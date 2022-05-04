program TESTZSTD;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DRT.Init,
  TestUnit in 'TestUnit.pas',
  EnsureData in 'EnsureData.pas',
  IOProxy in 'IOProxy.pas';
procedure Put(s : String);
begin
  Writeln(s);
end;
function Get:String;
begin
  Readln(Result);
end;
begin
  GetS := Get;
  PutS := Put;
  CheckData;
  DoTest;
end.
