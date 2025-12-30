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

unit CnScript_IniFiles;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 IniFiles 注册类
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
  Windows, SysUtils, Classes, IniFiles, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_IniFiles = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TMemIniFile(CL: TPSPascalCompiler);
procedure SIRegister_TIniFile(CL: TPSPascalCompiler);
procedure SIRegister_TCustomIniFile(CL: TPSPascalCompiler);
procedure SIRegister_IniFiles(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TMemIniFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TIniFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomIniFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_IniFiles(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TMemIniFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomIniFile', 'TMemIniFile') do
  with CL.AddClass(CL.FindClass('TCustomIniFile'), TMemIniFile) do
  begin
    RegisterMethod('Constructor Create( const FileName : string)');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure GetStrings( List : TStrings)');
    RegisterMethod('Procedure Rename( const FileName : string; Reload : Boolean)');
    RegisterMethod('Procedure SetStrings( List : TStrings)');
  end;
end;

procedure SIRegister_TIniFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomIniFile', 'TIniFile') do
  with CL.AddClass(CL.FindClass('TCustomIniFile'), TIniFile) do
  begin
  end;
end;

procedure SIRegister_TCustomIniFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCustomIniFile') do
  with CL.AddClass(CL.FindClass('TObject'), TCustomIniFile) do
  begin
    RegisterMethod('Constructor Create( const FileName : string)');
    RegisterMethod('Function SectionExists( const Section : string) : Boolean');
    RegisterMethod('Function ReadString( const Section, Ident, Default : string) : string');
    RegisterMethod('Procedure WriteString( const Section, Ident, Value : String)');
    RegisterMethod('Function ReadInteger( const Section, Ident : string; Default : Longint) : Longint');
    RegisterMethod('Procedure WriteInteger( const Section, Ident : string; Value : Longint)');
    RegisterMethod('Function ReadBool( const Section, Ident : string; Default : Boolean) : Boolean');
    RegisterMethod('Procedure WriteBool( const Section, Ident : string; Value : Boolean)');
    RegisterMethod('Function ReadDate( const Section, Name : string; Default : TDateTime) : TDateTime');
    RegisterMethod('Function ReadDateTime( const Section, Name : string; Default : TDateTime) : TDateTime');
    RegisterMethod('Function ReadFloat( const Section, Name : string; Default : Double) : Double');
    RegisterMethod('Function ReadTime( const Section, Name : string; Default : TDateTime) : TDateTime');
    RegisterMethod('Procedure WriteDate( const Section, Name : string; Value : TDateTime)');
    RegisterMethod('Procedure WriteDateTime( const Section, Name : string; Value : TDateTime)');
    RegisterMethod('Procedure WriteFloat( const Section, Name : string; Value : Double)');
    RegisterMethod('Procedure WriteTime( const Section, Name : string; Value : TDateTime)');
    RegisterMethod('Procedure ReadSection( const Section : string; Strings : TStrings)');
    RegisterMethod('Procedure ReadSections( Strings : TStrings)');
    RegisterMethod('Procedure ReadSectionValues( const Section : string; Strings : TStrings)');
    RegisterMethod('Procedure EraseSection( const Section : string)');
    RegisterMethod('Procedure DeleteKey( const Section, Ident : String)');
    RegisterMethod('Procedure UpdateFile');
    RegisterMethod('Function ValueExists( const Section, Ident : string) : Boolean');
    RegisterProperty('FileName', 'string', iptr);
  end;
end;

procedure SIRegister_IniFiles(CL: TPSPascalCompiler);
begin
  SIRegister_TCustomIniFile(CL);
  SIRegister_TIniFile(CL);
  SIRegister_TMemIniFile(CL);
end;

(* === run-time registration functions === *)

procedure TCustomIniFileFileName_R(Self: TCustomIniFile; var T: string);
begin
  T := Self.FileName;
end;

procedure RIRegister_TMemIniFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMemIniFile) do
  begin
    RegisterConstructor(@TMemIniFile.Create, 'Create');
    RegisterMethod(@TMemIniFile.Clear, 'Clear');
    RegisterMethod(@TMemIniFile.GetStrings, 'GetStrings');
    RegisterMethod(@TMemIniFile.Rename, 'Rename');
    RegisterMethod(@TMemIniFile.SetStrings, 'SetStrings');
  end;
end;

procedure RIRegister_TIniFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TIniFile) do
  begin
  end;
end;

procedure RIRegister_TCustomIniFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomIniFile) do
  begin
    RegisterConstructor(@TCustomIniFile.Create, 'Create');
    RegisterMethod(@TCustomIniFile.SectionExists, 'SectionExists');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.ReadString, 'ReadString');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.WriteString, 'WriteString');
    RegisterVirtualMethod(@TCustomIniFile.ReadInteger, 'ReadInteger');
    RegisterVirtualMethod(@TCustomIniFile.WriteInteger, 'WriteInteger');
    RegisterVirtualMethod(@TCustomIniFile.ReadBool, 'ReadBool');
    RegisterVirtualMethod(@TCustomIniFile.WriteBool, 'WriteBool');
    RegisterVirtualMethod(@TCustomIniFile.ReadDate, 'ReadDate');
    RegisterVirtualMethod(@TCustomIniFile.ReadDateTime, 'ReadDateTime');
    RegisterVirtualMethod(@TCustomIniFile.ReadFloat, 'ReadFloat');
    RegisterVirtualMethod(@TCustomIniFile.ReadTime, 'ReadTime');
    RegisterVirtualMethod(@TCustomIniFile.WriteDate, 'WriteDate');
    RegisterVirtualMethod(@TCustomIniFile.WriteDateTime, 'WriteDateTime');
    RegisterVirtualMethod(@TCustomIniFile.WriteFloat, 'WriteFloat');
    RegisterVirtualMethod(@TCustomIniFile.WriteTime, 'WriteTime');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.ReadSection, 'ReadSection');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.ReadSections, 'ReadSections');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.ReadSectionValues, 'ReadSectionValues');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.EraseSection, 'EraseSection');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.DeleteKey, 'DeleteKey');
    RegisterVirtualAbstractMethod(TIniFile, @TIniFile.UpdateFile, 'UpdateFile');
    RegisterMethod(@TCustomIniFile.ValueExists, 'ValueExists');
    RegisterPropertyHelper(@TCustomIniFileFileName_R, nil, 'FileName');
  end;
end;

procedure RIRegister_IniFiles(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCustomIniFile(CL);
  RIRegister_TIniFile(CL);
  RIRegister_TMemIniFile(CL);
end;

{ TPSImport_IniFiles }

procedure TPSImport_IniFiles.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_IniFiles(CompExec.Comp);
end;

procedure TPSImport_IniFiles.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_IniFiles(ri);
end;

end.



