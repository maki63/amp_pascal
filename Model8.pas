unit Model8;

interface
USES
 SysUtils,
 TYPE8,VAR8,VAREXT8,LINE8,DATAIO8,ELEMENT8,TASK8;



PROCEDURE MODEL_COMPONENTS;
PROCEDURE INSERT_MODEL_VAR_LISTS(job:taskpt);
PROCEDURE UPDATE_MOD_COMPONENTS(job:taskpt);


{***************************************************************************}
{***************************************************************************}
{***************************************************************************}
implementation

USES Amp8_main;

VAR
  EXPANDED_COMP_TAIL_PT:listapt;
  EXTENDED_COMP_TAIL_PT:listapt;





{***************************************************************************}
{ search for matching model                                                 }
{***************************************************************************}
{ $MOD FQ MOD0603 1G 30 }
{ FIND THEM IN TASK_PT - MODELS MIGHT BE UPDATED IN OTHER TASKS, BUT HAS TO BE DEFINED IN ROOT }

FUNCTION FIND_MATCHING_MOD ( mod_name:symb; VAR F,Q:double ): BOOLEAN;
VAR
 mod_pt:listapt;
 CheckLine: string;

BEGIN
  Result:=FALSE;
  mod_pt:=TASK_PT^.CDEF_PT;
  while mod_pt<>NIL do begin
    line:=mod_pt^.oneline;
    CheckLine:=UpperCase(line);
    if ( Pos('$MOD',CheckLine)<>0 ) then begin
      if ( Pos('FQ',CheckLine)<>0 ) then begin
        if ( Pos(mod_name,line)<>0  ) then begin
          cpt1:=Pos(mod_name,line);
          cpt2:= FND(' ',' ',cpt1);
          xx:=FALSE;
          RRL;F:=rr;
          RRL;Q:=rr;
          if ((F=0.0) or (Q=0.0)) then begin
            NOT_VALID_FQ_ERROR;
          end;
          Result:=(not xx);
          Break;
        end;
      end;
    end;
    mod_pt:=mod_pt^.lpt;
  end;
END;

{****************************************************************************}
{ FIND THEM IN TASK_PT - MODELS MIGHT BE UPDATED IN OTHER TASKS, BUT HAS TO BE DEFINED IN ROOT }
PROCEDURE MODEL_RLC_PARASITICS; { MODIFY  RLC nodes add PARASITICS }
VAR
 r_ptr:rptr;
 l_ptr:lptr;
 c_ptr:cptr;
 Fr,Qr:double;
 Rp,Lp,Cp:double;
 s_a,s_b,s_c,s_d:string;
 s_mod,sm_val:string;

 BEGIN

  r_ptr:=R_head;
  while r_ptr<>NIL do begin
    with r_ptr^ do begin
      if ( rvar = MODEL_DEF ) then begin
        if (FIND_MATCHING_MOD ( rref, Fr, Qr  )) then begin
          nn:=nn+1;
          STR(ra,s_a);
          STR(rb,s_b);
          STR(nn,s_c);
          rb:=nn;     { this will be internal node }
          Lp:=rv*Qr/(2*pi*Fr);
          Cp:=1/(Lp*(2*pi*Fr)*(2*pi*Fr));
          STR(Lp,sm_val);
          s_mod:=CONCAT('L.'+rname+'    '+s_c+' '+s_b+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
          STR(Cp,sm_val);
          s_mod:=CONCAT('C.'+rname+'    '+s_a+' '+s_b+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
        end
        else begin
          line:=line_pt^.oneline;
          NO_MOD_ERROR;
        end;
      end;
    end;
    r_ptr:=r_ptr^.rnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do begin
    with l_ptr^ do begin
      if ( lvar = MODEL_DEF ) then begin
        if (FIND_MATCHING_MOD ( lref, Fr, Qr  )) then begin
          nn:=nn+1;
          STR(la,s_a);
          STR(lb,s_b);
          STR(nn,s_c);
          lb:=nn;     { this will be internal node }
          Rp:=(2*pi*Fr)*lv/Qr;
          Cp:=1/(lv*(2*pi*Fr)*(2*pi*Fr));
          STR(Rp,sm_val);
          s_mod:=CONCAT('R.'+lname+'    '+s_c+' '+s_b+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
          STR(Cp,sm_val);
          s_mod:=CONCAT('C.'+lname+'    '+s_a+' '+s_b+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
        end
        else begin
          line:=line_pt^.oneline;
          NO_MOD_ERROR;
        end;
      end;
    end;
    l_ptr:=l_ptr^.lnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do begin
    with c_ptr^ do begin
      if ( cvar = MODEL_DEF ) then begin
        if (FIND_MATCHING_MOD ( cref, Fr, Qr  )) then begin
          STR(ca,s_a);
          STR(cb,s_b);
          STR(nn+1,s_c);
          STR(nn+2,s_d);
          cb:=nn+1;
          nn:=nn+2; { those will be internal nodes }
          Lp:=1/(cv*(2*pi*Fr)*(2*pi*Fr));
          Rp:=(2*pi*Fr)*Lp/Qr;
          STR(Rp,sm_val);
          s_mod:=CONCAT('R.'+cname+'    '+s_c+' '+s_d+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
          STR(Lp,sm_val);
          s_mod:=CONCAT('L.'+cname+'    '+s_d+' '+s_b+'    '+sm_val);
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
        end
        else begin
          line:=line_pt^.oneline;
          NO_MOD_ERROR;
        end;
      end;
    end;
    c_ptr:=c_ptr^.cnext;
  end;

 END;

{****************************************************************************}
{ H that gives voltage equal to 1[Ohm] * current to the inductor             }

PROCEDURE  CREATE_HIL(l_ptr:lptr);
VAR
 s_a,s_b,s_c:string;
 s_mod:string;
BEGIN
  with l_ptr^ do begin
     STR(la,s_a);
     STR(nn+1,s_b); {node la is now for out of H control current}
     STR(nn+2,s_c);
     la:=nn+1;
     nn:=nn+2;
     lc:=nn;   {node lc is set - indicates the voltage = 1.0 * control current}
     s_mod:=CONCAT('HIL.'+lname+'    '+s_c+'  0  '+s_a+'  '+s_b+'  1.0');
     CLEAR_LINE;
     INSERT(s_mod,line,1);
     ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);
  end;

END;

{****************************************************************************}
PROCEDURE MODEL_K_COUPLING;
VAR
  k_ptr:kptr;
  l_ptr,L1_ptr,L2_ptr:lptr;
  s_a,s_b,s_c:string;
  s_mod, sm_val:string;
  gk:double;

BEGIN

  k_ptr:=K_head;
  while k_ptr<>NIL do begin
    L1_ptr:=nil;
    L2_ptr:=nil;
    l_ptr:=L_head;
    while ( l_ptr<>NIL ) do begin
      if ( l_ptr^.lname=k_ptr^.k_lname1 ) then begin
        L1_ptr:=l_ptr;
        Break;
      end;
      l_ptr:=l_ptr^.lnext;
    end;
    l_ptr:=L_head;
    while ( l_ptr<>NIL ) do begin
      if ( l_ptr^.lname=k_ptr^.k_lname2 ) then begin
        L2_ptr:=l_ptr;
        Break;
      end;
      l_ptr:=l_ptr^.lnext;
    end;
    if ( (L1_ptr<>NIL) and (L2_ptr<>NIL)) then begin
      if ( L1_ptr^.lc = 0 ) then begin
        CREATE_HIL(L1_ptr);
      end;
      if ( L2_ptr^.lc = 0 ) then begin
        CREATE_HIL(L2_ptr);
      end;
     STR(L1_ptr^.la,s_a);
     STR(L1_ptr^.lb,s_b); {node la is now for out of H control current}
     STR(L2_ptr^.lc,s_c);
     gk:=(k_ptr^.kv)*sqrt(L2_ptr^.lv/L1_ptr^.lv);
     STR(gk,sm_val);
     s_mod:=CONCAT('GK.'+L1_ptr^.lname+'|'+L2_ptr^.lname+'    '+s_b+' '+s_a+'  '+s_c+' 0 '+ sm_val);
     CLEAR_LINE;
     INSERT(s_mod,line,1);
     ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);

     STR(L2_ptr^.la,s_a);
     STR(L2_ptr^.lb,s_b); {node la is now for out of H control current}
     STR(L1_ptr^.lc,s_c);
     gk:=(k_ptr^.kv)*sqrt(L1_ptr^.lv/L2_ptr^.lv);
     STR(gk,sm_val);
     s_mod:=CONCAT('GK.'+L2_ptr^.lname+'|'+L1_ptr^.lname+'    '+s_b+' '+s_a+'  '+s_c+' 0 '+ sm_val);
     CLEAR_LINE;
     INSERT(s_mod,line,1);
     ADD_TO_LISTA(EXTENDED_COMP_PT, EXTENDED_COMP_TAIL_PT);

    end
    else begin
      line:= k_ptr^.line_pt^.oneline;
      NO_L_FOR_K_ERROR;
    end;
    k_ptr:=k_ptr^.knext;
  end;

END;


{****************************************************************************}
PROCEDURE MODEL_EFHN;
VAR
 e_ptr:eptr;
 f_ptr:fptr;
 h_ptr:hptr;
 n_ptr:nptr;
 s_a,s_b,s_c,s_d,s_n1,s_n2,s_n3:string;
 s_mod,sm_val,si_val:string;

BEGIN



  e_ptr:=E_head;
  while e_ptr<>NIL do begin
    with e_ptr^ do begin
      STR(ea,s_a);
      STR(eb,s_b);
      STR(ec,s_c);
      STR(ed,s_d);
      STR(nn+1,s_n1);
      STR(ev*gx_MOD_val,sm_val);
      STR(gx_MOD_val,si_val);
      {ge  n1 eb ec ed   10.0m}
      s_mod:=CONCAT(gE_MOD_str+'.'+ename+'    '+s_n1+' '+s_b+' '+s_c+' '+s_d+'    '+sm_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      { gi  ea  n1 ea  n1   1.0m }
      s_mod:=CONCAT(gi_MOD_str+'.'+ename+'    '+s_a+' '+s_n1+' '+s_a+' '+s_n1+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      { Ae  ea eb eb  n1 }
      s_mod:=CONCAT('A.'+ename+'    '+s_a+' '+s_b+' '+s_b+' '+s_n1);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
    end;
    nn:=nn+1;
    e_ptr:=e_ptr^.enext;
  end;

  f_ptr:=F_head;
  while f_ptr<>NIL do begin
    with f_ptr^ do begin
      STR(fa,s_a);
      STR(fb,s_b);
      STR(fc,s_c);
      STR(fd,s_d);
      STR(nn+1,s_n1);
      STR(fv*gx_MOD_val,sm_val);
      STR(gx_MOD_val,si_val);
      {gf  fb  fa   n1  fd   10.0m}
      s_mod:=CONCAT(gF_MOD_str+'.'+fname+'    '+s_b+' '+s_a+' '+s_n1+' '+s_d+'    '+sm_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gi   n1  fc   1  fc   1.0m}
      s_mod:=CONCAT(gi_MOD_str+'.'+fname+'    '+s_n1+' '+s_c+' '+s_n1+' '+s_c+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {Af   n1  fd  fd  fc}
      s_mod:=CONCAT('A.'+fname+'    '+s_n1+' '+s_d+' '+s_d+' '+s_c);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
    end;
    nn:=nn+1;
    f_ptr:=f_ptr^.fnext;
  end;

  h_ptr:=H_head;
  while h_ptr<>NIL do begin
    with h_ptr^ do begin
      STR(ha,s_a);
      STR(hb,s_b);
      STR(hc,s_c);
      STR(hd,s_d);
      STR(nn+1,s_n1);
      STR(nn+2,s_n2);
      STR(hv,sm_val);
      STR(gx_MOD_val,si_val);
      {RH  hc  n1        1k}
      s_mod:=CONCAT('R.'+hname+'    '+s_c+' '+s_n1+'                '+sm_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gi1  n2 hb hd  n1  1.0m}
      s_mod:=CONCAT(gi_MOD_str+'1.'+hname+'    '+s_n2+' '+s_b+' '+s_d+' '+s_n1+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gi2 ha  n2 ha  n2  1.0m}
      s_mod:=CONCAT(gi_MOD_str+'2.'+hname+'    '+s_a+' '+s_n2+' '+s_a+' '+s_n2+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {Ah1  n1 hd hd hc}
      s_mod:=CONCAT('A1.'+hname+'    '+s_n1+' '+s_d+' '+s_d+' '+s_c);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {Ah2 ha hb hb  n2}
      s_mod:=CONCAT('A2.'+hname+'    '+s_a+' '+s_b+' '+s_b+' '+s_n2);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
    end;
    nn:=nn+2;
    h_ptr:=h_ptr^.hnext
  end;

  n_ptr:=N_head;
  while n_ptr<>NIL do begin
    with n_ptr^ do begin
      STR(na,s_a);
      STR(nb,s_b);
      STR(nc,s_c);
      STR(nd,s_d);
      STR(nn+1,s_n1);
      STR(nn+2,s_n2);
      STR(nn+3,s_n3);
      STR(nv*gx_MOD_val,sm_val);
      STR(gx_MOD_val,si_val);
      {gn  nc nd  n3  n2  10.0m}
      s_mod:=CONCAT(gN_MOD_str+'1.'+nname+'    '+s_c+' '+s_d+' '+s_n3+' '+s_n2+'    '+sm_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gn  n1 nb nc nd  10.0m}
      s_mod:=CONCAT(gN_MOD_str+'2.'+nname+'    '+s_n1+' '+s_b+' '+s_c+' '+s_d+'    '+sm_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gi1  n2  n1  n2  n1  1.0m}
      s_mod:=CONCAT(gi_MOD_str+'1.'+nname+'    '+s_n2+' '+s_n1+' '+s_n2+' '+s_n1+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {gi2  n3 na  n3 na  1.0m}
      s_mod:=CONCAT(gi_MOD_str+'2.'+nname+'    '+s_n3+' '+s_a+' '+s_n3+' '+s_a+'    '+si_val);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {An1  n2 nb nb  n1 }
      s_mod:=CONCAT('A1.'+nname+'    '+s_n2+' '+s_b+' '+s_b+' '+s_n1);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {An2  n3  n2  n2 na}
      s_mod:=CONCAT('A2.'+nname+'    '+s_n3+' '+s_n2+' '+s_n2+' '+s_a);
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
    end;
    nn:=nn+3;
    n_ptr:=n_ptr^.nnext
  end;

END;


{****************************************************************************}
PROCEDURE MODEL_T;
VAR
 t_ptr:tptr;
 t_a,t_b,t_c:string;
 s_mod:string;

BEGIN

  t_ptr:=T_head;
  while t_ptr<>NIL do begin
    with t_ptr^ do begin
      STR(ta,t_a);
      STR(tb,t_b);
      STR(tc,t_c);
      {g11  ta tc ta tc VAR   }
      s_mod:=CONCAT(g_T_str+'11'+'.'+tname+'    '+t_a+' '+t_c+' '+t_a+' '+t_c+'    '+'VAR '+g_T_str+'diag.'+tname );
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {g22  tb tc tb tc VAR   }
      s_mod:=CONCAT(g_T_str+'22'+'.'+tname+'    '+t_b+' '+t_c+' '+t_b+' '+t_c+'    '+'VAR '+g_T_str+'diag.'+tname );
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {g12  ta tc tb tc VAR   }
      s_mod:=CONCAT(g_T_str+'12'+'.'+tname+'    '+t_a+' '+t_c+' '+t_b+' '+t_c+'    '+'VAR '+g_T_str+'adiag.'+tname );
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
      {g22  tb tc ta tc VAR   }
      s_mod:=CONCAT(g_T_str+'21'+'.'+tname+'    '+t_b+' '+t_c+' '+t_a+' '+t_c+'    '+'VAR '+g_T_str+'adiag.'+tname );
      CLEAR_LINE;
      INSERT(s_mod,line,1);
      ADD_TO_LISTA(EXPANDED_COMP_PT, EXPANDED_COMP_TAIL_PT);
    end;
    t_ptr:=t_ptr^.tnext;
  end;

END;

{****************************************************************************}

PROCEDURE MODEL_T_GVAR(job:taskpt);
VAR
 t_ptr:tptr;
 s_mod,s_reval,s_imval:string;
 f_ptr:listbpt;
 def_head_ptr,def_tail_ptr:listapt;
 omega,phi:double;
 gre,gim,Y0,TAU:double;
BEGIN
  t_ptr:=T_head;
  while t_ptr<>NIL do begin
    with t_ptr^ do begin
      f_ptr:=job^.FREQ_PT;
      if ( f_ptr<>NIL ) then begin

        def_head_ptr:=job^.CDEF_PT; { remeber old head }
        job^.CDEF_PT:=NIL;          { add from head    }
        def_tail_ptr:=job^.CDEF_PT;

        Y0:=1.0/(t_ptr^.t_zr);
        TAU:=t_ptr^.t_td;
        s_mod:=CONCAT('$VAR '+g_T_str+'diag.'+tname +' CLIST' ); {diagonal}
        CLEAR_LINE;
        INSERT(s_mod,line,1);
        ADD_TO_LISTA(job^.CDEF_PT, def_tail_ptr);
        while ( f_ptr<>NIL ) do begin
          omega:=2.0*Pi*f_ptr^.value;
          phi:=omega*(TAU); {val=Yo*(-j*ctg(phi))}
          if ( (sin(phi)>=0.0) and (sin(phi)< min_num_value) ) then begin
            gre:=0.0;
            gim:= -(Y0)*(cos(phi)/min_num_value);
          end
          else  if ( (sin(phi)<0.0) and (sin(phi)> -min_num_value) ) then begin
            gre:=0.0;
            gim:= (Y0)*(cos(phi)/min_num_value);
          end
          else begin
            gre:= 0.0;
            gim:= -(Y0)*(cos(phi)/sin(phi));
          end;
          STR(gre,s_reval);
          STR(gim,s_imval);
          s_mod:=CONCAT(s_reval + '  ' + s_imval );
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(job^.CDEF_PT, def_tail_ptr);
          f_ptr:=f_ptr^.vpt;
        end;

        f_ptr:=job^.FREQ_PT;
        s_mod:=CONCAT('$VAR '+g_T_str+'adiag.'+tname +' CLIST' );  {anti-diagonal}
        CLEAR_LINE;
        INSERT(s_mod,line,1);
        ADD_TO_LISTA(job^.CDEF_PT, def_tail_ptr);
        while ( f_ptr<>NIL ) do begin
          omega:=2.0*Pi*f_ptr^.value;
          phi:=omega*TAU; {val=Y0/sin(phi)}
          if ( (sin(phi)>=0.0) and (sin(phi)< min_num_value) ) then begin
            gre:= 0.0;
            gim:= (Y0/min_num_value);
          end
          else  if ( (sin(phi)<0.0) and (sin(phi)> -min_num_value) ) then begin
            gre:= 0.0;
            gim:= -(Y0/min_num_value);
          end
          else begin
            gre:= 0.0;
            gim:= (Y0/sin(phi));
          end;
          STR(gre,s_reval);
          STR(gim,s_imval);
          s_mod:=CONCAT(s_reval + '  ' + s_imval );
          CLEAR_LINE;
          INSERT(s_mod,line,1);
          ADD_TO_LISTA(job^.CDEF_PT, def_tail_ptr);
          f_ptr:=f_ptr^.vpt;
        end;
        def_tail_ptr^.lpt:= def_head_ptr; {link tail with old head }
      end;
    end;
    t_ptr:=t_ptr^.tnext;
  end;
END;



{****************************************************************************}

PROCEDURE ADD_EXPANDED_COMPONENTS;
 VAR
 lpointer:listapt;

 BEGIN
  lpointer:=EXPANDED_COMP_PT;
  WHILE lpointer<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=lpointer^.oneline;
   cpt1:=FND('A','z',1);
   DSV(lpointer);
   lpointer:=lpointer^.lpt
  END
 END;

{****************************************************************************}

PROCEDURE ADD_EXTENDED_COMPONENTS;
 VAR
 lpointer:listapt;

 BEGIN
  lpointer:=EXTENDED_COMP_PT;
  WHILE lpointer<>NIL DO
  BEGIN
   xx:=FALSE;
   line:=lpointer^.oneline;
   cpt1:=FND('A','z',1);
   DSV(lpointer);
   lpointer:=lpointer^.lpt
  END
 END;

{****************************************************************************}
PROCEDURE MODEL_COMPONENTS;

BEGIN
  EXTENDED_COMP_PT:=NIL;
  EXTENDED_COMP_TAIL_PT:=NIL;

  MODEL_RLC_PARASITICS; { MODIFY  RLC nodes add PARASITICS }
  MODEL_K_COUPLING;
  ADD_EXTENDED_COMPONENTS; { ADD HIL FROM HERE }

  EXPANDED_COMP_PT:=NIL;
  EXPANDED_COMP_TAIL_PT:=NIL;
  MODEL_EFHN;
  MODEL_T;
  ADD_EXPANDED_COMPONENTS;
END;

{****************************************************************************}
PROCEDURE INSERT_MODEL_VAR_LISTS(job:taskpt);
BEGIN
  MODEL_T_GVAR(job);
END;

{****************************************************************************}
{ MODIFY  RLC PARASITICS values                                              }
PROCEDURE UPDATE_RLC_PARASITICS (mod_name:string; Fr,Qr:double);
VAR
 r_ptr:rptr;
 l_ptr:lptr;
 c_ptr:cptr;
 Rp,Lp,Cp:double;
 s_mod:string;
 parasitic_found:boolean;

 BEGIN

  r_ptr:=R_head;
  while r_ptr<>NIL do begin
    with r_ptr^ do begin
      if ( rvar=MODEL_DEF ) then begin
        if ( rref=mod_name ) then begin

          Lp:=rv*Qr/(2*pi*Fr);
          Cp:=1/(Lp*(2*pi*Fr)*(2*pi*Fr));
          s_mod:=CONCAT('L.'+rname);
          l_ptr:=L_head;
          parasitic_found:=FALSE;
          while ( l_ptr<>NIL ) do begin
            with l_ptr^ do begin
              if ( lname=s_mod ) then begin
                lv:=Lp;
                parasitic_found:=TRUE;
              end;
            end;
            l_ptr:=l_ptr^.lnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Lp FOUND FOR ' + rname;
            INTERNAL_ERROR;
          end;

          s_mod:=CONCAT('C.'+rname);
          c_ptr:=C_head;
          parasitic_found:=FALSE;
          while ( c_ptr<>NIL ) do begin
            with c_ptr^ do begin
              if ( cname=s_mod ) then begin
                cv:=Cp;
                parasitic_found:=TRUE;
              end;
            end;
            c_ptr:=c_ptr^.cnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Cp FOUND FOR ' + rname;
            INTERNAL_ERROR;
          end;

        end;
      end;
    end;
    r_ptr:=r_ptr^.rnext;
  end;

  l_ptr:=L_head;
  while l_ptr<>NIL do begin
    with l_ptr^ do begin
      if ( lvar = MODEL_DEF ) then begin
        if ( lref=mod_name ) then begin

          Rp:=(2*pi*Fr)*lv/Qr;
          Cp:=1/(lv*(2*pi*Fr)*(2*pi*Fr));

          s_mod:=CONCAT('R.'+lname);
          r_ptr:=R_head;
          parasitic_found:=FALSE;
          while ( r_ptr<>NIL ) do begin
            with r_ptr^ do begin
              if ( rname=s_mod ) then begin
                rv:=Rp;
                parasitic_found:=TRUE;
              end;
            end;
            r_ptr:=r_ptr^.rnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Rp FOUND FOR ' + lname;
            INTERNAL_ERROR;
          end;

          s_mod:=CONCAT('C.'+lname);
          c_ptr:=C_head;
          parasitic_found:=FALSE;
          while ( c_ptr<>NIL ) do begin
            with c_ptr^ do begin
              if ( cname=s_mod ) then begin
                cv:=Cp;
                parasitic_found:=TRUE;
              end;
            end;
            c_ptr:=c_ptr^.cnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Cp FOUND FOR ' + lname;
            INTERNAL_ERROR;
          end;

        end;
      end;
    end;
    l_ptr:=l_ptr^.lnext;
  end;

  c_ptr:=C_head;
  while c_ptr<>NIL do begin
    with c_ptr^ do begin
      if ( cvar = MODEL_DEF ) then begin
        if ( cref=mod_name ) then begin
          Lp:=1/(cv*(2*pi*Fr)*(2*pi*Fr));
          Rp:=(2*pi*Fr)*Lp/Qr;

          s_mod:=CONCAT('R.'+cname);
          r_ptr:=R_head;
          parasitic_found:=FALSE;
          while ( r_ptr<>NIL ) do begin
            with r_ptr^ do begin
              if ( rname=s_mod ) then begin
                rv:=Rp;
                parasitic_found:=TRUE;
              end;
            end;
            r_ptr:=r_ptr^.rnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Rp FOUND FOR ' + cname;
            INTERNAL_ERROR;
          end;

          s_mod:=CONCAT('L.'+cname);
          l_ptr:=L_head;
          parasitic_found:=FALSE;
          while ( l_ptr<>NIL ) do begin
            with l_ptr^ do begin
              if ( lname=s_mod ) then begin
                lv:=Lp;
                parasitic_found:=TRUE;
              end;
            end;
            l_ptr:=l_ptr^.lnext;
          end;
          if ( not parasitic_found ) then begin
            line:=line + 'NO Lp FOUND FOR ' + cname;
            INTERNAL_ERROR;
          end;

        end;
      end;
    end;
    c_ptr:=c_ptr^.cnext;
  end;

 END;



{****************************************************************************}
PROCEDURE UPDATE_MOD_COMPONENTS(job:taskpt);
VAR
 mod_pt:listapt;
 CheckLine: string;
 F,Q:double;
 mod_name:string;

BEGIN
  mod_pt:=job^.CDEF_PT;
  while mod_pt<>NIL do begin
    line:=mod_pt^.oneline;
    CheckLine:=UpperCase(line);
    if ( Pos('$MOD',CheckLine)<>0 ) then begin
      if ( Pos('FQ',CheckLine)<>0 ) then begin

          xx:=FALSE;
          cpt1:=FND('$','$',1);
          cpt2:=FND(' ',' ',cpt1);
          cpt1:=FND('A','z',cpt2);
          cpt2:= FND(' ',' ',cpt1);
          cpt1:=FND('A','z',cpt2);
          cpt2:= FND(' ',' ',cpt1);
          TXT(cpt1,cpt2-1);
          mod_name:=nsymb;
          xx:=FALSE;
          RRL;F:=rr;
          RRL;Q:=rr;
          if ((F=0.0) or (Q=0.0) or  xx ) then begin
            MOD_ERROR;
          end
          else begin
            UPDATE_RLC_PARASITICS(mod_name,F,Q);
          end;
      end;
    end;
    mod_pt:=mod_pt^.lpt;
  end;
END;

end.
