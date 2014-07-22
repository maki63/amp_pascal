 {***************************************************************************
 Matrix TOOLBOX

 MTB_mat_0 (ptrA,dim);
 MTB_mat_1 (ptrA,dim);
 MTB_element (ptrA; i,j; Re,Im);
 MTB_copy(ptrB,ptrA);
 MTB_transp(ptrB,ptrA);
 MTB_mulc(ptrB, ptrA,  Re_c, Im_c );
 MTB_add(ptrC, ptrA, ptrB);
 MTB_mult (ptrC, ptrA, ptrB);

 MTB_coff(ptrcoff,ptrA);
 MTB_inverse(ptrB,ptrA);

 MTB_MA2RI (ptrB,ptrA);
 MTB_DB2RI (ptrB,ptrA);
 MTB_S2Y (ptrY,ptrS; R0);

 @version - 8.B
 ***************************************************************************}

UNIT TOOLBOX8;

interface
USES
 SysUtils,
 TYPE8;

Procedure MTB_mat_0 (ptrA:matrixpt; dim:INTEGER);
Procedure MTB_mat_1 (ptrA:matrixpt; dim:INTEGER);
Procedure MTB_element (ptrA:matrixpt; i,j:INTEGER; Re,Im:DOUBLE);

Procedure MTB_copy (ptrB,ptrA:matrixpt);
Procedure MTB_transp (ptrB,ptrA:matrixpt);
Procedure MTB_multc( ptrB,ptrA:matrixpt;  Re_c, Im_c:double );

Procedure MTB_add( ptrC,ptrA,ptrB:matrixpt);
Procedure MTB_sub( ptrC,ptrA,ptrB:matrixpt);
Procedure MTB_mult( ptrC,ptrA,ptrB:matrixpt);

Procedure MTB_coff_0 (ptrcoff:coffpt);
Procedure MTB_coff_add (ptrcoff:coffpt; w,r,k,l:INTEGER);
Procedure MTB_coff(ptrcoff:coffpt;ptrA:matrixpt);
Procedure MTB_inverse(ptrB,ptrA:matrixpt);

Procedure MTB_MA2RI (ptrB,ptrA:matrixpt);
Procedure MTB_DB2RI (ptrB,ptrA:matrixpt);
Procedure MTB_S2Y (ptrY,ptrS:matrixpt; R0:double);

function Power(Base, Exponent : Double) : Double;

{***************************************************************************}
{***************************************************************************}
{***************************************************************************}
implementation

USES Amp8_main;

{** }
{***************************************************************************
 Power function that does not come with Delphi3.
 A power function from Jack Lyle. Said to be more powerful than the


 @version - 1.0
 @param   Base:Double;
 @param   Exponent:Double;
 ***************************************************************************}


function Power(Base, Exponent : Double) : Double;
{ raises the base to the exponent }
  CONST
    cTiny = 1e-15;

  VAR
    VPower : Double; { Value before sign correction }

  BEGIN
    VPower := 0;
    { Deal with the near zero special cases }
    IF (Abs(Base) < cTiny) THEN BEGIN
      Base := 0.0;
    END; { IF }
    IF (Abs(Exponent) < cTiny) THEN BEGIN
      Exponent := 0.0;
    END; { IF }

    { Deal with the exactly zero cases }
    IF (Base = 0.0) THEN BEGIN
      VPower := 0.0;
    END; { IF }
    IF (Exponent = 0.0) THEN BEGIN
      VPower := 1.0;
    END; { IF }

    { Cover everything else }
    IF ((Base < 0) AND (Exponent < 0)) THEN
        VPower := 1/Exp(-Exponent*Ln(-Base))
    ELSE IF ((Base < 0) AND (Exponent >= 0)) THEN
        VPower := Exp(Exponent*Ln(-Base))
    ELSE IF ((Base > 0) AND (Exponent < 0)) THEN
        VPower := 1/Exp(-Exponent*Ln(Base))
    ELSE IF ((Base > 0) AND (Exponent >= 0)) THEN
        VPower := Exp(Exponent*Ln(Base));

    { Correct the sign }
    IF ((Base < 0) AND (Frac(Exponent/2.0) <> 0.0)) THEN
      Result := -VPower
    ELSE
      Result := VPower;
  END; { FUNCTION Pow }


{***************************************************************************
 MTB_mat_0 - zero 0 matrix [dim x dim]

 @version - 1.0
 @param   ptrA:matrixpt;
 @param   dim:INTEGER;
 ***************************************************************************}

Procedure MTB_mat_0 (ptrA:matrixpt; dim:INTEGER);
VAR
  i,j:INTEGER;
BEGIN
   if ( ptrA=NIL ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;
   if ( dim<=0 ) then begin
    MATRIX_TOOLBOX_DIM_ERROR;
   end;
   for  i:=1 to dim do begin
    for j:=1 to dim do begin
      ptrA^.ymat[i,j].Re:=0.0;
      ptrA^.ymat[i,j].Im:=0.0;
    end;
   end;
  ptrA^.matcol:=dim;
  ptrA^.matrow:=dim;
  ptrA^.fmat:=0.0;
  ptrA^.next_f_mat_pt:=NIL;
END;

{***************************************************************************
 MTB_mat_1 - 1 matrix [dim x dim]

 @version - 1.0
 @param   ptrA:matrixpt;
 @param   dim:INTEGER;
 ***************************************************************************}

Procedure MTB_mat_1 (ptrA:matrixpt; dim:INTEGER);
VAR
  i,j:INTEGER;
BEGIN

   if ( ptrA=NIL ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;
   if ( dim<=0 ) then begin
    MATRIX_TOOLBOX_DIM_ERROR;
   end;

   for  i:=1 to dim do begin
    for j:=1 to dim do begin
      if ( i=j ) then begin
        ptrA^.ymat[i,j].Re:=1.0;
      end
      else begin
        ptrA^.ymat[i,j].Re:=0.0;
      end;
      ptrA^.ymat[i,j].Im:=0.0;
    end;
  end;
  ptrA^.matcol:=dim;
  ptrA^.matrow:=dim;
  ptrA^.fmat:=0.0;
  ptrA^.next_f_mat_pt:=NIL;
END;

{***************************************************************************
 MTB_copy - B:=A

 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_element (ptrA:matrixpt; i,j:INTEGER; Re,Im:DOUBLE);
BEGIN

   if ( ptrA=NIL ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   if ( (i>ptrA^.matrow) or (j>ptrA^.matcol) ) then begin
    MATRIX_TOOLBOX_DIM_ERROR;
   end;

   if ( (i<=0) or (j<=0) ) then begin
    MATRIX_TOOLBOX_DIM_ERROR;
   end;

   ptrA^.ymat[i,j].Re:=Re;
   ptrA^.ymat[i,j].Im:=Im;

END;

{***************************************************************************
 MTB_copy - B:=A

 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_copy (ptrB,ptrA:matrixpt);
VAR
  i,j:INTEGER;

BEGIN

   if ( (ptrA=NIL) or (ptrB=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;


   for  i:=1 to ptrB^.matrow do begin
    for j:=1 to ptrB^.matcol do begin
      ptrB^.ymat[i,j].Re:=ptrA^.ymat[i,j].Re;
      ptrB^.ymat[i,j].Im:=ptrA^.ymat[i,j].Im;
    end;
   end;
  ptrB^.matcol:=ptrA^.matcol;
  ptrB^.matrow:=ptrA^.matrow;
  ptrB^.fmat:=ptrA^.fmat;
  ptrB^.next_f_mat_pt:=NIL;

END;

{***************************************************************************
 MTB_transp - B:=A^T
 will it work if ptrB=ptrA
 works only for square matrixes (?)
 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_transp (ptrB,ptrA:matrixpt);
VAR
  i,j:INTEGER;
  XRe,XIm:DOUBLE;
BEGIN

   if ( (ptrA=NIL) or (ptrB=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   if ( ptrB <> ptrA ) then begin
      MTB_copy(ptrB,ptrA);
   end;

   for  i:=1 to ptrA^.matrow do begin
    for j:=i+1 to ptrA^.matcol do begin
      XRe:=ptrB^.ymat[j,i].Re;          { swap b[i,j] <-> b[j,i] }
      XIm:=ptrB^.ymat[j,i].Im;
      ptrB^.ymat[j,i].Re:=ptrA^.ymat[i,j].Re;
      ptrB^.ymat[j,i].Im:=ptrA^.ymat[i,j].Im;
      ptrB^.ymat[i,j].Re:=XRe;
      ptrB^.ymat[i,j].Im:=XIm;
    end;
  end;

  if ( ptrB <> ptrA ) then begin
    ptrB^.matcol:=ptrA^.matrow;
    ptrB^.matrow:=ptrA^.matcol;
    ptrB^.fmat:=ptrA^.fmat;
    ptrB^.next_f_mat_pt:=NIL;
  end;

END;


{***************************************************************************
 MTB_multc - B:=c*A

 (x1+jy1)*(x2+jy2) = (x1*x2-y1*y2)+j(x1*y2+x2*y1)
 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 @param   Re_c,Im_c:double;
 ***************************************************************************}

Procedure MTB_multc( ptrB,ptrA:matrixpt;  Re_c, Im_c:double );
VAR
  i,j:INTEGER;
BEGIN

   if ( (ptrA=NIL) or (ptrB=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

  for  i:=1 to ptrA^.matrow do begin
   for j:=1 to ptrA^.matcol do begin
      ptrB^.ymat[i,j].Re:= ptrA^.ymat[i,j].Re*Re_c - ptrA^.ymat[i,j].Im*Im_c;
      ptrB^.ymat[i,j].Im:= ptrA^.ymat[i,j].Re*Im_c + ptrA^.ymat[i,j].Im*Re_c;
    end;
  end;
  ptrB^.matcol:=ptrA^.matcol;
  ptrB^.matrow:=ptrA^.matrow;
  ptrB^.fmat:=ptrA^.fmat;
  ptrB^.next_f_mat_pt:=NIL;
END;


{***************************************************************************
 MTB_add - C:=A+B


 @version - 1.0
 @param   ptrC,ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_add( ptrC,ptrA,ptrB:matrixpt);
VAR
  i,j:INTEGER;
BEGIN

  if ( (ptrA=NIL) or (ptrB=NIL) or (ptrC=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
  end;

  if ( (ptrA^.matcol<>ptrB^.matcol) or  (ptrA^.matrow<>ptrB^.matrow) ) then begin
     MATRIX_TOOLBOX_DIM_ERROR;
  end;

  for  i:=1 to ptrA^.matrow do begin
    for j:=1 to ptrA^.matcol do begin
      ptrC^.ymat[i,j].Re:= ptrA^.ymat[i,j].Re + ptrB^.ymat[i,j].Re;
      ptrC^.ymat[i,j].Im:= ptrA^.ymat[i,j].Im + ptrB^.ymat[i,j].Im;
    end;
  end;
  ptrC^.matcol:=ptrA^.matcol;
  ptrC^.matrow:=ptrA^.matrow;
  ptrC^.fmat:=ptrA^.fmat;
  ptrC^.next_f_mat_pt:=NIL;
END;

{***************************************************************************
 MTB_sub - C:=A-B


 @version - 1.0
 @param   ptrC,ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_sub( ptrC,ptrA,ptrB:matrixpt);
VAR
  i,j:INTEGER;
BEGIN

  if ( (ptrA=NIL) or (ptrB=NIL) or (ptrC=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
  end;

  if ( (ptrA^.matcol<>ptrB^.matcol) or  (ptrA^.matrow<>ptrB^.matrow) ) then begin
     MATRIX_TOOLBOX_DIM_ERROR;
  end;

  for  i:=1 to ptrA^.matrow do begin
    for j:=1 to ptrA^.matcol do begin
      ptrC^.ymat[i,j].Re:= ptrA^.ymat[i,j].Re - ptrB^.ymat[i,j].Re;
      ptrC^.ymat[i,j].Im:= ptrA^.ymat[i,j].Im - ptrB^.ymat[i,j].Im;
    end;
  end;
  ptrC^.matcol:=ptrA^.matcol;
  ptrC^.matrow:=ptrA^.matrow;
  ptrC^.fmat:=ptrA^.fmat;
  ptrC^.next_f_mat_pt:=NIL;
END;

{***************************************************************************
 MTB_mult - C:=A*B

 C[i,j]=A[i,k]*B[k,j]
 (x1+jy1)*(x2+jy2) = (x1*x2-y1*y2)+j(x1*y2+x2*y1)
 @version - 1.0
 @param   ptrC,ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_mult( ptrC,ptrA,ptrB:matrixpt);
VAR
  i,j,k:INTEGER;
  rsum,isum:DOUBLE;
BEGIN

  if ( (ptrA=NIL) or (ptrB=NIL) or (ptrC=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
  end;

  if ( (ptrA^.matcol<>ptrB^.matrow) ) then begin
    MATRIX_TOOLBOX_DIM_ERROR;
  end;

  for  i:=1 to ptrA^.matrow do begin
    for j:=1 to ptrB^.matcol do begin
      rsum := 0.0;
      isum := 0.0;
      for k:=1 to ptrA^.matcol do begin
        rsum := rsum + (ptrA^.ymat[i,k].Re)*(ptrB^.ymat[k,j].Re)-(ptrA^.ymat[i,k].Im)*(ptrB^.ymat[k,j].Im);
        isum := isum + (ptrA^.ymat[i,k].Re)*(ptrB^.ymat[k,j].Im)+(ptrA^.ymat[i,k].Im)*(ptrB^.ymat[k,j].Re);
      end;
      ptrC^.ymat[i,j].Re:= rsum;
      ptrC^.ymat[i,j].Im:= isum;
    end;
  end;
  ptrC^.matcol:=ptrA^.matcol;
  ptrC^.matrow:=ptrB^.matrow;
  ptrC^.fmat:=ptrA^.fmat;
  ptrC^.next_f_mat_pt:=NIL;
END;

{***************************************************************************
 TB_CTM updated version of CTM - ancient version using global varaibles
 TM represents the results of transformations included in coffactor string
 Ordered coffactor is transformed into matrix which should be applied
 according to equation
    Y[i,j]=Y[i,j]+ X[TM(i+1),TM(j+1)]
 i.e:
  row i becomes TM(i+1)
  column j becomes TM(j+1)
  0 means row is deleted

 @version - 2.0
 @param   ptr_ecoff:ecoffpt - elementary coffactor
 ***************************************************************************}

Procedure  TB_CTM(ptr_ecoff:ecoffpt);

VAR
 x:COFFMAT_TYPE;
 y:TMAT_TYPE;
 l:INTEGER;

 i,j,m,c:INTEGER;
 BEGIN {CTM}
  x:=ptr_ecoff^.x;        { assign values }
  y:=ptr_ecoff^.TM;
  l:=ptr_ecoff^.lc;

  FOR i:=1 TO matmaxdim+1 DO y[i]:=i-1;  { reset TM - TM=[0,1,2,3,4,5....] means no ops on row or column }

  FOR i:=1 TO l DO
   FOR j:=1 TO matmaxdim+1 DO
    IF y[j]=x[1,i] THEN y[j]:=x[2,i];     { (w+r) w->r w is added to r, w is deleted }

  { have to renumber nodes from 0,1,2,..... }
  { i.e. smalest number becomes 1 }
  { this seems far from optimal, but was working for years - don't touch now }
  IF l<>0 THEN
  BEGIN                  {a}
   c:=1;
   REPEAT
   BEGIN                 {b}
    i:=1;m:=9999;
    REPEAT
    BEGIN                {c}
     IF (y[i]>=c) AND (y[i]<m) THEN m:=y[i];
     i:=i+1
    END                  {c}
    UNTIL (i>(matmaxdim+1)) OR (m=c);
    FOR j:=1 TO matmaxdim+1 DO IF y[j]=m THEN y[j]:=c;
    c:=c+1
    END                  {b}
    UNTIL c>(matmaxdim+1)
  END;                   {a}
  ptr_ecoff^.TM:=y;

 END; {CTM}



{***************************************************************************
 TB_PCR updated version of PCR - ancient version using global varaibles

 global variables:
 lc - lenght
 (a1+b1)(a2+b2)(a3+b3)..... is kept in cf
 [a1,a2,a3,....]
 [b1,b2,b3,....]
 cofactor is passed by a variable, so that properly ordered is returned.
 The interpretation of indexes is :
 add row(col) ai to bi and remove row (col)ai
 0 means not existing row
 Putting in order means sorting in the way the operations can be carried seamlessly
 from first index to the last without any clash (i.e. attempt to delete no existing row)

 global input/output:
 lc: lenght of coffactor - might be changed by operation of removal of (0+0)(0+0)

 global output:
 fcf - TRUE - fail in coffactor order
 cs - change sign counter includes sum of deleted rows(columns) ai


 @version - 2.0
 @param   ptr_ecoff:ecoffpt - elementary coffactor
 ***************************************************************************}

Procedure  TB_PCR(ptr_ecoff:ecoffpt);

 VAR
 r:BOOLEAN;                               {r=TRUE  means that check is in order }
 k,b1,b2,p,s:INTEGER;
 x:COFFMAT_TYPE;
 fcf:BOOLEAN;
 lc:INTEGER;
 cs:INTEGER;

 {*
   M from match - Find index x[1,p] in following cells i.e (p..lc)
   - if found - M=TRUE
   using p as global

 *}
 FUNCTION M:BOOLEAN;
 VAR
  k:INTEGER;
 BEGIN
  M:=FALSE;
  FOR k:=p+1 TO lc DO
  IF ((x[1,k]=x[1,p]) OR (x[2,k]=x[1,p])) THEN M:=TRUE;
 END; {M}


 BEGIN {pcr}

 lc:=ptr_ecoff^.lc;
 cs:=ptr_ecoff^.cs;
 x:=ptr_ecoff^.x;

 fcf:=FALSE;

 p:=1; { pointer to first index }
 WHILE ((p<=lc)AND(NOT fcf)) DO            { fcf - is fail in coffactor order}
 BEGIN {a}
  s:=lc-p;                                { s is a swap counter }
  REPEAT
  BEGIN {b}
    r:=FALSE;                             { r - repeated value in following indexes ai - is current pointed by p }
    IF (x[1,p]=0)AND(x[2,p]<>0) THEN      { this is kind of (0+ai) -> change to (ai+0) and cs++ }
    BEGIN
     x[1,p]:=x[2,p];x[2,p]:=0;cs:=cs+1
    END;
    IF x[1,p]<>x[2,p] THEN                {if (ai=bi) then 0 }
    BEGIN {c}
      r:=M;                               { check if ai appears in next indexes }
      IF r THEN
      BEGIN {d}
        IF x[2,p]<>0 THEN                 { if yes try to swap ai<->bi and check again }
        BEGIN {e}
          b1:=x[1,p];x[1,p]:=x[2,p];x[2,p]:=b1;
          cs:=cs+1;                       { (ai+bi) -> (bi+ai) and cs++ }
          r:=M;
        END {e};
        IF r  THEN
        BEGIN
         IF s>0 THEN                     { if s > 0 there is an option for swap, so put (ai+bi) at the end of list }
         BEGIN {f}
           b1:=x[1,p];b2:=x[2,p];
           FOR k:=p TO lc-1 DO
           BEGIN {g}
             x[1,k]:=x[1,k+1];x[2,k]:=x[2,k+1]
           END; {g}
           x[1,lc]:=b1;x[2,lc]:=b2;
           s:=s-1;cs:=cs+lc-p;         { decrement swap counter }
         END {f}
         ELSE
         BEGIN
          fcf:=TRUE                { no option for swap }
         END
        END
       END {d}
     END {c}
     ELSE
     BEGIN
      IF (x[1,p]=0)AND(x[2,p]=0) THEN  { ai = bi (0+0) might be canceled }
      BEGIN
       FOR k:=p TO lc-1 DO
       BEGIN {h}
        x[1,k]:=x[1,k+1];x[2,k]:=x[2,k+1]  { remove (0+0) and decrease lenght }
       END; {h}
       lc:=lc-1;p:=p-1                     {now p must kept, thus p--  because p++ at the end the end of the loop}
      END
      ELSE fcf:=TRUE                  { (ai+ai) is something which is always 0 }
     END
  END {b}
  UNTIL((NOT r)OR fcf);               { if not r there was a swap so repeat }
  p:=p+1
END; {a}
FOR k:=1 TO lc DO
BEGIN
 FOR p:=k+1 TO lc DO
  IF x[1,p]<x[1,k] THEN cs:=cs+1;
  cs:=cs+x[1,k]
END;

 ptr_ecoff^.lc:=lc;
 ptr_ecoff^.cs:=cs;
 ptr_ecoff^.x:=x;
 ptr_ecoff^.notapp:=fcf;      { not applicable flag }

END;{pcr}

{***************************************************************************
 TB_LUT updated version of LUT - ancient version using global varaibles

 @version - 2.0
 @param   ptrcoff:coffpt - coffactor for cs and Fail of LU decomposition
 @param   ptrX:matrixpt - LU transformed
 ***************************************************************************}

PROCEDURE TB_LUT(ptrX:matrixpt; ptrcoff:coffpt );
VAR
 i,j,k,l,rmx:INTEGER;
 ymx,yreb,yimb:DOUBLE;
 ROW:tmat;                           { is it used anyway, it is set properly, but only local variable}
 Y:YMATRIX_TYPE;
 cs:INTEGER;
 flu:BOOLEAN;
 nm:INTEGER;

 PROCEDURE CME;                      { CME - change maximum element  }
 VAR
  k,m:INTEGER;
  ym,yrb,yib:DOUBLE;
  BEGIN
   ymx:=Y[i,i].Re*Y[i,i].Re+Y[i,i].Im*Y[i,i].Im;   { square module of is the metrics }
   rmx:=i;                                     { element abs(Y[i,i]) is reference}
   FOR m:=i+1 TO nm DO                         { search for elements in column i below}
   BEGIN
    ym:=Y[m,i].Re*Y[m,i].Re+Y[m,i].Im*Y[m,i].Im;
    IF ym>ymx THEN
     BEGIN
      ymx:=ym;rmx:=m                           { if greater remember it in rmx - row with max element in i column }
     END
    END;
   IF rmx<>i THEN
   BEGIN
    FOR k:=1 TO nm DO                         { swap }
    BEGIN
     yrb:=Y[i,k].Re;
     yib:=Y[i,k].Im;
     Y[i,k].Re:=Y[rmx,k].Re;
     Y[i,k].Im:=Y[rmx,k].Im;
     Y[rmx,k].Re:=yrb;
     Y[rmx,k].Im:=yib
    END;
    cs:=cs+1                                 { after swap change sign -> cs++ }
   END;
   ROW[i]:=rmx                               { which row was the greatest one }
  END;{CME}

  {----------------------------------------------------------------------------------------------}
  { (x1+jy1)/(x2+jy2)=(x1+jy1)*(x2-jy2)/(x2^+y2)=(x1*x2+y1*y2)/(x2^+y2)+j*(y1*x2-y2*x1)/(x^2+y^2)}
  { (x1+jy1)*(x2+jy2) = (x1*x2-y1*y2)+j(x1*y2+x2*y1) }
  {----------------------------------------------------------------------------------------------}

  BEGIN {LUT}
  Y:=ptrX^.ymat;
  nm:=ptrX^.matrow;
  flu:=FALSE;
  cs:=0;
  i:=1;
  CME;                                       { ymx is square module of element a(i,i) i.e. ymx=(Re(a[i,i])^2+Im(a[i,i])^2) }
  IF ymx=0.0 THEN flu:=TRUE                    { Doolitle LU decomposition  u(i,k) - first, l(j,k) - next }
  ELSE                                       { u(1,i) = a(1,i) }
   FOR j:=2 TO nm DO                         { l(j,1) = a(j,1)/u(1,1) }
   BEGIN         {b}
    yreb:=(Y[1,j].Re*Y[1,1].Re+Y[1,j].Im*Y[1,1].Im)/ymx;
    yimb:=(Y[1,j].Im*Y[1,1].Re-Y[1,j].Re*Y[1,1].Im)/ymx;
    Y[1,j].Re:=yreb;
    Y[1,j].Im:=yimb
   END;          {b}
  FOR l:=2 TO nm DO
   IF NOT flu THEN
   BEGIN {c}
    j:=l;
    FOR i:=l TO nm DO
     FOR k:=1 TO j-1 DO
     BEGIN       {d}
      yreb:=Y[i,j].Re;
      yimb:=Y[i,j].Im;
      yreb:=yreb-(Y[i,k].Re * Y[k,j].Re - Y[i,k].Im * Y[k,j].Im);
      yimb:=yimb-(Y[i,k].Re * Y[k,j].Im + Y[i,k].Im * Y[k,j].Re);
      Y[i,j].Re:=yreb;
      Y[i,j].Im:=yimb                         { First for given row i: j=i..N  u(i,j) : u(i,j) = a(i,j) - SUM[l(i,k)*u(k,j)] }
     END;        {d}
    i:=l;
    CME;
    IF ymx=0 THEN flu:=TRUE
    ELSE
     FOR j:=l+1 TO nm DO
     BEGIN       {e}
      FOR k:=1 TO i-1 DO
      BEGIN      {f}
       yreb:=Y[i,j].Re;
       yimb:=Y[i,j].Im;
       yreb:=yreb-(Y[i,k].Re * Y[k,j].Re - Y[i,k].Im * Y[k,j].Im);
       yimb:=yimb-(Y[i,k].Re * Y[k,j].Im + Y[i,k].Im * Y[k,j].Re);
       Y[i,j].Re:=yreb;
       Y[i,j].Im:=yimb
      END;       {f}
      yreb:=(Y[i,j].Re * Y[i,i].Re + Y[i,j].Im * Y[i,i].Im)/ymx;
      yimb:=(Y[i,j].Im * Y[i,i].Re - Y[i,j].Re * Y[i,i].Im)/ymx;
      Y[i,j].Re:=yreb;
      Y[i,j].Im:=yimb                    { next for given column i: j=i+1..N  l(i,j) : l(i,j) = (a(i,j) - SUM[l(i,k)*u(k,j)]/u(i,i)}
     END         {e}
    END;         {c}

    ptrX^.ymat:=Y;
    ptrcoff^.cs:=ptrcoff^.cs+cs;      { accumulate all changes of signs }
    ptrcoff^.notapp:=flu;

   END; {LUT}

{***************************************************************************
 TB_MATCOFF - B:=COFFACTOR_OPS(A) - create matrix for coffactor

 Ordered coffactor is transformed into matrix which should be applied
 according to equation
    Y[i,j]=Y[i,j]+ X[TM(i+1),TM(j+1)]
 i.e:
  row i becomes TM(i+1)
  column j becomes TM(j+1)
  0 means row is deleted

 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 @param   ptrcoff:coffpt;
 ***************************************************************************}

 Procedure TB_MATCOFF( ptrB,ptrA:matrixpt;  ptrcoff:coffpt );
 VAR
  i,j:INTEGER;
  ti,tj:INTEGER;
 BEGIN

  for  i:=1 to ptrA^.matrow do begin
   for j:=1 to ptrA^.matcol do begin
      ti:= ptrcoff^.rows.TM[i+1];
      tj:= ptrcoff^.cols.TM[j+1];
      if ( (ti<>0) and (tj<>0) ) then begin
        ptrB^.ymat[ti,tj].Re:= ptrB^.ymat[ti,tj].Re + ptrA^.ymat[i,j].Re;
        ptrB^.ymat[ti,tj].Im:= ptrB^.ymat[ti,tj].Im + ptrA^.ymat[i,j].Im;
      end;
    end;
  end;
  ptrB^.matcol:=ptrA^.matcol-ptrcoff^.len;
  ptrB^.matrow:=ptrA^.matrow-ptrcoff^.len;
  ptrB^.fmat:=ptrA^.fmat;
  ptrB^.next_f_mat_pt:=NIL;
 END;



{***************************************************************************
 MTB_coff -  version of CCC - compute complex coffactor
             result is returned as D.Re+j*D.Im in ptrcoff^.D
             flag notapp set when failed to order indexes.
             ptrA matrix is not changed.
             Calculations are done on X matrix - local variable to perform transformations


 @version - 1.0
 @param   ptrA:matrixpt;
 @param   ptrcoff:coffpt;
 ***************************************************************************}

Procedure MTB_coff(ptrcoff:coffpt; ptrA:matrixpt);


VAR
 k:INTEGER;
 a,b:DOUBLE;
 X:LISTMAT;                            { X is operational matrix }
 ptrX:matrixpt;
 nm:INTEGER;

BEGIN

   if ((ptrA=NIL) or (ptrcoff=NIL)) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   ptrX := @X;                          { get pointer of local variable - this is tradoff X matrix is small }
   MTB_mat_0(ptrX, ptrA^.matrow);      { create 0 matrix with dim of A }
   ptrcoff^.notapp := FALSE;           { assume it may be calculated }
   ptrcoff^.cs :=0;
   ptrcoff^.rows.cs := 0;
   ptrcoff^.cols.cs := 0;
   TB_PCR(@(ptrcoff^.rows));
   TB_PCR(@(ptrcoff^.cols));
   if ( ((ptrcoff^.rows.lc) <> (ptrcoff^.cols.lc)) or ptrcoff^.rows.notapp or ptrcoff^.cols.notapp ) then begin
     ptrcoff^.notapp:=TRUE;                               { can not be calculated }
     ptrcoff^.D.Re := 0.0;
     ptrcoff^.D.Im := 0.0;
   end
   else begin
     ptrcoff^.cs:= ptrcoff^.rows.cs + ptrcoff^.cols.cs;   {cs is a sum }
     ptrcoff^.len:= ptrcoff^.rows.lc;                     {lc is equal }
     nm:= ptrA^.matrow-ptrcoff^.len;
     if ( nm <= 0 ) then begin
      if ( nm = 0 ) then begin
        if (ODD(ptrcoff^.cs)AND(ptrcoff^.cs>0)) then ptrcoff^.D.Re:=-1.0 else ptrcoff^.D.Re:=1.0;
        ptrcoff^.D.Im:=0.0;  { dim 0x0 if ordered is by definition 1.0 or -1.0 ! }
      end
      else begin
       ptrcoff^.D.Re := 0.0; { dim < 0x0 - is 0.0 }
       ptrcoff^.D.Im := 0.0;
      end
     end
     else begin
      TB_CTM(@(ptrcoff^.rows));
      TB_CTM(@(ptrcoff^.cols));
      TB_MATCOFF(ptrX,ptrA, ptrcoff);                    { X is transformed A matrix }
      TB_LUT(ptrX,ptrcoff);                              { LU of X - transformed matrix}
      if ( ptrcoff^.notapp ) then begin
       ptrcoff^.D.Re := 0.0;  { LU does not exist for matrix  determinant is 0.0 }
       ptrcoff^.D.Im := 0.0;
      end
      else begin
       if (ODD(ptrcoff^.cs)AND(ptrcoff^.cs>0)) then ptrcoff^.D.Re := -1.0 else ptrcoff^.D.Re := 1.0;
       ptrcoff^.D.Im:=0.0;
       for k:=1 to nm do begin
        a := ptrcoff^.D.Re; { coffactor is product of diagonal element - initialized as sign }
        b := ptrcoff^.D.Im;
        ptrcoff^.D.Re := a * ptrX^.ymat[k,k].Re - b * ptrX^.ymat[k,k].Im;
        ptrcoff^.D.Im := b * ptrX^.ymat[k,k].Re + a * ptrX^.ymat[k,k].Im
        end
      end
     end
    end
 END;

{***************************************************************************
 TB_coff_0 - zero coffactor

 @version - 1.0
 @param   ptrcoff:matrixpt;
 ***************************************************************************}

Procedure MTB_coff_0 (ptrcoff:coffpt);
VAR
  i:INTEGER;
BEGIN
   if ( ptrcoff=NIL ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;
   for  i:=1 to matmaxdim+1 do begin
      ptrcoff^.rows.x[1,i]:=0;
      ptrcoff^.rows.x[2,i]:=0;
      ptrcoff^.rows.TM[i]:=i;
      ptrcoff^.cols.x[1,i]:=0;
      ptrcoff^.cols.x[2,i]:=0;
      ptrcoff^.cols.TM[i]:=i;
   end;
   ptrcoff^.rows.cs:=0;
   ptrcoff^.rows.lc:=0;
   ptrcoff^.rows.notapp:=FALSE;
   ptrcoff^.cols.cs:=0;
   ptrcoff^.cols.lc:=0;
   ptrcoff^.cols.notapp:=FALSE;
   ptrcoff^.cs:=0;
   ptrcoff^.len:=0;
   ptrcoff^.notapp:=FALSE;
   ptrcoff^.D.Re:=0.0;
   ptrcoff^.D.Im:=0.0;
END;

{***************************************************************************
 TB_coff_0 - zero coffactor

 @version - 1.0
 @param   ptrcoff:matrixpt;
 ***************************************************************************}
Procedure MTB_coff_add (ptrcoff:coffpt; w,r,k,l:INTEGER);
BEGIN

   if ( ptrcoff=NIL ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   ptrcoff^.rows.lc:=ptrcoff^.rows.lc+1;
   ptrcoff^.rows.x[1,ptrcoff^.rows.lc]:=w;
   ptrcoff^.rows.x[2,ptrcoff^.rows.lc]:=r;

   ptrcoff^.cols.lc:=ptrcoff^.cols.lc+1;
   ptrcoff^.cols.x[1,ptrcoff^.cols.lc]:=k;
   ptrcoff^.cols.x[2,ptrcoff^.cols.lc]:=l;

   ptrcoff^.len:=ptrcoff^.len+1;

END;


{***************************************************************************
 MTB_inverse - compute complex inverse matrix
             by computing transposed matrix of coffactors
             result is returned in B
             flag notapp set when failed - i.e. determinat of A is 0
             ptrA matrix is not changed.


 @version - 1.0
 @param   ptrA:matrixpt;
 @param   ptrcoff:coffpt;
 ***************************************************************************}

Procedure MTB_inverse(ptrB,ptrA:matrixpt);

VAR
 i,j:INTEGER;
 DAre,DAim:DOUBLE;
 cf:COFF;
 ptrcoff:coffpt;
 det:COMPLEX;
 mdet:DOUBLE;
BEGIN

  if ( (ptrA=NIL) or (ptrB=NIL)) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
  end;

  if ( (ptrA^.matcol<>ptrB^.matcol) or  (ptrA^.matrow<>ptrB^.matrow) ) then begin
     MATRIX_TOOLBOX_DIM_ERROR;
  end;

  ptrcoff:=@cf;
  MTB_coff_0 (ptrcoff);
  MTB_coff(ptrcoff,ptrA);
  det:=ptrcoff^.D;
  mdet:=det.Re*det.Re + det.Im*det.Im;
  if ( ptrcoff^.notapp or ((det.Re=0.0) and (det.Im=0.0)) ) then begin
     MATRIX_TOOLBOX_CANNOT_INVERT_ERROR;
  end;

  for i:= 1  to ptrA^.matrow do begin
    for j:= 1 to ptrA^.matcol  do begin
       MTB_coff_0 (ptrcoff);  { create D(i+0)(j+0) }
       ptrcoff^.rows.x[1,1]:=i;
       ptrcoff^.rows.lc:=1;
       ptrcoff^.cols.x[1,1]:=j;
       ptrcoff^.cols.lc:=1;
       MTB_coff(ptrcoff,ptrA);
       DARe:=ptrcoff^.D.Re;
       DAIm:=ptrcoff^.D.Im; { B[i,j]:= DA(i+0)(j+0)/det }
      {----------------------------------------------------------------------------------------------}
      { (x1+jy1)/(x2+jy2)=(x1+jy1)*(x2-jy2)/(x2^+y2)=(x1*x2+y1*y2)/(x2^+y2)+j*(y1*x2-y2*x1)/(x^2+y^2)}
      {----------------------------------------------------------------------------------------------}
       ptrB^.ymat[i,j].Re:= (DARe*det.Re + DAIm*det.Im)/mdet;
       ptrB^.ymat[i,j].Im:= (DAIm*det.Re - DARe*det.Im)/mdet;
    end;
  end;
  MTB_transp (ptrB,ptrB); { transponded - should work }

END;

{***************************************************************************
 MTB_MA2RI - B:= |A|*exp(j*arg(A))

 Convert MA format into RI
 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_MA2RI (ptrB,ptrA:matrixpt);
VAR
  i,j:INTEGER;
  m,ph:DOUBLE;
BEGIN

   if ( (ptrA=NIL) or (ptrB=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   for  i:=1 to ptrA^.matrow do begin
    for j:=1 to ptrA^.matcol do begin
      m:=ptrA^.ymat[i,j].Re;
      ph:=ptrA^.ymat[i,j].Im;
      ptrB^.ymat[i,j].Re:=m*cos(PI*ph/180.0);
      ptrB^.ymat[i,j].Im:=m*sin(PI*ph/180.0);
    end;
  end;

  ptrB^.matcol:=ptrA^.matcol;
  ptrB^.matrow:=ptrA^.matrow;
  ptrB^.fmat:=ptrA^.fmat;
  ptrB^.next_f_mat_pt:=NIL;

END;

{***************************************************************************
 MTB_MA2RI - B:= (20*log|A|)*exp(j*arg(A))

 Convert DB format into RI
 @version - 1.0
 @param   ptrB,ptrA:matrixpt;
 ***************************************************************************}

Procedure MTB_DB2RI (ptrB,ptrA:matrixpt);
VAR
  i,j:INTEGER;
  m,mdB,ph:DOUBLE;
BEGIN

   if ( (ptrA=NIL) or (ptrB=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   for  i:=1 to ptrA^.matrow do begin
    for j:=1 to ptrA^.matcol do begin
      mdB:=ptrA^.ymat[i,j].Re;
      ph:=ptrA^.ymat[i,j].Im;
      {m=10^(mdB/20)}
      { CAN NOT FIND POWER ???? - not implemented in Delphi3}
      { x**y => exp(y*ln(x));}
      m:=Power(10.0,mdB/20);


      ptrB^.ymat[i,j].Re:=m*cos(PI*ph/180.0);
      ptrB^.ymat[i,j].Im:=m*sin(PI*ph/180.0);
    end;
  end;

  ptrB^.matcol:=ptrA^.matcol;
  ptrB^.matrow:=ptrA^.matrow;
  ptrB^.fmat:=ptrA^.fmat;
  ptrB^.next_f_mat_pt:=NIL;

END;

{***************************************************************************
 MTB_S2Y - Y:= (1/R0*I)*(I-S)*(1+S)^-1

 Convert S into Y
 @version - 1.0
 @param   ptrY,ptrS:matrixpt;
 @param   R0:double;

 ***************************************************************************}

Procedure MTB_S2Y (ptrY,ptrS:matrixpt; R0:double);
VAR
  dim:INTEGER;
  I,M1,M2,M3:LISTMAT;                            { I,M are operational matrix }
  ptrI,ptrM1,ptrM2,ptrM3:matrixpt;
BEGIN

   if ( (ptrY=NIL) or (ptrS=NIL) ) then begin
    MATRIX_TOOLBOX_NIL_ERROR;
   end;

   if ( R0 = 0.0 ) then begin
    MATRIX_TOOLBOX_CONVERSION_ERROR;
   end;

   if ( ptrS^.matrow <> ptrS^.matcol ) then begin
    MATRIX_TOOLBOX_CONVERSION_ERROR;
   end;

   if ( ptrS^.matrow < 1 ) then begin
    MATRIX_TOOLBOX_CONVERSION_ERROR;
   end;

  dim :=ptrS^.matrow;
  ptrI :=  @I;                          { get pointer of local variable - this is tradoff - matrix dim is small }
  ptrM1 := @M1;
  ptrM2 := @M2;
  ptrM3 := @M3;

  MTB_mat_1 (ptrI,dim);
  MTB_mat_0 (ptrM1,dim);
  MTB_mat_0 (ptrM2,dim);
  MTB_mat_0 (ptrM3,dim);
  // M1=(I+S)
  MTB_add(ptrM1,ptrI,ptrS);
  // M3=(I+S)^-1
  MTB_inverse(ptrM3,ptrM1);
  // M2=(I-S)
  MTB_sub(ptrM2,ptrI,ptrS);
  // M1=(I-S)*(I+S)^-1
  MTB_mult(ptrM1,ptrM2,ptrM3);
  // M2=(1/R0)*I
  MTB_multc(ptrM2, ptrI, 1.0/R0, 0.0);
  // Y= (1/R0)*I*(I-S)*(I+S)^-1
  MTB_mult(ptrY,ptrM2,ptrM1);
  //  but, why not just Y = 1/R0*(I-S)*(I+S)^-1
  // MTB_multc(ptrY, ptrM1, 1/R0, 0.0);
  ptrY^.fmat:=ptrS^.fmat;
END;



end.

