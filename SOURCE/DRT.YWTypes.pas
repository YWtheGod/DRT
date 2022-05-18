unit DRT.YWTypes;

interface

uses sysutils, Classes;

type
  __T1 = array [0 .. 0] of byte;
  __T2 = array [0 .. 1] of byte;
  __T3 = array [0 .. 2] of byte;
  __T4 = array [0 .. 3] of byte;
  __T5 = array [0 .. 4] of byte;
  __T6 = array [0 .. 5] of byte;
  __T7 = array [0 .. 6] of byte;
  __T8 = array [0 .. 7] of byte;
  __T9 = array [0 .. 8] of byte;
  __T10 = array [0 .. 9] of byte;
  __T11 = array [0 .. 10] of byte;
  __T12 = array [0 .. 11] of byte;
  __T13 = array [0 .. 12] of byte;
  __T14 = array [0 .. 13] of byte;
  __T15 = array [0 .. 14] of byte;
  __T16 = array [0 .. 15] of byte;

TBufferPool < T >= record

const
  BufferSize = 1 shl (11 + sizeof(T));
  class var [volatile] buf: Pointer;
class function GetBuffer: Pointer; static; inline;
class procedure FreeBuffer(var B: Pointer); static; inline;
class constructor Create;
class destructor Destroy;
end;

BufferPool4k = TBufferPool<__T1>;
BufferPool16k = TBufferPool<__T3>;
BufferPool64k = TBufferPool<__T5>;
BufferPool128k = TBufferPool<__T6>;
BufferPool256k = TBufferPool<__T7>;
BufferPool512k = TBufferPool<__T8>;
BufferPool1M = TBufferPool<__T9>;
BufferPool2M = TBufferPool<__T10>;
BufferPool4M = TBufferPool<__T11>;

TLock=record
  [volatile]
  lock : Cardinal;
  procedure Enter; inline;
  procedure Leave; inline;
  class operator Initialize(out Dest: TLock);
end;

TStack<T> = record

const
  _StackSize = (1 shl sizeof(T) * 3) * 8 - 1;
  StackSize = 511;
var
  [volatile]
  head: Integer;
  lock: TLock;
  [volatile]
  Data: array [0 .. StackSize] of Pointer;

  function Put(const V: Pointer): boolean; inline;
  function Get: Pointer; inline;
  class operator Initialize(out Dest: TStack<T>);
end;

TRingQueue<T> = record
const
  QueueSize = 511;
  _QueueSize = (1 shl (sizeof(T) * 3)) * 8 - 1;
var
  [volatile]
  head: Integer;
  [volatile]
  tail: Integer;
  [volatile]
  Count: Integer;
  [volatile]
  Count2: Integer;
  [volatile]
  Data: array [0 .. QueueSize] of Pointer;
  function Put(const V: Pointer): boolean; inline;
  function Get: Pointer; inline;
  class operator Initialize(out Dest: TRingQueue<T>);
end;

TPool<T:Record; T1>= record
type
  PT = ^T;
var
  Data : TRingQueue<T1>;
  function Get : Pointer; inline;
  procedure Release(const P : Pointer); inline;
  class operator Finalize(var Dest : TPool<T,T1>);
end;



    TRingQueue64 = TRingQueue<__T1>;
    TRingQueue512 = TRingQueue<__T2>;
    TRingQueue4k = TRingQueue<__T3>;
    TRingQueue256k = TRingQueue<__T5>;

    __RWLock<T> = record private[volatile] R: Cardinal;
    [volatile]
  WW:
    Cardinal;
    [volatile]
  W:
    TThreadID;
    public const
      NeedSleep = sizeof(T) <= 2;
      class
      procedure idle;
      inline;
      static;
      class operator Initialize(out Dest: __RWLock<T>);
      class operator Finalize(var Dest: __RWLock<T>);
      procedure BeginRead;
      inline;
      procedure EndRead;
      inline;
      procedure BeginWrite;
      inline;
      procedure EndWrite;
      inline;
      procedure UpgradeToWrite;
      inline;
      procedure DownGradeToRead;
      inline;
      end;

      RWLock = __RWLock<__T3>;
      RWLock4Calc = __RWLock<__T1>;
      RWLock4IO = __RWLock<__T2>;

      __PRefPtr = ^__PRef;
      __PRef = record private[volatile] RefCount: Cardinal;
      [volatile]
      WeakRefCount: Cardinal;
    public
      RefPtr: Pointer;
      procedure AddRef; inline;
      procedure RemoveRef; inline;
      procedure AddWeakRef; inline;
      procedure RemoveWeakRef; inline;
      class operator Initialize(out Dest: __PRef);
      end;

      RefPtr = record
      private
        GuardRef : __PRefPtr;
      public
        class operator Implicit(a: Pointer): RefPtr; inline;
        class operator Implicit(a: RefPtr): Pointer; inline;
        class operator Equal(a, B: RefPtr): boolean; inline;
        class operator Implicit(a : RefPtr) : NativeInt; inline;
        class operator Implicit(a : RefPtr) : Boolean; inline;
        class operator NotEqual(a, B: RefPtr): boolean; inline;
        procedure Alloc(S :NativeInt); inline;
        procedure Calloc(S :NativeInt); inline;
        procedure Realloc(S :NativeInt); inline;
        function PTR : Pointer; inline;
        function Int : NativeInt; inline;
        class operator Initialize(out Dest: RefPtr);
        class operator Finalize(var Dest: RefPtr);
        class operator Assign(var Dest: RefPtr; const [ref] Src: RefPtr);  inline;
      end;

      WRefPtr = record
      private
        GuardRef : __PRefPtr;
      public
        class operator Implicit(a: RefPtr): WRefPtr; inline;
        class operator Implicit(a: WRefPtr): RefPtr; inline;
        class operator Implicit(a: WRefPtr): Pointer; inline;
        class operator Implicit(a : WRefPtr) : NativeInt; inline;
        class operator Implicit(a : WRefPtr) : Boolean; inline;
        function PTR : Pointer; inline;
        function Int : NativeInt; inline;
        class operator Equal(a, B: WRefPtr): boolean; inline;
        class operator NotEqual(a, B: WRefPtr): boolean; inline;
        class operator Initialize(out Dest: WRefPtr);
        class operator Finalize(var Dest: WRefPtr);
        class operator Assign(var Dest: WRefPtr; const [ref] Src: WRefPtr);  inline;
      end;

      __RefPtr = ^__Ref;
      __Ref = record private[volatile] RefCount: Cardinal;
      [volatile]
      WeakRefCount: Cardinal;
    public
      RefObj: TObject;
      procedure AddRef;
      inline;
      procedure RemoveRef;
      inline;
      procedure AddWeakRef;
      inline;
      procedure RemoveWeakRef;
      inline;
      class operator Initialize(out Dest: __Ref);
      end;

      R<T: class> = record private
{$IFNDEF AUTOREFCOUNT}
        GuardRef: __RefPtr;
{$ELSE}
        obj: T;
{$ENDIF}
    public
      function O: T; inline;
      class operator Implicit(a: T): R<T>; inline;
      class operator Implicit(a: R<T>): T; inline;
      class operator Equal(a, B: R<T>): boolean; inline;
      class operator NotEqual(a, B: R<T>): boolean; inline;
      class operator Equal(a: R<T>; B: Pointer): boolean; inline;
      class operator NotEqual(a: R<T>; B: Pointer): boolean; inline;
      class operator Equal(a: R<T>; B: T): boolean; inline;
      class operator NotEqual(a: R<T>; B: T): boolean; inline;
      class operator Positive(a: R<T>): T; inline;
{$IFNDEF AUTOREFCOUNT}
      class operator Initialize(out Dest: R<T>);
      class operator Finalize(var Dest: R<T>);
      class operator Assign(var Dest: R<T>; const [ref] Src: R<T>);
      inline;
{$ENDIF}
      end;

      WR<T: class> = record private
{$IFNDEF AUTOREFCOUNT}
        GuardRef: __RefPtr;
{$ELSE}
      [WEAK]
      obj: T;
{$ENDIF}
    public
      function O: T;
      inline;
      class operator Implicit(a: WR<T>): R<T>; inline;
      class operator Implicit(a: WR<T>): T; inline;
      class operator Implicit(a: R<T>): WR<T>; inline;
      class operator Equal(a, B: WR<T>): boolean; inline;
      class operator NotEqual(a, B: WR<T>): boolean; inline;
      class operator Equal(a: WR<T>; B: Pointer): boolean; inline;
      class operator NotEqual(a: WR<T>; B: Pointer): boolean; inline;
      class operator Equal(a: WR<T>; B: T): boolean; inline;
      class operator NotEqual(a: WR<T>; B: T): boolean; inline;
      class operator Equal(a: WR<T>; B: R<T>): boolean; inline;
      class operator NotEqual(a: WR<T>; B: R<T>): boolean; inline;
      class operator Positive(a: WR<T>): T; inline;
{$IFNDEF AUTOREFCOUNT}
      class operator Initialize(out Dest: WR<T>);
      class operator Finalize(var Dest: WR<T>);
      class operator Assign(var Dest: WR<T>; const [ref] Src: WR<T>);
      inline;
{$ENDIF}
      end;
  TTaskResult = (StillWorking,AllDone,Canceled,JustCancel,JustDone);
  TTaskSyncData = record
    RefCount,TaskCount : integer;
    ResultValue : TTaskResult;
    OnFinish : TProc;
  end;
  PTaskSyncData = ^TTaskSyncData;
  TaskSyncer = record
  private
  class var
    DataPool : TPool<TTaskSyncData,__T2>;
  var
    Data : PTaskSyncData;
    procedure CheckData; inline;
    procedure AddRef; inline;
    procedure RemoveRef; inline;
  public
    procedure AddTask; overload; inline;
    procedure AddTask(const i : integer); overload; inline;
    procedure OnAllDone(F : TProc); inline;
    function Cancel(F: TProc):TTaskResult; inline;
    function DoneTask : TTaskResult; inline;
    class operator Initialize(out Dest: TaskSyncer);
    class operator Finalize(var Dest: TaskSyncer);
    class operator Assign(var Dest: TaskSyncer; const [ref] Src: TaskSyncer); inline;
  end;

var
  __RefPool : TPool<__Ref,__T3>;
  __PRefPool : TPool<__PRef,__T3>;

implementation

{ TRingQueue<T> }

function TRingQueue<T>.Get: Pointer;
begin
  if Count2<=0 then exit(nil);
  if atomicdecrement(Count)<0 then begin
    atomicincrement(Count);
    exit(nil);
  end;
  Result := Data[(atomicincrement(tail)-1) and queuesize];
  atomicdecrement(Count2);
end;

class operator TRingQueue<T>.Initialize(out Dest: TRingQueue<T>);
begin
  Dest.head := 0;
  Dest.tail := 0;
  Dest.Count := 0;
  Dest.Count2 := 0;
end;

function TRingQueue<T>.Put(const V: Pointer): boolean;
begin
  if (V = nil)or(Count2>QueueSize) then
    exit(false); // No Nil Pointer allowed
  if atomicincrement(Count)>QueueSize+1 then begin
    atomicdecrement(Count);
    exit(false);
  end;
  Data[(atomicincrement(head)-1) and queuesize] := V;
  atomicincrement(Count2);
  Result := true;
end;

{ _RWLock }

procedure __RWLock<T>.BeginRead;
begin
  if W = TThread.Current.ThreadID then
    exit;
  repeat
    while WW > 0 do
      idle;
    atomicincrement(R);
    if WW = 0 then
      break;
    atomicdecrement(R);
    idle;
  until false;
end;

procedure __RWLock<T>.BeginWrite;
begin
  if W = TThread.Current.ThreadID then
    exit;
  atomicincrement(WW);
  repeat
    while (R > 0) or (W <> 0) do
      idle;
    if atomiccmpexchange(W, TThread.Current.ThreadID, 0) = 0 then
      break;
  until false;
end;

procedure __RWLock<T>.DownGradeToRead;
begin
  if W <> TThread.Current.ThreadID then
    BeginRead
  else
  begin
    atomicincrement(R);
    W := 0;
    atomicdecrement(WW);
  end;
end;

procedure __RWLock<T>.EndRead;
begin
  if W = 0 then
    atomicdecrement(R);
end;

procedure __RWLock<T>.EndWrite;
begin
  if W = TThread.Current.ThreadID then
  begin
    W := 0;
    atomicdecrement(WW);
  end;
end;

class operator __RWLock<T>.Finalize(var Dest: __RWLock<T>);
begin
  while Dest.R or Dest.WW <> 0 do
    idle;
end;

class procedure __RWLock<T>.idle;
begin
  if NeedSleep then
    sleep(sizeof(T) - 1);
end;

class operator __RWLock<T>.Initialize(out Dest: __RWLock<T>);
begin
  Dest.R := 0;
  Dest.WW := 0;
  Dest.W := 0;
end;

procedure __RWLock<T>.UpgradeToWrite;
begin
  if W <> 0 then
    BeginWrite
  else
  begin
    atomicincrement(WW);
    while R > 1 do
      idle;
    W := TThread.Current.ThreadID;
    atomicdecrement(R);
  end;
end;

{ __Ref }

procedure __Ref.AddRef;
begin
  atomicincrement(RefCount);
end;

procedure __Ref.AddWeakRef;
begin
  atomicincrement(WeakRefCount);
end;

class operator __Ref.Initialize(out Dest: __Ref);
begin
  Dest.WeakRefCount := 0;
end;

procedure __Ref.RemoveRef;
begin
  if atomicdecrement(RefCount) = 0 then begin
    RefObj.DisposeOf;
    RefObj := nil;
    if WeakRefCount=0 then __RefPool.Release(@self);
  end;
end;

procedure __Ref.RemoveWeakRef;
begin
  AddRef;
  atomicdecrement(WeakRefCount);
  RemoveRef;
end;

{ R<T> }

{$IFNDEF AUTOREFCOUNT}

class operator R<T>.Assign(var Dest: R<T>; const [ref] Src: R<T>);
begin
  if Dest.GuardRef <> nil then
    Dest.GuardRef.RemoveRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef <> nil then
    Dest.GuardRef.AddRef;
end;

class operator R<T>.Initialize(out Dest: R<T>);
begin
  Dest.GuardRef := nil;
end;

class operator R<T>.Finalize(var Dest: R<T>);
begin
  if Dest.GuardRef <> nil then
    Dest.GuardRef.RemoveRef;
end;
{$ENDIF}

class operator R<T>.Equal(a: R<T>; B: T): boolean;
begin
  Result := B = a.O;
end;

class operator R<T>.Equal(a: R<T>; B: Pointer): boolean;
begin
  Result := B = Pointer(a.O);
end;

class operator R<T>.Equal(a, B: R<T>): boolean;
begin
  Result := a.O = B.O;
end;

class operator R<T>.Implicit(a: R<T>): T;
begin
  Result := a.O;
end;

class operator R<T>.Implicit(a: T): R<T>;
begin
{$IFDEF AUTOREFCOUNT}
  Result.obj := a;
{$ELSE}
  if a <> nil then
  begin
    Result.GuardRef := __RefPool.Get;
    Result.GuardRef.RefObj := a;
    Result.GuardRef.RefCount := 1;
  end;
{$ENDIF}
end;

class operator R<T>.NotEqual(a: R<T>; B: Pointer): boolean;
begin
  Result := B <> Pointer(a.O);
end;

class operator R<T>.NotEqual(a: R<T>; B: T): boolean;
begin
  Result := B <> a.O;
end;

class operator R<T>.NotEqual(a, B: R<T>): boolean;
begin
  Result := a.O <> B.O;
end;

function R<T>.O: T;
begin
{$IFDEF AUTOREFCOUNT}
  Result := obj;
{$ELSE}
  Result := nil;
  if GuardRef <> nil then
    Result := T(GuardRef.RefObj);
{$ENDIF}
end;

class operator R<T>.Positive(a: R<T>): T;
begin
  Result := a.O;
end;

{ WR<T> }

class operator WR<T>.Equal(a: WR<T>; B: R<T>): boolean;
begin
  Result := a.O = B.O;
end;

class operator WR<T>.Equal(a: WR<T>; B: T): boolean;
begin
  Result := a.O = B;
end;

class operator WR<T>.Equal(a: WR<T>; B: Pointer): boolean;
begin
  Result := Pointer(a.O) = B;
end;

class operator WR<T>.Equal(a, B: WR<T>): boolean;
begin
  Result := a.O = B.O;
end;

{$IFNDEF AUTOREFCOUNT}

class operator WR<T>.Initialize(out Dest: WR<T>);
begin
  Dest.GuardRef := nil;
end;

class operator WR<T>.Finalize(var Dest: WR<T>);
begin
  if Dest.GuardRef <> nil then
    Dest.GuardRef.RemoveWeakRef;
end;

class operator WR<T>.Assign(var Dest: WR<T>; const [ref] Src: WR<T>);
begin
  if Dest.GuardRef <> nil then
    Dest.GuardRef.RemoveWeakRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef <> nil then
    Dest.GuardRef.AddWeakRef;
end;
{$ENDIF}

class operator WR<T>.Implicit(a: R<T>): WR<T>;
begin
{$IFDEF AUTOREFCOUNT}
  Result.obj := a.O;
{$ELSE}
  Result.GuardRef := a.GuardRef;
  if Result.GuardRef <> nil then
    Result.GuardRef.AddWeakRef;
{$ENDIF}
end;

class operator WR<T>.Implicit(a: WR<T>): T;
begin
  Result := A.O;
end;

class operator WR<T>.Implicit(a: WR<T>): R<T>;
begin
{$IFDEF AUTOREFCOUNT}
  Result.obj := a.O;
{$ELSE}
  Result.GuardRef := a.GuardRef;
  if Result.GuardRef <> nil then
    Result.GuardRef.AddRef;
{$ENDIF}
end;

class operator WR<T>.NotEqual(a, B: WR<T>): boolean;
begin
  Result := a.O <> B.O;
end;

class operator WR<T>.NotEqual(a: WR<T>; B: Pointer): boolean;
begin
  Result := Pointer(a.O) <> B;
end;

class operator WR<T>.NotEqual(a: WR<T>; B: R<T>): boolean;
begin
  Result := a.O <> B.O;
end;

class operator WR<T>.NotEqual(a: WR<T>; B: T): boolean;
begin
  Result := a.O <> B;
end;

function WR<T>.O: T;
begin
{$IFDEF AUTOREFCOUNT}
  Result := obj;
{$ELSE}
  Result := nil;
  if GuardRef <> nil then
    Result := T(GuardRef.RefObj);
{$ENDIF}
end;

class operator WR<T>.Positive(a: WR<T>): T;
begin
  Result := a.O;
end;

{ TBufferPool<T> }

class constructor TBufferPool<T>.Create;
begin
  buf := nil;
end;

class destructor TBufferPool<T>.Destroy;
begin
  if buf <> nil then
    Freemem(buf);
end;

class procedure TBufferPool<T>.FreeBuffer(var B: Pointer);
begin
  B := AtomicExchange(buf, B);
  if B <> nil then
    Freemem(B);
end;

class function TBufferPool<T>.GetBuffer: Pointer;
begin
  Result := nil;
  Result := AtomicExchange(buf, Result);
  if Result = nil then
    Getmem(Result, BufferSize);
end;

{ TStack<T> }

function TStack<T>.Get: Pointer;
begin
  Result := nil;
  if head > 0 then begin
    Lock.Enter;
    if head > 0 then begin
      dec(head);
      Result := Data[head];
    end;
    Lock.Leave;
  end;
end;

class operator TStack<T>.Initialize(out Dest: TStack<T>);
begin
  Dest.head := 0;
end;

function TStack<T>.Put(const V: Pointer): boolean;
begin
  Result := false;
  if head <= StackSize then begin
    Lock.Enter;
    if head <= StackSize then begin
      Data[head] := V;
      inc(head);
      Result := true;
    end;
    Lock.Leave;
  end;
end;

{ TLock }

procedure TLock.Enter;
var n : integer;
begin
  n := 0;
  while atomicincrement(lock)>1 do begin
    atomicdecrement(lock);
    inc(n);
    if n>10000 then sleep(1)
    else if n>1000 then sleep(0);
  end;
end;

class operator TLock.Initialize(out Dest: TLock);
begin
  Dest.lock := 0;
end;

procedure TLock.Leave;
begin
  atomicdecrement(lock);
end;

{ TPool<T, T1> }

class operator TPool<T, T1>.Finalize(var Dest: TPool<T, T1>);
var a : PT;
begin
  a := Dest.Data.Get;
  while a<>nil do begin
    dispose(A);
    a := Dest.Data.Get;
  end;
end;

function TPool<T, T1>.Get: Pointer;
begin
  Result := PT(Data.Get);
  if Result=nil then new(PT(Result));
end;

procedure TPool<T, T1>.Release(const P: Pointer);
begin
 if not Data.Put(P) then dispose(PT(P));
end;

{ __PRef }

procedure __PRef.AddRef;
begin
  atomicincrement(RefCount);
end;

procedure __PRef.AddWeakRef;
begin
  atomicincrement(WeakRefCount);
end;

class operator __PRef.Initialize(out Dest: __PRef);
begin
  Dest.WeakRefCount := 0;
end;

procedure __PRef.RemoveRef;
begin
  if atomicdecrement(RefCount)=0 then begin
    FreeMem(RefPtr);
    RefPtr := nil;
    if WeakRefCount=0 then __PrefPool.Release(@self);
  end;
end;

procedure __PRef.RemoveWeakRef;
begin
  AddRef;
  atomicdecrement(WeakRefCount);
  RemoveRef;
end;

{ RefPtr }

procedure RefPtr.Alloc(S: NativeInt);
begin
  if GuardRef<>nil then GuardRef.RemoveRef;
  if S>0 then begin
    var P : Pointer;
    GetMem(P,S);
    GuardRef := __PRefPool.Get;
    GuardRef.RefPtr := P;
    GuardRef.RefCount := 1;
  end else GuardRef := nil;
end;

class operator RefPtr.Assign(var Dest: RefPtr; const [ref]Src: RefPtr);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef<>nil then Dest.GuardRef.AddRef;
end;

procedure RefPtr.Calloc(S: NativeInt);
begin
  if GuardRef<>nil then GuardRef.RemoveRef;
  if S>0 then begin
    var P : Pointer;
    P := AllocMem(S);
    GuardRef := __PRefPool.Get;
    GuardRef.RefPtr := P;
    GuardRef.RefCount := 1;
  end else GuardRef := nil;
end;

class operator RefPtr.Equal(a, B: RefPtr): boolean;
begin
  Result := a.PTR = b.PTR;
end;

class operator RefPtr.Finalize(var Dest: RefPtr);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveRef;
end;

class operator RefPtr.Implicit(a: RefPtr): Pointer;
begin
  Result := a.PTR;
end;

class operator RefPtr.Implicit(a: Pointer): RefPtr;
begin
  if a<>nil then begin
    Result.GuardRef := __PRefPool.Get;
    Result.GuardRef.RefPtr := a;
    Result.GuardRef.RefCount := 1;
  end;
end;

class operator RefPtr.Initialize(out Dest: RefPtr);
begin
  Dest.GuardRef := nil;
end;

function RefPtr.Int: NativeInt;
begin
  Result := NativeInt(PTR);
end;

class operator RefPtr.NotEqual(a, B: RefPtr): boolean;
begin
  Result := a.PTR<>b.PTR;
end;

class operator RefPtr.Implicit(a: RefPtr): NativeInt;
begin
  Result := a.Int;
end;

function RefPtr.PTR: Pointer;
begin
  Result := nil;
  if GuardRef<>nil then Result := GuardRef.RefPtr;
end;

procedure RefPtr.Realloc(S: NativeInt);
begin
  if GuardRef=nil then Alloc(S)
  else ReallocMem(GuardRef.RefPtr,S);
end;

class operator RefPtr.Implicit(a: RefPtr): Boolean;
begin
  Result := a.PTR<>nil;
end;

{ WRefPtr }

class operator WRefPtr.Assign(var Dest: WRefPtr; const [ref]Src: WRefPtr);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveWeakRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef<>nil then Dest.GuardRef.AddWeakRef;
end;

class operator WRefPtr.Equal(a, B: WRefPtr): boolean;
begin
  Result := a.PTR = b.PTR;
end;

class operator WRefPtr.Finalize(var Dest: WRefPtr);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveWeakRef;
end;

class operator WRefPtr.Implicit(a: RefPtr): WRefPtr;
begin
  Result.GuardRef := a.GuardRef;
  Result.GuardRef.AddWeakRef;
end;

class operator WRefPtr.Implicit(a: WRefPtr): RefPtr;
begin
  Result.GuardRef := a.GuardRef;
  Result.GuardRef.AddRef;
end;

class operator WRefPtr.Implicit(a: WRefPtr): Pointer;
begin
  Result := a.PTR;
end;

class operator WRefPtr.Implicit(a: WRefPtr): NativeInt;
begin
  Result := a.Int;
end;

class operator WRefPtr.Initialize(out Dest: WRefPtr);
begin
  Dest.GuardRef := nil;
end;

function WRefPtr.Int: NativeInt;
begin
  Result := NativeInt(PTR);
end;

class operator WRefPtr.NotEqual(a, B: WRefPtr): boolean;
begin
  Result := a.PTR<>b.PTR;
end;

function WRefPtr.PTR: Pointer;
begin
  Result := nil;
  if GuardRef<>nil then Result := GuardRef.RefPtr;
end;

class operator WRefPtr.Implicit(a: WRefPtr): Boolean;
begin
  Result := a.PTR<>nil;
end;

{ TaskSyncer }

procedure TaskSyncer.AddRef;
begin
  if Data<>nil then atomicincrement(Data.RefCount);
end;

procedure TaskSyncer.AddTask;
begin
  CheckData;
  atomicincrement(Data.TaskCount);
end;

procedure TaskSyncer.AddTask(const i: integer);
begin
  CheckData;
  atomicincrement(Data.TaskCount,i);
end;

class operator TaskSyncer.Assign(var Dest: TaskSyncer;
  const [ref]Src: TaskSyncer);
begin
  Dest.RemoveRef;
  Dest.Data := Src.Data;
  Dest.AddRef;
end;

function TaskSyncer.Cancel(F: TProc): TTaskResult;
begin
  CheckData;
  Result := TTaskResult(atomiccmpexchange(PCardinal(Data.ResultValue)^,
    ord(Canceled), ord(StillWorking)));
  if Result=StillWorking then begin
    try
      if assigned(F) then F;
    except on E: Exception do
    end;
    Result := JustCancel;
  end;
end;

procedure TaskSyncer.CheckData;
begin
  if Data=nil then begin
    Data := DataPool.Get;
    Data.RefCount := 1;
    Data.TaskCount := 0;
    Data.ResultValue := StillWorking;
    Data.OnFinish := nil;
  end;
end;

function TaskSyncer.DoneTask: TTaskResult;
begin
  CheckData;
  Result := StillWorking;
  if atomicdecrement(Data.TaskCount)<=0 then begin
    Result := TTaskResult(atomiccmpexchange(PCardinal(@Data.ResultValue)^,
      ord(AllDone),ord(StillWorking)));
    if Result=StillWorking then begin
      Result := justDone;
      try
        if assigned(Data.OnFinish) then Data.OnFinish();
      except on E: Exception do
      end;
    end;
  end;
end;

class operator TaskSyncer.Finalize(var Dest: TaskSyncer);
begin
  Dest.RemoveRef;
end;

class operator TaskSyncer.Initialize(out Dest: TaskSyncer);
begin
  Dest.Data := nil;
end;

procedure TaskSyncer.OnAllDone(F: TProc);
begin
  CheckData;
  Data.OnFinish := F;
end;

procedure TaskSyncer.RemoveRef;
begin
  if assigned(Data) then if atomicdecrement(Data.RefCount)=0 then begin
    DataPool.Release(Data);
    Data := nil;
  end;
end;

end.
