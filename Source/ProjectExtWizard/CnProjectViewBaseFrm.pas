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

unit CnProjectViewBaseFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程扩展工具窗体列表单元列表基类
* 单元作者：Leeon (real-like@163.com); 张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.5
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.02.22 V1.1
*               重写所有代码
*           2004.02.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, 
  ImgList, Contnrs, ActnList, 
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF COMPILER6_UP}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni, CnWizIdeUtils,
  CnWizMultiLang, CnWizShareImages, CnWizNotifier, CnIniStrUtils;

type

//==============================================================================
// 工程信息类
//==============================================================================

{ TCnProjectInfo }

  TCnProjectInfo = class
    Name: string;
    FileName: string;
    InfoList: TObjectList;
    constructor Create;
    destructor Destroy; override;
  end;

//==============================================================================
// 工程组单元窗体列表基类窗体
//==============================================================================

{ TCnProjectViewBaseForm }

  TCnProjectViewBaseForm = class(TCnTranslateForm)
    actAttribute: TAction;
    actClose: TAction;
    actCopy: TAction;
    actHelp: TAction;
    actHookIDE: TAction;
    ActionList: TActionList;
    actMatchAny: TAction;
    actMatchStart: TAction;
    actOpen: TAction;
    actQuery: TAction;
    actSelectAll: TAction;
    actSelectInvert: TAction;
    actSelectNone: TAction;
    cbbProjectList: TComboBox;
    edtMatchSearch: TEdit;
    lblProject: TLabel;
    lblSearch: TLabel;
    lvList: TListView;
    pnlHeader: TPanel;
    StatusBar: TStatusBar;
    btnMatchAny: TToolButton;
    btnAttribute: TToolButton;
    btnClose: TToolButton;
    btnCopy: TToolButton;
    btnHelp: TToolButton;
    btnHookIDE: TToolButton;
    btnOpen: TToolButton;
    btnQuery: TToolButton;
    btnSelectInvert: TToolButton;
    btnSelectAll: TToolButton;
    btnSep1: TToolButton;
    btnSep3: TToolButton;
    btnSep4: TToolButton;
    btnSep5: TToolButton;
    btnSep6: TToolButton;
    btnSep7: TToolButton;
    btnSep8: TToolButton;
    btnMatchStart: TToolButton;
    btnSelectNone: TToolButton;
    ToolBar: TToolBar;
    actFont: TAction;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    procedure lvListDblClick(Sender: TObject);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbbProjectListChange(Sender: TObject);
    procedure edtMatchSearchChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectNoneExecute(Sender: TObject);
    procedure actSelectInvertExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actAttributeExecute(Sender: TObject);
    procedure actMatchStartExecute(Sender: TObject);
    procedure actMatchAnyExecute(Sender: TObject);
    procedure actQueryExecute(Sender: TObject);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actHookIDEExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListKeyPress(Sender: TObject; var Key: Char);
    procedure lvListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FSortIndex: Integer;
    FSortDown: Boolean;
    FListViewWidthStr: string;
    FProjectListSelectedAllProject: Boolean;
    function GetMatchAny: Boolean;
    procedure SetMatchAny(const Value: Boolean);

    procedure FirstUpdate(Sender: TObject);
  protected
    NeedInitProjectControls: Boolean;
    ProjectList: TObjectList;
    CurrList: TList;
    function DoSelectOpenedItem: string; virtual; abstract;
    procedure DoSelectItemChanged(Sender: TObject); virtual;
    procedure DoUpdateListView; virtual; abstract;
    procedure DoSortListView; virtual;
    {* 供子类重载用，被 UpdateListView 调用}
    function GetSelectedFileName: string; virtual; abstract;
    procedure CreateList; virtual;
    {* 窗体 OnCreate 时被第一个调用，用来初始化数据 }
    procedure UpdateComboBox; virtual;
    {* 窗体 OnCreate 时被第二个调用，用来初始化 ComboBox 中的内容}
    procedure UpdateListView; virtual;
    {* 窗体 OnCreate 时被第三个调用，用来更新 ListView 中的内容，同时还在其他响应输入的地方调用}
    procedure UpdateStatusBar; virtual;
    procedure OpenSelect; virtual; abstract;
    procedure FontChanged(AFont: TFont); virtual;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); virtual; abstract;
    procedure SelectFirstItem;
    procedure SelectItemByIndex(Index: Integer);
    procedure LoadProjectSettings(Ini: TCustomIniFile; aSection: string);
    procedure SaveProjectSettings(Ini: TCustomIniFile; aSection: string);
  public
    procedure SelectOpenedItem;
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string); virtual;
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string); virtual;
    property SortIndex: Integer read FSortIndex write FSortIndex;
    property SortDown: Boolean read FSortDown write FSortDown;
    property MatchAny: Boolean read GetMatchAny write SetMatchAny;
  end;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

//==============================================================================
// 工程信息类
//==============================================================================

{ TCnProjectInfo }

constructor TCnProjectInfo.Create;
begin
  InfoList := TObjectList.Create;
end;

destructor TCnProjectInfo.Destroy;
begin
  FreeAndNil(InfoList);
  inherited Destroy;
end;

//==============================================================================
// 工程组单元窗体列表基类窗体
//==============================================================================

{ TCnProjectViewBaseForm }

procedure TCnProjectViewBaseForm.FormCreate(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    lvList.DoubleBuffered := True;
    ProjectList := TObjectList.Create;
    CurrList := TList.Create;
    NeedInitProjectControls := True;
    CreateList;
    UpdateComboBox;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCnProjectViewBaseForm.FormShow(Sender: TObject);
begin
  UpdateListView;
  SelectOpenedItem;
{$IFDEF BDS}
  SetListViewWidthString(lvList, FListViewWidthStr);
{$ENDIF}
  CnWizNotifierServices.ExecuteOnApplicationIdle(FirstUpdate);
end;

procedure TCnProjectViewBaseForm.FormDestroy(Sender: TObject);
begin
  CnWizNotifierServices.StopExecuteOnApplicationIdle(DoSelectItemChanged);
  ProjectList.Free;
  CurrList.Free;
end;

procedure TCnProjectViewBaseForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    lvListDblClick(Sender);
    Key := #0;
  end
  else if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end
  else if Key = #22 then // Ctrl + V
  begin
    if edtMatchSearch.Focused then
    begin
      if Clipboard.HasFormat(CF_TEXT) then
      begin
        edtMatchSearch.PasteFromClipboard;
        edtMatchSearch.Text := Trim(edtMatchSearch.Text);
        Key := #0;
      end;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actSelectAll.Enabled := lvList.Items.Count > 0;
  actSelectNone.Enabled := lvList.Items.Count > 0;
  actSelectInvert.Enabled := lvList.Items.Count > 0;

  actOpen.Enabled := lvList.SelCount > 0;
  actAttribute.Enabled := lvList.SelCount > 0;
  actCopy.Enabled := lvList.SelCount > 0;

  Handled := True;
end;

procedure TCnProjectViewBaseForm.actCopyExecute(Sender: TObject);
var
  i: Integer;
  AList: TStringList;
begin
  AList := TStringList.Create;
  try
    with lvList do
    begin
      for i := 0 to Pred(Items.Count) do
        if Items.Item[i].Selected and (Items.Item[i].Caption <> '') then
          AList.Add(Items[i].Caption);
    end;
  finally
    if AList.Count > 0 then
      Clipboard.AsText := TrimRight(AList.Text);
    FreeAndNil(AList);
  end;
end;

procedure TCnProjectViewBaseForm.actSelectAllExecute(Sender: TObject);
var
  i: Integer;
begin
  with lvList do
    for i := 0 to Pred(Items.Count) do
      Items[i].Selected := True;
end;

procedure TCnProjectViewBaseForm.actSelectNoneExecute(Sender: TObject);
begin
  lvList.Selected := nil;
end;

procedure TCnProjectViewBaseForm.actSelectInvertExecute(Sender: TObject);
var
  i: Integer;
begin
  with lvList do
    for i := Pred(Items.Count) downto 0 do
      Items[i].Selected := not Items[i].Selected;
end;

procedure TCnProjectViewBaseForm.actAttributeExecute(Sender: TObject);
var
  FileName: string;
begin
  FileName := GetSelectedFileName;

  if FileExists(FileName) then
    FileProperties(FileName)
  else
    InfoDlg(SCnProjExtFileNotExistOrNotSave, SCnInformation, 64);
end;

procedure TCnProjectViewBaseForm.actOpenExecute(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnProjectViewBaseForm.actHookIDEExecute(Sender: TObject);
begin
  actHookIDE.Checked := not actHookIDE.Checked;
end;

procedure TCnProjectViewBaseForm.actMatchStartExecute(Sender: TObject);
begin
  MatchAny := False;
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.actMatchAnyExecute(Sender: TObject);
begin
  MatchAny := True;
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.FontChanged(AFont: TFont);
begin

end;

procedure TCnProjectViewBaseForm.actFontExecute(Sender: TObject);
begin
  dlgFont.Font := lvList.Font; 
  if dlgFont.Execute then
  begin
    lvList.ParentFont := False;
    lvList.Font := dlgFont.Font;
    FontChanged(dlgFont.Font);
  end;
end;

procedure TCnProjectViewBaseForm.actQueryExecute(Sender: TObject);
begin
  actQuery.Checked := not actQuery.Checked;
end;

procedure TCnProjectViewBaseForm.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCnProjectViewBaseForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not (((Key = VK_F4) and (ssAlt in Shift)) or
    (Key in [VK_DELETE, VK_LEFT, VK_RIGHT]) or
    ((Key in [VK_HOME, VK_END]) and not (ssCtrl in Shift)) or
    ((Key in [VK_INSERT]) and ((ssShift in Shift) or (ssCtrl in Shift)))) then
  begin
    SendMessage(lvList.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
  end;
end;

procedure TCnProjectViewBaseForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnProjectViewBaseForm.GetMatchAny: Boolean;
begin
  Result := actMatchAny.Checked;
end;

procedure TCnProjectViewBaseForm.SetMatchAny(const Value: Boolean);
begin
  actMatchAny.Checked := Value;
  actMatchStart.Checked := not Value;
end;

procedure TCnProjectViewBaseForm.DoSortListView;
begin
  lvList.CustomSort(nil, 0);
end;

procedure TCnProjectViewBaseForm.lvListColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;
  DoSortListView;
end;

procedure TCnProjectViewBaseForm.lvListDblClick(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnProjectViewBaseForm.cbbProjectListChange(Sender: TObject);
begin
  if Sender is TComboBox then
  begin
    if TComboBox(Sender).ItemIndex = cbbProjectList.Items.IndexOf(SCnProjExtCurrentProject) then
    begin
      FProjectListSelectedAllProject := False;
    end
    else if TComboBox(Sender).ItemIndex = cbbProjectList.Items.IndexOf(SCnProjExtProjectAll) then
    begin
      FProjectListSelectedAllProject := True;
    end;
  end;
  if Visible then
  begin
    UpdateListView;
    SelectOpenedItem;
  end;
end;

const
  csMatchAny = 'MatchAny';
  csFont = 'Font';
  csSortIndex = 'SortIndex';
  csSortDown = 'SortDown';
  csCurrentPrj = 'SelectCurrentProject';
  csHookIDE = 'HookIDE';
  csOpenMultiUnitQuery = 'Query';
  csWidth = 'Width';
  csHeight = 'Height';
  csListViewWidth = 'ListViewWidth';

procedure TCnProjectViewBaseForm.LoadProjectSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  with Ini do
  begin
    if ReadBool(aSection, csCurrentPrj, False) then
    begin
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtCurrentProject);
      cbbProjectListChange(nil);
    end
    else
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtProjectAll);

    actHookIDE.Checked := ReadBool(aSection, csHookIDE, True);
    actQuery.Checked := ReadBool(aSection, csOpenMultiUnitQuery, True);
  end;
end;

procedure TCnProjectViewBaseForm.SaveProjectSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  with Ini do
  begin
    if not FProjectListSelectedAllProject then
      WriteBool(aSection, csCurrentPrj, True)
    else
      WriteBool(aSection, csCurrentPrj, False);

    WriteBool(aSection, csHookIDE, actHookIDE.Checked);
    WriteBool(aSection, csOpenMultiUnitQuery, actQuery.Checked);
  end;
end;

procedure TCnProjectViewBaseForm.LoadSettings(Ini: TCustomIniFile; aSection: string);
var
  sFont: string;
begin
  with TCnIniFile.Create(Ini) do
  try
    MatchAny := ReadBool(aSection, csMatchAny, True);
    sFont := ReadString(aSection, csFont, '');
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ReadFont: ' + sFont);
    CnDebugger.LogMsg('SelfFont: ' + FontToString(Self.Font));
{$ENDIF DEBUG}
    if (sFont <> '') and (sFont <> FontToString(Self.Font)) then
    begin
      // 只有保存的字体不等于窗体字体的时候，也即用户设置过字体后，才载入
      lvList.ParentFont := False;
      lvList.Font := ReadFont(aSection, csFont, lvList.Font);
      dlgFont.Font := lvList.Font;
      FontChanged(dlgFont.Font);
    end;

    FSortIndex := ReadInteger(aSection, csSortIndex, 0);
    FSortDown := ReadBool(aSection, csSortDown, False);
    lvList.CustomSort(nil, 0); // 按保存的设置排序

    Width := ReadInteger(aSection, csWidth, Width);
    Height := ReadInteger(aSection, csHeight, Height);
    CenterForm(Self);
    
    FListViewWidthStr := ReadString(aSection, csListViewWidth, '');
    SetListViewWidthString(lvList, FListViewWidthStr);
  finally
    Free;
  end;

  if NeedInitProjectControls then
    LoadProjectSettings(Ini, aSection);
end;

procedure TCnProjectViewBaseForm.SaveSettings(Ini: TCustomIniFile; aSection: string);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool(aSection, csMatchAny, MatchAny);
    WriteInteger(aSection, csSortIndex, FSortIndex);
    WriteBool(aSection, csSortDown, FSortDown);

    // 如用户没设置过字体，ParentFont 会为 True，无论语言如何切换总会跟随变化
    if not lvList.ParentFont then
      WriteFont(aSection, csFont, lvList.Font)
    else
      WriteString(aSection, csFont, '');

    WriteInteger(aSection, csWidth, Width);
    WriteInteger(aSection, csHeight, Height);
    WriteString(aSection, csListViewWidth, GetListViewWidthString(lvList));
  finally
    Free;
  end;

  if NeedInitProjectControls then
    SaveProjectSettings(Ini, aSection);
end;

procedure TCnProjectViewBaseForm.UpdateStatusBar;
begin

end;

procedure TCnProjectViewBaseForm.SelectFirstItem;
begin
  with lvList do
  begin
    Selected := nil;
    Selected := Items[0];
    ItemFocused := Selected;
  end;
end;

procedure TCnProjectViewBaseForm.SelectOpenedItem;
var
  i: Integer;
  aCurrentName: string;
begin
  with lvList do
  begin
    if Items.Count = 0 then
      Exit;

    aCurrentName := DoSelectOpenedItem;
    SelectFirstItem;

    if aCurrentName = '' then
      Exit;

    for i := 0 to Pred(Items.Count) do
      if AnsiSameText(Items[i].Caption, aCurrentName) then
      begin
        Selected := nil;
        Items[i].Selected := True;
        ItemFocused := Selected;
        Selected.MakeVisible(False);
        Break;
      end;
  end;
end;

procedure TCnProjectViewBaseForm.UpdateComboBox;
begin

end;

procedure TCnProjectViewBaseForm.CreateList;
begin

end;

procedure TCnProjectViewBaseForm.UpdateListView;
begin
  DoUpdateListView;
  // RemoveListViewSubImages(lvList);
end;

procedure TCnProjectViewBaseForm.DoSelectItemChanged(Sender: TObject);
begin
  UpdateStatusBar;
  StatusBar.Invalidate;
end;

procedure TCnProjectViewBaseForm.edtMatchSearchChange(Sender: TObject);
begin
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.lvListCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DrawListItem(Sender, Item);
end;

procedure TCnProjectViewBaseForm.lvListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoSelectItemChanged);
end;

procedure TCnProjectViewBaseForm.SelectItemByIndex(Index: Integer);
begin
  with lvList do
  begin
    if (Index >= 0) and (Index < Items.Count) then
    begin
      Selected := nil;
      Selected := Items[Index];
      ItemFocused := Selected;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
const
  CNCOPY_SPLITER  = #9;     // TAB
  CNCOPY_LINE     = #13#10;
var
  I, J: Integer;
  CopyBuf: string;
begin
  if lvList.MultiSelect then
  begin
    if Shift = [ssCtrl] then
    begin
      // 选择全部
      if Key = Ord('A') then
      begin
        lvList.Items.BeginUpdate;
        try
          for I := 0 to lvList.Items.Count - 1 do
            lvList.Items[I].Selected := True;
        finally
          lvList.Items.EndUpdate;
        end;
        Key := 0;
      end
      // 取消选择
      else if Key = Ord('D') then
      begin
        lvList.Items.BeginUpdate;
        try
          for I := 0 to lvList.Items.Count - 1 do
            lvList.Items[I].Selected := False;
        finally
          lvList.Items.EndUpdate;
        end;
        Key := 0;
      end
      // 复制文本
      // 现为初步功能，复制所有文字，日后可实现可选列
      else if Key = Ord('C') then
      begin
        if edtMatchSearch.Focused and (edtMatchSearch.SelText <> '') then
          Exit; // 有选择时不进行额外的复制

        if lvList.Selected <> nil then
        begin
          CopyBuf := '';

          // 产生标题
          for I := 0 to lvList.Columns.Count - 1 do
          begin
            CopyBuf := CopyBuf + lvList.Column[I].Caption;
            if I < lvList.Columns.Count - 1 then
              CopyBuf := CopyBuf + CNCOPY_SPLITER;
          end;
          CopyBuf := CopyBuf + CNCOPY_LINE;

          // 复制内容
          for I := 0 to lvList.Items.Count - 1 do
          begin
            if lvList.Items[I].Selected then
            begin
              CopyBuf := CopyBuf + lvList.Items[I].Caption;
              for J := 0 to lvList.Items[I].SubItems.Count - 1 do
                CopyBuf := CopyBuf + CNCOPY_SPLITER + lvList.Items[I].SubItems[J];
              CopyBuf := CopyBuf + CNCOPY_LINE;
            end;
          end;

          // 放入剪贴板
          Clipboard.Clear;
          Clipboard.SetTextBuf(PChar(CopyBuf));
        end
        else
        begin
          // 这里可以增加提示没有选择需要复制的内容
        end;  // if lvList.Selected <> nil
      end;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.lvListKeyPress(Sender: TObject;
  var Key: Char);
begin
  if CharInSet(Key, ['0'..'9', 'a'..'z', 'A'..'Z']) then
  begin
    PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      edtMatchSearch.SetFocus;
    except
      ;
    end;
    Key := #0;
  end;
end;

procedure TCnProjectViewBaseForm.lvListKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_BACK] then
  begin
    //PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      edtMatchSearch.SetFocus;
    except
      ;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.FirstUpdate(Sender: TObject);
begin
  lvList.Update;
end;

end.
