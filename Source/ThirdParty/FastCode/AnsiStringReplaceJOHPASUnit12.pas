unit AnsiStringReplaceJOHPASUnit12;

interface

{$R-,Q-}

uses
  Windows, SysUtils, StrUtils;

{Equivalent of StringReplace for Non Multi Byte Character Sets}
function StringReplace_JOH_PAS_12(const S, OldPattern, NewPattern: AnsiString;
                                  Flags: TReplaceFlags): AnsiString;

{Size = 1188 + 256 (Table) + 4 (srCodePage) = 1448 Bytes}

implementation

var
  AnsiUpcase: packed array[Char] of Char; {Upcase Lookup Table}
  srCodePage: UINT; {Active String Replace Windows CodePage}

{Setup Lookup Table for Ansi Uppercase}
procedure InitialiseAnsiUpcase;
var
  Ch: Char;
begin
  srCodePage := GetACP; {Save CodePage}
  for Ch := #0 to #255 do
    AnsiUpcase[Ch] := Ch;
  CharUpperBuffA(@AnsiUpcase, 256);
end;

{$IFNDEF Delphi2005Plus}
  {$I D7PosEx.inc}
{$ENDIF}

{Case Insensitive PosEx based on Ansi Uppercase}
{AnsiUpcase must be initialized before this function is called}
function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;
var
  StrLen, SubLen, Len: Integer;
  PStr, PSub, PMax   : PChar;
  FirstChar          : Char; {First Character of SubStr}
begin
  Result := 0;
  SubLen := Length(SubStr);
  StrLen := Length(S);
  if (SubLen = 0) then
    Exit;
  PSub := Pointer(SubStr);
  PStr := Pointer(S);
  PMax := PStr + StrLen - SubLen; {Maximum Start Position}
  Inc(PStr, Offset - 1);
  if PStr > PMax then
    Exit;
  FirstChar := AnsiUpcase[PSub^];
  if SubLen = 1 then
    repeat {Single Character Saarch}
      if AnsiUpcase[PStr^] = FirstChar then
        begin
          Result := PStr + 1 - Pointer(S);
          Exit;
        end;
      if AnsiUpcase[PStr[1]] = FirstChar then
        begin
          if PStr < PMax then {Within Valid Range}
            Result := PStr + 2 - Pointer(S);
          Exit;
        end;
      Inc(PStr, 2);
    until PStr > PMax
  else
    begin {Multi-Character Search}
      Dec(SubLen, 2); {Characters to Check after Match}
      repeat
        if AnsiUpcase[PStr^] = FirstChar then
          begin
            Len := SubLen;
            while True do
              begin
                if (AnsiUpcase[PSub[Len  ]] <> AnsiUpcase[PStr[Len  ]])
                or (AnsiUpcase[PSub[Len+1]] <> AnsiUpcase[PStr[Len+1]]) then
                  Break; {No Match}
                Dec(Len, 2);
                if Len < 0 then
                  begin {First Char already Checked}
                    Result := PStr + 1 - Pointer(S);
                    Exit;
                  end;
              end;
          end;
        if AnsiUpcase[PStr[1]] = FirstChar then
          begin
            Len := SubLen;
            while True do
              begin
                if (AnsiUpcase[PSub[Len  ]] <> AnsiUpcase[PStr[Len+1]])
                or (AnsiUpcase[PSub[Len+1]] <> AnsiUpcase[PStr[Len+2]]) then
                  Break; {No Match}
                Dec(Len, 2);
                if Len < 0 then
                  begin {First Char already Checked}
                    if PStr < PMax then {Within Valid Range}
                      Result := PStr + 2 - Pointer(S);
                    Exit;
                  end;
              end;
          end;
        Inc(PStr, 2);
      until PStr > PMax;
    end;
end; {AnsiPosExIC}

function StringReplace_JOH_PAS_12(const S, OldPattern, NewPattern: AnsiString;
                                  Flags: TReplaceFlags): AnsiString;
type
  TPosEx = function(const SubStr, S: Ansistring; Offset: Integer): Integer;
const
  StaticBufferSize = 16;
var
  SrcLen, OldLen, NewLen, Found, Count, Start, Match, Matches, BufSize,
  Remainder    : Integer;
  PosExFunction: TPosEx;
  StaticBuffer : array[0..StaticBufferSize-1] of Integer;
  Buffer       : PIntegerArray;
  P, PSrc, PRes: PChar;
  Ch           : Char;
begin
  SrcLen := Length(S);
  OldLen := Length(OldPattern);
  NewLen := Length(NewPattern);                     
  if (OldLen = 0) or (SrcLen < OldLen) then
    begin
      if SrcLen = 0 then                   
        Result := '' {Needed for Non-Nil Zero Length Strings}
      else
        Result := S
    end
  else
    begin
      if rfIgnoreCase in Flags then
        begin
          PosExFunction := AnsiPosExIC;
          if GetACP <> srCodePage then {Check CodePage}
            InitialiseAnsiUpcase; {CodePage Changed - Update Lookup Table}
        end
      else
        PosExFunction := PosEx;
      if rfReplaceAll in Flags then
        begin
          if (OldLen = 1) and (NewLen = 1) then
            begin {Single Character Replacement}
              Remainder := SrcLen;
              SetLength(Result, Remainder);
              P := Pointer(Result);
              Move(Pointer(S)^, P^, Remainder);
              if rfIgnoreCase in Flags then
                begin
                  Ch := AnsiUpcase[OldPattern[1]];
                  repeat
                    Dec(Remainder);
                    if AnsiUpcase[P[Remainder]] = Ch then
                      P[Remainder] := NewPattern[1];
                  until Remainder = 0;
                end
              else
                begin
                  repeat
                    Dec(Remainder);
                    if P[Remainder] = OldPattern[1] then
                      P[Remainder] := NewPattern[1];
                  until Remainder = 0;
                end;
              Exit;
            end;
          Found := PosExFunction(OldPattern, S, 1);
          if Found <> 0 then
            begin
              Buffer    := @StaticBuffer;
              BufSize   := StaticBufferSize;
              Matches   := 1;
              Buffer[0] := Found;
              repeat
                Inc(Found, OldLen);
                Found := PosExFunction(OldPattern, S, Found);
                if Found > 0 then
                  begin
                    if Matches = BufSize then
                      begin {Create or Expand Dynamic Buffer}
                        BufSize := BufSize + (BufSize shr 1); {Grow by 50%}
                        if Buffer = @StaticBuffer then
                          begin {Create Dynamic Buffer}
                            GetMem(Buffer, BufSize * SizeOf(Integer));
                            Move(StaticBuffer, Buffer^, SizeOf(StaticBuffer));
                          end
                        else {Expand Dynamic Buffer}
                          ReallocMem(Buffer, BufSize * SizeOf(Integer));
                      end;
                    Buffer[Matches] := Found;
                    Inc(Matches);
                  end
              until Found = 0;
              SetLength(Result, SrcLen + (Matches * (NewLen - OldLen)));
              PSrc := Pointer(S);
              PRes := Pointer(Result);
              Start := 1;
              Match := 0;
              repeat
                Found := Buffer[Match];
                Count := Found - Start;
                Start := Found + OldLen;
                if Count > 0 then
                  begin
                    Move(PSrc^, PRes^, Count);
                    Inc(PRes, Count);
                  end;
                Inc(PSrc, Count + OldLen);
                Move(Pointer(NewPattern)^, PRes^, NewLen);
                Inc(PRes, NewLen);
                Inc(Match);
              until Match = Matches;
              Remainder := SrcLen - Start;
              if Remainder >= 0 then
                Move(PSrc^, PRes^, Remainder + 1);
              if BufSize <> StaticBufferSize then
                FreeMem(Buffer); {Free Dynamic Buffer if Created}
            end
          else {No Matches Found}
            Result := S
        end {ReplaceAll}
      else
        begin {Replace First Occurance Only}
          Found := PosExFunction(OldPattern, S, 1);
          if Found <> 0 then
            begin {Match Found}
              SetLength(Result, SrcLen - OldLen + NewLen);
              Dec(Found);
              PSrc := Pointer(S);
              PRes := Pointer(Result);
              if NewLen = OldLen then
                begin
                  Move(PSrc^, PRes^, SrcLen);
                  Inc(PRes, Found);
                  Move(Pointer(NewPattern)^, PRes^, NewLen);
                end
              else
                begin
                  if Found > 0 then                        
                begin
                  Move(PSrc^, PRes^, Found);
                  Inc(PRes, Found);
                end;
                  Inc(PSrc, Found + OldLen);
                  Move(Pointer(NewPattern)^, PRes^, NewLen);
                  Inc(PRes, NewLen);
                  Move(PSrc^, PRes^, SrcLen - Found - OldLen);
                end;
            end
          else {No Matches Found}
            Result := S
        end;
    end;
end;

initialization
  srCodePage := 0; {Invalidate AnsiUpcase Lookup Table}
end.

