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

unit CnWizConfigFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ר�����ô��嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.05.23 V1.8
*               �������ݼ��Ƿ��ͻ�Ļ���
*           2012.11.30 V1.7
*               ȥ��ʹ�� FormScaler ���µ������ֵĻ���
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2012.06.21 V1.5
*               ������������������ĸ����ר������������༭��
*           2004.11.18 V1.4
*               ���� listbox �Ի����ʺ� 120DPI ��С���� (shenloqi)
*           2003.06.25 V1.3
*               �Ƴ� IDE ��չ���ý��� (LiuXiao)
*           2003.05.01 V1.2
*               ���� IDE ��չ����
*           2003.03.20 V1.1
*               �������Ա༭������
*           2002.10.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, ToolWin, StdCtrls, ImgList, Buttons,
  {$IFDEF FPC} LCLType, LCLProc, CnHotKey, {$ENDIF}
  CnDesignEditor, CnWizMultiLang, CnWizClasses, CnDesignEditorConsts, CnWizMenuAction;

type

//==============================================================================
// ר�����ô���
//==============================================================================

{ TCnWizConfigForm }

  TCnWizConfigForm = class(TCnTranslateForm)
    PageControl: TPageControl;
    tsWizards: TTabSheet;
    pnlWizard: TPanel;
    lblWizardName: TLabel;
    bvlWizard: TBevel;
    Label1: TLabel;
    lblWizardAuthor: TLabel;
    lblWizardComment: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    HotKeyWizard: THotKey;
    Label5: TLabel;
    cbWizardActive: TCheckBox;
    btnConfig: TButton;
    lblWizardKind: TLabel;
    Label7: TLabel;
    tsEnvOption: TTabSheet;
    grpOthers: TGroupBox;
    Label2: TLabel;
    gbHintWnd: TGroupBox;
    cbShowWizComment: TCheckBox;
    btnResetWizComment: TButton;
    cbShowHint: TCheckBox;
    gbUpdate: TGroupBox;
    rbUpgradeDisabled: TRadioButton;
    rbUpgradeAll: TRadioButton;
    cbUpgradeReleaseOnly: TCheckBox;
    btnCheckUpgrade: TButton;
    tsPropEditor: TTabSheet;
    Panel1: TPanel;
    lblDesignEditorName: TLabel;
    Bevel1: TBevel;
    Label11: TLabel;
    lblDesignEditorAuthor: TLabel;
    lblDesignEditorComment: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    lblDesignEditorKind: TLabel;
    Label18: TLabel;
    cbDesignEditorActive: TCheckBox;
    btnDesignEditorConfig: TButton;
    imgIcon: TImage;
    Image1: TImage;
    dlgSaveActionList: TSaveDialog;
    grpTools: TGroupBox;
    btnExportImagelist: TButton;
    btnExportActionList: TButton;
    btnExportComponents: TButton;
    chkUseToolsMenu: TCheckBox;
    btnDesignEditorCustomize: TButton;
    ilEnable: TImageList;
    chkUserDir: TCheckBox;
    edtUserDir: TEdit;
    btnUserDir: TSpeedButton;
    chkFixThreadLocale: TCheckBox;
    chkUseOneCPUCore: TCheckBox;
    pnlListBox: TPanel;
    lbWizards: TListBox;
    pnlEditors: TPanel;
    lbDesignEditors: TListBox;
    pnlListTop: TPanel;
    edtSearchWizard: TEdit;
    lblSearchWizard: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pnlEditorTop: TPanel;
    edtSearchEditor: TEdit;
    lblSearchEditor: TLabel;
    btnSort: TButton;
    btnRestoreSetting: TButton;
    chkUseLargeIcon: TCheckBox;
    chkEnlarge: TCheckBox;
    cbbEnlarge: TComboBox;
    chkDisableIcons: TCheckBox;
    procedure lbWizardsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure lbWizardsClick(Sender: TObject);
    procedure HotKeyWizardExit(Sender: TObject);
    procedure cbWizardActiveClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lbWizardsDblClick(Sender: TObject);
    procedure btnResetWizCommentClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure cbShowHintClick(Sender: TObject);
    procedure UpdateControls(Sender: TObject);
    procedure btnCheckUpgradeClick(Sender: TObject);
    procedure lbDesignEditorsClick(Sender: TObject);
    procedure lbDesignEditorsDblClick(Sender: TObject);
    procedure lbDesignEditorsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbDesignEditorActiveClick(Sender: TObject);
    procedure btnDesignEditorConfigClick(Sender: TObject);
    procedure btnExportImagelistClick(Sender: TObject);
    procedure btnExportActionListClick(Sender: TObject);
    procedure btnExportComponentsClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
    procedure btnDesignEditorCustomizeClick(Sender: TObject);
    procedure btnUserDirClick(Sender: TObject);
    procedure edtSearchWizardChange(Sender: TObject);
    procedure edtSearchEditorChange(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure btnRestoreSettingClick(Sender: TObject);
    procedure lbWizardsKeyPress(Sender: TObject; var Key: Char);
    procedure lbDesignEditorsKeyPress(Sender: TObject; var Key: Char);
  private
    FWizardsActiveChanged: Boolean;
    FShortCuts: array of TShortCut;    // ����ר�ҵĿ�ݼ�
    FActives: array of Boolean;        // ����ר�ҵ�����״̬
    FEditorActives: array of Boolean;  // ���б༭��������״̬
    FDrawTextHeight: Integer;
    function CalcSelectedWizardIndex(Wizard: TCnBaseWizard = nil): Integer;
    {* ����ָ�� Wizard ʵ����ר���е������ţ��򷵻�ר���б���е�ѡ�е�������}
    function CalcSelectedEditorIndex(Editor: TCnDesignEditorInfo = nil): Integer;
    procedure ToggleWizardActive;
    procedure TogglePropertyEditorActive;
  protected
    function GetHelpTopic: string; override;
  public

  end;

// ��ʾ���ô���
procedure ShowCnWizConfigForm(AIcon: TIcon = nil);

implementation

uses
  CnWizManager, CnCommon, CnWizConsts, CnWizShortCut, CnWizOptions, CnEventBus,
  CnWizCommentFrm, CnWizUtils, CnWizUpgradeFrm, CnWizIdeUtils, CnWizMenuSortFrm;

const
  csSelectedColor = $FFB0B0;
  csNormalColor = $FFF4F4;
  csShadowColor = $444444;

  csLastSelectedItem = 'LastSelectedItem';

  CN_ITEM_DRAW_HEIGHT = 12;
  CN_ITEM_ICON_WIDTH = 42;

type
  TCnActionWizardHack = class(TCnActionWizard);
{$IFDEF IDE_SUPPORT_HDPI}
  TControlHack = class(TControl);
{$ENDIF}

{$R *.DFM}

// ��ʾ���ô���
procedure ShowCnWizConfigForm(AIcon: TIcon = nil);
begin
  with TCnWizConfigForm.Create(Application.MainForm) do
  try
    ShowHint := WizOptions.ShowHint;
    if AIcon <> nil then
      Icon := AIcon;
    ShowModal;
  finally
    Free;
  end;
end;

//==============================================================================
// ר�����ô���
//==============================================================================

{ TCnWizConfigForm }

// �����ʼ��
procedure TCnWizConfigForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  PageControl.ActivePageIndex := 0;

  // ר������ҳ��
  SetLength(FShortCuts, CnWizardMgr.WizardCount);
  SetLength(FActives, CnWizardMgr.WizardCount);
  for I := 0 to CnWizardMgr.WizardCount - 1 do
  begin
    FActives[I] := CnWizardMgr[I].Active;
    if CnWizardMgr[I] is TCnActionWizard then
      FShortCuts[I] := TCnActionWizard(CnWizardMgr[I]).Action.ShortCut
    else
      FShortCuts[I] := 0;
    lbWizards.Items.AddObject(CnWizardMgr[I].WizardName, CnWizardMgr[I]);
  end;
  I := WizOptions.ReadInteger(SCnOptionSection, csLastSelectedItem, 0);
  if (I >= 0) and (I < lbWizards.ItemIndex) then
    lbWizards.ItemIndex := I;

  lbWizardsClick(lbWizards);
  ActiveControl := lbWizards;

  // ���Ա༭��ҳ��
  SetLength(FEditorActives, CnDesignEditorMgr.PropEditorCount +
    CnDesignEditorMgr.CompEditorCount);
  for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
  begin
    FEditorActives[I] := CnDesignEditorMgr.PropEditors[I].Active;
    lbDesignEditors.Items.AddObject(CnDesignEditorMgr.PropEditors[I].Name,
      CnDesignEditorMgr.PropEditors[I]);
  end;

  for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
  begin
    FEditorActives[CnDesignEditorMgr.PropEditorCount + I] :=
      CnDesignEditorMgr.CompEditors[I].Active;
    lbDesignEditors.Items.AddObject(CnDesignEditorMgr.CompEditors[I].Name, CnDesignEditorMgr.CompEditors[I]);
  end;
  if lbDesignEditors.Items.Count > 0 then
    lbDesignEditors.ItemIndex := 0;
  lbDesignEditorsClick(lbDesignEditors);

  // ��������ҳ��
  chkUseToolsMenu.Checked := WizOptions.UseToolsMenu;
  cbShowHint.Checked := WizOptions.ShowHint;
  cbShowWizComment.Checked := WizOptions.ShowWizComment;
  chkUseOneCPUCore.Checked := WizOptions.UseOneCPUCore;
  chkFixThreadLocale.Checked := WizOptions.FixThreadLocale;
  chkUseLargeIcon.Checked := WizOptions.UseLargeIcon;

  // ��������
  if WizOptions.UpgradeStyle = usDisabled then
    rbUpgradeDisabled.Checked := True
  else
    rbUpgradeAll.Checked := True;
  cbUpgradeReleaseOnly.Checked := WizOptions.UpgradeReleaseOnly;

  //�Ի��߶ȵ���
  FDrawTextHeight := IdeGetScaledPixelsFromOrigin(CN_ITEM_DRAW_HEIGHT, lbWizards);
  if Enlarged then
  begin
    FDrawTextHeight := Round(FDrawTextHeight * GetFactorFromSizeEnlarge(Enlarge));
    lbWizards.ItemHeight := Round(lbWizards.ItemHeight * GetFactorFromSizeEnlarge(Enlarge));
    lbDesignEditors.ItemHeight := Round(lbDesignEditors.ItemHeight * GetFactorFromSizeEnlarge(Enlarge));
  end;

{$IFDEF IDE_SUPPORT_HDPI}
  imgIcon.Stretch := True;
{$ENDIF}

  chkUserDir.Checked := WizOptions.UseCustomUserDir;
  edtUserDir.Text := WizOptions.CustomUserDir;
  chkEnlarge.Checked := WizOptions.SizeEnlarge <> wseOrigin;
  if chkEnlarge.Checked then
    cbbEnlarge.ItemIndex := Ord(WizOptions.SizeEnlarge) - 1
  else
    cbbEnlarge.ItemIndex := 0;
  chkDisableIcons.Checked := WizOptions.DisableIcons;

  UpdateControls(nil);

  PageControl.ActivePageIndex := 0;
end;

// �����ͷ�
procedure TCnWizConfigForm.FormDestroy(Sender: TObject);
var
  I: Integer;
  Changes: DWORD;
  OldUseLargeIcon: Boolean;
begin
  if ModalResult = mrOK then
  begin
    if FWizardsActiveChanged then
      Changes := CNWIZARDS_SETTING_WIZARDS_CHANGED
    else
      Changes := 0;

    // ר������ҳ��
    WizShortCutMgr.BeginUpdate;
    try
      for I := 0 to CnWizardMgr.WizardCount - 1 do
      begin
        CnWizardMgr[I].Active := FActives[I];
        if CnWizardMgr[I] is TCnActionWizard then
          if TCnActionWizard(CnWizardMgr[I]).Action <> nil then // ��� Action Ϊ nil ���޷����ÿ�ݼ�
            TCnActionWizard(CnWizardMgr[I]).Action.ShortCut := FShortCuts[I];
      end;
    finally
      WizShortCutMgr.EndUpdate;
    end;

    // ���Ա༭��ҳ��
    for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
    begin
      if CnDesignEditorMgr.PropEditors[I].Active <> FEditorActives[I] then
        Changes := Changes or CNWIZARDS_SETTING_PROPERTY_EDITORS_CHANGED;
      CnDesignEditorMgr.PropEditors[I].Active := FEditorActives[I];
    end;

    for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
    begin
      if CnDesignEditorMgr.CompEditors[I].Active <>
        FEditorActives[CnDesignEditorMgr.PropEditorCount + I] then
        Changes := Changes or CNWIZARDS_SETTING_COMPONENT_EDITORS_CHANGED;
      CnDesignEditorMgr.CompEditors[I].Active :=
        FEditorActives[CnDesignEditorMgr.PropEditorCount + I];
    end;

    CnDesignEditorMgr.UnRegister;
    CnDesignEditorMgr.Register;

    // ��������ҳ��
    WizOptions.UseToolsMenu := chkUseToolsMenu.Checked;
    WizOptions.ShowHint := cbShowHint.Checked;
    WizOptions.ShowWizComment := cbShowWizComment.Checked;
    WizOptions.UseOneCPUCore := chkUseOneCPUCore.Checked;
    WizOptions.FixThreadLocale := chkFixThreadLocale.Checked;

    OldUseLargeIcon := WizOptions.UseLargeIcon;
    WizOptions.UseLargeIcon := chkUseLargeIcon.Checked;

    // ��������
    if rbUpgradeDisabled.Checked then
      WizOptions.UpgradeStyle := usDisabled
    else
      WizOptions.UpgradeStyle := usAllUpgrade;
    WizOptions.UpgradeReleaseOnly := cbUpgradeReleaseOnly.Checked;

    WizOptions.UseCustomUserDir := chkUserDir.Checked;
    WizOptions.CustomUserDir := edtUserDir.Text;
    if chkEnlarge.Checked and (cbbEnlarge.ItemIndex >= 0) then
      WizOptions.SizeEnlarge := TCnWizSizeEnlarge(cbbEnlarge.ItemIndex + 1)
    else
      WizOptions.SizeEnlarge := wseOrigin;
    WizOptions.DisableIcons := chkDisableIcons.Checked;
    
    WizOptions.WriteInteger(SCnOptionSection, csLastSelectedItem, lbWizards.ItemIndex);

    WizOptions.SaveSettings(True);
    WizOptions.UseLargeIcon := OldUseLargeIcon; // �����Ѹ�ٻָ�ԭֵ��ȷ���´���������Ч

    CnWizardMgr.SaveSettings;

    // ֪ͨ���ר�Ұ������öԻ���رղ������øı���
    EventBus.PostEvent(EVENT_CNWIZARDS_SETTING_CHANGED, Pointer(Changes));
  end;
  FShortCuts := nil;
  FActives := nil;
  FEditorActives := nil;
end;

// �����С���ʱˢ���б����ʾ
procedure TCnWizConfigForm.FormResize(Sender: TObject);
begin
  lbWizards.Refresh;                    // �����б��ˢ�²�����������
  lbDesignEditors.Refresh;
end;

//------------------------------------------------------------------------------
// ר�����ô���
//------------------------------------------------------------------------------

// ���� ListBox ��Ŀ
procedure TCnWizConfigForm.lbWizardsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Canvas: TCanvas;
  ARect: TRect;
  R: TRect;
  Wizard: TCnBaseWizard;
  Idx, X, Y: Integer;
  Bmp: TBitmap;
  EnableIndex, EnableIconMargin: Integer;
{$IFDEF IDE_SUPPORT_HDPI}
  XIcon: TIcon;
{$ENDIF}
begin
  if not (Control is TListBox) then Exit;
  ListBox := TListBox(Control);
  Wizard := TCnBaseWizard(ListBox.Items.Objects[Index]);
  Idx := CalcSelectedWizardIndex(Wizard);

  // ������ʱλͼ��������˸
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.Width := RectWidth(Rect);
    Bmp.Height := RectHeight(Rect);
    ARect := Bounds(0, 0, Bmp.Width, Bmp.Height);

    R.Left := ARect.Left + 4;
    R.Right := ARect.Right - 5;
    R.Top := ARect.Top + 2;
    R.Bottom := ARect.Bottom - 2;

    Canvas := Bmp.Canvas;
    Canvas.Font.Assign(ListBox.Font);
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := ListBox.Color;
    Canvas.FillRect(ARect);
    Canvas.Brush.Color := csShadowColor;
    Canvas.RoundRect(R.Left + 1, R.Top + 1, R.Right + 1, R.Bottom + 1, 8, 8);

    if odSelected in State then
    begin
      Canvas.Brush.Color := csSelectedColor;
      Canvas.Font.Color := clBlue;
    end
    else if FActives[Idx] then
    begin
      Canvas.Brush.Color := csNormalColor;
      Canvas.Font.Color := clBlack;
    end
    else
    begin
      Canvas.Brush.Color := csNormalColor;
      Canvas.Font.Color := clGray;
    end;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
    if Wizard.BigIcon <> nil then
    begin
{$IFDEF IDE_SUPPORT_HDPI}
      ARect.Left := R.Left + 4;
      ARect.Top := R.Top + (R.Bottom - R.Top - IdeGetScaledPixelsFromOrigin(Wizard.BigIcon.Height, lbWizards)) div 2;
      ARect.Right := ARect.Left + IdeGetScaledPixelsFromOrigin(Wizard.BigIcon.Width, lbWizards);
      ARect.Bottom := ARect.Top + IdeGetScaledPixelsFromOrigin(Wizard.BigIcon.Height, lbWizards);

      DrawIconEx(Canvas.Handle, ARect.Left, ARect.Top, Wizard.BigIcon.Handle,
        ARect.Width, ARect.Height, 0, 0, DI_NORMAL);

      // �� 32x32 û�������ͼ�꣬ԭ�ⲻ�����Ƶ� 32x32 �� HDPI ������Ŀؼ��Ļ�����
{$ELSE}
      Canvas.Draw(R.Left + 4, R.Top + (R.Bottom - R.Top - Wizard.BigIcon.Height) div 2, Wizard.BigIcon);
{$ENDIF}
    end;

    X := R.Left + IdeGetScaledPixelsFromOrigin(CN_ITEM_ICON_WIDTH, Control);
    Y := R.Top + 2;
    Canvas.TextOut(X, Y, SCnWizardNameStr + Wizard.WizardName);
    Inc(Y, FDrawTextHeight + 2);
    if FActives[Idx] then
      Canvas.TextOut(X, Y, SCnWizardStateStr + SCnWizardActiveStr)
    else
      Canvas.TextOut(X, Y, SCnWizardStateStr + SCnWizardDisActiveStr);
    Inc(Y, FDrawTextHeight + 2);
    Canvas.TextOut(X, Y, SCnWizardShortCutStr + ShortCutToText(FShortCuts[Idx]));

    BitBlt(ListBox.Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height,
      Canvas.Handle, 0, 0, SRCCOPY);

    // ������ͼ��
    if FActives[Idx] then
      EnableIndex := 0
    else
      EnableIndex := 1;

{$IFDEF IDE_SUPPORT_HDPI}
    EnableIconMargin := (Rect.Bottom - Rect.Top
      - IdeGetScaledPixelsFromOrigin(ilEnable.Height, lbWizards)) div 2;
    if EnableIconMargin < 0 then
      EnableIconMargin := 0;

    XIcon := TIcon.Create;
    try
      ilEnable.GetIcon(EnableIndex, XIcon);
      DrawIconEx(ListBox.Canvas.Handle, Rect.Right - EnableIconMargin
        - IdeGetScaledPixelsFromOrigin(ilEnable.Width, lbWizards) - 6,
        Rect.Top + EnableIconMargin + 1, XIcon.Handle,
        IdeGetScaledPixelsFromOrigin(ilEnable.Width, lbWizards),
        IdeGetScaledPixelsFromOrigin(ilEnable.Height, lbWizards), 0, 0, DI_NORMAL);
    finally
      XIcon.Free;
    end;
{$ELSE}
    EnableIconMargin := (Rect.Bottom - Rect.Top - ilEnable.Height) div 2;
    if EnableIconMargin < 0 then
      EnableIconMargin := 0;
    ilEnable.Draw(ListBox.Canvas, Rect.Right - EnableIconMargin - ilEnable.Width - 6,
      Rect.Top + EnableIconMargin + 1, EnableIndex);
{$ENDIF}
  finally
    Bmp.Free;
  end;
end;

// ListBox ����¼�
procedure TCnWizConfigForm.lbWizardsClick(Sender: TObject);
var
  Wizard: TCnBaseWizard;
  AName, Author, Email, Comment: string;
  Idx: Integer;
begin
  if (lbWizards.Items.Count = 0) or (lbWizards.ItemIndex < 0) then
  begin
    btnConfig.Enabled := False;
    imgIcon.Picture.Graphic := nil;
    lblWizardName.Caption := '';
    lblWizardAuthor.Caption := '';
    lblWizardComment.Caption := '';
    lblWizardKind.Caption := '';
    HotKeyWizard.HotKey := 0;
    
    Exit;
  end;
  Wizard := TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]);
  Idx := CalcSelectedWizardIndex(Wizard);

{$IFDEF IDE_SUPPORT_HDPI}
  imgIcon.Canvas.Brush.Style := bsSolid;
  imgIcon.Canvas.Brush.Color := TControlHack(imgIcon.Parent).Color;
  imgIcon.Canvas.FillRect(Rect(0, 0, imgIcon.Width, imgIcon.Height));
  DrawIconEx(imgIcon.Canvas.Handle, 0, 0, Wizard.BigIcon.Handle,
    imgIcon.Width, imgIcon.Height, 0, 0, DI_NORMAL);
  // �� 32x32 û�������ͼ�꣬ԭ�ⲻ�����Ƶ� 32x32 �� HDPI ������Ŀؼ��Ļ�����
{$ELSE}
  imgIcon.Picture.Graphic := Wizard.BigIcon;
{$ENDIF}

  Wizard.GetWizardInfo(AName, Author, Email, Comment);
  lblWizardName.Caption := AName;
  lblWizardAuthor.Caption := CnAuthorEmailToStr(Author, '');
  lblWizardComment.Caption := Comment;
  lblWizardKind.Caption := GetCnWizardTypeName(Wizard);

  cbWizardActive.Checked := FActives[Idx];
  HotKeyWizard.HotKey := FShortCuts[Idx];
  HotKeyWizard.Visible := (Wizard is TCnActionWizard) and
    TCnActionWizard(Wizard).EnableShortCut;
  Label4.Visible := HotKeyWizard.Visible;
  btnConfig.Enabled := Wizard.HasConfig and cbWizardActive.Checked;
  btnRestoreSetting.Enabled := (Wizard.HasConfig or (Wizard is TCnActionWizard))
    and cbWizardActive.Checked;
end;

// ListBox ˫���¼�
procedure TCnWizConfigForm.lbWizardsDblClick(Sender: TObject);
begin
  if btnConfig.Visible and btnConfig.Enabled then
    btnConfigClick(btnConfig);
end;

// �����ȼ�
procedure TCnWizConfigForm.HotKeyWizardExit(Sender: TObject);
var
  Idx: Integer;
  Wizard: TCnBaseWizard;
  WizardAction: TCnWizAction;
begin
  Idx := CalcSelectedWizardIndex();
  WizardAction := nil;
  if lbWizards.ItemIndex >= 0 then
  begin
    Wizard := TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]);
    if (Wizard <> nil) and (Wizard is TCnActionWizard) then
      WizardAction := (Wizard as TCnActionWizard).Action;
  end;

  if Idx >= 0 then
  begin
{$IFNDEF DELPHI_OTA}
    FShortCuts[Idx] := HotKeyWizard.HotKey;
{$ELSE}
    if CheckQueryShortCutDuplicated(HotKeyWizard.HotKey, WizardAction) <> sdDuplicatedStop then
      FShortCuts[Idx] := HotKeyWizard.HotKey
    else
      HotKeyWizard.SetFocus;
{$ENDIF}
  end;
end;

// ����ר�һ�Ծ
procedure TCnWizConfigForm.cbWizardActiveClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CalcSelectedWizardIndex();
  if Idx >= 0 then
  begin
    FWizardsActiveChanged := True;
    FActives[Idx] := cbWizardActive.Checked;
    btnConfig.Enabled := cbWizardActive.Checked and
      TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]).HasConfig;
    lbWizards.Refresh;
  end
  else
    btnConfig.Enabled := False;
end;

procedure TCnWizConfigForm.ToggleWizardActive;
var
  Idx: Integer;
begin
  Idx := CalcSelectedWizardIndex; // Idx �᷵�� lbWizards.ItemIndex
  if Idx >= 0 then
  begin
    FWizardsActiveChanged := True;
    FActives[Idx] := not FActives[Idx];

    // ʵʱ���� Wizard ʵ����״̬
    Screen.Cursor := crHourGlass;
    try
      TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]).Active := FActives[Idx];
    finally
      Screen.Cursor := crDefault;
    end;
    cbWizardActive.Checked := FActives[Idx];
    btnConfig.Enabled := FActives[Idx] and
      TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]).HasConfig;
    lbWizards.Refresh;
  end
  else
    btnConfig.Enabled := False;
end;

procedure TCnWizConfigForm.TogglePropertyEditorActive;
var
  Idx: Integer;
begin
  Idx := CalcSelectedEditorIndex;
  if Idx >= 0 then
  begin
    FEditorActives[Idx] := not FEditorActives[Idx];

    // ʵʱ�������Ա༭��ʵ��״̬
    CnDesignEditorMgr.PropEditors[Idx].Active := FEditorActives[Idx];
    cbDesignEditorActive.Checked := FEditorActives[Idx];
    btnDesignEditorConfig.Enabled := cbDesignEditorActive.Checked;
    lbDesignEditors.Refresh;
  end
  else
    btnDesignEditorConfig.Enabled := False;
end;

// ����ר��
procedure TCnWizConfigForm.btnConfigClick(Sender: TObject);
begin
  if lbWizards.ItemIndex >= 0 then
  begin
    with TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]) do
      if HasConfig then Config;
    lbWizards.Refresh;
  end;
end;

// �ָ�Ĭ������
procedure TCnWizConfigForm.btnRestoreSettingClick(Sender: TObject);
var
  Wizard: TCnBaseWizard;
  Idx: Integer;
begin
  if lbWizards.ItemIndex >= 0 then
  begin
    Wizard := TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]);
    if QueryDlg(Format(SCnConfirmResetSetting, [Wizard.WizardName])) then
    begin
      Wizard.DoResetSettings; // ���� HasConfig �� True ���� False ��Ӧ������

      if Wizard is TCnActionWizard then
      begin
        TCnActionWizard(Wizard).Action.ShortCut := TCnActionWizardHack(Wizard).GetDefShortCut;
        Idx := CalcSelectedWizardIndex(Wizard);
        if Idx >= 0 then
          FShortCuts[Idx] := TCnActionWizard(Wizard).Action.ShortCut;
      end;
      lbWizards.Refresh;
      lbWizards.OnClick(lbWizards); // Refresh hotkey display.

      InfoDlg(Format(SCnSettingsReset, [Wizard.WizardName]));
    end;
  end;
end;

//------------------------------------------------------------------------------
// �༭������
//------------------------------------------------------------------------------

procedure TCnWizConfigForm.lbDesignEditorsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Canvas: TCanvas;
  R: TRect;
  ARect: TRect;
  Info: TCnDesignEditorInfo;
  Idx, X, Y: Integer;
  Bmp: TBitmap;
  EnableIndex, EnableIconMargin: Integer;
begin
  if not (Control is TListBox) then Exit;
  ListBox := TListBox(Control);
  Info := TCnDesignEditorInfo(ListBox.Items.Objects[Index]);
  Idx := CalcSelectedEditorIndex(Info);

  // ������ʱλͼ��������˸
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.Width := RectWidth(Rect);
    Bmp.Height := RectHeight(Rect);
    ARect := Bounds(0, 0, Bmp.Width, Bmp.Height);

    R.Left := ARect.Left + 4;
    R.Right := ARect.Right - 5;
    R.Top := ARect.Top + 2;
    R.Bottom := ARect.Bottom - 2;

    Canvas := Bmp.Canvas;
    Canvas.Font.Assign(ListBox.Font);
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := ListBox.Color;
    Canvas.FillRect(ARect);
    Canvas.Brush.Color := csShadowColor;
    Canvas.RoundRect(R.Left + 1, R.Top + 1, R.Right + 1, R.Bottom + 1, 8, 8);

    if odSelected in State then
    begin
      Canvas.Brush.Color := csSelectedColor;
      Canvas.Font.Color := clBlue;
    end
    else if FEditorActives[Idx] then
    begin
      Canvas.Brush.Color := csNormalColor;
      Canvas.Font.Color := clBlack;
    end
    else
    begin
      Canvas.Brush.Color := csNormalColor;
      Canvas.Font.Color := clGray;
    end;

    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
    X := R.Left + 5;
    Y := R.Top + 2;
    Canvas.TextOut(X, Y, SCnDesignEditorNameStr + Info.Name);
    Inc(Y, FDrawTextHeight + 2);

    if FEditorActives[Idx] then
      Canvas.TextOut(X, Y, SCnDesignEditorStateStr + SCnWizardActiveStr)
    else
      Canvas.TextOut(X, Y, SCnDesignEditorStateStr + SCnWizardDisActiveStr);

    BitBlt(ListBox.Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height,
      Canvas.Handle, 0, 0, SRCCOPY);

    // ������ͼ��
    if FEditorActives[Idx] then
      EnableIndex := 0
    else
      EnableIndex := 1;

    EnableIconMargin := (Rect.Bottom - Rect.Top - ilEnable.Height) div 2;
    if EnableIconMargin < 0 then
      EnableIconMargin := 0;
    ilEnable.Draw(ListBox.Canvas, Rect.Right - EnableIconMargin - ilEnable.Width - 8,
      Rect.Top + EnableIconMargin + 1, EnableIndex);
  finally
    Bmp.Free;
  end;
end;

procedure TCnWizConfigForm.lbDesignEditorsClick(Sender: TObject);
var
  EditorInfo: TCnDesignEditorInfo;
  Idx: Integer;
begin
  if (lbDesignEditors.Items.Count = 0) or (lbDesignEditors.ItemIndex < 0) then
  begin
    lblDesignEditorName.Caption := '';
    lblDesignEditorAuthor.Caption := '';
    lblDesignEditorComment.Caption := '';
    lblDesignEditorKind.Caption := '';
    btnDesignEditorConfig.Enabled := False;
    btnDesignEditorCustomize.Enabled := False;
    
    Exit;
  end;

  EditorInfo := TCnDesignEditorInfo(lbDesignEditors.Items.Objects[lbDesignEditors.ItemIndex]);
  Idx := CalcSelectedEditorIndex(EditorInfo);
  with EditorInfo do
  begin
    lblDesignEditorName.Caption := Name;
    lblDesignEditorAuthor.Caption := CnAuthorEmailToStr(Author, '');
    lblDesignEditorComment.Caption := Comment;
    if EditorInfo is TCnPropEditorInfo then
      lblDesignEditorKind.Caption := SCnPropertyEditor
    else if EditorInfo is TCnCompEditorInfo then
      lblDesignEditorKind.Caption := SCnComponentEditor
    else // ��������
      lblDesignEditorKind.Caption := '';
    cbDesignEditorActive.Checked := FEditorActives[Idx];
    btnDesignEditorConfig.Visible := HasConfig;
    btnDesignEditorConfig.Enabled := cbDesignEditorActive.Checked;
    btnDesignEditorCustomize.Visible := HasCustomize;
    btnDesignEditorCustomize.Enabled := cbDesignEditorActive.Checked;
  end;
end;

procedure TCnWizConfigForm.lbDesignEditorsDblClick(Sender: TObject);
begin
  if btnDesignEditorConfig.Visible and btnDesignEditorConfig.Enabled then
    btnDesignEditorConfigClick(btnDesignEditorConfig);
end;

procedure TCnWizConfigForm.cbDesignEditorActiveClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CalcSelectedEditorIndex();
  if Idx >= 0 then
  begin
    FEditorActives[Idx] := cbDesignEditorActive.Checked;
    btnDesignEditorConfig.Enabled := cbDesignEditorActive.Checked;
    lbDesignEditors.Refresh;
  end
  else
    btnDesignEditorConfig.Enabled := False;
end;

procedure TCnWizConfigForm.btnDesignEditorConfigClick(Sender: TObject);
begin
  if lbDesignEditors.ItemIndex >= 0 then
  begin
    with TCnDesignEditorInfo(lbDesignEditors.Items.Objects[lbDesignEditors.ItemIndex]) do
      if HasConfig then Config;
    lbDesignEditors.Refresh;
  end;
end;

procedure TCnWizConfigForm.btnDesignEditorCustomizeClick(Sender: TObject);
begin
  if lbDesignEditors.ItemIndex >= 0 then
  begin
    with TCnDesignEditorInfo(lbDesignEditors.Items.Objects[lbDesignEditors.ItemIndex]) do
      if HasCustomize then Customize;
  end;
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

// �������
procedure TCnWizConfigForm.btnCheckUpgradeClick(Sender: TObject);
begin
  CheckUpgrade(True);
end;

procedure TCnWizConfigForm.btnResetWizCommentClick(Sender: TObject);
begin
  ResetAllComment(True);
  InfoDlg(SCnWizCommentReseted);
end;

procedure TCnWizConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizConfigForm.GetHelpTopic: string;
begin
  case PageControl.ActivePageIndex of
    1: Result := 'CnWizPropConfig';
    2: Result := 'CnWizOtherConfig';
    3: Result := 'CnWizIdeConfig';
  else
    Result := 'CnWizConfig';
  end;
end;

procedure TCnWizConfigForm.cbShowHintClick(Sender: TObject);
begin
  ShowHint := cbShowHint.Checked;
end;

procedure TCnWizConfigForm.UpdateControls(Sender: TObject);
begin
  cbUpgradeReleaseOnly.Enabled := rbUpgradeAll.Checked;
  edtUserDir.Enabled := chkUserDir.Checked;
  btnUserDir.Enabled := chkUserDir.Checked;
  cbbEnlarge.Enabled := chkEnlarge.Checked;
end;

procedure TCnWizConfigForm.btnExportImagelistClick(Sender: TObject);
var
  Dir: string;
begin
  if GetDirectory(SCnSelectDir, Dir) then
    SaveIDEImageListToPath(GetIDEImageList, MakePath(Dir));
end;

procedure TCnWizConfigForm.btnExportActionListClick(Sender: TObject);
begin
  if dlgSaveActionList.Execute then
    SaveIDEActionListToFile(dlgSaveActionList.FileName);
end;

procedure TCnWizConfigForm.btnExportComponentsClick(Sender: TObject);
{$IFNDEF STAND_ALONE}
const
  SCnPackageFileName = 'Packages.txt';
  SCnComponentFileName = 'Components.txt';
var
  P, C: TStringList;
  Dir: string;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  P := nil;
  C := nil;
  try
    P := TStringList.Create;
    C := TStringList.Create;
    GetInstalledComponents(P, C);
    if GetDirectory(SCnExportPCDirCaption, Dir) then
    begin
      P.SaveToFile(MakePath(Dir) + SCnPackageFileName);
      C.SaveToFile(MakePath(Dir) + SCnComponentFileName);
      InfoDlg(Format(SCnExportPCSucc, [SCnComponentFileName, SCnPackageFileName]));
    end;
  finally
    P.Free;
    C.Free;
  end;
{$ENDIF}
end;

procedure TCnWizConfigForm.btnSortClick(Sender: TObject);
begin
  // ��ʾ���򴰿�
  with TCnMenuSortForm.Create(nil) do
  begin
    InitWizardMenus;
    if ShowModal = mrOK then
    begin
      ReSortMenuWizards;
      CnWizardMgr.ConstructSortedMenu;
      SaveWizardCreateInfo;
    end;
    Free;
  end;
end;

procedure TCnWizConfigForm.btnUserDirClick(Sender: TObject);
var
  ADir: string;
begin
  ADir := edtUserDir.Text;
  if GetDirectory('', ADir) then
    edtUserDir.Text := ADir;
end;

procedure TCnWizConfigForm.edtSearchWizardChange(Sender: TObject);
var
  I: Integer;
  Py: string;

  function CanShowWizard(FilterText: string; Wizard: TCnBaseWizard): Boolean;
  begin
    if FilterText = '' then
    begin
      Result := True;
      Exit;
    end;
    FilterText := LowerCase(FilterText);

    if (Pos(FilterText, LowerCase(Wizard.WizardName)) > 0)
      or (Pos(FilterText, LowerCase(Wizard.GetIDStr)) > 0)
      or (Pos(FilterText, LowerCase(Wizard.GetAuthor)) > 0)
      or (Pos(FilterText, LowerCase(Wizard.GetSearchContent)) > 0) then
      Result := True
    else // ����ƴ������ĸ
    begin
      Py := LowerCase(string(GetHzPy(AnsiString(Wizard.WizardName))));
      Result := Pos(FilterText, Py) > 0;
    end;
  end;

begin
  lbWizards.Items.Clear;
  for I := 0 to CnWizardMgr.WizardCount - 1 do
  begin
    if CanShowWizard(edtSearchWizard.Text, CnWizardMgr[I]) then
      lbWizards.Items.AddObject(CnWizardMgr[I].WizardName, CnWizardMgr[I]);
  end;
  if lbWizards.Items.Count > 0 then
    lbWizards.ItemIndex := 0;

  lbWizardsClick(lbWizards);
end;

procedure TCnWizConfigForm.edtSearchEditorChange(Sender: TObject);
var
  I: Integer;
  Py: string;

  function CanShowEditor(FilterText: string; Editor: TCnPropEditorInfo): Boolean; overload;
  begin
    if FilterText = '' then
    begin
      Result := True;
      Exit;
    end;
    FilterText := LowerCase(FilterText);

    if (Pos(FilterText, Editor.Name) > 0)
      or (Pos(FilterText, Editor.Author) > 0) then
      Result := True
    else // ����ƴ������ĸ
    begin
      Py := LowerCase(string(GetHzPy(AnsiString(Editor.Name))));
      Result := Pos(FilterText, Py) > 0;
    end;
  end;

  function CanShowEditor(FilterText: string; Editor: TCnCompEditorInfo): Boolean; overload;
  begin
    if FilterText = '' then
    begin
      Result := True;
      Exit;
    end;
    FilterText := LowerCase(FilterText);

    if (Pos(FilterText, LowerCase(Editor.Name)) > 0)
      or (Pos(FilterText, LowerCase(Editor.Author)) > 0) then
      Result := True
    else // ����ƴ������ĸ
    begin
      Py := LowerCase(string(GetHzPy(AnsiString(Editor.Name))));
      Result := Pos(FilterText, Py) > 0;
    end;
  end;

begin
  lbDesignEditors.Items.Clear;
  for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
  begin
    if CanShowEditor(edtSearchEditor.Text, CnDesignEditorMgr.PropEditors[I]) then
      lbDesignEditors.Items.AddObject(CnDesignEditorMgr.PropEditors[I].Name,
        CnDesignEditorMgr.PropEditors[I]);
  end;

  for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
  begin
    if CanShowEditor(edtSearchEditor.Text, CnDesignEditorMgr.CompEditors[I]) then
      lbDesignEditors.Items.AddObject(CnDesignEditorMgr.CompEditors[I].Name,
        CnDesignEditorMgr.CompEditors[I]);
  end;

  if lbDesignEditors.Items.Count > 0 then
    lbDesignEditors.ItemIndex := 0;
  lbDesignEditorsClick(lbDesignEditors);
end;

function TCnWizConfigForm.CalcSelectedWizardIndex(Wizard: TCnBaseWizard): Integer;
begin
  Result := -1;
  if Wizard = nil then
    if lbWizards.ItemIndex >= 0 then
      Wizard := TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]);

  if Wizard <> nil then
    Result := CnWizardMgr.IndexOf(Wizard);
end;

function TCnWizConfigForm.CalcSelectedEditorIndex(Editor: TCnDesignEditorInfo): Integer;
begin
  Result := -1;
  if Editor = nil then
    if lbDesignEditors.ItemIndex >= 0 then
      Editor := TCnDesignEditorInfo(lbDesignEditors.Items.Objects[lbDesignEditors.ItemIndex]);

  if Editor <> nil then
  begin
    if Editor is TCnPropEditorInfo then
      Result := CnDesignEditorMgr.IndexOfPropEditor(Editor as TCnPropEditorInfo)
    else if Editor is TCnCompEditorInfo then
      Result := CnDesignEditorMgr.PropEditorCount +
        CnDesignEditorMgr.IndexOfCompEditor(Editor as TCnCompEditorInfo);
  end;
end;

procedure TCnWizConfigForm.PageControlChange(Sender: TObject);
begin
  btnSort.Visible := (PageControl.ActivePageIndex = 0);
end;

procedure TCnWizConfigForm.lbWizardsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = ' ' then
    ToggleWizardActive;
end;

procedure TCnWizConfigForm.lbDesignEditorsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = ' ' then
    TogglePropertyEditorActive;
end;

end.


