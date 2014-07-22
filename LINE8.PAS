UNIT LINE8;

interface

USES
 SysUtils,
 TYPE8,VAR8;


FUNCTION MIGHT_BE_DIGIT(c:CHAR):BOOLEAN;
FUNCTION IS_COMP_NAME(c:CHAR):BOOLEAN;
FUNCTION FND(c1,c2:CHAR;k:INTEGER):INTEGER;

PROCEDURE CLEAR_LINE;
PROCEDURE TXT(p,q:INTEGER);
PROCEDURE RRL;
PROCEDURE RIN;

implementation

{***************************************************************************}

 FUNCTION IS_COMP_NAME(c:CHAR):BOOLEAN;
 VAR
 TEST:BOOLEAN;
 BEGIN
  CASE c OF
   'y','Y','R','r','Z','z': TEST:=TRUE;
   'a','A','g','G': TEST:=TRUE;
   'l','L','C','c': TEST:=TRUE;
   'i','I','v','V': TEST:=TRUE;
   'p','P': TEST:=TRUE;
   'e','E','f','F','h','H','n','N': TEST:=TRUE;
   'b','B': TEST:=TRUE;
   't','T': TEST:=TRUE;
   'k','K': TEST:=TRUE;
   {'x','X': TEST:=TRUE;}
   ELSE    TEST:=FALSE
  END;
  IS_COMP_NAME:=TEST
 END;

{***************************************************************************}
 FUNCTION MIGHT_BE_DIGIT(c:CHAR):BOOLEAN;
 VAR
 TEST:BOOLEAN;
 BEGIN
  CASE c OF
   '0','1','2','3','4','5','6','7','8','9','+','-','.': TEST:=TRUE;
   ELSE    TEST:=FALSE
  END;
  MIGHT_BE_DIGIT:=TEST
 END;

{********************************************************}
{*******        find character c:c1<=c<=c2   ************}
{********************************************************}

FUNCTION FND(c1,c2:CHAR;k:INTEGER):INTEGER;
VAR
l,llen:INTEGER;
BEGIN
llen:=LENGTH(line);
l:=k;
IF k<llen THEN
 WHILE NOT(((ORD(line[l])>=ORD(c1))AND(ORD(line[l])<=ORD(c2)))OR(l>llen)) DO
 l:=l+1;
 IF l>llen THEN BEGIN xx:=TRUE ;l:=k END;
 FND:=l
END;

{********************************************************}
{*******        read real number rr          ************}
{********************************************************}

PROCEDURE RRL;
VAR

 r1s:STRING;
 cpt3,code:INTEGER;

BEGIN {RRL}

 cpt1:=FND('!','z',cpt2);
 {cpt2:=FND(CHR(13),' ',cpt1);}
 cpt2:=FND(CHR(09),' ',cpt1);
 r1s:=COPY(line,cpt1,(cpt2-cpt1));
 VAL(r1s,rr,code);
 IF code<>0 THEN
 BEGIN
 {* THIS IS NOT A NUBMER IN SCIENTIFIC NOTATION                     *}
 {* THE ERROR CAN BE CAUSED BY POST-FIX;THE LAST CHAR IN STRING     *}
  xx:=FALSE;
  cpt3:=FND('A','z',cpt1);
  IF (cpt2-cpt3)=1 THEN BEGIN
    r1s:=COPY(line,cpt1,(cpt3-cpt1));
    VAL(r1s,rr,code);
    IF code=0 THEN BEGIN
      CASE line[cpt3] OF
      'p': rr:=rr*1.0E-12;
      'n': rr:=rr*1.0E-9;
      'u': rr:=rr*1.0E-6;
      'm': rr:=rr*1.0E-3;
  'k','K': rr:=rr*1.0E+3;
      'M': rr:=rr*1.0E+6;
      'G': rr:=rr*1.0E+9;
      'T': rr:=rr*1.0E+12;
      ELSE xx:=TRUE
      END
    END
  END
  ELSE xx:=TRUE
 END
END;{RRL}

{********************************************************}
{*******        read integer number          ************}
{********************************************************}

PROCEDURE RIN;
VAR
 code:INTEGER;
 intstr:STRING;

BEGIN

 itg:=0;
 cpt1:=FND('!','z',cpt2);
 IF NOT xx THEN
 BEGIN
  IF (ORD(line[cpt1])>=ORD('0')) AND (ORD(line[cpt1])<=ORD('9')) THEN
  BEGIN
   cpt2:=FND(CHR(13),'/',cpt1);
   intstr:=COPY(line,cpt1,(cpt2-cpt1));
   VAL(intstr,itg,code);
   IF code<>0 THEN xx:=TRUE
  END
  ELSE xx:=TRUE
 END

END;



{********************************************************}
{*******             clear line              ************}
{********************************************************}

 PROCEDURE CLEAR_LINE;
 BEGIN
{*  FOR k:=1 TO llen DO line[k]:=' '; *}
  line:=' ';
  cpt1:=1;
  cpt2:=1
 END;


{********************************************************}
{*******  read characters n:=line[p..q]:symb ************}
{********************************************************}



PROCEDURE TXT(p,q:INTEGER);

BEGIN
IF NOT xx THEN nsymb:=COPY(line,p,(q-p+1))
ELSE nsymb:='        '
END;

PROCEDURE TXT_X(p,q:INTEGER);
VAR k:INTEGER;
BEGIN
IF NOT xx THEN
BEGIN
 FOR k:=1 TO lmax DO
  IF (p+k-1)<=q THEN nsymb[k]:=line[p+k-1]
  ELSE nsymb[k]:=' '
END
ELSE nsymb:='        '
END;




END.
