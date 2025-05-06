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

unit CnRoFrmFileList;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开文件列表 Frame 单元
* 单元作者：Leeon (real-like@163.com);
* 备    注：打开历史文件文件列表Frame
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：
*           2005-05-04 V1.2 by hubdog
*               修改 ExploreDir 的使用为采用 ExploreFile
*           2004-12-12 V1.1
*               修改为 IRoOptions 处理
*           2004-03-02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, Menus, ShellAPI, Clipbrd, ImgList, ActnList, FileCtrl,
  CnRoInterfaces, CnPopupMenu;

type
  TCnRecentFilesFrame = class(TFrame)
    actCopyFolder: TAction;
    actCopyName: TAction;
    actlstFiles: TActionList;
    actOpenFile: TAction;
    actOpenFolder: TAction;
    ImageList1: TImageList;
    lvFile: TListView;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    pmList: TPopupMenu;
    procedure actCopyFolderExecute(Sender: TObject);
    procedure actCopyNameExecute(Sender: TObject);
    procedure actOpenFileExecute(Sender: TObject);
    procedure actOpenFolderExecute(Sender: TObject);
    procedure lvFileColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvFileCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvFileDblClick(Sender: TObject);
    procedure lvFileKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure actlstFilesUpdate(Action: TBasicAction;
      var Handled: Boolean);
  private
    ColumnToSort: Integer;
    FFiles: ICnRoFiles;
    SortOrder: Integer;
    procedure CloseForm(AFileName: string);
  public
    procedure DeleteSelectedItems;
    procedure GetSortMemento;
    procedure OpenSelectedItem;
    procedure OpenSelectedItems;
    procedure SetSortMemento;
    property Files: ICnRoFiles read FFiles write FFiles;
  end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{$R *.DFM}

uses
  ToolsAPI, CnWizShareImages, CnCommon, CnWizUtils;

{***************************** TRecentFilesFrame ******************************}

procedure TCnRecentFilesFrame.actCopyFolderExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvFile.SelCount > 0 then
  begin
    Clipboard.AsText := '';
    for I := 0 to lvFile.Items.Count - 1 do
    begin
      if lvFile.Items[I].Selected then
      begin
        if Clipboard.AsText = '' then
          Clipboard.AsText := lvFile.Items[I].SubItems[0]
        else
          Clipboard.AsText := Clipboard.AsText + #13#10 + lvFile.Items[I].SubItems[0];
      end;
    end;
  end;
end;

procedure TCnRecentFilesFrame.actCopyNameExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvFile.SelCount > 0 then
  begin
    Clipboard.AsText := '';
    for I := 0 to lvFile.Items.Count - 1 do
    begin
      if lvFile.Items[I].Selected then
      begin
        if Clipboard.AsText = '' then
          Clipboard.AsText := lvFile.Items[I].Caption
        else
          Clipboard.AsText := Clipboard.AsText + #13#10 + lvFile.Items[I].Caption;
      end;
    end;
  end;
end;

procedure TCnRecentFilesFrame.actOpenFileExecute(Sender: TObject);
begin
  if lvFile.SelCount > 0 then
    OpenSelectedItem;
end;

procedure TCnRecentFilesFrame.actOpenFolderExecute(Sender: TObject);
begin
  if lvFile.Selected <> nil then
  begin
    if FileExists(lvFile.Selected.SubItems[0]) then
      ExploreFile(lvFile.Selected.SubItems[0])
    else if DirectoryExists(_CnExtractFileDir(lvFile.Selected.SubItems[0])) then
      ExploreDir(_CnExtractFileDir(lvFile.Selected.SubItems[0]));
  end;
end;

procedure TCnRecentFilesFrame.CloseForm(AFileName: string);
begin
  // TODO: check favorate file is project's file then close form.
  if (IsProject(AFileName) or IsDpk(AFileName)
    or IsBdsProject(AFileName) or IsDProject(AFileName) or 
    IsCbProject(AFileName) or IsBpg(AFileName)) then
    TForm(Owner).Close
  else
    TForm(Owner).BringToFront;
end;

procedure TCnRecentFilesFrame.DeleteSelectedItems;
var
  I, J: Integer;
begin
  with lvFile do
  begin
    if SelCount > 1 then
    begin
      for I := Items.Count - 1 downto 0 do
      begin
        if Items[i].Selected then
        begin
          J := Files.IndexOf(Items[i].SubItems[0] + Items[i].Caption);
          if J > -1 then Files.Delete(J);
          Items.Delete(I);
        end;
      end;
      if (Items.Count <> 0) then
        Items[0].Selected := True;
    end
    else
    begin
      I := Selected.Index;
      J := Files.IndexOf(Selected.SubItems[0] + Selected.Caption);
      if J > -1 then Files.Delete(J);
      Selected.Delete;
      if Items.Count > I then
        Items.Item[I].Selected := True
      else if (Items.Count = i) and (I > 0) then
        Items.Item[I - 1].Selected := True;
    end;
  end;
end;

procedure TCnRecentFilesFrame.GetSortMemento;
var
  S: string;
  J: Integer;
begin
  S := Files.ColumnSorting;
  J := Pos(',', s);
  if J = 0 then
    J := Length(s) + 1;
  ColumnToSort := StrToIntDef(Copy(s, 1, J - 1), 1);
  S := Copy(S, J + 1, length(S));
  SortOrder := StrToIntDef(S, 1);
  lvFile.AlphaSort;
end;

procedure TCnRecentFilesFrame.lvFileColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvFile.Column[ColumnToSort].ImageIndex := -1;
  ColumnToSort := Column.Index;
  
  if Column.Tag = 0 then
  begin
    Column.Tag := 1;
    lvFile.Column[ColumnToSort].ImageIndex := 1;
  end
  else
  begin
    Column.Tag := 0;
    lvFile.Column[ColumnToSort].ImageIndex := 0;
  end;
  
  SortOrder := Column.Tag;
  try
    lvFile.AlphaSort;
  except
    ;
  end;
end;

procedure TCnRecentFilesFrame.lvFileCompare(Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  I: Integer;
begin
  if ColumnToSort = 0 then
  begin
    if SortOrder = 0 then
      Compare := CompareText(Item1.Caption, Item2.Caption)
    else
      Compare := CompareText(Item2.Caption, Item1.Caption)
  end
  else
  begin
    I := ColumnToSort - 1;
    if SortOrder = 0 then
      Compare := CompareText(Item1.SubItems[I], Item2.SubItems[I])
    else
      Compare := CompareText(Item2.SubItems[I], Item1.SubItems[I])
  end;
end;

procedure TCnRecentFilesFrame.lvFileDblClick(Sender: TObject);
begin
  actOpenFile.Execute;
end;

procedure TCnRecentFilesFrame.lvFileKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (lvFile.Selected = nil) or (lvFile.SelCount <= 0) then
    Exit;
  if Key = VK_DELETE then
    DeleteSelectedItems;
  if Key = VK_RETURN then
    OpenSelectedItems;
end;

procedure TCnRecentFilesFrame.OpenSelectedItem;
var
  S: string;
begin
  with lvFile do
  begin
    S := Selected.SubItems[0] + Selected.Caption;
    if FileExists(S) then
    begin
      if IsProject(S) then
        (BorlandIDEServices as IOTAActionServices).OpenProject(S, True)
      else
        (BorlandIDEServices as IOTAActionServices).OpenFile(S);
    end;
  end;
  CloseForm(S);
end;

procedure TCnRecentFilesFrame.OpenSelectedItems;
var
  I: Integer;
  S: string;
begin
  with lvFile do
  begin
    if SelCount > 1 then
    begin
      for I := Items.Count - 1 downto 0 do
      begin
        if Items[I].Selected then
        begin
          S := Items[I].SubItems[0] + Items[I].Caption;
          if FileExists(S) then
          begin
            (BorlandIDEServices as IOTAActionServices).OpenFile(S);
          end;
        end;
      end;
      CloseForm(S);
    end
    else
      OpenSelectedItem;
  end;
end;

procedure TCnRecentFilesFrame.SetSortMemento;
begin
  Files.ColumnSorting := IntToStr(ColumnToSort) + ',' + IntToStr(SortOrder);
end;

procedure TCnRecentFilesFrame.actlstFilesUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = actOpenFile) or (Action = actCopyFolder) or
    (Action = actOpenFolder) or (Action = actCopyName) then
    (Action as TAction).Enabled := lvFile.Selected <> nil;
    
  Handled := True;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.

