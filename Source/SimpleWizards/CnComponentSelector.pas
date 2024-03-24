{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnComponentSelector;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件选择工具专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：WizOptions.UseSearchCombo 为 True 时，cbbByClass 和 cbbByEvent
*           会被 SearchComboBox 替之
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2021.07.27 V1.3
*               增加一独立函数可供调用以返回选择控件
*           2003.04.16 V1.2
*               修正切换 Tag 范围类型为“介于”时，第二个 SpinEdit 不能显示的错误
*           2003.03.12 V1.1
*               修正不支持默认排序的问题
*           2002.10.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCOMPONENTSELECTOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, IniFiles, Registry, Menus, ToolsAPI,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  ActnList, TypInfo, Contnrs, CnConsts, CnWizClasses, CnWizConsts, CnWizUtils,
  CnCommon, CnSpin, CnSearchCombo, CnWizOptions, CnWizMultiLang, CnWizManager;

type

//==============================================================================
// 组件选择专家窗体
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
    FSourceList, FDestList: IDesignerSelections;
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
    property SourceList: IDesignerSelections read FSourceList;
    property DestList: IDesignerSelections read FDestList;
    property ContainerWindow: TWinControl read FContainerWindow;
    property CurrList: TStrings read FCurrList;
    function GetHelpTopic: string; override;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile; ASourceList,
      ADestList: IDesignerSelections; AContainerWindow: TWinControl);
    procedure LoadSettings(Ini: TCustomIniFile; const Section: string); virtual;
    procedure SaveSettings(Ini: TCustomIniFile; const Section: string); virtual;
  end;

//==============================================================================
// 组件选择专家类
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
{* 供外界单独调用，用来选择组件并将实例返回于 Selections 里，返回是否选择成功}

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

implementation

{$IFDEF CNWIZARDS_CNCOMPONENTSELECTOR}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// 组件选择专家窗体
//==============================================================================

{ TCnComponentSelectorForm }

// 扩展的构造器，增加了输入输出组件列表、设计窗体
constructor TCnComponentSelectorForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile; ASourceList, ADestList: IDesignerSelections;
  AContainerWindow: TWinControl);
begin
  Create(AOwner);
  FIni := AIni;
  FSourceList := ASourceList;
  FDestList := ADestList;
  FContainerWindow := AContainerWindow;
end;

// 窗体初始化
procedure TCnComponentSelectorForm.FormCreate(Sender: TObject);
begin
  FCurrList := TStringList.Create;
  InitControls;
  if Ini <> nil then
    LoadSettings(Ini, '');
  UpdateControls;
  UpdateList;
end;

// 窗体释放
procedure TCnComponentSelectorForm.FormDestroy(Sender: TObject);
begin
  if Ini <> nil then
    SaveSettings(Ini, '');
  FCurrList.Free;
end;

// 确定返回选择结果
procedure TCnComponentSelectorForm.btnOKClick(Sender: TObject);
var
  I: Integer;
begin
  if lbDest.Items.Count > 0 then       // 选择列表不为空
  begin
    for I := 0 to lbDest.Items.Count - 1 do
    {$IFDEF COMPILER6_UP}
      DestList.Add(TComponent(lbDest.Items.Objects[I]));
    {$ELSE}
      DestList.Add(MakeIPersistent(TComponent(lbDest.Items.Objects[I])));
    {$ENDIF}
  end
  else if cbDefaultSelAll.Checked then // 无选择结果时自动返回所有内容
  begin
    for I := 0 to lbSource.Items.Count - 1 do
    {$IFDEF COMPILER6_UP}
      DestList.Add(TComponent(lbSource.Items.Objects[I]));
    {$ELSE}
      DestList.Add(MakeIPersistent(TComponent(lbSource.Items.Objects[I])));
    {$ENDIF}
  end;
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------
// 控件设置方法
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

// 初始化控件，只会被调用一次
procedure TCnComponentSelectorForm.InitControls;
var
  I: Integer;
  WinControl: TWinControl;
  SelIsEmpty: Boolean;
  Component: TComponent;
  List: TStringList;
begin
  // 检查当前选择的组件列表是否包含子控件
  SelIsEmpty := True;
  for I := 0 to SourceList.Count - 1 do
  begin
{$IFDEF COMPILER6_UP}
    Component := TComponent(SourceList[I]);
{$ELSE}
    Component := TryExtractComponent(SourceList[I]);
{$ENDIF}
    if Component = ContainerWindow then
      Break; // 选择部分包含窗体本身
    if (Component is TWinControl) and (TWinControl(Component).ControlCount > 0) then
    begin
      SelIsEmpty := False;
      Break;
    end;
  end;
  rbCurrControl.Enabled := not SelIsEmpty;
  if rbCurrControl.Checked and SelIsEmpty then
    rbCurrForm.Checked := True;

  // 初始化容器控件列表
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

    // 初始化类列表
    FCbbByClass.Items.Clear;
    for I := 0 to ContainerWindow.ComponentCount - 1 do
      with ContainerWindow.Components[I] do
        if FCbbByClass.Items.IndexOf(ClassName) < 0 then
          FCbbByClass.Items.AddObject(ClassName, Pointer(ClassType));

    // 初始化事件列表
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
    // 初始化类列表
    cbbByClass.Items.Clear;
    for I := 0 to ContainerWindow.ComponentCount - 1 do
      with ContainerWindow.Components[I] do
        if cbbByClass.Items.IndexOf(ClassName) < 0 then
          cbbByClass.Items.AddObject(ClassName, Pointer(ClassType));

    // 初始化事件列表
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

// 更新当前过滤列表
procedure TCnComponentSelectorForm.UpdateList;
var
  I, J: Integer;
  SelStrs: TStrings;
  Component: TComponent;
  WinControl: TWinControl;
  
  // 名称是否匹配
  function MatchName(const AName: string): Boolean;
  begin
    Result := not cbByName.Checked or (edtByName.Text = '') or
      (AnsiPos(UpperCase(edtByName.Text), UpperCase(AName)) > 0);
  end;

  // 类型是否匹配
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

  // 事件是否匹配
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

  // Tag 是否匹配
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

  // 增加一项条目
  procedure AddItem(AComponent: TComponent; IncludeChildren: Boolean = False);
  var
    s: string;
    I: Integer;
  begin
    // 判断是否匹配
    if (AComponent.Name <> '') and MatchName(AComponent.Name) and MatchClass(AComponent)
      and MatchEvent(AComponent) and MatchTag(AComponent.Tag)
      and (CurrList.IndexOfObject(AComponent) < 0) then
    begin
      s := AComponent.Name + ': ' + AComponent.ClassName;
      CurrList.AddObject(s, AComponent);  // 增加到当前过滤列表
      if lbDest.Items.IndexOf(s) < 0 then
        lbSource.Items.AddObject(s, AComponent); // 只增加不在已选择列表中的项
    end;
    // 递归增加子控件
    if IncludeChildren and (AComponent is TWinControl) then
      with TWinControl(AComponent) do
        for I := 0 to ControlCount - 1 do
          AddItem(Controls[I], True);
  end;
begin
  BeginUpdateList;
  try
    SelStrs := TStringList.Create;
    try
      for I := 0 to lbSource.Items.Count - 1 do // 保存当前已选择的列表
        if lbSource.Selected[I] then
          SelStrs.Add(lbSource.Items[I]);
      CurrList.Clear;
      lbSource.Clear;
      if rbCurrForm.Checked then       // 窗体上所有组件
      begin
        for I := 0 to ContainerWindow.ComponentCount - 1 do
          AddItem(ContainerWindow.Components[I]);
      end
      else if rbCurrControl.Checked then // 当前选择控件的子控件
      begin
        for I := 0 to SourceList.Count - 1 do
        begin
        {$IFDEF COMPILER6_UP}
          Component := TComponent(SourceList[I]);
        {$ELSE}
          Component := TryExtractComponent(SourceList[I]);
        {$ENDIF}
          if Component is TWinControl then
          begin
            WinControl := TWinControl(Component);
            for J := 0 to WinControl.ControlCount - 1 do
              AddItem(WinControl.Controls[J], cbIncludeChildren.Checked);
          end;
        end;
      end
      else if rbSpecControl.Checked then // 指定控件的子控件
      begin
        if cbbFilterControl.ItemIndex >= 0 then
        begin
          WinControl := TWinControl(cbbFilterControl.Items.Objects[cbbFilterControl.ItemIndex]);
            for I := 0 to WinControl.ControlCount - 1 do
              AddItem(WinControl.Controls[I], cbIncludeChildren.Checked);
        end;
      end;
      for I := 0 to lbSource.Items.Count - 1 do // 恢复保存的选择列表
        lbSource.Selected[I] := SelStrs.IndexOf(lbSource.Items[I]) >= 0;
    finally
      SelStrs.Free;
    end;
  finally
    UpdateSourceOrders;
    EndUpdateList;
  end;
end;

// 更新控件状态
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
// ListBox 排序方法
//------------------------------------------------------------------------------

type
  TSortStyle = (ssByName, ssByClass);
  TSortDir = (sdUp, sdDown);

var
  SortStyle: TSortStyle;
  SortDir: TSortDir;

// 字符串列表排序过程
function DoSortProc(List: TStringList; Index1, Index2: Integer): Integer;
var
  Comp1, Comp2: TComponent;
begin
  Comp1 := TComponent(List.Objects[Index1]);
  Comp2 := TComponent(List.Objects[Index2]);
  if SortStyle = ssByName then         // 按名称排序
    Result := AnsiCompareText(Comp1.Name, Comp2.Name)
  else
  begin
    Result := AnsiCompareText(Comp1.ClassName, Comp2.ClassName);
    if Result = 0 then                 // 如果同类再按名称排序
      Result := AnsiCompareText(Comp1.Name, Comp2.Name);
  end;
  if SortDir = sdDown then             // 反向排序
    Result := -Result;
end;

// 对列表框进行排序
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
    for I := 0 to ListBox.Items.Count - 1 do // 保存选择的条目
      if ListBox.Selected[I] then
        SelStrs.Add(ListBox.Items[I]);       // ListBox.Items 是 ListBoxStrings 类型
    OrderStrs.Assign(ListBox.Items);         // 不能直接排序，通过 TStringList 来进行
    TStringList(OrderStrs).CustomSort(DoSortProc);
    ListBox.Items.Assign(OrderStrs);
    for I := 0 to ListBox.Items.Count - 1 do // 恢复选择的条目
      ListBox.Selected[I] := SelStrs.IndexOf(ListBox.Items[I]) >= 0;
  finally
    if SelStrs <> nil then SelStrs.Free;
    if OrderStrs <> nil then OrderStrs.Free;
  end;
end;

// 对源列表重新进行排序
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
// 设置参数存取
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

// 装载设置
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

// 保存设置
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
// 控件事件处理
//------------------------------------------------------------------------------

// 开始更新列表
procedure TCnComponentSelectorForm.BeginUpdateList;
begin
  lbSource.Items.BeginUpdate;
  lbDest.Items.BeginUpdate;
end;

// 结束更新列表
procedure TCnComponentSelectorForm.EndUpdateList;
begin
  lbSource.Items.EndUpdate;
  lbDest.Items.EndUpdate;
end;

// 重新对源列表排序
procedure TCnComponentSelectorForm.DoUpdateSourceOrder(
  Sender: TObject);
begin
  if cbbSourceOrderStyle.ItemIndex <= 0 then
    UpdateList
  else
    UpdateSourceOrders;
end;

// 更新列表
procedure TCnComponentSelectorForm.DoUpdateList(Sender: TObject);
begin
  UpdateList;
end;

// 更新列表和控件状态
procedure TCnComponentSelectorForm.DoUpdateListControls(Sender: TObject);
begin
  UpdateControls;
  UpdateList;
end;

// 调用帮助
procedure TCnComponentSelectorForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnComponentSelectorForm.GetHelpTopic: string;
begin
  Result := 'CnComponentSelector';
end;

//------------------------------------------------------------------------------
// ActionList 事件处理
//------------------------------------------------------------------------------

// Action 更新
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

// 增加选择
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

// 增加全部选择
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

// 删除选择
procedure TCnComponentSelectorForm.actDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 0 to lbDest.Items.Count - 1 do // 只有当前过滤列表中有的才加入到左边
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

// 删除全部选择
procedure TCnComponentSelectorForm.actDeleteAllExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 0 to lbDest.Items.Count - 1 do // 只有当前过滤列表中有的才加入到左边
      if CurrList.IndexOf(lbDest.Items[I]) >= 0 then
        lbSource.Items.AddObject(lbDest.Items[I], lbDest.Items.Objects[I]);
    lbDest.Items.Clear;
  finally
    UpdateSourceOrders;
    EndUpdateList;
  end;
end;

// 选择全部
procedure TCnComponentSelectorForm.actSelAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := True;
end;

// 取消选择
procedure TCnComponentSelectorForm.actSelNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := False;
end;

// 反转选择
procedure TCnComponentSelectorForm.actSelInvertExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbSource.Items.Count - 1 do
    lbSource.Selected[I] := not lbSource.Selected[I];
end;

// 移动到顶部
procedure TCnComponentSelectorForm.actMoveToTopExecute(Sender: TObject);
var
  I, J: Integer;
begin
  BeginUpdateList;
  try
    J := 0;
    for I := 0 to lbDest.Items.Count - 1 do
      if lbDest.Selected[I] then
      begin
        lbDest.Items.Move(I, J);
        lbDest.Selected[J] := True;
        Inc(J);
      end;
  finally
    EndUpdateList;
  end;
end;

// 移动到底部
procedure TCnComponentSelectorForm.actMoveToBottomExecute(Sender: TObject);
var
  I, J: Integer;
begin
  BeginUpdateList;
  try
    J := lbDest.Items.Count - 1;
    for I := lbDest.Items.Count - 1 downto 0 do
      if lbDest.Selected[I] then
      begin
        lbDest.Items.Move(I, J);
        lbDest.Selected[J] := True;
        Dec(J);
      end;
  finally
    EndUpdateList;
  end;
end;

// 上移一格
procedure TCnComponentSelectorForm.actMoveUpExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := 1 to lbDest.Items.Count - 1 do
      if lbDest.Selected[I] and not lbDest.Selected[I - 1] then
      begin
        lbDest.Items.Move(I, I - 1);
        lbDest.Selected[I - 1] := True;
      end;
  finally
    EndUpdateList;
  end;
end;

// 下移一格
procedure TCnComponentSelectorForm.actMoveDownExecute(Sender: TObject);
var
  I: Integer;
begin
  BeginUpdateList;
  try
    for I := lbDest.Items.Count - 2 downto 0 do
      if lbDest.Selected[I] and not lbDest.Selected[I + 1] then
      begin
        lbDest.Items.Move(I, I + 1);
        lbDest.Selected[I + 1] := True;
      end;
  finally
    EndUpdateList;
  end;
end;

// 供外界单独调用，用来选择组件并将实例返回于 Selections 里，返回是否选择成功
function SelectComponentsWithSelector(Selections: TComponentList): Boolean;
var
  Ini: TCustomIniFile;
  Root: TComponent;
  FormDesigner: IDesigner;
  SourceList, DestList: IDesignerSelections;
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
    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
{$IFDEF DEBUG}
    if Root <> nil then
      CnDebugger.LogFmt('SelectComponents GetRoot %s: %s', [Root.ClassName, Root.Name]);
    CnDebugger.LogFmt('SelectComponents Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

    SourceList := CreateSelectionList;
    DestList := CreateSelectionList;
    // FormDesigner.GetSelections(SourceList); // 手工选择时无需提前拎出被选择控件

    with TCnComponentSelectorForm.CreateEx(nil, Ini, SourceList, DestList,
      TWinControl(Root)) do
    try
      ShowHint := WizOptions.ShowHint;
      if ShowModal = mrOK then
      begin
        Selections.Clear;

        for I := 0 to DestList.Count - 1 do
        begin
{$IFDEF COMPILER6_UP}
          Component := TComponent(DestList[I]);
{$ELSE}
          Component := TryExtractComponent(DestList[I]);
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
// 组件选择专家类
//==============================================================================

{ TCnComponentSelector }

// 专家执行主过程
procedure TCnComponentSelector.Execute;
var
  Ini: TCustomIniFile;
  Root: TComponent;
  FormDesigner: IDesigner;
  SourceList, DestList: IDesignerSelections;
begin
  if not Active and not Action.Enabled then
    Exit;

  Ini := CreateIniFile;
  try
    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
{$IFDEF DEBUG}
    if Root <> nil then
      CnDebugger.LogFmt('ComponentSelector GetRoot %s: %s', [Root.ClassName, Root.Name]);
{$ENDIF}

    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ComponentSelector Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

    SourceList := CreateSelectionList;
    DestList := CreateSelectionList;
    FormDesigner.GetSelections(SourceList);
    
    with TCnComponentSelectorForm.CreateEx(nil, Ini, SourceList, DestList,
      TWinControl(Root)) do
    try
      ShowHint := WizOptions.ShowHint;
      if ShowModal = mrOK then
        FormDesigner.SetSelections(DestList);
    finally
      Free;
    end;
  finally
    Ini.Free;
  end;
end;

//------------------------------------------------------------------------------
// 专家 override 方法
//------------------------------------------------------------------------------

// 取专家菜单标题
function TCnComponentSelector.GetCaption: string;
begin
  Result := SCnCompSelectorMenuCaption;
end;

// 取专家默认快捷键
function TCnComponentSelector.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

// 取专家是否有设置窗口
function TCnComponentSelector.GetHasConfig: Boolean;
begin
  Result := False;
end;

// 取专家按钮提示
function TCnComponentSelector.GetHint: string;
begin
  Result := SCnCompSelectorMenuHint;
end;

// 返回专家状态
function TCnComponentSelector.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '选择,selection,';
end;

function TCnComponentSelector.GetState: TWizardState;
begin
  if CurrentIsForm then
    Result := [wsEnabled]              // 当前编辑的文件是窗体时才启用
  else
    Result := [];
end;

// 返回专家信息
class procedure TCnComponentSelector.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnCompSelectorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnCompSelectorComment;
end;

initialization
  RegisterCnWizard(TCnComponentSelector); // 注册专家

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}
end.
