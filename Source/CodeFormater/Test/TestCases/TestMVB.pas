unit TestMVB;

{ AFS 15 June 2000

 This unit does not compile and is not semantically meaningfull
 it is test cases for the code formatting utility

  test some conditions mailed to me by Marcel van Brakel}

interface

uses SysUtils, Windows;

type

  EJclError = class (Exception)
  {$IFNDEF DELPHI5_UP}
  public
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const);
    overload;
  {$ENDIF}
  end;

  TFred = class (TObject) end;
  TFred2 = class(TObject) end;
  TFred3 = class      (TObject) end;

  PInt64 = ^Int64;
  Int64 = packed record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: Longint);
  {$IFNDEF BCB3}
    1: (
      QuadPart: LONGLONG);
  {$ENDIF}
  end;

const

  DynExtendedArrayHigh = 214748363;  // 2^31 / SizeOf(Extended)
  DynDoubleArrayHigh   = 536870908;  // 2^31 / SizeOf(Double)
  DynSingleArrayHigh   = 268435448;  // 2^31 / SizeOf(Single)
  {$IFDEF MATH_EXTENDED_PRECISION}
  DynFloatArrayHigh = 214748363;  // 2^31 / SizeOf(Extended)
  {$ENDIF}


procedure I64Assign(var I: Int64; Low, High: Longint);
procedure I64Copy(var Dest: Int64; const Source: Int64);
function I64Compare(const I1, I2: Int64): Integer;


implementation


var
  i: integer;
  fred: string;


  const
    WAN = 1;
    TWOOOO = 2;
    F = 12;


constructor EJclError.CreateResFmt(ResStringRec: PResStringRec; const Args: array of const);
begin
  CreateFmt(LoadResString(ResStringRec), Args);
end;

constructor EJclWin32Error.CreateRes(Ident: Integer);
begin
  FLastError    := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateFmt(LoadStr(Ident) + #13 + 'Win32: %s (%u)', [FLastErrorMsg, FLastError]);
end;

constructor EJclWin32Error.CreateFmt(const Msg: String; const Args: array of const);
begin
  FLastError    := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateFmt(Msg + #13 + Format('Win32: %s (%u)', [FLastErrorMsg, FLastError]), Args);
end;

procedure DynArrayInitialize(var A; ElementSize, InitialLength: Longint);
var
  P:    Pointer;
  Size: Longint;
begin
  if (ElementSize < 1) or (ElementSize > 8) then raise Exception.Create('');
  if InitialLength < 0 then InitialLength := 0;
  Size  := DynArrayRecSize + (InitialLength * ElementSize);
  P := AllocMem(Size);
  with TDynArrayRec(P^) do
  begin
    AllocSize := Size;
    Length    := InitialLength;
    ElemSize  := ElementSize;
  end;
  Pointer(A) := Pointer(Longint(P) + DynArrayRecSize);
end;

procedure TestMisc;
var
  p: pointer;
  s: string;
begin
  s := '';
  p := nil;

  s:='';
  p:=nil;

  s  :=  '';
  p  :=  nil;

end;

  
initialization
  InitSysInfo;
end.
