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

unit CnRoFilesList;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开文件主窗口单元
* 单元作者：Leeon (real-like@163.com);
* 备    注：打开历史文件专家主窗体
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2004-12-12 V1.1
*               去除 TIniContainer 处理，改为用 IRoOptions 接口处理。
*           2004-03-02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ToolWin, ExtCtrls, IniFiles, ImgList, ActnList,
  Menus,
  CnWizMultiLang, CnWizShareImages, CnRoOptions, CnRoFrmFileList,CnRoClasses,
  CnRoInterfaces;

type

  TRecentFileType = (rfBPG, rfDPR, rfPAS, rfDPK, rfOther);

  TCnFilesListForm = class(TCnTranslateForm)
    actDelete: TAction;
    actExit: TAction;
    actFav: TAction;
    actHelp: TAction;
    actlstMain: TActionList;
    actOpen: TAction;
    actOptions: TAction;
    btnDelete: TToolButton;
    btnExit: TToolButton;
    btnFavorite: TToolButton;
    btnHelp: TToolButton;
    btnOpen: TToolButton;
    btnOptions: TToolButton;
    clbr1: TCoolBar;
    frBPG: TRecentFilesFrame;
    frDPK: TRecentFilesFrame;
    frDPR: TRecentFilesFrame;
    frFAV: TRecentFilesFrame;
    frOTH: TRecentFilesFrame;
    frPAS: TRecentFilesFrame;
    ilProjectImages: TImageList;
    pnlFrame: TPanel;
    Splitter1: TSplitter;
    tlb1: TToolBar;
    tvMenu: TTreeView;
    procedure actDeleteExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actFavExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actlstMainUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actOpenExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure frOTHMenuItem3Click(Sender: TObject);
    procedure frOTHN2Click(Sender: TObject);
    procedure tvMenuChange(Sender: TObject; Node: TTreeNode);
    procedure tvMenuCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure tvMenuDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvMenuDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept:
            Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FActiveFrame: TRecentFilesFrame;
    FOptions: ICnRoOptions;
    procedure AddToFavorites(Source: TListView);
    procedure MoveMenu(var Key: Word);
    procedure ReadFiles(AFrame: TFrame; ASection: string);
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function GetHelpTopic: string; override;
  public
    constructor Create(AOptions: ICnRoOptions); reintroduce;
    destructor Destroy; override;
    property Options: ICnRoOptions read FOptions write FOptions;
  end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{$R *.DFM}

uses
  ToolsAPI, CnCommon, CnRoWizard, CnLangMgr, CnWizOptions;

{***************************** TCnFilesListForm *******************************}

constructor TCnFilesListForm.Create(AOptions: ICnRoOptions);
begin
  inherited Create(nil);
  FOptions := AOptions;
end;

destructor TCnFilesListForm.Destroy;
begin
  FOptions := nil;
  CnRoWizard.FormOpened := False;
  inherited Destroy;
end;

procedure TCnFilesListForm.actDeleteExecute(Sender: TObject);
begin
  if FActiveFrame.lvFile.SelCount > 0 then
    FActiveFrame.DeleteSelectedItems;
end;

procedure TCnFilesListForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnFilesListForm.actFavExecute(Sender: TObject);
begin
  if FActiveFrame.lvFile.SelCount > 0 then
    AddToFavorites(FActiveFrame.lvFile);
end;

procedure TCnFilesListForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnFilesListForm.actlstMainUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  if (Action = actOpen) or (Action = actDelete) or (Action = actFav) then
    (Action as TAction).Enabled := Self.FActiveFrame.lvFile.SelCount > 0;
  Handled := True;
end;

procedure TCnFilesListForm.actOpenExecute(Sender: TObject);
begin
  if FActiveFrame.lvFile.SelCount > 0 then
    FActiveFrame.OpenSelectedItems;
end;

procedure TCnFilesListForm.actOptionsExecute(Sender: TObject);
begin
  with TCnRoOptionsDlg.Create(Self) do
  begin
    try
      SetMemento;
      if ShowModal = mrOK then
        GetMemento;
    finally
      Free;
    end;
  end;
end;

procedure TCnFilesListForm.AddToFavorites(Source: TListView);
var
  j, Index: Integer;
  Files: ICnRoFiles;
  DroppedFile: string;
begin
  Files := FOptions.Files[SFavorite];
  DroppedFile := TListView(Source).Selected.SubItems[0]
    + TListView(Source).Selected.Caption;
  
  Index := Files.IndexOf(DroppedFile);
  if Index <> -1 then Exit;
  if (Files.Count > 0) then
  begin
    if Files.Capacity <= Files.Count then
    begin
      if Files.Count = Files.Capacity then
      begin
        Files.Delete(0);
      end
      else
        for j := 0 to (Files.Count - Files.Capacity) do
        begin
          Files.Delete(j);
        end;
    end;
    Files.AddFile(DroppedFile);
    with frFAV.lvFile.Items.Add do
    begin
      ImageIndex := 2;
      Caption := TListView(Source).Selected.Caption;
      SubItems.Add(TListView(Source).Selected.SubItems[0]);
    end;
  end
  else
  begin
    Files.AddFile(DroppedFile);
    with frFAV.lvFile.Items.Add do
    begin
      ImageIndex := 2;
      Caption := TListView(Source).Selected.Caption;
      SubItems.Add(TListView(Source).Selected.SubItems[0]);
    end;
  end;
end;

procedure TCnFilesListForm.DoLanguageChanged(Sender: TObject);
begin
  try
    if CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageID = 1033 then
    begin
      Self.tlb1.ShowCaptions := False;
      Self.tlb1.ShowCaptions := True;
    end;
  except
    ;
  end;
end;

procedure TCnFilesListForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FOptions.SortPersistance then
  begin
    frBPG.SetSortMemento;
    frDPR.SetSortMemento;
    frPAS.SetSortMemento;
    frDPK.SetSortMemento;
    frOTH.SetSortMemento;
    frFAV.SetSortMemento;
  end;
  FOptions.SaveAll;
  Action := caFree;
end;

procedure TCnFilesListForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  WizOptions.ResetToolbarWithLargeIcons(tlb1);

  ReadFiles(frBPG, SProjectGroup);
  ReadFiles(frDPR, SProject);
  ReadFiles(frPAS, SUnt);
  ReadFiles(frDPK, SPackge);
  ReadFiles(frOTH, SOther);
  ReadFiles(frFAV, SFavorite);
  
  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TRecentFilesFrame) then
    begin
      with TRecentFilesFrame(Components[I]) do
      begin
        if FOptions.SortPersistance then
          GetSortMemento;
        if lvFile.Items.Count > 0 then
          lvFile.Items[0].Selected := True;
      end;
    end;
  end; //end for
end;

procedure TCnFilesListForm.FormShow(Sender: TObject);
begin
  with tvMenu do
  begin
    Items[1].Data := frBPG;
    Items[2].Data := frDPR;
    Items[3].Data := frPAS;
    Items[4].Data := frDPK;
    Items[5].Data := frOTH;
    Items[6].Data := frFAV;
  end; //end with
  
  tvMenu.FullExpand;
  tvMenu.Items[FOptions.DefaultPage + 1].Selected := True;
  tvMenu.OnChange(tvMenu, tvMenu.Items[FOptions.DefaultPage + 1]);
  frFAV.lvFile.DragMode := dmManual;
  
  ActiveControl := FActiveFrame.lvFile;
  with FActiveFrame.lvFile do
    if Items.Count >  0 then
    begin
      SetFocus;
      Items[0].Selected := True;
      Items[0].Focused := True;
    end;
end;

procedure TCnFilesListForm.frOTHMenuItem3Click(Sender: TObject);
begin
  frOTH.actOpenFolderExecute(Sender);
end;

procedure TCnFilesListForm.frOTHN2Click(Sender: TObject);
begin
  inherited;
  frOTH.actOpenFileExecute(Sender);
end;

function TCnFilesListForm.GetHelpTopic: string;
begin
  Result := 'CnReopenFiles';
end;

procedure TCnFilesListForm.ReadFiles(AFrame: TFrame; ASection: string);
var
  I: Integer;
  Files: ICnRoFiles;
begin
  Files := FOptions.Files[ASection];
  TRecentFilesFrame(AFrame).Files := Files;
  with TRecentFilesFrame(AFrame).lvFile do
  begin
    Items.Clear;
    for I := 0 to Files.Count - 1 do
    begin
      with Items.Add, PCnRoFileEntry(Files.Nodes[I])^ do
      begin
        ImageIndex := 2;
        Caption := _CnExtractFileName(FileName);
        SubItems.Add(_CnExtractFilePath(FileName));
        if OpenedTime <> '' then
          SubItems.Add(OpenedTime)
        else
          SubItems.Add(' ');
        if ClosingTime <> '' then
          SubItems.Add(ClosingTime)
        else
          SubItems.Add(' ');
      end;
    end;
  end;
end;

procedure TCnFilesListForm.tvMenuChange(Sender: TObject; Node: TTreeNode);
begin
  if (Node = tvMenu.TopItem) then Exit;
  TRecentFilesFrame(Node.Data).BringToFront;
  FActiveFrame := TRecentFilesFrame(Node.Data);
end;

procedure TCnFilesListForm.tvMenuCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse:
        Boolean);
begin
  AllowCollapse := Node.Index <> 0;
end;

procedure TCnFilesListForm.tvMenuDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if (TTreeNode(tvMenu.GetNodeAt(X, Y)).AbsoluteIndex = 6) and (Source is TListView) then
    AddToFavorites(Source as TListView);
end;

procedure TCnFilesListForm.tvMenuDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := False;
  if (tvMenu.GetNodeAt(X, Y) = nil) then Exit;
  if (TTreeNode(tvMenu.GetNodeAt(X, Y)).AbsoluteIndex = 6) and (Source is TListView) then
    Accept := True;
end;

procedure TCnFilesListForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;

  if Key in [VK_LEFT, VK_RIGHT] then
    MoveMenu(Key);

  if Key in [VK_SPACE, VK_RETURN] then
    FActiveFrame.lvFile.SetFocus;
end;

procedure TCnFilesListForm.MoveMenu(var Key: Word);
begin
  with tvMenu do
    if Key = VK_LEFT then
    begin
      if Selected = nil then
        tvMenu.Items.GetFirstNode.Selected := True
      else begin
        if Selected.getPrevSibling <> nil then
          Selected.getPrevSibling.Selected := True
        else if Selected.HasChildren then
          Selected.getFirstChild.Selected := True;
      end;
    end else
    if Key = VK_RIGHT then
    begin
      if Selected = nil then
        tvMenu.Items.GetFirstNode.Selected := True
      else begin
        if Selected.getNextSibling <> nil then
          selected.getNextSibling.Selected := True
        else if Selected.HasChildren then
          Selected.GetLastChild.Selected := True;
      end;
    end;
  FActiveFrame.lvFile.SetFocus;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.





