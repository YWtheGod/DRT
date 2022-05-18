unit TestAutoRefMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls
//*****************************************
  ,DRT.YWTypes
//*****************************************
  ;

type
  TMain = class(TForm)
    M: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    type TPointers = array of Pointer;
    var
    T : TaskSyncer;
    procedure Put(const S:String=''); inline;
    procedure ShowValue(P : TPointers);
    procedure ShowMem; inline;
    procedure UIPut(const S:String='');
  end;

var
  Main: TMain;

implementation
uses FastMM5, System.Threading;

{$R *.dfm}

{ TMain }
type
  TClassA = class
    procedure SayHello;
    constructor Create;
    destructor Destroy; override;
  end;

procedure TMain.Button1Click(Sender: TObject);
var A,B : R<TClassA>;
    C : WR<TClassA>;
    D : TClassA;
begin
  Put('=======Object Auto Ref Demo Started==========');
  ShowValue([A,B,C]);
  PUT;
  Put('A := TClassA.Create;');
  A := TClassA.Create;
  ShowValue([A,B,C]);
  PUT;
  B :=TClassA.Create;
  A :=B;
  ShowValue([A,B]);
  PUT;
  Put('D:=A');
  D := A;
  ShowValue([A,B,C,D]);
  PUT;
  PUT('C := B;');
  C  := B;
  ShowValue([A,B,C]);
  PUT;
  PUT('C.O.SayHello;');
  C.O.SayHello;
  PUT;
  begin
    var E : R<TClassA>;
    PUT('E := C;');
    E := C;
    ShowValue([A,B,C,D,E]);
    PUT;
    PUT('A:=nil; B:=nil');
    A:=nil; B := nil;
    ShowValue([A,B,C,D,E]);
    PUT;
    PUT('E end of life');
  end;
  ShowValue([A,B,C,D]);
  PUT;
  PUT('D.Free.......');
  try
    D.Free;
  except on E: Exception do
    PUT(E.Message);
  end;
  Put('========Object Auto Ref Demo Ended===========');
  Put;
end;

const
  MEMSIZE = 100000000; //256M;
procedure TMain.Button2Click(Sender: TObject);
var A,B : REFPTR;
    C : WREFPTR;
    D : Pointer;
begin
  Put('=======Pointer Auto Ref Demo Started==========');
  ShowMem;
  A.Alloc(MEMSIZE);
  ShowMem;
  GetMem(D,MEMSIZE); B := D;
  C := B;
  ShowValue([A,B,C]);
  ShowMem;
  B := A;
  ShowMem;
  ShowValue([A,B,C]);
  begin
    var E: REFPTR  := A;
    A := nil; B := nil;
    ShowMem;
    ShowValue([A,B,C,D,E]);
  end;
  ShowMem;
    ShowValue([A,B,C,D]);
  Put('========Pointer Auto Ref Demo Ended===========');
  Put;
end;

procedure TMain.Button3Click(Sender: TObject);
var T : TaskSyncer;
begin
  Put('=======Task Syncer Demo Started==========');
  T.OnAllDone(procedure begin
    UIPut('All Task Done!');
    UIPut('========Task Syncer Ref Demo Ended===========');
    UIPut;
  end);
  T.AddTask(20);
  for var i := 1 to 20 do begin
    var F := procedure(i : integer) begin
      TTask.Run(procedure begin
        UIPut('Task '+i.ToString+' Start.....');
        var a := random(3000)+200;
        if a and 3 = 1 then begin
          T.AddTask;
          TTask.Run(procedure begin
            UIPut('Additional Task From Task '+i.tostring+' Running...');
            Sleep(2000);
            UIPut('Additional Task From Task '+i.tostring+' Done!');
            T.DoneTask;
          end);
        end;
        sleep(a);
        UIPut('Task '+i.ToString+' Done!');
        T.DoneTask;
      end);
    end;
    F(i);
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  randomize;
end;

procedure TMain.Put(const S: String);
begin
  M.Lines.Add(S);
end;

procedure TMain.ShowMem;
begin
  Put('Memory Allocated: '+FastMM_GetUsageSummary.AllocatedBytes.ToString);
end;

procedure TMain.ShowValue(P: TPointers);
var s : string;
begin
  s := '';
  for var i := 0 to Length(P)-1 do
    s :=s+'  '+Char(ord('A')+i)+': @'+ inttohex(NativeInt(P[i]),
      sizeof(Pointer)*2);
  Put(s);
end;

procedure TMain.UIPut(const S: String);
begin
  TThread.Queue(TThread.Current,procedure begin
    Put(S);
  end);
end;

{ TClassA }

constructor TClassA.Create;
begin
  Main.Put(format('Class %s instance created @%p',[ClassName,Pointer(Self)]));
end;

destructor TClassA.Destroy;
begin
  Main.Put(format('Class %s instance @%p destroyed',[ClassName,Pointer(Self)]));
  inherited;
end;

procedure TClassA.SayHello;
begin
  Main.Put(format('Hello From %s @%p!',[ClassName,Pointer(self)]));
end;

end.
