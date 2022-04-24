program TESTFMXEDGE;

uses
  System.StartUpCopy,
  FMX.Forms,
  testmfxedgemain in 'testmfxedgemain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
