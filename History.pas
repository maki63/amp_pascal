unit History;

interface

implementation
{
   Amp8_D
	 22.12.2014
   build 8.13.26.1
   bug fix $MAT due to change in RRL, FND and READREAL

   Amp8_D
	 14.12.2014
   build 8.13.25.1
   bug fixes due to bug fix in RRL, FND and READREAL

   Amp8_D
	 12.12.2014
   build 8.13.24.1
   bug fix in RRL

   Amp8_D
	 11.12.2014
   build 8.13.23.1
   bug fix: $LIB with semicolons

   Amp8_D
	 08.12.2014
   build 8.13.22.1
   X with hierarchy

   Amp8_D
	 15.11.2014
   build 8.13.21.1
   bug fix: $LIB when in commands is not mistaken as $LET 

   Amp8_D
	 13.11.2014
   build 8.13.20.1
   semicolon as a command separator, yet $INC still have to be a single line command 

   Amp8_D
	 28.10.2014
   build 8.13.19.1
   Amp_calc is a thread

   Amp8_D
	 04.10.2014
   build 8.13.18.1
   MODEL_DRV removed
   MODEL_DEF, PARAM understood by CALC_Ysens_X

   Amp8_D
	 25.09.2014
   build 8.13.17.1
   $TN for task name

   build 8.13.16.1
   $LET for R,L,C causes model to update

   Amp8_D
	 10.09.2014
   build 8.13.15.1
   MCADDIR, RAWDIR  - in amp.ini to create separate folders for MCAD/ RAW ;
   SENS for TF are in separate files

   Amp8_D
	 10.09.2014
   build 8.13.14.1
   GUI  - in amp.ini to show/hide GUI ;

   Amp8_D
	 09.09.2014
   build 8.13.13.1
   TICK  - in amp.ini to configure timer in forms - default changed to 1ms;

   Amp8_D
	 06.09.2014
   build 8.13.12.1
   $LET  - to change component values ;

   Amp8_D
	 03.09.2014
   build 8.13.11.1
   $MCAD VAL - to generate *.mvXX files for each major or middle change ;


   Amp8_D
	 03.09.2014
   build 8.13.10.1
   $MCAD for D
   $RAW for D
   $MCAD, $RAW set by SET_SWITCHES - not reset by RESET_SWITCHES;

   Amp8_D
	 20.07.2014
   build 8.13.9.1
   $PAR when not present generates an ERROR

   build 8.13.8.1
   $MCAD can triger script execution
   $RAW doesn't look for a spice file as it might be a command in a PATH

   Amp8_D
	 17.07.2014
   build 8.13.7.1
   fix bug for results duplication for multiple $PAR runs 

   Amp8_D
	 14.07.2014
   build 8.13.6.1
   all task with matching Major.Middle.* should be stored in one file

   Amp8_D
	 12.07.2014
   build 8.13.5.1
   bug fix - correct number of variables in raw files for sens
   change name for $MAT components from GMAT[1,2] to GMAT12 to
   change name for T components from GT[1,2].T1 to GT12.T1 to
   comply with nutmeg parser

   Amp8_D
	 12.07.2014
   build 8.13.4.1
   TF_SENS in RAW files

   Amp8_D
	 10.07.2014
   build 8.13.3.1
   PAR values in RAW files description

	 09.07.2014
   build 8.13.2.4
   numberMajor:INTEGER;      ** assigned in EXTRACT_TASKS
   numberMiddle:INTEGER;     ** changed by SET_PAR_COMP and
   numberMinor:INTEGER;      ** assigned in CREATE_PROBES_TF_TASKS
   Changes in RAW_TF()
   Many warnings removed - some still remains
   
	 03.07.2014
   Major change AMP8 vB
   short update loop for update of $PAR
   build 8.13.1.6
	 try to return error code by setting in Amp8_main
   ExitCode := error_num;

	 03.07.2014
   build 8.13.1.5
	 Amp.exe input.in output.out

	 30.06.2014
   build 8.13.1.2
	 Fixing bug in
   * Lname la lb PAR lref *
   * Cname ca cb PAR cref *

   Amp8_C
	 14.07.2010
	 nmax=200


   Amp8_C
	 13.06.2010
	 Aligment of Delphi and FPC versions due to FPC CRISIS
   Possible bug in function str() gives gi=2mS or funny results for FPC, but only at ADB machine !!!
	 When for compilation all checking options are on - appllication aborts


   19.12.2009
   FPC+Lazarus - first build
   12.12.2009
   Consider the syntax of new TF names
   OUTPUT8 splited into OUTPUT8+MCAD8+RAW8

   07.11.2009
   Probes8.pas
   Names of TF changed to be compliant with NUTMEG
   i.e. KU[U1/V1] -> KU_U1_V1

}
{
   Amp8_B
   23.08.2009
   Change in
   CREATE_MAT_DEF; - double definitions of $MAT

   Change in GET_F2_MAT;

    GET_F1F2_MAT(head_ptr, f1_mat_ptr, f1_mat_ptr); /// this is to handle f1<f2<f
    changed into
    GET_F1F2_MAT(head_ptr, f1_mat_ptr, f2_mat_ptr); /// this is to handle f1<f2<f

    due to errors in interpolation !
    use of compliter directive to debug the code
}
{
   Amp8_B
   22.08.2009
   Change in RRL

   cpt2:=FND(CHR(13),' ',cpt1);
   changed into
   cpt2:=FND(CHR(09),' ',cpt1);
   r1s:=COPY(line,cpt1,(cpt2-cpt1));

}
{
  Amp8_B
  23.05.2009

  SnP - Touchstone for B elements

}

{
  Amp8_A
  13.04.2009
  Linear interpoation of MAT elements

 Touchstone S - *.s2p *.s3p *s4p is to be converted into Y – in version B
 Touchstone Y,Z  formats are to be supported later (?).
 Native B-format of file is:
 freq reY11 imY11 reY12 imY12 reY21 imY21 reY22 imY22
 If $FREQ is declared – parameters of Y are interpolated and $TF is calculated at frequency points as specified in $FREQ.
 If $FREQ is not defined – list is created which is a sum of all frequecny points declared in all included B-type files


}

{
  Amp8_9
  07.04.2009
  MAJOR CHANGE - TESTING - TESTING TESTING
  bug fix:
     line:AnsiString; so called LongString;
}

{
  Amp8_9
  15.08.2007
  bug fix:
      PROCEDURE MODEL_T_GVAR(job:taskpt);
      fixed broken link of tail with old head
      def_tail_ptr^.lpt:= def_head_ptr;
}
{
  Amp8_9
  13.08.2007
  bug fix:
      Probes - changes in code of ADD_J_EXCEPT_ONE
  functional_fix:
      Parameters are in m0 file

}
{
  08.07.2007
  Amp8_9
  No new features
  Bug removals
  Stabilization of the code
}
{ 12.06.2007
  Amp8_8

  *.m0 - directory file for MCAD
  B, T available in LIB

  R1 1 2 PAR parname

  $PAR parname LIST
  $PAR parname CLIST
  $PAR parname LIN
  $PAR parname LOG
  $PAR parname FILE
  $PAR parname CFILE

  Change in RRL


}
{04.06.2007
  Amp8_7

  R 1 2 10k   MOD  0603   for parasitics calculation
  L 1 2 100n  MOD  0805   for parasitics calculation
  C 1 2 10p   MOD  0402   for parasitics calculation

  $MOD FQ MOD0603 1G 30

  K12 L1 L2  1.0

  check_nodes

  lib_path in Amp.ini new approach to reading lib files

  BLIND UPDATE IN LIB8.PAS to support E,F,H,N

}
{
 26.05.2007
  Amp8_6

  T - type - lossless transmssion lines
  T1 ta tb tc Zo TD
  New probes  ratios
  PTU a b c d => U(a,b)/U(c,d)
  PTI a b c d => I(a,b)/I(c,d)
  PTN a b c d => I(a,b)/U(c,d)
  PTM a b c d => U(a,b)/I(c,d)
  $FOR - format <default MP RI>
  $FOR dB MP RI

  $MCAD format for TF is re im

  LOG start_value end_value (including specified)
  LOG start_value number_of_decades (>0) was not intuitive - natural

  A bridge to far
  in TASK8.PAS
  lptr (THIS is A TYPE FOR GOD SAKE) as global/local variable
  in PARSE_DEF governs all multilines reads
  this is very BADLLY interlaced so had to be replicated in
  DEFINE_FREQ - very sad piece of coding


 }


{
 19.05.2007
  Amp8_5

  B - type
  $MAT - declaration

  BName b1 b2 [b3 b4.....]  MatrixName
  $MAT MatrixType Matrixname MatrixFileName

  module -YMAT8

 }

{
 14.05.2007
  Amp8_4
  E,F,H,N - types

}

{
 14.04.2007
  Amp8_3

  V,I sources
  PU,PV,PI,PZ - probes

  TRIM replaces PARA
  PARA is to be a new type for characteristics family in future applications


}

{
 10.04.2007
  Amp8_2
  New fromat for macro-model
    Xa1 1 2 3 4 MYAMP
  4pins Amps properly parsed in library files

}

{
 26.03.2007
  Amp8_1
    Evolution
    Z - new type
    Z,Y,G, might be declared as complex
     Gname ga gb gc gd 1.0E-3
     Gname ga gb gc gd 1.0E-3 1.0E-4
     $FREQ, $VAR, $TUN, $PARA may have many lines

    $INC

     $VAR varname FILE
     $VAR varname CFILE

}
{
  26.01.2007
  Amp8_0
    Revolution

    New data format for new input format:
      there are no component definitions in VAR, TUN, GEN
      VAR, TUN only give values of the model

    Examples for R

    Rxxx ra rb VAR RV_model
    $VAR RV_model LIST ....

    Rxxx ra rb TUN RT_model
    $VAR RT_model LIST ....

    Rxxx ra rb GEN
    Ryyy ra rb GEN
    $GR Rxxx Ryyy

   - X for macromodels
   - $VAR
   - $TUN
   - $FREQ
   - $HARM for $DISTO

  AMP8 in 'AMP8.PAS',
  COMM8 in 'COMM8.PAS',
  COMP8 in 'COMP8.PAS',
  DATAIO8 in 'DATAIO8.PAS',
  ELEMENT8 in 'ELEMENT8.PAS',
  EXTEND8 in 'EXTEND8.PAS',
  LIB8 in 'LIB8.PAS',
  LINE8 in 'LINE8.PAS',
  MATRIX8 in 'MATRIX8.PAS',
  TASK8 in 'TASK8.PAS',
  TYPE8 in 'TYPE8.PAS',
  VAR8 in 'VAR8.PAS',
  VAREXT8 in 'VAREXT8.PAS',
  OUTPUT8 in 'OUTPUT8.PAS',
  History in 'History.pas';

}

{
 15.01.2007
 MODIFIED DATAIO7
 IF j^.CTRL_PT<>NIL THEN
  j^.CTRL_PT^.fqpt:=j^.CTRL_PT^.CT_PT;
}

{
  14.01.2007
  MODIFIED - COMP7
  IF job^.CTRL_PT<>NIL THEN
        job^.CTRL_PT^.fqpt:=job^.CTRL_PT^.CT_PT;
}

{
  13.01.2007 - Amp7_0

  Amp7form in 'Amp7form.pas',
  AMP7 in 'AMP7.PAS',
  COMM7 in 'COMM7.PAS',
  COMP7 in 'COMP7.PAS',
  DATAIO7 in 'DATAIO7.PAS',
  ELEMENT7 in 'ELEMENT7.PAS',
  EXTEND7 in 'EXTEND7.PAS',
  LIB7 in 'LIB7.PAS',
  LINE7 in 'LINE7.PAS',
  MATRIX7 in 'MATRIX7.PAS',
  TASK7 in 'TASK7.PAS',
  TYPE7 in 'TYPE7.PAS',
  VAR7 in 'VAR7.PAS',
  VAREXT7 in 'VAREXT7.PAS',
  OUTPUT7 in 'OUTPUT7.PAS',
  History in 'History.pas';

  Changes:
        nd->ddim
        nn->nsymb

        sens->tuned

        X,E,I removed

        A,G spec changed to be compatible with As
        old:
        A ii ni out
        new:
        Axxx out ni ii
        Axxx out+ out- ni ii
        old:
        Gxxx vp ip im vm
        new:
        Gxxx ip im vp vm

        MODIFIED - 14.01.2007
        COMP 7
              ->
                EVALCOFVARC
        original:
                job^.CTRL_PT^.fqpt:=job^.CTRL_PT^.CT_PT;
        modified
                IF job^.CTRL_PT<>NIL THEN
                        job^.CTRL_PT^.fqpt:=job^.CTRL_PT^.CT_PT;
        due to segment violation errors when CTRL_PT=nil

}
{
  01.01.2007
    Amp6 for DOS
}
end.
