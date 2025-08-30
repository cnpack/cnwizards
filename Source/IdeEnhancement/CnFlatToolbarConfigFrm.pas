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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from GExperts 1.2                                    }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnFlatToolbarConfigFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：浮动工具条定制窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元移植自 GExperts 1.2a Src
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2003.05.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFORMENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Menus,
  StdCtrls, ExtCtrls, ComCtrls, ActnList, Buttons, IniFiles,
  {$IFDEF DELPHIXE3_UP} Actions, {$ENDIF} {$IFDEF LAZARUS} LCLType, {$ENDIF}
  CnSpin, CnWizUtils, CnCommon, CnWizConsts, CnWizOptions, CnWizMultiLang,
  CnWizIdeUtils;

const
  csOptions = 'Options';
  csLineCount = 'LineCount';
  csVertOrder = 'VertOrder';
  csToolBar = 'ToolBar';
  csButton = 'Button';
  csFlatFormLeft = 'FlatFormLeft';
  csFlatFormTop = 'FlatFormTop';
  csMinLineCount = 1;
  csMaxLineCount = 4;

type
  TCnWizToolBarStyle = (tbsForm, tbsEditor);
  
  TCnFlatToolbarConfigForm = class(TCnTranslateForm)
    lbCategories: TListBox;
    lblCategories: TLabel;
    lblAvailable: TLabel;
    lbAvailable: TListBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    btnAdd: TBitBtn;
    btnRemove: TBitBtn;
    lblToolbar: TLabel;
    lbToolbar: TListBox;
    Actions: TActionList;
    actAddButton: TAction;
    actRemoveButton: TAction;
    btnUp: TBitBtn;
    btnDown: TBitBtn;
    actMoveDown: TAction;
    actMoveUp: TAction;
    pnlButtons: TPanel;
    pnlContent: TPanel;
    actReset: TAction;
    btnReset: TBitBtn;
    pnlForm: TPanel;
    lbl1: TLabel;
    seLineCount: TCnSpinEdit;
    chkVertOrder: TCheckBox;
    pnlEditor: TPanel;
    btnAddSep: TButton;
    procedure btnHelpClick(Sender: TObject);
    procedure actAddButtonExecute(Sender: TObject);
    procedure actRemoveButtonExecute(Sender: TObject);
    procedure ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure lbCategoriesClick(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ListboxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbAvailableDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbAvailableDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbToolbarDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure lbToolbarKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actResetExecute(Sender: TObject);
    procedure btnAddSepClick(Sender: TObject);
  private
    FStyle: TCnWizToolBarStyle;
    FDataFileName: string;
    FHelpStr: string;
    FToolbarActionNames: TStrings;
    FSavedToolbarItemIndex: Integer;
    FTextOffset: Integer;
    FActionList: TCustomActionList;
    procedure SetupActionListBoxes;
    function GetToolbarActions: TStrings;
    procedure SetToolbarActions(const Value: TStrings);
    procedure GetCategories(ActionList: TCustomActionList;
      Categories: TStrings);
    function GetLineCount: Integer;
    function GetVertOrder: Boolean;
    procedure SetLineCount(const Value: Integer);
    procedure SetVertOrder(const Value: Boolean);
  protected
    function GetHelpTopic: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Integer; override;
    procedure SetStyle(Style: TCnWizToolBarStyle; const ADataFileName, AHelpStr:
      string);
    property ToolbarActions: TStrings read GetToolbarActions write SetToolbarActions;
    property LineCount: Integer read GetLineCount write SetLineCount;
    property VertOrder: Boolean read GetVertOrder write SetVertOrder;
  end;

{$ENDIF CNWIZARDS_CNFORMENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFORMENHANCEWIZARD}

{$R *.DFM}

const
  csSeparatorCaption = '-';
  csListItemIconWidth = 22;

resourcestring
  SNoButtonCategory = '(None)';
  SAllButtonsCategory = '(All)';
  SSeparator = '[Separator]';

procedure AddActionToListbox(Action: TContainedAction; Listbox: TCustomListbox; Select: Boolean);
var
  NewIndex: Integer;
begin
  if Action = nil then
    NewIndex := Listbox.Items.Add(csSeparatorCaption)
  else if (Action is TCustomAction) and (TCustomAction(Action).Caption <> '') then
    NewIndex := Listbox.Items.AddObject(StripHotkey(TCustomAction(Action).Caption), Action)
  else
    NewIndex := Listbox.Items.AddObject(Action.Name, Action);
  if Select then
    Listbox.ItemIndex := NewIndex;
end;

procedure TCnFlatToolbarConfigForm.GetCategories(ActionList: TCustomActionList;
  Categories: TStrings);
var
  I: Integer;
  Category: string;
begin
  Assert(Assigned(ActionList));
  Assert(Assigned(Categories));
  Categories.Clear;

  for I := 0 to ActionList.ActionCount - 1 do
  begin
    Category := ActionList.Actions[I].Category;
    if Trim(Category) = '' then
      Category := SNoButtonCategory;
    if Categories.IndexOf(Category) = -1 then
      Categories.Add(Category);
  end;
end;

procedure TCnFlatToolbarConfigForm.SetupActionListBoxes;
var
  I: Integer;
  Action: TContainedAction;
  NoneIndex: Integer;
begin
  GetCategories(FActionList, lbCategories.Items);
  Assert(lbCategories.Items.Count > 0);
  lbCategories.Sorted := True;
  NoneIndex := lbCategories.Items.IndexOf(SNoButtonCategory);
  lbCategories.Sorted := False;
  if NoneIndex >= 0 then
  begin
    lbCategories.Items.Delete(NoneIndex);
    lbCategories.Items.Add(SNoButtonCategory);
  end;
  lbCategories.Items.Add(SAllButtonsCategory);
  lbCategories.ItemIndex := 0;
  lbCategoriesClick(lbCategories);
  ActiveControl := lbCategories;
  ListboxHorizontalScrollbar(lbCategories);

  Assert(Assigned(FToolbarActionNames));
  for I := 0 to FToolbarActionNames.Count - 1 do
  begin
    Action := FindIDEAction(FToolbarActionNames[I]);
    if (FToolbarActionNames[I] = csSeparatorCaption) or Assigned(Action) then
      AddActionToListbox(Action, lbToolbar, False);
  end;
end;

procedure TCnFlatToolbarConfigForm.SetToolbarActions(const Value: TStrings);
begin
  Assert(Assigned(FToolbarActionNames));
  FToolbarActionNames.Assign(Value);
end;

procedure TCnFlatToolbarConfigForm.SetStyle(Style: TCnWizToolBarStyle; const 
  ADataFileName, AHelpStr: string);
begin
  FStyle := Style;
  FDataFileName := ADataFileName;
  FHelpStr := AHelpStr;
  pnlEditor.Visible := Style = tbsEditor;
  pnlForm.Visible := Style = tbsForm;
end;

constructor TCnFlatToolbarConfigForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FToolbarActionNames := TStringList.Create;
  FActionList := GetIDEActionList;
end;

destructor TCnFlatToolbarConfigForm.Destroy;
begin
  FreeAndNil(FToolbarActionNames);

  inherited Destroy;
end;

procedure TCnFlatToolbarConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnFlatToolbarConfigForm.GetHelpTopic: string;
begin
  Result := FHelpStr;
end;

procedure TCnFlatToolbarConfigForm.actAddButtonExecute(Sender: TObject);
var
  I: Integer;
begin
  if lbAvailable.MultiSelect then
  begin
    for I := 0 to lbAvailable.Items.Count-1 do
    begin
      if lbAvailable.Selected[I] then
        AddActionToListbox(TContainedAction(lbAvailable.Items.Objects[I]), lbToolbar, True);
    end;
  end
  else
  begin
    if (lbAvailable.Items.Count > 0) and (lbAvailable.ItemIndex <> -1) then
      AddActionToListbox(TContainedAction(lbAvailable.Items.Objects[lbAvailable.ItemIndex]), lbToolbar, True);
  end;
end;

procedure TCnFlatToolbarConfigForm.actRemoveButtonExecute(Sender: TObject);
var
  I: Integer;
  SelIndex: Integer;
begin
  SelIndex := lbToolbar.ItemIndex;
  if lbToolbar.MultiSelect then
  begin
    for I := lbToolbar.Items.Count - 1 downto 0 do
      if lbToolbar.Selected[I] then
        lbToolbar.Items.Delete(I);
  end
  else
  begin
    if lbToolbar.ItemIndex <> -1 then
      lbToolbar.Items.Delete(lbToolbar.ItemIndex);
  end;

  if SelIndex <= lbToolbar.Items.Count - 1 then
    lbToolbar.ItemIndex := SelIndex
  else
    lbToolbar.ItemIndex := lbToolbar.Items.Count - 1;
end;

procedure TCnFlatToolbarConfigForm.btnAddSepClick(Sender: TObject);
begin
  AddActionToListbox(nil, lbToolbar, True);
end;

procedure TCnFlatToolbarConfigForm.ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  if lbAvailable.MultiSelect then
    actAddButton.Enabled := lbAvailable.SelCount > 0
  else
    actAddButton.Enabled := lbAvailable.ItemIndex <> -1;

  if lbToolbar.MultiSelect then
    actRemoveButton.Enabled := lbToolbar.SelCount > 0
  else
    actRemoveButton.Enabled := lbToolbar.ItemIndex <> -1;

  actMoveUp.Enabled := actRemoveButton.Enabled and (lbToolbar.ItemIndex <> 0);
  actMoveDown.Enabled := actRemoveButton.Enabled and (lbToolbar.ItemIndex <> lbToolbar.Items.Count - 1);
end;

procedure TCnFlatToolbarConfigForm.lbCategoriesClick(Sender: TObject);
var
  I: Integer;
  Category: string;
begin
  lbAvailable.Items.BeginUpdate;
  try
    lbAvailable.Clear;
    if lbCategories.ItemIndex = -1 then
      Exit;

    Category := lbCategories.Items[lbCategories.ItemIndex];
    for I := 0 to FActionList.ActionCount - 1 do
    begin
      if FActionList.Actions[I].Name = '' then
        Continue;
      if (FActionList.Actions[I] is TCustomAction) then // 不加入隐藏的 Action
        if not TCustomAction(FActionList.Actions[I]).Visible then
          Continue;

      if Category = SAllButtonsCategory then
        AddActionToListbox(FActionList.Actions[I], lbAvailable, False)
      else if SameText(Category, FActionList.Actions[I].Category) then
        AddActionToListbox(FActionList.Actions[I], lbAvailable, False)
      else if (Category = SNoButtonCategory) and (Trim(FActionList.Actions[I].Category) = '') then
        AddActionToListbox(FActionList.Actions[I], lbAvailable, False);
    end;
    lbAvailable.Sorted := True;
  finally
    lbAvailable.Items.EndUpdate;
  end;
end;

function TCnFlatToolbarConfigForm.GetToolbarActions: TStrings;
begin
  Result := FToolbarActionNames;
end;

function TCnFlatToolbarConfigForm.ShowModal: Integer;
begin
  SetupActionListBoxes;
  Result := inherited ShowModal;
end;

procedure TCnFlatToolbarConfigForm.actMoveUpExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := lbToolbar.ItemIndex;
  if Index = 0 then
    Exit;
  lbToolbar.Items.Exchange(Index, Index - 1);
end;

procedure TCnFlatToolbarConfigForm.actMoveDownExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := lbToolbar.ItemIndex;
  if Index = lbToolbar.Items.Count - 1 then
    Exit;
  lbToolbar.Items.Exchange(Index, Index + 1);
end;

procedure TCnFlatToolbarConfigForm.btnOKClick(Sender: TObject);
var
  I: Integer;
  Action: TContainedAction;
begin
  FToolbarActionNames.Clear;
  for I := 0 to lbToolbar.Items.Count - 1 do
  begin
    Action := TContainedAction(lbToolbar.Items.Objects[I]);
    if Action <> nil then
      FToolbarActionNames.Add(Action.Name)
    else
      FToolbarActionNames.Add(lbToolbar.Items[I]);
  end;
end;

procedure TCnFlatToolbarConfigForm.ListboxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Listbox: TListbox;
  LbCanvas: TCanvas;

  procedure DrawToolbarButton;
  var
    BtnRect: TRect;
    OldColor: TColor;
    Action: TCustomAction;
    Obj: TObject;
  begin
    Action := nil;
    Obj := Listbox.Items.Objects[Index];
    if Assigned(Obj) and (Obj is TCustomAction) then
      Action := TCustomAction(Obj);

    if odSelected in State then
      LbCanvas.Brush.Color := clHighlight
    else
      LbCanvas.Brush.Color := clWindow;

    LbCanvas.FillRect(Rect);

    // Paint fake button
    if Assigned(Action) and (Action.ImageIndex <> -1) then
    begin
      OldColor := LbCanvas.Brush.Color;
      LbCanvas.Brush.Color := clBtnface;
      try
        BtnRect := Classes.Rect(Rect.Left, Rect.Top + 1,
                                Rect.Left + 20, Rect.Top + 20);
        LbCanvas.FillRect(BtnRect);
        Action.ActionList.Images.Draw(LbCanvas,
                                      Rect.Left + 2,
                                      Rect.Top + 2,
                                      Action.ImageIndex);
        Frame3D(LbCanvas, BtnRect, clBtnHighlight, clBtnShadow, 1);
      finally
        LbCanvas.Brush.Color := OldColor;
      end;
    end;
  end;

begin
  Assert(Control is TListBox);
  Listbox := TListBox(Control);
  LbCanvas := Listbox.Canvas;
  if FTextOffset = 0 then
    FTextOffset := (Listbox.ItemHeight - LbCanvas.TextHeight(SAllAlphaNumericChars)) div 2;

  DrawToolbarButton;

  LbCanvas.Brush.Style := bsClear;

  if not lbAvailable.Enabled then
    LbCanvas.Font.Color := clGrayText;
  if ListBox.Items[Index] = csSeparatorCaption then
    LbCanvas.TextOut(Rect.Left + IdeGetScaledPixelsFromOrigin(csListItemIconWidth, ListBox), Rect.Top + FTextOffSet, SSeparator)
  else
    LbCanvas.TextOut(Rect.Left + IdeGetScaledPixelsFromOrigin(csListItemIconWidth, ListBox), Rect.Top + FTextOffSet, Listbox.Items[Index]);
end;

procedure TCnFlatToolbarConfigForm.lbAvailableDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = lbToolbar);
end;

procedure TCnFlatToolbarConfigForm.lbAvailableDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  actRemoveButton.Execute;
end;

procedure TCnFlatToolbarConfigForm.lbToolbarDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Idx: Integer;
begin
  Accept := ((Source = lbAvailable) or (Source = Sender));
  // Autoscroll the listbox to make dragging easier
  if Y < 15 then
    lbToolbar.Perform(WM_VSCROLL, SB_LINEUP, 0)
  else if Y > lbToolbar.Height - 15 then
    lbToolbar.Perform(WM_VSCROLL, SB_LINEDOWN, 0);

  Idx := lbToolbar.ItemAtPos(Point(X, Y), False);
  if (Idx > -1) and (Idx < lbToolbar.Items.Count) then
    lbToolbar.ItemIndex := Idx;
end;

procedure TCnFlatToolbarConfigForm.lbToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Idx: Integer;
begin
  Idx := lbToolbar.ItemAtPos(Point(X, Y), False);
  if Idx = lbToolbar.Items.Count then
    Dec(Idx);
  if Sender <> Source then
  begin
    if (Idx < 0) or (Idx = lbToolbar.Items.Count - 1) then
      actAddButton.Execute
    else if lbAvailable.ItemIndex <> -1 then
    begin
      lbToolbar.Items.InsertObject(Idx, lbAvailable.Items[lbAvailable.ItemIndex],
        lbAvailable.Items.Objects[lbAvailable.ItemIndex]);
      lbToolbar.ItemIndex := Idx;
    end;
  end
  else
  begin
    if (FSavedToolbarItemIndex < 0) or (Idx < 0) then
      Exit;
    lbToolbar.Items.Move(FSavedToolbarItemIndex, Idx);
    lbToolbar.ItemIndex := Idx;
  end;
end;

procedure TCnFlatToolbarConfigForm.lbToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  FSavedToolbarItemIndex := lbToolbar.ItemIndex;
end;

procedure TCnFlatToolbarConfigForm.lbToolbarKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    actRemoveButton.Execute;
end;

function TCnFlatToolbarConfigForm.GetLineCount: Integer;
begin
  Result := seLineCount.Value;
end;

function TCnFlatToolbarConfigForm.GetVertOrder: Boolean;
begin
  Result := chkVertOrder.Checked;
end;

procedure TCnFlatToolbarConfigForm.SetLineCount(const Value: Integer);
begin
  seLineCount.Value := Value;
end;

procedure TCnFlatToolbarConfigForm.SetVertOrder(const Value: Boolean);
begin
  chkVertOrder.Checked := Value;
end;

procedure TCnFlatToolbarConfigForm.actResetExecute(Sender: TObject);
var
  Value, FileName: string;
  Action: TContainedAction;
  I: Integer;
begin
  FToolbarActionNames.Clear;
  lbToolbar.Clear;

  if FDataFileName <> '' then
  begin
    DeleteFile(WizOptions.GetUserFileName(FDataFileName, False));
    FileName := WizOptions.GetUserFileName(FDataFileName, True);

    with TMemIniFile.Create(FileName) do
    try
      if FStyle = tbsForm then
      begin
        LineCount := TrimInt(ReadInteger(csOptions, csLineCount, 2),
          csMinLineCount, csMaxLineCount);
        VertOrder := ReadBool(csOptions, csVertOrder, True);
      end;

      I := 0;
      while ValueExists(csToolBar, csButton + IntToStr(I)) do
      begin
        Value := Trim(ReadString(csToolBar, csButton + IntToStr(I), ''));
        if Value <> '' then
          FToolbarActionNames.Add(Value);
        Inc(I);
      end;
    finally
      Free;
    end;

    for I := 0 to FToolbarActionNames.Count - 1 do
    begin
      Action := FindIDEAction(FToolbarActionNames[I]);
      if (FToolbarActionNames[I] = csSeparatorCaption) or Assigned(Action) then
        AddActionToListbox(Action, lbToolbar, False);
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNFORMENHANCEWIZARD}
end.
