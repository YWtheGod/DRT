unit MMTestUnit;

interface

procedure DoTest(a:integer);

implementation

const
  TESTCOUNT  = 10000;
type
  TJOB = record
    D, O : integer;
  end;
var
  Data : array[0..127,0..TESTCOUNT-1] of Pointer;
  Ops : array[0..TESTCOUNT-1,0..7] of Cardinal;
  WorkLoad : array[0..TESTCOUNT*8-1] of TJOB;
  tmp : array[0..TESTCOUNT-1] of TJOB;

procedure compute(const D : Pointer;const Size : Cardinal); inline;
begin
  var A : PCardinal := PCardinal(NativeInt(D)+4);
  var B : PCardinal := PCardinal(NativeInt(D)+size);
  while NativeInt(A)<NativeInt(B) do begin
    PCardinal(D)^ := PCardinal(D)^+A^;
    inc(A);
  end;
end;

procedure DoTest(a:integer);
var i : integer;
    J : TJob;
begin
  for i := 0 to TESTCOUNT*8-1 do with WorkLoad[i] do begin
    case O of
       0,4 : begin GetMem(Data[a,D],Ops[D,O]);Compute(Data[a,D],Ops[D,O]);end;
       1,2,5,6 : begin ReallocMem(Data[a,D],Ops[D,O]);Compute(Data[a,D],Ops[D,O]);end;
       3,7 : FreeMem(Data[a,D]);
    end;
  end;
end;

procedure InitData;
var i,j,k : integer;
begin
  randseed := 13579;
  for i := 0 to TESTCOUNT-1 do begin
    tmp[i].D := i;
    tmp[i].O := 0 ;
  end;
  j := TESTCOUNT;
  for i := 0 to TESTCOUNT*8-1 do begin
    k := random(J);
    WorkLoad[i] := tmp[k];
    if not(tmp[k].O in [3,7]) then begin
      var m,n : integer;
      m := random(8)+4;
      n := random(10)+1;
      Ops[tmp[k].D,tmp[k].O] := 1 shl (random(n)+m);
    end;
    inc(tmp[k].O);
    if(tmp[k].O=8) then begin
      tmp[k] := tmp[j-1];
      dec(j);
    end;
  end;
end;

initialization
  InitData;
end.
