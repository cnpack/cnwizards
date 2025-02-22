unit DasmProc;

interface

uses
  Classes, DCU_In, DCU_Out, DasmCF,DCURecs;

type

TProcMemDataClass = class of TProcMemData;

TProcMemKind = (pmExcRec);
TProcMemData = class(TProcMemPart)
protected
  FKind: TProcMemKind;
public
  constructor Create(AStart,ASize: integer); virtual;
  procedure Show(BlOfs: ulong); virtual;
  property Start: Cardinal read FStart;
  property Size: Cardinal read FSize;
  property Kind: TProcMemKind read FKind;
end ;

TProc = class(TList)
protected
  FStart,FSize: Cardinal;
  FProc: TProcDecl;
  FNextSeq: integer;
  function AddMemData(AStart,ASize: Cardinal; Cl: TProcMemDataClass): TProcMemData;
public
  constructor Create(AProc: TProcDecl; AStart,ASize: integer);
  destructor Destroy; override;
  function AddSeq(AStart: Cardinal): TCmdSeq;
  procedure AddSeqEnd(AStart: Cardinal);
  procedure AddExcDesc(AStart,ASize: Cardinal);
  function GetNotReadySeqNum: integer;
  function GetMaxMemPartSize(i: integer): Cardinal{MaxSize};
  function GetProcMemPartNumByOfs(AOfs: Cardinal): integer;
  function GetProcMemPartByOfs(AOfs: Cardinal): TProcMemPart;
  function GetProcMemPart(i: integer): TProcMemPart;
  function GetCmdSeq(i: integer): TCmdSeq; //Nil for other kinds of TProcMemPart
  procedure ReachedNext(i: integer);
  procedure ReachedNextS(Seq: TCmdSeq);
  procedure CheckStructure;
 {$IFDEF OpSem}
  procedure TraceData;
 {$ENDIF}
  property Proc: TProcDecl read FProc;
  property Start: Cardinal read FStart;
  property Size: Cardinal read FSize;
end ;

implementation

uses
  FixUp, DCU32;

type
  PCmdSeqRefCrack=^TCmdSeqRefCrack;
  TCmdSeqRefCrack = object(TCmdSeqRef)
  end;
  TCmdSeqCrack = class(TCmdSeq);

{ TProcMemData. }
constructor TProcMemData.Create(AStart,ASize: integer);
begin
  inherited Create(AStart);
  FSize := ASize;
end ;

procedure TProcMemData.Show(BlOfs: ulong);
var
  DP: Pointer;
  DS,i,ExcCnt,ExcClOfs,HandlerOfs: Cardinal;
  FixRd: TFixUpReader;
  ExcFix,HandlerFix: PFixupRec;
begin
  PutSFmt('%x[%x]:',[Start,Size]);
  DP := CurUnit.GetBlockMem(BlOfs+Start,Size,DS);
  if DP=Nil then
    Exit;
  FixRd.Init(DP,DS);
  case Kind of
   pmExcRec: begin
     if not FixRd.ReadULongNoFix(ExcCnt) then
       Exit;
     ShiftNLOfs(2);
     try
       PutS('(');
       for i:=0 to ExcCnt-1 do begin
         if i>0 then
           PutS(','+cSoftNL);
         if not FixRd.ReadULongFix(ExcClOfs,ExcFix) then
           Exit;
         if not FixRd.ReadULongFix(HandlerOfs,HandlerFix) then
           Exit;
         PutS('(on ');
         CurUnit.PutAddrStr(ExcFix^.Ndx,true{ShowNDX});
         PutHexOffset(ExcClOfs); //In fact always 0
         PutS(' do'+cSoftNL);
         CurUnit.PutAddrStr(HandlerFix^.Ndx,true{ShowNDX});
         PutHexOffset(HandlerOfs);
         PutS(')');
       end ;
       PutS(')');
     finally
       ShiftNLOfs(-2);
     end ;
    end ;
  end ;
end ;


{ TProc. }
constructor TProc.Create(AProc: TProcDecl; AStart,ASize: integer);
begin
  inherited Create;
  FStart := AStart;
  FSize := ASize;
  FProc := AProc;
  Add(DefaultCmdSeqClass{CmdSeq}.Create(AStart));
end ;

destructor TProc.Destroy;
var
  i: integer;
begin
  for i:=0 to Count-1 do
    TProcMemPart(Items[i]).Free;
end ;

function TProc.AddSeq(AStart: Cardinal): TCmdSeq;
var
  P: TProcMemPart;
  i: integer;
begin
  Result := Nil;
  i := GetProcMemPartNumByOfs(AStart);
  if i<0 then
    Exit; {Out of proc. range}
  P := TProcMemPart(Items[i]);
  if P.Start=AStart then begin
    if P is TCmdSeq{!!!We silently ignore the error, which shouldn`t happen} then
      Result := TCmdSeq(P)
    else if P is TCmdSeqEnd then begin //Replace the code end marker by TCmdSeq
      Result := DefaultCmdSeqClass{TCmdSeq}.Create(AStart);
      Items[i] := Result;
      P.Free;
      if i<FNextSeq then
        FNextSeq := i;
    end ;
    Exit;
  end ;
  if P.Start+P.Size<=AStart then begin
    Result := DefaultCmdSeqClass{TCmdSeq}.Create(AStart);
    Inc(i);
    Insert(i,Result);
    if i<FNextSeq then
      FNextSeq := i;
   end
  else if P is TCmdSeq{!!!We silently ignore the error, which shouldn`t happen} then begin
    Result := TCmdSeq(P).SplitAt(AStart);
    if Result=Nil then
      Exit;
    Insert(i,Result);
    Result := TCmdSeq(P);
  end ;
end ;

procedure TProc.AddSeqEnd(AStart: Cardinal);
var
  P: TProcMemPart;
  i: integer;
  EndOfs: Cardinal;
begin
  i := GetProcMemPartNumByOfs(AStart);
  if i<0 then
    Exit; {Out of proc. range}
  P := TProcMemPart(Items[i]);
  if P.Start=AStart then
    Exit{Already splitted};
  EndOfs := P.Start+P.Size;
  if EndOfs<=AStart then begin
    if EndOfs=AStart then
      Exit{The part has stopped here already, no need to stop it explicitly};
    P := TCmdSeqEnd.Create(AStart);
    Inc(i);
    Insert(i,P);
    if i<=FNextSeq then
      Inc(FNextSeq);
   end
  else {The case of getting into a code part is impossible, because the SeqEnd is
    added before code tracing};
end ;

function TProc.AddMemData(AStart,ASize: Cardinal; Cl: TProcMemDataClass): TProcMemData;
{ Returns Cl.Create if the new part is required }
var
  P: TProcMemPart;
  i: integer;
  EndOfs,MaxSz: Cardinal;
begin
  Result := Nil;
  i := GetProcMemPartNumByOfs(AStart);
  if i<0 then
    Exit; {Out of proc. range}
  P := TProcMemPart(Items[i]);
  if P.Start=AStart then begin
    if P is TCmdSeqEnd then begin
      MaxSz := GetMaxMemPartSize(i);
      if MaxSz>=ASize then begin
        Result := Cl.Create(AStart,ASize);
        Items[i] := Result;
        P.Free;
        if i<=FNextSeq then
          Inc(FNextSeq);
      end ;
    end ;
    Exit;
  end ;
  EndOfs := P.Start+P.Size;
  if EndOfs>AStart then
    Exit{!!!Error, overlaps some memory part};
  MaxSz := P.Start+GetMaxMemPartSize(i)-AStart;
  if MaxSz<ASize then
    Exit{!!!Error, not enough memory to place the part};
  Result := Cl.Create(AStart,ASize);
  Inc(i);
  Insert(i,Result);
  if i<=FNextSeq then
    Inc(FNextSeq);
end ;

procedure TProc.AddExcDesc(AStart,ASize: Cardinal);
var
  E: TProcMemData;
begin
  E := AddMemData(AStart,ASize,TProcMemData);
  if E<>Nil then
    E.FKind := pmExcRec;
end ;

function TProc.GetNotReadySeqNum: integer;
var
  MemPart: TProcMemPart;
begin
  Result := FNextSeq;
  while Result<Count do begin
    MemPart := Items[Result];
    if (MemPart is TCmdSeq)and(TCmdSeq(MemPart).Size=0) then begin
      FNextSeq := Result+1;
      Exit;
    end ;
    Inc(Result);
  end ;
  FNextSeq := Result;
  Result := -1;
end ;

function TProc.GetMaxMemPartSize(i: integer): Cardinal{MaxSize};
var
  S,S1: TProcMemPart;
begin
  if i<0 then begin
    Result := 0;
    Exit;
  end ;
  S := TProcMemPart(Items[i]);
  Inc(i);
  if i<Count then begin
    S1 := TProcMemPart(Items[i]);
    Result := S1.Start-S.Start;
   end
  else
    Result := FStart+FSize-S.Start;
end ;

function TProc.GetProcMemPartNumByOfs(AOfs: Cardinal): integer;
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
    C := AOfs-TProcMemPart(Items[i]).Start;
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

function TProc.GetProcMemPartByOfs(AOfs: Cardinal): TProcMemPart;
begin
  Result := GetProcMemPart(GetProcMemPartNumByOfs(AOfs));
end ;

function TProc.GetProcMemPart(i: integer): TProcMemPart;
begin
  if i<0 then
    Result := Nil
  else
    Result := TProcMemPart(Items[i]);
end ;

function TProc.GetCmdSeq(i: integer): TCmdSeq; //Nil for other kinds of TProcMemPart
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
  S,S1: TProcMemPart;
begin
  if i<0 then
    Exit;
  S := GetProcMemPart(i);
  if not(S is TCmdSeq) then
    Exit;
  Inc(i);
  if i>=Count then
    Exit;
  S1 := GetProcMemPart(i);
  if not(S1 is TCmdSeq) then
    Exit;
  TCmdSeq(S).SetNext(TCmdSeq(S1));
end ;

procedure TProc.ReachedNextS(Seq: TCmdSeq);
begin
  ReachedNext(IndexOf(Seq));
end ;

const
  SeqUnknown = TCmdSeq(-1);

function FindCommonDominator(D1,D2: TCmdSeqCrack; IsPost: Boolean): TCmdSeqCrack;
var
  D: Integer;
begin
  if D2.FIDom[IsPost]=SeqUnknown then begin
    Result := D1;
    Exit;
  end ;
  if D1=SeqUnknown then begin
    Result := D2;
    Exit;
  end ;
  repeat
    if (D1=Nil)or(D2=Nil) then begin
      Result := Nil;
      Exit{Paranoic: for predecessors - unreachable lines};
    end ;
    D := D1.FLevel-D2.FLevel;
    if D=0 then begin //The Level is unique among the nodes => D1=D2
      Result := D1;
      Exit;
    end ;
    if D<0 then
      D1 := TCmdSeqCrack(D1.FIDom[IsPost])
    else
      D2 := TCmdSeqCrack(D2.FIDom[IsPost]);
  until false;
end ;

procedure CalcDominators(L: TList; IsPost: Boolean);
var
  Seq: TCmdSeqCrack;
  IDomRes: TCmdSeq;
  Ref: PCmdSeqRef;
  i: Integer;
  Changed: Boolean;
begin
  repeat
    Changed := false;
    for i:=L.Count-1 downto 0 do {Reverse postorder} begin
      Seq := TCmdSeqCrack(L[i]);
      IDomRes := SeqUnknown;
      if IsPost then begin
        Ref := Seq.FNext;
        if Ref<>Nil then
          IDomRes := FindCommonDominator(TCmdSeqCrack(IDomRes),TCmdSeqCrack(Ref^.Tgt),IsPost);
        Ref := Seq.FNextCond;
        if Ref<>Nil then
          IDomRes := FindCommonDominator(TCmdSeqCrack(IDomRes),TCmdSeqCrack(Ref^.Tgt),IsPost);
       end
      else begin
        Ref := Seq.FRefs;
        while Ref<>Nil do begin
          IDomRes := FindCommonDominator(TCmdSeqCrack(IDomRes),TCmdSeqCrack(Ref^.Src),IsPost);
          Ref := PCmdSeqRefCrack(Ref)^.NextSrc;
        end ;
      end ;
      if (IDomRes<>SeqUnknown)and(IDomRes<>TCmdSeqCrack(Seq).FIDom[IsPost]) then begin
        TCmdSeqCrack(Seq).FIDom[IsPost] := IDomRes;
        Changed := true;
      end ;
    end ;
  until not Changed;
end ;

procedure TProc.CheckStructure;
var
  L,Stack: TList;

  procedure DFS(Seq: TCmdSeqCrack); forward;

  procedure DFSRef(Ref: PCmdSeqRefCrack);
  var
    Seq: TCmdSeqCrack;
    L0,i: Integer;
  begin
    if Ref=Nil then
      Exit;
    Seq := TCmdSeqCrack(Ref^.Tgt);
    if Seq.FState=0 then begin
      L0 := Stack.Add(Ref);
      DFS(Seq);
      if Ref.Kind=rkNext then
        Ref.FKind := rkJmp;
      Stack.Count := L0;
     end
    else if Seq.FState=1 then begin
     {Loop detected, cause the code part is still on the stack}
      if not Ref.IsForward then
        Ref.FKind := rkLoop //!!!Temp - to be improved
      else begin //Seek for the back reference to mark it as a loop
        Ref.FKind := rkJmp;
        i := Stack.Count;
        while i>0 do begin
          Dec(i);
          Ref := Stack[i];
          if not Ref.IsForward then begin
            Ref.FKind := rkLoop;
            break;
          end ;
        end ;
      end ;
     end
    else begin
     {a parallel jump link, which can be || to loop}
      Ref.FKind := rkJmp;
    end ;
  end ;

  procedure DFS(Seq: TCmdSeqCrack);
  begin
    Seq.FState := 1;
    DFSRef(PCmdSeqRefCrack(Seq.FNext));
    DFSRef(PCmdSeqRefCrack(Seq.FNextCond));
    Seq.FState := 2;
    Seq.FLevel := L.Add(Seq); //PostOrder enumeration
  end ;

  procedure PostDFS(Seq: TCmdSeqCrack); forward;

  procedure PostDFSRef(Ref: PCmdSeqRef);
  var
    Seq: TCmdSeq;
  begin
    if Ref=Nil then
      Exit;
    Seq := Ref^.Src;
    if TCmdSeqCrack(Seq).FState=0 then
      PostDFS(TCmdSeqCrack(Seq));
  end ;

  procedure PostDFS(Seq: TCmdSeqCrack);
  var
    Ref: PCmdSeqRef;
  begin
    Seq.FState := 1;
    Ref := Seq.FRefs;
    while Ref<>Nil do begin
      PostDFSRef(Ref);
      Ref := PCmdSeqRefCrack(Ref)^.NextSrc;
    end ;
    Seq.FState := 2;
    Seq.FLevel := L.Add(Seq); //PostOrder enumeration
  end ;

var
  i: Integer;
  P: TProcMemPart;
  Seq: TCmdSeqCrack;
  DomSeq: TCmdSeq;
begin
  L := Nil;
  Stack := TList.Create;
  try
   {Compute DFS postdominator postorder index in L}
    L := TList.Create;
    for i:=Count-1 downto 0 do begin
      P := GetProcMemPart(i);
      if not(P is TCmdSeq) then
        Continue;
      Seq := TCmdSeqCrack(P);
      if (Seq.FNext=Nil)and(Seq.FNextCond=Nil) then begin
        if Seq.FState=0 then
          PostDFS(Seq);
        Seq.FIDom[true{IsPost}] := Nil;
       end
      else
        Seq.FIDom[true{IsPost}] := SeqUnknown;
    end ;
    CalcDominators(L,true{IsPost});
   {Compute DFS postorder index in L - computed after postdominators to reuse L}
    L.Clear;
    for i:=0 to Count-1 do begin
      P := GetProcMemPart(i);
      if not(P is TCmdSeq) then
        Continue;
      Seq := TCmdSeqCrack(P);
      Seq.FState:=0;
    end ;
    for i:=0 to Count-1 do begin
      P := GetProcMemPart(i);
      if not(P is TCmdSeq) then
        Continue;
      Seq := TCmdSeqCrack(P);
      if Seq.FRefs=Nil then begin
        if Seq.FState=0 then
          DFS(Seq);
        Seq.FIDom[false{IsPost}] := Nil
       end
      else
        Seq.FIDom[false{IsPost}] := SeqUnknown;
    end ;
    CalcDominators(L,false{IsPost});
   {Compute levels - reverse postorder}
    for i:=L.Count-1 downto 0 do begin
      Seq := TCmdSeqCrack(L[i]);
      if (Seq.FRefs=Nil)or(Seq.IDom=Nil) then
        Seq.FLevel := 0
      else begin
        DomSeq := Seq.IDom;
        if DomSeq.IPostDom=Seq then
          Seq.FLevel := TCmdSeqCrack(DomSeq).FLevel
        else
          Seq.FLevel := TCmdSeqCrack(DomSeq).FLevel+1;
      end ;
    end ;
  finally
    L.Free;
    Stack.Free;
  end ;
end ;

{$IFDEF OpSem}
procedure TProc.TraceData;
var
  i: Integer;
  P: TProcMemPart;
begin
  if not DefaultCmdSeqClass.NeedTraceData then
    Exit;
  for i:=0 to Count-1 do begin //Trace data flow after computing the code part structure
    P := GetProcMemPart(i);
    {if P is TCmdSeqEnd then
      Continue;}
    if P is TCmdSeq then
      try
        TCmdSeq(P).TraceData;
      except
        raise;
      end;
  end ;
end;
{$ENDIF}

end .