program TestAutoRef;

uses
  DRT.Init,
  Vcl.Forms,
  TestAutoRefMain in 'TestAutoRefMain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
