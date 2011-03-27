{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
* 单元名称：在脚本中使用的 CnWizUtils 单元声明
* 单元作者：CnPack 开发组
* 备    注：本单元中声明的类型和函数可以在 Pascal Script 脚本中使用
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
  Windows, Messages, Classes, Graphics, Controls, SysUtils, Menus, ImgList,
  ActnList, Forms, ComCtrls,
{$IFNDEF VER130}
  DesignIntf,
{$ENDIF}
  ToolsAPI;

type
  TCnCompilerKind = (ckDelphi, ckBCB);
  TCnCompiler = (cnDelphi5, cnDelphi6, cnDelphi7, cnDelphi8, cnDelphi9,
    cnDelphi10, cnDelphi11, cnDelphi12, cnDelphi14, cnBCB5, cnBCB6);

const
  // 以下常量的实际值取决于当前编译器
  Compiler: TCnCompiler = cnDelphi5;
  CompilerKind: TCnCompilerKind = ckDelphi;
  CompilerName = 'Delphi 5';
  CompilerShortName = 'D5';

  _DELPHI = {$IFDEF DELPHI}True{$ELSE}False{$ENDIF};
  _BCB = {$IFDEF BCB}True{$ELSE}False{$ENDIF};
  _BDS = {$IFDEF BDS}True{$ELSE}False{$ENDIF};

  _DELPHI1 = {$IFDEF DELPHI1}True{$ELSE}False{$ENDIF};
  _DELPHI2 = {$IFDEF DELPHI2}True{$ELSE}False{$ENDIF};
  _DELPHI3 = {$IFDEF DELPHI3}True{$ELSE}False{$ENDIF};
  _DELPHI4 = {$IFDEF DELPHI4}True{$ELSE}False{$ENDIF};
  _DELPHI5 = {$IFDEF DELPHI5}True{$ELSE}False{$ENDIF};
  _DELPHI6 = {$IFDEF DELPHI6}True{$ELSE}False{$ENDIF};
  _DELPHI7 = {$IFDEF DELPHI7}True{$ELSE}False{$ENDIF};
  _DELPHI8 = {$IFDEF DELPHI8}True{$ELSE}False{$ENDIF};
  _DELPHI9 = {$IFDEF DELPHI9}True{$ELSE}False{$ENDIF};
  _DELPHI10 = {$IFDEF DELPHI10}True{$ELSE}False{$ENDIF};
  _DELPHI11 = {$IFDEF DELPHI11}True{$ELSE}False{$ENDIF};
  _DELPHI12 = {$IFDEF DELPHI12}True{$ELSE}False{$ENDIF};
  _DELPHI14 = {$IFDEF DELPHI14}True{$ELSE}False{$ENDIF};

  _DELPHI1_UP = {$IFDEF DELPHI1_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2_UP = {$IFDEF DELPHI2_UP}True{$ELSE}False{$ENDIF};
  _DELPHI3_UP = {$IFDEF DELPHI3_UP}True{$ELSE}False{$ENDIF};
  _DELPHI4_UP = {$IFDEF DELPHI4_UP}True{$ELSE}False{$ENDIF};
  _DELPHI5_UP = {$IFDEF DELPHI5_UP}True{$ELSE}False{$ENDIF};
  _DELPHI6_UP = {$IFDEF DELPHI6_UP}True{$ELSE}False{$ENDIF};
  _DELPHI7_UP = {$IFDEF DELPHI7_UP}True{$ELSE}False{$ENDIF};
  _DELPHI8_UP = {$IFDEF DELPHI8_UP}True{$ELSE}False{$ENDIF};
  _DELPHI9_UP = {$IFDEF DELPHI9_UP}True{$ELSE}False{$ENDIF};
  _DELPHI10_UP = {$IFDEF DELPHI10_UP}True{$ELSE}False{$ENDIF};
  _DELPHI11_UP = {$IFDEF DELPHI11_UP}True{$ELSE}False{$ENDIF};
  _DELPHI12_UP = {$IFDEF DELPHI12_UP}True{$ELSE}False{$ENDIF};
  _DELPHI14_UP = {$IFDEF DELPHI14_UP}True{$ELSE}False{$ENDIF};

  _BCB1 = {$IFDEF BCB1}True{$ELSE}False{$ENDIF};
  _BCB3 = {$IFDEF BCB3}True{$ELSE}False{$ENDIF};
  _BCB4 = {$IFDEF BCB4}True{$ELSE}False{$ENDIF};
  _BCB5 = {$IFDEF BCB5}True{$ELSE}False{$ENDIF};
  _BCB6 = {$IFDEF BCB6}True{$ELSE}False{$ENDIF};
  _BCB7 = {$IFDEF BCB7}True{$ELSE}False{$ENDIF};
  _BCB10 = {$IFDEF BCB10}True{$ELSE}False{$ENDIF};
  _BCB11 = {$IFDEF BCB11}True{$ELSE}False{$ENDIF};
  _BCB12 = {$IFDEF BCB12}True{$ELSE}False{$ENDIF};
  _BCB14 = {$IFDEF BCB14}True{$ELSE}False{$ENDIF};

  _BCB1_UP = {$IFDEF BCB1_UP}True{$ELSE}False{$ENDIF};
  _BCB3_UP = {$IFDEF BCB3_UP}True{$ELSE}False{$ENDIF};
  _BCB4_UP = {$IFDEF BCB4_UP}True{$ELSE}False{$ENDIF};
  _BCB5_UP = {$IFDEF BCB5_UP}True{$ELSE}False{$ENDIF};
  _BCB6_UP = {$IFDEF BCB6_UP}True{$ELSE}False{$ENDIF};
  _BCB7_UP = {$IFDEF BCB7_UP}True{$ELSE}False{$ENDIF};
  _BCB10_UP = {$IFDEF BCB10_UP}True{$ELSE}False{$ENDIF};
  _BCB11_UP = {$IFDEF BCB11_UP}True{$ELSE}False{$ENDIF};
  _BCB12_UP = {$IFDEF BCB12_UP}True{$ELSE}False{$ENDIF};
  _BCB14_UP = {$IFDEF BCB14_UP}True{$ELSE}False{$ENDIF};

  _KYLIX1 = {$IFDEF KYLIX1}True{$ELSE}False{$ENDIF};
  _KYLIX2 = {$IFDEF KYLIX2}True{$ELSE}False{$ENDIF};
  _KYLIX3 = {$IFDEF KYLIX3}True{$ELSE}False{$ENDIF};

  _KYLIX1_UP = {$IFDEF KYLIX1_UP}True{$ELSE}False{$ENDIF};
  _KYLIX2_UP = {$IFDEF KYLIX2_UP}True{$ELSE}False{$ENDIF};
  _KYLIX3_UP = {$IFDEF KYLIX3_UP}True{$ELSE}False{$ENDIF};

  _BDS2 = {$IFDEF BDS2}True{$ELSE}False{$ENDIF};
  _BDS3 = {$IFDEF BDS3}True{$ELSE}False{$ENDIF};
  _BDS4 = {$IFDEF BDS4}True{$ELSE}False{$ENDIF};
  _BDS5 = {$IFDEF BDS5}True{$ELSE}False{$ENDIF};
  _BDS6 = {$IFDEF BDS6}True{$ELSE}False{$ENDIF};
  _BDS7 = {$IFDEF BDS7}True{$ELSE}False{$ENDIF};

  _BDS2_UP = {$IFDEF BDS2_UP}True{$ELSE}False{$ENDIF};
  _BDS3_UP = {$IFDEF BDS3_UP}True{$ELSE}False{$ENDIF};
  _BDS4_UP = {$IFDEF BDS4_UP}True{$ELSE}False{$ENDIF};
  _BDS5_UP = {$IFDEF BDS5_UP}True{$ELSE}False{$ENDIF};
  _BDS6_UP = {$IFDEF BDS6_UP}True{$ELSE}False{$ENDIF};
  _BDS7_UP = {$IFDEF BDS7_UP}True{$ELSE}False{$ENDIF};

  _COMPILER1 = {$IFDEF COMPILER1}True{$ELSE}False{$ENDIF};
  _COMPILER2 = {$IFDEF COMPILER2}True{$ELSE}False{$ENDIF};
  _COMPILER3 = {$IFDEF COMPILER3}True{$ELSE}False{$ENDIF};
  _COMPILER35 = {$IFDEF COMPILER35}True{$ELSE}False{$ENDIF};
  _COMPILER4 = {$IFDEF COMPILER4}True{$ELSE}False{$ENDIF};
  _COMPILER5 = {$IFDEF COMPILER5}True{$ELSE}False{$ENDIF};
  _COMPILER6 = {$IFDEF COMPILER6}True{$ELSE}False{$ENDIF};
  _COMPILER7 = {$IFDEF COMPILER7}True{$ELSE}False{$ENDIF};
  _COMPILER8 = {$IFDEF COMPILER8}True{$ELSE}False{$ENDIF};
  _COMPILER9 = {$IFDEF COMPILER9}True{$ELSE}False{$ENDIF};
  _COMPILER10 = {$IFDEF COMPILER10}True{$ELSE}False{$ENDIF};
  _COMPILER11 = {$IFDEF COMPILER11}True{$ELSE}False{$ENDIF};
  _COMPILER12 = {$IFDEF COMPILER12}True{$ELSE}False{$ENDIF};
  _COMPILER14 = {$IFDEF COMPILER14}True{$ELSE}False{$ENDIF};

  _COMPILER1_UP = {$IFDEF COMPILER1_UP}True{$ELSE}False{$ENDIF};
  _COMPILER2_UP = {$IFDEF COMPILER2_UP}True{$ELSE}False{$ENDIF};
  _COMPILER3_UP = {$IFDEF COMPILER3_UP}True{$ELSE}False{$ENDIF};
  _COMPILER35_UP = {$IFDEF COMPILER35_UP}True{$ELSE}False{$ENDIF};
  _COMPILER4_UP = {$IFDEF COMPILER4_UP}True{$ELSE}False{$ENDIF};
  _COMPILER5_UP = {$IFDEF COMPILER5_UP}True{$ELSE}False{$ENDIF};
  _COMPILER6_UP = {$IFDEF COMPILER6_UP}True{$ELSE}False{$ENDIF};
  _COMPILER7_UP = {$IFDEF COMPILER7_UP}True{$ELSE}False{$ENDIF};
  _COMPILER8_UP = {$IFDEF COMPILER8_UP}True{$ELSE}False{$ENDIF};
  _COMPILER9_UP = {$IFDEF COMPILER9_UP}True{$ELSE}False{$ENDIF};
  _COMPILER10_UP = {$IFDEF COMPILER10_UP}True{$ELSE}False{$ENDIF};
  _COMPILER11_UP = {$IFDEF COMPILER11_UP}True{$ELSE}False{$ENDIF};
  _COMPILER12_UP = {$IFDEF COMPILER12_UP}True{$ELSE}False{$ENDIF};
  _COMPILER14_UP = {$IFDEF COMPILER14_UP}True{$ELSE}False{$ENDIF};

type
  TFormType = (ftBinary, ftText, ftUnknown);
  TCnCharSet = set of Char;

//==============================================================================
// 公共信息函数
//==============================================================================

function CnIntToObject(AInt: Integer): TObject;
{* 供 Pascal Script 使用的将整型值转换成 TObject 的函数}
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
function ReplaceToActualPath(const Path: string): string;
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
procedure DoHandleException(const ErrorMsg: string);
{* 处理一些执行方法中的异常}
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
procedure RemoveListViewSubImages(ListView: TListView);
{* 更新 ListView 控件，去除子项的 SubItemImages }
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

function CurrentIsDelphiSource: Boolean;
{* 当前编辑的文件是Delphi源文件}
function CurrentIsCSource: Boolean;
{* 当前编辑的文件是C源文件}
function CurrentIsSource: Boolean;
{* 当前编辑的文件是Delphi或C源文件}
function CurrentIsForm: Boolean;
{* 当前编辑的文件是窗体文件}
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
function IsCppSourceModule(const FileName: string): Boolean;
{* 判断是否所有类型的C++源文件}
function IsCpp(const FileName: string): Boolean;
{* 判断是否.Cpp文件}
function IsHpp(const FileName: string): Boolean;
{* 判断是否.Hpp文件}
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
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
{* 使用字符串的方式判断对象是否继承自此类}
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
{* 使用字符串的方式判断控件是否包含指定类名的子控件，存在则返回最上面一个}

//==============================================================================
// OTA 接口操作相关函数
//==============================================================================

{* 查询输入的服务接口并返回一个指定接口实例，如果失败，返回 False}
function CnOtaGetEditBuffer: IOTAEditBuffer;
{* 取IOTAEditBuffer接口}
function CnOtaGetEditPosition: IOTAEditPosition;
{* 取IOTAEditPosition接口}
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
function CnOtaGetEditor(const FileName: string): IOTAEditor;
{* 根据文件名返回编辑器接口}
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
{* 返回窗体编辑器设计窗体组件}
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
{* 取得 IDE 设置变量名列表}
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
{* 设置当前项目的属性值}
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
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* 取当前工程配置选项，2009 后才有效}
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
procedure CnOtaEditBackspace(Many: Integer);
{* 在编辑器中退格}
procedure CnOtaEditDelete(Many: Integer);
{* 在编辑器中删除}
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
{* 取指定行的源代码}
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
{* 取当前行源代码}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
{* 使用 NTA 方法取当前行源代码。速度快，但取回的文本是将 Tab 扩展成空格的。
   如果使用 ConvertPos 来转换成 EditPos 可能会有问题。直接将 CharIndex + 1 
   赋值给 EditPos.Col 即可。}
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
{* 返回 SourceEditor 当前行信息}
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* 取当前光标下的标识符及光标在标识符中的索引号，速度较快}
function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
{* 取当前光标下的字符，允许偏移量}
function CnOtaDeleteCurrToken(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* 删除当前光标下的标识符}
function CnOtaDeleteCurrTokenLeft(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* 删除当前光标下的标识符左半部分}
function CnOtaDeleteCurrTokenRight(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* 删除当前光标下的标识符右半部分}
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
{* 判断位置是否超出行尾了 }
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
{* 选择一个代码块}
function CnOtaCurrBlockEmpty: Boolean;
{* 返回当前选择的块是否为空 }
function CnOtaOpenFile(const FileName: string): Boolean;
{* 打开文件}
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
{* 打开未保存的窗体}
function CnOtaIsFileOpen(const FileName: string): Boolean;
{* 判断文件是否打开}
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

//==============================================================================
// 源代码操作相关函数
//==============================================================================

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
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

function ConvertTextToEditorText(const Text: string): string;
{* 转换字符串为编辑器使用的字符串 }

function ConvertEditorTextToText(const Text: string): string;
{* 转换编辑器使用的字符串为普通字符串 }

function CnOtaGetCurrentSourceFile: string;
{* 取当前编辑的源文件}

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
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
{* 保存EditReader内容到流中}

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean = True): Boolean;
{* 保存编辑器文本到流中}

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
{* 保存当前编辑器文本到流中}

function CnOtaGetCurrentEditorSource: string;
{* 取得当前编辑器源代码}

procedure CnOtaInsertLineIntoEditor(const Text: string);
{* 插入一个字符串到当前 IOTASourceEditor，仅在 Text 为单行文本时有用
   它会替换当前所选的文本。}

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
{* 插入一行文本当前 IOTASourceEditor，Line 为行号，Text 为单行 }

procedure CnOtaInsertTextIntoEditor(const Text: string);
{* 插入文本到当前 IOTASourceEditor，允许多行文本。}

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
{* 为指定 SourceEditor 返回一个 Writer，如果输入为空返回当前值。}

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* 在指定位置处插入文本，如果 SourceEditor 为空使用当前值。}

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* 移动光标到指定位置，如果 EditView 为空使用当前值。}

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
{* 返回当前光标位置，如果 EditView 为空使用当前值。 }

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* 移动光标到指定位置，如果 EditView 为空使用当前值。}

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

implementation

{$WARNINGS OFF}

function CnIntToObject(AInt: Integer): TObject;
begin
end;

function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
begin
end;

function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
begin
end;

function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
begin
end;

function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
begin
end;

procedure AdjustButtonGlyph(Glyph: TBitmap);
begin
end;

function SameFileName(const S1, S2: string): Boolean;
begin
end;

function CompressWhiteSpace(const Str: string): string;
begin
end;

procedure ShowHelp(const Topic: string);
begin
end;

procedure CenterForm(const Form: TCustomForm);
begin
end;

procedure EnsureFormVisible(const Form: TCustomForm);
begin
end;

function GetCaptionOrgStr(const Caption: string): string;
begin
end;

function GetIDEImageList: TCustomImageList;
begin
end;

procedure SaveIDEImageListToPath(const Path: string);
begin
end;

procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
begin
end;

function GetIDEMainMenu: TMainMenu;
begin
end;

function GetIDEToolsMenu: TMenuItem;
begin
end;

function GetIDEActionList: TCustomActionList;
begin
end;

function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
begin
end;

function GetIdeRootDirectory: string;
begin
end;

function ReplaceToActualPath(const Path: string): string;
begin
end;

procedure SaveIDEActionListToFile(const FileName: string);
begin
end;

procedure SaveIDEOptionsNameToFile(const FileName: string);
begin
end;

procedure SaveProjectOptionsNameToFile(const FileName: string);
begin
end;

function FindIDEAction(const ActionName: string): TContainedAction;
begin
end;

function ExecuteIDEAction(const ActionName: string): Boolean;
begin
end;

function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
begin
end;

function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
begin
end;

procedure SortListByMenuOrder(List: TList);
begin
end;

function IsTextForm(const FileName: string): Boolean;
begin
end;

procedure DoHandleException(const ErrorMsg: string);
begin
end;

function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
begin
end;

function ScreenHasModalForm: Boolean;
begin
end;

procedure SetFormNoTitle(Form: TForm);
begin
end;

procedure SendKey(vk: Word);
begin
end;

function IMMIsActive: Boolean;
begin
end;

function GetCaretPosition(var Pt: TPoint): Boolean;
begin
end;

procedure GetCursorList(List: TStrings);
begin
end;

procedure GetCharsetList(List: TStrings);
begin
end;

procedure GetColorList(List: TStrings);
begin
end;

function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;
begin
end;

function CnGetComponentText(Component: TComponent): string;
begin
end;

function CnGetComponentAction(Component: TComponent): TBasicAction;
begin
end;

procedure RemoveListViewSubImages(ListView: TListView);
begin
end;

function GetListViewWidthString(AListView: TListView): string;
begin
end;

procedure SetListViewWidthString(AListView: TListView; const Text: string);
begin
end;

function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
begin
end;

function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
begin
end;

procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
begin
end;

function IsDelphiRuntime: Boolean;
begin
end;

function IsCSharpRuntime: Boolean;
begin
end;

function IsDelphiProject(Project: IOTAProject): Boolean;
begin
end;

function CurrentIsDelphiSource: Boolean;
begin
end;

function CurrentIsCSource: Boolean;
begin
end;

function CurrentIsSource: Boolean;
begin
end;

function CurrentIsForm: Boolean;
begin
end;

function ExtractUpperFileExt(const FileName: string): string;
begin
end;

procedure AssertIsDprOrPas(const FileName: string);
begin
end;

procedure AssertIsDprOrPasOrInc(const FileName: string);
begin
end;

procedure AssertIsPasOrInc(const FileName: string);
begin
end;

function IsSourceModule(const FileName: string): Boolean;
begin
end;

function IsDelphiSourceModule(const FileName: string): Boolean;
begin
end;

function IsDprOrPas(const FileName: string): Boolean;
begin
end;

function IsDpr(const FileName: string): Boolean;
begin
end;

function IsBpr(const FileName: string): Boolean;
begin
end;

function IsProject(const FileName: string): Boolean;
begin
end;

function IsBdsProject(const FileName: string): Boolean;
begin
end;

function IsDProject(const FileName: string): Boolean;
begin
end;

function IsCbProject(const FileName: string): Boolean;
begin
end;

function IsDpk(const FileName: string): Boolean;
begin
end;

function IsBpk(const FileName: string): Boolean;
begin
end;

function IsPackage(const FileName: string): Boolean;
begin
end;

function IsBpg(const FileName: string): Boolean;
begin
end;

function IsPas(const FileName: string): Boolean;
begin
end;

function IsDcu(const FileName: string): Boolean;
begin
end;

function IsInc(const FileName: string): Boolean;
begin
end;

function IsDfm(const FileName: string): Boolean;
begin
end;

function IsForm(const FileName: string): Boolean;
begin
end;

function IsXfm(const FileName: string): Boolean;
begin
end;

function IsCppSourceModule(const FileName: string): Boolean;
begin
end;

function IsCpp(const FileName: string): Boolean;
begin
end;

function IsHpp(const FileName: string): Boolean;
begin
end;  

function IsC(const FileName: string): Boolean;
begin
end;

function IsH(const FileName: string): Boolean;
begin
end;

function IsAsm(const FileName: string): Boolean;
begin
end;

function IsRC(const FileName: string): Boolean;
begin
end;

function IsKnownSourceFile(const FileName: string): Boolean;
begin
end;

function IsTypeLibrary(const FileName: string): Boolean;
begin
end;

function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
begin
end;

function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
begin
end;

function CnOtaGetEditBuffer: IOTAEditBuffer;
begin
end;

function CnOtaGetEditPosition: IOTAEditPosition;
begin
end;

function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
begin
end;

function CnOtaGetTopMostEditActions: IOTAEditActions;
begin
end;

function CnOtaGetCurrentModule: IOTAModule;
begin
end;

function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
begin
end;

function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
begin
end;

function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
begin
end;

function CnOtaGetCurrentFormEditor: IOTAFormEditor;
begin
end;

function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
begin
end;

function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
begin
end;

procedure CnOtaShowDesignerForm;
begin
end;

function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
end;

function CnOtaGetActiveDesignerType: string;
begin
end;

function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
begin
end;

function CnOtaGetComponentText(Component: IOTAComponent): string;
begin
end;

function CnOtaGetModule(const FileName: string): IOTAModule;
begin
end;

function CnOtaGetEditor(const FileName: string): IOTAEditor;
begin
end;

function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
begin
end;

function CnOtaGetCurrentEditWindow: TCustomForm;
begin
end;

function CnOtaGetCurrentEditControl: TWinControl;
begin
end;

function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
begin
end;

function CnOtaGetProjectGroup: IOTAProjectGroup;
begin
end;

function CnOtaGetProjectGroupFileName: string;
begin
end;

function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
begin
end;

function CnOtaGetCurrentProject: IOTAProject;
begin
end;

function CnOtaGetProject: IOTAProject;
begin
end;

function CnOtaGetProjectCountFromGroup: Integer;
begin
end;

function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
begin
end;

procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
begin
end;

procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
begin
end;

procedure CnOtaGetProjectList(const List: TInterfaceList);
begin
end;

function CnOtaGetCurrentProjectName: string;
begin
end;

function CnOtaGetCurrentProjectFileName: string;
begin
end;

function CnOtaGetCurrentProjectFileNameEx: string;
begin
end;

function CnOtaGetCurrentFormName: string;
begin
end;

function CnOtaGetCurrentFormFileName: string;
begin
end;

function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
begin
end;

function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
begin
end;

function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
begin
end;

function CnOtaGetEditOptions: IOTAEditOptions;
begin
end;

function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
begin
end;

function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
begin
end;

function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
begin
end;

function CnOtaGetNewFormTypeOption: TFormType;
begin
end;

function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
begin
end;

function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
begin
end;

function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
begin
end;

function CnOtaGetCurrentSelection: string;
begin
end;

procedure CnOtaDeleteCurrentSelection;
begin
end;

procedure CnOtaEditBackspace(Many: Integer);
begin
end;

procedure CnOtaEditDelete(Many: Integer);
begin
end;

function CnOtaGetCurrentProcedure: string;
begin
end;

function CnOtaGetCurrentOuterBlock: string;
begin
end;

function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
begin
end;

function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
begin
end;

function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
begin
end;

function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
begin
end;

function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
begin
end;

function CnOtaDeleteCurrToken(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaDeleteCurrTokenLeft(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaDeleteCurrTokenRight(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
begin
end;

procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
begin
end;

function CnOtaCurrBlockEmpty: Boolean;
begin
end;

function CnOtaOpenFile(const FileName: string): Boolean;
begin
end;

function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
begin
end;

function CnOtaIsFileOpen(const FileName: string): Boolean;
begin
end;

function CnOtaIsFormOpen(const FormName: string): Boolean;
begin
end;

function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
begin
end;

function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
begin
end;

function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
begin
end;

function CnOtaIsDebugging: Boolean;
begin
end;

function CnOtaGetBaseModuleFileName(const FileName: string): string;
begin
end;

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
begin
end;

function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
begin
end;

function ConvertTextToEditorText(const Text: string): string;
begin
end;

function ConvertEditorTextToText(const Text: string): string;
begin
end;

function CnOtaGetCurrentSourceFile: string;
begin
end;

function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos
  = ipCur): Boolean;
begin
end;

function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
begin
end;

function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
begin
end;

function CnOtaSetCurSourceCol(Col: Integer): Boolean;
begin
end;

function CnOtaSetCurSourceRow(Row: Integer): Boolean;
begin
end;

function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
begin
end;

function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
begin
end;

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
begin
end;

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
begin
end;

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
begin
end;

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
begin
end;

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean = True): Boolean;
begin
end;

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
begin
end;

function CnOtaGetCurrentEditorSource: string;
begin
end;

procedure CnOtaInsertLineIntoEditor(const Text: string);
begin
end;

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
begin
end;

procedure CnOtaInsertTextIntoEditor(const Text: string);
begin
end;

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
begin
end;

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
begin
end;

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
begin
end;

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
begin
end;

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
begin
end;

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
begin
end;

function CnOtaGetBlockIndent: Integer;
begin
end;

procedure CnOtaClosePage(EditView: IOTAEditView);
begin
end;

procedure CnOtaCloseEditView(AModule: IOTAModule);
begin
end;

function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList; 
  ExcludeForm: Boolean = True): Boolean;
begin
end;

function CnOtaGetCurrFormSelectionsCount: Integer;
begin
end;

function CnOtaIsCurrFormSelectionsEmpty: Boolean;
begin
end;

procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor = nil);
begin
end;

function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor = nil): Boolean;
begin
end;

function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
begin
end;

procedure CnOtaSetCurrFormSelectRoot;
begin
end;

procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
begin
end;

procedure CnOtaCopyCurrFormSelectionsName;
begin
end;

function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
begin
end;

function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
begin
end;

function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
begin
end;

function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
begin
end;

function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
begin
end;

end.

