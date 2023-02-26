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
  TypInfo, StdCtrls, ExtCtrls, ComCtrls, IniFiles,
  CnConsts, CnCommon, CnWizConsts, CnWizUtils, CnCodingToolsetWizard,
  CnEditControlWrapper, CnPasCodeParser, CnWidePasParser;

type
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
    procedure chkShowPreviewClick(Sender: TObject);
  private
    FTool: TCnEditorExtractString;
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

  CN_DEF_MAX_WORDS = 7;

{ TCnEditorExtractString }

function TCnEditorExtractString.CanExtract(const S: PCnIdeTokenChar): Boolean;
var
  L: Integer;
begin
  Result := False;
  L := StrLen(S);
  if L <= 2 then // 单引号或不全，不算
    Exit;

  if (L = 3) and (S[0] = '''') and (S[2] = '''') then // 单个字符也不算
    Exit;

  if (L = 4) and (S[0] = '''') and (S[1] = '''') and (S[2] = '''') and (S[2] = '''') then // 单个单引号也不算
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
  FIgnoreSingleChar := True; 
end;

destructor TCnEditorExtractString.Destroy;
begin

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

    edtPrefix.Text := FPrefix;
    cbbIdentWordStyle.ItemIndex := Ord(FIdentWordStyle);
    if FUseFullPinYin then
      cbbPinYinRule.ItemIndex := 1
    else
      cbbPinYinRule.ItemIndex := 0;
    udMaxWords.Position := FMaxWords;
    udMaxPinYin.Position := FMaxPinYinWords;
    chkUseUnderLine.Checked := FUseUnderLine;
    chkIgnoreSingleChar.Checked := FIgnoreSingleChar;
    chkIgnoreSimpleFormat.Checked := FIgnoreSimpleFormat;
    chkShowPreview.Checked := FShowPreview;

    if ShowModal = mrOK then
    begin
      Prefix := edtPrefix.Text;
      IdentWordStyle := TCnIdentWordStyle(cbbIdentWordStyle.ItemIndex);
      UseFullPinYin := cbbPinYinRule.ItemIndex = 1;

      MaxWords := udMaxWords.Position;
      MaxPinYinWords := udMaxPinYin.Position;
      UseUnderLine := chkUseUnderLine.Checked;
      IgnoreSingleChar := chkIgnoreSingleChar.Checked;
      IgnoreSimpleFormat := chkIgnoreSimpleFormat.Checked;
      ShowPreview := chkShowPreview.Checked;
    end;

    Free;
  end;

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

procedure TCnExtractStringForm.chkShowPreviewClick(Sender: TObject);
begin
  mmoPreview.Visible := chkShowPreview.Checked;
  // spl1.Visible := chkShowPreview.Checked;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtractString); // 注册工具

end.
