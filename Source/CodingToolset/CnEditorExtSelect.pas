{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorExtSelect;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��㼶����ѡ��ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.04.29 V1.1
*               ���Ʋ��� Pascal ����Ĺ���
*           2021.10.06 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, Menus, ToolsAPI, Contnrs,
  CnWizUtils, CnConsts, CnCommon, CnWizManager, CnWizEditFiler,
  CnCodingToolsetWizard, CnWizConsts, CnSelectionCodeTool, CnWizIdeUtils,
  CnSourceHighlight, CnPasCodeParser, CnEditControlWrapper, mPasLex,
  CnCppCodeParser, mwBCBTokenList, CnIDEStrings;

type
  TCnEditorExtendingSelect = class(TCnBaseCodingToolset)
  private
    FEditPos: TOTAEditPos;
    FSelectStep: Integer;
    FCurrTokenStr: TCnIdeTokenString;
    FTimer: TTimer;
    FNeedReparse: Boolean;
    FSelecting: Boolean;
    FStartPos, FEndPos: TOTACharPos;
    procedure FixPair(APair: TCnBlockLinePair);
    procedure CheckModifiedAndReparse;
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType:
      TCnEditorChangeTypes);
    procedure OnSelectTimer(Sender: TObject);
  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
    function GetState: TWizardState; override;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csProcTokens = [tkProcedure, tkFunction, tkOperator, tkConstructor, tkDestructor];

{ TCnEditorExtendingSelect }

procedure TCnEditorExtendingSelect.FixPair(APair: TCnBlockLinePair);
var
  I: Integer;
begin
  if APair.MiddleCount > 0 then
  begin
    if APair.EndToken.TokenID in [tkElse, tkExcept, tkFinally, tkCase] then
    begin
      APair.EndToken := APair.MiddleToken[APair.MiddleCount - 1];
      APair.DeleteMidToken(APair.MiddleCount - 1);
    end;

    // record of of end ���ֽ������Ľ��Ҫ����
    if (APair.StartToken.TokenID = tkRecord) and (APair.EndToken.TokenID = tkEnd) then
    begin
      for I := APair.MiddleCount - 1 downto 0 do
      begin
        if APair.MiddleToken[I].TokenID = tkOf then
          APair.DeleteMidToken(I);
      end;
    end;
  end;
end;

procedure TCnEditorExtendingSelect.CheckModifiedAndReparse;
const
  NO_LAYER = -2;
var
  EditView: IOTAEditView;
  EditControl: TControl;
  I, J, C, InnerIdx, PairLevel, Step, StStartIdx, StEndIdx: Integer;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  CurIsPas, CurIsCpp, AreaFound, CursorInPair: Boolean;
  BlockMatchInfo: TCnBlockMatchInfo;
  MaxInnerLayer, MinOutLayer: Integer;
  Pair, TmpPair, InnerPair: TCnBlockLinePair;
  LeftBrace, RightBrace: TList;
  InnerStartGot: Boolean;
  PT, PT1, PStStart, PStEnd, POuterLeftBrace, POuterRightBrace: TCnGeneralPasToken;
  CT, CStStart, CStEnd, COuterLeftBrace, COuterRightBrace: TCnGeneralCppToken;
  LastS: string;

  // �ж�һ�� Pair �Ƿ�����˹��λ�ã��ؼ���Ҳ������ȥ�ˣ�������
  function EditPosInPairClose(AEditPos: TOTAEditPos; APairStart, APairEnd: TCnGeneralPasToken): Boolean;
  var
    AfterStart, BeforeEnd: Boolean;
  begin
    AfterStart := (AEditPos.Line > APairStart.EditLine) or
      ((AEditPos.Line = APairStart.EditLine) and (AEditPos.Col >= APairStart.EditCol));
    BeforeEnd := (AEditPos.Line < APairEnd.EditLine) or
      ((AEditPos.Line = APairEnd.EditLine) and (AEditPos.Col <= APairEnd.EditEndCol));

    Result := AfterStart and BeforeEnd;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('EditPosInPairClose Step %d. Is %d %d in Open %d %d to %d %d? %d',
//      [Step, AEditPos.Line, AEditPos.Col, APairStart.EditLine, APairStart.EditCol,
//      APairEnd.EditLine, APairEnd.EditEndCol, Ord(Result)]);
{$ENDIF}
  end;

  // �ж�һ�� Pair �Ƿ�����˹��λ�ã�������ͷβ�ؼ��֣������䣨ע��ͷ�ؼ��ֺ�β�ؼ���ǰ�����������
  function EditPosInPairOpen(AEditPos: TOTAEditPos; APairStart, APairEnd: TCnGeneralPasToken): Boolean;
  var
    AfterStart, BeforeEnd: Boolean;
  begin
    AfterStart := (AEditPos.Line > APairStart.EditLine) or
      ((AEditPos.Line = APairStart.EditLine) and (AEditPos.Col >= APairStart.EditEndCol));
    BeforeEnd := (AEditPos.Line < APairEnd.EditLine) or
      ((AEditPos.Line = APairEnd.EditLine) and (AEditPos.Col <= APairEnd.EditCol));

    Result := AfterStart and BeforeEnd;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('EditPosInPairOpen Step %d. Is %d %d in Open %d %d to %d %d? %d',
//      [Step, AEditPos.Line, AEditPos.Col, APairStart.EditLine, APairStart.EditEndCol,
//      APairEnd.EditLine, APairEnd.EditCol, Ord(Result)]);
{$ENDIF}
  end;

  procedure SetStartEndPos(StartToken, EndToken: TCnGeneralPasToken; Open: Boolean);
  begin
    if Open then
    begin
      FStartPos.Line := StartToken.EditLine;
      FStartPos.CharIndex := StartToken.EditEndCol;
      FEndPos.Line := EndToken.EditLine;
      FEndPos.CharIndex := EndToken.EditCol;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Success! Open at Step %d. %s ... %s', [Step, StartToken.Token, EndToken.Token]);
{$ENDIF}
    end
    else
    begin
      FStartPos.Line := StartToken.EditLine;
      FStartPos.CharIndex := StartToken.EditCol;
      FEndPos.Line := EndToken.EditLine;
      FEndPos.CharIndex := EndToken.EditEndCol;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Success! Close at Step %d at %s ... %s', [Step, StartToken.Token, EndToken.Token]);
{$ENDIF}
    end;
    AreaFound := True;
  end;

  function GetPascalPairStartPrevOne(APair: TCnBlockLinePair; Offset: Integer = 1): TCnGeneralPasToken;
  begin
    Result := nil;
    if (APair <> nil) and (APair.StartToken <> nil) and (APair.StartToken.ItemIndex >= Offset) then
      Result := PasParser.Tokens[APair.StartToken.ItemIndex - Offset];
  end;

  function GetPascalPairEndNextOne(APair: TCnBlockLinePair; Offset: Integer = 1): TCnGeneralPasToken;
  begin
    Result := nil;
    if (APair <> nil) and (APair.EndToken <> nil) and (APair.EndToken.ItemIndex < PasParser.Count - Offset) then
      Result := PasParser.Tokens[APair.EndToken.ItemIndex + Offset];
  end;

  // �õ�һ�� Pair �󣬲��� Step �Ը��ֿ��������ѣ����������� Pascal �� C/C++ ֻ�Ǻ��ߴ��û MiddleTokens ֻ�д��������
  // �ڲ�ʹ�� Step ������FLevel �Ƚϡ�AreaFound ����Ƿ��ҵ����ⲿ����
  procedure SearchInAPair(APair: TCnBlockLinePair; NextTokenAfterPairEnd: TCnGeneralPasToken = nil);
  var
    I: Integer;
  begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Search A Pair with MiddleCount %d. Step Start From %d to Meet Dest Step %d',
//      [APair.MiddleCount, Step, FSelectStep]);
{$ENDIF}
    if APair.MiddleCount = 0 then
    begin
      // ��ͨ Pair����ͷβ�����䣬Step + 1���ж�
      if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, APair.EndToken, True);
          Exit;
        end;
      end;

      // ��ͨ Pair����ͷβ�����䣬Step + 1�� �ж�
      if EditPosInPairClose(FEditPos, APair.StartToken, APair.EndToken) then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, APair.EndToken, False);
          Exit;
        end;
      end;
    end
    else
    begin
      // ��ṹ Pair��������ͷβ�Ŀ��������䣬Step + 1���ж�
      for I := 0 to APair.MiddleCount - 1 do
      begin
        if I = 0 then
        begin
          // ��һ���м䣬��ʼ�͵�һ���м�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.StartToken, APair.MiddleToken[I]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.StartToken, APair.MiddleToken[I], True);
              Exit;
            end;
          end;

          // ��һ���м䣬��ʼ�͵�һ���м�ı������ж�
          if EditPosInPairClose(FEditPos, APair.StartToken, APair.MiddleToken[I]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.StartToken, APair.MiddleToken[I], False);
              Exit;
            end;
          end;
        end;

        if I = APair.MiddleCount - 1 then // ע�ⲻ�� else if
        begin
          // ���һ���м䣬���һ���м�ͽ�β�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.EndToken) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.EndToken, True);
              Exit;
            end;
          end;

          // ���һ���м䣬���һ���м�ͽ�β�ı������ж�
          if EditPosInPairClose(FEditPos, APair.MiddleToken[I], APair.EndToken) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.EndToken, False);
              Exit;
            end;
          end;
        end;

        if (APair.MiddleCount > 1) and (I < APair.MiddleCount - 1) then
        begin
          // ĳ�м��Һ������м䣬���м����һ���м�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.MiddleToken[I + 1]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.MiddleToken[I + 1], True);
              Exit;
            end;
          end;

          // ĳ�м��Һ������м䣬���һ���м�ͽ�β�ı������ж�
          if EditPosInPairClose(FEditPos, APair.MiddleToken[I], APair.MiddleToken[I + 1]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.MiddleToken[I + 1], False);
              Exit;
            end;
          end;
        end;
      end;

      // ���û�ҵ������Ҷ�ṹ Pair ������ͷβ
      if not AreaFound then
      begin
        // ͷ�ͽ�β�Ŀ����䣬Step + 1���ж�
        if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(APair.StartToken, APair.EndToken, True);
            Exit;
          end;
        end;

        // ͷ�ͽ�β�ı����䣬Step + 1���ж�
        if EditPosInPairClose(FEditPos, APair.StartToken, APair.EndToken) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(APair.StartToken, APair.EndToken, False);
            Exit;
          end;
        end;
      end;
    end;

    // ��� APair ��β���� end������紫��Ľ��������޷ֺţ������һ�������
    if not AreaFound and (NextTokenAfterPairEnd <> nil) then
    begin
      if NextTokenAfterPairEnd.TokenID = tkSemiColon then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, NextTokenAfterPairEnd, False);
          Exit;
        end;
      end;
    end;
  end;

  function TokenOnCursor(AToken: TCnGeneralPasToken): Boolean;
  begin
    Result := (FEditPos.Line = AToken.EditLine) and
      (FEditPos.Col <= AToken.EditEndCol) and (FEditPos.Col >= AToken.EditCol);
  end;

  function PairKeysOnCursor(APair: TCnBlockLinePair): Boolean;
  var
    I: Integer;
  begin
    Result := TokenOnCursor(APair.StartToken) or TokenOnCursor(APair.EndToken);
    if not Result then
    begin
      for I := 0 to APair.MiddleCount - 1 do
      begin
        if TokenOnCursor(APair.MiddleToken[I]) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;

begin
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  CurIsPas := IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName);
  CurIsCpp := IsCppSourceModule(EditView.Buffer.FileName);
  if (not CurIsCpp) and (not CurIsPas) then
    Exit;

  // ����
  PasParser := nil;
  CppParser := nil;
  BlockMatchInfo := nil;

  try
    if CurIsPas then
    begin
      PasParser := TCnGeneralPasStructParser.Create;
  {$IFDEF BDS}
      PasParser.UseTabKey := True;
      PasParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    if CurIsCpp then
    begin
      CppParser := TCnGeneralCppStructParser.Create;
  {$IFDEF BDS}
      CppParser.UseTabKey := True;
      CppParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    Stream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

      // ������ǰ��ʾ��Դ�ļ�
      if CurIsPas then
        CnGeneralPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
          or IsInc(EditView.Buffer.FileName), False)
      else if CurIsCpp then
        CnGeneralCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line,
          EditView.CursorPos.Col, True, True);
    finally
      Stream.Free;
    end;

    if CurIsPas then
    begin
      // �������ٲ��ҵ�ǰ������ڵĿ飬��ֱ��ʹ�� CursorPos����Ϊ Parser ����ƫ�ƿ��ܲ�ͬ
      CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
      PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    end;

    BlockMatchInfo := TCnBlockMatchInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := TCnBlockLineInfo.Create(EditControl);

    if CurIsPas then
    begin
      // �����õ� Token ���� BlockMatchInfo ��
      for I := 0 to PasParser.Count - 1 do
      begin
        if PasParser.Tokens[I].TokenID in csKeyTokens + csProcTokens + [tkSemiColon] then
          BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);
      end;
    end
    else if CurIsCpp then
    begin
      // �����õ� Token ���� BlockMatchInfo ��
      for I := 0 to CppParser.Count - 1 do
      begin
        if CppParser.Tokens[I].CppTokenKind <> ctkUnknown then
          BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end;
    end;

    // ת��һ��
    for I := 0 to BlockMatchInfo.KeyCount - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.KeyTokens[I]);

    // �����ԣ����ɶ�� Pair��ע�����һ�� True ��ʾ Pascal �м����� Procedure ����Ϊ Pair
    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView.CursorPos.Line, EditView.CursorPos.Col, False, False, True);

    // BlockMatchInfo ������� LineInfo �ڵ����ݣ����ɶ�� Pair

    // ȥ��ÿ�� Pair β������������ݱ��� Pascal �� else ������
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
      FixPair(BlockMatchInfo.LineInfo.Pairs[I]);
    BlockMatchInfo.LineInfo.SortPairs;

{$IFDEF DEBUG}
//    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
//    begin
//      Pair := BlockMatchInfo.LineInfo.Pairs[I];
//      CnDebugger.LogFmt('Dump Pairs: #%d From %d %d ~ %d %d, ^%d %s ~ %s', [I,
//        Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine,
//        Pair.StartToken.EditCol, Pair.Layer, Pair.StartToken.Token, Pair.EndToken.Token]);
//    end;
{$ENDIF}

    FStartPos.Line := -1;
    FEndPos.Line := -1;
    MaxInnerLayer := NO_LAYER; // -2 ������
    MinOutLayer := MaxInt;
    AreaFound := False;

    // ֻ���ڳ�ʼ�����ȼ�ʱ�ż�¼��겢��Ϊ������ʼ��꣬�Լ���չѡ��������ɵĹ���ƶ�����
    if (FSelectStep <= 1) or ((FEditPos.Line = -1) and (FEditPos.Col = -1)) then
    begin
      FEditPos := EditView.CursorPos;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Set Edit Pos Line %d Col %d', [FEditPos.Line, FEditPos.Col]);
{$ENDIF}
    end;

    // �õ�������� Pair �������
    InnerPair := nil;
    InnerIdx := -1;
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      // ���ҿ���λ�õ����ڲ�Ҳ���� Layer ���� Pair
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      if EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
      begin
        if Pair.Layer > MaxInnerLayer then
        begin
          MaxInnerLayer := Pair.Layer;
          InnerPair := Pair;
          InnerIdx := I;
        end;
        if Pair.Layer < MinOutLayer then
          MinOutLayer := Pair.Layer;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CheckModifiedAndReparse Get Layer from %d to %d.', [MinOutLayer, MaxInnerLayer]);
{$ENDIF}

//    û�ҵ���Ҳ�����˳�����Ҫ����������
//    if (MaxInnerLayer = NO_LAYER) or (MinOutLayer = MaxInt) then
//      Exit;

    // ����������ε������ʺ� FLevel �ģ��������н���������ÿ�� Layer ֻ���� 1
    Step := 0;

    if CurIsPas then
    begin
      // ****** ��С������ ******
      // ����С���š�������ѡ�������Ƿ��� InnerPair �ڣ�������� Step ���� FLevel �Ƚ��ж�
      // �� InnerPair �ڵ� Token ���ҳ��������� InnerPair ��ȫ�ҳ�����׼��ƥ��С���ź�������
      LeftBrace := nil;
      RightBrace := nil;

      try
        LeftBrace := TList.Create;
        RightBrace := TList.Create;
        POuterLeftBrace:= nil;
        POuterRightBrace := nil;
        InnerStartGot := InnerPair = nil; // �� InnerPair �������ʼ��������ȫ��

        for I := 0 to PasParser.Count - 1 do
        begin
          PT := PasParser.Tokens[I];
          if (InnerPair <> nil) and (PT = InnerPair.EndToken) then
            Break;

          if InnerStartGot then
          begin
            if PT.TokenID in [tkRoundOpen, tkRoundClose, tkSquareOpen, tkSquareClose] then
            begin
              ConvertGeneralTokenPos(Pointer(EditView), PT);

              // Token ��ͷλ��С�ڹ�꣬Ҳ���ǹ��λ�ô��� Token ��ͷ���������ţ�����ӵ����
              if ((FEditPos.Line > PT.EditLine) or
                ((FEditPos.Line = PT.EditLine) and (FEditPos.Col > PT.EditCol))) then
                LeftBrace.Insert(0, PT);

              // Token ��βλ��С�ڹ�꣬Ҳ���ǹ��λ��С�� Token β�͵��������ţ��ӵ��ұ�
              if ((FEditPos.Line < PT.EditLine) or
                ((FEditPos.Line = PT.EditLine) and (FEditPos.Col < PT.EditEndCol))) then
                RightBrace.Add(PT);
            end;
          end;

          if (InnerPair <> nil) and (PT = InnerPair.StartToken) then
            InnerStartGot := True;
        end;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('Extract All Pascal Braces in InnerPair: Left %d, Right %d', [LeftBrace.Count, RightBrace.Count]);
{$ENDIF}
        // �õ����ǰ����������ţ��±�͵���������ȸɵ������������ź�С���Ų���
        RemovePasMatchedBraces(LeftBrace, True, True);
        RemovePasMatchedBraces(LeftBrace, False, True);
        RemovePasMatchedBraces(RightBrace, True, False);
        RemovePasMatchedBraces(RightBrace, False, False);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Removed Pascal Matched Braces in InnerPair: Left %d, Right %d', [LeftBrace.Count, RightBrace.Count]);
{$ENDIF}

        C := LeftBrace.Count;
        if RightBrace.Count < C then
          C := RightBrace.Count;

        for I := 0 to C - 1 do // ��� C Ϊ 0 �������
        begin
          // ��һ���������������б�ʶ�������ʼһ����������ͬ�С��Ҿ�����ڱ�ʶ�����ȣ�����β��߿����䣬�����ظ�ѡ��
          if (I = 0) and (FCurrTokenStr <> '') and
            (TCnGeneralPasToken(LeftBrace[0]).LineNumber = TCnGeneralPasToken(RightBrace[0]).LineNumber)
            and (TCnGeneralPasToken(RightBrace[0]).EditCol - TCnGeneralPasToken(LeftBrace[0]).EditEndCol
            = Length(FCurrTokenStr)) then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Pascal #%d Step %d Matched Braces is Current Token. No Open.', [I, Step]);
{$ENDIF}
            Inc(Step);
            POuterLeftBrace:= TCnGeneralPasToken(LeftBrace[I]);
            POuterRightBrace := TCnGeneralPasToken(RightBrace[I]);
            if Step = FSelectStep then // ���߱�����
            begin
              SetStartEndPos(POuterLeftBrace, POuterRightBrace, False);
              Exit;
            end;
          end
          else
          begin
            Inc(Step);
            POuterLeftBrace:= TCnGeneralPasToken(LeftBrace[I]);
            POuterRightBrace := TCnGeneralPasToken(RightBrace[I]);
            if Step = FSelectStep then  // �����ȿ�
            begin
              SetStartEndPos(POuterLeftBrace, POuterRightBrace, True);
              Exit;
            end;
            Inc(Step);
            if Step = FSelectStep then  // ������
            begin
              SetStartEndPos(POuterLeftBrace,POuterRightBrace, False);
              Exit;
            end;
          end;
        end;
      finally
        RightBrace.Free;
        LeftBrace.Free;
      end;

      // ****** ���������ˣ��ҵ�����䣬���������������ҹ���²��� Pair �Ĺؼ��� ******
      if (InnerPair = nil) or (not (InnerPair.StartToken.TokenID in
        [tkClass, tkRecord, tkInterface, tkDispinterface]) and not
        PairKeysOnCursor(InnerPair)) then
      begin
        // InnerPair �ڻ����е����Ŵ�����ϣ����û�У��ٴ� Tokens ����ǰ������������
        // ��������Ƿֺš��޷ֺ��� end/else ǰ��ǰ���ǷֺŻ������ؼ���
        // ע���ҵ���ǰ������������볬�������ҵ�����������ţ�����еĻ���
        PStStart := nil;
        PStEnd := nil;
        StStartIdx := -1;
        StEndIdx := -1;

        for I := 0 to PasParser.Count - 1 do
        begin
          PT := PasParser.Tokens[I];
          if PT.TokenID in csKeyTokens + [tkSemiColon, tkVar, tkConst] then // ֻ����������������ת�����Ƚ�λ��
            ConvertGeneralTokenPos(Pointer(EditView), PT);

          if (FEditPos.Line < PT.EditLine) or // Token ��ͷλ�ú��ڹ��ģ�������
            ((FEditPos.Line = PT.EditLine) and (FEditPos.Col <= PT.EditCol)) then
          begin
            // Ҫ���Ѿ��ҵ����������������֮��ŷ�������
            if (POuterRightBrace = nil) or ((POuterRightBrace.EditLine < PT.EditLine) or
              ((POuterRightBrace.EditLine = PT.EditLine) and (POuterRightBrace.EditCol < PT.EditCol))) then
            begin
              if (PStEnd = nil) and (PT.TokenID = tkSemiColon) then  // �����ֺ�
              begin
                PStEnd := PT;
              end
              else if (PStEnd = nil) and (PT.TokenID in [tkEnd, tkElse, tkThen, tkDo, tkVar, tkConst]) then // �޷ֺţ������� else/end ��������������β
              begin
                PStEnd := PT;
                StEndIdx := I - 1;  // ǰһ����������������β
              end;
            end;
          end;

          if (FEditPos.Line > PT.EditLine) or // Token ��βλ��ǰ�ڹ��ģ���ǰ��
            ((FEditPos.Line = PT.EditLine) and (FEditPos.Col > PT.EditEndCol)) then
          begin
            // Ҫ���Ѿ��ҵ����������������֮ǰ�Ĳŷ�������
            if (POuterLeftBrace = nil) or ((POuterLeftBrace.EditLine > PT.EditLine) or
              ((POuterLeftBrace.EditLine = PT.EditLine) and (POuterLeftBrace.EditCol > PT.EditCol))) then
            begin
              if PT.TokenID in csKeyTokens + [tkSemiColon, tkVar, tkConst] then
              begin
                PStStart := PT;
                StStartIdx := I + 1; // ��һ��������������俪ͷ
              end;
            end;
          end;

          if (PStStart <> nil) and (PStEnd <> nil) then // ǰ���ҵ��ˣ�����
            Break;
        end;

        if (StStartIdx >= 0) and (StStartIdx < PasParser.Count) then // �����߽�
        begin
          PStStart := PasParser.Tokens[StStartIdx];
          ConvertGeneralTokenPos(Pointer(EditView), PStStart);
        end;
        if (StEndIdx >= 0) and (StEndIdx < PasParser.Count) then     // �����߽�
        begin
          PStEnd := PasParser.Tokens[StEndIdx];
          ConvertGeneralTokenPos(Pointer(EditView), PStEnd);
        end;

{$IFDEF DEBUG}
        if (PStStart <> nil) and (PStEnd <> nil) then
          CnDebugger.LogFmt('Get Current Pascal Statement %d %d %s to %d %d %s',
            [PStStart.EditLine, PStStart.EditCol, PStStart.Token,
            PStEnd.EditLine, PStEnd.EditCol, PStEnd.Token]);
{$ENDIF}

        if (PStStart <> nil) and (PStEnd <> nil) then
        begin
          // �ҵ������β���Ҷ��ǰ����ıգ��Ҳ�Ҫ�͵�ǰ����ʶ���ظ�
          if (FCurrTokenStr = '') or (PStStart <> PStEnd) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(PStStart, PStEnd, False);
              Exit;
            end;
          end;

          // �� PStStart ��ǰ��ͷβ����ǰ��Ľ��ڵ� Pair �Ƿ� if/then ���֣�����ѡ���� Pair ͷ�� PStEnd
          for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
          begin
            TmpPair := BlockMatchInfo.LineInfo.Pairs[I];
            if TmpPair.EndToken.TokenID in [tkThen, tkDo, tkOf] then
            begin
              PT := GetPascalPairEndNextOne(TmpPair);
              if PT = PStStart then
              begin
{$IFDEF DEBUG}
                CnDebugger.LogFmt('Get Previous Pair End %d %d %s for Pascal Statement.',
                  [TmpPair.EndToken.EditLine, TmpPair.EndToken.EditCol, TmpPair.EndToken.Token]);
{$ENDIF}
                Inc(Step);
                if Step = FSelectStep then
                begin
                  SetStartEndPos(TmpPair.StartToken, PStEnd, False);
                  Exit;
                end;
                Break; // �ҵ�ƥ���ˣ����������������ѭ��
              end;
            end;

            if TmpPair.EndToken.LineNumber > FEditPos.Line then // ���������ˣ���ǰ����
              Break;
          end;
        end;
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Do Not Search Pascal Statement for No Pair or Decl/Cursor on Pair Keywords.');
{$ENDIF}
      end;

      // ****** �����ڵĲ������ ******
      // InnerPair �ڻ����е����Ŵ�����ϣ����Ҳ������ϣ����û�У���� InnerPair �Ĺ�����ڿ����䵽������ڱ����䣬
      // ��� InnerPair �Ƕ�ṹ�������һ��������������
      if InnerPair <> nil then
      begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('To Search Current Pascal Inner Pair %d %d to %d %d with Level %d',
//        [InnerPair.StartToken.EditLine, InnerPair.StartToken.EditCol,
//        InnerPair.EndToken.EditLine, InnerPair.StartToken.EditCol, InnerPair.Layer]);
{$ENDIF}
        SearchInAPair(InnerPair, GetPascalPairEndNextOne(InnerPair));

        // class/record/interface �� Pair����ǰ����Χ�� = ����ʶ�������ÿ�ε� SearchInAPair ��Ҫ��һ�Σ����������ظ�
        if InnerPair.StartToken.TokenID in [tkClass, tkRecord, tkPacked, tkInterface, tkDispinterface] then
        begin
          PT := GetPascalPairStartPrevOne(InnerPair);
          if (PT <> nil) and ((PT.TokenID = tkEqual) or ((PT.TokenID = tkPacked) and (InnerPair.StartToken.TokenID = tkRecord))) then
          begin
            if PT.TokenID = tkPacked then
              PT := GetPascalPairStartPrevOne(InnerPair, 3)
            else
              PT := GetPascalPairStartPrevOne(InnerPair, 2);

            if (PT <> nil) and (PT.TokenID = tkIdentifier) then
            begin
              ConvertGeneralTokenPos(Pointer(EditView), PT); // �ñ�ʶ��λ�ÿ���û����
              // �ӱ�ʶ���� end
              Inc(Step);
              if Step = FSelectStep then
              begin
                SetStartEndPos(PT, InnerPair.EndToken, False);
                Exit;
              end;

              // ��������� end ��β��β�����зֺţ�����һ����
              if InnerPair.EndToken.TokenID = tkEnd then
              begin
                PT1 := GetPascalPairEndNextOne(InnerPair);
                if (PT1 <> nil) and (PT1.TokenID = tkSemiColon) then
                begin
                  Inc(Step);
                  if Step = FSelectStep then
                  begin
                    // �������̺�����зֺţ�����һ����
                    SetStartEndPos(PT, PT1, False);
                    Exit;
                  end;
                end;
              end;
            end;
          end;
        end;

        // ****** �����Ĳ������ ******
        if not AreaFound then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Pascal InnerPair Search Complete. To Search Other Pairs');
{$ENDIF}
          PairLevel := InnerPair.Layer;
          while PairLevel >= 0 do
          begin
{$IFDEF DEBUG}
//          CnDebugger.LogMsg('In Loop To Find Another Pascal Pair with Level ' + IntToStr(PairLevel));
{$ENDIF}
            for I := InnerIdx downto 0 do
            begin
              // ÿ��һ�� Pair���ҿ����䣬Step + 1���жϣ����ұ����䣬Step + 1���ж�
              // ���жϸ� Pair �Ƿ���ͬ���� procedure/function����������� Step + 1���ж�
              // �ٽ���һ���ظ�����ѭ����ע����ʼ����������Ѿ��ѹ��� InnerPair

              Pair := BlockMatchInfo.LineInfo.Pairs[I];
              CursorInPair := False;
{$IFDEF DEBUG}
//            CnDebugger.LogFmt('To Check Pascal Pair with Level %d. Is %d %d in From %d %d %s to %d %d %s',
//              [Pair.Layer, FEditPos.Line, FEditPos.Col,
//              Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.StartToken.Token,
//              Pair.EndToken.EditLine, Pair.EndToken.EditEndCol, Pair.EndToken.Token]);
{$ENDIF}
              if (Pair <> InnerPair) and EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
              begin
                // �����Ѿ��ѹ��� InnerPair
                CursorInPair := True;
                if Pair.Layer = PairLevel then
                begin
{$IFDEF DEBUG}
//                CnDebugger.LogFmt('Level Match In Pascal Pair %d %d to %d %d. To Search in this Pair with Level %d',
//                  [Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine, Pair.EndToken.EditCol, Pair.Layer]);
{$ENDIF}
                  SearchInAPair(Pair, GetPascalPairEndNextOne(Pair));

                  // class/record/interface �� Pair����ǰ����Χ�� = ����ʶ�������ÿ�ε� SearchInAPair ��Ҫ��һ�Σ����������ظ�
                  if Pair.StartToken.TokenID in [tkClass, tkRecord, tkPacked, tkInterface, tkDispinterface] then
                  begin
                    PT := GetPascalPairStartPrevOne(Pair);
                    if (PT <> nil) and ((PT.TokenID = tkEqual) or ((PT.TokenID = tkPacked) and (Pair.StartToken.TokenID = tkRecord))) then
                    begin
                      if PT.TokenID = tkPacked then
                        PT := GetPascalPairStartPrevOne(Pair, 3)
                      else
                        PT := GetPascalPairStartPrevOne(Pair, 2);

                      if (PT <> nil) and (PT.TokenID = tkIdentifier) then
                      begin
                        ConvertGeneralTokenPos(Pointer(EditView), PT); // �ñ�ʶ��λ�ÿ���û����
                        // �ӱ�ʶ���� end
                        Inc(Step);
                        if Step = FSelectStep then
                        begin
                          SetStartEndPos(PT, Pair.EndToken, False);
                          Exit;
                        end;

                        // ��������� end ��β��β�����зֺţ�����һ����
                        if Pair.EndToken.TokenID = tkEnd then
                        begin
                          PT1 := GetPascalPairEndNextOne(Pair);
                          if (PT1 <> nil) and (PT1.TokenID = tkSemiColon) then
                          begin
                            Inc(Step);
                            if Step = FSelectStep then
                            begin
                              // �������̺�����зֺţ�����һ����
                              SetStartEndPos(PT, PT1, False);
                              Exit;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
              if Pair = InnerPair then // �Ѿ��ѹ��� InnerPair������Ȼ�ڴ� Pair ��
                CursorInPair := True;

              // �����ǲ����ѹ��� InnerPair��ֻҪ���Ƿ��ϼ���� begin/end���Ұ������λ�ã���Ҫ����ǰ��ͬ���� if ��
              if not AreaFound and CursorInPair and (Pair.Layer = PairLevel) and (Pair.MiddleCount = 0) and
                (Pair.StartToken.TokenID in [tkBegin, tkAsm]) and (Pair.EndToken.TokenID = tkEnd) then
              begin
{$IFDEF DEBUG}
                CnDebugger.LogMsg('Not Found in This Pair. Check other Pairs with Same Level ' + IntToStr(Pair.Layer));
{$ENDIF}
                // ��ǰ�����޺� Pair ��� begin end ͬ���� if/then��while/do��procedure/function���м䲻��������ͬ���� begin end
                for J := I - 1 downto 0 do
                begin
                  TmpPair := BlockMatchInfo.LineInfo.Pairs[J];
                  if TmpPair.Layer = Pair.Layer then
                  begin
                    // ����ͬ���� begin end ��ʾ���漴ʹ�� if ʲô��Ҳ������һ���
                    if (TmpPair.StartToken.TokenID in [tkBegin, tkAsm]) and (TmpPair.EndToken.TokenID = tkEnd) then
                      Break;

                    if ((TmpPair.StartToken.TokenID = tkIf) and (TmpPair.EndToken.TokenID = tkThen))
                      or ((TmpPair.StartToken.TokenID = tkWhile) and (TmpPair.EndToken.TokenID = tkDo))
                      or ((TmpPair.StartToken.TokenID = tkFor) and (TmpPair.EndToken.TokenID = tkDo))
                      or ((TmpPair.StartToken.TokenID = tkWith) and (TmpPair.EndToken.TokenID = tkDo)) then
                    begin
{$IFDEF DEBUG}
                      CnDebugger.LogMsg('Get Backward Same Level ' + IntToStr(Pair.Layer) + ' ' + TmpPair.StartToken.Token);
{$ENDIF}
                      Inc(Step);
                      if Step = FSelectStep then
                      begin
                        SetStartEndPos(TmpPair.StartToken, Pair.EndToken, True);
                        Exit;
                      end;
                      Inc(Step);
                      if Step = FSelectStep then
                      begin
                        SetStartEndPos(TmpPair.StartToken, Pair.EndToken, False);
                        Exit;
                      end;
                      Break; // �Ѿ��ҵ���ͬ�� if ����䣬�������� function/procedure ��
                    end;

                    // ������ͬ���������ڵ� function/procedure
                    if (TmpPair.StartToken.TokenID in csProcTokens)
                      and (TmpPair.EndToken.TokenID in csProcTokens) then
                    begin
                      Inc(Step);
                      if Step = FSelectStep then
                      begin
                        // �������̾ͱ����䣬û�п�����
                        SetStartEndPos(TmpPair.StartToken, Pair.EndToken, False);
                        Exit;
                      end;

                      PT := GetPascalPairEndNextOne(Pair);
                      if (PT <> nil) and (PT.TokenID = tkSemiColon) then
                      begin
                        Inc(Step);
                        if Step = FSelectStep then
                        begin
                          // �������̺�����зֺţ�����һ����
                          SetStartEndPos(TmpPair.StartToken, PT, False);
                          Exit;
                        end;
                      end;
                      Break;
                    end;
                  end;
                end;
              end
              else if not AreaFound and CursorInPair and (Pair.Layer = PairLevel) and
                (Pair.MiddleCount = 0) and (I < BlockMatchInfo.LineInfo.Count - 1) and (  // ����û��� Pair
                ((Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen)) or
                ((Pair.StartToken.TokenID = tkFor) and (Pair.EndToken.TokenID = tkDo)) or
                ((Pair.StartToken.TokenID = tkWith) and (Pair.EndToken.TokenID = tkDo)) or
                ((Pair.StartToken.TokenID = tkWhile) and (Pair.EndToken.TokenID = tkDo)) ) then
              begin
                // ֻҪ���Ƿ��ϼ���� if then/for do/with do/while do���Ұ������λ�ã�
                // ��Ҫ����������������������ͬ�� begin end ������ if then/for do/with do/while do
                // ע�����ͬ����ʵ�ǽ������ó��ı�ʾ�����Ĳ�ȷ�н��ۣ�����ֻ��������
                TmpPair := Pair;
                for J := I + 1 to BlockMatchInfo.LineInfo.Count - 1 do
                begin
                  // ��� BlockMatchInfo.LineInfo.Pairs[J] �� TmpPair �м����������ݣ�˵������һ���߼�����Ҫ����
{$IFDEF DEBUG}
                  CnDebugger.LogFmt('Check Forward Pair %d %s to Previous %d %s ',
                    [BlockMatchInfo.LineInfo.Pairs[J].StartToken.ItemIndex,
                    BlockMatchInfo.LineInfo.Pairs[J].StartToken.Token,
                    TmpPair.EndToken.ItemIndex, TmpPair.EndToken.Token]);
{$ENDIF}
                  if BlockMatchInfo.LineInfo.Pairs[J].StartToken.ItemIndex - TmpPair.EndToken.ItemIndex <> 1 then
                  begin
{$IFDEF DEBUG}
                    CnDebugger.LogMsg('Forward Next Level but Far Away. Break for ' + IntToStr(Pair.Layer) + ' ' + BlockMatchInfo.LineInfo.Pairs[J].StartToken.Token);
{$ENDIF}
                    Break;
                  end;

                  TmpPair := BlockMatchInfo.LineInfo.Pairs[J];
                  if (TmpPair.Layer = Pair.Layer) and (
                    ((TmpPair.StartToken.TokenID = tkIf) and (TmpPair.EndToken.TokenID = tkThen)) or
                    ((TmpPair.StartToken.TokenID = tkWhile) and (TmpPair.EndToken.TokenID = tkDo)) or
                    ((TmpPair.StartToken.TokenID = tkFor) and (TmpPair.EndToken.TokenID = tkDo)) or
                    ((TmpPair.StartToken.TokenID = tkWith) and (TmpPair.EndToken.TokenID = tkDo)) or
                    ((TmpPair.StartToken.TokenID in [tkBegin, tkAsm]) and (TmpPair.EndToken.TokenID = tkEnd)) ) then
                  begin
{$IFDEF DEBUG}
                    CnDebugger.LogMsg('Get Forward Same Level ' + IntToStr(Pair.Layer) + ' ' + TmpPair.StartToken.Token);
{$ENDIF}
                    Inc(Step);
                    if Step = FSelectStep then
                    begin
                      SetStartEndPos(Pair.StartToken, TmpPair.EndToken, True);
                      Exit;
                    end;
                    Inc(Step);
                    if Step = FSelectStep then
                    begin
                      SetStartEndPos(Pair.StartToken, TmpPair.EndToken, False);
                      Exit;
                    end;

                    // begin end ����зֺ��ټ�һ��
                    if TmpPair.EndToken.TokenID = tkEnd then
                    begin
                      PT := GetPascalPairEndNextOne(TmpPair);
                      if PT.TokenID = tkSemiColon then
                      begin
                        Inc(Step);
                        if Step = FSelectStep then
                        begin
                          SetStartEndPos(Pair.StartToken, PT, False);
                          Exit;
                        end;
                      end;
                    end;
                  end;

                  if TmpPair.Layer <> Pair.Layer then
                    Break;
                end;
              end;
            end;
            Dec(PairLevel); // �Ƿ��ڱ��㣿
          end;
        end;
      end;
    end
    else if CurIsCpp then
    begin
      // ����С���š�������ѡ�������Ƿ��� InnerPair �ڣ�������� Step ���� FLevel �Ƚ��ж�
      // �� InnerPair �ڵ� Token ���ҳ��������� InnerPair ��ȫ�ҳ�����׼��ƥ��С���ź�������
      LeftBrace := nil;
      RightBrace := nil;

      try
        LeftBrace := TList.Create;
        RightBrace := TList.Create;
        COuterLeftBrace := nil;
        COuterRightBrace := nil;
        InnerStartGot := InnerPair = nil; // �� InnerPair �������ʼ��������ȫ��

        for I := 0 to CppParser.Count - 1 do
        begin
          CT := CppParser.Tokens[I];
          if (InnerPair <> nil) and (CT = InnerPair.EndToken) then
            Break;

          if InnerStartGot then
          begin
            if CT.CppTokenKind in [ctkroundopen, ctkroundClose, ctksquareopen, ctksquareclose] then
            begin
              ConvertGeneralTokenPos(Pointer(EditView), CT);

              // Token ��ͷλ��С�ڹ�꣬Ҳ���ǹ��λ�ô��� Token ��ͷ���������ţ�����ӵ����
              if ((FEditPos.Line > CT.EditLine) or
                ((FEditPos.Line = CT.EditLine) and (FEditPos.Col > CT.EditCol))) then
                LeftBrace.Insert(0, CT);

              // Token ��βλ��С�ڹ�꣬Ҳ���ǹ��λ��С�� Token β�͵��������ţ��ӵ��ұ�
              if ((FEditPos.Line < CT.EditLine) or
                ((FEditPos.Line = CT.EditLine) and (FEditPos.Col < CT.EditEndCol))) then
                RightBrace.Add(CT);
            end;
          end;

          if (InnerPair <> nil) and (CT = InnerPair.StartToken) then
            InnerStartGot := True;
        end;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('Extract All C/C++ Braces in InnerPair: Left %d, Right %d', [LeftBrace.Count, RightBrace.Count]);
{$ENDIF}
        // �õ����ǰ����������ţ��±�͵���������ȸɵ������������ź�С���Ų���
        RemoveCppMatchedBraces(LeftBrace, True, True);
        RemoveCppMatchedBraces(LeftBrace, False, True);
        RemoveCppMatchedBraces(RightBrace, True, False);
        RemoveCppMatchedBraces(RightBrace, False, False);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Removed C/C++ Matched Braces in InnerPair: Left %d, Right %d', [LeftBrace.Count, RightBrace.Count]);
{$ENDIF}

        C := LeftBrace.Count;
        if RightBrace.Count < C then
          C := RightBrace.Count;

        for I := 0 to C - 1 do // ��� C Ϊ 0 �������
        begin
          // ��һ���������������б�ʶ�������ʼһ����������ͬ�С��Ҿ�����ڱ�ʶ�����ȣ�����β��߿����䣬�����ظ�ѡ��
          if (I = 0) and (FCurrTokenStr <> '') and
            (TCnGeneralCppToken(LeftBrace[0]).LineNumber = TCnGeneralCppToken(RightBrace[0]).LineNumber)
            and (TCnGeneralCppToken(RightBrace[0]).EditCol - TCnGeneralCppToken(LeftBrace[0]).EditEndCol
            = Length(FCurrTokenStr)) then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogFmt('C/C++ #%d Step %d Matched Braces is Current Token. No Open.', [I, Step]);
{$ENDIF}
            Inc(Step);
            COuterLeftBrace:= TCnGeneralCppToken(LeftBrace[I]);
            COuterRightBrace := TCnGeneralCppToken(RightBrace[I]);
            if Step = FSelectStep then // ���߱�����
            begin
              SetStartEndPos(COuterLeftBrace, COuterRightBrace, False);
              Exit;
            end;
          end
          else
          begin
            Inc(Step);
            COuterLeftBrace:= TCnGeneralCppToken(LeftBrace[I]);
            COuterRightBrace := TCnGeneralCppToken(RightBrace[I]);
            if Step = FSelectStep then
            begin
              SetStartEndPos(COuterLeftBrace, COuterRightBrace, True);
              Exit;
            end;
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(COuterLeftBrace, COuterRightBrace, False);
              Exit;
            end;
          end;
        end;
      finally
        RightBrace.Free;
        LeftBrace.Free;
      end;

      // InnerPair �ڻ����е����Ŵ�����ϣ����û�У��ٴ� Tokens ����ǰ������������
      // ��������Ƿֺţ�ǰ���ǷֺŻ� { ��
      CStStart := nil;
      CStEnd := nil;
      StStartIdx := -1;
      StEndIdx := -1;

      for I := 0 to CppParser.Count - 1 do
      begin
        CT := CppParser.Tokens[I];
        if CT.CppTokenKind in [ctksemicolon, ctkbraceopen, ctkelse] then // ֻ����������������ת�����Ƚ�λ��
          ConvertGeneralTokenPos(Pointer(EditView), CT);

        if ((FEditPos.Line < CT.EditLine) or // Token ��ͷλ�ú��ڹ��ģ�������
          ((FEditPos.Line = CT.EditLine) and (FEditPos.Col <= CT.EditCol))) then
        begin
          // Ҫ���Ѿ��ҵ����������������֮��ŷ�������
          if (COuterRightBrace = nil) or ((COuterRightBrace.EditLine < CT.EditLine) or
            ((COuterRightBrace.EditLine = CT.EditLine) and (COuterRightBrace.EditCol < CT.EditCol))) then
          begin
            if (CStEnd = nil) and (CT.CppTokenKind = ctksemicolon) then  // �����ֺ�
              CStEnd := CT;
          end;
        end;

        if ((FEditPos.Line > CT.EditLine) or // Token ��βλ��ǰ�ڹ��ģ���ǰ��
          ((FEditPos.Line = CT.EditLine) and (FEditPos.Col > CT.EditEndCol))) then
        begin
          // Ҫ���Ѿ��ҵ����������������֮ǰ�Ĳŷ�������
          if (COuterLeftBrace = nil) or ((COuterLeftBrace.EditLine > CT.EditLine) or
            ((COuterLeftBrace.EditLine = CT.EditLine) and (COuterLeftBrace.EditCol > CT.EditCol))) then
          begin
            if CT.CppTokenKind in [ctksemicolon, ctkbraceopen, ctkelse] then
            begin
              CStStart := CT;
              StStartIdx := I + 1; // ��һ��������������俪ͷ
            end;
          end;
        end;

        if (CStStart <> nil) and (CStEnd <> nil) then // ǰ���ҵ��ˣ�����
          Break;
      end;

      if (StStartIdx >= 0) and (StStartIdx < CppParser.Count) then // �����߽�
      begin
        CStStart := CppParser.Tokens[StStartIdx];
        ConvertGeneralTokenPos(Pointer(EditView), CStStart);
      end;
      if (StEndIdx >= 0) and (StEndIdx < PasParser.Count) then     // �����߽�
      begin
        CStEnd := CppParser.Tokens[StEndIdx];
        ConvertGeneralTokenPos(Pointer(EditView), CStEnd);
      end;

{$IFDEF DEBUG}
      if (CStStart <> nil) and (CStEnd <> nil) then
        CnDebugger.LogFmt('Get Current C/C++ Statement %d %d %s to %d %d %s',
          [CStStart.EditLine, CStStart.EditCol, CStStart.Token,
          CStEnd.EditLine, CStEnd.EditCol, CStEnd.Token]);
{$ENDIF}

      if (CStStart <> nil) and (CStEnd <> nil) then
      begin
        // �ҵ������β���Ҷ��ǰ����ıգ��Ҳ�Ҫ�͵�ǰ����ʶ���ظ�
        if (FCurrTokenStr = '') or (CStStart <> CStEnd) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(CStStart, CStEnd, False);
            Exit;
          end;
        end;
      end;

      // С���ź������Ŵ������
      if InnerPair <> nil then
      begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('To Search Current C/C++ Inner Pair %d %d to %d %d with Level %d',
//        [InnerPair.StartToken.EditLine, InnerPair.StartToken.EditCol,
//        InnerPair.EndToken.EditLine, InnerPair.StartToken.EditCol, InnerPair.Layer]);
{$ENDIF}
        SearchInAPair(InnerPair); // �����ź�����ֺ�

        if not AreaFound then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('C/C++ InnerPair Search Complete. To Search Other Pairs');
{$ENDIF}
          PairLevel := InnerPair.Layer;
          while PairLevel >= 0 do
          begin
{$IFDEF DEBUG}
//          CnDebugger.LogMsg('In Loop To Find Another C/C++ Pair with Level ' + IntToStr(PairLevel));
{$ENDIF}
            for I := InnerIdx downto 0 do
            begin
              // ÿ��һ�� Pair���ҿ����䣬Step + 1���жϣ����ұ����䣬Step + 1���ж�
              // �ٽ���һ���ظ�����ѭ����ע����ʼ����������Ѿ��ѹ��� InnerPair

              Pair := BlockMatchInfo.LineInfo.Pairs[I];
{$IFDEF DEBUG}
//            CnDebugger.LogFmt('To Check C/C++ Pair with Level %d. Is %d %d in From %d %d %s to %d %d %s',
//              [Pair.Layer, FEditPos.Line, FEditPos.Col,
//              Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.StartToken.Token,
//              Pair.EndToken.EditLine, Pair.EndToken.EditEndCol, Pair.EndToken.Token]);
{$ENDIF}
              if (Pair <> InnerPair) and EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
              begin
                // �����Ѿ��ѹ��� InnerPair
                if Pair.Layer = PairLevel then
                begin
{$IFDEF DEBUG}
//                CnDebugger.LogFmt('Level Match In C/C++ Pair %d %d to %d %d. To Search in this Pair with Level %d',
//                  [Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine, Pair.EndToken.EditCol, Pair.Layer]);
{$ENDIF}
                  SearchInAPair(Pair);
                end;
              end;
            end;
            Dec(PairLevel); // �Ƿ��ڱ��㣿
          end;
        end;
      end;
    end;

    if not AreaFound then
    begin
      // û�����ڵĲ㣬��ɶ��û�ҵ���ֱ��ȫѡ�����ļ�
      FStartPos.Line := 1;
      FStartPos.CharIndex := 0;
      FEndPos.Line := EditView.Buffer.GetLinesInBuffer;
      LastS := CnOtaGetLineText(FEndPos.Line, EditView.Buffer);
      FEndPos.CharIndex := Length(LastS);
      Exit;
    end;
  finally
    BlockMatchInfo.LineInfo.Free;
    BlockMatchInfo.LineInfo := nil;
    BlockMatchInfo.Free; // LineInfo �� nil ������� Clear ���ܽ���
    PasParser.Free;
    CppParser.Free;
  end;
end;

constructor TCnEditorExtendingSelect.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 500;
  FTimer.OnTimer := OnSelectTimer;
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
end;

destructor TCnEditorExtendingSelect.Destroy;
begin
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  FTimer.Free;
  inherited;
end;

procedure TCnEditorExtendingSelect.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
begin
  if ChangeType * [ctView, ctModified, ctTopEditorChanged, ctOptionChanged] <> [] then
    FNeedReparse := True;

  if not FSelecting and (ChangeType * [ctBlock] <> []) then
  begin
    FSelectStep := 0;
    FEditPos.Line := -1;
    FEditPos.Col := -1;
    FCurrTokenStr := '';
  end;
end;

procedure TCnEditorExtendingSelect.Execute;
var
  CurrIndex: Integer;
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  // ���������
  // ���û��ѡ��������ѡ��ǰ��ʶ������ Level 1���ޱ�ʶ���Ļ�������ѡ���ڲ㿪���䣬���� Level 2
  // �����ѡ������������������ݵ�ǰ Level ������ 1 ѡ��
  // �㼶����˳����ѡ���� 0������±�ʶ�� 1����һ���У�����ǰ����ڿ����� 2��
  // ��ǰ������䣨Ҳ���������飬�����зֺžͼӸ��ֺţ�3
  // �͵�ǰ��ͬ�������п飨�������������Ļ���4��������ڿ����� 5���Դ�����

  FSelecting := True;
  try
    if (EditView.Block = nil) or not EditView.Block.IsValid then
    begin
      // ��¼������ı�ʶ��
      if CnOtaGeneralGetCurrPosToken(FCurrTokenStr, CurrIndex) then
      begin
        if FCurrTokenStr <> '' then
        begin
          // ������б�ʶ����ѡ��
          CnOtaSelectCurrentToken;
          Exit;
        end;
      end;
    end;

    Inc(FSelectStep);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('EditorExtendingSelect To Select Step %d.', [FSelectStep]);
{$ENDIF}

    CheckModifiedAndReparse;

    // ѡ�� FLevel ��Ӧ����
    if (FStartPos.Line >= 0) and (FEndPos.Line >= 0) then
    begin
      CnOtaMoveAndSelectBlock(FStartPos, FEndPos);
{$IFDEF WIN64}
      EditView.Paint;
{$ENDIF}
    end;
  finally
    FTimer.Enabled := False;
    FTimer.Enabled := True; // �����Ӻ����� FSelecting
  end;
end;

function TCnEditorExtendingSelect.GetCaption: string;
begin
  Result := SCnEditorExtendingSelectMenuCaption;
end;

function TCnEditorExtendingSelect.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+Q');
end;

procedure TCnEditorExtendingSelect.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorExtendingSelectName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorExtendingSelect.GetHint: string;
begin
  Result := SCnEditorExtendingSelectMenuHint;
end;

function TCnEditorExtendingSelect.GetState: TWizardState;
begin
  Result := inherited GetState;
  if wsEnabled in Result then
  begin
    if not CurrentIsSource then
      Result := [];
  end;
end;

procedure TCnEditorExtendingSelect.OnSelectTimer(Sender: TObject);
begin
  FSelecting := False;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtendingSelect);

end.
