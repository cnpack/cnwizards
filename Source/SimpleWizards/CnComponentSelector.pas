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

unit CnComponentSelector;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ѡ�񹤾�ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��WizOptions.UseSearchCombo Ϊ True ʱ��cbbByClass �� cbbByEvent
*           �ᱻ SearchComboBox ��֮
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.07.27 V1.3
*               ����һ���������ɹ������Է���ѡ��ؼ�
*           2003.04.16 V1.2
*               �����л� Tag ��Χ����Ϊ�����ڡ�ʱ���ڶ��� SpinEdit ������ʾ�Ĵ���
*           2003.03.12 V1.1
*               ������֧��Ĭ�����������
*           2002.10.02 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCOMPONENTSELECTOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, IniFiles, Registry, Menus,
  {$IFDEF DELPHI_OTA} ToolsAPI,
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  {$ENDIF}
  {$IFDEF LAZARUS} IDEIntf, FormEditingIntf, PropEdits, {$ENDIF}
  ActnList, TypInfo, Contnrs, CnConsts, CnWizClasses, CnWizConsts, CnWizUtils,
  CnCommon, CnSpin, CnSearchCombo, CnWizOptions, CnWizMultiLang, CnWizManager;

type

//==============================================================================
// ���ѡ��ר�Ҵ���
//==============================================================================

{ TCnComponentSelectorForm }

  TCnComponentSelectorForm = class(TCnTranslateForm)
    gbFilter: TGroupBox;
    rbCurrForm: TRadioButton;
    rbCurrControl: TRadioButton;
    rbSpecControl: TRadioButton;
    cbbFilterControl: TComboBox;
    gbByName: TGroupBox;
    gbComponentList: TGroupBox;
    lbSource: TListBox;
    btnAdd: TButton;
    btnAddAll: TButton;
    btnDelete: TButton;
    btnDeleteAll: TButton;
    btnSelAll: TButton;
    btnSelNone: TButton;
    btnSelInvert: TButton;
    Label1: TLabel;
    lbDest: TListBox;
    Label2: TLabel;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    edtByName: TEdit;
    cbByName: TCheckBox;
    cbByClass: TCheckBox;
    cbbByClass: TComboBox;
    gbTag: TGroupBox;
    cbByTag: TCheckBox;
    cbbByTag: TComboBox;
    lblTag: TLabel;
    Label4: TLabel;
    cbbSourceOrderStyle: TComboBox;
    cbbSourceOrderDir: TComboBox;
    cbSubClass: TCheckBox;
    ActionList: TActionList;
    actAdd: TAction;
    actAddAll: TAction;
    actDelete: TAction;
    actDeleteAll: TAction;
    actSelAll: TAction;
    actSelNone: TAction;
    actSelInvert: TAction;
    cbDefaultSelAll: TCheckBox;
    cbIncludeChildren: TCheckBox;
    btnMoveToTop: TButton;
    btnMoveToBottom: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    actMoveToTop: TAction;
    actMoveToBottom: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    seTagStart: TCnSpinEdit;
    seTagEnd: TCnSpinEdit;
    chkByEvent: TCheckBox;
    cbbByEvent: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DoUpdateSourceOrder(Sender: TObject);
    procedure DoUpdateListControls(Sender: TObject);
    procedure DoUpdateList(Sender: TObject);
    procedure DoActionListUpdate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actAddAllExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteAllExecute(Sender: TObject);
    procedure actSelAllExecute(Sender: TObject);
    procedure actSelNoneExecute(Sender: TObject);
    procedure actSelInvertExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure actMoveToTopExecute(Sender: TObject);
    procedure actMoveToBottomExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FIni: TCustomIniFile;
    FSourceList, FDestList: TCnDesignerSelectionList;
    FContainerWindow: TWinControl;
    FCurrList: TStrings;
    FCbbByClass: TCnSearchComboBox;
    FCbbByEvent: TCnSearchComboBox;
    procedure GetEventList(AObj: TObject; AList: TStringList);
    procedure BeginUpdateList;
    procedure EndUpdateList;
    procedure InitControls;
    procedure UpdateControls;
    procedure UpdateList;
    procedure UpdateSourceOrders;
  protected
    property Ini: TCustomIniFile read FIni;
    property SourceList: TCnDesignerSelectionList read FSourceList;
    property DestList: TCnDesignerSelectionList read FDestList;
    property ContainerWindow: TWinControl read FContainerWindow;
    property CurrList: TStrings read FCurrList;
    function GetHelpTopic: string; override;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile; ASourceList,
      ADestList: TCnDesignerSelectionList; AContainerWindow: TWinControl);
    procedure LoadSettings(Ini: TCustomIniFile; const Section: string); virtual;
    procedure SaveSettings(Ini: TCustomIniFile; const Section: string); virtual;
  end;

//==============================================================================
// ���ѡ��ר����
//==============================================================================

{ TCnComponentSelector }

  TCnComponentSelector = class(TCnMenuWizard)
  private
  
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

function SelectComponentsWithSelector(Selections: TComponentList): Boolean;
{* ����絥�����ã�����ѡ���������ʵ�������� Selections ������Ƿ�ѡ��ɹ�}

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

implementation

{$IFDEF CNWIZARDS_CNCOMPONENTSELECTOR}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// ���ѡ��ר�Ҵ���
//==============================================================================

{ TCnComponentSelectorForm }

// ��չ�Ĺ������������������������б���ƴ���
constructor TCnComponentSelectorForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile; ASourceList, ADestList: TCnDesignerSelectionList;
  AContainerWindow: TWinControl);
begin
  Create(AOwner);
  FIni := AIni;
  FSourceList := ASourceList;
  FDestList := ADestList;
  FContainerWindow := AContainerWindow;
end;

// �����ʼ��
procedure TCnComponentSelectorForm.FormCreate(Sender: TObject);
begin
  FCurrList := TStringList.Create;
  InitControls;
  if Ini <> nil then
    LoadSettings(Ini, '');
  UpdateControls;
  UpdateList;
end;

// �����ͷ�
procedure TCnComponentSelectorForm.FormDestroy(Sender: TObject);
begin
  if Ini <> nil then
    SaveSettings(Ini, '');
  FCurrList.Free;
end;

// ȷ������ѡ����
procedure TCnComponentSelectorForm.btnOKClick(Sender: TObject);
var
  I: Integer;
begin
  if lbDest.Items.Count > 0 then       // ѡ���б�Ϊ��
  begin
    for I := 0 to lbDest.Items.Count - 1 do
    begin
{$IFDEF LAZARUS}
      DestList.Add(TComponent(lbDest.Items.Objects[I]));
{$ELSE}
    {$IFDEF COMPILER6_UP}
      DestList.Add(TComponent(lbDest.Items.Objects[I]));
    {$ELSE}
      DestList.Add(MakeIPersistent(TComponent(lbDest.Items.Objects[I])));
    {$ENDIF}
{$ENDIF}
    end;
  end
  else if cbDefaultSelAll.Checked then // ��ѡ����ʱ�Զ�������������
  begin
    for I := 0 to lbSource.Items.Count - 1 do
    begin
{$IFDEF LAZARUS}
      DestList.Add(TComponent(lbDest.Items.Objects[I]));
{$ELSE}
    {$IFDEF COMPILER6_UP}
      DestList.Add(TComponent(lbSource.Items.Objects[I]));
    {$ELSE}
      DestList.Add(MakeIPersistent(TComponent(lbSource.Items.Objects[I])));
    {$ENDIF}
{$ENDIF}
    end;
  end;
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------
// �ؼ����÷���
//------------------------------------------------------------------------------

procedure TCnComponentSelectorForm.GetEventList(AObj: TObject;
  AList: TStringList);
var
  PropList: PPropList;
  Value: TMethod;
  Count, I: Integer;
  MName: string;
begin
  if (AObj = nil) or not (AObj is TComponent) or (TComponent(AObj).Owner = nil) then
    Exit;
  try
    Count := GetPropList(AObj.ClassInfo, [tkMethod], nil);
  except
    Exit;
  end;

  GetMem(PropList, Count * SizeOf(PPropInfo));
  try
    GetPropList(AObj.ClassInfo, [tkMethod], PropList);
    for I := 0 to Count - 1 do
    begin
      Value := GetMethodProp(AObj, PropList[I]);
      if Value.Code <> nil then
      begin
        MName := TComponent(AObj).Owner.MethodName(Value.Code);
        if (MName <> '') and (AList.IndexOf(MName) < 0) then
          AList.Add(MName);
      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

// ��ʼ���ؼ���ֻ�ᱻ����һ��
procedure TCnComponentSelectorForm.InitControls;
var
  I: Integer;
  WinControl: TWinControl;
  SelIsEmpty: Boolean;
  Component: TComponent;
  List: TStringList;
begin
  // ��鵱ǰѡ�������б��Ƿ�����ӿؼ�
  SelIsEmpty := True;
  for I := 0 to SourceList.Count - 1 do
  begin
{$IFDEF LAZARUS}
    Component := TComponent(SourceList[I]);
{$ELSE}
  {$IFDEF COMPILER6_UP}
    Component := TComponent(SourceList[I]);
  {$ELSE}
    Component := TryExtractComponent(SourceList[I]);
  {$ENDIF}
{$ENDIF}
    if Component = ContainerWindow then
      Break; // ѡ�񲿷ְ������屾��
    if (Component is TWinControl) and (TWinControl(Component).ControlCount > 0) then
    begin
      SelIsEmpty := False;
      Break;
    end;
  end;
  rbCurrControl.Enabled := not SelIsEmpty;
  if rbCurrControl.Checked and SelIsEmpty then
    rbCurrForm.Checked := True;

  // ��ʼ�������ؼ��б�
  cbbFilterControl.Items.Clear;
  for I := 0 to ContainerWindow.ComponentCount - 1 do
  begin
    if ContainerWindow.Components[I] is TControl then
    begin
      WinControl := TControl(ContainerWindow.Components[I]).Parent;
      if (WinControl <> nil) and (WinControl <> ContainerWindow) and
        (WinControl.Name <> '') and
        (cbbFilterControl.Items.IndexOfObject(WinControl) < 0) then
        cbbFilterControl.Items.AddObject(WinControl.Name, WinControl);
    end;
  end;
  rbSpecControl.Enabled := cbbFilterControl.Items.Count > 0;

  if WizOptions.UseSearchCombo then
  begin
    CloneSearchCombo(FCbbByClass, cbbByClass);
    CloneSearchCombo(FCbbByEvent, cbbByEvent);

    // ��ʼ�����б�
    FCbbByClass.Items.Clear;
    for I := 0 to ContainerWindow.ComponentCount - 1 do
      with ContainerWindow.Components[I] do
        if FCbbByClass.Items.IndexOf(ClassName) < 0 then
          FCbbByClass.Items.AddObject(ClassName, Pointer(ClassType));

    // ��ʼ���¼��б�
    FCbbByEvent.Items.Clear;
    List := TStringList.Create;
    try
      List.Sorted := True;
      for I := 0 to ContainerWindow.ComponentCount - 1 do
        GetEventList(ContainerWindow.Components[I], List);
      FCbbByEvent.Items.Assign(List);
    finally
      List.Free;
    end;
  end
  else
  begin
    // ��ʼ�����б�
    cbbByClass.Items.Clear;
    for I := 0 to ContainerWindow.ComponentCount - 1 do
    begin
      with ContainerWindow.Components[I] do
        if cbbByClass.Items.IndexOf(ClassName) < 0 then
          cbbByClass.Items.AddObject(ClassName, Pointer(ClassType));
    end;

    // ��ʼ���¼��б�
    cbbByEvent.Items.Clear;
    List := TStringList.Create;
    try
      List.Sorted := True;
      for I := 0 to ContainerWindow.ComponentCount - 1 do
        GetEventList(ContainerWindow.Components[I], List);
      cbbByEvent.Items.Assign(List);
    finally
      List.Free;
    end;
  end;
end;

// ���µ�ǰ�����б�
procedure TCnComponentSelectorForm.UpdateList;
var
  I, J: Integer;
  SelStrs: TStrings;
  Component: TComponent;
  WinControl: TWinControl;
  
  // �����Ƿ�ƥ��
  function MatchName(const AName: string): Boolean;
  begin
    Result := not cbByName.Checked or (edtByName.Text = '') or
      (AnsiPos(UpperCase(edtByName.Text), UpperCase(AName)) > 0);
  end;

  // �����Ƿ�ƥ��
  function MatchClass(AObject: TObject): Boolean;
  begin
    if WizOptions.UseSearchCombo then
      Result := not cbByClass.Checked or (FcbbByClass.Text = '') or
      AObject.ClassNameIs(FcbbByClass.Text) or
      (cbSubClass.Checked and AObject.InheritsFrom(
      TClass(FcbbByClass.Items.Objects[FcbbByClass.ItemIndex])))
    else
      Result := not cbByClass.Checked or (cbbByClass.Text = '') or
        AObject.ClassNameIs(cbbByClass.Text) or
        (cbSubClass.Checked and AObject.InheritsFrom(
        TClass(cbbByClass.Items.Objects[cbbByClass.ItemIndex])));
  end;

  // �¼��Ƿ�ƥ��
  function MatchEvent(AObject: TObject): Boolean;
  var
    List: TStringList;
    EvtTxt: string;
  begin
    Result := True;
    if WizOptions.UseSearchCombo then
      EvtTxt := FcbbByEvent.Text
    else
      EvtTxt := cbbByEvent.Text;

    if not chkByEvent.Checked or (EvtTxt = '') then
      Exit;

    List := TStringList.Create;
    try
      GetEventList(AObject, List);
      Result := List.IndexOf(EvtTxt) >= 0;
    finally
      List.Free;
    end;   
  end;

  // Tag �Ƿ�ƥ��
  function MatchTag(ATag: Integer): Boolean;
  var
    TagStart, TagEnd: Integer;
  begin
    if cbByTag.Checked then
    begin
      TagStart := StrToIntDef(seTagStart.Text, 0);
      TagEnd := StrToIntDef(seTagEnd.Text, 0);
      case cbbByTag.ItemIndex of
        0: Result := ATag = TagStart;
        1: Result := ATag < TagStart;
        2: Result := ATag > TagStart;
        3: Result := (ATag >= TagStart) and (ATag <= TagEnd);
      else
        Result := True;
      end;
    end
    else
      Result := True;
  end;

  // ����һ����Ŀ
  procedure AddItem(AComponent: TComponent; IncludeChildren: Boolean = False);
  var
    S: string;
    I: Integer;
  begin
    // �ж��Ƿ�ƥ��
    if (AComponent.Name <> '') and MatchName(AComponent.Name) and MatchClass(AComponent)
      and MatchEvent(AComponent) and MatchTag(AComponent.Tag)
      and (CurrList.IndexOfObject(AComponent) < 0) then
    begin
      S := AComponent.Name + ': ' + AComponent.ClassName;
      CurrList.AddObject(S, AComponent);  // ���ӵ���ǰ�����б�
      if lbDest.Items.IndexOf(S) < 0 then
        lbSource.Items.AddObject(S, AComponent); // ֻ���Ӳ�����ѡ���б��е���
    end;

    // �ݹ������ӿؼ�
    if IncludeChildren and (AComponent is TWinControl) then
    begin
      with TWinControl(AComponent) do
        for I := 0 to ControlCount - 1 do
          AddItem(Controls[I], True);
    end;
  end;

begin
  BeginUpdateList;
  try
    SelStrs := TStringList.Create;
    try
      for I := 0 to lbSource.Items.Count - 1 do // ���浱ǰ��ѡ����б�
      begin
        if lbSource.Selected[I] then
          SelStrs.Add(lbSource.Items[I]);
      end;

      CurrList.Clear;
      lbSource.Clear;
      if rbCurrForm.Checked then       // �������������
      begin
        for I := 0 to ContainerWindow.ComponentCount - 1 do
          AddItem(ContainerWindow.Components[I]);
      end
      else if rbCurrControl.Checked then // ��ǰѡ��ؼ����ӿؼ�
      begin
        for I := 0 to SourceList.Count - 1 do
        begin
{$IFDEF LAZARUS}
          Component := TComponent(SourceList[I]);
{$ELSE}
        {$IFDEF COMPILER6_UP}
          Component := TComponent(SourceList[I]);
        {$ELSE}
          Component := TryExtractComponent(SourceList[I]);
        {$ENDIF}
{$ENDIF}
          if Component is TWinControl then
          begin
            WinControl := TWinControl(Component);
            for J := 0 to WinControl.ControlCount - 1 do
              AddItem(WinControl.Controls[J], cbIncludeChildren.Checked);
          end;
        end;
      end
      else if rbSpecControl.Checked then // ָ���ؼ����ӿؼ�
      begin
        if cbbFilterControl.ItemIndex >= 0 then
        begin
          WinControl := TWinControl(cbbFilterControl.Items.Objects[cbbFilterControl.ItemIndex]);
            for I := 0 to WinControl.ControlCount - 1 do
              AddItem(WinControl.Controls[I], cbIncludeChildren.Checked);
        end;
      end;
      for I := 0 to lbSource.Items.Count - 1 do // �ָ������ѡ���б�
        lbSource.Selected[I] := SelStrs.IndexOf(lbSource.Items[I]) >= 0;
    finally
      SelStrs.Free;
    end;
  finally
    UpdateSourceOrders;
    EndUpdateList;
  end;
end;

// ���¿ؼ�״̬
procedure TCnComponentSelectorForm.UpdateControls;

  procedure InitComboBox(Combo: TComboBox);
  begin
    if (Combo.Items.Count > 0) and (Combo.ItemIndex < 0) then
      Combo.ItemIndex := 0;
  end;

begin
  InitComboBox(cbbFilterControl);
  InitComboBox(cbbByClass);
  InitComboBox(cbbByTag);
  InitComboBox(cbbByEvent);
  InitComboBox(cbbSourceOrderStyle);
  InitComboBox(cbbSourceOrderDir);
  cbbFilterControl.Enabled := rbSpecControl.Checked;
  cbIncludeChildren.Enabled := not rbCurrForm.Checked;
  edtByName.Enabled := cbByName.Checked;
  cbSubClass.Enabled := cbByClass.Checked;
  cbbByClass.Enabled := cbByClass.Checked;
  cbbByTag.Enabled := cbByTag.Checked;
  cbbByEvent.Enabled := chkByEvent.Checked;
  seTagStart.Enabled := cbByTag.Checked;
  seTagEnd.Enabled := cbByTag.Checked;
  seTagEnd.Visible := cbbByTag.ItemIndex = 3;
  lblTag.Visible := cbbByTag.ItemIndex = 3;

  if WizOptions.UseSearchCombo then
  begin
    FcbbByClass.Enabled := cbByClass.Checked;
    FcbbByEvent.Enabled := chkByEvent.Checked;
  end;
end;

//------------------------------------------------------------------------------
// ListBox ���򷽷�
//------------------------------------------------------------------------------

type
  TSortStyle = (ssByName, ssByClass);
  TSortDir = (sdUp, sdDown);

var
  SortStyle: TSortStyle;
  SortDir: TSortDir;

// �ַ����б��������
function DoSortProc(List: TStringList; Index1, Index2: Integer): Integer;
var
  Comp1, Comp2: TComponent;
begin
  Comp1 := TComponent(List.Objects[Index1]);
  Comp2 := TComponent(List.Objects[Index2]);
  if SortStyle = ssByName then         // ����������
    Result := AnsiCompareText(Comp1.Name, Comp2.Name)
  else
  begin
    Result := AnsiCompareText(Comp1.ClassName, Comp2.ClassName);
    if Result = 0 then                 // ���ͬ���ٰ���������
      Result := AnsiCompareText(Comp1.Name, Comp2.Name);
  end;
  if SortDir = sdDown then             // ��������
    Result := -Result;
end;

// ���б���������
procedure DoSortListBox(ListBox: TCustomListBox);
var
  SelStrs: TStrings;
  OrderStrs: TStrings;
  I: Integer;
begin
  SelStrs := nil;
  OrderStrs := nil;

  try
    SelStrs := TStringList.Create;
    OrderStrs := TStringList.Create;
    for I := 0 to ListBox.Items.Count - 1 do // ����ѡ�����Ŀ
    begin
      if ListBox.Selected[I] then
        SelStrs.Add(ListBox.Items[I]);       // ListBox.Items �� ListBoxStrings ����
    end;

    OrderStrs.Assign(ListBox.Items);         // ����ֱ������ͨ�� TStringList ������
    TStringList(OrderStrs).CustomSort(DoSortProc);
    ListBox.Items.Assign(OrderStrs);
    for I := 0 to ListBox.Items.Count - 1 do // �ָ�ѡ�����Ŀ
      ListBox.Selected[I] := SelStrs.IndexOf(ListBox.Items[I]) >= 0;
  finally
    if SelStrs <> nil then
      SelStrs.Free;
    if OrderStrs <> nil then
      OrderStrs.Free;
  end;
end;

// ��Դ�б����½�������
procedure TCnComponentSelectorForm.UpdateSourceOrders;
begin
  case cbbSourceOrderStyle.ItemIndex of
    1: SortStyle := ssByName;
    2: SortStyle := ssByClass;
  else
    Exit;
  end;
  if cbbSourceOrderDir.ItemIndex = 1 then
    SortDir := sdDown
  else
    SortDir := sdUp;

  DoSortListBox(lbSource);
end;

//------------------------------------------------------------------------------
// ���ò�����ȡ
//------------------------------------------------------------------------------

const
  csContainerFilter = 'ContainerFilter';
  csFilterControl = 'FilterControl';
  csIncludeChildren = 'IncludeChildren';
  csByName = 'ByName';
  csByNameText = 'ByNameText';
  csByClass = 'ByClass';
  csByClassText = 'ByClassText';
  csSubClass = 'SubClass';
  csByEvent = 'ByEvent';
  csByEventIndex = 'ByEventIndex';
  csByTag = 'ByTag';
  csByTagIndex = 'ByTagIndex';
  csTagStart = 'TagStart';
  csTagEnd = 'TagEnd';
  csSourceOrderStyle = 'SourceOrderStyle';
  csSourceOrderDir = 'SourceOrderDir';
  csDestOrderStyle = 'DestOrderStyle';
  csDestOrderDir = 'DestOrderDir';
  csDefaultSelAll = 'DefaultSelAll';

// װ������
procedure TCnComponentSelectorForm.LoadSettings(Ini: TCustomIniFile;
  const Section: string);
begin
  rbCurrForm.Checked := True;
  case Ini.ReadInteger(Section, csContainerFilter, 0) of
    1: if rbCurrControl.Enabled then rbCurrControl.Checked := True;
    2: if rbSpecControl.Enabled then rbSpecControl.Checked := True;
  end;
  cbbFilterControl.ItemIndex := cbbFilterControl.Items.IndexOf(
    Ini.ReadString(Section, csFilterControl, ''));
  cbIncludeChildren.Checked := Ini.ReadBool(Section, csIncludeChildren, True);
  cbByName.Checked := Ini.ReadBool(Section, csByName, False);
  edtByName.Text := Ini.ReadString(Section, csByNameText, '');
  cbByClass.Checked := Ini.ReadBool(Section, csByClass, False);
  cbbByClass.ItemIndex := cbbByClass.Items.IndexOf(
    Ini.ReadString(Section, csByClassText, ''));
  cbSubClass.Checked := Ini.ReadBool(Section, csSubClass, True);
  chkByEvent.Checked := Ini.ReadBool(Section, csByEvent, False);
  cbbByEvent.ItemIndex := Ini.ReadInteger(Section, csByEvent, 0);
  cbByTag.Checked := Ini.ReadBool(Section, csByTag, False);
  cbbByTag.ItemIndex := Ini.ReadInteger(Section, csByTagIndex, 0);
  seTagStart.Text := IntToStr(Ini.ReadInteger(Section, csTagStart, 0));
  seTagEnd.Text := IntToStr(Ini.ReadInteger(Section, csTagEnd, 0));
  cbbSourceOrderStyle.ItemIndex := Ini.ReadInteger(Section, csSourceOrderStyle, 0);
  cbbSourceOrderDir.ItemIndex := Ini.ReadInteger(Section, csSourceOrderDir, 0);
  cbDefaultSelAll.Checked := Ini.ReadBool(Section, csDefaultSelAll, True);
end;

// ��������
procedure TCnComponentSelectorForm.SaveSettings(Ini: TCustomIniFile;
  const Section: string);
var
  I: Integer;
begin
  if rbCurrControl.Checked then I := 1
  else if rbSpecControl.Checked then I := 2
  else I := 0;
  Ini.WriteInteger(Section, csContainerFilter, I);
  Ini.WriteString(Section, csFilterControl, cbbFilterControl.Text);
  Ini.WriteBool(Section, csIncludeChildren, cbIncludeChildren.Checked);
  Ini.WriteBool(Section, csByName, cbByName.Checked);
  Ini.WriteString(Section, csByNameText, edtByName.Text);
  Ini.WriteBool(Section, csByClass, cbByClass.Checked);

  if WizOptions.UseSearchCombo then
    Ini.WriteString(Section, csByClassText, FcbbByClass.Text)
  else
    Ini.WriteString(Section, csByClassText, cbbByClass.Text);
  Ini.WriteBool(Section, csSubClass, cbSubClass.Checked);
  Ini.WriteBool(Section, csByEvent, chkByEvent.Checked);

  if WizOptions.UseSearchCombo then
    Ini.WriteInteger(Section, csByEvent, FcbbByEvent.ItemIndex)
  else
    Ini.WriteInteger(Section, csByEvent, cbbByEvent.ItemIndex);

  Ini.WriteBool(Section, csByTag, cbByTag.Checked);
  Ini.WriteInteger(Section, csByTagIndex, cbbByTag.ItemIndex);
  Ini.WriteInteger(Section, csTagStart, StrToIntDef(seTagStart.Text, 0));
  Ini.WriteInteger(Section, csTagEnd, StrToIntDef(seTagEnd.Text, 0));
  Ini.WriteInteger(Section, csSourceOrderStyle, cbbSourceOrderStyle.ItemIndex);
  Ini.WriteInteger(Section, csSourceOrderDir, cbbSourceOrderDir.ItemIndex);
  Ini.WriteBool(Section, csDefaultSelAll, cbDefaultSelAll.Checked);
end;

//------------------------------------------------------------------------------
// �ؼ��¼�����
//------------------------------------------------------------------------------

// ��ʼ�����б�
procedure TCnComponentSelectorForm.BeginUpdateList;
begin
  lbSource.Items.BeginUpdate;
  lbDest.Items.BeginUpdate;
end;

// ���������б�
procedure TCnComponentSelectorForm.EndUpdateList;
begin
  lbSource.Items.EndUpdate;
  lbDest.Items.EndUpdate;
end;

// ���¶�Դ�б�����
procedure TCnComponentSelectorForm.DoUpdateSourceOrder(
  Sender: TObject);
begin
  if cbbSourceOrderStyle.ItemIndex <= 0 then
    UpdateList
  else
    UpdateSourceOrders;
end;

// �����б�
procedure TCnComponentSelectorForm.DoUpdateList(Sender: TObject);
begin
  UpdateList;
end;

// �����б�Ϳؼ�״̬
procedure TCnComponentSelectorForm.DoUpdateListControls(Sender: TObject);
begin
  UpdateControls;
  UpdateList;
end;

// ���ð���
procedure TCnComponentSelectorForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnComponentSelectorForm.GetHelpTopic: string;
begin
  Result := 'CnComponentSelector';
end;

//------------------------------------------------------------------------------
// ActionList �¼�����
//------------------------------------------------------------------------------

// Action ����
procedure TCnComponentSelectorForm.DoActionListUpdate(Sender: TObject);
begin
  actAdd.Enabled := lbSource.SelCount > 0;
  actAddAll.Enabled := lbSource.Items.Count > 0;
  actDelete.Enabled := lbDest.SelCount > 0;
  actDeleteAll.Enabled := lbDest.Items.Count > 0;
  actSelAll.Enabled := lbSource.SelCount < lbSource.Items.Count;
  actSelNone.Enabled := lbSource.SelCount > 0;
  actSelInvert.Enabled := lbSource.Items.Count > 0;
  actMoveToTop.Enabled := lbDest.SelCount > 0;
  actMoveToBottom.Enabled := lbDest.SelCount > 0;
  actMoveUp.Enabled := lbDest.SelCount > 0;
  actMoveDown.Enabled := lbDest.SelCount > 0;
end;

// ����ѡ��
procedure TCnComponentSelectorForm.actAddExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 0 to lbSource.Items.Count - 1 do
      if lbSource.Selected[I] then
        lbDest.Items.AddObject(lbSource.Items[I], lbSource.Items.Objects[I]);
    for I := lbSource.Items.Count - 1 downto 0 do
      if lbSource.Selected[I] then
        lbSource.Items.Delete(I);
  finally
    EndUpdateList;
  end;
end;

// ����ȫ��ѡ��
procedure TCnComponentSelectorForm.actAddAllExecute(Sender: TObject);
begin
  BeginUpdateList;
  try
    lbDest.Items.AddStrings(lbSource.Items);
    lbSource.Items.Clear;
  finally
    EndUpdateList;
  end;
end;

// ɾ��ѡ��
procedure TCnComponentSelectorForm.actDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 0 to lbDest.Items.Count - 1 do // ֻ�е�ǰ�����б����еĲż��뵽���
      if lbDest.Selected[I] and (CurrList.IndexOf(lbDest.Items[I]) >= 0) then
        lbSource.Items.AddObject(lbDest.Items[I], lbDest.Items.Objects[I]);
    for I := lbDest.Items.Count - 1 downto 0 do
      if lbDest.Selected[I] then
        lbDest.Items.Delete(I);
  finally
    UpdateSourceOrders;
    EndUpdateList;
  end;
end;

// ɾ��ȫ��ѡ��
procedure TCnComponentSelectorForm.actDeleteAllExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 0 to lbDest.Items.Count - 1 do // ֻ�е�ǰ�����б����еĲż��뵽���
      if CurrList.IndexOf(lbDest.Items[I]) >= 0 then
        lbSource.Items.AddObject(lbDest.Items[I], lbDest.Items.Objects[I]);
    lbDest.Items.Clear;
  finally
    UpdateSourceOrders;
    EndUpdateList;
  end;
end;

// ѡ��ȫ��
procedure TCnComponentSelectorForm.actSelAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := True;
end;

// ȡ��ѡ��
procedure TCnComponentSelectorForm.actSelNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := False;
end;

// ��תѡ��
procedure TCnComponentSelectorForm.actSelInvertExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := not lbSource.Selected[I];
end;

// �ƶ�������
procedure TCnComponentSelectorForm.actMoveToTopExecute(Sender: TObject);
var
  I, J: Integer;
begin
  BeginUpdateList;
  try
    J := 0;
    for I := 0 to lbDest.Items.Count - 1 do
    begin
      if lbDest.Selected[I] then
      begin
        lbDest.Items.Move(I, J);
        lbDest.Selected[J] := True;
        Inc(J);
      end;
    end;
  finally
    EndUpdateList;
  end;
end;

// �ƶ����ײ�
procedure TCnComponentSelectorForm.actMoveToBottomExecute(Sender: TObject);
var
  I, J: Integer;
begin
  BeginUpdateList;
  try
    J := lbDest.Items.Count - 1;
    for I := lbDest.Items.Count - 1 downto 0 do
    begin
      if lbDest.Selected[I] then
      begin
        lbDest.Items.Move(I, J);
        lbDest.Selected[J] := True;
        Dec(J);
      end;
    end;
  finally
    EndUpdateList;
  end;
end;

// ����һ��
procedure TCnComponentSelectorForm.actMoveUpExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 1 to lbDest.Items.Count - 1 do
    begin
      if lbDest.Selected[I] and not lbDest.Selected[I - 1] then
      begin
        lbDest.Items.Move(I, I - 1);
        lbDest.Selected[I - 1] := True;
      end;
    end;
  finally
    EndUpdateList;
  end;
end;

// ����һ��
procedure TCnComponentSelectorForm.actMoveDownExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := lbDest.Items.Count - 2 downto 0 do
    begin
      if lbDest.Selected[I] and not lbDest.Selected[I + 1] then
      begin
        lbDest.Items.Move(I, I + 1);
        lbDest.Selected[I + 1] := True;
      end;
    end;
  finally
    EndUpdateList;
  end;
end;

// ����絥�����ã�����ѡ���������ʵ�������� Selections ������Ƿ�ѡ��ɹ�
function SelectComponentsWithSelector(Selections: TComponentList): Boolean;
var
  Ini: TCustomIniFile;
  Root: TComponent;
  FormDesigner: TCnIDEDesigner;
  SourceList, DestList: TCnDesignerSelectionList;
  I: Integer;
  Component: TComponent;
  Wizard: TCnComponentSelector;
begin
  Result := False;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then
    Exit;

  Wizard := TCnComponentSelector(CnWizardMgr.WizardByClass(TCnComponentSelector));
  if Wizard <> nil then
    Ini := Wizard.CreateIniFile
  else
    Ini := nil;

  try
{$IFDEF LAZARUS}
    Root := TComponent(GlobalDesignHook.LookupRoot);
{$ELSE}
    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
{$ENDIF}

{$IFDEF DEBUG}
    if Root <> nil then
      CnDebugger.LogFmt('SelectComponents GetRoot %s: %s', [Root.ClassName, Root.Name]);
  {$IFDEF LAZARUS}
    CnDebugger.LogFmt('SelectComponents Root Class: %s', [GlobalDesignHook.GetRootClassName]);
  {$ELSE}
    CnDebugger.LogFmt('SelectComponents Root Class: %s', [FormDesigner.GetRootClassName]);
  {$ENDIF}
{$ENDIF}

{$IFDEF LAZARUS}
    SourceList := TCnDesignerSelectionList.Create;
    DestList := TCnDesignerSelectionList.Create;
{$ELSE}
    SourceList := CreateSelectionList;
    DestList := CreateSelectionList;
{$ENDIF}
    // FormDesigner.GetSelections(SourceList); // �ֹ�ѡ��ʱ������ǰ�����ѡ��ؼ�

    with TCnComponentSelectorForm.CreateEx(nil, Ini, SourceList, DestList,
      TWinControl(Root)) do
    try
      ShowHint := WizOptions.ShowHint;
      if ShowModal = mrOK then
      begin
        Selections.Clear;

        for I := 0 to DestList.Count - 1 do
        begin
{$IFDEF LAZARUS}
          Component := TComponent(DestList[I]);
{$ELSE}
{$IFDEF COMPILER6_UP}
          Component := TComponent(DestList[I]);
{$ELSE}
          Component := TryExtractComponent(DestList[I]);
{$ENDIF}
{$ENDIF}
          Selections.Add(Component);
        end;
        Result := Selections.Count > 0;
      end;
    finally
      Free;
    end;
  finally
    Ini.Free;
  end;
end;

//==============================================================================
// ���ѡ��ר����
//==============================================================================

{ TCnComponentSelector }

// ר��ִ��������
procedure TCnComponentSelector.Execute;
var
  Ini: TCustomIniFile;
  Root: TComponent;
  FormDesigner: TCnIDEDesigner;
  SourceList, DestList: TCnDesignerSelectionList;
begin
  if not Active and not Action.Enabled then
    Exit;

  Ini := CreateIniFile;
  try
{$IFDEF LAZARUS}
    Root := TComponent(GlobalDesignHook.LookupRoot);
{$ELSE}
    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
{$ENDIF}

{$IFDEF DEBUG}
    if Root <> nil then
      CnDebugger.LogFmt('ComponentSelector GetRoot %s: %s', [Root.ClassName, Root.Name]);
{$ENDIF}

    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
  {$IFDEF LAZARUS}
    CnDebugger.LogFmt('ComponentSelector Root Class: %s', [GlobalDesignHook.GetRootClassName]);
  {$ELSE}
    CnDebugger.LogFmt('ComponentSelector Root Class: %s', [FormDesigner.GetRootClassName]);
  {$ENDIF}
{$ENDIF}

{$IFDEF LAZARUS}
    SourceList := TCnDesignerSelectionList.Create;
    DestList := TCnDesignerSelectionList.Create;
    GlobalDesignHook.GetSelection(SourceList);
{$ELSE}
    SourceList := CreateSelectionList;
    DestList := CreateSelectionList;
    FormDesigner.GetSelections(SourceList);
{$ENDIF}

    with TCnComponentSelectorForm.CreateEx(nil, Ini, SourceList, DestList,
      TWinControl(Root)) do
    try
      ShowHint := WizOptions.ShowHint;
      if ShowModal = mrOK then
      begin
{$IFDEF LAZARUS}
        GlobalDesignHook.SetSelection(DestList);
{$ELSE}
        FormDesigner.SetSelections(DestList);
{$ENDIF}
      end;
    finally
      Free;
    end;
  finally
    Ini.Free;
  end;
end;

//------------------------------------------------------------------------------
// ר�� override ����
//------------------------------------------------------------------------------

// ȡר�Ҳ˵�����
function TCnComponentSelector.GetCaption: string;
begin
  Result := SCnCompSelectorMenuCaption;
end;

// ȡר��Ĭ�Ͽ�ݼ�
function TCnComponentSelector.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

// ȡר���Ƿ������ô���
function TCnComponentSelector.GetHasConfig: Boolean;
begin
  Result := False;
end;

// ȡר�Ұ�ť��ʾ
function TCnComponentSelector.GetHint: string;
begin
  Result := SCnCompSelectorMenuHint;
end;

// ����ר��״̬
function TCnComponentSelector.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + 'ѡ��,selection,';
end;

function TCnComponentSelector.GetState: TWizardState;
begin
  Result := [];
{$IFDEF LAZARUS}
  if CnOtaGetFormDesigner <> nil then
    Result := [wsEnabled];
{$ELSE}
  if CurrentIsForm then
    Result := [wsEnabled];              // ��ǰ�༭���ļ��Ǵ���ʱ������
{$ENDIF}
end;

// ����ר����Ϣ
class procedure TCnComponentSelector.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnCompSelectorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnCompSelectorComment;
end;

initialization
  RegisterCnWizard(TCnComponentSelector); // ע��ר��

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}
end.
