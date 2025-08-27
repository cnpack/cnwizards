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

unit CnTestEditorInsertTextWizard;
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
// 测试编辑器插入文本用子菜单专家
//==============================================================================

{ TCnTestEditorInsertTextWizard }

  TCnTestEditorInsertTextWizard = class(TCnSubMenuWizard)
  private
    FIdInsertTextIntoEditor: Integer;
    FIdInsertLineIntoEditor: Integer;
    FIdReplaceCurrentSelection: Integer;
    FIdInsertTextToCurSource: Integer;
    FIdInsertMoreTexts: Integer;
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
// 测试编辑器插入文本用子菜单专家
//==============================================================================

{ TCnTestEditorInsertTextWizard }

procedure TCnTestEditorInsertTextWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditorInsertTextWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditorInsertTextWizard.AcquireSubActions;
begin
  FIdInsertTextIntoEditor := RegisterASubAction('CnOtaInsertTextIntoEditor',
    'Test CnOtaInsertTextIntoEditor', 0, 'Test CnOtaInsertTextIntoEditor',
    'CnOtaInsertTextIntoEditor');
  FIdInsertLineIntoEditor := RegisterASubAction('CnOtaInsertLineIntoEditor',
    'Test CnOtaInsertLineIntoEditor', 0, 'Test CnOtaInsertLineIntoEditor',
    'CnOtaInsertLineIntoEditor');
  FIdReplaceCurrentSelection := RegisterASubAction('CnOtaReplaceCurrentSelection',
    'Test CnOtaReplaceCurrentSelection', 0, 'Test CnOtaReplaceCurrentSelection',
    'CnOtaReplaceCurrentSelection');
  FIdInsertTextToCurSource := RegisterASubAction('CnOtaInsertTextToCurSource',
    'Test CnOtaInsertTextToCurSource', 0, 'Test CnOtaInsertTextToCurSource',
    'CnOtaInsertTextToCurSource');
  FIdInsertMoreTexts := RegisterASubAction('CnOtaInsertMoreTexts',
    'Test Insert More Texts', 0, 'Test Insert More Texts', 'CnOtaInsertMoreTexts');
end;

function TCnTestEditorInsertTextWizard.GetCaption: string;
begin
  Result := 'Test Editor Insert Text';
end;

function TCnTestEditorInsertTextWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorInsertTextWizard.GetHint: string;
begin
  Result := 'Test Editor InsertText';
end;

function TCnTestEditorInsertTextWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorInsertTextWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Insert Text Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor Insert Text Wizard';
end;

procedure TCnTestEditorInsertTextWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorInsertTextWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorInsertTextWizard.SubActionExecute(Index: Integer);
var
  S: string;
  APos: TOTAEditPos;
begin
  if not Active then Exit;

  if Index = FIdInsertTextIntoEditor then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{吃饭睡觉}');
    CnOtaInsertTextIntoEditor(S); // Using EditWriter.Insert
  end
  else if Index = FIdInsertLineIntoEditor then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{吃饭睡觉}');
    CnOtaInsertLineIntoEditor(S); // Using EditPosition.Insert
  end
  else if Index = FIdReplaceCurrentSelection then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{吃饭睡觉}');
    CnOtaReplaceCurrentSelection(S, True, True);
  end
  else if Index = FIdInsertTextToCurSource then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{吃饭睡觉}');
    APos.Line := 27; APos.Col := 31;
    CnOtaGetTopMostEditView.CursorPos := APos;
    CnOtaInsertTextToCurSource(S);
  end
  else if Index = FIdInsertMoreTexts then
  begin
    S := '隔200';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
    S := '毫秒显示一个';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
    S := '字符' + #13#10 + '  end';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
  end;
end;

procedure TCnTestEditorInsertTextWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditorInsertTextWizard); // 注册专家

end.
