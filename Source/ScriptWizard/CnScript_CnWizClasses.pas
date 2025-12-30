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

unit CnScript_CnWizClasses;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本类 CnWizClasses 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 7.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2015.05.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;

type
(*----------------------------------------------------------------------------*)
  TPSImport_CnWizClasses = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_TCnContextMenuExecutor(CL: TPSPascalCompiler);
procedure SIRegister_TCnBaseMenuExecutor(CL: TPSPascalCompiler);
procedure SIRegister_TCnRepositoryWizard(CL: TPSPascalCompiler);
procedure SIRegister_TCnSubMenuWizard(CL: TPSPascalCompiler);
procedure SIRegister_TCnMenuWizard(CL: TPSPascalCompiler);
procedure SIRegister_TCnActionWizard(CL: TPSPascalCompiler);
procedure SIRegister_TCnIconWizard(CL: TPSPascalCompiler);
procedure SIRegister_TCnBaseWizard(CL: TPSPascalCompiler);
procedure SIRegister_CnWizClasses(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
procedure RIRegister_TCnContextMenuExecutor(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnBaseMenuExecutor(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnRepositoryWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnSubMenuWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnMenuWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnActionWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnIconWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnBaseWizard(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnWizClasses(CL: TPSRuntimeClassImporter);

implementation


uses
   Windows
  ,Graphics
  ,Menus
  ,ActnList
  ,IniFiles
  ,ToolsAPI
  ,Registry
  ,ComCtrls
  ,Forms
  ,CnHashMap
  ,CnWizIni
  ,CnWizShortCut
  ,CnWizMenuAction
  ,CnIni
  ,CnWizConsts
  ,CnPopupMenu
  ,CnWizClasses
  ;


(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnContextMenuExecutor(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnBaseMenuExecutor', 'TCnContextMenuExecutor') do
  with CL.AddClassN(CL.FindClass('TCnBaseMenuExecutor'),'TCnContextMenuExecutor') do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('OnExecute', 'TNotifyEvent', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnBaseMenuExecutor(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnBaseMenuExecutor') do
  with CL.AddClassN(CL.FindClass('TObject'),'TCnBaseMenuExecutor') do
  begin
    RegisterMethod('Constructor Create( OwnWizard : TCnBaseWizard)');
    RegisterMethod('Function GetActive : Boolean');
    RegisterMethod('Function GetCaption : string');
    RegisterMethod('Function GetHint : string');
    RegisterMethod('Function GetEnabled : Boolean');
    RegisterMethod('Procedure Prepare');
    RegisterMethod('Function Execute : Boolean');
    RegisterProperty('Wizard', 'TCnBaseWizard', iptr);
    RegisterProperty('Tag', 'Integer', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnRepositoryWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnIconWizard', 'TCnRepositoryWizard') do
  with CL.AddClassN(CL.FindClass('TCnIconWizard'),'TCnRepositoryWizard') do
  begin
    RegisterMethod('Function GetPage : string');
    RegisterMethod('Function GetGlyph : Cardinal');
    RegisterMethod('Function GetGlyph : HICON');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnSubMenuWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnMenuWizard', 'TCnSubMenuWizard') do
  with CL.AddClassN(CL.FindClass('TCnMenuWizard'),'TCnSubMenuWizard') do
  begin
    RegisterMethod('Procedure AcquireSubActions');
    RegisterMethod('Procedure ClearSubActions');
    RegisterMethod('Procedure RefreshSubActions');
    RegisterProperty('SubActionCount', 'Integer', iptr);
    RegisterProperty('SubMenus', 'TMenuItem Integer', iptr);
    RegisterProperty('SubActions', 'TCnWizMenuAction Integer', iptr);
    RegisterMethod('Function ActionByCommand( const ACommand : string) : TCnWizAction');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnMenuWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnActionWizard', 'TCnMenuWizard') do
  with CL.AddClassN(CL.FindClass('TCnActionWizard'),'TCnMenuWizard') do
  begin
    RegisterProperty('Menu', 'TMenuItem', iptr);
    RegisterProperty('Action', 'TCnWizMenuAction', iptr);
    RegisterProperty('MenuOrder', 'Integer', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnActionWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnIDEEnhanceWizard', 'TCnActionWizard') do
  with CL.AddClassN(CL.FindClass('TCnIDEEnhanceWizard'),'TCnActionWizard') do
  begin
    RegisterProperty('ImageIndex', 'Integer', iptr);
    RegisterProperty('Action', 'TCnWizAction', iptr);
    RegisterMethod('Function EnableShortCut : Boolean');
    RegisterMethod('Procedure RefreshAction');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnIconWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnBaseWizard', 'TCnIconWizard') do
  with CL.AddClassN(CL.FindClass('TCnBaseWizard'),'TCnIconWizard') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnBaseWizard(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TNotifierObject', 'TCnBaseWizard') do
  with CL.AddClassN(CL.FindClass('TNotifierObject'),'TCnBaseWizard') do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Function WizardName : string');
    RegisterMethod('Function GetAuthor : string');
    RegisterMethod('Function GetComment : string');
    RegisterMethod('Function GetSearchContent : string');
    RegisterMethod('Procedure DebugComand( Cmds : TStrings; Results : TStrings)');
    RegisterMethod('Function GetState : TWizardState');
    RegisterMethod('Procedure Execute');
    RegisterMethod('Procedure Loaded');
    RegisterMethod('Procedure LaterLoaded');
    RegisterMethod('Function IsInternalWizard : Boolean');
    RegisterMethod('Procedure GetWizardInfo( var Name, Author, Email, Comment : string)');
    RegisterMethod('Procedure Config');
    RegisterMethod('Procedure LanguageChanged( Sender : TObject)');
    RegisterMethod('Procedure LoadSettings( Ini : TCustomIniFile)');
    RegisterMethod('Procedure SaveSettings( Ini : TCustomIniFile)');
    RegisterMethod('Procedure ResetSettings( Ini : TCustomIniFile)');
    RegisterMethod('Function GetIDStr : string');
    RegisterMethod('Function CreateIniFile( CompilerSection : Boolean) : TCustomIniFile');
    RegisterMethod('Procedure DoLoadSettings');
    RegisterMethod('Procedure DoSaveSettings');
    RegisterMethod('Procedure DoResetSettings');
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('HasConfig', 'Boolean', iptr);
    RegisterProperty('WizardIndex', 'Integer', iptrw);
    RegisterProperty('Icon', 'TIcon', iptr);
    RegisterProperty('BigIcon', 'TIcon', iptr);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CnWizClasses(CL: TPSPascalCompiler);
begin
  SIRegister_TCnBaseWizard(CL);
  //CL.AddTypeS('TCnWizardClass', 'class of TCnBaseWizard');
  SIRegister_TCnIconWizard(CL);
  CL.AddClassN(CL.FindClass('TOBJECT'),'TCnIDEEnhanceWizard');
  SIRegister_TCnActionWizard(CL);
  SIRegister_TCnMenuWizard(CL);
  SIRegister_TCnSubMenuWizard(CL);
  SIRegister_TCnRepositoryWizard(CL);
  CL.AddClassN(CL.FindClass('TOBJECT'),'TCnUnitWizard');
  CL.AddClassN(CL.FindClass('TOBJECT'),'TCnFormWizard');
  CL.AddClassN(CL.FindClass('TOBJECT'),'TCnProjectWizard');
  SIRegister_TCnBaseMenuExecutor(CL);
  SIRegister_TCnContextMenuExecutor(CL);
 //CL.AddDelphiFunction('Procedure RegisterCnWizard( const AClass : TCnWizardClass)');
 //CL.AddDelphiFunction('Function GetCnWizardClass( const ClassName : string) : TCnWizardClass');
 CL.AddDelphiFunction('Function GetCnWizardClassCount : Integer');
 //CL.AddDelphiFunction('Function GetCnWizardClassByIndex( const Index : Integer) : TCnWizardClass');
 //CL.AddDelphiFunction('Function GetCnWizardTypeNameFromClass( AClass : TClass) : string');
 //CL.AddDelphiFunction('Function GetCnWizardTypeName( AWizard : TCnBaseWizard) : string');
 CL.AddDelphiFunction('Procedure GetCnWizardInfoStrs( AWizard : TCnBaseWizard; Infos : TStrings)');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorOnExecute_W(Self: TCnContextMenuExecutor; const T: TNotifyEvent);
begin Self.OnExecute := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorOnExecute_R(Self: TCnContextMenuExecutor; var T: TNotifyEvent);
begin T := Self.OnExecute; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorEnabled_W(Self: TCnContextMenuExecutor; const T: Boolean);
begin Self.Enabled := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorEnabled_R(Self: TCnContextMenuExecutor; var T: Boolean);
begin T := Self.Enabled; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorActive_W(Self: TCnContextMenuExecutor; const T: Boolean);
begin Self.Active := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorActive_R(Self: TCnContextMenuExecutor; var T: Boolean);
begin T := Self.Active; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorHint_W(Self: TCnContextMenuExecutor; const T: string);
begin Self.Hint := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorHint_R(Self: TCnContextMenuExecutor; var T: string);
begin T := Self.Hint; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorCaption_W(Self: TCnContextMenuExecutor; const T: string);
begin Self.Caption := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorCaption_R(Self: TCnContextMenuExecutor; var T: string);
begin T := Self.Caption; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseMenuExecutorTag_W(Self: TCnBaseMenuExecutor; const T: Integer);
begin Self.Tag := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseMenuExecutorTag_R(Self: TCnBaseMenuExecutor; var T: Integer);
begin T := Self.Tag; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseMenuExecutorWizard_R(Self: TCnBaseMenuExecutor; var T: TCnBaseWizard);
begin T := Self.Wizard; end;

(*----------------------------------------------------------------------------*)
procedure TCnSubMenuWizardSubActions_R(Self: TCnSubMenuWizard; var T: TCnWizMenuAction; const t1: Integer);
begin T := Self.SubActions[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnSubMenuWizardSubMenus_R(Self: TCnSubMenuWizard; var T: TMenuItem; const t1: Integer);
begin T := Self.SubMenus[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnSubMenuWizardSubActionCount_R(Self: TCnSubMenuWizard; var T: Integer);
begin T := Self.SubActionCount; end;

(*----------------------------------------------------------------------------*)
procedure TCnMenuWizardMenuOrder_W(Self: TCnMenuWizard; const T: Integer);
begin Self.MenuOrder := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnMenuWizardMenuOrder_R(Self: TCnMenuWizard; var T: Integer);
begin T := Self.MenuOrder; end;

(*----------------------------------------------------------------------------*)
procedure TCnMenuWizardAction_R(Self: TCnMenuWizard; var T: TCnWizMenuAction);
begin T := Self.Action; end;

(*----------------------------------------------------------------------------*)
procedure TCnMenuWizardMenu_R(Self: TCnMenuWizard; var T: TMenuItem);
begin T := Self.Menu; end;

(*----------------------------------------------------------------------------*)
procedure TCnActionWizardAction_R(Self: TCnActionWizard; var T: TCnWizAction);
begin T := Self.Action; end;

(*----------------------------------------------------------------------------*)
procedure TCnActionWizardImageIndex_R(Self: TCnActionWizard; var T: Integer);
begin T := Self.ImageIndex; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardBigIcon_R(Self: TCnBaseWizard; var T: TIcon);
begin T := Self.BigIcon; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardIcon_R(Self: TCnBaseWizard; var T: TIcon);
begin T := Self.Icon; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardWizardIndex_W(Self: TCnBaseWizard; const T: Integer);
begin Self.WizardIndex := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardWizardIndex_R(Self: TCnBaseWizard; var T: Integer);
begin T := Self.WizardIndex; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardHasConfig_R(Self: TCnBaseWizard; var T: Boolean);
begin T := Self.HasConfig; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardActive_W(Self: TCnBaseWizard; const T: Boolean);
begin Self.Active := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBaseWizardActive_R(Self: TCnBaseWizard; var T: Boolean);
begin T := Self.Active; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@RegisterCnWizard, 'RegisterCnWizard', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardClass, 'GetCnWizardClass', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardClassCount, 'GetCnWizardClassCount', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardClassByIndex, 'GetCnWizardClassByIndex', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardTypeNameFromClass, 'GetCnWizardTypeNameFromClass', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardTypeName, 'GetCnWizardTypeName', cdRegister);
 S.RegisterDelphiFunction(@GetCnWizardInfoStrs, 'GetCnWizardInfoStrs', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnContextMenuExecutor(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnContextMenuExecutor) do
  begin
    RegisterVirtualConstructor(@TCnContextMenuExecutor.Create, 'Create');
    RegisterPropertyHelper(@TCnContextMenuExecutorCaption_R,@TCnContextMenuExecutorCaption_W,'Caption');
    RegisterPropertyHelper(@TCnContextMenuExecutorHint_R,@TCnContextMenuExecutorHint_W,'Hint');
    RegisterPropertyHelper(@TCnContextMenuExecutorActive_R,@TCnContextMenuExecutorActive_W,'Active');
    RegisterPropertyHelper(@TCnContextMenuExecutorEnabled_R,@TCnContextMenuExecutorEnabled_W,'Enabled');
    RegisterPropertyHelper(@TCnContextMenuExecutorOnExecute_R,@TCnContextMenuExecutorOnExecute_W,'OnExecute');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnBaseMenuExecutor(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnBaseMenuExecutor) do
  begin
    RegisterVirtualConstructor(@TCnBaseMenuExecutor.Create, 'Create');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.GetActive, 'GetActive');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.GetCaption, 'GetCaption');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.GetHint, 'GetHint');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.GetEnabled, 'GetEnabled');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.Prepare, 'Prepare');
    RegisterVirtualMethod(@TCnBaseMenuExecutor.Execute, 'Execute');
    RegisterPropertyHelper(@TCnBaseMenuExecutorWizard_R,nil,'Wizard');
    RegisterPropertyHelper(@TCnBaseMenuExecutorTag_R,@TCnBaseMenuExecutorTag_W,'Tag');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnRepositoryWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnRepositoryWizard) do
  begin
    RegisterMethod(@TCnRepositoryWizard.GetPage, 'GetPage');
    RegisterMethod(@TCnRepositoryWizard.GetGlyph, 'GetGlyph');
    RegisterMethod(@TCnRepositoryWizard.GetGlyph, 'GetGlyph');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnSubMenuWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnSubMenuWizard) do
  begin
    RegisterVirtualMethod(@TCnSubMenuWizard.AcquireSubActions, 'AcquireSubActions');
    RegisterVirtualMethod(@TCnSubMenuWizard.ClearSubActions, 'ClearSubActions');
    RegisterVirtualMethod(@TCnSubMenuWizard.RefreshSubActions, 'RefreshSubActions');
    RegisterPropertyHelper(@TCnSubMenuWizardSubActionCount_R,nil,'SubActionCount');
    RegisterPropertyHelper(@TCnSubMenuWizardSubMenus_R,nil,'SubMenus');
    RegisterPropertyHelper(@TCnSubMenuWizardSubActions_R,nil,'SubActions');
    RegisterMethod(@TCnSubMenuWizard.ActionByCommand, 'ActionByCommand');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnMenuWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnMenuWizard) do
  begin
    RegisterPropertyHelper(@TCnMenuWizardMenu_R,nil,'Menu');
    RegisterPropertyHelper(@TCnMenuWizardAction_R,nil,'Action');
    RegisterPropertyHelper(@TCnMenuWizardMenuOrder_R,@TCnMenuWizardMenuOrder_W,'MenuOrder');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnActionWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnActionWizard) do
  begin
    RegisterPropertyHelper(@TCnActionWizardImageIndex_R,nil,'ImageIndex');
    RegisterPropertyHelper(@TCnActionWizardAction_R,nil,'Action');
    RegisterVirtualMethod(@TCnActionWizard.EnableShortCut, 'EnableShortCut');
    RegisterVirtualMethod(@TCnActionWizard.RefreshAction, 'RefreshAction');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnIconWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnIconWizard) do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnBaseWizard(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnBaseWizard) do
  begin
    RegisterVirtualConstructor(@TCnBaseWizard.Create, 'Create');
    RegisterMethod(@TCnBaseWizard.WizardName, 'WizardName');
    RegisterVirtualMethod(@TCnBaseWizard.GetAuthor, 'GetAuthor');
    RegisterVirtualMethod(@TCnBaseWizard.GetComment, 'GetComment');
    RegisterVirtualMethod(@TCnBaseWizard.GetSearchContent, 'GetSearchContent');
    RegisterVirtualMethod(@TCnBaseWizard.DebugComand, 'DebugComand');
    RegisterVirtualMethod(@TCnBaseWizard.GetState, 'GetState');
    //RegisterVirtualAbstractMethod(@TCnBaseWizard, @!.Execute, 'Execute');
    RegisterVirtualMethod(@TCnBaseWizard.Loaded, 'Loaded');
    RegisterVirtualMethod(@TCnBaseWizard.LaterLoaded, 'LaterLoaded');
    RegisterVirtualMethod(@TCnBaseWizard.IsInternalWizard, 'IsInternalWizard');
    //RegisterVirtualAbstractMethod(@TCnBaseWizard, @!.GetWizardInfo, 'GetWizardInfo');
    RegisterVirtualMethod(@TCnBaseWizard.Config, 'Config');
    RegisterVirtualMethod(@TCnBaseWizard.LanguageChanged, 'LanguageChanged');
    RegisterVirtualMethod(@TCnBaseWizard.LoadSettings, 'LoadSettings');
    RegisterVirtualMethod(@TCnBaseWizard.SaveSettings, 'SaveSettings');
    RegisterVirtualMethod(@TCnBaseWizard.ResetSettings, 'ResetSettings');
    RegisterMethod(@TCnBaseWizard.GetIDStr, 'GetIDStr');
    RegisterMethod(@TCnBaseWizard.CreateIniFile, 'CreateIniFile');
    RegisterMethod(@TCnBaseWizard.DoLoadSettings, 'DoLoadSettings');
    RegisterMethod(@TCnBaseWizard.DoSaveSettings, 'DoSaveSettings');
    RegisterMethod(@TCnBaseWizard.DoResetSettings, 'DoResetSettings');
    RegisterPropertyHelper(@TCnBaseWizardActive_R,@TCnBaseWizardActive_W,'Active');
    RegisterPropertyHelper(@TCnBaseWizardHasConfig_R,nil,'HasConfig');
    RegisterPropertyHelper(@TCnBaseWizardWizardIndex_R,@TCnBaseWizardWizardIndex_W,'WizardIndex');
    RegisterPropertyHelper(@TCnBaseWizardIcon_R,nil,'Icon');
    RegisterPropertyHelper(@TCnBaseWizardBigIcon_R,nil,'BigIcon');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnBaseWizard(CL);
  RIRegister_TCnIconWizard(CL);
  with CL.Add(TCnIDEEnhanceWizard) do
  RIRegister_TCnActionWizard(CL);
  RIRegister_TCnMenuWizard(CL);
  RIRegister_TCnSubMenuWizard(CL);
  RIRegister_TCnRepositoryWizard(CL);
  with CL.Add(TCnUnitWizard) do
  with CL.Add(TCnFormWizard) do
  with CL.Add(TCnProjectWizard) do
  RIRegister_TCnBaseMenuExecutor(CL);
  RIRegister_TCnContextMenuExecutor(CL);
end;



{ TPSImport_CnWizClasses }
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizClasses(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizClasses(ri);
  RIRegister_CnWizClasses_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)


end.
