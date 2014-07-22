UNIT TASK8;

interface

USES
 SysUtils,
 TYPE8,VAR8,VAREXT8,LINE8,DATAIO8;

PROCEDURE EXTRACT_JOB_NAME;
PROCEDURE EXTRACT_COMPONENTS;
PROCEDURE INCLUDE_INC_FILES;
PROCEDURE EXTRACT_LIB_FILES;
PROCEDURE EXTRACT_LIB_CALLS;
PROCEDURE EXTRACT_TASKS;
PROCEDURE TRACE_DATA;

PROCEDURE ADD_CDEF(tp:taskpt; VAR cp:listapt);
PROCEDURE ADD_COMD(tp:taskpt; VAR cp:listapt);
PROCEDURE ADD_COFFACTOR(j:taskpt; VAR d_ptr:dptr);

PROCEDURE ADD2REAL_LIST(VAR head,tail:listbpt; dbval:DOUBLE);
PROCEDURE ADD2CPLX_LIST(VAR head,tail:listcpt; val_re,val_im:DOUBLE);

PROCEDURE ADD2COFF_LIST(VAR head,tail:drpt; reval,imval:DOUBLE);

PROCEDURE ADD_LISTA(head:listapt; VAR tail:listapt);

PROCEDURE CREATE_PROBES_TF_TASKS;

PROCEDURE PARSE_DEF(job:taskpt);

PROCEDURE SET_VARIABLE_COMP(job:taskpt);
FUNCTION MATCH_TRIM (job:taskpt; par_name:symb): trimpt;
PROCEDURE SET_TUNED_VALUES(job:taskpt);
PROCEDURE LINK_TUN_VALUES(job:taskpt);
PROCEDURE LINK_VAR_VALUES(job:taskpt);

PROCEDURE DEFINE_FREQ(job:taskpt);

PROCEDURE SET_PAR_COMP(job:taskpt);
FUNCTION  UPDATE_PAR_COMP(job:taskpt):boolean;

FUNCTION COMPLEX_ELEMENT_COUNTER( clpt:listcpt):integer;
FUNCTION REAL_ELEMENT_COUNTER( rlpt:listbpt):integer;

implementation
USES Amp8_main;
{***************************************************************************}

PROCEDURE TRACE_DATA;
BEGIN
 LIST_BATCH;
 OUT_FLUSH;
 LIST_LIB_FILES;
 OUT_FLUSH;
 LIST_LIB_CALLS;
 OUT_FLUSH;
 LIST_LIB_DEF;
 OUT_FLUSH;
 LIST_COMP;
 OUT_FLUSH;
 LIST_LIB_COMP;
 OUT_FLUSH;
 LIST_TASKS;
 OUT_FLUSH;
END;

{***************************************************************************}

PROCEDURE ADD2REAL_LIST(VAR head,tail:listbpt;dbval:DOUBLE);
BEGIN
 IF head=NIL THEN
 BEGIN
  NEW(head);
  tail:=head
 END
 ELSE
 BEGIN
  NEW(tail^.vpt);
  tail:=tail^.vpt
 END;
 tail^.value:=dbval;
 tail^.vpt:=NIL
END;

{***************************************************************************}

PROCEDURE ADD2CPLX_LIST(VAR head,tail:listcpt; val_re,val_im:DOUBLE);
BEGIN
 IF head=NIL THEN
 BEGIN
  NEW(head);
  tail:=head
 END
 ELSE
 BEGIN
  NEW(tail^.cvpt);
  tail:=tail^.cvpt
 END;
 tail^.valre:=val_re;
 tail^.valim:=val_im;
 tail^.cvpt:=NIL;
END;

{***************************************************************************}
 FUNCTION REAL_ELEMENT_COUNTER( rlpt:listbpt):integer;

 BEGIN
    Result:=0;
    while ( rlpt<>NIL ) do begin
      Result:=Result+1;
      rlpt:=rlpt^.vpt;
    end;
 END;

{***************************************************************************}
 FUNCTION COMPLEX_ELEMENT_COUNTER( clpt:listcpt):integer;

 BEGIN
    Result:=0;
    while ( clpt<>NIL ) do begin
      Result:=Result+1;
      clpt:=clpt^.cvpt;
    end;
 END;


{***************************************************************************}


PROCEDURE ADD2COFF_LIST(VAR head,tail:drpt; reval,imval:DOUBLE);
BEGIN
 IF head=NIL THEN
 BEGIN
  NEW(head);
  tail:=head
 END
 ELSE
 BEGIN
  NEW(tail^.drptn);
  tail:=tail^.drptn
 END;
 tail^.red:=reval;
 tail^.imd:=imval;
 tail^.drptn:=NIL
END;



{***************************************************************************}

 PROCEDURE EXTRACT_JOB_NAME;
 CONST
  maxlenght=75;
 VAR
  lptr:listpt;

 BEGIN

  lptr:=BATCH_PT;
  REPEAT
  BEGIN
   JOB_NAME:='NUL';
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF line[cpt1]='*'THEN
   BEGIN
    cpt2:=FND(CHR(13),CHR(13),cpt1);
    IF xx OR ((cpt2-cpt1)>maxlenght) THEN
     cpt2:=maxlenght+cpt1;
    JOB_NAME:=COPY(line,cpt1+1,cpt2-1);
   END
   ELSE
    JOB_NAME:='NONAME';
   lptr:=lptr^.lptt
  END
  UNTIL (lptr=NIL) OR (JOB_NAME<>'NUL');
  {
  IF JOB_NAME<>'NUL' THEN
  BEGIN
   SETWD(1);
   WRITE(JOB_NAME);
  END
  }
 END;

{***************************************************************************}

 PROCEDURE EXTRACT_COMPONENTS;
 VAR
  lptr:listpt;
  lptra:listapt;

 BEGIN

  lptr:=BATCH_PT;
  WHILE NOT(lptr=NIL) DO
  BEGIN
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF NOT xx THEN
   BEGIN
    IF IS_COMP_NAME(line[cpt1]) THEN
    BEGIN
     IF COMP_PT=NIL THEN
     BEGIN
      NEW(COMP_PT);
      lptra:=COMP_PT
     END
     ELSE
     BEGIN
      NEW(lptra^.lpt);
      lptra:=lptra^.lpt
     END;
     lptra^.oneline:=line;
     lptra^.lpt:=NIL;
    END
   END;
   lptr:=lptr^.lptt
  END;

 END;

 {***************************************************************************}

 PROCEDURE EXTRACT_INCSTR;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('$','$',1);
  cpt2:=cpt1;
  cpt1:=FND(' ',' ',cpt2);
  cpt2:=cpt1;
  cpt1:=FND('!','z',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  IF NOT(xx) THEN
   INCSTR:=COPY(line,cpt1,cpt2)
  ELSE
   INCSTR:='NULL'
 END;

{***************************************************************************}

 PROCEDURE INCLUDE_INC_FILES;
 Var
  lptr:listpt;
  pre_lptr,post_lptr:listpt;
  CheckLine:string;
  inc_flag:boolean;

 BEGIN
  lptr:=BATCH_PT;
  while not(lptr=NIL) do begin
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   inc_flag:=FALSE;
   if not xx then begin
    if (line[cpt1]='$') and ((line[cpt1+1]='i')or(line[cpt1+1]='I'))then begin
      CheckLine:=UpperCase(line);
      if ( Pos('INC',CheckLine)<>0 ) then begin
        EXTRACT_INCSTR;
        if ( INCSTR <>'NULL' ) then begin
          INC_HEAD_PT:=nil; INC_TAIL_PT:=nil;
          INC_OPEN;
          INC_READ;
          INC_CLOSE;
          inc_flag:=TRUE;  { remove $INC line and link the whole file so that $INC could be nested :-) }
          if ( lptr=BATCH_PT ) then begin
            post_lptr:=lptr^.lptt;
            BATCH_PT:=INC_HEAD_PT;
            post_lptr^.lpth:=INC_TAIL_PT;
            INC_TAIL_PT^.lptt:=post_lptr;
          end
          else begin
            pre_lptr:=lptr^.lpth;
            post_lptr:=lptr^.lptt;
            pre_lptr^.lptt:=INC_HEAD_PT;
            INC_HEAD_PT^.lpth:=pre_lptr;
            post_lptr^.lpth:=INC_TAIL_PT;
            INC_TAIL_PT^.lptt:=post_lptr;
          end;
          lptr:=INC_HEAD_PT; { inc_flag prevents change }
        end
        else begin
          DATA_ERROR;
        end
      end;
    end;
   end;
   if not (inc_flag) then lptr:=lptr^.lptt
  end

 END;

 {***************************************************************************}

 PROCEDURE EXTRACT_FILELINESSTR;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('!','z',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  IF NOT(xx) THEN
   FILELINESSTR:=COPY(line,cpt1,cpt2)
  ELSE
   FILELINESSTR:='NULL'
 END;

{***************************************************************************}

 PROCEDURE EXTRACT_LIB_FILES;
 VAR
  lptr:listpt;
  lptra:listapt;
  cond:BOOLEAN;

 BEGIN
  lptr:=BATCH_PT;
  WHILE NOT(lptr=NIL) DO
  BEGIN
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF NOT xx THEN
   BEGIN
    IF (line[cpt1]='$')THEN
    BEGIN
     cond:=(((line[cpt1+1]='l')or(line[cpt1+1]='L')) and ((line[cpt1+2]='i')or(line[cpt1+2]='I')) );
     IF cond THEN
     BEGIN
      IF LIB_FILES_PT=NIL THEN
      BEGIN
       NEW(LIB_FILES_PT);
       lptra:=LIB_FILES_PT;
      END
      ELSE
      BEGIN
       NEW(lptra^.lpt);
       lptra:=lptra^.lpt
      END;
      lptra^.oneline:=line;
      lptra^.lpt:=NIL
     END
    END
   END;
   lptr:=lptr^.lptt
  END

 END;

{***************************************************************************}

 PROCEDURE EXTRACT_LIB_CALLS;
 VAR
  lptr:listpt;
  lptra:listapt;

 BEGIN
  lptr:=BATCH_PT;
  WHILE NOT(lptr=NIL) DO
  BEGIN
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF NOT xx THEN
   BEGIN
    IF (line[cpt1]='x') or (line[cpt1]='X') THEN
    BEGIN
     IF LIB_CALLS_PT=NIL THEN
     BEGIN
       NEW(LIB_CALLS_PT);
       lptra:=LIB_CALLS_PT;
      END
      ELSE
      BEGIN
       NEW(lptra^.lpt);
       lptra:=lptra^.lpt
      END;
      lptra^.oneline:=line;
      lptra^.lpt:=NIL
    END
   END;
   lptr:=lptr^.lptt
  END

 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE EXTRACT_TASKS;
 VAR
  k:INTEGER;
  lptr:listpt;
  comdpt,cdefpt:listapt;
  tlptr:taskpt;
  start,stop,newtask:BOOLEAN;

 PROCEDURE SKIP_DATA;
 BEGIN
  WHILE NOT((lptr=NIL)OR(start)) DO
  BEGIN
    line:=lptr^.oneline;
    xx:=FALSE;
    cpt1:=FND('!','z',1);
    cpt2:=cpt1;
    IF NOT xx THEN
      IF (line[cpt1]='$') THEN
      {* $end or $END  *}
      start:=(line[cpt1+1]='e')OR(line[cpt1+1]='E');
    lptr:=lptr^.lptt
  END
 END;


 BEGIN

  lptr:=BATCH_PT;
  start:=FALSE;
  comdpt:=NIL;
  cdefpt:=NIL;
  k:=1;

  SKIP_DATA;

  IF start THEN BEGIN

    REPEAT BEGIN
      newtask:=TRUE;
      REPEAT BEGIN
      stop:=FALSE;
      line:=lptr^.oneline;
      xx:=FALSE;
      cpt1:=FND('!','~',1);
      cpt2:=cpt1;
      IF NOT xx THEN
      BEGIN
        if ( (line[cpt1] = '$') and (newtask) ) then begin
          if  TASK_PT=NIL then begin
            NEW(TASK_PT);
            tlptr:=TASK_PT;
          end
          else begin
            NEW(tlptr^.tpt);
            tlptr:=tlptr^.tpt
          end;
          tlptr^.numberMajor:=k;
          tlptr^.numberMiddle:=0;
          tlptr^.numberMinor:=0;
          tlptr^.COMD_PT:=NIL;
          tlptr^.CDEF_PT:=NIL;
          tlptr^.COFF_PT:=NIL;
          tlptr^.FREQ_PT:=NIL;
          tlptr^.VAR_PT:=NIL;
          tlptr^.TRIM_PT:=NIL;
          tlptr^.TUN_PT:=NIL;
          tlptr^.PAR_PT:=NIL;
          tlptr^.tpt:=NIL;
          newtask:=FALSE;
        end;
        CASE line[cpt1] OF
        '$'    : case line[cpt1+1] of
               'd','D':ADD_CDEF(tlptr,cdefpt); {* $D()() *}
               'f','F': case line[cpt1+2] of
                        'r','R':ADD_CDEF(tlptr,cdefpt); {* $FREQ  *}
                        'o','O':ADD_COMD(tlptr,comdpt); {* $FORMAT  *}
                        end;
               'v','V':ADD_CDEF(tlptr,cdefpt); {* $VAR   *}
               'p','P':ADD_CDEF(tlptr,cdefpt); {* $PAR   *}

               't','T': case line[cpt1+2] of
                        'u','U': ADD_CDEF(tlptr,cdefpt); {* $TUN *}
                        'r','R': case line[cpt1+3] of
                                 'a','A': ADD_COMD(tlptr,comdpt); {* $TRACE *}
                                 'i','I': ADD_CDEF(tlptr,cdefpt); {* $TRIM  *}
                                 end;
                        'f','F': ADD_COMD(tlptr,comdpt); {* $TF *}
                        end;

               'm','M': case line[cpt1+2] of
                        'a','A': ADD_CDEF(tlptr,cdefpt); {* $MAT  *}
                        'o','O': ADD_CDEF(tlptr,cdefpt); {* $MOD  *}
                        'c','C': ADD_COMD(tlptr,comdpt); {* $MCAD *}
                        end;
               's','S':ADD_COMD(tlptr,comdpt); {* $SENS *}
               'h','H':ADD_COMD(tlptr,comdpt); {* $HARM *}
               'g','G':ADD_COMD(tlptr,comdpt); {* $GR, $GS*}
               'r','R': case line[cpt1+2] of
                        'a','A': ADD_COMD(tlptr,comdpt);        {* $RAW *}
                        'u','U': begin
                                  ADD_COMD(tlptr,comdpt);       {* $RUN *}
                                  stop:=TRUE;
                                 end;
                        end;
                 end;
         '.','+','-','0','1','2','3','4','5','6','7','8','9' : begin
                        ADD_CDEF(tlptr,cdefpt); {* might be DATA continuation line *}
                  end;
         '*'    : begin
                          { skip comments}
                  end
         else begin
              DATA_ERROR;
          end
        END;
      END;
      lptr:=lptr^.lptt
    END UNTIL ((stop) OR (lptr=NIL));
    k:=k+1
   END UNTIL (lptr=NIL)

  END
  ELSE
  BEGIN
   ERROR(9,0) {* NO $END STATEMENT *}
  END
 END;

{***************************************************************************}

 PROCEDURE ADD_CDEF(tp:taskpt; VAR cp:listapt);
 BEGIN
  WITH tp^ DO
  BEGIN
   IF CDEF_PT=NIL THEN
   BEGIN
    NEW(CDEF_PT);
    cp:=CDEF_PT;
   END
   ELSE
   BEGIN
    NEW(cp^.lpt);
    cp:=cp^.lpt
   END;
   cp^.oneline:=line;
   cp^.lpt:=NIL;
  END
 END;

{***************************************************************************}

 PROCEDURE ADD_COMD(tp:taskpt; VAR cp:listapt);
 BEGIN
  WITH tp^ DO
  BEGIN
   IF COMD_PT=NIL THEN
   BEGIN
    NEW(COMD_PT);
    cp:=COMD_PT;
   END
   ELSE
   BEGIN
    NEW(cp^.lpt);
    cp:=cp^.lpt
   END;
   cp^.oneline:=line;
   cp^.lpt:=NIL;
  END
 END;

{***************************************************************************}

 PROCEDURE ADD_LISTA(head:listapt; VAR tail:listapt);
 BEGIN
   if head=NIL then begin
    NEW(head);
    tail:=head;
   end
   else begin
    NEW(tail^.lpt);
    tail:=tail^.lpt
   end;
   tail^.oneline:=line;
   tail^.lpt:=NIL;
 END;

{***************************************************************************}

 PROCEDURE ADD_COFFACTOR(j:taskpt; VAR d_ptr:dptr);
 VAR
  dcounter:INTEGER;
 BEGIN
  WITH j^ DO
  BEGIN
   IF COFF_PT=NIL THEN
   BEGIN
    NEW(COFF_PT);
    d_ptr:=COFF_PT;
    D_head:=COFF_PT;
    D_tail:=D_head;
    dcounter:=1;
    d_ptr^.d:=dcounter;
   END
   ELSE
   BEGIN
    dcounter:=D_tail^.d;
    NEW(d_ptr^.dnext);
    d_ptr:=d_ptr^.dnext;
    dcounter:=dcounter+1;
    d_ptr^.d:=dcounter;
    D_tail:=d_ptr
   END;

   d_ptr^.dnext:=NIL;
   d_ptr^.CF_PT:=NIL;
   cpt1:=FND('D','D',1);
   IF NOT xx THEN
   BEGIN
    cpt2:=FND('(','(',cpt1);
    TXT(cpt1,cpt2-1);
    d_ptr^.dname:=nsymb;
    d_ptr^.ddim:=0;
    xx:=FALSE;
    d_ptr^.ctb:=FALSE;
    d_ptr^.ctb0:=FALSE;
    d_ptr^.dcreb:=FALSE;
    REPEAT
    WITH d_ptr^ DO
    BEGIN
     ddim:=ddim+1;
     cpt2:=FND('(','(',cpt1);
     cpt1:=FND('0','9',cpt2);
     cpt2:=cpt1;
     RIN;
     wr[1,ddim]:=itg;
     cpt2:=FND('+','+',cpt1);
     cpt1:=FND('0','9',cpt2);
     cpt2:=cpt1;
     RIN;
     wr[2,ddim]:=itg;
     cpt2:=FND('(','(',cpt1);
     cpt1:=FND('0','9',cpt2);
     cpt2:=cpt1;
     RIN;
     kl[1,ddim]:=itg;
     cpt2:=FND('+','+',cpt1);
     cpt1:=FND('0','9',cpt2);
     cpt2:=cpt1;
     RIN;
     kl[2,ddim]:=itg;
     cpt2:=FND(')',')',cpt1);
     cpt1:=cpt2;
    END
   UNTIL (line[cpt2+1]<>',');
   IF xx THEN DATA_ERROR
  END
  ELSE
   DATA_ERROR
  END
 END;


{***************************************************************************}
{ search for matching para for tuned                                        }
{***************************************************************************}
FUNCTION MATCH_TRIM (job:taskpt; par_name:symb): trimpt;
VAR
  triming_pt:trimpt;
BEGIN
  Result:=NIL;
  triming_pt:=job^.TRIM_PT;
  while triming_pt<>NIL do
  begin
    if ( triming_pt^.trimname = par_name  ) then
    begin
       Result:=triming_pt;
       Break;
    end;
    triming_pt:=triming_pt^.trimnext;
  end;
END;

{***************************************************************************}
{ calculate values from para to tuned                                       }
{***************************************************************************}

PROCEDURE CALC_TUNED_VALUES(tun_pt:tunpt; trim_pt:trimpt);
VAR
  triming_pt:listbpt;
BEGIN
  triming_pt:=trim_pt^.TRIM_HEAD_PT;
  tun_pt^.TUN_HEAD_PT:=nil;
  while triming_pt<>NIL do
  begin
      ADD2REAL_LIST(tun_pt^.TUN_HEAD_PT, tun_pt^.TUN_TAIL_PT,
       (tun_pt^.tunconst + tun_pt^.tunvar*(triming_pt^.value)));
      triming_pt:=triming_pt^.vpt;
  end;

END;

{***************************************************************************}
{ assign values from para to tuned                                          }
{***************************************************************************}
PROCEDURE SET_TUNED_VALUES(job:taskpt);
VAR
  tun_pt:tunpt;
  trim_pt:trimpt;
BEGIN
  tun_pt:=job^.TUN_PT;
  while tun_pt<>NIL do
  begin
    trim_pt:=MATCH_TRIM(job, tun_pt^.tunpara);
    if ( trim_pt <> NIL ) then begin
       CALC_TUNED_VALUES(tun_pt,trim_pt);
    end
    else
    begin
      line:=tun_pt^.line_pt^.oneline;
      PARA_ERROR; {'11:NO MATCHING PARA FOR TUNED ELEMENT'}
    end;
    tun_pt:=tun_pt^.tunnext;
  end
END;

{***************************************************************************}
{ search for matching TUN model                                             }
{***************************************************************************}
FUNCTION MATCH_TUN (job:taskpt; tun_name:symb): tunpt;
VAR
  tun_pt:tunpt;
BEGIN
  Result:=NIL;
  tun_pt:=job^.TUN_PT;
  while tun_pt<>NIL do
  begin
    if ( tun_pt^.tunname = tun_name ) then
    begin
       Result:=tun_pt;
       Break;
    end;
    tun_pt:=tun_pt^.tunnext;
  end;
END;

{***************************************************************************}
{ link values from TUN definitions with components declared as TUNed        }
{***************************************************************************}
PROCEDURE LINK_TUN_VALUES(job:taskpt);
VAR
 tun_pt:tunpt;

 y_ptr:yptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = TUNED) then begin
          tun_pt := MATCH_TUN(job, y_ptr^.yref);
          if ( tun_pt<>NIL ) then begin
              y_ptr^.ytunpt:=tun_pt;
          end
          else begin
            line:=y_ptr^.line_pt^.oneline;
            TUN_ERROR; {'14:NO MATCHING MODEL FOR TUN ELEMENT'}
          end
       end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = TUNED) then begin
          tun_pt := MATCH_TUN(job, g_ptr^.gref);
          if ( tun_pt<>NIL ) then begin
              g_ptr^.gtunpt:=tun_pt;
          end
          else begin
            line:=g_ptr^.line_pt^.oneline;
            TUN_ERROR; {'14:NO MATCHING MODEL FOR TUN ELEMENT'}
          end
       end;
       g_ptr:=g_ptr^.gnext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = TUNED) then begin
          tun_pt := MATCH_TUN(job, r_ptr^.rref);
          if ( tun_pt<>NIL ) then begin
              r_ptr^.rtunpt:=tun_pt;
          end
          else begin
            line:=r_ptr^.line_pt^.oneline;
            TUN_ERROR; {'14:NO MATCHING MODEL FOR TUN ELEMENT'}
          end
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = TUNED) then begin
          tun_pt := MATCH_TUN(job, c_ptr^.cref);
          if ( tun_pt<>NIL ) then begin
              c_ptr^.ctunpt:=tun_pt;
          end
          else begin
            line:=c_ptr^.line_pt^.oneline;
            TUN_ERROR; {'14:NO MATCHING MODEL FOR TUN ELEMENT'}
          end
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = TUNED) then begin
          tun_pt := MATCH_TUN(job, l_ptr^.lref);
          if ( tun_pt<>NIL ) then begin
              l_ptr^.ltunpt:=tun_pt;
          end
          else begin
            line:=l_ptr^.line_pt^.oneline;
            TUN_ERROR; {'14:NO MATCHING MODEL FOR TUN ELEMENT'}
          end
       end;
       l_ptr:=l_ptr^.lnext;
  end;


END;



{***************************************************************************}
{ search for matching VAR model                                             }
{***************************************************************************}
FUNCTION MATCH_VAR (job:taskpt; var_name:symb): varpt;
VAR
  var_pt:varpt;
BEGIN
  Result:=NIL;
  var_pt:=job^.VAR_PT;
  while var_pt<>NIL do
  begin
    if ( var_pt^.varname = var_name ) then
    begin
       Result:=var_pt;
       Break;
    end;
    var_pt:=var_pt^.varnext;
  end;
END;


{***************************************************************************}
{ link values from VAR definitions with components declared as VARiable     }
{***************************************************************************}
PROCEDURE LINK_VAR_VALUES(job:taskpt);
VAR
 var_pt:varpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN
  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, y_ptr^.yref);
          if ( var_pt<>NIL ) then begin
            y_ptr^.yvarpt :=var_pt;
          end
          else begin
            line:=y_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, g_ptr^.gref);
          if ( var_pt<>NIL ) then begin
            g_ptr^.gvarpt:=var_pt;
          end
          else begin
            line:=g_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       g_ptr:=g_ptr^.gnext;
  end;

  z_ptr:=Z_head;
  while z_ptr<>NIL do
  begin
       if ( z_ptr^.zvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, z_ptr^.zref);
          if ( var_pt<>NIL ) then begin
            z_ptr^.zvarpt:=var_pt;
          end
          else begin
            line:=z_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, r_ptr^.rref);
          if ( var_pt<>NIL ) then begin
            r_ptr^.rvarpt:=var_pt;
          end
          else begin
            line:=r_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, c_ptr^.cref);
          if ( var_pt<>NIL ) then begin
            c_ptr^.cvarpt:=var_pt;
          end
          else begin
            line:=c_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = VARIABLE) then begin
          var_pt := MATCH_VAR(job, l_ptr^.lref);
          if ( var_pt<>NIL ) then begin
            l_ptr^.lvarpt:=var_pt;
          end
          else begin
            line:=l_ptr^.line_pt^.oneline;
            VAR_ERROR; {'12:NO MATCHING MODEL FOR VAR ELEMENT'}
          end
       end;
       l_ptr:=l_ptr^.lnext;
  end;

END;

{***************************************************************************}

 PROCEDURE READ_LOG_VALUES(VAR HEAD,TAIL:listbpt);
 VAR
  value,startval,endvalue,valmax:DOUBLE;
  fp,np:INTEGER;  { first_power;number of decades }
  mp,power:INTEGER; { multpiplier }
 BEGIN

   {*  LOG start_value end_value  (>0)                   *}

   RRL;
   startval:=rr;
   IF (NOT xx) AND (rr<>0.0) THEN fp:=ROUND(LN(rr)/LN(10));
   RRL;
   endvalue:=rr;

   IF NOT xx THEN np:=ROUND(itg);
   xx:=(xx)OR(np<0);
   IF NOT xx THEN
   BEGIN
    power:=0;
    valmax:=endvalue;
    mp:=1;
    REPEAT
    BEGIN
     value:=fm[mp]*startval*Exp(power*Ln(10));
     ADD2REAL_LIST(HEAD,TAIL,value);
     mp:=mp+1;
     IF mp>indexmax THEN
     BEGIN
      mp:=1;power:=power+1
     END
    END
    UNTIL (value>=valmax)
   END
   ELSE
    DATA_ERROR
 END;


{***************************************************************************}

 PROCEDURE READ_LIN_VALUES(VAR HEAD,TAIL:listbpt);
 VAR
  startv,endv,stepv,value:DOUBLE;
 BEGIN

   {* read start, end and step  *}
   RRL;
   startv:=rr;
   RRL;
   endv:=rr;
   RRL;
   stepv:=rr;
   xx:=(xx)OR(((stepv<0.0)AND(endv>startv))OR(stepv>0.0)AND(endv<startv));
   IF NOT xx THEN
   BEGIN
    value:=startv-stepv;
    REPEAT
    BEGIN
     value:=value+stepv;
     ADD2REAL_LIST(HEAD,TAIL,value)
    END
    UNTIL (value>=endv)
   END
   ELSE
    DATA_ERROR
 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}
{ I know this is mess due to lptr (this is a TYPE!!!)
  READREAL but this is fix - to be solved in future }

 PROCEDURE PARSE_DEF(job:taskpt);
 VAR
  lptr,ldefptr:listapt;
  coff_tail_pt:dptr;
  var_tail_pt:varpt;
  tun_tail_pt:tunpt;
  trim_tail_pt:trimpt;
  c:char;

{***************************************************************************}
{***************************************************************************}

 PROCEDURE READREAL;
 VAR
 c:char;
 line_ptr:listapt;
 BEGIN
   line_ptr:=lptr; { use local copy }
   cpt1:=FND('!','~',cpt2);
   c:=line[cpt1];
   if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
      xx:=FALSE;
      RRL;
   end
   else begin
      if ( line_ptr^.lpt<>NIL ) then begin
        line_ptr:=lptr^.lpt;
        line:=line_ptr^.oneline;
        cpt2:=1;
        cpt1:=FND('!','~',cpt2);
        c:=line[cpt1];
        if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
            xx:=FALSE;
            RRL;
            if (not xx) then lptr:=line_ptr; { valid data found so update line}
        end
        else begin
          xx:=TRUE;
        end
      end
      else begin
         xx:=TRUE;
      end

   end
 END;



{***************************************************************************}

 PROCEDURE READ_LIST_VALUES(VAR HEAD,TAIL:listbpt);
 VAR
  value:DOUBLE;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('0','9',cpt1);
  READREAL;
  IF NOT xx THEN
  BEGIN
   REPEAT
   BEGIN
    value:=rr;
    ADD2REAL_LIST(HEAD,TAIL,value);
    READREAL;
   END
   UNTIL (xx)
  END
  ELSE
   DATA_ERROR
 END;

{***************************************************************************}

 PROCEDURE READ_CLIST_VALUES(VAR HEAD,TAIL:listcpt);
 VAR
  rvalue:DOUBLE;
  ivalue:DOUBLE;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('+','9',cpt1);
  READREAL;
  IF NOT xx THEN
  BEGIN
   REPEAT
   BEGIN
    rvalue:=rr;
    READREAL;
    ivalue:=rr;
    ADD2CPLX_LIST(HEAD,TAIL,rvalue,ivalue);
    READREAL;
   END
   UNTIL (xx)
  END
  ELSE
   DATA_ERROR
 END;


{***************************************************************************}

{ $VAR varname LIST .............. }
{ $VAR varname CLIST .............. }
{ $VAR varname LIN start stop step }
{ $VAR varname LOG start decades   }
{ $VAR varname FILE   }
{ $VAR varname CFILE   }

PROCEDURE ADD_VARCOMP(j:taskpt; VAR HEAD_PT,TAIL_PT:varpt);
VAR
  CheckLine:string;
  lptr_ref:listapt;
 BEGIN
  if HEAD_PT=NIL then {* add new var def *}
  begin
    NEW(HEAD_PT);
    TAIL_PT:=HEAD_PT;
  end
  else
  begin
    NEW(TAIL_PT^.varnext);
    TAIL_PT:=TAIL_PT^.varnext
  end;
  TAIL_PT^.varnext:=NIL;

  { CheckLine is used only for finding list type (i.e LOG LIN LIST) }
  { UpperCase changes m->M so cannot be used for value reading      }
  CheckLine:=UpperCase(line);

  xx:=FALSE;
  cpt1:=FND(' ',' ',cpt1);
  cpt1:=FND('!','z',cpt1);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  TAIL_PT^.varname:=nsymb;
  { move pointer beyond list_type (i.e LOG LIN LIST FILE) }
  cpt1:=FND('!','z',cpt2);
  cpt1:= FND(' ',' ',cpt1);
  cpt2:=cpt1;

  if ( Pos('LOG',CheckLine)<>0 ) then
  begin
    TAIL_PT^.Var_complex:=FALSE;     { default is not complex }
    TAIL_PT^.VVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVR_TAIL_PT:=NIL;
    READ_LOG_VALUES(TAIL_PT^.VVR_HEAD_PT,TAIL_PT^.VVR_TAIL_PT);
  end
  else if ( Pos('LIN',CheckLine)<>0 ) then
  begin
    TAIL_PT^.Var_complex:=FALSE;     { default is not complex }
    TAIL_PT^.VVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVR_TAIL_PT:=NIL;
    READ_LIN_VALUES(TAIL_PT^.VVR_HEAD_PT,TAIL_PT^.VVR_TAIL_PT)
  end
  else if ( Pos('CLIST',CheckLine)<>0 ) then   { CLIST must be before because LIST is a subset of CLIST}
  begin
    TAIL_PT^.Var_complex:=TRUE;     { default is not complex }
    TAIL_PT^.VVC_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVC_TAIL_PT:=NIL;
    READ_CLIST_VALUES(TAIL_PT^.VVC_HEAD_PT,TAIL_PT^.VVC_TAIL_PT)
  end
  else if ( Pos('LIST',CheckLine)<>0 ) then
  begin
    TAIL_PT^.Var_complex:=FALSE;     { default is not complex }
    TAIL_PT^.VVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVR_TAIL_PT:=NIL;
    READ_LIST_VALUES(TAIL_PT^.VVR_HEAD_PT,TAIL_PT^.VVR_TAIL_PT)
  end
  else if ( Pos('CFILE',CheckLine)<>0 ) then
  begin
    TAIL_PT^.Var_complex:=TRUE;     { default is not complex }
    TAIL_PT^.VVC_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVC_TAIL_PT:=NIL;
    EXTRACT_FILELINESSTR;
    if ( FILELINESSTR <>'NULL' ) then begin
      FILELINES_HEAD_PT:=nil;
      FILELINES_OPEN;
      FILELINES_READ;
      FILELINES_CLOSE;
      lptr_ref:=lptr;
      lptr:=FILELINES_HEAD_PT;
      line:=lptr^.oneline;
      READ_CLIST_VALUES(TAIL_PT^.VVC_HEAD_PT,TAIL_PT^.VVC_TAIL_PT);
      lptr:=lptr_ref;
    end
    else begin
      DATA_ERROR;
    end
  end
  else if ( Pos('FILE',CheckLine)<>0 ) then
  begin
    TAIL_PT^.Var_complex:=FALSE;     { default is not complex }
    TAIL_PT^.VVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.VVR_TAIL_PT:=NIL;
    EXTRACT_FILELINESSTR;
    if ( FILELINESSTR <>'NULL' ) then begin
      FILELINES_HEAD_PT:=nil;
      FILELINES_OPEN;
      FILELINES_READ;
      FILELINES_CLOSE;
      lptr_ref:=lptr;
      lptr:=FILELINES_HEAD_PT;
      line:=lptr^.oneline;
      READ_LIST_VALUES(TAIL_PT^.VVR_HEAD_PT,TAIL_PT^.VVR_TAIL_PT);
      lptr:=lptr_ref;
    end
    else begin
      DATA_ERROR;
    end
  end
  else
   DATA_ERROR;
 END;

{***************************************************************************}
{ $TUN tunedname tunedpara LIN tunedconst tundedvar }
{***************************************************************************}

PROCEDURE ADD_TUNEDCOMP(j:taskpt; VAR HEAD_PT,TAIL_PT:tunpt);
VAR
CheckLine:string;
BEGIN
  if HEAD_PT=NIL then {* add new TUN def *}
  begin
    NEW(HEAD_PT);
    TAIL_PT:=HEAD_PT;
  end
  else
  begin
    NEW(TAIL_PT^.tunnext);
    TAIL_PT:=TAIL_PT^.tunnext
  end;
  TAIL_PT^.tunnext:=NIL;
  TAIL_PT^.TUN_HEAD_PT:=NIL;       {* reset new list *}
  TAIL_PT^.TUN_TAIL_PT:=NIL;

  CheckLine:=UpperCase(line);
  xx:=FALSE;
  cpt1:=FND(' ',' ',cpt1);
  cpt1:=FND('!','z',cpt1);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  TAIL_PT^.tunname:=nsymb;
  cpt1:=FND('!','z',cpt2);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  TAIL_PT^.tunpara:=nsymb;

  if ( Pos('LIN',CheckLine)<>0 ) then
  begin
   cpt1:=Pos('LIN',CheckLine);
   cpt2:= FND(' ',' ',cpt1);
   xx:=FALSE;
   RRL; TAIL_PT^.tunconst:=rr;
   RRL; TAIL_PT^.tunvar:=rr;
   IF xx THEN DATA_ERROR
  end
  else
   DATA_ERROR;

END;


{***************************************************************************}
{* $PARA eps LIST[LOG][LIN] ..........                                 *}
 PROCEDURE ADD_TRIM(j:taskpt; VAR HEAD_PT,TAIL_PT:trimpt);

 VAR
  c:CHAR;

 BEGIN
  if HEAD_PT=NIL then {* add new TUN def *}
  begin
    NEW(HEAD_PT);
    TAIL_PT:=HEAD_PT;
  end
  else
  begin
    NEW(TAIL_PT^.trimnext);
    TAIL_PT:=TAIL_PT^.trimnext
  end;

  TAIL_PT^.trimnext:=NIL;
  TAIL_PT^.TRIM_HEAD_PT:=NIL;       {* reset new list *}
  TAIL_PT^.TRIM_TAIL_PT:=NIL;

  xx:=FALSE;
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('!','z',cpt2);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  TAIL_PT^.trimname:=nsymb;
  cpt1:=FND('!','z',cpt2);
  IF NOT xx THEN
  BEGIN
   c:=line[cpt1];
   cpt2:=FND(' ',' ',cpt1);
   IF (c='l') OR (c='L') THEN
   BEGIN
    c:=line[cpt1+1];
    IF (c='o') OR (c='O') THEN
     READ_LOG_VALUES(TAIL_PT^.TRIM_HEAD_PT, TAIL_PT^.TRIM_TAIL_PT)
    ELSE
    BEGIN
     IF (c='i') OR (c='I') THEN
     BEGIN
      c:=line[cpt1+2];
      CASE c OF
       'n','N':READ_LIN_VALUES(TAIL_PT^.TRIM_HEAD_PT, TAIL_PT^.TRIM_TAIL_PT);
       's','S':READ_LIST_VALUES(TAIL_PT^.TRIM_HEAD_PT, TAIL_PT^.TRIM_TAIL_PT);
      ELSE
       DATA_ERROR
      END
     END
    END
   END
   ELSE
    DATA_ERROR
  END
  ELSE
   DATA_ERROR
 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 BEGIN

  coff_tail_pt:=job^.COFF_PT;
  var_tail_pt:=job^.VAR_PT;
  tun_tail_pt:=job^.TUN_PT;
  trim_tail_pt:=job^.TRIM_PT;
  lptr:=job^.CDEF_PT;

  WHILE lptr<>NIL DO
  BEGIN
   line:=lptr^.oneline;
   ldefptr:=lptr;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   if line[cpt1]='$' then begin
        c:=line[cpt1+1];
        CASE c OF
        'd','D': ADD_COFFACTOR(job,coff_tail_pt);                        { $D      }
        'v','V':begin
                  ADD_VARCOMP(job,job^.VAR_PT,var_tail_pt);               { $VAR    }
                  var_tail_pt^.line_pt:=ldefptr;
                end;
        't','T': CASE line[cpt1+2] OF
                 'u','U': begin
                            ADD_TUNEDCOMP(job,job^.TUN_PT,tun_tail_pt);        { $TUN    }
                            tun_tail_pt^.line_pt:=ldefptr;
                          end;
                 'r','R': begin
                            ADD_TRIM(job,job^.TRIM_PT,trim_tail_pt);          { $TRIM   }
                            trim_tail_pt^.line_pt:=ldefptr;
                          end;
                 END;
        END;
   end;
   lptr:=lptr^.lpt
  END
 END;


{***************************************************************************}
{ READREAL, READLIST - LOCAL COPY IS REQUIRED !!! }
{***************************************************************************}
PROCEDURE DEFINE_FREQ(job:taskpt);

 VAR
  lptr:listapt;
  freq_tail_pt:listbpt;
  freq_list_pt:listbpt;
  c:char;

{***************************************************************************}
{***************************************************************************}

 PROCEDURE READREAL;
 VAR
 c:char;
 line_ptr:listapt;
 BEGIN
   line_ptr:=lptr; { use local copy }
   cpt1:=FND('!','~',cpt2);
   c:=line[cpt1];
   if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
      xx:=FALSE;
      RRL;
   end
   else begin
      if ( line_ptr^.lpt<>NIL ) then begin
        line_ptr:=lptr^.lpt;
        line:=line_ptr^.oneline;
        cpt2:=1;
        cpt1:=FND('!','~',cpt2);
        c:=line[cpt1];
        if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
            xx:=FALSE;
            RRL;
            if (not xx) then lptr:=line_ptr; { valid data found so update line}
        end
        else begin
          xx:=TRUE;
        end
      end
      else begin
         xx:=TRUE;
      end

   end
 END;



{***************************************************************************}

 PROCEDURE READ_LIST_VALUES(VAR HEAD,TAIL:listbpt);
 VAR
  value:DOUBLE;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('0','9',cpt1);
  READREAL;
  IF NOT xx THEN
  BEGIN
   REPEAT
   BEGIN
    value:=rr;
    ADD2REAL_LIST(HEAD,TAIL,value);
    READREAL;
   END
   UNTIL (xx)
  END
  ELSE
   DATA_ERROR
 END;


{***************************************************************************}

 PROCEDURE ADD_FREQENCY(j:taskpt; VAR FHEAD,FTAIL:listbpt);
 VAR
  CheckLine:string;
  lptr_ref:listapt;
 BEGIN

  xx:=FALSE;               {cpt1 points at $ in $FREQ}
  cpt1:=FND(' ',' ',cpt1);
  cpt1:=FND('!','z',cpt1); {cpt1 points at first char LIN LOG LIST FILE}
  if not (xx) then begin
   cpt2:=FND(' ',' ',cpt1); {cpt1,cpt2 point after LIN LOG LIST FILE}
   cpt1:=cpt1;
   CheckLine:=UpperCase(line);
    if ( Pos('LOG',CheckLine)<>0 ) then begin
      READ_LOG_VALUES(FHEAD,FTAIL)
    end
    else if ( Pos('LIN',CheckLine)<>0 ) then begin
      READ_LIN_VALUES(FHEAD,FTAIL);
    end
    else if ( Pos('LIST',CheckLine)<>0 ) then begin
      READ_LIST_VALUES(FHEAD,FTAIL);
    end
    else if ( Pos('FILE',CheckLine)<>0 ) then begin
      EXTRACT_FILELINESSTR;
      if ( FILELINESSTR <>'NULL' ) then begin
        FILELINES_HEAD_PT:=nil;
        FILELINES_OPEN;
        FILELINES_READ;
        FILELINES_CLOSE;
        lptr_ref:=lptr;
        lptr:=FILELINES_HEAD_PT;
        line:=lptr^.oneline;
        READ_LIST_VALUES(FHEAD,FTAIL);
        lptr:=lptr_ref;
      end
      else begin
        DATA_ERROR;
      end
    end
    else begin
      DATA_ERROR;
    end;
  end
  else begin
    DATA_ERROR;
  end;

 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 BEGIN
  freq_list_pt:=job^.FREQ_PT;
  job^.FREQ_PT:=NIL;
  freq_tail_pt:=job^.FREQ_PT;
  lptr:=job^.CDEF_PT;
  {D_C:=FALSE;}
  WHILE lptr<>NIL DO
  BEGIN
   line:=lptr^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   if line[cpt1]='$' then begin
        c:=line[cpt1+1];
        CASE c OF
        'f','F': ADD_FREQENCY(job,job^.FREQ_PT,freq_tail_pt);            { $FREQ   }
        END;
   end;
   lptr:=lptr^.lpt
  END;

    if (freq_list_pt<>NIL) then begin
     if ( job^.FREQ_PT = NIL) then begin
       job^.FREQ_PT := freq_list_pt;  { Freq was set by parent task as SCONV/RCONV SENS or DISTO }
     end
     else begin
      freq_tail_pt^.vpt:=freq_list_pt; {  }
     end
    end;



 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE ADD_NEW_CDEF( VAR head_pt,tail_pt:listapt);
 BEGIN
   IF head_pt=NIL THEN
   BEGIN
    NEW(head_pt);
    tail_pt:=head_pt;
   END
   ELSE
   BEGIN
    NEW(tail_pt^.lpt);
    tail_pt:=tail_pt^.lpt;
   END;
   tail_pt^.oneline:=line;
   tail_pt^.lpt:=NIL;
 END;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 PROCEDURE FIND_COMD_TAIL( head_pt:listapt; VAR tail_pt:listapt);
 BEGIN
   tail_pt:=head_pt;
   if ( tail_pt<>nil ) then begin
      while ( tail_pt^.lpt<>nil ) do begin
          tail_pt:=tail_pt^.lpt;
      end;
   end

 END;

{***************************************************************************}
{ TASK_TAIL_PT^ := TASK_ref_pt^;  copy mother to child task                 }
{ but create new instances - coping pointers to lists is not a good idea    }
{***************************************************************************}
 PROCEDURE REPLICATE_TASK(NEW_TASK_PT:taskpt; TASK_REF_PT:taskpt );
 VAR
  CDEF_TAIL_PT,COMD_TAIL_PT:listapt;
  cdef_pt, comd_pt: listapt;
  BEGIN

   NEW_TASK_PT^.COMD_PT:=NIL;
   NEW_TASK_PT^.CDEF_PT:=NIL;
   NEW_TASK_PT^.COFF_PT:=NIL;
   NEW_TASK_PT^.FREQ_PT:=NIL;
   NEW_TASK_PT^.VAR_PT:=NIL;
   NEW_TASK_PT^.TRIM_PT:=NIL;
   NEW_TASK_PT^.TUN_PT:=NIL;

   comd_pt:=TASK_REF_PT^.COMD_PT;
   while ( comd_pt<>nil ) do begin
      line:=comd_pt^.oneline;
      ADD_COMD(NEW_TASK_PT, COMD_TAIL_PT);
      comd_pt:=comd_pt^.lpt;
   end;
   cdef_pt:=TASK_REF_PT^.CDEF_PT;
   while ( cdef_pt<>nil ) do begin
      line:=cdef_pt^.oneline;
      ADD_CDEF(NEW_TASK_PT, CDEF_TAIL_PT);
      cdef_pt:=cdef_pt^.lpt;
   end;

 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

PROCEDURE CREATE_PROBES_TF_TASKS;
VAR
  TASK_TAIL_PT:taskpt;
  TASK_ref_pt:taskpt;
  tf_line_pt,COMD_TAIL_PT,COMD_CHAIN_PT:listapt;
  task_counter:integer;
BEGIN

  if ( probes_flag ) then begin

     TASK_ref_pt:=TASK_PT; { this must be task with no $TF since it will be copied to child task }
     TASK_PT:=NIL;
     task_counter:=1;
     while ( TASK_ref_pt<> NIL ) do begin
          tf_line_pt:=PROBES_TF_PT;
          while ( tf_line_pt<>NIL ) do begin
              if  TASK_PT=NIL then begin
                NEW(TASK_PT);
                TASK_TAIL_PT:=TASK_PT;
              end
              else begin
                NEW(TASK_TAIL_PT^.tpt);
                TASK_TAIL_PT:=TASK_TAIL_PT^.tpt
              end;
              REPLICATE_TASK(TASK_TAIL_PT, TASK_ref_pt );
              TASK_TAIL_PT^.tpt := NIL;      { here - not sooner to prevent false links }
              TASK_TAIL_PT^.numberMajor:=TASK_ref_pt^.numberMajor;
              TASK_TAIL_PT^.numberMiddle:=TASK_ref_pt^.numberMiddle;
              TASK_TAIL_PT^.numberMinor:=task_counter;
              task_counter:=task_counter+1;
              COMD_CHAIN_PT:=TASK_TAIL_PT^.COMD_PT;
              TASK_TAIL_PT^.COMD_PT:=NIL;
              line:=tf_line_pt^.oneline;
              ADD_COMD(TASK_TAIL_PT, COMD_TAIL_PT); {add $TF from head}
              COMD_TAIL_PT^.lpt:=COMD_CHAIN_PT;     {chain tail to head}
              tf_line_pt:=tf_line_pt^.lpt;
          end;
        TASK_ref_pt:=TASK_ref_pt^.tpt;
     end;

  end;

END;

{***************************************************************************}

PROCEDURE SET_VARIABLE_COMP(job:taskpt);
BEGIN
  PARSE_DEF(job);         { translate CDEF_PT declarations $VAR $PAR $TUN into usable structures }
  SET_TUNED_VALUES(job);  { create the list of values for TUN model - associate with para values }
  LINK_TUN_VALUES(job);   { create the link between Y,G,R,C,L and values of the TUN model }
  LINK_VAR_VALUES(job);
END;


{***************************************************************************}

 FUNCTION PAR_COUNT( ppt:parpt):integer;

 BEGIN
    if ( ppt^.PAR_complex ) then begin
      Result:= COMPLEX_ELEMENT_COUNTER (ppt^.PVC_HEAD_PT);
    end
    else begin
      Result:= REAL_ELEMENT_COUNTER (ppt^.PVR_HEAD_PT);
    end

 END;

{***************************************************************************}
{ search for matching PAR model                                             }
{***************************************************************************}
FUNCTION MATCH_PAR (job:taskpt; par_name:symb): parpt;
VAR
  par_pt:parpt;
BEGIN
  Result:=NIL;
  par_pt:=job^.PAR_PT;
  while par_pt<>NIL do
  begin
    if ( par_pt^.parname = par_name ) then
    begin
       Result:=par_pt;
       Break;
    end;
    par_pt:=par_pt^.parnext;
  end;
END;


{***************************************************************************}
{ link values from PAR definitions with components declared as PAR          }
{***************************************************************************}
PROCEDURE LINK_PAR_VALUES(job:taskpt);
VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN
  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := MATCH_PAR(job, y_ptr^.yref);
          if ( par_pt<>NIL ) then begin
            y_ptr^.yparpt :=par_pt;
          end
          else begin
            line:=y_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = PARAM) then begin
          par_pt := MATCH_PAR(job, g_ptr^.gref);
          if ( par_pt<>NIL ) then begin
            g_ptr^.gparpt:=par_pt;
          end
          else begin
            line:=g_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       g_ptr:=g_ptr^.gnext;
  end;

  z_ptr:=Z_head;
  while z_ptr<>NIL do
  begin
       if ( z_ptr^.zvar = PARAM) then begin
          par_pt := MATCH_PAR(job, z_ptr^.zref);
          if ( par_pt<>NIL ) then begin
            z_ptr^.zparpt:=par_pt;
          end
          else begin
            line:=z_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := MATCH_PAR(job, r_ptr^.rref);
          if ( par_pt<>NIL ) then begin
            r_ptr^.rparpt:=par_pt;
          end
          else begin
            line:=r_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := MATCH_PAR(job, c_ptr^.cref);
          if ( par_pt<>NIL ) then begin
            c_ptr^.cparpt:=par_pt;
          end
          else begin
            line:=c_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := MATCH_PAR(job, l_ptr^.lref);
          if ( par_pt<>NIL ) then begin
            l_ptr^.lparpt:=par_pt;
          end
          else begin
            line:=l_ptr^.line_pt^.oneline;
            NO_MATCHING_PAR_ERROR;
          end
       end;
       l_ptr:=l_ptr^.lnext;
  end;

END;


{***************************************************************************}
{ link values from PAR definitions with components declared as PAR          }
{***************************************************************************}
PROCEDURE SET_PAR_VALUES(job:taskpt);
VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN

  par_pt:=job^.PAR_PT;                { check $PAR definitions consistency - equal number of elements }
  while par_pt<>NIL do begin
    if ( par_pt^.PAR_complex  ) then begin
      par_pt^.PVC_CURR_PT:=par_pt^.PVC_HEAD_PT;
    end
    else begin
      par_pt^.PVR_CURR_PT:=par_pt^.PVR_HEAD_PT;
    end;
    par_pt:=par_pt^.parnext;
  end;


  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := y_ptr^.yparpt ;
          if ( par_pt^.PAR_complex ) then begin
            y_ptr^.yvre := par_pt^.PVC_CURR_PT^.valre;
            y_ptr^.yvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            y_ptr^.yvre := par_pt^.PVR_CURR_PT^.value;
            y_ptr^.yvim := 0.0;
          end
       end;
       y_ptr:=y_ptr^.ynext;
  end;

  g_ptr:=G_head;
  while g_ptr<>NIL do
  begin
       if ( g_ptr^.gvar = PARAM) then begin
          par_pt := g_ptr^.gparpt ;
          if ( par_pt^.PAR_complex ) then begin
            g_ptr^.gvre := par_pt^.PVC_CURR_PT^.valre;
            g_ptr^.gvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            g_ptr^.gvre := par_pt^.PVR_CURR_PT^.value;
            g_ptr^.gvim := 0.0;
          end
       end;
       g_ptr:=g_ptr^.gnext;
  end;

  z_ptr:=Z_head;
  while z_ptr<>NIL do
  begin
       if ( z_ptr^.zvar = PARAM) then begin
          par_pt := z_ptr^.zparpt ;
          if ( par_pt^.PAR_complex ) then begin
            z_ptr^.zvre := par_pt^.PVC_CURR_PT^.valre;
            z_ptr^.zvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            z_ptr^.zvre := par_pt^.PVR_CURR_PT^.value;
            z_ptr^.zvim := 0.0;
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := r_ptr^.rparpt ;
          r_ptr^.rv := par_pt^.PVR_CURR_PT^.value;
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := c_ptr^.cparpt ;
          c_ptr^.cv := par_pt^.PVR_CURR_PT^.value;
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := l_ptr^.lparpt ;
          l_ptr^.lv := par_pt^.PVR_CURR_PT^.value;
       end;
       l_ptr:=l_ptr^.lnext;
  end;

END;

{***************************************************************************}

FUNCTION UPDATE_PAR_COMP (job:taskpt): boolean;

VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 param_updated:boolean;

BEGIN

  param_updated:=FALSE;

  par_pt:=job^.PAR_PT;                { $PAR definitions consistency was checked before  }
  while par_pt<>NIL do begin
    if ( par_pt^.PAR_complex  ) then begin
      par_pt^.PVC_CURR_PT:=par_pt^.PVC_CURR_PT^.cvpt;
      if ( par_pt^.PVC_CURR_PT <> NIL ) then begin
        param_updated:=TRUE;
      end
    end
    else begin
      par_pt^.PVR_CURR_PT:=par_pt^.PVR_CURR_PT^.vpt;
      if ( par_pt^.PVR_CURR_PT <> NIL ) then begin
        param_updated:=TRUE;
      end
    end;
    par_pt:=par_pt^.parnext;
  end;

  if ( param_updated ) then begin
    y_ptr:=Y_head;
    while y_ptr<>NIL do
    begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := y_ptr^.yparpt ;
          if ( par_pt^.PAR_complex ) then begin
            y_ptr^.yvre := par_pt^.PVC_CURR_PT^.valre;
            y_ptr^.yvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            y_ptr^.yvre := par_pt^.PVR_CURR_PT^.value;
            y_ptr^.yvim := 0.0;
          end
       end;
       y_ptr:=y_ptr^.ynext;
    end;

    g_ptr:=G_head;
    while g_ptr<>NIL do
    begin
       if ( g_ptr^.gvar = PARAM) then begin
          par_pt := g_ptr^.gparpt ;
          if ( par_pt^.PAR_complex ) then begin
            g_ptr^.gvre := par_pt^.PVC_CURR_PT^.valre;
            g_ptr^.gvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            g_ptr^.gvre := par_pt^.PVR_CURR_PT^.value;
            g_ptr^.gvim := 0.0;
          end
       end;
       g_ptr:=g_ptr^.gnext;
    end;

    z_ptr:=Z_head;
    while z_ptr<>NIL do
    begin
       if ( z_ptr^.zvar = PARAM) then begin
          par_pt := z_ptr^.zparpt ;
          if ( par_pt^.PAR_complex ) then begin
            z_ptr^.zvre := par_pt^.PVC_CURR_PT^.valre;
            z_ptr^.zvim := par_pt^.PVC_CURR_PT^.valim;
          end
          else begin
            z_ptr^.zvre := par_pt^.PVR_CURR_PT^.value;
            z_ptr^.zvim := 0.0;
          end
       end;
       z_ptr:=z_ptr^.znext;
    end;

    r_ptr:=R_head;
    while r_ptr<>NIL do
    begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := r_ptr^.rparpt ;
          r_ptr^.rv := par_pt^.PVR_CURR_PT^.value;
       end;
       r_ptr:=r_ptr^.rnext;
    end;

    c_ptr:=C_head;
    while c_ptr<>NIL do
    begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := c_ptr^.cparpt ;
          c_ptr^.cv := par_pt^.PVR_CURR_PT^.value;
       end;
       c_ptr:=c_ptr^.cnext;
    end;

    l_ptr:=L_head;
    while l_ptr<>NIL do
    begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := l_ptr^.lparpt ;
          l_ptr^.lv := par_pt^.PVR_CURR_PT^.value;
       end;
       l_ptr:=l_ptr^.lnext;
    end;

  end;
  
  if (( job^.PAR_PT<>NIL ) and param_updated )then begin
    job^.numberMiddle := job^.numberMiddle + 1; { this is a next task with parameter set }
  end;
  
  Result:=param_updated;

END;



{***************************************************************************}
{ READREAL, READLIST - LOCAL COPY IS REQUIRED !!! }
{***************************************************************************}
PROCEDURE SET_PAR_COMP(job:taskpt);

 VAR
  lptr,ldefptr:listapt;
  PAR_TAIL_PT,par_pt:parpt;
  c:char;
  par_cnt, ref_par_cnt:integer;

{***************************************************************************}
{***************************************************************************}

 PROCEDURE READREAL;
 VAR
 c:char;
 line_ptr:listapt;
 BEGIN
   line_ptr:=lptr; { use local copy }
   cpt1:=FND('!','~',cpt2);
   c:=line[cpt1];
   if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
      xx:=FALSE;
      RRL;
   end
   else begin
      if ( line_ptr^.lpt<>NIL ) then begin
        line_ptr:=lptr^.lpt;
        line:=line_ptr^.oneline;
        cpt2:=1;
        cpt1:=FND('!','~',cpt2);
        c:=line[cpt1];
        if (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) then begin
            xx:=FALSE;
            RRL;
            if (not xx) then lptr:=line_ptr; { valid data found so update line}
        end
        else begin
          xx:=TRUE;
        end
      end
      else begin
         xx:=TRUE;
      end

   end
 END;



{***************************************************************************}

 PROCEDURE READ_LIST_VALUES(VAR HEAD,TAIL:listbpt);
 VAR
  value:DOUBLE;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('0','9',cpt1);
  READREAL;
  IF NOT xx THEN
  BEGIN
   REPEAT
   BEGIN
    value:=rr;
    ADD2REAL_LIST(HEAD,TAIL,value);
    READREAL;
   END
   UNTIL (xx)
  END
  ELSE
   DATA_ERROR
 END;

{***************************************************************************}

 PROCEDURE READ_CLIST_VALUES(VAR HEAD,TAIL:listcpt);
 VAR
  rvalue:DOUBLE;
  ivalue:DOUBLE;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('+','9',cpt1);
  READREAL;
  IF NOT xx THEN
  BEGIN
   REPEAT
   BEGIN
    rvalue:=rr;
    READREAL;
    ivalue:=rr;
    ADD2CPLX_LIST(HEAD,TAIL,rvalue,ivalue);
    READREAL;
   END
   UNTIL (xx)
  END
  ELSE
   DATA_ERROR
 END;


{***************************************************************************}
 { $PAR parname LIST
   $PAR parname CLIST
   $PAR parname LIN
   $PAR parname LOG
   $PAR parname FILE
   $PAR parname CFILE
 }

 PROCEDURE ADD_PAR(j:taskpt; VAR HEAD_PT,TAIL_PT:parpt);
 VAR
  CheckLine:string;
  lptr_ref:listapt;

 BEGIN

  if HEAD_PT=NIL then {* add new var def *}
  begin
    NEW(HEAD_PT);
    TAIL_PT:=HEAD_PT;
  end
  else
  begin
    NEW(TAIL_PT^.parnext);
    TAIL_PT:=TAIL_PT^.parnext
  end;
  TAIL_PT^.parnext:=NIL;

  { CheckLine is used only for finding list type (i.e LOG LIN LIST) }
  { UpperCase changes m->M so cannot be used for value reading      }
  CheckLine:=UpperCase(line);

  xx:=FALSE;
  cpt1:=FND(' ',' ',cpt1);
  cpt1:=FND('!','z',cpt1);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  TAIL_PT^.parname:=nsymb;
  { move pointer beyond list_type (i.e LOG LIN LIST FILE) }
  cpt1:=FND('!','z',cpt2);
  cpt1:= FND(' ',' ',cpt1);
  cpt2:=cpt1;

  if ( Pos('LOG',CheckLine)<>0 ) then
  begin
    TAIL_PT^.PAR_complex:=FALSE;     { default is not complex }
    TAIL_PT^.PVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVR_TAIL_PT:=NIL;
    READ_LOG_VALUES(TAIL_PT^.PVR_HEAD_PT,TAIL_PT^.PVR_TAIL_PT);
  end
  else if ( Pos('LIN',CheckLine)<>0 ) then
  begin
    TAIL_PT^.PAR_complex:=FALSE;     { default is not complex }
    TAIL_PT^.PVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVR_TAIL_PT:=NIL;
    READ_LIN_VALUES(TAIL_PT^.PVR_HEAD_PT,TAIL_PT^.PVR_TAIL_PT)
  end
  else if ( Pos('CLIST',CheckLine)<>0 ) then   { CLIST must be before because LIST is a subset of CLIST}
  begin
    TAIL_PT^.PAR_complex:=TRUE;     { default is not complex }
    TAIL_PT^.PVC_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVC_TAIL_PT:=NIL;
    READ_CLIST_VALUES(TAIL_PT^.PVC_HEAD_PT,TAIL_PT^.PVC_TAIL_PT)
  end
  else if ( Pos('LIST',CheckLine)<>0 ) then
  begin
    TAIL_PT^.PAR_complex:=FALSE;     { default is not complex }
    TAIL_PT^.PVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVR_TAIL_PT:=NIL;
    READ_LIST_VALUES(TAIL_PT^.PVR_HEAD_PT,TAIL_PT^.PVR_TAIL_PT)
  end
  else if ( Pos('CFILE',CheckLine)<>0 ) then
  begin
    TAIL_PT^.PAR_complex:=TRUE;     { default is not complex }
    TAIL_PT^.PVC_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVC_TAIL_PT:=NIL;
    EXTRACT_FILELINESSTR;
    if ( FILELINESSTR <>'NULL' ) then begin
      FILELINES_HEAD_PT:=nil;
      FILELINES_OPEN;
      FILELINES_READ;
      FILELINES_CLOSE;
      lptr_ref:=lptr;
      lptr:=FILELINES_HEAD_PT;
      line:=lptr^.oneline;
      READ_CLIST_VALUES(TAIL_PT^.PVC_HEAD_PT,TAIL_PT^.PVC_TAIL_PT);
      lptr:=lptr_ref;
    end
    else begin
      DATA_ERROR;
    end
  end
  else if ( Pos('FILE',CheckLine)<>0 ) then
  begin
    TAIL_PT^.PAR_complex:=FALSE;     { default is not complex }
    TAIL_PT^.PVR_HEAD_PT:=NIL;       {* reset new list *}
    TAIL_PT^.PVR_TAIL_PT:=NIL;
    EXTRACT_FILELINESSTR;
    if ( FILELINESSTR <>'NULL' ) then begin
      FILELINES_HEAD_PT:=nil;
      FILELINES_OPEN;
      FILELINES_READ;
      FILELINES_CLOSE;
      lptr_ref:=lptr;
      lptr:=FILELINES_HEAD_PT;
      line:=lptr^.oneline;
      READ_LIST_VALUES(TAIL_PT^.PVR_HEAD_PT,TAIL_PT^.PVR_TAIL_PT);
      lptr:=lptr_ref;
    end
    else begin
      DATA_ERROR;
    end
  end
  else
   DATA_ERROR;

 END;


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

 BEGIN

  job^.PAR_PT:=NIL;           { fetch $PAR definitions }
  PAR_TAIL_PT:=job^.PAR_PT;
  lptr:=job^.CDEF_PT;
  while lptr<>NIL do begin
   line:=lptr^.oneline;
   ldefptr:=lptr;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   if line[cpt1]='$' then begin
        c:=line[cpt1+1];
        case c of
        'p','P': begin
                  ADD_PAR(job,job^.PAR_PT,PAR_TAIL_PT);            { $PAR   }
                  PAR_TAIL_PT^.line_pt:=ldefptr;
                 end;
        end;
   end;
   lptr:=lptr^.lpt;
  end;

  if ( job^.PAR_PT<>NIL ) then begin

    par_pt:=job^.PAR_PT;   { check $PAR definitions consistency - equal number of elements }
    while (par_pt<>NIL) do begin
      par_cnt:=PAR_COUNT(par_pt);
      if ( par_pt=job^.PAR_PT ) then begin
        ref_par_cnt:=par_cnt;
      end
      else begin
        if ( par_cnt<>ref_par_cnt ) then begin
          CLEAR_LINE;
          INSERT(par_pt^.line_pt^.oneline+'<>'+job^.PAR_PT^.line_pt^.oneline,line,1);
          PAR_COUNT_ERROR;
        end;
      end;
      par_pt:=par_pt^.parnext;
    end;
  end;
  
  { link YGRLC with $PAR - this procedure must be run for  job^.PAR_PT = nil to find errors }
  LINK_PAR_VALUES(job); 
      
  if ( job^.PAR_PT<>NIL ) then begin
    job^.numberMiddle := 1; { this is a task with first parameter set }
    SET_PAR_VALUES(job);
  end;

 END;



END.










