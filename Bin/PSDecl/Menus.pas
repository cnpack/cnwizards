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

unit Menus;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Menus 单元声明
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

uses Windows, SysUtils, Classes, Contnrs, Messages, Graphics, ImgList, ActnList;

type
  TMenuItem = class;
  TMenu = class;
  
  TMenuBreak = (mbNone, mbBreak, mbBarBreak);
  TMenuChangeEvent = procedure (Sender: TObject; Source: TMenuItem; Rebuild: Boolean) of object;
  TMenuDrawItemEvent = procedure (Sender: TObject; ACanvas: TCanvas;
    ARect: TRect; Selected: Boolean) of object;
  TAdvancedMenuDrawItemEvent = procedure (Sender: TObject; ACanvas: TCanvas;
    ARect: TRect; State: TOwnerDrawState) of object;
  TMenuMeasureItemEvent = procedure (Sender: TObject; ACanvas: TCanvas;
    var Width, Height: Integer) of object;
  TMenuItemAutoFlag = (maAutomatic, maManual, maParent);
  TMenuAutoFlag = TMenuItemAutoFlag; // maAutomatic..maManual;

{ TMenuItem }

  TMenuItem = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitiateAction; virtual;
    procedure Insert(Index: Integer; Item: TMenuItem);
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure Click; virtual;
    function Find(ACaption: string): TMenuItem;
    function IndexOf(Item: TMenuItem): Integer;
    function IsLine: Boolean;
    function GetImageList: TCustomImageList;
    function GetParentComponent: TComponent; override;
    function GetParentMenu: TMenu;
    function HasParent: Boolean; override;
    function NewTopLine: Integer;
    function NewBottomLine: Integer;
    function InsertNewLineBefore(AItem: TMenuItem): Integer;
    function InsertNewLineAfter(AItem: TMenuItem): Integer;
    procedure Add(Item: TMenuItem); overload;
    procedure AddEx(const AItems: array of TMenuItem); overload;
    procedure Remove(Item: TMenuItem);
    function RethinkHotkeys: Boolean;
    function RethinkLines: Boolean;
    property Command: Word read FCommand;
    property Handle: HMENU read GetHandle;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TMenuItem read GetItem; default;
    property MenuIndex: Integer read GetMenuIndex write SetMenuIndex;
    property Parent: TMenuItem read FParent;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property AutoHotkeys: TMenuItemAutoFlag read FAutoHotkeys write SetAutoHotkeys default maParent;
    property AutoLineReduction: TMenuItemAutoFlag read FAutoLineReduction write SetAutoLineReduction default maParent;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property Break: TMenuBreak read FBreak write SetBreak default mbNone;
    property Caption: string read FCaption write SetCaption stored IsCaptionStored;
    property Checked: Boolean read FChecked write SetChecked stored IsCheckedStored default False;
    property SubMenuImages: TCustomImageList read FSubMenuImages write SetSubMenuImages;
    property Default: Boolean read FDefault write SetDefault default False;
    property Enabled: Boolean read FEnabled write SetEnabled stored IsEnabledStored default True;
    property GroupIndex: Byte read FGroupIndex write SetGroupIndex default 0;
    property HelpContext: THelpContext read FHelpContext write FHelpContext stored IsHelpContextStored default 0;
    property Hint: string read FHint write FHint stored IsHintStored;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex stored IsImageIndexStored default -1;
    property RadioItem: Boolean read FRadioItem write SetRadioItem default False;
    property ShortCut: TShortCut read FShortCut write SetShortCut stored IsShortCutStored default 0;
    property Visible: Boolean read FVisible write SetVisible stored IsVisibleStored default True;
    property OnClick: TNotifyEvent read FOnClick write FOnClick stored IsOnClickStored;
    property OnDrawItem: TMenuDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnAdvancedDrawItem: TAdvancedMenuDrawItemEvent read FOnAdvancedDrawItem write FOnAdvancedDrawItem;
    property OnMeasureItem: TMenuMeasureItemEvent read FOnMeasureItem write FOnMeasureItem;
  end;

  TFindItemKind = (fkCommand, fkHandle, fkShortCut);

  TMenu = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function DispatchCommand(ACommand: Word): Boolean;
    function DispatchPopup(AHandle: HMENU): Boolean;
    function FindItem(Value: Integer; Kind: TFindItemKind): TMenuItem;
    function GetHelpContext(Value: Integer; ByCommand: Boolean): THelpContext;
    property Images: TCustomImageList read FImages write SetImages;
    function IsRightToLeft: Boolean;
    function IsShortCut(var Message: TWMKey): Boolean; dynamic;
    property AutoHotkeys: TMenuAutoFlag read GetAutoHotkeys write SetAutoHotkeys default maAutomatic;
    property AutoLineReduction: TMenuAutoFlag read GetAutoLineReduction write SetAutoLineReduction default maAutomatic;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property Handle: HMENU read GetHandle;
    property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw default False;
    property ParentBiDiMode: Boolean read FParentBiDiMode write SetParentBiDiMode default True;
    property WindowHandle: HWND read FWindowHandle write SetWindowHandle;
  published
    property Items: TMenuItem read FItems;
  end;

  TMainMenu = class(TMenu)
  published
    property AutoHotkeys;
    property AutoLineReduction;
    property AutoMerge: Boolean read FAutoMerge write SetAutoMerge default False;
    property BiDiMode;
    property Images;
    property OwnerDraw;
    property ParentBiDiMode;
    property OnChange;
  end;

  TPopupAlignment = (paLeft, paRight, paCenter);
  TTrackButton = (tbRightButton, tbLeftButton);
  TMenuAnimations = (maLeftToRight, maRightToLeft, maTopToBottom, maBottomToTop, maNone);
  TMenuAnimation = set of TMenuAnimations;

  TPopupMenu = class(TMenu)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer); virtual;
    property PopupComponent: TComponent read FPopupComponent write FPopupComponent;
  published
    property Alignment: TPopupAlignment read FAlignment write FAlignment default paLeft;
    property AutoHotkeys;
    property AutoLineReduction;
    property AutoPopup: Boolean read FAutoPopup write FAutoPopup default True;
    property BiDiMode;
    property HelpContext: THelpContext read GetHelpContext write SetHelpContext default 0;
    property Images;
    property MenuAnimation: TMenuAnimation read FMenuAnimation write FMenuAnimation default [];
    property OwnerDraw;
    property ParentBiDiMode;
    property TrackButton: TTrackButton read FTrackButton write FTrackButton default tbRightButton;
    property OnChange;
    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
  end;

function ShortCut(Key: Word; Shift: TShiftState): TShortCut;
procedure ShortCutToKey(ShortCut: TShortCut; var Key: Word; var Shift: TShiftState);
function ShortCutToText(ShortCut: TShortCut): string;
function TextToShortCut(Text: string): TShortCut;

function NewMenu(Owner: TComponent; const AName: string; Items: array of TMenuItem): TMainMenu;
function NewPopupMenu(Owner: TComponent; const AName: string;
  Alignment: TPopupAlignment; AutoPopup: Boolean; Items: array of TMenuitem): TPopupMenu;
function NewSubMenu(const ACaption: string; hCtx: Word;
  const AName: string; Items: array of TMenuItem; AEnabled: Boolean = True): TMenuItem;
function NewItem(const ACaption: string; AShortCut: TShortCut;
  AChecked, AEnabled: Boolean; AOnClick: TNotifyEvent; hCtx: Word;
  const AName: string): TMenuItem;
function NewLine: TMenuItem;

const
  cHotkeyPrefix = '&';
  cLineCaption = '-';
  cDialogSuffix = '...';

{ StripHotkey removes the & escape char that marks the hotkey character(s) in
  the string.  When the current locale is a Far East locale, this function also
  looks for and removes parens around the hotkey, common in Far East locales. }
function StripHotkey(const Text: string): string;

{ GetHotkey will return the last hotkey that StripHotkey would strip. }
function GetHotkey(const Text: string): string;

{ Similar to AnsiSameText but strips hotkeys before comparing }
function AnsiSameCaption(const Text1, Text2: string): Boolean;

implementation

end.

