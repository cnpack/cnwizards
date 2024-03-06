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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnInputSymbolList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手单词列表类定义单元
* 单元作者：Johnson Zhong zhongs@tom.com http://www.longator.com
*           周劲羽 zjy@cnpack.org
* 备    注：单词列表类定义
* 开发平台：PWin2000Pro + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2022.02.13 by liuxiao
*               模板输出允许用两个连续的 || 代表一个 | 号，而单个 | 号仍代表光标位置
*           2016.03.15 by liuxiao
*               TUnitNameList 增加路径机制与 h/hpp 支持供外部使用
*           2012.09.19 by shenloqi
*               移植到 Delphi XE3
*           2012.03.26
*               增加对 XE/XE2 独有的 XML 格式的模板的支持，有部分内容兼容问题
*           2004.11.05
*               移植而来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$IFDEF BDS}
  {$DEFINE IDE_SYMBOL_HAS_SYSTEM} // 2005 或以上，符号列表中有 System 单元
{$ENDIF}

uses
  Windows, SysUtils, Classes, Controls, IniFiles, ToolsApi, Psapi, Math,
  Forms, Graphics, Contnrs, TypInfo,
  {$IFDEF OTA_CODE_TEMPLATE_API} CodeTemplateAPI, {$ENDIF}
  CnCommon, CnWizConsts, CnWizOptions,
  CnWizUtils, CnWizIdeUtils, CnPasCodeParser, OmniXML, OmniXMLPersistent,
  OmniXMLUtils, CnWizMacroUtils, CnWizIni;

const
  CODE_TEMPLATE_INDEX_INVALID = -1;

type

//==============================================================================
// 符号项类
//==============================================================================

  TSymbolKind = (skUnknown, skConstant, skType, skVariable, skProcedure,
    skFunction, skUnit, skLabel, skProperty, skConstructor, skDestructor,
    skInterface, skEvent, skKeyword, skClass, skTemplate, skCompDirect,
    skComment, skUser);
  {* 符号类型 }

  TSymbolKindSet = set of TSymbolKind;
  {* 符号类型集合 }

  TCnKeywordStyle = (ksDefault, ksLower, ksUpper, ksFirstUpper);
  {* 关键字大小写方式 }
  
{ TSymbolItem }

  TSymbolItem = class(TPersistent)
  {* 用于代码输入的符号项 }
  private
    FDescription: string;
    FDescIsUtf8: Boolean;
    FKind: TSymbolKind;
    FName: string;
    FScope: Integer;
    FScopeHit: Integer;
    FScopeAdjust: Integer;
    FText: string;
    FTag: Integer;
    FHashCode: Cardinal;
    FMatchFirstOnly: Boolean;
    FFuzzyMatchIndexes: TList;
    FAutoIndent: Boolean;
    FAlwaysDisp: Boolean;
    FForPascal: Boolean;
    FForCpp: Boolean;
    FCodeTemplateIndex: Integer;
    function GetScopeRate: Integer;
    function GetText: string;
    procedure SetScopeRate(const Value: Integer);
    function GetAllowMultiLine: Boolean;
    function GetDescription: string;
    function PipesCursorPosition(var S: string): Integer;
    {* 处理输入文本中的 | 号，返回第一个单独 | 号的偏移量，无则返回 -1。并将 S 中的连续 || 替换成单独 |}
  protected
    procedure CalcHashCode; virtual;
    procedure OutputLines(Editor: IOTAEditBuffer; Lines: TStrings);
    procedure OutputTemplate(Editor: IOTAEditBuffer; Icon: TIcon);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure Output(Editor: IOTAEditBuffer; Icon: TIcon; KeywordStyle:
      TCnKeywordStyle); virtual;
    {* 输出文本到代码编辑器 }
    function GetKeywordText(KeywordStyle: TCnKeywordStyle): string;
    {* 按指定风格取关键字文本 }

    property HashCode: Cardinal read FHashCode write FHashCode;
    {* 标识符及类型的 HashCode 信息 }
    property Tag: Integer read FTag write FTag;
    {* 供其它程序使用的数据，如排序时用来临时保存数据，包括模糊匹配的匹配度数据 }
    property ScopeHit: Integer read FScopeHit write FScopeHit;
    {* 使用频度优先级，由输入助手设置 }
    property ScopeAdjust: Integer read FScopeAdjust write FScopeAdjust;
    {* 根据使用频度调整过后的优先级，由输入助手设置 }

    property Scope: Integer read FScope write FScope;
    {* 符号的优先级，0..MaxInt，越小显示越靠前 }
    property MatchFirstOnly: Boolean read FMatchFirstOnly write FMatchFirstOnly;
    {* 是否要求从头开始匹配 }
    property AllowMultiLine: Boolean read GetAllowMultiLine;
    {* 允许多行文本 }
    property FuzzyMatchIndexes: TList read FFuzzyMatchIndexes;
    {* 模糊匹配时用来存储匹配下标的列表 }
  published
    property Name: string read FName write FName;
    {* 符号的名称，即用户键入的字符串 }
    property Kind: TSymbolKind read FKind write FKind;
    {* 符号的类型 }
    property Description: string read GetDescription write FDescription;
    {* 符号的声明，显示在列表中 }
    property Text: string read GetText write FText;
    {* 实际输出到代码编辑器的文本 }
    property ScopeRate: Integer read GetScopeRate write SetScopeRate;
    {* 符号的优先级，0..100，越小显示越靠前 }
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    {* 如果是多行文本时，是否自动缩进对齐 }
    property AlwaysDisp: Boolean read FAlwaysDisp write FAlwaysDisp;
    {* 允许文本全匹配时不弹出助手 }
    property ForPascal: Boolean read FForPascal write FForPascal;
    {* 是否在 Pascal 中有效}
    property ForCpp: Boolean read FForCpp write FForCpp;
    {* 是否在 C/C++ 中有效}
    property CodeTemplateIndex: Integer read FCodeTemplateIndex write FCodeTemplateIndex;
    {* 当本条目指向一 IDE 的代码模板时，存储其索引号，无则 -1}
  end;

//==============================================================================
// 符号列表基类
//==============================================================================

{ TSymbolList }

  TSymbolList = class(TObject)
  private
    FList: TObjectList; // 持有符号对象的实例们
    FActive: Boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): TSymbolItem;
  protected
    property List: TObjectList read FList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure Sort; virtual;
    procedure Reset; virtual;
    class function GetListName: string; virtual;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; virtual;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; 
      PosInfo: TCodePosInfo); virtual;
    function Add(AItem: TSymbolItem): Integer; overload; virtual;
    function Add(const AName: string; AKind: TSymbolKind; AScope: Integer; const
      ADescription: string = ''; const AText: string = ''; AAutoIndent: Boolean = 
      True; AMatchFirstOnly: Boolean = False; AAlwaysDisp: Boolean = False;
      ADescIsUtf8: Boolean = False): Integer; overload; virtual;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure Remove(AItem: TSymbolItem);
    function IndexOf(const AName: string; AKind: TSymbolKind): Integer;
    function CanCustomize: Boolean; virtual;
    procedure RestoreDefault; virtual;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TSymbolItem read GetItem;
    property Active: Boolean read FActive write FActive;
  end;

  TSymbolListClass = class of TSymbolList;

//==============================================================================
// 自定义符号列表
//==============================================================================

{ TFileSymbolList }

  TFileSymbolList = class(TSymbolList)
  protected
    function GetReadFileName: string; virtual;
    function GetWriteFileName: string; virtual;
    function GetDataFileName: string; virtual;
  public
    procedure Load; override;
    procedure Save; override;
    procedure Reset; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
    function CanCustomize: Boolean; override;
    procedure RestoreDefault; override;
  end;

//==============================================================================
// 预定义符号列表
//==============================================================================

{ TPreDefSymbolList }

  TPreDefSymbolList = class(TFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
  end;

//==============================================================================
// 预定义符号列表
//==============================================================================

{ TUserTemplateList }

  TUserTemplateList = class(TFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
  end;

//==============================================================================
// 用户定义符号列表
//==============================================================================

{ TUserSymbolList }

  TUserSymbolList = class(TFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; 
      PosInfo: TCodePosInfo); override;
  end;

//==============================================================================
// XML 注释列表
//==============================================================================

{ TXMLCommentSymbolList }

  TXMLCommentSymbolList = class(TFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet;
      PosInfo: TCodePosInfo); override;
  end;

//==============================================================================
// JavaDoc 注释列表
//==============================================================================

{ TJavaDocSymbolList }

  TJavaDocSymbolList = class(TFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; PosInfo:
      TCodePosInfo); override;
  end;

//==============================================================================
// 编译指令符号列表
//==============================================================================

{ TCompDirectSymbolList }

  TCompDirectSymbolList = class(TSymbolList)
  protected
    procedure AddSection(Ini: TMemIniFile; const Section: string);
  public
    procedure Load; override;
    procedure Save; override;
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; PosInfo:
      TCodePosInfo); override;
  end;

//==============================================================================
// 在 uses 中使用的单元名称列表
//==============================================================================

{ TUnitNameList }

  TUnitNameList = class(TSymbolList)
  private
    FUseFullPath: Boolean;
    FCppMode: Boolean;
    FLoadAfterCreate: Boolean;
    FSysPath: string;
    FSysUnitsName: TStringList;
    FSysUnitsPath: TStringList;
    FProjectPath: string;
    FProjectUnitsName: TStringList;
    FProjectUnitsPath: TStringList;  // 这几个 Path StringList 存储的都是带路径的完整文件名
    FUnitNames: TStringList;   // 存储单独的文件名
    FUnitPaths: TStringList;   // FUseFullPath 为 True 时存储对应的包括路径的完整单元名
    FCurrFileList: TStringList;
    FCurrPathList: TStringList;
    function AddUnit(const UnitName: string; IsInProject: Boolean = False): Boolean;
    procedure AddUnitFullNameWithPath(const UnitFullName: string);
    procedure DoFindFile(const FileName: string; const Info: TSearchRec; var Abort: 
      Boolean);
    procedure LoadFromSysPath;
    procedure LoadFromProjectPath;
    procedure LoadFromCurrProject;
    procedure UpdatePathsSequence(Names, Paths: TStringList);
  public
    constructor Create; overload; override;
    constructor Create(UseFullPath: Boolean; IsCppMode: Boolean;
      LoadAfterCreate: Boolean); reintroduce; overload;
    destructor Destroy; override;
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
    procedure DoInternalLoad(IncludePath: Boolean = True);
    procedure ExportToStringList(Names, Paths: TStringList);
    // 将不包括扩展名的文件名以及带完整路径的文件名输出至外部列表
  end;

//==============================================================================
// 当前单元引用的单元名称列表
//==============================================================================

{ TUnitUsesList }

  TUnitUsesList = class(TSymbolList)
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

//==============================================================================
// 代码模板列表
//==============================================================================

{ TCodeTemplateList }

  TCodeTemplateList = class(TSymbolList)
  private
    FFileAge: Integer;
  protected
    FForBcb: Boolean;
    FForPascal: Boolean;
    function GetReadFileName: string; virtual; abstract;
  public
    procedure Load; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

//==============================================================================
// IDE 自带的代码模板列表
//==============================================================================

{ TIDECodeTemplateList }

  TIDECodeTemplateList = class(TCodeTemplateList)
  protected
    function GetReadFileName: string; override;
  public
    class function GetListName: string; override;
  end;

{$IFDEF OTA_CODE_TEMPLATE_API}

  TIDEModernCodeTemplateList = class(TSymbolList)
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

{$ENDIF}

//==============================================================================
// 符号列表管理器
//==============================================================================

{ TSymbolListMgr }

  TSymbolListMgr = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetList(Index: Integer): TSymbolList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitList;
    procedure Reset;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; 
      PosInfo: TCodePosInfo);
    function ListByClass(AClass: TSymbolListClass): TSymbolList;
    procedure Load;
    procedure Save;
    property List[Index: Integer]: TSymbolList read GetList;
    property Count: Integer read GetCount;
  end;

function GetSymbolKindName(Kind: TSymbolKind): string;
{* 返回符号类型的名称 }

function ScopeToRate(Scope: Integer): Integer;
function RateToScope(Rate: Integer): Integer;

function SaveListToXMLFile(List: TSymbolList; const FileName: string): Boolean;
function LoadListFromXMLFile(List: TSymbolList; const FileName: string): Boolean;

procedure RegisterSymbolList(AClass: TSymbolListClass);
{* 注册一个符号列表类 }

const
  csDefScopeRate = 15;
  csIdentFirstSet: TAnsiCharSet = Alpha;
  csIdentCharSet: TAnsiCharSet = AlphaNumeric;
  csCompDirectFirstSet: TAnsiCharSet = ['{'];
  csCompDirectCharSet: TAnsiCharSet = ['$', '+', '-'] + AlphaNumeric;
  csCppCompDirectFirstSet: TAnsiCharSet = ['#'];
  csCppCompDirectCharSet: TAnsiCharSet = AlphaNumeric;
  csCommentFirstSet: TAnsiCharSet = ['/'];
  csCommentCharSet: TAnsiCharSet = ['/'] + AlphaNumeric;
  csJavaDocFirstSet: TAnsiCharSet = ['{'];
  csJavaDocTagFirstSet: TAnsiCharSet = ['@'];
  csJavaDocCharSet: TAnsiCharSet = ['*', '-'] + AlphaNumeric;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCRC32, CnWizMacroText, CnWizMacroFrm;

const
  csCompD5 = 'D5';
  csCompD6 = 'D6';
  csCompD7 = 'D7';

  csCompD2005 = 'D2005';
  csCompD2006 = 'D2006';
  csCompD2007 = 'D2007';
  csCompD2009 = 'D2009';
  csCompD2010 = 'D2010';
  csCompDXE = 'DXE';
  csCompDXE2 = 'DXE2';
  csCompDXE3 = 'DXE3';
  csCompDXE4 = 'DXE4';
  csCompDXE5 = 'DXE5';
  csCompDXE6 = 'DXE6';
  csCompDXE7 = 'DXE7';
  csCompDXE8 = 'DXE8';
  csCompD10S = 'D10S';
  csCompD101B = 'D101B';
  csCompD102T = 'D102T';
  csCompD103R = 'D103R';
  csCompD104S = 'D104S';
  csCompD110A = 'D110A';
  csCompD120A = 'D120A';

  csCompBCB = 'BCB';
  csCompUser = 'User';

  csCompDirectScope = MaxInt div 100 * 35;
  csUnitScope = MaxInt div 100 * 30;
  csUsesScope = MaxInt div 100 * 25;
  csTemplateScope = MaxInt div 100 * 20;
  csCommentScope = MaxInt div 100 * 15;
  csDefScope = MaxInt div 100 * csDefScopeRate;

type
  TOmniXMLReaderHack = class(TOmniXMLReader);
  TOmniXMLWriterHack = class(TOmniXMLWriter);

// 返回符号类型的名称
function GetSymbolKindName(Kind: TSymbolKind): string;
begin
  Result := Copy(GetEnumName(TypeInfo(TSymbolKind), Ord(Kind)), 3, MaxInt);
end;

function ScopeToRate(Scope: Integer): Integer;
begin
  Result := Round(Scope / MaxInt * 100);
end;

function RateToScope(Rate: Integer): Integer;
begin
  Result := Round(Rate / 100 * MaxInt);
end;

//==============================================================================
// 符号项类
//==============================================================================

{ TSymbolItem }

constructor TSymbolItem.Create;
begin
  inherited;
  FScope := csDefScope;
  FAutoIndent := True;
  FAlwaysDisp := False;
  FForPascal := True;
  FCodeTemplateIndex := CODE_TEMPLATE_INDEX_INVALID;
  FFuzzyMatchIndexes := TList.Create;
end;

procedure TSymbolItem.Assign(Source: TPersistent);
begin
  if Source is TSymbolItem then
  begin
    FDescription := TSymbolItem(Source).FDescription;
    FDescIsUtf8 := TSymbolItem(Source).FDescIsUtf8;
    FKind := TSymbolItem(Source).FKind;
    FName := TSymbolItem(Source).FName;
    FScope := TSymbolItem(Source).FScope;
    FScopeAdjust := TSymbolItem(Source).FScopeAdjust;
    FText := TSymbolItem(Source).FText;
    FTag := TSymbolItem(Source).FTag;
    FHashCode := TSymbolItem(Source).FHashCode;
    FMatchFirstOnly := TSymbolItem(Source).FMatchFirstOnly;
    FAutoIndent := TSymbolItem(Source).FAutoIndent;
  end
  else
    inherited;
end;

procedure TSymbolItem.CalcHashCode;
begin
  FHashCode := Ord(FKind);
  FHashCode := StrCRC32(FHashCode, FName);
  FHashCode := StrCRC32(FHashCode, FDescription);
end;

function TSymbolItem.GetScopeRate: Integer;
begin
  Result := ScopeToRate(FScope);
end;

function TSymbolItem.GetText: string;
begin
  if AllowMultiLine then
    Result := FText
  else
    Result := FName;
end;

function TSymbolItem.GetDescription: string;
begin
  if FDescIsUtf8 then
    Result := string(ConvertEditorTextToText(AnsiString(FDescription)))
  else
    Result := FDescription;
end;

procedure TSymbolItem.SetScopeRate(const Value: Integer);
begin
  FScope := RateToScope(Value);
end;

function TSymbolItem.GetAllowMultiLine: Boolean;
begin
  Result := Kind in [skTemplate, skComment];
end;

function TSymbolItem.GetKeywordText(KeywordStyle: TCnKeywordStyle): string;
begin
  Result := Name;
  if (FKind = skKeyword) and (KeywordStyle <> ksDefault) then
  begin
    case KeywordStyle of
      ksLower: Result := LowerCase(Result);
      ksUpper: Result := UpperCase(Result);
      ksFirstUpper:
        begin
          Result := LowerCase(Result);
          if Result <> '' then
            Result[1] := UpCase(Result[1]);
        end;
    end;
  end;
end;

procedure TSymbolItem.OutputLines(Editor: IOTAEditBuffer; Lines: TStrings);
var
  Line: string;
  OrgPos: TOTAEditPos;
  EditPos: TOTAEditPos;
  Relocate: Boolean;
  OffsetX, Idx: Integer;
  OffsetY: Integer;
  I: Integer;
begin
  if not AutoIndent then
  begin
    CnOtaInsertTextToCurSource(Lines.Text);
  end
  else
  begin
    OffsetX := 0;
    OffsetY := 0;
    Relocate := False;
    OrgPos := Editor.TopView.CursorPos;
    for I := 0 to Lines.Count - 1 do
    begin
      if I > 0 then
      begin
        EditPos.Col := OrgPos.Col;
        EditPos.Line := OrgPos.Line + I;
        Editor.TopView.CursorPos := EditPos;
      end;

      Line := Lines[I];
      Idx := PipesCursorPosition(Line); // 处理该行中的双 || 与单 |，返回的 Idx 是最开始一个单 | 的位置
      if not Relocate and (Idx > 0) then
      begin
        OffsetX := Idx - 1;
        OffsetY := I;
        Relocate := True;
      end;

      if I < Lines.Count - 1 then
        Line := Line + #13#10;
      CnOtaInsertTextToCurSource(Line);
    end;

    if Relocate then
    begin
      EditPos.Col := OrgPos.Col + OffsetX;
      EditPos.Line := OrgPos.Line + OffsetY;
      Editor.TopView.CursorPos := EditPos;
      Application.ProcessMessages;
      Editor.TopView.Paint;
    end;
  end;
end;

procedure TSymbolItem.OutputTemplate(Editor: IOTAEditBuffer; Icon: TIcon);
var
  OutText: string;
  Lines: TStringList;
  CurrPos: Integer;
  MacroText: TCnWizMacroText;
begin
  OutText := Text;
  if (OutText <> '') and Assigned(Editor) and Assigned(Editor.TopView) then
  begin
    // OutText := StringReplace(OutText, GetMacroEx(cwmCursor), '|', [rfReplaceAll]);
    MacroText := TCnWizMacroText.Create(OutText);
    try
      if MacroText.Macros.Count > 0 then
      begin
        if not GetEditorMacroValue(MacroText.Macros, SCnInputHelperName, Icon) then
          Exit;
      end;
      OutText := MacroText.OutputText(CurrPos);
    finally
      MacroText.Free;
    end;

    Lines := TStringList.Create;
    try
      Lines.Text := OutText;
      OutputLines(Editor, Lines);
    finally
      Lines.Free;
    end;
  end;
end;

procedure TSymbolItem.Output(Editor: IOTAEditBuffer; Icon: TIcon; KeywordStyle:
  TCnKeywordStyle);
var
  S: string;
  Idx: Integer;
begin
  if Assigned(Editor) and Assigned(Editor.EditPosition) then
  begin
    if not AllowMultiLine then
    begin
      S := GetKeywordText(KeywordStyle);
      Idx := PipesCursorPosition(S);
      // || means an actual | and first single | means cursor position
{$IFDEF UNICODE}
      Editor.EditPosition.InsertText(ConvertTextToEditorUnicodeText(S));
{$ELSE}
      Editor.EditPosition.InsertText(ConvertTextToEditorText(S));
{$ENDIF}
      Editor.TopView.Paint;
      if Idx > 0 then
        Editor.EditPosition.MoveRelative(0, -(Length(S) - Idx + 1));
    end
    else
    begin
      Editor.TopView.Paint;
      OutputTemplate(Editor, Icon);
    end;        
  end;
end;

destructor TSymbolItem.Destroy;
begin
  FFuzzyMatchIndexes.Free;
  inherited;
end;

function TSymbolItem.PipesCursorPosition(var S: string): Integer;
const
  RPC = #0;
var
  I, Dif: Integer;
begin
  Result := -1;
  if  Pos('|', S) <= 0 then
    Exit;

  if Length(S) <= 0 then
    Exit
  else if (Length(S) = 1) and (S[1] = '|') then // 单 | 表示插入位置
  begin
    S := '';
    Result := 1;
    Exit;
  end;

  // 预处理双 ||，把第二个 | 替换成 #0
  for I := 1 to Length(S) - 1 do
  begin
    if S[I] = '|' then
    begin
      if S[I + 1] = '|' then
      begin
        // 是双 |，先替换第二个成 #0
        S[I + 1] := RPC;
      end;
    end;
  end;

  // 然后记录第一个单 | 出现的位置并替换成 #0
  for I := 1 to Length(S) do
  begin
    if S[I] = '|' then
    begin
      if ((I = 1) or (S[I - 1] <> '|')) and         // 无前或前非 |，并且
        ((I = Length(S)) or ((S[I + 1] <> '|') and (S[I + 1] <> RPC))) then  // 无后或后非 | 且非 #0
      begin
        Result := I;  // 都表示是第一个单 |，先替换成 #0
        S[I] := RPC;
        Break;
      end;
    end;
  end;

  Dif := 0;
  for I := 1 to Length(S) - 1 do
  begin
    if S[I] = '|' then
    begin
      if S[I + 1] = RPC then
      begin
        // 是已经处理后的双 |
        if I < Result then // 如果双 || 的位置在单 | 前，则替换双 | 为单 | 时要减去相应的字符数
          Inc(Dif);
      end
      else
      begin
        // 还有后续的单个 |，不记录位置，只替换成 #0
        S[I] := RPC;
      end;
    end;
  end;

  S := ReplaceAllInString(S, RPC, ''); // 替换掉所有的 #0
  if (Result > 0) and (Dif > 0) then
    Dec(Result, Dif);
end;

//==============================================================================
// 符号列表基类
//==============================================================================

{ TSymbolList }

const
  csXmlRoot = 'Symbols';
  csXmlItem = 'Item';

function SaveListToXMLFile(List: TSymbolList; const FileName: string): Boolean;
var
  Doc: IXMLDocument;
  Root: IXMLElement;
  Node: IXMLElement;
  Writer: TOmniXMLWriterHack;
  I: Integer;
begin
  Result := False;
  if FileName <> '' then
  try
    Doc := CreateXMLDoc;
    Root := Doc.CreateElement(csXmlRoot);
    Doc.DocumentElement := Root;
    
    List.Sort;
    Writer := TOmniXMLWriterHack.Create(Doc);
    try
      for I := 0 to List.Count - 1 do
      begin
        Node := Doc.CreateElement(csXmlItem);
        Writer.Write(List.Items[I], Node, False);
        Root.AppendChild(Node);
      end;
    finally
      Writer.Free;
    end;
    Doc.Save(FileName, ofIndent);
    Result := True;
  except
    ;
  end;
end;

function LoadListFromXMLFile(List: TSymbolList; const FileName: string): Boolean;
var
  Doc: IXMLDocument;
  Root: IXMLElement;
  Item: TSymbolItem;
  I, Idx: Integer;
  Reader: TOmniXMLReaderHack;
begin
  Result := False;
  if FileExists(FileName) then
  try
    Doc := CreateXMLDoc;
    Doc.Load(FileName);
    Root := Doc.DocumentElement;
    if not Assigned(Root) or not SameText(Root.NodeName, csXmlRoot) then
      Exit;

    Reader := TOmniXMLReaderHack.Create(pfNodes);
    try
      for I := 0 to Root.ChildNodes.Length - 1 do
        if SameText(Root.ChildNodes.Item[I].NodeName, csXmlItem) then
        begin
          Item := TSymbolItem.Create;
          try
            Reader.Read(Item, Root.ChildNodes.Item[I] as IXmlElement);
            Item.MatchFirstOnly := Item.Kind in [skCompDirect, skComment];
            Idx := List.IndexOf(Item.Name, Item.Kind);
            if Idx < 0 then
              List.Add(Item)
            else
            begin
              List.Items[Idx].Assign(Item);
              Item.Free;
            end;
          except
            Item.Free;
          end;
        end;
    finally
      Reader.Free;
    end;
    Result := List.Count > 0;
  except
    ;
  end;
end;

// 调整优先值，减少重复值
procedure AdjustSymbolListScope(List: TSymbolList);
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    List.Items[I].FScope := RateToScope(List.Items[I].ScopeRate) + I;
end;

constructor TSymbolList.Create;
begin
  inherited;
  FList := TObjectList.Create;
  FActive := True;
  Load;
end;

destructor TSymbolList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TSymbolList.Add(AItem: TSymbolItem): Integer;
begin
  AItem.CalcHashCode;
  Result := FList.Add(AItem);
end;

function TSymbolList.Add(const AName: string; AKind: TSymbolKind; AScope:
  Integer; const ADescription: string = ''; const AText: string = ''; 
  AAutoIndent: Boolean = True; AMatchFirstOnly: Boolean = False; 
  AAlwaysDisp: Boolean = False; ADescIsUtf8: Boolean = False): Integer;
var
  Item: TSymbolItem;
begin
  Item := TSymbolItem.Create;
  Item.Name := AName;
  Item.Description := ADescription;
  if AText = '' then
    Item.Text := AName
  else
    Item.Text := AText;
  Item.Kind := AKind;
  Item.Scope := AScope;
  Item.AutoIndent := AAutoIndent;
  if not (Item.Kind in [Low(TSymbolKind)..High(TSymbolKind)]) then
    Item.Kind := skUnknown;
  Item.MatchFirstOnly := AMatchFirstOnly;
  Item.AlwaysDisp := AAlwaysDisp;
  Item.FDescIsUtf8 := ADescIsUtf8;
  Item.CalcHashCode;
  Result := FList.Add(Item);
end;

procedure TSymbolList.Clear;
begin
  FList.Clear;
end;

procedure TSymbolList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

procedure TSymbolList.Remove(AItem: TSymbolItem);
begin
  FList.Remove(AItem);
end;

function TSymbolList.IndexOf(const AName: string; AKind: TSymbolKind): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if (AKind = Items[I].Kind) and (CompareStr(Items[I].Name, AName) = 0) then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TSymbolList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSymbolList.GetItem(Index: Integer): TSymbolItem;
begin
  Result := TSymbolItem(FList[Index]);
end;

class function TSymbolList.GetListName: string;
begin
  Result := RemoveClassPrefix(ClassName);
end;

function TSymbolList.Reload(Editor: IOTAEditBuffer; const InputText: string;
  PosInfo: TCodePosInfo): Boolean;
begin
  Result := Count > 0;
end;

procedure TSymbolList.GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; 
  PosInfo: TCodePosInfo);
begin
  FirstSet := csIdentFirstSet;
  CharSet := csIdentCharSet;
end;

function TSymbolList.CanCustomize: Boolean;
begin
  Result := False;
end;

procedure TSymbolList.RestoreDefault;
begin

end;

function DoListSort(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TSymbolItem(Item1).Name, TSymbolItem(Item2).Name);
end;  

procedure TSymbolList.Sort;
begin
  FList.Sort(DoListSort);
end;

procedure TSymbolList.Load;
begin

end;

procedure TSymbolList.Save;
begin

end;

procedure TSymbolList.Reset;
begin

end;

//==============================================================================
// 自定义符号列表
//==============================================================================


{ TFileSymbolList }

function TFileSymbolList.CanCustomize: Boolean;
begin
  Result := True;
end;

function TFileSymbolList.GetDataFileName: string;
begin

end;

function TFileSymbolList.GetReadFileName: string;
begin
  Result := WizOptions.GetUserFileName(GetDataFileName, True);
end;

function TFileSymbolList.GetWriteFileName: string;
begin
  Result := WizOptions.GetUserFileName(GetDataFileName, False);
end;

procedure TFileSymbolList.Load;
begin
  Clear;
  LoadListFromXMLFile(Self, GetReadFileName);
{$IFDEF DEBUG}
  CnDebugger.LogMsg(ClassName + ' LoadFrom ' + GetReadFileName + '. Symbol Count ' + IntToStr(List.Count));
{$ENDIF}
  AdjustSymbolListScope(Self);
end;

function TFileSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkComment]) // ParsePasCodePosInfo(W) 判断位置不准的问题修复了，不用 Field
  else
    Result := PosInfo.PosKind in [pkField, pkComment];
end;

procedure TFileSymbolList.Reset;
begin
  RestoreDefault;
end;

procedure TFileSymbolList.RestoreDefault;
begin
  DeleteFile(WizOptions.UserPath + GetDataFileName);
  Load;
end;

procedure TFileSymbolList.Save;
begin
  SaveListToXMLFile(Self, GetWriteFileName);
  WizOptions.CheckUserFile(GetDataFileName);
end;

//==============================================================================
// 预定义符号列表
//==============================================================================

{ TPreDefSymbolList }

class function TPreDefSymbolList.GetListName: string;
begin
  Result := SCnInputHelperPreDefSymbolList;
end;

function TPreDefSymbolList.GetDataFileName: string;
begin
  Result := SCnPreDefSymbolsFile;
end;

{ TUserTemplateList }

class function TUserTemplateList.GetListName: string;
begin
  Result := SCnInputHelperUserTemplateList;
end;

function TUserTemplateList.GetDataFileName: string;
begin
  Result := SCnCodeTemplateFile;
end;

//==============================================================================
// 编译指令符号列表
//==============================================================================

{ TCompDirectSymbolList }

procedure TCompDirectSymbolList.GetValidCharSet(var FirstSet, 
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csCompDirectFirstSet;
  CharSet := csCompDirectCharSet;
end;

procedure TCompDirectSymbolList.AddSection(Ini: TMemIniFile; const Section: string);
var
  Names: TStringList;
  I, Idx: Integer;
  Desc: string;
begin
  Names := TStringList.Create;
  try
    Ini.ReadSection(Section, Names);
    for I := 0 to Names.Count - 1 do
    begin
      Desc := Trim(Ini.ReadString(Section, Names[I], ''));
      Idx := Add(Names[I], skCompDirect, csCompDirectScope, Desc, Names[I], True, True);
      if Names[I][1] = '#' then // # 开头的是 C/C++ 的
      begin
        Items[Idx].ForPascal := False;
        Items[Idx].ForCpp := True;
      end;
    end;
  finally
    Names.Free;
  end;
end;

procedure TCompDirectSymbolList.Load;
var
  Ini: TMemIniFile;
begin
  Clear;
  Ini := TMemIniFile.Create(WizOptions.DataPath + SCnCompDirectDataFile);
  try
  {$IFDEF DELPHI5_UP} AddSection(Ini, csCompD5); {$ENDIF}
  {$IFDEF DELPHI6_UP} AddSection(Ini, csCompD6); {$ENDIF}
  {$IFDEF DELPHI7_UP} AddSection(Ini, csCompD7); {$ENDIF}

  {$IFDEF DELPHI2005_UP} AddSection(Ini, csCompD2005); {$ENDIF}
  {$IFDEF DELPHI2006_UP} AddSection(Ini, csCompD2006); {$ENDIF}
  {$IFDEF DELPHI2007_UP} AddSection(Ini, csCompD2007); {$ENDIF}
  {$IFDEF DELPHI2009_UP} AddSection(Ini, csCompD2009); {$ENDIF}
  {$IFDEF DELPHI2010_UP} AddSection(Ini, csCompD2010); {$ENDIF}
  {$IFDEF DELPHIXE_UP} AddSection(Ini, csCompDXE); {$ENDIF}
  {$IFDEF DELPHIXE2_UP} AddSection(Ini, csCompDXE2); {$ENDIF}
  {$IFDEF DELPHIXE3_UP} AddSection(Ini, csCompDXE3); {$ENDIF}
  {$IFDEF DELPHIXE4_UP} AddSection(Ini, csCompDXE4); {$ENDIF}
  {$IFDEF DELPHIXE5_UP} AddSection(Ini, csCompDXE5); {$ENDIF}
  {$IFDEF DELPHIXE6_UP} AddSection(Ini, csCompDXE6); {$ENDIF}
  {$IFDEF DELPHIXE7_UP} AddSection(Ini, csCompDXE7); {$ENDIF}
  {$IFDEF DELPHIXE8_UP} AddSection(Ini, csCompDXE8); {$ENDIF}
  {$IFDEF DELPHI10_SEATTLE_UP} AddSection(Ini, csCompD10S); {$ENDIF}
  {$IFDEF DELPHI101_BERLIN_UP} AddSection(Ini, csCompD101B); {$ENDIF}
  {$IFDEF DELPHI102_TOKYO_UP} AddSection(Ini, csCompD102T); {$ENDIF}
  {$IFDEF DELPHI103_RIO_UP} AddSection(Ini, csCompD103R); {$ENDIF}
  {$IFDEF DELPHI104_SYDNEY_UP} AddSection(Ini, csCompD104S); {$ENDIF}
  {$IFDEF DELPHI110_ALEXANDRIA_UP} AddSection(Ini, csCompD110A); {$ENDIF}
  {$IFDEF DELPHI120_ATHENS_UP} AddSection(Ini, csCompD120A); {$ENDIF}

   AddSection(Ini, csCompBCB); // 加进来并设为C/C++专用的再说
  finally
    Ini.Free;
  end;
  AdjustSymbolListScope(Self);
end;

function TCompDirectSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkIntfUses, pkImplUses, pkField])
  else
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkField]);
end;

procedure TCompDirectSymbolList.Save;
begin
  // do nothing
end;

class function TCompDirectSymbolList.GetListName: string;
begin
  Result := SCnInputHelperCompDirectSymbolList;
end;

//==============================================================================
// 用户自定义符号列表
//==============================================================================

{ TUserSymbolList }

class function TUserSymbolList.GetListName: string;
begin
  Result := SCnInputHelperUserSymbolList;
end;

function TUserSymbolList.GetDataFileName: string;
begin
  Result := SCnUserSymbolsFile;
end;

procedure TUserSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csIdentFirstSet + csCompDirectFirstSet + csCommentFirstSet;
  CharSet := csIdentCharSet + csCompDirectCharSet + csCommentCharSet;
end;

//==============================================================================
// XML 注释列表
//==============================================================================

{ TXMLCommentSymbolList }

class function TXMLCommentSymbolList.GetListName: string;
begin
  Result := SCnInputHelperXMLCommentList;
end;

function TXMLCommentSymbolList.GetDataFileName: string;
begin
  Result := SCnXmlCommentDataFile;
end;

procedure TXMLCommentSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csCommentFirstSet;
  CharSet := csCommentCharSet; 
end;

function TXMLCommentSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  Result := PosInfo.PosKind in (csNormalPosKinds + [pkComment]);
end;

//==============================================================================
// JavaDoc 注释列表
//==============================================================================

{ TJavaDocSymbolList }

class function TJavaDocSymbolList.GetListName: string;
begin
  Result := SCnInputHelperJavaDocList;
end;

function TJavaDocSymbolList.GetDataFileName: string;
begin
  Result := SCnJavaDocDataFile;
end;

procedure TJavaDocSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  if PosInfo.PosKind in [pkComment] then
  begin
    FirstSet := csJavaDocFirstSet + csJavaDocTagFirstSet;
  end
  else
  begin
    FirstSet := csJavaDocFirstSet;
  end;
  CharSet := csJavaDocCharSet;
end;

function TJavaDocSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  Result := PosInfo.PosKind in [pkComment, pkField]; // Pascal/C/C++ 
end;

//==============================================================================
// 在 uses 中使用的单元名称列表
//==============================================================================

{ TUnitNameList }

constructor TUnitNameList.Create(UseFullPath: Boolean; IsCppMode: Boolean;
  LoadAfterCreate: Boolean);
begin
  FUseFullPath := UseFullPath;
  FCppMode := IsCppMode;
  FLoadAfterCreate := LoadAfterCreate;
  Create;
end;

constructor TUnitNameList.Create;
begin
  inherited;
  FSysUnitsName := TStringList.Create;
  FSysUnitsPath := TStringList.Create;
  FProjectUnitsName := TStringList.Create;
  FProjectUnitsPath := TStringList.Create;
  FUnitNames := TStringList.Create;
  FUnitPaths := TStringList.Create;
  FCurrFileList := nil;
  FCurrPathList := nil;
  FSysUnitsName.Sorted := not FUseFullPath;
  FProjectUnitsName.Sorted := not FUseFullPath;
  FUnitNames.Sorted := not FUseFullPath;

  if FLoadAfterCreate then
    LoadFromSysPath;
end;

destructor TUnitNameList.Destroy;
begin
  FProjectUnitsPath.Free;
  FProjectUnitsName.Free;
  FSysUnitsPath.Free;
  FSysUnitsName.Free;
  FUnitPaths.Free;
  FUnitNames.Free;
  inherited;
end;

class function TUnitNameList.GetListName: string;
begin
  Result := SCnInputHelperUnitNameList;
end;

function TUnitNameList.AddUnit(const UnitName: string; IsInProject: Boolean): Boolean;
begin
  Result := False;
  if FUnitNames.IndexOf(UnitName) < 0 then
  begin
    if IsInProject then
      FUnitNames.AddObject(UnitName, TObject(Integer(IsInProject)))
    else
      FUnitNames.Add(UnitName);

    Add(UnitName, skUnit, csUnitScope);
    Result := True;
  end;
end;

procedure TUnitNameList.AddUnitFullNameWithPath(const UnitFullName: string);
begin
  FUnitPaths.Add(UnitFullName);
  // 必须允许重复
end;

procedure TUnitNameList.LoadFromCurrProject;
var
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
  FileName: string;
  I, J: Integer;
  Added: Boolean;
begin
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
  begin
    for I := 0 to ProjectGroup.GetProjectCount - 1 do
    begin
      Project := ProjectGroup.Projects[I];
      if Assigned(Project) then
      begin
        for J := 0 to Project.GetModuleCount - 1 do
        begin
          FileName := Project.GetModule(J).FileName;

          if FCppMode then
          begin
            FileName := _CnChangeFileExt(FileName, '.h');
            if FileExists(FileName) or CnOtaIsFileOpen(FileName) then
            begin
              Added := AddUnit(_CnExtractFileName(FileName), True);

              if FUseFullPath and Added then
                AddUnitFullNameWithPath(FileName);
            end
            else
            begin
              FileName := _CnChangeFileExt(FileName, '.hpp');
              if FileExists(FileName) or CnOtaIsFileOpen(FileName) then
              begin
                Added := AddUnit(_CnExtractFileName(FileName), True);

                if FUseFullPath and Added then
                  AddUnitFullNameWithPath(FileName);
              end;
            end;
          end
          else
          begin
            if IsPas(FileName) or IsDcu(FileName) then
            begin
              Added := AddUnit(_CnChangeFileExt(_CnExtractFileName(FileName), ''), True);

              if FUseFullPath and Added then
                AddUnitFullNameWithPath(FileName);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TUnitNameList.DoFindFile(const FileName: string; const Info:
  TSearchRec; var Abort: Boolean);
var
  FilePart: string;
begin
  if FCppMode then // C 中 include 的需要扩展名
    FilePart := Info.Name
  else
    FilePart := _CnChangeFileExt(Info.Name, '');

  if IsValidIdent(StringReplace(FilePart, '.', '', [rfReplaceAll])) and (FCurrFileList.IndexOf(FilePart) < 0) then
  begin
    // 加入指示对应路径在 FCurrPathList 中的位置，供排序后对应使用
    FCurrFileList.AddObject(FilePart, TObject(FCurrFileList.Count));

    if FUseFullPath then
      FCurrPathList.Add(FileName);
  end;
end;

procedure TUnitNameList.LoadFromSysPath;
var
  I: Integer;
  Paths: TStringList;
  Added: Boolean;
begin
  Paths := TStringList.Create;
  try
    Paths.Sorted := True;
    GetLibraryPath(Paths, False);
    if not SameText(Paths.Text, FSysPath) then
    begin
      FSysUnitsName.Clear;
      FSysUnitsPath.Clear;
      FCurrFileList := FSysUnitsName;
      FCurrPathList := FSysUnitsPath;

      if FCppMode then
      begin
        for I := 0 to Paths.Count - 1 do
        begin
          FindFile(Paths[I], '*.h*', DoFindFile, nil, False, False);
          // FindFile(Paths[I], '*.h', DoFindFile, nil, False, False);
        end;
        FindFile(MakePath(GetInstallDir) + 'Include\', '*.h*', DoFindFile, nil,
          False, False);
      end
      else
      begin
        for I := 0 to Paths.Count - 1 do
        begin
          FindFile(Paths[I], '*.pas', DoFindFile, nil, False, False);
          FindFile(Paths[I], '*.dcu', DoFindFile, nil, False, False);
        end;
        FindFile(MakePath(GetInstallDir) + 'Lib\', '*.dcu', DoFindFile, nil,
          False, False);
      end;

      CorrectCaseFromIdeModules(FSysUnitsName, FCppMode);
      UpdatePathsSequence(FSysUnitsName, FSysUnitsPath);
      FSysPath := Paths.Text;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('SysNames %d. SysPaths %d.', [FSysUnitsName.Count,
        FSysUnitsPath.Count]);
{$ENDIF}
    end;
  finally
    Paths.Free;
  end;

  for I := 0 to FSysUnitsName.Count - 1 do
  begin
    Added := AddUnit(FSysUnitsName[I]);
    if FUseFullPath and Added then
      AddUnitFullNameWithPath(FSysUnitsPath[I]);
  end;
end;

procedure TUnitNameList.LoadFromProjectPath;
var
  I: Integer;
  Paths: TStringList;
  Added: Boolean;
begin
  Paths := TStringList.Create;
  try
    Paths.Sorted := True;
    GetProjectLibPath(Paths);
    if not SameText(Paths.Text, FProjectPath) then
    begin
      FProjectUnitsName.Clear;
      FProjectUnitsPath.Clear;
      FCurrFileList := FProjectUnitsName;
      FCurrPathList := FProjectUnitsPath;

      if FCppMode then
      begin
        for I := 0 to Paths.Count - 1 do
        begin
          FindFile(Paths[I], '*.h*', DoFindFile, nil, False, False);
          // FindFile(Paths[I], '*.h', DoFindFile, nil, False, False);
        end;
      end
      else
        for I := 0 to Paths.Count - 1 do
          FindFile(Paths[I], '*.pas', DoFindFile, nil, False, False);

      CorrectCaseFromIdeModules(FProjectUnitsName, FCppMode);
      UpdatePathsSequence(FProjectUnitsName, FProjectUnitsPath);
      FProjectPath := Paths.Text;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('ProjNames %d. ProjPaths %d.', [FProjectUnitsName.Count,
        FProjectUnitsPath.Count]);
{$ENDIF}
    end;
  finally
    Paths.Free;
  end;

  for I := 0 to FProjectUnitsName.Count - 1 do
  begin
    Added := AddUnit(FProjectUnitsName[I]);
    if FUseFullPath and Added then
      AddUnitFullNameWithPath(FProjectUnitsPath[I]);
  end;
end;

// 上面更新大小写时会影响排序，此处根据预先记录的下标更新对应的路径
procedure TUnitNameList.UpdatePathsSequence(Names, Paths: TStringList);
var
  I, Idx: Integer;
  List: TStringList;
begin
  if not FUseFullPath or (Names.Count <> Paths.Count) then
    Exit;

  List := TStringList.Create;
  try
    for I := 0 to Names.Count - 1 do
    begin
      Idx := Integer(Names.Objects[I]);
      List.Add(Paths[Idx]);
    end;
    Paths.Assign(List);
  finally
    List.Free;
  end;
end;

function TUnitNameList.Reload(Editor: IOTAEditBuffer; const InputText: string;
  PosInfo: TCodePosInfo): Boolean;
begin
  Result := False;
  try
    if PosInfo.IsPascal and (PosInfo.PosKind in [pkIntfUses, pkImplUses, pkVarType,
      pkProcedure, pkFunction, pkConstructor, pkDestructor]) then
    begin
      DoInternalLoad;
      AdjustSymbolListScope(Self);
      Result := True;
    end;
  except
    ;
  end;
end;

procedure TUnitNameList.DoInternalLoad(IncludePath: Boolean);
begin
  FUnitNames.Clear;
  FUnitPaths.Clear;
  Clear;
  LoadFromCurrProject;
  if IncludePath then
  begin
    LoadFromSysPath;
    LoadFromProjectPath;
  end;
end;

procedure TUnitNameList.ExportToStringList(Names, Paths: TStringList);
begin
  if Names <> nil then
    Names.Assign(FUnitNames);

  if Paths <> nil then
    Paths.Assign(FUnitPaths);
end;

//==============================================================================
// 当前单元引用的单元名称列表
//==============================================================================

{ TUnitUsesList }

class function TUnitUsesList.GetListName: string;
begin
  Result := SCnInputHelperUnitUsesList;
end;

function TUnitUsesList.Reload(Editor: IOTAEditBuffer; const InputText: string;
  PosInfo: TCodePosInfo): Boolean;
const
  csMaxProcessLines = 30000;
var
  View: IOTAEditView;
  Stream: TMemoryStream;
  UsesList: TStringList;
  I: Integer;
{$IFNDEF IDE_SYMBOL_HAS_SYSTEM}
  SysAdded: Boolean;
{$ENDIF}
begin
  Result := False;
  try
    Clear;
    View := CnOtaGetTopMostEditView;
    Result := (PosInfo.PosKind in csNormalPosKinds) and Assigned(View) and
      (View.Buffer.GetLinesInBuffer <= csMaxProcessLines);
    if Result then
    begin
      Stream := TMemoryStream.Create;
      try
        CnOtaSaveCurrentEditorToStream(Stream, False);
        UsesList := TStringList.Create;
        try
          ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);

{$IFNDEF IDE_SYMBOL_HAS_SYSTEM}
          SysAdded := False;
{$ENDIF}
          for I := 0 to UsesList.Count - 1 do
          begin
            Add(UsesList[I], skUnit, csUsesScope);

{$IFNDEF IDE_SYMBOL_HAS_SYSTEM}
            if not SysAdded and (UsesList[I] = 'SysUtils') then
            begin
              Add('System', skUnit, csUsesScope, '');
              SysAdded := True;
            end;
{$ENDIF}
          end;
          AdjustSymbolListScope(Self);
        finally
          UsesList.Free;
        end;
      finally
        Stream.Free;
      end;
    end;
  except
    ;
  end;          
end;

//==============================================================================
// 代码模板列表
//==============================================================================

{ TCodeTemplateList }

procedure TCodeTemplateList.Load;
var
  Lines: TStringList;
  StrList: TStringList;
  I, Idx: Integer;
  FileName: string;
  Text: string;
  Line: string;
  Name: string;
  Desc: string;
  LangName: string;
  IsPascal: Boolean;
  IsCpp: Boolean;

  function IsTempleteCaption(const AText: string): Boolean;
  begin
    Result := (AText <> '') and (AText[1] = '[') and (AText[Length(AText)] = ']');
  end;
begin
  FileName := GetReadFileName;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCodeTemplateList.Load: ' + FileName);
{$ENDIF}
  if FileExists(FileName) and (FileAge(FileName) <> FFileAge) then
  begin
    Clear;
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(FileName);
    {$IFDEF DEBUG}
      CnDebugger.LogStrings(Lines, 'Lines');
    {$ENDIF}

      I := 0;
      while I < Lines.Count - 1 do
      begin
        Line := Lines[I];
        if IsTempleteCaption(Line) then
        begin
          // 取出模板名称、描述及语言
          Line := Copy(Line, 2, Length(Line) - 2); // 删除两边的 [] 号
          StrList := TStringList.Create;
          try
            Line := StringReplace(Line, ' | ', CRLF, [rfReplaceAll]);
            StrList.Text := StringReplace(Line, '|', CRLF, [rfReplaceAll]);
            Name := '';
            Desc := '';
            LangName := '';
            if StrList.Count > 0 then
              Name := StrList[0];
            if StrList.Count > 1 then
              Desc := StrList[1];
            if StrList.Count > 2 then
              LangName := Trim(StrList[2]);
          finally
            StrList.Free;
          end;

          // 取出模板内容
          Text := '';
          Inc(I);
          while (I < Lines.Count - 1) and not IsTempleteCaption(Lines[I]) do
          begin
            if Text <> '' then
              Text := Text + CRLF;
            Text := Text + Lines[I];
            Inc(I);
          end;

          IsPascal := False;
          IsCpp := False;
          if Name <> '' then
          begin
            Idx := Add(Name, skTemplate, csTemplateScope, Desc, Text, True);
            if LangName = '' then
            begin
              // 自动判断类型
{$IFNDEF DELPHI} // 说明是 BCB5、6编译
              IsPascal := False;
              IsCpp := True;
{$ELSE}
              IsPascal := True;
              IsCpp := False;
{$ENDIF}
            end
            else if SameText(LangName, 'Borland.EditOptions.Pascal') then
            begin
              IsPascal := True;
              IsCpp := False;
            end
            else if SameText(LangName, 'Borland.EditOptions.C') then
            begin
              IsPascal := False;
              IsCpp := True;
            end;
            Items[Idx].ForPascal := IsPascal;
            Items[Idx].ForCpp := IsCpp;
          end;
        end
        else
          Inc(I);
      end;
    finally
      Lines.Free;
    end;
    FFileAge := FileAge(FileName);
  end;
end;

function TCodeTemplateList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in csNormalPosKinds // ParsePasCodePosInfo(W) 判断位置不准的问题修复了，不用 Field
  else
    Result := PosInfo.PosKind in [pkField, pkComment];

  if Result then
  begin
    Load;
  end;
end;

//==============================================================================
// IDE 自带的代码模板列表
//==============================================================================

{ TIDECodeTemplateList }

class function TIDECodeTemplateList.GetListName: string;
begin
  Result := SCnInputHelperIDECodeTemplateList;
end;

function TIDECodeTemplateList.GetReadFileName: string;
begin
{$IFDEF BDS}
  // C:\Documents and Settings\Administrator\Local Settings\Application Data\Borland\BDS\3.0\bds.dci
  Result := MakePath(GetBDSUserDataDir) + 'bds.dci';
  // c:\Program Files\CodeGear\RAD Studio\5.0\ObjRepos\bds.dci
  if not FileExists(Result) then
    Result := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName)) + 'ObjRepos\bds.dci';
  FForBcb := True;
  FForPascal := True;
{$ELSE}
{$IFDEF BCB}
  Result := _CnExtractFilePath(Application.ExeName) + 'bcb.dci';
  FForBcb := True;
{$ELSE}
  Result := _CnExtractFilePath(Application.ExeName) + 'delphi32.dci';
  FForPascal := True;
{$ENDIF}
{$ENDIF}
end;

//==============================================================================
// 符号列表管理器
//==============================================================================

{ TSymbolListMgr }

var
  SymbolListClassList: TClassList;

procedure RegisterSymbolList(AClass: TSymbolListClass);
begin
  if SymbolListClassList = nil then
    SymbolListClassList := TClassList.Create;
  if SymbolListClassList.IndexOf(AClass) < 0 then
    SymbolListClassList.Add(AClass);
end;

constructor TSymbolListMgr.Create;
begin
  inherited;
  FList := TObjectList.Create;
end;

destructor TSymbolListMgr.Destroy;
begin
  FList.Free;
  inherited;
end;

function TSymbolListMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSymbolListMgr.GetList(Index: Integer): TSymbolList;
begin
  Result := TSymbolList(FList[Index]);
end;

procedure TSymbolListMgr.InitList;
var
  I: Integer;
begin
  FList.Clear;
  if SymbolListClassList <> nil then
  begin
    for I := 0 to SymbolListClassList.Count - 1 do
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Create SymbolList: ' + SymbolListClassList[I].ClassName);
    {$ENDIF}
      try
        FList.Add(TSymbolListClass(SymbolListClassList[I]).Create);
      except
      {$IFDEF DEBUG}
        on E: Exception do
          CnDebugger.LogMsg('Create SymbolList Error: ' + E.Message);
      {$ENDIF}
      end;
    end;
  end;
end;

procedure TSymbolListMgr.GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet; 
  PosInfo: TCodePosInfo);
var
  I: Integer;
  F, C: TAnsiCharSet;
begin
  FirstSet := [];
  CharSet := [];
  for I := 0 to Count - 1 do
  begin
    if List[I].Active then
    begin
      List[I].GetValidCharSet(F, C, PosInfo);
      FirstSet := FirstSet + F;
      CharSet := CharSet + C;
    end;
  end;
end;

function TSymbolListMgr.ListByClass(AClass: TSymbolListClass): TSymbolList;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if List[I].ClassType = AClass then
    begin
      Result := List[I];
      Exit;
    end;
  end;
end;

procedure TSymbolListMgr.Load;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Load;
end;

procedure TSymbolListMgr.Save;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Save;
end;

procedure TSymbolListMgr.Reset;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Reset;
end;

{$IFDEF OTA_CODE_TEMPLATE_API}

{ TIDEModernCodeTemplateList }

class function TIDEModernCodeTemplateList.GetListName: string;
begin
  Result := SCnInputHelperIDECodeTemplateList;
end;

function TIDEModernCodeTemplateList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
var
  I, Idx: Integer;
  CT: IOTACodeTemplate;
  CTS: IOTACodeTemplateServices;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in csNormalPosKinds // ParsePasCodePosInfo(W) 判断位置不准的问题修复了，不用 Field
  else
    Result := PosInfo.PosKind in [pkField, pkComment];

  if not Result then
    Exit;

  if not QuerySvcs(BorlandIDEServices, IOTACodeTemplateServices, CTS) then
    Exit;

  if CTS <> nil then
  begin
    Clear;
    for I := 0 to CTS.CodeObjectCount - 1 do
    begin
      CT := CTS.CodeObjects[I];
      if CT = nil then // IDE 设置损坏时有可能缺失
        Continue;

      if (PosInfo.IsPascal and (CT.Language = 'Delphi')) or
        (not PosInfo.IsPascal and (CT.Language = 'C++')) then
      begin
        Idx := Add(CT.Shortcut, skTemplate, csTemplateScope, CT.Description,
          CT.Code);

        Items[Idx].FForPascal := PosInfo.IsPascal;
        Items[Idx].FForCpp := not PosInfo.IsPascal;
        Items[Idx].CodeTemplateIndex := I;
      end;
    end;
  end;
end;

{$ENDIF}

initialization
  RegisterSymbolList(TPreDefSymbolList);
  RegisterSymbolList(TUserTemplateList);
  RegisterSymbolList(TCompDirectSymbolList);
  RegisterSymbolList(TXMLCommentSymbolList);
  RegisterSymbolList(TJavaDocSymbolList);
  RegisterSymbolList(TUnitNameList);
  RegisterSymbolList(TUnitUsesList);
{$IFDEF OTA_CODE_TEMPLATE_API}
  RegisterSymbolList(TIDEModernCodeTemplateList);
{$ELSE}
  RegisterSymbolList(TIDECodeTemplateList);
{$ENDIF}
  RegisterSymbolList(TUserSymbolList);

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnInputSymbolList finalization.');
{$ENDIF}

  FreeAndNil(SymbolListClassList);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnInputSymbolList finalization.');
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.

