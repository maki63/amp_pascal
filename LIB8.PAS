UNIT LIB8;

interface

USES
 SysUtils,
 TYPE8,VAR8,LINE8,DATAIO8;

 PROCEDURE ADD_NEW_DEF(VAR pt:libpt);
 PROCEDURE EXTRACT_LIBSTR;
 PROCEDURE CREATE_LIB_DEF;
 PROCEDURE DEF_PARAM(VAR d:DEVICE);
 PROCEDURE DEF_NODES(VAR d:DEVICE);
 PROCEDURE SET_UP_LIB_DEF;
 PROCEDURE PREPARE_LIB_CALLS;
 PROCEDURE SET_UP_LIB_CALLS;
 PROCEDURE EXTRACT_LIB_COMP;

implementation
USES Amp8_main;

{***************************************************************************}

 PROCEDURE ADD_NEW_DEF(VAR pt:libpt);
 VAR
  line_pt:listapt;

 BEGIN

  pt^.def.llpth:=NIL;
  pt^.def.ppth:=NIL;
  pt^.def.devpt:=NIL;
  pt^.def.devname:='NUL     ';
  pt^.def.nodes:=0;
  READ_LISTA(LIBFILE,pt^.def.llpth);

  {* DISCARD COMMENTS *}

  line_pt:=pt^.def.llpth;
  WHILE line_pt<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=line_pt^.oneline;
   cpt1:=FND('!','~',1);
   IF NOT xx THEN
    IF (line[cpt1]='#') AND (line[cpt1+1]='#') THEN line_pt^.lpt:=NIL;
   line_pt:=line_pt^.lpt
  END
 END;

{***************************************************************************}

 PROCEDURE EXTRACT_LIBSTR;
 BEGIN
  xx:=FALSE;
  cpt1:=FND('$','$',1);
  cpt2:=cpt1;
  cpt1:=FND(' ',' ',cpt2);
  cpt2:=cpt1;
  cpt1:=FND('!','z',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  IF NOT(xx) THEN
   LIBSTR:=COPY(line,cpt1,cpt2)
  ELSE
   LIBSTR:='NUL'
 END;



{***************************************************************************}

 PROCEDURE CREATE_LIB_DEF;
 VAR
  pointer:listapt;
  lbpt:libpt;
 BEGIN

  pointer:=LIB_FILES_PT;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   LIBSTR:='NUL';
   EXTRACT_LIBSTR;
   LIB_OPEN;
   IF (LIB_PT= NIL) THEN
   BEGIN
    NEW(LIB_PT);
    ADD_NEW_DEF(LIB_PT);
    lbpt:=LIB_PT
   END
   ELSE
   BEGIN
    NEW(lbpt^.defpt);
    ADD_NEW_DEF(lbpt^.defpt);
    lbpt:=lbpt^.defpt
   END;
   LIB_CLOSE;
   LIBSTR:='NUL';
   lbpt^.defpt:=NIL;
   pointer:=pointer^.lpt
  END
 END;

{***************************************************************************}

 PROCEDURE DEF_PARAM(VAR d:DEVICE);
 VAR
 pointer:listapt;
 parpt:parameterpt;
 BEGIN

  pointer:=d.llpth;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF (line[cpt1]='#')AND(line[cpt1+1]=' ') THEN
   BEGIN
    cpt1:=FND('A','z',cpt2);
    cpt2:=FND(' ',' ',cpt1);
    TXT(cpt1,cpt2-1);
    d.devname:=nsymb;
    cpt1:=FND('!','z',cpt2);
    WHILE NOT xx DO
    BEGIN
     cpt2:=FND(' ',' ',cpt1);
     IF d.ppth=NIL THEN
     BEGIN
      NEW(d.ppth);
      parpt:=d.ppth
     END
     ELSE
     BEGIN
      NEW(parpt^.ppt);
      parpt:=parpt^.ppt
     END;
     TXT(cpt1,cpt2-1);
     parpt^.ps:=nsymb;
     parpt^.pv:=0;
     parpt^.ppt:=NIL;
     cpt1:=FND('A','z',cpt2)
    END;
   END;
   pointer:=pointer^.lpt
  END
 END;

{***************************************************************************}

FUNCTION COUNT_PARAMETERS:INTEGER;
VAR
  par_cnt:integer;
BEGIN
    par_cnt:=0;
    xx:=FALSE;
    while (NOT xx) do begin
      cpt1:=FND('0','z',cpt2);
      if not xx then begin
        par_cnt:=par_cnt+1;
        cpt2:=FND(CHR(13),' ',cpt1);
      end;
    end;
    Result:=par_cnt;
END;

{***************************************************************************}

 PROCEDURE DEF_NODES(VAR d:DEVICE);
 VAR
 pointer:listapt;
 max,temp:INTEGER;
 temp_cpt1,temp_cpt2,p_cnt:integer;

 FUNCTION FIND_MAX_OF(count:INTEGER):INTEGER;
 VAR
  mx:INTEGER;
 BEGIN
  mx:=0;
  xx:=FALSE;
  cpt1:=cpt2;
  REPEAT
  BEGIN
   RIN;
   IF (mx<itg) AND (NOT xx) THEN mx:=itg;
   IF xx THEN
   BEGIN
    xx:=FALSE;
    cpt1:=FND('!','z',cpt1);
    cpt2:=FND(' ',' ',cpt1);
   END;
   count:=count-1
  END
  UNTIL(count=0);
  FIND_MAX_OF:=mx
 END;

 BEGIN
  max:=0;
  pointer:=d.llpth;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=FND(' ',' ',cpt1);
   IF IS_COMP_NAME(line[cpt1]) THEN
   BEGIN
    CASE line[cpt1] OF
     'r','R','y','Y','c','C','l','L','z','Z':
           temp:=FIND_MAX_OF(2);
     'a','A':
           temp:=FIND_MAX_OF(4);
     'g','G','e','E','f','F','h','H','n','N':
           temp:=FIND_MAX_OF(4);
     't','T':
           temp:=FIND_MAX_OF(3);
     'b','B': begin
                temp_cpt1:=cpt1;
                temp_cpt2:=cpt2;
                p_cnt:=COUNT_PARAMETERS;
                cpt1:=temp_cpt1;
                cpt2:=temp_cpt2;
                temp:=FIND_MAX_OF(p_cnt-1); {last one parameter in B is a matrix name}
              end;
     ELSE
     BEGIN
     END
    END;
    IF temp>max THEN max:=temp
   END;
   pointer:=pointer^.lpt
  END;
  d.nodes:=max
 END;

{***************************************************************************}

 PROCEDURE SET_UP_LIB_DEF;
 VAR
  pointer:libpt;

 BEGIN

  pointer:=LIB_PT;
  WHILE pointer<>NIL DO
  BEGIN
   DEF_PARAM(pointer^.def);
   DEF_NODES(pointer^.def);
   pointer:=pointer^.defpt
  END
 END;

{***************************************************************************}

 PROCEDURE COPY_DEF( source:devicept; VAR dest:devicept);
 VAR
  srcpt,destpt:listapt;
 BEGIN

  srcpt:=source^.llpth;
  WHILE srcpt<>NIL DO
  BEGIN
   IF dest^.llpth=NIL THEN
   BEGIN
    NEW(dest^.llpth);
    destpt:=dest^.llpth
   END
   ELSE
   BEGIN
    NEW(destpt^.lpt);
    destpt:=destpt^.lpt
   END;
   linebuff:=srcpt^.oneline;
   destpt^.oneline:=linebuff;
   destpt^.lpt:=NIL;
   srcpt:=srcpt^.lpt;
  END

 END;

 PROCEDURE COPY_PAR( source:devicept; VAR dest:devicept);
 VAR
  srcpt,destpt:parameterpt;
 BEGIN

  srcpt:=source^.ppth;
  WHILE srcpt<>NIL DO
  BEGIN
   IF dest^.ppth=NIL THEN
   BEGIN
    NEW(dest^.ppth);
    destpt:=dest^.ppth
   END
   ELSE
   BEGIN
    NEW(destpt^.ppt);
    destpt:=destpt^.ppt
   END;
   destpt^.ps:=srcpt^.ps;
   destpt^.pv:=srcpt^.pv;
   destpt^.ppt:=NIL;
   srcpt:=srcpt^.ppt;
  END


 END;



 PROCEDURE SET_DEV_PAR( VAR dest:devicept);
 VAR
  destpt:parameterpt;
 BEGIN
  destpt:=dest^.ppth;
  WHILE destpt<>NIL DO
  BEGIN
   RIN;
   IF NOT xx THEN destpt^.pv:=itg
   ELSE
   BEGIN
    STATUS(line);
    ERROR(8,0)   {INVALID PARAMETER IN LIB_CALL}
   END;
   destpt:=destpt^.ppt
  END

 END;


 PROCEDURE PREPARE_LIB_CALLS;
 VAR
  devname,partname:symb;
  pointera:listapt;
  pointer,defpointer:libpt;
  devpointer,defpt:devicept;
  temp_cpt1,temp_cpt2:integer;
 BEGIN

  pointera:=LIB_CALLS_PT;
  WHILE pointera<>NIL DO
  BEGIN
   line:=pointera^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   IF (line[cpt1]='x') or (line[cpt1]='X') THEN
   BEGIN
    cpt2:=FND(' ',' ',cpt1);
    {IF (cpt1+1>=cpt2-1) THEN nsymb:=''
    ELSE TXT(cpt1+1,cpt2-1);}
    TXT(cpt1,cpt2-1);
    partname:=nsymb;
    temp_cpt1:=cpt1;
    temp_cpt2:=cpt2;
    cpt1:=FND('A','z',cpt2); { skip nodes }
    cpt2:=FND(' ',' ',cpt1);
    TXT(cpt1,cpt2-1);
    devname:=nsymb;
    pointer:=LIB_PT;
    defpointer:=NIL;
    WHILE (pointer<>NIL) AND (defpointer=NIL) DO
    BEGIN
     IF (devname=pointer^.def.devname) THEN defpointer:=pointer;
     pointer:=pointer^.defpt
    END;

    IF defpointer=NIL THEN
    BEGIN
     STATUS(line);
     ERROR(7,0)  { LIBRARY ERROR-DEF FOR CALL NOT FOUND }
    END
    ELSE
    BEGIN
     cpt1 := temp_cpt1;
     cpt2 := temp_cpt2;
     defpt:=ADDR(defpointer^.def);
     devpointer:=ADDR(defpointer^.def);
     WHILE devpointer^.devpt<>NIL DO
      devpointer:=devpointer^.devpt;
     NEW(devpointer^.devpt);
     devpointer:=devpointer^.devpt;
     devpointer^.devpt:=NIL;
     devpointer^.devname:=partname;
     devpointer^.nodes:=defpointer^.def.nodes;
     devpointer^.llpth:=NIL;
     devpointer^.ppth:=NIL;
     COPY_DEF(defpt,devpointer);
     COPY_PAR(defpt,devpointer);
     SET_DEV_PAR(devpointer);
    END
   END;
   pointera:=pointera^.lpt
  END
 END;

{***************************************************************************}

 PROCEDURE CHANGE_INT_NODES(VAR dev:devicept);
 VAR

 pointer:listapt;
 temp_cpt1,temp_cpt2,p_cnt:integer;


 PROCEDURE NODE(m:INTEGER);
 VAR
 s:string;
 index1,index2,index3:INTEGER;

 BEGIN

  index2:=cpt2;
  REPEAT
  BEGIN
   index3:=index2;
   index1:=FND('0','z',index2);
   index2:=FND(' ',' ',index1);
   xx:=FALSE;
   RIN;
   IF NOT xx THEN
   BEGIN
    IF itg>0 THEN
    BEGIN
     DELETE(line,index1,(index2-index1));
     STR(itg+nn,s);
     INSERT(s,line,index1);
     index1:=FND('0','9',index3);
     index2:=FND(' ',' ',index1)
    END
   END;
   cpt1:=index1;
   cpt2:=index2;
   m:=m-1;
  END
  UNTIL (m<=0)
 END;



 BEGIN

  pointer:=dev^.llpth;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   xx:=FALSE;
   cpt1:=FND('A','z',1);
   cpt2:=FND(' ',' ',cpt1);
   IF NOT xx THEN
   BEGIN

    CASE line[cpt1] OF
    'r','R','y','Y','c','C','l','L','z','Z':
     BEGIN
      cpt1:=cpt2;
      NODE(2)
     END;
    'a','A':
    BEGIN
     cpt1:=cpt2;
     NODE(4)
    END;
    't','T':
    BEGIN
     cpt1:=cpt2;
     NODE(3)
    END;
    'b','B':
    BEGIN
     temp_cpt1:=cpt1;
     temp_cpt2:=cpt2;
     p_cnt:=COUNT_PARAMETERS;
     cpt1:=temp_cpt1;
     cpt2:=temp_cpt2;
     cpt1:=cpt2;
     NODE(p_cnt-1); {last parameter in B is a matrix name}
    END;
    'g','G','e','E','f','F','h','H','n','N':
    BEGIN
     cpt1:=cpt2;
     NODE(4)
    END
    ELSE
     BEGIN
     END
    END
   END;
   pointer^.oneline:=line;
   pointer:=pointer^.lpt
  END
 END;


 PROCEDURE CHANGE_DEV_PARAMETERS(VAR dev:devicept);
 VAR

 pointer:listapt;
 temp_cpt1,temp_cpt2,p_cnt:integer;

 PROCEDURE PARAMETERS(m:INTEGER;p:parameterpt);
 VAR
 patern,s:string;
 index1,index2,index3:INTEGER;
 param_found:BOOLEAN;
 pointer:parameterpt;

 BEGIN

  index2:=cpt2;
  REPEAT
  BEGIN
   index3:=index2;
   index1:=FND('0','z',index2);
   index2:=FND(' ',' ',index1);
   xx:=FALSE;
   RIN;
   IF xx THEN
   BEGIN
     xx:=FALSE;
     TXT(index1,index2-1);
     s:=nsymb;
     if ( s<>'' ) then begin    { A ao ai aa ab }
      param_found:=FALSE;
      pointer:=p;
      WHILE ((NOT param_found) AND (pointer<>NIL)) DO
        IF pointer^.ps=s THEN param_found:=TRUE
        ELSE pointer:=pointer^.ppt;
      IF param_found THEN
      BEGIN
        DELETE(line,index1,(index2-index1));
        STR(pointer^.pv,patern);
        INSERT(patern,line,index1);
        index1:=FND('0','9',index3);
        index2:=FND(' ',' ',index1)
      END
      ELSE
      BEGIN
        STATUS(line);
        ERROR(8,0)
      END
     end;
   END;
   m:=m-1;
   cpt1:=index1;
   cpt2:=index2;
  END
  UNTIL (m<=0)
 END;



 BEGIN

  pointer:=dev^.llpth;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   xx:=FALSE;
   cpt1:=FND('A','z',1);
   cpt2:=FND(' ',' ',cpt1);
   IF NOT xx THEN
   BEGIN

    CASE line[cpt1] OF
    'r','R','y','Y','c','C','l','L','z','Z':
     BEGIN
      cpt1:=cpt2;
      PARAMETERS(2,dev^.ppth)
     END;
    'a','A':
    BEGIN
     cpt1:=cpt2;
     PARAMETERS(4,dev^.ppth)   { A ao ai aa ab }
    END;
    'g','G','e','E','f','F','h','H','n','N':
    BEGIN
     cpt1:=cpt2;
     PARAMETERS(4,dev^.ppth)
    END;
    't','T':
    BEGIN
     cpt1:=cpt2;
     PARAMETERS(3,dev^.ppth)
    END;
    'b','B':
    BEGIN
     temp_cpt1:=cpt1;
     temp_cpt2:=cpt2;
     p_cnt:=COUNT_PARAMETERS;
     cpt1:=temp_cpt1;
     cpt2:=temp_cpt2;
     cpt1:=cpt2;
     PARAMETERS(p_cnt-1,dev^.ppth); {last parameter in B is a matrix name}
    END

    ELSE
     BEGIN
     END
    END
   END;
   pointer^.oneline:=line;
   pointer:=pointer^.lpt
  END
 END;


 PROCEDURE SET_UP_LIB_CALLS;
 VAR
  libpointer:libpt;
  devpointer:devicept;

 BEGIN

  libpointer:=LIB_PT;
  WHILE libpointer<>NIL DO
  BEGIN
   devpointer:=libpointer^.def.devpt;
   WHILE devpointer<>NIL DO
   BEGIN
    CHANGE_INT_NODES(devpointer);
    nn:=nn+devpointer^.nodes;
    CHANGE_DEV_PARAMETERS(devpointer);
    devpointer:=devpointer^.devpt
   END;
   libpointer:=libpointer^.defpt
  END
 END;

{***************************************************************************}

 PROCEDURE EXTRACT_LIB_COMP;
 VAR
  libpointer:libpt;
  devpointer:devicept;
  linepointer,compointer:listapt;
  extension:symb;

 BEGIN

  libpointer:=LIB_PT;
  WHILE libpointer<>NIL DO
  BEGIN
   devpointer:=libpointer^.def.devpt;
   WHILE devpointer<>NIL DO
   BEGIN
    extension:=CONCAT('.',devpointer^.devname);
    linepointer:=devpointer^.llpth;
    WHILE linepointer<>NIL DO
    BEGIN
     line:=linepointer^.oneline;
     xx:=FALSE;
     cpt1:=FND('!','z',1);
     cpt2:=FND(' ',' ',cpt1);
     IF IS_COMP_NAME(line[cpt1]) THEN
     BEGIN
      INSERT(extension,line,cpt2);
      IF LIB_COMP_PT=NIL THEN
      BEGIN
       NEW(LIB_COMP_PT);
       compointer:=LIB_COMP_PT;
      END
      ELSE
      BEGIN
       NEW(compointer^.lpt);
       compointer:=compointer^.lpt
      END;
      compointer^.oneline:=line;
      compointer^.lpt:=NIL
     END;
     linepointer:=linepointer^.lpt
    END;
    devpointer:=devpointer^.devpt
   END;
   libpointer:=libpointer^.defpt
  END

 END;





END.
