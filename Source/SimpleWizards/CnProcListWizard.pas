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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2, a lot of function added.   }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnProcListWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：函数过程列表专家单元
* 单元作者：刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：该单元部分内容移植自 GExperts 的相应单元
*           其原始内容受 GExperts License 的保护
*           ——有待增加设置窗口控制其设置
*           原则上窗体列表里不使用全局的 List，后者只在工具栏中使用
* 开发平台：PWin2000 + Delphi 5
* 兼容测试：暂无（PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2024.03.13 V1.5
*               增加预览窗口的位置控制按钮，宽度和高度的保存加载暂无 HDPI 问题
*           2012.12.25 V1.4
*               修正列表框的宽度恢复可能有误的问题
*           2012.02.07 V1.3
*               增加列表框的宽度保存机制
*           2009.04.16 V1.2
*               增加工具栏的下拉查找功能
*           2005.10.29 V1.1
*               增加多个单元的选择功能，目前排序还有点问题
*           2005.03.12 V1.0
*               创建单元，实现部分移植功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}

{$IFDEF DELPHIXE4_UP}
  {$DEFINE USE_CUSTOMIZED_SPLITTER}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, StdCtrls, ExtCtrls, IniFiles, Math, Menus, ActnList,
  CnProjectViewBaseFrm, CnIni, mPasLex,  mwBCBTokenList, Contnrs, Clipbrd, CnPasCodeParser,
  {$IFDEF USE_CUSTOMIZED_SPLITTER} CnSplitter, {$ENDIF} CnWidePasParser, CnWideCppParser,
  CnPopupMenu, CnCppCodeParser, CnStrings, CnEdit, RegExpr,
{$IFNDEF STAND_ALONE}
  ToolsAPI, CnWizClasses, CnWizManager, CnWizEditFiler, CnEditControlWrapper, CnWizUtils,
  CnWizMenuAction, CnWizIdeUtils, CnFloatWindow,
{$ENDIF}
  CnFrmMatchButton, CnWizOptions;

type
  TCnSourceLanguageType = (ltUnknown, ltPas, ltCpp);

  TCnElementType = (etUnknown, etClassFunc, etSingleFunction, etConstructor, etDestructor,
    etIntfMember, etRecord, etClass, etInterface, etProperty, etIntfProperty, etNamespace,
    etOperator);

  TCnElementInfo = class(TCnBaseElementInfo)
  {* 一元素包含的信息，从过程扩展而来}
  private
    FElementType: TCnElementType;
    FLineNo: Integer;
    FElementTypeStr: string;
    FProcName: string;
    FProcReturnType: string;
    FName: string;
    FProcArgs: string;
    FOwnerClass: string;
    FAllName: string;
    FFileName: string;
    FBeginIndex: Integer;
    FEndIndex: Integer;
    FIsForward: Boolean;
  public
    property LineNo: Integer read FLineNo write FLineNo;
    {* 元素开始所在行号，1 开始}
    property Name: string read FName write FName;
    {* 记录函数的完整声明，其他类型记录名字，以备状态栏上显示}
    property ElementTypeStr: string read FElementTypeStr write FElementTypeStr;
    {* 额外的类型修饰用的说明性字符串}
    property ProcArgs: string read FProcArgs write FProcArgs;
    {* 函数参数列表}
    property ProcName: string read FProcName write FProcName;
    {* 单纯的函数名}
    property OwnerClass: string read FOwnerClass write FOwnerClass;
    {* 元素所属的类或接口}
    property ProcReturnType: string read FProcReturnType write FProcReturnType;
    {* 函数返回值}
    property FileName: string read FFileName write FFileName;
    {* 文件名，不包括路径}
    property AllName: string read FAllName write FAllName;
    {* 完整的路径文件名}
    property BeginIndex: Integer read FBeginIndex write FBeginIndex;
    {* 起始行}
    property EndIndex: Integer read FEndIndex write FEndIndex;
    {* 结束行}
    property IsForward: Boolean read FIsForward write FIsForward;
    {* 是否前向声明}
    property ElementType: TCnElementType read FElementType write FElementType;
    {* 元素类型}
  end;

  TCnProcListWizard = class;

{$IFDEF STAND_ALONE} // 独立运行时重新声明一些框架内的东西
  TCnMenuWizard = class(TObject);

  {$IFDEF IDE_STRING_ANSI_UTF8}
  TCnIdeTokenString = WideString; // WideString for Utf8 Conversion
  PCnIdeTokenChar = PWideChar;
  {$ELSE}
  TCnIdeTokenString = string;     // Ansi/Utf16
  PCnIdeTokenChar = PChar;
  {$ENDIF}

  {$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}  // 2005 以上
  TCnGeneralPasToken = TCnWidePasToken;
  TCnGeneralCppToken = TCnWideCppToken;
  TCnGeneralPasStructParser = TCnWidePasStructParser;
  TCnGeneralCppStructParser = TCnWideCppStructParser;
  {$ELSE}                               // 5 6 7
  TCnGeneralPasToken = TCnPasToken;
  TCnGeneralCppToken = TCnCppToken;
  TCnGeneralPasStructParser = TCnPasStructureParser;
  TCnGeneralCppStructParser = TCnCppStructureParser;
  {$ENDIF}
{$ENDIF}

{$IFDEF USE_CUSTOMIZED_SPLITTER}
  TCnCustomizedSplitter = TCnSplitter;
{$ELSE}
  TCnCustomizedSplitter = TSplitter;
{$ENDIF}

  TCnProcListForm = class(TCnProjectViewBaseForm)
    btnShowPreview: TToolButton;
    btnSep9: TToolButton;
    cbbMatchSearch: TComboBox;
    lblFiles: TLabel;
    cbbFiles: TComboBox;
    Splitter: TSplitter;
    mmoContent: TMemo;
    btnPreviewRight: TToolButton;
    btnPreviewDown: TToolButton;
    btn2: TToolButton;
    procedure FormDestroy(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure btnShowPreviewClick(Sender: TObject);
    //procedure lvListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure cbbMatchSearchChange(Sender: TObject);
    procedure cbbMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cbbFilesDropDown(Sender: TObject);
    procedure cbbFilesChange(Sender: TObject);
    procedure lvListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListKeyPress(Sender: TObject; var Key: Char);
    procedure SplitterMoved(Sender: TObject);
    procedure btnPreviewRightClick(Sender: TObject);
    procedure btnPreviewDownClick(Sender: TObject);
  private
    FFileName: string;
{$IFNDEF STAND_ALONE}
    FFiler: TCnEditFiler;
    FFilesGot: Boolean;
{$ENDIF}
    FCurrentFile: string;
    FSelIsCurFile: Boolean;
    FWizard: TCnProcListWizard;
    FPreviewIsRight: Boolean;
    FPreviewHeight: Integer;
    FPreviewWidth: Integer;
    FObjName: string;
    FIsObjAll: Boolean;
    FIsObjNone: Boolean;
    FObjectList: TStringList; // 和 DataList 类似，存储本窗体打开时解析出的类名
    procedure SetFileName(const Value: string);
    procedure LoadObjectCombobox(ObjectList: TStringList);
{$IFNDEF STAND_ALONE}
    procedure InitFileComboBox;
    procedure LoadFileComboBox;
{$ENDIF}
    function GetMethodName(const ProcName: string): string;
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function DoSelectOpenedItem: string; override;
    function GetSelectedFileName: string; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateStatusBar; override;
    procedure UpdateComboBox; override;
    procedure UpdateListView; override;
    procedure UpdateItemPosition;
    procedure FontChanged(AFont: TFont); override;

    function DisableLargeIcons: Boolean; override;
    procedure RestorePreviewWidth;
    procedure RestorePreviewHeight;

    procedure PrepareSearchRange; override;
    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;
  public
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string); override;
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string); override;
    procedure UpdateMemoSize(Sender: TObject);
    property FileName: string read FFileName write SetFileName;
    //property Language: TCnSourceLanguageType read FLanguage write FLanguage;
    //property IsCurrentFile: Boolean read FIsCurrentFile write SetIsCurrentFile;
    {* 是否是只显示当前文件 }
    property CurrentFile: string read FCurrentFile write FCurrentFile;
    {* 只显示当前文件时，当前的文件名 }
    property SelIsCurFile: Boolean read FSelIsCurFile write FSelIsCurFile;
    {* 选中的条目的文件名 }

    property PreviewHeight: Integer read FPreviewHeight;
    {* 预览窗口在下方时的高度}
    property PreviewWidth: Integer read FPreviewWidth;
    {* 预览窗口在右方时的宽度}
    property ObjectList: TStringList read FObjectList;
    {* 存储类名的字符串列表，供外界使用}
    property Wizard: TCnProcListWizard read FWizard write FWizard;
  end;

  TCnItemHintEvent = procedure (Sender: TObject; Index: Integer;
    var HintStr: string) of object;

{$IFNDEF STAND_ALONE}

  // 工具栏中的下拉列表框的下拉列表
  TCnProcDropDownBox = class(TCnFloatListBox)
  private
    FRegExpr: TRegExpr;
    FLastItem: Integer;
    FOnItemHint: TCnItemHintEvent;
    FDisplayItems: TStrings;
    FMatchStr: string;
    FMatchMode: TCnMatchMode;
    FInfoItems: TStrings; // 存储原始列表内容
    FDisableClickFlag: Boolean;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure ListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SetMatchStr(const Value: string);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure UpdateDisplay;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseUp; override;

    procedure UpdateListFont;
    procedure SavePosition;

    property OnItemHint: TCnItemHintEvent read FOnItemHint write FOnItemHint;
    property DisplayItems: TStrings read FDisplayItems;
    property InfoItems: TStrings read FInfoItems;
    property MatchStr: string read FMatchStr write SetMatchStr;
    property MatchMode: TCnMatchMode read FMatchMode write FMatchMode;
  end;

//==============================================================================
// 工具栏中的下拉框组件
//==============================================================================

  TCnProcListComboBox = class(TCnEdit)
  private
    FChangeDown: Boolean;
    FDisableChange: Boolean;
    FFocusedClick: Boolean;
    FOnKillFocus: TNotifyEvent;
    FDropDownList: TCnProcDropDownBox;
    FOnMarginClick: TNotifyEvent;
    procedure RefreshDropBox(Sender: TObject);
    procedure DropDownListDblClick(Sender: TObject);
    procedure DropDownListClick(Sender: TObject);
    procedure UpdateDropPosition;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure Change; override;
    procedure Click; override;
    procedure DoMarginClick; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ShowDropBox;
    procedure SetTextWithoutChange(const AText: TCnIdeTokenString);

    property DropDownList: TCnProcDropDownBox read FDropDownList;
    property OnKillFocus: TNotifyEvent read FOnKillFocus write FOnKillFocus;
    property ChangeDown: Boolean read FChangeDown write FChangeDown;
    // 是否由于文字改变导致的下拉，为 False 时大概是点击导致的下拉
    property OnMarginClick: TNotifyEvent read FOnMarginClick write FOnMarginClick;
    {* 点击在文字右侧的空白处触发，供改善用户体验用}
  end;

  TCnProcToolButton = class(TToolButton);

  TCnProcToolBarObj = class(TObject)
  private
    // 工具栏上的工具按钮和弹出菜单，都采用手工方式创建
    FInternalToolBar1: TToolBar;
    FInternalToolBar2: TToolBar;
    FToolBtnProcList: TCnProcToolButton;
    FToolBtnListUsed: TCnProcToolButton;
    FToolBtnSep1: TCnProcToolButton;
    FToolBtnJumpIntf: TCnProcToolButton;
    FToolBtnJumpImpl: TCnProcToolButton;
    FClassCombo: TCnProcListComboBox;
    FProcCombo: TCnProcListComboBox;
    FPopupMenu: TPopupMenu;
    FEditControl: TControl;
    FEditorToolBar: TControl;
    FSplitter1: TCnCustomizedSplitter;
    FSplitter2: TCnCustomizedSplitter;
    FMatchFrame: TCnMatchButtonFrame;
  protected
    procedure MatchChange(Sender: TObject);
    procedure CloseUpList;
  public
    property EditControl: TControl read FEditControl write FEditControl;
    property EditorToolBar: TControl read FEditorToolBar write FEditorToolBar;

    property InternalToolBar1: TToolBar read FInternalToolBar1 write FInternalToolBar1;
    property InternalToolBar2: TToolBar read FInternalToolBar2 write FInternalToolBar2;
    property ToolBtnProcList: TCnProcToolButton read FToolBtnProcList write FToolBtnProcList;
    property ToolBtnListUsed: TCnProcToolButton read FToolBtnListUsed write FToolBtnListUsed;
    property ToolBtnSep1: TCnProcToolButton read FToolBtnSep1 write FToolBtnSep1;
    property ToolBtnJumpIntf: TCnProcToolButton read FToolBtnJumpIntf write FToolBtnJumpIntf;
    property ToolBtnJumpImpl: TCnProcToolButton read FToolBtnJumpImpl write FToolBtnJumpImpl;
    property ClassCombo: TCnProcListComboBox read FClassCombo write FClassCombo;
    property Splitter1: TCnCustomizedSplitter read FSplitter1 write FSplitter1;
    property Splitter2: TCnCustomizedSplitter read FSplitter2 write FSplitter2;
    property ProcCombo: TCnProcListComboBox read FProcCombo write FProcCombo;
    property MatchFrame: TCnMatchButtonFrame read FMatchFrame write FMatchFrame;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
  end;

{$ENDIF}

  TCnProcListWizard = class(TCnMenuWizard)
  private
    FNeedReParse: Boolean;
    FCurrPasParser: TCnGeneralPasStructParser;
    FCurrCppParser: TCnGeneralCppStructParser;
    FCurrStream: TMemoryStream;
{$IFNDEF STAND_ALONE}
    FEditorToolBarType: string;
    FUseEditorToolBar: Boolean;
    FToolBarTimer: TTimer;
    FProcToolBarObjects: TList;
    FComboToSearch: TCnProcListComboBox;
    FProcComboHeight: Integer;
    FClassComboHeight: Integer;
    FProcComboWidth: Integer;
    FClassComboWidth: Integer;
    FToolbarClassComboWidth: Integer;
    FToolbarProcComboWidth: Integer;
    FHistoryCount: Integer;
    FFileIndex: Integer;
{$ELSE}
    FLines: TStringList;
{$ENDIF}
    FPreviewLineCount: Integer;
    FElementList: TStringList; // 存储当前 ProcToolbar 的原始元素列表
    FObjStrings: TStringList;  // 存储当前 ProcToolbar 的类元素列表
{$IFNDEF STAND_ALONE}
    function GetToolBarObjFromEditControl(EditControl: TControl): TCnProcToolBarObj;
    procedure RemoveToolBarObjFromEditControl(EditControl: TControl);
    procedure ToolBarCanShow(Sender: TObject; APage: TCnSrcEditorPage; var ACanShow: Boolean);
    procedure SplitterMoved(Sender: TObject);
    procedure CreateProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure InitProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure RemoveProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure OnToolBarTimer(Sender: TObject);
    procedure PopupCloseItemClick(Sender: TObject);
    procedure PopupSubItemSortByClick(Sender: TObject);
    procedure PopupSubItemReverseClick(Sender: TObject);
    procedure PopupExportItemClick(Sender: TObject);
    procedure PopupEditorEnhanceConfigItemClick(Sender: TObject);

    procedure EditorToolBarEnable(const Value: Boolean);
    procedure SetUseEditorToolBar(const Value: Boolean);

    procedure EditorChange(Editor: TEditorObject; ChangeType:
      TEditorChangeTypes);

    procedure ParseCurrent;
    procedure ClearList;
    procedure CheckCurrentFile(Sender: TObject);
    function CheckReparse: Boolean;

    procedure CurrentGotoLineAndFocusEditControl(Info: TCnElementInfo); overload;
    procedure CurrentGotoLineAndFocusEditControl(Line: Integer); overload;
    procedure JumpIntfOnClick(Sender: TObject);
    procedure JumpImplOnClick(Sender: TObject);
    procedure ClassComboDropDown(Sender: TObject);
    procedure ProcComboDropDown(Sender: TObject);
    procedure DoIdleComboChange(Sender: TObject);
    procedure AfterThemeChange(Sender: TObject);
{$IFDEF IDE_SUPPORT_THEMING}
    procedure DoThemeChange(Sender: TObject);
{$ENDIF}
{$ENDIF}
    procedure ClearObjectStrings(ObjectList: TStringList);
  protected
{$IFNDEF STAND_ALONE}
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
{$ENDIF}
  public
    constructor Create; {$IFNDEF STAND_ALONE} override; {$ENDIF}
    destructor Destroy; override;
{$IFNDEF STAND_ALONE}
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    function GetCurrentToolBarObj: TCnProcToolBarObj;
{$ENDIF}
    procedure Execute; {$IFNDEF STAND_ALONE} override; {$ENDIF}

    procedure LoadElements(ElementList, ObjectList: TStringList; aFileName: string;
      ToClear: Boolean = True);
    procedure UpdateDataListImageIndex(ADataList: TStringList);
    procedure AddProcedure(ElementList, ObjectList: TStringList;
      ElementInfo: TCnElementInfo; IsIntf: Boolean);
    procedure AddElement(ElementList: TStringList;
      ElementInfo: TCnElementInfo);

    // 注：有其他的设置在 Form 的属性中，不完全在此地
    property PreviewLineCount: Integer read FPreviewLineCount write FPreviewLineCount;
    {* 预览窗口中的行数量}

{$IFNDEF STAND_ALONE}
    property UseEditorToolBar: Boolean read FUseEditorToolBar write SetUseEditorToolBar;
    {* 是否显示编辑器中的过程函数列表工具栏}
    property HistoryCount: Integer read FHistoryCount write FHistoryCount;
    {* 历史记录的数量}
    property FileIndex: Integer read FFileIndex write FFileIndex;
    {* 下拉框里选中的文件范围}

    // 下拉框的尺寸
    property ProcComboHeight: Integer read FProcComboHeight write FProcComboHeight;
    property ProcComboWidth: Integer read FProcComboWidth write FProcComboWidth;
    property ClassComboHeight: Integer read FClassComboHeight write FClassComboHeight;
    property ClassComboWidth: Integer read FClassComboWidth write FClassComboWidth;

    // 工具栏列表框宽度
    property ToolbarClassComboWidth: Integer read FToolbarClassComboWidth write FToolbarClassComboWidth;
    property ToolbarProcComboWidth: Integer read FToolbarProcComboWidth write FToolbarProcComboWidth;
{$ENDIF}
  end;

{$ENDIF CNWIZARDS_CNPROCLISTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}

uses
  CnConsts, CnWizConsts, CnCommon, CnLangMgr,
  {$IFNDEF STAND_ALONE} CnWizMacroUtils, CnSrcEditorToolBar, CnWizNotifier, {$ENDIF}
  CnWizShareImages, CnPasWideLex, CnBCBWideTokenList
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

{$R *.DFM}

const
  csUseEditorToolbar = 'UseEditorToolBar';
  csPreviewLineCount = 'PreviewLineCount';
  csHistoryCount = 'HistoryCount';
  csProcHeight = 'ProcHeight';
  csProcWidth = 'ProcWidth';
  csClassHeight = 'ClassHeight';
  csClassWidth = 'ClassWidth';
  csToolbarClassComboWidth = 'ToolbarClassComboWidth';
  csToolbarProcComboWidth = 'ToolbarProcComboWidth';

  csProcComboName = 'ProcCombo';
  csClassComboName = 'ClassCombo';

  CN_SPLITTER_WIDTH = 3;
  CN_INIT_CLASSCOMBO_WIDTH = 300;
  CN_INIT_PROCCOMBO_WIDTH = 400;
  CN_ICON_WIDTH = 22;

  csDefHistoryCount = 8;
  csDefPreviewLineCount = 4;
  csDefProcDropDownBoxFontSize = 8;

type
  TCnFileInfo = class(TObject)
  private
    FAllName: string;
    FProjectName: string;
    FFileName: string;
  public
    property FileName: string read FFileName write FFileName;
    property AllName: string read FAllName write FAllName;
    property ProjectName: string read FProjectName write FProjectName;
  end;

const
  csShowPreview = 'ShowPreview';
  csPreviewHeight = 'PreviewHeight';
  csPreviewWidth = 'PreviewWidth';
  csPreviewIsRight = 'PreviewIsRight';
  csDropDown = 'DropDown';
  csClassComboWidth = 'ClassComboWidth';
  csProcComboWidth = 'ProcComboWidth';

  csCRLF = #13#10;
  csSep = ';';

  CnDropDownListCount = 7;

  ProcBlacklist: array[0..2] of string = ('CATCH_ALL', 'CATCH', 'AND_CATCH_ALL');

var
  FLanguage: TCnSourceLanguageType;
  FCurElement: string;
  FIsCurrentFile: Boolean;
  FOldCaption: string;
  FIntfLine: Integer = 0;
  FImplLine: Integer = 0;

  GListSortIndex: Integer = 0;
  GListSortReverse: Boolean = False;

  FWizard: TCnProcListWizard = nil;

{$IFNDEF STAND_ALONE}

function GetMatchMode(Obj: TCnProcToolBarObj): TCnMatchMode;
begin
  if Obj <> nil then
    Result := Obj.MatchFrame.MatchMode
  else
    Result := mmFuzzy;
end;

{$ENDIF}

function InfoCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  case GListSortIndex of
  0:
    begin
      Result := CompareText(List[Index1], List[Index2]);
    end;
  1:
    begin
      if (List.Objects[Index1] <> nil) and (List.Objects[Index2] <> nil) then
      begin
        Result := CompareValue(TCnElementInfo(List.Objects[Index1]).LineNo,
          TCnElementInfo(List.Objects[Index2]).LineNo);
      end;
    end;
  else
    Result := CompareValue(Index1, Index2);
  end;

  if GListSortReverse then
    Result := -Result;
end;

function CalcSelectImageIndex(ProcInfo: TCnElementInfo; Lang: TCnSourceLanguageType): Integer;
var
  ProcName: string;
begin
  // 返回图标编号
  Result := 20;
  if ProcInfo = nil then
    Exit;

  case Lang of
  ltPas:
    begin
      ProcName := UpperCase(ProcInfo.Name);
      if Pos('.', ProcName) <> 0 then
        Result := 41    // 方法
      else
        Result := 20;   // 独立
      if Pos('CONSTRUCTOR', ProcName) <> 0 then // Do not localize.
        Result := 12;   // 构造
      if Pos('DESTRUCTOR', ProcName) <> 0 then // Do not localize.
        Result := 31;   // 析构

      case ProcInfo.ElementType of
        etClass:     Result := 90;
        etRecord:    Result := 36;
        etInterface: Result := 91;
        etProperty : Result := 92;
      else
        // nochange;
      end;
    end;
  ltCpp:
    begin
      case ProcInfo.ElementType of
        etClassFunc:      Result := 41;   // 方法
        etSingleFunction: Result := 20;   // 独立
        etConstructor:    Result := 12;   // 构造
        etDestructor:     Result := 31;   // 析构
        etClass:          Result := 90;
        etInterface:      Result := 91;
        etProperty :      Result := 92;
        etRecord:         Result := 36;
      end;
    end;
  end;
end;

{ TCnProcListWizard }

{$IFNDEF STAND_ALONE}

procedure TCnProcListWizard.CheckCurrentFile(Sender: TObject);
var
  S: string;
  Obj: TCnProcToolBarObj;
begin
  Obj := GetCurrentToolBarObj;
  if (Obj <> nil) and (Obj.EditorToolBar <> nil) then
  begin
    S := CnOtaGetCurrentSourceFileName;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnProcListWizard.CheckCurrentFile ' + S);
{$ENDIF}
    try
      Obj.EditorToolBar.Visible := Active and FUseEditorToolBar and
        IsDelphiSourceModule(S) or IsInc(S) or IsCppSourceModule(S);
    except
      ; // Maybe cause AV when Editor Resizing.
    end;

    if IsPas(S) or IsInc(S) then
    begin
      Obj.ToolBtnJumpIntf.Enabled := True;
      Obj.ToolBtnJumpImpl.Enabled := True;
    end
    else
    begin
      Obj.ToolBtnJumpIntf.Enabled := False;
      Obj.ToolBtnJumpImpl.Enabled := False;
    end;
  end;
end;

function TCnProcListWizard.CheckReparse: Boolean;

  procedure RemoveForward;
  var
    I: Integer;
    Info1, Info2: TCnElementInfo;
  begin
    I := 0;
    while I < FElementList.Count do
    begin
      // 如果本条目和后续条目相同，则删除本条与后续条目中是前向的，I不变，继续循环
      if I < FElementList.Count - 1 then
      begin
        // 同名，判断谁是前向声明的 Info
        Info1 := TCnElementInfo(FElementList.Objects[I]);
        Info2 := TCnElementInfo(FElementList.Objects[I + 1]);

        if (Info1 <> nil) and (Info2 <> nil) and
          (Info1.Text = Info2.Text) then
        begin
          // 谁是前向就删谁，但只删一个，如果有多个前向（虽然不太可能），则在下次循环中删
          if Info1.IsForward then
          begin
            FElementList.Delete(I);
            Info1.Free;
          end
          else if Info2.IsForward then
          begin
            FElementList.Delete(I + 1);
            Info2.Free;
          end;
        end;
      end;
      Inc(I);
    end;
  end;

begin
  Result := False;
  if FNeedReParse then
  begin
    ClearList;
    LoadElements(FElementList, FObjStrings, CnOtaGetCurrentSourceFileName);
    UpdateDataListImageIndex(FElementList);

    FElementList.Sort;
    RemoveForward; // 去除重复的前向声明

    // 再按需要排序
    if GListSortReverse or (GListSortIndex <> 0) then
      FElementList.CustomSort(InfoCompare);

    FNeedReParse := False;
    Result := True;
  end;
end;

procedure TCnProcListWizard.ClassComboDropDown(Sender: TObject);
var
  ClassCombo: TCnProcListComboBox;
  I, Idx: Integer;
  Info: TCnElementInfo;
  Obj: TCnProcToolBarObj;
  AText: string;
begin
  CheckReparse;
  ClassCombo := Sender as TCnProcListComboBox;
  ClassCombo.DropDownList.InfoItems.Clear;

  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    if (Info <> nil) and (Info.ElementType in [etRecord, etClass, etInterface]) then
      ClassCombo.DropDownList.InfoItems.AddObject(Info.Text, Info);
  end;

  if not ClassCombo.ChangeDown then
  begin
    AText := ClassCombo.Text;
    ClassCombo.SetTextWithoutChange('');
    ClassCombo.DropDownList.MatchStr := '';
    ClassCombo.DropDownList.MatchMode := GetMatchMode(Obj);
    ClassCombo.DropDownList.UpdateDisplay;
    if ClassCombo.DropDownList.DisplayItems.Count > 0 then
    begin
      // DropDownList 定位并显示到 AText
      Idx := ClassCombo.DropDownList.DisplayItems.IndexOf(AText);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnProcListWizard.ClassComboDropDown. To Select %d, Text: %s',
        [Idx, AText]);
{$ENDIF}

      // 有待选中条目，则选中其上一个，UpdateDisplay 会再下移一个条目
      if Idx >= 1 then
        ClassCombo.DropDownList.ItemIndex := Idx - 1;

      ClassCombo.ShowDropBox;
    end;
  end;

  CnWizNotifierServices.ExecuteOnApplicationIdle(ClassCombo.RefreshDropBox);
end;

procedure TCnProcListWizard.ClearList;
var
  I: Integer;
begin
  FObjStrings.Clear;
  for I := 0 to FElementList.Count - 1 do
    if FElementList.Objects[I] <> nil then
      FElementList.Objects[I].Free;

  FElementList.Clear;
  FIntfLine := 0;
  FImplLine := 0;
end;

procedure TCnProcListWizard.Config;
begin
  inherited;

end;

{$ENDIF}

constructor TCnProcListWizard.Create;
begin
  inherited;
  FElementList := TStringList.Create;
  FObjStrings := TStringList.Create;
  FObjStrings.Sorted := True;
  FObjStrings.Duplicates := dupIgnore;

{$IFNDEF STAND_ALONE}
  FProcToolBarObjects := TList.Create;
  EditControlWrapper.AddEditorChangeNotifier(EditorChange);
  CnWizNotifierServices.AddAfterThemeChangeNotifier(AfterThemeChange);
{$ELSE}
  FLines := TStringList.Create;
{$ENDIF}
  FNeedReParse := True;
  FWizard := Self;
end;

destructor TCnProcListWizard.Destroy;
var
  I: Integer;
begin
  FWizard := nil;
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.RemoveAfterThemeChangeNotifier(AfterThemeChange);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChange);
  for I := 0 to FProcToolBarObjects.Count - 1 do
    TObject(FProcToolBarObjects).Free;
  FreeAndNil(FProcToolBarObjects);

  FreeAndNil(FToolBarTimer);
{$ELSE}
  FLines.Free;
{$ENDIF}
  FObjStrings.Free;
  for I := 0 to FElementList.Count - 1 do
    if FElementList.Objects[I] <> nil then
      FElementList.Objects[I].Free;

  FElementList.Free;

  FreeAndNil(FCurrPasParser);
  FreeAndNil(FCurrCppParser);
  FreeAndNil(FCurrStream);
  inherited;
end;

procedure TCnProcListWizard.ClearObjectStrings(ObjectList: TStringList);
begin
  ObjectList.Clear;
  ObjectList.Add(SCnProcListObjsAll);
end;

{$IFNDEF STAND_ALONE}

procedure TCnProcListWizard.ToolBarCanShow(Sender: TObject;
  APage: TCnSrcEditorPage; var ACanShow: Boolean);
begin
  ACanShow := Active and (APage in [epCode]);
end;

procedure TCnProcListWizard.SplitterMoved(Sender: TObject);
var
  AComp, AToolbar: TComponent;
  AClassCombo, AProcCombo: TCnProcListComboBox;
begin
  if Sender is TComponent then
  begin
    AToolbar := (Sender as TComponent).Owner;
    if (AToolbar <> nil) then
    begin
      AComp := AToolbar.FindComponent(csClassComboName);
      if (AComp <> nil) and (AComp is TCnProcListComboBox) then
      begin
        AClassCombo := AComp as TCnProcListComboBox;
        if AClassCombo.Parent <> nil then
          FToolbarClassComboWidth := IdeGetOriginPixelsFromScaled(AClassCombo.Width, AClassCombo);
      end;
      AComp := AToolbar.FindComponent(csProcComboName);
      if (AComp <> nil) and (AComp is TCnProcListComboBox) then
      begin
        AProcCombo := AComp as TCnProcListComboBox;
        if AProcCombo.Parent <> nil then
          FToolbarProcComboWidth := IdeGetOriginPixelsFromScaled(AProcCombo.Width, AProcCombo);
      end;
    end;
  end;
end;

procedure TCnProcListWizard.CreateProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
var
  Obj: TCnProcToolBarObj;
  Item, SubItem: TMenuItem;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Create Proc ToolBar from EditControl %8.8x', [Integer(EditControl)]);
{$ENDIF}
  ToolBar.Top := 40; // 让其处于标准编辑器工具栏之下
  ToolBar.Images := dmCnSharedImages.ilProcToolBar;
  ToolBar.Wrapable := False;
  if ToolBar is TCnExternalSrcEditorToolBar then
    TCnExternalSrcEditorToolBar(ToolBar).OnCanShow := ToolBarCanShow;

  Obj := TCnProcToolBarObj.Create;
  Obj.EditControl := EditControl;
  Obj.EditorToolBar := ToolBar;

  // 手工创建弹出菜单
  Obj.PopupMenu := TPopupMenu.Create(ToolBar);
  Obj.PopupMenu.Images := dmCnSharedImages.GetMixedImageList;

  // 排序
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListSortMenuCaption;
  Obj.PopupMenu.Items.Add(Item);

  // 子菜单缩进，按名称排序
  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuByName;
  SubItem.Tag := 0;
  SubItem.GroupIndex := 1;
  SubItem.RadioItem := True;
  SubItem.Checked := True;
  SubItem.OnClick := PopupSubItemSortByClick;
  Item.Add(SubItem);

  // 按位置排序
  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuByLocation;
  SubItem.Tag := 1;
  SubItem.GroupIndex := 1;
  SubItem.RadioItem := True;
  SubItem.OnClick := PopupSubItemSortByClick;
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := '-';
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuReverse;
  SubItem.OnClick := PopupSubItemReverseClick;
  Item.Add(SubItem);

  // 导出
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListExportMenuCaption;
  Item.OnClick := PopupExportItemClick;
  Item.ImageIndex := dmCnSharedImages.CalcMixedImageIndex(46);
  Obj.PopupMenu.Items.Add(Item);

  // 分割线
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := '-';
  Obj.PopupMenu.Items.Add(Item);

  // 编辑器扩展配置
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnEditorEnhanceConfig;
  Item.OnClick := PopupEditorEnhanceConfigItemClick;
  Item.ImageIndex := CnWizardMgr.ImageIndexByWizardClassNameAndCommand('TCnIdeEnhanceMenuWizard',
    SCnIdeEnhanceMenuCommand + 'TCnSrcEditorEnhance');
  Obj.PopupMenu.Items.Add(Item);

  // 关闭
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListCloseMenuCaption;
  Item.OnClick := PopupCloseItemClick;
  Item.ImageIndex := dmCnSharedImages.CalcMixedImageIndex(13);
  Obj.PopupMenu.Items.Add(Item);

  ToolBar.PopupMenu := Obj.PopupMenu;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Proc ToolBar Obj Created: %8.8x', [Integer(Obj)]);
{$ENDIF}

  Obj.ClassCombo := TCnProcListComboBox.Create(ToolBar);
  with Obj.ClassCombo do
  begin
    Parent := ToolBar;
    Left := 108;
    Top := 0;
    if IdeGetScaledPixelsFromOrigin(FToolbarClassComboWidth, Obj.ClassCombo) > 50 then
      Width := IdeGetScaledPixelsFromOrigin(FToolbarClassComboWidth, Obj.ClassCombo)
    else
      Width := IdeGetScaledPixelsFromOrigin(CN_INIT_CLASSCOMBO_WIDTH, Obj.ClassCombo);
    Height := 21;
    FDisableChange := True;
    Name := csClassComboName;
    SetTextWithoutChange('');
    FDisableChange := False;
    OnButtonClick := ClassComboDropDown;
    OnMarginClick := ClassComboDropDown;
  end;

  Obj.FSplitter1 := TCnCustomizedSplitter.Create(ToolBar);
  with Obj.FSplitter1 do
  begin
    Align := alLeft;
    Width := CN_SPLITTER_WIDTH;
    MinSize := 40;
    Parent := ToolBar;
    Left := Obj.ClassCombo.Left + Obj.ClassCombo.Width - 1;
    OnMoved := SplitterMoved;
  end;

  Obj.ProcCombo := TCnProcListComboBox.Create(ToolBar);
  with Obj.ProcCombo do
  begin
    Parent := ToolBar;
    Left := Obj.FSplitter1.Left + Obj.FSplitter1.Width + 1;
    Top := 0;
    if IdeGetScaledPixelsFromOrigin(FToolbarProcComboWidth, Obj.ProcCombo) > 50 then
      Width := IdeGetScaledPixelsFromOrigin(FToolbarProcComboWidth, Obj.ProcCombo)
    else
      Width := IdeGetScaledPixelsFromOrigin(CN_INIT_CLASSCOMBO_WIDTH, Obj.ProcCombo);
    Height := 21;
    FDisableChange := True;
    Name := csProcComboName;
    SetTextWithoutChange('');
    FDisableChange := False;
    OnButtonClick := ProcComboDropDown;
    OnMarginClick := ProcComboDropDown;
  end;

  Obj.FSplitter2 := TCnCustomizedSplitter.Create(ToolBar);
  with Obj.FSplitter2 do
  begin
    Align := alLeft;
    Width := CN_SPLITTER_WIDTH;
    MinSize := 40;
    Parent := ToolBar;
    Left := Obj.ProcCombo.Left + Obj.ProcCombo.Width + 2;
    onMoved := SplitterMoved;
  end;

  Obj.InternalToolBar2 := TCnExternalSrcEditorToolBar.Create(ToolBar);
  with Obj.InternalToolBar2 do
  begin
    Parent := ToolBar;
    Left := 40;
    Top := 0;
    Caption := '';
    AutoSize := True;
    Align := alLeft;
    EdgeBorders := [];
    Flat := True;
    DockSite := False;
    ShowHint := True;
    Transparent := False;
{$IFDEF IDE_SUPPORT_HDPI}
    Images := TImageList(dmCnSharedImages.ProcToolbarVirtualImages);
    InitSizeIfLargeIcon(Obj.InternalToolBar2, TImageList(dmCnSharedImages.LargeProcToolbarVirtualImages));
{$ELSE}
    Images := dmCnSharedImages.ilProcToolBar;
    InitSizeIfLargeIcon(Obj.InternalToolBar2, dmCnSharedImages.ilProcToolbarLarge);
{$ENDIF}
    PopupMenu := Obj.PopupMenu;
  end;

  Obj.ToolBtnJumpIntf := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnJumpIntf do
  begin
    Left := 54;
    Top := 0;
    Caption := '';
    ImageIndex := 0;
    SetToolBar(Obj.InternalToolBar2);
    OnClick := JumpIntfOnClick;
  end;

  Obj.ToolBtnJumpImpl := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnJumpImpl do
  begin
    Left := 77;
    Top := 0;
    Caption := '';
    ImageIndex := 1;
    SetToolBar(Obj.InternalToolBar2);
    OnClick := JumpImplOnClick;
  end;

  Obj.InternalToolBar1 := TCnExternalSrcEditorToolBar.Create(ToolBar);
  with Obj.InternalToolBar1 do
  begin
    Parent := ToolBar;
    Left := 0;
    Top := 0;
    Caption := '';
    AutoSize := True;
    Align := alLeft;
    EdgeBorders := [];
    Flat := True;
    DockSite := False;
    ShowHint := True;
    Transparent := False;
    Images := GetIDEImageList;
{$IFDEF IDE_SUPPORT_HDPI}
    InitSizeIfLargeIcon(Obj.InternalToolBar1, TImageList(dmCnSharedImages.IDELargeVirtualImages));
{$ELSE}
    InitSizeIfLargeIcon(Obj.InternalToolBar1, dmCnSharedImages.IDELargeImages);
{$ENDIF}
    PopupMenu := Obj.PopupMenu;
  end;

  Obj.ToolBtnProcList := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnProcList do
  begin
    Left := 0;
    Top := 0;
    Caption := '';
    ImageIndex := -1;
    SetToolBar(Obj.InternalToolBar1);
  end;

  Obj.ToolBtnListUsed := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnListUsed do
  begin
    Left := 23;
    Top := 0;
    Caption := '';
    ImageIndex := -1;
    SetToolBar(Obj.InternalToolBar1);
  end;

  Obj.ToolBtnSep1 := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnSep1 do
  begin
    Left := 46;
    Top := 0;
    Width := 4;
    Caption := '';
    ImageIndex := -1;
    Style := tbsSeparator;
    SetToolBar(Obj.InternalToolBar1);
  end;
  Obj.InternalToolBar1.Visible := Obj.ToolBtnSep1.Visible;

  // 有下拉菜单的 Frame，在主题存在的情况下，如果菜单的 Owner 不是 Frame，
  // 或 Frame 的 Owner 不是 Form，那么 TSysPopupStyleHook 会无法根据菜单 Handle
  // 找到 MenuItem，导致主题状态下菜单绘制失败。
  // 即使 GetVCLParentMenuItem 函数里从只找 Menu/Frame 改为全递归，也仍然存在
  // Owner 为 nil 的 PopupMenu 无法被找到的问题。
{$IFDEF DELPHI103_RIO_UP}
  Obj.MatchFrame := TCnMatchButtonFrame.Create(GetIdeMainForm);
  Obj.MatchFrame.Name := Obj.MatchFrame.Name + FormatDateTime('yyyyMMddhhmmss', Now);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Create ProcToolbar: MatchFrame Name: ' + Obj.MatchFrame.Name);
{$ENDIF}
{$ELSE}
  Obj.MatchFrame := TCnMatchButtonFrame.Create(ToolBar);
{$ENDIF}

{$IFNDEF IDE_SUPPORT_HDPI}
  if WizOptions.UseLargeIcon then
  begin
    Obj.MatchFrame.Width := Obj.MatchFrame.Width + csLargeToolbarHeightDelta;
    Obj.MatchFrame.tlb1.Width := Obj.MatchFrame.tlb1.Width + csLargeToolbarHeightDelta;
  end;
{$ENDIF}

  with Obj.MatchFrame do
  begin
    Parent := ToolBar;  // HDPI 下，这里会放大
    Top := 0;
    Left := Obj.ProcCombo.Left + Obj.ProcCombo.Width + Obj.FSplitter1.Width + 2;
    OnModeChange := Obj.MatchChange;
  end;

  // 注意必须设置完 Parent 后再调用此函数
  WizOptions.ResetToolbarWithLargeIcons(Obj.MatchFrame.tlb1);

  FProcToolBarObjects.Add(Obj);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProcList: Proc ToolBar Obj Added.');
{$ENDIF}
end;

procedure TCnProcListWizard.EditorChange(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  Obj: TCnProcToolBarObj;
begin
  if Active and FUseEditorToolBar then
  begin
    if ChangeType * [ctView] <> [] then
    begin
      // D5/6 下 Alt+F12 切换 Form 与 Text 时，收到通知时得到的可能是旧的文件，需要延迟处理
{$IFDEF COMPILER7_UP}
      CheckCurrentFile(nil);
{$ELSE}
      CnWizNotifierServices.ExecuteOnApplicationIdle(CheckCurrentFile);
{$ENDIF}
    end;

    if ChangeType * [ctView, ctWindow, ctModified, ctBlock] <> [] then
    begin
      FNeedReParse := True;
    end;
    if FNeedReParse or (ChangeType * [ctCurrLine, ctCurrCol] <> []) then
    begin
      FToolBarTimer.Enabled := False;
      FToolBarTimer.Enabled := True;
    end;

    if ChangeType * [ctView] <> [] then
    begin
      Obj := GetCurrentToolBarObj;
      if Obj <> nil then
        Obj.CloseUpList;
    end;    
  end;  
end;

{$ENDIF}

procedure TCnProcListWizard.Execute;
var
{$IFNDEF STAND_ALONE}
  Ini: TCustomIniFile;
{$ENDIF}
  TmpFileName: string;
begin
{$IFDEF STAND_ALONE}
  TmpFileName := ParamStr(1);
{$ELSE}
  TmpFileName := CnOtaGetCurrentSourceFileName;
{$ENDIF}
  if TmpFileName = '' then
  begin
    ErrorDlg(SCnProcListErrorFileType);
    Exit;
  end;

{$IFNDEF STAND_ALONE}
  Ini := CreateIniFile;
{$ENDIF}
  try
    // ClearList;
    with TCnProcListForm.Create(nil) do
    try
      Wizard := Self;
      if FPreviewIsRight then
        btnPreviewRight.Down := True
      else
        btnPreviewDown.Down := True;

{$IFNDEF STAND_ALONE}
      ShowHint := WizOptions.ShowHint;
{$ENDIF}
      FileName := TmpFileName;
      // Current Filename
      CurrentFile := TmpFileName;
      FIsCurrentFile := True;

{$IFNDEF STAND_ALONE}
      LoadSettings(Ini, '');
{$ENDIF}
      LoadElements(DataList, ObjectList, FFileName);
      UpdateDataListImageIndex(DataList);

      UpdateListView;
      LoadObjectComboBox(ObjectList);

      Caption := Caption + ' - ' + _CnExtractFileName(FFileName);
      StatusBar.Panels[1].Text := Trim(IntToStr(lvList.Items.Count));

{$IFDEF STAND_ALONE}
      actHookIDE.Enabled := False;
{$ELSE}
      actHookIDE.Enabled := IsSourceModule(FFileName) or IsInc(FFileName);
      if actHookIDE.Enabled then
        actHookIDE.Checked := UseEditorToolBar;

      if (FFileIndex >= 0) and (FFileIndex < cbbFiles.Items.Count) then
      begin
        cbbFiles.ItemIndex := Wizard.FileIndex;
        if cbbFiles.ItemIndex > 0 then
          cbbFiles.OnChange(cbbFiles);
      end;
{$ENDIF}

      if ShowModal = mrOK then
      begin
        // BringIdeEditorFormToFront;
{$IFNDEF STAND_ALONE}
        CnOtaMakeSourceVisible(CurrentFile);
{$ENDIF}
      end;

{$IFNDEF STAND_ALONE}
      if actHookIDE.Enabled then
        UseEditorToolBar := actHookIDE.Checked;
      SaveSettings(Ini, '');
      DoSaveSettings;
{$ENDIF}
    finally
      Free;
    end;
  finally
{$IFNDEF STAND_ALONE}
    Ini.Free;
{$ENDIF}
  end;
end;

{$IFNDEF STAND_ALONE}

function TCnProcListWizard.GetCaption: string;
begin
  Result := SCnProcListWizardMenuCaption;
end;

function TCnProcListWizard.GetCurrentToolBarObj: TCnProcToolBarObj;
begin
  Result := GetToolBarObjFromEditControl(GetCurrentEditControl);
end;

function TCnProcListWizard.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(Word('D'), [ssCtrl]);
end;

function TCnProcListWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnProcListWizard.GetHint: string;
begin
  Result := SCnProcListWizardMenuHint;
end;

function TCnProcListWizard.GetState: TWizardState;
begin
  if CnOtaGetCurrentSourceFileName <> '' then
    Result := [wsEnabled]
  else
    Result := [];
end;

function TCnProcListWizard.GetToolBarObjFromEditControl(
  EditControl: TControl): TCnProcToolBarObj;
var
  I: Integer;
begin
  Result := nil;
  // 倒序来，容易找点儿，同时避免某些未是否的东西在 FProcToolBarObjects 中重复出错
  for I := FProcToolBarObjects.Count - 1 downto 0 do
    if TCnProcToolBarObj(FProcToolBarObjects[I]).EditControl = EditControl then
    begin
      Result := TCnProcToolBarObj(FProcToolBarObjects[I]);
      Exit;
    end;
end;

class procedure TCnProcListWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnProcListWizardName;
  Author := SCnPack_LiuXiao + ';GExperts Team';
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnProcListWizardComment;
end;

function TCnProcListWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '属性,元素,property,function,element,';
end;

procedure TCnProcListWizard.InitProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
var
  Obj: TCnProcToolBarObj;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Init Proc ToolBar from EditControl %8.8x', [Integer(EditControl)]);
{$ENDIF}
  Obj := GetToolBarObjFromEditControl(EditControl);
  if Obj = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Obj found from EditControl %8.8x', [Integer(Obj)]);
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  InitSizeIfLargeIcon(ToolBar, TImageList(dmCnSharedImages.LargeProcToolbarVirtualImages));
{$ELSE}
  InitSizeIfLargeIcon(ToolBar, dmCnSharedImages.ilProcToolbarLarge);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: ClassCombo Font Size %d', [Obj.ClassCombo.Font.Size]);
{$ENDIF}

  IdeScaleToolbarComboFontSize(Obj.ClassCombo);
  IdeScaleToolbarComboFontSize(Obj.ProcCombo);

  Obj.ToolBtnProcList.Action := FindIDEAction('act' + Copy(ClassName, 2, MaxInt)); // 去 T
  Obj.ToolBtnProcList.Visible := Action <> nil;

  Obj.ToolBtnListUsed.Action := FindIDEAction('act' + SCnProjExtListUsed);
  Obj.ToolBtnListUsed.Visible := Action <> nil;

  if Obj.ToolBtnProcList.ImageIndex < 0 then
    Obj.ToolBtnProcList.ImageIndex := dmCnSharedImages.IdxUnknownInIDE; // 确保有个图标
  if Obj.ToolBtnListUsed.ImageIndex < 0 then
    Obj.ToolBtnListUsed.ImageIndex := dmCnSharedImages.IdxUnknownInIDE;

  Obj.ToolBtnSep1.Visible := (Obj.ToolBtnProcList.Visible or Obj.ToolBtnListUsed.Visible);
  Obj.InternalToolBar1.Visible := Obj.ToolBtnSep1.Visible;

  Obj.ToolBtnJumpIntf.Hint := SCnProcListJumpIntfHint;
  Obj.ToolBtnJumpImpl.Hint := SCnProcListJumpImplHint;

  Obj.ClassCombo.Hint := SCnProcListClassComboHint;
  Obj.ProcCombo.Hint := SCnProcListProcComboHint;
  
  Obj.PopupMenu.Items[0].Caption := SCnProcListSortMenuCaption;

    Obj.PopupMenu.Items[0].Items[0].Caption := SCnProcListSortSubMenuByName;
    Obj.PopupMenu.Items[0].Items[1].Caption := SCnProcListSortSubMenuByLocation;
    Obj.PopupMenu.Items[0].Items[2].Caption := '-';
    Obj.PopupMenu.Items[0].Items[3].Caption := SCnProcListSortSubMenuReverse;

  Obj.PopupMenu.Items[1].Caption := SCnProcListExportMenuCaption;
  Obj.PopupMenu.Items[2].Caption := '-';
  Obj.PopupMenu.Items[3].Caption := SCnEditorEnhanceConfig;
  Obj.PopupMenu.Items[4].Caption := SCnProcListCloseMenuCaption;

  Obj.MatchFrame.mniMatchStart.Caption := SCnMatchButtonFrameMenuStartCaption;
  Obj.MatchFrame.mniMatchStart.Hint := SCnMatchButtonFrameMenuStartHint;
  Obj.MatchFrame.mniMatchAny.Caption := SCnMatchButtonFrameMenuAnyCaption;
  Obj.MatchFrame.mniMatchAny.Hint := SCnMatchButtonFrameMenuAnyHint;
  Obj.MatchFrame.mniMatchFuzzy.Caption := SCnMatchButtonFrameMenuFuzzyCaption;
  Obj.MatchFrame.mniMatchFuzzy.Hint := SCnMatchButtonFrameMenuFuzzyHint;
  Obj.MatchFrame.SyncButtonHint;
  
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProcList: Init Proc ToolBar Complete.');
{$ENDIF}
end;

procedure TCnProcListWizard.JumpImplOnClick(Sender: TObject);
begin
  CheckReparse;
  // 跳到 impl 行数处
  if FImplLine > 0 then
    CurrentGotoLineAndFocusEditControl(FImplLine)
  else
    ErrorDlg(SCnProcListErrorNoImpl);
end;

procedure TCnProcListWizard.JumpIntfOnClick(Sender: TObject);
begin
  CheckReparse;
  // 跳到 intf 行数处
  if FIntfLine > 0 then
    CurrentGotoLineAndFocusEditControl(FIntfLine)
  else
    ErrorDlg(SCnProcListErrorNoIntf);
end;

procedure TCnProcListWizard.LoadSettings(Ini: TCustomIniFile);
begin
  UseEditorToolBar := Ini.ReadBool('', csUseEditorToolbar, True);
  PreviewLineCount := Ini.ReadInteger('', csPreviewLineCount, csDefPreviewLineCount);
  HistoryCount := Ini.ReadInteger('', csHistoryCount, csDefHistoryCount);

  ProcComboHeight := Ini.ReadInteger('', csProcHeight, 0);
  ProcComboWidth := Ini.ReadInteger('', csProcWidth, 0);
  ClassComboHeight := Ini.ReadInteger('', csClassHeight, 0);
  ClassComboWidth := Ini.ReadInteger('', csClassWidth, 0);

  ToolbarClassComboWidth := Ini.ReadInteger('', csToolbarClassComboWidth, 0);
  ToolbarProcComboWidth := Ini.ReadInteger('', csToolbarProcComboWidth, 0);
end;

procedure TCnProcListWizard.OnToolBarTimer(Sender: TObject);
begin
  try
    if FUseEditorToolBar then
      ParseCurrent;
  finally
    FToolBarTimer.Enabled := False;
  end;
end;

procedure TCnProcListWizard.ParseCurrent;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Obj: TCnProcToolBarObj;
  DotPos: Integer;
  S: string;
begin
  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  if FCurrStream = nil then
    FCurrStream := TMemoryStream.Create
  else
    FCurrStream.Clear;

  CnGeneralSaveEditorToStream(EditView.Buffer, FCurrStream);
  S := EditView.Buffer.FileName;

  FLanguage := ltUnknown;
  if IsPas(S) or IsDpr(S) or IsInc(S) then
    FLanguage := ltPas
  else if IsCppSourceModule(S) then
    FLanguage := ltCpp;

  if FLanguage = ltPas then
  begin
    if FCurrPasParser = nil then
      FCurrPasParser := TCnGeneralPasStructParser.Create;

    CnPasParserParseSource(FCurrPasParser, FCurrStream, IsDpr(S) or IsInc(S), False);

    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);

    if not Obj.ClassCombo.Focused then
      Obj.ClassCombo.SetTextWithoutChange(TCnIdeTokenString(FCurrPasParser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex)));

    if not Obj.ProcCombo.Focused then
    begin
      if FCurrPasParser.CurrentChildMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(TCnIdeTokenString(FCurrPasParser.CurrentChildMethod))
      else if FCurrPasParser.CurrentMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(TCnIdeTokenString(FCurrPasParser.CurrentMethod))
      else
        Obj.ProcCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;

    if not Obj.ClassCombo.Focused and (Obj.ClassCombo.Text = '') then
    begin
      DotPos := Pos('.', Obj.ProcCombo.Text);
      if DotPos > 1 then
        Obj.ClassCombo.SetTextWithoutChange(Copy(Obj.ProcCombo.Text, 1, DotPos - 1))
      else
        Obj.ClassCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;
  end
  else if FLanguage = ltCpp then
  begin
    if FCurrCppParser = nil then
      FCurrCppParser := TCnGeneralCppStructParser.Create;

    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    // 是否需要转换？

    CnCppParserParseSource(FCurrCppParser, FCurrStream,
      CharPos.Line, CharPos.CharIndex, True);

    // 记录并显示当前类与当前函数名
    if not Obj.ClassCombo.Focused then
    begin
      if FCurrCppParser.CurrentClass <> '' then
        Obj.ClassCombo.SetTextWithoutChange(TCnIdeTokenString(FCurrCppParser.CurrentClass))
      else
        Obj.ClassCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;

    if not Obj.ProcCombo.Focused then
    begin
      if FCurrCppParser.CurrentMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(TCnIdeTokenString(FCurrCppParser.CurrentMethod))
      else
        Obj.ProcCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;

    if not Obj.ClassCombo.Focused and (Obj.ClassCombo.Text = '') then
    begin
      DotPos := Pos('::', Obj.ProcCombo.Text);
      if DotPos > 1 then
        Obj.ClassCombo.SetTextWithoutChange(Copy(Obj.ProcCombo.Text, 1, DotPos - 1))
      else
        Obj.ClassCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;
  end;
end;

procedure TCnProcListWizard.ProcComboDropDown(Sender: TObject);
var
  ProcCombo: TCnProcListComboBox;
  I, Idx: Integer;
  Info: TCnElementInfo;
  Obj: TCnProcToolBarObj;
  AText: string;
begin
  CheckReparse;
  ProcCombo := Sender as TCnProcListComboBox;
  ProcCombo.DropDownList.InfoItems.Clear;

  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    if (Info <> nil) and (Info.ElementType in [etClassFunc, etSingleFunction,
      etConstructor, etDestructor, etOperator]) then
      ProcCombo.DropDownList.InfoItems.AddObject(Info.Text, Info);
  end;

  if not ProcCombo.ChangeDown then
  begin
    AText := ProcCombo.Text;
    ProcCombo.SetTextWithoutChange('');
    ProcCombo.DropDownList.MatchStr := '';
    ProcCombo.DropDownList.MatchMode := GetMatchMode(Obj);
    ProcCombo.DropDownList.UpdateDisplay;
    if ProcCombo.DropDownList.DisplayItems.Count > 0 then
    begin
      // DropDownList 定位并显示到 AText
      Idx := ProcCombo.DropDownList.DisplayItems.IndexOf(AText);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnProcListWizard.ProcComboDropDown. To Select %d, Text: %s',
        [Idx, AText]);
{$ENDIF}

      // 有待选中条目，则选中其上一个，UpdateDisplay 会再下移一个条目
      if Idx >= 1 then
        ProcCombo.DropDownList.ItemIndex := Idx - 1;

      ProcCombo.ShowDropBox;
    end;
  end;

  CnWizNotifierServices.ExecuteOnApplicationIdle(ProcCombo.RefreshDropBox);
end;

procedure TCnProcListWizard.RemoveProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  RemoveToolBarObjFromEditControl(EditControl);
end;

procedure TCnProcListWizard.RemoveToolBarObjFromEditControl(
  EditControl: TControl);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Prepare to Remove Objs from EditControl %8.8x',
    [Integer(EditControl)]);
{$ENDIF}
  for I := FProcToolBarObjects.Count - 1 downto 0 do
    if TCnProcToolBarObj(FProcToolBarObjects[I]).EditControl = EditControl then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ProcList: Remove Obj %8.8x from EditControl %8.8x',
        [Integer(FProcToolBarObjects[I]), Integer(EditControl)]);
{$ENDIF}
      FProcToolBarObjects.Delete(I);
    end;
end;

procedure TCnProcListWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csUseEditorToolbar, UseEditorToolBar);
  Ini.WriteInteger('', csPreviewLineCount, PreviewLineCount);
  Ini.WriteInteger('', csHistoryCount, HistoryCount);

  Ini.WriteInteger('', csProcHeight, ProcComboHeight);
  Ini.WriteInteger('', csProcWidth, ProcComboWidth);
  Ini.WriteInteger('', csClassHeight, ClassComboHeight);
  Ini.WriteInteger('', csClassWidth, ClassComboWidth);

  Ini.WriteInteger('', csToolbarClassComboWidth, ToolbarClassComboWidth);
  Ini.WriteInteger('', csToolbarProcComboWidth, ToolbarProcComboWidth);
end;

{$ENDIF}

{ TCnProcListFrm }

procedure TCnProcListForm.FormCreate(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  EditorCanvas: TCanvas;
{$ENDIF}
begin
  inherited;
  NeedInitProjectControls := False;
  FOldCaption := Caption;

{$IFDEF STAND_ALONE}
  MatchMode := mmFuzzy;
  btnShowPreview.Down := True;
{$ELSE}
  InitFileComboBox;
  actHookIDE.Visible := CnEditorToolBarService <> nil;
{$ENDIF}
  FObjectList := TStringList.Create;
  FObjectList.Sorted := True;
  FObjectList.Duplicates := dupIgnore;

{$IFNDEF STAND_ALONE}
  EditorCanvas := EditControlWrapper.GetEditControlCanvas(CnOtaGetCurrentEditControl);
  if EditorCanvas <> nil then
  begin
    if EditorCanvas.Font.Name <> mmoContent.Font.Name then
      mmoContent.Font.Name := EditorCanvas.Font.Name;
    mmoContent.Font.Size := EditorCanvas.Font.Size;
    mmoContent.Font.Style := EditorCanvas.Font.Style - [fsUnderline, fsStrikeOut, fsItalic];
  end;
{$ENDIF}

{$IFDEF COMPILER6_UP}
  cbbMatchSearch.AutoComplete := False;
{$ENDIF}

{$IFDEF DELPHI110_ALEXANDRIA_UP}
  actQuery.Visible := True;
  actQuery.Enabled := False;
  btnQuery.Visible := True;
  btnQuery.Enabled := False;
{$ENDIF}
end;

procedure TCnProcListForm.FormShow(Sender: TObject);
begin
  inherited;
  UpdateItemPosition;

  if FPreviewIsRight then
  begin
    mmoContent.Align := alRight;
    Splitter.Align := alRight;
  end;

  UpdateMemoSize(nil);
{$IFDEF DELPHI110_ALEXANDRIA_UP}
  btnClose.Down := False;
  btnQuery.Visible := False;
{$ENDIF}
end;

procedure TCnProcListForm.CreateList;
begin

end;

function TCnProcListForm.DoSelectOpenedItem: string;
begin
  Result := '';
end;

function TCnProcListForm.GetSelectedFileName: string;
begin
  Result := '';
end;

function TCnProcListForm.GetHelpTopic: string;
begin
  Result := 'CnProcListWizard';
end;

procedure TCnProcListWizard.LoadElements(ElementList, ObjectList: TStringList;
  aFileName: string; ToClear: Boolean);
var
  I, BraceCountDelta, PreviousBraceCount, BeginIndex: Integer;
  MemStream: TMemoryStream;
{$IFDEF UNICODE}
  PasParser: TCnPasWideLex;
  CppParser: TCnBCBWideTokenList;
{$ELSE}
  PasParser: TmwPasLex;
  CppParser: TBCBTokenList;
{$ENDIF}
  BeginBracePosition, ClassNamePosition: Longint;
  BraceCount, NameSpaceCount: Integer;
  NameList: TStrings;
  NewName, TmpName, ProcClassAdd, ClassName, TemplateArgs: string;
  UpperIsNameSpace: Boolean;
  BraceStack: TStack;
  ElementType: TCnElementType;

  function GetPasParserLineNumber: Integer;
  begin
{$IFDEF UNICODE}
    Result := PasParser.LineNumber;
{$ELSE}
    Result := PasParser.LineNumber + 1;
{$ENDIF}
  end;

  function IsDprOrInc(const AFile: string): Boolean;
  var
    FileExt: string;
  begin
    FileExt := UpperCase(_CnExtractFileExt(AFile));
    Result := (FileExt = '.INC') or (FileExt = '.DPR');
  end;

  function MoveToImplementation: Boolean;
  begin
    if IsDprOrInc(aFileName) then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    while PasParser.TokenID <> tkNull do
    begin
      if PasParser.TokenID = tkImplementation then
        Result := True;
      PasParser.Next;
      if Result then
        Break;
    end;
  end;

  function GetProperProcName(ProcType: TTokenKind; IsClass: Boolean): string;
  begin
    Result := SCnUnknown;

    case ProcType of
      // Do not localize.
      tkFunction: Result := 'function';
      tkProcedure: Result := 'procedure';
      tkConstructor: Result := 'constructor';
      tkDestructor: Result := 'destructor';
      tkOperator: Result := 'operator';
    else
      Exit;
    end;

    if IsClass then
      Result := 'class ' + Result;
  end;

  function GetProperElementType(ProcType: TTokenKind; IsClass: Boolean): TCnElementType;
  begin
    Result := etUnknown;
    if IsClass then
    begin
      if ProcType in [tkFunction, tkProcedure] then
        Result := etClassFunc
      else if ProcType = tkOperator then
        Result := etOperator
    end
    else
    begin
      case ProcType of
        tkFunction, tkProcedure: Result := etSingleFunction;
        tkConstructor: Result := etConstructor;
        tkDestructor: Result := etDestructor;
        tkOperator: Result := etOperator;
      end;
    end;
  end;

  // 从当前位置往后找最外层的{ 或找上一层是 namespace 的 {
  procedure FindBeginningBrace;
  var
    Prev1, Prev2: TCTokenKind; // 分别表示当前 RunID 的前一个/前两个 id
    CurIsNameSpace, NeedDecBraceCount: Boolean;
  begin
    CurIsNameSpace := False;
    NeedDecBraceCount := False;
    Prev1 := ctknull;

    repeat
      Prev2 := Prev1;
      Prev1 := CppParser.RunID;

      CppParser.NextNonJunk;
      if NeedDecBraceCount then // 如果上次循环记录了bracepair，则留到此时减
      begin
        Dec(BraceCount);
        NeedDecBraceCount := False;
      end;

      case CppParser.RunID of
        ctkbraceopen, ctkbracepair:
          begin
            Inc(BraceCount);

            if BraceStack.Count = 0 then
              UpperIsNameSpace := False
            else
              UpperIsNameSpace := Boolean(BraceStack.Peek);
              // 读堆栈顶的判断上一层次是否为 namespace 的内容

            CurIsNameSpace := (Prev2 = ctknamespace) or (Prev1 = ctknamespace);
            BraceStack.Push(Pointer(CurIsNameSpace));
            if CurIsNameSpace then
              Inc(NameSpaceCount);

            if CppParser.RunID = ctkbracepair then // 空函数体 {} 紧邻时的处理
            begin
              // Dec(BraceCount);  // 留到下次循环时再减，免得下面until判断出错
              NeedDecBraceCount := True;
              if CurIsNameSpace then
                Dec(NameSpaceCount);
              BraceStack.Pop;
            end;
          end;
        ctkbraceclose:
          begin
            Dec(BraceCount);
            try
              if Boolean(BraceStack.Pop) then
                Dec(NameSpaceCount);
            except
              ;
            end;
          end;
        ctknull: Exit;
      end;
    until (CppParser.RunID = ctknull) or
      ((CppParser.RunID in [ctkbraceopen, ctkbracepair]) and not CurIsNameSpace and ((BraceCount = 1) or UpperIsNameSpace));

    if CppParser.RunID = ctkbracepair then
      Dec(BraceCount);
  end;

  procedure FindBeginningProcedureBrace(var Name: string; var AEleType: TCnElementType); // Used for CPP
  var
    InitialPosition: Integer;
    RestorePosition: Integer;
    FoundClass: Boolean;
  begin
    BeginBracePosition := 0;
    ClassNamePosition := 0;
    InitialPosition := CppParser.RunPosition;
    // Skip these: enum {a, b, c};  or  int a[] = {0, 3, 5};  and find  foo () {
    FindBeginningBrace;
    if CppParser.RunID = ctknull then
      Exit;
    CppParser.PreviousNonJunk;
    // 找到最外层的'{'后，回退开始检查是类还是名字空间
    if CppParser.RunID = ctkidentifier then  // 左大括号前是标识符，类似于 class TA { }
    begin
      Name := CppParser.RunToken; // The name
      // This might be a derived class so search backward
      // no further than InitialPosition to see
      RestorePosition := CppParser.RunPosition;
      FoundClass := False;
      while CppParser.RunPosition >= InitialPosition do // 往回找关键字，看有无以下几个
      begin
        if CppParser.RunID in [ctkclass, ctkstruct, ctknamespace] then
        begin
          FoundClass := True;
          ClassNamePosition := CppParser.RunPosition;
          case CppParser.RunID of
            ctkclass: AEleType := etClass;
            ctkstruct: AEleType := etRecord;
            ctknamespace: AEleType := etNamespace;
          else
            AEleType := etUnknown;
          end;
          Break;
        end;
        if CppParser.RunPosition = InitialPosition then
          Break;
        CppParser.PreviousNonJunk;
      end;

      // 如果是类，那么类名是紧靠 : 或 { 前的东西，那么类、结构、名字空间的话就往前找名字
      if FoundClass then //
      begin
        while not (CppParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
        begin
          Name := CppParser.RunToken; // 找到类名或者名字空间名
          CppParser.NextNonJunk;
        end;
        // Back up a bit if we are on a brace open so empty enums don't get treated as namespaces
        if CppParser.RunID = ctkbraceopen then
          CppParser.PreviousNonJunk;
      end;
      // Now get back to where you belong
      while CppParser.RunPosition < RestorePosition do
        CppParser.NextNonJunk;
      CppParser.NextNonJunk;
      BeginBracePosition := CppParser.RunPosition; // 回到最外层的 '{'
    end
    else  // 左大括号前不是标识符，接着判断是否是函数标识
    begin
      if CppParser.RunID in [ctkroundclose, ctkroundpair, ctkconst, ctkvolatile,
        ctknull] then
      begin
        // 以上几个，表示找到函数了
        Name := '';
        CppParser.NextNonJunk;
        BeginBracePosition := CppParser.RunPosition;
      end
      else
      begin
        while not (CppParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull]) do
        begin
          CppParser.NextNonJunk;
          if CppParser.RunID = ctknull then
            Exit;
          // Recurse
          FindBeginningProcedureBrace(Name, ElementType);
          CppParser.PreviousNonJunk;
          if Name <> '' then
            Break;
        end;
        CppParser.NextNonJunk;
      end;
    end;
  end;

  procedure EraseName(Names: TStrings; Index: Integer);
  var
    NameIndex: Integer;
  begin
    NameIndex := Names.IndexOfName(IntToStr(Index));
    if NameIndex <> -1 then
      Names.Delete(NameIndex);
  end;

  function SearchForProcedureName: string;
  var
    ParenCount: Integer;
  begin
    ParenCount := 0;
    Result := '';
    repeat
      CppParser.Previous;
      if CppParser.RunID <> ctkcrlf then
        if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CppParser.RunToken + Result;
      case CppParser.RunID of
        ctkroundclose: Inc(ParenCount);
        ctkroundopen: Dec(ParenCount);
        ctknull: Exit;
      end;
    until ((ParenCount <= 0) and ((CppParser.RunID = ctkroundopen) or
      (CppParser.RunID = ctkroundpair)));
    CppParser.PreviousNonJunk; // This is the procedure name
  end;

  function InProcedureBlacklist(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(ProcBlacklist) to High(ProcBlacklist) do
    begin
      if Name = ProcBlacklist[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  function SearchForTemplateArgs: string;
  var
    AngleCount: Integer;
  begin
    Result := '';
    if CppParser.RunID <> ctkGreater then
      Exit; // Only use if we are on a '>'
    AngleCount := 1;
    Result := CppParser.RunToken;
    repeat
      CppParser.Previous;
      if CppParser.RunID <> ctkcrlf then
        if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CppParser.RunToken + Result;
      case CppParser.RunID of
        ctkGreater: Inc(AngleCount);
        ctklower: Dec(AngleCount);
        ctknull: Exit;
      end;
    until (((AngleCount = 0) and (CppParser.RunID = ctklower)) or
      (CppParser.RunIndex = 0));
    CppParser.PreviousNonJunk; // This is the token before the template args
  end;

  procedure FindEndingBrace(const BraceCountDelta: Integer;
    const DecrementOpenBrace: Boolean);
  var
    aBraceCount: Integer;
  begin
    if DecrementOpenBrace then
      aBraceCount := BraceCountDelta
    else
      aBraceCount := 0;

    repeat
      CppParser.NextNonComment;
      case CppParser.RunID of
        ctkbraceopen: Inc(BraceCount);
        ctkbraceclose: Dec(BraceCount);
        ctknull: Exit;
      end;
    until ((BraceCount - aBraceCount) = NameSpaceCount) or
      (CppParser.RunID = ctknull);
  end;

  procedure FindElements(IsDprFile: Boolean);
  var
    ProcLine: string;
    ProcType, PrevTokenID: TTokenKind;
    Line: Integer;
    ClassLast, IntfLast: Boolean;
    InParenthesis: Boolean;
    InTypeDeclaration: Boolean;
    InIntfDeclaration: Boolean;
    InImplementation: Boolean;
    FoundNonEmptyType: Boolean;
    IdentifierNeeded: Boolean;
    IsExternal: Boolean;
    ProcEndSemicolon: Boolean;
    ElementInfo: TCnElementInfo;
    BeginProcHeaderPosition: Longint;
    J, K: Integer;
    LineNo: Integer;
    ProcName, ProcReturnType, IntfName: string;
    ElementTypeStr, OwnerClass, ProcArgs: string;

    CurIdent, CurClass, CurIntf: string;
    PrevIsOperator, PrevIsTilde: Boolean;
    PrevElementForForward: TCnElementInfo;
    IsClassForForward, IsInTemplate: Boolean;

    // For class sealed or abstract
    IsClassButNotKnown: Boolean;
    CurClassForNotKnown: string;
    NotKnownLineNo: Integer;
  begin
    ElementList.BeginUpdate;
    try
      case FLanguage of
        ltPas:
          begin
            ClassLast := False;
            InParenthesis := False;
            InTypeDeclaration := False;
            InImplementation := IsDprFile;
            InIntfDeclaration := False;
            FoundNonEmptyType := False;
            IsClassForForward := False;
            IsClassButNotKnown := False;
            IsInTemplate := False;
            PrevElementForForward := nil;
            IntfName := '';
            CurIdent := '';
            CurClass := '';
            CurIntf := '';
            CurClassForNotKnown := '';
            PrevTokenID := tkNull;
            NotKnownLineNo := -1;

            while PasParser.TokenID <> tkNull do
            begin
              // 记录下每个 Identifier
              if PasParser.TokenID = tkLower then
              begin
                IsInTemplate := True;
                CurIdent := CurIdent + '<'
              end
              else if PasParser.TokenID = tkGreater then
              begin
                IsInTemplate := False;
                CurIdent := CurIdent + '>';
              end
              else if PasParser.TokenID = tkIdentifier then
              begin
                if IsInTemplate then
                  CurIdent := CurIdent + string(PasParser.Token)
                else
                  CurIdent := string(PasParser.Token);
              end
              else if PasParser.TokenID = tkComma then
              begin
                if IsInTemplate then
                  CurIdent := CurIdent + string(PasParser.Token);
              end
              else if PasParser.TokenID = tkSemicolon then
              begin
                IsInTemplate := False;
                if IsClassForForward and (PrevElementForForward <> nil) then
                  PrevElementForForward.IsForward := True;
              end;
              IsClassForForward := False;
              PrevElementForForward := nil;

              if ((PasParser.TokenID = tkClass) and PasParser.IsClass) or
                (PasParser.TokenID = tkRecord) or
                ((PasParser.TokenID = tkObject) and (PrevTokenID <> tkOf)) then
                CurClass := CurIdent
              else if (PasParser.TokenID = tkClass) and not PasParser.IsClass then
              begin
                CurClassForNotKnown := CurIdent;
              end;
              if PasParser.TokenID = tkInterface then
              begin
                if PasParser.IsInterface then
                  CurIntf := CurIdent
                else if FIntfLine = 0 then
                  FIntfLine := GetPasParserLineNumber;
              end
              else if PasParser.TokenId = tkDispInterface then
              begin
                CurIntf := CurIdent;
              end
              else if (PasParser.TokenID = tkImplementation) and (FImplLine = 0) then
                FImplLine := GetPasParserLineNumber;

              if ((not InTypeDeclaration and InImplementation) or InIntfDeclaration) and
                (PasParser.TokenID in [tkFunction, tkProcedure, tkConstructor, tkDestructor, tkOperator]) then
              begin
                IdentifierNeeded := not (PrevTokenID in [tkAssign, tkRoundOpen, tkComma]);
                // 暂时认为 procedure 前面是 := ( 以及 , 的是匿名函数

                ProcType := PasParser.TokenID;
                Line := GetPasParserLineNumber;
                ProcLine := '';

                // 此循环获得整个 Proc 的声明
                while not (PasParser.TokenId in [tkNull]) do
                begin
                  case PasParser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  if (not InParenthesis) and (PasParser.TokenID in [tkSemiColon,
                    tkVar, tkBegin, tkType, tkConst]) then // 匿名方法声明后无分号，暂且以 begin 或 var 等来判断
                    Break;

                  if not (PasParser.TokenID in [tkCRLF, tkCRLFCo]) then
                    ProcLine := ProcLine + string(PasParser.Token);
                  PasParser.Next;
                end; // while

                // 得到整个 Proc 的声明，ProcLine
                if PasParser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.

                if not IdentifierNeeded then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.Name := ProcLine;
                  if InIntfDeclaration then
                  begin
                    if ProcType = tkProcedure then
                      ElementInfo.ElementTypeStr := 'interface procedure'
                    else if ProcType = tkFunction then
                      ElementInfo.ElementTypeStr := 'interface function'
                    else
                      ElementInfo.ElementTypeStr := 'interface member';
                      
                    ElementInfo.ElementType := etIntfMember;
                    ElementInfo.OwnerClass := IntfName;
                  end
                  else
                  begin
                    ElementInfo.ElementTypeStr := GetProperProcName(ProcType, ClassLast);
                    ElementInfo.ElementType := GetProperElementType(ProcType, ClassLast);
                  end;

                  ElementInfo.LineNo := Line;
                  ElementInfo.FileName := _CnExtractFileName(aFileName);
                  ElementInfo.AllName := aFileName;
                  AddProcedure(ElementList, ObjectList, ElementInfo, InIntfDeclaration);
                end;
              end
              else if not InImplementation and not InTypeDeclaration and not InIntfDeclaration
                and (PasParser.TokenID in [tkFunction, tkProcedure]) then
              begin
                // interface 部分的 function 与 procedure 要考虑 extnernal 的情况
                // 但这处判断 class 里的 procedure/function 也会进去，可能多出很多无谓判断
                IdentifierNeeded := True;
                // interface 部分不会有匿名函数
                IsExternal := False;
                ProcEndSemicolon := False;

                ProcType := PasParser.TokenID;
                Line := GetPasParserLineNumber;
                ProcLine := '';

                // 此循环获得整个 Proc 的声明
                while not (PasParser.TokenId in [tkNull]) do
                begin
                  case PasParser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  // 这里可能碰到 implementation，必须记录行号
                  if (PasParser.TokenID = tkImplementation) and (FImplLine = 0) then
                    FImplLine := GetPasParserLineNumber;

                  if (not InParenthesis) and (PasParser.TokenID in [tkEnd, tkImplementation,
                    tkVar, tkBegin, tkType, tkConst, tkUses]) then // 不能只判断分号，暂且以这些关键字来判断
                    Break;

                  if not (PasParser.TokenID in [tkCRLF, tkCRLFCo]) and not ProcEndSemicolon then
                    ProcLine := ProcLine + string(PasParser.Token);

                  if (not InParenthesis) and (PasParser.TokenID = tkSemicolon) then
                    ProcEndSemicolon := True;

                  PasParser.Next;

                  if PasParser.TokenID = tkExternal then
                  begin
                    IsExternal := True;
                    Break;
                  end;
                end; // while

                // 得到整个 Proc 的声明，ProcLine
                if PasParser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.

                if IsExternal then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.Name := ProcLine;
                  if InIntfDeclaration then
                  begin
                    if ProcType = tkProcedure then
                      ElementInfo.ElementTypeStr := 'interface procedure'
                    else if ProcType = tkFunction then
                      ElementInfo.ElementTypeStr := 'interface function'
                    else
                      ElementInfo.ElementTypeStr := 'interface member';

                    ElementInfo.ElementType := etIntfMember;
                    ElementInfo.OwnerClass := IntfName;
                  end
                  else
                  begin
                    ElementInfo.ElementTypeStr := GetProperProcName(ProcType, ClassLast);
                    ElementInfo.ElementType := GetProperElementType(ProcType, ClassLast);
                  end;

                  ElementInfo.LineNo := Line;
                  ElementInfo.FileName := ExtractFileName('Unknown Filename');
                  ElementInfo.AllName := 'Unknown Filename';
                  AddProcedure(ElementList, ObjectList, ElementInfo, InIntfDeclaration);
                end;
              end;  // 针对 External 判断完成

              if not InIntfDeclaration and (PasParser.TokenID = tkIdentifier) then
                IntfName := string(PasParser.Token);

              if IsClassButNotKnown then
              begin
                IsClassButNotKnown := False;
                if PasParser.TokenID in [tkSealed, tkAbstract] then
                begin
                  // 记录 sealed 或 abstract 类信息
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.LineNo := NotKnownLineNo;
                  ElementInfo.FileName := _CnExtractFileName(aFileName);
                  ElementInfo.AllName := aFileName;
                  ElementInfo.ElementType := etClass;

                  if PasParser.TokenID = tkSealed then
                    ElementInfo.ElementTypeStr := 'class sealed'
                  else
                    ElementInfo.ElementTypeStr := 'class abstract';

                  ElementInfo.Text := CurClassForNotKnown;
                  ElementInfo.OwnerClass := CurClassForNotKnown;
                  ElementInfo.Name := ElementInfo.Text;
                  AddElement(ElementList, ElementInfo);

                  IsClassForForward := True; // 以备后面判断是否是 class; 的前向声明
                  PrevElementForForward := ElementInfo;
                end;
              end;

              if (PasParser.TokenID = tkClass) and PasParser.IsClass then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := False;
                FoundNonEmptyType := False;

                // 记录类信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := _CnExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etClass;
                ElementInfo.ElementTypeStr := 'class';
                ElementInfo.Text := CurClass;
                ElementInfo.OwnerClass := CurClass;
                ElementInfo.Name := ElementInfo.Text;
                AddElement(ElementList, ElementInfo);

                IsClassForForward := True; // 以备后面判断是否是 class; 的前向声明
                PrevElementForForward := ElementInfo;
              end
              else if (PasParser.TokenID = tkClass) and not PasParser.IsClass then
              begin
                // Parser 遇到 class sealed/abstract 时，IsClass 判断有误，需要如此处理一下
                IsClassButNotKnown := True;
                NotKnownLineNo := GetPasParserLineNumber;
              end
              else if ((PasParser.TokenID = tkInterface) and PasParser.IsInterface) or
                (PasParser.TokenID = tkDispInterface) then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := True;
                FoundNonEmptyType := False;

                // 记录接口信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := _CnExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etInterface;
                ElementInfo.ElementTypeStr := 'interface';
                ElementInfo.Text := CurIntf;
                ElementInfo.OwnerClass := CurIntf;
                ElementInfo.Name := ElementInfo.Text;
                AddElement(ElementList, ElementInfo);
              end
              else if (PasParser.TokenID = tkRecord) or
                ((PasParser.TokenID = tkObject) and (PrevTokenID <> tkOf)) then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := False;
                FoundNonEmptyType := False;

                // 记录记录信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := _CnExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etRecord;
                if PasParser.TokenID = tkRecord then
                  ElementInfo.ElementTypeStr := 'record'
                else
                  ElementInfo.ElementTypeStr := 'record object';
                ElementInfo.Text := CurIdent;
                ElementInfo.Name := ElementInfo.Text;
                // ElementInfo.OwnerClass := CurIntf;
                AddElement(ElementList, ElementInfo);
              end
              else if InTypeDeclaration and
                (PasParser.TokenID in [tkProcedure, tkFunction, tkProperty,
                tkPrivate, tkProtected, tkPublic, tkPublished]) then
              begin
                FoundNonEmptyType := True;

                // 记录属性信息
                if PasParser.TokenID = tkProperty then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.LineNo := GetPasParserLineNumber;
                  ElementInfo.FileName := _CnExtractFileName(aFileName);
                  ElementInfo.AllName := aFileName;

                  while PasParser.TokenID <> tkIdentifier do
                    PasParser.Next;

                  if InIntfDeclaration then
                  begin
                    ElementInfo.ElementType := etIntfProperty;
                    ElementInfo.ElementTypeStr := 'interface property';
                    ElementInfo.OwnerClass := CurIntf;
                    ElementInfo.Text := CurIntf + '.' + string(PasParser.Token);
                  end
                  else
                  begin
                    ElementInfo.ElementType := etProperty;
                    ElementInfo.ElementTypeStr := 'property';
                    ElementInfo.OwnerClass := CurClass;
                    ElementInfo.Text := CurClass + '.' + string(PasParser.Token);
                  end;
                  ElementInfo.Name := ElementInfo.Text;
                  AddElement(ElementList, ElementInfo);
                end;
              end
              else if InTypeDeclaration and
                ((PasParser.TokenID = tkEnd) or
                (((PasParser.TokenID = tkSemiColon) and not InIntfDeclaration)
                 and not FoundNonEmptyType)) then
              begin
                InTypeDeclaration := False;
                InIntfDeclaration := False;
                IntfName := '';
              end
              else if PasParser.TokenID = tkImplementation then
              begin
                InImplementation := True;
                InTypeDeclaration := False;
              end
              else if (PasParser.TokenID = tkProgram) or (PasParser.TokenID = tkLibrary) then
              begin
                InImplementation := True; // DPR 和 Lib 等文件无 Interface 部分
              end;

              ClassLast := (PasParser.TokenID = tkClass);
              IntfLast := (PasParser.TokenID = tkInterface);

              if not (PasParser.TokenID in [tkSpace, tkCRLF, tkCRLFCo]) then
                PrevTokenID := PasParser.TokenID;

              if ClassLast or IntfLast then
              begin
                PasParser.NextNoJunk;
              end
              else
                PasParser.Next;
            end;
          end; //ltPas

        ltCpp:
          begin
            BraceCount := 0;
            PreviousBraceCount := 0;
            NameSpaceCount := 0;

            UpperIsNameSpace := False;
            BraceStack := TStack.Create;
            NameList := TStringList.Create;

            try
              // 记录最后的位置，避免从头查找时超过末尾
              J := CppParser.TokenPositionsList[CppParser.TokenPositionsList.Count - 1];
              FindBeginningProcedureBrace(NewName, ElementType);
              // 上面的函数会找到一个类声明或函数声明的开头，如果是类声明等，
              // 类名称会被塞入 NewName 这个变量

              while (CppParser.RunPosition <= J - 1) or (CppParser.RunID <> ctknull) do
              begin
                // NewName = '' 表示是个函数，做函数的处理
                if NewName = '' then
                begin
                  // If we found a brace pair then special handling is necessary
                  // for the bracecounting stuff (it is off by one)
                  if CppParser.RunID = ctkbracepair then
                    BraceCountDelta := 0
                  else
                    BraceCountDelta := 1;

                  if (BraceCountDelta > 0) and (PreviousBraceCount >= BraceCount) then
                    EraseName(NameList, PreviousBraceCount);
                  // Back up a tiny bit so that we are "in front of" the
                  // ctkbraceopen or ctkbracepair we just found
                  CppParser.Previous;

                  // 去找上一个分号，作为本函数的起始
                  // 这个 while 可跨过函数中的冒号，如 __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
                  while not ((CppParser.RunID in [ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair]) or
                      (CppParser.RunID in IdentDirect) or
                    (CppParser.RunIndex = 0)) do
                  begin
                    CppParser.PreviousNonJunk;
                    // Handle the case where a colon is part of a valid procedure definition
                    if CppParser.RunID = ctkcolon then
                    begin
                      // A colon is valid in a procedure definition only if it is immediately
                      // following a close parenthesis (possibly separated by "junk")
                      CppParser.PreviousNonJunk;
                      if CppParser.RunID in [ctkroundclose, ctkroundpair] then
                        CppParser.NextNonJunk
                      else
                      begin
                        // Restore position and stop backtracking
                        CppParser.NextNonJunk;
                        Break;
                      end;
                    end;
                  end;

                  // 找到了往前的一个分号或空白地方，往后一点即是函数开头
                  if CppParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair] then
                    CppParser.NextNonComment
                  else if CppParser.RunIndex = 0 then
                  begin
                    if CppParser.IsJunk then
                      CppParser.NextNonJunk;
                  end
                  else // IdentDirect
                  begin
                    while CppParser.RunID <> ctkcrlf do
                    begin
                      if (CppParser.RunID = ctknull) then
                        Exit;
                      CppParser.Next;
                    end;
                    CppParser.NextNonJunk;
                  end;

                  // 所以到达了一个具体的函数开头
                  BeginProcHeaderPosition := CppParser.RunPosition;

                  ProcLine := '';
                  while (CppParser.RunPosition < BeginBracePosition) and
                    (CppParser.RunID <> ctkcolon) do
                  begin
                    if (CppParser.RunID = ctknull) then
                      Exit
                    else if (CppParser.RunID <> ctkcrlf) then
                      if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
                        ProcLine := ProcLine + #32
                      else
                        ProcLine := ProcLine + CppParser.RunToken;
                    CppParser.NextNonComment;
                  end;
                  // We are at the end of a procedure header
                  // Go back and skip parenthesis to find the procedure name
                  ProcName := '';
                  OwnerClass := '';
                  ProcReturnType := '';
                  ProcArgs := SearchForProcedureName;
                  // We have to check for ctknull and exit since we moved the
                  // code to a nested procedure (if we exit SearchForProcedureName
                  // early due to RunID = ctknull we exit this procedure early as well)
                  if CppParser.RunID = ctknull then
                    Exit;
                  if CppParser.RunID = ctkthrow then
                  begin
                    ProcArgs := CppParser.RunToken + ProcArgs;
                    ProcArgs := SearchForProcedureName + ProcArgs;
                  end;
                  // Since we've enabled nested procedures it is now possible
                  // that we think we've found a procedure but what we've really found
                  // is a standard C or C++ construct (like if or for, etc...)
                  // To guard against this we require that our procedures be of type
                  // ctkidentifier.  If not, then skip this step.
                  CppParser.PreviousNonJunk;
                  PrevIsOperator := CppParser.RunID = ctkoperator;
                  PrevIsTilde := CppParser.RunID = ctktilde;
                  CppParser.NextNonJunk;
                  // 记录前一个是否是关键字 operator
                  if ((CppParser.RunID = ctkidentifier) or PrevIsOperator or PrevIsTilde) and not
                    InProcedureBlacklist(CppParser.RunToken) then
                  begin
                    BeginIndex := CppParser.RunPosition;
                    if PrevIsOperator then
                      ProcName := 'operator ';
                    if PrevIsTilde then
                      ProcName := '~';

                    ProcName := ProcName + CppParser.RunToken;
                    LineNo := CppParser.PositionAtLine(CppParser.RunPosition);
                    CppParser.PreviousNonJunk;

                    if CppParser.RunID = ctktilde then
                      CppParser.PreviousNonJunk;
                    if CppParser.RunID = ctkcoloncolon then
                    // The object/method delimiter
                    begin
                      // There may be multiple name::name::name:: sets here
                      // so loop until no more are found
                      ClassName := '';
                      while CppParser.RunID = ctkcoloncolon do
                      begin
                        CppParser.PreviousNonJunk; // The object name?
                        // It is possible that we are looking at a templatized class and
                        // what we have in front of the :: is the end of a specialization:
                        // ClassName<x, y, z>::Function
                        if CppParser.RunID = ctkGreater then
                          TemplateArgs := SearchForTemplateArgs;
                        OwnerClass := CppParser.RunToken + OwnerClass;
                        if ClassName = '' then
                          ClassName := CppParser.RunToken;
                        CppParser.PreviousNonJunk; // look for another ::
                        if CppParser.RunID = ctkcoloncolon then
                          OwnerClass := CppParser.RunToken + OwnerClass;
                      end;
                      // We went back one step too far so go ahead one
                      CppParser.NextNonJunk;
                      ElementTypeStr := 'procedure';
                      ElementType := etClassFunc;  // Class
                      if ProcName = ClassName then
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end
                      else if ProcName = '~' + ClassName then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end;
                    end
                    else
                    begin
                      ElementTypeStr := 'procedure';
                      ElementType := etSingleFunction; // Single function
                      // If type is a procedure is 1 then we have backed up too far already
                      // so restore our previous position in order to correctly
                      // get the return type information for non-class methods
                      CppParser.NextNonJunk;
                    end;

                    while CppParser.RunPosition > BeginProcHeaderPosition do
                    begin // Find the return type of the procedure
                      CppParser.PreviousNonComment;
                      // Handle the possibility of template specifications and
                      // do not include them in the return type
                      if CppParser.RunID = ctkGreater then
                        TemplateArgs := SearchForTemplateArgs;
                      if CppParser.RunID in [ctktemplate, ctkoperator] then
                        Continue;
                      if CppParser.RunID in [ctkcrlf, ctkspace] then
                        ProcReturnType := ' ' + ProcReturnType
                      else
                      begin
                        ProcReturnType := CppParser.RunToken + ProcReturnType;
                        BeginIndex := CppParser.RunPosition;
                      end;
                    end;
                    // If the return type is an empty string then it must be a constructor
                    // or a destructor (depending on the presence of a ~ in the name
                    if (Trim(ProcReturnType) = '') or (Trim(ProcReturnType) = 'virtual') then
                    begin
                      if Pos('~', ProcName) = 1 then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end
                      else
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end;
                    end;

                    ProcLine := Trim(ProcReturnType) + ' ';

                    // This code sticks enclosure names in front of
                    // methods (namespaces & classes with in-line definitions)
                    ProcClassAdd := '';
                    for K := 0 to BraceCount - BraceCountDelta do
                    begin
                      if K < NameList.Count then
                      begin
                        TmpName := NameList.Values[IntToStr(K)];
                        if TmpName <> '' then
                        begin
                          if ProcClassAdd <> '' then
                            ProcClassAdd := ProcClassAdd + '::';
                          ProcClassAdd := ProcClassAdd + TmpName;
                        end;
                      end;
                    end;

                    if Length(ProcClassAdd) > 0 then
                    begin
                      if Length(OwnerClass) > 0 then
                        ProcClassAdd := ProcClassAdd + '::';
                      OwnerClass := ProcClassAdd + OwnerClass;
                    end;
                    if Length(OwnerClass) > 0 then
                      ProcLine := ProcLine + ' ' + OwnerClass + '::';
                    ProcLine := ProcLine + ProcName + ' ' + ProcArgs;

                    if ElementTypeStr = 'procedure' then
                    begin
                      if (Pos('static ', Trim(ProcReturnType)) = 1) and
                        (Length(OwnerClass) > 0) then
                      begin
                        if Pos('void', ProcReturnType) > 0 then
                          ElementTypeStr := 'class procedure'
                        else
                          ElementTypeStr := 'class function'
                      end
                      else if not Pos('void', ProcReturnType) > 0 then
                        ElementTypeStr := 'function';
                    end;

                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := ProcLine;
                    ElementInfo.ElementTypeStr := ElementTypeStr;
                    ElementInfo.LineNo := LineNo;
                    ElementInfo.OwnerClass := OwnerClass;
                    ElementInfo.ProcArgs := ProcArgs;
                    ElementInfo.ProcReturnType := ProcReturnType;
                    ElementInfo.ElementType := ElementType;
                    ElementInfo.ProcName := ProcName;
                    ElementInfo.FileName := _CnExtractFileName(aFileName);
                    ElementInfo.AllName := aFileName;
                    AddProcedure(ElementList, ObjectList, ElementInfo, False); // TODO: BCB Interface

                    while (CppParser.RunPosition < BeginBracePosition) do
                      CppParser.Next;

                    ElementInfo.BeginIndex := BeginIndex;
                    FindEndingBrace(BraceCountDelta, (BraceCount > 1));
                    ElementInfo.EndIndex := CppParser.RunPosition + 1;
                  end
                  else
                    while (CppParser.RunPosition < BeginBracePosition) do
                      CppParser.Next;
                end
                else
                begin
                  // 找到的是类名，加入处理
                  if ElementType <> etUnknown then
                  begin
                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := NewName;
                    ElementInfo.Text := NewName; // 显示用的
                    ElementInfo.ProcName := NewName; // ProcName 是搜索用的
                    if ElementType = etClass then
                      ElementInfo.OwnerClass := NewName;
                    
                    ElementInfo.ElementType := ElementType;
                    if ClassNamePosition > 0 then
                      ElementInfo.LineNo := CppParser.PositionAtLine(ClassNamePosition);

                    case ElementType of
                      etClass: ElementInfo.ElementTypeStr := 'class';
                      etRecord: ElementInfo.ElementTypeStr := 'struct';
                      etNamespace: ElementInfo.ElementTypeStr := 'namespace';
                    end;
                    ElementInfo.FileName := _CnExtractFileName(aFileName);
                    ElementInfo.AllName := aFileName;
                    AddProcedure(ElementList, ObjectList, ElementInfo, False);
                  end;

                  EraseName(NameList, BraceCount);
                  NameList.Add(IntToStr(BraceCount) + '=' + NewName);
                end;
                PreviousBraceCount := BraceCount;
                FindBeginningProcedureBrace(NewName, ElementType);
              end; // while (RunPosition <= j-1)
            finally
              FreeAndNil(NameList);
              FreeAndNil(BraceStack);
            end;
          end; //Cpp
      end; //case Language
    finally
      ElementList.EndUpdate;
    end;
  end;

begin
  case FLanguage of
{$IFDEF UNICODE}
    ltPas: PasParser := TCnPasWideLex.Create(True);
    ltCpp: CppParser := TCnBCBWideTokenList.Create(True);
{$ELSE}
    ltPas: PasParser := TmwPasLex.Create;
    ltCpp: CppParser := TBCBTokenList.Create;
{$ENDIF}
  end;

{$IFNDEF STAND_ALONE}
  if FIsCurrentFile and (FLanguage = ltPas) then
    FCurElement := EdtGetProcName
  else
{$ENDIF}
    FCurElement := '';

  try
    MemStream := TMemoryStream.Create;
    try
{$IFDEF STAND_ALONE}
      // TODO: 判断编码
      MemStream.LoadFromFile(aFileName);
      FLines.LoadFromStream(MemStream);
{$ELSE}
      with TCnEditFiler.Create(aFileName) do
      try
  {$IFDEF UNICODE}
        SaveToStreamW(MemStream);
  {$ELSE}
        SaveToStream(MemStream, True);
  {$ENDIF}
      finally
        Free;
      end;
{$ENDIF}

      case FLanguage of
        ltPas: PasParser.Origin := MemStream.Memory;
        ltCpp: CppParser.SetOrigin(MemStream.Memory, MemStream.Size);
      end;

      Screen.Cursor := crHourGlass;
      try
        ClearObjectStrings(ObjectList);

        if ToClear then
        begin
          for I := ElementList.Count - 1 downto 0 do
            if ElementList.Objects[I] <> nil then
              TCnElementInfo(ElementList.Objects[I]).Free;

          ElementList.Clear;
        end;

        FindElements(IsDprOrInc(aFileName));
      finally
        Screen.Cursor := crDefault;
      end;
    finally
      MemStream.Free;
    end;
  finally
    case FLanguage of
      ltPas: PasParser.Free;
      ltCpp: CppParser.Free;
    end;
    PasParser := nil;
    CppParser := nil;
  end;
end;

procedure TCnProcListWizard.UpdateDataListImageIndex(ADataList: TStringList);
var
  I: Integer;
  Ele: TCnElementInfo;
begin
  for I := 0 to ADataList.Count - 1 do
  begin
    Ele := TCnElementInfo(ADataList.Objects[I]);
    if Ele <> nil then
      Ele.ImageIndex := CalcSelectImageIndex(Ele, FLanguage);
  end;
end;

procedure TCnProcListForm.LoadSettings(Ini: TCustomIniFile;
  aSection: string);
var
  S: string;
{$IFNDEF STAND_ALONE}
  I: Integer;
{$ENDIF}
begin
  inherited;
  S := Ini.ReadString(aSection, csDropDown, '');
  S := StringReplace(S, csSep, csCRLF, [rfReplaceAll, rfIgnoreCase]);
  cbbMatchSearch.Items.Text := S;
{$IFNDEF STAND_ALONE}
  if cbbMatchSearch.Items.Count > Wizard.HistoryCount then
    for I := cbbMatchSearch.Items.Count - 1 downto Wizard.HistoryCount do
      cbbMatchSearch.Items.Delete(I);
{$ENDIF}

  btnShowPreview.Down := Ini.ReadBool(aSection, csShowPreview, True);
  FPreviewIsRight := Ini.ReadBool(aSection, csPreviewIsRight, False);
  FPreviewHeight := Ini.ReadInteger(aSection, csPreviewHeight, 0);
  FPreviewWidth := Ini.ReadInteger(aSection, csPreviewWidth, 0);
  mmoContent.Visible := btnShowPreview.Down;
  Splitter.Visible := btnShowPreview.Down;
end;

procedure TCnProcListForm.OpenSelect;
{$IFNDEF STAND_ALONE}
var
  ProcInfo: TCnElementInfo;
  Module: IOTAModule;
  SourceEditor: IOTASourceEditor;  
  View: IOTAEditView;
  I: Integer;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  if lvList.Selected <> nil then
  begin
    ProcInfo := lvList.Selected.Data;
    if ProcInfo <> nil then
    begin
      if SelIsCurFile then
      begin
        View := CnOtaGetTopMostEditView;
        if View <> nil then
        begin
          View.Position.GotoLine(ProcInfo.LineNo);
          if ProcInfo.ElementType in [etRecord, etClass, etInterface] then
            View.Position.MoveEOL;
          View.Center(ProcInfo.LineNo, 1);
          View.Paint;
        end;

        if FFiler = nil then
        begin
          FFiler := TCnEditFiler.Create(ProcInfo.AllName);

          FFiler.GotoLine(ProcInfo.LineNo);
          FFiler.ShowSource;
          FFiler.FreeFileData;
        end;
      end
      else
      begin
        // 打开选择的其他文件并定位
        FreeAndNil(FFiler);
        FFiler := TCnEditFiler.Create(ProcInfo.AllName);

        if not CnOtaIsFileOpen(ProcInfo.AllName) then // 文件已经打开
          CnOtaOpenFile(ProcInfo.AllName);

        Module := CnOtaGetModule(ProcInfo.AllName);
        if Module = nil then Exit;
        SourceEditor := CnOtaGetSourceEditorFromModule(Module);
        if SourceEditor = nil then Exit;
        View := CnOtaGetTopMostEditView(SourceEditor);
        if View = nil then Exit;

        View.Position.GotoLine(ProcInfo.LineNo);
        if ProcInfo.ElementType in [etRecord, etClass, etInterface] then
          View.Position.MoveEOL;
        View.Paint;

        FFiler.GotoLine(ProcInfo.LineNo);
        FFiler.ShowSource;
        FFiler.FreeFileData;
      end;

      // 只在此处赋值
      CurrentFile := ProcInfo.AllName;
      ModalResult := mrOk;

      if (cbbMatchSearch.Text <> '') and
        (cbbMatchSearch.Items.IndexOf(cbbMatchSearch.Text) < 0) then
      begin
        if cbbMatchSearch.Items.Count > CnDropDownListCount then
          for I := cbbMatchSearch.Items.Count - 1 downto CnDropDownListCount - 1 do
            cbbMatchSearch.Items.Delete(I);

        cbbMatchSearch.Items.Insert(0, cbbMatchSearch.Text);
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnProcListForm.SaveSettings(Ini: TCustomIniFile;
  aSection: string);
var
  S: string;
begin
  inherited;
  S := StringReplace(cbbMatchSearch.Items.Text, csCRLF, csSep, [rfReplaceAll, rfIgnoreCase]);
  Ini.WriteString(aSection, csDropDown, S);
  Ini.WriteBool(aSection, csShowPreview, btnShowPreview.Down);
  Ini.WriteBool(aSection, csPreviewIsRight, FPreviewIsRight);
  if FPreviewHeight > 0 then
    Ini.WriteInteger(aSection, csPreviewHeight, FPreviewHeight);
  if FPreviewWidth > 0 then
    Ini.WriteInteger(aSection, csPreviewWidth, FPreviewWidth);
end;

procedure TCnProcListForm.UpdateComboBox;
begin

end;

procedure TCnProcListForm.UpdateListView;
begin
  edtMatchSearch.Text := cbbMatchSearch.Text;
  inherited;
  if DisplayList.Count = 0 then
    mmoContent.Clear;
end;

procedure TCnProcListForm.UpdateStatusBar;
const
  CnBeforeLine = 1;
var
  ProcInfo: TCnElementInfo;
  AfterLine: Integer;
{$IFDEF STAND_ALONE}
  K, ML: Integer;
{$ELSE}
  Module: IOTAModule;
  SourceEditor: IOTASourceEditor;
  EditView: IOTAEditView;
  Buffer: IOTAEditBuffer;
{$ENDIF}
begin
  ProcInfo := nil;
  if lvList.Selected <> nil then
    ProcInfo := lvList.Selected.Data;

  if ProcInfo <> nil then
  begin
    StatusBar.Panels[0].Text := ProcInfo.Name;
    StatusBar.Panels[1].Text := Format('%d/%d', [lvList.Selected.Index + 1,
      lvList.Items.Count]);
    StatusBar.Panels[2].Text := ProcInfo.FileName;

    if not btnShowPreview.Down then
      Exit;

    AfterLine := mmoContent.Height div (mmoContent.Font.Size + 2);
    if AfterLine < Wizard.PreviewLineCount then
      AfterLine := Wizard.PreviewLineCount;
    if AfterLine <= 0 then
      AfterLine := 4;

{$IFNDEF STAND_ALONE}
    FSelIsCurFile := ProcInfo.AllName = CurrentFile;
    if not FSelIsCurFile then // 别的打开的文件
    begin
      // 是另一文件，检查此文件是否打开
      if CnOtaIsFileOpen(ProcInfo.AllName) then // 文件已经打开
      begin
        Module := CnOtaGetModule(ProcInfo.AllName);
        if Module <> nil then
        begin
          SourceEditor := CnOtaGetSourceEditorFromModule(Module);
          if SourceEditor <> nil then
          begin
            EditView := CnOtaGetTopMostEditView(SourceEditor);
            if EditView <> nil then
            begin
              Buffer := EditView.GetBuffer;
              if Buffer <> nil then
              begin
                // 此方法不适于未打开的工程源文件
                mmoContent.Lines.Text := CnOtaGetLineText(ProcInfo.LineNo - CnBeforeLine,
                  Buffer, CnBeforeLine + AfterLine);
                SelectMemoOneLine(mmoContent, CnBeforeLine);
                Exit;
              end;
            end;
          end;
        end;
      end;
      // 文件未打开，不宜先打开
      mmoContent.Lines.Text := SCnProcListErrorPreview;
    end
    else // 还是此文件
    begin
      mmoContent.Lines.Text := CnOtaGetLineText(ProcInfo.LineNo - CnBeforeLine,
        nil, CnBeforeLine + AfterLine);
      SelectMemoOneLine(mmoContent, CnBeforeLine);
    end;
{$ELSE}
    mmoContent.Lines.Clear;
    if Wizard.FLines.Count > ProcInfo.LineNo then
    begin
      ML := Wizard.FLines.Count - 1;
      if ML > ProcInfo.LineNo + AfterLine then
        ML := ProcInfo.LineNo + AfterLine;

      mmoContent.Lines.BeginUpdate;
      for K := ProcInfo.LineNo - CnBeforeLine - 1 to ML do
        mmoContent.Lines.Add(Wizard.FLines[K]);
      mmoContent.Lines.EndUpdate;

      SelectMemoOneLine(mmoContent, CnBeforeLine);
    end;
{$ENDIF}
  end
  else
  begin
    StatusBar.Panels[0].Text := '';
    StatusBar.Panels[1].Text := Format('%d/%d', [0, 0]);
    mmoContent.Clear;
  end;
end;

procedure TCnProcListForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  inherited;

{$IFNDEF STAND_ALONE}
  FFiler.Free;
{$ENDIF}
  FObjectList.Free;

  for I := 0 to cbbFiles.Items.Count - 1 do
    if cbbFiles.Items.Objects[I] <> nil then
    begin
      TCnFileInfo(cbbFiles.Items.Objects[I]).Free;
      cbbFiles.Items.Objects[I] := nil;
    end;
end;

procedure TCnProcListForm.SetFileName(const Value: string);

  function IsDprOrPasOrInc(const AFile: string): Boolean;
  var
    FileExt: string;
  begin
    FileExt := UpperCase(_CnExtractFileExt(AFile));
    Result := (FileExt = '.INC') or (FileExt = '.DPR') or (FileExt = '.PAS');
  end;

begin
  FFileName := Value;
  FIsCurrentFile := False;
  if IsDprOrPasOrInc(Value) then
    FLanguage := ltPas
  else
    FLanguage := ltCpp;
end;

procedure TCnProcListForm.LoadObjectComboBox(ObjectList: TStringList);
begin
  cbbProjectList.Items.Assign(ObjectList);
  cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProcListObjsAll);
end;

procedure TCnProcListWizard.AddElement(ElementList: TStringList; ElementInfo: TCnElementInfo);
begin
  ElementList.AddObject(#9 + ElementInfo.Text + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
end;

procedure TCnProcListWizard.AddProcedure(ElementList, ObjectList: TStringList;
  ElementInfo: TCnElementInfo; IsIntf: Boolean);
var
  TempStr: string;
  I, J, K1, K2: Integer;
begin
{$IFNDEF STAND_ALONE}
  ElementInfo.Name := CompressWhiteSpace(ElementInfo.Name);
{$ENDIF}
  case FLanguage of
    ltPas:
      begin
        TempStr := ElementInfo.Name;
        // Remove the class reserved word
        I := Pos('CLASS ', UpperCase(TempStr)); // Do not localize.
        if I = 1 then
          Delete(TempStr, 1, Length('CLASS ')); // Do not localize.
        // Remove 'function' or 'procedure'
        I := Pos(' ', TempStr);
        J := Pos('(', TempStr);
        if (I > 0) and (I < J) then // 匿名函数没有函数名
          TempStr := Copy(TempStr, I + 1, Length(TempStr))
        else if (I > 0) and (J = 0) then
        begin
          J := Pos(';', TempStr); // 没有括号的函数，有分号也可以，但得处理分号是在注释内的情况
          if J > I then
          begin
            K1 := Pos('{', TempStr);
            K2 := Pos('}', TempStr);

            // 简单处理 {}。如果分号是注释内，也就是 K1 < J < K2，那么只要 Copy 到 K1
            if (K1 < J) and (J < K2) then
              TempStr := Copy(TempStr, I + 1, K1 - I - 1)
            else
              TempStr := Copy(TempStr, I + 1, Length(TempStr));
          end;
        end;

        // 为 Interface 的成员声明加上 Interface 名
        if IsIntf and (ElementInfo.OwnerClass <> '') then
          TempStr := ElementInfo.OwnerClass + '.' + TempStr;

        // Remove the paramater list
        I := Pos('(', TempStr);
        if I > 0 then
          TempStr := Copy(TempStr, 1, I - 1);
        // Remove the function return type
        I := Pos(':', TempStr);
        if I > 0 then
          TempStr := Copy(TempStr, 1, I - 1);
        // Check for an implementation procedural type
        if Length(TempStr) = 0 then
        begin
          TempStr := '<anonymous>';
        end;
        // Remove any trailing ';'
        if TempStr[Length(TempStr)] = ';' then
          Delete(TempStr, Length(TempStr), 1);
        TempStr := Trim(TempStr);
        if (LowerCase(TempStr) = 'procedure') or (LowerCase(TempStr) = 'function') then
          TempStr := '<anonymous>';

        ElementInfo.Text := TempStr;
        // Add to the object comboBox and set the object name in ElementInfo
        if Pos('.', TempStr) = 0 then
        begin
          ObjectList.Add(SCnProcListObjsNone);
          if IsIntf and (ElementInfo.OwnerClass <> '') then
            ObjectList.Add(ElementInfo.OwnerClass);
        end
        else
        begin
          ElementInfo.OwnerClass := Copy(TempStr, 1, Pos('.', TempStr) - 1);
          ObjectList.Add(ElementInfo.OwnerClass);
        end;
        ElementList.AddObject(#9 + TempStr + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
      end; //ltPas

    ltCpp:
      begin
        if not (ElementInfo.ElementType in [etClass, etRecord, etNamespace]) then
        begin
          // 只对函数类型的才如此处理
          if Length(ElementInfo.OwnerClass) > 0 then
            ElementInfo.Text := ElementInfo.OwnerClass + '::';

          ElementInfo.Text := ElementInfo.Text + ElementInfo.ProcName;
        end;

        ElementList.AddObject(#9 + ElementInfo.Text + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
        if Length(ElementInfo.OwnerClass) = 0 then
          ObjectList.Add(SCnProcListObjsNone)
        else
          ObjectList.Add(ElementInfo.OwnerClass);
      end; //ltCpp
  end; //case Language
end;

function TCnProcListForm.GetMethodName(const ProcName: string): string;
var
  CharPos, LTPos: Integer;
  TempStr: string;
begin
  Result := ProcName;
  if Pos('.', Result) = 1 then
    Delete(Result, 1, 1);

  CharPos := Pos(#9, Result);
  if CharPos <> 0 then
    Delete(Result, CharPos, Length(Result));

  TempStr := Result;
  LTPos := Pos('<', Result);
  CharPos := Pos(' ', Result);
  if CharPos < LTPos then     // 避免从 Test<TKey, TValue> 这种中间截断
    TempStr := Copy(Result, CharPos + 1, Length(Result));

  CharPos := Pos('.', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    TempStr := Copy(TempStr, CharPos + 1, Length(TempStr));

  CharPos := Pos('(', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    Result := Copy(TempStr, 1, CharPos - 1);

  Result := Trim(Result);
end;

procedure TCnProcListForm.lvListData(Sender: TObject; Item: TListItem);
var
  ElementInfo: TCnElementInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    ElementInfo := TCnElementInfo(DisplayList.Objects[Item.Index]);
    if ElementInfo <> nil then
    begin
      Item.Caption := ElementInfo.Text;
      Item.ImageIndex := ElementInfo.ImageIndex;
      Item.SubItems.Add(ElementInfo.ElementTypeStr);
      Item.SubItems.Add(IntToStr(ElementInfo.LineNo));
      Item.SubItems.Add(ElementInfo.FileName);
{$IFNDEF STAND_ALONE}
      RemoveListViewSubImages(Item);
{$ENDIF}
      Item.Data := ElementInfo;
    end;
  end;
end;

procedure TCnProcListForm.btnShowPreviewClick(Sender: TObject);
begin
  if btnShowPreview.Down then
  begin
    if FPreviewIsRight then
    begin
      mmoContent.Align := alRight;
      Splitter.Align := alRight;
    end
    else
    begin
      mmoContent.Align := alBottom;
      Splitter.Align := alBottom;
    end;

    mmoContent.Visible := True;
    Splitter.Visible := True;
  end
  else
  begin
    mmoContent.Visible := False;
    Splitter.Visible := False;

    if mmoContent.Align = alRight then
      FPreviewWidth := mmoContent.Width
    else
      FPreviewHeight := mmoContent.Height;
  end;

  UpdateStatusBar;
end;

procedure TCnProcListForm.DoLanguageChanged(Sender: TObject);
begin
  ToolBar.ShowCaptions := True;
  ToolBar.ShowCaptions := False;
end;

procedure TCnProcListForm.FontChanged(AFont: TFont);
begin
  inherited;
  mmoContent.Font := AFont;  // 之前注释掉了，可能字体改变会引发其他问题但不确定，现暂时放开
end;

procedure TCnProcListForm.cbbMatchSearchChange(Sender: TObject);
begin
  if not cbbMatchSearch.DroppedDown then
    UpdateListView;
end;

procedure TCnProcListForm.cbbMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin           
  if cbbMatchSearch.DroppedDown then
  begin
    // 暂时不做啥
  end
  else // 未下拉时按普通处理
  begin
    if not (((Key = VK_F4) and (ssAlt in Shift)) or
      ((Key = VK_DOWN) and (ssAlt in Shift)) or
      (Key in [VK_DELETE, VK_LEFT, VK_RIGHT, VK_HOME, VK_END]) or
      ((Key in [VK_INSERT]) and ((ssShift in Shift) or (ssCtrl in Shift)))) then
    begin
      SendMessage(lvList.Handle, WM_KEYDOWN, Key, 0);
      Key := 0;
    end;
  end;
end;

procedure TCnProcListForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if cbbMatchSearch.DroppedDown then
    UpdateListView
  else if Key = #22 then
  begin
    if cbbMatchSearch.Focused then
    begin
      if Clipboard.HasFormat(CF_TEXT) then
      begin
        SendMessage(cbbMatchSearch.Handle, WM_PASTE, 0, 0);
        cbbMatchSearch.Text := Trim(cbbMatchSearch.Text);
        Key := #0;
      end;  
    end;  
  end
  else
    inherited;
end;

procedure TCnProcListForm.UpdateItemPosition;
var
  I, J: Integer;
  ProcName: string;
  ProcInfo: TCnElementInfo;
begin
  if (FCurElement <> '') and (FCurElement <> SCnUnknownNameResult) then
  begin
    lvList.Selected := nil;
    for I := 0 to DataList.Count - 1 do
    begin
      ProcInfo := TCnElementInfo(DataList.Objects[I]);
      if ProcInfo = nil then
        Continue;

      case FLanguage of
        ltPas: ProcName := ProcInfo.Text;
        ltCpp: ProcName := ProcInfo.ProcName;
      end;

      if SameText(FCurElement, ProcName) and (I >= 1) then
      begin
        for J := 0 to lvList.Items.Count - 1 do
        begin
          // TODO: 没考虑嵌套的情况
          if lvList.Items[J].Data = DataList.Objects[I - 1] then
          begin
            lvList.Selected := lvList.Items[J];
            lvList.ItemFocused := lvList.Selected;
            lvList.Selected.MakeVisible(True);
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCnProcListForm.cbbFilesDropDown(Sender: TObject);
begin
{$IFNDEF STAND_ALONE}
  if not FFilesGot then
  begin
    LoadFileComboBox;
    FFilesGot := True;
  end;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

procedure TCnProcListForm.InitFileComboBox;
begin
  cbbFiles.Items.Clear;
  cbbFiles.Items.Add(SCnProcListCurrentFile);
  cbbFiles.Items.Add(SCnProcListAllFileInProject);
  cbbFiles.Items.Add(SCnProcListAllFileInProjectGroup);
  cbbFiles.Items.Add(SCnProcListAllFileOpened);
  cbbFiles.ItemIndex := 0;
end;

procedure TCnProcListForm.LoadFileComboBox;
var
  I, J: Integer;
  ModuleInfo: IOTAModuleInfo;
  Project: IOTAProject;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
  ProjectInterfaceList: TInterfaceList;

  procedure AddAFileToComboBox(aFile, aProject: string);
  var
    FileInfo: TCnFileInfo;
  begin
    if aFile = '' then Exit;

    if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
      or IsTypeLibrary(aFile) or IsInc(aFile) then
    begin
      FileInfo := TCnFileInfo.Create;
      FileInfo.ProjectName := aProject;
      FileInfo.FileName := _CnExtractFileName(aFile);
      FileInfo.AllName := aFile;

      cbbFiles.Items.AddObject(FileInfo.FileName, FileInfo);
    end;
  end;
begin
  ProjectInterfaceList := TInterfaceList.Create;
  try
    CnOtaGetProjectList(ProjectInterfaceList);
    for I := 0 to ProjectInterfaceList.Count - 1 do
    begin
      Project := IOTAProject(ProjectInterfaceList[I]);
      if Project <> nil then
      begin
{$IFDEF BDS}
        // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
        if Supports(Project, IOTAProjectGroup, ProjectGroup) then
          Continue;
{$ENDIF}
        AddAFileToComboBox(Project.FileName, Project.FileName);
        for J := 0 to Project.GetModuleCount - 1 do
        begin
          ModuleInfo := Project.GetModule(J);
          if ModuleInfo <> nil then
            AddAFileToComboBox(ModuleInfo.FileName, Project.FileName);
        end;
      end;
    end;
  finally
    ProjectInterfaceList.Free;
  end;
end;

{$ENDIF}

procedure TCnProcListForm.cbbFilesChange(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  I, J: Integer;
  aFile: string;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  ModuleInfo: IOTAModuleInfo;
  ModuleServices: IOTAModuleServices;
  FirstFile: Boolean;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  FirstFile := True;
  if cbbFiles.Items.Objects[cbbFiles.ItemIndex] <> nil then
  begin
    FIsCurrentFile := TCnFileInfo(cbbFiles.Items.Objects[cbbFiles.ItemIndex]).AllName = CurrentFile;
    aFile := TCnFileInfo(cbbFiles.Items.Objects[cbbFiles.ItemIndex]).AllName;
    Wizard.LoadElements(DataList, FObjectList, aFile);
    Wizard.UpdateDataListImageIndex(DataList);
  end
  else
  begin
    case cbbFiles.ItemIndex of
    0: // 当前文件
      begin
        FIsCurrentFile := True;
        Wizard.LoadElements(DataList, FObjectList, CnOtaGetCurrentSourceFileName);
        Wizard.UpdateDataListImageIndex(DataList);
      end;
    1: // 当前工程
      begin
        FIsCurrentFile := False;
        Project := CnOtaGetCurrentProject;
        if Project <> nil then
        begin
          for I := 0 to Project.GetModuleCount - 1 do
          begin
            ModuleInfo := Project.GetModule(I);
            if ModuleInfo <> nil then
            begin
              aFile := ModuleInfo.FileName;
              if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
                or IsTypeLibrary(aFile) or IsInc(aFile) then
              begin
                Wizard.LoadElements(DataList, FObjectList, aFile, FirstFile);
                Wizard.UpdateDataListImageIndex(DataList);
                FirstFile := False;
              end;
            end;
          end;
        end;
      end;
    2: // 当前工程组
      begin
        FIsCurrentFile := False;
        ProjectGroup := CnOtaGetProjectGroup;
        if ProjectGroup <> nil then
        begin
          for J := 0 to ProjectGroup.ProjectCount - 1 do
          begin
            Project := ProjectGroup.Projects[J];
            if Project <> nil then
            begin
              for I := 0 to Project.GetModuleCount - 1 do
              begin
                ModuleInfo := Project.GetModule(I);
                if ModuleInfo <> nil then
                begin
                  aFile := ModuleInfo.FileName;
                  if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
                    or IsTypeLibrary(aFile) or IsInc(aFile) then
                  begin
                    Wizard.LoadElements(DataList, FObjectList, aFile, FirstFile);
                    Wizard.UpdateDataListImageIndex(DataList);
                    FirstFile := False;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    3: // 所有打开的单元
      begin
        FIsCurrentFile := False;
        QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
        for I := 0 to ModuleServices.GetModuleCount - 1 do
        begin
          aFile := CnOtaGetFileNameOfModule(ModuleServices.GetModule(I));
          if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
            or IsTypeLibrary(aFile) or IsInc(aFile) then
          begin
            Wizard.LoadElements(DataList, FObjectList, aFile, FirstFile);
            Wizard.UpdateDataListImageIndex(DataList);
            FirstFile := False;
          end;
        end;
      end;
    end;
  end;

  UpdateListView;
  LoadObjectCombobox(FObjectList);
  UpdateItemPosition;
  UpdateStatusBar;

  if Visible then
    cbbMatchSearch.SetFocus;
  Wizard.FileIndex := cbbFiles.ItemIndex;
{$ENDIF}
end;

procedure TCnProcListForm.lvListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_BACK] then
  begin
    //PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      cbbMatchSearch.SetFocus;
    except
      ;
    end;
  end;
end;

procedure TCnProcListForm.lvListKeyPress(Sender: TObject; var Key: Char);
begin
  if CharInSet(Key, ['0'..'9', 'a'..'z', 'A'..'Z']) then
  begin
    PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      cbbMatchSearch.SetFocus;
    except
      ;
    end;
    Key := #0;
  end;
end;

procedure TCnProcListForm.PrepareSearchRange;
begin
  inherited;
  FObjName := cbbProjectList.Text;
  FIsObjAll := SameText(FObjName, SCnProcListObjsAll);
  FIsObjNone := SameText(FObjName, SCnProcListObjsNone);
end;

function TCnProcListForm.CanMatchDataByIndex(const AMatchStr: string;
  AMatchMode: TCnMatchMode; DataListIndex: Integer; var StartOffset: Integer;
  MatchedIndexes: TList): Boolean;
var
  Info: TCnElementInfo;
  ProcName: string;
  IsObject: Boolean;
  Offset, I: Integer;

{$IFDEF STAND_ALONE}
  // 搬移过来的判断正则表达式匹配
  function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
    APattern: string; IsMatchStart: Boolean = False): Boolean;
  begin
    Result := True;
    if (APattern = '') or (ARegExpr = nil) then Exit;

    if IsMatchStart and (APattern[1] <> '^') then // 额外的从头匹配
      APattern := '^' + APattern;

    ARegExpr.Expression := APattern;
    try
      Result := ARegExpr.Exec(AText);
    except
      Result := False;
    end;
  end;
{$ENDIF}
begin
  Result := False;
  if (AMatchStr = '') and FIsObjAll then
  begin
    Result := True;
    Exit;
  end;

  Info := TCnElementInfo(DataList.Objects[DataListIndex]);
  if Info = nil then
    Exit;

  Offset := 0;
  case FLanguage of
    ltPas:
      begin
        // 只搜函数名，不搜包括类名在内的函数名
        ProcName := GetMethodName(Info.Text);
        Offset := Pos(ProcName, Info.Text);
      end;

    ltCpp:
      begin
        ProcName := Info.ProcName;
        Offset := Pos(ProcName, Info.Text);  // 如果是构造函数就会出现重复，导致 Offset 为 1，下面额外处理一下
        if Offset = 1 then
        begin
          Offset := Pos(':' + ProcName, Info.Text);
          if Offset > 0 then
            Inc(Offset)
          else
            Offset := 1;
        end;
      end;
  end;
  IsObject := Length(Info.OwnerClass) > 0;

  // 查独立东西时是 Object 的则不加
  if FIsObjNone and IsObject then
    Exit;

  // 查指定 Class 时，如非 Class 则不加
  if not FIsObjAll and not FIsObjNone and not SameText(FObjName, Info.OwnerClass) then
    Exit;

  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  if AMatchMode in [mmStart, mmAnywhere] then
  begin
    // 因为不搜类名，所以要将偏移传出去
    Result := RegExpContainsText(FRegExpr, ProcName, AMatchStr, AMatchMode = mmStart);
    StartOffset := Offset;
  end
  else
  begin
    Result := FuzzyMatchStr(AMatchStr, ProcName, MatchedIndexes);
    // 因为不搜类名，所以查找到的 MatchedIndexes 要加上偏移
    if Result and (Offset > 0) then
    begin
      Dec(Offset);
      for I := 0 to MatchedIndexes.Count - 1 do
        MatchedIndexes[I] := Pointer(Integer(MatchedIndexes[I]) + Offset);
    end;
  end;
end;

function TCnProcListForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnElementInfo;
begin
  Info1 := TCnElementInfo(Obj1);
  Info2 := TCnElementInfo(Obj2);

  case ASortIndex of
  0:
    begin
      Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
    end;
  1:
    begin
      Result := CompareText(Info1.ElementTypeStr, Info2.ElementTypeStr);
    end;
  2:
    begin
      Result := CompareValue(Info1.LineNo, Info2.LineNo);
    end;
  3:
    begin
      Result := CompareText(Info1.FileName, Info2.FileName);
    end;
  else
    Result := 0;
  end;

  if SortDown and (ASortIndex in [1..3]) then
    Result := -Result;
end;

procedure TCnProcListForm.SplitterMoved(Sender: TObject);
begin
  if FPreviewIsRight then
    FPreviewWidth := mmoContent.Width
  else
    FPreviewHeight := mmoContent.Height;
  UpdateStatusBar;
end;

procedure TCnProcListForm.btnPreviewRightClick(Sender: TObject);
begin
  btnPreviewRight.Down := True;
  btnPreviewDown.Down := False;
  FPreviewIsRight := True;
end;

procedure TCnProcListForm.btnPreviewDownClick(Sender: TObject);
begin
  btnPreviewDown.Down := True;
  btnPreviewRight.Down := False;
  FPreviewIsRight := False;
end;

procedure TCnProcListForm.UpdateMemoSize(Sender: TObject);
const
  csStep = 5;
var
  I, Steps, Distance: Integer;
begin
  if FPreviewIsRight then
  begin
{$IFNDEF STAND_ALONE}
    RestorePreviewWidth;
{$ENDIF}
  end
  else
  begin
    if FPreviewHeight > 0 then
    begin
      Distance := mmoContent.Height - FPreviewHeight;
      Steps := Abs(Distance div csStep);
      if Distance > 0 then
        for I := 1 to Steps do
          mmoContent.Height := mmoContent.Height - csStep
      else
        for I := 1 to Steps do
          mmoContent.Height := mmoContent.Height + csStep;
    end;
  end;
end;

procedure TCnProcListForm.RestorePreviewHeight;
begin
  if FPreviewHeight > 0 then
    mmoContent.Height := FPreviewHeight;
end;

procedure TCnProcListForm.RestorePreviewWidth;
begin
  if FPreviewWidth > 0 then
    mmoContent.Width := FPreviewWidth;
end;

function TCnProcListForm.DisableLargeIcons: Boolean;
begin
  Result := True; // 大图标会引发工具栏按钮混乱
end;

{ TCnProcListWizard }

{$IFNDEF STAND_ALONE}

procedure TCnProcListWizard.SetUseEditorToolBar(const Value: Boolean);
begin
  if FUseEditorToolBar <> Value then
  begin
    FUseEditorToolBar := Value;
    EditorToolBarEnable(Active and FUseEditorToolBar);
  end;
end;

procedure TCnProcListWizard.DoIdleComboChange(Sender: TObject);
var
  Info: TCnElementInfo;
  Idx, I: Integer;
begin
  if FComboToSearch = nil then
    Exit;

  Idx := FComboToSearch.DropDownList.ItemIndex;
  if Idx = -1 then
    for I  := 0 to FComboToSearch.DropDownList.Items.Count - 1 do
      if FComboToSearch.DropDownList.Selected[I] then
      begin
        Idx := I;
        Break;
      end;  
      
  if Idx = -1 then
    Idx := FComboToSearch.DropDownList.DisplayItems.IndexOf(FComboToSearch.Text);
  if Idx >= 0 then
  begin
    Info := TCnElementInfo(FComboToSearch.DropDownList.DisplayItems.Objects[Idx]);
    CurrentGotoLineAndFocusEditControl(Info);
  end;
  FComboToSearch := nil;
end;

procedure TCnProcListWizard.CurrentGotoLineAndFocusEditControl(
  Info: TCnElementInfo);
var
  View: IOTAEditView;
  EditControl: TControl;
begin
  if Info = nil then Exit;

  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.Position.GotoLine(Info.LineNo);
    if Info.ElementType in [etRecord, etInterface, etClass] then
      View.Position.MoveEOL;
    View.Center(Info.LineNo, 1);
    View.Paint;

    EditControl := GetCurrentEditControl;
    if (EditControl <> nil) and (EditControl is TWinControl) then
    try
      (EditControl as TWinControl).SetFocus;
    except
      ;
    end;
  end;
end;

procedure TCnProcListWizard.CurrentGotoLineAndFocusEditControl(Line: Integer);
var
  View: IOTAEditView;
  EditControl: TControl;
begin
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.Position.GotoLine(Line);
    View.Center(Line, 1);
    View.Paint;

    EditControl := GetCurrentEditControl;
    if (EditControl <> nil) and (EditControl is TWinControl) then
      (EditControl as TWinControl).SetFocus;
  end;
end;

procedure TCnProcListWizard.PopupCloseItemClick(Sender: TObject);
begin
  InfoDlg(SCnProcListCloseToolBarHint);
  UseEditorToolBar := False;
  DoSaveSettings;
end;

procedure TCnProcListWizard.PopupSubItemSortByClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    GListSortIndex := (Sender as TMenuItem).Tag;
  (Sender as TMenuItem).Checked := True;
  FNeedReParse := True;
end;

procedure TCnProcListWizard.PopupSubItemReverseClick(Sender: TObject);
begin
  GListSortReverse := not GListSortReverse;
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  FNeedReParse := True;
end;

procedure TCnProcListWizard.PopupExportItemClick(Sender: TObject);
var
  List: TStrings;
  Dlg: TSaveDialog;
  I: Integer;
  Info: TCnElementInfo;
begin
  CheckReparse;

  Dlg := nil;
  List := nil;

  try
    Dlg := TSaveDialog.Create(nil);
    Dlg.Filter := 'Text Files(*.txt)|*.txt|All Files(*.*)|*.*';
    if Dlg.Execute then
    begin
      List := TStringList.Create;
      List.Add('Classes:');

      for I := 0 to FElementList.Count - 1 do
      begin
        Info := TCnElementInfo(FElementList.Objects[I]);
        if (Info <> nil) and (Info.ElementType in [etRecord, etClass, etInterface]) then
          List.Add(Info.Text);
      end;

      List.Add('');
      List.Add('Procedures:');
      for I := 0 to FElementList.Count - 1 do
      begin
        Info := TCnElementInfo(FElementList.Objects[I]);
        if (Info <> nil) and (Info.ElementType in [etClassFunc, etSingleFunction,
          etConstructor, etDestructor]) then
          List.Add(Info.Text);
      end;
      List.Add('');

      List.SaveToFile(Dlg.FileName);
    end;
  finally
    List.Free;
    Dlg.Free;
  end;
end;

procedure TCnProcListWizard.EditorToolBarEnable(const Value: Boolean);
begin
  if CnEditorToolBarService <> nil then
  begin
    if Value then
    begin
      if FEditorToolBarType <> '' then
        CnEditorToolBarService.SetVisible(FEditorToolBarType, True)
      else
      begin
        FEditorToolBarType := ClassName;
        CnEditorToolBarService.RegisterToolBarType(FEditorToolBarType,
          CreateProcToolBar, InitProcToolBar, RemoveProcToolBar);
        if FToolBarTimer = nil then
        begin
          FToolBarTimer := TTimer.Create(nil);
          FToolBarTimer.Enabled := False;
          FToolBarTimer.Interval := 500;
          FToolBarTimer.OnTimer := OnToolBarTimer;
        end;
      end;
    end
    else
    begin
      if FEditorToolBarType <> '' then
        CnEditorToolBarService.SetVisible(FEditorToolBarType, False);
    end;
  end
  else
    FUseEditorToolBar := False;
end;

procedure TCnProcListWizard.SetActive(Value: Boolean);
begin
  inherited;
  EditorToolBarEnable(Active and FUseEditorToolBar);
end;

//==============================================================================
// 查找下拉列表框
//==============================================================================

{ TCnProcDrowDownBox }

procedure TCnProcDropDownBox.ListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  AText: string;
  Info: TCnElementInfo;
  MatchedIndexesRef: TList;
  ColorFont, ColorBrush: TColor;
  M: Integer;

  function GetListImageIndex(Info: TCnElementInfo): Integer;
  begin
    case Info.ElementType of
      etClassFunc:      Result := 41;   // 方法
      etSingleFunction: Result := 20;   // 独立
      etConstructor:    Result := 12;   // 构造
      etDestructor:     Result := 31;   // 析构
      etClass:          Result := 90;
      etInterface:      Result := 91;
      etProperty :      Result := 92;
      etRecord:         Result := 36;
    else
      Result := 20;
    end;
  end;

begin
  if Index >= FDisplayItems.Count then
    Exit;

  // 自画 ListBox 中的 List
  with Control as TCnProcDropDownBox do
  begin
    Canvas.Font := Font;
    if odSelected in State then
    begin
      ColorBrush := SelectBackColor;
      ColorFont := SelectFontColor;
    end
    else
    begin
      ColorBrush := BackColor;
      ColorFont := FontColor;
    end;

    Canvas.Brush.Color := ColorBrush;
    Canvas.Font.Color := ColorFont;

    Info := TCnElementInfo(FDisplayItems.Objects[Index]);
    Canvas.FillRect(Rect);
    M := (Rect.Bottom - Rect.Top - dmCnSharedImages.Images.Height) div 2;
    if M < 0 then
      M := 0;

    dmCnSharedImages.Images.Draw(Canvas, Rect.Left + M + 2,
      Rect.Top + M, GetListImageIndex(Info));
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := [fsBold];

    AText := FDisplayItems[Index];
    MatchedIndexesRef := nil;
    if FDisplayItems.Objects[Index] <> nil then
    begin
      Info := TCnElementInfo(FDisplayItems.Objects[Index]);
      if (Info.MatchIndexes <> nil) and (Info.MatchIndexes.Count > 0) then
        MatchedIndexesRef := Info.MatchIndexes;
    end;

    DrawMatchText(Canvas, MatchStr, FDisplayItems[Index], Rect.Left +
      IdeGetScaledPixelsFromOrigin(CN_ICON_WIDTH, Control), Rect.Top,
      MatchColor, MatchedIndexesRef);
  end;
end;

procedure TCnProcDropDownBox.CloseUp;
begin
  if Visible then
    SavePosition;

  inherited;
end;

procedure TCnProcDropDownBox.SavePosition;
begin
  if (FWizard <> nil) and (Owner <> nil) then
  begin
    if Owner.Name = csProcComboName then
    begin
      FWizard.ProcComboHeight := IdeGetOriginPixelsFromScaled(Height, Self);
      FWizard.ProcComboWidth := IdeGetOriginPixelsFromScaled(Width, Self);
    end
    else if Owner.Name = csClassComboName then
    begin
      FWizard.ClassComboHeight := IdeGetOriginPixelsFromScaled(Height, Self);
      FWizard.ClassComboWidth := IdeGetOriginPixelsFromScaled(Width, Self);
    end;
  end;
end;

procedure TCnProcDropDownBox.CMHintShow(var Message: TMessage);
var
  Index: Integer;
  P: TPoint;
  S: string;
begin
  Message.Result := 1;
  if Assigned(FOnItemHint) and GetCursorPos(P) then
  begin
    P := ScreenToClient(P);
    Index := ItemAtPos(P, True);
    if Index >= 0 then
    begin
      FOnItemHint(Self, Index, S);
      if S <> '' then
      begin
        TCMHintShow(Message).HintInfo^.HintStr := S;
        Message.Result := 0;
      end;
    end;
  end;
end;

constructor TCnProcDropDownBox.Create(AOwner: TComponent);
const
  csMinDispItems = 6;
  csDefDispItems = 16;
  csMinDispWidth = 500;
  csDefDispWidth = 300;
begin
  inherited;

  Constraints.MinHeight := ItemHeight * csMinDispItems + 4;
  Constraints.MinWidth := csMinDispWidth;
  Height := ItemHeight * csDefDispItems + 8;
  Width := csDefDispWidth;
  Font.Size := csDefProcDropDownBoxFontSize;
  FLastItem := -1;

  FDisplayItems := TStringList.Create;
  FInfoItems := TStringList.Create;
  OnDrawItem := ListDrawItem;

  FRegExpr := TRegExpr.Create;
  FRegExpr.ModifierI := True;
end;

destructor TCnProcDropDownBox.Destroy;
begin
  FRegExpr.Free;
  FDisplayItems.Free;
  FInfoItems.Free;
  inherited;
end;

procedure TCnProcDropDownBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  inherited;
  if Shift = [] then
  begin
    Index := ItemAtPos(Point(X, Y), True);
    if Index <> FLastItem then
    begin
      FLastItem := Index;
      Application.CancelHint;
      if Index >= 0 then
      begin
        try
          Selected[Index] := True;
        except
          // 上句 D5 下会出错，怪事。
          try
            ItemIndex := Index;
          except
            ;
          end;
        end;
        Application.ActivateHint(ClientToScreen(Point(X, Y)));
      end;
    end;
  end;
end;

procedure TCnProcDropDownBox.UpdateListFont;
var
  S: Integer;

  procedure AdjustListItemHeight;
  var
    O: Integer;
  begin
    try
      // 根据字号变化动态调整 ItemHeight
      O := Canvas.Font.Size;
      Canvas.Font.Size := Font.Size;
      S := Canvas.TextHeight('Aj');
      Canvas.Font.Size := O;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('ProcDropDownBox AdjustListItemHeight. Calc Font Size %d', [S]);
{$ENDIF}

      if S > 16 then
        S := S + 2
      else
        S := 16; // 最小 16

      if S <> ItemHeight then
      begin
        ItemHeight := S;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('ProcDropDownBox List ItemHeight Changed to %d', [ItemHeight]);
{$ENDIF}
      end;
    except
      ;
    end;
  end;

begin
  if WizOptions.SizeEnlarge <> wseOrigin then
  begin
    S := WizOptions.CalcIntEnlargedValue(WizOptions.SizeEnlarge, csDefProcDropDownBoxFontSize);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ProcDropDownBox Enlarge Mode. Should Set Font Size to %d', [S]);
{$ENDIF}
    if Font.Size <> S then
    begin
      Font.Size := S;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ProcDropDownBox List Font Change Size to %d', [Font.Size]);
{$ENDIF}
    end;
  end
  else if Font.Size <> csDefProcDropDownBoxFontSize then
  begin
    Font.Size := csDefProcDropDownBoxFontSize;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Input Helper List Font Size Restored to %d', [Font.Size]);
{$ENDIF}
  end;
  AdjustListItemHeight;
end;

procedure TCnProcListWizard.PopupEditorEnhanceConfigItemClick(Sender: TObject);
var
  Wizard: TCnIDEEnhanceWizard;
begin
  Wizard := TCnIDEEnhanceWizard(CnWizardMgr.WizardByClassName('TCnSrcEditorEnhance'));
  if Wizard <> nil then
    Wizard.Config;
end;

procedure TCnProcListWizard.AfterThemeChange(Sender: TObject);
begin
{$IFDEF IDE_SUPPORT_THEMING}
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoThemeChange);
{$ENDIF}
end;

{$IFDEF IDE_SUPPORT_THEMING}

procedure TCnProcListWizard.DoThemeChange(Sender: TObject);
var
  I: Integer;
  Obj: TCnProcToolBarObj;
  Theming: IOTAIDEThemingServices;
begin
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, Theming) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Procedure Toolbar Got Theme Changed Notification.');
{$ENDIF}
    for I := FProcToolBarObjects.Count - 1 downto 0 do
    begin
      Obj := TCnProcToolBarObj(FProcToolBarObjects[I]);
      if (Obj <> nil) and (Obj.EditorToolBar <> nil) then
      begin
        try
          Theming.ApplyTheme(Obj.EditorToolBar);
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Procedure Toolbar Apply Theme for ' + IntToStr(I));
{$ENDIF}
        except
          ;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

{$ENDIF}

{$IFNDEF STAND_ALONE}

{ TCnProcListComboBox }

procedure TCnProcListComboBox.Change;
var
  Obj: TCnProcToolBarObj;
  OldSel, OldSelLength: Integer;
begin
  inherited;
  if FDisableChange then Exit;

  OldSel := SelStart;
  OldSelLength := SelLength;

  if Text = '' then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnProcListComboBox.Change: NO Text. Hide');
{$ENDIF}
    FDropDownList.Hide;
    FDropDownList.SavePosition;
    Exit;
  end;

  if not FDropDownList.Visible then
  begin
    FChangeDown := True;
    if Assigned(OnButtonClick) then // 手工下拉前，触发下拉事件
      OnButtonClick(Self);
    FChangeDown := False;
  end;

  FDropDownList.MatchStr := Text;
  Obj := FWizard.GetCurrentToolBarObj;
  FDropDownList.MatchMode := GetMatchMode(Obj);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnProcListComboBox.Change: To UpdateDisplay and ShowDropBox');
{$ENDIF}

  FDropDownList.UpdateDisplay;
  if not FDropDownList.Visible then
    ShowDropBox;

  SelStart := OldSel;
  SelLength := OldSelLength;
end;

procedure TCnProcListComboBox.CNKeyDown(var Message: TWMKeyDown);
var
  AShortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Message.KeyData);
  AShortCut := ShortCut(Message.CharCode, ShiftState);
  Message.Result := 1;
  if not HandleEditShortCut(Self, AShortCut) then
    inherited;
end;

procedure TCnProcListComboBox.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_LBUTTONDOWN then
    FFocusedClick := Focused; // 记录鼠标左键点下时有无焦点，有才能处理自动下拉

  inherited;
  if Message.Msg = WM_KILLFOCUS then
  begin
    if FDropDownList.Visible then
    begin
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end;
    Message.Result := 0;
  end;
end;

constructor TCnProcListComboBox.Create(AOwner: TComponent);
begin
  inherited;
  LinkStyle := lsDropDown;
  FDropDownList := TCnProcDropDownBox.Create(Self);
  FDropDownList.Name := 'DropDownList';
  FDropDownList.Parent := Application.MainForm;
  FDropDownList.OnDblClick := DropDownListDblClick;
  FDropDownList.OnClick := DropDownListClick;

  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
end;

destructor TCnProcListComboBox.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  inherited;
end;

procedure TCnProcListComboBox.RefreshDropBox(Sender: TObject);
begin
  FDropDownList.Invalidate;
end;

procedure TCnProcListComboBox.DropDownListDblClick(Sender: TObject);
begin
  PostMessage(Handle, WM_KEYDOWN, VK_RETURN, 0);
end;

procedure TCnProcListComboBox.DropDownListClick(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnProcListComboBox.DropDownListClick');
{$ENDIF}
  if FDropDownList.FDisableClickFlag then
  begin
    // 屏蔽一次单击下拉触发事件
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnProcListComboBox.DropDownListClick Ignore One');
{$ENDIF}
    FDropDownList.FDisableClickFlag := False;
    Exit;
  end;

  if FDropDownList.ItemIndex >= 0 then
    PostMessage(Handle, WM_KEYDOWN, VK_RETURN, 0);
end;

procedure TCnProcListComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
  begin
    if FDropDownList.Visible then
    begin
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end;
    Key := 0;
  end
  else if (Key = VK_RETURN) and (Shift = []) then
  begin
    // 无则下拉，已下拉则定位
    if FDropDownList.Visible then
    begin
      FWizard.FComboToSearch := Self;
      CnWizNotifierServices.ExecuteOnApplicationIdle(FWizard.DoIdleComboChange);
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end
    else
    begin
      CnWizNotifierServices.ExecuteOnApplicationIdle(RefreshDropBox);
    end;
    Key := 0;
  end
  else if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT] then
  begin
    FDropDownList.FDisableClickFlag := True; 
    PostMessage(FDropDownList.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
  end;
  inherited;
end;

procedure TCnProcListComboBox.KeyPress(var Key: Char);
begin
  if Key = #13 then
    Key := #0;
  inherited;
end;  

procedure TCnProcDropDownBox.UpdateDisplay;
var
  I, HeightCount, AHeight: Integer;
  HeightSet: Boolean;
  Info: TCnElementInfo;
begin
  FDisplayItems.Clear;
  if MatchMode in [mmStart, mmAnywhere] then
  begin
    for I := 0 to FInfoItems.Count - 1 do
      if RegExpContainsText(FRegExpr, FInfoItems[I], FMatchStr, MatchMode = mmStart) then
        FDisplayItems.AddObject(FInfoItems[I], FInfoItems.Objects[I]);
  end
  else
  begin
    for I := 0 to FInfoItems.Count - 1 do
    begin
      Info := TCnElementInfo(FInfoItems.Objects[I]);
      Info.MatchIndexes.Clear;
      if (FMatchStr = '') or FuzzyMatchStr(FMatchStr, FInfoItems[I], Info.MatchIndexes) then
        FDisplayItems.AddObject(FInfoItems[I], Info);
    end;
  end;

  SetCount(FDisplayItems.Count);
  if FDisplayItems.Count > 12 then
    HeightCount := 12
  else if FDisplayItems.Count < 6 then
    HeightCount := 6
  else
    HeightCount := FDisplayItems.Count;

  AHeight := ItemHeight * HeightCount + 8;
  HeightSet := False;

  if (FWizard <> nil) and (Owner <> nil) then
  begin
    if Owner.Name = csProcComboName then
    begin
      if IdeGetScaledPixelsFromOrigin(FWizard.ProcComboWidth, Self) > 100 then
        Width := IdeGetScaledPixelsFromOrigin(FWizard.ProcComboWidth, Self);
      if IdeGetScaledPixelsFromOrigin(FWizard.ProcComboHeight, Self) > AHeight then
      begin
        Height := IdeGetScaledPixelsFromOrigin(FWizard.ProcComboHeight, Self);
        HeightSet := True;
      end;
    end
    else if Owner.Name = csClassComboName then
    begin
      if IdeGetScaledPixelsFromOrigin(FWizard.ClassComboWidth, Self) > 100 then
        Width := IdeGetScaledPixelsFromOrigin(FWizard.ClassComboWidth, Self);
      if IdeGetScaledPixelsFromOrigin(FWizard.ClassComboHeight, Self) > AHeight then
      begin
        Height := IdeGetScaledPixelsFromOrigin(FWizard.ClassComboHeight, Self);
        HeightSet := True;
      end;
    end;
  end;

  if not HeightSet then
    Height := AHeight;

  if FDisplayItems.Count > 0 then
  begin
    FDisableClickFlag := True;
    PostMessage(Handle, WM_KEYDOWN, VK_DOWN, 0); // 选中首条
  end;
end;

procedure TCnProcListComboBox.ShowDropBox;
begin
  UpdateDropPosition;
  FDropDownList.UpdateListFont;
  FDropDownList.Popup;
end;

procedure TCnProcDropDownBox.SetMatchStr(const Value: string);
begin
  FMatchStr := UpperCase(Value);
end;

procedure TCnProcListComboBox.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
  if (Parent <> nil) and FDropDownList.Visible then
    UpdateDropPosition;
end;

procedure TCnProcListComboBox.UpdateDropPosition;
var
  P: TPoint;
begin
  P.x := Left;
  P.y := Top + Height;
  P := Parent.ClientToScreen(P);
  FDropDownList.SetPos(P.x, P.y);
end;

procedure TCnProcListComboBox.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  case Msg.message of
    WM_MOUSEWHEEL:  // 处理鼠标滚轮事件
      if FDropDownList.Visible then
      begin
        SendMessage(FDropDownList.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
        Handled := True;
        Msg.message := 0;
        Msg.wParam := 0;
        Msg.lParam := 0;
      end;
    { 暂时先不处理其他消息导致List关闭的情况
    WM_SYSKEYDOWN, WM_SETFOCUS:
      if FDropDownList.Visible then
        FDropDownList.CloseUp;
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN:
      if (Msg.hwnd <> FDropDownList.Handle) and FDropDownList.Visible then
        FDropDownList.CloseUp;
    }
  end;
end;

procedure TCnProcListComboBox.SetTextWithoutChange(const AText: TCnIdeTokenString);
begin
  FDisableChange := True;
  Text := AText;
{$IFDEF IDE_STRING_ANSI_UTF8}
  if HandleAllocated then // Unicode 支持，但似乎不起作用，还是有问号乱码
  begin
    SetWindowTextW(Handle, PWideChar(AText));
    Perform(CM_TEXTCHANGED, 0, 0);
  end;
{$ENDIF}
  FDisableChange := False;
end;

procedure TCnProcListComboBox.Click;
var
  W: Integer;
  P: TPoint;
  ACanvas: TControlCanvas;
begin
  inherited;
// 本来点击前如果没焦点，此次点击只是获取焦点，不应下拉，但去掉了这个限制
//  if not FFocusedClick then
//    Exit;

  P := Mouse.CursorPos;
  P := ScreenToClient(P);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnProcListComboBox.Click at X %d, Button Left Edge %d',
    [P.X, ClientWidth - ButtonWidth]);
{$ENDIF}

  if P.X > ClientWidth - ButtonWidth then // 鼠标点击位置在按钮上则啥也不做
    Exit;

  // 鼠标点击位置是否在文字右侧
  ACanvas := TControlCanvas.Create;
  try
    ACanvas.Control := Self;
    W := ACanvas.TextWidth(Text);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnProcListComboBox.Click at X %d, Text Width %d', [P.X, W]);
{$ENDIF}
  finally
    ACanvas.Free;
  end;

  if P.X > W then
    DoMarginClick;
end;

procedure TCnProcListComboBox.DoMarginClick;
begin
  if Assigned(FOnMarginClick) then
    FOnMarginClick(Self);
end;

{ TCnProcToolBarObj }

procedure TCnProcToolBarObj.CloseUpList;
begin
  if FProcCombo <> nil then
    FProcCombo.DropDownList.CloseUp;
  if FClassCombo <> nil then
    FClassCombo.DropDownList.CloseUp;
end;

procedure TCnProcToolBarObj.MatchChange(Sender: TObject);
begin
  CloseUpList;
  if FProcCombo <> nil then
    FProcCombo.Text := '';
  if FClassCombo <> nil then
    FClassCombo.Text := '';
end;

initialization
  RegisterCnWizard(TCnProcListWizard); // 注册专家

{$ENDIF}
{$ENDIF CNWIZARDS_CNPROCLISTWIZARD}
end.

