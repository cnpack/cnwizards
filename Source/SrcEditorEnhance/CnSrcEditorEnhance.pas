{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnSrcEditorEnhance;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展设置单元
* 单元作者：刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin98SE + Delphi 6
* 兼容测试：暂无（PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.05.30 V1.3
*               LiuXiao 修改通知器以修改工具栏的更新方式，降低 CPU 占有率
*           2007.05.02 V1.2
*               LiuXiao 加入编辑器右键菜单中插入浮动下拉按钮的功能
*           2004.06.12 V1.1
*               LiuXiao 加入打开文件时自动只读保护的功能
*           2003.06.24 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  IniFiles, Menus, CnCommon, CnWizUtils, CnConsts, CnWizClasses, CnWizConsts,
  CnWizManager, ComCtrls, ActnList, CnSpin, StdCtrls, ExtCtrls, CnWizMultiLang,
  Forms, CnSrcEditorMisc, CnSrcEditorGutter, CnSrcEditorToolBar, CnSrcEditorNav,
  CnSrcEditorBlockTools, CnSrcEditorKey, CnEditControlWrapper, CnWizNotifier;

type

{ TCnSrcEditorEnhanceForm }

  TCnSrcEditorEnhanceForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    ActionList: TActionList;
    actReplace: TAction;
    actAdd: TAction;
    actDelete: TAction;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    grpEditorEnh: TGroupBox;
    chkAddMenuCloseOtherPages: TCheckBox;
    chkAddMenuSelAll: TCheckBox;
    chkAddMenuExplore: TCheckBox;
    chkCodeCompletion: TCheckBox;
    hkCodeCompletion: THotKey;
    grpAutoReadOnly: TGroupBox;
    lblDir: TLabel;
    chkAutoReadOnly: TCheckBox;
    lbReadOnlyDirs: TListBox;
    edtDir: TEdit;
    btnSelectDir: TButton;
    btnReplace: TButton;
    btnAdd: TButton;
    btnDel: TButton;
    grpLineNumber: TGroupBox;
    chkShowLineNumber: TCheckBox;
    grpToolBar: TGroupBox;
    chkShowToolBar: TCheckBox;
    btnToolBar: TButton;
    chkToolBarWrap: TCheckBox;
    rbLinePanelAutoWidth: TRadioButton;
    rbLinePanelFixedWidth: TRadioButton;
    lbl1: TLabel;
    seLinePanelFixWidth: TCnSpinEdit;
    chkShowLineCount: TCheckBox;
    lbl2: TLabel;
    seLinePanelMinWidth: TCnSpinEdit;
    dlgFontCurrLine: TFontDialog;
    dlgFontLine: TFontDialog;
    btnLineFont: TButton;
    btnCurrLineFont: TButton;
    grpEditorNav: TGroupBox;
    chkExtendForwardBack: TCheckBox;
    Label1: TLabel;
    seNavMinLineDiff: TCnSpinEdit;
    Label2: TLabel;
    seNavMaxItems: TCnSpinEdit;
    ts3: TTabSheet;
    gbTab: TGroupBox;
    chkDispModifiedInTab: TCheckBox;
    gbFlatButton: TGroupBox;
    chkShowFlatButton: TCheckBox;
    chkDblClkClosePage: TCheckBox;
    chkRClickShellMenu: TCheckBox;
    chkAddMenuShellMenu: TCheckBox;
    ts4: TTabSheet;
    grpKeyExtend: TGroupBox;
    chkShiftEnter: TCheckBox;
    chkHomeExtend: TCheckBox;
    chkHomeFirstChar: TCheckBox;
    grpAutoIndent: TGroupBox;
    chkAutoIndent: TCheckBox;
    mmoAutoIndent: TMemo;
    lbl3: TLabel;
    chkSearchAgain: TCheckBox;
    chkTabIndent: TCheckBox;
    chkShowInDesign: TCheckBox;
    chkAddMenuBlockTools: TCheckBox;
    chkAddMenuCopyFileName: TCheckBox;
    grpAutoSave: TGroupBox;
    chkAutoSave: TCheckBox;
    seSaveInterval: TCnSpinEdit;
    lblSaveInterval: TLabel;
    lblMinutes: TLabel;
    chkEditorMultiLine: TCheckBox;
    chkEditorFlatButtons: TCheckBox;
    grpSmart: TGroupBox;
    chkSmartCopy: TCheckBox;
    chkSmartPaste: TCheckBox;
    chkAutoBracket: TCheckBox;
    chkKeepSearch: TCheckBox;
    lbl4: TLabel;
    edtExploreCmdLine: TEdit;
    chkF2Rename: TCheckBox;
    hkRename: THotKey;
    chkSemicolon: TCheckBox;
    chkAutoEnterEnd: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
    procedure UpdateContent(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure lbReadOnlyDirsClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure btnToolBarClick(Sender: TObject);
    procedure btnLineFontClick(Sender: TObject);
    procedure btnCurrLineFontClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

//==============================================================================
// 代码编辑器扩展类
//==============================================================================

{ TCnSrcEditorEnhance }

  TCnSrcEditorEnhance = class(TCnIDEEnhanceWizard)
  private
    FEditorMisc: TCnSrcEditorMisc;
    FToolbarMgr: TCnSrcEditorToolBarMgr;

    FGutterMgr: TCnSrcEditorGutterMgr;
  {$IFNDEF BDS}
    FNavMgr: TCnSrcEditorNavMgr;
  {$ENDIF}

    FBlockTools: TCnSrcEditorBlockTools;
    FEditorKey: TCnSrcEditorKey;

  {$IFDEF BDS}
    procedure CheckToolBarEnable;
    procedure EditorChanged(Editor: TEditorObject;
      ChangeType: TEditorChangeTypes);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm; 
      Operation: TOperation);
    procedure CheckToolBarEnableOnIdle(Sender: TObject);
  {$ENDIF}
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    procedure OnEnhConfig(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;
    procedure LanguageChanged(Sender: TObject); override;

    property GutterMgr: TCnSrcEditorGutterMgr read FGutterMgr;
  {$IFNDEF BDS}
    property NavMgr: TCnSrcEditorNavMgr read FNavMgr;
  {$ENDIF}
  
    property ToolBarMgr: TCnSrcEditorToolBarMgr read FToolbarMgr;
    property EditorMisc: TCnSrcEditorMisc read FEditorMisc;
    property BlockTools: TCnSrcEditorBlockTools read FBlockTools;
    property EditorKey: TCnSrcEditorKey read FEditorKey;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$R *.DFM}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizOptions, CnWizIdeUtils;

{ TCnSrcEditorEnhanceForm }

procedure TCnSrcEditorEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcEditorEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnSrcEditorEnhance';
end;

procedure TCnSrcEditorEnhanceForm.UpdateContent(Sender: TObject);
begin
  edtExploreCmdLine.Enabled := chkAddMenuExplore.Checked;
  hkCodeCompletion.Enabled := chkCodeCompletion.Checked;
  lbReadOnlyDirs.Enabled := chkAutoReadOnly.Checked;
  lblDir.Enabled := chkAutoReadOnly.Checked;
  edtDir.Enabled := chkAutoReadOnly.Checked;
  btnSelectDir.Enabled := chkAutoReadOnly.Checked;

  chkToolBarWrap.Enabled := chkShowToolBar.Checked;
  btnToolBar.Enabled := chkShowToolBar.Checked;
{$IFDEF BDS}
  chkShowInDesign.Enabled := chkShowToolBar.Checked;
  chkEditorMultiLine.Enabled := False;
  chkEditorFlatButtons.Enabled := False;  
{$ELSE}
  chkShowInDesign.Enabled := False;
{$ENDIF}

  chkShowLineCount.Enabled := chkShowLineNumber.Checked;
  rbLinePanelAutoWidth.Enabled := chkShowLineNumber.Checked;
  btnLineFont.Enabled := chkShowLineNumber.Checked;
  btnCurrLineFont.Enabled := chkShowLineNumber.Checked;

  seLinePanelMinWidth.Enabled := chkShowLineNumber.Checked and
    rbLinePanelAutoWidth.Checked;
  rbLinePanelFixedWidth.Enabled := chkShowLineNumber.Checked;
  seLinePanelFixWidth.Enabled := chkShowLineNumber.Checked and
    rbLinePanelFixedWidth.Checked;

  lblSaveInterval.Enabled := chkAutoSave.Checked;
  lblMinutes.Enabled := chkAutoSave.Checked;
  seSaveInterval.Enabled := chkAutoSave.Checked;
  
  seNavMinLineDiff.Enabled := chkExtendForwardBack.Checked;
  seNavMaxItems.Enabled := chkExtendForwardBack.Checked;

  chkHomeFirstChar.Enabled := chkHomeExtend.Checked;
  chkKeepSearch.Enabled := chkSearchAgain.Checked;

  mmoAutoIndent.Enabled := chkAutoIndent.Checked;
end;

procedure TCnSrcEditorEnhanceForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ActiveControl <> hkCodeCompletion then
    Exit;

  if (Key = VK_SPACE) and (ssAlt in Shift) then
  begin
    hkCodeCompletion.HotKey := ShortCut(VK_SPACE, [ssAlt]);
    Key := 0;
  end;
end;

procedure TCnSrcEditorEnhanceForm.FormCreate(Sender: TObject);
begin
  pgc1.ActivePageIndex := 0;
end;

procedure TCnSrcEditorEnhanceForm.actReplaceExecute(Sender: TObject);
begin
  if lbReadOnlyDirs.ItemIndex >= 0 then
    lbReadOnlyDirs.Items[lbReadOnlyDirs.ItemIndex] := Trim(edtDir.Text);
end;

procedure TCnSrcEditorEnhanceForm.actAddExecute(Sender: TObject);
begin
  if Trim(edtDir.Text) <> '' then
  begin
    lbReadOnlyDirs.Items.Add(Trim(edtDir.Text));
    lbReadOnlyDirs.ItemIndex := lbReadOnlyDirs.Items.Count - 1;
  end;
end;

procedure TCnSrcEditorEnhanceForm.lbReadOnlyDirsClick(Sender: TObject);
begin
  if lbReadOnlyDirs.ItemIndex >= 0 then
    edtDir.Text := lbReadOnlyDirs.Items[lbReadOnlyDirs.ItemIndex];
end;

procedure TCnSrcEditorEnhanceForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := ReplaceToActualPath(edtDir.Text);
  if GetDirectory(SCnSelectDir, NewDir) then
    edtDir.Text := NewDir;
end;

procedure TCnSrcEditorEnhanceForm.btnToolBarClick(Sender: TObject);
var
  Wizard: TCnSrcEditorEnhance;
begin
  Wizard := CnWizardMgr.WizardByClass(TCnSrcEditorEnhance) as TCnSrcEditorEnhance;
  if Wizard <> nil then
    Wizard.ToolBarMgr.ConfigToolBar;
end;

procedure TCnSrcEditorEnhanceForm.actDeleteExecute(Sender: TObject);
begin
  if lbReadOnlyDirs.ItemIndex >= 0 then
  begin
    lbReadOnlyDirs.Items.Delete(lbReadOnlyDirs.ItemIndex);
    lbReadOnlyDirs.SetFocus;
  end;
end;

procedure TCnSrcEditorEnhanceForm.btnLineFontClick(Sender: TObject);
begin
  dlgFontLine.Execute;
end;

procedure TCnSrcEditorEnhanceForm.btnCurrLineFontClick(Sender: TObject);
begin
  dlgFontCurrLine.Execute;
end;

procedure TCnSrcEditorEnhanceForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if not chkAutoReadOnly.Checked then
  begin
    (Action as TAction).Enabled := False;
    Handled := True;
    Exit;
  end;

  if Action = actReplace then
  begin
    (Action as TAction).Enabled := (lbReadOnlyDirs.ItemIndex >= 0) and
      (edtDir.Text <> lbReadOnlyDirs.Items[lbReadOnlyDirs.ItemIndex]) and (Trim(edtDir.Text) <> '');
  end
  else if Action = actAdd then
  begin
    (Action as TAction).Enabled := (lbReadOnlyDirs.Items.IndexOf(edtDir.Text) < 0)
       and (Trim(edtDir.Text) <> '');
  end
  else if Action = actDelete then
  begin
    (Action as TAction).Enabled := lbReadOnlyDirs.ItemIndex >= 0;
  end;
  Handled := True;
end;

//==============================================================================
// 代码编辑器扩展类
//==============================================================================

{ TCnSrcEditorEnhance }

constructor TCnSrcEditorEnhance.Create;
begin
  inherited;
  FEditorMisc := TCnSrcEditorMisc.Create;
  FToolbarMgr := TCnSrcEditorToolBarMgr.Create;

  if Assigned(CreateEditorToolBarServiceProc) then
    CreateEditorToolBarServiceProc();

  FToolbarMgr.OnEnhConfig := OnEnhConfig;
  FGutterMgr := TCnSrcEditorGutterMgr.Create;
  FGutterMgr.OnEnhConfig := OnEnhConfig;
{$IFNDEF BDS}
  FNavMgr := TCnSrcEditorNavMgr.Create;
  FNavMgr.OnEnhConfig := OnEnhConfig;
{$ENDIF}
  FBlockTools := TCnSrcEditorBlockTools.Create;
  FBlockTools.OnEnhConfig := OnEnhConfig;
  FEditorKey := TCnSrcEditorKey.Create;
  FEditorKey.OnEnhConfig := OnEnhConfig;
{$IFDEF BDS}
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
{$ENDIF}
end;

destructor TCnSrcEditorEnhance.Destroy;
begin
{$IFDEF BDS}
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
{$ENDIF}
  FEditorMisc.Free;
  FToolbarMgr.Free;
  
  CnEditorToolBarService := nil;
  FGutterMgr.Free;
{$IFNDEF BDS}
  FNavMgr.Free;
{$ENDIF}
  FBlockTools.Free;
  FEditorKey.Free;
  inherited;
end;

procedure TCnSrcEditorEnhance.LanguageChanged(Sender: TObject);
begin
  inherited;
  FEditorMisc.LanguageChanged(Sender);
  FToolbarMgr.LanguageChanged(Sender);
  if CnEditorToolBarService <> nil then
    CnEditorToolBarService.LanguageChanged;
  FGutterMgr.LanguageChanged(Sender);
{$IFNDEF BDS}
  FNavMgr.LanguageChanged(Sender);
{$ENDIF}
  FBlockTools.LanguageChanged(Sender);
  FEditorKey.LanguageChanged(Sender);
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

procedure TCnSrcEditorEnhance.LoadSettings(Ini: TCustomIniFile);
begin
  FEditorMisc.LoadSettings(Ini);
  FToolbarMgr.LoadSettings(Ini);
  FGutterMgr.LoadSettings(Ini);
{$IFNDEF BDS}
  FNavMgr.LoadSettings(Ini);
{$ENDIF}
  FBlockTools.LoadSettings(Ini);
  FEditorKey.LoadSettings(Ini);
end;

procedure TCnSrcEditorEnhance.SaveSettings(Ini: TCustomIniFile);
begin
  FEditorMisc.SaveSettings(Ini);
  FToolbarMgr.SaveSettings(Ini);
  FGutterMgr.SaveSettings(Ini);
{$IFNDEF BDS}
  FNavMgr.SaveSettings(Ini);
{$ENDIF}
  FBlockTools.SaveSettings(Ini);
  FEditorKey.SaveSettings(Ini);
end;

procedure TCnSrcEditorEnhance.SetActive(Value: Boolean);
begin
  inherited;
  FEditorMisc.Active := Value;
  FToolbarMgr.Active := Value;
  FGutterMgr.Active := Value;
{$IFNDEF BDS}
  FNavMgr.Active := Value;
{$ENDIF}
  FBlockTools.Active := Value;
  FEditorKey.Active := Value;
end;

function TCnSrcEditorEnhance.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnSrcEditorEnhance.Config;
begin
  with TCnSrcEditorEnhanceForm.Create(nil) do
  try
    chkAddMenuCloseOtherPages.Checked := FEditorMisc.AddMenuCloseOtherPages;
    chkAddMenuSelAll.Checked := FEditorMisc.AddMenuSelAll;
    chkAddMenuExplore.Checked := FEditorMisc.AddMenuExplore;
    chkAddMenuCopyFileName.Checked := FEditorMisc.AddMenuCopyFileName;
    chkAddMenuShellMenu.Checked := FEditorMisc.AddMenuShell;
    edtExploreCmdLine.Text := FEditorMisc.ExploreCmdLine;
    chkCodeCompletion.Checked := FEditorMisc.ChangeCodeComKey;
    hkCodeCompletion.HotKey := FEditorMisc.CodeCompletionKey;

    chkAutoReadOnly.Checked := FEditorMisc.AutoReadOnly;
    lbReadOnlyDirs.Items.Assign(FEditorMisc.ReadOnlyDirs);

    chkDispModifiedInTab.Checked := FEditorMisc.DispModifiedInTab;
  {$IFDEF BDS}
    chkDispModifiedInTab.Enabled := False;
    chkShowInDesign.Checked := FToolbarMgr.ShowInDesign;
  {$ELSE}
    chkShowInDesign.Enabled := False;
  {$ENDIF}

    chkDblClkClosePage.Checked := FEditorMisc.DblClickClosePage;
    chkRClickShellMenu.Checked := FEditorMisc.RClickShellMenu;

    chkShowToolBar.Checked := FToolbarMgr.ShowToolBar;
    chkToolBarWrap.Checked := FToolbarMgr.Wrapable;

    chkShowLineNumber.Checked := FGutterMgr.ShowLineNumber;
    chkShowLineCount.Checked := FGutterMgr.ShowLineCount;
    rbLinePanelAutoWidth.Checked := FGutterMgr.AutoWidth;
    rbLinePanelFixedWidth.Checked := not FGutterMgr.AutoWidth;
    dlgFontLine.Font := FGutterMgr.Font;
    dlgFontCurrLine.Font := FGutterMgr.CurrFont;
    seLinePanelMinWidth.Value := FGutterMgr.MinWidth;
    seLinePanelFixWidth.Value := FGutterMgr.FixedWidth;

    chkEditorMultiLine.Checked := FEditorMisc.EditorTabMultiLine;
    chkEditorFlatButtons.Checked := FEditorMisc.EditorTabFlatButton;  
  {$IFNDEF BDS}
    chkExtendForwardBack.Checked := FNavMgr.ExtendForwardBack;
    seNavMinLineDiff.Value := FNavMgr.MinLineDiff;
    seNavMaxItems.Value := FNavMgr.MaxItems;
  {$ELSE}
    chkExtendForwardBack.Enabled := False;
    seNavMinLineDiff.Enabled := False;
    seNavMaxItems.Enabled := False;
    chkEditorMultiLine.Checked := False;
    chkEditorFlatButtons.Checked := False;
  {$ENDIF}

    chkShowFlatButton.Checked := FBlockTools.ShowBlockTools;
    chkAddMenuBlockTools.Checked := FEditorMisc.AddMenuBlockTools;

    chkAutoSave.Checked := FEditorMisc.AutoSave;
    seSaveInterval.Value := FEditorMisc.SaveInterval;

    chkSmartCopy.Checked := FEditorKey.SmartCopy;
    chkSmartPaste.Checked := FEditorKey.SmartPaste;
    chkTabIndent.Checked := FBlockTools.TabIndent;
    chkAutoBracket.Checked := FEditorKey.AutoBracket;
    chkShiftEnter.Checked := FEditorKey.ShiftEnter;
    chkHomeExtend.Checked := FEditorKey.HomeExt;
    chkSearchAgain.Checked := FEditorKey.F3Search;
    chkF2Rename.Checked := FEditorKey.F2Rename;
    hkRename.HotKey := FEditorKey.RenameShortCut;
    chkSemicolon.Checked := FEditorKey.SemicolonLastChar;
    chkKeepSearch.Checked := FEditorKey.KeepSearch;
    chkHomeFirstChar.Checked := FEditorKey.HomeFirstChar;

  {$IFNDEF DELPHI10_UP}
    chkAutoEnterEnd.Checked := FEditorKey.AutoEnterEnd;
    chkAutoIndent.Checked := FEditorKey.AutoIndent;
    mmoAutoIndent.Lines.Assign(FEditorKey.AutoIndentList);
  {$ELSE}
    grpAutoIndent.Enabled := False;
    lbl3.Enabled := False;
    chkAutoIndent.Enabled := False;
    mmoAutoIndent.Enabled := False;
    chkAutoEnterEnd.Enabled := False;
  {$ENDIF}

    UpdateContent(nil);

    if ShowModal = mrOK then
    begin
      FEditorMisc.AddMenuCloseOtherPages := chkAddMenuCloseOtherPages.Checked;
      FEditorMisc.AddMenuSelAll := chkAddMenuSelAll.Checked;
      FEditorMisc.AddMenuExplore := chkAddMenuExplore.Checked;
      FEditorMisc.AddMenuCopyFileName := chkAddMenuCopyFileName.Checked;
      FEditorMisc.AddMenuShell := chkAddMenuShellMenu.Checked;
      FEditorMisc.ExploreCmdLine := Trim(edtExploreCmdLine.Text);
      if FEditorMisc.ExploreCmdLine = '' then
        FEditorMisc.ExploreCmdLine := csDefExploreCmdLine;
      FEditorMisc.ChangeCodeComKey := chkCodeCompletion.Checked;
      FEditorMisc.CodeCompletionKey := hkCodeCompletion.HotKey;

      FEditorMisc.AutoReadOnly := chkAutoReadOnly.Checked;
      FEditorMisc.ReadOnlyDirs := lbReadOnlyDirs.Items;

      FEditorMisc.DblClickClosePage := chkDblClkClosePage.Checked;
      FEditorMisc.DispModifiedInTab := chkDispModifiedInTab.Checked;
      FEditorMisc.RClickShellMenu := chkRClickShellMenu.Checked;

      if FEditorMisc.EditorTabMultiLine <> chkEditorMultiLine.Checked then
      begin
        FEditorMisc.EditorTabMultiLine := chkEditorMultiLine.Checked;
        FEditorMisc.UpdateEditorTabStyle;
      end;
      if FEditorMisc.EditorTabFlatButton <> chkEditorFlatButtons.Checked then
      begin
        FEditorMisc.EditorTabFlatButton := chkEditorFlatButtons.Checked;
        FEditorMisc.UpdateEditorTabStyle;
      end;

      FEditorMisc.AddMenuBlockTools := chkAddMenuBlockTools.Checked;
      FEditorMisc.AutoSave := chkAutoSave.Checked;
      FEditorMisc.SaveInterval := seSaveInterval.Value;

      FToolbarMgr.ShowToolBar := chkShowToolBar.Checked;
      FToolbarMgr.Wrapable := chkToolBarWrap.Checked;

      FGutterMgr.ShowLineNumber := chkShowLineNumber.Checked;
      FGutterMgr.ShowLineCount := chkShowLineCount.Checked;
      FGutterMgr.AutoWidth := rbLinePanelAutoWidth.Checked;
      FGutterMgr.AutoWidth := not rbLinePanelFixedWidth.Checked;
      FGutterMgr.Font := dlgFontLine.Font;
      FGutterMgr.CurrFont := dlgFontCurrLine.Font;
      FGutterMgr.MinWidth := seLinePanelMinWidth.Value;
      FGutterMgr.FixedWidth := seLinePanelFixWidth.Value;
      FGutterMgr.UpdateGutters;

    {$IFNDEF BDS}
      FNavMgr.MinLineDiff := seNavMinLineDiff.Value;
      FNavMgr.MaxItems := seNavMaxItems.Value;
      FNavMgr.ExtendForwardBack := chkExtendForwardBack.Checked;
      FNavMgr.UpdateInstall;
    {$ELSE}
      FToolbarMgr.ShowInDesign := chkShowInDesign.Checked;
    {$ENDIF}

      FBlockTools.ShowBlockTools := chkShowFlatButton.Checked;
      FEditorKey.SmartCopy := chkSmartCopy.Checked;
      FEditorKey.SmartPaste := chkSmartPaste.Checked;
      FBlockTools.TabIndent := chkTabIndent.Checked;
      FEditorKey.AutoBracket := chkAutoBracket.Checked;
      FEditorKey.ShiftEnter := chkShiftEnter.Checked;
      FEditorKey.HomeExt := chkHomeExtend.Checked;
      FEditorKey.F3Search := chkSearchAgain.Checked;
      FEditorKey.F2Rename := chkF2Rename.Checked;
      FEditorKey.RenameShortCut := hkRename.HotKey;
      FEditorKey.KeepSearch := chkKeepSearch.Checked;
      FEditorKey.HomeFirstChar := chkHomeFirstChar.Checked;
      FEditorKey.SemicolonLastChar := chkSemicolon.Checked;
    {$IFNDEF DELPHI10_UP}
      FEditorKey.AutoEnterEnd := chkAutoEnterEnd.Checked;
      FEditorKey.AutoIndent := chkAutoIndent.Checked;
      FEditorKey.AutoIndentList.Assign(mmoAutoIndent.Lines);
    {$ENDIF}

      DoSaveSettings;
    end;
  finally
    Free;
  end;
end;

{$IFDEF BDS}

procedure TCnSrcEditorEnhance.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
begin
  if Active and FToolbarMgr.Active and
    (ChangeType * [ctTopEditorChanged] <> []) then
    CheckToolBarEnable;
end;

procedure TCnSrcEditorEnhance.CheckToolBarEnableOnIdle(Sender: TObject);
begin
  CheckToolBarEnable;
end;

procedure TCnSrcEditorEnhance.EditControlNotify(EditControl: TControl;
  EditWindow: TCustomForm; Operation: TOperation);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(CheckToolBarEnableOnIdle)
end;

procedure TCnSrcEditorEnhance.CheckToolBarEnable;
var
  I, J, K: Integer;
  AControl: TControl;
  AVisible, EditVisible: Boolean;
begin
  if FToolbarMgr.Count > 0 then
  begin
    // 有编辑器工具栏，需要和外部工具栏夹杂处理
    for I := 0 to FToolbarMgr.Count - 1 do
    begin
      if not FToolbarMgr.ToolBars[I].Enabled then
        FToolbarMgr.ToolBars[I].Enabled := True;
      if not FToolbarMgr.ToolBars[I].ShowHint then
        FToolbarMgr.ToolBars[I].ShowHint := True;

      try
        if FToolbarMgr.ToolBars[I].Parent <> nil then
        begin
          if FToolbarMgr.ShowInDesign then // 允许其它工具栏也显示
          begin
            if not FToolbarMgr.ToolBars[I].Visible then
              FToolbarMgr.ToolBars[I].Visible := True;
            Continue;
          end;

          // 从头搜索第一个 Align 是 Client 的东西，是编辑器则显示
          for J := FToolbarMgr.ToolBars[I].Parent.ControlCount - 1 downto 0 do
          begin
            AControl := FToolbarMgr.ToolBars[I].Parent.Controls[J];
            if AControl.Align = alClient then
            begin
              EditVisible := AControl.ClassNameIs(EditControlClassName) and AControl.Visible;
              AVisible := EditVisible or AControl.ClassNameIs('TDisassemblyView'); // CPU 也显示

              if AVisible then
              begin
                if AVisible <> FToolbarMgr.ToolBars[I].Visible then
                  FToolbarMgr.ToolBars[I].Visible := AVisible;

                if CnEditorToolBarService <> nil then
                  CnEditorToolBarService.SetVisible(-1, AControl, EditVisible, False);
              end
              else // 要按倒序来，否则工具栏之间上下会错位
              begin
                // 还需要找出 EditControl 来让这个 EditControl 对应的 ToolBar 失效
                if CnEditorToolBarService <> nil then
                begin
                  for K := FToolbarMgr.ToolBars[I].Parent.ControlCount - 1 downto 0 do
                  begin
                    AControl := FToolbarMgr.ToolBars[I].Parent.Controls[K];
                    if AControl.ClassNameIs(EditControlClassName) then
                    begin
                      CnEditorToolBarService.SetVisible(-1, AControl, EditVisible, False);
              Break;
            end;
          end;
                end;

          if AVisible <> FToolbarMgr.ToolBars[I].Visible then
            FToolbarMgr.ToolBars[I].Visible := AVisible;
              end;
              Break;
            end;
          end;
        end;
      except
        ;
      end;
    end;
  end
  else // 无编辑器工具栏的情况下，单独调用 CheckEditorToolbarEnable 让其自行检测
  begin
    if CnEditorToolBarService <> nil then
      CnEditorToolBarService.CheckEditorToolbarEnable;
  end;
end;

{$ENDIF}

procedure TCnSrcEditorEnhance.OnEnhConfig(Sender: TObject);
begin
  Config;
end;

class procedure TCnSrcEditorEnhance.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnEditorEnhanceWizardName;
  Author := SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';' +
    SCnPack_Leeon + ';' + SCnPack_DragonPC;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail +
    ';' + SCnPack_LeeonEmail + ';' + SCnPack_DragonPCEmail;
  Comment := SCnEditorEnhanceWizardComment;
end;

initialization
  RegisterCnWizard(TCnSrcEditorEnhance);

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
