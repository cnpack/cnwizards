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
* 单元标识：$Id$
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
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    procedure InitWizardMenus;
    procedure SaveWizardCreateInfo;
    procedure ReSortMenuWizards;
    procedure ExchangeTwoListItems(A, B: TListItem);
    { Public declarations }
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
  i: Integer;
begin
  if Sorted = nil then
    Exit;

  Self.lvMenuWizards.Items.BeginUpdate;
  try
    Self.lvMenuWizards.Items.Clear;
    for i := 0 to Sorted.Count - 1 do
    begin
      with Self.lvMenuWizards.Items.Add do
      begin
        Caption := StripHotKey(TCnMenuWizard(Sorted[i]).Menu.Caption);
        SubItems.Add(TCnMenuWizard(Sorted[i]).WizardName);
        SubItems.Add(TCnMenuWizard(Sorted[i]).GetIDStr);
        if TCnMenuWizard(Sorted[i]) is TCnSubMenuWizard then
          SubItems.Add(SCnSubMenuWizardName)
        else
          SubItems.Add(SCnMenuWizardName);
        Data := TCnMenuWizard(Sorted[i]);
      end;
    end;
    if Self.lvMenuWizards.Items.Count > 0 then
      Self.lvMenuWizards.Selected := Self.lvMenuWizards.TopItem;
  finally
    Self.lvMenuWizards.Items.EndUpdate;
  end;
end;

procedure TCnMenuSortForm.ReSortMenuWizards;
var
  i: Integer;
begin
  for i := 0 to Self.lvMenuWizards.Items.Count - 1 do
    TCnMenuWizard(Self.lvMenuWizards.Items[i].Data).MenuOrder := i;
end;

procedure TCnMenuSortForm.ResetActionExecute(Sender: TObject);
var
  i: Integer;
begin
  // 恢复 FMWizards 中的原始顺序
  Self.FMWizards.Clear;
  for i := 0 to CnWizardMgr.MenuWizardCount - 1 do
  begin
    Self.FMWizards.Add(CnWizardMgr.MenuWizards[i]);
    TCnMenuWizard(FMWizards[i]).MenuOrder := i;
  end;

  Self.InitMenusFromList(Self.FMWizards);
end;

procedure TCnMenuSortForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  Self.UpAction.Enabled := (Self.lvMenuWizards.SelCount = 1)
    and (Self.lvMenuWizards.Selected.Index > 0);
  Self.DownAction.Enabled := (Self.lvMenuWizards.SelCount = 1)
    and (Self.lvMenuWizards.Selected.Index < Self.lvMenuWizards.Items.Count - 1);
  Self.ResetAction.Enabled := True;
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
    with Self.lvMenuWizards do
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
    with Self.lvMenuWizards do
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
  i: Integer;
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

  for i := 0 to A.SubItems.Count - 1 do
  begin
    S := A.SubItems[i];
    A.SubItems[i] := B.SubItems[i];
    B.SubItems[i] := S;
  end;
end;

procedure TCnMenuSortForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Self.PageControl.ActivePageIndex := 0;
  Self.FMWizards := TList.Create;
  for i := 0 to CnWizardMgr.MenuWizardCount - 1 do
    FMWizards.Add(CnWizardMgr.MenuWizards[i]);
  Self.lvWizardCreate.Items.Clear;
  for i := 0 to GetCnWizardClassCount - 1 do
  begin
    with Self.lvWizardCreate.Items.Add do
    begin
      Caption := TCnWizardClass(GetCnWizardClassByIndex(i)).WizardName;
      SubItems.Add(TCnWizardClass(GetCnWizardClassByIndex(i)).GetIDStr);
      SubItems.Add(GetCnWizardTypeNameFromClass(TCnWizardClass(GetCnWizardClassByIndex(i))));
      Checked := CnWizardMgr.WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName];
    end;
  end;
end;

procedure TCnMenuSortForm.FormDestroy(Sender: TObject);
begin
  Self.FMWizards.Free;
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
  Self.FDragIndex := Self.lvMenuWizards.Selected.Index;
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
  L: TListItem;
begin
  if Sender = Source then
  begin
    if (Self.FDragIndex > 0) and (Self.lvMenuWizards.GetItemAt(X, Y) <> nil) then
    begin
      // 插入到松开的 Item 之上
      L := Self.lvMenuWizards.Items[FDragIndex];
      (Self.lvMenuWizards.Items.Insert(Self.lvMenuWizards.GetItemAt(X, Y).Index)).Assign(L);
      Self.lvMenuWizards.Items.Delete(L.Index);

      Self.lvMenuWizards.Selected := Self.lvMenuWizards.GetItemAt(X, Y);
      Self.lvMenuWizards.ItemFocused := Self.lvMenuWizards.Selected;

      // 人性化设计，相邻上拖下本来不改变，现在交换此两个。拖到最后一个上也交换。
      if (Self.lvMenuWizards.Selected.Index = Self.lvMenuWizards.Items.Count - 1)
        or (Self.lvMenuWizards.Selected.Index - FDragIndex = 1) then
        if Self.lvMenuWizards.Items.Count > 1 then
          Self.ExchangeTwoListItems(Self.lvMenuWizards.Selected,
            Self.lvMenuWizards.Items[Self.lvMenuWizards.Selected.Index - 1]);
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
  i: Integer;
begin
  for i := 0 to Self.lvWizardCreate.Items.Count - 1 do
    CnWizardMgr.WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName]
      := Self.lvWizardCreate.Items[i].Checked;
end;

procedure TCnMenuSortForm.actSelAllExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[i].Checked := True;
end;

procedure TCnMenuSortForm.actSelNoneExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[i].Checked := False;
end;

procedure TCnMenuSortForm.actSelReverseExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lvWizardCreate.Items.Count - 1 do
    lvWizardCreate.Items[i].Checked := not lvWizardCreate.Items[i].Checked;
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
