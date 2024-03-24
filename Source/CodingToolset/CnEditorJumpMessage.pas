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

unit CnEditorJumpMessage;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：跳至上下一信息行与跳至 intf/impl 与跳至匹配关键字实现单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：跳转的 Index 使用 MessageCount - 2 是由于最后一条消息强制为空，无效。
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2014.12.25
*               加入跳至匹配的条件编译指令的功能
*           2012.02.25
*               加入跳至前一个/后一个相同标识符的功能
*           2009.04.15
*               加入对 C/C++ 大括号的支持
*           2008.11.22
*               加入跳至匹配关键字的功能
*           2008.11.14
*               加入跳至 intf/impl 的功能
*           2007.01.23 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, Menus, ToolsAPI, CnWizUtils, CnConsts, CnCommon, CnWizManager,
  CnWizEditFiler, CnCodingToolsetWizard, CnWizConsts, CnEditorCodeTool, CnWizIdeUtils,
  CnSourceHighlight, CnPasCodeParser, CnEditControlWrapper, mPasLex,
  CnCppCodeParser, mwBCBTokenList, CnFastList {$IFDEF BDS}, CnWizMethodHook {$ENDIF};

type

//==============================================================================
// 跳至上/下一信息行工具类
//==============================================================================

{ TCnEditorPrevMessage }

  TCnEditorPrevMessage = class(TCnBaseCodingToolset)
  private

  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

{ TCnEditorNextMessage }

  TCnEditorNextMessage = class(TCnBaseCodingToolset)
  private

  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

  TCnEditorJumpIntf = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpImpl = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

// 此仨功能依赖于高亮解析因此此处需要也这样 IFDEF

  TCnEditorJumpMatchedKeyword = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpPrevIdent = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpNextIdent = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$IFDEF IDE_HAS_INSIGHT}

  TCnEditorJumpIDEInsight = class(TCnBaseCodingToolset)
  private

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$IFDEF BDS}
function EmptyKeyDataToShiftState(KeyData: Longint): TShiftState;
begin
  Result := [];
end;
{$ENDIF}

{ TCnEditorJumpMessage }

constructor TCnEditorNextMessage.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorNextMessage.Destroy;
begin

  inherited;
end;

function TCnEditorNextMessage.GetCaption: string;
begin
  Result := SCnEditorNextMessageMenuCaption;
end;

function TCnEditorNextMessage.GetHint: string;
begin
  Result := SCnEditorNextMessageMenuHint;
end;

function TCnEditorNextMessage.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+.');
end;

procedure TCnEditorNextMessage.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorNextMessageName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

procedure TCnEditorNextMessage.Execute;
{$IFDEF BDS}
var
  Hook: TCnMethodHook;
{$ENDIF}
begin
  if CnMessageViewWrapper.MessageViewForm = nil then Exit;
  if not CnMessageViewWrapper.MessageViewForm.Visible then
    CnMessageViewWrapper.MessageViewForm.Show;
{$IFDEF BDS}
  Hook := TCnMethodHook.Create(GetBplMethodAddress(@KeyDataToShiftState), @EmptyKeyDataToShiftState);
  CnMessageViewWrapper.TreeView.Perform(WM_KEYDOWN, VK_DOWN, Integer($1500001));
  CnMessageViewWrapper.TreeView.Perform(WM_KEYUP, VK_DOWN, Integer($C1500001));
  Hook.Free;
{$ELSE}
  if CnMessageViewWrapper.SelectedIndex < CnMessageViewWrapper.MessageCount - 2 then
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex + 1
  else
    CnMessageViewWrapper.SelectedIndex := 0; // 重新跳到第一项
{$ENDIF}
  CnMessageViewWrapper.EditMessageSource;
end;

{ TCnEditorPrevMessage }

constructor TCnEditorPrevMessage.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorPrevMessage.Destroy;
begin

  inherited;
end;

procedure TCnEditorPrevMessage.Execute;
{$IFDEF BDS}
var
  Hook: TCnMethodHook;
{$ENDIF}
begin
  if CnMessageViewWrapper.MessageViewForm = nil then Exit;
  if not CnMessageViewWrapper.MessageViewForm.Visible then
    CnMessageViewWrapper.MessageViewForm.Show;
{$IFDEF BDS}
  Hook := TCnMethodHook.Create(GetBplMethodAddress(@KeyDataToShiftState), @EmptyKeyDataToShiftState);
  CnMessageViewWrapper.TreeView.Perform(WM_KEYDOWN, VK_UP, Integer($1500001));
  CnMessageViewWrapper.TreeView.Perform(WM_KEYUP, VK_UP, Integer($C1500001));
  Hook.Free;  
{$ELSE}
  if CnMessageViewWrapper.SelectedIndex > 0 then
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex - 1
  else
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.MessageCount - 2 ; // 重新跳到末一项
{$ENDIF}
  CnMessageViewWrapper.EditMessageSource;
end;

function TCnEditorPrevMessage.GetCaption: string;
begin
  Result := SCnEditorPrevMessageMenuCaption;
end;

function TCnEditorPrevMessage.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+,');
end;

procedure TCnEditorPrevMessage.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorPrevMessageName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorPrevMessage.GetHint: string;
begin
  Result := SCnEditorPrevMessageMenuHint;
end;

// 解析 Pascal 代码并跳至第一个 Token 所在的行。由于只处理行，因此无需 Unicode 处理
procedure ParsePasAndGotoLine(TokenKind: TTokenKind; const ErrorMsg: string);
var
  LineNum: Integer;
  View: IOTAEditView;
  Parser: TmwPasLex;
  MemStream: TMemoryStream;
  S: string;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  LineNum := 0;
  S := CnOtaGetCurrentSourceFileName;
  if not (IsDelphiSourceModule(S) or IsInc(S)) then
    Exit;

  Parser := nil;
  MemStream := TMemoryStream.Create;
  try
    with TCnEditFiler.Create(S) do
    try
      SaveToStream(MemStream, True);
    finally
      Free;
    end;

    Parser := TmwPasLex.Create;
    Parser.Origin := MemStream.Memory;
    
    while Parser.TokenID <> tkNull do
    begin
      if Parser.TokenID = TokenKind then
      begin
        if (TokenKind <> tkInterface) or not Parser.IsInterface then
        begin
          if LineNum = 0 then
          begin
            LineNum := Parser.LineNumber + 1;
            Break;
          end;
        end;
      end;
      Parser.NextNoJunk;
    end;

    if LineNum > 0 then
      CnOtaGotoEditPosAndRepaint(View, LineNum)
    else
      ErrorDlg(ErrorMsg);
  finally
    MemStream.Free;
    Parser.Free;
  end;
end;

{ TCnEditorJumpIntf }

function TCnEditorJumpIntf.GetCaption: string;
begin
  Result := SCnEditorJumpIntfMenuCaption;
end;

function TCnEditorJumpIntf.GetHint: string;
begin
  Result := SCnEditorJumpIntfMenuHint;
end;

procedure TCnEditorJumpIntf.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpIntfName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpIntf.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpIntf.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpIntf.Execute;
begin
  ParsePasAndGotoLine(tkInterface, SCnProcListErrorNoIntf);
end;

function TCnEditorJumpIntf.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsPas(S) or IsInc(S)) then
    Result := [];
end;

function TCnEditorJumpIntf.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorJumpIntf.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpIntf.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{ TCnEditorJumpImpl }

function TCnEditorJumpImpl.GetCaption: string;
begin
  Result := SCnEditorJumpImplMenuCaption;
end;

function TCnEditorJumpImpl.GetHint: string;
begin
  Result := SCnEditorJumpImplMenuHint;
end;

procedure TCnEditorJumpImpl.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpImplName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpImpl.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpImpl.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpImpl.Execute;
begin
  ParsePasAndGotoLine(tkImplementation, SCnProcListErrorNoImpl);
end;

function TCnEditorJumpImpl.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsPas(S) or IsInc(S)) then
    Result := [];
end;

function TCnEditorJumpImpl.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorJumpImpl.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpImpl.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

// 此功能依赖于高亮解析因此此处需要也这样 IFDEF

{ TCnEditorJumpMatchedKeyword }

function TCnEditorJumpMatchedKeyword.GetCaption: string;
begin
  Result := SCnEditorJumpMatchedKeywordMenuCaption;
end;

function TCnEditorJumpMatchedKeyword.GetHint: string;
begin
  Result := SCnEditorJumpMatchedKeywordMenuHint;
end;

procedure TCnEditorJumpMatchedKeyword.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpMatchedKeywordName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpMatchedKeyword.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpMatchedKeyword.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpMatchedKeyword.Execute;
var
  BlockMatchInfo: TCnBlockMatchInfo;
  LineInfo: TCnBlockLineInfo;
  CompDirectiveInfo: TCnCompDirectiveInfo;
  EditControl: TControl;
  EditView: IOTAEditView;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  I: Integer;
  DestToken: TCnGeneralPasToken;
  TokenIndex: Integer;
  CurIsPas, CurIsCpp: Boolean;
  HighlightWizard: TCnSourceHighlight;
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

  HighlightWizard := TCnSourceHighlight(CnWizardMgr.WizardByClass(TCnSourceHighlight));
  if HighlightWizard = nil then
    Exit;

  CurIsPas := IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName);
  CurIsCpp := IsCppSourceModule(EditView.Buffer.FileName);
  if (not CurIsCpp) and (not CurIsPas) then
    Exit;

  PasParser := nil;
  CppParser := nil;

  if CurIsPas then
  begin
    PasParser := TCnGeneralPasStructParser.Create;
    {$IFDEF BDS}
    PasParser.UseTabKey := True; // HighlightWizard.UseTabKey;
    PasParser.TabWidth := HighlightWizard.TabWidth;
    {$ENDIF}
  end;
  if CurIsCpp then
  begin
    CppParser := TCnGeneralCppStructParser.Create;
    {$IFDEF BDS}
    CppParser.UseTabKey := True; // HighlightWizard.UseTabKey;
    CppParser.TabWidth := HighlightWizard.TabWidth;
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

  try
    BlockMatchInfo := TCnBlockMatchInfo.Create(EditControl);
    LineInfo := TCnBlockLineInfo.Create(EditControl);
    CompDirectiveInfo := TCnCompDirectiveInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := LineInfo;
    BlockMatchInfo.CompDirectiveInfo := CompDirectiveInfo;

    if CurIsPas then
    begin
      if Assigned(PasParser.InnerBlockStartToken) and Assigned(PasParser.InnerBlockCloseToken) then
      begin
        for I := PasParser.InnerBlockStartToken.ItemIndex to
          PasParser.InnerBlockCloseToken.ItemIndex do
          if PasParser.Tokens[I].TokenID in csKeyTokens then
            BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);
      end;

      for I := 0 to PasParser.Count - 1 do
        if CheckIsCompDirectiveToken(PasParser.Tokens[I], False) then
          BlockMatchInfo.AddToCompDirectiveList(PasParser.Tokens[I]);
    end;

    if CurIsCpp then
    begin
      if Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        for I := CppParser.InnerBlockStartToken.ItemIndex to
          CppParser.InnerBlockCloseToken.ItemIndex do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end
      else if Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
      begin
        for I := CppParser.BlockStartToken.ItemIndex to
          CppParser.BlockCloseToken.ItemIndex do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end
      else
      begin
        for I := 0 to CppParser.Count - 1 do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end;

      for I := 0 to CppParser.Count - 1 do
        if CheckIsCompDirectiveToken(CppParser.Tokens[I], True) then
          BlockMatchInfo.AddToCompDirectiveList(CppParser.Tokens[I]);
    end;

    if BlockMatchInfo.KeyCount > 0 then
    begin
      for I := 0 to BlockMatchInfo.KeyCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.KeyTokens[I]);

      BlockMatchInfo.ConvertLineList;
    end;

    if BlockMatchInfo.CompDirectiveTokenCount > 0 then
    begin
      for I := 0 to BlockMatchInfo.CompDirectiveTokenCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.CompDirectiveTokens[I]);

      BlockMatchInfo.ConvertCompDirectiveLineList;
    end;

    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView, False, False);
    BlockMatchInfo.CheckCompDirectiveMatch(EditView);

    // 解析完毕，准备定位
    DestToken := nil;
    if LineInfo.CurrentPair <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Jump Matching. Current Token %d:%d - %s.', [LineInfo.CurrentToken.EditLine,
        LineInfo.CurrentToken.EditCol, LineInfo.CurrentToken.Token]);
{$ENDIF}

      if LineInfo.CurrentToken = LineInfo.CurrentPair.StartToken then
      begin
        if LineInfo.CurrentPair.MiddleCount > 0 then
          DestToken := LineInfo.CurrentPair.MiddleToken[0]
        else
          DestToken := LineInfo.CurrentPair.EndToken
      end
      else if LineInfo.CurrentToken = LineInfo.CurrentPair.EndToken then
        DestToken := LineInfo.CurrentPair.StartToken
      else
      begin
        if LineInfo.CurrentPair.MiddleCount > 0 then
        begin
          TokenIndex := LineInfo.CurrentPair.IndexOfMiddleToken(LineInfo.CurrentToken);
          if TokenIndex = LineInfo.CurrentPair.MiddleCount - 1 then // 最后一个
            DestToken := LineInfo.CurrentPair.EndToken
          else
            DestToken := LineInfo.CurrentPair.MiddleToken[TokenIndex + 1];
        end;
      end;
    end
    else if CompDirectiveInfo.CurrentPair <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Jump Matching. Current CompDirective Token %d:%d - %s.', [CompDirectiveInfo.CurrentToken.EditLine,
        CompDirectiveInfo.CurrentToken.EditCol, CompDirectiveInfo.CurrentToken.Token]);
{$ENDIF}

      if CompDirectiveInfo.CurrentToken = CompDirectiveInfo.CurrentPair.StartToken then
      begin
        if CompDirectiveInfo.CurrentPair.MiddleCount > 0 then
          DestToken := CompDirectiveInfo.CurrentPair.MiddleToken[0]
        else
          DestToken := CompDirectiveInfo.CurrentPair.EndToken
      end
      else if CompDirectiveInfo.CurrentToken = CompDirectiveInfo.CurrentPair.EndToken then
        DestToken := CompDirectiveInfo.CurrentPair.StartToken
      else
      begin
        if CompDirectiveInfo.CurrentPair.MiddleCount > 0 then
        begin
          TokenIndex := CompDirectiveInfo.CurrentPair.IndexOfMiddleToken(CompDirectiveInfo.CurrentToken);
          if TokenIndex = CompDirectiveInfo.CurrentPair.MiddleCount - 1 then // 最后一个
            DestToken := CompDirectiveInfo.CurrentPair.EndToken
          else
            DestToken := CompDirectiveInfo.CurrentPair.MiddleToken[TokenIndex + 1];
        end;
      end;
    end;

    if DestToken <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Jump Matching. Destination Token %d:%d - %s.', [DestToken.EditLine,
        DestToken.EditCol, DestToken.Token]);
{$ENDIF}

      CnOtaGotoEditPosAndRepaint(EditView, DestToken.EditLine, DestToken.EditCol);
    end;
  finally
    FreeAndNil(BlockMatchInfo);
    FreeAndNil(LineInfo);
    FreeAndNil(CompDirectiveInfo);
    FreeAndNil(CppParser);
    FreeAndNil(PasParser);
  end;
end;

function TCnEditorJumpMatchedKeyword.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

function TCnEditorJumpMatchedKeyword.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Ctrl+,');
end;

procedure TCnEditorJumpMatchedKeyword.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpMatchedKeyword.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure JumpIdentifierNearby(Prev: Boolean);
var
  EditControl: TControl;
  EditView: IOTAEditView;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  Stream: TMemoryStream;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  I: Integer;
  CurrentToken: TCnGeneralPasToken;
  CurrentTokenName: TCnIdeTokenString;
  CurIsPas, CurIsCpp: Boolean;
  CurrentTokenIndex, StartIdx, EndIdx: Integer;

  procedure SetParseRange(MaxCount: Integer);
  begin
    if Prev then
    begin
      StartIdx := CurrentTokenIndex - 1;
      EndIdx := 0;
    end
    else
    begin
      StartIdx := CurrentTokenIndex + 1;
      EndIdx := MaxCount;
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

  PasParser := nil;
  CppParser := nil;

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

  CurrentToken := nil;
  Stream := TMemoryStream.Create;
  try
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

    // 解析当前显示的源文件
    if CurIsPas then
    begin
      CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
        or IsInc(EditView.Buffer.FileName), False);

      for I := 0 to PasParser.Count - 1 do
      begin
        // 将解析器解析出来的字符偏移转换成 CharPos
        CnConvertPasTokenPositionToCharPos(Pointer(EditView), PasParser.Tokens[I], CharPos);
        // 再把 CharPos 转换成 EditPos
        CnOtaConvertEditViewCharPosToEditPos(Pointer(EditView),
          CharPos.Line, CharPos.CharIndex, EditPos);

        PasParser.Tokens[I].EditCol := EditPos.Col;
        PasParser.Tokens[I].EditLine := EditPos.Line;

        if (PasParser.Tokens[I].TokenID = tkIdentifier) and // 此处判断不支持双字节字符
          IsGeneralCurrentToken(Pointer(EditView), EditControl, PasParser.Tokens[I]) then
        begin
          if CurrentToken = nil then
          begin
            CurrentToken := PasParser.Tokens[I];
            CurrentTokenName := CurrentToken.Token;
            CurrentTokenIndex := I;
            // Can't Break for Parser Tokens Line/Col need to assigned.
          end;
        end;
      end;

      SetParseRange(PasParser.Count);
      if CurrentTokenName <> '' then
      begin
        if StartIdx > EndIdx then
        begin
          for I := StartIdx downto EndIdx do // Search for previous
          begin
            if (PasParser.Tokens[I].TokenID = tkIdentifier) and
              CheckTokenMatch(PasParser.Tokens[I].Token, PCnIdeTokenChar(CurrentTokenName), False) then
            begin
              // Found. Jump here and Exit;
              CnOtaGotoEditPosAndRepaint(EditView, PasParser.Tokens[I].EditLine, PasParser.Tokens[I].EditCol);
              Exit;
            end;
          end;
        end
        else
        begin
          for I := StartIdx to EndIdx do // Search for Next
          begin
            if (PasParser.Tokens[I].TokenID = tkIdentifier) and
              CheckTokenMatch(PasParser.Tokens[I].Token, PCnIdeTokenChar(CurrentTokenName), False) then
            begin
              // Found. Jump here and Exit;
              CnOtaGotoEditPosAndRepaint(EditView, PasParser.Tokens[I].EditLine, PasParser.Tokens[I].EditCol);
              Exit;
            end;
          end;
        end;
      end;
    end;

    if CurIsCpp then
    begin
      CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
      // 将当前光标位置转换成 Ansi/Utf16/Utf16 供 CppParser 使用
      CnCppParserParseSource(CppParser, Stream, CharPos.Line, CharPos.CharIndex + 1);
      // 转出来的 CharIndex 是 0 开始，但 CppParser 要求 1 开始，所以加一。

      for I := 0 to CppParser.Count - 1 do
      begin
        // 将解析器解析出来的字符偏移转换成 CharPos
        CnConvertPasTokenPositionToCharPos(Pointer(EditView), CppParser.Tokens[I], CharPos);
        // 再把 CharPos 转换成 EditPos
        CnOtaConvertEditViewCharPosToEditPos(Pointer(EditView),
          CharPos.Line, CharPos.CharIndex, EditPos);

        CppParser.Tokens[I].EditCol := EditPos.Col;
        CppParser.Tokens[I].EditLine := EditPos.Line;

        if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
          IsGeneralCurrentToken(Pointer(EditView), EditControl, CppParser.Tokens[I]) then
        begin
          if CurrentToken = nil then
          begin
            CurrentToken := CppParser.Tokens[I];
            CurrentTokenName := CurrentToken.Token;
            CurrentTokenIndex := I;
            // Can't Break for Parser Tokens Line/Col need to assigned.
          end;
        end;
      end;

      SetParseRange(CppParser.Count);
      if CurrentTokenName <> '' then
      begin
        if StartIdx > EndIdx then
        begin
          for I := StartIdx downto EndIdx do // Search for previous
          begin
            if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
              CheckTokenMatch(CppParser.Tokens[I].Token, PCnIdeTokenChar(CurrentTokenName), True) then
            begin
              // Found. Jump here and Exit;
              CnOtaGotoEditPosAndRepaint(EditView, CppParser.Tokens[I].EditLine, CppParser.Tokens[I].EditCol);
              Exit;
            end;
          end;
        end
        else
        begin
          for I := StartIdx to EndIdx do // Search for Next
          begin
            if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
              CheckTokenMatch(CppParser.Tokens[I].Token, PCnIdeTokenChar(CurrentTokenName), True) then
            begin
              // Found. Jump here and Exit;
              CnOtaGotoEditPosAndRepaint(EditView, CppParser.Tokens[I].EditLine, CppParser.Tokens[I].EditCol);
              Exit;
            end;
          end;
        end;
      end;
    end;
  finally
    PasParser.Free;
    CppParser.Free;
    Stream.Free;
  end;
end;

{ TCnEditorJumpPrevIdent }

constructor TCnEditorJumpPrevIdent.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpPrevIdent.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpPrevIdent.Execute;
begin
  JumpIdentifierNearby(True);
end;

function TCnEditorJumpPrevIdent.GetCaption: string;
begin
  Result := SCnEditorJumpPrevIdentMenuCaption;
end;

function TCnEditorJumpPrevIdent.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(VK_UP, [ssAlt, ssCtrl]);
end;

procedure TCnEditorJumpPrevIdent.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorJumpPrevIdentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorJumpPrevIdent.GetHint: string;
begin
  Result := SCnEditorJumpPrevIdentMenuHint;
end;

function TCnEditorJumpPrevIdent.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

procedure TCnEditorJumpPrevIdent.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpPrevIdent.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{ TCnEditorJumpNextIdent }

constructor TCnEditorJumpNextIdent.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpNextIdent.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpNextIdent.Execute;
begin
  JumpIdentifierNearby(False);
end;

function TCnEditorJumpNextIdent.GetCaption: string;
begin
  Result := SCnEditorJumpNextIdentMenuCaption;
end;

function TCnEditorJumpNextIdent.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(VK_DOWN, [ssAlt, ssCtrl]);
end;

procedure TCnEditorJumpNextIdent.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorJumpNextIdentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorJumpNextIdent.GetHint: string;
begin
  Result := SCnEditorJumpNextIdentMenuHint;
end;

function TCnEditorJumpNextIdent.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

procedure TCnEditorJumpNextIdent.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpNextIdent.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{$IFDEF IDE_HAS_INSIGHT}

{ TCnEditorJumpIDEInsight }

constructor TCnEditorJumpIDEInsight.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorJumpIDEInsight.Destroy;
begin
  inherited;

end;

procedure TCnEditorJumpIDEInsight.Execute;
var
  S: string;
  Idx: Integer;
  Bar: TWinControl;
begin
  S := CnOtaGetCurrentSelection;
  if S = '' then
    CnOtaGetCurrPosToken(S, Idx);

  if S <> '' then
  begin
    CnOtaShowDesignerForm; // 先尝试切到设计器，因为 IDE Insight 在非设计器界面无法搜索设计器界面组件，而编辑器没啥可搜的

    Bar := GetIdeInsightBar;
    if (Bar <> nil) and (Bar is TCustomEdit) then
    begin
      (Bar as TCustomEdit).Text := S;
      Bar.SetFocus;
    end;
  end;
end;

function TCnEditorJumpIDEInsight.GetCaption: string;
begin
  Result := SCnEditorJumpIDEInsightMenuCaption;
end;

function TCnEditorJumpIDEInsight.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+F6');
end;

procedure TCnEditorJumpIDEInsight.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorJumpIDEInsightName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorJumpIDEInsight.GetHint: string;
begin
  Result := SCnEditorJumpIDEInsightMenuHint;
end;

function TCnEditorJumpIDEInsight.GetState: TWizardState;
begin
  Result := inherited GetState;
  if not CurrentIsSource then
    Result := []
end;

procedure TCnEditorJumpIDEInsight.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpIDEInsight.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

initialization
  RegisterCnCodingToolset(TCnEditorPrevMessage);
  RegisterCnCodingToolset(TCnEditorNextMessage);

  RegisterCnCodingToolset(TCnEditorJumpIntf);
  RegisterCnCodingToolset(TCnEditorJumpImpl);

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}
  RegisterCnCodingToolset(TCnEditorJumpMatchedKeyword);
  RegisterCnCodingToolset(TCnEditorJumpPrevIdent);
  RegisterCnCodingToolset(TCnEditorJumpNextIdent);
{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$IFDEF IDE_HAS_INSIGHT}
  RegisterCnCodingToolset(TCnEditorJumpIDEInsight);
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
