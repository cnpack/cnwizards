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

unit CnProjectDirImportFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程目录创建器导入目录单元
* 单元作者：LiuXiao master@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2005.06.8 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, StdCtrls, FileCtrl;

type
  TCnImportDirForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    grpImport: TGroupBox;
    lblDir: TLabel;
    edtDir: TEdit;
    btnSelectDir: TButton;
    chkIngoreDir: TCheckBox;
    cbbIgnoreDir: TComboBox;
    chkNameIsDesc: TCheckBox;
    procedure btnSelectDirClick(Sender: TObject);
    procedure chkIngoreDirClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

function SelectImportDir(var RootDir: string; var Ignore: Boolean;
  var IgnoreDir: string; var GenReadMe: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  CnCommon, CnWizConsts, CnWizUtils;

{$R *.DFM}

function SelectImportDir(var RootDir: string; var Ignore: Boolean;
  var IgnoreDir: string; var GenReadMe: Boolean): Boolean;
begin
  with TCnImportDirForm.Create(nil) do
  begin
    edtDir.Text := RootDir;
    chkIngoreDir.Checked := Ignore;
    cbbIgnoreDir.Text := IgnoreDir;
    chkNameIsDesc.Checked := GenReadMe;
    if Assigned(chkIngoreDir.OnClick) then
      chkIngoreDir.OnClick(chkIngoreDir);
      
    Result := ShowModal = mrOK;
    if Result then
    begin
      RootDir := edtDir.Text;
      Ignore := chkIngoreDir.Checked;
      IgnoreDir := cbbIgnoreDir.Text;
      GenReadMe := chkNameIsDesc.Checked;
      if cbbIgnoreDir.Items.IndexOf(IgnoreDir) < 0 then
        cbbIgnoreDir.Items.Add(IgnoreDir);
    end;
    Free;
  end;
end;

procedure TCnImportDirForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := ReplaceToActualPath(edtDir.Text);
  if GetDirectory(SCnSelectDir, NewDir) then
    edtDir.Text := NewDir;
end;

procedure TCnImportDirForm.chkIngoreDirClick(Sender: TObject);
begin
  cbbIgnoreDir.Enabled := chkIngoreDir.Checked;
end;

procedure TCnImportDirForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnImportDirForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtDirBuilder';
end;

procedure TCnImportDirForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if not DirectoryExists(edtDir.Text) then
    begin
      ErrorDlg(SCnStatDirNotExists);
      CanClose := False;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
