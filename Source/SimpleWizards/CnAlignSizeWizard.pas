{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnAlignSizeWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：控件对齐专家单元
* 单元作者：王玉宝（Wyb_star） Wyb_star@sina.com
*           周劲羽 (zjy@cnpack.org)
*           刘啸 (liuxiao@cnpack.org)
*           朱磊（Licwing Zue）licwing@chinasystemsn.com
* 备    注：控件对齐专家单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnAlignSizeWizard.pas,v 1.38 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2004.12.04 by 周劲羽
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

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
  Windows, SysUtils, Messages, Classes, Forms, IniFiles, ToolsAPI, Controls,
  Dialogs, Math, ActnList,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Buttons, Menus, CnWizClasses, CnWizMenuAction, CnWizUtils, 
  CnConsts, CnWizNotifier, CnWizConsts, CnWizManager,
  StdCtrls, CnSpin, CnWizIdeUtils, CnCommon, CnWizMultiLang;

type

//==============================================================================
// Align Size 设置工具
//==============================================================================

{ TCnAlignSizeWizard }

  TAlignSizeStyle = (
    asAlignLeft, asAlignRight, asAlignTop, asAlignBottom,
    asAlignHCenter, asAlignVCenter,
    asSpaceEquH, asSpaceEquHX, asSpaceIncH, asSpaceDecH, asSpaceRemoveH,
    asSpaceEquV, asSpaceEquVY, asSpaceIncV, asSpaceDecV, asSpaceRemoveV,
    asIncWidth, asDecWidth, asIncHeight, asDecHeight,
    asMakeMinWidth, asMakeMaxWidth, asMakeSameWidth,
    asMakeMinHeight, asMakeMaxHeight, asMakeSameHeight, asMakeSameSize,
    asParentHCenter, asParentVCenter, asBringToFront, asSendToBack,
    asSnapToGrid, {$IFDEF DELPHI10_UP} asUseGuidelines, {$ENDIF} asAlignToGrid,
    asSizeToGrid, asLockControls, asSelectRoot, asCopyCompName, asHideComponent,
    asNonArrange, asListComp, asCompToCode, asShowFlatForm);

  TNonArrangeStyle = (asRow, asCol);
  TNonMoveStyle = (msLeftTop, msRightTop, msLeftBottom, msRightBottom, msCenter);

  TCnAlignSizeWizard = class(TCnSubMenuWizard)
  private
    Indexes: array[TAlignSizeStyle] of Integer;
    FHideNonVisual: Boolean;
    FNonArrangeStyle: TNonArrangeStyle;
    FNonMoveStyle: TNonMoveStyle;
    FRowSpace, FColSpace: Integer;
    FPerRowCount, FPerColCount: Integer;
    FSortByClassName: Boolean;
    FSizeSpace: Integer;
    FIDELockControlsMenu: TMenuItem;

    procedure ControlListSortByPos(List: TList; IsVert: Boolean;
      Desc: Boolean = False);
    procedure ControlListSortByProp(List: TList; ProName: string;
      Desc: Boolean = False);
    procedure DoAlignSize(AlignSizeStyle: TAlignSizeStyle);

    function UpdateNonVisualComponent(FormEditor: IOTAFormEditor): Boolean;
    procedure HideNonVisualComponent;

    procedure ShowFlatForm;
    procedure NonVisualArrange;
    procedure ArrangeNonVisualComponents;
    procedure FormEditorNotifier(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);

    function GetNonVisualComponentsFromCurrentForm(List: TList): Boolean;
    function GetNonVisualSelComponentsFromCurrentForm(
      List: TList): Boolean;
    procedure SetNonVisualPos(Form: TCustomForm; Component: TComponent;
      X, Y: Integer);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AcquireSubActions; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;

    property HideNonVisual: Boolean read FHideNonVisual;
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
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  TypInfo, CnFormEnhancements, CnListCompFrm, CnCompToCodeFrm;

{$R *.dfm}

resourcestring
  SOptionDisplayGrid = 'DisplayGrid';
  SOptionShowComponentCaptions = 'ShowComponentCaptions';
  SOptionSnapToGrid = 'SnapToGrid';
  SOptionUseGuidelines = 'UseDesignerGuidelines';
  SOptionGridSizeX = 'GridSizeX';
  SOptionGridSizeY = 'GridSizeY';
  SIDELockControlsMenuName = 'EditLockControlsItem';

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
  csNonVisualCaptionSize = 14;
  csNonVisualCaptionV = 30;

  csSpaceIncStep = 1;

  // Action 生效需要选择的最小控件数
  csAlignNeedControls: array[TAlignSizeStyle] of Integer = (2, 2, 2, 2, 2, 2,
    3, 2, 2, 2, 2, 3, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0,
    {$IFDEF DELPHI10_UP} 0, {$ENDIF} 1, 1, -1, -1, -1, 0, 0, 0, 0, -1);

  csAlignNeedSepMenu: set of TAlignSizeStyle =
    [asAlignVCenter, asSpaceRemoveV, asMakeSameSize, asParentVCenter,
    asSendToBack, asLockControls, asCompToCode];

  csAlignSizeNames: array[TAlignSizeStyle] of string = (
    'CnAlignLeft', 'CnAlignRight', 'CnAlignTop', 'CnAlignBottom', 'CnAlignHCenter',
    'CnAlignVCenter', 'CnSpaceEquH', 'CnSpaceEquHX', 'CnSpaceIncH', 'CnSpaceDecH', 'CnSpaceRemoveH',
    'CnSpaceEquV', 'CnSpaceEquVY', 'CnSpaceIncV', 'CnSpaceDecV', 'CnSpaceRemoveV',
    'CnIncWidth', 'CnDecWidth', 'CnIncHeight', 'CnDecHeight',
    'CnMakeMinWidth', 'CnMakeMaxWidth', 'CnMakeSameWidth', 'CnMakeMinHeight',
    'CnMakeMaxHeight', 'CnMakeSameHeight', 'CnMakeSameSize', 'CnParentHCenter',
    'CnParentVCenter', 'CnBringToFront', 'CnSendToBack', 'CnSnapToGrid',
    {$IFDEF DELPHI10_UP} 'CnUseGuidelines', {$ENDIF}
    'CnAlignToGrid', 'CnSizeToGrid', 'CnLockControls', 'CnSelectRoot',
    'CnCopyCompName', 'CnHideComponent', 'CnNonArrange', 'CnListComp',
    'CnCompToCode', 'CnShowFlatForm');

  csAlignSizeCaptions: array[TAlignSizeStyle] of PString = (
    @SCnAlignLeftCaption, @SCnAlignRightCaption, @SCnAlignTopCaption,
    @SCnAlignBottomCaption, @SCnAlignHCenterCaption, @SCnAlignVCenterCaption,
    @SCnSpaceEquHCaption, @SCnSpaceEquHXCaption, @SCnSpaceIncHCaption, @SCnSpaceDecHCaption, @SCnSpaceRemoveHCaption,
    @SCnSpaceEquVCaption, @SCnSpaceEquVYCaption, @SCnSpaceIncVCaption, @SCnSpaceDecVCaption, @SCnSpaceRemoveVCaption,
    @SCnIncWidthCaption, @SCnDecWidthCaption, @SCnIncHeightCaption, @SCnDecHeightCaption,
    @SCnMakeMinWidthCaption, @SCnMakeMaxWidthCaption, @SCnMakeSameWidthCaption,
    @SCnMakeMinHeightCaption, @SCnMakeMaxHeightCaption, @SCnMakeSameHeightCaption,
    @SCnMakeSameSizeCaption, @SCnParentHCenterCaption, @SCnParentVCenterCaption,
    @SCnBringToFrontCaption, @SCnSendToBackCaption, @SCnSnapToGridCaption,
    {$IFDEF DELPHI10_UP} @SCnUseGuidelinesCaption, {$ENDIF}
    @SCnAlignToGridCaption, @SCnSizeToGridCaption, @SCnLockControlsCaption,
    @SCnSelectRootCaption, @SCnCopyCompNameCaption, @SCnHideComponentCaption,
    @SCnNonArrangeCaption, @SCnListCompCaption, @SCnCompToCodeCaption, @SCnShowFlatFormCaption);

  csAlignSizeHints: array[TAlignSizeStyle] of PString = (
    @SCnAlignLeftHint, @SCnAlignRightHint, @SCnAlignTopHint,
    @SCnAlignBottomHint, @SCnAlignHCenterHint, @SCnAlignVCenterHint,
    @SCnSpaceEquHHint, @SCnSpaceEquHXHint, @SCnSpaceIncHHint, @SCnSpaceDecHHint, @SCnSpaceRemoveHHint,
    @SCnSpaceEquVHint, @SCnSpaceEquVYHint, @SCnSpaceIncVHint, @SCnSpaceDecVHint, @SCnSpaceRemoveVHint,
    @SCnIncWidthHint, @SCnDecWidthHint, @SCnIncHeightHint, @SCnDecHeightHint,
    @SCnMakeMinWidthHint, @SCnMakeMaxWidthHint, @SCnMakeSameWidthHint,
    @SCnMakeMinHeightHint, @SCnMakeMaxHeightHint, @SCnMakeSameHeightHint,
    @SCnMakeSameSizeHint, @SCnParentHCenterHint, @SCnParentVCenterHint,
    @SCnBringToFrontHint, @SCnSendToBackHint, @SCnSnapToGridHint,
    {$IFDEF DELPHI10_UP} @SCnUseGuidelinesHint, {$ENDIF}
    @SCnAlignToGridHint, @SCnSizeToGridHint, @SCnLockControlsHint,
    @SCnSelectRootHint, @SCnCopyCompNameHint, @SCnHideComponentHint,
    @SCnNonArrangeHint, @SCnListCompHint, @SCnCompToCodeHint, @SCnShowFlatFormHint);

//==============================================================================
// Align Size 设置工具
//==============================================================================

{ TCnAlignSizeWizard }

constructor TCnAlignSizeWizard.Create;
begin
  inherited;
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorNotifier);
  FIDELockControlsMenu := TMenuItem(Application.MainForm.FindComponent(SIDELockControlsMenuName));
end;

destructor TCnAlignSizeWizard.Destroy;
begin
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorNotifier);
  inherited;
end;

//------------------------------------------------------------------------------
// 组件对齐缩放处理
//------------------------------------------------------------------------------

var
  _ProName: string;
  _Desc: Boolean;
  _IsVert: Boolean;

function DoSortByProp(Item1, Item2: Pointer): Integer;
var
  V1, V2: Integer;
begin
  V1 := GetOrdProp(TComponent(Item1), _ProName);
  V2 := GetOrdProp(TComponent(Item2), _ProName);
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

procedure TCnAlignSizeWizard.ControlListSortByProp(List: TList; ProName: string;
  Desc: Boolean);
begin
  _ProName := ProName;
  _Desc := Desc;
  List.Sort(DoSortByProp);
end;

procedure TCnAlignSizeWizard.ControlListSortByPos(List: TList; IsVert: Boolean;
  Desc: Boolean = False);
begin
  _IsVert := IsVert;
  _Desc := Desc;
  List.Sort(DoSortByPos);
end;

procedure TCnAlignSizeWizard.DoAlignSize(AlignSizeStyle: TAlignSizeStyle);
var
  I: Integer;
  Count, Value: Integer;
  Curr: Double;
  ControlList: TList;
  AList: TList;
  R1, R2, R3: TRect;
  GridSizeX, GridSizeY: Integer;
  IsModified: Boolean;
  FormEditor: IOTAFormEditor;
  EnvOptions: IOTAEnvironmentOptions;
  S: string;
  Space: Integer;
  KeyState: TKeyboardState;
  EditAction:IOTAEditActions;
  Ini: TCustomIniFile;
begin
  ControlList := TList.Create;
  try
    if (csAlignNeedControls[AlignSizeStyle] > 0) and
      not CnOtaGetSelectedControlFromCurrentForm(ControlList) then Exit;

    IsModified := True;
    case AlignSizeStyle of
      asAlignLeft, asAlignRight, asAlignTop, asAlignBottom,
      asAlignHCenter, asAlignVCenter:
        begin
          R1 := GetControlScreenRect(TControl(ControlList[0]));
          for I := 1 to ControlList.Count - 1 do
          begin
            R2 := GetControlScreenRect(TControl(ControlList[I]));
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
            SetControlScreenRect(TControl(ControlList[I]), R2);
          end;
        end;
      asSpaceEquH, asSpaceEquV:
        begin
          if ControlList.Count < 3 then Exit;
          ControlListSortByPos(ControlList, AlignSizeStyle = asSpaceEquV);

          R1 := GetControlScreenRect(TControl(ControlList[0]));
          R2 := GetControlScreenRect(TControl(ControlList[ControlList.Count - 1]));
          Count := 0;
          for I := 1 to ControlList.Count - 2 do
          begin
            R3 := GetControlScreenRect(TControl(ControlList[I]));
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
            R3 := GetControlScreenRect(TControl(ControlList[I]));
            if AlignSizeStyle = asSpaceEquH then
              OffsetRect(R3, Round(Curr) - R3.Left, 0)
            else
              OffsetRect(R3, 0, Round(Curr) - R3.Top);
            SetControlScreenRect(TControl(ControlList[I]), R3);
            if AlignSizeStyle = asSpaceEquH then
              Curr := Curr + R3.Right - R3.Left
            else
              Curr := Curr + R3.Bottom - R3.Top;
          end;
        end;
      asSpaceEquHX, asSpaceEquVY:
        begin
          if ControlList.Count < 2 then Exit;
          ControlListSortByPos(ControlList, AlignSizeStyle = asSpaceEquVY);

          S := '4';
          if not CnInputQuery(SCnInformation, SCnSpacePrompt, S) then
            Exit;

          if IsInt(S) then
            Space := StrToInt(S)
          else
          begin
            ErrorDlg(SCnMustDigital);
            Exit;
          end;

          // 获得了手工间距，开始排列
          R1 := GetControlScreenRect(TControl(ControlList[0]));
          if AlignSizeStyle = asSpaceEquHX then
            Curr := R1.Right
          else
            Curr := R1.Bottom;

          for I := 1 to ControlList.Count - 1 do
          begin
            Curr := Curr + Space;

            R3 := GetControlScreenRect(TControl(ControlList[I]));
            if AlignSizeStyle = asSpaceEquHX then
              OffsetRect(R3, Round(Curr) - R3.Left, 0)
            else
              OffsetRect(R3, 0, Round(Curr) - R3.Top);
            SetControlScreenRect(TControl(ControlList[I]), R3);

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
          R1 := GetControlScreenRect(TControl(ControlList[0]));
          for I := 1 to ControlList.Count - 1 do
          begin
            R2 := GetControlScreenRect(TControl(ControlList[I]));
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
            SetControlScreenRect(TControl(ControlList[I]), R2);
            R1 := R2;
          end;
        end;
      asIncWidth, asDecWidth, asIncHeight, asDecHeight,
      asAlignToGrid, asSizeToGrid:
       begin
          try
            EnvOptions := CnOtaGetEnvironmentOptions;
            GridSizeX := EnvOptions.GetOptionValue(SOptionGridSizeX);
            GridSizeY := EnvOptions.GetOptionValue(SOptionGridSizeY);
            if (GridSizeX <> 0) and (GridSizeY <> 0) then
              for i := 0 to ControlList.Count - 1 do
                with TControl(ControlList[I]) do
                begin
                  if AlignSizeStyle = asIncWidth then
                    Width := Width + GridSizeX
                  else if AlignSizeStyle = asDecWidth then
                  begin
                    if Width > GridSizeX then
                      Width := Width - GridSizeX;
                  end
                  else if AlignSizeStyle = asIncHeight then
                    Height := Height + GridSizeY
                  else if AlignSizeStyle = asDecHeight then
                  begin
                    if Height > GridSizeY then
                      Height := Height - GridSizeY;
                  end
                  else
                  begin
                    Left := Left - Left mod GridSizeX;
                    Top := Top - Top mod GridSizeY;
                    if AlignSizeStyle = asSizeToGrid then
                    begin
                      Width := Round(Width / GridSizeX) * GridSizeX;
                      Height := Round(Height / GridSizeY) * GridSizeY;
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
            ControlListSortByProp(ControlList, 'Width', AlignSizeStyle = asMakeMaxWidth);
          if AlignSizeStyle in [asMakeMinHeight, asMakeMaxHeight] then
            ControlListSortByProp(ControlList, 'Height', AlignSizeStyle = asMakeMaxHeight);
          for i := 1 to ControlList.Count - 1 do
          begin
            if AlignSizeStyle in [asMakeMinWidth, asMakeMaxWidth,
              asMakeSameWidth, asMakeSameSize] then
              TControl(ControlList[I]).Width := TControl(ControlList[0]).Width;
            if AlignSizeStyle in [asMakeMinHeight, asMakeMaxHeight,
              asMakeSameHeight, asMakeSameSize] then
              TControl(ControlList[I]).Height := TControl(ControlList[0]).Height;
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
              for i := ControlList.Count - 1 downto 0 do
                if TControl(ControlList[I]).Parent = TControl(AList[0]).Parent then
                  AList.Add(ControlList.Extract(ControlList[I]));

              if AlignSizeStyle = asParentHCenter then
              begin
                // 计算控件组的外接宽度
                R1.Left := MaxInt;
                R1.Right := -MaxInt;
                for i := 0 to AList.Count - 1 do
                begin
                  R1.Left := Min(TControl(AList[i]).Left, R1.Left);
                  R1.Right := Max(TControl(AList[i]).Left + TControl(AList[I]).Width, R1.Right);
                end;

                // 要移动的距离
                Value := (TControl(AList[0]).Parent.ClientWidth - R1.Left - R1.Right) div 2;
                for I := 0 to AList.Count - 1 do
                  TControl(AList[I]).Left := TControl(AList[I]).Left + Value;
              end
              else
              begin
                // 计算控件组的外接高度
                R1.Top := MaxInt;
                R1.Bottom := -MaxInt;
                for I := 0 to AList.Count - 1 do
                begin
                  R1.Top := Min(TControl(AList[I]).Top, R1.Top);
                  R1.Bottom := Max(TControl(AList[I]).Top + TControl(AList[I]).Height, R1.Bottom);
                end;

                // 要移动的距离
                Value := (TControl(AList[0]).Parent.ClientHeight - R1.Top - R1.Bottom) div 2;
                for i := 0 to AList.Count - 1 do
                  TControl(AList[I]).Top := TControl(AList[I]).Top + Value;
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
              TControl(ControlList[I]).BringToFront
            else
              TControl(ControlList[I]).SendToBack;
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
      {$IFDEF DELPHI10_UP}
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
            FIDELockControlsMenu.Click;
          IsModified := False;
        end;
      asSelectRoot:
        begin
          CnOtaSetCurrFormSelectRoot;
          IsModified := False;
        end;
      asCopyCompName:
        begin
          CnOtaCopyCurrFormSelectionsName;
          
          GetKeyboardState(KeyState);
          if (KeyState[VK_SHIFT] and $80) = 0 then // 按 Shift 不跳
          begin
            //Switch To Code
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
          //  弹出列表供选择
          Ini := CreateIniFile();
          try
            CnListComponent(Ini);
          finally
            Ini.Free;
          end;
          IsModified := False;
        end;  
      asCompToCode:
        begin
          ShowCompToCodeForm.RefreshCode;
        end;
      asShowFlatForm:
        begin
          ShowFlatForm;
          IsModified := False;
        end;
    end;

    for I := 0 to ControlList.Count - 1 do
      TControl(ControlList[I]).Invalidate;
    
    if IsModified then
    begin
      FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
      if Assigned(FormEditor) then
        FormEditor.MarkModified;
    end;
  finally
    ControlList.Free;
  end;
end;

//------------------------------------------------------------------------------
// 隐藏不可视组件
//------------------------------------------------------------------------------

procedure TCnAlignSizeWizard.HideNonvisualComponent;
begin
  if UpdateNonVisualComponent(CnOtaGetCurrentFormEditor) then
  begin
    FHideNonVisual := not FHideNonvisual;
    SubActions[Indexes[asHideComponent]].Checked := FHideNonVisual;
  end
  else
    ErrorDlg(SCnHideNonVisualNotSupport);
end;

function TCnAlignSizeWizard.UpdateNonVisualComponent(
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
        if Active and HideNonVisual then
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

procedure TCnAlignSizeWizard.FormEditorNotifier(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  if Active and (NotifyType = fetActivated) then
    UpdateNonVisualComponent(FormEditor);
end;

//------------------------------------------------------------------------------
// 排列不可视组件
//------------------------------------------------------------------------------

procedure TCnAlignSizeWizard.NonVisualArrange;
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
end;

procedure TCnAlignSizeWizard.ArrangeNonVisualComponents;
var
  CompList: TList;
  i, Rows, Cols, cRow, cCol: Integer;
  CompPosArray: array of TPoint;
  AForm: TCustomForm;
  AllWidth, AllHeight, OffSetX, OffSetY: Integer;
{$IFDEF COMPILER6_UP}
  FormDesigner: IDesigner;
  AContainer: TComponent;
{$ELSE}
  FormDesigner: IFormDesigner;
{$ENDIF}
begin
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF COMPILER6_UP}
  AForm := nil;
  AContainer := FormDesigner.Root;
{$IFDEF DEBUG}
    CnDebugger.LogComponent(AContainer);
{$ENDIF}
  if (AContainer is TWinControl) or ObjectIsInheritedFromClass(AContainer, 'TWidgetControl') then
    AForm := TCustomForm(AContainer)
  else if (AContainer.Owner <> nil) 
    and AContainer.Owner.ClassNameIs('TDataModuleForm') then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('AContainer Owner is DataModule Form.');
{$ENDIF}
    AForm := AContainer.Owner as TCustomForm;
  end;
{$ELSE}
  AForm := FormDesigner.Form;
{$ENDIF}

  if AForm = nil then
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

    for i := 0 to CompList.Count - 1 do
    begin
      CompPosArray[i].x := (cCol - 1) * (csNonVisualSize + FColSpace);
      CompPosArray[i].y := (cRow - 1) * (csNonVisualSize + FRowSpace);
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

    // 现在的Rows和Cols记录了实际排列的行列数。
    AllWidth := Cols * (csNonVisualSize + FColSpace) - FColSpace;
    AllHeight := Rows * (csNonVisualSize + FRowSpace) - FRowSpace;

    OffSetX := 0; OffSetY := 0;
    case FNonMoveStyle of
      msLeftTop:
        begin
          OffSetX := FSizeSpace;
          OffSetY := FSizeSpace;
        end;
      msRightTop:
        begin
          OffSetX := AForm.ClientWidth - AllWidth - FSizeSpace;
          OffSetY := FSizeSpace;
        end;
      msLeftBottom:
        begin
          OffSetX := FSizeSpace;
          OffSetY := AForm.ClientHeight - AllHeight - FSizeSpace;
        end;
      msRightBottom:
        begin
          OffSetX := AForm.ClientWidth - AllWidth - FSizeSpace;
          OffSetY := AForm.ClientHeight - AllHeight - FSizeSpace;
        end;
      msCenter:
        begin
          OffSetX := (AForm.ClientWidth - AllWidth) div 2;
          OffSetY := (AForm.ClientHeight - AllHeight) div 2
        end;
    end;

    for i := CompList.Count - 1 downto 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('%d. %s: %s, X %d, Y %d.', [ I,
        TComponent(CompList.Items[i]).ClassName,
        TComponent(CompList.Items[i]).Name,
        CompPosArray[i].X + OffSetX,
        CompPosArray[i].Y + OffSetY]);
{$ENDIF}
      SetNonVisualPos(AForm, TComponent(CompList.Items[i]),
        CompPosArray[i].X + OffSetX, CompPosArray[i].Y + OffSetY);
    end;

    FormDesigner.Modified;
  finally
    SetLength(CompPosArray, 0);
    CompList.Free;
  end;
end;

function TCnAlignSizeWizard.GetNonVisualComponentsFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  RootComponent: IOTAComponent;
  IComponent: IOTAComponent;
  Component: TComponent;
  CompList: TStrings;
  i: Integer;
begin
  Result := False;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  RootComponent := FormEditor.GetRootComponent;

  CompList := TStringList.Create;
  try
    GetInstalledComponents(nil, CompList);
    for i := 0 to RootComponent.GetComponentCount - 1 do
    begin
      IComponent := RootComponent.GetComponent(i);
      if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
        (TObject(IComponent.GetComponentHandle) is TComponent) then
      begin
        Component := TObject(IComponent.GetComponentHandle) as TComponent;
        if Assigned(Component) and not (Component is TControl) and
          (CompList.IndexOf(Component.ClassName) >= 0) then
          List.Add(Component);
      end;
    end;
  finally
    CompList.Free;
  end;

  Result := List.Count > 0;
end;

function TCnAlignSizeWizard.GetNonVisualSelComponentsFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  CompList: TStrings;
  i: Integer;
begin
  Result := False;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  CompList := TStringList.Create;
  try
    GetInstalledComponents(nil, CompList);
    for i := 0 to FormEditor.GetSelCount - 1 do
    begin
      IComponent := FormEditor.GetSelComponent(i);
      if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
        (TObject(IComponent.GetComponentHandle) is TComponent) then
      begin
        Component := TObject(IComponent.GetComponentHandle) as TComponent;
        if Assigned(Component) and not (Component is TControl) and
          (CompList.IndexOf(Component.ClassName) >= 0) then
          List.Add(Component);
      end;
    end;
  finally
    CompList.Free;
  end;

  Result := List.Count > 0;
end;

procedure TCnAlignSizeWizard.SetNonVisualPos(Form: TCustomForm;
  Component: TComponent; X, Y: Integer);
var
  P: TSmallPoint;
  H1, H2: HWND;
  Offset: TPoint;

  // 此函数目前已支持 DataModule
  procedure GetComponentContainerHandle(AForm: TCustomForm; L, T: Integer;
    var H1, H2: HWND; var Offset: TPoint);
  var
    R1, R2: TRect;
    P: TPoint;
    ParentHandle: HWND;
    AControl: TWinControl;
    I: Integer;
  begin
    ParentHandle := AForm.Handle;
    AControl := AForm;
{$IFDEF DEBUG}
    CnDebugger.LogComponent(AForm);
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
          if AControl.Controls[I].ClassNameIs('TComponentContainer')
            and (AControl.Controls[I] is TWinControl) then
          begin
            AControl := AControl.Controls[I] as TWinControl;
            ParentHandle := AControl.Handle;
            Break;
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
        if AForm.Controls[I].ClassNameIs('TComponentContainer')
          and (AForm.Controls[I] is TWinControl) then
        begin
          AControl := AForm.Controls[I] as TWinControl;
          ParentHandle := AControl.Handle;
          Break;
        end;
    end;
{$ENDIF}

    H2 := 0;
    H1 := GetWindow(ParentHandle, GW_CHILD);
    H1 := GetWindow(H1, GW_HWNDLAST);

    while H1 <> 0 do
    begin
      if HWndIsNonvisualComponent(H1) and GetWindowRect(H1, R1) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogInteger(H1, 'H1: ');
{$ENDIF}
        P.x := R1.Left;
        P.y := R1.Top;
        P := AControl.ScreenToClient(P);

        // 此处取得组件对应的窗体句柄
        if (P.x = L) and (P.y = T) and (R1.Right - R1.Left = csNonVisualSize) and
          (R1.Bottom - R1.Top = csNonVisualSize) then
        begin
          H2 := GetWindow(ParentHandle, GW_CHILD);
          H2 := GetWindow(H2, GW_HWNDLAST);
          while H2 <> 0 do
          begin
            if HWndIsNonvisualComponent(H2) and GetWindowRect(H2, R2) then
            begin
              // 此处取得组件标题对应的窗体句柄
              if (R2.Top - R1.Top = csNonVisualCaptionV) and
                (Abs(R2.Left + R2.Right - R1.Left - R1.Right) <= 1) and
                (R2.Bottom - R2.Top = csNonVisualCaptionSize) then
              begin
                Offset.x := R2.Left - R1.Left;
                Offset.y := R2.Top - R1.Top;
                Break;
              end;
            end;

            H2 := GetWindow(H2, GW_HWNDPREV);
          end;

          Exit;
        end;
      end;

      H1 := GetWindow(H1, GW_HWNDPREV);
    end;
  end;
begin
  if ObjectIsInheritedFromClass(Form, 'TWidgetControl') then
  begin
    ErrorDlg(SCnNonNonVisualNotSupport);
    Exit;
  end;

  P := TSmallPoint(Component.DesignInfo);
  // 根据当前组件的位置查找 TContainer 句柄（如果原组件位置重合，可能会误判断）
  GetComponentContainerHandle(Form, P.x, P.y, H1, H2, Offset);
  Component.DesignInfo := Integer(PointToSmallPoint(Point(X, Y)));

{$IFDEF DEBUG}
  CnDebugger.LogFmt('H1 %d, H2 %d', [H1, H2]);
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

procedure TCnAlignSizeWizard.ShowFlatForm;
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

procedure TCnAlignSizeWizard.AcquireSubActions;
var
  Style: TAlignSizeStyle;

  function GetDefShortCut(AStyle: TAlignSizeStyle): TShortCut;
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
  for Style := Low(TAlignSizeStyle) to High(TAlignSizeStyle) do
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
procedure TCnAlignSizeWizard.SubActionExecute(Index: Integer);
var
  Style: TAlignSizeStyle;
begin
  if not Active then Exit;

  for Style := Low(TAlignSizeStyle) to High(TAlignSizeStyle) do
    if Indexes[Style] = Index then
    begin
      DoAlignSize(Style);
      Break;
    end;
end;

// Action 状态更新
procedure TCnAlignSizeWizard.SubActionUpdate(Index: Integer);
var
  List: TList;
  Count: Integer;
  Style: TAlignSizeStyle;
  Actn: TCnWizMenuAction;
begin
  if not Active or not CurrentIsForm then
  begin
    SubActions[Index].Enabled := False;
    Exit;
  end;

  List := TList.Create;
  try
    CnOtaGetSelectedControlFromCurrentForm(List);
    Count := List.Count;
  finally
    List.Free;
  end;

  Actn := SubActions[Index];
  for Style := Low(TAlignSizeStyle) to High(TAlignSizeStyle) do
  begin
    if Indexes[Style] = Index then
    begin
      Actn.Visible := Active;
      if csAlignNeedControls[Style] >= 0 then
        Actn.Enabled := Menu.Enabled and (Count >= csAlignNeedControls[Style]);
      Break;
    end;
  end;

  if Index = Indexes[asSnapToGrid] then
    Actn.Checked := CnOtaGetEnvironmentOptions.GetOptionValue(SOptionSnapToGrid)
  {$IFDEF DELPHI10_UP}
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
  else if Index = Indexes[asCopyCompName] then
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

procedure TCnAlignSizeWizard.Config;
begin
  if ShowShortCutDialog('CnAlignSizeConfig') then
    DoSaveSettings;
end;

// 装载专家设置

procedure TCnAlignSizeWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FNonArrangeStyle := TNonArrangeStyle(Ini.ReadInteger('', csNonArrangeStyle, 0));
  FNonMoveStyle := TNonMoveStyle(Ini.ReadInteger('', csNonMoveStyle, 0));
  FRowSpace := Ini.ReadInteger('', csRowSpace, 4);
  FColSpace := Ini.ReadInteger('', csColSpace, 4);
  FPerRowCount := Ini.ReadInteger('', csPerRowCount, 5);
  FPerColCount := Ini.ReadInteger('', csPerColCount, 3);
  FSortByClassName := Ini.ReadBool('', csSortByClassName, True);
  FSizeSpace := Ini.ReadInteger('', csSizeSpace, 16);
end;

// 保存专家设置

procedure TCnAlignSizeWizard.SaveSettings(Ini: TCustomIniFile);
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
end;

// 取专家菜单标题

function TCnAlignSizeWizard.GetCaption: string;
begin
  Result := SCnAlignSizeMenuCaption;
end;

// 取专家是否有设置窗口

function TCnAlignSizeWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

// 取专家按钮提示

function TCnAlignSizeWizard.GetHint: string;
begin
  Result := SCnAlignSizeMenuHint;
end;

// 返回专家状态

function TCnAlignSizeWizard.GetState: TWizardState;
begin
  if Active and CurrentIsForm then
    Result := [wsEnabled] // 当前编辑的文件是窗体时才启用
  else
    Result := [];
end;

// 返回专家信息

class procedure TCnAlignSizeWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnAlignSizeName;
  Author := SCnPack_Wyb_star + ';' + SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';'
    + SCnPack_Licwing;
  Email := SCnPack_Wyb_starMail + ';' + SCnPack_ZjyEmail + ';'
    + SCnPack_LiuXiaoEmail + ';' + SCnPack_LicwingEmail;
  Comment := SCnAlignSizeComment;
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

initialization
  RegisterCnWizard(TCnAlignSizeWizard); // 注册专家

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.

