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

unit CnAICoderChatFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的对话窗体单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：PWin7/10/11 + Delphi / C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, CnWizIdeDock, CnChatBox, ToolWin, ComCtrls, ActnList,
  Buttons, CnWizShareImages, CnWizOptions, CnAICoderEngine, CnAICoderWizard;

type
  TCnAICoderChatForm = class(TCnIdeDockForm)
    pnlChat: TPanel;
    tlbAICoder: TToolBar;
    actlstAICoder: TActionList;
    actToggleSend: TAction;
    pnlTop: TPanel;
    spl1: TSplitter;
    mmoSelf: TMemo;
    btnMsgSend: TSpeedButton;
    actCopyCode: TAction;
    btnToggleSend: TToolButton;
    btnOption: TToolButton;
    actHelp: TAction;
    btnCopyCode: TToolButton;
    btnHelp: TToolButton;
    actOption: TAction;
    btn1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure actToggleSendExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actlstAICoderUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure btnMsgSendClick(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure mmoSelfKeyPress(Sender: TObject; var Key: Char);
  private
    FChatBox: TCnChatBox;
    FWizard: TCnAICoderWizard;
  protected
    function GetHelpTopic: string; override;
  public
    procedure AddMessage(const Msg, AFrom: string; IsMe: Boolean = False);

    property ChatBox: TCnChatBox read FChatBox;
    property Wizard: TCnAICoderWizard read FWizard write FWizard;
  end;

var
  CnAICoderChatForm: TCnAICoderChatForm;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  CnAICoderNetClient;

{$R *.DFM}

procedure TCnAICoderChatForm.AddMessage(const Msg, AFrom: string; IsMe: Boolean);
begin
  with FChatBox.Items.AddMessage do
  begin
    Text := Msg;
    if IsMe then
      FromType := cmtMe
    else
    begin
      FromType := cmtYou;
      From := AFrom;
    end;
  end;
end;

procedure TCnAICoderChatForm.FormCreate(Sender: TObject);
begin
  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := clWhite;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ColorSelection := clGreen;
  FChatBox.ScrollBarVisible := True;

  WizOptions.ResetToolbarWithLargeIcons(tlbAICoder);
end;

procedure TCnAICoderChatForm.actToggleSendExecute(Sender: TObject);
begin
  pnlTop.Visible := not pnlTop.Visible;
  actToggleSend.Checked := pnlTop.Visible;
end;

procedure TCnAICoderChatForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnAICoderChatForm.GetHelpTopic: string;
begin
  Result := 'CnAICoderWizard';
end;

procedure TCnAICoderChatForm.actlstAICoderUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
//  if Action = actCopyCode then
//    // 选中内容里有无 ```
//  else if Action = actSend then
//    (Action as TAction).Enabled := mmoSelf.Lines.Text <> '';
end;

procedure TCnAICoderChatForm.btnMsgSendClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  if Trim(mmoSelf.Lines.Text) <> '' then
  begin
    // 发出的消息
    Msg := ChatBox.Items.AddMessage;
    Msg.From := CnAIEngineManager.CurrentEngineName;
    Msg.Text := mmoSelf.Lines.Text;
    Msg.FromType := cmtMe;

    // 回来的消息
    Msg := CnAICoderChatForm.ChatBox.Items.AddMessage;
    Msg.From := CnAIEngineManager.CurrentEngineName;
    Msg.FromType := cmtYou;
    Msg.Text := '...';

    CnAIEngineManager.CurrentEngine.AskAIEngineForCode(mmoSelf.Lines.Text, Msg,
      artRaw, FWizard.ForCodeAnswer);
    mmoSelf.Lines.Text := '';
  end;
end;

procedure TCnAICoderChatForm.actOptionExecute(Sender: TObject);
begin
  if FWizard <> nil then
    FWizard.Config;
end;

procedure TCnAICoderChatForm.mmoSelfKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
    btnMsgSend.Click;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
