program TESTWV2LD;

uses
  Vcl.Forms,
  testwv2ldmain in 'testwv2ldmain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
