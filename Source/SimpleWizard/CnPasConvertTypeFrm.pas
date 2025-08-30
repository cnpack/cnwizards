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

unit CnPasConvertTypeFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����뵽HTMLת�����ר������ѡ��Ԫ
* ��Ԫ���ߣ�С�� kendling@sina.com
* ��    ע��
* ����ƽ̨��PWinXP SP2 + Delphi 7
* ���ݲ��ԣ����ޣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6��
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2008.08.20 v1.1
*               ������������
*           2006.09.06 v1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  Windows, Messages, SysUtils, Classes, CnPasConvert, Clipbrd, ToolsAPI,
  CnConsts, CnWizClasses, CnWizConsts, CnWizUtils, CnCommon, CnWizIdeUtils,
  Forms, Dialogs, Controls, StdCtrls, ComCtrls, CnIni, IniFiles,
  FileCtrl, Graphics, CnWizEditFiler, CnWizMultiLang, ExtCtrls;

type

{ TCnPasConvertType }

  TCnPasConvertType  = (ctHTML, ctRTF);

{ TCnPasConvertTypeForm }

  TCnPasConvertTypeForm = class(TCnTranslateForm)
    btnOK: TButton;
    rgConvertType: TRadioGroup;
    btnCancel: TButton;
    chkOpenAfterConvert: TCheckBox;
    lblEncode: TLabel;
    cbbEncoding: TComboBox;
    btnHelp: TButton;
    procedure rgConvertTypeClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    function GetConvertType: TCnPasConvertType;
    procedure SetConvertType(const Value: TCnPasConvertType);
    function GetHTMLEncode: string;
    procedure SetHTMLEncode(const Value: string);
  protected
    function GetHelpTopic: string; override;
  public
    function Open: Boolean;
    property ConvertType: TCnPasConvertType read GetConvertType write SetConvertType;
    property HTMLEncode: string read GetHTMLEncode write SetHTMLEncode;
  end;

const
  SConvertTypeFileExt: array[TCnPasConvertType] of string = (
    'htm',
    'rtf'
  );

  SConvertTypeFileFilter: array[TCnPasConvertType] of string = (
    'HTML Files (*.htm;*.html)|*.htm; *.html',
    'RTF Files (*.rtf)|*.rtf'
  );

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

{$R *.DFM}

function TCnPasConvertTypeForm.GetConvertType: TCnPasConvertType;
begin
  Result := TCnPasConvertType(rgConvertType.ItemIndex);
end;

function TCnPasConvertTypeForm.GetHTMLEncode: string;
begin
  Result := cbbEncoding.Text;
end;

function TCnPasConvertTypeForm.Open: Boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TCnPasConvertTypeForm.SetConvertType(
  const Value: TCnPasConvertType);
begin
  rgConvertType.ItemIndex := Ord(Value);
end;

procedure TCnPasConvertTypeForm.SetHTMLEncode(const Value: string);
begin
  cbbEncoding.Text := Value;
end;

procedure TCnPasConvertTypeForm.rgConvertTypeClick(Sender: TObject);
begin
  lblEncode.Enabled := rgConvertType.ItemIndex = 0;
  cbbEncoding.Enabled := rgConvertType.ItemIndex = 0;
end;

function TCnPasConvertTypeForm.GetHelpTopic: string;
begin
  Result := 'CnPas2HtmlWizard';
end;

procedure TCnPasConvertTypeForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}
end.


