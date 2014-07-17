{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnWizAboutFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：关于窗体单元
* 单元作者：CnPack开发组
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2002.09.28 V1.0
*               创建单元
*           2003.03.10 V1.1
*               添加左侧图片
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, CnConsts, CnWizFeedbackFrm, CnWizMultiLang, CnLangMgr,
  CnWaterImage;

type
  TCnWizAboutForm = class(TCnTranslateForm)
    Bevel1: TBevel;
    Label2: TLabel;
    Label4: TLabel;
    btnOK: TButton;
    lblWeb: TLabel;
    lblEmail: TLabel;
    lblVersion: TLabel;
    lblBbs: TLabel;
    Bevel2: TBevel;
    Label3: TLabel;
    btnReport: TButton;
    Panel1: TPanel;
    btnLicense: TButton;
    tmr1: TTimer;
    CnWaterImage1: TCnWaterImage;
    imgDonation: TImage;
    edtVer: TEdit;
    lblSource: TLabel;
    procedure lblWebClick(Sender: TObject);
    procedure lblEmailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblBbsClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnLicenseClick(Sender: TObject);
    procedure imgDonationClick(Sender: TObject);
    procedure lblSourceClick(Sender: TObject);
    procedure Label2DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure DbgEditKeyPress(Sender: TObject; var Key: Char);
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

// 显示关于窗口
procedure ShowCnWizAboutForm;

implementation

uses
  CnCommon, CnWizConsts, CnWizOptions, CnWizManager;

{$R *.DFM}

var
  DbgFrm: TForm = nil;

// 显示关于窗口
procedure ShowCnWizAboutForm;
begin
  with TCnWizAboutForm.Create(Application.MainForm) do
  try
    ShowHint := WizOptions.ShowHint;
    ShowModal;
  finally
    Free;
  end;
end;

{ TCnWizAboutForm }

procedure TCnWizAboutForm.FormCreate(Sender: TObject);
begin
  edtVer.Text := Format('%s %s.%s Build %s', [edtVer.Text,
    SCnWizardMajorVersion, SCnWizardMinorVersion, SCnWizardBuildDate]);
end;

procedure TCnWizAboutForm.lblWebClick(Sender: TObject);
begin
  OpenUrl(SCnPackUrl);
end;

procedure TCnWizAboutForm.lblEmailClick(Sender: TObject);
begin
  MailTo(SCnPackEmail, SCnWizMailSubject);
end;

procedure TCnWizAboutForm.lblBbsClick(Sender: TObject);
begin
  OpenUrl(SCnPackBbsUrl);
end;

procedure TCnWizAboutForm.lblSourceClick(Sender: TObject);
begin
  OpenUrl(SCnPackSourceUrl);
end;

procedure TCnWizAboutForm.imgDonationClick(Sender: TObject);
begin
  OpenUrl(SCnPackDonationUrl);
end;

procedure TCnWizAboutForm.btnReportClick(Sender: TObject);
begin
  ShowFeedbackForm;
  ModalResult := mrOk;
end;

procedure TCnWizAboutForm.btnLicenseClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizAboutForm.GetHelpTopic: string;
begin
  Result := 'License';
end;

procedure TCnWizAboutForm.Label2DblClick(Sender: TObject);
var
  Edit: TEdit;
  Memo: TMemo;
begin
{$IFDEF DEBUG}
  Close;

  if DbgFrm <> nil then
  begin
    DbgFrm.Show;
  end
  else
  begin
    DbgFrm := TForm.Create(Application);
    with DbgFrm do
    begin
      Width := 550;
      Height := 400;
      Position := poScreenCenter;
      Caption := 'CnPack IDE Wizard Debug Command Window';
      BorderIcons := [biSystemMenu];
    end;

    Edit := TEdit.Create(DbgFrm);
    with Edit do
    begin
      Parent := DbgFrm;
      Align := alTop;
      OnKeyPress := DbgEditKeyPress;
    end;

    Memo := TMemo.Create(DbgFrm);
    with Memo do
    begin
      Parent := DbgFrm;
      Align := alClient;
      ReadOnly := True;
      ScrollBars := ssBoth;
      Text := '';
    end;

    Edit.Tag := Integer(Memo);
    DbgFrm.Show;
  end;
{$ENDIF}
end;

procedure TCnWizAboutForm.DbgEditKeyPress(Sender: TObject; var Key: Char);
var
  List: TStrings;
  Memo: TMemo;
  Cmd: string;
begin
  if Key = #13 then
  begin
    if not (Sender is TEdit) then
      Exit;

    Memo := TMemo((Sender as TEdit).Tag);
    if Memo = nil then
      Exit;

    Cmd := Trim((Sender as TEdit).Text);
    if Cmd = '' then
      Exit;

    List := TStringList.Create;
    try
      CnWizardMgr.DispatchDebugComand(Cmd, List);
      Memo.Clear;
      Memo.Lines.AddStrings(List);
    finally
      List.Free;
    end;
    Key := #0;
  end;
end;

end.
