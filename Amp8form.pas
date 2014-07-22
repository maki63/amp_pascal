unit Amp8form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

  PROCEDURE ERROR(errnum,doserr:INTEGER);
  PROCEDURE INFO(i:STRING);
  PROCEDURE STATUS(s:STRING);
  PROCEDURE DATA_ERROR;
  PROCEDURE PARA_ERROR;
  PROCEDURE VAR_ERROR;
  PROCEDURE VAR_TYPE_ERROR;
  PROCEDURE PROBE_TYPE_ERROR;
  PROCEDURE TUN_ERROR;
  PROCEDURE GEN_ERROR;
  PROCEDURE GEN_PARA_ERROR;
  PROCEDURE NO_MAT_ERROR;
  PROCEDURE NO_B_ERROR;
  PROCEDURE UNKNOWN_MAT_ERROR;
  PROCEDURE MAT_SIZE_ERROR;
  PROCEDURE MAT_FREQ_ERROR;
  PROCEDURE MAT_MATCH_ERROR;
  PROCEDURE MAT_FREQ_LISTS_ERROR;
  PROCEDURE FORMAT_ERROR;
  PROCEDURE NO_MOD_ERROR;
  PROCEDURE NOT_VALID_FQ_ERROR;
  PROCEDURE NO_L_FOR_K_ERROR;
  PROCEDURE INVALID_NODE_ERROR;
  PROCEDURE INVALID_TOPOLOGY_ERROR;
  PROCEDURE INTERNAL_ERROR;
  PROCEDURE MOD_ERROR;
  PROCEDURE PAR_COUNT_ERROR;
  PROCEDURE NO_MATCHING_PAR_ERROR;
  PROCEDURE NO_FREQ_ERROR;
  PROCEDURE NO_S_OPTION_ERROR;
  PROCEDURE TOUCHSTONE_FORMAT_ERROR;
  PROCEDURE MATRIX_TOOLBOX_DIM_ERROR;
  PROCEDURE MATRIX_TOOLBOX_NIL_ERROR;
  PROCEDURE MATRIX_TOOLBOX_CANNOT_INVERT_ERROR;
  PROCEDURE MATRIX_TOOLBOX_CONVERSION_ERROR;
  PROCEDURE RAW_POINTS_ERROR;


implementation
USES Amp8_Main,TYPE8,VAR8,VAREXT8;
{***************************************************************************}

PROCEDURE INFO(i:STRING);
BEGIN
 Form1.Memo1.Lines.Add(i+#13);
END;

{***************************************************************************}
PROCEDURE STATUS(s:STRING);
BEGIN
 Form1.Memo2.Lines.Add(s+#13);
END;

PROCEDURE ERROR(errnum,doserr:INTEGER);
VAR

str:string;
BEGIN
     error_num:=errnum;
     CASE errnum OF
      1:str:='01:CONSOLE CAN NOT BE INPUT';
      2:str:='02:CANNOT OPEN DATA FILE';
      3:str:='03:ERROR IN DATA FILE';
      4:str:='04:CANNOT OPEN OUTPUT FILE';
      5:str:='05:CANNOT CLOSE DATA FILE';
      6:str:='06:CANNOT CLOSE OUTPUT FILE';
      7:str:='07:LIBRARY ERROR- DEFINITION  NOT FOUND';
      8:str:='08:LIBRARY ERROR- INVALID PARAMETER';
      9:str:='09:NO $END STATEMENT';
     10:str:='10:WRONG CONFIG';
     11:str:='11:NO MATCHING TRIM PARAMETER FOR TUNED ELEMENT';
     12:str:='12:NO MATCHING MODEL FOR VAR ELEMENT';
     13:str:='13:COMPLEX VAR NOT ALLOWED FOR RLC';
     14:str:='14:NO MATCHING MODEL FOR TUN ELEMENT';
     15:str:='15:NO MATCHING MODEL FOR GEN';
     16:str:='16:NO MATCHING TRIM PARAMETER FOR GEN';
     17:str:='17:PROBE TYPE UNKNOWN';
     18:str:='18:NO $MAT DEFINITION FOR B COMPONENTS';
     19:str:='19:NO B COMPONENTS FOR $MAT DEFINITION';
     20:str:='20:UNKNOWN $MAT TYPE';
     21:str:='21:$MAT SIZE ERROR';
     22:str:='22:$MAT AND $FREQ ARE NOT ALLOWED';
     23:str:='23:$MAT DOES NOT HAVE A MATCHING COMPONENT';
     24:str:='24:$MAT FREQ LISTS ARE NOT CONSISTENT';
     25:str:='25:$FORMAT - NOTHING RECOGNIZED';
     26:str:='26:NO MATCHING $MOD FOR COMPONENT IN ROOT TASK';
     27:str:='27:MOD FQ F=0.0 or Q=0.0 ';
     28:str:='28:NO MATCHING L FOR K';
     29:str:='29:INVALID NODE NUMBER';
     30:str:='30:NO CONECTION AT NODE';
     31:str:='31:INTERNAL ERROR :-(';
     32:str:='32:INVALID MOD';
     33:str:='33:UNEQUAL NUMBER OF PAR VALUES';
     34:str:='34:NO MATCHING PAR FOR COMPONENT';
     35:str:='35:EMPTY FREQ LIST';
     36:str:='36:NO_S_OPTION';
     37:str:='37:TOUCHSTONE_FORMAT_ERROR';
     38:str:='38:MATRIX_TOOLBOX_DIM_ERROR';
     39:str:='39:MATRIX_TOOLBOX_NIL_ERROR';
     40:str:='40:MATRIX_TOOLBOX_CANNOT_INVERT_ERROR';
     41:str:='41:MATRIX_TOOLBOX_CONVERSION_ERROR';
     42:str:='42:RAW_POINTS_ERROR';
    ELSE
       str:='STRANGE ERROR NUMBER'
    END;
        Form1.Memo1.Lines.Add(str+#13);
    Sleep(5000);
    Halt;
END;

{***************************************************************************}
PROCEDURE DATA_ERROR;
BEGIN
 STATUS(line);
 ERROR(3,0)
END;

{***************************************************************************}
PROCEDURE PARA_ERROR;
BEGIN
 STATUS(line);
 ERROR(11,0)
END;

{***************************************************************************}
PROCEDURE VAR_ERROR;
BEGIN
 STATUS(line);
 ERROR(12,0)
END;

{***************************************************************************}
PROCEDURE VAR_TYPE_ERROR;
BEGIN
 STATUS(line);
 ERROR(13,0)
END;

{***************************************************************************}
PROCEDURE TUN_ERROR;
BEGIN
 STATUS(line);
 ERROR(14,0)
END;

{***************************************************************************}
PROCEDURE GEN_ERROR;
BEGIN
 STATUS(line);
 ERROR(15,0)
END;

{***************************************************************************}
PROCEDURE GEN_PARA_ERROR;
BEGIN
 STATUS(line);
 ERROR(16,0)
END;

{***************************************************************************}
PROCEDURE PROBE_TYPE_ERROR;
BEGIN
 STATUS(line);
 ERROR(17,0)
END;

{***************************************************************************}
PROCEDURE NO_MAT_ERROR;
BEGIN
 STATUS(line);
 ERROR(18,0)
END;

{***************************************************************************}
PROCEDURE NO_B_ERROR;
BEGIN
 STATUS(line);
 ERROR(19,0)
END;

{***************************************************************************}
PROCEDURE UNKNOWN_MAT_ERROR;
BEGIN
 STATUS(line);
 ERROR(20,0)
END;

{***************************************************************************}
PROCEDURE MAT_SIZE_ERROR;
BEGIN
 STATUS(line);
 ERROR(21,0)
END;

{***************************************************************************}
PROCEDURE MAT_FREQ_ERROR;
BEGIN
 STATUS(line);
 ERROR(22,0)
END;

{***************************************************************************}
PROCEDURE MAT_MATCH_ERROR;
BEGIN
 STATUS(line);
 ERROR(23,0)
END;

{***************************************************************************}
PROCEDURE MAT_FREQ_LISTS_ERROR;
BEGIN
 STATUS(line);
 ERROR(24,0)
END;

{***************************************************************************}
PROCEDURE FORMAT_ERROR;
BEGIN
 STATUS(line);
 ERROR(25,0)
END;

{***************************************************************************}
PROCEDURE NO_MOD_ERROR;
BEGIN
 STATUS(line);
 ERROR(26,0)
END;

{***************************************************************************}
PROCEDURE NOT_VALID_FQ_ERROR;
BEGIN
 STATUS(line);
 ERROR(27,0)
END;

{***************************************************************************}
PROCEDURE NO_L_FOR_K_ERROR;
BEGIN
 STATUS(line);
 ERROR(28,0)
END;

{***************************************************************************}
PROCEDURE INVALID_NODE_ERROR;
BEGIN
 STATUS(line);
 ERROR(29,0)
END;

{***************************************************************************}
PROCEDURE INVALID_TOPOLOGY_ERROR;
BEGIN
 STATUS(line);
 ERROR(30,0)
END;

{***************************************************************************}
PROCEDURE INTERNAL_ERROR;
BEGIN
 STATUS(line);
 ERROR(31,0)
END;

{***************************************************************************}
PROCEDURE MOD_ERROR;
BEGIN
 STATUS(line);
 ERROR(32,0)
END;

{***************************************************************************}
PROCEDURE PAR_COUNT_ERROR;
BEGIN
 STATUS(line);
 ERROR(33,0)
END;

{***************************************************************************}
PROCEDURE NO_MATCHING_PAR_ERROR;
BEGIN
 STATUS(line);
 ERROR(34,0)
END;

{***************************************************************************}
PROCEDURE NO_FREQ_ERROR;
BEGIN
 ERROR(35,0)
END;

{***************************************************************************}
PROCEDURE NO_S_OPTION_ERROR;
BEGIN
 ERROR(36,0)
END;

{***************************************************************************}
PROCEDURE TOUCHSTONE_FORMAT_ERROR;
BEGIN
 ERROR(37,0)
END;

{***************************************************************************}
PROCEDURE MATRIX_TOOLBOX_DIM_ERROR;
BEGIN
 ERROR(38,0)
END;

{***************************************************************************}
PROCEDURE MATRIX_TOOLBOX_NIL_ERROR;
BEGIN
 ERROR(39,0)
END;

{***************************************************************************}
PROCEDURE MATRIX_TOOLBOX_CANNOT_INVERT_ERROR;
BEGIN
 ERROR(40,0)
END;

{***************************************************************************}
PROCEDURE MATRIX_TOOLBOX_CONVERSION_ERROR;
BEGIN
  ERROR(41,0)
END;

{***************************************************************************}
PROCEDURE RAW_POINTS_ERROR;
BEGIN
  ERROR(42,0)
END;



end.

