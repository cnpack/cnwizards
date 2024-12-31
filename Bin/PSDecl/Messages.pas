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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit Messages;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Messages 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses Windows;

{ Window Messages }

const
  WM_NULL             = $0000;
  WM_CREATE           = $0001;
  WM_DESTROY          = $0002;
  WM_MOVE             = $0003;
  WM_SIZE             = $0005;
  WM_ACTIVATE         = $0006;
  WM_SETFOCUS         = $0007;
  WM_KILLFOCUS        = $0008;
  WM_ENABLE           = $000A;
  WM_SETREDRAW        = $000B;
  WM_SETTEXT          = $000C;
  WM_GETTEXT          = $000D;
  WM_GETTEXTLENGTH    = $000E;
  WM_PAINT            = $000F;
  WM_CLOSE            = $0010;
  WM_QUERYENDSESSION  = $0011;
  WM_QUIT             = $0012;
  WM_QUERYOPEN        = $0013;
  WM_ERASEBKGND       = $0014;
  WM_SYSCOLORCHANGE   = $0015;
  WM_ENDSESSION       = $0016;
  WM_SYSTEMERROR      = $0017;
  WM_SHOWWINDOW       = $0018;
  WM_CTLCOLOR         = $0019;
  WM_WININICHANGE     = $001A;
  WM_SETTINGCHANGE = WM_WININICHANGE;
  WM_DEVMODECHANGE    = $001B;
  WM_ACTIVATEAPP      = $001C;
  WM_FONTCHANGE       = $001D;
  WM_TIMECHANGE       = $001E;
  WM_CANCELMODE       = $001F;
  WM_SETCURSOR        = $0020;
  WM_MOUSEACTIVATE    = $0021;
  WM_CHILDACTIVATE    = $0022;
  WM_QUEUESYNC        = $0023;
  WM_GETMINMAXINFO    = $0024;
  WM_PAINTICON        = $0026;
  WM_ICONERASEBKGND   = $0027;
  WM_NEXTDLGCTL       = $0028;
  WM_SPOOLERSTATUS    = $002A;
  WM_DRAWITEM         = $002B;
  WM_MEASUREITEM      = $002C;
  WM_DELETEITEM       = $002D;
  WM_VKEYTOITEM       = $002E;
  WM_CHARTOITEM       = $002F;
  WM_SETFONT          = $0030;
  WM_GETFONT          = $0031;
  WM_SETHOTKEY        = $0032;
  WM_GETHOTKEY        = $0033;
  WM_QUERYDRAGICON    = $0037;
  WM_COMPAREITEM      = $0039;
  WM_GETOBJECT        = $003D;
  WM_COMPACTING       = $0041;

  WM_WINDOWPOSCHANGING = $0046;
  WM_WINDOWPOSCHANGED = $0047;
  WM_POWER            = $0048;

  WM_COPYDATA         = $004A;
  WM_CANCELJOURNAL    = $004B;
  WM_NOTIFY           = $004E;
  WM_INPUTLANGCHANGEREQUEST = $0050;
  WM_INPUTLANGCHANGE  = $0051;
  WM_TCARD            = $0052;
  WM_HELP             = $0053;
  WM_USERCHANGED      = $0054;
  WM_NOTIFYFORMAT     = $0055;

  WM_CONTEXTMENU      = $007B;
  WM_STYLECHANGING    = $007C;
  WM_STYLECHANGED     = $007D;
  WM_DISPLAYCHANGE    = $007E;
  WM_GETICON          = $007F;
  WM_SETICON          = $0080;

  WM_NCCREATE         = $0081;
  WM_NCDESTROY        = $0082;
  WM_NCCALCSIZE       = $0083;
  WM_NCHITTEST        = $0084;
  WM_NCPAINT          = $0085;
  WM_NCACTIVATE       = $0086;
  WM_GETDLGCODE       = $0087;
  WM_NCMOUSEMOVE      = $00A0;
  WM_NCLBUTTONDOWN    = $00A1;
  WM_NCLBUTTONUP      = $00A2;
  WM_NCLBUTTONDBLCLK  = $00A3;
  WM_NCRBUTTONDOWN    = $00A4;
  WM_NCRBUTTONUP      = $00A5;
  WM_NCRBUTTONDBLCLK  = $00A6;
  WM_NCMBUTTONDOWN    = $00A7;
  WM_NCMBUTTONUP      = $00A8;
  WM_NCMBUTTONDBLCLK  = $00A9;

  WM_NCXBUTTONDOWN = $00AB;
  WM_NCXBUTTONUP = $00AC;
  WM_NCXBUTTONDBLCLK = $00AD;
  WM_INPUT = $00FF;

  WM_KEYFIRST         = $0100;
  WM_KEYDOWN          = $0100;
  WM_KEYUP            = $0101;
  WM_CHAR             = $0102;
  WM_DEADCHAR         = $0103;
  WM_SYSKEYDOWN       = $0104;
  WM_SYSKEYUP         = $0105;
  WM_SYSCHAR          = $0106;
  WM_SYSDEADCHAR      = $0107;
  WM_KEYLAST          = $0108;

  WM_INITDIALOG       = $0110;
  WM_COMMAND          = $0111;
  WM_SYSCOMMAND       = $0112;
  WM_TIMER            = $0113;
  WM_HSCROLL          = $0114;
  WM_VSCROLL          = $0115;
  WM_INITMENU         = $0116;
  WM_INITMENUPOPUP    = $0117;
  WM_MENUSELECT       = $011F;
  WM_MENUCHAR         = $0120;
  WM_ENTERIDLE        = $0121;

  WM_MENURBUTTONUP    = $0122;
  WM_MENUDRAG         = $0123;
  WM_MENUGETOBJECT    = $0124;
  WM_UNINITMENUPOPUP  = $0125;
  WM_MENUCOMMAND      = $0126;

  WM_CHANGEUISTATE    = $0127;
  WM_UPDATEUISTATE    = $0128;
  WM_QUERYUISTATE     = $0129;

  WM_CTLCOLORMSGBOX   = $0132;
  WM_CTLCOLOREDIT     = $0133;
  WM_CTLCOLORLISTBOX  = $0134;
  WM_CTLCOLORBTN      = $0135;
  WM_CTLCOLORDLG      = $0136;
  WM_CTLCOLORSCROLLBAR= $0137;
  WM_CTLCOLORSTATIC   = $0138;

  WM_MOUSEFIRST       = $0200;
  WM_MOUSEMOVE        = $0200;
  WM_LBUTTONDOWN      = $0201;
  WM_LBUTTONUP        = $0202;
  WM_LBUTTONDBLCLK    = $0203;
  WM_RBUTTONDOWN      = $0204;
  WM_RBUTTONUP        = $0205;
  WM_RBUTTONDBLCLK    = $0206;
  WM_MBUTTONDOWN      = $0207;
  WM_MBUTTONUP        = $0208;
  WM_MBUTTONDBLCLK    = $0209;
  WM_MOUSEWHEEL       = $020A;
  WM_MOUSELAST        = $020A;

  WM_PARENTNOTIFY     = $0210;
  WM_ENTERMENULOOP    = $0211;
  WM_EXITMENULOOP     = $0212;
  WM_NEXTMENU         = $0213;

  WM_SIZING           = 532;
  WM_CAPTURECHANGED   = 533;
  WM_MOVING           = 534;
  WM_POWERBROADCAST   = 536;
  WM_DEVICECHANGE     = 537;

  WM_IME_STARTCOMPOSITION        = $010D;
  WM_IME_ENDCOMPOSITION          = $010E;
  WM_IME_COMPOSITION             = $010F;
  WM_IME_KEYLAST                 = $010F;

  WM_IME_SETCONTEXT              = $0281;
  WM_IME_NOTIFY                  = $0282;
  WM_IME_CONTROL                 = $0283;
  WM_IME_COMPOSITIONFULL         = $0284;
  WM_IME_SELECT                  = $0285;
  WM_IME_CHAR                    = $0286;
  WM_IME_REQUEST                 = $0288;

  WM_IME_KEYDOWN                 = $0290;
  WM_IME_KEYUP                   = $0291;

  WM_MDICREATE        = $0220;
  WM_MDIDESTROY       = $0221;
  WM_MDIACTIVATE      = $0222;
  WM_MDIRESTORE       = $0223;
  WM_MDINEXT          = $0224;
  WM_MDIMAXIMIZE      = $0225;
  WM_MDITILE          = $0226;
  WM_MDICASCADE       = $0227;
  WM_MDIICONARRANGE   = $0228;
  WM_MDIGETACTIVE     = $0229;
  WM_MDISETMENU       = $0230;

  WM_ENTERSIZEMOVE    = $0231;
  WM_EXITSIZEMOVE     = $0232;
  WM_DROPFILES        = $0233;
  WM_MDIREFRESHMENU   = $0234;

  WM_MOUSEHOVER       = $02A1;
  WM_MOUSELEAVE       = $02A3;

  WM_NCMOUSEHOVER     = $02A0;
  WM_NCMOUSELEAVE     = $02A2;
  WM_WTSSESSION_CHANGE = $02B1;

  WM_TABLET_FIRST     = $02C0;
  WM_TABLET_LAST      = $02DF;

  WM_CUT              = $0300;
  WM_COPY             = $0301;
  WM_PASTE            = $0302;
  WM_CLEAR            = $0303;
  WM_UNDO             = $0304;
  WM_RENDERFORMAT     = $0305;
  WM_RENDERALLFORMATS = $0306;
  WM_DESTROYCLIPBOARD = $0307;
  WM_DRAWCLIPBOARD    = $0308;
  WM_PAINTCLIPBOARD   = $0309;
  WM_VSCROLLCLIPBOARD = $030A;
  WM_SIZECLIPBOARD    = $030B;
  WM_ASKCBFORMATNAME  = $030C;
  WM_CHANGECBCHAIN    = $030D;
  WM_HSCROLLCLIPBOARD = $030E;
  WM_QUERYNEWPALETTE  = $030F;
  WM_PALETTEISCHANGING= $0310;
  WM_PALETTECHANGED   = $0311;
  WM_HOTKEY           = $0312;

  WM_PRINT            = 791;
  WM_PRINTCLIENT      = 792;
  WM_APPCOMMAND       = $0319;
  WM_THEMECHANGED     = $031A;

  WM_HANDHELDFIRST    = 856;
  WM_HANDHELDLAST     = 863;

  WM_PENWINFIRST      = $0380;
  WM_PENWINLAST       = $038F;

  WM_COALESCE_FIRST   = $0390;
  WM_COALESCE_LAST    = $039F;

  WM_APP = $8000;

{ NOTE: All Message Numbers below 0x0400 are RESERVED }

{ Private Window Messages Start Here }

  WM_USER             = $0400;

type

  TMessage = record
    Msg: Cardinal;
    WParam: Longint;
    LParam: Longint;
    Result: Longint;
  end;

  TWMKey = record
    Msg: Cardinal;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: Longint;
  end;

implementation

end.
