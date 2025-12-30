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

unit CnScriptWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.09.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}

{$IFDEF SUPPORT_PASCAL_SCRIPT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, ComCtrls, ExtCtrls, StdCtrls, ToolWin, ActnList, CheckLst,
  OmniXML, OmniXMLPersistent, CnClasses, CnConsts, CnWizMultiLang, CnWizClasses,
  TypInfo, CnWizUtils, CnWizConsts, CnCommon, CnWizShareImages, CnScriptClasses,
  CnWizOptions, CnWizShortCut, Buttons, CnScriptFrm, CnWizNotifier, CnWizManager,
  CnCheckTreeView;

type
  TOTAFileNotificationSet = set of TOTAFileNotification;
  TCnWizSourceEditorNotifyTypeSet = set of TCnWizSourceEditorNotifyType;
  TCnWizFormEditorNotifyTypeSet = set of TCnWizFormEditorNotifyType;
  TCnWizAppEventTypeSet = set of TCnWizAppEventType;

  TCnScriptItem = class(TCnAssignableCollectionItem)
  private
    FEnabled: Boolean;
    FFileName: string;
    FComment: string;
    FName: string;
    FActionIndex: Integer;
    FIconName: string;
    FShortCut: TShortCut;
    FConfirm: Boolean;
    FMode: TCnScriptModeSet;
    FFormEditorNotifyType: TCnWizFormEditorNotifyTypeSet;
    FSourceEditorNotifyType: TCnWizSourceEditorNotifyTypeSet;
    FFileNotifyCode: TOTAFileNotificationSet;
    FAppEventType: TCnWizAppEventTypeSet;
    FIsInternal: Boolean;
    function GetRelFileName: string;
    procedure SetRelFileName(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    property ActionIndex: Integer read FActionIndex write FActionIndex;
    property FileName: string read FFileName write FFileName;
    property IsInternal: Boolean read FIsInternal write FIsInternal; // 内部的不展示
  published
    property Name: string read FName write FName;
    property Comment: string read FComment write FComment;
    property Mode: TCnScriptModeSet read FMode write FMode default [smManual];
    property FileNotifyCode: TOTAFileNotificationSet
      read FFileNotifyCode write FFileNotifyCode default [];
    property SourceEditorNotifyType: TCnWizSourceEditorNotifyTypeSet
      read FSourceEditorNotifyType write FSourceEditorNotifyType default [];
    property FormEditorNotifyType: TCnWizFormEditorNotifyTypeSet
      read FFormEditorNotifyType write FFormEditorNotifyType default [];
    property AppEventType: TCnWizAppEventTypeSet read FAppEventType
      write FAppEventType default [];
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Confirm: Boolean read FConfirm write FConfirm default True;
    property ShortCut: TShortCut read FShortCut write FShortCut default 0;
    property IconName: string read FIconName write FIconName;
    property RelFileName: string read GetRelFileName write SetRelFileName;
  end;

  TCnScriptCollection = class(TCollection)
  private
    FIsInternal: Boolean;
    function GetItem(Index: Integer): TCnScriptItem;
    procedure SetItem(Index: Integer; const Value: TCnScriptItem);
  public
    constructor Create(AInternal: Boolean = False);
    function Add: TCnScriptItem;
    function LoadFromFile(const FileName: string; Append: Boolean = False): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function GetNewName: string;
    function IndexOfName(const AName: string): Integer;
    property IsInternal: Boolean read FIsInternal;
    property Items[Index: Integer]: TCnScriptItem read GetItem write SetItem; default;
  end;

  TCnScriptWizardForm = class(TCnTranslateForm)
    tlb1: TToolBar;
    ActionList: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    actClear: TAction;
    actExport: TAction;
    actImport: TAction;
    actClose: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    actHelp: TAction;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    btnClear: TToolButton;
    btnImport: TToolButton;
    btnExport: TToolButton;
    btnMoveUp: TToolButton;
    btnMoveDown: TToolButton;
    btnHelp: TToolButton;
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    btnClose: TToolButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    dlgOpenIcon: TOpenDialog;
    dlgOpenFile: TOpenDialog;
    pnl1: TPanel;
    grp1: TGroupBox;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl1: TLabel;
    btnOpen: TSpeedButton;
    lbl4: TLabel;
    lbl5: TLabel;
    btnFileName: TSpeedButton;
    edtName: TEdit;
    edtIcon: TEdit;
    chkEnabled: TCheckBox;
    edtComment: TEdit;
    hkShortCut: THotKey;
    chkExecConfirm: TCheckBox;
    edtFileName: TEdit;
    chktvMode: TCnCheckTreeView;
    grp2: TGroupBox;
    lbl6: TLabel;
    mmoSearchPath: TMemo;
    lvList: TListView;
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure OnControlChanged(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure lvListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnOpenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFileNameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chktvModeStateChange(Sender: TObject; Node: TTreeNode;
      OldState, NewState: TCheckBoxState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure hkShortCutExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    FUpdating: Boolean;
    procedure UpdateList(Sender: TObject);
    procedure UpdateControls;
    procedure SetItemToControls(Item: TCnScriptItem);
    procedure GetItemFromControls(Item: TCnScriptItem);
    function CheckCurrentShortCutContinue: Boolean;
    procedure InitTreeAndList;
  protected
    function GetHelpTopic: string; override;
  public
    TempScripts: TCnScriptCollection;
    // 用于真正控制显示与编辑的，内容可能比 Wizard 里头的少，因为后者有 Internal 项目
    procedure AddNewScript(const Script: string);
  end;

{ TCnScriptWizard }

  TCnScriptWizard = class(TCnSubMenuWizard)
  private
    IdForm: Integer;
    IdConfig: Integer;
    IdBrowseDemo: Integer;
    FInternalScripts: TCnScriptCollection; // 放预置的脚本，加载完成后会先加入 Fscripts
    FScripts: TCnScriptCollection;
    FMgr: TCnScriptFormMgr;
    FSearchPath: TStringList;
    procedure RemoveInternalItems(AScripts: TCnScriptCollection);
    // 删除 AScripts 中的所有 Internal 的条目
    procedure MergeCollectionsTo(AInternalFrom, ATo: TCnScriptCollection);
    // 将 AInternalFrom、ATo 条目合并至 ATo 中，AInternalFrom 中的内容不变
    procedure UpdateScriptActions;
    procedure DoExecute(Item: TCnScriptItem; AEvent: TCnScriptEvent); overload;
    procedure DoExecute(AEvent: TCnScriptEvent); overload;
    procedure DoConfig(const NewScript: string);
    
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure OnFormEditorNotify(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
    procedure OnBeforeCompile(const Project: IOTAProject;
      IsCodeInsight: Boolean; var Cancel: Boolean);
    procedure OnAfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure OnAppEventNotify(EventType: TCnWizAppEventType; Data: Pointer);
    procedure OnActiveFormNotify(Sender: TObject);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    
    procedure Loaded; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    
    procedure AddScript(const Lines: string);
    procedure ExecuteScriptByIndex(ItemIndex: Integer; AEvent: TCnScriptEvent);

    property Scripts: TCnScriptCollection read FScripts;
    property SearchPath: TStringList read FSearchPath;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}

{$IFDEF SUPPORT_PASCAL_SCRIPT}

{$R *.DFM}


uses
  CnEventBus {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csSearchPath = 'SearchPath';

  csScriptModeTextArray: array[TCnScriptMode] of PString = (
    @SCnScriptModeManual, @SCnScriptModeIDELoaded,
    @SCnScriptModeFileNotify, @SCnScriptModeBeforeCompile,
    @SCnScriptModeAfterCompile, @SCnScriptModeSourceEditorNotify,
    @SCnScriptModeFormEditorNotify, @SCnScriptModeApplicationEvent,
    @SCnScriptModeActiveFormChanged, @SCnScriptModeEditorFlatButton,
    @SCnScriptModeDesignerContextMenu);

{ TCnScriptItem }

constructor TCnScriptItem.Create(Collection: TCollection);
begin
  inherited;
  FName := TCnScriptCollection(Collection).GetNewName;
  FEnabled := True;
  FConfirm := True;
  FMode := [smManual];
  FFileNotifyCode := [];
  FSourceEditorNotifyType := [];
  FFormEditorNotifyType := [];
  FActionIndex := -1;
end;

function TCnScriptItem.GetRelFileName: string;
begin
  if FIsInternal then
    Result := ExtractRelativePath(WizOptions.DataPath, FFileName)
  else
    Result := ExtractRelativePath(WizOptions.UserPath, FFileName);
end;

procedure TCnScriptItem.SetRelFileName(const Value: string);
begin
  if FIsInternal then
    FFileName := LinkPath(WizOptions.DataPath, Value)
  else
    FFileName := LinkPath(WizOptions.UserPath, Value);
end;

{ TCnScriptCollection }

function TCnScriptCollection.Add: TCnScriptItem;
begin
  Result := TCnScriptItem(inherited Add);
  if FIsInternal then
    Result.IsInternal := True;
end;

constructor TCnScriptCollection.Create(AInternal: Boolean);
begin
  inherited Create(TCnScriptItem);
  FIsInternal := AInternal;
end;

function TCnScriptCollection.LoadFromFile(const FileName: string;
  Append: Boolean): Boolean;
var
  Col: TCnScriptCollection;
  I: Integer;
begin
  Result := False;
  try
    if not Append then
      Clear;
      
    Col := TCnScriptCollection.Create;
    try
      TOmniXMLReader.LoadFromFile(Col, FileName);
      for I := 0 to Col.Count - 1 do
        Add.Assign(Col.Items[I]);
      Result := True;
    finally
      Col.Free;
    end;
  except
    ;
  end;
end;

function TCnScriptCollection.SaveToFile(const FileName: string): Boolean;
begin
  Result := False;
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    ;
  end;
end;

function TCnScriptCollection.IndexOfName(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if SameText(Items[I].Name, AName) then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TCnScriptCollection.GetNewName: string;
var
  Idx: Integer;
begin
  Idx := 1;
  repeat
    Result := 'Script' + IntToStr(Idx);
    Inc(Idx);
  until IndexOfName(Result) < 0;
end;

function TCnScriptCollection.GetItem(Index: Integer): TCnScriptItem;
begin
  Result := TCnScriptItem(inherited Items[index]);
end;

procedure TCnScriptCollection.SetItem(Index: Integer;
  const Value: TCnScriptItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnScriptWizardForm }

procedure TCnScriptWizardForm.InitTreeAndList;
var
  Mode: TCnScriptMode;
  Node: TTreeNode;
  FileNotifyCode: TOTAFileNotification;
  SourceEditorNotifyType: TCnWizSourceEditorNotifyType;
  FormEditorNotifyType: TCnWizFormEditorNotifyType;
  AppEventType: TCnWizAppEventType;
begin
  chktvMode.BeginUpdate;
  try
    chktvMode.Items.Clear;
    for Mode := Low(Mode) to High(Mode) do
    begin
      Node := chktvMode.Items.AddChild(nil, csScriptModeTextArray[Mode]^);
      case Mode of
        smFileNotify:
          begin
            for FileNotifyCode := Low(FileNotifyCode) to High(FileNotifyCode) do
              chktvMode.Items.AddChild(Node, GetEnumName(TypeInfo(TOTAFileNotification),
                Ord(FileNotifyCode)));
          end;
        smSourceEditorNotify:
          begin
            for SourceEditorNotifyType := Low(SourceEditorNotifyType) to High(SourceEditorNotifyType) do
              chktvMode.Items.AddChild(Node, GetEnumName(TypeInfo(TCnWizSourceEditorNotifyType),
                Ord(SourceEditorNotifyType)));
          end;
        smFormEditorNotify:
          begin
            for FormEditorNotifyType := Low(FormEditorNotifyType) to High(FormEditorNotifyType) do
              chktvMode.Items.AddChild(Node, GetEnumName(TypeInfo(TCnWizFormEditorNotifyType),
                Ord(FormEditorNotifyType)));
          end;
        smApplicationEvent:
          begin
            for AppEventType := Low(TCnWizAppEventType) to High(TCnWizAppEventType) do
              chktvMode.Items.AddChild(Node, GetEnumName(TypeInfo(TCnWizAppEventType),
                Ord(AppEventType)));
          end;
      end;
    end;
    chktvMode.Selected := chktvMode.Items.GetFirstNode;
    chktvMode.TopItem := chktvMode.Items.GetFirstNode;
  finally
    chktvMode.EndUpdate;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InitTreeAndList Nodes ' + IntToStr(chktvMode.items.Count));
{$ENDIF}
{$IFDEF DELPHI120_ATHENS_UP}
  CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateList);
{$ENDIF}
end;

procedure TCnScriptWizardForm.FormCreate(Sender: TObject);
begin
  inherited;
  WizOptions.ResetToolbarWithLargeIcons(tlb1);

  TempScripts := TCnScriptCollection.Create;
  EnlargeListViewColumns(lvList);

{$IFNDEF DELPHI120_ATHENS_UP}
  InitTreeAndList;
{$ENDIF}
end;

procedure TCnScriptWizardForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  OnControlChanged(nil);

  if ModalResult = mrNone then
    ModalResult := mrOk;
  Action := caHide;
end;

procedure TCnScriptWizardForm.UpdateList(Sender: TObject);
begin
  lvList.Items.Count := TempScripts.Count;
  lvList.Invalidate;
  if (lvList.Items.Count > 0) and (lvList.Selected = nil) then
    lvList.Selected := lvList.Items[0];
  UpdateControls;
end;

procedure TCnScriptWizardForm.lvListData(Sender: TObject; Item: TListItem);
var
  Script: TCnScriptItem;
begin
  if Item <> nil then
  begin
    Script := TempScripts[Item.Index];
    Item.Caption := Script.Name;
    Item.SubItems.Clear;
    Item.SubItems.Add(BoolToStr(Script.Enabled, True));
  end;  
end;

procedure TCnScriptWizardForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  HasSel: Boolean;
begin
  HasSel := lvList.Selected <> nil;
  actDelete.Enabled := HasSel;
  actClear.Enabled := TempScripts.Count > 0;
  actMoveUp.Enabled := HasSel and (lvList.Selected.Index > 0);
  actMoveDown.Enabled := HasSel and (lvList.Selected.Index < TempScripts.Count - 1);

  Handled := True;
end;

procedure TCnScriptWizardForm.actAddExecute(Sender: TObject);
begin
  TempScripts.Add;
  UpdateList(Self);
  lvList.Selected := lvList.Items[TempScripts.Count - 1];
end;

procedure TCnScriptWizardForm.actDeleteExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and QueryDlg(SCnDeleteConfirm) then
  begin
    Idx := lvList.Selected.Index;
    TempScripts.Delete(Idx);
    UpdateList(Self);
    if TempScripts.Count > 0 then
      lvList.Selected := lvList.Items[TrimInt(Idx, 0, TempScripts.Count - 1)];
  end;
end;

procedure TCnScriptWizardForm.actClearExecute(Sender: TObject);
begin
  if QueryDlg(SCnClearConfirm) then
  begin
    TempScripts.Clear;
    UpdateList(Self);
  end;
end;

procedure TCnScriptWizardForm.actMoveUpExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and (lvList.Selected.Index > 0) then
  begin
    Idx := lvList.Selected.Index;
    TempScripts[Idx].Index := Idx - 1;
    lvList.Selected := lvList.Items[Idx - 1];
    lvList.Invalidate;
  end;  
end;

procedure TCnScriptWizardForm.actMoveDownExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and (lvList.Selected.Index < TempScripts.Count - 1) then
  begin
    Idx := lvList.Selected.Index;
    TempScripts[Idx].Index := Idx + 1;
    lvList.Selected := lvList.Items[Idx + 1];
    lvList.Invalidate;
  end;  
end;

procedure TCnScriptWizardForm.actExportExecute(Sender: TObject);
begin
  if dlgSave.Execute then
    if not TempScripts.SaveToFile(dlgSave.FileName) then
      ErrorDlg(SCnExportError);
end;

procedure TCnScriptWizardForm.actImportExecute(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    if not TempScripts.LoadFromFile(dlgOpen.FileName, QueryDlg(SCnImportAppend)) then
      ErrorDlg(SCnImportError);
    UpdateList(Self);
  end;
end;

procedure TCnScriptWizardForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnScriptWizardForm.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCnScriptWizardForm.AddNewScript(const Script: string);
begin
  actAdd.Execute;
  OnControlChanged(nil);
  edtName.Text := _CnChangeFileExt(_CnExtractFileName(Script), '');
  edtFileName.Text := Script;
  ActiveControl := edtName;
end;

function TCnScriptWizardForm.GetHelpTopic: string;
begin
  Result := 'CnScriptWizard';
end;

procedure TCnScriptWizardForm.GetItemFromControls(Item: TCnScriptItem);
var
  Node: TTreeNode;
  Mode: TCnScriptMode;
  ModeSet: TCnScriptModeSet;
  FileNotifyCode: TOTAFileNotification;
  FileNotifyCodeSet: TOTAFileNotificationSet;
  SourceEditorNotifyType: TCnWizSourceEditorNotifyType;
  SourceEditorNotifyTypeSet: TCnWizSourceEditorNotifyTypeSet;
  FormEditorNotifyType: TCnWizFormEditorNotifyType;
  FormEditorNotifyTypeSet: TCnWizFormEditorNotifyTypeSet;
  AppEventType: TCnWizAppEventType;
  AppEventTypeSet: TCnWizAppEventTypeSet;
begin
  Item.Name := edtName.Text;
  Item.Comment := edtComment.Text;
  Item.IconName := edtIcon.Text;
  Item.ShortCut := hkShortCut.HotKey;
  Item.FileName := edtFileName.Text;
  Item.Enabled := chkEnabled.Checked;
  Item.Confirm := chkExecConfirm.Checked;

  ModeSet := [];
  FileNotifyCodeSet := [];
  SourceEditorNotifyTypeSet := [];
  FormEditorNotifyTypeSet := [];
  AppEventTypeSet := [];
{$IFDEF DEBUG}
  CnDebugger.LogMsg('GetItemFromControls Nodes ' + IntToStr(chktvMode.items.Count));
{$ENDIF}

  Node := chktvMode.Items.GetFirstNode;
  if Node = nil then
    Exit;

  for Mode := Low(Mode) to High(Mode) do
  begin
    case Mode of
      smFileNotify:
        begin
          for FileNotifyCode := Low(FileNotifyCode) to High(FileNotifyCode) do
            if chktvMode.Checked[Node[Ord(FileNotifyCode)]] then
              Include(FileNotifyCodeSet, FileNotifyCode);
          if FileNotifyCodeSet <> [] then
            Include(ModeSet, Mode);
        end;
      smSourceEditorNotify:
        begin
          for SourceEditorNotifyType := Low(SourceEditorNotifyType) to High(SourceEditorNotifyType) do
            if chktvMode.Checked[Node[Ord(SourceEditorNotifyType)]] then
              Include(SourceEditorNotifyTypeSet, SourceEditorNotifyType);
          if SourceEditorNotifyTypeSet <> [] then
            Include(ModeSet, Mode);
        end;
      smFormEditorNotify:
        begin
          for FormEditorNotifyType := Low(FormEditorNotifyType) to High(FormEditorNotifyType) do
            if chktvMode.Checked[Node[Ord(FormEditorNotifyType)]] then
              Include(FormEditorNotifyTypeSet, FormEditorNotifyType);
          if FormEditorNotifyTypeSet <> [] then
            Include(ModeSet, Mode);
        end;
      smApplicationEvent:
        begin
          for AppEventType := Low(TCnWizAppEventType) to High(TCnWizAppEventType) do
            if chktvMode.Checked[Node[Ord(AppEventType)]] then
              Include(AppEventTypeSet, AppEventType);
          if AppEventTypeSet <> [] then
            Include(ModeSet, Mode);
        end;
    else
      begin
        if chktvMode.Checked[Node] then
          Include(ModeSet, Mode);
      end;
    end;

    Node := Node.getNextSibling;
    if Node = nil then
      Break;
  end;

  Item.Mode := ModeSet;
  Item.FileNotifyCode := FileNotifyCodeSet;
  Item.SourceEditorNotifyType := SourceEditorNotifyTypeSet;
  Item.FormEditorNotifyType := FormEditorNotifyTypeSet;
  Item.AppEventType := AppEventTypeSet;
  lvList.UpdateItems(Item.Index, Item.Index);
end;

procedure TCnScriptWizardForm.SetItemToControls(Item: TCnScriptItem);
var
  Node: TTreeNode;
  Mode: TCnScriptMode;
  FileNotifyCode: TOTAFileNotification;
  SourceEditorNotifyType: TCnWizSourceEditorNotifyType;
  FormEditorNotifyType: TCnWizFormEditorNotifyType;
  AppEventType: TCnWizAppEventType;
begin
  edtName.Text := Item.Name;
  edtComment.Text := Item.Comment;
  edtIcon.Text := Item.IconName;
  hkShortCut.HotKey := Item.ShortCut;
  edtFileName.Text := Item.FileName;
  chkEnabled.Checked := Item.Enabled;
  chkExecConfirm.Checked := Item.Confirm;

  Node := chktvMode.Items.GetFirstNode;
  if Node = nil then // 有可能未初始化
    Exit;

  for Mode := Low(Mode) to High(Mode) do
  begin
    if Mode in Item.Mode then
    begin
      case Mode of
        smFileNotify:
          begin
            for FileNotifyCode := Low(FileNotifyCode) to High(FileNotifyCode) do
              chktvMode.Checked[Node[Ord(FileNotifyCode)]] := FileNotifyCode in
                Item.FileNotifyCode;
          end;
        smSourceEditorNotify:
          begin
            for SourceEditorNotifyType := Low(SourceEditorNotifyType) to High(SourceEditorNotifyType) do
              chktvMode.Checked[Node[Ord(SourceEditorNotifyType)]] :=
                SourceEditorNotifyType in Item.SourceEditorNotifyType;
          end;
        smFormEditorNotify:
          begin
            for FormEditorNotifyType := Low(FormEditorNotifyType) to High(FormEditorNotifyType) do
              chktvMode.Checked[Node[Ord(FormEditorNotifyType)]] :=
                FormEditorNotifyType in Item.FormEditorNotifyType;
          end;
        smApplicationEvent:
          begin
            for AppEventType := Low(TCnWizAppEventType) to High(TCnWizAppEventType) do
              chktvMode.Checked[Node[Ord(AppEventType)]] :=
                AppEventType in Item.AppEventType;
          end;
      else
        chktvMode.Checked[Node] := True;
      end;
    end
    else
      chktvMode.Checked[Node] := False;
    Node := Node.getNextSibling;

    if Node = nil then
      Exit;
  end;
end;

procedure TCnScriptWizardForm.chktvModeStateChange(Sender: TObject;
  Node: TTreeNode; OldState, NewState: TCheckBoxState);
begin
  OnControlChanged(nil);
end;

procedure TCnScriptWizardForm.OnControlChanged(Sender: TObject);
begin
  if lvList.Selected <> nil then
  begin
    if FUpdating then Exit;
    FUpdating := True;
    try
      GetItemFromControls(TempScripts[lvList.Selected.Index]);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TCnScriptWizardForm.UpdateControls;
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    if lvList.Selected <> nil then
    begin
      edtFileName.Enabled := True;
      edtName.Enabled := True;
      edtComment.Enabled := True;
      edtIcon.Enabled := True;
      btnOpen.Enabled := True;
      hkShortCut.Enabled := True;
      chkEnabled.Enabled := True;
      chkExecConfirm.Enabled := True;
      chktvMode.Enabled := True;
      SetItemToControls(TempScripts[lvList.Selected.Index]);
    end
    else
    begin
      edtFileName.Enabled := False;
      edtFileName.Text := '';
      edtName.Enabled := False;
      edtName.Text := '';
      edtComment.Enabled := False;
      edtComment.Text := '';
      edtIcon.Enabled := False;
      edtIcon.Text := '';
      btnOpen.Enabled := False;
      hkShortCut.Enabled := False;
      hkShortCut.HotKey := 0;
      chkEnabled.Enabled := False;
      chkExecConfirm.Enabled := False;
      chktvMode.Enabled := False;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TCnScriptWizardForm.lvListChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  UpdateControls;
end;

procedure TCnScriptWizardForm.btnFileNameClick(Sender: TObject);
begin
  dlgOpenFile.InitialDir := _CnExtractFilePath(edtFileName.Text);
  dlgOpenFile.FileName := _CnExtractFileName(edtFileName.Text);
  if dlgOpenFile.Execute then
    edtFileName.Text := dlgOpenFile.FileName;
end;

procedure TCnScriptWizardForm.btnOpenClick(Sender: TObject);
begin
  dlgOpenIcon.InitialDir := _CnExtractFilePath(edtIcon.Text);
  dlgOpenIcon.FileName := _CnExtractFileName(edtIcon.Text);
  if dlgOpenIcon.Execute then
    edtIcon.Text := dlgOpenIcon.FileName;
end;

function TCnScriptWizardForm.CheckCurrentShortCutContinue: Boolean;
var
  I, Idx: Integer;
  Wizard: TCnScriptWizard;
  ScriptAction: TCustomAction;
  AScript, BScript: TCnScriptItem;
begin
  // 判断快捷键是否重复，不重复或允许之后，再更新条目
  // 如果是手动运行类型的就找其 Action（可能是 nil），如果是其他，也以 nil 找
  Result := True;
  Wizard := nil;
  if CnWizardMgr.WizardByClass(TCnScriptWizard) <> nil then
    if CnWizardMgr.WizardByClass(TCnScriptWizard) is TCnScriptWizard then
      Wizard := TCnScriptWizard(CnWizardMgr.WizardByClass(TCnScriptWizard));

  if Wizard = nil then
    Exit;

  Idx := 2; // 脚本专家菜单的脚本列表前面有仨菜单项，0 1 2
  ScriptAction := nil;

  // 要寻找 lvList 中的选中项有无对应的下拉菜单的 Action
  if lvList.Selected <> nil then
  begin
    AScript := TempScripts[lvList.Selected.Index];

    if AScript.Enabled and not AScript.IsInternal and (smManual in AScript.Mode) then
    begin
      // 被选中项应有对应菜单项，需要找 Action
      for I := 0 to TempScripts.Count - 1 do
      begin
        BScript := TempScripts[I];
        if BScript.Enabled and not BScript.IsInternal and (smManual in BScript.Mode) then
          Inc(Idx);

        if BScript = AScript then
          ScriptAction := Wizard.SubActions[Idx];
      end;
    end;
  end;

  Result := CheckQueryShortCutDuplicated(hkShortCut.HotKey, ScriptAction) <> sdDuplicatedStop;
end;

{ TCnScriptWizard }

constructor TCnScriptWizard.Create;
begin
  inherited;
  FSearchPath := TStringList.Create;
  FScripts := TCnScriptCollection.Create;
  FInternalScripts := TCnScriptCollection.Create(True);

  FMgr := TCnScriptFormMgr.Create;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
  CnWizNotifierServices.AddBeforeCompileNotifier(OnBeforeCompile);
  CnWizNotifierServices.AddAfterCompileNotifier(OnAfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.AddFormEditorNotifier(OnFormEditorNotify);
  CnWizNotifierServices.AddAppEventNotifier(OnAppEventNotify);
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormNotify);
end;

destructor TCnScriptWizard.Destroy;
begin
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  CnWizNotifierServices.RemoveBeforeCompileNotifier(OnBeforeCompile);
  CnWizNotifierServices.RemoveAfterCompileNotifier(OnAfterCompile);
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.RemoveFormEditorNotifier(OnFormEditorNotify);
  CnWizNotifierServices.RemoveAppEventNotifier(OnAppEventNotify);
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormNotify);
  FMgr.Free;
  FInternalScripts.Free;
  FScripts.Free;
  FSearchPath.Free;
  inherited;
end;

procedure TCnScriptWizard.Loaded;
var
  Event: TCnScriptIDELoaded;
begin
  Event := TCnScriptIDELoaded.Create;
  try
    DoExecute(Event);
  finally
    Event.Free;
  end;          
end;

procedure TCnScriptWizard.UpdateScriptActions;
var
  I: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    while SubActionCount > IdBrowseDemo + 1 do
      DeleteSubAction(IdBrowseDemo + 1);
    for I := 0 to FScripts.Count - 1 do
    begin
      with FScripts[I] do
      begin
        if Enabled and not IsInternal and (smManual in Mode) then
        begin
          ActionIndex := RegisterASubAction(SCnScriptItem + IntToStr(I),
            Name, ShortCut, Comment, IconName);
          SubActions[ActionIndex].ShortCut := ShortCut;
        end
        else
          ActionIndex := -1;
      end;
    end;
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnScriptWizard.AcquireSubActions;
begin
  IdForm := RegisterASubAction(SCnScriptFormCommand,
    SCnScriptFormCaption, 0, SCnScriptFormHint);
  IdConfig := RegisterASubAction(SCnScriptWizCfgCommand,
    SCnScriptWizCfgCaption, 0, SCnScriptWizCfgHint);
  IdBrowseDemo := RegisterASubAction(SCnScriptBrowseDemoCommand,
    SCnScriptBrowseDemoCaption, 0, SCnScriptBrowseDemoHint);

  // 创建分隔菜单
  AddSepMenu;

  UpdateScriptActions;
end;

procedure TCnScriptWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
  Event: TCnScriptEvent;
begin
  if not Active then Exit;

  if Index = IdForm then
  begin
    FMgr.Execute(True);
  end
  else if Index = IdConfig then
  begin
    Config;
  end
  else if Index = IdBrowseDemo then
  begin
    ExploreDir(WizOptions.DllPath + SCnScriptDemoDir);
  end
  else
  begin
    for I := 0 to FScripts.Count - 1 do
    begin
      if FScripts[I].Enabled and not FScripts[I].IsInternal and (FScripts[I].ActionIndex = Index) then
      begin
        if not FScripts[I].Confirm or QueryDlg(Format(SCnScriptExecConfirm,
          [FScripts[I].Name])) then
        begin
          Event := TCnScriptEvent.Create(smManual);
          try
            DoExecute(FScripts[I], Event);
          finally
            Event.Free;
          end;
        end;
        Exit;
      end;
    end;
  end;
end;

procedure TCnScriptWizard.SubActionUpdate(Index: Integer);
begin
  if Index <= IdBrowseDemo then
  begin
    SubActions[Index].Visible := Active;
    SubActions[Index].Enabled := Active;
  end
  else
  begin
    SubActions[Index].Enabled := Action.Enabled;
  end;
end;

procedure TCnScriptWizard.DoExecute(Item: TCnScriptItem; AEvent: TCnScriptEvent);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Script Wizard Do Execute:' + Item.FileName);
{$ENDIF}

  if FileExists(Item.FileName) then
  begin
    FMgr.ExecuteScript(Item.FileName, AEvent);
  end
  else
    ErrorDlg(SCnScriptFileNotExists);
end;

procedure TCnScriptWizard.DoExecute(AEvent: TCnScriptEvent);
var
  I: Integer;
begin
  for I := 0 to FScripts.Count - 1 do
    if FScripts[I].Enabled and (AEvent.Mode in FScripts[I].Mode) and
      FileExists(FScripts[I].FileName) then
    begin
      FMgr.ExecuteScript(FScripts[I].FileName, AEvent);
    end;  
end;

procedure TCnScriptWizard.DoConfig(const NewScript: string);
var
  I: Integer;
begin
  with TCnScriptWizardForm.Create(nil) do
  try
    TempScripts.Assign(FScripts);    // 注意没有复制 IsInternal 属性，不能直接 RemoveInternalItems
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ScriptWizard Config Start. Internal %d External %d. Duplicated Temp %d.',
      [FInternalScripts.Count, FScripts.Count, TempScripts.Count]);
{$ENDIF}

    for I := 0 to FInternalScripts.Count - 1 do
      TempScripts.Delete(0);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ScriptWizard Config. Show %d Scripts for Setting.', [TempScripts.Count]);
{$ENDIF}

    mmoSearchPath.Lines.Assign(Self.FSearchPath);
    UpdateList(nil);
    
    if NewScript <> '' then
      AddNewScript(NewScript);

    ShowModal;

    // 把修改后的 TempScript 塞回 FScripts
    FScripts.Assign(TempScripts);
    MergeCollectionsTo(FInternalScripts, FScripts);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ScriptWizard Config End. Internal %d External %d.',
      [FInternalScripts.Count, FScripts.Count]);
{$ENDIF}

    FSearchPath.Assign(mmoSearchPath.Lines);
    UpdateScriptActions;
    FMgr.ClearEngineList;

    // 通知外界脚本库发生了改变
    EventBus.PostEvent(EVENT_SCRIPT_SETTING_CHANGED);
    DoSaveSettings;
  finally
    Free;
  end;   
end;

procedure TCnScriptWizard.Config;
begin
  DoConfig('');
end;

procedure TCnScriptWizard.AddScript(const Lines: string);
begin
  DoConfig(Lines);
end;

procedure TCnScriptWizard.ExecuteScriptByIndex(ItemIndex: Integer; AEvent: TCnScriptEvent);
begin
  if (ItemIndex < 0) or (ItemIndex >= FScripts.Count) then
    Exit;

  if FScripts[ItemIndex].Enabled then
  begin
    if not FScripts[ItemIndex].Confirm or QueryDlg(Format(SCnScriptExecConfirm,
      [FScripts[ItemIndex].Name])) then
      DoExecute(FScripts[ItemIndex], AEvent);
  end;
end;

function TCnScriptWizard.GetCaption: string;
begin
  Result := SCnScriptWizardMenuCaption;
end;

function TCnScriptWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnScriptWizard.GetHint: string;
begin
  Result := SCnScriptWizardMenuHint;
end;

function TCnScriptWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnScriptWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnScriptWizardName;
  Author := SCnPack_Zjy + ';RemObjects Team';
  Email := SCnPack_ZjyEmail;
  Comment := SCnScriptWizardComment;
end;

procedure TCnScriptWizard.LoadSettings(Ini: TCustomIniFile);
var
  S: string;
begin
  S := MakePath(WizOptions.DataPath) + SCnScriptInternalFileName;
  if FileExists(S) then
    FInternalScripts.LoadFromFile(S);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ScriptWizard Load %d Internal Items from %s', [FInternalScripts.Count, S]);
{$ENDIF}

  S := WizOptions.GetUserFileName(SCnScriptFileName, True);
  if FileExists(S) then
    FScripts.LoadFromFile(S);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ScriptWizard Load %d Items from %s', [FScripts.Count, S]);
{$ENDIF}

  MergeCollectionsTo(FInternalScripts, FScripts);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ScriptWizard Merge to %d Items', [FScripts.Count]);
{$ENDIF}
  FSearchPath.CommaText := Ini.ReadString('', csSearchPath, FSearchPath.CommaText);
end;

procedure TCnScriptWizard.SaveSettings(Ini: TCustomIniFile);
begin
  RemoveInternalItems(FScripts);

  // 删除内部的，只保存外部的
  FScripts.SaveToFile(WizOptions.GetUserFileName(SCnScriptFileName, False));
  WizOptions.CheckUserFile(SCnScriptFileName);
  Ini.WriteString('', csSearchPath, FSearchPath.CommaText);

  // 保存完毕后再把内部的加进来
  MergeCollectionsTo(FInternalScripts, FScripts);
end;

procedure TCnScriptWizard.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnScriptFileName);
end;

procedure TCnScriptWizard.SetActive(Value: Boolean);
begin
  inherited;
  FMgr.Active := Value;
end;

procedure TCnScriptWizard.OnAfterCompile(Succeeded,
  IsCodeInsight: Boolean);
var
  Event: TCnScriptAfterCompile;
begin
  if not IsCodeInsight then
  begin
    Event := TCnScriptAfterCompile.Create(Succeeded);
    try
      DoExecute(Event);
    finally
      Event.Free;
    end;
  end;    
end;

procedure TCnScriptWizard.OnBeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  Event: TCnScriptBeforeCompile;
begin
  if not IsCodeInsight then
  begin
    Event := TCnScriptBeforeCompile.Create(Project, Cancel);
    try
      DoExecute(Event);
      Cancel := Event.Cancel;
    finally
      Event.Free;
    end;
  end;
end;

procedure TCnScriptWizard.OnAppEventNotify(EventType: TCnWizAppEventType; Data: Pointer);
var
  I: Integer;
  Event: TCnScriptApplicationEventNotify;
begin
  Event := TCnScriptApplicationEventNotify.Create(EventType, TObject(Data));
  try
    for I := 0 to FScripts.Count - 1 do
      if FScripts[I].Enabled and (Event.Mode in FScripts[I].Mode) and
        (EventType in FScripts[I].AppEventType) then
      begin
        FMgr.ExecuteScript(FScripts[I].FileName, Event);
      end;
  finally
    Event.Free;
  end;
end;

procedure TCnScriptWizard.OnActiveFormNotify(Sender: TObject);
var
  Event: TCnScriptActiveFormChanged;
begin
  Event := TCnScriptActiveFormChanged.Create;
  try
    DoExecute(Event);
  finally
    Event.Free;
  end;
end;

procedure TCnScriptWizard.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
var
  Event: TCnScriptFileNotify;
  I: Integer;
begin
  Event := TCnScriptFileNotify.Create(NotifyCode, FileName);
  try
    for I := 0 to FScripts.Count - 1 do
      if FScripts[I].Enabled and (Event.Mode in FScripts[I].Mode) and
        (NotifyCode in FScripts[I].FileNotifyCode) and
        FileExists(FScripts[I].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[I].FileName, Event);
      end;
  finally
    Event.Free;
  end;          
end;

procedure TCnScriptWizard.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
var
  Event: TCnScriptSourceEditorNotify;
  I: Integer;
begin
  Event := TCnScriptSourceEditorNotify.Create(SourceEditor, NotifyType, EditView);
  try
    for I := 0 to FScripts.Count - 1 do
      if FScripts[I].Enabled and (Event.Mode in FScripts[I].Mode) and
        (NotifyType in FScripts[I].SourceEditorNotifyType) and
        FileExists(FScripts[I].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[I].FileName, Event);
      end;
  finally
    Event.Free;
  end;          
end;

procedure TCnScriptWizard.OnFormEditorNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
var
  Event: TCnScriptFormEditorNotify;
  I: Integer;
begin
  Event := TCnScriptFormEditorNotify.Create(FormEditor, NotifyType, Component,
    OldName, NewName);
  try
    for I := 0 to FScripts.Count - 1 do
      if FScripts[I].Enabled and (Event.Mode in FScripts[I].Mode) and
        (NotifyType in FScripts[I].FormEditorNotifyType) and
        FileExists(FScripts[I].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[I].FileName, Event);
      end;
  finally
    Event.Free;
  end;          
end;

procedure TCnScriptWizardForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Ord(Key) = VK_ESCAPE) and (Shift = []) then
  begin
    UpdateControls;
    Close;
  end;
end;

procedure TCnScriptWizard.MergeCollectionsTo(AInternalFrom,
  ATo: TCnScriptCollection);
var
  I: Integer;
  Item: TCnScriptItem;
begin
  if AInternalFrom.Count = 0 then
    Exit;

  for I := AInternalFrom.Count - 1 downto 0 do
  begin
    Item := TCnScriptItem(ATo.Insert(0));
    Item.IsInternal := True;       // 必须先设置 True 以正确拿到文件名
    Item.Assign(AInternalFrom[I]);
  end;
end;

procedure TCnScriptWizard.RemoveInternalItems(
  AScripts: TCnScriptCollection);
var
  I: Integer;
begin
  for I := AScripts.Count - 1 downto 0 do
    if AScripts[I].IsInternal then
      AScripts.Delete(I);
end;

procedure TCnScriptWizardForm.FormDestroy(Sender: TObject);
begin
  TempScripts.Free;
end;

procedure TCnScriptWizardForm.hkShortCutExit(Sender: TObject);
begin
  if CheckCurrentShortCutContinue then
    OnControlChanged(Sender);
end;

procedure TCnScriptWizardForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := CheckCurrentShortCutContinue;
end;

procedure TCnScriptWizardForm.FormShow(Sender: TObject);
begin
{$IFDEF DELPHI120_ATHENS_UP}
  InitTreeAndList;
{$ENDIF}
end;

initialization
  RegisterCnWizard(TCnScriptWizard); // 注册专家

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}
end.
