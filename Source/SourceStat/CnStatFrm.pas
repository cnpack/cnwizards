{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnStatFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ͳ��ѯ�ʶԻ�����
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��ģ��
* ����ƽ̨��Windows 98 + Delphi 6
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2003.03.26 V1.0
*               ������Ԫ
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
    function GetStatStyle: TCnStatStyle;
    procedure LoadSettings;
    procedure SaveSettings;
  protected
    function GetHelpTopic: string; override;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile);
    property StatStyle: TCnStatStyle read GetStatStyle;
  end;

var
  CnStatForm: TCnStatForm = nil;

{$ENDIF CNWIZARDS_CNSTATWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSTATWIZARD}

{$R *.DFM}

function TCnStatForm.GetStatStyle: TCnStatStyle;
begin
  Result := TCnStatStyle(rgStatStyle.ItemIndex);
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
  begin
    if Components[I] is TComboBox then
      AddComboBoxTextToItems(TComboBox(Components[I]));
  end;

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

