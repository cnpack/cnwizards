unit DiffUnit;

(*******************************************************************************
* Component         TDiff                                                      *
* Version:          1.1                                                        *
* Date:             24 February 2002                                           *
* Compilers:        Delphi 3 - Delphi 6                                        *
* Author:           Angus Johnson - ajohnson@rpi.net.au                        *
* Copyright:        © 2001-2002 Angus Johnson                                  *
                                                                               *
* Licence to use, terms and conditions:                                        *
*                   The code in the TDiff component is released as freeware    *
*                   provided you agree to the following terms & conditions:    *
*                   1. the copyright notice, terms and conditions are          *
*                   left unchanged                                             *
*                   2. modifications to the code by other authors must be      *
*                   clearly documented and accompanied by the modifier's name. *
*                   3. the TDiff component may be freely compiled into binary  *
*                   format and no acknowledgement is required. However, a      *
*                   discrete acknowledgement would be appreciated (eg. in a    *
*                   program's 'About Box').                                    *
*                                                                              *
* Description:      Component to list differences between two integer arrays   *
*                   using a "longest common sequence" algorithm.               *
*                   Typically, this component is used to diff 2 text files     *
*                   once their individuals lines have been hashed.             *
*                   By uncommenting {$DEFINE DIFF_BYTES} this component        *
*                   can also diff char arrays (eg to create file patches)      *
*                                                                              *
* Acknowledgements: The key algorithm in this component is based on:           *
*                   "An O(ND) Difference Algorithm and its Variations"         *
*                   By E Myers - Algorithmica Vol. 1 No. 2, 1986, pp. 251-266  *
*                   http://www.cs.arizona.edu/people/gene/                     *
*                   http://www.cs.arizona.edu/people/gene/PAPERS/diff.ps       *
*                                                                              *
*******************************************************************************)

(*******************************************************************************
* History:                                                                     *
* 13 December 2001 - Original Release                                          *
* 24 February 2002 - OnProgress event added, improvements to code comments     *
*******************************************************************************)

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, ExtCtrls, Forms;

const
  //Maximum allowed deviation from centre diagonal vector ...
  MAX_DIAGONAL = $FFFFF;

type
  PDiagVectorArray = ^TDiagVectorArray;
  TDiagVectorArray = array[-MAX_DIAGONAL.. + MAX_DIAGONAL] of Integer;
  TScriptKind = (skAddRange, skDelRange, skDelDiagDel,
    skAddDiagAdd, skAddDel, skAddDiagDel, skDelDiagAdd);

  //nb: the OnProgress event has only a small effect on overall performance
  {$DEFINE DIFF_PROGRESS}

//USES INTEGER ARRAY NOT BYTE ARRAY FOR THIS DEMO...
//{$DEFINE DIFF_BYTES}

  {$IFDEF DIFF_BYTES}
  TByteArray = array[1..(MaxInt div SizeOf(Byte))] of Byte;
  PByteArray = ^TByteArray;
  {$ELSE}
  TIntArray = array[1..(MaxInt div SizeOf(Integer))] of Integer;
  PIntArray = ^TIntArray;
  {$ENDIF}

  TChangeKind = (ckAdd, ckDelete, ckModify);

  PChangeRec = ^TChangeRec;
  TChangeRec = record
    Kind: TChangeKind;                  //(ckAdd, ckDelete, ckModify)
    x: Integer;                         //Array1 offset (where to add, delete, modify)
    y: Integer;                         //Array2 offset (what to add, modify)
    Range: Integer;                     //range :-)
  end;

  TProgressEvent = procedure(Sender: TObject; ProgressPercent: Integer) of object;

  TDiff = class(TComponent)
  private
    MaxD: Integer;
    fChangeList: TList;
    fLastAdd, fLastDel, fLastMod: PChangeRec;
    diagVecB,
      diagVecF: PDiagVectorArray;       //forward and backward arrays
    Array1,
      Array2: {$IFDEF DIFF_BYTES}PByteArray{$ELSE}PIntArray{$ENDIF};
    fCancelled: Boolean;

    {$IFDEF DIFF_PROGRESS}
    fQpc1, fQpc2, fQpc3: TLargeInteger;
    fHpfcEnabled: Boolean;
    fMaxX: Integer;
    fForwardX: Integer;
    fBackwardX: Integer;
    fProgressTimer: TTimer;
    fProgressInterval: Integer;
    fOnProgress: TProgressEvent;
    procedure DoProgressTimer(Sender: TObject);
    {$ENDIF}

    function RecursiveDiff(x1, y1, x2, y2: Integer): Boolean;
    procedure AddToScript(x1, y1, x2, y2: Integer; ScriptKind: TScriptKind);
    procedure ClearChanges;
    function GetChangeCount: Integer;
    function GetChanges(Index: Integer): TChangeRec;
    procedure PushAdd;
    procedure PushDel;
    procedure PushMod;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {$IFDEF DIFF_BYTES}
    function Execute(const Arr1, Arr2: PByteArray; ArrSize1, ArrSize2: Integer):
      Boolean;
    {$ELSE}
    function Execute(const Arr1, Arr2: PIntArray; ArrSize1, ArrSize2: Integer):
      Boolean;
    {$ENDIF}
    procedure Cancel;                   //allow cancelling prolonged comparisons
    property ChangeCount: Integer read GetChangeCount;
    property changes[Index: Integer]: TChangeRec read GetChanges; default;

    {$IFDEF DIFF_PROGRESS}
    property OnProgress: TProgressEvent read fOnProgress write fOnProgress;
    property ProgressInterval: Integer read fProgressInterval
      write fProgressInterval;
    {$ENDIF}
  end;

implementation

type
  {$IFDEF DIFF_BYTES}
  PArray = PByteArray;
  {$ELSE}
  PArray = PIntArray;
  {$ENDIF}

//--------------------------------------------------------------------------
// Miscellaneous Functions ...
//--------------------------------------------------------------------------

function Min(a, b: Integer): Integer;
begin
  if a < b then Result := a else Result := b;
end;
//--------------------------------------------------------------------------

function Max(a, b: Integer): Integer;
begin
  if a > b then Result := a else Result := b;
end;

//--------------------------------------------------------------------------
// TDiff Class ...
//--------------------------------------------------------------------------

constructor TDiff.Create(AOwner: TComponent);
begin
  inherited;
  fChangeList := TList.Create;
  {$IFDEF DIFF_PROGRESS}
  fProgressTimer := TTimer.Create(Self);
  fProgressTimer.Enabled := False;
  fProgressTimer.OnTimer := DoProgressTimer;
  fProgressInterval := 1000;            //1 second
  fHpfcEnabled := QueryPerformanceFrequency(fQpc1);
  {$ENDIF}
end;
//--------------------------------------------------------------------------

destructor TDiff.Destroy;
begin
  ClearChanges;
  fChangeList.Free;
  inherited;
end;
//--------------------------------------------------------------------------

{$IFDEF DIFF_PROGRESS}
procedure TDiff.DoProgressTimer(Sender: TObject);
begin
  if not fHpfcEnabled or not Assigned(fOnProgress) then Exit
  else if fBackwardX > fForwardX then
    //still trying to find the midpoint of the whole editpath ...
    //empirically it takes about 46% of the time just to find the midpoint.
    fOnProgress(Self, (fMaxX - (fBackwardX - fForwardX)) * 46 div fMaxX)
  else
  begin
    //after the midpoint is found, the simplest way to estimate progress
    //is to use a high-resolution counter ...
    {$IFDEF VER100}
    if fQpc2.quadpart = 0 then QueryPerformanceCounter(fQpc2);
    QueryPerformanceCounter(fQpc3);
    fOnProgress(Self, trunc((fQpc3.quadpart - fQpc1.quadpart) * 46 /
      (fQpc2.quadpart - fQpc1.quadpart)));
    {$ELSE}
    if fQpc2 = 0 then QueryPerformanceCounter(fQpc2);
    QueryPerformanceCounter(fQpc3);
    fOnProgress(Self, ((fQpc3 - fQpc1) * 46 div (fQpc2 - fQpc1)));
    {$ENDIF}
  end;
end;
{$ENDIF}
//--------------------------------------------------------------------------

procedure TDiff.Cancel;
begin
  fCancelled := True;
end;
//--------------------------------------------------------------------------

{$IFDEF DIFF_BYTES}
function TDiff.Execute(const Arr1, Arr2: PByteArray; ArrSize1, ArrSize2: Integer):
  Boolean;
{$ELSE}
function TDiff.Execute(const Arr1, Arr2: PIntArray; ArrSize1, ArrSize2: Integer):
  Boolean;
{$ENDIF}
var
  IntArr_f, IntArr_b: PArray;
begin
  Result := False;
  ClearChanges;

  if not Assigned(Arr1) or not Assigned(Arr2) then Exit;
  Array1 := Arr1;
  Array2 := Arr2;

  //MaxD == Maximum possible deviation from centre diagonal vector
  //which can't be more than the largest intArray (with upperlimit = MAX_DIAGONAL) ...
  MaxD := Min(Max(ArrSize1, ArrSize2), MAX_DIAGONAL);

  //estimate the no. changes == 1/8 total size rounded to a 32bit boundary
  fChangeList.capacity := (Max(MaxD, 1024) div 32) * 4;

  {$IFDEF DIFF_PROGRESS}
  fMaxX := ArrSize1;
  fForwardX := 0;
  fBackwardX := fMaxX;
  fProgressTimer.Enabled := True;
  fProgressTimer.Interval := fProgressInterval;
  QueryPerformanceCounter(fQpc1);
  {$IFDEF VER100}
  fQpc2.QuadPart := 0;
  {$ELSE}
  fQpc2 := 0;
  {$ENDIF}
  {$ENDIF}

  IntArr_f := nil;
  IntArr_b := nil;
  try
    //allocate the vector memory ...
    GetMem(IntArr_f, SizeOf(Integer) * (MaxD * 2 + 1));
    GetMem(IntArr_b, SizeOf(Integer) * (MaxD * 2 + 1));
    //Align the forward and backward diagonal vector arrays
    //with the memory which has just been allocated ...
    Integer(diagVecF) := Integer(IntArr_f) - SizeOf(Integer) * (MAX_DIAGONAL - MaxD);
    Integer(diagVecB) := Integer(IntArr_b) - SizeOf(Integer) * (MAX_DIAGONAL - MaxD);

    fCancelled := False;
    //NOW DO IT HERE...
    Result := RecursiveDiff(0, 0, ArrSize1, ArrSize2);
    //add remaining range buffers onto ChangeList...
    PushAdd;
    PushDel;

    if not Result then ClearChanges;
  finally
    FreeMem(IntArr_f);
    FreeMem(IntArr_b);
    {$IFDEF DIFF_PROGRESS}
    fProgressTimer.Enabled := False;
    {$ENDIF}
  end;
end;
//--------------------------------------------------------------------------

function TDiff.RecursiveDiff(x1, y1, x2, y2: Integer): Boolean;
var
  //normally, parameters and local vars should be stored on the heap for
  //recursive functions. However, as the maximum number of possible recursions
  //here is relatively small (<25) the risk of stack overflow is negligible.
  x, y, Delta, D, k: Integer;
begin
  Result := True;

  //skip over initial and trailing matches...
  D := Min(x2 - x1, y2 - y1);
  k := 0;
  while (k < D) and (Array1[x1 + k + 1] = Array2[y1 + k + 1]) do Inc(k);
  Inc(x1, k);
  Inc(y1, k);
  Dec(D, k);
  k := 0;
  while (k < D) and (Array1[x2 - k] = Array2[y2 - k]) do Inc(k);
  Dec(x2, k);
  Dec(y2, k);

  //check if just all additions or all deletions...
  if (x2 = x1) then
  begin
    AddToScript(x1, y1, x2, y2, skAddRange);
    Exit;
  end else if (y2 = y1) then
  begin
    AddToScript(x1, y1, x2, y2, skDelRange);
    Exit;
  end;

  //divide and conquer ...
  //(recursively) find midpoints of the edit path...
  Delta := (x2 - x1) - (y2 - y1);
  //initialize forward and backward diagonal vectors...
  diagVecF[0] := x1;
  diagVecB[Delta] := x2;
  //OUTER LOOP ...
  //MAKE INCREASING OSCILLATIONS ABOUT CENTRE DIAGONAL UNTIL A FORWARD
  //DIAGONAL VECTOR IS GREATER THAN OR EQUAL TO A BACKWARD DIAGONAL.
  //nb: 'D' doesn't needs to start at 0 as there's never an initial match
  for D := 1 to MaxD do
  begin
    Application.processmessages;
    if fCancelled then
    begin
      Result := False;
      Exit;
    end;

    //forward loop...............................................
    //nb: k == index of current diagonal vector and
    //    will oscillate (in increasing swings) between -MaxD and MaxD
    k := -D;
    while k <= D do
    begin
      //derive x from the larger of the adjacent vectors...
      if (k = -D) or ((k < D) and (diagVecF[k - 1] < diagVecF[k + 1])) then
        x := diagVecF[k + 1] else
        x := diagVecF[k - 1] + 1;
      y := x - x1 + y1 - k;
      //while (x+1,y+1) match - increment them...
      while (x < x2) and (y < y2) and (Array1[x + 1] = Array2[y + 1]) do
      begin
        Inc(x);
        Inc(y);
      end;
      //update current vector ...
      diagVecF[k] := x;
      {$IFDEF DIFF_PROGRESS}
      if x > fForwardX then fForwardX := x;
      {$ENDIF}

      //check if midpoint reached (ie: when diagVecF[k] & diagVecB[k] vectors overlap)...
      //nb: if midpoint found in forward loop then there must be common sub-sequences ...
      if odd(Delta) and (k > -D + Delta) and (k < D + Delta) and (diagVecF[k] >=
        diagVecB[k]) then
      begin
        //To avoid declaring 2 extra variables in this recursive function ..
        //Delta & k are simply reused to store the x & y values ...
        Delta := x;
        k := y;
        //slide up to top (left) of diagonal...
        while (x > x1) and (y > y1) and (Array1[x] = Array2[y]) do
        begin
          Dec(x);
          Dec(y);
        end;
        //do recursion with the first half...
        Result := RecursiveDiff(x1, y1, x, y);
        if not Result then Exit;
        //and again with the second half (nb: Delta & k are stored x & y)...
        Result := RecursiveDiff(Delta, k, x2, y2);
        Exit;                           //All done!!!
      end;
      Inc(k, 2);
    end;

    //backward loop..............................................
    //nb: k will oscillate (in increasing swings) between -MaxD and MaxD
    k := -D + Delta;

    while k <= D + Delta do
    begin
      //make sure we remain within the diagVecB[] and diagVecF[] array bounds...
      if (k < -MaxD) then
      begin
        Inc(k, 2);
        Continue;
      end
      else if (k > MaxD) then Break;

      //derive x from the adjacent vectors...
      if (k = D + Delta) or ((k > -D + Delta) and (diagVecB[k + 1] > diagVecB[k - 1]))
        then
        x := diagVecB[k - 1] else
        x := diagVecB[k + 1] - 1;
      y := x - x1 + y1 - k;
      //while (x,y) match - decrement them...
      while (x > x1) and (y > y1) and (Array1[x] = Array2[y]) do
      begin
        Dec(x);
        Dec(y);
      end;
      //update current vector ...
      diagVecB[k] := x;
      {$IFDEF DIFF_PROGRESS}
      if x < fBackwardX then fBackwardX := x;
      {$ENDIF}

      //check if midpoint reached...
      if not odd(Delta) and (k >= -D) and (k <= D) and (diagVecF[k] >= diagVecB[k])
        then
      begin
        //if D == 1 then the smallest common subsequence must have been found ...
        if D = 1 then                   //nb: if D == 1 then Delta must be in [-2,0,+2]
        begin
          if Delta = 2 then
            AddToScript(x1, y1, x2, y2, skDelDiagDel)
          else if Delta = -2 then
            AddToScript(x1, y1, x2, y2, skAddDiagAdd)
          else if (x1 + 1 = x2) then
            AddToScript(x1, y1, x2, y2, skAddDel)
          else if (Array1[x1 + 2] = Array2[y1 + 1]) then
            AddToScript(x1, y1, x2, y2, skDelDiagAdd)
          else
            AddToScript(x1, y1, x2, y2, skAddDiagDel);
        end else
        begin                           // D > 1 then find common sub-sequences...
          //process the first half...
          Result := RecursiveDiff(x1, y1, x, y);
          if not Result then Exit;
          //now slide down to bottom (right) of diagonal...
          while (x < x2) and (y < y2) and (Array1[x + 1] = Array2[y + 1]) do
          begin
            Inc(x);
            Inc(y);
          end;
          //and process the second half...
          Result := RecursiveDiff(x, y, x2, y2);
        end;
        Exit;                           //All done!!!
      end;
      Inc(k, 2);
    end;

  end;
  Result := False;
end;
//--------------------------------------------------------------------------

(*.................................
                                  .
  skAddRange:      |              .
  (x1 == x2)       |              .
                   |              .
                                  .
  skDelRange:     ----            .
  (y1 == y2)                      .
                                  .
When the midpoint is reached in   .
the smallest possible editgrid,   .
D = 1 & Delta must be even and    .
the snake must appears as one of: .
                                  .
  skAddDiagAdd:     |             .
  (Delta == -2)      \            .
                      |           .
                                  .
  skDelDiagDel:     _             .
  (Delta == +2)      \            .
                      -           .
                                  .
  skAddDel:         |_            .
  (Delta == 0                     .
  & Rec size == 1x1)              .
  nb: skAddDel == skDelAdd        .
                                  .
  skAddDiagDel      |             .
  (Delta == 0)       \            .
                      -           .
                                  .
  skDelDiagAdd      _             .
  (Delta == 0)       \            .
                      |           .
                                  .
.................................*)

procedure TDiff.PushAdd;
begin
  PushMod;
  if Assigned(fLastAdd) then fChangeList.Add(fLastAdd);
  fLastAdd := nil;
end;
//--------------------------------------------------------------------------

procedure TDiff.PushDel;
begin
  PushMod;
  if Assigned(fLastDel) then fChangeList.Add(fLastDel);
  fLastDel := nil;
end;
//--------------------------------------------------------------------------

procedure TDiff.PushMod;
begin
  if Assigned(fLastMod) then fChangeList.Add(fLastMod);
  fLastMod := nil;
end;
//--------------------------------------------------------------------------

//This is a bit UGLY but simply reduces many adds & deletes to many fewer
//add, delete & modify ranges which are then stored in ChangeList...
procedure TDiff.AddToScript(x1, y1, x2, y2: Integer; ScriptKind: TScriptKind);
var
  i: Integer;

  //---------------------------------------------------

  procedure TrashAdd;
  begin
    Dispose(fLastAdd);
    fLastAdd := nil;
  end;
  //---------------------------------------------------

  procedure TrashDel;
  begin
    Dispose(fLastDel);
    fLastDel := nil;
  end;
  //---------------------------------------------------

  procedure NewAdd(x1, y1: Integer);
  begin
    New(fLastAdd);
    fLastAdd.Kind := ckAdd;
    fLastAdd.x := x1;
    fLastAdd.y := y1;
    fLastAdd.Range := 1;
  end;
  //---------------------------------------------------

  procedure NewMod(x1, y1: Integer);
  begin
    New(fLastMod);
    fLastMod.Kind := ckModify;
    fLastMod.x := x1;
    fLastMod.y := y1;
    fLastMod.Range := 1;
  end;
  //---------------------------------------------------

  procedure NewDel(x1: Integer);
  begin
    New(fLastDel);
    fLastDel.Kind := ckDelete;
    fLastDel.x := x1;
    fLastDel.y := 0;
    fLastDel.Range := 1;
  end;
  //---------------------------------------------------

  // 1. there can NEVER be concurrent fLastAdd and fLastDel record ranges.
  // 2. fLastMod is always pushed onto ChangeList before fLastAdd & fLastDel.

  procedure Add(x1, y1: Integer);
  begin
    if Assigned(fLastAdd) then          //OTHER ADDS PENDING
    begin
      if (fLastAdd.x = x1) and
        (fLastAdd.y + fLastAdd.Range = y1) then
        Inc(fLastAdd.Range)             //add in series
      else
      begin
        PushAdd;
        NewAdd(x1, y1);
      end;                              //add NOT in series
    end
    else if Assigned(fLastDel) then     //NO ADDS BUT DELETES PENDING
    begin
      if x1 = fLastDel.x then           //add matches pending del so modify ...
      begin
        if Assigned(fLastMod) and (fLastMod.x + fLastMod.Range - 1 = x1) and
          (fLastMod.y + fLastMod.Range - 1 = y1) then
          Inc(fLastMod.Range)           //modify in series
        else
        begin
          PushMod;
          NewMod(x1, y1);
        end;                            //start NEW modify

        if fLastDel.Range = 1 then TrashDel //decrement or remove existing del
        else
        begin
          Dec(fLastDel.Range);
          Inc(fLastDel.x);
        end;
      end
      else
      begin
        PushDel;
        NewAdd(x1, y1);
      end;                              //add does NOT match pending del's
    end
    else
      NewAdd(x1, y1);                   //NO ADDS OR DELETES PENDING
  end;
  //---------------------------------------------------

  procedure Delete(x1: Integer);
  begin
    if Assigned(fLastDel) then          //OTHER DELS PENDING
    begin
      if (fLastDel.x + fLastDel.Range = x1) then
        Inc(fLastDel.Range)             //del in series
      else
      begin
        PushDel;
        NewDel(x1);
      end;                              //del NOT in series
    end
    else if Assigned(fLastAdd) then     //NO DELS BUT ADDS PENDING
    begin
      if x1 = fLastAdd.x then           //del matches pending add so modify ...
      begin
        if Assigned(fLastMod) and (fLastMod.x + fLastMod.Range = x1) then
          Inc(fLastMod.Range)           //mod in series
        else
        begin
          PushMod;
          NewMod(x1, fLastAdd.y);
        end;                            //start NEW modify ...
        if fLastAdd.Range = 1 then TrashAdd //decrement or remove existing add
        else
        begin
          Dec(fLastAdd.Range);
          Inc(fLastAdd.x);
          Inc(fLastAdd.y);
        end;
      end
      else
      begin
        PushAdd;
        NewDel(x1);
      end;                              //del does NOT match pending add's
    end
    else
      NewDel(x1);                       //NO ADDS OR DELETES PENDING
  end;
  //---------------------------------------------------

begin
  case ScriptKind of
    skAddRange: for i := y1 to y2 - 1 do Add(x1, i);
    skDelRange: for i := x1 to x2 - 1 do Delete(i);
    skDelDiagDel:
      begin
        Delete(x1);
        Delete(x2 - 1);
      end;
    skAddDiagAdd:
      begin
        Add(x1, y1);
        Add(x2, y2 - 1);
      end;
    skAddDel:
      begin
        Add(x1, y1);
        Delete(x2 - 1);
      end;
    skDelDiagAdd:
      begin
        Delete(x1);
        Add(x2, y2 - 1);
      end;
    skAddDiagDel:
      begin
        Add(x1, y1);
        Delete(x2 - 1);
      end;
  end;
end;
//--------------------------------------------------------------------------

procedure TDiff.ClearChanges;
var
  i: Integer;
begin
  for i := 0 to fChangeList.Count - 1 do
    dispose(PChangeRec(fChangeList[i]));
  fChangeList.Clear;
end;
//--------------------------------------------------------------------------

function TDiff.GetChangeCount: Integer;
begin
  Result := fChangeList.Count;
end;
//--------------------------------------------------------------------------

function TDiff.GetChanges(Index: Integer): TChangeRec;
begin
  Result := PChangeRec(fChangeList[Index])^;
end;
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------

end.

