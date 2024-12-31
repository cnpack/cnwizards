{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnPrefixCompFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家组件列表窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家组件列表窗体单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.04.28 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Contnrs, ToolsAPI, CnCommon, CnPrefixList, CnWizUtils,
  CnWizConsts, CnWizMultiLang, IniFiles;

type

{ TCnPrefixCompForm }

  TCnPrefixCompForm = class(TCnTranslateForm)
    gbList: TGroupBox;
    ListView: TListView;
    lbl1: TLabel;
    edtNewName: TEdit;
    btnModify: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure edtNewNameKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtNewNameEnter(Sender: TObject);
    procedure edtNewNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FList: TCnPrefixCompList;
    FSortIndex: Integer;
    FSortDown: Boolean;
    procedure SetListToListView;
    procedure UpdateListToListView(Sender: TObject);
    procedure GetListFromListView;
    procedure UpdateNameEdit;
  protected
    function GetHelpTopic: string; override;
  public

  end;

function ShowPrefixCompForm(List: TCnPrefixCompList; IniFile: TCustomIniFile;
  var UpdateTrigger: TNotifyEvent): Boolean;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{$R *.DFM}

uses
  CnWizManager, CnPrefixWizard, CnWizOptions;

const
  aSection = 'CnPrefixCompForm';
  csWidth = 'Width';
  csHeight = 'Height';
  csListViewWidth = 'ListViewWidth';

function ShowPrefixCompForm(List: TCnPrefixCompList; IniFile: TCustomIniFile;
  var UpdateTrigger: TNotifyEvent): Boolean;
var
  Frm: TCnPrefixCompForm;
begin
  Frm := TCnPrefixCompForm.Create(nil);
  with Frm, IniFile do
  try
    FList := List;
    Width := ReadInteger(aSection, csWidth, Width);
    Height := ReadInteger(aSection, csHeight, Height);
    CenterForm(Frm);
    SetListViewWidthString(ListView, ReadString(aSection, csListViewWidth, ''),
      GetFactorFromSizeEnlarge(Enlarge));
    UpdateTrigger := UpdateListToListView;
    Result := ShowModal = mrOk;
    
    WriteInteger(aSection, csWidth, Width);
    WriteInteger(aSection, csHeight, Height);
    WriteString(aSection, csListViewWidth,
      GetListViewWidthString(ListView, GetFactorFromSizeEnlarge(Enlarge)));
  finally
    Frm.Free;
  end;
end;

{ TCnPrefixCompForm }

procedure TCnPrefixCompForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
    if not QueryDlg(SCnPrefixAskToProcess) then
      CanClose := False;
end;

procedure TCnPrefixCompForm.FormShow(Sender: TObject);
begin
  FSortIndex := 0;
  FSortDown := False;
  SetListToListView;
  if ListView.Items.Count > 0 then
  begin
    // 此处需要先发一个 VK_DOWN，否则用户在 Edit 中第一次按 Down 无效
    SendMessage(ListView.Handle, WM_KEYDOWN, VK_DOWN, 0);
    ListView.Selected := ListView.Items[0];
  end;
  edtNewName.SetFocus;
end;

function TCnPrefixCompForm.GetHelpTopic: string;
begin
  Result := 'CnPrefixCompForm';
end;

procedure TCnPrefixCompForm.SetListToListView;
var
  I: Integer;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for I := 0 to FList.Count - 1 do
    begin
      with ListView.Items.Add do
      begin
        Checked := FList[I].Active;
        Caption := FList[I].ProjectName;
        SubItems.Add(_CnExtractFileName(FList[I].FormEditor.FileName));
        SubItems.Add(FList[I].OldName);
        SubItems.Add(FList[I].Component.ClassName);
        SubItems.Add(CnGetComponentText(FList[I].Component));
        SubItems.Add(FList[I].Prefix);
        SubItems.Add(FList[I].NewName);
        Data := FList[I];
      end;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TCnPrefixCompForm.GetListFromListView;
var
  I: Integer;
begin
  for I := 0 to ListView.Items.Count - 1 do
  begin
    with TCnPrefixCompItem(ListView.Items[I].Data) do
    begin
      NewName := ListView.Items[I].SubItems[5];
      Active := (NewName <> '') and ListView.Items[I].Checked;
    end;
  end;
end;

procedure TCnPrefixCompForm.UpdateNameEdit;
begin
  if ListView.Selected <> nil then
  begin
    edtNewName.Text := ListView.Selected.SubItems[5];
    edtNewName.Enabled := True;
    btnModify.Enabled := True;
  end
  else
  begin
    edtNewName.Text := '';
    edtNewName.Enabled := False;
    btnModify.Enabled := False;
  end;
end;

procedure TCnPrefixCompForm.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  UpdateNameEdit;
end;

procedure TCnPrefixCompForm.btnModifyClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    if (edtNewName.Text = '') or IsValidIdent(edtNewName.Text) then
      ListView.Selected.SubItems[5] := edtNewName.Text
    else
      ErrorDlg(SCnPrefixNameError);
  end;
end;

procedure TCnPrefixCompForm.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;
  ListView.CustomSort(nil, 0);
end;

procedure TCnPrefixCompForm.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if FSortIndex <= 0 then
    Compare := CompareText(Item1.Caption, Item2.Caption)
  else
    Compare := CompareText(Item1.SubItems[FSortIndex - 1], Item2.SubItems[FSortIndex - 1]);
  if FSortDown then
    Compare := -Compare;
end;

procedure TCnPrefixCompForm.edtNewNameEnter(Sender: TObject);
var
  Prefix: string;
begin
  if (ListView.Selected <> nil) and (edtNewName.Text <> '') then
  begin
    Prefix := TCnPrefixCompItem(ListView.Selected.Data).Prefix;
    if (Prefix <> '') and (AnsiPos(Prefix, edtNewName.Text) = 1) then
    begin
      edtNewName.SelStart := Length(Prefix);
      edtNewName.SelLength := Length(edtNewName.Text) - Length(Prefix);
    end
    else
      edtNewName.SelectAll;
  end;
end;

procedure TCnPrefixCompForm.edtNewNameKeyPress(Sender: TObject;
  var Key: Char);
const
  Chars = ['A'..'Z', 'a'..'z', '_', '0'..'9', #08];
  EditChars = [#3, #22, #24, #26];  // Ctrl+C/V/X/Z
begin
  if Key = #13 then
  begin
    btnModifyClick(nil);
    if (edtNewName.Text = '') or IsValidIdent(edtNewName.Text) then
      if ListView.Selected.Index < ListView.Items.Count - 1 then
      begin
        ListView.Selected := ListView.Items[ListView.Selected.Index + 1];
        edtNewName.SetFocus;
      end
      else
        btnOK.SetFocus;
    Key := #0;
  end
  else if not CharInSet(Key, Chars + EditChars) and not IsValidIdent('A' + Key) then
    Key := #0;
end;

procedure TCnPrefixCompForm.btnOKClick(Sender: TObject);
begin
  GetListFromListView;
  ModalResult := mrOk;
end;

procedure TCnPrefixCompForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnPrefixCompForm.edtNewNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
  begin
    SendMessage(ListView.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
    edtNewName.SetFocus;
  end;
end;

procedure TCnPrefixCompForm.UpdateListToListView(Sender: TObject);
var
  I: Integer;
  RenameList: TList;
  FormEditor: IOTAFormEditor;
  Wizard: TCnPrefixWizard;
  ProjectName: string;
begin
  if Sender <> nil then
  begin
    // 如果 Sender 不为空，说明是被迟来的调用的，为一 RenameList，
    // 在此用 RenameList 更新 FList
    RenameList := Sender as TList;
    FormEditor := CnOtaGetCurrentFormEditor;
    Wizard := TCnPrefixWizard(CnWizardMgr.WizardByClass(TCnPrefixWizard));
    if Wizard = nil then
      Exit;

    // 取工程名
    if Assigned(FormEditor.Module) and (FormEditor.Module.OwnerCount > 0) then
      ProjectName := _CnExtractFileName(FormEditor.Module.Owners[0].FileName)
    else
      ProjectName := '';

    for I := 0 to RenameList.Count - 1 do
    begin
      // 只有当前窗体上存在的组件才处理
      if FList.IndexOfComponent(FormEditor, TComponent(RenameList[I])) < 0 then
        if Assigned(FormEditor.GetComponentFromHandle(RenameList[I])) then
          Wizard.AddCompToList(ProjectName, FormEditor, TComponent(RenameList[I]), FList);
    end;

    SetListToListView;
    
    if ListView.Items.Count > 0 then
    begin
      // 此处需要先发一个 VK_DOWN，否则用户在 Edit 中第一次按 Down 无效
      SendMessage(ListView.Handle, WM_KEYDOWN, VK_DOWN, 0);
      ListView.Selected := ListView.Items[0];
    end;
    edtNewName.SetFocus;
  end;
end;

procedure TCnPrefixCompForm.FormCreate(Sender: TObject);
begin
//  EnlargeListViewColumns(ListView);
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
