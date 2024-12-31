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

unit CnScript_Clipbrd;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Clipbrd 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Clipbrd, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_Clipbrd = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TClipboard(CL: TPSPascalCompiler);
procedure SIRegister_Clipbrd(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Clipbrd_Routines(S: TPSExec);
procedure RIRegister_TClipboard(CL: TPSRuntimeClassImporter);
procedure RIRegister_Clipbrd(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TClipboard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TClipboard') do
  with CL.AddClass(CL.FindClass('TPersistent'), TClipboard) do
  begin
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Close');
    RegisterMethod('Function GetComponent( Owner, Parent : TComponent) : TComponent');
    RegisterMethod('Function GetAsHandle( Format : Word) : THandle');
    RegisterMethod('Function GetTextBuf( Buffer : PChar; BufSize : Integer) : Integer');
    RegisterMethod('Function HasFormat( Format : Word) : Boolean');
    RegisterMethod('Procedure Open');
    RegisterMethod('Procedure SetComponent( Component : TComponent)');
    RegisterMethod('Procedure SetAsHandle( Format : Word; Value : THandle)');
    RegisterMethod('Procedure SetTextBuf( Buffer : PChar)');
    RegisterProperty('AsText', 'string', iptrw);
    RegisterProperty('FormatCount', 'Integer', iptr);
    RegisterProperty('Formats', 'Word Integer', iptr);
  end;
end;

procedure SIRegister_Clipbrd(CL: TPSPascalCompiler);
begin
  SIRegister_TClipboard(CL);
  CL.AddDelphiFunction('Function Clipboard : TClipboard');
end;

(* === run-time registration functions === *)

procedure TClipboardFormats_R(Self: TClipboard; var T: Word; const t1: Integer);
begin
  T := Self.Formats[t1];
end;

procedure TClipboardFormatCount_R(Self: TClipboard; var T: Integer);
begin
  T := Self.FormatCount;
end;

procedure TClipboardAsText_W(Self: TClipboard; const T: string);
begin
  Self.AsText := T;
end;

procedure TClipboardAsText_R(Self: TClipboard; var T: string);
begin
  T := Self.AsText;
end;

procedure RIRegister_Clipbrd_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Clipboard, 'Clipboard', cdRegister);
end;

procedure RIRegister_TClipboard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TClipboard) do
  begin
    RegisterMethod(@TClipboard.Clear, 'Clear');
    RegisterMethod(@TClipboard.Close, 'Close');
    RegisterMethod(@TClipboard.GetComponent, 'GetComponent');
    RegisterMethod(@TClipboard.GetAsHandle, 'GetAsHandle');
    RegisterMethod(@TClipboard.GetTextBuf, 'GetTextBuf');
    RegisterMethod(@TClipboard.HasFormat, 'HasFormat');
    RegisterMethod(@TClipboard.Open, 'Open');
    RegisterMethod(@TClipboard.SetComponent, 'SetComponent');
    RegisterMethod(@TClipboard.SetAsHandle, 'SetAsHandle');
    RegisterMethod(@TClipboard.SetTextBuf, 'SetTextBuf');
    RegisterPropertyHelper(@TClipboardAsText_R, @TClipboardAsText_W, 'AsText');
    RegisterPropertyHelper(@TClipboardFormatCount_R, nil, 'FormatCount');
    RegisterPropertyHelper(@TClipboardFormats_R, nil, 'Formats');
  end;
end;

procedure RIRegister_Clipbrd(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TClipboard(CL);
end;

{ TPSImport_Clipbrd }

procedure TPSImport_Clipbrd.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Clipbrd(CompExec.Comp);
end;

procedure TPSImport_Clipbrd.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Clipbrd(ri);
  RIRegister_Clipbrd_Routines(CompExec.Exec); // comment it if no routines
end;

end.



