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

unit CnProjectBackupSaveFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：项目备份单元
* 单元作者：LiuXiao (master@cnpack.org)
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2008.06.20 V1.1 by LiuXiao
*               加入备份后运行命令的机制
*           2005.10.16 V1.0 by LiuXiao
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnCommon, CnWizConsts, CnWizMultiLang, StdCtrls, ExtCtrls, ComCtrls;

type
  TCnProjectBackupSaveForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    dlgSave: TSaveDialog;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    grp2: TGroupBox;
    chkUseExternal: TCheckBox;
    grpSave: TGroupBox;
    lblFile: TLabel;
    lblTime: TLabel;
    btnSelect: TButton;
    edtFile: TEdit;
    cbbTimeFormat: TComboBox;
    grp1: TGroupBox;
    lblPass: TLabel;
    chkRememberPass: TCheckBox;
    edtPass: TEdit;
    chkPassword: TCheckBox;
    chkRemovePath: TCheckBox;
    lblPredefine: TLabel;
    cbbPredefine: TComboBox;
    lblCompressor: TLabel;
    edtCompressor: TEdit;
    btnCompressor: TButton;
    lblCmd: TLabel;
    mmoCmd: TMemo;
    dlgOpenCompressor: TOpenDialog;
    tsAfter: TTabSheet;
    grpAfter: TGroupBox;
    lblPreParams: TLabel;
    lblAfterCmd: TLabel;
    lblPreCmd: TLabel;
    chkExecAfter: TCheckBox;
    cbbParams: TComboBox;
    edtAfterCmd: TEdit;
    btnAfterCmd: TButton;
    mmoAfterCmd: TMemo;
    chkShowPass: TCheckBox;
    lblComments: TLabel;
    mmoComments: TMemo;
    chkIncludeVer: TCheckBox;
    chkSendMailTo: TCheckBox;
    edtMailAddress: TEdit;
    procedure btnSelectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkPasswordClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure edtFileChange(Sender: TObject);
    procedure cbbTimeFormatChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbPredefineChange(Sender: TObject);
    procedure btnCompressorClick(Sender: TObject);
    procedure chkUseExternalClick(Sender: TObject);
    procedure btnAfterCmdClick(Sender: TObject);
    procedure cbbParamsChange(Sender: TObject);
    procedure chkShowPassClick(Sender: TObject);
    procedure chkSendMailToClick(Sender: TObject);
  private
    FConfirmed: Boolean;
    FSavePath: string;
    FCurrentName: string;
    FVersion: string;
    FExt: string;
    function GetPassword: string;
    function GetRemovePath: Boolean;
    function GetUsePassword: Boolean;
    procedure SetPassword(const Value: string);
    procedure SetUsePassword(const Value: Boolean);
    function GetSaveFileName: string;
    procedure SetRemovePath(const Value: Boolean);
    procedure SetSaveFileName(const Value: string);
    function GetRememberPass: Boolean;
    procedure SetRememberPass(const Value: Boolean);
    function GetCompressCmd: string;
    function GetCompressor: string;
    function GetUseExternal: Boolean;
    procedure SetCompressCmd(const Value: string);
    procedure SetCompressor(const Value: string);
    procedure SetUseExternal(const Value: Boolean);
    function GetAfterCmd: string;
    procedure SetAfterCmd(const Value: string);
    function GetExecAfter: Boolean;
    procedure SetExecAfter(const Value: Boolean);
    function GetExecAfterFile: string;
    procedure SetExecAfterFile(const Value: string);
    function GetShowPass: Boolean;
    procedure SetShowPass(const Value: Boolean);
    function GetComments: string;
    procedure SetComments(const Value: string);
    function GetIncludeVer: Boolean;
    procedure SetIncludeVer(const Value: Boolean);
    function GetMailAddr: string;
    function GetSendMail: Boolean;
    procedure SetMailAddr(const Value: string);
    procedure SetSendMail(const Value: Boolean);
  protected
    function GetHelpTopic: string; override;
    procedure UpdateContent;
    procedure CheckShowPass;
  public
    function GetExtFromCompressor(Compressor: string): string;

    property IncludeVer: Boolean read GetIncludeVer write SetIncludeVer;
    property UsePassword: Boolean read GetUsePassword write SetUsePassword;
    property Password: string read GetPassword write SetPassword;
    property RemovePath: Boolean read GetRemovePath write SetRemovePath;
    property RememberPass: Boolean read GetRememberPass write SetRememberPass;
    property ShowPass: Boolean read GetShowPass write SetShowPass;
    property Comments: string read GetComments write SetComments;
    property SaveFileName: string read GetSaveFileName write SetSaveFileName;
    property Confirmed: Boolean read FConfirmed write FConfirmed;
    property UseExternal: Boolean read GetUseExternal write SetUseExternal;
    property Compressor: string read GetCompressor write SetCompressor;
    property CompressCmd: string read GetCompressCmd write SetCompressCmd;

    property ExecAfter: Boolean read GetExecAfter write SetExecAfter;
    property ExecAfterFile: string read GetExecAfterFile write SetExecAfterFile;
    property AfterCmd: string read GetAfterCmd write SetAfterCmd;

    property SendMail: Boolean read GetSendMail write SetSendMail;
    property MailAddr: string read GetMailAddr write SetMailAddr;

    property SavePath: string read FSavePath write FSavePath;
    property CurrentName: string read FCurrentName write FCurrentName;
    property Version: string read FVersion write FVersion;
  end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

type
  TCnCompressPredefined = (cpRAR, cpRARRp, {cp7zip, }cp7zipRp, cpZip);

const
  SCnCompressCmdPredefined: array[TCnCompressPredefined] of string = (
    '<compress.exe> a -p<Password> <BackupFile> @<ListFile>',
    '<compress.exe> a -ep -p<Password> <BackupFile> @<ListFile>',
    '<compress.exe> a -p<Password> <BackupFile> @<ListFile>',
    '<compress.exe> -a -s<Password> <BackupFile> @<ListFile>'
  );

  SCnAfterCmdPredefined: array[0..1] of string = (
    '<externfile.exe>',
    '<externfile.exe> <BackupFile>'
  );

{ TCnProjectBackupSaveForm }

function TCnProjectBackupSaveForm.GetPassword: string;
begin
  Result := edtPass.Text;
end;

function TCnProjectBackupSaveForm.GetRemovePath: Boolean;
begin
  Result := chkRemovePath.Checked;
end;

function TCnProjectBackupSaveForm.GetSaveFileName: string;
begin
  Result := Trim(edtFile.Text);
end;

procedure TCnProjectBackupSaveForm.SetSaveFileName(const Value: string);
begin
  if Value <> '' then
    edtFile.Text := Value;
end;

function TCnProjectBackupSaveForm.GetUsePassword: Boolean;
begin
  Result := chkPassword.Checked;
end;

procedure TCnProjectBackupSaveForm.SetPassword(const Value: string);
begin
  edtPass.Text := Value;
end;

procedure TCnProjectBackupSaveForm.SetUsePassword(const Value: Boolean);
begin
  chkPassword.Checked := Value;
end;

procedure TCnProjectBackupSaveForm.btnSelectClick(Sender: TObject);
var
  FileName: string;
begin
  dlgSave.FileName := _CnExtractFileName(edtFile.Text);
  if Self.dlgSave.Execute then
  begin
    case dlgSave.FilterIndex of
      1: FileName := _CnChangeFileExt(Self.dlgSave.FileName, '.zip');
      2: FileName := _CnChangeFileExt(Self.dlgSave.FileName, '.rar');
      3: FileName := _CnChangeFileExt(Self.dlgSave.FileName, '.7z');
    end;
    
    if not FileExists(FileName) or QueryDlg(SCnOverwriteQuery) then
    begin
      edtFile.Text := FileName;
      FSavePath := _CnExtractFilePath(Self.dlgSave.FileName);
      FConfirmed := True;
    end;
  end;
end;

procedure TCnProjectBackupSaveForm.FormShow(Sender: TObject);
begin
  UpdateContent;
end;

procedure TCnProjectBackupSaveForm.SetRemovePath(const Value: Boolean);
begin
  chkRemovePath.Checked := Value;
end;

procedure TCnProjectBackupSaveForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if (edtFile.Text = '') then
    begin
      ErrorDlg(SCnInputFile);
      CanClose := False;
      Exit;
    end;

    if chkUseExternal.Checked and not FileExists(edtCompressor.Text) then
    begin
      ErrorDlg(SCnProjExtBackupErrorCompressor);
      CanClose := False;
      Exit;
    end;

    if not chkUseExternal.Checked and (UpperCase(_CnExtractFileExt(edtFile.Text)) <> '.ZIP') then
    begin
      CanClose := QueryDlg(SCnProjExtBackupMustZip);
      Exit;
    end;
  end;
end;

procedure TCnProjectBackupSaveForm.chkPasswordClick(Sender: TObject);
begin
  UpdateContent;
end;

procedure TCnProjectBackupSaveForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnProjectBackupSaveForm.GetHelpTopic: string;
begin
  Result := 'CnProjectBackup';
end;

procedure TCnProjectBackupSaveForm.edtFileChange(Sender: TObject);
begin
  FConfirmed := False;
end;

procedure TCnProjectBackupSaveForm.cbbTimeFormatChange(Sender: TObject);
begin
  if FExt = '' then
    FExt := '.zip';

  if IncludeVer and (FVersion <> '') then
    edtFile.Text := SavePath + CurrentName + '_' + FVersion
      + FormatDateTime('_' + Trim(cbbTimeFormat.Items[cbbTimeFormat.ItemIndex]), Date + Time) + FExt
  else
    edtFile.Text := SavePath + CurrentName
      + FormatDateTime('_' + Trim(cbbTimeFormat.Items[cbbTimeFormat.ItemIndex]), Date + Time) + FExt;

  FConfirmed := False;
end;

function TCnProjectBackupSaveForm.GetRememberPass: Boolean;
begin
  Result := chkRememberPass.Checked;
end;

procedure TCnProjectBackupSaveForm.SetRememberPass(const Value: Boolean);
begin
  chkRememberPass.Checked := Value;
end;

function TCnProjectBackupSaveForm.GetCompressCmd: string;
begin
  Result := Trim(mmoCmd.Lines.Text);
end;

function TCnProjectBackupSaveForm.GetCompressor: string;
begin
  Result := Trim(edtCompressor.Text);
end;

function TCnProjectBackupSaveForm.GetUseExternal: Boolean;
begin
  Result := chkUseExternal.Checked;
end;

procedure TCnProjectBackupSaveForm.SetCompressCmd(const Value: string);
begin
  mmoCmd.Lines.Text := Value;
end;

procedure TCnProjectBackupSaveForm.SetCompressor(const Value: string);
begin
  edtCompressor.Text := Value;
end;

procedure TCnProjectBackupSaveForm.SetUseExternal(const Value: Boolean);
begin
  chkUseExternal.Checked := Value;
  UpdateContent;
end;

procedure TCnProjectBackupSaveForm.FormCreate(Sender: TObject);
begin
  Self.pgc1.ActivePageIndex := 0;
  UpdateContent;
end;

procedure TCnProjectBackupSaveForm.UpdateContent;
begin
  edtPass.Enabled := chkPassword.Checked;
  chkRememberPass.Enabled := chkPassword.Checked;
  chkShowPass.Enabled := chkPassword.Checked;
  chkRemovePath.Enabled := not chkUseExternal.Checked;
  lblPredefine.Enabled := chkUseExternal.Checked;
  lblCompressor.Enabled := chkUseExternal.Checked;
  lblCmd.Enabled := chkUseExternal.Checked;
  mmoCmd.Enabled := chkUseExternal.Checked;
  cbbPredefine.Enabled := chkUseExternal.Checked;
  btnCompressor.Enabled := chkUseExternal.Checked;
  edtCompressor.Enabled := chkUseExternal.Checked;

  lblAfterCmd.Enabled := chkExecAfter.Checked;
  edtAfterCmd.Enabled := chkExecAfter.Checked;
  btnAfterCmd.Enabled := chkExecAfter.Checked;
  lblPreParams.Enabled := chkExecAfter.Checked;
  cbbParams.Enabled := chkExecAfter.Checked;
  lblPreCmd.Enabled := chkExecAfter.Checked;
  mmoAfterCmd.Enabled := chkExecAfter.Checked;
  edtMailAddress.Enabled := chkSendMailTo.Checked;

  if not chkUseExternal.Checked then
    Exit;
  FExt := GetExtFromCompressor(edtCompressor.Text);
  edtFile.Text := _CnChangeFileExt(edtFile.Text, FExt);
end;

procedure TCnProjectBackupSaveForm.cbbPredefineChange(Sender: TObject);
var
  Ext: string;
begin
  // 使用预设的命令行设置
  if cbbPredefine.ItemIndex >= 0 then
  begin
    mmoCmd.Lines.Text := SCnCompressCmdPredefined[TCnCompressPredefined(cbbPredefine.ItemIndex)];
    Ext := GetExtFromCompressor(edtCompressor.Text);
    if Ext <> '' then
      edtFile.Text :=  _CnChangeFileExt(edtFile.Text, Ext);
  end;
end;

procedure TCnProjectBackupSaveForm.btnCompressorClick(Sender: TObject);
begin
  if dlgOpenCompressor.Execute then
  begin
    edtCompressor.Text := dlgOpenCompressor.FileName;
    UpdateContent;
  end;
end;

procedure TCnProjectBackupSaveForm.chkUseExternalClick(Sender: TObject);
begin
  UpdateContent;
end;

function TCnProjectBackupSaveForm.GetExtFromCompressor(
  Compressor: string): string;
var
  S: string;
begin
  Result := '';
  S := LowerCase(_CnExtractFileName(Compressor));
  if S = '' then Exit;

  if Pos('rar', S) > 0 then
    Result := '.rar'
  else if Pos('7z', S) > 0 then
    Result := '.7z'
  else if Pos('zip', S) > 0 then
    Result := '.zip';
end;

procedure TCnProjectBackupSaveForm.btnAfterCmdClick(Sender: TObject);
begin
  if dlgOpenCompressor.Execute then
  begin
    edtAfterCmd.Text := dlgOpenCompressor.FileName;
    UpdateContent;
  end;
end;

procedure TCnProjectBackupSaveForm.cbbParamsChange(Sender: TObject);
begin
  // 使用预设的命令行设置
  if cbbParams.ItemIndex >= 0 then
    mmoAfterCmd.Lines.Text := SCnAfterCmdPredefined[cbbParams.ItemIndex];
end;

function TCnProjectBackupSaveForm.GetAfterCmd: string;
begin
  Result := Trim(mmoAfterCmd.Lines.Text);
end;

procedure TCnProjectBackupSaveForm.SetAfterCmd(const Value: string);
begin
  mmoAfterCmd.Lines.Text := Value;
end;

function TCnProjectBackupSaveForm.GetExecAfter: Boolean;
begin
  Result := chkExecAfter.Checked;
end;

procedure TCnProjectBackupSaveForm.SetExecAfter(const Value: Boolean);
begin
  chkExecAfter.Checked := Value;
end;

function TCnProjectBackupSaveForm.GetExecAfterFile: string;
begin
  Result := Trim(edtAfterCmd.Text);
end;

procedure TCnProjectBackupSaveForm.SetExecAfterFile(const Value: string);
begin
  edtAfterCmd.Text := Trim(Value);
end;

function TCnProjectBackupSaveForm.GetShowPass: Boolean;
begin
  Result := chkShowPass.Checked;
end;

procedure TCnProjectBackupSaveForm.SetShowPass(const Value: Boolean);
begin
  chkShowPass.Checked := Value;
  CheckShowPass;
end;

procedure TCnProjectBackupSaveForm.chkShowPassClick(Sender: TObject);
begin
  CheckShowPass;
end;

procedure TCnProjectBackupSaveForm.CheckShowPass;
begin
  if chkShowPass.Checked then
    edtPass.PasswordChar := #0
  else
    edtPass.PasswordChar := '*';
end;

function TCnProjectBackupSaveForm.GetComments: string;
begin
  Result := mmoComments.Lines.Text;
end;

procedure TCnProjectBackupSaveForm.SetComments(const Value: string);
begin
  mmoComments.Lines.Text := Value;
end;

function TCnProjectBackupSaveForm.GetIncludeVer: Boolean;
begin
  Result := chkIncludeVer.Checked;
end;

procedure TCnProjectBackupSaveForm.SetIncludeVer(const Value: Boolean);
begin
  chkIncludeVer.Checked := Value;
  UpdateContent;
end;

procedure TCnProjectBackupSaveForm.chkSendMailToClick(Sender: TObject);
begin
  UpdateContent;
end;

function TCnProjectBackupSaveForm.GetMailAddr: string;
begin
  Result := edtMailAddress.Text;
end;

function TCnProjectBackupSaveForm.GetSendMail: Boolean;
begin
  Result := chkSendMailTo.Checked;
end;

procedure TCnProjectBackupSaveForm.SetMailAddr(const Value: string);
begin
  edtMailAddress.Text := Value;
end;

procedure TCnProjectBackupSaveForm.SetSendMail(const Value: Boolean);
begin
  chkSendMailTo.Checked := Value;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
