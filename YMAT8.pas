{***************************************************************************
 YMAT8 - PROCESS_B_COMP, PROCESS_MAT_FILES, INTERPOLATE_CREATE_INSERT_MAT_VAR_LISTS

 @version - 8.A
 ***************************************************************************}

{$DEFINE notDebug}

UNIT YMAT8;

interface
USES
 SysUtils,
 TYPE8,VAR8,LINE8,DATAIO8,VAREXT8,ELEMENT8,TASK8,TOOLBOX8;

PROCEDURE PROCESS_B_COMP;

PROCEDURE PROCESS_MAT_FILES;

PROCEDURE INTERPOLATE_MAT(t_ptr:taskpt);
PROCEDURE CREATE_MAT_VAR_LISTS(t_ptr:taskpt);
PROCEDURE INSERT_MAT_VAR_LISTS(t_ptr:taskpt);



{***************************************************************************}
{***************************************************************************}
{***************************************************************************}
implementation
USES Amp8_main;

{***************************************************************************}
{***************************************************************************}

 PROCEDURE READ_ONE_REAL;
 VAR
 c:char;
 BEGIN
   cpt1:=FND('!','~',cpt2);
   c:=line[cpt1];
   IF (ORD(c)>=ORD('+'))AND(ORD(c)<=ORD('9')) THEN
   RRL
   ELSE
    xx:=TRUE
 END;

{***************************************************************************
 Read lines and skip comments !

 @version - 1.0
 @param l_ptr:listapt - pointer to next line - might be comment !
 ***************************************************************************}

 PROCEDURE FIND_CMAT_NEXT_ROW(VAR l_ptr:listapt);
 BEGIN

  line:=l_ptr^.oneline;
  cpt1:=1;
  cpt1:=FND('!','z',1);
  cpt2:=cpt1;
  while ( ( not MIGHT_BE_DIGIT( line[cpt1]) ) ) do begin
      l_ptr:=l_ptr^.lpt;
      line:=l_ptr^.oneline;
      if ( l_ptr=NIL ) then begin
        MAT_SIZE_ERROR;   /// a line is expected - if there is none, then error
      end;
      cpt1:=FND('!','z',1);
  end;

 END;


{***************************************************************************
 Read values of complex pairs in complex list

 @version - 1.0
 @param l_ptr:listapt - pointer to next line - might be comment !
 @param rowlenght:INTEGER - count of values read including freq
 @param head:listcpt - used to link complex elements i.e. Yre Yim
 @param tail:listcpt - used to link complex elements i.e. Yre Yim
 ***************************************************************************}


 PROCEDURE READ_CMAT_NEXT_ROW(VAR l_ptr:listapt; VAR rowlenght:INTEGER; VAR HEAD,TAIL:listcpt);
 VAR
  rvalue:DOUBLE;
  ivalue:DOUBLE;
 BEGIN

  l_ptr:=l_ptr^.lpt;
  FIND_CMAT_NEXT_ROW(l_ptr);
  {cpt1:=1;
  cpt2:=cpt1;}
  xx:=FALSE;
  READ_ONE_REAL;
  if ( NOT xx ) then begin
   repeat
      rvalue:=rr;
      READ_ONE_REAL;
      ivalue:=rr;
      ADD2CPLX_LIST(HEAD,TAIL,rvalue,ivalue);
      rowlenght:=rowlenght+2;
      READ_ONE_REAL;
    until ( xx );
  end
  else
      DATA_ERROR;

 END;



{***************************************************************************
 Read values to freq into f variable and complex pairs in complex list

 @version - 1.0
 @param rowlenght:INTEGER - count of values read including freq
 @param f:double - frequency
 @param head:listcpt - used to link complex elements i.e. Yre Yim
 @param tail:listcpt - used to link complex elements i.e. Yre Yim
 ***************************************************************************}


 PROCEDURE READ_CMAT_ROW(VAR rowlenght:INTEGER; VAR f:DOUBLE; VAR HEAD,TAIL:listcpt);
 VAR
  rvalue:DOUBLE;
  ivalue:DOUBLE;
 BEGIN
  xx:=FALSE;
  rowlenght:=0;
  cpt2:=cpt1;
  READ_ONE_REAL;
  if ( NOT xx ) then begin
    f:=rr;
    rowlenght:=1;
    READ_ONE_REAL;
    if NOT xx then begin
    repeat
      rvalue:=rr;
      READ_ONE_REAL;
      ivalue:=rr;
      ADD2CPLX_LIST(HEAD,TAIL,rvalue,ivalue);
      rowlenght:=rowlenght+2;
      READ_ONE_REAL;
    until ( xx );
    end
    else
      DATA_ERROR;
  end
    else
      DATA_ERROR;

 END;

{***************************************************************************
 Read values of # - options line
 # [GHZ/MHZ/KHZ/HZ] [S/Y/Z/G/H] [MA/DB/RI] [R n]
 parameters may appear in any order

 @version - 1.0
 @param m_ptr:matptr - pointer to current MATRIX
 ***************************************************************************}


 PROCEDURE READ_OPTIONS_LINE(m_ptr:matptr);
 VAR
  CheckLine:string;
 BEGIN
  CheckLine := UpperCase(line);

  if ( Pos('GHZ',CheckLine)<>0 ) then m_ptr^.mattsfreq:=GHz
  else if ( Pos('MHZ',CheckLine)<>0 ) then m_ptr^.mattsfreq:=MHz
  else if ( Pos('KHZ',CheckLine)<>0 ) then m_ptr^.mattsfreq:=KHz
  else if ( Pos('HZ',CheckLine)<>0 ) then  m_ptr^.mattsfreq:=Hz
  else m_ptr^.mattsfreq:=Ghz; /// default is GHz

  if ( Pos('S',CheckLine)<>0 ) then m_ptr^.mattsparam:=S
  else if ( Pos('Y',CheckLine)<>0 ) then TOUCHSTONE_FORMAT_ERROR
  else if ( Pos('Z',CheckLine)<>0 ) then TOUCHSTONE_FORMAT_ERROR
  else if ( Pos('H',CheckLine)<>0 ) then TOUCHSTONE_FORMAT_ERROR
  else if ( Pos('G',CheckLine)<>0 ) then TOUCHSTONE_FORMAT_ERROR
  else m_ptr^.mattsparam:=S; /// default is S

  if ( Pos('MA',CheckLine)<>0 ) then m_ptr^.mattsformat:=MA
  else if ( Pos('DB',CheckLine)<>0 ) then m_ptr^.mattsformat:=DB
  else if ( Pos('RI',CheckLine)<>0 ) then m_ptr^.mattsformat:=RI
  else m_ptr^.mattsformat:=MA; /// default is MA

  cpt1:=Pos('R ',CheckLine);  /// not 'RI' only 'R '
  cpt2:=cpt1+1;
  xx:=FALSE;
  RRL;
  if ( xx ) then TOUCHSTONE_FORMAT_ERROR
  else m_ptr^.mattsRref:=rr;


 END;



{***************************************************************************
 Add values to listb using head and tail pointer

 @version - 1.0
 @param val:DOUBLE - added to the tail of list
 @param head:listbpt - when nil initializes list
 @param tail:listbpt - used to link elements
 ***************************************************************************}

PROCEDURE ADD_TO_LISTB(val:DOUBLE; VAR head_ptr,tail_ptr:listbpt);
BEGIN
 if (head_ptr=NIL) then begin
    NEW(head_ptr);
    tail_ptr:=head_ptr
 end
 else begin
    NEW(tail_ptr^.vpt);
    tail_ptr:=tail_ptr^.vpt
 end;
 tail_ptr^.value:=val;
 tail_ptr^.vpt:=NIL
END;

{***************************************************************************
 Search from head to find if a value is already in the list.
 @version - 1.0
 @param val:DOUBLE -
 @param head_ptr:listbpt - when nil initializes list
 @return val_ptr:listbpt - pointer to found value
 @return TRUE - value not found
 ***************************************************************************}


FUNCTION VALUE_NOT_IN_THE_LIST(val:DOUBLE; head_ptr:listbpt; VAR val_ptr:listbpt ):BOOLEAN;
VAR
  v_ptr:listbpt;
  TEST:BOOLEAN;
BEGIN
    v_ptr:=head_ptr;
    val_ptr:=NIL;
    TEST:=TRUE;
    while ( v_ptr <> NIL ) do begin
       if ( v_ptr^.value = val ) then begin
          TEST:=FALSE;
          val_ptr:=v_ptr;
          break;
       end;
       v_ptr:=v_ptr^.vpt;
    end;
    VALUE_NOT_IN_THE_LIST:=TEST;
END;


{***************************************************************************
 Search from head and return val_ptr - a pointer to GREATEST(val_ptr.value) < value.
 If exist next is val_ptr^.vpt is the value SMALLEST_LARGER.
 Calling function might insert new element into the list using val_ptr
  if val_ptr=nil -  value of head is > value
  if val_ptr=head - head_ptr^.val<val, next is higher
 @version - 1.0
 @param val:DOUBLE -   val_ptr^.value< val
 @param head:listbpt - when nil initializes list
 @return val_ptr:listbpt - used to link elements
 ***************************************************************************}

PROCEDURE GET_PTR_TO_GREATEST_SMALLER(val:DOUBLE; head_ptr:listbpt; VAR val_ptr:listbpt );
VAR
  v_ptr:listbpt;
BEGIN
    val_ptr:=NIL;
    v_ptr:=head_ptr;
    while ( v_ptr <> NIL ) do begin
       if ( v_ptr^.value > val ) then break;  /// stop if current is > value - previouse is the one sought
       val_ptr:=v_ptr;                        ///  keep this as a reference - last kept is the one sought
       v_ptr:=v_ptr^.vpt;
    end;

END;



{***************************************************************************
 Insert values to listb using head and tail pointer

 @version - 1.0
 @param val:DOUBLE - inserted into the list
 @param head:listbpt - VAR when nil initializes list
 ***************************************************************************}

PROCEDURE INSERT_INTO_LISTB(value:DOUBLE; VAR head_ptr:listbpt );
VAR
  val_ptr:listbpt;
  temp_ptr:listbpt;
BEGIN
    if ( head_ptr=NIL ) then begin
      ADD_TO_LISTB(value, head_ptr,val_ptr); /// create a list
    end
    else begin
         if ( VALUE_NOT_IN_THE_LIST(value,head_ptr,temp_ptr))  then begin   /// skip all existing values
            GET_PTR_TO_GREATEST_SMALLER(value, head_ptr, val_ptr );
            if ( val_ptr<>NIL ) then begin
              temp_ptr:=val_ptr^.vpt;  /// break link, create, insert, restore link
              val_ptr^.vpt:=NIL;
              NEW(val_ptr^.vpt);
              val_ptr^.vpt^.vpt := temp_ptr;
              val_ptr^.vpt^.value:=value;
            end
            else begin
              temp_ptr:=head_ptr;  /// nil means that value must be inserted from the head;
              head_ptr:=NIL;
              NEW(head_ptr);
              head_ptr^.vpt := temp_ptr;
              head_ptr^.value:=value;
            end;
         end;
    end;

END;

{***************************************************************************
 Add values from matrix freq to listb MAT_COMM_FREQ_LISTS
 @version - 1.0
 ***************************************************************************}

 PROCEDURE CREATE_MAT_COMM_FREQ_LISTS;
 VAR
  mat_ptr:matptr;
  mat_data_ptr:matrixpt;
  BEGIN
    mat_ptr:=MAT_PT;
    while ( mat_ptr <> NIL ) do begin
      mat_data_ptr:=mat_ptr^.MAT_FILE_DATA_PT;
      while ( mat_data_ptr <> NIL ) do begin
        /// this means put new value into chain - list is supposed to ascending
        INSERT_INTO_LISTB( mat_data_ptr^.fmat, MAT_COMM_FREQ_PT );
        mat_data_ptr:=mat_data_ptr^.next_f_mat_pt;
      end;
      mat_ptr:=mat_ptr^.matnext;
    end;

 END;

{***************************************************************************
 Add values to MAT list using head and tail pointer

 @version - 1.0

 @result head:matrixpt - when nil initializes list
 @result tail:matrixpt - used to link elements
 ***************************************************************************}

PROCEDURE ADD_TO_MATLIST(VAR head_ptr,tail_ptr:matptr);
BEGIN
 if (head_ptr=NIL) then begin
    NEW(head_ptr);
    tail_ptr:=head_ptr
 end
 else begin
    NEW(tail_ptr^.matnext);
    tail_ptr:=tail_ptr^.matnext
 end;
 tail_ptr^.matnext:=NIL;
END;


{***************************************************************************
 From $MAT lines CREATE_MAT_DEF - get MatrixType Matrixname MatrixFileName
***************************************************************************}

 PROCEDURE CREATE_MAT_DEF;
 VAR
  t_ptr:taskpt;
  l_ptr:listapt;
  MAT_TAIL_PT:matptr;
 BEGIN
    t_ptr:=TASK_PT;
    while ( t_ptr<>NIL ) do begin
      l_ptr:=t_ptr^.CDEF_PT;
      while ( l_ptr<>NIL ) do begin
        line:=l_ptr^.oneline;
        if ( Pos('$MAT',UpperCase(line))<>0 ) then begin
            ADD_TO_MATLIST( MAT_PT, MAT_TAIL_PT);
            with (MAT_TAIL_PT^) do begin
            MAT_TAIL_PT^.line_pt:=l_ptr;
            xx:=FALSE;
            cpt1:= FND('$','$',1);
            cpt2:= FND(' ',' ',cpt1); {skip $MAT}
            cpt1:= FND('A','z',cpt2);
            cpt2:= FND(' ',' ',cpt1); {get MatrixType }
            TXT(cpt1,cpt2-1); mattypestr:=nsymb;
            cpt1:= FND('A','z',cpt2);
            cpt2:= FND(' ',' ',cpt1); {get Matrixname }
            TXT(cpt1,cpt2-1); matname:=nsymb;
            cpt1:=FND('!','z',cpt2);
            cpt2:= FND(' ',' ',cpt1); {get MatrixFileName }
            matfilestr:=COPY(line,cpt1,(cpt2-cpt1));
            MAT_TAIL_PT^.matnext:=NIL;
           end;
        end;
        l_ptr:=l_ptr^.lpt;
    end;
    t_ptr:=t_ptr^.tpt;
  end;
 END;

{***************************************************************************}
 PROCEDURE CMAT_ROW_TO_MATDATA(VAR mdata_head_pt, mdata_tail_pt:matrixpt; r_len:INTEGER; f_r:DOUBLE; cplx_head_pt:listcpt);
 VAR
  i,j:INTEGER;
  cplx_pt:listcpt;
 BEGIN
  if (mdata_head_pt=NIL) then begin
    NEW(mdata_head_pt);
    mdata_tail_pt:=mdata_head_pt;
  end
  else begin
    NEW(mdata_tail_pt^.next_f_mat_pt);
    mdata_tail_pt:=mdata_tail_pt^.next_f_mat_pt;
  end;
  mdata_tail_pt^.next_f_mat_pt:=NIL;
  if ( ((r_len-1)/2) < 1) then begin
     MAT_SIZE_ERROR; { it is not a square matrix }
  end
  else begin
    if ( abs(Sqrt((r_len-1)/2)-Round(Sqrt((r_len-1)/2)))>0.001 ) then begin
       MAT_SIZE_ERROR; { it is not a square matrix }
    end
    else begin
      with mdata_tail_pt^ do begin
        fmat:=f_r;
        matcol:=Round(Sqrt((r_len-1)/2));
        matrow:=matcol;
        if ( matrow > matmaxdim ) then begin
          MAT_SIZE_ERROR; { matrix is too big }
        end
        else begin
          cplx_pt:=cplx_head_pt;
          i:=1; j:=1;
          while ( cplx_pt<>NIL ) do begin
            ymat[i,j].Re:=cplx_pt^.valre;
            ymat[i,j].Im:=cplx_pt^.valim;
            j:=j+1;
            if ( j>matcol ) then begin
              i:=i+1; j:=1;
            end;
            cplx_pt:=cplx_pt^.cvpt;
          end;
        end;
      end;
    end
  end
 END;

{***************************************************************************
 Extract SnP data from file m_ptr^matfilestr

 @version - 1.0
 @param m_ptr:matptr - pointer to MATRECTYPE
 ***************************************************************************}

 PROCEDURE EXTRACT_MAT_SNP_DATA(m_ptr:matptr);
 VAR
  l_ptr:listapt;
  CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT:listcpt;
  f_row:DOUBLE;
  row_length:INTEGER;
  MAT_FILE_DATA_TAIL_PT:matrixpt;
  OPTIONS_FOUND:BOOLEAN;
  STstr:String;

 BEGIN
   with (m_ptr^) do begin

    STstr:=UpperCase(mattypestr);
    if ( STstr = 'S1P' ) then mattype:=S1P
    else if ( STstr = 'S2P' ) then mattype:=S2P
    else if ( STstr = 'S3P' ) then mattype:=S3P
    else if ( STstr = 'S4P' ) then mattype:=S4P
    else if ( STstr = 'S5P' ) then mattype:=S5P
    else if ( STstr = 'S6P' ) then mattype:=S6P
    else if ( STstr = 'S7P' ) then mattype:=S7P
    else if ( STstr = 'S8P' ) then mattype:=S8P
    else if ( STstr = 'S9P' ) then mattype:=S9P
    else UNKNOWN_MAT_ERROR;


    OPTIONS_FOUND:=FALSE;
    MAT_FILE_DATA_PT:=NIL; { pointer to list of matrixes }
    mat_fq_dim:=0;
    l_ptr:=FILELINES_HEAD_PT;
    while ( l_ptr<>NIL ) do begin
     line:=l_ptr^.oneline;
     cpt1:=FND('!','z',1);
     if ( OPTIONS_FOUND ) then begin
      if ( MIGHT_BE_DIGIT( line[cpt1]) ) then begin
        CMPLX_ROW_PT:=NIL;{ new list for new row }
        mat_fq_dim:=mat_fq_dim+1;
        case ( mattype) of
          S1P: READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); // f S11
          S2P: READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); // f S11 S21 S12 S22
          S3P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);       // f S11 S12 S13
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);  //   S21 S22 S23
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);  //   S31 S32 S33
          end;
          S4P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
          end;
          S5P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S15
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S25
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S35
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S45
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S51 S52 S53 S54
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S55
          end;
          S6P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S15 S16
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S25 S26
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S35 S36
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S45 S46
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S51 S52 S53 S54
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S55 S56
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S61 S62 S63 S64
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S65 S66
          end;

          S7P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S15 S16 S17
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S25 S26 S27
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S35 S36 S37
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S45 S46 S47
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S51 S52 S53 S54
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S55 S56 S57
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S61 S62 S63 S64
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S65 S66 S67
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S71 S72 S73 S74
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S75 S76 S77
          end;

          S8P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S15 S16 S17 S18
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S25 S26 S27 S28
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S35 S36 S37 S38
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S45 S46 S47 S48
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S51 S52 S53 S54
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S55 S56 S57 S58
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S61 S62 S63 S64
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S65 S66 S67 S68
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S71 S72 S73 S74
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S75 S76 S77 S78
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S81 S82 S83 S84
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S85 S86 S87 S88
          end;

          S9P: begin
                READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);      // f S11 S12 S13 S14
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S15 S16 S17 S18
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S19
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S21 S22 S23 S24
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S25 S26 S27 S28
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S29
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S31 S32 S33 S34
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S35 S36 S37 S38
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S39
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S41 S42 S43 S44
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S45 S46 S47 S48
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S49
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S51 S52 S53 S54
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S55 S56 S57 S58
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S59
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S61 S62 S63 S64
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S65 S66 S67 S68
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S69
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S71 S72 S73 S74
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S75 S76 S77 S78
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S79
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S81 S82 S83 S84
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S85 S86 S87 S88
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S89
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S91 S92 S93 S94
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S95 S96 S97 S98
                READ_CMAT_NEXT_ROW(l_ptr,row_length,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT); //   S99
          end;

        end;
        CMAT_ROW_TO_MATDATA(MAT_FILE_DATA_PT, MAT_FILE_DATA_TAIL_PT, row_length, f_row, CMPLX_ROW_PT);
      end
     end
     else begin
       if (line[cpt1]='#') then begin
           READ_OPTIONS_LINE( m_ptr );
           OPTIONS_FOUND:=TRUE;
       end
     end;
     l_ptr:=l_ptr^.lpt;
    end;
    if ( not OPTIONS_FOUND ) then begin
      NO_S_OPTION_ERROR;
    end;
   end;
 END;



{***************************************************************************
 Extract YRI data from file m_ptr^matfilestr

 @version - 1.0
 @param m_ptr:matptr - pointer to MATRECTYPE
 ***************************************************************************}

 PROCEDURE EXTRACT_MAT_YRI_DATA(m_ptr:matptr);
 VAR
  l_ptr:listapt;
  CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT:listcpt;
  f_row:DOUBLE;
  row_length:INTEGER;
  MAT_FILE_DATA_TAIL_PT:matrixpt;

  BEGIN
   with (m_ptr^) do begin
    mattype:=YRI;

    MAT_FILE_DATA_PT:=NIL; { pointer to list of matrixes }

    mat_fq_dim:=0;
    l_ptr:=FILELINES_HEAD_PT;
    while ( l_ptr<>NIL ) do begin
     line:=l_ptr^.oneline;
     cpt1:=FND('!','z',1);
     if ( MIGHT_BE_DIGIT(line[cpt1]) ) then begin
      CMPLX_ROW_PT:=NIL;{ new list for new row }
      mat_fq_dim:=mat_fq_dim+1;
      READ_CMAT_ROW(row_length,f_row,CMPLX_ROW_PT,CMPLX_ROW_TAIL_PT);
      if ( MAT_FILE_DATA_PT=NIL ) then begin
        mat_dim:=Round(Sqrt((row_length-1)/2));
      end
      else begin
        if ( Round(Sqrt((row_length-1)/2)) <>  mat_dim ) then begin
          MAT_SIZE_ERROR; { it is not a square matrix }
        end
      end;
      CMAT_ROW_TO_MATDATA(MAT_FILE_DATA_PT, MAT_FILE_DATA_TAIL_PT, row_length, f_row, CMPLX_ROW_PT);
     end;
     l_ptr:=l_ptr^.lpt;
    end;

  end;

 END;


{***************************************************************************
 Parse MAT_PT list and using mattype switch to appropriate routine to read
 YRI - native format
 SNP - Touchstone S FORMAT
 @version - 1.0

 ***************************************************************************}

 PROCEDURE EXTRACT_MAT_DATA;
 VAR
  m_ptr:matptr;

  BEGIN
    m_ptr:=MAT_PT;
    while ( m_ptr<>NIL ) do begin
       with (m_ptr^) do begin
        FILELINESSTR:=matfilestr;
        FILELINES_OPEN;
        FILELINES_READ;  { copy file to FILELINES_HEAD_PT list }
        FILELINES_CLOSE;
        MAT_FILE_DATA_PT:=nil;        /// file data
        MAT_S_PT:=nil;                /// normalized S - RI format
        MAT_Y_PT:=nil;                /// converter into Y
        MAT_INTERP_Y_PT:=nil;         /// interpolated data
        if (UpperCase(mattypestr)='YRI') then EXTRACT_MAT_YRI_DATA(m_ptr)
        else begin
         if (UpperCase(mattypestr[1])='S') then EXTRACT_MAT_SNP_DATA(m_ptr)
         else begin
            UNKNOWN_MAT_ERROR;
         end
        end
       end;
       m_ptr:=m_ptr^.matnext;
    end;

 END;

{***************************************************************************}
 PROCEDURE CREATE_B_COMPONENTS;

  VAR
  b_ptr:bptr;
  s_a,s_b,s_c,s_d:string;
  s_i,s_j:string;
  s_ins:string;
  MAT_COMP_TAIL_PT:listapt;
  i,j:INTEGER;
 BEGIN

  MAT_COMP_PT:=NIL;
  b_ptr:=b_Head;
  while b_ptr<>NIL do begin
    with b_ptr^ do begin
      for i:=1 to bndim-1  do begin
        for  j:=1 to bndim-1 do begin
          STR(i,s_i);
          STR(j,s_j);
          STR(bnodes[i],s_a);
          STR(bnodes[bndim],s_b);
          STR(bnodes[j],s_c);
          STR(bnodes[bndim],s_d);
          s_ins:=CONCAT(g_MAT_str+s_i+s_j+'.'+bname+'    '+s_a+' '+s_b+' '+s_c+' '+s_d+'    '
                        +'VAR '+g_MAT_str+s_i+s_j+'.'+bref );
          CLEAR_LINE;
          INSERT(s_ins,line,1);
          ADD_TO_LISTA(MAT_COMP_PT, MAT_COMP_TAIL_PT);
        end;
      end;
    end;
    b_ptr:=b_ptr^.bnext;
  end;

 END;

{***************************************************************************}
 PROCEDURE ADD_B_COMPONENTS;
 VAR
 lpointer:listapt;

 BEGIN
  lpointer:=MAT_COMP_PT;
  WHILE lpointer<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=lpointer^.oneline;
   cpt1:=FND('A','z',1);
   DSV(lpointer);
   lpointer:=lpointer^.lpt
  END
 END;





{***************************************************************************
 Convert  GHZ into internal format - Hz

 @version - 1.0
 @param ptrM:matrixpt
 ***************************************************************************}
 PROCEDURE CONVERT_GHZ_TO_HZ(ptrM:matrixpt);
 BEGIN
    while ( ptrM<>NIL ) do begin
        ptrM^.fmat:=ptrM^.fmat*1.0E+9;
        ptrM:=ptrM^.next_f_mat_pt;
    end;
 END;

{***************************************************************************
 Convert  MHZ into internal format - Hz

 @version - 1.0
 @param ptrM:matrixpt
 ***************************************************************************}
 PROCEDURE CONVERT_MHZ_TO_HZ(ptrM:matrixpt);
 BEGIN
    while ( ptrM<>NIL ) do begin
        ptrM^.fmat:=ptrM^.fmat*1.0E+6;
        ptrM:=ptrM^.next_f_mat_pt;
    end;
 END;

{***************************************************************************
 Convert  KHZ into internal format - Hz

 @version - 1.0
 @param ptrM:matrixpt
 ***************************************************************************}
 PROCEDURE CONVERT_KHZ_TO_HZ(ptrM:matrixpt);
 BEGIN
    while ( ptrM<>NIL ) do begin
        ptrM^.fmat:=ptrM^.fmat*1.0E+3;
        ptrM:=ptrM^.next_f_mat_pt;
    end;
 END;

{***************************************************************************
 CREATE_NEW_MATRIX in a list

 @version - 1.0
 @param head_ptr,tail_ptr:matrixpt
 ***************************************************************************}

PROCEDURE CREATE_NEW_MATRIX_IN_LIST(VAR head_ptr,tail_ptr:matrixpt );
BEGIN
 if (head_ptr=NIL) then begin
    NEW(head_ptr);
    tail_ptr:=head_ptr
 end
 else begin
    NEW(tail_ptr^.next_f_mat_pt);
    tail_ptr:=tail_ptr^.next_f_mat_pt;
 end;

END;


{***************************************************************************
 Convert  DB into internal format - RI

 @version - 1.0
 @param VAR ptrS_head:matrixpt
 @param ptrX:matrixpt
 ***************************************************************************}
 PROCEDURE CONVERT_S_DB_TO_S_RI(VAR ptrS_head:matrixpt; ptrX:matrixpt);
 VAR
  ptrS:matrixpt;
 BEGIN

    while ( ptrX <> NIL ) do begin
        CREATE_NEW_MATRIX_IN_LIST(ptrS_head,ptrS);
        MTB_DB2RI(ptrS,ptrX);
        ptrX:=ptrX^.next_f_mat_pt;
    end;
 END;


{***************************************************************************
 Convert  MA into internal format - RI

 @version - 1.0
 @param VAR ptrS_head:matrixpt
 @param ptrX:matrixpt
 ***************************************************************************}
 PROCEDURE CONVERT_S_MA_TO_S_RI(VAR ptrS_head:matrixpt; ptrX:matrixpt);
 VAR
  ptrS:matrixpt;
 BEGIN

    while ( ptrX <> NIL ) do begin
        CREATE_NEW_MATRIX_IN_LIST(ptrS_head,ptrS);
        MTB_MA2RI(ptrS,ptrX);
        ptrX:=ptrX^.next_f_mat_pt;
    end;
 END;

{***************************************************************************
 Traspose S2P - to change order [s11 s21 s12 s22]
 @version - 1.0

 @param ptrS:matrixpt
 ***************************************************************************}
 PROCEDURE TRANSPOSE_S_MAT(ptrS:matrixpt);
 BEGIN
    while ( ptrS <> NIL ) do begin
        MTB_transp(ptrS,ptrS);
        ptrS:=ptrS^.next_f_mat_pt;
    end;
 END;


{***************************************************************************
 Convert S into Y

 @version - 1.0
 @param VAR ptrY_head:matrixpt
 @param ptrS:matrixpt
 @param R0:double
 ***************************************************************************}
 PROCEDURE CONVERT_S_TO_Y( VAR ptrY_head:matrixpt; ptrS:matrixpt; R0:double);
 VAR
  ptrY:matrixpt;
 BEGIN
    while ( ptrS <> NIL ) do begin
        CREATE_NEW_MATRIX_IN_LIST(ptrY_head,ptrY);
        MTB_S2Y(ptrY,ptrS,R0);
        ptrS:=ptrS^.next_f_mat_pt;
    end;
 END;


{***************************************************************************
  Convert  SnP MAT_FILE_DATA into MAT_Y_PT (YRI) internal format
  MAT_Y_PT is later used for interpolation

 @version - 1.0
 @param m_ptr:matptr - pointer to MATRECTYPE

 ***************************************************************************}
 PROCEDURE CONVERT_S_TOUCHSTONE_DATA(m_ptr:matptr);

 BEGIN
   with (m_ptr^) do begin

    if ( mattsfreq = GHz ) then begin
      CONVERT_GHZ_TO_HZ( MAT_FILE_DATA_PT );
    end
    else if ( mattsfreq = MHz ) then begin
      CONVERT_MHZ_TO_HZ( MAT_FILE_DATA_PT );
    end
    else if ( mattsfreq = KHz ) then begin
      CONVERT_KHZ_TO_HZ( MAT_FILE_DATA_PT );
    end
    else if ( mattsfreq <> Hz ) then begin
      TOUCHSTONE_FORMAT_ERROR;
    end;

    if ( mattsformat = DB ) then begin
      CONVERT_S_DB_TO_S_RI( MAT_S_PT, MAT_FILE_DATA_PT );
    end
    else if ( mattsformat = MA ) then begin
      CONVERT_S_MA_TO_S_RI( MAT_S_PT, MAT_FILE_DATA_PT );
    end
    else if ( mattsformat = RI ) then begin
      MAT_S_PT := MAT_FILE_DATA_PT;
    end
    else TOUCHSTONE_FORMAT_ERROR;


    case ( mattype ) of
    S2P: begin
      TRANSPOSE_S_MAT(MAT_S_PT);
      CONVERT_S_TO_Y( MAT_Y_PT, MAT_S_PT, mattsRref );
    end;
    S1P, S3P,S4P,S5P,S6P,S7P,S8P,S9P: begin
      CONVERT_S_TO_Y( MAT_Y_PT, MAT_S_PT, mattsRref);
    end;
    else
     UNKNOWN_MAT_ERROR
    end;

   end;
 END;


{***************************************************************************
  Convert  MAT_FILE_DATA into MAT_Y_PT (YRI) internal format
 ***************************************************************************}
 PROCEDURE CONVERT_MAT_DATA;
 VAR
  m_ptr:matptr;

 BEGIN
    m_ptr:=MAT_PT;
    while ( m_ptr<>NIL ) do begin
       with (m_ptr^) do begin
          case ( mattype ) of
           YRI: begin
                  m_ptr^.MAT_Y_PT:=m_ptr^.MAT_FILE_DATA_PT;
           end;
           S1P, S2P, S3P, S4P, S5P, S6P, S7P, S8P, S9P: begin
                  CONVERT_S_TOUCHSTONE_DATA (m_ptr);
           end;
          else
            UNKNOWN_MAT_ERROR
       end;
       m_ptr:=m_ptr^.matnext;
       end
    end;
  END;


{***************************************************************************
  From $MAT: CREATE_MAT_DEF, EXTRACT_MAT_DATA, CONVERT_MAT_DATA, CREATE_MAT_FREQ_LISTS;
  Extract data from files
  Create set of G VAR components for each B element
  Create set of VAR CLIST for each B element
 ***************************************************************************}
 PROCEDURE PROCESS_MAT_FILES;
 BEGIN

  CREATE_MAT_DEF;                 /// create matrix list pointed by MAT_PT

  EXTRACT_MAT_DATA;               /// for each MAT_PT fetch data from files to list by MAT_FILE_DATA_PT
  {$IFDEF Debug}
  LIST_DEBUG_INFO('--- MATRIX DATA EXTRACTED FROM FILE ---');
  LIST_MATRIX;
  {$ENDIF}
  CONVERT_MAT_DATA;               /// convert S into Y
  {$IFDEF Debug}
  LIST_DEBUG_INFO('--- MATRIX DATA CONVERTED ---');
  LIST_MATRIX;
  {$ENDIF}
  CREATE_MAT_COMM_FREQ_LISTS;

 END;


{***************************************************************************
  From Bxx CREATE_B_COMPONENTS, ADD_B_COMPONENTS;
  Create set of G VAR components for each B element
 ***************************************************************************}

 PROCEDURE PROCESS_B_COMP;
 BEGIN
  CREATE_B_COMPONENTS; { for each B element create G VAR component }
  ADD_B_COMPONENTS;
 END;

{***************************************************************************
 Search from head to find if a freq is already in the list.
 @version - 1.0
 @param val:DOUBLE -
 @param head_ptr:matrixpt - when nil initializes list
 @return f_mat_ptr:matrixpt - pointer to found value
 @return TRUE - freq not found
 ***************************************************************************}

FUNCTION MAT_F_NOT_DEFINED( f:DOUBLE; head_ptr:matrixpt; VAR f_mat_ptr:matrixpt ):BOOLEAN;
VAR
  mat_ptr:matrixpt;
  TEST:BOOLEAN;
BEGIN
    mat_ptr:=head_ptr;
    f_mat_ptr:=NIL;
    TEST:=TRUE;
    while ( mat_ptr <> NIL ) do begin
       if ( mat_ptr^.fmat = f ) then begin
          TEST:=FALSE;
          f_mat_ptr:=mat_ptr;
          break;
       end;
       mat_ptr:=mat_ptr^.next_f_mat_pt;
    end;
    MAT_F_NOT_DEFINED :=TEST;
END;



{***************************************************************************
 Add records to listmat using head and tail pointer

 @version - 1.0
 @param mat_ptr:matrixpt - record added to the tail of list
 @param head_ptr:matrixpt - when nil initializes list
 @param tail_ptr:matrixpt - used to link elements
 ***************************************************************************}

PROCEDURE ADD_NEW_Y_MAT(mat_ptr:matrixpt; VAR head_ptr,tail_ptr:matrixpt);
BEGIN
 if (head_ptr=NIL) then begin
    NEW(head_ptr);
    tail_ptr:=head_ptr
 end
 else begin
    NEW(tail_ptr^.next_f_mat_pt);
    tail_ptr:=tail_ptr^.next_f_mat_pt;
 end;
 tail_ptr^.fmat:=mat_ptr^.fmat;
 tail_ptr^.matcol:=mat_ptr^.matcol;
 tail_ptr^.matrow:=mat_ptr^.matrow;
 tail_ptr^.ymat:=mat_ptr^.ymat;
 tail_ptr^.next_f_mat_pt:=NIL
END;

{***************************************************************************
 Search by freq from head and return f_mat_ptr - a pointer to GREATEST() < f
 If exist, next is f_mat_ptr^.next_f_mat_pt is the pointer to SMALLEST_LARGER.
  if f_mat_ptr=nil - means, fmat of head is > f

 @version - 1.0
 @param f:DOUBLE -   LARGEST(f_mal_ptr^.fmat) < f
 @param head_ptr:matrixpt -
 @return f_mat_ptr:listbpt -
 ***************************************************************************}

PROCEDURE GET_F1_MAT(f:DOUBLE; head_ptr:matrixpt; VAR f_mat_ptr:matrixpt );
VAR
  mat_ptr:matrixpt;
BEGIN
    f_mat_ptr:=NIL;
    mat_ptr:=head_ptr;
    while ( mat_ptr <> NIL ) do begin
       if ( mat_ptr^.fmat > f ) then break;  /// stop if current is > value - previouse, is the one sought
       f_mat_ptr:=mat_ptr;                        ///  keep this as a reference - last kept is the one sought
       mat_ptr:=mat_ptr^.next_f_mat_pt;
    end;

END;

{***************************************************************************
 Search back from head and return pointers f1_mat_ptr f2_mat_ptr
 This is to handle a case when f1<f2<f i.e. f is greater than matrix frequency
 @version - 1.0

 @param head_ptr:listbpt - when nil initializes list
 @return val_ptr:listbpt - used to link elements
 ***************************************************************************}

PROCEDURE GET_F1F2_MAT(head_ptr:matrixpt; VAR f1_mat_ptr,f2_mat_ptr:matrixpt );
BEGIN
    if ( f1_mat_ptr=head_ptr ) then begin
      f2_mat_ptr:=f1_mat_ptr;                 /// this is worst case f1 is 1 element matrix so this is the best thing to do
    end
    else begin
      f2_mat_ptr:=f1_mat_ptr;
      f1_mat_ptr:=head_ptr;
      while ( f1_mat_ptr <> NIL ) do begin
       if ( f1_mat_ptr^.next_f_mat_pt= f2_mat_ptr )   then break;  /// stop if current is > value - previouse is the one sought
       f1_mat_ptr:=f1_mat_ptr^.next_f_mat_pt;
      end;
    end;
END;

{***************************************************************************
 Return valid f2_mat_ptr  - must not be nil.
 If  f1_mat_ptr^.next_f_mat_pt <> nil this is the value SMALLEST_LARGER so ->f2
 best scenario is f1_mat_ptr.fmat has next, than  f1<f<f2 = f2_mat_ptr.fmat

 @version - 1.0
 @param head_ptr:matrixpt - ptr to head
 @return f1_mat_ptr: - ptr to f1 matrix
 @return f2_mat_ptr: - ptr to f2 matrix
 ***************************************************************************}

PROCEDURE GET_F2_MAT(head_ptr:matrixpt; VAR f1_mat_ptr,f2_mat_ptr:matrixpt );
BEGIN
  if ( f1_mat_ptr=NIL ) then begin
    f1_mat_ptr:=head_ptr;
    if ( f1_mat_ptr^.next_f_mat_pt=NIL ) then begin
        f2_mat_ptr:=f1_mat_ptr;                         /// MAT has 1 freq defined  so  f<f1=f2
    end
    else begin
       f2_mat_ptr:=f1_mat_ptr^.next_f_mat_pt;           /// f< f1 < f2
    end
  end
  else begin
      if ( f1_mat_ptr^.next_f_mat_pt=NIL ) then begin   /// f1 < f but no f2 so this is a case for f1<f2<f
        GET_F1F2_MAT(head_ptr, f1_mat_ptr, f2_mat_ptr); /// this is to handle f1<f2<f
      end
      else begin
        f2_mat_ptr:=f1_mat_ptr^.next_f_mat_pt;          /// best case: f1 and f2 clearly defined
      end
  end

END;



{***************************************************************************
 Interpolate matrix values for freq having a y_mat_ptr(f1), so that f1<f<f2

 @version - 1.0
 @param freq:double -   new entry freq
 @param tail_ptr:matrixpt - pointer to new matrix entry in matrix list
 @param y1_mat_ptr:matrixpt - might not be NIL - pointer to f1 reference
 @param y2_mat_ptr:matrixpt - might not be NIL - pointer to f2 reference
 ***************************************************************************}

PROCEDURE INTERPOLATE_F1F2(f:double; f_mat_ptr, f1_mat_ptr, f2_mat_ptr:matrixpt);
VAR
 f1,f2,u: double;
 i,j:integer;
 BEGIN
 f_mat_ptr^.fmat:=f;
 f_mat_ptr^.matcol:=f1_mat_ptr^.matcol;
 f_mat_ptr^.matrow:=f1_mat_ptr^.matrow;
 f_mat_ptr^.next_f_mat_pt:=NIL;
 f1:=f1_mat_ptr^.fmat;
 f2:=f2_mat_ptr^.fmat;
 if ( f1=f2 ) then begin
  u:=0.0;        /// if (y1_mat_ptr=y2_mat_ptr) for 1 element of MAT or else ...
 end
 else begin
  u:=(f-f1)/(f2-f1);  /// u=0 for f1, u=1 for f2
 end;
 for i:=1 to f_mat_ptr^.matrow  do begin
      for  j:=1 to f_mat_ptr^.matcol do begin

        f_mat_ptr^.ymat[i,j].Re:=(1.0-u)*f1_mat_ptr^.ymat[i,j].Re + (u)*f2_mat_ptr^.ymat[i,j].Re;
        f_mat_ptr^.ymat[i,j].Im:=(1.0-u)*f1_mat_ptr^.ymat[i,j].Im + (u)*f2_mat_ptr^.ymat[i,j].Im;

      end;
  end;

END;



{***************************************************************************
 For $FREQ list interpolate MAT_Y_PT into MAT_INTERP_Y_PT
 ***************************************************************************}

 PROCEDURE INTERPOLATE_MAT(t_ptr:taskpt);
 VAR
  m_ptr:matptr;
  f_ptr:listbpt;
  MAT_INTERP_DATA_TAIL_PT:matrixpt;
  f1_mat_ptr:matrixpt;
  f2_mat_ptr:matrixpt;
  freq:double;
 BEGIN

  m_ptr:=MAT_PT;
  while m_ptr<>NIL do begin   /// for all MAT
      m_ptr^.MAT_INTERP_Y_PT:=NIL;
      MAT_INTERP_DATA_TAIL_PT:=NIL;
      f_ptr:=t_ptr^.FREQ_PT;
      while f_ptr<>NIL do begin  /// for each freq
        freq:=f_ptr^.value;
        if ( MAT_F_NOT_DEFINED(freq, m_ptr^.MAT_Y_PT, f1_mat_ptr) ) then begin
          GET_F1_MAT(freq, m_ptr^.MAT_Y_PT, f1_mat_ptr);  /// for f find y_mat_ptr(f1) so that f1<f<f2
          GET_F2_MAT( m_ptr^.MAT_Y_PT, f1_mat_ptr, f2_mat_ptr);
          ADD_NEW_Y_MAT(f1_mat_ptr, m_ptr^.MAT_INTERP_Y_PT, MAT_INTERP_DATA_TAIL_PT); /// only temp - create record
          INTERPOLATE_F1F2(freq, MAT_INTERP_DATA_TAIL_PT, f1_mat_ptr, f2_mat_ptr);     /// f1<f<f2
        end
        else begin
          ADD_NEW_Y_MAT(f1_mat_ptr, m_ptr^.MAT_INTERP_Y_PT, MAT_INTERP_DATA_TAIL_PT); /// copy record
        end;
        f_ptr:=f_ptr^.vpt;
      end;
    m_ptr:=m_ptr^.matnext;
    end;

 END;

{***************************************************************************
 Create $VAR var CLIST and store in MAT_VAR_PT list for each MATrix
 ***************************************************************************}

 PROCEDURE CREATE_MAT_VAR_LISTS(t_ptr:taskpt);
 VAR
  m_ptr:matptr;
  mdata_ptr:matrixpt;
  s_i,s_j:string;
  s_reval, s_imval :string;
  s_ins:string;
  MAT_VAR_TAIL_PT:listapt;
  i,j:INTEGER;
 BEGIN

  m_ptr:=MAT_PT;
  while m_ptr<>NIL do begin
    m_ptr^.MAT_VAR_PT:=NIL;
    {m_ptr^.MAT_FREQ_PT:=NIL;}


    for i:=1 to m_ptr^.MAT_INTERP_Y_PT^.matrow  do begin
      for  j:=1 to m_ptr^.MAT_INTERP_Y_PT^.matcol do begin
          STR(i,s_i);
          STR(j,s_j);
          s_ins:=CONCAT('$VAR '+g_MAT_str+s_i+s_j+'.'+m_ptr^.matname + '  CLIST');
          CLEAR_LINE;
          INSERT(s_ins,line,1);
          ADD_TO_LISTA(m_ptr^.MAT_VAR_PT, MAT_VAR_TAIL_PT);
          mdata_ptr:=m_ptr^.MAT_INTERP_Y_PT;
          while ( mdata_ptr<>nil ) do begin
            STR(mdata_ptr^.ymat[i,j].Re,s_reval);
            STR(mdata_ptr^.ymat[i,j].Im,s_imval);
            s_ins:=CONCAT(s_reval + '  ' + s_imval );
            CLEAR_LINE;
            INSERT(s_ins,line,1);
            ADD_TO_LISTA(m_ptr^.MAT_VAR_PT, MAT_VAR_TAIL_PT);
            mdata_ptr:=mdata_ptr^.next_f_mat_pt;
          end;
      end;
    end;

    m_ptr:=m_ptr^.matnext;
  end;

 END;



{***************************************************************************
  Insert $VAR var CLIST from MAT_VAR_PT list in place of  $MAT into job^..CDEF_PT
***************************************************************************}
 PROCEDURE INSERT_MAT_VAR_LISTS(t_ptr:taskpt);
 VAR
  l_ptr:listapt;
  lvar_ptr,list_head_ptr, list_tail_ptr:listapt;
  m_ptr:matptr;
  found:BOOLEAN;

 BEGIN



  l_ptr:=t_ptr^.CDEF_PT;
  while ( l_ptr<>NIL ) do begin
    line:=l_ptr^.oneline;    // search CDEF for $MAT definition
    if ( Pos('$MAT',UpperCase(line))<>0 ) then begin
      m_ptr:=MAT_PT;
      found:=FALSE;
      while ( (m_ptr<>NIL) and (not found) ) do begin    // search MAT_PT list for matching definition
        if ( m_ptr^.line_pt = l_ptr ) then begin
          found:=TRUE;                      // insert MAT_VAR_PT to CDEF - the list will grow so be carefull
          list_head_ptr:=l_ptr^.lpt;        // this is a link after insertion
          list_tail_ptr:=l_ptr;
          list_tail_ptr^.lpt:=NIL;
          lvar_ptr:=m_ptr^.MAT_VAR_PT;       // start adding $VAR CLIST
          while ( lvar_ptr<>NIL ) do begin
            line:=lvar_ptr^.oneline;
            ADD_TO_LISTA(t_ptr^.CDEF_PT,list_tail_ptr);
            lvar_ptr:=lvar_ptr^.lpt;
          end;
          list_tail_ptr^.lpt:=list_head_ptr; // restore link }
          l_ptr:=list_tail_ptr;              // pointer will be advanced to next original i.e. not inserted line
        end;
        m_ptr:=m_ptr^.matnext;
      end;
      if ( not found ) then begin
        MAT_MATCH_ERROR;      // $MAT does not have a matching component
      end;
    end;
    l_ptr:=l_ptr^.lpt;
  end;

 END;

 end.
