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

unit CnEditControlWrapper;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 相关公共单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元封装了对 IDE 的 EditControl 的操作
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2021.05.03 V1.8
*               用新 RTTI 办法更精准地获取编辑器字符长宽
*           2021.02.28 V1.7
*               适应 10.4.2 下 ErroInsight 导致行距与字符高度改变以及通知
*           2018.03.20 V1.6
*               增加主题改变时的通知与字体重算
*           2016.07.16 V1.5
*               增加 Tab 键属性的封装
*           2015.07.13 V1.4
*               增加三个编辑器鼠标事件通知，采用延迟 Hook 的机制
*           2009.05.30 V1.3
*               增加两个 BDS 下的顶、底页面切换变化通知
*           2008.08.20 V1.2
*               增加一 BDS 下的总行数位数变化通知，用来处理行号重画区变化的情况
*           2004.12.26 V1.1
*               增加一系列 BDS 下的通知控制函数以及编辑器横向滚动的通知
*           2004.12.26 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, ToolsAPI, ExtCtrls,
  ComCtrls, TypInfo, Forms, Tabs, Registry, Contnrs,
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  {$IFDEF SUPPORT_ENHANCED_RTTI} Rtti, {$ENDIF}
  CnCommon, CnWizMethodHook, CnWizUtils, CnWizCompilerConst, CnWizNotifier,
  CnWizIdeUtils, CnWizOptions;
  
type

//==============================================================================
// 代码编辑器控件封装类
//==============================================================================

{ TCnEditControlWrapper }

  TCnEditControlInfo = record
  {* 代码编辑器位置信息 }
    TopLine: Integer;         // 顶行号
    LinesInWindow: Integer;   // 窗口显示行数
    LineCount: Integer;       // 代码缓冲区总行数
    CaretX: Integer;          // 光标 X 位置
    CaretY: Integer;          // 光标 Y 位置
    CharXIndex: Integer;      // 字符序号
{$IFDEF BDS}
    LineDigit: Integer;       // 编辑器总行数的位数，如 100 行为 3, 计算而来
{$ENDIF}
  end;

  TCnEditorChangeType = (
    ctView,                   // 当前视图切换
    ctWindow,                 // 窗口首行、尾行变化
    ctCurrLine,               // 当前光标行
    ctCurrCol,                // 当前光标列
    ctFont,                   // 字体变更
    ctVScroll,                // 编辑器垂直滚动
    ctHScroll,                // 编辑器横向滚动
    ctBlock,                  // 块变更，也就是选择范围或状态有变化
    ctModified,               // 编辑内容修改
    ctTopEditorChanged,       // 当前显示的上层编辑器变更
{$IFDEF BDS}
    ctLineDigit,              // 编辑器总行数位数变化，如 99 到 100
{$ENDIF}
{$IFDEF IDE_EDITOR_ELIDE}
    ctElided,                 // 编辑器行折叠，有限支持
    ctUnElided,               // 编辑器行展开，有限支持
{$ENDIF}
    ctOptionChanged           // 编辑器设置对话框曾经打开过
    );

  TCnEditorChangeTypes = set of TCnEditorChangeType;

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
    LineDigit: Integer;       // 编辑器总行数的位数，如 100 行为 3, 计算而来
{$ENDIF}
  end;

  TCnEditorObject = class
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
    procedure NotifyIDEGutterChanged;

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

  TCnHighlightItem = class
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

  TCnEditorPaintLineNotifier = procedure (Editor: TCnEditorObject;
    LineNum, LogicLineNum: Integer) of object;
  {* EditControl 控件单行绘制通知事件，用户可以此进行自定义绘制}

  TCnEditorPaintNotifier = procedure (EditControl: TControl; EditView: IOTAEditView)
    of object;
  {* EditControl 控件完整绘制通知事件，用户可以此进行自定义绘制}

  TCnEditorNotifier = procedure (EditControl: TControl; EditWindow: TCustomForm;
    Operation: TOperation) of object;
  {* 编辑器创建、删除通知}

  TCnEditorChangeNotifier = procedure (Editor: TCnEditorObject; ChangeType:
    TCnEditorChangeTypes) of object;
  {* 编辑器变更通知}

  TCnKeyMessageNotifier = procedure (Key, ScanCode: Word; Shift: TShiftState;
    var Handled: Boolean) of object;
  {* 按键事件}

  // 鼠标事件类似于 TControl 内的定义，但 Sender 是 TCnEditorObject，并且加了是否是非客户区的标志
  TCnEditorMouseUpNotifier = procedure(Editor: TCnEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标抬起通知}

  TCnEditorMouseDownNotifier =  procedure(Editor: TCnEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标按下通知}

  TCnEditorMouseMoveNotifier = procedure(Editor: TCnEditorObject; Shift: TShiftState;
    X, Y: Integer; IsNC: Boolean) of object;
  {* 编辑器内鼠标移动通知}

  TCnEditorMouseLeaveNotifier = procedure(Editor: TCnEditorObject; IsNC: Boolean) of object;
  {* 编辑器内鼠标离开通知}

  // 编辑器非客户区相关通知，用于滚动条重绘
  TCnEditorNcPaintNotifier = procedure(Editor: TCnEditorObject) of object;
  {* 编辑器非客户区重画通知}

  TCnEditorVScrollNotifier = procedure(Editor: TCnEditorObject) of object;
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
    FCmpLines: TList;
    FMouseUpNotifiers: TList;
    FMouseDownNotifiers: TList;
    FMouseMoveNotifiers: TList;
    FMouseLeaveNotifiers: TList;
    FNcPaintNotifiers: TList;
    FVScrollNotifiers: TList;
    FBackgroundColor: TColor;
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
    function GetEditorContext(Editor: TCnEditorObject): TCnEditorContext;
    function CheckViewLinesChange(Editor: TCnEditorObject; Context: TCnEditorContext): Boolean;
    // 检查某个 View 中的具体行号分布有无改变，包括纵向滚动、纵向伸缩、折叠等，不包括单行内改动

    function CheckEditorChanges(Editor: TCnEditorObject): TCnEditorChangeTypes;
    procedure OnActiveFormChange(Sender: TObject);
    procedure AfterThemeChange(Sender: TObject);
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnGetMsgProc(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnIdle(Sender: TObject);
    function GetEditorCount: Integer;
    function GetEditors(Index: Integer): TCnEditorObject;
    function GetHighlight(Index: Integer): TCnHighlightItem;
    function GetHighlightCount: Integer;
    function GetHighlightName(Index: Integer): string;
    procedure ClearHighlights;
    procedure LoadFontFromRegistry;
    procedure ResetFontsFromBasic(ABasicFont: TFont);
    function GetFonts(Index: Integer): TFont;
    procedure SetFonts(const Index: Integer; const Value: TFont);
    function GetBackgroundColor: TColor;
  protected
    procedure DoAfterPaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoBeforePaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
{$IFDEF IDE_EDITOR_ELIDE}
    procedure DoAfterElide(EditControl: TControl);   // 暂不支持
    procedure DoAfterUnElide(EditControl: TControl); // 暂不支持
{$ENDIF}
    procedure DoEditControlNotify(EditControl: TControl; Operation: TOperation);
    procedure DoEditorChange(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);

    procedure DoMouseDown(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseUp(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseMove(Editor: TCnEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure DoMouseLeave(Editor: TCnEditorObject; IsNC: Boolean);
    procedure DoNcPaint(Editor: TCnEditorObject);
    procedure DoVScroll(Editor: TCnEditorObject);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CheckNewEditor(EditControl: TControl; View: IOTAEditView);
    function AddEditor(EditControl: TControl; View: IOTAEditView): Integer;
    procedure DeleteEditor(EditControl: TControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfEditor(EditControl: TControl): Integer; overload;
    function IndexOfEditor(EditView: IOTAEditView): Integer; overload;
    function GetEditorObject(EditControl: TControl): TCnEditorObject;
    property Editors[Index: Integer]: TCnEditorObject read GetEditors;
    property EditorCount: Integer read GetEditorCount;

    // 以下几项是封装的编辑器高亮显示的不同元素的属性，但不包括字体本身，需要结合 EditorBaseFont 属性使用
    function IndexOfHighlight(const Name: string): Integer;
    property HighlightCount: Integer read GetHighlightCount;
    property HighlightNames[Index: Integer]: string read GetHighlightName;
    property Highlights[Index: Integer]: TCnHighlightItem read GetHighlight;

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

{$IFDEF IDE_EDITOR_ELIDE}
    procedure ElideLine(EditControl: TControl; LineNum: Integer);
    {* 折叠某行，行号必须是可折叠区的首行}
    procedure UnElideLine(EditControl: TControl; LineNum: Integer);
    {* 展开某行，行号必须是可折叠区的首行}
{$ENDIF}

{$IFDEF BDS}
    function GetPointFromEdPos(EditControl: TControl; APos: TOTAEditPos): TPoint;
    {* 返回 BDS 中编辑器控件某字符位置处的座标，只在 BDS 下有效}
{$ENDIF}

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

    function GetBlockIndent: Integer;
    {* 获得编辑器缩进宽度}

    function ClickBreakpointAtActualLine(ActualLineNum: Integer; EditControl: TControl = nil): Boolean;
    {* 点击编辑器控件左侧指定行的断点栏以增加/删除断点}

    procedure AddKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* 增加编辑器按键通知 }
    procedure RemoveKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* 删除编辑器按键通知 }

    procedure AddKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* 增加编辑器按键后通知 }
    procedure RemoveKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* 删除编辑器按键后通知 }

    procedure AddBeforePaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* 增加编辑器单行重绘前通知 }
    procedure RemoveBeforePaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* 删除编辑器单行重绘前通知 }

    procedure AddAfterPaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* 增加编辑器单行重绘后通知 }
    procedure RemoveAfterPaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* 删除编辑器单行重绘后通知 }

    procedure AddEditControlNotifier(Notifier: TCnEditorNotifier);
    {* 增加编辑器创建或删除通知 }
    procedure RemoveEditControlNotifier(Notifier: TCnEditorNotifier);
    {* 删除编辑器创建或删除通知 }

    procedure AddEditorChangeNotifier(Notifier: TCnEditorChangeNotifier);
    {* 增加编辑器变更通知 }
    procedure RemoveEditorChangeNotifier(Notifier: TCnEditorChangeNotifier);
    {* 删除编辑器变更通知 }

    property PaintNotifyAvailable: Boolean read FPaintNotifyAvailable;
    {* 返回编辑器的重绘通知服务是否可用 }

    procedure AddEditorMouseUpNotifier(Notifier: TCnEditorMouseUpNotifier);
    {* 增加编辑器鼠标抬起通知 }
    procedure RemoveEditorMouseUpNotifier(Notifier: TCnEditorMouseUpNotifier);
    {* 删除编辑器鼠标抬起通知 }

    procedure AddEditorMouseDownNotifier(Notifier: TCnEditorMouseDownNotifier);
    {* 增加编辑器鼠标按下通知 }
    procedure RemoveEditorMouseDownNotifier(Notifier: TCnEditorMouseDownNotifier);
    {* 删除编辑器鼠标按下通知 }

    procedure AddEditorMouseMoveNotifier(Notifier: TCnEditorMouseMoveNotifier);
    {* 增加编辑器鼠标移动通知 }
    procedure RemoveEditorMouseMoveNotifier(Notifier: TCnEditorMouseMoveNotifier);
    {* 删除编辑器鼠标移动通知 }

    procedure AddEditorMouseLeaveNotifier(Notifier: TCnEditorMouseLeaveNotifier);
    {* 增加编辑器鼠标离开通知，注意鼠标离开通知经常无效，不能太依赖之 }
    procedure RemoveEditorMouseLeaveNotifier(Notifier: TCnEditorMouseLeaveNotifier);
    {* 删除编辑器鼠标离开通知 }

    procedure AddEditorNcPaintNotifier(Notifier: TCnEditorNcPaintNotifier);
    {* 增加编辑器非客户区重画通知 }
    procedure RemoveEditorNcPaintNotifier(Notifier: TCnEditorNcPaintNotifier);
    {* 删除编辑器非客户区重画通知 }

    procedure AddEditorVScrollNotifier(Notifier: TCnEditorVScrollNotifier);
    {* 增加编辑器非客户区重画通知 }
    procedure RemoveEditorVScrollNotifier(Notifier: TCnEditorVScrollNotifier);
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

    property BackgroundColor: TColor read GetBackgroundColor;
    {* 编辑器的文字背景色，实际上是 WhiteSpace 字体的背景色}
  end;

function EditControlWrapper: TCnEditControlWrapper;
{* 获取全局编辑器封装对象}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  PCnWizNotifierRecord = ^TCnWizNotifierRecord;
  TCnWizNotifierRecord = record
    Notifier: TMethod;
  end;

  NoRef = Pointer;

  TCustomControlHack = class(TCustomControl);

const
  CN_BP_CLICK_POS_X = 5;

  WM_NCMOUSELEAVE       = $02A2;

{$IFDEF BDS}
{$IFDEF BDS2005}
  CnWideControlCanvasOffset = $230;
  // BDS 2005 下 EditControl 的 Canvas 属性的偏移量
{$ELSE}
  // BDS 2006/2007 下 EditControl 的 Canvas 属性的偏移量
  CnWideControlCanvasOffset = $260;
{$ENDIF}
{$ENDIF}

var
  FEditControlWrapper: TCnEditControlWrapper = nil;

function EditControlWrapper: TCnEditControlWrapper;
begin
  if FEditControlWrapper = nil then
    FEditControlWrapper := TCnEditControlWrapper.Create(nil);
  Result := FEditControlWrapper;
end;

function GetLineDigit(LineCount: Integer): Integer;
begin
  Result := Length(IntToStr(LineCount));
end;

{ TCnEditorObject }

constructor TCnEditorObject.Create(AEditControl: TControl;
  AEditView: IOTAEditView);
begin
  inherited Create;
  FLines := TList.Create;
  FEditControl := AEditControl;
  FEditWindow := TCustomForm(AEditControl.Owner);
  SetEditView(AEditView);
end;

destructor TCnEditorObject.Destroy;
begin
  SetEditView(nil);
  FLines.Free;
  inherited;
end;

function TCnEditorObject.GetGutterWidth: Integer;
begin
  if FGutterChanged and Assigned(FEditView) then
  begin
{$IFDEF BDS}
    FGutterWidth := EditControlWrapper.GetPointFromEdPos(FEditControl,
      OTAEditPos(1, 1)).X;
    FGutterWidth := FGutterWidth + (FEditView.LeftColumn - 1) *
      FEditControlWrapper.FCharSize.cx;
{$ELSE}
    FGutterWidth := FEditView.Buffer.BufferOptions.LeftGutterWidth;
{$ENDIF}

{$IFDEF DEBUG}
    CnDebugger.LogFmt('EditorObject GetGutterWidth. Control Left %d. ReCalc to %d',
      [FEditControl.Left, FGutterWidth]);
{$ENDIF}
    FGutterChanged := False;
  end;
  Result := FGutterWidth;
end;

function TCnEditorObject.GetViewBottomLine: Integer;
begin
  if ViewLineCount > 0 then
    Result := ViewLineNumber[ViewLineCount - 1]
  else
    Result := 0;
end;

function TCnEditorObject.GetViewLineNumber(Index: Integer): Integer;
begin
  Result := Integer(FLines[Index]);
end;

function TCnEditorObject.GetViewLineCount: Integer;
begin
  Result := FLines.Count;
end;

procedure TCnEditorObject.SetEditView(AEditView: IOTAEditView);
begin
  NoRef(FEditView) := NoRef(AEditView);
end;

function TCnEditorObject.GetTopEditor: TControl;
var
  I: Integer;
  ACtrl: TControl;
begin
  Result := nil;
  if (EditControl <> nil) and (EditControl.Parent <> nil) then
  begin
    for I := EditControl.Parent.ControlCount - 1 downto 0 do
    begin
      ACtrl := EditControl.Parent.Controls[I];
      if (ACtrl.Align = alClient) and ACtrl.Visible then
      begin
        Result := ACtrl;
        Exit;
      end;
    end;
  end;
end;

procedure TCnEditorObject.NotifyIDEGutterChanged;
begin
  FGutterChanged := True;
end;

function TCnEditorObject.EditorIsOnTop: Boolean;
begin
  Result := (EditControl <> nil) and (GetTopEditor = EditControl);
end;

//==============================================================================
// 代码编辑器控件封装类
//==============================================================================

{ TCnEditControlWrapper }

const
  STEditViewClass = 'TEditView';
{$IFDEF DELPHI10_SEATTLE_UP}
  SGetCanvas = '@Editorcontrol@TCustomEditControl@GetCanvas$qqrv';
{$ENDIF}

{$IFDEF COMPILER8_UP}
  SPaintLineName = '@Editorcontrol@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextiii';
  SMarkLinesDirtyName = '@Editorcontrol@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editorcontrol@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editorcontrol@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editorbuffer@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editorcontrol@TCustomEditControl@SetEditView$qqrp22Editorbuffer@TEditView';
  SGetAttributeAtPosName = '@Editorcontrol@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';

  SLineIsElidedName = '@Editorcontrol@TCustomEditControl@LineIsElided$qqri';
  SPointFromEdPosName = '@Editorcontrol@TCustomEditControl@PointFromEdPos$qqrrx9Ek@TEdPosoo';
  STabsChangedName = '@Editorform@TEditWindow@TabsChanged$qqrp14System@TObject';

  SViewBarChangedName = '@Editorform@TEditWindow@ViewBarChange$qqrp14System@TObjectiro';

{$IFDEF COMPILER10_UP}
  SIndexPosToCurPosName = '@Editorcontrol@TCustomEditControl@IndexPosToCurPos$qqrsi';
{$ELSE}
  SIndexPosToCurPosName = '@Editorcontrol@TCustomEditControl@IndexPosToCurPos$qqrss';
{$ENDIF}
{$ELSE}
  SPaintLineName = '@Editors@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextisi';
  SMarkLinesDirtyName = '@Editors@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editors@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editors@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editors@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editors@TCustomEditControl@SetEditView$qqrp17Editors@TEditView';

{$IFDEF COMPILER7_UP}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';
{$ELSE}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2o';
{$ENDIF}
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  SEditControlElideName = '@Editorcontrol@TCustomEditControl@Elide$qqri';
  SEditControlUnElideName = '@Editorcontrol@TCustomEditControl@unElide$qqri';
{$ENDIF}

type
  TControlHack = class(TControl);
{$IFDEF DELPHI10_SEATTLE_UP}
  TGetCanvasProc = function (Self: TObject): TCanvas;
{$ENDIF}
  TPaintLineProc = function (Self: TObject; Ek: Pointer;
    LineNum, V1, V2{$IFDEF DELPHI10_SEATTLE_UP}, V3 {$ENDIF}: Integer): Integer; register;
  TMarkLinesDirtyProc = procedure(Self: TObject; LineNum: Integer; Count: Word;
    Flag: Integer); register;
  TEdRefreshProc = procedure(Self: TObject; DirtyOnly: Boolean); register;
  TGetTextAtLineProc = function(Self: TObject; LineNum: Integer): string; register;
  TGetOTAEditViewProc = function(Self: TObject): IOTAEditView; register;
  TSetEditViewProc = function(Self: TObject; EditView: TObject): Integer;
  TLineIsElidedProc = function(Self: TObject; LineNum: Integer): Boolean;

{$IFDEF BDS}
  TPointFromEdPosProc = function(Self: TObject; const EdPos: TOTAEditPos;
    B1, B2: Boolean): TPoint;
  TIndexPosToCurPosProc = function(Self: TObject; Col: ShortInt; Row: Integer): ShortInt;
{$ENDIF}

{$IFDEF COMPILER7_UP}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1, B2: Boolean);
{$ELSE}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1: Boolean);
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  TEditControlElideProc = procedure(Self: TObject; Line: Integer);
  TEditControlUnElideProc = procedure(Self: TObject; Line: Integer);
{$ENDIF}

var
  PaintLine: TPaintLineProc = nil;
{$IFDEF DELPHI10_SEATTLE_UP}
  GetCanvas: TGetCanvasProc = nil;
{$ENDIF}
  GetOTAEditView: TGetOTAEditViewProc = nil;
  DoGetAttributeAtPos: TGetAttributeAtPosProc = nil;
  DoMarkLinesDirty: TMarkLinesDirtyProc = nil;
  EdRefresh: TEdRefreshProc = nil;
  DoGetTextAtLine: TGetTextAtLineProc = nil;
  SetEditView: TSetEditViewProc = nil;
  LineIsElided: TLineIsElidedProc = nil;
{$IFDEF BDS}
  PointFromEdPos: TPointFromEdPosProc = nil;
  IndexPosToCurPosProc: TIndexPosToCurPosProc = nil;
{$ENDIF}
{$IFDEF IDE_EDITOR_ELIDE}
  EditControlElide: TEditControlElideProc = nil;
  EditControlUnElide: TEditControlUnElideProc = nil;
{$ENDIF}

  PaintLineLock: TRTLCriticalSection;

function EditorChangeTypesToStr(ChangeType: TCnEditorChangeTypes): string;
var
  AType: TCnEditorChangeType;
begin
  Result := '';
  for AType := Low(AType) to High(AType) do
    if AType in ChangeType then
      if Result = '' then
        Result := GetEnumName(TypeInfo(TCnEditorChangeType), Ord(AType))
      else
        Result := Result + ', ' + GetEnumName(TypeInfo(TCnEditorChangeType), Ord(AType));
  Result := '[' + Result + ']';
end;

// 替换掉的 TCustomEditControl.PaintLine 函数
function MyPaintLine(Self: TObject; Ek: Pointer; LineNum, LogicLineNum, V2: Integer
  {$IFDEF DELPHI10_SEATTLE_UP}; V3: Integer {$ENDIF}): Integer;
var
  Idx: Integer;
  Editor: TCnEditorObject;
begin
  Result := 0;
  EnterCriticalSection(PaintLineLock);
  try
    Editor := nil;
    if IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
    begin
      Idx := FEditControlWrapper.IndexOfEditor(TControl(Self));
      if Idx >= 0 then
      begin
        Editor := FEditControlWrapper.GetEditors(Idx);
      end;
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;

    if FEditControlWrapper.FPaintLineHook.UseDDteours then
    begin
      try
        Result := TPaintLineProc(FEditControlWrapper.FPaintLineHook.Trampoline)(Self, Ek, LineNum, LogicLineNum, V2{$IFDEF DELPHI10_SEATTLE_UP}, V3 {$ENDIF});
      except
        on E: Exception do
          DoHandleException(E.Message);
      end;
    end
    else
    begin
      FEditControlWrapper.FPaintLineHook.UnhookMethod;
      try
        try
          Result := PaintLine(Self, Ek, LineNum, LogicLineNum, V2{$IFDEF DELPHI10_SEATTLE_UP}, V3 {$ENDIF});
        except
          on E: Exception do
            DoHandleException(E.Message);
        end;
      finally
        FEditControlWrapper.FPaintLineHook.HookMethod;
      end;
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;
  finally
    LeaveCriticalSection(PaintLineLock);
  end;
end;

function MySetEditView(Self: TObject; EditView: TObject): Integer;
begin
  if Assigned(EditView) and (Self is TControl) and
    (TControl(Self).Owner is TCustomForm) and
    IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
  begin
    FEditControlWrapper.CheckNewEditor(TControl(Self), GetOTAEditView(EditView));
  end;

  if FEditControlWrapper.FSetEditViewHook.UseDDteours then
    Result := TSetEditViewProc(FEditControlWrapper.FSetEditViewHook.Trampoline)(Self, EditView)
  else
  begin
    FEditControlWrapper.FSetEditViewHook.UnhookMethod;
    try
      Result := SetEditView(Self, EditView);
    finally
      FEditControlWrapper.FSetEditViewHook.HookMethod;
    end;
  end;
end;

constructor TCnEditControlWrapper.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  FOptionChanged := True;

  FCmpLines := TList.Create;
  FBeforePaintLineNotifiers := TList.Create;
  FAfterPaintLineNotifiers := TList.Create;
  FEditControlNotifiers := TList.Create;
  FEditorChangeNotifiers := TList.Create;
  FKeyDownNotifiers := TList.Create;
  FKeyUpNotifiers := TList.Create;
  FMouseUpNotifiers := TList.Create;
  FMouseDownNotifiers := TList.Create;
  FMouseMoveNotifiers := TList.Create;
  FMouseLeaveNotifiers := TList.Create;
  FEditControlList := TList.Create;
  FNcPaintNotifiers := TList.Create;
  FVScrollNotifiers := TList.Create;

  FEditorList := TObjectList.Create;
  InitEditControlHook;

  FHighlights := TStringList.Create;
  FBpClickQueue := TQueue.Create;
  FEditorBaseFont := TFont.Create;

  for I := Low(Self.FFontArray) to High(FFontArray) do
    FFontArray[I] := TFont.Create;
  FBackgroundColor := clWhite;

  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.AddAfterThemeChangeNotifier(AfterThemeChange);
  CnWizNotifierServices.AddGetMsgNotifier(OnGetMsgProc, [WM_MOUSEMOVE, WM_NCMOUSEMOVE,
    WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDOWN, WM_RBUTTONUP,
    WM_MBUTTONDOWN, WM_MBUTTONUP, WM_NCLBUTTONDOWN, WM_NCLBUTTONUP, WM_NCRBUTTONDOWN,
    WM_NCRBUTTONUP, WM_NCMBUTTONDOWN, WM_NCMBUTTONUP, WM_MOUSELEAVE, WM_NCMOUSELEAVE]);
  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet,
    [WM_VSCROLL, WM_HSCROLL, WM_NCPAINT, WM_NCACTIVATE {$IFDEF IDE_SUPPORT_HDPI}, WM_DPICHANGED {$ENDIF}]);
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);

  UpdateEditControlList;
  GetHighlightFromReg;
  LoadFontFromRegistry;
end;

destructor TCnEditControlWrapper.Destroy;
var
  I: Integer;
begin
  for I := Low(Self.FFontArray) to High(FFontArray) do
    FFontArray[I].Free;

  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.RemoveGetMsgNotifier(OnGetMsgProc);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);

  FEditorBaseFont.Free;
  while FBpClickQueue.Count > 0 do
    TObject(FBpClickQueue.Pop).Free;
  FBpClickQueue.Free;

  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
  if FPaintLineHook <> nil then
    FPaintLineHook.Free;
  if FSetEditViewHook <> nil then
    FSetEditViewHook.Free;

  FEditControlList.Free;
  FEditorList.Free;

  ClearHighlights;
  FHighlights.Free;

  ClearAndFreeList(FVScrollNotifiers);
  ClearAndFreeList(FNcPaintNotifiers);
  ClearAndFreeList(FMouseUpNotifiers);
  ClearAndFreeList(FMouseDownNotifiers);
  ClearAndFreeList(FMouseMoveNotifiers);
  ClearAndFreeList(FMouseLeaveNotifiers);
  ClearAndFreeList(FBeforePaintLineNotifiers);
  ClearAndFreeList(FAfterPaintLineNotifiers);
  ClearAndFreeList(FEditControlNotifiers);
  ClearAndFreeList(FEditorChangeNotifiers);
  ClearAndFreeList(FKeyDownNotifiers);
  ClearAndFreeList(FKeyUpNotifiers);

  FCmpLines.Free;
  inherited;
end;

procedure TCnEditControlWrapper.InitEditControlHook;
begin
  try
    FCorIdeModule := LoadLibrary(CorIdeLibName);
    CnWizAssert(FCorIdeModule <> 0, 'Load FCorIdeModule');

    GetOTAEditView := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetOTAEditViewName));
    CnWizAssert(Assigned(GetOTAEditView), 'Load GetOTAEditView from FCorIdeModule');

    DoGetAttributeAtPos := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetAttributeAtPosName));
    CnWizAssert(Assigned(DoGetAttributeAtPos), 'Load GetAttributeAtPos from FCorIdeModule');

    PaintLine := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SPaintLineName));
    CnWizAssert(Assigned(PaintLine), 'Load PaintLine from FCorIdeModule');

{$IFDEF DELPHI10_SEATTLE_UP}
    GetCanvas := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetCanvas));
    CnWizAssert(Assigned(GetCanvas), 'Load GetCanvas from FCorIdeModule');
{$ENDIF}

    DoMarkLinesDirty := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SMarkLinesDirtyName));
    CnWizAssert(Assigned(DoMarkLinesDirty), 'Load MarkLinesDirty from FCorIdeModule');

    EdRefresh := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEdRefreshName));
    CnWizAssert(Assigned(EdRefresh), 'Load EdRefresh from FCorIdeModule');

    DoGetTextAtLine := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetTextAtLineName));
    CnWizAssert(Assigned(DoGetTextAtLine), 'Load GetTextAtLine from FCorIdeModule');

{$IFDEF IDE_EDITOR_ELIDE}
    LineIsElided := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SLineIsElidedName));
    CnWizAssert(Assigned(LineIsElided), 'Load LineIsElided from FCorIdeModule');

    EditControlElide := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEditControlElideName));
    CnWizAssert(Assigned(EditControlElide), 'Load EditControlElide from FCorIdeModule');

    EditControlUnElide := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEditControlUnElideName));
    CnWizAssert(Assigned(EditControlUnElide), 'Load EditControlUnElide from FCorIdeModule');
{$ENDIF}

{$IFDEF BDS}
    // BDS 下才有效
    PointFromEdPos := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SPointFromEdPosName));
    CnWizAssert(Assigned(PointFromEdPos), 'Load PointFromEdPos from FCorIdeModule');

    IndexPosToCurPosProc := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SIndexPosToCurPosName));
    CnWizAssert(Assigned(IndexPosToCurPosProc), 'Load IndexPosToCurPos from FCorIdeModule');
{$ENDIF}


    SetEditView := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetEditViewName));
    CnWizAssert(Assigned(SetEditView), 'Load SetEditView from FCorIdeModule');

    FPaintLineHook := TCnMethodHook.Create(@PaintLine, @MyPaintLine);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.PaintLine Hooked');
{$ENDIF}

    FSetEditViewHook := TCnMethodHook.Create(@SetEditView, @MySetEditView);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.SetEditView Hooked');
{$ENDIF}

    FPaintNotifyAvailable := True;
  except
    FPaintNotifyAvailable := False;
  end;
end;

//------------------------------------------------------------------------------
// 编辑器控件列表处理
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.CheckNewEditor(EditControl: TControl;
  View: IOTAEditView);
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    Editors[Idx].SetEditView(View);
    DoEditorChange(Editors[Idx], [ctView]);
  end
  else
  begin
    AddEditor(EditControl, View);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: New EditControl.');
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.AddEditor(EditControl: TControl;
  View: IOTAEditView): Integer;
begin
  Result := FEditorList.Add(TCnEditorObject.Create(EditControl, View));
end;

procedure TCnEditControlWrapper.DeleteEditor(EditControl: TControl);
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    FEditorList.Delete(Idx);
    DoEditControlNotify(EditControl, opRemove);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: EditControl Removed.');
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetEditorContext(Editor: TCnEditorObject):
  TCnEditorContext;
begin
  FillChar(Result, SizeOf(TCnEditorContext), 0);
  if (Editor <> nil) and (Editor.EditView <> nil) and (Editor.EditControl <> nil) then
  begin
    Result.TopRow := Editor.EditView.TopRow;
    Result.BottomRow := Editor.EditView.BottomRow;
    Result.LeftColumn := Editor.EditView.LeftColumn;
    Result.CurPos := Editor.EditView.CursorPos;
    Result.ModTime := Editor.EditView.Buffer.GetCurrentDate;
    Result.LineCount := Editor.EditView.Buffer.GetLinesInBuffer;
    Result.BlockValid := Editor.EditView.Block.IsValid;
    Result.BlockSize := Editor.EditView.Block.Size;
    Result.BlockStartingColumn := Editor.EditView.Block.StartingColumn;
    Result.BlockStartingRow := Editor.EditView.Block.StartingRow;
    Result.BlockEndingColumn := Editor.EditView.Block.EndingColumn;
    Result.BlockEndingRow := Editor.EditView.Block.EndingRow;
    Result.EditView := Pointer(Editor.EditView);
    Result.LineText := GetStrProp(Editor.EditControl, 'LineText');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount);
{$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetEditorCount: Integer;
begin
  Result := FEditorList.Count;
end;

function TCnEditControlWrapper.GetEditors(Index: Integer): TCnEditorObject;
begin
  Result := TCnEditorObject(FEditorList[Index]);
end;

function TCnEditControlWrapper.GetEditorObject(
  EditControl: TControl): TCnEditorObject;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := Editors[Idx]
  else
    Result := nil;
end;

function TCnEditControlWrapper.IndexOfEditor(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to EditorCount - 1 do
  begin
    if Editors[I].EditControl = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnEditControlWrapper.IndexOfEditor(EditView: IOTAEditView): Integer;
var
  I: Integer;
begin
  for I := 0 to EditorCount - 1 do
  begin
    if Editors[I].EditView = EditView then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnEditControlWrapper.CheckViewLinesChange(Editor: TCnEditorObject;
  Context: TCnEditorContext): Boolean;
var
  I, Idx, LineCount: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditControlWrapper.CheckViewLinesChange');
{$ENDIF}
  Result := False;
  FCmpLines.Clear;

  LineCount := Context.LineCount;
  Idx := Context.TopRow;
  Editor.FLastTop := Idx;
  Editor.FLastBottomElided := GetLineIsElided(Editor.EditControl, LineCount);
  for I := Context.TopRow to Context.BottomRow do
  begin
    FCmpLines.Add(Pointer(Idx));
    repeat
      Inc(Idx);
      if Idx > LineCount then
        Break;
    until not GetLineIsElided(Editor.EditControl, Idx);

    if Idx > LineCount then
      Break;
  end;

  if FCmpLines.Count <> Editor.FLines.Count then
    Result := True
  else
  begin
    for I := 0 to FCmpLines.Count - 1 do
    begin
      if FCmpLines[I] <> Editor.FLines[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  if Result then
  begin
    Editor.FLines.Count := FCmpLines.Count;
    for I := 0 to FCmpLines.Count - 1 do
      Editor.FLines[I] := FCmpLines[I];
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Lines Changed');
  {$ENDIF}
  end;

  Editor.FLinesChanged := False;
  FCmpLines.Clear;
end;

function TCnEditControlWrapper.CheckEditorChanges(Editor: TCnEditorObject):
  TCnEditorChangeTypes;
var
  Context, OldContext: TCnEditorContext;
  ACtrl: TControl;
begin
  Result := [];

  // 始终判断编辑器是否在最顶端
  ACtrl := Editor.GetTopEditor;
  if Editor.FTopControl <> ACtrl then
  begin
    Include(Result, ctTopEditorChanged);
    Editor.FTopControl := ACtrl;
  end;

  if not Editor.EditControl.Visible or (Editor.EditView = nil) then
  begin
    if Editor.FLastValid then
    begin
      // 可能执行 Close All 导致 EditView 释放了
      Include(Result, ctView);
      Editor.FLastValid := False;
    end;
    Exit;
  end;

  // 编辑器不在最前端时不进行后继判断
  if ACtrl <> Editor.EditControl then
    Exit;

  try
    Context := GetEditorContext(Editor);
    Editor.FLastValid := True;
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditorContext Error');
  {$ENDIF}
  {$IFDEF BDS}
    // BDS 下，时常出现 EditView 已经被释放而导致出错的情况，此处将其置 nil
    Editor.FEditView := nil;
    Include(Result, ctView);
    Exit;
  {$ENDIF}
  end;
  OldContext := Editor.Context;

  if (Context.TopRow <> OldContext.TopRow) or
    (Context.BottomRow <> OldContext.BottomRow) then
    Include(Result, ctWindow);

  if (Context.LeftColumn <> OldContext.LeftColumn) then
    Include(Result, ctHScroll);

  if Context.CurPos.Line <> OldContext.CurPos.Line then
    Include(Result, ctCurrLine);

  if Context.CurPos.Col <> OldContext.CurPos.Col then
    Include(Result, ctCurrCol);

  if (Context.BlockValid <> OldContext.BlockValid) or
    (Context.BlockSize <> OldContext.BlockSize) or
    (Context.BlockStartingColumn <> OldContext.BlockStartingColumn) or
    (Context.BlockStartingRow <> OldContext.BlockStartingRow) or
    (Context.BlockEndingColumn <> OldContext.BlockEndingColumn) or
    (Context.BlockEndingRow <> OldContext.BlockEndingRow) then
    Include(Result, ctBlock);

  if Context.EditView <> OldContext.EditView then
    Include(Result, ctView);

  if Editor.FLinesChanged or (Result * [ctWindow, ctView] <> []) or
    (Editor.FLastBottomElided <> GetLineIsElided(Editor.EditControl,
    Context.LineCount)) then
  begin
    // 如果首尾行分布发生变化，又不是因为 Window 改变或 View 改变，则认为折叠改变了
    if CheckViewLinesChange(Editor, Context) then
    begin
{$IFDEF IDE_EDITOR_ELIDE}
      if Result * [ctWindow, ctView] = [] then
        Result := Result + [ctElided, ctUnElided];
{$ENDIF}
    end;
  end;

{$IFDEF BDS}
  if Context.LineDigit <> OldContext.LineDigit then
    Include(Result, ctLineDigit);
{$ENDIF}

  // 有时候 EditBuffer 修改后时间未变化
  if (Context.LineCount <> OldContext.LineCount) or
    (Context.ModTime <> OldContext.ModTime) then
  begin
    Include(Result, ctModified);
  end
  else if (Context.CurPos.Line = OldContext.CurPos.Line) and
    (Context.LineText <> OldContext.LineText) then
  begin
    Include(Result, ctModified);
  end
  else if (Context.BlockSize <> OldContext.BlockSize) and
    (Context.BlockStartingRow = OldContext.BlockStartingRow) and
    (Context.BlockEndingColumn = OldContext.BlockEndingColumn) and
    (Context.BlockEndingRow = OldContext.BlockEndingRow) and
    (Context.BlockEndingRow = Context.CurPos.Line) then
  begin
    // 块缩进、反缩进时块位置不变而大小变化
    Include(Result, ctModified);
  end;

  Editor.FContext := Context;
end;

procedure TCnEditControlWrapper.OnIdle(Sender: TObject);
var
  I: Integer;
  OptionType: TCnEditorChangeTypes;
  ChangeType: TCnEditorChangeTypes;
  Option: IOTAEditOptions;
{$IFDEF IDE_HAS_ERRORINSIGHT}
  IsSmoothWave: Boolean;
{$ENDIF}
begin
  OptionType := [];

  Option := CnOtaGetEditOptions;
  if Option <> nil then
  begin
{$IFDEF IDE_HAS_ERRORINSIGHT}
    IsSmoothWave := GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave;
{$ENDIF}
    if not SameText(Option.FontName, FSaveFontName) or (Option.FontSize <> FSaveFontSize)
      {$IFDEF IDE_HAS_ERRORINSIGHT} or IsSmoothWave <> FSaveErrorInsightIsSmoothWave {$ENDIF} then
    begin
      FOptionChanged := True;
    end;
  end;

  if FOptionChanged then
  begin
    Include(OptionType, ctOptionChanged);
    if UpdateCharSize then             // 重新读取高亮颜色，会更新 FSave 系列变量供下次对比
      Include(OptionType, ctFont);

    LoadFontFromRegistry;              // 重新读取高亮字体
    FOptionChanged := False;
  end;

  for I := 0 to EditorCount - 1 do
  begin
    ChangeType := CheckEditorChanges(Editors[I]) + OptionType;
    if ChangeType <> [] then
    begin
      DoEditorChange(Editors[I], ChangeType);
    end;
  end;
end;

//------------------------------------------------------------------------------
// 字体及高亮计算
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.GetHighlightFromReg;
const
{$IFDEF COMPILER7_UP}
  csColorBkName = 'Background Color New';
  csColorFgName = 'Foreground Color New';
{$ELSE}
  csColorBkName = 'Background Color';
  csColorFgName = 'Foreground Color';
{$ENDIF}
var
  I: Integer;
  Reg: TRegistry;
  Names, Values: TStringList;
  Item: TCnHighlightItem;

  function RegReadBool(Reg: TRegistry; const AName: string): Boolean;
  var
    Value: string;
  begin
    if Reg.ValueExists(AName) then
    begin
      Value := Reg.ReadString(AName);
      Result := not (SameText(Value, 'False') or (Value = '0'));
    end
    else
      Result := False;
  end;

  function RegReadColor(Reg: TRegistry; const AName: string): TColor;
  begin
    if Reg.ValueExists(AName) then
    begin
      if Reg.GetDataType(AName) = rdInteger then
        Result := SCnColor16Table[TrimInt(Reg.ReadInteger(AName), 0, 16)]
      else if Reg.GetDataType(AName) = rdString then
        Result := StringToColor(Reg.ReadString(AName))
      else
        Result := clNone;
    end
    else
      Result := clNone;
  end;

begin
  if WizOptions = nil then
    Exit;

  ClearHighlights;
  Reg := nil;
  Names := nil;
  Values := nil;

  try
    Names := TStringList.Create;
    Values := TStringList.Create;
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Highlight') then
    begin
      Reg.GetKeyNames(Names);
      for I := 0 to Names.Count - 1 do
      begin
        if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath +
          '\Editor\Highlight\' + Names[I]) then
        begin
          Item := nil;
          try
            Reg.GetValueNames(Values);
            if Values.Count > 0 then // 此键有数据
            begin
              Item := TCnHighlightItem.Create;
              Item.Bold := RegReadBool(Reg, 'Bold');
              Item.Italic := RegReadBool(Reg, 'Italic');
              Item.Underline := RegReadBool(Reg, 'Underline');
              if RegReadBool(Reg, 'Default Background') then
                Item.ColorBk := clWhite
              else
                Item.ColorBk := RegReadColor(Reg, csColorBkName);
              if RegReadBool(Reg, 'Default Foreground') then
                Item.ColorFg := clWindowText
              else
                Item.ColorFg := RegReadColor(Reg, csColorFgName);
              FHighlights.AddObject(Names[I], Item);
            end;
          except
            on E: Exception do
            begin
              if Item <> nil then
                Item.Free;
              DoHandleException(E.Message);
            end;
          end;
        end;
      end;
    end;
  finally
    Values.Free;
    Names.Free;
    Reg.Free;
  end;
end;

function TCnEditControlWrapper.UpdateCharSize: Boolean;
begin
  Result := False;
  if FOptionChanged and (GetCurrentEditControl <> nil) and
    (CnOtaGetEditOptions <> nil) then
    Result := CalcCharSize;
end;

function TCnEditControlWrapper.CalcCharSize: Boolean;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
var
  LogFont, AFont: TLogFont;
  DC: HDC;
  SaveFont: HFONT;
  Option: IOTAEditOptions;
  Control: TControlHack;
  FontName: string;
  FontHeight: Integer;
  Size: TSize;
  I: Integer;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  V: Integer;
{$ENDIF}

  procedure CalcFont(const AName: string; ALogFont: TLogFont);
  var
    AHandle: THandle;
    TM: TEXTMETRIC;
  begin
    AHandle := CreateFontIndirect(ALogFont);
    AHandle := SelectObject(DC, AHandle);
    if SaveFont = 0 then
      SaveFont := AHandle
    else if AHandle <> 0 then
      DeleteObject(AHandle);

    GetTextMetrics(DC, TM);
    GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), Size);

    // 取文本高度
    if TM.tmHeight + TM.tmExternalLeading > FCharSize.cy then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TextMetrics tmHeight %d + ExternalLeading %d > Cy %d. Increase.',
        [TM.tmHeight, TM.tmExternalLeading, FCharSize.cy]);
{$ENDIF}
      FCharSize.cy := TM.tmHeight + TM.tmExternalLeading;
    end;

    if Size.cy > FCharSize.cy then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TextExtentPoint Size.cy %d > FCharSize.cy %d. Increase.',
        [Size.cy, FCharSize.cy]);
{$ENDIF}
      FCharSize.cy := Size.cy;
    end;

    // 取文本宽度
    if TM.tmAveCharWidth > FCharSize.cx then
      FCharSize.cx := TM.tmAveCharWidth;
    if Size.cx div Length(csAlphaText) > FCharSize.cx then
      FCharSize.cx := Size.cx div Length(csAlphaText);

  {$IFDEF DEBUG}
    CnDebugger.LogFmt('[%s] TM.Height: %d TM.Width: %d Size.cx: %d / %d Size.cy: %d',
      [AName, TM.tmHeight + TM.tmExternalLeading, TM.tmAveCharWidth,
      Size.cx, Length(csAlphaText), Size.cy]);
  {$ENDIF}
  end;

begin
  Result := False;
  FCharSize.cx := 0;
  FCharSize.cy := 0;

  Control := TControlHack(GetCurrentEditControl);
  Option := CnOtaGetEditOptions;
  if not Assigned(Control) or not Assigned(Option) then
    Exit;

  GetHighlightFromReg;

  if GetObject(Control.Font.Handle, SizeOf(LogFont), @LogFont) <> 0 then
  begin
    // 坑一：EditControl.Font 一般是默认的 MS Sans Serif，不代表真实情况
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.CalcCharSize');
    CnDebugger.LogFmt('FontName: %s Height: %d Width: %d',
      [LogFont.lfFaceName, LogFont.lfHeight, LogFont.lfWidth]);
  {$ENDIF}

    FSaveFontName := Option.FontName;
    FSaveFontSize := Option.FontSize;
  {$IFDEF IDE_HAS_ERRORINSIGHT}
    FSaveErrorInsightIsSmoothWave := GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave;
  {$ENDIF}

    // 坑二：在编辑器设置对话框里选了字体再取消，Options 里会被更新成选择后的字体，导致和实际情况不符
    FontName := Option.FontName;
    FontHeight := -MulDiv(Option.FontSize, Screen.PixelsPerInch, 72);

    // 保留一份编辑器字体对象供使用
    FEditorBaseFont.Name := Option.FontName;
    FEditorBaseFont.Size := Option.FontSize;

    if not SameText(FontName, LogFont.lfFaceName) or (FontHeight <> LogFont.lfHeight) then
    begin
      // 调整为系统设置的字体
      StrCopy(LogFont.lfFaceName, PChar(FontName));
      LogFont.lfHeight := FontHeight;
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Adjust FontName: %s Height: %d', [FontName, FontHeight]);
    {$ENDIF}
      // 再保留一份编辑器字体对象供使用
      FEditorBaseFont.Name := FontName;
      FEditorBaseFont.Height := FontHeight;
    end;

    DC := CreateCompatibleDC(0);
    try
      SaveFont := 0;
      if HighlightCount > 0 then
      begin
        for I := 0 to HighlightCount - 1 do
        begin
          AFont := LogFont;
          if Highlights[I].Bold then
            AFont.lfWeight := FW_BOLD;
          if Highlights[I].Italic then
            AFont.lfItalic := 1;
          if Highlights[I].Underline then
            AFont.lfUnderline := 1;
          CalcFont(HighlightNames[I], AFont);
        end;
      {$IFDEF DEBUG}
        CnDebugger.LogFmt('CharSize from registry: X = %d Y = %d',
          [FCharSize.cx, FCharSize.cy]);
      {$ENDIF}
      end
      else
      begin
      {$IFDEF DEBUG}
        CnDebugger.LogMsgWarning('Access registry fail.');
      {$ENDIF}
        AFont := LogFont;
        AFont.lfWeight := FW_BOLD;
        CalcFont('Bold', AFont);

        AFont := LogFont;
        AFont.lfItalic := 1;
        CalcFont('Italic', AFont);
      end;

      // 判断 ErrorInsight 是否导致 y 尺寸改变
      if GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('GetEditControlCharHeight: Smooth Wave Found.',
          [csErrorInsightCharHeightOffset]);
{$ENDIF}
        Inc(FCharSize.cy, csErrorInsightCharHeightOffset);
      end;

      Result := (FCharSize.cx > 0) and (FCharSize.cy > 0);

      // 兜底办法，拿 EditControl 的 CharHeight 和 CharWidth 属性，注意普通办法拿不到
      // --- 拿到后，覆盖上面所有的字符长宽计算结果！---
{$IFDEF SUPPORT_ENHANCED_RTTI}
      RttiContext := TRttiContext.Create;
      try
        RttiType := RttiContext.GetType(Control.ClassType);
        try
          RttiProperty := RttiType.GetProperty('CharHeight');
          V := RttiProperty.GetValue(Control).AsInteger;
          if (V > 1) and (V <> FCharSize.cy) then
          begin
            FCharSize.cy := V;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('RTTI EditControl CharHeight %d.', [V]);
{$ENDIF}
          end;
        except
          ;
        end;

        try
          RttiProperty := RttiType.GetProperty('CharWidth');
          V := RttiProperty.GetValue(Control).AsInteger;
          if (V > 1) and (V <> FCharSize.cx) then
          begin
            FCharSize.cx := V;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('RTTI EditControl CharWidth %d.', [V]);
{$ENDIF}
          end;
        except
          ;
        end;
      finally
        RttiContext.Free;
      end;
{$ENDIF}

{$IFDEF DEBUG}
      CnDebugger.LogFmt('Finally Get FCharSize: x %d, y %d.',
        [FCharSize.cx, FCharSize.cy]);
{$ENDIF}
    finally
      SaveFont := SelectObject(DC, SaveFont);
      if SaveFont <> 0 then
        DeleteObject(SaveFont);
      DeleteDC(DC);
    end;
  end;
end;

function TCnEditControlWrapper.GetCharHeight: Integer;
begin
  Result := GetCharSize.cy;
end;

function TCnEditControlWrapper.GetCharSize: TSize;
begin
  UpdateCharSize;
  Result := FCharSize;
end;

function TCnEditControlWrapper.GetCharWidth: Integer;
begin
  Result := GetCharSize.cx;
end;

function TCnEditControlWrapper.GetEditControlInfo(EditControl: TControl):
  TCnEditControlInfo;
begin
  try
    Result.TopLine := GetOrdProp(EditControl, 'TopLine');
    Result.LinesInWindow := GetOrdProp(EditControl, 'LinesInWindow');
    Result.LineCount := GetOrdProp(EditControl, 'LineCount');
    Result.CaretX := GetOrdProp(EditControl, 'CaretX');
    Result.CaretY := GetOrdProp(EditControl, 'CaretY');
    Result.CharXIndex := GetOrdProp(EditControl, 'CharXIndex');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount);
{$ENDIF}
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

function TCnEditControlWrapper.GetEditControlCharHeight(
  EditControl: TControl): Integer;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
var
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  H: Integer;
{$ELSE}
  Options: IOTAEditOptions;
  Control: TControlHack;
  FontName: string;
  FontHeight: Integer;
  DC: HDC;
  ASize: TSize;
  LgFont: TLogFont;
  FontHandle: THandle;
  TM: TEXTMETRIC;
{$ENDIF}
begin
  if EditControl = nil then
    EditControl := GetTopMostEditControl;

  // TODO: D2010或以上，直接用新 RTTI 带的 CharHeight 属性，以下则判断是否高亮，
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(EditControl.ClassInfo);
    if RttiType <> nil then
    begin
      RttiProperty := RttiType.GetProperty('CharHeight');
      if RttiProperty <> nil then
      begin
        H := RttiProperty.GetValue(EditControl).AsInteger;
        if H > 0 then
        begin
          Result := H;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('GetEditControlCharHeight: Get CharHeight Property %d.', [H]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  finally
    RttiContext.Free;
  end;
  Result := GetCharHeight;
{$ELSE}
  if GetEditControlSupportsSyntaxHighlight(EditControl) then
  begin
    // 支持语法高亮，直接用之前计算过的 CharHeight
    Result := GetCharHeight;
  end
  else
  begin
    // 不支持语法高亮，用默认字体绘制的办法获取
    Control := TControlHack(EditControl);
    Options := CnOtaGetEditOptions;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditControlCharHeight: NO Syntax Highlight. Re-calc.');
{$ENDIF}
    if (Options <> nil) and (GetObject(Control.Font.Handle, SizeOf(LgFont), @LgFont) <> 0) then
    begin
      FontName := Options.FontName;
      FontHeight := -MulDiv(Options.FontSize, Screen.PixelsPerInch, 72);
      if not SameText(FontName, LgFont.lfFaceName) or (FontHeight <> LgFont.lfHeight) then
      begin
        StrCopy(LgFont.lfFaceName, PChar(FontName));
        LgFont.lfHeight := FontHeight;
      end;

      DC := CreateCompatibleDC(0);
      try
        FontHandle := CreateFontIndirect(LgFont);
        SelectObject(DC, FontHandle);

        GetTextMetrics(DC, TM);
        GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), ASize);

        Result := TM.tmHeight + TM.tmExternalLeading;
        if ASize.cy > Result then
          Result := ASize.cy;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('GetEditControlCharHeight: TextMetrics Height %d Ext %d, Size.cy %d.',
          [TM.tmHeight, TM.tmExternalLeading, ASize.cy]);
{$ENDIF}
        DeleteObject(FontHandle);
        Exit;
      finally
        DeleteDC(DC);
      end;
    end;
    Result := GetCharHeight;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetEditControlSupportsSyntaxHighlight(
  EditControl: TControl): Boolean;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := CnOtaEditViewSupportsSyntaxHighlight(Editors[Idx].EditView)
  else
    Result := False;
end;

function TCnEditControlWrapper.GetEditControlCanvas(
  EditControl: TControl): TCanvas;
begin
  Result := nil;
  if EditControl = nil then Exit;
{$IFDEF BDS}
  {$IFDEF DELPHI10_SEATTLE_UP}
    // Delphi 10 Seattle 的绘制 Canvas 是其内部的一个 Bitmap 的 Canvas，不是 Control 本身的
    Result := GetCanvas(EditControl);
  {$ELSE}
    {$IFDEF BDS2009_UP}
      // BDS 2009 的 TControl 已经 Unicode 化了，直接用
      Result := TCustomControlHack(EditControl).Canvas;
    {$ELSE}
      // BDS 2009 以下的 EditControl 不再继承自 TCustomControl，因此得用硬办法来获得画布
      Result := TCanvas((PInteger(Integer(EditControl) + CnWideControlCanvasOffset))^);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  Result := TCustomControlHack(EditControl).Canvas;
{$ENDIF}
end;

function TCnEditControlWrapper.GetHighlight(Index: Integer): TCnHighlightItem;
begin
  Result := TCnHighlightItem(FHighlights.Objects[Index]);
end;

function TCnEditControlWrapper.GetHighlightCount: Integer;
begin
  Result := FHighlights.Count;
end;

function TCnEditControlWrapper.GetHighlightName(Index: Integer): string;
begin
  Result := FHighlights[Index];
end;

function TCnEditControlWrapper.IndexOfHighlight(
  const Name: string): Integer;
begin
  Result := FHighlights.IndexOf(Name);
end;

procedure TCnEditControlWrapper.ClearHighlights;
var
  I: Integer;
begin
  for I := 0 to FHighlights.Count - 1 do
    FHighlights.Objects[I].Free;
  FHighlights.Clear;
end;

//------------------------------------------------------------------------------
// 编辑器操作
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if IsEditControl(AComponent) and (Operation = opRemove) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opRemove');
  {$ENDIF}
    FEditControlList.Remove(AComponent);
    DeleteEditor(TControl(AComponent));
  end;
end;

procedure TCnEditControlWrapper.EditControlProc(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
begin
  if (EditControl <> nil) and (FEditControlList.IndexOf(EditControl) < 0) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opInsert');
  {$ENDIF}
    FEditControlList.Add(EditControl);
    EditControl.FreeNotification(Self);
    DoEditControlNotify(EditControl, opInsert);
  end;
end;

procedure TCnEditControlWrapper.UpdateEditControlList;
begin
  EnumEditControl(EditControlProc, nil);
end;

procedure TCnEditControlWrapper.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
{$IFDEF DELPHI2007_UP}
var
  I: Integer;
{$ENDIF}
begin
  if NotifyType = setEditViewActivated then
    UpdateEditControlList;
{$IFDEF DELPHI2007_UP}
  if NotifyType = setEditViewRemove then
  begin
    // RAD Studio 2007 Update1 下，Close All 时 EditControl 似乎不会释放，
    // 为了防止 EditView 释放了而 EditControl 没有释放的情况，此处进行检查
    for I := 0 to EditorCount - 1 do
    begin
      if Editors[I].EditView = EditView then
      begin
        NoRef(Editors[I].FEditView) := nil;
        Break;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnEditControlWrapper.CheckOptionDlg;

  function IsEditorOptionDlgVisible: Boolean;
  var
    I: Integer;
  begin
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[I].ClassNameIs(SEditorOptionDlgClassName) and
        SameText(Screen.CustomForms[I].Name, SEditorOptionDlgName) and
        Screen.CustomForms[I].Visible then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

begin
  if IsEditorOptionDlgVisible then
    FOptionDlgVisible := True
  else if FOptionDlgVisible then
  begin
    FOptionDlgVisible := False;
    FOptionChanged := True;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Option Dialog Closed. Editor Option Changed');
{$ENDIF}
  end;
end;

procedure TCnEditControlWrapper.AfterThemeChange(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('EditControlWrapper AfterThemeChange. Option Changed.');
{$ENDIF}
  FOptionChanged := True;
end;

procedure TCnEditControlWrapper.OnActiveFormChange(Sender: TObject);
begin
  UpdateEditControlList;
  CheckOptionDlg;
end;

function TCnEditControlWrapper.GetEditView(EditControl: TControl): IOTAEditView;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := Editors[Idx].EditView
  else
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogMsgWarning('GetEditView: not found in list.');
{$ENDIF}
    Result := CnOtaGetTopMostEditView;
  end;
end;

function TCnEditControlWrapper.GetEditControl(EditView: IOTAEditView): TControl;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditView);
  if Idx >= 0 then
    Result := Editors[Idx].EditControl
  else
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogMsgWarning('GetEditControl: not found in list.');
{$ENDIF}
    Result := CnOtaGetCurrentEditControl;
  end;
end;

function TCnEditControlWrapper.GetTopMostEditControl: TControl;
var
  Idx: Integer;
  EditView: IOTAEditView;
begin
  Result := nil;
  EditView := CnOtaGetTopMostEditView;
  for Idx := 0 to EditorCount - 1 do
  begin
    if Editors[Idx].EditView = EditView then
    begin
      Result := Editors[Idx].EditControl;
      Exit;
    end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsgWarning('GetTopMostEditControl: not found in list.');
{$ENDIF}
end;

function TCnEditControlWrapper.GetEditViewFromTabs(TabControl: TXTabControl;
  Index: Integer): IOTAEditView;
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
var
  Tabs: TStrings;
{$ENDIF}
begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
  if Assigned(GetOTAEditView) and (TabControl <> nil) and (GetEditorTabTabIndex(TabControl) >= 0) then
  begin
    Tabs := GetEditorTabTabs(TabControl);
    if (Tabs <> nil) and (Tabs.Objects[Index] <> nil) then
    begin
      if Tabs.Objects[Index].ClassNameIs(STEditViewClass) then
      begin
        Result := GetOTAEditView(Tabs.Objects[Index]);
        Exit;
      end;
    end;
  end;
  Result := nil;
{$ELSE}
  if Assigned(GetOTAEditView) and (TabControl <> nil) and
    (TabControl.TabIndex >= 0) and (TabControl.Tabs.Objects[Index] <> nil) and
    TabControl.Tabs.Objects[Index].ClassNameIs(STEditViewClass) then
    Result := GetOTAEditView(TabControl.Tabs.Objects[Index])
  else
    Result := nil;
{$ENDIF}
end;

procedure TCnEditControlWrapper.GetAttributeAtPos(EditControl: TControl; const
  EdPos: TOTAEditPos; IncludeMargin: Boolean; var Element, LineFlag: Integer);
begin
  if Assigned(DoGetAttributeAtPos) then
  begin
  {$IFDEF COMPILER7_UP}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin, True);
  {$ELSE}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin);
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetLineIsElided(EditControl: TControl;
  LineNum: Integer): Boolean;
begin
  Result := False;
  try
    if Assigned(LineIsElided) then
      Result := LineIsElided(EditControl, LineNum);
  except
    ;
  end;
end;

{$IFDEF BDS}

function TCnEditControlWrapper.GetPointFromEdPos(EditControl: TControl;
  APos: TOTAEditPos): TPoint;
begin
  if Assigned(PointFromEdPos) then
    Result := PointFromEdPos(EditControl, APos, True, True);
end;

{$ENDIF}

procedure TCnEditControlWrapper.MarkLinesDirty(EditControl: TControl; Line:
  Integer; Count: Integer);
begin
  if Assigned(DoMarkLinesDirty) then
    DoMarkLinesDirty(EditControl, Line, Count, $07);
end;

procedure TCnEditControlWrapper.EditorRefresh(EditControl: TControl;
  DirtyOnly: Boolean);
begin
  if Assigned(EdRefresh) then
    EdRefresh(EditControl, DirtyOnly);
end;

function TCnEditControlWrapper.GetTextAtLine(EditControl: TControl;
  LineNum: Integer): string;
begin
  if Assigned(DoGetTextAtLine) then
    Result := DoGetTextAtLine(EditControl, LineNum);
end;

function TCnEditControlWrapper.IndexPosToCurPos(EditControl: TControl;
  Col, Line: Integer): Integer;
begin
{$IFDEF BDS}
  if Assigned(IndexPosToCurPosProc) then
  begin
    Result := IndexPosToCurPosProc(EditControl, Col, Line);
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('IndexPosToCurPos: %d,%d => %d', [Col, Line, Result]);
  {$ENDIF}
  end
  else
{$ENDIF}
  begin
    Result := Col;
  end;
end;

procedure TCnEditControlWrapper.RepaintEditControls;
var
  I: Integer;
begin
  for I := 0 to FEditControlList.Count - 1 do
  begin
    if IsEditControl(TComponent(FEditControlList[I])) then
    begin
      try
        TControl(FEditControlList[I]).Invalidate;
      except
        ;
      end;
    end;
  end;
end;

function TCnEditControlWrapper.ClickBreakpointAtActualLine(ActualLineNum: Integer;
  EditControl: TControl): Boolean;
var
  Obj: TCnEditorObject;
  I: Integer;
  X, Y: Word;
  Item: TCnBreakPointClickItem;
begin
  Result := False;
  if ActualLineNum <= 0 then
    Exit;

  if EditControl = nil then
    EditControl := CnOtaGetCurrentEditControl;

  if EditControl = nil then
    Exit;

  I := IndexOfEditor(EditControl);
  if I < 0 then
    Exit;

  Obj := Editors[I];
  if Obj = nil then
    Exit;

  if Obj.ViewLineCount = 0 then
    Exit;

  X := 5;
  if (ActualLineNum > Obj.ViewBottomLine - Obj.ViewLineCount) and (ActualLineNum <= Obj.ViewBottomLine) then
  begin
    // 在可见区域
    for I := 0 to Obj.ViewLineCount - 1 do
    begin
      if Obj.ViewLineNumber[I] = ActualLineNum then
      begin
        Y := I * GetCharHeight + (GetCharHeight div 2);

        // EditControl 上做点击
        EditControl.Perform(WM_LBUTTONDOWN, 0, MakeLParam(X, Y));
        EditControl.Perform(WM_LBUTTONUP, 0, MakeLParam(X, Y));

        Result := True;
        Exit;
      end;
    end;
  end
  else // 在不可见区域，需要滚动到可见区域
  begin
    // 滚过去
    Item := TCnBreakPointClickItem.Create;
    Item.BpDeltaLine := ActualLineNum - Obj.ViewLineNumber[0];

    Item.BpEditControl := EditControl;
    Item.BpEditView := Obj.EditView;
    Item.BpPosY := GetCharHeight div 2;

    FBpClickQueue.Push(Item);
    CnWizNotifierServices.StopExecuteOnApplicationIdle(ScrollAndClickEditControl);
    CnWizNotifierServices.ExecuteOnApplicationIdle(ScrollAndClickEditControl);
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
// 通知器列表操作
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
begin
  if IndexOf(List, Notifier) < 0 then
  begin
    New(Rec);
    Rec^.Notifier := TMethod(Notifier);
    List.Add(Rec);
  end;
end;

procedure TCnEditControlWrapper.RemoveNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  Idx: Integer;
begin
  Idx := IndexOf(List, Notifier);
  if Idx >= 0 then
  begin
    Rec := List[Idx];
    Dispose(Rec);
    List.Delete(Idx);
  end;
end;

procedure TCnEditControlWrapper.ClearAndFreeList(var List: TList);
var
  Rec: PCnWizNotifierRecord;
begin
  while List.Count > 0 do
  begin
    Rec := List[0];
    Dispose(Rec);
    List.Delete(0);
  end;
  FreeAndNil(List);
end;

function TCnEditControlWrapper.IndexOf(List: TList; Notifier: TMethod): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
  begin
    if CompareMem(List[I], @Notifier, SizeOf(TMethod)) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 编辑器绘制 Hook 通知
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddAfterPaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  AddNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddBeforePaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  AddNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveAfterPaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  RemoveNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveBeforePaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  RemoveNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoAfterPaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  if not Editor.FLinesChanged then
  begin
    if (LineNum < Editor.FLastTop) or (LineNum - Editor.FLastTop >= Editor.FLines.Count) or
      (Editor.ViewLineNumber[LineNum - Editor.FLastTop] <> LogicLineNum) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('DoAfterPaintLine: Editor.FLinesChanged := True');
    {$ENDIF}
      Editor.FLinesChanged := True;
    end;
  end;

  for I := 0 to FAfterPaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FAfterPaintLineNotifiers[I])^ do
      TCnEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoAfterPaintLine[' + IntToStr(I) + ']', E);
  end;
end;

procedure TCnEditControlWrapper.DoBeforePaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  for I := 0 to FBeforePaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FBeforePaintLineNotifiers[I])^ do
      TCnEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoBeforePaintLine[' + IntToStr(I) + ']', E);
  end;
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnEditControlWrapper.DoAfterElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctElided]);
end;

procedure TCnEditControlWrapper.DoAfterUnElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctUnElided]);
end;

{$ENDIF}

//------------------------------------------------------------------------------
// 编辑器控件通知
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditControlNotifier(
  Notifier: TCnEditorNotifier);
begin
  AddNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditControlNotifier(
  Notifier: TCnEditorNotifier);
begin
  RemoveNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditControlNotify(EditControl: TControl;
  Operation: TOperation);
var
  I: Integer;
  EditWindow: TCustomForm;
begin
  EditWindow := TCustomForm(EditControl.Owner);
  for I := 0 to FEditControlNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FEditControlNotifiers[I])^ do
      TCnEditorNotifier(Notifier)(EditControl, EditWindow, Operation);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoEditControlNotify[' + IntToStr(I) + ']', E);
  end;
end;

//------------------------------------------------------------------------------
// 编辑器控件变更通知
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditorChangeNotifier(
  Notifier: TCnEditorChangeNotifier);
begin
  AddNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorChangeNotifier(
  Notifier: TCnEditorChangeNotifier);
begin
  RemoveNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditorChange(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditControlWrapper.DoEditorChange: ' + EditorChangeTypesToStr(ChangeType));
{$ENDIF}

  if Editor = nil then // 某些古怪情况下 Editor 为 nil？
    Exit;

  if ChangeType * [ctView, ctWindow{$IFDEF BDS}, ctLineDigit{$ENDIF}] <> [] then
  begin
    Editor.FGutterChanged := True;  // 行位数发生变化时，会触发 Gutter 宽度变化
  end;

  for I := 0 to FEditorChangeNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditorChangeNotifiers[I])^ do
        TCnEditorChangeNotifier(Notifier)(Editor, ChangeType);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoEditorChange[' + IntToStr(I) + ']', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
// 消息通知
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  AddNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  AddNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  RemoveNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  RemoveNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.OnCallWndProcRet(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
var
  I, Idx: Integer;
  Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes;
begin
  if ((Msg.Msg = WM_VSCROLL) or (Msg.Msg = WM_HSCROLL))
    and IsEditControl(Control) then
  begin
    if Msg.Msg = WM_VSCROLL then
    begin
      ChangeType := [ctVScroll];
      Editor := nil;
      Idx := FEditControlWrapper.IndexOfEditor(Control);
      if Idx >= 0 then
        Editor := FEditControlWrapper.GetEditors(Idx);

      DoVScroll(Editor);
    end
    else
      ChangeType := [ctHScroll];

    for I := 0 to EditorCount - 1 do
    begin
      DoEditorChange(Editors[I], ChangeType + CheckEditorChanges(Editors[I]));
    end;
  end
{$IFDEF IDE_SUPPORT_HDPI}
  else if (Msg.Msg = WM_DPICHANGED) and (Control = Application.MainForm) then
  begin
    ChangeType := [ctOptionChanged];
    // 将系统 DPI 改变的通知转化为字体大小选项变化，并且为了避免多次调用，只判断主窗体
    FOptionChanged := True;
    for I := 0 to EditorCount - 1 do
      DoEditorChange(Editor, ChangeType + CheckEditorChanges(Editors[I]));
  end
{$ENDIF}
  else if (Msg.Msg = WM_NCPAINT) and IsEditControl(Control) then
  begin
    Editor := nil;
    Idx := FEditControlWrapper.IndexOfEditor(Control);
    if Idx >= 0 then
      Editor := FEditControlWrapper.GetEditors(Idx);

    DoNcPaint(Editor);
  end;
end;

procedure TCnEditControlWrapper.OnGetMsgProc(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
var
  Idx: Integer;
  Editor: TCnEditorObject;
  P: TPoint;
begin
  if FMouseNotifyAvailable and IsEditControl(Control) then
  begin
    Editor := nil;
    Idx := FEditControlWrapper.IndexOfEditor(Control);
    if Idx >= 0 then
      Editor := FEditControlWrapper.GetEditors(Idx);

    if Editor <> nil then
    begin
      P.x := Msg.LParamLo;
      P.y := Msg.LParamHi;
      case Msg.Msg of
      WM_MOUSEMOVE:  // 普通鼠标消息，座标为自身相对座标，无需转换
        begin
          DoMouseMove(Editor, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_LBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_LBUTTONUP:
        begin
          DoMouseUp(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_RBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_RBUTTONUP:
        begin
          DoMouseUp(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_MBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_MBUTTONUP:
        begin
          DoMouseUp(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_NCMOUSEMOVE: // NC 系列，座标为屏幕座标，需要转换
        begin
          P := Control.ScreenToClient(P);
          DoMouseMove(Editor, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCLBUTTONDOWN:
        begin
          P := Control.ScreenToClient(P);
          DoMouseDown(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCLBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCRBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCRBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMBUTTONDOWN:
        begin
          P := Control.ScreenToClient(P);
          DoMouseDown(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMOUSELEAVE:
        begin
          DoMouseLeave(Editor, True);
        end;
      WM_MOUSELEAVE:
        begin
          DoMouseLeave(Editor, False);
        end;
      else
        ; // DBLCLICKs do nothing
      end;
    end;
  end;
end;

procedure TCnEditControlWrapper.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  I: Integer;
  Key: Word;
  ScanCode: Word;
  Shift: TShiftState;
  List: TList;
begin
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP)) and
    IsEditControl(Screen.ActiveControl) then
  begin
    Key := Msg.wParam;
    ScanCode := (Msg.lParam and $00FF0000) shr 16;
    Shift := KeyDataToShiftState(Msg.lParam);

    // 处理输入法送回的按键
    if Key = VK_PROCESSKEY then
    begin
      Key := MapVirtualKey(ScanCode, 1);
    end;

    if Msg.message = WM_KEYDOWN then
      List := FKeyDownNotifiers
    else
      List := FKeyUpNotifiers;

    for I := 0 to List.Count - 1 do
    begin
      try
        with PCnWizNotifierRecord(List[I])^ do
          TCnKeyMessageNotifier(Notifier)(Key, ScanCode, Shift, Handled);
        if Handled then Break;
      except
        on E: Exception do
          DoHandleException('TCnEditControlWrapper.KeyMessage[' + IntToStr(I) + ']', E);
      end;
    end;
  end;
end;

procedure TCnEditControlWrapper.ScrollAndClickEditControl(Sender: TObject);
var
  Item: TCnBreakPointClickItem;
begin
  while FBpClickQueue.Count > 0 do
  begin
    Item := TCnBreakPointClickItem(FBpClickQueue.Pop);
    if (Item = nil) or (Item.BpEditControl = nil) or (Item.BpEditView = nil)
       or (Item.BpDeltaLine = 0) then
       Continue;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ScrollAndClickEditControl Scroll %d. X %d Y: %d.', [Item.BpDeltaLine,
      CN_BP_CLICK_POS_X, Item.BpPosY]);
{$ENDIF}

    Item.BpEditView.Scroll(Item.BpDeltaLine, 0);

    // EditControl 上做点击
    Item.BpEditControl.Perform(WM_LBUTTONDOWN, 0, MakeLParam(CN_BP_CLICK_POS_X, Item.BpPosY));
    Item.BpEditControl.Perform(WM_LBUTTONUP, 0, MakeLParam(CN_BP_CLICK_POS_X, Item.BpPosY));

    // 滚回去
    Item.BpEditView.Scroll(-Item.BpDeltaLine, 0);
    Item.Free;
  end;
end;

procedure TCnEditControlWrapper.CheckAndSetEditControlMouseHookFlag;
begin
  if FMouseNotifyAvailable then
    Exit;

  FMouseNotifyAvailable := True;
end;

procedure TCnEditControlWrapper.AddEditorMouseDownNotifier(
  Notifier: TCnEditorMouseDownNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  AddNotifier(FMouseDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorMouseMoveNotifier(
  Notifier: TCnEditorMouseMoveNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  AddNotifier(FMouseMoveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorMouseUpNotifier(
  Notifier: TCnEditorMouseUpNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  AddNotifier(FMouseUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseDownNotifier(
  Notifier: TCnEditorMouseDownNotifier);
begin
  RemoveNotifier(FMouseDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseMoveNotifier(
  Notifier: TCnEditorMouseMoveNotifier);
begin
  RemoveNotifier(FMouseMoveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseUpNotifier(
  Notifier: TCnEditorMouseUpNotifier);
begin
  RemoveNotifier(FMouseUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoMouseDown(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseDownNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseDownNotifiers[I])^ do
        TCnEditorMouseDownNotifier(Notifier)(Editor, Button, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseDown[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseMove(Editor: TCnEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseMoveNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseMoveNotifiers[I])^ do
        TCnEditorMouseMoveNotifier(Notifier)(Editor, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseMove[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseUp(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseUpNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseUpNotifiers[I])^ do
        TCnEditorMouseUpNotifier(Notifier)(Editor, Button, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseUp[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseLeave(Editor: TCnEditorObject; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseLeaveNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseLeaveNotifiers[I])^ do
        TCnEditorMouseLeaveNotifier(Notifier)(Editor, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseLeave[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.AddEditorMouseLeaveNotifier(
  Notifier: TCnEditorMouseLeaveNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  AddNotifier(FMouseLeaveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseLeaveNotifier(
  Notifier: TCnEditorMouseLeaveNotifier);
begin
  RemoveNotifier(FMouseLeaveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorNcPaintNotifier(
  Notifier: TCnEditorNcPaintNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  AddNotifier(FNcPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorNcPaintNotifier(
  Notifier: TCnEditorNcPaintNotifier);
begin
  RemoveNotifier(FNcPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoNcPaint(Editor: TCnEditorObject);
var
  I: Integer;
begin
  for I := 0 to FNcPaintNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FNcPaintNotifiers[I])^ do
        TCnEditorNcPaintNotifier(Notifier)(Editor);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoNcPaint[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.AddEditorVScrollNotifier(
  Notifier: TCnEditorVScrollNotifier);
begin
  AddNotifier(FVScrollNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorVScrollNotifier(
  Notifier: TCnEditorVScrollNotifier);
begin
  RemoveNotifier(FVScrollNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoVScroll(Editor: TCnEditorObject);
var
  I: Integer;
begin
  for I := 0 to FVScrollNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FVScrollNotifiers[I])^ do
        TCnEditorVScrollNotifier(Notifier)(Editor);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoVScroll[' + IntToStr(I) + ']', E);
    end;
  end;
end;

function TCnEditControlWrapper.GetLineFromPoint(Point: TPoint;
  EditControl: TControl; EditView: IOTAEditView): Integer;
var
  EditorObj: TCnEditorObject;
begin
  Result := -1;
  if EditControl = nil then
    Exit;

  if EditView = nil then
    EditView := GetEditView(EditControl);
  if EditView = nil then
    Exit;

  Result := Point.y div GetCharHeight;
  EditorObj := GetEditorObject(EditControl);
  if (EditorObj <> nil) and (Result >= 0) and (Result < EditorObj.ViewLineCount) then
    Result := EditorObj.ViewLineNumber[Result]
  else if Result >= 0 then
    Result := EditView.TopRow + Result;
end;

function TCnEditControlWrapper.GetTabWidth: Integer;
var
  Options: IOTAEnvironmentOptions;

{$IFDEF BDS}

  function GetAvrTabWidth(TabWidthStr: string): Integer;
  var
    Sl: TStringList;
    Prev: Integer;
    I: Integer;
  begin
    Sl := TStringList.Create();
    try
      Sl.Delimiter := ' ';
      // The tab-string might separeted by ';', too
      if Pos(';', TabWidthStr) > 0 then
      begin
        // if so, use it
        Sl.Delimiter := ';';
      end;
      Sl.DelimitedText := TabWidthStr;
      Result := 0;
      Prev := 0;
      for I := 0 to Sl.Count - 1 do
      begin
        Inc(Result, StrToInt(Sl[I]) - Prev);
        Prev := StrToInt(Sl[I]);
      end;
      Result := Result div Sl.Count;
    finally
      FreeAndNil(Sl);
    end;
  end;

{$ENDIF}

begin
  Result := 2;
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    try
{$IFDEF BDS}
      Result := GetAvrTabWidth(Options.GetOptionValue('TabStops'));
{$ELSE}
      Result := StrToIntDef(VarToStr(Options.GetOptionValue('TabStops')), 2);
{$ENDIF}
    except
      ;
    end;
  end;
end;

function TCnEditControlWrapper.GetBlockIndent: Integer;
var
  Options: IOTAEnvironmentOptions;
begin
  Result := 2;
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    try
      Result := StrToIntDef(VarToStr(Options.GetOptionValue('BlockIndent')), 2);
    except
      ;
    end;
  end;
end;

function TCnEditControlWrapper.GetUseTabKey: Boolean;
var
  Options: IOTAEnvironmentOptions;
  S: string;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    S := VarToStr(Options.GetOptionValue('UseTabCharacter'));
    Result := (S = 'True') or (S = '-1'); // D567 is -1
  end
  else
    Result := False;
end;

function TCnEditControlWrapper.GetFonts(Index: Integer): TFont;
begin
  Result := FFontArray[Index];
end;

function TCnEditControlWrapper.GetBackgroundColor: TColor;
begin
  Result := FBackgroundColor;
end;

procedure TCnEditControlWrapper.LoadFontFromRegistry;
const
  ArrRegItems: array [0..9] of string = ('', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol');
var
  I: Integer;
  AFont: TFont;
  BColor: TColor;
begin
  // 从注册表中载入 IDE 的字体供外界使用
  AFont := TFont.Create;
  try
    AFont.Name := 'Courier New';  {Do NOT Localize}
    AFont.Size := 10;

    BColor := clWhite;
    if GetIDERegistryFont(ArrRegItems[0], AFont, BColor) then
      ResetFontsFromBasic(AFont);

    for I := Low(FFontArray) + 1 to High(FFontArray) do
    begin
      try
        BColor := clWhite;
        if GetIDERegistryFont(ArrRegItems[I], AFont, BColor) then
        begin
          FFontArray[I].Assign(AFont);
          if I = 7 then // WhiteSpace 的背景色
          begin
            FBackgroundColor := BColor;
{$IFDEF DEBUG} // 没有 EditControl 实例时可能会因为拿不到信息被 Idle 频繁调用，不打
//          CnDebugger.LogColor(FBackgroundColor, 'LoadFontFromRegistry Get Background');
{$ENDIF}
          end;
        end;
      except
        Continue;
      end;
    end;
  finally
    AFont.Free;
  end;
end;

procedure TCnEditControlWrapper.ResetFontsFromBasic(ABasicFont: TFont);
var
  TempFont: TFont;
begin
  TempFont := TFont.Create;
  try
    TempFont.Assign(ABasicFont);
    FontBasic := TempFont;

    TempFont.Color := clRed;
    FontAssembler := TempFont;

    TempFont.Color := clNavy;
    TempFont.Style := [fsItalic];
    FontComment := TempFont;

    TempFont.Style := [];
    TempFont.Color := clBlack;
    FontIdentifier := TempFont;

    TempFont.Color := clGreen;
    FontDirective := TempFont;

    TempFont.Color := clBlack;
    TempFont.Style := [fsBold];
    FontKeyWord := TempFont;

    TempFont.Style := [];
    FontNumber := TempFont;

    FontSpace := TempFont;

    TempFont.Color := clBlue;
    FontString := TempFont;

    TempFont.Color := clBlack;
    FontSymbol := TempFont;
  finally
    TempFont.Free;
  end;
end;

procedure TCnEditControlWrapper.SetFonts(const Index: Integer;
  const Value: TFont);
begin
  if Value <> nil then
    FFontArray[Index].Assign(Value);
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnEditControlWrapper.ElideLine(EditControl: TControl;
  LineNum: Integer);
begin
  if Assigned(EditControlElide) then
    EditControlElide(EditControl, LineNum);
end;

procedure TCnEditControlWrapper.UnElideLine(EditControl: TControl;
  LineNum: Integer);
begin
  if Assigned(EditControlUnElide) then
    EditControlUnElide(EditControl, LineNum);
end;

{$ENDIF}

initialization
  InitializeCriticalSection(PaintLineLock);

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnEditControlWrapper finalization.');
{$ENDIF}

  if FEditControlWrapper <> nil then
    FreeAndNil(FEditControlWrapper);
  DeleteCriticalSection(PaintLineLock);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnEditControlWrapper finalization.');
{$ENDIF}

end.

