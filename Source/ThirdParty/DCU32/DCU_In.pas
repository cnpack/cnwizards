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

uses
  SysUtils;

type
  TDCURecTag = Byte{Char};

  TNDX = integer;

  PName = PShortString;

  TInt64Rec = record
    Lo: Cardinal;
    Hi: Cardinal;
  end ;

const
  {Local flags}
  lfClass = $1;{class procedure }
  lfPrivate = $0;
  lfPublic = $2;
  lfProtected = $4;
  lfPublished = $A;
  lfScope = $0E { $0F};
  lfDeftProp = $20;
  lfOverride = $20;
  lfVirtual = $40;
  lfDynamic = $80;

type
TDefNDX = TNDX;

PPNDXTbl = ^PNDXTbl;
PNDXTbl = ^TNDXTbl;
TNDXTbl = array[Byte]of TNDX;

PDef = ^Pointer;
PNameDef = ^TNameDef;
TNameDef = packed record
  Tag: TDCURecTag;
  Name: ShortString;
end ;

type
  TScanState=record
    StartPos,CurPos,EndPos: PAnsiChar; // Modified by Liu Xiao
  end ;

var
  ScSt: TScanState;
  DefStart: Pointer;
  Tag: TDCURecTag;

procedure ChangeScanState(var State: TScanState; DP: Pointer; MaxSz: Cardinal);
procedure RestoreScanState(const State: TScanState);

//function IsEOF: boolean;

function ReadByte: Cardinal;
function ReadTag: TDCURecTag;
function ReadULong: Cardinal;

procedure SkipBlock(Sz: Cardinal);
procedure ReadBlock(var B; Sz: Cardinal);

function ReadMem(Sz: Cardinal): Pointer;

function ReadStr: ShortString;
function ReadName: PShortString;

function ReadNDXStr: String;
function ReadByteIfEQ(V: byte): Cardinal;

var
  NDXHi: LongInt;

function ReadUIndex: LongInt;
function ReadIndex: LongInt;

procedure ReadIndex64(var Res: TInt64Rec);
procedure ReadUIndex64(var Res: TInt64Rec);

function SkipDataUntil(B: Byte): PChar;

function NDXToStr(NDXLo: LongInt): String;

function MemToInt(DP: Pointer; Sz: Cardinal; var Res: integer): boolean;
function MemToUInt(DP: Pointer; Sz: Cardinal; var Res: Cardinal): boolean;

type
  EDCUFmtError = class(Exception)
  end ;

procedure DCUError(Msg: String);
procedure DCUErrorFmt(Msg: String; Args: array of const);
procedure DCUWarning(Msg: String);
procedure DCUWarningFmt(Msg: String; Args: array of const);
procedure TagError(Msg: String);

function ExtractFileNameAnySep(FN: String): String;

implementation

uses
  DCU32{CurUnit};

procedure DCUError(Msg: String);
var
  US: String;
  TagC: Char;
begin
  US := '';
  if CurUnit<>MainUnit then begin
    US := CurUnit.UnitName;
    if US='' then
      US := ChangeFileExt(ExtractFileName(CurUnit.FileName),'');
    US := Format(' in %s ',[US]);
  end ;
  TagC := Char(Tag);
  if TagC<' ' then
    TagC := '.';
  if ScSt.EndPos<>Nil then
    US := Format('Error at 0x%x%s(Def: 0x%x, Tag="%s"(0x%x)): %s',
      [ScSt.CurPos-ScSt.StartPos,US,PChar(DefStart)-ScSt.StartPos,TagC,Byte(Tag),Msg])
  else
    US := Format('Error%s: %s',[US,Msg]);
  raise EDCUFmtError.Create(US);
end ;

procedure DCUErrorFmt(Msg: String; Args: array of const);
begin
  DCUError(Format(Msg,Args));
end ;

procedure DCUWarning(Msg: String);
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
      [ScSt.CurPos-ScSt.StartPos,US,PChar(DefStart)-ScSt.StartPos,Char(Tag),Byte(Tag),Msg])
  else
    US := Format('Warning%s: %s',[US,Msg]);
  Writeln(US);
end ;

procedure DCUWarningFmt(Msg: String; Args: array of const);
begin
  DCUWarning(Format(Msg,Args));
end ;

procedure TagError(Msg: String);
begin
  DCUErrorFmt('%s: wrong tag "%s"=0x%x',[Msg,Char(Tag),Byte(Tag)]);
end ;

procedure ChangeScanState(var State: TScanState; DP: Pointer; MaxSz: Cardinal);
begin
  State := ScSt;
  ScSt.StartPos := DP;
  ScSt.CurPos := DP;
  ScSt.EndPos := PAnsiChar(DP)+MaxSz;
end ;

procedure RestoreScanState(const State: TScanState);
begin
  ScSt := State;
end ;

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

function ReadByte: Cardinal;
begin
  ChkSize(1);
  Result := Byte(Pointer(ScSt.CurPos)^);
  Inc(ScSt.CurPos,1);
end ;

function ReadByteIfEQ(V: byte): Cardinal;
begin
  ChkSize(1);
  Result := Byte(Pointer(ScSt.CurPos)^);
  if Result<>V then
    Exit;
  Inc(ScSt.CurPos,1);
end ;

function ReadTag: TDCURecTag;
begin
  DefStart := ScSt.CurPos;
  Result := TDCURecTag(ReadByte);
end ;

function ReadULong: Cardinal;
begin
  ChkSize(4);
  Result := Cardinal(Pointer(ScSt.CurPos)^);
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
  Result := Pointer(ScSt.CurPos);
  SkipBlock(Sz);
end ;

function ReadStr: ShortString;
begin
  Result[0] := AnsiChar(ReadByte);
  ReadBlock(Result[1],Length(Result));
end ;

function ReadName: PShortString;
begin
  Result := Pointer(ScSt.CurPos);
  SkipBlock(ReadByte);
end ;

function ReadNDXStr: String;
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
            sar DWORD PTR[Result],3
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

function SkipDataUntil(B: Byte): PChar;
begin
  Result := Pointer(ScSt.CurPos);
  while ReadByte<>B do;
end ;

function NDXToStr(NDXLo: LongInt): String;
begin
  if NDXHi=0 then
    Result := Format('$%x',[NDXLo])
  else if NDXHi=-1 then
    Result := Format('-$%x',[-NDXLo])
  else if NDXHi<0 then
    Result := Format('-$%x%8.8x',[-NDXHi-1,-NDXLo])
  else
    Result := Format('$%x%8.8x',[NDXHi,NDXLo])
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

function ExtractFileNameAnySep(FN: String): String;
var
  CP: PChar;
begin
  Result := ExtractFileName(FN);
  CP := StrRScan(PChar(Result),AlterSep);
  if CP=Nil then
    Exit;
  Result := StrPas(CP+1);
end ;

end.


