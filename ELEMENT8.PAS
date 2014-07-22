
UNIT ELEMENT8;

interface

USES
 SysUtils,
 TYPE8,VAR8,LINE8,VAREXT8;

PROCEDURE FNN;
PROCEDURE CHECK_TOPOLOGY;

PROCEDURE DSV (l_pt:listapt);

PROCEDURE ADD_COMPONENTS;
PROCEDURE ADD_LIB_COMPONENTS;
PROCEDURE MACRO_NODES;

PROCEDURE ADD_TO_LISTA(VAR head,tail:listapt);

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}

implementation
USES Amp8_main;

{***************************************************************************}

PROCEDURE ADD_TO_LISTA(VAR head,tail:listapt);
BEGIN
 if (head=NIL) then begin
    NEW(head);
    tail:=head
 end
 else begin
    NEW(tail^.lpt);
    tail:=tail^.lpt
 end;
 tail^.oneline:=line;
 tail^.lpt:=NIL
END;


{********************************************************}
{*******   read A component                  ************}
{*******   A o+ [o-] ni ii                   ************}
{*******   A aa [ab] ac ad                   ************}
{*******   D(aa+ab)(ad+ac)                   ************}
{********************************************************}
{ Differential Output  }
{ Aname aa ab ac ad    }
{ Single Ended Output }
{ Aname aa ac ad      }

PROCEDURE RDA;
var
yy:BOOLEAN;

BEGIN{a}
 WITH A_tail^ DO
 BEGIN
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  aname:=nsymb;
  RIN;aa:=itg;     { O+    }
  RIN;ab:=itg;     { [0-]  }
  RIN;ac:=itg;     { NI    }
  yy:=xx;          { II    }
  xx:=FALSE;
  RIN;
  IF NOT (xx) THEN
  BEGIN
       ad:=itg;    { II    }
  END
  ELSE
  BEGIN            { there are 3 nodes,  so }
       ad:=ac;
       ac:=ab;
       ab:=0;
  END;
  xx:=yy;

 END
END;{a}

{********************************************************}
{*******        read V component             ************}
{********************************************************}
{ Vname va vb }
PROCEDURE RDV;
BEGIN{v}
 WITH V_tail^ DO
 BEGIN
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  vname:=nsymb;
  RIN; va:=itg;
  RIN; vb:=itg;
  vtype:=GENERIC;
  vref:='';
 END
END;{v}

{********************************************************}
{*******        read I component             ************}
{********************************************************}
{ Iname ia ib }

PROCEDURE RDI;
BEGIN{I}
 WITH I_tail^ DO
 BEGIN
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  iname:=nsymb;
  RIN; ia:=itg;
  RIN; ib:=itg;
  itype:=GENERIC;
  iref:='';
 END
END;{i}

{********************************************************}
{*******        read P component             ************}
{********************************************************}
{ P[U,I,Z]name pa pb   }
{ PT[U,I,N,M]name pa pb pc pd  }

PROCEDURE RDP;
BEGIN {P}
 WITH P_tail^ DO BEGIN
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1+1,cpt2-1);
  pname:=nsymb;
  case ( nsymb[1] ) of
    'u','U': ptype:=PROBE_U;
    'v','V': ptype:=PROBE_U;
    'i','I': ptype:=PROBE_I;
    'j','J': ptype:=PROBE_I;
    'z','Z': ptype:=PROBE_Z;
    't','T': case ( nsymb[2] ) of
             'u','U': ptype:=PROBE_TU;
             'v','V': ptype:=PROBE_TU;
             'i','I': ptype:=PROBE_TI;
             'j','J': ptype:=PROBE_TI;
             'n','N': ptype:=PROBE_TN;
             'm','M': ptype:=PROBE_TM;
             end;
    else
        PROBE_TYPE_ERROR;
    end;

  if ( (ptype=PROBE_U) or (ptype=PROBE_I) or (ptype=PROBE_Z) ) then begin
    pname:=nsymb;
    RIN; pa:=itg;
    RIN; pb:=itg;
    pc:=0;
    pd:=0;
  end
  else begin
    pname:=Copy(nsymb,2,Length(nsymb)-1);
    RIN; pa:=itg;
    RIN; pb:=itg;
    RIN; pc:=itg;
    RIN; pd:=itg;
  end;
  pref:='';
 END
END; {P}

{********************************************************}
{*******        read Y component             ************}
{********************************************************}
 { Yname ya yb 1.0E-3 }
 { Yname ya yb 1.0E-3  1.0E-4}
PROCEDURE RDY;
VAR yy:BOOLEAN;
BEGIN{y}
 WITH Y_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  yname:=nsymb;
  RIN;ya:=itg;
  RIN;yb:=itg;
  RRL;yvre:=rr;
  yy:=xx;          { Im ?    }
  xx:=FALSE;
  RRL;
  if ( not(xx) ) then begin
     yvim:=rr;
  end
  else begin
     yvim:=0.0;
  end;
  xx:=yy;
  yvar:=CONSTANT;
  yref:='';
 END
END;{y}

{ Yname ya yb VAR yref }
PROCEDURE RDY_VAR;
BEGIN{y}
 WITH Y_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  yname:=nsymb;
  RIN;ya:=itg;
  RIN;yb:=itg;
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  yref:=nsymb;
  yvar:=VARIABLE; { type defined by model }
 END
END;{y}

{ Yname ya yb TUN yref }
PROCEDURE RDY_TUN;
BEGIN{y}
 WITH Y_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  yname:=nsymb;
  RIN;ya:=itg;
  RIN;yb:=itg;
  cpt1:=FND('T','t',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  yref:=nsymb;
  yvar:=TUNED;
 END
END;{y}

{ Yname ya yb GEN }
PROCEDURE RDY_GEN;
BEGIN{y}
 WITH Y_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  yname:=nsymb;
  RIN;ya:=itg;
  RIN;yb:=itg;
  cpt1:=FND('G','g',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  yvar:=GEN;
  yref:='';
 END
END;{y}

{ Yname ya yb PAR yref }
PROCEDURE RDY_PAR;
BEGIN{y}
 WITH Y_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  yname:=nsymb;
  RIN;ya:=itg;
  RIN;yb:=itg;
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  yref:=nsymb;
  yvar:=PARAM;
 END
END;{y}

{********************************************************}
{*******        read G component             ************}
{********************************************************}
{ Gname ga gb gc gd 1.0E-3 }
{ Gname ga gb gc gd 1.0E-3 1.0E-4}
PROCEDURE RDG;
VAR yy:BOOLEAN;
BEGIN{g}
 WITH G_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  gname:=nsymb;
  RIN;ga:=itg;
  RIN;gb:=itg;
  RIN;gc:=itg;
  RIN;gd:=itg;
  RRL;gvre:=rr;
  yy:=xx;          { Im ?   }
  xx:=FALSE;
  RRL;
  if ( not(xx) ) then begin
     gvim:=rr;
  end
  else begin
     gvim:=0.0;
  end;
  xx:=yy;
  gvar:=CONSTANT;
  gtype:=GENUINE;
  gref:='';
 END
END;{g}


{ Gname ga gb gc gd VAR gref }
PROCEDURE RDG_VAR;
BEGIN{g}
 WITH G_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  gname:=nsymb;
  RIN;ga:=itg;
  RIN;gb:=itg;
  RIN;gc:=itg;
  RIN;gd:=itg;
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  gref:=nsymb;
  gvar:=VARIABLE; { type defined by model }
  gtype:=GENUINE;
 END
END;{g}

{ Gname ga gb gc gd TUN yref  }
PROCEDURE RDG_TUN;
BEGIN{g}
 WITH G_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  gname:=nsymb;
  RIN;ga:=itg;
  RIN;gb:=itg;
  RIN;gc:=itg;
  RIN;gd:=itg;
  cpt1:=FND('T','t',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  gref:=nsymb;
  gvar:=TUNED;
  gtype:=GENUINE;
 END
END;{g}

{ Gname ga gb gc gd GEN }
PROCEDURE RDG_GEN;
BEGIN{g}
 WITH G_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  gname:=nsymb;
  RIN;ga:=itg;
  RIN;gb:=itg;
  RIN;gc:=itg;
  RIN;gd:=itg;
  cpt1:=FND('G','g',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  gvar:=GEN;
  gtype:=GENUINE;
  gref:='';
 END
END;{g}

{ Gname ga gb gc gd PAR yref  }
PROCEDURE RDG_PAR;
BEGIN{g}
 WITH G_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  gname:=nsymb;
  RIN;ga:=itg;
  RIN;gb:=itg;
  RIN;gc:=itg;
  RIN;gd:=itg;
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  gref:=nsymb;
  gvar:=PARAM;
  gtype:=GENUINE;

 END
END;{g}


{********************************************************}
{*******        read Z component             ************}
{********************************************************}
{ Zname za zb 1.0E+3 }
{ Zname za zb 1.0E+3 1.0E+4 }
PROCEDURE RDZ;
VAR yy:BOOLEAN;
BEGIN{z}
 WITH Z_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  zname:=nsymb;
  RIN;za:=itg;
  RIN;zb:=itg;
  RRL;zvre:=rr;
  yy:=xx;          { Im ?    }
  xx:=FALSE;
  RRL;
  if ( not(xx) ) then begin
     zvim:=rr;
  end
  else begin
     zvim:=0.0;
  end;
  xx:=yy;
  ztunpt:=nil;
  zvarpt:=nil;
  zvar:=CONSTANT;
  zref:='';
 END
END;{z}

{ Zname za zb VAR zref }
PROCEDURE RDZ_VAR;
BEGIN{r}
 WITH Z_tail^ DO
 BEGIN
   cpt2:= FND(' ',' ',cpt1);
   TXT(cpt1,cpt2-1);
   zname:=nsymb;
  RIN;za:=itg;
  RIN;zb:=itg;
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  zref:=nsymb;
  zvar:=VARIABLE; { type defined by model }
 END
END;{r}

{ Zname za zb PAR zref }
PROCEDURE RDZ_PAR;
BEGIN{r}
 WITH Z_tail^ DO
 BEGIN
   cpt2:= FND(' ',' ',cpt1);
   TXT(cpt1,cpt2-1);
   zname:=nsymb;
  RIN;za:=itg;
  RIN;zb:=itg;
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  zref:=nsymb;
  zvar:=PARAM; { type defined by model }
 END
END;{r}


{********************************************************}
{*******        read R component             ************}
{********************************************************}
{ Rname ra rb 1.0E+3 }
PROCEDURE RDR;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  RRL;rv:=rr;
  rvar:=CONSTANT;
  rref:='';

 END
END;{r}

{ Rname ra rb VAR rref }
PROCEDURE RDR_VAR;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
   cpt2:= FND(' ',' ',cpt1);
   TXT(cpt1,cpt2-1);
   rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  rref:=nsymb;
  rvar:=VARIABLE; { type defined by model }
 END
END;{r}

{ Rname ra rb TUN rref }
PROCEDURE RDR_TUN;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  cpt1:=FND('T','t',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  rref:=nsymb;
  rvar:=TUNED;
 END
END;{r}

{ Rname ra rb GEN }
PROCEDURE RDR_GEN;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  cpt1:=FND('G','g',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  rvar:=GEN;
  rref:='';
 END
END;{r}

{ Rname ra rb 100 MOD rref }
PROCEDURE RDR_MOD;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  RRL;rv:=rr;
  cpt1:=FND('M','m',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  rref:=nsymb;
  rvar:=MODEL_DEF;
 END
END;{r}

{ Rname ra rb PAR rref }
PROCEDURE RDR_PAR;
BEGIN{r}
 WITH R_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  rname:=nsymb;
  RIN;ra:=itg;
  RIN;rb:=itg;
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  rref:=nsymb;
  rvar:=PARAM;
 END
END;{r}


{********************************************************}
{*******        read C component             ************}
{********************************************************}
{ Cname ca cb 1.0E-12 }
PROCEDURE RDC;
BEGIN {c}
 WITH C_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  cname:=nsymb;
  RIN;ca:=itg;
  RIN;cb:=itg;
  RRL;cv:=rr;
  cvar:=CONSTANT;
  cref:='';

 END
END;{c}

{ Cname ca cb VAR cref }
PROCEDURE RDC_VAR;
BEGIN {c}
 WITH C_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  cname:=nsymb;
  RIN;ca:=itg;
  RIN;cb:=itg;
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  cref:=nsymb;
  cvar:=VARIABLE; { type defined by model }
 END
END;{c}

{ Cname ca cb TUN cref }
PROCEDURE RDC_TUN;
BEGIN {c}
 WITH C_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  cname:=nsymb;
  RIN;ca:=itg;
  RIN;cb:=itg;
  cpt1:=FND('T','t',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  cref:=nsymb;
  cvar:=TUNED;
 END
END;{c}

{ Cname ca cb 10p MOD cref }
PROCEDURE RDC_MOD;
BEGIN {c}
 WITH C_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  cname:=nsymb;
  RIN;ca:=itg;
  RIN;cb:=itg;
  RRL;cv:=rr;
  cpt1:=FND('M','m',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  cref:=nsymb;
  cvar:=MODEL_DEF;
 END
END;{c}

{ Cname ca cb PAR cref }
PROCEDURE RDC_PAR;
BEGIN {c}
 WITH C_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  cname:=nsymb;
  RIN;ca:=itg;
  RIN;cb:=itg;
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  cref:=nsymb;
  cvar:=PARAM;
 END
END;{c}

{********************************************************}
{*******        read L component             ************}
{********************************************************}
{ Lname la lb 1.0E-6 }
PROCEDURE RDL;
BEGIN{l}
 WITH L_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  lname:=nsymb;
  RIN;la:=itg;
  RIN;lb:=itg;
  lc:=0; { lc = 0 means the HIL was not set }
  RRL;lv:=rr;
  lvar:=CONSTANT;
  lref:='';

 END
END;{l}

{ Lname la lb VAR lref }
PROCEDURE RDL_VAR;
BEGIN{l}
 WITH L_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  lname:=nsymb;
  RIN;la:=itg;
  RIN;lb:=itg;
  lc:=0; { lc = 0 means the HIL was not set }
  cpt1:=FND('V','v',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  lref:=nsymb;
  lvar:=VARIABLE; { type defined by model }

 END
END;{l}

{ Lname la lb TUN lref }
PROCEDURE RDL_TUN;
BEGIN{l}
 WITH L_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  lname:=nsymb;
  RIN;la:=itg;
  RIN;lb:=itg;
  lc:=0; { lc = 0 means the HIL was not set }
  cpt1:=FND('T','t',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  lref:=nsymb;
  lvar:=TUNED;

 END
END;{l}

{ Lname la lb 100n MOD lref }
PROCEDURE RDL_MOD;
BEGIN{l}
 WITH L_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  lname:=nsymb;
  RIN;la:=itg;
  RIN;lb:=itg;
  lc:=0; { lc = 0 means the HIL was not set }
  RRL;lv:=rr;
  cpt1:=FND('M','m',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  lref:=nsymb;
  lvar:=MODEL_DEF;

 END
END;{l}

{ Lname la lb PAR lref }
PROCEDURE RDL_PAR;
BEGIN{l}
 WITH L_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  lname:=nsymb;
  RIN;la:=itg;
  RIN;lb:=itg;
  lc:=0; { lc = 0 means the HIL was not set }
  cpt1:=FND('P','p',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  lref:=nsymb;
  lvar:=PARAM;

 END
END;{l}

{********************************************************}
{*******        read K component             ************}
{********************************************************}
{ Kname Laname Lbname 1.0 }

PROCEDURE RDK;
BEGIN{k}
 WITH K_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  kname:=nsymb;
  cpt1:=FND('L','l',cpt2);
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  k_lname1:=nsymb;
  cpt1:=FND('L','l',cpt2);
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  k_lname2:=nsymb;
  RRL;kv:=rr;
 END
END;{k}


{********************************************************}
{*******        read E component             ************}
{********************************************************}
{ Ename ea eb ec ed 1.0E+3 }

PROCEDURE RDE;
BEGIN{e}
 WITH E_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  ename:=nsymb;
  RIN;ea:=itg;
  RIN;eb:=itg;
  RIN;ec:=itg;
  RIN;ed:=itg;
  RRL;ev:=rr;

 END
END;{e}

{********************************************************}
{*******        read F component             ************}
{********************************************************}
{ Fname fa fb fc fd 1.0E+0 }

PROCEDURE RDF;
BEGIN{f}
 WITH F_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  fname:=nsymb;
  RIN;fa:=itg;
  RIN;fb:=itg;
  RIN;fc:=itg;
  RIN;fd:=itg;
  RRL;fv:=rr;

 END
END;{f}

{********************************************************}
{*******        read H component             ************}
{********************************************************}
{ Hname ha hb hc hd 1.0E+3 }

PROCEDURE RDH;
BEGIN{f}
 WITH H_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  hname:=nsymb;
  RIN;ha:=itg;
  RIN;hb:=itg;
  RIN;hc:=itg;
  RIN;hd:=itg;
  RRL;hv:=rr;

 END
END;{h}

{********************************************************}
{*******        read N component             ************}
{********************************************************}
{ Nname na nb nc nd 1.0E+3 }

PROCEDURE RDN;
BEGIN{n}
 WITH N_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  nname:=nsymb;
  RIN;na:=itg;
  RIN;nb:=itg;
  RIN;nc:=itg;
  RIN;nd:=itg;
  RRL;nv:=rr;
 END
END;{n}

{********************************************************}
{*******        read B component             ************}
{********************************************************}
{ Bname ba bb [bc.......] bmatref }

PROCEDURE RDB;
var
yy:BOOLEAN;
cpt3:INTEGER;
BEGIN{b}
 with B_tail^ do begin
  cpt2:=FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  bname:=nsymb;
  bndim:=2;
  RIN;bnodes[1]:=itg;     { ba  }
  RIN;bnodes[2]:=itg;     { bb  }
  yy:=xx;
  cpt3:=cpt2;
  repeat
    RIN;
    if ( NOT xx ) then begin
        if ( bndim < bmaxdim ) then begin
          bndim:=bndim +1 ;
          bnodes[bndim]:=itg;
          cpt3:=cpt2;
        end
        else begin
          xx:=TRUE;
        end;
    end;
  until ( xx );
  xx:=FALSE;
  cpt2:=cpt3;
  cpt1:=FND('A','z',cpt2);
  cpt2:= FND(CHR(13),' ',cpt1);
  TXT(cpt1,cpt2-1);
  bref:=nsymb;
  bmatpt:=NIL;
  xx:=yy;
 end
END;{b}

{********************************************************}
{*******        read T component             ************}
{********************************************************}
{ Tname ta tb tc 100 10n }
PROCEDURE RDT;
BEGIN{t}
 WITH T_tail^ DO
 BEGIN
  cpt2:= FND(' ',' ',cpt1);
  TXT(cpt1,cpt2-1);
  tname:=nsymb;
  RIN;ta:=itg;
  RIN;tb:=itg;
  RIN;tc:=itg;
  RRL;t_zr:=rr;
  RRL;t_td:=rr;
 END
END;{t}


{********************************************************}
{*******          data  supervisor           ************}
{********************************************************}

PROCEDURE DSV (l_pt:listapt);
 VAR
 CheckLine: string;
 BEGIN
  CheckLine:=UpperCase(line);
  CASE line[cpt1] OF

   'v','V': begin
            IF V_head=NIL THEN BEGIN
              NEW(V_head);
              V_tail:=V_head;
            END
            ELSE BEGIN
              NEW(V_tail^.vnext);
              V_tail:=V_tail^.vnext;
            END;
            V_tail^.vnext:=NIL;
            V_tail^.line_pt:=l_pt;
            RDV;
           end;

   'i','I': begin
            IF I_head=NIL THEN BEGIN
              NEW(I_head);
              I_tail:=I_head;
            END
            ELSE BEGIN
              NEW(I_tail^.inext);
              I_tail:=I_tail^.inext;
            END;
            I_tail^.inext:=NIL;
            I_tail^.line_pt:=l_pt;
            RDI;
           end;

   'p','P': begin
            IF P_head=NIL THEN BEGIN
              NEW(P_head);
              P_tail:=P_head;
            END
            ELSE BEGIN
              NEW(P_tail^.pnext);
              P_tail:=P_tail^.pnext;
            END;
            P_tail^.pnext:=NIL;
            P_tail^.line_pt:=l_pt;
            RDP;
           end;

   'a','A': begin
            IF A_head=NIL THEN BEGIN
              NEW(A_head);
              A_tail:=A_head;
            END
            ELSE BEGIN
              NEW(A_tail^.anext);
              A_tail:=A_tail^.anext;
            END;
            A_tail^.anext:=NIL;
            A_tail^.line_pt:=l_pt;
            RDA;
           end;

   'y','Y': begin
              IF Y_head=NIL THEN BEGIN
                NEW(Y_head);
                Y_tail:=Y_head;
              END
              ELSE BEGIN
                NEW(Y_tail^.ynext);
                Y_tail:=Y_tail^.ynext;
              END;
              Y_tail^.ynext:=NIL;
              Y_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDY_VAR
              else if ( Pos('TUN',CheckLine)<>0 ) then RDY_TUN
              else if ( Pos('GEN',CheckLine)<>0 ) then RDY_GEN
              else if ( Pos('PAR',CheckLine)<>0 ) then RDY_PAR
              else RDY;
              Y_tail^.ytunpt:=NIL;
              Y_tail^.yvarpt:=NIL;
              Y_tail^.yparpt:=NIL;
            end;

   'g','G': begin
              IF G_head=NIL THEN
              BEGIN
                NEW(G_head);
                G_tail:=G_head;
              END
              ELSE
              BEGIN
                NEW(G_tail^.gnext);
                G_tail:=G_tail^.gnext;
              END;
              G_tail^.gnext:=NIL;
              G_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDG_VAR
              else if ( Pos('TUN',CheckLine)<>0 ) then RDG_TUN
              else if ( Pos('GEN',CheckLine)<>0 ) then RDG_GEN
              else if ( Pos('PAR',CheckLine)<>0 ) then RDG_PAR
              else RDG;
              G_tail^.gtunpt:=NIL;
              G_tail^.gvarpt:=NIL;
              G_tail^.gparpt:=NIL;
            end;

   'z','Z': begin
              IF Z_head=NIL THEN
              BEGIN
                NEW(Z_head);
                Z_tail:=Z_head;
              END
              ELSE
              BEGIN
                NEW(Z_tail^.znext);
                Z_tail:=Z_tail^.znext;
              END;
              Z_tail^.znext:=NIL;
              Z_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDZ_VAR
              else if ( Pos('PAR',CheckLine)<>0 ) then RDZ_PAR
              else RDZ;
              Z_tail^.ztunpt:=NIL;
              Z_tail^.zvarpt:=NIL;
              Z_tail^.zparpt:=NIL;
            end;

   'r','R': begin
              IF R_head=NIL THEN
              BEGIN
                NEW(R_head);
                R_tail:=R_head;
              END
              ELSE
              BEGIN
                NEW(R_tail^.rnext);
                R_tail:=R_tail^.rnext;
              END;
              R_tail^.rnext:=NIL;
              R_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDR_VAR
              else if ( Pos('TUN',CheckLine)<>0 ) then RDR_TUN
              else if ( Pos('GEN',CheckLine)<>0 ) then RDR_GEN
              else if ( Pos('MOD',CheckLine)<>0 ) then RDR_MOD
              else if ( Pos('PAR',CheckLine)<>0 ) then RDR_PAR
              else RDR;
              R_tail^.rtunpt:=NIL;
              R_tail^.rvarpt:=NIL;
              R_tail^.rparpt:=NIL;
            end;

   'c','C': begin
              IF C_head=NIL THEN
              BEGIN
                NEW(C_head);
                C_tail:=C_head;
              END
              ELSE
              BEGIN
                NEW(C_tail^.cnext);
                C_tail:=C_tail^.cnext;
              END;
              C_tail^.cnext:=NIL;
              C_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDC_VAR
              else if ( Pos('TUN',CheckLine)<>0 ) then RDC_TUN
              else if ( Pos('MOD',CheckLine)<>0 ) then RDC_MOD
              else if ( Pos('PAR',CheckLine)<>0 ) then RDC_PAR
              else RDC;
              C_tail^.ctunpt:=NIL;
              C_tail^.cvarpt:=NIL;
              C_tail^.cparpt:=NIL;
            end;

   'l','L': begin
              IF L_head=NIL THEN
              BEGIN
                NEW(L_head);
                L_tail:=L_head;
              END
              ELSE
              BEGIN
                NEW(L_tail^.lnext);
                L_tail:=L_tail^.lnext;
              END;
              L_tail^.lnext:=NIL;
              L_tail^.line_pt:=l_pt;
              if ( Pos('VAR',CheckLine)<>0 ) then RDL_VAR
              else if ( Pos('TUN',CheckLine)<>0 ) then RDL_TUN
              else if ( Pos('MOD',CheckLine)<>0 ) then RDL_MOD
              else if ( Pos('PAR',CheckLine)<>0 ) then RDL_PAR
              else RDL;
              L_tail^.ltunpt:=NIL;
              L_tail^.lvarpt:=NIL;
              L_tail^.lparpt:=NIL;
            end;

   'k','K': begin
              IF K_head=NIL THEN
              BEGIN
                NEW(K_head);
                K_tail:=K_head;
              END
              ELSE
              BEGIN
                NEW(K_tail^.knext);
                K_tail:=K_tail^.knext;
              END;
              K_tail^.knext:=NIL;
              K_tail^.line_pt:=l_pt;
              RDK;
            end;

   'e','E': begin
              IF E_head=NIL THEN
              BEGIN
                NEW(E_head);
                E_tail:=E_head;
              END
              ELSE
              BEGIN
                NEW(E_tail^.enext);
                E_tail:=E_tail^.enext;
              END;
              E_tail^.enext:=NIL;
              E_tail^.line_pt:=l_pt;
              RDE;
            end;

   'f','F': begin
              IF F_head=NIL THEN
              BEGIN
                NEW(F_head);
                F_tail:=F_head;
              END
              ELSE
              BEGIN
                NEW(F_tail^.fnext);
                F_tail:=F_tail^.fnext;
              END;
              F_tail^.fnext:=NIL;
              F_tail^.line_pt:=l_pt;
              RDF;
            end;

  'h','H': begin
              IF H_head=NIL THEN
              BEGIN
                NEW(H_head);
                H_tail:=H_head;
              END
              ELSE
              BEGIN
                NEW(H_tail^.hnext);
                H_tail:=H_tail^.hnext;
              END;
              H_tail^.hnext:=NIL;
              H_tail^.line_pt:=l_pt;
              RDH;
            end;
   'n','N': begin
              IF N_head=NIL THEN
              BEGIN
                NEW(N_head);
                N_tail:=N_head;
              END
              ELSE
              BEGIN
                NEW(N_tail^.nnext);
                N_tail:=N_tail^.nnext;
              END;
              N_tail^.nnext:=NIL;
              N_tail^.line_pt:=l_pt;
              RDN;
            end;

   'b','B': begin
              IF B_head=NIL THEN
              BEGIN
                NEW(B_head);
                B_tail:=B_head;
              END
              ELSE
              BEGIN
                NEW(B_tail^.bnext);
                B_tail:=B_tail^.bnext;
              END;
              B_tail^.bnext:=NIL;
              B_tail^.line_pt:=l_pt;
              RDB;
            end;

   't','T': begin
              IF T_head=NIL THEN
              BEGIN
                NEW(T_head);
                T_tail:=T_head;
              END
              ELSE
              BEGIN
                NEW(T_tail^.tnext);
                T_tail:=T_tail^.tnext;
              END;
              T_tail^.tnext:=NIL;
              T_tail^.line_pt:=l_pt;
              RDT;
            end;


           ELSE
           xx:=FALSE
    END;
    IF xx THEN DATA_ERROR
  END;

{****************************************************************************}

 PROCEDURE ADD_COMPONENTS;
 VAR
 pointer:listapt;

 BEGIN
  pointer:=COMP_PT;
  WHILE pointer<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=pointer^.oneline;
   cpt1:=FND('A','z',1);
   DSV(pointer);
   pointer:=pointer^.lpt
  END
 END;

{****************************************************************************}

PROCEDURE ADD_LIB_COMPONENTS;
 VAR
 lpointer:listapt;

 BEGIN
  lpointer:=LIB_COMP_PT;
  WHILE lpointer<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=lpointer^.oneline;
   cpt1:=FND('A','z',1);
   DSV(lpointer);
   lpointer:=lpointer^.lpt
  END
 END;

{********************************************************}
{*******        find number of nodes         ************}
{********************************************************}

PROCEDURE FNN;
VAR
 y_ptr:yptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 a_ptr:aptr;
 g_ptr:gptr;
 z_ptr:zptr;
 e_ptr:eptr;
 f_ptr:fptr;
 h_ptr:hptr;
 n_ptr:nptr;
 b_ptr:bptr;
 t_ptr:tptr;
 v_ptr:vptr;
 i_ptr:iptr;
 p_ptr:pptr;
 i:INTEGER;
BEGIN
nn:=0;
y_ptr:=Y_head;
WHILE y_ptr <> NIL DO
BEGIN
 WITH y_ptr^ DO
 BEGIN
  IF ya>nn THEN nn:=ya;
  IF yb>nn THEN nn:=yb
 END;
 y_ptr:=y_ptr^.ynext;
END;

z_ptr:=Z_head;
WHILE z_ptr<>NIL DO
BEGIN
 WITH z_ptr^ DO
 BEGIN
  IF za>nn THEN nn:=za;
  IF zb>nn THEN nn:=zb
 END;
 z_ptr:=z_ptr^.znext
END;

r_ptr:=R_head;
WHILE r_ptr<>NIL DO
BEGIN
 WITH r_ptr^ DO
 BEGIN
  IF ra>nn THEN nn:=ra;
  IF rb>nn THEN nn:=rb
 END;
 r_ptr:=r_ptr^.rnext
END;

c_ptr:=C_HEAD;
WHILE c_ptr<>NIL DO BEGIN
 WITH c_ptr^ DO BEGIN
  IF ca>nn THEN nn:=ca;
  IF cb>nn THEN nn:=cb
 END;
 c_ptr:=c_ptr^.cnext
END;

l_ptr:=L_head;
WHILE l_ptr<>NIL DO BEGIN
 WITH l_ptr^ DO BEGIN
  IF la>nn THEN nn:=la;
  IF lb>nn THEN nn:=lb
 END;
 l_ptr:=l_ptr^.lnext
END;

g_ptr:=G_head;
WHILE g_ptr<>NIL DO BEGIN
 WITH g_ptr^ DO BEGIN
  IF ga>nn THEN nn:=ga;
  IF gb>nn THEN nn:=gb;
  IF gc>nn THEN nn:=gc;
  IF gd>nn THEN nn:=gd
 END;
 g_ptr:=g_ptr^.gnext
END;

a_ptr:=A_head;
WHILE a_ptr<>NIL DO BEGIN
 WITH a_ptr^ DO BEGIN
  IF aa>nn THEN nn:=aa;
  IF ab>nn THEN nn:=ab;
  IF ac>nn THEN nn:=ac;
  IF ad>nn THEN nn:=ad;
 END;
 a_ptr:=a_ptr^.anext
END;

e_ptr:=E_head;
WHILE e_ptr<>NIL DO BEGIN
 WITH e_ptr^ DO BEGIN
  IF ea>nn THEN nn:=ea;
  IF eb>nn THEN nn:=eb;
  IF ec>nn THEN nn:=ec;
  IF ed>nn THEN nn:=ed;
 END;
 e_ptr:=e_ptr^.enext
END;

f_ptr:=F_head;
WHILE f_ptr<>NIL DO BEGIN
 WITH f_ptr^ DO BEGIN
  IF fa>nn THEN nn:=fa;
  IF fb>nn THEN nn:=fb;
  IF fc>nn THEN nn:=fc;
  IF fd>nn THEN nn:=fd;
 END;
 f_ptr:=f_ptr^.fnext
END;

h_ptr:=H_head;
WHILE h_ptr<>NIL DO BEGIN
 WITH h_ptr^ DO BEGIN
  IF ha>nn THEN nn:=ha;
  IF hb>nn THEN nn:=hb;
  IF hc>nn THEN nn:=hc;
  IF hd>nn THEN nn:=hd;
 END;
 h_ptr:=h_ptr^.hnext
END;

n_ptr:=N_head;
WHILE n_ptr<>NIL DO BEGIN
 WITH n_ptr^ DO BEGIN
  IF na>nn THEN nn:=na;
  IF nb>nn THEN nn:=nb;
  IF nc>nn THEN nn:=nc;
  IF nd>nn THEN nn:=nd;
 END;
 n_ptr:=n_ptr^.nnext
END;

b_ptr:=B_head;
WHILE b_ptr<>NIL DO
BEGIN
 WITH b_ptr^ DO
 BEGIN
  for i:=1 to bndim do begin
    if bnodes[i]>nn then nn:=bnodes[i];
  end;
 END;
 b_ptr:=b_ptr^.bnext
END;

t_ptr:=T_head;
WHILE t_ptr<>NIL DO BEGIN
 WITH t_ptr^ DO BEGIN
  IF ta>nn THEN nn:=ta;
  IF tb>nn THEN nn:=tb;
  IF tc>nn THEN nn:=tc;
 END;
 t_ptr:=t_ptr^.tnext
END;

v_ptr:=V_head;
WHILE v_ptr<>NIL DO BEGIN
 WITH v_ptr^ DO BEGIN
  IF va>nn THEN nn:=va;
  IF vb>nn THEN nn:=vb;
 END;
 v_ptr:=v_ptr^.vnext
END;

i_ptr:=I_head;
WHILE i_ptr<>NIL DO BEGIN
 WITH i_ptr^ DO BEGIN
  IF ia>nn THEN nn:=ia;
  IF ib>nn THEN nn:=ib;
 END;
 i_ptr:=i_ptr^.inext
END;

p_ptr:=P_head;
WHILE p_ptr<>NIL DO BEGIN
 WITH p_ptr^ DO BEGIN
  IF pa>nn THEN nn:=pa;
  IF pb>nn THEN nn:=pb;
  if (( ptype=PROBE_TU) or (ptype=PROBE_TI) or (ptype=PROBE_TN) or (ptype=PROBE_TM)) then begin
    IF pc>nn THEN nn:=pc;
    IF pd>nn THEN nn:=pd;
  end;
 END;
 p_ptr:=p_ptr^.pnext
END;

END;{FNN}



{********************************************************}
{*******  Check single node                   ***********}
{********************************************************}

FUNCTION Check_Node(nx:INTEGER):BOOLEAN;
begin
     result:=TRUE;
     if (nx>=0) AND (nx<=nmax) then
        INC( check_nodes[nx+1])
     else
     begin
        result:=FALSE;
     end;
end;

{********************************************************}
{*******  Check single node                   ***********}
{********************************************************}

Procedure Report_node_err(xname:symb; xn:INTEGER);
VAR
  s_node:string;
BEGIN
    STR(xn,s_node);
    CLEAR_LINE;
    s_node:=CONCAT('!ERROR - WRONG NODE NUMBER: '+ s_node +' IN COMPONENT ', xname);
    INSERT(s_node,line,1);
    INVALID_NODE_ERROR;
END;

{********************************************************}
{*******  Check nodes numbering               ***********}
{********************************************************}

Procedure Check_nodes_numbers;
Var

 k:INTEGER;
 i:INTEGER;

 y_ptr:yptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 a_ptr:aptr;
 g_ptr:gptr;
 z_ptr:zptr;
 b_ptr:bptr;
 t_ptr:tptr;
 v_ptr:vptr;
 i_ptr:iptr;
 p_ptr:pptr;
BEGIN

  For k:=1 to nmax+1 do check_nodes[k]:=0;

  y_ptr:=Y_head;
  WHILE y_ptr <> NIL DO BEGIN
    WITH y_ptr^ DO BEGIN
      if (Check_Node(ya)=FALSE) then Report_node_err(yname,ya);
      if (Check_Node(yb)=FALSE) then Report_node_err(yname,yb);
    END;
    y_ptr:=y_ptr^.ynext;
  END;

  z_ptr:=Z_head;
  WHILE z_ptr<>NIL DO BEGIN
    WITH z_ptr^ DO BEGIN
      if (Check_Node(za)=FALSE) then Report_node_err(zname,za);
      if (Check_Node(zb)=FALSE) then Report_node_err(zname,zb);
    END;
    z_ptr:=z_ptr^.znext
  END;

  r_ptr:=R_head;
  WHILE r_ptr<>NIL DO BEGIN
    WITH r_ptr^ DO BEGIN
      if (Check_Node(ra)=FALSE) then Report_node_err(rname,ra);
      if (Check_Node(rb)=FALSE) then Report_node_err(rname,rb);
    END;
    r_ptr:=r_ptr^.rnext
  END;

  c_ptr:=C_HEAD;
  WHILE c_ptr<>NIL DO BEGIN
    WITH c_ptr^ DO BEGIN
      if (Check_Node(ca)=FALSE) then Report_node_err(cname,ca);
      if (Check_Node(cb)=FALSE) then Report_node_err(cname,cb);
    END;
    c_ptr:=c_ptr^.cnext
  END;

  l_ptr:=L_head; { node lc is only to mark the current HIL }
  WHILE l_ptr<>NIL DO BEGIN
    WITH l_ptr^ DO BEGIN
      if (Check_Node(la)=FALSE) then Report_node_err(lname,la);
      if (Check_Node(lb)=FALSE) then Report_node_err(lname,lb);
    END;
    l_ptr:=l_ptr^.lnext
  END;

  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO BEGIN
    WITH g_ptr^ DO BEGIN
      if (Check_Node(ga)=FALSE) then Report_node_err(gname,ga);
      if (Check_Node(gb)=FALSE) then Report_node_err(gname,gb);
      if (Check_Node(gc)=FALSE) then Report_node_err(gname,gc);
      if (Check_Node(gd)=FALSE) then Report_node_err(gname,gd);
    END;
    g_ptr:=g_ptr^.gnext
  END;

  a_ptr:=A_head;
  WHILE a_ptr<>NIL DO BEGIN
    WITH a_ptr^ DO BEGIN
      if (Check_Node(aa)=FALSE) then Report_node_err(aname,aa);
      if (Check_Node(ab)=FALSE) then Report_node_err(aname,ab);
      if (Check_Node(ac)=FALSE) then Report_node_err(aname,ac);
      if (Check_Node(ad)=FALSE) then Report_node_err(aname,ad);
    END;
    a_ptr:=a_ptr^.anext
  END;

  b_ptr:=B_head;
  WHILE b_ptr<>NIL DO BEGIN
    WITH b_ptr^ DO BEGIN
      for i:=1 to bndim do begin
        if (Check_Node(bnodes[i])=FALSE) then Report_node_err(bname,bnodes[i]);
      end;
    END;
  b_ptr:=b_ptr^.bnext
  END;

  t_ptr:=T_head;
  WHILE t_ptr<>NIL DO BEGIN
    WITH t_ptr^ DO BEGIN
      if (Check_Node(ta)=FALSE) then Report_node_err(tname,ta);
      if (Check_Node(tb)=FALSE) then Report_node_err(tname,tb);
      if (Check_Node(tc)=FALSE) then Report_node_err(tname,tc);
    END;
    t_ptr:=t_ptr^.tnext
  END;

  v_ptr:=V_head;
  WHILE v_ptr <> NIL DO BEGIN
    WITH v_ptr^ DO BEGIN
      if (Check_Node(va)=FALSE) then Report_node_err(vname,va);
      if (Check_Node(vb)=FALSE) then Report_node_err(vname,vb);
    END;
    v_ptr:=v_ptr^.vnext;
  END;

  i_ptr:=I_head;
  WHILE i_ptr <> NIL DO BEGIN
    WITH i_ptr^ DO BEGIN
      if (Check_Node(ia)=FALSE) then Report_node_err(iname,ia);
      if (Check_Node(ib)=FALSE) then Report_node_err(iname,ib);
    END;
    i_ptr:=i_ptr^.inext;
  END;

  p_ptr:=P_head;
  WHILE p_ptr <> NIL DO BEGIN
    WITH p_ptr^ DO BEGIN
      if (Check_Node(pa)=FALSE) then Report_node_err(pname,pa);
      if (Check_Node(pb)=FALSE) then Report_node_err(pname,pb);
      if (( ptype=PROBE_TU) or (ptype=PROBE_TI) or (ptype=PROBE_TN) or (ptype=PROBE_TM)) then begin
        if (Check_Node(pc)=FALSE) then Report_node_err(pname,pc);
        if (Check_Node(pd)=FALSE) then Report_node_err(pname,pd);
      end;
    END;
    p_ptr:=p_ptr^.pnext;
  END;


{ THERE ARE NO  EFHNBT components only YZGRLCA }

END;{Check node numbers}



{****************************************************************************}
PROCEDURE CHECK_TOPOLOGY;
VAR
 k:INTEGER;
 s_node:string;
BEGIN

    Check_nodes_numbers;

    for k:=0 to nn do
    begin
      if check_nodes[k+1]=0 then
      begin
        STR(k,s_node);
        CLEAR_LINE;
        s_node:=CONCAT('NO CONNECTION IN NODE: '+ s_node );
        INSERT(s_node,line,1);
        INVALID_TOPOLOGY_ERROR;
      end;
      if check_nodes[k+1]=1 then
      begin
        STR(k,s_node);
        CLEAR_LINE;
        s_node:=CONCAT('ONE CONNECTION IN NODE: '+ s_node );
        INSERT(s_node,line,1);
        INFO(line);
        WRITELN(RESULTS,'! WARNING - 1 CONNECTIONS IN NODE ', k );
     end;
    end;
    { check_nodes[nn+1]<>0  are o'k}
    { nodes[k>nn+1]<>0  are not o'k}
    for  k:=nn+2 to nmax  do begin
      if check_nodes[k]<>0 then begin
        STR(k,s_node);
        CLEAR_LINE;
        s_node:=CONCAT('INTERNAL ERROR NODE NUMBER: '+ s_node  +' IS GREATER THEN nn ???');
        INSERT(s_node,line,1);
        INTERNAL_ERROR;
      end;
    end;

END;


{****************************************************************************}
{*  CHECK  MACROMODELS  CALLS*}
PROCEDURE MACRO_NODES;
VAR
 line_pt:listapt;
 macro_node:INTEGER;
BEGIN
 line_pt:=LIB_CALLS_PT;
 WHILE line_pt<>NIL DO
 BEGIN
  line:=line_pt^.oneline;
  xx:=FALSE;
  {* cpt1:=FND('#','#',1); *}       {* SKIP PREFIX *}
  {* cpt1:=FND('a','~',cpt1); *}    {* SKIP NAME   *}
  cpt1:=FND('A','~',1);             {* SKIP Xname   *}
  cpt1:=FND(' ',' ',cpt1);

  cpt2:=cpt1;
  WHILE NOT xx DO
  BEGIN
   RIN;macro_node:=itg;
   IF macro_node>nn THEN nn:=macro_node;
  END;
  line_pt:=line_pt^.lpt
 END
END;





END.
