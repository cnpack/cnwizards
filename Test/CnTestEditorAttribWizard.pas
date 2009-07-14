{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnTestEditorAttribWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：简单的专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元可获取并弹出代码编辑器当前光标所在的行以及字符属性的内容
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.01.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// 编辑器属性获取菜单专家
//==============================================================================

{ TCnTestEditorAttribWizard }

  TCnTestEditorAttribWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

//==============================================================================
// 演示用菜单专家
//==============================================================================

{ TCnTestEditorAttribWizard }

procedure TCnTestEditorAttribWizard.Config;
begin
  { TODO -oAnyone : 在此显示配置窗口 }
end;

procedure TCnTestEditorAttribWizard.Execute;
var
  EditPos: TOTAEditPos;
  EditControl: TControl;
  EditView: IOTAEditView;
  LineFlag, Element: Integer;
  S, T: string;
  Block: IOTAEditBlock;
begin
  { TODO -oAnyone : 该专家的主执行过程 }
  EditControl := CnOtaGetCurrentEditControl;
  EditView := CnOtaGetTopMostEditView;

  Block := EditView.Block;
  S := Format('Edit Block %8.8x. ', [Integer(Block)]);
  if Block <> nil then
  begin
    if Block.IsValid then
      S := S + 'Is Valid.'
    else
      S := S + 'NOT Valid.';
  end;

  EditPos := EditView.CursorPos;
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := S + #13#10 +Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);

  if EditPos.Col > 1 then
    Dec(EditPos.Col);

  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);
end;

function TCnTestEditorAttribWizard.GetCaption: string;
begin
  Result := 'Show Attribute at Cursor';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestEditorAttribWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestEditorAttribWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestEditorAttribWizard.GetHint: string;
begin
  Result := 'Show Attribute at Cursor in Current Editor';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestEditorAttribWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestEditorAttribWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Attribute Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Editor Attribute Menu Wizard';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestEditorAttribWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestEditorAttribWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestEditorAttribWizard); // 注册专家

end.
