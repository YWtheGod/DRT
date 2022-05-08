﻿unit DRT.Init;

interface
uses
{$IFDEF MSWINDOWS}
  fastmm5,
{$ENDIF}
  DRT.YWSTRUTIL,
  drt.LIBNAME;
var
  OriginMM : TMemoryManagerEx;
{$IFDEF ANDROID}
procedure __emutls_get_address; external 'libgcc_real.a';
{$ENDIF}
{$IFDEF LINUX64}
procedure DRT_Init; external libdrt name _PU+'DRT_Init';
procedure DRT_Done; external libdrt name _PU+'DRT_Done';
{$ENDIF}
implementation
{$IFDEF MSWINDOWS}
uses Windows,SysUtils;
const
{$IFDEF WIN32}
  p1value = $FF525051;
  p2value = $15;
{$ELSE}
  p1value = $FFCA8748;
  p2value = $25;
{$ENDIF}

type
Tpatch = packed record
  p1 : cardinal;
  p2 : byte;
  Offset : integer;
{$IFDEF WIN32}
  p3 : Cardinal;
  p4 : byte;
{$ENDIF}
end;
Ppatch =^TPatch;
var
  newmove,oldmove : TPatch;
{$IFDEF WIN32}
procedure _memmove; cdecl; external 'MSVCRT.DLL' name 'memmove';
{$ELSE}
procedure memmove; cdecl; external 'MSVCRT.DLL';
{$ENDIF}

procedure PatchMove(var patch,old : TPatch);
var
  Protect, OldProtect : DWORD;
  A : NativeInt;
begin
  VirtualProtect(@System.Move, 256, PAGE_EXECUTE_READWRITE, @OldProtect);
  old := PPatch(@System.Move)^;
  if PCardinal(@System.Move)^ <> patch.p1 then {Check if Already Patched}
    PPatch(@System.Move)^ := patch;
  VirtualProtect(@System.Move, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, @System.Move, 256);
end;

procedure PatchFunc(P1,P2 : Pointer);
var
  Protect, OldProtect : DWORD;
begin
  VirtualProtect(P1, 256, PAGE_EXECUTE_READWRITE, @OldProtect);
  if PByte(P1)^ <> $E9 then begin
    PByte(P1)^ := $E9;
    PInteger(NativeInt(P1)+1)^ := NativeInt(P2)-NativeInt(P1)-5;
  end;
  VirtualProtect(P1, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, P1, 256);
end;

procedure PatchIntoStr;
var
  O1,N1 : function (Value: Integer): string;
  O2,N2 : function (Value: Int64): string;
  O3,N3 : function (Value: Cardinal): string;
  O4,N4 : function (Value: UInt64): string;
  O5,N5 : function (Value: Integer; Digits: Integer): string;
  O6,N6 : function (Value: Int64; Digits: Integer): string;
  O7,N7 : function (Value: UInt64; Digits: Integer): string;
begin
  O1 := SysUtils.InttoStr;
  N1 := DRT.YWSTRUtil.IntToStr2;
  PatchFunc(@O1,@N1);
  O2 := SysUtils.InttoStr;
  N2 := DRT.YWSTRUtil.IntToStr2;
  PatchFunc(@O2,@N2);
  O3 := SysUtils.UInttoStr;
  N3 := DRT.YWSTRUtil.UIntToStr2;
  PatchFunc(@O3,@N3);
  O4 := SysUtils.UInttoStr;
  N4 := DRT.YWSTRUtil.UIntToStr2;
  PatchFunc(@O4,@N4);
  O5 := SysUtils.IntToHex;
  N5 := DRT.YWSTRUtil.IntToHex2;
  PatchFunc(@O5,@N5);
  O6 := SysUtils.IntToHex;
  N6 := DRT.YWSTRUtil.IntToHex2;
  PatchFunc(@O6,@N6);
  O7 := SysUtils.IntToHex;
  N7 := DRT.YWSTRUtil.IntToHex2;
  PatchFunc(@O7,@N7);
end;

procedure SetDelphiMM(var C:TMemoryManagerEx);
  cdecl; external libdrt;

function GetP(const P:Pointer;const A,B:Integer) : PPointer; inline;
begin
  Result := PPointer(NativeInt(P)+PInteger(NativeInt(P)+A)^+B);
end;

procedure PatchMem(P1,P2 : Pointer);
var
  Protect, OldProtect : DWORD;
begin
  VirtualProtect(P1, 256, PAGE_EXECUTE_READWRITE, @OldProtect);
  PPointer(P1)^ := P2;
  VirtualProtect(P1, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, P1, 256);
end;

procedure PatchDRTMM;
var C : TMemoryManagerEx;
    P : PPointer;
begin
{$IFDEF WIN32}
  SetDelphiMM(C);
  PatchFunc(@C.GetMem,@OriginMM.GetMem);
  PatchFunc(@C.FreeMem,@OriginMM.FreeMem);
  PatchFunc(@C.ReallocMem,@OriginMM.ReallocMem);
  PatchFunc(@C.AllocMem,@OriginMM.AllocMem);
{$ELSE}
  P := GetP(@SetDelphiMM,2,6);
  PatchMem(GetP(P^,3,7),@OriginMM.GetMem);
  PatchMem(GetP(P^,13,17),@OriginMM.FreeMem);
  PatchMem(GetP(P^,24,28),@OriginMM.ReallocMem);
  PatchMem(GetP(P^,35,39),@OriginMM.AllocMem);
{$ENDIF}
end;

{$ENDIF}
initialization
{$IFDEF LINUX64}
  DRT_Init;
{$ENDIF}
{$IFDEF MSWINDOWS}
  GetMemoryManager(OriginMM);
{$IFDEF WIN64}
  PatchDRTMM;
  with newmove do begin
    p1 := p1value;
    p2 := p2value;
  {$IFDEF WIN32}
    p3 := $0CC48366;
    p4 := $C3;
    offset := PCardinal(NativeInt(@_memmove)+2)^;
  {$ELSE}
    offset := NativeInt(@memmove)+6+PInteger(NativeInt(@memmove)+2)^-NativeInt(@system.Move)-9;
  {$ENDIF}
  end;
  PatchMove(newmove,oldmove);
{$ENDIF}
  PatchIntoStr;
{$ENDIF}
finalization
{$IFDEF WIN64}
  PatchMove(oldmove,newmove);
{$ENDIF}
{$IFDEF LINUX64}
  DRT_Done;
{$ENDIF}
end.
