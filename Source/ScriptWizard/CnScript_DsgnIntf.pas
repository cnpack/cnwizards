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

unit CnScript_DsgnIntf;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 DsgnIntf 注册类
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
  Windows, SysUtils, Classes, DsgnIntf, Forms, Menus,
  uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_DsgnIntf = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_IDesigner(CL: TPSPascalCompiler);
procedure SIRegister_IDesignerSelections(CL: TPSPascalCompiler);
procedure SIRegister_IImplementation(CL: TPSPascalCompiler);
procedure SIRegister_IComponent(CL: TPSPascalCompiler);
procedure SIRegister_IPersistent(CL: TPSPascalCompiler);
procedure SIRegister_IEventInfos(CL: TPSPascalCompiler);
procedure SIRegister_DsgnIntf(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_DsgnIntf_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_IDesigner(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDesignerHook', 'IDesigner') do
  with CL.AddInterface(CL.FindInterface('IDesignerHook'), IDesigner, 'IDesigner') do
  begin
    RegisterMethod('Function CreateMethod( const Name : string; TypeData : PTypeData) : TMethod', cdRegister);
    RegisterMethod('Function GetMethodName( const Method : TMethod) : string', cdRegister);
    RegisterMethod('Procedure GetMethods( TypeData : PTypeData; Proc : TGetStrProc)', cdRegister);
    RegisterMethod('Function GetPrivateDirectory : string', cdRegister);
    RegisterMethod('Procedure GetSelections( const List : IDesignerSelections)', cdRegister);
    RegisterMethod('Function MethodExists( const Name : string) : Boolean', cdRegister);
    RegisterMethod('Procedure RenameMethod( const CurName, NewName : string)', cdRegister);
    RegisterMethod('Procedure SelectComponent( Instance : TPersistent)', cdRegister);
    RegisterMethod('Procedure SetSelections( const List : IDesignerSelections)', cdRegister);
    RegisterMethod('Procedure ShowMethod( const Name : string)', cdRegister);
    RegisterMethod('Procedure GetComponentNames( TypeData : PTypeData; Proc : TGetStrProc)', cdRegister);
    RegisterMethod('Function GetComponent( const Name : string) : TComponent', cdRegister);
    RegisterMethod('Function GetComponentName( Component : TComponent) : string', cdRegister);
    RegisterMethod('Function GetObject( const Name : string) : TPersistent', cdRegister);
    RegisterMethod('Function GetObjectName( Instance : TPersistent) : string', cdRegister);
    RegisterMethod('Procedure GetObjectNames( TypeData : PTypeData; Proc : TGetStrProc)', cdRegister);
    RegisterMethod('Function MethodFromAncestor( const Method : TMethod) : Boolean', cdRegister);
    RegisterMethod('Function CreateComponent( ComponentClass : TComponentClass; Parent : TComponent; Left, Top, Width, Height : Integer) : TComponent', cdRegister);
    RegisterMethod('Function IsComponentLinkable( Component : TComponent) : Boolean', cdRegister);
    RegisterMethod('Procedure MakeComponentLinkable( Component : TComponent)', cdRegister);
    RegisterMethod('Procedure Revert( Instance : TPersistent; PropInfo : PPropInfo)', cdRegister);
    RegisterMethod('Function GetIsDormant : Boolean', cdRegister);
    RegisterMethod('Function HasInterface : Boolean', cdRegister);
    RegisterMethod('Function HasInterfaceMember( const Name : string) : Boolean', cdRegister);
    RegisterMethod('Procedure AddToInterface( InvKind : Integer; const Name : string; VT : Word; const TypeInfo : string)', cdRegister);
    RegisterMethod('Procedure GetProjectModules( Proc : TGetModuleProc)', cdRegister);
    RegisterMethod('Function GetAncestorDesigner : IFormDesigner', cdRegister);
    RegisterMethod('Function IsSourceReadOnly : Boolean', cdRegister);
    RegisterMethod('Function GetContainerWindow : TWinControl', cdRegister);
    RegisterMethod('Procedure SetContainerWindow( const NewContainer : TWinControl)', cdRegister);
    RegisterMethod('Function GetScrollRanges( const ScrollPosition : TPoint) : TPoint', cdRegister);
    RegisterMethod('Procedure Edit( const Component : IComponent)', cdRegister);
    RegisterMethod('Function BuildLocalMenu( Base : TPopupMenu; Filter : TLocalMenuFilters) : TPopupMenu', cdRegister);
    RegisterMethod('Procedure ChainCall( const MethodName, InstanceName, InstanceMethod : string; TypeData : PTypeData)', cdRegister);
    RegisterMethod('Procedure CopySelection', cdRegister);
    RegisterMethod('Procedure CutSelection', cdRegister);
    RegisterMethod('Function CanPaste : Boolean', cdRegister);
    RegisterMethod('Procedure PasteSelection', cdRegister);
    RegisterMethod('Procedure DeleteSelection', cdRegister);
    RegisterMethod('Procedure ClearSelection', cdRegister);
    RegisterMethod('Procedure NoSelection', cdRegister);
    RegisterMethod('Procedure ModuleFileNames( var ImplFileName, IntfFileName, FormFileName : string)', cdRegister);
    RegisterMethod('Function GetRootClassName : string', cdRegister);
  end;
end;

procedure SIRegister_IDesignerSelections(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IDesignerSelections') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IDesignerSelections, 'IDesignerSelections') do
  begin
    RegisterMethod('Function Add( const Item : IPersistent) : Integer', cdRegister);
    RegisterMethod('Function Equals( const List : IDesignerSelections) : Boolean', cdRegister);
    RegisterMethod('Function Get( Index : Integer) : IPersistent', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
  end;
end;

procedure SIRegister_IImplementation(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IImplementation') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IImplementation, 'IImplementation') do
  begin
    RegisterMethod('Function GetInstance : TObject', cdRegister);
  end;
end;

procedure SIRegister_IComponent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IPersistent', 'IComponent') do
  with CL.AddInterface(CL.FindInterface('IPersistent'), IComponent, 'IComponent') do
  begin
    RegisterMethod('Function FindComponent( const Name : string) : IComponent', cdRegister);
    RegisterMethod('Function GetComponentCount : Integer', cdRegister);
    RegisterMethod('Function GetComponents( Index : Integer) : IComponent', cdRegister);
    RegisterMethod('Function GetComponentState : TComponentState', cdRegister);
    RegisterMethod('Function GetComponentStyle : TComponentStyle', cdRegister);
    RegisterMethod('Function GetDesignInfo : TSmallPoint', cdRegister);
    RegisterMethod('Function GetDesignOffset : TPoint', cdRegister);
    RegisterMethod('Function GetDesignSize : TPoint', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetOwner : IComponent', cdRegister);
    RegisterMethod('Function GetParent : IComponent', cdRegister);
    RegisterMethod('Procedure SetDesignInfo( const Point : TSmallPoint)', cdRegister);
    RegisterMethod('Procedure SetDesignOffset( const Point : TPoint)', cdRegister);
    RegisterMethod('Procedure SetDesignSize( const Point : TPoint)', cdRegister);
    RegisterMethod('Procedure SetName( const Value : string)', cdRegister);
  end;
end;

procedure SIRegister_IPersistent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IPersistent') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IPersistent, 'IPersistent') do
  begin
    RegisterMethod('Procedure DestroyObject', cdRegister);
    RegisterMethod('Function Equals( const Other : IPersistent) : Boolean', cdRegister);
    RegisterMethod('Function GetClassname : string', cdRegister);
    RegisterMethod('Function GetEventInfos : IEventInfos', cdRegister);
    RegisterMethod('Function GetNamePath : string', cdRegister);
    RegisterMethod('Function GetOwner : IPersistent', cdRegister);
    RegisterMethod('Function InheritsFrom( const Classname : string) : Boolean', cdRegister);
    RegisterMethod('Function IsComponent : Boolean', cdRegister);
    RegisterMethod('Function IsControl : Boolean', cdRegister);
    RegisterMethod('Function IsWinControl : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IEventInfos(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IEventInfos') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IEventInfos, 'IEventInfos') do
  begin
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetEventValue( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetEventName( Index : Integer) : string', cdRegister);
    RegisterMethod('Procedure ClearEvent( Index : Integer)', cdRegister);
  end;
end;

procedure SIRegister_DsgnIntf(CL: TPSPascalCompiler);
begin
  SIRegister_IEventInfos(CL);
  SIRegister_IPersistent(CL);
  SIRegister_IComponent(CL);
  SIRegister_IImplementation(CL);
  CL.AddDelphiFunction('Function MakeIPersistent( Instance : TPersistent) : IPersistent');
  CL.AddDelphiFunction('Function ExtractPersistent( const Intf : IUnknown) : TPersistent');
  CL.AddDelphiFunction('Function TryExtractPersistent( const Intf : IUnknown) : TPersistent');
  CL.AddDelphiFunction('Function MakeIComponent( Instance : TComponent) : IComponent');
  CL.AddDelphiFunction('Function ExtractComponent( const Intf : IUnknown) : TComponent');
  CL.AddDelphiFunction('Function TryExtractComponent( const Intf : IUnknown) : TComponent');
  SIRegister_IDesignerSelections(CL);
  CL.AddDelphiFunction('Function CreateSelectionList : IDesignerSelections');
  CL.AddTypeS('TLocalMenuFilter', '( lmModule, lmComponent, lmDesigner )');
  CL.AddTypeS('TLocalMenuFilters', 'set of TLocalMenuFilter');
  SIRegister_IDesigner(CL);
  CL.AddTypeS('IFormDesigner', 'IDesigner');
end;

(* === run-time registration functions === *)

procedure RIRegister_DsgnIntf_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@MakeIPersistent, 'MakeIPersistent', cdRegister);
  S.RegisterDelphiFunction(@ExtractPersistent, 'ExtractPersistent', cdRegister);
  S.RegisterDelphiFunction(@TryExtractPersistent, 'TryExtractPersistent', cdRegister);
  S.RegisterDelphiFunction(@MakeIComponent, 'MakeIComponent', cdRegister);
  S.RegisterDelphiFunction(@ExtractComponent, 'ExtractComponent', cdRegister);
  S.RegisterDelphiFunction(@TryExtractComponent, 'TryExtractComponent', cdRegister);
  S.RegisterDelphiFunction(@CreateSelectionList, 'CreateSelectionList', cdRegister);
end;

{ TPSImport_DsgnIntf }

procedure TPSImport_DsgnIntf.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_DsgnIntf(CompExec.Comp);
end;

procedure TPSImport_DsgnIntf.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_DsgnIntf_Routines(CompExec.Exec); // comment it if no routines
end;

end.

