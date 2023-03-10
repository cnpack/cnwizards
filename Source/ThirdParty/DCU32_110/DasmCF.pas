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
      constructor Create(AOfs: integer); virtual;
      property Ofs: Cardinal read FOfs;
  end;

  TCmdSeq = class;

  TCmdSeqRefKind = (rkNext, rkJmp, rkLoop);

  PCmdSeqRef = ^TCmdSeqRef;

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
  end;

  TProcMemPart = class
    protected
      FStart, FSize: Cardinal;
    public
      constructor Create(AStart: integer);
      property Start: Cardinal read FStart;
      property Size: Cardinal read FSize;
  end;

  TCmdSeqLabel = class
    protected
      FNext: TCmdSeqLabel;
    public
      destructor Destroy; override;
      procedure Show; virtual; abstract;
      property Next: TCmdSeqLabel read FNext;
  end;

  TCmdSeqStrLabel = class(TCmdSeqLabel)
    protected
      FStr: String;
    public
      constructor Create(const AStr: String);
      procedure Show; override;
  end;

  TCmdSeqIndexStrLabel = class(TCmdSeqStrLabel)
    protected
      FIndex: integer;
    public
      constructor Create(const AStr: String; AIndex: integer);
      procedure Show; override;
  end;

  TCmdSeqAddrNDXLabel = class(TCmdSeqLabel)
    protected
      FNdx: TNDX;
    public
      constructor Create(const ANdx: TNDX);
      procedure Show; override;
  end;

  TCmdSeqExcHandlerLabel = class(TCmdSeqAddrNDXLabel)
    public
      procedure Show; override;
  end;

  TCmdSeqClass = class of TCmdSeq;

  TCmdSeq = class(TProcMemPart)
    protected
      FCommands: TList;
      FNext: PCmdSeqRef;
      FNextCond: PCmdSeqRef;
      FLevel: integer; // DFS visit order
      FState: integer { 0 - unprocessed, 1 - in processing (on the DFS stack), 2 - processed };
      FRefs: PCmdSeqRef; // References to the sequence
      FLabels: TCmdSeqLabel;
      FIDom: array [Boolean { IsPost } ] of TCmdSeq; // Immediate dominator
      function GetCount: integer;
      class function GetCmdClass: TCmdClass; virtual;
    public
      constructor Create(AStart: integer); virtual;
      destructor Destroy; override;
      procedure SetNext(ATgt: TCmdSeq);
      procedure SetCondNext(ATgt: TCmdSeq);
      function GetCmdNumByOfs(AOfs: Cardinal): integer;
      function GetCmdByOfs(AOfs: Cardinal): TCmd;
      function SplitAt(AOfs: Cardinal): TCmdSeq; virtual;
      procedure Add(Cmd: TCmd);
      procedure AddCmd(Cmd: TCmd; ASize: Cardinal);
      function NewCmd(AStart, ASize: Cardinal): TCmd;
      function GetCmd(i: integer): TCmd;
      procedure AddLabel(L: TCmdSeqLabel);
      procedure AddStrLabel(const S: String);
      procedure AddIndexStrLabel(const S: String; index: integer);
      property Refs: PCmdSeqRef read FRefs;
      property Labels: TCmdSeqLabel read FLabels;
      property Level: integer read FLevel;
      property IDom: TCmdSeq read FIDom[false]; // Immediate dominator
      property IPostDom: TCmdSeq read FIDom[true]; // Immediate postdominator
      property Count: integer read GetCount;
  end;

  TCmdSeqEnd = class(TProcMemPart);

  TProcMemDataClass = class of TProcMemData;

  TProcMemKind = (pmExcRec);

  TProcMemData = class(TProcMemPart)
    protected
      FKind: TProcMemKind;
    public
      constructor Create(AStart, ASize: integer); virtual;
      procedure Show(BlOfs: ulong); virtual;
      property Start: Cardinal read FStart;
      property Size: Cardinal read FSize;
      property Kind: TProcMemKind read FKind;
  end;

  TProc = class(TList)
    protected
      FStart, FSize: Cardinal;
      FNextSeq: integer;
      function AddMemData(AStart, ASize: Cardinal; Cl: TProcMemDataClass): TProcMemData;
    public
      constructor Create(AStart, ASize: integer);
      destructor Destroy; override;
      function AddSeq(AStart: Cardinal): TCmdSeq;
      procedure AddSeqEnd(AStart: Cardinal);
      procedure AddExcDesc(AStart, ASize: Cardinal);
      function GetNotReadySeqNum: integer;
      function GetMaxMemPartSize(i: integer): Cardinal { MaxSize };
      function GetProcMemPartNumByOfs(AOfs: Cardinal): integer;
      function GetProcMemPartByOfs(AOfs: Cardinal): TProcMemPart;
      function GetProcMemPart(i: integer): TProcMemPart;
      function GetCmdSeq(i: integer): TCmdSeq; // Nil for other kinds of TProcMemPart
      procedure ReachedNext(i: integer);
      procedure ReachedNextS(Seq: TCmdSeq);
      procedure CheckStructure;
      property Start: Cardinal read FStart;
      property Size: Cardinal read FSize;
  end;

var
  DefaultCmdSeqClass: TCmdSeqClass = TCmdSeq; // Allows to extend the class if required

implementation

uses
  DCU32 {CurUnit} , FixUp;

{ TCmd. }
constructor TCmd.Create(AOfs: integer);
  begin
    inherited Create;
    FOfs := AOfs;
  end;

function NewCmdSeqRef(ASrc, ATgt: TCmdSeq): PCmdSeqRef;
  begin
    New(Result);
    Result^.Src := ASrc;
    Result^.Tgt := ATgt;
    Result^.NextSrc := ATgt.FRefs;
    Result^.FKind := rkNext;
    ATgt.FRefs := Result;
  end;

procedure FreeCmdSeqRefs(R: PCmdSeqRef);
  var
    RN: PCmdSeqRef;
  begin
    while R <> Nil do begin
        RN := R^.NextSrc;
        Dispose(R);
        R := RN;
      end;
  end;

{ TCmdSeqRef. }
function TCmdSeqRef.SrcOfs: Cardinal;
  var
    N: integer;
  begin
    N := Src.Count - 1;
    Result := Src.GetCmd(N).Ofs;
  end;

function TCmdSeqRef.Next: PCmdSeqRef;
  begin
    Result := NextSrc;
  end;

function TCmdSeqRef.IsPrev: Boolean;
  begin
    Result := (Src.FNext = @Self) and (Src.FStart + Src.FSize = Tgt.FStart);
  end;

function TCmdSeqRef.IsForward: Boolean;
  begin
    Result := Src.FStart + Src.FSize <= Tgt.FStart;
  end;

function TCmdSeqRef.Kind: TCmdSeqRefKind;
  begin
    Result := FKind;
  end;

{ TProcMemPart. }
constructor TProcMemPart.Create(AStart: integer);
  begin
    inherited Create;
    FStart := AStart;
  end;

{ TCmdSeqLabel. }
destructor TCmdSeqLabel.Destroy;
  begin
    FNext.Free;
    inherited Destroy;
  end;

{ TCmdSeqStrLabel. }
constructor TCmdSeqStrLabel.Create(const AStr: String);
  begin
    inherited Create;
    FStr := AStr;
  end;

procedure TCmdSeqStrLabel.Show;
  begin
    PutS(FStr);
  end;

{ TCmdSeqIndexedStrLabel. }
constructor TCmdSeqIndexStrLabel.Create(const AStr: String; AIndex: integer);
  begin
    inherited Create(AStr);
    FIndex := AIndex;
  end;

procedure TCmdSeqIndexStrLabel.Show;
  begin
    inherited Show;
    PutInt(FIndex);
  end;

{ TCmdSeqAddrNDXLabel. }
constructor TCmdSeqAddrNDXLabel.Create(const ANdx: TNDX);
  begin
    inherited Create;
    FNdx := ANdx;
  end;

procedure TCmdSeqAddrNDXLabel.Show;
  begin
    CurUnit.PutAddrStr(FNdx, true { ShowNDX } );
  end;

{ TCmdSeqExcHandlerLabel. }
procedure TCmdSeqExcHandlerLabel.Show;
  begin
    PutS('on ');
    inherited Show;
    PutS(' do');
  end;

{ TCmdSeq. }
constructor TCmdSeq.Create(AStart: integer);
  begin
    inherited Create(AStart);
    FCommands := TList.Create;
  end;

destructor TCmdSeq.Destroy;
  var
    i: integer;
  begin
    FLabels.Free;
    FreeCmdSeqRefs(FRefs);
    if FCommands <> Nil then begin
        for i := 0 to Count - 1 do
            TCmd(FCommands[i]).Free;
        FCommands.Destroy;
      end;
    inherited Destroy;
  end;

function TCmdSeq.GetCount: integer;
  begin
    Result := FCommands.Count;
  end;

procedure TCmdSeq.SetNext(ATgt: TCmdSeq);
  begin
    FNext := NewCmdSeqRef(Self, ATgt);
  end;

procedure TCmdSeq.SetCondNext(ATgt: TCmdSeq);
  begin
    FNextCond := NewCmdSeqRef(Self, ATgt);
  end;

function TCmdSeq.GetCmdNumByOfs(AOfs: Cardinal): integer;
  var
    L, H, i, C: integer;
  begin
    Result := -1;
    if (AOfs < FStart) or (AOfs >= FStart + FSize) then
        Exit;
    Result := 0;
    L := 0;
    H := Count - 1;
    while L <= H do begin
        i := (L + H) shr 1;
        C := AOfs - TCmd(FCommands[i]).Ofs;
        if C < 0 then
            H := i - 1
        else begin
            Result := i;
            if C = 0 then
                break;
            L := i + 1;
          end;
      end;
  end;

function TCmdSeq.GetCmdByOfs(AOfs: Cardinal): TCmd;
  var
    i: integer;
  begin
    i := GetCmdNumByOfs(AOfs);
    if i < 0 then
        Result := Nil
    else
        Result := TCmd(FCommands[i]);
  end;

function TCmdSeq.SplitAt(AOfs: Cardinal): TCmdSeq;
  var
    i, j: integer;
    Cmd: TCmd;
    Ref: PCmdSeqRef;
  begin
    Result := Nil;
    i := GetCmdNumByOfs(AOfs);
    if i < 0 then
        Exit;
    Cmd := TCmd(FCommands[i]);
    if Cmd.FOfs <> AOfs then
        Exit; // Reference inside the command
    Result := DefaultCmdSeqClass { TCmdSeq }.Create(FStart);
    for j := 0 to i - 1 do
        Result.Add(FCommands[j]);
    Result.FSize := AOfs - FStart;
    FCommands.Count := FCommands.Count - i;
    System.move(FCommands.List[i], FCommands.List[0], Count * SizeOf(Pointer));
    FStart := AOfs;
    Dec(FSize, Result.FSize);
    i := Count or $7;
    if FCommands.Capacity > i then
        FCommands.Capacity := i;
    Result.FRefs := FRefs;
    Ref := FRefs;
    while Ref <> Nil do begin
        Ref^.Tgt := Result;
        Ref := Ref^.NextSrc;
      end;
    FRefs := Nil;
    Result.SetNext(Self);
  end;

procedure TCmdSeq.Add(Cmd: TCmd);
  begin
    FCommands.Add(Cmd);
  end;

procedure TCmdSeq.AddCmd(Cmd: TCmd; ASize: Cardinal);
  begin
    Add(Cmd);
    FSize := Cmd.Ofs + ASize - FStart;
  end;

class function TCmdSeq.GetCmdClass: TCmdClass;
  begin
    Result := TCmd;
  end;

function TCmdSeq.NewCmd(AStart, ASize: Cardinal): TCmd;
  begin
    Result := GetCmdClass.Create(AStart);
    AddCmd(Result, ASize);
  end;

function TCmdSeq.GetCmd(i: integer): TCmd;
  begin
    Result := FCommands[i];
  end;

procedure TCmdSeq.AddLabel(L: TCmdSeqLabel);
  begin
    L.FNext := FLabels;
    FLabels := L;
  end;

procedure TCmdSeq.AddStrLabel(const S: String);
  begin
    AddLabel(TCmdSeqStrLabel.Create(S));
  end;

procedure TCmdSeq.AddIndexStrLabel(const S: String; index: integer);
  begin
    AddLabel(TCmdSeqIndexStrLabel.Create(S, index));
  end;

{ TProcMemData. }
constructor TProcMemData.Create(AStart, ASize: integer);
  begin
    inherited Create(AStart);
    FSize := ASize;
  end;

procedure TProcMemData.Show(BlOfs: ulong);
  var
    DP: Pointer;
    DS, i, ExcCnt, ExcClOfs, HandlerOfs: Cardinal;
    FixRd: TFixUpReader;
    ExcFix, HandlerFix: PFixupRec;
  begin
    PutSFmt('%x[%x]:', [Start, Size]);
    DP := CurUnit.GetBlockMem(BlOfs + Start, Size, DS);
    if DP = Nil then
        Exit;
    FixRd.Init(DP, DS);
    case Kind of
      pmExcRec: begin
          if not FixRd.ReadULongNoFix(ExcCnt) then
              Exit;
          ShiftNLOfs(2);
          try
            PutS('(');
            for i := 0 to ExcCnt - 1 do begin
                if i > 0 then
                    PutS(',' + cSoftNL);
                if not FixRd.ReadULongFix(ExcClOfs, ExcFix) then
                    Exit;
                if not FixRd.ReadULongFix(HandlerOfs, HandlerFix) then
                    Exit;
                PutS('(on ');
                CurUnit.PutAddrStr(ExcFix^.Ndx, true { ShowNDX } );
                PutHexOffset(ExcClOfs); // In fact always 0
                PutS(' do' + cSoftNL);
                CurUnit.PutAddrStr(HandlerFix^.Ndx, true { ShowNDX } );
                PutHexOffset(HandlerOfs);
                PutS(')');
              end;
            PutS(')');
          finally
              ShiftNLOfs(-2);
          end;
        end;
    end;
  end;

{ TProc. }
constructor TProc.Create(AStart, ASize: integer);
  begin
    inherited Create;
    FStart := AStart;
    FSize := ASize;
    Add(DefaultCmdSeqClass { CmdSeq }.Create(AStart));
  end;

destructor TProc.Destroy;
  var
    i: integer;
  begin
    for i := 0 to Count - 1 do
        TProcMemPart(Items[i]).Free;
  end;

function TProc.AddSeq(AStart: Cardinal): TCmdSeq;
  var
    P: TProcMemPart;
    i: integer;
  begin
    Result := Nil;
    i := GetProcMemPartNumByOfs(AStart);
    if i < 0 then
        Exit; { Out of proc. range }
    P := TProcMemPart(Items[i]);
    if P.Start = AStart then begin
        if P is TCmdSeq { !!!We silently ignore the error, which shouldn`t happen } then
            Result := TCmdSeq(P)
        else if P is TCmdSeqEnd then begin // Replace the code end marker by TCmdSeq
            Result := DefaultCmdSeqClass { TCmdSeq }.Create(AStart);
            Items[i] := Result;
            P.Free;
            if i < FNextSeq then
                FNextSeq := i;
          end;
        Exit;
      end;
    if P.Start + P.Size <= AStart then begin
        Result := DefaultCmdSeqClass { TCmdSeq }.Create(AStart);
        Inc(i);
        Insert(i, Result);
        if i < FNextSeq then
            FNextSeq := i;
      end
    else if P is TCmdSeq { !!!We silently ignore the error, which shouldn`t happen } then begin
        Result := TCmdSeq(P).SplitAt(AStart);
        if Result = Nil then
            Exit;
        Insert(i, Result);
        Result := TCmdSeq(P);
      end;
  end;

procedure TProc.AddSeqEnd(AStart: Cardinal);
  var
    P: TProcMemPart;
    i: integer;
    EndOfs: Cardinal;
  begin
    i := GetProcMemPartNumByOfs(AStart);
    if i < 0 then
        Exit; { Out of proc. range }
    P := TProcMemPart(Items[i]);
    if P.Start = AStart then
        Exit { Already splitted };
    EndOfs := P.Start + P.Size;
    if EndOfs <= AStart then begin
        if EndOfs = AStart then
            Exit { The part has stopped here already, no need to stop it explicitly };
        P := TCmdSeqEnd.Create(AStart);
        Inc(i);
        Insert(i, P);
        if i <= FNextSeq then
            Inc(FNextSeq);
      end
    else { The case of getting into a code part is impossible, because the SeqEnd is
        added before code tracing };
  end;

function TProc.AddMemData(AStart, ASize: Cardinal; Cl: TProcMemDataClass): TProcMemData;
  { Returns Cl.Create if the new part is required }
  var
    P: TProcMemPart;
    i: integer;
    EndOfs, MaxSz: Cardinal;
  begin
    Result := Nil;
    i := GetProcMemPartNumByOfs(AStart);
    if i < 0 then
        Exit; { Out of proc. range }
    P := TProcMemPart(Items[i]);
    if P.Start = AStart then begin
        if P is TCmdSeqEnd then begin
            MaxSz := GetMaxMemPartSize(i);
            if MaxSz >= ASize then begin
                Result := Cl.Create(AStart, ASize);
                Items[i] := Result;
                P.Free;
                if i <= FNextSeq then
                    Inc(FNextSeq);
              end;
          end;
        Exit;
      end;
    EndOfs := P.Start + P.Size;
    if EndOfs > AStart then
        Exit { !!!Error, overlaps some memory part };
    MaxSz := P.Start + GetMaxMemPartSize(i) - AStart;
    if MaxSz < ASize then
        Exit { !!!Error, not enough memory to place the part };
    Result := Cl.Create(AStart, ASize);
    Inc(i);
    Insert(i, Result);
    if i <= FNextSeq then
        Inc(FNextSeq);
  end;

procedure TProc.AddExcDesc(AStart, ASize: Cardinal);
  var
    E: TProcMemData;
  begin
    E := AddMemData(AStart, ASize, TProcMemData);
    if E <> Nil then
        E.FKind := pmExcRec;
  end;

function TProc.GetNotReadySeqNum: integer;
  var
    MemPart: TProcMemPart;
  begin
    Result := FNextSeq;
    while Result < Count do begin
        MemPart := Items[Result];
        if (MemPart is TCmdSeq) and (TCmdSeq(MemPart).FSize = 0) then begin
            FNextSeq := Result + 1;
            Exit;
          end;
        Inc(Result);
      end;
    FNextSeq := Result;
    Result := -1;
  end;

function TProc.GetMaxMemPartSize(i: integer): Cardinal { MaxSize };
  var
    S, S1: TProcMemPart;
  begin
    if i < 0 then begin
        Result := 0;
        Exit;
      end;
    S := TProcMemPart(Items[i]);
    Inc(i);
    if i < Count then begin
        S1 := TProcMemPart(Items[i]);
        Result := S1.Start - S.Start;
      end
    else
        Result := FStart + FSize - S.Start;
  end;

function TProc.GetProcMemPartNumByOfs(AOfs: Cardinal): integer;
  var
    L, H, i, C: integer;
  begin
    Result := -1;
    if (AOfs < FStart) or (AOfs >= FStart + FSize) then
        Exit;
    Result := 0;
    L := 0;
    H := Count - 1;
    while L <= H do begin
        i := (L + H) shr 1;
        C := AOfs - TProcMemPart(Items[i]).Start;
        if C < 0 then
            H := i - 1
        else begin
            Result := i;
            if C = 0 then
                break;
            L := i + 1;
          end;
      end;
  end;

function TProc.GetProcMemPartByOfs(AOfs: Cardinal): TProcMemPart;
  begin
    Result := GetProcMemPart(GetProcMemPartNumByOfs(AOfs));
  end;

function TProc.GetProcMemPart(i: integer): TProcMemPart;
  begin
    if i < 0 then
        Result := Nil
    else
        Result := TProcMemPart(Items[i]);
  end;

function TProc.GetCmdSeq(i: integer): TCmdSeq; // Nil for other kinds of TProcMemPart
  var
    Part: TProcMemPart;
  begin
    Part := GetProcMemPart(i);
    if Part is TCmdSeq then
        Result := TCmdSeq(Part)
    else
        Result := Nil;
  end;

procedure TProc.ReachedNext(i: integer);
  var
    S, S1: TProcMemPart;
  begin
    if i < 0 then
        Exit;
    S := GetProcMemPart(i);
    if not(S is TCmdSeq) then
        Exit;
    Inc(i);
    if i >= Count then
        Exit;
    S1 := GetProcMemPart(i);
    if not(S1 is TCmdSeq) then
        Exit;
    TCmdSeq(S).SetNext(TCmdSeq(S1));
  end;

procedure TProc.ReachedNextS(Seq: TCmdSeq);
  begin
    ReachedNext(IndexOf(Seq));
  end;

const
  SeqUnknown = TCmdSeq(-1);

function FindCommonDominator(D1, D2: TCmdSeq; IsPost: Boolean): TCmdSeq;
  var
    D: integer;
  begin
    if D2.FIDom[IsPost] = SeqUnknown then begin
        Result := D1;
        Exit;
      end;
    if D1 = SeqUnknown then begin
        Result := D2;
        Exit;
      end;
    repeat
      if (D1 = Nil) or (D2 = Nil) then begin
          Result := Nil;
          Exit { Paranoic: for predecessors - unreachable lines };
        end;
      D := D1.FLevel - D2.FLevel;
      if D = 0 then begin // The Level is unique among the nodes => D1=D2
          Result := D1;
          Exit;
        end;
      if D < 0 then
          D1 := D1.FIDom[IsPost]
      else
          D2 := D2.FIDom[IsPost];
    until false;
  end;

procedure CalcDominators(L: TList; IsPost: Boolean);
  var
    Seq, IDomRes: TCmdSeq;
    Ref: PCmdSeqRef;
    i: integer;
    Changed: Boolean;
  begin
    repeat
      Changed := false;
      for i := L.Count - 1 downto 0 do { Reverse postorder } begin
          Seq := TCmdSeq(L[i]);
          IDomRes := SeqUnknown;
          if IsPost then begin
              Ref := Seq.FNext;
              if Ref <> Nil then
                  IDomRes := FindCommonDominator(IDomRes, Ref^.Tgt, IsPost);
              Ref := Seq.FNextCond;
              if Ref <> Nil then
                  IDomRes := FindCommonDominator(IDomRes, Ref^.Tgt, IsPost);
            end
          else begin
              Ref := Seq.FRefs;
              while Ref <> Nil do begin
                  IDomRes := FindCommonDominator(IDomRes, Ref^.Src, IsPost);
                  Ref := Ref^.NextSrc;
                end;
            end;
          if (IDomRes <> SeqUnknown) and (IDomRes <> Seq.FIDom[IsPost]) then begin
              Seq.FIDom[IsPost] := IDomRes;
              Changed := true;
            end;
        end;
    until not Changed;
  end;

procedure TProc.CheckStructure;
  var
    L, Stack: TList;

  procedure DFS(Seq: TCmdSeq); forward;

    procedure DFSRef(Ref: PCmdSeqRef);
      var
        Seq: TCmdSeq;
        L0, i: integer;
      begin
        if Ref = Nil then
            Exit;
        Seq := Ref^.Tgt;
        if Seq.FState = 0 then begin
            L0 := Stack.Add(Ref);
            DFS(Seq);
            if Ref.Kind = rkNext then
                Ref.FKind := rkJmp;
            Stack.Count := L0;
          end
        else if Seq.FState = 1 then begin
            { Loop detected, cause the code part is still on the stack }
            if not Ref.IsForward then
                Ref.FKind := rkLoop // !!!Temp - to be improved
            else begin // Seek for the back reference to mark it as a loop
                Ref.FKind := rkJmp;
                i := Stack.Count;
                while i > 0 do begin
                    Dec(i);
                    Ref := Stack[i];
                    if not Ref.IsForward then begin
                        Ref.FKind := rkLoop;
                        break;
                      end;
                  end;
              end;
          end
        else begin
            { a parallel jump link, which can be || to loop }
            Ref.FKind := rkJmp;
          end;
      end;

    procedure DFS(Seq: TCmdSeq);
      begin
        Seq.FState := 1;
        DFSRef(Seq.FNext);
        DFSRef(Seq.FNextCond);
        Seq.FState := 2;
        Seq.FLevel := L.Add(Seq); // PostOrder enumeration
      end;

  procedure PostDFS(Seq: TCmdSeq); forward;

    procedure PostDFSRef(Ref: PCmdSeqRef);
      var
        Seq: TCmdSeq;
      begin
        if Ref = Nil then
            Exit;
        Seq := Ref^.Src;
        if Seq.FState = 0 then
            PostDFS(Seq);
      end;

    procedure PostDFS(Seq: TCmdSeq);
      var
        Ref: PCmdSeqRef;
      begin
        Seq.FState := 1;
        Ref := Seq.FRefs;
        while Ref <> Nil do begin
            PostDFSRef(Ref);
            Ref := Ref^.NextSrc;
          end;
        Seq.FState := 2;
        Seq.FLevel := L.Add(Seq); // PostOrder enumeration
      end;

  var
    i: integer;
    P: TProcMemPart;
    Seq, DomSeq: TCmdSeq;
  begin
    L := Nil;
    Stack := TList.Create;
    try
      { Compute DFS postdominator postorder index in L }
      L := TList.Create;
      for i := Count - 1 downto 0 do begin
          P := GetProcMemPart(i);
          if not(P is TCmdSeq) then
              Continue;
          Seq := TCmdSeq(P);
          if (Seq.FNext = Nil) and (Seq.FNextCond = Nil) then begin
              if Seq.FState = 0 then
                  PostDFS(Seq);
              Seq.FIDom[true { IsPost } ] := Nil;
            end
          else
              Seq.FIDom[true { IsPost } ] := SeqUnknown;
        end;
      CalcDominators(L, true { IsPost } );
      { Compute DFS postorder index in L - computed after postdominators to reuse L }
      L.Clear;
      for i := 0 to Count - 1 do begin
          P := GetProcMemPart(i);
          if not(P is TCmdSeq) then
              Continue;
          Seq := TCmdSeq(P);
          Seq.FState := 0;
        end;
      for i := 0 to Count - 1 do begin
          P := GetProcMemPart(i);
          if not(P is TCmdSeq) then
              Continue;
          Seq := TCmdSeq(P);
          if Seq.FRefs = Nil then begin
              if Seq.FState = 0 then
                  DFS(Seq);
              Seq.FIDom[false { IsPost } ] := Nil
            end
          else
              Seq.FIDom[false { IsPost } ] := SeqUnknown;
        end;
      CalcDominators(L, false { IsPost } );
      { Compute levels - reverse postorder }
      for i := L.Count - 1 downto 0 do begin
          Seq := TCmdSeq(L[i]);
          if (Seq.FRefs = Nil) or (Seq.IDom = Nil) then
              Seq.FLevel := 0
          else begin
              DomSeq := Seq.IDom;
              if DomSeq.IPostDom = Seq then
                  Seq.FLevel := DomSeq.FLevel
              else
                  Seq.FLevel := DomSeq.FLevel + 1;
            end;
        end;
    finally
      L.Free;
      Stack.Free;
    end;
  end;

end.
