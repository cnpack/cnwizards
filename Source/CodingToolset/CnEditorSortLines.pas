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

unit CnEditorSortLines;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：排序选择行工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.08.23 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard,
  CnWizConsts, CnEditorCodeTool, CnIni;

type

//==============================================================================
// 插入颜色工具类
//==============================================================================

{ TCnEditorSortLines }

  TCnEditorSortLines = class(TCnSelectionCodeTool)
  protected
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
  
implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{ TCnEditorSortLines }

constructor TCnEditorSortLines.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  ValidInSource := False;
  BlockMustNotEmpty := True;
end;

function DoCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareText(Trim(List[Index1]), Trim(List[Index2]));
end;

function TCnEditorSortLines.ProcessText(const Text: string): string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    Lines.CustomSort(DoCompare);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;   
end;

function TCnEditorSortLines.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorSortLines.GetCaption: string;
begin
  Result := SCnEditorSortLinesMenuCaption;
end;

function TCnEditorSortLines.GetHint: string;
begin
  Result := SCnEditorSortLinesMenuHint;
end;

procedure TCnEditorSortLines.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorSortLinesName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

initialization
  RegisterCnCodingToolset(TCnEditorSortLines);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
