
unit uPSR_dll;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;

procedure RegisterDLLRuntime(Caller: TPSExec);
procedure RegisterDLLRuntimeEx(Caller: TPSExec; AddDllProcImport: Boolean);

function ProcessDllImport(Caller: TPSExec; P: TPSExternalProcRec): Boolean;
function ProcessDllImportEx(Caller: TPSExec; P: TPSExternalProcRec; ForceDelayLoad: Boolean): Boolean;
function UnloadProc(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;

implementation
uses
  {$IFDEF UNIX}
  {$IFDEF Darwin}
  LCLIntf, Unix, baseunix, dynlibs, termio, sockets;
  {$ELSE}
  LibC{$IFNDEF FPC}, Windows{$ENDIF};
  {$ENDIF}
  {$ELSE}
  Windows;
  {$ENDIF}

{
p^.Ext1 contains the pointer to the Proc function
p^.ExportDecl:
  'dll:'+DllName+#0+FunctionName+#0+chr(Cc)+Chr(DelayLoad)+Chr(AlternateSearchPath)+VarParams
}

type
  PLoadedDll = ^TLoadedDll;
  TLoadedDll = record
    dllnamehash: Longint;
    dllname: tbtstring;
    {$IFDEF LINUX}
    dllhandle: Pointer;
    {$ELSE}
    dllhandle: THandle;
    {$ENDIF}
  end;
  TMyExec = class(TPSExec);
  PInteger = ^Integer;

procedure LAstErrorFree(Sender: TPSExec; P: PInteger);
begin
  dispose(p);
end;

procedure DLLSetLastError(Sender: TPSExec; P: Integer);
var
  pz: PInteger;
begin
  pz := Sender.FindProcResource(@LastErrorFree);
  if pz = nil then
  begin
    new(pz);
    Sender.AddResource(@LastErrorFree, PZ);
  end;
  pz^ := p;
end;

function DLLGetLastError(Sender: TPSExec): Integer;
var
  pz: PInteger;
begin
  pz := Sender.FindProcResource(@LastErrorFree);
  if pz = nil then
    result := 0
  else
    result := pz^;
end;


procedure DllFree(Sender: TPSExec; P: PLoadedDll);
begin
  {$IFDEF LINUX}
  dlclose(p^.dllhandle);
  {$ELSE}
  FreeLibrary(p^.dllhandle);
  {$ENDIF}
  Dispose(p);
end;

function LoadDll(Caller: TPSExec; P: TPSExternalProcRec): Boolean;
var
  s, s2, s3: tbtstring;
  h, i: Longint;
  ph: PLoadedDll;
  {$IFDEF LINUX}
  dllhandle: Pointer;
  {$ELSE}
  dllhandle: THandle;
  {$ENDIF}
  loadwithalteredsearchpath: Boolean;
begin
  s := p.Decl;
  Delete(s, 1, 4);
  s2 := copy(s, 1, pos(tbtchar(#0), s)-1);
  delete(s, 1, length(s2)+1);
  h := makehash(s2);
  s3 := copy(s, 1, pos(tbtchar(#0), s)-1);
  delete(s, 1, length(s3)+1);
  loadwithalteredsearchpath := bytebool(s[3]);
  i := 2147483647; // maxint
  dllhandle := 0;
  repeat
    ph := Caller.FindProcResource2(@dllFree, i);
    if (ph = nil) then
    begin
      if s2 = '' then
      begin
        // don't pass an empty filename to LoadLibrary, just treat it as uncallable
        p.Ext2 := Pointer(1);
        Result := False;
        exit;
      end;
      {$IFDEF UNIX}
	  {$IFDEF DARWIN}
	  dllhandle := LoadLibrary(PChar(s2));
	  {$ELSE}
      dllhandle := dlopen(PChar(s2), RTLD_LAZY);
	  {$ENDIF}
      {$ELSE}
      if loadwithalteredsearchpath then
        dllhandle := LoadLibraryExA(PAnsiChar(AnsiString(s2)), 0, LOAD_WITH_ALTERED_SEARCH_PATH)
      else
        dllhandle := LoadLibraryA(PAnsiChar(AnsiString(s2)));
      {$ENDIF}
      if dllhandle = {$IFDEF LINUX}nil{$ELSE}0{$ENDIF}then
      begin
        p.Ext2 := Pointer(1);
        Result := False;
        exit;
      end;
      new(ph);
      ph^.dllnamehash := h;
      ph^.dllname := s2;
      ph^.dllhandle := dllhandle;
      Caller.AddResource(@DllFree, ph);
    end;
    if (ph^.dllnamehash = h) and (ph^.dllname = s2) then
    begin
      dllhandle := ph^.dllhandle;
    end;
  until dllhandle <> {$IFDEF LINUX}nil{$ELSE}0{$ENDIF};
  {$IFDEF LINUX}
  p.Ext1 := dlsym(dllhandle, pchar(s3));
  {$ELSE}
  p.Ext1 := GetProcAddress(dllhandle, pansichar(s3));
  {$ENDIF}
  if p.Ext1 = nil then
  begin
    p.Ext2 := Pointer(1);
    Result := false;
    exit;
  end;
  Result := True;
end;


function DllProc(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;

var
  i: Longint;
  MyList: TIfList;
  n: PPSVariantIFC;
  CurrStack: Cardinal;
  cc: TPSCallingConvention;
  s: tbtstring;
begin
  if p.Ext2 <> nil then // error
  begin
    Result := false;
    exit;
  end;
  if p.Ext1 = nil then
  begin
    if not LoadDll(Caller, P) then
    begin
      Result := false;
      exit;
    end;
  end;
  s := p.Decl;
  delete(S, 1, pos(tbtchar(#0), s));
  delete(S, 1, pos(tbtchar(#0), s));
  if length(S) < 2 then
  begin
    Result := False;
    exit;
  end;
  cc := TPSCallingConvention(s[1]);
  delete(s, 1, 3); // cc + delayload + alternatesearchpath (delayload might also be forced!)
  CurrStack := Cardinal(Stack.Count) - Cardinal(length(s));
  if s[1] = #0 then inc(CurrStack);
  MyList := tIfList.Create;
  for i := 2 to length(s) do
  begin
    MyList.Add(nil);
  end;
  for i := length(s) downto 2 do
  begin
    MyList[i - 2] := NewPPSVariantIFC(Stack[CurrStack], s[i] <> #0);
    inc(CurrStack);
  end;
  if s[1] <> #0 then
  begin
    n := NewPPSVariantIFC(Stack[CurrStack], true);
  end else n := nil;
  try
    TMYExec(Caller).InnerfuseCall(nil, p.Ext1, cc, MyList, n);
    {$IFNDEF LINUX}
    DLLSetLastError(Caller, GetLastError);
    {$ENDIF}
  finally
    DisposePPSvariantIFC(n);
    DisposePPSVariantIFCList(MyList);
  end;
  result := true;
end;

function ProcessDllImport(Caller: TPSExec; P: TPSExternalProcRec): Boolean;
begin
  Result := ProcessDllImportEx(Caller, P, False);
end;

function ProcessDllImportEx(Caller: TPSExec; P: TPSExternalProcRec; ForceDelayLoad: Boolean): Boolean;
var
  DelayLoad: Boolean;
  s: tbtstring;
begin
  if not ForceDelayLoad then begin
    s := p.Decl;
    Delete(s,1,pos(tbtchar(#0), s));
    Delete(s,1,pos(tbtchar(#0), s));
    DelayLoad := bytebool(s[2]);
  end else
    DelayLoad := True;

  if DelayLoad then begin
    p.ProcPtr := DllProc;
    Result := True;
  end else begin
    p.ProcPtr := DllProc;
    Result := LoadDll(Caller, p);
  end;
end;


function GetLastErrorProc(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;
begin
  Stack.SetInt(-1, DLLGetLastError(Caller));
  Result := true;
end;

function UnloadProc(Caller: TPSExec; p: TPSExternalProcRec; Global, Stack: TPSStack): Boolean;
var
  h, i: Longint;
  pv: TPSProcRec;
  ph: PLoadedDll;
  sname, s: tbtstring;
begin
  sname := Stack.GetAnsiString(-1);
  for i := Caller.GetProcCount -1 downto 0 do
  begin
    pv := Caller.GetProcNo(i);
    if not (pv is TPSExternalProcRec) then continue;
    if @TPSExternalProcRec(pv).ProcPtr <> @DllProc then continue;
    s := (TPSExternalProcRec(pv).Decl);
    delete(s,1,4);
    if copy(s,1,pos(tbtchar(#0),s)-1) = sname then
    begin
      TPSExternalProcRec(pv).Ext1 := nil;
    end;
  end;
  h := MakeHash(sname);
  i := 2147483647; // maxint
  repeat
    ph := Caller.FindProcResource2(@dllFree, i);
    if (ph = nil) then break;
    if (ph.dllnamehash = h) and (ph.dllname = sname) then
    begin
      {$IFDEF LINUX}
      dlclose(ph^.dllhandle);
      {$ELSE}
      FreeLibrary(ph^.dllhandle);
      {$ENDIF}
      Caller.DeleteResource(ph);
      dispose(ph);
    end;
  until false;
  result := true;
end;

procedure RegisterDLLRuntime(Caller: TPSExec);
begin
  RegisterDLLRuntimeEx(Caller, True);
end;

procedure RegisterDLLRuntimeEx(Caller: TPSExec; AddDllProcImport: Boolean);
begin
  if AddDllProcImport then
    Caller.AddSpecialProcImport('dll', @ProcessDllImport, nil);
  Caller.RegisterFunctionName('UNLOADDLL', UnloadProc, nil, nil);
  Caller.RegisterFunctionName('DLLGETLASTERROR', GetLastErrorProc, nil, nil);
end;

end.
