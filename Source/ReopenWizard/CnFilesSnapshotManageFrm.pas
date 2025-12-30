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

unit CnFilesSnapshotManageFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组单元列表单元
* 单元作者：熊恒（beta） xbeta@tom.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：P2000Pro + Delphi 6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2007.08.02 V1.2
*               beta 文件列表改为非 virtual 方式以提供对 D5 的兼容
*           2007.08.01 V1.1
*               beta 文件列表支持鼠标拖拽、快捷键、工具按钮等方式改变顺序
*               合并添加快照窗口以实现功能代码共用，文件列表支持多选
*               新增添加文件名、编辑文件名等；界面优化及少量代码重构
*           2004.04.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CnWizMultiLang, CnCommon, CnWizConsts, CheckLst,
  ImgList, ActnList;

type

//==============================================================================
// 快照管理窗体
//==============================================================================

{ TCnProjectFilesSnapshotManageForm }

  TCnProjectFilesSnapshotManageForm = class(TCnTranslateForm)
    cbbSnapshots: TComboBox;
    lblSnapshots: TLabel;
    btnDelete: TButton;
    btnHelp: TButton;
    btnRemove: TButton;
    lstFiles: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    lblFiles: TLabel;
    ilFormIcons: TImageList;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    actlstFLS: TActionList;
    actSnapshotDelete: TAction;
    actFileMoveUp: TAction;
    actFileMoveDown: TAction;
    actFileRemove: TAction;
    actFileAdd: TAction;
    actFileEdit: TAction;
    actFormOk: TAction;
    dlgOpen: TOpenDialog;
    btnFileRemove: TButton;
    btnFileMoveDown: TButton;
    procedure actFileAddExecute(Sender: TObject);
    procedure actFileEditExecute(Sender: TObject);
    procedure actFileMoveDownExecute(Sender: TObject);
    procedure actFileMoveUpExecute(Sender: TObject);
    procedure actFileRemoveExecute(Sender: TObject);
    procedure actFormOkExecute(Sender: TObject);
    procedure actlstFLSUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actSnapshotDeleteExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure cbbSnapshotsChange(Sender: TObject);
    procedure lstFilesDblClick(Sender: TObject);
    procedure lstFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lstFilesDragOver(Sender, Source: TObject; X, Y: Integer; State:
      TDragState; var Accept: Boolean);
    procedure lstFilesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FFiles: TStrings;
    FManaging: Boolean;
    FSnapshots: TStrings;
    function lstFilesItemFmt(const AFileName: string): string;
    procedure lstFilesRefresh(AItem: Integer = -1);
    procedure lstFilesSetCount(ACount: Integer);
    function GetFirstSelectedIndex: Integer;
    function GetLastSelectedIndex: Integer;
    function GetUnselectedItemCount(AFrom, ATo: Integer): Integer;
    procedure MoveItems(Distance: Integer);
  protected
    function GetHelpTopic: string; override;
  public

  end;

// 显示添加文件快照界面，若用户取消则返回空字符串
function AddFilesSnapshot(Names, Files: TStrings): string;

// 显示管理文件快照界面，若用户取消修改则返回 False
function ManageFilesSnapshot(Snapshots: TStrings): Boolean;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{$R *.DFM}

function AddFilesSnapshot(Names, Files: TStrings): string;
begin
  Result := '';
  with TCnProjectFilesSnapshotManageForm.Create(nil) do
  try
    cbbSnapshots.Items.Assign(Names);
    FFiles := Files;
    lstFilesSetCount(FFiles.Count);

    if ShowModal = mrOK then
      Result := Trim(cbbSnapshots.Text);
  finally
    Free;
  end;
end;

function ManageFilesSnapshot(Snapshots: TStrings): Boolean;
begin
  with TCnProjectFilesSnapshotManageForm.Create(nil) do
  try
    FManaging := True;
    FSnapshots := Snapshots;
    cbbSnapshots.Items.Assign(Snapshots);
    if Snapshots.Count > 0 then
    begin
      cbbSnapshots.ItemIndex := 0;
      cbbSnapshotsChange(nil);
    end;

    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

//==============================================================================
// 快照管理窗体
//==============================================================================

{ TCnProjectFilesSnapshotManageForm }

procedure TCnProjectFilesSnapshotManageForm.FormShow(Sender: TObject);
begin
  if FManaging then
  begin // manage
    Caption := SCnFilesSnapshotManageFrmCaptionManage;
    ilFormIcons.GetIcon(0, Icon);
    lblSnapshots.Caption := SCnFilesSnapshotManageFrmLblSnapshotsCaptionManage;
    cbbSnapshots.Style := csDropDownList;
  end else
  begin // add
    Caption := SCnFilesSnapshotManageFrmCaptionAdd;
    ilFormIcons.GetIcon(1, Icon);
    lblSnapshots.Caption := SCnFilesSnapshotManageFrmLblSnapshotsCaptionAdd;
    cbbSnapshots.Style := csDropDown;
    cbbSnapshots.Width := cbbSnapshots.Width + 5 + btnDelete.Width;
    actSnapshotDelete.Visible := False;
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.actFileAddExecute(Sender: TObject);
begin
  if not Assigned(FFiles) then Exit;

  with dlgOpen do
  begin
    Options := Options + [ofAllowMultiSelect];
    if Execute then
    begin
      FFiles.AddStrings(Files);
      lstFilesSetCount(FFiles.Count);
    end;
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.actFileEditExecute(Sender: TObject);
begin
  if not Assigned(FFiles) or (lstFiles.ItemIndex < 0) then Exit;

  with dlgOpen do
  begin
    Options := Options - [ofAllowMultiSelect];
    FileName := FFiles[lstFiles.ItemIndex];
    if Execute then
      with lstFiles do
      begin
        FFiles[ItemIndex] := FileName;
        lstFilesRefresh(ItemIndex);
      end;
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.actFileMoveDownExecute(Sender:
  TObject);
begin
  if GetLastSelectedIndex < lstFiles.Items.Count - 1 then MoveItems(1);
end;

procedure TCnProjectFilesSnapshotManageForm.actFileMoveUpExecute(Sender:
  TObject);
begin
  if GetFirstSelectedIndex > 0 then MoveItems(-1);
end;

procedure TCnProjectFilesSnapshotManageForm.actFileRemoveExecute(Sender:
  TObject);
var
  i: Integer;
begin
  with lstFiles do
  begin
    for i := Items.Count - 1 downto 0 do
      if Selected[i] then
        FFiles.Delete(i);
    lstFilesSetCount(FFiles.Count);
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.actFormOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCnProjectFilesSnapshotManageForm.actlstFLSUpdate(Action:
  TBasicAction; var Handled: Boolean);
var
  SelCount: Integer;
begin
  SelCount := lstFiles.SelCount;
  actSnapshotDelete.Enabled := FManaging and (cbbSnapshots.ItemIndex >= 0);
  actFileMoveUp.Enabled := SelCount > 0;
  actFileMoveDown.Enabled := SelCount > 0;
  actFileRemove.Enabled := SelCount > 0;
  actFileAdd.Enabled := not FManaging or (cbbSnapshots.ItemIndex >= 0);
  actFileEdit.Enabled := SelCount = 1;
  actFormOk.Enabled := FManaging or (Trim(cbbSnapshots.Text) <> '');
end;

procedure TCnProjectFilesSnapshotManageForm.actSnapshotDeleteExecute(Sender:
  TObject);
var
  Index: Integer;
begin
  Index := cbbSnapshots.ItemIndex;
  if (Index >= 0) and (Index < FSnapshots.Count) then
  begin
    FSnapshots.Objects[Index].Free;
    FSnapshots.Delete(Index);
    cbbSnapshots.Items.Delete(Index);
  end
  else
    Exit;

  if FSnapshots.Count > 0 then
    cbbSnapshots.ItemIndex := 0
  else
    cbbSnapshots.Clear;
  cbbSnapshotsChange(cbbSnapshots);
end;

procedure TCnProjectFilesSnapshotManageForm.cbbSnapshotsChange(Sender: TObject);
var
  Index: Integer;
begin
  if FManaging then
  begin
    Index := cbbSnapshots.ItemIndex;
    if (Index >= 0) and (Index < FSnapshots.Count) then
    begin
      FFiles := TStrings(FSnapshots.Objects[Index]);
      lstFilesSetCount(FFiles.Count);
    end else
    begin
      FFiles := nil;
      lstFilesSetCount(0);
    end;
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnProjectFilesSnapshotManageForm.GetFirstSelectedIndex: Integer;
begin
  with lstFiles do
    for Result := 0 to Items.Count - 1 do
      if Selected[Result] then
        Exit;
  Result := -1;
end;

function TCnProjectFilesSnapshotManageForm.GetLastSelectedIndex: Integer;
begin
  with lstFiles do
    for Result := Items.Count - 1 downto 0 do
      if Selected[Result] then
        Exit;
  Result := -1;
end;

function TCnProjectFilesSnapshotManageForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtFileSnapshot';
end;

function TCnProjectFilesSnapshotManageForm.GetUnselectedItemCount(AFrom, ATo:
  Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  with lstFiles do
    if AFrom <= ATo then
      for i := AFrom to ATo do
        if not Selected[i] then
          Inc(Result)
        else
          // nothing
    else
      for i := AFrom downto ATo do
        if not Selected[i] then
          Dec(Result)
        else
          // nothing
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesDblClick(Sender: TObject);
begin
  actFileEdit.Execute;
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesDragDrop(Sender, Source:
  TObject; X, Y: Integer);
var
  NewIndex: Integer;
begin
  with lstFiles do
  begin
    if X < 0 then X := 0;
    if X > ClientWidth then X := ClientWidth;
    if Y < 0 then Y := 0;
    if Y > ClientHeight then Y := ClientHeight;
    NewIndex := ItemAtPos(Point(X, Y), True);
    if NewIndex < 0 then NewIndex := Items.Count - 1;

    if Selected[NewIndex] then Exit;

    MoveItems(GetUnselectedItemCount(GetFirstSelectedIndex, NewIndex));
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesDragOver(Sender, Source:
  TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = Source;
end;

function TCnProjectFilesSnapshotManageForm.lstFilesItemFmt(
  const AFileName: string): string;
begin
  Result :=
    Format('%s (%s)', [_CnExtractFileName(AFileName), _CnExtractFileDir(AFileName)]);
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  I: Integer;
begin
  if Key = VK_DELETE then
  begin
    Key := 0;
    actFileRemove.Execute;
  end else
  if (Key = Ord('A')) and (ssCtrl in Shift) then
  begin
    Key := 0;
    if lstFiles.MultiSelect then
      for I := 0 to lstFiles.Items.Count - 1 do
        lstFiles.Selected[I] := True;
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesRefresh(AItem: Integer = -1);

  procedure HandleItem(Index: Integer);
  var
    SavedSel: Boolean;
  begin
    with lstFiles do
    begin
      SavedSel := Selected[Index];
      Items[Index] := lstFilesItemFmt(FFiles[Index]);
      Selected[Index] := SavedSel;
    end;
  end;

var
  i: Integer;
begin
  Assert(lstFiles.Items.Count = FFiles.Count);

  if AItem >= 0 then
    HandleItem(AItem)
  else
    for i := 0 to FFiles.Count - 1 do
      HandleItem(i);
end;

procedure TCnProjectFilesSnapshotManageForm.lstFilesSetCount(
  ACount: Integer);
var
  i: Integer;
begin
  with lstFiles do
  begin
    Clear;
    for i := 0 to ACount - 1 do
      Items.AddObject(lstFilesItemFmt(FFiles[i]), nil);
  end;
end;

procedure TCnProjectFilesSnapshotManageForm.MoveItems(Distance: Integer);

  procedure HandleItem(Index: Integer);
  var
    NewIndex: Integer;
  begin
    with lstFiles do
      if Selected[Index] then
      begin
        NewIndex := Index + Distance;
        if NewIndex > Items.Count - 1 then
          NewIndex := Items.Count - 1;
        Selected[Index] := False;
        Selected[NewIndex] := True;
        FFiles.Move(Index, NewIndex);
      end;
  end;

var
  i: Integer;
begin
  with lstFiles do
  begin
    Items.BeginUpdate;
    try
      if Distance > 0 then
        for i := Items.Count - 1 downto 0 do
          HandleItem(i)
      else
        for i := 0 to Items.Count - 1 do
          HandleItem(i);
      lstFilesRefresh;
    finally
      Items.EndUpdate;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.
