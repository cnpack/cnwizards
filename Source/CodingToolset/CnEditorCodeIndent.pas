{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorCodeIndent;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�������������ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2005.01.22 V1.0
*               ������Ԫ��ʵ�ֹ���
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
// ���������������
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
// ����鷴����������
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
