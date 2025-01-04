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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizIdeUtils;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 CnIdeWizUtils 单元声明
* 单元作者：CnPack 开发组
* 备    注：本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, Forms, ComCtrls,
  ExtCtrls, Menus, Buttons, Tabs,
{$IFNDEF VER130}
  DesignIntf,
{$ENDIF}
  ToolsAPI;

type
  TCnModuleSearchType = (mstInvalid, mstProject, mstProjectSearch, mstSystemSearch);
  {* 搜索到的源码位置类型：非法、工程内、工程搜索目录内、系统搜索目录内}

//==============================================================================
// IDE 代码编辑器功能函数
//==============================================================================

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
{* 取得当前代码编辑器选择行的代码，使用整行模式。如果选择块为空，则返回当前行代码。}

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
{* 取得当前代码编辑器选择块的代码。}

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
{* 取得当前代码编辑器全部源代码。}

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
{* 替换当前代码编辑器选择行的代码，使用整行模式。如果选择块为空，则替换当前行代码。}

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
{* 替换当前代码编辑器选择块的代码。}

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
{* 替换当前代码编辑器全部源代码。}

function IdeInsertTextIntoEditor(const Text: string): Boolean;
{* 插入文本到当前编辑器，支持多行文本。}

function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
{* 返回当前光标位置，如果 EditView 为空使用当前值。 }

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
{* 移动光标到指定位置，Middle 表示是否移动视图到中心。}

function IdeGetBlockIndent: Integer;
{* 获得当前编辑器块缩进宽度 }

function IdeGetSourceByFileName(const FileName: string): string;
{* 根据文件名取得内容。如果文件在 IDE 中打开，返回编辑器中的内容，否则返回文件内容。}

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
{* 根据文件名写入内容。如果文件在 IDE 中打开，写入内容到编辑器中，否则如果
   OpenInIde 为真打开文件写入到编辑器，OpenInIde 为假直接写入文件。}

//==============================================================================
// IDE 窗体编辑器功能函数
//==============================================================================

function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* 取得窗体编辑器的设计器，FormEditor 为 nil 表示取当前窗体 }

function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
{* 取得当前设计的窗体 }

function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
{* 取得当前设计窗体上已选择的组件 }
 
//==============================================================================
// 修改自 GExperts Src 1.12 的 IDE 相关函数
//==============================================================================

function GetIdeMainForm: TCustomForm;
{* 返回 IDE 主窗体 (TAppBuilder) }

function GetIdeEdition: string;
{* 返回 IDE 版本}

function GetComponentPaletteTabControl: TTabControl;
{* 返回组件面板对象，可能为空，只支持 2010 以下版本}

function GetNewComponentPaletteTabControl: TWinControl;
{* 返回 2010 或以上的新组件面板上半部分 Tab 对象，可能为空}

function GetNewComponentPaletteComponentPanel: TWinControl;
{* 返回 2010 或以上的新组件面板下半部分容纳组件列表的容器对象，可能为空}

function GetObjectInspectorForm: TCustomForm;
{* 返回对象检查器窗体，可能为空}

function GetComponentPalettePopupMenu: TPopupMenu;
{* 返回组件面板右键菜单，可能为空}

function GetComponentPaletteControlBar: TControlBar;
{* 返回组件面板所在的ControlBar，可能为空}

function GetMainMenuItemHeight: Integer;
{* 返回主菜单项高度 }

function IsIdeEditorForm(AForm: TCustomForm): Boolean;
{* 判断指定窗体是否编辑器窗体}

function IsIdeDesignForm(AForm: TCustomForm): Boolean;
{* 判断指定窗体是否是设计期窗体}

procedure BringIdeEditorFormToFront;
{* 将源码编辑器设为活跃}

function IDEIsCurrentWindow: Boolean;
{* 判断 IDE 是否是当前的活动窗口 }

//==============================================================================
// 其它的 IDE 相关函数
//==============================================================================

function GetInstallDir: string;
{* 取编译器安装目录}

{$IFDEF BDS}
function GetBDSUserDataDir: string;
{* 取得 BDS (Delphi8/9) 的用户数据目录 }
{$ENDIF}

procedure GetProjectLibPath(Paths: TStrings);
{* 取当前工程组的相关 Path 内容}

function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
{* 根据模块名获得完整文件名}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
{* 获取当前项目中的版本信息键值}

procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean = True);
{* 取环境设置中的 LibraryPath 内容}

function GetComponentUnitName(const ComponentName: string): string;
{* 取组件定义所在的单元名}

procedure GetInstalledComponents(Packages, Components: TStrings);
{* 取已安装的包和组件，参数允许为 nil（忽略）}

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
{* 返回编辑器窗口的编辑器控件 }

function GetCurrentEditControl: TControl;
{* 返回当前的代码编辑器控件 }

function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
{* 从编辑器控件获得其所属的编辑器窗口的状态栏}

function GetCurrentSyncButton: TControl;
{* 获取当前最前端编辑器的语法编辑按钮，注意语法编辑按钮存在不等于可见}

function GetCurrentSyncButtonVisible: Boolean;
{* 获取当前最前端编辑器的语法编辑按钮是否可见，无按钮或不可见均返回 False}

function GetCodeTemplateListBox: TControl;
{* 返回编辑器中的代码模板自动输入框}

function GetCodeTemplateListBoxVisible: Boolean;
{* 返回编辑器中的代码模板自动输入框是否可见，无或不可见均返回 False}

function IsCurrentEditorInSyncMode: Boolean;
{* 当前编辑器是否在语法块编辑模式下，不支持或不在块模式下返回 False}

function IsKeyMacroRunning: Boolean;
{* 当前是否在键盘宏的录制或回放，不支持或不在返回 False}

function GetCurrentCompilingProject: IOTAProject;
{* 返回当前正在编译的工程，注意不一定是当前工程}

function CompileProject(AProject: IOTAProject): Boolean;
{* 编译工程，返回编译是否成功}

//==============================================================================
// 组件面板封装类
//==============================================================================

type

{ TCnPaletteWrapper }

  TCnPaletteWrapper = class(TObject)
  private
    function GetActiveTab: string;
    function GetEnabled: Boolean;
    function GetIsMultiLine: Boolean;
    function GetPalToolCount: Integer;
    function GetSelectedIndex: Integer;
    function GetSelectedToolName: string;
    function GetSelector: TSpeedButton;
    function GetTabCount: Integer;
    function GetTabIndex: Integer;
    function GetTabs(Index: Integer): string;
    function GetVisible: Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetSelectedIndex(const Value: Integer);
    procedure SetTabIndex(const Value: Integer);
    procedure SetVisible(const Value: Boolean);

  public
    constructor Create;

    procedure BeginUpdate;
    {* 开始更新，禁止刷新页面 }
    procedure EndUpdate;
    {* 停止更新，恢复刷新页面 }
    function SelectComponent(const AComponent: string; const ATab: string): Boolean;
    {* 根据类名选中控件板中的某控件 }
    function FindTab(const ATab: string): Integer;
    {* 查找某页面的索引 }
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* 按下的控件在本页的序号，0 开头 }
    property SelectedToolName: string read GetSelectedToolName;
    {* 按下的控件的类名，未按下则为空 }
    property Selector: TSpeedButton read GetSelector;
    {* 用来切换到鼠标光标的 SpeedButton }
    property PalToolCount: Integer read GetPalToolCount;
    {* 当前页控件个数 }
    property ActiveTab: string read GetActiveTab;
    {* 当前页标题 }
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* 当前页索引 }
    property Tabs[Index: Integer]: string read GetTabs;
    {* 根据索引得到页名称 }
    property TabCount: Integer read GetTabCount;
    {* 控件板总页数 }
    property IsMultiLine: Boolean read GetIsMultiLine;
    {* 控件板是否多行 }
    property Visible: Boolean read GetVisible write SetVisible;
    {* 控件板是否可见 }
    property Enabled: Boolean read GetEnabled write SetEnabled;
    {* 控件板是否使能 }
  end;

{ TCnMessageViewWrapper }

{$IFDEF BDS}
  TXTreeView = TCustomControl;
{$ELSE}
  TXTreeView = TTreeView;
{$ENDIF BDS}

  TCnMessageViewWrapper = class(TObject)
  {* 封装了消息显示窗口的各个属性的类 }
  private
    FMessageViewForm: TCustomForm;
    FEditMenuItem: TMenuItem;
    FTabSet: TTabSet;
    FTreeView: TXTreeView;
{$IFNDEF BDS}
    function GetMessageCount: Integer;
    function GetSelectedIndex: Integer;
    procedure SetSelectedIndex(const Value: Integer);
    function GetCurrentMessage: string;
{$ENDIF}
    function GetTabCaption: string;
    function GetTabCount: Integer;
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetTabSetVisible: Boolean;
  public
    constructor Create;

    procedure UpdateAllItems;

    procedure EditMessageSource;
    {* 双击信息窗口}

    property MessageViewForm: TCustomForm read FMessageViewForm;
    {* 信息窗口}
    property TreeView: TXTreeView read FTreeView;
    {* 信息树组件实例，BDS 下非 TreeView，因此只能返回 CustomControl }
{$IFNDEF BDS}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* 信息中选中的序号}
    property MessageCount: Integer read GetMessageCount;
    {* 现有的信息数}
    property CurrentMessage: string read GetCurrentMessage;
    {* 当前选中的信息，但似乎老是返回空}
{$ENDIF}
    property TabSet: TTabSet read FTabSet;
    {* 返回分页组件的实例}
    property TabSetVisible: Boolean read GetTabSetVisible;
    {* 返回分页组件是否可见，D5 下默认不可见}
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* 返回/设置当前页序号}
    property TabCount: Integer read GetTabCount;
    {* 返回总页数}
    property TabCaption: string read GetTabCaption;
    {* 返回当前页的字符串}
    property EditMenuItem: TMenuItem read FEditMenuItem;
    {* '编辑'菜单项}
  end;

{ TCnEditControlWrapper }

  TCnEditControlInfo = record
  {* 代码编辑器位置信息 }
    TopLine: Integer;         // 顶行号
    LinesInWindow: Integer;   // 窗口显示行数
    LineCount: Integer;       // 代码缓冲区总行数
    CaretX: Integer;          // 光标X位置
    CaretY: Integer;          // 光标Y位置
    CharXIndex: Integer;      // 字符序号
{$IFDEF BDS}
    LineDigit: Integer;       // 编辑器总行数的位数，如100行为3, 计算而来
{$ENDIF}
  end;

  TEditorChangeType = (
    ctView,                   // 当前视图切换
    ctWindow,                 // 窗口首行、尾行变化
    ctCurrLine,               // 当前光标行
    ctCurrCol,                // 当前光标列
    ctFont,                   // 字体变更
    ctVScroll,                // 编辑器垂直滚动
    ctHScroll,                // 编辑器横向滚动
    ctBlock,                  // 块变更
    ctModified,               // 编辑内容修改
    ctTopEditorChanged,       // 当前显示的上层编辑器变更
{$IFDEF BDS}
    ctLineDigit,              // 编辑器总行数位数变化，如99到100
{$ENDIF}
    ctElided,                 // 编辑器行折叠，有限支持
    ctUnElided,               // 编辑器行展开，有限支持
    ctOptionChanged           // 编辑器设置对话框曾经打开过
    );

  TEditorChangeTypes = set of TEditorChangeType;

  TCnEditorContext = record
    TopRow: Integer;               // 视觉上第一行的行号
    BottomRow: Integer;            // 视觉上最下面一行的行号
    LeftColumn: Integer;
    CurPos: TOTAEditPos;
    LineCount: Integer;            // 记录编辑器里的文字总行数
    LineText: string;
    ModTime: TDateTime;
    BlockValid: Boolean;
    BlockSize: Integer;
    BlockStartingColumn: Integer;
    BlockStartingRow: Integer;
    BlockEndingColumn: Integer;
    BlockEndingRow: Integer;
    EditView: Pointer;
{$IFDEF BDS}
    LineDigit: Integer;       // 编辑器总行数的位数，如100行为3, 计算而来
{$ENDIF}
  end;

  TEditorObject = class
  private
    FLines: TList;
    FLastTop: Integer;
    FLastBottomElided: Boolean;
    FLinesChanged: Boolean;
    FTopControl: TControl;
    FContext: TCnEditorContext;
    FEditControl: TControl;
    FEditWindow: TCustomForm;
    FEditView: IOTAEditView;
    FGutterWidth: Integer;
    FGutterChanged: Boolean;
    FLastValid: Boolean;
    procedure SetEditView(AEditView: IOTAEditView);
    function GetGutterWidth: Integer;
    function GetViewLineNumber(Index: Integer): Integer;
    function GetViewLineCount: Integer;
    function GetViewBottomLine: Integer;
    function GetTopEditor: TControl;
  public
    constructor Create(AEditControl: TControl; AEditView: IOTAEditView);
    destructor Destroy; override;
    function EditorIsOnTop: Boolean;
    procedure IDEShowLineNumberChanged;
    property Context: TCnEditorContext read FContext;
    property EditControl: TControl read FEditControl;
    property EditWindow: TCustomForm read FEditWindow;
    property EditView: IOTAEditView read FEditView;
    property GutterWidth: Integer read GetGutterWidth;

    // 当前显示在最前面的编辑控件
    property TopControl: TControl read FTopControl;
    // 视图中有效行数
    property ViewLineCount: Integer read GetViewLineCount;
    // 视图中显示的真实行号，Index 从 0 开始
    property ViewLineNumber[Index: Integer]: Integer read GetViewLineNumber;
    // 视图中显示的最大真实行号
    property ViewBottomLine: Integer read GetViewBottomLine;
  end;

  THighlightItem = class
  {* 不同编辑器元素的高亮显示特性，不包括基本字体}
  private
    FBold: Boolean;
    FColorBk: TColor;
    FColorFg: TColor;
    FItalic: Boolean;
    FUnderline: Boolean;
  public
    property Bold: Boolean read FBold write FBold;
    property ColorBk: TColor read FColorBk write FColorBk;
    property ColorFg: TColor read FColorFg write FColorFg;
    property Italic: Boolean read FItalic write FItalic;
    property Underline: Boolean read FUnderline write FUnderline;
  end;

  TEditorPaintLineNotifier = procedure (Editor: TEditorObject;
    LineNum, LogicLineNum: Integer) of object;
  {* EditControl 控件单行绘制通知事件，用户可以此进行自定义绘制}

  TEditorPaintNotifier = procedure (EditControl: TControl; EditView: IOTAEditView)
    of object;
  {* EditControl 控件完整绘制通知事件，用户可以此进行自定义绘制}

  TEditorNotifier = procedure (EditControl: TControl; EditWindow: TCustomForm;
    Operation: TOperation) of object;
  {* 编辑器创建、删除通知}

  TEditorChangeNotifier = procedure (Editor: TEditorObject; ChangeType:
    TEditorChangeTypes) of object;
  {* 编辑器变更通知}

  TKeyMessageNotifier = procedure (Key, ScanCode: Word; Shift: TShiftState;
    var Handled: Boolean) of object;
  {* 按键事件}

  // 鼠标事件类似于 TControl 内的定义，但 Sender 是 TEditorObject，并且加了是否是非客户区的标志
  TEditorMouseUpNotifier = procedure(Editor: TEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标抬起通知}

  TEditorMouseDownNotifier =  procedure(Editor: TEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标按下通知}

  TEditorMouseMoveNotifier = procedure(Editor: TEditorObject; Shift: TShiftState;
    X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标移动通知}

  TEditorMouseLeaveNotifier = procedure(Editor: TEditorObject; IsNC: Boolean) of object;
  {* 编辑器内鼠标离开通知}

  // 编辑器非客户区相关通知，用于滚动条重绘
  TEditorNcPaintNotifier = procedure(Editor: TEditorObject) of object;
  {* 编辑器非客户区重画通知}

  TEditorVScrollNotifier = procedure(Editor: TEditorObject) of object;
  {* 编辑器纵向滚动通知}

  TCnBreakPointClickItem = class
  private
    FBpPosY: Integer;
    FBpDeltaLine: Integer;
    FBpEditView: IOTAEditView;
    FBpEditControl: TControl;
  public
    property BpEditControl: TControl read FBpEditControl write FBpEditControl;
    property BpEditView: IOTAEditView read FBpEditView write FBpEditView;
    property BpPosY: Integer read FBpPosY write FBpPosY;
    property BpDeltaLine: Integer read FBpDeltaLine write FBpDeltaLine;
  end;

  TCnEditControlWrapper = class(TComponent)
  private
    FCorIdeModule: HMODULE;
    FAfterPaintLineNotifiers: TList;
    FBeforePaintLineNotifiers: TList;
    FEditControlNotifiers: TList;
    FEditorChangeNotifiers: TList;
    FKeyDownNotifiers: TList;
    FKeyUpNotifiers: TList;
    FCharSize: TSize;
    FHighlights: TStringList;
    FPaintNotifyAvailable: Boolean;
    FMouseNotifyAvailable: Boolean;
    FPaintLineHook: TCnMethodHook;
    FSetEditViewHook: TCnMethodHook;

    FMouseUpNotifiers: TList;
    FMouseDownNotifiers: TList;
    FMouseMoveNotifiers: TList;
    FMouseLeaveNotifiers: TList;
    FNcPaintNotifiers: TList;
    FVScrollNotifiers: TList;

    FEditorList: TObjectList;
    FEditControlList: TList;
    FOptionChanged: Boolean;
    FOptionDlgVisible: Boolean;
    FSaveFontName: string;
    FSaveFontSize: Integer;
{$IFDEF IDE_HAS_ERRORINSIGHT}
    FSaveErrorInsightIsSmoothWave: Boolean;
{$ENDIF}
    FFontArray: array[0..9] of TFont;

    FBpClickQueue: TQueue;
    FEditorBaseFont: TFont;
    procedure ScrollAndClickEditControl(Sender: TObject);

    procedure AddNotifier(List: TList; Notifier: TMethod);
    function CalcCharSize: Boolean;
    // 计算字符串尺寸，核心思想是从注册表里拿各种高亮设置计算，取其大者
    procedure GetHighlightFromReg;
    procedure ClearAndFreeList(var List: TList);
    function IndexOf(List: TList; Notifier: TMethod): Integer;
    procedure InitEditControlHook;
    procedure CheckAndSetEditControlMouseHookFlag;
    procedure RemoveNotifier(List: TList; Notifier: TMethod);
    function UpdateCharSize: Boolean;
    procedure EditControlProc(EditWindow: TCustomForm; EditControl:
      TControl; Context: Pointer);
    procedure UpdateEditControlList;
    procedure CheckOptionDlg;
    function GetEditorContext(Editor: TEditorObject): TCnEditorContext;
    function CheckViewLines(Editor: TEditorObject; Context: TCnEditorContext): Boolean;
    function CheckEditorChanges(Editor: TEditorObject): TEditorChangeTypes;
    procedure OnActiveFormChange(Sender: TObject);
    procedure AfterThemeChange(Sender: TObject);
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnGetMsgProc(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnIdle(Sender: TObject);
    function GetEditorCount: Integer;
    function GetEditors(Index: Integer): TEditorObject;
    function GetHighlight(Index: Integer): THighlightItem;
    function GetHighlightCount: Integer;
    function GetHighlightName(Index: Integer): string;
    procedure ClearHighlights;
    procedure LoadFontFromRegistry;
    procedure ResetFontsFromBasic(ABasicFont: TFont);
    function GetFonts(Index: Integer): TFont;
    procedure SetFonts(const Index: Integer; const Value: TFont);
  protected
    procedure DoAfterPaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoBeforePaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoAfterElide(EditControl: TControl);   // 暂不支持
    procedure DoAfterUnElide(EditControl: TControl); // 暂不支持
    procedure DoEditControlNotify(EditControl: TControl; Operation: TOperation);
    procedure DoEditorChange(Editor: TEditorObject; ChangeType: TEditorChangeTypes);

    procedure DoMouseDown(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseUp(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure DoMouseLeave(Editor: TEditorObject; IsNC: Boolean);
    procedure DoNcPaint(Editor: TEditorObject);
    procedure DoVScroll(Editor: TEditorObject);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CheckNewEditor(EditControl: TControl; View: IOTAEditView);
    function AddEditor(EditControl: TControl; View: IOTAEditView): Integer;
    procedure DeleteEditor(EditControl: TControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfEditor(EditControl: TControl): Integer; overload;
    function IndexOfEditor(EditView: IOTAEditView): Integer; overload;
    function GetEditorObject(EditControl: TControl): TEditorObject;
    property Editors[Index: Integer]: TEditorObject read GetEditors;
    property EditorCount: Integer read GetEditorCount;

    // 以下几项是封装的编辑器高亮显示的不同元素的属性，但不包括字体本身，需要结合 EditorBaseFont 属性使用
    function IndexOfHighlight(const Name: string): Integer;
    property HighlightCount: Integer read GetHighlightCount;
    property HighlightNames[Index: Integer]: string read GetHighlightName;
    property Highlights[Index: Integer]: THighlightItem read GetHighlight;

    function GetCharHeight: Integer;
    {* 返回编辑器行高 }
    function GetCharWidth: Integer;
    {* 返回编辑器字宽 }
    function GetCharSize: TSize;
    {* 返回编辑器行高和字宽 }
    function GetEditControlInfo(EditControl: TControl): TCnEditControlInfo;
    {* 返回编辑器当前信息 }
    function GetEditControlCharHeight(EditControl: TControl): Integer;
    {* 返回编辑器内的字符高度也就是行高}
    function GetEditControlSupportsSyntaxHighlight(EditControl: TControl): Boolean;
    {* 返回编辑器是否支持语法高亮 }
    function GetEditControlCanvas(EditControl: TControl): TCanvas;
    {* 返回编辑器的画布属性}
    function GetEditView(EditControl: TControl): IOTAEditView;
    {* 返回指定编辑器当前关联的 EditView }
    function GetEditControl(EditView: IOTAEditView): TControl;
    {* 返回指定 EditView 当前关联的编辑器 }
    function GetTopMostEditControl: TControl;
    {* 返回当前最前端的 EditControl}
    function GetEditViewFromTabs(TabControl: TXTabControl; Index: Integer):
      IOTAEditView;
    {* 返回 TabControl 指定页关联的 EditView }
    procedure GetAttributeAtPos(EditControl: TControl; const EdPos: TOTAEditPos;
      IncludeMargin: Boolean; var Element, LineFlag: Integer);
    {* 返回指定位置的高亮属性，用于替换 IOTAEditView 的函数，后者可能会导致编辑区问题。
       此指定位置在非 Unicode 环境里可由 CursorPos 而来，D5/6/7 是 Ansi 位置，
       2005~2007 是 UTF8 的字节位置（一个汉字跨 3 列），
       2009 以上要注意，EdPos 居然也要求是 UTF8 字节位置。而 2009 下 CursorPos 是 Ansi，
       不能直接拿 CursorPos 来作为 EdPos 参数，而必须经过一次 UTF8 转换 }
    function GetLineIsElided(EditControl: TControl; LineNum: Integer): Boolean;
    {* 返回指定行是否折叠，不包括折叠的头尾，也就是返回是否隐藏。
       只对 BDS 有效，其余情况返回 False}

    procedure ElideLine(EditControl: TControl; LineNum: Integer);
    {* 折叠某行，行号必须是可折叠区的首行}
    procedure UnElideLine(EditControl: TControl; LineNum: Integer);
    {* 展开某行，行号必须是可折叠区的首行}

    function GetPointFromEdPos(EditControl: TControl; APos: TOTAEditPos): TPoint;
    {* 返回 BDS 中编辑器控件某字符位置处的座标，只在 BDS 下有效}

    function GetLineFromPoint(Point: TPoint; EditControl: TControl;
      EditView: IOTAEditView = nil): Integer;
    {* 返回编辑器控件内鼠标座标对应的行，行结果从一开始，返回 -1 表示失败}

    procedure MarkLinesDirty(EditControl: TControl; Line: Integer; Count: Integer);
    {* 标记编辑器指定行需要重绘，屏幕可见第一行为 0 }
    procedure EditorRefresh(EditControl: TControl; DirtyOnly: Boolean);
    {* 刷新编辑器 }
    function GetTextAtLine(EditControl: TControl; LineNum: Integer): string;
    {* 取指定行的文本。注意该函数取到的文本是将 Tab 扩展成空格的，如果使用
       ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1
       赋值给 EditPos.Col 即可。
       字符串返回类型：AnsiString/Ansi-Utf8/UnicodeString
       另外，LineNum为逻辑行号，也就是和折叠无关的实际行号，1 开始 }
    function IndexPosToCurPos(EditControl: TControl; Col, Line: Integer): Integer;
    {* 计算编辑器字符串索引到编辑器显示的实际位置 }

    procedure RepaintEditControls;
    {* 挨个强行让编辑器控件们重画}

    function GetUseTabKey: Boolean;
    {* 获得编辑器选项是否使用 Tab 键}

    function GetTabWidth: Integer;
    {* 获得编辑器选项中的 Tab 键宽度}

    function ClickBreakpointAtActualLine(ActualLineNum: Integer; EditControl: TControl = nil): Boolean;
    {* 点击编辑器控件左侧指定行的断点栏以增加/删除断点}

    procedure AddKeyDownNotifier(Notifier: TKeyMessageNotifier);
    {* 增加编辑器按键通知 }
    procedure RemoveKeyDownNotifier(Notifier: TKeyMessageNotifier);
    {* 删除编辑器按键通知 }

    procedure AddKeyUpNotifier(Notifier: TKeyMessageNotifier);
    {* 增加编辑器按键后通知 }
    procedure RemoveKeyUpNotifier(Notifier: TKeyMessageNotifier);
    {* 删除编辑器按键后通知 }

    procedure AddBeforePaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* 增加编辑器单行重绘前通知 }
    procedure RemoveBeforePaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* 删除编辑器单行重绘前通知 }

    procedure AddAfterPaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* 增加编辑器单行重绘后通知 }
    procedure RemoveAfterPaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* 删除编辑器单行重绘后通知 }

    procedure AddEditControlNotifier(Notifier: TEditorNotifier);
    {* 增加编辑器创建或删除通知 }
    procedure RemoveEditControlNotifier(Notifier: TEditorNotifier);
    {* 删除编辑器创建或删除通知 }

    procedure AddEditorChangeNotifier(Notifier: TEditorChangeNotifier);
    {* 增加编辑器变更通知 }
    procedure RemoveEditorChangeNotifier(Notifier: TEditorChangeNotifier);
    {* 删除编辑器变更通知 }

    property PaintNotifyAvailable: Boolean read FPaintNotifyAvailable;
    {* 返回编辑器的重绘通知服务是否可用 }

    procedure AddEditorMouseUpNotifier(Notifier: TEditorMouseUpNotifier);
    {* 增加编辑器鼠标抬起通知 }
    procedure RemoveEditorMouseUpNotifier(Notifier: TEditorMouseUpNotifier);
    {* 删除编辑器鼠标抬起通知 }

    procedure AddEditorMouseDownNotifier(Notifier: TEditorMouseDownNotifier);
    {* 增加编辑器鼠标按下通知 }
    procedure RemoveEditorMouseDownNotifier(Notifier: TEditorMouseDownNotifier);
    {* 删除编辑器鼠标按下通知 }

    procedure AddEditorMouseMoveNotifier(Notifier: TEditorMouseMoveNotifier);
    {* 增加编辑器鼠标移动通知 }
    procedure RemoveEditorMouseMoveNotifier(Notifier: TEditorMouseMoveNotifier);
    {* 删除编辑器鼠标移动通知 }

    procedure AddEditorMouseLeaveNotifier(Notifier: TEditorMouseLeaveNotifier);
    {* 增加编辑器鼠标离开通知 }
    procedure RemoveEditorMouseLeaveNotifier(Notifier: TEditorMouseLeaveNotifier);
    {* 删除编辑器鼠标离开通知 }

    procedure AddEditorNcPaintNotifier(Notifier: TEditorNcPaintNotifier);
    {* 增加编辑器非客户区重画通知 }
    procedure RemoveEditorNcPaintNotifier(Notifier: TEditorNcPaintNotifier);
    {* 删除编辑器非客户区重画通知 }

    procedure AddEditorVScrollNotifier(Notifier: TEditorVScrollNotifier);
    {* 增加编辑器非客户区重画通知 }
    procedure RemoveEditorVScrollNotifier(Notifier: TEditorVScrollNotifier);
    {* 删除编辑器非客户区重画通知 }

    property MouseNotifyAvailable: Boolean read FMouseNotifyAvailable;
    {* 返回编辑器的鼠标事件通知服务是否可用 }
    property EditorBaseFont: TFont read FEditorBaseFont;
    {* 一个 TFont 对象，持有编辑器的基础字体供外界使用}

    // 以下是维护的注册表中的编辑器各类元素的字体，和 Highlights 有一定重叠，但无背景色属性
    property FontBasic: TFont index 0 read GetFonts write SetFonts; // 基本字体无前景色
    property FontAssembler: TFont index 1 read GetFonts write SetFonts;
    property FontComment: TFont index 2 read GetFonts write SetFonts;
    property FontDirective: TFont index 3 read GetFonts write SetFonts;
    property FontIdentifier: TFont index 4 read GetFonts write SetFonts;
    property FontKeyWord: TFont index 5 read GetFonts write SetFonts;
    property FontNumber: TFont index 6 read GetFonts write SetFonts;
    property FontSpace: TFont index 7 read GetFonts write SetFonts;
    property FontString: TFont index 8 read GetFonts write SetFonts;
    property FontSymbol: TFont index 9 read GetFonts write SetFonts;
  end;

function CnPaletteWrapper: TCnPaletteWrapper;

function CnMessageViewWrapper: TCnMessageViewWrapper;

function EditControlWrapper: TCnEditControlWrapper;

implementation

{$WARNINGS OFF}

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
begin
end;

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
begin
end;

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
begin
end;

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
begin
end;

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
begin
end;

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
begin
end;

function IdeInsertTextIntoEditor(const Text: string): Boolean;
begin
end;

function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
begin
end;

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
begin
end;

function IdeGetBlockIndent: Integer;
begin
end;

function IdeGetSourceByFileName(const FileName: string): string;
begin
end;

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
begin
end;

function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
end;

function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
begin
end;

function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
begin
end;

function GetIdeMainForm: TCustomForm;
begin
end;

function GetIdeEdition: string;
begin
end;

function GetComponentPaletteTabControl: TTabControl;
begin
end;

function GetNewComponentPaletteTabControl: TWinControl;
begin
end;

function GetNewComponentPaletteComponentPanel: TWinControl;
begin
end;

function GetObjectInspectorForm: TCustomForm;
begin
end;

function GetComponentPalettePopupMenu: TPopupMenu;
begin
end;

function GetComponentPaletteControlBar: TControlBar;
begin
end;

function GetMainMenuItemHeight: Integer;
begin
end;

function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
end;

function IsIdeDesignForm(AForm: TCustomForm): Boolean;
begin
end;

procedure BringIdeEditorFormToFront;
begin
end;

function IDEIsCurrentWindow: Boolean;
begin
end;

function GetInstallDir: string;
begin
end;

function GetBDSUserDataDir: string;
begin
end;

procedure GetProjectLibPath(Paths: TStrings);
begin
end;

function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
begin
end;

function GetFileNameSearchTypeFromModuleName(AName: string;
  var SearchType: TCnModuleSearchType; AProject: IOTAProject = nil): string;
begin
end;

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
begin
end;

procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean = True);
begin
end;

function GetComponentUnitName(const ComponentName: string): string;
begin
end;

procedure GetInstalledComponents(Packages, Components: TStrings);
begin
end;

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
begin
end;

function GetCurrentEditControl: TControl;
begin
end;

function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
begin
end;

function GetCurrentSyncButton: TControl;
begin
end;

function GetCurrentSyncButtonVisible: Boolean;
begin
end;

function GetCodeTemplateListBox: TControl;
begin
end;

function GetCodeTemplateListBoxVisible: Boolean;
begin
end;

function IsCurrentEditorInSyncMode: Boolean;
begin
end;

function IsKeyMacroRunning: Boolean;
begin
end;

function GetCurrentCompilingProject: IOTAProject;
begin
end;

function CompileProject(AProject: IOTAProject): Boolean;
begin
end;

{ TCnPaletteWrapper }

procedure TCnPaletteWrapper.BeginUpdate;
begin
end;

constructor TCnPaletteWrapper.Create;
begin
end;

procedure TCnPaletteWrapper.EndUpdate;
begin
end;

function TCnPaletteWrapper.FindTab(const ATab: string): Integer;
begin
end;

function TCnPaletteWrapper.GetActiveTab: string;
begin
end;

function TCnPaletteWrapper.GetEnabled: Boolean;
begin
end;

function TCnPaletteWrapper.GetIsMultiLine: Boolean;
begin
end;

function TCnPaletteWrapper.GetPalToolCount: Integer;
begin
end;

function TCnPaletteWrapper.GetSelectedIndex: Integer;
begin
end;

function TCnPaletteWrapper.GetSelectedToolName: string;
begin
end;

function TCnPaletteWrapper.GetSelector: TSpeedButton;
begin
end;

function TCnPaletteWrapper.GetTabCount: Integer;
begin
end;

function TCnPaletteWrapper.GetTabIndex: Integer;
begin
end;

function TCnPaletteWrapper.GetTabs(Index: Integer): string;
begin
end;

function TCnPaletteWrapper.GetVisible: Boolean;
begin
end;

function TCnPaletteWrapper.SelectComponent(const AComponent,
  ATab: string): Boolean;
begin
end;

procedure TCnPaletteWrapper.SetEnabled(const Value: Boolean);
begin
end;

procedure TCnPaletteWrapper.SetSelectedIndex(const Value: Integer);
begin
end;

procedure TCnPaletteWrapper.SetTabIndex(const Value: Integer);
begin
end;

procedure TCnPaletteWrapper.SetVisible(const Value: Boolean);
begin
end;

function CnPaletteWrapper: TCnPaletteWrapper;
begin
end;
  
{ TCnMessageViewWrapper }

constructor TCnMessageViewWrapper.Create;
begin
end;

procedure TCnMessageViewWrapper.EditMessageSource;
begin
end;

function TCnMessageViewWrapper.GetCurrentMessage: string;
begin
end;

function TCnMessageViewWrapper.GetMessageCount: Integer;
begin
end;

function TCnMessageViewWrapper.GetSelectedIndex: Integer;
begin
end;

function TCnMessageViewWrapper.GetTabCaption: string;
begin
end;

function TCnMessageViewWrapper.GetTabCount: Integer;
begin
end;

function TCnMessageViewWrapper.GetTabIndex: Integer;
begin
end;

function TCnMessageViewWrapper.GetTabSetVisible: Boolean;
begin
end;

procedure TCnMessageViewWrapper.SetSelectedIndex(const Value: Integer);
begin
end;

procedure TCnMessageViewWrapper.SetTabIndex(const Value: Integer);
begin
end;

procedure TCnMessageViewWrapper.UpdateAllItems;
begin
end;

function CnMessageViewWrapper: TCnMessageViewWrapper;
begin
end;

{ TEditorObject }

constructor TEditorObject.Create(AEditControl: TControl;
  AEditView: IOTAEditView);
begin

end;

destructor TEditorObject.Destroy;
begin
  inherited;

end;

function TEditorObject.EditorIsOnTop: Boolean;
begin

end;

function TEditorObject.GetGutterWidth: Integer;
begin

end;

function TEditorObject.GetTopEditor: TControl;
begin

end;

function TEditorObject.GetViewBottomLine: Integer;
begin

end;

function TEditorObject.GetViewLineCount: Integer;
begin

end;

function TEditorObject.GetViewLineNumber(Index: Integer): Integer;
begin

end;

procedure TEditorObject.IDEShowLineNumberChanged;
begin

end;

procedure TEditorObject.SetEditView(AEditView: IOTAEditView);
begin

end;

{ TCnEditControlWrapper }

procedure TCnEditControlWrapper.AddAfterPaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin

end;

procedure TCnEditControlWrapper.AddBeforePaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditControlNotifier(
  Notifier: TEditorNotifier);
begin

end;

function TCnEditControlWrapper.AddEditor(EditControl: TControl;
  View: IOTAEditView): Integer;
begin

end;

procedure TCnEditControlWrapper.AddEditorChangeNotifier(
  Notifier: TEditorChangeNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorMouseDownNotifier(
  Notifier: TEditorMouseDownNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorMouseLeaveNotifier(
  Notifier: TEditorMouseLeaveNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorMouseMoveNotifier(
  Notifier: TEditorMouseMoveNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorMouseUpNotifier(
  Notifier: TEditorMouseUpNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorNcPaintNotifier(
  Notifier: TEditorNcPaintNotifier);
begin

end;

procedure TCnEditControlWrapper.AddEditorVScrollNotifier(
  Notifier: TEditorVScrollNotifier);
begin

end;

procedure TCnEditControlWrapper.AddKeyDownNotifier(
  Notifier: TKeyMessageNotifier);
begin

end;

procedure TCnEditControlWrapper.AddKeyUpNotifier(
  Notifier: TKeyMessageNotifier);
begin

end;

procedure TCnEditControlWrapper.AddNotifier(List: TList;
  Notifier: TMethod);
begin

end;

procedure TCnEditControlWrapper.AfterThemeChange(Sender: TObject);
begin

end;

procedure TCnEditControlWrapper.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin

end;

function TCnEditControlWrapper.CalcCharSize: Boolean;
begin

end;

procedure TCnEditControlWrapper.CheckAndSetEditControlMouseHookFlag;
begin

end;

function TCnEditControlWrapper.CheckEditorChanges(
  Editor: TEditorObject): TEditorChangeTypes;
begin

end;

procedure TCnEditControlWrapper.CheckNewEditor(EditControl: TControl;
  View: IOTAEditView);
begin

end;

procedure TCnEditControlWrapper.CheckOptionDlg;
begin

end;

function TCnEditControlWrapper.CheckViewLines(Editor: TEditorObject;
  Context: TCnEditorContext): Boolean;
begin

end;

procedure TCnEditControlWrapper.ClearAndFreeList(var List: TList);
begin

end;

procedure TCnEditControlWrapper.ClearHighlights;
begin

end;

function TCnEditControlWrapper.ClickBreakpointAtActualLine(
  ActualLineNum: Integer; EditControl: TControl): Boolean;
begin

end;

constructor TCnEditControlWrapper.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TCnEditControlWrapper.DeleteEditor(EditControl: TControl);
begin

end;

destructor TCnEditControlWrapper.Destroy;
begin
  inherited;

end;

procedure TCnEditControlWrapper.DoAfterElide(EditControl: TControl);
begin

end;

procedure TCnEditControlWrapper.DoAfterPaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
begin

end;

procedure TCnEditControlWrapper.DoAfterUnElide(EditControl: TControl);
begin

end;

procedure TCnEditControlWrapper.DoBeforePaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
begin

end;

procedure TCnEditControlWrapper.DoEditControlNotify(EditControl: TControl;
  Operation: TOperation);
begin

end;

procedure TCnEditControlWrapper.DoEditorChange(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
begin

end;

procedure TCnEditControlWrapper.DoMouseDown(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin

end;

procedure TCnEditControlWrapper.DoMouseLeave(Editor: TEditorObject;
  IsNC: Boolean);
begin

end;

procedure TCnEditControlWrapper.DoMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin

end;

procedure TCnEditControlWrapper.DoMouseUp(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin

end;

procedure TCnEditControlWrapper.DoNcPaint(Editor: TEditorObject);
begin

end;

procedure TCnEditControlWrapper.DoVScroll(Editor: TEditorObject);
begin

end;

procedure TCnEditControlWrapper.EditControlProc(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
begin

end;

procedure TCnEditControlWrapper.EditorRefresh(EditControl: TControl;
  DirtyOnly: Boolean);
begin

end;

procedure TCnEditControlWrapper.ElideLine(EditControl: TControl;
  LineNum: Integer);
begin

end;

procedure TCnEditControlWrapper.GetAttributeAtPos(EditControl: TControl;
  const EdPos: TOTAEditPos; IncludeMargin: Boolean; var Element,
  LineFlag: Integer);
begin

end;

function TCnEditControlWrapper.GetCharHeight: Integer;
begin

end;

function TCnEditControlWrapper.GetCharSize: TSize;
begin

end;

function TCnEditControlWrapper.GetCharWidth: Integer;
begin

end;

function TCnEditControlWrapper.GetEditControl(
  EditView: IOTAEditView): TControl;
begin

end;

function TCnEditControlWrapper.GetEditControlCanvas(
  EditControl: TControl): TCanvas;
begin

end;

function TCnEditControlWrapper.GetEditControlCharHeight(
  EditControl: TControl): Integer;
begin

end;

function TCnEditControlWrapper.GetEditControlInfo(
  EditControl: TControl): TCnEditControlInfo;
begin

end;

function TCnEditControlWrapper.GetEditControlSupportsSyntaxHighlight(
  EditControl: TControl): Boolean;
begin

end;

function TCnEditControlWrapper.GetEditorContext(
  Editor: TEditorObject): TCnEditorContext;
begin

end;

function TCnEditControlWrapper.GetEditorCount: Integer;
begin

end;

function TCnEditControlWrapper.GetEditorObject(
  EditControl: TControl): TEditorObject;
begin

end;

function TCnEditControlWrapper.GetEditors(Index: Integer): TEditorObject;
begin

end;

function TCnEditControlWrapper.GetEditView(
  EditControl: TControl): IOTAEditView;
begin

end;

function TCnEditControlWrapper.GetEditViewFromTabs(
  TabControl: TXTabControl; Index: Integer): IOTAEditView;
begin

end;

function TCnEditControlWrapper.GetFonts(Index: Integer): TFont;
begin

end;

function TCnEditControlWrapper.GetHighlight(
  Index: Integer): THighlightItem;
begin

end;

function TCnEditControlWrapper.GetHighlightCount: Integer;
begin

end;

procedure TCnEditControlWrapper.GetHighlightFromReg;
begin

end;

function TCnEditControlWrapper.GetHighlightName(Index: Integer): string;
begin

end;

function TCnEditControlWrapper.GetLineFromPoint(Point: TPoint;
  EditControl: TControl; EditView: IOTAEditView): Integer;
begin

end;

function TCnEditControlWrapper.GetLineIsElided(EditControl: TControl;
  LineNum: Integer): Boolean;
begin

end;

function TCnEditControlWrapper.GetPointFromEdPos(EditControl: TControl;
  APos: TOTAEditPos): TPoint;
begin

end;

function TCnEditControlWrapper.GetTabWidth: Integer;
begin

end;

function TCnEditControlWrapper.GetTextAtLine(EditControl: TControl;
  LineNum: Integer): string;
begin

end;

function TCnEditControlWrapper.GetTopMostEditControl: TControl;
begin

end;

function TCnEditControlWrapper.GetUseTabKey: Boolean;
begin

end;

function TCnEditControlWrapper.IndexOf(List: TList;
  Notifier: TMethod): Integer;
begin

end;

function TCnEditControlWrapper.IndexOfEditor(
  EditView: IOTAEditView): Integer;
begin

end;

function TCnEditControlWrapper.IndexOfEditor(
  EditControl: TControl): Integer;
begin

end;

function TCnEditControlWrapper.IndexOfHighlight(
  const Name: string): Integer;
begin

end;

function TCnEditControlWrapper.IndexPosToCurPos(EditControl: TControl; Col,
  Line: Integer): Integer;
begin

end;

procedure TCnEditControlWrapper.InitEditControlHook;
begin

end;

procedure TCnEditControlWrapper.LoadFontFromRegistry;
begin

end;

procedure TCnEditControlWrapper.MarkLinesDirty(EditControl: TControl; Line,
  Count: Integer);
begin

end;

procedure TCnEditControlWrapper.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

end;

procedure TCnEditControlWrapper.OnActiveFormChange(Sender: TObject);
begin

end;

procedure TCnEditControlWrapper.OnCallWndProcRet(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
begin

end;

procedure TCnEditControlWrapper.OnGetMsgProc(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
begin

end;

procedure TCnEditControlWrapper.OnIdle(Sender: TObject);
begin

end;

procedure TCnEditControlWrapper.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
begin

end;

procedure TCnEditControlWrapper.RemoveAfterPaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveBeforePaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditControlNotifier(
  Notifier: TEditorNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorChangeNotifier(
  Notifier: TEditorChangeNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorMouseDownNotifier(
  Notifier: TEditorMouseDownNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorMouseLeaveNotifier(
  Notifier: TEditorMouseLeaveNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorMouseMoveNotifier(
  Notifier: TEditorMouseMoveNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorMouseUpNotifier(
  Notifier: TEditorMouseUpNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorNcPaintNotifier(
  Notifier: TEditorNcPaintNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveEditorVScrollNotifier(
  Notifier: TEditorVScrollNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveKeyDownNotifier(
  Notifier: TKeyMessageNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveKeyUpNotifier(
  Notifier: TKeyMessageNotifier);
begin

end;

procedure TCnEditControlWrapper.RemoveNotifier(List: TList;
  Notifier: TMethod);
begin

end;

procedure TCnEditControlWrapper.RepaintEditControls;
begin

end;

procedure TCnEditControlWrapper.ResetFontsFromBasic(ABasicFont: TFont);
begin

end;

procedure TCnEditControlWrapper.ScrollAndClickEditControl(Sender: TObject);
begin

end;

procedure TCnEditControlWrapper.SetFonts(const Index: Integer;
  const Value: TFont);
begin

end;

procedure TCnEditControlWrapper.UnElideLine(EditControl: TControl;
  LineNum: Integer);
begin

end;

function TCnEditControlWrapper.UpdateCharSize: Boolean;
begin

end;

procedure TCnEditControlWrapper.UpdateEditControlList;
begin

end;

end.

