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

unit CnWizMenuSortFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：高级设置单元
* 单元作者：LiuXiao
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.08.02 V1.1
*               LiuXiao 加入是否创建专家的设置
*           2003.06.27 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ActnList, Menus, CheckLst, CnWizUtils, CnCommon,
  CnWizMultiLang;

type
  TCnMenuSortForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    ActionList: TActionList;
    UpAction: TAction;
    DownAction: TAction;
    ResetAction: TAction;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    lvMenuWizards: TListView;
    Label1: TLabel;
    btnReset: TBitBtn;
    btnDown: TBitBtn;
    btnUp: TBitBtn;
    TabSheet2: TTabSheet;
    Label2: TLabel;
    lvWizardCreate: TListView;
    actSelAll: TAction;
    actSelNone: TAction;
    actSelReverse: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure ResetActionExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure btnHelpClick(Sender: TObject);
    procedure UpActionExecute(Sender: TObject);
    procedure DownActionExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvMenuWizardsStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure lvMenuWizardsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvMenuWizardsDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure lvMenuWizardsColumnClick(Sender: TObject;
      Column: TListColumn);
    procedure lvMenuWizardsCompare(Sender: TObject; Item1,
      Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure actSelAllExecute(Sender: TObject);
    procedure actSelNoneExecute(Sender: TObject);
    procedure actSelReverseExecute(Sender: TObject);
    procedure lvMenuWizardsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FDragIndex: Integer;
    FColumnToSort: Integer;
    FSortFlag: array[0..3] of Boolean;
    FMWizards: TList;
    procedure InitMenusFromList(Sorted: TList);
  protected
    function GetHelpTopic: string; override;
  public
    procedure InitWizardMenus;
    procedure SaveWizardCreateInfo;
    procedure ReSortMenuWizards;
    procedure ExchangeTwoListItems(A, B: TListItem);
  end;

var
  CnMenuSortForm: TCnMenuSortForm;

implementation

uses CnWizManager, CnWizConsts, CnWizClasses;

{$R *.DFM}

{ TCnMenuSortFrm }

// 应该按照当前菜单的顺序来加入
procedure TCnMenuSortForm.InitMenusFromList(Sorted: TList);
var
  I: Integer;
begin
  if Sorted = nil then
    Exit;

  lvMenuWizards.Items.BeginUpdate;
  try
    lvMenuWizards.Items.Clear;
    for I := 0 to Sorted.Count - 1 do
    begin
      with lvMenuWizards.Items.Add do
      begin
        ImageIndex := TCnMenuWizard(Sorted[I]).Action.ImageIndex;
        Caption := StripHotKey(TCnMenuWizard(Sorted[I]).Menu.Caption);
        SubItems.Add(TCnMenuWizard(Sorted[I]).WizardName);
        SubItems.Add(TCnMenuWizard(Sorted[I]).GetIDStr);
        if TCnMenuWizard(Sorted[I]) is TCnSubMenuWizard then
          SubItems.Add(SCnSubMenuWizardName)
        else
          SubItems.Add(SCnMenuWizardName);
        Data := TCnMenuWizard(Sorted[I]);
      end;
    end;
    if lvMenuWizards.Items.Count > 0 then
      lvMenuWizards.Selected := lvMenuWizards.TopItem;
  finally
    lvMenuWizards.Items.EndUpdate;
  end;
end;

procedure TCnMenuSortForm.ReSortMenuWizards;
var
  I: Integer;
begin
  for I := 0 to lvMenuWizards.Items.Count - 1 do
    TCnMenuWizard(lvMenuWizards.Items[I].Data).MenuOrder := I;
end;

procedure TCnMenuSortForm.ResetActionExecute(Sender: TObject);
var
  I: Integer;
begin
  // 恢复 FMWizards 中的原始顺序
  FMWizards.Clear;
  for I := 0 to CnWizardMgr.MenuWizardCount - 1 do
  begin
    FMWizards.Add(CnWizardMgr.MenuWizards[I]);
    TCnMenuWizard(FMWizards[I]).MenuOrder := I;
  end;

  InitMenusFromList(FMWizards);
end;

procedure TCnMenuSortForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  UpAction.Enabled := (lvMenuWizards.SelCount = 1)
    and (lvMenuWizards.Selected.Index > 0);
  DownAction.Enabled := (lvMenuWizards.SelCount = 1)
    and (lvMenuWizards.Selected.Index < lvMenuWizards.Items.Count - 1);
  ResetAction.Enabled := True;
  Handled := True;
end;

procedure TCnMenuSortForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnMenuSortForm.GetHelpTopic: string;
begin
  Result := 'CnWizConfig';
end;

procedure TCnMenuSortForm.UpActionExecute(Sender: TObject);
var
  Idx: Integer;
begin
  // 选中的上移
  if UpAction.Enabled then
    with lvMenuWizards do
    begin
      Idx := Selected.Index;
      ExchangeTwoListItems(Selected, Items[Selected.Index - 1]);
      Selected := Items[Idx - 1];
      ItemFocused := Selected;
      SetFocus;
    end;
end;

procedure TCnMenuSortForm.DownActionExecute(Sender: TObject);
var
  Idx: Integer;
begin
  // 选中的下移
  if DownAction.Enabled then
    with lvMenuWizards do
    begin
      Idx := Selected.Index;
      ExchangeTwoListItems(Selected, Items[Selected.Index + 1]);
      Selected := Items[Idx + 1];
      ItemFocused := Selected;
      SetFocus;
    end;
end;

procedure TCnMenuSortForm.ExchangeTwoListItems(A, B: TListItem);
var
  I: Integer;
  S: String;
  P: Pointer;
begin
  if (A = nil) or (B = nil) then
    Exit;

  S := A.Caption;
  A.Caption := B.Caption;
  B.Caption := S;

  P := A.Data;
  A.Data := B.Data;
  B.Data := P;

  for I := 0 to A.SubItems.Count - 1 do
  begin
    S := A.SubItems[I];
    A.SubItems[I] := B.SubItems[I];
    B.SubItems[I] := S;
  end;
end;

procedure TCnMenuSortForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  PageControl.ActivePageIndex := 0;
  FMWizards := TList.Create;
  for I := 0 to CnWizardMgr.MenuWizardCount - 1 do
    FMWizards.Add(CnWizardMgr.MenuWizards[I]);
  lvWizardCreate.Items.Clear;
  lvMenuWizards.SmallImages := GetIDEImageList;

  for I := 0 to GetCnWizardClassCount - 1 do
  begin
    with lvWizardCreate.Items.Add do
    begin
      Caption := TCnWizardClass(GetCnWizardClassByIndex(I)).WizardName;
      SubItems.Add(TCnWizardClass(GetCnWizardClassByIndex(I)).GetIDStr);
      SubItems.Add(GetCnWizardTypeNameFromClass(TCnWizardClass(GetCnWizardClassByIndex(I))));
      Checked := CnWizardMgr.WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(I)).ClassName];
    end;
  end;
end;

procedure TCnMenuSortForm.FormDestroy(Sender: TObject);
begin
  FMWizards.Free;
end;

procedure TCnMenuSortForm.InitWizardMenus;
begin
  // FMWizards排序然后加入
  SortListByMenuOrder(FMWizards);
  InitMenusFromList(FMWizards);
end;

procedure TCnMenuSortForm.lvMenuWizardsStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FDragIndex := lvMenuWizards.Selected.Index;
end;

procedure TCnMenuSortForm.lvMenuWizardsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := ((Source = lvMenuWizards) or (Source = Sender));
  // 滚动ListView
  if Y < 15 then
    lvMenuWizards.Perform(WM_VSCROLL, SB_LINEUP, 0)
  else
    if Y > lvMenuWizards.Height - 15 then
      lvMenuWizards.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  lvMenuWizards.Selected := lvMenuWizards.GetItemAt(X, Y);
end;

procedure TCnMenuSortForm.lvMenuWizardsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  L, D: TListItem;
begin
  if Sender = Source then
  begin
    D := lvMenuWizards.GetItemAt(X, Y);
    if (FDragIndex >= 0) and (D <> nil) then
    begin
      // 插入到松开的 Item 之上
      L := lvMenuWizards.Items[FDragIndex];
      (lvMenuWizards.Items.Insert(D.Index)).Assign(L);
      lvMenuWizards.Items.Delete(L.Index);

      lvMenuWizards.Selected := D;
      lvMenuWizards.ItemFocused := lvMenuWizards.Selected;

      // 人性化设计，相邻上拖下本来不改变，现在交换此两个。拖到最后一个上也交换。
      if (lvMenuWizards.Selected.Index = lvMenuWizards.Items.Count - 1)
        or (lvMenuWizards.Selected.Index - FDragIndex = 1) then
        if lvMenuWizards.Items.Count > 1 then
          ExchangeTwoListItems(lvMenuWizards.Selected,
            lvMenuWizards.Items[lvMenuWizards.Selected.Index - 1]);
    end;
  end;
end;

procedure TCnMenuSortForm.lvMenuWizardsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  FColumnToSort := Column.Index;
  FSortFlag[FColumnToSort] := not FSortFlag[FColumnToSort];
  (Sender as TCustomListView).AlphaSort;
end;

procedure TCnMenuSortForm.lvMenuWizardsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  ix: Integer;
begin
  if FColumnToSort = 0 then
    Compare := CompareText(Item1.Caption,Item2.Caption)
  else
  begin
   ix := FColumnToSort - 1;
   Compare := CompareText(Item1.SubItems[ix],Item2.SubItems[ix]);
  end;

  if not FSortFlag[FColumnToSort] then
    Compare := -Compare;
end;

procedure TCnMenuSortForm.SaveWizardCreateInfo;
var
  I: Integer;
begin
  for I := 0 to lvWizardCreate.Items.Count - 1 do
    CnWizardMgr.WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(I)).ClassName]
      := lvWizardCreate.Items[I].Checked;
end;

procedure TCnMenuSortForm.actSelAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[I].Checked := True;
end;

procedure TCnMenuSortForm.actSelNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[I].Checked := False;
end;

procedure TCnMenuSortForm.actSelReverseExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[I].Checked := not lvWizardCreate.Items[I].Checked;
end;

procedure TCnMenuSortForm.lvMenuWizardsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  // 处理 Ctrl + Up 和 Ctrl + Down 按键实现项目上下移动
  if ssCtrl in Shift then
    case Key of
      VK_UP:
      begin
        UpActionExecute(Sender);
        Key := 0;
      end;
      VK_DOWN:
      begin
        DownActionExecute(Sender);
        Key := 0;
      end;
    end;
end;

end.
