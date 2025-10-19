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
* 单元名称：IDE 相关公共单元
* 单元作者：周劲羽 (zjy@cnpack.org)
*           CnPack 开发组 master@cnpack.org
* 备    注：该单元部分内容移植自 GExperts 1.12 Src
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2016.04.04 by liuxiao
*               增加 2010 以上版本的新风格控件板的支持
*           2012.09.19 by shenloqi
*               移植到 Delphi XE3
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
  Windows, Messages, Classes, Controls, SysUtils, Graphics, Forms, Contnrs,
  Menus, Buttons, ComCtrls, StdCtrls, ExtCtrls, TypInfo, ImgList,
  {$IFDEF LAZARUS} PackageIntf, ComponentReg, IDEOptionsIntf, {$ENDIF}
  {$IFDEF DELPHI_OTA} ToolsAPI, CnWizEditFiler, {$IFDEF IDE_SUPPORT_HDPI}
  Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF}
 {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner, Variants,
  {$ELSE} DsgnIntf, LibIntf,{$ENDIF} {$ENDIF}
  {$IFDEF FPC} LCLType, {$ELSE} Tabs, {$ENDIF}
  {$IFDEF OTA_PALETTE_API} PaletteAPI, {$ENDIF}
  {$IFNDEF STAND_ALONE} {$IFNDEF CNWIZARDS_MINIMUM} CnIDEVersion, {$ENDIF} {$ENDIF}
  {$IFDEF USE_CODEEDITOR_SERVICE} ToolsAPI.Editor, {$ENDIF}
  CnPasCodeParser, CnWidePasParser, CnWizMethodHook, mPasLex, CnPasWideLex,
  mwBCBTokenList, CnBCBWideTokenList, CnWizUtils, CnCommon,
  CnWideStrings, CnWizOptions, CnWizCompilerConst, CnIDEStrings;

//==============================================================================
// IDE 中的常量定义
//==============================================================================

const
  // IDE Action 名称
  SCnEditSelectAllCommand = 'EditSelectAllCommand';

  // Editor 窗口右键菜单名称
  SCnMenuClosePageName = 'ecClosePage';
  SCnMenuClosePageIIName = 'ecClosePageII';
  SCnMenuEditPasteItemName = 'EditPasteItem';
  SCnMenuOpenFileAtCursorName = 'ecOpenFileAtCursor';

  // Editor 窗口相关类名
{$IFDEF LAZARUS}
  SCnEditorFormClassName = 'TSourceNotebook';
  SCnEditorFormName = 'SourceNotebook';    // 似乎单窗口实例
  SCnEditControlClassName = 'TIDESynEditor';
  SCnEditControlNamePrefix = 'SynEdit';    // 一窗口多个编辑器实例，因此是前缀，名称后面还有数字

  // Lazarus 编辑器里是一个 PageControl，每个 TabSheet 里一个编辑器实例
  SCnEditWindowPageControlClassName = 'TExtendedNotebook';
  SCnEditWindowPageControlName = 'SrcEditNotebook';
{$ELSE}
  SCnEditorFormClassName = 'TEditWindow';
  SCnEditorFormNamePrefix = 'EditWindow_'; // 多窗口实例，因此是前缀，名称后面还有数字
  SCnEditControlClassName = 'TEditControl';
  SCnEditControlName = 'Editor';
{$ENDIF}

  SCnDesignControlClassName = 'TEditorFormDesigner';
  SCnWelcomePageClassName = 'TWelcomePageFrame';
  SCnDisassemblyViewClassName = 'TDisassemblyView';
  SCnDisassemblyViewName = 'CPU';
  SCnEditorStatusBarName = 'StatusBar';

{$IFDEF BDS}
  {$IFDEF BDS4_UP} // BDS 2006 RAD Studio 2007 的标签页类名
  SCnXTabControlClassName = 'TIDEGradientTabSet';   // TWinControl 子类
  {$ELSE} // BDS 2005 的标签页类名
  SCnXTabControlClassName = 'TCodeEditorTabControl'; // TTabSet 子类
  {$ENDIF}
{$ELSE} // Delphi BCB 的标签页类名
  SCnXTabControlClassName = 'TXTabControl';
{$ENDIF BDS}
  SCnXTabControlName = 'TabControl';

  SCnTabControlPanelName = 'TabControlPanel';
  SCnCodePanelName = 'CodePanel';
  SCnTabPanelName = 'TabPanel';

  // 对象查看器
  SCnPropertyInspectorClassName = 'TPropertyInspector';
  SCnPropertyInspectorName = 'PropertyInspector';
  SCnPropertyInspectorListClassName = 'TInspListBox';
  SCnPropertyInspectorListName = 'PropList';
  SCnPropertyInspectorTabControlName = 'TabControl';
  SCnPropertyInspectorLocalPopupMenu = 'LocalPopupMenu';

  // 编辑器设置对话框
{$IFDEF BDS}
  SCnEditorOptionDlgClassName = 'TDefaultEnvironmentDialog';
  SCnEditorOptionDlgName = 'DefaultEnvironmentDialog';
{$ELSE} {$IFDEF BCB}
  SCnEditorOptionDlgClassName = 'TCppEditorPropertyDialog';
  SCnEditorOptionDlgName = 'CppEditorPropertyDialog';
{$ELSE}
  SCnEditorOptionDlgClassName = 'TPasEditorPropertyDialog';
  SCnEditorOptionDlgName = 'PasEditorPropertyDialog';
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

  // 调试信息提示大窗口
  SCnExpandableEvalViewClassName = 'TExpandableEvalView';
  SCnExpandableEvalViewName = 'ExpandableEvalView';

{$IFDEF BDS}
  SCnTreeMessageViewClassName = 'TBetterHintWindowVirtualDrawTree';
{$ELSE}
  SCnTreeMessageViewClassName = 'TTreeMessageView';
{$ENDIF}

  // XE5 或以上版本有 IDE Insight 搜索框 
{$IFDEF IDE_HAS_INSIGHT}
  SCnIDEInsightBarClassName = 'TButtonedEdit';
  SCnIDEInsightBarName = 'beIDEInsight';
{$ENDIF}

  // 引用单元功能的 Action 名称
{$IFDEF DELPHI}
  SCnUseUnitActionName = 'FileUseUnitCommand';
{$ELSE}
  SCnUseUnitActionName = 'FileIncludeUnitHdrCommand';
{$ENDIF}

  // Lazarus 主窗体
  SCnLazMainFormClassName = 'TMainIDEBar';
  SCnLazMainFormName = 'MainIDE';

  SCnColor16Table: array[0..15] of TColor =
  ( clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clLtGray, clDkGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite);

  csDarkBackgroundColor = $2E2F33;  // Dark 模式下的未选中的背景色
  csDarkFontColor = $FFFFFF;        // Dark 模式下的未选中的文字颜色
  csDarkHighlightBkColor = $8E6535; // Dark 模式下的选中状态下的高亮背景色
  csDarkHighlightFontColor = $FFFFFF; // Dark 模式下的选中状态下的高亮文字颜色

  // 10.4.2 后的 Error Insight 绘制类型，会影响行高
  SCnErrorInsightRenderStyleKeyName = 'ErrorInsightMarks';
  csErrorInsightRenderStyleNotSupport = -1;
  csErrorInsightRenderStyleClassic = 0;
  csErrorInsightRenderStyleSmoothWave = 1;
  csErrorInsightRenderStyleSolid = 2;
  csErrorInsightRenderStyleDot = 3;

  // Smooth Wave时行高有 3 像素的固定偏差
  csErrorInsightCharHeightOffset = 3;

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

  TCnSrcEditorPage = (epCode, epDesign, epCPU, epWelcome, epOthers);

  TCnModuleSearchType = (mstInvalid, mstInProject, mstProjectSearch, mstSystemSearch);
  {* 搜索到的源码位置类型：非法、工程内、工程搜索目录内、系统搜索目录内（包括安装目录的系统库）}

  TCnModuleSearchTypes = set of TCnModuleSearchType;

  TCnUsesFileType = (uftInvalid, uftPascalSource, uftPascalDcu, uftCppHeader);

  TCnUnitCallback = procedure(const AUnitFullName: string; Exists: Boolean;
    FileType: TCnUsesFileType; ModuleSearchType: TCnModuleSearchType) of object;

  TEnumEditControlProc = procedure (EditWindow: TCustomForm; EditControl:
    TControl; Context: Pointer) of object;

type
  PCnUnitsInfoRec = ^TCnUnitsInfoRec;
  TCnUnitsInfoRec = record
    IsCppMode: Boolean;
    Sorted: TStringList;
    Unsorted: TStringList;
  end;

{$IFDEF DELPHI_OTA}

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
{* 根据文件名取得内容。如果文件在 IDE 中打开，返回编辑器中的内容，否则返回文件内容。
  内容应该是无 BOM 头的 Ansi/Ansi/Utf16}

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
{* 根据文件名写入内容。如果文件在 IDE 中打开，写入内容到编辑器中，否则如果
   OpenInIde 为真打开文件写入到编辑器，OpenInIde 为假直接写入文件。}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* 判断标识符是否在光标下，频繁调用，因此此处 View 用指针来避免引用计数从而优化速度，各版本均可使用 }

function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
{* 判断标识符是否在光标下，同上，但使用 WideToken，可供 Unicode/Utf8 环境下调用}

function IsGeneralCurrentToken(AView: Pointer; AControl: TControl;
    Token: TCnGeneralPasToken): Boolean;
{* 判断标识符是否在光标下，囊括以上两种情况}

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

{$ENDIF}

function IdeGetIsEmbeddedDesigner: Boolean;
{* 取得当前是否是嵌入式设计窗体模式}

var
  IdeIsEmbeddedDesigner: Boolean = False;
  {* 标记当前是否是嵌入式设计窗体模式，initiliazation 时被初始化，请勿手工修改其值。
     使用此全局变量可以避免频繁调用 IdeGetIsEmbeddedDesigner 函数}

//==============================================================================
// 修改自 GExperts Src 1.12 的 IDE 相关函数
//==============================================================================

function GetIDEMainForm: TCustomForm;
{* 返回 IDE 主窗体（TAppBuilder 或 TMainIDEBar）}

{$IFDEF DELPHI_OTA}

function GetIDEEdition: string;
{* 返回 IDE 版本}

function GetComponentPaletteTabControl: TTabControl;
{* 返回组件面板对象，可能为空，只支持 2010 以下版本}

function GetNewComponentPaletteTabControl: TWinControl;
{* 返回 2010 或以上的新组件面板上半部分 Tab 对象，可能为空}

function GetNewComponentPaletteComponentPanel: TWinControl;
{* 返回 2010 或以上的新组件面板下半部分容纳组件列表的容器对象，可能为空}

function GetEditWindowStatusBar(EditWindow: TCustomForm = nil): TStatusBar;
{* 返回编辑器窗口下方的状态栏，可能为空}

function GetObjectInspectorForm: TCustomForm;
{* 返回对象检查器窗体，可能为空}

function GetComponentPalettePopupMenu: TPopupMenu;
{* 返回组件面板右键菜单，可能为空}

function GetComponentPaletteControlBar: TControlBar;
{* 返回组件面板所在的 ControlBar，可能为空}

function GetIDEInsightBar: TWinControl;
{* 返回 IDE Insight 搜索框控件对象}

function GetExpandableEvalViewForm: TCustomForm;
{* 返回调试时提示信息大窗口，低版本或非调试期可能为空}

function GetMainMenuItemHeight: Integer;
{* 返回主菜单项高度 }

{$ENDIF}

function IsIdeEditorForm(AForm: TCustomForm): Boolean;
{* 判断指定窗体是否编辑器窗体}

function IsIdeDesignForm(AForm: TCustomForm): Boolean;
{* 判断指定窗体是否是设计期窗体}

procedure BringIdeEditorFormToFront;
{* 将源码编辑器设为活跃}

procedure GetInstalledComponents(Packages, Components: TStrings);
{* 取已安装的包和组件，参数允许为 nil（忽略）}

function IsEditControl(AControl: TComponent): Boolean;
{* 判断指定控件是否代码编辑器控件 }

function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean = True): Integer;
{* 枚举 IDE 中的代码编辑器窗口和 EditControl 控件，调用回调函数，返回总数 }

{$IFDEF LAZARUS}

function GetEditControlsFromEditorForm(AForm: TCustomForm; EditControls: TObjectList): Integer;
{* Lazarus 下返回编辑器窗口的编辑器控件列表，因为一个窗体多个 Tab，每个 Tab 都有一个 Edit 控件。}

{$ELSE}

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
{* 返回编辑器窗口的编辑器控件，注意 Lazarus 下因为一个窗体多个 Tab，每个 Tab 都有一个 Edit 控件，
  因而本函数只能返回找到的第一个符合条件的控件，意义不大，直接在 Lazarus 下禁用，只在 Delphi 中使用。}

{$ENDIF}

function GetCurrentEditControl: TControl;
{* 返回当前的代码编辑器控件 }

procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean = True);
{* 取环境设置中的 LibraryPath 内容}

procedure GetProjectLibPath(Paths: TStrings);
{* 取当前工程组的相关 Path 内容}

function GetProjectDcuPath(AProject: TCnIDEProjectInterface): string;
{* 取当前工程的输出目录，支持 Delphi 和 Lazarus}

function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
{* 取当前编辑窗口顶层页面类型，传入编辑器父控件 }

function IsDesignControl(AControl: TControl): Boolean;
{* 判断一 Control 是否是设计期 WinControl}

function IsDesignWinControl(AControl: TWinControl): Boolean;
{* 判断一 WinControl 是否是设计期 WinControl}

function IsXTabControl(AControl: TComponent): Boolean;
{* 判断指定控件是否编辑器窗口的 TabControl 控件 }

{$IFDEF DELPHI_OTA}

procedure CloseExpandableEvalViewForm;
{* 关闭调试时提示信息大窗口}

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

function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
{* 根据模块名获得完整文件名}

function GetFileNameSearchTypeFromModuleName(AName: string;
  var SearchType: TCnModuleSearchType; AProject: IOTAProject = nil): string;
{* 根据模块名获得完整文件名以及处于哪一类搜索目录中，无扩展名时默认搜 pas}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
{* 获取当前项目中的版本信息键值}

function GetCurrentCompilingProject: IOTAProject;
{* 返回当前正在编译的工程，注意不一定是当前工程}

function CompileProject(AProject: IOTAProject): Boolean;
{* 编译工程，返回编译是否成功}

function GetComponentUnitName(const ComponentName: string): string;
{* 取组件定义所在的单元名}

function GetIDERegistryFont(const RegItem: string; AFont: TFont;
  out BackgroundColor: TColor; CheckBackDef: Boolean = False): Boolean;
{* 从某项注册表中载入某项字体并赋值给 AFont，并把背景色赋值给 BackgroundColor
   CheckBackDef 表示（目前仅在 D56 下）读背景色时是否检查 Default Background 为 True，
   True 代表使用默认背景色而不是本条目背景色，因而不返回读到的背景色值
   RegItem 可以是 '', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol'
    等注册表里头已经定义了的键值}

function GetCPUViewFromEditorForm(AForm: TCustomForm): TControl;
{* 返回编辑器窗口的 CPU 查看器控件 }

function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
{* 返回编辑器窗口的 TabControl 控件 }

function GetEditorTabTabs(ATab: TXTabControl): TStrings;
{* 返回编辑器 TabControl 控件的 Tabs 属性}

function GetEditorTabTabIndex(ATab: TXTabControl): Integer;
{* 返回编辑器 TabControl 控件的 Index 属性}

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

procedure BeginBatchOpenClose;
{* 开始批量打开或关闭文件 }

procedure EndBatchOpenClose;
{* 结束批量打开或关闭文件 }

function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
{* 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNode 强行转换成公用的 TreeNode}

function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
{* 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNodes 强行转换成公用的 TreeNodes}

procedure ApplyThemeOnToolBar(ToolBar: TToolBar; Recursive: Boolean = True);
{* 为工具栏应用主题，只在支持主题的 Delphi 版本中有效}

function GetErrorInsightRenderStyle: Integer;
{* 返回 ErrorInsight 的当前类型，返回值为 csErrorInsightRenderStyle* 系列常数
   -1 为不支持，1 时会影响编辑器行高，影响程度和显示 Leve 以及是否侧边栏显示均无关}

function IdeEnumUsesIncludeUnits(UnitCallback: TCnUnitCallback; IsCpp: Boolean = False;
  SearchTypes: TCnModuleSearchTypes = [mstInProject, mstProjectSearch, mstSystemSearch]): Boolean;
{* 遍历 Uses 单元，可根据 SearchTypes 指定范围。返回的文件名可能是 IDE 中打开的还未保存的
  Delphi 会遍历 pas 和 dcu，C++Builder 会遍历 h/hpp，均会在 UnitCallback 中指明}

procedure CorrectCaseFromIdeModules(UnitFilesList: TStringList; IsCpp: Boolean = False);
{* 根据文件名获得的系统 Uses 的单元名大小写可能不正确，此处通过遍历 IDE 模块来更新
  UnitFilesList 是不带 dcu 扩展名的文件名列表，注意不是完整路径名列表，
  且跑完后 UnitFilesList.Sorted 会被设为 True}

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
     下面 Panel 容纳滚动按钮以及多个 TPalItemSpeedButton 的控件图标按钮}
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
    function ParseCompNameFromHint(const Hint: string): string;
    function ParseUnitNameFromHint(const Hint: string): string;
    function ParsePackageNameFromHint(const Hint: string): string;
{$ENDIF}
    function GetSelectedIndex: Integer;
    function GetSelectedToolName: string;
    function GetSelectedUnitName: string;
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

{$IFDEF SUPPORT_PALETTE_ENHANCE}
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
    function GetUnitNameFromComponentClassName(const AClassName: string;
      const ATabName: string = ''): string;
    {* 从组件类名获得其单元名}
{$IFDEF OTA_PALETTE_API}
    function GetUnitPackageNameFromComponentClassName(out UnitName: string; out PackageName: string;
      const AClassName: string; const ATabName: string = ''): Boolean;
    {* 用 Palette API 的接口从组件类名获得单元名与包名，返回获取是否成功}
{$ENDIF}
    procedure GetComponentImage(Bmp: TBitmap; const AComponentClassName: string);
    {* 将控件板上指定的组件名的图标绘制到 Bmp 中，Bmp 推荐尺寸为 26 * 26}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* 按下的控件在本页的序号，0 开头，支持高版本的新控件板 }
    property SelectedToolName: string read GetSelectedToolName;
    {* 按下的控件的类名，未按下则为空，支持高版本的新控件板 }
    property SelectedUnitName: string read GetSelectedUnitName;
    {* 按下的控件的单元名，未按下为空，支持高版本的新控件版，可解析 Hint 而来}
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

{ TCnMessageViewWrapper }

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

  TCnThemeWrapper = class(TObject)
  {* 封装了主题信息的工具类}
  private
    FActiveThemeName: string;
    FCurrentIsDark: Boolean;
    FCurrentIsLight: Boolean;
    FSupportTheme: Boolean;
    procedure ThemeChanged(Sender: TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsUnderDarkTheme: Boolean;
    function IsUnderLightTheme: Boolean;

    property SupportTheme: Boolean read FSupportTheme;
    property ActiveThemeName: string read FActiveThemeName;
    property CurrentIsDark: Boolean read FCurrentIsDark;
    property CurrentIsLight: Boolean read FCurrentIsLight;
  end;

function CnPaletteWrapper: TCnPaletteWrapper;
{* 控件板封装处理}

function CnMessageViewWrapper: TCnMessageViewWrapper;
{* 消息栏封装处理}

function CnThemeWrapper: TCnThemeWrapper;
{* 主题封装处理}

procedure DisableWaitDialogShow;
{* 以 Hook 方式禁用 WaitDialog}

procedure EnableWaitDialogShow;
{* 以解除 Hook 方式启用 WaitDialog}

{$ENDIF}

function IdeGetScaledPixelsFromOrigin(APixels: Integer; AControl: TControl = nil): Integer;
{* IDE 中根据 DPI 与缩放设置，计算原始像素数的真实所需像素数用于绘制
  支持 Windows 中的缩放比，支持 IDE 运行在 DPI Ware/Unware 下
  也就是说：Windows 缩放比是 100% 也就是原始大小时，无论 IDE 运行模式如何都返回原始数据
  缩放比不为 100% 时，DPI Ware 才返回 APixels * HDPI 比例，Unware 无论啥设置仍返回原始数据}

function IdeGetOriginPixelsFromScaled(APixels: Integer; AControl: TControl = nil): Integer;
{* IDE 中根据 DPI 与缩放设置，计算真实像素数所对应的原始像素数用于设计或存储
  支持 Windows 中的缩放比，支持 IDE 运行在 DPI Ware/Unware 下
  也就是说：Windows 缩放比是 100% 也就是原始大小时，无论 IDE 运行模式如何都返回原始数据
  缩放比不为 100% 时，DPI Ware 才返回 APixels / HDPI 比例，Unware 无论啥设置仍返回原始数据}

function IdeGetScaledFactor(AControl: TControl = nil): Single;
{* 获得 IDE 中某控件的应该放大的比例}

procedure IdeSetReverseScaledFontSize(AControl: TControl);
{* IDE 中根据 DPI 与缩放设置，反推计算某字号的原始尺寸，以便 Scale 时恢复原始尺寸。暂不使用。}

procedure IdeScaleToolbarComboFontSize(Combo: TControl);
{* 统一根据当前 HDPI 与缩放设置等设置 Toolbar 中的 Combobox 的字号}

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}

function IdeGetVirtualImageListFromOrigin(Origin: TCustomImageList;
  AControl: TControl = nil; IgnoreWizLargeOption: Boolean = False): TVirtualImageList;
{* 统一根据当前 HDPI 与缩放设置等，从原始 TImageList 创建一个 TVirtualImageList，无需释放
  IgnoreWizLargeOption 表示不处理专家包设置中的使用大图标}

{$ENDIF}
{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF CNWIZARDS_MINIMUM}

{$IFDEF DELPHI_OTA}

function SearchUsesInsertPosInPasFile(const FileName: string; IsIntf: Boolean;
  out HasUses: Boolean; out LinearPos: Integer): Boolean;
{* 使用 Filer 封装指定 Pascal 源文件中搜索 uses 待插入的线性位置，不区分文件或磁盘
  偏移均以 Ansi/Utf16/Utf16 为准。IsIntf 指明搜索的是 interface 处的 uses
  还是 implemetation 的，返回是否成功。成功时返回线性位置，以及该处是否已有 uses}

function SearchUsesInsertPosInCurrentPas(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
{* 在当前编辑的 Pascal 源文件中搜索 uses 待插入的编辑器位置，IsIntf 指明搜索的是 interface 处的 uses
  还是 implemetation 的，返回是否成功，成功时返回编辑器位置，以及该处是否已有 uses}

function SearchUsesInsertPosInCurrentCpp(out CharPos: TOTACharPos;
  SourceEditor: IOTASourceEditor = nil): Boolean;
{* 在编辑的 C++ 源文件中搜索 include 待插入的位置，返回是否成功，成功时返回位置}

function JoinUsesOrInclude(IsCpp, FileHasUses: Boolean; IsHFromSystem: Boolean;
  const IncFiles: TStrings): string;
{* 根据源码类型与待插入的文件名列表得到插入的 uses 或 include 字符串，
  FileHasUses 只对 Pascal 代码有效、IsHFromSystem 只对 Cpp 文件有效}

{$ENDIF}
{$ENDIF}
{$ENDIF}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Registry, CnGraphUtils {$IFNDEF LAZARUS}, CnWizNotifier {$ENDIF};

const
{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF FPC}
  CN_DEF_SCREEN_DPI = 96;
{$ELSE}
  CN_DEF_SCREEN_DPI = Windows.USER_DEFAULT_SCREEN_DPI;
{$ENDIF}
{$ENDIF}

  SSyncButtonName = 'SyncButton';
  SCodeTemplateListBoxName = 'CodeTemplateListBox';
{$IFDEF IDE_SWITCH_BUG}
  {$IFDEF WIN64}
  SWaitDialogShow = '_ZN10Waitdialog14TIDEWaitDialog4ShowEN6System13UnicodeStringES2_b';
  {$ELSE}
  SWaitDialogShow = '@Waitdialog@TIDEWaitDialog@Show$qqrx20System@UnicodeStringt1o';
  {$ENDIF}
{$ENDIF}

{$IFDEF BDS4_UP}
const
{$IFDEF WIN64}
  SBeginBatchOpenCloseName = '_ZN10Editorform19BeginBatchOpenCloseEv';
  SEndBatchOpenCloseName = '_ZN10Editorform17EndBatchOpenCloseEb';
{$ELSE}
  SBeginBatchOpenCloseName = '@Editorform@BeginBatchOpenClose$qqrv';
  SEndBatchOpenCloseName = '@Editorform@EndBatchOpenClose$qqrv';

{$IFDEF DELPHI120_ATHENS_UP}
  // D12.1 改名了，但 12 没改
  SEndBatchOpenCloseName121 = '@Editorform@EndBatchOpenClose$qqrxo';
{$ENDIF}
{$ENDIF}

var
  BeginBatchOpenCloseProc: TProcedure = nil;
  EndBatchOpenCloseProc: TProcedure = nil;
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
var
  FOriginImages: TObjectList = nil;
  FVirtualImages: TObjectList = nil;
  FImageCollections: TObjectList = nil;
{$ENDIF}

{$IFDEF IDE_SWITCH_BUG}
type
  TCnWaitDialogShowProc = procedure (ASelfClass: Pointer; const Caption: string;
    const TitleMessage: string; LockDrawing: Boolean);

var
  FDesignIdeHandle: THandle = 0;
  FWaitDialogHook: TCnMethodHook = nil;
  OldWaitDialogShow: TCnWaitDialogShowProc = nil;

procedure MyWaitDialogShow(ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);
begin
  // 啥都不做
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MyWaitDialogShow Called. Do Nothing.');
{$ENDIF}
end;

{$ENDIF}

type
  TControlHack = class(TControl);
  TCustomControlHack = class(TCustomControl);

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE功能函数
//==============================================================================

type
  TGetCodeMode = (smLine, smSelText, smSource);
  // 选择区扩展到整行（未选则当前行）、选择区、整个文件

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
{$IFDEF DEBUG}
      if Block = nil then
        CnDebugger.LogMsg('DoGetEditorSrcInfo: Block is nil.')
      else if Block.IsValid then
        CnDebugger.LogMsg('DoGetEditorSrcInfo: Block is Valid.');
{$ENDIF}
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

{$IFDEF DEBUG}
    CnDebugger.LogFmt('DoGetEditorLines: StartPos %d, EndPos %d.', [StartPos, EndPos]);
{$ENDIF}

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

    // 10.1 或以上的脚本专家创建的 TStringList，其 LineBreak 属性会莫名其妙变空，补一下
{$IFDEF DELPHI101_BERLIN_UP}
    if Lines.LineBreak <> sLineBreak then
      Lines.LineBreak := sLineBreak;
{$ENDIF}

    Lines.Text := Res;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('DoGetEditorLines Get %d Lines.', [Lines.Count]);
{$ENDIF}
    Result := Text <> '';
  end;
end;

function DoSetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: string;
  S: AnsiString;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos: Integer;
  Writer: IOTAEditWriter;
  NewRow, NewCol: Integer;
{$IFDEF TSTRINGS_HAS_OPTIONS}
  T: Boolean;
{$ENDIF}
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;

{$IFDEF TSTRINGS_HAS_OPTIONS}
    T := Lines.TrailingLineBreak;
    Lines.TrailingLineBreak := True; // 要保留末尾的回车换行免得下一行被拎上来
{$ENDIF}
    Text := StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]);
{$IFDEF TSTRINGS_HAS_OPTIONS}
    Lines.TrailingLineBreak := T;
{$ENDIF}

    Writer := View.Buffer.CreateUndoableWriter;
    try
      Writer.CopyTo(StartPos);
  {$IFDEF UNICODE}
      S := ConvertTextToEditorTextW(Text);
  {$ELSE}
      S := ConvertTextToEditorText(Text);
  {$ENDIF}
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Insert %d AnsiChars to %d -> %d', [Length(S), StartPos, EndPos]);
{$ENDIF}
      Writer.Insert(PAnsiChar(S));
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

function IdeGetSourceByFileName(const FileName: string): string;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Strm, True); // Ansi/Ansi/Utf16
    // 得到 Ansi/Ansi/Utf16 内容，对应直接转成 string
    Result := string(PChar(Strm.Memory));
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

// 判断标识符是否在光标下
function IsGeneralCurrentToken(AView: Pointer; AControl: TControl;
  Token: TCnGeneralPasToken): Boolean;
begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Result := IsCurrentTokenW(AView, AControl, Token);
{$ELSE}
  Result := IsCurrentToken(AView, AControl, Token);
{$ENDIF}
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

// 判断标识符是否在光标下，使用 WideToken，可供 Unicode/Utf8 环境下调用
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

  // 行相等才需要比较列，并且由于 CursorPos 是 ANSI 的光标位置，
  // 所以得把 Utf16 转成 Ansi 来比较
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol +
    CalcAnsiDisplayLengthFromWideString(Token.Token));
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
  I: Integer;
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
      for I := 0 to AList.Count - 1 do
      begin
      {$IFDEF COMPILER6_UP}
        AObj := TPersistent(AList[I]);
      {$ELSE}
        AObj := TryExtractPersistent(AList[I]);
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

{$ENDIF}

// 取得当前是否是嵌入式设计窗体模式
function IdeGetIsEmbeddedDesigner: Boolean;
{$IFDEF BDS}
{$IFNDEF DELPHI104_SYDNEY_UP}
var
  S: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF BDS}
  {$IFDEF DELPHI104_SYDNEY_UP} // 10.4.1 以上，无嵌入式设计器选项，默认都嵌入了
  Result := True;
  {$ELSE}
  S := CnOtaGetEnvironmentOptions.Values['EmbeddedDesigner'];
  Result := S = 'True';
  {$ENDIF}
{$ELSE}
  Result := False;  // D7 以下或 Lazarus 不支持嵌入
{$ENDIF}
end;

//==============================================================================
// 修改自 GExperts Src 1.12 的 IDE 相关函数
//==============================================================================

// 返回 IDE 主窗体（TAppBuilder 或 TMainIDEBar）
function GetIDEMainForm: TCustomForm;
begin
  Assert(Assigned(Application));
{$IFDEF STAND_ALONE}
  Result := CnStubRefMainForm;
{$ELSE}
{$IFDEF LAZARUS}
  Result := Application.FindComponent('MainIDE') as TCustomForm;
{$ELSE}
  Result := Application.FindComponent('AppBuilder') as TCustomForm;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find IDE Main Form!');
{$ENDIF}
end;

{$IFDEF DELPHI_OTA}

// 取 IDE 版本
function GetIDEEdition: string;
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

  MainForm := GetIDEMainForm;
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

  MainForm := GetIDEMainForm;
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

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find New ComponentPalette Panel!');
{$ENDIF}
end;

// 返回编辑器窗口下方的状态栏，可能为空
function GetEditWindowStatusBar(EditWindow: TCustomForm = nil): TStatusBar;
var
  AComp: TComponent;
begin
  Result := nil;
  if EditWindow = nil then
    EditWindow := CnOtaGetCurrentEditWindow;

  if EditWindow = nil then
    Exit;

  AComp := EditWindow.FindComponent(SCnEditorStatusBarName);
  if (AComp <> nil) and (AComp is TStatusBar) then
    Result := AComp as TStatusBar;
end;

// 返回对象检查器窗体，可能为空
function GetObjectInspectorForm: TCustomForm;
begin
  Result := GetIDEMainForm;
  if Result <> nil then  // 大部分版本下 ObjectInspector 是 AppBuilder 的子控件
    Result := TCustomForm(Result.FindComponent(SCnPropertyInspectorName));
  if Result = nil then // D2007 或某些版本下 ObjectInspector 是 Application 的子控件
    Result := TCustomForm(Application.FindComponent(SCnPropertyInspectorName));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find Object Inspector!');
{$ENDIF}
end;

// 返回组件面板右键菜单，可能为空
function GetComponentPalettePopupMenu: TPopupMenu;
var
  MainForm: TCustomForm;
begin
  Result := nil;
  MainForm := GetIDEMainForm;
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
  I: Integer;
begin
  Result := nil;

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    for I := 0 to MainForm.ComponentCount - 1 do
      if MainForm.Components[I] is TControlBar then
      begin
        Result := MainForm.Components[I] as TControlBar;
        Break;
      end;
      
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find ControlBar!');
{$ENDIF}
end;

function GetExpandableEvalViewForm: TCustomForm;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if Screen.CustomForms[I].ClassNameIs(SCnExpandableEvalViewClassName) then
    begin
      Result := Screen.CustomForms[I];
      Exit;
    end;
  end;
  Result := nil;
end;

function GetIDEInsightBar: TWinControl;
{$IFDEF IDE_HAS_INSIGHT}
var
  MainForm: TCustomForm;
  AComp: TComponent;
{$ENDIF}
begin
  Result := nil;
{$IFDEF IDE_HAS_INSIGHT}
  MainForm := GetIDEMainForm;
  if MainForm <> nil then
  begin
    AComp := MainForm.FindComponent(SCnIDEInsightBarName);
    if (AComp is TWinControl) and (AComp.ClassNameIs(SCnIDEInsightBarClassName)) then
      Result := TWinControl(AComp);
  end;
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
  MainForm := GetIDEMainForm;
  Component := nil;
  if MainForm <> nil then
    Component := MainForm.FindComponent('MenuBar');
  if (Component is TControl) then
    Result := TControl(Component).ClientHeight; // This is approximate?
{$ELSE}
  Result := GetSystemMetrics(SM_CYMENU);
{$ENDIF}
end;

{$ENDIF}

// 判断指定窗体是否是设计期窗体
function IsIdeDesignForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (csDesigning in AForm.ComponentState);
end;

// 判断指定窗体是否编辑器窗体
function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and
{$IFDEF LAZARUS}
            (AForm.Name = SCnEditorFormName) and
{$ELSE}
            (Pos(SCnEditorFormNamePrefix, AForm.Name) = 1) and
{$ENDIF}
            (AForm.ClassName = SCnEditorFormClassName) and
            (not (csDesigning in AForm.ComponentState));
end;

// 将源码编辑器设为活跃
procedure BringIdeEditorFormToFront;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      Screen.CustomForms[I].BringToFront;
      Exit;
    end;
  end;
end;

// 取已安装的包和组件
procedure GetInstalledComponents(Packages, Components: TStrings);
{$IFNDEF STAND_ALONE}
var
{$IFDEF FPC}
  Pkg: TIDEPackage;
  Comp: TRegisteredComponent;
{$ELSE}
  PackSvcs: IOTAPackageServices;
{$ENDIF}
  I, J: Integer;
{$ENDIF}
begin
  if Assigned(Packages) then
    Packages.Clear;
  if Assigned(Components) then
    Components.Clear;
{$IFNDEF STAND_ALONE}
{$IFDEF FPC}
  for I := 0 to PackageEditingInterface.GetPackageCount - 1 do
  begin
    Pkg := PackageEditingInterface.GetPackages(I);
    if Assigned(Packages) then
      Packages.Add(Pkg.Name);

    if Assigned(Components) then
    begin
      for J := 0 to IDEComponentPalette.Comps.Count - 1 do
      begin
        Comp := IDEComponentPalette.Comps[J];
        Components.Add(Comp.ComponentClass.ClassName);
      end;
    end;
  end;
{$ELSE}
  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    if Assigned(Packages) then
      Packages.Add(PackSvcs.PackageNames[I]);
    if Assigned(Components) then
    begin
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        Components.Add(PackSvcs.ComponentNames[I, J]);
    end;
  end;
{$ENDIF}
{$ENDIF}
end;

// 判断指定控件是否代码编辑器控件
function IsEditControl(AControl: TComponent): Boolean;
{$IFDEF USE_CODEEDITOR_SERVICE}
var
  CES: INTACodeEditorServices;
{$ENDIF}
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if (AControl is TWinControl) and Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    Result := CES.IsIDEEditor(TWinControl(AControl));
{$ELSE}
  Result := (AControl <> nil) and AControl.ClassNameIs(SCnEditControlClassName)
    and {$IFDEF LAZARUS} (Pos(SCnEditControlNamePrefix, AControl.Name) = 1)
    {$ELSE} SameText(AControl.Name, SCnEditControlName) {$ENDIF};
{$ENDIF}
end;

// 枚举 IDE 中的代码编辑器窗口和 EditControl 控件，调用回调函数，返回总数
function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean): Integer;
var
  I: Integer;
  EditWindow: TCustomForm;
  EditControl: TControl;
{$IFDEF LAZARUS}
  J: Integer;
  List: TObjectList;
{$ENDIF}
begin
  Result := 0;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      EditWindow := Screen.CustomForms[I];
{$IFDEF LAZARUS}
      List := TObjectList.Create(False);
      try
        GetEditControlsFromEditorForm(EditWindow, List);
        if List.Count > 0 then
        begin
          for J := 0 to List.Count - 1 do
          begin
            EditControl := TControl(List[J]);
            if Assigned(EditControl) or not EditorMustExists then
            begin
              Inc(Result);
              if Assigned(Proc) then
                Proc(EditWindow, EditControl, Context);
            end;
          end;
        end;
      finally
        List.Free;
      end;
{$ELSE}
      EditControl := GetEditControlFromEditorForm(EditWindow);
      if Assigned(EditControl) or not EditorMustExists then
      begin
        Inc(Result);
        if Assigned(Proc) then
          Proc(EditWindow, EditControl, Context);
      end;
{$ENDIF}
    end;
  end;
end;

{$IFDEF LAZARUS}

// Lazarus 下返回编辑器窗口的编辑器控件列表
function GetEditControlsFromEditorForm(AForm: TCustomForm; EditControls: TObjectList): Integer;
var
  I: Integer;
begin
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is TControl then
    begin
      if IsEditControl(AForm.Components[I]) then
        EditControls.Add(AForm.Components[I]);
    end;
  end;

  Result := EditControls.Count;
end;

{$ELSE}

// 返回编辑器窗口的编辑器控件
function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
begin
{$IFDEF LAZARUS}
  Result := TControl(FindComponentByClassName(AForm, SCnEditControlClassName));
  if Result <> nil then
    if Pos(SCnEditControlNamePrefix, Result.Name) <> 1 then
      Result := nil;
{$ELSE}
  Result := TControl(FindComponentByClassName(AForm, SCnEditControlClassName,
    SCnEditControlName));
{$ENDIF}
end;

{$ENDIF}

// 返回当前的代码编辑器控件
function GetCurrentEditControl: TControl;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  I: Integer;
  EditWindow: TCustomForm;
  Pgc: TPageControl;
  Tb: TTabSheet;
{$ELSE}
  View: IOTAEditView;
{$ENDIF}
{$ENDIF}
begin
  Result := nil;
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      EditWindow := Screen.CustomForms[I];
      Pgc := TPageControl(FindComponentByClassName(EditWindow,
        SCnEditWindowPageControlClassName, SCnEditWindowPageControlName));
      if Pgc <> nil then
      begin
        Tb := Pgc.ActivePage;
        if Tb <> nil then
          Result := TControl(FindControlByClassName(Tb, SCnEditControlClassName));
      end;
    end;
  end;
{$ELSE}
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.GetEditWindow <> nil) then
    Result := GetEditControlFromEditorForm(View.GetEditWindow.Form);
{$ENDIF}
{$ENDIF}
end;

type
  TCnProjPathType = (pptSrc, pptUnit, pptLib, pptInclude);
  {* pptSrc 和 pptUnit 对应 UnitDir，也就是 Unit Search Path，
     pptInclude 对应 IncludeDir，也就是 $I 等的文件}

procedure AddProjectPath(Project: TCnIDEProjectInterface; Paths: TStrings; PathType: TCnProjPathType);
{$IFNDEF STAND_ALONE}
var
  IDStr, APath: string;
  APaths: TStrings;
  I: Integer;

  function GetProjPathIDFromType(APathType: TCnProjPathType): string;
  begin
    case APathType of
      pptSrc: Result := 'SrcDir';
      pptUnit: Result := 'UnitDir';
      pptLib: Result := 'LibPath';
      pptInclude: Result := 'IncludePath';
    else
      Result := 'LibPath';
    end;
  end;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if not Assigned(Project.LazCompilerOptions) then
    Exit;

  case PathType of
    pptSrc: APath := Project.LazCompilerOptions.SrcPath;
    pptUnit: APath := Project.LazCompilerOptions.OtherUnitFiles;
    pptLib: APath := Project.LazCompilerOptions.Libraries;
    pptInclude: APath := Project.LazCompilerOptions.IncludePath;
  end;

  if APath <> '' then
  begin
    // TODO: 多个路径里替换宏

    // 处理路径中的相对路径
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for I := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[I]) <> '' then   // 无效目录
        begin
          APath := MakePath(Trim(APaths[I]));
          if (Length(APath) > 2) and (APath[2] = ':') then // 全路径目录
          begin
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end
          else  // 相对路径
          begin
            APath := LinkPath(_CnExtractFilePath(Project.Directory), APath);
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;
{$ELSE}
  if not Assigned(Project.ProjectOptions) then
    Exit;

  IDStr := GetProjPathIDFromType(PathType);
  APath := Project.ProjectOptions.GetOptionValue(IdStr);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('AddProjectPath: %s '#13#10 + APath, [IdStr]);
{$ENDIF}

  if APath <> '' then
  begin
    APath := ReplaceToActualPath(APath, Project); // 多个路径也一并替换

    // 处理路径中的相对路径
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for I := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[I]) <> '' then   // 无效目录
        begin
          APath := MakePath(Trim(APaths[I]));
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
{$ENDIF}
{$ENDIF}
end;

// 取环境设置中的 LibraryPath 内容，注意 XE2 以上版本，GetEnvironmentOptions 里头
// 得到的值并不是当前工程的 Platform 对应的值，所以只能改成根据工程平台从注册表里读。
procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean);
var
{$IFDEF DELPHI_OTA}
  Svcs: IOTAServices;
  Options: IOTAEnvironmentOptions;
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform: string;
  Project: IOTAProject;
{$ENDIF}
{$ENDIF}
  Text: string;
  List: TStrings;


  procedure AddList(AList: TStrings);
  var
    S: string;
    I: Integer;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      S := Trim(MakePath(AList[I]));
      if (S <> '') and (Paths.IndexOf(S) < 0) then
        Paths.Add(S);
    end;
  end;

begin
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if IDEEnvironmentOptions = nil then
    Exit;
{$ELSE}
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
{$ENDIF}

  List := TStringList.Create;
  try
{$IFDEF LAZARUS}
    // 拿环境里的 FPC 的 source 目录，以及 lcl 目录
    Text := LinkPath(_CnExtractFilePath(IDEEnvironmentOptions.GetParsedCompilerFilename), '..\..\source\rtl\');
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    Text := MakePath(IDEEnvironmentOptions.GetParsedLazarusDirectory) + 'lcl\';
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    Text := MakePath(IDEEnvironmentOptions.GetParsedLazarusDirectory) + 'components\';
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);
{$ELSE}
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
{$ENDIF}

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
{$ENDIF}
end;

// 取当前工程组的相关 Path 内容
procedure GetProjectLibPath(Paths: TStrings);
var
{$IFDEF DELPHI_OTA}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
  Project: TCnIDEProjectInterface;
  Path: string;
  I, J: Integer;
  APaths: TStrings;
begin
  Paths.Clear;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('GetProjectLibPath');
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  // 把当前工程的几个路径都加进来
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    AddProjectPath(Project, Paths, pptSrc);
    AddProjectPath(Project, Paths, pptUnit);
    AddProjectPath(Project, Paths, pptLib);
    AddProjectPath(Project, Paths, pptInclude);

    for I := 0 to Project.FileCount - 1 do
    begin
      Path := _CnExtractFileDir(Project.Files[I].Filename);
      if Paths.IndexOf(Path) < 0 then
        Paths.Add(Path);
    end;
  end;

{$ELSE}
  // 处理当前工程组中的路径设置
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
  begin
    APaths := TStringList.Create;
    try
      for I := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[I];
        if Assigned(Project) then
        begin
          // 增加工程搜索路径
          AddProjectPath(Project, Paths, pptSrc);
          AddProjectPath(Project, Paths, pptUnit);
          AddProjectPath(Project, Paths, pptLib);
          AddProjectPath(Project, Paths, pptInclude);

          // 增加工程中文件的路径
          for J := 0 to Project.GetModuleCount - 1 do
          begin
            Path := _CnExtractFileDir(Project.GetModule(J).FileName);
            if Paths.IndexOf(Path) < 0 then
              Paths.Add(Path);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
  CnDebugger.LogLeave('GetProjectLibPath');
{$ENDIF}
end;

function GetProjectDcuPath(AProject: TCnIDEProjectInterface): string;
begin
{$IFDEF STAND_ALONE}
  Result := '';
{$ELSE}
{$IFDEF LAZARUS}
  if (AProject <> nil) and (AProject.LazCompilerOptions <> nil) then
  begin
    Result := AProject.LazCompilerOptions.GetUnitOutputDirectory(True);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
  {$ENDIF}
  end;
{$ELSE}
  if (AProject <> nil) and (AProject.ProjectOptions <> nil) then
  begin
    Result := ReplaceToActualPath(AProject.ProjectOptions.Values['UnitOutputDir'], AProject);
    if Result <> '' then
      Result := MakePath(LinkPath(_CnExtractFilePath(AProject.FileName), Result));
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
  {$ENDIF}
  end
  else
    Result := '';
{$ENDIF}
{$ENDIF}
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
      if Ctrl.ClassNameIs(SCnEditControlClassName) then
        Result := epCode
      else if Ctrl.ClassNameIs(SCnDisassemblyViewClassName) then
        Result := epCPU
      else if Ctrl.ClassNameIs(SCnDesignControlClassName) then
        Result := epDesign
      else if Ctrl.ClassNameIs(SCnWelcomePageClassName) then
        Result := epWelcome;
      Break;
    end;
  end;
end;

// 判断一 Control 是否是设计期 Control
function IsDesignControl(AControl: TControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl is TControl) and
    (csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
    not (AControl is TCustomForm) and not (AControl is TCustomFrame) and
    ((AControl.Owner is TCustomForm) or (AControl.Owner is TCustomFrame)) and
    (csDesigning in AControl.Owner.ComponentState);
end;

// 判断一 WinControl 是否是设计期 Control
function IsDesignWinControl(AControl: TWinControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl is TWinControl) and
    (csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
    not (AControl is TCustomForm) and not (AControl is TCustomFrame) and
    ((AControl.Owner is TCustomForm) or (AControl.Owner is TCustomFrame)) and
    (csDesigning in AControl.Owner.ComponentState);
end;

// 判断指定控件是否编辑器窗口的 TabControl 控件
function IsXTabControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(SCnXTabControlClassName)
    and SameText(AControl.Name, SCnXTabControlName);
end;

{$IFDEF DELPHI_OTA}

procedure CloseExpandableEvalViewForm;
var
  F: TCustomForm;
begin
  F := GetExpandableEvalViewForm;
  if F <> nil then
    F.Close;
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
// 取得 BDS (Delphi8/9及以上) 的用户数据目录
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
{$IFDEF DELPHI102_TOKYO}
  Result := Result + 'Embarcadero\BDS\19.0';
{$ELSE}
{$IFDEF DELPHI103_RIO}
  Result := Result + 'Embarcadero\BDS\20.0';
{$ELSE}
{$IFDEF DELPHI104_SYDNEY}
  Result := Result + 'Embarcadero\BDS\21.0';
{$ELSE}
{$IFDEF DELPHI110_ALEXANDRIA}
  Result := Result + 'Embarcadero\BDS\22.0';
{$ELSE}
{$IFDEF DELPHI120_ATHENS}
  Result := Result + 'Embarcadero\BDS\23.0';
{$ELSE}
{$IFDEF DELPHI130_FLORENCE}
  Result := Result + 'Embarcadero\BDS\37.0';
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
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;
{$ENDIF}

// 根据模块名获得完整文件名
function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
var
  SearchType: TCnModuleSearchType;
begin
  SearchType := mstInvalid;
  Result := GetFileNameSearchTypeFromModuleName(AName, SearchType, AProject);
end;

// 根据模块名获得完整文件名以及处于哪一类搜索目录中
function GetFileNameSearchTypeFromModuleName(AName: string;
  var SearchType: TCnModuleSearchType; AProject: IOTAProject = nil): string;
var
  Paths: TStringList;
  I, ProjectSrcIdx: Integer;
  Ext, ProjectPath: string;
begin
  if AProject = nil then
    AProject := CnOtaGetCurrentProject;

  Ext := LowerCase(_CnExtractFileExt(AName));
  if (Ext = '') or (Ext <> '.pas') then
    AName := AName + '.pas';

  Result := '';
  SearchType := mstInvalid;

  // 在工程模块中查找
  if AProject <> nil then
  begin
    for I := 0 to AProject.GetModuleCount - 1 do
    begin
      if SameFileName(_CnExtractFileName(AProject.GetModule(I).FileName), AName) then
      begin
        Result := AProject.GetModule(I).FileName;
        SearchType := mstInProject;
        Exit;
      end;
    end;

    ProjectPath := MakePath(_CnExtractFilePath(AProject.FileName));
    if FileExists(ProjectPath + AName) then
    begin
      Result := ProjectPath + AName;
      SearchType := mstInProject;
      Exit;
    end;
  end;

  Paths := TStringList.Create;
  try
    if Assigned(AProject) then  // 加入工程搜索路径
      AddProjectPath(AProject, Paths, pptSrc);

    ProjectSrcIdx := Paths.Count; // 前 ProjectSrcIdx 个，也就是 0 到 ProjectSrcIdx - 1 是工程搜索路径

    // 加入系统搜索路径
    GetLibraryPath(Paths, False);

    for I := 0 to Paths.Count - 1 do
    begin
      if FileExists(MakePath(Paths[I]) + AName) then
      begin
        Result := MakePath(Paths[I]) + AName;
        if I >= ProjectSrcIdx then        // 系统路径里找到的
          SearchType := mstSystemSearch
        else
          SearchType := mstProjectSearch; // 工程路径里找到的
        Exit;
      end;
    end;
  finally
    Paths.Free;
  end;
end;

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

// 编译工程，返回编译是否成功
function CompileProject(AProject: IOTAProject): Boolean;
begin
  Result := not AProject.ProjectBuilder.ShouldBuild or
    AProject.ProjectBuilder.BuildProject(cmOTAMake, False);
end;

// 返回当前正在编译的工程，注意不一定是当前工程
function GetCurrentCompilingProject: IOTAProject;
begin
  Result := CnWizNotifierServices.GetCurrentCompilingProject;
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

function GetIDERegistryFont(const RegItem: string; AFont: TFont;
  out BackgroundColor: TColor; CheckBackDef: Boolean): Boolean;
const
  SCnIDEFontName = 'Editor Font';
  SCnIDEFontSize = 'Font Size';

  SCnIDEBold = 'Bold';
  SCnIDEDefaultBackground = 'Default Background';

  {$IFDEF COMPILER7_UP}
  SCnIDEForeColor = 'Foreground Color New';
  SCnIDEBackColor = 'Background Color New';
  {$ELSE}
  SCnIDEForeColor = 'Foreground Color';
  SCnIDEBackColor = 'Background Color';
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
  if WizOptions = nil then
    Exit;

  if AFont <> nil then
  begin
    Reg := nil;
    try
      Reg := TRegistry.Create;
      Reg.RootKey := HKEY_CURRENT_USER;
      try
        if RegItem = '' then // 是基本字体，没有读颜色设置
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
        else  // 是高亮字体，有前景色读取和背景色读取，因为 TFont 没有背景色，因而搁 BackgroundColor 变量中
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
            if Reg.ValueExists(SCnIDEBackColor) then
            begin
              Result := True;
{$IFDEF COMPILER7_UP}
              AColorStr := Reg.ReadString(SCnIDEBackColor);
              if IdentToColor(AColorStr, AColor) then
                BackgroundColor := AColor
              else
                BackgroundColor := StrToIntDef(AColorStr, 0);
{$ELSE}
              // D5/6 的颜色是 16 色索引号
              AColor := Reg.ReadInteger(SCnIDEBackColor);
              if AColor in [0..15] then
              begin
                if CheckBackDef then // 该条目里，Default Background 为 False 时表示有背景色，此选项才有效，才返回
                begin
                  if Reg.ValueExists(SCnIDEDefaultBackground) then
                  begin
                    // 其他 -1 这些字符串都算 True
                    if LowerCase(Reg.ReadString(SCnIDEDefaultBackground)) = 'false' then
                      BackgroundColor := SCnColor16Table[AColor];
                  end;
                end
                else
                  BackgroundColor := SCnColor16Table[AColor];
              end;
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

// 返回编辑器窗口的 CPU 查看器控件
function GetCPUViewFromEditorForm(AForm: TCustomForm): TControl;
begin
  Result := TControl(FindComponentByClassName(AForm, SCnDisassemblyViewClassName,
    SCnDisassemblyViewName));
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

// 返回编辑器窗口的 TabControl 控件
function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
begin
  Result := TXTabControl(FindComponentByClassName(AForm, SCnXTabControlClassName,
    SCnXTabControlName));
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

// 获取当前最前端编辑器的语法编辑按钮，注意语法编辑按钮存在不等于可见
function GetCurrentSyncButton: TControl;
var
  EditControl: TControl;
begin
  Result := nil;
  EditControl := GetCurrentEditControl;
  if EditControl <> nil then
    Result := TControl(EditControl.FindComponent(SSyncButtonName));
end;

// 获取当前最前端编辑器的语法编辑按钮是否可见，无按钮或不可见均返回 False
function GetCurrentSyncButtonVisible: Boolean;
var
  Button: TControl;
begin
  Result := False;
  Button := GetCurrentSyncButton;
  if Button <> nil then
    Result := Button.Visible;
end;

// 返回编辑器中的代码模板自动输入框
function GetCodeTemplateListBox: TControl;
begin
  Result := TControl(Application.FindComponent(SCodeTemplateListBoxName));
end;

// 返回编辑器中的代码模板自动输入框是否可见，无或不可见均返回 False
function GetCodeTemplateListBoxVisible: Boolean;
var
  Control: TControl;
begin
  Result := False;
  Control := GetCodeTemplateListBox;
  if Control <> nil then
    Result := Control.Visible;
end;

// 当前编辑器是否在语法块编辑模式下，不支持或不在块模式下返回 False
function IsCurrentEditorInSyncMode: Boolean;
{$IFDEF IDE_SYNC_EDIT_BLOCK}
var
  View: IOTAEditView;
{$ENDIF}
begin
  Result := False;
{$IFDEF IDE_SYNC_EDIT_BLOCK}
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.Block <> nil) then
    Result := View.Block.SyncMode <> smNone;
{$ENDIF}
end;

// 当前是否在键盘宏的录制或回放，不支持或不在返回 False
function IsKeyMacroRunning: Boolean;
var
  Key: IOTAKeyboardServices;
  Rec: IOTARecord;
begin
  Result := False;
  if Supports(BorlandIDEServices, IOTAKeyboardServices, Key) then
  begin
    Rec := Key.CurrentPlayback;
    if Rec <> nil then
      Result := Rec.IsPlaying or Rec.IsRecording;
  end;
end;

var
  CorIdeModule: HMODULE;

procedure InitIdeAPIs;
begin
{$IFNDEF STAND_ALONE}
  CorIdeModule := LoadLibrary(CorIdeLibName);
  Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

{$IFDEF BDS4_UP}
  BeginBatchOpenCloseProc := GetProcAddress(CorIdeModule, SBeginBatchOpenCloseName);
  Assert(Assigned(BeginBatchOpenCloseProc), 'Failed to load BeginBatchOpenCloseProc from CorIdeModule');

  EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName);
{$IFNDEF WIN64}
{$IFDEF DELPHI120_ATHENS_UP}
  if not Assigned(EndBatchOpenCloseProc) then // D12.1 改名了，再找一次
    EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName121);
{$ENDIF}
{$ENDIF}

  Assert(Assigned(EndBatchOpenCloseProc), 'Failed to load EndBatchOpenCloseProc from CorIdeModule');
{$ENDIF}
{$ENDIF}
end;

procedure FinalIdeAPIs;
begin
{$IFNDEF STAND_ALONE}
  if CorIdeModule <> 0 then
    FreeLibrary(CorIdeModule);
{$ENDIF}
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
  begin
  {$IFDEF WIN64}
    CnDebugger.LogFmt('Node ClassName %s. Value %16.16x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, NativeInt(Node)]);
  {$ELSE}
    CnDebugger.LogFmt('Node ClassName %s. Value %8.8x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, Integer(Node)]);
  {$ENDIF}
  end;
{$ENDIF}
  Result := TTreeNode(Node);
end;

// 将 IDE 内部使用的 TTreeControl的 Items 属性值的 TreeNodes 强行转换成公用的 TreeNodes
function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
begin
{$IFDEF DEBUG}
  if not (Nodes is TTreeNodes) then
  begin
  {$IFDEF WIN64}
    CnDebugger.LogFmt('Nodes ClassName %s. Value %16.16x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, NativeInt(Nodes)]);
  {$ELSE}
    CnDebugger.LogFmt('Nodes ClassName %s. Value %8.8x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, Integer(Nodes)]);
  {$ENDIF}
  end;
{$ENDIF}
  Result := TTreeNodes(Nodes);
end;

procedure ApplyThemeOnToolBar(ToolBar: TToolBar; Recursive: Boolean);
{$IFDEF IDE_SUPPORT_THEMING}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_THEMING}
  if CnThemeWrapper.CurrentIsDark then
  begin
    ToolBar.DrawingStyle := TTBDrawingStyle.dsGradient;
    ToolBar.GradientStartColor := csDarkBackgroundColor;
    ToolBar.GradientEndColor := csDarkBackgroundColor;
  end
  else
  begin
    ToolBar.DrawingStyle := TTBDrawingStyle.dsNormal;
    ToolBar.Color := clBtnface;
  end;

  if Recursive then
  begin
    for I := 0 to ToolBar.ControlCount - 1 do
    begin
      if ToolBar.Controls[I] is TToolBar then
        ApplyThemeOnToolbar(ToolBar.Controls[I] as TToolBar);
    end;
  end;
{$ENDIF}
end;

function GetErrorInsightRenderStyle: Integer;
{$IFDEF IDE_HAS_ERRORINSIGHT}
var
  V: Variant;
{$ENDIF}
begin
  // Env Options 里的 ErrorInsightMarks 值
{$IFDEF IDE_HAS_ERRORINSIGHT}
  V := CnOtaGetEnvironmentOptionValue(SCnErrorInsightRenderStyleKeyName);
  if VarToStr(V) = '' then
    Result := csErrorInsightRenderStyleNotSupport
  else
    Result := V;
{$ELSE}
  Result := csErrorInsightRenderStyleNotSupport;
{$ENDIF}
end;

procedure GetInfoProc(const Name: string; NameType: TNameType; Flags: Byte;
  Param: Pointer);
var
  Idx: Integer;
  Cpp: Boolean;
begin
  // 将单元名或头文件名替换成正确的大小写格式
  if NameType = ntContainsUnit then
  begin
    Cpp := PCnUnitsInfoRec(Param).IsCppMode;
    if not Cpp then
    begin
      Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name);
      if Idx >= 0 then
        PCnUnitsInfoRec(Param).Unsorted[Idx] := Name;
    end
    else
    begin
      Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name + '.hpp');
      if Idx >= 0 then
        PCnUnitsInfoRec(Param).Unsorted[Idx] := Name + '.hpp'
      else
      begin
        Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name + '.h');
        if Idx >= 0 then
          PCnUnitsInfoRec(Param).Unsorted[Idx] := Name + '.h'
      end;
    end;
  end;
end;

function GetModuleProc(HInstance: THandle; Data: Pointer): Boolean;
var
  Flags: Integer;
begin
  Result := True;
  try
    if FindResource(HInstance, 'PACKAGEINFO', RT_RCDATA) <> 0 then
      GetPackageInfo(HInstance, Data, Flags, GetInfoProc);
  except
    ;
  end;
end;

var
  FCurrFileType: TCnUsesFileType;
  FCurrSearchType: TCnModuleSearchType;
  FUnitCallback: TCnUnitCallback = nil;

procedure InternalDoFindFile(ASelf: TObject; const FileName: string; const Info:
  TSearchRec; var Abort: Boolean);
begin
  FUnitCallback(FileName, True, FCurrFileType, FCurrSearchType);
end;

function IdeEnumUsesIncludeUnits(UnitCallback: TCnUnitCallback; IsCpp: Boolean;
  SearchTypes: TCnModuleSearchTypes): Boolean;
var
  Paths: TStringList;
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
  FileName: string;
  I, J: Integer;
  FindCallBack: TFindCallback;
  A, B: Boolean;

  procedure EnumPaths(APaths: TStringList);
  var
    K: Integer;
  begin
    if IsCpp then
    begin
      FCurrFileType := uftCppHeader;
      for K := 0 to APaths.Count - 1 do
        FindFile(APaths[K], '*.h*', FindCallBack, nil, False, False);
    end
    else
    begin
      for K := 0 to APaths.Count - 1 do
      begin
        if APaths.Objects[K] = nil then // 有标记的话不搜 pas，譬如 Lib 目录
        begin
          FCurrFileType := uftPascalSource;
          FindFile(APaths[K], '*.pas', FindCallBack, nil, False, False);
        end;
        FCurrFileType := uftPascalDcu;
        FindFile(APaths[K], '*.dcu', FindCallBack, nil, False, False);
      end;
    end;
  end;

begin
  Result := False;
  if not Assigned(UnitCallback) then
    Exit;

  Paths := nil;
  try
    Paths := TStringList.Create;
    Paths.Sorted := True;

    FUnitCallback := UnitCallback;
    TMethod(FindCallBack).Code := @InternalDoFindFile;
    TMethod(FindCallBack).Data := nil;

    if mstSystemSearch in SearchTypes then
    begin
      Paths.Clear;
      FCurrSearchType := mstSystemSearch;
      GetLibraryPath(Paths, False);

      if IsCpp then
        Paths.Add(MakePath(GetInstallDir) + 'Include\')
      else
      begin
        Paths.Add(MakePath(GetInstallDir) + 'Lib\');
        Paths.Objects[Paths.Count - 1] := TObject(True); // 标记只搜 dcu
      end;

      EnumPaths(Paths);
    end;

    if mstProjectSearch in SearchTypes then
    begin
      Paths.Clear;
      FCurrSearchType := mstProjectSearch;

      GetProjectLibPath(Paths);
      EnumPaths(Paths);
    end;

    if mstInProject in SearchTypes then
    begin
      FCurrSearchType := mstInProject;
      ProjectGroup := CnOtaGetProjectGroup;
      if not Assigned(ProjectGroup) then
        Exit;

      for I := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[I];
        if not Assigned(Project) then
          Continue;

        for J := 0 to Project.GetModuleCount - 1 do
        begin
          FileName := Project.GetModule(J).FileName;
          if IsCpp then
          begin
            FileName := _CnChangeFileExt(FileName, '.h');
            A := FileExists(FileName);
            B := CnOtaIsFileOpen(FileName);
            if A or B then
              UnitCallback(FileName, A, uftCppHeader, mstInProject)
            else
            begin
              FileName := _CnChangeFileExt(FileName, '.hpp');
              A := FileExists(FileName);
              B := CnOtaIsFileOpen(FileName);
              if A or B then
                UnitCallback(FileName, A, uftCppHeader, mstInProject);
            end;
          end
          else
          begin
            A := FileExists(FileName);
            B := CnOtaIsFileOpen(FileName);

            if A or B then ; // 只 Pas 或 Dcu 通知 Callback
            begin
              if IsPas(FileName) then
                UnitCallback(FileName, A, uftPascalSource, mstInProject)
              else if IsDcu(FileName) then
                UnitCallback(FileName, A, uftPascalDcu, mstInProject);
            end;
          end;
        end;
      end;
    end;
    Result := True;
  finally
    Paths.Free;
  end;
end;

procedure CorrectCaseFromIdeModules(UnitFilesList: TStringList; IsCpp: Boolean);
var
  Data: TCnUnitsInfoRec;
begin
  { Use a sorted StringList for searching and copy this list to an unsorted list
    which is manipulated in GetInfoProc(). After that the unsorted list is
    copied back to the original sorted list. BinSearch is a lot faster than
    linear search. (by AHUser) }
  Data.IsCppMode := IsCpp;
  Data.Sorted := UnitFilesList;
  Data.Unsorted := TStringList.Create;
  try
    Data.Unsorted.Assign(UnitFilesList);
    Data.Unsorted.Sorted := False; // added to avoid exception
    EnumModules(GetModuleProc, @Data);
  finally
    UnitFilesList.Sorted := False;
    UnitFilesList.Assign(Data.Unsorted);
    UnitFilesList.Sorted := True;
    Data.Unsorted.Free;
  end;
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

//==============================================================================
// 组件面板封装类
//==============================================================================

{ TCnPaletteWrapper }

var
  FCnPaletteWrapper: TCnPaletteWrapper = nil;

function CnPaletteWrapper: TCnPaletteWrapper;
begin
{$IFDEF SUPPORT_PALETTE_ENHANCE}
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
      begin
        if FPageScroller.Controls[J].ClassNameIs('TPalette') then
        begin
          FPalette := FPageScroller.Controls[J] as TWinControl;
          Exit;
        end;
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
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  GetComponentImageFromNewPalette(Bmp, AComponentClassName);
  {$ELSE}
  GetComponentImageFromOldPalette(Bmp, AComponentClassName);
  {$ENDIF}
{$ENDIF}
end;

{$IFDEF SUPPORT_PALETTE_ENHANCE}

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

procedure TCnPaletteWrapper.GetComponentImageFromNewPalette(Bmp: TBitmap;
  const AComponentClassName: string);
var
{$IFDEF OTA_PALETTE_API}
  Item: IOTABasePaletteItem;
  Group: IOTAPaletteGroup;
  CI: IOTAComponentPaletteItem;
  Painter: INTAPalettePaintIcon;
  PAS: IOTAPaletteServices;
{$ELSE}
  I, J: Integer;
  S: string;
{$ENDIF}
begin
  if (Bmp = nil) or (AComponentClassName = '') then
    Exit;

{$IFDEF OTA_PALETTE_API}
  // 注意有 PALETTE_API 时还不一定有新的控件板，但至少新控件板能用这 API
  if Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        Item := Group.FindItemByName(AComponentClassName, True);
        if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI)
          and Supports(Item, INTAPalettePaintIcon, Painter) then
          Painter.Paint(Bmp.Canvas, 1, 1, pi24x24);
      end;
    end;
  end;
{$ELSE}
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
          S := ParseCompNameFromHint((FPalette.Controls[J] as TSpeedButton).Hint);
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
{$ENDIF}
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
            Result := ParseCompNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
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

function TCnPaletteWrapper.GetSelectedUnitName: string;
var
  S: string;
  AClass: TPersistentClass;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  {$IFDEF OTA_PALETTE_API}
  SelTool: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
  {$ELSE}
  I: Integer;
  {$ENDIF}
{$ENDIF}
begin
  Result := '';
  S := SelectedToolName;

  if S <> '' then
  begin
    AClass := GetClass(S);
    if (AClass <> nil) and (PTypeInfo(AClass.ClassInfo).Kind = TypInfo.tkClass) then
      Result := string(GetTypeData(PTypeInfo(AClass.ClassInfo)).UnitName);

    // 新型组件板下由于 FMX 等无法获得 Class 的，得另外想办法
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  {$IFDEF OTA_PALETTE_API}
    // 支持 PaletteAPI 的话直接获取
    if (Result = '') and Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
    begin
      if PAS <> nil then
      begin
        SelTool := PAS.SelectedTool;
        if (SelTool <> nil) and Supports(SelTool, IOTAComponentPaletteItem, CI) then
        begin
          if CI <> nil then
            Result := CI.UnitName;
        end;
      end;
    end;
  {$ELSE} // 如果不支持 PaletteAPI，则只能通过选择来实现，相当慢
    if Result = '' then
    begin
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := ParseUnitNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
            Exit;
          end;
        end;
      end;
    end;
  {$ENDIF}
{$ENDIF}
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

function TCnPaletteWrapper.GetUnitNameFromComponentClassName(
  const AClassName: string; const ATabName: string): string;
var
  AClass: TPersistentClass;
{$IFDEF OTA_PALETTE_API}
  Group, SubGroup: IOTAPaletteGroup;
  Item: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
{$ENDIF}
begin
  Result := '';
  AClass := GetClass(AClassName);
  if (AClass <> nil) and (PTypeInfo(AClass.ClassInfo).Kind = TypInfo.tkClass) then
    Result := string(GetTypeData(PTypeInfo(AClass.ClassInfo)).UnitName);

{$IFDEF DEBUG}
  if Result = '' then
    Cndebugger.LogMsg('GetUnitNameFromComponentClassName ' + AClassName + ' NOT Found.');
{$ENDIF}

{$IFDEF OTA_PALETTE_API}
  if (Result = '') and Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        if ATabName <> '' then
        begin
          // 如果有 Tab 名就找到 Tab 名的 Group 并找其符合名字的子 Item
          SubGroup := Group.FindItemGroupByName(ATabName);
          if SubGroup <> nil then
          begin
            Item := SubGroup.FindItemByName(AClassName, True);
            if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
              Result := CI.UnitName;
          end;
        end
        else
        begin
          // 没有 Tab 名就遍历子 Group 找其符合名字的子 Item
          Item := SubGroup.FindItemByName(AClassName, True);
          if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
              Result := CI.UnitName;
        end;
      end;
    end;
  end;
{$ELSE}
  if (Result = '') and SelectComponent(AClassName, ATabName) then
    Result := SelectedUnitName;
{$ENDIF}
end;

{$IFDEF OTA_PALETTE_API}

function TCnPaletteWrapper.GetUnitPackageNameFromComponentClassName(
  out UnitName: string; out PackageName: string; const AClassName: string;
  const ATabName: string): Boolean;
var
  Group, SubGroup: IOTAPaletteGroup;
  Item: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
begin
  Result := False;
  if Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        if ATabName <> '' then
        begin
          // 如果有 Tab 名就找到 Tab 名的 Group 并找其符合名字的子 Item
          SubGroup := Group.FindItemGroupByName(ATabName);
          if SubGroup <> nil then
          begin
            Item := SubGroup.FindItemByName(AClassName, True);
            if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
            begin
              UnitName := CI.UnitName;
              PackageName := CI.PackageName;
              Result := True;
            end;
          end;
        end
        else
        begin
          // 没有 Tab 名就遍历子 Group 找其符合名字的子 Item
          Item := SubGroup.FindItemByName(AClassName, True);
          if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
          begin
            UnitName := CI.UnitName;
            PackageName := CI.PackageName;
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

function TCnPaletteWrapper.GetVisible: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Visible
  else
    Result := False;
end;

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

const
  COMP_NAME_PREFIX = 'Name: ';
  UNIT_NAME_PREFIX = 'Unit: ';
  PACKAGE_NAME_PREFIX = 'Package: ';
  CRLF = #13#10;

function InternalParseContentFromHint(const Hint: string; const Pat: string): string;
var
  APos: Integer;
begin
  // 把控件板组件上某组件 SpeedButton 按钮的 Hint 里头的字段值解析出来
  {
    Hint 形如：
    Name: ComponentName
    Unit: UnitName
    Package: PackageName
  }
  Result := Hint;
  if Pat = '' then
    Exit;

  APos := Pos(Pat, Result);
  if APos > 0 then
    Delete(Result, 1, APos - 1 + Length(Pat));
  APos := Pos(CRLF, Result);
  if APos > 0 then
    Result := Copy(Result, 1, APos - 1);
end;

function TCnPaletteWrapper.ParseCompNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, COMP_NAME_PREFIX);
end;

function TCnPaletteWrapper.ParseUnitNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, UNIT_NAME_PREFIX);
end;

function TCnPaletteWrapper.ParsePackageNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, PACKAGE_NAME_PREFIX);
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
        S := ParseCompNameFromHint((FPalette.Controls[K] as TSpeedButton).Hint);
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

//==============================================================================
// 消息输出窗口封装类
//==============================================================================

{ TCnMessageViewWrapper }

var
  FCnMessageViewWrapper: TCnMessageViewWrapper = nil;

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

var
  FThemeWrapper: TCnThemeWrapper = nil;

function CnThemeWrapper: TCnThemeWrapper;
begin
  if FThemeWrapper = nil then
    FThemeWrapper := TCnThemeWrapper.Create;
  Result := FThemeWrapper;
end;

{ TCnThemeWrapper }

constructor TCnThemeWrapper.Create;
begin
  inherited;
{$IFDEF IDE_SUPPORT_THEMING}
  FSupportTheme := True;
{$ENDIF}
  FActiveThemeName := CnOtaGetActiveThemeName;
  FCurrentIsDark := FActiveThemeName = 'Dark';

  CnWizNotifierServices.AddAfterThemeChangeNotifier(ThemeChanged);
end;

destructor TCnThemeWrapper.Destroy;
begin
  CnWizNotifierServices.RemoveAfterThemeChangeNotifier(ThemeChanged);
  inherited;
end;

function TCnThemeWrapper.IsUnderDarkTheme: Boolean;
begin
  Result := FSupportTheme and FCurrentIsDark;
end;

function TCnThemeWrapper.IsUnderLightTheme: Boolean;
begin
  Result := FSupportTheme and FCurrentIsLight;
end;

procedure TCnThemeWrapper.ThemeChanged(Sender: TObject);
begin
  FActiveThemeName := CnOtaGetActiveThemeName;
  FCurrentIsDark := FActiveThemeName = 'Dark';
  FCurrentIsLight := FActiveThemeName = 'Light';
end;

procedure DisableWaitDialogShow;
begin
{$IFDEF IDE_SWITCH_BUG}
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  if not CnIsDelphi10Dot4GEDot2 then
    Exit;
  {$ENDIF}

  if FWaitDialogHook = nil then
  begin
    FDesignIdeHandle := GetModuleHandle(DesignIdeLibName);
    if FDesignIdeHandle <> 0 then
    begin
      OldWaitDialogShow := GetBplMethodAddress(GetProcAddress(FDesignIdeHandle, SWaitDialogShow));
      FWaitDialogHook := TCnMethodHook.Create(@OldWaitDialogShow, @MyWaitDialogShow);
    end;
  end;
  FWaitDialogHook.HookMethod;
{$ENDIF}
end;

procedure EnableWaitDialogShow;
begin
{$IFDEF IDE_SWITCH_BUG}
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  if not CnIsDelphi10Dot4GEDot2 then
    Exit;
  {$ENDIF}

  if FWaitDialogHook <> nil then
    FWaitDialogHook.UnhookMethod;
{$ENDIF}
end;

{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}

function GetControlCurrentPPI(AControl: TControl): Integer;
{$IFDEF FPC}
var
  P: TPoint;
  M: TMonitor;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := Screen.PixelsPerInch;
  try
    P := AControl.ClientToScreen(Point(0, 0));
    M := Screen.MonitorFromPoint(P);
    if M <> nil then
      Result := M.PixelsPerInch;
  except
    ;
  end;
{$ELSE}
  Result := AControl.CurrentPPI;
{$ENDIF}
end;

{$ENDIF}

function IdeGetScaledPixelsFromOrigin(APixels: Integer; AControl: TControl): Integer;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := APixels
  else
  begin
    Result := MulDiv(APixels, GetControlCurrentPPI(AControl), CN_DEF_SCREEN_DPI);
  end;
{$ELSE}
  Result := APixels; // IDE 不支持 HDPI 时原封不动地返回，交给 OS 处理
{$ENDIF}
end;

function IdeGetOriginPixelsFromScaled(APixels: Integer; AControl: TControl = nil): Integer;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := APixels
  else
  begin
    Result := MulDiv(APixels, CN_DEF_SCREEN_DPI, GetControlCurrentPPI(AControl));
  end;
{$ELSE}
  Result := APixels; // IDE 不支持 HDPI 时原封不动地返回
{$ENDIF}
end;

function IdeGetScaledFactor(AControl: TControl = nil): Single;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := 1.0
  else
  begin
    Result := GetControlCurrentPPI(AControl) / CN_DEF_SCREEN_DPI;
  end;
{$ELSE}
  Result := 1.0; // IDE 不支持 HDPI 时原封不动地返回，交给 OS 处理
{$ENDIF}
end;

procedure IdeSetReverseScaledFontSize(AControl: TControl);
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl <> nil then
  begin
  if not TControlHack(AControl).ParentFont
    {$IFNDEF FPC} and (sfFont in TControlHack(AControl).DefaultScalingFlags) {$ENDIF}
    then
    TControlHack(AControl).Font.Height := MulDiv(TControlHack(AControl).Font.Height,
      CN_DEF_SCREEN_DPI, GetControlCurrentPPI(AControl));
  end;
{$ENDIF}
end;

procedure IdeScaleToolbarComboFontSize(Combo: TControl);
begin
  // 高 DPI 下 Toolbar 中的 ComboBox 似乎会被自动放大，因此这里无需 IdeGetScaledPixelsFromOrigin
  if WizOptions.UseLargeIcon then
    TControlHack(Combo).Font.Size := csLargeComboFontSize;
end;

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}

function IdeGetVirtualImageListFromOrigin(Origin: TCustomImageList;
  AControl: TControl; IgnoreWizLargeOption: Boolean): TVirtualImageList;
var
  Idx: Integer;
  AVL: TVirtualImageList;
  AIC: TImageCollection;
begin
  Result := nil;
  if Origin = nil then
    Exit;

  if Origin.Count = 0 then
    Exit;

  Idx := FOriginImages.IndexOf(Origin);
  if (Idx >= 0) and (Idx < FVirtualImages.Count) then
  begin
    Result := TVirtualImageList(FVirtualImages[Idx]);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('IdeGetVirtualImageListFromOrigin Existing Result Index %d', [Idx]);
{$ENDIF}
    Exit;
  end;

  AVL := TVirtualImageList.Create(Application);
  AIC := TImageCollection.Create(Application);
  AVL.ImageCollection := AIC;

  FOriginImages.Add(Origin);
  FVirtualImages.Add(AVL);
  FImageCollections.Add(AIC);

  if WizOptions.UseLargeIcon and not IgnoreWizLargeOption then
  begin
    AVL.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth, AControl);
    AVL.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight, AControl);
  end
  else
  begin
    AVL.Width := IdeGetScaledPixelsFromOrigin(Origin.Width, AControl);
    AVL.Height := IdeGetScaledPixelsFromOrigin(Origin.Height, AControl);
  end;

  CopyImageListToVirtual(Origin, AVL);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('IdeGetVirtualImageListFromOrigin New Result Index %d', [FVirtualImages.Count - 1]);
{$ENDIF}
  Result := AVL;
end;

{$ENDIF}
{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF CNWIZARDS_MINIMUM}

{$IFDEF DELPHI_OTA}

function SearchUsesInsertPosInPasFile(const FileName: string; IsIntf: Boolean;
  out HasUses: Boolean; out LinearPos: Integer): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralWidePasLex;
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfPos, ImplPos: Integer;
begin
  Result := False;
  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfPos := 0;
  ImplPos := 0;

  Stream := nil;
  Lex := nil;

  try
    Stream := TMemoryStream.Create;
    CnGeneralFilerSaveFileToStream(FileName, Stream);

    Lex := TCnGeneralWidePasLex.Create;
    Lex.Origin := Stream.Memory;

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // 到达了自己需要的 uses 处
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // 插入位置就在分号前
              Result := True;
              LinearPos := Lex.TokenPos;
              Exit;
            end
            else // uses 后找不着分号，出错
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface, tkProgram:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;

          IntfPos := Lex.TokenPos;
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;

          ImplPos := Lex.TokenPos;
        end;
      end;
      Lex.Next;
    end;

    // 解析完毕，到此处是没有 uses 的情形
    if IsIntf and MeetIntf then    // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      LinearPos := IntfPos + Length('interface');
    end
    else if not IsIntf and MeetImpl then // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      LinearPos := ImplPos + Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

function SearchUsesInsertPosInCurrentPas(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralPasLex;
{$IFDEF UNICODE}
  LineText: string;
  S: AnsiString;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  LineText: string;
  S: AnsiString;
  {$ENDIF}
{$ENDIF}
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfLine, ImplLine: Integer;
begin
  Result := False;
  Stream := TMemoryStream.Create;

  // 这里可优化成 General 系列，不过先不整
{$IFDEF UNICODE}
  Lex := TCnPasWideLex.Create;
  CnOtaSaveCurrentEditorToStreamW(Stream, False);
{$ELSE}
  Lex := TmwPasLex.Create;
  CnOtaSaveCurrentEditorToStream(Stream, False);
{$ENDIF}

  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfLine := 0;
  ImplLine := 0;

  CharPos.Line := 0;
  CharPos.CharIndex := -1;

  try
{$IFDEF UNICODE}
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // 到达了自己需要的 uses 处
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // 插入位置就在分号前
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // 不明白 Unicode 环境里的 TOTACharPos 为什么也需要做 Utf8 转换
{$ELSE}
              CharPos.Line := Lex.LineNumber + 1;
              CharPos.CharIndex := Lex.TokenPos - Lex.LinePos;
  {$IFDEF IDE_STRING_ANSI_UTF8}
              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));
  {$ENDIF}
{$ENDIF}
              Exit;
            end
            else // uses 后找不着分号，出错
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface, tkProgram:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;
{$IFDEF UNICODE}
          IntfLine := Lex.LineNumber;
{$ELSE}
          IntfLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;
{$IFDEF UNICODE}
          ImplLine := Lex.LineNumber;
{$ELSE}
          ImplLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      end;
      Lex.Next;
    end;

    // 解析完毕，到此处是没有 uses 的情形
    if IsIntf and MeetIntf then    // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      CharPos.Line := ImplLine;
      CharPos.CharIndex := Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

function SearchUsesInsertPosInCurrentCpp(out CharPos: TOTACharPos;
  SourceEditor: IOTASourceEditor = nil): Boolean;
var
  Stream: TMemoryStream;
  LastIncLine: Integer;
{$IFDEF UNICODE}
  CParser: TCnBCBWideTokenList;
{$ELSE}
  CParser: TBCBTokenList;
{$ENDIF}
begin
  // 插在最后一个 include 前面。如无 include，h 文件和 cpp 处理还不同。
  Result := False;
  Stream := nil;
  CParser := nil;

  try
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStreamW(SourceEditor, Stream, False);
    CParser.SetOrigin(PWideChar(Stream.Memory), Stream.Size div SizeOf(Char));
{$ELSE}
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStream(SourceEditor, Stream, False);
    CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}

    LastIncLine := -1;
    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
{$IFDEF UNICODE}
        LastIncLine := CParser.LineNumber;
{$ELSE}
        LastIncLine := CParser.RunLineNumber;
{$ENDIF}
      end;
      CParser.NextNonJunk;
    end;

    if LastIncLine >= 0 then
    begin
      Result := True;
      CharPos.Line := LastIncLine + 1; // 最后一个 inc 的行首
      CharPos.CharIndex := 0;
    end;
  finally
    CParser.Free;
    Stream.Free;
  end;
end;

function JoinUsesOrInclude(IsCpp, FileHasUses: Boolean; IsHFromSystem: Boolean;
  const IncFiles: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  if (IncFiles = nil) or (IncFiles.Count = 0) then
    Exit;

  if IsCpp then
  begin
    for I := 0 to IncFiles.Count - 1 do
    begin
      if IsHFromSystem then
        Result := Result + Format('#include <%s>' + #13#10, [IncFiles[I]])
      else
        Result := Result + Format('#include "%s"' + #13#10, [IncFiles[I]]);
    end;
  end
  else
  begin
    if FileHasUses then
    begin
      for I := 0 to IncFiles.Count - 1 do
        Result := Result + ', ' + IncFiles[I];
    end
    else
    begin
      Result := #13#10#13#10 + 'uses' + #13#10 + Spc(CnOtaGetBlockIndent) + IncFiles[0];
      for I := 1 to IncFiles.Count - 1 do
        Result := Result + ', ' + IncFiles[I];
      Result := Result + ';';
    end;
  end;
end;

{$ENDIF}

{$ENDIF}

initialization
{$IFDEF DELPHI_OTA}
  // 使用此全局变量可以避免频繁调用 IdeGetIsEmbeddedDesigner 函数
  IdeIsEmbeddedDesigner := IdeGetIsEmbeddedDesigner;
  InitIdeAPIs;
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  FOriginImages := TObjectList.Create(False);
  FVirtualImages := TObjectList.Create(False);
  FImageCollections := TObjectList.Create(False);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizIdeUtils.');
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizIdeUtils finalization.');
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  FImageCollections.Free;
  FVirtualImages.Free;
  FOriginImages.Free;
{$ENDIF}

{$IFDEF IDE_SWITCH_BUG}
  FWaitDialogHook.Free;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  if FCnPaletteWrapper <> nil then
    FreeAndNil(FCnPaletteWrapper);

  if FCnMessageViewWrapper <> nil then
    FreeAndNil(FCnMessageViewWrapper);

  if FThemeWrapper <> nil then
    FreeAndNil(FThemeWrapper);

  FinalIdeAPIs;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizIdeUtils finalization.');
{$ENDIF}
{$ENDIF}

end.

