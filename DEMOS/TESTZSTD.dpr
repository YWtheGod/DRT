program TESTZSTD;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DRT.Init,
  TestUnit in 'TestUnit.pas',
  EnsureData in 'EnsureData.pas';

begin
  CheckData;
  DoTest;
end.
