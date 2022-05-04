unit DRT.YWTypes;

interface
uses sysutils,Classes;
type
  __T1 = array[0..0] of byte;
  __T2 = array[0..1] of byte;
  __T3 = array[0..2] of byte;
  __T4 = array[0..3] of byte;
  __T5 = array[0..4] of byte;
  __T6 = array[0..5] of byte;
  __T7 = array[0..6] of byte;
  __T8 = array[0..7] of byte;
  __T9 = array[0..8] of byte;
  __T10 = array[0..9] of byte;
  __T11 = array[0..10] of byte;
  __T12 = array[0..11] of byte;
  __T13 = array[0..12] of byte;
  __T14 = array[0..13] of byte;
  __T15 = array[0..14] of byte;
  __T16 = array[0..15] of byte;

  TBufferPool<T>=record
  const BufferSize = 1 shl (11+sizeof(T));
  class var
    [volatile]buf : Pointer;
  class function GetBuffer : Pointer; static; inline;
  class procedure FreeBuffer(var B : Pointer); static; inline;
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

  TRingQueue<T> = record
  const
    QueueSize = (1 shl sizeof(T)*3)*8-1;
  var
    [volatile]head : Integer;
    [volatile]tail : Integer;
    [volatile]Data : array[0..QueueSize] of Pointer;
    procedure Init; inline;
    function Put(const V : Pointer):boolean; inline;
    function Get:Pointer; inline;
    class operator Initialize (out Dest : TRingQueue<T>);
  end;

  TRingQueue64 = TRingQueue<__T1>;
  TRingQueue512 = TRingQueue<__T2>;
  TRingQueue4k = TRingQueue<__T3>;
  TRingQueue256k = TRingQueue<__T5>;

  __RWLock<T> =record
  private
    [volatile]R : Cardinal;
    [volatile]WW : Cardinal;
    [volatile]W : TThreadID;
  public
    const NeedSleep = sizeof(T)<=2;
    class procedure idle; inline; static;
    class operator Initialize (out Dest: __RWLock<T>);
    class operator Finalize (var Dest: __RWLock<T>);
    procedure BeginRead; inline;
    procedure EndRead; inline;
    procedure BeginWrite; inline;
    procedure EndWrite; inline;
    procedure UpgradeToWrite; inline;
    procedure DownGradeToRead; inline;
  end;

  RWLock = __RWLock<__T3>;
  RWLock4Calc = __RWLock<__T1>;
  RWLock4IO = __RWLock<__T2>;

  __RefPtr = ^__Ref;
  __Ref = record
  private
    [volatile]RefCount : Cardinal;
    [volatile]WeakRefCount : Cardinal;
  public
    RefObj : TObject;
    procedure AddRef; inline;
    procedure RemoveRef; inline;
    procedure AddWeakRef; inline;
    procedure RemoveWeakRef; inline;
    class operator Initialize (out Dest: __Ref);
  end;

  R<T : class> =record
  private
  {$IFNDEF AUTOREFCOUNT}
    GuardRef : __RefPtr;
  {$ELSE}
    obj : T;
  {$ENDIF}
  public
    function O : T; inline;
    class operator Implicit(a: T): R<T>; inline;
    class operator Implicit(a: R<T>): T; inline;
    class operator Equal(a, b: R<T>) : Boolean;  inline;
    class operator NotEqual(a, b: R<T>) : Boolean;  inline;
    class operator Equal(a : R<T>; b: Pointer) : Boolean;  inline;
    class operator NotEqual(a : R<T>; b: Pointer) : Boolean;  inline;
    class operator Equal(a : R<T>; b: T) : Boolean;  inline;
    class operator NotEqual(a : R<T>; b: T) : Boolean;  inline;
    class operator Positive(a: R<T>): T; inline;
    {$IFNDEF AUTOREFCOUNT}
    class operator Initialize (out Dest: R<T>);
    class operator Finalize (var Dest: R<T>);
    class operator Assign (var Dest: R<T>; const [ref] Src: R<T>);
      inline;
    {$ENDIF}
  end;

  WR<T : class> =record
  private
  {$IFNDEF AUTOREFCOUNT}
    GuardRef : __RefPtr;
  {$ELSE}
    [WEAK]obj : T;
  {$ENDIF}
  public
    function O : T; inline;
    class operator Implicit(a: WR<T>): R<T>; inline;
    class operator Implicit(a: R<T>): WR<T>; inline;
    class operator Equal(a, b: WR<T>) : Boolean; inline;
    class operator NotEqual(a, b: WR<T>) : Boolean;  inline;
    class operator Equal(a : WR<T>; b: Pointer) : Boolean;  inline;
    class operator NotEqual(a : WR<T>; b: Pointer) : Boolean;  inline;
    class operator Equal(a : WR<T>; b: T) : Boolean;  inline;
    class operator NotEqual(a : WR<T>; b: T) : Boolean;  inline;
    class operator Equal(a : WR<T>; b: R<T>) : Boolean;  inline;
    class operator NotEqual(a : WR<T>; b: R<T>) : Boolean;  inline;
    class operator Positive(a: WR<T>): T; inline;
    {$IFNDEF AUTOREFCOUNT}
    class operator Initialize (out Dest: WR<T>);
    class operator Finalize (var Dest: WR<T>);
    class operator Assign (var Dest: WR<T>; const [ref] Src: WR<T>);
      inline;
    {$ENDIF}
  end;

implementation

{ TRingQueue<T> }

function TRingQueue<T>.Get: Pointer;
var t : integer;
    successed : boolean;
begin
  repeat
    t := tail;
    Result := Data[t];
    if Result=nil then exit;    //Queue is empty, Return a nil pointer
    atomiccmpexchange(tail,(t+1)and QueueSize,t,successed);
  until successed;
  Data[t] := nil;
end;

procedure TRingQueue<T>.Init;
begin
  fillchar(Self,Sizeof(Self),0);
end;

class operator TRingQueue<T>.Initialize(out Dest: TRingQueue<T>);
begin
  Dest.Init;
end;

function TRingQueue<T>.Put(const V: Pointer): boolean;
begin
  Result := (V<>nil);
  if not Result then exit;      //Nil pointer not allowed, Return false
  var h : integer;
  var successed : boolean:=false;
  repeat
    h := head;
    Result := Data[h]=nil;
    if not Result then
      if h=tail then exit   //Queue is full, Return false
      else continue;
    atomiccmpexchange(head,(h+1)and QueueSize,h,successed);
  until successed;
  Data[h] := V;
end;

{ _RWLock }

procedure __RWLock<T>.BeginRead;
begin
  if W=TThread.Current.ThreadID then exit;
  repeat
    while WW>0 do idle;
    atomicincrement(R);
    if WW=0 then break;
    atomicdecrement(R);
    idle;
  until false;
end;

procedure __RWLock<T>.BeginWrite;
begin
  if W=TThread.Current.ThreadID then exit;
  atomicincrement(WW);
  repeat
    while (R>0)or(W<>0) do idle;
    var successed : boolean;
    atomiccmpexchange(W,TThread.Current.ThreadID,0,successed);
    if successed then break;
    idle;
  until false;
end;

procedure __RWLock<T>.DownGradeToRead;
begin
  if W<>TThread.Current.ThreadID then BeginRead
  else begin
    atomicincrement(R);
    W := 0;
    atomicdecrement(WW);
  end;
end;

procedure __RWLock<T>.EndRead;
begin
  if W=0 then atomicdecrement(R);
end;

procedure __RWLock<T>.EndWrite;
begin
  if W=TThread.Current.ThreadID then begin
    W := 0;
    atomicdecrement(WW);
  end;
end;

class operator __RWLock<T>.Finalize(var Dest: __RWLock<T>);
begin
  while Dest.R or Dest.WW<>0 do idle;
end;

class procedure __RWLock<T>.idle;
begin
  if NeedSleep then sleep(sizeof(T)-1);
end;

class operator __RWLock<T>.Initialize(out Dest: __RWLock<T>);
begin
  Dest.R := 0;
  Dest.WW := 0;
  Dest.W := 0;
end;

procedure __RWLock<T>.UpgradeToWrite;
begin
  if W<>0 then BeginWrite
  else begin
    atomicincrement(WW);
    while R>1 do idle;
    W := TThread.Current.ThreadID;
    atomicdecrement(R);
  end;
end;

{ __Ref }

procedure __Ref.AddRef;
begin
  atomicincrement(RefCount);
  AddWeakRef;
end;

procedure __Ref.AddWeakRef;
begin
  atomicincrement(WeakRefCount);
end;

class operator __Ref.Initialize(out Dest: __Ref);
begin
  Dest.RefCount := 0;
  Dest.WeakRefCount := 0;
  Dest.RefObj := nil;
end;

procedure __Ref.RemoveRef;
begin
  if atomicdecrement(RefCount)=0 then begin
    RefObj.DisposeOf;
    RefObj := nil;
  end;
  RemoveWeakRef;
end;

procedure __Ref.RemoveWeakRef;
begin
  if atomicdecrement(WeakRefCount)=0 then begin
    var p : __RefPtr := @Self;
    dispose(p);
  end;
end;

{ R<T> }

{$IFNDEF AUTOREFCOUNT}
class operator R<T>.Assign(var Dest: R<T>; const [Ref]Src: R<T>);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef<>nil then Dest.GuardRef.AddRef;
end;

class operator R<T>.Initialize(out Dest: R<T>);
begin
  Dest.GuardRef := nil;
end;

class operator R<T>.Finalize(var Dest: R<T>);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveRef;
end;
{$ENDIF}

class operator R<T>.Equal(a: R<T>; b: T): Boolean;
begin
  Result := b=a.O;
end;

class operator R<T>.Equal(a: R<T>; b: Pointer): Boolean;
begin
  Result := b=Pointer(a.O);
end;

class operator R<T>.Equal(a, b: R<T>): Boolean;
begin
  Result := a.O = b.O;
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
  if a<>nil then begin
    new(Result.GuardRef);
    Result.GuardRef.RefObj := a;
    Result.GuardRef.AddRef;
  end;
  {$ENDIF}
end;

class operator R<T>.NotEqual(a: R<T>; b: Pointer): Boolean;
begin
  Result := b<>Pointer(a.O);
end;

class operator R<T>.NotEqual(a: R<T>; b: T): Boolean;
begin
  Result := b<>a.O;
end;

class operator R<T>.NotEqual(a, b: R<T>): Boolean;
begin
  Result := a.O<>b.O;
end;

function R<T>.O: T;
begin
  {$IFDEF AUTOREFCOUNT}
  Result := obj;
  {$ELSE}
  Result := nil;
  if GuardRef<>nil then Result := T(GuardRef.RefObj);
  {$ENDIF}
end;

class operator R<T>.Positive(a: R<T>): T;
begin
  Result := a.O;
end;

{ WR<T> }

class operator WR<T>.Equal(a: WR<T>; b: R<T>): Boolean;
begin
  Result := a.O = b.O;
end;

class operator WR<T>.Equal(a: WR<T>; b: T): Boolean;
begin
  Result := a.O = b;
end;

class operator WR<T>.Equal(a: WR<T>; b: Pointer): Boolean;
begin
  Result := Pointer(a.O) = b;
end;

class operator WR<T>.Equal(a, b: WR<T>): Boolean;
begin
  Result := a.O = b.O;
end;

{$IFNDEF AUTOREFCOUNT}
class operator WR<T>.Initialize(out Dest: WR<T>);
begin
  Dest.GuardRef := nil;
end;

class operator WR<T>.Finalize(var Dest: WR<T>);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveWeakRef;
end;

class operator WR<T>.Assign(var Dest: WR<T>; const [Ref]Src: WR<T>);
begin
  if Dest.GuardRef<>nil then Dest.GuardRef.RemoveWeakRef;
  Dest.GuardRef := Src.GuardRef;
  if Dest.GuardRef<>nil then Dest.GuardRef.AddWeakRef;
end;
{$ENDIF}

class operator WR<T>.Implicit(a: R<T>): WR<T>;
begin
{$IFDEF AUTOREFCOUNT}
  Result.obj := a.O;
{$ELSE}
  Result.GuardRef := a.GuardRef;
  if Result.GuardRef<>nil then Result.GuardRef.AddWeakRef;
{$ENDIF}
end;

class operator WR<T>.Implicit(a: WR<T>): R<T>;
begin
{$IFDEF AUTOREFCOUNT}
  Result.obj := a.O;
{$ELSE}
  Result.GuardRef := a.GuardRef;
  if Result.GuardRef<>nil then Result.GuardRef.AddRef;
{$ENDIF}
end;

class operator WR<T>.NotEqual(a, b: WR<T>): Boolean;
begin
  Result := a.O <> b.O;
end;

class operator WR<T>.NotEqual(a: WR<T>; b: Pointer): Boolean;
begin
  Result := Pointer(a.O)<>b;
end;

class operator WR<T>.NotEqual(a: WR<T>; b: R<T>): Boolean;
begin
  Result := a.O<>b.O;
end;

class operator WR<T>.NotEqual(a: WR<T>; b: T): Boolean;
begin
  Result := a.O <> b;
end;

function WR<T>.O: T;
begin
{$IFDEF AUTOREFCOUNT}
  Result := obj;
{$ELSE}
  Result := nil;
  if GuardRef<>nil then Result := T(GuardRef.RefObj);
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
  if Buf<>nil then Freemem(Buf);
end;

class procedure TBufferPool<T>.FreeBuffer(var B: Pointer);
begin
  b := AtomicExchange(buf,b);
  if b<>nil then Freemem(b);
end;

class function TBufferPool<T>.GetBuffer: Pointer;
begin
  Result := nil;
  Result := AtomicExchange(buf,Result);
  if Result=nil then Getmem(Result,buffersize);
end;

end.
