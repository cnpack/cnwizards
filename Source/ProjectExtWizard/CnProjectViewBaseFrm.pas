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

unit CnProjectViewBaseFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�������չ���ߴ����б�Ԫ�б����
* ��Ԫ���ߣ�Leeon (real-like@163.com); ��ΰ��Alan�� BeyondStudio@163.com
* ��    ע������������п�ʱ�����ָ߰汾�� Delphi �� HDPI �»�����п�������
*           ������˸� WindowProc �� Hook ���� ListView ���п�ı���Ϣ�ű��棬
*           �� D12 �������Ϣ���ز�������� D12 ��ֻ�ܽ��ܿ����е��п���
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin2000 + Delphi 5/6/7
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2019.12.10 V1.2
*               ֧�� STAND_ALONE ��������ģʽ
*           2004.02.22 V1.1
*               ��д���д���
*           2004.02.08 V1.0
*               ������Ԫ
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
{$IFNDEF STAND_ALONE} {$IFNDEF NO_DELPHI_OTA} ToolsAPI, {$ENDIF}
  CnWizUtils, CnWizIdeUtils, CnWizNotifier, CnIDEVersion, {$ENDIF}
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnIni, CnWizMultiLang,
  CnWizShareImages, CnIniStrUtils, AsRegExpr, CnStrings;

type

//==============================================================================
// ������Ϣ��
//==============================================================================

{ TCnProjectInfo }

  TCnProjectInfo = class
    Name: string;
    FileName: string;
  end;

//==============================================================================
// �б���Ϣ����
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
    {* ƥ�����ʼλ�ã�Ĭ��Ϊ 0}
    property FuzzyScore: Integer read FFuzzyScore write FFuzzyScore;
    {* ģ��ƥ���ƥ��ȣ���δʹ��}
    property MatchIndexes: TList read FMatchIndexes;
    {* ģ��ƥ�� Text ���±�}
    property ParentProject: TCnProjectInfo read FParentProject write FParentProject;
    {* ��Ԫ�ش����� Project������Ϊ nil}
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    {* ��ʾʱ������ ImageIndex ͼ����ţ����������Ҫ���������������}
  published
    property Text: string read FText write FText;
    {* Text ��ʾ��һ����ʾ������}
  end;

  TCnDrawMatchTextEvent = procedure (Canvas: TCanvas; const MatchStr, Text: string;
    X, Y: Integer; HighlightColor: TColor) of object;

//==============================================================================
// �����鵥Ԫ�����б���ര��
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
    FOutDataListRef: TStringList; // �ⲿ DataList ��ʱ�洢�ĵط�
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
    FMatchAnyWhereSepList: TStringList;
    NeedInitProjectControls: Boolean;
    FProjectListSelectedAllProject: Boolean;
    ProjectList: TObjectList;     // �洢 ProjectInfo ���б�
    ProjectInfoSearch: TCnProjectInfo;  // ��Ǵ��޶��� Project ������Χ
    DataList: TStringList;        // ������洢ԭʼ��Ҫ�������б������Լ� Object
    DisplayList: TStringList;     // ���������ɹ��˺���Ҫ��ʾ���б������Լ� Object�����ã�
    function DisableLargeIcons: Boolean; virtual; // ��������������Ϊ����ԭ����ô�ͼ�꣬Ĭ�ϸ���������
    function DoSelectOpenedItem: string; virtual;
    procedure DoSelectItemChanged(Sender: TObject); virtual;
    procedure DoUpdateListView; virtual;

    // === New Routines for refactor ===
    // ��ǰ׼�����ò���
    procedure PrepareSearchRange; virtual;

    // ʵ�ָ���ƥ������ DataList ������ DisplayList�Ĺ��ܣ�һ����������
    procedure CommonUpdateListView; virtual;

    // ���������Է�����ָ��ƥ���ַ���ָ��ƥ��ģʽ�£�DataList �е�ָ�����Ƿ�ƥ��
    // ���ô˷���ǰ ProjectInfo ָ��������������ʶ�Ĺ��̷�Χ
    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; virtual;

    // ���������Է��ش����Ƿ������Ϊ����ѡ�е��һ����������
    function CanSelectDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer): Boolean; virtual;

    // ����Ƚ���������������ʵ�ָ��� Object �ȽϵĹ���
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; virtual;

    // Ĭ��ƥ���ʵ�֣�ֻƥ�� DataList �е��ַ������������� Object �����������
    function DefaultMatchHandler(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList;
      CaseSensitive: Boolean = False): Boolean;

    // Ĭ����������ѡ����ͷ��ƥ�����
    function DefaultSelectHandler(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer): Boolean;

    // �ͷ� DataList �����³�ʼ���ĳ���
    procedure ClearDataList;

    // ������������� Item ʱ�����޸Ĳ��ֻ��Ʋ�������ɫ��
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); virtual;
    // === New Routines for refactor ===

    procedure DoSortListView; virtual;
    {* �����������ã��� UpdateListView ����}
    function GetSelectedFileName: string; virtual; abstract;
    procedure CreateList; virtual;
    {* ���� OnCreate ʱ����һ�����ã�������ʼ�����ݣ�һ������ݼ��ؽ� DataList �У�
       �������������̫�࣬Ҳ���� UpdateListView ʱ�� }
    procedure UpdateComboBox; virtual;
    {* ���� OnCreate ʱ���ڶ������ã�������ʼ�� ComboBox �е�����}
    procedure UpdateListView; virtual;
    {* ���� OnCreate ʱ�����������ã��������� ListView �е����ݣ�ͬʱ����������Ӧ����ĵط�����}
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
    destructor Destroy; override;

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
// �����鵥Ԫ�����б���ര��
//==============================================================================

{ TCnProjectViewBaseForm }

procedure TCnProjectViewBaseForm.ListViewWindowProc(var Message: TMessage);
var
  NM: TWMNotify;
begin
  FOldListViewWndProc(Message);
  if Message.Msg = WM_NOTIFY then
  begin
    // ע�⣬�ƺ��� D12 �½��������ղ����п�ı��֪ͨ
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
  I: Integer;
  AList: TStringList;
begin
  AList := TStringList.Create;
  try
    with lvList do
    begin
      for I := 0 to Pred(Items.Count) do
        if Items.Item[I].Selected and (Items.Item[I].Caption <> '') then
          AList.Add(Items[I].Caption);
    end;
  finally
    if AList.Count > 0 then
      Clipboard.AsText := TrimRight(AList.Text);
    FreeAndNil(AList);
  end;
end;

procedure TCnProjectViewBaseForm.actSelectAllExecute(Sender: TObject);
var
  I: Integer;
begin
  with lvList do
    for I := 0 to Pred(Items.Count) do
      Items[I].Selected := True;
end;

procedure TCnProjectViewBaseForm.actSelectNoneExecute(Sender: TObject);
begin
  lvList.Selected := nil;
end;

procedure TCnProjectViewBaseForm.actSelectInvertExecute(Sender: TObject);
var
  I: Integer;
begin
  with lvList do
    for I := Pred(Items.Count) downto 0 do
      Items[I].Selected := not Items[I].Selected;
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
      // ֻ�б�������岻���ڴ��������ʱ��Ҳ���û����ù�����󣬲�����
      lvList.ParentFont := False;
      lvList.Font := ReadFont(aSection, csFont, lvList.Font);
      dlgFont.Font := lvList.Font;
      FontChanged(dlgFont.Font);
    end;

    FSortIndex := ReadInteger(aSection, csSortIndex, 0);
    FSortDown := ReadBool(aSection, csSortDown, False);
    lvList.CustomSort(nil, 0); // ���������������
    ChangeColumnArrow;

    TW := ReadInteger(aSection, csWidth, 0);
    TH := ReadInteger(aSection, csHeight, 0);
{$IFDEF IDE_SUPPORT_HDPI}
    TW := Round(TW * IdeGetScaledFactor(Self));
    TH := Round(TH * IdeGetScaledFactor(Self));
{$ENDIF}
    if TW > Screen.Width - 150 then   // ���Ʋ��ܱ���Ļ��
      TW := Screen.Width - 150;
    if TH > Screen.Height - 120 then
      TH := Screen.Height - 120;

    if TW > MIN_WH then Width := TW;
    if TH > MIN_WH then Height := TH;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnProjectViewBaseForm.LoadSettings Load Width %d Height %d after Scale', [Width, Height]);
{$ENDIF}

{$IFNDEF STAND_ALONE}
    CenterForm(Self);
    if FListViewWidthOldStr = '' then // �����ɿ�ȹ��ж��Ƿ�ı��
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
      if lvList.Columns[I].Width > Screen.Width then // ����п�������Ļ��ȣ�˵����������
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

    // ���û�û���ù����壬ParentFont ��Ϊ True��������������л��ܻ����仯
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

{$IFNDEF NO_DELPHI_OTA}
    if CnIsGEDelphi11Dot3 then
    begin
      S := GetListViewWidthString2(lvList, GetFactorFromSizeEnlarge(Enlarge)); // ��ȡ��ȷ�Ŀ��ֵ
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnProjectViewBaseForm.SaveSettings To Write ListView Width2 %s', [S]);
{$ENDIF}
      if {$IFNDEF DELPHI120_ATHENS_UP} FColumnWidthManuallyChanged and {$ENDIF}
        (S <> FListViewWidthOldStr) then // �п�� Bug ���ڵ�����£�ֻ�ֹ����Ĺ��ұ仯�˲ű���
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
        if S <> FListViewWidthOldStr then // ֻ�仯�ˣ��ҿ�Ⱥ��ʣ��ű���
          WriteString(aSection, csListViewWidth, S);
      end
      else // ��Ȳ����ʣ�������ûָ�ԭʼ���
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
  I: Integer;
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

    for I := 0 to Pred(Items.Count) do
    begin
      if AnsiSameText(Items[I].Caption, aCurrentName) then
      begin
        Selected := nil;
        Items[I].Selected := True;
        ItemFocused := Selected;
        Selected.MakeVisible(False);
        Break;
      end;
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
      // ѡ��ȫ��
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
      // ȡ��ѡ��
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
      // �����ı�
      // ��Ϊ�������ܣ������������֣��պ��ʵ�ֿ�ѡ��
      else if Key = Ord('C') then
      begin
        if edtMatchSearch.Focused and (edtMatchSearch.SelText <> '') then
          Exit; // ��ѡ��ʱ�����ж���ĸ���

        if lvList.Selected <> nil then
        begin
          CopyBuf := '';

          // ��������
          for I := 0 to lvList.Columns.Count - 1 do
          begin
            CopyBuf := CopyBuf + lvList.Column[I].Caption;
            if I < lvList.Columns.Count - 1 then
              CopyBuf := CopyBuf + CNCOPY_SPLITER;
          end;
          CopyBuf := CopyBuf + CNCOPY_LINE;

          // ��������
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

          // ���������
          Clipboard.Clear;
          Clipboard.SetTextBuf(PChar(CopyBuf));
        end
        else
        begin
          // �������������ʾû��ѡ����Ҫ���Ƶ�����
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
  // Toolbar �İ�ť�ڶ�Ӧ Action �����ص�����¿��ܻ���ֻ��ң���Ҫ�����ְ취�޸�һ��
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
      if (AMatchMode in [mmAnywhere, mmFuzzy]) and (DataList.Objects[I] <> nil) and
        ObjectIsBaseElementInfo(DataList.Objects[I]) then
      begin
        TCnBaseElementInfo(DataList.Objects[I]).FuzzyScore := 0;
        Indexes := TCnBaseElementInfo(DataList.Objects[I]).MatchIndexes;
        if Indexes <> nil then
          Indexes.Clear;
      end;
      AStartOffset := 0;

      // ������Ϊ MatchSearchText = '' ��ֱ��ͨ��ƥ�䣬��Ϊ������ܻ���������������
      if CanMatchDataByIndex(MatchSearchText, AMatchMode, I, AStartOffset, Indexes) then
      begin
        // DataList.Objects �п���Ϊ nil
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

    // ������Ҫѡ�е���ƥ�������ѡ�У�����ѡ 0����һ��
    if (ToSels.Count > 0) and (DisplayList.Count > 0) then
    begin
      for I := 0 to DisplayList.Count - 1 do
      begin
        if ToSels.IndexOf(DisplayList[I]) >= 0 then
        begin
          // DisplayList �еĵ�һ���� ToSelCompInfos ��ͷ����
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
  // Ĭ�ϸ���ƥ��ģʽƥ�� DataList �ĵ� I ���ַ�����
  Result := True;
  if AMatchStr = '' then
    Exit;

  S := DataList[DataListIndex];
  StartOffset := 0;

  if CaseSensitive then
  begin
    case AMatchMode of
      mmStart:
        begin
          Result := Pos(AMatchStr, S) = 1;
        end;
      mmAnywhere:
        begin
          if FMatchAnyWhereSepList = nil then
            FMatchAnyWhereSepList := TStringList.Create;
          Result := AnyWhereSepMatchStr(AMatchStr, S, FMatchAnyWhereSepList, MatchedIndexes, True);
        end;
      mmFuzzy:
        begin
          Result := FuzzyMatchStr(AMatchStr, S, MatchedIndexes);
        end;
    end
  end
  else
  begin
    case AMatchMode of
      mmStart:
        begin
          Result := Pos(UpperCase(AMatchStr), UpperCase(S)) = 1;
        end;
      mmAnywhere:
        begin
          if FMatchAnyWhereSepList = nil then
            FMatchAnyWhereSepList := TStringList.Create;
          Result := AnyWhereSepMatchStr(AMatchStr, S, FMatchAnyWhereSepList, MatchedIndexes, False);
        end;
      mmFuzzy:
        begin
          Result := FuzzyMatchStr(AMatchStr, S, MatchedIndexes);
        end;
    end
  end;
end;

function TCnProjectViewBaseForm.DefaultSelectHandler(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer): Boolean;
begin
  // Ĭ����ͷƥ������ȼ����������ѡ��
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
  if FOutDataListRef = nil then // ���ⲿ�� List ����ʱ�����ͷ� Object
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

{$IFDEF BDS2007_UP}  // D2007 CommCtrl ��֧�� SORTUP/DOWN ���
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

{$IFNDEF BDS2007_UP} // D2007 CommCtrl ��֧�� SORTUP/DOWN ���
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

  // ����ƥ����ͳһ����ͼ���� Caption��ѡ����ʹ�ûҵף�δѡ����ʹ�ð׵�
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

    // ������һ�������ض��� Font ����ɫ�� Canvas ����
    DrawListPreParam(Item, Bmp.Canvas);

    // ����ɫ
    Bmp.Canvas.FillRect(Bounds(1, (Bmp.Height - LV.Height) div 2,
      Bmp.Width, LV.Height));

    if (Item.ImageIndex >= 0) and (LV.SmallImages <> nil) then
    begin
{$IFDEF IDE_SUPPORT_HDPI}
  {$IFDEF STAND_ALONE}
      // TODO: �������
      LV.SmallImages.Draw(Bmp.Canvas, csDrawIconMargin,
        (Bmp.Height - LV.SmallImages.Height) div 2, Item.ImageIndex);
  {$ELSE}
      // TODO: �������
      LV.SmallImages.Draw(Bmp.Canvas, IdeGetScaledPixelsFromOrigin(csDrawIconMargin, LV),
        (Bmp.Height - LV.SmallImages.Height) div 2, Item.ImageIndex);
  {$ENDIF}
{$ELSE}
      // ͼ������ֱ�������� Bmp �о���
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

    // ����ƥ������
    if MatchMode = mmStart then
    begin
      if AStartOffset > 1 then
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed, nil, AStartOffset)
      else
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed);
    end
    else if (MatchMode = mmAnywhere) and ((MatchedIndexesRef = nil) or (MatchedIndexesRef.Count = 0)) then
    begin
      if AStartOffset > 1 then
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed, nil, AStartOffset)
      else
        DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed);
    end
    else if MatchedIndexesRef <> nil then
    begin
      DrawMatchText(Bmp.Canvas, edtMatchSearch.Text, Item.Caption, X, Y, clRed, MatchedIndexesRef);
    end
    else
      Bmp.Canvas.TextOut(X, Y, Item.Caption);

    // ���� SubItem ������
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
  // ����ɶ�����ģ���Ĭ�ϻ���
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
  else  // ǿ��Сͼ��
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
  inherited; // ���� DataList �Ż� Create
  if FOutDataListRef <> nil then
    DataList.Assign(FOutDataListRef);
end;

procedure TCnProjectViewBaseForm.DoOpenSelect;
begin
  OpenSelect;
end;

destructor TCnProjectViewBaseForm.Destroy;
begin
  FMatchAnyWhereSepList.Free;
  inherited;
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

