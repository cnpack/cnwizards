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

unit CnViewOption;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：设置窗体单元
* 单元作者：小冬（kend） kending@21cn.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2008.01.18
*               Sesame: 增加保存主窗口位置选项
*           2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, CnLangMgr, Spin;

type
  TCnViewerOptionsFrm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    chkMinToTrayIcon: TCheckBox;
    chkCloseToTrayIcon: TCheckBox;
    hkShowFormHotKey: THotKey;
    grpTrayIcon: TGroupBox;
    chkShowTrayIcon: TCheckBox;
    grpCapture: TGroupBox;
    chkCapDebug: TCheckBox;
    lblCapOD: TLabel;
    lblHotKey: TLabel;
    chkMinStart: TCheckBox;
    chkSaveFormPosition: TCheckBox;
    chkUDPMsg: TCheckBox;
    seUDPPort: TSpinEdit;
    lblPort: TLabel;
    dlgFont: TFontDialog;
    btnFont: TButton;
    lblRestart: TLabel;
    chkLocalSession: TCheckBox;
    grp1: TGroupBox;
    mmoWhiteList: TMemo;
    mmoBlackList: TMemo;
    rbWhiteList: TRadioButton;
    rbBlackList: TRadioButton;
    procedure chkShowTrayIconClick(Sender: TObject);
    procedure chkUDPMsgClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
  private
    FFontChanged: Boolean;
    procedure SwitchTrayIconControls(const AShow: Boolean);
  protected
    procedure DoCreate; override;    
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;

    property FontChanged: Boolean read FFontChanged;
  end;

implementation

uses CnViewCore;

{$R *.dfm}

{ TCnViewerOptionsFrm }

procedure TCnViewerOptionsFrm.DoCreate;
begin
  inherited;
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnViewerOptionsFrm.LoadFromOptions;
begin
  with CnViewerOptions do
  begin
    chkMinStart.Checked := StartMin;
    chkShowTrayIcon.Checked := ShowTrayIcon;
    chkMinToTrayIcon.Checked := MinToTrayIcon;
    chkCloseToTrayIcon.Checked := CloseToTrayIcon;
    chkSaveFormPosition.Checked := SaveFormPosition;
    hkShowFormHotKey.HotKey := MainShortCut;
    chkCapDebug.Checked := not IgnoreODString;
    chkLocalSession.Checked := LocalSession;
    chkUDPMsg.Checked := EnableUDPMsg;
    seUDPPort.Value := UDPPort;
    rbBlackList.Checked := UseBlackList;
    rbWhiteList.Checked := not UseBlackList;
    mmoWhiteList.Lines.CommaText := WhiteList;
    mmoBlackList.Lines.CommaText := BlackList;
    SwitchTrayIconControls(ShowTrayIcon);
    chkUDPMsgClick(nil);

    if DisplayFont = nil then
      dlgFont.Font.Assign(Application.MainForm.Font)
    else
      dlgFont.Font.Assign(DisplayFont);
  end;
  FFontChanged := False;
end;

procedure TCnViewerOptionsFrm.SaveToOptions;
begin
  with CnViewerOptions do
  begin
    StartMin := chkMinStart.Checked;
    ShowTrayIcon := chkShowTrayIcon.Checked;
    MinToTrayIcon := chkMinToTrayIcon.Checked;
    CloseToTrayIcon := chkCloseToTrayIcon.Checked;
    SaveFormPosition := chkSaveFormPosition.Checked;
    MainShortCut := hkShowFormHotKey.HotKey;
    IgnoreODString := not chkCapDebug.Checked;
    LocalSession := chkLocalSession.Checked;
    EnableUDPMsg := chkUDPMsg.Checked;
    UDPPort := seUDPPort.Value;
    UseBlackList := rbBlackList.Checked;
    WhiteList := mmoWhiteList.Lines.CommaText;
    BlackList := mmoBlackList.Lines.CommaText;
    ChangeCount := ChangeCount + 1;

    if FFontChanged then
      DisplayFont := dlgFont.Font;
  end;
end;

procedure TCnViewerOptionsFrm.SwitchTrayIconControls(const AShow: Boolean);
begin
  chkMinToTrayIcon.Enabled := AShow;
  chkCloseToTrayIcon.Enabled := AShow;
end;

procedure TCnViewerOptionsFrm.chkShowTrayIconClick(Sender: TObject);
begin
  SwitchTrayIconControls(chkShowTrayIcon.Checked);
end;

procedure TCnViewerOptionsFrm.chkUDPMsgClick(Sender: TObject);
begin
  seUDPPort.Enabled := chkUDPMsg.Checked;
end;

procedure TCnViewerOptionsFrm.btnFontClick(Sender: TObject);
begin
  if dlgFont.Execute then
    FFontChanged := True;
end;

end.
