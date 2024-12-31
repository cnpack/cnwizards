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

unit CnEditSMRUnit;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：SMR 编辑单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2007.08.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Grids, ADODB,
  Dialogs, Menus, StdCtrls, Buttons, ExtCtrls, DB, DBCtrls, DBGrids, ActnList,
  AppEvnts, CnCommon, CnMainUnit, CnSMRBplUtils, CnBaseUtils, CnSMRUtils, CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnEditSMRForm = class(TForm, IUIInitializable)
    lblOpenedFile: TLabel;
    gpAnalyse: TPanel;
    pnlAffectModules: TPanel;
    Label1: TLabel;
    pnlSourceFiles: TPanel;
    Label3: TLabel;
    Label9: TLabel;
    edtSearchFile: TEdit;
    sbButtons: TScrollBox;
    gpAnalyseBtns: TPanel;
    btnOpenSMR: TBitBtn;
    btnLoadARF: TBitBtn;
    pnlAllAffectModules: TPanel;
    Label2: TLabel;
    sdSaveSMR: TSaveDialog;
    pmOpenSMR: TPopupMenu;
    miOpenSMR: TMenuItem;
    N1: TMenuItem;
    odOpenSMF: TOpenDialog;
    dsMain: TDataSource;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    DBNavigator4: TDBNavigator;
    DBNavigator5: TDBNavigator;
    cdsMain: TADODataSet;
    gdAffects: TStringGrid;
    gdAllAffects: TStringGrid;
    gdFiles: TDBGrid;
    btnFillSelected: TBitBtn;
    btnSaveSMR: TBitBtn;
    miNewSMR: TMenuItem;
    miNewSMRFromDirList: TMenuItem;
    N2: TMenuItem;
    pmOpenARF: TPopupMenu;
    miLoadARF: TMenuItem;
    MenuItem2: TMenuItem;
    odOpenARF: TOpenDialog;
    odOpenDirListFile: TOpenDialog;
    pmFillCDS: TPopupMenu;
    miFillSelectedSMR: TMenuItem;
    miFillAllSMR: TMenuItem;
    miClearARF: TMenuItem;
    N3: TMenuItem;
    miCloseSMR: TMenuItem;
    N4: TMenuItem;
    pnlAffectedModules: TPanel;
    cmbPickList: TComboBox;
    appEventsFixMouseWheelMsg: TApplicationEvents;
    procedure cdsMainAfterCancel(DataSet: TDataSet);
    procedure miCloseSMRClick(Sender: TObject);
    procedure miClearARFClick(Sender: TObject);
    procedure DoProcessKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchFileChange(Sender: TObject);
    procedure edtSearchFileKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cdsMainAfterPost(DataSet: TDataSet);
    procedure pmFillCDSPopup(Sender: TObject);
    procedure miFillSelectedSMRClick(Sender: TObject);
    procedure miFillAllSMRClick(Sender: TObject);
    procedure miLoadARFClick(Sender: TObject);
    procedure miOpenSMRClick(Sender: TObject);
    procedure miNewSMRFromDirListClick(Sender: TObject);
    procedure miNewSMRClick(Sender: TObject);
    procedure cdsMainBeforePost(DataSet: TDataSet);
    procedure cdsMainBeforeScroll(DataSet: TDataSet);
    procedure DoPopupMenuPopup(Sender: TObject);
    procedure DoPopupPopupMenu(Sender: TObject);
    procedure btnSaveSMRClick(Sender: TObject);
    procedure cdsMainAfterScroll(DataSet: TDataSet);
    procedure pnlSourceFilesResize(Sender: TObject);
    procedure pnlAllAffectModulesResize(Sender: TObject);
    procedure pnlAffectModulesResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DoSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure appEventsFixMouseWheelMsgMessage(var Msg: tagMSG;
      var Handled: Boolean);
    procedure gdAffectsTopLeftChanged(Sender: TObject);
    procedure cmbSetCellText(Sender: TObject);
    procedure cmbPickListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FUIUpdating, FActiveControlChanging, FActiveDataSet: Boolean;
    FOpenedSMRFiles, FOpenedARFFiles: TStringList;
    FARFFileName: string;
    FSMRFileName: string;
    FSMRPopupMenuItemCount, FARFPopupMenuItemCount: Integer;
    FAnalyseResults: TPackageInfosList;
    FUnits, FUsedByPackagesList: TStringObjectList;
    FUnitPackages, FAllUnitPackages: TStringList;
    FSMRList: TSMRList;
    FLastSelectedGrid: TStringGrid;
    OldOnScreenActiveControlChange: TNotifyEvent;
    cdsMainFileName: TStringField;
    cdsMainAffectModules: TMemoField;
    cdsMainAllAffectModules: TMemoField;

    procedure SetARFFileName(const Value: string);
    procedure SetSMRFileName(const Value: string);

    function GetSelectSourceUnit: string;
    function GetSourceUnit(const s: string): string;
    function GetASourceAffectModules(const s: string): Boolean;
    function ActiveIsPickControl: Boolean;

    procedure GetAllSourceAffectModules(AffectModules: TStringList);
    procedure GetOpenedFiles(Files: TStrings;
      FileFormat: TAppFileType; AllFiles: Boolean);
    procedure UpdateControlsState;
    procedure ResizeDBGrid;
    procedure PrevBuildMenu(pm: TPopupMenu);
    procedure miOpenSpecifiedSMRFileClick(Sender: TObject);
    procedure miOpenSpecifiedARFFileClick(Sender: TObject);
    procedure LoadSMRFromFile(const s: string);
    procedure LoadARFFromFile(const s: string);
    procedure SyncSMRListWithCDS;
    procedure SyncCDSWithSyncList;
    procedure SyncCDSWithStringGrids;
    procedure SyncStringGridsWithCDS;
    procedure CDSAdd(const sFileName, sModules, sAllModules: string; Check: Boolean = True);
    procedure CDSEdit;
    procedure CDSPost;
    procedure BuildPickList(gd: TStringGrid);
    procedure CMGetFormIndex(var Message: TMessage); message CM_GETFORMINDEX;
    procedure HidePickControl;
    procedure ShowPickControl(ACol, ARow: Integer);
    procedure OnScreenActiveControlChange(Sender: TObject);
    procedure CreateTempDataSet(ds: TADODataSet);
    procedure ActiveDataSet(DoActive: Boolean);
  public
    { Public declarations }
    procedure UIInitialize;
    property SMRFileName: string read FSMRFileName write SetSMRFileName;
    property ARFFileName: string read FARFFileName write SetARFFileName;
  end;

implementation

{$R *.dfm}

const
  DelphiExts: array[0..8] of string =
  ('.PAS', '.DFM', '.DPR', '.DPK', '.DOF', '.CFG'
    , '.RC', '.DRC', '.RES'
    {, '.C', '.CPP' ,'.H', '.HPP', '.BFM', '.BPR', '.BPK'
    , '.XFM', '.NFM'});

function IsDelphiExt(s: string): Boolean; 
var
  i: Integer;
begin
  Result := False;
  for i := Low(DelphiExts) to High(DelphiExts) do
  begin
    if DelphiExts[i] = s then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function FindKeyInCDS(cds: TDataSet; Field: TField; s: string; SearchNext, SkipCurrent: Boolean; MatchProc: TStringMatchFunc): Boolean;
var
  BM: TBookmarkStr;
begin
  Result := False;
  if not (Assigned(cds) and Assigned(Field) and Assigned(MatchProc) and (s <> '')) then
  begin
    Exit;
  end;

  s := AnsiUpperCase(s);
  cds.DisableControls;
  BM := cds.Bookmark;
  try
    if SearchNext then
    begin
      if SkipCurrent and not cds.Eof then
      begin
        cds.Next;
      end;

      while not cds.Eof do
      begin
        if MatchProc(s, Field.AsString) then
        begin
          Result := True;
          Break;
        end;
        cds.Next;
      end;
    end
    else
    begin
      if SkipCurrent and not cds.Bof then
      begin
        cds.Prior;
      end;

      while not cds.Bof do
      begin
        if MatchProc(s, Field.AsString) then
        begin
          Result := True;
          Break;
        end;
        cds.Prior;
      end;
    end;
  finally
    if not Result then
    begin
      cds.Bookmark := BM;
    end;
    cds.EnableControls;
  end;
end;

procedure ClearGrid(gd: TStringGrid);
var
  i, j: Integer;
begin
  if Assigned(gd) then
  begin
    for i := 0 to gd.RowCount - 1 do
    begin
      for j := 0 to gd.ColCount - 1 do
      begin
        gd.Cells[j , i] := '';
      end;
    end;
  end;
end;

function GetGridValues(gd: TStringGrid; ss: TStrings): string;
var
  i: Integer;
  s: string;
begin
  if not (Assigned(gd) and Assigned(ss) and (gd.ColCount > 0)) then
  begin
    Result := '';
    Exit;
  end;

  ss.Clear;
  for i := 0 to gd.RowCount - 1 do
  begin
    s := Trim(gd.Cells[0, i]);
    if s <> '' then
    begin
      ss.Add(s);
    end;
  end;
  Result := ss.CommaText;
end;

procedure FillGrid(gd: TStringGrid; ss: TStrings);
var
  i: Integer;
  OldGetEditText: TGetEditEvent;
  OldSetEditText: TSetEditEvent;
begin
  if not (Assigned(gd) and Assigned(ss) and (gd.ColCount > 0)) then
  begin
    Exit;
  end;

  OldGetEditText := gd.OnGetEditText;
  OldSetEditText := gd.OnSetEditText;
  try
    gd.OnGetEditText := nil;
    gd.OnSetEditText := nil;
    if gd.RowCount < ss.Count then
    begin
      gd.RowCount := ss.Count;
    end;

    ClearGrid(gd);
    for i := 0 to ss.Count - 1 do
    begin
      gd.Cells[0, i] := ss[i];
    end;
  finally
    gd.OnGetEditText := OldGetEditText;
    gd.OnSetEditText := OldSetEditText;
  end;
end;

{ TfEditSMR }

procedure TCnEditSMRForm.DoPopupPopupMenu(Sender: TObject);
var
  Pos: TPoint;
begin
  if (Sender is TButton) and (TButton(Sender).PopupMenu <> nil) then
  begin
    TButton(Sender).PopupMenu.PopupComponent := TButton(Sender);
    Pos := TButton(Sender).ClientToScreen(GetRectCenter(TButton(Sender).ClientRect)); // gpAnalyseBtns.ClientToScreen(GetRectCenter(GetControlRectInGridPanel(TButton(Sender), gpAnalyseBtns)));
    TButton(Sender).PopupMenu.Popup(Pos.X, Pos.Y);
  end;
end;

procedure TCnEditSMRForm.btnSaveSMRClick(Sender: TObject);
begin
  if not cdsMain.Active then
  begin
    Exit;
  end;

  CDSPost;
  sdSaveSMR.FileName := SMRFileName;
  if sdSaveSMR.Execute then
  begin
    SyncSMRListWithCDS;
    FSMRList.SaveToFile(sdSaveSMR.FileName);
    FSMRList.Clear;
  end;
end;

procedure TCnEditSMRForm.cdsMainAfterCancel(DataSet: TDataSet);
begin
  if FActiveDataSet and not cdsMain.ControlsDisabled then
  begin
    UpdateControlsState;
  end;
end;

procedure TCnEditSMRForm.cdsMainAfterPost(DataSet: TDataSet);
begin
  if FActiveDataSet and not cdsMain.ControlsDisabled then
  begin
    if Trim(cdsMainFileName.AsString) = '' then
    begin
      DataSet.Delete;
    end;
    UpdateControlsState;
  end;  
end;

procedure TCnEditSMRForm.cdsMainAfterScroll(DataSet: TDataSet);
begin
  if FActiveDataSet and not cdsMain.ControlsDisabled then
  begin
    ResizeDBGrid;
    UpdateControlsState;
  end;
end;

procedure TCnEditSMRForm.cdsMainBeforePost(DataSet: TDataSet);
begin
  if FActiveDataSet and not cdsMain.ControlsDisabled then
  begin
    SyncCDSWithStringGrids;
  end;
end;

procedure TCnEditSMRForm.cdsMainBeforeScroll(DataSet: TDataSet);
begin
  if FActiveDataSet and not cdsMain.ControlsDisabled then
  begin
    CDSPost;
  end;
end;

function TCnEditSMRForm.GetASourceAffectModules(const s: string): Boolean;
var
  idx: Integer;
begin
  idx := FUnits.IndexOf(s);
  Result := idx >= 0;
  if Result then
  begin
    SetCommaText(FUnits.StringObjects[idx], FUnitPackages);
  end
  else
  begin
    FUnitPackages.Clear;
  end;
end;

procedure TCnEditSMRForm.GetAllSourceAffectModules(
  AffectModules: TStringList);
begin
  FAllUnitPackages.Clear;
  FAnalyseResults.GetAllAffectedPackages(FUsedByPackagesList, AffectModules, FAllUnitPackages);
end;

procedure TCnEditSMRForm.FormCreate(Sender: TObject);
begin
  FSMRList := TSMRList.Create;
  FSMRList.Sorted := True;
  FAnalyseResults := TPackageInfosList.Create;
  FAnalyseResults.Sorted := True;
  FOpenedSMRFiles := TStringList.Create;
  FOpenedSMRFiles.Sorted := True;
  FOpenedARFFiles := TStringList.Create;
  FOpenedARFFiles.Sorted := True;
  FUnitPackages := TStringList.Create;
  FUnitPackages.Sorted := True;
  FAllUnitPackages := TStringList.Create;
  FAllUnitPackages.Sorted := True;
  FUnits := TStringObjectList.Create;
  FUnits.Sorted := True;
  FUsedByPackagesList := TStringObjectList.Create;
  FUsedByPackagesList.Sorted := True;
  SetDlgInitialDir(Self);
  FSMRPopupMenuItemCount := pmOpenSMR.Items.Count;
  FARFPopupMenuItemCount := pmOpenARF.Items.Count;
  OldOnScreenActiveControlChange := Screen.OnActiveControlChange;
  Screen.OnActiveControlChange := OnScreenActiveControlChange;
  UpdateControlsState;
end;

procedure TCnEditSMRForm.FormDestroy(Sender: TObject);
begin
  Screen.OnActiveControlChange := OldOnScreenActiveControlChange;
  ActiveDataSet(False);
  FUsedByPackagesList.Free;
  FUnits.Free;
  FUnitPackages.Free;
  FAllUnitPackages.Free;
  FOpenedSMRFiles.Free;
  FOpenedARFFiles.Free;
  FAnalyseResults.Free;
  FSMRList.Free;
end;

procedure TCnEditSMRForm.DoProcessKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s: string;
begin
  if (Sender is TStringGrid) and (not TStringGrid(Sender).EditorMode)
    and (Key = VK_DELETE) then
  begin
    if [ssCtrl] = Shift then
    begin
      ClearGrid(TStringGrid(Sender));
    end
    else if [ssShift] = Shift then
    begin
      s := TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row];
      ClearGrid(TStringGrid(Sender));
      TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row] := s;
    end
    else
    begin
      TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row] := '';
    end;
    with Sender as TStringGrid do ShowPickControl(Col, Row);
    SyncCDSWithStringGrids;
    Key := 0;
  end;
  if Key = VK_F1 then
  begin
    if [ssShift] = Shift then
    begin
      miFillAllSMR.Click;
    end
    else if [] = Shift then
    begin
      miFillSelectedSMR.Click;
    end;
  end;
end;

procedure TCnEditSMRForm.GetOpenedFiles(Files: TStrings;
  FileFormat: TAppFileType; AllFiles: Boolean);
var
  Msgs: TMessageList;
  Msg: TMessage;
  Proc: TGetOpenedFilesProc;
  i: Integer;
begin
  if not (Assigned(CnSMRMainForm) and Assigned(Files)) then
  begin
    Exit;
  end;

  Files.Clear;

  Msg.Msg := CM_GETOPENEDFILES;
  Msg.Result := 0;
  Msg.WParam := Ord(FileFormat);

  CnSMRMainForm.GetMessageResults(Msg, Msgs);
  for i := Low(Msgs) to High(Msgs) do
  begin
    Proc := Pointer(Msgs[i].WParam);
    if Assigned(Proc) then
    begin
      Proc(TObject(Msgs[i].LParam), Files, AllFiles);
    end;
  end;
end;

function TCnEditSMRForm.GetSelectSourceUnit: string;
begin
  Result := GetSourceUnit(cdsMainFileName.AsString);
end;

function TCnEditSMRForm.GetSourceUnit(const s: string): string;
begin
  Result := Trim(s);
  if (Result <> '') and IsDelphiExt(UpperCase(_CnExtractFileExt(Result))) then
  begin
    Result := _CnChangeFileExt(_CnExtractFileName(Result), '');
  end;
end;

procedure TCnEditSMRForm.LoadARFFromFile(const s: string);
begin
  FAnalyseResults.LoadFromFile(s);
  ARFFileName := s;
  FAnalyseResults.BuildUnits(FUnits);
  FAnalyseResults.BuildPackageUsedBy(FUsedByPackagesList, FUnitPackages);
  UpdateControlsState;
end;

procedure TCnEditSMRForm.LoadSMRFromFile(const s: string);
begin
  FSMRList.LoadFromFile(s);
  SyncCDSWithSyncList;
  FSMRList.Clear;
  SMRFileName := s;
  UpdateControlsState;
end;

procedure TCnEditSMRForm.miClearARFClick(Sender: TObject);
begin
  FAnalyseResults.Clear;
  ARFFileName := '';
  FAnalyseResults.BuildUnits(FUnits);
  FAnalyseResults.BuildPackageUsedBy(FUsedByPackagesList, FUnitPackages);
  UpdateControlsState;
end;

procedure TCnEditSMRForm.miCloseSMRClick(Sender: TObject);
begin
  ActiveDataSet(False);
  SMRFileName := '';
  UpdateControlsState;
end;

procedure TCnEditSMRForm.miFillAllSMRClick(Sender: TObject);
var
  BM: TBookmarkStr;
begin
  if not cdsMain.Active then
  begin
    Exit;
  end;

  cdsMain.DisableControls;
  try
    BM := cdsMain.Bookmark;
    cdsMain.First;
    while not cdsMain.Eof do
    begin
      if GetASourceAffectModules(GetSourceUnit(cdsMainFileName.AsString)) then
      begin
        GetAllSourceAffectModules(FUnitPackages);
        cdsMain.Edit;
        cdsMainAffectModules.AsString := FUnitPackages.CommaText;
        cdsMainAllAffectModules.AsString := FAllUnitPackages.CommaText;
        cdsMain.Post;
      end;
      cdsMain.Next;
    end;
  finally
    cdsMain.Bookmark := BM;
    cdsMain.EnableControls;
    UpdateControlsState;
  end;
end;

procedure TCnEditSMRForm.miFillSelectedSMRClick(Sender: TObject);
begin
  if FAnalyseResults.Count > 0 then
  begin
    CDSEdit;
    try
      if GetASourceAffectModules(GetSelectSourceUnit) then
      begin
        GetAllSourceAffectModules(FUnitPackages);
        cdsMainAffectModules.AsString := FUnitPackages.CommaText;
        cdsMainAllAffectModules.AsString := FAllUnitPackages.CommaText;
      end
      else
      begin
        cdsMainAffectModules.AsString := '';
        cdsMainAllAffectModules.AsString := '';
      end;
    finally
      UpdateControlsState;
    end;
  end;
end;

procedure TCnEditSMRForm.miLoadARFClick(Sender: TObject);
begin
  if odOpenARF.Execute then
  begin
    LoadARFFromFile(odOpenARF.FileName);
  end;
end;

procedure TCnEditSMRForm.ActiveDataSet(DoActive: Boolean);
begin
  FActiveDataSet := DoActive;
{$IFDEF VER130}
  try
    cdsMain.Active := FActiveDataSet;
  except
    FreeAndNil(cdsMain);
    if not FActiveDataSet then
    begin
      cdsMain := TADODataSet.Create(Self);
      dsMain.DataSet := cdsMain;
      with cdsMain do
      begin
        BeforePost := cdsMainBeforePost;
        AfterPost := cdsMainAfterPost;
        AfterCancel := cdsMainAfterCancel;
        BeforeScroll := cdsMainBeforeScroll;
        AfterScroll := cdsMainAfterScroll;
      end;
    end;  
  end;
{$ELSE}
  cdsMain.Active := FActiveDataSet;
{$ENDIF}
  if cdsMain.Active then
  begin
    ResizeDBGrid;
    UpdateControlsState;
  end;
end;

procedure TCnEditSMRForm.CreateTempDataSet(ds: TADODataSet);
const
  csFileName = 'FileName';
  csAffectModules = 'AffectModules';
  csAllAffectModules = 'AllAffectModules';
begin
  with ds do
  begin
    FieldDefs.Clear;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Name := csFileName;
      Size := 260;
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftMemo;
      Name := csAffectModules;
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftMemo;
      Name := csAllAffectModules;
    end;
    CreateDataSet;
    cdsMainFileName := FindField(csFileName) as TStringField;
    with cdsMainFileName do
    begin
      Visible := True;
    end;
    cdsMainAffectModules := FindField(csAffectModules) as TMemoField;
    with cdsMainAffectModules do
    begin
      Visible := False;
      BlobType := ftMemo;
    end;
    cdsMainAllAffectModules := FindField(csAllAffectModules) as TMemoField;
    with cdsMainAllAffectModules do
    begin
      Visible := False;
      BlobType := ftMemo;
    end;
  end;
end;

procedure TCnEditSMRForm.miNewSMRClick(Sender: TObject);
begin
  ActiveDataSet(False);
  CreateTempDataSet(cdsMain);
  ActiveDataSet(True);
  SMRFileName := '';
  UpdateControlsState;
end;

procedure TCnEditSMRForm.miNewSMRFromDirListClick(Sender: TObject);
var
  i: Integer;
  ss: TStrings;
begin
  if odOpenDirListFile.Execute then
  begin    
    ss := TStringList.Create;
    miNewSMR.Click;
    cdsMain.DisableControls;
    try
      ss.LoadFromFile(odOpenDirListFile.FileName);
      for i := 0 to ss.Count - 1 do
      begin
        CDSAdd(Trim(ss[i]), '', '', False);
      end;
    finally
      ss.Free;
      cdsMain.First;
      cdsMain.EnableControls;
      UpdateControlsState;
    end;
  end;
end;

procedure TCnEditSMRForm.miOpenSMRClick(Sender: TObject);
begin
  if odOpenSMF.Execute then
  begin
    LoadSMRFromFile(odOpenSMF.FileName);
  end;
end;

procedure TCnEditSMRForm.miOpenSpecifiedARFFileClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    LoadARFFromFile(TMenuItem(Sender).Caption);
  end;
end;

procedure TCnEditSMRForm.miOpenSpecifiedSMRFileClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    LoadSMRFromFile(TMenuItem(Sender).Caption);
  end;
end;

procedure TCnEditSMRForm.DoPopupMenuPopup(Sender: TObject);
var
  ss: TStrings;
begin
  if Sender is TPopupMenu then
  begin
    PrevBuildMenu(TPopupMenu(Sender));
    if Sender = pmOpenSMR then
    begin
      ss := TStringList.Create;
      try
        GetOpenedFiles(ss, aftSMR, True);
        ss.Add('-');
        ss.AddStrings(FOpenedSMRFiles);
        BuildPopupMenu(TPopupMenu(Sender), ss, miOpenSpecifiedSMRFileClick);
        miCloseSMR.Enabled := cdsMain.Active;
      finally
        ss.Free;
      end;
    end
    else if Sender = pmOpenARF then
    begin
      ss := TStringList.Create;
      try
        GetOpenedFiles(ss, aftARF, True);
        ss.Add('-');
        ss.AddStrings(FOpenedARFFiles);
        BuildPopupMenu(TPopupMenu(Sender), ss, miOpenSpecifiedARFFileClick);
        miClearARF.Enabled := ARFFileName <> '';
      finally
        ss.Free;
      end;
    end;
  end;
end;

procedure TCnEditSMRForm.edtSearchFileChange(Sender: TObject);
var
  BM: TBookmarkStr;
  s: string;
begin
  cdsMain.DisableControls;
  try
    BM := cdsMain.Bookmark;
    s := GetSearchMask(edtSearchFile.Text);
    cdsMain.First;
    if not FindKeyInCDS(cdsMain, cdsMainFileName, s, True, False, DefaultMatchProc) then
    begin
      cdsMain.Bookmark := BM;
    end;
  finally
    cdsMain.EnableControls;
    UpdateControlsState;
  end;
end;

procedure TCnEditSMRForm.edtSearchFileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_UP: begin
      if cdsMain.Active and not cdsMain.Bof then
      begin
        if ([ssCtrl] = Shift) then
        begin
          if FindKeyInCDS(cdsMain, cdsMainFileName, GetSearchMask(edtSearchFile.Text), False, True, DefaultMatchProc) then
          begin
            UpdateControlsState;
          end;
        end
        else
        begin
          cdsMain.Prior;
        end;
        Key := 0;
      end;
    end;
    VK_DOWN: begin
      if cdsMain.Active and not cdsMain.Eof then
      begin
        if ([ssCtrl] = Shift) then
        begin
          if FindKeyInCDS(cdsMain, cdsMainFileName, GetSearchMask(edtSearchFile.Text), True, True, DefaultMatchProc) then
          begin
            UpdateControlsState;
          end;
        end
        else
        begin
          cdsMain.Next;
        end;
        Key := 0;
      end;
    end;
    VK_HOME: begin
      if [ssCtrl] = Shift then
      begin
        cdsMain.First;
        Key := 0;
      end;
    end;
    VK_END: begin
      if [ssCtrl] = Shift then
      begin
        cdsMain.Last;
        Key := 0;
      end;
    end;
  end;
end;

procedure TCnEditSMRForm.BuildPickList(gd: TStringGrid);
begin
  if GetASourceAffectModules(GetSourceUnit(cdsMainFileName.AsString)) then
  begin
    if gd = gdAffects then
    begin
      cmbPickList.Items.Assign(FUnitPackages);
    end
    else
    begin
      GetAllSourceAffectModules(FUnitPackages);
      cmbPickList.Items.Assign(FAllUnitPackages);
    end;
  end
  else
  begin
    cmbPickList.Clear;
  end;  
end;

procedure TCnEditSMRForm.CDSAdd(const sFileName, sModules, sAllModules: string; Check: Boolean = True);
var
  s: string;
begin
  if Check and (not (cdsMain.Active and (cdsMain.State in [dsBrowse]))) then
  begin
    Exit;
  end;

  s := Trim(sFileName);
  if s <> '' then
  begin
    cdsMain.Append;
    cdsMainFileName.AsString := s;
    cdsMainAffectModules.AsString := sModules;
    cdsMainAllAffectModules.AsString := sAllModules;
    cdsMain.Post;
  end;
end;

procedure TCnEditSMRForm.CDSEdit;
begin
  if cdsMain.Active and (not (cdsMain.State in [dsInsert, dsEdit])) then
  begin
    cdsMain.Edit;
  end;
end;

procedure TCnEditSMRForm.pmFillCDSPopup(Sender: TObject);
begin
  miFillSelectedSMR.Enabled := cdsMain.Active;
  miFillAllSMR.Enabled := miFillSelectedSMR.Enabled;
end;

procedure TCnEditSMRForm.pnlAffectModulesResize(Sender: TObject);
begin
  if gdAffects.ColCount > 0 then
  begin
    gdAffects.ColWidths[0] := gdAffects.ClientWidth;
    if Assigned(FLastSelectedGrid) then
      with FLastSelectedGrid do
        ShowPickControl(Col, Row);
  end;
end;

procedure TCnEditSMRForm.pnlAllAffectModulesResize(Sender: TObject);
begin
  if gdAllAffects.ColCount > 0 then
  begin
    gdAllAffects.ColWidths[0] := gdAllAffects.ClientWidth;
    if Assigned(FLastSelectedGrid) then
      with FLastSelectedGrid do
        ShowPickControl(Col, Row);
  end;
end;

procedure TCnEditSMRForm.pnlSourceFilesResize(Sender: TObject);
begin
  ResizeDBGrid;
end;

procedure TCnEditSMRForm.CDSPost;
begin
  if cdsMain.State in [dsInsert, dsEdit] then
  begin
    cdsMain.Post;
  end;
end;

procedure TCnEditSMRForm.CMGetFormIndex(var Message: TMessage);
begin
  Message.Result := 4;
end;

procedure TCnEditSMRForm.PrevBuildMenu(pm: TPopupMenu);
var
  i, iCount: Integer;
begin
  if pm = pmOpenSMR then
  begin
    iCount := FSMRPopupMenuItemCount;
  end
  else if pm = pmOpenARF then
  begin
    iCount := FARFPopupMenuItemCount;
  end
  else
  begin
    Exit;
  end;
  for i := pm.Items.Count - 1 downto iCount do
  begin
    pm.Items.Delete(i);
  end;
end;

procedure TCnEditSMRForm.ResizeDBGrid;
var
  TM: TTextMetric;
begin
  if not cdsMain.Active then
    Exit;
  with gdFiles do
  begin
    GetTextMetrics(Canvas.Handle, TM);
    cdsMainFileName.DisplayWidth :=
      (Width - GetSystemMetrics(SM_CXVSCROLL) - 8 - TM.tmOverhang) div (Canvas.TextWidth('0') - TM.tmOverhang);
  end;
end;

procedure TCnEditSMRForm.SetARFFileName(const Value: string);
begin
  if Value <> '' then
  begin
    FOpenedARFFiles.Add(Value);
    if FOpenedARFFiles.Count > ciMaxFileList then
    begin
      FOpenedARFFiles.Delete(0);
    end;
  end;
  FARFFileName := Value;
end;

procedure TCnEditSMRForm.SetSMRFileName(const Value: string);
begin
  if Value <> '' then
  begin
    FOpenedSMRFiles.Add(Value);
    if FOpenedSMRFiles.Count > ciMaxFileList then
    begin
      FOpenedSMRFiles.Delete(0);
    end;
  end;
  FSMRFileName := Value;
end;

procedure TCnEditSMRForm.SyncCDSWithStringGrids;
begin
  CDSEdit;
  cdsMainAffectModules.AsString := GetGridValues(gdAffects, FUnitPackages);
  cdsMainAllAffectModules.AsString := GetGridValues(gdAllAffects, FAllUnitPackages);
end;

procedure TCnEditSMRForm.SyncCDSWithSyncList;
var
  i: Integer;
  P: PSMR;
begin
  miNewSMR.Click;
  cdsMain.DisableControls;
  try
    for i := 0 to FSMRList.Count - 1 do
    begin
      P := FSMRList.SMR[i];
      if P <> nil then
      begin
        CDSAdd(FSMRList[i], P.AffectModules.CommaText, P.AllAffectModules.CommaText, False);
      end
      else
      begin
        CDSAdd(FSMRList[i], '', '', False);
      end;
    end;
  finally
    cdsMain.First;
    cdsMain.EnableControls;
  end;
end;

procedure TCnEditSMRForm.SyncSMRListWithCDS;
var
  BM: TBookmarkStr;
begin
  FSMRList.Clear;
  if not cdsMain.Active then
    Exit;
  cdsMain.DisableControls;
  try
    BM := cdsMain.Bookmark;
    cdsMain.First;
    while not cdsMain.Eof do
    begin
      FSMRList.AddCommaText(cdsMainFileName.AsString, cdsMainAffectModules.AsString, cdsMainAllAffectModules.AsString);
      cdsMain.Next;
    end;
  finally
    cdsMain.Bookmark := BM;
    cdsMain.EnableControls;
  end;
end;

procedure TCnEditSMRForm.SyncStringGridsWithCDS;
begin
  if cdsMain.Active then
  begin
    SetCommaText(cdsMainAffectModules.AsString, FUnitPackages);
    SetCommaText(cdsMainAllAffectModules.AsString, FAllUnitPackages);
  end
  else
  begin
    FUnitPackages.Clear;
    FAllUnitPackages.Clear;
  end;
  FillGrid(gdAffects, FUnitPackages);
  FillGrid(gdAllAffects, FAllUnitPackages);
end;

procedure TCnEditSMRForm.UpdateControlsState;
var
  bEnabled: Boolean;
  s: string;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    s := '';
    if SMRFileName <> '' then
    begin
      s := '[SMR file: ' + AnsiQuotedStr(SMRFileName, '"') + ']';
    end;
    if ARFFileName <> '' then
    begin
      s := s + '[ARF file:' + AnsiQuotedStr(ARFFileName, '"') + ']';
    end;
    lblOpenedFile.Caption := s;

    bEnabled := cdsMain.Active;
    edtSearchFile.Enabled := bEnabled;
    btnSaveSMR.Enabled := bEnabled;
    gdAffects.Enabled := bEnabled;
    gdAllAffects.Enabled := bEnabled;

    SyncStringGridsWithCDS;
  finally
    FUIUpdating := False;
  end;
end;

procedure TCnEditSMRForm.FormResize(Sender: TObject);
begin
  // realign controls
  pnlSourceFiles.Width := (gpAnalyse.ClientWidth - sbButtons.Width) div 2;
  pnlAffectModules.Height := pnlAffectedModules.ClientHeight div 2;
end;

(*
{ TStringGrid }

function TStringGrid.CreateEditor: TInplaceEdit;
begin
  Result := TInplaceEditList.Create(Self);
  TInplaceEditList(Result).DropDownRows := 20;
end;

function TStringGrid.GetEditStyle(ACol, ARow: Integer): TEditStyle;
begin
  Result := esPickList;
end;
//*)

procedure TCnEditSMRForm.DoSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  HidePickControl;
  ShowPickControl(ACol, ARow);
end;

procedure TCnEditSMRForm.appEventsFixMouseWheelMsgMessage(var Msg: tagMSG;
  var Handled: Boolean);
var
  i: SmallInt;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    Msg.message := WM_KEYDOWN;
    Msg.lParam := 0;
    i := HiWord(Msg.wParam);
    if i > 0 then
      Msg.wParam := VK_UP
    else
      Msg.wParam := VK_DOWN;

    Handled := False;
  end;
end;

procedure TCnEditSMRForm.HidePickControl;
begin
  cmbPickList.Hide;
end;

procedure TCnEditSMRForm.ShowPickControl(ACol, ARow: Integer);
var
  Rect: TRect;
begin
  if (not ActiveIsPickControl) or (FLastSelectedGrid = nil) then Exit;

  BuildPickList(FLastSelectedGrid);
  Rect := FLastSelectedGrid.CellRect(ACol, ARow);
  with cmbPickList do
  begin
    Parent := FLastSelectedGrid.Parent;
    //ParentWindow := FLastSelectedGrid.Handle;
    Text := FLastSelectedGrid.Cells[ACol, ARow];
    ItemIndex := Items.IndexOf(Text);
    Width := Rect.Right - Rect.Left;
    Left := Rect.Left + FLastSelectedGrid.Left + 2;
    Top := Rect.Top + FLastSelectedGrid.Top + 1;
    Visible := True;
    BringToFront;
    SelectAll;
    if not FActiveControlChanging then try SetFocus; except end;
  end;
end;

procedure TCnEditSMRForm.gdAffectsTopLeftChanged(Sender: TObject);
begin
  with Sender as TStringGrid do ShowPickControl(Col, Row);
end;

function TCnEditSMRForm.ActiveIsPickControl: Boolean;
begin
  Result := (Screen.ActiveControl = gdAffects) or
    (Screen.ActiveControl = gdAllAffects) or
    (Screen.ActiveControl = cmbPickList);
end;

procedure TCnEditSMRForm.OnScreenActiveControlChange(Sender: TObject);
begin
  Assert(not FActiveControlChanging);
  if FActiveControlChanging then Exit;

  FActiveControlChanging := True;
  try
    if ActiveIsPickControl then
    begin
      if Screen.ActiveControl <> cmbPickList then
      begin
        FLastSelectedGrid := Screen.ActiveControl as TStringGrid;
//        ShowPickControl(FLastSelectedGrid.Col, FLastSelectedGrid.Row);
      end;
    end
    else
    begin
      FLastSelectedGrid := nil;
      HidePickControl;
    end;
  finally
    FActiveControlChanging := False;
  end;
end;

procedure TCnEditSMRForm.cmbSetCellText(Sender: TObject);
begin
  if Assigned(FLastSelectedGrid) then
    with FLastSelectedGrid do
      Cells[Col, Row] := cmbPickList.Text;
  SyncCDSWithStringGrids;    
end;

procedure TCnEditSMRForm.cmbPickListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FLastSelectedGrid) then
    with FLastSelectedGrid do
      case Key of
        VK_UP, VK_DOWN, VK_TAB:
          begin
            if Shift = [] then
              try
                SetFocus;
                keybd_event(Key, 0, 0, 0);
                Key := 0;
              except
              end;
          end;
        VK_HOME, VK_END:
          begin
            if Shift = [ssCtrl] then
              try
                SetFocus;
                keybd_event(Key, 0, 0, 0);
                Key := 0;
              except
              end;
          end;
        VK_F1:
          begin
            try
              SetFocus;
              keybd_event(Key, 0, 0, 0);
              Key := 0;
            except
            end;
          end;
        VK_DELETE:
          begin
            if Shift <> [] then
              try
                SetFocus;
                keybd_event(Key, 0, 0, 0);
                Key := 0;
              except
              end;
          end;
      end;
end;

procedure TCnEditSMRForm.UIInitialize;
begin
  WrapButtonsCaption(gpAnalyseBtns);
end;

initialization
  RegisterFormClass(TCnEditSMRForm);

end.
