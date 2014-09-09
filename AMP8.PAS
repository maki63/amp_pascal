{***************************************************************************
 AMP8 - AMP and EXEC_TRACE
 AMP is top level sequencer routine
 EXEC_TRACE - gives extra debug output

 @version - 8.B
 short loop for $PAR update parameters in a task 
 ***************************************************************************}

{$DEFINE notDebug}

UNIT AMP8;

interface
USES
 SysUtils,
 TYPE8,VAR8,DATAIO8,LIB8,ELEMENT8,TASK8,COMM8,
 VAREXT8, Probes8, YMAT8, Model8, RAW8;

VAR
 job:taskpt;
 yr,mt,dy,wd:word;
 hr,mi,sc,sh:word;

PROCEDURE AMP;

implementation
USES Amp8_main;

{***************************************************************************
 EXEC_TRACE - gives extra debug output

 @param job:taskpt - pointer to currently executed task
 @version - 8.A
 ***************************************************************************}

  PROCEDURE EXEC_TRACE(job:taskpt);
  BEGIN
    if job=TASK_PT then begin
         if (LIB_FILES_PT<>NIL) then TRACE_LIB;
         if ( EXTENDED_COMP_PT <> NIL ) then LIST_EXTENDED_COMP;
         if ( EXPANDED_COMP_PT <> NIL ) then LIST_EXPANDED_COMP;
         if ( MAT_COMP_PT <> NIL ) then LIST_MAT_COMP;
         if ( MAT_PT <> NIL) then LIST_MATRIX;
    end;
    TRACE_TASK(job);
    WRITELN(RESULTS,asterix,version,asterix);
    WRITELN(RESULTS,'TASK:',job^.numberMajor,'.',job^.numberMiddle,'.',job^.numberMinor);
    WRITELN(RESULTS,'COMMANDS:');
    LIST_LISTA(job^.COMD_PT);
    WRITELN(RESULTS,'DECLARATIONS:');
    LIST_LISTA(job^.CDEF_PT);
  END;


{***************************************************************************
 AMP is top level sequencer routine

 @version - 8.A
 ***************************************************************************}

PROCEDURE AMP;
VAR
  param_updated:boolean;
BEGIN

 RESETPRG;
 READ_BATCH;
 IN_CLOSE;

 INCLUDE_INC_FILES;

 EXTRACT_JOB_NAME;

 EXTRACT_COMPONENTS;

 EXTRACT_LIB_FILES;
 EXTRACT_LIB_CALLS;
 CREATE_LIB_DEF;
 SET_UP_LIB_DEF;
 PREPARE_LIB_CALLS;

 ADD_COMPONENTS;

 FNN;
 MACRO_NODES;

 SET_UP_LIB_CALLS;
 EXTRACT_LIB_COMP;
 ADD_LIB_COMPONENTS;

 EXTRACT_TASKS;

 MODEL_COMPONENTS;   { MOD RLC + K EFHN + T }

 if ( P_head<> NIL ) then begin
    probes_flag:=TRUE;
    CREATE_PROBES_TF;         { create $TF for probes in PROBES_TF_PT list }
    CREATE_PROBES_TF_TASKS;   { one task per one $TF from PROBES_TF_PT list }
 end;

 if ( B_head<> NIL ) then begin
    PROCESS_B_COMP;
    PROCESS_MAT_FILES;        ///  convert S into Y
 end;

 CHECK_TOPOLOGY;

 LIST_BATCH;

 WRITELN(RESULTS,asterix,version,asterix);
 WRITELN(RESULTS,'DATE:'+DateToStr(Date));
 WRITELN(RESULTS,'TIME:'+TimeToStr(Time));

 job:=TASK_PT;
 while job<>NIL do begin

      RESET_SWITCHES;
      SET_SWITCHES(job);
      DEFINE_FREQ(job);                 // if $fFREQ present - define F for models
      if ( job^.FREQ_PT=NIL ) then begin
         job^.FREQ_PT:=MAT_COMM_FREQ_PT;     // if not take MAT Freq
      end;
      if (job^.FREQ_PT=NIL) then NO_FREQ_ERROR;

      if ( MAT_PT<>NIL ) then begin
          INTERPOLATE_MAT(job);           // intorpolate Y
          CREATE_MAT_VAR_LISTS(job);      // for each MAT element create $VAR CLIST to be linked with B related G VAR
          INSERT_MAT_VAR_LISTS(job);      // incorporate $VAR, $FREQ lists from $MAT into task CDEF_PT
      end;

     {$IFDEF Debug}
        LIST_DEBUG_INFO('MATRIX DATA INTERPOLATED');
        LIST_MATRIX;
     {$ENDIF}

      if ( T_head<>NIL ) then begin
          INSERT_MODEL_VAR_LISTS(job);    // incorporate $VAR lists from T into task CDEF_PT }
      end;
      SET_VARIABLE_COMP(job);           // set up VAR and TUNE lists
      if ( job<>TASK_PT ) then begin
          UPDATE_MOD_COMPONENTS(job);     // this is perhaps not effective but i can't see other way
      end;

      SET_TASK(job);
      SET_PAR_COMP(job);                 // set PAR_PT list and PAR components
      APPLY_LET_LIST(job);
      if trace then EXEC_TRACE(job);
      repeat
          CLEAR_RESULTS(job);
          DO_IT(job);
          FINISH_IT(job);
          param_updated:=UPDATE_PAR_COMP(job);            { update parameters list and PAR components }
      until (not param_updated );

    job:=job^.tpt;
  end;

  if raw then WRITE_RAW_FILES;                      { all_files_in_one_shot }
  WRITELN(RESULTS);

  WRITELN(RESULTS,'TIME:'+TimeToStr(Time));
  WRITELN(RESULTS,asterix,version,asterix);
 OUT_CLOSE;
END;

END.
