{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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
* 单元名称：IDE 相关公共单元
* 单元作者：周劲羽 (zjy@cnpack.org)
*           LiuXiao（刘啸）liuxiao@cnpack.org
* 备    注：该单元部分内容移植自 GExperts 1.12 Src
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2016.04.04 by liuxiao
*               增加 2010 以上版本的新风格控件板的支持
*           2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2005.05.06 V1.3
*               hubdog 增加 获取版本信息的函数
*           2004.03.19 V1.2
*               LiuXiao 增加 CnPaletteWrapper，封装控件面板的各个属性
*           2003.03.06 V1.1
*               GetLibraryPath 扩展了路径搜索范围，支持工程搜索路径
*           2002.12.05 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, Forms, Tabs,
  Menus, Buttons, ComCtrls, StdCtrls, ExtCtrls, TypInfo, ToolsAPI, 
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner,
  {$ELSE}
  DsgnIntf, LibIntf,
  {$ENDIF}
  CnPasCodeParser, CnWidePasParser,
  CnWizUtils, CnWizEditFiler, CnCommon, CnWizOptions, CnWizCompilerConst;

//==============================================================================
// IDE 中的常量定义
//==============================================================================

const
  // IDE Action 名称
  SEditSelectAllCommand = 'EditSelectAllCommand';

  // Editor 窗口右键菜单名称
  SMenuClosePageName = 'ecClosePage';
  SMenuClosePageIIName = 'ecClosePageII';
  SMenuEditPasteItemName = 'EditPasteItem';
  SMenuOpenFileAtCursorName = 'ecOpenFileAtCursor';

  // Editor 窗口相关类名
  EditorFormClassName = 'TEditWindow';
  EditControlName = 'Editor';
  EditControlClassName = 'TEditControl';
  DesignControlClassName = 'TEditorFormDesigner';
  WelcomePageClassName = 'TWelcomePageFrame';
  DisassemblyViewClassName = 'TDisassemblyView';
{$IFDEF BDS}
  {$IFDEF BDS4_UP} // BDS 2006 RAD Studio 2007 的标签页类名
  XTabControlClassName = 'TIDEGradientTabSet';   // TWinControl 子类
  {$ELSE} // BDS 2005 的标签页类名
  XTabControlClassName = 'TCodeEditorTabControl'; // TTabSet 子类
  {$ENDIF}
{$ELSE} // Delphi BCB 的标签页类名
  XTabControlClassName = 'TXTabControl';
{$ENDIF BDS}
  XTabControlName = 'TabControl';

  TabControlPanelName = 'TabControlPanel';
  CodePanelName = 'CodePanel';
  TabPanelName = 'TabPanel';

  // 对象查看器
  PropertyInspectorClassName = 'TPropertyInspector';
  PropertyInspectorName = 'PropertyInspector';

  // 编辑器设置对话框
{$IFDEF BDS}
  SEditorOptionDlgClassName = 'TDefaultEnvironmentDialog';
  SEditorOptionDlgName = 'DefaultEnvironmentDialog';
{$ELSE} {$IFDEF BCB}
  SEditorOptionDlgClassName = 'TCppEditorPropertyDialog';
  SEditorOptionDlgName = 'CppEditorPropertyDialog';
{$ELSE}
  SEditorOptionDlgClassName = 'TPasEditorPropertyDialog';
  SEditorOptionDlgName = 'PasEditorPropertyDialog';
{$ENDIF} {$ENDIF}

  // 控件板相关类名和属性名
  SCnPaletteTabControlClassName = 'TComponentPaletteTabControl';
  SCnPalettePropSelectedIndex = 'SelectedIndex';
  SCnPalettePropSelectedToolName = 'SelectedToolName';
  SCnPalettePropSelector = 'Selector';
  SCnPalettePropPalToolCount = 'PalToolCount';

  // D2010 或以上版本的新控件板，一个 TComponentToolbarFrame 里包着 TGradientTabSet
  SCnNewPaletteFrameClassName = 'TComponentToolbarFrame';
  SCnNewPaletteFrameName = 'ComponentToolbarFrame';
  SCnNewPaletteTabClassName = 'TGradientTabSet';
  SCnNewPaletteTabName = 'TabControl';
  SCnNewPaletteTabItemsPropName = 'Items';
  SCnNewPaletteTabIndexPropName = 'TabIndex';
  SCnNewPalettePanelContainerName = 'PanelButtons';
  SCnNewPaletteButtonClassName = 'TPalItemSpeedButton';
  
  // 消息窗口
  SCnMessageViewFormClassName = 'TMessageViewForm';
  SCnMessageViewTabSetName = 'MessageGroups';
  SCnMvEditSourceItemName = 'mvEditSourceItem';

{$IFDEF BDS}
  SCnTreeMessageViewClassName = 'TBetterHintWindowVirtualDrawTree';
{$ELSE}
  SCnTreeMessageViewClassName = 'TTreeMessageView';
{$ENDIF}

  // 引用单元功能的 Action 名称
{$IFDEF DELPHI}
  SCnUseUnitActionName = 'FileUseUnitCommand';
{$ELSE}
  SCnUseUnitActionName = 'FileIncludeUnitHdrCommand';
{$ENDIF}

  SCnColor16Table: array[0..15] of TColor =
  ( clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clLtGray, clDkGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite);

type
{$IFDEF BDS}
  {$IFDEF BDS2006_UP}
  TXTabControl = TWinControl;
  {$ELSE}
  TXTabControl = TTabSet;
  {$ENDIF}
{$ELSE}
  TXTabControl = TTabControl;
{$ENDIF BDS}

{$IFDEF BDS}
  TXTreeView = TCustomControl;
{$ELSE}
  TXTreeView = TTreeView;
{$ENDIF BDS}

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

function IdeGetSourceByFileName(const FileName: string): AnsiString;
{* 根据文件名取得内容。如果文件在 IDE 中打开，返回编辑器中的内容，否则返回文件内容。}

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
{* 根据文件名写入内容。如果文件在 IDE 中打开，写入内容到编辑器中，否则如果
   OpenInIde 为真打开文件写入到编辑器，OpenInIde 为假直接写入文件。}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* 判断标识符是否在光标下，频繁调用，因此此处 View 用指针来避免引用计数从而优化速度，各版本均可使用 }

function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
{* 判断标识符是否在光标下，同上，但使用 WideToken，可供 Unicode/Utf8 环境下调用}

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

function IdeGetIsEmbeddedDesigner: Boolean;
{* 取得当前是否是嵌入式设计窗体模式}

var
  IdeIsEmbeddedDesigner: Boolean = False;
  {* 标记当前是否是嵌入式设计窗体模式，initiliazation 时被初始化，请勿手工修改其值。
     使用此全局变量可以避免频繁调用 IdeGetIsEmbeddedDesigner 函数}

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
{* 取得 BDS (Delphi8以后版本) 的用户数据目录 }
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

function GetIDERegistryFont(const RegItem: string; AFont: TFont): Boolean;
{* 从某项注册表中载入某项字体并赋值给 AFont
   RegItem 可以是 '', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol'
    等注册表里头已经定义了的键值}

type
  TEnumEditControlProc = procedure (EditWindow: TCustomForm; EditControl:
    TControl; Context: Pointer) of object;

function IsEditControl(AControl: TComponent): Boolean;
{* 判断指定控件是否代码编辑器控件 }

function IsXTabControl(AControl: TComponent): Boolean;
{* 判断指定控件是否编辑器窗口的 TabControl 控件 }

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
{* 返回编辑器窗口的编辑器控件 }

function GetCurrentEditControl: TControl;
{* 返回当前的代码编辑器控件 }

function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
{* 返回编辑器窗口的 TabControl 控件 }

function GetEditorTabTabs(ATab: TXTabControl): TStrings;
{* 返回编辑器 TabControl 控件的 Tabs 属性}

function GetEditorTabTabIndex(ATab: TXTabControl): Integer;
{* 返回编辑器 TabControl 控件的 Index 属性}

function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
{* 从编辑器控件获得其所属的编辑器窗口的状态栏}

function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean = True): Integer;
{* 枚举 IDE 中的代码编辑器窗口和 EditControl 控件，调用回调函数，返回总数 }

type
  TCnSrcEditorPage = (epCode, epDesign, epCPU, epWelcome, epOthers);

function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
{* 取当前编辑窗口顶层页面类型，传入编辑器父控件 }

procedure BeginBatchOpenClose;
{* 开始批量打开或关闭文件 }

procedure EndBatchOpenClose;
{* 结束批量打开或关闭文件 }

function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
{* 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNode 强行转换成公用的 TreeNode}

function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
{* 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNodes 强行转换成公用的 TreeNodes}


//==============================================================================
// 扩展控件
//==============================================================================

type
  TCnToolBarComboBox = class(TComboBox)
  private
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  end;

//==============================================================================
// 组件面板封装类
//==============================================================================

type

{ TCnPaletteWrapper }

  TCnPaletteWrapper = class(TObject)
  {* 封装了控件板各个属性的类，大部分只支持低版本控件板
     高版本控件板由上下两个 Panel 组成，上面 Panel 容纳 TGradientTab 与 ToolbarSearch
     下面 Panel 容纳滚动按钮以及多个 TPalItemSpeedButton 的控件图标按钮
   }
  private
    FPalTab: TWinControl;  // 低版本指大的 TabControl 容器，高版本指上半部分的 TGradientTabSet
    FPalette: TWinControl; // 低版本指大的 TabControl 内的组件容器，高版本指下半部分的组件容器
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FPageScroller: TWinControl;
{$ENDIF}
    FUpdateCount: Integer;
{$IFDEF COMPILER6_UP}
  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FOldRootClass: TClass;
  {$ENDIF}
{$ENDIF}
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    function ParseNameFromHint(const Hint: string): string;
{$ENDIF}
    function GetSelectedIndex: Integer;
    function GetSelectedToolName: string;
    function GetSelector: TSpeedButton;
    function GetPalToolCount: Integer;
    function GetActiveTab: string;
    function GetTabCount: Integer;
    function GetIsMultiLine: Boolean;
    procedure SetSelectedIndex(const Value: Integer);
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetTabs(Index: Integer): string;
{$IFDEF SUPPORTS_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    procedure GetComponentImageFromNewPalette(Bmp: TBitmap; const AComponentClassName: string);
  {$ELSE}
    procedure GetComponentImageFromOldPalette(Bmp: TBitmap; const AComponentClassName: string);
  {$ENDIF}
{$ENDIF}
  public
    constructor Create;

    procedure BeginUpdate;
    {* 开始更新，禁止刷新页面 }
    procedure EndUpdate;
    {* 停止更新，恢复刷新页面 }
    function SelectComponent(const AComponent: string; const ATab: string): Boolean;
    {* 根据类名选中控件板中的某控件，返回是否成功 }
    function FindTab(const ATab: string): Integer;
    {* 查找某页面的索引 }
    procedure GetComponentImage(Bmp: TBitmap; const AComponentClassName: string);
    {* 将控件板上指定的组件名的图标绘制到 Bmp 中，Bmp 推荐尺寸为 26 * 26}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* 按下的控件在本页的序号，0 开头，支持高版本的新控件板 }
    property SelectedToolName: string read GetSelectedToolName;
    {* 按下的控件的类名，未按下则为空，支持高版本的新控件板 }
    property Selector: TSpeedButton read GetSelector;
    {* 获得用来切换到鼠标光标的 SpeedButton，低版本在组件区内，高版本在 Tab 头中 }
    property PalToolCount: Integer read GetPalToolCount;
    {* 当前页控件个数，支持高版本的新控件板 }
    property ActiveTab: string read GetActiveTab;
    {* 当前页标题，支持高版本的新控件板 }
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* 当前页索引，支持高版本的新控件板 }
    property Tabs[Index: Integer]: string read GetTabs;
    {* 根据索引得到页名称，支持高版本的新控件板 }
    property TabCount: Integer read GetTabCount;
    {* 控件板总页数，支持高版本的新控件板 }
    property IsMultiLine: Boolean read GetIsMultiLine;
    {* 控件板是否多行，支持高版本的新控件板但高版本新控件板不支持多行 }
    property Visible: Boolean read GetVisible write SetVisible;
    {* 控件板是否可见，支持高版本的新控件板 }
    property Enabled: Boolean read GetEnabled write SetEnabled;
    {* 控件板是否使能，支持高版本的新控件板 }
  end;

{TCnMessageViewWrapper}

  TCnMessageViewWrapper = class(TObject)
  {* 封装了消息显示窗口的各个属性的类 }
  private
    FMessageViewForm: TCustomForm;
    FTreeView: TXTreeView;
    FTabSet: TTabSet;
    FEditMenuItem: TMenuItem;
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

function CnPaletteWrapper: TCnPaletteWrapper;

function CnMessageViewWrapper: TCnMessageViewWrapper;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Registry;

{$IFDEF BDS4_UP}
const
  SBeginBatchOpenCloseName = '@Editorform@BeginBatchOpenClose$qqrv';
  SEndBatchOpenCloseName = '@Editorform@EndBatchOpenClose$qqrv';

var
  BeginBatchOpenCloseProc: TProcedure = nil;
  EndBatchOpenCloseProc: TProcedure = nil;
{$ENDIF}

type
  TCustomControlHack = class(TCustomControl);

//==============================================================================
// IDE功能函数
//==============================================================================

type
  TGetCodeMode = (smLine, smSelText, smSource);

function DoGetEditorSrcInfo(Mode: TGetCodeMode; View: IOTAEditView;
  var StartPos, EndPos, NewRow, NewCol, BlockStartLine, BlockEndLine: Integer): Boolean;
var
  Block: IOTAEditBlock;
  Row, Col: Integer;
  Stream: TMemoryStream;
begin
  Result := False;
  if View <> nil then
  begin
    Block := View.Block;
    StartPos := 0;
    EndPos := 0;
    BlockStartLine := 0;
    BlockEndLine := 0;
    NewRow := 0;
    NewCol := 0;
    if Mode = smLine then
    begin
      if (Block <> nil) and Block.IsValid then
      begin             // 选择文本扩大到整行
        BlockStartLine := Block.StartingRow;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockStartLine), View);
        BlockEndLine := Block.EndingRow;
        // 光标不在行首时，处理到下一行行首
        if Block.EndingColumn > 1 then
        begin
          if BlockEndLine < View.Buffer.GetLinesInBuffer then
          begin
            Inc(BlockEndLine);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, BlockEndLine), View);
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
      end
      else
      begin    // 未选择表示转换整行。
        if CnOtaGetCurSourcePos(Col, Row) then
        begin
          StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row), View);
          if Row < View.Buffer.GetLinesInBuffer then
          begin
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row + 1), View);
            NewRow := Row + 1;
            NewCol := Col;
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, Row), View);
        end
        else
        begin
          Exit;
        end;
      end;
    end
    else if Mode = smSelText then
    begin
      if (Block <> nil) and (Block.IsValid) then
      begin                           // 仅处理选择的文本
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(Block.StartingColumn,
          Block.StartingRow), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(Block.EndingColumn,
          Block.EndingRow), View);
      end;
    end
    else
    begin
      StartPos := 0;
      Stream := TMemoryStream.Create;
      try
        CnOtaSaveCurrentEditorToStream(Stream, False);
        EndPos := Stream.Size; // 用笨办法得到编辑的长度
      finally
        Stream.Free;
      end;
    end;
    
    Result := True;
  end;
end;

function DoGetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: AnsiString;
  Res: string;
  Buf: PAnsiChar;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos, Len, ReadStart, ASize: Integer;
  Reader: IOTAEditReader;
  NewRow, NewCol: Integer;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;
      
    Len := EndPos - StartPos;
    Assert(Len >= 0);
    SetLength(Text, Len);
    Buf := Pointer(Text);
    ReadStart := StartPos;

    Reader := View.Buffer.CreateReader;
    try
      while Len > SCnOtaBatchSize do // 逐次读取
      begin
        ASize := Reader.GetText(ReadStart, Buf, SCnOtaBatchSize);
        Inc(Buf, ASize);
        Inc(ReadStart, ASize);
        Dec(Len, ASize);
      end;
      if Len > 0 then // 读最后剩余的
        Reader.GetText(ReadStart, Buf, Len);
    finally
      Reader := nil;
    end;                  

    {$IFDEF UNICODE}
    Res := ConvertEditorTextToTextW(Text); // Unicode 下不经过 Ansi 转换以避免丢字符
    {$ELSE}
    Res := ConvertEditorTextToText(Text);
    {$ENDIF}

    Lines.Text := Res;
    Result := Text <> '';
  end;
end;

function DoSetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: AnsiString;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos: Integer;
  Writer: IOTAEditWriter;
  NewRow, NewCol: Integer;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;

  {$IFDEF UNICODE_STRING}
    Text := AnsiString(StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]));
  {$ELSE}
    Text := StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]);
  {$ENDIF}
    Writer := View.Buffer.CreateUndoableWriter;
    try
      Writer.CopyTo(StartPos);
      Writer.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
      Writer.DeleteTo(EndPos);
    finally
      Writer := nil;
    end;                

    if (NewRow > 0) and (NewCol > 0) then
    begin
      View.CursorPos := OTAEditPos(NewCol, NewRow);
    end
    else if (BlockStartLine > 0) and (BlockEndLine > 0) then
    begin
      CnOtaSelectBlock(View.Buffer, OTACharPos(0, BlockStartLine),
        OTACharPos(0, BlockEndLine));
    end;

    Result := True;
  end;
end;

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smLine, Lines);
end;

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSelText, Lines);
end;

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSource, Lines);
end;

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smLine, Lines);
end;

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSelText, Lines);
end;

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSource, Lines);
end;

function IdeInsertTextIntoEditor(const Text: string): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaInsertTextIntoEditor(Text);
    Result := True;
  end
  else
    Result := False;  
end;
  
function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
var
  EditPos: TOTAEditPos;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    EditPos := CnOtaGetEditPos(CnOtaGetTopMostEditView);
    Col := EditPos.Col;
    Line := EditPos.Line;
    Result := True;
  end
  else
    Result := False;
end;

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaGotoEditPos(OTAEditPos(Col, Line), CnOtaGetTopMostEditView, Middle);
    Result := True;
  end
  else
    Result := False;
end;

function IdeGetBlockIndent: Integer;
begin
  Result := CnOtaGetBlockIndent;
end;  

function IdeGetSourceByFileName(const FileName: string): AnsiString;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Strm, True);
    Result := PAnsiChar(Strm.Memory);
  finally
    Strm.Free;
  end;
end;

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
var
  Strm: TMemoryStream;
begin
  Result := False;
  if OpenInIde and not CnOtaOpenFile(FileName) then
    Exit;
    
  if CnOtaIsFileOpen(FileName) then
  begin
    Strm := TMemoryStream.Create;
    try
      Source.SaveToStream(Strm);
      Strm.Position := 0;
      with TCnEditFiler.Create(FileName) do
      try
        ReadFromStream(Strm);
      finally
        Free;
      end;
    finally
      Strm.Free;
    end;
  end
  else
    Source.SaveToFile(FileName);
  Result := True;
end;  

// 判断标识符是否在光标下，各版本均可使用
function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
var
{$IFDEF BDS}
  Text: AnsiString;
{$ENDIF}
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // 行号不等时直接退出
  begin
    Result := False;
    Exit;
  end;

  // 行相等才需要读出行内容进行比较，其中 Col 是直观的 Ansi 概念，双字节字符占 2 列
{$IFDEF BDS}
  Text := AnsiString(GetStrProp(AControl, 'LineText')); // D2009 以上 Unicode 也得转换成 Ansi
  if Text <> '' then
  begin
    // TODO: 用 TextWidth 获得光标位置精确对应的源码字符位置，但实现较难。
    // 当存在占据单字符位置的双字节字符时，以下算法会有偏差。

    {$IFNDEF UNICODE}
    // D2005~2007 获得的是 Utf8 字符串，需要转换为 Ansi 才能进行直观列比较
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    {$ENDIF}
  end;
{$ENDIF}
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(Token.Token));
end;

{* 判断标识符是否在光标下，使用 WideToken，可供 Unicode/Utf8 环境下调用}
function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
var
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // 行号不等时直接退出
  begin
    Result := False;
    Exit;
  end;

  // 行相等才需要比较列，并且由于 CursorPos 是 ANSI 的光标位置，所以得把 Utf16 转成 Ansi 来比较
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(AnsiString(Token.Token)));
end;

//==============================================================================
// IDE 窗体编辑器功能函数
//==============================================================================

// 取得窗体编辑器的设计器，FormEditor 为 nil 表示取当前窗体
function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
  Result := CnOtaGetFormDesigner(FormEditor);
end;  

// 取得当前设计的窗体
function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
begin
  Result := nil;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;
    
  {$IFDEF COMPILER6_UP}
    if Designer.Root is TCustomForm then
      Result := TCustomForm(Designer.Root);
  {$ELSE}
    Result := Designer.Form;
  {$ENDIF}
  except
    ;
  end;
end;

// 取得当前设计窗体上已选择的组件
function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
var
  i: Integer;
  AObj: TPersistent;
  AList: IDesignerSelections;
begin
  Result := False;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;

    if Selections <> nil then
    begin
      Selections.Clear;
      AList := CreateSelectionList;
      Designer.GetSelections(AList);
      for i := 0 to AList.Count - 1 do
      begin
      {$IFDEF COMPILER6_UP}
        AObj := TPersistent(AList[i]);
      {$ELSE}
        AObj := TryExtractPersistent(AList[i]);
      {$ENDIF}
        if AObj <> nil then // perhaps is nil when disabling packages in the IDE
          Selections.Add(AObj);
      end;

      if ExcludeForm and (Selections.Count = 1) and (Selections[0] =
        IdeGetDesignedForm(Designer)) then
        Selections.Clear;
    end;
    Result := True;
  except
    ;
  end;
end;

// 取得当前是否是嵌入式设计窗体模式
function IdeGetIsEmbeddedDesigner: Boolean;
{$IFDEF BDS}
var
  S: string;
{$ENDIF}
begin
{$IFDEF BDS}
  S := CnOtaGetEnvironmentOptions.Values['EmbeddedDesigner'];
  Result := S = 'True';
{$ELSE}
  Result := False;
{$ENDIF}
end;

//==============================================================================
// 修改自 GExperts Src 1.12 的 IDE 相关函数
//==============================================================================

// 返回 IDE 主窗体 (TAppBuilder)
function GetIdeMainForm: TCustomForm;
begin
  Assert(Assigned(Application));
  Result := Application.FindComponent('AppBuilder') as TCustomForm;
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find AppBuilder!');
{$ENDIF}
end;

// 取 IDE 版本
function GetIdeEdition: string;
begin
  Result := '';

  with TRegistry.Create do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly(WizOptions.CompilerRegPath) then
    begin
      Result := ReadString('Version');
      CloseKey;
    end;
  finally
    Free;
  end;
end;

// 返回组件面板对象，可能为空
function GetComponentPaletteTabControl: TTabControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent('TabControl') as TTabControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find ComponentPalette TabControl!');
{$ENDIF}
end;

// 返回 2010 或以上的新组件面板上半部分 Tab 对象，可能为空
function GetNewComponentPaletteTabControl: TWinControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPaletteTabName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find New ComponentPalette TabControl!');
{$ENDIF}
end;

// 返回 2010 或以上的新组件面板下半部分容纳组件列表的容器对象，可能为空
function GetNewComponentPaletteComponentPanel: TWinControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find New ComponentPalette Panel!');
{$ENDIF}
end;

// 返回对象检查器窗体，可能为空
function GetObjectInspectorForm: TCustomForm;
begin
  Result := GetIdeMainForm;
  if Result <> nil then
    Result := TCustomForm(Result.FindComponent('PropertyInspector'));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find Oject Inspector!');
{$ENDIF}
end;

// 返回组件面板右键菜单，可能为空
function GetComponentPalettePopupMenu: TPopupMenu;
var
  MainForm: TCustomForm;
begin
  Result := nil;
  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := TPopupMenu(MainForm.FindComponent('PaletteMenu'));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find PaletteMenu!');
{$ENDIF}
end;

// 返回组件面板所在的ControlBar，可能为空
function GetComponentPaletteControlBar: TControlBar;
var
  MainForm: TCustomForm;
  i: Integer;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    for i := 0 to MainForm.ComponentCount - 1 do
      if MainForm.Components[i] is TControlBar then
      begin
        Result := MainForm.Components[i] as TControlBar;
        Break;
      end;
      
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find ControlBar!');
{$ENDIF}
end;

// 返回主菜单项高度
function GetMainMenuItemHeight: Integer;
{$IFDEF COMPILER7_UP}
var
  MainForm: TCustomForm;
  Component: TComponent;
{$ENDIF}
begin
{$IFDEF COMPILER7_UP}
  Result := 23;
  MainForm := GetIdeMainForm;
  Component := nil;
  if MainForm <> nil then
    Component := MainForm.FindComponent('MenuBar');
  if (Component is TControl) then
    Result := TControl(Component).ClientHeight; // This is approximate?
{$ELSE}
  Result := GetSystemMetrics(SM_CYMENU);
{$ENDIF}
end;

// 判断指定窗体是否是设计期窗体
function IsIdeDesignForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (csDesigning in AForm.ComponentState);
end;

// 判断指定窗体是否编辑器窗体
function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and
            (Pos('EditWindow_', AForm.Name) = 1) and
            (AForm.ClassName = EditorFormClassName) and
            (not (csDesigning in AForm.ComponentState));
end;

// 将源码编辑器设为活跃
procedure BringIdeEditorFormToFront;
var
  i: Integer;
begin
  for i := 0 to Screen.CustomFormCount - 1 do
    if IsIdeEditorForm(Screen.CustomForms[i]) then
    begin
      Screen.CustomForms[i].BringToFront;
      Exit;
    end;
end;

// 判断 IDE 是否是当前的活动窗口
function IDEIsCurrentWindow: Boolean;
begin
  Result := GetCurrentThreadId = GetWindowThreadProcessId(GetForegroundWindow, nil);
end;

//==============================================================================
// 其它的 IDE 相关函数
//==============================================================================

// 取编译器安装目录
function GetInstallDir: string;
begin
  Result := _CnExtractFileDir(_CnExtractFileDir(Application.ExeName));
end;

{$IFDEF BDS}
// 取得 BDS (Delphi8/9) 的用户数据目录
function GetBDSUserDataDir: string;
const
  CSIDL_LOCAL_APPDATA = $001c;
begin
  Result := MakePath(GetSpecialFolderLocation(CSIDL_LOCAL_APPDATA));
{$IFDEF DELPHI8}
  Result := Result + 'Borland\BDS\2.0';
{$ELSE}
{$IFDEF DELPHI9}
  Result := Result + 'Borland\BDS\3.0';
{$ELSE}
{$IFDEF DELPHI10}
  Result := Result + 'Borland\BDS\4.0';
{$ELSE}
{$IFDEF DELPHI11}
  Result := Result + 'CodeGear\RAD Studio\5.0';
{$ELSE}
{$IFDEF DELPHI12}
  Result := Result + 'CodeGear\RAD Studio\6.0';
{$ELSE}
{$IFDEF DELPHI14}
  Result := Result + 'CodeGear\RAD Studio\7.0';
{$ELSE}
{$IFDEF DELPHI15}
  Result := Result + 'Embarcadero\BDS\8.0';
{$ELSE}
{$IFDEF DELPHI16}
  Result := Result + 'Embarcadero\BDS\9.0';
{$ELSE}
{$IFDEF DELPHI17}
  Result := Result + 'Embarcadero\BDS\10.0';
{$ELSE}
{$IFDEF DELPHIXE4}
  Result := Result + 'Embarcadero\BDS\11.0';
{$ELSE}
{$IFDEF DELPHIXE5}
  Result := Result + 'Embarcadero\BDS\12.0';
{$ELSE}
{$IFDEF DELPHIXE6}
  Result := Result + 'Embarcadero\BDS\14.0';
{$ELSE}
{$IFDEF DELPHIXE7}
  Result := Result + 'Embarcadero\BDS\15.0';
{$ELSE}
{$IFDEF DELPHIXE8}
  Result := Result + 'Embarcadero\BDS\16.0';
{$ELSE}
{$IFDEF DELPHI10_SEATTLE}
  Result := Result + 'Embarcadero\BDS\17.0';
{$ELSE}
{$IFDEF DELPHI101_BERLIN}
  Result := Result + 'Embarcadero\BDS\18.0';
{$ELSE}
  Error: Unknown Compiler
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;
{$ENDIF}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
var
  Options: IOTAProjectOptions;
  PKeys: Integer;
begin
  Result := nil;
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then Exit;
  PKeys := Options.GetOptionValue('Keys');
{$IFDEF DEBUG}
  CnDebugger.LogInteger(PKeys, 'CnOtaGetVersionInfoKeys');
{$ENDIF}
  Result := Pointer(PKeys);
end;

// 取环境设置中的 LibraryPath 内容，注意 XE2 以上版本，GetEnvironmentOptions 里头
// 得到的值并不是当前工程的 Platform 对应的值，所以只能改成根据工程平台从注册表里读。
procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean);
var
  Svcs: IOTAServices;
  Options: IOTAEnvironmentOptions;
  Text: string;
  List: TStrings;
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform: string;
  Project: IOTAProject;
{$ENDIF}

  procedure AddList(AList: TStrings);
  var
    S: string;
    i: Integer;
  begin
    for i := 0 to List.Count - 1 do
    begin
      S := Trim(MakePath(List[i]));
      if (S <> '') and (Paths.IndexOf(S) < 0) then
        Paths.Add(S);
    end;
  end;
begin
  Svcs := BorlandIDEServices as IOTAServices;
  if not Assigned(Svcs) then Exit;
  Options := Svcs.GetEnvironmentOptions;
  if not Assigned(Options) then Exit;

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform := '';
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    CurPlatform := Project.CurrentPlatform;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Project.CurrentPlatform  is ' + CurPlatform);
  {$ENDIF}
  end;
{$ENDIF}

  List := TStringList.Create;
  try
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Search Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('LibraryPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Browsing Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('BrowsingPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    if IncludeProjectPath then
    begin
      GetProjectLibPath(List);
      AddList(List);
    end;
  finally
    List.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
{$ENDIF}
end;

procedure AddProjectPath(Project: IOTAProject; Paths: TStrings; IDStr: string);
var
  APath: string;
  APaths: TStrings;
  i: Integer;
begin
  if not Assigned(Project.ProjectOptions) then
    Exit;

  APath := Project.ProjectOptions.GetOptionValue(IdStr);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('AddProjectPath: %s '#13#10 + APath, [IdStr]);
{$ENDIF}

  if APath <> '' then
  begin
    APath := ReplaceToActualPath(APath, Project);
      
    // 处理路径中的相对路径
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for i := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[i]) <> '' then   // 无效目录
        begin
          APath := MakePath(Trim(APaths[i]));
          if (Length(APath) > 2) and (APath[2] = ':') then // 全路径目录
          begin
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end
          else                          // 相对路径
          begin
            APath := LinkPath(_CnExtractFilePath(Project.FileName), APath);
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end;
        end;          
      end;
    finally
      APaths.Free;
    end;                
  end;
end;

// 取当前工程组的相关 Path 内容
procedure GetProjectLibPath(Paths: TStrings);
var
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
  Path: string;
  i, j: Integer;
  APaths: TStrings;
begin
  Paths.Clear;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('GetProjectLibPath');
{$ENDIF}

  // 处理当前工程组中的路径设置
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
  begin
    APaths := TStringList.Create;
    try
      for i := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[i];
        if Assigned(Project) then
        begin
          // 增加工程搜索路径
          AddProjectPath(Project, Paths, 'SrcDir');
          AddProjectPath(Project, Paths, 'UnitDir');
          AddProjectPath(Project, Paths, 'LibPath');
          AddProjectPath(Project, Paths, 'IncludePath');

          // 增加工程中文件的路径
          for j := 0 to Project.GetModuleCount - 1 do
          begin
            Path := _CnExtractFileDir(Project.GetModule(j).FileName);
            if Paths.IndexOf(Path) < 0 then
              Paths.Add(Path);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
  CnDebugger.LogLeave('GetProjectLibPath');
{$ENDIF}
end;

// 根据模块名获得完整文件名
function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
var
  Paths: TStringList;
  i: Integer;
  Ext, ProjectPath: string;
begin
  if AProject = nil then
    AProject := CnOtaGetCurrentProject;

  Ext := LowerCase(_CnExtractFileExt(AName));
  if (Ext = '') or (Ext <> '.pas') then
    AName := AName + '.pas';

  Result := '';
  // 在工程模块中查找
  if AProject <> nil then
  begin
    for i := 0 to AProject.GetModuleCount - 1 do
      if SameFileName(_CnExtractFileName(AProject.GetModule(i).FileName), AName) then
      begin
        Result := AProject.GetModule(i).FileName;
        Exit;
      end;

    ProjectPath := MakePath(_CnExtractFilePath(AProject.FileName));
    if FileExists(ProjectPath + AName) then
    begin
      Result := ProjectPath + AName;
      Exit;
    end;
  end;

  Paths := TStringList.Create;
  try
    if Assigned(AProject) then
    begin
      // 在工程搜索路径里查找
      AddProjectPath(AProject, Paths, 'SrcDir');
    end;

    // 在系统搜索路径里查找
    GetLibraryPath(Paths, False);
    for i := 0 to Paths.Count - 1 do
      if FileExists(MakePath(Paths[i]) + AName) then
      begin
        Result := MakePath(Paths[i]) + AName;
        Exit;
      end;
  finally
    Paths.Free;
  end;
end;

// 取组件定义所在的单元名
function GetComponentUnitName(const ComponentName: string): string;
var
  ClassRef: TClass;
  TypeData: PTypeData;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('GetComponentUnitName: ' + ComponentName);
{$ENDIF}

  Result := '';
  ClassRef := GetClass(ComponentName);

  if Assigned(ClassRef) then
  begin
    TypeData := GetTypeData(PTypeInfo(ClassRef.ClassInfo));
    Result := string(TypeData^.UnitName);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('UnitName: ' + Result);
  {$ENDIF}
  end;
end;

// 取已安装的包和组件
procedure GetInstalledComponents(Packages, Components: TStrings);
var
  PackSvcs: IOTAPackageServices;
  i, j: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  if Assigned(Packages) then
    Packages.Clear;
  if Assigned(Components) then
    Components.Clear;
    
  for i := 0 to PackSvcs.PackageCount - 1 do
  begin
    if Assigned(Packages) then
      Packages.Add(PackSvcs.PackageNames[i]);
    if Assigned(Components) then
      for j := 0 to PackSvcs.ComponentCount[i] - 1 do
        Components.Add(PackSvcs.ComponentNames[i, j]);
  end;
end;

function GetIDERegistryFont(const RegItem: string; AFont: TFont): Boolean;
const
  SCnIDERegName = {$IFDEF BDS} 'BDS' {$ELSE} {$IFDEF DELPHI} 'Delphi' {$ELSE} 'C++Builder' {$ENDIF}{$ENDIF};

  SCnIDEFontName = 'Editor Font';
  SCnIDEFontSize = 'Font Size';

  SCnIDEBold = 'Bold';
  {$IFDEF COMPILER7_UP}
  SCnIDEForeColor = 'Foreground Color New';
  {$ELSE}
  SCnIDEForeColor = 'Foreground Color';
  {$ENDIF}
  SCnIDEItalic = 'Italic';
  SCnIDEUnderline = 'Underline';
var
  S: string;
  Reg: TRegistry;
  Size: Integer;
{$IFDEF COMPILER7_UP}
  AColorStr: string;
{$ENDIF}
  AColor: Integer;

  function ReadBoolReg(Reg: TRegistry; const RegName: string): Boolean;
  var
    S: string;
  begin
    Result := False;
    if Reg <> nil then
    begin
      try
        S := Reg.ReadString(RegName);
        if (UpperCase(S) = 'TRUE') or (S = '1') then
          Result := True;
      except
        ;
      end;
    end;
  end;
begin
  // 从某项注册表中载入某项字体并赋值给 AFont
  Result := False; 

  if AFont <> nil then
  begin
    Reg := nil;
    try
      Reg := TRegistry.Create;
      Reg.RootKey := HKEY_CURRENT_USER;
      try
        if RegItem = '' then // 是基本字体
        begin
          if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Options') then
          begin
            if Reg.ValueExists(SCnIDEFontName) then
            begin
              S := Reg.ReadString(SCnIDEFontName);
              if S <> '' then AFont.Name := S;
            end;
            if Reg.ValueExists(SCnIDEFontSize) then
            begin
              Size := Reg.ReadInteger(SCnIDEFontSize);
              if Size > 0 then AFont.Size := Size;
            end;
            Reg.CloseKey;
          end;
          Result := True; // 不存在则用默认字体
        end
        else  // 是高亮字体
        begin
          AFont.Style := [];
          if Reg.OpenKeyReadOnly(Format(WizOptions.CompilerRegPath
            + '\Editor\Highlight\%s', [RegItem])) then
          begin
            if Reg.ValueExists(SCnIDEBold) and ReadBoolReg(Reg, SCnIDEBold) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsBold];
            end;
            if Reg.ValueExists(SCnIDEItalic) and ReadBoolReg(Reg, SCnIDEItalic) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsItalic];
            end;
            if Reg.ValueExists(SCnIDEUnderline) and ReadBoolReg(Reg, SCnIDEUnderline) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsUnderline];
            end;
            if Reg.ValueExists(SCnIDEForeColor) then
            begin
              Result := True;
  {$IFDEF COMPILER7_UP}
              AColorStr := Reg.ReadString(SCnIDEForeColor);
              if IdentToColor(AColorStr, AColor) then
                AFont.Color := AColor
              else
                AFont.Color := StrToIntDef(AColorStr, 0);
  {$ELSE}
              // D5/6 的颜色是 16 色索引号
              AColor := Reg.ReadInteger(SCnIDEForeColor);
              if AColor in [0..15] then
                AFont.Color := SCnColor16Table[AColor];
  {$ENDIF}
            end;
          end;
        end;
      except
        Result := False;
      end;
    finally
      Reg.Free;
    end;
  end;
end;

// 判断指定控件是否代码编辑器控件
function IsEditControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(EditControlClassName)
    and SameText(AControl.Name, EditControlName);
end;

// 判断指定控件是否编辑器窗口的 TabControl 控件
function IsXTabControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(XTabControlClassName)
    and SameText(AControl.Name, XTabControlName);
end;

// 返回编辑器窗口的编辑器控件
function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
begin
  Result := TControl(FindComponentByClassName(AForm, EditControlClassName,
    EditControlName));
end;

// 从编辑器控件获得其所属的编辑器窗口的状态栏
function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
var
  AComp: TComponent;
begin
  Result := nil;
  if EditControl <> nil then
  begin
    AComp := FindComponentByClass(TWinControl(EditControl.Owner), TStatusBar, 'StatusBar');
    if AComp is TStatusBar then
      Result := AComp as TStatusBar;
  end;
end;

// 返回当前的代码编辑器控件
function GetCurrentEditControl: TControl;
var
  View: IOTAEditView;
begin
  Result := nil;
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.GetEditWindow <> nil) then
    Result := GetEditControlFromEditorForm(View.GetEditWindow.Form);
end;

// 返回编辑器窗口的 TabControl 控件
function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
begin
  Result := TXTabControl(FindComponentByClassName(AForm, XTabControlClassName,
    XTabControlName));
end;

// 返回编辑器 TabControl 控件的 Tabs 属性
function GetEditorTabTabs(ATab: TXTabControl): TStrings;
begin
  Result := nil;
  if ATab <> nil then
  begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
    Result := TStrings(GetObjectProp(ATab, 'Items'));
{$ELSE}
    Result := ATab.Tabs;
{$ENDIF}
  end;
end;

// 返回编辑器 TabControl 控件的 Index 属性
function GetEditorTabTabIndex(ATab: TXTabControl): Integer;
begin
  Result := -1;
  if ATab <> nil then
  begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
    Result := GetOrdProp(ATab, 'TabIndex');
{$ELSE}
    Result := ATab.TabIndex;
{$ENDIF}
  end;
end;

// 枚举 IDE 中的代码编辑器窗口和 EditControl 控件，调用回调函数，返回总数
function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean): Integer;
var
  i: Integer;
  EditWindow: TCustomForm;
  EditControl: TControl;
begin
  Result := 0;
  for i := 0 to Screen.CustomFormCount - 1 do
    if IsIdeEditorForm(Screen.CustomForms[i]) then
    begin
      EditWindow := Screen.CustomForms[i];
      EditControl := GetEditControlFromEditorForm(EditWindow);
      if Assigned(EditControl) or not EditorMustExists then
      begin
        Inc(Result);
        if Assigned(Proc) then
          Proc(EditWindow, EditControl, Context);
      end;
    end;
end;

// 取当前编辑窗口顶层页面类型，传入编辑器父控件
function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
var
  I: Integer;
  Ctrl: TControl;
begin
  // 从头搜索第一个 Align 是 Client 的东西，是编辑器则显示
  Result := epOthers;
  for I := AControl.ControlCount - 1 downto 0 do
  begin
    Ctrl := AControl.Controls[I];
    if Ctrl.Visible and (Ctrl.Align = alClient) then
    begin
      if Ctrl.ClassNameIs(EditControlClassName) then
        Result := epCode
      else if Ctrl.ClassNameIs(DisassemblyViewClassName) then
        Result := epCPU
      else if Ctrl.ClassNameIs(DesignControlClassName) then
        Result := epDesign
      else if Ctrl.ClassNameIs(WelcomePageClassName) then
        Result := epWelcome;
      Break;
    end;
  end;
end;

var
  CorIdeModule: HMODULE;

procedure InitIdeAPIs;
begin
  CorIdeModule := LoadLibrary(CorIdeLibName);
  Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

{$IFDEF BDS4_UP}
  BeginBatchOpenCloseProc := GetProcAddress(CorIdeModule, SBeginBatchOpenCloseName);
  Assert(Assigned(BeginBatchOpenCloseProc), 'Failed to load BeginBatchOpenCloseProc from CorIdeModule');

  EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName);
  Assert(Assigned(EndBatchOpenCloseProc), 'Failed to load EndBatchOpenCloseProc from CorIdeModule');
{$ENDIF}
end;

procedure FinalIdeAPIs;
begin
  if CorIdeModule <> 0 then
    FreeLibrary(CorIdeModule);
end;  

// 开始批量打开或关闭文件
procedure BeginBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(BeginBatchOpenCloseProc) then
    BeginBatchOpenCloseProc;
{$ENDIF}
end;

// 结束批量打开或关闭文件
procedure EndBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(EndBatchOpenCloseProc) then
    EndBatchOpenCloseProc;
{$ENDIF}
end;

// 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNode 强行转换成公用的 TreeNode
function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
begin
{$IFDEF DEBUG}
  if not (Node is TTreeNode) then
    CnDebugger.LogFmt('Node ClassName %s. Value %8.8x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, Integer(Node)]);
{$ENDIF}
  Result := TTreeNode(Node);
end;

// 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNodes 强行转换成公用的 TreeNodes
function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
begin
{$IFDEF DEBUG}
  if not (Nodes is TTreeNodes) then
    CnDebugger.LogFmt('Nodes ClassName %s. Value %8.8x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, Integer(Nodes)]);
{$ENDIF}
  Result := TTreeNodes(Nodes);
end;

//==============================================================================
// 扩展控件
//==============================================================================

{ TCnToolBarComboBox }

procedure TCnToolBarComboBox.CNKeyDown(var Message: TWMKeyDown);
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

var
  FCnMessageViewWrapper: TCnMessageViewWrapper = nil;

//==============================================================================
// 组件面板封装类
//==============================================================================

{ TCnPaletteWrapper }

var
  FCnPaletteWrapper: TCnPaletteWrapper = nil;

function CnPaletteWrapper: TCnPaletteWrapper;
begin
{$IFDEF SUPPORTS_PALETTE_ENHANCE}
  if FCnPaletteWrapper = nil then
    FCnPaletteWrapper := TCnPaletteWrapper.Create;
  Result := FCnPaletteWrapper;
{$ELSE}
  raise Exception.Create('Palette NOT Support.');
{$ENDIF}
end;

procedure TCnPaletteWrapper.BeginUpdate;
begin
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 0, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 0, 0);
  end;
  Inc(FUpdateCount);
end;

constructor TCnPaletteWrapper.Create;
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I, J: Integer;
{$ENDIF}
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  FPalTab := GetNewComponentPaletteTabControl;
  if FPalTab <> nil then
    FPalette := FPalTab.Owner.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;
{$ELSE}
  FPalTab := GetComponentPaletteTabControl;

  for I := 0 to FPalTab.ControlCount - 1 do
  begin
    if FPalTab.Controls[I].ClassNameIs('TPageScroller') then
    begin
      FPageScroller := FPalTab.Controls[I] as TWinControl;
      for J := 0 to FPageScroller.ControlCount - 1 do
        if FPageScroller.Controls[J].ClassNameIs('TPalette') then
        begin
          FPalette := FPageScroller.Controls[J] as TWinControl;
          Exit;
        end;
    end;
  end;
{$ENDIF}
end;

procedure TCnPaletteWrapper.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 1, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 1, 0);
    FPalTab.Invalidate;
    FPalette.Invalidate;
  end;
end;

function TCnPaletteWrapper.FindTab(const ATab: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TabCount - 1 do
    if Tabs[I] = ATab then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnPaletteWrapper.GetActiveTab: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  Result := '';
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName)];
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Strings[(FPalTab as TTabControl).TabIndex];
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.GetComponentImage(Bmp: TBitmap;
  const AComponentClassName: string);
begin
{$IFDEF SUPPORTS_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  GetComponentImageFromNewPalette(Bmp, AComponentClassName);
  {$ELSE}
  GetComponentImageFromOldPalette(Bmp, AComponentClassName);
  {$ENDIF}
{$ENDIF}
end;

{$IFDEF SUPPORTS_PALETTE_ENHANCE}

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

procedure TCnPaletteWrapper.GetComponentImageFromNewPalette(Bmp: TBitmap;
  const AComponentClassName: string);
var
  I, J: Integer;
  S: string;
begin
  if (Bmp = nil) or (AComponentClassName = '') then
    Exit;
  try
    BeginUpdate;
    for I := 0 to TabCount - 1 do
    begin
      TabIndex := I;
      for J := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[J] is TSpeedButton) and
          FPalette.Controls[J].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          S := ParseNameFromHint((FPalette.Controls[J] as TSpeedButton).Hint);
          if S = AComponentClassName then
          begin
            GetControlBitmap(FPalette.Controls[J], Bmp);
            Exit;
          end;
        end;
      end;
    end;
  finally
    EndUpdate;
  end;
end;

{$ELSE}

procedure TCnPaletteWrapper.GetComponentImageFromOldPalette(Bmp: TBitmap;
  const AComponentClassName: string);
var
  AClass: TComponentClass;
{$IFDEF COMPILER6_UP}
  FormEditor: IOTAFormEditor;
  Root: TPersistent;
  PalItem: IPaletteItem;
  PalItemPaint: IPalettePaint;
{$ENDIF}
begin
  if (Bmp = nil) or (AComponentClassName = '') then
    Exit;

  try
{$IFDEF COMPILER6_UP}
    FormEditor := CnOtaGetCurrentFormEditor;
    if Assigned(FormEditor) and (FormEditor.GetSelComponent(0) <> nil) then
    begin
      Root := TPersistent(FormEditor.GetSelComponent(0).GetComponentHandle);
      if (Root <> nil) and not ObjectIsInheritedFromClass(Root, 'TDataModule') then
      begin
        // 只处理 CLX 和 VCL 设计期窗体变化的情况，转变 CLX/VCL 后，无需恢复
        if FOldRootClass <> Root.ClassType then
        begin
          ActivateClassGroup(TPersistentClass(Root.ClassType));
          FOldRootClass := Root.ClassType;
        end;
      end;
    end;
{$ENDIF}

    AClass := TComponentClass(GetClass(AComponentClassName));
    if AClass <> nil then
    begin
      Bmp.Canvas.FillRect(Bounds(0, 0, Bmp.Width, Bmp.Height));
{$IFDEF COMPILER6_UP}
      PalItem := ComponentDesigner.ActiveDesigner.Environment.GetPaletteItem(AClass) as IPaletteItem;
      if Supports(PalItem, IPalettePaint, PalItemPaint) then
        PalItemPaint.Paint(Bmp.Canvas, 0, 0);
{$ELSE}
      DelphiIDE.GetPaletteItem(TComponentClass(AClass)).Paint(Bmp.Canvas, -1, -1);
{$ENDIF}
    end;
  except
    ;
  end;
end;

{$ENDIF}

{$ENDIF}

function TCnPaletteWrapper.GetEnabled: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Enabled
  else
    Result := False;
end;

function TCnPaletteWrapper.GetIsMultiLine: Boolean;
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE} // 新控件板不支持多行
  Result := False;
{$ELSE}
  Result := (FPalTab as TTabControl).MultiLine;
{$ENDIF}
end;

function TCnPaletteWrapper.GetPalToolCount: Integer;
var
  I: Integer;
begin
  Result := -1;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  if FPalette <> nil then
  begin
    for I := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[I] is TSpeedButton) and
        FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        Inc(Result);
    end;
  end;
{$ELSE}
  try
    if FPalette <> nil then
      Result := GetPropValue(FPalette, SCnPalettePropPalToolCount)
  except
    Result := 0;
    if FPageScroller <> nil then
      for I := 0 to FPageScroller.ControlCount - 1 do
        if Self.FPageScroller.Controls[I] is TSpeedButton then
          Inc(Result);
  end;
{$ENDIF}
end;

function TCnPaletteWrapper.GetSelectedIndex: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I, Idx: Integer;
{$ENDIF}
begin
  Result := -1;
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      Idx := -1;
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          Inc(Idx);
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := Idx;
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedIndex);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelectedToolName: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I: Integer;
{$ENDIF}
begin
  Result := '';
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := ParseNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedToolName);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelector: TSpeedButton;
begin
  Result := nil;
  try
    if FPalette <> nil then
      Result := TSpeedButton(GetObjectProp(FPalette, SCnPalettePropSelector))
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetTabCount: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList.Count
    else
      Result := 0;
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Count;
{$ENDIF}
  end
  else
    Result := 0;
end;

function TCnPaletteWrapper.GetTabIndex: Integer;
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Result := GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName);
{$ELSE}
    Result := (FPalTab as TTabControl).TabIndex;
{$ENDIF}
  end
  else
    Result := -1;
end;

function TCnPaletteWrapper.GetTabs(Index: Integer): string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[Index]
    else
      Result := '';
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs[Index];
{$ENDIF}
  end
  else
    Result := '';
end;

function TCnPaletteWrapper.GetVisible: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Visible
  else
    Result := False;
end;

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

function TCnPaletteWrapper.ParseNameFromHint(const Hint: string): string;
const
  NamePrefix = 'Name: ';
  CRLF = #13#10;
var
  CRLFPos: Integer;
begin
  // 把控件板组件上某组件 SpeedButton 按钮的 Hint 里头的名字解析出来
  {
    Hint 形如：
    Name: ComponentName
    Unit: UnitName
    Package: PackageName
  }
  Result := Hint;
  if Pos(NamePrefix, Result) = 1 then
    Delete(Result, 1, Length(NamePrefix));
  CRLFPos := Pos(CRLF, Result);
  if CRLFPos > 0 then
    Result := Copy(Result, 1, CRLFPos - 1);
end;

{$ENDIF}

function TCnPaletteWrapper.SelectComponent(const AComponent,
  ATab: string): Boolean;
var
  I, Idx: Integer;
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  J: Integer;
{$ENDIF}

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  function SelectComponentInCurrentTab: Boolean;
  var
    K: Integer;
    S: string;
  begin
    Result := False;
    for K := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[K] is TSpeedButton) and
        FPalette.Controls[K].ClassNameIs(SCnNewPaletteButtonClassName) then
      begin
        S := ParseNameFromHint((FPalette.Controls[K] as TSpeedButton).Hint);
        if S = AComponent then
        begin
          if not (FPalette.Controls[K] as TSpeedButton).Down then
            (FPalette.Controls[K] as TSpeedButton).Click;
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}

begin
  Result := True;
  Idx := FindTab(ATab);
  if Idx >= 0 then
    TabIndex := Idx;

  // 空则表示不选择
  if AComponent = '' then
  begin
    SelectedIndex := -1;
    Exit;
  end
  else
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    if SelectComponentInCurrentTab then
      Exit;
{$ELSE}
    for I := 0 to PalToolCount - 1 do
    begin
      SelectedIndex := I;
      if SelectedToolName = AComponent then
        Exit;
    end;
{$ENDIF}
  end;

  // 该 Tab 内无此组件时，全盘搜索
  for I := 0 to TabCount - 1 do
  begin
    TabIndex := I;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    if SelectComponentInCurrentTab then
      Exit;
{$ELSE}
    for J := 0 to PalToolCount - 1 do
    begin
      SelectedIndex := J;
      if SelectedToolName = AComponent then
        Exit;
    end;
{$ENDIF}
  end;

  SelectedIndex := -1;
  Result := False;
end;

procedure TCnPaletteWrapper.SetEnabled(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Enabled := Value;
end;

procedure TCnPaletteWrapper.SetSelectedIndex(const Value: Integer);
var
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  I, Idx: Integer;
{$ELSE}
  PropInfo: PPropInfo;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Idx := -1;
    for I := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[I] is TSpeedButton) and
        FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
      begin
        Inc(Idx);
        if (Idx = Value) and not (FPalette.Controls[I] as TSpeedButton).Down then
        begin
          (FPalette.Controls[I] as TSpeedButton).Click;
          Exit;
        end
        else if (Value = -1) and (FPalette.Controls[I] as TSpeedButton).Down then
        begin
          (FPalette.Controls[I] as TSpeedButton).Click;
          Exit;
        end;
      end;
    end;
{$ELSE}
    PropInfo := GetPropInfo(FPalette.ClassInfo, SCnPalettePropSelectedIndex);
    SetOrdProp(FPalette, PropInfo, Value);
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.SetTabIndex(const Value: Integer);
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    SetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName, Value);
{$ELSE}
    (FPalTab as TTabControl).TabIndex := Value;
    if Assigned((FPalTab as TTabControl).OnChange) then
      (FPalTab as TTabControl).OnChange(FPalTab);
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.SetVisible(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Visible := Value;
end;

{ TCnMessageViewWrapper }

function CnMessageViewWrapper: TCnMessageViewWrapper;
begin
  if FCnMessageViewWrapper = nil then
    FCnMessageViewWrapper := TCnMessageViewWrapper.Create
  else
    FCnMessageViewWrapper.UpdateAllItems;

  Result := FCnMessageViewWrapper;
end;

constructor TCnMessageViewWrapper.Create;
begin
  UpdateAllItems;
end;

procedure TCnMessageViewWrapper.EditMessageSource;
begin
  if (FEditMenuItem <> nil) and Assigned(FEditMenuItem.OnClick) then
  begin
    FMessageViewForm.SetFocus;
    FEditMenuItem.OnClick(FEditMenuItem);
  end;
end;

{$IFNDEF BDS}

function TCnMessageViewWrapper.GetCurrentMessage: string;
begin
  Result := '';
  if FTreeView <> nil then
    if FTreeView.Selected <> nil then
      Result := FTreeView.Selected.Text;
end;

function TCnMessageViewWrapper.GetMessageCount: Integer;
begin
  Result := -1;
  if FTreeView <> nil then
    Result := FTreeView.Items.Count;
end;

function TCnMessageViewWrapper.GetSelectedIndex: Integer;
begin
  Result := -1;
  if (FTreeView <> nil) and (FTreeView.Selected <> nil) then
    Result := FTreeView.Selected.AbsoluteIndex;
end;

procedure TCnMessageViewWrapper.SetSelectedIndex(const Value: Integer);
begin
  if FTreeView <> nil then
    if (Value >= 0) and (Value < FTreeView.Items.Count) then
      FTreeView.Selected := FTreeView.Items[Value];
end;

{$ENDIF}

function TCnMessageViewWrapper.GetTabCaption: string;
begin
  Result := '';
  if FTabSet <> nil then
    Result := FTabSet.Tabs[FTabSet.TabIndex];
end;

function TCnMessageViewWrapper.GetTabCount: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.Tabs.Count;
end;

function TCnMessageViewWrapper.GetTabIndex: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.TabIndex;
end;

function TCnMessageViewWrapper.GetTabSetVisible: Boolean;
begin
  Result := False;
  if FTabSet <> nil then
    Result := FTabSet.Visible;;
end;

procedure TCnMessageViewWrapper.SetTabIndex(const Value: Integer);
begin
  if FTabSet <> nil then
    FTabSet.TabIndex := Value;
end;

procedure TCnMessageViewWrapper.UpdateAllItems;
var
  I, J: Integer;
begin
  try
    FMessageViewForm := nil;
    FEditMenuItem := nil;
    FTreeView := nil;
    FTabSet := nil;
    
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[I].ClassNameIs('TMessageViewForm') then
      begin
        FMessageViewForm := Screen.CustomForms[I];
        FEditMenuItem := TMenuItem(FMessageViewForm.FindComponent(SCnMvEditSourceItemName));

        for J := 0 to FMessageViewForm.ControlCount - 1 do
        begin
          if FMessageViewForm.Controls[J].ClassNameIs(SCnTreeMessageViewClassName) then
          begin
           FTreeView := TXTreeView(FMessageViewForm.Controls[J]);
          end
          else if FMessageViewForm.Controls[J].Name = SCnMessageViewTabSetName then
          begin
            FTabSet := TTabSet(FMessageViewForm.Controls[J]);
          end;
        end;
      end;
    end;
  except
    ;
  end;
end;

initialization
  // 使用此全局变量可以避免频繁调用 IdeGetIsEmbeddedDesigner 函数
  IdeIsEmbeddedDesigner := IdeGetIsEmbeddedDesigner;
  
  InitIdeAPIs;

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizIdeUtils finalization.');
{$ENDIF}

  if FCnPaletteWrapper <> nil then
    FreeAndNil(FCnPaletteWrapper);

  if FCnMessageViewWrapper <> nil then
    FreeAndNil(FCnMessageViewWrapper);

  FinalIdeAPIs;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizIdeUtils finalization.');
{$ENDIF}
end.

