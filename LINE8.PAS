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
        
    if k<=llen then
    begin
     while (l<=llen) do
     begin
      if ((ORD(line[l])>=ORD(c1))AND(ORD(line[l])<=ORD(c2))) then break
      else l:=l+1;
     end
    end;
    
    if l>llen then  
    begin 
      xx:=TRUE;
    end;  
    
    FND:=l
END;

{********************************************************}
{*******        read real number rr          ************}
{********************************************************}

PROCEDURE RRL;
VAR

 r1s:STRING;
 code,cpt3:INTEGER;

BEGIN {RRL}

 cpt1:=FND('+','9',cpt2);
 if not xx then 
 begin  
     cpt2:=FND(CHR(9),' ',cpt1); {* CHR(9) is in a right place, don't try to be clever and change it into ' ' *}
     if xx then 
     begin 
        cpt2:=LENGTH(line)+1 ; {* xx means the end of line was hit, set cpt2 at beyond the end of line *}
     end;        
     r1s:=COPY(line, cpt1, cpt2-cpt1); {* cpt2 points at first white space or one char beyond line *}     
     xx:=FALSE;
     VAL(r1s,rr,code);
     if code<>0 then
     begin
     {* THIS IS NOT A NUBMER IN SCIENTIFIC NOTATION                     *}
     {* THE ERROR CAN BE CAUSED BY POST-FIX;THE LAST CHAR IN STRING     *}
        
        cpt3:=FND('A','z',cpt1);              {* find first leter in a digit but leave cpt2 as it was ! *}
        r1s:=COPY(line,cpt1,(cpt3-cpt1));
        VAL(r1s,rr,code);
        if ((code=0) and (not xx)) then   {* not xx means that character line[cpt3] was found *}
        begin
          case line[cpt3] of
          'f': rr:=rr*1.0E-15;
          'p': rr:=rr*1.0E-12;
          'n': rr:=rr*1.0E-9;
          'u': rr:=rr*1.0E-6;
          'm': rr:=rr*1.0E-3;
      'k','K': rr:=rr*1.0E+3;
          'M': rr:=rr*1.0E+6;
          'G': rr:=rr*1.0E+9;
          'T': rr:=rr*1.0E+12;
          else xx:=TRUE;
          end
        end
        else xx:=TRUE;
     end
  end    
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
