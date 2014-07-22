UNIT MATRIX8;
INTERFACE

USES
 TYPE8,VAR8;

VAR
 nm,cs:INTEGER;
 fcf,flu:BOOLEAN;
 omega,freqency:DOUBLE;
 dre,dim,dm,dp:DOUBLE;
 cnb:STRING;

PROCEDURE CCOFF(j:taskpt;cpt:dptr);

IMPLEMENTATION

PROCEDURE CCOFF(j:taskpt;cpt:dptr);

TYPE
 rmat=ARRAY[1..nmax,1..nmax] OF DOUBLE;
VAR
  YRE,YIM,YR:rmat;
  dpt:drpt;
  fpt:listbpt;
{********************************************************}
{*******      input value to matrix YR       ************}
{********************************************************}

PROCEDURE IVRE(RTX,CTX:tmat);
VAR
 i,j:INTEGER;
 y_ptr:yptr;
 r_ptr:rptr;
 g_ptr:gptr;
 z_ptr:zptr;

 PROCEDURE IMR(a,b:INTEGER;v:REAL);
 BEGIN
  IF (a<>0)AND(b<>0) THEN YR[a,b]:=YR[a,b]+v
 END;

BEGIN {IVRE}
 FOR i:=1 TO nm DO
  FOR j:=1 TO nm DO
   YR[i,j]:=0.0;

  y_ptr:=Y_head;
  WHILE y_ptr<>NIL DO
  BEGIN
   WITH y_ptr^ DO
   BEGIN
    if ( yvar<>GEN ) then begin  {GEN is virtual component}
      IMR(RTX[ya+1],CTX[ya+1],+yvre);
      IMR(RTX[yb+1],CTX[yb+1],+yvre);
      IMR(RTX[ya+1],CTX[yb+1],-yvre);
      IMR(RTX[yb+1],CTX[ya+1],-yvre)
    end;
   END;
   y_ptr:=y_ptr^.ynext
  END;


  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO
  BEGIN
   WITH g_ptr^ DO
   BEGIN
    if ( gvar<>GEN ) then begin  {GEN is virtual component}
    IMR(RTX[ga+1],CTX[gc+1],+gvre);               { updated on 13.01.2007 }
    IMR(RTX[gb+1],CTX[gd+1],+gvre);               { updated on 13.01.2007 }
    IMR(RTX[ga+1],CTX[gd+1],-gvre);               { updated on 13.01.2007 }
    IMR(RTX[gb+1],CTX[gc+1],-gvre)                { updated on 13.01.2007 }
    end;
   END;
   g_ptr:=g_ptr^.gnext
  END;

  z_ptr:=Z_head;
  WHILE z_ptr<>NIL DO
  BEGIN
   WITH z_ptr^ DO
   BEGIN
    IMR(RTX[za+1],CTX[za+1],+zvre/(zvre*zvre+zvim*zvim));
    IMR(RTX[zb+1],CTX[zb+1],+zvre/(zvre*zvre+zvim*zvim));
    IMR(RTX[za+1],CTX[zb+1],-zvre/(zvre*zvre+zvim*zvim));
    IMR(RTX[zb+1],CTX[za+1],-zvre/(zvre*zvre+zvim*zvim))
   END;
   z_ptr:=z_ptr^.znext
  END;

  r_ptr:=R_head;
  WHILE r_ptr<>NIL DO
  BEGIN
   WITH r_ptr^ DO
   BEGIN
    if ( rvar<>GEN ) then begin  {GEN is virtual component}
    IMR(RTX[ra+1],CTX[ra+1],+1.0/rv);
    IMR(RTX[rb+1],CTX[rb+1],+1.0/rv);
    IMR(RTX[ra+1],CTX[rb+1],-1.0/rv);
    IMR(RTX[rb+1],CTX[ra+1],-1.0/rv)
    end;
   END;
   r_ptr:=r_ptr^.rnext
  END;

 END; {IVRE}


{********************************************************}
{*******    input value to matrix  YIM       ************}
{********************************************************}

PROCEDURE IVIM(RTX,CTX:tmat);
VAR

 c_ptr:cptr;
 l_ptr:lptr;
 y_ptr:yptr;
 g_ptr:gptr;
 z_ptr:zptr;

 PROCEDURE IMI(a,b:INTEGER;v:REAL);
 BEGIN
  IF (a<>0)AND(b<>0) THEN YIM[a,b]:=YIM[a,b]+v
 END;

BEGIN {IVIM}
 omega:=2.0*Pi*freqency;

  if ( omega > 0.0 ) then begin
    c_ptr:=C_head;
    WHILE c_ptr<>NIL DO
    BEGIN
      WITH c_ptr^ DO
      BEGIN
        IMI(RTX[ca+1],CTX[ca+1],+cv*omega);
        IMI(RTX[cb+1],CTX[cb+1],+cv*omega);
        IMI(RTX[ca+1],CTX[cb+1],-cv*omega);
        IMI(RTX[cb+1],CTX[ca+1],-cv*omega)
      END;
      c_ptr:=c_ptr^.cnext
    END;

    l_ptr:=L_head;
    WHILE l_ptr<>NIL DO
    BEGIN
      WITH l_ptr^ DO
      BEGIN
        IMI(RTX[la+1],CTX[la+1],-1/(lv*omega));
        IMI(RTX[lb+1],CTX[lb+1],-1/(lv*omega));
        IMI(RTX[la+1],CTX[lb+1],+1/(lv*omega));
        IMI(RTX[lb+1],CTX[la+1],+1/(lv*omega))
      END;
      l_ptr:=l_ptr^.lnext
    END;

  end;

  y_ptr:=Y_head;
  WHILE y_ptr<>NIL DO
  BEGIN
   WITH y_ptr^ DO
   BEGIN
    if ( yvar<>GEN ) then begin  {GEN is virtual component}
      IMI(RTX[ya+1],CTX[ya+1],+yvim);
      IMI(RTX[yb+1],CTX[yb+1],+yvim);
      IMI(RTX[ya+1],CTX[yb+1],-yvim);
      IMI(RTX[yb+1],CTX[ya+1],-yvim)
    end;
   END;
   y_ptr:=y_ptr^.ynext
  END;

  g_ptr:=G_head;
  WHILE g_ptr<>NIL DO
  BEGIN
   WITH g_ptr^ DO
   BEGIN
    if ( gvar<>GEN ) then begin  {GEN is virtual component}
    IMI(RTX[ga+1],CTX[gc+1],+gvim);
    IMI(RTX[gb+1],CTX[gd+1],+gvim);
    IMI(RTX[ga+1],CTX[gd+1],-gvim);
    IMI(RTX[gb+1],CTX[gc+1],-gvim)
    end;
   END;
   g_ptr:=g_ptr^.gnext
  END;

  z_ptr:=Z_head;
  WHILE z_ptr<>NIL DO
  BEGIN
   WITH z_ptr^ DO
   BEGIN
    IMI(RTX[za+1],CTX[za+1],-zvim/(zvre*zvre+zvim*zvim));
    IMI(RTX[zb+1],CTX[zb+1],-zvim/(zvre*zvre+zvim*zvim));
    IMI(RTX[za+1],CTX[zb+1],+zvim/(zvre*zvre+zvim*zvim));
    IMI(RTX[zb+1],CTX[za+1],+zvim/(zvre*zvre+zvim*zvim))
   END;
   z_ptr:=z_ptr^.znext
  END;

END;{IVIM}

{********************************************************}
{*******         create  dc   matrix         ************}
{********************************************************}

PROCEDURE CDCM;
VAR
 i,j:INTEGER;
BEGIN
 FOR i:=1 TO nm DO
  FOR j:=1 TO nm DO
   BEGIN
    YRE[i,j]:=YR[i,j];
    YIM[i,j]:=0.0
   END;

END; {CDCM}

{********************************************************}
{*******  LU transfomation for YRE & YIM     ************}
{********************************************************}

PROCEDURE LUT;
VAR
 i,j,k,l,rmx:INTEGER;
 ymx,yreb,yimb:DOUBLE;
 ROW:tmat;                           { is it used anyway, it is set properly, but only local variable}

 PROCEDURE CME;                      { CME - change maximum element  }
 VAR
  k,m:INTEGER;
  ym,yrb,yib:DOUBLE;
  BEGIN
   ymx:=YRE[i,i]*YRE[i,i]+YIM[i,i]*YIM[i,i];   { square module of is the metrics }
   rmx:=i;                                     { element abs(Y[i,i]) is reference}
   FOR m:=i+1 TO nm DO                         { search for elements in column i below}
   BEGIN
    ym:=YRE[m,i]*YRE[m,i]+YIM[m,i]*YIM[m,i];
    IF ym>ymx THEN
     BEGIN
      ymx:=ym;rmx:=m                           { if greater remember it in rmx - row with max element in i column }
     END
    END;
   IF rmx<>i THEN
   BEGIN
    FOR k:=1 TO nm DO                         { swap }
    BEGIN
     yrb:=YRE[i,k];
     yib:=YIM[i,k];
     YRE[i,k]:=YRE[rmx,k];
     YIM[i,k]:=YIM[rmx,k];
     YRE[rmx,k]:=yrb;
     YIM[rmx,k]:=yib
    END;
    cs:=cs+1                                 { after swap change sign -> cs++ }
   END;
   ROW[i]:=rmx                               { which row was the greatest one }
  END;{CME}
                      { (x1+jy1)/(x2+jy2)=(x1+jy1)*(x2-jy2)/(x2^+y2)=(x1*x2+y1*y2)/(x2^+y2)+j*(y1*x2-y2*x1)/(x^2+y^2)}
 BEGIN {LUT}          { (x1+jy1)*(x2+jy2) = (x1*x2-y1*y2)+j(x1*y2+x2*y1) }
  i:=1;
  CME;                                       { ymx is square module of element a(i,i) i.e. ymx=(Re(a[i,i])^2+Im(a[i,i])^2) }
  IF ymx=0 THEN flu:=TRUE                    { Doolitle LU decomposition  u(i,k) - first, l(j,k) - next }
  ELSE                                       { u(1,i) = a(1,i) }
   FOR j:=2 TO nm DO                         { l(j,1) = a(j,1)/u(1,1) }
   BEGIN         {b}
    yreb:=(YRE[1,j]*YRE[1,1]+YIM[1,j]*YIM[1,1])/ymx;
    yimb:=(YIM[1,j]*YRE[1,1]-YRE[1,j]*YIM[1,1])/ymx;
    YRE[1,j]:=yreb;
    YIM[1,j]:=yimb
   END;          {b}
  FOR l:=2 TO nm DO
   IF NOT flu THEN
   BEGIN {c}
    j:=l;
    FOR i:=l TO nm DO
     FOR k:=1 TO j-1 DO
     BEGIN       {d}
      yreb:=YRE[i,j];
      yimb:=YIM[i,j];
      yreb:=yreb-(YRE[i,k]*YRE[k,j]-YIM[i,k]*YIM[k,j]);
      yimb:=yimb-(YRE[i,k]*YIM[k,j]+YIM[i,k]*YRE[k,j]);
      YRE[i,j]:=yreb;
      YIM[i,j]:=yimb                         { First for given row i: j=i..N  u(i,j) : u(i,j) = a(i,j) - SUM[l(i,k)*u(k,j)] }
     END;        {d}
    i:=l;
    CME;
    IF ymx=0 THEN flu:=TRUE
    ELSE
     FOR j:=l+1 TO nm DO
     BEGIN       {e}
      FOR k:=1 TO i-1 DO
      BEGIN      {f}
       yreb:=YRE[i,j];
       yimb:=YIM[i,j];
       yreb:=yreb-(YRE[i,k]*YRE[k,j]-YIM[i,k]*YIM[k,j]);
       yimb:=yimb-(YRE[i,k]*YIM[k,j]+YIM[i,k]*YRE[k,j]);
       YRE[i,j]:=yreb;
       YIM[i,j]:=yimb
      END;       {f}
      yreb:=(YRE[i,j]*YRE[i,i]+YIM[i,j]*YIM[i,i])/ymx;
      yimb:=(YIM[i,j]*YRE[i,i]-YRE[i,j]*YIM[i,i])/ymx;
      YRE[i,j]:=yreb;
      YIM[i,j]:=yimb                    { next for given column i: j=i+1..N  l(i,j) : l(i,j) = (a(i,j) - SUM[l(i,k)*u(k,j)]/u(i,i)}
     END         {e}
    END          {c}
   END; {LUT}

{*********************************************************}
{*******       compute complex cofactor       ************}
{*********************************************************}

PROCEDURE CCC;
VAR
 k:INTEGER;
 a,b:DOUBLE;
BEGIN
 flu:=FALSE;
 IF (nm>0) THEN
 BEGIN          {a1}
  LUT;
  IF not flu THEN
  BEGIN         {b1}
   dim:=0.0;
   IF (ODD(cs)AND(cs>0)) THEN dre:=-1.0 ELSE dre:=1.0;
   FOR k:=1 TO nm DO
   BEGIN        {c1}
    a:=dre;b:=dim;
    dre:=a*YRE[k,k]-b*YIM[k,k];
    dim:=b*YRE[k,k]+a*YIM[k,k]
   END          {c1}
  END           {b1}
  ELSE
  BEGIN         {d1}
   dre:=0;dim:=0
  END           {d1}
 END            {a1}
 ELSE
 BEGIN          {a2}
  IF nm=0 THEN
  BEGIN         {b2}
   dim:=0.0;
   IF (ODD(cs)AND(cs>0)) THEN dre:=-1.0 ELSE dre:=1.0
  END           {b2}
  ELSE
  BEGIN         {c2}
   dre:=0.0;dim:=0.0
  END           {c2}
 END            {a2}
END;{CCC}


{***************************** CCOFF **************************************}

BEGIN

 fpt:=j^.FREQ_PT;
 cpt^.dcreb:=FALSE;
 WHILE fpt<>NIL DO
 BEGIN
   freqency:=fpt^.value;
   WITH cpt^ DO
   BEGIN
    IF freqency=0.0 THEN
    BEGIN
     IF ctb0 THEN
     BEGIN
      nm:=nn-lgt0;
      IVRE(RT0,CT0);
      dcreb:=FALSE;  {* MARKER - YR=RE(AC) MATRIX MUST BE REBUILD *}
      CDCM;
      IVIM(RT0,CT0); {* well, now we have complex Z,Y,G theoreticaly defined also for freq=0.0 *}
      cs:=csg0;
      CCC
     END
     ELSE
     BEGIN
      dre:=0;
      dim:=0
     END
    END
    ELSE
    BEGIN
     IF ctb THEN
     BEGIN
      nm:=nn-lgt;
      cs:=csg;
      IF NOT dcreb THEN
      BEGIN
       IVRE(RT,CT);
       dcreb:=TRUE;      {* MARKER - YR=RE(AC) MATRIX IS REBUILD     *}
      END;
      CDCM;
      IVIM(RT,CT);
      CCC
     END
     ELSE
     BEGIN
      dre:=0;
      dim:=0
     END
    END;
    IF CF_PT=NIL THEN
    BEGIN
     NEW(CF_PT);
     dpt:=CF_PT;
     drfpt:=dpt
    END
    ELSE
    BEGIN
     {* this is a change allowing multiple leaving and entering *}
     {* new  tail            is  pointed by drfpt               *}
     NEW(drfpt^.drptn);
     dpt:=drfpt^.drptn;
     drfpt:=dpt
    END;
  END;
  dpt^.red:=dre;
  dpt^.imd:=dim;
  dpt^.drptn:=NIL;

  fpt:=fpt^.vpt
 END;

END;

END.
