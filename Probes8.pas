unit Probes8;

interface
USES
 SysUtils,
 TYPE8,VAR8, VAREXT8, LINE8,DATAIO8;

PROCEDURE  CREATE_PROBES_TF;

implementation

{***************************************************************************}

PROCEDURE ADD2_PROBES_TF_LIST(VAR head,tail:listapt);
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
{*******   add to coff V shorts except one   ************}
{********************************************************}

Procedure ADD_V_EXCEPT_ONE(var s:string; except_v_ptr:vptr);
var
  sva,svb:string;
  v_ptr:vptr;
begin
  v_ptr:= V_head;
  while ( v_ptr<>NIL ) do begin
    if ( v_ptr<>except_v_ptr ) then begin
      STR(v_ptr^.va,sva);
      STR(v_ptr^.vb,svb);
      s:=CONCAT(s,',(',sva,'+',svb,')(',sva,'+',svb,')');
    end;
    v_ptr:=v_ptr^.vnext;
  end;
end;


{********************************************************}
{*******   add to coff J shorts except one   ************}
{********************************************************}

Procedure ADD_J_EXCEPT_ONE(var s:string;  except_j_ptr:pptr; except_port:PORT_PROBE_TYPE );
var
  spa,spb,spc,spd:string;
  p_ptr:pptr;
begin
  p_ptr:= P_head;
  while ( p_ptr<>NIL ) do begin
    if ( p_ptr<>except_j_ptr ) then begin
      if ( p_ptr^.ptype=PROBE_I ) then begin
        STR(p_ptr^.pa,spa);
        STR(p_ptr^.pb,spb);
        s:=CONCAT(s,',(',spa,'+',spb,')(',spa,'+',spb,')');
      end
      else if ( p_ptr^.ptype=PROBE_TI ) then begin
        STR(p_ptr^.pa,spa);
        STR(p_ptr^.pb,spb);
        s:=CONCAT(s,',(',spa,'+',spb,')(',spa,'+',spb,')');
        STR(p_ptr^.pc,spc);
        STR(p_ptr^.pd,spd);
        s:=CONCAT(s,',(',spc,'+',spd,')(',spc,'+',spd,')');
      end
      else if ( p_ptr^.ptype=PROBE_TN ) then begin
        STR(p_ptr^.pa,spa);
        STR(p_ptr^.pb,spb);
        s:=CONCAT(s,',(',spa,'+',spb,')(',spa,'+',spb,')');
      end
      else if ( p_ptr^.ptype=PROBE_TM ) then begin
        STR(p_ptr^.pc,spc);
        STR(p_ptr^.pd,spd);
        s:=CONCAT(s,',(',spc,'+',spd,')(',spc,'+',spd,')');
      end
    end
    else begin
      if (( p_ptr^.ptype=PROBE_TI ) and (except_port=L_PORT)) then begin
        STR(p_ptr^.pc,spc);
        STR(p_ptr^.pd,spd); {short only M_PORT}
        s:=CONCAT(s,',(',spc,'+',spd,')(',spc,'+',spd,')');
      end
      else if (( p_ptr^.ptype=PROBE_TI ) and (except_port=M_PORT)) then begin
        STR(p_ptr^.pa,spa);
        STR(p_ptr^.pb,spb); {short only L_PORT}
        s:=CONCAT(s,',(',spa,'+',spb,')(',spa,'+',spb,')');
      end
      else if (( p_ptr^.ptype=PROBE_TN ) and (except_port=M_PORT)) then begin
        STR(p_ptr^.pa,spa);
        STR(p_ptr^.pb,spb); {short only L_PORT}
        s:=CONCAT(s,',(',spa,'+',spb,')(',spa,'+',spb,')');
      end
      else if (( p_ptr^.ptype=PROBE_TM ) and (except_port=L_PORT)) then begin
        STR(p_ptr^.pc,spc);
        STR(p_ptr^.pd,spd); {short only M_PORT}
        s:=CONCAT(s,',(',spc,'+',spd,')(',spc,'+',spd,')');
      end
    end;

    p_ptr:=p_ptr^.pnext;
  end;

end;


{********************************************************}
{*******   Create TF for P=U Meter and V source  ********}
{****   K=U/V=DL(va+vb)(pa+pb)/ DM(va+vb)(va+vb)    *****}
{*******   all other V and J are shorts          ********}
{********************************************************}
Procedure CREATE_UV_TF(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,sp,spa,spb,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  sp:=CONCAT('(',spa,'+',spb,')'); {* probe *}
  sl:=CONCAT('DL',ss,sp); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,ss); {* DM(va+vb)(va+vb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,NIL, NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,NIL, NIL_PORT);
  // st:=CONCAT ('$TF KU[',p_ptr^.pname,'/',v_ptr^.vname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;


{********************************************************}
{*******   Create TF for P=U Meter and V source  ********}
{****   M=U/I=DL(ia+ib)(pa+pb)/ DM(0+0)(0+0)        *****}
{*******       all V and J are shorts            ********}
{********************************************************}
Procedure CREATE_UI_TF(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,sp,spa,spb,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  sp:=CONCAT('(',spa,'+',spb,')'); {* probe *}
  sl:=CONCAT('DL',ss,sp); {* DL(ia+ib)(pa+pb) *}
  sm:='DM(0+0)(0+0)';     {* DM *}
  ADD_V_EXCEPT_ONE(sl,nil);
  ADD_J_EXCEPT_ONE(sl,nil,NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,nil);
  ADD_J_EXCEPT_ONE(sm,nil,NIL_PORT);
  // st:=CONCAT ('$TF M[',p_ptr^.pname,'/',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF M_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;


{********************************************************}
{*******   Create TF for P=J Meter and V source  ********}
{ N=I/V=DL(va+vb)(pa+pb)/DM(va+vb)(va+vb),(pa+pb)(pa+pb) }
{*******   all other V and J are shorts          ********}
{********************************************************}
Procedure CREATE_JV_TF(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,sp,spa,spb,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  sp:=CONCAT('(',spa,'+',spb,')'); {* probe *}
  sl:=CONCAT('DL',ss,sp); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,ss,',',sp,sp); {* DM(va+vb)(va+vb),(pa+pb)(pa+pb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,p_ptr,DEF_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,p_ptr,DEF_PORT);
  // st:=CONCAT ('$TF N[',p_ptr^.pname,'/',v_ptr^.vname,']=', sl, '/', sm);
  st:=CONCAT ('$TF N_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{*******   Create TF for P=U Meter and V source  ********}
{****  Ki=Ip/Is=DL(ia+ib)(pa+pb)/ DM(pa+pb)(pa+pb)  *****}
{*******       all V and ohter J are shorts      ********}
{********************************************************}
Procedure CREATE_JI_TF(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,sp,spa,spb,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  sp:=CONCAT('(',spa,'+',spb,')'); {* probe *}
  sl:=CONCAT('DL',ss,sp); {* DL(ia+ib)(pa+pb) *}
  sm:=CONCAT('DM',sp,sp); {* DM(pa+pb)(pa+pb) *}
  ADD_V_EXCEPT_ONE(sl,nil);
  ADD_J_EXCEPT_ONE(sl,p_ptr,DEF_PORT);
  ADD_V_EXCEPT_ONE(sm,nil);
  ADD_J_EXCEPT_ONE(sm,p_ptr,DEF_PORT);
  // st:=CONCAT ('$TF KI[',p_ptr^.pname,'/',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{*******   Create TF for P=U Meter and V source  ********}
{****   Z=U/I=DL(pa+pb)(pa+pb)/ DM(0+0)(0+0)        *****}
{*******       all V and J are shorts            ********}
{********************************************************}
Procedure CREATE_Z_TF(p_ptr:pptr);
VAR
  st,sl,sm,sp,spa,spb:string;
BEGIN

  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  sp:=CONCAT('(',spa,'+',spb,')'); {* probe *}
  sl:=CONCAT('DL',sp,sp); {* DL(pa+pb)(pa+pb) *}
  sm:='DM(0+0)(0+0)';     {* DM *}
  ADD_V_EXCEPT_ONE(sl,nil);
  ADD_J_EXCEPT_ONE(sl,NIL, NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,nil);
  ADD_J_EXCEPT_ONE(sm,NIL, NIL_PORT);
  //st:=CONCAT ('$TF Z[',p_ptr^.pname,']=', sl, '/', sm);
  st:=CONCAT ('$TF Z_',p_ptr^.pname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ U(pa,pb)/U(pc,pd)=DL(va+vb)(pa+pb)/ DM(va+vb)(pc+pd)   }
{********************************************************}

Procedure CREATE_TU_FOR_V(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(va+vb)(va+vb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,NIL,NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,NIL,NIL_PORT);
  //st:=CONCAT ('$TF KU[',p_ptr^.pname,'|',v_ptr^.vname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ i(pa,pb)/i(pc,pd)=DL(va+vb)(pa+pb)/ DM(va+vb)(pc+pd)   }
{********************************************************}

Procedure CREATE_TI_FOR_V(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(va+vb)(va+vb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,p_ptr,L_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,p_ptr,M_PORT);
  // st:=CONCAT ('$TF KI[',p_ptr^.pname,'|',v_ptr^.vname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ U(pa,pb)/i(pc,pd)=DL(va+vb)(pa+pb)/ DM(va+vb)(pc+pd)   }
{********************************************************}

Procedure CREATE_TM_FOR_V(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(va+vb)(va+vb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,NIL,NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,p_ptr,M_PORT);
  //st:=CONCAT ('$TF M[',p_ptr^.pname,'|',v_ptr^.vname,']=', sl, '/', sm);
  st:=CONCAT ('$TF M_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ i(pa,pb)/U(pc,pd)=DL(va+vb)(pa+pb)/ DM(va+vb)(pc+pd)   }
{********************************************************}

Procedure CREATE_TN_FOR_V(p_ptr:pptr; v_ptr:vptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sva,svb:string;
BEGIN

  STR(v_ptr^.va,sva);
  STR(v_ptr^.vb,svb);
  ss:=CONCAT('(',sva,'+',svb,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(va+vb)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(va+vb)(va+vb) *}
  ADD_V_EXCEPT_ONE(sl,v_ptr);
  ADD_J_EXCEPT_ONE(sl,p_ptr,L_PORT);
  ADD_V_EXCEPT_ONE(sm,v_ptr);
  ADD_J_EXCEPT_ONE(sm,NIL,NIL_PORT);
  st:=CONCAT ('$TF N_',p_ptr^.pname,'_',v_ptr^.vname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ U(pa,pb)/U(pc,pd)=DL(ia+ib)(pa+pb)/ DM(ia+ib)(pc+pd)   }
{********************************************************}

Procedure CREATE_TU_FOR_I(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(ia+ib)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(ia+ib)(pc+pd) *}
  ADD_V_EXCEPT_ONE(sl,NIL);
  ADD_J_EXCEPT_ONE(sl,NIL,NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,NIL);
  ADD_J_EXCEPT_ONE(sm,NIL,NIL_PORT);
  //st:=CONCAT ('$TF KU[',p_ptr^.pname,'|',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ i(pa,pb)/i(pc,pd)=DL(ia+ib)(pa+pb)/ DM(ia+ib)(pc+pd)   }
{********************************************************}

Procedure CREATE_TI_FOR_I(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(ia+ib)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(ia+ib)(pc+pd) *}
  ADD_V_EXCEPT_ONE(sl,NIL);
  ADD_J_EXCEPT_ONE(sl,p_ptr,L_PORT);
  ADD_V_EXCEPT_ONE(sm,NIL);
  ADD_J_EXCEPT_ONE(sm,p_ptr,M_PORT);
  //st:=CONCAT ('$TF KI[',p_ptr^.pname,'|',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF K_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;


{********************************************************}
{ u(pa,pb)/i(pc,pd)=DL(ia+ib)(pa+pb)/ DM(ia+ib)(pc+pd)   }
{********************************************************}

Procedure CREATE_TM_FOR_I(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(ia+ib)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(ia+ib)(pc+pd) *}
  ADD_V_EXCEPT_ONE(sl,NIL);
  ADD_J_EXCEPT_ONE(sl,NIL,NIL_PORT);
  ADD_V_EXCEPT_ONE(sm,NIL);
  ADD_J_EXCEPT_ONE(sm,p_ptr,M_PORT);
  // st:=CONCAT ('$TF M[',p_ptr^.pname,'|',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF M_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;

{********************************************************}
{ u(pa,pb)/i(pc,pd)=DL(ia+ib)(pa+pb)/ DM(ia+ib)(pc+pd)   }
{********************************************************}

Procedure CREATE_TN_FOR_I(p_ptr:pptr; i_ptr:iptr);
VAR
  st,sl,sm,ss,spL,spM,spa,spb,spc,spd,sia,sib:string;
BEGIN

  STR(i_ptr^.ia,sia);
  STR(i_ptr^.ib,sib);
  ss:=CONCAT('(',sia,'+',sib,')'); {* source *}
  STR(p_ptr^.pa,spa);
  STR(p_ptr^.pb,spb);
  STR(p_ptr^.pc,spc);
  STR(p_ptr^.pd,spd);
  spL:=CONCAT('(',spa,'+',spb,')'); {* probeL *}
  spM:=CONCAT('(',spc,'+',spd,')'); {* probeM *}
  sl:=CONCAT('DL',ss,spL); {* DL(ia+ib)(pa+pb) *}
  sm:=CONCAT('DM',ss,spM); {* DM(ia+ib)(pc+pd) *}
  ADD_V_EXCEPT_ONE(sl,NIL);
  ADD_J_EXCEPT_ONE(sl,p_ptr,L_PORT);
  ADD_V_EXCEPT_ONE(sm,NIL);
  ADD_J_EXCEPT_ONE(sm,NIL,NIL_PORT);
  //st:=CONCAT ('$TF N[',p_ptr^.pname,'|',i_ptr^.iname,']=', sl, '/', sm);
  st:=CONCAT ('$TF N_',p_ptr^.pname,'_',i_ptr^.iname,'=', sl, '/', sm);
  CLEAR_LINE;
  INSERT(st,line,1);

END;


{*******************************************************************}
{*** Determine coff for TF of the type U/V, U/I, J/V, J/I, Z    ****}
{*** and store in PROBES_TF_PT list                             ****}
{*******************************************************************}

PROCEDURE  CREATE_PROBES_TF;
var
  probe_ptr:pptr;
  v_ptr:vptr;
  i_ptr:iptr;
  PROBES_TF_TAIL_PT:listapt;
BEGIN

  PROBES_TF_PT:=NIL;
  PROBES_TF_TAIL_PT:=NIL;
  probe_ptr:= P_head;
  while ( probe_ptr<>NIL ) do begin
    case (probe_ptr^.ptype) of
      PROBE_U:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_UV_TF(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_UI_TF(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    PROBE_I:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_JV_TF(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_JI_TF(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    PROBE_Z:begin
             CREATE_Z_TF(probe_ptr);
             ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
      end;

    PROBE_TU:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_TU_FOR_V(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_TU_FOR_I(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    PROBE_TI:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_TI_FOR_V(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_TI_FOR_I(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    PROBE_TN:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_TN_FOR_V(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_TN_FOR_I(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    PROBE_TM:begin
            v_ptr:= V_head;
            while ( v_ptr<>NIL ) do begin
              CREATE_TM_FOR_V(probe_ptr,v_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              v_ptr:=v_ptr^.vnext;
            end;
            i_ptr:= I_head;
            while ( i_ptr<>NIL ) do begin
              CREATE_TM_FOR_I(probe_ptr,i_ptr);
              ADD2_PROBES_TF_LIST(PROBES_TF_PT,PROBES_TF_TAIL_PT);
              i_ptr:=i_ptr^.inext;
            end;
      end;

    end;
    probe_ptr:=probe_ptr^.pnext;
  end;
END;


end.
