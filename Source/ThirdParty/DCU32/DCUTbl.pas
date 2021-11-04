unit DCUTbl;

(*
  The table of used units module of the DCU32INT utility by Alexei Hmelnov.
  It is used to obtain the necessary imported declarations. If the imported unit
  was not found, the program will still work, but, for example, will show
  the corresponding constant value as a HEX dump.
  ----------------------------------------------------------------------------
  E-Mail: alex@icc.ru
  http://hmelnov.icc.ru/DCU/
  ----------------------------------------------------------------------------

  See the file "readme.txt" for more details.

  ------------------------------------------------------------------------
  IMPORTANT NOTE:
  This software is provided 'as-is', without any expressed or implied warranty.
  In no event will the author be held liable for any damages arising from the
  use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  1. The origin of this software must not be misrepresented, you must not
  claim that you wrote the original software.
  2. Altered source versions must be plainly marked as such, and must not
  be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
  distribution.
*)
interface

uses
  SysUtils, Classes, DCU32, DCP{$IFDEF Win32}, Windows{$ENDIF};

const
  PathSep = {$IFNDEF LINUX}';'{$ELSE}':'{$ENDIF};
  DirSep = {$IFNDEF LINUX}'\'{$ELSE}'/'{$ENDIF};

var
  DCUPath: String = '*'; { To disable LIB directory autodetection use -U flag }
  PASPath: String =
    '*' { Let only presence of -P signals, that source lines are required };

  FOutPutFile: string = '';
  TopLevelUnitClass: TUnitClass = TUnit;
  IgnoreUnitStamps: Boolean = true;

function ExtractFileNamePkg(const FN: String): String;

function GetDCUByName(FName, FExt: String; VerRq: integer; MSILRq: Boolean;
  PlatformRq: TDCUPlatform; StampRq: integer): TUnit;

function GetDCUOfMemory(MemP: Pointer): TUnit;

procedure FreeDCU;

procedure LoadSourceLines(FName: String; Lines: TStrings);

procedure SetUnitAliases(const V: String);

function IsDCPName(const S: String): Boolean;

function LoadPackage(const FName: String; IsMain: Boolean): TDCPackage;

const
  PkgSep = '@';

implementation

{ const
  PkgErr = Pointer(1); }
var
  PathList: TStringList = Nil;
  FUnitAliases: TStringList = Nil;
  AddedUnitDirToPath: Boolean = false;
  AutoLibDirNDX: integer = -1;

procedure FreePackages;
var
  i: integer;
  Pkg: TDCPackage;
begin
  if PathList = Nil then
    Exit;
  for i := 0 to PathList.Count - 1 do
  begin
    Pkg := TDCPackage(PathList.Objects[i]);
    { if Pkg=PkgErr then
      Continue; }
    Pkg.Free;
  end;
  PathList.Clear;
end;

function ExtractFileNamePkg(const FN: String): String;
{ Extract file name for packaged or normal files }
var
  CP: PChar;
begin
  Result := ExtractFileName(FN);
  CP := StrScan(PChar(Result), PkgSep);
  if CP <> Nil then
    Result := StrPas(CP + 1);
end;

function GetDelphiLibDir(VerRq: integer; MSILRq: Boolean;
  PlatformRq: TDCUPlatform): String;
{ Delphi LIB directory autodetection }
{$IFDEF Win32}
const
  sRoot = 'RootDir';
  sPlatformDir: array [TDCUPlatform] of String = ('win32', 'win64', 'osx32',
    'iOSSimulator', 'iOSDevice', 'Android');
var
  Key: HKey;
  sPath, sRes, sLib: String;
  DataType, DataSize: integer;
{$ENDIF}
begin
  Result := '';
{$IFDEF Win32}
  sPath := '';
  sLib := 'Lib';
  case VerRq of
    verD2 .. verD7:
      sPath := Format('SOFTWARE\Borland\Delphi\%d.0', [VerRq]);
    verD8:
      sPath := 'SOFTWARE\Borland\BDS\2.0';
    verD2005:
      sPath := 'SOFTWARE\Borland\BDS\3.0';
    verD2006:
      sPath := 'SOFTWARE\Borland\BDS\4.0';
    // verD2007: sPath := 'SOFTWARE\Borland\BDS\5.0'; This version was not detected
    verD2009:
      sPath := 'SOFTWARE\CodeGear\BDS\6.0';
    verD2010:
      sPath := 'SOFTWARE\CodeGear\BDS\7.0';
    verD_XE:
      sPath := 'SOFTWARE\Embarcadero\BDS\8.0';
    verD_XE2:
      sPath := 'SOFTWARE\Embarcadero\BDS\9.0';
    verD_XE3:
      sPath := 'SOFTWARE\Embarcadero\BDS\10.0';
    verD_XE4:
      sPath := 'SOFTWARE\Embarcadero\BDS\11.0';
    verD_XE5:
      sPath := 'SOFTWARE\Embarcadero\BDS\12.0';
    // verAppMethod: sPath := 'SOFTWARE\Embarcadero\BDS\13.0'; == verD_XE7
    verD_XE6:
      sPath := 'SOFTWARE\Embarcadero\BDS\14.0';
    verD_XE7:
      sPath := 'SOFTWARE\Embarcadero\BDS\15.0';
  end;
  if sPath = '' then
    Exit;
  if RegOpenKeyEx(HKEY_CURRENT_USER, PChar(sPath), 0, KEY_READ, Key) <> ERROR_SUCCESS
  then
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(sPath), 0, KEY_READ, Key) <> ERROR_SUCCESS
    then
      Exit;
  try
    if RegQueryValueEx(Key, sRoot, nil, @DataType, nil, @DataSize) <> ERROR_SUCCESS
    then
      Exit;
    if DataType <> REG_SZ then
      Exit;
    if DataSize <= SizeOf(Char) then
      Exit;
    SetString(sRes, nil, (DataSize div SizeOf(Char)) - 1);
    if RegQueryValueEx(Key, sRoot, nil, @DataType, PByte(sRes), @DataSize) <> ERROR_SUCCESS
    then
      Exit;
    if sRes[Length(sRes)] <> DirSep then
      sRes := sRes + DirSep;
    if VerRq >= verD_XE then
      sLib := 'lib' + DirSep + sPlatformDir[PlatformRq] + DirSep + 'release';
    Result := sRes + sLib + DirSep;
  finally
    RegCloseKey(Key);
  end;
{$ENDIF}
end;

function IsDCPName(const S: String): Boolean;
var
  Ext: String;
begin
  Ext := ExtractFileExt(S);
  Result := (CompareText(Ext, '.dcp') = 0) or (CompareText(Ext, '.dcpil') = 0);
end;

function AddToPathList(S: String; SurePkg: Boolean): integer;
begin
  if S = '' then
  begin
    Result := -1;
    Exit;
  end;
  Result := PathList.IndexOf(S);
  if Result >= 0 then
    Exit; { It may be wrong on Unix }
  if SurePkg or IsDCPName(S) then
  begin
    if FileExists(S) then
    begin
      Result := PathList.AddObject(S, TDCPackage.Create);
      Exit;
    end;
    Result := -1;
    if SurePkg then
      Exit;
  end;
  if not(AnsiLastChar(S)^ in [{$IFNDEF Linux}':', {$ENDIF} DirSep]) then
    S := S + DirSep;
  Result := PathList.Add(S);
end;

procedure FindPackagesAndAddToPathList(const Mask: String);
var
  SR: TSearchRec;
  Path, FN, Ext: String;
  lExt: integer;
begin
  Ext := ExtractFileExt(Mask);
  lExt := Length(Ext);
  if SysUtils.FindFirst(Mask, faAnyFile, SR) <> 0 then
    Exit;
  Path := ExtractFilePath(Mask);
  repeat
    if (SR.Attr and faDirectory) = 0 then
    begin
      Ext := ExtractFileExt(SR.Name);
      if Length(Ext) = lExt then
      // Check that we don`t have .dcpil instead of .dcp
        AddToPathList(Path + SR.Name, true { SurePkg } );
    end;
  until FindNext(SR) <> 0;
end;

procedure SetPathList(const DirList: string);
var
  i, P, L, hDir: integer;
  sDir: String;
  CP: PChar;
begin
  P := 1;
  L := Length(DirList);
  while true do
  begin
    while (P <= L) and (DirList[P] = PathSep) do
      Inc(P);
    if P > L then
      Break;
    i := P;
    while (P <= L) and (DirList[P] <> PathSep) do
    begin
      if DirList[P] in LeadBytes then
        Inc(P);
      Inc(P);
    end;
    sDir := Copy(DirList, i, P - i);
    if sDir = '' then
      Continue { Paranoic };
    CP := PChar(sDir);
    if ((StrScan(CP, '*') <> Nil) or (StrScan(CP, '?') <> Nil)) and
      IsDCPName(sDir) then
    begin
      FindPackagesAndAddToPathList(sDir);
      Continue;
    end;
    hDir := AddToPathList(sDir, false { SurePkg } );
    if sDir = '*' then
      AutoLibDirNDX := hDir;
    // Mark the place to add the directory from registry
  end;
end;

(*
  function AllFilesSearch(Name: string; var DirList: string): string;
  var
  I, P, L: Integer;
  begin
  Result := Name;
  P := 1;
  L := Length(DirList);
  while True do
  begin
  while (P <= L) and (DirList[P] = PathSep) do
  Inc(P);
  if P > L then
  Break;
  I := P;
  while (P <= L) and (DirList[P] <> PathSep) do begin
  if DirList[P] in LeadBytes then
  Inc(P);
  Inc(P);
  end;
  Result := Copy(DirList, I, P - I);
  if not (AnsiLastChar(Result)^ in [{$IFNDEF Linux}':',{$ENDIF} DirSep]) then
  Result := Result + DirSep;
  Result := Result + Name;
  if FileExists(Result) then begin
  Delete(DirList,1,P+1);
  Exit;
  end ;
  end;
  Result := '';
  DirList := '';
  end;
*)

type

  TDCUSearchRec = record
    hPath: integer;
    FN, UnitName: String;
    Res: PDCPUnitHdr;
  end;

function InitDCUSearch(FN, FExt: String; var SR: TDCUSearchRec)
  : Boolean { HasPath };
var
  Dir: String;
  CP: PChar;
  AddedUnitDir: Boolean;
begin
  FillChar(SR, SizeOf(TDCUSearchRec), 0);
  SR.FN := FN;
  SR.hPath := -1;
  Dir := ExtractFileDir(FN);
  Result := Dir <> '';
  AddedUnitDir := AddedUnitDirToPath;
  if not AddedUnitDirToPath then
  begin
    if (PASPath <> '*') then
    begin
      if (PASPath = '') then
        PASPath := Dir
      else
        PASPath := Dir + PathSep + PASPath;
    end;
    AddedUnitDirToPath := true;
  end;
  CP := PChar(FN) + Length(Dir);
  CP := StrScan(CP + 1, PkgSep);
  if CP <> Nil then
  begin
    SetLength(FN, CP - PChar(FN)); // Package name with path
    SR.hPath := AddToPathList(FN, true { SurePkg } );
    if SR.hPath >= 0 then
      SR.UnitName := StrPas(CP + 1);
    SR.UnitName := ChangeFileExt(SR.UnitName, '');
    Exit;
  end;
  { if ExtractFileExt(SR.FN)='' then
    SR.FN := SR.FN+'.dcu'; }
  SR.UnitName := ExtractFileName(SR.FN);
  SR.FN := SR.FN + FExt;
  (*
    if (DCUPath='') then
    DCUPath := Dir
    else
    DCUPath := Dir + {$IFNDEF LINUX}';'{$ELSE}';'{$ENDIF}+DCUPath;
  *)
  if not AddedUnitDir then
    AddToPathList(Dir, false { SurePkg } );
  if Dir = '' then
    SR.hPath := 0;
end;

function FindDCU(var SR: TDCUSearchRec): String;
var
  S: String;
  Pkg: TDCPackage;
begin
  Result := '';
  SR.Res := Nil;
  if SR.hPath < 0 then
  begin
    if FileExists(SR.FN) then
      Result := SR.FN;
    Exit;
  end;
  if PathList = Nil then
    Exit { Paranoic };
  if SR.hPath >= PathList.Count then
    SR.hPath := -1
  else
  begin
    S := PathList[SR.hPath];
    Pkg := TDCPackage(PathList.Objects[SR.hPath]);
    Inc(SR.hPath);
    if Pkg = Nil then
    begin
      if S = '*' + DirSep then
        Exit;
      Result := S + SR.FN;
      if FileExists(Result) then
        Exit;
      Result := '';
    end
    else if Pkg.Load(S, false) then
    begin
      SR.Res := Pkg.GetFileByName(SR.UnitName);
      if SR.Res <> Nil then
        Result := S + PkgSep + SR.UnitName + ExtractFileExt(SR.FN);
    end;
  end;
end;

var
  UnitList: TStringList = Nil;

function GetUnitList: TStringList;
begin
  if UnitList = Nil then
  begin
    UnitList := TStringList.Create;
    UnitList.Sorted := true;
    UnitList.Duplicates := dupError;
  end;
  Result := UnitList;
end;

procedure RegisterUnit(const Name: String; U: TUnit);
var
  UL: TStringList;
begin
  UL := GetUnitList;
  UL.AddObject(Name, U);
end;

procedure NeedPathList;
begin
  if PathList = Nil then
  begin
    PathList := TStringList.Create;
    SetPathList(DCUPath);
  end;
end;

function GetDCUByName(FName, FExt: String; VerRq: integer; MSILRq: Boolean;
  PlatformRq: TDCUPlatform; StampRq: integer): TUnit;
var
  UL: TStringList;
  NDX: integer;
  U0: TUnit;
  // SearchPath: String;
  SR: TDCUSearchRec;
  FN, UnitName: String;
  HasPath: Boolean;
  Cl: TUnitClass;
begin
  UL := GetUnitList;
  NeedPathList;
  if (AutoLibDirNDX >= 0) and (VerRq > 0) then
  begin
    FN := GetDelphiLibDir(VerRq, MSILRq, PlatformRq);
    if (FN <> '') and (PathList.IndexOf(FN) >= 0) then
      FN := '';
    if FN = '' then
      PathList.Delete(AutoLibDirNDX)
    else
      PathList[AutoLibDirNDX] := FN;
    AutoLibDirNDX := -1; // Substitution for * was made
  end;
  { if not AddedUnitDirToPath then begin
    AddUnitDirToPath(FName);
    AddedUnitDirToPath := true;
    end ; }
  UnitName := ExtractFileNamePkg(FName);
  HasPath := Length(UnitName) < Length(FName);
  if HasPath or (FExt = '' { FExt is not empty for the units from uses } ) then
    UnitName := ChangeFileExt(UnitName, '');
  if not HasPath and (FUnitAliases <> Nil) then
  begin
    FN := FUnitAliases.Values[UnitName { FName } ];
    if FN <> '' then
    begin
      UnitName { FName } := FN;
      FName { FName } := FN;
    end;
  end;
  if IgnoreUnitStamps or
    not((VerRq > verD2) { In Delphi 2.0 Stamp is not used } and (VerRq <= verD7)
    { The higher versions ignore the value too } or (VerRq >= verK1)) then
    StampRq := 0;
  if UL.Find(UnitName { FName } , NDX) then
    Result := TUnit(UL.Objects[NDX])
  else
  begin
    InitDCUSearch(FName, FExt, SR);
    // SearchPath := DCUPath;
    Result := Nil;
    U0 := CurUnit;
    try
      FN := FName;
      repeat
        FName := FindDCU(SR);
        if FName <> '' then
        begin
          if VerRq = 0 then
            Cl := TopLevelUnitClass
          else
            Cl := TUnit;
          Result := Cl.Create;
          try
            if Result.Load(FName, VerRq, MSILRq, PlatformRq, SR.Res) then
            begin
              if (StampRq = 0) or (StampRq = Result.Stamp)
              then { Let`s check it here to try to find the correct stamp somewhere else }
                Break;
            end;
          except
            on E: Exception do
            begin
              if VerRq = 0 then // Main Unit => reraise;
                raise;
              // The unit with the required version found, but it was wrong.
              // Report the problem and stop the search
              Writeln(Format('!!!%s: %s', [E.ClassName, E.Message]));
              Result.Free;
              Result := Nil;
              Break;
            end;
          end;
          Result.Free;
          Result := Nil;
        end;
      until SR.hPath < 0;
      if Result <> Nil then
        RegisterUnit
          (UnitName { Result.UnitName - some units in packages may have different source file name } ,
          Result)
      else
        RegisterUnit(FN, Nil); // Means: don't seek this name again,
      // It's supposed that FName is a unit name without path
    finally
      CurUnit := U0;
    end;
  end;
  if Result = Nil then
    Exit;
  if (StampRq <> 0) and (StampRq <> Result.Stamp) then
    Result := Nil;
end;

function GetDCUOfMemory(MemP: Pointer): TUnit;
var
  UL: TStringList;
  U: TUnit;
  i: integer;
begin
  if MemP <> Nil then
  begin
    if (CurUnit <> Nil) and CurUnit.IsValidMemPtr(MemP) then
    begin
      Result := CurUnit;
      Exit;
    end;
    UL := GetUnitList;
    for i := 0 to UL.Count - 1 do
    begin
      U := TUnit(UL.Objects[i]);
      if (U <> Nil) and U.IsValidMemPtr(MemP) then
      begin
        Result := U;
        Exit;
      end;
    end;
  end;
  Result := Nil;
end;

procedure FreeDCU;
var
  i: integer;
  U: TUnit;
begin
  if UnitList = Nil then
    Exit;
  for i := 0 to UnitList.Count - 1 do
  begin
    U := TUnit(UnitList.Objects[i]);
    U.Free;
  end;
  UnitList.Free;
  UnitList := Nil;
  FreePackages;
end;

function FindPAS(FName: String): String;
var
  S: String;
begin
  if PASPath = '*' then
  begin
    Result := '';
    Exit;
  end;
  S := ExtractFilePath(FName);
  if S <> '' then
  begin
    if FileExists(FName) then
    begin
      Result := FName;
      Exit;
    end;
    FName := ExtractFileName(FName);
  end;
  Result := FileSearch(FName, PASPath);
end;

procedure LoadSourceLines(FName: String; Lines: TStrings);
var
  S: String;
begin
  S := FindPAS(FName);
  if S = '' then
    Exit;
  Lines.LoadFromFile(S);
end;

procedure SetUnitAliases(const V: String);
var
  CP, EP, NP: PChar;
  S: String;
begin
  if FUnitAliases <> Nil then
    FUnitAliases.Clear;
  if V = '' then
    Exit;
  if FUnitAliases = Nil then
    FUnitAliases := TStringList.Create;
  CP := PChar(V);
  repeat
    NP := StrScan(CP, ';');
    if NP = Nil then
      EP := StrEnd(CP)
    else
    begin
      EP := NP;
      NP := EP + 1;
    end;
    SetString(S, CP, EP - CP);
    if S <> '' then
      FUnitAliases.Add(S);
    CP := NP;
  until CP = Nil;
end;

function LoadPackage(const FName: String; IsMain: Boolean): TDCPackage;
var
  hPkg: integer;
begin
  Result := Nil;
  NeedPathList;
  hPkg := AddToPathList(FName, true { SurePkg } );
  if hPkg < 0 then
    Exit;
  Result := TDCPackage(PathList.Objects[hPkg]);
  if Result = Nil then
    Exit;
  if not Result.Load(FName, IsMain) then
    Result := Nil;
end;

initialization

finalization

FUnitAliases.Free;
PathList.Free;

end.
