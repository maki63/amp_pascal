UNIT COMP8;

INTERFACE

USES
 TYPE8,VAR8,LINE8,ELEMENT8,MATRIX8,TASK8,VAREXT8;

FUNCTION LOG(x:DOUBLE):DOUBLE;
FUNCTION MD(a,b:DOUBLE):DOUBLE;
FUNCTION PHR(a,b:DOUBLE):DOUBLE;
FUNCTION RE(m,p:DOUBLE):DOUBLE;
FUNCTION IM(m,p:DOUBLE):DOUBLE;

PROCEDURE CCP(job:taskpt);
PROCEDURE EVALCOFVARF(job:taskpt);
PROCEDURE EVALCOFVARC(job:taskpt);

PROCEDURE EVALNEWTON(j:taskpt);

PROCEDURE COMPUTE_TF_VALUE(fpt:listbpt;DLptr:dptr;yo_pt:yptr);

PROCEDURE CALC_Ysens_Y(y_ptr:yptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
PROCEDURE CALC_Ysens_G(g_ptr:gptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
PROCEDURE CALC_Ysens_Z(z_ptr:zptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
PROCEDURE CALC_Ysens_R(r_ptr:rptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
PROCEDURE CALC_Ysens_C(c_ptr:cptr; f_ptr :listbpt; Ys_HEAD_PT:listcpt);
PROCEDURE CALC_Ysens_L(l_ptr:lptr; f_ptr :listbpt; Ys_HEAD_PT:listcpt);

PROCEDURE ACCUMULATE_SENSOR_SENS(AccSS_HEAD_PT:drpt;CurrSrSi_HEAD_PT:drpt;eps_HEAD_PT:listbpt;Tun_pt:tunpt);
PROCEDURE COMPUTE_SENS_VAL(fpt:listbpt;NM:symb;Y0:BOOLEAN;Yc_head_ptr:listcpt;DLptr,DLPptr:dptr);

PROCEDURE SOLVE_YXYN(job:taskpt);



IMPLEMENTATION
USES Amp8_main;
{********************************************************}
{*******             log                     ************}
{********************************************************}

FUNCTION LOG(x:DOUBLE):DOUBLE;
BEGIN
 LOG:=LN(x)/LN(10)
END;

{********************************************************}
{*******           module                    ************}
{********************************************************}

FUNCTION MD(a,b:DOUBLE):DOUBLE;
BEGIN
 MD:=SQRT(SQR(a)+SQR(b))
END;

{********************************************************}
{*******           phase                     ************}
{********************************************************}

FUNCTION PHR(a,b:DOUBLE):DOUBLE;
VAR p:DOUBLE;
BEGIN
 IF a>0 THEN p:=ARCTAN(b/a);
 IF a<0 THEN p:=Pi+ARCTAN(b/a);
 IF a=0 THEN
 BEGIN
  IF b>0 THEN p:= Pi/2;
  IF b<0 THEN p:=-Pi/2;
  IF b=0 THEN p:= 0.0
 END;
 IF (p>Pi) THEN
  REPEAT
   p:=p-2*Pi
  UNTIL p<(Pi);
 IF (p<-Pi) THEN
  REPEAT
   p:=p+2*Pi
  UNTIL p>(-Pi);
 PHR:=p
END;

{********************************************************}
{*******           real  part                ************}
{********************************************************}

FUNCTION RE(m,p:DOUBLE):DOUBLE;
BEGIN
 RE:=m*COS(p)
END;

{********************************************************}
{*******           imaginary  part           ************}
{********************************************************}

FUNCTION IM(m,p:DOUBLE):DOUBLE;
BEGIN
 IM:=m*SIN(p)
END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE COMPUTE_TF_VALUE
    (fpt:listbpt;DLptr:dptr;yo_pt:yptr);
{* COMPUTE DL/DM*yld                                                   *}
{* and store results in TFmp_PT^ and TFri list                         *}
{* each time procedure is called TFmp_PT & TFri_PT are reseted         *}
{* cptL->DL ,DM is next                                                *}

VAR
tfre,tfim,tfmd,tfph:DOUBLE;
cptL,cptM:drpt;
smfptr,sriptr:drpt;
yo_re,yo_im:double;
BEGIN

{* TF CAN BE LOADED - Yo*DL/DM *}
{* IF NOT LOADED THEN ld=1     *}
{* ELSE ld=Yo OR pointer to load admitance is given                        *}


{* reset fpointer for DL,DM and var value                                  *}

 DLptr^.drfpt:=DLptr^.CF_PT;
 DLptr^.dnext^.drfpt:=DLptr^.dnext^.CF_PT;

 if ( yo_pt<>NIL ) then begin
  with (yo_pt^) do begin

    if (yvar=VARIABLE) then begin
        if (yvarpt^.Var_complex) then begin
            yvarpt^.VVC_TAIL_PT:=yvarpt^.VVC_HEAD_PT;
        end
        else begin
            yvarpt^.VVR_TAIL_PT:=yvarpt^.VVR_HEAD_PT;
        end
    end
    else if (yvar=TUNED) then begin
                ytunpt^.TUN_TAIL_PT:=ytunpt^.TUN_HEAD_PT;
        end
        else begin
                yo_re:=yvre;
                yo_im:=yvim;
        end
    end
 end
 else begin
    yo_re:=1.0;
    yo_im:=0.0;
 end;

{* set pointers to start frequency                                         *}
 cptL:=DLptr^.drfpt;
 cptM:=DLptr^.dnext^.drfpt;
 TFri_PT:=NIL;
 TFmp_PT:=NIL;
{* start loop                                                              *}
 WHILE fpt<>NIL DO
 BEGIN

  if ( yo_pt<>NIL ) then begin
    with (yo_pt^) do begin
      if (yvar=VARIABLE) then begin
        if (yvarpt^.Var_complex) then begin
          yo_re:=yvarpt^.VVC_TAIL_PT^.valre;
          yo_im:=yvarpt^.VVC_TAIL_PT^.valim;
          yvarpt^.VVC_TAIL_PT:=yvarpt^.VVC_TAIL_PT^.cvpt;
        end
        else begin
          yo_re:=yvarpt^.VVR_TAIL_PT^.value;
          yo_im:=0.0;
          yvarpt^.VVR_TAIL_PT:=yvarpt^.VVR_TAIL_PT^.vpt;
        end
      end
      else if (yvar=TUNED) then begin
        yo_re:=ytunpt^.TUN_TAIL_PT^.value;
        yo_im:=0.0;
        ytunpt^.TUN_TAIL_PT:=ytunpt^.TUN_TAIL_PT^.vpt;
      end;
    end;
  end;
  if (MD(cptM^.red,cptM^.imd)<>0.0) then
     tfmd:=MD(cptL^.red,cptL^.imd)/MD(cptM^.red,cptM^.imd)* MD(yo_re,yo_im)
  else
     tfmd:= max_1over0_value;

  tfph:=PHR(cptL^.red,cptL^.imd)-PHR(cptM^.red,cptM^.imd)+PHR(yo_re,yo_im);
  tfre:=RE(tfmd,tfph);
  tfim:=IM(tfmd,tfph);
  tfph:=PHR(tfre,tfim); {this should eventually normalise phase}
  tfph:=tfph*360/(2*Pi);
 {* add results to lists                                                *}
  ADD2COFF_LIST(TFmp_PT,smfptr,tfmd,tfph);
  ADD2COFF_LIST(TFri_PT,sriptr,tfre,tfim);
  {* update pointers *}
  cptL:=cptL^.drptn;
  cptM:=cptM^.drptn;
  fpt:=fpt^.vpt;
 END

END;

{***************************************************************************}
{  Calculate list of complex admitances refenced by Ys_HEAD_PT              }
{***************************************************************************}
PROCEDURE CALC_Ysens_Y(y_ptr:yptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
BEGIN
  WITH (y_ptr^) DO
  BEGIN

      ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
      case ( yvar ) of
      CONSTANT: begin
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=yvre;
                    ysens_ptr^.valim:=yvim;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
             end;
      VARIABLE: begin
                  if ( yvarpt^.Var_complex ) then begin
                     yvarpt^.VVC_TAIL_PT:=yvarpt^.VVC_HEAD_PT;
                  end
                  else begin
                     yvarpt^.VVR_TAIL_PT:=yvarpt^.VVR_HEAD_PT;
                  end;
                  while ( ysens_ptr<>NIL ) do begin
                    if ( yvarpt^.Var_complex ) then begin
                      ysens_ptr^.valre:=yvarpt^.VVC_TAIL_PT^.valre;
                      ysens_ptr^.valim:=yvarpt^.VVC_TAIL_PT^.valim;
                      yvarpt^.VVC_TAIL_PT:=yvarpt^.VVC_TAIL_PT^.cvpt;
                    end
                    else begin
                      ysens_ptr^.valre:=yvarpt^.VVR_TAIL_PT^.value;
                      ysens_ptr^.valim:=0.0;
                      yvarpt^.VVR_TAIL_PT:=yvarpt^.VVR_TAIL_PT^.vpt;
                    end;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                 end;
      TUNED: begin
                ytunpt^.TUN_TAIL_PT:=ytunpt^.TUN_HEAD_PT;
                while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=ytunpt^.TUN_TAIL_PT^.value;
                    ysens_ptr^.valim:=0.0;
                    ytunpt^.TUN_TAIL_PT:=ytunpt^.TUN_TAIL_PT^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                end;
             end;
      end;
  END;
END;


{***************************************************************************}
{  Calculate list of complex admitances refenced by Ys_HEAD_PT              }
{***************************************************************************}
PROCEDURE CALC_Ysens_G(g_ptr:gptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt );
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
BEGIN

  WITH (g_ptr^) DO
  BEGIN

      ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
      case ( gvar ) of
      CONSTANT: begin
                  ysens_ptr:=Ysens_HEAD_PT; { assign values to the existing list }
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=gvre;
                    ysens_ptr^.valim:=gvim;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      VARIABLE: begin
                  if ( gvarpt^.Var_complex ) then begin
                     gvarpt^.VVC_TAIL_PT:=gvarpt^.VVC_HEAD_PT;
                  end
                  else begin
                     gvarpt^.VVR_TAIL_PT:=gvarpt^.VVR_HEAD_PT;
                  end;
                  while ( ysens_ptr<>NIL ) do begin
                    if ( gvarpt^.Var_complex ) then begin
                      ysens_ptr^.valre:=gvarpt^.VVC_TAIL_PT^.valre;
                      ysens_ptr^.valim:=gvarpt^.VVC_TAIL_PT^.valim;
                      gvarpt^.VVC_TAIL_PT:=gvarpt^.VVC_TAIL_PT^.cvpt;
                    end
                    else begin
                      ysens_ptr^.valre:=gvarpt^.VVR_TAIL_PT^.value;
                      ysens_ptr^.valim:=0.0;
                      gvarpt^.VVR_TAIL_PT:=gvarpt^.VVR_TAIL_PT^.vpt;
                    end;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                 end;
      TUNED:    begin
                  gtunpt^.TUN_TAIL_PT:=gtunpt^.TUN_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=gtunpt^.TUN_TAIL_PT^.value;
                    ysens_ptr^.valim:=0.0;
                    gtunpt^.TUN_TAIL_PT:=gtunpt^.TUN_TAIL_PT^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
              end;
      end;
   END;
 END;

{***************************************************************************}
{  Calculate list of complex admitances refenced by Ys_HEAD_PT              }
{***************************************************************************}
PROCEDURE CALC_Ysens_Z(z_ptr:zptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
  zr,zi:double;
BEGIN

  WITH (z_ptr^) DO
  BEGIN

      ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
      case ( zvar ) of
      CONSTANT: begin
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre := -(zvre)/(zvre*zvre+zvim*zvim);   {change of sign for STF[Z]=-STF[Y=1/Z]}
                    ysens_ptr^.valim := +(zvim)/(zvre*zvre+zvim*zvim);
                    ysens_ptr := ysens_ptr^.cvpt;
                  end;
                end;
      VARIABLE: begin
                  if ( zvarpt^.Var_complex ) then begin
                     zvarpt^.VVC_TAIL_PT:=zvarpt^.VVC_HEAD_PT;
                  end
                  else begin
                     zvarpt^.VVR_TAIL_PT:=zvarpt^.VVR_HEAD_PT;
                  end;
                  while ( ysens_ptr<>NIL ) do begin
                    if ( zvarpt^.Var_complex ) then begin
                      zr := zvarpt^.VVC_TAIL_PT^.valre;
                      zi := zvarpt^.VVC_TAIL_PT^.valim;
                      zvarpt^.VVC_TAIL_PT:=zvarpt^.VVC_TAIL_PT^.cvpt;
                    end
                    else begin
                      zr := zvarpt^.VVR_TAIL_PT^.value;
                      zi := 0.0;
                      zvarpt^.VVR_TAIL_PT:=zvarpt^.VVR_TAIL_PT^.vpt;
                    end;
                    ysens_ptr^.valre := -zr/(zr*zr+zi*zi); {change of sign for STF[Z]=-STF[Y=1/Z]}
                    ysens_ptr^.valim := +zi/(zr*zr+zi*zi); {change of sign for STF[Z]=-STF[Y=1/Z]}
                    ysens_ptr := ysens_ptr^.cvpt;
                  end;
                 end;
      end;
  END;
 END;



{***************************************************************************}
{  Calculate list of complex admitances refenced by Ys_HEAD_PT              }
{***************************************************************************}
PROCEDURE CALC_Ysens_R(r_ptr:rptr; f_ptr:listbpt; Ys_HEAD_PT:listcpt);
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
BEGIN

  WITH (r_ptr^) DO
  BEGIN

      ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
      case ( rvar ) of
      CONSTANT: begin
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=-1.0/rv;   {change of sign for STF[R]=-STF[Y=1/R]}
                    ysens_ptr^.valim:=0.0;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      VARIABLE: begin
                  rvarpt^.VVR_TAIL_PT:=rvarpt^.VVR_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=-1.0/(rvarpt^.VVR_TAIL_PT^.value);
                    ysens_ptr^.valim:=0.0;
                    rvarpt^.VVR_TAIL_PT:=rvarpt^.VVR_TAIL_PT^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      TUNED:    begin
                  rtunpt^.TUN_TAIL_PT:=rtunpt^.TUN_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    ysens_ptr^.valre:=-1.0/(rtunpt^.TUN_TAIL_PT^.value);
                    ysens_ptr^.valim:=0.0;
                    rtunpt^.TUN_TAIL_PT:=rtunpt^.TUN_TAIL_PT^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      end;
  END;
 END;


{***************************************************************************}
{  Calculate list of complex admitances refenced by Ysens_HEAD_PT           }
{***************************************************************************}
PROCEDURE CALC_Ysens_C(c_ptr:cptr; f_ptr :listbpt; Ys_HEAD_PT:listcpt);
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
  freq:double;
BEGIN

  WITH (c_ptr^) DO
  BEGIN

    ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
    case ( cvar ) of
    CONSTANT: begin

                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    ysens_ptr^.valre:=0.0;
                    ysens_ptr^.valim:=(2*Pi*freq)*cv;  { assign values to the list }
                    f_ptr:=f_ptr^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;

             end;
      VARIABLE: begin
                  cvarpt^.VVR_TAIL_PT:=cvarpt^.VVR_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    ysens_ptr^.valre:=0.0;
                    ysens_ptr^.valim:=(2*Pi*freq)*(cvarpt^.VVR_TAIL_PT^.value);
                    cvarpt^.VVR_TAIL_PT:=cvarpt^.VVR_TAIL_PT^.vpt;
                    f_ptr:=f_ptr^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      TUNED:    begin
                  ctunpt^.TUN_TAIL_PT:=ctunpt^.TUN_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    ysens_ptr^.valre:=0.0;
                    ysens_ptr^.valim:=(2*Pi*freq)*(ctunpt^.TUN_TAIL_PT^.value);
                    ctunpt^.TUN_TAIL_PT:=ctunpt^.TUN_TAIL_PT^.vpt;
                    f_ptr:=f_ptr^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      end;
  END;
END;

{***************************************************************************}
{  Calculate list of complex admitances refenced by Ysens_HEAD_PT           }
{***************************************************************************}
PROCEDURE CALC_Ysens_L(l_ptr:lptr; f_ptr :listbpt; Ys_HEAD_PT:listcpt);
VAR
  ysens_ptr:listcpt; {list of complex values transfered to COMPUTE_SENS_VAL}
  freq:double;
BEGIN

  WITH (l_ptr^) DO
  BEGIN

    ysens_ptr:=Ys_HEAD_PT; { assign values to the existing list }
    case ( lvar ) of
    CONSTANT: begin
                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    if ( freq=0.0 ) then begin
                      ysens_ptr^.valre:=0.0;                     {this will make S[L]=0 for DC}
                      ysens_ptr^.valim:=0.0;                     {this will make S[L]=0 for DC}
                    end
                    else begin
                      ysens_ptr^.valre:=0.0;
                      ysens_ptr^.valim:=1.0/((2*Pi*freq)*lv);   { STF[L]=-STF[YL=-j/(w*L)] }
                    end;
                    ysens_ptr:=ysens_ptr^.cvpt;
                    f_ptr:=f_ptr^.vpt;
                  end;
             end;
     VARIABLE: begin
                  lvarpt^.VVR_TAIL_PT:=lvarpt^.VVR_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    if ( freq=0.0 ) then begin
                      ysens_ptr^.valre:=0.0;                     {this will make S[L]=0 for DC}
                      ysens_ptr^.valim:=0.0;                     {this will make S[L]=0 for DC}
                    end
                    else begin
                       ysens_ptr^.valre:=0.0;
                       ysens_ptr^.valim:=1.0/((2*Pi*freq)*(lvarpt^.VVR_TAIL_PT^.value));
                    end;
                    lvarpt^.VVR_TAIL_PT:=lvarpt^.VVR_TAIL_PT^.vpt;
                    f_ptr:=f_ptr^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
      TUNED:    begin
                  ltunpt^.TUN_TAIL_PT:=ltunpt^.TUN_HEAD_PT;
                  while ( ysens_ptr<>NIL ) do begin
                    freq:=f_ptr^.value;
                    if ( freq=0.0 ) then begin
                      ysens_ptr^.valre:=0.0;                     {this will make S[L]=0 for DC}
                      ysens_ptr^.valim:=0.0;                     {this will make S[L]=0 for DC}
                    end
                    else begin
                      ysens_ptr^.valre:=0.0;
                      ysens_ptr^.valim:=1.0/((2*Pi*freq)*(ltunpt^.TUN_TAIL_PT^.value));
                    end;
                    ltunpt^.TUN_TAIL_PT:=ltunpt^.TUN_TAIL_PT^.vpt;
                    f_ptr:=f_ptr^.vpt;
                    ysens_ptr:=ysens_ptr^.cvpt;
                  end;
                end;
        end;
  END;
 END;
{***************************************************************************}
{ Denominator has the form of sum for each sensors                          }
{ [SUM(S[TF/Yi]*S[Yi/eps])]=SUM[eps*svar/(scons+svar*eps)*S[TF/sens]        }
{***************************************************************************}

PROCEDURE ACCUMULATE_SENSOR_SENS(AccSS_HEAD_PT:drpt;CurrSrSi_HEAD_PT:drpt;eps_HEAD_PT:listbpt;Tun_pt:tunpt);
VAR
  acc_pt:drpt;
  curr_pt:drpt;
  eps_pt:listbpt;
  Tun_var, Tun_const:double;

  BEGIN

  acc_pt:=AccSS_HEAD_PT;
  curr_pt:=CurrSrSi_HEAD_PT;
  eps_pt:=eps_HEAD_PT;
  Tun_var:=Tun_pt^.tunvar;
  Tun_const:=Tun_pt^.tunconst;

  while acc_pt<>NIL do begin
    acc_pt^.red:=acc_pt^.red+curr_pt^.red*(Tun_var*eps_pt^.value)/(Tun_var*eps_pt^.value+Tun_const);
    acc_pt^.imd:=acc_pt^.imd+curr_pt^.imd*(Tun_var*eps_pt^.value)/(Tun_var*eps_pt^.value+Tun_const);
    acc_pt:=acc_pt^.drptn;
    curr_pt:=curr_pt^.drptn;
    eps_pt:=eps_pt^.vpt;
  end;

END;
{***************************************************************************}
PROCEDURE COMPUTE_SENS_VAL
(fpt:listbpt;NM:symb;Y0:BOOLEAN;Yc_head_ptr:listcpt;DLptr,DLPptr:dptr);

{* DLptr->DL;DM is next                                                   *}
{* DLPptr->DL';DM'is next                                                 *}
{* this procedure computes sensitivties                                   *}
{* (Yre+jYim)*(DL'/DL-DM'/DM)                                             *}
{* and stores the results in DR list  which is referenced by SrSi_PT      *}
{ Yc_head_ptr poits to the list of (Yre+jYim)                              }
VAR
 cptL,ccptL,cptM,ccptM:drpt;
 solpt:drpt;
 LC_Lmd,LC_Lph,LC_Lre,LC_Lim,MC_Mmd,MC_Mph,MC_Mre,MC_Mim:DOUBLE;
 S_re,S_im,Sre,Sim:DOUBLE;
 Yre,Yim:double;
 cv_ptr:listcpt;
BEGIN


{* reset fpointer for DL,DM and               *}
 DLptr^.drfpt:=DLptr^.CF_PT;
 DLptr^.dnext^.drfpt:=DLptr^.dnext^.CF_PT;
{* COMP_DL,COMP_DM                            *}
 DLPptr^.drfpt:=DLPptr^.CF_PT;
 DLPptr^.dnext^.drfpt:=DLPptr^.dnext^.CF_PT;

{* set pointers to start frequency                                         *}
 cptL:=DLptr^.drfpt;
 cptM:=DLptr^.dnext^.drfpt;
 ccptL:=DLPptr^.drfpt;
 ccptM:=DLPptr^.dnext^.drfpt;
 cv_ptr:=Yc_head_ptr;
{* start loop                                                              *}
 SrSi_PT:=NIL;

 WHILE fpt<>NIL DO
 BEGIN

  Yre:=cv_ptr^.valre;
  Yim:=cv_ptr^.valim;
  LC_Lmd:=MD(ccptL^.red,ccptL^.imd)/MD(cptL^.red,cptL^.imd);
  LC_Lph:=PHR(ccptL^.red,ccptL^.imd)-PHR(cptL^.red,cptL^.imd);
  LC_Lre:=RE(LC_Lmd,LC_Lph);
  LC_Lim:=IM(LC_Lmd,LC_Lph);
  MC_Mmd:=MD(ccptM^.red,ccptM^.imd)/MD(cptM^.red,cptM^.imd);
  MC_Mph:=PHR(ccptM^.red,ccptM^.imd)-PHR(cptM^.red,cptM^.imd);
  MC_Mre:=RE(MC_Mmd,MC_Mph);
  MC_Mim:=IM(MC_Mmd,MC_Mph);
{*  DO NOT TRY TO ELIMINATE S_re S_im - L & C                             *}
  S_re:=LC_Lre - MC_Mre;
  S_im:=LC_Lim - MC_Mim;
  Sre:=S_re*Yre-S_im*Yim;
  Sim:=S_re*Yim+S_im*Yre;
  IF Y0 THEN Sre:=Sre+1;

  {* store new value *}
  ADD2COFF_LIST(SrSi_PT,solpt,Sre,Sim);

  {* update pointers *}
  cptL:=cptL^.drptn;
  cptM:=cptM^.drptn;
  ccptL:=ccptL^.drptn;
  ccptM:=ccptM^.drptn;
  cv_ptr:=cv_ptr^.cvpt;
  fpt:=fpt^.vpt;
 END
END;

{**************************************************************************}
{**************************************************************************}
{**************************************************************************}

 PROCEDURE SOLVE_YXYN(job:taskpt);
 VAR
  d,dx,dy,dxy:drpt;
  fpt:listbpt;
  d_ptr:dptr;
  solpt:drpt;
  r1,i1,r2,i2,r3,i3,r4,i4,a,b,c,delta:DOUBLE;
  rl1,il1,rm1,im1,rl2,il2,rm2,im2,yx,yx1,yx2,yn,zn1,zn2:DOUBLE;
  yxe1,yxe2:DOUBLE;

 BEGIN
  probable:=TRUE;
  d_ptr:=job^.COFF_PT;
  WHILE (d_ptr<>NIL) DO
  BEGIN
   d_ptr^.drfpt:=d_ptr^.CF_PT;
   d_ptr:=d_ptr^.dnext
  END;
  YxYn_PT:=NIL;
{* coffactor order is D,Dyx,Dyn,Dynyx                                      *}
  d:=job^.COFF_PT^.drfpt;
  dx:=job^.COFF_PT^.dnext^.drfpt;
  dy:=job^.COFF_PT^.dnext^.dnext^.drfpt;
  dxy:=job^.COFF_PT^.dnext^.dnext^.dnext^.drfpt;
  fpt:=job^.FREQ_PT;
  WHILE fpt<>NIL DO
  BEGIN
{* compute yx1,yx2                                                       *}
   r1:=d^.red;   i1:=d^.imd;
   r2:=dx^.red;  i2:=dx^.imd;
   r3:=dy^.red;  i3:=dy^.imd;
   r4:=dxy^.red; i4:=dxy^.imd;
   a:=r2*i4-r4*i2;
   b:=r1*i4-r4*i1+r2*i3-r3*i2;
   c:=r1*i3-r3*i1;
   delta:=b*b-4*a*c;
   IF delta<0.0 THEN
   BEGIN
    STATUS('PARABOLIC EQUATION FOR $GR CANNOT BE SOLVED - DELTA<0');
    WRITELN(RESULTS);
    WRITELN(RESULTS,'PARABOLIC EQUATION FOR $GR CANNOT BE SOLVED - DELTA<0');
    {* STRANGE ERROR *}
    ERROR(0,0);
   END

   ELSE
   BEGIN {* start for delta >=0 *}

    IF (a=0.0) OR (c=0.0) THEN
    BEGIN
     IF (a=0.0) THEN
     BEGIN
      yx1:=-c/b;
{* compute Zn\Mn                                                          *}
      rl1:=r3+yx1*r4;
      il1:=i3+yx1*i4;
      rm1:=r1+yx1*r2;
      im1:=i1+yx1*i2;
{* compute  real part Z/M#1                                               *}
      zn1:=(rl1*rm1+il1*im1)/(rm1*rm1+im1*im1);
      yn:=-1/zn1;
      yx:=yx1
     END  {* end for a=0 *}
     ELSE
     BEGIN {* c=0        *}
       yx1:=-b/a;
{* compute Zn\Mn - use Yx & try do discard nonsense solutions             *}
       rl1:=r3+yx1*r4;
       il1:=i3+yx1*i4;
       rm1:=r1+yx1*r2;
       im1:=i1+yx1*i2;
{* compute  real part Z/M#1                                               *}
       zn1:=(rl1*rm1+il1*im1)/(rm1*rm1+im1*im1);
       yn:=-1/zn1;
       yx:=yx1
     END  {* end for c=0 *}
    END   {* end for one root *}

    ELSE
    BEGIN {* start for two roots *}

     yx1:=(-b+SQRT(delta))/(2*a);
     yx2:=(-b-SQRT(delta))/(2*a);

{* compute Zn\Mn - use Yx & try do discard nonsense solutions             *}
{* For Yn,Rn                                                              *}
{* Zn as seen from nonlinear terminals should be negative                 *}
{* in order to acomplish  Rn+Zn=0  where Rn-nonlinear resistor attached   *}
{* Yn=-1/Zn admitance of nonlinear resistor                               *}
{* For Gn                                                                 *}
{* Mn       as seen from nonlinear terminals should be negative           *}
{* in order to acomplish  Gn*Mn=-1 where Gn-nonlinear transcond attached  *}
{* Gn=-1/Mn transconductance of nonlinear VCCS                            *}

      rl1:=r3+yx1*r4;
      il1:=i3+yx1*i4;
      rm1:=r1+yx1*r2;
      im1:=i1+yx1*i2;
{* compute  real part Z/M#1                                               *}
      zn1:=(rl1*rm1+il1*im1)/(rm1*rm1+im1*im1);
      rl2:=r3+yx2*r4;
      il2:=i3+yx2*i4;
      rm2:=r1+yx2*r2;
      im2:=i1+yx2*i2;
{* compute  real part Z/M#2                                               *}
      zn2:=(rl2*rm2+il2*im2)/(rm2*rm2+im2*im2);

      IF ((zn1<0.0)AND(zn2>=0.0)) OR ((zn2<0.0)AND(zn1>=0.0))  THEN
      BEGIN
       IF zn1<0 THEN
       BEGIN
        yn:=-1/zn1;yx:=yx1
       END
       ELSE
       BEGIN
        yn:=-1/zn2;yx:=yx2
       END
      END

      ELSE
      BEGIN  {* start of problems *}
       probable:=FALSE;
{* PROBLEMS:                                                            *}
{* SOLUTION A:                                                             *}
{* FIND TWO ESTIMATIONS:  for b>0                                          *}
{*            for a->0   yxe1=-c/b =>> yx1->yxe1 and  yx2->+/-inf          *}
{*            for c->0   yxe2=-b/a =>> yx1->0    and  yx2->yxe2            *}
{*                        if  b<0  yxe1<->yxe2                             *}
{* AND TRY TO MATCH                                                        *}
{* SOLUTION B: zn1,zn2 are both negative                                   *}
{* due to numeric errors some solution are strange                         *}
{* DISCARD strange results. Limits are 1mOhm to 1GOhm                      *}
{* SOLUTION C:                                                             *}
{* zn1,zn2 are both positive - choose positive yx,if not exist choose yx   *}
       IF (b>0.0) THEN
       BEGIN
        yxe1:=-c/b;
        yxe2:=-b/a
       END
       ELSE
       BEGIN
        yxe1:=-b/a;
        yxe2:=-c/b
       END;

       IF ((ABS(yx1/yxe1-1)<1.0E-3) AND (zn1<0.0)) OR
          ((ABS(yx2/yxe2-1)<1.0E-3) AND (zn2<0.0))
       THEN
       BEGIN   {* start for solution A *}


               IF ((ABS(yx1/yxe1-1)<1.0E-3) AND (zn1<0.0)) THEN
               BEGIN
                 yn:=-1/zn1;yx:=yx1
               END
               ELSE
               BEGIN
                  yn:=-1/zn2;yx:=yx2
               END



       END     {* end for solution A *}

       ELSE
       BEGIN   {* start for solution B *}
        IF (zn1<0) AND (zn2<0) THEN
        BEGIN

           IF ((abs(zn1)<1.0E+9) AND (abs(zn1)>1.0E-3) AND
              ((abs(zn2)>1.0E+9) OR (abs(zn2)<1.0E-3)))
           OR ((abs(zn2)<1.0E+9) AND (abs(zn2)>1.0E-3) AND
              ((abs(zn1)>1.0E+9) OR (abs(zn1)<1.0E-3))) THEN

               IF
                ((abs(zn1)<1.0E+9) AND (abs(zn1)>1.0E-3) AND
                ((abs(zn2)>1.0E+9) OR (abs(zn2)<1.0E-3))) THEN
               BEGIN
                 yx:=yx1; yn:=-1/zn1
               END
               ELSE
               BEGIN
                 yx:=yx2; yn:=-1/zn2
               END
            ELSE
               IF (yx1 >0.0) THEN
               BEGIN
                yx:=yx1; yn:=-1/zn1;
               END
               ELSE
               BEGIN
                yx:=yx2; yn:=-1/zn2;
               END


        END    {* end for solution B *}
        ELSE
        BEGIN  {* start for solution C *}


                  IF (yx1*yx2 <0.0) THEN
                    IF (yx1>0.0) THEN
                    BEGIN
                     yx:=yx1; yn:=-1/zn1;
                    END
                    ELSE
                    BEGIN
                     yx:=yx2; yn:=-1/zn2;
                    END
                  ELSE
                    BEGIN
                     yx:=yx1; yn:=-1/zn1;
                    END
       END   {* end of solution C  *}

      END    {* end of problems    *}
   END       {* end of two roots   *}
 END
 END;        {* end for delta >0   *}


 ADD2COFF_LIST(YxYn_PT,solpt,yx,yn);

 d:=d^.drptn;
 dx:=dx^.drptn;
 dy:=dy^.drptn;
 dxy:=dxy^.drptn;
 fpt:=fpt^.vpt;
 END
END;



{***************************************************************************}
{***************************************************************************}
{***************************************************************************}


{*********************************************************}
{*******        cofactor's control            ************}
{*********************************************************}

PROCEDURE CCP(job:taskpt);
VAR
 lc,lg:INTEGER;
 count1,count2:STRING;
 d_ptr:dptr;


{***************************************************************************
 PCR ancient version using global varaibles
 *******  put in order cofactor string       ************
 global variables:
 lc - lenght
 (a1+b1)(a2+b2)(a3+b3)..... is kept in cf
 [a1,a2,a3,....]
 [b1,b2,b3,....]
 cofactor is passed by a variable, so that properly ordered is returned.
 The ops means:
 add row(col) ai to bi and remove row (col)ai
 0 means not existing row
 Putting in order means sorting in the way the operations can be carried seamlessly
 from first index to the last without any clash (i.e. attempt to delete no existing row)

 global input/output:
 lc: lenght of coffactor - might be changed by operation of removal of (0+0)(0+0)

 global output:
 fcf - TRUE - fail in coffactor order
 cs - change sign counter includes sum of deleted rows(columns) ai


 @version - 1.0
 @param   x:cf
 @param
 @param
 @param
 ***************************************************************************}


PROCEDURE PCR( VAR x:cf);

 VAR
 r:BOOLEAN;                               {r=TRUE  means that check is in order }
 k,b1,b2,p,s:INTEGER;

 {*
   M from match - Find index x[1,p] in following cells i.e (p..lc)
   - if found - M=TRUE
   using p as global

 *}
 FUNCTION M:BOOLEAN;
 VAR
  k:INTEGER;
 BEGIN
  M:=FALSE;
  FOR k:=p+1 TO lc DO
  IF ((x[1,k]=x[1,p]) OR (x[2,k]=x[1,p])) THEN M:=TRUE;
 END;

BEGIN{pcr}

p:=1; { pointer to first index }
WHILE ((p<=lc)AND(NOT fcf)) DO            { fcf - is fail in coffactor order}
BEGIN{a}
  s:=lc-p;                                { s is a swap counter }
  REPEAT
  BEGIN{b}
    r:=FALSE;                             { r - repeated value in following indexes ai - is current pointed by p }
    IF (x[1,p]=0)AND(x[2,p]<>0) THEN      { this is kind of (0+ai) -> change to (ai+0) and cs++ }
    BEGIN
     x[1,p]:=x[2,p];x[2,p]:=0;cs:=cs+1
    END;
    IF x[1,p]<>x[2,p] THEN                {if (ai=bi) then 0 }
    BEGIN {c}
      r:=M;                               { check if ai appears in next indexes }
      IF r THEN
      BEGIN{d}
        IF x[2,p]<>0 THEN                 { if yes try to swap ai<->bi and check again }
        BEGIN{e}
          b1:=x[1,p];x[1,p]:=x[2,p];x[2,p]:=b1;
          cs:=cs+1;                       { (ai+bi) -> (bi+ai) and cs++ }
          r:=M;
        END{e};
        IF r  THEN
         IF s>0 THEN                     { if s > 0 there is an option for swap, so put (ai+bi) at the end of list }
         BEGIN{f}
           b1:=x[1,p];b2:=x[2,p];
           FOR k:=p TO lc-1 DO
           BEGIN{g}
             x[1,k]:=x[1,k+1];x[2,k]:=x[2,k+1]
           END;{g}
           x[1,lc]:=b1;x[2,lc]:=b2;
           s:=s-1;cs:=cs+lc-p;         { decrement swap counter }
         END{f}
         ELSE fcf:=TRUE                { no option for swap }
       END{d}
     END {c}
     ELSE
     BEGIN
      IF (x[1,p]=0)AND(x[2,p]=0) THEN  { ai = bi (0+0) might be canceled }
      BEGIN
       FOR k:=p TO lc-1 DO
       BEGIN{h}
        x[1,k]:=x[1,k+1];x[2,k]:=x[2,k+1]  { remove (0+0) and decrease lenght }
       END;{h}
       lc:=lc-1;p:=p-1                     {now p must kept, thus p--  because p++ at the end the end of the loop}
      END
      ELSE fcf:=TRUE                  { (ai+ai) is something which is always 0 }
     END
  END {b}
  UNTIL((NOT r)OR fcf);               { if not r there was a swap so repeat }
  p:=p+1
END;{a}
FOR k:=1 TO lc DO
BEGIN
 FOR p:=k+1 TO lc DO
  IF x[1,p]<x[1,k] THEN cs:=cs+1;
  cs:=cs+x[1,k]
END
END;{pcr}

{********************************************************}
{*******   complemet cofactors-d computings   ***********}
{*******   take into cosideration A X E L     ***********}
{********************************************************}

PROCEDURE CCF0 (d_ptr:dptr);

VAR j:INTEGER;
a_ptr:aptr;
l_ptr:lptr;

BEGIN
  WITH d_ptr^ DO
  BEGIN
   FOR j:=1 TO nmax+1 DO
   BEGIN
    IF j<=ddim THEN
    BEGIN
     ROW0[1,j]:=wr[1,j];ROW0[2,j]:=wr[2,j]
    END
    ELSE
    BEGIN
     ROW0[1,j]:=0;ROW0[2,j]:=0
    END;
    IF j<=ddim THEN
    BEGIN
     COL0[1,j]:=kl[1,j];COL0[2,j]:=kl[2,j]
    END
    ELSE
    BEGIN
     COL0[1,j]:=0;COL0[2,j]:=0
    END
   END;
   lgt0:=ddim;
   ctb:=TRUE;
   a_ptr:=A_head;
   WHILE a_ptr<>NIL DO
   BEGIN
    WITH a_ptr^ DO
    BEGIN
     lgt0:=lgt0+1;
     ROW0[1,lgt0]:=aa;
     ROW0[2,lgt0]:=ab;
     COL0[1,lgt0]:=ad;
     COL0[2,lgt0]:=ac
    END;
    a_ptr:=a_ptr^.anext
   END;

   l_ptr:=L_head;
   WHILE l_ptr<>NIL DO
   BEGIN
    WITH l_ptr^ DO
    BEGIN
     lgt0:=lgt0+1;
     ROW0[1,lgt0]:=la;
     ROW0[2,lgt0]:=lb;
     COL0[1,lgt0]:=la;
     COL0[2,lgt0]:=lb
    END;
   l_ptr:=l_ptr^.lnext
  END
 END
END;{CCF0}

{********************************************************}
{*******   complemet cofactors-d computings   ***********}
{*******   take into cosideration A X E       ***********}
{********************************************************}

PROCEDURE CCF1 ( d_ptr:dptr);

VAR
 l:INTEGER;
 a_ptr:aptr;

BEGIN
  WITH d_ptr^ DO
  BEGIN
   FOR l:=1 TO nmax+1 DO
   BEGIN
    IF l<=ddim THEN
    BEGIN
     ROW[1,l]:=wr[1,l];ROW[2,l]:=wr[2,l]
    END
    ELSE
    BEGIN
     ROW[1,l]:=0;ROW[2,l]:=0
    END;
    IF l<=ddim THEN
    BEGIN
     COL[1,l]:=kl[1,l];COL[2,l]:=kl[2,l]
    END
    ELSE
    BEGIN
     COL[1,l]:=0;COL[2,l]:=0
    END
   END;
   lgt:=ddim;
   ctb:=TRUE;
   a_ptr:=A_head;
   WHILE a_ptr<>NIL DO
   BEGIN
    WITH a_ptr^ DO
    BEGIN
     lgt:=lgt+1;
     ROW[1,lgt]:=aa;
     ROW[2,lgt]:=ab;
     COL[1,lgt]:=ad;
     COL[2,lgt]:=ac
    END;
    a_ptr:=a_ptr^.anext
   END;
  END;
END;{CCF1}

{********************************************************}
{*******     transfomation of row/col        ************}
{********************************************************}

PROCEDURE CTM(x:cf; l:INTEGER; VAR y:tmat);
VAR
 i,j,m,c:INTEGER;
 BEGIN {CTM}
  FOR i:=1 TO nmax+1 DO y[i]:=i-1;
  FOR i:=1 TO l DO
   FOR j:=1 TO nmax+1 DO
    IF y[j]=x[1,i] THEN y[j]:=x[2,i];
  IF l<>0 THEN
  BEGIN                  {a}
   c:=1;
   REPEAT
   BEGIN                 {b}
    i:=1;m:=9999;
    REPEAT
    BEGIN                {c}
     IF (y[i]>=c) AND (y[i]<m) THEN m:=y[i];
     i:=i+1
    END                  {c}
    UNTIL (i>(nmax+1)) OR (m=c);
    FOR j:=1 TO nmax+1 DO IF y[j]=m THEN y[j]:=c;
    c:=c+1
    END                  {b}
    UNTIL c>(nmax+1)
   END                   {a}
 END; {CTM}

{********************************************************}
{****************** ACTUAL CPP   ************************}
{********************************************************}

BEGIN

 STR(D_tail^.d,count2);
 d_ptr:=job^.COFF_PT;
 WHILE d_ptr<>NIL DO
 BEGIN
  STR(d_ptr^.d,count1);
  STATUS(CONCAT('PREPARING:',d_ptr^.dname,'   PROGRESS:',count1,' OF ',count2));
  CCF0(d_ptr);
  CCF1(d_ptr);
  WITH d_ptr^ DO
  BEGIN                {a}
   fcf:=FALSE;
   cs:=0;
   lc:=lgt0;
   PCR(ROW0);
   lg:=lc;
   lc:=lgt0;
   PCR(COL0);
   IF lg<>lc THEN fcf:=TRUE;
   ctb0:=NOT fcf;
   csg0:=cs;
   lgt0:=lc;
   IF ctb0 THEN
   BEGIN
    CTM(ROW0,lgt0,RT0);
    CTM(COL0,lgt0,CT0)
   END;
   fcf:=FALSE;
   cs:=0;
   lc:=lgt;
   PCR(ROW);
   lg:=lc;
   lc:=lgt;
   PCR(COL);
   IF lg<>lc THEN fcf:=TRUE;
   ctb:=NOT fcf;
   csg:=cs;
   lgt:=lc;
   IF ctb THEN
   BEGIN
    CTM(ROW,lgt,RT);
    CTM(COL,lgt,CT)
   END
  END;
  d_ptr:=d_ptr^.dnext;
 END
END;{CCP}

{***************************************************************************}
{*******             evaluate all cofactors for freqency list   ************}
{***************************************************************************}

PROCEDURE EVALCOF(j:taskpt);
VAR
 count1,count2:STRING;
 d_ptr:dptr;

BEGIN
 {* CCP must be provided by invoking procedure *}

 STR(D_tail^.d,count2);
 d_ptr:=j^.COFF_PT;
 WHILE d_ptr<>NIL DO
 BEGIN

  STR(d_ptr^.d,count1);
  STATUS(CONCAT('COMPUTING:',d_ptr^.dname,'   PROGRESS:',count1,' OF ',count2));
  CCOFF(j,d_ptr);
  d_ptr:=d_ptr^.dnext
 END
END;


{***************************************************************************}
{*******           evaluate cofators for var. freq.             ************}
{***************************************************************************}

PROCEDURE EVALCOFVARF(job:taskpt);
VAR
 fpoints:INTEGER;
 fpstr:STRING;
 fpt:listbpt;

BEGIN           {ECF}
 {* prepare for computings all coffactors *}
{* find number of freq points                                              *}
 fpt:=job^.FREQ_PT;
 fpoints:=0;
 WHILE fpt<>NIL DO
 BEGIN
  fpoints:=fpoints+1;
  fpt:=fpt^.vpt
 END;
 Str(fpoints,fpstr);
 INFO
 (CONCAT('CALCULATING COFFACTORS FOR ',fpstr,' DISCRETE FREQUENCY POINTS'));
 CCP(job);
 EVALCOF(job)
END;            {ECF}


{**************************************************************************}

PROCEDURE RESET_TUN_LISTS(j:taskpt);
VAR
 tun_ptr:tunpt;

BEGIN

  tun_ptr:=j^.TUN_PT;
  while tun_ptr<>NIL do
  begin
    tun_ptr^.TUN_TAIL_PT:=tun_ptr^.TUN_HEAD_PT;
    tun_ptr:=tun_ptr^.tunnext;
  end;

END;

{**************************************************************************}

PROCEDURE RESET_VAR_LISTS(j:taskpt);
VAR
 var_ptr:varpt;

BEGIN

  var_ptr:=j^.VAR_PT;
  while var_ptr<>NIL do
  begin
    if (var_ptr^.Var_complex) then begin
      var_ptr^.VVC_TAIL_PT:=var_ptr^.VVC_HEAD_PT;
    end
    else begin
      var_ptr^.VVR_TAIL_PT:=var_ptr^.VVR_HEAD_PT;
    end;
    var_ptr:=var_ptr^.varnext;
  end;

END;


{**************************************************************************}

PROCEDURE UPDATE_TUN_LISTS(j:taskpt);
VAR
 tun_ptr:tunpt;

BEGIN

  tun_ptr:=j^.TUN_PT;
  while tun_ptr<>NIL do
  begin
    tun_ptr^.TUN_TAIL_PT:=tun_ptr^.TUN_TAIL_PT^.vpt;
    tun_ptr:=tun_ptr^.tunnext;
  end;

END;

{**************************************************************************}

PROCEDURE UPDATE_VAR_LISTS(j:taskpt);
VAR
 var_ptr:varpt;

BEGIN

  var_ptr:=j^.VAR_PT;
  while var_ptr<>NIL do
  begin
    if (var_ptr^.Var_complex) then begin
      var_ptr^.VVC_TAIL_PT:=var_ptr^.VVC_TAIL_PT^.cvpt;
    end
    else begin
      var_ptr^.VVR_TAIL_PT:=var_ptr^.VVR_TAIL_PT^.vpt;
    end;
    var_ptr:=var_ptr^.varnext;
  end;

END;


{**************************************************************************}

PROCEDURE SET_TUN_VALUES(j:taskpt);
VAR
 y_ptr:yptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
BEGIN

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = TUNED ) then begin
          y_ptr^.yvre:=y_ptr^.ytunpt^.TUN_TAIL_PT^.value;
          y_ptr^.yvim:=0.0;
       end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = TUNED ) then begin
        g_ptr^.gvre:=g_ptr^.gtunpt^.TUN_TAIL_PT^.value;
        g_ptr^.gvim:=0.0;
       end;
       g_ptr:=g_ptr^.gnext;
  end;


  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if (r_ptr^.rvar = TUNED) then begin
          r_ptr^.rv:=r_ptr^.rtunpt^.TUN_TAIL_PT^.value;
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if (c_ptr^.cvar = TUNED) then begin
          c_ptr^.cv:=c_ptr^.ctunpt^.TUN_TAIL_PT^.value;
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if (l_ptr^.lvar = TUNED) then begin
          l_ptr^.lv:=l_ptr^.ltunpt^.TUN_TAIL_PT^.value;
       end;
       l_ptr:=l_ptr^.lnext;
  end;

END;

{**************************************************************************}

PROCEDURE SET_VAR_VALUES(j:taskpt);
VAR
 y_ptr:yptr;
 g_ptr:gptr;
 z_ptr:zptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
BEGIN

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = VARIABLE ) then begin
            if (y_ptr^.yvarpt^.Var_complex) then begin
              y_ptr^.yvre:=y_ptr^.yvarpt^.VVC_TAIL_PT^.valre;
              y_ptr^.yvim:=y_ptr^.yvarpt^.VVC_TAIL_PT^.valim;
            end
            else begin
              y_ptr^.yvre:=y_ptr^.yvarpt^.VVR_TAIL_PT^.value;
              y_ptr^.yvim:=0.0;
            end;
          end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = VARIABLE ) then begin
            if (g_ptr^.gvarpt^.Var_complex) then begin
              g_ptr^.gvre:=g_ptr^.gvarpt^.VVC_TAIL_PT^.valre;
              g_ptr^.gvim:=g_ptr^.gvarpt^.VVC_TAIL_PT^.valim;
            end
            else begin
              g_ptr^.gvre:=g_ptr^.gvarpt^.VVR_TAIL_PT^.value;
              g_ptr^.gvim:=0.0;
            end;
          end;
       g_ptr:=g_ptr^.gnext;
  end;

  z_ptr:=Z_head;
  while z_ptr<>NIL do
  begin
       if ( z_ptr^.zvar = VARIABLE ) then begin
            if (z_ptr^.zvarpt^.Var_complex) then begin
              z_ptr^.zvre:=z_ptr^.zvarpt^.VVC_TAIL_PT^.valre;
              z_ptr^.zvim:=z_ptr^.zvarpt^.VVC_TAIL_PT^.valim;
            end
            else begin
              z_ptr^.zvre:=z_ptr^.zvarpt^.VVR_TAIL_PT^.value;
              z_ptr^.zvim:=0.0;
            end;
          end;
       z_ptr:=z_ptr^.znext;
  end;


  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = VARIABLE ) then begin
          r_ptr^.rv:=r_ptr^.rvarpt^.VVR_TAIL_PT^.value;
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = VARIABLE ) then begin
          c_ptr^.cv:=c_ptr^.cvarpt^.VVR_TAIL_PT^.value;
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = VARIABLE ) then begin
          l_ptr^.lv:=l_ptr^.lvarpt^.VVR_TAIL_PT^.value;
       end;
       l_ptr:=l_ptr^.lnext;
  end;


END;

{***************************************************************************}
{*******             evaluate cofators for var freq and comp    ************}
{***************************************************************************}

PROCEDURE EVALCOFVARC(job:taskpt);
VAR
 fpt,FREQ_PT_X:listbpt;
 fpoints,apoint:INTEGER;
 fpstr,apstr:STRING;

BEGIN
{* prepare for computings all coffactors                                   *}
{* find number of freq points                                              *}
 fpt:=job^.FREQ_PT;
 fpoints:=0;
 WHILE fpt<>NIL DO
 BEGIN
  fpoints:=fpoints+1;
  fpt:=fpt^.vpt
 END;
 Str(fpoints,fpstr);

{* setup coffactors according to definitions                               *}
{* di is zeroed by PREPARE_JOB                                             *}
{* update coffactors according to definitions  1..di                       *}
 CCP(job);
{* start loop for changing extra components and var freqency               *}
 RESET_TUN_LISTS(job);
 RESET_VAR_LISTS(job);
{* cheat with frequency list                                               *}
{* store true pointer                                                      *}
 FREQ_PT_X:=job^.FREQ_PT;
 fpt:=FREQ_PT_X;
 apoint:=1;
 NEW(job^.FREQ_PT);
 WHILE fpt<>NIL DO
 BEGIN
  job^.FREQ_PT^.value:=fpt^.value;
  job^.FREQ_PT^.vpt:=NIL;
  SET_TUN_VALUES(job);
  SET_VAR_VALUES(job);
  Str(apoint,apstr);
  INFO(CONCAT('CALCULATING COFFACTORS FOR ',apstr,' OF ',fpstr,' DISCRETE FREQUENCY POINTS'));
{* compute coffactors                                                      *}
   EVALCOF(job);
   apoint:=apoint+1;
   UPDATE_TUN_LISTS(job);
   UPDATE_VAR_LISTS(job);
   fpt:=fpt^.vpt;
 END;
{* restore frequency pointer  and number of nodes                          *}
 job^.FREQ_PT:=FREQ_PT_X;

END;





{***************************************************************************}
{*******             evaluate equation Im[TF(e)]=0              ************}
{***************************************************************************}
{* result is stored in eZN_PT list                                         *}
{* result eps is stored as modyficantion of start point estimation         *}
{* ReTF & ImTF are stored in NS_PT list                                    *}
{* RE[S[TF]], IM[S[TF]] are stored for succesive sensors in SS_PT          *}
{* temporary storage of sensitivities results in SV_PT^ list               *}
{***************************************************************************}


PROCEDURE EVALNEWTON(j:taskpt);
VAR

 nnx:INTEGER;
 itr:INTEGER;
 PASS:BOOLEAN;
 MESSAGESTR:STRING;
 n_itrstr:STRING;
 d_ptr:dptr;
 eypt:drpt;

 f_ptr,trim_ptr:listbpt;
 FREQ_PT_X:listbpt;
 TRIM_HEAD_PT_X:listbpt;
 tuned_pt:tunpt;
 TFRE,TFIM,epsi,epsj,STFRE,STFIM,dRETF,dIMTF,AuxRE,AuxIM:DOUBLE;
 fpoints,apoint:INTEGER;
 fpstr,apstr:STRING;
 Ysgen_TAIL_PT:listcpt;

 y_ptr:yptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN
{* find number of freq points                                              *}
 f_ptr:=j^.FREQ_PT;
 fpoints:=0;
 WHILE f_ptr<>NIL DO
 BEGIN
  fpoints:=fpoints+1;
  f_ptr:=f_ptr^.vpt
 END;
 Str(fpoints,fpstr);
 apoint:=1;
 eYn_PT:=NIL;
 NS_PT:=NIL;
 SS_PT:=NIL;
{* setup coffactors according to definitions                               *}
 CCP(j);
{ complex admittance list used by sensitivity routines of tuned components  - only one element needed }
Ysgen_HEAD_PT:=NIL;
ADD2CPLX_LIST(Ysgen_HEAD_PT, Ysgen_TAIL_PT, 0.0, 0.0);
{* start loop for changing extra components and var freqency               *}
{* cheat with frequency list                                               *}
 FREQ_PT_X:=j^.FREQ_PT;
 f_ptr:=j^.FREQ_PT;
 j^.FREQ_PT:=NIL;
 NEW(j^.FREQ_PT);
{* cheat with control   list                                               *}
 TRIM_HEAD_PT_X:=j^.TRIM_PT^.TRIM_HEAD_PT;
 { !!! THIS IS LOUSY - who said that there will be only one para            }
 trim_ptr:=j^.TRIM_PT^.TRIM_HEAD_PT;
 j^.TRIM_PT^.TRIM_HEAD_PT:=NIL;
 NEW(j^.TRIM_PT^.TRIM_HEAD_PT);
{ TAIL_PT = HEAD_PT }
 RESET_VAR_LISTS(j);

 IF trace THEN WRITELN(RESULTS,asterix,' NEWTONs ',asterix);
{* pointer to results                                                      *}
 PROBABLE:=TRUE;
 WHILE f_ptr<>NIL DO
 BEGIN
 {* only one frequency - like in EVALCOFVARC                                *}
  j^.FREQ_PT^.value:=f_ptr^.value;
  j^.FREQ_PT^.vpt:=NIL;
  IF trace THEN WRITELN(RESULTS,'FREQUENCY=',j^.FREQ_PT^.value);
{* add var  components - once per frequency step                           *}
{ assign VALUES referenced by TAIL_PT                                              }
  SET_VAR_VALUES(j);

  d_ptr:=j^.COFF_PT;
  WHILE d_ptr<>NIL DO
  BEGIN
   d_ptr^.CF_PT:=NIL;
   d_ptr:=d_ptr^.dnext
  END;
  itr:=1;

  Str(apoint,apstr);

{* set control value according initial estimation                          *}
  j^.TRIM_PT^.TRIM_HEAD_PT^.value:=trim_ptr^.value;
  j^.TRIM_PT^.TRIM_HEAD_PT^.vpt:=NIL;
  REPEAT
  BEGIN
    epsi:=j^.TRIM_PT^.TRIM_HEAD_PT^.value;
    SET_TUNED_VALUES(j);  { assign values from para to tuned                }
    RESET_TUN_LISTS(j);   { TAIL_PT = HEAD_PT }
    SET_TUN_VALUES(j);    { assign VALUES referenced by TAIL_PT             }

    EVALCOF(j);
{ Newton                                                                   }
{ ej=ei-Im(TF(ei))/(d[Im(TF(e)]/d[e]|e=ei)                                 }
{     TFIM=Im(TF(ei))                                                      }
{     dIMTF=(d[Im(TF(e)]/d[e]|e=ei)                                        }
{     dIMTF=SUM Im( TF(e)*STF[Y(e)]*(1/Y(e))*d[Y(e)]/d[e] )                }

   d_ptr:=j^.COFF_PT;
   COMPUTE_TF_VALUE (j^.FREQ_PT,d_ptr,NIL);
   TFRE:=TFri_PT^.red;
   TFIM:=TFri_PT^.imd;
   dRETF:=0.0;
   dIMTF:=0.0;
   d_ptr:=j^.COFF_PT^.dnext^.dnext;

  { the condition should look like this
          if (( yvar=TUN ) and (ytunpt^.tunpara=eps_symb)) then begin
   but this algorithm should work well when there are no other PARAs
   ... }

    y_ptr:=Y_head;
    WHILE y_ptr<>NIL DO
    BEGIN
    WITH y_ptr^ DO
      if ( yvar=TUNED ) then begin
        CALC_Ysens_Y(y_ptr, j^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(j^.FREQ_PT,yname,FALSE,Ysgen_HEAD_PT,j^.COFF_PT,d_ptr);
        STFRE:=SrSi_PT^.red;
        STFIM:=SrSi_PT^.imd;
        AuxRE:=STFRE*TFRE-STFIM*TFIM;
        AuxIM:=STFIM*TFRE+STFRE*TFIM;
        dRETF:=dRETF+(AuxRE*(ytunpt^.tunvar)/((ytunpt^.tunconst)+epsi*(ytunpt^.tunvar)));
        dIMTF:=dIMTF+(AuxIM*(ytunpt^.tunvar)/((ytunpt^.tunconst)+epsi*(ytunpt^.tunvar)));
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
    y_ptr:=y_ptr^.ynext
    END;

    g_ptr:=G_head;
    WHILE g_ptr<>NIL DO
    BEGIN
    WITH g_ptr^ DO
      if ( gvar=TUNED ) then begin
        CALC_Ysens_G(g_ptr, j^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(j^.FREQ_PT,gname,FALSE,Ysgen_HEAD_PT,j^.COFF_PT,d_ptr);
        STFRE:=SrSi_PT^.red;
        STFIM:=SrSi_PT^.imd;
        AuxRE:=STFRE*TFRE-STFIM*TFIM;
        AuxIM:=STFIM*TFRE+STFRE*TFIM;
        dRETF:=dRETF+(AuxRE*(gtunpt^.tunvar)/((gtunpt^.tunconst)+epsi*(gtunpt^.tunvar)));
        dIMTF:=dIMTF+(AuxIM*(gtunpt^.tunvar)/((gtunpt^.tunconst)+epsi*(gtunpt^.tunvar)));
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      g_ptr:=g_ptr^.gnext
    END;

    r_ptr:=R_head;
    WHILE r_ptr<>NIL DO
    BEGIN
    WITH r_ptr^ DO
      if ( rvar=TUNED ) then begin
        CALC_Ysens_R(r_ptr, j^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(j^.FREQ_PT,rname,FALSE,Ysgen_HEAD_PT,j^.COFF_PT,d_ptr);
        STFRE:=SrSi_PT^.red;
        STFIM:=SrSi_PT^.imd;
        AuxRE:=STFRE*TFRE-STFIM*TFIM;
        AuxIM:=STFIM*TFRE+STFRE*TFIM;
        dRETF:=dRETF+(AuxRE*(rtunpt^.tunvar)/((rtunpt^.tunconst)+epsi*(rtunpt^.tunvar)));
        dIMTF:=dIMTF+(AuxIM*(rtunpt^.tunvar)/((rtunpt^.tunconst)+epsi*(rtunpt^.tunvar)));
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
    r_ptr:=r_ptr^.rnext
    END;

    c_ptr:=C_head;
    WHILE c_ptr<>NIL DO
    BEGIN
    WITH c_ptr^ DO
      if ( cvar=TUNED ) then begin
        CALC_Ysens_C(c_ptr, j^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(j^.FREQ_PT,cname,FALSE,Ysgen_HEAD_PT,j^.COFF_PT,d_ptr);
        STFRE:=SrSi_PT^.red;
        STFIM:=SrSi_PT^.imd;
        AuxRE:=STFRE*TFRE-STFIM*TFIM;
        AuxIM:=STFIM*TFRE+STFRE*TFIM;
        dRETF:=dRETF+(AuxRE*(ctunpt^.tunvar)/((ctunpt^.tunconst)+epsi*(ctunpt^.tunvar)));
        dIMTF:=dIMTF+(AuxIM*(ctunpt^.tunvar)/((ctunpt^.tunconst)+epsi*(ctunpt^.tunvar)));
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
    c_ptr:=c_ptr^.cnext
    END;

    l_ptr:=L_head;
    WHILE l_ptr<>NIL DO
    BEGIN
    WITH l_ptr^ DO
      if ( lvar=TUNED ) then begin
        CALC_Ysens_L(l_ptr, j^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(j^.FREQ_PT,lname,FALSE,Ysgen_HEAD_PT,j^.COFF_PT,d_ptr);
        STFRE:=SrSi_PT^.red;
        STFIM:=SrSi_PT^.imd;
        AuxRE:=STFRE*TFRE-STFIM*TFIM;
        AuxIM:=STFIM*TFRE+STFRE*TFIM;
        dRETF:=dRETF+(AuxRE*(ltunpt^.tunvar)/((ltunpt^.tunconst)+epsi*(ltunpt^.tunvar)));
        dIMTF:=dIMTF+(AuxIM*(ltunpt^.tunvar)/((ltunpt^.tunconst)+epsi*(ltunpt^.tunvar)));
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      l_ptr:=l_ptr^.lnext
  END;


   epsj:=epsi-TFIM/dIMTF;

   d_ptr:=j^.COFF_PT;
   WHILE d_ptr<>NIL DO
   BEGIN
    d_ptr^.CF_PT:=NIL;
    d_ptr:=d_ptr^.dnext
   END;

{* TEST epsi                                                              *}
   IF (ABS(TFIM)<accuracy*ABS(TFRE)) AND (itr > 1) OR (itr>itrmax) THEN
   BEGIN
{* epsi is accepted                                                       *}
    PASS:=TRUE;
{ but this might be forced by overflow of iteration counter                }
    IF (itr>itrmax) AND (ABS(TFIM)>accuracy*ABS(TFRE)) THEN PROBABLE:=FALSE;
{* store transfer function and sensitivties of the the solutinon          *}
{* eYN_PT stores value of eps and -RETF                                   *}
{* result eps is stored as modificantion of start point estimation        *}
{* ReTF & ImTF are stored in NS_PT list                                   *}
    ADD2COFF_LIST(eYn_PT,eypt,epsi,-1/TFRE);
    ADD2COFF_LIST(NS_PT,TFri_pt,TFRE,TFIM);
{ trim_pt references to original list - so this is original list is modification  }
     trim_ptr^.value:=epsi;
   END
   ELSE
   BEGIN
    j^.TRIM_PT^.TRIM_HEAD_PT^.value:=epsj;
    PASS:=FALSE
   END;
   Str(itr,n_itrstr);
   IF PASS THEN
    MESSAGESTR:=CONCAT('GS-FREQ#:',apstr,' OF ',fpstr,' -ITERATION #:',n_itrstr,'- PASS')
   ELSE
    MESSAGESTR:=CONCAT('GS-FREQ#:',apstr,' OF ',fpstr,' -ITERATION #:',n_itrstr,'- FAIL');
   INFO(MESSAGESTR);
   IF trace THEN
   BEGIN
    WRITELN(RESULTS,'#:',itr, 'PASSED:',PASS);
    WRITELN(RESULTS,'    ei=',epsi,'      ej=',epsj);
    WRITELN(RESULTS,'Re(TF)=',TFRE,'  Im(TF)=',TFIM);
   END;
   itr:=itr+1;

  END
  UNTIL ((PASS));

  apoint:=apoint+1;
  { ADVANCE TAIL_PT  }
  UPDATE_VAR_LISTS(j);
  f_ptr:=f_ptr^.vpt;
  trim_ptr:=trim_ptr^.vpt

 END;

 j^.FREQ_PT:=FREQ_PT_X;
 j^.TRIM_PT^.TRIM_HEAD_PT:=TRIM_HEAD_PT_X;


END;


END.
