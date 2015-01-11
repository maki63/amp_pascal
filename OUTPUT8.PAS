UNIT OUTPUT8;
interface
USES
 SysUtils,
 TYPE8,VAREXT8,VAR8,TASK8,COMP8,DATAIO8,MCAD8;

PROCEDURE WRITE_RESULTS(job:taskpt);
PROCEDURE WRITE_TF(job:taskpt);
PROCEDURE WRITE_TF_SENS(job:taskpt);

PROCEDURE WRITE_RCONV(job:taskpt);
PROCEDURE WRITE_RCONV_SENS(job:taskpt);
PROCEDURE WRITE_RCONV_DISTO(job:taskpt);

PROCEDURE WRITE_SCONV(job:taskpt);
PROCEDURE WRITE_SCONV_SENS(job:taskpt);
PROCEDURE WRITE_SCONV_DISTO(job:taskpt);

implementation
USES Amp8_main;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE WRITE_RESULTS(job:taskpt);
 VAR
  fpt:listbpt;
  d_ptr:dptr;
  crpt:drpt;

 BEGIN
  INFO('WRITING RESULTS');
  WRITELN(RESULTS,asterix,version,asterix);
  WRITELN(RESULTS,'RESULTS OF TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor, ' ', job^.task_name);

  d_ptr:=job^.COFF_PT;
  WHILE d_ptr<>NIL DO
  BEGIN
   d_ptr^.drfpt:=d_ptr^.CF_PT;
   d_ptr:=d_ptr^.dnext
  END;

   d_ptr:=job^.COFF_PT;
   WHILE d_ptr<>NIL DO
   BEGIN
    WRITELN(RESULTS,d_ptr^.dname,'-COUNTABLE=',d_ptr^.ctb);
    d_ptr:=d_ptr^.dnext
   END;

  fpt:=job^.FREQ_PT;
  WHILE fpt<>NIL DO
  BEGIN
   WRITELN(RESULTS,'FREQENCY=',fpt^.value,'     ','OMEGA=',2*Pi*fpt^.value);
   d_ptr:=job^.COFF_PT;
   WHILE d_ptr<>NIL DO
   BEGIN
    crpt:=d_ptr^.drfpt;
    WRITELN(RESULTS,d_ptr^.dname,'=(',crpt^.red,')+i(',crpt^.imd,')');
    d_ptr^.drfpt:=d_ptr^.drfpt^.drptn;
    d_ptr:=d_ptr^.dnext
   END;
   fpt:=fpt^.vpt
  END;
  d_ptr:=job^.COFF_PT;
  WHILE d_ptr<>NIL DO
  BEGIN
   d_ptr^.drfpt:=d_ptr^.CF_PT;
   d_ptr:=d_ptr^.dnext
  END;
  WRITELN(RESULTS,asterix,version,asterix);
 END;

 {***************************************************************************}
 {***************************************************************************}
 {***************************************************************************}

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}


PROCEDURE WRITE_TF_VALUE (fpt:listbpt;TFMF_PT,TFRI_PT:drpt);
VAR
smf,sri:drpt;
BEGIN
 smf:=TFMF_PT;
 sri:=TFRI_PT;
 WHILE fpt<>NIL DO
 BEGIN

 if ( TF_name='' ) then
    WRITELN(RESULTS,'FREQUENCY=',fpt^.value:16,'     ','  OMEGA=',2*Pi*fpt^.value:16)
 else
   WRITELN(RESULTS,'TF=',TF_name,'  FREQ=',fpt^.value:16,'     ','  OMEGA=',2*Pi*fpt^.value:16);

 if ( format_dB_flag ) then begin
  if ( smf^.red <>0.0 ) then begin
    WRITELN(RESULTS,'     TFdB=',(20.0*ln(smf^.red)/ln(10.0)):16:5  ,'     ','deg(TF)=',smf^.imd:16:5);
  end
  else begin
    WRITELN(RESULTS,'     TFdB=-INF (|TF|=0.0)');
  end;
 end;

 if ( format_MP_flag ) then begin
  WRITELN(RESULTS,'     |TF|=',smf^.red:16:8      ,'     ','deg(TF)=',smf^.imd:16:5);
 end;

 if ( format_RI_flag ) then begin
  WRITELN(RESULTS,'   Re(TF)=',sri^.red:16      ,'     ',' Im(TF)=',sri^.imd:16);
 end;


  fpt:=fpt^.vpt;
  smf:=smf^.drptn;
  sri:=sri^.drptn;
 END


END;

{***************************************************************************}

PROCEDURE WRITE_TF(job:taskpt);
VAR
 fpt:listbpt;
 DLptr:dptr;
BEGIN
 INFO('WRITING TRANSFER FUNCTION RESULTS');
 WRITELN(RESULTS,asterix,version,asterix);


 if (job^.PAR_PT = nil) then begin
  WRITELN(RESULTS,'RESULTS OF TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor , ' ', job^.task_name);
 end
 else begin
  WRITELN(RESULTS,'RESULTS OF TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor , ' ', job^.task_name,'  FOR PAR:');
  LIST_PAR_COMP(job);
 end;

 DLptr:=job^.COFF_PT;
 fpt:=job^.FREQ_PT;
 COMPUTE_TF_VALUE(fpt,DLptr,Y0_PT);
 WRITE_TF_VALUE(fpt,TFmp_PT,TFri_PT);
END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_TF_SENS_VAL (fpt:listbpt;name:symb;SENS_PT:drpt);

VAR
 s:drpt;
 freq:DOUBLE;

BEGIN

 WRITELN(RESULTS,'TF SENS OF [',name,']');
 s:=SENS_PT;
 WHILE fpt<>NIL DO
 BEGIN
  freq:=fpt^.value;
  WRITELN(RESULTS,'F=',freq:16,'     ','RE[S]=',s^.red:16,'  ','IM[S]=',s^.imd:16);
  fpt:=fpt^.vpt;
  s:=s^.drptn;
 END
END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_TF_SENS(job:taskpt);
VAR

 f_ptr :listbpt;
 d_ptr:dptr;
 y_ptr:yptr;
 r_ptr:rptr;
 z_ptr:zptr;
 g_ptr:gptr;
 c_ptr:cptr;
 l_ptr:lptr;


 Ysens_TAIL_PT:listcpt;
 YisLOAD:BOOLEAN;
BEGIN
 INFO('WRITING TRANSFER FUNCTION SENSITIVITIES');
 WRITELN(RESULTS,asterix,version,asterix);

{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
 f_ptr:=job^.FREQ_PT;
 Ysens_HEAD_PT:=NIL;
 while ( f_ptr<>NIL ) do begin
     ADD2CPLX_LIST(Ysens_HEAD_PT, Ysens_TAIL_PT, 0.0, 0.0);
     f_ptr:=f_ptr^.vpt;
 end;


{* freq pointers are reseted in suporting procedures                      *}
{* The coffactor list starts from DL and DN                               *}

 d_ptr:=job^.COFF_PT^.dnext^.dnext;

{The coffactor order is: Y,G,Z,R,C,L}
{* for each component                                                    *}
 y_ptr:=Y_head;
 WHILE (y_ptr<>NIL) DO
 BEGIN
   WITH(y_ptr^) DO
   BEGIN
      if ( yvar<>GEN ) then begin
        CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
        IF (y_ptr=Y0_PT) THEN YisLOAD:=TRUE ELSE YisLOAD:=FALSE;
        COMPUTE_SENS_VAL(job^.FREQ_PT,yname,YisLOAD,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
        WRITE_TF_SENS_VAL(job^.FREQ_PT,yname,SrSi_PT);
        d_ptr:=d_ptr^.dnext^.dnext
      end;
  END;
  y_ptr:=y_ptr^.ynext
 END;

 g_ptr:=G_head;
 WHILE (g_ptr<>NIL) DO
 BEGIN
   WITH(g_ptr^) DO
   BEGIN
    if ( gvar<>GEN ) then begin
      CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      WRITE_TF_SENS_VAL(job^.FREQ_PT,gname,SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  g_ptr:=g_ptr^.gnext
 END;

 z_ptr:=Z_head;
 WHILE (z_ptr<>NIL) DO
 BEGIN
   WITH(z_ptr^) DO
   BEGIN
      CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      WRITE_TF_SENS_VAL(job^.FREQ_PT,zname,SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
  END;
  z_ptr:=z_ptr^.znext
 END;

 r_ptr:=R_head;
 WHILE r_ptr<>NIL DO
 BEGIN
  WITH r_ptr^ DO
  BEGIN
   if ( rvar<>GEN ) then begin
      CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      WRITE_TF_SENS_VAL(job^.FREQ_PT,rname,SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  r_ptr:=r_ptr^.rnext
 END;

 c_ptr:=C_head;
 WHILE c_ptr<>NIL DO
 BEGIN
  WITH c_ptr^ DO
  BEGIN
      CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      WRITE_TF_SENS_VAL(job^.FREQ_PT,cname,SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    END;
    c_ptr:=c_ptr^.cnext
 END;

 l_ptr:=L_head;
 WHILE l_ptr<>NIL DO
 BEGIN
  WITH l_ptr^ DO
  BEGIN
        CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
        COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
        WRITE_TF_SENS_VAL(job^.FREQ_PT,lname,SrSi_PT);
        d_ptr:=d_ptr^.dnext^.dnext
      END;
    l_ptr:=l_ptr^.lnext
 END;

 WRITELN(RESULTS,asterix,version,asterix);
END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_RCONV(job:taskpt);
VAR
 spt:drpt;
 fpt:listbpt;
 BEGIN

  INFO('WRITING RESULTS OF RCONV ANALYSIS');
  WRITELN(RESULTS,asterix,version,asterix);
  WRITELN(RESULTS,'TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor, ' ', job^.task_name);
  WRITELN(RESULTS,'SOLUTION IS PROBABLE - ',probable);
  fpt:=job^.FREQ_PT;
  spt:=YxYn_PT;
  WHILE fpt<>NIL DO
  BEGIN
   WRITELN(RESULTS,'FREQUENCY=',fpt^.value:16,'     ','OMEGA=',2*Pi*fpt^.value:16);
   IF invertrx THEN
    WRITE(RESULTS,Yx_symb,'=',(1/(spt^.red)):16,'     ')
   ELSE
    WRITE(RESULTS,Yx_symb,'=',spt^.red:16,'     ');
   IF invertrn THEN
    WRITELN(RESULTS,Yn_symb,'=',(1/(spt^.imd)):16)
   ELSE
    WRITELN(RESULTS,Yn_symb,'=',spt^.imd:16);
   fpt:=fpt^.vpt;
   spt:=spt^.drptn;
  END
 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_RCONV_SENS_VAL (fpt:listbpt;name:symb;SCOMP_PT,SREF_PT:drpt);

VAR
 s,sr:drpt;
 freq:DOUBLE;
BEGIN

 WRITELN(RESULTS,Yx_symb,' SENS OF [',name,']');
 s:=SCOMP_PT;
 sr:=SREF_PT;
 WHILE fpt<>NIL DO
 BEGIN
  freq:=fpt^.value;
  WRITELN(RESULTS,'F=',freq:16,'     ','S=',-(s^.imd)/(sr^.imd):16);
  fpt:=fpt^.vpt;
  s:=s^.drptn;
  sr:=sr^.drptn;
 END
END;

{***************************************************************************}
PROCEDURE WRITE_RCONV_SENS(job:taskpt);
VAR
 f_ptr:listbpt;
 d_ptr:dptr;
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 z_ptr:zptr;
 c_ptr:cptr;
 l_ptr:lptr;
 Ysens_TAIL_PT:listcpt;{list of complex values transfered to COMPUTE_SENS_VAL}

BEGIN
 INFO('WRITING GENERATOR GR SENSITIVITIES');
 WRITELN(RESULTS,asterix,version,asterix);


{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
 f_ptr:=job^.FREQ_PT;
 Ysens_HEAD_PT:=NIL;
 while ( f_ptr<>NIL ) do begin
     ADD2CPLX_LIST(Ysens_HEAD_PT, Ysens_TAIL_PT, 0.0, 0.0);
     f_ptr:=f_ptr^.vpt;
 end;

{* The coffactor list starts from DL and DN                               *}

 d_ptr:=job^.COFF_PT^.dnext^.dnext;

{  The position of Yx coffactors is unkown                                }
{  The coffactor order is: Y,G,Z,R,C,L                                    }

 case ( Yx_symb[1] ) of
  'y','Y':  begin
              y_ptr:=Y_head;
              while ( y_ptr<>NIL ) do begin
                if ( y_ptr^.yvar<>GEN ) then begin
                  if (( y_ptr^.yvar=VARIABLE ) and (y_ptr^.yref=Yx_symb)) then begin
                    CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
                    COMPUTE_SENS_VAL(job^.FREQ_PT,y_ptr^.yname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
                    SxrSxi_PT:=SrSi_PT;
                  end;
                  d_ptr:=d_ptr^.dnext^.dnext;
                end;
                y_ptr:=y_ptr^.ynext;
             end;
            end;
  'g','G':  begin
              y_ptr:=Y_head;
              while ( y_ptr<>NIL ) do begin
                if ( y_ptr^.yvar<>GEN ) then begin
                  d_ptr:=d_ptr^.dnext^.dnext;
                end;
                y_ptr:=y_ptr^.ynext;
              end;
              g_ptr:=G_head;
              while ( g_ptr<>NIL ) do begin
                if ( g_ptr^.gvar<>GEN ) then begin
                  if (( g_ptr^.gvar=VARIABLE ) and (g_ptr^.gref=Yx_symb)) then begin
                    CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
                    COMPUTE_SENS_VAL(job^.FREQ_PT,g_ptr^.gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
                    SxrSxi_PT:=SrSi_PT;
                  end;
                  d_ptr:=d_ptr^.dnext^.dnext;
                end;
                g_ptr:=g_ptr^.gnext;
              end;
            end;

  'r','R':  begin
                  y_ptr:=Y_head;
                  while ( y_ptr<>NIL ) do begin
                     if ( y_ptr^.yvar<>GEN ) then begin
                      d_ptr:=d_ptr^.dnext^.dnext;
                     end;
                     y_ptr:=y_ptr^.ynext;
                  end;
                  g_ptr:=G_head;
                  while ( g_ptr<>NIL ) do begin
                     if ( g_ptr^.gvar<>GEN ) then begin
                      d_ptr:=d_ptr^.dnext^.dnext;
                     end;
                     g_ptr:=g_ptr^.gnext;
                  end;

                  z_ptr:=Z_head;
                  while ( z_ptr<>NIL ) do begin
                     d_ptr:=d_ptr^.dnext^.dnext;
                     z_ptr:=z_ptr^.znext;
                  end;

                  r_ptr:=R_head;
                  while ( r_ptr<>NIL ) do begin
                     if ( r_ptr^.rvar<>GEN ) then begin
                      if ((r_ptr^.rvar=VARIABLE) and (r_ptr^.rref=Yx_symb)) then begin
                        CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
                        COMPUTE_SENS_VAL(job^.FREQ_PT,g_ptr^.gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
                        SxrSxi_PT:=SrSi_PT;
                      end;
                      d_ptr:=d_ptr^.dnext^.dnext;
                     end;
                     r_ptr:=r_ptr^.rnext;
                  end;

            end;
 end;

{* The coffactor list starts from DL and DN                               *}


 d_ptr:=job^.COFF_PT^.dnext^.dnext;

{The coffactor order is: Y,G,Z,R,C,L}
{* for each component                                                    *}
 y_ptr:=Y_head;
 WHILE (y_ptr<>NIL) DO
 BEGIN
   WITH(y_ptr^) DO
   BEGIN
      if ( yvar<>GEN ) then begin
        if (not(( y_ptr^.yvar=VARIABLE ) and (y_ptr^.yref=Yx_symb))) then begin
          CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,yname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_RCONV_SENS_VAL(job^.FREQ_PT,yname,SrSi_PT,SxrSxi_PT);
        end;
        d_ptr:=d_ptr^.dnext^.dnext
      end;
  END;
  y_ptr:=y_ptr^.ynext
 END;


 g_ptr:=G_head;
 WHILE (g_ptr<>NIL) DO
 BEGIN
   WITH(g_ptr^) DO
   BEGIN
      if ( gvar<>GEN ) then begin
        if (not(( g_ptr^.gvar=VARIABLE ) and (g_ptr^.gref=Yx_symb))) then begin
          CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_RCONV_SENS_VAL(job^.FREQ_PT,gname,SrSi_PT,SxrSxi_PT);
        end;
        d_ptr:=d_ptr^.dnext^.dnext
      end;
  END;
  g_ptr:=g_ptr^.gnext
 END;

 z_ptr:=Z_head;
 WHILE (z_ptr<>NIL) DO
 BEGIN
   WITH(z_ptr^) DO
   BEGIN
        if (not(( z_ptr^.zvar=VARIABLE ) and (z_ptr^.zref=Yx_symb))) then begin
          CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_RCONV_SENS_VAL(job^.FREQ_PT,zname,SrSi_PT,SxrSxi_PT);
        end;
        d_ptr:=d_ptr^.dnext^.dnext
  END;
  z_ptr:=z_ptr^.znext
 END;


 r_ptr:=R_head;
 WHILE r_ptr<>NIL DO
 BEGIN
    WITH r_ptr^ DO
    BEGIN
      if ( rvar<>GEN ) then begin
        if (not(( r_ptr^.rvar=VARIABLE ) and (r_ptr^.rref=Yx_symb))) then begin
          CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_RCONV_SENS_VAL(job^.FREQ_PT,rname,SrSi_PT,SxrSxi_PT);
        end;
        d_ptr:=d_ptr^.dnext^.dnext
      end;
    END;
    r_ptr:=r_ptr^.rnext
 END;

 c_ptr:=C_head;
 WHILE c_ptr<>NIL DO
 BEGIN
  WITH c_ptr^ DO
  BEGIN
    CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
    COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
    WRITE_RCONV_SENS_VAL(job^.FREQ_PT,cname,SrSi_PT,SxrSxi_PT);
    d_ptr:=d_ptr^.dnext^.dnext
  END;
  c_ptr:=c_ptr^.cnext
 END;

 l_ptr:=L_head;
 WHILE l_ptr<>NIL DO
 BEGIN
  WITH l_ptr^ DO
  BEGIN
    CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
    COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
    WRITE_RCONV_SENS_VAL(job^.FREQ_PT,lname,SrSi_PT,SxrSxi_PT);
    d_ptr:=d_ptr^.dnext^.dnext
  END;
  l_ptr:=l_ptr^.lnext
 END;

 WRITELN(RESULTS,asterix,version,asterix);
END;



{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_RCONV_DISTO(job:taskpt);

{***************************************************************************}

PROCEDURE COMPUTE_FIRST_PASS(j:taskpt);
VAR
 f_ptr:listbpt;
 Ysens_TAIL_PT:listcpt;{list of complex values transfered to COMPUTE_SENS_VAL}
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 d_ptr:dptr;
BEGIN
  INFO('COMPUTING RESULTS OF RCONV DISTO - FIRST PASS');
  FB_PT:=j^.FREQ_PT;
  COMPUTE_TF_VALUE (FB_PT,j^.COFF_PT,NIL);
  ZM_PT:=TFri_PT;

{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
  f_ptr:=job^.FREQ_PT;
  Ysens_HEAD_PT:=NIL;
  while ( f_ptr<>NIL ) do begin
     ADD2CPLX_LIST(Ysens_HEAD_PT, Ysens_TAIL_PT, 0.0, 0.0);
     f_ptr:=f_ptr^.vpt;
  end;
{ Sensitivity coffactors should be after DL,DM }
  d_ptr:=job^.COFF_PT^.dnext^.dnext;
  case ( Yx_symb[1] ) of
  'y','Y':  begin
              y_ptr:= Yx_ptr;
              CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
              COMPUTE_SENS_VAL(job^.FREQ_PT,y_ptr^.yname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
            end;
  'r','R':  begin
              r_ptr:= Rx_ptr;
              CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
              COMPUTE_SENS_VAL(job^.FREQ_PT,r_ptr^.rname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
            end;
  'g','G':  begin
              g_ptr:=Gx_ptr;
              CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
              COMPUTE_SENS_VAL(job^.FREQ_PT,g_ptr^.gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
            end;
  end;
 SxrSxi_PT:=SrSi_PT;
END;



PROCEDURE COMPUTE_SECOND_PASS(j:taskpt);
BEGIN
 INFO('COMPUTING RESULTS OF RCONV DISTO - SECOND PASS');
 COMPUTE_TF_VALUE (j^.FREQ_PT,j^.COFF_PT,NIL);
END;

{***************************************************************************}

PROCEDURE COMPUTE_THIRD_PASS(j:taskpt);
BEGIN
 INFO('COMPUTING RESULTS OF RCONV DISTO - THIRD PASS');
 COMPUTE_TF_VALUE (j^.FREQ_PT,j^.COFF_PT,NIL);
END;

{***************************************************************************}

PROCEDURE COMPUTE_DISTO(j:taskpt);
VAR
 h:INTEGER;
 fbptr:listbpt;
 zptr,zhptr,sptr,mhptr:drpt;
 ahptr:listbpt;
 DENOM,NOM,AH:DOUBLE;
BEGIN
 fbptr:=FB_PT;
 zptr:=ZM_PT;
 sptr:=SxrSxi_PT;
 zhptr:=ZMh_PT;
 mhptr:=VIh_PT;
 AH_PT:=NIL;
 WHILE fbptr<>NIL DO
 BEGIN
  {* compute denominator  DENOM:=Z*S[Z/Yx]/|M(Omega)|^2                  *}
  DENOM:=(zptr^.red)*(sptr^.imd)/((mhptr^.red)*(mhptr^.red));
  FOR h:=2 TO harmonics DO
  BEGIN
  {* skip base freqeuncy results                                          *}
   zhptr:=zhptr^.drptn;
   mhptr:=mhptr^.drptn;
   {* compute harmon coefficient h*Im[Z(jkOmega)]/|M(k*Omega)|^2/DENOM    *}
   NOM:=(zhptr^.imd)/((mhptr^.red)*(mhptr^.red));
   Ah:=-h*NOM/DENOM;
   ADD2REAL_LIST(AH_PT,ahptr,Ah);
  END;
  mhptr:=mhptr^.drptn;
  zptr:=zptr^.drptn;
  zhptr:=zhptr^.drptn;
  sptr:=sptr^.drptn;
  fbptr:=fbptr^.vpt
 END
END;

{***************************************************************************}

PROCEDURE WRITE_DISTO_VAL(j:taskpt);
VAR
 fptr,ahptr:listbpt;
 Yxptr:drpt;
 h:INTEGER;
BEGIN
 fptr:=FB_PT;
 Yxptr:=YxYn_PT;
 WRITELN(RESULTS,asterix,version,asterix);
 WRITELN(RESULTS,'GENERATIVE CONVERTER DISTORTION ANALYSIS RESULTS');
 WRITELN(RESULTS,'dYx/Yx=SUM(AH*hu^2)');

 WHILE fptr<>NIL DO
 BEGIN
  WRITELN(RESULTS,'FREQUENCY=',fptr^.value:16,'   Yx=',Yxptr^.red:16);
  FOR h:=2 TO harmonics DO
  BEGIN
   IF (fptr=FB_PT) AND (h=2) THEN ahptr:=AH_PT ELSE ahptr:=ahptr^.vpt;
   WRITELN(RESULTS,'h=',h:2,'         AH=',ahptr^.value:16)
  END;
  fptr:=fptr^.vpt;
  Yxptr:=Yxptr^.drptn
 END;
 WRITELN(RESULTS,asterix,version,asterix);
END;

{***************************************************************************}

BEGIN
 CASE disto_pass OF
 3:BEGIN
    COMPUTE_FIRST_PASS(job);
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - FIRST PASS');
     WRITE_TF_VALUE (FB_PT,TFmp_PT,ZM_PT);
     OUT_FLUSH;
     WRITE_TF_SENS_VAL (FB_PT,job^.VAR_PT^.varname,SxrSxi_PT);
     OUT_FLUSH;
    END;
    disto_pass:=2
   END;
 2:BEGIN
    COMPUTE_SECOND_PASS(job);
    ZMh_PT:=TFri_PT;
    FH_PT:=job^.FREQ_PT;
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - SECOND PASS');
     OUT_FLUSH;
     WRITE_TF_VALUE (FH_PT,TFmp_PT,ZMh_PT);
     OUT_FLUSH;
    END;
    disto_pass:=1
   END;
 1:BEGIN
    COMPUTE_THIRD_PASS(job);
    VIh_PT:=TFmp_PT;
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - THIRD PASS');
     OUT_FLUSH;
     WRITE_TF_VALUE (FH_PT,VIh_PT,TFri_PT);
     OUT_FLUSH;
    END;
    OUT_FLUSH;
    COMPUTE_DISTO(job);
    OUT_FLUSH;
    WRITE_DISTO_VAL(job);
    OUT_FLUSH;
    IF mcad THEN
     MCAD_RCONV_DISTO_VAL(job);
    disto_pass:=0
   END
  END
 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_SCONV(job:taskpt);
VAR
 spt:drpt;
 fpt:listbpt;
 BEGIN

  INFO('WRITING RESULTS OF SCONV ANALYSIS');
  WRITELN(RESULTS,asterix,version,asterix);
  WRITELN(RESULTS,'TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor, ' ', job^.task_name);
  WRITELN(RESULTS,'SOLUTION IS PROBABLE - ',probable);
  fpt:=job^.FREQ_PT;
  spt:=eYN_PT;
  WHILE fpt<>NIL DO
  BEGIN
   WRITELN(RESULTS,'FREQUENCY=',fpt^.value:16,'     ','OMEGA=',2*Pi*fpt^.value:16);
   WRITE(RESULTS,job^.TRIM_PT^.trimname,'=',spt^.red:16,'     ');
   IF invertrn THEN
    WRITELN(RESULTS,Yn_symb,'=',(1/(spt^.imd)):16)
   ELSE
    WRITELN(RESULTS,Yn_symb,'=',spt^.imd:16);
   fpt:=fpt^.vpt;
   spt:=spt^.drptn;
  END
 END;



{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_SCONV_SENS_VAL(j:taskpt;compname:symb;SCOMP_PT,SREF_PT:drpt);

VAR
 fpt:listbpt;
 s,sr:drpt;
 freq:DOUBLE;
BEGIN

 WRITELN(RESULTS,j^.TRIM_PT^.trimname,' SENS OF [',compname,']');
 s:=SCOMP_PT;
 sr:=SREF_PT;
 fpt:=j^.FREQ_PT;
 WHILE fpt<>NIL DO
 BEGIN
  freq:=fpt^.value;
  WRITELN(RESULTS,'F=',freq:16,'     ','S=',-(s^.imd)/(sr^.imd):16);
  fpt:=fpt^.vpt;
  s:=s^.drptn;
  sr:=sr^.drptn;
 END
END;

{***************************************************************************}

PROCEDURE WRITE_SCONV_SENS(job:taskpt);
VAR
 f_ptr:listbpt;
 d_ptr:dptr;
 denom_pt:drpt;
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 z_ptr:zptr;
 c_ptr:cptr;
 l_ptr:lptr;
 Ysgen_TAIL_PT:listcpt;

BEGIN
    INFO('WRITING GENERATOR GS SENSITIVITIES');
    WRITELN(RESULTS,asterix,version,asterix);

{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
    f_ptr:=job^.FREQ_PT;
    Ysgen_HEAD_PT:=NIL;
    while ( f_ptr<>NIL ) do begin
        ADD2CPLX_LIST(Ysgen_HEAD_PT, Ysgen_TAIL_PT, 0.0, 0.0);
        f_ptr:=f_ptr^.vpt;
    end;

{* d_ptr points to sensors' coffactors. Denominator has the form of sum   *}
{* [SUM(S[TF/Yi]*S[Yi/eps])]=SUM[eps*svar/(scons+svar*eps)*S[TF/sens]     *}

{* initialize list SS_PT                                                  *}
    SS_PT:=NIL;
    denom_pt:=NIL;
    f_ptr:=job^.FREQ_PT;
    WHILE f_ptr<>NIL DO
    BEGIN
        ADD2COFF_LIST(SS_PT,denom_pt,0,0);
        f_ptr:=f_ptr^.vpt
    END;
  { the condition should look like this
          if (( yvar=TUN ) and (ytunpt^.tunpara=eps_symb)) then begin
          but this algorithm should work well when there are no other PARAs
   ... }
  { Denominator has the form of sum for each sensors  }
  { [SUM(S[TF/Yi]*S[Yi/eps])]=SUM[eps*svar/(scons+svar*eps)*S[TF/sens]    }
    {* freq pointers are reseted in suporting procedures                      *}
    {* The coffactor list starts from DL and DN                               *}
    { then goes comp YGRLC                                                     }
    d_ptr:=job^.COFF_PT^.dnext^.dnext;


    y_ptr:=Y_head;
    while y_ptr<>NIL do begin
      with y_ptr^ do begin
        if ( yvar<>GEN ) then begin {* there is no coffactor for GEN *}
          if ( yvar=TUNED ) then begin
            CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,yname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,y_ptr^.ytunpt);
          end;
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      y_ptr:=y_ptr^.ynext
    end;

    g_ptr:=G_head;
    while g_ptr<>NIL do begin
      with g_ptr^ do begin
        if ( gvar<>GEN ) then begin {* there is no coffactor for GEN *}
          if ( gvar=TUNED ) then begin
            CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,g_ptr^.gtunpt);
          end;
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      g_ptr:=g_ptr^.gnext
    end;


    r_ptr:=R_head;
    while (r_ptr<>NIL) do begin
      with r_ptr^ do begin
        if ( rvar<>GEN ) then begin {* there is no coffactor for GEN *}
          if ( rvar=TUNED ) then begin
            CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,r_ptr^.rtunpt);
          end;
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      r_ptr:=r_ptr^.rnext;
    end;

    c_ptr:=C_head;
    while ( c_ptr<>NIL ) do begin
      with c_ptr^ do begin
        if ( cvar=TUNED ) then begin
          CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          { SS_PT list accumulates results from sensor referenced by SrSi_PT}
          ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,c_ptr^.ctunpt);
        end;
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      c_ptr:=c_ptr^.cnext
    end;

    l_ptr:=L_head;
    while ( l_ptr<>NIL  ) do begin
      with l_ptr^ do begin
        if ( lvar=TUNED ) then begin
          CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          { SS_PT list accumulates results from sensor referenced by SrSi_PT}
          ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,l_ptr^.ltunpt);
        end;
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      l_ptr:=l_ptr^.lnext
    end;


{* values of denominator are stored in SS_PT                              *}
{* for each component                                                     *}
{* actual start                                                           *}

  d_ptr:=job^.COFF_PT^.dnext^.dnext;

    y_ptr:=Y_head;
    while y_ptr<>NIL do begin
      with y_ptr^ do begin
        if ( yvar<>GEN ) then begin {* there is no coffactor for GEN *}

            CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,yname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            WRITE_SCONV_SENS_VAL(job,yname,SrSi_PT,SS_PT);

          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      y_ptr:=y_ptr^.ynext
    end;

    g_ptr:=G_head;
    while g_ptr<>NIL do begin
      with g_ptr^ do begin
        if ( gvar<>GEN ) then begin {* there is no coffactor for GEN *}

            CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            WRITE_SCONV_SENS_VAL(job,gname,SrSi_PT,SS_PT);

          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      g_ptr:=g_ptr^.gnext
    end;

    z_ptr:=Z_head;
    while z_ptr<>NIL do begin
      with z_ptr^ do begin
        if ( zvar<>GEN ) then begin {* there is no coffactor for GEN *}
          CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_SCONV_SENS_VAL(job,zname,SrSi_PT,SS_PT);
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      z_ptr:=z_ptr^.znext
    end;

    r_ptr:=R_head;
    while (r_ptr<>NIL) do begin
      with r_ptr^ do begin
        if ( rvar<>GEN ) then begin {* there is no coffactor for GEN *}

            CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            WRITE_SCONV_SENS_VAL(job,rname,SrSi_PT,SS_PT);

          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      r_ptr:=r_ptr^.rnext
    end;

    c_ptr:=C_head;
    while ( c_ptr<>NIL ) do begin
      with c_ptr^ do begin

          CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_SCONV_SENS_VAL(job,cname,SrSi_PT,SS_PT);

        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      c_ptr:=c_ptr^.cnext
    end;

    l_ptr:=L_head;
    while ( l_ptr<>NIL  ) do begin
      with l_ptr^ do begin

          CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          WRITE_SCONV_SENS_VAL(job,lname,SrSi_PT,SS_PT);

        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      l_ptr:=l_ptr^.lnext
    end;


 WRITELN(RESULTS,asterix,version,asterix);
END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE WRITE_SCONV_DISTO(job:taskpt);

{***************************************************************************}

PROCEDURE COMPUTE_FIRST_PASS(job:taskpt);
VAR

 f_ptr:listbpt;
 d_ptr:dptr;
 denom_pt:drpt;
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 c_ptr:cptr;
 l_ptr:lptr;
 Ysgen_TAIL_PT:listcpt;


BEGIN
    INFO('COMPUTING RESULTS OF RCONV DISTO - FIRST PASS');
    FB_PT:=job^.FREQ_PT;
    COMPUTE_TF_VALUE (FB_PT,job^.COFF_PT,NIL);
    ZM_PT:=TFri_PT;


{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
    f_ptr:=job^.FREQ_PT;
    Ysgen_HEAD_PT:=NIL;
    while ( f_ptr<>NIL ) do begin
        ADD2CPLX_LIST(Ysgen_HEAD_PT, Ysgen_TAIL_PT, 0.0, 0.0);
        f_ptr:=f_ptr^.vpt;
    end;

{* d_ptr points to sensors' coffactors. Denominator has the form of sum   *}
{* [SUM(S[TF/Yi]*S[Yi/eps])]=SUM[eps*svar/(scons+svar*eps)*S[TF/sens]     *}

{* initialize list SS_PT                                                  *}
    SS_PT:=NIL;
    denom_pt:=NIL;
    f_ptr:=job^.FREQ_PT;
    WHILE (f_ptr<>NIL) DO
    BEGIN
        ADD2COFF_LIST(SS_PT,denom_pt,0,0);
        f_ptr:=f_ptr^.vpt
    END;
  { the condition should look like this
          if (( yvar=TUN ) and (ytunpt^.tunpara=eps_symb)) then begin
          but this algorithm should work well when there are no other PARAs
   ... }
  { Denominator has the form of sum for each sensors  }
  { [SUM(S[TF/Yi]*S[Yi/eps])]=SUM[eps*svar/(scons+svar*eps)*S[TF/sens]    }

      {* freq pointers are reseted in suporting procedures                      *}
    {* The coffactor list starts from DL and DN                               *}
    { then goes comp YGRLC                                                     }
    d_ptr:=job^.COFF_PT^.dnext^.dnext;

    y_ptr:=Y_head;
    while y_ptr<>NIL do begin
      with y_ptr^ do begin
          if ( yvar=TUNED ) then begin
            CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,yname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,y_ptr^.ytunpt);
            d_ptr:=d_ptr^.dnext^.dnext;
          end;
      end;
      y_ptr:=y_ptr^.ynext
    end;

    g_ptr:=G_head;
    while g_ptr<>NIL do begin
      with g_ptr^ do begin
          if ( gvar=TUNED ) then begin
            CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,g_ptr^.gtunpt);
            d_ptr:=d_ptr^.dnext^.dnext;
          end;
      end;
      g_ptr:=g_ptr^.gnext
    end;


    r_ptr:=R_head;
    while (r_ptr<>NIL) do begin
      with r_ptr^ do begin
          if ( rvar=TUNED ) then begin
            CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,r_ptr^.rtunpt);
            d_ptr:=d_ptr^.dnext^.dnext;
          end;
      end;
      r_ptr:=r_ptr^.rnext
    end;

    c_ptr:=C_head;
    while ( c_ptr<>NIL ) do begin
      with c_ptr^ do begin
        if ( cvar=TUNED ) then begin
          CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          { SS_PT list accumulates results from sensor referenced by SrSi_PT}
          ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,c_ptr^.ctunpt);
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      c_ptr:=c_ptr^.cnext
    end;

    l_ptr:=L_head;
    while ( l_ptr<>NIL  ) do begin
      with l_ptr^ do begin
        if ( lvar=TUNED ) then begin
          CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
          COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
          { SS_PT list accumulates results from sensor referenced by SrSi_PT}
          ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,l_ptr^.ltunpt);
          d_ptr:=d_ptr^.dnext^.dnext;
        end;
      end;
      l_ptr:=l_ptr^.lnext
    end;
{* values of denominator are stored in SS_PT                              *}
 SxrSxi_PT:=SS_PT;
END;

{***************************************************************************}

PROCEDURE COMPUTE_SECOND_PASS(j:taskpt);
BEGIN
 INFO('COMPUTING RESULTS OF RCONV DISTO - SECOND PASS');
 COMPUTE_TF_VALUE (j^.FREQ_PT,j^.COFF_PT,NIL);
END;

{***************************************************************************}

PROCEDURE COMPUTE_THIRD_PASS(j:taskpt);
BEGIN
 INFO('COMPUTING RESULTS OF RCONV DISTO - THIRD PASS');
 COMPUTE_TF_VALUE (j^.FREQ_PT,j^.COFF_PT,NIL);
END;

{***************************************************************************}

PROCEDURE COMPUTE_DISTO(j:taskpt);
VAR
 h:INTEGER;
 fbptr:listbpt;
 zptr,zhptr,sptr,mhptr:drpt;
 ahptr:listbpt;
 DENOM,NOM,AH:DOUBLE;
BEGIN
 fbptr:=FB_PT;
 zptr:=ZM_PT;
 sptr:=SxrSxi_PT;
 zhptr:=ZMh_PT;
 mhptr:=VIh_PT;
 AH_PT:=NIL;
 WHILE fbptr<>NIL DO
 BEGIN
  {* compute denominator  DENOM:=Z*S[Z/Yx]/|M(Omega)|^2                  *}
  DENOM:=(zptr^.red)*(sptr^.imd)/((mhptr^.red)*(mhptr^.red));
  FOR h:=2 TO harmonics DO
  BEGIN
  {* skip base freqeuncy results                                          *}
   zhptr:=zhptr^.drptn;
   mhptr:=mhptr^.drptn;
   {* compute harmon coefficient h*Im[Z(jkOmega)]/|M(k*Omega)|^2/DENOM    *}
   NOM:=(zhptr^.imd)/((mhptr^.red)*(mhptr^.red));
   Ah:=-h*NOM/DENOM;
   ADD2REAL_LIST(AH_PT,ahptr,Ah);
  END;
  mhptr:=mhptr^.drptn;
  zptr:=zptr^.drptn;
  zhptr:=zhptr^.drptn;
  sptr:=sptr^.drptn;
  fbptr:=fbptr^.vpt
 END
END;

{***************************************************************************}

PROCEDURE WRITE_DISTO_VAL(j:taskpt);
VAR
 fptr,ahptr:listbpt;
 eptr:drpt;
 h:INTEGER;
BEGIN
 fptr:=FB_PT;
 eptr:=eYn_PT;
 WRITELN(RESULTS,asterix,version,asterix);
 WRITELN(RESULTS,'GENERATIVE CONVERTER DISTORTION ANALYSIS RESULTS');
 WRITELN(RESULTS,'de/e=SUM(AH*hu^2)');

 WHILE fptr<>NIL DO
 BEGIN
  WRITELN
  (RESULTS,'FREQUENCY=',fptr^.value:16,'   ',j^.TRIM_PT^.trimname,'=',eptr^.red:16);
  FOR h:=2 TO harmonics DO
  BEGIN
   IF (fptr=FB_PT) AND (h=2) THEN ahptr:=AH_PT ELSE ahptr:=ahptr^.vpt;
   WRITELN(RESULTS,'h=',h:2,'         AH=',ahptr^.value:16)
  END;
  fptr:=fptr^.vpt;
  eptr:=eptr^.drptn
 END;
 WRITELN(RESULTS,asterix,version,asterix);
END;

{***************************************************************************}

BEGIN
 CASE disto_pass OF
 3:BEGIN
    COMPUTE_FIRST_PASS(job);
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - FIRST PASS');
     WRITE_TF_VALUE (FB_PT,TFmp_PT,ZM_PT);
     OUT_FLUSH;
     WRITE_TF_SENS_VAL (FB_PT,'ALL SENSORS',SxrSxi_PT);
     OUT_FLUSH;
    END;
    disto_pass:=2
   END;
 2:BEGIN
    COMPUTE_SECOND_PASS(job);
    ZMh_PT:=TFri_PT;
    FH_PT:=job^.FREQ_PT;
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - SECOND PASS');
     OUT_FLUSH;
     WRITE_TF_VALUE (FH_PT,TFmp_PT,ZMh_PT);
     OUT_FLUSH;
    END;
    disto_pass:=1
   END;
 1:BEGIN
    COMPUTE_THIRD_PASS(job);
    VIh_PT:=TFmp_PT;
    IF trace THEN
    BEGIN
     WRITELN(RESULTS,asterix,version,asterix);
     WRITELN(RESULTS,'RESULTS OF DISTO ANALYSIS - THIRD PASS');
     OUT_FLUSH;
     WRITE_TF_VALUE (FH_PT,VIh_PT,TFri_PT);
     OUT_FLUSH;
    END;
    OUT_FLUSH;
    COMPUTE_DISTO(job);
    OUT_FLUSH;
    WRITE_DISTO_VAL(job);
    OUT_FLUSH;
    IF mcad THEN
     MCAD_SCONV_DISTO_VAL(job);
    disto_pass:=0
   END
  END
 END;


END.

