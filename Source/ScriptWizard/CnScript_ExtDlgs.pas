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

unit CnScript_ExtDlgs;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ExtDlgs 注册类
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
  Windows, SysUtils, Classes, Dialogs, ExtDlgs, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_ExtDlgs = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TSavePictureDialog(CL: TPSPascalCompiler);
procedure SIRegister_TOpenPictureDialog(CL: TPSPascalCompiler);
procedure SIRegister_ExtDlgs(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TSavePictureDialog(CL: TPSRuntimeClassImporter);
procedure RIRegister_TOpenPictureDialog(CL: TPSRuntimeClassImporter);
procedure RIRegister_ExtDlgs(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TSavePictureDialog(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOpenPictureDialog', 'TSavePictureDialog') do
  with CL.AddClass(CL.FindClass('TOpenPictureDialog'), TSavePictureDialog) do
  begin
  end;
end;

procedure SIRegister_TOpenPictureDialog(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOpenDialog', 'TOpenPictureDialog') do
  with CL.AddClass(CL.FindClass('TOpenDialog'), TOpenPictureDialog) do
  begin
  end;
end;

procedure SIRegister_ExtDlgs(CL: TPSPascalCompiler);
begin
  SIRegister_TOpenPictureDialog(CL);
  SIRegister_TSavePictureDialog(CL);
end;

(* === run-time registration functions === *)

procedure RIRegister_TSavePictureDialog(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TSavePictureDialog) do
  begin
  end;
end;

procedure RIRegister_TOpenPictureDialog(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TOpenPictureDialog) do
  begin
  end;
end;

procedure RIRegister_ExtDlgs(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TOpenPictureDialog(CL);
  RIRegister_TSavePictureDialog(CL);
end;

{ TPSImport_ExtDlgs }

procedure TPSImport_ExtDlgs.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ExtDlgs(CompExec.Comp);
end;

procedure TPSImport_ExtDlgs.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ExtDlgs(ri);
end;

end.



