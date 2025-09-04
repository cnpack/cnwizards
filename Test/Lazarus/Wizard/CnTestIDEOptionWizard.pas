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

unit CnTestIDEOptionWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试 IDE 选项的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 中的 IDE 选项。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.09.04 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf, LazIDEIntf, IDEOptEditorIntf, IDEOptionsIntf, CompOptsIntf;

type

//==============================================================================
// 测试 IDE 选项的子菜单专家
//==============================================================================

{ TCnTestIDEOptionWizard }

  TCnTestIDEOptionWizard = class(TCnSubMenuWizard)
  private
    FIdPrintIDEGroup: Integer;
    FIdPrintEditorOption: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 测试 IDE 选项的子菜单专家
//==============================================================================

{ TCnTestIDEOptionWizard }

procedure TCnTestIDEOptionWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestIDEOptionWizard.Create;
begin
  inherited;

end;

procedure TCnTestIDEOptionWizard.AcquireSubActions;
begin
  FIdPrintIDEGroup := RegisterASubAction('CnLazPrintIDEGroup',
    'Test CnLazPrintIDEGroup', 0, 'Test CnLazPrintIDEGroup',
    'CnLazPrintIDEGroup');
  FIdPrintEditorOption := RegisterASubAction('CnLazPrintEditorOption',
    'Test CnLazPrintEditorOption', 0, 'Test CnLazPrintEditorOption',
    'CnLazPrintEditorOption');
end;

function TCnTestIDEOptionWizard.GetCaption: string;
begin
  Result := 'Test IDE Option';
end;

function TCnTestIDEOptionWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestIDEOptionWizard.GetHint: string;
begin
  Result := 'Test IDE Option Wizard';
end;

function TCnTestIDEOptionWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestIDEOptionWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test IDE Option Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test IDE Option Wizard';
end;

procedure TCnTestIDEOptionWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIDEOptionWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIDEOptionWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
  Rec: PIDEOptionsGroupRec;

  procedure PrintEditorRecs(ARec: PIDEOptionsEditorRec; Indent: Integer);
  begin
    CnDebugger.TraceFmt('%sIndex %d Editor %s', [StringOfChar(' ', Indent),
      ARec^.Index, ARec^.EditorClass.ClassName]);
  end;

  procedure PrintGroupRecs(ARec: PIDEOptionsGroupRec; Indent: Integer);
  var
    J: Integer;
  begin
    CnDebugger.TraceFmt('%sIndex %d Group %s', [StringOfChar(' ', Indent), ARec^.Index, ARec^.GroupClass.ClassName]);
    if ARec^.Items <> nil then
    begin
      for J := 0 to ARec^.Items.Count - 1 do
        PrintEditorRecs(ARec^.Items[J], Indent + 4);
    end;
  end;

begin
  if not Active then Exit;

  if Index = FIdPrintIDEGroup then
  begin
    CnDebugger.TraceMsg('IDEEditorGroups Count ' + IntToStr(IDEEditorGroups.Count));
    for I := 0 to IDEEditorGroups.Count - 1 do
    begin
      Rec := IDEEditorGroups[I];
      PrintGroupRecs(Rec, 0);
    end;
  end
  else if Index = FIdPrintEditorOption then
  begin
    CnDebugger.TraceMsg('IDEEditorOptions TabPosition ' + IntToStr(Ord(IDEEditorOptions.TabPosition)));
    CnDebugger.TraceMsg('IDEEditorOptions ClassName ' + IDEEditorOptions.ClassName);
    if IDEEditorOptions.GetInstance <> nil then
      CnDebugger.TraceMsg('IDEEditorOptions GetInstance ClassName ' + IDEEditorOptions.GetInstance.ClassName);

    CnDebugger.EvaluateObject(IDEEditorOptions);
  end;
end;

procedure TCnTestIDEOptionWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestIDEOptionWizard); // 注册专家

end.
