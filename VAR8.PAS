UNIT VAR8;
interface
USES TYPE8;

VAR
 A_head,A_tail:aptr;
 Y_head,Y_tail,Y_temp:yptr;
 R_head,R_tail,R_temp:rptr;
 C_head,C_tail,C_temp:cptr;
 L_head,L_tail,L_temp:lptr;
 G_head,G_tail,G_temp:gptr;
 Z_head,Z_tail,Z_temp:zptr;
 V_head,V_tail,V_temp:vptr;
 I_head,I_tail,I_temp:iptr;
 P_head,P_tail,P_temp:pptr;
 E_head,E_tail,E_temp:eptr;
 H_head,H_tail,H_temp:hptr;
 F_head,F_tail,F_temp:fptr;
 N_head,N_tail,N_temp:nptr;
 B_head,B_tail,B_temp:bptr;
 T_head,T_tail,T_temp:tptr;
 K_head,K_tail,K_temp:kptr;
 D_head,D_tail,D_temp:dptr;
 DATA,RESULTS,MCADF,M0CADF,LIBFILE,RAWF,VCADF,V0CADF:text;
 BATCH_PT:listpt;
 INC_HEAD_PT,INC_TAIL_PT:listpt;
 FILELINES_HEAD_PT:listapt;
 COMP_PT:listapt;
 LIB_FILES_PT:listapt;
 LIB_CALLS_PT:listapt;
 LIB_PT:libpt;
 LIB_COMP_PT, LIB_COMP_PT_TAIL:listapt;
 TASK_PT:taskpt;
 EXTRA_JOB_PT:taskpt;
 nsymb:symb;
 line,linebuff:linetype;
 rr:DOUBLE;
 nn:INTEGER;                                          {* number of nodes *}
 itg,cpt1,cpt2:INTEGER;
 xx:BOOLEAN;                                       {* cancel marker *}
 ch:CHAR;
 INPSTR,OUTSTR,GRFSTR,LIBSTR,MSTR,M0STR,INCSTR,FILELINESSTR,LIBPATHSTR,RAWSTR,SPICESTR,NUTMEGSTR,MCADEXESTR,MCADSCRIPTSTR,V0STR,VSTR:string[250];
 MCADDIRSTR, RAWDIRSTR:string[250];
 JOB_NAME:string;
 trace,mcad:BOOLEAN;
 {D_C:BOOLEAN;}                                       {* D_C direct_current  *}
 sens:BOOLEAN;
 
implementation

END.
