{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit DCU_In;
(*
The DCU input module of the DCU32INT utility by Alexei Hmelnov.
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

{$IFDEF VER100}
{$DEFINE D3dn}
{$ENDIF}
{$IFDEF VER90}
{$DEFINE D3dn}
{$ENDIF}
uses
  {$IFDEF UNICODE}AnsiStrings,{$ENDIF}SysUtils;

type
  TDCURecTag = Byte{Char};

  TNDX = integer;

  TNameRecData = packed record
   case Integer of
    0: (S: ShortString);
    1: (bLen: Byte; dwLen: LongInt; lS: array[Word]of AnsiChar);
  end ;

  PName = ^TNameRec;
  TNameRec = object
   protected
    D: TNameRecData;
   public
    function IsEmpty: Boolean;
    function Get1stChar: AnsiChar;
    function GetStr: AnsiString;
    function GetRightStr(dl: Cardinal): AnsiString;
    function Eq(N: PName): Boolean;
    function EqS(const S: ShortString): Boolean;
  end ;

  PShortName = PShortString;

  PInt64Rec = ^TInt64Rec;
  TInt64Rec = record
    case integer of
     0: (Lo: LongInt; Hi: LongInt);
   {$IFNDEF VER100 - D30}
     1: (Val: Int64);
   {$ENDIF}
  end ;

  TByteSet = set of Byte;
  TIncPtr = PAnsiChar;

const
  {Local flags}
  lfClass = $1;{class procedure }
  lfClassV8up = $10;{class procedure for Versions 8 up}
  lfPrivate = $0;
  lfPublic = $2;
  lfProtected = $4;
  lfPublished = $A;
  lfScope = $0E { $0F};
  lfDeftProp = $20;
  lfOverride = $20;
  lfVirtual = $40;
  lfDynamic = $80;
  lfMessage = $C0;
  lfMethodKind = $C0;

  lfauxPropField = $80000000; //my own (AX) flag to mark the aux fields for properties

type
TDefNDX = TNDX;

PPNDXTbl = ^PNDXTbl;
PNDXTbl = ^TNDXTbl;
TNDXTbl = array[Byte]of TNDX;

PDef = ^Pointer;
PNameDef = ^TNameDef;
TNameDef = packed record
  Tag: TDCURecTag;
  Name: TNameRec;
end ;

ulong = {$IFDEF D3dn}cardinal{$ELSE}LongWord{$ENDIF};
TDCUFileTime = Integer;

{$IFDEF D3dn}
TQWORD = Comp;
{$ELSE}
TQWORD = Int64;
{$ENDIF}
PQWORD = ^TQWORD;

TMemStrRef = object //Representation of string from DCU memory without copying chars
 protected
  FChars: PAnsiChar;
  FLen: Cardinal;
 public
  function S: AnsiString;
  property Len: Cardinal read FLen;
end;

type
  TScanState=record
    StartPos,CurPos,EndPos: TIncPtr;
  end ;

var
  ScSt: TScanState;
  DefStart: Pointer;
  Tag: TDCURecTag;

procedure ChangeScanState(var State: TScanState; DP: Pointer; MaxSz: Cardinal);
procedure RestoreScanState(const State: TScanState);

//function IsEOF: boolean;

function ReadTag: TDCURecTag;
function ReadByte: Byte;
function ReadWord: Word;
function ReadULong: ulong;

procedure SkipBlock(Sz: Cardinal);
procedure ReadBlock(var B; Sz: Cardinal);

function ReadMem(Sz: Cardinal): Pointer;

function ReadStr: ShortString;
function ReadShortName: PShortName;
function ReadName: PName;
function StrLEnd(Str: PAnsiChar; L: Cardinal): PAnsiChar;

function ReadNDXStr: AnsiString;
function ReadNDXStrRef: TMemStrRef;
function GetNDXStr(DP: Pointer): AnsiString;
function ReadByteIfEQ(V: byte): Cardinal;
function ReadByteFrom(const S: TByteSet): Integer;

var
  NDXHi: LongInt;

function ReadUIndex: LongInt;
function ReadIndex: LongInt;

procedure ReadIndex64(var Res: TInt64Rec);
procedure ReadUIndex64(var Res: TInt64Rec);

function SkipDataUntil(B: Byte): TIncPtr;

function NDXToStr(NDXLo: LongInt): AnsiString;

function MemToInt(DP: Pointer; Sz: Cardinal; var Res: integer): boolean;
function MemToUInt(DP: Pointer; Sz: Cardinal; var Res: Cardinal): boolean;

type
  EDCUFmtError = class(Exception)
  end ;

procedure DCUError(const Msg: String);
procedure DCUErrorFmt(const Msg: String; Args: array of const);
procedure DCUWarning(const Msg: String);
procedure DCUWarningFmt(const Msg: String; Args: array of const);
procedure TagError(const Msg: String);

function ExtractFileNameAnySep(const FN: String): String;

function AllocName(const S: AnsiString): PName;
procedure FreeName(NP: PName);

implementation

uses
  DCU32{CurUnit};

procedure DCUError(const Msg: String);
var
  US: String;
  TagC: AnsiChar;
begin
  US := '';
  if CurUnit<>MainUnit then begin
    US := CurUnit.UnitName;
    if US='' then
      US := ChangeFileExt(ExtractFileName(CurUnit.FileName),'');
    US := Format(' in %s ',[US]);
  end ;
  TagC := AnsiChar(Tag);
  if TagC<' ' then
    TagC := '.';
  if ScSt.EndPos<>Nil then
    US := Format('Error at 0x%x%s(Def: 0x%x, Tag="%s"(0x%x)): %s',
      [ScSt.CurPos-ScSt.StartPos,US,TIncPtr(DefStart)-ScSt.StartPos,TagC,Byte(Tag),Msg])
  else
    US := Format('Error%s: %s',[US,Msg]);
  raise EDCUFmtError.Create(US);
end ;

procedure DCUErrorFmt(const Msg: String; Args: array of const);
begin
  DCUError(Format(Msg,Args));
end ;

procedure DCUWarning(const Msg: String);
var
  US: String;
begin
  US := '';
  if CurUnit<>MainUnit then begin
    US := CurUnit.UnitName;
    if US='' then
      US := ChangeFileExt(ExtractFileName(CurUnit.FileName),'');
    US := Format(' in %s ',[US]);
  end ;
  if ScSt.EndPos<>Nil then
    US := Format('Warning at 0x%x%s(Def: 0x%x, Tag="%s"(0x%x)): %s',
      [ScSt.CurPos-ScSt.StartPos,US,TIncPtr(DefStart)-ScSt.StartPos,AnsiChar(Tag),Byte(Tag),Msg])
  else
    US := Format('Warning%s: %s',[US,Msg]);
  // Writeln(US);
end ;

procedure DCUWarningFmt(const Msg: String; Args: array of const);
begin
  DCUWarning(Format(Msg,Args));
end ;

procedure TagError(const Msg: String);
begin
  DCUErrorFmt('%s: wrong tag "%s"=0x%x',[Msg,AnsiChar(Tag),Byte(Tag)]);
end ;

procedure ChangeScanState(var State: TScanState; DP: Pointer; MaxSz: Cardinal);
begin
  State := ScSt;
  ScSt.StartPos := DP;
  ScSt.CurPos := DP;
  ScSt.EndPos := TIncPtr(DP)+MaxSz;
end ;

procedure RestoreScanState(const State: TScanState);
begin
  ScSt := State;
end ;

{ TMemStrRef. }
function TMemStrRef.S: AnsiString;
begin
  SetString(Result,FChars,FLen);
end;

procedure ChkSize(Sz: Cardinal);
begin
  if integer(Sz)<0 then
    DCUErrorFmt('Negative block size %d',[Sz]);
  if ScSt.CurPos+Sz>ScSt.EndPos then
    DCUErrorFmt('Wrong block size %x',[Sz]);
end ;

{function IsEOF: boolean;
begin
  Result := ScSt.CurPos>=ScSt.EndPos;
end ;
}

function ReadByteIfEQ(V: byte): Cardinal;
begin
  ChkSize(1);
  Result := Byte(Pointer(ScSt.CurPos)^);
  if Result<>V then
    Exit;
  Inc(ScSt.CurPos,1);
end ;

function ReadByteFrom(const S: TByteSet): Integer;
begin
  ChkSize(1);
  Result := Byte(Pointer(ScSt.CurPos)^);
  if not(Result in S) then begin
    Result := -1;
    Exit;
  end ;
  Inc(ScSt.CurPos,1);
end ;

function ReadTag: TDCURecTag;
begin
  DefStart := ScSt.CurPos;
  Result := TDCURecTag(ReadByte);
end ;

function ReadByte: Byte;
begin
  ChkSize(1);
  Result := Byte(Pointer(ScSt.CurPos)^);
  Inc(ScSt.CurPos,1);
end ;

function ReadWord: Word;
begin
  ChkSize(2);
  Result := Word(Pointer(ScSt.CurPos)^);
  Inc(ScSt.CurPos,2);
end ;

function ReadULong: ulong;
begin
  ChkSize(4);
  Result := ulong(Pointer(ScSt.CurPos)^);
  Inc(ScSt.CurPos,4);
end ;

procedure SkipBlock(Sz: Cardinal);
begin
  ChkSize(Sz);
  Inc(ScSt.CurPos,Sz);
end ;

procedure ReadBlock(var B; Sz: Cardinal);
begin
  ChkSize(Sz);
  move(ScSt.CurPos^,B,Sz);
  Inc(ScSt.CurPos,Sz);
end ;

function ReadMem(Sz: Cardinal): Pointer;
begin
  ChkSize(Sz);
  Result := Pointer(ScSt.CurPos);
  SkipBlock(Sz);
end ;

function ReadStr: ShortString;
begin
  Result[0] := AnsiChar(ReadByte);
  ReadBlock(Result[1],Length(Result));
end ;

function ReadShortName: PShortName;
begin
  Result := Pointer(ScSt.CurPos);
  SkipBlock(ReadByte);
end ;

function ReadName: PName;
var
  L: Cardinal;
begin
  Result := Pointer(ScSt.CurPos);
  L := ReadByte;
  if (L=$FF)and(CurUnit.Ver>=verD2009)and(CurUnit.Ver<verK1) then
    L := ReadULong;
  SkipBlock(L);
end ;

function StrLEnd(Str: PAnsiChar; L: Cardinal): PAnsiChar; assembler;
asm
        MOV     ECX,EDX
        MOV     EDX,EDI
        MOV     EDI,EAX
        XOR     AL,AL
        REPNE   SCASB
        JCXZ    @1
        DEC     EDI
  @1:
        MOV     EAX,EDI
        MOV     EDI,EDX
end;

function ReadNDXStr: AnsiString;
//Was observed only in drConstAddInfo records of MSIL
var
  L: integer;
begin
  L := ReadUIndex;
  if (L<0)or(L>$100000{Heuristic}) then
    DCUError('Too long NDX String');
  SetLength(Result,L);
  ReadBlock(Result[1],L);
end ;

function ReadNDXStrRef: TMemStrRef;
//Was observed only in drConstAddInfo records of MSIL
//Alternative to ReadNDXStr, allows not to read the value
var
  L: integer;
begin
  L := ReadUIndex;
  if (L<0)or(L>$100000{Heuristic}) then
    DCUError('Too long NDX String');
  Result.FChars := ReadMem(L);
  Result.FLen := L;
end ;

function GetUIndex(var DP: Pointer): LongInt;
//for GetNDXStr
begin
  Result := Byte(DP^);
  case Result and $0F of
   0,2,4,6,8,10,12,14: begin
     Result := Result shr 1;
     Inc(TIncPtr(DP));
    end ;
   1,5,9,13: begin
     Result := Word(DP^)shr 2;
     Inc(TIncPtr(DP),2);
    end ;
   3,11: begin
     Result := ((LongInt(DP^)and $FFFFFF)shr 3); //!!!an extra byte is required to prevent errors
     Inc(TIncPtr(DP),3);
    end ;
   15: begin
     Inc(TIncPtr(DP));
     Result := LongInt(DP^);
     Inc(TIncPtr(DP),4);
    end ;
  end;
end;

function GetNDXStr(DP: Pointer): AnsiString;
var
  L: LongInt;
begin
  L := GetUIndex(DP);
  SetLength(Result,L);
  if L>0 then
    System.Move(DP^,Result[1],L*SizeOf(AnsiChar));
//  Inc(TIncPtr(DP),L);
end;

function ReadUIndex: LongInt;
type
  TR4 = packed record
    B: Byte;
    L: LongInt;
  end ;

var
  B: array[0..4]of byte;
  W: Word absolute B;
  L: cardinal absolute B;
  R4: TR4 absolute B;
begin
  NDXHi := 0;
  B[0] := ReadByte;
  if B[0] and $1=0 then
    Result := B[0] shr 1
  else begin
    B[1] := ReadByte;
    if B[0] and $2=0 then
      Result := W shr 2
    else begin
      B[2] := ReadByte;
      B[3] := 0;
      if B[0] and $4=0 then
        Result := L shr 3
      else begin
        B[3] := ReadByte;
        if B[0] and $8=0 then
          Result := L shr 4
        else begin
          B[4] := ReadByte;
          Result := R4.L;
          if (CurUnit.Ver>3)and(B[0] and $F0<>0) then
            NDXHi := ReadULong;
        end ;
      end ;
    end ;
  end ;
end ;

function ReadIndex: LongInt;
type
  TR4 = packed record
    B: Byte;
    L: LongInt;
  end ;

  TRL = packed record
    W: Word;
    i: SmallInt;
  end ;

var
  B: packed array[0..7]of byte;
  SB: ShortInt absolute B;
  W: SmallInt absolute B;
  L: LongInt absolute B;
  R4: TR4 absolute B;
  RL: TRL absolute B;
begin
  B[0] := ReadByte;
  if B[0] and $1=0 then begin
    Result := SB;
    asm
      sar DWORD PTR[Result],1
    end;
   end
  else begin
    B[1] := ReadByte;
    if B[0] and $2=0 then begin
      Result := W;
      asm
        sar DWORD PTR[Result],2
      end;
     end
    else begin
      B[2] := ReadByte;
      B[3] := 0;
      if B[0] and $4=0 then begin
        RL.i := ShortInt(B[2]);
        Result := L;
        asm
          sar DWORD PTR[Result],3
        end;
       end
      else begin
        B[3] := ReadByte;
        if B[0] and $8=0 then begin
          Result := L;
          asm
            sar DWORD PTR[Result],4
          end;
         end
        else begin
          B[4] := ReadByte;
          Result := R4.L;
          if (CurUnit.Ver>3)and(B[0] and $F0<>0) then begin
            NDXHi := ReadULong;
            Exit;
          end ;
        end ;
      end ;
    end ;
  end ;
  if Result<0 then
    NDXHi := -1
  else
    NDXHi := 0;
end ;

procedure ReadIndex64(var Res: TInt64Rec);
begin
  Res.Lo := ReadIndex;
  Res.Hi := NDXHi;
end ;

procedure ReadUIndex64(var Res: TInt64Rec);
begin
  Res.Lo := ReadUIndex;
  Res.Hi := NDXHi;
end ;

function SkipDataUntil(B: Byte): TIncPtr;
begin
  Result := Pointer(ScSt.CurPos);
  while ReadByte<>B do;
end ;

function NDXToStr(NDXLo: LongInt): AnsiString;
begin
  if NDXHi=0 then
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('$%x',[NDXLo])
  else if NDXHi=-1 then
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('-$%x',[-NDXLo])
  else if NDXHi<0 then
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('-$%x%8.8x',[-NDXHi-1,-NDXLo])
  else
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('$%x%8.8x',[NDXHi,NDXLo])
end ;

function MemToInt(DP: Pointer; Sz: Cardinal; var Res: integer): boolean;
begin
  Result := true;
  case Sz of
    1: Res := ShortInt(DP^);
    2: Res := SmallInt(DP^);
    4: Res := LongInt(DP^);
  else
    Result := false;
    Res := 0;
  end ;
end ;

function MemToUInt(DP: Pointer; Sz: Cardinal; var Res: Cardinal): boolean;
begin
  Result := true;
  case Sz of
    1: Res := Byte(DP^);
    2: Res := Word(DP^);
    4: Res := Cardinal(DP^);
  else
    Result := false;
    Res := 0;
  end ;
end ;

const
  AlterSep = {$IFDEF LINUX}'\'{$ELSE}'/'{$ENDIF};

function ExtractFileNameAnySep(const FN: String): String;
var
  CP: PChar;
begin
  Result := ExtractFileName(FN);
  CP := StrRScan(PChar(Result),AlterSep);
  if CP=Nil then
    Exit;
  Result := StrPas(CP+1);
end ;

function AllocName(const S: AnsiString): PName;
var
  L: Integer;
begin
  L := Length(S);
  if L>=255 then begin
    if (CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then begin
      GetMem(Result,L*SizeOf(AnsiChar)+SizeOf(Byte)+SizeOf(LongInt));
      Result^.D.bLen := $FF;
      Result^.D.dwLen := L;
      System.Move(S[1],Result^.D.lS[0],L*SizeOf(AnsiChar));
      Exit;
    end ;
    L := 255;
  end ;
  GetMem(Result,(L+1)*SizeOf(AnsiChar));
  SetString(Result^.D.S,PAnsiChar(S),L);
end ;

procedure FreeName(NP: PName);
begin
  if NP=Nil then
    Exit;
  FreeMem(NP{,(Length(NP^)+1)*SizeOf(AnsiChar)});
end ;


{ TNameRec. }
function TNameRec.IsEmpty: Boolean;
begin
  Result := (@Self=Nil)or(D.bLen=0);
end ;

function TNameRec.Get1stChar: AnsiChar;
var
  L: Cardinal;
begin
  if @Self=Nil then begin
    Result := #0;
    Exit;
  end ;
  L := D.bLen;
  if L=0 then begin
    Result := #0;
    Exit;
  end ;
  if (L=$FF)and(CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then begin
    if D.dwLen=0 then
      Result := #0 //Paranoic
    else
      Result := D.lS[0];
    Exit;
  end ;
  Result := D.S[1];
end ;

function TNameRec.GetStr: AnsiString;
var
  L: Cardinal;
begin
  if @Self=Nil then begin
    Result := '';
    Exit;
  end ;
  L := D.bLen;
  if (L=$FF)and(CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then
    SetString(Result,D.lS,D.dwLen)
  else
    Result := D.S;
end ;

function TNameRec.GetRightStr(dl: Cardinal): AnsiString;
var
  L: Cardinal;
begin
  if @Self=Nil then begin
    Result := '';
    Exit;
  end ;
  L := D.bLen;
  if (L=$FF)and(CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then begin
    L := D.dwLen-dL;
    if L<=0 then
      Result := ''
    else
      SetString(Result,PAnsiChar(@D.lS[dl]),L);
   end
  else
    Result := System.Copy(D.S,dl+1,255);
end ;

function TNameRec.Eq(N: PName): Boolean;
var
  L: Cardinal;
  CP,CP1: PAnsiChar;
begin
  Result := false;
  if (@Self=Nil)or(N=Nil) then begin
    Result := N=@Self;
    Exit;
  end ;
  L := D.bLen;
  if L<>N^.D.bLen then
    Exit;
  if (L=$FF)and(CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then begin
    L := D.dwLen;
    if L<>N^.D.dwLen then
      Exit;
    CP := @D.lS;
    CP1 := @N^.D.lS;
   end
  else begin
    CP := @D.S[1];
    CP1 := @N^.D.S[1];
  end ;
  Result := CompareMem(CP,CP1,L);
end ;

function TNameRec.EqS(const S: ShortString): Boolean;
begin
  Result := Eq(@S);
end ;

end.


