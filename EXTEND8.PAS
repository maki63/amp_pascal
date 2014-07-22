UNIT EXTEND8;
interface
USES

SysUtils,
TYPE8,VAR8,LINE8,VAREXT8,TASK8;

PROCEDURE TF(job:taskpt);
PROCEDURE TF_SENS(job:taskpt);

PROCEDURE RCONV(job:taskpt);
PROCEDURE RCONV_SENS_START(job:taskpt);
PROCEDURE RCONV_DISTO_START(job:taskpt);

PROCEDURE SCONV(job:taskpt);
PROCEDURE SCONV_SENS_START(job:taskpt);
PROCEDURE SCONV_DISTO_START(job:taskpt);
implementation
USES Amp8_main;

{**************************************************************************}
{* $TF DL(a+d)(b+c)/DM(a+d)(a+d) - NOT LOADED                             *}
{* $TF Y0*DL(a+d)(b+c)/DM(a+d)(a+d) - LOADED                              *}
{* DL and DM are extracted and serve as a construtors for sensitivites    *}
{* the actual form od coffactors has no influance on computings since     *}
{* their defintions are treated as strings                                *}
{**************************************************************************}

PROCEDURE TF(job:taskpt);
VAR
 k,l:INTEGER;
 c:char;
 found:boolean;
 listptr,listtail:listapt;
 d_ptr,d_tail:dptr;
 y_ptr:yptr;
BEGIN
 INFO('PREPARING TRANSFER FUNCTION ANALYSIS');
 found:=FALSE;
 loaded:=FALSE;
 Y0:='';
 deltaL:='';
 deltaM:='';

{* Find invoking  line                                                    *}
 listptr:=job^.COMD_PT;
 WHILE (listptr<>NIL)AND(NOT found) DO
 BEGIN
  line:=listptr^.oneline;
  xx:=FALSE;
  cpt1:=FND('!','z',1);
  IF ((line[cpt1]='$')AND(NOT xx)) THEN
  BEGIN
   c:=line[cpt1+1];
   IF ((c='T') OR (c='t')) THEN
   BEGIN
    c:=line[cpt1+2];
    IF ((c='F') OR (c='f')) THEN found:=TRUE
   END
  END;
  listptr:=listptr^.lpt
 END;

 IF NOT found THEN DATA_ERROR
 ELSE
 BEGIN
  cpt2:=FND(' ',' ',cpt1+2);
  cpt1:=FND('A','z',cpt2);
  c:=line[cpt1];
  IF (c='Y') OR (c='y') THEN
  BEGIN
   loaded:=TRUE;
   cpt2:=FND('*','*',cpt1);
   IF NOT xx THEN Y0:=COPY(line,cpt1,cpt2-cpt1)
   ELSE DATA_ERROR;
   cpt1:=FND('A','z',cpt2);
   c:=line[cpt1];
   TF_name:='';
  END
  ELSE
  BEGIN
    if (c='D') then begin
      TF_name:='';
    end
    else begin
      if (Pos('=',line)<>0) then begin
        cpt2:=FND('=','=',cpt1);
        TF_name:=COPY(line,cpt1,cpt2-cpt1);
        cpt1:=FND('A','z',cpt2);
        c:=line[cpt1]
      end
      else DATA_ERROR;
    end
  END;

  IF (c='D')  THEN
  BEGIN
   cpt2:=FND('/','/',cpt1);
   IF NOT xx THEN
   BEGIN
    deltaL:=COPY(line,cpt1,cpt2-cpt1);
    cpt1:=FND('D','D',cpt2);
    cpt2:=FND(CHR(13),' ',cpt1);
    IF NOT xx THEN deltaM:=COPY(line,cpt1,cpt2-cpt1)
    ELSE DATA_ERROR;
    k:=POS('(',deltaL);
    l:=LENGTH(deltaL);
    LCOF:=COPY(deltaL,k,l-k+1);
    k:=POS('(',deltaM);
    l:=LENGTH(deltaM);
    MCOF:=COPY(deltaM,k,l-k+1);
   END
   ELSE DATA_ERROR
  END
  ELSE DATA_ERROR;
{* add main coffactors definitions                                         *}
{* but preserve list add from the head - feature used by HARM analysis     *}
  listtail:=job^.CDEF_PT;
  d_tail:=job^.COFF_PT;
  job^.CDEF_PT:=NIL;
  job^.COFF_PT:=NIL;
  listptr:=job^.CDEF_PT;
  d_ptr:=job^.COFF_PT;
  CLEAR_LINE;
  INSERT(deltaL,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  CLEAR_LINE;
  INSERT(deltaM,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);

  listptr^.lpt:=listtail;
  d_ptr^.dnext:=d_tail;

{* look for the load admitance definitions                                 *}
  Y0_PT:=NIL;
  IF loaded THEN
  BEGIN
   {Y0VAR:=FALSE;}
   {Y0POINTER:=NIL;}
   y_ptr:=Y_head;
   WHILE y_ptr<>NIL DO
   BEGIN
    IF (y_ptr^.yname=Y0) THEN Y0_PT:=y_ptr;
    y_ptr:=y_ptr^.ynext
   END;
   IF Y0_PT=NIL THEN
   BEGIN
     STATUS('Y0 NOT FOUND EITHER IN REGULAR OR VAR COMPONENTS');
     ERROR(3,0)
   END
  END

 END
END;


{**************************************************************************}
{**************************************************************************}
{* This procedure adds cofactor bypassing PREPARE_JOB                     *}
{* All coffactors are added to CDEF list in order to have things in order *}
{* but the CDEF list cannot be processed by PREPARE_JOB                   *}
{**************************************************************************}
{**************************************************************************}

PROCEDURE CREATE_SENSCF
(n:symb;w,r,k,l:INTEGER;LC,MC:string;j:taskpt;VAR lpt:listapt;VAR d_ptr:dptr);
VAR
 S,ws,rs,ks,ls:STRING;
BEGIN
 STR(w,ws);
 STR(r,rs);
 STR(k,ks);
 STR(l,ls);
 S:=CONCAT('DL.',n,LC,',(',ws,'+',rs,')(',ks,'+',ls,')');
 CLEAR_LINE;
 INSERT(S,line,1);
 ADD_COFFACTOR(j,d_ptr);
 ADD_CDEF(j,lpt);
 S:=CONCAT('DM.',n,MC,',(',ws,'+',rs,')(',ks,'+',ls,')');
 CLEAR_LINE;
 INSERT(S,line,1);
 ADD_COFFACTOR(j,d_ptr);
 ADD_CDEF(j,lpt);
END;


PROCEDURE TF_SENS(job:taskpt);
VAR
 listptr,listtail:listapt;
 d_ptr,d_tail:dptr;
 y_ptr:yptr;
 z_ptr:zptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 g_ptr:gptr;


BEGIN
 INFO('PREPARING SENSITIVITY ANALYSIS OF TRANSFER FUNCTION');
{* there are only two coffactors  DL and DN until NOW - set by TF         *}
{* tail - the pointer of the second                                       *}

 listtail:=job^.CDEF_PT^.lpt^.lpt;
 listptr:=job^.CDEF_PT^.lpt;
 listptr^.lpt:=NIL;

 d_tail:=job^.COFF_PT^.dnext^.dnext;
 d_ptr:=job^.COFF_PT^.dnext;
 d_ptr^.dnext:=NIL;

{The order is: Y,G,Z,R,C,L}

  y_ptr:=Y_head;
  WHILE y_ptr<>NIL DO
  BEGIN
   WITH y_ptr^ DO
    if ( yvar<>GEN ) then begin
      CREATE_SENSCF(yname,ya,yb,ya,yb,LCOF,MCOF,job,listptr,d_ptr);
    end;
   y_ptr:=y_ptr^.ynext
  END;

  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO
  BEGIN
   WITH g_ptr^ DO
    if ( gvar<>GEN ) then begin
      CREATE_SENSCF(gname,ga,gb,gc,gd,LCOF,MCOF,job,listptr,d_ptr);
    end;
    g_ptr:=g_ptr^.gnext
  END;

  z_ptr:=Z_head;
  WHILE z_ptr<>NIL DO
  BEGIN
   WITH z_ptr^ DO
      CREATE_SENSCF(zname,za,zb,za,zb,LCOF,MCOF,job,listptr,d_ptr);
    z_ptr:=z_ptr^.znext
  END;

  r_ptr:=R_head;
  WHILE r_ptr<>NIL DO
  BEGIN
   WITH r_ptr^ DO
    if ( rvar<>GEN ) then begin
      CREATE_SENSCF(rname,ra,rb,ra,rb,LCOF,MCOF,job,listptr,d_ptr);
    end;
   r_ptr:=r_ptr^.rnext
  END;

  c_ptr:=C_head;
  WHILE c_ptr<>NIL DO
  BEGIN
   WITH c_ptr^ DO
    CREATE_SENSCF(cname,ca,cb,ca,cb,LCOF,MCOF,job,listptr,d_ptr);
   c_ptr:=c_ptr^.cnext
  END;

  l_ptr:=L_head;
  WHILE l_ptr<>NIL DO
  BEGIN
   WITH l_ptr^ DO
    CREATE_SENSCF(lname,la,lb,la,lb,LCOF,MCOF,job,listptr,d_ptr);
   l_ptr:=l_ptr^.lnext
  END;

  listptr^.lpt:=listtail;
  d_ptr^.dnext:=d_tail;

END;

{***************************************************************************}
{ search for matching GEN                                                   }
{***************************************************************************}
FUNCTION MATCH_Y_GEN (job:taskpt; y_name:symb): yptr;
VAR
  y_ptr:yptr;
BEGIN
  Result:=NIL;
  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
    if (( y_ptr^.yname = y_name ) and (y_ptr^.yvar=GEN)) then
    begin
       Result:=y_ptr;
       Break;
    end;
    y_ptr:=y_ptr^.ynext;
  end;
END;

{***************************************************************************}
{ search for matching GEN                                                   }
{***************************************************************************}
FUNCTION MATCH_R_GEN (job:taskpt; r_name:symb): rptr;
VAR
  r_ptr:rptr;
BEGIN
  Result:=NIL;
  r_ptr:=R_head;
  while R_ptr<>NIL do
  begin
    if (( r_ptr^.rname = r_name ) and (r_ptr^.rvar=GEN)) then
    begin
       Result:=r_ptr;
       Break;
    end;
    r_ptr:=r_ptr^.rnext;
  end;
END;

{***************************************************************************}
{ search for matching GEN                                                   }
{***************************************************************************}
FUNCTION MATCH_G_GEN (job:taskpt; g_name:symb): gptr;
VAR
  g_ptr:gptr;
BEGIN
  Result:=NIL;
  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
    if ((g_ptr^.gname = g_name) and (g_ptr^.gvar=GEN)) then
    begin
       Result:=g_ptr;
       Break;
    end;
    g_ptr:=g_ptr^.gnext;
  end;
END;


{***************************************************************************}
{*        prepare Dx-simple generative converter with R sensor             *}
{* $GR        g2 y2a y2b y2c y2d    g3 y3a y3b y3c y3d                     *}
{***************************************************************************}

PROCEDURE RCONV(job:taskpt);
VAR
 c:char;

 found:boolean;
 listptr,listtail:listapt;
 d_ptr:dptr;
 sx,sy,sz1,sz2:string;

BEGIN
 INFO('PREPARING GENERATIVE CONVERTER ANALYSIS ');
 found:=FALSE;
{* Find invoking  line                                                     *}
 listptr:=job^.COMD_PT;
 WHILE (listptr<>NIL)AND(NOT found) DO
 BEGIN
  line:=listptr^.oneline;
  xx:=FALSE;
  cpt1:=FND('!','z',1);
  IF ((line[cpt1]='$')AND(NOT xx)) THEN
  BEGIN
   c:=line[cpt1+1];
   IF ((c='G') OR (c='g')) THEN
   BEGIN
    c:=line[cpt1+2];
    IF ((c='R') OR (c='r')) THEN
    begin
      found:=TRUE;
      R_GEN_lineptr:=listptr;
    end
   END
  END;
  listptr:=listptr^.lpt
 END;
 IF NOT found THEN DATA_ERROR
 ELSE
 BEGIN


 {* comand line invoking RCONV is found                                    *}
  Yx_ptr := NIL; Yn_ptr := NIL;
  Rx_ptr := NIL; Rn_ptr := NIL;
  Gx_ptr := NIL; Gn_ptr := NIL;
  xx:=FALSE;
  sensor:=FALSE;
  invertrx:=FALSE;
  invertrn:=FALSE;
  {* first element - freq tuning can-be y,R,G                               *}
  cpt1:=FND('$','$',1);
  cpt2:=FND(' ',' ',cpt1);         {* skip $GR... *}
  cpt1:=FND('!','z',cpt2);

  cpt2:=FND(' ',' ',cpt1);         {* find Yxs .. *}
  TXT(cpt1,cpt2-1);
  Yx_symb:=nsymb;

  IF (Yx_symb[1]='R') OR (Yx_symb[1]='r') THEN invertrx:=TRUE;  {* marker - resitor *}

  CASE Yx_symb[1] OF
  'y','Y':
   BEGIN
        Yx_ptr := MATCH_Y_GEN(job, Yx_symb);
        if ( Yx_ptr <> NIL ) then begin
            yxna:=Yx_ptr^.ya;
            yxnb:=Yx_ptr^.yb;
            yxnc:=yxna;
            yxnd:=yxnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'r','R':
   BEGIN
        Rx_ptr := MATCH_R_GEN(job, Yx_symb);
        if ( Rx_ptr <> NIL ) then begin
            yxna:=Rx_ptr^.ra;
            yxnb:=Rx_ptr^.rb;
            yxnc:=yxna;
            yxnd:=yxnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'g','G':
   BEGIN
        Gx_ptr := MATCH_G_GEN(job, Yx_symb);
        if ( Gx_ptr <> NIL ) then begin
            yxna:=Gx_ptr^.ga;
            yxnb:=Gx_ptr^.gb;
            yxnc:=Gx_ptr^.gc;
            yxnd:=Gx_ptr^.gd;
        end
        else begin
          GEN_ERROR;
        end;
   END
   ELSE
    DATA_ERROR
  END;

 {* second element  - quasi linear-can be y,R,G                            *}

   cpt1:=FND('!','z',cpt2);

  cpt2:=FND(' ',' ',cpt1);         {* find Yns .. *}
  TXT(cpt1,cpt2-1);
  Yn_symb:=nsymb;
  IF (Yn_symb[1]='R') OR (Yn_symb[1]='r') THEN
    invertrn:=TRUE; {* marker - resitor *}

  CASE Yn_symb[1] OF
  'y','Y':
   BEGIN
        Yn_ptr := MATCH_Y_GEN(job, Yn_symb);
        if ( Yn_ptr <> NIL ) then begin
            ynna:=Yn_ptr^.ya;
            ynnb:=Yn_ptr^.yb;
            ynnc:=ynna;
            ynnd:=ynnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'r','R':
   BEGIN
        Rn_ptr := MATCH_R_GEN(job, Yn_symb);
        if ( Rn_ptr <> NIL ) then begin
            ynna:=Rn_ptr^.ra;
            ynnb:=Rn_ptr^.rb;
            ynnc:=ynna;
            ynnd:=ynnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'g','G':
   BEGIN
        Gn_ptr := MATCH_G_GEN(job, Yn_symb);
        if ( Gn_ptr <> NIL ) then begin
            ynna:=Gn_ptr^.ga;
            ynnb:=Gn_ptr^.gb;
            ynnc:=Gn_ptr^.gc;
            ynnd:=Gn_ptr^.gd;
        end
        else begin
          GEN_ERROR;
        end;
   END
   ELSE
    DATA_ERROR
  END;

{*  yx=(yxna+yxnb)(yxnc+yxnd)                                                  *}
  STR(yxna,sx);
  STR(yxnb,sy);
  sz1:=CONCAT('(',sx,'+',sy,')');
  STR(yxnc,sx);
  STR(yxnd,sy);
  sz2:=CONCAT('(',sx,'+',sy,')');
  YXCOF:=CONCAT(sz1,sz2);
{*  yn=(ynna+ynnb)(ynnc+ynnd)                                                  *}
  STR(ynna,sx);
  STR(ynnb,sy);
  sz1:=CONCAT('(',sx,'+',sy,')');
  STR(ynnc,sx);
  STR(ynnd,sy);
  sz2:=CONCAT('(',sx,'+',sy,')');
  YNCOF:=CONCAT(sz1,sz2);
{* ADD FROM THE HEAD  D,DX,DY,DXY                                          *}
  listtail:=job^.CDEF_PT;
  job^.CDEF_PT:=NIL;
  job^.COFF_PT:=NIL;
  listptr:=job^.CDEF_PT;
  d_ptr:=job^.COFF_PT;
  CLEAR_LINE;
  sx:=CONCAT('D   (0+0)(0+0)');
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  sx:=CONCAT('DX','  ',YXCOF);
  CLEAR_LINE;
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  sx:=CONCAT('DY','  ',YNCOF);
  CLEAR_LINE;
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  sx:=CONCAT('DYX',' ',YXCOF,',',YNCOF);
  CLEAR_LINE;
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  listptr^.lpt:=listtail;
 END
END;
{**************************************************************************}
{**************************************************************************}
{**************************************************************************}

PROCEDURE CREATE_VAR_Yx(var var_pt:varpt);
BEGIN
 NEW(var_pt);
 var_pt^.varnext:=NIL;
 var_pt^.varname:=Yx_symb;
 var_pt^.Var_Complex:=FALSE;
 var_pt^.VVR_HEAD_PT:=NIL;
 var_pt^.VVR_TAIL_PT:=NIL;
END;

{**************************************************************************}

PROCEDURE RCONV_SENS_START(job:taskpt);

VAR
 newtask,tail:taskpt;
 listptr:listapt;
 lstr:string;
 cval:DOUBLE;
 ref_pt:drpt;

BEGIN
 INFO('PREPARING RCONV CONVERTER SENSITIVITY ANALYSIS');
{* create new task in order to compute TF and sensitivity                *}
 tail:=job^.tpt;
 NEW(job^.tpt);
 newtask:=job^.tpt;
 newtask^.tpt:=tail;
 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
 {*copy frequency list                                                    *}
 newtask^.FREQ_PT:=job^.FREQ_PT;
 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.VAR_PT:=NIL;
 newtask^.PAR_PT:=NIL;

{* for GR sensor has no special meaning just another type of varying comp *}
 newtask^.TRIM_PT:=job^.TRIM_PT;
 newtask^.TUN_PT:=job^.TUN_PT;

 gen_sens:=TRUE;
 sensor:=FALSE;                         {* redirect output in FINISH_IT *}

{* add definitions                                                      *}
 listptr:=job^.COMD_PT;
 CLEAR_LINE;
{* define TF function definition                                          *}
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,listptr);
 CLEAR_LINE;
{* set switches                                                           *}
 INSERT('$SENS  ',line,1);
 ADD_COMD(newtask,listptr);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;

{* add Yx computed in previouse step  to the VAR list                    *}
 CREATE_VAR_Yx(newtask^.VAR_PT);
{* copy varcomponents defined for the converter add from the tail         *}
 newtask^.VAR_PT^.varnext:=job^.VAR_PT;

 ref_pt:=YxYn_PT;
 WHILE ref_pt<>NIL DO
 BEGIN
  IF invertrx THEN cval:=1/(ref_pt^.red) ELSE cval:=ref_pt^.red;
  ADD2REAL_LIST(newtask^.VAR_PT^.VVR_HEAD_PT,newtask^.VAR_PT^.VVR_TAIL_PT,cval);
  ref_pt:=ref_pt^.drptn
 END;

 { change the status of Yx from GEN to VAR                                 }
 case ( Yx_symb[1] ) of
  'y','Y':  begin
              Yx_ptr^.yvar:=VARIABLE;
              Yx_ptr^.yref:=Yx_symb;
            end;
  'r','R':  begin
              Rx_ptr^.rvar:=VARIABLE;
              Rx_ptr^.rref:=Yx_symb;
            end;
  'g','G':  begin
              Gx_ptr^.gvar:=VARIABLE;
              Gx_ptr^.gref:=Yx_symb;
            end;
 end;

END;

{**************************************************************************}
{**************************************************************************}
{**************************************************************************}

PROCEDURE CREATE_FREQ_HARM_LIST (h:INTEGER;reffpt:listbpt;VAR HEAD:listbpt);
{* This procedure has to create new frequency list                        *}
{* Frequency list has to be in form  f1 f1*2 f1*3 ..., f2 f2*2 f2*3 ...,  *}
{* h:# of harmonics;reffpt:-pointer to reference list                     *}
VAR
 fpt,nfpt:listbpt;
 k:INTEGER;
BEGIN

 fpt:=reffpt;
 HEAD:=NIL;
 WHILE fpt<>NIL DO
 BEGIN
  FOR k:=1 TO h DO
  BEGIN
   ADD2REAL_LIST(HEAD,nfpt,fpt^.value*k);
  END;
  fpt:=fpt^.vpt;
 END
END;

{**************************************************************************}

PROCEDURE CREATE_PAR_HARM_LIST (h:INTEGER;reffpt:listbpt;VAR HEAD:listbpt);
{* This procedure has to create new ctrl list                             *}
{* Control list has to be in form  e1 e1   e1   ..., e2 e2   e2   ...,    *}
{* h:# of harmonics;reffpt:-pointer to reference list                     *}
VAR
 fpt,nfpt:listbpt;
 k:INTEGER;
BEGIN

 fpt:=reffpt;
 HEAD:=NIL;
 WHILE fpt<>NIL DO
 BEGIN
  FOR k:=1 TO h DO
  BEGIN
   ADD2REAL_LIST(HEAD,nfpt,fpt^.value);
  END;
  fpt:=fpt^.vpt;
 END
END;

{**************************************************************************}

PROCEDURE CREATE_VAR_HARM
 (h:INTEGER;refvar:varpt;VAR VARHEAD,VARTAIL:varpt);
{* This procedure has to create new comp                                  *}
{* Component val list has to be in form  v1 v1 v1 ..., v2 v2   v2   ...,  *}
{* h:# of harm; refvarpt:pointer to reference component;                  *}
VAR
 rpt,nrpt:listbpt;
 cpt,ncpt:listcpt;
 k:INTEGER;
BEGIN

 IF VARHEAD=NIL THEN
 BEGIN
  NEW(VARHEAD);
  VARTAIL:=VARHEAD
 END
 ELSE
 BEGIN
  NEW(VARTAIL^.varnext);
  VARTAIL:=VARTAIL^.varnext
 END;

 { copy recordy but not all pointers}
 VARTAIL^ := refvar^;
 VARTAIL^.varnext:=NIL;

  if ( VARTAIL^.Var_complex ) then begin
    VARTAIL^.VVC_HEAD_PT:=NIL;
    cpt:=refvar^.VVC_HEAD_PT;
    WHILE cpt<>NIL DO
    BEGIN
      FOR k:=1 TO h DO
      BEGIN
        ADD2CPLX_LIST(VARTAIL^.VVC_HEAD_PT,ncpt,cpt^.valre,cpt^.valim);
      END;
      cpt:=cpt^.cvpt;
    END;
 end
 else begin
    VARTAIL^.VVR_HEAD_PT:=NIL;
    rpt:=refvar^.VVR_HEAD_PT;
    WHILE rpt<>NIL DO
    BEGIN
      FOR k:=1 TO h DO
      BEGIN
        ADD2REAL_LIST(VARTAIL^.VVR_HEAD_PT,nrpt,rpt^.value);
      END;
      rpt:=rpt^.vpt;
    END;
 end;

END;



{**************************************************************************}

PROCEDURE RCONV_DISTO_START(job:taskpt);

VAR
 found:BOOLEAN;
 c:CHAR;
 newtask,prevtask,tasktail:taskpt;
 listptr:listapt;
 lstr:string;
 comppt,varcomp_pt:varpt;
 ref_pt:drpt;
 cval:DOUBLE;
 d_ptr:dptr;
 sx,sy,sz1,sz2,dstr:STRING;

BEGIN
 INFO('PREPARING RCONV- GENERATIVE CONVERTER DISTORTION ANALYSIS');
{* find invoking line                                                    *}
 found:=FALSE;
{* Find invoking  line                                                   *}
{* $HARM #harm voltage_node_b voltage_node_c                             *}
 listptr:=job^.COMD_PT;
 WHILE (listptr<>NIL)AND(NOT found) DO
 BEGIN
  line:=listptr^.oneline;
  xx:=FALSE;
  cpt1:=FND('!','z',1);
  IF ((line[cpt1]='$')AND(NOT xx)) THEN
  BEGIN
   c:=line[cpt1+1];
   IF ((c='H') OR (c='h')) THEN
   BEGIN
    c:=line[cpt1+2];
    IF ((c='A') OR (c='a')) THEN found:=TRUE
   END
  END;
  listptr:=listptr^.lpt
 END;
 IF NOT found THEN DATA_ERROR
 ELSE
 BEGIN
  xx:=FALSE;
  cpt1:=FND('$','$',1);
  cpt2:=FND(' ',' ',cpt1);         {* skip $... *}
  cpt1:=FND('!','z',cpt2);
  RIN;harmonics:=itg;
  RIN;vnb:=itg;
  RIN;vnc:=itg;
  IF xx THEN DATA_ERROR
 END;

{*======================================================================*}
{* first create job to compute TF and S[TF/YX]                          *}
 tasktail:=job^.tpt;
 NEW(job^.tpt);
 newtask:=job^.tpt;

 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;

 {*copy frequency list                                                   *}
 newtask^.FREQ_PT:=job^.FREQ_PT;
 newtask^.TRIM_PT:=job^.TRIM_PT;
 newtask^.TUN_PT:=job^.TUN_PT;

{*reset all other pointers                                              *}
 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.PAR_PT:=NIL;
 newtask^.VAR_PT:=NIL;

{* add Yx computed in previouse step  to the VAR list                    *}
 CREATE_VAR_Yx(newtask^.VAR_PT);
{* copy varcomponents defined for the converter add from the tail         *}
 newtask^.VAR_PT^.varnext:=job^.VAR_PT;

 ref_pt:=YxYn_PT;
 WHILE ref_pt<>NIL DO
 BEGIN
  IF invertrx THEN cval:=1/(ref_pt^.red) ELSE cval:=ref_pt^.red;
  ADD2REAL_LIST(newtask^.VAR_PT^.VVR_HEAD_PT,newtask^.VAR_PT^.VVR_TAIL_PT,cval);
  ref_pt:=ref_pt^.drptn
 END;

 { change the status of Yx from GEN to VAR                                 }
 case ( Yx_symb[1] ) of
  'y','Y':  begin
              Yx_ptr^.yvar:=VARIABLE;
              Yx_ptr^.yref:=Yx_symb;
            end;
  'r','R':  begin
              Rx_ptr^.rvar:=VARIABLE;
              Rx_ptr^.rref:=Yx_symb;
            end;
  'g','G':  begin
              Gx_ptr^.gvar:=VARIABLE;
              Gx_ptr^.gref:=Yx_symb;
            end;
 end;

{* add definitions  TF and 2 coffactors required by S[TF/YX]   *}
{* define TF function definition  *}
 listptr:=newtask^.COMD_PT;
 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,listptr);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;

 listptr:=newtask^.CDEF_PT;
 d_ptr:=newtask^.COFF_PT;

{* the next step requires caution                                         *}
{* CREATE_SENSCF adds coffactors to CDEF and COFF lists                   *}
{* COFF has to be reseted, and $TF and TF procedure will add from head    *}
 case ( Yx_symb[1] ) of
  'y','Y':  begin
              with Yx_ptr^ do
              CREATE_SENSCF(yname,ya,yb,ya,yb,YNCOF,'(0+0)(0+0)',newtask,listptr,d_ptr);
            end;
  'r','R':  begin
              with Rx_ptr^ do
              CREATE_SENSCF(rname,ra,rb,ra,rb,YNCOF,'(0+0)(0+0)',newtask,listptr,d_ptr);
            end;
  'g','G':  begin
              with Gx_ptr^ do
              CREATE_SENSCF(gname,ga,gb,gc,gd,YNCOF,'(0+0)(0+0)',newtask,listptr,d_ptr);
            end;
 end;



{*======================================================================*}
{* second new tasks computes DL/DM for harmonics                        *}

 NEW(newtask^.tpt);
 prevtask:=newtask;
 newtask:=newtask^.tpt;

 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;

 newtask^.TUN_PT:=job^.TUN_PT;
 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;

 newtask^.FREQ_PT:=NIL;
 newtask^.VAR_PT:=NIL;
 newtask^.TRIM_PT:=NIL;
 newtask^.PAR_PT:=NIL;

{* For two next tasks new lists for harmonics has to be created         *}
 CREATE_FREQ_HARM_LIST (harmonics,prevtask^.FREQ_PT,newtask^.FREQ_PT);

 IF job^.TRIM_PT<>NIL THEN
 BEGIN
  NEW(newtask^.TRIM_PT);
  newtask^.TRIM_PT^.trimname:=job^.TRIM_PT^.trimname;
  newtask^.TRIM_PT^.TRIM_HEAD_PT:=NIL;
  newtask^.TRIM_PT^.trimnext:=NIL;
  CREATE_PAR_HARM_LIST(harmonics,job^.TRIM_PT^.TRIM_HEAD_PT, newtask^.TRIM_PT^.TRIM_HEAD_PT);
 END;

 varcomp_pt:=prevtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
  CREATE_VAR_HARM(harmonics,varcomp_pt,newtask^.VAR_PT,comppt);
  varcomp_pt:=varcomp_pt^.varnext
 END;

 varcomp_pt:=newtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
    if ( varcomp_pt^.Var_complex ) then begin
      varcomp_pt^.VVC_TAIL_PT:=varcomp_pt^.VVC_HEAD_PT;
    end
    else begin
      varcomp_pt^.VVR_TAIL_PT:=varcomp_pt^.VVR_HEAD_PT;
    end;
    varcomp_pt:=varcomp_pt^.varnext
 END;

 listptr:=newtask^.COMD_PT;
 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,listptr);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;


{*======================================================================*}
{* third new tasks computes transformation function for harmonics TF    *}
{* TF from current on Yn/Gn terminals to voltage at vnb - vnc           *}
{* all computings are made under previouse task conditions              *}

 NEW(newtask^.tpt);
 prevtask:=newtask;
 newtask:=newtask^.tpt;
 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
 newtask^.FREQ_PT:=prevtask^.FREQ_PT;
 newtask^.VAR_PT:=prevtask^.VAR_PT;
 newtask^.TRIM_PT:=prevtask^.TRIM_PT;
 newtask^.TUN_PT:=prevtask^.TUN_PT;

 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.PAR_PT:=NIL;

 varcomp_pt:=newtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
    if ( varcomp_pt^.Var_complex ) then begin
      varcomp_pt^.VVC_TAIL_PT:=varcomp_pt^.VVC_HEAD_PT;
    end
    else begin
      varcomp_pt^.VVR_TAIL_PT:=varcomp_pt^.VVR_HEAD_PT;
    end;
    varcomp_pt:=varcomp_pt^.varnext
 END;

{*  DL=D(ynna+ynnb)(vnb+vnc)                                                 *}
 STR(ynna,sx);
 STR(ynnb,sy);
 sz1:=CONCAT('(',sx,'+',sy,')');
 STR(vnb,sx);
 STR(vnc,sy);
 sz2:=CONCAT('(',sx,'+',sy,')');
 dstr:=CONCAT(sz1,sz2);
 listptr:=newtask^.COMD_PT;
 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',dstr,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,listptr);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,listptr);
  CLEAR_LINE
 END;

 newtask^.tpt:=tasktail;
 END;

{***************************************************************************}
{*        prepare  generative converter with sensors i.e. TUNED components *}
{* $GR eps  YNref  accuracy  max_number_of_itterations                     *}
{***************************************************************************}
{* NEWTON solving:  [max # of iterrations] [relative accuracy]             *}
{* Im[Z]=0 -> Im[Z]/Re[Z] < [relative accuracy]                            *}
{***************************************************************************}

PROCEDURE SCONV(job:taskpt);
VAR
 c:char;

 found:boolean;
 listptr,listtail:listapt;
 d_ptr:dptr;
 sx,sy,sz1,sz2:string;
 y_ptr:yptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 g_ptr:gptr;
 trim_pt:trimpt;

BEGIN
 INFO('PREPARING SCONV - CONVERTER WITH SENSORS ANALYSIS');
 found:=FALSE;
{* Find invoking  line                                                     *}
 listptr:=job^.COMD_PT;
 WHILE (listptr<>NIL)AND(NOT found) DO
 BEGIN
  line:=listptr^.oneline;
  xx:=FALSE;
  cpt1:=FND('!','z',1);
  IF ((line[cpt1]='$')AND(NOT xx)) THEN
  BEGIN
   c:=line[cpt1+1];
   IF ((c='G') OR (c='g')) THEN
   BEGIN
    c:=line[cpt1+2];
    IF ((c='s') OR (c='S')) THEN
      found:=TRUE;
      S_GEN_lineptr:=listptr;
   END
  END;
  listptr:=listptr^.lpt
 END;
 IF NOT found THEN DATA_ERROR
 ELSE
 BEGIN
 {* comand line invoking SCONV is found                                    *}
 {* element [Yn] - quasi linear-can be y,R,G                               *}
 {* $GR eps YN-spec  accuracy  max_number_of_itterations                      *}

  xx:=FALSE;
  invertrx:=FALSE;
  invertrn:=FALSE;
  cpt1:=FND('$','$',1);
  cpt2:=FND(' ',' ',cpt1);         {* skip $GS... *}
  cpt1:=FND('!','z',cpt2);

  cpt2:=FND(' ',' ',cpt1);         {* find Yns .. *}
  TXT(cpt1,cpt2-1);
  eps_symb:=nsymb;
  trim_pt:=MATCH_TRIM(job,eps_symb);
  if ( trim_pt = NIL ) then begin
     GEN_PARA_ERROR;
  end;
  cpt1:=FND('!','z',cpt2);

  cpt2:=FND(' ',' ',cpt1);         {* find Yns .. *}
  TXT(cpt1,cpt2-1);
  Yn_symb:=nsymb;
  IF (Yn_symb[1]='R') OR (Yn_symb[1]='r') THEN
    invertrn:=TRUE;  {* marker - resitor *}

  CASE Yn_symb[1] OF
  'y','Y':
   BEGIN
        Yn_ptr := MATCH_Y_GEN(job, Yn_symb);
        if ( Yn_ptr <> NIL ) then begin
            ynna:=Yn_ptr^.ya;
            ynnb:=Yn_ptr^.yb;
            ynnc:=ynna;
            ynnd:=ynnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'r','R':
   BEGIN
        Rn_ptr := MATCH_R_GEN(job, Yn_symb);
        if ( Rn_ptr <> NIL ) then begin
            ynna:=Rn_ptr^.ra;
            ynnb:=Rn_ptr^.rb;
            ynnc:=ynna;
            ynnd:=ynnb;
        end
        else begin
          GEN_ERROR;
        end;
   END;
  'g','G':
   BEGIN
        Gn_ptr := MATCH_G_GEN(job, Yn_symb);
        if ( Gn_ptr <> NIL ) then begin
            ynna:=Gn_ptr^.ga;
            ynnb:=Gn_ptr^.gb;
            ynnc:=Gn_ptr^.gc;
            ynnd:=Gn_ptr^.gd;
        end
        else begin
          GEN_ERROR;
        end;
   END
   ELSE
    DATA_ERROR
  END;

  RRL;
  accuracy:=rr;
  RIN;
  itrmax:=itg;
  IF xx THEN DATA_ERROR;


{* YNCOF=(ynna+ynnb)(ynnc+ynnd)                                                *}
  STR(ynna,sx);
  STR(ynnb,sy);
  sz1:=CONCAT('(',sx,'+',sy,')');
  STR(ynnc,sx);
  STR(ynnd,sy);
  sz2:=CONCAT('(',sx,'+',sy,')');
  YNCOF:=CONCAT(sz1,sz2);
  LCOF:=YNCOF;
  MCOF:='(0+0)(0+0)';

{* DEFINE FOLLOWING COFFACTORS                                             *}
{* TF=DL(ynna+ynnb)(ynnc+ynnd)/DM(0+0)(0+0)                                *}
{* AND FOR ALL SENSORS DEREVATIVES OF NOMINATOR AND DENOMINATOR            *}
{* DEFINTIONS SHOULD BE ADDED FROM HEAD, ANYWAY THIS LIST WONT BE PROCCESED*}
{* BY THE PREAPRE_JOB                                                      *}

  listtail:=job^.CDEF_PT;
  job^.CDEF_PT:=NIL;
  job^.COFF_PT:=NIL;
  listptr:=job^.CDEF_PT;
  d_ptr:=job^.COFF_PT;
  sx:=CONCAT('DL',' ',LCOF);
  CLEAR_LINE;
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);
  sx:=CONCAT('DM',' ',MCOF);
  CLEAR_LINE;
  INSERT(sx,line,1);
  ADD_COFFACTOR(job,d_ptr);
  ADD_CDEF(job,listptr);

  {* AND FOR ALL SENSORS DEREVATIVES OF NOMINATOR AND DENOMINATOR            *}
  { The order is: Y,G,R,C,L }
  { the condition should look like this
          if (( yvar=TUN ) and (ytunpt^.tunpara=eps_symb)) then begin
   ... }
  y_ptr:=Y_head;
  WHILE y_ptr<>NIL DO
  BEGIN
   WITH y_ptr^ DO
      if ( yvar=TUNED )then begin
        CREATE_SENSCF(yname,ya,yb,ya,yb,LCOF,MCOF,job,listptr,d_ptr);
      end;
   y_ptr:=y_ptr^.ynext
  END;

  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO
  BEGIN
   WITH g_ptr^ DO
      if ( gvar=TUNED ) then begin
        CREATE_SENSCF(gname,ga,gb,gc,gd,LCOF,MCOF,job,listptr,d_ptr);
      end;
    g_ptr:=g_ptr^.gnext
  END;

  r_ptr:=R_head;
  WHILE r_ptr<>NIL DO
  BEGIN
   WITH r_ptr^ DO
      if ( rvar=TUNED ) then begin
        CREATE_SENSCF(rname,ra,rb,ra,rb,LCOF,MCOF,job,listptr,d_ptr);
      end;
   r_ptr:=r_ptr^.rnext
  END;

  c_ptr:=C_head;
  WHILE c_ptr<>NIL DO
  BEGIN
   WITH c_ptr^ DO
      if ( cvar=TUNED ) then begin
        CREATE_SENSCF(cname,ca,cb,ca,cb,LCOF,MCOF,job,listptr,d_ptr);
      end;
   c_ptr:=c_ptr^.cnext
  END;

  l_ptr:=L_head;
  WHILE l_ptr<>NIL DO
  BEGIN
   WITH l_ptr^ DO
      if ( lvar=TUNED ) then begin
        CREATE_SENSCF(lname,la,lb,la,lb,LCOF,MCOF,job,listptr,d_ptr);
      end;
   l_ptr:=l_ptr^.lnext
  END;

  listptr^.lpt:=listtail;
 END
END;

{***************************************************************************}

PROCEDURE SCONV_SENS_START(job:taskpt);

VAR
 newtask,tail:taskpt;
 listptr:listapt;
 lstr:string;
 COMD_TAIL_PT:listapt;

BEGIN
 INFO('PREPARING SCONV CONVERTER SENSITIVITY ANALYSIS');
{* create new task in order to compute TF and sensitivity                *}
 tail:=job^.tpt;
 NEW(job^.tpt);
 newtask:=job^.tpt;
 newtask^.tpt:=tail;
 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
 {*copy frequency list                                                    *}
 newtask^.FREQ_PT:=job^.FREQ_PT;
 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.PAR_PT:=NIL;

 newtask^.TRIM_PT:=job^.TRIM_PT;
 newtask^.TUN_PT:=job^.TUN_PT;
 newtask^.VAR_PT:=job^.VAR_PT;

{* redirect output in FINISH_IT                                           *}
 gen_sens:=TRUE;
 sensor:=TRUE;

{* add definitions                                                        *}
 listptr:=job^.COMD_PT;
 CLEAR_LINE;
{* define TF function definition                                          *}
 COMD_TAIL_PT:=nil;
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,COMD_TAIL_PT);
 CLEAR_LINE;
{* set switches                                                           *}
 INSERT('$SENS  ',line,1);
 ADD_COMD(newtask,COMD_TAIL_PT);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;
END;

{**************************************************************************}

PROCEDURE SCONV_DISTO_START(job:taskpt);

VAR
 found:BOOLEAN;
 c:CHAR;
 newtask,prevtask,tasktail:taskpt;
 listptr:listapt;
 lstr:string;
 comppt,varcomp_pt:varpt;
 tunedptr:tunpt;
 refpt:drpt;
 cval:DOUBLE;
 valpt:listbpt;
 d_ptr:dptr;
 sx,sy,sz1,sz2,dstr:STRING;
 y_ptr:yptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 g_ptr:gptr;
 COMD_TAIL_PT:listapt;
 CDEF_TAIL_PT:listapt;

BEGIN
 INFO('PREPARING SCONV - GENERATIVE CONVERTER DISTORTION ANALYSIS');
{* find invoking line                                                    *}
 found:=FALSE;
{* Find invoking  line                                                   *}
{* $DISTO #harm voltage_node_b voltage_node_c                            *}
 listptr:=job^.COMD_PT;
 WHILE (listptr<>NIL)AND(NOT found) DO
 BEGIN
  line:=listptr^.oneline;
  xx:=FALSE;
  cpt1:=FND('!','z',1);
  IF ((line[cpt1]='$')AND(NOT xx)) THEN
  BEGIN
   c:=line[cpt1+1];
   IF ((c='H') OR (c='h')) THEN
   BEGIN
    c:=line[cpt1+2];
    IF ((c='A') OR (c='a')) THEN found:=TRUE
   END
  END;
  listptr:=listptr^.lpt
 END;
 IF NOT found THEN DATA_ERROR
 ELSE
 BEGIN
  xx:=FALSE;
  cpt1:=FND('$','$',1);
  cpt2:=FND(' ',' ',cpt1);         {* skip $... *}
  cpt1:=FND('!','z',cpt2);
  RIN;harmonics:=itg;
  RIN;vnb:=itg;
  RIN;vnc:=itg;
  IF xx THEN DATA_ERROR
 END;

{*======================================================================*}
{* first create job to compute TF and SUM S[TF/Ys]                      *}
 tasktail:=job^.tpt;
 NEW(job^.tpt);
 newtask:=job^.tpt;

 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
{*copy frequency list                                                   *}
{* ctrl - list consist of proprer solutions                             *}
{* VAR_LIST without changes                                             *}

 newtask^.FREQ_PT:=job^.FREQ_PT;
 newtask^.TRIM_PT:=job^.TRIM_PT;
 newtask^.TUN_PT:=job^.TUN_PT;
 newtask^.VAR_PT:=job^.VAR_PT;

{*reset all other pointers                                              *}
 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.PAR_PT:=NIL;

{* add definitions                                                      *}
{* define TF function definition  and coffactors required by S[TF/YX]   *}


 COMD_TAIL_PT:=nil;


 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,COMD_TAIL_PT);

 CDEF_TAIL_PT:=nil;
 d_ptr:=newtask^.COFF_PT;

{* the next step requires caution                                         *}
{* CREATE_SENSCF adds coffactors to CDEF and COFF lists                   *}
{* COFF has to be reseted, and $TF and TF procedure will add from head    *}

  {* AND FOR ALL SENSORS DEREVATIVES OF NOMINATOR AND DENOMINATOR            *}
  { The order is: Y,G,R,C,L }
  { the condition should look like this
          if (( yvar=TUN ) and (ytunpt^.tunpara=eps_symb)) then begin
   ... }
  y_ptr:=Y_head;
  WHILE y_ptr<>NIL DO
  BEGIN
   WITH y_ptr^ DO
      if ( yvar=TUNED )then begin
        CREATE_SENSCF(yname,ya,yb,ya,yb,YNCOF,'(0+0)(0+0)',newtask,CDEF_TAIL_PT,d_ptr);
      end;
   y_ptr:=y_ptr^.ynext
  END;

  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO
  BEGIN
   WITH g_ptr^ DO
      if ( gvar=TUNED ) then begin
        CREATE_SENSCF(gname,ga,gb,gc,gd,YNCOF,'(0+0)(0+0)',newtask,CDEF_TAIL_PT,d_ptr);
      end;
    g_ptr:=g_ptr^.gnext
  END;

  r_ptr:=R_head;
  WHILE r_ptr<>NIL DO
  BEGIN
   WITH r_ptr^ DO
      if ( rvar=TUNED ) then begin
        CREATE_SENSCF(rname,ra,rb,ra,rb,YNCOF,'(0+0)(0+0)',newtask,CDEF_TAIL_PT,d_ptr);
      end;
   r_ptr:=r_ptr^.rnext
  END;

  c_ptr:=C_head;
  WHILE c_ptr<>NIL DO
  BEGIN
   WITH c_ptr^ DO
      if ( cvar=TUNED ) then begin
        CREATE_SENSCF(cname,ca,cb,ca,cb,YNCOF,'(0+0)(0+0)',newtask,CDEF_TAIL_PT,d_ptr);
      end;
   c_ptr:=c_ptr^.cnext
  END;

  l_ptr:=L_head;
  WHILE l_ptr<>NIL DO
  BEGIN
   WITH l_ptr^ DO
      if ( lvar=TUNED ) then begin
        CREATE_SENSCF(lname,la,lb,la,lb,YNCOF,'(0+0)(0+0)',newtask,CDEF_TAIL_PT,d_ptr);
      end;
   l_ptr:=l_ptr^.lnext
  END;



 IF mcad THEN
 BEGIN
  CLEAR_LINE;
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
 END;
 IF trace THEN
 BEGIN
  CLEAR_LINE;
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
 END;

{*======================================================================*}
{* second new tasks computes DL/DM for harmonics                        *}
{* For two next tasks new lists for harmonics has to be created         *}

 NEW(newtask^.tpt);
 prevtask:=newtask;
 newtask:=newtask^.tpt;

 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
 newtask^.TUN_PT:=job^.TUN_PT;

 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.FREQ_PT:=NIL;
 newtask^.VAR_PT:=NIL;
 newtask^.TRIM_PT:=NIL;
 newtask^.PAR_PT:=NIL;

{* For two next tasks new lists for harmonics has to be created         *}
 CREATE_FREQ_HARM_LIST (harmonics,prevtask^.FREQ_PT,newtask^.FREQ_PT);

 IF job^.TRIM_PT<>NIL THEN
 BEGIN
  NEW(newtask^.TRIM_PT);
  newtask^.TRIM_PT^.trimname:=job^.TRIM_PT^.trimname;
  newtask^.TRIM_PT^.TRIM_HEAD_PT:=NIL;
  newtask^.TRIM_PT^.trimnext:=NIL;
  CREATE_PAR_HARM_LIST(harmonics,job^.TRIM_PT^.TRIM_HEAD_PT,newtask^.TRIM_PT^.TRIM_HEAD_PT);
 END;

 varcomp_pt:=prevtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
  CREATE_VAR_HARM(harmonics,varcomp_pt,newtask^.VAR_PT,comppt);
  varcomp_pt:=varcomp_pt^.varnext
 END;

 varcomp_pt:=newtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
    if ( varcomp_pt^.Var_complex ) then begin
      varcomp_pt^.VVC_TAIL_PT:=varcomp_pt^.VVC_HEAD_PT;
    end
    else begin
      varcomp_pt^.VVR_TAIL_PT:=varcomp_pt^.VVR_HEAD_PT;
    end;
    varcomp_pt:=varcomp_pt^.varnext
 END;


 COMD_TAIL_PT:=nil;
 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',YNCOF,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 ADD_COMD(newtask,COMD_TAIL_PT);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;


{*======================================================================*}
{* third new tasks computes transformation function for harmonics TF    *}
{* TF from current on Yn/Gn terminals to voltage at vnb - vnc           *}
{* all computings are made under previouse task condition               *}

 NEW(newtask^.tpt);
 prevtask:=newtask;
 newtask:=newtask^.tpt;
 newtask^.numberMajor:=job^.numberMajor+1;
 newtask^.numberMiddle:=0;
 newtask^.numberMinor:=0;
 newtask^.FREQ_PT:=prevtask^.FREQ_PT;
 newtask^.VAR_PT:=prevtask^.VAR_PT;
 newtask^.TRIM_PT:=prevtask^.TRIM_PT;
 newtask^.TUN_PT:=prevtask^.TUN_PT;

 newtask^.COFF_PT:=NIL;
 newtask^.COMD_PT:=NIL;
 newtask^.CDEF_PT:=NIL;
 newtask^.PAR_PT:=NIL;

 varcomp_pt:=newtask^.VAR_PT;
 WHILE varcomp_pt<>NIL DO
 BEGIN
    if ( varcomp_pt^.Var_complex ) then begin
      varcomp_pt^.VVC_TAIL_PT:=varcomp_pt^.VVC_HEAD_PT;
    end
    else begin
      varcomp_pt^.VVR_TAIL_PT:=varcomp_pt^.VVR_HEAD_PT;
    end;
    varcomp_pt:=varcomp_pt^.varnext
 END;

{*  DL=D(ynna+ynnb)(vnb+vnc)                                                 *}

 STR(ynna,sx);
 STR(ynnb,sy);
 sz1:=CONCAT('(',sx,'+',sy,')');
 STR(vnb,sx);
 STR(vnc,sy);
 sz2:=CONCAT('(',sx,'+',sy,')');
 dstr:=CONCAT(sz1,sz2);
 listptr:=newtask^.COMD_PT;
 CLEAR_LINE;
 lstr:=CONCAT('$TF DL',dstr,'/','DM(0+0)(0+0) ');
 INSERT(lstr,line,1);
 COMD_TAIL_PT:=nil;
 ADD_COMD(newtask,COMD_TAIL_PT);
 CLEAR_LINE;
 IF mcad THEN
 BEGIN
  INSERT('$MCAD  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;
 IF trace THEN
 BEGIN
  INSERT('$TRACE  ',line,1);
  ADD_COMD(newtask,COMD_TAIL_PT);
  CLEAR_LINE
 END;

 newtask^.tpt:=tasktail;
 END;

END.
