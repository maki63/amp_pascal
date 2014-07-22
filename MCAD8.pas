UNIT MCAD8;
interface
USES
 SysUtils,
 TYPE8,VAREXT8,VAR8,TASK8,COMP8,DATAIO8;

PROCEDURE WRITE_MCAD(job:taskpt);

PROCEDURE MCAD_TF(job:taskpt);
PROCEDURE MCAD_TF_SENS(job:taskpt);

PROCEDURE MCAD_RCONV(job:taskpt);
PROCEDURE MCAD_RCONV_SENS(job:taskpt);
PROCEDURE MCAD_RCONV_DISTO_VAL(j:taskpt);


PROCEDURE MCAD_SCONV(job:taskpt);
PROCEDURE MCAD_SCONV_SENS(job:taskpt);
PROCEDURE MCAD_SCONV_DISTO_VAL(j:taskpt);


implementation
USES Amp8_main;

{***************************************************************************}

 PROCEDURE MCAD_OPEN;
 VAR
 err:INTEGER;
 BEGIN
  {$I-}
  ASSIGN(MCADF,MSTR);
  REWRITE(MCADF);
  if ( not mcaddirfile ) then begin
    ASSIGN(M0CADF,M0STR);
    REWRITE(M0CADF);
    mcaddirfile:=TRUE;
  end
  else begin
    ASSIGN(M0CADF,M0STR);
    APPEND(M0CADF);
  end;
  {$I+}
  err:=IOResult;
  IF err<>0 THEN
  BEGIN
   ASSIGN(MCADF,'NUL');
   REWRITE(MCADF);
   ERROR(4,err)
  END
 END;


{***************************************************************************}

 PROCEDURE MCAD_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+MSTR);
 {$I-}
  CLOSE(MCADF);
  CLOSE(M0CADF);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(6,err);
  END;
  ASSIGN(MCADF,'NUL');
  REWRITE(MCADF);
  MSTR:='NUL'
 END;


{***************************************************************************}

 PROCEDURE MCAD_CPX(fpt:listbpt;spt:drpt; VAR r_cnt:integer);
 BEGIN

  WHILE fpt<>NIL DO BEGIN
   WRITE(MCADF,fpt^.value,'  ');
   WRITE(MCADF,(spt^.red),'  ');
   WRITE(MCADF,(spt^.imd));
   WRITELN(MCADF);
   fpt:=fpt^.vpt;
   spt:=spt^.drptn;
   r_cnt:=r_cnt+1;
  END

 END;

{***************************************************************************}

 PROCEDURE MCAD_YxYn(fpt:listbpt;spt:drpt; VAR r_cnt:integer);
 BEGIN

  WHILE fpt<>NIL DO BEGIN
    WRITE(MCADF,fpt^.value,'  ');
    IF invertrx THEN WRITE(MCADF,1.0/(spt^.red),'  ')
    ELSE WRITE(MCADF,spt^.red);
    IF invertrn THEN WRITE(MCADF,1.0/(spt^.imd))
    ELSE WRITE(MCADF,(spt^.imd));
    WRITELN(MCADF);
    fpt:=fpt^.vpt;
    spt:=spt^.drptn;
    r_cnt:=r_cnt+1;
  END

 END;

{***************************************************************************}

 PROCEDURE MCAD_eYn(fpt:listbpt;spt:drpt; VAR r_cnt:integer);
 BEGIN

  WHILE fpt<>NIL DO BEGIN
    WRITE(MCADF,fpt^.value,'  ');
    WRITE(MCADF,spt^.red,'  ');
    IF invertrn THEN WRITE(MCADF,1.0/(spt^.imd))
    ELSE WRITE(MCADF,(spt^.imd));
    WRITELN(MCADF);
    fpt:=fpt^.vpt;
    spt:=spt^.drptn;
    r_cnt:=r_cnt+1;
  END

 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE WRITE_MCAD(job:taskpt);
 VAR
  nstr:string;
  fpt:listbpt;
  d_ptr:dptr;
  dr_ptr:drpt;
  p:integer;
  row_0,row_1:integer;
 BEGIN

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);



  d_ptr:=job^.COFF_PT;
  WHILE d_ptr<>NIL DO
  BEGIN
   d_ptr^.drfpt:=d_ptr^.CF_PT;
   d_ptr:=d_ptr^.dnext
  END;


   row_0:=1;
   row_1:=1;
   d_ptr:=job^.COFF_PT;
   WHILE d_ptr<>NIL DO
   BEGIN
    fpt:=job^.FREQ_PT;
    dr_ptr:=d_ptr^.CF_PT;
    WRITELN(M0CADF, 'DATANAME: '+d_ptr^.dname);
    while ( dr_ptr<>NIL ) do begin
      WRITELN(MCADF,fpt^.value,'  ',dr_ptr^.red,'  ',dr_ptr^.imd);
      dr_ptr:=dr_ptr^.drptn;
      fpt:=fpt^.vpt;
      row_1:=row_1+1;
    end;
    WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(D),IM(D)]' );
    row_0:=row_1;
    d_ptr:=d_ptr^.dnext
   END;

  WRITELN(M0CADF, 'EOF' );
  MCAD_CLOSE;

  d_ptr:=job^.COFF_PT;
  WHILE d_ptr<>NIL DO
  BEGIN
   d_ptr^.drfpt:=d_ptr^.CF_PT;
   d_ptr:=d_ptr^.dnext
  END
 END;


{***************************************************************************
 Write to *.m0 and *.mx
 to *.m0 directly
 to *.mx using MCAD_CPX(job^.FREQ_PT,TFri_PT,row_1)

 mcadfilenum - global mcad file counter
 OUTSTR - output name string

 @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

 PROCEDURE MCAD_TF(job:taskpt);
 VAR
  nstr:string;
  row_0,row_1:integer;
  p:integer;
 BEGIN

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+TF_name);
   if (job^.PAR_PT <> nil) then begin
    WRITELN(M0CADF, 'PARAMETERS:');
    LIST_MCAD_PAR_COMP(job);
   end;
   row_0:=1;
   row_1:=1;
   MCAD_CPX(job^.FREQ_PT,TFri_PT,row_1);
   WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(TF),IM(TF)]' );
   WRITELN(M0CADF, 'EOF' );
   MCAD_CLOSE;


 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE MCAD_TF_SENS(job:taskpt);
VAR

 f_ptr :listbpt;
 d_ptr:dptr;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 p:INTEGER;
 nstr:string;
 row_0,row_1:integer;

 Ysens_TAIL_PT:listcpt;
 YisLOAD:BOOLEAN;

BEGIN
 INFO('WRITING TRANSFER FUNCTION SENSITIVITIES TO MCAD FILE');
 STR(mcadfilenum,nstr);
 mcadfilenum:=mcadfilenum+1;
 nstr:=CONCAT('m',nstr);
 p:=POS('.',OUTSTR);
 if p<>0 then begin
  MSTR:=Copy(OUTSTR,1,p)+nstr;
  M0STR:=Copy(OUTSTR,1,p)+'m0';
 end
 else begin
  MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
  M0STR:=Copy(OUTSTR,1,p)+'.m0'
 end;

 INFO('OPENING OUTPUT:'+MSTR);
 MCAD_OPEN;

 WRITELN(M0CADF, 'FILE: '+MSTR);
 WRITELN(M0CADF, 'DATANAME: '+ 'SENS('+TF_name+')');
 if (job^.PAR_PT <> nil) then begin
  WRITELN(M0CADF, 'PARAMETERS:');
  LIST_MCAD_PAR_COMP(job);
 end;

{* first write freq points - skip this                                    *}
{ MCAD_LIST_REAL(F_PT);                                                    }
{* freq pointers are reseted in suporting procedures                      *}
{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
 f_ptr:=job^.FREQ_PT;
 Ysens_HEAD_PT:=NIL;
 while ( f_ptr<>NIL ) do begin
     ADD2CPLX_LIST(Ysens_HEAD_PT, Ysens_TAIL_PT, 0.0, 0.0);
     f_ptr:=f_ptr^.vpt;
 end;
{* The coffactor list starts from DL and DN                               *}

 d_ptr:=job^.COFF_PT^.dnext^.dnext;
 row_0:=1;
 row_1:=1;

{The coffactor order is: Y,G,R,C,L}
{* for each component                                                    *}
 y_ptr:=Y_head;
 WHILE (y_ptr<>NIL) DO BEGIN
   WITH(y_ptr^) DO BEGIN
      if ( yvar<>GEN ) then begin
        CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
        IF (y_ptr=Y0_PT) THEN YisLOAD:=TRUE ELSE YisLOAD:=FALSE;
        COMPUTE_SENS_VAL(job^.FREQ_PT,yname,YisLOAD,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
        MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
        WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+yname );
        row_0:=row_1;
        d_ptr:=d_ptr^.dnext^.dnext
      end;
    END;
    y_ptr:=y_ptr^.ynext
 END;

 g_ptr:=G_head;
 WHILE (g_ptr<>NIL) DO BEGIN
   WITH(g_ptr^) DO BEGIN
    if ( gvar<>GEN ) then begin
      CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
      WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+gname );
      row_0:=row_1;
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  g_ptr:=g_ptr^.gnext
 END;

 z_ptr:=Z_head;
 WHILE (z_ptr<>NIL) DO BEGIN
   WITH(z_ptr^) DO BEGIN
      CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
      WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+zname );
      row_0:=row_1;
      d_ptr:=d_ptr^.dnext^.dnext
  END;
  z_ptr:=z_ptr^.znext
 END;

 r_ptr:=R_head;
 WHILE r_ptr<>NIL DO BEGIN
  WITH r_ptr^ DO BEGIN
   if ( rvar<>GEN ) then begin
      CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
      WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+rname );
      row_0:=row_1;
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  r_ptr:=r_ptr^.rnext
 END;

 c_ptr:=C_head;
 WHILE c_ptr<>NIL DO BEGIN
  WITH c_ptr^ DO BEGIN
      CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
      WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+cname );
      row_0:=row_1;
      d_ptr:=d_ptr^.dnext^.dnext
    END;
    c_ptr:=c_ptr^.cnext
 END;

 l_ptr:=L_head;
 WHILE l_ptr<>NIL DO BEGIN
  WITH l_ptr^ DO BEGIN
      CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      MCAD_CPX(job^.FREQ_PT,SrSi_PT,row_1);
      WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,RE(S(TF)),IM(S(TF))]'+'_'+lname );
      row_0:=row_1;
      d_ptr:=d_ptr^.dnext^.dnext
   END;
   l_ptr:=l_ptr^.lnext
 END;

 WRITELN(M0CADF, 'EOF' );
 MCAD_CLOSE;
END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE MCAD_RCONV(job:taskpt);
 VAR
  nstr:string;
  row_0,row_1:integer;
  p:integer;
 BEGIN

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'RCONV');
   row_0:=1;
   row_1:=1;
   MCAD_YxYn(job^.FREQ_PT,YxYn_PT,row_1);

   WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,'+Yx_symb+','+Yn_symb+']' );
   WRITELN(M0CADF, 'EOF' );
   MCAD_CLOSE;

 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}


PROCEDURE MCAD_RCONV_SENS_VAL (fpt:listbpt;SCOMP_PT,SREF_PT:drpt; VAR r_cnt:integer);

VAR
 s,sr:drpt;
BEGIN
 s:=SCOMP_PT;
 sr:=SREF_PT;
 WHILE fpt<>NIL DO
 BEGIN
  WRITELN(MCADF,fpt^.value,'  ',-(s^.imd)/(sr^.imd));
  fpt:=fpt^.vpt;
  s:=s^.drptn;
  sr:=sr^.drptn;
  r_cnt:=r_cnt+1;
 END
END;


PROCEDURE MCAD_RCONV_SENS(job:taskpt);
VAR
 f_ptr:listbpt;
 d_ptr:dptr;
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 z_ptr:zptr;
 c_ptr:cptr;
 l_ptr:lptr;
 p:INTEGER;
 nstr:string;
 Ysens_TAIL_PT:listcpt;{list of complex values transfered to COMPUTE_SENS_VAL}
 row_0,row_1:integer;

BEGIN
 INFO('WRITING GENERATOR GR SENSITIVITIES TO MCAD FILE');

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'SENS('+Yx_symb+')');

   row_0:=1;
   row_1:=1;

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
          MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+yname );
          row_0:=row_1;
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
          MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+gname );
          row_0:=row_1;
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
          MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+zname );
          row_0:=row_1;
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
          MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+rname );
          row_0:=row_1;
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
    MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
    WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+cname );
    row_0:=row_1;
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
    MCAD_RCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SxrSxi_PT,row_1);
    WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+Yx_symb+')]'+'|'+lname );
    row_0:=row_1;
    d_ptr:=d_ptr^.dnext^.dnext
  END;
  l_ptr:=l_ptr^.lnext
 END;

MCAD_CLOSE;

END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}


PROCEDURE MCAD_RCONV_DISTO_VAL(j:taskpt);
VAR
 fptr,ahptr:listbpt;
 h:INTEGER;
 p:INTEGER;
 nstr:string;
 row_0,row_1:integer;

BEGIN
 INFO('WRITING GENERATOR GR DISTO COEFFICENTS TO MCAD FILE');

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'ah('+Yx_symb+')');

   row_0:=1;
   row_1:=1;

{* first write base freq points                                            *}

 fptr:=FB_PT;
 WHILE fptr<>NIL DO
 BEGIN
  FOR h:=2 TO harmonics DO BEGIN
   IF (fptr=FB_PT) AND (h=2) THEN ahptr:=AH_PT ELSE ahptr:=ahptr^.vpt;
   WRITELN(MCADF, fptr^.value,'  ',ahptr^.value);
   row_1:=row_1+1;
  END;
  fptr:=fptr^.vpt;
 END;
 WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,ah]' );
 MCAD_CLOSE
END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE MCAD_SCONV(job:taskpt);

 VAR
  nstr:string;
  row_0,row_1:integer;
  p:integer;
 BEGIN

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'SCONV');
   row_0:=1;
   row_1:=1;
   MCAD_eYn(job^.FREQ_PT,eYN_PT,row_1);
   WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..3',']', '[F,'+job^.TRIM_PT^.trimname+','+Yn_symb+']' );
   WRITELN(M0CADF, 'EOF' );
   MCAD_CLOSE;

 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE MCAD_SCONV_SENS_VAL (fpt:listbpt;SCOMP_PT,SREF_PT:drpt; VAR r_cnt:integer);

VAR
 s,sr:drpt;
BEGIN
 s:=SCOMP_PT;
 sr:=SREF_PT;
 WHILE fpt<>NIL DO
 BEGIN
  WRITELN(MCADF,fpt^.value,'  ',-(s^.imd)/(sr^.imd));
  fpt:=fpt^.vpt;
  s:=s^.drptn;
  sr:=sr^.drptn;
  r_cnt:=r_cnt+1;
 END
END;


{***************************************************************************}

PROCEDURE MCAD_SCONV_SENS(job:taskpt);
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
 p:INTEGER;
 nstr:string;
 row_0,row_1:integer;

BEGIN
 INFO('WRITING GENERATOR GS SENSITIVITIES TO MCAD FILE');

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'SENS('+job^.TRIM_PT^.trimname+')');

   row_0:=1;
   row_1:=1;



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

    z_ptr:=Z_head;
    while z_ptr<>NIL do begin
      with z_ptr^ do begin
          if ( zvar=TUNED ) then begin {*  should not happen *}
            CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
            COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
            { SS_PT list accumulates results from sensor referenced by SrSi_PT}
            ACCUMULATE_SENSOR_SENS(SS_PT,SrSi_PT,job^.TRIM_PT^.TRIM_HEAD_PT,g_ptr^.gtunpt);
          end;
          d_ptr:=d_ptr^.dnext^.dnext;
      end;
      z_ptr:=z_ptr^.znext
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
          MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+yname );
          row_0:=row_1;
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
          MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+gname );
          row_0:=row_1;
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
          MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+zname );
          row_0:=row_1;
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
          MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
          WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+rname );
          row_0:=row_1;
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
        MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
        WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+cname );
        row_0:=row_1;
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      c_ptr:=c_ptr^.cnext
    end;

    l_ptr:=L_head;
    while ( l_ptr<>NIL  ) do begin
      with l_ptr^ do begin
        CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysgen_HEAD_PT);
        COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysgen_HEAD_PT,job^.COFF_PT,d_ptr);
        MCAD_SCONV_SENS_VAL(job^.FREQ_PT,SrSi_PT,SS_PT,row_1);
        WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,S('+job^.TRIM_PT^.trimname+')]'+'|'+lname );
        row_0:=row_1;
        d_ptr:=d_ptr^.dnext^.dnext;
      end;
      l_ptr:=l_ptr^.lnext
    end;


 MCAD_CLOSE;
END;

{***************************************************************************}


PROCEDURE MCAD_SCONV_DISTO_VAL(j:taskpt);
VAR
 fptr,ahptr:listbpt;
 h:INTEGER;
 p:INTEGER;
 nstr:string;
 row_0,row_1:integer;

BEGIN
 INFO('WRITING GENERATOR GS DISTO COEFFICENTS TO MCAD FILE');

   STR(mcadfilenum,nstr);
   mcadfilenum:=mcadfilenum+1;
   nstr:=CONCAT('m',nstr);
   p:=POS('.',OUTSTR);
   if p<>0 then begin
    MSTR:=Copy(OUTSTR,1,p)+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'m0';
   end
   else begin
    MSTR:=Copy(OUTSTR,1,Length(INPSTR))+'.'+nstr;
    M0STR:=Copy(OUTSTR,1,p)+'.m0';
   end;

   INFO('OPENING OUTPUT:'+MSTR);
   MCAD_OPEN;
   WRITELN(M0CADF, 'FILE: '+MSTR);
   WRITELN(M0CADF, 'DATANAME: '+'ah('+Yx_symb+')');

   row_0:=1;
   row_1:=1;

 fptr:=FB_PT;
 WHILE fptr<>NIL DO
 BEGIN
  FOR h:=2 TO harmonics DO BEGIN
   IF (fptr=FB_PT) AND (h=2) THEN ahptr:=AH_PT ELSE ahptr:=ahptr^.vpt;
   WRITELN(MCADF, fptr^.value,'  ',ahptr^.value);
   row_1:=row_1+1;
  END;
  fptr:=fptr^.vpt;
 END;
 WRITELN(M0CADF, 'DATA: '+'[',row_0,'..',row_1-1,',1..2',']', '[F,ah]' );
 MCAD_CLOSE;

END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}



END.

