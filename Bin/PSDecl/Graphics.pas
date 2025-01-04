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

unit Graphics;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Graphics 单元声明
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

uses Windows, SysUtils, Classes;

type
  PColor = Pointer;
  TColor = Integer;

const
  clScrollBar = TColor(COLOR_SCROLLBAR or $80000000);
  clBackground = TColor(COLOR_BACKGROUND or $80000000);
  clActiveCaption = TColor(COLOR_ACTIVECAPTION or $80000000);
  clInactiveCaption = TColor(COLOR_INACTIVECAPTION or $80000000);
  clMenu = TColor(COLOR_MENU or $80000000);
  clWindow = TColor(COLOR_WINDOW or $80000000);
  clWindowFrame = TColor(COLOR_WINDOWFRAME or $80000000);
  clMenuText = TColor(COLOR_MENUTEXT or $80000000);
  clWindowText = TColor(COLOR_WINDOWTEXT or $80000000);
  clCaptionText = TColor(COLOR_CAPTIONTEXT or $80000000);
  clActiveBorder = TColor(COLOR_ACTIVEBORDER or $80000000);
  clInactiveBorder = TColor(COLOR_INACTIVEBORDER or $80000000);
  clAppWorkSpace = TColor(COLOR_APPWORKSPACE or $80000000);
  clHighlight = TColor(COLOR_HIGHLIGHT or $80000000);
  clHighlightText = TColor(COLOR_HIGHLIGHTTEXT or $80000000);
  clBtnFace = TColor(COLOR_BTNFACE or $80000000);
  clBtnShadow = TColor(COLOR_BTNSHADOW or $80000000);
  clGrayText = TColor(COLOR_GRAYTEXT or $80000000);
  clBtnText = TColor(COLOR_BTNTEXT or $80000000);
  clInactiveCaptionText = TColor(COLOR_INACTIVECAPTIONTEXT or $80000000);
  clBtnHighlight = TColor(COLOR_BTNHIGHLIGHT or $80000000);
  cl3DDkShadow = TColor(COLOR_3DDKSHADOW or $80000000);
  cl3DLight = TColor(COLOR_3DLIGHT or $80000000);
  clInfoText = TColor(COLOR_INFOTEXT or $80000000);
  clInfoBk = TColor(COLOR_INFOBK or $80000000);

  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clWhite = TColor($FFFFFF);
  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);

type
  TGraphic = class;
  TBitmap = class;
  TIcon = class;
  TMetafile = class;

  TFontPitch = (fpDefault, fpVariable, fpFixed);
  TFontName = type string;
  TFontCharset = Byte;

  TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
  TFontStyles = set of TFontStyle;
  TFontStylesBase = set of TFontStyle;

  TPenStyle = (psSolid, psDash, psDot, psDashDot, psDashDotDot, psClear,
    psInsideFrame);
  TPenMode = (pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy,
    pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge,
    pmNotMerge, pmMask, pmNotMask, pmXor, pmNotXor);

  TBrushStyle = (bsSolid, bsClear, bsHorizontal, bsVertical,
    bsFDiagonal, bsBDiagonal, bsCross, bsDiagCross);

  TGraphicsObject = class(TPersistent)
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TFont = class(TGraphicsObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Handle: HFont read GetHandle write SetHandle;
    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch;
  published
    property Charset: TFontCharset read GetCharset write SetCharset;
    property Color: TColor read FColor write SetColor;
    property Height: Integer read GetHeight write SetHeight;
    property Name: TFontName read GetName write SetName;
    property Pitch: TFontPitch read GetPitch write SetPitch default fpDefault;
    property Size: Integer read GetSize write SetSize stored False;
    property Style: TFontStyles read GetStyle write SetStyle;
  end;

  TPen = class(TGraphicsObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Handle: HPen read GetHandle write SetHandle;
  published
    property Color: TColor read GetColor write SetColor default clBlack;
    property Mode: TPenMode read FMode write SetMode default pmCopy;
    property Style: TPenStyle read GetStyle write SetStyle default psSolid;
    property Width: Integer read GetWidth write SetWidth default 1;
  end;

  TBrush = class(TGraphicsObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property Handle: HBrush read GetHandle write SetHandle;
  published
    property Color: TColor read GetColor write SetColor default clWhite;
    property Style: TBrushStyle read GetStyle write SetStyle default bsSolid;
  end;

  TFillStyle = (fsSurface, fsBorder);
  TFillMode = (fmAlternate, fmWinding);

  TCopyMode = Longint;

  TCanvasStates = (csHandleValid, csFontValid, csPenValid, csBrushValid);
  TCanvasState = set of TCanvasStates;
  TCanvasOrientation = (coLeftToRight, coRightToLeft);

  TCanvas = class(TPersistent)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure BrushCopy(const Dest: TRect; Bitmap: TBitmap;
      const Source: TRect; Color: TColor);
    procedure Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure CopyRect(const Dest: TRect; Canvas: TCanvas;
      const Source: TRect);
    procedure Draw(X, Y: Integer; Graphic: TGraphic);
    procedure DrawFocusRect(const Rect: TRect);
    procedure Ellipse(X1, Y1, X2, Y2: Integer); overload;
    procedure FillRect(const Rect: TRect);
    procedure FloodFill(X, Y: Integer; Color: TColor; FillStyle: TFillStyle);
    procedure FrameRect(const Rect: TRect);
    procedure LineTo(X, Y: Integer);
    procedure Lock;
    procedure MoveTo(X, Y: Integer);
    procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure Polygon(const Points: array of TPoint);
    procedure Polyline(const Points: array of TPoint);
    procedure PolyBezier(const Points: array of TPoint);
    procedure PolyBezierTo(const Points: array of TPoint);
    procedure Rectangle(X1, Y1, X2, Y2: Integer); overload;
    procedure Refresh;
    procedure RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
    procedure StretchDraw(const Rect: TRect; Graphic: TGraphic);
    function TextExtent(const Text: string): TSize;
    function TextHeight(const Text: string): Integer;
    procedure TextOut(X, Y: Integer; const Text: string);
    procedure TextRect(Rect: TRect; X, Y: Integer; const Text: string);
    function TextWidth(const Text: string): Integer;
    function TryLock: Boolean;
    procedure Unlock;
    property ClipRect: TRect read GetClipRect;
    property Handle: HDC read GetHandle write SetHandle;
    property LockCount: Integer read FLockCount;
    property CanvasOrientation: TCanvasOrientation read GetCanvasOrientation;
    property PenPos: TPoint read GetPenPos write SetPenPos;
    property Pixels[X, Y: Integer]: TColor read GetPixel write SetPixel;
    property TextFlags: Longint read FTextFlags write FTextFlags;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  published
    property Brush: TBrush read FBrush write SetBrush;
    property CopyMode: TCopyMode read FCopyMode write FCopyMode default cmSrcCopy;
    property Font: TFont read FFont write SetFont;
    property Pen: TPen read FPen write SetPen;
  end;

  TGraphic = class(TPersistent)
  public
    constructor Create; virtual;
    procedure LoadFromFile(const Filename: string); virtual;
    procedure SaveToFile(const Filename: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); virtual; abstract;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); virtual; abstract;
    property Empty: Boolean read GetEmpty;
    property Height: Integer read GetHeight write SetHeight;
    property Modified: Boolean read FModified write SetModified;
    property Palette: HPALETTE read GetPalette write SetPalette;
    property PaletteModified: Boolean read FPaletteModified write FPaletteModified;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property Width: Integer read GetWidth write SetWidth;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TPicture = class(TPersistent)
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const Filename: string);
    procedure SaveToFile(const Filename: string);
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE);
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE);
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property Graphic: TGraphic read FGraphic write SetGraphic;
    property Height: Integer read GetHeight;
    property Icon: TIcon read GetIcon write SetIcon;
    property Metafile: TMetafile read GetMetafile write SetMetafile;
    property Width: Integer read GetWidth;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TBitmapHandleType = (bmDIB, bmDDB);
  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);
  TTransparentMode = (tmAuto, tmFixed);

  TBitmap = class(TGraphic)
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure FreeImage;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromResourceName(Instance: THandle; const ResName: String);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer);
    procedure Mask(TransparentColor: TColor);
    function ReleaseHandle: HBITMAP;
    function ReleaseMaskHandle: HBITMAP;
    function ReleasePalette: HPALETTE;
    procedure SaveToClipboardFormat(var Format: Word; var Data: THandle;
      var APalette: HPALETTE); override;
    procedure SaveToStream(Stream: TStream); override;
    property Canvas: TCanvas read GetCanvas;
    property Handle: HBITMAP read GetHandle write SetHandle;
    property HandleType: TBitmapHandleType read GetHandleType write SetHandleType;
    property IgnorePalette: Boolean read FIgnorePalette write FIgnorePalette;
    property MaskHandle: HBITMAP read GetMaskHandle write SetMaskHandle;
    property Monochrome: Boolean read GetMonochrome write SetMonochrome;
    property PixelFormat: TPixelFormat read GetPixelFormat write SetPixelFormat;
    property ScanLine[Row: Integer]: Pointer read GetScanLine;
    property TransparentColor: TColor read GetTransparentColor
      write SetTransparentColor stored TransparentColorStored;
    property TransparentMode: TTransparentMode read FTransparentMode
      write SetTransparentMode default tmAuto;
  end;

  TIcon = class(TGraphic)
  public
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure LoadFromStream(Stream: TStream); override;
    function ReleaseHandle: HICON;
    procedure SaveToClipboardFormat(var Format: Word; var Data: THandle;
      var APalette: HPALETTE); override;
    procedure SaveToStream(Stream: TStream); override;
    property Handle: HICON read GetHandle write SetHandle;
  end;

function ColorToRGB(Color: TColor): Longint;
function ColorToString(Color: TColor): string;
function StringToColor(const S: string): TColor;
function ColorToIdent(Color: Longint; var Ident: string): Boolean;
function IdentToColor(const Ident: string; var Color: Longint): Boolean;
function CharsetToIdent(Charset: Longint; var Ident: string): Boolean;
function IdentToCharset(const Ident: string; var Charset: Longint): Boolean;

implementation

end.
