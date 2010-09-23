{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2, a lot of function added.   }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnProcListWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：函数过程列表专家单元
* 单元作者：刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：该单元部分内容移植自 GExperts 的相应单元
*           其原始内容受 GExperts License 的保护
*           ——有待增加设置窗口控制其设置
* 开发平台：PWin2000 + Delphi 5
* 兼容测试：暂无（PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.04.16 V1.2
*               增加工具栏的下拉查找功能
*           2005.10.29 V1.1
*               增加多个单元的选择功能，目前排序还有点问题
*           2005.03.12 V1.0
*               创建单元，实现部分移植功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, StdCtrls, ExtCtrls, IniFiles, ToolsAPI, Math, Menus, ActnList,
  CnProjectViewBaseFrm, CnWizClasses, CnWizManager, CnIni, CnWizEditFiler, mPasLex,
  mwBCBTokenList, Contnrs, Clipbrd, CnEditControlWrapper, CnPasCodeParser,
  CnPopupMenu, CnWizIdeUtils, CnCppCodeParser, CnEdit, RegExpr;

type
  TCnSourceLanguageType = (ltUnknown, ltPas, ltCpp);

  TCnElementType = (etUnknown, etClassFunc, etSingleFunction, etConstructor, etDestructor,
    etIntfMember, etRecord, etClass, etInterface, etProperty, etIntfProperty, etNamespace);

  TCnElementInfo = class(TObject)
  {* 一元素包含的信息，从过程扩展而来 }
  private
    FElementType: TCnElementType;
    FLineNo: Integer;
    FElementTypeStr: string;
    FProcName: string;
    FProcReturnType: string;
    FName: string;
    FProcArgs: string;
    FOwnerClass: string;
    FDisplayName: string;
    FAllName: string;
    FFileName: string;
    FBeginIndex: Integer;
    FEndIndex: Integer;
    FIsForward: Boolean;
  public
    property DisplayName: string read FDisplayName write FDisplayName;
    property LineNo: Integer read FLineNo write FLineNo;
    property Name: string read FName write FName;
    property ElementTypeStr: string read FElementTypeStr write FElementTypeStr;
    property ProcArgs: string read FProcArgs write FProcArgs;
    property ProcName: string read FProcName write FProcName;
    property OwnerClass: string read FOwnerClass write FOwnerClass;
    property ProcReturnType: string read FProcReturnType write FProcReturnType;
    property FileName: string read FFileName write FFileName;
    property AllName: string read FAllName write FAllName;
    property BeginIndex: Integer read FBeginIndex write FBeginIndex;
    property EndIndex: Integer read FEndIndex write FEndIndex;
    property IsForward: Boolean read FIsForward write FIsForward;
    property ElementType: TCnElementType read FElementType write FElementType;
  end;

  TCnProcListWizard = class;

  TCnProcListForm = class(TCnProjectViewBaseForm)
    mmoContent: TMemo;
    Splitter: TSplitter;
    btnShowPreview: TToolButton;
    btnSep9: TToolButton;
    cbbMatchSearch: TComboBox;
    lblFiles: TLabel;
    cbbFiles: TComboBox;
    procedure FormDestroy(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure btnShowPreviewClick(Sender: TObject);
    procedure lvListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure cbbMatchSearchChange(Sender: TObject);
    procedure cbbMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cbbFilesDropDown(Sender: TObject);
    procedure cbbFilesChange(Sender: TObject);
    procedure lvListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvListKeyPress(Sender: TObject; var Key: Char);
    procedure SplitterMoved(Sender: TObject);
  private
    { Private declarations }

    FFileName: string;
    FFiler: TCnEditFiler;
    FFilesGot: Boolean;
    FCurrentFile: string;
    FSelIsCurFile: Boolean;
    FSelInfo: TCnElementInfo;
    FWizard: TCnProcListWizard;
    FPreviewHeight: Integer;
    procedure SetFileName(const Value: string);

    procedure ClearObjectStrings;
    procedure LoadObjectCombobox;
    procedure InitFileComboBox;
    procedure LoadFileComboBox;
    function SelectImageIndex(ProcInfo: TCnElementInfo): Integer;
    function GetMethodName(const ProcName: string): string;
    procedure SortDisplayList;
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function DoSelectOpenedItem: string; override;
    procedure DoUpdateListView; override;
    function GetSelectedFileName: string; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateStatusBar; override;
    procedure UpdateComboBox; override;
    procedure UpdateListView; override;
    procedure UpdateItemPosition;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;
    procedure FontChanged(AFont: TFont); override;
  public
    { Public declarations }
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string); override;
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string); override;
    procedure UpdateMemoHeight(Sender: TObject);
    property FileName: string read FFileName write SetFileName;
    //property Language: TCnSourceLanguageType read FLanguage write FLanguage;
    //property IsCurrentFile: Boolean read FIsCurrentFile write SetIsCurrentFile;
    {* 是否是只显示当前文件 }
    property CurrentFile: string read FCurrentFile write FCurrentFile;
    {* 只显示当前文件时，当前的文件名 }
    property SelIsCurFile: Boolean read FSelIsCurFile write FSelIsCurFile;
    {* 选中的条目的文件名 }

    property PreviewHeight: Integer read FPreviewHeight;
    {* 预览窗口的高度}
    property Wizard: TCnProcListWizard read FWizard write FWizard;
  end;

  TCnItemHintEvent = procedure (Sender: TObject; Index: Integer;
    var HintStr: string) of object;

  // 工具栏中的下拉列表框的下拉列表
  TCnProcDropDownBox = class(TCustomListBox)
  private
    FRegExpr: TRegExpr;
    FLastItem: Integer;
    FOnItemHint: TCnItemHintEvent;
    FDisplayItems: TStrings;
    FMatchStr: string;
    FMatchStart: Boolean;
    FInfoItems: TStrings;
    FDisableClickFlag: Boolean;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CNCancelMode(var Message: TMessage); message CM_CANCELMODE;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    function AdjustHeight(AHeight: Integer): Integer;
    procedure ListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SetMatchStart(const Value: Boolean);
    procedure SetMatchStr(const Value: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure UpdateDisplay;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCount(const Value: Integer);
    procedure SetPos(X, Y: Integer);
    procedure CloseUp;
    procedure Popup;
    procedure SavePosition;

    property OnItemHint: TCnItemHintEvent read FOnItemHint write FOnItemHint;
    property DisplayItems: TStrings read FDisplayItems;
    property InfoItems: TStrings read FInfoItems;
    property MatchStr: string read FMatchStr write SetMatchStr;
    property MatchStart: Boolean read FMatchStart write SetMatchStart;
  end;

//==============================================================================
// 工具栏中的下拉框组件
//==============================================================================

  TCnProcListComboBox = class(TCnEdit)
  private
    FChangeDown: Boolean; // 是否由于文字改变导致的下拉
    FDisableChange: Boolean;
    FOnKillFocus: TNotifyEvent;
    FDropDownList: TCnProcDropDownBox;
    procedure RefreshDropBox(Sender: TObject);
    procedure DropDownListDblClick(Sender: TObject);
    procedure DropDownListClick(Sender: TObject);
    procedure UpdateDropPosition;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure Change; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ShowDropBox;
    procedure SetTextWithoutChange(const AText: string);

    property DropDownList: TCnProcDropDownBox read FDropDownList;
    property OnKillFocus: TNotifyEvent read FOnKillFocus write FOnKillFocus;
    property ChangeDown: Boolean read FChangeDown write FChangeDown;
  end;

  TCnProcToolButton = class(TToolButton);

  TCnProcToolBarObj = class(TObject)
  private
    // 工具栏上的工具按钮和弹出菜单，都采用手工方式创建
    FInternalToolBar1: TToolBar;
    FInternalToolBar2: TToolBar;
    FToolBtnProcList: TCnProcToolButton;
    FToolBtnListUsed: TCnProcToolButton;
    FToolBtnSep1: TCnProcToolButton;
    FToolBtnJumpIntf: TCnProcToolButton;
    FToolBtnJumpImpl: TCnProcToolButton;
    FClassCombo: TCnProcListComboBox;
    FProcCombo: TCnProcListComboBox;
    FToolBtnMatchStart: TCnProcToolButton;
    FToolBtnMatchAny: TCnProcToolButton;
    FPopupMenu: TPopupMenu;
    FEditControl: TControl;
    FEditorToolBar: TControl;
    FSplitter1: TSplitter;
    FSplitter2: TSplitter;
  public
    property EditControl: TControl read FEditControl write FEditControl;
    property EditorToolBar: TControl read FEditorToolBar write FEditorToolBar;

    property InternalToolBar1: TToolBar read FInternalToolBar1 write FInternalToolBar1;
    property InternalToolBar2: TToolBar read FInternalToolBar2 write FInternalToolBar2;
    property ToolBtnProcList: TCnProcToolButton read FToolBtnProcList write FToolBtnProcList;
    property ToolBtnListUsed: TCnProcToolButton read FToolBtnListUsed write FToolBtnListUsed;
    property ToolBtnSep1: TCnProcToolButton read FToolBtnSep1 write FToolBtnSep1;
    property ToolBtnJumpIntf: TCnProcToolButton read FToolBtnJumpIntf write FToolBtnJumpIntf;
    property ToolBtnJumpImpl: TCnProcToolButton read FToolBtnJumpImpl write FToolBtnJumpImpl;
    property ClassCombo: TCnProcListComboBox read FClassCombo write FClassCombo;
    property Splitter1: TSplitter read FSplitter1 write FSplitter1;
    property Splitter2: TSplitter read FSplitter2 write FSplitter2;
    property ProcCombo: TCnProcListComboBox read FProcCombo write FProcCombo;
    property ToolBtnMatchStart: TCnProcToolButton read FToolBtnMatchStart write FToolBtnMatchStart;
    property ToolBtnMatchAny: TCnProcToolButton read FToolBtnMatchAny write FToolBtnMatchAny;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
  end;

  TCnProcListWizard = class(TCnMenuWizard)
  private
    FEditorToolBarType: string;
    FUseEditorToolBar: Boolean;
    FToolBarTimer: TTimer;
    FNeedReParse: Boolean;
    FCurrPasParser: TCnPasStructureParser;
    FCurrCppParser: TCnCppStructureParser;
    FCurrStream: TMemoryStream;
    FProcToolBarObjects: TList;
    FComboToSearch: TCnProcListComboBox;
    FPreviewLineCount: Integer;
    FHistoryCount: Integer;
    FProcComboHeight: Integer;
    FClassComboHeight: Integer;
    FProcComboWidth: Integer;
    FClassComboWidth: Integer;
    function GetToolBarObjFromEditControl(EditControl: TControl): TCnProcToolBarObj;
    procedure RemoveToolBarObjFromEditControl(EditControl: TControl);
    procedure ToolBarCanShow(Sender: TObject; APage: TCnSrcEditorPage; var ACanShow: Boolean);
    procedure CreateProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure InitProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure RemoveProcToolBar(ToolBarType: string; EditControl: TControl; ToolBar: TToolBar);
    procedure EditorChange(Editor: TEditorObject; ChangeType:
      TEditorChangeTypes);
    procedure OnToolBarTimer(Sender: TObject);
    procedure PopupCloseItemClick(Sender: TObject);
    procedure PopupSubItemSortByClick(Sender: TObject);
    procedure PopupSubItemReverseClick(Sender: TObject);
    procedure PopupExportItemClick(Sender: TObject);

    procedure EditorToolBarEnable(const Value: Boolean);
    procedure SetUseEditorToolBar(const Value: Boolean);
    procedure ParseCurrent;
    procedure ClearList;

    procedure CheckCurrentFile;
    function CheckReparse: Boolean;

    procedure CurrentGotoLineAndFocusEditControl(Info: TCnElementInfo); overload;
    procedure CurrentGotoLineAndFocusEditControl(Line: Integer); overload;
    procedure JumpIntfOnClick(Sender: TObject);
    procedure JumpImplOnClick(Sender: TObject);
    procedure ClassComboDropDown(Sender: TObject);
    procedure ProcComboDropDown(Sender: TObject);
    procedure DoIdleComboChange(Sender: TObject);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    procedure LoadElements(aFileName: string; ToClear: Boolean = True);
    procedure AddProcedure(ElementInfo: TCnElementInfo; IsIntf: Boolean);
    procedure AddElement(ElementInfo: TCnElementInfo);
    function GetCurrentToolBarObj: TCnProcToolBarObj;

    // 注：有其他的设置在 Form 的属性中，不完全在此地
    property UseEditorToolBar: Boolean read FUseEditorToolBar write SetUseEditorToolBar;
    {* 是否显示编辑器中的过程函数列表工具栏}
    property PreviewLineCount: Integer read FPreviewLineCount write FPreviewLineCount;
    {* 预览窗口中的行数量}
    property HistoryCount: Integer read FHistoryCount write FHistoryCount;
    {* 历史记录的数量}

    // 下拉框的尺寸
    property ProcComboHeight: Integer read FProcComboHeight write FProcComboHeight;
    property ProcComboWidth: Integer read FProcComboWidth write FProcComboWidth;
    property ClassComboHeight: Integer read FClassComboHeight write FClassComboHeight;
    property ClassComboWidth: Integer read FClassComboWidth write FClassComboWidth;
  end;

{$ENDIF CNWIZARDS_CNPROCLISTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROCLISTWIZARD}

uses
  CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnWizMacroUtils, CnCommon,
  CnLangMgr, CnSrcEditorToolBar, CnWizNotifier, CnWizShareImages
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

{$R *.DFM}

const
  csUseEditorToolbar = 'UseEditorToolBar';
  csPreviewLineCount = 'PreviewLineCount';
  csHistoryCount = 'HistoryCount';
  csProcHeight = 'ProcHeight';
  csProcWidth = 'ProcWidth';
  csClassHeight = 'ClassHeight';
  csClassWidth = 'ClassWidth';

  csProcComboName = 'ProcCombo';
  csClassComboName = 'ClassCombo';

type
  TCnFileInfo = class(TObject)
  private
    FAllName: string;
    FProjectName: string;
    FFileName: string;
  public
    property FileName: string read FFileName write FFileName;
    property AllName: string read FAllName write FAllName;
    property ProjectName: string read FProjectName write FProjectName;
  end;

const
  csShowPreview = 'ShowPreview';
  csPreviewHeight = 'PreviewHeight';
  csDropDown = 'DropDown';

  csCRLF = #13#10;
  csSep = ';';

  CnDropDownListCount = 7;

  ProcBlacklist: array[0..2] of string = ('CATCH_ALL', 'CATCH', 'AND_CATCH_ALL');

var
  GSortIndex: Integer = -1;
  GSortDown: Boolean = False;
  GMatchStr: string = '';

  FElementList: TStringList;
  FDisplayList: TStringList;
  FObjStrings: TStringList;
  FLanguage: TCnSourceLanguageType;
  FCurElement: string;
  FIsCurrentFile: Boolean;
  FOldCaption: string;
  FIntfLine: Integer = 0;
  FImplLine: Integer = 0;

  ProcListForm: TCnProcListForm = nil;

  GListSortIndex: Integer = 0;
  GListSortReverse: Boolean = False;

  FWizard: TCnProcListWizard = nil;

{ TCnProcListWizard }

procedure TCnProcListWizard.CheckCurrentFile;
var
  S: string;
  Obj: TCnProcToolBarObj;
begin
  Obj := GetCurrentToolBarObj;
  if Obj <> nil then
  begin
    S := CnOtaGetCurrentSourceFileName;
    Obj.EditorToolBar.Visible := IsDelphiSourceModule(S) or IsInc(S) or IsCppSourceModule(S);

    if IsPas(S) or IsInc(S) then
    begin
      Obj.ToolBtnJumpIntf.Enabled := True;
      Obj.ToolBtnJumpImpl.Enabled := True;
    end
    else
    begin
      Obj.ToolBtnJumpIntf.Enabled := False;
      Obj.ToolBtnJumpImpl.Enabled := False;
    end;
  end;
end;

function InfoCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  case GListSortIndex of
  0:
    begin
      Result := CompareText(List[Index1], List[Index2]);
    end;
  1:
    begin
      if (List.Objects[Index1] <> nil) and (List.Objects[Index2] <> nil) then
      begin
        Result := CompareValue(TCnElementInfo(List.Objects[Index1]).LineNo,
          TCnElementInfo(List.Objects[Index2]).LineNo);
      end;
    end;
  else
    Result := CompareValue(Index1, Index2);
  end;

  if GListSortReverse then
    Result := -Result;
end;

function TCnProcListWizard.CheckReparse: Boolean;

  procedure RemoveForward;
  var
    I: Integer;
    Info1, Info2: TCnElementInfo;
  begin
    I := 0;
    while I < FElementList.Count do
    begin
      // 如果本条目和后续条目相同，则删除本条与后续条目中是前向的，I不变，继续循环
      if I < FElementList.Count - 1 then
      begin
        // 同名，判断谁是前向声明的 Info
        Info1 := TCnElementInfo(FElementList.Objects[I]);
        Info2 := TCnElementInfo(FElementList.Objects[I + 1]);

        if (Info1 <> nil) and (Info2 <> nil) and
          (Info1.DisplayName = Info2.DisplayName) then
        begin
          // 谁是前向就删谁，但只删一个，如果有多个前向（虽然不太可能），则在下次循环中删
          if Info1.IsForward then
          begin
            FElementList.Delete(I);
            Info1.Free;
          end
          else if Info2.IsForward then
          begin
            FElementList.Delete(I + 1);
            Info2.Free;
          end;
        end;
      end;
      Inc(I);
    end;
  end;

begin
  Result := False;
  if FNeedReParse then
  begin
    ClearList;
    LoadElements(CnOtaGetCurrentSourceFileName);

    FElementList.Sort;
    RemoveForward; // 去除重复的前向声明

    // 再按需要排序
    if GListSortReverse or (GListSortIndex <> 0) then
      FElementList.CustomSort(InfoCompare);

    FNeedReParse := False;
    Result := True;
  end;
end;

procedure TCnProcListWizard.ClassComboDropDown(Sender: TObject);
var
  ClassCombo: TCnProcListComboBox;
  I: Integer;
  Info: TCnElementInfo;
  Obj: TCnProcToolBarObj;
begin
  CheckReparse;
  ClassCombo := Sender as TCnProcListComboBox;
  ClassCombo.DropDownList.InfoItems.Clear;

  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    if (Info <> nil) and (Info.ElementType in [etRecord, etClass, etInterface]) then
      ClassCombo.DropDownList.InfoItems.AddObject(Info.DisplayName, Info);
  end;

  if not ClassCombo.ChangeDown then
  begin
    ClassCombo.SetTextWithoutChange('');
    ClassCombo.DropDownList.MatchStr := '';
    ClassCombo.DropDownList.MatchStart := Obj.ToolBtnMatchStart.Down;
    ClassCombo.DropDownList.UpdateDisplay;
    if ClassCombo.DropDownList.DisplayItems.Count > 0 then  
      ClassCombo.ShowDropBox;
  end;

  CnWizNotifierServices.ExecuteOnApplicationIdle(ClassCombo.RefreshDropBox);
end;

procedure TCnProcListWizard.ClearList;
var
  I: Integer;
begin
  FObjStrings.Clear;
  FDisplayList.Clear;
  for I := 0 to FElementList.Count - 1 do
    if FElementList.Objects[I] <> nil then
      FElementList.Objects[I].Free;

  FElementList.Clear;
  FIntfLine := 0;
  FImplLine := 0;
end;

procedure TCnProcListWizard.Config;
begin
  inherited;

end;

constructor TCnProcListWizard.Create;
begin
  inherited;
  FProcToolBarObjects := TList.Create;

  FElementList := TStringList.Create;
  FDisplayList := TStringList.Create;
  FObjStrings := TStringList.Create;
  FObjStrings.Sorted := True;
  FObjStrings.Duplicates := dupIgnore;

  EditControlWrapper.AddEditorChangeNotifier(EditorChange);
  FWizard := Self;
end;

procedure TCnProcListWizard.ToolBarCanShow(Sender: TObject;
  APage: TCnSrcEditorPage; var ACanShow: Boolean);
begin
  ACanShow := APage in [epCode];
end;
  
procedure TCnProcListWizard.CreateProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
var
  Obj: TCnProcToolBarObj;
  Item, SubItem: TMenuItem;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Create Proc ToolBar from EditControl %8.8x', [Integer(EditControl)]);
{$ENDIF}
  ToolBar.Top := 40; // 让其处于标准编辑器工具栏之下
  ToolBar.Images := dmCnSharedImages.ilProcToolBar;
  ToolBar.Wrapable := False;
  if ToolBar is TCnExternalSrcEditorToolBar then
    TCnExternalSrcEditorToolBar(ToolBar).OnCanShow := ToolBarCanShow;

  Obj := TCnProcToolBarObj.Create;
  Obj.EditControl := EditControl;
  Obj.EditorToolBar := ToolBar;

  // 手工创建弹出菜单
  Obj.PopupMenu := TPopupMenu.Create(ToolBar);

  // 排序
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListSortMenuCaption;
  Obj.PopupMenu.Items.Add(Item);

  // 子菜单缩进，按名称排序
  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuByName;
  SubItem.Tag := 0;
  SubItem.GroupIndex := 1;
  SubItem.RadioItem := True;
  SubItem.Checked := True;
  SubItem.OnClick := PopupSubItemSortByClick;
  Item.Add(SubItem);

  // 按位置排序
  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuByLocation;
  SubItem.Tag := 1;
  SubItem.GroupIndex := 1;
  SubItem.RadioItem := True;
  SubItem.OnClick := PopupSubItemSortByClick;
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := '-';
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Obj.PopupMenu);
  SubItem.Caption := SCnProcListSortSubMenuReverse;
  SubItem.OnClick := PopupSubItemReverseClick;
  Item.Add(SubItem);

  // 导出
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListExportMenuCaption;
  Item.OnClick := PopupExportItemClick;
  Obj.PopupMenu.Items.Add(Item);

  // 分割线
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := '-';
  Obj.PopupMenu.Items.Add(Item);

  // 关闭
  Item := TMenuItem.Create(Obj.PopupMenu);
  Item.Caption := SCnProcListCloseMenuCaption;
  Item.OnClick := PopupCloseItemClick;
  Obj.PopupMenu.Items.Add(Item);

  ToolBar.PopupMenu := Obj.PopupMenu;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Proc ToolBar Obj Created: %8.8x', [Integer(Obj)]);
{$ENDIF}

  Obj.ClassCombo := TCnProcListComboBox.Create(ToolBar);
  with Obj.ClassCombo do
  begin
    Parent := ToolBar;
    Left := 108;
    Top := 0;
    Width := 150;
    Height := 21;
    FDisableChange := True;
    Name := csClassComboName;
    SetTextWithoutChange('');
    FDisableChange := False;
    OnButtonClick := ClassComboDropDown;
  end;

  Obj.FSplitter1 := TSplitter.Create(ToolBar);
  with Obj.FSplitter1 do
  begin
    Align := alLeft;
    Width := 2;
    MinSize := 40;
    Parent := ToolBar;
    Left := Obj.ClassCombo.Width - 1;
  end;

  Obj.ProcCombo := TCnProcListComboBox.Create(ToolBar);
  with Obj.ProcCombo do
  begin
    Parent := ToolBar;
    Left := 265;
    Top := 0;
    Width := 244;
    Height := 21;
    FDisableChange := True;
    Name := csProcComboName;
    SetTextWithoutChange('');
    FDisableChange := False;
    OnButtonClick := ProcComboDropDown;
  end;

  Obj.FSplitter2 := TSplitter.Create(ToolBar);
  with Obj.FSplitter2 do
  begin
    Align := alLeft;
    Width := 3;
    MinSize := 40;
    Parent := ToolBar;
    Left := Obj.ClassCombo.Width + 2;
  end;

  Obj.InternalToolBar2 := TCnExternalSrcEditorToolBar.Create(ToolBar);
  with Obj.InternalToolBar2 do
  begin
    Parent := ToolBar;
    Left := 40;
    Top := 0;
    Caption := '';
    AutoSize := True;
    Align := alLeft;
    EdgeBorders := [];
    Flat := True;
    DockSite := False;
    ShowHint := True;
    Transparent := False;
    Images := dmCnSharedImages.ilProcToolBar;
    PopupMenu := Obj.PopupMenu;
  end;

  Obj.ToolBtnJumpIntf := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnJumpIntf do
  begin
    Left := 54;
    Top := 0;
    Caption := '';
    ImageIndex := 0;
    SetToolBar(Obj.InternalToolBar2);
    OnClick := JumpIntfOnClick;
  end;

  Obj.ToolBtnJumpImpl := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnJumpImpl do
  begin
    Left := 77;
    Top := 0;
    Caption := '';
    ImageIndex := 1;
    SetToolBar(Obj.InternalToolBar2);
    OnClick := JumpImplOnClick;
  end;

  Obj.InternalToolBar1 := TCnExternalSrcEditorToolBar.Create(ToolBar);
  with Obj.InternalToolBar1 do
  begin
    Parent := ToolBar;
    Left := 0;
    Top := 0;
    Caption := '';
    AutoSize := True;
    Align := alLeft;
    EdgeBorders := [];
    Flat := True;
    DockSite := False;
    ShowHint := True;
    Transparent := False;
    Images := GetIDEImageList;
    PopupMenu := Obj.PopupMenu;
  end;

  Obj.ToolBtnProcList := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnProcList do
  begin
    Left := 0;
    Top := 0;
    Caption := '';
    ImageIndex := -1;
    SetToolBar(Obj.InternalToolBar1);
  end;

  Obj.ToolBtnListUsed := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnListUsed do
  begin
    Left := 23;
    Top := 0;
    Caption := '';
    ImageIndex := -1;
    SetToolBar(Obj.InternalToolBar1);
  end;

  Obj.ToolBtnSep1 := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnSep1 do
  begin
    Left := 46;
    Top := 0;
    Width := 4;
    Caption := '';
    ImageIndex := -1;
    Style := tbsSeparator;
    SetToolBar(Obj.InternalToolBar1);
  end;
  Obj.InternalToolBar1.Visible := Obj.ToolBtnSep1.Visible;

  Obj.ToolBtnMatchStart := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnMatchStart do
  begin
    Left := 505;
    Top := 0;
    Caption := '';
    ImageIndex := 2;
    Grouped := True;
    Style := tbsCheck;
    SetToolBar(ToolBar);
  end;

  Obj.ToolBtnMatchAny := TCnProcToolButton.Create(ToolBar);
  with Obj.ToolBtnMatchAny do
  begin
    Left := 528;
    Top := 0;
    Caption := '';
    ImageIndex := 3;
    Grouped := True;
    Style := tbsCheck;
    Down := True;
    SetToolBar(ToolBar);
  end;

  FProcToolBarObjects.Add(Obj);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProcList: Proc ToolBar Obj Added.');
{$ENDIF}
end;

destructor TCnProcListWizard.Destroy;
var
  I: Integer;
begin
  FWizard := nil;
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChange);
  for I := 0 to FProcToolBarObjects.Count - 1 do
    TObject(FProcToolBarObjects).Free;
  FreeAndNil(FProcToolBarObjects);

  FreeAndNil(FToolBarTimer);

  FObjStrings.Free;
  FDisplayList.Free;
  for I := 0 to FElementList.Count - 1 do
    if FElementList.Objects[I] <> nil then
      FElementList.Objects[I].Free;

  FElementList.Free;

  FreeAndNil(FCurrPasParser);
  FreeAndNil(FCurrCppParser);
  FreeAndNil(FCurrStream);
  inherited;
end;

procedure TCnProcListWizard.EditorChange(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  Obj: TCnProcToolBarObj;
begin
  if FUseEditorToolBar then
  begin
    if ChangeType * [ctView] <> [] then
    begin
      CheckCurrentFile;
    end;

    if ChangeType * [ctView, ctWindow, ctModified, ctBlock] <> [] then
    begin
      FNeedReParse := True;
    end;
    if FNeedReParse or (ChangeType * [ctCurrLine, ctCurrCol] <> []) then
    begin
      FToolBarTimer.Enabled := False;
      FToolBarTimer.Enabled := True;
    end;

    if ChangeType * [ctView] <> [] then
    begin
      Obj := GetCurrentToolBarObj;
      if Obj <> nil then
      begin
        if Obj.ProcCombo <> nil then
          Obj.ProcCombo.DropDownList.CloseUp;
        if Obj.ClassCombo <> nil then
          Obj.ClassCombo.DropDownList.CloseUp;
      end;
    end;    
  end;  
end;

procedure TCnProcListWizard.Execute;
var
  Ini: TCustomIniFile;
  TmpFileName: string;
begin
  TmpFileName := CnOtaGetCurrentSourceFileName;
  if TmpFileName = '' then
  begin
    ErrorDlg(SCnProcListErrorFileType);
    Exit;
  end;

  Ini := CreateIniFile;
  try
    ClearList;
    with TCnProcListForm.Create(nil) do
    try
      Wizard := Self;

      ShowHint := WizOptions.ShowHint;
      FileName := TmpFileName;
      // Current Filename
      CurrentFile := TmpFileName;
      FIsCurrentFile := True;

      LoadSettings(Ini, '');
      LoadElements(FFileName);
      UpdateListView;

      actHookIDE.Enabled := IsSourceModule(FFileName) or IsInc(FFileName);
      if actHookIDE.Enabled then
        actHookIDE.Checked := UseEditorToolBar;
      if ShowModal = mrOK then
      begin
        // BringIdeEditorFormToFront;
        CnOtaMakeSourceVisible(CurrentFile);
      end;

      if actHookIDE.Enabled then
        UseEditorToolBar := actHookIDE.Checked;
      SaveSettings(Ini, '');
      DoSaveSettings;
    finally
      Free;
    end;
  finally
    Ini.Free;
  end;
end;

function TCnProcListWizard.GetCaption: string;
begin
  Result := SCnProcListWizardMenuCaption;
end;

function TCnProcListWizard.GetCurrentToolBarObj: TCnProcToolBarObj;
begin
  Result := GetToolBarObjFromEditControl(GetCurrentEditControl);
end;

function TCnProcListWizard.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(Word('D'), [ssCtrl]);
end;

function TCnProcListWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnProcListWizard.GetHint: string;
begin
  Result := SCnProcListWizardMenuHint;
end;

function TCnProcListWizard.GetState: TWizardState;
begin
  if CnOtaGetCurrentSourceFileName <> '' then
    Result := [wsEnabled]
  else
    Result := [];
end;

function TCnProcListWizard.GetToolBarObjFromEditControl(
  EditControl: TControl): TCnProcToolBarObj;
var
  I: Integer;
begin
  Result := nil;
  // 倒序来，容易找点儿，同时避免某些未是否的东西在 FProcToolBarObjects 中重复出错
  for I := FProcToolBarObjects.Count - 1 downto 0 do
    if TCnProcToolBarObj(FProcToolBarObjects[I]).EditControl = EditControl then
    begin
      Result := TCnProcToolBarObj(FProcToolBarObjects[I]);
      Exit;
    end;
end;

class procedure TCnProcListWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnProcListWizardName;
  Author := SCnPack_LiuXiao + ';GExperts Team';
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnProcListWizardComment;
end;

procedure TCnProcListWizard.InitProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
var
  Obj: TCnProcToolBarObj;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Init Proc ToolBar from EditControl %8.8x', [Integer(EditControl)]);
{$ENDIF}
  Obj := GetToolBarObjFromEditControl(EditControl);
  if Obj = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Obj found from EditControl %8.8x', [Integer(Obj)]);
{$ENDIF}

  Obj.ToolBtnProcList.Action := FindIDEAction('act' + Copy(ClassName, 2, MaxInt)); // 去 T
  Obj.ToolBtnProcList.Visible := Action <> nil;

  Obj.ToolBtnListUsed.Action := FindIDEAction('act' + SCnProjExtListUsed);
  Obj.ToolBtnListUsed.Visible := Action <> nil;

  Obj.ToolBtnSep1.Visible := (Obj.ToolBtnProcList.Visible or Obj.ToolBtnListUsed.Visible);
  Obj.InternalToolBar1.Visible := Obj.ToolBtnSep1.Visible;

  Obj.ToolBtnJumpIntf.Hint := SCnProcListJumpIntfHint;
  Obj.ToolBtnJumpImpl.Hint := SCnProcListJumpImplHint;

  Obj.ClassCombo.Hint := SCnProcListClassComboHint;
  Obj.ProcCombo.Hint := SCnProcListProcComboHint;
  
  Obj.ToolBtnMatchStart.Hint := SCnProcListMatchStartHint;
  Obj.ToolBtnMatchAny.Hint := SCnProcListMatchAnyHint;

  Obj.PopupMenu.Items[0].Caption := SCnProcListSortMenuCaption;

    Obj.PopupMenu.Items[0].Items[0].Caption := SCnProcListSortSubMenuByName;
    Obj.PopupMenu.Items[0].Items[1].Caption := SCnProcListSortSubMenuByLocation;
    Obj.PopupMenu.Items[0].Items[2].Caption := '-';
    Obj.PopupMenu.Items[0].Items[3].Caption := SCnProcListSortSubMenuReverse;

  Obj.PopupMenu.Items[1].Caption := SCnProcListExportMenuCaption;
  Obj.PopupMenu.Items[2].Caption := '-';
  Obj.PopupMenu.Items[3].Caption := SCnProcListCloseMenuCaption;
  
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProcList: Init Proc ToolBar Complete.');
{$ENDIF}
end;

procedure TCnProcListWizard.JumpImplOnClick(Sender: TObject);
begin
  CheckReparse;
  // 跳到 impl 行数处
  if FImplLine > 0 then
    CurrentGotoLineAndFocusEditControl(FImplLine)
  else
    ErrorDlg(SCnProcListErrorNoImpl);
end;

procedure TCnProcListWizard.JumpIntfOnClick(Sender: TObject);
begin
  CheckReparse;
  // 跳到 intf 行数处
  if FIntfLine > 0 then
    CurrentGotoLineAndFocusEditControl(FIntfLine)
  else
    ErrorDlg(SCnProcListErrorNoIntf);
end;

procedure TCnProcListWizard.LoadSettings(Ini: TCustomIniFile);
begin
  UseEditorToolBar := Ini.ReadBool('', csUseEditorToolbar, True);
  PreviewLineCount := Ini.ReadInteger('', csPreviewLineCount, 4);
  HistoryCount := Ini.ReadInteger('', csHistoryCount, 8);

  ProcComboHeight := Ini.ReadInteger('', csProcHeight, 0);
  ProcComboWidth := Ini.ReadInteger('', csProcWidth, 0);
  ClassComboHeight := Ini.ReadInteger('', csClassHeight, 0);
  ClassComboWidth := Ini.ReadInteger('', csClassWidth, 0);
end;

procedure TCnProcListWizard.OnToolBarTimer(Sender: TObject);
begin
  try
    if FUseEditorToolBar then
      ParseCurrent;
  finally
    FToolBarTimer.Enabled := False;
  end;
end;

procedure TCnProcListWizard.ParseCurrent;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Obj: TCnProcToolBarObj;
  DotPos: Integer;
  S: string;
begin
  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  if FCurrStream = nil then
    FCurrStream := TMemoryStream.Create
  else
    FCurrStream.Clear;

  CnOtaSaveEditorToStream(EditView.Buffer, FCurrStream);
  S := EditView.Buffer.FileName;

  FLanguage := ltUnknown;
  if IsPas(S) or IsDpr(S) or IsInc(S) then
    FLanguage := ltPas
  else if IsCppSourceModule(S) then
    FLanguage := ltCpp;

  if FLanguage = ltPas then
  begin
    if FCurrPasParser = nil then
      FCurrPasParser := TCnPasStructureParser.Create;

    FCurrPasParser.ParseSource(PAnsiChar(FCurrStream.Memory),
      IsDpr(S) or IsInc(S), False);

    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);

    if not Obj.ClassCombo.Focused then
      Obj.ClassCombo.SetTextWithoutChange(string(FCurrPasParser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex)));

    if not Obj.ProcCombo.Focused then
    begin
      if FCurrPasParser.CurrentChildMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(string(FCurrPasParser.CurrentChildMethod))
      else if FCurrPasParser.CurrentMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(string(FCurrPasParser.CurrentMethod))
      else
        Obj.ProcCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;

    if not Obj.ClassCombo.Focused and (Obj.ClassCombo.Text = '') then
    begin
      DotPos := Pos('.', Obj.ProcCombo.Text);
      if DotPos > 1 then
        Obj.ClassCombo.SetTextWithoutChange(Copy(Obj.ProcCombo.Text, 1, DotPos - 1))
      else
        Obj.ClassCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;
  end
  else if FLanguage = ltCpp then
  begin
    if FCurrCppParser = nil then
      FCurrCppParser := TCnCppStructureParser.Create;

    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    // 是否需要转换？
    FCurrCppParser.ParseSource(PAnsiChar(FCurrStream.Memory), FCurrStream.Size,
      CharPos.Line, CharPos.CharIndex, True);

    // 记录并显示当前类与当前函数名
    if not Obj.ClassCombo.Focused then
    begin
      if FCurrCppParser.CurrentClass <> '' then
        Obj.ClassCombo.SetTextWithoutChange(string(FCurrCppParser.CurrentClass))
      else
        Obj.ClassCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;

    if not Obj.ProcCombo.Focused then
    begin
      if FCurrCppParser.CurrentMethod <> '' then
        Obj.ProcCombo.SetTextWithoutChange(string(FCurrCppParser.CurrentMethod))
      else
        Obj.ProcCombo.SetTextWithoutChange(SCnProcListNoContent);
    end;
  end;
end;

procedure TCnProcListWizard.ProcComboDropDown(Sender: TObject);
var
  ProcCombo: TCnProcListComboBox;
  I: Integer;
  Info: TCnElementInfo;
  Obj: TCnProcToolBarObj;
begin
  CheckReparse;
  ProcCombo := Sender as TCnProcListComboBox;
  ProcCombo.DropDownList.InfoItems.Clear;

  Obj := GetToolBarObjFromEditControl(CnOtaGetCurrentEditControl);
  if Obj = nil then Exit;

  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    if (Info <> nil) and (Info.ElementType in [etClassFunc, etSingleFunction,
      etConstructor, etDestructor]) then
      ProcCombo.DropDownList.InfoItems.AddObject(Info.DisplayName, Info);
  end;

  if not ProcCombo.ChangeDown then
  begin
    ProcCombo.SetTextWithoutChange('');
    ProcCombo.DropDownList.MatchStr := '';
    ProcCombo.DropDownList.MatchStart := Obj.ToolBtnMatchStart.Down;
    ProcCombo.DropDownList.UpdateDisplay;
    if ProcCombo.DropDownList.DisplayItems.Count > 0 then
      ProcCombo.ShowDropBox;
  end;

  CnWizNotifierServices.ExecuteOnApplicationIdle(ProcCombo.RefreshDropBox);
end;

procedure TCnProcListWizard.RemoveProcToolBar(ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  RemoveToolBarObjFromEditControl(EditControl);
end;

procedure TCnProcListWizard.RemoveToolBarObjFromEditControl(
  EditControl: TControl);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProcList: Prepare to Remove Objs from EditControl %8.8x',
    [Integer(EditControl)]);
{$ENDIF}
  for I := FProcToolBarObjects.Count - 1 downto 0 do
    if TCnProcToolBarObj(FProcToolBarObjects[I]).EditControl = EditControl then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ProcList: Remove Obj %8.8x from EditControl %8.8x',
        [Integer(FProcToolBarObjects[I]), Integer(EditControl)]);
{$ENDIF}
      FProcToolBarObjects.Delete(I);
    end;
end;

procedure TCnProcListWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csUseEditorToolbar, UseEditorToolBar);
  Ini.WriteInteger('', csPreviewLineCount, PreviewLineCount);
  Ini.WriteInteger('', csHistoryCount, HistoryCount);

  Ini.WriteInteger('', csProcHeight, ProcComboHeight);
  Ini.WriteInteger('', csProcWidth, ProcComboWidth);
  Ini.WriteInteger('', csClassHeight, ClassComboHeight);
  Ini.WriteInteger('', csClassWidth, ClassComboWidth);
end;

{ TCnProcListFrm }

procedure TCnProcListForm.FormCreate(Sender: TObject);
var
  EditorCanvas: TCanvas;
begin
  inherited;
  NeedInitProjectControls := False;
  InitFileComboBox;
  FOldCaption := Caption;
  actHookIDE.Visible := CnEditorToolBarService <> nil;

  ProcListForm := Self;

  EditorCanvas := EditControlWrapper.GetEditControlCanvas(CnOtaGetCurrentEditControl);
  if EditorCanvas <> nil then
  begin
    if EditorCanvas.Font.Name <> mmoContent.Font.Name then
      mmoContent.Font.Name := EditorCanvas.Font.Name;
    mmoContent.Font.Size := EditorCanvas.Font.Size;
    mmoContent.Font.Style := EditorCanvas.Font.Style;
  end;
  
  {$IFDEF COMPILER6_UP}
  cbbMatchSearch.AutoComplete := False;
  {$ENDIF}
end;

procedure TCnProcListForm.FormShow(Sender: TObject);
begin
  inherited;
  UpdateItemPosition;
  UpdateMemoHeight(nil);
end;

procedure TCnProcListForm.CreateList;
begin

end;

function TCnProcListForm.DoSelectOpenedItem: string;
begin
  Result := '';
end;

procedure TCnProcListForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin

end;

function TCnProcListForm.GetSelectedFileName: string;
begin
  Result := '';
end;

function TCnProcListForm.GetHelpTopic: string;
begin
  Result := 'CnProcListWizard';
end;

procedure TCnProcListWizard.LoadElements(aFileName: string; ToClear: Boolean);
var
  I, BraceCountDelta, PreviousBraceCount, BeginIndex: Integer;
  MemStream: TMemoryStream;
  Parser: TmwPasLex;
  CParser: TBCBTokenList;
  BeginBracePosition, ClassNamePosition: Longint;
  BraceCount, NameSpaceCount: Integer;
  NameList: TStrings;
  NewName, TmpName, ProcClassAdd, ClassName, TemplateArgs: string;
  UpperIsNameSpace: Boolean;
  BraceStack: TStack;
  ElementType: TCnElementType;

  function MoveToImplementation: Boolean;
  begin
    if IsDpr(aFileName) or (IsInc(aFileName)) then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    while Parser.TokenID <> tkNull do
    begin
      if Parser.TokenID = tkImplementation then
        Result := True;
      Parser.Next;
      if Result then
        Break;
    end;
  end;

  function GetProperProcName(ProcType: TTokenKind; IsClass: Boolean): string;
  begin
    Result := SUnknown;
    if IsClass then
    begin
      if ProcType = tkFunction then
        Result := 'class function' // Do not localize.
      else if ProcType = tkProcedure then
        Result := 'class procedure'; // Do not localize.
    end
    else
    begin
      case ProcType of
        // Do not localize.
        tkFunction: Result := 'function';
        tkProcedure: Result := 'procedure';
        tkConstructor: Result := 'constructor';
        tkDestructor: Result := 'destructor';
      end;
    end;
  end;

  function GetProperElementType(ProcType: TTokenKind; IsClass: Boolean): TCnElementType;
  begin
    Result := etUnknown;
    if IsClass then
    begin
      if ProcType in [tkFunction, tkProcedure] then
        Result := etClassFunc;
    end
    else
    begin
      case ProcType of
        tkFunction, tkProcedure: Result := etSingleFunction;
        tkConstructor: Result := etConstructor;
        tkDestructor: Result := etDestructor;
      end;
    end;
  end;

  // 从当前位置往后找最外层的{ 或找上一层是 namespace 的 {
  procedure FindBeginningBrace;
  var
    Prev1, Prev2: TCTokenKind; // 分别表示当前 RunID 的前一个/前两个 id
    CurIsNameSpace, NeedDecBraceCount: Boolean;
  begin
    CurIsNameSpace := False;
    NeedDecBraceCount := False;
    Prev1 := ctknull;

    repeat
      Prev2 := Prev1;
      Prev1 := CParser.RunID;

      CParser.NextNonJunk;
      if NeedDecBraceCount then // 如果上次循环记录了bracepair，则留到此时减
      begin
        Dec(BraceCount);
        NeedDecBraceCount := False;
      end;

      case CParser.RunID of
        ctkbraceopen, ctkbracepair:
          begin
            Inc(BraceCount);

            if BraceStack.Count = 0 then
              UpperIsNameSpace := False
            else
              UpperIsNameSpace := Boolean(BraceStack.Peek);
              // 读堆栈顶的判断上一层次是否为 namespace 的内容

            CurIsNameSpace := (Prev2 = ctknamespace) or (Prev1 = ctknamespace);
            BraceStack.Push(Pointer(CurIsNameSpace));
            if CurIsNameSpace then
              Inc(NameSpaceCount);

            if CParser.RunID = ctkbracepair then // 空函数体 {} 紧邻时的处理
            begin
              // Dec(BraceCount);  // 留到下次循环时再减，免得下面until判断出错
              NeedDecBraceCount := True;
              if CurIsNameSpace then
                Dec(NameSpaceCount);
              BraceStack.Pop;
            end;
          end;
        ctkbraceclose:
          begin
            Dec(BraceCount);
            try
              if Boolean(BraceStack.Pop) then
                Dec(NameSpaceCount);
            except
              ;
            end;
          end;
        ctknull: Exit;
      end;
    until (CParser.RunID = ctknull) or
      ((CParser.RunID in [ctkbraceopen, ctkbracepair]) and not CurIsNameSpace and ((BraceCount = 1) or UpperIsNameSpace));

    if CParser.RunID = ctkbracepair then
      Dec(BraceCount);
  end;

  procedure FindBeginningProcedureBrace(var Name: string; var AEleType: TCnElementType); // Used for CPP
  var
    InitialPosition: Integer;
    RestorePosition: Integer;
    FoundClass: Boolean;
  begin
    BeginBracePosition := 0;
    ClassNamePosition := 0;
    InitialPosition := CParser.RunPosition;
    // Skip these: enum {a, b, c};  or  int a[] = {0, 3, 5};  and find  foo () {
    FindBeginningBrace;
    if CParser.RunID = ctknull then
      Exit;
    CParser.PreviousNonJunk;
    // 找到最外层的'{'后，回退开始检查是类还是名字空间
    if CParser.RunID = ctkidentifier then  // 左大括号前是标识符，类似于 class TA { }
    begin
      Name := CParser.RunToken; // The name
      // This might be a derived class so search backward
      // no further than InitialPosition to see
      RestorePosition := CParser.RunPosition;
      FoundClass := False;
      while CParser.RunPosition >= InitialPosition do // 往回找关键字，看有无以下几个
      begin
        if CParser.RunID in [ctkclass, ctkstruct, ctknamespace] then
        begin
          FoundClass := True;
          ClassNamePosition := CParser.RunPosition;
          case CParser.RunID of
            ctkclass: AEleType := etClass;
            ctkstruct: AEleType := etRecord;
            ctknamespace: AEleType := etNamespace;
          else
            AEleType := etUnknown;
          end;
          Break;
        end;
        if CParser.RunPosition = InitialPosition then
          Break;
        CParser.PreviousNonJunk;
      end;

      // 如果是类，那么类名是紧靠 : 或 { 前的东西，那么类、结构、名字空间的话就往前找名字
      if FoundClass then //
      begin
        while not (CParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
        begin
          Name := CParser.RunToken; // 找到类名或者名字空间名
          CParser.NextNonJunk;
        end;
        // Back up a bit if we are on a brace open so empty enums don't get treated as namespaces
        if CParser.RunID = ctkbraceopen then
          CParser.PreviousNonJunk;
      end;
      // Now get back to where you belong
      while CParser.RunPosition < RestorePosition do
        CParser.NextNonJunk;
      CParser.NextNonJunk;
      BeginBracePosition := CParser.RunPosition; // 回到最外层的 '{'
    end
    else  // 左大括号前不是标识符，接着判断是否是函数标识
    begin
      if CParser.RunID in [ctkroundclose, ctkroundpair, ctkconst, ctkvolatile,
        ctknull] then
      begin
        // 以上几个，表示找到函数了
        Name := '';
        CParser.NextNonJunk;
        BeginBracePosition := CParser.RunPosition;
      end
      else
      begin
        while not (CParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull]) do
        begin
          CParser.NextNonJunk;
          if CParser.RunID = ctknull then
            Exit;
          // Recurse
          FindBeginningProcedureBrace(Name, ElementType);
          CParser.PreviousNonJunk;
          if Name <> '' then
            Break;
        end;
        CParser.NextNonJunk;
      end;
    end;
  end;

  procedure EraseName(Names: TStrings; Index: Integer);
  var
    NameIndex: Integer;
  begin
    NameIndex := Names.IndexOfName(IntToStr(Index));
    if NameIndex <> -1 then
      Names.Delete(NameIndex);
  end;

  function SearchForProcedureName: string;
  var
    ParenCount: Integer;
  begin
    ParenCount := 0;
    Result := '';
    repeat
      CParser.Previous;
      if CParser.RunID <> ctkcrlf then
        if (CParser.RunID = ctkspace) and (CParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CParser.RunToken + Result;
      case CParser.RunID of
        ctkroundclose: Inc(ParenCount);
        ctkroundopen: Dec(ParenCount);
        ctknull: Exit;
      end;
    until ((ParenCount <= 0) and ((CParser.RunID = ctkroundopen) or
      (CParser.RunID = ctkroundpair)));
    CParser.PreviousNonJunk; // This is the procedure name
  end;

  function InProcedureBlacklist(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(ProcBlacklist) to High(ProcBlacklist) do
    begin
      if Name = ProcBlacklist[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  function SearchForTemplateArgs: string;
  var
    AngleCount: Integer;
  begin
    Result := '';
    if CParser.RunID <> ctkGreater then
      Exit; // Only use if we are on a '>'
    AngleCount := 1;
    Result := CParser.RunToken;
    repeat
      CParser.Previous;
      if CParser.RunID <> ctkcrlf then
        if (CParser.RunID = ctkspace) and (CParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CParser.RunToken + Result;
      case CParser.RunID of
        ctkGreater: Inc(AngleCount);
        ctklower: Dec(AngleCount);
        ctknull: Exit;
      end;
    until (((AngleCount = 0) and (CParser.RunID = ctklower)) or
      (CParser.RunIndex = 0));
    CParser.PreviousNonJunk; // This is the token before the template args
  end;

  procedure FindEndingBrace(const BraceCountDelta: Integer;
    const DecrementOpenBrace: Boolean);
  var
    aBraceCount: Integer;
  begin
    if DecrementOpenBrace then
      aBraceCount := BraceCountDelta
    else
      aBraceCount := 0;

    repeat
      CParser.NextNonComment;
      case CParser.RunID of
        ctkbraceopen: Inc(BraceCount);
        ctkbraceclose: Dec(BraceCount);
        ctknull: Exit;
      end;
    until ((BraceCount - aBraceCount) = NameSpaceCount) or
      (CParser.RunID = ctknull);
  end;

  procedure FindElements(IsDprFile: Boolean);
  var
    ProcLine: string;
    ProcType, PrevTokenID: TTokenKind;
    Line: Integer;
    ClassLast, IntfLast: Boolean;
    InParenthesis: Boolean;
    InTypeDeclaration: Boolean;
    InIntfDeclaration: Boolean;
    InImplementation: Boolean;
    FoundNonEmptyType: Boolean;
    IdentifierNeeded: Boolean;
    ElementInfo: TCnElementInfo;
    BeginProcHeaderPosition: Longint;
    j, k: Integer;
    LineNo: Integer;
    ProcName, ProcReturnType, IntfName: string;
    ElementTypeStr, OwnerClass, ProcArgs: string;

    CurIdent, CurClass, CurIntf: string;
    PrevIsOperator: Boolean;
    PrevElementForForward: TCnElementInfo;
    IsClassForForward: Boolean;
  begin
    FElementList.BeginUpdate;
    try
      case FLanguage of
        ltPas:
          begin
            ClassLast := False;
            InParenthesis := False;
            InTypeDeclaration := False;
            InImplementation := IsDprFile;
            InIntfDeclaration := False;
            FoundNonEmptyType := False;
            IsClassForForward := False;
            PrevElementForForward := nil;
            IntfName := '';
            CurIdent := '';
            CurClass := '';
            CurIntf := '';
            PrevTokenID := tkNull;

            while Parser.TokenID <> tkNull do
            begin
              // 记录下每个 Identifier
              if Parser.TokenID = tkIdentifier then
                CurIdent := Parser.Token
              else if Parser.TokenID = tkSemicolon then
              begin
                if IsClassForForward and (PrevElementForForward <> nil) then
                  PrevElementForForward.IsForward := True;
              end;
              IsClassForForward := False;
              PrevElementForForward := nil;

              if (Parser.TokenID = tkClass) and Parser.IsClass then
                CurClass := CurIdent;
              if Parser.TokenID = tkInterface then
              begin
                if Parser.IsInterface then
                  CurIntf := CurIdent
                else if FIntfLine = 0 then
                  FIntfLine := Parser.LineNumber + 1;
              end
              else if (Parser.TokenID = tkImplementation) and (FImplLine = 0) then
                FImplLine := Parser.LineNumber + 1;

              if ((not InTypeDeclaration and InImplementation) or InIntfDeclaration) and
                (Parser.TokenID in [tkFunction, tkProcedure, tkConstructor, tkDestructor]) then
              begin
                IdentifierNeeded := PrevTokenID <> tkAssign;

                ProcType := Parser.TokenID;
                Line := Parser.LineNumber + 1;
                ProcLine := '';

                // 此循环获得整个 Proc 的声明
                while not (Parser.TokenId in [tkNull]) do
                begin
                  case Parser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  if (not InParenthesis) and (Parser.TokenID in [tkSemiColon,
                    tkVar, tkBegin, tkType, tkConst]) then // 匿名方法声明后无分号，暂且以 begin 或 var 等来判断
                    Break;

                  if not (Parser.TokenID in [tkCRLF, tkCRLFCo]) then
                    ProcLine := ProcLine + Parser.Token;
                  Parser.Next;
                end; // while

                // 得到整个 Proc 的声明，ProcLine
                if Parser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.

                if not IdentifierNeeded then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.Name := ProcLine;
                  if InIntfDeclaration then
                  begin
                    if ProcType = tkProcedure then
                      ElementInfo.ElementTypeStr := 'interface procedure'
                    else if ProcType = tkFunction then
                      ElementInfo.ElementTypeStr := 'interface function'
                    else
                      ElementInfo.ElementTypeStr := 'interface member';
                      
                    ElementInfo.ElementType := etIntfMember;
                    ElementInfo.OwnerClass := IntfName;
                  end
                  else
                  begin
                    ElementInfo.ElementTypeStr := GetProperProcName(ProcType, ClassLast);
                    ElementInfo.ElementType := GetProperElementType(ProcType, ClassLast);
                  end;

                  ElementInfo.LineNo := Line;
                  ElementInfo.FileName := ExtractFileName(aFileName);
                  ElementInfo.AllName := aFileName;
                  AddProcedure(ElementInfo, InIntfDeclaration);
                end;
              end;

              if not InIntfDeclaration and (Parser.TokenID = tkIdentifier) then
                IntfName := Parser.Token;

              if (Parser.TokenID = tkClass) and Parser.IsClass then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := False;
                FoundNonEmptyType := False;

                // 记录类信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := Parser.LineNumber + 1;
                ElementInfo.FileName := ExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etClass;
                ElementInfo.ElementTypeStr := 'class';
                ElementInfo.DisplayName := CurClass;
                ElementInfo.OwnerClass := CurClass;
                AddElement(ElementInfo);

                IsClassForForward := True; // 以备后面判断是否是 class; 的前向声明
                PrevElementForForward := ElementInfo;
              end
              else if ((Parser.TokenID = tkInterface) and Parser.IsInterface) or
                (Parser.TokenID = tkDispInterface) then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := True;
                FoundNonEmptyType := False;

                // 记录接口信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := Parser.LineNumber + 1;
                ElementInfo.FileName := ExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etInterface;
                ElementInfo.ElementTypeStr := 'interface';
                ElementInfo.DisplayName := CurIntf;
                ElementInfo.OwnerClass := CurIntf;
                AddElement(ElementInfo);
              end
              else if Parser.TokenID = tkRecord then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := True;
                FoundNonEmptyType := False;

                // 记录记录信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := Parser.LineNumber + 1;
                ElementInfo.FileName := ExtractFileName(aFileName);
                ElementInfo.AllName := aFileName;
                ElementInfo.ElementType := etRecord;
                ElementInfo.ElementTypeStr := 'record';
                ElementInfo.DisplayName := CurIdent;
                // ElementInfo.OwnerClass := CurIntf;
                AddElement(ElementInfo);
              end
              else if InTypeDeclaration and
                (Parser.TokenID in [tkProcedure, tkFunction, tkProperty,
                tkPrivate, tkProtected, tkPublic, tkPublished]) then
              begin
                FoundNonEmptyType := True;

                // 记录属性信息
                if Parser.TokenID = tkProperty then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.LineNo := Parser.LineNumber + 1;
                  ElementInfo.FileName := ExtractFileName(aFileName);
                  ElementInfo.AllName := aFileName;

                  while Parser.TokenID <> tkIdentifier do
                    Parser.Next;

                  if InIntfDeclaration then
                  begin
                    ElementInfo.ElementType := etIntfProperty;
                    ElementInfo.ElementTypeStr := 'interface property';
                    ElementInfo.OwnerClass := CurIntf;
                    ElementInfo.DisplayName := CurIntf + '.' + Parser.Token;
                  end
                  else
                  begin
                    ElementInfo.ElementType := etProperty;
                    ElementInfo.ElementTypeStr := 'property';
                    ElementInfo.OwnerClass := CurClass;
                    ElementInfo.DisplayName := CurClass + '.' + Parser.Token;
                  end;
                  AddElement(ElementInfo);
                end;
              end
              else if InTypeDeclaration and
                ((Parser.TokenID = tkEnd) or
                (((Parser.TokenID = tkSemiColon) and not InIntfDeclaration)
                 and not FoundNonEmptyType)) then
              begin
                InTypeDeclaration := False;
                InIntfDeclaration := False;
                IntfName := '';
              end
              else if Parser.TokenID = tkImplementation then
              begin
                InImplementation := True;
                InTypeDeclaration := False;
              end
              else if (Parser.TokenID = tkProgram) or (Parser.TokenID = tkLibrary) then
              begin
                InImplementation := True; // DPR 和 Lib 等文件无 Interface 部分
              end;

              ClassLast := (Parser.TokenID = tkClass);
              IntfLast := (Parser.TokenID = tkInterface);

              if not (Parser.TokenID in [tkSpace, tkCRLF, tkCRLFCo]) then
                PrevTokenID := Parser.TokenID;

              if ClassLast or IntfLast then
              begin
                Parser.NextNoJunk;
              end
              else
                Parser.Next;
            end;
          end; //ltPas

        ltCpp:
          begin
            BraceCount := 0;
            PreviousBraceCount := 0;
            NameSpaceCount := 0;

            UpperIsNameSpace := False;
            BraceStack := TStack.Create;
            NameList := TStringList.Create;

            try
              // 记录最后的位置，避免从头查找时超过末尾
              j := CParser.TokenPositionsList[CParser.TokenPositionsList.Count - 1];
              FindBeginningProcedureBrace(NewName, ElementType);
              // 上面的函数会找到一个类声明或函数声明的开头，如果是类声明等，
              // 类名称会被塞入 NewName 这个变量

              while (CParser.RunPosition <= j - 1) or (CParser.RunID <> ctknull) do
              begin
                // NewName = '' 表示是个函数，做函数的处理
                if NewName = '' then
                begin
                  // If we found a brace pair then special handling is necessary
                  // for the bracecounting stuff (it is off by one)
                  if CParser.RunID = ctkbracepair then
                    BraceCountDelta := 0
                  else
                    BraceCountDelta := 1;

                  if (BraceCountDelta > 0) and (PreviousBraceCount >= BraceCount) then
                    EraseName(NameList, PreviousBraceCount);
                  // Back up a tiny bit so that we are "in front of" the
                  // ctkbraceopen or ctkbracepair we just found
                  CParser.Previous;

                  // 去找上一个分号，作为本函数的起始
                  // 这个 while 可跨过函数中的冒号，如 __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
                  while not ((CParser.RunID in [ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair]) or
                      (CParser.RunID in IdentDirect) or
                    (CParser.RunIndex = 0)) do
                  begin
                    CParser.PreviousNonJunk;
                    // Handle the case where a colon is part of a valid procedure definition
                    if CParser.RunID = ctkcolon then
                    begin
                      // A colon is valid in a procedure definition only if it is immediately
                      // following a close parenthesis (possibly separated by "junk")
                      CParser.PreviousNonJunk;
                      if CParser.RunID in [ctkroundclose, ctkroundpair] then
                        CParser.NextNonJunk
                      else
                      begin
                        // Restore position and stop backtracking
                        CParser.NextNonJunk;
                        Break;
                      end;
                    end;
                  end;

                  // 找到了往前的一个分号或空白地方，往后一点即是函数开头
                  if CParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair] then
                    CParser.NextNonComment
                  else if CParser.RunIndex = 0 then
                  begin
                    if CParser.IsJunk then
                      CParser.NextNonJunk;
                  end
                  else // IdentDirect
                  begin
                    while CParser.RunID <> ctkcrlf do
                    begin
                      if (CParser.RunID = ctknull) then
                        Exit;
                      CParser.Next;
                    end;
                    CParser.NextNonJunk;
                  end;

                  // 所以到达了一个具体的函数开头
                  BeginProcHeaderPosition := CParser.RunPosition;

                  ProcLine := '';
                  while (CParser.RunPosition < BeginBracePosition) and
                    (CParser.RunID <> ctkcolon) do
                  begin
                    if (CParser.RunID = ctknull) then
                      Exit
                    else if (CParser.RunID <> ctkcrlf) then
                      if (CParser.RunID = ctkspace) and (CParser.RunToken = #9) then
                        ProcLine := ProcLine + #32
                      else
                        ProcLine := ProcLine + CParser.RunToken;
                    CParser.NextNonComment;
                  end;
                  // We are at the end of a procedure header
                  // Go back and skip parenthesis to find the procedure name
                  ProcName := '';
                  OwnerClass := '';
                  ProcReturnType := '';
                  ProcArgs := SearchForProcedureName;
                  // We have to check for ctknull and exit since we moved the
                  // code to a nested procedure (if we exit SearchForProcedureName
                  // early due to RunID = ctknull we exit this procedure early as well)
                  if CParser.RunID = ctknull then
                    Exit;
                  if CParser.RunID = ctkthrow then
                  begin
                    ProcArgs := CParser.RunToken + ProcArgs;
                    ProcArgs := SearchForProcedureName + ProcArgs;
                  end;
                  // Since we've enabled nested procedures it is now possible
                  // that we think we've found a procedure but what we've really found
                  // is a standard C or C++ construct (like if or for, etc...)
                  // To guard against this we require that our procedures be of type
                  // ctkidentifier.  If not, then skip this step.
                  CParser.PreviousNonJunk;
                  PrevIsOperator := CParser.RunID = ctkoperator;
                  CParser.NextNonJunk;
                  // 记录前一个是否是关键字 operator
                  if ((CParser.RunID = ctkidentifier) or (PrevIsOperator)) and not
                    InProcedureBlacklist(CParser.RunToken) then
                  begin
                    BeginIndex := CParser.RunPosition;
                    if PrevIsOperator then
                      ProcName := 'operator ';
                    ProcName := ProcName + CParser.RunToken;
                    LineNo := CParser.PositionAtLine(CParser.RunPosition);
                    CParser.PreviousNonJunk;
                    if CParser.RunID = ctkcoloncolon then
                    // The object/method delimiter
                    begin
                      // There may be multiple name::name::name:: sets here
                      // so loop until no more are found
                      ClassName := '';
                      while CParser.RunID = ctkcoloncolon do
                      begin
                        CParser.PreviousNonJunk; // The object name?
                        // It is possible that we are looking at a templatized class and
                        // what we have in front of the :: is the end of a specialization:
                        // ClassName<x, y, z>::Function
                        if CParser.RunID = ctkGreater then
                          TemplateArgs := SearchForTemplateArgs;
                        OwnerClass := CParser.RunToken + OwnerClass;
                        if ClassName = '' then
                          ClassName := CParser.RunToken;
                        CParser.PreviousNonJunk; // look for another ::
                        if CParser.RunID = ctkcoloncolon then
                          OwnerClass := CParser.RunToken + OwnerClass;
                      end;
                      // We went back one step too far so go ahead one
                      CParser.NextNonJunk;
                      ElementTypeStr := 'procedure';
                      ElementType := etClassFunc;  // Class
                      if ProcName = ClassName then
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end
                      else if ProcName = '~' + ClassName then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end;
                    end
                    else
                    begin
                      ElementTypeStr := 'procedure';
                      ElementType := etSingleFunction; // Single function
                      // If type is a procedure is 1 then we have backed up too far already
                      // so restore our previous position in order to correctly
                      // get the return type information for non-class methods
                      CParser.NextNonJunk;
                    end;

                    while CParser.RunPosition > BeginProcHeaderPosition do
                    begin // Find the return type of the procedure
                      CParser.PreviousNonComment;
                      // Handle the possibility of template specifications and
                      // do not include them in the return type
                      if CParser.RunID = ctkGreater then
                        TemplateArgs := SearchForTemplateArgs;
                      if CParser.RunID in [ctktemplate, ctkoperator] then
                        Continue;
                      if CParser.RunID in [ctkcrlf, ctkspace] then
                        ProcReturnType := ' ' + ProcReturnType
                      else
                      begin
                        ProcReturnType := CParser.RunToken + ProcReturnType;
                        BeginIndex := CParser.RunPosition;
                      end;
                    end;
                    // If the return type is an empty string then it must be a constructor
                    // or a destructor (depending on the presence of a ~ in the name
                    if (Trim(ProcReturnType) = '') or (Trim(ProcReturnType) = 'virtual') then
                    begin
                      if Pos('~', ProcName) = 1 then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end
                      else
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end;
                    end;

                    ProcLine := Trim(ProcReturnType) + ' ';

                    // This code sticks enclosure names in front of
                    // methods (namespaces & classes with in-line definitions)
                    ProcClassAdd := '';
                    for k := 0 to BraceCount - BraceCountDelta do
                    begin
                      if k < NameList.Count then
                      begin
                        TmpName := NameList.Values[IntToStr(k)];
                        if TmpName <> '' then
                        begin
                          if ProcClassAdd <> '' then
                            ProcClassAdd := ProcClassAdd + '::';
                          ProcClassAdd := ProcClassAdd + TmpName;
                        end;
                      end;
                    end;

                    if Length(ProcClassAdd) > 0 then
                    begin
                      if Length(OwnerClass) > 0 then
                        ProcClassAdd := ProcClassAdd + '::';
                      OwnerClass := ProcClassAdd + OwnerClass;
                    end;
                    if Length(OwnerClass) > 0 then
                      ProcLine := ProcLine + ' ' + OwnerClass + '::';
                    ProcLine := ProcLine + ProcName + ' ' + ProcArgs;

                    if ElementTypeStr = 'procedure' then
                    begin
                      if (Pos('static ', Trim(ProcReturnType)) = 1) and
                        (Length(OwnerClass) > 0) then
                      begin
                        if Pos('void', ProcReturnType) > 0 then
                          ElementTypeStr := 'class procedure'
                        else
                          ElementTypeStr := 'class function'
                      end
                      else if not Pos('void', ProcReturnType) > 0 then
                        ElementTypeStr := 'function';
                    end;

                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := ProcLine;
                    ElementInfo.ElementTypeStr := ElementTypeStr;
                    ElementInfo.LineNo := LineNo;
                    ElementInfo.OwnerClass := OwnerClass;
                    ElementInfo.ProcArgs := ProcArgs;
                    ElementInfo.ProcReturnType := ProcReturnType;
                    ElementInfo.ElementType := ElementType;
                    ElementInfo.ProcName := ProcName;
                    ElementInfo.FileName := ExtractFileName(aFileName);
                    ElementInfo.AllName := aFileName;
                    AddProcedure(ElementInfo, False); // TODO: BCB Interface

                    while (CParser.RunPosition < BeginBracePosition) do
                      CParser.Next;

                    ElementInfo.BeginIndex := BeginIndex;
                    FindEndingBrace(BraceCountDelta, (BraceCount > 1));
                    ElementInfo.EndIndex := CParser.RunPosition + 1;
                  end
                  else
                    while (CParser.RunPosition < BeginBracePosition) do
                      CParser.Next;
                end
                else
                begin
                  // 找到的是类名，加入处理
                  if ElementType <> etUnknown then
                  begin
                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := NewName;
                    ElementInfo.DisplayName := NewName; // 显示用的
                    ElementInfo.ProcName := NewName; // ProcName 是搜索用的
                    if ElementType = etClass then
                      ElementInfo.OwnerClass := NewName;
                    
                    ElementInfo.ElementType := ElementType;
                    if ClassNamePosition > 0 then
                      ElementInfo.LineNo := CParser.PositionAtLine(ClassNamePosition);

                    case ElementType of
                      etClass: ElementInfo.ElementTypeStr := 'class';
                      etRecord: ElementInfo.ElementTypeStr := 'struct';
                      etNamespace: ElementInfo.ElementTypeStr := 'namespace';
                    end;
                    ElementInfo.FileName := ExtractFileName(aFileName);
                    ElementInfo.AllName := aFileName;
                    AddProcedure(ElementInfo, False);
                  end;

                  EraseName(NameList, BraceCount);
                  NameList.Add(IntToStr(BraceCount) + '=' + NewName);
                end;
                PreviousBraceCount := BraceCount;
                FindBeginningProcedureBrace(NewName, ElementType);
              end; // while (RunPosition <= j-1)
            finally
              FreeAndNil(NameList);
              FreeAndNil(BraceStack);
            end;
          end; //Cpp
      end; //case Language
    finally
      FElementList.EndUpdate;
    end;
  end;

begin
  case FLanguage of
    ltPas: Parser := TmwPasLex.Create;
    ltCpp: CParser := TBCBTokenList.Create;
  end;

  if FIsCurrentFile and (FLanguage = ltPas) then
    FCurElement := EdtGetProcName
  else
    FCurElement := '';

  try
    MemStream := TMemoryStream.Create;
    try
      with TCnEditFiler.Create(aFileName) do
      try
        SaveToStream(MemStream, True);
      finally
        Free;
      end;

      case FLanguage of
        ltPas: Parser.Origin := MemStream.Memory;
        ltCpp: CParser.SetOrigin(MemStream.Memory, MemStream.Size);
      end;

      if ToClear and (ProcListForm <> nil) then
        ProcListForm.Caption := FOldCaption + ' - ' + ExtractFileName(aFileName);

      Screen.Cursor := crHourGlass;
      try
        if ProcListForm <> nil then
          ProcListForm.ClearObjectStrings;
        try
          if ToClear then
          begin
            for I := FElementList.Count - 1 downto 0 do
              if FElementList.Objects[I] <> nil then
                TCnElementInfo(FElementList.Objects[I]).Free;

            FElementList.Clear;
          end;

          FindElements(IsDpr(aFileName) or IsInc(aFileName));
        finally
          if ProcListForm <> nil then
           ProcListForm.LoadObjectComboBox;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
      if ProcListForm <> nil then
        ProcListForm.StatusBar.Panels[1].Text := Trim(IntToStr(ProcListForm.lvList.Items.Count));
    finally
      MemStream.Free;
    end;
  finally
    case FLanguage of
      ltPas: Parser.Free;
      ltCpp: CParser.Free;
    end;
    Parser := nil;
    CParser := nil;
  end;
end;

procedure TCnProcListForm.LoadSettings(Ini: TCustomIniFile;
  aSection: string);
var
  S: string;
  I: Integer;
begin
  inherited;
  S := Ini.ReadString(aSection, csDropDown, '');
  S := StringReplace(S, csSep, csCRLF, [rfReplaceAll, rfIgnoreCase]);
  cbbMatchSearch.Items.Text := S;
  if cbbMatchSearch.Items.Count > Wizard.HistoryCount then
    for I := cbbMatchSearch.Items.Count - 1 downto Wizard.HistoryCount do
      cbbMatchSearch.Items.Delete(I);

  btnShowPreview.Down := Ini.ReadBool(aSection, csShowPreview, True);
  FPreviewHeight := Ini.ReadInteger(aSection, csPreviewHeight, 0);

  mmoContent.Visible := btnShowPreview.Down;
  Splitter.Visible := btnShowPreview.Down;
end;

procedure TCnProcListForm.OpenSelect;
var
  ProcInfo: TCnElementInfo;
  Module: IOTAModule;
  SourceEditor: IOTASourceEditor;  
  View: IOTAEditView;
  I: Integer;
begin
  if lvList.Selected <> nil then
  begin
    ProcInfo := lvList.Selected.Data;
    if ProcInfo <> nil then
    begin
      if SelIsCurFile then
      begin
        View := CnOtaGetTopMostEditView;
        if View <> nil then
        begin
          View.Position.GotoLine(ProcInfo.LineNo);
          if ProcInfo.ElementType in [etRecord, etClass, etInterface] then
            View.Position.MoveEOL;
          View.Center(ProcInfo.LineNo, 1);
          View.Paint;
        end;

        if FFiler = nil then
        begin
          FFiler := TCnEditFiler.Create(ProcInfo.AllName);

          FFiler.GotoLine(ProcInfo.LineNo);
          FFiler.ShowSource;
          FFiler.FreeFileData;
        end;
      end
      else
      begin
        // 打开选择的其他文件并定位
        FreeAndNil(FFiler);
        FFiler := TCnEditFiler.Create(ProcInfo.AllName);

        if not CnOtaIsFileOpen(ProcInfo.AllName) then // 文件已经打开
          CnOtaOpenFile(ProcInfo.AllName);

        Module := CnOtaGetModule(ProcInfo.AllName);
        if Module = nil then Exit;
        SourceEditor := CnOtaGetSourceEditorFromModule(Module);
        if SourceEditor = nil then Exit;
        View := CnOtaGetTopMostEditView(SourceEditor);
        if View = nil then Exit;

        View.Position.GotoLine(ProcInfo.LineNo);
        if ProcInfo.ElementType in [etRecord, etClass, etInterface] then
          View.Position.MoveEOL;
        View.Paint;

        FFiler.GotoLine(ProcInfo.LineNo);
        FFiler.ShowSource;
        FFiler.FreeFileData;
      end;

      // 只在此处赋值
      CurrentFile := ProcInfo.AllName;
      ModalResult := mrOk;

      if (cbbMatchSearch.Text <> '') and
        (cbbMatchSearch.Items.IndexOf(cbbMatchSearch.Text) < 0) then
      begin
        if cbbMatchSearch.Items.Count > CnDropDownListCount then
          for I := cbbMatchSearch.Items.Count - 1 downto CnDropDownListCount - 1 do
            cbbMatchSearch.Items.Delete(I);

        cbbMatchSearch.Items.Insert(0, cbbMatchSearch.Text);
      end;
    end;
  end;
end;

procedure TCnProcListForm.SaveSettings(Ini: TCustomIniFile;
  aSection: string);
var
  S: string;
begin
  inherited;
  S := StringReplace(cbbMatchSearch.Items.Text, csCRLF, csSep, [rfReplaceAll, rfIgnoreCase]);
  Ini.WriteString(aSection, csDropDown, S);
  Ini.WriteBool(aSection, csShowPreview, btnShowPreview.Down);
  if FPreviewHeight > 0 then
    Ini.WriteInteger(aSection, csPreviewHeight, FPreviewHeight);
end;

procedure TCnProcListForm.UpdateComboBox;
begin

end;

procedure TCnProcListForm.UpdateListView;
begin
  inherited;
  edtMatchSearch.Text := cbbMatchSearch.Text;
  lvList.Items.Count := FDisplayList.Count;
  lvList.Invalidate;
  if FDisplayList.Count = 0 then
    mmoContent.Clear;
end;

procedure TCnProcListForm.UpdateStatusBar;
const
  CnBeforeLine = 1;
var
  ProcInfo: TCnElementInfo;
  Module: IOTAModule;
  SourceEditor: IOTASourceEditor;
  EditView: IOTAEditView;
  Buffer: IOTAEditBuffer;
  AfterLine: Integer;

  procedure SetMemoSelection;
  var
    L, I: Integer;
{$IFDEF DELPHI2007}
    J, Len: Integer;
{$ENDIF}
  begin
    if mmoContent.Lines.Count > CnBeforeLine then // 有待显示内容
    begin
      L := 0;
      for I := 0 to CnBeforeLine - 1 do
      begin
{$IFDEF DELPHI2007}
        Len := Length(mmoContent.Lines[I]);
        for J := 0 to Length(mmoContent.Lines[I]) - 1 do
        begin
          if Ord(mmoContent.Lines[I][J]) < 128 then
            Inc(Len);
        end;
        Len := Len div 2;
        L := L + Len + 2;
{$ELSE}
        L := L + Length(mmoContent.Lines[I]) + 2;
{$ENDIF}
      end;

      mmoContent.SelStart := L;
      mmoContent.SelLength := Length(mmoContent.Lines[CnBeforeLine]);
    end;
  end;

begin
  ProcInfo := nil;
  if lvList.Selected <> nil then
    ProcInfo := lvList.Selected.Data;

  if ProcInfo <> nil then
  begin
    StatusBar.Panels[0].Text := ProcInfo.Name;
    StatusBar.Panels[1].Text := Format('%d/%d', [lvList.Selected.Index + 1,
      lvList.Items.Count]);
    StatusBar.Panels[2].Text := ProcInfo.FileName;

    if not btnShowPreview.Down then
      Exit;

    AfterLine := Wizard.PreviewLineCount;
    if AfterLine <= 0 then
      AfterLine := 4;

    FSelIsCurFile := ProcInfo.AllName = CurrentFile;
    if not FSelIsCurFile then // 别的打开的文件
    begin
      // 是另一文件，检查此文件是否打开
      if CnOtaIsFileOpen(ProcInfo.AllName) then // 文件已经打开
      begin
        Module := CnOtaGetModule(ProcInfo.AllName);
        if Module <> nil then
        begin
          SourceEditor := CnOtaGetSourceEditorFromModule(Module);
          if SourceEditor <> nil then
          begin
            EditView := CnOtaGetTopMostEditView(SourceEditor);
            if EditView <> nil then
            begin
              Buffer := EditView.GetBuffer;
              if Buffer <> nil then
              begin
                // 此方法不适于未打开的工程源文件
                mmoContent.Lines.Text := CnOtaGetLineText(ProcInfo.LineNo - CnBeforeLine,
                  Buffer, CnBeforeLine + AfterLine);
                SetMemoSelection;
                Exit;
              end;
            end;
          end;
        end;
      end;
      // 文件未打开，不宜先打开
      mmoContent.Lines.Text := SCnProcListErrorPreview;
    end
    else // 还是此文件
    begin
      mmoContent.Lines.Text := CnOtaGetLineText(ProcInfo.LineNo - CnBeforeLine,
        nil, CnBeforeLine + AfterLine);
      SetMemoSelection;
    end;
  end
  else
  begin
    StatusBar.Panels[0].Text := '';
    StatusBar.Panels[1].Text := Format('%d/%d', [0, 0]);
    mmoContent.Clear;
  end;
end;

procedure TCnProcListForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  inherited;

  FFiler.Free;
  ProcListForm := nil;

  for I := 0 to cbbFiles.Items.Count - 1 do
    if cbbFiles.Items.Objects[I] <> nil then
    begin
      TCnFileInfo(cbbFiles.Items.Objects[I]).Free;
      cbbFiles.Items.Objects[I] := nil;
    end;
end;

procedure TCnProcListForm.SetFileName(const Value: string);
begin
  FFileName := Value;
  FIsCurrentFile := False;
  if IsPas(Value) or IsDpr(Value) or IsInc(Value) then
    FLanguage := ltPas
  else
    FLanguage := ltCpp;
end;

procedure TCnProcListForm.ClearObjectStrings;
begin
  FObjStrings.Clear;
  FObjStrings.Add(SCnProcListObjsAll);
end;

procedure TCnProcListForm.LoadObjectComboBox;
begin
  cbbProjectList.Items.Assign(FObjStrings);
  cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProcListObjsAll);
end;

procedure TCnProcListForm.DoUpdateListView;
var
  I: Integer;
  ProcName: string;
  ObjName: string;
  MatchStr: string;
  IsObject: Boolean;
  ProcInfo: TCnElementInfo;
  IsObjAll: Boolean;
  IsObjNone: Boolean;
  IsMatchAny: Boolean;
  ToSelInfos: TList;
  ToSelIndex: Integer;

begin
  ObjName := cbbProjectList.Text;
  IsObjAll := SameText(ObjName, SCnProcListObjsAll);
  IsObjNone := SameText(ObjName, SCnProcListObjsNone);
  MatchStr := UpperCase(edtMatchSearch.Text);
  IsMatchAny := MatchAny;

  ToSelIndex := 0;
  ToSelInfos := TList.Create;

  try
    if (MatchStr = '') and IsObjAll then
    begin
      // 此处更新整个 List
      FDisplayList.Clear;
      for I := 0 to FElementList.Count - 1 do
        FDisplayList.AddObject(FElementList[I], FElementList.Objects[I]);
    end
    else
    begin
      FDisplayList.Clear;
      FDisplayList.BeginUpdate;
      try
        for I := 0 to FElementList.Count - 1 do
        begin
          ProcInfo := TCnElementInfo(FElementList.Objects[I]);
          case FLanguage of
            ltPas: ProcName := ProcInfo.DisplayName;
            // 此处 GE 用 Name 参与搜索，会造成多余条目的显示，这儿改正
            ltCpp: ProcName := ProcInfo.OwnerClass;
          end;
          IsObject := Length(ProcInfo.OwnerClass) > 0;

          // Is it the object we want?
          if not IsObjAll then
          begin
            if IsObjNone then
            begin
              if IsObject then // Does it have an object?
                Continue;
              if MatchStr = '' then // If no filter is active, add
              begin
                FDisplayList.AddObject(FElementList[I], FElementList.Objects[I]);
                Continue;
              end;
            end // if/then
            else if not SameText(ObjName, ProcInfo.OwnerClass) then
              Continue;
          end;

          case FLanguage of
            ltPas: ProcName := GetMethodName(ProcName);
            ltCpp: ProcName := ProcInfo.ProcName;
          end;

          if MatchStr = '' then
            FDisplayList.AddObject(FElementList[I], FElementList.Objects[I])
          else
          begin
            if RegExpContainsText(FRegExpr, ProcName, MatchStr, not IsMatchAny) then
            begin
              FDisplayList.AddObject(FElementList[I], FElementList.Objects[I]);
              // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
              if IsMatchAny and (Pos(MatchStr, ProcName) = 1) then
                ToSelInfos.Add(FElementList.Objects[I]);
            end;
          end;
        end;
      finally
        FDisplayList.EndUpdate;
      end;
    end;

    SortDisplayList;
    lvList.Items.Count := FDisplayList.Count;
    lvList.Invalidate;

    // 如有需要选中的首匹配的项则选中，无则选 0，第一项
    if (ToSelInfos.Count > 0) and (FDisplayList.Count > 0) then
    begin
      for I := 0 to FDisplayList.Count - 1 do
      begin
        if ToSelInfos.IndexOf(FDisplayList.Objects[I]) >= 0 then
        begin
          // FDisplayList 中的第一个在 SelUnitInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;

    SelectItemByIndex(ToSelIndex);
  finally
    ToSelInfos.Free;
  end;
  UpdateStatusBar;
end;

procedure TCnProcListWizard.AddElement(ElementInfo: TCnElementInfo);
begin
  FElementList.AddObject(#9 + ElementInfo.DisplayName + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
end;

procedure TCnProcListWizard.AddProcedure(ElementInfo: TCnElementInfo; IsIntf: Boolean);
var
  TempStr: string;
  i: Integer;
begin
  ElementInfo.Name := CompressWhiteSpace(ElementInfo.Name);
  case FLanguage of
    ltPas:
      begin
        TempStr := ElementInfo.Name;
        // Remove the class reserved word
        i := Pos('CLASS ', UpperCase(TempStr)); // Do not localize.
        if i = 1 then
          Delete(TempStr, 1, Length('CLASS ')); // Do not localize.
        // Remove 'function' or 'procedure'
        i := Pos(' ', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, i + 1, Length(TempStr));

        // 为 Interfac 的成员声明加上 Interface 名
        if IsIntf and (ElementInfo.OwnerClass <> '') then
          TempStr := ElementInfo.OwnerClass + '.' + TempStr;

        // Remove the paramater list
        i := Pos('(', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, 1, i - 1);
        // Remove the function return type
        i := Pos(':', TempStr);
        if i > 0 then
          TempStr := Copy(TempStr, 1, i - 1);
        // Check for an implementation procedural type
        if Length(TempStr) = 0 then
        begin
          TempStr := '<anonymous>';
        end;
        // Remove any trailing ';'
        if TempStr[Length(TempStr)] = ';' then
          Delete(TempStr, Length(TempStr), 1);
        TempStr := Trim(TempStr);
        if (LowerCase(TempStr) = 'procedure') or (LowerCase(TempStr) = 'function') then
          TempStr := '<anonymous>';

        ElementInfo.DisplayName := TempStr;
        // Add to the object comboBox and set the object name in ElementInfo
        if Pos('.', TempStr) = 0 then
        begin
          FObjStrings.Add(SCnProcListObjsNone);
          if IsIntf and (ElementInfo.OwnerClass <> '') then
            FObjStrings.Add(ElementInfo.OwnerClass);
        end
        else
        begin
          ElementInfo.OwnerClass := Copy(TempStr, 1, Pos('.', TempStr) - 1);
          FObjStrings.Add(ElementInfo.OwnerClass);
        end;
        FElementList.AddObject(#9 + TempStr + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
      end; //ltPas

    ltCpp:
      begin
        if not (ElementInfo.ElementType in [etClass, etRecord, etNamespace]) then
        begin
          // 只对函数类型的才如此处理
          if Length(ElementInfo.OwnerClass) > 0 then
            ElementInfo.DisplayName := ElementInfo.OwnerClass + '::';

          ElementInfo.DisplayName := ElementInfo.DisplayName + ElementInfo.ProcName;
        end;

        FElementList.AddObject(#9 + ElementInfo.DisplayName + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
        if Length(ElementInfo.OwnerClass) = 0 then
          FObjStrings.Add(SCnProcListObjsNone)
        else
          FObjStrings.Add(ElementInfo.OwnerClass);
      end; //ltCpp
  end; //case Language
end;

function TCnProcListForm.SelectImageIndex(ProcInfo: TCnElementInfo): Integer;
var
  ProcName: string;
begin
  // 返回图标编号
  Result := 20;
  if ProcInfo = nil then Exit;

  case FLanguage of
  ltPas:
    begin
      ProcName := UpperCase(ProcInfo.Name);
      if Pos('.', ProcName) <> 0 then
        Result := 41    // 方法
      else
        Result := 20;   // 独立
      if Pos('CONSTRUCTOR', ProcName) <> 0 then // Do not localize.
        Result := 12;   // 构造
      if Pos('DESTRUCTOR', ProcName) <> 0 then // Do not localize.
        Result := 31;   // 析构

      case ProcInfo.ElementType of
        etClass:     Result := 90;
        etRecord:    Result := 36;
        etInterface: Result := 91;
        etProperty : Result := 92;
      else
        // nochange;
      end;
    end;
  ltCpp:
    begin
      case ProcInfo.ElementType of
        etClassFunc:      Result := 41;   // 方法
        etSingleFunction: Result := 20;   // 独立
        etConstructor:    Result := 12;   // 构造
        etDestructor:     Result := 31;   // 析构
        etClass:          Result := 90;
        etInterface:      Result := 91;
        etProperty :      Result := 92;
        etRecord:         Result := 36;
      end;
    end;
  end;
end;

function TCnProcListForm.GetMethodName(const ProcName: string): string;
var
  CharPos: Integer;
  TempStr: string;
begin
  Result := ProcName;
  if Pos('.', Result) = 1 then
    Delete(Result, 1, 1);

  CharPos := Pos(#9, Result);
  if CharPos <> 0 then
    Delete(Result, CharPos, Length(Result));

  CharPos := Pos(' ', Result);
  TempStr := Copy(Result, CharPos + 1, Length(Result));

  CharPos := Pos('.', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    TempStr := Copy(TempStr, CharPos + 1, Length(TempStr));

  CharPos := Pos('(', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    Result := Copy(TempStr, 1, CharPos - 1);

  Result := Trim(Result);
end;

procedure TCnProcListForm.lvListData(Sender: TObject; Item: TListItem);
var
  ElementInfo: TCnElementInfo;
begin
  if (Item.Index > FDisplayList.Count) then Exit;

  ElementInfo := TCnElementInfo(FDisplayList.Objects[Item.Index]);
  if ElementInfo <> nil then
  begin
    Item.Caption := ElementInfo.DisplayName;
    Item.ImageIndex := SelectImageIndex(ElementInfo);
    Item.SubItems.Add(ElementInfo.ElementTypeStr);
    Item.SubItems.Add(IntToStr(ElementInfo.LineNo));
    Item.SubItems.Add(ElementInfo.FileName);
    RemoveListViewSubImages(Item);
    Item.Data := ElementInfo;
  end;
end;

procedure TCnProcListForm.btnShowPreviewClick(Sender: TObject);
begin
  mmoContent.Visible := btnShowPreview.Down;
  Splitter.Visible := btnShowPreview.Down;
  UpdateStatusBar;
end;

procedure TCnProcListForm.DoLanguageChanged(Sender: TObject);
begin
  ToolBar.ShowCaptions := True;
  ToolBar.ShowCaptions := False;
end;

procedure TCnProcListForm.lvListColumnClick(Sender: TObject;
  Column: TListColumn);
var
  I: Integer;
begin
  inherited;
  // 记录已选择的位置
  if lvList.Selected <> nil then
    FSelInfo := TCnElementInfo(lvList.Selected.Data)
  else
    FSelInfo := nil;

  // 将 FList 按 ColumnIndex 和 Down 排序
  SortDisplayList;
  lvList.Invalidate;

  if FSelInfo = nil then
    Exit;
  // 恢复选择的位置  
  for I := 0 to lvList.Items.Count - 1 do
  begin
    if lvList.Items[I].Data = FSelInfo then
    begin
      lvList.Selected := lvList.Items[I];
      lvList.ItemFocused := lvList.Selected;
      lvList.Selected.MakeVisible(True);
      Exit;
    end;
  end;
end;

function CompareProcs(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  case GSortIndex of
  0:
    begin
      Result := CompareTextPos(GMatchStr, List[Index1], List[Index2]);
    end;
  1:
    begin
      if (List.Objects[Index1] <> nil) and (List.Objects[Index2] <> nil) then
      begin
        Result := CompareText(TCnElementInfo(List.Objects[Index1]).ElementTypeStr,
          TCnElementInfo(List.Objects[Index2]).ElementTypeStr);
      end;
    end;
  2:
    begin
      if (List.Objects[Index1] <> nil) and (List.Objects[Index2] <> nil) then
      begin
        Result := CompareValue(TCnElementInfo(List.Objects[Index1]).LineNo,
          TCnElementInfo(List.Objects[Index2]).LineNo);
      end;
    end;
  3:
    begin
      if (List.Objects[Index1] <> nil) and (List.Objects[Index2] <> nil) then
      begin
        Result := CompareText(TCnElementInfo(List.Objects[Index1]).FileName,
          TCnElementInfo(List.Objects[Index2]).FileName);
      end;
    end;
  else
    Result := CompareValue(Index1, Index2);
  end;

  if GSortDown then
    Result := -Result;
end;

procedure TCnProcListForm.SortDisplayList;
begin
  GSortIndex := SortIndex;
  GSortDown := SortDown;
  if MatchAny then
    GMatchStr := cbbMatchSearch.Text
  else
    GMatchStr := '';
  if (FDisplayList <> nil) and (GSortIndex >= 0) then
    FDisplayList.CustomSort(CompareProcs);
end;

procedure TCnProcListForm.FontChanged(AFont: TFont);
begin
  inherited;
  // mmoContent.Font := AFont;
end;

procedure TCnProcListForm.cbbMatchSearchChange(Sender: TObject);
begin
  if not cbbMatchSearch.DroppedDown then
    UpdateListView;
end;

procedure TCnProcListForm.cbbMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin           
  if cbbMatchSearch.DroppedDown then
  begin
    // 暂时不做啥
  end
  else // 未下拉时按普通处理
  begin
    if not (((Key = VK_F4) and (ssAlt in Shift)) or
      ((Key = VK_DOWN) and (ssAlt in Shift)) or
      (Key in [VK_DELETE, VK_LEFT, VK_RIGHT, VK_HOME, VK_END]) or
      ((Key in [VK_INSERT]) and ((ssShift in Shift) or (ssCtrl in Shift)))) then
    begin
      SendMessage(lvList.Handle, WM_KEYDOWN, Key, 0);
      Key := 0;
    end;
  end;
end;

procedure TCnProcListForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if cbbMatchSearch.DroppedDown then
    UpdateListView
  else if Key = #22 then
  begin
    if cbbMatchSearch.Focused then
    begin
      if Clipboard.HasFormat(CF_TEXT) then
      begin
        SendMessage(cbbMatchSearch.Handle, WM_PASTE, 0, 0);
        cbbMatchSearch.Text := Trim(cbbMatchSearch.Text);
        Key := #0;
      end;  
    end;  
  end
  else
    inherited;
end;

procedure TCnProcListForm.UpdateItemPosition;
var
  I, J: Integer;
  ProcName: string;
  ProcInfo: TCnElementInfo;
begin
  if (FCurElement <> '') and (FCurElement <> SCnUnknownNameResult) then
  begin
    for I := 0 to FElementList.Count - 1 do
    begin
      ProcInfo := TCnElementInfo(FElementList.Objects[I]); // lvList.Items[I].Data);
      if ProcInfo = nil then
        Continue;

      case FLanguage of
        ltPas: ProcName := ProcInfo.DisplayName;
        ltCpp: ProcName := ProcInfo.ProcName;
      end;

      if SameText(FCurElement, ProcName) and (I >= 1) then
      begin
        for J := 0 to lvList.Items.Count - 1 do
        begin
          // TODO: 没考虑嵌套的情况
          if lvList.Items[J].Data =  FElementList.Objects[I - 1] then
          begin
            lvList.Selected := lvList.Items[J];
            lvList.ItemFocused := lvList.Selected;
            lvList.Selected.MakeVisible(True);
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCnProcListForm.cbbFilesDropDown(Sender: TObject);
begin
  if not FFilesGot then
  begin
    LoadFileComboBox;
    FFilesGot := True;
  end;
end;

procedure TCnProcListForm.InitFileComboBox;
begin
  cbbFiles.Items.Clear;
  cbbFiles.Items.Add(SCnProcListCurrentFile);
  cbbFiles.Items.Add(SCnProcListAllFileInProject);
  cbbFiles.Items.Add(SCnProcListAllFileInProjectGroup);
  cbbFiles.Items.Add(SCnProcListAllFileOpened);
  cbbFiles.ItemIndex := 0;
end;

procedure TCnProcListForm.LoadFileComboBox;
var
  I, J: Integer;
  ModuleInfo: IOTAModuleInfo;
  Project: IOTAProject;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
  ProjectInterfaceList: TInterfaceList;

  procedure AddAFileToComboBox(aFile, aProject: string);
  var
    FileInfo: TCnFileInfo;
  begin
    if aFile = '' then Exit;

    if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
      or IsTypeLibrary(aFile) or IsInc(aFile) then
    begin
      FileInfo := TCnFileInfo.Create;
      FileInfo.ProjectName := aProject;
      FileInfo.FileName := ExtractFileName(aFile);
      FileInfo.AllName := aFile;

      cbbFiles.Items.AddObject(FileInfo.FileName, FileInfo);
    end;
  end;
begin
  ProjectInterfaceList := TInterfaceList.Create;
  try
    CnOtaGetProjectList(ProjectInterfaceList);
    for I := 0 to ProjectInterfaceList.Count - 1 do
    begin
      Project := IOTAProject(ProjectInterfaceList[I]);
      if Project <> nil then
      begin
{$IFDEF BDS}
        // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
        if Supports(Project, IOTAProjectGroup, ProjectGroup) then
          Continue;
{$ENDIF}
        AddAFileToComboBox(Project.FileName, Project.FileName);
        for J := 0 to Project.GetModuleCount - 1 do
        begin
          ModuleInfo := Project.GetModule(J);
          if ModuleInfo <> nil then
            AddAFileToComboBox(ModuleInfo.FileName, Project.FileName);
        end;
      end;
    end;
  finally
    ProjectInterfaceList.Free;
  end;
end;

procedure TCnProcListForm.cbbFilesChange(Sender: TObject);
var
  I, J: Integer;
  aFile: string;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  ModuleInfo: IOTAModuleInfo;
  ModuleServices: IOTAModuleServices;
  FirstFile: Boolean;
begin
  FirstFile := True;
  if cbbFiles.Items.Objects[cbbFiles.ItemIndex] <> nil then
  begin
    FIsCurrentFile := TCnFileInfo(cbbFiles.Items.Objects[cbbFiles.ItemIndex]).AllName = CurrentFile;
    aFile := TCnFileInfo(cbbFiles.Items.Objects[cbbFiles.ItemIndex]).AllName;
    Wizard.LoadElements(aFile);
  end
  else
  begin
    case cbbFiles.ItemIndex of
    0: // 当前文件
      begin
        FIsCurrentFile := True;
        Wizard.LoadElements(CnOtaGetCurrentSourceFileName);
      end;
    1: // 当前工程
      begin
        FIsCurrentFile := False;
        Project := CnOtaGetCurrentProject;
        if Project <> nil then
        begin
          for I := 0 to Project.GetModuleCount - 1 do
          begin
            ModuleInfo := Project.GetModule(I);
            if ModuleInfo <> nil then
            begin
              aFile := ModuleInfo.FileName;
              if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
                or IsTypeLibrary(aFile) or IsInc(aFile) then
              begin
                Wizard.LoadElements(aFile, FirstFile);
                FirstFile := False;
              end;
            end;
          end;
        end;
      end;
    2: // 当前工程组
      begin
        FIsCurrentFile := False;
        ProjectGroup := CnOtaGetProjectGroup;
        if ProjectGroup <> nil then
        begin
          for J := 0 to ProjectGroup.ProjectCount - 1 do
          begin
            Project := ProjectGroup.Projects[J];
            if Project <> nil then
            begin
              for I := 0 to Project.GetModuleCount - 1 do
              begin
                ModuleInfo := Project.GetModule(I);
                if ModuleInfo <> nil then
                begin
                  aFile := ModuleInfo.FileName;
                  if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
                    or IsTypeLibrary(aFile) or IsInc(aFile) then
                  begin
                    Wizard.LoadElements(aFile, FirstFile);
                    FirstFile := False;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    3: // 所有打开的单元
      begin
        FIsCurrentFile := False;
        QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
        for I := 0 to ModuleServices.GetModuleCount - 1 do
        begin
          aFile := CnOtaGetFileNameOfModule(ModuleServices.GetModule(I));
          if IsDpr(aFile) or IsPas(aFile) or IsCpp(aFile) or IsC(aFile)
            or IsTypeLibrary(aFile) or IsInc(aFile) then
          begin
            Wizard.LoadElements(aFile, FirstFile);
            FirstFile := False;
          end;
        end;
      end;
    end;
  end;

  UpdateListView;
  LoadObjectCombobox;
  UpdateItemPosition;
  UpdateStatusBar;
  cbbMatchSearch.SetFocus;
end;

procedure TCnProcListForm.lvListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_BACK] then
  begin
    //PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      cbbMatchSearch.SetFocus;
    except
      ;
    end;
  end;
end;

procedure TCnProcListForm.lvListKeyPress(Sender: TObject; var Key: Char);
begin
  if CharInSet(Key, ['0'..'9', 'a'..'z', 'A'..'Z']) then
  begin
    PostMessage(edtMatchSearch.Handle, WM_CHAR, Integer(Key), 0);
    try
      cbbMatchSearch.SetFocus;
    except
      ;
    end;
    Key := #0;
  end;
end;

procedure TCnProcListWizard.SetUseEditorToolBar(const Value: Boolean);
begin
  if FUseEditorToolBar <> Value then
  begin
    FUseEditorToolBar := Value;
    EditorToolBarEnable(Active and FUseEditorToolBar);
  end;
end;

procedure TCnProcListWizard.DoIdleComboChange(Sender: TObject);
var
  Info: TCnElementInfo;
  Idx, I: Integer;
begin
  if FComboToSearch = nil then
    Exit;

  Idx := FComboToSearch.DropDownList.ItemIndex;
  if Idx = -1 then
    for I  := 0 to FComboToSearch.DropDownList.Items.Count - 1 do
      if FComboToSearch.DropDownList.Selected[I] then
      begin
        Idx := I;
        Break;
      end;  
      
  if Idx = -1 then
    Idx := FComboToSearch.DropDownList.DisplayItems.IndexOf(FComboToSearch.Text);
  if Idx >= 0 then
  begin
    Info := TCnElementInfo(FComboToSearch.DropDownList.DisplayItems.Objects[Idx]);
    CurrentGotoLineAndFocusEditControl(Info);
  end;
  FComboToSearch := nil;
end;

procedure TCnProcListWizard.CurrentGotoLineAndFocusEditControl(
  Info: TCnElementInfo);
var
  View: IOTAEditView;
  EditControl: TControl;
begin
  if Info = nil then Exit;

  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.Position.GotoLine(Info.LineNo);
    if Info.ElementType in [etRecord, etInterface, etClass] then
      View.Position.MoveEOL;
    View.Center(Info.LineNo, 1);
    View.Paint;

    EditControl := GetCurrentEditControl;
    if (EditControl <> nil) and (EditControl is TWinControl) then
    try
      (EditControl as TWinControl).SetFocus;
    except
      ;
    end;
  end;
end;

procedure TCnProcListWizard.CurrentGotoLineAndFocusEditControl(Line: Integer);
var
  View: IOTAEditView;
  EditControl: TControl;
begin
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.Position.GotoLine(Line);
    View.Center(Line, 1);
    View.Paint;

    EditControl := GetCurrentEditControl;
    if (EditControl <> nil) and (EditControl is TWinControl) then
      (EditControl as TWinControl).SetFocus;
  end;
end;

procedure TCnProcListWizard.PopupCloseItemClick(Sender: TObject);
begin
  InfoDlg(SCnProcListCloseToolBarHint);
  UseEditorToolBar := False;
  DoSaveSettings;
end;

procedure TCnProcListWizard.PopupSubItemSortByClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    GListSortIndex := (Sender as TMenuItem).Tag;
  (Sender as TMenuItem).Checked := True;
  FNeedReParse := True;
end;

procedure TCnProcListWizard.PopupSubItemReverseClick(Sender: TObject);
begin
  GListSortReverse := not GListSortReverse;
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  FNeedReParse := True;
end;

procedure TCnProcListWizard.PopupExportItemClick(Sender: TObject);
var
  List: TStrings;
  Dlg: TSaveDialog;
  I: Integer;
  Info: TCnElementInfo;
begin
  CheckReparse;

  Dlg := nil;
  List := nil;

  try
    Dlg := TSaveDialog.Create(nil);
    Dlg.Filter := 'Text Files(*.txt)|*.txt|All Files(*.*)|*.*';
    if Dlg.Execute then
    begin
      List := TStringList.Create;
      List.Add('Classes:');

      for I := 0 to FElementList.Count - 1 do
      begin
        Info := TCnElementInfo(FElementList.Objects[I]);
        if (Info <> nil) and (Info.ElementType in [etRecord, etClass, etInterface]) then
          List.Add(Info.DisplayName);
      end;

      List.Add('');
      List.Add('Procedures:');
      for I := 0 to FElementList.Count - 1 do
      begin
        Info := TCnElementInfo(FElementList.Objects[I]);
        if (Info <> nil) and (Info.ElementType in [etClassFunc, etSingleFunction,
          etConstructor, etDestructor]) then
          List.Add(Info.DisplayName);
      end;
      List.Add('');

      List.SaveToFile(Dlg.FileName);
    end;
  finally
    List.Free;
    Dlg.Free;
  end;
end;

procedure TCnProcListWizard.EditorToolBarEnable(const Value: Boolean);
begin
  if CnEditorToolBarService <> nil then
  begin
    if Value then
    begin
      if FEditorToolBarType <> '' then
        CnEditorToolBarService.SetVisible(FEditorToolBarType, True)
      else
      begin
        FEditorToolBarType := ClassName;
        CnEditorToolBarService.RegisterToolBarType(FEditorToolBarType,
          CreateProcToolBar, InitProcToolBar, RemoveProcToolBar);
        if FToolBarTimer = nil then
        begin
          FToolBarTimer := TTimer.Create(nil);
          FToolBarTimer.Enabled := False;
          FToolBarTimer.Interval := 500;
          FToolBarTimer.OnTimer := OnToolBarTimer;
        end;
      end;
    end
    else
    begin
      if FEditorToolBarType <> '' then
        CnEditorToolBarService.SetVisible(FEditorToolBarType, False);
    end;
  end
  else
    FUseEditorToolBar := False;
end;

procedure TCnProcListWizard.SetActive(Value: Boolean);
begin
  inherited;
  EditorToolBarEnable(Active and FUseEditorToolBar);
end;

procedure TCnProcListForm.SplitterMoved(Sender: TObject);
begin
  FPreviewHeight := mmoContent.Height;
end;

procedure TCnProcListForm.UpdateMemoHeight(Sender: TObject);
const
  csStep = 5;
var
  I, Steps, Distance: Integer;
begin
  if FPreviewHeight > 0 then
  begin
    Distance := mmoContent.Height - FPreviewHeight;
    Steps := Abs(Distance div csStep);
    if Distance > 0 then
      for I := 1 to Steps do
        mmoContent.Height := mmoContent.Height - csStep
    else
      for I := 1 to Steps do
        mmoContent.Height := mmoContent.Height + csStep;
   end;
end;

procedure TCnProcDropDownBox.ListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  AText: string;
  Idx, X: Integer;
  S: string;
  SaveColor: TColor;
  Info: TCnElementInfo;

  function GetListImageIndex(Info: TCnElementInfo): Integer;
  begin
    case Info.ElementType of
      etClassFunc:      Result := 41;   // 方法
      etSingleFunction: Result := 20;   // 独立
      etConstructor:    Result := 12;   // 构造
      etDestructor:     Result := 31;   // 析构
      etClass:          Result := 90;
      etInterface:      Result := 91;
      etProperty :      Result := 92;
      etRecord:         Result := 36;
    else
      Result := 20;
    end;
  end;
begin
  if Index >= FDisplayItems.Count then
    Exit;

  // 自画ListBox中的 List
  with Control as TCnProcDropDownBox do
  begin
    Canvas.Font := Font;
    if odSelected in State then
    begin
      Canvas.Font.Color := clHighlightText;
      Canvas.Brush.Color := clHighlight;
    end
    else
    begin
      Canvas.Brush.Color := clWindow;
      Canvas.Font.Color := clWindowText;
    end;

    Info := TCnElementInfo(FDisplayItems.Objects[Index]);
    Canvas.FillRect(Rect);
    dmCnSharedImages.Images.Draw(Canvas, Rect.Left + 2, Rect.Top,
      GetListImageIndex(Info));
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := [fsBold];

    AText := FDisplayItems[Index];
    if MatchStr <> '' then
    begin
      // 高亮显示匹配的内容
      Idx := Pos(UpperCase(MatchStr), UpperCase(AText));
      if Idx > 0 then
      begin
        SaveColor := Canvas.Font.Color;
        X := Rect.Left + 22;
        if Idx > 1 then
        begin
          S := Copy(AText, 1, Idx - 1);
          Canvas.TextOut(X, Rect.Top, S);
          Inc(X, Canvas.TextWidth(S));
        end;
        Canvas.Font.Color := clRed;
        S := Copy(AText, Idx, Length(MatchStr));
        Canvas.TextOut(X, Rect.Top, S);
        Inc(X, Canvas.TextWidth(S));
        Canvas.Font.Color := SaveColor;
        S := Copy(AText, Idx + Length(MatchStr), MaxInt);
        Canvas.TextOut(X, Rect.Top, S);
      end
      else
        Canvas.TextOut(Rect.Left + 22, Rect.Top, AText);
    end
    else
      Canvas.TextOut(Rect.Left + 22, Rect.Top, AText);
  end;
end;

//==============================================================================
// 查找下拉列表框
//==============================================================================

{ TCnProcDrowDownBox }

function TCnProcDropDownBox.AdjustHeight(AHeight: Integer): Integer;
var
  BorderSize: Integer;
begin
  BorderSize := Height - ClientHeight;
  Result := Max((AHeight - BorderSize) div ItemHeight, 4) * ItemHeight + BorderSize;
end;

function TCnProcDropDownBox.CanResize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
  NewHeight := AdjustHeight(NewHeight);
  Result := True;
end;

procedure TCnProcDropDownBox.CloseUp;
begin
  if Visible then
  begin
    Visible := False;
    SavePosition;
  end;
end;

procedure TCnProcDropDownBox.SavePosition;
begin
  if (FWizard <> nil) and (Owner <> nil) then
  begin
    if Owner.Name = csProcComboName then
    begin
      FWizard.ProcComboHeight := Height;
      FWizard.ProcComboWidth := Width;
    end
    else if Owner.Name = csClassComboName then
    begin
      FWizard.ClassComboHeight := Height;
      FWizard.ClassComboWidth := Width;
    end;
  end;
end;

procedure TCnProcDropDownBox.CMHintShow(var Message: TMessage);
var
  Index: Integer;
  P: TPoint;
  S: string;
begin
  Message.Result := 1;
  if Assigned(FOnItemHint) and GetCursorPos(P) then
  begin
    P := ScreenToClient(P);
    Index := ItemAtPos(P, True);
    if Index >= 0 then
    begin
      FOnItemHint(Self, Index, S);
      if S <> '' then
      begin
        TCMHintShow(Message).HintInfo^.HintStr := S;
        Message.Result := 0;
      end;
    end;
  end;
end;

procedure TCnProcDropDownBox.CNCancelMode(var Message: TMessage);
begin
  CloseUp;
end;

procedure TCnProcDropDownBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    State := TOwnerDrawState(LongRec(itemState).Lo);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText
    end;
    if Integer(itemID) >= 0 then
    begin
      if Assigned(OnDrawItem) then
        OnDrawItem(Self, itemID, rcItem, State);
    end
    else
      Canvas.FillRect(rcItem);
    Canvas.Handle := 0;
  end;
end;

procedure TCnProcDropDownBox.CNMeasureItem(var Message: TWMMeasureItem);
begin
  with Message.MeasureItemStruct^ do
  begin
    itemHeight := Self.ItemHeight;
  end;
end;

constructor TCnProcDropDownBox.Create(AOwner: TComponent);
const
  csMinDispItems = 6;
  csDefDispItems = 12;
  csMinDispWidth = 450;
  csDefDispWidth = 300;
begin
  inherited;
  Visible := False;
  Style := lbOwnerDrawFixed;
  DoubleBuffered := True;
  Constraints.MinHeight := ItemHeight * csMinDispItems + 4;
  Constraints.MinWidth := csMinDispWidth;
  Height := ItemHeight * csDefDispItems + 8;
  Width := csDefDispWidth;
  ShowHint := True;
  Font.Name := 'Tahoma';
  Font.Size := 8;
  FLastItem := -1;

  FDisplayItems := TStringList.Create;
  FInfoItems := TStringList.Create;
  OnDrawItem := ListDrawItem;

  FRegExpr := TRegExpr.Create;
  FRegExpr.ModifierI := True;
end;

procedure TCnProcDropDownBox.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $20000;
begin
  inherited;
  Params.Style := (Params.Style or WS_CHILDWINDOW or WS_SIZEBOX or WS_MAXIMIZEBOX
    or LBS_NODATA or LBS_OWNERDRAWFIXED) and not (LBS_SORT or LBS_HASSTRINGS);
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnProcDropDownBox.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
  Height := AdjustHeight(Height);
end;

destructor TCnProcDropDownBox.Destroy;
begin
  FRegExpr.Free;
  FDisplayItems.Free;
  FInfoItems.Free;
  inherited;
end;

procedure TCnProcDropDownBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  inherited;
  if Shift = [] then
  begin
    Index := ItemAtPos(Point(X, Y), True);
    if Index <> FLastItem then
    begin
      FLastItem := Index;
      Application.CancelHint;
      if Index >= 0 then
      begin
        try
          Selected[Index] := True;
        except
          // 上句 D5 下会出错，怪事。
          try
            ItemIndex := Index;
          except
            ;
          end;
        end;
        Application.ActivateHint(ClientToScreen(Point(X, Y)));
      end;
    end;
  end;
end;

procedure TCnProcDropDownBox.Popup;
begin
  Visible := True;
end;

procedure TCnProcDropDownBox.SetCount(const Value: Integer);
var
  Error: Integer;
begin
{$IFDEF DEBUG}
  if Value <> 0 then
    CnDebugger.LogInteger(Value, 'TCnProcDrowDownBox.SetCount');
{$ENDIF}
  // Limited to 32767 on Win95/98 as per Win32 SDK
  Error := SendMessage(Handle, LB_SETCOUNT, Min(Value, 32767), 0);
  if (Error = LB_ERR) or (Error = LB_ERRSPACE) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('TCnProcDrowDownBox.SetCount Error: ' + IntToStr(Error), cmtError);
  {$ENDIF}
  end;
end;

procedure TCnProcDropDownBox.SetPos(X, Y: Integer);
begin
  SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);  
end;

{ TCnProcListComboBox }

procedure TCnProcListComboBox.Change;
var
  Obj: TCnProcToolBarObj;
  OldSel, OldSelLength: Integer;
begin
  inherited;
  if FDisableChange then Exit;

  OldSel := SelStart;
  OldSelLength := SelLength;

  if Text = '' then
  begin
    FDropDownList.Hide;
    FDropDownList.SavePosition;
    Exit;
  end;

  if not FDropDownList.Visible then
  begin
    FChangeDown := True;
    if Assigned(OnButtonClick) then // 手工下拉前，触发下拉事件
      OnButtonClick(Self);
    FChangeDown := False;
  end;

  FDropDownList.MatchStr := Text;
  Obj := FWizard.GetCurrentToolBarObj;
  if (Obj <> nil) and (Obj.EditorToolBar <> nil) then
    FDropDownList.MatchStart := Obj.ToolBtnMatchStart.Down
  else
    FDropDownList.MatchStart := False;

  FDropDownList.UpdateDisplay;
  if not FDropDownList.Visible then
    ShowDropBox;

  SelStart := OldSel;
  SelLength := OldSelLength;
end;

procedure TCnProcListComboBox.CNKeyDown(var Message: TWMKeyDown);
var
  AShortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Message.KeyData);
  AShortCut := ShortCut(Message.CharCode, ShiftState);
  Message.Result := 1;
  if not HandleEditShortCut(Self, AShortCut) then
    inherited;
end;

procedure TCnProcListComboBox.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = WM_KILLFOCUS then
  begin
    if FDropDownList.Visible then
    begin
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end;
    Message.Result := 0;
  end;
end;

constructor TCnProcListComboBox.Create(AOwner: TComponent);
begin
  inherited;
  LinkStyle := lsDropDown;
  FDropDownList := TCnProcDropDownBox.Create(Self);
  FDropDownList.Name := 'DropDownList';
  FDropDownList.Parent := Application.MainForm;
  FDropDownList.OnDblClick := DropDownListDblClick;
  FDropDownList.OnClick := DropDownListClick;

  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
end;

destructor TCnProcListComboBox.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  inherited;
end;

procedure TCnProcListComboBox.RefreshDropBox(Sender: TObject);
begin
  FDropDownList.Invalidate;
end;

procedure TCnProcListComboBox.DropDownListDblClick(Sender: TObject);
begin
  PostMessage(Handle, WM_KEYDOWN, VK_RETURN, 0);
end;

procedure TCnProcListComboBox.DropDownListClick(Sender: TObject);
begin
  if FDropDownList.FDisableClickFlag then
  begin
    FDropDownList.FDisableClickFlag := False;
    Exit;
  end;
  
  if FDropDownList.ItemIndex >= 0 then
    PostMessage(Handle, WM_KEYDOWN, VK_RETURN, 0);
end;

procedure TCnProcListComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
  begin
    if FDropDownList.Visible then
    begin
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end;
    Key := 0;
  end
  else if (Key = VK_RETURN) and (Shift = []) then
  begin
    // 无则下拉，已下拉则定位
    if FDropDownList.Visible then
    begin
      FWizard.FComboToSearch := Self;
      CnWizNotifierServices.ExecuteOnApplicationIdle(FWizard.DoIdleComboChange);
      FDropDownList.Hide;
      FDropDownList.SavePosition;
    end
    else
    begin
      CnWizNotifierServices.ExecuteOnApplicationIdle(RefreshDropBox);
    end;
    Key := 0;
  end
  else if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT] then
  begin
    FDropDownList.FDisableClickFlag := True; 
    PostMessage(FDropDownList.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
  end;
  inherited;
end;

procedure TCnProcListComboBox.KeyPress(var Key: Char);
begin
  if Key = #13 then
    Key := #0;
  inherited;
end;  

procedure TCnProcDropDownBox.UpdateDisplay;
var
  I, HeightCount, AHeight: Integer;
  HeightSet: Boolean;
begin
  FDisplayItems.Clear;
  for I := 0 to FInfoItems.Count - 1 do
    if RegExpContainsText(FRegExpr, FInfoItems[I], FMatchStr, FMatchStart) then
      FDisplayItems.AddObject(FInfoItems[I], FInfoItems.Objects[I]);

  SetCount(FDisplayItems.Count);
  if FDisplayItems.Count > 12 then
    HeightCount := 12
  else if FDisplayItems.Count < 6 then
    HeightCount := 6
  else
    HeightCount := FDisplayItems.Count;

  AHeight := ItemHeight * HeightCount + 8;
  HeightSet := False;

  if (FWizard <> nil) and (Owner <> nil) then
  begin
    if Owner.Name = csProcComboName then
    begin
      if FWizard.ProcComboWidth > 100 then
        Width := FWizard.ProcComboWidth;
      if FWizard.ProcComboHeight > AHeight then
      begin
        Height := FWizard.ProcComboHeight;
        HeightSet := True;
      end;
    end
    else if Owner.Name = csClassComboName then
    begin
      if FWizard.ClassComboWidth > 100 then
        Width := FWizard.ClassComboWidth;
      if FWizard.ClassComboHeight > AHeight then
      begin
        Height := FWizard.ClassComboHeight;
        HeightSet := True;
      end;
    end;
  end;

  if not HeightSet then
    Height := AHeight;

  if FDisplayItems.Count > 0 then
  begin
    FDisableClickFlag := True;
    PostMessage(Handle, WM_KEYDOWN, VK_DOWN, 0); // 选中首条
  end;
end;

procedure TCnProcDropDownBox.SetMatchStart(const Value: Boolean);
begin
  FMatchStart := Value;
end;

procedure TCnProcListComboBox.ShowDropBox;
begin
  UpdateDropPosition;
  FDropDownList.Popup;
end;

procedure TCnProcDropDownBox.SetMatchStr(const Value: string);
begin
  FMatchStr := UpperCase(Value);
end;

procedure TCnProcListComboBox.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
  if (Parent <> nil) and FDropDownList.Visible then
    UpdateDropPosition;
end;

procedure TCnProcListComboBox.UpdateDropPosition;
var
  P: TPoint;
begin
  P.x := Left;
  P.y := Top + Height;
  P := Parent.ClientToScreen(P);
  FDropDownList.SetPos(P.x, P.y);
end;

procedure TCnProcListComboBox.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  case Msg.message of
    WM_MOUSEWHEEL:  // 处理鼠标滚轮事件
      if FDropDownList.Visible then
      begin
        SendMessage(FDropDownList.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
        Handled := True;
        Msg.message := 0;
        Msg.wParam := 0;
        Msg.lParam := 0;
      end;
    { 暂时先不处理其他消息导致List关闭的情况
    WM_SYSKEYDOWN, WM_SETFOCUS:
      if FDropDownList.Visible then
        FDropDownList.CloseUp;
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN:
      if (Msg.hwnd <> FDropDownList.Handle) and FDropDownList.Visible then
        FDropDownList.CloseUp;
    }
  end;
end;

procedure TCnProcListComboBox.SetTextWithoutChange(const AText: string);
begin
  FDisableChange := True;
  Text := AText;
  FDisableChange := False;
end;

initialization
  RegisterCnWizard(TCnProcListWizard); // 注册专家

{$ENDIF CNWIZARDS_CNPROCLISTWIZARD}
end.

