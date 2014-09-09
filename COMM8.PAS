UNIT COMM8;
interface
USES
 SysUtils,
 TYPE8,VAR8,LINE8,DATAIO8,
 COMP8,OUTPUT8,VAREXT8,EXTEND8, MCAD8, RAW8;

PROCEDURE RESETPRG;
PROCEDURE RESET_SWITCHES;
PROCEDURE SET_SWITCHES(job:taskpt);
PROCEDURE SET_TASK(job:taskpt);
PROCEDURE CLEAR_RESULTS(job:taskpt);
PROCEDURE DO_IT(job:taskpt);
PROCEDURE FINISH_IT(job:taskpt);
implementation
USES Amp8_main;

{***************************************************************************}

PROCEDURE RESETPRG;
BEGIN

 xx:=FALSE;
 Y_head:=NIL;Y_tail:=NIL;Y_temp:=NIL;
 R_head:=NIL;R_tail:=NIL;R_temp:=NIL;
 Z_head:=NIL;Z_tail:=NIL;Z_temp:=NIL;
 G_head:=NIL;G_tail:=NIL;G_temp:=NIL;
 C_head:=NIL;C_tail:=NIL;C_temp:=NIL;
 L_head:=NIL;L_tail:=NIL;L_temp:=NIL;
 A_head:=NIL;A_tail:=NIL;

 V_head:=NIL;V_tail:=NIL;V_temp:=NIL;
 I_head:=NIL;I_tail:=NIL;I_temp:=NIL;
 P_head:=NIL;P_tail:=NIL;P_temp:=NIL;

 E_head:=NIL;E_tail:=NIL;E_temp:=NIL;
 H_head:=NIL;H_tail:=NIL;H_temp:=NIL;
 F_head:=NIL;F_tail:=NIL;F_temp:=NIL;
 N_head:=NIL;N_tail:=NIL;N_temp:=NIL;

 B_head:=NIL;B_tail:=NIL;B_temp:=NIL;
 T_head:=NIL;T_tail:=NIL;T_temp:=NIL;

 D_head:=NIL;D_tail:=NIL;D_temp:=NIL;

 BATCH_PT:=NIL;
 COMP_PT:=NIL;
 LIB_PT:=NIL;
 LIB_FILES_PT:=NIL;
 LIB_CALLS_PT:=NIL;
 LIB_COMP_PT:=NIL;
 TASK_PT:=NIL;
 EXTRA_JOB_PT:=NIL;
 TFmp_PT:=NIL;
 YxYn_PT:=NIL;
 gen_sens:=FALSE; {* this flag can not be touched  by RESET_SWITCHES *}
    trace:=FALSE; {* this flag can not be touched  by RESET_SWITCHES *}
 disto_pass:=0;   {* disto analysis passes counter                   *}
 sensor:=FALSE;   {* this flag can not be touched by RESET_SWITCHES  *}
 probes_flag:=FALSE;
 PROBES_TF_PT:=NIL;
 EXPANDED_COMP_PT:=NIL;

 MAT_PT:=NIL;
 MAT_COMM_FREQ_PT:=NIL;
 format_dB_flag:=FALSE;
 format_MP_flag:=TRUE;          { default }
 format_RI_flag:=TRUE;          { default }

 
 RAW_LIST_PT:=nil; {* this flag can not be touched  by RESET_SWITCHES *}
 RAW_FILE_PT:=nil;
 raw:=FALSE;
 
 mcad:=FALSE;
 mcaddirfile:=FALSE; {* true when *.m0 is created *}
 mvaldirfile:=FALSE; {* true when *.mv0 is created *}
 mcad_values_flag:=FALSE; {* set by $MCAD VAL command to enable component values listing in *mvXX files *}

 mcadfilenum:=1;
 mvalfilenum:=1;
 mcad_numberMajor:=0;
 mcad_numberMiddle:=0;
 
END;

{***************************************************************************}

PROCEDURE RESET_SWITCHES;
BEGIN
 sens:=FALSE;
 transfer:=FALSE;
 generator:=FALSE;
 disto:=FALSE; 
END;

{***************************************************************************}

 PROCEDURE SET_SWITCHES(job:taskpt);
 VAR
  pointer:listapt;
  c:char;
  CheckLine:string;
 BEGIN
  pointer:=job^.COMD_PT;
  WHILE pointer<>NIL DO
  BEGIN
   line:=pointer^.oneline;
   xx:=FALSE;
   cpt1:=FND('!','z',1);
   cpt2:=cpt1;
   c:=line[cpt1+1];
   CASE c OF
    'm','M':  begin
              c:=line[cpt1+2];
              case c of
              'c','C':
                mcad:=TRUE;                 {* $MCAD   *}   
              end;
              CheckLine:=UpperCase(line);   {* $MCAD VAL  *}
              mcad_values_flag:=FALSE;              
              if ( Pos('VAL',CheckLine)<>0 )  then  mcad_values_flag:=TRUE;               
              end;                          
    'r','R': begin
              c:=line[cpt1+2];
              case c of
              'a','A':
                raw:=TRUE;                    {* $RAW    *}
              end
             end;
    'g','G':BEGIN
             generator:=TRUE;                {* $GR $GS *}
             c:=line[cpt1+2];
             CASE c OF
             'r','R':sensor:=FALSE;
             's','S':sensor:=TRUE
             END
            END;
    't','T':BEGIN                            {* $TRACE OR  $TF  *}
             c:=line[cpt1+2];
             CASE c OF
             'r','R':trace:=TRUE;
             'f','F':transfer:=TRUE
             END
            END;
    's','S':sens:=TRUE;                      {* $SENS   *}
    'h','H':disto:=TRUE;                     {* $HARM   *}
    'f','F':begin
              CheckLine:=UpperCase(line);        {* $FORMAT dB MP RI  *}
              format_dB_flag:=FALSE;
              format_MP_flag:=FALSE;
              format_RI_flag:=FALSE;
              if ( Pos('DB',CheckLine)<>0 )  then  format_dB_flag:=TRUE;
              if ( Pos('MP',CheckLine)<>0 )  then  format_MP_flag:=TRUE;
              if ( Pos('RI',CheckLine)<>0 )  then  format_RI_flag:=TRUE;
              if ( not (format_RI_flag or format_dB_flag or format_MP_flag )) then begin
                FORMAT_ERROR;
              end;
            end;
   END;
   pointer:=pointer^.lpt
  END
 END;

{***************************************************************************}

PROCEDURE SET_TASK(job:taskpt);
BEGIN
 IF transfer THEN
 BEGIN
  TF(job);
  IF sens THEN TF_SENS(job)
 END
 ELSE
 BEGIN
  IF generator THEN
  BEGIN
   IF NOT (sensor) THEN RCONV(job)
   ELSE SCONV(job)
  END
 END;
END;

{***************************************************************************}

PROCEDURE CLEAR_RESULTS(job:taskpt);
VAR
 d_ptr:dptr;
BEGIN

    d_ptr:=job^.COFF_PT;
    while d_ptr<>NIL do
    begin
        d_ptr^.CF_PT :=nil; 
        d_ptr:=d_ptr^.dnext
    end; 
END;


{***************************************************************************}

PROCEDURE DO_IT(job:taskpt);
BEGIN
 IF transfer THEN
 BEGIN
  IF (job^.VAR_PT=NIL) AND (job^.TUN_PT=NIL) THEN
   EVALCOFVARF(job)
  ELSE
   EVALCOFVARC(job)
 END
 ELSE
 BEGIN
  IF generator THEN
  BEGIN
   IF NOT(sensor) THEN
    EVALCOFVARC(job);
   IF sensor THEN
    EVALNEWTON(job)
  END
  ELSE
  BEGIN
   IF (job^.VAR_PT=NIL)AND(job^.TRIM_PT=NIL) THEN
    EVALCOFVARF(job)
   ELSE
    EVALCOFVARC(job)
  END
 END;

END;

{***************************************************************************}

PROCEDURE FINISH_IT(job:taskpt);
VAR

 standard:BOOLEAN;

BEGIN

 standard:=TRUE;
{*                  list coffactors if trace                              *}
 IF (trace)AND (NOT (generator AND sensor)) THEN
 BEGIN
  OUT_FLUSH;
  WRITE_RESULTS(job);
  OUT_FLUSH;
  standard:=FALSE
 END;


{* disto defines three sub tasks each is actually of transfer type        *}
 IF transfer THEN
 BEGIN
  IF disto_pass=0 THEN
  BEGIN
    OUT_FLUSH;
    WRITE_TF(job);
    OUT_FLUSH;
    IF (mcad)AND(TFmp_PT<>NIL)AND(NOT gen_sens) THEN MCAD_TF(job);
    IF (raw)AND(TFmp_PT<>NIL)AND(NOT gen_sens) THEN RAW_TF(job);

    IF sens THEN BEGIN
      OUT_FLUSH;
      IF NOT gen_sens THEN BEGIN
        WRITE_TF_SENS(job);
        IF (mcad) THEN MCAD_TF_SENS(job);
        IF (raw)  THEN RAW_TF_SENS(job);
      END;
      IF gen_sens THEN BEGIN
        IF NOT sensor THEN  BEGIN
          WRITE_RCONV_SENS(job);
          IF mcad THEN MCAD_RCONV_SENS(job)
        END
        ELSE BEGIN
          WRITE_SCONV_SENS(job);
          IF mcad THEN MCAD_SCONV_SENS(job)
        END;
        OUT_FLUSH;
        gen_sens:=FALSE
      END
    END
  END
  ELSE BEGIN
   IF NOT sensor THEN WRITE_RCONV_DISTO(job)
   ELSE WRITE_SCONV_DISTO(job)
  END;
  standard:=FALSE
 END;

 IF generator THEN BEGIN
    IF (NOT sensor) THEN BEGIN
      OUT_FLUSH;
      SOLVE_YXYN(job);
      WRITE_RCONV(job);
      OUT_FLUSH;
      IF (mcad)AND(YxYn_PT<>NIL) THEN MCAD_RCONV(job);
      {* order sens , disto is important why ?                                  *}
      IF sens THEN RCONV_SENS_START(job);
      IF disto THEN BEGIN
        RCONV_DISTO_START(job);
        disto_pass:=3
      END;
      standard:=FALSE
    END;

    IF sensor THEN BEGIN
      OUT_FLUSH;
      WRITE_SCONV(job);
      OUT_FLUSH;
      IF (mcad)AND(eYn_PT<>NIL) THEN MCAD_SCONV(job);
      OUT_FLUSH;
      IF sens THEN SCONV_SENS_START(job);
      IF disto THEN BEGIN
        SCONV_DISTO_START(job);
        disto_pass:=3
      END;
      standard:=FALSE
    END

 END;

{* Print out D for standard flag *}
 
 IF standard THEN BEGIN
  OUT_FLUSH;
  WRITE_RESULTS(job);
  OUT_FLUSH;  
 END;
 
{* Mcad out D for standard - but trace might have clear it above *}
 IF (mcad) AND (not transfer) AND (not generator)  THEN MCAD_D(job);
 IF (raw)  AND (not transfer) AND (not generator)  THEN RAW_D(job);
 
 {* Mcad values update for change in  *}
 if (mcad_values_flag) AND 
    ((mcad_numberMajor <> job^.numberMajor ) OR (mcad_numberMiddle <> job^.numberMiddle )) 
    then  MCAD_VAL(job); 
 
END;


{***************************************************************************}

END.

