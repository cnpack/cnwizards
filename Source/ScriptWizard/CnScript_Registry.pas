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

unit CnScript_Registry;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Registry 注册类
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
  Windows, SysUtils, Classes, Registry, IniFiles, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_Registry = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TRegistryIniFile(CL: TPSPascalCompiler);
procedure SIRegister_TRegIniFile(CL: TPSPascalCompiler);
procedure SIRegister_TRegistry(CL: TPSPascalCompiler);
procedure SIRegister_Registry(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TRegistryIniFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TRegIniFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TRegistry(CL: TPSRuntimeClassImporter);
procedure RIRegister_Registry(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TRegistryIniFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomIniFile', 'TRegistryIniFile') do
  with CL.AddClass(CL.FindClass('TCustomIniFile'), TRegistryIniFile) do
  begin
    RegisterMethod('Constructor Create( const FileName : string);');
    RegisterMethod('Constructor CreateEx( const FileName : string; AAccess : LongWord);');
    RegisterProperty('RegIniFile', 'TRegIniFile', iptr);
  end;
end;

procedure SIRegister_TRegIniFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TRegistry', 'TRegIniFile') do
  with CL.AddClass(CL.FindClass('TRegistry'), TRegIniFile) do
  begin
    RegisterMethod('Constructor Create( const FileName : string);');
    RegisterMethod('Constructor CreateEx( const FileName : string; AAccess : LongWord);');
    RegisterMethod('Function ReadString( const Section, Ident, Default : string) : string');
    RegisterMethod('Function ReadInteger( const Section, Ident : string; Default : Longint) : Longint');
    RegisterMethod('Procedure WriteInteger( const Section, Ident : string; Value : Longint)');
    RegisterMethod('Procedure WriteString( const Section, Ident, Value : String)');
    RegisterMethod('Function ReadBool( const Section, Ident : string; Default : Boolean) : Boolean');
    RegisterMethod('Procedure WriteBool( const Section, Ident : string; Value : Boolean)');
    RegisterMethod('Procedure ReadSection( const Section : string; Strings : TStrings)');
    RegisterMethod('Procedure ReadSections( Strings : TStrings)');
    RegisterMethod('Procedure ReadSectionValues( const Section : string; Strings : TStrings)');
    RegisterMethod('Procedure EraseSection( const Section : string)');
    RegisterMethod('Procedure DeleteKey( const Section, Ident : String)');
    RegisterProperty('FileName', 'string', iptr);
  end;
end;

procedure SIRegister_TRegistry(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TRegistry') do
  with CL.AddClass(CL.FindClass('TObject'), TRegistry) do
  begin
    RegisterMethod('Constructor Create;');
    RegisterMethod('Constructor CreateEx( AAccess : LongWord);');
    RegisterMethod('Procedure CloseKey');
    RegisterMethod('Function CreateKey( const Key : string) : Boolean');
    RegisterMethod('Function DeleteKey( const Key : string) : Boolean');
    RegisterMethod('Function DeleteValue( const Name : string) : Boolean');
    RegisterMethod('Function GetDataInfo( const ValueName : string; var Value : TRegDataInfo) : Boolean');
    RegisterMethod('Function GetDataSize( const ValueName : string) : Integer');
    RegisterMethod('Function GetDataType( const ValueName : string) : TRegDataType');
    RegisterMethod('Function GetKeyInfo( var Value : TRegKeyInfo) : Boolean');
    RegisterMethod('Procedure GetKeyNames( Strings : TStrings)');
    RegisterMethod('Procedure GetValueNames( Strings : TStrings)');
    RegisterMethod('Function HasSubKeys : Boolean');
    RegisterMethod('Function KeyExists( const Key : string) : Boolean');
    RegisterMethod('Function LoadKey( const Key, FileName : string) : Boolean');
    RegisterMethod('Procedure MoveKey( const OldName, NewName : string; Delete : Boolean)');
    RegisterMethod('Function OpenKey( const Key : string; CanCreate : Boolean) : Boolean');
    RegisterMethod('Function OpenKeyReadOnly( const Key : String) : Boolean');
    RegisterMethod('Function ReadCurrency( const Name : string) : Currency');
    RegisterMethod('Function ReadBinaryData( const Name : string; var Buffer, BufSize : Integer) : Integer');
    RegisterMethod('Function ReadBool( const Name : string) : Boolean');
    RegisterMethod('Function ReadDate( const Name : string) : TDateTime');
    RegisterMethod('Function ReadDateTime( const Name : string) : TDateTime');
    RegisterMethod('Function ReadFloat( const Name : string) : Double');
    RegisterMethod('Function ReadInteger( const Name : string) : Integer');
    RegisterMethod('Function ReadString( const Name : string) : string');
    RegisterMethod('Function ReadTime( const Name : string) : TDateTime');
    RegisterMethod('Function RegistryConnect( const UNCName : string) : Boolean');
    RegisterMethod('Procedure RenameValue( const OldName, NewName : string)');
    RegisterMethod('Function ReplaceKey( const Key, FileName, BackUpFileName : string) : Boolean');
    RegisterMethod('Function RestoreKey( const Key, FileName : string) : Boolean');
    RegisterMethod('Function SaveKey( const Key, FileName : string) : Boolean');
    RegisterMethod('Function UnLoadKey( const Key : string) : Boolean');
    RegisterMethod('Function ValueExists( const Name : string) : Boolean');
    RegisterMethod('Procedure WriteCurrency( const Name : string; Value : Currency)');
    RegisterMethod('Procedure WriteBinaryData( const Name : string; var Buffer, BufSize : Integer)');
    RegisterMethod('Procedure WriteBool( const Name : string; Value : Boolean)');
    RegisterMethod('Procedure WriteDate( const Name : string; Value : TDateTime)');
    RegisterMethod('Procedure WriteDateTime( const Name : string; Value : TDateTime)');
    RegisterMethod('Procedure WriteFloat( const Name : string; Value : Double)');
    RegisterMethod('Procedure WriteInteger( const Name : string; Value : Integer)');
    RegisterMethod('Procedure WriteString( const Name, Value : string)');
    RegisterMethod('Procedure WriteExpandString( const Name, Value : string)');
    RegisterMethod('Procedure WriteTime( const Name : string; Value : TDateTime)');
    RegisterProperty('CurrentKey', 'HKEY', iptr);
    RegisterProperty('CurrentPath', 'string', iptr);
    RegisterProperty('LazyWrite', 'Boolean', iptrw);
    RegisterProperty('RootKey', 'HKEY', iptrw);
    RegisterProperty('Access', 'LongWord', iptrw);
  end;
end;

procedure SIRegister_Registry(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TRegKeyInfo', 'record NumSubKeys : Integer; MaxSubKeyLen : Integ'
    + 'er; NumValues : Integer; MaxValueLen : Integer; MaxDataLen : Integer; File'
    + 'Time : TFileTime; end');
  CL.AddTypeS('TRegDataType', '( rdUnknown, rdString, rdExpandString, rdInteger'
    + ', rdBinary )');
  CL.AddTypeS('TRegDataInfo', 'record RegData : TRegDataType; DataSize : Intege'
    + 'r; end');
  SIRegister_TRegistry(CL);
  SIRegister_TRegIniFile(CL);
  SIRegister_TRegistryIniFile(CL);
end;

(* === run-time registration functions === *)

procedure TRegistryIniFileRegIniFile_R(Self: TRegistryIniFile; var T: TRegIniFile);
begin
  T := Self.RegIniFile;
end;

function TRegistryIniFileCreateEx_P(Self: TClass; CreateNewInstance: Boolean; const FileName: string; AAccess: LongWord): TObject;
begin
  Result := TRegistryIniFile.Create(FileName, AAccess);
end;

function TRegistryIniFileCreate_P(Self: TClass; CreateNewInstance: Boolean; const FileName: string): TObject;
begin
  Result := TRegistryIniFile.Create(FileName);
end;

procedure TRegIniFileFileName_R(Self: TRegIniFile; var T: string);
begin
  T := Self.FileName;
end;

function TRegIniFileCreateEx_P(Self: TClass; CreateNewInstance: Boolean; const FileName: string; AAccess: LongWord): TObject;
begin
  Result := TRegIniFile.Create(FileName, AAccess);
end;

function TRegIniFileCreate_P(Self: TClass; CreateNewInstance: Boolean; const FileName: string): TObject;
begin
  Result := TRegIniFile.Create(FileName);
end;

procedure TRegistryAccess_W(Self: TRegistry; const T: LongWord);
begin
  Self.Access := T;
end;

procedure TRegistryAccess_R(Self: TRegistry; var T: LongWord);
begin
  T := Self.Access;
end;

procedure TRegistryRootKey_W(Self: TRegistry; const T: HKEY);
begin
  Self.RootKey := T;
end;

procedure TRegistryRootKey_R(Self: TRegistry; var T: HKEY);
begin
  T := Self.RootKey;
end;

procedure TRegistryLazyWrite_W(Self: TRegistry; const T: Boolean);
begin
  Self.LazyWrite := T;
end;

procedure TRegistryLazyWrite_R(Self: TRegistry; var T: Boolean);
begin
  T := Self.LazyWrite;
end;

procedure TRegistryCurrentPath_R(Self: TRegistry; var T: string);
begin
  T := Self.CurrentPath;
end;

procedure TRegistryCurrentKey_R(Self: TRegistry; var T: HKEY);
begin
  T := Self.CurrentKey;
end;

function TRegistryCreateEx_P(Self: TClass; CreateNewInstance: Boolean; AAccess: LongWord): TObject;
begin
  Result := TRegistry.Create(AAccess);
end;

function TRegistryCreate_P(Self: TClass; CreateNewInstance: Boolean): TObject;
begin
  Result := TRegistry.Create;
end;

procedure RIRegister_TRegistryIniFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRegistryIniFile) do
  begin
    RegisterConstructor(@TRegistryIniFileCreate_P, 'Create');
    RegisterConstructor(@TRegistryIniFileCreateEx_P, 'CreateEx');
    RegisterPropertyHelper(@TRegistryIniFileRegIniFile_R, nil, 'RegIniFile');
  end;
end;

procedure RIRegister_TRegIniFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRegIniFile) do
  begin
    RegisterConstructor(@TRegIniFileCreate_P, 'Create');
    RegisterConstructor(@TRegIniFileCreateEx_P, 'CreateEx');
    RegisterMethod(@TRegIniFile.ReadString, 'ReadString');
    RegisterMethod(@TRegIniFile.ReadInteger, 'ReadInteger');
    RegisterMethod(@TRegIniFile.WriteInteger, 'WriteInteger');
    RegisterMethod(@TRegIniFile.WriteString, 'WriteString');
    RegisterMethod(@TRegIniFile.ReadBool, 'ReadBool');
    RegisterMethod(@TRegIniFile.WriteBool, 'WriteBool');
    RegisterMethod(@TRegIniFile.ReadSection, 'ReadSection');
    RegisterMethod(@TRegIniFile.ReadSections, 'ReadSections');
    RegisterMethod(@TRegIniFile.ReadSectionValues, 'ReadSectionValues');
    RegisterMethod(@TRegIniFile.EraseSection, 'EraseSection');
    RegisterMethod(@TRegIniFile.DeleteKey, 'DeleteKey');
    RegisterPropertyHelper(@TRegIniFileFileName_R, nil, 'FileName');
  end;
end;

procedure RIRegister_TRegistry(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRegistry) do
  begin
    RegisterConstructor(@TRegistryCreate_P, 'Create');
    RegisterConstructor(@TRegistryCreateEx_P, 'CreateEx');
    RegisterMethod(@TRegistry.CloseKey, 'CloseKey');
    RegisterMethod(@TRegistry.CreateKey, 'CreateKey');
    RegisterMethod(@TRegistry.DeleteKey, 'DeleteKey');
    RegisterMethod(@TRegistry.DeleteValue, 'DeleteValue');
    RegisterMethod(@TRegistry.GetDataInfo, 'GetDataInfo');
    RegisterMethod(@TRegistry.GetDataSize, 'GetDataSize');
    RegisterMethod(@TRegistry.GetDataType, 'GetDataType');
    RegisterMethod(@TRegistry.GetKeyInfo, 'GetKeyInfo');
    RegisterMethod(@TRegistry.GetKeyNames, 'GetKeyNames');
    RegisterMethod(@TRegistry.GetValueNames, 'GetValueNames');
    RegisterMethod(@TRegistry.HasSubKeys, 'HasSubKeys');
    RegisterMethod(@TRegistry.KeyExists, 'KeyExists');
    RegisterMethod(@TRegistry.LoadKey, 'LoadKey');
    RegisterMethod(@TRegistry.MoveKey, 'MoveKey');
    RegisterMethod(@TRegistry.OpenKey, 'OpenKey');
    RegisterMethod(@TRegistry.OpenKeyReadOnly, 'OpenKeyReadOnly');
    RegisterMethod(@TRegistry.ReadCurrency, 'ReadCurrency');
    RegisterMethod(@TRegistry.ReadBinaryData, 'ReadBinaryData');
    RegisterMethod(@TRegistry.ReadBool, 'ReadBool');
    RegisterMethod(@TRegistry.ReadDate, 'ReadDate');
    RegisterMethod(@TRegistry.ReadDateTime, 'ReadDateTime');
    RegisterMethod(@TRegistry.ReadFloat, 'ReadFloat');
    RegisterMethod(@TRegistry.ReadInteger, 'ReadInteger');
    RegisterMethod(@TRegistry.ReadString, 'ReadString');
    RegisterMethod(@TRegistry.ReadTime, 'ReadTime');
    RegisterMethod(@TRegistry.RegistryConnect, 'RegistryConnect');
    RegisterMethod(@TRegistry.RenameValue, 'RenameValue');
    RegisterMethod(@TRegistry.ReplaceKey, 'ReplaceKey');
    RegisterMethod(@TRegistry.RestoreKey, 'RestoreKey');
    RegisterMethod(@TRegistry.SaveKey, 'SaveKey');
    RegisterMethod(@TRegistry.UnLoadKey, 'UnLoadKey');
    RegisterMethod(@TRegistry.ValueExists, 'ValueExists');
    RegisterMethod(@TRegistry.WriteCurrency, 'WriteCurrency');
    RegisterMethod(@TRegistry.WriteBinaryData, 'WriteBinaryData');
    RegisterMethod(@TRegistry.WriteBool, 'WriteBool');
    RegisterMethod(@TRegistry.WriteDate, 'WriteDate');
    RegisterMethod(@TRegistry.WriteDateTime, 'WriteDateTime');
    RegisterMethod(@TRegistry.WriteFloat, 'WriteFloat');
    RegisterMethod(@TRegistry.WriteInteger, 'WriteInteger');
    RegisterMethod(@TRegistry.WriteString, 'WriteString');
    RegisterMethod(@TRegistry.WriteExpandString, 'WriteExpandString');
    RegisterMethod(@TRegistry.WriteTime, 'WriteTime');
    RegisterPropertyHelper(@TRegistryCurrentKey_R, nil, 'CurrentKey');
    RegisterPropertyHelper(@TRegistryCurrentPath_R, nil, 'CurrentPath');
    RegisterPropertyHelper(@TRegistryLazyWrite_R, @TRegistryLazyWrite_W, 'LazyWrite');
    RegisterPropertyHelper(@TRegistryRootKey_R, @TRegistryRootKey_W, 'RootKey');
    RegisterPropertyHelper(@TRegistryAccess_R, @TRegistryAccess_W, 'Access');
  end;
end;

procedure RIRegister_Registry(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TRegistry(CL);
  RIRegister_TRegIniFile(CL);
  RIRegister_TRegistryIniFile(CL);
end;

{ TPSImport_Registry }

procedure TPSImport_Registry.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Registry(CompExec.Comp);
end;

procedure TPSImport_Registry.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Registry(ri);
end;

end.



