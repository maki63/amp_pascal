
UNIT DATAIO8;

interface

USES
 SysUtils,
 TYPE8,VAR8,LINE8,VAREXT8;



PROCEDURE IN_OPEN;
PROCEDURE IN_SET_UP;
PROCEDURE IN_CLOSE;

PROCEDURE INC_OPEN;
PROCEDURE INC_CLOSE;
PROCEDURE INC_READ;

PROCEDURE FILELINES_OPEN;
PROCEDURE FILELINES_CLOSE;
PROCEDURE FILELINES_READ;

PROCEDURE OUT_OPEN;
PROCEDURE OUT_SET_UP;
PROCEDURE OUT_CLOSE;
PROCEDURE OUT_FLUSH;

PROCEDURE LIB_OPEN;
PROCEDURE LIB_CLOSE;

PROCEDURE READ_LINE(VAR f:text);
PROCEDURE READ_DATA_LINE;
PROCEDURE READ_BATCH;
PROCEDURE EXPAND_SEPARATED_COMMANDS;

PROCEDURE READ_LISTA(VAR f:TEXT;VAR head:listapt);
PROCEDURE LIST_BATCH;
PROCEDURE LIST_LISTA(head:listapt);
PROCEDURE LIST_COMP;
PROCEDURE LIST_LIB_COMP;
PROCEDURE LIST_LIB_FILES;
PROCEDURE LIST_LIB_CALLS;
PROCEDURE LIST_LIB_DEF;
PROCEDURE LIST_TASKS;
PROCEDURE TRACE_TASK(job:taskpt);
PROCEDURE LIST_VARYING_COMP(j:taskpt);
PROCEDURE TRACE_LIB;

PROCEDURE LIST_PAR_COMP(j:taskpt);
PROCEDURE LIST_MCAD_PAR_COMP(j:taskpt; var FTEXT:text);


PROCEDURE LIST_MAT_COMP;
PROCEDURE LIST_EXTENDED_COMP;
PROCEDURE LIST_EXPANDED_COMP;
PROCEDURE LIST_MATRIX;

PROCEDURE LIST_DEBUG_INFO (str:string);

implementation

USES Amp8_main;
{***************************************************************************}

 PROCEDURE IN_OPEN;
 VAR
  err:INTEGER;
 BEGIN
  INFO('READING DATA :'+INPSTR);
 {$I-}
  ASSIGNFile(DATA,INPSTR);
  RESET(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(2,err);
  END
 END;

{***************************************************************************}

 PROCEDURE IN_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+INPSTR);
 {$I-}
  CLOSEFile(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(5,err);
  END;
 END;

{***************************************************************************}

 PROCEDURE INC_OPEN;
 VAR
  err:INTEGER;
 BEGIN
  INFO('READING DATA :'+INCSTR);
 {$I-}
  ASSIGNFile(DATA,INCSTR);
  RESET(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(2,err);
  END
 END;

{***************************************************************************}

 PROCEDURE INC_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+INCSTR);
 {$I-}
  CLOSEFile(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(5,err);
  END;
 END;

{***************************************************************************}

 PROCEDURE INC_READ;
 VAR
  listptr:listpt;
 BEGIN

  WHILE (NOT Eof(DATA)) DO
  BEGIN
   IF INC_HEAD_PT=NIL THEN
   BEGIN
    NEW(INC_HEAD_PT);
    listptr:=INC_HEAD_PT;
    listptr^.lpth:=INC_HEAD_PT;
   END
   ELSE
   BEGIN
    NEW(listptr^.lptt);
    listptr^.lptt^.lpth:=listptr^.lptt;
    listptr:=listptr^.lptt;
   END;

   READ_DATA_LINE;
   listptr^.oneline:=line;
   INC_TAIL_PT:=listptr;
   listptr^.lptt:=NIL;
  END

 END;

{***************************************************************************}

 PROCEDURE FILELINES_OPEN;
 VAR
  err:INTEGER;
 BEGIN
  INFO('READING DATA :'+FILELINESSTR);
 {$I-}
  ASSIGNFile(DATA,FILELINESSTR);
  RESET(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   FILELINESSTR:='NUL';
   ERROR(2,err);
  END
 END;

{***************************************************************************}

 PROCEDURE FILELINES_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+FILELINESSTR);
 {$I-}
  CLOSEFile(DATA);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(5,err);
  END;
   FILELINESSTR:='NUL';
 END;

{***************************************************************************}

 PROCEDURE FILELINES_READ;
 VAR
  l_ptr:listapt;
 BEGIN

  FILELINES_HEAD_PT:=NIL; { each new file creates new list }
  WHILE (NOT Eof(DATA)) DO
  BEGIN
   IF (FILELINES_HEAD_PT=nil) THEN
   BEGIN
    NEW(FILELINES_HEAD_PT);
    l_ptr:=FILELINES_HEAD_PT;
   END
   ELSE
   BEGIN
    NEW(l_ptr^.lpt);
    l_ptr:=l_ptr^.lpt;
   END;
   READ_DATA_LINE;
   l_ptr^.oneline:=line;
   l_ptr^.lpt:=nil;
  END

 END;



{***************************************************************************}

 PROCEDURE IN_SET_UP;
 BEGIN
  IF NOT (ParamCount=0) THEN
   INPSTR:=ParamStr(1)
  ELSE
   ERROR(1,0);
  INFO('OPENING INPUT:'+INPSTR);
  IN_OPEN;
 END;

{***************************************************************************}

 PROCEDURE OUT_OPEN;
 VAR
 err:INTEGER;
 BEGIN
  {$I-}
  ASSIGNFile(RESULTS,OUTSTR);
  REWRITE(RESULTS);
  {$I+}
  err:=IOResult;
  IF err<>0 THEN
  BEGIN
   ERROR(4,err)
  END
 END;

{***************************************************************************}

 PROCEDURE OUT_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+OUTSTR);
 {$I-}
  CLOSEFile(RESULTS);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(6,err);
  END;
 END;

{***************************************************************************}

 PROCEDURE OUT_FLUSH;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+OUTSTR);
 {$I-}
  CLOSEFile(RESULTS);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(6,err);
  END;
  {$I-}
  ASSIGNFile(RESULTS,OUTSTR);
  APPEND(RESULTS);
  {$I+}
  err:=IOResult;
  IF err<>0 THEN
  BEGIN
   ERROR(4,err)
  END

 END;

{***************************************************************************}

 PROCEDURE OUT_SET_UP;
 VAR p:BYTE;

 BEGIN
  IF OUTSTR='NUL' THEN
  BEGIN
   p:=POS('.',INPSTR);
   IF p<>0 THEN
    OUTSTR:=Copy(INPSTR,1,p)+'OUT'
   ELSE
    OUTSTR:=Copy(INPSTR,1,Length(INPSTR))+'.OUT'
  END;
  INFO('OPENING OUTPUT:'+OUTSTR);
  OUT_OPEN
 END;

{***************************************************************************}

 PROCEDURE LIB_OPEN;
 VAR
  err:BYTE;

 BEGIN
  INFO('OPENING:'+LIBSTR);
  {$I-}
  ASSIGNFile(LIBFILE,LIBSTR);
  RESET(LIBFILE);

  if (IOResult<>0) then begin
    if (  (LIBPATHSTR<>'') ) then begin
      INFO('FAIL OPENING:'+LIBSTR);
      INFO('TRYING PATH:'+LIBPATHSTR);
      LIBSTR:=LIBPATHSTR+'\'+LIBSTR;
      INFO('OPENING:'+LIBSTR);
      ASSIGNFile(LIBFILE,LIBSTR);
      RESET(LIBFILE);
      if (IOResult<>0) then begin
        INFO('FAIL OPENING:'+LIBSTR);
        ERROR(2,err);
      end
    end
    else begin
      INFO('FAIL OPENING:'+LIBSTR);
      INFO('NO LIBPATH:'+LIBPATHSTR);
      ERROR(2,err);
    end
  end
  {$I+}
 END;

{***************************************************************************}

 PROCEDURE LIB_CLOSE;
 VAR
  err:BYTE;
 BEGIN
  INFO('CLOSING FILE:'+LIBSTR);
  {$I-}
  CLOSEFile (LIBFILE);
  err:=IOResult;
  {$I+}
  LIBSTR:='NUL';
  IF err<>0 THEN
  BEGIN
   ERROR(5,err);
  END
 END;

{***************************************************************************}

 PROCEDURE READ_LINE(VAR f:TEXT);
 BEGIN
  CLEAR_LINE;
  READLN(f,line);
  line:=CONCAT(line,'  ')
 END;

{***************************************************************************}


 PROCEDURE READ_DATA_LINE;
 BEGIN
  CLEAR_LINE;
  READLN(DATA,line);
  line:=CONCAT(line,'  ')
 END;

{***************************************************************************}

 PROCEDURE READ_BATCH;
 VAR
  listptr:listpt;
 BEGIN

  WHILE (NOT Eof(DATA)) DO
  BEGIN
   IF BATCH_PT=NIL THEN
   BEGIN
    NEW(BATCH_PT);
    listptr:=BATCH_PT;
    listptr^.lpth:=BATCH_PT;
   END
   ELSE
   BEGIN
    NEW(listptr^.lptt);
    listptr^.lptt^.lpth:=listptr^.lptt;
    listptr:=listptr^.lptt;
   END;

   READ_DATA_LINE;
   listptr^.oneline:=line;
   listptr^.lptt:=NIL;
  END

 END;

{***************************************************************************}

 PROCEDURE EXPAND_SEPARATED_COMMANDS;
 VAR
  listptr:listpt;
  tail_ptr:listpt;
  cmdstr1, cmdstr2: string;
  len:integer;
 BEGIN

  INFO('EXPAND_SEPARATED_COMMANDS');
  listptr:=BATCH_PT;
  while listptr<>NIL do
  begin

    line:=listptr^.oneline;
    len:=length(line);

    xx:=false;

    cpt1:=FND('!','z',1);
    cpt2:=cpt1;
    if NOT xx then
    begin
      if (line[cpt1]='$') then
      begin
        cpt2:=FND(';',';',cpt1);
        if NOT xx then
        begin
            {* there are commands and separator *}
            {* new lines break exisiting links, this links have to be restored later *}
            tail_ptr := listptr^.lptt;
            listptr^.lptt:=NIL;
            
            while not xx do 
            begin 
                {* split into two parts - second may contain next commas - next loop to process them*}
                cmdstr1 := COPY(line,cpt1,(cpt2-cpt1));
                {* cpt2 points to ',' find next character*}
                cpt2:=FND('!','z',cpt2+1);
                if cpt2 < len then
                begin   
                    cmdstr2 := COPY(line,cpt2,len);
                end
                else 
                begin
                    cmdstr2:=' ';
                end;
                listptr^.oneline := cmdstr1 ; {* add white char at the end - why ??? *}
                
                new(listptr^.lptt);
                listptr^.lptt^.lpth:=listptr^.lptt;
                listptr:=listptr^.lptt;
                
                listptr^.oneline := cmdstr2;
                listptr^.lptt:=NIL;             
                line:=listptr^.oneline;
                len:=length(line);
                cpt1:=FND('$','$',1);
                if NOT xx then
                begin
                    cpt2:=FND(';',';',cpt1);
                end; 
            end; {* while not xx *}
            {* restore broken links in a line list *}
            listptr^.lptt := tail_ptr;
            if listptr^.lptt<> nil then
            begin
               listptr^.lptt^.lpth := listptr;  
            end;
        end; {* FND(',') *}
      end; {* FND('$')  *}    
    end; {* not xx *}
    listptr:=listptr^.lptt;
  end; {* while listptr<>NIL do *}
 
 END;

{***************************************************************************}

 PROCEDURE LIST_BATCH;
 VAR
  listptr:listpt;
 BEGIN
  INFO('LISTING DATA');
  listptr:=BATCH_PT;
  WHILE listptr<>NIL DO
  BEGIN
   WRITELN(RESULTS,listptr^.oneline);
   listptr:=listptr^.lptt
  END
 END;

{***************************************************************************}

 PROCEDURE LIST_LISTA(head:listapt);
 VAR
  listptr:listapt;

  BEGIN
   IF OUTSTR<>'NUL' THEN
   BEGIN
    listptr:=head;
    WHILE listptr<>NIL DO
    BEGIN
     WRITELN(RESULTS,listptr^.oneline);
     listptr:=listptr^.lpt
    END
   END
   ELSE
    INFO('WARRNING:RESULTS=NUL')
  END;

{***************************************************************************}

 PROCEDURE READ_LISTA(VAR f:TEXT;VAR head:listapt);
 VAR
  listptr:listapt;
  BEGIN
    listptr:=head;
    WHILE NOT(Eof(f)) DO
    BEGIN
     IF head=NIL THEN
      BEGIN
       NEW(head);
       listptr:=head
      END
      ELSE
      BEGIN
       NEW(listptr^.lpt);
       listptr:=listptr^.lpt
      END;
      READ_LINE(f);
     listptr^.oneline:=line;
     listptr^.lpt:=NIL
    END
  END;


{***************************************************************************}

 PROCEDURE LIST_COMP;
 BEGIN
  INFO('LISTING DATA');
  WRITELN(RESULTS,'******************** COMPONENTS *************************');
  LIST_LISTA(COMP_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

{***************************************************************************}

 PROCEDURE LIST_LIB_COMP;
 BEGIN
  INFO('LISTING DATA');
  WRITELN(RESULTS,'****************** LIB--COMPONENTS **********************');
  LIST_LISTA(LIB_COMP_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

{***************************************************************************}

 PROCEDURE LIST_LIB_FILES;
 BEGIN
  INFO('LISTING LIB FILES');
  WRITELN(RESULTS,'******************** LIB--FILES *************************');
  LIST_LISTA(LIB_FILES_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

{***************************************************************************}

 PROCEDURE LIST_LIB_CALLS;
 BEGIN
  INFO('LISTING LIB CALLS');
  WRITELN(RESULTS,'******************** LIB--CALLS *************************');
  LIST_LISTA(LIB_CALLS_PT)
 END;


{***************************************************************************}

PROCEDURE LIST_LIB_DEF;
VAR
 lpt:libpt;
 dpt:devicept;
 parpt:parameterpt;

BEGIN
  INFO('LISTING LIB-DEF');
  WRITELN(RESULTS,'******************* LIB--DEFINITIONS ********************');
  lpt:=LIB_PT;
  WHILE lpt<>NIL DO
  BEGIN
   dpt:=ADDR(lpt^.def);
   WHILE dpt<>NIL DO
   BEGIN
    WRITELN(RESULTS,'name:',dpt^.devname);
    WRITELN(RESULTS,'int nodes:',dpt^.nodes);
    WRITELN(RESULTS,'parameters:');
    parpt:=dpt^.ppth;
    WHILE parpt<>NIL DO
    BEGIN
     WRITELN(RESULTS,parpt^.ps,'=',parpt^.pv);
     parpt:=parpt^.ppt
    END;
    LIST_LISTA(dpt^.llpth);
    dpt:=dpt^.devpt
   END;
  lpt:=lpt^.defpt;
  END;
  WRITELN(RESULTS,'*********************************************************');
END;

{***************************************************************************}

 PROCEDURE LIST_TASKS;
 VAR
  tp:taskpt;
 BEGIN
  INFO('LISTING TASKS');
  tp:=TASK_PT;
  WRITELN(RESULTS,'******************** TASK LIST **************************');
  WHILE tp<>NIL DO
  BEGIN
   WRITELN(RESULTS,' TASK:',tp^.numberMajor,'.',tp^.numberMiddle,'.',tp^.numberMinor,' ', tp^.task_name);
   WRITELN(RESULTS,' COMPUTE  DEF [tp^.CDEF_PT] ');
   LIST_LISTA(tp^.CDEF_PT);
   WRITELN(RESULTS,' COMANDS  [tp^.COMD_PT]    ');
   LIST_LISTA(tp^.COMD_PT);
   tp:=tp^.tpt
  END;
  WRITELN(RESULTS,'*********************************************************');
 END;
{***************************************************************************}

PROCEDURE LIST_VARYING_COMP(j:taskpt);
VAR
 var_pt:varpt;
 tun_pt:tunpt;
 trim_pt:trimpt;
 f_pt:listbpt;

BEGIN

 var_pt:=j^.VAR_PT;
 tun_pt:=j^.TUN_PT;
 trim_pt:=j^.TRIM_PT;
 IF (var_pt<>NIL) OR (tun_pt<>NIL) THEN
 BEGIN
  INFO('LISTING VARYING COMPONENTS');

{***            reset - varying pointers                          ***}

  WHILE var_pt<>NIL DO
  BEGIN
        if ( var_pt^.Var_complex ) then begin
          var_pt^.VVC_TAIL_PT:=var_pt^.VVC_HEAD_PT;
        end
        else begin
          var_pt^.VVR_TAIL_PT:=var_pt^.VVR_HEAD_PT;
        end;
   var_pt:=var_pt^.varnext
  END;


  WHILE trim_pt<>NIL DO
  BEGIN
   trim_pt^.TRIM_TAIL_PT:=trim_pt^.TRIM_HEAD_PT;
   trim_pt:=trim_pt^.trimnext
  END;


  WHILE tun_pt<>NIL DO
  BEGIN
   tun_pt^.TUN_TAIL_PT:=tun_pt^.TUN_HEAD_PT;
   tun_pt:=tun_pt^.tunnext
  END;

{***           start outer loop - frequency                            ***}
  WRITELN(RESULTS,'****************** VARYING COMPONENTS *********************');
  WRITELN(RESULTS,'TASK:',j^.numberMajor,'.',j^.numberMiddle,'.',j^.numberMinor, ' ', j^.task_name);
  f_pt:=j^.FREQ_PT;
  WHILE f_pt<>NIL DO
  BEGIN
   WRITELN(RESULTS,'FREQENCY=',f_pt^.value,'     ','OMEGA=',2*Pi*f_pt^.value);
{***           start inner loop - components                           ***}

   var_pt:=j^.VAR_PT;
   WHILE var_pt<>NIL DO
   BEGIN
    if ( var_pt^.Var_complex ) then begin
      if(var_pt^.VVC_TAIL_PT<>NIL) then begin
        WRITELN(RESULTS,var_pt^.varname,'=',var_pt^.VVC_TAIL_PT^.valre,' + i(',var_pt^.VVC_TAIL_PT^.valim,')' );
        var_pt^.VVC_TAIL_PT:=var_pt^.VVC_TAIL_PT^.cvpt;
      end
      else begin
        WRITELN(RESULTS, var_pt^.varname,'=','NOT DEFINED');
      end
    end
    else begin
      if(var_pt^.VVR_TAIL_PT<>NIL) then begin
        WRITELN(RESULTS,var_pt^.varname,'=',var_pt^.VVR_TAIL_PT^.value);
        var_pt^.VVR_TAIL_PT:=var_pt^.VVR_TAIL_PT^.vpt;
      end
      else begin
        WRITELN(RESULTS, var_pt^.varname,'=','NOT DEFINED');
      end;
    end;
    var_pt:=var_pt^.varnext;
   END;

   trim_pt:=j^.TRIM_PT;
   WHILE var_pt<>NIL DO
   BEGIN
    if(trim_pt^.TRIM_TAIL_PT<>NIL) then begin
        WRITELN(RESULTS,trim_pt^.trimname,'=',trim_pt^.TRIM_TAIL_PT^.value);
        trim_pt^.TRIM_TAIL_PT:=trim_pt^.TRIM_TAIL_PT^.vpt;
    end
    else begin
        WRITELN(RESULTS,trim_pt^.trimname,'=','NOT DEFINED');
    end;
    trim_pt:=trim_pt^.trimnext
   END;

   tun_pt:=j^.TUN_PT;
   WHILE tun_pt<>NIL DO
   BEGIN
    if(tun_pt^.TUN_TAIL_PT<>NIL) then begin
        WRITELN(RESULTS,tun_pt^.tunname,'=',tun_pt^.TUN_TAIL_PT^.value);
        tun_pt^.TUN_TAIL_PT:=tun_pt^.TUN_TAIL_PT^.vpt;
    end
    else begin
        WRITELN(RESULTS,tun_pt^.tunname,'=','NOT DEFINED');
    end;
    tun_pt:=tun_pt^.tunnext
   END;

   f_pt:=f_pt^.vpt
  END;
  WRITELN(RESULTS,'******************* END OF VARYING COMPONENTS *************');
 END;
END;


{***************************************************************************}

PROCEDURE LIST_PAR_COMP(j:taskpt);
VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN


 IF (par_pt<>NIL) THEN
 BEGIN
  INFO('LISTING PAR COMPONENTS');
  {WRITELN(RESULTS,'*******************     PAR COMPONENTS       *************');}

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := y_ptr^.yparpt ;
          if ( par_pt^.PAR_complex ) then begin
            WRITELN(RESULTS,tab_str+y_ptr^.yname,'=',par_pt^.PVC_CURR_PT^.valre,' + i(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(RESULTS,tab_str+y_ptr^.yname,'=',par_pt^.PVR_CURR_PT^.value );
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
            WRITELN(RESULTS,tab_str+g_ptr^.gname,'=',par_pt^.PVC_CURR_PT^.valre,' + i(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(RESULTS,tab_str+g_ptr^.gname,'=',par_pt^.PVR_CURR_PT^.value );
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
            WRITELN(RESULTS,tab_str+z_ptr^.zname,'=',par_pt^.PVC_CURR_PT^.valre,' + i(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(RESULTS,tab_str+z_ptr^.zname,'=',par_pt^.PVR_CURR_PT^.value );
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := r_ptr^.rparpt ;
          WRITELN(RESULTS,tab_str+r_ptr^.rname,'=',par_pt^.PVR_CURR_PT^.value );
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := c_ptr^.cparpt ;
          WRITELN(RESULTS,tab_str+c_ptr^.cname,'=',par_pt^.PVR_CURR_PT^.value );
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := l_ptr^.lparpt ;
          WRITELN(RESULTS,tab_str+l_ptr^.lname,'=',par_pt^.PVR_CURR_PT^.value );
       end;
       l_ptr:=l_ptr^.lnext;
  end;

  {WRITELN(RESULTS,'******************* END OF PAR COMPONENTS    *************');}
 END;
END;

{***************************************************************************}

PROCEDURE LIST_MCAD_PAR_COMP(j:taskpt; var FTEXT:text);
VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;

BEGIN


 IF (par_pt<>NIL) THEN
 BEGIN

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := y_ptr^.yparpt ;
          if ( par_pt^.PAR_complex ) then begin
            WRITELN(FTEXT,tab_str+y_ptr^.yname,' = ',par_pt^.PVC_CURR_PT^.valre,' + %i*(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(FTEXT,tab_str+y_ptr^.yname,' = ',par_pt^.PVR_CURR_PT^.value );
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
            WRITELN(FTEXT,tab_str+g_ptr^.gname,' = ',par_pt^.PVC_CURR_PT^.valre,' + %i*(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(FTEXT,tab_str+g_ptr^.gname,' = ',par_pt^.PVR_CURR_PT^.value );
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
            WRITELN(FTEXT,tab_str+z_ptr^.zname,' = ',par_pt^.PVC_CURR_PT^.valre,' + %i*(',par_pt^.PVC_CURR_PT^.valim,')' );
          end
          else begin
            WRITELN(FTEXT,tab_str+z_ptr^.zname,' = ',par_pt^.PVR_CURR_PT^.value );
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := r_ptr^.rparpt ;
          WRITELN(FTEXT,tab_str+r_ptr^.rname,' = ',par_pt^.PVR_CURR_PT^.value );
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := c_ptr^.cparpt ;
          WRITELN(FTEXT,tab_str+c_ptr^.cname,' = ',par_pt^.PVR_CURR_PT^.value );
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := l_ptr^.lparpt ;
          WRITELN(FTEXT,tab_str+l_ptr^.lname,' = ',par_pt^.PVR_CURR_PT^.value );
       end;
       l_ptr:=l_ptr^.lnext;
  end;

 END;
END;



{***************************************************************************}
PROCEDURE TRACE_TASK(job:taskpt);
BEGIN
 INFO('TRACING TASK');
 LIST_VARYING_COMP(job);
 WRITELN(RESULTS,'************** TRACE_TASK [job^.CDEF_PT] ****************');
 LIST_LISTA(job^.CDEF_PT);
 OUT_FLUSH;
 WRITELN(RESULTS,'*********************************************************');

END;
{***************************************************************************}
PROCEDURE TRACE_LIB;
BEGIN
 WRITELN(RESULTS,'*********************** TRACE_LIB *********************');
 LIST_LIB_FILES;
 LIST_LIB_CALLS;
 LIST_LIB_DEF;
 LIST_LIB_COMP;
 WRITELN(RESULTS,'*********************************************************');

END;

 {***************************************************************************}
 PROCEDURE LIST_EXPANDED_COMP;
 BEGIN
  INFO('LISTING EXPANDED COMP');
  WRITELN(RESULTS,'****************** EXPANDED_COMP ************************');
  LIST_LISTA(EXPANDED_COMP_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

 {***************************************************************************}
 PROCEDURE LIST_EXTENDED_COMP;
 BEGIN
  INFO('LISTING EXTENDED COMP');
  WRITELN(RESULTS,'****************** EXTENDED_COMP ************************');
  LIST_LISTA(EXTENDED_COMP_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

 {***************************************************************************}
 PROCEDURE LIST_MAT_COMP;
 BEGIN
  INFO('LISTING MAT COMP');
  WRITELN(RESULTS,'****************** MAT-COMPONENTS ***********************');
  LIST_LISTA(MAT_COMP_PT);
  WRITELN(RESULTS,'*********************************************************');
 END;

 {***************************************************************************
 MATRIX_display

 @version - 1.0
 @param   ptrA:matrixpt;
 @param   matname;string
 ***************************************************************************}

 Procedure MATRIX_display(ptrA:matrixpt;matname:string);
 VAR
  i,j:INTEGER;

 BEGIN
  while ( ptrA<>NIL ) do begin
    Writeln(RESULTS,'Freq = ',ptrA^.fmat:16);
    for  i:=1 to ptrA^.matrow do begin
      for j:=1 to ptrA^.matcol do begin
        Writeln(RESULTS, matname,'[',i:2,',',j:2,'] = (',ptrA^.ymat[i,j].Re:16,') + j*( ',ptrA^.ymat[i,j].Im:16,') ');
      end;
    end;
    ptrA:=ptrA^.next_f_mat_pt;
  end;
 END;

 {***************************************************************************
 LIST_TOUCHSTONE_DATA

 @version - 1.0
 @param   m_ptr:matptr
 ***************************************************************************}

 PROCEDURE LIST_TOUCHSTONE_DATA(m_ptr:matptr);
 BEGIN

   with (m_ptr^) do begin
    WRITELN(RESULTS,'***************************************************');
    case ( mattype ) of
    S1P: WRITELN(RESULTS,matname, ' TYPE=S1P');
    S2P: WRITELN(RESULTS,matname, ' TYPE=S2P');
    S3P: WRITELN(RESULTS,matname, ' TYPE=S3P');
    S4P: WRITELN(RESULTS,matname, ' TYPE=S4P');
    S5P: WRITELN(RESULTS,matname, ' TYPE=S5P');
    S6P: WRITELN(RESULTS,matname, ' TYPE=S6P');
    S7P: WRITELN(RESULTS,matname, ' TYPE=S7P');
    S8P: WRITELN(RESULTS,matname, ' TYPE=S8P');
    S9P: WRITELN(RESULTS,matname, ' TYPE=S9P');
    end;

    case ( mattsformat ) of
    RI: WRITELN(RESULTS,matname, ' FORMAT=RI');
    MA: WRITELN(RESULTS,matname, ' FORMAT=MA');
    DB: WRITELN(RESULTS,matname, ' FORMAT=DB');
    end;

    WRITELN(RESULTS,matname, ' Rref=',mattsRref:5);

    WRITELN(RESULTS,'****************** SnP-MATRIX *********************');
    MATRIX_display(MAT_FILE_DATA_PT,matname);
    WRITELN(RESULTS,'****************** S-MATRIX ***********************');
    MATRIX_display(MAT_S_PT,matname);
    WRITELN(RESULTS,'****************** Y-MATRIX ***********************');
    MATRIX_display(MAT_Y_PT,matname);
    WRITELN(RESULTS,'****************** Y-MATRIX interpolated **********');
    MATRIX_display(MAT_INTERP_Y_PT,matname);
    WRITELN(RESULTS,'***************************************************');
   end;
 END;

 {***************************************************************************
 LIST_TOUCHSTONE_DATA

 @version - 1.0
 @param   m_ptr:matptr
 ***************************************************************************}

 PROCEDURE LIST_YRI_DATA(m_ptr:matptr);
 BEGIN
   with (m_ptr^) do begin
    WRITELN(RESULTS,'***************************************************');
    WRITELN(RESULTS,'****************** Y-MATRIX ***********************');
    MATRIX_display(MAT_Y_PT,matname);
    WRITELN(RESULTS,'****************** Y-MATRIX interpolated **********');
    MATRIX_display(MAT_INTERP_Y_PT,matname);
    WRITELN(RESULTS,'***************************************************');
   end;
 END;

 {***************************************************************************
 LIST_MATRIX

 @version - 1.0
 @param   none
 ***************************************************************************}


 PROCEDURE LIST_MATRIX;
 VAR
  m_ptr:matptr;

 BEGIN
   INFO('LISTING MATRIX');
   WRITELN(RESULTS,'*********************************************************');
   WRITELN(RESULTS,'********************** MATRIXES *************************');
   WRITELN(RESULTS,'*********************************************************');
   m_ptr:=MAT_PT;
   while ( m_ptr<>NIL ) do begin

       with (m_ptr^) do begin
          case ( mattype ) of
           S1P, S2P, S3P, S4P, S5P, S6P, S7P, S8P, S9P: begin
                  LIST_TOUCHSTONE_DATA (m_ptr);
           end;
           YRI: begin
                  LIST_YRI_DATA (m_ptr);
           end;
           else
           begin
            WRITELN(RESULTS,'!!! ---- UNKNOWN_MAT_ERROR ------ !!!');
           end
          end;
       end;
       m_ptr:=m_ptr^.matnext;

   end;
   WRITELN(RESULTS,'*********************************************************');
   WRITELN(RESULTS,'******************** END OF MATRIXES ********************');
   WRITELN(RESULTS,'*********************************************************');

 END;

 {***************************************************************************
 LIST_DEBUG_INFO

 @version - 1.0
 @param   none
 ***************************************************************************}


 PROCEDURE LIST_DEBUG_INFO (str:string);

 BEGIN
   INFO('DEBUG_INFO'+str);
   WRITELN(RESULTS,str);
 END;

END.
