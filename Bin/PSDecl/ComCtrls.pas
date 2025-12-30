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

unit ComCtrls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 ComCtrls 单元声明
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

{$R-,T-,H+,X+}

interface

uses Messages, Windows, SysUtils, CommCtrl, Classes, Controls, Forms,
  Menus, Graphics, StdCtrls, RichEdit, ToolWin, ImgList, ExtCtrls;

type
  THitTest = (htAbove, htBelow, htNowhere, htOnItem, htOnButton, htOnIcon,
    htOnIndent, htOnLabel, htOnRight, htOnStateIcon, htToLeft, htToRight);
  THitTests = set of THitTest;

  TCustomTabControl = class;

  TTabChangingEvent = procedure(Sender: TObject;
    var AllowChange: Boolean) of object;

  TTabPosition = (tpTop, tpBottom, tpLeft, tpRight);

  TTabStyle = (tsTabs, tsButtons, tsFlatButtons);

  TDrawTabEvent = procedure(Control: TCustomTabControl; TabIndex: Integer;
    const Rect: TRect; Active: Boolean) of object;
  TTabGetImageEvent = procedure(Sender: TObject; TabIndex: Integer;
    var ImageIndex: Integer) of object;

  TCustomTabControl = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IndexOfTabAt(X, Y: Integer): Integer;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function TabRect(Index: Integer): TRect;
    function RowCount: Integer;
    procedure ScrollTabs(Delta: Integer);
    property Canvas: TCanvas read FCanvas;
    property TabStop default True;
  end;

  TTabControl = class(TCustomTabControl)
  public
    property DisplayRect;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HotTrack;
    property Images;
    property MultiLine;
    property MultiSelect;
    property OwnerDraw;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RaggedRight;
    property ScrollOpposite;
    property ShowHint;
    property Style;
    property TabHeight;
    property TabOrder;
    property TabPosition;
    property Tabs;
    property TabIndex;  // must be after Tabs
    property TabStop;
    property TabWidth;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawTab;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  TPageControl = class;

  TTabSheet = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property PageControl: TPageControl read FPageControl write SetPageControl;
    property TabIndex: Integer read GetTabIndex;
  published
    property BorderWidth;
    property Caption;
    property DragMode;
    property Enabled;
    property Font;
    property Height stored False;
    property Highlighted: Boolean read FHighlighted write SetHighlighted default False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default 0;
    property Left stored False;
    property Constraints;
    property PageIndex: Integer read GetPageIndex write SetPageIndex stored False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabVisible: Boolean read FTabVisible write SetTabVisible default True;
    property Top stored False;
    property Visible stored False;
    property Width stored False;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnStartDrag;
  end;

  TPageControl = class(TCustomTabControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindNextPage(CurPage: TTabSheet;
      GoForward, CheckTabVisible: Boolean): TTabSheet;
    procedure SelectNextPage(GoForward: Boolean);
    property ActivePageIndex: Integer read GetActivePageIndex
      write SetActivePageIndex;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TTabSheet read GetPage;
  published
    property ActivePage: TTabSheet read FActivePage write SetActivePage;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HotTrack;
    property Images;
    property MultiLine;
    property OwnerDraw;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RaggedRight;
    property ScrollOpposite;
    property ShowHint;
    property Style;
    property TabHeight;
    property TabOrder;
    property TabPosition;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawTab;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

{ TStatusBar }

  TStatusBar = class;

  TStatusPanelStyle = (psText, psOwnerDraw);
  TStatusPanelBevel = (pbNone, pbLowered, pbRaised);

  TStatusPanel = class(TCollectionItem)
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ParentBiDiModeChanged;
    function UseRightToLeftAlignment: Boolean;
    function UseRightToLeftReading: Boolean;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Bevel: TStatusPanelBevel read FBevel write SetBevel default pbLowered;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property ParentBiDiMode: Boolean read FParentBiDiMode write SetParentBiDiMode default True;
    property Style: TStatusPanelStyle read FStyle write SetStyle default psText;
    property Text: string read FText write SetText;
    property Width: Integer read FWidth write SetWidth;
  end;

  TStatusPanels = class(TCollection)
  public
    constructor Create(StatusBar: TStatusBar);
    function Add: TStatusPanel;
    property Items[Index: Integer]: TStatusPanel read GetItem write SetItem; default;
  end;

  TDrawPanelEvent = procedure(StatusBar: TStatusBar; Panel: TStatusPanel;
    const Rect: TRect) of object;

  TStatusBar = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure FlipChildren(AllLevels: Boolean); override;
    property Canvas: TCanvas read FCanvas;
  published
    property Action;
    property AutoHint: Boolean read FAutoHint write FAutoHint default False;
    property Align default alBottom;
    property Anchors;
    property BiDiMode;
    property BorderWidth;
    property Color default clBtnFace;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font stored IsFontStored;
    property Constraints;
    property Panels: TStatusPanels read FPanels write SetPanels;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SimplePanel: Boolean read FSimplePanel write SetSimplePanel;
    property SimpleText: string read FSimpleText write SetSimpleText;
    property SizeGrip: Boolean read FSizeGrip write SetSizeGrip default True;
    property UseSystemFont: Boolean read FUseSystemFont write SetUseSystemFont default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDrawPanel: TDrawPanelEvent read FOnDrawPanel write FOnDrawPanel;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;

{ Custom draw }

  TCustomDrawTarget = (dtControl, dtItem, dtSubItem);
  TCustomDrawStage = (cdPrePaint, cdPostPaint, cdPreErase, cdPostErase);
  TCustomDrawStateE = (cdsSelected, cdsGrayed, cdsDisabled, cdsChecked,
    cdsFocused, cdsDefault, cdsHot, cdsMarked, cdsIndeterminate);
  TCustomDrawState = set of TCustomDrawStateE;

{ THeaderControl }

  THeaderControl = class;

  THeaderSectionStyle = (hsText, hsOwnerDraw);

  THeaderSection = class(TCollectionItem)
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ParentBiDiModeChanged;
    function UseRightToLeftAlignment: Boolean;
    function UseRightToLeftReading: Boolean;
    property Left: Integer read GetLeft;
    property Right: Integer read GetRight;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AllowClick: Boolean read FAllowClick write FAllowClick default True;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 10000;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property ParentBiDiMode: Boolean read FParentBiDiMode write SetParentBiDiMode default True;
    property Style: THeaderSectionStyle read FStyle write SetStyle default hsText;
    property Text: string read FText write SetText;
    property Width: Integer read FWidth write SetWidth;
  end;

  THeaderSections = class(TCollection)
  public
    constructor Create(HeaderControl: THeaderControl);
    function Add: THeaderSection;
    property Items[Index: Integer]: THeaderSection read GetItem write SetItem; default;
  end;

  TSectionTrackState = (tsTrackBegin, tsTrackMove, tsTrackEnd);

  TDrawSectionEvent = procedure(HeaderControl: THeaderControl;
    Section: THeaderSection; const Rect: TRect; Pressed: Boolean) of object;
  TSectionNotifyEvent = procedure(HeaderControl: THeaderControl;
    Section: THeaderSection) of object;
  TSectionTrackEvent = procedure(HeaderControl: THeaderControl;
    Section: THeaderSection; Width: Integer;
    State: TSectionTrackState) of object;
  TSectionDragEvent = procedure (Sender: TObject; FromSection, ToSection: THeaderSection;
    var AllowDrag: Boolean) of object;

  THeaderStyle = (hsButtons, hsFlat);

  THeaderControl = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas: TCanvas read FCanvas;
    procedure FlipChildren(AllLevels: Boolean); override;
  published
    property Align default alTop;
    property Anchors;
    property BiDiMode;
    property BorderWidth;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DragReorder: Boolean read FDragReorder write SetDragReorder;
    property Enabled;
    property Font;
    property FullDrag: Boolean read FFullDrag write SetFullDrag default True;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property Images: TCustomImageList read FImages write SetImages;
    property Constraints;
    property Sections: THeaderSections read FSections write SetSections;
    property ShowHint;
    property Style: THeaderStyle read FStyle write SetStyle default hsButtons;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDrawSection: TDrawSectionEvent read FOnDrawSection write FOnDrawSection;
    property OnResize;
    property OnSectionClick: TSectionNotifyEvent read FOnSectionClick
      write FOnSectionClick;
    property OnSectionDrag: TSectionDragEvent read FOnSectionDrag
      write FOnSectionDrag;
    property OnSectionEndDrag: TNotifyEvent read FOnSectionEndDrag
      write FOnSectionEndDrag;
    property OnSectionResize: TSectionNotifyEvent read FOnSectionResize
      write FOnSectionResize;
    property OnSectionTrack: TSectionTrackEvent read FOnSectionTrack
      write FOnSectionTrack;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TTreeNode }

  TCustomTreeView = class;
  TTreeNodes = class;

  HTreeItem = Pointer;

  TNodeState = (nsCut, nsDropHilited, nsFocused, nsSelected, nsExpanded);
  TNodeAttachMode = (naAdd, naAddFirst, naAddChild, naAddChildFirst, naInsert);
  TAddMode = (taAddFirst, taAdd, taInsert);

  TTreeNode = class(TPersistent)
  public
    constructor Create(AOwner: TTreeNodes);
    destructor Destroy; override;
    function AlphaSort: Boolean;
    procedure Assign(Source: TPersistent); override;
    procedure Collapse(Recurse: Boolean);
    function CustomSort(SortProc: TTVCompare; Data: Longint): Boolean;
    procedure Delete;
    procedure DeleteChildren;
    function DisplayRect(TextOnly: Boolean): TRect;
    function EditText: Boolean;
    procedure EndEdit(Cancel: Boolean);
    procedure Expand(Recurse: Boolean);
    function getFirstChild: TTreeNode; {GetFirstChild conflicts with C++ macro}
    function GetHandle: HWND;
    function GetLastChild: TTreeNode;
    function GetNext: TTreeNode;
    function GetNextChild(Value: TTreeNode): TTreeNode;
    function getNextSibling: TTreeNode; {GetNextSibling conflicts with C++ macro}
    function GetNextVisible: TTreeNode;
    function GetPrev: TTreeNode;
    function GetPrevChild(Value: TTreeNode): TTreeNode;
    function getPrevSibling: TTreeNode; {GetPrevSibling conflicts with a C++ macro}
    function GetPrevVisible: TTreeNode;
    function HasAsParent(Value: TTreeNode): Boolean;
    function IndexOf(Value: TTreeNode): Integer;
    procedure MakeVisible;
    procedure MoveTo(Destination: TTreeNode; Mode: TNodeAttachMode); virtual;
    property AbsoluteIndex: Integer read GetAbsoluteIndex;
    property Count: Integer read GetCount;
    property Cut: Boolean read GetCut write SetCut;
    property Data: Pointer read FData write SetData;
    property Deleting: Boolean read FDeleting;
    property Focused: Boolean read GetFocused write SetFocused;
    property DropTarget: Boolean read GetDropTarget write SetDropTarget;
    property Selected: Boolean read GetSelected write SetSelected;
    property Expanded: Boolean read GetExpanded write SetExpanded;
    property Handle: HWND read GetHandle;
    property HasChildren: Boolean read GetChildren write SetChildren;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property Index: Integer read GetIndex;
    property IsVisible: Boolean read IsNodeVisible;
    property Item[Index: Integer]: TTreeNode read GetItem write SetItem; default;
    property ItemId: HTreeItem read FItemId;
    property Level: Integer read GetLevel;
    property OverlayIndex: Integer read FOverlayIndex write SetOverlayIndex;
    property Owner: TTreeNodes read FOwner;
    property Parent: TTreeNode read GetParent;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property StateIndex: Integer read FStateIndex write SetStateIndex;
    property Text: string read FText write SetText;
    property TreeView: TCustomTreeView read GetTreeView;
  end;

{ TTreeNodes }

  TTreeNodes = class(TPersistent)
  public
    constructor Create(AOwner: TCustomTreeView);
    destructor Destroy; override;
    function AddChildFirst(Node: TTreeNode; const S: string): TTreeNode;
    function AddChild(Node: TTreeNode; const S: string): TTreeNode;
    function AddChildObjectFirst(Node: TTreeNode; const S: string;
      Ptr: Pointer): TTreeNode;
    function AddChildObject(Node: TTreeNode; const S: string;
      Ptr: Pointer): TTreeNode;
    function AddFirst(Node: TTreeNode; const S: string): TTreeNode;
    function Add(Node: TTreeNode; const S: string): TTreeNode;
    function AddObjectFirst(Node: TTreeNode; const S: string;
      Ptr: Pointer): TTreeNode;
    function AddObject(Node: TTreeNode; const S: string;
      Ptr: Pointer): TTreeNode;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear;
    procedure Delete(Node: TTreeNode);
    procedure EndUpdate;
    function GetFirstNode: TTreeNode;
    function GetNode(ItemId: HTreeItem): TTreeNode;
    function Insert(Node: TTreeNode; const S: string): TTreeNode;
    function InsertObject(Node: TTreeNode; const S: string;
      Ptr: Pointer): TTreeNode;
    property Count: Integer read GetCount;
    property Handle: HWND read GetHandle;
    property Item[Index: Integer]: TTreeNode read GetNodeFromIndex; default;
    property Owner: TCustomTreeView read FOwner;
  end;

{ TCustomTreeView }

  TSortType = (stNone, stData, stText, stBoth);

  TTVChangingEvent = procedure(Sender: TObject; Node: TTreeNode;
    var AllowChange: Boolean) of object;
  TTVChangedEvent = procedure(Sender: TObject; Node: TTreeNode) of object;
  TTVEditingEvent = procedure(Sender: TObject; Node: TTreeNode;
    var AllowEdit: Boolean) of object;
  TTVEditedEvent = procedure(Sender: TObject; Node: TTreeNode; var S: string) of object;
  TTVExpandingEvent = procedure(Sender: TObject; Node: TTreeNode;
    var AllowExpansion: Boolean) of object;
  TTVCollapsingEvent = procedure(Sender: TObject; Node: TTreeNode;
    var AllowCollapse: Boolean) of object;
  TTVExpandedEvent = procedure(Sender: TObject; Node: TTreeNode) of object;
  TTVCompareEvent = procedure(Sender: TObject; Node1, Node2: TTreeNode;
    Data: Integer; var Compare: Integer) of object;
  TTVCustomDrawEvent = procedure(Sender: TCustomTreeView; const ARect: TRect;
    var DefaultDraw: Boolean) of object;
  TTVCustomDrawItemEvent = procedure(Sender: TCustomTreeView; Node: TTreeNode;
    State: TCustomDrawState; var DefaultDraw: Boolean) of object;
  TTVAdvancedCustomDrawEvent = procedure(Sender: TCustomTreeView; const ARect: TRect;
    Stage: TCustomDrawStage; var DefaultDraw: Boolean) of object;
  TTVAdvancedCustomDrawItemEvent = procedure(Sender: TCustomTreeView; Node: TTreeNode;
    State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean) of object;

  TCustomTreeView = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AlphaSort: Boolean;
    function CustomSort(SortProc: TTVCompare; Data: Longint): Boolean;
    procedure FullCollapse;
    procedure FullExpand;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function GetNodeAt(X, Y: Integer): TTreeNode;
    function IsEditing: Boolean;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    property Canvas: TCanvas read FCanvas;
    property DropTarget: TTreeNode read GetDropTarget write SetDropTarget;
    property Selected: TTreeNode read GetSelection write SetSelection;
    property TopItem: TTreeNode read GetTopItem write SetTopItem;
  end;

  TTreeView = class(TCustomTreeView)
  published
    property Align;
    property Anchors;
    property AutoExpand;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property ChangeDelay;
    property Color;
    property Ctl3D;
    property Constraints;
    property DragKind;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HotTrack;
    property Images;
    property Indent;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RowSelect;
    property ShowButtons;
    property ShowHint;
    property ShowLines;
    property ShowRoot;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    { Items must be published after OnGetImageIndex and OnGetSelectedIndex }
    property Items;
  end;

{ TTrackBar }

  TTrackBarOrientation = (trHorizontal, trVertical);
  TTickMark = (tmBottomRight, tmTopLeft, tmBoth);
  TTickStyle = (tsNone, tsAuto, tsManual);

  TTrackBar = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetTick(Value: Integer);
  published
    property Align;
    property Anchors;
    property BorderWidth;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Constraints;
    property LineSize: Integer read FLineSize write SetLineSize default 1;
    property Max: Integer read FMax write SetMax default 10;
    property Min: Integer read FMin write SetMin default 0;
    property Orientation: TTrackBarOrientation read FOrientation write SetOrientation;
    property ParentCtl3D;
    property ParentShowHint;
    property PageSize: Integer read FPageSize write SetPageSize default 2;
    property PopupMenu;
    property Frequency: Integer read FFrequency write SetFrequency;
    property Position: Integer read FPosition write SetPosition;
    property SliderVisible: Boolean read FSliderVisible write SetSliderVisible default True;
    property SelEnd: Integer read FSelEnd write SetSelEnd;
    property SelStart: Integer read FSelStart write SetSelStart;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThumbLength: Integer read GetThumbLength write SetThumbLength default 20;
    property TickMarks: TTickMark read FTickMarks write SetTickMarks;
    property TickStyle: TTickStyle read FTickStyle write SetTickStyle;
    property Visible;
    property OnContextPopup;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TProgressBar }

  TProgressRange = Integer; // for backward compatibility

  TProgressBarOrientation = (pbHorizontal, pbVertical);

  TProgressBar = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    procedure StepIt;
    procedure StepBy(Delta: Integer);
  published
    property Align;
    property Anchors;
    property BorderWidth;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Hint;
    property Constraints;
    property Min: Integer read GetMin write SetMin;
    property Max: Integer read GetMax write SetMax;
    property Orientation: TProgressBarOrientation read FOrientation
      write SetOrientation default pbHorizontal;
    property ParentShowHint;
    property PopupMenu;
    property Position: Integer read GetPosition write SetPosition default 0;
    property Smooth: Boolean read FSmooth write SetSmooth default False;
    property Step: Integer read FStep write SetStep default 10;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TTextAttributes }

  TCustomRichEdit = class;

  TAttributeType = (atSelected, atDefaultText);
  TConsistentAttribute = (caBold, caColor, caFace, caItalic,
    caSize, caStrikeOut, caUnderline, caProtected);
  TConsistentAttributes = set of TConsistentAttribute;

  TTextAttributes = class(TPersistent)
  public
    constructor Create(AOwner: TCustomRichEdit; AttributeType: TAttributeType);
    procedure Assign(Source: TPersistent); override;
    property Charset: TFontCharset read GetCharset write SetCharset;
    property Color: TColor read GetColor write SetColor;
    property ConsistentAttributes: TConsistentAttributes read GetConsistentAttributes;
    property Name: TFontName read GetName write SetName;
    property Pitch: TFontPitch read GetPitch write SetPitch;
    // property Protected: Boolean read GetProtected write SetProtected;
    property Size: Integer read GetSize write SetSize;
    property Style: TFontStyles read GetStyle write SetStyle;
    property Height: Integer read GetHeight write SetHeight;
  end;

{ TParaAttributes }

  TNumberingStyle = (nsNone, nsBullet);

  TParaAttributes = class(TPersistent)
  public
    constructor Create(AOwner: TCustomRichEdit);
    procedure Assign(Source: TPersistent); override;
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    property FirstIndent: Longint read GetFirstIndent write SetFirstIndent;
    property LeftIndent: Longint read GetLeftIndent write SetLeftIndent;
    property Numbering: TNumberingStyle read GetNumbering write SetNumbering;
    property RightIndent: Longint read GetRightIndent write SetRightIndent;
    property Tab[Index: Byte]: Longint read GetTab write SetTab;
    property TabCount: Integer read GetTabCount write SetTabCount;
  end;

{ TCustomRichEdit }

  TRichEditResizeEvent = procedure(Sender: TObject; Rect: TRect) of object;
  TRichEditProtectChange = procedure(Sender: TObject;
    StartPos, EndPos: Integer; var AllowChange: Boolean) of object;
  TRichEditSaveClipboard = procedure(Sender: TObject;
    NumObjects, NumChars: Integer; var SaveClipboard: Boolean) of object;
  TSearchType = (stWholeWord, stMatchCase);
  TSearchTypes = set of TSearchType;

  TConversion = class(TObject)
  public
    function ConvertReadStream(Stream: TStream; Buffer: PChar; BufSize: Integer): Integer; virtual;
    function ConvertWriteStream(Stream: TStream; Buffer: PChar; BufSize: Integer): Integer; virtual;
  end;

  TConversionClass = class of TConversion;

  TCustomRichEdit = class(TCustomMemo)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    function FindText(const SearchStr: string;
      StartPos, Length: Integer; Options: TSearchTypes): Integer;
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer; override;
    procedure Print(const Caption: string); virtual;
    class procedure RegisterConversionFormat(const AExtension: string;
      AConversionClass: TConversionClass);
    property DefaultConverter: TConversionClass
      read FDefaultConverter write FDefaultConverter;
    property DefAttributes: TTextAttributes read FDefAttributes write SetDefAttributes;
    property SelAttributes: TTextAttributes read FSelAttributes write SetSelAttributes;
    property PageRect: TRect read FPageRect write FPageRect;
    property Paragraph: TParaAttributes read FParagraph;
  end;

  TRichEdit = class(TCustomRichEdit)
  published
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HideScrollBars;
    property ImeMode;
    property ImeName;
    property Constraints;
    property Lines;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PlainText;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property WantTabs;
    property WantReturns;
    property WordWrap;
    property OnChange;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSaveClipboard;
    property OnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TUpDown }

  TUDAlignButton = (udLeft, udRight);
  TUDOrientation = (udHorizontal, udVertical);
  TUDBtnType = (btNext, btPrev);
  TUpDownDirection = (updNone, updUp, updDown);
  TUDClickEvent = procedure (Sender: TObject; Button: TUDBtnType) of object;
  TUDChangingEvent = procedure (Sender: TObject; var AllowChange: Boolean) of object;
  TUDChangingEventEx = procedure (Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection) of object;

  TCustomUpDown = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TUpDown = class(TCustomUpDown)
  published
    property AlignButton;
    property Anchors;
    property Associate;
    property ArrowKeys;
    property Enabled;
    property Hint;
    property Min;
    property Max;
    property Increment;
    property Constraints;
    property Orientation;
    property ParentShowHint;
    property PopupMenu;
    property Position;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Thousands;
    property Visible;
    property Wrap;
    property OnChanging;
    property OnChangingEx;
    property OnContextPopup;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ THotKey }

  THKModifier = (hkShift, hkCtrl, hkAlt, hkExt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  TCustomHotKey = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  THotKey = class(TCustomHotKey)
  published
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Hint;
    property HotKey;
    property InvalidKeys;
    property Modifiers;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

type
  TListColumns = class;
  TListItems = class;
  TCustomListView = class;
  TWidth = Integer; // ColumnHeaderWidth..MaxInt;

  TListColumn = class(TCollectionItem)
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property WidthType: TWidth read FWidth;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Caption: string read FCaption write SetCaption;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property MaxWidth: TWidth read FMaxWidth write SetMaxWidth default 0;
    property MinWidth: TWidth read FMinWidth write SetMinWidth default 0;
    property Tag: Integer read FTag write FTag default 0;
    property Width: TWidth read GetWidth write SetWidth stored IsWidthStored default 50;
  end;

  TListColumns = class(TCollection)
  public
    constructor Create(AOwner: TCustomListView);
    function Add: TListColumn;
    property Owner: TCustomListView read FOwner;
    property Items[Index: Integer]: TListColumn read GetItem write SetItem; default;
  end;

  TDisplayCode = (drBounds, drIcon, drLabel, drSelectBounds);

  { TListItem }

  TListItem = class(TPersistent)
  public
    constructor Create(AOwner: TListItems);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure CancelEdit;
    procedure Delete;
    function DisplayRect(Code: TDisplayCode): TRect;
    function EditCaption: Boolean;
    function GetPosition: TPoint;
    procedure MakeVisible(PartialOK: Boolean);
    procedure Update;
    procedure SetPosition(const Value: TPoint);
    function WorkArea: Integer;
    property Caption: string read FCaption write SetCaption;
    property Checked: Boolean read GetChecked write SetChecked;
    property Cut: Boolean index 0 read GetState write SetState;
    property Data: Pointer read FData write SetData;
    property DropTarget: Boolean index 1 read GetState write SetState;
    property Focused: Boolean index 2 read GetState write SetState;
    property Handle: HWND read GetHandle;
    property ImageIndex: TImageIndex index 0 read FImageIndex write SetImage;
    property Indent: Integer read FIndent write SetIndent default 0;
    property Index: Integer read GetIndex;
    property Left: Integer read GetLeft write SetLeft;
    property ListView: TCustomListView read GetListView;
    property Owner: TListItems read FOwner;
    property OverlayIndex: TImageIndex index 1 read FOverlayIndex write SetImage;
    property Position: TPoint read GetPosition write SetPosition;
    property Selected: Boolean index 3 read GetState write SetState;
    property StateIndex: TImageIndex index 2 read FStateIndex write SetImage;
    property SubItems: TStrings read FSubItems write SetSubItems;
    property SubItemImages[Index: Integer]: Integer read GetSubItemImage write SetSubItemImage; 
    property Top: Integer read GetTop write SetTop;
  end;

{ TListItems }

  TListItems = class(TPersistent)
  public
    constructor Create(AOwner: TCustomListView);
    destructor Destroy; override;
    function Add: TListItem;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure EndUpdate;
    function IndexOf(Value: TListItem): Integer;
    function Insert(Index: Integer): TListItem;
    property Count: Integer read GetCount write SetCount;
    property Handle: HWND read GetHandle;
    property Item[Index: Integer]: TListItem read GetItem write SetItem; default;
    property Owner: TCustomListView read FOwner;
  end;

{ TWorkArea }

  TWorkArea = class(TCollectionItem)
  public
    constructor Create(Collection: TCollection); override;
    procedure SetDisplayName(const Value: string); override;
    function  GetDisplayName: string; override;
    property Rect: TRect read FRect write SetRect;
    property Color: TColor read FColor write SetColor;
  end;

{ TWorkAreas }

  TWorkAreas = class(TOwnedCollection)
  public
    function  Add: TWorkArea;
    procedure Delete(Index: Integer);
    function  Insert(Index: Integer): TWorkArea;
    property  Items[Index: Integer]: TWorkArea read GetItem write SetItem; default;
  end;

{ TIconOptions }

  TIconArrangement = (iaTop, iaLeft);

  TIconOptions = class(TPersistent)
  public
    constructor Create(AOwner: TCustomListView);
  published
    property Arrangement: TIconArrangement read FArrangement write SetArrangement default iaTop;
    property AutoArrange: Boolean read FAutoArrange write SetAutoArrange default False;
    property WrapText: Boolean read FWrapText write SetWrapText default True;
  end;

  TListArrangement = (arAlignBottom, arAlignLeft, arAlignRight,
    arAlignTop, arDefault, arSnapToGrid);
  TViewStyle = (vsIcon, vsSmallIcon, vsList, vsReport);
  TItemState = (isNone, isCut, isDropHilited, isFocused, isSelected, isActivating);
  TItemStates = set of TItemState;
  TItemChange = (ctText, ctImage, ctState);
  TItemFind = (ifData, ifPartialString, ifExactString, ifNearest);
  TSearchDirection = (sdLeft, sdRight, sdAbove, sdBelow, sdAll);
  TListHotTrackStyle = (htHandPoint, htUnderlineCold, htUnderlineHot);
  TListHotTrackStyles = set of TListHotTrackStyle;
  TItemRequests = (irText, irImage, irParam, irState, irIndent);
  TItemRequest = set of TItemRequests;

  TLVDeletedEvent = procedure(Sender: TObject; Item: TListItem) of object;
  TLVEditingEvent = procedure(Sender: TObject; Item: TListItem;
    var AllowEdit: Boolean) of object;
  TLVEditedEvent = procedure(Sender: TObject; Item: TListItem; var S: string) of object;
  TLVChangeEvent = procedure(Sender: TObject; Item: TListItem;
    Change: TItemChange) of object;
  TLVChangingEvent = procedure(Sender: TObject; Item: TListItem;
    Change: TItemChange; var AllowChange: Boolean) of object;
  TLVColumnClickEvent = procedure(Sender: TObject; Column: TListColumn) of object;
  TLVColumnRClickEvent = procedure(Sender: TObject; Column: TListColumn;
    Point: TPoint) of object;
  TLVCompareEvent = procedure(Sender: TObject; Item1, Item2: TListItem;
    Data: Integer; var Compare: Integer) of object;
  TLVNotifyEvent = procedure(Sender: TObject; Item: TListItem) of object;
  TLVSelectItemEvent = procedure(Sender: TObject; Item: TListItem;
    Selected: Boolean) of object;
  TLVDrawItemEvent = procedure(Sender: TCustomListView; Item: TListItem;
    Rect: TRect; State: TOwnerDrawState) of object;
  TLVCustomDrawEvent = procedure(Sender: TCustomListView; const ARect: TRect;
    var DefaultDraw: Boolean) of object;
  TLVCustomDrawItemEvent = procedure(Sender: TCustomListView; Item: TListItem;
    State: TCustomDrawState; var DefaultDraw: Boolean) of object;
  TLVCustomDrawSubItemEvent = procedure(Sender: TCustomListView; Item: TListItem;
    SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean) of object;
  TLVAdvancedCustomDrawEvent = procedure(Sender: TCustomListView; const ARect: TRect;
    Stage: TCustomDrawStage; var DefaultDraw: Boolean) of object;
  TLVAdvancedCustomDrawItemEvent = procedure(Sender: TCustomListView; Item: TListItem;
    State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean) of object;
  TLVAdvancedCustomDrawSubItemEvent = procedure(Sender: TCustomListView; Item: TListItem;
    SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage;
    var DefaultDraw: Boolean) of object;
  TLVOwnerDataEvent = procedure(Sender: TObject; Item: TListItem) of object;
  TLVOwnerDataFindEvent = procedure(Sender: TObject; Find: TItemFind;
    const FindString: string; const FindPosition: TPoint; FindData: Pointer;
    StartIndex: Integer; Direction: TSearchDirection; Wrap: Boolean;
    var Index: Integer) of object;
  TLVOwnerDataHintEvent = procedure(Sender: TObject; StartIndex, EndIndex: Integer) of object;
  TLVOwnerDataStateChangeEvent = procedure(Sender: TObject; StartIndex,
    EndIndex: Integer; OldState, NewState: TItemStates) of object;
  TLVSubItemImageEvent = procedure(Sender: TObject; Item: TListItem; SubItem: Integer;
    var ImageIndex: Integer) of object;
  TLVInfoTipEvent = procedure(Sender: TObject; Item: TListItem; var InfoTip: string) of object;

{ TCustomListView }

  TCustomListView = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AlphaSort: Boolean;
    procedure Arrange(Code: TListArrangement);
    function FindCaption(StartIndex: Integer; Value: string;
      Partial, Inclusive, Wrap: Boolean): TListItem;
    function FindData(StartIndex: Integer; Value: Pointer;
      Inclusive, Wrap: Boolean): TListItem;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function GetItemAt(X, Y: Integer): TListItem;
    function GetNearestItem(Point: TPoint;
      Direction: TSearchDirection): TListItem;
    function GetNextItem(StartItem: TListItem;
      Direction: TSearchDirection; States: TItemStates): TListItem;
    function GetSearchString: string;
    function IsEditing: Boolean;
    procedure Scroll(DX, DY: Integer);
    property Canvas: TCanvas read FCanvas;
    property Checkboxes: Boolean read FCheckboxes write SetCheckboxes default False;
    property Column[Index: Integer]: TListColumn read GetColumnFromIndex;
    property DropTarget: TListItem read GetDropTarget write SetDropTarget;
    property FlatScrollBars: Boolean read FFlatScrollBars write SetFlatScrollBars default False;
    property FullDrag: Boolean read FFullDrag write SetFullDrag default False;
    property GridLines: Boolean read FGridLines write SetGridLines default False;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property HotTrackStyles: TListHotTrackStyles read FHotTrackStyles write SetHotTrackStyles default [];
    property ItemFocused: TListItem read GetFocused write SetFocused;
    property RowSelect: Boolean read FRowSelect write SetRowSelect default False;
    property SelCount: Integer read GetSelCount;
    property Selected: TListItem read GetSelection write SetSelection;
    function CustomSort(SortProc: TLVCompare; lParam: Longint): Boolean;
    function StringWidth(S: string): Integer;
    procedure UpdateItems(FirstIndex, LastIndex: Integer);
    property TopItem: TListItem read GetTopItem;
    property ViewOrigin: TPoint read GetViewOrigin;
    property VisibleRowCount: Integer read GetVisibleRowCount;
    property BoundingRect: TRect read GetBoundingRect;
    property WorkAreas: TWorkAreas read FWorkAreas;
  end;

{ TListView }

  TListView = class(TCustomListView)
  published
    property Align;
    property AllocBy;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Checkboxes;
    property Color;
    property Columns;
    property ColumnClick;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property FlatScrollBars;
    property FullDrag;
    property GridLines;
    property HideSelection;
    property HotTrack;
    property HotTrackStyles;
    property HoverTime;
    property IconOptions;
    property Items;
    property LargeImages;
    property MultiSelect;
    property OwnerData;
    property OwnerDraw;
    property ReadOnly default False;
    property RowSelect;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowColumnHeaders;
    property ShowWorkAreas;
    property ShowHint;
    property SmallImages;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ViewStyle;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnColumnClick;
    property OnColumnDragged;
    property OnColumnRightClick;
    property OnCompare;
    property OnContextPopup;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDrawItem;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSubItemImage;
    property OnDragDrop;
    property OnDragOver;
    property OnInfoTip;
    property OnInsert;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TAnimate }

  TCommonAVI = (aviNone, aviFindFolder, aviFindFile, aviFindComputer, aviCopyFiles,
    aviCopyFile, aviRecycleFile, aviEmptyRecycle, aviDeleteFile);

  TAnimate = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    property FrameCount: Integer read FFrameCount;
    property FrameHeight: Integer read FFrameHeight;
    property FrameWidth: Integer read FFrameWidth;
    property Open: Boolean read FOpen write SetOpen;
    procedure Play(FromFrame, ToFrame: Word; Count: Integer);
    procedure Reset;
    procedure Seek(Frame: Smallint);
    procedure Stop;
    property ResHandle: THandle read FResHandle write SetResHandle;
    property ResId: Integer read FResId write SetResId;
    property ResName: string read FResName write SetResName;
  published
    property Align;
    property Active: Boolean read FActive write SetActive;
    property Anchors;
    property AutoSize default True;
    property BorderWidth;
    property Center: Boolean read FCenter write SetCenter default True;
    property Color;
    property CommonAVI: TCommonAVI read FCommonAVI write SetCommonAVI default aviNone;
    property Constraints;
    property FileName: string read FFileName write SetFileName;
    property ParentColor;
    property ParentShowHint;
    property Repetitions: Integer read FRepetitions write SetRepetitions default 0;
    property ShowHint;
    property StartFrame: Smallint read FStartFrame write SetStartFrame default 1;
    property StopFrame: Smallint read FStopFrame write SetStopFrame default 0;
    property Timers: Boolean read FTimers write SetTimers default False;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
  end;

{ TToolBar }

type
  TToolButtonStyle = (tbsButton, tbsCheck, tbsDropDown, tbsSeparator, tbsDivider);

  TToolButtonState = (tbsChecked, tbsPressed, tbsEnabled, tbsHidden,
    tbsIndeterminate, tbsWrap, tbsEllipses, tbsMarked);

  TToolBar = class;
  TToolButton = class;

  TToolButton = class(TGraphicControl)
  public
    constructor Create(AOwner: TComponent); override;
    function CheckMenuDropdown: Boolean; dynamic;
    procedure Click; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property Index: Integer read GetIndex;
  published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write FAllowAllUp default False;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Caption;
    property Down: Boolean read FDown write SetDown stored IsCheckedStored default False;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropdownMenu: TPopupMenu read FDropdownMenu write SetDropdownMenu;
    property Enabled;
    property Grouped: Boolean read FGrouped write SetGrouped default False;
    property Height stored False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex stored IsImageIndexStored default -1;
    property Indeterminate: Boolean read FIndeterminate write SetIndeterminate default False;
    property Marked: Boolean read FMarked write SetMarked default False;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property ParentShowHint;
    property PopupMenu;
    property Wrap: Boolean read FWrap write SetWrap default False;
    property ShowHint;
    property Style: TToolButtonStyle read FStyle write SetStyle default tbsButton;
    property Visible;
    property Width stored IsWidthStored;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TTBCustomDrawFlagsE = (tbNoEdges, tbHiliteHotTrack, tbNoOffset,
    tbNoMark, tbNoEtchedEffect);
  TTBCustomDrawFlags = set of TTBCustomDrawFlagsE;

  TTBCustomDrawEvent = procedure(Sender: TToolBar; const ARect: TRect;
    var DefaultDraw: Boolean) of object;
  TTBCustomDrawBtnEvent = procedure(Sender: TToolBar; Button: TToolButton;
    State: TCustomDrawState; var DefaultDraw: Boolean) of object;
  TTBAdvancedCustomDrawEvent = procedure(Sender: TToolBar; const ARect: TRect;
    Stage: TCustomDrawStage; var DefaultDraw: Boolean) of object;
  TTBAdvancedCustomDrawBtnEvent = procedure(Sender: TToolBar; Button: TToolButton;
    State: TCustomDrawState; Stage: TCustomDrawStage;
    var Flags: TTBCustomDrawFlags; var DefaultDraw: Boolean) of object;

  TToolBar = class(TToolWindow)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FlipChildren(AllLevels: Boolean); override;
    function TrackMenu(Button: TToolButton): Boolean; dynamic;
    property ButtonCount: Integer read GetButtonCount;
    property Buttons[Index: Integer]: TToolButton read GetButton;
    property Canvas: TCanvas read FCanvas;
    property RowCount: Integer read GetRowCount;
  published
    property Align default alTop;
    property Anchors;
    property AutoSize;
    property BorderWidth;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight default 22;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 23;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property DisabledImages: TCustomImageList read FDisabledImages write SetDisabledImages;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EdgeBorders default [ebTop];
    property EdgeInner;
    property EdgeOuter;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
    property Height default 32;
    property HotImages: TCustomImageList read FHotImages write SetHotImages;
    property Images: TCustomImageList read FImages write SetImages;
    property Indent: Integer read FIndent write SetIndent default 0;
    property List: Boolean read FList write SetList default False;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowCaptions: Boolean read FShowCaptions write SetShowCaptions default False;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
    property Visible;
    property Wrapable: Boolean read FWrapable write SetWrapable default True;
    property OnAdvancedCustomDraw: TTBAdvancedCustomDrawEvent
      read FOnAdvancedCustomDraw write FOnAdvancedCustomDraw;
    property OnAdvancedCustomDrawButton: TTBAdvancedCustomDrawBtnEvent
      read FOnAdvancedCustomDrawButton write FOnAdvancedCustomDrawButton;
    property OnClick;
    property OnContextPopup;
    property OnCustomDraw: TTBCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnCustomDrawButton: TTBCustomDrawBtnEvent read FOnCustomDrawButton
      write FOnCustomDrawButton;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

{ TCoolBar }

type
  TCoolBar = class;

  TCoolBand = class(TCollectionItem)
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Height: Integer read GetHeight;
  published
    property Bitmap: TBitmap read FBitmap write SetBitmap stored IsBitmapStored;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property Break: Boolean read FBreak write SetBreak default True;
    property Color: TColor read FColor write SetColor stored IsColorStored default clBtnFace;
    property Control: TWinControl read FControl write SetControl;
    property FixedBackground: Boolean read FFixedBackground write SetFixedBackground default True;
    property FixedSize: Boolean read FFixedSize write SetFixedSize default False;
    property HorizontalOnly: Boolean read FHorizontalOnly write SetHorizontalOnly default False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property MinHeight: Integer read FMinHeight write SetMinHeight default 25;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property ParentColor: Boolean read FParentColor write SetParentColor default True;
    property ParentBitmap: Boolean read FParentBitmap write SetParentBitmap default True;
    property Text: string read FText write SetText;
    property Visible: Boolean read GetVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth;
  end;

  TCoolBands = class(TCollection)
  public
    constructor Create(CoolBar: TCoolBar);
    function Add: TCoolBand;
    function FindBand(AControl: TControl): TCoolBand;
    property CoolBar: TCoolBar read FCoolBar;
    property Items[Index: Integer]: TCoolBand read GetItem write SetItem; default;
  end;

  TCoolBandMaximize = (bmNone, bmClick, bmDblClick);

  TCoolBar = class(TToolWindow)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FlipChildren(AllLevels: Boolean); override;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BandBorderStyle: TBorderStyle read FBandBorderStyle write SetBandBorderStyle default bsSingle;
    property BandMaximize: TCoolBandMaximize read FBandMaximize write SetBandMaximize default bmClick;
    property Bands: TCoolBands read FBands write SetBands;
    property BorderWidth;
    property Color;
    property Constraints;
    property Ctl3D;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EdgeBorders;
    property EdgeInner;
    property EdgeOuter;
    property Enabled;
    property FixedSize: Boolean read FFixedSize write SetFixedSize default False;
    property FixedOrder: Boolean read FFixedOrder write SetFixedOrder default False;
    property Font;
    property Images: TCustomImageList read FImages write SetImages;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property PopupMenu;
    property ShowHint;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property Vertical: Boolean read FVertical write SetVertical default False;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

{ Calendar common control support }

  TCommonCalendar = class;

  TMonthCalColors = class(TPersistent)
  public
    constructor Create(AOwner: TCommonCalendar);
    procedure Assign(Source: TPersistent); override;
  published
    property BackColor: TColor index 0 read FBackColor write SetColor default clWindow;
    property TextColor: TColor index 1 read FTextColor write SetColor default clWindowText;
    property TitleBackColor: TColor index 2 read FTitleBackColor write SetColor default clActiveCaption;
    property TitleTextColor: TColor index 3 read FTitleTextColor write SetColor default clWhite;
    property MonthBackColor: TColor index 4 read FMonthBackColor write SetColor default clWhite;
    property TrailingTextColor: TColor index 5 read FTrailingTextColor
      write SetColor default clInactiveCaptionText;
  end;

  TCalDayOfWeek = (dowMonday, dowTuesday, dowWednesday, dowThursday,
    dowFriday, dowSaturday, dowSunday, dowLocaleDefault);

  TOnGetMonthInfoEvent = procedure(Sender: TObject; Month: LongWord;
    var MonthBoldInfo: LongWord) of object;

  TCommonCalendar = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BoldDays(Days: array of LongWord; var MonthBoldInfo: LongWord);
  end;

{ TMonthCalendar }

  TMonthCalendar = class(TCommonCalendar)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BorderWidth;
    property BiDiMode;
    property CalColors;
    property Constraints;
    property MultiSelect;  // must be before date stuff
    property Date;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property EndDate;
    property FirstDayOfWeek;
    property Font;
    property ImeMode;
    property ImeName;
    property MaxDate;
    property MaxSelectRange;
    property MinDate;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowToday;
    property ShowTodayCircle;
    property TabOrder;
    property TabStop;
    property Visible;
    property WeekNumbers;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetMonthInfo;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TDateTimePicker }

  TDateTimeKind = (dtkDate, dtkTime);
  TDTDateMode = (dmComboBox, dmUpDown);
  TDTDateFormat = (dfShort, dfLong);
  TDTCalAlignment = (dtaLeft, dtaRight);

  TDTParseInputEvent = procedure(Sender: TObject; const UserString: string;
    var DateAndTime: TDateTime; var AllowChange: Boolean) of object;

  TDateTimeColors = TMonthCalColors;  // for backward compatibility

  TDateTimePicker = class(TCommonCalendar)
  public
    constructor Create(AOwner: TComponent); override;
    property DateTime;
    property DroppedDown: Boolean read FDroppedDown;
  published
    property Anchors;
    property BiDiMode;
    property CalAlignment: TDTCalAlignment read FCalAlignment write SetCalAlignment;
    property CalColors;
    property Constraints;
    // The Date, Time, ShowCheckbox, and Checked properties must be in this order:
    property Date;
    property Time: TTime read GetTime write SetTime;
    property ShowCheckbox: Boolean read FShowCheckbox write SetShowCheckbox default False;
    property Checked: Boolean read FChecked write SetChecked default True;
    property Color stored True default clWindow;
    property DateFormat: TDTDateFormat read FDateFormat write SetDateFormat;
    property DateMode: TDTDateMode read FDateMode write SetDateMode;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property Kind: TDateTimeKind read FKind write SetKind;
    property MaxDate;
    property MinDate;
    property ParseInput: Boolean read FParseInput write SetParseInput;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnContextPopup;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUserInput: TDTParseInputEvent read FOnUserInput write FOnUserInput;
  end;

{ TPageScroller }

  TPageScrollerOrientation = (soHorizontal, soVertical);
  TPageScrollerButton = (sbFirst, sbLast);
  TPageScrollerButtonState = (bsNormal, bsInvisible, bsGrayed, bsDepressed, bsHot);

  TPageScrollEvent = procedure (Sender: TObject; Shift: TShiftState; X, Y: Integer;
    Orientation: TPageScrollerOrientation; var Delta: Integer) of object;

  TPageScroller = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    function GetButtonState(Button: TPageScrollerButton): TPageScrollerButtonState;
  published
    property Align;
    property Anchors;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property BorderWidth;
    property ButtonSize: Integer read FButtonSize write SetButtonSize default 12;
    property Color;
    property Constraints;
    property Control: TWinControl read FControl write SetControl;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DragScroll: Boolean read FDragScroll write SetDragScroll default True;
    property Enabled;
    property Font;
    property Margin: Integer read FMargin write SetMargin default 0;
    property Orientation: TPageScrollerOrientation read FOrientation write SetOrientation default soHorizontal;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Position: Integer read FPosition write SetPosition default 0;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseWheel;
    property OnResize;
    property OnScroll: TPageScrollEvent read FOnScroll write FOnScroll;
    property OnStartDock;
    property OnStartDrag;
  end;

const
  ComCtlVersionIE3 = $00040046;
  ComCtlVersionIE4 = $00040047;
  ComCtlVersionIE401 = $00040048;
  ComCtlVersionIE5 = $00050050;

function GetComCtlVersion: Integer;
procedure CheckToolMenuDropdown(ToolButton: TToolButton);

implementation

end.
