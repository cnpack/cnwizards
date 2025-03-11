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

unit CnProjectViewBaseFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程扩展工具窗体列表单元列表基类
* 单元作者：Leeon (real-like@163.com); 张伟（Alan） BeyondStudio@163.com
* 备    注：保存与加载列宽时，部分高版本的 Delphi 在 HDPI 下会出现列宽计算错误，
*           因而用了个 WindowProc 的 Hook 拦截 ListView 的列宽改变消息才保存，
*           但 D12 下这个消息拦截不到，因而 D12 下只能接受可能有的列宽误差。
* 开发平台：PWin2000Pro + Delphi 5.5
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2019.12.10 V1.2
*               支持 STAND_ALONE 单独编译模式
*           2004.02.22 V1.1
*               重写所有代码
*           2004.02.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, Contnrs, ActnList, CommCtrl,
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF COMPILER6_UP}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles,
{$IFNDEF STAND_ALONE} ToolsAPI, CnWizUtils, CnWizIdeUtils, CnWizNotifier, CnIDEVersion, {$ENDIF}
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnIni, CnWizMultiLang,
  CnWizShareImages, CnIniStrUtils, RegExpr, CnStrings;

type

//==============================================================================
// 工程信息类
//==============================================================================

{ TCnProjectInfo }

  TCnProjectInfo = class
    Name: string;
    FileName: string;
  end;

//==============================================================================
// 列表信息基类
//==============================================================================

  TCnBaseElementInfo = class
  private
    FText: string;
    FMatchIndexes: TList;
    FParentProject: TCnProjectInfo;
    FFuzzyScore: Integer;
    FStartOffset: Integer;
    FImageIndex: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property StartOffset: Integer read FStartOffset write FStartOffset;
    {* 匹配的起始位置，默认为 0}
    property FuzzyScore: Integer read FFuzzyScore write FFuzzyScore;
    {* 模糊匹配的匹配度，暂未使用}
    property MatchIndexes: TList read FMatchIndexes;
    {* 模糊匹配 Text 的下标}
    property ParentProject: TCnProjectInfo read FParentProject write FParentProject;
    {* 该元素从属的 Project，无则为 nil}
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    {* 显示时用来存 ImageIndex 图标序号，多个子类需要，因此提至父类中}
  published
    property Text: string read FText write FText;
    {* Text 表示第一列显示的文字}
  end;

  TCnDrawMatchTextEvent = procedure (Canvas: TCanvas; const MatchStr, Text: string;
    X, Y: Integer; HighlightColor: TColor) of object;

//==============================================================================
// 工程组单元窗体列表基类窗体
//==============================================================================

{ TCnProjectViewBaseForm }

  TCnProjectViewBaseForm = class(TCnTranslateForm)
    actAttribute: TAction;
    actClose: TAction;
    actCopy: TAction;
    actHelp: TAction;
    actHookIDE: TAction;
    ActionList: TActionList;
    actMatchAny: TAction;
    actMatchStart: TAction;
    actOpen: TAction;
    actQuery: TAction;
    actSelectAll: TAction;
    actSelectInvert: TAction;
    actSelectNone: TAction;
    cbbProjectList: TComboBox;
    edtMatchSearch: TEdit;
    lblProject: TLabel;
    lblSearch: TLabel;
    lvList: TListView;
    pnlHeader: TPanel;
    StatusBar: TStatusBar;
    btnMatchAny: TToolButton;
    btnAttribute: TToolButton;
    btnClose: TToolButton;
    btnCopy: TToolButton;
    btnHelp: TToolButton;
    btnHookIDE: TToolButton;
    btnOpen: TToolButton;
    btnQuery: TToolButton;
    btnSelectInvert: TToolButton;
    btnSelectAll: TToolButton;
    btnSep1: TToolButton;
    btnSep3: TToolButton;
    btnSep4: TToolButton;
    btnSep5: TToolButton;
    btnSep6: TToolButton;
    btnSep7: TToolButton;
    btnSep8: TToolButton;
    btnMatchStart: TToolButton;
    btnSelectNone: TToolButton;
    ToolBar: TToolBar;
    actFont: TAction;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    btnMatchFuzzy: TToolButton;
    actMatchFuzzy: TAction;
    pnlMain: TPanel;
    procedure lvListDblClick(Sender: TObject);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbbProjectListChange(Sender: TObject);
    procedure edtMatchSearchChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectNoneExecute(Sender: TObject);
    procedure actSelectInvertExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actAttributeExecute(Sender: TObject);
    procedure actMatchStartExecute(Sender: TObject);
    procedure actMatchAnyExecute(Sender: TObject);
    procedure actQueryExecute(Sender: TObject);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actHookIDEExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListKeyPress(Sender: TObject; var Key: Char);
    procedure lvListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actMatchFuzzyExecute(Sender: TObject);
  private
    FOutDataListRef: TStringList; // 外部 DataList 临时存储的地方
    FSortIndex: Integer;
    FSortDown: Boolean;
    FUpArrow: TBitmap;
    FDownArrow: TBitmap;
    FNoArrow: TBitmap;
{$IFNDEF STAND_ALONE}
    FListViewWidthStr: string;
    FListViewWidthOldStr: string;
{$ENDIF}
    FColumnWidthManuallyChanged: Boolean;
    FOldListViewWndProc: TWndMethod;
    function GetMatchAny: Boolean;
    procedure SetMatchAny(const Value: Boolean);

    function GetMatchMode: TCnMatchMode;
    procedure SetMatchMode(const Value: TCnMatchMode);
    procedure InitArrowBitmaps;
    procedure ClearColumnArrow;
    procedure ChangeColumnArrow;
    procedure DoOpenSelect;
{$IFNDEF STAND_ALONE}
    procedure FirstUpdate(Sender: TObject);
    procedure ChangeIconToIDEImageList;
{$ENDIF}
    procedure ListViewWindowProc(var Message: TMessage);
  protected
    FRegExpr: TRegExpr;
    NeedInitProjectControls: Boolean;
    FProjectListSelectedAllProject: Boolean;
    ProjectList: TObjectList;     // 存储 ProjectInfo 的列表
    ProjectInfoSearch: TCnProjectInfo;  // 标记待限定的 Project 搜索范围
    DataList: TStringList;        // 供子类存储原始需要搜索的列表名字以及 Object
    DisplayList: TStringList;     // 供子类容纳过滤后需要显示的列表名字以及 Object（引用）
    function DisableLargeIcons: Boolean; virtual; // 供子类重载以因为特殊原因禁用大图标，默认跟着设置走
    function DoSelectOpenedItem: string; virtual;
    procedure DoSelectItemChanged(Sender: TObject); virtual;
    procedure DoUpdateListView; virtual;

    // === New Routines for refactor ===
    // 提前准备调用参数
    procedure PrepareSearchRange; virtual;
    // 实现根据匹配规则从 DataList 更新至 DisplayList的功能，一般无须重载
    procedure CommonUpdateListView; virtual;
    // 子类重载以返回在指定匹配字符、指定匹配模式下，DataList 中的指定项是否匹配
    // 调用此方法前 ProjectInfo 指定了下拉框所标识的工程范围
    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; virtual;
    // 子类重载以返回此项是否可以作为优先选中的项，一般无须重载
    function CanSelectDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer): Boolean; virtual;
    // 排序比较器，子类重载以实现根据 Object 比较的功能
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; virtual;

    // 默认匹配的实现，只匹配 DataList 中的字符串，不处理其 Object 所代表的内容
    function DefaultMatchHandler(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList;
      CaseSensitive: Boolean = False): Boolean;
    // 默认允许优先选择最头上匹配的项
    function DefaultSelectHandler(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer): Boolean;
    // 释放 DataList 供重新初始化的场合
    procedure ClearDataList;
    // 供子类决定绘制 Item 时可以修改部分绘制参数如颜色等
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); virtual;
    // === New Routines for refactor ===

    procedure DoSortListView; virtual;
    {* 供子类重载用，被 UpdateListView 调用}
    function GetSelectedFileName: string; virtual; abstract;
    procedure CreateList; virtual;
    {* 窗体 OnCreate 时被第一个调用，用来初始化数据，一般把内容加载进 DataList 中，
       如果待加载内容太多，也可在 UpdateListView 时做 }
    procedure UpdateComboBox; virtual;
    {* 窗体 OnCreate 时被第二个调用，用来初始化 ComboBox 中的内容}
    procedure UpdateListView; virtual;
    {* 窗体 OnCreate 时被第三个调用，用来更新 ListView 中的内容，同时还在其他响应输入的地方调用}
    procedure UpdateStatusBar; virtual;
    procedure OpenSelect; virtual; abstract;
    procedure FontChanged(AFont: TFont); virtual;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean); virtual;
    procedure SelectFirstItem;
    procedure SelectItemByIndex(AIndex: Integer);
    procedure LoadProjectSettings(Ini: TCustomIniFile; aSection: string);
    procedure SaveProjectSettings(Ini: TCustomIniFile; aSection: string);
  public
    constructor Create(AOwner: TComponent; ADataList: TStringList = nil); reintroduce;
    procedure AfterConstruction; override;

    procedure SelectOpenedItem;
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string); virtual;
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string); virtual;
    property SortIndex: Integer read FSortIndex write FSortIndex;
    property SortDown: Boolean read FSortDown write FSortDown;
    property MatchMode: TCnMatchMode read GetMatchMode write SetMatchMode;
    property MatchAny: Boolean read GetMatchAny write SetMatchAny;
  end;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csMatchAny = 'MatchAny';
  csMatchMode = 'MatchMode';
  csFont = 'Font';
  csSortIndex = 'SortIndex';
  csSortDown = 'SortDown';
  csCurrentPrj = 'SelectCurrentProject';
  csHookIDE = 'HookIDE';
  csOpenMultiUnitQuery = 'Query';
  csWidth = 'Width';
  csHeight = 'Height';
  csListViewWidth = 'ListViewWidth';

  csDrawIconMargin = 1;

  {CommCtrl Constants For Windows >= XP }
  HDF_SORTUP              = $0400;
  HDF_SORTDOWN            = $0200;

type
  TSortCompareEvent = function(ASortIndex: Integer; const AMatchStr: string;
    const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer of object;

var
  GlobalSortIndex: Integer;
  GlobalSortDown: Boolean;
  GlobalSortMatchStr: string;
  GlobalSortCompareEvent: TSortCompareEvent = nil;

function DoListSort(List: TStringList; Index1, Index2: Integer): Integer;
var
  Obj1, Obj2: TObject;
begin
  Obj1 := List.Objects[Index1];
  Obj2 := List.Objects[Index2];

  if Assigned(GlobalSortCompareEvent) then
  begin
    Result := GlobalSortCompareEvent(GlobalSortIndex, GlobalSortMatchStr,
      List[Index1], List[Index2], Obj1, Obj2, GlobalSortDown);
  end
  else
    Result := AnsiCompareStr(List[Index1], List[Index2]);
end;

//==============================================================================
// 工程组单元窗体列表基类窗体
//==============================================================================

{ TCnProjectViewBaseForm }

procedure TCnProjectViewBaseForm.ListViewWindowProc(var Message: TMessage);
var
  NM: TWMNotify;
begin
  FOldListViewWndProc(Message);
  if Message.Msg = WM_NOTIFY then
  begin
    // 注意，似乎在 D12 下进不来，收不到列宽改变的通知
    NM := TWMNotify(Message);
    case NM.NMHdr^.code of
      HDN_ENDTRACK, HDN_BEGINTRACK, HDN_TRACK:
      begin
        FColumnWidthManuallyChanged := True;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('%s ListView Column Width Manually Changed.', [ClassName]);
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.FormCreate(Sender: TObject);
var
  OldC: TCursor;
begin
  OldC := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
{$IFNDEF STAND_ALONE}
    if CnIsDelphi11GEDot3 then
    begin
      FOldListViewWndProc := lvList.WindowProc;
      lvList.WindowProc := ListViewWindowProc;
    end;
{$ENDIF}

    FRegExpr := TRegExpr.Create;
    FRegExpr.ModifierI := True;
    FUpArrow := TBitmap.Create;
    FDownArrow := TBitmap.Create;
    FNoArrow := TBitmap.Create;
    InitArrowBitmaps;
{$IFNDEF STAND_ALONE}
    ChangeIconToIDEImageList;
{$ENDIF}
    lvList.DoubleBuffered := True;
    ProjectList := TObjectList.Create;
    NeedInitProjectControls := True;

    DataList := TStringList.Create;
    DisplayList := TStringList.Create;
    GlobalSortCompareEvent := SortItemCompare;

    CreateList;
{$IFDEF DEBUG}
    CnDebugger.LogMsg(ClassName + ': DataList Count: ' + IntToStr(DataList.Count));
{$ENDIF}
    UpdateComboBox;
  finally
    Screen.Cursor := OldC;
  end;
end;

procedure TCnProjectViewBaseForm.FormShow(Sender: TObject);
begin
  UpdateListView;
  SelectOpenedItem;
{$IFNDEF STAND_ALONE}
  {$IFDEF BDS}
  SetListViewWidthString(lvList, FListViewWidthStr, GetFactorFromSizeEnlarge(Enlarge));
  {$ENDIF}
  CnWizNotifierServices.ExecuteOnApplicationIdle(FirstUpdate);
{$ENDIF}
end;

procedure TCnProjectViewBaseForm.FormDestroy(Sender: TObject);
begin
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.StopExecuteOnApplicationIdle(DoSelectItemChanged);
{$ENDIF}
  ProjectList.Free;
  GlobalSortCompareEvent := nil;
  ClearDataList;
  FUpArrow.Free;
  FDownArrow.Free;
  FNoArrow.Free;
  FreeAndNil(DataList);
  FreeAndNil(DisplayList);
  FRegExpr.Free;
end;

procedure TCnProjectViewBaseForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    lvListDblClick(Sender);
    Key := #0;
  end
  else if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end
  else if Key = #22 then // Ctrl + V
  begin
    if edtMatchSearch.Focused then
    begin
      if Clipboard.HasFormat(CF_TEXT) then
      begin
        edtMatchSearch.PasteFromClipboard;
        edtMatchSearch.Text := Trim(edtMatchSearch.Text);
        Key := #0;
      end;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actSelectAll.Enabled := lvList.Items.Count > 0;
  actSelectNone.Enabled := lvList.Items.Count > 0;
  actSelectInvert.Enabled := lvList.Items.Count > 0;

  actOpen.Enabled := lvList.SelCount > 0;
  actAttribute.Enabled := lvList.SelCount > 0;
  actCopy.Enabled := lvList.SelCount > 0;

  Handled := True;
end;

procedure TCnProjectViewBaseForm.actCopyExecute(Sender: TObject);
var
  i: Integer;
  AList: TStringList;
begin
  AList := TStringList.Create;
  try
    with lvList do
    begin
      for i := 0 to Pred(Items.Count) do
        if Items.Item[i].Selected and (Items.Item[i].Caption <> '') then
          AList.Add(Items[i].Caption);
    end;
  finally
    if AList.Count > 0 then
      Clipboard.AsText := TrimRight(AList.Text);
    FreeAndNil(AList);
  end;
end;

procedure TCnProjectViewBaseForm.actSelectAllExecute(Sender: TObject);
var
  i: Integer;
begin
  with lvList do
    for i := 0 to Pred(Items.Count) do
      Items[i].Selected := True;
end;

procedure TCnProjectViewBaseForm.actSelectNoneExecute(Sender: TObject);
begin
  lvList.Selected := nil;
end;

procedure TCnProjectViewBaseForm.actSelectInvertExecute(Sender: TObject);
var
  i: Integer;
begin
  with lvList do
    for i := Pred(Items.Count) downto 0 do
      Items[i].Selected := not Items[i].Selected;
end;

procedure TCnProjectViewBaseForm.actAttributeExecute(Sender: TObject);
var
  FileName: string;
begin
  FileName := GetSelectedFileName;

  if FileExists(FileName) then
    FileProperties(FileName)
  else
    InfoDlg(SCnProjExtFileNotExistOrNotSave, SCnInformation, 64);
end;

procedure TCnProjectViewBaseForm.actOpenExecute(Sender: TObject);
begin
  DoOpenSelect;
end;

procedure TCnProjectViewBaseForm.actHookIDEExecute(Sender: TObject);
begin
  actHookIDE.Checked := not actHookIDE.Checked;
end;

procedure TCnProjectViewBaseForm.actMatchStartExecute(Sender: TObject);
begin
  MatchAny := False;
  MatchMode := mmStart;
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.actMatchAnyExecute(Sender: TObject);
begin
  MatchAny := True;
  MatchMode := mmAnywhere;
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.FontChanged(AFont: TFont);
begin

end;

procedure TCnProjectViewBaseForm.actFontExecute(Sender: TObject);
begin
  dlgFont.Font := lvList.Font;
  if dlgFont.Execute then
  begin
    lvList.ParentFont := False;
    lvList.Font := dlgFont.Font;
    FontChanged(dlgFont.Font);
  end;
end;

procedure TCnProjectViewBaseForm.actQueryExecute(Sender: TObject);
begin
  actQuery.Checked := not actQuery.Checked;
end;

procedure TCnProjectViewBaseForm.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCnProjectViewBaseForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not (((Key = VK_F4) and (ssAlt in Shift)) or
    (Key in [VK_DELETE, VK_LEFT, VK_RIGHT]) or
    ((Key in [VK_HOME, VK_END]) and not (ssCtrl in Shift)) or
    ((Key in [VK_INSERT]) and ((ssShift in Shift) or (ssCtrl in Shift)))) then
  begin
    SendMessage(lvList.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
  end;
end;

procedure TCnProjectViewBaseForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnProjectViewBaseForm.GetMatchAny: Boolean;
begin
  Result := actMatchAny.Checked;
end;

procedure TCnProjectViewBaseForm.SetMatchAny(const Value: Boolean);
begin
  actMatchAny.Checked := Value;
  actMatchStart.Checked := not Value;
end;

procedure TCnProjectViewBaseForm.DoSortListView;
var
  Sel: Pointer;
begin
  if lvList.Selected <> nil then
    Sel := lvList.Selected.Data
  else
    Sel := nil;

  GlobalSortIndex := SortIndex;
  GlobalSortDown := SortDown;
  GlobalSortMatchStr := edtMatchSearch.Text;

  QuickSortStringList(DisplayList, 0, DisplayList.Count - 1, DoListSort);
  lvList.Invalidate;

  if Sel <> nil then
    SelectItemByIndex(DisplayList.IndexOfObject(Sel));
end;

procedure TCnProjectViewBaseForm.lvListColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ClearColumnArrow;
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;
  DoSortListView;
  ChangeColumnArrow;
end;

procedure TCnProjectViewBaseForm.lvListDblClick(Sender: TObject);
begin
  DoOpenSelect;
end;

procedure TCnProjectViewBaseForm.cbbProjectListChange(Sender: TObject);
begin
  if Visible then
  begin
    UpdateListView;
    SelectOpenedItem;
  end;
end;

procedure TCnProjectViewBaseForm.LoadProjectSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  with Ini do
  begin
    FProjectListSelectedAllProject := not ReadBool(aSection, csCurrentPrj, False);
    if not FProjectListSelectedAllProject then
    begin
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtCurrentProject);
      cbbProjectListChange(nil);
    end
    else
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtProjectAll);

    actHookIDE.Checked := ReadBool(aSection, csHookIDE, True);
    actQuery.Checked := ReadBool(aSection, csOpenMultiUnitQuery, True);
  end;
end;

procedure TCnProjectViewBaseForm.SaveProjectSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  with Ini do
  begin
    if not FProjectListSelectedAllProject then
      WriteBool(aSection, csCurrentPrj, True)
    else
      WriteBool(aSection, csCurrentPrj, False);

    WriteBool(aSection, csHookIDE, actHookIDE.Checked);
    WriteBool(aSection, csOpenMultiUnitQuery, actQuery.Checked);
  end;
end;

procedure TCnProjectViewBaseForm.LoadSettings(Ini: TCustomIniFile; aSection: string);
const
  MIN_WH = 200;
var
  TW, TH: Integer;
  sFont: string;
begin
  with TCnIniFile.Create(Ini) do
  try
    MatchAny := ReadBool(aSection, csMatchAny, True);
    MatchMode := TCnMatchMode(ReadInteger(aSection, csMatchMode, Ord(mmFuzzy)));

    sFont := ReadString(aSection, csFont, '');
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnProjectViewBaseForm ReadFont: ' + sFont);
    CnDebugger.LogMsg('TCnProjectViewBaseForm SelfFont: ' + FontToString(Self.Font));
{$ENDIF}
    if (sFont <> '') and (sFont <> FontToString(Self.Font)) then
    begin
      // 只有保存的字体不等于窗体字体的时候，也即用户设置过字体后，才载入
      lvList.ParentFont := False;
      lvList.Font := ReadFont(aSection, csFont, lvList.Font);
      dlgFont.Font := lvList.Font;
      FontChanged(dlgFont.Font);
    end;

    FSortIndex := ReadInteger(aSection, csSortIndex, 0);
    FSortDown := ReadBool(aSection, csSortDown, False);
    lvList.CustomSort(nil, 0); // 按保存的设置排序
    ChangeColumnArrow;

    TW := ReadInteger(aSection, csWidth, 0);
    TH := ReadInteger(aSection, csHeight, 0);
{$IFDEF IDE_SUPPORT_HDPI}
    TW := Round(TW * IdeGetScaledFactor(Self));
    TH := Round(TH * IdeGetScaledFactor(Self));
{$ENDIF}
    if TW > MIN_WH then Width := TW;
    if TH > MIN_WH then Height := TH;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnProjectViewBaseForm.LoadSettings Load Width %d Height %d after Scale', [Width, Height]);
{$ENDIF}

{$IFNDEF STAND_ALONE}
    CenterForm(Self);
    if FListViewWidthOldStr = '' then // 保留旧宽度供判断是否改变过
      FListViewWidthOldStr := GetListViewWidthString(lvList, GetFactorFromSizeEnlarge(Enlarge));
    FListViewWidthStr := ReadString(aSection, csListViewWidth, '');
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnProjectViewBaseForm.LoadSettings Read ListView Widths %s', [FListViewWidthStr]);
{$ENDIF}
    if FListViewWidthStr <> '' then
      SetListViewWidthString(lvList, FListViewWidthStr, GetFactorFromSizeEnlarge(Enlarge));
{$ENDIF}
  finally
    Free;
  end;

  if NeedInitProjectControls then
    LoadProjectSettings(Ini, aSection);
end;

procedure TCnProjectViewBaseForm.SaveSettings(Ini: TCustomIniFile; aSection: string);
{$IFNDEF STAND_ALONE}
var
  S: string;
  TW, TH: Integer;

  function CheckWidthValid: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to lvList.Columns.Count - 1 do
    begin
      if lvList.Columns[I].Width > Screen.Width then // 如果列宽超过了屏幕宽度，说明出问题了
        Exit;
    end;
    Result := True;
  end;

{$ENDIF}
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool(aSection, csMatchAny, MatchAny);
    WriteInteger(aSection, csMatchMode, Ord(MatchMode));
    WriteInteger(aSection, csSortIndex, FSortIndex);
    WriteBool(aSection, csSortDown, FSortDown);

    // 如用户没设置过字体，ParentFont 会为 True，无论语言如何切换总会跟随变化
    if not lvList.ParentFont then
      WriteFont(aSection, csFont, lvList.Font)
    else
      WriteString(aSection, csFont, '');

    TW := Width;
    TH := Height;
{$IFDEF IDE_SUPPORT_HDPI}
    TW := Round(TW / IdeGetScaledFactor(Self));
    TH := Round(TH / IdeGetScaledFactor(Self));
{$ENDIF}
    WriteInteger(aSection, csWidth, TW);
    WriteInteger(aSection, csHeight, TH);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnProjectViewBaseForm.LoadSettings Save Width %d Height %d before Scale.', [TW, TH]);
{$ENDIF}

{$IFNDEF STAND_ALONE}
    if CnIsGEDelphi11Dot3 then
    begin
      S := GetListViewWidthString2(lvList, GetFactorFromSizeEnlarge(Enlarge)); // 获取正确的宽度值
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnProjectViewBaseForm.SaveSettings To Write ListView Width2 %s', [S]);
{$ENDIF}
      if {$IFNDEF DELPHI120_ATHENS_UP} FColumnWidthManuallyChanged and {$ENDIF}
        (S <> FListViewWidthOldStr) then // 有宽度 Bug 存在的情况下，只手工更改过且变化了才保存
        WriteString(aSection, csListViewWidth, S);
    end
    else
    begin
      S := GetListViewWidthString(lvList, GetFactorFromSizeEnlarge(Enlarge));
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnProjectViewBaseFormSaveSettings To Write ListView Width %s', [S]);
{$ENDIF}
      if CheckWidthValid then
      begin
        if S <> FListViewWidthOldStr then // 只变化了，且宽度合适，才保存
          WriteString(aSection, csListViewWidth, S);
      end
      else // 宽度不合适，清空设置恢复原始宽度
        WriteString(aSection, csListViewWidth, '');
    end;
{$ENDIF}
  finally
    Free;
  end;

  if NeedInitProjectControls then
    SaveProjectSettings(Ini, aSection);
end;

procedure TCnProjectViewBaseForm.UpdateStatusBar;
begin

end;

procedure TCnProjectViewBaseForm.SelectFirstItem;
begin
  with lvList do
  begin
    Selected := nil;
    Selected := Items[0];
    ItemFocused := Selected;
  end;
end;

procedure TCnProjectViewBaseForm.SelectOpenedItem;
var
  i: Integer;
  aCurrentName: string;
begin
  with lvList do
  begin
    if Items.Count = 0 then
      Exit;

    aCurrentName := DoSelectOpenedItem;
    SelectFirstItem;

    if aCurrentName = '' then
      Exit;

    for i := 0 to Pred(Items.Count) do
      if AnsiSameText(Items[i].Caption, aCurrentName) then
      begin
        Selected := nil;
        Items[i].Selected := True;
        ItemFocused := Selected;
        Selected.MakeVisible(False);
        Break;
      end;
  end;
end;

procedure TCnProjectViewBaseForm.UpdateComboBox;
begin

end;

procedure TCnProjectViewBaseForm.CreateList;
begin

end;

procedure TCnProjectViewBaseForm.UpdateListView;
begin
  PrepareSearchRange;
  CommonUpdateListView;
  DoUpdateListView;
end;

procedure TCnProjectViewBaseForm.DoSelectItemChanged(Sender: TObject);
begin
  UpdateStatusBar;
  StatusBar.Invalidate;
end;

procedure TCnProjectViewBaseForm.edtMatchSearchChange(Sender: TObject);
begin
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.lvListCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DrawListItem(Sender, Item, State, DefaultDraw);
end;

procedure TCnProjectViewBaseForm.lvListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoSelectItemChanged);
{$ELSE}
  DoSelectItemChanged(Sender);
{$ENDIF}
end;

procedure TCnProjectViewBaseForm.SelectItemByIndex(AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < lvList.Items.Count) then
  begin
    lvList.Selected := nil;
    lvList.Selected := lvList.Items[AIndex];
    lvList.ItemFocused := lvList.Selected;
    lvList.Selected.MakeVisible(True);
  end;
end;

procedure TCnProjectViewBaseForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
const
  CNCOPY_SPLITER  = #9;     // TAB
  CNCOPY_LINE     = #13#10;
var
  I, J: Integer;
  CopyBuf: string;
begin
  if lvList.MultiSelect then
  begin
    if Shift = [ssCtrl] then
    begin
      // 选择全部
      if Key = Ord('A') then
      begin
        lvList.Items.BeginUpdate;
        try
          for I := 0 to lvList.Items.Count - 1 do
            lvList.Items[I].Selected := True;
        finally
          lvList.Items.EndUpdate;
        end;
        Key := 0;
      end
      // 取消选择
      else if Key = Ord('D') then
      begin
        lvList.Items.BeginUpdate;
        try
          for I := 0 to lvList.Items.Count - 1 do
            lvList.Items[I].Selected := False;
        finally
          lvList.Items.EndUpdate;
        end;
        Key := 0;
      end
      // 复制文本
      // 现为初步功能，复制所有文字，日后可实现可选列
      else if Key = Ord('C') then
      begin
        if edtMatchSearch.Focused and (edtMatchSearch.SelText <> '') then
          Exit; // 有选择时不进行额外的复制

        if lvList.Selected <> nil then
        begin
          CopyBuf := '';

          // 产生标题
          for I := 0 to lvList.Columns.Count - 1 do
          begin
            CopyBuf := CopyBuf + lvList.Column[I].Caption;
            if I < lvList.Columns.Count - 1 then
              CopyBuf := CopyBuf + CNCOPY_SPLITER;
          end;
          CopyBuf := CopyBuf + CNCOPY_LINE;

          // 复制内容
          for I := 0 to lvList.Items.Count - 1 do
          begin
            if lvList.Items[I].Selected then
            begin
              CopyBuf := CopyBuf + lvList.Items[I].Caption;
              for J := 0 to lvList.Items[I].SubItems.Count - 1 do
                CopyBuf := CopyBuf + CNCOPY_SPLITER + lvList.Items[I].SubItems[J];
              CopyBuf := CopyBuf + CNCOPY_LINE;
            end;
          end;

          // 放入剪贴板
          Clipboard.Clear;
          Clipboard.SetTextBuf(PChar(CopyBuf));
        end
        else
        begin
          // 这里可以增加提示没有选择需要复制的内容
        end;  // if lvList.Selected <> nil
      end;
    end;
  end;
end;

procedure TCnProjectViewBaseForm.lvListKeyPress(Sender: TObject;
  var Key: Char);
begin
  if CharInSet(Key, ['0'..'9', 'a'..'z', 'A'..'Z']) then
  begin
    PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      edtMatchSearch.SetFocus;
    except
      ;
    end;
    Key := #0;
  end;
end;

procedure TCnProjectViewBaseForm.lvListKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_BACK] then
  begin
    // PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      edtMatchSearch.SetFocus;
    except
      ;
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

procedure TCnProjectViewBaseForm.FirstUpdate(Sender: TObject);
var
  I: Integer;
begin
  // Toolbar 的按钮在对应 Action 有隐藏的情况下可能会出现混乱，需要用这种办法修复一下
  for I := 0 to ActionList.ActionCount - 1 do
  begin
    if ActionList.Actions[I] is TAction then
    begin
      if not (ActionList.Actions[I] as TAction).Visible then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnProjectViewBaseForm Idle Fix Toolbar Button Mixed Problem: ' + IntToStr(I));
{$ENDIF}
        (ActionList.Actions[I] as TAction).Visible := True;
        (ActionList.Actions[I] as TAction).Visible := False;
      end;
    end;
  end;
  lvList.Update;
end;

{$ENDIF}

function TCnProjectViewBaseForm.GetMatchMode: TCnMatchMode;
begin
  Result := mmAnywhere;

  if actMatchStart.Checked then
    Result := mmStart
  else if actMatchAny.Checked then
    Result := mmAnywhere
  else if actMatchFuzzy.Checked then
    Result := mmFuzzy;
end;

procedure TCnProjectViewBaseForm.SetMatchMode(const Value: TCnMatchMode);
begin
  actMatchStart.Checked := Value = mmStart;
  actMatchAny.Checked := Value = mmAnywhere;
  actMatchFuzzy.Checked := Value = mmFuzzy;
end;

procedure TCnProjectViewBaseForm.actMatchFuzzyExecute(Sender: TObject);
begin
  MatchMode := mmFuzzy;
  UpdateListView;
end;

procedure TCnProjectViewBaseForm.CommonUpdateListView;
var
  MatchSearchText: string;
  I, ToSelIndex, AStartOffset: Integer;
  ToSels: TStringList;
  Indexes: TList;
  AMatchMode: TCnMatchMode;

  function ObjectIsBaseElementInfo(Obj: TObject): Boolean;
  begin
    try
      Result := Obj is TCnBaseElementInfo;
    except
      Result := False;
    end;
  end;

begin
  MatchSearchText := edtMatchSearch.Text;
  ToSelIndex := 0;
  ToSels := TStringList.Create;

  DisplayList.Clear;
  AMatchMode := MatchMode;
  try
    for I := 0 to DataList.Count - 1 do
    begin
      Indexes := nil;
      if (AMatchMode = mmFuzzy) and (DataList.Objects[I] <> nil) and
        ObjectIsBaseElementInfo(DataList.Objects[I]) then
      begin
        TCnBaseElementInfo(DataList.Objects[I]).FuzzyScore := 0;
        Indexes := TCnBaseElementInfo(DataList.Objects[I]).MatchIndexes;
        if Indexes <> nil then
          Indexes.Clear;
      end;
      AStartOffset := 0;

      // 不能因为 MatchSearchText = '' 就直接通过匹配，因为子类可能还有其它搜索条件
      if CanMatchDataByIndex(MatchSearchText, AMatchMode, I, AStartOffset, Indexes) then
      begin
        // DataList.Objects 有可能为 nil
        if (DataList.Objects[I] <> nil) and
          ObjectIsBaseElementInfo(DataList.Objects[I]) then
          TCnBaseElementInfo(DataList.Objects[I]).StartOffset := AStartOffset;

        DisplayList.AddObject(DataList[I], DataList.Objects[I]);
        if CanSelectDataByIndex(MatchSearchText, AMatchMode, I) then
          ToSels.Add(DataList[I]);
      end;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ViewBase Form, Get %d to Display from %d.', [DisplayList.Count, DataList.Count]);
{$ENDIF}

    DoSortListView;
    lvList.Items.Count := DisplayList.Count;
    lvList.Invalidate;
    UpdateStatusBar;

    // 如有需要选中的首匹配的项则选中，无则选 0，第一项
    if (ToSels.Count > 0) and (DisplayList.Count > 0) then
    begin
      for I := 0 to DisplayList.Count - 1 do
      begin
        if ToSels.IndexOf(DisplayList[I]) >= 0 then
        begin
          // DisplayList 中的第一个在 ToSelCompInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;
    SelectItemByIndex(ToSelIndex);
  finally
    ToSels.Free;
  end;
end;

function TCnProjectViewBaseForm.CanMatchDataByIndex(const AMatchStr: string;
  AMatchMode: TCnMatchMode; DataListIndex: Integer; var StartOffset: Integer;
  MatchedIndexes: TList): Boolean;
begin
  Result := DefaultMatchHandler(AMatchStr, AMatchMode, DataListIndex, StartOffset, MatchedIndexes);
end;

function TCnProjectViewBaseForm.CanSelectDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer): Boolean;
begin
  Result := DefaultSelectHandler(AMatchStr, AMatchMode, DataListIndex);
end;

function TCnProjectViewBaseForm.DefaultMatchHandler(const AMatchStr: string;
  AMatchMode: TCnMatchMode; DataListIndex: Integer; var StartOffset: Integer;
  MatchedIndexes: TList; CaseSensitive: Boolean): Boolean;
var
  S: string;
begin
  // 默认根据匹配模式匹配 DataList 的第 I 个字符串，
  Result := True;
  if AMatchStr = '' then
    Exit;

  S := DataList[DataListIndex];
  StartOffset := 0;

  if CaseSensitive then
  begin
    case AMatchMode of
      mmStart:    Result := Pos(AMatchStr, S) = 1;
      mmAnywhere: Result := Pos(AMatchStr, S) > 0;
      mmFuzzy:    Result := FuzzyMatchStr(AMatchStr, S, MatchedIndexes);
    end
  end
  else
  begin
    case AMatchMode of
      mmStart:    Result := Pos(UpperCase(AMatchStr), UpperCase(S)) = 1;
      mmAnywhere: Result := Pos(UpperCase(AMatchStr), UpperCase(S)) > 0;
      mmFuzzy:    Result := FuzzyMatchStr(AMatchStr, S, MatchedIndexes);
    end
  end;
end;

function TCnProjectViewBaseForm.DefaultSelectHandler(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer): Boolean;
begin
  // 默认以头匹配的优先级最高最优先选中
  Result := Pos(AMatchStr, DataList[DataListIndex]) = 1;
end;

function TCnProjectViewBaseForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr: string; const S1, S2: string;
  Obj1, Obj2: TObject; SortDown: Boolean): Integer;
begin
  Result := CompareTextWithPos(AMatchStr, S1, S2, SortDown);
end;

procedure TCnProjectViewBaseForm.PrepareSearchRange;
{$IFNDEF STAND_ALONE}
var
  I: Integer;
  AProjectInfo: TCnProjectInfo;
{$ENDIF}
begin
  ProjectInfoSearch := nil;
  FProjectListSelectedAllProject := False;

{$IFNDEF STAND_ALONE}
  if not cbbProjectList.Visible or (cbbProjectList.ItemIndex <= 0) then  // nil means All Project
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('PrepareSearchRange, Search All Projects');
{$ENDIF}
    FProjectListSelectedAllProject := True;
    Exit;
  end
  else if cbbProjectList.ItemIndex = 1 then // 1 means Current Project
  begin
    for I := 0 to ProjectList.Count - 1 do
    begin
      AProjectInfo := TCnProjectInfo(ProjectList[I]);
      if _CnChangeFileExt(AProjectInfo.FileName, '') = CnOtaGetCurrentProjectFileNameEx then
      begin
        ProjectInfoSearch := AProjectInfo;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('PrepareSearchRange, Search Current Project: ' + ProjectInfoSearch.FileName);
{$ENDIF}
        Exit;
      end;
    end;
  end
  else  // Specified Project
  begin
    for I := 0 to ProjectList.Count - 1 do
    begin
      AProjectInfo := TCnProjectInfo(ProjectList[I]);
      if cbbProjectList.Items.Objects[cbbProjectList.ItemIndex] <> nil then
      begin
        if TCnProjectInfo(cbbProjectList.Items.Objects[cbbProjectList.ItemIndex]).FileName
          = AProjectInfo.FileName then
        begin
          ProjectInfoSearch := AProjectInfo;
{$IFDEF DEBUG}
          CnDebugger.LogMsg('PrepareSearchRange, Search Project: ' + ProjectInfoSearch.FileName);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnProjectViewBaseForm.DoUpdateListView;
begin
  // Do Nothing in Base Class, to remove after refactoring.
end;

procedure TCnProjectViewBaseForm.ClearDataList;
var
  I: Integer;
begin
  if FOutDataListRef = nil then // 有外部的 List 存在时则不能释放 Object
  begin
    for I := 0 to DataList.Count - 1 do
      DataList.Objects[I].Free;
  end;
  DataList.Clear;
end;

procedure TCnProjectViewBaseForm.ChangeColumnArrow;
var
  Header: HWND;
  Item: THDItem;
begin
  if (FSortIndex >= 0) and (FSortIndex < lvList.Columns.Count) then
  begin
    Header := ListView_GetHeader(lvList.Handle);
    ZeroMemory(@Item, SizeOf(Item));
    Item.Mask := HDI_FORMAT or HDI_BITMAP;

    Header_GetItem(Header, FSortIndex, Item);

{$IFDEF BDS2007_UP}  // D2007 CommCtrl 才支持 SORTUP/DOWN 标记
    Item.fmt := Item.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
    if FSortDown then
      Item.fmt := Item.fmt or HDF_SORTUP
    else
      Item.fmt := Item.fmt or HDF_SORTDOWN;
{$ELSE}
    Item.fmt := Item.fmt or HDF_BITMAP_ON_RIGHT or HDF_BITMAP;
    if FSortDown then
      Item.hbm := FUpArrow.Handle
    else
      Item.hbm := FDownArrow.Handle;
{$ENDIF}

    Header_SetItem(Header, FSortIndex, Item);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('ChangeColumnArrow for Column ' + IntToStr(FSortIndex));
{$ENDIF}
  end;
end;

procedure TCnProjectViewBaseForm.ClearColumnArrow;
var
  Header: HWND;
  Item: THDItem;
begin
  if (FSortIndex >= 0) and (FSortIndex < lvList.Columns.Count) then
  begin
    Header := ListView_GetHeader(lvList.Handle);
    ZeroMemory(@Item, SizeOf(Item));
    Item.Mask := HDI_FORMAT or HDI_BITMAP;

    Header_GetItem(Header, FSortIndex, Item);
    Item.fmt := Item.fmt and not (HDF_SORTUP or HDF_SORTDOWN);

{$IFNDEF BDS2007_UP} // D2007 CommCtrl 才支持 SORTUP/DOWN 标记
    Item.fmt := Item.fmt or HDF_BITMAP_ON_RIGHT or HDF_BITMAP;
    Item.hbm := FNoArrow.Handle;
{$ENDIF}

    Header_SetItem(Header, FSortIndex, Item);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ClearColumnArrow for Column ' + IntToStr(FSortIndex));
{$ENDIF}
  end;
end;

procedure TCnProjectViewBaseForm.InitArrowBitmaps;

  procedure MakeBitmap(Bmp: TBitmap; Idx: Integer);
  begin
    Bmp.Width := dmCnSharedImages.ilColumnHeader.Width;
    Bmp.Height := dmCnSharedImages.ilColumnHeader.Height;
    with Bmp.Canvas do
    begin
      Brush.COlor := clBtnface;
      Brush.Style := bsSolid;
      FillRect(ClipRect);
    end;
    dmCnSharedImages.ilColumnHeader.Draw(Bmp.Canvas, 0, 0, Idx);
  end;

begin
  MakeBitmap(FUpArrow, 0);
  MakeBitmap(FDownArrow, 1);
  MakeBitmap(FNoArrow, 2);
end;

procedure TCnProjectViewBaseForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  R, SR: TRect;
  Bmp: TBitmap;
  LV: TListView;
  I, X, Y, AStartOffset: Integer;
  S: string;
  Info: TCnBaseElementInfo;
  MatchedIndexesRef: TList;
begin
  DefaultDraw := False;
  LV := ListView as TListView;

  // 根据匹配结果统一绘制图标与 Caption，选择区使用灰底，未选择区使用白底
  R := Item.DisplayRect(drSelectBounds);
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.Width := R.Right - R.Left;
    Bmp.Height := R.Bottom - R.Top;

    Bmp.Canvas.Font.Assign(LV.Font);
    Bmp.Canvas.Brush.Style := bsSolid;

    if Item.Selected then
      Bmp.Canvas.Brush.Color := $E0E0E0
    else
      Bmp.Canvas.Brush.Color := clWindow;

    // 给子类一个机会重定义 Font 的颜色与 Canvas 背景
    DrawListPreParam(Item, Bmp.Canvas);

    // 填充底色
    Bmp.Canvas.FillRect(Bounds(1, (Bmp.Height - LV.Height) div 2,
      Bmp.Width, LV.Height));

    if (Item.ImageIndex >= 0) and (LV.SmallImages <> nil) then
    begin
{$IFDEF IDE_SUPPORT_HDPI}
  {$IFDEF STAND_ALONE}
      // TODO: 拉伸绘制
      LV.SmallImages.Draw(Bmp.Canvas, csDrawIconMargin,
        (Bmp.Height - LV.SmallImages.Height) div 2, Item.ImageIndex);
  {$ELSE}
      // TODO: 拉伸绘制
      LV.SmallImages.Draw(Bmp.Canvas, IdeGetScaledPixelsFromOrigin(csDrawIconMargin, LV),
        (Bmp.Height - LV.SmallImages.Height) div 2, Item.ImageIndex);
  {$ENDIF}
{$ELSE}
      // 图标在竖直方向上在 Bmp 中居中
      LV.SmallImages.Draw(Bmp.Canvas, csDrawIconMargin, (Bmp.Height - LV.SmallImages.Height) div 2, Item.ImageIndex);
{$ENDIF}
    end;

{$IFDEF STAND_ALONE}
    if LV.SmallImages <> nil then
      X := LV.SmallImages.Width + 2
    else
      X := Bmp.Height + 2;
{$ELSE}
    if LV.SmallImages <> nil then
      X := IdeGetScaledPixelsFromOrigin(LV.SmallImages.Width, LV) + 2
    else
      X := Bmp.Height + 2;
{$ENDIF}

    Y := (Bmp.Height - Bmp.Canvas.TextHeight(Item.Caption)) div 2;

    AStartOffset := 0;
    MatchedIndexesRef := nil;
    if (Item.Data <> nil) and (TObject(Item.Data) is TCnBaseElementInfo) then
    begin
      Info := TCnBaseElementInfo(Item.Data);
      AStartOffset := Info.StartOffset;
      if (Info.MatchIndexes <> nil) and (Info.MatchIndexes.Count > 0) then
        MatchedIndexesRef := Info.MatchIndexes;
    end;

    // 绘制匹配文字
    if MatchMode in [mmStart, mmAnywhere] then
    begin
      if AStartOffset > 1 then
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed, nil, AStartOffset)
      else
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed);
    end
    else if MatchedIndexesRef <> nil then
      DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed, MatchedIndexesRef)
    else
      Bmp.Canvas.TextOut(X, Y, Item.Caption);

    // 绘制 SubItem 其它列
    for I := 0 to Item.SubItems.Count - 1 do
    begin
      S := Item.SubItems[I];
      if S <> '' then
      begin
        ListView_GetSubItemRect(LV.Handle, Item.Index, I + 1, LVIR_BOUNDS, @SR);
        Bmp.Canvas.TextOut(SR.Left + 2, Y, S);
      end;
    end;

    BitBlt(LV.Canvas.Handle, R.Left, R.Top, Bmp.Width, Bmp.Height,
      Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    Bmp.Free;
  end;
end;

procedure TCnProjectViewBaseForm.DrawListPreParam(Item: TListItem;
  ListCanvas: TCanvas);
begin
  // 基类啥都不改，按默认绘制
end;

function TCnProjectViewBaseForm.DisableLargeIcons: Boolean;
begin
  Result := False;
end;

function TCnProjectViewBaseForm.DoSelectOpenedItem: string;
begin
  Result := '';
end;

{$IFNDEF STAND_ALONE}

procedure TCnProjectViewBaseForm.ChangeIconToIDEImageList;
var
  I: Integer;
  Act: TCustomAction;
begin
  if WizOptions.UseLargeIcon and not DisableLargeIcons then
  begin
    ToolBar.ButtonWidth := csLargeButtonWidth;
    ToolBar.ButtonHeight := csLargeButtonHeight;
    ActionList.Images := dmCnSharedImages.GetMixedImageList;
    ToolBar.Images := dmCnSharedImages.GetMixedImageList;
  end
  else  // 强制小图标
  begin
    ActionList.Images := dmCnSharedImages.GetMixedImageList(True);
    ToolBar.Images := dmCnSharedImages.GetMixedImageList(True);
  end;

  for I := 0 to ActionList.ActionCount - 1 do
  begin
    if ActionList.Actions[I] is TCustomAction then
    begin
      Act := ActionList.Actions[I] as TCustomAction;
      Act.ImageIndex := dmCnSharedImages.CalcMixedImageIndex(Act.ImageIndex);
    end;
  end;
  for I := 0 to ToolBar.ButtonCount - 1 do
  begin
    if not (ToolBar.Buttons[I].Style in [tbsSeparator, tbsDivider]) and
      (ToolBar.Buttons[I].Action = nil) then
      ToolBar.Buttons[I].ImageIndex := dmCnSharedImages.CalcMixedImageIndex(ToolBar.Buttons[I].ImageIndex);
  end;
end;

{$ENDIF}

constructor TCnProjectViewBaseForm.Create(AOwner: TComponent;
  ADataList: TStringList);
begin
  FOutDataListRef := ADataList;
  inherited Create(AOwner);
end;

procedure TCnProjectViewBaseForm.AfterConstruction;
begin
  inherited; // 这里 DataList 才会 Create
  if FOutDataListRef <> nil then
    DataList.Assign(FOutDataListRef);
end;

procedure TCnProjectViewBaseForm.DoOpenSelect;
begin
  OpenSelect;
end;

{ TCnBaseElementInfo }

constructor TCnBaseElementInfo.Create;
begin
  FMatchIndexes := TList.Create;
end;

destructor TCnBaseElementInfo.Destroy;
begin
  FMatchIndexes.Free;
  inherited;
end;

end.

