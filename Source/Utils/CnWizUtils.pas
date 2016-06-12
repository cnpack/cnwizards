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

unit CnWizUtils;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：公共运行期过程库单元
* 单元作者：CnPack 开发组
* 备    注：该单元定义了 CnWizards 专家包的公共过程库
*           该单元部分内容移植自 GExperts
*           其原始内容受 GExperts License 的保护
*           注意：IOTAEditBlock.Start/Ending/Column/Row 是 1 开始的。
*           IOTAEditView.Position.Move的参数，其 Col 也是 1 开始的。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.04 by liuxiao
*               加入一批 Unicode 版本的函数
*           2012.10.01 by shenloqi
*               修复CnOtaGetCurrLineText不能获取最后一行和未TrimRight的BUG
*               修复CnOtaInsertSingleLine不能正确在第一行插入的BUG
*           2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2005.05.06 by hubdog
*               追加设置项目属性值的函数，修改CnOtaGetActiveProjectOptions
*           2005.05.04 by hubdog
*               复制控件名称后，自动切换到代码模式
*           2002.09.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, Menus, ActnList,
  Forms, ImgList, ExtCtrls, ExptIntf, ToolsAPI, ComObj, IniFiles, FileCtrl,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner, Variants,
  {$ELSE}
  DsgnIntf, LibIntf,
  {$ENDIF}
  {$IFDEF DELPHIXE3_UP}Actions,{$ENDIF}
  Clipbrd, TypInfo, ComCtrls, StdCtrls, Imm, Contnrs, RegExpr, CnWizCompilerConst,
  CnWizConsts, CnCommon, CnConsts, CnWideStrings, CnWizClasses, CnWizIni;

type
  ECnWizardException = class(Exception);
  ECnDuplicateShortCutName = class(ECnWizardException);
  ECnDuplicateCommand = class(ECnWizardException);
  ECnEmptyCommand = class(ECnWizardException);

  TFormType = (ftBinary, ftText, ftUnknown);

{$IFNDEF COMPILER6_UP}
  IDesigner = IFormDesigner;
{$ENDIF}

  TCnBookmarkObject = class
  private
    FLine: Integer;
    FCol: Integer;
    FID: Integer;
  public
    property ID: Integer read FID write FID;
    property Line: Integer read FLine write FLine;
    property Col: Integer read FCol write FCol;
  end;

const
  CRLF = #13#10;
  SAllAlphaNumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';

  InvalidNotifierIndex = -1;
  NonvisualClassNamePattern = 'TContainer';
  
  // 最大源代码行长度
  csMaxLineLength = 1023;

var
  CnNoIconList: TStrings;
  IdeClosing: Boolean;

//==============================================================================
// 公共信息函数
//==============================================================================

function CnIntToObject(AInt: Integer): TObject;
{* 供 Pascal Script 使用的将整型值转换成 TObject 的函数}
function CnObjectToInt(AObject: TObject): Integer;
{* 供 Pascal Script 使用的将 TObject 转换成整型值的函数}
function CnIntToInterface(AInt: Integer): IUnknown;
{* 供 Pascal Script 使用的将整型值转换成 TObject 的函数}
function CnInterfaceToInt(Intf: IUnknown): Integer;
{* 供 Pascal Script 使用的将 TObject 转换成整型值的函数}
function CnGetClassFromClassName(const AClassName: string): Integer;
{* 供 Pascal Script 使用的从类名获取类信息并转换成整型值的函数}
function CnGetClassFromObject(AObject: TObject): Integer;
{* 供 Pascal Script 使用的从对象获取类信息并转换成整型值的函数}
function CnGetClassNameFromClass(AClass: Integer): string;
{* 供 Pascal Script 使用的从整型的类信息获取类名的函数}
function CnGetClassParentFromClass(AClass: Integer): Integer;
{* 供 Pascal Script 使用的从整型的类信息获取父类信息的函数}

function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
{* 从资源或文件中装载图标，执行时先从图标目录中查找，如果失败再从资源中查找，
   返回结果为图标装载成功标志。参数 ResName 请不要带 .ico 扩展名}
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
{* 从资源或文件中装载位图，执行时先从图标目录中查找，如果失败再从资源中查找，
   返回结果为位图装载成功标志。参数 ResName 请不要带 .bmp 扩展名}
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
{* 增加图标到 ImageList 中，使用平滑处理}
function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
{* 创建一个 Disabled 的位图，返回对象需要调用方释放}
procedure AdjustButtonGlyph(Glyph: TBitmap);
{* Delphi 的按钮在 Disabled 状态时，显示的图像很难看，该函数通过在该位图的基础上
   创建一个新的灰度位图来解决这一问题。调整完成后 Glyph 宽度变为高度的两倍，需要
   设置 Button.NumGlyphs := 2 }
function SameFileName(const S1, S2: string): Boolean;
{* 文件名相同}
function CompressWhiteSpace(const Str: string): string;
{* 压缩字符串中间的空白字符}
procedure ShowHelp(const Topic: string);
{* 显示指定主题的帮助内容}
procedure CenterForm(const Form: TCustomForm);
{* 窗体居中}
procedure EnsureFormVisible(const Form: TCustomForm);
{* 保证窗体可见}
function GetCaptionOrgStr(const Caption: string): string;
{* 删除标题中热键信息}
function GetIDEImageList: TCustomImageList;
{* 取得 IDE 主 ImageList}
procedure SaveIDEImageListToPath(const Path: string);
{* 保存 IDE ImageList 中的图像到指定目录下}
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
{* 保存菜单名称列表到文件}
function GetIDEMainMenu: TMainMenu;
{* 取得 IDE 主菜单}
function GetIDEToolsMenu: TMenuItem;
{* 取得 IDE 主菜单下的 Tools 菜单}
function GetIDEActionList: TCustomActionList;
{* 取得 IDE 主 ActionList}
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
{* 取得 IDE 主 ActionList 中指定快捷键的 Action}
function GetIdeRootDirectory: string;
{* 取得 IDE 根目录}
function ReplaceToActualPath(const Path: string; Project: IOTAProject = nil): string;
{* 将 $(DELPHI) 这样的符号替换为 Delphi 所在路径}
procedure SaveIDEActionListToFile(const FileName: string);
{* 保存 IDE ActionList 中的内容到指定文件}
procedure SaveIDEOptionsNameToFile(const FileName: string);
{* 保存 IDE 环境设置变量名到指定文件}
procedure SaveProjectOptionsNameToFile(const FileName: string);
{* 保存当前工程环境设置变量名到指定文件}
function FindIDEAction(const ActionName: string): TContainedAction;
{* 根据 IDE Action 名，返回对象}
function ExecuteIDEAction(const ActionName: string): Boolean;
{* 根据 IDE Action 名，执行它}
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
{* 创建一个子菜单项}
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
{* 创建一个分隔菜单项}
procedure SortListByMenuOrder(List: TList);
{* 根据 TCnMenuWizard 列表中的 MenuOrder 值进行由小到大的排序}
function IsTextForm(const FileName: string): Boolean;
{* 返回 DFM 文件是否文本格式}
procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
{* 处理一些执行方法中的异常}
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
{* 在窗口控件中查找指定类的子组件}
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
{* 在窗口控件中查找指定类名的子组件}
function ScreenHasModalForm: Boolean;
{* 存在模式窗口}
procedure SetFormNoTitle(Form: TForm);
{* 去掉窗体的标题}
procedure SendKey(vk: Word);
{* 发送一个按键事件}
function IMMIsActive: Boolean;
{* 判断输入法是否打开}
function GetCaretPosition(var Pt: TPoint): Boolean;
{* 取编辑光标在屏幕的坐标}
procedure GetCursorList(List: TStrings);
{* 取Cursor标识符列表 }
procedure GetCharsetList(List: TStrings);
{* 取FontCharset标识符列表 }
procedure GetColorList(List: TStrings);
{* 取Color标识符列表 }
function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;
{* 使控件处理标准编辑快捷键 }

//==============================================================================
// 控件处理函数 
//==============================================================================

type
  TCnSelectMode = (smAll, smNone, smInvert);

function CnGetComponentText(Component: TComponent): string;
{* 返回组件的标题}
function CnGetComponentAction(Component: TComponent): TBasicAction;
{* 取控件关联的 Action }
procedure RemoveListViewSubImages(ListView: TListView); overload;
{* 更新 ListView 控件，去除子项的 SubItemImages }
procedure RemoveListViewSubImages(ListItem: TListItem); overload;
{* 更新 ListItem，去除子项的 SubItemImages }
function GetListViewWidthString(AListView: TListView): string;
{* 转换 ListView 子项宽度为字符串 }
procedure SetListViewWidthString(AListView: TListView; const Text: string);
{* 转换字符串为 ListView 子项宽度 }
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
{* ListView 当前选择项是否允许上移 }
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
{* ListView 当前选择项是否允许下移 }
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
{* 修改 ListView 当前选择项 }

//==============================================================================
// 运行期判断 IDE/BDS 是 Delphi 还是 C++Builder 还是别的
//==============================================================================

function IsDelphiRuntime: Boolean;
{* 用各种法子判断当前 IDE 是否是 Delphi(.NET)，是则返回 True，其他则返回 False}

function IsCSharpRuntime: Boolean;
{* 用各种法子判断当前 IDE 是否是 C#，是则返回 True，其他则返回 False}

function IsDelphiProject(Project: IOTAProject): Boolean;
{* 判断当前是否是 Delphi 工程}

//==============================================================================
// 文件名判断处理函数 (来自 GExperts Src 1.12)
//==============================================================================

resourcestring
  SCnDefDelphiSourceMask = '.PAS;.DPR';
  SCnDefCppSourceMask = '.CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';
  SCnDefSourceMask = '.PAS;.DPR;CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';

function CurrentIsDelphiSource: Boolean;
{* 当前编辑的文件是Delphi源文件}
function CurrentIsCSource: Boolean;
{* 当前编辑的文件是C源文件}
function CurrentIsSource: Boolean;
{* 当前编辑的文件是Delphi或C源文件}
function CurrentSourceIsDelphi: Boolean;
{* 当前编辑的源文件（非窗体）是Delphi源文件}
function CurrentSourceIsC: Boolean;
{* 当前编辑的源文件（非窗体）是C源文件}
function CurrentSourceIsDelphiOrCSource: Boolean;
{* 当前编辑的源文件（非窗体）是Delphi或C源文件}
function CurrentIsForm: Boolean;
{* 当前编辑的文件是窗体文件}
function IsVCLFormEditor(FormEditor: IOTAFormEditor = nil): Boolean;
{* 窗体编辑器对象是否 VCL 窗体（非 .NET 窗体）}
function ExtractUpperFileExt(const FileName: string): string;
{* 取大写文件扩展名}
procedure AssertIsDprOrPas(const FileName: string);
{* 假定是.Dpr或.Pas文件}
procedure AssertIsDprOrPasOrInc(const FileName: string);
{* 假定是.Dpr、.Pas或.Inc文件}
procedure AssertIsPasOrInc(const FileName: string);
{* 假定是.Pas或.Inc文件}
function IsSourceModule(const FileName: string): Boolean;
{* 判断是否Delphi或C++源文件}
function IsDelphiSourceModule(const FileName: string): Boolean;
{* 判断是否Delphi源文件}
function IsDprOrPas(const FileName: string): Boolean;
{* 判断是否.Dpr或.Pas文件}
function IsDpr(const FileName: string): Boolean;
{* 判断是否.Dpr文件}
function IsBpr(const FileName: string): Boolean;
{* 判断是否.Bpr文件}
function IsProject(const FileName: string): Boolean;
{* 判断是否.Bpr或.Dpr文件}
function IsBdsProject(const FileName: string): Boolean;
{* 判断是否.bdsproj文件}
function IsDProject(const FileName: string): Boolean;
{* 判断是否.dproj文件}
function IsCbProject(const FileName: string): Boolean;
{* 判断是否.cbproj文件}
function IsDpk(const FileName: string): Boolean;
{* 判断是否.Dpk文件}
function IsBpk(const FileName: string): Boolean;
{* 判断是否.Bpk文件}
function IsPackage(const FileName: string): Boolean;
{* 判断是否.Dpk或.Bpk文件}
function IsBpg(const FileName: string): Boolean;
{* 判断是否.Bpg文件}
function IsPas(const FileName: string): Boolean;
{* 判断是否.Pas文件}
function IsDcu(const FileName: string): Boolean;
{* 判断是否.Dcu文件}
function IsInc(const FileName: string): Boolean;
{* 判断是否.Inc文件}
function IsDfm(const FileName: string): Boolean;
{* 判断是否.Dfm文件}
function IsForm(const FileName: string): Boolean;
{* 判断是否窗体文件}
function IsXfm(const FileName: string): Boolean;
{* 判断是否.Xfm文件}
function IsFmx(const FileName: string): Boolean;
{* 判断是否.fmx文件}
function IsCppSourceModule(const FileName: string): Boolean;
{* 判断是否所有类型的C++源文件}
function IsHpp(const FileName: string): Boolean;
{* 判断是否.Hpp文件}
function IsCpp(const FileName: string): Boolean;
{* 判断是否.Cpp文件}
function IsC(const FileName: string): Boolean;
{* 判断是否.C文件}
function IsH(const FileName: string): Boolean;
{* 判断是否.H文件}
function IsAsm(const FileName: string): Boolean;
{* 判断是否.ASM文件}
function IsRC(const FileName: string): Boolean;
{* 判断是否.RC文件}
function IsKnownSourceFile(const FileName: string): Boolean;
{* 判断是否未知文件}
function IsTypeLibrary(const FileName: string): Boolean;
{* 判断是否是 TypeLibrary 文件}
function IsLua(const FileName: string): Boolean;
{* 判断是否是 lua 文件}
function IsSpecifiedExt(const FileName: string; const Ext: string): Boolean;
{* 判断是否是指定扩展名的文件，Ext 参数要带点号}
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
{* 使用字符串的方式判断对象是否继承自此类}
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
{* 使用字符串的方式判断控件是否包含指定类名的子控件，存在则返回最上面一个}

//==============================================================================
// OTA 接口操作相关函数
//==============================================================================

function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
{* 查询输入的服务接口并返回一个指定接口实例，如果失败，返回 False}
function CnOtaGetEditBuffer: IOTAEditBuffer;
{* 取IOTAEditBuffer接口}
function CnOtaGetEditPosition: IOTAEditPosition;
{* 取IOTAEditPosition接口}
function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string; ForceOpen: Boolean = True): IOTAEditView;
{* 根据文件名返回编辑器中打开的第一个 EditView，未打开时如 ForceOpen 为 True 则尝试打开，否则返回 nil}
function CnOtaGetTopMostEditView: IOTAEditView; overload;
{* 取当前最前端的IOTAEditView接口}
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
{* 取指定编辑器最前端的IOTAEditView接口}
function CnOtaGetTopMostEditActions: IOTAEditActions;
{* 取当前最前端的 IOTAEditActions 接口}
function CnOtaGetCurrentModule: IOTAModule;
{* 取当前模块}
function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
{* 取当前源码编辑器}
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
{* 取模块编辑器}
function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
{* 取窗体编辑器}
function CnOtaGetCurrentFormEditor: IOTAFormEditor;
{* 取当前窗体编辑器}
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
{* 取得窗体编辑器的容器控件或 DataModule 的容器}
function CnOtaGetCurrentDesignContainer: TWinControl;
{* 取得当前窗体编辑器的容器控件或 DataModule 的容器}
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
{* 取得当前窗体编辑器的已选择的控件}
function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
{* 显示指定模块的窗体 (来自 GExperts Src 1.2)}
procedure CnOtaShowDesignerForm;
{* 显示当前设计窗体 }
function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* 取当前的窗体设计器}
function CnOtaGetActiveDesignerType: string;
{* 取当前设计器的类型，返回字符串 dfm 或 xfm}
function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
{* 取组件的名称}
function CnOtaGetComponentText(Component: IOTAComponent): string;
{* 返回组件的标题}
function CnOtaGetModule(const FileName: string): IOTAModule;
{* 根据文件名返回模块接口}
function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
{* 取当前工程中模块数，无工程返回 -1}
function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
{* 取当前工程中的第 Index 个模块信息，从 0 开始}
function CnOtaGetEditor(const FileName: string): IOTAEditor;
{* 根据文件名返回编辑器接口}
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
{* 返回窗体编辑器设计窗体组件，或 DataModule 设计器的实例}
function CnOtaGetCurrentEditWindow: TCustomForm;
{* 取当前的 EditWindow}
function CnOtaGetCurrentEditControl: TWinControl;
{* 取当前的 EditControl 控件}
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
{* 返回单元名称}
function CnOtaGetProjectGroup: IOTAProjectGroup;
{* 取当前工程组}
function CnOtaGetProjectGroupFileName: string;
{* 取当前工程组文件名}
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
{* 取工程资源}
function CnOtaGetProjectVersion(Project: IOTAProject = nil): string;
{* 取工程版本号字符串}
function CnOtaGetCurrentProject: IOTAProject;
{* 取当前工程}
function CnOtaGetProject: IOTAProject;
{* 取第一个工程}
function CnOtaGetProjectCountFromGroup: Integer;
{* 取当前工程组中工程数，无工程组返回 -1}
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
{* 取当前工程组中的第 Index 个工程，从 0 开始}
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
function CnOtaGetOptionsNames(Options: IOTAOptions; IncludeType:
  Boolean = True): string; overload;
{* 取得 IDE 设置变量名列表}
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
{* 设置当前项目的属性值}

function CnOtaGetProjectPlatform(Project: IOTAProject): string;
{* 获得项目的当前Platform值，返回字符串，如不支持此特性则返回空字符串}
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
{* 获得项目的当前FrameworkType值，返回字符串，如不支持此特性则返回空字符串}
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName: string): string;
{* 获得项目的当前BuildConfiguration中的属性值，返回字符串，如不支持此特性则返回空字符串}
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName,
  AValue: string);
{* 设置项目的当前BuildConfiguration中的属性值，如不支持此特性则什么都不做}

{$IFDEF SUPPORTS_CROSS_PLATFORM}
procedure CnOtaGetPlatformsFromBuildConfiguration(BuildConfig: IOTABuildConfiguration; Platforms: TStrings);
{* 获取 BuildConfiguration 的 Platforms 至 TStrings 中，以避免低版本与脚本不支持泛型的问题}
{$ENDIF}

procedure CnOtaGetProjectList(const List: TInterfaceList);
{* 取得所有工程列表}
function CnOtaGetCurrentProjectName: string;
{* 取当前工程名称}
function CnOtaGetCurrentProjectFileName: string;
{* 取当前工程文件名称}
function CnOtaGetCurrentProjectFileNameEx: string;
{* 取当前工程文件名称扩展}
function CnOtaGetCurrentFormName: string;
{* 取当前窗体名称}
function CnOtaGetCurrentFormFileName: string;
{* 取当前窗体文件名称}
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
{* 取指定模块文件名，GetSourceEditorFileName 表示是否返回在代码编辑器中打开的文件}
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
{* 取当前模块文件名}
function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
{* 取当前环境设置}
function CnOtaGetEditOptions: IOTAEditOptions;
{* 取当前编辑器设置}
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
{* 取当前工程选项}
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
{* 取当前工程指定选项}
function CnOtaGetPackageServices: IOTAPackageServices;
{* 取当前包与组件服务}

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* 取当前工程配置选项，2009 后才有效}
{$ENDIF}

function CnOtaGetNewFormTypeOption: TFormType;
{* 取环境设置中新建窗体的文件类型}
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
{* 返回指定模块指定文件名的单元编辑器}
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
{* 返回指定模块指定文件名的编辑器}
function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
{* 返回指定模块的 EditActions }
function CnOtaGetCurrentSelection: string;
{* 取当前选择的文本}
procedure CnOtaDeleteCurrentSelection;
{* 删除选中的文本}
function CnOtaReplaceCurrentSelection(const Text: string; NoSelectionInsert: Boolean = True;
  KeepSelecting: Boolean = False; LineMode: Boolean = False): Boolean;
{* 用文本替换选中的文本。
  Text：插入的内容，2007 下 Text 是 AnsiString，2009 以上是 UnicodeString。
  NoSelectionInsert：控制无选择区时是否在当前位置插入。
  KeepSelecting：控制插入后是否选中插入内容。
  LineMode 是否先将选区扩展到整行。
  返回是否成功。已知问题：D5下似乎选择无效}
function CnOtaReplaceCurrentSelectionUtf8(const Utf8Text: AnsiString; NoSelectionInsert: Boolean = True;
  KeepSelecting: Boolean = False; LineMode: Boolean = False): Boolean;
{* 用文本替换选中的文本，参数是 Utf8 的 Ansi 字符串，可在 D2005~2007 下使用}
procedure CnOtaEditBackspace(Many: Integer);
{* 在编辑器中退格}
procedure CnOtaEditDelete(Many: Integer);
{* 在编辑器中删除}

{$IFNDEF CNWIZARDS_MINIMUM}

function CnOtaGetCurrentProcedure: string;
{* 获取当前光标所在的过程或函数名}
function CnOtaGetCurrentOuterBlock: string;
{* 获取当前光标所在的类名或声明}
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
{* 取指定行的源代码，行号以 1 开始，返回结果为 Ansi/Unicode，非 UTF8}
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
{* 取当前行源代码}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
{* 使用 NTA 方法取当前行源代码。速度快，但取回的文本是将 Tab 扩展成空格的。
   如果使用 ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1
   赋值给 EditPos.Col 即可。
   D7以下取到的是AnsiString，BDS 非 Unicode 下取到的是 UTF8 格式的 AnsiString，
   Unicode IDE 下取得的是 UTF16 字符串}

{$IFDEF UNICODE}
function CnNtaGetCurrLineTextW(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
{* 使用 NTA 方法取当前行源代码的Unicode版本。速度快，但取回的文本是将 Tab 扩展成空格的。
   如果使用 ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1
   赋值给 EditPos.Col 即可。
   Unicode IDE 下取得的是 UTF16 字符串与 UTF16 的偏移量}
{$ENDIF}

function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
{* 返回 SourceEditor 当前行信息}
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil): Boolean;
{* 取当前光标下的标识符及光标在标识符中的索引号，速度较快}

{$IFDEF UNICODE}
function CnOtaGetCurrPosTokenW(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCharSet = [];
  CharSet: TCharSet = []; EditView: IOTAEditView = nil): Boolean;
{* 取当前光标下的标识符及光标在标识符中的索引号的 Unicode 版本，允许 Unicode 标识符}
{$ENDIF}

function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
{* 取当前光标下的字符，允许偏移量}
function CnOtaDeleteCurrToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* 删除当前光标下的标识符}
function CnOtaDeleteCurrTokenLeft(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* 删除当前光标下的标识符左半部分}
function CnOtaDeleteCurrTokenRight(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* 删除当前光标下的标识符右半部分}
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
{* 判断位置是否超出行尾了。此机制在 Unicode 环境下当前行含有超过一个宽字符时可能会不准，慎用 }

{$ENDIF}

procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
{* 选择一个代码块，貌似不特别可靠}
function CnOtaMoveAndSelectBlock(const Start, After: TOTACharPos; View: IOTAEditView = nil): Boolean;
{* 用 Block 的方式设置代码块选区，返回是否成功。D5 下有 Bug 可能导致 D5 下无法选中。
   另外起始位置必须小于结束位置，否则也无法选中。选择成功后光标停留在结束处}
function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView = nil): Boolean;
{* 用 Block Extend 的方式选中一行，返回是否成功，光标处于行首}
function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer; View: IOTAEditView = nil): Boolean;
{* 用 Block Extend 的方式选中多行，光标停留在 End 行所标识的地方，返回是否成功}
function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
{* 直接用起止行列为参数选中代码快，均以一开始，返回是否成功
   如果起行列大于止行列，内部会互换}
function CnOtaCurrBlockEmpty: Boolean;
{* 返回当前选择的块是否为空}
function CnOtaGetBlockOffsetForLineMode(var StartPos: TOTACharPos; var EndPos: TOTACharPos;
  View: IOTAEditView = nil): Boolean;
{* 返回当前选择的块扩展成行模式后的起始位置，不实际扩展选择区}
function CnOtaOpenFile(const FileName: string): Boolean;
{* 打开文件}
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
{* 打开未保存的窗体}
function CnOtaIsFileOpen(const FileName: string): Boolean;
{* 判断文件是否打开}
procedure CnOtaCloseFile(const FileName: string; ForceClosed: Boolean = False);
{* 关闭文件}
function CnOtaIsFormOpen(const FormName: string): Boolean;
{* 判断窗体是否打开}
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
{* 判断模块是否已被修改}
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
{* 指定模块是否以文本窗体方式显示, Lines 为转到指定行，<= 0 忽略}
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
{* 让指定文件可见}
function CnOtaIsDebugging: Boolean;
{* 当前是否在调试状态}
function CnOtaGetBaseModuleFileName(const FileName: string): string;
{* 取模块的单元文件名}
function CnOtaIsPersistentBlocks: Boolean;
{* 当前 PersistentBlocks 是否为 True}
procedure CnOtaGetCurrentBreakpoints(Results: TList);
{* 使用 CnWizDebuggerNotifierServices 获取当前源文件内的断点，
   List 中返回 TCnBreakpointDescriptor 实例}

//==============================================================================
// 源代码操作相关函数
//==============================================================================

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean; MaxLen: Integer = 0): string;
{* 字符串转为源代码串}

function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
{* 长代码自动切换为多行代码。
 |<PRE>
   Code: string            - 源代码
   Len: Integer            - 行宽度
   Indent: Integer         - 换行后的缩进字符数
   IndentOnceOnly: Boolean - 是否仅在产生第二行时进行缩进
 |</PRE>}

{$IFDEF COMPILER6_UP}
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
{* 快速转换Utf8到Ansi字符串，适用于长度短且主要是Ansi字符的字符串 }
{$ENDIF}

{$IFDEF UNICODE}
function ConvertTextToEditorUnicodeText(const Text: string): string;
{* Unicode 环境下转换字符串为编辑器使用的字符串，避免 AnsiString 转换}
{$ENDIF}

function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
{* 转换字符串为编辑器使用的字符串 }

function ConvertEditorTextToText(const Text: AnsiString): AnsiString;
{* 转换编辑器使用的字符串为普通字符串 }

{$IFDEF IDE_WIDECONTROL}

function ConvertWTextToEditorText(const Text: WideString): AnsiString;
{* 转换宽字符串为编辑器使用的字符串(UTF8)，D2005~2007 版本使用}

function ConvertEditorTextToWText(const Text: AnsiString): WideString;
{* 转换编辑器使用的字符串(UTF8)为宽字符串，D2005~2007 版本使用 }

{$ENDIF}

{$IFDEF UNICODE}
function ConvertTextToEditorTextW(const Text: string): AnsiString;
{* 转换字符串为编辑器使用的字符串(UTF8)，D2009 以上版本使用 }

function ConvertEditorTextToTextW(const Text: AnsiString): string;
{* 转换编辑器使用的字符串(UTF8)为 Unicode 字符串，D2009 以上版本使用 }
{$ENDIF}

function CnOtaGetCurrentSourceFile: string;
{* 取当前编辑的源文件}

function CnOtaGetCurrentSourceFileName: string;
{* 取当前编辑的 Pascal 或 C 源文件，判断限制较多}

// 在 EditPosition 中插入一段文本，支持 D2005 下使用 utf-8 格式
procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);

type
  TInsertPos = (ipCur, ipFileHead, ipFileEnd, ipLineHead, ipLineEnd);
{* 文本插入位置
 |<PRE>
   ipCur         - 当前光标处
   ipFileHead    - 文件头部
   ipFileEnd     - 文件尾部
   ipLineHead    - 当前行首
   ipLineEnd     - 当前行尾
 |</PRE>}

function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos
  = ipCur): Boolean;
{* 插入一段文本到当前正在编辑的源文件中，返回成功标志
 |<PRE>
   Text: string           - 文本内容
   InsertPos: TInsertPos  - 插入位置，默认为 ipCurr 当前位置
 |</PRE>}

function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
{* 获得当前编辑的源文件中光标的位置，返回成功标志
 |<PRE>
   Col: Integer           - 行位置
   Row: Integer           - 列位置
 |</PRE>}

function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
{* 设定当前编辑的源文件中光标的位置，返回成功标志
 |<PRE>
   Col: Integer           - 行位置
   Row: Integer           - 列位置
 |</PRE>}

function CnOtaSetCurSourceCol(Col: Integer): Boolean;
{* 设定当前编辑的源文件中光标的位置，返回成功标志}

function CnOtaSetCurSourceRow(Row: Integer): Boolean;
{* 设定当前编辑的源文件中光标的位置，返回成功标志}

function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
{* 在当前编辑的源文件中移动光标，返回成功标志
 |<PRE>
   Pos: TInsertPos        - 光标位置
   Offset: Integer        - 偏移量
 |</PRE>}

function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
{* 返回 SourceEditor 当前光标位置的线性地址}

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
{* 返回 SourceEditor 当前光标位置}

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
{* 编辑位置转换为线性位置 }

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
{* 线性位置转换为编辑位置 }

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
{* 保存EditReader内容到流中，流中的内容默认为 Ansi 格式，带末尾 #0 字符，
   AlternativeWideChar 表示 CheckUtf8 为 True 时，在纯英文 OS 的 Unicode 环境下，
   是否将转换成的 Ansi 中的每个宽字符手动替换成两个空格。此选项用于躲过纯英文 OS
   的 Unicode 环境下 UnicodeString 直接转 Ansi 时的丢字符问题}

procedure CnOtaSaveEditorToStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
{* 保存编辑器文本到流中}

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
{* 保存编辑器文本到流中}

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
{* 保存当前编辑器文本到流中}

function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean = True): string;
{* 取得当前编辑器源代码}

{$IFDEF UNICODE}

procedure CnOtaSaveReaderToStreamW(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* 保存 EditReader 内容到流中，流中的内容默认为 Unicode 格式，带末尾 #0 字符，2009 以上使用}

procedure CnOtaSaveEditorToStreamWEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* 保存编辑器文本到流中，Unicode 版本，2009 以上使用}

function CnOtaSaveEditorToStreamW(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
{* 保存编辑器文本到流中，Unicode 版本，2009 以上使用}

function CnOtaSaveCurrentEditorToStreamW(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
{* 保存当前编辑器文本到流中，Unicode 版本，2009 以上使用}

function CnOtaGetCurrentEditorSourceW: string;
{* 取得当前编辑器源代码，Unicode 版本，2009 以上使用}

procedure CnOtaSetCurrentEditorSourceW(const Text: string);
{* 设置当前编辑器源代码，Unicode 版本，2009 以上使用}

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}
procedure CnOtaSetCurrentEditorSourceUtf8(const Text: string);
{* 设置当前编辑器源代码，只在 D2005~2007 版本使用，参数为原始 UTF8 内容}
{$ENDIF}

procedure CnOtaSetCurrentEditorSource(const Text: string);
{* 设置当前编辑器源代码，可在各版本使用，但有多余的转换可能导致丢内容}

procedure CnOtaInsertLineIntoEditor(const Text: string);
{* 插入一个字符串到当前 IOTASourceEditor，仅在 Text 为单行文本时有用
   它会替换当前所选的文本。}

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
{* 插入一行文本当前 IOTASourceEditor，Line 为行号，Text 为单行 }

procedure CnOtaInsertTextIntoEditor(const Text: string);
{* 插入文本到当前 IOTASourceEditor，允许多行文本。}

procedure CnOtaInsertTextIntoEditorUtf8(const Utf8Text: AnsiString);
{* 插入文本到当前 IOTASourceEditor，允许多行文本。
  可在 D2005~2007 下替代上面的 CnOtaInsertTextIntoEditor 以避免转成 Ansi 而可能丢字符的问题}

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
{* 为指定 SourceEditor 返回一个 Writer，如果输入为空返回当前值。}

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* 在指定位置处插入文本，内部会根据需要做 Utf8 转换，如果 SourceEditor 为空使用当前值。}

procedure CnOtaInsertTextIntoEditorAtPosUtf8(const Utf8Text: AnsiString; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* 在指定位置处插入 Utf8 字符串，如果 SourceEditor 为空使用当前值。
  可在 D2005~2007 下替代上面的 CnOtaInsertTextIntoEditorAtPos 以避免转成 Ansi 而可能丢字符的问题}

{$IFDEF UNICODE}
procedure CnOtaInsertTextIntoEditorAtPosW(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* 在指定位置处插入文本，如果 SourceEditor 为空使用当前值，D2009 以上使用。}
{$ENDIF}

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* 移动光标到指定位置，如果 EditView 为空使用当前值。}

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
{* 返回当前光标位置，如果 EditView 为空使用当前值。 }

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* 移动光标到指定位置，BDS 以上的列使用 Utf8 的列值。如果 EditView 为空使用当前值。}

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
{* 转换一个线性位置到 TOTACharPos，因为在 D5/D6 下 IOTAEditView.PosToCharPos
   可能不能正常工作}

function CnOtaGetBlockIndent: Integer;
{* 获得当前编辑器块缩进宽度 }

procedure CnOtaClosePage(EditView: IOTAEditView);
{* 关闭模块视图}

procedure CnOtaCloseEditView(AModule: IOTAModule);
{* 仅关闭模块的视图，而不关闭模块}

//==============================================================================
// 窗体操作相关函数
//==============================================================================

function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList; 
  ExcludeForm: Boolean = True): Boolean;
{* 取得当前设计的窗体及选择的组件列表，返回成功标志
 |<PRE>
   var AForm: TCustomForm    - 正在设计的窗体
   Selections: TList         - 当前选择的组件列表，如果传入 nil 则不返回
   ExcludeForm: Boolean      - 不包含 Form 本身
   Result: Boolean           - 如果成功返回为 True
 |</PRE>}

function CnOtaGetCurrFormSelectionsCount: Integer;
{* 取当前设计的窗体上选择控件的数量}

function CnOtaIsCurrFormSelectionsEmpty: Boolean;
{* 判断当前设计的窗体上是否选择有控件}

procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor = nil);
{* 通知窗体设计器内容已变更}

function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor = nil): Boolean;
{* 判断当前选择的控件是否为设计窗体本身}

function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
{* 判断设计期控件的指定属性是否存在}

procedure CnOtaSetCurrFormSelectRoot;
{* 设置当前设计期窗体选择的组件为设计窗体本身}

procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
{* 取得当前选择的控件的名称列表}

procedure CnOtaCopyCurrFormSelectionsName;
{* 复制当前选择的控件的名称列表到剪贴板}

function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
{* 返回一个位置值}

function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
{* 返回一个编辑位置值 }

function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
{* 判断两个编辑位置是否相等 }

function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
{* 判断两个字符位置是否相等 }

function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
{* 判断一控件窗口是否是非可视化控件}

function FileExists(const Filename: string): Boolean;
{* Tests for file existance, a lot faster than the RTL implementation }

procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* 将一 EditView 中的书签信息保存至一 ObjectList 中}

procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* 从 ObjectList 中全部恢复一 EditView 中的书签}

procedure ReplaceBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* 从 ObjectList 中替换一部分 EditView 中的书签}

function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
  APattern: string; IsMatchStart: Boolean = False): Boolean;
{* 判断正则表达式匹配}

{$IFNDEF CNWIZARDS_MINIMUM}
procedure TranslateFormFromLangFile(AForm: TCustomForm; const ALangDir, ALangFile: string;
  LangID: Cardinal);
{* 加载指定的语言文件翻译窗体}
{$ENDIF}

procedure CnWizAssert(Expr: Boolean; const Msg: string = '');
{* 封装 Assert 判断}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFDEF SUPPORTS_FMX}
  CnFmxUtils,
{$ENDIF}
  Math, CnWizOptions, CnGraphUtils
{$IFNDEF CNWIZARDS_MINIMUM}
  , CnWizMultiLang, CnLangMgr, CnWizIdeUtils, CnWizDebuggerNotifier, CnEditControlWrapper,
  CnPasCodeParser, CnCppCodeParser, CnLangStorage, CnHashLangStorage, CnWizHelp
{$ENDIF}
  ;

const
  MAX_LINE_LENGTH = 2048;

type
  TControlAccess = class(TControl);

var
{$IFDEF COMPILER7_UP}
  OldRegisterNoIconProc: procedure(const ComponentClasses: array of TComponentClass) = nil;
{$ELSE}
  OldRegisterNoIconProc: procedure(ComponentClasses: array of TComponentClass) = nil;
{$ENDIF COMPILER7_UP}

{$IFDEF COMPILER7_UP}
procedure CnRegisterNoIconProc(const ComponentClasses: array of TComponentClass);
{$ELSE}
procedure CnRegisterNoIconProc(ComponentClasses: array of TComponentClass);
{$ENDIF COMPILER7_UP}
var
  i: Integer;
begin
  for i := Low(ComponentClasses) to High(ComponentClasses) do
  begin
    if CnNoIconList.IndexOf(ComponentClasses[i].ClassName) < 0 then
    begin
      CnNoIconList.Add(ComponentClasses[i].ClassName);
    end;
  end;

  if Assigned(OldRegisterNoIconProc) then
    OldRegisterNoIconProc(ComponentClasses);
end;

procedure AddNoIconToList(const ClassName: string);
var
  AClass: TPersistentClass;
begin
  AClass := GetClass(ClassName);
  if Assigned(AClass) then
    CnNoIconList.Add(AClass.ClassName);
end;

//==============================================================================
// 公共信息函数
//==============================================================================

// 供 Pascal Script 使用的将整型值转换成 TObject 的函数
// （因为 Pascal Script 不支持 TObject(0) 这种语法）
function CnIntToObject(AInt: Integer): TObject;
begin
  Result := TObject(AInt);
end;

// 供 Pascal Script 使用的将 TObject 转换成整型值的函数}\
function CnObjectToInt(AObject: TObject): Integer;
begin
  Result := Integer(AObject);
end;

// 供 Pascal Script 使用的将整型值转换成 TObject 的函数
function CnIntToInterface(AInt: Integer): IUnknown;
begin
  Result := IUnknown(AInt);
end;

// 供 Pascal Script 使用的将 TObject 转换成整型值的函数
function CnInterfaceToInt(Intf: IUnknown): Integer;
begin
  Result := Integer(Intf);
end;

// 供 Pascal Script 使用的从类名获取类信息并转换成整型值的函数
function CnGetClassFromClassName(const AClassName: string): Integer;
begin
  Result := Integer(GetClass(AClassName));
end;

// 供 Pascal Script 使用的从对象获取类信息并转换成整型值的函数
function CnGetClassFromObject(AObject: TObject): Integer;
begin
  Result := Integer(AObject.ClassType);
end;

// 供 Pascal Script 使用的从整型的类信息获取类名的函数
function CnGetClassNameFromClass(AClass: Integer): string;
begin
  Result := TClass(AClass).ClassName;
end;

// 供 Pascal Script 使用的从整型的类信息获取父类信息的函数
function CnGetClassParentFromClass(AClass: Integer): Integer;
begin
  Result := Integer(TClass(AClass).ClassParent);
end;

var
  FResInited: Boolean;
  HResModule: HMODULE;

// 加载资源DLL文件
function LoadResDll: Boolean;
begin
  if not FResInited then
  begin
    HResModule := LoadLibrary(PChar(WizOptions.DllPath + SCnWizResDllName));
  {$IFDEF DEBUG}
    CnDebugger.LogInteger(HResModule, 'HResModule');
  {$ENDIF}
    FResInited := True;
  end;
  Result := HResModule <> 0;
end;

// 释放资源DLL文件
procedure FreeResDll;
begin
  if HResModule <> 0 then
    FreeLibrary(HResModule);
  FResInited := False;
end;

// 从资源或文件中装载图标
function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
var
  FileName: string;
  Handle: HICON;
begin
  Result := False;
  
  // 从文件中装载
  try
    if SameFileName(_CnExtractFileName(ResName), ResName) then
      FileName := WizOptions.IconPath + ResName + SCnIcoFileExt
    else
      FileName := ResName;
    if FileExists(FileName) then
    begin
      AIcon.LoadFromFile(FileName);
      if not AIcon.Empty then
      begin
        Result := True;
        Exit;
      end;
    end;
  except
    ;
  end;

  // 从资源中装载
  if LoadResDll then
  begin
    Handle := LoadImage(HResModule, PChar(UpperCase(ResName)), IMAGE_ICON, 0, 0, 0);
    if Handle <> 0 then
    begin
      AIcon.Handle := Handle;
      Result := True;
    end;
  end;
end;

// 从资源或文件中装载位图
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
var
  FileName: string;
begin
  Result := False;
  
  // 从文件中装载
  try
    if SameFileName(_CnExtractFileName(ResName), ResName) then
      FileName := WizOptions.IconPath + ResName + SCnBmpFileExt
    else
      FileName := ResName;
    if FileExists(FileName) then
    begin
      ABitmap.LoadFromFile(FileName);
      if not ABitmap.Empty then
      begin
        Result := True;
        Exit;
      end;
    end;
  except
    ;
  end;

  // 从资源中装载
  if LoadResDll then
  begin
    ABitmap.LoadFromResourceName(HResModule, UpperCase(ResName));
    Result := not ABitmap.Empty;
  end;
end;

// 增加图标到 ImageList 中，使用平滑处理
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
const
  MaskColor = clBtnFace;
var
  SrcBmp, DstBmp: TBitmap;
  PSrc1, PSrc2, PDst: PRGBArray;
  x, y: Integer;
begin
  Assert(Assigned(AIcon));
  Assert(Assigned(ImageList));
  if (ImageList.Width = 16) and (ImageList.Height = 16) and not AIcon.Empty and
    (AIcon.Width = 32) and (AIcon.Height = 32) then
  begin
    SrcBmp := nil;
    DstBmp := nil;
    try
      SrcBmp := CreateEmptyBmp24(32, 32, MaskColor);
      DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
      SrcBmp.Canvas.Draw(0, 0, AIcon);
      for y := 0 to DstBmp.Height - 1 do
      begin
        PSrc1 := SrcBmp.ScanLine[y * 2];
        PSrc2 := SrcBmp.ScanLine[y * 2 + 1];
        PDst := DstBmp.ScanLine[y];
        for x := 0 to DstBmp.Width - 1 do
        begin
          PDst^[x].b := (PSrc1^[x * 2].b + PSrc1^[x * 2 + 1].b + PSrc2^[x * 2].b
            + PSrc2^[x * 2 + 1].b) shr 2;
          PDst^[x].g := (PSrc1^[x * 2].g + PSrc1^[x * 2 + 1].g + PSrc2^[x * 2].g
            + PSrc2^[x * 2 + 1].g) shr 2;
          PDst^[x].r := (PSrc1^[x * 2].r + PSrc1^[x * 2 + 1].r + PSrc2^[x * 2].r
            + PSrc2^[x * 2 + 1].r) shr 2;
        end;
      end;
      Result := ImageList.AddMasked(DstBmp, MaskColor);
    finally
      if Assigned(SrcBmp) then FreeAndNil(SrcBmp);
      if Assigned(DstBmp) then FreeAndNil(DstBmp);
    end;
  end
  else if not AIcon.Empty then
    Result := ImageList.AddIcon(AIcon)
  else
    Result := -1;
end;

// 创建一个 Disabled 的位图，返回对象需要调用方释放
function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
const
  ROP_DSPDxax = $00E20746;
var
  MonoBmp: TBitmap;
  Col: TColor;
  tr, tg, tb: Byte;
  P, P1, P2, P3: PRGBArray;
  R: PRGBColor;
  C: array[0..3] of PRGBColor;
  x, y, i: Integer;
  IsEdge: Boolean;
begin
  Result := TBitmap.Create;
  if Assigned(Glyph) then
  begin
    Glyph.PixelFormat := pf24bit;
    Result.Assign(Glyph);
    Result.PixelFormat := pf24bit;
    Result.Canvas.Brush.Color := Glyph.TransparentColor;
    Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));

    Col := ColorToRGB(Glyph.TransparentColor);
    tr := GetRValue(Col);
    tg := GetGValue(Col);
    tb := GetBValue(Col);
    for y := 0 to Result.Height - 1 do
    begin
      P := Result.ScanLine[y];
      P1 := Glyph.ScanLine[Max(y - 1, 0)];
      P2 := Glyph.ScanLine[y];
      P3 := Glyph.ScanLine[Min(y + 1, Result.Height - 1)];
      for x := 0 to Result.Width - 1 do
      begin
        R := @P2^[x];
        if (R^.r <> tr) or (R^.g <> tg) or (R^.b <> tb) then
        begin
          IsEdge := (R^.r + R^.g + R^.b) < 3 * $80;
          if not IsEdge then
          begin
            C[0] := @P1^[x];
            C[1] := @P3^[x];
            C[2] := @P2^[Max(x - 1, 0)];
            C[3] := @P2^[Min(x + 1, Result.Width - 1)];
            for i := 0 to 3 do
              if (C[i]^.r = tr) and (C[i]^.g = tg) and (C[i]^.b = tb) then
              begin
                IsEdge := True;
                Break;
              end;
          end;
          
          if IsEdge then
          begin
            R := @P^[x];
            R^.b := 0;
            R^.g := 0;
            R^.r := 0;
          end
        end;
      end;
    end;

    MonoBmp := TBitmap.Create;
    try
      with MonoBmp do
      begin
        Assign(Result);
        HandleType := bmDDB;
        Canvas.Brush.Color := clBlack;
        Width := Result.Width;
        if Monochrome then
        begin
          Canvas.Font.Color := clWhite;
          Monochrome := False;
          Canvas.Brush.Color := clWhite;
        end;
        Monochrome := True;
      end;
      with Result.Canvas do
      begin
        Brush.Color := clBtnFace;
        FillRect(Rect(0, 0, Result.Width, Result.Height));
        Brush.Color := clBtnHighlight;
        SetTextColor(Handle, clBlack);
        SetBkColor(Handle, clWhite);
        BitBlt(Handle, 1, 1, Result.Width, Result.Height,
          MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
        Brush.Color := clBtnShadow;
        SetTextColor(Handle, clBlack);
        SetBkColor(Handle, clWhite);
        BitBlt(Handle, 0, 0, Result.Width, Result.Height,
          MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
      end;
    finally
      MonoBmp.Free;
    end;
  end;
end;

// Delphi 的按钮在 Disabled 状态时，显示的图像很难看，该函数通过在原位图的基础上
// 创建一个新的灰度位图来解决这一问题，调整完成后 Glyph 宽度变为高度的两倍，需要
// 设置 Button.NumGlyphs := 2
procedure AdjustButtonGlyph(Glyph: TBitmap);
var
  Bmp, Bmp2: TBitmap;
begin
  if Assigned(Glyph) then
  begin
    Bmp := CreateDisabledBitmap(Glyph);
    try
      Bmp2 := TBitmap.Create;
      try
        Bmp2.Assign(Glyph);
        Glyph.Width := Glyph.Width * 2;
        Glyph.Canvas.Brush.Color := Glyph.TransparentColor;
        Glyph.Canvas.FillRect(Rect(0, 0, Glyph.Width, Glyph.Height));
        Glyph.Canvas.Draw(0, 0, Bmp2);
        Glyph.Canvas.Draw(Bmp.Width, 0, Bmp);
      finally
        Bmp2.Free;
      end;
    finally
      Bmp.Free;
    end;
  end;
end;

// 文件名相同
function SameFileName(const S1, S2: string): Boolean;
begin
  Result := (CompareText(S1, S2) = 0);
end;

// 压缩字符串中间的空白字符
function CompressWhiteSpace(const Str: string): string;
var
  i: Integer;
  Len: Integer;
  NextResultChar: Integer;
  CheckChar: Char;
  NextChar: Char;
begin
  Len := Length(Str);
  NextResultChar := 1;
  SetLength(Result, Len);

  for i := 1 to Len do
  begin
    CheckChar := Str[i];
    NextChar := Str[i + 1];
    case CheckChar of
      #9, #10, #13, #32:
        begin
          if CharInSet(NextChar, [#0, #9, #10, #13, #32]) or (NextResultChar = 1) then
            Continue
          else
          begin
            Result[NextResultChar] := #32;
            Inc(NextResultChar);
          end;
        end;
      else
        begin
          Result[NextResultChar] := Str[i];
          Inc(NextResultChar);
        end;
    end;
  end;
  if Len = 0 then
    Exit;
  SetLength(Result, NextResultChar - 1);
end;

// 显示指定主题的帮助内容
procedure ShowHelp(const Topic: string);
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  if not CnWizHelp.ShowHelp(Topic) then
    ErrorDlg(SCnNoHelpofThisLang);
{$ENDIF}
end;

// 窗体居中
procedure CenterForm(const Form: TCustomForm);
var
  Rect: TRect;
begin
  if Form = nil then
    Exit;

  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);

  with Form do
  begin
    SetBounds((Rect.Right - Rect.Left - Width) div 2,
      (Rect.Bottom - Rect.Top - Height) div 2, Width, Height);
  end;
end;

// 保证窗体可见
procedure EnsureFormVisible(const Form: TCustomForm);
var
  Rect: TRect;
begin
  Rect.Top := 0;
  Rect.Left := 0;
  Rect.Right := Screen.Width;
  Rect.Bottom := Screen.Height;
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);
  if (Form.Left + Form.Width > Rect.Right) then
    Form.Left := Form.Left - ((Form.Left + Form.Width) - Rect.Right);
  if (Form.Top + Form.Height > Rect.Bottom) then
    Form.Top := Form.Top - ((Form.Top + Form.Height) - Rect.Bottom);
  if Form.Left < 0 then
    Form.Left := 0;
  if Form.Top < 0 then
    Form.Top := 0;
end;

// 删除标题中热键信息
function GetCaptionOrgStr(const Caption: string): string;
var
  i, l: Integer;
begin
  Result := Caption;
  for i := Length(Result) downto 1 do
    if Result[i] = '.' then
      Delete(Result, i, 1);

  l := Length(Result);
  if l > 4 then
    if CharInSet(Result[l - 3], ['(', '[']) and (Result[l - 2] = '&') and
      CharInSet(Result[l], [')', ']']) then
      Delete(Result, l - 3, 4);

  Result := StringReplace(Result, '&', '', [rfReplaceAll]);
end;

//取得 IDE 主 ImageList
function GetIDEImageList: TCustomImageList;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ImageList;
end;

// 保存 IDE ImageList 中的图像到指定目录下}
procedure SaveIDEImageListToPath(const Path: string);
var
  ImgList: TCustomImageList;
  Bmp: TBitmap;
  i: Integer;
begin
  if not DirectoryExists(Path) then
    Exit;
  ImgList := GetIDEImageList;
  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf24bit;
  Bmp.Width := ImgList.Width;
  Bmp.Height := ImgList.Height;
  try
    for i := 0 to ImgList.Count - 1 do
    begin
      Bmp.Canvas.Brush.Color := clFuchsia;
      Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
      ImgList.GetBitmap(i, Bmp);
      Bmp.SaveToFile(MakePath(Path) + IntToStrEx(i, 3) + '.bmp');
    end;
  finally
    Bmp.Free;
  end;
end;

// 保存菜单名称列表到文件
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
var
  i: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    for i := 0 to AMenu.Count - 1 do
      List.Add(AMenu.Items[i].Name + ' | ' + AMenu.Items[i].Caption);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// 取得 IDE 主菜单
function GetIDEMainMenu: TMainMenu;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.MainMenu;
end;

// 取得 IDE 主菜单下的 Tools 菜单
function GetIDEToolsMenu: TMenuItem;
var
  MainMenu: TMainMenu;
  i: Integer;
begin
  MainMenu := GetIDEMainMenu; // IDE主菜单
  if MainMenu <> nil then
  begin
    for i := 0 to MainMenu.Items.Count - 1 do
      if AnsiCompareText(SToolsMenuName, MainMenu.Items[i].Name) = 0 then
      begin
        Result := MainMenu.Items[i];
        Exit;
      end
  end;
  Result := nil;
end;
  
// 取得 IDE 主 ActionList
function GetIDEActionList: TCustomActionList;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ActionList;
end;

// 取得 IDE 主 ActionList 中指定快捷键的 Action
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
var
  I: Integer;
  ActionList: TCustomActionList;
begin
  Result := nil;
  ActionList := GetIDEActionList;
  if ActionList <> nil then
    for I := 0 to ActionList.ActionCount - 1 do
      if ActionList.Actions[I] is TCustomAction then
        if TCustomAction(ActionList.Actions[I]).ShortCut = ShortCut then
        begin
          Result := TCustomAction(ActionList.Actions[I]);
          Exit;
        end;  
end;  

// 取得 IDE 根目录
function GetIdeRootDirectory: string;
begin
  Result := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));
end;

// 将 $(DELPHI) 这样的符号替换为 Delphi 所在路径
function ReplaceToActualPath(const Path: string; Project: IOTAProject = nil): string;
{$IFDEF COMPILER6_UP}
var
  Vars: TStringList;
  I: Integer;
{$IFDEF DELPHI2011_UP}
  BC: IOTAProjectOptionsConfigurations;
{$ENDIF}
begin
  Result := Path;
  Vars := TStringList.Create;
  try
    GetEnvironmentVars(Vars, True);
    for I := 0 to Vars.Count - 1 do
    begin
{$IFDEF DELPHIXE6_UP}
      // There's a $(Platform) values '' in XE6, will make Platform Empty.
      if Trim(Vars.Values[Vars.Names[I]]) = '' then
        Continue;
{$ENDIF}
      Result := StringReplace(Result, '$(' + Vars.Names[I] + ')',
        Vars.Values[Vars.Names[I]], [rfReplaceAll, rfIgnoreCase]);
    end;

{$IFDEF DELPHI2011_UP}
    BC := CnOtaGetActiveProjectOptionsConfigurations(Project);
    if BC <> nil then
    begin
      if BC.GetActiveConfiguration <> nil then
      begin
        Result := StringReplace(Result, '$(Config)',
          BC.GetActiveConfiguration.GetName, [rfReplaceAll, rfIgnoreCase]);
  {$IFDEF DELPHI2012_UP}
        if BC.GetActiveConfiguration.GetPlatform <> '' then
        begin
          Result := StringReplace(Result, '$(Platform)',
            BC.GetActiveConfiguration.GetPlatform, [rfReplaceAll, rfIgnoreCase]);
        end
        else if Project <> nil then
        begin
          Result := StringReplace(Result, '$(Platform)',
            Project.CurrentPlatform, [rfReplaceAll, rfIgnoreCase]);
        end;
  {$ENDIF}
      end;
    end;
{$ENDIF}

    if Project <> nil then
    begin
      Result := StringReplace(Result, '$(MSBuildProjectName)',
        _CnChangeFileExt(_CnExtractFileName(Project.FileName), ''),
        [rfReplaceAll, rfIgnoreCase]);
    end;
  finally
    Vars.Free;
  end;   
end;  
{$ELSE}
begin
  // Delphi5 下不支持环境变量
  Result := StringReplace(Path, SCnIDEPathMacro, MakeDir(GetIdeRootDirectory),
    [rfReplaceAll, rfIgnoreCase]);
end;
{$ENDIF}

// 保存 IDE ActionList 中的内容到指定文件
procedure SaveIDEActionListToFile(const FileName: string);
var
  ActionList: TCustomActionList;
  i: Integer;
  List: TStrings;
begin
  ActionList := GetIDEActionList;
  List := TStringList.Create;
  try
    for i := 0 to ActionList.ActionCount - 1 do
      if ActionList.Actions[i] is TCustomAction then
        with ActionList.Actions[i] as TCustomAction do
          List.Add(Name + ' | ' + Caption)
      else
        List.Add(ActionList.Actions[i].Name);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// 保存 IDE 环境设置变量名到指定文件
procedure SaveIDEOptionsNameToFile(const FileName: string);
var
  Options: IOTAEnvironmentOptions;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Assigned(Options) then
    SaveStringToFile(CnOtaGetOptionsNames(Options), FileName);
end;

// 保存当前工程环境设置变量名到指定文件
procedure SaveProjectOptionsNameToFile(const FileName: string);
var
  Options: IOTAProjectOptions;
begin
  Options := CnOtaGetActiveProjectOptions;
  if Assigned(Options) then
    SaveStringToFile(CnOtaGetOptionsNames(Options), FileName);
end;

// 根据 IDE Action 名，返回对象
function FindIDEAction(const ActionName: string): TContainedAction;
var
  Svcs40: INTAServices40;
  ActionList: TCustomActionList;
  i: Integer;
begin
  if ActionName = '' then 
  begin
    Result := nil;
    Exit;
  end;

  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  ActionList := Svcs40.ActionList;
  for i := 0 to ActionList.ActionCount - 1 do
  begin
    if SameText(ActionList.Actions[i].Name, ActionName) then
    begin
      Result := ActionList.Actions[i];
      Exit;
    end;
  end;
  Result := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsgError('FindIDEAction can NOT find ' + ActionName);
{$ENDIF}
end;

// 根据 IDE Action 名，执行它
function ExecuteIDEAction(const ActionName: string): Boolean;
var
  Action: TContainedAction;
begin
  Action := FindIDEAction(ActionName);
  if Assigned(Action) then
    Result := Action.Execute
  else
  begin
    Result := False;
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('ExecuteIDEAction can NOT find ' + ActionName);
{$ENDIF}
  end;
end;

// 创建一个子菜单项
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
begin
  Result := TMenuItem.Create(Menu);
  Result.Caption := Caption;
  Result.OnClick := OnClick;
  Result.ShortCut := ShortCut;
  if Hint = '' then
    Result.Hint := StripHotkey(Caption)
  else
    Result.Hint := Hint;
  Result.Tag := Tag;
  Result.Action := Action;
  Menu.Add(Result);
end;

// 创建一个分隔菜单项
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
begin
  Result := AddMenuItem(Menu, '-');
end;

// 根据 TCnMenuWizard 列表中的 MenuOrder 值进行由小到大的排序
procedure SortListByMenuOrder(List: TList);
var
  i, j: Integer;
  P: Pointer;
begin
  // 冒泡排序
  if List.Count = 1 then
    Exit;
    
  for i := List.Count - 2 downto 0 do
    for j := 0 to i do
    begin
      if TCnMenuWizard(List.Items[j]).MenuOrder >
        TCnMenuWizard(List.Items[j + 1]).MenuOrder then  // 大头在后边
        begin
          P := List.Items[j];
          List.Items[j] := List.Items[j + 1];
          List.Items[j + 1] := P;
        end;
    end;
end;

// 返回 DFM 文件是否文本格式
function IsTextForm(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  C: Char;
begin
  Result := False;
  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      FileStream.Position := 0;
      if FileStream.Read(C, SizeOf(C)) = SizeOf(C) then
        if CharInSet(C, ['o','O','i','I',' ',#13,#11,#9]) then
          Result := True;
    finally
      FileStream.Free;
    end;
  except
    ;
  end;
end;

// 处理一些执行方法中的异常
procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
begin
{$IFDEF DEBUG}
  if E = nil then
    CnDebugger.LogMsgWithType('Error: ' + ErrorMsg, cmtError)
  else
  begin
    CnDebugger.LogMsgWithType('Error ' + ErrorMsg + ' : ' + E.Message, cmtError);
    CnDebugger.LogStackFromAddress(ExceptAddr, 'Call Stack');
  end;
{$ENDIF}
end;

// 在窗口控件中查找指定类的子组件
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
var
  i: Integer;
begin
  for i := 0 to AWinControl.ComponentCount - 1 do
    if (AWinControl.Components[i] is AClass) and ((AComponentName = '') or
      (SameText(AComponentName, AWinControl.Components[i].Name))) then
    begin
      Result := AWinControl.Components[i];
      Exit;
    end;
  Result := nil;
end;

// 在窗口控件中查找指定类名的子组件
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
var
  i: Integer;
begin
  for i := 0 to AWinControl.ComponentCount - 1 do
    if AWinControl.Components[i].ClassNameIs(AClassName) and ((AComponentName = 
      '') or (SameText(AComponentName, AWinControl.Components[i].Name))) then
    begin
      Result := AWinControl.Components[i];
      Exit;
    end;
  Result := nil;
end;

// 存在模式窗口
function ScreenHasModalForm: Boolean;
var
  i: Integer;
begin
  for i := 0 to Screen.CustomFormCount - 1 do
    if fsModal in Screen.CustomForms[i].FormState then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

// 去掉窗体的标题
procedure SetFormNoTitle(Form: TForm);
var
  Style: Integer;
  H: Integer;
  Max: boolean;                         // for refresh form
begin
  Max := Form.WindowState = wsMaximized;
  if Max then Form.WindowState := wsNormal;
  H := Form.Width;
  Style := GetWindowLong(Form.Handle, GWL_STYLE);
  SetWindowLong(Form.Handle, GWL_STYLE, Style and not WS_CAPTION);
  // only for refresh form
  Form.Width := H + 1;
  Form.Width := H;
  if Max then Form.WindowState := wsNormal;
end;

// 发送一个按键事件
procedure SendKey(vk: Word);
begin
  keybd_event(vk, 0, 0, 0);
  keybd_event(vk, 0, KEYEVENTF_KEYUP, 0);
end;

// 判断输入法是否打开
function IMMIsActive: Boolean;
begin
  Result := ImmIsIME(GetKeyBoardLayOut(0));
end;

// 取编辑光标在屏幕的坐标
function GetCaretPosition(var Pt: TPoint): Boolean;
begin
  Result := Windows.GetCaretPos(Pt);
  if Result then
  begin
    Windows.ClientToScreen(Windows.GetFocus(), Pt);
  end;
end;

type
  TCnGetListClass = class
    FList: TStrings;
    procedure GetProc(const S: string);
  end;

procedure TCnGetListClass.GetProc(const S: string);
begin
  FList.Add(S);
end;  

// 取Cursor标识符列表
procedure GetCursorList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetCursorValues(GetProc);
  finally
    Free;
  end;
end;

// 取FontCharset标识符列表
procedure GetCharsetList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetCharsetValues(GetProc);
  finally
    Free;
  end;
end;

// 取Color标识符列表
procedure GetColorList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetColorValues(GetProc);
  finally
    Free;
  end;
end;

// 使控件处理标准编辑快捷键
function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;

  function SendMessageToActiveControl(Msg: Cardinal): Boolean;
  begin
    if (AControl is TCustomEdit) or (AControl is TCustomComboBox) then
    begin
      SendMessage(AControl.Handle, Msg, 0, 0);
      Result := True;
    end
    else
      Result := False;
  end;
begin
  if AControl = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  if AShortCut = ShortCut(Word('C'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_COPY)
  else if AShortCut = ShortCut(Word('X'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_CUT)
  else if AShortCut = ShortCut(Word('V'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_PASTE)
  else if AShortCut = ShortCut(Word('Z'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_UNDO)
  else if AShortCut = ShortCut(Word('A'), [ssCtrl]) then
  begin
    if AControl is TCustomEdit then
      TCustomEdit(AControl).SelectAll
    else if AControl is TCustomComboBox then
      TCustomComboBox(AControl).SelectAll
    else
      Result := False;
  end
  else
    Result := False;
end;

//==============================================================================
// 控件处理函数
//==============================================================================

// 返回组件的标题
function CnGetComponentText(Component: TComponent): string;
var
  Text: string;

  function GetCompPropText(const PropName: string; var AText: string): Boolean;
  var
    PInfo: PPropInfo;
  begin
    Result := False;
    PInfo := GetPropInfo(Component, PropName, [tkString, tkLString, tkWString
      {$IFDEF UNICODE_STRING}, tkUString{$ENDIF}]);
    if PInfo <> nil then
    begin
      AText := GetStrProp(Component, PInfo);
      Result := AText <> '';
    end;
  end;
begin
  Result := '';
  if Assigned(Component) then
  begin
    if Component is TCustomAction then
      Result := TCustomAction(Component).Caption
    else if Component is TMenuItem then
      Result := TMenuItem(Component).Caption
  {$IFDEF COMPILER6_UP}
    else if Component is TLabeledEdit then
      Result := TLabeledEdit(Component).EditLabel.Caption
  {$ENDIF}
    else if GetCompPropText('Caption', Text) or GetCompPropText('Text', Text) or
      GetCompPropText('Title', Text) or GetCompPropText('Filter', Text) or
      GetCompPropText('FieldName', Text) or GetCompPropText('TableName', Text) then
      Result := Text
    else if Component is TControl then
      Result := TControlAccess(Component).Text;
  end;
end;

// 取控件关联的 Action
function CnGetComponentAction(Component: TComponent): TBasicAction;
begin
  if Component is TControl then
    Result := TControl(Component).Action
  else if Component is TMenuItem then
    Result := TMenuItem(Component).Action
  else
    Result := nil;
end;

// 更新 ListView 控件，去除子项的 SubItemImages
procedure RemoveListViewSubImages(ListView: TListView); overload;
{$IFDEF BDS}
var
  i, j: Integer;
{$ENDIF}
begin
{$IFDEF BDS}
  for i := 0 to ListView.Items.Count - 1 do
    for j := 0 to ListView.Items[i].SubItems.Count - 1 do
      ListView.Items[i].SubItemImages[j] := -1;
{$ENDIF}
end;

// 更新 ListItem，去除子项的 SubItemImages
procedure RemoveListViewSubImages(ListItem: TListItem); overload;
{$IFDEF BDS}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF BDS}
  for I := 0 to ListItem.SubItems.Count - 1 do
      ListItem.SubItemImages[I] := -1;
{$ENDIF}
end;

{* 转换 ListView 子项宽度为字符串 }
function GetListViewWidthString(AListView: TListView): string;
var
  i: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    for i := 0 to AListView.Columns.Count - 1 do
      Lines.Add(IntToStr(AListView.Columns[i].Width));
    Result := Lines.CommaText;
  finally
    Lines.Free;
  end;
end;

{* 转换字符串为 ListView 子项宽度 }
procedure SetListViewWidthString(AListView: TListView; const Text: string);
var
  i: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.CommaText := Text;
    for i := 0 to Min(AListView.Columns.Count - 1, Lines.Count - 1) do
      AListView.Columns[i].Width := StrToIntDef(Lines[i], AListView.Columns[i].Width);
  finally
    Lines.Free;
  end;
end;

// ListView 当前选择项是否允许上移
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to AListView.Items.Count - 1 do
    if AListView.Items[i].Selected and not AListView.Items[i - 1].Selected then
    begin
      Result := True;
      Exit;
    end;
end;

// ListView 当前选择项是否允许下移
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := AListView.Items.Count - 2 downto 0 do
    if AListView.Items[i].Selected and not AListView.Items[i + 1].Selected then
    begin
      Result := True;
      Exit;
    end;
end;

// 修改 ListView 当前选择项
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
var
  i: Integer;
begin
  for i := 0 to AListView.Items.Count - 1 do
    if Mode = smAll then
      AListView.Items[i].Selected := True
    else if Mode = smNone then
      AListView.Items[i].Selected := False
    else
      AListView.Items[i].Selected := not AListView.Items[i].Selected;
end;

//==============================================================================
// 文件名判断处理函数 (来自 GExperts Src 1.12)
//==============================================================================

// 当前编辑的文件是Delphi源文件
function CurrentIsDelphiSource: Boolean;
begin
  Result := WizOptions.IsDelphiSource(CnOtaGetCurrentSourceFile);
end;

// 当前编辑的文件是C源文件
function CurrentIsCSource: Boolean;
begin
  Result := WizOptions.IsCSource(CnOtaGetCurrentSourceFile);
end;

// 当前编辑的文件是Delphi或C源文件
function CurrentIsSource: Boolean;
begin
{$IFDEF BDS}
  Result := (CurrentIsDelphiSource or CurrentIsCSource) and
    (CnOtaGetEditPosition <> nil);
{$ELSE}
  Result := CurrentIsDelphiSource or CurrentIsCSource;
{$ENDIF}
end;

// 当前编辑的源文件（非窗体）是Delphi源文件
function CurrentSourceIsDelphi: Boolean;
begin
  Result := WizOptions.IsDelphiSource(CnOtaGetCurrentSourceFileName);
end;

// 当前编辑的源文件（非窗体）是C源文件
function CurrentSourceIsC: Boolean;
begin
  Result := WizOptions.IsCSource(CnOtaGetCurrentSourceFileName);
end;

// 当前编辑的源文件（非窗体）是Delphi或C源文件
function CurrentSourceIsDelphiOrCSource: Boolean;
begin
  Result := CurrentSourceIsDelphi or CurrentSourceIsC;
end;

// 当前编辑的文件是窗体文件
function CurrentIsForm: Boolean;
begin
  Result := IsForm(CnOtaGetCurrentSourceFile);
end;

// 窗体编辑器对象是否 VCL 窗体（非 .NET 窗体）
function IsVCLFormEditor(FormEditor: IOTAFormEditor = nil): Boolean;
begin
  if FormEditor = nil then
    Result := CurrentIsForm
  else
  begin
{$IFDEF COMPILER6_UP}
    Result := IsForm(FormEditor.FileName);
{$ELSE}
    Result := True;
{$ENDIF}
  end;
end;
  
function ExtractUpperFileExt(const FileName: string): string;
begin
  Result := UpperCase(_CnExtractFileExt(FileName));
end;

procedure AssertIsDprOrPas(const FileName: string);
begin
  if not IsDprOrPas(FileName) then
    raise Exception.Create(SCnWizardForPasOrDprOnly);
end;

procedure AssertIsPasOrInc(const FileName: string);
begin
  if not (IsPas(FileName) or IsInc(FileName)) then
    raise Exception.Create(SCnWizardForPasOrIncOnly);
end;

procedure AssertIsDprOrPasOrInc(const FileName: string);
begin
  if not (IsDprOrPas(FileName) or IsInc(FileName)) then
    raise Exception.Create(SCnWizardForDprOrPasOrIncOnly);
end;

function IsSourceModule(const FileName: string): Boolean;
begin
  Result := IsDelphiSourceModule(FileName) or IsCppSourceModule(FileName);
end;

function IsDelphiSourceModule(const FileName: string): Boolean;
begin
  Result := IsDprOrPas(FileName);
end;

function IsDprOrPas(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.PAS') or (FileExt = '.DPR'));
end;

function IsDpr(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPR');
end;

function IsBpr(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPR');
end;

function IsProject(const FileName: string): Boolean;
begin
  Result := IsDpr(FileName) or IsBpr(FileName);
end;

function IsBdsProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BDSPROJ');
end;

function IsDProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPROJ');
end;

function IsCbProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.CBPROJ');
end;

function IsDpk(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPK');
end;

function IsBpk(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPK');
end;

function IsPackage(const FileName: string): Boolean;
begin
  Result := IsDpk(FileName) or IsBpk(FileName);
end;

function IsBpg(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPG')  or (FileExt = '.BDSGROUP') or (FileExt = '.GROUPPROJ');
end;

function IsPas(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.PAS');
end;

function IsDcu(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DCU');
end;

function IsInc(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.INC');
end;

function IsDfm(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.DFM');
end;

// 判断文件是否窗体
function IsForm(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DFM') or (FileExt = '.XFM');
{$IFDEF SUPPORTS_FMX}
  if not Result then
    Result := (FileExt = '.FMX');
{$ENDIF}
end;

function IsXfm(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.XFM');
end;

function IsFmx(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.FMX');
end;

function IsCppSourceModule(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.CPP') or (FileExt = '.C') or
             (FileExt = '.HPP') or (FileExt = '.H') or
             (FileExt = '.CXX') or (FileExt = '.CC') or
             (FileExt = '.HXX') or (FileExt = '.HH') or
             (FileExt = '.ASM'));
end;

function IsHpp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.HPP') or (FileExt = '.HH');
end;

function IsCpp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.CPP') or (FileExt = '.CC');
end;

function IsC(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.C');
end;

function IsH(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.H');
end;

function IsAsm(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.ASM');
end;

function IsRC(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.RC');
end;

function IsKnownSourceFile(const FileName: string): Boolean;
begin
  Result := IsDprOrPas(FileName) or IsCppSourceModule(FileName);
end;

function IsTypeLibrary(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.TLB')
          or (FileExt = '.OLB')
          or (FileExt = '.OCX')
          or (FileExt = '.DLL')
          or (FileExt = '.EXE'));
end;

function IsLua(const FileName: string): Boolean;
begin
  Result := IsSpecifiedExt(FileName, '.LUA');
end;

function IsSpecifiedExt(const FileName: string; const Ext: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := FileExt = UpperCase(Ext);
end;

// 使用字符串的方式判断对象是否继承自此类
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
var
  AClass: TClass;
begin
  Result := False;
  AClass := AObj.ClassType;
  while AClass <> nil do
  begin
    if AClass.ClassNameIs(AClassName) then
    begin
      Result := True;
      Exit;
    end;
    AClass := AClass.ClassParent;
  end;
end;

// 使用字符串的方式判断控件是否包含指定类名的子控件，存在则返回最上面一个
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
var
  I: Integer;
begin
  if AParent <> nil then
    for I := AParent.ControlCount - 1 downto 0 do // 倒序以先找到最上面的
      if AParent.Controls[I].ClassNameIs(AClassName) then
      begin
        Result := AParent.Controls[I];
        Exit;
      end;
  Result := nil;
end;


//==============================================================================
// OTA 接口操作相关函数
// 以下大部分代码修改自 GxExperts Src 1.11
//==============================================================================

// 查询输入的服务接口并返回一个指定接口实例，如果失败，返回假
function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
begin
  Result := (Instance <> nil) and Supports(Instance, Intf, Inst);
{$IFDEF Debug}
  if not Result then
    CnDebugger.LogMsgWithType('Query services interface fail: ' + GUIDToString(Intf), cmtError);
{$ENDIF Debug}
end;

// 取IOTAEditBuffer接口
function CnOtaGetEditBuffer: IOTAEditBuffer;
var
  iEditorServices: IOTAEditorServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, iEditorServices);
  if iEditorServices <> nil then
  begin
    Result := iEditorServices.GetTopBuffer;
    Exit;
  end;
  Result := nil;
end;

// 取IOTAEditPosition接口
function CnOtaGetEditPosition: IOTAEditPosition;
var
  iEditBuffer: IOTAEditBuffer;
begin
  iEditBuffer := CnOtaGetEditBuffer;
  if iEditBuffer <> nil then
  begin
    Result := iEditBuffer.GetEditPosition;
    Exit;
  end;
  Result := nil;
end;

// 根据文件名返回编辑器中打开的第一个 EditView，未打开时如 ForceOpen 为 True 则尝试打开，否则返回 nil
function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string;
  ForceOpen: Boolean): IOTAEditView;
var
  Editor: IOTAEditor;
  SrcEditor: IOTASourceEditor;
begin
  Result := nil;
  Editor := CnOtaGetEditor(FileName);
  if (Editor = nil) and not ForceOpen then
    Exit;

  if not CnOtaOpenFile(FileName) then
    Exit;

  if not Supports(Editor, IOTASourceEditor, SrcEditor) then
    Exit;

  if SrcEditor.EditViewCount = 0 then
    Exit;

  Result := SrcEditor.EditViews[0];
end;

// 取当前最前端的IOTAEditView接口
function CnOtaGetTopMostEditView: IOTAEditView;
var
  iEditBuffer: IOTAEditBuffer;
begin
  iEditBuffer := CnOtaGetEditBuffer;
  if iEditBuffer <> nil then
  begin
    Result := iEditBuffer.GetTopView;
    Exit;
  end;
  Result := nil;
end;

// 取指定编辑器最前端的IOTAEditView接口
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView;
var
  EditBuffer: IOTAEditBuffer;
begin
  if SourceEditor = nil then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor <> nil then
  begin
    QuerySvcs(SourceEditor, IOTAEditBuffer, EditBuffer);
    if EditBuffer <> nil then
    begin
      Result := EditBuffer.TopView;
      Exit;
    end
    else if SourceEditor.EditViewCount > 0 then
    begin
      Result := SourceEditor.EditViews[0];
      Exit;
    end;
  end;
  Result := nil;
end;

// 取当前最前端的 IOTAEditActions 接口
function CnOtaGetTopMostEditActions: IOTAEditActions;
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView <> nil then
  begin
    QuerySvcs(EditView, IOTAEditActions, Result);
    Exit;
  end;
  Result := nil;
end;

// 取当前模块
function CnOtaGetCurrentModule: IOTAModule;
var
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices <> nil then
  begin
    Result := iModuleServices.CurrentModule;
    Exit;
  end;
  Result := nil;
end;

// 取当前源码编辑器
function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
var
  EditBuffer: IOTAEditBuffer;
begin
  EditBuffer := CnOtaGetEditBuffer;
  if Assigned(EditBuffer) and (EditBuffer.FileName <> '') then
    Result := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, EditBuffer.FileName);
  if Result = nil then
    Result := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule);
end;

// 取模块编辑器 (来自 GExperts Src 1.12)
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
begin
  Result := nil;
  if not Assigned(Module) then Exit;
  try
    // BCB 5 下为一个简单的单元调用 GetModuleFileEditor(1) 会出错
    {$IFDEF BCB5}
    if IsCpp(Module.FileName) and (Module.GetModuleFileCount = 2) and (Index = 1) then
      Index := 2;
    {$ENDIF}
    Result := Module.GetModuleFileEditor(Index);
  except
    Result := nil; // 在 IDE 释放时，可能会有异常发生
  end;
end;

// 取窗体编辑器 (来自 GExperts Src 1.12)
function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
var
  i: Integer;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
begin
  if Assigned(Module) then
  begin
      for i := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := CnOtaGetFileEditorForModule(Module, i);
        if Supports(Editor, IOTAFormEditor, FormEditor) then
        begin
          Result := FormEditor;
          Exit;
        end;
      end;
  end;
  Result := nil;
end;

// 取当前窗体编辑器
function CnOtaGetCurrentFormEditor: IOTAFormEditor;
var
  Module: IOTAModule;
begin
  Module := CnOtaGetCurrentModule;
  if Assigned(Module) then
  begin    
    Result := CnOtaGetFormEditorFromModule(Module);
    Exit;
  end;   
  Result := nil;
end;

// 取得窗体编辑器的容器控件或 DataModule 的容器
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
var
  Root: TComponent;
begin
  { 支持为 Root 非 TWinControl 的设计对象取其 Container }
  Result := nil;
  Root := CnOtaGetRootComponentFromEditor(FormEditor);
  if Root is TWinControl then
  begin
    Result := Root as TWinControl;
    while Assigned(Result) and Assigned(Result.Parent) do
      Result := Result.Parent;
  end
  else if (Root is TDataModule) and (Root.Owner <> nil) and (Root.Owner is TWinControl) then
  begin
    // DataModule 实例的 Owner 是设计器容器 TDataModuleDesigner
    Result := TWinControl(Root.Owner);
  end;
end;

// 取得当前窗体编辑器的容器控件或 DataModule 的容器
function CnOtaGetCurrentDesignContainer: TWinControl;
begin
  if CurrentIsForm then
    Result := CnOtaGetDesignContainerFromEditor(CnOtaGetCurrentFormEditor)
  else
    Result := nil;
end;

// 取得当前窗体编辑器的已选择的控件
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  i: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for i := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(i);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
      begin
        if (Component is TControl) and Assigned(TControl(Component).Parent) then
          List.Add(Component);
{$IFDEF SUPPORTS_FMX}
        if CnFmxIsInheritedFromControl(Component) then
        begin
          if Assigned(CnFmxGetControlParent(Component)) then
            List.Add(Component);
        end;
{$ENDIF}
      end;
    end;
  end;

  Result := List.Count > 0;
end;

// 显示指定模块的窗体 (来自 GExperts Src 1.2)
function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
var
  FormEditor: IOTAFormEditor;
begin
  Result := False;
  if Module = nil then Exit;
  FormEditor := CnOtaGetFormEditorFromModule(Module);
  if Assigned(FormEditor) then
  begin
    FormEditor.Show;
    Result := True;
  end;
end;

// 取当前的窗体设计器
function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor): IDesigner;
var
  NTAFormEditor: INTAFormEditor;
begin
  if not Assigned(FormEditor) then
    FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);

  if (FormEditor = nil) or not IsVCLFormEditor(FormEditor) then
  begin
    Result := nil;
    Exit;
  end;
  QuerySvcs(FormEditor, INTAFormEditor, NTAFormEditor);
  if NTAFormEditor <> nil then
  begin
    Result := NTAFormEditor.GetFormDesigner;
    Exit;
  end;
  Result := nil;
end;

// 取当前设计器的类型，返回字符串 dfm 或 xfm
function CnOtaGetActiveDesignerType: string;
{$IFDEF COMPILER6_UP}
var
  Svcs: IOTAServices;
{$ENDIF}
begin
  Result := 'dfm';
{$IFDEF COMPILER6_UP}
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Result := Svcs.GetActiveDesignerType;
{$ENDIF}
end;

// 显示当前设计窗体
procedure CnOtaShowDesignerForm;
begin
  try
  {$IFDEF COMPILER6_UP}
    if (ComponentDesigner.ActiveRoot <> nil)
      and Assigned(ComponentDesigner.ActiveRoot.GetFormEditor) then
      ComponentDesigner.ActiveRoot.GetFormEditor.Show;
  {$ELSE}
    if Assigned(CompLib) and Assigned(CompLib.GetActiveForm)
      and (CompLib.GetActiveForm.GetFormEditor <> nil) then
      CompLib.GetActiveForm.GetFormEditor.Show;
  {$ENDIF}
  except
    ;
  end;
end;

// 取组件的名称
function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
var
{$IFDEF COMPILER6_UP}
  CompIntf: INTAComponent;
{$ELSE}
  CompIntf: IComponent;
{$ENDIF}
begin
  Result := False;
{$IFDEF COMPILER6_UP}
  CompIntf := Component as INTAComponent;
{$ELSE}
  CompIntf := Component.GetIComponent;
{$ENDIF}
  Name := '';
  if CompIntf = nil then
    Exit
  else
  begin
  {$IFDEF COMPILER6_UP}
    Name := CompIntf.GetComponent.Name;
  {$ELSE}
    Name := CompIntf.Name;
  {$ENDIF}
    Result := True;
  end;
end;

// 如果组件是 TControl，返回其标题
function CnOtaGetComponentText(Component: IOTAComponent): string;
var
  NTAComp: INTAComponent;
begin
  NTAComp := Component as INTAComponent;
  Result := CnGetComponentText(NTAComp.GetComponent);
end;

// 根据文件名返回模块接口
function CnOtaGetModule(const FileName: string): IOTAModule;
var
  ModuleServices: IOTAModuleServices;
begin
  Result := nil;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    Result := ModuleServices.FindModule(FileName);
end;

// 取当前工程中模块数，无工程返回 -1
function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
begin
  Result := -1;
  if Project <> nil then
    Result := Project.GetModuleCount;
end;

// 取当前工程中的第 Index 个模块信息，从 0 开始
function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
begin
  if Project <> nil then
    Result := Project.GetModule(Index)
  else
    Result := nil;
end;

// 根据文件名返回编辑器接口
function CnOtaGetEditor(const FileName: string): IOTAEditor;
var
  ModuleServices: IOTAModuleServices;
  i, j: Integer;
  Module: IOTAModule;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    for i := 0 to ModuleServices.ModuleCount - 1 do
    begin
      Module := ModuleServices.Modules[i];
      for j := 0 to Module.GetModuleFileCount - 1 do
        if SameFileName(FileName, Module.GetModuleFileEditor(j).FileName) then
        begin
          Result := Module.GetModuleFileEditor(j);
          Exit;
        end;
    end;
  Result := nil;
end;

// 返回窗体编辑器设计窗体组件
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
var
  Component: IOTAComponent;
  NTAComponent: INTAComponent;
begin
  if Assigned(Editor) and IsVCLFormEditor(Editor) then 
  begin
    try
      Component := Editor.GetRootComponent;
    except
      // 打开某些文件时会出错（Delphi5）
      Result := nil;
      Exit;
    end;
      
    if Assigned(Component) and QuerySvcs(Component, INTAComponent,
      NTAComponent) then
    begin
      Result := NTAComponent.GetComponent;
      Exit;
    end;
  end;
  Result := nil;
end;

// 取当前的 EditWindow
function CnOtaGetCurrentEditWindow: TCustomForm;
var
  EditView: IOTAEditView;
  EditWindow: INTAEditWindow;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    EditWindow := EditView.GetEditWindow;
    if Assigned(EditWindow) then
    begin
      Result := EditWindow.Form;
      Exit;
    end;
  end;
  Result := nil;
end;

// 取当前的 EditControl 控件
function CnOtaGetCurrentEditControl: TWinControl;
var
  EditWindow: TCustomForm;
  Comp: TComponent;
begin
  EditWindow := CnOtaGetCurrentEditWindow;
  if EditWindow <> nil then
  begin
    Comp := FindComponentByClassName(EditWindow, 'TEditControl', 'Editor');
    if (Comp <> nil) and (Comp is TWinControl) then
    begin
      Result := TWinControl(Comp);
      Exit;
    end;
  end;
  Result := nil;
end;

// 返回单元名称
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
begin
  Result := _CnExtractFileName(Editor.FileName);
end;

// 取当前工程组
function CnOtaGetProjectGroup: IOTAProjectGroup;
var
  IModuleServices: IOTAModuleServices;
{$IFNDEF BDS}
  IModule: IOTAModule;
  i: Integer;
{$ENDIF}
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
{$IFDEF BDS}
  Result := IModuleServices.MainProjectGroup;
{$ELSE}
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProjectGroup, Result) then
        Exit;
    end;
  Result := nil;
{$ENDIF}
end;

// 取当前工程组文件名
function CnOtaGetProjectGroupFileName: string;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProjectGroup: IOTAProjectGroup;
  i: Integer;
begin
  Result := '';
  IModuleServices := BorlandIDEServices as IOTAModuleServices;
  if IModuleServices = nil then Exit;
  
  IProjectGroup := nil;
  for i := 0 to IModuleServices.ModuleCount - 1 do
  begin
    IModule := IModuleServices.Modules[i];
    if IModule.QueryInterface(IOTAProjectGroup, IProjectGroup) = S_OK then
      Break;
  end;
  // Delphi 5 does not return the file path when querying IOTAProjectGroup directly
  if IProjectGroup <> nil then
    Result := IModule.FileName;
end;

// 取工程资源
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
var
  i: Integer;
  IEditor: IOTAEditor;
begin
  for i:= 0 to (Project.GetModuleFileCount - 1) do
  begin
    IEditor := Project.GetModuleFileEditor(i);
    if Supports(IEditor, IOTAProjectResource, Result) then
      Exit;
  end;
  Result := nil;
end;

// 取工程版本号字符串
function CnOtaGetProjectVersion(Project: IOTAProject = nil): string;
var
  Options: IOTAProjectOptions;
begin
  Result := '';
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then
    Exit;

  try
{$IFDEF VERSIONINFO_PER_CONFIGURATION}
    if Project = nil then
      Project := CnOtaGetCurrentProject;

    Result := Format('%d.%d.%d.%d',
      [StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_MajorVer')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_MinorVer')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_Release')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_Build')), 0)]);
{$ELSE}
    Result := Format('%d.%d.%d.%d',
      [StrToIntDef(VarToStr(Options.GetOptionValue('MajorVersion')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('MinorVersion')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('Release')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('Build')), 0)]);
{$ENDIF}
  except
    ;
  end;
end;

// 取当前工程
function CnOtaGetCurrentProject: IOTAProject;
var
  IProjectGroup: IOTAProjectGroup;
begin
  IProjectGroup := CnOtaGetProjectGroup;
  if Assigned(IProjectGroup) then
  begin
      try
        // This raises exceptions in D5 with .bat projects active
        Result := IProjectGroup.ActiveProject;
        Exit;
      except
        ;
      end;
  end;
  Result := nil;
end;

//设定项目配置值
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
begin
  Assert(Options <> nil, ' Options can not be null');
  Options.Values[AOption] := AValue;
end;

// 获得项目的当前Platform值，返回字符串，如不支持此特性则返回空字符串
function CnOtaGetProjectPlatform(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.CurrentPlatform;
{$ENDIF}
end;

// 获得项目的当前FrameworkType值，返回字符串，如不支持此特性则返回空字符串
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.FrameworkType;
{$ENDIF}
end;


// 获得当前项目的当前BuildConfiguration中的属性值，返回字符串，如不支持此特性则返回空字符串
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject;
  const APropName: string): string;
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
  Proj: IOTAProject;
  CurrPs: string;
{$ENDIF}
{$ENDIF}
begin
  Result := '';
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  BC := nil;
  POCS := CnOtaGetActiveProjectOptionsConfigurations(Project);
  if POCS <> nil then
  begin
    for I := 0 to POCS.GetConfigurationCount - 1 do
    begin
      if POCS.GetConfiguration(I).GetName = POCS.GetActiveConfiguration.GetName then
      begin
        BC := POCS.GetConfiguration(I);
        Break;
      end;
    end;

    if BC <> nil then
    begin
{$IFDEF SUPPORTS_CROSS_PLATFORM}
      Proj := Project; 
      if Proj = nil then
        Proj := CnOtaGetCurrentProject;

      CurrPs := '';
      if Proj <> nil  then
      begin
        CurrPs := Proj.CurrentPlatform;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('CnOtaGetProjectCurrentBuildConfigurationValue. Current Project Platform %s.', [CurrPs]);
{$ENDIF}
        for PS in BC.Platforms do
        begin
          PlatformConfig := BC.PlatformConfiguration[PS];
{$IFDEF DEBUG}
          CnDebugger.LogFmt('CnOtaGetProjectCurrentBuildConfigurationValue. Name %s, Platform %s, Value %s.',
            [APropName, PS, PlatformConfig.Value[APropName]]);
{$ENDIF}
          if PS = CurrPs then
            Result := PlatformConfig.Value[APropName];
        end;
      end;
{$ELSE}
      Result := BC.GetValue(APropName);
{$ENDIF}
    end;
  end;
{$ENDIF}
end;

// 设置当前项目的当前BuildConfiguration中的属性值
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject;const APropName,
  AValue: string);
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
  Proj: IOTAProject;
  CurrPs: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  BC := nil;
  POCS := CnOtaGetActiveProjectOptionsConfigurations(Project);

  if POCS <> nil then
  begin
    for I := 0 to POCS.GetConfigurationCount - 1 do
    begin
      if POCS.GetConfiguration(I).GetName = POCS.GetActiveConfiguration.GetName then
      begin
        BC := POCS.GetConfiguration(I);
        Break;
      end;
    end;

    if BC <> nil then
    begin
{$IFDEF SUPPORTS_CROSS_PLATFORM}
      Proj := Project;
      if Proj = nil then
        Proj := CnOtaGetCurrentProject;

      CurrPs := '';
      if Proj <> nil  then
      begin
        CurrPs := Proj.CurrentPlatform;
        for PS in BC.Platforms do
        begin
          PlatformConfig := BC.PlatformConfiguration[PS];
          if PS = CurrPs then
          begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('CnOtaSetProjectCurrentBuildConfigurationValue. Name %s, Platform %s, Value %s.',
            [APropName, PS, AValue]);
{$ENDIF}
            PlatformConfig.SetValue(APropName, AValue);
            Exit;
          end;
        end;
      end;
{$ELSE}
      BC.SetValue(APropName, AValue);
{$ENDIF}
    end;
  end;
{$ENDIF}
end;

{$IFDEF SUPPORTS_CROSS_PLATFORM}
// 获取 BuildConfiguration 的 Platforms 至 TStrings 中，以避免低版本与脚本不支持泛型的问题}
procedure CnOtaGetPlatformsFromBuildConfiguration(BuildConfig: IOTABuildConfiguration;
  Platforms: TStrings);
var
  S: string;
begin
  if (BuildConfig = nil) or (Platforms = nil) then
    Exit;

  Platforms.Clear;
  for S in BuildConfig.Platforms do
    Platforms.Add(S);
end;
{$ENDIF}

// 取得 IDE 设置变量名列表
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True);
var
  Names: TOTAOptionNameArray;
  i: Integer;
begin
  List.Clear;
  Names := nil;
  if not Assigned(Options) then Exit;

  Names := Options.GetOptionNames;
  try
    for i := Low(Names) to High(Names) do
      if IncludeType then
        List.Add(Names[i].Name + ': ' + GetEnumName(TypeInfo(TTypeKind),
          Ord(Names[i].Kind)))
      else
        List.Add(Names[i].Name);
  finally
    Names := nil;
  end;
end;

function CnOtaGetOptionsNames(Options: IOTAOptions; IncludeType:
  Boolean = True): string;
var
  List: TStringList;
begin
  Result := '';
  List := TStringList.Create;
  try
    CnOtaGetOptionsNames(Options, List, IncludeType);
    Result := List.Text;
  finally
    List.Free;
  end;
end;

// 取第一个工程
function CnOtaGetProject: IOTAProject;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  i: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProject, Result) then
        Exit;
    end;
  Result := nil;
end;

// 取当前工程组中工程数，无工程组返回 -1
function CnOtaGetProjectCountFromGroup: Integer;
begin
  Result := -1;
  if CnOtaGetProjectGroup <> nil then
    Result := CnOtaGetProjectGroup.GetProjectCount;
end;

// 取当前工程组中的第 Index 个工程，从 0 开始
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
begin
  if CnOtaGetProjectGroup <> nil then
    Result := CnOtaGetProjectGroup.GetProject(Index)
  else
    Result := nil;
end;

// 取得所有工程列表
procedure CnOtaGetProjectList(const List: TInterfaceList);
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProject: IOTAProject;
  i: Integer;
begin
  if not Assigned(List) then
    Exit;

  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProject, IProject) then
        List.Add(IProject);
    end;
end;

// 取当前工程名称
function CnOtaGetCurrentProjectName: string;
var
  IProject: IOTAProject;
begin
  Result := '';

  IProject := CnOtaGetCurrentProject;
  if Assigned(IProject) then
  begin
    Result := _CnExtractFileName(IProject.FileName);
    Result := _CnChangeFileExt(Result, '');
  end;
end;

// 取当前工程文件名称
function CnOtaGetCurrentProjectFileName: string;
var
  CurrentProject: IOTAProject;
begin
  CurrentProject := CnOtaGetCurrentProject;
  if Assigned(CurrentProject) then
    Result := CurrentProject.FileName
  else
    Result := '';
end;

// 取当前工程文件名称扩展
function CnOtaGetCurrentProjectFileNameEx: string;
begin
  // 修改以符合返回全路径的规则
  Result := _CnChangeFileExt((CnOtaGetCurrentProjectFileName), '');

  if Result <> '' then
    Exit;

  Result := _CnChangeFileExt((CnOtaGetProject.FileName), '');
  if Result <> '' then
    Exit;

  Result := Trim(Application.MainForm.Caption);
  Delete(Result, 1, AnsiPos('-', Result) + 1);
end;

// 取当前窗体名称
function CnOtaGetCurrentFormName: string;
var
  FormDesigner: IDesigner;
  AForm: TCustomForm;
  AFrame: TFrame;
begin
  Result := '';
  try
    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;
  {$IFDEF COMPILER6_UP}
    if FormDesigner.Root is TCustomForm then
    begin
      AForm := TCustomForm(FormDesigner.Root);
      Result := AForm.Name;
    end
    else
    if FormDesigner.Root is TFrame then
    begin
      AFrame := TFrame(FormDesigner.Root);
      Result := AFrame.Name;
    end;
  {$ELSE}
    if FormDesigner.GetRoot is TCustomForm then
    begin
      AForm := TCustomForm(FormDesigner.Form);
      Result := AForm.Name;
    end
    else
    if FormDesigner.GetRoot is TFrame then
    begin
      AFrame := TFrame(FormDesigner.GetRoot);
      Result := AFrame.Name;
    end;
  {$ENDIF}
  except
    ;
  end;
end;

// 取当前窗体文件名称
function CnOtaGetCurrentFormFileName: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  if Assigned(CurrentModule) then
    Result := _CnChangeFileExt(CurrentModule.FileName, '.dfm')
  else
    Result := '';
end;

// 取指定模块文件名，GetSourceEditorFileName 表示是否返回在代码编辑器中打开的文件
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean): string;
var
  i: Integer;
  Editor: IOTAEditor;
  SourceEditor: IOTASourceEditor;
begin
  Result := '';
  if Assigned(Module) then
    if not GetSourceEditorFileName then
      Result := Module.FileName
    else
      for i := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := Module.GetModuleFileEditor(i);
        if Supports(Editor, IOTASourceEditor, SourceEditor) then
        begin
          Result := Editor.FileName;
          Break;
        end;
      end;
end;

// 取当前模块文件名
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean): string;
begin
  Result := CnOtaGetFileNameOfModule(CnOtaGetCurrentModule, GetSourceEditorFileName);
end;

// 取当前环境设置
function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
var
  Svcs: IOTAServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Result := Svcs.GetEnvironmentOptions
  else
    Result := nil;
end;

// 取当前编辑器设置
function CnOtaGetEditOptions: IOTAEditOptions;
var
  Svcs: IOTAEditorServices;
begin
  Result := nil;
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, Svcs);
  if Assigned(Svcs) then
  begin
  {$IFDEF COMPILER7_UP}
    if Assigned(Svcs.GetTopBuffer) then
      Result := Svcs.GetTopBuffer.EditOptions
    else if Svcs.EditOptionsCount > 0 then
      Result := Svcs.GetEditOptionsIndex(0);
  {$ELSE}
    Result := Svcs.GetEditOptions;
  {$ENDIF}
  end;
end;

// 取当前工程选项
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
begin
  if Assigned(Project) then
  begin
    Result := Project.ProjectOptions;
    Exit;
  end;

  Project := CnOtaGetCurrentProject;
  if Assigned(Project) then
    Result := Project.ProjectOptions
  else
    Result := nil;
end;

// 取当前工程指定选项
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
var
  ProjectOptions: IOTAProjectOptions;
begin
  Result := False;
  Value := '';
  ProjectOptions := CnOtaGetActiveProjectOptions;
  if Assigned(ProjectOptions) then
  begin
    Value := ProjectOptions.Values[Option];
    Result := True;
  end;
end;

// 取当前包与组件服务
function CnOtaGetPackageServices: IOTAPackageServices;
begin
  if not QuerySvcs(BorlandIDEServices, IOTAPackageServices, Result) then
    Result := nil;
end;

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
// * 取当前工程配置选项，2009 后才有效
function CnOtaGetActiveProjectOptionsConfigurations
  (Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
var
  ProjectOptions: IOTAProjectOptions;
begin
  ProjectOptions := CnOtaGetActiveProjectOptions(Project);
  if ProjectOptions <> nil then
    if Supports(ProjectOptions, IOTAProjectOptionsConfigurations, Result) then
      Exit;

  Result := nil;
end;
{$ENDIF}

// 取环境设置中新建窗体的文件类型
function CnOtaGetNewFormTypeOption: TFormType;
var
  Options: IOTAEnvironmentOptions;
begin
  Result := ftUnknown;

  Options := CnOtaGetEnvironmentOptions;
  if not Assigned(Options) then Exit;

  case Options.Values['DFMAsText'] of
    -1: Result := ftText;
    0: Result := ftBinary;
  end;
end;

// 返回指定模块指定文件名的单元编辑器
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string): IOTASourceEditor;
var
  I: Integer;
  IEditor: IOTAEditor;
  ISourceEditor: IOTASourceEditor;
begin
  if not Assigned(Module) then
  begin
    Result := nil;
    Exit;
  end;

  for I := 0 to Module.GetModuleFileCount - 1 do
  begin
    IEditor := CnOtaGetFileEditorForModule(Module, I);

    if Supports(IEditor, IOTASourceEditor, ISourceEditor) then
    begin
      if Assigned(ISourceEditor) then
      begin
        if (FileName = '') or SameFileName(ISourceEditor.FileName, FileName) then
        begin
          Result := ISourceEditor;
          Exit;
        end;
      end;
    end;
  end;
  Result := nil;
end;

// 返回指定模块指定文件名的编辑器
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
var
  i: Integer;
  Editor: IOTAEditor;
begin
  Assert(Assigned(Module));
  for i := 0 to Module.GetModuleFileCount - 1 do
  begin
    Editor := CnOtaGetFileEditorForModule(Module, i);
    if SameFileName(Editor.FileName, FileName) then
    begin
      Result := Editor;
      Exit;
    end;
  end;
  Result := nil;
end;

// 返回指定模块的 EditActions 
function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
var
  i: Integer;
  EditView: IOTAEditView;
  SourceEditor: IOTASourceEditor;
begin
  if Module <> nil then
  begin
      SourceEditor := CnOtaGetSourceEditorFromModule(Module);
      if SourceEditor = nil then
      begin
        Result := nil;
        Exit;
      end;
      
      for i := 0 to SourceEditor.GetEditViewCount - 1 do
      begin
        EditView := SourceEditor.GetEditView(i);
        if Supports(EditView, IOTAEditActions, Result) then
          Exit;
      end;
  end;
  Result := nil;
end;

// 取当前选择的文本
function CnOtaGetCurrentSelection: string;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
begin
  Result := '';

  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if Assigned(EditBlock) then
    Result := EditBlock.Text;

{$IFDEF IDE_WIDECONTROL}
  Result := CnUtf8ToAnsi2(Result);
{$ENDIF}
end;

// 删除选中的文本
procedure CnOtaDeleteCurrentSelection;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
begin
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if Assigned(EditBlock) then
    EditBlock.Delete;
end;

// 用文本替换选中的文本
function CnOtaReplaceCurrentSelection(const Text: string; NoSelectionInsert:
  Boolean; KeepSelecting: Boolean; LineMode: Boolean): Boolean;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
  EditPos, InsPos: TOTAEditPos;
  StartPos, EndPos: TOTACharPos;
  LinearPos: Integer;
  InsertLen: Integer;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if not Assigned(EditBlock) or not EditBlock.IsValid then
  begin
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, StartPos);
    // 无选择区
    if not NoSelectionInsert then
      Exit;

    // 插入当前光标所在位置
    CnOtaInsertTextIntoEditor(Text);
  end
  else
  begin
    if LineMode then
    begin
      // 把块延伸到行头尾
      if not CnOtaGetBlockOffsetForLineMode(StartPos, EndPos, EditView) then
        Exit;

      CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('CnOtaReplaceCurrentSelection Line Selection %s', [EditBlock.Text]);
{$ENDIF}
    end;

    InsPos.Line := EditBlock.StartingRow;
    InsPos.Col := EditBlock.StartingColumn;

    EditView.ConvertPos(True, InsPos, StartPos); // 1 开始变成了 0 开始
    EditBlock.Delete;

    // EditBlock.Delete 后当前光标位置不确定，不能直接调用 CnOtaInsertTextIntoEditor
    // 来在当前光标位置处插入文本，否则可能产生插入位置偏差
    LinearPos := EditView.CharPosToPos(StartPos);
{$IFDEF UNICODE}
    CnOtaInsertTextIntoEditorAtPosW(Text, LinearPos);
{$ELSE}
    CnOtaInsertTextIntoEditorAtPos(Text, LinearPos);
{$ENDIF}
  end;

  EditBlock := nil;
  if KeepSelecting then
  begin
    // StartPos 此时是没选择区时的当前光标位置或有选择区的选择区头
    // InsertLen 参与线性偏移运算，是 Ansi(D7y以下) 或 Utf8 (D2007以上)的偏移。
{$IFDEF IDE_WIDECONTROL}
    InsertLen := Length(CnAnsiToUtf8(AnsiString(Text)));
{$ELSE}
    InsertLen := Length(Text);
{$ENDIF}

    LinearPos := EditView.CharPosToPos(StartPos); // 起始位置转为线性位置
    EndPos := EditView.PosToCharPos(LinearPos + InsertLen); // 线性位置加后转换为结束位置

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaReplaceCurrentSelection StartPos %d:%d. Linear %d. Insert Length %d. EndPos %d:%d',
//    [StartPos.Line, StartPos.CharIndex, LinearPos, InsertLen, EndPos.Line, EndPos.CharIndex]);
{$ENDIF}

    // 选中插入的内容，从 StartPos 到 EndPos 加线性位置
    CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
  end;
  Result := True;
end;

// 用文本替换选中的文本，参数是 Utf8 的 Ansi 字符串，可在 D2005~2007 下使用
function CnOtaReplaceCurrentSelectionUtf8(const Utf8Text: AnsiString;
  NoSelectionInsert: Boolean; KeepSelecting: Boolean; LineMode: Boolean): Boolean;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
  EditPos, InsPos: TOTAEditPos;
  StartPos, EndPos: TOTACharPos;
  LinearPos: Integer;
  InsertLen: Integer;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if not Assigned(EditBlock) or not EditBlock.IsValid then
  begin
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, StartPos);
    // 无选择区
    if not NoSelectionInsert then
      Exit;

    // 插入当前光标所在位置
    CnOtaInsertTextIntoEditorUtf8(Utf8Text);
  end
  else
  begin
    if LineMode then
    begin
      // 把块延伸到行头尾
      if not CnOtaGetBlockOffsetForLineMode(StartPos, EndPos, EditView) then
        Exit;

      CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('CnOtaReplaceCurrentSelection Line Selection %s', [EditBlock.Text]);
{$ENDIF}
    end;

    InsPos.Line := EditBlock.StartingRow;
    InsPos.Col := EditBlock.StartingColumn;

    EditView.ConvertPos(True, InsPos, StartPos); // 1 开始变成了 0 开始
    EditBlock.Delete;

    // EditBlock.Delete 后当前光标位置不确定，不能直接调用 CnOtaInsertTextIntoEditor
    // 来在当前光标位置处插入文本，否则可能产生插入位置偏差
    LinearPos := EditView.CharPosToPos(StartPos);
    CnOtaInsertTextIntoEditorAtPosUtf8(Utf8Text, LinearPos);
  end;

  EditBlock := nil;
  if KeepSelecting then
  begin
    // StartPos 此时是没选择区时的当前光标位置或有选择区的选择区头
    // InsertLen 参与线性偏移运算，是 Utf8 (D2007以上) 的偏移。
    InsertLen := Length(Utf8Text);
    LinearPos := EditView.CharPosToPos(StartPos); // 起始位置转为线性位置
    EndPos := EditView.PosToCharPos(LinearPos + InsertLen); // 线性位置加后转换为结束位置

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaReplaceCurrentSelection StartPos %d:%d. Linear %d. Insert Length %d. EndPos %d:%d',
//    [StartPos.Line, StartPos.CharIndex, LinearPos, InsertLen, EndPos.Line, EndPos.CharIndex]);
{$ENDIF}

    // 选中插入的内容，从 StartPos 到 EndPos 加线性位置
    CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
  end;
  Result := True;
end;

// 在编辑器中退格
procedure CnOtaEditBackspace(Many: Integer);
var
  EditPosition: IOTAEditPosition;
  EditView: IOTAEditView;
begin
  EditPosition := CnOtaGetEditPosition;
  if Assigned(EditPosition) then
  begin
    EditPosition.BackspaceDelete(Many);
    EditView := CnOtaGetTopMostEditView;
    if Assigned(EditView) then
      EditView.Paint;
  end;
end;

// 在编辑器中删除
procedure CnOtaEditDelete(Many: Integer);
var
  EditPosition: IOTAEditPosition;
  EditView: IOTAEditView;
begin
  EditPosition := CnOtaGetEditPosition;
  if Assigned(EditPosition) then
  begin
    EditPosition.Delete(Many);
    EditView := CnOtaGetTopMostEditView;
    if Assigned(EditView) then
      EditView.Paint;
  end;
end;

{$IFNDEF CNWIZARDS_MINIMUM}
// 获取当前光标所在的过程或函数名
function CnOtaGetCurrentProcedure: string;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  PasParser: TCnPasStructureParser;
  CParser: TCnCppStructureParser;
  S: string;
begin
  Result := '';
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  S := EditView.Buffer.FileName;
  Stream := TMemoryStream.Create;
  CnOtaSaveEditorToStream(EditView.Buffer, Stream);
  try
    if IsDprOrPas(S) or IsInc(S) then
    begin
      PasParser := TCnPasStructureParser.Create;
      try
        PasParser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(EditView.Buffer.FileName), False);

        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
        if PasParser.CurrentChildMethod <> '' then
          Result := string(PasParser.CurrentChildMethod)
        else if PasParser.CurrentMethod <> '' then
          Result := string(PasParser.CurrentMethod);
      finally
        PasParser.Free;
      end;
    end
    else if IsCppSourceModule(S) then
    begin
      CParser := TCnCppStructureParser.Create;

      try
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        // 是否需要转换？
        CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
          CharPos.Line, CharPos.CharIndex, True);

        Result := string(CParser.CurrentMethod);
      finally
        CParser.Free;
      end;
    end;
  finally
    Stream.Free;
  end;
end;

// 获取当前光标所在的类名或声明
function CnOtaGetCurrentOuterBlock: string;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
begin
  Result := '';
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Parser := TCnPasStructureParser.Create;
  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), False);
  finally
    Stream.Free;
  end;

  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Result := string(Parser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex));
  Parser.Free;
end;

// 取指定行的源代码，行号以 1 开始，返回结果为 Ansi/Unicode，非 UTF8
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
var
  L1, L2: Integer;
  Reader: IOTAEditReader;
  View: IOTAEditView;
  OutStr: AnsiString;
begin
  Result := '';
  if LineNum < 1 then
  begin
    Count := Count + LineNum - 1;
    LineNum := 1;
  end;
  if Count <= 0 then Exit;

  if not Assigned(EditBuffer) then
    EditBuffer := CnOtaGetEditBuffer;
  if LineNum > EditBuffer.GetLinesInBuffer then Exit;

  if Assigned(EditBuffer) then
  begin
    View := EditBuffer.TopView;
    if Assigned(View) then
    begin
      L1 := View.CharPosToPos(OTACharPos(0, LineNum));
      L2 := View.CharPosToPos(OTACharPos(csMaxLineLength, Min(LineNum +
        Count - 1, EditBuffer.GetLinesInBuffer)));
      SetLength(OutStr , L2 - L1);
      Reader := EditBuffer.CreateReader;
      try
        Reader.GetText(L1, PAnsiChar(OutStr), L2 - L1);
      finally
        Reader := nil;
      end;
      {$IFDEF UNICODE}
      Result := ConvertEditorTextToTextW(OutStr);
      {$ELSE}
      Result := string(ConvertEditorTextToText(OutStr));
      {$ENDIF}

    {$IFDEF UNICODE_STRING}
      // 此函数在 D2009 下 Result 长度不对，需要 TrimRight
      Result := TrimRight(Result);
    {$ENDIF}
    end;
  end;
end;

// 取当前行源代码
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
var
  L1, L2: Integer;
  Reader: IOTAEditReader;
  EditBuffer: IOTAEditBuffer;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  OutStr: AnsiString;
begin
  Result := False;
  if not Assigned(View) then
    View := CnOtaGetTopMostEditView;
  if not Assigned(View) then Exit;

  EditPos := View.CursorPos;
  View.ConvertPos(True, EditPos, CharPos);
  LineNo := CharPos.Line;
  CharIndex := CharPos.CharIndex;

  EditBuffer := View.Buffer;
  L1 := CnOtaEditPosToLinePos(OTAEditPos(1, LineNo), EditBuffer.TopView);
  if (LineNo >= View.Buffer.GetLinesInBuffer) then
    L2 := CnOtaEditPosToLinePos(OTAEditPos(High(SmallInt), LineNo + 1), EditBuffer.TopView)
  else
    L2 := CnOtaEditPosToLinePos(OTAEditPos(1, LineNo + 1), EditBuffer.TopView) - 2;
  SetLength(OutStr, L2 - L1);
  Reader := EditBuffer.CreateReader;
  try
    Reader.GetText(L1, PAnsiChar(OutStr), L2 - L1);
  finally
    Reader := nil;
  end;
  {$IFDEF UNICODE}
  Text := TrimRight(ConvertEditorTextToTextW(OutStr));
  {$ELSE}
  Text := TrimRight(string(ConvertEditorTextToText(OutStr)));
  {$ENDIF}
  Result := True;
end;


// 使用 NTA 方法取当前行源代码。速度快，但取回的文本是将 Tab 扩展成空格的。
// 如果使用 ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1
// 赋值给 EditPos.Col 即可
// D7 及以下取到的是AnsiString，CursorPos.Col 是编辑器中状态栏的 Col - 1，一致。
//   可以直接根据 CharIndex 处理 Text
// BDS 非 Unicode 下取到的是 UTF8 格式的 AnsiString，CursorPos.Col 是 UTF8 格式的 Col - 1，和编辑器中状态栏显示的对不上号
//   也可以直接根据 CharIndex 处理 Text，但要注意双字节字符变成了仨字节
// Unicode IDE 下取得的是 UTF16 字符串，CursorPos.Col 是 Ansi 格式的 Col - 1，和编辑器中状态栏显示的一致
//   如果要根据 CharIndex 处理 Text，则需要将 Text 转换为 AnsiString
{
  以如下表格为准：
                      获取的 Text 格式   CharIndex(CursorPos.Col)  编辑器状态栏的真实列状况（Ansi）   TOTACharPos

  Delphi5/6/7         Ansi               同左、一致                同左、一致                         Ansi

  Delphi 2005~2007    Ansi with UTF8     同左、与 UTF8 一致        Ansi、与 UTF8 不一致               Utf8

  Delphi 2009~        UTF16              Ansi、与 UTF16 不一致     同左 Ansi、与 UTF16 不一致         Utf8，为啥？
}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
var
  EditControl: TControl;
  View: IOTAEditView;
begin
  Result := False;
  EditControl := GetCurrentEditControl;
  View := CnOtaGetTopMostEditView;
  if (EditControl <> nil) and (View <> nil) then
  begin
    Text := GetStrProp(EditControl, 'LineText');
    // LineText 在 D5~D7 下为 AnsiString，在 D2005~2007 下是包含 UTF8 字符的 AnsiString
    // 在 D2009 以上直接是 UnicodeString

    //CnDebugger.TraceFmt('Col %d, Len %d, Text %s', [View.CursorPos.Col - 1, Length(Text), Text]);

{$IFDEF UNICODE}
    CharIndex := Min(View.CursorPos.Col - 1, Length(AnsiString(Text)));
{$ELSE}
    CharIndex := Min(View.CursorPos.Col - 1, Length(Text));
{$ENDIF}
    LineNo := View.CursorPos.Line;
    Result := True;
  end;
end;

{$IFDEF UNICODE}

// 使用 NTA 方法取当前行源代码的Unicode版本。速度快，但取回的文本是将 Tab 扩展成空格的。
// 如果使用 ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1
// 赋值给 EditPos.Col 即可。
// Unicode IDE 下取得的是 UTF16 字符串与 UTF16 的偏移量}
function CnNtaGetCurrLineTextW(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
var
  EditControl: TControl;
  View: IOTAEditView;
begin
  Result := False;
  EditControl := GetCurrentEditControl;
  View := CnOtaGetTopMostEditView;
  if (EditControl <> nil) and (View <> nil) then
  begin
    Text := GetStrProp(EditControl, 'LineText');

    // CursorPos 反映的是 Ansi （非UTF8）方式的列，需要把 string 转成 Ansi 后才能
    // 得到光标对应到 Text 中的真实位置
    CharIndex := Length(string(Copy(AnsiString(Text), 1, View.CursorPos.Col - 1)));

    LineNo := View.CursorPos.Line;
    Result := True;
  end;
end;

{$ENDIF}

// 返回 SourceEditor 当前行信息
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
var
  LineText: string;
begin
  Result := CnNtaGetCurrLineText(LineText, LineNo, CharIndex);
  if Result then
    LineLen := Length(LineText);
end;

// 取当前光标下的标识符及光标在标识符中的索引号，速度较快
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  AnsiText: AnsiString;
  i: Integer;

  function _IsValidIdentChar(C: AnsiChar; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
      Result := IsValidIdentChar(Char(C), First)
    else
      Result := CharInSet(Char(C), FirstSet + CharSet);
  end;

begin
  Token := '';
  CurrIndex := 0;
  Result := False;

  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if (EditView <> nil) and CnNtaGetCurrLineText(LineText, LineNo, CharIndex) and
    (LineText <> '') then
  begin
    //CnDebugger.TraceFmt('CharIndex %d, LineText %s', [CharIndex, LineText]);
    if CheckCursorOutOfLineEnd and CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
      Exit;

    if _UNICODE_STRING and CodePageOnlySupportsEnglish then // 纯英文 Unicode 环境下不能直接转 Ansi
      AnsiText := ConvertUtf16ToAlterAnsi(PWideChar(LineText), 'C')
    else
      AnsiText := AnsiString(LineText);

    i := CharIndex;
    CurrIndex := 0;
    // 查找起始字符
    while (i > 0) and _IsValidIdentChar(AnsiText[i], False) do
    begin
      Dec(i);
      Inc(CurrIndex);
    end;
    Delete(AnsiText, 1, i);

    // 查找结束字符
    i := 1;
    while (i <= Length(AnsiText)) and _IsValidIdentChar(AnsiText[i], False) do
      Inc(i);
    Delete(AnsiText, i, MaxInt);
    Token := string(AnsiText);
  end;

  if Token <> '' then
  begin
    if CharInSet(Token[1], FirstSet) or IsValidIdent(Token) then
      Result := True;
  end;

  if not Result then
    Token := '';
end;

{$IFDEF UNICODE}

// 取当前光标下的标识符及光标在标识符中的索引号的 Unicode 版本，允许 Unicode 标识符
function CnOtaGetCurrPosTokenW(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCharSet = [];
  CharSet: TCharSet = []; EditView: IOTAEditView = nil): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  i: Integer;

  function _IsValidIdentChar(C: Char; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
      Result := IsValidIdentChar(C, First) or (Ord(C) > 127)
    else
      Result := CharInSet(Char(C), FirstSet + CharSet);
  end;

  function StrHasUnicodeChar(const S: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Length(S) = 0 then
      Exit;
    for I := 0 to Length(S) - 1 do
    begin
      if Ord(S[I]) > 127 then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

begin
  Token := '';
  CurrIndex := 0;
  Result := False;

  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if (EditView <> nil) and CnNtaGetCurrLineTextW(LineText, LineNo, CharIndex) and
    (LineText <> '') then
  begin
    // CnDebugger.TraceFmt('CharIndex %d, LineText %s', [CharIndex, LineText]);
    if CheckCursorOutOfLineEnd then
    begin
      if StrHasUnicodeChar(LineText) then
      begin
        // CnOtaIsEditPosOutOfLine 的判断在当前行文字有宽字节字符时可能不准
        // 改用直接判断，两者都是 UTF16，可直接判断。
        if CharIndex > Length(LineText) then
          Exit;
      end
      else
      begin
        if CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
          Exit;
      end;
    end;

    i := CharIndex;
    CurrIndex := 0;
    // 查找起始字符
    while (i > 0) and _IsValidIdentChar(LineText[i], False) do
    begin
      Dec(i);
      Inc(CurrIndex);
    end;
    Delete(LineText, 1, i);

    // 查找结束字符
    i := 1;
    while (i <= Length(LineText)) and _IsValidIdentChar(LineText[i], False) do
      Inc(i);
    Delete(LineText, i, MaxInt);
    Token := LineText;
  end;

  if Token <> '' then
  begin
    if CharInSet(Token[1], FirstSet) or IsValidIdentW(Token) then
      Result := True;
  end;

  if not Result then
    Token := '';
end;

{$ENDIF}

// 取当前光标下的字符，允许偏移量
function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
var
  CharIndex: Integer;
  LineText: string;
  LineNo: Integer;
begin
  Result := #0;
  if (View = nil) or (View = CnOtaGetTopMostEditView) then
  begin
    if CnOtaGetCurrLineText(LineText, LineNo, CharIndex) then
    begin
      CharIndex := CharIndex + OffsetX + 1;
      if (CharIndex > 0) and (CharIndex <= Length(LineText)) then
        Result := LineText[CharIndex];
    end;
  end
  else if CnOtaGetCurrLineText(LineText, LineNo, CharIndex, View) then
  begin
    CharIndex := CharIndex + OffsetX + 1;
    if (CharIndex > 0) and (CharIndex <= Length(LineText)) then
      Result := LineText[CharIndex];
  end;
end;

function _DeleteCurrToken(DelLeft, DelRight: Boolean; FirstSet: TAnsiCharSet;
  CharSet: TAnsiCharSet): Boolean;
var
  Token: string;
  CurrIndex: Integer;
  EditPos: IOTAEditPosition;
begin
  Result := False;
  if CnOtaGetCurrPosToken(Token, CurrIndex, True, FirstSet, CharSet) then
  begin
    EditPos := CnOtaGetEditPosition;
    if Assigned(EditPos) then
    begin
      if DelLeft and DelRight then
      begin
        EditPos.MoveRelative(0, Length(Token) - CurrIndex);
        EditPos.BackspaceDelete(Length(Token));
      end
      else if DelLeft and (CurrIndex > 0) then
        EditPos.BackspaceDelete(CurrIndex)
      else if DelRight and (CurrIndex < Length(Token) - 1) then
      begin
        EditPos.MoveRelative(0, Length(Token) - CurrIndex);
        EditPos.BackspaceDelete(Length(Token) - CurrIndex);
      end;
      Result := True;
    end;
  end;
end;

// 删除当前光标下的标识符
function CnOtaDeleteCurrToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(True, True, FirstSet, CharSet);
end;

// 删除当前光标下的标识符左半部分
function CnOtaDeleteCurrTokenLeft(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(True, False, FirstSet, CharSet);
end;

// 删除当前光标下的标识符右半部分
function CnOtaDeleteCurrTokenRight(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(False, True, FirstSet, CharSet);
end;

// 判断位置是否超出行尾了。此机制在 Unicode 环境下当前行含有宽字符时可能会不准，慎用
// 一般 Unicode 环境下，行内含有几个宽字符，使用 ConvertPos 就会可能产生几列的偏差，
// 也即超过行尾再加几列才会判断为超出行尾，而且这个规则还不靠谱，需要另做处理
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView): Boolean;
var
  APos: TOTAEditPos;
  CPos: TOTACharPos;
{$IFDEF UNICODE}
  EditControl: TControl;
  S: AnsiString;
  I, Idx, Len: Integer;
  HasWide: Boolean;
{$ENDIF}
begin
  Result := True;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.ConvertPos(True, EditPos, CPos);
    View.ConvertPos(False, APos, CPos);
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaIsEditPosOutOfLine EditPos: %d,%d. APos %d,%d.',
//   [EditPos.Line, EditPos.Col, APos.Line, APos.Col]);
{$ENDIF}
    Result := not SameEditPos(EditPos, APos);

{$IFDEF UNICODE}
    // Unicode 环境下可能有误差，补算一把
    EditControl := EditControlWrapper.GetEditControl(View);
    if EditControl = nil then
      Exit;

    // 使用 EditControlWrapper.GetTextAtLine 较快获取行文字，并且 Tab 已展开
    S := AnsiString(TrimRight(EditControlWrapper.GetTextAtLine(EditControl, EditPos.Line)));
    if S = '' then
      Exit;

    HasWide := False;
    Idx := -1;
    Len := Length(S);

    for I := 1 to Len do
    begin
      if Ord(S[I]) > 127 then
      begin
        HasWide := True;
        Idx := I;
        Break;
      end;
    end;

    if not HasWide then
      Exit;
    if EditPos.Col < Idx + 1 then
      Exit;

    // Unicode 环境下含有双字节字符时，并且需要判断的位置在第一个双字节字符后时
    // 可能有偏差，换这种判断方式。
    Result := EditPos.Col > Len + 1; // Col is 0 based.
{$ENDIF}
  end;  
end;
{$ENDIF}

// 选择一个代码块
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
var
  View: IOTAEditView;
  Ed: IOTASourceEditor;
begin
  Ed := Editor;
  if Ed = nil then
  begin
    View := CnOtaGetTopMostEditView;
    if View = nil then
      Exit;
    Ed := View.GetBuffer;
  end;

  if Ed = nil then
    Exit;

  Ed.BlockVisible := False;
  try
    Ed.BlockType := btNonInclusive;
    Ed.BlockStart := Start;
    Ed.BlockAfter := After;
  finally
    Ed.BlockVisible := True;
  end;
end;

// 用 Block 的方式设置代码块选区，返回是否成功
function CnOtaMoveAndSelectBlock(const Start, After: TOTACharPos; View: IOTAEditView): Boolean;
var
  Block: IOTAEditBlock;
  Row, Col: Integer;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  Row := Start.Line;       // 2005~2007 下 Col 为 0 会导致光标随机出现在行中间所以必须限制最小为 1
  Col := Start.CharIndex;
  if Col <= 0 then
    Col := 1;

  View.Position.Move(Row, Col);
  Block := View.Block;
  if Block = nil then
    Exit;

  Block.Reset;
  Block.Style := btNonInclusive;
  Block.BeginBlock;

  Row := After.Line;
  Col := After.CharIndex;
  if Col <= 0 then
    Col := 1;

  View.Position.Move(Row, Col);
  Block.EndBlock;
  Result := True;
end;

// 用 Block Extend 的方式选中一行，返回是否成功，光标处于行首
function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView): Boolean;
var
  Position: IOTAEditPosition;
  Block: IOTAEditBlock;
  EndRow, EndCol: Integer;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  Position := View.Position;
  Block := View.Block;
  Block.Save;
  try
    Position.Move(LineNum, 1);
    Position.MoveEOL;
    Position.Save;
    try
      Position.MoveBOL;
      EndRow := Position.Row;
      EndCol := Position.Column;
    finally
      Position.Restore;
    end;
  finally
    Block.Restore;
  end;
  Block.Extend(EndRow, EndCol);
  View.Paint;

  Result := True;
end;

// 用 Block Extend 的方式选中多行，光标停留在 End 行所标识的地方，返回是否成功
function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer;
  View: IOTAEditView = nil): Boolean;
var
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
  EndRow, EndCol: Integer;
begin
  if StartLineNum = EndLineNum then
    Result := CnOtaMoveAndSelectLine(StartLineNum, View)
  else
  begin
    Result := False;
    if View = nil then
      View := CnOtaGetTopMostEditView;
    if View = nil then
      Exit;

    Position := View.Position;
    Block := View.Block;
    Block.Save;
    try
      Position.Move(StartLineNum, 1);
      if StartLineNum > EndLineNum then
        Position.MoveEOL
      else
        Position.MoveBOL;

      Position.Save;
      try
        Position.Move(EndLineNum, 1);
        if StartLineNum > EndLineNum then
          Position.MoveBOL
        else
          Position.MoveEOL;
        EndRow := Position.Row;
        EndCol := Position.Column;
      finally
        Position.Restore;
      end;
    finally
      Block.Restore;
    end;
    Block.Extend(EndRow, EndCol);
    View.Paint;

    Result := True;
  end;
end;

// 直接用起止行列为参数选中代码块，均以一开始，返回是否成功
function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
var
  Start, After: TOTACharPos;
  R1, R2, C1, C2, T: Integer;
begin
  R1 := OneBasedStartRow;
  R2 := OneBasedEndRow;
  C1 := OneBasedStartCol;
  C2 := OneBasedEndCol;

  // 如果起始位置大于结束位置，则互换
  if (R1 > R2) or ((R1 = R2) and (C1 > C2)) then
  begin
    T := R1; R1 := R2; R2 := T;
    T := C1; C1 := C2; C2 := T;
  end;

  Start.Line := R1;
  Start.CharIndex := C1;
  After.Line := R2;
  After.CharIndex := C2;

  Result := CnOtaMoveAndSelectBlock(Start, After, View);
end;

// 返回当前选择的块是否为空
function CnOtaCurrBlockEmpty: Boolean;
var
  View: IOTAEditView;
begin
  Result := True;
  View := CnOtaGetTopMostEditView;
  if Assigned(View) and View.Block.IsValid then
    Result := False;
end;

// 返回当前选择的块扩展成行模式后的起始位置，不实际扩展选择区
function CnOtaGetBlockOffsetForLineMode(var StartPos: TOTACharPos; var EndPos: TOTACharPos;
  View: IOTAEditView = nil): Boolean;
var
  Block: IOTAEditBlock;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if Assigned(View) and View.Block.IsValid then
  begin
    Block := View.Block;
    StartPos.Line := Block.StartingRow;
    StartPos.CharIndex := 1;
    EndPos.Line := Block.EndingRow;
    EndPos.CharIndex := Block.EndingColumn;
    if EndPos.CharIndex > 1 then
    begin
      if EndPos.Line < View.Buffer.GetLinesInBuffer then
      begin
        Inc(EndPos.Line);
        EndPos.CharIndex := 1;
      end
      else
        EndPos.CharIndex := 1024; // 用个大数代替行尾
    end;
    Result := True;
  end;
end;

// 打开文件
function CnOtaOpenFile(const FileName: string): Boolean;
var
  ActionServices: IOTAActionServices;
begin
  Result := False;
  try
    ActionServices := BorlandIDEServices as IOTAActionServices;
    if ActionServices <> nil then
      Result := ActionServices.OpenFile(FileName);
  except
    ;
  end;            
end;

// 打开未保存的窗体
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
var
  iModuleServices: IOTAModuleServices;
begin
  Result := False;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices <> nil then
    Result := CnOtaShowFormForModule(iModuleServices.FindFormModule(FormName));
end;

// 判断文件是否打开
function CnOtaIsFileOpen(const FileName: string): Boolean;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FileEditor: IOTAEditor;
  i: Integer;
begin
  Result := False;

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
  begin
    for i := 0 to Module.GetModuleFileCount-1 do
    begin
      FileEditor := CnOtaGetFileEditorForModule(Module, i);
      Assert(Assigned(FileEditor));

      Result := CompareText(FileName, FileEditor.FileName) = 0;
      if Result then
        Exit;
    end;
  end;
end;

// 关闭文件
procedure CnOtaCloseFile(const FileName: string; ForceClosed: Boolean);
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
begin
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
    Module.CloseModule(ForceClosed);
end;

// 判断窗体是否打开
function CnOtaIsFormOpen(const FormName: string): Boolean;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
  i: Integer;
begin
  Result := False;

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindFormModule(FormName);
  if Assigned(Module) then
  begin
    for i := 0 to Module.GetModuleFileCount-1 do
    begin
      FormEditor := CnOtaGetFormEditorFromModule(Module);

      Result := Assigned(FormEditor);
      if Result then
        Exit;
    end;
  end;
end;

// 判断模块是否已被修改
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to AModule.GetModuleFileCount - 1 do
    if AModule.GetModuleFileEditor(i).Modified then
    begin
      Result := True;
      Exit;
    end;
end;

// 取模块的单元文件名
function CnOtaGetBaseModuleFileName(const FileName: string): string;
var
  AltName: string;
begin
  Result := FileName;
  if IsForm(FileName) then
  begin
    {$IFDEF BCB}
    AltName := _CnChangeFileExt(FileName, '.cpp');
    if CnOtaIsFileOpen(AltName) or FileExists(AltName) then
      Result := AltName;
    {$ENDIF BCB}
    AltName := _CnChangeFileExt(FileName, '.pas');
    if CnOtaIsFileOpen(AltName) or FileExists(AltName) then
      Result := AltName;
  end;
end;

// 当前是否在调试状态
function CnOtaIsDebugging: Boolean;
var
  DebugScvs: IOTADebuggerServices;
begin
  Result := False;
  QuerySvcs(BorlandIDEServices, IOTADebuggerServices, DebugScvs);
  if Assigned(DebugScvs) then
    Result := DebugScvs.ProcessCount > 0;
end;

// 让指定文件可见
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer): Boolean;
var
  EditActions: IOTAEditActions;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
  SourceEditor: IOTASourceEditor;
  FileEditor: IOTAEditor;
  i: Integer;
  BaseFileName: string;
begin
  Result := False;

  BaseFileName := CnOtaGetBaseModuleFileName(FileName);
  Module := CnOtaGetModule(BaseFileName);

  if Module <> nil then
  begin
    if IsForm(FileName) then
    begin
      if not CnOtaModuleIsShowingFormSource(Module) then
      begin
        SourceEditor := CnOtaGetSourceEditorFromModule(Module, BaseFileName);
        if Assigned(SourceEditor) then
          SourceEditor.Show;
        SourceEditor := nil;
        EditActions := CnOtaGetEditActionsFromModule(Module);
        if EditActions <> nil then
        begin
          FormEditor := CnOtaGetFormEditorFromModule(Module);
          FormEditor.Show;
          EditActions.SwapSourceFormView;
          Result := True;
        end;
      end;
    end
    else // We are focusing a regular text file, not a form
    begin
      if CnOtaModuleIsShowingFormSource(Module) then
      begin
        SourceEditor := CnOtaGetSourceEditorFromModule(Module);
        if Assigned(SourceEditor) then
          SourceEditor.Show;
        SourceEditor := nil;
        EditActions := CnOtaGetEditActionsFromModule(Module);
        if EditActions <> nil then
        begin
          EditActions.SwapSourceFormView;
          Result := True;
        end;
      end
      else
        Result := True;
    end;
  end;

  if not CnOtaIsFileOpen(BaseFileName) then
    Result := CnOtaOpenFile(FileName);

  // D5 sometimes delays opening the file until messages are processed
  Application.ProcessMessages;

  if Result then
  begin
    Module := CnOtaGetModule(BaseFileName);
    if Module <> nil then
    begin
      for i := 0 to Module.GetModuleFileCount-1 do
      begin
        FileEditor := Module.GetModuleFileEditor(i);
        Assert(Assigned(FileEditor));

        if CompareText(FileEditor.FileName, FileName) = 0 then
        begin
          FileEditor.Show;
          if Lines > 0 then
          begin
            Supports(FileEditor, IOTASourceEditor, SourceEditor);
            if (SourceEditor <> nil) and (SourceEditor.EditViewCount > 0) then
            begin
              SourceEditor.EditViews[0].Center(Lines, 1);
              SourceEditor.EditViews[0].Paint;
            end;
          end;
          Exit;
        end;
      end;
    end;
    Result := False;
  end;
end;

// 指定模块是否以文本窗体方式显示
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
var
  Editor: IOTAEditor;
begin
  Result := False;
  if Module.GetModuleFileCount = 1 then
  begin
    Editor := CnOtaGetFileEditorForModule(Module, 0);
    Assert(Assigned(Editor));
    if IsForm(Editor.GetFileName) then
      Result := True;
  end;
end;

// 当前 PersistentBlocks 是否为 True
function CnOtaIsPersistentBlocks: Boolean;
var
  EnvOptions: IOTAEnvironmentOptions;
begin
  Result := False;
  try
    EnvOptions := CnOtaGetEnvironmentOptions;
    if Assigned(EnvOptions) then
      Result := EnvOptions.Values['PersistentBlocks'];
  except
    ;
  end;
end;

// 使用 CnWizDebuggerNotifierServices 获取当前源文件内的断点，List 中返回 TCnBreakpointDescriptor 实例
procedure CnOtaGetCurrentBreakpoints(Results: TList);
begin
  if Results <> nil then
    CnWizDebuggerNotifierServices.RetrieveBreakpoints(Results, CnOtaGetCurrentSourceFileName);
end;

//==============================================================================
// 源代码操作相关函数
//==============================================================================

// 字符串转为源代码串
function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean; MaxLen: Integer): string;
var
  Strings: TStrings;
  i, J: Integer;
  s, Line, SingleLine: string;
{$IFDEF UNICODE}
  TmpLine: string;
{$ELSE}
  TmpLine: WideString;
{$ENDIF}
  IsDelphi: Boolean;
begin
  Result := '';
  IsDelphi := CurrentIsDelphiSource;
  if Str = '' then
  begin
    if IsDelphi then
      Result := ''''''
    else
      Result := '""';
    Exit;
  end;

  Strings := TStringList.Create;
  try
    if Wrap then                     // 是否插入换行符
      s := CRLF
    else
      s := '';
        
    Strings.Text := Str;
    for i := 0 to Strings.Count - 1 do
    begin
      Line := Strings[i];

      if MaxLen <= 1 then
      begin
        for J := Length(Line) downto 1 do
        begin
          if IsDelphi then             // Delphi 将 ' 号转换为 ''
          begin
            if Line[J] = '''' then
              Insert('''', Line, J);
          end
          else begin                   // C++Builder 将 " 号转换为 \"
            if Line[J] = '"' then
              Insert('\', Line, J);
          end;
        end;
      end
      else
      begin
        // 把 Line 按长度劈成多个字符串，然后分别转换，然后再拼起来。
        // ANSI 模式下要考虑宽字符串的问题，所以转成 WideString 处理。
        TmpLine := Line;
        Line := '';
        repeat
          SingleLine := string(Copy(TmpLine, 1, MaxLen));
          Delete(TmpLine, 1, MaxLen);

          for J := Length(SingleLine) downto 1 do
          begin
            if IsDelphi then             // Delphi 将 ' 号转换为 ''
            begin
              if SingleLine[J] = '''' then
                Insert('''', SingleLine, J);
            end
            else begin                   // C++Builder 将 " 号转换为 \"
              if SingleLine[J] = '"' then
                Insert('\', SingleLine, J);
            end;
          end;

          if Line = '' then
            Line := SingleLine
          else
            Line := Line + ''' + ''' + SingleLine;
        until Length(TmpLine) = 0;
      end;

      if IsDelphi then
      begin
        if i = Strings.Count - 1 then  // 最后一行不加换行符
        begin
          if Line <> '' then
            Result := Format('%s''%s''', [Result, Line])
          else
            Delete(Result, Length(Result) - Length(' + ' + s) + 1,
              Length(' + ' + s));
        end
        else
        begin
          if Trim(ADelphiReturn) <> '' then
          begin
            if Wrap or (Line <> '') then
              Result := Format('%s''%s'' + %s + %s', [Result, Line, ADelphiReturn, s])
            else
              Result := Result + ADelphiReturn + ' + ' + s;
          end
          else
          begin
            if Wrap or (Line <> '') then
              Result := Format('%s''%s'' + %s', [Result, Line, s])
            else
              Result := Result + s;
          end;
        end;
      end
      else
      begin
        if i = Strings.Count - 1 then
          Result := Format('%s"%s"', [Result, Line])
        else
          Result := Format('%s"%s%s" %s', [Result , Line, ACReturn, s]);
      end;
    end;
  finally
    Strings.Free;
  end;
end;

// 长代码自动切换为多行代码
function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
var
  Strings: TStrings;
  i: Integer;
begin
  if Length(Code) <= Width then
  begin
    Result := Code;
    Exit;
  end;
  
  Result := StrLeft(Code, Indent); // 先处理第一行由于缩进多出来的字符
  Delete(Code, 1, Indent);
  
  Strings := TStringList.Create;
  try
    Strings.Text := WrapText(Code, #13#10, [' '], Width - Indent);
    Result := Result + Strings[0] + #13#10;
    for i := 1 to Strings.Count - 1 do
      if (i = 1) or not IndentOnceOnly then
        Result := Result + Spc(Indent) + Trim(Strings[i]) + #13#10  // 考虑缩进
      else
        Result := Result + Strings[i] + #13#10;
    Delete(Result, Length(Result) - 1, 2); // 删除后面的换行符
  finally
    Strings.Free;
  end;
end;

{$IFDEF COMPILER6_UP}
// 快速转换Utf8到Ansi字符串，适用于长度短且主要是Ansi字符的字符串
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
var
  i, l, Len: Cardinal;
  IsMultiBytes: Boolean;
  P: PDWORD;
begin
  if Text <> '' then
  begin
    Len := Length(Text);
    l := Len and $FFFFFFFC;
    P := PDWORD(@Text[1]);
    IsMultiBytes := False;
    for i := 0 to l div 4 do
    begin
      if P^ and $80808080 <> 0 then
      begin
        IsMultiBytes := True;
        Break;
      end;
      Inc(P);  
    end;
    
    if not IsMultiBytes then
    begin
      for i := l + 1 to Len do
      begin
        if Ord(Text[i]) and $80 <> 0 then
        begin
          IsMultiBytes := True;
          Break;
        end;  
      end;  
    end;

    if IsMultiBytes then
      Result := CnUtf8ToAnsi(Text)
    else
      Result := Text;
  end
  else
    Result := '';
end;

{$ENDIF}

{$IFDEF UNICODE}

// Unicode 环境下转换字符串为编辑器使用的字符串，避免 AnsiString 转换
function ConvertTextToEditorUnicodeText(const Text: string): string;
begin
  Result := Text;
end;

{$ENDIF}

// 转换字符串为编辑器使用的字符串
function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
begin
{$IFDEF IDE_WIDECONTROL}
  // 只适合于非 Unicode 环境的 BDS。Unicode 环境下，直接用其 string 即可
  Result := CnAnsiToUtf8(Text);
{$ELSE}
  Result := Text;
{$ENDIF}
end;

// 转换编辑器使用的字符串为普通字符串
function ConvertEditorTextToText(const Text: AnsiString): AnsiString;
begin
{$IFDEF IDE_WIDECONTROL}
  // 只适合于非 Unicode 环境的 BDS。Unicode 环境下，直接用其 string 即可
  Result := CnUtf8ToAnsi(Text);
{$ELSE}
  // 只适合于 D7 及以下
  Result := Text;
{$ENDIF}
end;

{$IFDEF IDE_WIDECONTROL}

// 转换宽字符串为编辑器使用的字符串(UTF8)，D2005~2007 版本使用
function ConvertWTextToEditorText(const Text: WideString): AnsiString;
begin
  Result := Utf8Encode(Text);
end;

// 转换编辑器使用的字符串(UTF8)为宽字符串，D2005~2007 版本使用
function ConvertEditorTextToWText(const Text: AnsiString): WideString;
begin
  Result := UTF8Decode(Text);
end;

{$ENDIF}

{$IFDEF UNICODE}

// 转换字符串为编辑器使用的字符串(UTF8)，D2009 以上版本使用
function ConvertTextToEditorTextW(const Text: string): AnsiString;
begin
  Result := Utf8Encode(Text);
end;

// 转换编辑器使用的字符串(UTF8)为 Unicode 字符串，D2009 以上版本使用
function ConvertEditorTextToTextW(const Text: AnsiString): string;
begin
  Result := UTF8ToUnicodeString(Text);
end;

{$ENDIF}

// 取当前编辑的源文件  (来自 GExperts Src 1.12，有改动)
function CnOtaGetCurrentSourceFile: string;
{$IFDEF COMPILER6_UP}
var
  iModule: IOTAModule;
  iEditor: IOTAEditor;
begin
  iModule := CnOtaGetCurrentModule;
  if iModule <> nil then
  begin
    iEditor := iModule.GetCurrentEditor;
    if iEditor <> nil then
    begin
      Result := iEditor.FileName;
      if Result <> '' then
        Exit;
    end;
  end;
  Result := '';
{$IFDEF BCB}  // BCB 下可能存在无法获得当前工程的cpp文件的问题，特此加上此功能
  if (Result = '') and (CnOtaGetEditBuffer <> nil) then
    Result := CnOtaGetEditBuffer.FileName;
{$ENDIF}
end;
{$ELSE}
begin
  // Delphi5/BCB5/K1 下仍然要采用旧的方式
  Result := ToolServices.GetCurrentFile;
end;
{$ENDIF}

// 取当前编辑的 Pascal 或 C 源文件，判断限制较多
function CnOtaGetCurrentSourceFileName: string;
var
  TmpName: string;
begin
  Result := CnOtaGetCurrentSourceFile;
  if IsForm(Result) then
  begin
    TmpName := _CnChangeFileExt(Result, '.pas');
    if CnOtaIsFileOpen(TmpName) then
      Result := TmpName
    else
    begin
      TmpName := _CnChangeFileExt(Result, '.cpp');
      if CnOtaIsFileOpen(TmpName) then
        Result := TmpName
      else
      begin
        TmpName := _CnChangeFileExt(Result, '.h');
        if CnOtaIsFileOpen(TmpName) then
          Result := TmpName
        else
        begin
          TmpName := _CnChangeFileExt(Result, '.cc');
          if CnOtaIsFileOpen(TmpName) then
            Result := TmpName
          else
          begin
            TmpName := _CnChangeFileExt(Result, '.hh');
            if CnOtaIsFileOpen(TmpName) then
              Result := TmpName
          end;
        end;
      end;
    end;
  end
  else
  begin
    if not (IsDprOrPas(Result) or IsTypeLibrary(Result) or IsInc(Result)
      or IsCpp(Result) or IsC(Result) or IsHpp(Result) or IsH(Result)) then
    begin
      // ErrorDlg(SPasOrDprOrCPPOnly, mtError, [mbOK], 0)
      Result := '';
    end;
  end;
end;

// 在 EditPosition 中插入一段文本，支持 D2005 下使用 utf-8 格式
procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);
begin
{$IFDEF UNICODE_STRING}
  EditPosition.InsertText(Text); // InsertText 在 Unicode 环境里使用 Unicode 字符串，无需 Utf8 转换
{$ELSE}
  EditPosition.InsertText(ConvertTextToEditorText(Text));
{$ENDIF}
end;

// 插入一段文本到当前正在编辑的源文件中，返回成功标志
function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos): Boolean;
var
  iEditPosition: IOTAEditPosition;
  iEditView: IOTAEditView;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditView := CnOtaGetTopMostEditView;
    if iEditView = nil then Exit;
    if not CnOtaMovePosInCurSource(InsertPos, 0, 0) then Exit;
    CnOtaPositionInsertText(iEditPosition, Text);
    iEditView.Paint;
    Result := True;
  except
    ;
  end;
end;

// 获得当前编辑的源文件中光标的位置，返回成功标志
function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    Col := iEditPosition.Column;
    Row := iEditPosition.Row;
    Result := True;
  except
    ;
  end;
end;

// 设定当前编辑的源文件中光标的位置，返回成功标志
function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, Col);
    Result := True;
  except
    ;
  end;
end;

// 设定当前编辑的源文件中光标的位置，返回成功标志
function CnOtaSetCurSourceCol(Col: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(iEditPosition.Row, Col);
    Result := True;
  except
    ;
  end;
end;

// 设定当前编辑的源文件中光标的位置，返回成功标志
function CnOtaSetCurSourceRow(Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, iEditPosition.Column);
    Result := True;
  except
    ;
  end;
end;

// 在当前源文件中移动光标
function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    case Pos of
      ipFileHead: if not iEditPosition.Move(1, 1) then Exit;
      ipFileEnd: if not iEditPosition.MoveEOF then Exit;
      ipLineHead: if not iEditPosition.MoveBOL then Exit;
      ipLineEnd: if not iEditPosition.MoveEOL then Exit;
    end;
    if (OffsetRow <> 0) or (OffsetCol <> 0) then
      if not iEditPosition.MoveRelative(OffsetRow, OffsetCol) then Exit;
    Result := True;
  except
    ;
  end;
end;

// 返回 SourceEditor 当前光标位置的线性地址
function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor): Integer;
var
  CharPos: TOTACharPos;
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor.EditViewCount > 0 then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;
    IEditView.ConvertPos(True, EditPos, CharPos);
    Result := IEditView.CharPosToPos(CharPos);
    if Result < 0 then Result := 0;
  end
  else
    Result := 0;
end;

// 返回 SourceEditor 当前光标位置
function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor): TOTACharPos;
var
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(SourceEditor) and (SourceEditor.EditViewCount > 0) then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;
    IEditView.ConvertPos(True, EditPos, Result);
  end
  else
  begin
    Result.CharIndex := 0;
    Result.Line := 0;
  end;
end;

// 编辑位置转换为线性位置
function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
var
  CharPos: TOTACharPos;
begin
  if EditView = nil then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    EditView.ConvertPos(True, EditPos, CharPos);
    Result := EditView.CharPosToPos(CharPos);
  end
  else
    Result := 0;
end;

// 线性位置转换为编辑位置
function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
var
  CharPos: TOTACharPos;
begin
  if EditView = nil then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    CharPos := CnOtaGetCharPosFromPos(LinePos, EditView);
    EditView.ConvertPos(False, Result, CharPos);
  end
  else
  begin
    Result.Col := 0;
    Result.Line := 0;
  end;
end;

// 保存EditReader内容到流中，流中的内容默认为 Ansi 格式
procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
const
  // Leave typed constant as is - needed for streaming code.
  TerminatingNulChar: Char = #0;
  BufferSize = 1024 * 24;
var
  Buffer: PAnsiChar;
  EditReaderPos: Integer;
  DataLen: Integer;
  ReadDataSize: Integer;
{$IFDEF IDE_WIDECONTROL}
  Text: AnsiString;
{$ENDIF}

{$IFDEF UNICODE}
  UniText: string;
{$ENDIF}

begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaSaveReaderToStream. StartPos %d, EndPos %d, PreSize %d.',
//    [StartPos, EndPos, PreSize]);
{$ENDIF}

  if EndPos > 0 then
  begin
    DataLen := EndPos - StartPos;
    Stream.Size := DataLen + 1;
  end
  else
  begin
    // 分配预计的内存以提高性能
    DataLen := MaxInt;
    Stream.Size := PreSize;
  end;
  Stream.Position := 0;
  GetMem(Buffer, BufferSize);
  try
    EditReaderPos := StartPos;
    ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
    Inc(EditReaderPos, ReadDataSize);
    Dec(DataLen, ReadDataSize);
    while (ReadDataSize = BufferSize) and (DataLen > 0) do
    begin
      Stream.Write(Buffer^, ReadDataSize);
      ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
      Inc(EditReaderPos, ReadDataSize);
      Dec(DataLen, ReadDataSize);
    end;
    Stream.Write(Buffer^, ReadDataSize);
    Stream.Write(TerminatingNulChar, SizeOf(TerminatingNulChar));
    if Stream.Size > Stream.Position then
      Stream.Size := Stream.Position;
  finally
    FreeMem(Buffer);
  end;

{$IFDEF IDE_WIDECONTROL}
  if CheckUtf8 then
  begin
    AlternativeWideChar := AlternativeWideChar and _UNICODE_STRING and CodePageOnlySupportsEnglish;

    if AlternativeWideChar then
    begin
{$IFDEF UNICODE}
      // Unicode 环境里在纯英文 OS 下不能按照后面的转 Ansi，以免丢字符。
      // 需要转成 UTF16 的再硬替成 Ansi。
      UniText := Utf8Decode(PAnsiChar(Stream.Memory));
      Text := ConvertUtf16ToAlterAnsi(PWideChar(UniText));
{$ELSE}
      Text := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
{$ENDIF}
    end
    else
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
    end;
    Stream.Size := Length(Text) + 1;
    Stream.Position := 0;
    Stream.Write(PAnsiChar(Text)^, Length(Text) + 1);
  end;
{$ENDIF}

  Stream.Position := 0;
end;

// 保存编辑器文本到流中
procedure CnOtaSaveEditorToStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  CnOtaSaveReaderToStream(Editor.CreateReader, Stream, StartPos, EndPos, PreSize, CheckUtf8, AlternativeWideChar);
end;

// 保存编辑器文本到流中
function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
var
  IPos: Integer;
  PreSize: Integer;
begin
  Assert(Stream <> nil);
  Result := False;

  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  if Editor.EditViewCount > 0 then
  begin
    if FromCurrPos then
      IPos := CnOtaGetCurrPos(Editor)
    else
      IPos := 0;

    // 如果此文件未保存，则会出现 FileSize 与其不一致的情况，
    // 可能导致 PreSize 为负从而出现问题
    if FileExists(Editor.FileName) then
      PreSize := Round(GetFileSize(Editor.FileName) * 1.5) - IPos
    else
      PreSize := 0;

    // 修补上述问题
    if PreSize < 0 then
      PreSize := 0;

    CnOtaSaveEditorToStreamEx(Editor, Stream, IPos, 0, PreSize, CheckUtf8, AlternativeWideChar);
    Result := True;
  end;
end;

// 保存当前编辑器文本到流中
function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
begin
  Result := CnOtaSaveEditorToStream(nil, Stream, FromCurrPos, CheckUtf8, AlternativeWideChar);
end;

// 取得当前编辑器源代码
function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean): string;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    if CnOtaSaveCurrentEditorToStream(Strm, False, CheckUtf8) then
      Result := string(PAnsiChar(Strm.Memory));
  finally
    Strm.Free;
  end;
end;

{$IFDEF UNICODE}

// 保存 EditReader 内容到流中，流中的内容默认为 Unicode 格式，2009 以上使用
procedure CnOtaSaveReaderToStreamW(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
const
  // Leave typed constant as is - needed for streaming code.
  TerminatingNulChar: AnsiChar = #0;
  BufferSize = 1024 * 24;
var
  Buffer: PAnsiChar;
  EditReaderPos: Integer;
  DataLen: Integer;
  ReadDataSize: Integer;
  Text: string;
begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaSaveReaderToStreamW. StartPos %d, EndPos %d, PreSize %d.',
//    [StartPos, EndPos, PreSize]);
{$ENDIF}

  if EndPos > 0 then
  begin
    DataLen := EndPos - StartPos;
    Stream.Size := DataLen + 1;
  end
  else
  begin
    // 分配预计的内存以提高性能
    DataLen := MaxInt;
    Stream.Size := PreSize;
  end;
  Stream.Position := 0;
  GetMem(Buffer, BufferSize);
  try
    EditReaderPos := StartPos;
    ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
    Inc(EditReaderPos, ReadDataSize);
    Dec(DataLen, ReadDataSize);
    while (ReadDataSize = BufferSize) and (DataLen > 0) do
    begin
      Stream.Write(Buffer^, ReadDataSize);
      ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
      Inc(EditReaderPos, ReadDataSize);
      Dec(DataLen, ReadDataSize);
    end;
    Stream.Write(Buffer^, ReadDataSize);
    Stream.Write(TerminatingNulChar, SizeOf(TerminatingNulChar));
    if Stream.Size > Stream.Position then
      Stream.Size := Stream.Position;
  finally
    FreeMem(Buffer);
  end;

  // 即使 Unicode 环境下，EditReader 读到的仍然是 Utf8 的 AnsiString，在此转成 UnicodeString
  Text := UTF8ToUnicodeString(PAnsiChar(Stream.Memory));
  Stream.Size := (Length(Text) + 1) * SizeOf(Char);
  Stream.Position := 0;
  Stream.Write(PChar(Text)^, (Length(Text) + 1) * SizeOf(Char));

  Stream.Position := 0;
end;

// 保存编辑器文本到流中，Unicode 版本，2009 以上使用
procedure CnOtaSaveEditorToStreamWEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  CnOtaSaveReaderToStreamW(Editor.CreateReader, Stream, StartPos, EndPos, PreSize);
end;

// 保存编辑器文本到流中，Unicode 版本，2009 以上使用
function CnOtaSaveEditorToStreamW(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
var
  IPos: Integer;
  PreSize: Integer;
begin
  Assert(Stream <> nil);
  Result := False;

  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  if Editor.EditViewCount > 0 then
  begin
    if FromCurrPos then
      IPos := CnOtaGetCurrPos(Editor)
    else
      IPos := 0;

    // 如果此文件未保存，则会出现 FileSize 与其不一致的情况，
    // 可能导致 PreSize 为负从而出现问题
    if FileExists(Editor.FileName) then
      PreSize := Round(GetFileSize(Editor.FileName) * 1.5) - IPos
    else
      PreSize := 0;

    // 修补上述问题
    if PreSize < 0 then
      PreSize := 0;

    CnOtaSaveEditorToStreamWEx(Editor, Stream, IPos, 0, PreSize);
    Result := True;
  end;
end;

// 保存当前编辑器文本到流中，Unicode 版本，2009 以上使用
function CnOtaSaveCurrentEditorToStreamW(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
begin
  Result := CnOtaSaveEditorToStreamW(nil, Stream, FromCurrPos);
end;

// 取得当前编辑器源代码，Unicode 版本，2009 以上使用
function CnOtaGetCurrentEditorSourceW: string;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    if CnOtaSaveCurrentEditorToStreamW(Stream, False) then
      Result := string(PChar(Stream.Memory));
  finally
    Stream.Free;
  end;
end;

// 设置当前编辑器源代码，Unicode 版本，2009 以上使用
procedure CnOtaSetCurrentEditorSourceW(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}

// 设置当前编辑器源代码，只在 D2005~2007 版本使用，参数为原始 UTF8 内容
procedure CnOtaSetCurrentEditorSourceUtf8(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
    EditWriter.Insert(PAnsiChar(Text));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

// 设置当前编辑器源代码
procedure CnOtaSetCurrentEditorSource(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
  {$IFDEF UNICODE_STRING}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
  {$ENDIF}
  finally
    EditWriter := nil;
  end;
end;

// 插入一个字符串到当前 IOTASourceEditor，仅在 Text 为单行文本时有用
procedure CnOtaInsertLineIntoEditor(const Text: string);
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    CnOtaPositionInsertText(EditView.Position, Text);
    EditView.Paint;
  end;
end;

// 插入一行文本当前 IOTASourceEditor，Line 为行号，Text 为单行
procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    if Line > 1 then
    begin
      // 先插入一个换行
      EditView.Position.Move(Line - 1, 1);
      EditView.Position.MoveEOL;
    end
    else
    begin
      EditView.Position.Move(1, 1);
    end;
    CnOtaPositionInsertText(EditView.Position, CRLF);
    // 再插入文本以避免下一行自动缩进
    EditView.Position.Move(Line, 1);
    CnOtaPositionInsertText(EditView.Position, Text);
    EditView.Paint;
  end;
end;

// 插入文本到当前 IOTASourceEditor，允许多行文本。
procedure CnOtaInsertTextIntoEditor(const Text: string);
var
  EditView: IOTAEditView;
  Position: Longint;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
begin
  EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Position := EditView.CharPosToPos(CharPos);
{$IFDEF UNICODE}
  CnOtaInsertTextIntoEditorAtPosW(Text, Position);
{$ELSE}
  CnOtaInsertTextIntoEditorAtPos(Text, Position);
{$ENDIF}
  EditView.MoveViewToCursor;
  EditView.Paint;
end;

procedure CnOtaInsertTextIntoEditorUtf8(const Utf8Text: AnsiString);
var
  EditView: IOTAEditView;
  Position: Longint;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
begin
  EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Position := EditView.CharPosToPos(CharPos);
  CnOtaInsertTextIntoEditorAtPosUtf8(Utf8Text, Position);
  EditView.MoveViewToCursor;
  EditView.Paint;
end;

// 为指定 SourceEditor 返回一个 Writer，如果输入为空返回当前值。
function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
resourcestring
  SEditWriterNotAvail = 'Edit writer not available';
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(SourceEditor) then
    Result := SourceEditor.CreateUndoableWriter;
  Assert(Assigned(Result), SEditWriterNotAvail);
end;

// 在指定位置处插入文本，如果 SourceEditor 为空使用当前值。
procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
  {$IFDEF UNICODE_STRING}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
  {$ENDIF}
  finally
    EditWriter := nil;
  end;
end;

procedure CnOtaInsertTextIntoEditorAtPosUtf8(const Utf8Text: AnsiString; Position: Longint;
  SourceEditor: IOTASourceEditor);
var
  EditWriter: IOTAEditWriter;
begin
  if Utf8Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
    EditWriter.Insert(PAnsiChar(Utf8Text));
  finally
    EditWriter := nil;
  end;
end;

{$IFDEF UNICODE}

// 在指定位置处插入文本，如果 SourceEditor 为空使用当前值，D2009 以上使用。
procedure CnOtaInsertTextIntoEditorAtPosW(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW((Text))));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

// 移动光标到指定位置，如果 EditView 为空使用当前值。
procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView; Middle: Boolean);
var
  CurPos: TOTAEditPos;
  CharPos: TOTACharPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));

  CharPos := CnOtaGetCharPosFromPos(Position, EditView);
  CurPos.Col := CharPos.CharIndex + 1;
  CurPos.Line := CharPos.Line;
  CnOtaGotoEditPos(CurPos, EditView, Middle);
end;

// 返回当前光标位置，如果 EditView 为空使用当前值。
function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
    Result := EditView.CursorPos
  else
  begin
    Result.Col := 0;
    Result.Line := 0;
  end;
end;

// 移动光标到指定位置，如果 EditView 为空使用当前值。
procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView; Middle: Boolean);
var
  TopRow: TOTAEditPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
//  Assert(Assigned(EditView));
  if EditView = nil then
    Exit;

  if EditPos.Line < 1 then
    EditPos.Line := 1;
  TopRow := EditPos;
  if Middle then
    TopRow.Line := TopRow.Line - (EditView.ViewSize.cy div 2) + 1;
  if TopRow.Line < 1 then
    TopRow.Line := 1;
  TopRow.Col := 1;
  EditView.TopPos := TopRow;

  EditView.CursorPos := EditPos;
  Application.ProcessMessages;
  EditView.Paint;
end;

// 转换一个线性位置到 TOTACharPos，因为在 D5/D6 下 IOTAEditView.PosToCharPos
// 可能不能正常工作
function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
var
  EditWriter: IOTAEditWriter;
begin
  Assert(Assigned(EditView));
  EditWriter := EditView.Buffer.CreateUndoableWriter;
  try
    Assert(Assigned(EditWriter));
    EditWriter.CopyTo(Position);
    Result := EditWriter.CurrentPos;
  finally
    EditWriter := nil;
  end;          
end;

// 获得当前编辑器块缩进宽度 
function CnOtaGetBlockIndent: Integer;
var
  EditOptions: IOTAEditOptions;
begin
  EditOptions := CnOtaGetEditOptions;
  if Assigned(EditOptions) then
    Result := EditOptions.GetBlockIndent
  else
    Result := 2;
end;

// 关闭模块视图
procedure CnOtaClosePage(EditView: IOTAEditView);
var
  EditActions: IOTAEditActions;
begin
  if not Assigned(EditView) then Exit;
  QuerySvcs(EditView, IOTAEditActions, EditActions);
  if Assigned(EditActions) then
    EditActions.ClosePage;
end;

// 仅关闭模块的视图，而不关闭模块
procedure CnOtaCloseEditView(AModule: IOTAModule);
var
  Editor: IOTASourceEditor;
  View: IOTAEditView;
begin
  Editor := CnOtaGetSourceEditorFromModule(AModule);
  if Editor = nil then Exit;
  View := CnOtaGetTopMostEditView(Editor);
  if View = nil then Exit;
  Editor.Show;
  CnOtaClosePage(View);
end;

//==============================================================================
// 窗体操作相关函数
//==============================================================================

// 取得当前设计的窗体及选择的组件列表，返回成功标志
function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList;
  ExcludeForm: Boolean): Boolean;
var
  i: Integer;
  AObj: TPersistent;
  FormDesigner: IDesigner;
  AList: IDesignerSelections;
begin
  Result := False;
  try
    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;
  {$IFDEF COMPILER6_UP}
    if FormDesigner.Root is TCustomForm then
      AForm := TCustomForm(FormDesigner.Root);
  {$ELSE}
    AForm := FormDesigner.Form;
  {$ENDIF}

    if Selections <> nil then
    begin
      Selections.Clear;
      AList := CreateSelectionList;
      FormDesigner.GetSelections(AList);
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
      
      if ExcludeForm and (Selections.Count = 1) and (Selections[0] = AForm) then
        Selections.Clear;
    end;
    Result := True;
  except
    ;
  end;
end;

// 取当前设计的窗体上选择控件的数量
function CnOtaGetCurrFormSelectionsCount: Integer;
var
  AForm: TCustomForm;
  AList: TList;
begin
  Result := 0;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;
    Result := AList.Count;
  finally
    AList.Free;
  end;
end;

// 判断当前设计的窗体上是否选择有控件
function CnOtaIsCurrFormSelectionsEmpty: Boolean;
begin
  Result := CnOtaGetCurrFormSelectionsCount <= 0;
end;

// 通知窗体设计器内容已变更
procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor);
var
  FormDesigner: IDesigner;
begin
  FormDesigner := CnOtaGetFormDesigner(FormEditor);
  if FormDesigner = nil then Exit;
  FormDesigner.Modified;
end;

// 判断当前选择的控件是否为设计窗体本身
function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor): Boolean;
var
  SelCount: Integer;
  CurrentComponent: IOTAComponent;
  RootComponent: IOTAComponent;
begin
  Result := False;
  if not Assigned(FormEditor) then
    FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);

  if FormEditor = nil then Exit;
  SelCount := FormEditor.GetSelCount;
  if SelCount = 1 then
  begin
    CurrentComponent := FormEditor.GetSelComponent(0);
    Assert(Assigned(CurrentComponent));
    RootComponent := FormEditor.GetRootComponent;
    Assert(Assigned(RootComponent));
    Result := SameText(RootComponent.GetComponentType, CurrentComponent.GetComponentType);
  end
  else
    Result := False;
end;

// 判断设计期控件的指定属性是否存在
function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  Assert(Assigned(Component));
  for i := 0 to Component.GetPropCount - 1 do
  begin
    Result := SameText(Component.GetPropName(i), PropertyName);
    if Result then
      Break;
  end;
end;

// 设置当前设计期窗体选择的组件为设计窗体本身
procedure CnOtaSetCurrFormSelectRoot;
var
  FormDesigner: IDesigner;
begin
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;
  FormDesigner.SelectComponent(FormDesigner.GetRoot);
end;

// 取得当前选择的控件的名称列表
procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
var
  AForm: TCustomForm;
  AList: TList;
  i: Integer;
begin
  List.Clear;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;
    
    for i := 0 to AList.Count - 1 do
      List.Add(TComponent(AList[i]).Name);
  finally
    AList.Free;
  end;
end;

// 复制当前选择的控件的名称列表到剪贴板
procedure CnOtaCopyCurrFormSelectionsName;
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    CnOtaGetCurrFormSelectionsName(List);
    if List.Count = 1 then
      Clipboard.AsText := List[0]  // 只有一行时去掉换行符
    else
      Clipboard.AsText := List.Text;
  finally
    List.Free;
  end;
end;

// 返回一个位置值
function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
begin
  Result.CharIndex := CharIndex;
  Result.Line := Line;
end;

// 返回一个编辑位置值
function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
begin
  Result.Col := Col;
  Result.Line := Line;
end;

// 判断两个编辑位置是否相等
function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
begin
  Result := (Pos1.Col = Pos2.Col) and (Pos1.Line = Pos2.Line);
end;

// 判断两个字符位置是否相等
function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
begin
  Result := (Pos1.CharIndex = Pos2.CharIndex) and (Pos1.Line = Pos2.Line);
end;

// 判断一控件窗口是否是非可视化控件
function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
var
  AClassName: array[0..256] of Char;
begin
  //FillChar(AClassName, SizeOf(AClassName), #0);
  AClassName[GetClassName(hWnd, @AClassName, SizeOf(AClassName) - 1)] := #0;
  Result := string(AClassName) = NonvisualClassNamePattern;
end;

// Tests for file existance, a lot faster than the RTL implementation
function FileExists(const Filename: string): Boolean;
var
  a: Cardinal;
begin
  a := GetFileAttributes(PChar(Filename));
  Result := (a <> $FFFFFFFF) and (a and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

// 用各种法子判断当前 IDE/BDS 是否是 Delphi，是则返回 True，C++Builder 则返回 False
function IsDelphiRuntime: Boolean;
{$IFDEF COMPILER9_UP}
var
  Project: IOTAProject;
  Personality: string;
{$ENDIF}
begin
{$IFNDEF COMPILER9_UP} // 不是 BDS 2005/2006 或以上，则以编译期为准
  {$IFDEF DELPHI}
  Result := True;
  {$ELSE}
  Result := False;
  {$ENDIF}
  Exit;
{$ELSE} // 是 BDS 2005/2006 或以上则需要动态判断
  Result := CurrentIsDelphiSource;
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    Personality := Project.Personality;
    if (Personality = sDelphiPersonality) or (Personality = sDelphiDotNetPersonality) then
      Result := True
    else if (Personality = sCBuilderPersonality) or (Personality = sCSharpPersonality) then
      Result := False;
  end;
{$ENDIF}
end;

// 用各种法子判断当前 IDE 是否是 C#，是则返回 True，其他则返回 False
function IsCSharpRuntime: Boolean;
{$IFDEF COMPILER9_UP}
var
  Project: IOTAProject;
  Personality: string;
{$ENDIF}
begin
  Result := False;
{$IFDEF COMPILER9_UP}
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    Personality := Project.Personality;
    if Personality = sCSharpPersonality then
      Result := True;
  end;
{$ENDIF}
end;

// 判断当前是否是 Delphi 工程
function IsDelphiProject(Project: IOTAProject): Boolean;
{$IFDEF COMPILER9_UP}
var
  Personality: string;
{$ENDIF}
begin
  Result := False;
  if Project <> nil then
  begin
{$IFDEF COMPILER9_UP}
    Personality := Project.Personality;
    if (Personality = sDelphiPersonality) or (Personality = sDelphiDotNetPersonality) then
      Result := True;
{$ELSE}
    Result := IsDpr(Project.FileName) or IsDpk(Project.FileName);
{$ENDIF}
  end;
end;

// 将一 EditView 中的书签信息保存至一 ObjectList 中
procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  BookMarkObj: TCnBookmarkObject;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;
  BookMarkList.Clear;

  for I := 0 to 9 do
  begin
    APos := EditView.BookmarkPos[I];
    if (APos.CharIndex <> 0) or (APos.Line <> 0) then
    begin
      BookMarkObj := TCnBookmarkObject.Create;
      BookMarkObj.ID := I;
      BookMarkObj.Line := APos.Line;
      BookMarkObj.Col := APos.CharIndex;
      BookMarkList.Add(BookMarkObj);
    end;
  end;
end;

// 从 ObjectList 中恢复一 EditView 中的书签
procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  EditPos, SavePos: TOTAEditPos;
  BookMarkObj: TCnBookmarkObject;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  if BookMarkList.Count > 0 then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to 9 do // 先清除以前的书签
    begin
      APos := EditView.BookmarkPos[I];
      if (APos.Line <> 0) or (APos.CharIndex <> 0) then
      begin
        EditPos := EditView.CursorPos;
        EditPos.Line := APos.Line;
        EditView.CursorPos := EditPos;
        EditView.BookmarkToggle(I);
      end;
    end;

    for I := 0 to BookMarkList.Count - 1 do
    begin
      BookMarkObj := TCnBookmarkObject(BookMarkList.Extract(BookMarkList.First));
      EditPos := EditView.CursorPos;
      EditPos.Line := BookMarkObj.Line;
      EditView.CursorPos := EditPos;
      EditView.BookmarkToggle(BookMarkObj.ID);
      BookMarkObj.Free;
    end;
    EditView.CursorPos := SavePos;
  end;
end;

// 从 ObjectList 中替换一部分 EditView 中的书签
procedure ReplaceBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  EditPos, SavePos: TOTAEditPos;
  BookMarkObj: TCnBookmarkObject;

  function BookMarkIdInList(BID: Integer): Boolean;
  var
    J: Integer;
  begin
    for J := 0 to BookMarkList.Count - 1 do
    begin
      if TCnBookmarkObject(BookMarkList[J]).ID = BID then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  if BookMarkList.Count > 0 then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to 9 do // 先清除存在于 BookMarkList 中的书签
    begin
      if not BookMarkIdInList(I) then
        Continue;

      APos := EditView.BookmarkPos[I];
      if (APos.Line <> 0) or (APos.CharIndex <> 0) then
      begin
        EditPos := EditView.CursorPos;
        EditPos.Line := APos.Line;
        EditView.CursorPos := EditPos;
        EditView.BookmarkToggle(I);
      end;
    end;

    for I := 0 to BookMarkList.Count - 1 do
    begin
      BookMarkObj := TCnBookmarkObject(BookMarkList.Extract(BookMarkList.First));
      EditPos := EditView.CursorPos;
      EditPos.Line := BookMarkObj.Line;
      EditView.CursorPos := EditPos;
      EditView.BookmarkToggle(BookMarkObj.ID);
      BookMarkObj.Free;
    end;
    EditView.CursorPos := SavePos;
  end;
end;

// 判断正则表达式匹配
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

{$IFNDEF CNWIZARDS_MINIMUM}

// 加载指定的语言文件翻译窗体
procedure TranslateFormFromLangFile(AForm: TCustomForm; const ALangDir, ALangFile: string;
  LangID: Cardinal);
var
  LangMgr: TCnLangManager;
  Storage: TCnHashLangFileStorage;
begin
  LangMgr := nil;
  Storage := nil;
  try
    LangMgr := TCnLangManager.Create(nil);
    LangMgr.AutoTranslate := False;
    LangMgr.TranslateTreeNode := True;
    LangMgr.UseDefaultFont := True;
    Storage := TCnHashLangFileStorage.Create(nil);
    Storage.StorageMode := smByDirectory;
    Storage.FileName := ALangFile;
    Storage.LanguagePath := ALangDir;
    LangMgr.LanguageStorage := Storage;
    if Storage.Languages.Find(LangID) >= 0 then
    begin
      LangMgr.CurrentLanguageIndex := Storage.Languages.Find(LangID);
      LangMgr.TranslateForm(AForm);
    end;
  finally
    LangMgr.Free;
    Storage.Free;
  end;
end;
{$ENDIF}

// 封装 Assert 判断
procedure CnWizAssert(Expr: Boolean; const Msg: string = '');
begin
{$IFDEF DEBUG}
  if Expr then
    CnDebugger.LogMsg('Assert Passed: ' + Msg)
  else
    CnDebugger.LogMsgError('Assert Failed! ' + Msg);
{$ENDIF}
  Assert(Expr, Msg);
end;

initialization
  CnNoIconList := TStringList.Create;
  AddNoIconToList('TMenuItem'); // TMenuItem 等在专家加载之前已注册
  AddNoIconToList('TField');
  AddNoIconToList('TAction');
  OldRegisterNoIconProc := RegisterNoIconProc;
  RegisterNoIconProc := CnRegisterNoIconProc;

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnWizUtils finalization.');
{$ENDIF Debug}

  RegisterNoIconProc := OldRegisterNoIconProc;
  FreeAndNil(CnNoIconList);
  
  FreeResDll;
{$IFDEF Debug}
  CnDebugger.LogLeave('CnWizUtils finalization.');
{$ENDIF Debug}

end.

