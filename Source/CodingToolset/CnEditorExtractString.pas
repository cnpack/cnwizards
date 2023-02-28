{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2023 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorExtractString;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：从源码中抽取字符串单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2023.02.10 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

// {$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ToolsAPI,
  TypInfo, StdCtrls, ExtCtrls, ComCtrls, IniFiles, Clipbrd,
  CnConsts, CnCommon, CnHashMap, CnWizConsts, CnWizUtils, CnCodingToolsetWizard,
  CnEditControlWrapper, CnPasCodeParser, CnWidePasParser, Buttons, ActnList;

type
  TCnStringHeadType = (htVar, htConst, htResourcestring);

  TCnEditorExtractString = class(TCnBaseCodingToolset)
  private
    FUseUnderLine: Boolean;
    FIgnoreSingleChar: Boolean;
    FMaxWords: Integer;
    FMaxPinYinWords: Integer;
    FPrefix: string;
    FIdentWordStyle: TCnIdentWordStyle;
    FUseFullPinYin: Boolean;
    FShowPreview: Boolean;
    FIgnoreSimpleFormat: Boolean;
    FPasParser: TCnGeneralPasStructParser;
    FTokenListRef: TCnIdeStringList;
    function CanExtract(const S: PCnIdeTokenChar): Boolean;
  protected

  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;

    function Scan: Boolean;
    {* 扫描当前源码中的字符串，返回扫描是否成功，产出在 TokenListRef 中}
    procedure MakeUnique;
    {* 将 TokenListRef 中的字符串判重并加上 1 等后缀}
    function GenerateDecl(OutList: TStringList; HeadType: TCnStringHeadType): Boolean;
    {* 从 FTokenListRef 中生成 var 或 const 的声明块，内容放 OutList 中}
    function Replace: Boolean;
    {* 将字符串替换为变量名，不插入声明}

    procedure FreeTokens;
    {* 处理完毕后外界须调用以释放内存}
    property TokenListRef: TCnIdeStringList read FTokenListRef;
    {* 扫描结果，对象均是引用}

  published
    property IgnoreSingleChar: Boolean read FIgnoreSingleChar write FIgnoreSingleChar;
    {* 扫描时是否忽略单字符的字符串}
    property IgnoreSimpleFormat: Boolean read FIgnoreSimpleFormat write FIgnoreSimpleFormat;
    {* 扫描时是否忽略简单的格式化字符串}

    property Prefix: string read FPrefix write FPrefix;
    {* 生成的变量名的前缀，可为空，但不推荐}
    property UseUnderLine: Boolean read FUseUnderLine write FUseUnderLine;
    {* 变量名的分词是否使用下划线作为分隔符}
    property IdentWordStyle: TCnIdentWordStyle read FIdentWordStyle write FIdentWordStyle;
    {* 变量名的分词风格，全大写还是全小写还是首字母大写别的小写}
    property UseFullPinYin: Boolean read FUseFullPinYin write FUseFullPinYin;
    {* 遇到汉字时是使用全拼还是拼音首字母，True 为前者}
    property MaxPinYinWords: Integer read FMaxPinYinWords write FMaxPinYinWords;
    {* 最多的拼音分词个数}
    property MaxWords: Integer read FMaxWords write FMaxWords;
    {* 最多的普通英文分词个数}

    property ShowPreview: Boolean read FShowPreview write FShowPreview;
    {* 是否显示预览窗口}
  end;

  TCnExtractStringForm = class(TForm)
    grpScanOption: TGroupBox;
    chkIgnoreSingleChar: TCheckBox;
    chkIgnoreSimpleFormat: TCheckBox;
    grpPinYinOption: TGroupBox;
    lblPinYin: TLabel;
    cbbPinYinRule: TComboBox;
    btnReScan: TButton;
    pnl1: TPanel;
    lvStrings: TListView;
    mmoPreview: TMemo;
    spl1: TSplitter;
    cbbMakeType: TComboBox;
    lblMake: TLabel;
    lblToArea: TLabel;
    cbbToArea: TComboBox;
    btnHelp: TButton;
    btnReplace: TButton;
    btnClose: TButton;
    lblPrefix: TLabel;
    edtPrefix: TEdit;
    lblStyle: TLabel;
    cbbIdentWordStyle: TComboBox;
    lblMaxWords: TLabel;
    edtMaxWords: TEdit;
    udMaxWords: TUpDown;
    lblMaxPinYin: TLabel;
    edtMaxPinYin: TEdit;
    udMaxPinYin: TUpDown;
    chkUseUnderLine: TCheckBox;
    chkShowPreview: TCheckBox;
    btnCopy: TSpeedButton;
    actlstExtract: TActionList;
    procedure chkShowPreviewClick(Sender: TObject);
    procedure btnReScanClick(Sender: TObject);
    procedure lvStringsData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure lvStringsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnCopyClick(Sender: TObject);
  private
    FTool: TCnEditorExtractString;
    procedure UpdateTokenToListView;
    procedure LoadSettings;
    procedure SaveSettings;
  public
    property Tool: TCnEditorExtractString read FTool write FTool;
  end;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CnSourceStringPosKinds: TCodePosKinds = [pkField, pkProcedure, pkFunction,
    pkConstructor, pkDestructor, pkFieldDot];

  SCN_HEAD_STRS: array[TCnStringHeadType] of string = ('var', 'const', 'resourcestring');

  CN_DEF_MAX_WORDS = 7;

{ TCnExtractStringForm }

procedure TCnExtractStringForm.chkShowPreviewClick(Sender: TObject);
begin
  mmoPreview.Visible := chkShowPreview.Checked;
  // spl1.Visible := chkShowPreview.Checked;
end;

procedure TCnExtractStringForm.UpdateTokenToListView;
begin
  lvStrings.Items.Count := FTool.FTokenListRef.Count;
  lvStrings.Invalidate;
end;

procedure TCnExtractStringForm.btnReScanClick(Sender: TObject);
begin
  if FTool <> nil then
  begin
    SaveSettings;
    if FTool.Scan then
    begin
      if FTool.TokenListRef.Count <= 0 then
      begin
        ErrorDlg(SCnEditorExtractStringNotFound);
        Exit;
      end;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Rescan OK. To Make Unique.');
{$ENDIF}

      FTool.MakeUnique;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Make Unique OK. Update To ListView.');
{$ENDIF}

      UpdateTokenToListView;
    end;
  end;
end;

procedure TCnExtractStringForm.lvStringsData(Sender: TObject;
  Item: TListItem);
var
  Token: TCnGeneralPasToken;
begin
  if (Item.Index >= 0) and (Item.Index < FTool.TokenListRef.Count) then
  begin
    Token := TCnGeneralPasToken(FTool.TokenListRef.Objects[Item.Index]);
    Item.Caption := IntToStr(Item.Index + 1);
    Item.Data := Token;

    with Item.SubItems do
    begin
      Add(FTool.TokenListRef[Item.Index]);
      Add(Token.Token);
    end;
  end;
end;

procedure TCnExtractStringForm.LoadSettings;
begin
  if FTool = nil then
    Exit;

  edtPrefix.Text := FTool.Prefix;
  cbbIdentWordStyle.ItemIndex := Ord(FTool.IdentWordStyle);
  if FTool.UseFullPinYin then
    cbbPinYinRule.ItemIndex := 1
  else
    cbbPinYinRule.ItemIndex := 0;
  udMaxWords.Position := FTool.MaxWords;
  udMaxPinYin.Position := FTool.MaxPinYinWords;
  chkUseUnderLine.Checked := FTool.UseUnderLine;
  chkIgnoreSingleChar.Checked := FTool.IgnoreSingleChar;
  chkIgnoreSimpleFormat.Checked := FTool.IgnoreSimpleFormat;
  chkShowPreview.Checked := FTool.ShowPreview;
end;

procedure TCnExtractStringForm.SaveSettings;
begin
  if FTool = nil then
    Exit;

  FTool.Prefix := edtPrefix.Text;
  FTool.IdentWordStyle := TCnIdentWordStyle(cbbIdentWordStyle.ItemIndex);
  FTool.UseFullPinYin := cbbPinYinRule.ItemIndex = 1;

  FTool.MaxWords := udMaxWords.Position;
  FTool.MaxPinYinWords := udMaxPinYin.Position;
  FTool.UseUnderLine := chkUseUnderLine.Checked;
  FTool.IgnoreSingleChar := chkIgnoreSingleChar.Checked;
  FTool.IgnoreSimpleFormat := chkIgnoreSimpleFormat.Checked;
  FTool.ShowPreview := chkShowPreview.Checked;
end;

procedure TCnExtractStringForm.FormCreate(Sender: TObject);
var
  EditorCanvas: TCanvas;
  I: TCnStringHeadType;
begin
  for I := Low(SCN_HEAD_STRS) to High(SCN_HEAD_STRS) do
    cbbMakeType.Items.Add(SCN_HEAD_STRS[I]);

  cbbMakeType.ItemIndex := 0;
  cbbToArea.ItemIndex := 0;

  EditorCanvas := EditControlWrapper.GetEditControlCanvas(CnOtaGetCurrentEditControl);
  if EditorCanvas <> nil then
  begin
    if EditorCanvas.Font.Name <> mmoPreview.Font.Name then
      mmoPreview.Font.Name := EditorCanvas.Font.Name;
    mmoPreview.Font.Size := EditorCanvas.Font.Size;
    mmoPreview.Font.Style := EditorCanvas.Font.Style - [fsUnderline, fsStrikeOut, fsItalic];
  end;
end;

procedure TCnExtractStringForm.lvStringsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
const
  CnBeforeLine = 1;
  CnAfterLine = 4;
var
  Token: TCnGeneralPasToken;
begin
  if not Selected or (Item = nil) or (Item.Data = nil) then
    Exit;

  Token := TCnGeneralPasToken(Item.Data);
  mmoPreview.Lines.Text := CnOtaGetLineText(Token.EditLine - CnBeforeLine,
    nil, CnBeforeLine + CnAfterLine);
end;

procedure TCnExtractStringForm.btnCopyClick(Sender: TObject);
var
  L: TStringList;
  HT: TCnStringHeadType;
begin
  L := TStringList.Create;
  try
    HT := TCnStringHeadType(cbbMakeType.ItemIndex);
    if FTool.GenerateDecl(L, HT) then
    begin
      Clipboard.AsText := L.Text;
      InfoDlg(Format(SCnEditorExtractStringCopiedFmt, [L.Count - 1, SCN_HEAD_STRS[HT]]));
    end;
  finally
    L.Free;
  end;
end;

{ TCnEditorExtractString }

function TCnEditorExtractString.CanExtract(const S: PCnIdeTokenChar): Boolean;
var
  L: Integer;
begin
  Result := False;
  L := StrLen(S);
  if L <= 2 then // 单引号或不全，不算
    Exit;

  if FIgnoreSingleChar and (L = 3) and (S[0] = '''') and (S[2] = '''') then // 单个字符也不算
    Exit;

  if FIgnoreSingleChar and (L = 4) and (S[0] = '''') and (S[1] = '''')
    and (S[2] = '''') and (S[2] = '''') then // 单个单引号也不算
    Exit;

  if FIgnoreSimpleFormat and IsSimpleFormat(S) then
    Exit;

  Result := True;
end;

constructor TCnEditorExtractString.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FIdentWordStyle := iwsUpperCase;
  FPrefix := 'S';
  FMaxWords := CN_DEF_MAX_WORDS;
  FMaxPinYinWords := CN_DEF_MAX_WORDS;
  FUseUnderLine := True;
  FIgnoreSingleChar := True;
  FIgnoreSimpleFormat := True;
  FShowPreview := True;
end;

destructor TCnEditorExtractString.Destroy;
begin
  FTokenListRef.Free;
  FPasParser.Free;
  inherited;
end;

procedure TCnEditorExtractString.Execute;
var
  PasParser: TCnGeneralPasStructParser;
  Stream: TMemoryStream;
  I, CurrPos, LastTokenPos: Integer;
  EditView: IOTAEditView;
  Token, StartToken, EndToken, PrevToken: TCnGeneralPasToken;
  EditPos: TOTAEditPos;
  Info: TCodePosInfo;
  TokenList: TCnIdeStringList;
  S, NewCode: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  with TCnExtractStringForm.Create(Application) do
  begin
    Tool := Self;
    LoadSettings;

    if ShowModal = mrOK then
    begin
      SaveSettings;

    end;

    Free;
  end;

  Exit;

  PasParser := nil;
  Stream := nil;
  TokenList := nil;

  try
    PasParser := TCnGeneralPasStructParser.Create;
{$IFDEF BDS}
    PasParser.UseTabKey := True;
    PasParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}

    Stream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnEditorExtractString.Execute to ParseString.');
{$ENDIF}

    // 解析当前显示的源文件中的字符串
    CnPasParserParseString(PasParser, Stream);
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if CanExtract(Token.Token) then
      begin
        ConvertGeneralTokenPos(Pointer(EditView), Token);

{$IFDEF UNICODE}
        ParsePasCodePosInfoW(PChar(Stream.Memory), Token.EditLine, Token.EditCol, Info);
{$ELSE}
        EditPos.Line := Token.EditLine;
        EditPos.Col := Token.EditCol;
        CurrPos := CnOtaGetLinePosFromEditPos(EditPos);

        Info := ParsePasCodePosInfo(PChar(Stream.Memory), CurrPos);
{$ENDIF}
        Token.Tag := Ord(Info.PosKind);
      end
      else
        Token.Tag := Ord(pkUnknown);
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(PasParser.Count, 'PasParser.Count');
{$ENDIF}

    TokenList := TCnIdeStringList.Create;
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if TCodePosKind(Token.Tag) in CnSourceStringPosKinds then
      begin
        S := ConvertStringToIdent(string(Token.Token));
        // 在 D2005~2007 下有 AnsiString 到 WideString 的转换但也无影响

        TokenList.AddObject(S, Token);
      end;
    end;

    // TokensRefList 中的 Token 是要抽取的内容
    if TokenList.Count <= 0 then
    begin
      ErrorDlg(SCnEditorExtractStringNotFound);
      Exit;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(TokenList.Count, 'TokensRefList.Count');
{$ENDIF}

    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. PosKind: %-18s, Token: %-14s, ConvertTo: %14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos,
        GetEnumName(TypeInfo(TCodePosKind), Token.Tag), Token.Token, TokenList[I]]);
{$ENDIF}
    end;

    StartToken := TCnGeneralPasToken(TokenList.Objects[0]);
    EndToken := TCnGeneralPasToken(TokenList.Objects[TokenList.Count - 1]);
    PrevToken := nil;

    // 拼接替换后的字符串
    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
      if PrevToken = nil then
        NewCode := TokenList[I]
      else
      begin
        // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字，用 Ansi/Wide/Wide String 来计算
        LastTokenPos := PrevToken.TokenPos + Length(PrevToken.Token);
        NewCode := NewCode + Copy(PasParser.Source, LastTokenPos + 1,
          Token.TokenPos - LastTokenPos) + TokenList[I];
      end;
      PrevToken := TCnGeneralPasToken(TokenList.Objects[I]);
    end;

    EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
    // 插入时，Wide 要做 Utf8 转换
    EditWriter.CopyTo(Length(UTF8Encode(Copy(Parser.Source, 1, StartToken.TokenPos))));
    EditWriter.DeleteTo(Length(UTF8Encode(Copy(Parser.Source, 1, EndToken.TokenPos + Length(EndToken.Token)))));
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
  {$ENDIF}
{$ELSE}
    EditWriter.CopyTo(StartToken.TokenPos);
    EditWriter.DeleteTo(EndToken.TokenPos + Length(EndToken.Token));
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
{$ENDIF}
    EditWriter := nil;

    RemoveDuplicatedStrings(TokenList); // 去重

    // 组成声明部分
    for I := 0 to TokenList.Count - 1 do
    begin
      Token := TCnGeneralPasToken(TokenList.Objects[I]);
      TokenList[I] := '  ' + TokenList[I] + ' = ' + Token.Token + ';';
    end;
    TokenList.Insert(0, 'const');

    // TODO: 找到 implementation 部分再次插入
  finally
    TokenList.Free;
    Stream.Free;
    PasParser.Free;
  end;
end;

procedure TCnEditorExtractString.FreeTokens;
begin
  FreeAndNil(FTokenListRef);
  FreeAndNil(FPasParser);
end;

function TCnEditorExtractString.GenerateDecl(OutList: TStringList;
  HeadType: TCnStringHeadType): Boolean;
var
  I, L: Integer;
  Token: TCnGeneralPasToken;
begin
  Result := False;
  if (OutList = nil) or (FTokenListRef = nil) or (FTokenListRef.Count <= 0) then
    Exit;

  L := EditControlWrapper.GetBlockIndent;
  OutList.Clear;
  OutList.Add(SCN_HEAD_STRS[HeadType]);

  if HeadType in [htVar] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      OutList.Add(Spc(L) + FTokenListRef[I] + ': string = ' + Token.Token + ';');
    end;
    StringsRemoveDuplicated(OutList);
    Result := True;
  end
  else if HeadType in [htConst, htResourcestring] then
  begin
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      OutList.Add(Spc(L) + FTokenListRef[I] + ' = ' + Token.Token + ';');
    end;
    StringsRemoveDuplicated(OutList);
    Result := True;
  end;
end;

function TCnEditorExtractString.GetCaption: string;
begin
  Result := SCnEditorExtractStringMenuCaption;
end;

function TCnEditorExtractString.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorExtractString.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorExtractStringName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorExtractString.GetHint: string;
begin
  Result := SCnEditorExtractStringMenuHint;
end;

procedure TCnEditorExtractString.MakeUnique;
var
  I, J: Integer;
  Map: TCnStrToStrHashMap;
  S, H: string;
  Token: TCnGeneralPasToken;
begin
  if FTokenListRef.Count <= 1 then
    Exit;

  Map := TCnStrToStrHashMap.Create;
  try
    for I := 0 to FTokenListRef.Count - 1 do
    begin
      Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
      if Map.Find(string(FTokenListRef[I]), S) then
      begin
        if S <> string(Token.Token) then
        begin
          // 有同名的，但值不同，要换名
          J := 1;
          H := FTokenListRef[I];
          repeat
            FTokenListRef[I] := H + IntToStr(J);
            Inc(J);
          until not Map.Find(string(FTokenListRef[I]), S);

          // 换名后要添加
          Map.Add(string(FTokenListRef[I]), string(Token.Token));
        end;
        // 同名同值忽略
      end
      else // 无同名的，直接添加
        Map.Add(string(FTokenListRef[I]), string(Token.Token));
    end;
  finally
    Map.Free;
  end;
end;

function TCnEditorExtractString.Replace: Boolean;
var
  I, LastTokenPos: Integer;
  EditView: IOTAEditView;
  Token, StartToken, EndToken, PrevToken: TCnGeneralPasToken;
  NewCode: TCnIdeTokenString;
  EditWriter: IOTAEditWriter;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  StartToken := TCnGeneralPasToken(FTokenListRef.Objects[0]);
  EndToken := TCnGeneralPasToken(FTokenListRef.Objects[FTokenListRef.Count - 1]);
  PrevToken := nil;

  // 拼接替换后的字符串
  for I := 0 to FTokenListRef.Count - 1 do
  begin
    Token := TCnGeneralPasToken(FTokenListRef.Objects[I]);
    if PrevToken = nil then
      NewCode := FTokenListRef[I]
    else
    begin
      // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字，用 Ansi/Wide/Wide String 来计算
      LastTokenPos := PrevToken.TokenPos + Length(PrevToken.Token);
      NewCode := NewCode + Copy(FPasParser.Source, LastTokenPos + 1,
        Token.TokenPos - LastTokenPos) + FTokenListRef[I];
    end;
    PrevToken := TCnGeneralPasToken(FTokenListRef.Objects[I]);
  end;

  EditWriter := CnOtaGetEditWriterForSourceEditor;

{$IFDEF IDE_WIDECONTROL}
  // 插入时，Wide 要做 Utf8 转换
  EditWriter.CopyTo(Length(UTF8Encode(Copy(Parser.Source, 1, StartToken.TokenPos))));
  EditWriter.DeleteTo(Length(UTF8Encode(Copy(Parser.Source, 1, EndToken.TokenPos + Length(EndToken.Token)))));
  {$IFDEF UNICODE}
  EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
  {$ELSE}
  EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
  {$ENDIF}
{$ELSE}
  EditWriter.CopyTo(StartToken.TokenPos);
  EditWriter.DeleteTo(EndToken.TokenPos + Length(EndToken.Token));
  EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
{$ENDIF}
  EditWriter := nil;
end;

function TCnEditorExtractString.Scan: Boolean;
var
  Stream: TMemoryStream;
  I, CurrPos, LastTokenPos: Integer;
  EditView: IOTAEditView;
  Token: TCnGeneralPasToken;
  EditPos: TOTAEditPos;
  Info: TCodePosInfo;
  S: TCnIdeTokenString;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Stream := nil;

  try
    FreeTokens;

    FPasParser := TCnGeneralPasStructParser.Create;
{$IFDEF BDS}
    FPasParser.UseTabKey := True;
    FPasParser.TabWidth := EditControlWrapper.GetTabWidth;
{$ENDIF}

    Stream := TMemoryStream.Create;
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('CnEditorExtractString Scan to ParseString.');
{$ENDIF}

    // 解析当前显示的源文件中的字符串
    CnPasParserParseString(FPasParser, Stream);
    for I := 0 to FPasParser.Count - 1 do
    begin
      Token := FPasParser.Tokens[I];
      if CanExtract(Token.Token) then
      begin
        ConvertGeneralTokenPos(Pointer(EditView), Token);

{$IFDEF UNICODE}
        ParsePasCodePosInfoW(PChar(Stream.Memory), Token.EditLine, Token.EditCol, Info);
{$ELSE}
        EditPos.Line := Token.EditLine;
        EditPos.Col := Token.EditCol;
        CurrPos := CnOtaGetLinePosFromEditPos(EditPos);

        Info := ParsePasCodePosInfo(PChar(Stream.Memory), CurrPos);
{$ENDIF}
        Token.Tag := Ord(Info.PosKind);
      end
      else
        Token.Tag := Ord(pkUnknown);
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(FPasParser.Count, 'PasParser.Count');
{$ENDIF}

    if FTokenListRef = nil then
      FTokenListRef := TCnIdeStringList.Create
    else
      FTokenListRef.Clear;

    for I := 0 to FPasParser.Count - 1 do
    begin
      Token := FPasParser.Tokens[I];
      if TCodePosKind(Token.Tag) in CnSourceStringPosKinds then
      begin
        S := ConvertStringToIdent(string(Token.Token), FPrefix, FUseUnderLine,
          FIdentWordStyle, FUseFullPinYin, FMaxPinYinWords, FMaxWords);
        // 在 D2005~2007 下有 AnsiString 到 WideString 的转换但也无影响

        FTokenListRef.AddObject(S, Token);
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(FTokenListRef.Count, 'TokensRefList.Count');
{$ENDIF}
    Result := True;
  finally
    Stream.Free;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtractString); // 注册工具

end.
