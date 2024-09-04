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
  ExtCtrls, StdCtrls,ToolWin, ComCtrls, ActnList, Menus, Buttons, Clipbrd,
  CnWizIdeDock, CnChatBox, CnWizShareImages, CnWizOptions, CnAICoderEngine,
  CnAICoderWizard, CnWizConsts, CnEditControlWrapper;

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
    actCopy: TAction;
    btnToggleSend: TToolButton;
    btnOption: TToolButton;
    actHelp: TAction;
    btnHelp: TToolButton;
    actOption: TAction;
    btn1: TToolButton;
    pmChat: TPopupMenu;
    N1: TMenuItem;
    actCopyCode: TAction;
    M1: TMenuItem;
    actClear: TAction;
    btnClear: TToolButton;
    N2: TMenuItem;
    Clear1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actToggleSendExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actlstAICoderUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure btnMsgSendClick(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure mmoSelfKeyPress(Sender: TObject; var Key: Char);
    procedure actCopyExecute(Sender: TObject);
    procedure pmChatPopup(Sender: TObject);
    procedure actCopyCodeExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
  private
    FChatBox: TCnChatBox;
    FWizard: TCnAICoderWizard;
    FItemUnderMouse: TCnChatItem;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure UpdateCaption;
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
  CnAICoderNetClient, CnCommon;

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
const
  BK_COLOR = $71EA9A;
begin
  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := clWhite;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ColorYou := BK_COLOR;
  FChatBox.ColorMe := BK_COLOR;
  FChatBox.ColorSelection := BK_COLOR;
  FChatBox.ScrollBarVisible := True;
  FChatBox.PopupMenu := pmChat;

  FChatBox.Font := EditControlWrapper.FontBasic;
  mmoSelf.Font := EditControlWrapper.FontBasic;

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

procedure TCnAICoderChatForm.UpdateCaption;
const
  SEP = ' - ';
var
  S: string;
  I: Integer;
begin
  S := Caption;
  I := Pos(SEP, S);
  if I > 0 then
    Delete(S, I, MaxInt);

  Caption := S + SEP + CnAIEngineManager.CurrentEngineName;
end;

procedure TCnAICoderChatForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TCnAICoderChatForm.actCopyExecute(Sender: TObject);
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
        Clipboard.AsText := TCnChatMessage(FItemUnderMouse).Text;
    except
      ; // 弹出时记录的鼠标下的 Item，万一执行时被释放了，就可能出异常，要抓住
    end;
  end;
end;

procedure TCnAICoderChatForm.pmChatPopup(Sender: TObject);
begin
  FItemUnderMouse := FChatBox.GetItemUnderMouse;
  actCopy.Enabled := FItemUnderMouse <> nil;
  actCopyCode.Enabled := FItemUnderMouse <> nil;
end;

procedure TCnAICoderChatForm.actCopyCodeExecute(Sender: TObject);
const
  CODE_BLOCK = '```';
var
  S: string;
  I1, I2: Integer;
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
      begin
        S := TCnChatMessage(FItemUnderMouse).Text;
        I1 := Pos(CODE_BLOCK, S);
        if I1 > 0 then
        begin
          Delete(S, 1, I1 + Length(CODE_BLOCK) - 1);
          I2 := Pos(CODE_BLOCK, S);
          if I2 > 0 then
          begin
            S := Copy(S, 1, I2 - 1);
            Clipboard.AsText := Trim(S);
            Exit;
          end;
        end;

        ErrorDlg(SCnAICoderWizardErrorNoCode);
      end;
    except
      ; // 弹出时记录的鼠标下的 Item，万一执行时被释放了，就可能出异常，要抓住
    end;
  end;
end;

procedure TCnAICoderChatForm.actClearExecute(Sender: TObject);
begin
  FChatBox.Items.ClearNoWaiting;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
