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

unit CnEditorInsertColor;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：插入颜色工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.07.30 V1.0
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

{ TCnEditorInsertColor }

  TCnEditorInsertColor = class(TCnBaseCodingToolset)
  private
    dlgColor: TColorDialog;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

const
  csColor = 'Color';
  csCustomColors = 'CustomColors';

{ TCnEditorInsertColor }

constructor TCnEditorInsertColor.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  dlgColor := TColorDialog.Create(nil);
  dlgColor.Options := [cdFullOpen, cdAnyColor];
end;

destructor TCnEditorInsertColor.Destroy;
begin
  dlgColor.Free;
  inherited;
end;

function TCnEditorInsertColor.GetCaption: string;
begin
  Result := SCnEditorInsertColorMenuCaption;
end;

function TCnEditorInsertColor.GetHint: string;
begin
  Result := SCnEditorInsertColorMenuHint;
end;

procedure TCnEditorInsertColor.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorInsertColorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

procedure TCnEditorInsertColor.Execute;
var
  Text: string;
begin
  try
    Text := Trim(CnOtaGetCurrentSelection);
    if Text <> '' then
      dlgColor.Color := StringToColor(Text);
  except
    ;
  end;
            
  if dlgColor.Execute then
  begin
    CnOtaInsertTextToCurSource(ColorToString(dlgColor.Color), ipCur);
  end;  
end;

procedure TCnEditorInsertColor.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    dlgColor.Color := ReadColor('', csColor, dlgColor.Color);
    ReadStrings('', csCustomColors, dlgColor.CustomColors);
  finally
    Free;
  end;
end;

procedure TCnEditorInsertColor.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteColor('', csColor, dlgColor.Color);
    WriteStrings('', csCustomColors, dlgColor.CustomColors);
  finally
    Free;
  end;
end;

function TCnEditorInsertColor.GetState: TWizardState;
begin
  Result := inherited GetState;
  if (wsEnabled in Result) and not CurrentIsSource then
    Result := [];
end;

initialization
  RegisterCnCodingToolset(TCnEditorInsertColor);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
