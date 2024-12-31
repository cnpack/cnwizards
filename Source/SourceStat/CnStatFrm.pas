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

unit CnStatFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：统计询问对话框窗体
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：模块
* 开发平台：Windows 98 + Delphi 6
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2003.03.26 V1.0
*               创建单元
================================================================================
|</PRE>}
interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSTATWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CnStatWizard, FileCtrl, IniFiles, CnIni, CnCommon,
  CnWizConsts, CnWizUtils, CnWizMultiLang, CnLangMgr;

type
  TCnStatForm = class(TCnTranslateForm)
    rgStatStyle: TRadioGroup;
    gbDir: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    btnSelectDir: TButton;
    cbbDir: TComboBox;
    cbbMask: TComboBox;
    cbSubDirs: TCheckBox;
    btnStat: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure rgStatStyleClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnHelpClick(Sender: TObject);
  private
    FIni: TCustomIniFile;
    function GetStatStyle: TStatStyle;
    procedure LoadSettings;
    procedure SaveSettings;
  protected
    function GetHelpTopic: string; override;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile);  
    property StatStyle: TStatStyle read GetStatStyle;
  end;

var
  CnStatForm: TCnStatForm = nil;

{$ENDIF CNWIZARDS_CNSTATWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSTATWIZARD}

{$R *.DFM}

function TCnStatForm.GetStatStyle: TStatStyle;
begin
  Result := TStatStyle(rgStatStyle.ItemIndex);
end;

procedure TCnStatForm.rgStatStyleClick(Sender: TObject);
var
  I: Integer;
begin
  gbDir.Enabled := StatStyle = ssDir;
  for I := 0 to gbDir.ControlCount - 1 do
    gbDir.Controls[I].Enabled := StatStyle = ssDir;
end;

procedure TCnStatForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := cbbDir.Text;
  if GetDirectory(SCnStatSelectDirCaption, NewDir) then
    cbbDir.Text := NewDir;
end;

procedure TCnStatForm.FormCreate(Sender: TObject);
begin
  LoadSettings;
  Self.rgStatStyle.OnClick(Self.rgStatStyle);
end;

constructor TCnStatForm.CreateEx(AOwner: TComponent; AIni: TCustomIniFile);
begin
  Create(AOwner);
  Self.FIni := AIni;
end;

const
  csStatDir = 'StatDir';
  csStatDirs = 'StatDirs';
  csStatMask = 'StatMask';
  csStatMasks = 'StatMasks';
  csStatSubDir = 'StatSubDir';

procedure TCnStatForm.LoadSettings;
begin
  with TCnIniFile.Create(FIni) do
  try
    cbbDir.Text := ReadString('', csStatDir, '');
    ReadStrings(csStatDirs, cbbDir.Items);
    cbbMask.Text := ReadString('', csStatMask, '');
    ReadStrings(csStatMasks, cbbMask.Items);
    cbSubDirs.Checked := ReadBool('', csStatSubDir, True);
  finally
    Free;
  end;
end;

procedure TCnStatForm.SaveSettings;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TComboBox then
      AddComboBoxTextToItems(TComboBox(Components[I]));

  with TCnIniFile.Create(FIni) do
  try
    WriteString('', csStatDir, cbbDir.Text);
    WriteStrings(csStatDirs, cbbDir.Items);
    WriteString('', csStatMask, cbbMask.Text);
    WriteStrings(csStatMasks, cbbMask.Items);
    WriteBool('', csStatSubDir, cbSubDirs.Checked);
  finally
    Free;
  end;
end;

procedure TCnStatForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
    SaveSettings;
end;

procedure TCnStatForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnStatForm.GetHelpTopic: string;
begin
  Result := 'CnStatWizard';
end;

{$ENDIF CNWIZARDS_CNSTATWIZARD}
end.

