{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnEditorCollector;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：收集面板工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2012.08.22 V1.1
*               补上自动粘贴状态未保存的功能
*           2005.08.01 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard,
  CnWizConsts, CnSelectionCodeTool, CnIni, CnWizIdeDock, ComCtrls, Menus, Clipbrd,
  StdActns, ActnList, ToolWin, Tabs, CnWizShareImages, CnDesignEditorConsts,
  CnWizOptions;

type
  TCnEditorCollector = class(TCnBaseCodingToolset)
  protected
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure ParentActiveChanged(ParentActive: Boolean); override;
  end;

  TCnEditorCollectorForm = class(TCnIdeDockForm)
    tlbMain: TToolBar;
    btnSep7: TToolButton;
    btnFind: TToolButton;
    btnFindNext: TToolButton;
    btnReplace: TToolButton;
    btnSep4: TToolButton;
    btnSetFont: TToolButton;
    btnWordWrap: TToolButton;
    btnSave: TToolButton;
    btnLoad: TToolButton;
    btnNew: TToolButton;
    btnSep6: TToolButton;
    btnAbout: TToolButton;
    actlstEdit: TActionList;
    actEditSave: TAction;
    actEditLoad: TAction;
    actEditFind: TAction;
    actEditFindNext: TAction;
    actEditReplace: TAction;
    actEditWordWrap: TAction;
    actPageDelete: TAction;
    actPageNew: TAction;
    actPageRename: TAction;
    mmoEdit: TMemo;
    TabSet: TTabSet;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    dlgFind: TFindDialog;
    dlgReplace: TReplaceDialog;
    btn1: TToolButton;
    btnPageDelete: TToolButton;
    btnPageRename: TToolButton;
    actEditClear: TAction;
    btnEditClear: TToolButton;
    btnAutoPaste: TToolButton;
    btnSep8: TToolButton;
    btnImport: TToolButton;
    btnExport: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    btn4: TToolButton;
    procedure btnSetFontClick(Sender: TObject);
    procedure dlgFindClose(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure dlgFindShow(Sender: TObject);
    procedure dlgReplaceClose(Sender: TObject);
    procedure dlgReplaceFind(Sender: TObject);
    procedure dlgReplaceReplace(Sender: TObject);
    procedure dlgReplaceShow(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure actlstEditUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actEditSaveExecute(Sender: TObject);
    procedure actEditLoadExecute(Sender: TObject);
    procedure actEditFindExecute(Sender: TObject);
    procedure actEditFindNextExecute(Sender: TObject);
    procedure actEditReplaceExecute(Sender: TObject);
    procedure actEditWordWrapExecute(Sender: TObject);
    procedure actPageNewExecute(Sender: TObject);
    procedure actPageDeleteExecute(Sender: TObject);
    procedure actPageRenameExecute(Sender: TObject);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure actEditClearExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAutoPasteClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    FPath: string;
    FNextHandle: THandle;
    FAutoPaste: Boolean;
    Updating: Boolean;
    FClipUpdating: Boolean;
    Ini: TCustomIniFile;
    procedure SavePage;
    procedure LoadPage(Idx: Integer = -1);
    procedure LoadSettings;
    procedure SaveSettings;
    procedure OnFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    function DoFind(const Str: string; const UpperCase: Boolean; const Dlg:
      Boolean = True): Boolean;
    function GetNewLabel(AName: string): string;

    procedure UpdateClipHandle;
    procedure DrawClipBoard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    procedure ChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
  protected
    function GetHelpTopic: string; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public

  end;

var
  CnEditorCollectorForm: TCnEditorCollectorForm = nil;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

var
  Collector: TCnEditorCollector = nil;

const
  csCnCollectorForm = 'CnEditorCollectorForm';
  csDefLabel = 'Text';
  csTabLabel = 'CurrPage';
  csFont = 'Font';
  csWordWrap = 'WordWrap';
  csAutoPaste = 'AutoPaste';

var
  FindStr, RepStr: string;

{ TCnEditorCollector }

constructor TCnEditorCollector.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  Collector := Self;
  IdeDockManager.RegisterDockableForm(TCnEditorCollectorForm, CnEditorCollectorForm,
    csCnCollectorForm);
end;

destructor TCnEditorCollector.Destroy;
begin
  IdeDockManager.UnRegisterDockableForm(CnEditorCollectorForm, csCnCollectorForm);
  FreeAndNil(CnEditorCollectorForm);

  Collector := nil;
  inherited;
end;

procedure TCnEditorCollector.Execute;
begin
  if CnEditorCollectorForm = nil then
    CnEditorCollectorForm := TCnEditorCollectorForm.Create(nil);

  IdeDockManager.ShowForm(CnEditorCollectorForm);
end;

procedure TCnEditorCollector.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Value <> Old then
  begin
    if Value then
    begin
      IdeDockManager.RegisterDockableForm(TCnEditorCollectorForm, CnEditorCollectorForm,
        csCnCollectorForm);
    end
    else
    begin
      IdeDockManager.UnRegisterDockableForm(CnEditorCollectorForm, csCnCollectorForm);
      FreeAndNil(CnEditorCollectorForm);
    end;
  end;
end;

function TCnEditorCollector.GetCaption: string;
begin
  Result := SCnEditorCollectorMenuCaption;
end;

procedure TCnEditorCollector.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCollectorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

function TCnEditorCollector.GetHint: string;
begin
  Result := SCnEditorCollectorMenuHint;
end;

procedure TCnEditorCollector.ParentActiveChanged(ParentActive: Boolean);
begin
  if ParentActive then
  begin
    IdeDockManager.RegisterDockableForm(TCnEditorCollectorForm, CnEditorCollectorForm,
      csCnCollectorForm);
  end
  else
  begin
    IdeDockManager.UnRegisterDockableForm(CnEditorCollectorForm, csCnCollectorForm);
    if CnEditorCollectorForm <> nil then
    begin
      CnEditorCollectorForm.Free;
      CnEditorCollectorForm := nil;
    end;
  end;
end;

{ TCnEditorCollectorForm }

procedure TCnEditorCollectorForm.actlstEditUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actEditWordWrap.Checked := mmoEdit.WordWrap;
end;

function TCnEditorCollectorForm.GetHelpTopic: string;
begin
  Result := 'CnEditorCollector';
end;

//------------------------------------------------------------------------------
// 页面操作
//------------------------------------------------------------------------------

procedure TCnEditorCollectorForm.FormCreate(Sender: TObject);
begin
  inherited;
  Assert(Collector <> nil);
  WizOptions.ResetToolbarWithLargeIcons(tlbMain);

  Ini := Collector.CreateIniFile;
  FPath := MakePath(WizOptions.UserPath + SCnCodingToolsetCollectorDir);
  ForceDirectories(FPath);
  TabSet.Font := Font;
  LoadSettings;
  UpdateClipHandle;
end;

procedure TCnEditorCollectorForm.FormDeactivate(Sender: TObject);
begin
  SavePage;
end;

procedure TCnEditorCollectorForm.FormDestroy(Sender: TObject);
begin
  inherited;
  if FNextHandle <> 0 then
    ChangeClipboardChain(Handle, FNextHandle);
  SaveSettings;
  Ini.Free;
  CnEditorCollectorForm := nil;
end;

procedure TCnEditorCollectorForm.LoadSettings;
var
  S: string;
begin
  Updating := True;
  with TCnIniFile.Create(Ini) do
  try
    TabSet.Tabs.Clear;
    if FileExists(WizOptions.UserPath + SCnCodingToolsetCollectorData) then
      TabSet.Tabs.LoadFromFile(WizOptions.UserPath + SCnCodingToolsetCollectorData);
    FindFile(FPath, '*.*', OnFindFile, nil, False, False);

    if TabSet.Tabs.Count = 0 then
      TabSet.Tabs.Add(csDefLabel);
    S := ReadString('', csTabLabel, '');
    if (S <> '') and (TabSet.Tabs.IndexOf(S) >= 0) then
      TabSet.TabIndex := TabSet.Tabs.IndexOf(S)
    else if TabSet.TabIndex < 0 then
      TabSet.TabIndex := 0;

    mmoEdit.Font := ReadFont('', csFont, mmoEdit.Font);
    mmoEdit.WordWrap := ReadBool('', csWordWrap, mmoEdit.WordWrap);
    FAutoPaste := ReadBool('', csAutoPaste, False);
    if FAutoPaste then
      btnAutoPaste.Down := True;

    if mmoEdit.WordWrap then
      mmoEdit.ScrollBars := ssVertical
    else
      mmoEdit.ScrollBars := ssBoth;

    LoadPage;
  finally
    Free;
    Updating := False;
  end;
end;

procedure TCnEditorCollectorForm.SaveSettings;
begin
  SavePage;
  with TCnIniFile.Create(Ini) do
  try
    TabSet.Tabs.SaveToFile(WizOptions.UserPath + SCnCodingToolsetCollectorData);
    if (TabSet.TabIndex >= 0) then
      WriteString('', csTabLabel, TabSet.Tabs[TabSet.TabIndex])
    else
      WriteString('', csTabLabel, '');

    WriteFont('', csFont, mmoEdit.Font);
    WriteBool('', csWordWrap, mmoEdit.WordWrap);
    WriteBool('', csAutoPaste, FAutoPaste);
  finally
    Free;
  end;
end;

procedure TCnEditorCollectorForm.OnFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if TabSet.Tabs.IndexOf(Info.Name) < 0 then
    TabSet.Tabs.Add(Info.Name);
end;

function TCnEditorCollectorForm.GetNewLabel(AName: string): string;
var
  I: Integer;
begin
  if AName = '' then
    AName := csDefLabel;
  if TabSet.Tabs.IndexOf(AName) < 0 then
  begin
    Result := AName;
    Exit;
  end;  
  I := 1;
  while TabSet.Tabs.IndexOf(AName + IntToStr(I)) >= 0 do
    Inc(I);
  Result := AName + IntToStr(I);
end;
  
procedure TCnEditorCollectorForm.LoadPage(Idx: Integer);
begin
  try
    if Idx < 0 then
      Idx := TabSet.TabIndex;
    if (Idx >= 0) and FileExists(FPath + TabSet.Tabs[Idx]) then
      mmoEdit.Lines.LoadFromFile(FPath + TabSet.Tabs[Idx]);
  except
    on E: Exception do
      DoHandleException('TCnEditorCollectorForm.LoadPage', E);
  end;
end;

procedure TCnEditorCollectorForm.SavePage;
begin
  if TabSet.TabIndex >= 0 then
  begin
    try
      ForceDirectories(FPath);
      mmoEdit.Lines.SaveToFile(FPath + TabSet.Tabs[TabSet.TabIndex]);
    except
      on E: Exception do
        DoHandleException('TCnEditorCollectorForm.SavePage', E);
    end;
  end;
end;

procedure TCnEditorCollectorForm.actPageNewExecute(Sender: TObject);
var
  NewLabel: string;
begin
  SavePage;
  NewLabel := GetNewLabel('');
  if CnWizInputQuery(SCnEditorCollectorInputCaption, SCnEditorCollectorInputCaption,
    NewLabel) then
  begin
    Updating := True;
    try
      NewLabel := GetValidFileName(NewLabel);
      NewLabel := GetNewLabel(NewLabel);
      TabSet.Tabs.Add(NewLabel);
      TabSet.TabIndex := TabSet.Tabs.Count - 1;
      mmoEdit.Lines.Clear;
      SavePage;
    finally
      Updating := False;
    end;                
  end;
end;

procedure TCnEditorCollectorForm.actPageDeleteExecute(Sender: TObject);
begin
  if (TabSet.Tabs.Count > 1) and QueryDlg(SCnDeleteConfirm) then
  begin
    DeleteFile(FPath + TabSet.Tabs[TabSet.TabIndex]);
    TabSet.Tabs.Delete(TabSet.TabIndex);
    if TabSet.TabIndex < 0 then
      TabSet.TabIndex := 0;
    LoadPage;
  end;
end;

procedure TCnEditorCollectorForm.actPageRenameExecute(Sender: TObject);
var
  OldLabel, NewLabel: string;
begin
  OldLabel := TabSet.Tabs[TabSet.TabIndex];
  NewLabel := OldLabel;
  if CnWizInputQuery(SCnEditorCollectorInputCaption, SCnEditorCollectorInputCaption,
    NewLabel) then
  begin
    Updating := True;
    try
      NewLabel := GetValidFileName(NewLabel);
      TabSet.Tabs[TabSet.TabIndex] := NewLabel;
      if not SameText(OldLabel, NewLabel) then
      begin
        RenameFile(FPath + OldLabel, FPath + NewLabel);
      end;
    finally
      Updating := False;
    end;
  end;
end;

procedure TCnEditorCollectorForm.TabSetChange(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
begin
  if not Updating then
  begin
    SavePage;
    if NewTab >= 0 then
    begin
      LoadPage(NewTab);
      AllowChange := True;
    end;
  end;    
end;

procedure TCnEditorCollectorForm.actEditLoadExecute(Sender: TObject);
begin
  if TabSet.TabIndex >= 0 then
  begin
    if dlgOpen.Execute then
      mmoEdit.Lines.LoadFromFile(dlgOpen.FileName);
  end;      
end;

procedure TCnEditorCollectorForm.actEditSaveExecute(Sender: TObject);
begin
  if TabSet.TabIndex >= 0 then
  begin
    dlgSave.FileName := TabSet.Tabs[TabSet.TabIndex];
    if dlgSave.Execute then
      mmoEdit.Lines.SaveToFile(dlgSave.FileName);
  end;      
end;

procedure TCnEditorCollectorForm.actEditClearExecute(Sender: TObject);
begin
  mmoEdit.Clear;
end;

procedure TCnEditorCollectorForm.btnAboutClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnEditorCollectorForm.actEditWordWrapExecute(Sender: TObject);
begin
  mmoEdit.WordWrap := not mmoEdit.WordWrap;
  if mmoEdit.WordWrap then
    mmoEdit.ScrollBars := ssVertical
  else
    mmoEdit.ScrollBars := ssBoth;
end;

procedure TCnEditorCollectorForm.btnSetFontClick(Sender: TObject);
begin
  with TFontDialog.Create(Self) do
  try
    Font := mmoEdit.Font;
    if Execute then
    begin
      mmoEdit.Font := Font;
    end;
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// 查找替换
//------------------------------------------------------------------------------

function TCnEditorCollectorForm.DoFind(const Str: string; const UpperCase,
  Dlg: Boolean): Boolean;
var
  FoundPos, InitPos: Integer;
begin
  InitPos := mmoEdit.SelStart + mmoEdit.SelLength;

  if UpperCase then
    FoundPos := Pos(AnsiUpperCase(Str), AnsiUpperCase(Copy(mmoEdit.Text, InitPos
      + 1, Length(mmoEdit.Text) - InitPos)))
  else
    FoundPos := Pos(Str, Copy(mmoEdit.Text, InitPos + 1,
      Length(mmoEdit.Text) - InitPos));
  if FoundPos > 0 then
  begin
    try
      mmoEdit.SetFocus;
    except
    end;
    mmoEdit.SelStart := InitPos + FoundPos - 1;
    mmoEdit.SelLength := Length(Str);
  end
  else if Dlg then
  begin
    ShowMessage(SCnPropEditorNoMatch);
  end;
  Result := FoundPos > 0;
end;

procedure TCnEditorCollectorForm.actEditFindExecute(Sender: TObject);
begin
  with dlgFind do
  begin
    FindText := FindStr;
    Execute;
  end;
end;

procedure TCnEditorCollectorForm.actEditFindNextExecute(Sender: TObject);
begin
  if FindStr = '' then
  begin
    actEditFind.Execute;
  end
  else
    DoFind(FindStr, not (frMatchCase in dlgFind.Options));
end;

procedure TCnEditorCollectorForm.actEditReplaceExecute(Sender: TObject);
begin
  with dlgReplace do
  begin
    FindText := FindStr;
    ReplaceText := RepStr;
    Execute;
  end;
end;

procedure TCnEditorCollectorForm.dlgFindClose(Sender: TObject);
begin
  FindStr := dlgFind.FindText;
end;

procedure TCnEditorCollectorForm.dlgFindFind(Sender: TObject);
begin
  DoFind(dlgFind.FindText, not (frMatchCase in dlgFind.Options));
end;

procedure TCnEditorCollectorForm.dlgFindShow(Sender: TObject);
begin
  dlgFind.Top := Top + Height * 2 div 3;
  dlgFind.Left := Screen.Width div 3;
end;

procedure TCnEditorCollectorForm.dlgReplaceClose(Sender: TObject);
begin
  FindStr := dlgReplace.FindText;
  RepStr := dlgReplace.ReplaceText;
end;

procedure TCnEditorCollectorForm.dlgReplaceFind(Sender: TObject);
begin
  DoFind(dlgReplace.FindText, not (frMatchCase in dlgReplace.Options));
end;

procedure TCnEditorCollectorForm.dlgReplaceReplace(Sender: TObject);
var
  iCount, iSelStart: Integer;
begin
  if frReplaceAll in dlgReplace.Options then
  begin
    iCount := 0;
    mmoEdit.SelStart := 0;
    mmoEdit.SelLength := 0;
    while DoFind(dlgReplace.FindText, not (frMatchCase in dlgReplace.Options), False) do
    begin
      iSelStart := mmoEdit.SelStart;
      mmoEdit.SelText := dlgReplace.ReplaceText;
      mmoEdit.SelStart := iSelStart;
      mmoEdit.SelLength := Length(dlgReplace.ReplaceText);
      iCount := iCount + 1;
    end;
    if iCount > 0 then
      ShowMessage(Format(SCnPropEditorReplaceOK, [iCount]))
    else
      ShowMessage(SCnPropEditorNoMatch);
  end
  else if DoFind(dlgReplace.FindText, not (frMatchCase in dlgReplace.Options)) then
  begin
    iSelStart := mmoEdit.SelStart;
    mmoEdit.SelText := dlgReplace.ReplaceText;
    mmoEdit.SelStart := iSelStart;
    mmoEdit.SelLength := Length(dlgReplace.ReplaceText);
  end;
end;

procedure TCnEditorCollectorForm.dlgReplaceShow(Sender: TObject);
begin
  dlgReplace.Top := Top + Height * 2 div 3;
  dlgReplace.Left := Screen.Width div 3;
end;

procedure TCnEditorCollectorForm.DrawClipBoard(var Msg: TMessage);
begin
  if FAutoPaste and not FClipUpdating and not mmoEdit.Focused and
    Clipboard.HasFormat(CF_TEXT) then
  begin
    mmoEdit.PasteFromClipboard;
    PostMessage(mmoEdit.Handle, WM_KEYDOWN, VK_RETURN, 0);
  end;
  if FNextHandle <> Handle then
    SendMessage(FNextHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TCnEditorCollectorForm.btnAutoPasteClick(Sender: TObject);
begin
  FAutoPaste := btnAutoPaste.Down;
end;

procedure TCnEditorCollectorForm.ChangeCBChain(var Msg: TWMChangeCBChain);
begin
  if Msg.Remove = FNextHandle then
    FNextHandle := Msg.Next
  else if FNextHandle <> 0 then
    SendMessage(FNextHandle, Msg.Msg, Msg.Remove, Msg.Next);
end;

procedure TCnEditorCollectorForm.UpdateClipHandle;
begin
  FClipUpdating := True;
  if FNextHandle <> 0 then
    ChangeClipboardChain(Handle, FNextHandle);
  FNextHandle := SetClipboardViewer(Handle);
  FClipUpdating := False;
end;

procedure TCnEditorCollectorForm.CreateWnd;
begin
  inherited;
  UpdateClipHandle;
end;

procedure TCnEditorCollectorForm.DestroyWnd;
begin
  FClipUpdating := True;
  if FNextHandle <> 0 then
    ChangeClipboardChain(Handle, FNextHandle);
  FNextHandle := 0;
  FClipUpdating := False;
  inherited;
end;

procedure TCnEditorCollectorForm.btnImportClick(Sender: TObject);
begin
  mmoEdit.SelText := CnOtaGetCurrentSelection;
end;

procedure TCnEditorCollectorForm.btnExportClick(Sender: TObject);
begin
  if mmoEdit.SelText <> '' then
    CnOtaInsertTextToCurSource(mmoEdit.SelText);
end;

initialization
  RegisterCnCodingToolset(TCnEditorCollector); // 注册工具

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
