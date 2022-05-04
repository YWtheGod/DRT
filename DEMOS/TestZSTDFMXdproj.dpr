program TestZSTDFMXdproj;

uses
  DRT.Init,
  System.StartUpCopy,
  FMX.Forms,
  TestZSTDFMXmain in 'TestZSTDFMXmain.pas' {main},
  EnsureData in 'EnsureData.pas',
  TestUnit in 'TestUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmain, main);
  Application.Run;
end.
