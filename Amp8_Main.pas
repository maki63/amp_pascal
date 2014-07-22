unit Amp8_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,
  Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
      private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  error_num:integer=0;
  programstate:integer=1;
  trace:boolean=FALSE;
  SpiceProcess: TProcess;
  McadProcess: TProcess;

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
uses
AMP8,Amp8form,TYPE8,VAR8,VAREXT8;

const
default_input_ext='.in';
default_output_ext='.out';
default_nutmeg_ext='.nut';
default_mcad_ext='.sci';

err_file=1;
err_synt=2;
err_node=3;
err_topology=4;
err_config=5;
err_index=6;


var

  def_in_str:string=default_input_ext;
  def_out_str:string=default_output_ext;
  def_nut_str:string=default_nutmeg_ext;

  ext_in_str:string=default_input_ext;
  ext_out_str:string=default_output_ext;
  ext_nut_str:string=default_nutmeg_ext;
  ext_mcad_str:string=default_mcad_ext;

  CONFIG:TEXTFile;
{***************************************************************************}
{***************************************************************************}
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

{***************************************************************************}
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
    Sleep(10000);
    ExitCode := error_num;
    Halt(error_num);
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


{***************************************************************************}
Procedure ErrorReport;
begin
  Case error_num of
     err_file:
     begin
      Form1.Memo1.Lines.Add('FILE CAN NOT BE OPENED'+#13);
     end;
     err_synt:
     begin
      Form1.Memo1.Lines.Add('SYNTAX ERROR '+ #13);
     end;
     err_topology:
     begin
      Form1.Memo1.Lines.Add('TOPOLOGY ERROR '+ #13);
     end;
     err_config:
     begin
      Form1.Memo1.Lines.Add('CONFIG ERROR '+ #13);
     end;

    else
      Form1.Memo1.Lines.Add('STRANGE ERROR'+#13);
  end;

end;

{***************************************************************************}

procedure ReadConfig;
var
   line_len,count,p:integer;
   line_str,libpath_str,spicepath_str,mcadpath_str:string;
label next_line;
begin

     while (not EOF(CONFIG)) do
     begin
          Readln(CONFIG,line_str);
          line_len:=length(line_str);
          if(Pos('IN',line_str)<>0) then
          begin
               p:=pos('.',line_str);
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    if count>4 then count:=4;
                    ext_in_str:=Copy(line_str,p,count);
               end;
               goto next_line;
          end;

          if(Pos('OUT',line_str)<>0) then
          begin
               p:=pos('.',line_str);
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    if count>4 then count:=4;
                    ext_out_str:=Copy(line_str,p,count);
               end;
          goto next_line;
          end;

          if(Pos('LIBPATH',line_str)<>0) then
          begin
               p:=pos(CHR(39),line_str);  { CHR(39)=' }
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    libpath_str:=Trim(Copy(line_str,p,count));
                    LIBPATHSTR:=Copy(libpath_str,2,Length(libpath_str)-2); {remove ' ' from the path}
               end;
          goto next_line;
          end;

          if(Pos('SPICE',line_str)<>0) then
          begin
               p:=pos(CHR(39),line_str);  { CHR(39)=' }
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    spicepath_str:=Trim(Copy(line_str,p,count));
                    SPICESTR:=Copy(spicepath_str,2,Length(spicepath_str)-2); {remove ' ' from the path}
               end;
          goto next_line;
          end;

          if(Pos('NUTMEG',line_str)<>0) then
          begin
               p:=pos('.',line_str);
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    if count>4 then count:=4;
                    ext_nut_str:=Copy(line_str,p,count);
               end;
          goto next_line;
          end;

          if(Pos('MCADEXE',line_str)<>0) then
          begin
               p:=pos(CHR(39),line_str);  { CHR(39)=' }
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    mcadpath_str:=Trim(Copy(line_str,p,count));
                    MCADEXESTR:=Copy(mcadpath_str,2,Length(mcadpath_str)-2); {remove ' ' from the path}
               end;
          goto next_line;
          end;

          if(Pos('MCADEXT',line_str)<>0) then
          begin
               p:=pos('.',line_str);
               if (p>0) then
               begin
                    count:=line_len-p+1;
                    if count>4 then count:=4;
                    ext_mcad_str:=Copy(line_str,p,count);
               end;
          goto next_line;
          end;

next_line:
     end;


end;

procedure GetConfig;
 var
    conf_str:string;
    path_str:string;

begin
{$I-}
    LIBPATHSTR:='';
    path_str:=ExtractFileDir(ParamStr(0));
    conf_str:=path_str+'\amp.ini';
    ASSIGN(CONFIG,conf_str);
    RESET(CONFIG);
    if IOResult<>0 then
    begin
         INFO('NO CONFIG FILE - USING DEFAULTS');
         ext_in_str:=def_in_str;
         ext_out_str:=def_out_str;
         ext_nut_str:=def_nut_str;
         SPICESTR:='';
    end
    else
    begin
         ReadConfig;
    end;
    INFO('Config: Input *'+ext_in_str);
    INFO('Config: Output *'+ext_out_str);
    INFO('Config: Libpath: '+LIBPATHSTR);
    INFO('Config: Nutmeg *'+ext_nut_str);
    INFO('Config: Spice: ' + SPICESTR);

    if (ext_in_str=ext_out_str) then error_num:=err_config;
{$I+}
end;



Procedure DataOpen;
begin
  {$I-}
  if INPSTR<>'' then
  begin

       ASSIGN(DATA,INPSTR);
       RESET(DATA);
       if IOResult<>0 then
       begin
            error_num:=err_file;
       end;
  end
  else
       error_num:=err_file;
  {$I+}

end;


Procedure CreateResults;

 begin


  ASSIGN(RESULTS,OUTSTR);
  REWRITE(RESULTS);
  {
  if IOResult<>0 then
  begin
       error_num:=err_file;
  end;
  while not (eof(DATA))do
  begin
       READLN(DATA,s);
       WRITELN(RESULTS,s);
  end;
  }
  RESET(DATA);

end;


{***************************************************************************
 check if exists Spice and nutmeg file, if yes execute

 @version - 1.0
 ***************************************************************************}

procedure Run_Nutmeg;

begin

      INFO('$RAW SPICE:' + SPICESTR);
      NUTMEGSTR:=Copy(OUTSTR,1,POS('.',OUTSTR)-1)+ext_nut_str;
      if (FileExists(NUTMEGSTR)) then begin
        INFO('$RAW NUTMEG:' + NUTMEGSTR);
        // Now we will create the TProcess object, and assign it to the var AProcess.
        SpiceProcess := TProcess.Create(nil);
        // Tell the new AProcess what the command to execute is.
        SpiceProcess.CommandLine := SPICESTR +' '+NUTMEGSTR;
        // We will define an option for when the program is run. This option will make sure that our program
        // does not continue until the program we will launch
        // has stopped running.
        // AProcess.Options := AProcess.Options + [poWaitOnExit];
        // Now that AProcess knows what the commandline is we will run it.
        SpiceProcess.Execute;
        // This is not reached until ppc386 stops running.
        SpiceProcess.Free;
      end
      else begin
        INFO('$RAW BUT NO NUTMEG :' + NUTMEGSTR);
      end

end;

{----------------------------------------------------------}

{***************************************************************************
 check if exists Mcad and script file, if yes execute

 @version - 1.0
 ***************************************************************************}

procedure Run_Mcad;

begin
    { MCADEXESTR is not checked to be a file - it is a command in a path so Fi}
      MCADSCRIPTSTR:=Copy(OUTSTR,1,POS('.',OUTSTR)-1)+ext_mcad_str;
      if (FileExists(MCADSCRIPTSTR)) then begin
        INFO('$MCAD SCRIPT:' + MCADSCRIPTSTR);
        // Now we will create the TProcess object, and assign it to the var AProcess.
        McadProcess := TProcess.Create(nil);
        // Tell the new AProcess what the command to execute is.
        // Tell the new AProcess what the command to execute is.
        McadProcess.CommandLine := MCADEXESTR + ' ' + MCADSCRIPTSTR;
        // We will define an option for when the program is run. This option will make sure that our program
         // does not continue until the program we will launch
         // has stopped running.
         // AProcess.Options := AProcess.Options + [poWaitOnExit];
         // Now that AProcess knows what the commandline is we will run it.
         McadProcess.Execute;
         // This is not reached until ppc386 stops running.
         McadProcess.Free;
    end
    else
    begin
     INFO('$MCAD BUT NO SCRIPT :' + MCADSCRIPTSTR);
    end

end;

{----------------------------------------------------------}

procedure Amp_exe;
 var
  p:Integer;

begin


     GetConfig;

     if ParamCount=0 then
     begin
         Form1.OpenDialog1.Filter:=
         'Amp input files(*'+ext_in_str+')|*'+ext_in_str+
         '|All(*.*)|*.*';
         Form1.OpenDialog1.Execute;
         INPSTR:=Form1.OpenDialog1.Filename;
     end
     else if ParamCount=1 then
     begin
          INPSTR:=ParamStr(1);
          p:=POS('.',INPSTR);
          if p>0 then
            OUTSTR:=Copy(INPSTR,1,p-1)+ext_out_str
          else  
            OUTSTR:=Copy(INPSTR,1,Length(INPSTR))+ext_out_str;        
     end
     else
     begin
          INPSTR:=ParamStr(1);
          OUTSTR:=ParamStr(2);  
     end;

     DataOpen;
     Form1.Edit1.Text:=INPSTR;

     If error_num<>0 then
     begin
        ErrorReport;
     end
     else
     begin
          CreateResults;
          Form1.Edit2.Text:=OUTSTR;
          If error_num<>0 then  ErrorReport;
     end;

     if error_num=0 then
     begin
        AMP;
        if error_num=0 then
        begin
          if raw then Run_Nutmeg;
          if mcad then Run_Mcad; 
          STATUS('*** THIS IS THE END ***');
          INFO('*** THIS IS THE END ***');
          programstate:=4;
        end
     end
     else
     begin
        programstate:=3;
     end;
end;

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
     Edit1.Text:='';
     Edit2.Text:='';
     Memo1.Clear;
     Timer1.Enabled:=True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    case programstate of
    1:
    begin
         programstate:=2;
         Amp_exe;
    end;
    2:
    begin
         {wait for dojob end -> programstate=3 }
    end;
    3:
    begin
         ExitCode := error_num;
         programstate:=4;
    end;
    4:
    begin
         programstate:=5;
    end;
    5:
    begin
         programstate:=6;
    end;
    6:
    begin
         if error_num <> 0 then
         begin
          ExitCode := error_num;
          Halt(error_num);
         end;
         Application.Terminate;
    end;
   end;
end;


initialization
  {$I Amp8_Main.lrs}

end.

