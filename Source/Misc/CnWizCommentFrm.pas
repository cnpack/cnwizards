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

unit CnWizCommentFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家功能提示窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2002.10.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Registry, Menus, CnWizClasses, CnLangMgr, CnWizMultiLang,
  CnWizIni, CnWideStrings;

type
//==============================================================================
// 专家功能提示窗体
//==============================================================================

{ TCnWizCommentForm }

  TCnWizCommentForm = class(TCnTranslateForm)
    imgIcon: TImage;
    Label1: TLabel;
    Bevel1: TBevel;
    memHint: TMemo;
    Bevel2: TBevel;
    cbNotShow: TCheckBox;
    btnContinue: TButton;
    btnCancel: TButton;
    chkCloseAll: TCheckBox;
  private

  public

  end;

function ShowCnWizCommentForm(Wizard: TCnBaseWizard;
  Command: string = ''): Boolean; overload;
{* 显示专家功能提示窗体，如果用户以前显示过该窗体并选择了以后不再显示，则调用该
   过程直接返回为真。
   显示内容将从统一的文件中读取，调用方不需要关心。
 |<PRE>
   Wizard: TCnBaseWizard    - 调用该方法的专家
   Command: string          - 要执行的命令，默认为空，即专家主执行命令
   Result: Boolean          - 如果用户点击“继续”返回为真，否则为假
 |</PRE>}
function ShowCnWizCommentForm(const ACaption: string; AIcon: TIcon;
  Command: string): Boolean; overload;
{* 显示专家功能提示窗体，如果用户以前显示过该窗体并选择了以后不再显示，则调用该
   过程直接返回为真。
   显示内容将从统一的文件中读取，调用方不需要关心。
 |<PRE>
   ACaption: string         - 窗口标题
   AIcon: TIcon             - 图标
   Command: string          - 要执行的命令
   Result: Boolean          - 如果用户点击“继续”返回为真，否则为假
 |</PRE>}

procedure ShowSimpleCommentForm(const ACaption: string; AText, Command: string;
  NextChecked: Boolean = True);
{* 显示简单的提示窗体
 |<PRE>
   ACaption: string         - 窗口标题
   AText:    string         - 显示文字
   Command:  string         - 标识的命令
   NextChecked: Boolean     - 是否勾上“下次不显示”
 |</PRE>}

procedure ResetAllComment(Show: Boolean);
{* 重设置所有的提示信息显示，参数表示是否允许显示}

function GetCommandComment(Command: string): string;
{* 取指定命令的提示信息}

implementation

uses
  IniFiles, CnWizUtils, CnWizOptions, CnWizConsts, CnCommon;

{$R *.DFM}

const
  csOption = 'Option';
  csReturn = 'Return';
  csIndent = 'Indent';
  csComment = 'Comment';
  csDefReturn = '\n';

// 显示专家功能提示窗体
function ShowCnWizCommentForm(const ACaption: string; AIcon: TIcon;
  Command: string): Boolean;
var
  FileName: string;
  Comment: string;
  Show: Boolean;
  CRLF: string;
  Indent: Integer;
begin
  Result := True;
  if not WizOptions.ShowWizComment then Exit;
  if Command = '' then Exit;

  Show := WizOptions.ReadBool(SCnCommentSection, Command, True);
  if Show then
  begin
    FileName := GetFileFromLang(SCnWizCommentIniFile);
    if FileExists(FileName) then
      with TCnWideMemIniFile.Create(FileName) do
      try
        if not CheckWinVista and not ValueExists(csComment, Command) then
        begin
          WriteString(csComment, Command, '');  // 创建该项内容供编辑
          Exit;
        end
        else
        begin
          Comment := ReadString(csComment, Command, '');
          if Comment = '' then Exit;
          with TCnWizCommentForm.Create(nil) do
          try
            ShowHint := WizOptions.ShowHint;
            CRLF := ReadString(csOption, csReturn, csDefReturn); // 字符串中的换行符
            Indent := ReadInteger(csOption, csIndent, 0); // 段落缩进
            Comment := Spc(Indent) + StringReplace(Comment, CRLF, #13#10 +
              Spc(Indent), [rfReplaceAll]);
            memHint.Lines.Text := Comment;
            if AIcon <> nil then
              imgIcon.Picture.Graphic := AIcon; // 专家图标
            Caption := StripHotkey(ACaption);
            if ShowModal = mrOK then
            begin
              Result := True;
              WizOptions.WriteBool(SCnCommentSection, Command, not cbNotShow.Checked);
              WizOptions.ShowWizComment := not chkCloseAll.Checked;
            end
            else
              Result := False;
          finally
            Free;
          end;
        end;
      finally
        if not CheckWinVista then
          UpdateFile;
        Free;
      end;
  end;
end;

// 显示专家功能提示窗体
function ShowCnWizCommentForm(Wizard: TCnBaseWizard; Command: string): Boolean;
begin
  Assert(Assigned(Wizard));
  if Command = '' then
    Command := Wizard.GetIDStr;
  Result := ShowCnWizCommentForm(Wizard.WizardName, Wizard.Icon, Command);
end;

// 显示简单的提示窗体
procedure ShowSimpleCommentForm(const ACaption: string; AText, Command: string;
  NextChecked: Boolean);
var
  Show: Boolean;
begin
  if Command = '' then Exit;

  Show := WizOptions.ReadBool(SCnCommentSection, Command, True);
  if Show then
  begin
    with TCnWizCommentForm.Create(nil) do
    try
      ShowHint := WizOptions.ShowHint;
      memHint.Lines.Text := AText;
      if ACaption <> '' then
        Caption := StripHotkey(ACaption);
      chkCloseAll.Visible := False;
      btnCancel.Enabled := False;
      cbNotShow.Checked := NextChecked;
      
      ShowModal; // Don't Judge = mrOK for Saving when Direct Close.
      WizOptions.WriteBool(SCnCommentSection, Command, not cbNotShow.Checked);
    finally
      Free;
    end;
  end;
end;

// 取指定命令的提示信息
function GetCommandComment(Command: string): string;
var
  CRLF: string;
  Indent: Integer;
begin
  Result := '';
  with TCnWideMemIniFile.Create(GetFileFromLang(SCnWizCommentIniFile)) do
  try
    Result := ReadString(csComment, Command, '');
    if not CheckWinVista and (Result = '') then
    begin
      WriteString(csComment, Command, '');  // 创建该项内容供编辑
      Exit;
    end;
    CRLF := ReadString(csOption, csReturn, csDefReturn); // 字符串中的换行符
    Indent := ReadInteger(csOption, csIndent, 0); // 段落缩进
    Result := Spc(Indent) + StringReplace(Result, CRLF, #13#10 +
      Spc(Indent), [rfReplaceAll]);
  finally
    if not CheckWinVista then
      UpdateFile;
    Free;
  end;
end;

// 重设置所有的提示信息显示，参数表示是否允许显示
procedure ResetAllComment(Show: Boolean);
var
  Values: TStrings;
  i: Integer;
begin
  Values := TStringList.Create;
  try
    with TCnWideMemIniFile.Create(GetFileFromLang(SCnWizCommentIniFile)) do
    try
      ReadSectionValues(csComment, Values);
    finally
      Free;
    end;

    with WizOptions.CreateRegIniFile do
    try
      for i := 0 to Values.Count - 1 do
        if Show then
          DeleteKey(SCnCommentSection, Values.Names[i])
        else
          WriteBool(SCnCommentSection, Values.Names[i], Show);
    finally
      Free;
    end;
  finally
    Values.Free;
  end;
end;

end.
