unit DasmCF;
(*
The disassembler control flow information data structures module of the
DCU32INT utility by Alexei Hmelnov.
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
  Classes;

type

TCmd = class
protected
  FOfs: Cardinal;
public
  constructor Create(AOfs: integer);
  property Ofs: Cardinal read FOfs;
end ;

TCmdSeq = class;

PCmdSeqRef=^TCmdSeqRef;
TCmdSeqRef = record
  Src: TCmdSeq;
  Tgt: TCmdSeq;
  NextSrc: PCmdSeqRef;
end ;

TCmdSeq = class(TList)
protected
  FStart,FSize: Cardinal;
  FNext: PCmdSeqRef;
  FNextCond: PCmdSeqRef;
  Refs: PCmdSeqRef;
public
  constructor Create(AStart: integer);
  destructor Destroy; override;
  procedure SetNext(ATgt: TCmdSeq);
  procedure SetCondNext(ATgt: TCmdSeq);
  function GetCmdNumByOfs(AOfs: Cardinal): integer;
  function GetCmdByOfs(AOfs: Cardinal): TCmd;
  function SplitAt(AOfs: Cardinal): TCmdSeq;
  function AddCmd(AStart,ASize: Cardinal): TCmd;
  property Start: Cardinal read FStart;
  property Size: Cardinal read FSize;
end ;

TProc = class(TList)
protected
  FStart,FSize: Cardinal;
  FNextSeq: integer;
public
  constructor Create(AStart,ASize: integer);
  destructor Destroy; override;
  function AddSeq(AStart: Cardinal): TCmdSeq;
  function GetNotReadySeqNum: integer;
  function GetMaxSeqSize(i: integer): Cardinal{MaxSize};
  function GetCmdSeqNumByOfs(AOfs: Cardinal): integer;
  function GetCmdSeqByOfs(AOfs: Cardinal): TCmdSeq;
  function GetCmdSeq(i: integer): TCmdSeq;
  procedure ReachedNext(i: integer);
  procedure ReachedNextS(Seq: TCmdSeq);
  property Start: Cardinal read FStart;
  property Size: Cardinal read FSize;
end ;

implementation

{ TCmd. }
constructor TCmd.Create(AOfs: integer);
begin
  inherited Create;
  FOfs := AOfs;
end ;

function NewCmdSeqRef(ASrc,ATgt: TCmdSeq): PCmdSeqRef;
begin
  New(Result);
  Result^.Src := ASrc;
  Result^.Tgt := ATgt;
  Result^.NextSrc := ATgt.Refs;
  ATgt.Refs := Result;
end ;

procedure FreeCmdSeqRefs(R: PCmdSeqRef);
var
  RN: PCmdSeqRef;
begin
  while R<>Nil do begin
    RN := R^.NextSrc;
    Dispose(R);
    R := RN;
  end ;
end ;

{ TCmdSeq. }

constructor TCmdSeq.Create(AStart: integer);
begin
  inherited Create;
  FStart := AStart;
end ;

destructor TCmdSeq.Destroy;
var
  i: integer;
begin
  FreeCmdSeqRefs(Refs);
  for i:=0 to Count-1 do
    TCmd(Items[i]).Free;
end ;

procedure TCmdSeq.SetNext(ATgt: TCmdSeq);
begin
  FNext :=  NewCmdSeqRef(Self,ATgt);
end ;

procedure TCmdSeq.SetCondNext(ATgt: TCmdSeq);
begin
  FNextCond := NewCmdSeqRef(Self,ATgt);
end ;

function TCmdSeq.GetCmdNumByOfs(AOfs: Cardinal): integer;
var
  L, H, i, C: integer;
begin
  Result := -1;
  if (AOfs<FStart)or(AOfs>=FStart+FSize) then
    Exit;
  Result := 0;
  L := 0;
  H := Count - 1;
  while L <= H do begin
    i := (L + H)shr 1;
    C := AOfs-TCmd(Items[i]).Ofs;
    if C<0 then
      H := i-1
    else begin
      Result := i;
      if C=0 then
        break;
      L := i+1;
    end;
  end;
end ;

function TCmdSeq.GetCmdByOfs(AOfs: Cardinal): TCmd;
var
  i: Integer;
begin
  i := GetCmdNumByOfs(AOfs);
  if i<0 then
    Result := Nil
  else
    Result := TCmd(Items[i]);
end ;

function TCmdSeq.SplitAt(AOfs: Cardinal): TCmdSeq;
var
  i,j: Integer;
  Cmd: TCmd;
  Ref: PCmdSeqRef;
begin
  Result := Nil;
  i := GetCmdNumByOfs(AOfs);
  if i<0 then
    Exit;
  Cmd := TCmd(Items[i]);
  if Cmd.FOfs<>AOfs then
    Exit; //Reference inside the command
  Result := TCmdSeq.Create(FStart);
  for j:=0 to i-1 do
    Result.Add(Items[j]);
  Result.FSize := AOfs-FStart;
  Count := Count-i;
{$IFDEF LIST_NEW_POINTER}
  System.move(List[i],List[0],Count*SizeOf(Pointer));
{$ELSE}
  System.move(List^[i],List^,Count*SizeOf(Pointer));
{$ENDIF}

  FStart := AOfs;
  Dec(FSize,Result.FSize);
  i := Count or $7;
  if Capacity>i then
    Capacity := i;
  Result.Refs := Refs;
  Ref := Refs;
  while Ref<>Nil do begin
    Ref^.Tgt := Result;
    Ref := Ref^.NextSrc;
  end ;
  Refs := Nil;
  Result.SetNext(Self);
end ;

function TCmdSeq.AddCmd(AStart,ASize: Cardinal): TCmd;
begin
  Result := TCmd.Create(AStart);
  Add(Result);
  FSize := AStart+ASize-FStart;
end ;

{ TProc. }
constructor TProc.Create(AStart,ASize: integer);
begin
  inherited Create;
  FStart := AStart;
  FSize := ASize;
  Add(TCmdSeq.Create(AStart));
end ;

destructor TProc.Destroy;
var
  i: integer;
begin
  for i:=0 to Count-1 do
    TCmdSeq(Items[i]).Free;
end ;

function TProc.AddSeq(AStart: Cardinal): TCmdSeq;
var
  S: TCmdSeq;
  i: integer;
begin
  Result := Nil;
  i := GetCmdSeqNumByOfs(AStart);
  if i<0 then
    Exit; {Out of proc. range}
  S := TCmdSeq(Items[i]);
  if S.Start=AStart then begin
    Result := S;
    Exit;
  end ;
  if S.Start+S.Size<=AStart then begin
    Result := TCmdSeq.Create(AStart);
    Inc(i);
    Insert(i,Result);
    if i<FNextSeq then
      FNextSeq := i;
   end
  else begin
    Result := S.SplitAt(AStart);
    if Result=Nil then
      Exit;
    Insert(i,Result);
    Result := S;
  end ;
end ;

function TProc.GetNotReadySeqNum: integer;
begin
  Result := FNextSeq;
  while Result<Count do begin
    if TCmdSeq(Items[Result]).FSize=0 then begin
      FNextSeq := Result+1;
      Exit;
    end ;
    Inc(Result);
  end ;
  FNextSeq := Result;
  Result := -1;
end ;

function TProc.GetMaxSeqSize(i: integer): Cardinal{MaxSize};
var
  S,S1: TCmdSeq;
begin
  if i<0 then begin
    Result := 0;
    Exit;
  end ;
  S := TCmdSeq(Items[i]);
  Inc(i);
  if i<Count then begin
    S1 := TCmdSeq(Items[i]);
    Result := S1.Start-S.Start;
   end
  else
    Result := FStart+FSize-S.Start;
end ;

function TProc.GetCmdSeqNumByOfs(AOfs: Cardinal): integer;
var
  L, H, i, C: Integer;
begin
  Result := -1;
  if (AOfs<FStart)or(AOfs>=FStart+FSize) then
    Exit;
  Result := 0;
  L := 0;
  H := Count - 1;
  while L <= H do begin
    i := (L + H)shr 1;
    C := AOfs-TCmdSeq(Items[i]).Start;
    if C<0 then
      H := i-1
    else begin
      Result := i;
      if C=0 then
        break;
      L := i+1;
    end;
  end;
end ;

function TProc.GetCmdSeqByOfs(AOfs: Cardinal): TCmdSeq;
begin
  Result := GetCmdSeq(GetCmdSeqNumByOfs(AOfs));
end ;

function TProc.GetCmdSeq(i: integer): TCmdSeq;
begin
  if i<0 then
    Result := Nil
  else
    Result := TCmdSeq(Items[i]);
end ;

procedure TProc.ReachedNext(i: integer);
var
  S,S1: TCmdSeq;
begin
  if i<0 then
    Exit;
  S := GetCmdSeq(i);
  Inc(i);
  if i>=Count then
    Exit;
  S1 := GetCmdSeq(i);
  S.SetNext(S1);
end ;

procedure TProc.ReachedNextS(Seq: TCmdSeq);
begin
  ReachedNext(IndexOf(Seq));
end ;

end.
