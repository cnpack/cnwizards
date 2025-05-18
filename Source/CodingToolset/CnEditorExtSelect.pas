{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorExtSelect;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：层级渐进选择实现单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin7 SP2 + Delphi 5.01
* 兼容测试：PWin7 + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2025.04.29 V1.1
*               完善部分 Pascal 代码的功能
*           2021.10.06 V1.0
*               创建单元，实现功能
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

    // record of of end 这种解析出的结果要调整
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

  // 判断一个 Pair 是否包括了光标位置，关键字也包括进去了，闭区间
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

  // 判断一个 Pair 是否包括了光标位置，不包括头尾关键字，开区间（注意头关键字后、尾关键字前，算包括）。
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

  // 拿到一个 Pair 后，步进 Step 以各种开闭区间搜，照理适用于 Pascal 和 C/C++ 只是后者大概没 MiddleTokens 只有大括号配对
  // 内部使用 Step 步进、FLevel 比较、AreaFound 输出是否找到等外部变量
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
      // 普通 Pair，找头尾开区间，Step + 1，判断
      if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, APair.EndToken, True);
          Exit;
        end;
      end;

      // 普通 Pair，找头尾闭区间，Step + 1， 判断
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
      // 多结构 Pair，找所在头尾的开、闭区间，Step + 1，判断
      for I := 0 to APair.MiddleCount - 1 do
      begin
        if I = 0 then
        begin
          // 第一个中间，开始和第一个中间的开区间判断
          if EditPosInPairOpen(FEditPos, APair.StartToken, APair.MiddleToken[I]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.StartToken, APair.MiddleToken[I], True);
              Exit;
            end;
          end;

          // 第一个中间，开始和第一个中间的闭区间判断
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

        if I = APair.MiddleCount - 1 then // 注意不能 else if
        begin
          // 最后一个中间，最后一个中间和结尾的开区间判断
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.EndToken) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.EndToken, True);
              Exit;
            end;
          end;

          // 最后一个中间，最后一个中间和结尾的闭区间判断
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
          // 某中间且后面有中间，本中间和下一个中间的开区间判断
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.MiddleToken[I + 1]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.MiddleToken[I + 1], True);
              Exit;
            end;
          end;

          // 某中间且后面有中间，最后一个中间和结尾的闭区间判断
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

      // 如果没找到，则找多结构 Pair 的整个头尾
      if not AreaFound then
      begin
        // 头和结尾的开区间，Step + 1，判断
        if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(APair.StartToken, APair.EndToken, True);
            Exit;
          end;
        end;

        // 头和结尾的闭区间，Step + 1，判断
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

    // 如果 APair 的尾巴是 end，找外界传入的紧跟的有无分号，有则加一层闭区间
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

  // 解析
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

      // 解析当前显示的源文件
      if CurIsPas then
        CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
          or IsInc(EditView.Buffer.FileName), False)
      else if CurIsCpp then
        CnCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line,
          EditView.CursorPos.Col, True, True);
    finally
      Stream.Free;
    end;

    if CurIsPas then
    begin
      // 解析后再查找当前光标所在的块，不直接使用 CursorPos，因为 Parser 所需偏移可能不同
      CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
      PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    end;

    BlockMatchInfo := TCnBlockMatchInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := TCnBlockLineInfo.Create(EditControl);

    if CurIsPas then
    begin
      // 把有用的 Token 加入 BlockMatchInfo 中
      for I := 0 to PasParser.Count - 1 do
      begin
        if PasParser.Tokens[I].TokenID in csKeyTokens + csProcTokens + [tkSemiColon] then
          BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);
      end;
    end
    else if CurIsCpp then
    begin
      // 把有用的 Token 加入 BlockMatchInfo 中
      for I := 0 to CppParser.Count - 1 do
      begin
        if CppParser.Tokens[I].CppTokenKind <> ctkUnknown then
          BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end;
    end;

    // 转换一下
    for I := 0 to BlockMatchInfo.KeyCount - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.KeyTokens[I]);

    // 检查配对，生成多个 Pair，注意最后一个 True 表示 Pascal 中加入了 Procedure 等作为 Pair
    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView.CursorPos.Line, EditView.CursorPos.Col, False, False, True);

    // BlockMatchInfo 的输出是 LineInfo 内的内容，生成多个 Pair

    // 去掉每个 Pair 尾部不合理的内容比如 Pascal 的 else 再排序
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
    MaxInnerLayer := NO_LAYER; // -2 不存在
    MinOutLayer := MaxInt;
    AreaFound := False;

    // 只有在初始按下热键时才记录光标并作为搜索起始光标，自己扩展选择区域造成的光标移动不算
    if (FSelectStep <= 1) or ((FEditPos.Line = -1) and (FEditPos.Col = -1)) then
    begin
      FEditPos := EditView.CursorPos;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Set Edit Pos Line %d Col %d', [FEditPos.Line, FEditPos.Col]);
{$ENDIF}
    end;

    // 得到光标所在 Pair 的最深层
    InnerPair := nil;
    InnerIdx := -1;
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      // 先找跨光标位置的最内层也就是 Layer 最大的 Pair
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

//    没找到层也不能退出，需要单独找括号
//    if (MaxInnerLayer = NO_LAYER) or (MinOutLayer = MaxInt) then
//      Exit;

    // 从内往外逐次递增找适合 FLevel 的，但递增有讲究，并非每个 Layer 只递增 1
    Step := 0;

    if CurIsPas then
    begin
      // ****** 找小中括号 ******
      // 扩大小括号、中括号选区，看是否在 InnerPair 内，在则递增 Step 并和 FLevel 比较判断
      // 把 InnerPair 内的 Token 都找出来，如无 InnerPair 则全找出来，准备匹配小括号和中括号
      LeftBrace := nil;
      RightBrace := nil;

      try
        LeftBrace := TList.Create;
        RightBrace := TList.Create;
        POuterLeftBrace:= nil;
        POuterRightBrace := nil;
        InnerStartGot := InnerPair = nil; // 有 InnerPair 则从它开始，否则搜全局

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

              // Token 开头位置小于光标，也就是光标位置大于 Token 开头的左右括号，逆向加到左边
              if ((FEditPos.Line > PT.EditLine) or
                ((FEditPos.Line = PT.EditLine) and (FEditPos.Col > PT.EditCol))) then
                LeftBrace.Insert(0, PT);

              // Token 结尾位置小于光标，也就是光标位置小于 Token 尾巴的左右括号，加到右边
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
        // 拿到光标前后的左右括号，下标低的离光标近，先干掉抵消的中括号和小括号部分
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

        for I := 0 to C - 1 do // 如果 C 为 0 则进不来
        begin
          // 第一轮里，如果光标下最初有标识符、且最开始一对左右括号同行、且距离等于标识符长度，则这次不走开区间，避免重复选择
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
            if Step = FSelectStep then // 仅走闭区间
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
            if Step = FSelectStep then  // 常规先开
            begin
              SetStartEndPos(POuterLeftBrace, POuterRightBrace, True);
              Exit;
            end;
            Inc(Step);
            if Step = FSelectStep then  // 常规后闭
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

      // ****** 括号找完了，找单独语句，但不进块声明，且光标下不是 Pair 的关键字 ******
      if (InnerPair = nil) or (not (InnerPair.StartToken.TokenID in
        [tkClass, tkRecord, tkInterface, tkDispinterface]) and not
        PairKeysOnCursor(InnerPair)) then
      begin
        // InnerPair 内或所有的括号处理完毕，如果没中，再从 Tokens 中找前后语句结束符，
        // 后结束符是分号、无分号则 end/else 前，前则是分号或其他关键字
        // 注意找到的前后结束符，必须超出上面找到的最外层括号（如果有的话）
        PStStart := nil;
        PStEnd := nil;
        StStartIdx := -1;
        StEndIdx := -1;

        for I := 0 to PasParser.Count - 1 do
        begin
          PT := PasParser.Tokens[I];
          if PT.TokenID in csKeyTokens + [tkSemiColon, tkVar, tkConst] then // 只挑出符合条件的来转换并比较位置
            ConvertGeneralTokenPos(Pointer(EditView), PT);

          if (FEditPos.Line < PT.EditLine) or // Token 开头位置后于光标的，往后找
            ((FEditPos.Line = PT.EditLine) and (FEditPos.Col <= PT.EditCol)) then
          begin
            // 要在已经找到过的最外层右括号之后才符合条件
            if (POuterRightBrace = nil) or ((POuterRightBrace.EditLine < PT.EditLine) or
              ((POuterRightBrace.EditLine = PT.EditLine) and (POuterRightBrace.EditCol < PT.EditCol))) then
            begin
              if (PStEnd = nil) and (PT.TokenID = tkSemiColon) then  // 包括分号
              begin
                PStEnd := PT;
              end
              else if (PStEnd = nil) and (PT.TokenID in [tkEnd, tkElse, tkThen, tkDo, tkVar, tkConst]) then // 无分号，不包括 else/end 及其他复合语句结尾
              begin
                PStEnd := PT;
                StEndIdx := I - 1;  // 前一个才是真正的语句结尾
              end;
            end;
          end;

          if (FEditPos.Line > PT.EditLine) or // Token 结尾位置前于光标的，往前找
            ((FEditPos.Line = PT.EditLine) and (FEditPos.Col > PT.EditEndCol)) then
          begin
            // 要在已经找到过的最外层左括号之前的才符合条件
            if (POuterLeftBrace = nil) or ((POuterLeftBrace.EditLine > PT.EditLine) or
              ((POuterLeftBrace.EditLine = PT.EditLine) and (POuterLeftBrace.EditCol > PT.EditCol))) then
            begin
              if PT.TokenID in csKeyTokens + [tkSemiColon, tkVar, tkConst] then
              begin
                PStStart := PT;
                StStartIdx := I + 1; // 后一个才是真正的语句开头
              end;
            end;
          end;

          if (PStStart <> nil) and (PStEnd <> nil) then // 前后都找到了，结束
            Break;
        end;

        if (StStartIdx >= 0) and (StStartIdx < PasParser.Count) then // 修正边界
        begin
          PStStart := PasParser.Tokens[StStartIdx];
          ConvertGeneralTokenPos(Pointer(EditView), PStStart);
        end;
        if (StEndIdx >= 0) and (StEndIdx < PasParser.Count) then     // 修正边界
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
          // 找到语句首尾了且都是包括的闭，且不要和当前光标标识符重复
          if (FCurrTokenStr = '') or (PStStart <> PStEnd) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(PStStart, PStEnd, False);
              Exit;
            end;
          end;

          // 从 PStStart 往前找头尾都在前面的紧邻的 Pair 是否 if/then 这种，是则选择这 Pair 头和 PStEnd
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
                Break; // 找到匹配了，如果不跳，则跳出循环
              end;
            end;

            if TmpPair.EndToken.LineNumber > FEditPos.Line then // 超过光标后了，提前跳出
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

      // ****** 找最内的层次区间 ******
      // InnerPair 内或所有的括号处理完毕，语句也处理完毕，如果没中，则从 InnerPair 的光标所在开区间到光标所在闭区间，
      // 如果 InnerPair 是多结构语句则下一个是整个闭区间
      if InnerPair <> nil then
      begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('To Search Current Pascal Inner Pair %d %d to %d %d with Level %d',
//        [InnerPair.StartToken.EditLine, InnerPair.StartToken.EditCol,
//        InnerPair.EndToken.EditLine, InnerPair.StartToken.EditCol, InnerPair.Layer]);
{$ENDIF}
        SearchInAPair(InnerPair, GetPascalPairEndNextOne(InnerPair));

        // class/record/interface 的 Pair，往前扩大范围找 = 及标识符，大概每次调 SearchInAPair 都要做一次，代码略有重复
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
              ConvertGeneralTokenPos(Pointer(EditView), PT); // 该标识符位置可能没整好
              // 从标识符到 end
              Inc(Step);
              if Step = FSelectStep then
              begin
                SetStartEndPos(PT, InnerPair.EndToken, False);
                Exit;
              end;

              // 如果声明是 end 结尾且尾巴上有分号，再来一个闭
              if InnerPair.EndToken.TokenID = tkEnd then
              begin
                PT1 := GetPascalPairEndNextOne(InnerPair);
                if (PT1 <> nil) and (PT1.TokenID = tkSemiColon) then
                begin
                  Inc(Step);
                  if Step = FSelectStep then
                  begin
                    // 函数过程后如果有分号，再来一个闭
                    SetStartEndPos(PT, PT1, False);
                    Exit;
                  end;
                end;
              end;
            end;
          end;
        end;

        // ****** 找外层的层次区间 ******
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
              // 每退一层 Pair，找开区间，Step + 1，判断，再找闭区间，Step + 1，判断
              // 再判断该 Pair 是否有同级的 procedure/function，有则闭区间 Step + 1，判断
              // 再进外一层重复上述循环。注意起始条件会包括已经搜过的 InnerPair

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
                // 不搜已经搜过的 InnerPair
                CursorInPair := True;
                if Pair.Layer = PairLevel then
                begin
{$IFDEF DEBUG}
//                CnDebugger.LogFmt('Level Match In Pascal Pair %d %d to %d %d. To Search in this Pair with Level %d',
//                  [Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine, Pair.EndToken.EditCol, Pair.Layer]);
{$ENDIF}
                  SearchInAPair(Pair, GetPascalPairEndNextOne(Pair));

                  // class/record/interface 的 Pair，往前扩大范围找 = 及标识符，大概每次调 SearchInAPair 都要做一次，代码略有重复
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
                        ConvertGeneralTokenPos(Pointer(EditView), PT); // 该标识符位置可能没整好
                        // 从标识符到 end
                        Inc(Step);
                        if Step = FSelectStep then
                        begin
                          SetStartEndPos(PT, Pair.EndToken, False);
                          Exit;
                        end;

                        // 如果声明是 end 结尾且尾巴上有分号，再来一个闭
                        if Pair.EndToken.TokenID = tkEnd then
                        begin
                          PT1 := GetPascalPairEndNextOne(Pair);
                          if (PT1 <> nil) and (PT1.TokenID = tkSemiColon) then
                          begin
                            Inc(Step);
                            if Step = FSelectStep then
                            begin
                              // 函数过程后如果有分号，再来一个闭
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
              if Pair = InnerPair then // 已经搜过的 InnerPair，光标必然在此 Pair 内
                CursorInPair := True;

              // 无论是不是搜过的 InnerPair，只要它是符合级别的 begin/end，且包含光标位置，就要搜其前面同级的 if 等
              if not AreaFound and CursorInPair and (Pair.Layer = PairLevel) and (Pair.MiddleCount = 0) and
                (Pair.StartToken.TokenID in [tkBegin, tkAsm]) and (Pair.EndToken.TokenID = tkEnd) then
              begin
{$IFDEF DEBUG}
                CnDebugger.LogMsg('Not Found in This Pair. Check other Pairs with Same Level ' + IntToStr(Pair.Layer));
{$ENDIF}
                // 找前面有无和 Pair 这对 begin end 同级的 if/then、while/do、procedure/function，中间不能再碰见同级的 begin end
                for J := I - 1 downto 0 do
                begin
                  TmpPair := BlockMatchInfo.LineInfo.Pairs[J];
                  if TmpPair.Layer = Pair.Layer then
                  begin
                    // 如有同级的 begin end 表示后面即使有 if 什么的也不是在一块的
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
                      Break; // 已经找到了同级 if 等语句，不用再找 function/procedure 了
                    end;

                    // 继续找同级上面相邻的 function/procedure
                    if (TmpPair.StartToken.TokenID in csProcTokens)
                      and (TmpPair.EndToken.TokenID in csProcTokens) then
                    begin
                      Inc(Step);
                      if Step = FSelectStep then
                      begin
                        // 函数过程就闭区间，没有开区间
                        SetStartEndPos(TmpPair.StartToken, Pair.EndToken, False);
                        Exit;
                      end;

                      PT := GetPascalPairEndNextOne(Pair);
                      if (PT <> nil) and (PT.TokenID = tkSemiColon) then
                      begin
                        Inc(Step);
                        if Step = FSelectStep then
                        begin
                          // 函数过程后如果有分号，再来一个闭
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
                (Pair.MiddleCount = 0) and (I < BlockMatchInfo.LineInfo.Count - 1) and (  // 后面得还有 Pair
                ((Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen)) or
                ((Pair.StartToken.TokenID = tkFor) and (Pair.EndToken.TokenID = tkDo)) or
                ((Pair.StartToken.TokenID = tkWith) and (Pair.EndToken.TokenID = tkDo)) or
                ((Pair.StartToken.TokenID = tkWhile) and (Pair.EndToken.TokenID = tkDo)) ) then
              begin
                // 只要它是符合级别的 if then/for do/with do/while do，且包含光标位置，
                // 就要往后搜其后面紧跟的连续的同级 begin end 或其他 if then/for do/with do/while do
                // 注意这个同级其实是解析器得出的表示连续的不确切结论，这里只能用上了
                TmpPair := Pair;
                for J := I + 1 to BlockMatchInfo.LineInfo.Count - 1 do
                begin
                  // 如果 BlockMatchInfo.LineInfo.Pairs[J] 和 TmpPair 中间有其他内容，说明不是一个逻辑，需要跳走
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

                    // begin end 块后有分号再加一层
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
            Dec(PairLevel); // 是否在本层？
          end;
        end;
      end;
    end
    else if CurIsCpp then
    begin
      // 扩大小括号、中括号选区，看是否在 InnerPair 内，在则递增 Step 并和 FLevel 比较判断
      // 把 InnerPair 内的 Token 都找出来，如无 InnerPair 则全找出来，准备匹配小括号和中括号
      LeftBrace := nil;
      RightBrace := nil;

      try
        LeftBrace := TList.Create;
        RightBrace := TList.Create;
        COuterLeftBrace := nil;
        COuterRightBrace := nil;
        InnerStartGot := InnerPair = nil; // 有 InnerPair 则从它开始，否则搜全局

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

              // Token 开头位置小于光标，也就是光标位置大于 Token 开头的左右括号，逆向加到左边
              if ((FEditPos.Line > CT.EditLine) or
                ((FEditPos.Line = CT.EditLine) and (FEditPos.Col > CT.EditCol))) then
                LeftBrace.Insert(0, CT);

              // Token 结尾位置小于光标，也就是光标位置小于 Token 尾巴的左右括号，加到右边
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
        // 拿到光标前后的左右括号，下标低的离光标近，先干掉抵消的中括号和小括号部分
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

        for I := 0 to C - 1 do // 如果 C 为 0 则进不来
        begin
          // 第一轮里，如果光标下最初有标识符、且最开始一对左右括号同行、且距离等于标识符长度，则这次不走开区间，避免重复选择
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
            if Step = FSelectStep then // 仅走闭区间
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

      // InnerPair 内或所有的括号处理完毕，如果没中，再从 Tokens 中找前后语句结束符，
      // 后结束符是分号，前则是分号或 { 等
      CStStart := nil;
      CStEnd := nil;
      StStartIdx := -1;
      StEndIdx := -1;

      for I := 0 to CppParser.Count - 1 do
      begin
        CT := CppParser.Tokens[I];
        if CT.CppTokenKind in [ctksemicolon, ctkbraceopen, ctkelse] then // 只挑出符合条件的来转换并比较位置
          ConvertGeneralTokenPos(Pointer(EditView), CT);

        if ((FEditPos.Line < CT.EditLine) or // Token 开头位置后于光标的，往后找
          ((FEditPos.Line = CT.EditLine) and (FEditPos.Col <= CT.EditCol))) then
        begin
          // 要在已经找到过的最外层右括号之后才符合条件
          if (COuterRightBrace = nil) or ((COuterRightBrace.EditLine < CT.EditLine) or
            ((COuterRightBrace.EditLine = CT.EditLine) and (COuterRightBrace.EditCol < CT.EditCol))) then
          begin
            if (CStEnd = nil) and (CT.CppTokenKind = ctksemicolon) then  // 包括分号
              CStEnd := CT;
          end;
        end;

        if ((FEditPos.Line > CT.EditLine) or // Token 结尾位置前于光标的，往前找
          ((FEditPos.Line = CT.EditLine) and (FEditPos.Col > CT.EditEndCol))) then
        begin
          // 要在已经找到过的最外层左括号之前的才符合条件
          if (COuterLeftBrace = nil) or ((COuterLeftBrace.EditLine > CT.EditLine) or
            ((COuterLeftBrace.EditLine = CT.EditLine) and (COuterLeftBrace.EditCol > CT.EditCol))) then
          begin
            if CT.CppTokenKind in [ctksemicolon, ctkbraceopen, ctkelse] then
            begin
              CStStart := CT;
              StStartIdx := I + 1; // 后一个才是真正的语句开头
            end;
          end;
        end;

        if (CStStart <> nil) and (CStEnd <> nil) then // 前后都找到了，结束
          Break;
      end;

      if (StStartIdx >= 0) and (StStartIdx < CppParser.Count) then // 修正边界
      begin
        CStStart := CppParser.Tokens[StStartIdx];
        ConvertGeneralTokenPos(Pointer(EditView), CStStart);
      end;
      if (StEndIdx >= 0) and (StEndIdx < PasParser.Count) then     // 修正边界
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
        // 找到语句首尾了且都是包括的闭，且不要和当前光标标识符重复
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

      // 小括号和中括号处理完毕
      if InnerPair <> nil then
      begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('To Search Current C/C++ Inner Pair %d %d to %d %d with Level %d',
//        [InnerPair.StartToken.EditLine, InnerPair.StartToken.EditCol,
//        InnerPair.EndToken.EditLine, InnerPair.StartToken.EditCol, InnerPair.Layer]);
{$ENDIF}
        SearchInAPair(InnerPair); // 大括号后无需分号

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
              // 每退一层 Pair，找开区间，Step + 1，判断，再找闭区间，Step + 1，判断
              // 再进外一层重复上述循环。注意起始条件会包括已经搜过的 InnerPair

              Pair := BlockMatchInfo.LineInfo.Pairs[I];
{$IFDEF DEBUG}
//            CnDebugger.LogFmt('To Check C/C++ Pair with Level %d. Is %d %d in From %d %d %s to %d %d %s',
//              [Pair.Layer, FEditPos.Line, FEditPos.Col,
//              Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.StartToken.Token,
//              Pair.EndToken.EditLine, Pair.EndToken.EditEndCol, Pair.EndToken.Token]);
{$ENDIF}
              if (Pair <> InnerPair) and EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
              begin
                // 不搜已经搜过的 InnerPair
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
            Dec(PairLevel); // 是否在本层？
          end;
        end;
      end;
    end;

    if not AreaFound then
    begin
      // 没有所在的层，或啥都没找到，直接全选整个文件
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
    BlockMatchInfo.Free; // LineInfo 设 nil 后这里的 Clear 才能进行
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

  // 理想情况：
  // 如果没有选择区，则选当前标识符并设 Level 1，无标识符的话解析并选最内层开区间，并设 Level 2
  // 如果有选择区，则解析，并根据当前 Level 层数加 1 选择
  // 层级计数顺序：无选择区 0，光标下标识符 1（不一定有），当前块块内开区间 2，
  // 当前块闭区间（也就是整个块，后面有分号就加个分号）3
  // 和当前块同级的所有块（如果还有其他块的话）4，次外块内开区间 5，以此类推

  FSelecting := True;
  try
    if (EditView.Block = nil) or not EditView.Block.IsValid then
    begin
      // 记录下最初的标识符
      if CnOtaGeneralGetCurrPosToken(FCurrTokenStr, CurrIndex) then
      begin
        if FCurrTokenStr <> '' then
        begin
          // 光标下有标识符，选中
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

    // 选择 FLevel 对应的区
    if (FStartPos.Line >= 0) and (FEndPos.Line >= 0) then
    begin
      CnOtaMoveAndSelectBlock(FStartPos, FEndPos);
{$IFDEF WIN64}
      EditView.Paint;
{$ENDIF}
    end;
  finally
    FTimer.Enabled := False;
    FTimer.Enabled := True; // 半秒钟后重置 FSelecting
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
