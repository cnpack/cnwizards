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

unit CnEditorCodeComment;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码块注释工具单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org; http://www.cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2002.12.31 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizClasses, CnWizUtils, CnConsts, CnCommon,
  Menus, CnEditorWizard, CnWizConsts, CnEditorCodeTool, CnWizMultiLang;

type

//==============================================================================
// 代码块注释工具类
//==============================================================================

{ TCnEditorCodeComment }

  TCnEditorCodeComment = class(TCnEditorCodeTool)
  protected
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
  end;

//==============================================================================
// 代码块取消注释工具类
//==============================================================================

{ TCnEditorCodeUnComment }

  TCnEditorCodeUnComment = class(TCnEditorCodeTool)
  protected
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
  end;

//==============================================================================
// 代码块切换注释工具类
//==============================================================================

{ TCnEditorCodeToggleComment }

  TCnEditorCodeToggleComment = class(TCnEditorCodeTool)
  private
    Inited: Boolean;
    FirstIsCommented: Boolean;
    FMoveToNextLine: Boolean;
  protected
    function GetHasConfig: Boolean; override;
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
    function GetDefShortCut: TShortCut; override;
    procedure GetNewPos(var ARow: Integer; var ACol: Integer); override;
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
    procedure Config; override;
  published
    property MoveToNextLine: Boolean read FMoveToNextLine write FMoveToNextLine default True;    
  end;

  TCnEditorCodeCommentForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    chkMoveToNextLine: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$R *.dfm}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

function GetCommentStr(const Str: string): string;
begin
  Result := '//' + Str;
end;

function IsCommentStr(const Str: string): Boolean;
var
  S: string;
begin
  S := Trim(Str);
  // 前面两个是 // 并且不是只有连续三个 ///
  Result := (Pos('//', S) = 1) and ((Length(S) <= 2) or (S[3] <> '/') or
    (Pos('////', S) = 1));
end;

function GetUnCommentStr(const Str: string): string;
begin
  if IsCommentStr(Str) then
    Result := StringReplace(Str, '//', '', [])
  else
    Result := Str;
end;

{ TCnEditorCodeComment }

function TCnEditorCodeComment.ProcessLine(const Str: string): string;
begin
  Result := GetCommentStr(Str);
end;

function TCnEditorCodeComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeComment.GetCaption: string;
begin
  Result := SCnEditorCodeCommentMenuCaption;
end;

function TCnEditorCodeComment.GetHint: string;
begin
  Result := SCnEditorCodeCommentMenuHint;
end;

procedure TCnEditorCodeComment.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeCommentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

{ TCnEditorCodeUnComment }

function TCnEditorCodeUnComment.ProcessLine(const Str: string): string;
begin
  Result := GetUnCommentStr(Str);
end;

function TCnEditorCodeUnComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeUnComment.GetCaption: string;
begin
  Result := SCnEditorCodeUnCommentMenuCaption;
end;

function TCnEditorCodeUnComment.GetHint: string;
begin
  Result := SCnEditorCodeUnCommentMenuHint;
end;

procedure TCnEditorCodeUnComment.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeUnCommentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

{ TCnEditorCodeToggleComment }

constructor TCnEditorCodeToggleComment.Create(AOwner: TCnEditorWizard);
begin
  inherited;
  FMoveToNextLine := True;
end;

procedure TCnEditorCodeToggleComment.Execute;
begin
  Inited := False;
  FirstIsCommented := False;
  inherited;
end;

function TCnEditorCodeToggleComment.ProcessLine(const Str: string): string;
begin
  // 判断首行是否已注释
  if not Inited then
  begin
    FirstIsCommented := IsCommentStr(Str);
    Inited := True;
  end;

  // 使用 BDS 2005 的规则处理
  if not FirstIsCommented then
    Result := GetCommentStr(Str)    // 首行未注释时全部增加注释
  else if IsCommentStr(Str) then
    Result := GetUnCommentStr(Str)  // 注释过的取消注释
  else
    Result := GetCommentStr(Str);   // 未注释的增加注释
end;

function TCnEditorCodeToggleComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeToggleComment.GetCaption: string;
begin
  Result := SCnEditorCodeToggleCommentMenuCaption;
end;

procedure TCnEditorCodeToggleComment.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorCodeToggleCommentName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

function TCnEditorCodeToggleComment.GetHint: string;
begin
  Result := SCnEditorCodeToggleCommentMenuHint;
end;

function TCnEditorCodeToggleComment.GetDefShortCut: TShortCut;
begin
  Result := $40BF;   // Ctrl+/
end;

procedure TCnEditorCodeToggleComment.GetNewPos(var ARow, ACol: Integer);
begin
  if MoveToNextLine then
    Inc(ARow);
end;

function TCnEditorCodeToggleComment.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnEditorCodeToggleComment.Config;
begin
  with TCnEditorCodeCommentForm.Create(nil) do
  try
    chkMoveToNextLine.Checked := FMoveToNextLine;

    if ShowModal = mrOk then
    begin
      FMoveToNextLine := chkMoveToNextLine.Checked;
    end;
  finally
    Free;
  end;
end;

initialization
  RegisterCnEditor(TCnEditorCodeComment);
  RegisterCnEditor(TCnEditorCodeUnComment);
{$IFNDEF COMPILER9_UP}
  RegisterCnEditor(TCnEditorCodeToggleComment);
{$ENDIF}

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
