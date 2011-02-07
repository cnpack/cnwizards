{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorFontZoom;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器字体缩放单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin XP SP3 + Delphi 5.01
* 兼容测试：
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id: CnEditorFontZoom.pas 418 2010-02-08 04:53:54Z zhoujingyu $
* 修改记录：2010.06.10 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizClasses, CnWizUtils, CnConsts, CnCommon,
  Menus, CnEditorWizard, CnWizConsts, CnEditorCodeTool;

type

//==============================================================================
// 编辑器字体增大
//==============================================================================

{ TCnEditorFontInc }

  TCnEditorFontInc = class(TCnEditorCodeTool)
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

//==============================================================================
// 编辑器字体缩小
//==============================================================================

{ TCnEditorFontDec }

  TCnEditorFontDec = class(TCnEditorCodeTool)
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

{ TCnEditorFontInc }

constructor TCnEditorFontInc.Create(AOwner: TCnEditorWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := False;
end;

function TCnEditorFontInc.GetCaption: string;
begin
  Result := SCnEditorFontIncMenuCaption;
end;

function TCnEditorFontInc.GetHint: string;
begin
  Result := SCnEditorFontIncMenuHint;
end;

procedure TCnEditorFontInc.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorFontIncName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

procedure TCnEditorFontInc.Execute;
var
  Option: IOTAEditOptions;
begin
  Option := CnOtaGetEditOptions;
  if Assigned(Option) then
    Option.FontSize := Round(Option.FontSize * 1.1);
end;

{ TCnEditorFontDec }

constructor TCnEditorFontDec.Create(AOwner: TCnEditorWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := False;
end;

function TCnEditorFontDec.GetCaption: string;
begin
  Result := SCnEditorFontDecMenuCaption;
end;

function TCnEditorFontDec.GetHint: string;
begin
  Result := SCnEditorFontDecMenuHint;
end;

procedure TCnEditorFontDec.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorFontDecName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

procedure TCnEditorFontDec.Execute;
var
  Option: IOTAEditOptions;
begin
  Option := CnOtaGetEditOptions;
  if Assigned(Option) then
    Option.FontSize := Round(Option.FontSize / 1.1);
end;

initialization
  RegisterCnEditor(TCnEditorFontInc);
  RegisterCnEditor(TCnEditorFontDec);

{$ENDIF CNWIZARDS_CNEDITORWIZARD}  
end.
