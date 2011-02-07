{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
* 单元标识：$Id$
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
  CnWizOptions, CnWizShortCut, Buttons, CnScriptFrm, CnWizNotifier,
  CnCheckTreeView;

type

  TOTAFileNotificationSet = set of TOTAFileNotification;
  TCnWizSourceEditorNotifyTypeSet = set of TCnWizSourceEditorNotifyType;
  TCnWizFormEditorNotifyTypeSet = set of TCnWizFormEditorNotifyType;

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
    function GetRelFileName: string;
    procedure SetRelFileName(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    property ActionIndex: Integer read FActionIndex write FActionIndex;
    property FileName: string read FFileName write FFileName;
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
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Confirm: Boolean read FConfirm write FConfirm default True;
    property ShortCut: TShortCut read FShortCut write FShortCut default 0;
    property IconName: string read FIconName write FIconName;
    property RelFileName: string read GetRelFileName write SetRelFileName;
  end;

  TCnScriptCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TCnScriptItem;
    procedure SetItem(Index: Integer; const Value: TCnScriptItem);
  public
    constructor Create;
    function Add: TCnScriptItem;
    function LoadFromFile(const FileName: string; Append: Boolean = False): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function GetNewName: string;
    function IndexOfName(const AName: string): Integer;
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
    lvList: TListView;
    dlgOpenIcon: TOpenDialog;
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
    grp2: TGroupBox;
    lbl6: TLabel;
    mmoSearchPath: TMemo;
    dlgOpenFile: TOpenDialog;
    chktvMode: TCnCheckTreeView;
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
  private
    { Private declarations }
    FUpdating: Boolean;
    procedure UpdateList;
    procedure UpdateControls;
    procedure SetItemToControls(Item: TCnScriptItem);
    procedure GetItemFromControls(Item: TCnScriptItem);
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    Scripts: TCnScriptCollection;
    procedure AddNewScript(const Script: string);
  end;

{ TCnScriptWizard }

  TCnScriptWizard = class(TCnSubMenuWizard)
  private
    IdForm: Integer;
    IdConfig: Integer;
    IdBrowseDemo: Integer;
    FScripts: TCnScriptCollection;
    FMgr: TCnScriptFormMgr;
    FSearchPath: TStringList;
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
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    
    procedure AddScript(const Lines: string);

    property Scripts: TCnScriptCollection read FScripts;
    property SearchPath: TStringList read FSearchPath;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSCRIPTWIZARD}

{$IFDEF SUPPORT_PASCAL_SCRIPT}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csSearchPath = 'SearchPath';

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
  Result := GetRelativePath(FFileName, WizOptions.UserPath);
end;

procedure TCnScriptItem.SetRelFileName(const Value: string);
begin
  FFileName := LinkPath(WizOptions.UserPath, Value);
end;

{ TCnScriptCollection }

function TCnScriptCollection.Add: TCnScriptItem;
begin
  Result := TCnScriptItem(inherited Add);
end;

constructor TCnScriptCollection.Create;
begin
  inherited Create(TCnScriptItem);
end;

function TCnScriptCollection.LoadFromFile(const FileName: string;
  Append: Boolean): Boolean;
var
  Col: TCnScriptCollection;
  i: Integer;
begin
  Result := False;
  try
    if not Append then
      Clear;
      
    Col := TCnScriptCollection.Create;
    try
      TOmniXMLReader.LoadFromFile(Col, FileName);
      for i := 0 to Col.Count - 1 do
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
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameText(Items[i].Name, AName) then
    begin
      Result := i;
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

procedure TCnScriptWizardForm.FormCreate(Sender: TObject);
var
  Mode: TCnScriptMode;
  Node: TTreeNode;
  FileNotifyCode: TOTAFileNotification;
  SourceEditorNotifyType: TCnWizSourceEditorNotifyType;
  FormEditorNotifyType: TCnWizFormEditorNotifyType;
begin
  inherited;

  chktvMode.BeginUpdate;
  try
    chktvMode.Items.Clear;
    for Mode := Low(Mode) to High(Mode) do
    begin
      Node := chktvMode.Items.AddChild(nil, GetEnumName(TypeInfo(TCnScriptMode),
        Ord(Mode)));
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
      end;
    end;
    chktvMode.Selected := chktvMode.Items.GetFirstNode;
    chktvMode.TopItem := chktvMode.Items.GetFirstNode;
  finally
    chktvMode.EndUpdate;
  end;
end;

procedure TCnScriptWizardForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  OnControlChanged(nil);
  if ModalResult = mrNone then
    ModalResult := mrOk;
  Action := caHide;
end;

procedure TCnScriptWizardForm.UpdateList;
begin
  lvList.Items.Count := Scripts.Count;
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
    Script := Scripts[Item.Index];
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
  actClear.Enabled := Scripts.Count > 0;
  actMoveUp.Enabled := HasSel and (lvList.Selected.Index > 0);
  actMoveDown.Enabled := HasSel and (lvList.Selected.Index < Scripts.Count - 1);

  Handled := True;
end;

procedure TCnScriptWizardForm.actAddExecute(Sender: TObject);
begin
  Scripts.Add;
  UpdateList;
  lvList.Selected := lvList.Items[Scripts.Count - 1];
end;

procedure TCnScriptWizardForm.actDeleteExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and QueryDlg(SCnDeleteConfirm) then
  begin
    Idx := lvList.Selected.Index;
    Scripts.Delete(Idx);
    UpdateList;
    if Scripts.Count > 0 then
      lvList.Selected := lvList.Items[TrimInt(Idx, 0, Scripts.Count - 1)];
  end;
end;

procedure TCnScriptWizardForm.actClearExecute(Sender: TObject);
begin
  if QueryDlg(SCnClearConfirm) then
  begin
    Scripts.Clear;
    UpdateList;
  end;  
end;

procedure TCnScriptWizardForm.actMoveUpExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and (lvList.Selected.Index > 0) then
  begin
    Idx := lvList.Selected.Index;
    Scripts[Idx].Index := Idx - 1;
    lvList.Selected := lvList.Items[Idx - 1];
    lvList.Invalidate;
  end;  
end;

procedure TCnScriptWizardForm.actMoveDownExecute(Sender: TObject);
var
  Idx: Integer;
begin
  if (lvList.Selected <> nil) and (lvList.Selected.Index < Scripts.Count - 1) then
  begin
    Idx := lvList.Selected.Index;
    Scripts[Idx].Index := Idx + 1;
    lvList.Selected := lvList.Items[Idx + 1];
    lvList.Invalidate;
  end;  
end;

procedure TCnScriptWizardForm.actExportExecute(Sender: TObject);
begin
  if dlgSave.Execute then
    if not Scripts.SaveToFile(dlgSave.FileName) then
      ErrorDlg(SCnExportError);
end;

procedure TCnScriptWizardForm.actImportExecute(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    if not Scripts.LoadFromFile(dlgOpen.FileName, QueryDlg(SCnImportAppend)) then
      ErrorDlg(SCnImportError);
    UpdateList;
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
  edtName.Text := ChangeFileExt(ExtractFileName(Script), '');
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
  Node := chktvMode.Items.GetFirstNode;
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
      else
        begin
          if chktvMode.Checked[Node] then
            Include(ModeSet, Mode);
        end;
    end;
    Node := Node.getNextSibling;
  end;

  Item.Mode := ModeSet;
  Item.FileNotifyCode := FileNotifyCodeSet;
  Item.SourceEditorNotifyType := SourceEditorNotifyTypeSet;
  Item.FormEditorNotifyType := FormEditorNotifyTypeSet;
  lvList.UpdateItems(Item.Index, Item.Index);
end;

procedure TCnScriptWizardForm.SetItemToControls(Item: TCnScriptItem);
var
  Node: TTreeNode;
  Mode: TCnScriptMode;
  FileNotifyCode: TOTAFileNotification;
  SourceEditorNotifyType: TCnWizSourceEditorNotifyType;
  FormEditorNotifyType: TCnWizFormEditorNotifyType;
begin
  edtName.Text := Item.Name;
  edtComment.Text := Item.Comment;
  edtIcon.Text := Item.IconName;
  hkShortCut.HotKey := Item.ShortCut;
  edtFileName.Text := Item.FileName;
  chkEnabled.Checked := Item.Enabled;
  chkExecConfirm.Checked := Item.Confirm;

  Node := chktvMode.Items.GetFirstNode;
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
        else
          chktvMode.Checked[Node] := True;
      end;
    end
    else
      chktvMode.Checked[Node] := False;
    Node := Node.getNextSibling;
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
      GetItemFromControls(Scripts[lvList.Selected.Index]);
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
      SetItemToControls(Scripts[lvList.Selected.Index]);
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
  dlgOpenFile.InitialDir := ExtractFilePath(edtFileName.Text);
  dlgOpenFile.FileName := ExtractFileName(edtFileName.Text);
  if dlgOpenFile.Execute then
    edtFileName.Text := dlgOpenFile.FileName;
end;

procedure TCnScriptWizardForm.btnOpenClick(Sender: TObject);
begin
  dlgOpenIcon.InitialDir := ExtractFilePath(edtIcon.Text);
  dlgOpenIcon.FileName := ExtractFileName(edtIcon.Text);
  if dlgOpenIcon.Execute then
    edtIcon.Text := dlgOpenIcon.FileName;
end;

{ TCnScriptWizard }

constructor TCnScriptWizard.Create;
begin
  inherited;
  FSearchPath := TStringList.Create;
  FScripts := TCnScriptCollection.Create;
  FMgr := TCnScriptFormMgr.Create;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
  CnWizNotifierServices.AddBeforeCompileNotifier(OnBeforeCompile);
  CnWizNotifierServices.AddAfterCompileNotifier(OnAfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.AddFormEditorNotifier(OnFormEditorNotify);
end;

destructor TCnScriptWizard.Destroy;
begin
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  CnWizNotifierServices.RemoveBeforeCompileNotifier(OnBeforeCompile);
  CnWizNotifierServices.RemoveAfterCompileNotifier(OnAfterCompile);
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.RemoveFormEditorNotifier(OnFormEditorNotify);
  FMgr.Free;
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
  i: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    while SubActionCount > IdBrowseDemo + 1 do
      DeleteSubAction(IdBrowseDemo + 1);
    for i := 0 to FScripts.Count - 1 do
      with FScripts[i] do
        if Enabled and (smManual in Mode) then
        begin
          ActionIndex := RegisterASubAction(SCnScriptItem + IntToStr(i),
            Name, ShortCut, Comment, IconName);
          SubActions[ActionIndex].ShortCut := ShortCut;
        end
        else
          ActionIndex := -1;
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
  i: Integer;
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
    for i := 0 to FScripts.Count - 1 do
      if FScripts[i].Enabled and (FScripts[i].ActionIndex = Index) then
      begin
        if not FScripts[i].Confirm or QueryDlg(Format(SCnScriptExecConfirm,
          [FScripts[i].Name])) then
        begin
          Event := TCnScriptEvent.Create(smManual);
          try
            DoExecute(FScripts[i], Event);
          finally
            Event.Free;
          end;                                  
        end;
        Exit;
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
  if FileExists(Item.FileName) then
  begin
    FMgr.ExecuteScript(Item.FileName, AEvent);
  end
  else
    ErrorDlg(SCnScriptFileNotExists);
end;

procedure TCnScriptWizard.DoExecute(AEvent: TCnScriptEvent);
var
  i: Integer;
begin
  for i := 0 to FScripts.Count - 1 do
    if FScripts[i].Enabled and (AEvent.Mode in FScripts[i].Mode) and
      FileExists(FScripts[i].FileName) then
    begin
      FMgr.ExecuteScript(FScripts[i].FileName, AEvent);
    end;  
end;

procedure TCnScriptWizard.DoConfig(const NewScript: string);
begin
  with TCnScriptWizardForm.Create(nil) do
  try
    Scripts := Self.FScripts;
    mmoSearchPath.Lines.Assign(Self.FSearchPath);
    UpdateList;
    
    if NewScript <> '' then
      AddNewScript(NewScript);

    ShowModal;

    FSearchPath.Assign(mmoSearchPath.Lines);
    UpdateScriptActions;
    FMgr.ClearEngineList;
    
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
begin
  Scripts.LoadFromFile(WizOptions.GetUserFileName(SCnScriptFileName, True));
  FSearchPath.CommaText := Ini.ReadString('', csSearchPath, FSearchPath.CommaText);
end;

procedure TCnScriptWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Scripts.SaveToFile(WizOptions.GetUserFileName(SCnScriptFileName, False));
  WizOptions.CheckUserFile(SCnScriptFileName);
  Ini.WriteString('', csSearchPath, FSearchPath.CommaText);
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

procedure TCnScriptWizard.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
var
  Event: TCnScriptFileNotify;
  i: Integer;
begin
  Event := TCnScriptFileNotify.Create(NotifyCode, FileName);
  try
    for i := 0 to FScripts.Count - 1 do
      if FScripts[i].Enabled and (Event.Mode in FScripts[i].Mode) and
        (NotifyCode in FScripts[i].FileNotifyCode) and
        FileExists(FScripts[i].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[i].FileName, Event);
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
  i: Integer;
begin
  Event := TCnScriptSourceEditorNotify.Create(SourceEditor, NotifyType, EditView);
  try
    for i := 0 to FScripts.Count - 1 do
      if FScripts[i].Enabled and (Event.Mode in FScripts[i].Mode) and
        (NotifyType in FScripts[i].SourceEditorNotifyType) and
        FileExists(FScripts[i].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[i].FileName, Event);
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
  i: Integer;
begin
  Event := TCnScriptFormEditorNotify.Create(FormEditor, NotifyType, Component,
    OldName, NewName);
  try
    for i := 0 to FScripts.Count - 1 do
      if FScripts[i].Enabled and (Event.Mode in FScripts[i].Mode) and
        (NotifyType in FScripts[i].FormEditorNotifyType) and
        FileExists(FScripts[i].FileName) then
      begin
        FMgr.ExecuteScript(FScripts[i].FileName, Event);
      end;
  finally
    Event.Free;
  end;          
end;

initialization
  RegisterCnWizard(TCnScriptWizard); // 注册专家

{$ENDIF}

{$ENDIF CNWIZARDS_CNSCRIPTWIZARD}
end.
