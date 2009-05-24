{ Compiletime DLL importing support }
unit uPSC_dll;

{$I PascalScript.inc}
interface
{

  Function FindWindow(c1, c2: PChar): Cardinal; external 'FindWindow@user32.dll stdcall';

}
uses
  uPSCompiler, uPSUtils;

  
{$IFDEF DELPHI3UP }
resourceString
{$ELSE }
const
{$ENDIF }

  RPS_Invalid_External = 'Invalid External';
  RPS_InvalidCallingConvention = 'Invalid Calling Convention';



function DllExternalProc(Sender: TPSPascalCompiler; Decl: TPSParametersDecl; const Name, FExternal: string): TPSRegProc;
type
  
  TDllCallingConvention = (clRegister 
  , clPascal 
  , ClCdecl 
  , ClStdCall 
  );

var
  DefaultCC: TDllCallingConvention;

procedure RegisterDll_Compiletime(cs: TPSPascalCompiler);

implementation

function rpos(ch: char; const s: string): Longint;
var
  i: Longint;
begin
  for i := length(s) downto 1 do
  if s[i] = ch then begin Result := i; exit; end;
  result := 0;
end;

function RemoveQuotes(s: string): string;
begin
  result := s;
  if result = '' then exit;
  if Result[1] = '"' then delete(result ,1,1);
  if (Result <> '') and (Result[Length(result)] = '"') then delete(result, length(result), 1);
end;

function DllExternalProc(Sender: TPSPascalCompiler; Decl: TPSParametersDecl; const Name, FExternal: string): TPSRegProc;
var
  FuncName,
  FuncCC, s: string;
  CC: TDllCallingConvention;
  DelayLoad: Boolean;

begin
  DelayLoad := False;
  FuncCC := FExternal;
  if (pos('@', FuncCC) = 0) then
  begin
    Sender.MakeError('', ecCustomError, RPS_Invalid_External);
    Result := nil;
    exit;
  end;
  FuncName := copy(FuncCC, 1, rpos('@', FuncCC)-1)+#0;
  delete(FuncCc, 1, length(FuncName));
  if pos(' ', Funccc) <> 0 then
  begin
    if FuncCC[1] = '"' then
    begin
      Delete(FuncCC, 1, 1);
      FuncName := RemoveQuotes(copy(FuncCC, 1, pos('"', FuncCC)-1))+#0+FuncName;
      Delete(FuncCC,1, pos('"', FuncCC));
      if (FuncCC <> '') and( FuncCC[1] = ' ') then delete(FuncCC,1,1);
    end else
    begin
      FuncName := copy(FuncCc, 1, pos(' ',FuncCC)-1)+#0+FuncName;
      Delete(FuncCC, 1, pos(' ', FuncCC));
    end;
    if pos(' ', FuncCC) > 0 then
    begin
      s := Copy(FuncCC, pos(' ', Funccc)+1, MaxInt);
      FuncCC := FastUpperCase(Copy(FuncCC, 1, pos(' ', FuncCC)-1));
      Delete(FuncCC, pos(' ', Funccc), MaxInt);
      if FastUppercase(s) = 'DELAYLOAD' then
        DelayLoad := True
      else
      begin
        Sender.MakeError('', ecCustomError, RPS_Invalid_External);
        Result := nil;
        exit;
      end;
    end else
      FuncCC := FastUpperCase(FuncCC);
    if FuncCC = 'STDCALL' then cc := ClStdCall else
    if FuncCC = 'CDECL' then cc := ClCdecl else
    if FuncCC = 'REGISTER' then cc := clRegister else
    if FuncCC = 'PASCAL' then cc := clPascal else
    begin
      Sender.MakeError('', ecCustomError, RPS_InvalidCallingConvention);
      Result := nil;
      exit;
    end;
  end else
  begin
    FuncName := RemoveQuotes(FuncCC)+#0+FuncName;
    FuncCC := '';
    cc := DefaultCC;
  end;
  FuncName := 'dll:'+FuncName+char(cc)+char(bytebool(DelayLoad)) + declToBits(Decl);
  Result := TPSRegProc.Create;
  Result.ImportDecl := FuncName;
  Result.Decl.Assign(Decl);
  Result.Name := Name;
  Result.ExportName := False;
end;

procedure RegisterDll_Compiletime(cs: TPSPascalCompiler);
begin
  cs.OnExternalProc := DllExternalProc;
  cs.AddFunction('procedure UnloadDll(s: string)');
  cs.AddFunction('function DLLGetLastError: Longint');
end;

begin
  DefaultCc := clRegister;
end.

