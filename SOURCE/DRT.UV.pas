unit DRT.UV;

interface

uses SysUtils, classes, System.Net.Socket, DRT.libuv, DRT.YWTypes, SyncObjs,
{$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.WinSock2, Winapi.ShellAPI, Winapi.IpExport, Winapi.WinSock;
{$ENDIF}
{$IFDEF POSIX}
POSIX.SysTypes, Posix.ArpaInet, Posix.NetinetIn, Posix.SysSocket,
  Posix.SysSelect;
{$ENDIF}

type
  TUVHandle = class;
  TUVRunMode = uv_run_mode;
  TUVLoopOption = uv_loop_option;
  TUVFileHandle = uv_os_fd_t;
  TUVBuf = uv_buf_t;
  TUVNotify = reference to procedure;
  TUVIntNotify = reference to procedure(i: integer);
  TUV2IntNotify = reference to procedure(i, j: integer);
  TUVWalkNotify = reference to procedure(Sender: TUVHandle);
  TUVWalkNotify2 = reference to procedure(Sender: TUVHandle; a: Pointer);
  TUVRetNotify = reference to function : integer;

  TUV_Async = record
    A : uv_async_t;
    reserved : array[0..15] of byte;
    FCB : TUVNotify;
    FRCB : TUVRetNotify;
    S : TEvent;
    NeedReturn : boolean;
    Ret : Integer;
    E : Exception;
  end;
  PUV_Async = ^TUV_Async;

  TUVLoop = class;
  TUVThread = class(TThread)
  private
    FLoop : TUVLoop;
  public
    Constructor Create(L : TUVLoop = nil; Paused : Boolean=false);
    procedure Run(F : TUVNotify); inline;
    function Get(F : TUVRetNotify):integer; inline;
    procedure Execute; overload;
    procedure Quit;
  end;

  TUVLoop = class
  private
    FRunMode: TUVRunMode;
    procedure SetRunMode(const Value: TUVRunMode);
  protected
  class var
    CWalkCB1: TUVWalkNotify;
    CWalkCB2: TUVWalkNotify2;
    CTID : Cardinal;
    EventPool : TRingQueue512;
    AsyncPool: TPool<uv_async_t,__T2>;
    NoReturn : boolean;

  var
    FLoop: uv_loop_t;
    reverse: array [0 .. 255] of byte;
    WalkCB1: TUVWalkNotify;
    WalkCB2: TUVWalkNotify2;
    FTID : Cardinal;

    function uvloop: Puv_loop_t; inline;
    class function Data(P: Puv_loop_t): TUVLoop; static; inline;
    class procedure Walk_CB(var handle: uv_handle_t; arg: Pointer);
      cdecl; static;
    class procedure ACB(var handle: uv_async_t); cdecl; static;
  public
    procedure UVRun(F : TUVNotify); inline;
    function UVGet(F : TUVRetNotify):integer; inline;
    function TID : Cardinal; inline;
    constructor Create;
    destructor Destroy; override;
    function Run(m: TUVRunMode): integer; overload;
    function Run: integer; overload;
    procedure UpdateTime;
    function Config(O: TUVLoopOption): integer;
    function Alive: boolean;
    procedure Stop;
    function BackEndFD: integer;
    function BackEndTimeOut: integer;
    function Now: UInt64;
    procedure Walk(F: TUVWalkNotify2; arg: Pointer); overload;
    procedure Walk(F: TUVWalkNotify); overload;
    class destructor ClassDone;
    property RunMode: TUVRunMode read FRunMode write SetRunMode;
  end;

  TUVBase = class abstract
  private
    FLoop: TUVLoop;
    procedure SetLoop(const Value: TUVLoop);
  protected
    procedure Init; virtual; abstract;
    function uvloop: Puv_loop_t; inline;
  public
    procedure UVRun(F : TUVNotify); inline;
    function UVGet(F : TUVRetNotify):integer; inline;
    constructor Create(L: TUVLoop = nil); virtual;
    property loop: TUVLoop read FLoop write SetLoop;
  end;

  TUVHandle = class abstract(TUVBase)
  private
    function GetSendBufferSize: integer;
    procedure SetSendBufferSize(Value: integer);
    function GetRecvBufferSize: integer;
    procedure SetRecvBufferSize(Value: integer);
    procedure DoFree;
  protected
    FreeNow : boolean;
    function uvhandle: Puv_handle_t; virtual; abstract;
    class function Data(const h: uv_handle_t): TUVHandle; static; inline;
    class procedure Close_CB(var handle: uv_handle_t); cdecl; static;
    class procedure ReleaseHandle(h : Pointer); virtual; abstract;
    procedure Close; virtual;
  public
    constructor Create(L: TUVLoop = nil); override;
    destructor Destroy; override;
    function Active: boolean;
    function Closing: boolean;
    function FileHandle: TUVFileHandle;
    property SendBufferSize: integer read GetSendBufferSize
      write SetSendBufferSize;
    property RecvBufferSize: integer read GetRecvBufferSize
      write SetRecvBufferSize;
  end;

  TUVHandle < T: Record >= class abstract(TUVHandle)
  protected
  type
    TInitProc = function(var L: uv_loop_t; h: Pointer): integer; cdecl;
    TData = record
      case integer of
        0:
          (uvhandle: uv_handle_t);
        1:
          (handle: T);
    end;
    PData = ^TData;
  class var Pool : TPool<TData,__T1>;
  var
    UV: PData;
    function uvhandle: Puv_handle_t; override;
    class procedure ReleaseHandle(h : Pointer); override;
    procedure DoInit(F: TInitProc);
    procedure Init; override;
  end;

  TUVTimer = class;
  TUV_Timer = record
    T : uv_timer_t;
    reserved : array[0..15] of byte;
    FCB: TUVNotify;
  end;
  PUV_Timer = ^TUV_Timer;
  TUVTimer = class(TUVHandle<TUV_Timer>)
  private
    FTimeOut: UInt64;
    function GetInterval: UInt64;
    procedure SetInterval(const Value: UInt64);
    procedure SetTimeOut(const Value: UInt64);
  protected
    frunning : boolean;
    procedure Init; override;
    class function Data(const h: uv_timer_t): TUVTimer; static; inline;
    class procedure CB(var handle: uv_timer_t); cdecl; static;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    function Start(F: TUVNotify): integer; overload;
    function Stop: integer;
    function Again: integer;
    function DueIn: UInt64;
    property Interval: UInt64 read GetInterval write SetInterval;
    property TimeOut : UInt64 read FTimeOut write SetTimeOut;
  end;

  TUVIdle = class;
  TUV_Idle = record
    I : uv_idle_t;
    reserved : array[0..15] of byte;
    FCB: TUVNotify;
  end;
  PUV_Idle = ^TUV_Idle;
  TUVIdle = class(TUVHandle<TUV_Idle>)
  protected
    procedure Init; override;
    class function Data(const h: uv_idle_t): TUVIdle; static; inline;
    class procedure CB(var handle: uv_idle_t); cdecl; static;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    function Start(F: TUVNotify): integer; overload;
    function Stop: integer;
  end;

  TUVPrepare = class;
  TUV_Prepare = record
    P : uv_prepare_t;
    reserved : array[0..15] of byte;
    FCB: TUVNotify;
  end;
  PUV_Prepare = ^TUV_Prepare;
  TUVPrepare = class(TUVHandle<TUV_Prepare>)
  protected
    procedure Init; override;
    class procedure CB(var handle: uv_prepare_t); cdecl; static;
    class function Data(const h: uv_prepare_t): TUVPrepare; static; inline;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    function Start(F: TUVNotify): integer; overload;
    function Stop: integer;
  end;

  TUVCheck = class;
  TUV_Check = record
    C : uv_check_t;
    reserved : array[0..15] of byte;
    FCB: TUVNotify;
  end;
  PUV_Check = ^TUV_Check;
  TUVCheck = class(TUVHandle<TUV_Check>)
  protected
    procedure Init; override;
    class procedure CB(var handle: uv_check_t); cdecl; static;
    class function Data(const h: uv_check_t): TUVCheck; static; inline;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    function Start(F: TUVNotify): integer; overload;
    function Stop: integer;
  end;

  TUVSock = uv_os_sock_t;
  TUVPoll = class;
  TUV_Poll = record
    P : uv_poll_t;
    reserved : array[0..15] of byte;
    FCB: TUV2IntNotify;
  end;
  PUV_Poll = ^TUV_Poll;
  TUVPoll = class(TUVHandle<TUV_Poll>)
  private
    FEvents: integer;
    procedure SetEvents(const Value: integer);
  protected
    ffd : integer;
    fsock : TUVSock;
    class procedure CB(var handle: uv_poll_t; status, events: integer); cdecl;
      static;
    class function Data(const h: uv_poll_t): TUVPoll; static; inline;
    procedure init; override;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    constructor Createfd(fd: integer; L: TUVLoop = nil); overload;
    constructor CreateSock(sock: TUVSock; L: TUVLoop = nil); overload;
    function Start(F: TUV2IntNotify): integer; overload;
    function Stop: integer;
    property Events : integer read FEvents write SetEvents;
  end;

  TUVSignal = class;
  TUV_Signal = record
    S : uv_signal_t;
    reserved : array[0..15] of byte;
    FCB: TUVIntNotify;
  end;
  PUV_Signal = ^TUV_Signal;
  TUVSignal = class(TUVHandle<TUV_Signal>)
  private
    FSigNum: integer;
    procedure SetSigNum(const Value: integer);
  protected
    class procedure CB(var handle: uv_signal_t; signum: integer); cdecl; static;
    class function Data(const h: uv_signal_t): TUVSignal; static; inline;
    procedure Init; override;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    function Start(F: TUVIntNotify): integer; overload;
    function StartOneShot(F: TUVIntNotify): integer; overload;
    function Stop: integer;
    property SigNum : integer read FSigNum write SetSigNum;
  end;

  TUVProcessOptions = uv_process_options_t;
  PUVProcessOptions = ^TUVProcessOptions;
  TUVProcessFlags = uv_process_flags;
  TUVProcess = class;
  TUVProcessNotify = reference to procedure(es: Int64; ts: integer);
  TUVProcessData=record
    Process : uv_process_t;
    Options : uv_process_options_t;
    FCB : TUVProcessNotify;
  end;
  PUVProcessData = ^TUVProcessData;
  TUVProcess = class(TUVHandle<TUVProcessData>)
  private
    function getpid: integer;
  protected
    PO : PUVProcessOptions;
    class procedure CB(var handle: uv_process_t; es: Int64; ts: integer); cdecl;
      static;
    class function Data(const h: uv_process_t): TUVProcess; static; inline;
    procedure Init; override;
    class procedure ReleaseHandle(h : Pointer); override;
  public
    constructor Create(const O: TUVProcessOptions; F: TUVProcessNotify = nil;
      L: TUVLoop = nil); overload;
    function kill(signum: integer): integer; overload;
    class function kill(pid, signum: integer): integer; overload; static;
    property pid: integer read getpid;
  end;

  TUVADDR = record
  private
    function GetAddressV4: String;
    function GetAddressV6: String;
    procedure SetAddressV4(const Value: String);
    procedure SetAddressV6(const Value: String);
  public
    property AddressV4 : String read GetAddressV4 write SetAddressV4;
    property AddressV6 : String read GetAddressV6 write SetAddressV6;
    procedure SetV4(const A : String; const P : Word); inline;
    procedure SetV6(const A : String; const P : Word); inline;
    class function From(S : String;P:Word):TUVADDR; inline; static;
    case integer of
      0:
        (SaFamily,Port: Word);
      1:
        (v4: sockaddr_in);
      2:
        (v6: sockaddr_in6);
      3:
        (storage: sockaddr_storage);
  end;
  PUVADDR = ^TUVADDR;

  TUVStream = class;
  TUVStreamClass = class of TUVStream;
  TUVReadNotify = reference to procedure(Buf: REFPTR; Len: NativeUInt);
  TUVUDPRecvNotify = reference to procedure(Buf: REFPTR; Len: NativeUInt;
    Addr : TUVAddr; flags: Cardinal);
  TUVStreamIntNotify = reference to procedure(S: TUVStream; i: integer);
  TUVStrIntIntNotify = reference to procedure(Str : String; i,j: integer);
  TUVPollNotify = reference to procedure(statu:integer; prev,curr : uv_stat_t);
  TUV_Stream = record
    FLCB: TUVIntNotify;
    FRCB: TUVReadNotify;
    FURCB : TUVUDPRecvNotify;
    FFSCB : TUVStrIntIntNotify;
    FPCB : TUVPollNotify;
    FEOF : boolean;
  end;
  PUV_Stream = ^TUV_Stream;
  TUVStream = class abstract(TUVHandle)
  private
    function GetWriteQueueSize: NativeUInt;
    function GetEof: boolean;
  protected
    class function StreamData(var h):PUV_Stream; virtual; abstract;
    class procedure LCB(var server: uv_stream_t; status: integer); cdecl;
      static;
    class procedure ACB(var h: uv_handle_t; S: NativeUInt; var b: uv_buf_t);
      cdecl; static;
    class procedure RCB(var h: uv_stream_t; S: ssize_t; const b: uv_buf_t);
      cdecl; static;
    class function Data(const h: uv_stream_t): TUVStream; static; inline;
    function uvstream: Puv_stream_t; inline;
  public
    function listen(backlog: integer; F: TUVIntNotify): integer; overload;
    function Read(F: TUVReadNotify): integer; overload;
    function ReadStop: integer;
    function ShutDown(F: TUVIntNotify): integer; overload;
    function Write(Buf: REFPTR; size: NativeInt; F: TUVIntNotify):
      integer; overload;
    function Write(Buf: Pointer; size: NativeInt; F: TUVIntNotify):
      integer; overload;
    function Write2(Buf: REFPTR; size: NativeInt; S: TUVStream; F:
      TUVIntNotify): integer; overload;
    function Write2(Buf: Pointer; size: NativeInt; S: TUVStream; F:
      TUVIntNotify): integer; overload;
    function TryWrite(Buf: Pointer; size: integer): integer;
    function TryWrite2(Buf: Pointer; size: integer; S: TUVStream): integer;
    function IsReadable: boolean;
    function IsWriteable: boolean;
    function SetBlocking(b: integer): integer;
    property WriteQueueSize: NativeUInt read GetWriteQueueSize;
    property EOF:boolean read GetEof;
  end;

  TUVStream<T: Record > = class abstract(TUVStream)
  protected
  type
    TData2 = record
      case integer of 0: (uvhande: uv_handle_t);
        1: (uvstream: uv_stream_t);
        2: (handle: T);
    end;
    TData = record
      D : TDATA2;
      reserved : array[0..31] of byte;
      S : TUV_Stream;
    end;
    PData = ^TData;
  class var Pool : TPool<TData,__T2>;
  var
    UV: PData;
    reserved : array[0..31] of byte;
    function uvhandle: Puv_handle_t; override;
    class procedure ReleaseHandle(h : Pointer); override;
    procedure Init; override;
    class function StreamData(var h):PUV_Stream; override;
  end;

  TUVTCP = class(TUVStream<uv_tcp_t>)
  protected
    fflags: Cardinal;
    procedure Init; override;
    procedure close; override;
  public
    constructor Create(flags: Cardinal; L: TUVLoop = nil); overload;
    function Open(sock: TUVSock): integer;
    function NoDelay(Enable: integer): integer;
    function SimultaneousAccepts(Enable: integer): integer;
    function KeepAlive(Enable, delay: integer): integer;
    function Bind(const Bound : TUVADDR; flags : Cardinal):integer;
    function Connect(const Peer : TUVADDR; F : TUVIntNotify=nil) : integer;
      overload;
    function GetSockName(var A : TUVAddr):integer;
    function GetPeerName(var A : TUVAddr):integer;
    function Accept:TUVTCP;
    function SocketPair(tp,pt : integer;var s1,s2:TUVSock;f0:uv_stdio_flags=
      UV__NONBLOCK_PIPE; f1:uv_stdio_flags=UV__NONBLOCK_PIPE):integer;
  end;

  TUVFile = uv_file;
  TUVPipe = class(TUVStream<uv_pipe_t>)
  protected
    fipc : boolean;
    procedure Init; override;
  public
    constructor Creaet(ipc : boolean; L : TUVLoop = nil); overload;
    function Open(f : TUVFile):integer;
    procedure Connect(Name : String; F : TUVIntNotify); overload;
    function Bind(S : String):integer;
    function SockName : AnsiString;
    function PeerName : AnsiString;
    procedure PendingInstances(count : integer);
    function PendingCount : integer;
    function PendingType : uv_handle_type;
    function Accept:TUVStream;
    function Chmod(flags : integer):integer;
    function Pipe(var f1,f2 : TUVFile; read_flags,write_flags : integer):
      integer;
  end;

  TUVTTY = class(TUVStream<uv_tty_t>)
  private
    class function GetVtermState: uv_tty_vtermstate_t; static;
    class procedure SetVtermState(const Value: uv_tty_vtermstate_t); static;
  protected
    ffd : integer;
    fnotreadable : boolean;
    procedure Init; override;
  public
    constructor Create(fd : integer; Readable : boolean; L:TUVLoop = nil);
      overload;
    function SetMode(M : uv_tty_mode_t):integer;
    function Width : integer;
    function Height : integer;
    class property VtermState : uv_tty_vtermstate_t read GetVtermState write
      SetVtermState;
  end;

  TUVUDP=class;
  TUV_UDPSEND=record
    S : uv_udp_send_t;
    ADDR : TUVAddr;
    buffer : uv_buf_t;
    buf : REFPTR;
    FCB : TUVIntNotify;
  end;
  PUV_UDPSEND = ^TUV_UDPSEND;
  TUVUDP = class(TUVStream<uv_udp_t>)
  private
    function GetSendQueueSize: NativeUInt;
    function GetSendQueueCount: NativeUInt;
  protected
  type
    TUV_UDPCONNECT = record
      C : uv_udp_send_t;
      buf : RefPTR;
      Buffer : uv_buf_t;
      FCB : TUVIntNotify;
    end;
  class var
    SendPool : TPool<TUV_UDPSEND,__T2>;
  var
    fflag : integer;
    procedure Init; override;
    class procedure SCB(var H:uv_udp_send_t; status : integer); cdecl; static;
    class procedure URCB(var handle: uv_udp_t; nread: ssize_t;
      const buf: Puv_buf_t; const addr: PSOCKADDR; flags: Cardinal); cdecl; static;
  public
    constructor Create(flags : integer; L : TUVLoop=nil); overload;
    function Open(sock : TUVSock):integer;
    function Bind(const Addr : TUVAddr; flags : Cardinal):integer;
    function Connect(const Addr : TUVAddr):integer;
    function Peer:TUVAddr;
    function Bound:TUVAddr;
    function SetMemberShip(MultiCastAddr,InterfaceAddr:AnsiString;M :
      uv_membership):integer;
    function SetSourceMemberShip(MultiCastAddr,InterfaceAddr,SourceAddr:
      AnsiString;M : uv_membership):integer;
    function SetMultiCastLoopOn(O : boolean):integer;
    function SetMultiCastTTL(T:integer):integer;
    function SetMultiCastInterface(I : AnsiString):integer;
    function SetBoardCastOn(O:Boolean):integer;
    function SetTTL(T : integer):integer;
    function Send(const Buf : RefPtr; Size : Cardinal; const Addr : TUVAddr;
      F : TUVIntNotify) : integer; overload;
    function Send(const Buf : Pointer; Size : Cardinal; const Addr : TUVAddr;
      F : TUVIntNotify) : integer; overload;
    function TrySend(const Buf : Pointer; Size : Cardinal; const Addr :
      TUVAddr) : integer; overload;
    function RecvStart(F : TUVUDPRecvNotify):integer;
    function RecvStop:integer;
    function UsingRecvMMsg:boolean;
    property SendQueueSize : NativeUInt read GetSendQueueSize;
    property SendQueueCount : NativeUInt read GetSendQueueCount;
  end;

  TUVFSEvent = class(TUVStream<uv_fs_event_t>)
  protected
    class procedure FSCB(var h : uv_fs_event_t; const filename : PAnsiChar;
      events, status : integer); cdecl; static;
    procedure Init; override;
  public
    function Start(Path : String; flags:Cardinal; F:TUVStrIntIntNotify):integer;
    function Stop:integer;
    function Path : String;
  end;

  TUVFSPoll = class(TUVStream<uv_fs_poll_t>)
  protected
    class procedure PCB(var h : uv_fs_poll_t;status : integer; const prev,curr
      : uv_stat_t); cdecl; static;
    procedure Init; override;
  public
    function Start(Path:AnsiString; interval:Cardinal; F : TUVPollNotify)
      : integer;
    function Stop:integer;
    function Path : String;
  end;

  function DefaultLoop: TUVLoop; inline;
  procedure DisableStdioInheritance;
  function UVStreamClass(T : uv_handle_type):TUVStreamClass;

implementation

uses DRT.YWSTRUTIL;

type
  TUVShutDown = record
    S: uv_shutdown_t;
    FCB: TUVIntNotify;
    class procedure CB(var R: uv_shutdown_t; st: integer); static; cdecl;
  end;

  PUVShutDown = ^TUVShutDown;

  TUVWrite = record
    S: uv_write_t;
    FCB: TUVIntNotify;
    Buf: uv_buf_t;
    buffer: REFPTR;
    class procedure CB(var R: uv_write_t; st: integer); static; cdecl;
  end;

  TUVConnect = record
    S: uv_connect_t;
    FCB: TUVIntNotify;
    class procedure CB(var R: uv_connect_t; st: integer); cdecl; static;
  end;

  PUVWrite = ^TUVWrite;
  PUVConnect = ^TUVConnect;

var
  ShutDownPool: TPool<TUVShutDown, __T1>;
  WritePool: TPool<TUVWrite, __T2>;
  ConnectPool : TPool<uv_connect_t,__T1>;

function UVStreamClass(T : uv_handle_type):TUVStreamClass;
begin
  Result := nil;
  case T of
    UV__UNKNOWN_HANDLE: ;
    UV__ASYNC: ;
    UV__CHECK: ;
    UV__FS_EVENT: ;
    UV__FS_POLL: ;
    UV__HANDLE: ;
    UV__IDLE: ;
    UV__NAMED_PIPE: ;
    UV__POLL: ;
    UV__PREPARE: ;
    UV__PROCESS: ;
    UV__STREAM: ;
    UV__TCP: Result := TUVTCP;
    UV__TIMER: ;
    UV__TTY: Result := TUVTTY;
    UV__UDP: Result := TUVUDP;
    UV__SIGNAL: ;
    UV__FILE: ;
    UV__HANDLE_TYPE_MAX: ;
  end;
end;

procedure DisableStdioInheritance;
begin
  uv_disable_stdio_inheritance;
end;

function DefaultLoop: TUVLoop; inline;
begin
  Result := nil;
end;

{ TUVLoop }

function TUVLoop.Alive: boolean;
begin
  Result := uv_loop_alive(uvloop^) <> 0;
end;

function TUVLoop.BackEndFD: integer;
begin
  Result := uv_backend_fd(uvloop^);
end;

function TUVLoop.BackEndTimeOut: integer;
begin
  Result := uv_backend_timeout(uvloop^);
end;

class destructor TUVLoop.ClassDone;
var E : TEvent;
begin
  uv_loop_close(uv_default_loop^);
  E := EventPool.Get;
  while assigned(E) do begin
    E.Free;
    E := EventPool.Get;
  end;
end;

function TUVLoop.Config(O: TUVLoopOption): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_loop_configure(uvloop^, O);
  end);
end;

constructor TUVLoop.Create;
begin
  uv_loop_init(FLoop);
  uv_loop_set_data(FLoop, self);
  RunMode := UV__RUN_DEFAULT;
end;

class function TUVLoop.Data(P: Puv_loop_t): TUVLoop;
begin
  Result := TUVLoop(uv_loop_get_data(Puv_loop_t(P)^));
end;

destructor TUVLoop.Destroy;
var A : integer;
begin
  A := UVGet(function : integer begin
    Result := uv_loop_close(FLoop);
  end);
  if A<>0 then
    raise Exception.Create('UV_LOOP Closing Error Code: '+A.ToString);
  inherited;
end;

function TUVLoop.Now: UInt64;
begin
  Result := uv_now(uvloop^);
end;

function TUVLoop.Run: integer;
begin
  if self = nil then begin
    CTID := TThread.Current.ThreadID;
    Result := uv_run(uv_default_loop^, UV__RUN_DEFAULT)
  end else begin
    FTID := TThread.Current.ThreadID;
    Result := uv_run(FLoop, RunMode);
  end;
end;

function TUVLoop.Run(m: TUVRunMode): integer;
begin
  if self = nil then begin
    CTID := TThread.Current.ThreadID;
    Result := uv_run(uv_default_loop^, m)
  end else begin
    FTID := TThread.Current.ThreadID;
    Result := uv_run(FLoop, m);
  end;
end;

procedure TUVLoop.SetRunMode(const Value: TUVRunMode);
begin
  FRunMode := Value;
end;

procedure TUVLoop.Stop;
begin
  UVRun(procedure begin
    uv_stop(uvloop^);
  end);
end;

function TUVLoop.TID: Cardinal;
begin
  if self= nil then Result := CTID else Result := FTID;
end;

procedure TUVLoop.UpdateTime;
begin
  UVRun(procedure begin
    uv_update_time(FLoop);
  end);
end;

function TUVLoop.uvloop: Puv_loop_t;
begin
  if assigned(self) then
    Result := @FLoop
  else
    Result := uv_default_loop;
end;

procedure TUVLoop.Walk(F: TUVWalkNotify2; arg: Pointer);
begin
  if assigned(F) then
  begin
    if assigned(self) then
    begin
      WalkCB1 := nil;
      WalkCB2 := F;
    end
    else
    begin
      CWalkCB1 := nil;
      CWalkCB2 := F;
    end;
    UVRun(procedure begin
      uv_walk(uvloop^, Walk_CB, arg);
    end);
  end;
end;

procedure TUVLoop.Walk(F: TUVWalkNotify);
begin
  if assigned(F) then
  begin
    if assigned(self) then
    begin
      WalkCB1 := F;
      WalkCB2 := nil;
    end
    else
    begin
      CWalkCB1 := F;
      CWalkCB2 := nil;
    end;
    UVRun(procedure begin
      uv_walk(uvloop^, Walk_CB, nil);
    end);
  end;
end;

class procedure TUVLoop.Walk_CB(var handle: uv_handle_t; arg: Pointer);
var
  L: TUVLoop;
  O: TUVHandle;
begin
  O := TUVHandle.Data(handle);
  L := O.loop;
  if assigned(L) then
    if assigned(L.WalkCB1) then
      L.WalkCB1(O)
    else
      L.WalkCB2(O, arg)
  else if assigned(L.CWalkCB1) then
    L.CWalkCB1(O)
  else
    L.CWalkCB2(O, arg);
end;

class procedure TUVLoop.ACB(var handle: uv_async_t);
var A : PUV_Async;
begin
  A := PUV_Async(@handle);
  if A.NeedReturn then begin
    try
      A.Ret := A.FRCB();
    except on E: Exception do
      A.E := E;
    end;
    if NoReturn then begin A.FCB:=nil; A.FRCB:=nil; AsyncPool.Release(A) end
    else A.S.SetEvent;
  end else begin
    try
      A.FCB();
    except on E: Exception do
    end;
    A.FCB := nil;
    A.FRCB := nil;
    AsyncPool.Release(A);
  end;
end;

function TUVLoop.UVGet(F: TUVRetNotify): integer;
var A : PUV_Async;
    E : Exception;
begin
  if assigned(F) then
    if TThread.Current.ThreadID=TID then Result := F()
    else begin
      A := AsyncPool.Get;
      A.NeedReturn := True;
      if not NoReturn then begin
        A.S := EventPool.Get;
        if not Assigned(A.S) then A.S := TEvent.Create;
        A.S.ResetEvent;
        A.E := nil;
      end;
      A.FRCB := F;
      uv_async_init(uvloop^,A^.A,ACB);
      uv_async_send(A.A);
      if NoReturn then Result := 0
      else begin
        A.S.WaitFor(Cardinal(-1));
        Result := A.Ret;
        if not EventPool.Put(A.S) then A.S.Free;
        E := A.E;
        A.FCB := nil;
        A.FRCB := nil;
        AsyncPool.Release(A);
        if assigned(E) then raise E;
      end;
    end
  else Result := 0;
end;

procedure TUVLoop.UVRun(F: TUVNotify);
var A : PUV_Async;
begin
  if assigned(F) then
    if TThread.Current.ThreadID=TID then F()
    else begin
      A := AsyncPool.Get;
      A.NeedReturn := false;
      A.FCB := F;
      uv_async_init(uvloop^,A^.A,ACB);
      uv_async_send(A.A);
    end;
end;

{ TUVHandle }

procedure TUVHandle.Close;
begin
  UVRUN(procedure begin
    uv_close(uvhandle^,Close_CB);
  end);
end;

class procedure TUVHandle.Close_CB(var handle: uv_handle_t);
begin
  ReleaseHandle(@handle);
end;

function TUVHandle.Closing: boolean;
begin
  Result := uv_is_closing(uvhandle^) <> 0;
end;

constructor TUVHandle.Create(L: TUVLoop);
begin
  inherited Create(L);
  uv_handle_set_data(uvhandle^, self);
end;

class function TUVHandle.Data(const h: uv_handle_t): TUVHandle;
begin
  Result := TUVHandle(uv_handle_get_data(h));
end;

destructor TUVHandle.Destroy;
begin
  Close;
  inherited;
end;

procedure TUVHandle.DoFree;
begin

end;

function TUVHandle.FileHandle: TUVFileHandle;
begin
  if uv_fileno(uvhandle^, Result) <> 0 then
    Result := 0;
end;

function TUVHandle.GetRecvBufferSize: integer;
begin
  Result := 0;
  if uv_recv_buffer_size(uvhandle^, Result) <> 0 then
    raise Exception.Create('Error on GetRecvBufferSize');
end;

function TUVHandle.GetSendBufferSize: integer;
begin
  Result := 0;
  if uv_send_buffer_size(uvhandle^, Result) <> 0 then
    raise Exception.Create('Error on GetSendBufferSize');
end;

procedure TUVHandle.SetRecvBufferSize(Value: integer);
begin
  if uv_recv_buffer_size(uvhandle^, Value) <> 0 then
    raise Exception.Create('Error on SetRecvBufferSize');
end;

procedure TUVHandle.SetSendBufferSize(Value: integer);
begin
  if uv_send_buffer_size(uvhandle^, Value) <> 0 then
    raise Exception.Create('Error on SetSendBufferSize');
end;

function TUVHandle.Active: boolean;
begin
  Result := uv_is_active(uvhandle^) <> 0;
end;

{ TUVBase }

constructor TUVBase.Create(L: TUVLoop);
begin
  inherited Create;
  loop := L;
  Init;
end;

procedure TUVBase.SetLoop(const Value: TUVLoop);
begin
  FLoop := Value;
end;

function TUVBase.UVGet(F: TUVRetNotify): integer;
begin
  Result := Floop.UVGet(F);
end;

function TUVBase.uvloop: Puv_loop_t;
begin
  Result := FLoop.uvloop;
end;

procedure TUVBase.UVRun(F: TUVNotify);
begin
  Floop.UVRun(F);
end;

{ TUVHandle<T> }

procedure TUVHandle<T>.DoInit(F: TInitProc);
type
  PT = ^T;
begin
  F(loop.uvloop^, @UV.handle);
end;

procedure TUVHandle<T>.Init;
begin
  uv := Pool.Get;
end;

class procedure TUVHandle<T>.ReleaseHandle(h : Pointer);
begin
  Pool.Release(h);
end;

function TUVHandle<T>.uvhandle: Puv_handle_t;
begin
  Result := @UV.uvhandle;
end;

class procedure TUVIdle.CB(var handle: uv_idle_t);
var I : PUV_Idle;
begin
  I := PUV_Idle(@handle);
  if assigned(I.FCB) then I.FCB()
end;

class function TUVIdle.Data(const h: uv_idle_t): TUVIdle;
begin
  Result := TUVIdle(uv_handle_get_data(Puv_handle_t(@h)^));
end;

procedure TUVIdle.Init;
begin
  inherited;
  DoInit(uv_idle_init);
end;

class procedure TUVIdle.ReleaseHandle(h: Pointer);
begin
  PUV_Idle(h).FCB := nil;
  inherited;
end;

function TUVIdle.Start(F: TUVNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_idle_start(UV.handle.I, CB);
    end);
  end else Result := 0;
end;

function TUVIdle.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_idle_stop(UV.handle.I);
  end);
end;

{ TUVTimer }

function TUVTimer.Again: integer;
begin
  Result := uv_timer_again(UV.handle.T);
end;

class procedure TUVTimer.CB(var handle: uv_timer_t);
var T : PUV_Timer;
begin
  T := PUV_Timer(@handle);
  if assigned(T.FCB) then T.FCB()
end;

class function TUVTimer.Data(const h: uv_timer_t): TUVTimer;
begin
  Result := TUVTimer(uv_handle_get_data(Puv_handle_t(@h)^));
end;

function TUVTimer.DueIn: UInt64;
begin
  Result := uv_timer_get_due_in(UV.handle.T);
end;

function TUVTimer.GetInterval: UInt64;
begin
  Result := uv_timer_get_repeat(UV.handle.T);
end;

procedure TUVTimer.Init;
begin
  inherited;
  DoInit(uv_timer_init);
  TimeOut := 1000;
  InterVal := 1000;
end;

class procedure TUVTimer.ReleaseHandle(h: Pointer);
begin
  PUV_Timer(h).FCB := nil;
  inherited;
end;

procedure TUVTimer.SetInterval(const Value: UInt64);
begin
  uv_timer_set_repeat(UV.handle.T, Value);
end;

procedure TUVTimer.SetTimeOut(const Value: UInt64);
begin
  FTimeOut := Value;
end;

function TUVTimer.Start(F: TUVNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_timer_start(UV.handle.T, CB, timeout, interval);
    end);
    frunning := (Result = 0)or frunning;
  end;
  Result := 0;
end;

function TUVTimer.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_timer_stop(UV.handle.T);
  end);
  Frunning := (Result<>0) and FRunning;
end;

{ TUVPrepare }

class procedure TUVPrepare.CB(var handle: uv_prepare_t);
var P : PUV_Prepare;
begin
  P := PUV_Prepare(@handle);
  if assigned(P.FCB) then P.FCB()
end;

class function TUVPrepare.Data(const h: uv_prepare_t): TUVPrepare;
begin
  Result := TUVPrepare(uv_handle_get_data(Puv_handle_t(@h)^));
end;

procedure TUVPrepare.Init;
begin
  inherited;
  DoInit(uv_prepare_init);
end;

class procedure TUVPrepare.ReleaseHandle(h: Pointer);
begin
  PUV_Prepare(h).FCB := nil;
  inherited;
end;

function TUVPrepare.Start(F: TUVNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_prepare_start(UV.handle.P, CB);
    end);
  end else Result := 0;
end;

function TUVPrepare.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_prepare_stop(UV.handle.P);
  end);
end;

{ TUVCheck }

class procedure TUVCheck.CB(var handle: uv_check_t);
var C : PUV_Check;
begin
  C := PUV_Check(@handle);
  if assigned(C.FCB) then C.FCB()
end;

class function TUVCheck.Data(const h: uv_check_t): TUVCheck;
begin
  Result := TUVCheck(uv_handle_get_data(Puv_handle_t(@h)^));
end;

procedure TUVCheck.Init;
begin
  inherited;
  DoInit(uv_check_init);
end;

class procedure TUVCheck.ReleaseHandle(h: Pointer);
begin
  PUV_Check(h).FCB := nil;
  inherited;
end;

function TUVCheck.Start(F: TUVNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_check_start(UV.handle.C, CB);
    end);
  end else Result := 0;
end;

function TUVCheck.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_check_stop(UV.handle.C);
  end);
end;

{ TUVPoll }

class procedure TUVPoll.CB(var handle: uv_poll_t; status, events: integer);
var P : PUV_Poll;
begin
  P := PUV_Poll(@handle);
  if assigned(P.FCB) then P.FCB(status,events)
end;

constructor TUVPoll.Createfd(fd: integer; L: TUVLoop);
begin
  ffd := fd;
  fsock := 0;
  inherited Create(L);
end;

constructor TUVPoll.CreateSock(sock: TUVSock; L: TUVLoop);
begin
  ffd := 0;
  fsock := sock;
  inherited Create(L);
end;

class function TUVPoll.Data(const h: uv_poll_t): TUVPoll;
begin
  Result := TUVPoll(uv_handle_get_data(Puv_handle_t(@h)^));
end;

procedure TUVPoll.init;
begin
  inherited;
  if ffd<>0 then uv_poll_init(loop.uvloop^,uv.handle.P,ffd)
  else if fsock<>0 then uv_poll_init_socket(loop.uvloop^,uv.handle.P,fsock);
end;

class procedure TUVPoll.ReleaseHandle(h: Pointer);
begin
  PUV_Poll(h).FCB := nil;
  inherited;
end;

function TUVPoll.Start(F: TUV2IntNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_poll_start(UV.handle.P, events, CB);
    end);
  end else Result := 0;
end;

procedure TUVPoll.SetEvents(const Value: integer);
begin
  FEvents := Value;
end;

function TUVPoll.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_poll_stop(UV.handle.P);
  end);
end;

{ TUVSignal }

class procedure TUVSignal.CB(var handle: uv_signal_t; signum: integer);
var S : PUV_Signal;
begin
  S := PUV_Signal(@handle);
  if assigned(S.FCB) then S.FCB(signum)
end;

class function TUVSignal.Data(const h: uv_signal_t): TUVSignal;
begin
  Result := TUVSignal(uv_handle_get_data(Puv_handle_t(@h)^));
end;

procedure TUVSignal.Init;
begin
  inherited;
  DoInit(uv_signal_init);
end;

class procedure TUVSignal.ReleaseHandle(h: Pointer);
begin
  PUV_Signal(h).FCB := nil;
  inherited;
end;

function TUVSignal.Start(F: TUVIntNotify): integer;
begin
  if assigned(F) then begin
    uv.handle.FCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_signal_start(UV.handle.S, CB, signum);
    end);
  end else Result := 0;
end;

function TUVSignal.StartOneShot(F: TUVIntNotify): integer;
begin
  uv.handle.FCB := F;
  if assigned(F) then
    Result:=UVGet(function:integer begin
      Result := uv_signal_start_oneshot(UV.handle.S, CB, signum);
    end);
end;

function TUVSignal.Stop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_signal_stop(UV.handle.S);
  end);
end;

procedure TUVSignal.SetSigNum(const Value: integer);
begin
  FSigNum := Value;
end;

{ TUVProcess }

class procedure TUVProcess.CB(var handle: uv_process_t; es: Int64; ts: integer);
var P : PUVProcessData;
begin
  P := PUVProcessData(@handle);
  if assigned(P.FCB) then P.FCB(es, ts)
end;

constructor TUVProcess.Create(const O: TUVProcessOptions; F: TUVProcessNotify;
L: TUVLoop);
begin
  PO := @O;
  inherited Create(L);
  uv.handle.FCB := F;
end;

class function TUVProcess.Data(const h: uv_process_t): TUVProcess;
begin
  Result := TUVProcess(uv_handle_get_data(Puv_handle_t(@h)^));
end;

function TUVProcess.getpid: integer;
begin
  Result := uv_process_get_pid(uv.handle.Process);
end;

procedure TUVProcess.Init;
begin
  inherited;
  uv.handle.Options := PO^;
  uv.handle.Options.exit_cb := CB;
  UVRun(procedure begin
    uv_spawn(loop.uvloop^,uv.handle.Process,uv.handle.Options);
  end);
end;

function TUVProcess.kill(signum: integer): integer;
begin
  Result := uv_process_kill(UV.handle.Process, signum);
end;

class function TUVProcess.kill(pid, signum: integer): integer;
begin
  Result := uv_kill(pid, signum);
end;

class procedure TUVProcess.ReleaseHandle(h: Pointer);
begin
  PUVProcessData(h).FCB := nil;
  inherited;
end;

{ TUVStream }

class procedure TUVStream.ACB(var h: uv_handle_t; S: NativeUInt;
var b: uv_buf_t);
begin
  Getmem(b.Base, S);
  b.Len := S;
end;

class procedure TUVStream.LCB(var server: uv_stream_t; status: integer);
var
  S: PUV_Stream;
begin
  S := StreamData(server);
  if assigned(S.FLCB) then S.FLCB(status)
end;

class function TUVStream.Data(const h: uv_stream_t): TUVStream;
begin
  Result := TUVStream(uv_handle_get_data(Puv_handle_t(@h)^));
end;

function TUVStream.GetEof: boolean;
begin
  Result := StreamData(uvstream^).FEOF;
end;

function TUVStream.GetWriteQueueSize: NativeUInt;
begin
  Result := uvstream^.write_queue_size;
end;

function TUVStream.IsReadable: boolean;
begin
  Result := uv_is_readable(uvstream^) <> 0;
end;

function TUVStream.IsWriteable: boolean;
begin
  Result := uv_is_writable(uvstream^) <> 0;
end;

function TUVStream.listen(backlog: integer; F: TUVIntNotify): integer;
begin
  if assigned(F) then begin
    StreamData(uvstream^).FLCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_listen(uvstream^, backlog, LCB)
    end);
  end else Result := 0;
end;

class procedure TUVStream.RCB(var h: uv_stream_t; S: ssize_t;
const b: uv_buf_t);
var
  R: REFPTR;
  T : PUV_Stream;
begin
  T := StreamData(h);
  T.FEOF := s = ord(UV__EOF);
  if S > 0 then
    R := b.Base
  else begin
    R := nil;
    uv_read_stop(h);
  end;
  if assigned(T.FRCB) then T.FRCB(R, S)
end;

function TUVStream.Read(F: TUVReadNotify): integer;
begin
  if assigned(F) then begin
    StreamData(uvstream^).FRCB := F;
    Result:=UVGet(function:integer begin
      Result := uv_read_start(uvstream^, ACB, RCB);
    end);
  end else Result := 0;
end;

function TUVStream.ReadStop: integer;
begin
  Result:=UVGet(function:integer begin
    Result := uv_read_stop(uvstream^);
  end);
end;

function TUVStream.SetBlocking(b: integer): integer;
begin
  Result := uv_stream_set_blocking(uvstream^, b);
end;

function TUVStream.ShutDown(F: TUVIntNotify): integer;
var
  P: PUVShutDown;
begin
  P := ShutDownPool.Get;
  P.FCB := F;
  Result:=UVGet(function:integer begin
    Result := uv_shutdown(P.S, uvstream, TUVShutDown.CB);
  end);
end;

function TUVStream.TryWrite(Buf: Pointer; size: integer): integer;
var
  b: uv_buf_t;
begin
  b.Base := Buf;
  b.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_try_write(uvstream^, @b, 1);
  end);
end;

function TUVStream.TryWrite2(Buf: Pointer; size: integer; S: TUVStream)
  : integer;
var
  b: uv_buf_t;
begin
  b.Base := Buf;
  b.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_try_write2(uvstream^, @b, 1, S.uvstream^);
  end);
end;

function TUVStream.uvstream: Puv_stream_t;
begin
  Result := Puv_stream_t(uvhandle);
end;

function TUVStream.Write(Buf: REFPTR; size: NativeInt;
F: TUVIntNotify): integer;
var
  P: PUVWrite;
begin
  P := WritePool.Get;
  P.FCB := F;
  P.buffer := Buf;
  P.Buf.Base := Buf;
  P.Buf.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_write(P.S, uvstream^, @P.Buf, 1, TUVWrite.CB);
  end);
end;

function TUVStream.Write2(Buf: REFPTR; size: NativeInt; S: TUVStream;
F: TUVIntNotify): integer;
var
  P: PUVWrite;
begin
  P := WritePool.Get;
  P.FCB := F;
  P.buffer := Buf;
  P.Buf.Base := Buf;
  P.Buf.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_write2(P.S, uvstream^, @P.Buf, 1, S.uvstream^, TUVWrite.CB);
  end);
end;

function TUVStream.Write(Buf: Pointer; size: NativeInt;
  F: TUVIntNotify): integer;
var
  P: PUVWrite;
begin
  P := WritePool.Get;
  P.FCB := F;
  P.Buf.Base := Buf;
  P.Buf.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_write(P.S, uvstream^, @P.Buf, 1, TUVWrite.CB);
  end);
end;

function TUVStream.Write2(Buf: Pointer; size: NativeInt; S: TUVStream;
  F: TUVIntNotify): integer;
var
  P: PUVWrite;
begin
  P := WritePool.Get;
  P.FCB := F;
  P.Buf.Base := Buf;
  P.Buf.Len := size;
  Result:=UVGet(function:integer begin
    Result := uv_write2(P.S, uvstream^, @P.Buf, 1, S.uvstream^, TUVWrite.CB);
  end);
end;

{ TUVShutDown }

class procedure TUVShutDown.CB(var R: uv_shutdown_t; st: integer);
var S : PUVShutDown;
begin
  S := @R;
  try
    with S^ do if assigned(FCB) then FCB(st);
  finally
    S.FCB := nil;
    ShutDownPool.Release(S);
  end;
end;

{ TUVWrite }

class procedure TUVWrite.CB(var R: uv_write_t; st: integer);
var W : PUVWrite;
begin
  W := @R;
  try
    with W^ do
      if assigned(FCB) then FCB(st);
  finally
    W.buffer := nil;
    W.FCB := nil;
    WritePool.Release(W);
  end;
end;

{ TUVStream<T> }

procedure TUVStream<T>.Init;
begin
  uv := Pool.Get;
end;

class procedure TUVStream<T>.ReleaseHandle(h : Pointer);
var S : PData;
begin
  S := h;
  S.S.FLCB := nil;
  S.S.FRCB := nil;
  S.S.FURCB := nil;
  S.S.FFSCB := nil;
  S.S.FPCB := nil;
  Pool.Release(h);
end;

class function TUVStream<T>.StreamData(var h): PUV_Stream;
begin
  Result := @PData(@h).S;
end;

function TUVStream<T>.uvhandle: Puv_handle_t;
begin
  Result := @UV.D.uvhande;
end;

{ TUVTCP }

function TUVTCP.Accept: TUVTCP;
begin
  Result := TUVTCP.Create(loop);
  if uv_accept(uv.D.uvstream,Result.uv.D.uvstream)<0 then begin
    Result.Free;
    Result := nil;
  end;
end;

function TUVTCP.Bind(const Bound : TUVADDR; flags: Cardinal):integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tcp_bind(uv.D.handle,@Bound,flags);
  end);
end;

procedure TUVTCP.close;
begin
  UVRun(procedure begin
    uv_tcp_close_reset(uv.D.handle,Close_CB);
  end);
end;

function TUVTCP.Connect(const Peer : TUVADDR; F: TUVIntNotify): integer;
var C : PUVConnect;
begin
  C := ConnectPool.Get;
  C.FCB := F;
  Result := UVGet(function : integer begin
    Result := uv_tcp_connect(C.S,uv.D.handle,@Peer,C.CB);
  end);
end;

constructor TUVTCP.Create(flags: Cardinal; L: TUVLoop);
begin
  fflags := flags;
  inherited Create(L);
end;

function TUVTCP.GetPeerName(var A: TUVAddr): integer;
var l : integer;
begin
  Result := uv_tcp_getpeername(uv.D.handle,@A,l);
end;

function TUVTCP.GetSockName(var A: TUVAddr): integer;
var l : integer;
begin
  Result := uv_tcp_getsockname(uv.D.handle,@A,l);
end;

procedure TUVTCP.Init;
begin
  inherited;
  if fflags = 0 then
    uv_tcp_init(loop.uvloop^, @UV.D.handle)
  else
    uv_tcp_init_ex(loop.uvloop^, UV.D.handle, fflags);
end;

function TUVTCP.KeepAlive(Enable, delay: integer): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tcp_keepalive(UV.D.handle, Enable, delay);
  end);
end;

function TUVTCP.NoDelay(Enable: integer): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tcp_nodelay(UV.D.handle, Enable);
  end);
end;

function TUVTCP.Open(sock: TUVSock): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tcp_open(UV.D.handle, sock);
  end);
end;

function TUVTCP.SimultaneousAccepts(Enable: integer): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tcp_simultaneous_accepts(UV.D.handle, Enable);
  end);
end;

function TUVTCP.SocketPair(tp, pt: integer; var s1, s2: TUVSock; f0,
  f1: uv_stdio_flags): integer;
var s : array[0..1] of TUVSock;
begin
  Result := uv_socketpair(tp,pt,s[0],ord(f0),ord(f1));
  s1 := s[0]; s2 := s[1];
end;

{ TUVADDR }

class function TUVADDR.From(S: String;P:Word): TUVADDR;
begin
  if S.IndexOf(':')>=0 then Result.SetV6(S,P)
  else Result.SetV4(S,P);
end;

function TUVADDR.GetAddressV4: String;
begin
  Result := IPV4ToString(v4.sin_addr.s_addr);
end;

function TUVADDR.GetAddressV6: String;
begin
 Result := IPV6ToString(v6.sin6_addr);
end;

procedure TUVADDR.SetAddressV4(const Value: String);
begin
  SAFamily := AF_INET;
  v4.sin_addr.s_addr := StringToIPV4(Value);
end;

procedure TUVADDR.SetAddressV6(const Value: String);
begin
  SAFamily := AF_INET6;
  StringToIPV6(Value,v6.sin6_addr);
end;

procedure TUVADDR.SetV4(const A: String; const P: Word);
begin
  AddressV4 := A;
  Port := P;
end;

procedure TUVADDR.SetV6(const A: String; const P: Word);
begin
  AddressV6 := A;
  Port := P;
end;

{ TUVConnect }

class procedure TUVConnect.CB(var R: uv_connect_t; st: integer);
var C : PUVConnect;
begin
  C :=@R;
  try
    with C^ do if assigned(FCB) then FCB(st);
  finally
    C.FCB := nil;
    ConnectPool.Release(C);
  end;
end;

{ TUVPipe }

function TUVPipe.Accept: TUVStream;
var UC : TUVStreamClass;
begin
  Result := nil;
  if PendingCount>0 then begin
    UC := UVStreamClass(PendingType);
    if UC<>nil then begin
      Result := UC.Create(loop);
      if uv_accept(uv.D.uvstream,Result.uvstream^)<>0 then begin
        Result.Free;
        Result := nil;
      end;
    end;
  end;
end;

function TUVPipe.Bind(S: String): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_pipe_bind(uv.D.handle,PAnsiChar(AnsiString(S)));
  end);
end;

procedure TUVPipe.Connect(Name: String; F: TUVIntNotify);
var C : PUVConnect;
begin
  C := ConnectPool.Get;
  C.FCB := F;
  UVRun(procedure begin
    uv_pipe_connect(C.S,uv.D.handle,PAnsiChar(AnsiString(Name)),C.CB);
  end);
end;

function TUVPipe.Chmod(flags: integer): integer;
begin
  Result := uv_pipe_chmod(uv.D.handle,flags);
end;

constructor TUVPipe.Creaet(ipc: boolean; L: TUVLoop);
begin
  fipc := not ipc;
  inherited Create(L);
end;

procedure TUVPipe.Init;
begin
  inherited;
  uv_pipe_init(loop.uvloop^,uv.D.handle,ord(not fipc));
end;

function TUVPipe.Open(f: TUVFile): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_pipe_open(uv.D.handle,f);
  end);
end;

function TUVPipe.PeerName: AnsiString;
var s : NativeUInt;
begin
  s := 2048;
  SetLength(Result,s);
  uv_pipe_getpeername(uv.D.handle,PAnsiChar(Result),s);
  SetLength(Result,s);
end;

function TUVPipe.PendingCount: integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_pipe_pending_count(uv.D.handle);
  end);
end;

procedure TUVPipe.PendingInstances(count: integer);
begin
  UVRun(procedure begin
    uv_pipe_pending_instances(uv.D.handle,count);
  end);
end;

function TUVPipe.PendingType: uv_handle_type;
begin
  Result := uv_pipe_pending_type(uv.D.handle);
end;

function TUVPipe.Pipe(var f1, f2: TUVFile; read_flags,
  write_flags: integer): integer;
var f : array[0..1] of TUVFile;
begin
  Result := uv_pipe(f[0],read_flags,write_flags);
  f1 := f[0]; f2 := f[1];
end;

function TUVPipe.SockName: AnsiString;
var s : NativeUInt;
begin
  s := 2048;
  SetLength(Result,s);
  uv_pipe_getsockname(uv.D.handle,PAnsiChar(Result),s);
  SetLength(Result,s);
end;

{ TUVTTY }

constructor TUVTTY.Create(fd: integer; Readable: boolean; L: TUVLoop);
begin
  ffd := fd;
  fnotreadable := not readable;
  inherited Create(L);
end;

class function TUVTTY.GetVtermState: uv_tty_vtermstate_t;
begin
  uv_tty_get_vterm_state(Result);
end;

function TUVTTY.Height: integer;
var h : integer;
begin
  uv_tty_get_winsize(uv.D.handle,Result,h);
end;

procedure TUVTTY.Init;
begin
  inherited;
  uv_tty_init(loop.uvloop^,uv.D.handle,ffd,ord(not fnotreadable));
end;

function TUVTTY.SetMode(M: uv_tty_mode_t): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_tty_set_mode(uv.D.handle, M);
  end);
end;

class procedure TUVTTY.SetVtermState(const Value: uv_tty_vtermstate_t);
begin
  uv_tty_set_vterm_state(Value);
end;

function TUVTTY.Width: integer;
var w : integer;
begin
  uv_tty_get_winsize(uv.D.handle,w,Result);
end;

{ TUVUDP }

function TUVUDP.Bind(const Addr: TUVAddr; flags: Cardinal): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_bind(uv.D.handle,@Addr,flags);
  end);
end;

function TUVUDP.Bound: TUVAddr;
var l : integer;
begin
  l := sizeof(Result);
  uv_udp_getsockname(uv.D.handle,@Result,l);
end;

function TUVUDP.Connect(const Addr: TUVAddr): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_connect(uv.D.handle,@Addr);
  end);
end;

constructor TUVUDP.Create(flags: integer; L: TUVLoop);
begin
  fflag := flags;
  inherited Create(L);
end;

function TUVUDP.GetSendQueueCount: NativeUInt;
begin
  Result := uv.D.handle.send_queue_count;
end;

function TUVUDP.GetSendQueueSize: NativeUInt;
begin
  Result := uv.D.handle.send_queue_size;
end;

procedure TUVUDP.Init;
begin
  inherited;
  if fflag=0 then uv_udp_init(loop.uvloop^,@uv.D.handle)
  else uv_udp_init_ex(loop.uvloop^,uv.D.handle,fflag);
end;

function TUVUDP.Open(sock: TUVSock): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_open(uv.D.handle,sock);
  end);
end;

function TUVUDP.Peer: TUVAddr;
var l : integer;
begin
  l := sizeof(Result);
  uv_udp_getpeername(uv.D.handle,@Result,l);
end;

function TUVUDP.RecvStart(F: TUVUDPRecvNotify): integer;
begin
  if assigned(F) then begin
    uv.S.FURCB := F;
    Result := UVGet(function :integer begin
      Result := uv_udp_recv_start(uv.D.handle,ACB,URCB);
    end);
  end;
end;

function TUVUDP.RecvStop: integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_recv_stop(uv.D.handle);
  end);
end;

class procedure TUVUDP.SCB(var H: uv_udp_send_t; status: integer);
var P:PUV_UDPSEND;
begin
  P := @H;
  try
    if assigned(P.FCB) then P.FCB(status);
  finally
    P.buf := nil;
    P.FCB := nil;
    SendPool.Release(P);
  end;
end;

function TUVUDP.Send(const Buf: Pointer; Size: Cardinal;
  const Addr: TUVAddr; F : TUVIntNotify) : integer;
var S : PUV_UDPSEND;
begin
  S := SendPool.Get;
  S.buffer.Base := Buf;
  S.buffer.len := Size;
  S.ADDR := Addr;
  S.FCB := F;
  Result := UVGet(function :integer begin
    Result := uv_udp_send(S.S,uv.D.handle,@S.buffer,1,@Addr,SCB);
  end);
end;

function TUVUDP.Send(const Buf: RefPtr; Size: Cardinal;
  const Addr: TUVAddr; F : TUVIntNotify) : integer;
var S : PUV_UDPSEND;
begin
  S := SendPool.Get;
  S.buf := Buf;
  S.buffer.Base := Buf;
  S.buffer.len := Size;
  S.ADDR := Addr;
  S.FCB := F;
  Result := UVGet(function :integer begin
    Result := uv_udp_send(S.S,uv.D.handle,@S.buffer,1,@Addr,SCB);
  end);
end;

function TUVUDP.SetBoardCastOn(O: Boolean): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_broadcast(uv.D.handle,ord(O));
  end);
end;

function TUVUDP.SetMemberShip(MultiCastAddr, InterfaceAddr: AnsiString;
  M: uv_membership): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_membership(uv.D.handle,PAnsiChar(MultiCastAddr),
      PAnsiChar(InterfaceAddr),M);
  end);
end;

function TUVUDP.SetMultiCastInterface(I: AnsiString): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_multicast_interface(uv.D.handle,PAnsiChar(I));
  end);
end;

function TUVUDP.SetMultiCastLoopOn(O: boolean): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_multicast_loop(uv.D.handle,ord(O));
  end);
end;

function TUVUDP.SetMultiCastTTL(T: integer): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_multicast_ttl(uv.D.handle,T);
  end);
end;

function TUVUDP.SetSourceMemberShip(MultiCastAddr, InterfaceAddr, SourceAddr
  : AnsiString; M: uv_membership): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_source_membership(uv.D.handle,PAnsiChar(MultiCastAddr),
      PAnsiChar(InterfaceAddr),PAnsiChar(SourceAddr),M);
  end);
end;

function TUVUDP.SetTTL(T: integer): integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_udp_set_ttl(uv.D.handle,T);
  end);
end;

function TUVUDP.TrySend(const Buf: Pointer; Size: Cardinal; const Addr:
  TUVAddr): integer;
var b : uv_buf_t;
begin
  b.Base := @Buf;
  b.len := Size;
  Result := UVGet(function : integer begin
    Result := uv_udp_try_send(uv.D.handle,@b,1,@Addr);
  end);
end;

class procedure TUVUDP.URCB(var handle: uv_udp_t; nread: ssize_t;
      const buf: Puv_buf_t; const addr: PSOCKADDR; flags: Cardinal);
var P : PData;
    B : REFPTR;
begin
  P := @handle;
  if nread>0 then B := buf.Base;
  if assigned(P.S.FURCB) then P.S.FURCB(B,nread,PUVAddr(addr)^,flags);
end;

function TUVUDP.UsingRecvMMsg: boolean;
begin
  Result := boolean(uv_udp_using_recvmmsg(uv.D.handle));
end;

{ TUVThread }

constructor TUVThread.Create(L: TUVLoop; Paused: Boolean);
begin
  FLoop := L;
  inherited Create(Paused);
end;

procedure TUVThread.Execute;
begin
  FLoop.Run;
end;

procedure TUVThread.Quit;
begin
  Run(procedure begin
    FLoop.Stop;
  end);
  Self.WaitFor;
end;

function TUVThread.Get(F: TUVRetNotify): integer;
begin
  Result := FLoop.UVGet(F);
end;

procedure TUVThread.Run(F: TUVNotify);
begin
  FLoop.UVRun(F);
end;

{ TUVFSEvent }

class procedure TUVFSEvent.FSCB(var h: uv_fs_event_t; const filename: PAnsiChar;
  events, status: integer);
var F : PDATA;
begin
  F := @h;
  if assigned(F.S.FFSCB) then F.S.FFSCB(filename,events,status);
end;

procedure TUVFSEvent.Init;
begin
  inherited;
  uv_fs_event_init(loop.uvloop^,@uv.D.handle);
end;

function TUVFSEvent.Path: String;
var P : AnsiString;
    l : NativeUInt;
begin
  SetLength(P,1000);
  l := 1000;
  uv_fs_event_getpath(uv.D.handle,PAnsiChar(P),l);
  SetLength(P,l);
  Result := P;
end;

function TUVFSEvent.Start(Path : String; flags: Cardinal; F: TUVStrIntIntNotify): integer;
var P : AnsiString;
begin
  if assigned(F) then begin
    uv.S.FFSCB := F;
    P := AnsiString(Path);
    Result := UVGet(function : integer begin
      Result := uv_fs_event_start(uv.D.handle,FSCB,PAnsiChar(P),flags);
    end);
  end else Result := 0;
end;

function TUVFSEvent.Stop: integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_fs_event_stop(uv.D.handle);
  end);
end;

{ TUVFSPoll }

procedure TUVFSPoll.Init;
begin
  inherited;
  uv_fs_poll_init(loop.uvloop^,uv.D.handle);
end;

function TUVFSPoll.Path: String;
var P : AnsiString;
    l : NativeUInt;
begin
  SetLength(P,1000);
  l := 1000;
  uv_fs_poll_getpath(uv.D.handle,PAnsiChar(P),l);
  SetLength(P,l);
  Result := P;
end;

class procedure TUVFSPoll.PCB(var h: uv_fs_poll_t; status: integer; const prev,
  curr: uv_stat_t);
var P : PData;
begin
  P := @h;
  if assigned(P.S.FPCB) then P.S.FPCB(status,prev,curr);
end;

function TUVFSPoll.Start(Path: AnsiString; interval: Cardinal;
  F: TUVPollNotify): integer;
begin
  if assigned(F) then begin
    uv.S.FPCB := F;
    Result := UVGet(function : integer begin
      Result := uv_fs_poll_start(uv.D.handle,PCB,PAnsiChar(Path),interval);
    end);
  end else Result := 0;
end;

function TUVFSPoll.Stop: integer;
begin
  Result := UVGet(function : integer begin
    Result := uv_fs_poll_stop(uv.D.handle);
  end);
end;

initialization
finalization
  uv_tty_reset_mode;
end.
