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

unit CnWizConfigFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家设置窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2012.11.30 V1.7
*               去除使用FormScaler重新调整文字的机制
*           2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2012.06.21 V1.5
*               加入搜索框，允许按首字母搜索专家与属性组件编辑器
*           2004.11.18 V1.4
*               修正listbox自画不适合120DPI的小问题 (shenloqi)
*           2003.06.25 V1.3
*               移除 IDE 扩展设置界面 (LiuXiao)
*           2003.05.01 V1.2
*               新增 IDE 扩展设置
*           2003.03.20 V1.1
*               增加属性编辑器设置
*           2002.10.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, ToolWin, StdCtrls, CnDesignEditor, CnWizMultiLang,
  CnWizClasses, CnDesignEditorConsts, ImgList, Buttons;

type

//==============================================================================
// 专家设置窗体
//==============================================================================

{ TCnWizConfigForm }

  TCnWizConfigForm = class(TCnTranslateForm)
    PageControl: TPageControl;
    pnlButton: TPanel;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
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
    btnSort: TButton;
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
    lblSearchWizard: TLabel;
    edtSearchWizard: TEdit;
    pnlEditors: TPanel;
    lbDesignEditors: TListBox;
    edtSearchEditor: TEdit;
    lblSearchEditor: TLabel;
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
  private
    { Private declarations }
    FShortCuts: array of TShortCut;
    FActives: array of Boolean;
    FEditorActives: array of Boolean;
    FDrawTextHeight: Integer;
    function CalcSelectedWizardIndex(Wizard: TCnBaseWizard = nil): Integer;
    function CalcSelectedEditorIndex(Editor: TCnDesignEditorInfo = nil): Integer;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

// 显示配置窗口
procedure ShowCnWizConfigForm(AIcon: TIcon = nil);

implementation

uses
  CnWizManager, CnCommon, CnWizConsts, CnWizShortCut, CnWizOptions,
  CnWizCommentFrm, CnWizUtils, CnWizUpgradeFrm, CnWizIdeUtils, CnWizMenuSortFrm;

const
  csSelectedColor = $FFB0B0;
  csNormalColor = $FFF4F4;
  csShadowColor = $444444;

  csLastSelectedItem = 'LastSelectedItem';

{$R *.DFM}

// 显示配置窗口
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
// 专家设置窗体
//==============================================================================

{ TCnWizConfigForm }

// 窗体初始化
procedure TCnWizConfigForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  // 专家设置页面
  SetLength(FShortCuts, CnWizardMgr.WizardCount);
  SetLength(FActives, CnWizardMgr.WizardCount);
  for i := 0 to CnWizardMgr.WizardCount - 1 do
  begin
    FActives[i] := CnWizardMgr[i].Active;
    if CnWizardMgr[i] is TCnActionWizard then
      FShortCuts[i] := TCnActionWizard(CnWizardMgr[i]).Action.ShortCut
    else
      FShortCuts[i] := 0;
    lbWizards.Items.AddObject(CnWizardMgr[i].WizardName, CnWizardMgr[i]);
  end;
  lbWizards.ItemIndex := WizOptions.ReadInteger(SCnOptionSection, csLastSelectedItem, 0);
  lbWizardsClick(lbWizards);
  ActiveControl := lbWizards;

  // 属性编辑器页面
  SetLength(FEditorActives, CnDesignEditorMgr.PropEditorCount +
    CnDesignEditorMgr.CompEditorCount);
  for i := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
  begin
    FEditorActives[i] := CnDesignEditorMgr.PropEditors[i].Active;
    lbDesignEditors.Items.AddObject(CnDesignEditorMgr.PropEditors[i].Name,
      CnDesignEditorMgr.PropEditors[i]);
  end;

  for i := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
  begin
    FEditorActives[CnDesignEditorMgr.PropEditorCount + i] :=
      CnDesignEditorMgr.CompEditors[i].Active;
    lbDesignEditors.Items.AddObject(CnDesignEditorMgr.CompEditors[i].Name, CnDesignEditorMgr.CompEditors[i]);
  end;
  lbDesignEditors.ItemIndex := 0;
  lbDesignEditorsClick(lbDesignEditors);

  // 环境设置页面
  chkUseToolsMenu.Checked := WizOptions.UseToolsMenu;
  cbShowHint.Checked := WizOptions.ShowHint;
  cbShowWizComment.Checked := WizOptions.ShowWizComment;
  chkUseOneCPUCore.Checked := WizOptions.UseOneCPUCore;
  chkFixThreadLocale.Checked := WizOptions.FixThreadLocale;

  // 升级设置
  if WizOptions.UpgradeStyle = usDisabled then
    rbUpgradeDisabled.Checked := True
  else
    rbUpgradeAll.Checked := True;
  cbUpgradeReleaseOnly.Checked := WizOptions.UpgradeReleaseOnly;

  //自画高度调整
  FDrawTextHeight := 12;
//  if Scaled then
//  begin
//    FDrawTextHeight := FScaler.MultiPPI(FDrawTextHeight, Self);
//    lbWizards.ItemHeight := FScaler.MultiPPI(lbWizards.ItemHeight, Self);
//    lbDesignEditors.ItemHeight := FScaler.MultiPPI(lbDesignEditors.ItemHeight, Self);
//  end;

  chkUserDir.Checked := WizOptions.UseCustomUserDir;
  edtUserDir.Text := WizOptions.CustomUserDir;

  UpdateControls(nil);

  PageControl.ActivePageIndex := 0;
end;

// 窗体释放
procedure TCnWizConfigForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  if ModalResult = mrOK then
  begin
    // 专家设置页面
    WizShortCutMgr.BeginUpdate;
    try
      for i := 0 to CnWizardMgr.WizardCount - 1 do
      begin
        CnWizardMgr[i].Active := FActives[i];
        if CnWizardMgr[i] is TCnActionWizard then
          TCnActionWizard(CnWizardMgr[i]).Action.ShortCut := FShortCuts[i];
      end;
    finally
      WizShortCutMgr.EndUpdate;
    end;

    // 属性编辑器页面
    for i := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
      CnDesignEditorMgr.PropEditors[i].Active := FEditorActives[i];

    for i := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
      CnDesignEditorMgr.CompEditors[i].Active :=
        FEditorActives[CnDesignEditorMgr.PropEditorCount + i];

    CnDesignEditorMgr.UnRegister;
    CnDesignEditorMgr.Register;

    // 环境设置页面
    WizOptions.UseToolsMenu := chkUseToolsMenu.Checked;
    WizOptions.ShowHint := cbShowHint.Checked;
    WizOptions.ShowWizComment := cbShowWizComment.Checked;
    WizOptions.UseOneCPUCore := chkUseOneCPUCore.Checked;
    WizOptions.FixThreadLocale := chkFixThreadLocale.Checked;

    // 升级设置
    if rbUpgradeDisabled.Checked then
      WizOptions.UpgradeStyle := usDisabled
    else
      WizOptions.UpgradeStyle := usAllUpgrade;
    WizOptions.UpgradeReleaseOnly := cbUpgradeReleaseOnly.Checked;

    WizOptions.UseCustomUserDir := chkUserDir.Checked;
    WizOptions.CustomUserDir := edtUserDir.Text;
    
    WizOptions.WriteInteger(SCnOptionSection, csLastSelectedItem, lbWizards.ItemIndex);

    WizOptions.SaveSettings;
    CnWizardMgr.SaveSettings;
  end;
  FShortCuts := nil;
  FActives := nil;
  FEditorActives := nil;
end;

// 窗体大小变更时刷新列表框显示
procedure TCnWizConfigForm.FormResize(Sender: TObject);
begin
  lbWizards.Refresh;                    // 修正列表框刷新不完整的问题
  lbDesignEditors.Refresh;
end;

//------------------------------------------------------------------------------
// 专家设置处理
//------------------------------------------------------------------------------

// 绘制 ListBox 条目
procedure TCnWizConfigForm.lbWizardsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Canvas: TCanvas;
  ARect: TRect;
  R: TRect;
  Wizard: TCnBaseWizard;
  Idx, x, y: Integer;
  Bmp: TBitmap;
  EnableIndex, EnableIconMargin: Integer;
begin
  if not (Control is TListBox) then Exit;
  ListBox := TListBox(Control);
  Wizard := TCnBaseWizard(ListBox.Items.Objects[Index]);
  Idx := CalcSelectedWizardIndex(Wizard);

  // 创建临时位图以消除闪烁
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
    if Wizard.Icon <> nil then
      Canvas.Draw(R.Left + 4, R.Top + (R.Bottom - R.Top - Wizard.Icon.Height) div 2, Wizard.Icon);

    x := R.Left + 42;
    y := R.Top + 2;
    Canvas.TextOut(x, y, SCnWizardNameStr + Wizard.WizardName);
    Inc(y, FDrawTextHeight);
    if FActives[Idx] then
      Canvas.TextOut(x, y, SCnWizardStateStr + SCnWizardActiveStr)
    else
      Canvas.TextOut(x, y, SCnWizardStateStr + SCnWizardDisActiveStr);
    Inc(y, FDrawTextHeight);
    Canvas.TextOut(x, y, SCnWizardShortCutStr + ShortCutToText(FShortCuts[Idx]));

    BitBlt(ListBox.Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height,
      Canvas.Handle, 0, 0, SRCCOPY);

    // 画勾叉图标
    if FActives[Idx] then
      EnableIndex := 0
    else
      EnableIndex := 1;

    EnableIconMargin := (Rect.Bottom - Rect.Top - ilEnable.Height) div 2;
    if EnableIconMargin < 0 then
      EnableIconMargin := 0;
    ilEnable.Draw(ListBox.Canvas, Rect.Right - EnableIconMargin - ilEnable.Width - 6,
      Rect.Top + EnableIconMargin + 1, EnableIndex);
  finally
    Bmp.Free;
  end;
end;

// ListBox 点击事件
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

  imgIcon.Picture.Graphic := Wizard.Icon;
  Wizard.GetWizardInfo(AName, Author, Email, Comment);
  lblWizardName.Caption := AName;
  lblWizardAuthor.Caption := CnAuthorEmailToStr(Author, '');
  lblWizardComment.Caption := Comment;
  lblWizardKind.Caption := GetCnWizardTypeName(Wizard);

  cbWizardActive.Checked := FActives[Idx];
  HotKeyWizard.HotKey := FShortCuts[Idx];
  HotKeyWizard.Visible := (Wizard is TCnActionWizard) and
    TCnActionWizard(Wizard).EnableShortCut;
  btnConfig.Enabled := Wizard.HasConfig and cbWizardActive.Checked;
end;

// ListBox 双击事件
procedure TCnWizConfigForm.lbWizardsDblClick(Sender: TObject);
begin
  if btnConfig.Visible and btnConfig.Enabled then
    btnConfigClick(btnConfig);
end;

// 处理热键
procedure TCnWizConfigForm.HotKeyWizardExit(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CalcSelectedWizardIndex();
  if Idx >= 0 then
    FShortCuts[Idx] := HotKeyWizard.HotKey;
end;

// 设置专家活跃
procedure TCnWizConfigForm.cbWizardActiveClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CalcSelectedWizardIndex();
  if Idx >= 0 then
  begin
    FActives[Idx] := cbWizardActive.Checked;
    btnConfig.Enabled := cbWizardActive.Checked and
      TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]).HasConfig;
    lbWizards.Refresh;
  end
  else
    btnConfig.Enabled := False;
end;

// 设置专家
procedure TCnWizConfigForm.btnConfigClick(Sender: TObject);
begin
  if lbWizards.ItemIndex >= 0 then
  begin
    with TCnBaseWizard(lbWizards.Items.Objects[lbWizards.ItemIndex]) do
      if HasConfig then Config;
    lbWizards.Refresh;
  end;
end;

//------------------------------------------------------------------------------
// 编辑器设置
//------------------------------------------------------------------------------

procedure TCnWizConfigForm.lbDesignEditorsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Canvas: TCanvas;
  R: TRect;
  ARect: TRect;
  Info: TCnDesignEditorInfo;
  Idx, x, y: Integer;
  Bmp: TBitmap;
  EnableIndex, EnableIconMargin: Integer;
begin
  if not (Control is TListBox) then Exit;
  ListBox := TListBox(Control);
  Info := TCnDesignEditorInfo(ListBox.Items.Objects[Index]);
  Idx := CalcSelectedEditorIndex(Info);

  // 创建临时位图以消除闪烁
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
    x := R.Left + 5;
    y := R.Top + 2;
    Canvas.TextOut(x, y, SCnDesignEditorNameStr + Info.Name);
    Inc(y, FDrawTextHeight);

    if FEditorActives[Idx] then
      Canvas.TextOut(x, y, SCnDesignEditorStateStr + SCnWizardActiveStr)
    else
      Canvas.TextOut(x, y, SCnDesignEditorStateStr + SCnWizardDisActiveStr);

    BitBlt(ListBox.Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height,
      Canvas.Handle, 0, 0, SRCCOPY);

    // 画勾叉图标
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
    else // 其它类型
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
// 其它设置
//------------------------------------------------------------------------------

// 检查升级
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
end;

procedure TCnWizConfigForm.btnExportImagelistClick(Sender: TObject);
var
  Dir: string;
begin
  if GetDirectory(SCnSelectDir, Dir) then
    SaveIDEImageListToPath(MakePath(Dir));
end;

procedure TCnWizConfigForm.btnExportActionListClick(Sender: TObject);
begin
  if dlgSaveActionList.Execute then
    SaveIDEActionListToFile(dlgSaveActionList.FileName);
end;

procedure TCnWizConfigForm.btnExportComponentsClick(Sender: TObject);
const
  SCnPackageFileName = 'Packages.txt';
  SCnComponentFileName = 'Components.txt';
var
  p, c: TStringList;
  Dir: String;
begin
  p := nil; c := nil;
  try
    p := TStringList.Create;
    c := TStringList.Create;
    GetInstalledComponents(p, c);
    if GetDirectory(SCnExportPCDirCaption, Dir) then
    begin
      p.SaveToFile(MakePath(Dir) + SCnPackageFileName);
      c.SaveToFile(MakePath(Dir) + SCnComponentFileName);
      InfoDlg(Format(SCnExportPCSucc, [SCnComponentFileName, SCnPackageFileName]));
    end;
  finally
    p.Free;
    c.Free;
  end;
end;

procedure TCnWizConfigForm.btnSortClick(Sender: TObject);
begin
// 显示排序窗口
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

    if (Pos(FilterText, Wizard.WizardName) > 0)
      or (Pos(FilterText, Wizard.GetIDStr) > 0)
      or (Pos(FilterText, Wizard.GetAuthor) > 0) then
      Result := True
    else // 查找拼音首字母
    begin
{$IFDEF DelphiXE3_UP}
      Py := LowerCase(String(GetHzPy(AnsiString(Wizard.WizardName))));
{$ELSE}
      Py := LowerCase(GetHzPy(Wizard.WizardName));
{$ENDIF DelphiXE3_UP}
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
    else // 查找拼音首字母
    begin
{$IFDEF DelphiXE3_UP}
      Py := LowerCase(String(GetHzPy(AnsiString(Editor.Name))));
{$ELSE}
      Py := LowerCase(GetHzPy(Editor.Name));
{$ENDIF DelphiXE3_UP}
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

    if (Pos(FilterText, Editor.Name) > 0)
      or (Pos(FilterText, Editor.Author) > 0) then
      Result := True
    else // 查找拼音首字母
    begin
{$IFDEF DelphiXE3_UP}
      Py := LowerCase(String(GetHzPy(AnsiString(Editor.Name))));
{$ELSE}
      Py := LowerCase(GetHzPy(Editor.Name));
{$ENDIF DelphiXE3_UP}
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

end.


