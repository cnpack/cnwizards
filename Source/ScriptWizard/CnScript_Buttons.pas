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

unit CnScript_Buttons;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Buttons 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Buttons, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_Buttons = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TBitBtn(CL: TPSPascalCompiler);
procedure SIRegister_TSpeedButton(CL: TPSPascalCompiler);
procedure SIRegister_Buttons(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Buttons_Routines(S: TPSExec);
procedure RIRegister_TBitBtn(CL: TPSRuntimeClassImporter);
procedure RIRegister_TSpeedButton(CL: TPSRuntimeClassImporter);
procedure RIRegister_Buttons(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TBitBtn(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TButton', 'TBitBtn') do
  with CL.AddClass(CL.FindClass('TButton'), TBitBtn) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TSpeedButton(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TSpeedButton') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TSpeedButton) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_Buttons(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TButtonLayout', '( blGlyphLeft, blGlyphRight, blGlyphTop, blGlyp'
    + 'hBottom )');
  CL.AddTypeS('TButtonState', '( bsUp, bsDisabled, bsDown, bsExclusive )');
  CL.AddTypeS('TButtonStyle', '( bsAutoDetect, bsWin31, bsNew )');
  CL.AddTypeS('TNumGlyphs', 'Integer');
  SIRegister_TSpeedButton(CL);
  CL.AddTypeS('TBitBtnKind', '( bkCustom, bkOK, bkCancel, bkHelp, bkYes, bkNo, '
    + 'bkClose, bkAbort, bkRetry, bkIgnore, bkAll )');
  SIRegister_TBitBtn(CL);
  CL.AddDelphiFunction('Function DrawButtonFace( Canvas : TCanvas; const Client : TRect; BevelWidth : Integer; Style : TButtonStyle; IsRounded, IsDown, IsFocused : Boolean) : TRect');
end;

procedure RIRegister_Buttons_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@DrawButtonFace, 'DrawButtonFace', cdRegister);
end;

procedure RIRegister_TBitBtn(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBitBtn) do
  begin
  end;
end;

procedure RIRegister_TSpeedButton(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TSpeedButton) do
  begin
  end;
end;

procedure RIRegister_Buttons(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TSpeedButton(CL);
  RIRegister_TBitBtn(CL);
end;

{ TPSImport_Buttons }

procedure TPSImport_Buttons.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Buttons(CompExec.Comp);
end;

procedure TPSImport_Buttons.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Buttons(ri);
  RIRegister_Buttons_Routines(CompExec.Exec); // comment it if no routines
end;

end.

