unit DCP;

interface
(*
The *.DCP (Delphi Compiled Package) support routines and data types
of the DCU32INT utility by Alexei Hmelnov.
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

uses
  SysUtils,Classes;

{$WARNINGS OFF}
{$HINTS OFF}

type

PDCPHdr = ^TDCPHdr;
TDCPHdr = record
{ %$IF MSIL;
  ulong X0 //DCPIL files contain additional DWORD
 %$END }
  nRequires,nContains: LongInt;
  Sz1: Cardinal;
  pContains: Cardinal;
 //The rest of header is ignored here
end ;


PDCPUnitHdr = ^TDCPUnitHdr;
TDCPUnitHdr = record
  Magic: LongInt;
  FileSize: LongInt;
end ;

PDCPUnitInfo = ^TDCPUnitInfo;
TDCPUnitInfo = record
  pData: Cardinal; //PDCPUnitHdr
  F,FT: Cardinal;
  bplCode,bplData: LongInt;
 {
 %$IF Ver>4; //Not checked for D4
  ulong bplBSS
 %$END
 %$IF (Ver>=9)or MSIL;
  ulong X
 %$END
  PChar Name
 %$IF Ver>=9;
  PChar Name1
 %$END}
end ;

TDCPackage = class(TStringList)
 protected
  FMemPtr: Pointer;
  FMemSize: Cardinal;
  FOk,FLoaded: boolean;
 public
  destructor Destroy; override;
  function Load(FN: String): boolean;
  function GetFileByName(Name: String): PDCPUnitHdr;
end ;

implementation

{ TDCPackage. }
destructor TDCPackage.Destroy;
begin
  if FMemPtr<>Nil then
    FreeMem(FMemPtr,FMemSize);
  inherited Destroy;
end ;

type
  TMagicChars = array[0..3]of AnsiChar;

const
  DCPMagic: TMagicChars = AnsiString('PKG'#0);
  DCPMagicMask = $00FFFFFF;

function TDCPackage.Load(FN: String): boolean;
var
  F: File;
  Magic: LongInt;
  DP: Pointer;
  VerCh: AnsiChar;
  Hdr: PDCPHdr;
  NP,EP: PChar;
  UI: PDCPUnitInfo;
  UD: PDCPUnitHdr;
  i,l: integer;
  NS: String;

  procedure DCPErr(Msg: String);
  begin
    raise Exception.Create(Msg);
  end ;

  function CheckDCPOfs(Ofs: Cardinal; Msg: String): Pointer;
  begin
    if (Ofs<0)or(Ofs>=FMemSize) then
      DCPErr(Msg);
    Result := PChar(FMemPtr)+Ofs;
  end ;

begin
  if FLoaded then begin
    Result := FOk;
    Exit;
  end ;
  FLoaded := true;
  Result := false;
  AssignFile(F,FN);
  FileMode := 0; //Read only, helps with DCUs on CD
  Reset(F,1);
  try
    FMemSize := FileSize(F);
    if FMemSize<$40 then
      DCPErr('Package file is too small.');
    GetMem(FMemPtr,FMemSize);
    BlockRead(F,FMemPtr^,FMemSize);
  finally
    Close(F);
  end ;
  DP := FMemPtr;
  Magic := LongInt(DP^);
  Inc(PChar(DP),SizeOf(LongInt));
  if (Magic and DCPMagicMask)<>LongInt(DCPMagic) then
    DCPErr('Wrong PKG magic.');
  VerCh := TMagicChars(Magic)[3];
  if (VerCh<'4')or(VerCh>'9')or(VerCh='6')or(VerCh='8') then
    DCPErr('Wrong PKG version.');
  Hdr := DP;
  if (Hdr^.nRequires>$100{Empirical limitation})or(Hdr^.nRequires<0) then
    DCPErr('Package requires too much.');
  UI := CheckDCPOfs(Hdr^.pContains,'Wrong contains pointer.');
  for i:=0 to Hdr^.nContains-1 do begin
    UD := CheckDCPOfs(UI^.pData,'Wrong unit data pointer.');
    CheckDCPOfs(UI^.pData+UD^.FileSize-1,'Wrong unit data size');
    NP := PChar(UI)+SizeOf(TDCPUnitInfo);
    if VerCh>'4' then
      Inc(NP,SizeOf(LongInt));
    if VerCh>='9' then
      Inc(NP,SizeOf(LongInt));
    EP := StrEnd(NP);
    l := EP-NP;
    if l>255 then
      DCPErr('Too long unit name.');
    SetString(NS,NP,l);
    AddObject(NS,Pointer(UD));
    Inc(EP);
    if VerCh>='9' then begin
      EP := StrEnd(EP);
      Inc(EP);
    end ;
    UI := Pointer(EP);
  end ;
  FOk := true;
  Result := true;
end ;

function TDCPackage.GetFileByName(Name: String): PDCPUnitHdr;
var
  i: integer;
begin
  Result := Nil;
  i := IndexOf(Name);
  if i<0 then
    Exit;
  Result := PDCPUnitHdr(Objects[i]);
end ;

procedure FreePackages;
begin
end ;

end.
