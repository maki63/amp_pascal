UNIT RAW8;
interface
USES
 SysUtils,
 TYPE8,VAREXT8,VAR8,TASK8,COMP8;

 PROCEDURE RAW_TF(job:taskpt);
 PROCEDURE RAW_TF_SENS(job:taskpt);
 PROCEDURE RAW_D(job:taskpt);
 PROCEDURE WRITE_RAW_FILES;

implementation
USES Amp8_main;


function LIST_RAW_PAR_COMP(j:taskpt) : string ;
VAR
 par_pt:parpt;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 s:string[250];
 
BEGIN

 s:='@PAR: '; 
 IF (par_pt<>NIL) THEN
 BEGIN

  y_ptr:=Y_head;
  while y_ptr<>NIL do
  begin
       if ( y_ptr^.yvar = PARAM) then begin
          par_pt := y_ptr^.yparpt ;
          if ( par_pt^.PAR_complex ) then begin
            s:= s + y_ptr^.yname + ' = (' + FloatToStrF(par_pt^.PVC_CURR_PT^.valre , ffExponent, 8, 4) +' + i(' + FloatToStrF(par_pt^.PVC_CURR_PT^.valim, ffExponent, 8, 4) +')) ';
          end
          else begin
            s:= s + y_ptr^.yname + ' = (' + FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4 ) + ') ';
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
            s:= s + g_ptr^.gname + ' = (' + FloatToStrF(par_pt^.PVC_CURR_PT^.valre, ffExponent, 8, 4) + ' + i(' + FloatToStrF(par_pt^.PVC_CURR_PT^.valim, ffExponent, 8, 4) + ')) ';
          end
          else begin
            s:= s + g_ptr^.gname + ' = (' + FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4) + ') ';
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
            s:= s + z_ptr^.zname + ' = (' + FloatToStrF(par_pt^.PVC_CURR_PT^.valre, ffExponent, 8, 4) + ' + i(' + FloatToStrF(par_pt^.PVC_CURR_PT^.valim, ffExponent, 8, 4) + ')) ';
          end
          else begin
            s:= s + z_ptr^.zname + ' = (' + FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4) + ') ';
          end
       end;
       z_ptr:=z_ptr^.znext;
  end;

  r_ptr:=R_head;
  while r_ptr<>NIL do
  begin
       if ( r_ptr^.rvar = PARAM) then begin
          par_pt := r_ptr^.rparpt ;
          s:= s + r_ptr^.rname + ' = ('+ FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4) + ') ';
       end;
       r_ptr:=r_ptr^.rnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do
  begin
       if ( c_ptr^.cvar = PARAM) then begin
          par_pt := c_ptr^.cparpt ;
          s:= s + c_ptr^.cname + ' = (' + FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4) + ') ';
       end;
       c_ptr:=c_ptr^.cnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do
  begin
       if ( l_ptr^.lvar = PARAM) then begin
          par_pt := l_ptr^.lparpt ;
          s:= s + l_ptr^.lname + ' = ('+ FloatToStrF(par_pt^.PVR_CURR_PT^.value, ffExponent, 8, 4 ) + ') ';
       end;
       l_ptr:=l_ptr^.lnext;
  end;

 END;
  Result := s;
END;



{***************************************************************************
 Add names to raw var name list

 @version - 1.0
 @param head_pt:lists_pt - head of list
 @param varname:STRING   - var name
 ***************************************************************************}

PROCEDURE ADD_RAW_VARNAME( var head_pt:lists_pt; varname:STRING);
  VAR
   l_pt:lists_pt;
  BEGIN
   if ( head_pt=nil ) then begin
    NEW(head_pt);
    l_pt:=head_pt;
   end
   else begin
   l_pt:=head_pt; // search tail of the list of names
    while ( l_pt^.next_name_pt<>nil ) do begin
      l_pt:=l_pt^.next_name_pt;
    end;
    NEW(l_pt^.next_name_pt);
    l_pt:=l_pt^.next_name_pt;
   end;
   l_pt^.name_str:=varname;
   l_pt^.next_name_pt:=nil;

 END;


{***************************************************************************
 Add real values to point list

 @version - 1.0
 @param head_pt:raw_point_pt_type - head of list
 @param val_pt:listbpt
 ***************************************************************************}

PROCEDURE ADD_RAW_LISTB_TO_POINTS( var head_pt:raw_point_list_pt_type; val_pt:listbpt );
  VAR
   point_pt:raw_point_list_pt_type;
   point_tail_pt:listcpt;
  BEGIN

    if ( head_pt=nil ) then begin // if head is nil then you have to create a new points
      while ( val_pt <> nil ) do begin
        if ( head_pt=nil ) then begin
          NEW(head_pt);                    // this is new point
          point_pt:=head_pt;
        end else begin
         NEW(point_pt^.next_point_pt);     // this is new point
         point_pt:=point_pt^.next_point_pt;
        end;
        point_pt^.point:=nil;
        point_pt^.next_point_pt:=nil;

        NEW(point_pt^.point); // this is new point - each point is a new list
        point_pt^.next_point_pt:=nil;

        point_pt^.point^.valre:=val_pt^.value;
        point_pt^.point^.valim:=0.0;
        point_pt^.point^.cvpt:=nil;
        val_pt:=val_pt^.vpt;
      end
   end
   else begin // if head is not nil then you have to add values to existing points
      point_pt:=head_pt;
      while ( (val_pt <> nil) and (point_pt <> nil) ) do begin
          if ( (val_pt = nil) or (point_pt = nil) ) then begin
            RAW_POINTS_ERROR;
          end;
          point_tail_pt:=point_pt^.point;
          while ( point_tail_pt^.cvpt<>nil ) do begin
            point_tail_pt:=point_tail_pt^.cvpt;
          end;
          NEW(point_tail_pt^.cvpt); // this is a new value to the point - each point is a new list
          point_tail_pt:=point_tail_pt^.cvpt;

          point_tail_pt^.valre:=val_pt^.value;
          point_tail_pt^.valim:=0.0;
          point_tail_pt^.cvpt:=nil;

          point_pt:=point_pt^.next_point_pt;
          val_pt:=val_pt^.vpt;
      end;

   end;


 END;

{***************************************************************************
 Add complex values to point list

 @version - 1.0
 @param head_pt:raw_point_pt_type - head of list
 @param val_pt:listcpt
 ***************************************************************************}

PROCEDURE ADD_RAW_LISTC_TO_POINTS( var head_pt:raw_point_list_pt_type; val_pt:listcpt );
  VAR
   point_pt:raw_point_list_pt_type;
   point_tail_pt:listcpt;
  BEGIN

    if ( head_pt=nil ) then begin // if head is nil then you have to create a new points
      while ( val_pt <> nil ) do begin
        if ( head_pt=nil ) then begin
          NEW(head_pt);                    // this is a pointer to new list of points
          point_pt:=head_pt;
        end else begin
          NEW(point_pt^.next_point_pt);     // this is new point
          point_pt:=point_pt^.next_point_pt;
        end;
        point_pt^.point:=nil;
        point_pt^.next_point_pt:=nil;
        NEW(point_pt^.point);   // this is new point - each point is a new list so create a new list
        point_pt^.point^.valre:=val_pt^.valre;
        point_pt^.point^.valim:=val_pt^.valim;
        point_pt^.point^.cvpt:=nil;
        val_pt:=val_pt^.cvpt;
      end
   end
   else begin // if head is not nil then you have to add values to existing points
      point_pt:=head_pt;
      while ( (val_pt <> nil) and (point_pt <> nil) ) do begin
          if ( (val_pt = nil) or (point_pt = nil) ) then begin
            RAW_POINTS_ERROR;
          end;
          point_tail_pt:=point_pt^.point;
          while ( point_tail_pt^.cvpt<>nil ) do begin
            point_tail_pt:=point_tail_pt^.cvpt;
          end;
          NEW(point_tail_pt^.cvpt); // this is a new value to the point - each point is a new list
          point_tail_pt:=point_tail_pt^.cvpt;

          point_tail_pt^.valre:=val_pt^.valre;
          point_tail_pt^.valim:=val_pt^.valim;
          point_tail_pt^.cvpt:=nil;

          point_pt:=point_pt^.next_point_pt;
          val_pt:=val_pt^.cvpt;
      end;

   end;


 END;

{***************************************************************************
 Add complex values to point list

 @version - 1.0
 @param head_pt:raw_point_pt_type - head of list
 @param val_pt:listcpt
 ***************************************************************************}

PROCEDURE ADD_RAW_DR_TO_POINTS( var head_pt:raw_point_list_pt_type; val_pt:drpt );
  VAR
   point_pt:raw_point_list_pt_type;
   point_tail_pt:listcpt;
  BEGIN

    if ( head_pt=nil ) then begin // if head is nil then you have to create a new points
      while ( val_pt <> nil ) do begin
        if ( head_pt=nil ) then begin
          NEW(head_pt);                    // this is a pointer to new list of points
          point_pt:=head_pt;
        end else begin
         NEW(point_pt^.next_point_pt);     // this is new point
         point_pt:=point_pt^.next_point_pt;
        end;
        point_pt^.point:=nil;
        point_pt^.next_point_pt:=nil;
        NEW(point_pt^.point);   // this is new point - each point is a new list so create a new list
        point_pt^.next_point_pt:=nil;

        point_pt^.point^.valre:=val_pt^.red;
        point_pt^.point^.valim:=val_pt^.imd;
        point_pt^.point^.cvpt:=nil;
        val_pt:=val_pt^.drptn;
      end
   end
   else begin // if head is not nil then you have to add values to existing points
      point_pt:=head_pt;
      while ( (val_pt <> nil) and (point_pt <> nil) ) do begin
          if ( (val_pt = nil) or (point_pt = nil) ) then begin
            RAW_POINTS_ERROR;
          end;
          point_tail_pt:=point_pt^.point;
          while ( point_tail_pt^.cvpt<>nil ) do begin
            point_tail_pt:=point_tail_pt^.cvpt;
          end;
          NEW(point_tail_pt^.cvpt); // this is a new value to the point - each point is a new list
          point_tail_pt:=point_tail_pt^.cvpt;

          point_tail_pt^.valre:=val_pt^.red;
          point_tail_pt^.valim:=val_pt^.imd;
          point_tail_pt^.cvpt:=nil;

          point_pt:=point_pt^.next_point_pt;
          val_pt:=val_pt^.drptn;
      end;

   end;


 END;

{***************************************************************************
  This is a mutation of MCAD_TF_SENS - so operates just like WRITE_TF_SENS
  Since sens is only a flag - Major,Middle,Minor task numbers remain the same
  thus all sensitivities are appeneded to the same file as a origin TF
  *  @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

PROCEDURE RAW_TF_SENS(job:taskpt);
VAR

 f_ptr :listbpt;
 d_ptr:dptr;
 y_ptr:yptr;
 z_ptr:zptr;
 g_ptr:gptr;
 r_ptr:rptr;
 c_ptr:cptr;
 l_ptr:lptr;
 Ysens_TAIL_PT:listcpt;
 YisLOAD:BOOLEAN;

BEGIN

{ Create list of admittances to avoid overloading of the heap - one list for YGRLC}
 f_ptr:=job^.FREQ_PT;
 Ysens_HEAD_PT:=NIL;
 while ( f_ptr<>NIL ) do begin
     ADD2CPLX_LIST(Ysens_HEAD_PT, Ysens_TAIL_PT, 0.0, 0.0);
     f_ptr:=f_ptr^.vpt;
 end;
{* The coffactor list starts from DL and DN                               *}

 d_ptr:=job^.COFF_PT^.dnext^.dnext;

{The coffactor order is: Y,G,R,C,L}
{* for each component                                                    *}
 y_ptr:=Y_head;
 WHILE (y_ptr<>NIL) DO BEGIN
   WITH(y_ptr^) DO BEGIN
      if ( yvar<>GEN ) then begin
        CALC_Ysens_Y(y_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
        IF (y_ptr=Y0_PT) THEN YisLOAD:=TRUE ELSE YisLOAD:=FALSE;
        COMPUTE_SENS_VAL(job^.FREQ_PT,yname,YisLOAD,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
        RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
        ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+yname);
        ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
        d_ptr:=d_ptr^.dnext^.dnext
      end;
    END;
    y_ptr:=y_ptr^.ynext
 END;

 g_ptr:=G_head;
 WHILE (g_ptr<>NIL) DO BEGIN
   WITH(g_ptr^) DO BEGIN
    if ( gvar<>GEN ) then begin
      CALC_Ysens_G(g_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,gname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+gname);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  g_ptr:=g_ptr^.gnext
 END;

 z_ptr:=Z_head;
 WHILE (z_ptr<>NIL) DO BEGIN
   WITH(z_ptr^) DO BEGIN
      CALC_Ysens_Z(z_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,zname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+zname);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
  END;
  z_ptr:=z_ptr^.znext
 END;

 r_ptr:=R_head;
 WHILE r_ptr<>NIL DO BEGIN
  WITH r_ptr^ DO BEGIN
   if ( rvar<>GEN ) then begin
      CALC_Ysens_R(r_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,rname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+rname);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    end;
  END;
  r_ptr:=r_ptr^.rnext
 END;

 c_ptr:=C_head;
 WHILE c_ptr<>NIL DO BEGIN
  WITH c_ptr^ DO BEGIN
      CALC_Ysens_C(c_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,cname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+cname);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
    END;
    c_ptr:=c_ptr^.cnext
 END;

 l_ptr:=L_head;
 WHILE l_ptr<>NIL DO BEGIN
  WITH l_ptr^ DO BEGIN
      CALC_Ysens_L(l_ptr, job^.FREQ_PT, Ysens_HEAD_PT);
      COMPUTE_SENS_VAL(job^.FREQ_PT,lname,FALSE,Ysens_HEAD_PT,job^.COFF_PT,d_ptr);
      RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'S_'+TF_name+'_'+lname);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, SrSi_PT);
      d_ptr:=d_ptr^.dnext^.dnext
   END;
   l_ptr:=l_ptr^.lnext
 END;

END;

{***************************************************************************
 Scan RAW_LIST_PT for a file with matching Major.Middle.* numbers
 @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

function FIND_RAW_MATCHING_JOB(job:taskpt) : raw_file_pt_type ;
var
    p_raw_file:raw_file_pt_type;

Begin

    p_raw_file:= RAW_LIST_PT;
    Result := nil;
    while p_raw_file <> nil do begin  
        if (p_raw_file^.numberMajor=job^.numberMajor) and (p_raw_file^.numberMiddle=job^.numberMiddle) then begin
            Result := p_raw_file;
            break;
        end;    
        p_raw_file := p_raw_file^.next_raw_file_pt;
    end;
        
End;


{***************************************************************************
 Scan from RAW_LIST_PT and add to the list a new allocated file
 @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

function ALLOC_NEW_RAW_FILE(job:taskpt) : raw_file_pt_type ;
var
    p_raw_file:raw_file_pt_type;

Begin    
    if RAW_LIST_PT = nil then begin
        NEW(RAW_LIST_PT);
        p_raw_file := RAW_LIST_PT;
    end
    else begin    
        p_raw_file:=RAW_LIST_PT;
        while (p_raw_file^.next_raw_file_pt <> nil) do begin
            p_raw_file := p_raw_file^.next_raw_file_pt;
        end;
        NEW(p_raw_file^.next_raw_file_pt);
        p_raw_file := p_raw_file^.next_raw_file_pt;    
    end;
    
    p_raw_file^.next_raw_file_pt:=nil; // this is a pointer to next file
    p_raw_file^.point_list_pt:=nil;
    p_raw_file^.var_list_pt:=nil;
    p_raw_file^.para_descr:='';
    
    p_raw_file^.numberMajor:=job^.numberMajor; // references for Major, Middle
    p_raw_file^.numberMiddle:=job^.numberMiddle; // all jobs with equal Major & Middle goes to the same file
    p_raw_file^.task_name:=job^.task_name;
    if (p_raw_file^.numberMiddle > 0) then begin
       p_raw_file^.para_descr := LIST_RAW_PAR_COMP(job );   // add list of params to file description when Middle > 0 i.e. there are some params  
    end;        
    
    Result := p_raw_file;
End;


{***************************************************************************
 Add data to raw list structure
 Check the number of freq points:
  if equal then add points
  else create new file and start with the begginig

 @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

 PROCEDURE RAW_TF(job:taskpt);

 BEGIN

    RAW_FILE_PT := FIND_RAW_MATCHING_JOB(job);
    if (( RAW_FILE_PT <> nil)) then begin 
     if ( REAL_ELEMENT_COUNTER(job^.FREQ_PT) = RAW_FILE_PT^.raw_data_rec.num_of_points ) then begin
        RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
        ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,TF_name);
        ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, TFri_PT);
     end
     else
     begin
        RAW_POINTS_ERROR;  // Major, Middle numbers indicate that data should belong to current set of data
     end
    end
    else begin
      
      RAW_FILE_PT:= ALLOC_NEW_RAW_FILE(job); // Major, Middle numbers indicate that data should belong to new *.r file 

      RAW_FILE_PT^.raw_data_rec.num_of_var:=2;
      RAW_FILE_PT^.raw_data_rec.num_of_points:=REAL_ELEMENT_COUNTER(job^.FREQ_PT);
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'frequency');
      ADD_RAW_LISTB_TO_POINTS(RAW_FILE_PT^.point_list_pt, job^.FREQ_PT);
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,TF_name);
      ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, TFri_PT);
    end
 END;


{***************************************************************************
 Add data to raw list structure
 Check the number of freq points:
  if equal then add points
  else create new file and start with the begginig

 @version - 1.0
 @param job:taskpt - pointer to the current task
 ***************************************************************************}

 PROCEDURE RAW_D(job:taskpt);
 VAR 
  d_ptr:dptr;
 
 BEGIN

    d_ptr:=job^.COFF_PT;
    WHILE d_ptr<>NIL DO
    BEGIN
     d_ptr^.drfpt:=d_ptr^.CF_PT;
     d_ptr:=d_ptr^.dnext
    END;   
   
    RAW_FILE_PT := FIND_RAW_MATCHING_JOB(job);
    if (( RAW_FILE_PT <> nil)) then begin      
     if ( REAL_ELEMENT_COUNTER(job^.FREQ_PT) = RAW_FILE_PT^.raw_data_rec.num_of_points ) then begin
 
        d_ptr:=job^.COFF_PT;
        while d_ptr<>NIL do
        begin
         RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
         ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,d_ptr^.dname);
         ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, d_ptr^.CF_PT);
         d_ptr:=d_ptr^.dnext
        end
            
     end
     else
     begin
        RAW_POINTS_ERROR;  // Major, Middle numbers indicate that data should belong to current set of data
     end
    end
    else begin
      
      RAW_FILE_PT:= ALLOC_NEW_RAW_FILE(job); // Major, Middle numbers indicate that data should belong to new *.r file 

      RAW_FILE_PT^.raw_data_rec.num_of_var:=1;
      RAW_FILE_PT^.raw_data_rec.num_of_points:=REAL_ELEMENT_COUNTER(job^.FREQ_PT);
      ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,'frequency');
      ADD_RAW_LISTB_TO_POINTS(RAW_FILE_PT^.point_list_pt, job^.FREQ_PT);
      
      d_ptr:=job^.COFF_PT;
      while d_ptr<>NIL do
      begin
       RAW_FILE_PT^.raw_data_rec.num_of_var:=RAW_FILE_PT^.raw_data_rec.num_of_var+1;
       ADD_RAW_VARNAME(RAW_FILE_PT^.var_list_pt,d_ptr^.dname);
       ADD_RAW_DR_TO_POINTS(RAW_FILE_PT^.point_list_pt, d_ptr^.CF_PT);
       d_ptr:=d_ptr^.dnext
      end      
    
    end
 END;


{***************************************************************************}

 PROCEDURE RAW_OPEN;
 VAR
 err:INTEGER;
 BEGIN
  INFO('OPENING:'+RAWSTR);
  if not DirectoryExists(RAWDIRSTR) then CreateDir(RAWDIRSTR);
  {$I-}
  ASSIGNFile(RAWF,RAWSTR);
  REWRITE(RAWF);
  {$I+}
  err:=IOResult;
  IF err<>0 THEN
  BEGIN
   ERROR(4,err)
  END
 END;


{***************************************************************************}

 PROCEDURE RAW_CLOSE;
 VAR
  err:INTEGER;
 BEGIN
  INFO('CLOSING:'+RAWSTR);
 {$I-}
  CLOSEFile(RAWF);
 {$I+}
  err:=IOresult;
  IF err<>0 THEN
  BEGIN
   ERROR(6,err);
  END;
  RAWSTR:='NUL'
 END;

{***************************************************************************
 write variables

 @version - 1.0
 @param f_pt:raw_file_pt_type
 @param n:integer
 ***************************************************************************}

 PROCEDURE WRITE_RAW_VAR(f_pt:raw_file_pt_type);
 VAR
   name_pt:lists_pt;
   p:integer;
 BEGIN
  WRITELN(RAWF,'Variables:');
  name_pt:=f_pt^.var_list_pt;
  p:=0;
  while ( name_pt<>nil ) do begin
    WRITE(RAWF, CHR(9),p,CHR(9),name_pt^.name_str);
    if ( name_pt^.name_str= 'frequency' ) then begin
      WRITELN(RAWF, CHR(9),'frequency');
    end
    else begin
      WRITELN(RAWF, CHR(9),'notype');
    end;
    p:=p+1;
    name_pt:=name_pt^.next_name_pt;
  end;
 END;

{***************************************************************************
 write variables

 @version - 1.0
 @param f_pt:raw_file_pt_type
 @param n:integer
 ***************************************************************************}

 PROCEDURE WRITE_RAW_POINTS(f_pt:raw_file_pt_type);
 VAR
   point_pt:raw_point_list_pt_type;
   values_pt:listcpt;
   p:integer;
 BEGIN
  WRITELN(RAWF,'Values:');
  point_pt:=f_pt^.point_list_pt;
  p:=0;
  while ( point_pt<>nil ) do begin
    WRITE(RAWF,p);
    values_pt:=point_pt^.point;
    while ( values_pt<>nil ) do begin
        WRITELN(RAWF,CHR(9),values_pt^.valre,',',values_pt^.valim);
        values_pt:=values_pt^.cvpt;
    end;
    p:=p+1;
    point_pt:=point_pt^.next_point_pt;
  end;
 END;

{***************************************************************************
 open  write  and close  one_raw_file

 @version - 1.0
 @param f_pt:raw_file_pt_type
 @param n:integer
 ***************************************************************************}

 PROCEDURE WRITE_ONE_RAW_FILE(f_pt:raw_file_pt_type; n:integer);
 VAR
   n_str:string;
   p:integer;
   path_str :string;
   name_str :string;
   r_string:string;

 BEGIN

   
   path_str := ExtractFilePath(OUTSTR);
   name_str := ExtractFileName(OUTSTR);
   
   STR(n,n_str);
   n_str:=CONCAT('r',n_str);
   
   p:=POS('.',name_str);
   if p<>0 then begin
    r_string:=Copy(name_str,1,p)+n_str;
   end
   else begin
    r_string:=name_str+'.'+n_str;
   end;
      
   RAWSTR := path_str+ RAWDIRSTR +'\'+r_string;

   RAW_OPEN;
   WRITELN(RAWF,'Title: Amp AC analysis results for Tasks = (', f_pt^.numberMajor, '.', f_pt^.numberMiddle,'.* ):', f_pt^.task_name, ' ', f_pt^.para_descr);
   WRITELN(RAWF,'Date:'+DateToStr(Date)+' at '+ TimeToStr(Time) );
   WRITELN(RAWF,'Plotname: AC Analysis');
   WRITELN(RAWF,'Flags: complex');
   WRITELN(RAWF,'Sckt. naming: from bottom to top');
   WRITELN(RAWF,'No. Variables: ', f_pt^.raw_data_rec.num_of_var);
   WRITELN(RAWF,'No. Points: ', f_pt^.raw_data_rec.num_of_points);
   WRITE_RAW_VAR(f_pt);
   WRITE_RAW_POINTS(f_pt);
   RAW_CLOSE;
 END;

{***************************************************************************
 Iterate raw file lists
  select one and invoke write_one_raw_file

 @version - 1.0
 @param
 ***************************************************************************}
 
 PROCEDURE WRITE_RAW_FILES();
 VAR
   file_count:integer;
 BEGIN

   if (RAW_LIST_PT <> nil) then begin
    RAW_FILE_PT:=RAW_LIST_PT;
    file_count:=1;
    while ( RAW_FILE_PT<>nil ) do begin
      WRITE_ONE_RAW_FILE(RAW_FILE_PT,file_count);
      file_count:=file_count+1;
      RAW_FILE_PT:= RAW_FILE_PT^.next_raw_file_pt;
    end
  end

 END;

 END.
