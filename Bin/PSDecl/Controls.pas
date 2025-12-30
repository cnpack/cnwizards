{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit Controls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Controls 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses Messages, Windows, MultiMon, Classes, Sysutils, Graphics, Menus, CommCtrl, Imm,
  ImgList, ActnList;

{ TModalResult values }

const
  mrNone     = 0;
  mrOk       = idOk;
  mrCancel   = idCancel;
  mrAbort    = idAbort;
  mrRetry    = idRetry;
  mrIgnore   = idIgnore;
  mrYes      = idYes;
  mrNo       = idNo;
  mrAll      = mrNo + 1;
  mrNoToAll  = mrAll + 1;
  mrYesToAll = mrNoToAll + 1;

{ Cursor identifiers }

type
  TCursor = ShortInt;

const
  crDefault     = TCursor(0);
  crNone        = TCursor(-1);
  crArrow       = TCursor(-2);
  crCross       = TCursor(-3);
  crIBeam       = TCursor(-4);
  crSize        = TCursor(-22);
  crSizeNESW    = TCursor(-6);
  crSizeNS      = TCursor(-7);
  crSizeNWSE    = TCursor(-8);
  crSizeWE      = TCursor(-9);
  crUpArrow     = TCursor(-10);
  crHourGlass   = TCursor(-11);
  crDrag        = TCursor(-12);
  crNoDrop      = TCursor(-13);
  crHSplit      = TCursor(-14);
  crVSplit      = TCursor(-15);
  crMultiDrag   = TCursor(-16);
  crSQLWait     = TCursor(-17);
  crNo          = TCursor(-18);
  crAppStart    = TCursor(-19);
  crHelp        = TCursor(-20);
  crHandPoint   = TCursor(-21);
  crSizeAll     = TCursor(-22);

type

{ Forward declarations }

  TDragObject = class;
  TControl = class;
  TWinControl = class;
  TDragImageList = class;

  TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient);

  TAlignSet = set of TAlign;

  TDragObject = class(TObject)
  public
    procedure Assign(Source: TDragObject); virtual;
    function GetName: string; virtual;
    procedure HideDragImage; virtual;
    function Instance: THandle; virtual;
    procedure ShowDragImage; virtual;
    property Cancelling: Boolean read FCancelling write FCancelling;
    property DragHandle: HWND read FDragHandle write FDragHandle;
    property DragPos: TPoint read FDragPos write FDragPos;
    property DragTargetPos: TPoint read FDragTargetPos write FDragTargetPos;
    property DragTarget: Pointer read FDragTarget write FDragTarget;
    property MouseDeltaX: Double read FMouseDeltaX;
    property MouseDeltaY: Double read FMouseDeltaX;
  end;
  
{ TControl }

  TControlStateE = (csLButtonDown, csClicked, csPalette,
    csReadingState, csAlignmentNeeded, csFocusing, csCreating,
    csPaintCopy, csCustomPaint, csDestroyingHandle, csDocking);
  TControlState = set of TControlStateE;

  TControlStyleE = (csAcceptsControls, csCaptureMouse,
    csDesignInteractive, csClickEvents, csFramed, csSetCaption, csOpaque,
    csDoubleClicks, csFixedWidth, csFixedHeight, csNoDesignVisible,
    csReplicatable, csNoStdEvents, csDisplayDragImage, csReflector,
    csActionClient, csMenuEvents);
  TControlStyle = set of TControlStyleE;

  TMouseButton = (mbLeft, mbRight, mbMiddle);

  TDragMode = (dmManual, dmAutomatic);

  TDragState = (dsDragEnter, dsDragLeave, dsDragMove);

  TDragKind = (dkDrag, dkDock);

  TTabOrder = Integer;

  TCaption = type string;

  TDate = type TDateTime;

  TTime = type TDateTime;

  TScalingFlag = (sfLeft, sfTop, sfWidth, sfHeight, sfFont);
  TScalingFlags = set of TScalingFlag;

  TAnchorKind = (akLeft, akTop, akRight, akBottom);
  TAnchors = set of TAnchorKind;

  TConstraintSize = 0..MaxInt;

  TSizeConstraints = class(TPersistent)
  public
    constructor Create(Control: TControl); virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property MaxHeight: TConstraintSize index 0 read FMaxHeight write SetConstraints default 0;
    property MaxWidth: TConstraintSize index 1 read FMaxWidth write SetConstraints default 0;
    property MinHeight: TConstraintSize index 2 read FMinHeight write SetConstraints default 0;
    property MinWidth: TConstraintSize index 3 read FMinWidth write SetConstraints default 0;
  end;

  TMouseEvent = procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer) of object;
  TMouseMoveEvent = procedure(Sender: TObject; Shift: TShiftState;
    X, Y: Integer) of object;
  TKeyEvent = procedure(Sender: TObject; var Key: Word;
    Shift: TShiftState) of object;
  TKeyPressEvent = procedure(Sender: TObject; var Key: Char) of object;
  TCanResizeEvent = procedure(Sender: TObject; var NewWidth, NewHeight: Integer;
    var Resize: Boolean) of object;
  TConstrainedResizeEvent = procedure(Sender: TObject; var MinWidth, MinHeight,
    MaxWidth, MaxHeight: Integer) of object;
  TMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean) of object;
  TMouseWheelUpDownEvent = procedure(Sender: TObject; Shift: TShiftState;
    MousePos: TPoint; var Handled: Boolean) of object;
  TContextPopupEvent = procedure(Sender: TObject; MousePos: TPoint; var Handled: Boolean) of object;

  TWndMethod = procedure(var Message: TMessage) of object;

  TDockOrientation = (doNoOrient, doHorizontal, doVertical);

  TControl = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginDrag(Immediate: Boolean; Threshold: Integer = -1);
    procedure BringToFront;
    function ClientToScreen(const Point: TPoint): TPoint;
    procedure Dock(NewDockSite: TWinControl; ARect: TRect); dynamic;
    function Dragging: Boolean;
    procedure DragDrop(Source: TObject; X, Y: Integer); dynamic;
    function DrawTextBiDiModeFlags(Flags: Longint): Longint;
    function DrawTextBiDiModeFlagsReadingOnly: Longint;
    property Enabled: Boolean read GetEnabled write SetEnabled stored IsEnabledStored default True;
    procedure EndDrag(Drop: Boolean);
    function GetControlsAlignment: TAlignment; dynamic;
    function GetParentComponent: TComponent; override;
    function GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function GetTextLen: Integer;
    function HasParent: Boolean; override;
    procedure Hide;
    procedure InitiateAction; virtual;
    procedure Invalidate; virtual;
    function IsRightToLeft: Boolean;
    function ManualDock(NewDockSite: TWinControl; DropControl: TControl = nil;
      ControlSide: TAlign = alNone): Boolean;
    function ManualFloat(ScreenPos: TRect): Boolean;
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure Refresh;
    procedure Repaint; virtual;
    function ReplaceDockedControl(Control: TControl; NewDockSite: TWinControl;
      DropControl: TControl; ControlSide: TAlign): Boolean;
    function ScreenToClient(const Point: TPoint): TPoint;
    procedure SendToBack;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); virtual;
    procedure SetTextBuf(Buffer: PChar);
    procedure Show;
    procedure Update; virtual;
    function UseRightToLeftAlignment: Boolean; dynamic;
    function UseRightToLeftReading: Boolean;
    function UseRightToLeftScrollBar: Boolean;
    property Action: TBasicAction read GetAction write SetAction;
    property Align: TAlign read FAlign write SetAlign default alNone;
    property Anchors: TAnchors read FAnchors write SetAnchors stored IsAnchorsStored default [akLeft, akTop];
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight stored False;
    property ClientOrigin: TPoint read GetClientOrigin;
    property ClientRect: TRect read GetClientRect;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth stored False;
    property Constraints: TSizeConstraints read FConstraints write FConstraints;
    property ControlState: TControlState read FControlState write FControlState;
    property ControlStyle: TControlStyle read FControlStyle write FControlStyle;
    property DockOrientation: TDockOrientation read FDockOrientation write FDockOrientation;
    property Floating: Boolean read GetFloating;
    property FloatingDockSiteClass: TWinControlClass read GetFloatingDockSiteClass write FFloatingDockSiteClass;
    property HostDockSite: TWinControl read FHostDockSite write SetHostDockSite;
    property LRDockWidth: Integer read GetLRDockWidth write FLRDockWidth;
    property Parent: TWinControl read FParent write SetParent;
    property ShowHint: Boolean read FShowHint write SetShowHint stored IsShowHintStored;
    property TBDockHeight: Integer read GetTBDockHeight write FTBDockHeight;
    property UndockHeight: Integer read GetUndockHeight write FUndockHeight;
    property UndockWidth: Integer read GetUndockWidth write FUndockWidth;
    property Visible: Boolean read FVisible write SetVisible stored IsVisibleStored default True;
    property WindowProc: TWndMethod read FWindowProc write FWindowProc;
  published
    property Left: Integer read FLeft write SetLeft;
    property Top: Integer read FTop write SetTop;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Cursor: TCursor read FCursor write SetCursor default crDefault;
    property Hint: string read FHint write FHint stored IsHintStored;
  end;

{ TWinControl }

  TImeMode = (imDisable, imClose, imOpen, imDontCare,
              imSAlpha, imAlpha, imHira, imSKata, imKata,
              imChinese, imSHanguel, imHanguel);
  TImeName = type string;

  TBorderWidth = 0..MaxInt;

  TBevelCut = (bvNone, bvLowered, bvRaised, bvSpace);
  TBevelEdge = (beLeft, beTop, beRight, beBottom);
  TBevelEdges = set of TBevelEdge;
  TBevelKind = (bkNone, bkTile, bkSoft, bkFlat);
  TBevelWidth = 1..MaxInt;

  TWinControl = class(TControl)
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateParented(ParentWindow: HWnd);
    destructor Destroy; override;
    procedure Broadcast(var Message: TMessage);
    function CanFocus: Boolean; dynamic;
    function ContainsControl(Control: TControl): Boolean;
    function ControlAtPos(const Pos: TPoint; AllowDisabled: Boolean;
      AllowWinControls: Boolean = False): TControl;
    procedure DisableAlign;
    property DockClientCount: Integer read GetDockClientCount;
    property DockClients[Index: Integer]: TControl read GetDockClients;
    procedure DockDrop(Source: TDragDockObject; X, Y: Integer); dynamic;
    property DoubleBuffered: Boolean read FDoubleBuffered write FDoubleBuffered;
    procedure EnableAlign;
    function FindChildControl(const ControlName: string): TControl;
    procedure FlipChildren(AllLevels: Boolean); dynamic;
    function Focused: Boolean; dynamic;
    procedure GetTabOrderList(List: TList); dynamic;
    function HandleAllocated: Boolean;
    procedure HandleNeeded;
    procedure InsertControl(AControl: TControl);
    procedure Invalidate; override;
    procedure MouseWheelHandler(var Message: TMessage); dynamic;
    procedure PaintTo(DC: HDC; X, Y: Integer);
    procedure RemoveControl(AControl: TControl);
    procedure Realign;
    procedure Repaint; override;
    procedure ScaleBy(M, D: Integer);
    procedure ScrollBy(DeltaX, DeltaY: Integer);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetFocus; virtual;
    procedure Update; override;
    procedure UpdateControlState;
    property VisibleDockClientCount: Integer read GetVisibleDockClientCount;
    property Brush: TBrush read FBrush;
    property Controls[Index: Integer]: TControl read GetControl;
    property ControlCount: Integer read GetControlCount;
    property Handle: HWnd read GetHandle;
    property ParentWindow: HWnd read FParentWindow write SetParentWindow;
    property Showing: Boolean read FShowing;
    property TabOrder: TTabOrder read GetTabOrder write SetTabOrder default -1;
    property TabStop: Boolean read FTabStop write SetTabStop default False;
  published
    property HelpContext: THelpContext read FHelpContext write FHelpContext stored IsHelpContextStored default 0;
  end;

  TGraphicControl = class(TControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TCustomControl = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TCustomImageList }

  HIMAGELIST = THandle;
  TDrawingStyle = (dsFocus, dsSelected, dsNormal, dsTransparent);
  TImageType = (itImage, itMask);
  TResType = (rtBitmap, rtCursor, rtIcon);
  TOverlay = 0..3;
  TLoadResource = (lrDefaultColor, lrDefaultSize, lrFromFile,
    lrMap3DColors, lrTransparent, lrMonoChrome);
  TLoadResources = set of TLoadResource;
  TImageIndex = type Integer;

  TCustomImageList = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateSize(AWidth, AHeight: Integer);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Image, Mask: TBitmap): Integer;
    function AddIcon(Image: TIcon): Integer;
    procedure AddImages(Value: TCustomImageList);
    function AddMasked(Image: TBitmap; MaskColor: TColor): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Draw(Canvas: TCanvas; X, Y, Index: Integer;
      Enabled: Boolean = True); overload;
    procedure DrawOverlay(Canvas: TCanvas; X, Y: Integer;
      ImageIndex: Integer; Overlay: TOverlay; Enabled: Boolean = True); overload;
    function FileLoad(ResType: TResType; const Name: string;
      MaskColor: TColor): Boolean;
    function GetBitmap(Index: Integer; Image: TBitmap): Boolean;
    function GetHotSpot: TPoint; virtual;
    procedure GetIcon(Index: Integer; Image: TIcon); overload;
    function GetImageBitmap: HBITMAP;
    function GetMaskBitmap: HBITMAP;
    function HandleAllocated: Boolean;
    procedure Insert(Index: Integer; Image, Mask: TBitmap);
    procedure InsertIcon(Index: Integer; Image: TIcon);
    procedure InsertMasked(Index: Integer; Image: TBitmap; MaskColor: TColor);
    procedure Move(CurIndex, NewIndex: Integer);
    function Overlay(ImageIndex: Integer; Overlay: TOverlay): Boolean;
    procedure Replace(Index: Integer; Image, Mask: TBitmap);
    procedure ReplaceIcon(Index: Integer; Image: TIcon);
    procedure ReplaceMasked(Index: Integer; NewImage: TBitmap; MaskColor: TColor);
    property Count: Integer read GetCount;
    property Handle: HImageList read GetHandle write SetHandle;
  public
    property AllocBy: Integer read FAllocBy write FAllocBy default 4;
    property BlendColor: TColor read FBlendColor write FBlendColor default clNone;
    property BkColor: TColor read GetBkColor write SetBkColor default clNone;
    property DrawingStyle: TDrawingStyle read FDrawingStyle write SetDrawingStyle default dsNormal;
    property Height: Integer read FHeight write SetHeight default 16;
    property ImageType: TImageType read FImageType write FImageType default itImage;
    property Masked: Boolean read FMasked write FMasked default True;
    property ShareImages: Boolean read FShareImages write FShareImages default False;
    property Width: Integer read FWidth write SetWidth default 16;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  
{ TDragImageList }

  TDragImageList = class(TCustomImageList)
  public
    function BeginDrag(Window: HWND; X, Y: Integer): Boolean;
    function DragLock(Window: HWND; XPos, YPos: Integer): Boolean;
    function DragMove(X, Y: Integer): Boolean;
    procedure DragUnlock;
    function EndDrag: Boolean;
    function GetHotSpot: TPoint; override;
    procedure HideDragImage;
    function SetDragImage(Index, HotSpotX, HotSpotY: Integer): Boolean;
    procedure ShowDragImage;
    property DragCursor: TCursor read FDragCursor write SetDragCursor;
    property Dragging: Boolean read FDragging;
  end;

{ TImageList }

  TImageList = class(TDragImageList)
  published
    property BlendColor;
    property BkColor;
    property AllocBy;
    property DrawingStyle;
    property Height;
    property ImageType;
    property Masked;
    property OnChange;
    property ShareImages;
    property Width;
  end;

{ Mouse support }

  TMouse = class
  public
    constructor Create;
    destructor Destroy; override;
    procedure SettingChanged(Setting: Integer);
    property Capture: HWND read GetCapture write SetCapture;
    property CursorPos: TPoint read GetCursorPos write SetCursorPos;
    property DragImmediate: Boolean read FDragImmediate write FDragImmediate default True;
    property DragThreshold: Integer read FDragThreshold write FDragThreshold default 5;
    property MousePresent: Boolean read FMousePresent;
    property RegWheelMessage: UINT read FWheelMessage;
    property WheelPresent: Boolean read FWheelPresent;
    property WheelScrollLines: Integer read FScrollLines;
  end;

function Mouse: TMouse; overload;

{ Misc }

function CursorToString(Cursor: TCursor): string;
function StringToCursor(const S: string): TCursor;
procedure GetCursorValues(Proc: TGetStrProc);
function CursorToIdent(Cursor: Longint; var Ident: string): Boolean;
function IdentToCursor(const Ident: string; var Cursor: Longint): Boolean;

function GetShortHint(const Hint: string): string;
function GetLongHint(const Hint: string): string;

function SendAppMessage(Msg: Cardinal; WParam, LParam: Longint): Longint;
procedure MoveWindowOrg(DC: HDC; DX, DY: Integer);

procedure SetImeMode(hWnd: HWND; Mode: TImeMode);
procedure SetImeName(Name: TImeName);

implementation

end.
