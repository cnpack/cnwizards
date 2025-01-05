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

unit CnWinTopRoller;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWinTopRoller 专家和设置窗体
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：为 IDE 中的窗体的标题栏增加置顶和折叠按钮，之前不支持 BDS，后来放开
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2004.07.22 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNWINTOPROLLER}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Contnrs, IniFiles, ActnList, Menus,
  CnConsts, CnWizConsts, CnCommon, CnWizClasses, CnWizMultiLang, CnWizNotifier,
  CnWizOptions;

type
  TCnWinFilterItem = class(TObject)
  {* 描述一过滤规则 }
  private
    FEnabled: Boolean;
    FWinClass: string;
    FComment: string;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property WinClass: string read FWinClass write FWinClass;
    property Comment: string read FComment write FComment;
  end;

  TCnRollerFormStatusItem = class(TObject)
  {* 描述一折叠状态 }
  private
    FRolled: Boolean;
    FFormClass: string;
    FOldHeight: Integer;
  published
    property FormClass: string read FFormClass write FFormClass;
    property Rolled: Boolean read FRolled write FRolled;
    property OldHeight: Integer read FOldHeight write FOldHeight;
  end;

  TCnWinTopRoller = class(TCnIDEEnhanceWizard)
  private
    FFilters: TObjectList;
    FRollerStatus: TObjectList;
    FClassList: TStrings;
    FFiltered: Boolean;
    FCaptionPacked: Boolean;
    FAnimate: Boolean;
    FShowTop: Boolean;
    FShowRoller: Boolean;
    FShowOptions: Boolean;
    FPopup: TPopupMenu;
    procedure SetCaptionPacked(Value: Boolean);
    procedure SetAnimate(Value: Boolean);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    function CheckFiltered(AForm: TCustomForm): Boolean;
    procedure LoadFilterAndStatus(const AFileName: string);
    procedure SaveFilterAndStatus(const AFileName: string);
    procedure AddButtonToForm(AForm: TCustomForm);
    {* 替一 Form 增加标题栏按钮 }
    procedure CreateButtons(AButtons: TComponent; AForm: TCustomForm;
      IsInit: Boolean = False);
    {* 重新创建各个按钮 }
    function InitPopupMenu(AMenu: TPopupMenu): TPopupMenu;
    {* 初始化弹出菜单 }
    procedure InitClassList;
    procedure RefreshFormsButton(IsInit: Boolean = False);
    {* 根据修改后的过滤规则，重新设置窗体按钮类型以及是否使能 }
    procedure RestoreRollerWindow(AButtons: TComponent);
    {* 重新恢复已经折叠的窗口 }
    function IndexOfStatus(const AClassName: string): TCnRollerFormStatusItem;
    procedure ActiveFormChanged(Sender: TObject);
    procedure ButtonRolled(Sender: TObject);
    procedure PopupOnOptionClick(Sender: TObject);
    procedure PopupOnAddClick(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;

    procedure Config; override;
    procedure LanguageChanged(Sender: TObject); override;

    procedure AddFilteredClass(const AClassName: string; const Comment: string = '');
    {* 供外部调用以增加屏蔽规则 }
    property ClassList: TStrings read FClassList;
    {* 根据使能的过滤规则生成的类名列表，搜索比较之用 }
    property Filters: TObjectList read FFilters;
    {* 容纳所有过滤规则，规则可持久化 }
    property RollerStatus: TObjectList read FRollerStatus;
    {* 容纳折叠状态 }
  published
    property Filtered: Boolean read FFiltered write FFiltered;
    property CaptionPacked: Boolean read FCaptionPacked write SetCaptionPacked;
    property Animate: Boolean read FAnimate write SetAnimate;
    property ShowTop: Boolean read FShowTop write FShowTop;
    property ShowRoller: Boolean read FShowRoller write FShowRoller;
    property ShowOptions: Boolean read FShowOptions write FShowOptions;
  end;

  TCnTopRollerForm = class(TCnTranslateForm)
    grpMain: TGroupBox;
    chkCaptionPacked: TCheckBox;
    grpFilter: TGroupBox;
    chkFilter: TCheckBox;
    ListView: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkAnimate: TCheckBox;
    cbbClassName: TComboBox;
    cbbComment: TComboBox;
    btnReplace: TButton;
    btnAdd: TButton;
    btnDel: TButton;
    ActionList: TActionList;
    actReplace: TAction;
    actAdd: TAction;
    actDelete: TAction;
    lblButtons: TLabel;
    chkShowTop: TCheckBox;
    chkShowRoller: TCheckBox;
    chkShowOptions: TCheckBox;
    procedure ListViewClick(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure cbbClassNameChange(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbbCommentChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadRules(AList: TObjectList);
    procedure SaveRules(AList: TObjectList);
  end;

{$ENDIF CNWIZARDS_CNWINTOPROLLER}

implementation

{$IFDEF CNWIZARDS_CNWINTOPROLLER}

{$R *.DFM}

uses
  mxCaptionBarButtons;

const
  SCnCaptionBarButtonName = 'CnCaptionBarButton';
  SCnFilterFile = 'TopRoller.dat';
  SCnRollerStatusPrefix = 'RollerStatus:';

  csShowTop = 'ShowTop';
  csShowRoller = 'ShowRoller';
  csShowOptions = 'ShowOptions';
  csFiltered = 'Filtered';
  csCaptionPacked = 'CaptionPacked';
  csAnimate = 'Animate';

  arrTopWinClasses: array[0..6] of string = // 所有有 Stay on Top 功能的窗体类名
    ('TObjectTreeView', 'TPropertyInspector', 'TProjectManagerForm',
     'TAlignPalette', 'TCallStackWindow', 'TWatchWindow', 'TLocalVarsWindow');

  arrRollerStatusClasses: array[0..19] of string = // 所有单实例的窗体，会被 Desktop 保存的
    ('TAppBuilder', 'TObjectTreeView', 'TPropertyInspector',
    'TPasModExpForm', 'TProjectManagerForm', 'TToDoListWindow',
    'TAlignPalette', 'TSynbolExplorer', 'TCompListForm', 'TMessageHintFrm',
    'TBPWindow', 'TCallStackWindow', 'TWatchWindow', 'TLocalVarsWindow',
    'TThreadStatus', 'TModulesView', 'TDebugLogView', 'TDisassemblyView',
    'TFPUWindow', 'TEvalDialog');

{ TCnWinTopRoller }

procedure TCnWinTopRoller.ActiveFormChanged(Sender: TObject);
var
  ActiveForm: TCustomForm;
  Buttons: TComponent;
begin
  ActiveForm := Screen.ActiveCustomForm;

  if (ActiveForm = nil) or CheckFiltered(ActiveForm) then
    Exit;

  Buttons := ActiveForm.FindComponent(SCnCaptionBarButtonName);
  if Active and (Buttons = nil) then
    AddButtonToForm(ActiveForm);
end;

procedure TCnWinTopRoller.AddButtonToForm(AForm: TCustomForm);
var
  Buttons: TmxCaptionBarButtons;
begin
  Buttons := TmxCaptionBarButtons.Create(AForm);
  CreateButtons(Buttons, AForm, True);
  Buttons.Loaded;
end;

procedure TCnWinTopRoller.AddFilteredClass(const AClassName,
  Comment: string);
var
  AItem: TCnWinFilterItem;
  I: Integer;
begin
  if AClassName <> '' then
  begin
    for I := 0 to FFilters.Count - 1 do
    begin
      if (Filters.Items[I] as TCnWinFilterItem).WinClass = AClassName then
        Exit;
    end;

    AItem := TCnWinFilterItem.Create;
    AItem.Enabled := True;
    AItem.WinClass := AClassName;
    if Comment = '' then
      AItem.Comment := AClassName
    else
      AItem.Comment := Comment;

    FFilters.Add(AItem);
    InitClassList;
    RefreshFormsButton;
  end;
end;

procedure TCnWinTopRoller.ButtonRolled(Sender: TObject);
var
  FormName: string;
  RolledUp: Boolean;
  AStatus: TCnRollerFormStatusItem;
begin
  if (Sender is TmxCaptionButton) and
    ((Sender as TmxCaptionButton).ButtonType = btRoller) then
  begin
    if (Sender as TmxCaptionButton).BarButtons.Parent <> nil then
    begin
      FormName := (Sender as TmxCaptionButton).BarButtons.Parent.ClassName;
      RolledUp := (Sender as TmxCaptionButton).RolledUp;

      if IndexStr(FormName, arrRollerStatusClasses) >= 0 then
      begin
        AStatus := IndexOfStatus(FormName);
        if AStatus = nil then
        begin
          AStatus := TCnRollerFormStatusItem.Create;
          AStatus.FormClass := FormName;
          FRollerStatus.Add(AStatus);
        end;
        AStatus.Rolled := RolledUp;
        AStatus.OldHeight := (Sender as TmxCaptionButton).BarButtons.OldHeight;
      end;
    end;
  end;
end;

function TCnWinTopRoller.CheckFiltered(AForm: TCustomForm): Boolean;
begin
  Result := (csDesigning in AForm.ComponentState)
    or (fsModal in AForm.FormState)
    or (FFiltered and (FClassList.IndexOf(AForm.ClassName) >= 0));
end;

procedure TCnWinTopRoller.Config;
begin
  with TCnTopRollerForm.Create(nil) do
  try
    chkShowTop.Checked := FShowTop;
    chkShowRoller.Checked := FShowRoller;
    chkShowOptions.Checked := FShowOptions;

    chkCaptionPacked.Checked := FCaptionPacked;
    chkFilter.Checked := FFiltered;
    chkAnimate.Checked := FAnimate;
    LoadRules(FFilters);

    if ShowModal = mrOK then
    begin
      FAnimate := chkAnimate.Checked;
      FFiltered := chkFilter.Checked;
      FCaptionPacked := chkCaptionPacked.Checked;

      FShowTop := chkShowTop.Checked;
      FShowRoller := chkShowRoller.Checked;
      FShowOptions := chkShowOptions.Checked;
      SaveRules(FFilters);
      InitClassList;
      RefreshFormsButton;

      DoSaveSettings;
    end;
  finally
    Free;
  end;
end;

constructor TCnWinTopRoller.Create;
begin
  inherited;
  FClassList := TStringList.Create;
  FFilters := TObjectList.Create(True);
  FRollerStatus := TObjectList.Create(True);
  FPopup := TPopupMenu.Create(nil);
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
end;

procedure TCnWinTopRoller.CreateButtons(AButtons: TComponent;
  AForm: TCustomForm; IsInit: Boolean = False);
var
  AStatus: TCnRollerFormStatusItem;
begin
  if (AButtons <> nil) and (AButtons.Owner <> nil)
    and (AButtons is TmxCaptionBarButtons) then
  begin
    with AButtons as TmxCaptionBarButtons do
    begin
      Name := SCnCaptionBarButtonName;
      APIStayOnTop := IndexStr(AButtons.Owner.ClassName, arrTopWinClasses) < 0;
      CaptionPacked := FCaptionPacked;
      if ShowTop then with Buttons.Add do
      begin
        ButtonType := btStayOnTop;
        Hint := SCnWinTopRollerBtnTopHint;
        Animate := FAnimate;
      end;
      if ShowRoller then with Buttons.Add do
      begin
        ButtonType := btRoller;
        Hint := SCnWinTopRollerBtnRollerHint;
        Animate := FAnimate;
        if IsInit then
        begin
          AStatus := IndexOfStatus(AForm.ClassName);
          if AStatus <> nil then
          begin
            RolledUp := AStatus.Rolled;
            if AStatus.Rolled and (AStatus.OldHeight > 0) then
              OldHeight := AStatus.OldHeight;
          end;
        end;
        OnRolled := ButtonRolled;        
      end;
      if ShowOptions then with Buttons.Add do
      begin
        Hint := SCnWinTopRollerBtnOptionsHint;
        DropDownMenu := InitPopupMenu(TPopupMenu.Create(AButtons.Owner));
        ButtonType := btCustom;
        ButtonGlyph := bgGlyph;
        Glyph.LoadFromResourceName(HInstance, 'DROP_DOWN');
      end;
    end;
  end;
end;

destructor TCnWinTopRoller.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  FPopup.Free;
  FFilters.Free;
  FRollerStatus.Free;
  FClassList.Free;
  inherited;
end;

function TCnWinTopRoller.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnWinTopRoller.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnWinTopRollerName;
  Author := 'Bitvad''z Kft' + ';' + SCnPack_Zjy + ';' + SCnPack_LiuXiao;
  Email := 'support@maxcomponents.net' + ';' +SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnWinTopRollerComment;
end;

function TCnWinTopRoller.IndexOfStatus(
  const AClassName: string): TCnRollerFormStatusItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FRollerStatus.Count - 1 do
  begin
    if TCnRollerFormStatusItem(FRollerStatus.Items[I]).FFormClass = AClassName then
    begin
      Result := TCnRollerFormStatusItem(FRollerStatus.Items[I]);
      Exit;
    end;
  end;
end;

procedure TCnWinTopRoller.InitClassList;
var
  I: Integer;
begin
  FClassList.Clear;
  for I := 0 to FFilters.Count - 1 do
  begin
    if (FFilters.Items[I] as TCnWinFilterItem).Enabled then
      FClassList.Add((FFilters.Items[I] as TCnWinFilterItem).WinClass);
  end;
end;

function TCnWinTopRoller.InitPopupMenu(AMenu: TPopupMenu): TPopupMenu;
var
  Item: TMenuItem;
begin
  if AMenu <> nil then
  begin
    AMenu.AutoHotkeys := maManual;
    AMenu.Items.Clear;
    Item := TMenuItem.Create(AMenu);
    Item.Caption := SCnWinTopRollerPopupAddToFilter;
    Item.OnClick := PopupOnAddClick;
    AMenu.Items.Add(Item);

    Item := TMenuItem.Create(AMenu);
    Item.Caption := '-';
    AMenu.Items.Add(Item);

    Item := TMenuItem.Create(AMenu);
    Item.Caption := SCnWinTopRollerPopupOptions;
    Item.OnClick := PopupOnOptionClick;
    AMenu.Items.Add(Item);
  end;
  Result := AMenu;
end;

procedure TCnWinTopRoller.LanguageChanged(Sender: TObject);
var
  I, J: Integer;
  Button: TComponent;
  Popup: TPopupMenu;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    Button := Screen.CustomForms[I].FindComponent(SCnCaptionBarButtonName);
    if (Button <> nil) and (Button is TmxCaptionBarButtons) then
    begin
      for J := 0 to (Button as TmxCaptionBarButtons).Buttons.Count - 1 do
      begin
        if (Button as TmxCaptionBarButtons).Buttons[J].DropDownMenu <> nil then
        begin
          (Button as TmxCaptionBarButtons).Buttons[J].Hint := SCnWinTopRollerBtnOptionsHint;
          Popup := (Button as TmxCaptionBarButtons).Buttons[J].DropDownMenu;
          InitPopupMenu(Popup);
        end
        else if (Button as TmxCaptionBarButtons).Buttons[J].ButtonType = btRoller then
          (Button as TmxCaptionBarButtons).Buttons[J].Hint := SCnWinTopRollerBtnRollerHint
        else if (Button as TmxCaptionBarButtons).Buttons[J].ButtonType = btStayOnTop then
          (Button as TmxCaptionBarButtons).Buttons[J].Hint := SCnWinTopRollerBtnTopHint
      end;
    end;
  end;
end;

procedure TCnWinTopRoller.LoadFilterAndStatus(const AFileName: string);
var
  Sl: TStrings;
  I, Q: Integer;
  S: string;
  AItem: TCnWinFilterItem;
  AStatus: TCnRollerFormStatusItem;
begin
  if FileExists(AFileName) then
  begin
    Sl := TStringList.Create;
    try
      Sl.LoadFromFile(AFileName);
      FFilters.Clear;
      FRollerStatus.Clear;
      for I := 0 to Sl.Count - 1 do
      begin
        S := Sl.Strings[I];
        if Pos('|', S) = 2 then // 是过滤规则
        begin
          AItem := TCnWinFilterItem.Create;
          AItem.Enabled := Copy(S, 1, 1) = '1';
          S := Copy(S, 3, MaxInt);
          Q := Pos('|', S);
          if Q > 0 then
          begin
            AItem.WinClass := Copy(S, 1, Q - 1);
            AItem.Comment := Copy(S, Q + 1, MaxInt);
          end
          else
            AItem.WinClass := S;

          FFilters.Add(AItem);
        end
        else if Pos(SCnRollerStatusPrefix, S) = 1 then // 是折叠状态
        begin
          // 载入折叠状态
          Delete(S, 1, Length(SCnRollerStatusPrefix));
          if Pos('|', S) = 2 then
          begin
            AStatus := TCnRollerFormStatusItem.Create;
            AStatus.Rolled := Copy(S, 1, 1) = '1';
            S := Copy(S, 3, MaxInt);
            Q := Pos('|', S);
            if Q > 0 then
            begin
              AStatus.FormClass := Copy(S, 1, Q - 1);
              AStatus.OldHeight := StrToIntDef(Copy(S, Q + 1, MaxInt) , -1);
            end
            else
            begin
              AStatus.FormClass := S;
              AStatus.OldHeight := -1;
            end;
            FRollerStatus.Add(AStatus);
          end;
        end;
      end;
    finally
      Sl.Free;
    end;
  end;
end;

procedure TCnWinTopRoller.LoadSettings(Ini: TCustomIniFile);
begin
  if Ini <> nil then
  begin
    FShowTop := Ini.ReadBool('', csShowTop, True);
    FShowRoller := Ini.ReadBool('', csShowRoller, True);
    FShowOptions := Ini.ReadBool('', csShowOptions, True);
    FFiltered := Ini.ReadBool('', csFiltered, True);
    FCaptionPacked := Ini.ReadBool('', csCaptionPacked, True);
    FAnimate := Ini.ReadBool('', csAnimate, True);

    LoadFilterAndStatus(WizOptions.GetUserFileName(SCnFilterFile, True));
    InitClassList;
    RefreshFormsButton(True);
  end;
end;

procedure TCnWinTopRoller.PopupOnAddClick(Sender: TObject);
begin
  if Screen.ActiveCustomForm <> nil then
    Self.AddFilteredClass(Screen.ActiveCustomForm.ClassName);
end;

procedure TCnWinTopRoller.PopupOnOptionClick(Sender: TObject);
begin
  Config;
end;

procedure TCnWinTopRoller.RefreshFormsButton(IsInit: Boolean);
var
  I: Integer;
  AForm: TCustomForm;
  Buttons: TComponent;
  CaptionButtons: TmxCaptionBarButtons;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    AForm := Screen.CustomForms[I];
    Buttons := AForm.FindComponent(SCnCaptionBarButtonName);
    if Active and not CheckFiltered(AForm) then // 此窗体需要显示，则检查
    begin
      if (Buttons <> nil) and (Buttons is TmxCaptionBarButtons) then
      begin
        CaptionButtons := (Buttons as TmxCaptionBarButtons);
        CaptionButtons.Enabled := True;
        CaptionButtons.CaptionPacked := FCaptionPacked;

        // 恢复折叠前的状态
        RestoreRollerWindow(CaptionButtons);
        CaptionButtons.Enabled := False;
        CaptionButtons.Buttons.Clear;
        CreateButtons(CaptionButtons, AForm, IsInit);
        CaptionButtons.Enabled := True;
      end
      else
        AddButtonToForm(AForm);
    end
    else // 如果此窗体无需显示按钮则 Disable
    begin
      if Buttons <> nil then
      begin
        RestoreRollerWindow(Buttons);
        (Buttons as TmxCaptionBarButtons).Enabled := False;
      end;
    end;
  end;
end;

procedure TCnWinTopRoller.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnFilterFile);
end;

procedure TCnWinTopRoller.RestoreRollerWindow(AButtons: TComponent);
var
  I: Integer;
begin
  if (AButtons <> nil) and (AButtons is TmxCaptionBarButtons) then
  begin
    for I := 0 to (AButtons as TmxCaptionBarButtons).Buttons.Count - 1 do
    begin
      if ((AButtons as TmxCaptionBarButtons).Buttons[I].ButtonType = btRoller)
        and (AButtons as TmxCaptionBarButtons).Buttons[I].RolledUp then
      begin
        (AButtons as TmxCaptionBarButtons).Buttons[I].RolledUp := False;
        Break;
      end;
    end;
  end;
end;

procedure TCnWinTopRoller.SaveFilterAndStatus(const AFileName: string);
var
  I: Integer;
  Sl: TStrings;
  AItem: TCnWinFilterItem;
  AStatus: TCnRollerFormStatusItem;
begin
  Sl := TStringList.Create;
  try
    for I := 0 to Filters.Count - 1 do
    begin
      AItem := TCnWinFilterItem(Filters.Items[I]);
      Sl.Add(Format('%d|%s|%s', [Integer(AItem.Enabled), AItem.WinClass,
        AItem.Comment]));
    end;

    for I := 0 to FRollerStatus.Count - 1 do
    begin
      AStatus := TCnRollerFormStatusItem(FRollerStatus.Items[I]);
      if AStatus.Rolled and (IndexStr(AStatus.FormClass, arrRollerStatusClasses) >= 0) then
        Sl.Add(Format('%s%d|%s|%d', [SCnRollerStatusPrefix, Integer(AStatus.Rolled),
          AStatus.FormClass, AStatus.OldHeight]));
    end;

    Sl.SaveToFile(AFileName);
  finally
    Sl.Free;
  end;
end;

procedure TCnWinTopRoller.SaveSettings(Ini: TCustomIniFile);
begin
  if Ini <> nil then
  begin
    Ini.WriteBool('', csShowTop, FShowTop);
    Ini.WriteBool('', csShowRoller, FShowRoller);
    Ini.WriteBool('', csShowOptions, FShowOptions);
    Ini.WriteBool('', csFiltered, FFiltered);
    Ini.WriteBool('', csCaptionPacked, FCaptionPacked);
    Ini.WriteBool('', csAnimate, FAnimate);

    SaveFilterAndStatus(WizOptions.GetUserFileName(SCnFilterFile, False));
    WizOptions.CheckUserFile(SCnFilterFile);
  end;
end;

procedure TCnWinTopRoller.SetActive(Value: Boolean);
var
  I: Integer;
  Button: TComponent;
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Value <> Old then
  begin
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      Button := Screen.CustomForms[I].FindComponent(SCnCaptionBarButtonName);
      if (Button <> nil) and (Button is TmxCaptionBarButtons) then
        (Button as TmxCaptionBarButtons).Enabled := Value;
    end;

    RefreshFormsButton;
  end;
end;

procedure TCnWinTopRoller.SetAnimate(Value: Boolean);
var
  I, J: Integer;
  Button: TComponent;
begin
  if FAnimate <> Value then
  begin
    FAnimate := Value;
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      Button := Screen.CustomForms[I].FindComponent(SCnCaptionBarButtonName);
      if (Button <> nil) and (Button is TmxCaptionBarButtons) then
      begin
        for J := 0 to (Button as TmxCaptionBarButtons).Buttons.Count - 1 do
          (Button as TmxCaptionBarButtons).Buttons[J].Animate := Value;
      end;
    end;
  end;
end;

procedure TCnWinTopRoller.SetCaptionPacked(Value: Boolean);
var
  I: Integer;
  Button: TComponent;
begin
  if FCaptionPacked <> Value then
  begin
    FCaptionPacked := Value;
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      Button := Screen.CustomForms[I].FindComponent(SCnCaptionBarButtonName);
      if (Button <> nil) and (Button is TmxCaptionBarButtons) then
        (Button as TmxCaptionBarButtons).CaptionPacked := Value;
    end;
  end;
end;

{ TCnTopRollerForm }

procedure TCnTopRollerForm.ListViewClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    cbbClassName.Text := ListView.Selected.Caption;
    cbbComment.Text := ListView.Selected.SubItems[0];
  end;
end;

procedure TCnTopRollerForm.actReplaceExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    ListView.Selected.Caption := cbbClassName.Text;
    ListView.Selected.SubItems[0] := cbbComment.Text;
  end;
end;

procedure TCnTopRollerForm.actAddExecute(Sender: TObject);
begin
  with ListView.Items.Add do
  begin
    Checked := True;
    Caption := cbbClassName.Text;
    SubItems.Add(cbbComment.Text);
  end;
end;

procedure TCnTopRollerForm.actDeleteExecute(Sender: TObject);
var
  Index: Integer;
begin
  if Self.ListView.Selected <> nil then
  begin
    Index := ListView.Selected.Index;
    ListView.Items.Delete(Index);
    if ListView.Items.Count > Index then
      ListView.Selected := ListView.Items[Index]
    else
      ListView.Selected := ListView.Items[Index - 1];

    if ListView.Selected = nil then
    begin
      cbbClassName.Text := '';
      cbbComment.Text := '';
    end;
  end;
end;

procedure TCnTopRollerForm.LoadRules(AList: TObjectList);
var
  I: Integer;
  AItem: TCnWinFilterItem;
begin
  if AList <> nil then
  begin
    Self.ListView.Items.Clear;
    for I := 0 to AList.Count - 1 do
    begin
      if AList.Items[I] is TCnWinFilterItem then
      begin
        AItem := TCnWinFilterItem(AList.Items[I]);
        with ListView.Items.Add do
        begin
          Checked := AItem.Enabled;
          Caption := Trim(AItem.WinClass);
          SubItems.Add(Trim(AItem.Comment));
        end;
      end;
    end;
  end;
end;

procedure TCnTopRollerForm.SaveRules(AList: TObjectList);
var
  I: Integer;
  AItem: TCnWinFilterItem;
begin
  if AList <> nil then
  begin
    AList.Clear;
    for I := 0 to Self.ListView.Items.Count - 1 do
    begin
      AItem := TCnWinFilterItem.Create;
      AItem.Enabled := Self.ListView.Items[I].Checked;
      AItem.WinClass := Trim(Self.ListView.Items[I].Caption);
      AItem.Comment := Trim(Self.ListView.Items[I].SubItems[0]);
      AList.Add(AItem);
    end;
  end;
end;

procedure TCnTopRollerForm.cbbClassNameChange(Sender: TObject);
begin
  if cbbClassName.ItemIndex >= 0 then
    cbbComment.ItemIndex := cbbClassName.ItemIndex;
end;

procedure TCnTopRollerForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  I: Integer;
  B: Boolean;
begin
  if Action = actDelete then
    (Action as TAction).Enabled := ListView.Selected <> nil
  else if Action = actReplace then
    (Action as TAction).Enabled :=
    (cbbClassName.Text <> '') and (ListView.Selected <> nil)
    and ((cbbClassName.Text <> ListView.Selected.Caption) or
    (cbbComment.Text <> ListView.Selected.SubItems[0]))
  else if Action = actAdd then
  begin
    B := True;
    for I := 0 to ListView.Items.Count - 1 do
    begin
      if ListView.Items[I].Caption = cbbClassName.Text then
      begin
        B := False;
        Break;
      end;
    end;
    (Action as TAction).Enabled := B and (Trim(cbbClassName.Text) <> '');
  end;
  Handled := True;
end;

procedure TCnTopRollerForm.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
    actDelete.Execute;
end;

procedure TCnTopRollerForm.cbbCommentChange(Sender: TObject);
begin
  if cbbComment.ItemIndex >= 0 then
    cbbClassName.ItemIndex := cbbComment.ItemIndex;
end;

procedure TCnTopRollerForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnTopRollerForm.GetHelpTopic: string;
begin
  Result := 'CnWinTopRoller';
end;

procedure TCnTopRollerForm.FormCreate(Sender: TObject);
begin
  EnlargeListViewColumns(ListView);
end;

initialization
{$IFNDEF IDE_SUPPORT_THEMING}
  RegisterCnWizard(TCnWinTopRoller); // 主题绘制有问题，禁用
{$ENDIF}

{$ENDIF CNWIZARDS_CNWINTOPROLLER}
end.
