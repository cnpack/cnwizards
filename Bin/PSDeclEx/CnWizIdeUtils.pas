{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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
* 单元名称：在脚本中使用的 CnIdeWizUtils 单元声明
* 单元作者：CnPack 开发组
* 备    注：本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
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
{* 返回组件面板对象，可能为空}

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

function CnPaletteWrapper: TCnPaletteWrapper;

function CnMessageViewWrapper: TCnMessageViewWrapper;

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

end.

