{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnScript_Messages;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Controls 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, uPSComponent, uPSRuntime, uPSCompiler;

type
  (*----------------------------------------------------------------------------*)
  TPSImport_Messages = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_Messages(CL: TPSPascalCompiler);

{ run-time registration functions }

implementation

(* === compile-time registration functions === *)

procedure SIRegister_Messages(CL: TPSPascalCompiler);
begin
  CL.AddConstantN('WM_NULL', 'LongWord').SetUInt($0000);
  CL.AddConstantN('WM_CREATE', 'LongWord').SetUInt($0001);
  CL.AddConstantN('WM_DESTROY', 'LongWord').SetUInt($0002);
  CL.AddConstantN('WM_MOVE', 'LongWord').SetUInt($0003);
  CL.AddConstantN('WM_SIZE', 'LongWord').SetUInt($0005);
  CL.AddConstantN('WM_ACTIVATE', 'LongWord').SetUInt($0006);
  CL.AddConstantN('WM_SETFOCUS', 'LongWord').SetUInt($0007);
  CL.AddConstantN('WM_KILLFOCUS', 'LongWord').SetUInt($0008);
  CL.AddConstantN('WM_ENABLE', 'LongWord').SetUInt($000A);
  CL.AddConstantN('WM_SETREDRAW', 'LongWord').SetUInt($000B);
  CL.AddConstantN('WM_SETTEXT', 'LongWord').SetUInt($000C);
  CL.AddConstantN('WM_GETTEXT', 'LongWord').SetUInt($000D);
  CL.AddConstantN('WM_GETTEXTLENGTH', 'LongWord').SetUInt($000E);
  CL.AddConstantN('WM_PAINT', 'LongWord').SetUInt($000F);
  CL.AddConstantN('WM_CLOSE', 'LongWord').SetUInt($0010);
  CL.AddConstantN('WM_QUERYENDSESSION', 'LongWord').SetUInt($0011);
  CL.AddConstantN('WM_QUIT', 'LongWord').SetUInt($0012);
  CL.AddConstantN('WM_QUERYOPEN', 'LongWord').SetUInt($0013);
  CL.AddConstantN('WM_ERASEBKGND', 'LongWord').SetUInt($0014);
  CL.AddConstantN('WM_SYSCOLORCHANGE', 'LongWord').SetUInt($0015);
  CL.AddConstantN('WM_ENDSESSION', 'LongWord').SetUInt($0016);
  CL.AddConstantN('WM_SYSTEMERROR', 'LongWord').SetUInt($0017);
  CL.AddConstantN('WM_SHOWWINDOW', 'LongWord').SetUInt($0018);
  CL.AddConstantN('WM_CTLCOLOR', 'LongWord').SetUInt($0019);
  CL.AddConstantN('WM_WININICHANGE', 'LongWord').SetUInt($001A);
  CL.AddConstantN('WM_SETTINGCHANGE', 'LongWord').SetUInt(WM_WININICHANGE);
  CL.AddConstantN('WM_DEVMODECHANGE', 'LongWord').SetUInt($001B);
  CL.AddConstantN('WM_ACTIVATEAPP', 'LongWord').SetUInt($001C);
  CL.AddConstantN('WM_FONTCHANGE', 'LongWord').SetUInt($001D);
  CL.AddConstantN('WM_TIMECHANGE', 'LongWord').SetUInt($001E);
  CL.AddConstantN('WM_CANCELMODE', 'LongWord').SetUInt($001F);
  CL.AddConstantN('WM_SETCURSOR', 'LongWord').SetUInt($0020);
  CL.AddConstantN('WM_MOUSEACTIVATE', 'LongWord').SetUInt($0021);
  CL.AddConstantN('WM_CHILDACTIVATE', 'LongWord').SetUInt($0022);
  CL.AddConstantN('WM_QUEUESYNC', 'LongWord').SetUInt($0023);
  CL.AddConstantN('WM_GETMINMAXINFO', 'LongWord').SetUInt($0024);
  CL.AddConstantN('WM_PAINTICON', 'LongWord').SetUInt($0026);
  CL.AddConstantN('WM_ICONERASEBKGND', 'LongWord').SetUInt($0027);
  CL.AddConstantN('WM_NEXTDLGCTL', 'LongWord').SetUInt($0028);
  CL.AddConstantN('WM_SPOOLERSTATUS', 'LongWord').SetUInt($002A);
  CL.AddConstantN('WM_DRAWITEM', 'LongWord').SetUInt($002B);
  CL.AddConstantN('WM_MEASUREITEM', 'LongWord').SetUInt($002C);
  CL.AddConstantN('WM_DELETEITEM', 'LongWord').SetUInt($002D);
  CL.AddConstantN('WM_VKEYTOITEM', 'LongWord').SetUInt($002E);
  CL.AddConstantN('WM_CHARTOITEM', 'LongWord').SetUInt($002F);
  CL.AddConstantN('WM_SETFONT', 'LongWord').SetUInt($0030);
  CL.AddConstantN('WM_GETFONT', 'LongWord').SetUInt($0031);
  CL.AddConstantN('WM_SETHOTKEY', 'LongWord').SetUInt($0032);
  CL.AddConstantN('WM_GETHOTKEY', 'LongWord').SetUInt($0033);
  CL.AddConstantN('WM_QUERYDRAGICON', 'LongWord').SetUInt($0037);
  CL.AddConstantN('WM_COMPAREITEM', 'LongWord').SetUInt($0039);
  CL.AddConstantN('WM_GETOBJECT', 'LongWord').SetUInt($003D);
  CL.AddConstantN('WM_COMPACTING', 'LongWord').SetUInt($0041);
  CL.AddConstantN('WM_WINDOWPOSCHANGING', 'LongWord').SetUInt($0046);
  CL.AddConstantN('WM_WINDOWPOSCHANGED', 'LongWord').SetUInt($0047);
  CL.AddConstantN('WM_POWER', 'LongWord').SetUInt($0048);
  CL.AddConstantN('WM_COPYDATA', 'LongWord').SetUInt($004A);
  CL.AddConstantN('WM_CANCELJOURNAL', 'LongWord').SetUInt($004B);
  CL.AddConstantN('WM_NOTIFY', 'LongWord').SetUInt($004E);
  CL.AddConstantN('WM_INPUTLANGCHANGEREQUEST', 'LongWord').SetUInt($0050);
  CL.AddConstantN('WM_INPUTLANGCHANGE', 'LongWord').SetUInt($0051);
  CL.AddConstantN('WM_TCARD', 'LongWord').SetUInt($0052);
  CL.AddConstantN('WM_HELP', 'LongWord').SetUInt($0053);
  CL.AddConstantN('WM_USERCHANGED', 'LongWord').SetUInt($0054);
  CL.AddConstantN('WM_NOTIFYFORMAT', 'LongWord').SetUInt($0055);
  CL.AddConstantN('WM_CONTEXTMENU', 'LongWord').SetUInt($007B);
  CL.AddConstantN('WM_STYLECHANGING', 'LongWord').SetUInt($007C);
  CL.AddConstantN('WM_STYLECHANGED', 'LongWord').SetUInt($007D);
  CL.AddConstantN('WM_DISPLAYCHANGE', 'LongWord').SetUInt($007E);
  CL.AddConstantN('WM_GETICON', 'LongWord').SetUInt($007F);
  CL.AddConstantN('WM_SETICON', 'LongWord').SetUInt($0080);
  CL.AddConstantN('WM_NCCREATE', 'LongWord').SetUInt($0081);
  CL.AddConstantN('WM_NCDESTROY', 'LongWord').SetUInt($0082);
  CL.AddConstantN('WM_NCCALCSIZE', 'LongWord').SetUInt($0083);
  CL.AddConstantN('WM_NCHITTEST', 'LongWord').SetUInt($0084);
  CL.AddConstantN('WM_NCPAINT', 'LongWord').SetUInt($0085);
  CL.AddConstantN('WM_NCACTIVATE', 'LongWord').SetUInt($0086);
  CL.AddConstantN('WM_GETDLGCODE', 'LongWord').SetUInt($0087);
  CL.AddConstantN('WM_NCMOUSEMOVE', 'LongWord').SetUInt($00A0);
  CL.AddConstantN('WM_NCLBUTTONDOWN', 'LongWord').SetUInt($00A1);
  CL.AddConstantN('WM_NCLBUTTONUP', 'LongWord').SetUInt($00A2);
  CL.AddConstantN('WM_NCLBUTTONDBLCLK', 'LongWord').SetUInt($00A3);
  CL.AddConstantN('WM_NCRBUTTONDOWN', 'LongWord').SetUInt($00A4);
  CL.AddConstantN('WM_NCRBUTTONUP', 'LongWord').SetUInt($00A5);
  CL.AddConstantN('WM_NCRBUTTONDBLCLK', 'LongWord').SetUInt($00A6);
  CL.AddConstantN('WM_NCMBUTTONDOWN', 'LongWord').SetUInt($00A7);
  CL.AddConstantN('WM_NCMBUTTONUP', 'LongWord').SetUInt($00A8);
  CL.AddConstantN('WM_NCMBUTTONDBLCLK', 'LongWord').SetUInt($00A9);
  CL.AddConstantN('WM_NCXBUTTONDOWN', 'LongWord').SetUInt($00AB);
  CL.AddConstantN('WM_NCXBUTTONUP', 'LongWord').SetUInt($00AC);
  CL.AddConstantN('WM_NCXBUTTONDBLCLK', 'LongWord').SetUInt($00AD);
  CL.AddConstantN('WM_INPUT', 'LongWord').SetUInt($00FF);
  CL.AddConstantN('WM_KEYFIRST', 'LongWord').SetUInt($0100);
  CL.AddConstantN('WM_KEYDOWN', 'LongWord').SetUInt($0100);
  CL.AddConstantN('WM_KEYUP', 'LongWord').SetUInt($0101);
  CL.AddConstantN('WM_CHAR', 'LongWord').SetUInt($0102);
  CL.AddConstantN('WM_DEADCHAR', 'LongWord').SetUInt($0103);
  CL.AddConstantN('WM_SYSKEYDOWN', 'LongWord').SetUInt($0104);
  CL.AddConstantN('WM_SYSKEYUP', 'LongWord').SetUInt($0105);
  CL.AddConstantN('WM_SYSCHAR', 'LongWord').SetUInt($0106);
  CL.AddConstantN('WM_SYSDEADCHAR', 'LongWord').SetUInt($0107);
  CL.AddConstantN('WM_KEYLAST', 'LongWord').SetUInt($0108);
  CL.AddConstantN('WM_INITDIALOG', 'LongWord').SetUInt($0110);
  CL.AddConstantN('WM_COMMAND', 'LongWord').SetUInt($0111);
  CL.AddConstantN('WM_SYSCOMMAND', 'LongWord').SetUInt($0112);
  CL.AddConstantN('WM_TIMER', 'LongWord').SetUInt($0113);
  CL.AddConstantN('WM_HSCROLL', 'LongWord').SetUInt($0114);
  CL.AddConstantN('WM_VSCROLL', 'LongWord').SetUInt($0115);
  CL.AddConstantN('WM_INITMENU', 'LongWord').SetUInt($0116);
  CL.AddConstantN('WM_INITMENUPOPUP', 'LongWord').SetUInt($0117);
  CL.AddConstantN('WM_MENUSELECT', 'LongWord').SetUInt($011F);
  CL.AddConstantN('WM_MENUCHAR', 'LongWord').SetUInt($0120);
  CL.AddConstantN('WM_ENTERIDLE', 'LongWord').SetUInt($0121);
  CL.AddConstantN('WM_MENURBUTTONUP', 'LongWord').SetUInt($0122);
  CL.AddConstantN('WM_MENUDRAG', 'LongWord').SetUInt($0123);
  CL.AddConstantN('WM_MENUGETOBJECT', 'LongWord').SetUInt($0124);
  CL.AddConstantN('WM_UNINITMENUPOPUP', 'LongWord').SetUInt($0125);
  CL.AddConstantN('WM_MENUCOMMAND', 'LongWord').SetUInt($0126);
  CL.AddConstantN('WM_CHANGEUISTATE', 'LongWord').SetUInt($0127);
  CL.AddConstantN('WM_UPDATEUISTATE', 'LongWord').SetUInt($0128);
  CL.AddConstantN('WM_QUERYUISTATE', 'LongWord').SetUInt($0129);
  CL.AddConstantN('WM_CTLCOLORMSGBOX', 'LongWord').SetUInt($0132);
  CL.AddConstantN('WM_CTLCOLOREDIT', 'LongWord').SetUInt($0133);
  CL.AddConstantN('WM_CTLCOLORLISTBOX', 'LongWord').SetUInt($0134);
  CL.AddConstantN('WM_CTLCOLORBTN', 'LongWord').SetUInt($0135);
  CL.AddConstantN('WM_CTLCOLORDLG', 'LongWord').SetUInt($0136);
  CL.AddConstantN('WM_CTLCOLORSCROLLBAR', 'LongWord').SetUInt($0137);
  CL.AddConstantN('WM_CTLCOLORSTATIC', 'LongWord').SetUInt($0138);
  CL.AddConstantN('WM_MOUSEFIRST', 'LongWord').SetUInt($0200);
  CL.AddConstantN('WM_MOUSEMOVE', 'LongWord').SetUInt($0200);
  CL.AddConstantN('WM_LBUTTONDOWN', 'LongWord').SetUInt($0201);
  CL.AddConstantN('WM_LBUTTONUP', 'LongWord').SetUInt($0202);
  CL.AddConstantN('WM_LBUTTONDBLCLK', 'LongWord').SetUInt($0203);
  CL.AddConstantN('WM_RBUTTONDOWN', 'LongWord').SetUInt($0204);
  CL.AddConstantN('WM_RBUTTONUP', 'LongWord').SetUInt($0205);
  CL.AddConstantN('WM_RBUTTONDBLCLK', 'LongWord').SetUInt($0206);
  CL.AddConstantN('WM_MBUTTONDOWN', 'LongWord').SetUInt($0207);
  CL.AddConstantN('WM_MBUTTONUP', 'LongWord').SetUInt($0208);
  CL.AddConstantN('WM_MBUTTONDBLCLK', 'LongWord').SetUInt($0209);
  CL.AddConstantN('WM_MOUSEWHEEL', 'LongWord').SetUInt($020A);
  CL.AddConstantN('WM_MOUSELAST', 'LongWord').SetUInt($020A);
  CL.AddConstantN('WM_PARENTNOTIFY', 'LongWord').SetUInt($0210);
  CL.AddConstantN('WM_ENTERMENULOOP', 'LongWord').SetUInt($0211);
  CL.AddConstantN('WM_EXITMENULOOP', 'LongWord').SetUInt($0212);
  CL.AddConstantN('WM_NEXTMENU', 'LongWord').SetUInt($0213);
  CL.AddConstantN('WM_SIZING', 'LongWord').SetUInt(532);
  CL.AddConstantN('WM_CAPTURECHANGED', 'LongWord').SetUInt(533);
  CL.AddConstantN('WM_MOVING', 'LongWord').SetUInt(534);
  CL.AddConstantN('WM_POWERBROADCAST', 'LongWord').SetUInt(536);
  CL.AddConstantN('WM_DEVICECHANGE', 'LongWord').SetUInt(537);
  CL.AddConstantN('WM_IME_STARTCOMPOSITION', 'LongWord').SetUInt($010D);
  CL.AddConstantN('WM_IME_ENDCOMPOSITION', 'LongWord').SetUInt($010E);
  CL.AddConstantN('WM_IME_COMPOSITION', 'LongWord').SetUInt($010F);
  CL.AddConstantN('WM_IME_KEYLAST', 'LongWord').SetUInt($010F);
  CL.AddConstantN('WM_IME_SETCONTEXT', 'LongWord').SetUInt($0281);
  CL.AddConstantN('WM_IME_NOTIFY', 'LongWord').SetUInt($0282);
  CL.AddConstantN('WM_IME_CONTROL', 'LongWord').SetUInt($0283);
  CL.AddConstantN('WM_IME_COMPOSITIONFULL', 'LongWord').SetUInt($0284);
  CL.AddConstantN('WM_IME_SELECT', 'LongWord').SetUInt($0285);
  CL.AddConstantN('WM_IME_CHAR', 'LongWord').SetUInt($0286);
  CL.AddConstantN('WM_IME_REQUEST', 'LongWord').SetUInt($0288);
  CL.AddConstantN('WM_IME_KEYDOWN', 'LongWord').SetUInt($0290);
  CL.AddConstantN('WM_IME_KEYUP', 'LongWord').SetUInt($0291);
  CL.AddConstantN('WM_MDICREATE', 'LongWord').SetUInt($0220);
  CL.AddConstantN('WM_MDIDESTROY', 'LongWord').SetUInt($0221);
  CL.AddConstantN('WM_MDIACTIVATE', 'LongWord').SetUInt($0222);
  CL.AddConstantN('WM_MDIRESTORE', 'LongWord').SetUInt($0223);
  CL.AddConstantN('WM_MDINEXT', 'LongWord').SetUInt($0224);
  CL.AddConstantN('WM_MDIMAXIMIZE', 'LongWord').SetUInt($0225);
  CL.AddConstantN('WM_MDITILE', 'LongWord').SetUInt($0226);
  CL.AddConstantN('WM_MDICASCADE', 'LongWord').SetUInt($0227);
  CL.AddConstantN('WM_MDIICONARRANGE', 'LongWord').SetUInt($0228);
  CL.AddConstantN('WM_MDIGETACTIVE', 'LongWord').SetUInt($0229);
  CL.AddConstantN('WM_MDISETMENU', 'LongWord').SetUInt($0230);
  CL.AddConstantN('WM_ENTERSIZEMOVE', 'LongWord').SetUInt($0231);
  CL.AddConstantN('WM_EXITSIZEMOVE', 'LongWord').SetUInt($0232);
  CL.AddConstantN('WM_DROPFILES', 'LongWord').SetUInt($0233);
  CL.AddConstantN('WM_MDIREFRESHMENU', 'LongWord').SetUInt($0234);
  CL.AddConstantN('WM_MOUSEHOVER', 'LongWord').SetUInt($02A1);
  CL.AddConstantN('WM_MOUSELEAVE', 'LongWord').SetUInt($02A3);
  CL.AddConstantN('WM_NCMOUSEHOVER', 'LongWord').SetUInt($02A0);
  CL.AddConstantN('WM_NCMOUSELEAVE', 'LongWord').SetUInt($02A2);
  CL.AddConstantN('WM_WTSSESSION_CHANGE', 'LongWord').SetUInt($02B1);
  CL.AddConstantN('WM_TABLET_FIRST', 'LongWord').SetUInt($02C0);
  CL.AddConstantN('WM_TABLET_LAST', 'LongWord').SetUInt($02DF);
  CL.AddConstantN('WM_CUT', 'LongWord').SetUInt($0300);
  CL.AddConstantN('WM_COPY', 'LongWord').SetUInt($0301);
  CL.AddConstantN('WM_PASTE', 'LongWord').SetUInt($0302);
  CL.AddConstantN('WM_CLEAR', 'LongWord').SetUInt($0303);
  CL.AddConstantN('WM_UNDO', 'LongWord').SetUInt($0304);
  CL.AddConstantN('WM_RENDERFORMAT', 'LongWord').SetUInt($0305);
  CL.AddConstantN('WM_RENDERALLFORMATS', 'LongWord').SetUInt($0306);
  CL.AddConstantN('WM_DESTROYCLIPBOARD', 'LongWord').SetUInt($0307);
  CL.AddConstantN('WM_DRAWCLIPBOARD', 'LongWord').SetUInt($0308);
  CL.AddConstantN('WM_PAINTCLIPBOARD', 'LongWord').SetUInt($0309);
  CL.AddConstantN('WM_VSCROLLCLIPBOARD', 'LongWord').SetUInt($030A);
  CL.AddConstantN('WM_SIZECLIPBOARD', 'LongWord').SetUInt($030B);
  CL.AddConstantN('WM_ASKCBFORMATNAME', 'LongWord').SetUInt($030C);
  CL.AddConstantN('WM_CHANGECBCHAIN', 'LongWord').SetUInt($030D);
  CL.AddConstantN('WM_HSCROLLCLIPBOARD', 'LongWord').SetUInt($030E);
  CL.AddConstantN('WM_QUERYNEWPALETTE', 'LongWord').SetUInt($030F);
  CL.AddConstantN('WM_PALETTEISCHANGING', 'LongWord').SetUInt($0310);
  CL.AddConstantN('WM_PALETTECHANGED', 'LongWord').SetUInt($0311);
  CL.AddConstantN('WM_HOTKEY', 'LongWord').SetUInt($0312);
  CL.AddConstantN('WM_PRINT', 'LongWord').SetUInt(791);
  CL.AddConstantN('WM_PRINTCLIENT', 'LongWord').SetUInt(792);
  CL.AddConstantN('WM_APPCOMMAND', 'LongWord').SetUInt($0319);
  CL.AddConstantN('WM_THEMECHANGED', 'LongWord').SetUInt($031A);
  CL.AddConstantN('WM_HANDHELDFIRST', 'LongWord').SetUInt(856);
  CL.AddConstantN('WM_HANDHELDLAST', 'LongWord').SetUInt(863);
  CL.AddConstantN('WM_PENWINFIRST', 'LongWord').SetUInt($0380);
  CL.AddConstantN('WM_PENWINLAST', 'LongWord').SetUInt($038F);
  CL.AddConstantN('WM_COALESCE_FIRST', 'LongWord').SetUInt($0390);
  CL.AddConstantN('WM_COALESCE_LAST', 'LongWord').SetUInt($039F);
  CL.AddConstantN('WM_APP', 'LongWord').SetUInt($8000);
  CL.AddConstantN('WM_USER', 'LongWord').SetUInt($0400);
  CL.AddTypeS('TMessage', 'record Msg : Cardinal; WParam : Longint; LParam : Lo'
    + 'ngint; Result : Longint; end');
  CL.AddTypeS('TWMKey', 'record Msg : Cardinal; CharCode : Word; Unused : Word;'
    + ' KeyData : Longint; Result : Longint; end');
end;

(* === run-time registration functions === *)

{ TPSImport_Messages }

procedure TPSImport_Messages.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Messages(CompExec.Comp);
end;

procedure TPSImport_Messages.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin

end;

end.

