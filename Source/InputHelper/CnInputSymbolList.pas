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

unit CnInputSymbolList;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��������ֵ����б��ඨ�嵥Ԫ
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע�������б��ඨ��
* ����ƽ̨��PWin2000Pro + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.02.13 by liuxiao
*               ģ��������������������� || ����һ�� | �ţ������� | ���Դ�����λ��
*           2016.03.15 by liuxiao
*               TUnitNameList ����·�������� h/hpp ֧�ֹ��ⲿʹ��
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2012.03.26
*               ���Ӷ� XE/XE2 ���е� XML ��ʽ��ģ���֧�֣��в������ݼ�������
*           2004.11.05
*               ��ֲ����
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$IFDEF BDS}
  {$DEFINE IDE_SYMBOL_HAS_SYSTEM} // 2005 �����ϣ������б����� System ��Ԫ
{$ENDIF}

uses
  Windows, SysUtils, Classes, Controls, IniFiles, ToolsApi, Psapi, Math,
  Forms, Graphics, Contnrs, TypInfo,
  {$IFDEF OTA_CODE_TEMPLATE_API} CodeTemplateAPI, {$ENDIF}
  CnCommon, CnWizConsts, CnWizOptions,
  CnWizUtils, CnWizIdeUtils, CnPasCodeParser, OmniXML, OmniXMLPersistent,
  OmniXMLUtils, CnWizMacroUtils, CnWizIni;

const
  CN_CODE_TEMPLATE_INDEX_INVALID = -1;

type

//==============================================================================
// ��������
//==============================================================================

  TCnSymbolKind = (skUnknown, skConstant, skType, skVariable, skProcedure,
    skFunction, skUnit, skLabel, skProperty, skConstructor, skDestructor,
    skInterface, skEvent, skKeyword, skClass, skTemplate, skCompDirect,
    skComment, skUser);
  {* �������� }

  TCnSymbolKindSet = set of TCnSymbolKind;
  {* �������ͼ��� }

  TCnKeywordStyle = (ksDefault, ksLower, ksUpper, ksFirstUpper);
  {* �ؼ��ִ�Сд��ʽ }

{ TCnSymbolItem }

  TCnSymbolItem = class(TPersistent)
  {* ���ڴ�������ķ����� }
  private
    FDescription: string;
    FDescIsUtf8: Boolean;
    FKind: TCnSymbolKind;
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
    {* ���������ı��е� | �ţ����ص�һ������ | �ŵ�ƫ���������򷵻� -1������ S �е����� || �滻�ɵ��� |}
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
    {* ����ı�������༭�� }
    function GetKeywordText(KeywordStyle: TCnKeywordStyle): string;
    {* ��ָ�����ȡ�ؼ����ı� }

    property HashCode: Cardinal read FHashCode write FHashCode;
    {* ��ʶ�������͵� HashCode ��Ϣ }
    property Tag: Integer read FTag write FTag;
    {* ����������ʹ�õ����ݣ�������ʱ������ʱ�������ݣ�����ģ��ƥ���ƥ������� }
    property ScopeHit: Integer read FScopeHit write FScopeHit;
    {* ʹ��Ƶ�����ȼ����������������� }
    property ScopeAdjust: Integer read FScopeAdjust write FScopeAdjust;
    {* ����ʹ��Ƶ�ȵ�����������ȼ����������������� }

    property Scope: Integer read FScope write FScope;
    {* ���ŵ����ȼ���0..MaxInt��ԽС��ʾԽ��ǰ }
    property MatchFirstOnly: Boolean read FMatchFirstOnly write FMatchFirstOnly;
    {* �Ƿ�Ҫ���ͷ��ʼƥ�� }
    property AllowMultiLine: Boolean read GetAllowMultiLine;
    {* ��������ı� }
    property FuzzyMatchIndexes: TList read FFuzzyMatchIndexes;
    {* ģ��ƥ��ʱ�����洢ƥ���±���б� }
  published
    property Name: string read FName write FName;
    {* ���ŵ����ƣ����û�������ַ��� }
    property Kind: TCnSymbolKind read FKind write FKind;
    {* ���ŵ����� }
    property Description: string read GetDescription write FDescription;
    {* ���ŵ���������ʾ���б��� }
    property Text: string read GetText write FText;
    {* ʵ�����������༭�����ı� }
    property ScopeRate: Integer read GetScopeRate write SetScopeRate;
    {* ���ŵ����ȼ���0..100��ԽС��ʾԽ��ǰ }
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    {* ����Ƕ����ı�ʱ���Ƿ��Զ��������� }
    property AlwaysDisp: Boolean read FAlwaysDisp write FAlwaysDisp;
    {* �����ı�ȫƥ��ʱ���������� }
    property ForPascal: Boolean read FForPascal write FForPascal;
    {* �Ƿ��� Pascal ����Ч}
    property ForCpp: Boolean read FForCpp write FForCpp;
    {* �Ƿ��� C/C++ ����Ч}
    property CodeTemplateIndex: Integer read FCodeTemplateIndex write FCodeTemplateIndex;
    {* ������Ŀָ��һ IDE �Ĵ���ģ��ʱ���洢�������ţ����� -1}
  end;

//==============================================================================
// �����б����
//==============================================================================

{ TCnSymbolList }

  TCnSymbolList = class(TObject)
  private
    FList: TObjectList; // ���з��Ŷ����ʵ����
    FActive: Boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCnSymbolItem;
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
    function Add(AItem: TCnSymbolItem): Integer; overload; virtual;
    function Add(const AName: string; AKind: TCnSymbolKind; AScope: Integer; const
      ADescription: string = ''; const AText: string = ''; AAutoIndent: Boolean =
      True; AMatchFirstOnly: Boolean = False; AAlwaysDisp: Boolean = False;
      ADescIsUtf8: Boolean = False): Integer; overload; virtual;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure Remove(AItem: TCnSymbolItem);
    function IndexOf(const AName: string; AKind: TCnSymbolKind): Integer;
    function CanCustomize: Boolean; virtual;
    procedure RestoreDefault; virtual;

    procedure Cancel; virtual;
    {* �����첽ʱ����ֹ����ͨ�������ʵ��}

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCnSymbolItem read GetItem;
    property Active: Boolean read FActive write FActive;
  end;

  TCnSymbolListClass = class of TCnSymbolList;

//==============================================================================
// �Զ�������б�
//==============================================================================

{ TCnFileSymbolList }

  TCnFileSymbolList = class(TCnSymbolList)
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
// Ԥ��������б������ؼ����벿����������
//==============================================================================

{ TCnPreDefSymbolList }

  TCnPreDefSymbolList = class(TCnFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

//==============================================================================
// Ԥ��������б�
//==============================================================================

{ TCnUserTemplateList }

  TCnUserTemplateList = class(TCnFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
  end;

//==============================================================================
// �û���������б�
//==============================================================================

{ TCnUserSymbolList }

  TCnUserSymbolList = class(TCnFileSymbolList)
  protected
    function GetDataFileName: string; override;
  public
    class function GetListName: string; override;
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet;
      PosInfo: TCodePosInfo); override;
  end;

//==============================================================================
// XML ע���б�
//==============================================================================

{ TCnXMLCommentSymbolList }

  TCnXMLCommentSymbolList = class(TCnFileSymbolList)
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
// JavaDoc ע���б�
//==============================================================================

{ TCnJavaDocSymbolList }

  TCnJavaDocSymbolList = class(TCnFileSymbolList)
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
// ����ָ������б�
//==============================================================================

{ TCnCompDirectSymbolList }

  TCnCompDirectSymbolList = class(TCnSymbolList)
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
// �� uses ��ʹ�õĵ�Ԫ�����б�
//==============================================================================

{ TCnUnitNameList }

  TCnUnitNameList = class(TCnSymbolList)
  private
    FUseFullPath: Boolean;
    FCppMode: Boolean;
    FLoadAfterCreate: Boolean;
    FSysPath: string;
    FSysUnitsName: TStringList;
    FSysUnitsPath: TStringList;
    FProjectPath: string;
    FProjectUnitsName: TStringList;
    FProjectUnitsPath: TStringList;  // �⼸�� Path StringList �洢�Ķ��Ǵ�·���������ļ���
    FUnitNames: TStringList;   // �洢�������ļ���
    FUnitPaths: TStringList;   // FUseFullPath Ϊ True ʱ�洢��Ӧ�İ���·����������Ԫ��
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
    // ����������չ�����ļ����Լ�������·�����ļ���������ⲿ�б�
  end;

//==============================================================================
// ��ǰ��Ԫ���õĵ�Ԫ�����б�
//==============================================================================

{ TCnUnitUsesList }

  TCnUnitUsesList = class(TCnSymbolList)
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

//==============================================================================
// ����ģ���б�
//==============================================================================

{ TCnCodeTemplateList }

  TCnCodeTemplateList = class(TCnSymbolList)
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
// IDE �Դ��Ĵ���ģ���б�
//==============================================================================

{ TCnIDECodeTemplateList }

  TCnIDECodeTemplateList = class(TCnCodeTemplateList)
  protected
    function GetReadFileName: string; override;
  public
    class function GetListName: string; override;
  end;

{$IFDEF OTA_CODE_TEMPLATE_API}

  TCnIDEModernCodeTemplateList = class(TCnSymbolList)
  public
    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;
  end;

{$ENDIF}

//==============================================================================
// �����б������
//==============================================================================

{ TCnSymbolListMgr }

  TCnSymbolListMgr = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetList(Index: Integer): TCnSymbolList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitList;
    procedure Reset;
    procedure Cancel; // ֻ��֧�� LSP �������� LSP ���첽ģʽ�µ���
    procedure GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet;
      PosInfo: TCodePosInfo);
    function ListByClass(AClass: TCnSymbolListClass): TCnSymbolList;
    procedure Load;
    procedure Save;
    property List[Index: Integer]: TCnSymbolList read GetList;
    property Count: Integer read GetCount;
  end;

function GetSymbolKindName(Kind: TCnSymbolKind): string;
{* ���ط������͵����� }

function ScopeToRate(Scope: Integer): Integer;
function RateToScope(Rate: Integer): Integer;

function SaveListToXMLFile(List: TCnSymbolList; const FileName: string): Boolean;
function LoadListFromXMLFile(List: TCnSymbolList; const FileName: string): Boolean;

procedure RegisterSymbolList(AClass: TCnSymbolListClass);
{* ע��һ�������б��� }

const
  csDefScopeRate = 15;
  csIdentFirstSet: TAnsiCharSet = CN_ALPHA_CHARS;
  csIdentCharSet: TAnsiCharSet = CN_ALPHANUMERIC;
  csCompDirectFirstSet: TAnsiCharSet = ['{'];
  csCompDirectCharSet: TAnsiCharSet = ['$', '+', '-'] + CN_ALPHANUMERIC;
  csCppCompDirectFirstSet: TAnsiCharSet = ['#'];
  csCppCompDirectCharSet: TAnsiCharSet = CN_ALPHANUMERIC;
  csCommentFirstSet: TAnsiCharSet = ['/'];
  csCommentCharSet: TAnsiCharSet = ['/'] + CN_ALPHANUMERIC;
  csJavaDocFirstSet: TAnsiCharSet = ['{'];
  csJavaDocTagFirstSet: TAnsiCharSet = ['@'];
  csJavaDocCharSet: TAnsiCharSet = ['*', '-'] + CN_ALPHANUMERIC;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCRC32, CnWizMacroText, CnWizMacroFrm, mPasLex;

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

// ���ط������͵�����
function GetSymbolKindName(Kind: TCnSymbolKind): string;
begin
  Result := Copy(GetEnumName(TypeInfo(TCnSymbolKind), Ord(Kind)), 3, MaxInt);
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
// ��������
//==============================================================================

{ TCnSymbolItem }

constructor TCnSymbolItem.Create;
begin
  inherited;
  FScope := csDefScope;
  FAutoIndent := True;
  FAlwaysDisp := False;
  FForPascal := True;
  FCodeTemplateIndex := CN_CODE_TEMPLATE_INDEX_INVALID;
  FFuzzyMatchIndexes := TList.Create;
end;

procedure TCnSymbolItem.Assign(Source: TPersistent);
begin
  if Source is TCnSymbolItem then
  begin
    FDescription := TCnSymbolItem(Source).FDescription;
    FDescIsUtf8 := TCnSymbolItem(Source).FDescIsUtf8;
    FKind := TCnSymbolItem(Source).FKind;
    FName := TCnSymbolItem(Source).FName;
    FScope := TCnSymbolItem(Source).FScope;
    FScopeAdjust := TCnSymbolItem(Source).FScopeAdjust;
    FText := TCnSymbolItem(Source).FText;
    FTag := TCnSymbolItem(Source).FTag;
    FHashCode := TCnSymbolItem(Source).FHashCode;
    FMatchFirstOnly := TCnSymbolItem(Source).FMatchFirstOnly;
    FAutoIndent := TCnSymbolItem(Source).FAutoIndent;
  end
  else
    inherited;
end;

procedure TCnSymbolItem.CalcHashCode;
begin
  FHashCode := Ord(FKind);
  FHashCode := StrCRC32(FHashCode, FName);
  FHashCode := StrCRC32(FHashCode, FDescription);
end;

function TCnSymbolItem.GetScopeRate: Integer;
begin
  Result := ScopeToRate(FScope);
end;

function TCnSymbolItem.GetText: string;
begin
  if AllowMultiLine then
    Result := FText
  else
    Result := FName;
end;

function TCnSymbolItem.GetDescription: string;
begin
  if FDescIsUtf8 then
    Result := string(ConvertEditorTextToText(AnsiString(FDescription)))
  else
    Result := FDescription;
end;

procedure TCnSymbolItem.SetScopeRate(const Value: Integer);
begin
  FScope := RateToScope(Value);
end;

function TCnSymbolItem.GetAllowMultiLine: Boolean;
begin
  Result := Kind in [skTemplate, skComment];
end;

function TCnSymbolItem.GetKeywordText(KeywordStyle: TCnKeywordStyle): string;
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

procedure TCnSymbolItem.OutputLines(Editor: IOTAEditBuffer; Lines: TStrings);
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
      Idx := PipesCursorPosition(Line); // ��������е�˫ || �뵥 |�����ص� Idx ���ʼһ���� | ��λ��
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

procedure TCnSymbolItem.OutputTemplate(Editor: IOTAEditBuffer; Icon: TIcon);
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

procedure TCnSymbolItem.Output(Editor: IOTAEditBuffer; Icon: TIcon; KeywordStyle:
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

destructor TCnSymbolItem.Destroy;
begin
  FFuzzyMatchIndexes.Free;
  inherited;
end;

function TCnSymbolItem.PipesCursorPosition(var S: string): Integer;
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
  else if (Length(S) = 1) and (S[1] = '|') then // �� | ��ʾ����λ��
  begin
    S := '';
    Result := 1;
    Exit;
  end;

  // Ԥ����˫ ||���ѵڶ��� | �滻�� #0
  for I := 1 to Length(S) - 1 do
  begin
    if S[I] = '|' then
    begin
      if S[I + 1] = '|' then
      begin
        // ��˫ |�����滻�ڶ����� #0
        S[I + 1] := RPC;
      end;
    end;
  end;

  // Ȼ���¼��һ���� | ���ֵ�λ�ò��滻�� #0
  for I := 1 to Length(S) do
  begin
    if S[I] = '|' then
    begin
      if ((I = 1) or (S[I - 1] <> '|')) and         // ��ǰ��ǰ�� |������
        ((I = Length(S)) or ((S[I + 1] <> '|') and (S[I + 1] <> RPC))) then  // �޺���� | �ҷ� #0
      begin
        Result := I;  // ����ʾ�ǵ�һ���� |�����滻�� #0
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
        // ���Ѿ�������˫ |
        if I < Result then // ���˫ || ��λ���ڵ� | ǰ�����滻˫ | Ϊ�� | ʱҪ��ȥ��Ӧ���ַ���
          Inc(Dif);
      end
      else
      begin
        // ���к����ĵ��� |������¼λ�ã�ֻ�滻�� #0
        S[I] := RPC;
      end;
    end;
  end;

  S := ReplaceAllInString(S, RPC, ''); // �滻�����е� #0
  if (Result > 0) and (Dif > 0) then
    Dec(Result, Dif);
end;

//==============================================================================
// �����б����
//==============================================================================

{ TCnSymbolList }

const
  csXmlRoot = 'Symbols';
  csXmlItem = 'Item';

function SaveListToXMLFile(List: TCnSymbolList; const FileName: string): Boolean;
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

function LoadListFromXMLFile(List: TCnSymbolList; const FileName: string): Boolean;
var
  Doc: IXMLDocument;
  Root: IXMLElement;
  Item: TCnSymbolItem;
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
          Item := TCnSymbolItem.Create;
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

// ��������ֵ�������ظ�ֵ
procedure AdjustSymbolListScope(List: TCnSymbolList);
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    List.Items[I].FScope := RateToScope(List.Items[I].ScopeRate) + I;
end;

constructor TCnSymbolList.Create;
begin
  inherited;
  FList := TObjectList.Create;
  FActive := True;
  Load;
end;

destructor TCnSymbolList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnSymbolList.Add(AItem: TCnSymbolItem): Integer;
begin
  AItem.CalcHashCode;
  Result := FList.Add(AItem);
end;

function TCnSymbolList.Add(const AName: string; AKind: TCnSymbolKind; AScope:
  Integer; const ADescription: string = ''; const AText: string = '';
  AAutoIndent: Boolean = True; AMatchFirstOnly: Boolean = False;
  AAlwaysDisp: Boolean = False; ADescIsUtf8: Boolean = False): Integer;
var
  Item: TCnSymbolItem;
begin
  Item := TCnSymbolItem.Create;
  Item.Name := AName;
  Item.Description := ADescription;
  if AText = '' then
    Item.Text := AName
  else
    Item.Text := AText;
  Item.Kind := AKind;
  Item.Scope := AScope;
  Item.AutoIndent := AAutoIndent;
  if not (Item.Kind in [Low(TCnSymbolKind)..High(TCnSymbolKind)]) then
    Item.Kind := skUnknown;
  Item.MatchFirstOnly := AMatchFirstOnly;
  Item.AlwaysDisp := AAlwaysDisp;
  Item.FDescIsUtf8 := ADescIsUtf8;
  Item.CalcHashCode;
  Result := FList.Add(Item);
end;

procedure TCnSymbolList.Clear;
begin
  FList.Clear;
end;

procedure TCnSymbolList.Cancel;
begin
  // �������ͨ����ɶҲ����
end;

procedure TCnSymbolList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

procedure TCnSymbolList.Remove(AItem: TCnSymbolItem);
begin
  FList.Remove(AItem);
end;

function TCnSymbolList.IndexOf(const AName: string; AKind: TCnSymbolKind): Integer;
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

function TCnSymbolList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnSymbolList.GetItem(Index: Integer): TCnSymbolItem;
begin
  Result := TCnSymbolItem(FList[Index]);
end;

class function TCnSymbolList.GetListName: string;
begin
  Result := RemoveClassPrefix(ClassName);
end;

function TCnSymbolList.Reload(Editor: IOTAEditBuffer; const InputText: string;
  PosInfo: TCodePosInfo): Boolean;
begin
  Result := Count > 0;
end;

procedure TCnSymbolList.GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet;
  PosInfo: TCodePosInfo);
begin
  FirstSet := csIdentFirstSet;
  CharSet := csIdentCharSet;
end;

function TCnSymbolList.CanCustomize: Boolean;
begin
  Result := False;
end;

procedure TCnSymbolList.RestoreDefault;
begin

end;

function DoListSort(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TCnSymbolItem(Item1).Name, TCnSymbolItem(Item2).Name);
end;

procedure TCnSymbolList.Sort;
begin
  FList.Sort(DoListSort);
end;

procedure TCnSymbolList.Load;
begin

end;

procedure TCnSymbolList.Save;
begin

end;

procedure TCnSymbolList.Reset;
begin

end;

//==============================================================================
// �Զ�������б�
//==============================================================================


{ TCnFileSymbolList }

function TCnFileSymbolList.CanCustomize: Boolean;
begin
  Result := True;
end;

function TCnFileSymbolList.GetDataFileName: string;
begin

end;

function TCnFileSymbolList.GetReadFileName: string;
begin
  Result := WizOptions.GetUserFileName(GetDataFileName, True);
end;

function TCnFileSymbolList.GetWriteFileName: string;
begin
  Result := WizOptions.GetUserFileName(GetDataFileName, False);
end;

procedure TCnFileSymbolList.Load;
begin
  Clear;
  LoadListFromXMLFile(Self, GetReadFileName);
{$IFDEF DEBUG}
  CnDebugger.LogMsg(ClassName + ' LoadFrom ' + GetReadFileName + '. Symbol Count ' + IntToStr(List.Count));
{$ENDIF}
  AdjustSymbolListScope(Self);
end;

function TCnFileSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkComment]) // ParsePasCodePosInfo(W) �ж�λ�ò�׼�������޸��ˣ����� Field
  else
    Result := PosInfo.PosKind in [pkField, pkComment];
end;

procedure TCnFileSymbolList.Reset;
begin
  RestoreDefault;
end;

procedure TCnFileSymbolList.RestoreDefault;
begin
  DeleteFile(WizOptions.UserPath + GetDataFileName);
  Load;
end;

procedure TCnFileSymbolList.Save;
begin
  SaveListToXMLFile(Self, GetWriteFileName);
  WizOptions.CheckUserFile(GetDataFileName);
end;

//==============================================================================
// Ԥ��������б�
//==============================================================================

{ TCnPreDefSymbolList }

class function TCnPreDefSymbolList.GetListName: string;
begin
  Result := SCnInputHelperPreDefSymbolList;
end;

function TCnPreDefSymbolList.GetDataFileName: string;
begin
  Result := SCnPreDefSymbolsFile;
end;

function TCnPreDefSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  Result := inherited Reload(Editor, InputText, PosInfo);
  if not Result and PosInfo.IsPascal then
  begin
    // ���⴦������û�Ѹ������ uses�����¹����ߵ� Token �� uses �������ֽ���Ϊ IntfUses/ImplUses
    // ��ôӦ�ðѹؼ����������������������� uses �ܹ��������б���������й���һ��ɸѡ
    if (PosInfo.PosKind in [pkIntfUses, pkImplUses]) and (PosInfo.LastNoSpace = tkUses) then
      Result := True;
  end;
end;

{ TCnUserTemplateList }

class function TCnUserTemplateList.GetListName: string;
begin
  Result := SCnInputHelperUserTemplateList;
end;

function TCnUserTemplateList.GetDataFileName: string;
begin
  Result := SCnCodeTemplateFile;
end;

//==============================================================================
// ����ָ������б�
//==============================================================================

{ TCnCompDirectSymbolList }

procedure TCnCompDirectSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csCompDirectFirstSet;
  CharSet := csCompDirectCharSet;
end;

procedure TCnCompDirectSymbolList.AddSection(Ini: TMemIniFile; const Section: string);
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
      if Names[I][1] = '#' then // # ��ͷ���� C/C++ ��
      begin
        Items[Idx].ForPascal := False;
        Items[Idx].ForCpp := True;
      end;
    end;
  finally
    Names.Free;
  end;
end;

procedure TCnCompDirectSymbolList.Load;
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

   AddSection(Ini, csCompBCB); // �ӽ�������ΪC/C++ר�õ���˵
  finally
    Ini.Free;
  end;
  AdjustSymbolListScope(Self);
end;

function TCnCompDirectSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkIntfUses, pkImplUses, pkField])
  else
    Result := PosInfo.PosKind in (csNormalPosKinds + [pkCompDirect, pkField]);
end;

procedure TCnCompDirectSymbolList.Save;
begin
  // do nothing
end;

class function TCnCompDirectSymbolList.GetListName: string;
begin
  Result := SCnInputHelperCompDirectSymbolList;
end;

//==============================================================================
// �û��Զ�������б�
//==============================================================================

{ TCnUserSymbolList }

class function TCnUserSymbolList.GetListName: string;
begin
  Result := SCnInputHelperUserSymbolList;
end;

function TCnUserSymbolList.GetDataFileName: string;
begin
  Result := SCnUserSymbolsFile;
end;

procedure TCnUserSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csIdentFirstSet + csCompDirectFirstSet + csCommentFirstSet;
  CharSet := csIdentCharSet + csCompDirectCharSet + csCommentCharSet;
end;

//==============================================================================
// XML ע���б�
//==============================================================================

{ TCnXMLCommentSymbolList }

class function TCnXMLCommentSymbolList.GetListName: string;
begin
  Result := SCnInputHelperXMLCommentList;
end;

function TCnXMLCommentSymbolList.GetDataFileName: string;
begin
  Result := SCnXmlCommentDataFile;
end;

procedure TCnXMLCommentSymbolList.GetValidCharSet(var FirstSet,
  CharSet: TAnsiCharSet; PosInfo: TCodePosInfo);
begin
  FirstSet := csCommentFirstSet;
  CharSet := csCommentCharSet;
end;

function TCnXMLCommentSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  Result := PosInfo.PosKind in (csNormalPosKinds + [pkComment]);
end;

//==============================================================================
// JavaDoc ע���б�
//==============================================================================

{ TCnJavaDocSymbolList }

class function TCnJavaDocSymbolList.GetListName: string;
begin
  Result := SCnInputHelperJavaDocList;
end;

function TCnJavaDocSymbolList.GetDataFileName: string;
begin
  Result := SCnJavaDocDataFile;
end;

procedure TCnJavaDocSymbolList.GetValidCharSet(var FirstSet,
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

function TCnJavaDocSymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  Result := PosInfo.PosKind in [pkComment, pkField]; // Pascal/C/C++
end;

//==============================================================================
// �� uses ��ʹ�õĵ�Ԫ�����б�
//==============================================================================

{ TCnUnitNameList }

constructor TCnUnitNameList.Create(UseFullPath: Boolean; IsCppMode: Boolean;
  LoadAfterCreate: Boolean);
begin
  FUseFullPath := UseFullPath;
  FCppMode := IsCppMode;
  FLoadAfterCreate := LoadAfterCreate;
  Create;
end;

constructor TCnUnitNameList.Create;
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

destructor TCnUnitNameList.Destroy;
begin
  FProjectUnitsPath.Free;
  FProjectUnitsName.Free;
  FSysUnitsPath.Free;
  FSysUnitsName.Free;
  FUnitPaths.Free;
  FUnitNames.Free;
  inherited;
end;

class function TCnUnitNameList.GetListName: string;
begin
  Result := SCnInputHelperUnitNameList;
end;

function TCnUnitNameList.AddUnit(const UnitName: string; IsInProject: Boolean): Boolean;
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

procedure TCnUnitNameList.AddUnitFullNameWithPath(const UnitFullName: string);
begin
  FUnitPaths.Add(UnitFullName);
  // ���������ظ�
end;

procedure TCnUnitNameList.LoadFromCurrProject;
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

procedure TCnUnitNameList.DoFindFile(const FileName: string; const Info:
  TSearchRec; var Abort: Boolean);
var
  FilePart: string;
begin
  if FCppMode then // C �� include ����Ҫ��չ��
    FilePart := Info.Name
  else
    FilePart := _CnChangeFileExt(Info.Name, '');

  if IsValidIdent(StringReplace(FilePart, '.', '', [rfReplaceAll])) and (FCurrFileList.IndexOf(FilePart) < 0) then
  begin
    // ����ָʾ��Ӧ·���� FCurrPathList �е�λ�ã���������Ӧʹ��
    FCurrFileList.AddObject(FilePart, TObject(FCurrFileList.Count));

    if FUseFullPath then
      FCurrPathList.Add(FileName);
  end;
end;

procedure TCnUnitNameList.LoadFromSysPath;
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

procedure TCnUnitNameList.LoadFromProjectPath;
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

// ������´�Сдʱ��Ӱ�����򣬴˴�����Ԥ�ȼ�¼���±���¶�Ӧ��·��
procedure TCnUnitNameList.UpdatePathsSequence(Names, Paths: TStringList);
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

function TCnUnitNameList.Reload(Editor: IOTAEditBuffer; const InputText: string;
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

procedure TCnUnitNameList.DoInternalLoad(IncludePath: Boolean);
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

procedure TCnUnitNameList.ExportToStringList(Names, Paths: TStringList);
begin
  if Names <> nil then
    Names.Assign(FUnitNames);

  if Paths <> nil then
    Paths.Assign(FUnitPaths);
end;

//==============================================================================
// ��ǰ��Ԫ���õĵ�Ԫ�����б�
//==============================================================================

{ TCnUnitUsesList }

class function TCnUnitUsesList.GetListName: string;
begin
  Result := SCnInputHelperUnitUsesList;
end;

function TCnUnitUsesList.Reload(Editor: IOTAEditBuffer; const InputText: string;
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
// ����ģ���б�
//==============================================================================

{ TCnCodeTemplateList }

procedure TCnCodeTemplateList.Load;
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
          // ȡ��ģ�����ơ�����������
          Line := Copy(Line, 2, Length(Line) - 2); // ɾ�����ߵ� [] ��
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

          // ȡ��ģ������
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
              // �Զ��ж�����
{$IFNDEF DELPHI} // ˵���� BCB5��6����
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

function TCnCodeTemplateList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in csNormalPosKinds // ParsePasCodePosInfo(W) �ж�λ�ò�׼�������޸��ˣ����� Field
  else
    Result := PosInfo.PosKind in [pkField, pkComment];

  if Result then
  begin
    Load;
  end;
end;

//==============================================================================
// IDE �Դ��Ĵ���ģ���б�
//==============================================================================

{ TCnIDECodeTemplateList }

class function TCnIDECodeTemplateList.GetListName: string;
begin
  Result := SCnInputHelperIDECodeTemplateList;
end;

function TCnIDECodeTemplateList.GetReadFileName: string;
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
// �����б������
//==============================================================================

{ TCnSymbolListMgr }

var
  SymbolListClassList: TClassList;

procedure RegisterSymbolList(AClass: TCnSymbolListClass);
begin
  if SymbolListClassList = nil then
    SymbolListClassList := TClassList.Create;
  if SymbolListClassList.IndexOf(AClass) < 0 then
    SymbolListClassList.Add(AClass);
end;

constructor TCnSymbolListMgr.Create;
begin
  inherited;
  FList := TObjectList.Create;
end;

destructor TCnSymbolListMgr.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnSymbolListMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnSymbolListMgr.GetList(Index: Integer): TCnSymbolList;
begin
  Result := TCnSymbolList(FList[Index]);
end;

procedure TCnSymbolListMgr.InitList;
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
        FList.Add(TCnSymbolListClass(SymbolListClassList[I]).Create);
      except
      {$IFDEF DEBUG}
        on E: Exception do
          CnDebugger.LogMsg('Create SymbolList Error: ' + E.Message);
      {$ENDIF}
      end;
    end;
  end;
end;

procedure TCnSymbolListMgr.GetValidCharSet(var FirstSet, CharSet: TAnsiCharSet;
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

function TCnSymbolListMgr.ListByClass(AClass: TCnSymbolListClass): TCnSymbolList;
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

procedure TCnSymbolListMgr.Load;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Load;
end;

procedure TCnSymbolListMgr.Save;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Save;
end;

procedure TCnSymbolListMgr.Reset;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Reset;
end;

procedure TCnSymbolListMgr.Cancel;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    List[I].Cancel;
end;

{$IFDEF OTA_CODE_TEMPLATE_API}

{ TCnIDEModernCodeTemplateList }

class function TCnIDEModernCodeTemplateList.GetListName: string;
begin
  Result := SCnInputHelperIDECodeTemplateList;
end;

function TCnIDEModernCodeTemplateList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
var
  I, Idx: Integer;
  CT: IOTACodeTemplate;
  CTS: IOTACodeTemplateServices;
begin
  if PosInfo.IsPascal then
    Result := PosInfo.PosKind in csNormalPosKinds // ParsePasCodePosInfo(W) �ж�λ�ò�׼�������޸��ˣ����� Field
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
      if CT = nil then // IDE ������ʱ�п���ȱʧ
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
  RegisterSymbolList(TCnPreDefSymbolList);
  RegisterSymbolList(TCnUserTemplateList);
  RegisterSymbolList(TCnCompDirectSymbolList);
  RegisterSymbolList(TCnXMLCommentSymbolList);
  RegisterSymbolList(TCnJavaDocSymbolList);
  RegisterSymbolList(TCnUnitNameList);
  RegisterSymbolList(TCnUnitUsesList);
{$IFDEF OTA_CODE_TEMPLATE_API}
  RegisterSymbolList(TCnIDEModernCodeTemplateList);
{$ELSE}
  RegisterSymbolList(TCnIDECodeTemplateList);
{$ENDIF}
  RegisterSymbolList(TCnUserSymbolList);

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

