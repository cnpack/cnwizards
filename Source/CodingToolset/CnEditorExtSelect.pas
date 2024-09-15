{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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
* 修改记录：2021.10.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, Menus, ToolsAPI,
  CnWizUtils, CnConsts, CnCommon, CnWizManager, CnWizEditFiler,
  CnCodingToolsetWizard, CnWizConsts, CnEditorCodeTool, CnWizIdeUtils,
  CnSourceHighlight, CnPasCodeParser, CnEditControlWrapper, mPasLex,
  CnCppCodeParser, mwBCBTokenList;

type
  TCnEditorExtendingSelect = class(TCnBaseCodingToolset)
  private
    FLevel: Integer;
    FTimer: TTimer;
    FNeedReparse: Boolean;
    FWholeLines: Boolean;
    FSelecting: Boolean;
    FStartPos, FEndPos: TOTACharPos;
    procedure CheckModifiedAndReparse;
    procedure EditorChanged(Editor: TEditorObject; ChangeType:
      TEditorChangeTypes);
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

    property WholeLines: Boolean read FWholeLines write FWholeLines;
    {* 块选择时是否是整行模式}
  end;

implementation

uses
  CnDebug;

{ TCnEditorExtendingSelect }

procedure TCnEditorExtendingSelect.CheckModifiedAndReparse;
const
  NO_LAYER = -2;
var
  EditView: IOTAEditView;
  EditControl: TControl;
  CurrIndex, I: Integer;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  Stream: TMemoryStream;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  CurrentToken: TCnGeneralPasToken;
  CurrentTokenName: TCnIdeTokenString;
  CurIsPas, CurIsCpp: Boolean;
  CurrentTokenIndex: Integer;
  BlockMatchInfo: TCnBlockMatchInfo;
  MaxInnerLayer, MinOutLayer: Integer;
  Pair: TCnBlockLinePair;
  LastS: string;

  // 判断一个 Pair 是否包括了光标位置
  function EditPosInPair(AEditPos: TOTAEditPos; APair: TCnBlockLinePair): Boolean;
  var
    AfterStart, BeforeEnd: Boolean;
  begin
    AfterStart := (AEditPos.Line > APair.StartToken.EditLine) or
      ((AEditPos.Line = APair.StartToken.EditLine) and (AEditPos.Col >= APair.StartToken.EditCol));
    BeforeEnd := (AEditPos.Line < APair.EndToken.EditLine) or
      ((AEditPos.Line = APair.EndToken.EditLine) and
      (AEditPos.Col <= APair.EndToken.EditEndCol));

    Result := AfterStart and BeforeEnd;
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
          or IsInc(EditView.Buffer.FileName), False);
      if CurIsCpp then
        CnCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line, EditView.CursorPos.Col);
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

    // 把有用的 Token 加入 BlockMatchInfo 中
    for I := 0 to PasParser.Count - 1 do
      if PasParser.Tokens[I].TokenID in csKeyTokens + [tkSemiColon] then
        BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);

    // 转换一下
    for I := 0 to BlockMatchInfo.KeyCount - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.KeyTokens[I]);

    // 检查配对
    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView, False, False);

    // BlockMatchInfo 的输出是 LineInfo 内的内容

    FStartPos.Line := -1;
    FEndPos.Line := -1;
    MaxInnerLayer := NO_LAYER; // -2 不存在
    MinOutLayer := MaxInt;
    EditPos := EditView.CursorPos;

    // 得到光标所在 Pair 的最深层
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      // 先找跨光标位置的最内层也就是 Layer 最高的 Pair
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      if EditPosInPair(EditPos, Pair) then
      begin
        if Pair.Layer > MaxInnerLayer then
          MaxInnerLayer := Pair.Layer;
        if Pair.Layer < MinOutLayer then
          MinOutLayer := Pair.Layer;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CheckModifiedAndReparse Get Layer from %d to %d.', [MinOutLayer, MaxInnerLayer]);
{$ENDIF}

    if (MaxInnerLayer = NO_LAYER) or (MinOutLayer = MaxInt) then
      Exit;

    // Layer 从 MinOutLayer（可能 -1 或 0） 到 MaxInnerLayer ，FLevel 从 1 往外，FLevel 和 Layer 有个线性对应关系
    // FLevel 1 <=> MaxInnerLayer，FLevel 2 <=> MaxInnerLayer - 1，... MaxLevel <=> MinOutLayer
    // 所以 FLevel + Layer = 1 + MaxInnerLayer 并且 MaxLevel := MaxInnerLayer + 1 - MinOutLayer
    if FLevel > MaxInnerLayer + 1 - MinOutLayer then
    begin
      // 全选整个文件
      FStartPos.Line := 1;
      FStartPos.CharIndex := 0;
      FEndPos.Line := EditView.Buffer.GetLinesInBuffer;
      LastS := CnOtaGetLineText(FEndPos.Line, EditView.Buffer);
      FEndPos.CharIndex := Length(LastS);
      Exit;
    end;

    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      // 先找跨光标位置的最内层也就是 Layer 最高的 Pair
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      if Pair.Layer = MaxInnerLayer + 1 - FLevel then
      begin
        if EditPosInPair(EditPos, Pair) then
        begin
          FStartPos.Line := Pair.StartToken.EditLine;
          FStartPos.CharIndex := Pair.StartToken.EditCol;
          FEndPos.Line := Pair.EndToken.EditLine;
          FEndPos.CharIndex := Pair.EndToken.EditEndCol;
        end;
      end;
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

procedure TCnEditorExtendingSelect.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
begin
  if ChangeType * [ctView, ctModified, ctTopEditorChanged, ctOptionChanged] <> [] then
    FNeedReparse := True;
  if not FSelecting and (ChangeType * [ctBlock] <> []) then
    FLevel := 0;
end;

procedure TCnEditorExtendingSelect.Execute;
var
  CurrIndex: Integer;
  EditView: IOTAEditView;
  CurrTokenStr: TCnIdeTokenString;
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
      if CnOtaGeneralGetCurrPosToken(CurrTokenStr, CurrIndex) then
      begin
        if CurrTokenStr <> '' then
        begin
          // 光标下有标识符，选中
          CnOtaSelectCurrentToken;
          Exit;
        end;
      end;
    end;

    Inc(FLevel);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('EditorExtendingSelect To Select Level %d.', [FLevel]);
{$ENDIF}

    CheckModifiedAndReparse;

    // 选择 FLevel 对应的区
    if (FStartPos.Line >= 0) and (FEndPos.Line >= 0) then
      CnOtaMoveAndSelectBlock(FStartPos, FEndPos);
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

procedure TCnEditorExtendingSelect.OnSelectTimer(Sender: TObject);
begin
  FSelecting := False;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtendingSelect);

end.
