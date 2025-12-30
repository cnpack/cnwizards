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

unit CnScript_Printers;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Printers 注册类
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
  Windows, SysUtils, Classes, Printers, Graphics, uPSComponent, uPSRuntime,
  uPSCompiler;

type

  TPSImport_Printers = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TPrinter(CL: TPSPascalCompiler);
procedure SIRegister_Printers(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Printers_Routines(S: TPSExec);
procedure RIRegister_TPrinter(CL: TPSRuntimeClassImporter);
procedure RIRegister_Printers(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TPrinter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TPrinter') do
  with CL.AddClass(CL.FindClass('TObject'), TPrinter) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure Abort');
    RegisterMethod('Procedure BeginDoc');
    RegisterMethod('Procedure EndDoc');
    RegisterMethod('Procedure NewPage');
    RegisterMethod('Procedure GetPrinter( ADevice, ADriver, APort : PChar; var ADeviceMode : THandle)');
    RegisterMethod('Procedure SetPrinter( ADevice, ADriver, APort : PChar; ADeviceMode : THandle)');
    RegisterMethod('Procedure Refresh');
    RegisterProperty('Aborted', 'Boolean', iptr);
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Capabilities', 'TPrinterCapabilities', iptr);
    RegisterProperty('Copies', 'Integer', iptrw);
    RegisterProperty('Fonts', 'TStrings', iptr);
    RegisterProperty('Handle', 'HDC', iptr);
    RegisterProperty('Orientation', 'TPrinterOrientation', iptrw);
    RegisterProperty('PageHeight', 'Integer', iptr);
    RegisterProperty('PageWidth', 'Integer', iptr);
    RegisterProperty('PageNumber', 'Integer', iptr);
    RegisterProperty('PrinterIndex', 'Integer', iptrw);
    RegisterProperty('Printing', 'Boolean', iptr);
    RegisterProperty('Printers', 'TStrings', iptr);
    RegisterProperty('Title', 'string', iptrw);
  end;
end;

procedure SIRegister_Printers(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TPrinterState', '( psNoHandle, psHandleIC, psHandleDC )');
  CL.AddTypeS('TPrinterOrientation', '( poPortrait, poLandscape )');
  CL.AddTypeS('TPrinterCapability', '( pcCopies, pcOrientation, pcCollation )');
  CL.AddTypeS('TPrinterCapabilities', 'set of TPrinterCapability');
  SIRegister_TPrinter(CL);
  CL.AddDelphiFunction('Function Printer : TPrinter');
end;

(* === run-time registration functions === *)

procedure TPrinterTitle_W(Self: TPrinter; const T: string);
begin
  Self.Title := T;
end;

procedure TPrinterTitle_R(Self: TPrinter; var T: string);
begin
  T := Self.Title;
end;

procedure TPrinterPrinters_R(Self: TPrinter; var T: TStrings);
begin
  T := Self.Printers;
end;

procedure TPrinterPrinting_R(Self: TPrinter; var T: Boolean);
begin
  T := Self.Printing;
end;

procedure TPrinterPrinterIndex_W(Self: TPrinter; const T: Integer);
begin
  Self.PrinterIndex := T;
end;

procedure TPrinterPrinterIndex_R(Self: TPrinter; var T: Integer);
begin
  T := Self.PrinterIndex;
end;

procedure TPrinterPageNumber_R(Self: TPrinter; var T: Integer);
begin
  T := Self.PageNumber;
end;

procedure TPrinterPageWidth_R(Self: TPrinter; var T: Integer);
begin
  T := Self.PageWidth;
end;

procedure TPrinterPageHeight_R(Self: TPrinter; var T: Integer);
begin
  T := Self.PageHeight;
end;

procedure TPrinterOrientation_W(Self: TPrinter; const T: TPrinterOrientation);
begin
  Self.Orientation := T;
end;

procedure TPrinterOrientation_R(Self: TPrinter; var T: TPrinterOrientation);
begin
  T := Self.Orientation;
end;

procedure TPrinterHandle_R(Self: TPrinter; var T: HDC);
begin
  T := Self.Handle;
end;

procedure TPrinterFonts_R(Self: TPrinter; var T: TStrings);
begin
  T := Self.Fonts;
end;

procedure TPrinterCopies_W(Self: TPrinter; const T: Integer);
begin
  Self.Copies := T;
end;

procedure TPrinterCopies_R(Self: TPrinter; var T: Integer);
begin
  T := Self.Copies;
end;

procedure TPrinterCapabilities_R(Self: TPrinter; var T: TPrinterCapabilities);
begin
  T := Self.Capabilities;
end;

procedure TPrinterCanvas_R(Self: TPrinter; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TPrinterAborted_R(Self: TPrinter; var T: Boolean);
begin
  T := Self.Aborted;
end;

procedure RIRegister_Printers_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Printer, 'Printer', cdRegister);
end;

procedure RIRegister_TPrinter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPrinter) do
  begin
    RegisterConstructor(@TPrinter.Create, 'Create');
    RegisterMethod(@TPrinter.Abort, 'Abort');
    RegisterMethod(@TPrinter.BeginDoc, 'BeginDoc');
    RegisterMethod(@TPrinter.EndDoc, 'EndDoc');
    RegisterMethod(@TPrinter.NewPage, 'NewPage');
    RegisterMethod(@TPrinter.GetPrinter, 'GetPrinter');
    RegisterMethod(@TPrinter.SetPrinter, 'SetPrinter');
    RegisterMethod(@TPrinter.Refresh, 'Refresh');
    RegisterPropertyHelper(@TPrinterAborted_R, nil, 'Aborted');
    RegisterPropertyHelper(@TPrinterCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TPrinterCapabilities_R, nil, 'Capabilities');
    RegisterPropertyHelper(@TPrinterCopies_R, @TPrinterCopies_W, 'Copies');
    RegisterPropertyHelper(@TPrinterFonts_R, nil, 'Fonts');
    RegisterPropertyHelper(@TPrinterHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TPrinterOrientation_R, @TPrinterOrientation_W, 'Orientation');
    RegisterPropertyHelper(@TPrinterPageHeight_R, nil, 'PageHeight');
    RegisterPropertyHelper(@TPrinterPageWidth_R, nil, 'PageWidth');
    RegisterPropertyHelper(@TPrinterPageNumber_R, nil, 'PageNumber');
    RegisterPropertyHelper(@TPrinterPrinterIndex_R, @TPrinterPrinterIndex_W, 'PrinterIndex');
    RegisterPropertyHelper(@TPrinterPrinting_R, nil, 'Printing');
    RegisterPropertyHelper(@TPrinterPrinters_R, nil, 'Printers');
    RegisterPropertyHelper(@TPrinterTitle_R, @TPrinterTitle_W, 'Title');
  end;
end;

procedure RIRegister_Printers(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TPrinter(CL);
end;

{ TPSImport_Printers }

procedure TPSImport_Printers.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Printers(CompExec.Comp);
end;

procedure TPSImport_Printers.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Printers(ri);
  RIRegister_Printers_Routines(CompExec.Exec); // comment it if no routines
end;

end.



