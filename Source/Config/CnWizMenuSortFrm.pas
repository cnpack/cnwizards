{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizMenuSortFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��߼����õ�Ԫ
* ��Ԫ���ߣ�LiuXiao
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.08.02 V1.1
*               LiuXiao �����Ƿ񴴽�ר�ҵ�����
*           2003.06.27 V1.0
*               ������Ԫ
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
{$IFDEF FPC}
    procedure ActionListUpdate(AAction: TBasicAction; var Handled: Boolean);
{$ELSE}
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
{$ENDIF}
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

uses
  CnWizManager, CnWizConsts, CnWizClasses;

{$R *.DFM}

{ TCnMenuSortFrm }

// Ӧ�ð��յ�ǰ�˵���˳��������
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
  // �ָ� FMWizards �е�ԭʼ˳��
  FMWizards.Clear;
  for I := 0 to CnWizardMgr.MenuWizardCount - 1 do
  begin
    FMWizards.Add(CnWizardMgr.MenuWizards[I]);
    TCnMenuWizard(FMWizards[I]).MenuOrder := I;
  end;

  InitMenusFromList(FMWizards);
end;

{$IFDEF FPC}
procedure TCnMenuSortForm.ActionListUpdate(AAction: TBasicAction;
  var Handled: Boolean);
{$ELSE}
procedure TCnMenuSortForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
{$ENDIF}
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
  // ѡ�е�����
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
  // ѡ�е�����
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
  // FMWizards����Ȼ�����
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
  // ����ListView
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
      // ���뵽�ɿ��� Item ֮��
      L := lvMenuWizards.Items[FDragIndex];
      (lvMenuWizards.Items.Insert(D.Index)).Assign(L);
      lvMenuWizards.Items.Delete(L.Index);

      lvMenuWizards.Selected := D;
      lvMenuWizards.ItemFocused := lvMenuWizards.Selected;

      // ���Ի���ƣ����������±������ı䣬���ڽ������������ϵ����һ����Ҳ������
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
  // ���� Ctrl + Up �� Ctrl + Down ����ʵ����Ŀ�����ƶ�
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
