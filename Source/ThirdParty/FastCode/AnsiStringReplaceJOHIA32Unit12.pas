unit AnsiStringReplaceJOHIA32Unit12;

interface

{$R-,Q-}

uses
  Windows, SysUtils, StrUtils;

{Equivalent of StringReplace for Non Multi Byte Character Sets}
function StringReplace_JOH_IA32_12(const S, OldPattern, NewPattern: AnsiString;
                                   Flags: TReplaceFlags): AnsiString;

function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;

//Size = 1132 + 256 (Table) + 4 (srCodePage) = 1392 Bytes

implementation

var
  AnsiUpcase: packed array[Char] of Char; {Upcase Lookup Table}
  srCodePage: UINT; {Active String Replace Windows CodePage}

{Setup Lookup Table for Ansi Uppercase}
procedure InitialiseAnsiUpcase;
var
  Ch: Char;
begin
  srCodePage := GetACP;
  for Ch := #0 to #255 do
    AnsiUpcase[Ch] := Ch;
  CharUpperBuffA(@AnsiUpcase, 256);
end;

{$IFNDEF Delphi2005Plus}
  {$I D7PosEx.inc}
{$ENDIF}

(*
{Non Case Sensitive version of PosEx using AnsiUpcase}
{AnsiUpcase must be initialized before this function is called}
function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;
asm
@@AnsiPosExIC:            //from JOH_IA32_14
  push   ebx
  push   esi
  push   edx                   {@Str}
  mov    esi, ecx
  mov    ecx, [edx-4]          {Length(Str) (S<>nil)}
  mov    ebx, [eax-4]          {Length(SubStr) (SubStr<>nil)}
  add    ecx, edx
  sub    ecx, ebx              {Max Start Pos for a Full Match}
  lea    edx, [edx+esi-1]      {Set Start Position}
  cmp    edx, ecx
  jg     @@NotFound            {StartPos > Max Start Pos}
  sub    ebx, 2                {Length(SubStr) - 2}
  jc     @@SingleChar          {Length(SubStr) <= 1}
  push   edi
  push   ebp
  push   ebx                   {Save Remainder to Check = Length(SubStr) - 2}
  push   ecx                   {Save Max Start Position}
  mov    esi, eax
  movzx  ebx, [eax]            {Search Character = 1st Char of SubStr}
  lea    edi, AnsiUpcase       {Uppercase Lookup Table}
  movzx  ebx, [edi+ebx]        {Convert to Uppercase}
@@Loop:                        {Loop Comparing 2 Characters per Loop}
  movzx  eax, [edx]            {Get Next Character}
  cmp    bl, [edi+eax]
  jne    @@NotChar1
  mov    ebp, [esp+4]          {Remainder to Check}
@@Char1Loop:
  movzx  eax, [esi+ebp]
  movzx  ecx, [edx+ebp]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar1
  movzx  eax, [esi+ebp+1]
  movzx  ecx, [edx+ebp+1]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar1
  sub    ebp, 2
  jge    @@Char1Loop
  pop    ecx
  pop    eax
  pop    ebp
  pop    edi
  jmp    @@SetPosResult
@@NotChar1:
  movzx  eax, [edx+1]          {Get Next Character}
  cmp    bl, [edi+eax]
  jne    @@NotChar2
  mov    ebp, [esp+4]          {Remainder to Check}
@@Char2Loop:
  movzx  eax, [esi+ebp]
  movzx  ecx, [edx+ebp+1]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar2
  movzx  eax, [esi+ebp+1]
  movzx  ecx, [edx+ebp+2]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar2
  sub    ebp, 2
  jge    @@Char2Loop
  pop    ecx
  pop    eax
  pop    ebp
  pop    edi
  jmp    @@CheckPosResult      {Check Match is within String Data}
@@NotChar2:
  add    edx, 2
  cmp    edx, [esp]            {Compare to Max Start Position}
  jle    @@Loop                {Loop until Start Pos > Max Start Pos}
  pop    ecx                   {Dump Start Position}
  pop    eax                   {Dump Remainder to Check}
  pop    ebp
  pop    edi              
  jmp    @@NotFound
@@SingleChar: 
  movzx  ebx, [eax]            {1st Char of SubStr}
  lea    esi, AnsiUpcase
  movzx  ebx, [esi+ebx]        {Convert to Uppercase}
@@CharLoop:
  movzx  eax, [edx]
  cmp    bl, [esi+eax]
  je     @@SetPosResult
  inc    edx
  cmp    edx, ecx
  jle    @@CharLoop
@@NotFound:
  xor    eax, eax
  pop    edx
  pop    esi
  pop    ebx
  ret
@@CheckPosResult:              {Check Match is within String Data}
  cmp    edx, ecx
  jge    @@NotFound
  inc    edx                   {OK - Adjust Result}
@@SetPosResult:                {Set Result Position}
  mov    eax, edx
  inc    eax
  pop    ecx                   {@Str}
  pop    esi
  pop    ebx
  sub    eax, ecx
  ret
end;
*)

(*
function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;
asm
@@AnsiPosExIC:       //wrongly passes validation
  push   ebx
  push   esi
  push   edx                   {@Str}
  mov    esi, ecx
  mov    ecx, [edx-4]          {Length(Str) (S<>nil)}
  mov    ebx, [eax-4]          {Length(SubStr) (SubStr<>nil)}
  add    ecx, edx
  sub    ecx, ebx              {Max Start Pos for a Full Match}
  lea    edx, [edx+esi-1]      {Set Start Position}
  cmp    edx, ecx
  jg     @@NotFound            {StartPos > Max Start Pos}
  sub    ebx, 2                {Length(SubStr) - 2}
  jc     @@SingleChar          {Length(SubStr) <= 1}
  push   edi
  push   ebp
  push   ebx                   {Save Remainder to Check = Length(SubStr) - 2}
  push   ecx                   {Save Max Start Position}
  mov    esi, eax
  movzx  ebx, [eax]            {Search Character = 1st Char of SubStr}
  lea    edi, AnsiUpcase       {Uppercase Lookup Table}
  movzx  ebx, [edi+ebx]        {Convert to Uppercase}
@@Loop:                        {Loop Comparing 2 Characters per Loop}
  movzx  eax, [edx]            {Get Next Character}
  cmp    bl, [edi+eax]
  jne    @@NotChar1
  mov    ebp, [esp+4]          {Remainder to Check}
@@Char1Loop:
  movzx  eax, [esi+ebp]
  movzx  ecx, [edx+ebp]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar1
  movzx  eax, [esi+ebp+1]
  movzx  ecx, [edx+ebp+1]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar1
  sub    ebp, 2
  jge    @@Char1Loop
  pop    ecx
  pop    eax
  pop    ebp
  pop    edi
  inc    edx
  jmp    @@SetPosResult
@@NotChar1:
  movzx  eax, [edx+1]          {Get Next Character}
  cmp    bl, [edi+eax]
  jne    @@NotChar2
  mov    ebp, [esp+4]          {Remainder to Check}
  inc    edx
@@Char2Loop:
  movzx  eax, [esi+ebp]
  movzx  ecx, [edx+ebp]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar2
  movzx  eax, [esi+ebp+1]
  movzx  ecx, [edx+ebp+1]
  movzx  eax, [edi+eax]        {Convert to Uppercase}
  cmp    al, [edi+ecx]
  jne    @@NotChar2
  sub    ebp, 2
  jge    @@Char2Loop
  pop    ecx
  pop    eax
  pop    ebp
  pop    edi
  jmp    @@CheckPosResult      {Check Match is within String Data}
@@NotChar2:
//inc edx
  add    edx, 2      //should be inc edx
  cmp    edx, [esp]            {Compare to Max Start Position}
  jle    @@Loop                {Loop until Start Pos > Max Start Pos}
  pop    ecx                   {Dump Start Position}
  pop    eax                   {Dump Remainder to Check}
  pop    ebp
  pop    edi
  jmp    @@NotFound
@@SingleChar:
  movzx  ebx, [eax]            {1st Char of SubStr}
  lea    esi, AnsiUpcase
  movzx  ebx, [esi+ebx]        {Convert to Uppercase}
@@CharLoop:
  movzx  eax, [edx]
  inc    edx
  cmp    bl, [esi+eax]
  je     @@SetPosResult
  cmp    edx, ecx
  jle    @@CharLoop
@@NotFound:
  xor    eax, eax
  pop    edx
  pop    esi
  pop    ebx
  ret
@@CheckPosResult:              {Check Match is within String Data}
  cmp    edx, ecx
  jg     @@NotFound
  inc    edx                   {OK - Adjust Result}
@@SetPosResult:                {Set Result Position}
  mov    eax, edx
  pop    ecx                   {@Str}
  pop    esi
  pop    ebx
  sub    eax, ecx
  ret
end;
*)


//original
function AnsiPosExIC(const SubStr, S: Ansistring; Offset: Integer = 1): Integer;
asm
  push    ebx
  push    esi
  push    edx              {@Str}
  test    eax, eax
  jz      @@NotFound       {Exit if SubStr = ''}
  test    edx, edx
  jz      @@NotFound       {Exit if Str = ''}
  mov     esi, ecx
  mov     ecx, [edx-4]     {Length(Str)}
  mov     ebx, [eax-4]     {Length(SubStr)}
  add     ecx, edx
  sub     ecx, ebx         {Max Start Pos for Full Match}
  lea     edx, [edx+esi-1] {Set Start Position}
  cmp     edx, ecx
  jg      @@NotFound       {StartPos > Max Start Pos}
  cmp     ebx, 1           {Length(SubStr)}
  jle     @@SingleChar     {Length(SubStr) <= 1}
  push    edi
  push    ebp
  lea     edi, [ebx-2]     {Length(SubStr) - 2}
  mov     esi, eax
  push    edi              {Save Remainder to Check = Length(SubStr) - 2}
  push    ecx              {Save Max Start Position}
  lea     edi, AnsiUpcase  {Uppercase Lookup Table}
  movzx   ebx, [eax]       {Search Character = 1st Char of SubStr}
  movzx   ebx, [edi+ebx]   {Convert to Uppercase}
@@Loop:                    {Loop Comparing 2 Characters per Loop}
  movzx   eax, [edx]       {Get Next Character}
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  jne     @@NotChar1
  mov     ebp, [esp+4]     {Remainder to Check}
@@Char1Loop:
  movzx   eax, [esi+ebp]
  movzx   ecx, [edx+ebp]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar1
  movzx   eax, [esi+ebp+1]
  movzx   ecx, [edx+ebp+1]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar1
  sub     ebp, 2
  jnc     @@Char1Loop
  pop     ecx
  pop     edi
  pop     ebp
  pop     edi
  jmp     @@SetResult
@@NotChar1:
  movzx   eax, [edx+1]     {Get Next Character}
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  cmp     bl, al
  jne     @@NotChar2
  mov     ebp, [esp+4]     {Remainder to Check}
@@Char2Loop:
  movzx   eax, [esi+ebp]
  movzx   ecx, [edx+ebp+1]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar2
  movzx   eax, [esi+ebp+1]
  movzx   ecx, [edx+ebp+2]
  movzx   eax, [edi+eax]   {Convert to Uppercase}
  movzx   ecx, [edi+ecx]   {Convert to Uppercase}
  cmp     eax, ecx
  jne     @@NotChar2
  sub     ebp, 2
  jnc     @@Char2Loop
  pop     ecx
  pop     edi
  pop     ebp
  pop     edi
  jmp     @@CheckResult    {Check Match is within String Data}
@@NotChar2:
  add     edx, 2
  cmp     edx, [esp]       {Compate to Max Start Position}
  jle     @@Loop           {Loop until Start Position > Max Start Position}
  pop     ecx              {Dump Start Position}
  pop     edi              {Dump Remainder to Check}
  pop     ebp
  pop     edi
  jmp     @@NotFound
@@SingleChar:
  jl      @@NotFound       {Needed for Zero-Length Non-NIL Strings}
  lea     esi, AnsiUpcase
  movzx   ebx, [eax]       {Search Character = 1st Char of SubStr}
  movzx   ebx, [esi+ebx]   {Convert to Uppercase}
@@CharLoop:
  movzx   eax, [edx]
  movzx   eax, [esi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  je      @@SetResult
  movzx   eax, [edx+1]
  movzx   eax, [esi+eax]   {Convert to Uppercase}
  cmp     eax, ebx
  je      @@CheckResult
  add     edx, 2
  cmp     edx, ecx
  jle     @@CharLoop
@@NotFound:
  xor     eax, eax
  pop     edx
  pop     esi
  pop     ebx
  ret
@@CheckResult:             {Check Match is within String Data}
  cmp     edx, ecx
  jge     @@NotFound
  add     edx, 1           {OK - Adjust Result}
@@SetResult:               {Set Result Position}
  pop     ecx              {@Str}
  pop     esi
  pop     ebx
  neg     ecx
  lea     eax, [edx+ecx+1]
end; {AnsiPosExIC}


function StringReplace_JOH_IA32_12(const S, OldPattern, NewPattern: AnsiString;
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
                  Move(PSrc^, PRes^, Found);
                  Inc(PRes, Found);
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

InitialiseAnsiUpcase; //test

end.
