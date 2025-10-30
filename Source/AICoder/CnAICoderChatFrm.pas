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

unit CnAICoderChatFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵĶԻ����嵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi / C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.07 V1.0
*               ������Ԫ
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
    actFont: TAction;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    cbbActiveEngine: TComboBox;
    btn2: TToolButton;
    btnReferSelection: TToolButton;
    btn3: TToolButton;
    pnlSend: TPanel;
    btnMsgSend: TSpeedButton;
    tlbSend: TToolBar;
    actAddDraftToFavorite: TAction;
    actClearFavorite: TAction;
    btnFavorite: TToolButton;
    btnAddToFavorite: TToolButton;
    btnClearFavorite: TToolButton;
    pmFavorite: TPopupMenu;
    AddMsgtoFavorite1: TMenuItem;
    actAddMsgToFavorite: TAction;
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
    procedure actFontExecute(Sender: TObject);
    procedure cbbActiveEngineChange(Sender: TObject);
    procedure btnReferSelectionClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actClearFavoriteExecute(Sender: TObject);
    procedure actAddDraftToFavoriteExecute(Sender: TObject);
    procedure actAddMsgToFavoriteExecute(Sender: TObject);
  private
    FChatBox: TCnChatBox;
    FWizard: TCnAICoderWizard;
    FItemUnderMouse: TCnChatItem;
    procedure OnEditorChange(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;

    procedure BuildFavoriteMenu;
    procedure FavoriteItemClick(Sender: TObject);
  public
    class function ExtractCode(Item: TCnChatMessage): string;
    procedure NotifySettingChanged;

    procedure UpdateCaption;
    procedure AddMessage(const Msg, AFrom: string; IsMe: Boolean = False);

    property ChatBox: TCnChatBox read FChatBox;
    property Wizard: TCnAICoderWizard read FWizard write FWizard;
  end;

var
  CnAICoderChatForm: TCnAICoderChatForm = nil;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  CnAICoderNetClient, CnAICoderConfig, CnCommon, CnIniStrUtils, CnWizUtils,
  CnStrings;

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
var
  I: Integer;
begin
  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := EditControlWrapper.BackgroundColor;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ColorYou := BK_COLOR;
  FChatBox.ColorMe := BK_COLOR;
  FChatBox.ColorSelection := BK_COLOR;
  FChatBox.ScrollBarVisible := True;
  FChatBox.PopupMenu := pmChat;

  if Trim(CnAIEngineOptionManager.ChatFontStr) <> '' then
  begin
    StringToFont(CnAIEngineOptionManager.ChatFontStr, FChatBox.Font);
    StringToFont(CnAIEngineOptionManager.ChatFontStr, mmoSelf.Font);
  end
  else
  begin
    FChatBox.Font := EditControlWrapper.FontBasic;
    mmoSelf.Font := EditControlWrapper.FontBasic;
  end;

  // ������������ɫ����༭������Ϊ����ɫ������
  FChatBox.Font.Color := clBlack;

  mmoSelf.Font.Color := EditControlWrapper.ForegroundColor;
  mmoSelf.Color := EditControlWrapper.BackgroundColor;
  btnReferSelection.Down := CnAIEngineOptionManager.ReferSelection;

  WizOptions.ResetToolbarWithLargeIcons(tlbAICoder);
  WizOptions.ResetToolbarWithLargeIcons(tlbSend);

  cbbActiveEngine.Items.Clear;
  for I := 0 to CnAIEngineManager.EngineCount - 1 do
    cbbActiveEngine.Items.Add(CnAIEngineManager.Engines[I].EngineName);

  cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;
  BuildFavoriteMenu;

  EditControlWrapper.AddEditorChangeNotifier(OnEditorChange);
end;

procedure TCnAICoderChatForm.FormDestroy(Sender: TObject);
begin
  EditControlWrapper.RemoveEditorChangeNotifier(OnEditorChange);
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
//    // ѡ������������ ```
//  else if Action = actSend then
//    (Action as TAction).Enabled := mmoSelf.Lines.Text <> '';
  if Action = actClear then
    TAction(Action).Enabled := FChatBox.Items.Count > 0
  else if Action = actClearFavorite then
    TAction(Action).Enabled := CnAIEngineOptionManager.GetFavoriteCount > 0
  else if Action = actAddDraftToFavorite then
    TAction(Action).Enabled := mmoSelf.Lines.Text <> '';
end;

procedure TCnAICoderChatForm.btnMsgSendClick(Sender: TObject);
var
  Msg: TCnChatMessage;
  S: string;
  His: TStrings;
begin
  if Trim(mmoSelf.Lines.Text) <> '' then
  begin
    His := TStringList.Create;
    try
      FChatBox.GetRecentMessages(His, CnAIEngineOptionManager.HistoryCount);

      // ��������Ϣ
      Msg := FChatBox.Items.AddMessage;
      Msg.From := UIStringToNativeString(CnAIEngineManager.CurrentEngineName);
      Msg.Text := mmoSelf.Lines.Text;
      Msg.FromType := cmtMe;

      // ��������Ϣ
      Msg := FChatBox.Items.AddMessage;
      Msg.From := UIStringToNativeString(CnAIEngineManager.CurrentEngineName);
      Msg.FromType := cmtYou;
      Msg.Text := '...';

      S := CnOtaGetCurrentSelection;

      if btnReferSelection.Down and (Trim(S) <> '') then
      begin
        S := (mmoSelf.Lines.Text + #13#10 +
          CnAIEngineManager.CurrentEngine.Option.ReferSelectionPrompt + #13#10 + S);
        CnAIEngineManager.CurrentEngine.AskAIEngineForCode(S, His, Msg,
          artRaw, FWizard.ForCodeAnswer);
      end
      else
        CnAIEngineManager.CurrentEngine.AskAIEngineForCode(mmoSelf.Lines.Text, His, Msg,
          artRaw, FWizard.ForCodeAnswer);
      mmoSelf.Lines.Text := '';
    finally
      His.Free;
    end;
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
  begin
    Key := #0;
    btnMsgSend.Click;
  end;
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

procedure TCnAICoderChatForm.OnEditorChange(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
begin
  if ctOptionChanged in ChangeType then
  begin
    mmoSelf.Font.Color := EditControlWrapper.ForegroundColor;
    mmoSelf.Color := EditControlWrapper.BackgroundColor;
    FChatBox.Color := EditControlWrapper.BackgroundColor;
  end;
end;

procedure TCnAICoderChatForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TCnAICoderChatForm.actCopyExecute(Sender: TObject);
var
  S: string;
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
      begin
        S := TCnChatMessage(FItemUnderMouse).SelText;
        if S = '' then
          S := TCnChatMessage(FItemUnderMouse).Text;

        Clipboard.AsText := S;
      end;
    except
      ; // ����ʱ��¼������µ� Item����һִ��ʱ���ͷ��ˣ��Ϳ��ܳ��쳣��Ҫץס
    end;
    FItemUnderMouse := nil;
  end;
end;

procedure TCnAICoderChatForm.pmChatPopup(Sender: TObject);
begin
  FItemUnderMouse := FChatBox.GetItemUnderMouse;
  actCopy.Enabled := FItemUnderMouse <> nil;
  actCopyCode.Enabled := FItemUnderMouse <> nil;
  actAddMsgToFavorite.Enabled := FItemUnderMouse <> nil;
end;

procedure TCnAICoderChatForm.actCopyCodeExecute(Sender: TObject);
var
  S: string;
begin
  if FItemUnderMouse <> nil then
  begin
    try
      if FItemUnderMouse is TCnChatMessage then
      begin
        S := ExtractCode(TCnChatMessage(FItemUnderMouse));
        if S <> '' then
        begin
          Clipboard.AsText := Trim(S);
          Exit;
        end;

        ErrorDlg(SCnAICoderWizardErrorNoCode);
      end;
    except
      ; // ����ʱ��¼������µ� Item����һִ��ʱ���ͷ��ˣ��Ϳ��ܳ��쳣��Ҫץס
    end;
    FItemUnderMouse := nil;
  end;
end;

procedure TCnAICoderChatForm.actClearExecute(Sender: TObject);
begin
  FChatBox.Items.ClearNoWaiting;
  FItemUnderMouse := nil;
end;

procedure TCnAICoderChatForm.actFontExecute(Sender: TObject);
var
  OldColor: TColor;
begin
  dlgFont.Font := mmoSelf.Font;
  if dlgFont.Execute then
  begin
    mmoSelf.Font := dlgFont.Font;
    mmoSelf.Font.Color := EditControlWrapper.ForegroundColor;

    OldColor := FChatBox.Font.Color;
    FChatBox.Font := dlgFont.Font;
    FChatBox.Font.Color := OldColor;
    // ������������ɫ����༭�����������Ϊ����ɫ������

    CnAIEngineOptionManager.ChatFontStr := FontToString(dlgFont.Font);
  end;
end;

procedure TCnAICoderChatForm.cbbActiveEngineChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbActiveEngine.Text;
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
  UpdateCaption;
end;

class function TCnAICoderChatForm.ExtractCode(Item: TCnChatMessage): string;
const
  CODE_BLOCK = '```';
  DELPHI_PREFIX = 'delphi' + #13#10;
  PASCAL_PREFIX = 'pascal' + #13#10;
  C_PREFIX = 'c' + #13#10;
  CPP_PREFIX = 'c++' + #13#10;
var
  S: string;
  I1, I2: Integer;
begin
  Result := '';
  if Item = nil then
    Exit;

  S := TCnChatMessage(Item).Text;
  I1 := Pos(CODE_BLOCK, S);
  if I1 > 0 then
  begin
    Delete(S, 1, I1 + Length(CODE_BLOCK) - 1);
    I2 := Pos(CODE_BLOCK, S);
    if I2 > 0 then
    begin
      S := Copy(S, 1, I2 - 1);
      I2 := Pos(DELPHI_PREFIX, LowerCase(S)); // ȥ����һ�� ``` ��� delphi
      if I2 = 1 then
        Delete(S, 1, Length(DELPHI_PREFIX));

      I2 := Pos(PASCAL_PREFIX, LowerCase(S)); // ȥ����һ�� ``` ��� pascal
      if I2 = 1 then
        Delete(S, 1, Length(PASCAL_PREFIX));

      I2 := Pos(C_PREFIX, LowerCase(S));      // ȥ����һ�� ``` ��� C
      if I2 = 1 then
        Delete(S, 1, Length(C_PREFIX));

      I2 := Pos(CPP_PREFIX, LowerCase(S));    // ȥ����һ�� ``` ��� C++
      if I2 = 1 then
        Delete(S, 1, Length(CPP_PREFIX));

      Result := Trim(S);
    end;
  end;
end;

procedure TCnAICoderChatForm.NotifySettingChanged;
var
  Old: TNotifyEvent;
begin
  Old := cbbActiveEngine.OnChange;
  try
    cbbActiveEngine.OnChange := nil;
    cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;
  finally
    cbbActiveEngine.OnChange := Old;
  end;

  UpdateCaption;
end;

procedure TCnAICoderChatForm.btnReferSelectionClick(Sender: TObject);
begin
  btnReferSelection.Down := not btnReferSelection.Down;
  CnAIEngineOptionManager.ReferSelection := btnReferSelection.Down;
end;

procedure TCnAICoderChatForm.BuildFavoriteMenu;
var
  I: Integer;
  Item: TMenuItem;
  S: string;
begin
  pmFavorite.Items.Clear;
  for I := 0 to CnAIEngineOptionManager.GetFavoriteCount - 1 do
  begin
    S := CnAIEngineOptionManager.GetFavorite(I);
    if Length(S) > 6 then
      S := Copy(S, 1, 6) + '...';

    Item := TMenuItem.Create(pmFavorite);
    Item.Caption := '&' + IntToStr(I + 1) + ' ' + S;
    Item.Tag := I;
    Item.OnClick := FavoriteItemClick;
    pmFavorite.Items.Add(Item);
  end;
  btnFavorite.Enabled := pmFavorite.Items.Count > 0;
end;

procedure TCnAICoderChatForm.FavoriteItemClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TComponent).Tag;
  if (Idx >= 0) and (Idx < CnAIEngineOptionManager.GetFavoriteCount) then
    mmoSelf.Lines.Text := CnAIEngineOptionManager.GetFavorite(Idx);
end;

procedure TCnAICoderChatForm.actClearFavoriteExecute(Sender: TObject);
begin
  CnAIEngineOptionManager.ClearFavorites;
  BuildFavoriteMenu;
end;

procedure TCnAICoderChatForm.actAddDraftToFavoriteExecute(Sender: TObject);
begin
  if Trim(mmoSelf.Lines.Text) <> '' then
  begin
    CnAIEngineOptionManager.AddToFavorite(mmoSelf.Lines.Text);
    BuildFavoriteMenu;
  end;
end;

procedure TCnAICoderChatForm.actAddMsgToFavoriteExecute(Sender: TObject);
begin
  if FChatBox.Focused and (FItemUnderMouse <> nil) and (FItemUnderMouse is TCnChatMessage)
    and (TCnChatMessage(FItemUnderMouse).FromType = cmtMe) then
  begin
    CnAIEngineOptionManager.AddToFavorite(TCnChatMessage(FItemUnderMouse).Text);
    BuildFavoriteMenu;
  end;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
