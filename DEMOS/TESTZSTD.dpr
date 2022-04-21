program TESTZSTD;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  TestUnit in 'TestUnit.pas',
  EnsureData in 'EnsureData.pas';

begin
  CheckData;
  DoTest;
end.
