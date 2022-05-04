unit TestZSTDFMXmain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls;

type
  Tmain = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Memo1Tap(Sender: TObject; const Point: TPointF);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  main: Tmain;
  running : boolean;

implementation
uses IOProxy,EnsureData,TestUnit,System.Threading;

{$R *.fmx}
procedure Put(S:String);
begin
  TThread.Queue(TThread.Current,procedure begin
    main.Memo1.Lines.Add(S);
  end);
end;

function Get:String;
begin
  Result := '';
end;

procedure Tmain.FormCreate(Sender: TObject);
begin
  PutS := Put;
  GetS := Get;
  running := true;
  TTask.Run(procedure begin
    CheckData;
    running := false;
  end);
end;

procedure Tmain.Memo1Click(Sender: TObject);
begin
  if not Running then begin
    running := true;
//    Memo1.Lines.Add('Creating Test Task....');
    TTask.Run(procedure begin
      DoTest;
//      running := false;
    end);
  end
//  else Memo1.Lines.Add('Already Running');
end;

procedure Tmain.Memo1Tap(Sender: TObject; const Point: TPointF);
begin
  Memo1Click(Sender);
end;

end.
