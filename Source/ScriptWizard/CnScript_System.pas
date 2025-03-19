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

unit CnScript_System;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 System 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, uPSUtils, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_System = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TObject(CL: TPSPascalCompiler);
procedure SIRegister_TInterfacedObject(CL: TPSPascalCompiler);
procedure SIRegister_System(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_TInterfacedObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_System_Routines(S: TPSExec);
procedure RIRegister_System(CL: TPSRuntimeClassImporter);

implementation

function _PChar(P: Pointer): PChar;
begin
  Result := PChar(P);
end;

function _Pointer(P: TObject): Pointer;
begin
  Result := Pointer(P);
end;

function _TObject(P: Pointer): TObject;
begin
  Result := TObject(P);
end;  

function _GetChar(P: Pointer): Char;
begin
  Result := PChar(P)^;
end;

procedure _SetChar(P: Pointer; V: Char);
begin
  PChar(P)^ := V;
end;

function _GetByte(P: Pointer): Byte;
begin
  Result := PByte(P)^;
end;

procedure _SetByte(P: Pointer; V: Byte);
begin
  PByte(P)^ := V;
end;

function _GetWord(P: Pointer): Word;
begin
  Result := PWord(P)^;
end;

procedure _SetWord(P: Pointer; V: Word);
begin
  PWord(P)^ := V;
end;

function _GetInteger(P: Pointer): Integer;
begin
  Result := PInteger(P)^;
end;

procedure _SetInteger(P: Pointer; V: Integer);
begin
  PInteger(P)^ := V;
end;

function _GetSingle(P: Pointer): Single;
begin
  Result := PSingle(P)^;
end;

procedure _SetSingle(P: Pointer; V: Single);
begin
  PSingle(P)^ := V;
end;

function _GetDouble(P: Pointer): Double;
begin
  Result := PDouble(P)^;
end;

procedure _SetDouble(P: Pointer; V: Double);
begin
  PDouble(P)^ := V;
end;

procedure _GetMem(var P: Pointer; Size: Integer);
begin
  GetMem(P, Size);
end;

procedure _FreeMem(var P: Pointer);
begin
  FreeMem(P);
end;

procedure SIRegister_TInterfacedObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TInterfacedObject') do
  with CL.AddClass(CL.FindClass('TObject'), TInterfacedObject) do
  begin
    RegisterProperty('RefCount', 'Integer', iptr);
  end;
end;

procedure SIRegister_TObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TObject') do
  with CL.AddClass(nil, TObject) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure Free');
    RegisterMethod('Function ClassName : string');
    RegisterMethod('Function ClassNameIs( const Name : string) : Boolean');
    RegisterMethod('Function ClassInfo : Pointer');
    RegisterMethod('Function InstanceSize : Longint');
    RegisterMethod('Function MethodAddress( const Name : string) : Pointer');
    RegisterMethod('Function MethodName( Address : Pointer) : string');
    RegisterMethod('Function FieldAddress( const Name : string) : Pointer');
  end;
end;

procedure SIRegister_System(CL: TPSPascalCompiler);
begin
{$IFDEF WIN64}
  CL.AddType('Pointer', btS64).ExportName := True;
{$ELSE}
  CL.AddType('Pointer', btU32).ExportName := True;
{$ENDIF}
  CL.AddTypeS('HRESULT', 'LongInt');
  CL.AddTypeS('TMethod', 'record Code : Pointer; Data : Pointer; end');
  CL.AddTypeS('TGUID', 'record D1 : LongWord; D2, D3 : Word; D4: array[0..7] of Byte; end');
  CL.AddConstantN('S_OK', 'HRESULT').SetInt(0);
  CL.AddConstantN('S_FALSE', 'HRESULT').SetInt($00000001);
  CL.AddConstantN('E_NOINTERFACE', 'HRESULT').SetInt(HRESULT($80004002));
  CL.AddConstantN('E_UNEXPECTED', 'HRESULT').SetInt(HRESULT($8000FFFF));
  CL.AddConstantN('E_NOTIMPL', 'HRESULT').SetInt(HRESULT($80004001));
  CL.AddTypeS('UCS2Char', 'WideChar');
  CL.AddTypeS('UCS4Char', 'LongWord');
  CL.AddTypeS('UTF8String', 'string');
  CL.AddTypeS('TDateTime', 'Double');
  CL.AddTypeS('THandle', 'LongWord');
  CL.AddTypeS('HINST', 'THandle');
  CL.AddTypeS('HMODULE', 'HINST');
  CL.AddTypeS('HGLOBAL', 'THandle');
  SIRegister_TObject(CL);
  SIRegister_TInterfacedObject(CL);
  CL.AddDelphiFunction('function _PChar(P: Pointer): PChar');
  CL.AddDelphiFunction('function _Pointer(P: TObject): Pointer');
  CL.AddDelphiFunction('function _TObject(P: Pointer): TObject');
  CL.AddDelphiFunction('function _GetChar(P: Pointer): Char');
  CL.AddDelphiFunction('procedure _SetChar(P: Pointer; V: Char)');
  CL.AddDelphiFunction('function _GetByte(P: Pointer): Byte');
  CL.AddDelphiFunction('procedure _SetByte(P: Pointer; V: Byte)');
  CL.AddDelphiFunction('function _GetWord(P: Pointer): Word');
  CL.AddDelphiFunction('procedure _SetWord(P: Pointer; V: Word)');
  CL.AddDelphiFunction('function _GetInteger(P: Pointer): Integer');
  CL.AddDelphiFunction('procedure _SetInteger(P: Pointer; V: Integer)');
  CL.AddDelphiFunction('function _GetSingle(P: Pointer): Single');
  CL.AddDelphiFunction('procedure _SetSingle(P: Pointer; V: Single)');
  CL.AddDelphiFunction('function _GetDouble(P: Pointer): Double');
  CL.AddDelphiFunction('procedure _SetDouble(P: Pointer; V: Double)');
  CL.AddDelphiFunction('Procedure ChDir( const S : string)');
  CL.AddDelphiFunction('Procedure MkDir( const S : string)');
  CL.AddDelphiFunction('Function ParamCount : Integer');
  CL.AddDelphiFunction('Function ParamStr( Index : Integer) : string');
  CL.AddDelphiFunction('Procedure Randomize');
  CL.AddDelphiFunction('Function Random( Range: Integer): Integer');
  CL.AddDelphiFunction('Procedure RmDir( const S : string)');
  CL.AddDelphiFunction('Function UpCase( Ch : Char) : Char');
{$IFDEF COMPILER6_UP}
  CL.AddDelphiFunction('Function UTF8Encode( const WS : WideString) : UTF8String');
  CL.AddDelphiFunction('Function UTF8Decode( const S : UTF8String) : WideString');
  CL.AddDelphiFunction('Function AnsiToUtf8( const S : string) : UTF8String');
  CL.AddDelphiFunction('Function Utf8ToAnsi( const S : UTF8String) : string');
{$ENDIF}
  CL.AddDelphiFunction('Function GetMemory( Size : Integer) : Pointer');
  CL.AddDelphiFunction('Function FreeMemory( P : Pointer) : Integer');
  CL.AddDelphiFunction('Function ReallocMemory( P : Pointer; Size : Integer) : Pointer');
  CL.AddDelphiFunction('Procedure GetMem( var P : Pointer; Size: Integer)');
  CL.AddDelphiFunction('Procedure FreeMem( var P : Pointer)');
end;

(* === run-time registration functions === *)

procedure ChDir_P(const S: string);
begin
  System.ChDir(S);
end;

procedure MkDir_P(const S: string);
begin
  System.MkDir(S);
end;

function Random_P(Range: Integer): Integer;
begin
  Result := Random(Range);
end;

procedure RmDir_P(const S: string);
begin
  System.RmDir(S);
end;

procedure TInterfacedObjectRefCount_R(Self: TInterfacedObject; var T: Integer);
begin
  T := Self.RefCount;
end;

procedure RIRegister_TInterfacedObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TInterfacedObject) do
  begin
    RegisterPropertyHelper(@TInterfacedObjectRefCount_R, nil, 'RefCount');
  end;
end;

function ClassName_P(Self: TObject): string;
begin
  Result := Self.ClassName;
end;

function ClassNameIs_P(Self: TObject; const Name: string): Boolean;
begin
  Result := Self.ClassNameIs(Name);
end;

function ClassInfo_P(Self: TObject): Pointer;
begin
  Result := Self.ClassInfo;
end;

function InstanceSize_P(Self: TObject): Longint;
begin
  Result := Self.InstanceSize
end;

function MethodAddress_P(Self: TObject; const Name: string): Pointer;
begin
  Result := Self.MethodAddress(Name);
end;

function MethodName_P(Self: TObject; Address: Pointer): string;
begin
  Result := Self.MethodName(Address);
end;

function FieldAddress_P(Self: TObject; const Name: string): Pointer;
begin
  Result := Self.FieldAddress(Name);
end;

procedure RIRegister_TObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TObject) do
  begin
    RegisterConstructor(@TObject.Create, 'Create');
    RegisterMethod(@TObject.Free, 'Free');
    // 脚本不支持 class function 和 ShortString
    RegisterMethod(@ClassName_P, 'ClassName');
    RegisterMethod(@ClassNameIs_P, 'ClassNameIs');
    RegisterMethod(@ClassInfo_P, 'ClassInfo');
    RegisterMethod(@InstanceSize_P, 'InstanceSize');
    RegisterMethod(@MethodAddress_P, 'MethodAddress');
    RegisterMethod(@MethodName_P, 'MethodName');
    RegisterMethod(@FieldAddress_P, 'FieldAddress');
  end;
end;

procedure RIRegister_System_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@_PChar, '_PChar', cdRegister);
  S.RegisterDelphiFunction(@_Pointer, '_Pointer', cdRegister);
  S.RegisterDelphiFunction(@_TObject, '_TObject', cdRegister);
  S.RegisterDelphiFunction(@_GetChar, '_GetChar', cdRegister);
  S.RegisterDelphiFunction(@_SetChar, '_SetChar', cdRegister);
  S.RegisterDelphiFunction(@_GetByte, '_GetByte', cdRegister);
  S.RegisterDelphiFunction(@_SetByte, '_SetByte', cdRegister);
  S.RegisterDelphiFunction(@_GetWord, '_GetWord', cdRegister);
  S.RegisterDelphiFunction(@_SetWord, '_SetWord', cdRegister);
  S.RegisterDelphiFunction(@_GetInteger, '_GetInteger', cdRegister);
  S.RegisterDelphiFunction(@_SetInteger, '_SetInteger', cdRegister);
  S.RegisterDelphiFunction(@_GetSingle, '_GetSingle', cdRegister);
  S.RegisterDelphiFunction(@_SetSingle, '_SetSingle', cdRegister);
  S.RegisterDelphiFunction(@_GetDouble, '_GetDouble', cdRegister);
  S.RegisterDelphiFunction(@_SetDouble, '_SetDouble', cdRegister);
  S.RegisterDelphiFunction(@ChDir_P, 'ChDir', cdRegister);
  S.RegisterDelphiFunction(@MkDir_P, 'MkDir', cdRegister);
  S.RegisterDelphiFunction(@ParamCount, 'ParamCount', cdRegister);
  S.RegisterDelphiFunction(@ParamStr, 'ParamStr', cdRegister);
  S.RegisterDelphiFunction(@Randomize, 'Randomize', cdRegister);
  S.RegisterDelphiFunction(@Random_P, 'Random', cdRegister);
  S.RegisterDelphiFunction(@RmDir_P, 'RmDir', cdRegister);
  S.RegisterDelphiFunction(@UpCase, 'UpCase', cdRegister);
{$IFDEF COMPILER6_UP}
  S.RegisterDelphiFunction(@UTF8Encode, 'UTF8Encode', cdRegister);
  S.RegisterDelphiFunction(@UTF8Decode, 'UTF8Decode', cdRegister);
  S.RegisterDelphiFunction(@AnsiToUtf8, 'AnsiToUtf8', cdRegister);
  S.RegisterDelphiFunction(@Utf8ToAnsi, 'Utf8ToAnsi', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@GetMemory, 'GetMemory', CdCdecl);
  S.RegisterDelphiFunction(@FreeMemory, 'FreeMemory', CdCdecl);
  S.RegisterDelphiFunction(@ReallocMemory, 'ReallocMemory', CdCdecl);
  S.RegisterDelphiFunction(@_GetMem, 'GetMem', cdRegister);
  S.RegisterDelphiFunction(@_FreeMem, 'FreeMem', cdRegister);
end;

procedure RIRegister_System(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TObject(CL);
  RIRegister_TInterfacedObject(CL);
end;

{ TPSImport_System }

procedure TPSImport_System.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_System(CompExec.Comp);
end;

procedure TPSImport_System.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_System(ri);
  RIRegister_System_Routines(CompExec.Exec);
end;

end.

