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

unit CnTestEditPosMoveWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试编辑器中插入字符串的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试在编辑器中插入字符串，分 Ansi/Utf8/Unicode 三种。
* 开发平台：Win7 + Delphi 5.01
* 兼容测试：Win7 + D5/2007/2009
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.04.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// 测试编辑器EditPosition移动的子菜单专家
//==============================================================================

{ TCnTestEditPosMoveWizard }

  TCnTestEditPosMoveWizard = class(TCnSubMenuWizard)
  private
    FIdCnOtaGotoEditPosAndRepaint: Integer;
    FIdMove: Integer;
    FIdMoveReal: Integer;
    FIdMoveRelative: Integer;
    FIdDelete: Integer;
    FIdBackspaceDelete: Integer;
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

//==============================================================================
// 测试编辑器EditPosition移动的子菜单专家
//==============================================================================

{ TCnTestEditPosMoveWizard }

procedure TCnTestEditPosMoveWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditPosMoveWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditPosMoveWizard.AcquireSubActions;
begin
  FIdCnOtaGotoEditPosAndRepaint := RegisterASubAction('CnOtaGotoEditPosAndRepaint',
    'Test CnOtaGotoEditPosAndRepaint', 0, 'Test CnOtaGotoEditPosAndRepaint',
    'CnOtaGotoEditPosAndRepaint');
  FIdMove := RegisterASubAction('CnTestEditPositionMove',
    'Test EditPosition Move', 0, 'Test EditPosition Move',
    'CnTestEditPositionMove');
  FIdMoveReal := RegisterASubAction('CnTestEditPositionMoveReal',
    'Test EditPosition MoveReal', 0, 'Test EditPosition MoveReal',
    'CnTestEditPositionMoveReal');
  FIdMoveRelative := RegisterASubAction('CnTestEditPositionMoveRelative',
    'Test EditPosition MoveRelative', 0, 'Test EditPosition MoveRelative',
    'CnTestEditPositionMoveRelative');
  FIdDelete := RegisterASubAction('CnTestEditPositionDelete',
    'Test EditPosition Delete', 0, 'Test EditPosition Delete',
    'CnTestEditPositionDelete');
  FIdBackspaceDelete := RegisterASubAction('CnTestEditPositionBackspaceDelete',
    'Test EditPosition BackspaceDelete', 0, 'Test EditPosition BackspaceDelete',
    'CnTestEditPositionBackspaceDelete');
end;

function TCnTestEditPosMoveWizard.GetCaption: string;
begin
  Result := 'Test EditPosition Move';
end;

function TCnTestEditPosMoveWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditPosMoveWizard.GetHint: string;
begin
  Result := 'Test EditPosition Move';
end;

function TCnTestEditPosMoveWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditPosMoveWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditPosition Move Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test EditPosition Move Wizard';
end;

procedure TCnTestEditPosMoveWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditPosMoveWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditPosMoveWizard.SubActionExecute(Index: Integer);
var
  S: string;
  Line, Col: Integer;
  EditView: IOTAEditView;
  EditPosition: IOTAEditPosition;
begin
  if not Active then Exit;

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Line := EditView.CursorPos.Line;
  S := CnInputBox('Enter Column', 'Enter Column Value:', '3');
  Col := StrToIntDef(S, 3);

  if Index = FIdCnOtaGotoEditPosAndRepaint then
  begin
    CnOtaGotoEditPosAndRepaint(EditView, Line, Col);
  end
  else
  begin
    EditPosition := CnOtaGetEditPosition;
    if Assigned(EditPosition) then
    begin
      if Index = FIdMove then
        EditPosition.Move(Line, Col)
      else if Index = FIdMoveReal then
        EditPosition.MoveReal(Line, Col)
      else if Index = FIdMoveRelative then
        EditPosition.MoveRelative(0, Col)
      else if Index = FIdDelete then
        EditPosition.Delete(Col)
      else if Index = FIdBackspaceDelete then
        EditPosition.BackspaceDelete(Col);

      EditView.Paint;
    end;
  end;
end;

procedure TCnTestEditPosMoveWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditPosMoveWizard); // 注册专家

end.
