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

unit CnEditorCodeIndent;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码块缩进工具单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.01.22 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, Menus, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizClasses,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts, CnSelectionCodeTool;

type

//==============================================================================
// 代码块缩进工具类
//==============================================================================

{ TCnEditorCodeIndent }

  TCnEditorCodeIndent = class(TCnSelectionCodeTool)
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

//==============================================================================
// 代码块反缩进工具类
//==============================================================================

{ TCnEditorCodeUnIndent }

  TCnEditorCodeUnIndent = class(TCnSelectionCodeTool)
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{ TCnEditorCodeIndent }

constructor TCnEditorCodeIndent.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := True;
end;

function TCnEditorCodeIndent.GetCaption: string;
begin
  Result := SCnEditorCodeIndentMenuCaption;
end;

function TCnEditorCodeIndent.GetHint: string;
begin
  Result := SCnEditorCodeIndentMenuHint;
end;

procedure TCnEditorCodeIndent.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeIndentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

procedure TCnEditorCodeIndent.Execute;
var
  EditView: TCnEditViewSourceInterface;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

{$IFDEF DELPHI_OTA}
  if EditView.Block <> nil then
  begin
    EditView.Block.Indent(CnOtaGetBlockIndent);
    EditView.Paint;
  end;
{$ENDIF}
end;

{ TCnEditorCodeUnIndent }

constructor TCnEditorCodeUnIndent.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := True;
end;

function TCnEditorCodeUnIndent.GetCaption: string;
begin
  Result := SCnEditorCodeUnIndentMenuCaption;
end;

function TCnEditorCodeUnIndent.GetHint: string;
begin
  Result := SCnEditorCodeUnIndentMenuHint;
end;

procedure TCnEditorCodeUnIndent.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeUnIndentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

procedure TCnEditorCodeUnIndent.Execute;
var
  EditView: TCnEditViewSourceInterface;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

{$IFDEF DELPHI_OTA}
  if EditView.Block <> nil then
  begin
    EditView.Block.Indent(-CnOtaGetBlockIndent);
    EditView.Paint;
  end;
{$ENDIF}
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeIndent);
  RegisterCnCodingToolset(TCnEditorCodeUnIndent);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
