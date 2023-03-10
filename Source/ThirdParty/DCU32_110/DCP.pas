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
  SysUtils, Classes;

type

  PDCPHdr = ^TDCPHdr;

  TDCPHdr = record
    { %$IF MSIL;
      ulong X0 //DCPIL files contain additional DWORD
      %$END }
    nRequires, nContains: LongInt;
    SzContains: Cardinal;
    pContains: Cardinal;
    // The rest of header is ignored here
  end;

  PDCPUnitHdr = ^TDCPUnitHdr;

  TDCPUnitHdr = record
    Magic: LongInt;
    FileSize: LongInt;
  end;

  PDCPUnitInfo = ^TDCPUnitInfo;

  TDCPUnitInfo = record
    pData: Cardinal; // PDCPUnitHdr
    F, FT: Cardinal;
    bplCode, bplData: LongInt;
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
      %$END }
  end;

  TDCPLoadState = (dcplNotLoaded, dcplHeaderLoaded, dcplAllLoaded);

  TDCPackage = class(TStringList)
    protected
      FFName: String; // for the two phase loading mode
      FMemPtr: Pointer;
      FMemSize, FSizeR: Cardinal;
      FOk: boolean;
      FLoaded: TDCPLoadState;
      procedure AllLoadedRequired;
      function GetFileData(i: Integer): PDCPUnitHdr;
      function CheckDCPOfs(Ofs: Cardinal; const Msg: String): Pointer;
    public
      destructor Destroy; override;
      function Load(const FN: String; IsMain: boolean): boolean;
      function GetFileByName(const Name: String): PDCPUnitHdr;
      property FileData[i: Integer]: PDCPUnitHdr read GetFileData;
  end;

var
  TwoPhaseDCPLoad: boolean = true; // false => load all data at once,
  // true => load header and all the other data before fetching 1st unit
  TwoPhaseDCPSizeLimit: Cardinal = 65536; // Heuristic limit, smaller or eq packages won't be loaded in two phases
  TwoPhaseInitSize: Cardinal = $800; // Should be < TwoPhaseDCPSizeLimit and >$24 (The largest package header size)

implementation

type
  TIncPtr = PAnsiChar;

procedure DCPErr(const Msg: String);
  begin
    raise Exception.Create(Msg);
  end;

{ TDCPackage. }
destructor TDCPackage.Destroy;
  begin
    if FMemPtr <> Nil then
        FreeMem(FMemPtr, FMemSize);
    inherited Destroy;
  end;

function TDCPackage.CheckDCPOfs(Ofs: Cardinal; const Msg: String): Pointer;
  begin
    if (Ofs < 0) or (Ofs >= FMemSize) then
        DCPErr(Msg);
    Result := TIncPtr(FMemPtr) + Ofs;
  end;

type
  TMagicChars = array [0 .. 3] of AnsiChar;

const
  DCPMagic: TMagicChars = 'PKG'#0;
  DCPMagicX: TMagicChars = 'PKX0';
  DCPMagicMask = $00FFFFFF;

function TDCPackage.Load(const FN: String; IsMain: boolean): boolean;
  var
    F: File;
    TwoPhase, isMSIL: boolean;
    Magic: LongInt;
    DP: Pointer;
    SzRq: Cardinal;
    VerCh: AnsiChar;
    Hdr: PDCPHdr;
    NP, EP: PAnsiChar;
    UI, UI0: PDCPUnitInfo;
    UD: PDCPUnitHdr;
    i, l, NChk: Integer;
    NS: String;

  begin
    if FLoaded > dcplNotLoaded then begin
        Result := FOk;
        Exit;
      end;
    TwoPhase := false;
    FLoaded := dcplAllLoaded;
    Result := false;
    FFName := FN;
    AssignFile(F, FN);
    FileMode := 0; // Read only, helps with DCUs on CD
    Reset(F, 1);
    try
      FMemSize := FileSize(F);
      if FMemSize < $40 then
          DCPErr('Package file is too small.');
      GetMem(FMemPtr, FMemSize);
      // We'll alloc all the memory at once anyway, cause even for DXE6\win64
      // all the *.DCP files take less than 200Mb - easily fits into memory of any computer
      FSizeR := FMemSize;
      if TwoPhaseDCPLoad and not IsMain and (FMemSize > TwoPhaseDCPSizeLimit) then begin
          FLoaded := dcplHeaderLoaded;
          TwoPhase := true;
          FSizeR := TwoPhaseInitSize;
        end;
      BlockRead(F, FMemPtr^, FSizeR);
      isMSIL := UpCase(FN[Length(FN)]) = 'L'; // DCPIL
      DP := FMemPtr;
      Magic := LongInt(DP^);
      Inc(TIncPtr(DP), SizeOf(LongInt));
      if Magic = LongInt(DCPMagicX) then begin
          VerCh := 'X';
          NChk := 3;
        end
      else begin
          NChk := 0;
          if (Magic and DCPMagicMask) <> LongInt(DCPMagic) then
              DCPErr('Wrong PKG magic.');
          VerCh := TMagicChars(Magic)[3];
          if (VerCh < '4') or (VerCh > '9') or (VerCh = '6') or (VerCh = '8') then
              DCPErr('Wrong PKG version.');
        end;
      if isMSIL then
          Inc(TIncPtr(DP), SizeOf(LongInt)); // MSIL
      Hdr := DP;
      if (Hdr^.nRequires > $100 { Empirical limitation } ) or (Hdr^.nRequires < 0) then
          DCPErr('Package requires too much.');
      UI0 := CheckDCPOfs(Hdr^.pContains, 'Wrong contains pointer.');
      EP := CheckDCPOfs(Hdr^.pContains + Hdr^.SzContains, 'Wrong contains size.');
      if TwoPhase then begin
          SzRq := Hdr^.pContains + Hdr^.SzContains;
          if SzRq > FSizeR then begin
              BlockRead(F, TIncPtr(FMemPtr)[FSizeR], SzRq - FSizeR);
              FSizeR := SzRq;
            end;
        end;
    finally
        Close(F);
    end;
    if (EP - 1)^ <> #0 then // Make sure that the last char is #0 => StrLen is safe
        DCPErr('Bad package Contains table end.');
    repeat // The loop is used to detect the valid version of DCP with PKX0 magic
      UI := UI0;
      try
        EP := TIncPtr(UI0);
        for i := 0 to Hdr^.nContains - 1 do begin
            if (TIncPtr(UI) - TIncPtr(UI0) + SizeOf(TDCPUnitInfo) >= Hdr^.SzContains) then
                break;
            UD := CheckDCPOfs(UI^.pData, 'Wrong unit data pointer.');
            if not TwoPhase then
                CheckDCPOfs(UI^.pData + UD^.FileSize - 1, 'Wrong unit data size');
            NP := TIncPtr(UI) + SizeOf(TDCPUnitInfo);
            if VerCh > '4' then
                Inc(NP, SizeOf(LongInt));
            if (VerCh >= '9') or isMSIL then
                Inc(NP, SizeOf(LongInt));
            if (VerCh >= 'X') then
                Inc(NP, (5 + NChk) * SizeOf(LongInt));
            if (TIncPtr(NP) - TIncPtr(UI0) >= Hdr^.SzContains) then
                break;
            EP := StrEnd(NP);
            l := EP - NP;
            if l > 255 then
                DCPErr('Too long unit name.');
            SetString(NS, NP, l);
            AddObject(NS, Pointer(UD));
            Inc(EP);
            if VerCh >= '9' then begin
                if (TIncPtr(EP) - TIncPtr(UI0) >= Hdr^.SzContains) then begin
                    Inc(EP); // make it >Hdr^.SzContains
                    break;
                  end;
                EP := StrEnd(EP);
                Inc(EP);
              end;
            UI := Pointer(EP);
          end;
        if (EP - TIncPtr(UI0) = Hdr^.SzContains) then
            break { Good NChk found };
        if (NChk <= 0) then
            DCPErr('Bad Contains size.');
      except
        if NChk <= 0 then
            raise;
      end;
      Dec(NChk, 3);
      Clear;
    until NChk < 0;
    FOk := true;
    Result := true;
  end;

procedure TDCPackage.AllLoadedRequired;
  var
    F: File;
    SzR: Integer;
  begin
    FLoaded := dcplAllLoaded;
    if FSizeR >= FMemSize then
        Exit { Paranoic };
    AssignFile(F, FFName);
    FileMode := 0; // Read only, helps with DCUs on CD
    Reset(F, 1);
    try
      Seek(F, FSizeR);
      BlockRead(F, TIncPtr(FMemPtr)[FSizeR], FMemSize - FSizeR, SzR);
      Inc(FSizeR, SzR);
      if FSizeR < FMemSize then begin
          FillChar(TIncPtr(FMemPtr)[FSizeR], FMemSize - FSizeR, 0); // The error is not reported, but the memory will be zeroed
          FOk := false;
        end;
    finally
        Close(F);
    end;
  end;

function TDCPackage.GetFileByName(const Name: String): PDCPUnitHdr;
  var
    i: Integer;
  begin
    Result := Nil;
    i := IndexOf(Name);
    if i < 0 then
        Exit;
    if (FLoaded = dcplHeaderLoaded) and FOk then
        AllLoadedRequired;
    Result := PDCPUnitHdr(Objects[i]);
    if TIncPtr(Result) - TIncPtr(FMemPtr) + Result^.FileSize > FMemSize then
        Result := Nil; // For TwoPhase mode
  end;

function TDCPackage.GetFileData(i: Integer): PDCPUnitHdr;
  begin
    if (FLoaded = dcplHeaderLoaded) and FOk then
        AllLoadedRequired;
    Result := PDCPUnitHdr(Objects[i]);
  end;

end.
