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

unit CnDesignWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：设计期专家单元
* 单元作者：王玉宝（Wyb_star） Wyb_star@sina.com
*           周劲羽 (zjy@cnpack.org)
*           CnPack 开发组 (master@cnpack.org)
*           朱磊（Licwing Zue）licwing@chinasystemsn.com
* 备    注：控件对齐专家单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.07.03 by LiuXiao
*               不可视组件增加对 FMX 的支持，使用 DesignInfo 结合界面切换实现
*           2021.08.11 by LiuXiao
*               增加组件比较的入口
*           2011.10.03 by LiuXiao
*               使用一批封装 Control 操作的函数以支持 FMX 框架
*           2004.12.04 by 周劲羽
*               大量修改和重构，支持更多的功能
*           2003.11.20 by 周劲羽
*               换了一种方法检查是否不可视组件，修正有时候不能过滤 TField 等的问题。
*           2003.06.24 V1.7 by LiuXiao
*               修改关联到窗体设计器扩展专家的部分。
*           2003.06.04 V1.6 by 周劲羽
*               大量的改进，不同父的控件也可以支持排列对齐
*               重新排列代码位置
*           2003.06.01 V1.5 by 周劲羽
*               排列不可视组件修正不能忽略 TMenuItem 及标题计算错误
*           2003.05.27 V1.4 by 周劲羽
*               排列不可视组件增加对组件标题的移动支持
*           2003.05.24 V1.3 by LiuXiao
*               增加排列不可视组件和显示隐藏不可视组件以及浮动工具面板的功能。
*           2003.05.12 V1.2 by LiuXiao
*               增加置于父控件水平和垂直方向上的中心的功能。
*           2003.05.02 V1.1 by 周劲羽
*               增加复制组件名、选择窗体功能，及设置功能
*           2003.04.24 V1.0 by 王玉宝
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDESIGNWIZARD}

uses
  Windows, SysUtils, Messages, Classes, Forms, IniFiles, ToolsAPI, Controls,
  Dialogs, Math, ActnList, Graphics, Contnrs,
{$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
{$IFDEF IDE_ACTION_UPDATE_DELAY} ActnMenus, ActnMan, {$ENDIF}
  Buttons, Menus, CnWizClasses, CnWizMenuAction, CnWizUtils, CnEventBus,
  CnConsts, CnWizNotifier, CnWizConsts, CnWizManager, CnVclFmxMixed,
  StdCtrls, CnSpin, CnWizIdeUtils, CnCommon, CnWizMultiLang, CnPropertyCompareFrm;

type

//==============================================================================
// Align Size 设置工具
//==============================================================================

{ TCnDesignWizard }

  TCnAlignSizeStyle = (
    asAlignLeft, asAlignRight, asAlignTop, asAlignBottom,
    asAlignHCenter, asAlignVCenter,
    asSpaceEquH, asSpaceEquHX, asSpaceIncH, asSpaceDecH, asSpaceRemoveH,
    asSpaceEquV, asSpaceEquVY, asSpaceIncV, asSpaceDecV, asSpaceRemoveV,
    asIncWidth, asDecWidth, asIncHeight, asDecHeight,
    asMakeMinWidth, asMakeMaxWidth, asMakeSameWidth,
    asMakeMinHeight, asMakeMaxHeight, asMakeSameHeight, asMakeSameSize,
    asParentHCenter, asParentVCenter, asBringToFront, asSendToBack,
    asSnapToGrid, {$IFDEF IDE_HAS_GUIDE_LINE} asUseGuidelines, {$ENDIF} asAlignToGrid,
    asSizeToGrid, asLockControls, asSelectRoot, asCopyCompName, asCopyCompClass,
    asHideComponent, asNonArrange, asListComp, asCompareProp, asCompToCode,
    asChangeCompClass, asCompRename, asShowFlatForm);

  TNonArrangeStyle = (asRow, asCol);

  TNonMoveStyle = (msLeftTop, msRightTop, msLeftBottom, msRightBottom, msCenter);

  TCnDesignWizard = class(TCnSubMenuWizard)
  private
    Indexes: array[TCnAlignSizeStyle] of Integer;
    FHideNonVisual: Boolean;
    FNonArrangeStyle: TNonArrangeStyle;
    FNonMoveStyle: TNonMoveStyle;
    FRowSpace, FColSpace: Integer;
    FPerRowCount, FPerColCount: Integer;
    FSortByClassName: Boolean;
    FSizeSpace: Integer;
    FIDELockControlsMenu: TMenuItem;
    FIDEHideNonvisualsMenu: TMenuItem;
    FPropertyCompare: TCnPropertyCompareManager;
    FUpdateControlList: TList;
    FUpdateCompList: TList;

{$IFDEF IDE_ACTION_UPDATE_DELAY}
    FIDEMenuBar: TCustomActionMenuBar;
    FEditMenuActionControl: TCustomActionControl;
{$ENDIF}

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}
    FScriptsDesignExecutors: TObjectList;
    FScriptSettingChangedReceiver: ICnEventBusReceiver;
{$ENDIF}
{$ENDIF}
    procedure ControlListSortByPos(List: TList; IsVert: Boolean;
      Desc: Boolean = False);
    procedure CompListSortByPos(List: TList; IsVert: Boolean;
      Desc: Boolean = False);
    procedure ControlListSortByProp(List: TList; ProName: string;
      Desc: Boolean = False);
    procedure DoAlignSize(AlignSizeStyle: TCnAlignSizeStyle);

    function UpdateNonVisualComponent(FormEditor: IOTAFormEditor): Boolean;
    procedure HideNonVisualComponent;

{$IFDEF IDE_ACTION_UPDATE_DELAY}
    procedure CheckMenuBarReady(Sender: TObject);
{$ENDIF}
    procedure CheckMenuItemReady(Sender: TObject);

    procedure RequestLockControlsMenuUpdate(Sender: TObject);
    procedure RequestNonvisualsMenuUpdate(Sender: TObject);

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}
    procedure SyncScriptsDesignMenus;
    procedure ScriptExecute(Sender: TObject);
{$ENDIF}
{$ENDIF}
    procedure ShowFlatForm;
    procedure NonVisualArrange;
    procedure ArrangeNonVisualComponents;
    procedure LockMenuExecuteReLock(Sender: TObject);
    procedure FormEditorNotifier(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);

    function GetComponentGeneralPos(Component: TComponent): TPoint;
    {* 封装的获取组件左上角位置的函数，支持可视组件与不可视组件}
    procedure SetComponentGeneralPos(Form: TCustomForm; Component: TComponent; APos: TPoint);
    {* 封装的设置组件左上角位置的函数，支持可视组件与不可视组件}
    function GetDesignerForm: TCustomForm;
    {* 拿当前设计期的窗体或 DataModule 的容器，注意不适合 FMX 的 Form 体系}

{$IFDEF SUPPORT_FMX}
    function GetFmxDesignerForm: TComponent;
    {* 拿 FMX 的设计期窗体}
{$ENDIF}

    function GetNonVisualComponentsFromCurrentForm(List: TList): Boolean;
    function GetNonVisualSelComponentsFromCurrentForm(List: TList): Boolean;
    procedure SetNonVisualPos(Form: TCustomForm; Component: TComponent;
      X, Y: Integer);
    {* 设置一个非可视组件的位置，Form 是设计器窗体或 DataModule 容器窗体
      Component 是这个组件实例，内部会去找具体 Handle 来设置位置}

    procedure ChangeComponentClass;
    {* 设计期更换组件类名，实际上是原位置新建组件，赋值属性、事件，搬移子 Control，再更名，再删除原组件。
      测试时须覆盖以下场景：窗体、数据模块；可视化组件、不可视组件；
      单选、多选（同 Parent、异 Parent）；有无子 Control 等，包括 FMX}
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AcquireSubActions; override;
    procedure Config; override;
    procedure Loaded; override;
    procedure LaterLoaded; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;

{$IFNDEF IDE_HAS_HIDE_NONVISUAL}
    property HideNonVisual: Boolean read FHideNonVisual;
{$ENDIF}
  end;

//==============================================================================
// 不可视组件排列窗体
//==============================================================================

{ TCnNonArrangeForm }

  TCnNonArrangeForm = class(TCnTranslateForm)
    GroupBox1: TGroupBox;
    rbRow: TRadioButton;
    rbCol: TRadioButton;
    sePerRow: TCnSpinEdit;
    sePerCol: TCnSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    cbbMoveStyle: TComboBox;
    Label5: TLabel;
    seSizeSpace: TCnSpinEdit;
    Label6: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label7: TLabel;
    GroupBox3: TGroupBox;
    chkSortbyClassName: TCheckBox;
    Label8: TLabel;
    grpSpace: TGroupBox;
    seColSpace: TCnSpinEdit;
    lblPixel2: TLabel;
    lblPixel1: TLabel;
    seRowSpace: TCnSpinEdit;
    lblRow: TLabel;
    lblCol: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure UpdateControls(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNDESIGNWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDESIGNWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  TypInfo, CnFormEnhancements, CnListCompFrm, CnCompToCodeFrm, CnScriptWizard,
  CnDesignEditorConsts, CnPrefixExecuteFrm, CnGraphUtils, CnScriptFrm
  {$IFDEF SUPPORT_FMX} , CnFmxUtils {$ENDIF};

{$R *.DFM}

resourcestring
  SOptionDisplayGrid = 'DisplayGrid';
  SOptionShowComponentCaptions = 'ShowComponentCaptions';
  SOptionSnapToGrid = 'SnapToGrid';
  SOptionUseGuidelines = 'UseDesignerGuidelines';
  SOptionGridSizeX = 'GridSizeX';
  SOptionGridSizeY = 'GridSizeY';
  SIDELockControlsMenuName = 'EditLockControlsItem';
  SIDELockControlsActionName = 'EditLockControlsCommand';

  // 10 Seattle 后才自带以下俩功能
  SIDEHideNonvisualsMenuName = 'ToggleNonVisualComponentVisibilityItem';
  SIDEHideNonvisualsActionName = 'ToggleNonVisualComponentVisibilityCommand';

{$IFDEF IDE_ACTION_UPDATE_DELAY}
  SIDEMenuBar = 'MenuBar';
  SEditMenuCaption = '&Edit';
{$ENDIF}

const
  csNonArrangeStyle = 'NonArrangeStyle';
  csNonMoveStyle = 'NonMoveStyle';
  csRowSpace = 'NonArrangeRowSpace';
  csColSpace = 'NonArrangeColSpace';
  csPerRowCount = 'NonArrangePerRowCount';
  csPerColCount = 'NonArrangePerColCount';
  csNonAutoMove = 'NonArrangeAutoMove';
  csSortByClassName = 'SortByClassName';
  csSizeSpace = 'NonArrangeSizeSpace';
  csNonVisualSize = 28;
{$IFDEF DELPHI110_ALEXANDRIA_UP}
  csNonVisualCaptionSize = 18;  // D110 下不可视组件的文字高度有变化且不固定
{$ELSE}
  csNonVisualCaptionSize = 14;
{$ENDIF}
  csNonVisualCaptionV = 30;
  csNonVisualMiddleGap = 4; 

  csSpaceIncStep = 1;

  csDefRowColSpace = 4;
  csDefPerRowCount = 5;
  csDefPerColCount = 3;
  csDefSizeSpace = 16;

  // Action 生效需要选择的最小控件数（部分包括组件数），-1 表示无需判断
  csAlignNeedControls: array[TCnAlignSizeStyle] of Integer = (2, 2, 2, 2, 2, 2,
    3, 2, 2, 2, 2, 3, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0,
    {$IFDEF IDE_HAS_GUIDE_LINE} 0, {$ENDIF} 1, 1, -1, -1, -1, -1,
    0, 0, 0, 0, 0, 0, 1, -1);

  csAlignNeedSepMenu: set of TCnAlignSizeStyle =
    [asAlignVCenter, asSpaceRemoveV, asMakeSameSize, asParentVCenter,
    asSendToBack, asLockControls, asChangeCompClass];

  csAlignSupportsNonVisual: set of TCnAlignSizeStyle =
    [asAlignLeft, asAlignRight, asAlignTop, asAlignBottom,
    asAlignHCenter, asAlignVCenter, asSpaceEquH, asSpaceEquV];

  csAlignSizeNames: array[TCnAlignSizeStyle] of string = (
    'CnAlignLeft', 'CnAlignRight', 'CnAlignTop', 'CnAlignBottom', 'CnAlignHCenter',
    'CnAlignVCenter', 'CnSpaceEquH', 'CnSpaceEquHX', 'CnSpaceIncH', 'CnSpaceDecH', 'CnSpaceRemoveH',
    'CnSpaceEquV', 'CnSpaceEquVY', 'CnSpaceIncV', 'CnSpaceDecV', 'CnSpaceRemoveV',
    'CnIncWidth', 'CnDecWidth', 'CnIncHeight', 'CnDecHeight',
    'CnMakeMinWidth', 'CnMakeMaxWidth', 'CnMakeSameWidth', 'CnMakeMinHeight',
    'CnMakeMaxHeight', 'CnMakeSameHeight', 'CnMakeSameSize', 'CnParentHCenter',
    'CnParentVCenter', 'CnBringToFront', 'CnSendToBack', 'CnSnapToGrid',
    {$IFDEF IDE_HAS_GUIDE_LINE} 'CnUseGuidelines', {$ENDIF}
    'CnAlignToGrid', 'CnSizeToGrid', 'CnLockControls', 'CnSelectRoot',
    'CnCopyCompName', 'CnCopyCompClass', 'CnHideComponent', 'CnNonArrange',
    'CnListComp', 'CnCompareProp', 'CnCompToCode', 'CnChangeCompClass',
    'CnCompRename', 'CnShowFlatForm');

  csAlignSizeCaptions: array[TCnAlignSizeStyle] of PString = (
    @SCnAlignLeftCaption, @SCnAlignRightCaption, @SCnAlignTopCaption,
    @SCnAlignBottomCaption, @SCnAlignHCenterCaption, @SCnAlignVCenterCaption,
    @SCnSpaceEquHCaption, @SCnSpaceEquHXCaption, @SCnSpaceIncHCaption, @SCnSpaceDecHCaption, @SCnSpaceRemoveHCaption,
    @SCnSpaceEquVCaption, @SCnSpaceEquVYCaption, @SCnSpaceIncVCaption, @SCnSpaceDecVCaption, @SCnSpaceRemoveVCaption,
    @SCnIncWidthCaption, @SCnDecWidthCaption, @SCnIncHeightCaption, @SCnDecHeightCaption,
    @SCnMakeMinWidthCaption, @SCnMakeMaxWidthCaption, @SCnMakeSameWidthCaption,
    @SCnMakeMinHeightCaption, @SCnMakeMaxHeightCaption, @SCnMakeSameHeightCaption,
    @SCnMakeSameSizeCaption, @SCnParentHCenterCaption, @SCnParentVCenterCaption,
    @SCnBringToFrontCaption, @SCnSendToBackCaption, @SCnSnapToGridCaption,
    {$IFDEF IDE_HAS_GUIDE_LINE} @SCnUseGuidelinesCaption, {$ENDIF}
    @SCnAlignToGridCaption, @SCnSizeToGridCaption, @SCnLockControlsCaption,
    @SCnSelectRootCaption, @SCnCopyCompNameCaption, @SCnCopyCompClassCaption,
    @SCnHideComponentCaption, @SCnNonArrangeCaption,
    @SCnListCompCaption, @SCnComparePropertyCaption, @SCnCompToCodeCaption,
    @SCnChangeCompClassCaption, @SCnFloatPropBarRenameCaption, @SCnShowFlatFormCaption);

  csAlignSizeHints: array[TCnAlignSizeStyle] of PString = (
    @SCnAlignLeftHint, @SCnAlignRightHint, @SCnAlignTopHint,
    @SCnAlignBottomHint, @SCnAlignHCenterHint, @SCnAlignVCenterHint,
    @SCnSpaceEquHHint, @SCnSpaceEquHXHint, @SCnSpaceIncHHint, @SCnSpaceDecHHint, @SCnSpaceRemoveHHint,
    @SCnSpaceEquVHint, @SCnSpaceEquVYHint, @SCnSpaceIncVHint, @SCnSpaceDecVHint, @SCnSpaceRemoveVHint,
    @SCnIncWidthHint, @SCnDecWidthHint, @SCnIncHeightHint, @SCnDecHeightHint,
    @SCnMakeMinWidthHint, @SCnMakeMaxWidthHint, @SCnMakeSameWidthHint,
    @SCnMakeMinHeightHint, @SCnMakeMaxHeightHint, @SCnMakeSameHeightHint,
    @SCnMakeSameSizeHint, @SCnParentHCenterHint, @SCnParentVCenterHint,
    @SCnBringToFrontHint, @SCnSendToBackHint, @SCnSnapToGridHint,
    {$IFDEF IDE_HAS_GUIDE_LINE} @SCnUseGuidelinesHint, {$ENDIF}
    @SCnAlignToGridHint, @SCnSizeToGridHint, @SCnLockControlsHint,
    @SCnSelectRootHint, @SCnCopyCompNameHint, @SCnCopyCompClassHint,
    @SCnHideComponentHint, @SCnNonArrangeHint, @SCnListCompHint,
    @SCnComparePropertyHint, @SCnCompToCodeHint, @SCnChangeCompClassHint,
    @SCnFloatPropBarRenameCaption, @SCnShowFlatFormHint); // 缺 Hint 的用 Caption 代替

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}

type
  TCnDesignScriptSettingChangedReceiver = class(TInterfacedObject, ICnEventBusReceiver)
  private
    FWizard: TCnDesignWizard;
  public
    constructor Create(AWizard: TCnDesignWizard);
    destructor Destroy; override;

    procedure OnEvent(Event: TCnEvent);
  end;

{$ENDIF}
{$ENDIF}

// 获取一个非可视组件的位置
function GetNonVisualPos(Component: TComponent): TSmallPoint;
begin
  Result := TSmallPoint(Component.DesignInfo);
end;

var
  _ProName: string;
  _Desc: Boolean;
  _IsVert: Boolean;

function DoSortByProp(Item1, Item2: Pointer): Integer;
var
  V1, V2: Integer;
begin
  if _ProName = 'Width' then
  begin
    V1 := GetControlWidth(TComponent(Item1));
    V2 := GetControlWidth(TComponent(Item2));
  end
  else if _ProName = 'Height' then
  begin
    V1 := GetControlHeight(TComponent(Item1));
    V2 := GetControlHeight(TComponent(Item2));
  end
  else if _ProName = 'Top' then
  begin
    V1 := GetControlTop(TComponent(Item1));
    V2 := GetControlTop(TComponent(Item2));
  end
  else if _ProName = 'Left' then
  begin
    V1 := GetControlLeft(TComponent(Item1));
    V2 := GetControlLeft(TComponent(Item2));
  end
  else // FMX 控件貌似通过 GetOrdProp 拿不到以上信息，只能单独处理
  begin
    V1 := GetOrdProp(TComponent(Item1), _ProName);
    V2 := GetOrdProp(TComponent(Item2), _ProName);
  end;

  Result := CompareInt(V1, V2, _Desc);
end;

function DoSortByPos(Item1, Item2: Pointer): Integer;
var
  R1, R2: TRect;
begin
  R1 := GetControlScreenRect(TControl(Item1));
  R2 := GetControlScreenRect(TControl(Item2));
  if _IsVert then
    Result := CompareInt(R1.Top, R2.Top, _Desc)
  else
    Result := CompareInt(R1.Left, R2.Left, _Desc)
end;

function DoSortNonVisualByPos(Item1, Item2: Pointer): Integer;
var
  P1, P2: TSmallPoint;
begin
  P1 := GetNonVisualPos(TComponent(Item1));
  P2 := GetNonVisualPos(TComponent(Item2));
  if _IsVert then
    Result := CompareInt(P1.y, P2.y, _Desc)
  else
    Result := CompareInt(P1.x, P2.x, _Desc)
end;

//==============================================================================
// Align Size 设置工具
//==============================================================================

{ TCnDesignWizard }

constructor TCnDesignWizard.Create;
begin
  inherited;
  FUpdateControlList := TList.Create;
  FUpdateCompList := TList.Create;

  FPropertyCompare := TCnPropertyCompareManager.Create(nil);
{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}
  FScriptsDesignExecutors := TObjectList.Create(False);
  SyncScriptsDesignMenus;

  FScriptSettingChangedReceiver := TCnDesignScriptSettingChangedReceiver.Create(Self);
  EventBus.RegisterReceiver(FScriptSettingChangedReceiver, EVENT_SCRIPT_SETTING_CHANGED);
{$ENDIF}
{$ENDIF}
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorNotifier);
end;

destructor TCnDesignWizard.Destroy;
begin
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorNotifier);
{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}
  EventBus.UnRegisterReceiver(FScriptSettingChangedReceiver);
  FScriptSettingChangedReceiver := nil;
  FScriptsDesignExecutors.Free;
{$ENDIF}
{$ENDIF}
  FPropertyCompare.Free;

  FUpdateCompList.Free;
  FUpdateControlList.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 组件对齐缩放处理
//------------------------------------------------------------------------------

procedure TCnDesignWizard.ControlListSortByProp(List: TList; ProName: string;
  Desc: Boolean);
begin
  _ProName := ProName;
  _Desc := Desc;
  List.Sort(DoSortByProp);
end;

procedure TCnDesignWizard.ControlListSortByPos(List: TList; IsVert, Desc: Boolean);
begin
  _IsVert := IsVert;
  _Desc := Desc;
  List.Sort(DoSortByPos);
end;

procedure TCnDesignWizard.CompListSortByPos(List: TList; IsVert, Desc: Boolean);
begin
  _IsVert := IsVert;
  _Desc := Desc;
  List.Sort(DoSortNonVisualByPos);
end;

procedure TCnDesignWizard.DoAlignSize(AlignSizeStyle: TCnAlignSizeStyle);
var
  I, AWidth, AHeight, ALeft, ATop: Integer;
  AParent, ALeftComp, ARightComp: TComponent;
  Count, Value: Integer;
  Curr: Double;
  ControlList, CompareCompList, CompList: TList;
  AList: TList;
  R1, R2, R3: TRect;
  P1, P2, P3: TPoint;
  GridSizeX, GridSizeY: Integer;
  IsModified: Boolean;
  FormEditor: IOTAFormEditor;
  EnvOptions: IOTAEnvironmentOptions;
  S: string;
  Space: Integer;
  KeyState: TKeyboardState;
  EditAction:IOTAEditActions;
  Ini: TCustomIniFile;
  FirstPos, SecPos: TPoint;
begin
  ControlList := TList.Create;
  CompList := TList.Create;

  try
    if AlignSizeStyle in csAlignSupportsNonVisual then
    begin
      // 可能又支持 Controls 的又支持 Components，要提前拿到两种选择：Controls 与 Components
      // 如果都拿不到则出错
      if (csAlignNeedControls[AlignSizeStyle] > 0) and
        (not CnOtaGetSelectedControlFromCurrentForm(ControlList) and
        not GetNonVisualSelComponentsFromCurrentForm(CompList)) then
        Exit;
    end
    else
    begin
      // 只支持 Controls 的，只要提前拿到 Controls，如果拿不到则出错
      if (csAlignNeedControls[AlignSizeStyle] > 0) and
        (not CnOtaGetSelectedControlFromCurrentForm(ControlList)) then
        Exit;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('DoAlignSize Get Selected Controls %d Components %d',
      [ControlList.Count, CompList.Count]);
{$ENDIF}

    IsModified := True;
    case AlignSizeStyle of
      asAlignLeft, asAlignRight, asAlignTop, asAlignBottom,
      asAlignHCenter, asAlignVCenter:
        begin
          if ControlList.Count >= csAlignNeedControls[AlignSizeStyle] then // 只支持全部是控件
          begin
            R1 := GetControlScreenRect(TComponent(ControlList[0]));
            for I := 1 to ControlList.Count - 1 do
            begin
              R2 := GetControlScreenRect(TComponent(ControlList[I]));

              if AlignSizeStyle = asAlignLeft then
                OffsetRect(R2, R1.Left - R2.Left, 0)
              else if AlignSizeStyle = asAlignRight then
                OffsetRect(R2, R1.Right - R2.Right, 0)
              else if AlignSizeStyle = asAlignTop then
                OffsetRect(R2, 0, R1.Top - R2.Top)
              else if AlignSizeStyle = asAlignBottom then
                OffsetRect(R2, 0, R1.Bottom - R2.Bottom)
              else if AlignSizeStyle = asAlignVCenter then
                OffsetRect(R2, 0, (R1.Top + R1.Bottom - R2.Top - R2.Bottom) div 2)
              else // AlignSizeStyle = asAlignHCenter
                OffsetRect(R2, (R1.Left + R1.Right - R2.Left - R2.Right) div 2, 0);

              SetControlScreenRect(TComponent(ControlList[I]), R2);
            end;
          end
          else if CompList.Count >= csAlignNeedControls[AlignSizeStyle] then // 控件选择数量不足或未选择时，只支持全部是可视化组件
          begin
            FirstPos := GetComponentGeneralPos(CompList[0]);
            for I := 1 to CompList.Count - 1 do
            begin
              SecPos := GetComponentGeneralPos(CompList[I]);

              if AlignSizeStyle in [asAlignLeft, asAlignRight, asAlignHCenter] then
                SecPos.x := FirstPos.x
              else if AlignSizeStyle in [asAlignTop, asAlignBottom, asAlignVCenter]  then
                SecPos.y := FirstPos.y;

              SetComponentGeneralPos(GetDesignerForm, CompList[I], SecPos);
            end;
          end;
        end;
      asSpaceEquH, asSpaceEquV: // 暂不支持可视化组件
        begin
          if ControlList.Count >= 3 then
          begin
            ControlListSortByPos(ControlList, AlignSizeStyle = asSpaceEquV);

            R1 := GetControlScreenRect(TComponent(ControlList[0]));
            R2 := GetControlScreenRect(TComponent(ControlList[ControlList.Count - 1]));
            Count := 0;
            for I := 1 to ControlList.Count - 2 do
            begin
              R3 := GetControlScreenRect(TComponent(ControlList[I]));
              if AlignSizeStyle = asSpaceEquH then
                Inc(Count, R3.Right - R3.Left)
              else
                Inc(Count, R3.Bottom - R3.Top);
            end;

            if AlignSizeStyle = asSpaceEquH then
              Curr := R1.Right
            else
              Curr := R1.Bottom;
            for I := 1 to ControlList.Count - 2 do
            begin
              if AlignSizeStyle = asSpaceEquH then
                Curr := Curr + (R2.Left - R1.Right - Count) / (ControlList.Count - 1)
              else
                Curr := Curr + (R2.Top - R1.Bottom - Count) / (ControlList.Count - 1);
              R3 := GetControlScreenRect(TComponent(ControlList[I]));
              if AlignSizeStyle = asSpaceEquH then
                OffsetRect(R3, Round(Curr) - R3.Left, 0)
              else
                OffsetRect(R3, 0, Round(Curr) - R3.Top);
              SetControlScreenRect(TComponent(ControlList[I]), R3);
              if AlignSizeStyle = asSpaceEquH then
                Curr := Curr + R3.Right - R3.Left
              else
                Curr := Curr + R3.Bottom - R3.Top;
            end;
          end
          else if CompList.Count >= 3 then
          begin
            CompListSortByPos(CompList, AlignSizeStyle = asSpaceEquV);

            P1 := GetComponentGeneralPos(TComponent(CompList[0]));
            P2 := GetComponentGeneralPos(TComponent(CompList[CompList.Count - 1]));

            if AlignSizeStyle = asSpaceEquH then
              Curr := P1.x
            else
              Curr := P1.y;

            for I := 1 to CompList.Count - 2 do
            begin
              if AlignSizeStyle = asSpaceEquH then
                Curr := Curr + (P2.x - P1.x) / (CompList.Count - 1)
              else
                Curr := Curr + (P2.y - P1.y) / (CompList.Count - 1);

              P3 := GetComponentGeneralPos(TComponent(CompList[I]));
              if AlignSizeStyle = asSpaceEquH then
                P3.x := Round(Curr)
              else
                P3.y := Round(Curr);

              SetComponentGeneralPos(GetDesignerForm, TComponent(CompList[I]), P3);
            end;
          end;
        end;
      asSpaceEquHX, asSpaceEquVY:
        begin
          if ControlList.Count < 2 then Exit;
          ControlListSortByPos(ControlList, AlignSizeStyle = asSpaceEquVY);

          S := '4';
          if not CnWizInputQuery(SCnInformation, SCnSpacePrompt, S) then
            Exit;

          if IsInt(S) then
            Space := StrToInt(S)
          else
          begin
            ErrorDlg(SCnMustDigital);
            Exit;
          end;

          // 获得了手工间距，开始排列
          R1 := GetControlScreenRect(TComponent(ControlList[0]));
          if AlignSizeStyle = asSpaceEquHX then
            Curr := R1.Right
          else
            Curr := R1.Bottom;

          for I := 1 to ControlList.Count - 1 do
          begin
            Curr := Curr + Space;

            R3 := GetControlScreenRect(TComponent(ControlList[I]));
            if AlignSizeStyle = asSpaceEquHX then
              OffsetRect(R3, Round(Curr) - R3.Left, 0)
            else
              OffsetRect(R3, 0, Round(Curr) - R3.Top);
            SetControlScreenRect(TComponent(ControlList[I]), R3);

            if AlignSizeStyle = asSpaceEquHX then
              Curr := Curr + R3.Right - R3.Left
            else
              Curr := Curr + R3.Bottom - R3.Top;
          end;
        end;
      asSpaceIncH, asSpaceDecH, asSpaceRemoveH,
      asSpaceIncV, asSpaceDecV, asSpaceRemoveV:
        begin
          ControlListSortByPos(ControlList, AlignSizeStyle in
            [asSpaceIncV, asSpaceDecV, asSpaceRemoveV]);
          R1 := GetControlScreenRect(TComponent(ControlList[0]));

          for I := 1 to ControlList.Count - 1 do
          begin
            R2 := GetControlScreenRect(TComponent(ControlList[I]));
            if AlignSizeStyle = asSpaceIncH then
              OffsetRect(R2, csSpaceIncStep * I, 0)
            else if AlignSizeStyle = asSpaceIncV then
              OffsetRect(R2, 0, csSpaceIncStep * I)
            else if AlignSizeStyle = asSpaceDecH then
              OffsetRect(R2, -csSpaceIncStep * I, 0)
            else if AlignSizeStyle = asSpaceDecV then
              OffsetRect(R2, 0, -csSpaceIncStep * I)
            else if AlignSizeStyle = asSpaceRemoveH then
              OffsetRect(R2, R1.Right - R2.Left, 0)
            else // AlignSizeStyle = asSpaceRemoveV then
              OffsetRect(R2, 0, R1.Bottom - R2.Top);
            SetControlScreenRect(TComponent(ControlList[I]), R2);
            R1 := R2;
          end;
        end;
      asIncWidth, asDecWidth, asIncHeight, asDecHeight, // FMX Support
      asAlignToGrid, asSizeToGrid:
       begin
          try
            EnvOptions := CnOtaGetEnvironmentOptions;
            GridSizeX := EnvOptions.GetOptionValue(SOptionGridSizeX);
            GridSizeY := EnvOptions.GetOptionValue(SOptionGridSizeY);
            if (GridSizeX <> 0) and (GridSizeY <> 0) then
            begin
              for I := 0 to ControlList.Count - 1 do
              begin
                ALeft := GetControlLeft(TComponent(ControlList[I]));
                ATop := GetControlTop(TComponent(ControlList[I]));
                AWidth := GetControlWidth(TComponent(ControlList[I]));
                AHeight := GetControlHeight(TComponent(ControlList[I]));

                if AlignSizeStyle = asIncWidth then
                  SetControlWidth(TComponent(ControlList[I]), AWidth + GridSizeX)
                else if AlignSizeStyle = asDecWidth then
                begin
                  if AWidth > GridSizeX then
                    SetControlWidth(TComponent(ControlList[I]), AWidth - GridSizeX);
                end
                else if AlignSizeStyle = asIncHeight then
                  SetControlHeight(TComponent(ControlList[I]), AHeight + GridSizeY)
                else if AlignSizeStyle = asDecHeight then
                begin
                  if AHeight > GridSizeY then
                    SetControlHeight(TComponent(ControlList[I]), AHeight - GridSizeY);
                end
                else
                begin
                  SetControlLeft(TComponent(ControlList[I]), ALeft - ALeft mod GridSizeX);
                  SetControlTop(TComponent(ControlList[I]), ATop - ATop mod GridSizeY);
                  if AlignSizeStyle = asSizeToGrid then
                  begin
                    SetControlWidth(TComponent(ControlList[I]), Round(AWidth / GridSizeX) * GridSizeX);
                    SetControlHeight(TComponent(ControlList[I]), Round(AHeight / GridSizeY) * GridSizeY);
                  end;
                end;
              end;
            end;
          except
            DoHandleException('AlignToGrid Error.');
          end;
        end;
      asMakeMinWidth, asMakeMaxWidth, asMakeSameWidth,
      asMakeMinHeight, asMakeMaxHeight, asMakeSameHeight,
      asMakeSameSize:
        begin
          if AlignSizeStyle in [asMakeMinWidth, asMakeMaxWidth] then
            ControlListSortByProp(ControlList, 'Width', AlignSizeStyle = asMakeMaxWidth)
          else if AlignSizeStyle in [asMakeMinHeight, asMakeMaxHeight] then
            ControlListSortByProp(ControlList, 'Height', AlignSizeStyle = asMakeMaxHeight);

          if AlignSizeStyle in [asMakeMinWidth, asMakeMaxWidth,
            asMakeSameWidth, asMakeSameSize] then
          begin
            Value := GetControlWidth(TComponent(ControlList[0]));
{$IFDEF DEBUG}
            CnDebugger.LogFmt('DoAlignSize. Make %d Controls Width to %d', [ControlList.Count, Value]);
{$ENDIF}
            for I := 1 to ControlList.Count - 1 do
              SetControlWidth(TComponent(ControlList[I]), Value);
          end;

          if AlignSizeStyle in [asMakeMinHeight, asMakeMaxHeight,
            asMakeSameHeight, asMakeSameSize] then
          begin
            Value := GetControlHeight(TComponent(ControlList[0]));
{$IFDEF DEBUG}
            CnDebugger.LogFmt('DoAlignSize. Make %d Controls Height to %d', [ControlList.Count, Value]);
{$ENDIF}
            for I := 1 to ControlList.Count - 1 do
              SetControlHeight(TComponent(ControlList[I]), Value);
          end;
        end;
      asParentHCenter, asParentVCenter:
        begin
          AList := TList.Create;
          try
            while ControlList.Count > 0 do
            begin
              // 取出 Parent 相同的一组控件
              AList.Clear;
              AList.Add(ControlList.Extract(ControlList[0]));
              for I := ControlList.Count - 1 downto 0 do
                if GetControlParent(TComponent(ControlList[I])) = GetControlParent(TComponent(TControl(AList[0]))) then
                  AList.Add(ControlList.Extract(ControlList[I]));

              if AlignSizeStyle = asParentHCenter then
              begin
                // 计算控件组的外接宽度
                R1.Left := MaxInt;
                R1.Right := -MaxInt;
                for I := 0 to AList.Count - 1 do
                begin
                  R1.Left := Min(GetControlLeft(TControl(AList[I])), R1.Left);
                  R1.Right := Max(GetControlLeft(TControl(AList[I])) + GetControlWidth(TControl(AList[I])), R1.Right);
                end;

                // 要移动的距离
                AParent := GetControlParent(TControl(AList[0]));
                if AParent <> nil then
                begin
                  if AParent is TControl then
                    AWidth := TControl(AParent).ClientWidth
                  else // FMX
                    AWidth := GetControlWidth(AParent);
                  Value := (AWidth - R1.Left - R1.Right) div 2;

                  for I := 0 to AList.Count - 1 do
                    SetControlLeft(TControl(AList[I]), GetControlLeft(TControl(AList[I])) + Value);
                end;
              end
              else
              begin
                // 计算控件组的外接高度
                R1.Top := MaxInt;
                R1.Bottom := -MaxInt;
                for I := 0 to AList.Count - 1 do
                begin
                  R1.Top := Min(GetControlTop(TControl(AList[I])), R1.Top);
                  R1.Bottom := Max(GetControlTop(TControl(AList[I])) + GetControlHeight(TControl(AList[I])), R1.Bottom);
                end;

                // 要移动的距离
                AParent := GetControlParent(TControl(AList[0]));
                if AParent <> nil then
                begin
                  if AParent is TControl then
                    AHeight := TControl(AParent).ClientHeight
                  else // FMX
                    AHeight := GetControlHeight(AParent);
                  Value := (AHeight - R1.Top - R1.Bottom) div 2;

                  for I := 0 to AList.Count - 1 do
                    SetControlTop(TControl(AList[I]), GetControlTop(TControl(AList[I])) + Value);
                end;
              end;
            end;
          finally
            AList.Free;
          end;
        end;
      asBringToFront, asSendToBack:
        begin
          for I := 0 to ControlList.Count - 1 do
            if AlignSizeStyle = asBringToFront then
              ControlBringToFront(TComponent(ControlList[I]))
            else
              ControlSendToBack(TComponent(ControlList[I]));
        end;
      asSnapToGrid:
        begin
          EnvOptions := CnOtaGetEnvironmentOptions;
          try
            if Assigned(EnvOptions) then
              EnvOptions.Values[SOptionSnapToGrid] :=
                not EnvOptions.Values[SOptionSnapToGrid];
            IsModified := False;
          except
            DoHandleException('SnapToGrid Error.');
          end;
        end;
      {$IFDEF IDE_HAS_GUIDE_LINE}
      asUseGuidelines:
        begin
          EnvOptions := CnOtaGetEnvironmentOptions;
          try
            if Assigned(EnvOptions) then
              EnvOptions.Values[SOptionUseGuidelines] :=
                not EnvOptions.Values[SOptionUseGuidelines];
            IsModified := False;
          except
            DoHandleException('UseGuidelines Error.');
          end;
        end;
      {$ENDIF}        
      asLockControls:
        begin
          if Assigned(FIDELockControlsMenu) then
          begin
            FIDELockControlsMenu.Click;
            CnWizNotifierServices.ExecuteOnApplicationIdle(RequestLockControlsMenuUpdate);
          end;
          IsModified := False;
        end;
      asSelectRoot:
        begin
          CnOtaSetCurrFormSelectRoot;
          IsModified := False;
        end;
      asCopyCompName, asCopyCompClass:
        begin
          if AlignSizeStyle = asCopyCompName then
            CnOtaCopyCurrFormSelectionsName
          else
            CnOtaCopyCurrFormSelectionsClassName;

          GetKeyboardState(KeyState);
          if (KeyState[VK_SHIFT] and $80) = 0 then // 按 Shift 不跳
          begin
            // Switch To Code
            if IsForm(CnOtaGetCurrentSourceFile) then
            begin
              EditAction := CnOtaGetEditActionsFromModule(CnOtaGetCurrentModule);
              if Assigned(EditAction) then
                EditAction.ToggleFormUnit;
            end;
          end;
          
          IsModified := False;
        end;
      asHideComponent:
        begin
          HideNonvisualComponent;
          IsModified := False;
        end;
      asNonArrange:
        begin
          NonVisualArrange;
          IsModified := False;
        end;
      asListComp:
        begin
          // 弹出列表供选择
          Ini := CreateIniFile();
          try
            CnListComponent(Ini);
          finally
            Ini.Free;
          end;
          IsModified := False;
        end;
      asCompareProp:
        begin
          // 有选择一个就比一个，没选择就空弹
          CompareCompList := TList.Create;
          try
            CnOtaGetSelectedComponentFromCurrentForm(CompareCompList);
            ALeftComp := nil;
            ARightComp := nil;
            if CompareCompList.Count > 0 then
              ALeftComp := TComponent(CompareCompList[0]);
            if CompareCompList.Count > 1 then
              ARightComp := TComponent(CompareCompList[1]);
          finally
            CompareCompList.Free;
          end;

          CompareTwoObjects(ALeftComp, ARightComp);
        end;
      asCompToCode:
        begin
          ShowCompToCodeForm.RefreshCode;
        end;
      asChangeCompClass:
        begin
          ChangeComponentClass;
        end;
      asCompRename:
        begin
          if (ControlList.Count > 0) and (TObject(ControlList[0]) is TComponent) and
            (Trim(TComponent(ControlList[0]).Name) <> '') then
          begin
            if Assigned(RenameProc) then
              RenameProc(TComponent(ControlList[0]))
            else
              ErrorDlg(SCnPrefixWizardNotExist);
          end;
        end;
      asShowFlatForm:
        begin
          ShowFlatForm;
          IsModified := False;
        end;
    end;

    for I := 0 to ControlList.Count - 1 do
      InvalidateControl(ControlList[I]);
    
    if IsModified then
    begin
      FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
      if Assigned(FormEditor) then
        FormEditor.MarkModified;
    end;
  finally
    CompList.Free;
    ControlList.Free;
  end;
end;

//------------------------------------------------------------------------------
// 隐藏不可视组件
//------------------------------------------------------------------------------

procedure TCnDesignWizard.HideNonvisualComponent;
begin
  if Assigned(FIDEHideNonvisualsMenu) then // 如果 IDE 有此功能
  begin
    FIDEHideNonvisualsMenu.Click;
    CnWizNotifierServices.ExecuteOnApplicationIdle(RequestNonvisualsMenuUpdate);
  end
  else if UpdateNonVisualComponent(CnOtaGetCurrentFormEditor) then
  begin
    FHideNonVisual := not FHideNonvisual;
    SubActions[Indexes[asHideComponent]].Checked := FHideNonVisual;
  end
  else
    ErrorDlg(SCnHideNonVisualNotSupport);
end;

function TCnDesignWizard.UpdateNonVisualComponent(
  FormEditor: IOTAFormEditor): Boolean;
var
  Component: IOTAComponent;
  ACompHandle: TOTAHandle;

  procedure DoHideNonvisualComponent(WinControl: TWinControl);
  var
    H, AHandle: HWND;
  begin
    if WinControl = nil then
      Exit;
    AHandle := WinControl.Handle;
    if AHandle = 0 then
      Exit;

    H := GetWindow(AHandle, GW_CHILD);
    if H <> 0 then
      H := GetWindow(H, GW_HWNDLAST);

    while H <> 0 do
    begin
      if HWndIsNonvisualComponent(H) then
        if Active and FHideNonVisual then
          ShowWindow(H, SW_HIDE)
        else
          ShowWindow(H, SW_SHOW);

      H := GetWindow(H, GW_HWNDPREV);
    end;
  end;

begin
  Result := False;
  if Assigned(FormEditor) and IsVCLFormEditor(FormEditor) then
  begin
    Component := FormEditor.GetRootComponent;
    if Component <> nil then
    begin
      ACompHandle := Component.GetComponentHandle;
      if ACompHandle <> nil then
      begin
        if (TObject(ACompHandle) is TWinControl) then
        begin
          DoHideNonvisualComponent(TWinControl(ACompHandle));
          Result := True;
        end;
      end;
    end;
  end;
end;

procedure TCnDesignWizard.FormEditorNotifier(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  // IDE 自身没这功能时才需要手动更新新窗体上的状态
  if Active and (NotifyType = fetActivated) and (FIDEHideNonvisualsMenu = nil) then
    UpdateNonVisualComponent(FormEditor);

  if Active and (NotifyType = fetOpened) and (FIDELockControlsMenu <> nil) and
    FIDELockControlsMenu.Enabled and FIDELockControlsMenu.Checked then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Form Editor Opened and Controls Locked. Do Re-Lock.');
{$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(LockMenuExecuteReLock);
  end;
end;

procedure TCnDesignWizard.LockMenuExecuteReLock(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('LockMenuExecute to Re-Lock.');
{$ENDIF}
  if FIDELockControlsMenu <> nil then
  begin
    FIDELockControlsMenu.Click;
    Sleep(0);
    FIDELockControlsMenu.Click;

    CnWizNotifierServices.ExecuteOnApplicationIdle(RequestLockControlsMenuUpdate);
  end;
end;

//------------------------------------------------------------------------------
// 排列不可视组件
//------------------------------------------------------------------------------

procedure TCnDesignWizard.NonVisualArrange;
begin
  with TCnNonArrangeForm.Create(nil) do
  begin
    rbRow.Checked := FNonArrangeStyle = asRow;
    rbCol.Checked := FNonArrangeStyle = asCol;
    sePerRow.Value := FPerRowCount;
    sePerCol.Value := FPerColCount;
    seRowSpace.Value := FRowSpace;
    seColSpace.Value := FColSpace;
    cbbMoveStyle.ItemIndex := Ord(FNonMoveStyle);
    seSizeSpace.Value := FSizeSpace;
    chkSortByClassName.Checked := FSortByClassName;

    if ShowModal = mrOK then
    begin
      if rbRow.Checked then FNonArrangeStyle := asRow
      else if rbCol.Checked then FNonArrangeStyle := asCol;
      FPerRowCount := sePerRow.Value;
      FPerColCount := sePerCol.Value;
      FRowSpace := seRowSpace.Value;
      FColSpace := seColSpace.Value;
      FNonMoveStyle := TNonMoveStyle(cbbMoveStyle.ItemIndex);
      FSizeSpace := seSizeSpace.Value;
      FSortByClassName := chkSortByClassName.Checked;

      ArrangeNonVisualComponents;
    end;
    Free;
  end;
end;

function SortByClassNameProc(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TComponent(Item1).ClassName, TComponent(Item2).ClassName);
  if Result = 0 then // 类名相同时用控件名比较
    Result := CompareText(TComponent(Item1).Name, TComponent(Item2).Name);
end;

function TCnDesignWizard.GetDesignerForm: TCustomForm;
var
{$IFDEF COMPILER6_UP}
  FormDesigner: IDesigner;
  AContainer: TComponent;
{$ELSE}
  FormDesigner: IFormDesigner;
{$ENDIF}
begin
  Result := nil;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF COMPILER6_UP}
  AContainer := FormDesigner.Root;

  // 注意 FMX 下这里能拿到 Root，但过不了以下判断，需要另起
  if (AContainer is TWinControl) or ObjectIsInheritedFromClass(AContainer, 'TWidgetControl') then
    Result := TCustomForm(AContainer)
  else if (AContainer.Owner <> nil)
    and AContainer.Owner.ClassNameIs('TDataModuleForm') then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('AContainer Owner is DataModule Form.');
{$ENDIF}
    Result := AContainer.Owner as TCustomForm;
  end;
{$ELSE}
  Result := FormDesigner.Form;
{$ENDIF}
end;

{$IFDEF SUPPORT_FMX}

function TCnDesignWizard.GetFmxDesignerForm: TComponent;
var
  FormDesigner: IDesigner;
  AContainer: TComponent;
begin
  Result := nil;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

  AContainer := FormDesigner.Root;

  // 注意 FMX 下这里能拿到 Root 且要判断是否是 FMX 的Form
  if CnFmxIsInheritedFromCommonCustomForm(AContainer) then
  begin
    Result := AContainer;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Get Fmx Form ' + AContainer.ClassName);
{$ENDIF}
  end;
end;

{$ENDIF}

procedure TCnDesignWizard.ArrangeNonVisualComponents;
var
  CompList: TList;
  I, Rows, Cols, cRow, cCol, ContainerWidth, ContainerHeight: Integer;
  CompPosArray: array of TPoint;
  AForm: TCustomForm;
  AFmxForm: TComponent;
  AllWidth, AllHeight, OffSetX, OffSetY: Integer;
{$IFDEF COMPILER6_UP}
  FormDesigner: IDesigner;
{$ELSE}
  FormDesigner: IFormDesigner;
{$ENDIF}
begin
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

  AForm := GetDesignerForm;
{$IFDEF SUPPORT_FMX}
  AFmxForm := GetFmxDesignerForm;
{$ELSE}
  AFmxForm := nil;
{$ENDIF}

  if (AForm = nil) {$IFDEF SUPPORT_FMX} and (AFmxForm = nil) {$ENDIF} then
  begin
    ErrorDlg(SCnNonNonVisualNotSupport);
    Exit;
  end;

  CompList := TList.Create;
  try
    if not GetNonVisualSelComponentsFromCurrentForm(CompList) and
      not GetNonVisualComponentsFromCurrentForm(CompList) then
    begin
      ErrorDlg(SCnNonNonVisualFound);
      Exit;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(CompList.Count, 'CompList Count: ');
{$ENDIF}

    if FSortByClassName then
      CompList.Sort(SortByClassNameProc);

    // 按规矩排列了。
    if FNonArrangeStyle = asRow then
    begin
      Cols := FPerRowCount;
      Rows := (CompList.Count div Cols) + 1;
    end
    else // if FNonArrangeStyle = asCol then
    begin
      Rows := FPerColCount;
      Cols := (CompList.Count div Rows) + 1;
    end;

    SetLength(CompPosArray, CompList.Count);
    cRow := 1; cCol := 1;

    for I := 0 to CompList.Count - 1 do
    begin
      CompPosArray[I].x := (cCol - 1) * (csNonVisualSize + FColSpace);
      CompPosArray[I].y := (cRow - 1) * (csNonVisualSize + FRowSpace);
      if FNonArrangeStyle = asRow then
      begin
        Inc(cCol);
        if cCol > Cols then
        begin
          Inc(cRow);
          cCol := 1;
        end;
      end
      else if FNonArrangeStyle = asCol then
      begin
        Inc(cRow);
        if cRow > Rows then
        begin
          Inc(cCol);
          cRow := 1;
        end;
      end;
    end;

    // 接着处理位置
    if FNonArrangeStyle = asRow then
      if cRow = 1 then Cols := cCol - 1;
    if FNonArrangeStyle = asCol then
      if cCol = 1 then Rows := cRow - 1;

    // 现在的 Rows 和 Cols 记录了实际排列的行列数。
    AllWidth := Cols * (csNonVisualSize + FColSpace) - FColSpace;
    AllHeight := Rows * (csNonVisualSize + FRowSpace) - FRowSpace;

    if AForm <> nil then
    begin
      ContainerWidth := AForm.ClientWidth;
      ContainerHeight := AForm.ClientHeight;
    end;

{$IFDEF SUPPORT_FMX}
    if AFmxForm <> nil then
      CnFmxGetFormClientSize(AFmxForm, ContainerWidth, ContainerHeight);
{$ENDIF}

    OffSetX := 0; OffSetY := 0;
    case FNonMoveStyle of
      msLeftTop:
        begin
          OffSetX := FSizeSpace;
          OffSetY := FSizeSpace;
        end;
      msRightTop:
        begin
          OffSetX := ContainerWidth - AllWidth - FSizeSpace;
          OffSetY := FSizeSpace;
        end;
      msLeftBottom:
        begin
          OffSetX := FSizeSpace;
          OffSetY := ContainerHeight - AllHeight - FSizeSpace;
        end;
      msRightBottom:
        begin
          OffSetX := ContainerWidth - AllWidth - FSizeSpace;
          OffSetY := ContainerHeight - AllHeight - FSizeSpace;
        end;
      msCenter:
        begin
          OffSetX := (ContainerWidth - AllWidth) div 2;
          OffSetY := (ContainerHeight - AllHeight) div 2;
        end;
    end;

    for I := CompList.Count - 1 downto 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Component #%d. %s: %s, X %d, Y %d.', [ I,
        TComponent(CompList.Items[I]).ClassName,
        TComponent(CompList.Items[I]).Name,
        CompPosArray[I].X + OffSetX,
        CompPosArray[I].Y + OffSetY]);
{$ENDIF}
      SetNonVisualPos(AForm, TComponent(CompList.Items[I]),
        CompPosArray[I].X + OffSetX, CompPosArray[I].Y + OffSetY);
    end;

    FormDesigner.Modified;

    if AFmxForm <> nil then
    begin
      // SetNonVisualPos 在 FMX 设计器中无法直接修改位置，只能修改 DesignInfo
      // 这里要触发一次 View as Text 再 View as Form 来让其生效
      // 也就是连续执行两次 ViewSwapSourceFormCommand 这个 Action
      ExecuteIDEAction('ViewSwapSourceFormCommand');
      Sleep(0);
      ExecuteIDEAction('ViewSwapSourceFormCommand');
    end;
  finally
    SetLength(CompPosArray, 0);
    CompList.Free;
  end;
end;

function TCnDesignWizard.GetNonVisualComponentsFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  RootComponent: IOTAComponent;
  IComponent: IOTAComponent;
  Component: TComponent;
  CompList: TStrings;
  I: Integer;
begin
  Result := False;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  RootComponent := FormEditor.GetRootComponent;

  CompList := TStringList.Create;
  try
    GetInstalledComponents(nil, CompList);
    for I := 0 to RootComponent.GetComponentCount - 1 do
    begin
      IComponent := RootComponent.GetComponent(I);
      if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
        (TObject(IComponent.GetComponentHandle) is TComponent) then
      begin
        Component := TObject(IComponent.GetComponentHandle) as TComponent;
        if Assigned(Component) and not (Component is TControl)
          {$IFDEF SUPPORT_FMX} and not CnFmxIsInheritedFromControl(Component) {$ENDIF} and
          (CompList.IndexOf(Component.ClassName) >= 0) then
          List.Add(Component);
      end;
    end;
  finally
    CompList.Free;
  end;

  Result := List.Count > 0;
end;

function TCnDesignWizard.GetNonVisualSelComponentsFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  CompList: TStrings;
  I: Integer;
begin
  Result := False;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  CompList := TStringList.Create;
  try
    GetInstalledComponents(nil, CompList);
    for I := 0 to FormEditor.GetSelCount - 1 do
    begin
      IComponent := FormEditor.GetSelComponent(I);
      if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
        (TObject(IComponent.GetComponentHandle) is TComponent) then
      begin
        Component := TObject(IComponent.GetComponentHandle) as TComponent;
        if Assigned(Component) and not (Component is TControl)
          {$IFDEF SUPPORT_FMX} and not CnFmxIsInheritedFromControl(Component) {$ENDIF}  and
          (CompList.IndexOf(Component.ClassName) >= 0) then
          List.Add(Component);
      end;
    end;
  finally
    CompList.Free;
  end;

  Result := List.Count > 0;
end;

function TCnDesignWizard.GetComponentGeneralPos(Component: TComponent): TPoint;
var
  P: TSmallPoint;
begin
  if Component is TControl then // VCL 的 Control
  begin
    Result.x := TControl(Component).Left;
    Result.y := TControl(Component).Top;
  end
{$IFDEF SUPPORT_FMX}
  else if CnFmxIsInheritedFromControl(Component) then // FMX 的 Control
  begin
    Result.x := CnFmxGetControlPositionValue(Component, fptLeft);
    Result.y := CnFmxGetControlPositionValue(Component, fptTop);
  end
{$ENDIF}
  else // 不可视组件
  begin
    P := GetNonVisualPos(Component);
    Result.x := P.x;
    Result.y := P.y;
  end;
end;

procedure TCnDesignWizard.SetComponentGeneralPos(Form: TCustomForm;
  Component: TComponent; APos: TPoint);
begin
  if Component is TControl then // VCL 的 Control
  begin
    TControl(Component).Left := APos.x;
    TControl(Component).Top := APos.y;
  end
{$IFDEF SUPPORT_FMX}
  else if CnFmxIsInheritedFromControl(Component) then // FMX 的 Control
  begin
    CnFmxSetControlPositionValue(Component, APos.x, fptLeft);
    CnFmxSetControlPositionValue(Component, APos.y, fptTop);
  end
{$ENDIF}
  else // 不可视组件
  begin
    SetNonVisualPos(Form, Component, APos.x, APos.y);
  end;
end;

procedure TCnDesignWizard.SetNonVisualPos(Form: TCustomForm;
  Component: TComponent; X, Y: Integer);
var
  P: TSmallPoint;
  H1, H2: HWND;
  Offset: TPoint;

  // 此函数目前已支持 DataModule
  procedure GetComponentContainerHandle(AForm: TCustomForm; L, T: Integer;
    out InternalH1, InternalH2: HWND; out Offset: TPoint);
  var
    R1, R2: TRect;
    P: TPoint;
    ParentHandle: HWND;
    AControl: TWinControl;
    I, NVSize, CapV, CapSize, MidGap: Integer;
  begin
    ParentHandle := AForm.Handle;
    AControl := AForm;
{$IFDEF DEBUG}
//    CnDebugger.LogComponent(AForm);
{$ENDIF}

{$IFDEF COMPILER5}
    if AForm.ClassNameIs('TDataModuleDesigner') then // 是 DataModule
    begin
      if (AForm.FindComponent('FrameTTraditionalEditorFrame1') <> nil)
        and (AForm.FindComponent('FrameTTraditionalEditorFrame1') is TWinControl) then
      begin
        AControl := AForm.FindComponent('FrameTTraditionalEditorFrame1') as TWinControl;

        // Delphi 5 下的 DataModule 结构是:
        // Form->PageControl->TabSheet->FrameTTraditionalEditorFrame1->TComponentContainer
        // 需要找到用来容纳各个组件的 TComponentContainer 实例
        for I := 0 to AControl.ControlCount - 1 do
        begin
          if AControl.Controls[I].ClassNameIs('TComponentContainer')
            and (AControl.Controls[I] is TWinControl) then
          begin
            AControl := AControl.Controls[I] as TWinControl;
            ParentHandle := AControl.Handle;
            Break;
          end;
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('AControl %d, Handle %d, Children %d',
          [Integer(AControl), ParentHandle, AControl.ControlCount]);
{$ENDIF}
      end;
    end;
{$ELSE}
    if AForm.ClassNameIs('TDataModuleForm') then // 是 DataModule
    begin
      // Delphi 6 以上的 DataModule 结构是 Form->TComponentContainer
      // 需要找到用来容纳各个组件的 TComponentContainer 实例
{$IFDEF DEBUG}
        CnDebugger.LogFmt('AForm %d Children %d',
          [Integer(AForm), AForm.ControlCount]);
{$ENDIF}
      for I := 0 to AForm.ControlCount - 1 do
      begin
        if AForm.Controls[I].ClassNameIs('TComponentContainer')
          and (AForm.Controls[I] is TWinControl) then
        begin
          AControl := AForm.Controls[I] as TWinControl;
          ParentHandle := AControl.Handle;
          Break;
        end;
      end;
    end;
{$ENDIF}

    // ParentHandle 总之是个大容器的 Handle
    InternalH2 := 0;
    InternalH1 := GetWindow(ParentHandle, GW_CHILD);
    InternalH1 := GetWindow(InternalH1, GW_HWNDLAST);

    NVSize := IdeGetScaledPixelsFromOrigin(csNonVisualSize, AControl); // 有 HDPI 放大
    CapV := IdeGetScaledPixelsFromOrigin(csNonVisualCaptionV, AControl);
    CapSize := IdeGetScaledPixelsFromOrigin(csNonVisualCaptionSize, AControl);
    MidGap := IdeGetScaledPixelsFromOrigin(csNonVisualMiddleGap, AControl);

    while InternalH1 <> 0 do
    begin
      if HWndIsNonvisualComponent(InternalH1) and GetWindowRect(InternalH1, R1) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogInteger(InternalH1, 'GetComponentContainerHandle InternalH1: ');
        CnDebugger.LogRect(R1, 'GetComponentContainerHandle Rect1: ');
{$ENDIF}
        P.x := R1.Left;
        P.y := R1.Top;
        P := AControl.ScreenToClient(P);

        // 此处取得组件对应的窗体句柄
        if (P.x = L) and (P.y = T) and (R1.Right - R1.Left = NVSize) and
          (R1.Bottom - R1.Top = NVSize) then
        begin
          InternalH2 := GetWindow(ParentHandle, GW_CHILD);
          InternalH2 := GetWindow(InternalH2, GW_HWNDLAST);

          while InternalH2 <> 0 do
          begin
            if HWndIsNonvisualComponent(InternalH2) and GetWindowRect(InternalH2, R2) then
            begin
{$IFDEF DEBUG}
              CnDebugger.LogInteger(InternalH2, 'GetComponentContainerHandle InternalH2: ');
              CnDebugger.LogRect(R2, 'GetComponentContainerHandle Rect2: ');
{$ENDIF}
              // 此处取得组件标题对应的窗体句柄
              if (R2.Top - R1.Top = CapV) and
                (Abs(R2.Left + R2.Right - R1.Left - R1.Right) <= MidGap) and // 居中
                ((R2.Bottom - R2.Top = CapSize) {$IFDEF DELPHI110_ALEXANDRIA_UP} or ((R2.Top - R1.Bottom) in [1..4]){$ENDIF}) then
              begin
                Offset.x := R2.Left - R1.Left;
                Offset.y := R2.Top - R1.Top;
                Break;
              end;
            end;

            InternalH2 := GetWindow(InternalH2, GW_HWNDPREV);
          end;

          Exit;
        end;
      end;

      InternalH1 := GetWindow(InternalH1, GW_HWNDPREV);
    end;
  end;
begin
  if (Form <> nil) and ObjectIsInheritedFromClass(Form, 'TWidgetControl') then
  begin
    ErrorDlg(SCnNonNonVisualNotSupport);
    Exit;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('NonVisualArrange Get DesignInfo %8.8x', [Component.DesignInfo]);
{$ENDIF}

  P := TSmallPoint(Component.DesignInfo);
  // 根据当前组件的位置查找 TContainer 句柄（如果原组件位置重合，可能会误判断）
  if Form = nil then
  begin
    H1 := 0;
    H2 := 0;
  end
  else
    GetComponentContainerHandle(Form, P.x, P.y, H1, H2, Offset);
  Component.DesignInfo := Integer(PointToSmallPoint(Point(X, Y)));

{$IFDEF DEBUG}
  CnDebugger.LogFmt('NonVisualArrange SetDesignInfo %8.8x. Get Handles H1 %d, H2 %d',
    [Component.DesignInfo, H1, H2]);
{$ENDIF}

  // 设置组件窗体位置
  if H1 <> 0 then
    SetWindowPos(H1, 0, X, Y, 0, 0, SWP_NOSIZE or SWP_NOZORDER);

  // 如果有组件标题，设置标题位置
  if H2 <> 0 then
    SetWindowPos(H2, 0, X + Offset.x, Y + Offset.y, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

//------------------------------------------------------------------------------
// 显示浮动工具面板
//------------------------------------------------------------------------------

procedure TCnDesignWizard.ShowFlatForm;
var
  Wizard: TCnIDEEnhanceWizard;
begin
  Wizard := TCnIDEEnhanceWizard(CnWizardMgr.WizardByClassName('TCnFormEnhanceWizard'));
  if Wizard <> nil then
    Wizard.Config;
end;

//------------------------------------------------------------------------------
// 专家调用方法
//------------------------------------------------------------------------------

procedure TCnDesignWizard.AcquireSubActions;
var
  Style: TCnAlignSizeStyle;

  function GetDefShortCut(AStyle: TCnAlignSizeStyle): TShortCut;
  begin
    if AStyle = asCopyCompName then
      Result := ShortCut(Ord('N'), [ssCtrl, ssAlt])
{$IFNDEF BDS}
    else if AStyle = asListComp then
      Result := ShortCut(Ord('F'), [ssCtrl, ssShift])
{$ENDIF}
    else
      Result := 0;
  end;
begin
  for Style := Low(TCnAlignSizeStyle) to High(TCnAlignSizeStyle) do
  begin
    Indexes[Style] := RegisterASubAction(csAlignSizeNames[Style],
      csAlignSizeCaptions[Style]^, GetDefShortCut(Style), csAlignSizeHints[Style]^,
      csAlignSizeNames[Style]);
    SubActions[Indexes[Style]].Category := SCnWizAlignSizeCategory;
    if Style in csAlignNeedSepMenu then
      AddSepMenu;
  end;
end;

// 子菜单执行过程
procedure TCnDesignWizard.SubActionExecute(Index: Integer);
var
  Style: TCnAlignSizeStyle;
begin
  if not Active then Exit;

  for Style := Low(TCnAlignSizeStyle) to High(TCnAlignSizeStyle) do
    if Indexes[Style] = Index then
    begin
      DoAlignSize(Style);
      Break;
    end;
end;

// Action 状态更新
procedure TCnDesignWizard.SubActionUpdate(Index: Integer);
var
  CtrlCount, CompCount: Integer;
  Style: TCnAlignSizeStyle;
  Actn: TCnWizMenuAction;
begin
  if not Active or not CurrentIsForm then
  begin
    SubActions[Index].Enabled := False;
    Exit;
  end;

  FUpdateControlList.Clear;
  try
    try
      CnOtaGetSelectedControlFromCurrentForm(FUpdateControlList);
      CtrlCount := FUpdateControlList.Count;
    except
      ; // Maybe XE4 FMX Style will cause AV here. Catch it
      CtrlCount := 0;
    end;
  finally
    FUpdateControlList.Clear;
  end;

  FUpdateCompList.Clear;
  try
    try
      GetNonVisualSelComponentsFromCurrentForm(FUpdateCompList);
      CompCount := FUpdateCompList.Count;
    except
      ; // Maybe XE4 FMX Style will cause AV here. Catch it
      CompCount := 0;
    end;
  finally
    FUpdateCompList.Clear;
  end;

  Actn := SubActions[Index];
  for Style := Low(TCnAlignSizeStyle) to High(TCnAlignSizeStyle) do
  begin
    if Indexes[Style] = Index then
    begin
      Actn.Visible := Active;
      if Style in csAlignSupportsNonVisual then // 支持控件和不可视组件的，要求选择的至少有一类足够多
      begin
        if csAlignNeedControls[Style] >= 0 then
          Actn.Enabled := Menu.Enabled and ((CompCount >= csAlignNeedControls[Style])
            or (CtrlCount >= csAlignNeedControls[Style]));
      end
      else
      begin
        if csAlignNeedControls[Style] >= 0 then
          Actn.Enabled := Menu.Enabled and (CtrlCount >= csAlignNeedControls[Style]);
      end;
      Break;
    end;
  end;

  if Index = Indexes[asSnapToGrid] then
    Actn.Checked := CnOtaGetEnvironmentOptions.GetOptionValue(SOptionSnapToGrid)
  {$IFDEF IDE_HAS_GUIDE_LINE}
  else if Index = Indexes[asUseGuidelines] then
    Actn.Checked := CnOtaGetEnvironmentOptions.GetOptionValue(SOptionUseGuidelines)
  {$ENDIF}   
  else if Index = Indexes[asSelectRoot] then
    Actn.Enabled := not CnOtaSelectedComponentIsRoot
  else if Index = Indexes[asLockControls] then
  begin
    if Assigned(FIDELockControlsMenu) then
    begin
      Actn.Enabled := True;
      Actn.Checked := FIDELockControlsMenu.Checked;
    end
    else
      Actn.Enabled := False;
  end
  else if Index = Indexes[asHideComponent] then
  begin
    Actn.Enabled := True;
    if Assigned(FIDEHideNonvisualsMenu) then
    begin
      Actn.Checked := (Length(FIDEHideNonvisualsMenu.Caption) > 1) and (FIDEHideNonvisualsMenu.Caption[1] = 'S');
      // 此菜单项无 Checked 状态，判断文字是 Show 还是 Hide。 
    end
    else
      Actn.Checked := FHideNonVisual;
  end
  else if (Index = Indexes[asCopyCompName]) or (Index = Indexes[asCopyCompClass]) or
    (Index = Indexes[asChangeCompClass]) then
  begin
    Actn.Enabled := not CnOtaIsCurrFormSelectionsEmpty;
  end
  else if Index = Indexes[asShowFlatForm] then
  begin
    Actn.Enabled := (CnWizardMgr.WizardByClassName('TCnFormEnhanceWizard') <> nil)
      and not IdeIsEmbeddedDesigner;
  end;
end;

//------------------------------------------------------------------------------
// 专家参数设置方法
//------------------------------------------------------------------------------

// 显示配置窗口
procedure TCnDesignWizard.Config;
begin
  if ShowShortCutDialog('CnAlignSizeConfig') then
    DoSaveSettings;
end;

// 装载专家设置
procedure TCnDesignWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FNonArrangeStyle := TNonArrangeStyle(Ini.ReadInteger('', csNonArrangeStyle, Ord(asRow)));
  FNonMoveStyle := TNonMoveStyle(Ini.ReadInteger('', csNonMoveStyle, Ord(msLeftTop)));
  FRowSpace := Ini.ReadInteger('', csRowSpace, csDefRowColSpace);
  FColSpace := Ini.ReadInteger('', csColSpace, csDefRowColSpace);
  FPerRowCount := Ini.ReadInteger('', csPerRowCount, csDefPerRowCount);
  FPerColCount := Ini.ReadInteger('', csPerColCount, csDefPerColCount);
  FSortByClassName := Ini.ReadBool('', csSortByClassName, True);
  FSizeSpace := Ini.ReadInteger('', csSizeSpace, csDefSizeSpace);

  FPropertyCompare.LoadSettings(Ini);
end;

// 保存专家设置
procedure TCnDesignWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteInteger('', csNonArrangeStyle, Ord(FNonArrangeStyle));
  Ini.WriteInteger('', csNonMoveStyle, Ord(FNonMoveStyle));
  Ini.WriteInteger('', csRowSpace, FRowSpace);
  Ini.WriteInteger('', csColSpace, FColSpace);
  Ini.WriteInteger('', csPerRowCount, FPerRowCount);
  Ini.WriteInteger('', csPerColCount, FPerColCount);
  Ini.WriteBool('', csSortByClassName, FSortByClassName);
  Ini.WriteInteger('', csSizeSpace, FSizeSpace);

  FPropertyCompare.SaveSettings(Ini);
end;

// 取专家菜单标题
function TCnDesignWizard.GetCaption: string;
begin
  Result := SCnDesignWizardMenuCaption;
end;

// 取专家是否有设置窗口
function TCnDesignWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

// 取专家按钮提示
function TCnDesignWizard.GetHint: string;
begin
  Result := SCnDesignWizardMenuHint;
end;

// 返回专家状态
function TCnDesignWizard.GetState: TWizardState;
begin
  if Active and CurrentIsForm then
    Result := [wsEnabled] // 当前编辑的文件是窗体时才启用
  else
    Result := [];
end;

// 返回专家信息
class procedure TCnDesignWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnDesignWizardName;
  Author := SCnPack_Wyb_star + ';' + SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';'
    + SCnPack_Licwing;
  Email := SCnPack_Wyb_starMail + ';' + SCnPack_ZjyEmail + ';'
    + SCnPack_LiuXiaoEmail + ';' + SCnPack_LicwingEmail;
  Comment := SCnDesignWizardComment;
end;

function TCnDesignWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent;
  Result := Result + '窗体,设计,对齐,排列,组件,浮动工具面板,缩放,尺寸,栅格,水平,垂直,高度,宽度,' +
    'form,design,align,arrange,component,control,flat,float,toolbar,enlarge,size,grid,' +
    'horizontal,vertical,height,width,';
end;

{$IFDEF IDE_ACTION_UPDATE_DELAY}

procedure TCnDesignWizard.CheckMenuBarReady(Sender: TObject);
var
  Comp: TComponent;
  I: Integer;
begin
  if (FIDEMenuBar <> nil) and (FEditMenuActionControl <> nil) then
    Exit;

  Comp := Application.MainForm.FindComponent(SIDEMenuBar);
  if (Comp <> nil) and (Comp is TCustomActionMenuBar) then
  begin
    FIDEMenuBar := Comp as TCustomActionMenuBar;
    for I := 0 to FIDEMenuBar.ComponentCount - 1 do
    begin
      Comp := FIDEMenuBar.Components[I];
      if (Comp is TCustomActionControl) and ((Comp as TCustomActionControl).Caption = SEditMenuCaption) then
      begin
        FEditMenuActionControl := Comp as TCustomActionControl;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnDesignWizard EditMenuActionControl Got.');
{$ENDIF}
        Break;
      end;
    end;
  end;
end;

{$ENDIF}

procedure TCnDesignWizard.CheckMenuItemReady(Sender: TObject);
begin
  if FIDELockControlsMenu = nil then
    FIDELockControlsMenu := TMenuItem(Application.MainForm.FindComponent(SIDELockControlsMenuName));

  // Maybe nil under XE8 or below.
  if FIDEHideNonvisualsMenu = nil then
    FIDEHideNonvisualsMenu := TMenuItem(Application.MainForm.FindComponent(SIDEHideNonvisualsMenuName));
end;


procedure TCnDesignWizard.RequestLockControlsMenuUpdate(Sender: TObject);
begin
{$IFDEF IDE_ACTION_UPDATE_DELAY}
  CheckMenuBarReady(nil);

  if (FIDEMenuBar <> nil) and (FEditMenuActionControl <> nil) then
  begin
    if Assigned(FIDEMenuBar.OnPopup) then
    begin
      FIDEMenuBar.OnPopup(FIDEMenuBar, FEditMenuActionControl);
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(FIDELockControlsMenu.Checked,
        'TCnDesignWizard RequestLockControlsMenuUpdate Call MenuBar.OnPopup. IDELockControlsMenu.Checked');
{$ENDIF}
    end;
  end;
{$ENDIF}
end;

procedure TCnDesignWizard.RequestNonvisualsMenuUpdate(Sender: TObject);
begin
{$IFDEF IDE_ACTION_UPDATE_DELAY}
  CheckMenuBarReady(nil);

  if (FIDEMenuBar <> nil) and (FEditMenuActionControl <> nil) then
  begin
    if Assigned(FIDEMenuBar.OnPopup) then
    begin
      FIDEMenuBar.OnPopup(FIDEMenuBar, FEditMenuActionControl);
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(FIDEHideNonvisualsMenu.Checked,
        'TCnDesignWizard RequestNonvisualsMenuUpdate Call MenuBar.OnPopup. IDEToggleNonvisualsMenu.Checked');
{$ENDIF}
    end;
  end;
{$ENDIF}
end;

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}

procedure TCnDesignWizard.ScriptExecute(Sender: TObject);
var
  Idx: Integer;
  SW: TCnScriptWizard;
  AEvent: TCnScriptDesignerContextMenu;
begin
  Idx := -1;
  if Sender is TCnContextMenuExecutor then
    Idx := (Sender as TCnContextMenuExecutor).Tag;

  SW := CnWizardMgr.WizardByClassName('TCnScriptWizard') as TCnScriptWizard;
  if (SW <> nil) and (Idx >= 0) then
  begin
    AEvent := TCnScriptDesignerContextMenu.Create;
    try
      SW.ExecuteScriptByIndex(Idx, AEvent);
    finally
      AEvent.Free;
    end;
  end;
end;

procedure TCnDesignWizard.SyncScriptsDesignMenus;
var
  I: Integer;
  Ext: TCnContextMenuExecutor;
  SW: TCnScriptWizard;
begin
  // 根据 Scripts 里的内容创建 FScriptsDesignExecutors 并挨个注册
  for I := 0 to FScriptsDesignExecutors.Count - 1 do
    UnRegisterDesignMenuExecutor(TCnContextMenuExecutor(FScriptsDesignExecutors[I]));
  FScriptsDesignExecutors.Clear;

  SW := CnWizardMgr.WizardByClassName('TCnScriptWizard') as TCnScriptWizard;
  if SW <> nil then
  begin
    for I := 0 to SW.Scripts.Count - 1 do
    begin
      if smDesignerContextMenu in SW.Scripts[I].Mode then
      begin
        Ext := TCnContextMenuExecutor.Create;
        Ext.Caption := SW.Scripts[I].Name;
        Ext.Active := SW.Scripts[I].Enabled;
        Ext.Tag := I;
        Ext.OnExecute := ScriptExecute;

        RegisterDesignMenuExecutor(Ext);
        FScriptsDesignExecutors.Add(Ext); // 保存一个引用供清除时用
      end;
    end;
  end;
end;

{$ENDIF}
{$ENDIF}

procedure TCnDesignWizard.Loaded;
begin
  inherited;
  CnWizNotifierServices.ExecuteOnApplicationIdle(CheckMenuItemReady);
end;

procedure TCnDesignWizard.LaterLoaded;
begin
  inherited;
  CnWizNotifierServices.ExecuteOnApplicationIdle(CheckMenuItemReady); // 如果开始没找到，这儿再找一次
{$IFDEF IDE_ACTION_UPDATE_DELAY}
  CnWizNotifierServices.ExecuteOnApplicationIdle(CheckMenuBarReady);
{$ENDIF}
end;

procedure TCnDesignWizard.ChangeComponentClass;
var
  I, J, K: Integer;
  ChComps: TInterfaceList;
  ChComp, OldComp, NewComp: TComponent;
  ChClass, NewClass, PropName, NewName: string;
  FormEditor: IOTAFormEditor;
  OldIComp, NewIComp: IOTAComponent;
  Pnt: TSmallPoint;
  PropValue: array[0..127] of Byte;
  StrValue: string;
  PropKind: TTypeKind;
  Par: TWinControl;
  OldCtrl, NewCtrl: TControl;
  OldWCtl, NewWCtl: TWinControl;
begin
  ChComps := TInterfaceList.Create;

  try
    FormEditor := CnOtaGetCurrentFormEditor;
    if FormEditor = nil then
    begin
      ErrorDlg(SCnChangeCompClassErrorNoSelection);
      Exit;
    end;

    if not CnOtaGetSelectedComponentFromCurrentForm(ChComps) then
    begin
      ErrorDlg(SCnChangeCompClassErrorNoSelection);
      Exit;
    end;

    ChComp := TComponent((ChComps[0] as IOTAComponent).GetComponentHandle);
    ChClass := ChComp.ClassName;

    // 检查所选组件类名是否一致
    for I := 1 to ChComps.Count - 1 do
    begin
      ChComp := TComponent((ChComps[I] as IOTAComponent).GetComponentHandle);
      if not ChComp.ClassNameIs(ChClass) then
      begin
        ErrorDlg(SCnChangeCompClassErrorDiffType);
        Exit;
      end;
    end;

    // 输入新类名
    NewClass := ChClass;
    if not CnWizInputQuery(SCnInformation, SCnChangeCompClassNewHint, NewClass) then
      Exit;

    if (NewClass = '') or (NewClass = ChClass) then
    begin
      ErrorDlg(SCnChangeCompClassErrorNew);
      Exit;
    end;

    // 开始循环替换组件
    for I := 0 to ChComps.Count - 1 do
    begin
      OldIComp := ChComps[I] as IOTAComponent;
      OldComp := TComponent(OldIComp.GetComponentHandle);
      Pnt := TSmallPoint(OldComp.DesignInfo);

{$IFDEF SUPPORT_FMX}
      // FMX 下的可视化组件不用 DesignInfo 存，要拿其 Position 属性
      if (Pnt.x = 0) and (Pnt.y = 0) then
        Pnt := CnFmxGetControlPosition(OldComp);
{$ENDIF}

{$IFDEF DEBUG}
      CnDebugger.LogFmt('# %d. Old Component %s Position %d, %d.',
         [I, OldComp.ClassName, Pnt.x, Pnt.y]);
{$ENDIF}

      // 找到个旧的，建一个新的
      NewIComp := FormEditor.CreateComponent(OldIComp.GetParent, NewClass, Pnt.x, Pnt.y, 10, 10);
      if NewIComp <> nil then
      begin
        NewComp := TComponent(NewIComp.GetComponentHandle);

        // 并遍历其属性、事件
        for J := 0 to OldIComp.GetPropCount - 1 do
        begin
          PropName := OldIComp.GetPropName(J);
          if PropName = 'Name' then
            Continue;

          // 挨个给属性赋值，无同名属性则出错继续
          PropKind := OldIComp.GetPropType(J);
          if PropKind in [tkString, tkLString, tkWString {$IFDEF UNICODE}, tkUString {$ENDIF}] then
          begin
            OldIComp.GetPropValueByName(PropName, StrValue);
            NewIComp.SetPropByName(PropName, StrValue);
          end
          else
          begin
            try
              OldIComp.GetPropValueByName(PropName, PropValue[0]); // 对 string 类型会出问题，需额外处理
              NewIComp.SetPropByName(PropName, PropValue[0]);
            except
              ;
            end;
          end;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('# %d. Transfer Property %s.', [J, PropName]);
{$ENDIF}
        end;

        // 同步 Parent
        if OldIComp.IsTControl and NewIComp.IsTControl then
        begin
          OldCtrl := TControl(OldComp);
          NewCtrl := TControl(NewComp);

          try
            Par := TControl(OldComp).Parent;
            TControl(NewComp).Parent := Par;
          except
            ;
          end;

          // 改换子 Controls
          if (OldCtrl is TWinControl) and (NewCtrl is TWinControl) then
          begin
            OldWCtl := TWinControl(OldCtrl);
            NewWCtl := TWinControl(NewCtrl);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('To Move %d Controls.', [OldWCtl.ControlCount]);
{$ENDIF}
            for K := 0 to OldWCtl.ControlCount - 1 do
              OldWCtl.Controls[0].Parent := NewWCtl;
          end;
        end;

{$IFDEF SUPPORT_FMX}
        CnFmxMoveSubControl(OldComp, NewComp);
{$ENDIF}

        // 删除旧组件，给新组件换同样的名字
        NewName := OldComp.Name;
        if OldIComp.Delete then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('# %d. OldComponent Deleted.', [I]);
{$ENDIF}
        end;

        NewIComp.SetPropByName('Name', NewName);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('# %d. Set New Component Name to %s.', [I, NewName]);
{$ENDIF}
      end // 一个组件的所有属性替换完成
      else
      begin
        ErrorDlg(Format(SCnChangeCompClassErrorCreateFmt, [NewClass]));
        Exit;
      end;
    end; // 所有选择组件的替换完成

    // TODO: 通知设计器重画，高版本可不用
    CnOtaNotifyFormDesignerModified(FormEditor);
  finally
    ChComps.Free;
  end;
end;

//==============================================================================
// 不可视组件排列窗体
//==============================================================================

{ TCnNonArrangeForm }

procedure TCnNonArrangeForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if ModalResult <> mrOK then
    Exit;

  if (sePerRow.Value <= 0) or
    (sePerCol.Value <= 0) then
  begin
    ErrorDlg(SCnMustGreaterThanZero);
    CanClose := False;
  end;
end;

procedure TCnNonArrangeForm.UpdateControls(Sender: TObject);
begin
  sePerRow.Enabled := rbRow.Checked;
  sePerCol.Enabled := rbCol.Checked;
  Label1.Enabled := rbRow.Checked;
  Label2.Enabled := rbCol.Checked;

  seSizeSpace.Enabled := cbbMoveStyle.Enabled and
    (cbbMoveStyle.ItemIndex <> Ord(msCenter));
end;

procedure TCnNonArrangeForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnNonArrangeForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

{$IFDEF IDE_SUPPORT_THEMING}

procedure CnAfterLoadIcon(ABigIcon: TIcon; ASmallIcon: TIcon; const IconName: string);
var
  AStyle: TCnAlignSizeStyle;
  SmallBmp: TBitmap;
  X, Y: Integer;
  P: PRGBArray;
  Rep: Boolean;

  function CheckAndReplaceColor(Pixel: PRGBColor): Boolean;
  begin
    Result := False;
    if Pixel <> nil then
    begin
      if (Pixel^.r = 8) and (Pixel^.g in [65, 66]) and (Pixel^.b = 82) then
      begin
        Pixel^.r := 222;
        Pixel^.g := 233;
        Pixel^.b := 0;
        Result := True;
      end
      else if (Pixel^.r = 0) and (Pixel^.g = 0) and (Pixel^.b = 128) then
      begin
        Pixel^.r := 0;
        Pixel^.g := 233;
        Pixel^.b := 60;
        Result := True;
      end
      else if (Pixel^.r = 74) and (Pixel^.g = 73) and (Pixel^.b = 74) then
      begin
        Pixel^.r := 192;
        Pixel^.g := 192;
        Pixel^.b := 192;
        Result := True;
      end;
    end;
  end;

begin
  for AStyle := Low(TCnAlignSizeStyle) to High(TCnAlignSizeStyle) do
  begin
    if csAlignSizeNames[AStyle] = IconName then
    begin
      if (ASmallIcon <> nil) and not ASmallIcon.Empty then
      begin
        SmallBmp := CreateEmptyBmp24(ASmallIcon.Width, ASmallIcon.Height, clBtnFace);
        try
          SmallBmp.Canvas.Draw(0, 0, ASmallIcon);
          Rep := False;
          for Y := 0 to SmallBmp.Height - 1 do
          begin
            P := SmallBmp.ScanLine[Y];
            for X := 0 to SmallBmp.Width - 1 do
            begin
              // 把指定暗色替换成亮色
              if CheckAndReplaceColor(@(P^[X])) then
                Rep := True;
            end;
          end;

          // 替换完毕后写回 Icon 去
          if Rep then
            DrawBmpToIcon(SmallBmp, ASmallIcon);
{$IFDEF DEBUG}
          CnDebugger.LogBoolean(Rep, 'CnAfterLoadIcon Small Icon');
{$ENDIF}
        finally
          SmallBmp.Free;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}
{$IFDEF SUPPORT_PASCAL_SCRIPT}

{ TCnDesignScriptSettingChangedReceiver }

constructor TCnDesignScriptSettingChangedReceiver.Create(
  AWizard: TCnDesignWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

destructor TCnDesignScriptSettingChangedReceiver.Destroy;
begin

  inherited;
end;

procedure TCnDesignScriptSettingChangedReceiver.OnEvent(Event: TCnEvent);
begin
  if FWizard <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('AlignSizeWizard Design Got Script Setting Changed.');
{$ENDIF}
    FWizard.SyncScriptsDesignMenus;
  end;
end;

{$ENDIF}
{$ENDIF}

initialization
  RegisterCnWizard(TCnDesignWizard); // 注册专家

{$IFDEF IDE_SUPPORT_THEMING}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnLoadIconProc To get Active Theme');
  CnDebugger.LogMsg('CnLoadIconProc get Active Theme: ' + CnOtaGetActiveThemeName);
{$ENDIF}
  // if CnOtaGetActiveThemeName = 'Dark' then // 暗黑主题下注册图标处理事件，不支持动态切换主题
  //  CnLoadIconProc := CnAfterLoadIcon;      // 效果不佳，暂时禁用
{$ENDIF}

{$ENDIF CNWIZARDS_CNDESIGNWIZARD}
end.


