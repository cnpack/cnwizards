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

unit CnCompFilterFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件面板过滤窗体
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：此单元不可在 D7 for D8 下编译
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2018.04.23 V1.1
*               加入模糊匹配的功能
*           2006.09.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

{$IFDEF SUPPORT_PALETTE_ENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, ToolWin, ComCtrls, StdCtrls, TypInfo,
  ActnList, ImgList, Menus, ToolsAPI, Tabs,
  {$IFDEF COMPILER6_UP}
  ComponentDesigner, DesignIntf,
  {$ELSE}
  LibIntf,
  {$ENDIF}
  CnWizUtils, CnWizMultiLang, CnWizShareImages, CnWizConsts, CnWizIdeUtils,
  CnWizNotifier, CnCommon, CnPopupMenu, RegExpr, CnStrings, CnWizOptions,
  CnFrmMatchButton;

type
  TCnFilterFormStyle = (fsHidden, fsDropped, fsFloat);

  TCnIdeCompType = (ctVCL, ctCLX, ctBoth);

  TCnIdeCompInfo = class(TPersistent)
  private
    FCompName: string;
    FTabName: string;
    FCompUnitName: string;
    FImgIndex: Integer;
    FInternalName: string;
    FCompType: TCnIdeCompType;
    FPackageName: string;
    FMatchedIndexes: TList;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property InternalName: string read FInternalName write FInternalName;
    {* 带 T 的真正类名}
    property CompName: string read FCompName write FCompName;
    {* 用来显示的组件名，根据设置可能不带 T 前缀}
    property TabName: string read FTabName write FTabName;
    property CompUnitName: string read FCompUnitName write FCompUnitName;
    property ImgIndex: Integer read FImgIndex write FImgIndex;
    property PackageName: string read FPackageName write FPackageName;
    property CompType: TCnIdeCompType read FCompType write FCompType;

    property MatchedIndexes: TList read FMatchedIndexes write FMatchedIndexes;
  end;

  TCnCompFilterForm = class(TCnTranslateForm)
    Panel1: TPanel;
    pnlHdr: TPanel;
    imgHdr: TImage;
    edtSearch: TEdit;
    ToolBar1: TToolBar;
    btnCreateComp: TToolButton;
    btnHelp: TToolButton;
    actlstFilter: TActionList;
    actCreateComp: TAction;
    tmrHide: TTimer;
    ilComps: TImageList;
    pmList: TPopupMenu;
    mniCreateComp: TMenuItem;
    N2: TMenuItem;
    mniDisplay: TMenuItem;
    mniTabs: TMenuItem;
    mniShowPrefix: TMenuItem;
    mniShowDetailHint: TMenuItem;
    mniAutoSelect: TMenuItem;
    mniShowAllTabs: TMenuItem;
    mniN1: TMenuItem;
    tmrHint: TTimer;
    ilBackup: TImageList;
    tmrLoad: TTimer;
    tbst1: TTabSet;
    pnlComp: TPanel;
    lvComps: TListView;
    pnlTab: TPanel;
    lvTabs: TListView;
    ilTabs: TImageList;
    tmrShowHint: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchChange(Sender: TObject);
    procedure lvCompsData(Sender: TObject; Item: TListItem);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure actCreateCompExecute(Sender: TObject);
    procedure lvCompsDblClick(Sender: TObject);
    procedure tmrHideTimer(Sender: TObject);
    procedure lvCompsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvCompsKeyPress(Sender: TObject; var Key: Char);
    procedure btnMatchModeClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgHdrMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgHdrMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgHdrMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actCreateCompUpdate(Sender: TObject);
    procedure lvCompsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnHelpClick(Sender: TObject);
    procedure pmListPopup(Sender: TObject);
    procedure mniShowPrefixClick(Sender: TObject);
    procedure mniShowDetailHintClick(Sender: TObject);
    procedure mniAutoSelectClick(Sender: TObject);
    procedure mniShowAllTabsClick(Sender: TObject);
    procedure tmrHintTimer(Sender: TObject);
    procedure tmrLoadTimer(Sender: TObject);
    procedure tbst1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure lvTabsData(Sender: TObject; Item: TListItem);
    procedure lvTabsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvTabsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvTabsDblClick(Sender: TObject);
    procedure lvCompsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrShowHintTimer(Sender: TObject);
  private
    FFilterFormStyle: TCnFilterFormStyle;
    FCaptionHeight: Integer;
    FCompList: TStringList;      // 容纳原始组件列表，其 Objects 为 TCnIdeCompInfo
    FDisplayList: TStringList;   // 容纳过滤显示的组件列表
    FTabsList: TStringList;         // 容纳原始的 Tab 列表
    FTabsDisplayList: TStringList;  // 容纳过滤显示的 Tab 列表，其 Objects 为 MatchedIndexes
    FBasePoint: TPoint;
    FOnStyleChanged: TNotifyEvent;
    FOnSettingChanged: TNotifyEvent;
    FJustHide: Boolean;
    FNeedRefresh: Boolean;
    FUpdating: Boolean;
    FJustLoad: Boolean; // 控制短期内不重复 Load，避免出 exception
    FMouseDown: Boolean;
    FOldX: Integer;
    FOldY: Integer;
    FCompBmp: TBitmap;

{$IFDEF COMPILER6_UP}
    FOldDesignerType: string;
    FIsDataModule: Boolean;
  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FOldRootClass: TClass;
  {$ENDIF}
{$ENDIF}

    FShowPrefix: Boolean;
    FUseSmallImg: Boolean;
    FAutoSelect: Boolean;
    FShowDetails: Boolean;
    FFilterTab: string;
    FDetailStr: string;
    FClassNameList: TStringList;
    FDetailsList: TStringList;
    FDetailHint: THintWindow;
    FPackageChanged: Boolean;
    FRegExpr: TRegExpr;
    FMatchButtonFrame: TCnMatchButtonFrame;

    procedure SetFilterFormStyle(const Value: TCnFilterFormStyle);
    procedure FileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure UpdateFilterFormStyle;
    function AddCompImage(const AComp: string): Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    function AddNewCompImage(const AComp: string): Integer;
{$ELSE}
    function AddOldCompImage(const AComp: string): Integer;
{$ENDIF}
    procedure TabsMenuClick(Sender: TObject);
    procedure ActivateDetailHint;
    procedure DeactivateDetailHint;
    procedure FormEditorNotify(FormEditor: IOTAFormEditor; NotifyType:
      TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle; Component:
      TComponent; const OldName, NewName: string);
    procedure CheckEnvAndUpdateCompList;
    procedure DoUpdateCompList(Sender: TObject);
    procedure SelectItemByIndex(ListView: TListView; AIndex: Integer);

    procedure SetShowPrefix(const Value: Boolean);
    procedure SetUseSmallImg(const Value: Boolean);
    procedure SetAutoSelect(const Value: Boolean);
    procedure SetFilterTab(const Value: string);
    procedure SetShowDetails(const Value: Boolean);
  protected
    procedure InitButtonFrame;
    procedure MatchModeChange(Sender: TObject);
    procedure DoStyleChanged; virtual;
    procedure DoSettingChanged; virtual;
    procedure DoLanguageChanged(Sender: TObject); override;
    procedure CustomDrawItem(Sender: TListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    procedure LoadComponentsList;
    procedure ClearCompList;
    procedure ClearTabList;
    procedure UpdateToDisplayList;
    function RegExpContainsText(AText, APattern: string; IsMatchStart: Boolean = False): Boolean;
    function CanDisplayAComp(AComp: TCnIdeCompInfo): Boolean;
    function CanDisplayATab(ATab: string; MatchedIndexes: TList): Boolean;
    procedure AdjustLayout;

    property FilterFormStyle: TCnFilterFormStyle read FFilterFormStyle write SetFilterFormStyle;
    property BasePoint: TPoint read FBasePoint write FBasePoint;

    property OnStyleChanged: TNotifyEvent read FOnStyleChanged write FOnStyleChanged;
    property OnSettingChanged: TNotifyEvent read FOnSettingChanged write FOnSettingChanged;
    property JustHide: Boolean read FJustHide write FJustHide;

    property ShowPrefix: Boolean read FShowPrefix write SetShowPrefix;
    property UseSmallImg: Boolean read FUseSmallImg write SetUseSmallImg;
    property ShowDetails: Boolean read FShowDetails write SetShowDetails;
    property AutoSelect: Boolean read FAutoSelect write SetAutoSelect;
    property FilterTab: string read FFilterTab write SetFilterTab;
  end;

var
  CnCompFilterForm: TCnCompFilterForm = nil;

{$ENDIF}

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

{$IFDEF SUPPORT_PALETTE_ENHANCE}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CnImgIndexUnset = -2;
  CnImgIndexInvalid = -1;

var
  FOldRegisterComponentsProc: procedure(const Page: string;
    {$IFDEF COMPILER7_UP} const {$ENDIF} ComponentClasses: array of TComponentClass) = nil;

  ComponentTabListMap: TStringList = nil;
  {* 内部每一行存储的是 ComponentClassName=Page，Object 是 TCnIdeCompType 值}

procedure CnCompRegisterComponents(const Page: string;
  {$IFDEF COMPILER7_UP} const {$ENDIF} ComponentClasses: array of TComponentClass);
var
  I: Integer;
  Obj: TObject;
begin
  if ComponentTabListMap = nil then
    ComponentTabListMap := TStringList.Create;

  for I := Low(ComponentClasses) to High(ComponentClasses) do
  begin
    if ComponentTabListMap.IndexOf(ComponentClasses[I].ClassName + '=' + Page) < 0 then
    begin
      if ComponentClasses[I].InheritsFrom(TWinControl) then
        Obj := TObject(ctVCL)
      else if InheritsFromClassName(ComponentClasses[I], 'TWidgetControl') then
        Obj := TObject(ctCLX)
      else
        Obj := TObject(ctBoth);

      ComponentTabListMap.AddObject(ComponentClasses[I].ClassName + '=' + Page, Obj);
    end;
  end;

  if Assigned(FOldRegisterComponentsProc) then
     FOldRegisterComponentsProc(Page, ComponentClasses);
end;

function TCnCompFilterForm.AddCompImage(const AComp: string): Integer;
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  Result := AddNewCompImage(AComp);
{$ELSE}
  Result := AddOldCompImage(AComp);
{$ENDIF}
end;

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

function TCnCompFilterForm.AddNewCompImage(const AComp: string): Integer;
begin
  if FCompBmp = nil then
  begin
    FCompBmp := TBitmap.Create;
    FCompBmp.Height := 26;
    FCompBmp.Width := 26;
    FCompBmp.Canvas.Brush.Color := clBtnFace;
  end;
  FCompBmp.Canvas.FillRect(Rect(0, 0, FCompBmp.Width, FCompBmp.Height));

  CnPaletteWrapper.GetComponentImage(FCompBmp, AComp);
  Result := ilComps.Add(FCompBmp, nil);
end;

{$ELSE}

function TCnCompFilterForm.AddOldCompImage(const AComp: string): Integer;
var
  AClass: TComponentClass;
{$IFDEF COMPILER6_UP}
  FormEditor: IOTAFormEditor;
  Root: TPersistent;
  PalItem: IPaletteItem;
  PalItemPaint: IPalettePaint;
{$ENDIF}
begin
  if FCompBmp = nil then
  begin
    FCompBmp := TBitmap.Create;
    FCompBmp.Height := 26;
    FCompBmp.Width := 26;
    FCompBmp.Canvas.Brush.Color := clBtnFace;
  end;

  Result := 0; // 默认使用缺省控件图标
  try
{$IFDEF COMPILER6_UP}
    FormEditor := CnOtaGetCurrentFormEditor;
    if Assigned(FormEditor) and (FormEditor.GetSelComponent(0) <> nil) then
    begin
      Root := TPersistent(FormEditor.GetSelComponent(0).GetComponentHandle);
      if (Root <> nil) and not ObjectIsInheritedFromClass(Root, 'TDataModule') then
      begin
        // 只处理 CLX 和 VCL 设计期窗体变化的情况，转变 CLX/VCL 后，无需恢复
        if FOldRootClass <> Root.ClassType then
        begin
          ActivateClassGroup(TPersistentClass(Root.ClassType));
          FOldRootClass := Root.ClassType;
        end;
      end;
    end;
{$ENDIF}

    AClass := TComponentClass(GetClass(AComp));
    if AClass <> nil then
    begin
      FCompBmp.Canvas.FillRect(Bounds(0, 0, FCompBmp.Width, FCompBmp.Height));
{$IFDEF COMPILER6_UP}
      PalItem := ComponentDesigner.ActiveDesigner.Environment.GetPaletteItem(AClass) as IPaletteItem;
      if Supports(PalItem, IPalettePaint, PalItemPaint) then
        PalItemPaint.Paint(FCompBmp.Canvas, 0, 0);
{$ELSE}
      DelphiIDE.GetPaletteItem(TComponentClass(AClass)).Paint(FCompBmp.Canvas, -1, -1);
{$ENDIF}
    end;
    Result := ilComps.Add(FCompBmp, nil);
  except
    ;
  end;
end;

{$ENDIF}

procedure TCnCompFilterForm.LoadComponentsList;
var
  I, J, EquPos: Integer;
  OldTabIdx, OldPalIdx: Integer;
  Info: TCnIdeCompInfo;
  S: string;

  procedure InitCompImages;
  var
    Bmp: TBitmap;
  begin
    ilComps.Clear;
    Bmp := TBitmap.Create;
    try
      Bmp.Height := ilComps.Height;
      Bmp.Width := ilComps.Width;
      Bmp.Canvas.Brush.Color := clBtnFace;
      Bmp.Canvas.FillRect(Bounds(0, 0, Bmp.Width, Bmp.Height));

      ilBackup.GetBitmap(0, Bmp); // 获得默认控件号
      ilComps.Add(Bmp, nil);
    finally
      Bmp.Free;
    end;
  end;

begin
  ClearCompList;
  ClearTabList;
  InitCompImages;

  OldTabIdx := CnPaletteWrapper.TabIndex;
  OldPalIdx := CnPaletteWrapper.SelectedIndex;

  // 如果是由于Package变化导致的，则不能通过挂接RegisterComponent过程来获得
  if FPackageChanged then
  begin
    CnPaletteWrapper.Visible := False;
    CnPaletteWrapper.BeginUpdate;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('LoadComponentsList');
{$ENDIF}
  Screen.Cursor := crHourGlass;

  try
    try
      if FPackageChanged then // 旧的方法，会引起 IDE 变动
      begin
        for I := 0 to CnPaletteWrapper.TabCount - 1 do
        begin
          CnPaletteWrapper.TabIndex := I;
          for J := 0 to CnPaletteWrapper.PalToolCount - 1 do
          begin
            CnPaletteWrapper.SelectedIndex := J;
            if CnPaletteWrapper.SelectedToolName = 'Frames' then
              Continue;

            Info := TCnIdeCompInfo.Create;
            Info.InternalName := CnPaletteWrapper.SelectedToolName;
            Info.ImgIndex := CnImgIndexUnset;
            if not FShowPrefix and (Info.InternalName[1] = 'T') then
              Info.CompName := Copy(Info.InternalName, 2, MaxInt)
            else
              Info.CompName := Info.InternalName;

            Info.TabName := CnPaletteWrapper.ActiveTab;
            Info.CompType := ctBoth; // 这种情况下无 VCL/CLX 的处理，所以赋值 both
            Info.CompUnitName := CnPaletteWrapper.SelectedUnitName;

            FCompList.AddObject(Info.CompName, Info);
          end;
        end;
      end
      else // 常规方式
      begin
        if ComponentTabListMap <> nil then
        begin
          ComponentTabListMap.Sort;
          CnPaletteWrapper.BeginUpdate;
          try
            for I := 0 to ComponentTabListMap.Count - 1 do
            begin
              Info := TCnIdeCompInfo.Create;

              S := ComponentTabListMap[I];
              EquPos := Pos('=', S);
              if EquPos > 0 then
              begin
                Info.InternalName := Copy(S, 1, EquPos - 1);
                Info.TabName := Copy(S, EquPos + 1, MaxInt);
              end
              else
              begin
                Info.InternalName := S;
                Info.TabName := 'Unknown';
              end;

              Info.ImgIndex := CnImgIndexUnset;
              Info.CompType := TCnIdeCompType(ComponentTabListMap.Objects[I]);
              if not FShowPrefix and (Info.InternalName[1] = 'T') then
                Info.CompName := Copy(Info.InternalName, 2, MaxInt)
              else
                Info.CompName := Info.InternalName;

{$IFDEF SUPPORT_FMX}
              // FMX 等单元即使获取不到 Class，也需要用 PaletteAPI 的方式（之前是选择再解析 Hint）来获取单元名等信息
              // 选择再解析可能出现屏幕闪动因此弃用了。
              // 注意低版本 Delphi 也有 TTextViewer 等没注册到组件版上的控件，那些无需获取
              if GetClass(Info.InternalName) = nil then
              begin
{$IFDEF DEBUG}
                CnDebugger.LogMsg('Get Class ' + Info.InternalName + ' is nil. Using Select.');
{$ENDIF}

{$IFDEF OTA_PALETTE_API}
                CnPaletteWrapper.GetUnitPackageNameFromComponentClassName(Info.FCompUnitName, Info.FPackageName, Info.InternalName, Info.TabName);
{$ELSE}
                Info.CompUnitName := CnPaletteWrapper.GetUnitNameFromComponentClassName(Info.InternalName, Info.TabName);
{$ENDIF}
                FCompList.AddObject(Info.CompName, Info);
              end;
{$ELSE}

{$ENDIF}
              // 非 FMX 下，Get 不到 Class 就可以不添加，反正没这组件（CLX 的情况呢？）
              if GetClass(Info.InternalName) <> nil then
              begin
                Info.CompUnitName := CnPaletteWrapper.GetUnitNameFromComponentClassName(Info.InternalName, Info.TabName);
                FCompList.AddObject(Info.CompName, Info);
              end;
            end;
          finally
            CnPaletteWrapper.EndUpdate;
          end;
        end;
      end;
    except
      ;
    end;

    // 装载组件面板的 Tabs 列表
    for I := 0 to CnPaletteWrapper.TabCount - 1 do
      FTabsList.AddObject(CnPaletteWrapper.Tabs[I], TList.Create); // 塞个模糊匹配列表供使用

    // 提前恢复
    if FPackageChanged then
    begin
      CnPaletteWrapper.Visible := True;
      CnPaletteWrapper.TabIndex := OldTabIdx;
      CnPaletteWrapper.SelectedIndex := OldPalIdx;
    end;

    // 此处暂不添加图像，待需要时填
  finally
    Screen.Cursor := crDefault;

    if FPackageChanged then
    begin
      CnPaletteWrapper.Visible := True;
      CnPaletteWrapper.TabIndex := OldTabIdx;
      CnPaletteWrapper.SelectedIndex := OldPalIdx;
      CnPaletteWrapper.EndUpdate;
      FPackageChanged := False;
    end;

    FJustLoad := True;
    tmrLoad.Enabled := True;
{$IFDEF DEBUG}
    CnDebugger.LogLeave('LoadComponentsList');
{$ENDIF}
  end;
end;

procedure TCnCompFilterForm.SetFilterFormStyle(const Value: TCnFilterFormStyle);
begin
  if FFilterFormStyle <> Value then
  begin
    FFilterFormStyle := Value;
    UpdateFilterFormStyle;
    DoStyleChanged;
  end;
end;

procedure TCnCompFilterForm.UpdateFilterFormStyle;
var
  WLong: Longint;
begin
  case FFilterFormStyle of
    fsHidden:
      begin
        Hide;
      end;
    fsDropped:
      begin
        WLong := GetWindowLong(Handle, GWL_STYLE);
        if WLong and WS_CAPTION <> 0 then // 说明有标题栏
        begin
          SetWindowLong(Handle, GWL_STYLE,
            WLong and (not WS_CAPTION));
          Height := ClientHeight;
        end;
        AdjustLayout;
        if FNeedRefresh then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Drop and Refresh');
{$ENDIF}
          LoadComponentsList;
          UpdateToDisplayList;
          FNeedRefresh := False;
        end;
        edtSearch.SelectAll;
        if lvComps.Selected <> nil then
        begin
          lvComps.Selected.Focused := False;
          lvComps.Selected := nil;
        end;
        if Assigned(lvComps.OnChange) then
          lvComps.OnChange(lvComps, lvComps.Selected, ctState);
        Visible := True;
      end;
    fsFloat:
      begin
        SetWindowLong(Handle, GWL_STYLE,
          GetWindowLong(Handle, GWL_STYLE) or WS_CAPTION);
        Height := ClientHeight + FCaptionHeight;
        Visible := True;
      end;
  end;
end;

procedure TCnCompFilterForm.FormCreate(Sender: TObject);
begin
  FCaptionHeight := Height - ClientHeight;
  pnlComp.Align := alClient;
  pnlTab.Align := alClient;
  pnlComp.BringToFront;

  // 覆盖 CnTranslateForm 的 ScreenCenter
  Position := poDesigned;
  FDetailHint := THintWindow.Create(Self);
  tmrHint.Interval := Trunc(1.5 * Application.HintHidePause); // 长一点好

  FCompList := TStringList.Create;
  FDisplayList := TStringList.Create;
  FTabsList := TStringList.Create;
  FTabsDisplayList := TStringList.Create;
  FClassNameList := TStringList.Create;
  FDetailsList := TStringList.Create;
  FNeedRefresh := True;

  FRegExpr := TRegExpr.Create;
  FRegExpr.ModifierI := True;
  FMatchButtonFrame := TCnMatchButtonFrame.Create(Self);
  FMatchButtonFrame.Anchors := FMatchButtonFrame.Anchors + [akBottom];
  FMatchButtonFrame.Parent := pnlHdr;
  FMatchButtonFrame.Left := 8;
  InitButtonFrame;
  FMatchButtonFrame.OnModeChange := MatchModeChange;

  WizOptions.ResetToolbarWithLargeIcons(ToolBar1);
  WizOptions.ResetToolbarWithLargeIcons(FMatchButtonFrame.tlb1);
  if WizOptions.UseLargeIcon then
  begin
    FMatchButtonFrame.Width := FMatchButtonFrame.Width + csLargeToolbarHeightDelta;
    FMatchButtonFrame.tlb1.Width := FMatchButtonFrame.tlb1.Width + csLargeToolbarHeightDelta;
    edtSearch.Font.Size := csLargeComboFontSize;
    pnlHdr.Height := pnlHdr.Height + csLargeToolbarHeightDelta;
  end;

  CnWizNotifierServices.AddFileNotifier(FileNotify);
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorNotify);
end;

procedure TCnCompFilterForm.FormDestroy(Sender: TObject);
begin
  DeactivateDetailHint;
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorNotify);
  CnWizNotifierServices.RemoveFileNotifier(FileNotify);
  FRegExpr.Free;
  FCompList.Free;
  FDetailsList.Free;
  FClassNameList.Free;
  FTabsDisplayList.Free;
  FTabsList.Free;
  FDisplayList.Free;
  FCompBmp.Free;
end;

procedure TCnCompFilterForm.ClearCompList;
var
  I: Integer;
begin
  if FCompList <> nil then
  begin
    for I := 0 to FCompList.Count - 1 do
      if FCompList.Objects[I] <> nil then
        FCompList.Objects[I].Free;
    FCompList.Clear;
  end;
end;

procedure TCnCompFilterForm.AdjustLayout;
begin
  // 根据屏幕上某点调整窗体位置，都往内靠俩象素
{$IFDEF DEBUG}
  CnDebugger.LogPoint(BasePoint);
{$ENDIF}

  if BasePoint.x < 0 then
    Left := 0 + 2
  else if BasePoint.x > Screen.Width - Width then // 太右
    Left := Screen.Width - Width - 2
  else // 中间
    Left := BasePoint.x;

  if BasePoint.y < 0 then
    Top := 0
  else if BasePoint.y > Screen.Height - Height then // 太低
    Top := Screen.Height - Height - 2
  else
    Top := BasePoint.y + 2;
end;

procedure TCnCompFilterForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    CnPaletteWrapper.SelectComponent('', '');
    FilterFormStyle := fsHidden;
    Key := 0;
  end;
end;

procedure TCnCompFilterForm.UpdateToDisplayList;
var
  I: Integer;
  Comp: TCnIdeCompInfo;
begin
  FDisplayList.Clear;
  for I := 0 to FCompList.Count - 1 do
  begin
    Comp := TCnIdeCompInfo(FCompList.Objects[I]);
    Comp.MatchedIndexes.Clear;
    if CanDisplayAComp(Comp) then
      FDisplayList.AddObject(Comp.CompName, Comp);
  end;
  lvComps.Items.Count := FDisplayList.Count;
  lvComps.Invalidate;

  if FFilterTab = '' then
    Caption := SCnSearchComponent
  else if tbst1.TabIndex = 0 then
    Caption := SCnSearchComponent + ' - ' + FFilterTab;

  FTabsDisplayList.Clear;
  for I := 0 to FTabsList.Count - 1 do
  begin
    TList(FTabsList.Objects[I]).Clear;
    if CanDisplayATab(FTabsList[I], TList(FTabsList.Objects[I])) then
      FTabsDisplayList.AddObject(FTabsList[I], FTabsList.Objects[I]);
  end;
  lvTabs.Items.Count := FTabsDisplayList.Count;
  lvTabs.Invalidate;
end;

function TCnCompFilterForm.CanDisplayAComp(AComp: TCnIdeCompInfo): Boolean;
begin
  // 检查一组件是否符合显示的要求
  Result := AComp <> nil;
  if Result then
  begin
    if FMatchButtonFrame.MatchMode = mmFuzzy then
    begin
      if Trim(edtSearch.Text) = '' then
        Result := True
      else
        Result := FuzzyMatchStr(Trim(edtSearch.Text), AComp.CompName, AComp.MatchedIndexes);
    end
    else
      Result := RegExpContainsText(AComp.CompName, Trim(edtSearch.Text), FMatchButtonFrame.MatchMode = mmStart);

    if Result and (FFilterTab <> '') then
      Result := AComp.TabName = FFilterTab;

    // 判断当前设计器和组件的类型是否匹配
    if Result and (AComp.CompType <> ctBoth) then
    begin
      if ((CnOtaGetActiveDesignerType = 'dfm') and (AComp.CompType = ctCLX)) or
        ((CnOtaGetActiveDesignerType = 'xfm') and (AComp.CompType = ctVCL)) then
        Result := False;
    end;
  end;
end;

function TCnCompFilterForm.CanDisplayATab(ATab: string; MatchedIndexes: TList): Boolean;
begin
  Result := ATab <> '';
  if Result then
  begin
    Result := edtSearch.Text = '';
    if Result then
      Exit;

    case FMatchButtonFrame.MatchMode of
      mmStart:
        Result := Pos(UpperCase(Trim(edtSearch.Text)), UpperCase(ATab)) > 0;
      mmAnywhere:
        Result := Pos(UpperCase(Trim(edtSearch.Text)), UpperCase(ATab)) = 1;
      mmFuzzy:
        begin
          if Trim(edtSearch.Text) = '' then
            Result := True
          else
            Result := FuzzyMatchStr(Trim(edtSearch.Text), ATab, MatchedIndexes);
        end;
    end;
  end;
end;

procedure TCnCompFilterForm.edtSearchChange(Sender: TObject);
var
  OldComp: string;
begin
  OldComp := '';
  if lvComps.Selected <> nil then
    OldComp := lvComps.Selected.Caption;

  UpdateToDisplayList;
  lvComps.Items.Count := FDisplayList.Count;
  lvComps.Invalidate;
  lvTabs.Items.Count := FTabsDisplayList.Count;
  lvTabs.Invalidate;

  if tbst1.TabIndex = 0 then
  begin
    if lvComps.Selected = nil then
    begin
      DeactivateDetailHint;
      SelectItemByIndex(lvComps, 0);
    end
    else if lvComps.Selected.Caption <> OldComp then
    begin
      DeactivateDetailHint;
      lvCompsChange(lvComps, lvComps.Selected, ctState) // 选择位置没变但对应 Item 变了，手工触发 Hint
    end
    else  // 选择点没变
    begin
      if tmrHint.Enabled then  // 如已经显示则延长 Hint 显示的时间
      begin
        tmrHint.Enabled := False;
        tmrHint.Enabled := True;
      end
      else  // 否则显示 Hint
      begin
        tmrShowHint.Enabled := False;
        tmrShowHint.Enabled := True;
      end;
    end;
  end
  else if (tbst1.TabIndex = 1) and (lvTabs.Selected = nil) then
    SelectItemByIndex(lvTabs, 0);
end;

procedure TCnCompFilterForm.lvCompsData(Sender: TObject; Item: TListItem);
var
  AComp: TCnIdeCompInfo;
begin
  if Item.Index >= FDisplayList.Count then Exit;

  AComp := TCnIdeCompInfo(FDisplayList.Objects[Item.Index]);
  if AComp <> nil then
  begin
    Item.Caption := AComp.CompName;
    // 需要时，如未取，则取
    if AComp.ImgIndex = CnImgIndexUnset then
      AComp.ImgIndex := AddCompImage(AComp.InternalName);

    Item.ImageIndex := AComp.ImgIndex;
    Item.Data := AComp;
  end;
end;

procedure TCnCompFilterForm.edtSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_LEFT, VK_RIGHT]) and (Shift = []) then
  begin
    if tbst1.TabIndex = 0 then
    begin
      if (Key = VK_RIGHT) and (edtSearch.SelLength = 0) // 最右则切页
        and (edtSearch.SelStart = Length(edtSearch.Text)) then
      begin
        tbst1.TabIndex := 1;
        if lvTabs.Selected = nil then
          SelectItemByIndex(lvTabs, 0);
      end;
    end
    else
    begin
      if (Key = VK_LEFT) and (edtSearch.SelLength = 0) // 最左则切页
        and (edtSearch.SelStart = 0) then
      begin
        tbst1.TabIndex := 0;
        if lvComps.Selected = nil then
          SelectItemByIndex(lvComps, 0);
      end;
    end;
  end;

  if not (((Key = VK_F4) and (ssAlt in Shift)) or
    (Key in [VK_DELETE, VK_LEFT, VK_RIGHT]) or
    ((Key in [VK_HOME, VK_END]) and not (ssCtrl in Shift)) or
    ((Key in [VK_INSERT]) and ((ssShift in Shift) or (ssCtrl in Shift)))) then
  begin
    if tbst1.TabIndex = 0 then
      SendMessage(lvComps.Handle, WM_KEYDOWN, Key, 0)
    else
      SendMessage(lvTabs.Handle, WM_KEYDOWN, Key, 0);

    Key := 0;
  end;
end;

procedure TCnCompFilterForm.FormDeactivate(Sender: TObject);
begin
  if FilterFormStyle = fsFloat then
    DeactivateDetailHint;
  if FilterFormStyle = fsDropped then
  begin
    FilterFormStyle := fsHidden;
    FJustHide := True;
    tmrHide.Enabled := True;
  end;
end;

procedure TCnCompFilterForm.DoStyleChanged;
begin
  if Assigned(FOnStyleChanged) then
    FOnStyleChanged(Self);
end;

procedure TCnCompFilterForm.FormHide(Sender: TObject);
var
  OldChange: TLVChangeEvent;
begin
  DeactivateDetailHint;
  // 用 F，避免触发多余的事件
  FFilterFormStyle := fsHidden;
  if lvComps.Selected <> nil then
  begin
    OldChange := lvComps.OnChange;
    lvComps.OnChange := nil;
    lvComps.Selected.Focused := False;
    lvComps.Selected := nil;
    lvComps.OnChange := OldChange;
  end;
end;

procedure TCnCompFilterForm.edtSearchKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    if tbst1.TabIndex = 0 then
      actCreateComp.Execute
    else if FilterFormStyle = fsDropped then
      FilterFormStyle := fsHidden;
    Key := #0;
  end;
end;

procedure TCnCompFilterForm.actCreateCompExecute(Sender: TObject);
var
  I: Integer;
  AComp: TCnIdeCompInfo;
  FormEditor: IOTAFormEditor;
{$IFDEF COMPILER6_UP}
  Root: TPersistent;
  OldGroup: TPersistentClass;
{$ENDIF}
begin
  try
    if (tbst1.TabIndex <> 0) or (lvComps.SelCount = 0) then Exit;

    FormEditor := CnOtaGetCurrentFormEditor;
    if FormEditor <> nil then
    begin
{$IFDEF COMPILER6_UP}
      OldGroup := nil;
      if FormEditor.GetSelComponent(0) <> nil then
      begin
        Root := TPersistent(FormEditor.GetSelComponent(0).GetComponentHandle);
        if Root <> nil then
          OldGroup := ActivateClassGroup(TPersistentClass(Root.ClassType));
      end;
{$ENDIF}
      for I := 0 to lvComps.Items.Count - 1 do
      begin
        if lvComps.Items[I].Selected and (lvComps.Items[I] <> nil)then
        begin
          AComp := TCnIdeCompInfo(lvComps.Items[I].Data);
          FormEditor.CreateComponent(FormEditor.GetSelComponent(0), AComp.InternalName,
            0, 0, 0, 0);
        end;
      end;
{$IFDEF COMPILER6_UP}
      if OldGroup <> nil then
        ActivateClassGroup(OldGroup);
{$ENDIF}
      CnOtaShowDesignerForm;
      CnPaletteWrapper.SelectComponent('', '');
      if FilterFormStyle = fsFloat then
        lvComps.Selected := nil;
    end;
  except
    ; // BPL 改变导致设计期 Form 消失后，调用此功能会出访问冲突，不得已屏蔽。
  end;
end;

procedure TCnCompFilterForm.lvCompsDblClick(Sender: TObject);
begin
  actCreateComp.Execute;
end;

procedure TCnCompFilterForm.tmrHideTimer(Sender: TObject);
begin
  FJustHide := False;
  tmrHide.Enabled := False;
end;

procedure TCnCompFilterForm.FileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  if NotifyCode in [ofnPackageInstalled, ofnPackageUnInstalled] then
  begin
{$IFDEF DEBUG}
    Cndebugger.LogMsg('CompFilter: Package Changed.');
{$ENDIF}
    if Application.FindComponent('AppBuilder') = nil then
    begin
      Close;
      Exit;
    end;
    FPackageChanged := True;

    case FilterFormStyle of
      fsFloat:
      begin
        FNeedRefresh := True;
        FilterFormStyle := fsHidden;
      end;
      fsDropped:
      begin
        LoadComponentsList;
        UpdateToDisplayList;
      end;
      fsHidden:
      begin
        FNeedRefresh := True;
      end;
    end;
  end;
end;

procedure TCnCompFilterForm.lvCompsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  CustomDrawItem(Sender as TListView, Item, State, DefaultDraw);
end;

procedure TCnCompFilterForm.lvCompsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in ['0'..'9', 'a'..'z', 'A'..'Z'] then
  begin
    PostMessage(edtSearch.Handle, WM_CHAR, Integer(Key), 0);
    edtSearch.SetFocus;
    Key := #0;
  end
  else if Key = #13 then
  begin
    Key := #0;
    if tbst1.TabIndex = 0 then
      actCreateComp.Execute
    else
    begin
      if FilterFormStyle = fsDropped then
        FilterFormStyle := fsHidden;
    end;
  end;
end;

procedure TCnCompFilterForm.btnMatchModeClick(Sender: TObject);
begin
  UpdateToDisplayList;
  lvComps.Items.Count := FDisplayList.Count;
  lvComps.Invalidate;
  lvTabs.Items.Count := FTabsDisplayList.Count;
  lvTabs.Invalidate;
end;

procedure TCnCompFilterForm.SetShowPrefix(const Value: Boolean);
var
  I: Integer;
  Info: TCnIdeCompInfo;
begin
  if FShowPrefix <> Value then
  begin
    FShowPrefix := Value;
    for I := 0 to FCompList.Count - 1 do
    begin
      Info := TCnIdeCompInfo(FCompList.Objects[I]);
      if Info <> nil then
      begin
        if not FShowPrefix and (Info.InternalName[1] = 'T') then
          Info.CompName := Copy(Info.InternalName, 2, MaxInt)
        else
          Info.CompName := Info.InternalName;
      end;
      FCompList.Strings[I] := Info.CompName;
    end;
    UpdateToDisplayList;

    DoSettingChanged;
  end;
end;

procedure TCnCompFilterForm.SetUseSmallImg(const Value: Boolean);
begin
  if FUseSmallImg <> Value then
  begin
    FUseSmallImg := Value;
    // NOT Implemented
    DoSettingChanged;
  end;
end;

procedure TCnCompFilterForm.FormResize(Sender: TObject);
begin
  lvComps.Columns[0].Width := lvComps.Width - 22;
  lvTabs.Columns[0].Width := lvTabs.Width - 22;
  Invalidate;
end;

procedure TCnCompFilterForm.imgHdrMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not FMouseDown then
  begin
    FMouseDown := True;
    FOldX := X; FOldY := Y;
  end;
end;

procedure TCnCompFilterForm.imgHdrMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := False;
  if Left < 0 then
    Left := 0;
  if Top < 0 then
    Top := 0;
  if (Top + Height) > Screen.Height then
    Top := Screen.Height - Height;
  if (Left + Width) > Screen.Width then
    Left := Screen.Width - Width;
end;

procedure TCnCompFilterForm.imgHdrMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FMouseDown then
  begin
    imgHdr.OnMouseMove := nil;
    SetBounds(Left + X - FOldX, Top + Y - FOldY, Width, Height);
    if FilterFormStyle = fsDropped then
      FilterFormStyle := fsFloat;
    imgHdr.OnMouseMove := imgHdrMouseMove;
  end;
end;

procedure TCnCompFilterForm.actCreateCompUpdate(Sender: TObject);
begin
  actCreateComp.Enabled := (tbst1.TabIndex = 0) and (lvComps.Selected <> nil);
end;

procedure TCnCompFilterForm.SetAutoSelect(const Value: Boolean);
begin
  if FAutoSelect <> Value then
  begin
    FAutoSelect := Value;
    if not FAutoSelect then
      CnPaletteWrapper.SelectComponent('', '')
    else if Assigned(lvComps.OnChange) then
      lvComps.OnChange(lvComps, lvComps.Selected, ctState);

    DoSettingChanged;
  end;
end;

procedure TCnCompFilterForm.lvCompsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  Info: TCnIdeCompInfo;
  AClass: TClass;
begin
  if FAutoSelect and (Change = ctState) and (lvComps.Selected <> nil) then
  begin
    if lvComps.Selected.Data <> nil then
    begin
      Info := TCnIdeCompInfo(lvComps.Selected.Data);
      if Info.PackageName = '' then
        FDetailStr := Format(SCnComponentDetailFmt, [Info.InternalName, Info.CompUnitName, Info.TabName])
      else
        FDetailStr := Format(SCnComponentWithPackageDetailFmt, [Info.InternalName, Info.CompUnitName,
          Info.PackageName, Info.TabName]);

      FClassNameList.Clear;

      // TODO: FMX 框架或其他非 Active 的 Group 内拿不到 Class 导致无法获得父类
      AClass := GetClass(Info.InternalName);
      while AClass <> nil do
      begin
        FClassNameList.Add(AClass.ClassName);
        AClass := AClass.ClassParent;
      end;
      FDetailStr := FDetailStr + FClassNameList.Text;

      if FShowDetails then
      begin
        tmrShowHint.Enabled := False;
        tmrShowHint.Enabled := True;
      end;

      CnPaletteWrapper.SelectComponent(Info.InternalName, Info.TabName);
    end;
  end;
end;

procedure TCnCompFilterForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnCompFilterForm.FormEditorNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
begin
  if NotifyType = fetActivated then
    CheckEnvAndUpdateCompList;
end;

procedure TCnCompFilterForm.CheckEnvAndUpdateCompList;
var
  EnvChanged: Boolean;
{$IFDEF COMPILER6_UP}
  FormDesigner: IDesigner;
  AContainer: TComponent;
  IsDataModule: Boolean;
{$ENDIF}
begin
  try
{$IFDEF COMPILER6_UP}
    if (BorlandIDEServices as IOTAServices).GetActiveDesignerType <> FOldDesignerType then
    begin
{$IFDEF DEBUG}
      Cndebugger.LogMsg('DesignerType different');
{$ENDIF}
      EnvChanged := True;
      FOldDesignerType := (BorlandIDEServices as IOTAServices).GetActiveDesignerType;
    end
    else
    begin
      FormDesigner := CnOtaGetFormDesigner;
      if FormDesigner = nil then Exit;
      AContainer := FormDesigner.Root;
      // 不是 VCL/CLX 下的可视基类则表示是 DataModule
      IsDataModule := not (AContainer is TWinControl) and
        not ObjectIsInheritedFromClass(AContainer, 'TWidgetControl');

{$IFDEF DEBUG}
      Cndebugger.LogBoolean(IsDataModule, 'Current Is Datamodule: ');
{$ENDIF}

      EnvChanged := FIsDataModule <> IsDataModule; // 不同则变了
      FIsDataModule := IsDataModule;
    end;
{$ELSE}
    // D5 下不需要更新
    EnvChanged := False;
{$ENDIF}

    if EnvChanged then
    begin
      if not FUpdating and (((FilterFormStyle = fsDropped) and not FJustLoad)
        or (FilterFormStyle = fsFloat)) then
      begin
        CnWizNotifierServices.ExecuteOnApplicationIdle(DoUpdateCompList);
      end
      else
        FNeedRefresh := True;
    end;
  except
    ;
  end;
end;

procedure TCnCompFilterForm.DoUpdateCompList(Sender: TObject);
begin
  try
    FUpdating := True;
    LoadComponentsList;
    UpdateToDisplayList;
  finally
    FUpdating := False;
  end;
end;

function TCnCompFilterForm.GetHelpTopic: string;
begin
  Result := 'CnPalEnhanceWizard';
end;

procedure TCnCompFilterForm.SetFilterTab(const Value: string);
begin
  FFilterTab := Value;
  UpdateToDisplayList;
end;

procedure TCnCompFilterForm.SetShowDetails(const Value: Boolean);
begin
  if FShowDetails <> Value then
  begin
    FShowDetails := Value;
    UpdateToDisplayList;
    DoSettingChanged;

    if not FShowDetails then
      DeactivateDetailHint
    else if Assigned(lvComps.OnChange) then
      lvComps.OnChange(lvComps, lvComps.Selected, ctState);
  end;
end;

procedure TCnCompFilterForm.DoSettingChanged;
begin
  if Assigned(FOnSettingChanged) then
    FOnSettingChanged(Self);
end;

procedure TCnCompFilterForm.pmListPopup(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  CnPaletteWrapper.SelectComponent('', '');
  mniShowPrefix.Checked := FShowPrefix;
  mniAutoSelect.Checked := FAutoSelect;
  mniShowDetailHint.Checked := FShowDetails;
  mniShowAllTabs.Checked := FFilterTab = '';

  // 删除旧的 Tabs 菜单项
  if mniTabs.Count > 2 then
    for I := mniTabs.Count - 1 downto 2 do
      mniTabs.Delete(I);

  for I := 0 to CnPaletteWrapper.TabCount - 1 do
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := CnPaletteWrapper.Tabs[I];
    if FFilterTab = Item.Caption then
      Item.Checked := True;

    Item.Tag := I;
    Item.OnClick := TabsMenuClick;
    mniTabs.Add(Item);
  end;
end;

procedure TCnCompFilterForm.TabsMenuClick(Sender: TObject);
begin
  if (Sender is TMenuItem) then
  begin
    FilterTab := CnPaletteWrapper.Tabs[(Sender as TMenuItem).Tag];
    CnPaletteWrapper.SelectComponent('', CnPaletteWrapper.Tabs[(Sender as TMenuItem).Tag]);
  end;
end;

procedure TCnCompFilterForm.mniShowPrefixClick(Sender: TObject);
begin
  ShowPrefix := not ShowPrefix;
end;

procedure TCnCompFilterForm.mniShowDetailHintClick(Sender: TObject);
begin
  ShowDetails := not ShowDetails;
end;

procedure TCnCompFilterForm.mniAutoSelectClick(Sender: TObject);
begin
  AutoSelect := not AutoSelect;
end;

procedure TCnCompFilterForm.mniShowAllTabsClick(Sender: TObject);
begin
  FilterTab := '';
end;

procedure TCnCompFilterForm.ActivateDetailHint;
const
  AMargin = 10;
var
  R: TRect;
  P: TPoint;
  AWidth, HintWidth, HintHeight: Integer;
  I: Integer;
begin
  // 计算 HINT 窗口的位置，允许左右两处
  FDetailsList.Text := FDetailStr;
  HintWidth := 0; 
  // 获得最宽的文字
  for I := 0 to FDetailsList.Count - 1 do
  begin
    AWidth := FDetailHint.Canvas.TextWidth(FDetailsList[I]);
    if AWidth > HintWidth then
      HintWidth := AWidth;
  end;

  // 获得最高的文字
  if Trim(FDetailsList[FDetailsList.Count - 1]) = '' then
    HintHeight := (FDetailsList.Count - 1) * (FDetailHint.Canvas.TextHeight('Jy') + 1)
  else
    HintHeight := FDetailsList.Count * (FDetailHint.Canvas.TextHeight('Jy') + 1);

  P.x := 0;
  P.y := 0;
  // 得到左上角的
  P := lvComps.ClientToScreen(P);

  R.Top := P.y;
  if P.x - HintWidth - 3 * AMargin < 0 then // 左边的太左，换右边
  begin
    P.x := lvComps.Width;
    P.y := 0;
    // 得到右上角的
    P := lvComps.ClientToScreen(P);

    if P.x + HintWidth + 3 * AMargin > Screen.Width then // 右边的太右，换
      R.Left := Screen.Width - HintWidth - 3 * AMargin
    else // 取右边
      R.Left := P.x + AMargin;
  end
  else // 取左边
    R.Left := P.x - HintWidth - 3 * AMargin;

  R.Bottom := R.Top + HintHeight + 2 * AMargin;
  R.Right := R.Left + HintWidth + 2 * AMargin;

  FDetailHint.ActivateHint(R, FDetailStr);
  tmrHint.Enabled := False;
  tmrHint.Enabled := True;
end;

procedure TCnCompFilterForm.tmrHintTimer(Sender: TObject);
begin
  DeactivateDetailHint;
end;

procedure TCnCompFilterForm.DeactivateDetailHint;
begin
  if FDetailHint <> nil then
    FDetailHint.ReleaseHandle;
  tmrHint.Enabled := False;
end;

procedure TCnCompFilterForm.tmrLoadTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  Cndebugger.LogMsg('Just load Time out.');
{$ENDIF}
  FJustLoad := False;
  lvComps.Invalidate;
  tmrLoad.Enabled := False;
end;

procedure TCnCompFilterForm.DoLanguageChanged(Sender: TObject);
begin
  Caption := SCnSearchComponent;
  InitButtonFrame;

  if (tbst1 <> nil) and (tbst1.Tabs.Count > 0) then
    tbst1.TabIndex := 0;
  if FDetailHint <> nil then
    DeactivateDetailHint;
end;

procedure TCnCompFilterForm.tbst1Change(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
var
  Pnl: TPanel;
begin
  if NewTab = 0 then
    Pnl := pnlComp
  else
    Pnl := pnlTab;

  if Pnl.Align <> alClient then
    Pnl.Align := alClient;
  Pnl.BringToFront;

  if FDisplayList = nil then
    Exit;

  UpdateToDisplayList;
  if NewTab = 0 then
  begin
    lvComps.Items.Count := FDisplayList.Count;
    lvComps.Invalidate;
  end
  else
  begin
    lvTabs.Items.Count := FTabsDisplayList.Count;
    lvTabs.Invalidate;
    DeactivateDetailHint;
  end;

  if FFilterTab = '' then
    Caption := SCnSearchComponent
  else if tbst1.TabIndex = 0 then
    Caption := SCnSearchComponent + ' - ' + FFilterTab;
end;

procedure TCnCompFilterForm.ClearTabList;
var
  I: Integer;
begin
  for I := 0 to FTabsList.Count - 1 do
    if FTabsList.Objects[I] <> nil then
      FTabsList.Objects[I].Free;
  FTabsList.Clear;
end;

procedure TCnCompFilterForm.lvTabsData(Sender: TObject; Item: TListItem);
begin
  if Item.Index < FTabsDisplayList.Count then
  begin
    Item.Caption := FTabsDisplayList[Item.Index];
    Item.Data := FTabsDisplayList.Objects[Item.Index];
  end;
end;

procedure TCnCompFilterForm.lvTabsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  CustomDrawItem(Sender as TListView, Item, State, DefaultDraw);
end;

procedure TCnCompFilterForm.lvTabsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (Change = ctState) and (lvTabs.Selected <> nil) then
    CnPaletteWrapper.SelectComponent('', lvTabs.Selected.Caption);
end;

procedure TCnCompFilterForm.lvTabsDblClick(Sender: TObject);
begin
  if FilterFormStyle = fsDropped then
    FilterFormStyle := fsHidden;
end;

procedure TCnCompFilterForm.lvCompsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_LEFT, VK_RIGHT] then
  begin
    PostMessage(edtSearch.Handle, WM_KEYDOWN, Key, 0);
    edtSearch.SetFocus;
  end
end;

function TCnCompFilterForm.RegExpContainsText(AText, APattern: string;
  IsMatchStart: Boolean): Boolean;
begin
  Result := True;
  if APattern = '' then Exit;

  if IsMatchStart and (APattern[1] <> '^') then // 额外的从头匹配
    APattern := '^' + APattern;

  FRegExpr.Expression := APattern;
  try
    Result := FRegExpr.Exec(AText);
  except
    Result := False;
  end;
end;

procedure TCnCompFilterForm.CustomDrawItem(Sender: TListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  R: TRect;
  Bmp: TBitmap;
  X, Y, ImgIdx: Integer;
  ImgList: TCustomImageList;
  MatchedIndexes: TList;
begin
  DefaultDraw := False;
  R := Item.DisplayRect(drSelectBounds);

  ImgIdx := 0;
  MatchedIndexes := nil;
  if Sender = lvComps then // 单独处理组件部分
  begin
    if Item.Data <> nil then
    begin
      // 需要时，如未取，则取
      if TCnIdeCompInfo(Item.Data).ImgIndex = CnImgIndexUnset then
        TCnIdeCompInfo(Item.Data).ImgIndex := AddCompImage(TCnIdeCompInfo(Item.Data).InternalName);
      ImgIdx := TCnIdeCompInfo(Item.Data).ImgIndex;
      MatchedIndexes := TCnIdeCompInfo(Item.Data).MatchedIndexes;
    end
    else
      ImgIdx := CnImgIndexInvalid;
  end
  else if Sender = lvTabs then
    MatchedIndexes := TList(Item.Data);

  // 创建临时位图以消除闪烁
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.Width := R.Right - R.Left;
    Bmp.Height := R.Bottom - R.Top;

    Bmp.Canvas.Font.Assign(Sender.Font);
    Bmp.Canvas.Font.Style := [fsBold];
    Bmp.Canvas.Brush.Style := bsSolid;

    ImgList := Sender.SmallImages;
    if Item.Selected then
    begin
      Bmp.Canvas.Brush.Color := $FFB0B0;
      Bmp.Canvas.Font.Color := clBlue;
    end;
    Bmp.Canvas.FillRect(Bounds(1, (Bmp.Height - ImgList.Height) div 2,
      Bmp.Width - 1, ImgList.Height));

    if ImgIdx >= 0 then
      ImgList.Draw(Bmp.Canvas, 1, (Bmp.Height - ImgList.Height) div 2, ImgIdx);

    X := ImgList.Width + 2;
    Y := (Bmp.Height - Bmp.Canvas.TextHeight(Item.Caption)) div 2;
    DrawMatchText(Bmp.Canvas, edtSearch.Text, Item.Caption, X, Y, clRed, MatchedIndexes);

    BitBlt(Sender.Canvas.Handle, R.Left, R.Top, Bmp.Width, Bmp.Height,
      Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    Bmp.Free;
  end;
end;

{ TCnIdeCompInfo }

constructor TCnIdeCompInfo.Create;
begin
  FMatchedIndexes := TList.Create;
end;

destructor TCnIdeCompInfo.Destroy;
begin
  FMatchedIndexes.Free;
  inherited;
end;

procedure TCnCompFilterForm.MatchModeChange(Sender: TObject);
begin
  UpdateToDisplayList;
  lvComps.Items.Count := FDisplayList.Count;
  lvComps.Invalidate;
  lvTabs.Items.Count := FTabsDisplayList.Count;
  lvTabs.Invalidate;
end;

procedure TCnCompFilterForm.InitButtonFrame;
begin
  if FMatchButtonFrame <> nil then
  begin
    FMatchButtonFrame.mniMatchStart.Caption := SCnMatchButtonFrameMenuStartCaption;
    FMatchButtonFrame.mniMatchStart.Hint := SCnMatchButtonFrameMenuStartHint;
    FMatchButtonFrame.mniMatchAny.Caption := SCnMatchButtonFrameMenuAnyCaption;
    FMatchButtonFrame.mniMatchAny.Hint := SCnMatchButtonFrameMenuAnyHint;
    FMatchButtonFrame.mniMatchFuzzy.Caption := SCnMatchButtonFrameMenuFuzzyCaption;
    FMatchButtonFrame.mniMatchFuzzy.Hint := SCnMatchButtonFrameMenuFuzzyHint;
    FMatchButtonFrame.SyncButtonHint;
  end;
end;

procedure TCnCompFilterForm.SelectItemByIndex(ListView: TListView;
  AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < ListView.Items.Count) then
  begin
    ListView.Selected := nil;
    ListView.Selected := ListView.Items[AIndex];
    ListView.ItemFocused := ListView.Selected;
  end;
end;

procedure TCnCompFilterForm.tmrShowHintTimer(Sender: TObject);
begin
  tmrShowHint.Enabled := False;
  ActivateDetailHint;
end;

initialization
  // 挂接系统的 Classes.RegisterComponentsProc
  if Assigned(RegisterComponentsProc) then
  begin
    FOldRegisterComponentsProc := Classes.RegisterComponentsProc;
    Classes.RegisterComponentsProc := CnCompRegisterComponents;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnCompFilterFrm.');
{$ENDIF}

finalization
  if ComponentTabListMap <> nil then
    FreeAndNil(ComponentTabListMap);
    
  // 恢复挂接系统的 Classes.RegisterComponentsProc
  if Assigned(FOldRegisterComponentsProc) then
  begin
    Classes.RegisterComponentsProc := FOldRegisterComponentsProc;
    FOldRegisterComponentsProc := nil;
  end;

  if CnCompFilterForm <> nil then
    FreeAndNil(CnCompFilterForm);

{$ENDIF}

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}
end.
