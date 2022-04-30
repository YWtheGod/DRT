program TestMMConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DRT.Init,
  System.SysUtils,
  System.Diagnostics,
  Classes,
  Threading,
  MMTestUnit in 'MMTestUnit.pas';

type
  TWorkThread =class(TThread)
    n : integer;
    constructor create(v : integer);
    procedure Execute; override;
  end;

var W : TStopWatch;
    WT : array[0..127] of TWorkThread;
    n : integer;
    a : Int64;

{ TWorkThread }

constructor TWorkThread.create(v: integer);
begin
  n := v;
  inherited Create(true);
end;

procedure TWorkThread.Execute;
begin
  DoTest(n);
end;

begin
  try
    n := 1;
    while n<=128 do begin
      writeln(n.ToString+' threads test starting....');
      for var i := 0 to n-1 do WT[i] := TWorkThread.create(i);
  //    SetMemoryManager(MM);
      W.Start;
      for var i := 0 to n-1 do WT[i].Start;
      for var i := 0 to n-1 do WT[i].WaitFor;
      W.Stop;
  //    SetMemoryManager(OMM);
      a := W.ElapsedMilliseconds;
      writeln('test run time: '+a.ToString+'ms');
      for var i := 0 to n-1 do WT[i].Free;
      n := n+n;
    end;
    Writeln('Done!');
    readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
