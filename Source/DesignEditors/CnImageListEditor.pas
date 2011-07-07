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

unit CnImageListEditor;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：支持在线搜索的 ImageList 编辑器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, DesignMenus,
  {$ELSE}
  Dsgnintf,
  {$ENDIF}
  SysUtils, Classes, ImgList, Controls, IniFiles, CnConsts, CnDesignEditor,
  CnDesignEditorConsts, CnImageListEditorFrm, CnDesignEditorUtils;

type

  TCnImageListEditor = class(TComponentEditor)
  {* 针对 ImageList 的组件编辑器}
  private
    procedure OnApply(Sender: TObject);
  public
    procedure Edit; override;
    {* 双击的过程 }
    procedure ExecuteVerb(Index: Integer); override;
    {* 执行右键菜单的过程 }
    function GetVerb(Index: Integer): string; override;
    {* 返回右键菜单条目 }
    function GetVerbCount: Integer; override;
    {* 返回右键菜单条目数 }
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
  end;

implementation

{ TCnImageListEditor }

procedure TCnImageListEditor.Edit;
var
  Ini: TCustomIniFile;
begin
  if Component is TCustomImageList then
  begin
    Ini := CreateEditorIniFile(TCnImageListEditor, False);
    try
      ShowCnImageListEditorForm(TCustomImageList(Component), Ini, OnApply);
    finally
      Ini.Free;
    end;
  end;
end;

procedure TCnImageListEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then
    Edit;
end;

class procedure TCnImageListEditor.GetInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnImageListCompEditorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnImageListCompEditorComment;
end;

function TCnImageListEditor.GetVerb(Index: Integer): string;
begin
  Result := '&ImageList Editor';
end;

function TCnImageListEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TCnImageListEditor.OnApply(Sender: TObject);
begin
  Designer.Modified;
end;

class procedure TCnImageListEditor.Register;
begin
  RegisterComponentEditor(TImageList, TCnImageListEditor);
  RegisterComponentEditor(TDragImageList, TCnImageListEditor);
  RegisterComponentEditor(TCustomImageList, TCnImageListEditor);
end;

initialization
  CnDesignEditorMgr.RegisterCompEditor(TCnImageListEditor, TCnImageListEditor.GetInfo,
    TCnImageListEditor.Register);

end.
