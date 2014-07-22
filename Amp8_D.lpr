program Amp8_D;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
Amp8_Main, LResources, Model8, OUTPUT8, Probes8, RAW8, TASK8, TOOLBOX8, TYPE8, VAR8, VAREXT8, YMAT8, AMP8, COMM8, COMP8, DATAIO8, ELEMENT8, EXTEND8, History, LIB8, LINE8, MATRIX8, MCAD8;

{$IFDEF WINDOWS}{$R Amp8_D.rc}{$ENDIF}

begin
  {$I Amp8_D.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

