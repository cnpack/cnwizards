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

uses
  Classes, DCU_In, DCU_Out;

type

TCmdClass = class of TCmd;

TCmd = class
protected
  FOfs: Cardinal;
public
  constructor Create(AOfs,ASize: integer); virtual;
  procedure Show; virtual;
  function HasExtraInfo: Boolean; virtual;
  property Ofs: Cardinal read FOfs;
end ;

TCmdSeq = class;

TCmdSeqRefKind = (rkNext,rkJmp,rkLoop);

PCmdSeqRef=^TCmdSeqRef;
TCmdSeqRef = object
 protected
  NextSrc: PCmdSeqRef;
  FKind: TCmdSeqRefKind;
 public
  Src: TCmdSeq;
  Tgt: TCmdSeq;
  function SrcOfs: Cardinal;
  function Next: PCmdSeqRef;
  function IsPrev: Boolean;
  function IsForward: Boolean;
  function Kind: TCmdSeqRefKind;
end ;

TProcMemPart = class
protected
  FStart,FSize: Cardinal;
public
  constructor Create(AStart: integer);
  procedure ShowBefore; virtual;
  procedure ShowAfter; virtual;
  property Start: Cardinal read FStart;
  property Size: Cardinal read FSize;
end ;

TCmdSeqLabel = class
protected
  FNext: TCmdSeqLabel;
public
  destructor Destroy; override;
  procedure Show; virtual; abstract;
  property Next: TCmdSeqLabel read FNext;
end ;

TCmdSeqStrLabel = class(TCmdSeqLabel)
protected
  FStr: AnsiString;
public
  constructor Create(const AStr: AnsiString);
  procedure Show; override;
end ;

TCmdSeqIndexStrLabel = class(TCmdSeqStrLabel)
protected
  FIndex: Integer;
public
  constructor Create(const AStr: AnsiString; AIndex: Integer);
  procedure Show; override;
end ;

TCmdSeqAddrNDXLabel = class(TCmdSeqLabel)
protected
  FNdx: TNDX;
public
  constructor Create(const ANdx: TNDX);
  procedure Show; override;
end ;

TCmdSeqExcHandlerLabel = class(TCmdSeqAddrNDXLabel)
public
  procedure Show; override;
end ;

TCmdSeqClass = class of TCmdSeq;

TCmdSeq = class(TProcMemPart)
protected
  FCommands: TList;
  FNext: PCmdSeqRef;
  FNextCond: PCmdSeqRef;
  FLevel: Integer; //DFS visit order
  FState: Integer{0 - unprocessed, 1 - in processing (on the DFS stack), 2 - processed};
  FRefs: PCmdSeqRef; //References to the sequence
  FLabels: TCmdSeqLabel;
  FIDom: array[Boolean{IsPost}]of TCmdSeq; //Immediate dominator
  function GetCount: Integer;
  class function GetCmdClass: TCmdClass; virtual;
public
  constructor Create(AStart: integer); virtual;
  destructor Destroy; override;
  class function NeedTraceData: Boolean; virtual;
  procedure SetNext(ATgt: TCmdSeq);
  procedure SetCondNext(ATgt: TCmdSeq);
  function GetCmdNumByOfs(AOfs: Cardinal): integer;
  function GetCmdByOfs(AOfs: Cardinal): TCmd;
  function SplitAt(AOfs: Cardinal): TCmdSeq;virtual;
  procedure Add(Cmd: TCmd); {virtual;}
  procedure AddCmd(Cmd: TCmd; ASize: Cardinal);
  function NewCmd(AStart,ASize: Cardinal): TCmd;
  function GetCmd(i: Integer): TCmd;
  procedure AddLabel(L: TCmdSeqLabel);
  procedure AddStrLabel(const S: AnsiString);
  procedure AddIndexStrLabel(const S: AnsiString; index: Integer);
  procedure TraceData; virtual;
  property Refs: PCmdSeqRef read FRefs;
  property Labels: TCmdSeqLabel read FLabels;
  property Level: Integer read FLevel;
  property IDom: TCmdSeq read FIDom[false]; //Immediate dominator
  property IPostDom: TCmdSeq read FIDom[true]; //Immediate postdominator
  property Count: Integer read GetCount;
end ;

TCmdSeqEnd = class(TProcMemPart);

var
  DefaultCmdSeqClass: TCmdSeqClass = TCmdSeq; //Allows to extend the class if required

implementation

uses
  DCU32{CurUnit},FixUp;

{ TCmd. }
constructor TCmd.Create(AOfs,ASize: integer);
begin
  inherited Create;
  FOfs := AOfs;
end ;

procedure TCmd.Show;
begin
end;

function TCmd.HasExtraInfo: Boolean;
begin
  Result := false;
end;

function NewCmdSeqRef(ASrc,ATgt: TCmdSeq): PCmdSeqRef;
begin
  New(Result);
  Result^.Src := ASrc;
  Result^.Tgt := ATgt;
  Result^.NextSrc := ATgt.FRefs;
  Result^.FKind := rkNext;
  ATgt.FRefs := Result;
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

{ TCmdSeqRef. }
function TCmdSeqRef.SrcOfs: Cardinal;
var
  N: Integer;
begin
  N := Src.Count-1;
  Result := Src.GetCmd(N).Ofs;
end ;

function TCmdSeqRef.Next: PCmdSeqRef;
begin
  Result := NextSrc;
end ;

function TCmdSeqRef.IsPrev: Boolean;
begin
  Result := (Src.FNext=@Self)and(Src.FStart+Src.FSize=Tgt.FStart);
end ;

function TCmdSeqRef.IsForward: Boolean;
begin
  Result := Src.FStart+Src.FSize<=Tgt.FStart;
end ;

function TCmdSeqRef.Kind: TCmdSeqRefKind;
begin
  Result := FKind;
end ;

{ TProcMemPart. }
constructor TProcMemPart.Create(AStart: integer);
begin
  inherited Create;
  FStart := AStart;
end ;

procedure TProcMemPart.ShowBefore;
begin
end;

procedure TProcMemPart.ShowAfter;
begin
end;



{ TCmdSeqLabel. }
destructor TCmdSeqLabel.Destroy;
begin
  FNext.Free;
  inherited Destroy;
end ;

{ TCmdSeqStrLabel. }
constructor TCmdSeqStrLabel.Create(const AStr: AnsiString);
begin
  inherited Create;
  FStr := AStr;
end ;

procedure TCmdSeqStrLabel.Show;
begin
  PutS(FStr);
end ;

{ TCmdSeqIndexedStrLabel. }
constructor TCmdSeqIndexStrLabel.Create(const AStr: AnsiString; AIndex: Integer);
begin
  inherited Create(AStr);
  FIndex := AIndex;
end ;

procedure TCmdSeqIndexStrLabel.Show;
begin
  inherited Show;
  PutInt(FIndex);
end ;

{ TCmdSeqAddrNDXLabel. }
constructor TCmdSeqAddrNDXLabel.Create(const ANdx: TNDX);
begin
  inherited Create;
  FNdx := ANdx;
end ;

procedure TCmdSeqAddrNDXLabel.Show;
begin
  CurUnit.PutAddrStr(FNdx,true{ShowNDX});
end ;

{ TCmdSeqExcHandlerLabel. }
procedure TCmdSeqExcHandlerLabel.Show;
begin
  PutS('on ');
  inherited Show;
  PutS(' do');
end ;

{ TCmdSeq. }
constructor TCmdSeq.Create(AStart: integer);
begin
  inherited Create(AStart);
  FCommands := TList.Create;
end ;

destructor TCmdSeq.Destroy;
var
  i: integer;
begin
  FLabels.Free;
  FreeCmdSeqRefs(FRefs);
  if FCommands<>Nil then begin
    for i:=0 to Count-1 do
      TCmd(FCommands[i]).Free;
    FCommands.Destroy;
  end ;
  inherited Destroy;
end ;

function TCmdSeq.GetCount: Integer;
begin
  Result := FCommands.Count;
end ;

procedure TCmdSeq.SetNext(ATgt: TCmdSeq);
begin
  FNext := NewCmdSeqRef(Self,ATgt);
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
    C := AOfs-TCmd(FCommands[i]).Ofs;
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
    Result := TCmd(FCommands[i]);
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
  Cmd := TCmd(FCommands[i]);
  if Cmd.FOfs<>AOfs then
    Exit; //Reference inside the command
  Result := DefaultCmdSeqClass{TCmdSeq}.Create(FStart);
  for j:=0 to i-1 do
    Result.Add(FCommands[j]);
  Result.FSize := AOfs-FStart;
  FCommands.Count := FCommands.Count-i;
  System.move(FCommands.List[i],FCommands.List[0],Count*SizeOf(Pointer));
  FStart := AOfs;
  Dec(FSize,Result.FSize);
  i := Count or $7;
  if FCommands.Capacity>i then
    FCommands.Capacity := i;
  Result.FRefs := FRefs;
  Ref := FRefs;
  while Ref<>Nil do begin
    Ref^.Tgt := Result;
    Ref := Ref^.NextSrc;
  end ;
  FRefs := Nil;
  Result.SetNext(Self);
end ;

procedure TCmdSeq.Add(Cmd: TCmd);
begin
  FCommands.Add(Cmd);
end ;

procedure TCmdSeq.AddCmd(Cmd: TCmd; ASize: Cardinal);
begin
  Add(Cmd);
  FSize := Cmd.Ofs+ASize-FStart;
end ;

class function TCmdSeq.GetCmdClass: TCmdClass;
begin
  Result := TCmd;
end ;

class function TCmdSeq.NeedTraceData: Boolean;
begin
  Result := false;
end;

function TCmdSeq.NewCmd(AStart,ASize: Cardinal): TCmd;
begin
  Result := GetCmdClass.Create(AStart,ASize);
  AddCmd(Result,ASize);
end ;

function TCmdSeq.GetCmd(i: Integer): TCmd;
begin
  Result := FCommands[i];
end ;

procedure TCmdSeq.AddLabel(L: TCmdSeqLabel);
begin
  L.FNext := FLabels;
  FLabels := L;
end ;

procedure TCmdSeq.AddStrLabel(const S: AnsiString);
begin
  AddLabel(TCmdSeqStrLabel.Create(S));
end ;

procedure TCmdSeq.AddIndexStrLabel(const S: AnsiString; index: Integer);
begin
  AddLabel(TCmdSeqIndexStrLabel.Create(S,index));
end ;

procedure TCmdSeq.TraceData;
begin
end;

end.
