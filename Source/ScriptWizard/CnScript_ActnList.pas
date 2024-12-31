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

unit CnScript_ActnList;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ActnList 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.29 V1.0
*               XE3 下的 Action 换单元了，适应性更改。
*           2006.12.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, ActnList, ImgList,
  {$IFDEF DELPHIXE3_UP} Actions, {$ENDIF}
  uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_ActnList = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TAction(CL: TPSPascalCompiler);
procedure SIRegister_TCustomAction(CL: TPSPascalCompiler);
procedure SIRegister_TActionList(CL: TPSPascalCompiler);
procedure SIRegister_TCustomActionList(CL: TPSPascalCompiler);
procedure SIRegister_TContainedAction(CL: TPSPascalCompiler);
procedure SIRegister_ActnList(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TAction(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomAction(CL: TPSRuntimeClassImporter);
procedure RIRegister_TActionList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomActionList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TContainedAction(CL: TPSRuntimeClassImporter);
procedure RIRegister_ActnList(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TAction(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomAction', 'TAction') do
  with CL.AddClass(CL.FindClass('TCustomAction'), TAction) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomAction(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TContainedAction', 'TCustomAction') do
  with CL.AddClass(CL.FindClass('TContainedAction'), TCustomAction) do
  begin
    RegisterMethod('Function DoHint( var HintStr : string) : Boolean');
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Checked', 'Boolean', iptrw);
    RegisterProperty('DisableIfNoHandler', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('HelpContext', 'THelpContext', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('ShortCut', 'TShortCut', iptrw);
    RegisterProperty('Visible', 'Boolean', iptrw);
    RegisterProperty('OnHint', 'THintEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TActionList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomActionList', 'TActionList') do
  with CL.AddClass(CL.FindClass('TCustomActionList'), TActionList) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomActionList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TCustomActionList') do
  with CL.AddClass(CL.FindClass('TComponent'), TCustomActionList) do
  begin
    RegisterMethod('Function IsShortCut( var Message : TWMKey) : Boolean');
    RegisterProperty('Actions', 'TContainedAction Integer', iptrw);
    SetDefaultPropery('Actions');
    RegisterProperty('ActionCount', 'Integer', iptr);
    RegisterProperty('Images', 'TCustomImageList', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TContainedAction(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TBasicAction', 'TContainedAction') do
  with CL.AddClass(CL.FindClass('TBasicAction'), TContainedAction) do
  begin
    RegisterProperty('ActionList', 'TCustomActionList', iptrw);
    RegisterProperty('Index', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_ActnList(CL: TPSPascalCompiler);
begin
  CL.AddClass(CL.FindClass('TOBJECT'), TCustomActionList);
  SIRegister_TContainedAction(CL);
  CL.AddTypeS('TActionEvent', 'Procedure ( Action : TBasicAction; var Handled :'
    + ' Boolean)');
  SIRegister_TCustomActionList(CL);
  SIRegister_TActionList(CL);
  CL.AddTypeS('THintEvent', 'Procedure ( var HintStr : string; var CanShow : Bo'
    + 'olean)');
  SIRegister_TCustomAction(CL);
  SIRegister_TAction(CL);
end;

(* === run-time registration functions === *)

procedure TCustomActionOnHint_W(Self: TCustomAction; const T: THintEvent);
begin
  Self.OnHint := T;
end;

procedure TCustomActionOnHint_R(Self: TCustomAction; var T: THintEvent);
begin
  T := Self.OnHint;
end;

procedure TCustomActionVisible_W(Self: TCustomAction; const T: Boolean);
begin
  Self.Visible := T;
end;

procedure TCustomActionVisible_R(Self: TCustomAction; var T: Boolean);
begin
  T := Self.Visible;
end;

procedure TCustomActionShortCut_W(Self: TCustomAction; const T: TShortCut);
begin
  Self.ShortCut := T;
end;

procedure TCustomActionShortCut_R(Self: TCustomAction; var T: TShortCut);
begin
  T := Self.ShortCut;
end;

procedure TCustomActionImageIndex_W(Self: TCustomAction; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TCustomActionImageIndex_R(Self: TCustomAction; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TCustomActionHint_W(Self: TCustomAction; const T: string);
begin
  Self.Hint := T;
end;

procedure TCustomActionHint_R(Self: TCustomAction; var T: string);
begin
  T := Self.Hint;
end;

procedure TCustomActionHelpContext_W(Self: TCustomAction; const T: THelpContext);
begin
  Self.HelpContext := T;
end;

procedure TCustomActionHelpContext_R(Self: TCustomAction; var T: THelpContext);
begin
  T := Self.HelpContext;
end;

procedure TCustomActionEnabled_W(Self: TCustomAction; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TCustomActionEnabled_R(Self: TCustomAction; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure TCustomActionDisableIfNoHandler_W(Self: TCustomAction; const T: Boolean);
begin
  Self.DisableIfNoHandler := T;
end;

procedure TCustomActionDisableIfNoHandler_R(Self: TCustomAction; var T: Boolean);
begin
  T := Self.DisableIfNoHandler;
end;

procedure TCustomActionChecked_W(Self: TCustomAction; const T: Boolean);
begin
  Self.Checked := T;
end;

procedure TCustomActionChecked_R(Self: TCustomAction; var T: Boolean);
begin
  T := Self.Checked;
end;

procedure TCustomActionCaption_W(Self: TCustomAction; const T: string);
begin
  Self.Caption := T;
end;

procedure TCustomActionCaption_R(Self: TCustomAction; var T: string);
begin
  T := Self.Caption;
end;

procedure TCustomActionListImages_W(Self: TCustomActionList; const T: TCustomImageList);
begin
  Self.Images := T;
end;

procedure TCustomActionListImages_R(Self: TCustomActionList; var T: TCustomImageList);
begin
  T := Self.Images;
end;

procedure TCustomActionListActionCount_R(Self: TCustomActionList; var T: Integer);
begin
  T := Self.ActionCount;
end;

procedure TCustomActionListActions_W(Self: TCustomActionList; const T: TContainedAction; const t1: Integer);
begin
  Self.Actions[t1] := T;
end;

procedure TCustomActionListActions_R(Self: TCustomActionList; var T: TContainedAction; const t1: Integer);
begin
  T := Self.Actions[t1];
end;

procedure TContainedActionIndex_W(Self: TContainedAction; const T: Integer);
begin
  Self.Index := T;
end;

procedure TContainedActionIndex_R(Self: TContainedAction; var T: Integer);
begin
  T := Self.Index;
end;

procedure TContainedActionActionList_W(Self: TContainedAction; const T: TCustomActionList);
begin
  Self.ActionList := T;
end;

procedure TContainedActionActionList_R(Self: TContainedAction; var T: TCustomActionList);
begin
{$IFDEF DELPHIXE3_UP}
  T := Self.ActionList as TCustomActionList;
{$ELSE}
  T := Self.ActionList;
{$ENDIF}
end;

procedure RIRegister_TAction(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TAction) do
  begin
  end;
end;

procedure RIRegister_TCustomAction(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomAction) do
  begin
    RegisterVirtualMethod(@TCustomAction.DoHint, 'DoHint');
    RegisterPropertyHelper(@TCustomActionCaption_R, @TCustomActionCaption_W, 'Caption');
    RegisterPropertyHelper(@TCustomActionChecked_R, @TCustomActionChecked_W, 'Checked');
    RegisterPropertyHelper(@TCustomActionDisableIfNoHandler_R, @TCustomActionDisableIfNoHandler_W, 'DisableIfNoHandler');
    RegisterPropertyHelper(@TCustomActionEnabled_R, @TCustomActionEnabled_W, 'Enabled');
    RegisterPropertyHelper(@TCustomActionHelpContext_R, @TCustomActionHelpContext_W, 'HelpContext');
    RegisterPropertyHelper(@TCustomActionHint_R, @TCustomActionHint_W, 'Hint');
    RegisterPropertyHelper(@TCustomActionImageIndex_R, @TCustomActionImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TCustomActionShortCut_R, @TCustomActionShortCut_W, 'ShortCut');
    RegisterPropertyHelper(@TCustomActionVisible_R, @TCustomActionVisible_W, 'Visible');
    RegisterPropertyHelper(@TCustomActionOnHint_R, @TCustomActionOnHint_W, 'OnHint');
  end;
end;

procedure RIRegister_TActionList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TActionList) do
  begin
  end;
end;

procedure RIRegister_TCustomActionList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomActionList) do
  begin
    RegisterMethod(@TCustomActionList.IsShortCut, 'IsShortCut');
    RegisterPropertyHelper(@TCustomActionListActions_R, @TCustomActionListActions_W, 'Actions');
    RegisterPropertyHelper(@TCustomActionListActionCount_R, nil, 'ActionCount');
    RegisterPropertyHelper(@TCustomActionListImages_R, @TCustomActionListImages_W, 'Images');
  end;
end;

procedure RIRegister_TContainedAction(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TContainedAction) do
  begin
    RegisterPropertyHelper(@TContainedActionActionList_R, @TContainedActionActionList_W, 'ActionList');
    RegisterPropertyHelper(@TContainedActionIndex_R, @TContainedActionIndex_W, 'Index');
  end;
end;

procedure RIRegister_ActnList(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TCustomActionList);
  RIRegister_TContainedAction(CL);
  RIRegister_TCustomActionList(CL);
  RIRegister_TActionList(CL);
  RIRegister_TCustomAction(CL);
  RIRegister_TAction(CL);
end;

{ TPSImport_ActnList }

procedure TPSImport_ActnList.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ActnList(CompExec.Comp);
end;

procedure TPSImport_ActnList.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ActnList(ri);
end;

end.

