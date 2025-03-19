

unit uPSR_comobj;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;


procedure RIRegister_ComObj(cl: TPSExec);

implementation
uses
{$IFDEF DELPHI3UP}
  ComObj;
{$ELSE}
  SysUtils, Ole2;
{$ENDIF}
{$IFNDEF DELPHI3UP}

{$IFDEF DELPHI3UP }
resourceString
{$ELSE }
const
{$ENDIF }

  RPS_OLEError = 'OLE error %.8x';
function OleErrorMessage(ErrorCode: HResult): String;
begin
  Result := SysErrorMessage(ErrorCode);
  if Result = '' then
    Result := Format(RPS_OLEError, [ErrorCode]);
end;

procedure OleError(ErrorCode: HResult);
begin
  raise Exception.Create(OleErrorMessage(ErrorCode));
end;

procedure OleCheck(Result: HResult);
begin
  if Result < 0 then OleError(Result);
end;

procedure CreateOleObject(const ClassName: string; var Disp: IDispatch);
var
  OldDisp: IDispatch;
  ClassID: TCLSID;
  WideCharBuf: array[0..127] of WideChar;
begin
  StringToWideChar(ClassName, WideCharBuf, SizeOf(WideCharBuf) div SizeOf(WideCharBuf[0]));
  OleCheck(CLSIDFromProgID(WideCharBuf, ClassID));
  if Disp <> nil then
  begin
    OldDisp := Disp;
    Disp := nil;
    OldDisp.Release;
  end;
  OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or
    CLSCTX_LOCAL_SERVER, IID_IDispatch, Disp));
end;

procedure GetActiveOleObject(const ClassName: string; var Disp: IDispatch);
var
  Unknown: IUnknown;
  OldDisp: IDispatch;
  ClassID: TCLSID;
  WideCharBuf: array[0..127] of WideChar;
begin
  StringToWideChar(ClassName, WideCharBuf, SizeOf(WideCharBuf) div SizeOf(WideCharBuf[0]));
  OleCheck(CLSIDFromProgID(WideCharBuf, ClassID));
  OleCheck(GetActiveObject(ClassID, nil, Unknown));
  try
    if Disp <> nil then
    begin
      OldDisp := Disp;
      Disp := nil;
      OldDisp.Release;
    end;
    OleCheck(Unknown.QueryInterface(IID_IDispatch, Disp));
  finally
    Unknown.Release;
  end;
end;

{$ENDIF}


procedure RIRegister_ComObj(cl: TPSExec);
begin
  cl.RegisterDelphiFunction(@CreateOleObject, 'CREATEOLEOBJECT', cdRegister);
  cl.RegisterDelphiFunction(@GetActiveOleObject, 'GETACTIVEOLEOBJECT', cdRegister);
end;

end.
