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

{$I CnPack.inc}

uses
  SysUtils,Classes,DCU32,DCP;

const
  PathSep = {$IFNDEF LINUX}';'{$ELSE}':'{$ENDIF};
  DirSep = {$IFNDEF LINUX}'\'{$ELSE}'/'{$ENDIF};
  PkgSep = '@';

var
  DCUPath: String='';
  PASPath: String='*' {Let only presence of -P signals, that source lines are required};

function GetDCUByName(FName,FExt: String; VerRq: integer; MSILRq: boolean; StampRq: integer): TUnit;

procedure FreeDCU;

procedure LoadSourceLines(FName: String; Lines: TStrings);

procedure SetUnitAliases(V: String);

implementation

{const
  PkgErr = Pointer(1);}

var
  PathList: TStringList = Nil;
  FUnitAliases: TStringList = Nil;
  AddedUnitDirToPath: boolean = false;

procedure FreePackages;
var
  i: integer;
  Pkg: TDCPackage;
begin
  if PathList=Nil then
    Exit;
  for i:=0 to PathList.Count-1 do begin
    Pkg := TDCPackage(PathList.Objects[i]);
    {if Pkg=PkgErr then
      Continue;}
    Pkg.Free;
  end ;
end ;

function AddToPathList(S: String; SurePkg: boolean): integer;
begin
  Result := PathList.IndexOf(S);
  if Result>=0 then
    Exit; {It may be wrong on Unix}
  if SurePkg or (CompareText(ExtractFileExt(S),'.dcp')=0) then begin
    if FileExists(S) then begin
      Result := PathList.AddObject(S,TDCPackage.Create);
      Exit;
    end ;
    Result := -1;
    if SurePkg then
      Exit;
  end ;
  if not (
  {$IFDEF DELPHI2009_UP}
  CharInSet(AnsiLastChar(S)^, [{$IFNDEF Linux}':',{$ENDIF} DirSep])
  {$ELSE}
  AnsiLastChar(S)^ in [{$IFNDEF Linux}':',{$ENDIF} DirSep]
  {$ENDIF}
  ) then
    S := S + DirSep;
  Result := PathList.Add(S);
end ;

procedure SetPathList(DirList: string);
var
  I, P, L: Integer;
begin
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
      if
      {$IFDEF DELPHI2009_UP}
      CharInSet(DirList[P], LeadBytes)
      {$ELSE}
      DirList[P] in LeadBytes
      {$ENDIF}
      then
        Inc(P);
      Inc(P);
    end;
    AddToPathList(Copy(DirList, I, P-I),False{SurePkg});
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
  FN,UnitName: String;
  Res: PDCPUnitHdr;
end ;

function InitDCUSearch(FN,FExt: String; var SR: TDCUSearchRec): boolean {HasPath};
var
  Dir: String;
  CP: PChar;
  AddedUnitDir: boolean;
begin
  FillChar(SR,SizeOf(TDCUSearchRec),0);
  SR.FN := FN;
  SR.hPath := -1;
  Dir := ExtractFileDir(FN);
  Result := Dir<>'';
  AddedUnitDir := AddedUnitDirToPath;
  if not AddedUnitDirToPath then begin
    if (PASPath<>'*') then begin
      if (PASPath='') then
        PASPath := Dir
      else
        PASPath := Dir + PathSep + PASPath;
    end ;
    AddedUnitDirToPath := true;
  end ;
  CP := PChar(FN)+Length(Dir);
  CP := StrScan(CP,PkgSep);
  if CP<>Nil then begin
    SetLength(FN,CP-PChar(FN)); //Package name with path
    SR.hPath := AddToPathList(FN,true{SurePkg});
    if SR.hPath>=0 then
      SR.UnitName := StrPas(CP+1);
    SR.UnitName := ChangeFileExt(SR.UnitName,'');
    Exit;
  end ;
  {if ExtractFileExt(SR.FN)='' then
    SR.FN := SR.FN+'.dcu';}
  SR.FN := SR.FN+FExt;
 (*
  if (DCUPath='') then
    DCUPath := Dir
  else
    DCUPath := Dir + {$IFNDEF LINUX}';'{$ELSE}';'{$ENDIF}+DCUPath;
  *)
  if not AddedUnitDir then
    AddToPathList(Dir,False{SurePkg});
  if Dir='' then
    SR.hPath := 0;
end ;


function FindDCU(var SR: TDCUSearchRec): String;
var
  S: String;
  Pkg: TDCPackage;
begin
  Result := '';
  SR.Res := Nil;
  if SR.hPath<0 then begin
    if FileExists(SR.FN) then
      Result := SR.FN;
    Exit;
  end ;
  if PathList=Nil then
    Exit {Paranoic};
  if SR.hPath>=PathList.Count then
    SR.hPath := -1
  else begin
    S := PathList[SR.hPath];
    Pkg := TDCPackage(PathList.Objects[SR.hPath]);
    Inc(SR.hPath);
    if Pkg=Nil then begin
      Result := S+SR.FN;
      if FileExists(Result) then
        Exit;
      Result := '';
     end
    else if Pkg.Load(S) then begin
      SR.Res := Pkg.GetFileByName(SR.UnitName);
      if SR.Res<>Nil then
        Result := S+'@'+SR.UnitName;
    end ;
  end ;
end ;

var
  UnitList: TStringList = Nil;

function GetUnitList: TStringList;
begin
  if UnitList=Nil then begin
    UnitList := TStringList.Create;
    UnitList.Sorted := true;
    UnitList.Duplicates := dupError;
  end ;
  Result := UnitList;
end ;

procedure RegisterUnit(Name: String; U: TUnit);
var
  UL: TStringList;
begin
  UL := GetUnitList;
  UL.AddObject(Name,U);
end ;

function GetDCUByName(FName,FExt: String; VerRq: integer; MSILRq: boolean; StampRq: integer): TUnit;
var
  UL: TStringList;
  NDX: integer;
  U0: TUnit;
//  SearchPath: String;
  SR: TDCUSearchRec;
  FN: String;
begin
  UL := GetUnitList;
  if PathList=Nil then begin
    PathList := TStringList.Create;
    SetPathList(DCUPath);
  end ;
  {if not AddedUnitDirToPath then begin
    AddUnitDirToPath(FName);
    AddedUnitDirToPath := true;
  end ;}
  if FUnitAliases<>Nil then begin
    FN := FUnitAliases.Values[FName];
    if FN<>'' then
      FName := FN;
  end ;
  if UL.Find(FName,NDX) then
    Result := TUnit(UL.Objects[NDX])
  else begin
    InitDCUSearch(FName,FExt,SR);
   // SearchPath := DCUPath;
    Result := Nil;
    U0 := CurUnit;
    try
      FN := FName;
      repeat
        FName := FindDCU(SR);
        if FName<>'' then begin
          Result := TUnit.Create;
          try
            if Result.Load(FName,VerRq,MSILRq,SR.Res) then
              break;
          except
            on E: Exception do begin
              if VerRq=0 then //Main Unit => reraise;
                raise;
            //The unit with the required version found, but it was wrong.
            //Report the problem and stop the search
              Writeln(Format('%s: %s',[E.ClassName,E.Message]));
              Result.Free;
              Result := Nil;
              break;
            end ;
          end ;
          Result.Free;
          Result := Nil;
        end ;
      until SR.hPath<0;
      if Result<>Nil then
        RegisterUnit(Result.UnitName, Result)
      else
        RegisterUnit(FN, Nil); //Means: don't seek this name again,
          //It's supposed that FName is a unit name without path
    finally
      CurUnit := U0;
    end ;
  end ;
  if Result=Nil then
    Exit;
  if (VerRq>2){In Delphi 2.0 Stamp is not used}and(StampRq<>0)
    and(StampRq<>Result.Stamp)
  then
    Result := Nil;
end ;

procedure FreeDCU;
var
  i: integer;
  U: TUnit;
begin
  if UnitList=Nil then
    Exit;
  for i:=0 to UnitList.Count-1 do begin
    U := TUnit(UnitList.Objects[i]);
    U.Free;
  end ;
  UnitList.Free;
  UnitList := Nil;
  FreePackages;
end ;

function FindPAS(FName: String): String;
var
  S: String;
begin
  if PASPath='*' then begin
    Result := '';
    Exit;
  end ;
  S := ExtractFilePath(FName);
  if S<>'' then begin
    if FileExists(FName) then begin
      Result := FName;
      Exit;
    end ;
    FName := ExtractFileName(FName);
  end ;
  Result := FileSearch(FName,PASPath);
end ;

procedure LoadSourceLines(FName: String; Lines: TStrings);
var
  S: String;
begin
  S := FindPAS(FName);
  if S='' then
    Exit;
  Lines.LoadFromFile(S);
end ;

procedure SetUnitAliases(V: String);
var
  CP,EP,NP: PChar;
  S: String;
begin
  if V='' then
    Exit;
  if FUnitAliases=Nil then
    FUnitAliases := TStringList.Create;
  CP := PChar(V);
  repeat
    NP := StrScan(CP,';');
    if NP=Nil then
      EP := StrEnd(CP)
    else begin
      EP := NP;
      NP := EP+1;
    end ;
    SetString(S,CP,EP-CP);
    if S<>'' then
      FUnitAliases.Add(S);
    CP := NP;
  until CP=Nil;
end ;

initialization
finalization
  FUnitAliases.Free;
  PathList.Free;
end.
