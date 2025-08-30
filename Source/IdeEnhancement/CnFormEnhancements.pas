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

unit CnFormEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：窗体设计器扩展单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2012.09.19 by shenloqi
*               移植到 Delphi XE3
*           2007.01.11 by 周劲羽
*               不再使用 CnWizControlHook 单元，改用 CallWndProcRet Hook
*               重新实现浮动面板的 Visible 属性，解决某些情况下错误显示的问题
*           2004.12.03 by 周劲羽
*               大量改进，支持多工具栏
*           2004.05.21 by chinbo(shenloqi)
*               修正重设按钮后窗体位置错位的问题
*           2003.10.04 by 何清(QSoft)
*               修正当浮动工具条显示时"Edit"中大部分菜单不可使用问题
*           2003.09.29 by 何清(QSoft)
*               改用 CnWizNotifier 新增的 Application OnIdle 通知服务修正以下 BUG
*           2003.09.28 by 何清(QSoft)
*               修正 D7 下调用 Close All 无法隐藏浮动工具条的问题，通过挂接
*               Application 的 OnIdle 事件来处理该问题，D5下该问题已经被
*               周劲羽兄解决了
*           2003.09.25
*               多语处理完成
*           2003.06.24
*               窗体设计期扩展专家改成专家注册的方式
*           2003.06.07
*               修正屏幕右边及下方的窗体停靠问题
*           2003.05.04
*               修正浮动工具面板不支持 TFrame 的问题
*           2003.05.02
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFORMENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, StdCtrls, Contnrs, ActnList, Buttons, Math,
  ImgList, Dialogs,
  {$IFDEF DELPHIXE3_UP} Actions, {$ENDIF}
  CnCommon, CnWizUtils, CnWizNotifier, CnWizIdeUtils,
  CnWizConsts, CnConsts, CnWizClasses, CnWizOptions, CnFlatToolbarConfigFrm,
  CnWizManager, CnWizMultiLang, CnSpin, TypInfo, CnPopupMenu, CnDesignEditorUtils,
  CnWizIni, CnEventBus;

const
  WM_PROPBARMODIFIED = WM_USER + $382;

type

//==============================================================================
// 窗体浮动面板控件
//==============================================================================

{ TCnFloatSnapPanel }

  TSnapPos = (spTopLeft, spTopRight, spBottomLeft, spBottomRight, spLeftTop,
    spLeftBottom, spRightTop, spRightBottom);

  TCnFloatSnapPanel = class(TWinControl)
  private
    FAllowDrag: Boolean;
    FMouseDown: Boolean;
    FOldX: Integer;
    FOldY: Integer;
    FOffsetX: Integer;
    FOffsetY: Integer;
    FSnapForm: TCustomForm;
    FSnapPos: TSnapPos;
    FPosMenu: TMenuItem;
    FDragMenu: TMenuItem;
    FAllowShow: Boolean;
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintMouseDown(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
    procedure SetAllowDrag(const Value: Boolean);
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
    procedure SetSnapPos(const Value: TSnapPos);
    procedure SetSnapForm(const Value: TCustomForm);
    procedure SetAllowShow(const Value: Boolean);
  protected
    PaintBox: TPaintBox;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure InitPopupMenu; virtual;
    function CanShow: Boolean; virtual;
    procedure SnapPosChanged(OldPos: TSnapPos); virtual;
    function IsVertical: Boolean; virtual;
    procedure SetPos(X, Y: Integer; hWndInsertAfter: HWND); virtual;
    procedure AlignSubControls; virtual;
    procedure OnMenuPopup(Sender: TObject); virtual;
    procedure OnMenuClose(Sender: TObject); virtual;
    procedure OnMenuSnapPos(Sender: TObject); virtual;
    procedure OnMenuAllowDrag(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure UpdatePosition; virtual;
    procedure UpdateVisible; virtual;
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    procedure LanguageChanged(Sender: TObject); virtual;
    procedure UpdateActions; virtual;

    property AllowDrag: Boolean read FAllowDrag write SetAllowDrag;
    property AllowShow: Boolean read FAllowShow write SetAllowShow;
    property SnapPos: TSnapPos read FSnapPos write SetSnapPos;
    property OffsetX: Integer read FOffsetX write SetOffsetX;
    property OffsetY: Integer read FOffsetY write SetOffsetY;
    property SnapForm: TCustomForm read FSnapForm write SetSnapForm;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

//==============================================================================
// 窗体浮动工具栏控件
//==============================================================================

{ TCnWizFloatButtonActionLink }

  TCnWizFloatButton = class;

{$IFNDEF BDS}
  TSpeedButtonActionLink = TControlActionLink;
{$ENDIF}

  TCnWizFloatButtonActionLink = class(TSpeedButtonActionLink)
  protected
    FClient: TCnWizFloatButton;
    procedure AssignClient(AClient: TObject); override;
    procedure SetChecked(Value: Boolean); override;
  end;

{ TCnWizFloatButton }

  TCnWizFloatButton = class(TSpeedButton)
  protected
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  end;

{ TCnFormFloatToolBar }

  TCnFormEnhanceWizard = class;

  TCnFormFloatToolBar = class(TCnFloatSnapPanel)
  private
    FVertOrder: Boolean;
    FLineCount: Integer;
    FActions: TStringList;
    FLastDataName: string;
    procedure SetLineCount(const Value: Integer);
    procedure SetVertOrder(const Value: Boolean);
    procedure OnMenuCustomize(Sender: TObject);
    procedure OnMenuConfig(Sender: TObject);
    procedure OnMenuExport(Sender: TObject);
    procedure OnMenuImport(Sender: TObject);
    function GetActionFileName: string;
  protected
    Panel: TPanel;
    Wizard: TCnFormEnhanceWizard;
    procedure RecreateButtons;
    procedure InitPopupMenu; override;
    procedure AlignSubControls; override;
    function CanShow: Boolean; override;
    procedure SnapPosChanged(OldPos: TSnapPos); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure SaveActions(FileName: string = '');
    procedure LoadActions(FileName: string = '');
    procedure ResetActions(FileName: string = '');
    procedure LanguageChanged(Sender: TObject); override;
    function ExportToFile: Boolean;
    function ImportFromFile: Boolean;
    procedure Customize;
    procedure UpdateActions; override;
    
    property LineCount: Integer read FLineCount write SetLineCount;
    property VertOrder: Boolean read FVertOrder write SetVertOrder;
    property Actions: TStringList read FActions;
    property ActionFileName: string read GetActionFileName;
  end;

//==============================================================================
// 窗体浮动编辑条控件
//==============================================================================

  TCnValueComboBox = class(TCnToolBarComboBox)
  private
    FOwnerDrawList: Boolean;
    FOnKillFocus: TNotifyEvent;
    procedure SetOwnerDrawList(const Value: Boolean);
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
  protected
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
      ComboProc: Pointer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    property OwnerDrawList: Boolean read FOwnerDrawList write SetOwnerDrawList;
    property OnKillFocus: TNotifyEvent read FOnKillFocus write FOnKillFocus;
  end;

  TCnFormFloatPropBar = class(TCnFloatSnapPanel)
  private
    FFreqProp: TStringList;
    FIsFilter: Boolean;
    FUpdating: Boolean;
    FDsnForm: TCustomForm;
    FSelection: TList;
    FNameCombo: TCnToolBarComboBox;
    FValueCombo: TCnValueComboBox;
    FStringButton: TSpeedButton;
    FFreqButton: TSpeedButton;
    FRenameButton: TSpeedButton;
    FNameComboWidth: Integer;
    FValueComboWidth: Integer;
    FUseHistory: Boolean;
    FSaveValue: string;
    FStrCaption: string;
    FIsSetProp: Boolean;
    FTypeInfo: PTypeInfo;
    FSetValue: TIntegerSet;
    procedure OnDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure OnMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure OnDropDown(Sender: TObject);
    function IsBoolType(PInfo: PTypeInfo): Boolean;
    function CanRename: Boolean;
    procedure OnMenuConfig(Sender: TObject);
    procedure OnRename(Sender: TObject);
    procedure OnFreq(Sender: TObject);
    procedure OnNameClick(Sender: TObject);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    procedure OnNameKeyPress(Sender: TObject; var Key: Char);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnKillFocus(Sender: TObject);
    procedure OnValueClick(Sender: TObject);
    procedure OnButtonClick(Sender: TObject);
    function GetSelection(Index: Integer): TPersistent;
    function GetSelectionCount: Integer;
    procedure UpdateControls;
    procedure UpdateProperty(TextOnly: Boolean);
    procedure ModifyProperty(BySelectItem: Boolean);
    function GetWizard: TCnBaseWizard;
    procedure WMModified(var Msg: TMessage); message WM_PROPBARMODIFIED;
    procedure SetIsSetProp(const Value: Boolean);
  protected
    Panel: TPanel;
    procedure RecreateControls;
    procedure InitPopupMenu; override;
    procedure AlignSubControls; override;
    function CanShow: Boolean; override;
    function IsVertical: Boolean; override;
    function Modified: Boolean;
    property Wizard: TCnBaseWizard read GetWizard;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure UpdateActions; override;
    property Selections[Index: Integer]: TPersistent read GetSelection;
    property SelectionCount: Integer read GetSelectionCount;
    property DsnForm: TCustomForm read FDsnForm;
    property IsSetProp: Boolean read FIsSetProp write SetIsSetProp;
  end;

  TCnSettingChangedReceiver = class(TInterfacedObject, ICnEventBusReceiver)
  private
    FWizard: TCnFormEnhanceWizard;
  public
    constructor Create(AWizard: TCnFormEnhanceWizard);
    destructor Destroy; override;

    procedure OnEvent(Event: TCnEvent);
  end;

//==============================================================================
// 窗体设计器扩展类
//==============================================================================

{ TCnFormEnhanceWizard }

  TCnFormEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FUpdating: Boolean;
    FAppBackground: Boolean;
    FList: TObjectList;
    FPropBar: TCnFormFloatPropBar;
    FDefCount: Integer;
    FIsEmbeddedDesigner: Boolean;
    FLastUpdateTick: Cardinal;
    FSettingChangedReceiver: ICnEventBusReceiver;
    function GetFlatToolBar(Index: Integer): TCnFormFloatToolBar;
    function GetFlatToolBarCount: Integer;
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;

    procedure UpdateFlatPanelsPosition;
    procedure OnAppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure OnAppEvent(EventType: TCnWizAppEventType; Data: Pointer);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure FormEditorNotify(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
    procedure ActiveFormChanged(Sender: TObject);
    procedure ExecOnIdle(Sender: TObject);
    procedure ApplicationIdle(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetFlatPanelFileName(Index: Integer): string;
    function AddFlatToolBar: TCnFormFloatToolBar;
    procedure RemoveFlatToolBar(FlatToolBar: TCnFormFloatToolBar);
    procedure CleanDataFile;
    procedure RestoreDefault;

    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    procedure LanguageChanged(Sender: TObject); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    property PropBar: TCnFormFloatPropBar read FPropBar;
    property FlatToolBars[Index: Integer]: TCnFormFloatToolBar read GetFlatToolBar;
    property FlatToolBarCount: Integer read GetFlatToolBarCount;
    property IsEmbeddedDesigner: Boolean read FIsEmbeddedDesigner;
  end;

//==============================================================================
// 窗体设计器设置窗体
//==============================================================================

{ TCnFormEnhanceConfigForm }

  TCnFormEnhanceConfigForm = class(TCnTranslateForm)
    grpFlatPanel: TGroupBox;
    cbbSnapPos: TComboBox;
    btnCustomize: TButton;
    btnExport: TButton;
    btnImport: TButton;
    btnClose: TButton;
    btnHelp: TButton;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnDefault: TButton;
    rbAllowDrag: TRadioButton;
    rbAutoSnap: TRadioButton;
    Label1: TLabel;
    seOffsetX: TCnSpinEdit;
    Label2: TLabel;
    seOffsetY: TCnSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtName: TEdit;
    cbAllowShow: TCheckBox;
    grp1: TGroupBox;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    cbbSnapPosPropBar: TComboBox;
    rbAllowDragPropBar: TRadioButton;
    rbAutoSnapPropBar: TRadioButton;
    sePropBarX: TCnSpinEdit;
    sePropBarY: TCnSpinEdit;
    chkShowPropBar: TCheckBox;
    lbl6: TLabel;
    mmoFreq: TMemo;
    lbl1: TLabel;
    lbl2: TLabel;
    seNameWidth: TCnSpinEdit;
    seValueWidth: TCnSpinEdit;
    procedure UpdateControls(Sender: TObject);
    procedure btnCustomizeClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnDefaultClick(Sender: TObject);
  private
    FUpdating: Boolean;
    procedure InitControls;
    procedure UpdateListView;
    procedure GetFromControl;
    procedure SetToControl;
    function CurrItem: TCnFormFloatToolBar;
  protected
    Wizard: TCnFormEnhanceWizard;
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNFORMENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFORMENHANCEWIZARD}

{$R *.DFM}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizShareImages, CnPrefixExecuteFrm, CnDesignEditorConsts,
  CnMultiLineEditorFrm;

const
  csTitleWidth = 12;
  csUpdateInterval = 100;

var
  csFlatFormPosCaptions: array[TSnapPos] of PString =
    (@SCnMenuFlatPanelTopLeft, @SCnMenuFlatPanelTopRight,
    @SCnMenuFlatPanelBottomLeft, @SCnMenuFlatPanelBottomRight,
    @SCnMenuFlatPanelLeftTop, @SCnMenuFlatPanelLeftBottom,
    @SCnMenuFlatPanelRightTop, @SCnMenuFlatPanelRightBottom);

const
  csPanel = 'Panel';
  csPropBar = 'PropBar';
  csPropBarHistory = 'PropBarHistory';
  csAllowDrag = 'AllowDrag';
  csAllowShow = 'AllowShow';
  csSnapPos = 'SnapPos';
  csOffsetX = 'OffsetX';
  csOffsetY = 'OffsetY';
  csLeft = 'Left';
  csTop = 'Top';
  csCaption = 'Caption';
  csCount = 'Count';
  csPropBarHeight = 20;
  csPropBarBigHeight = 32;
  csNameComboWidth = 'NameComboWidth';
  csValueComboWidth = 'ValueComboWidth';
  csIsFilter = 'IsFilter';
  csMaxEnumCount = 255;
  IdxRename = 86;
  IdxFreq = 87;
  
  csTypeInfoSimple = [tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    tkWChar, tkLString, tkWString, tkSet, tkVariant, tkInt64{$IFDEF UNICODE}, tkUString{$ENDIF}];

  csTypeInfoHistory = [tkInteger, tkChar, tkFloat, tkString, tkWChar,
    tkLString, tkWString, tkVariant, tkInt64{$IFDEF UNICODE}, tkUString{$ENDIF}];

//==============================================================================
// 窗体浮动面板控件
//==============================================================================

{ TCnFloatSnapPanel }

constructor TCnFloatSnapPanel.Create(AOwner: TComponent);
begin
  inherited;
  PopupMenu := TPopupMenu.Create(Self);

  PaintBox := TPaintBox.Create(Self);
  PaintBox.Width := csTitleWidth;
  PaintBox.Parent := Self;
  PaintBox.Align := alLeft;
  PaintBox.PopupMenu := PopupMenu;
  PaintBox.OnPaint := PaintBoxPaint;
  PaintBox.OnMouseDown := PaintMouseDown;
  PaintBox.OnMouseMove := PaintBoxMouseMove;
  PaintBox.OnMouseUp := PaintBoxMouseUp;

  InitPopupMenu;

  ParentWindow := Application.Handle;
  Visible := False;

  FAllowDrag := False;
  FAllowShow := True;
  FSnapPos := spTopLeft;
  FOffsetX := 0;
  FOffsetY := 0;
  FSnapForm := nil;
end;

procedure TCnFloatSnapPanel.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := Application.Handle;
  Params.Style := Params.Style and not (WS_CHILD or WS_GROUP or WS_TABSTOP or
    WS_CAPTION or WS_BORDER or WS_DLGFRAME) or WS_POPUP;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
end;

procedure TCnFloatSnapPanel.CreateWnd;
begin
  inherited;
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
  AlignSubControls;
end;

destructor TCnFloatSnapPanel.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------
// 控件初始化及更新
//------------------------------------------------------------------------------

procedure TCnFloatSnapPanel.InitPopupMenu;
var
  Pos: TSnapPos;
begin
  PopupMenu.Items.Clear;
  
  with PopupMenu do
  begin
    OnPopup := OnMenuPopup;

    AddMenuItem(Items, SCnMenuFlatFormCloseCaption, OnMenuClose);
    
    AddSepMenuItem(Items);
    
    FPosMenu := AddMenuItem(Items, SCnMenuFlagFormPosCaption);
    for Pos := Low(Pos) to High(Pos) do
    begin
      with AddMenuItem(FPosMenu, csFlatFormPosCaptions[Pos]^, OnMenuSnapPos) do
      begin
        GroupIndex := 1;
        RadioItem := True;
        Tag := Ord(Pos);
      end;
    end;

    FDragMenu := AddMenuItem(Items, SCnMenuFlatFormAllowDragCaption, OnMenuAllowDrag);
  end;
end;

function TCnFloatSnapPanel.IsVertical: Boolean;
begin
  Result := FSnapPos in [spLeftTop, spLeftBottom, spRightTop, spRightBottom];
end;

procedure TCnFloatSnapPanel.AlignSubControls;
begin
  if PaintBox <> nil then
  begin
    PaintBox.Visible := AllowDrag;
    if AllowDrag then
      PaintBox.Cursor := crSizeAll
    else
      PaintBox.Cursor := crDefault;
    if IsVertical then
    begin
      PaintBox.Align := alTop;
      PaintBox.Height := csTitleWidth;
    end
    else
    begin
      PaintBox.Align := alLeft;
      PaintBox.Width := csTitleWidth;
    end;
  end;
end;

procedure TCnFloatSnapPanel.SetPos(X, Y: Integer; hWndInsertAfter: HWND);
begin
  SetWindowPos(Handle, hWndInsertAfter, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure TCnFloatSnapPanel.Hide;
begin
  Visible := False;
end;

procedure TCnFloatSnapPanel.Show;
begin
  Visible := True;
end;

//------------------------------------------------------------------------------
// 控件事件处理
//------------------------------------------------------------------------------

procedure TCnFloatSnapPanel.PaintBoxPaint(Sender: TObject);
var
  r, g, b, dc: Byte;
  I, N: Integer;
  Factor: Double;
  ARect: TRect;
begin
  if IsVertical then
    N := PaintBox.Width
  else
    N := PaintBox.Height;
  if N <= 4 then Exit;
  
  if GetForegroundWindow = Handle then
  begin
    r := $00; g := $33; b := $66;
    Factor := ($99 - $00) / N;
  end
  else
  begin
    r := $99; g := $99; b := $99;
    Factor := ($CC - $99) / N;
  end;
  ARect := PaintBox.ClientRect;
  Frame3D(PaintBox.Canvas, ARect, clHighlightText, clBtnShadow, 1);
  for I := 1 to N - 2 do
  begin
    dc := Round(I * Factor);
    PaintBox.Canvas.Brush.Color := RGB(r + dc, g + dc, b + dc);
    if IsVertical then
      PaintBox.Canvas.FillRect(Rect(I, 1, I + 1, PaintBox.Height - 1))
    else
      PaintBox.Canvas.FillRect(Rect(1, I, PaintBox.Width - 1, I + 1));
  end;
end;

procedure TCnFloatSnapPanel.PaintMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if AllowDrag then
  begin
    if (Button = mbLeft) and not FMouseDown then
      FMouseDown := True;
    FOldX := X; FOldY := Y;
    PaintBox.Repaint;
  end;
end;

procedure TCnFloatSnapPanel.PaintBoxMouseMove(Sender: TObject; Shift:
  TShiftState; X, Y: Integer);
begin
  if AllowDrag and FMouseDown then
  begin
    PaintBox.OnMouseMove := nil;
    SetBounds(Left + X - FOldX, Top + Y - FOldY, Width, Height);
    PaintBox.OnMouseMove := PaintBoxMouseMove;
    PaintBox.Repaint;
  end;
end;

procedure TCnFloatSnapPanel.PaintBoxMouseUp(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := False;
  // 允许跨显示器边界，但不允许超出桌面
  if Left < Screen.DesktopLeft then
    Left := Screen.DesktopLeft;
  if Top < Screen.DesktopTop then
    Top := Screen.DesktopTop;
  if Top + Height > Screen.DesktopHeight then
    Top := Screen.DesktopHeight - Height;
  if Left + Width > Screen.DesktopWidth then
    Left := Screen.DesktopWidth - Width;
    
  PaintBox.Repaint;
end;

procedure TCnFloatSnapPanel.OnMenuPopup(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(FPosMenu) then
    for I := 0 to FPosMenu.Count - 1 do
      if FPosMenu.Items[I].Tag = Ord(SnapPos) then
      begin
        FPosMenu.Items[I].Checked := True;
        Break;
      end;
  if Assigned(FDragMenu) then
    FDragMenu.Checked := AllowDrag;
end;

procedure TCnFloatSnapPanel.OnMenuSnapPos(Sender: TObject);
begin
  if Sender is TMenuItem then
    SnapPos := TSnapPos(TMenuItem(Sender).Tag);
end;

procedure TCnFloatSnapPanel.OnMenuAllowDrag(Sender: TObject);
begin
  AllowDrag := not AllowDrag;
end;

procedure TCnFloatSnapPanel.OnMenuClose(Sender: TObject);
begin
  AllowShow := False;
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

function TCnFloatSnapPanel.GetVisible: Boolean;
begin
  Result := IsWindowVisible(Handle);
end;

procedure TCnFloatSnapPanel.SetVisible(const Value: Boolean);
begin
  if Value then
    ShowWindow(Handle, SW_SHOWNOACTIVATE)
  else
    ShowWindow(Handle, SW_HIDE);
end;

procedure TCnFloatSnapPanel.SetAllowDrag(const Value: Boolean);
begin
  if FAllowDrag <> Value then
  begin
    FAllowDrag := Value;
    AlignSubControls;
    Visible := False;
    UpdatePosition;
  end;
end;

procedure TCnFloatSnapPanel.SetOffsetX(const Value: Integer);
begin
  if FOffsetX <> Value then
  begin
    FOffsetX := Value;
    UpdatePosition;
  end;
end;

procedure TCnFloatSnapPanel.SetOffsetY(const Value: Integer);
begin
  if FOffsetY <> Value then
  begin
    FOffsetY := Value;
    UpdatePosition;
  end;
end;

procedure TCnFloatSnapPanel.SetSnapForm(const Value: TCustomForm);
begin
  if FSnapForm <> Value then
  begin
    FSnapForm := Value;
    UpdatePosition;
    UpdateVisible;
  end;
end;

procedure TCnFloatSnapPanel.SetSnapPos(const Value: TSnapPos);
var
  OldPos: TSnapPos;
  Save: Boolean;
begin
  if FSnapPos <> Value then
  begin
    Save := Visible;
    if Visible then
      Hide;
    OldPos := FSnapPos;
    FSnapPos := Value;
    SnapPosChanged(OldPos);
    AlignSubControls;
    UpdatePosition;
    if Save then
      Show;
  end;
end;

procedure TCnFloatSnapPanel.SetAllowShow(const Value: Boolean);
begin
  if FAllowShow <> Value then
  begin
    FAllowShow := Value;
    UpdateVisible;
  end;
end;

procedure TCnFloatSnapPanel.UpdatePosition;
var
  X, Y: Integer;
begin
  if FAllowShow and (SnapForm <> nil) and CanShow and
    not (csDestroying in SnapForm.ComponentState) and
    not (csDestroyingHandle in SnapForm.ControlState) and
    not ModalFormExists and
    IsWindowVisible(SnapForm.Handle) and not IsIconic(SnapForm.Handle) then
  begin
    if not AllowDrag then
    begin
      if FSnapPos in [spTopLeft, spTopRight] then
        Y := SnapForm.Top - Height
      else if FSnapPos in [spLeftTop, spRightTop] then
        Y := SnapForm.Top
      else if FSnapPos in [spLeftBottom, spRightBottom] then
        Y := SnapForm.Top + SnapForm.Height - Height
      else
        Y := SnapForm.Top + SnapForm.Height;
      if FSnapPos in [spLeftTop, spLeftBottom] then
        X := SnapForm.Left - Width
      else if FSnapPos in [spTopLeft, spBottomLeft] then
        X := SnapForm.Left
      else if FSnapPos in [spTopRight, spBottomRight] then
        X := SnapForm.Left + SnapForm.Width - Width
      else
        X := SnapForm.Left + SnapForm.Width;
      Inc(Y, OffsetY);
      Inc(X, OffsetX);
      
      // 约束在桌面内但并非本屏幕内
      if X < Screen.DesktopLeft then X := Screen.DesktopLeft;
      if Y < Screen.DesktopTop then Y := Screen.DesktopTop;
      if X + Width > Screen.DesktopWidth then
        X := Screen.DesktopWidth - Width;
      if Y + Height > Screen.DesktopHeight then
        Y := Screen.DesktopHeight - Height;

      if GetForegroundWindow = SnapForm.Handle then
        SetPos(X, Y, HWND_TOPMOST)
      else
        SetPos(X, Y, SnapForm.Handle);
      if not Visible then
        Show;
    end
    else
    begin
      SetPos(Left, Top, HWND_TOPMOST);
      if not Visible then
        Show;
    end;
    PaintBox.Repaint;
  end
  else if Visible then
    Hide;
end;

function TCnFloatSnapPanel.CanShow: Boolean;
begin
  Result := True;
end;

procedure TCnFloatSnapPanel.SnapPosChanged(OldPos: TSnapPos);
begin
  // do nothing
end;

procedure TCnFloatSnapPanel.UpdateVisible;
begin
  if FAllowShow and (SnapForm <> nil) and CanShow then
    Show
  else
    Hide;
end;

procedure TCnFloatSnapPanel.UpdateActions;
begin

end;

//------------------------------------------------------------------------------
// 多语及设置
//------------------------------------------------------------------------------

procedure TCnFloatSnapPanel.LanguageChanged(Sender: TObject);
begin
  InitPopupMenu;
end;

procedure TCnFloatSnapPanel.LoadSettings(Ini: TCustomIniFile);
begin
  Caption := Ini.ReadString(csPanel, csCaption, Caption);
  FAllowDrag := Ini.ReadBool(csPanel, csAllowDrag, FAllowDrag);
  FAllowShow := Ini.ReadBool(csPanel, csAllowShow, FAllowShow);
  FSnapPos := TSnapPos(Ini.ReadInteger(csPanel, csSnapPos, Ord(FSnapPos)));
  if not (FSnapPos in [Low(TSnapPos)..High(TSnapPos)]) then
    FSnapPos := spTopLeft;
  FOffsetX := Ini.ReadInteger(csPanel, csOffsetX, FOffsetX);
  FOffsetY := Ini.ReadInteger(csPanel, csOffsetY, FOffsetY);
end;

procedure TCnFloatSnapPanel.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteString(csPanel, csCaption, Caption);
  Ini.WriteBool(csPanel, csAllowDrag, FAllowDrag);
  Ini.WriteBool(csPanel, csAllowShow, FAllowShow);
  Ini.WriteInteger(csPanel, csSnapPos, Ord(FSnapPos));
  Ini.WriteInteger(csPanel, csOffsetX, FOffsetX);
  Ini.WriteInteger(csPanel, csOffsetY, FOffsetY);
end;

//==============================================================================
// 窗体浮动工具栏控件
//==============================================================================

{ TCnWizFloatButtonActionLink }

procedure TCnWizFloatButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TCnWizFloatButton;
end;

procedure TCnWizFloatButtonActionLink.SetChecked(Value: Boolean);
begin
  FClient.Down := Value;
end;

{ TCnWizFloatButton }

function TCnWizFloatButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TCnWizFloatButtonActionLink;
end;

procedure TCnWizFloatButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Action <> nil) and (Action is TCustomAction) then
  begin
    Action.Update;
    Down := (Action as TCustomAction).Checked;
  end;
end;

{ TCnFormFloatToolBar }

constructor TCnFormFloatToolBar.Create(AOwner: TComponent);
begin
  inherited;
  Wizard := TCnFormEnhanceWizard(CnWizardMgr.WizardByClass(TCnFormEnhanceWizard));
  Assert(Wizard <> nil);

  Panel := TPanel.Create(Self);
  Panel.Caption := '';
  Panel.Parent := Self;
  Panel.BevelInner := bvLowered;
  Panel.BevelOuter := bvNone;
  Panel.PopupMenu := PopupMenu;

  FVertOrder := True;
  FLineCount := 1;
  FActions := TStringList.Create;
end;

destructor TCnFormFloatToolBar.Destroy;
begin
  FActions.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 控件初始化及更新
//------------------------------------------------------------------------------

procedure TCnFormFloatToolBar.AlignSubControls;
begin
  inherited;
  if Panel <> nil then
  begin
    if IsVertical then
    begin
      Panel.Left := 0;
      if PaintBox.Visible then
        Panel.Top := PaintBox.Height
      else
        Panel.Top := 0;
    end
    else
    begin
      if PaintBox.Visible then
        Panel.Left := PaintBox.Width
      else
        Panel.Left := 0;
      Panel.Top := 0;
    end;
    Width := Panel.Left + Panel.Width;
    Height := Panel.Top + Panel.Height;
  end;
end;

procedure TCnFormFloatToolBar.InitPopupMenu;
begin
  inherited;

  with PopupMenu do
  begin
    AddSepMenuItem(Items);

    AddMenuItem(Items, SCnMenuFlagFormImportCaption, OnMenuImport);
    AddMenuItem(Items, SCnMenuFlagFormExportCaption, OnMenuExport);

    AddSepMenuItem(Items);

    AddMenuItem(Items, SCnMenuFlatFormCustomizeCaption, OnMenuCustomize);
    AddMenuItem(Items, SCnMenuFlatFormConfigCaption, OnMenuConfig);
  end;
end;

function TCnFormFloatToolBar.CanShow: Boolean;
begin
  Result := Actions.Count > 0;
end;

procedure TCnFormFloatToolBar.SnapPosChanged(OldPos: TSnapPos);
var
  OldIsVertical: Boolean;
begin
  inherited;
  OldIsVertical := OldPos in [spLeftTop, spLeftBottom, spRightTop, spRightBottom];
  if OldIsVertical <> IsVertical then
    RecreateButtons;
end;

procedure TCnFormFloatToolBar.RecreateButtons;
var
  I: Integer;
  Col, Row, ButtonWidth, ButtonHeight: Integer;
  Names: TStrings;
  Actn: TContainedAction;

  procedure AddButton(AParent: TWinControl; Idx, x, y: Integer; const ActionName: string);
  var
    Actn: TContainedAction;
    Btn: TCnWizFloatButton;
    BigImg: TCustomImageList;
  begin
    Actn := FindIDEAction(ActionName);
    if Assigned(Actn) then
    begin
      Btn := TCnWizFloatButton.Create(AParent);
      with Btn do
      begin
        Parent := AParent;
        GroupIndex := Idx;
        AllowAllUp := True;
        if IsVertical then
          SetBounds(y * ButtonWidth + 1, x * ButtonHeight + 1,
            ButtonWidth, ButtonHeight)
        else
          SetBounds(x * ButtonWidth + 1, y * ButtonHeight + 1,
            ButtonWidth, ButtonHeight);
        Action := Actn;

        // 如果大图模式，则手工复制大图
        if WizOptions.UseLargeIcon and (Actn is TCustomAction) then
        begin
          BigImg := dmCnSharedImages.IDELargeImages;
          Btn.Glyph.Width := BigImg.Width;
          Btn.Glyph.Height := BigImg.Height;
          Btn.Glyph.Canvas.Brush.Color := clFuchsia;
          Btn.Glyph.Canvas.FillRect(Rect(0, 0, Btn.Glyph.Width, Btn.Glyph.Height));
          BigImg.Draw(Btn.Glyph.Canvas, 0, 0, (Actn as TCustomAction).ImageIndex);
        end;

        if WizOptions.UseLargeIcon then
          dmCnSharedImages.GetSpeedButtonGlyph(Btn, dmCnSharedImages.LargeImages,
            dmCnSharedImages.IdxUnknown)
        else
          dmCnSharedImages.GetSpeedButtonGlyph(Btn, dmCnSharedImages.Images,
            dmCnSharedImages.IdxUnknown);

        ShowHint := True;
        PopupMenu := Self.PopupMenu;
        if Hint = '' then
          Hint := StripHotkey(Caption);
        Caption := '';
        if Actn is TCustomAction then
          Down := TCustomAction(Actn).Checked;
      end;
    end;
  end;

begin
  if WizOptions.UseLargeIcon then
  begin
    ButtonWidth := csLargeButtonWidth;
    ButtonHeight := csLargeButtonHeight;
  end
  else
  begin
    ButtonWidth := csButtonWidth;
    ButtonHeight := csButtonHeight;
  end;

  Names := TStringList.Create;
  try
    // 使用临时列表以清除不存在的 Action 但仍保留原有的列表
    Names.Assign(FActions);
    for I := Names.Count - 1 downto 0 do
    begin
      Actn := FindIDEAction(Names[I]);
      if not Assigned(Actn) then
        Names.Delete(I)
      else
      begin
        Actn.Update;
        if (Actn is TCustomAction) and not TCustomAction(Actn).Visible then
          Names.Delete(I);
      end;
    end;

    if Names.Count > 0 then
    begin
      Row := Min(LineCount, Names.Count);
      Col := (Names.Count - 1) div LineCount + 1;
      if IsVertical then
      begin
        Panel.Width := ButtonWidth * Row + 1;
        Panel.Height := ButtonHeight * Col + 1;
      end
      else
      begin
        Panel.Width := ButtonWidth * Col + 1;
        Panel.Height := ButtonHeight * Row + 1;
      end;

      for I := 0 to Names.Count - 1 do
      begin
        if Names[I] <> '' then
          if VertOrder then
            AddButton(Panel, I, I div Row, I mod Row, Names[I])
          else
            AddButton(Panel, I, I mod Col, I div Col, Names[I]);
      end;
    end;
  finally
    Names.Free;
  end;

  AlignSubControls;
  UpdatePosition;
end;

procedure TCnFormFloatToolBar.LanguageChanged(Sender: TObject);
begin
  inherited;
  RecreateButtons;
end;

procedure TCnFormFloatToolBar.UpdateActions;

  procedure TraverseClients(Container: TWinControl);
  var
    I: Integer;
    Control: TControl;
  begin
    if Container.Showing then
      for I := 0 to Container.ControlCount - 1 do
      begin
        Control := Container.Controls[I];
        if (csActionClient in Control.ControlStyle) and Control.Visible then
            Control.InitiateAction;
        if Control is TWinControl then
          TraverseClients(TWinControl(Control));
      end;
  end;
begin
  InitiateAction;
  TraverseClients(Self);
end;

//------------------------------------------------------------------------------
// 设置读写及导入导出
//------------------------------------------------------------------------------

function TCnFormFloatToolBar.GetActionFileName: string;
begin
  Result := Wizard.GetFlatPanelFileName(Wizard.FList.IndexOf(Self));
end;

procedure TCnFormFloatToolBar.LoadSettings(Ini: TCustomIniFile);
var
  Value: string;
  I: Integer;
begin
  inherited;

  FLineCount := TrimInt(Ini.ReadInteger(csOptions, csLineCount, FLineCount),
    csMinLineCount, csMaxLineCount);
  FVertOrder := Ini.ReadBool(csOptions, csVertOrder, True);

  I := 0;
  FActions.Clear;
  while Ini.ValueExists(csToolBar, csButton + IntToStr(I)) do
  begin
    Value := Trim(Ini.ReadString(csToolBar, csButton + IntToStr(I), ''));
    if Value <> '' then
      FActions.Add(Value);
    Inc(I);
  end;

  RecreateButtons;
end;

procedure TCnFormFloatToolBar.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  inherited;

  Ini.WriteInteger(csOptions, csLineCount, LineCount);
  Ini.WriteBool(csOptions, csVertOrder, FVertOrder);

  Ini.EraseSection(csToolBar);
  for I := 0 to FActions.Count - 1 do
    Ini.WriteString(csToolBar, csButton + IntToStr(I), FActions[I]);
end;

procedure TCnFormFloatToolBar.LoadActions(FileName: string = '');
var
  Ini: TMemIniFile;
begin
  if FileName = '' then
    FileName := WizOptions.GetUserFileName(ActionFileName, True);
  if FLastDataName = '' then
    FLastDataName := FileName;
  Ini := TMemIniFile.Create(FileName);
  try
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TCnFormFloatToolBar.SaveActions(FileName: string = '');
var
  Ini: TMemIniFile;
begin
  if FileName = '' then
    FileName := WizOptions.GetUserFileName(ActionFileName, False);
  Ini := TMemIniFile.Create(FileName);
  try
    SaveSettings(Ini);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  if SameText(_CnExtractFileName(FileName), ActionFileName) then
    WizOptions.CheckUserFile(ActionFileName);
end;

procedure TCnFormFloatToolBar.ResetActions(FileName: string);
begin
  if FileName = '' then
    WizOptions.CleanUserFile(ActionFileName)
  else
    WizOptions.CleanUserFile(FileName);
end;

function TCnFormFloatToolBar.ExportToFile: Boolean;
begin
  Result := False;
  with TSaveDialog.Create(nil) do
  try
    DefaultExt := SCnFlatToolBarDataExt;
    Filter := SCnMenuFlatFormDataFileFilter;
    Options := [ofHideReadOnly, ofOverwritePrompt, ofEnableSizing];
    FileName := FLastDataName;
    if Execute then
    begin
      SaveActions(FileName);
      FLastDataName := FileName;
      Result := True;
    end;
  finally
    Free;
  end;
end;

function TCnFormFloatToolBar.ImportFromFile: Boolean;
begin
  Result := False;
  with TOpenDialog.Create(nil) do
  try
    DefaultExt := SCnFlatToolBarDataExt;
    Filter := SCnMenuFlatFormDataFileFilter;
    Options := [ofHideReadOnly, ofFileMustExist, ofEnableSizing];
    FileName := FLastDataName;
    
    if Execute then
    begin
      LoadActions(FileName);
      FLastDataName := FileName;
      
      SaveActions;
      WizOptions.CheckUserFile(ActionFileName);
      
      Result := True;
    end;
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

procedure TCnFormFloatToolBar.SetLineCount(const Value: Integer);
begin
  if FLineCount <> Value then
  begin
    FLineCount := Value;
    RecreateButtons;
  end;
end;

procedure TCnFormFloatToolBar.SetVertOrder(const Value: Boolean);
begin
  if FVertOrder <> Value then
  begin
    FVertOrder := Value;
    RecreateButtons;
  end;
end;

//------------------------------------------------------------------------------
// 菜单事件处理
//------------------------------------------------------------------------------

procedure TCnFormFloatToolBar.OnMenuCustomize(Sender: TObject);
begin
  Customize;
end;

procedure TCnFormFloatToolBar.OnMenuConfig(Sender: TObject);
begin
  Wizard.Config;
end;

procedure TCnFormFloatToolBar.OnMenuExport(Sender: TObject);
begin
  ExportToFile;
end;

procedure TCnFormFloatToolBar.OnMenuImport(Sender: TObject);
begin
  ImportFromFile;
end;

procedure TCnFormFloatToolBar.Customize;
begin
  with TCnFlatToolbarConfigForm.Create(nil) do
  try
    SetStyle(tbsForm, ActionFileName, 'CnFlatToolbarConfigForm');
    ToolbarActions := FActions;
    LineCount := Self.LineCount;
    VertOrder := Self.VertOrder;
    if ShowModal = mrOk then
    begin
      FActions.Assign(ToolbarActions);
      Self.LineCount := LineCount;
      Self.VertOrder := VertOrder;

      SaveActions(WizOptions.GetUserFileName(ActionFileName, False));
      WizOptions.CheckUserFile(ActionFileName);
      RecreateButtons;
    end;
  finally
    Free;
  end;
end;

//==============================================================================
// 窗体浮动编辑条控件
//==============================================================================

{ TCnValueComboBox }

procedure TCnValueComboBox.ComboWndProc(var Message: TMessage;
  ComboWnd: HWnd; ComboProc: Pointer);
begin
  inherited;
  if Message.Msg = WM_KILLFOCUS then
  begin
    if Assigned(FOnKillFocus) then
      FOnKillFocus(Self);
    Message.Result := 0;
  end;
end;

procedure TCnValueComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if FOwnerDrawList then
  begin
    Params.Style := Params.Style or CBS_OWNERDRAWVARIABLE;
  end;
end;

procedure TCnValueComboBox.SetOwnerDrawList(const Value: Boolean);
begin
  FOwnerDrawList := Value;
  RecreateWnd;
end;

procedure TCnValueComboBox.WMMouseWheel(var Message: TWMMouseWheel);
begin
  // Disable Mouse Whell
end;

{ TCnFormFloatPropBar }

constructor TCnFormFloatPropBar.Create(AOwner: TComponent);
begin
  inherited;
  FFreqProp := TStringList.Create;
  FSelection := TList.Create;
  Panel := TPanel.Create(Self);
  Panel.Caption := '';
  Panel.Parent := Self;
  Panel.BevelInner := bvLowered;
  Panel.BevelOuter := bvNone;
  Panel.PopupMenu := PopupMenu;

  FNameCombo := TCnToolBarComboBox.Create(Self);
  FNameCombo.Parent := Panel;
  FNameCombo.ParentColor := True;
  FNameCombo.Style := csDropDownList;
  FNameCombo.OnClick := OnNameClick;
  FNameCombo.OnKeyPress := OnNameKeyPress;
  FNameCombo.OnKeyDown := OnKeyDown;

  FValueCombo := TCnValueComboBox.Create(Self);
  FValueCombo.Parent := Panel;
  FValueCombo.OnKeyPress := OnKeyPress;
  FValueCombo.OnKeyDown := OnKeyDown;
  FValueCombo.OnClick := OnValueClick;
  FValueCombo.OnKillFocus := OnKillFocus;
  FValueCombo.OnMeasureItem := OnMeasureItem;
  FValueCombo.OnDrawItem := OnDrawItem;
  FValueCombo.OnDropDown := OnDropDown;

  FStringButton := TSpeedButton.Create(Self);
  FStringButton.Parent := Panel;
  FStringButton.Caption := '...';
  FStringButton.OnClick := OnButtonClick;
{$IFDEF COMPILER6_UP}
  FValueCombo.AutoComplete := False;
{$ENDIF}

  FFreqButton := TSpeedButton.Create(Self);
  FFreqButton.Parent := Panel;
  FFreqButton.OnClick := OnFreq;
  FFreqButton.GroupIndex := 100;
  FFreqButton.AllowAllUp := True;
  FFreqButton.ShowHint := True;
  FFreqButton.Hint := SCnFloatPropBarFilterCaption;

  if WizOptions.UseLargeIcon then
    dmCnSharedImages.GetSpeedButtonGlyph(FFreqButton, dmCnSharedImages.LargeImages,
      IdxFreq)
  else
    dmCnSharedImages.GetSpeedButtonGlyph(FFreqButton, dmCnSharedImages.Images,
      IdxFreq);

  FRenameButton := TSpeedButton.Create(Self);
  FRenameButton.Parent := Panel;
  FRenameButton.OnClick := OnRename;
  FRenameButton.ShowHint := True;
  FRenameButton.Hint := SCnFloatPropBarRenameCaption;

  if WizOptions.UseLargeIcon then
    dmCnSharedImages.GetSpeedButtonGlyph(FRenameButton, dmCnSharedImages.LargeImages,
      IdxRename)
  else
    dmCnSharedImages.GetSpeedButtonGlyph(FRenameButton, dmCnSharedImages.Images,
      IdxRename);

  if WizOptions.UseLargeIcon then
  begin
    FNameCombo.Font.Size := csLargeComboFontSize;
    FValueCombo.Font.Size := csLargeComboFontSize;
  end;
end;

destructor TCnFormFloatPropBar.Destroy;
begin
  FSelection.Free;
  FFreqProp.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 控件初始化及更新
//------------------------------------------------------------------------------

function TCnFormFloatPropBar.IsVertical: Boolean;
begin
  Result := False;
end;

procedure TCnFormFloatPropBar.AlignSubControls;
var
  BarHeight: Integer;
begin
  inherited;
  if Panel <> nil then
  begin
    if WizOptions.UseLargeIcon then
      BarHeight := csPropBarBigHeight
    else
      BarHeight := csPropBarHeight;

    FNameCombo.SetBounds(-1, -1, FNameComboWidth, BarHeight);
    FValueCombo.SetBounds(FNameCombo.Left + FNameCombo.Width, -1,
      FValueComboWidth, BarHeight);
    if FStringButton.Visible then
    begin
      FStringButton.SetBounds(FValueCombo.Left + FValueCombo.Width, 0,
        BarHeight, BarHeight);
      FFreqButton.SetBounds(FStringButton.Left + FStringButton.Width, 0,
        BarHeight, BarHeight);
    end
    else
    begin
      FFreqButton.SetBounds(FValueCombo.Left + FValueCombo.Width, 0,
        BarHeight, BarHeight);
    end;
    FRenameButton.SetBounds(FFreqButton.Left + FFreqButton.Width, 0,
      BarHeight, BarHeight);
    Panel.ClientHeight := BarHeight;
    Panel.ClientWidth := FRenameButton.Left + FRenameButton.Width;
    
    if PaintBox.Visible then
      Panel.Left := PaintBox.Width
    else
      Panel.Left := 0;
    Panel.Top := 0;
    Width := Panel.Left + Panel.Width;
    Height := Panel.Top + Panel.Height;
  end;
end;

function TCnFormFloatPropBar.CanShow: Boolean;
begin
  Result := True;
end;

procedure TCnFormFloatPropBar.InitPopupMenu;
begin
  inherited;
  with PopupMenu do
  begin
    AddSepMenuItem(Items);
    AddMenuItem(Items, SCnMenuFlatFormConfigCaption, OnMenuConfig);
  end;
end;

procedure TCnFormFloatPropBar.RecreateControls;
begin
  AlignSubControls;
  UpdatePosition;
end;

procedure TCnFormFloatPropBar.LanguageChanged(Sender: TObject);
begin
  inherited;
  FFreqButton.Hint := SCnFloatPropBarFilterCaption;
  FRenameButton.Hint := SCnFloatPropBarRenameCaption;
end;

//------------------------------------------------------------------------------
// 组件处理功能
//------------------------------------------------------------------------------

function TCnFormFloatPropBar.IsBoolType(PInfo: PTypeInfo): Boolean;
begin
  Result := (PInfo = TypeInfo(Boolean)) or (PInfo = TypeInfo(WordBool)) or
    (PInfo = TypeInfo(LongBool));
end;

function TCnFormFloatPropBar.GetWizard: TCnBaseWizard;
begin
  Result := CnWizardMgr.WizardByClass(TCnFormEnhanceWizard);
  Assert(Result <> nil);
end;

function TCnFormFloatPropBar.GetSelection(Index: Integer): TPersistent;
begin
  Result := TPersistent(FSelection[Index]);
end;

function TCnFormFloatPropBar.GetSelectionCount: Integer;
begin
  Result := FSelection.Count;
end;

function TCnFormFloatPropBar.Modified: Boolean;
begin
  Result := FSaveValue <> FValueCombo.Text;
end;

procedure TCnFormFloatPropBar.UpdateActions;
var
  I: Integer;
  List: TList;
  AForm: TCustomForm;
  SelChanged: Boolean;
begin
  inherited;
  List := TList.Create;
  try
    if CnOtaGetCurrDesignedForm(AForm, List, False) then
    begin
      SelChanged := (FDsnForm <> AForm) or (SelectionCount <> List.Count);
      if not SelChanged then
        for I := 0 to List.Count - 1 do
          if FSelection[I] <> List[I] then
          begin
            SelChanged := True;
            Break;
          end;
          
      if SelChanged then
      begin
        FDsnForm := AForm;
        FSelection.Clear;
        for I := 0 to List.Count - 1 do
          FSelection.Add(List[I]);
      end;
    end
    else
    begin
      SelChanged := SelectionCount > 0;
      FDsnForm := nil;
      FSelection.Clear;
    end;

    FFreqButton.Down := FIsFilter;
    FRenameButton.Enabled := CanRename;
    FNameCombo.Enabled := SelectionCount > 0;

    if SelChanged then
      UpdateControls;
  finally
    List.Free;
  end;
end;

procedure TCnFormFloatPropBar.UpdateControls;
var
  I: Integer;
  PList: TStringList;

  procedure UpdatePropListFilter(AObj: TPersistent; Update: Boolean);
  var
    PInfo: PPropInfo;
    I, j: Integer;
    PropValid: Boolean;
  begin
    if not Update then
    begin
      for I := 0 to FFreqProp.Count - 1 do
      begin
        PInfo := GetPropInfoIncludeSub(AObj, FFreqProp[I], csTypeInfoSimple);
        if PInfo <> nil then
          if SameText(FFreqProp[I], PropInfoName(PInfo)) then
            PList.AddObject(PropInfoName(PInfo), TObject(PInfo^.PropType^))
          else  // 级联属性名
            PList.AddObject(FFreqProp[I], TObject(PInfo^.PropType^));
      end;
    end
    else
    begin
      for I := PList.Count - 1 downto 0 do
      begin
        PropValid := False;
        for j := 0 to FFreqProp.Count - 1 do
        begin
          PInfo := GetPropInfoIncludeSub(AObj, FFreqProp[j], csTypeInfoSimple);
          if PInfo = nil then
            Continue;

          if SameText(FFreqProp[j], PList[I]) and
            (PInfo.PropType^^.Kind = PTypeInfo(PList.Objects[I])^.Kind) and
            SameText(TypeInfoName(PInfo.PropType^), TypeInfoName(PTypeInfo(PList.Objects[I]))) then
          begin
            PropValid := True;
            Break;
          end;
        end;

        if not PropValid then
          PList.Delete(I);
      end;
    end;
  end;

  procedure UpdatePropListFromObj(AObj: TPersistent; AUpdate: Boolean);
  var
    PropList: PPropList;
    I, j, Count: Integer;
    PropValid: Boolean;
  begin
    try
      Count := GetPropList(AObj.ClassInfo, csTypeInfoSimple, nil);
    except
      Exit;
    end;

    GetMem(PropList, Count * SizeOf(PPropInfo));
    try
      GetPropList(AObj.ClassInfo, csTypeInfoSimple, PropList);
      if not AUpdate then
      begin
        for I := 0 to Count - 1 do
          if PList.IndexOf(PropInfoName(PropList[I])) < 0 then
            PList.AddObject(PropInfoName(PropList[I]), TObject(PropList[I].PropType^));
      end
      else
      begin
        for I := PList.Count - 1 downto 0 do
        begin
          PropValid := False;
          for j := 0 to Count - 1 do
            if SameText(PropInfoName(PropList[j]), PList[I]) and
              (PropList[j].PropType^^.Kind = PTypeInfo(PList.Objects[I])^.Kind) and
              SameText(TypeInfoName(PropList[j].PropType^), TypeInfoName(PTypeInfo(PList.Objects[I]))) then
            begin
              PropValid := True;
              Break;
            end;
          if not PropValid then
            PList.Delete(I);
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;

  function IsObjInheritFrom(AObj: TObject; const ClsName: string;
    var ALevel: Integer): Boolean;
  var
    Cls: TClass;
  begin
    ALevel := 0;
    Cls := AObj.ClassType;
    repeat
      if SameText(Cls.ClassName, ClsName) then
      begin
        Result := True;
        Exit;
      end;
      Cls := Cls.ClassParent;
      Inc(ALevel);
    until Cls.ClassParent = nil;
    Result := False;
  end;

begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    FNameCombo.Items.Clear;
    if SelectionCount > 0 then
    begin
      PList := TStringList.Create;
      try
        PList.Sorted := True;
        UpdatePropListFilter(Selections[0], False);
        for I := 1 to SelectionCount - 1 do
          UpdatePropListFilter(Selections[I], True);

        if not FIsFilter then
        begin
          UpdatePropListFromObj(Selections[0], False);
          for I := 1 to SelectionCount - 1 do
            UpdatePropListFromObj(Selections[I], True);
        end;            

        if SelectionCount > 1 then
          if PList.IndexOfName('Name') >= 0 then
            PList.Delete(PList.IndexOfName('Name'));

        for I := 0 to PList.Count - 1 do
          FNameCombo.Items.Add(PList[I]);

        for I := 0 to FFreqProp.Count - 1 do
          if (Trim(FFreqProp[I]) <> '') and (PList.IndexOf(Trim(FFreqProp[I])) >= 0) then
          begin
            FNameCombo.ItemIndex := PList.IndexOf(FFreqProp[I]);
            Break;
          end;
        if (FNameCombo.Items.Count > 0) and (FNameCombo.ItemIndex < 0) then
          FNameCombo.ItemIndex := 0;
      finally
        PList.Free;
      end;   
    end;
    
    UpdateProperty(False);
  finally
    FUpdating := False;
  end;
end;

procedure TCnFormFloatPropBar.UpdateProperty(TextOnly: Boolean);
var
  I: Integer;
  PropName: string;
  V: Variant;
  IsStr: Boolean;

  procedure AddEnumList(AInfo: PTypeInfo);
  var
    I: Integer;
    SList: TStringList;
    PData: PTypeData;
  begin
    SList := TStringList.Create;
    try
      SList.Sorted := True;
      if AInfo^.Kind = tkEnumeration then
      begin
        PData := GetTypeData(AInfo);
        for I := PData.MinValue to Min(PData.MaxValue, PData.MinValue +
          csMaxEnumCount - 1) do
          SList.Add(GetEnumName(AInfo, I));
        FValueCombo.Items.Assign(SList);
      end;
    finally
      SList.Free;
    end;
  end;

begin
  if (SelectionCount > 0) and (FNameCombo.ItemIndex >= 0) then
  begin
    try
      PropName := FNameCombo.Items[FNameCombo.ItemIndex];
      V := GetPropValueIncludeSub(Selections[0], PropName);
    except
      Exit;
    end;

    for I := 1 to SelectionCount - 1 do
    begin
      if GetPropValueIncludeSub(Selections[I], PropName) <> V then
      begin
        V := '';
        Break;
      end;
    end;

    FTypeInfo := GetPropInfoIncludeSub(Selections[0], PropName)^.PropType^;
    if (FTypeInfo^.Kind = tkSet) and (V <> '') then
      V := '[' + V + ']';

    IsStr := (FTypeInfo^.Kind in [tkWChar, tkString, tkLString, tkWString
      {$IFDEF UNICODE}, tkUString{$ENDIF}]) and (PropName <> 'Name');
      
    if not TextOnly then
    begin
      FValueCombo.Items.Clear;
      FUseHistory := False;
      IsSetProp := False;
      if IsBoolType(FTypeInfo) then
      begin
        FValueCombo.Items.Add(BoolToStr(False, True));
        FValueCombo.Items.Add(BoolToStr(True, True));
      end
      else if FTypeInfo^.Kind = tkEnumeration then
      begin
        AddEnumList(FTypeInfo);
      end
      else if FTypeInfo^.Kind = tkSet then
      begin
        AddEnumList(GetTypeData(FTypeInfo)^.CompType^);
        IsSetProp := True;
      end
      else if FTypeInfo = TypeInfo(TColor) then
      begin
        GetColorList(FValueCombo.Items);
      end
      else if FTypeInfo = TypeInfo(TFontCharSet) then
      begin
        GetCharsetList(FValueCombo.Items);
      end
      else if FTypeInfo = TypeInfo(TCursor) then
      begin
        GetCursorList(FValueCombo.Items);
      end
      else if FTypeInfo^.Kind in csTypeInfoHistory then
      begin
        with Wizard.CreateIniFile do
        try
          FValueCombo.Items.CommaText := ReadString(csPropBarHistory, TypeInfoName(FTypeInfo), '');
        finally
          Free;
        end;
        FUseHistory := True;
      end;
    end;
    FValueCombo.Text := V;

    if IsStr then
    begin
      if FValueCombo.Style <> csSimple then
        FValueCombo.Style := csSimple;
      if not FStringButton.Visible then
      begin
        FStringButton.Show;
        AlignSubControls;
      end;
      FStrCaption := Selections[0].GetNamePath + '.' + PropName;
    end
    else
    begin
      if FValueCombo.Style <> csDropDown then
        FValueCombo.Style := csDropDown;
      if FStringButton.Visible then
      begin
        FStringButton.Hide;
        AlignSubControls;
      end;
    end;
  end
  else
  begin
    FValueCombo.Text := '';
  end;
  FSaveValue := FValueCombo.Text;
  FValueCombo.Enabled := FNameCombo.ItemIndex >= 0;
end;

procedure TCnFormFloatPropBar.ModifyProperty(BySelectItem: Boolean);
var
  PInfo: PTypeInfo;
  PropName: string;
  PropValue: Variant;
  EnumValue: 0..SizeOf(Integer) * 8 - 1;
  I: Integer;
begin
  if (SelectionCount > 0) and (FNameCombo.ItemIndex >= 0) then
  begin
    PropName := FNameCombo.Items[FNameCombo.ItemIndex];
    if BySelectItem and IsSetProp then
    begin
      EnumValue := GetEnumValue(GetTypeData(FTypeInfo).CompType^,
        FValueCombo.Text);
      if EnumValue in FSetValue then
        Exclude(FSetValue, EnumValue)
      else
        Include(FSetValue, EnumValue);
      PropValue := Integer(FSetValue);
    end
    else
      PropValue := FValueCombo.Text;

    for I := 0 to SelectionCount - 1 do
    begin
      try
        DoSetPropValueIncludeSub(Selections[I], PropName, PropValue);
        CnOtaNotifyFormDesignerModified(CnOtaGetCurrentFormEditor);
      except
        Application.HandleException(Self);
      end;   
    end;
    
    if FUseHistory then
    begin
      AddComboBoxTextToItems(FValueCombo);
      PInfo := GetPropInfoIncludeSub(Selections[0], PropName)^.PropType^;
      with Wizard.CreateIniFile do
      try
        WriteString(csPropBarHistory, TypeInfoName(PInfo), FValueCombo.Items.CommaText);
      finally
        Free;
      end;
    end;

    UpdateProperty(True);
    if FValueCombo.Focused and (FValueCombo.SelLength = 0) then
      FValueCombo.SelectAll;
  end;
end;

procedure TCnFormFloatPropBar.SetIsSetProp(const Value: Boolean);
begin
  FIsSetProp := Value;
  FValueCombo.OwnerDrawList := FIsSetProp;
end;

procedure TCnFormFloatPropBar.OnDropDown(Sender: TObject);
begin
  if IsSetProp then
    FSetValue := TIntegerSet(StrToSetValue(FValueCombo.Text, FTypeInfo));
end;

procedure TCnFormFloatPropBar.OnDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  IsChecked: Boolean;
  Text: string;
begin
  Text := FValueCombo.Items[Index];
  IsChecked := GetEnumValue(GetTypeData(FTypeInfo).CompType^, Text) in FSetValue;
  DrawBoolCheckBox(FValueCombo.Canvas, Rect, IsChecked, Text);
end;

procedure TCnFormFloatPropBar.OnMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  if Height < CheckBoxHeight then
    Height := CheckBoxHeight;
end;

procedure TCnFormFloatPropBar.OnNameClick(Sender: TObject);
begin
  UpdateProperty(False);
end;

procedure TCnFormFloatPropBar.WMModified(var Msg: TMessage);
begin
  ModifyProperty(True);
end;

procedure TCnFormFloatPropBar.OnValueClick(Sender: TObject);
begin
  // 直接设置会导致 Text 变空
  PostMessage(Handle, WM_PROPBARMODIFIED, 0, 0);
end;

procedure TCnFormFloatPropBar.OnButtonClick(Sender: TObject);
begin
  // 弹出字符串属性编辑框
  with TCnMultiLineEditorForm.Create(nil) do
  try
    LoadFormSize;
    Caption := FStrCaption;
    memEdit.Text := FValueCombo.Text;
    memEdit.Modified := False;
    tbtSep9.Visible := False;
    tbtCodeEditor.Visible := False;
    case ShowModal of
      mrOK: FValueCombo.Text := memEdit.Text;
    end;
  finally
    Free;
  end;
end;  

procedure TCnFormFloatPropBar.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssCtrl in Shift) and Assigned(DsnForm) then
  begin
    DsnForm.BringToFront;
  end;
end;

procedure TCnFormFloatPropBar.OnKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #9 then
  begin
    Windows.SetFocus(FNameCombo.Handle);
  end
  else if Key = #27 then
  begin
    UpdateProperty(True);
    if FValueCombo.SelLength = 0 then
      FValueCombo.SelectAll;
  end
  else if Key = #13 then
  begin
    ModifyProperty(False);
    Key := #0;
  end;
end;

procedure TCnFormFloatPropBar.OnKillFocus(Sender: TObject);
begin
  if Modified then
    ModifyProperty(False);
end;

procedure TCnFormFloatPropBar.OnNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #9 then
    Windows.SetFocus(FValueCombo.Handle);
end;

//------------------------------------------------------------------------------
// 设置读写
//------------------------------------------------------------------------------

procedure TCnFormFloatPropBar.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  if AllowDrag then
  begin
    Left := Ini.ReadInteger(csPropBar, csLeft, Left);
    Top := Ini.ReadInteger(csPropBar, csTop, Top);
  end;
  FNameComboWidth := Ini.ReadInteger(csPropBar, csNameComboWidth, 100);
  FValueComboWidth := Ini.ReadInteger(csPropBar, csValueComboWidth, 150);
  FIsFilter := Ini.ReadBool(csPropBar, csIsFilter, True);
  WizOptions.LoadUserFile(FFreqProp, SCnFloatPropBarFileName);
  RecreateControls;
end;

procedure TCnFormFloatPropBar.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteInteger(csPropBar, csLeft, Left);
  Ini.WriteInteger(csPropBar, csTop, Top);
  Ini.WriteInteger(csPropBar, csNameComboWidth, FNameComboWidth);
  Ini.WriteInteger(csPropBar, csValueComboWidth, FValueComboWidth);
  Ini.WriteBool(csPropBar, csIsFilter, FIsFilter);
  WizOptions.SaveUserFile(FFreqProp, SCnFloatPropBarFileName);
end;

//------------------------------------------------------------------------------
// 菜单及按钮事件处理
//------------------------------------------------------------------------------

procedure TCnFormFloatPropBar.OnMenuConfig(Sender: TObject);
begin
  Wizard.Config;
end;

function TCnFormFloatPropBar.CanRename: Boolean;

  function IsRootControl(Comp: TPersistent): Boolean;
  begin
    Result := (Comp is TDataModule) or (Comp is TCustomFrame) or
      (Comp is TCustomForm);
  end;
begin
  Result := (SelectionCount > 0) and (Selections[0] is TComponent) and
    (Trim(TComponent(Selections[0]).Name) <> '');
     // and not IsRootControl(Selections[0]);
end;

procedure TCnFormFloatPropBar.OnFreq(Sender: TObject);
begin
  FIsFilter := not FIsFilter;
  UpdateControls;
end;

procedure TCnFormFloatPropBar.OnRename(Sender: TObject);
begin
  if CanRename then
  begin
    if Assigned(RenameProc) then
      RenameProc(TComponent(Selections[0]))
    else
      ErrorDlg(SCnPrefixWizardNotExist);
  end;
end;

//==============================================================================
// 窗体设计器扩展类
//==============================================================================

{ TCnFormEnhanceWizard }

constructor TCnFormEnhanceWizard.Create;
begin
  inherited;
  FPropBar := TCnFormFloatPropBar.Create(nil);
  FPropBar.Caption := 'FloatPropBar';
  FIsEmbeddedDesigner := IdeGetIsEmbeddedDesigner;

  FList := TObjectList.Create;
  FDefCount := 0;
  while FileExists(WizOptions.DataPath + GetFlatPanelFileName(FDefCount)) do
    Inc(FDefCount);

  CnWizNotifierServices.AddApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.AddAppEventNotifier(OnAppEvent);
  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet,
    [WM_ACTIVATE, WM_NCACTIVATE, WM_WINDOWPOSCHANGED, WM_SHOWWINDOW]);
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorNotify);
  CnWizNotifierServices.AddApplicationIdleNotifier(ApplicationIdle);
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);

  FSettingChangedReceiver := TCnSettingChangedReceiver.Create(Self);
  EventBus.RegisterReceiver(FSettingChangedReceiver);
end;

destructor TCnFormEnhanceWizard.Destroy;
begin
  EventBus.UnRegisterReceiver(FSettingChangedReceiver);
  FSettingChangedReceiver := nil;

  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnAppMessage);
  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorNotify);
  CnWizNotifierServices.RemoveApplicationIdleNotifier(ApplicationIdle);
  CnWizNotifierServices.RemoveAppEventNotifier(OnAppEvent);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  FPropBar.Free;
  FList.Free;
  inherited;
end;

procedure TCnFormEnhanceWizard.UpdateFlatPanelsPosition;
var
  Container: TWinControl;
  I: Integer;
  SnapForm: TCustomForm;
begin
  if FUpdating then
    Exit;

  if not Active or FIsEmbeddedDesigner then
  begin
    for I := 0 to FlatToolBarCount - 1 do
    begin
      FlatToolBars[I].SnapForm := nil;
      FlatToolBars[I].Hide;
    end;
    PropBar.SnapForm := nil;
    PropBar.Hide;
    Exit;
  end;

  FUpdating := True;
  try
    Container := CnOtaGetCurrentDesignContainer;

    // 10.2 或以上版本 DataModule 嵌套很深，
    // TUndockedDesignerForm 里头套一个 TEditorFormDesigner 里头套一个
    // TFormContainerForm 里头套一个 TDataModuleForm 里头套一个
    // TComponentContainer（ScrollBox）和 DataModule
    if (Container <> nil) and Container.ClassNameIs('TDataModuleForm') then
      while Container.Parent <> nil do
        Container := Container.Parent;

    if not FAppBackground and Assigned(Container) and CurrentIsForm and
      not (csDestroying in Container.ComponentState) and
      not (csDestroyingHandle in Container.ControlState) and
      IsWindowVisible(Container.Handle) and
      not IsIconic(Container.Handle) then
    begin
      SnapForm := TCustomForm(Container);
    end
    else
      SnapForm := nil;

    for I := 0 to FlatToolBarCount - 1 do
    begin
      FlatToolBars[I].SnapForm := SnapForm;
      FlatToolBars[I].UpdatePosition;
    end;
    PropBar.SnapForm := SnapForm;
    PropBar.UpdatePosition;
  finally
    FUpdating := False;
  end;
end;

procedure TCnFormEnhanceWizard.OnAppMessage(var Msg: TMsg; var Handled: Boolean);
var
  Control: TWinControl;
begin
  if Active and not FIsEmbeddedDesigner and not FUpdating and
    (Msg.message = WM_KEYDOWN) and (Msg.wParam = VK_TAB) and IsCtrlDown and
    FPropBar.AllowShow then
  begin
    Control := FindControl(Msg.hwnd);
    if (Control <> nil) and (Control = CnOtaGetCurrentDesignContainer) then
    begin
      Windows.SetFocus(FPropBar.FValueCombo.Handle);
      Handled := True;
    end;      
  end;
end;

procedure TCnFormEnhanceWizard.OnAppEvent(EventType: TCnWizAppEventType;
  Data: Pointer);
begin
  if not Active or FIsEmbeddedDesigner or FUpdating then
    Exit;

  if EventType in [aeActivate, aeDeactivate] then
  begin
    FAppBackground := (EventType = aeDeactivate);
    UpdateFlatPanelsPosition;
  end;
end;

procedure TCnFormEnhanceWizard.OnCallWndProcRet(Handle: HWND; Control: TWinControl;
  Msg: TMessage);
begin
  if not Active or FIsEmbeddedDesigner or FUpdating then
    Exit;

  if (Msg.Msg = WM_ACTIVATE) or (Msg.Msg = WM_NCACTIVATE) then
  begin
    UpdateFlatPanelsPosition;
  end
  else if ((Msg.Msg = WM_WINDOWPOSCHANGED) or (Msg.Msg = WM_SHOWWINDOW)) and
    (Control <> nil) and
{$IFNDEF IDE_NEW_EMBEDDED_DESIGNER} // 101B has a TUndockedDesignerForm Container without csDesigning
    (csDesigning in Control.ComponentState) and
{$ENDIF}
    (Control.Parent = nil) and (Control = CnOtaGetCurrentDesignContainer) then
  begin
    if Msg.Msg = WM_WINDOWPOSCHANGED then
      UpdateFlatPanelsPosition
    else
      CnWizNotifierServices.ExecuteOnApplicationIdle(ExecOnIdle);
  end;
end;

procedure TCnFormEnhanceWizard.FormEditorNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  if not Active or FIsEmbeddedDesigner or FUpdating then
    Exit;

  if NotifyType in [fetOpened, fetClosing, fetActivated] then
  begin
    CnWizNotifierServices.ExecuteOnApplicationIdle(ExecOnIdle);
  end
  else if NotifyType = fetModified then
  begin
    if not PropBar.Modified then
      PropBar.UpdateProperty(True);
  end;
end;

procedure TCnFormEnhanceWizard.ActiveFormChanged(Sender: TObject);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(ExecOnIdle);
end;

procedure TCnFormEnhanceWizard.ExecOnIdle(Sender: TObject);
begin
  if Active and not FUpdating and not FIsEmbeddedDesigner then
  begin
    UpdateFlatPanelsPosition;
  end;
end;

procedure TCnFormEnhanceWizard.ApplicationIdle(Sender: TObject);
var
  I: Integer;
begin
  if not Active or FIsEmbeddedDesigner or FUpdating then
    Exit;

  if GetTickCount - FLastUpdateTick > csUpdateInterval then
  begin
    // 由于工具栏创建时没有指定 Parent，上面的 Action 需要手工刷新
    for I := 0 to FlatToolBarCount - 1 do
      FlatToolBars[I].UpdateActions;
    PropBar.UpdateActions;
    FLastUpdateTick := GetTickCount;
  end;
end;

//------------------------------------------------------------------------------
// 参数存取
//------------------------------------------------------------------------------

function TCnFormEnhanceWizard.GetFlatPanelFileName(Index: Integer): string;
begin
  Result := SCnFlatPanelFileName + IntToStr(Index) + '.' + SCnFlatToolBarDataExt;
end;

function TCnFormEnhanceWizard.AddFlatToolBar: TCnFormFloatToolBar;
begin
  Result := TCnFormFloatToolBar.Create(nil);
  FList.Add(Result);
  Result.Caption := 'FloatToolBar' + IntToStr(FlatToolBarCount - 1);
  Result.LoadActions;
end;

procedure TCnFormEnhanceWizard.RemoveFlatToolBar(
  FlatToolBar: TCnFormFloatToolBar);
begin
  FList.Remove(FlatToolBar);
end;

procedure TCnFormEnhanceWizard.CleanDataFile;
var
  I: Integer;
begin
  I := FlatToolBarCount;
  while FileExists(WizOptions.UserPath + GetFlatPanelFileName(I)) do
  begin
    DeleteFile(WizOptions.UserPath + GetFlatPanelFileName(I));
    Inc(I);
  end;
end;

procedure TCnFormEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
  Count: Integer;
begin
  FList.Clear;
  Count := Ini.ReadInteger('', csCount, FDefCount);
  for I := 0 to Count - 1 do
  begin
    with AddFlatToolBar do
    begin
      if AllowDrag then
      begin
        Left := Ini.ReadInteger(GetFlatPanelFileName(I), csLeft, Left);
        Top := Ini.ReadInteger(GetFlatPanelFileName(I), csTop, Top);
      end;
    end;
  end;
  PropBar.LoadSettings(Ini);
  UpdateFlatPanelsPosition;
end;

procedure TCnFormEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  if FlatToolBarCount = FDefCount then
    Ini.DeleteKey('', csCount)
  else
    Ini.WriteInteger('', csCount, FlatToolBarCount);

  for I := 0 to FlatToolBarCount - 1 do
  begin
    FlatToolBars[I].SaveActions;
    Ini.WriteInteger(GetFlatPanelFileName(I), csLeft, FlatToolBars[I].Left);
    Ini.WriteInteger(GetFlatPanelFileName(I), csTop, FlatToolBars[I].Top);
  end;
  PropBar.SaveSettings(Ini);

  CleanDataFile;
end;

procedure TCnFormEnhanceWizard.ResetSettings(Ini: TCustomIniFile);
begin
//  for I := 0 to FlatToolBarCount - 1 do
//    FlatToolBars[I].ResetActions;
//  // Remove Propbar file.
//  WizOptions.CleanUserFile(SCnFloatPropBarFileName);

  RestoreDefault;
end;

procedure TCnFormEnhanceWizard.RestoreDefault;
begin
  FList.Clear;
  CleanDataFile;
  with CreateIniFile do
  try
    DeleteKey('', csCount);
  finally
    Free;
  end;
  DoLoadSettings;
end;

function TCnFormEnhanceWizard.GetFlatToolBar(
  Index: Integer): TCnFormFloatToolBar;
begin
  Result := TCnFormFloatToolBar(FList[Index]);
end;

function TCnFormEnhanceWizard.GetFlatToolBarCount: Integer;
begin
  Result := FList.Count;
end;

//------------------------------------------------------------------------------
// 专家重载方法
//------------------------------------------------------------------------------

function TCnFormEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnFormEnhanceWizard.Config;
begin
  if FIsEmbeddedDesigner then
  begin
    ErrorDlg(SCnEmbeddedDesignerNotSupport);
    Exit;
  end;

  with TCnFormEnhanceConfigForm.Create(nil) do
  try
    ShowModal;
    DoSaveSettings;
    UpdateFlatPanelsPosition;
  finally
    Free;
  end;
end;

procedure TCnFormEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateFlatPanelsPosition;
end;

procedure TCnFormEnhanceWizard.LanguageChanged(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FlatToolBarCount - 1 do
    FlatToolBars[I].LanguageChanged(Sender);
  PropBar.LanguageChanged(Sender);
end;

class procedure TCnFormEnhanceWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFormEnhanceWizardName;
  Author := SCnPack_Zjy + ';' + SCnPack_LiuXiao;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnFormEnhanceWizardComment;
end;

function TCnFormEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '浮动,面板,工具栏,floatbar,propertybar,';
end;

//==============================================================================
// 窗体设计器设置窗体
//==============================================================================

{ TCnFormEnhanceConfigForm }

procedure TCnFormEnhanceConfigForm.FormCreate(Sender: TObject);
begin
  Wizard := TCnFormEnhanceWizard(CnWizardMgr.WizardByClass(TCnFormEnhanceWizard));
  Assert(Wizard <> nil);
  InitControls;
  EnlargeListViewColumns(ListView);
  UpdateListView;
  UpdateControls(nil);
end;

function TCnFormEnhanceConfigForm.GetHelpTopic: string;
begin
  Result := 'CnFlatToolbarConfigForm';
end;

procedure TCnFormEnhanceConfigForm.InitControls;
var
  Pos: TSnapPos;
begin
  cbbSnapPos.Items.Clear;
  cbbSnapPosPropBar.Items.Clear;
  for Pos := Low(TSnapPos) to High(TSnapPos) do
  begin
    cbbSnapPos.Items.Add(StripHotkey(csFlatFormPosCaptions[Pos]^));
    cbbSnapPosPropBar.Items.Add(StripHotkey(csFlatFormPosCaptions[Pos]^));
  end;
end;

function TCnFormEnhanceConfigForm.CurrItem: TCnFormFloatToolBar;
begin
  if ListView.Selected <> nil then
    Result := TCnFormFloatToolBar(ListView.Selected.Data)
  else
    Result := nil;
end;

procedure TCnFormEnhanceConfigForm.UpdateControls(Sender: TObject);
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    cbAllowShow.Enabled := ListView.Selected <> nil;
    edtName.Enabled := ListView.Selected <> nil;
    rbAllowDrag.Enabled := ListView.Selected <> nil;
    rbAutoSnap.Enabled := ListView.Selected <> nil;
    btnCustomize.Enabled := ListView.Selected <> nil;
    btnExport.Enabled := ListView.Selected <> nil;
    btnImport.Enabled := ListView.Selected <> nil;
    btnDelete.Enabled := ListView.Selected <> nil;
    cbbSnapPos.Enabled := rbAutoSnap.Enabled and rbAutoSnap.Checked;
    seOffsetX.Enabled := rbAutoSnap.Enabled and rbAutoSnap.Checked;
    seOffsetY.Enabled := rbAutoSnap.Enabled and rbAutoSnap.Checked;

    seNameWidth.Enabled := chkShowPropBar.Checked;
    seValueWidth.Enabled := chkShowPropBar.Checked;
    cbbSnapPosPropBar.Enabled := rbAutoSnapPropBar.Checked;
    sePropBarX.Enabled := rbAutoSnapPropBar.Checked;
    sePropBarY.Enabled := rbAutoSnapPropBar.Checked;
  finally
    FUpdating := False;
  end;
  
  GetFromControl;
end;

procedure TCnFormEnhanceConfigForm.UpdateListView;
var
  I: Integer;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for I := 0 to Wizard.FlatToolBarCount - 1 do
    begin
      with ListView.Items.Add do
      begin
        Caption := IntToStr(I);
        SubItems.Add(Wizard.FlatToolBars[I].Caption);
        SubItems.Add(StripHotkey(csFlatFormPosCaptions[Wizard.FlatToolBars[I].SnapPos]^));
        Data := Wizard.FlatToolBars[I];
      end;
    end;
    if ListView.Items.Count > 0 then
      ListView.Selected := ListView.Items[0];
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TCnFormEnhanceConfigForm.GetFromControl;
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    if CurrItem <> nil then
    begin
      CurrItem.AllowShow := cbAllowShow.Checked;
      CurrItem.Caption := edtName.Text;
      CurrItem.AllowDrag := rbAllowDrag.Checked;
      CurrItem.SnapPos := TSnapPos(cbbSnapPos.ItemIndex);
      CurrItem.OffsetX := seOffsetX.Value;
      CurrItem.OffsetY := seOffsetY.Value;
      ListView.Selected.SubItems[0] := edtName.Text;
      ListView.Selected.SubItems[1] := StripHotkey(csFlatFormPosCaptions[CurrItem.SnapPos]^);
    end;

    Wizard.FPropBar.AllowShow := chkShowPropBar.Checked;
    Wizard.FPropBar.FNameComboWidth := seNameWidth.Value;
    Wizard.FPropBar.FValueComboWidth := seValueWidth.Value;
    Wizard.FPropBar.AllowDrag := rbAllowDragPropBar.Checked;
    Wizard.FPropBar.SnapPos := TSnapPos(cbbSnapPosPropBar.ItemIndex);
    Wizard.FPropBar.OffsetX := sePropBarX.Value;
    Wizard.FPropBar.OffsetY := sePropBarY.Value;
    Wizard.FPropBar.FFreqProp.Assign(mmoFreq.Lines);
    Wizard.FPropBar.AlignSubControls;
  finally
    FUpdating := False;
  end;
end;

procedure TCnFormEnhanceConfigForm.SetToControl;
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    if CurrItem <> nil then
    begin
      cbAllowShow.Checked := CurrItem.FAllowShow;
      edtName.Text := CurrItem.Caption;
      rbAllowDrag.Checked := CurrItem.FAllowDrag;
      rbAutoSnap.Checked := not CurrItem.FAllowDrag;
      cbbSnapPos.ItemIndex := Ord(CurrItem.FSnapPos);
      seOffsetX.Value := CurrItem.FOffsetX;
      seOffsetY.Value := CurrItem.FOffsetY;
    end;

    chkShowPropBar.Checked := Wizard.FPropBar.AllowShow;
    seNameWidth.Value := Wizard.FPropBar.FNameComboWidth;
    seValueWidth.Value := Wizard.FPropBar.FValueComboWidth;
    rbAllowDragPropBar.Checked := Wizard.FPropBar.AllowDrag;
    rbAutoSnapPropBar.Checked := not Wizard.FPropBar.AllowDrag;
    cbbSnapPosPropBar.ItemIndex := Ord(Wizard.FPropBar.SnapPos);
    sePropBarX.Value := Wizard.FPropBar.OffsetX;
    sePropBarY.Value := Wizard.FPropBar.OffsetY;
    mmoFreq.Lines.Assign(Wizard.FPropBar.FFreqProp);
  finally
    FUpdating := False;
  end;
end;

procedure TCnFormEnhanceConfigForm.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  SetToControl;
  UpdateControls(nil);
end;

procedure TCnFormEnhanceConfigForm.btnCustomizeClick(Sender: TObject);
begin
  if CurrItem <> nil then
    CurrItem.Customize;
end;

procedure TCnFormEnhanceConfigForm.btnExportClick(Sender: TObject);
begin
  if CurrItem <> nil then
    CurrItem.ExportToFile;
end;

procedure TCnFormEnhanceConfigForm.btnImportClick(Sender: TObject);
begin
  if CurrItem <> nil then
    CurrItem.ImportFromFile;
end;

procedure TCnFormEnhanceConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnFormEnhanceConfigForm.btnAddClick(Sender: TObject);
var
  NewPanel: TCnFormFloatToolBar;
begin
  NewPanel := Wizard.AddFlatToolBar;
  with TCnFlatToolbarConfigForm.Create(nil) do
  try
    SetStyle(tbsForm, '', 'CnFlatToolbarConfigForm');
    ToolbarActions := NewPanel.Actions;
    LineCount := NewPanel.LineCount;
    VertOrder := NewPanel.VertOrder;
    if (ShowModal = mrOk) and (ToolbarActions.Count > 0) then
    begin
      NewPanel.Actions.Assign(ToolbarActions);
      NewPanel.LineCount := LineCount;
      NewPanel.VertOrder := VertOrder;
      NewPanel.SaveActions;
      NewPanel.RecreateButtons;
    end
    else
      Wizard.RemoveFlatToolBar(NewPanel);
    UpdateListView;
    if ListView.Items.Count > 0 then
      ListView.Selected := ListView.Items[ListView.Items.Count - 1];
  finally
    Free;
  end;
end;

procedure TCnFormEnhanceConfigForm.btnDeleteClick(Sender: TObject);
var
  Save: Integer;
begin
  if ListView.Selected <> nil then
  begin
    Save := ListView.Selected.Index;
    Wizard.RemoveFlatToolBar(TCnFormFloatToolBar(ListView.Selected.Data));
    UpdateListView;
    if ListView.Items.Count > 0 then
      ListView.Selected := ListView.Items[Min(ListView.Items.Count - 1, Save)];
  end;
end;

procedure TCnFormEnhanceConfigForm.btnDefaultClick(Sender: TObject);
begin
  if QueryDlg(SCnFlatToolBarRestoreDefault, True) then
  begin
    Wizard.RestoreDefault;
    UpdateListView;
  end;
end;

{ TCnSettingChangedReceiver }

constructor TCnSettingChangedReceiver.Create(
  AWizard: TCnFormEnhanceWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

destructor TCnSettingChangedReceiver.Destroy;
begin

  inherited;
end;

procedure TCnSettingChangedReceiver.OnEvent(Event: TCnEvent);
var
  I: Integer;
begin
  if (FWizard <> nil) and
    ((DWORD(Event.EventData) and CNWIZARDS_SETTING_WIZARDS_CHANGED) <> 0) then
  begin
    // FWizard.FPropBar.RecreateControls 暂时不用
    for I := 0 to FWizard.FlatToolBarCount - 1 do
    try
      FWizard.FlatToolBars[I].RecreateButtons;
    except
      ;
    end;
  end;
end;

initialization
  RegisterCnWizard(TCnFormEnhanceWizard);

{$ENDIF CNWIZARDS_CNFORMENHANCEWIZARD}
end.
