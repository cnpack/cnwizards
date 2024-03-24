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

unit CnViewARFUnit;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：ARF 编辑单元
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls,
  CnMainUnit, CnSMRBplUtils, CnBaseUtils, CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnViewARFForm = class(TForm, IUIInitializable)
    sbLeft: TScrollBox;
    gpAnalyseBtns: TPanel;
    btnOpenFiles: TBitBtn;
    btnClear: TBitBtn;
    odOpenSavedResults: TOpenDialog;
    lblOpenedFile: TLabel;
    pgcMain: TPageControl;
    tsModuleView: TTabSheet;
    gpModule: TPanel;
    pnlVEExeFiles: TPanel;
    Label3: TLabel;
    Label5: TLabel;
    lsbModules: TListBox;
    edtSearchModule: TEdit;
    Panel5: TPanel;
    tsUnitView: TTabSheet;
    gpUnit: TPanel;
    Panel1: TPanel;
    pnlVUUnits: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    lsbUnits: TListBox;
    edtSearchUnit: TEdit;
    pnlModuleUnitsPackages: TPanel;
    gpModuleUnitsPackages: TPanel;
    pnlVEUnits: TPanel;
    Label1: TLabel;
    lsbModuleUnits: TListBox;
    pnlVERequiredPackages: TPanel;
    Label2: TLabel;
    lsbModuleRequirePackages: TListBox;
    pnlVEPackages: TPanel;
    pnlVEUsedBy: TPanel;
    Panel9: TPanel;
    Label7: TLabel;
    lsbPackagesUsed: TListBox;
    Label10: TLabel;
    lsbAllPackagesUsed: TListBox;
    Panel10: TPanel;
    Label4: TLabel;
    lsbModuleAllRequirePackages: TListBox;
    btnPrevView: TBitBtn;
    btnNextView: TBitBtn;
    edtUsedPackageMask: TEdit;
    Label11: TLabel;
    pmOpenFiles: TPopupMenu;
    miOpenFileManually: TMenuItem;
    N1: TMenuItem;
    pnlVUPackages: TPanel;
    Panel12: TPanel;
    Label6: TLabel;
    lsbUnitPackages: TListBox;
    Label12: TLabel;
    lsbAllUnitPackages: TListBox;
    tsDuplicatedUnits: TTabSheet;
    Panel2: TPanel;
    pnlDUAllExes: TPanel;
    Label14: TLabel;
    lbDUAllExes: TListBox;
    Panel6: TPanel;
    pnlDUSelectedExes: TPanel;
    Panel14: TPanel;
    Label13: TLabel;
    lbDUSelectedExes: TListBox;
    Panel15: TPanel;
    Label15: TLabel;
    btnDUAddExe: TButton;
    btnDUAddAll: TButton;
    btnDURemoveExe: TButton;
    btnDURemoveAll: TButton;
    Panel7: TPanel;
    btnDUSaveDUs: TButton;
    mmoDUDUs: TMemo;
    sdSaveDUs: TSaveDialog;
    procedure pmOpenFilesPopup(Sender: TObject);
    procedure miOpenFileManuallyClick(Sender: TObject);
    procedure DoUpdateAlign(Sender: TObject);
    procedure btnNextViewClick(Sender: TObject);
    procedure btnPrevViewClick(Sender: TObject);
    procedure DoViewByUnit(Sender: TObject);
    procedure DoViewByModule(Sender: TObject);
    procedure DoProcessKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoSeachByMask(Sender: TObject);
    procedure DoUpdateViews(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnOpenFilesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnDUAddExeClick(Sender: TObject);
    procedure btnDUAddAllClick(Sender: TObject);
    procedure DoUpdateControlsState(Sender: TObject);
    procedure btnDURemoveExeClick(Sender: TObject);
    procedure btnDURemoveAllClick(Sender: TObject);
    procedure btnDUSaveDUsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FAnalyseResults: TPackageInfosList;
    FUnits, FUsedByPackagesList: TStringObjectList;
    FUnitPackages, FAllUnitPackages, FUsedByPackages, FAllUsedByPackages: TStringList;
    FUIUpdating: Boolean;
    FOpenedFileName: string;
    FPrevList, FNextList: TStringList;
    FPreving, FNexting: Boolean;
    FOpenedFiles: TStringList;
    FPopupMenuItemCount: Integer;

    procedure SetOpenedFileName(const Value: string);

    function GetModuleMask: string;
    function GetSelectedModule: string;
    function GetSelectedUnit: string;
    function GetUnitMask: string;
    function GetSelectedKey: string;
    function GetMask: string;
    function LastViewIs(const s: string; p: Pointer): Boolean;
    function IndexOfAnalyseResult(const s: string): Integer;
    function CanViewPrev: Boolean;
    function CanViewNext: Boolean;
    function PrevNexting: Boolean;
    function PrevNextProc(IsModule: Boolean): TPrevNextProc; overload;
    function PrevNextProc(IsModule: Pointer): TPrevNextProc; overload;
    function PrevNextPointer(IsModule: Boolean): Pointer;
    function IsViewingModule: Boolean;
    function GetUsedByPackagesMask: string;

    procedure BuildUnits;
    procedure BuildPackageUsedBy;
    procedure ClearPrev;
    procedure ClearNext;
    procedure GetAllRequiredPackages(ssRequiredPackages, ssAllRequiredPackages: TStrings);
    procedure GetAllUsedByPackages(ssUsedByPackages, ssAllUsedByPackages: TStrings);
    procedure UpdateControlsState;
    procedure UpdateModuleView; overload;
    procedure UpdateModuleView(P: PPackageInfos; ssUsedByPackages: TStrings); overload;
    procedure UpdateModuleView(ssUnits, ssRequirePackages,
      ssAllRequiredPackages, ssUsedByPackages, ssAllUsedByPackages: TStrings); overload;
    procedure UpdateUnitView;
    procedure FillAllUnitPackages(ss: TStrings);
    procedure ViewAnalyseResults;
    procedure ViewByModule(const s: string);
    procedure ViewByUnit(const s: string);
    procedure ViewPrev;
    procedure ViewNext;

    procedure GetOpenedFiles(Files: TStrings; AllFiles: Boolean);
    procedure CMGetOpenedFiles(var Message: TMessage); message CM_GETOPENEDFILES;
    procedure CMGetFormIndex(var Message: TMessage); message CM_GETFORMINDEX;
    procedure OpenFileManually;
    procedure PrevBuildMenu(pm: TPopupMenu);
    procedure miOpenSpecifiedFileClick(Sender: TObject);
    procedure LoadFromFile(const s: string);
    procedure AnalyzeDuplicatedUnits;
  public
    { Public declarations }
    procedure UIInitialize;
    property OpenedFileName: string read FOpenedFileName write SetOpenedFileName;
  end;

implementation

{$R *.dfm}

const
  cpPrevNextModules: Pointer = Pointer(0);
  cpPrevNextUnits: Pointer = Pointer(1);

procedure TCnViewARFForm.btnClearClick(Sender: TObject);
begin
  FAnalyseResults.Clear;
  OpenedFileName := '';
  ViewAnalyseResults;
  UpdateControlsState;
end;

procedure TCnViewARFForm.btnNextViewClick(Sender: TObject);
begin
  ViewNext;
end;

procedure TCnViewARFForm.btnOpenFilesClick(Sender: TObject);
var
  Pos: TPoint;
begin
  if FOpenedFiles.Count = 0 then
  begin
    OpenFileManually;
  end
  else
  begin
    pmOpenFiles.PopupComponent := btnOpenFiles;
    Pos := btnOpenFiles.ClientToScreen(GetRectCenter(btnOpenFiles.ClientRect));// gpAnalyseBtns.ClientToScreen(GetRectCenter(GetControlRectInGridPanel(btnOpenFiles, gpAnalyseBtns)));
    pmOpenFiles.Popup(Pos.X, Pos.Y);
  end;
end;

procedure TCnViewARFForm.btnPrevViewClick(Sender: TObject);
begin
  ViewPrev;
end;

procedure TCnViewARFForm.BuildPackageUsedBy;
begin
  FAnalyseResults.BuildPackageUsedBy(FUsedByPackagesList, FUsedByPackages);
end;

procedure TCnViewARFForm.BuildUnits;
begin
  FAnalyseResults.BuildUnits(FUnits);
end;

function TCnViewARFForm.CanViewNext: Boolean;
begin
  Result := FNextList.Count > 0;
end;

function TCnViewARFForm.CanViewPrev: Boolean;
begin
  Result := FPrevList.Count > 1;
end;

procedure TCnViewARFForm.ClearNext;
begin
  FNextList.Clear;
end;

procedure TCnViewARFForm.ClearPrev;
begin
  FPrevList.Clear;
  FPrevList.AddObject('', PrevNextPointer(IsViewingModule));
end;

procedure TCnViewARFForm.CMGetFormIndex(var Message: TMessage);
begin
  Message.Result := 3;
end;

procedure TCnViewARFForm.CMGetOpenedFiles(var Message: TMessage);
var
  Proc: TGetOpenedFilesProcObject;
begin
  if Message.WParam = Ord(aftARF) then
  begin
    Proc := GetOpenedFiles;
    Message.Result := 1;
    Message.WParam := Integer(Pointer(@Proc));
    Message.LParam := Integer(Pointer(Self));
  end;
end;

procedure TCnViewARFForm.DoSeachByMask(Sender: TObject);
var
  OldItemIndex: Integer;
  lsb: TListBox;
  msk: string;
begin
  if Sender = edtSearchModule then
  begin
    lsb := lsbModules;
    msk := GetModuleMask;
  end
  else if Sender = edtSearchUnit then
  begin
    lsb := lsbUnits;
    msk := GetUnitMask;
  end
  else
  begin
    Exit;
  end;

  OldItemIndex := lsb.ItemIndex;
  lsb.Items.BeginUpdate;
  try
    lsb.ItemIndex := -1;
    lsbFindKey(lsb, msk, True, False, DefaultMatchProc);
  finally
    lsb.Items.EndUpdate;
  end;
  if (lsb.ItemIndex <> OldItemIndex) and Assigned(lsb.OnClick) then
  begin
    lsb.OnClick(lsb);
  end;
end;

procedure TCnViewARFForm.DoProcessKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  lsb: TListBox;
begin
  if Sender = edtSearchModule then
  begin
    lsb := lsbModules;
  end
  else if Sender = edtSearchUnit then
  begin
    lsb := lsbUnits;
  end
  else
  begin
    Exit;
  end;
  
  lsbProcessSearchKeyDown(lsb, GetMask, Key, Shift);
end;

procedure TCnViewARFForm.FillAllUnitPackages(ss: TStrings);
begin
  GetAllUsedByPackages(ss, FAllUnitPackages);
end;

procedure TCnViewARFForm.FormCreate(Sender: TObject);
begin
  FAnalyseResults := TPackageInfosList.Create;
  FAnalyseResults.Sorted := True;
  FUnitPackages := TStringList.Create;
  FUnitPackages.Sorted := True;
  FAllUnitPackages := TStringList.Create;
  FAllUnitPackages.Sorted := True;
  FUnits := TStringObjectList.Create;
  FUnits.Sorted := True;
  FUsedByPackagesList := TStringObjectList.Create;
  FUsedByPackagesList.Sorted := True;
  FUsedByPackages := TStringList.Create;
  FUsedByPackages.Sorted := True;
  FAllUsedByPackages := TStringList.Create;
  FAllUsedByPackages.Sorted := True;
  FPrevList := TStringList.Create;
  FNextList := TStringList.Create;
  FOpenedFiles := TStringList.Create;
  FOpenedFiles.Sorted := True;
  SetDlgInitialDir(Self);
  pgcMain.ActivePageIndex := 0;
  FPopupMenuItemCount := pmOpenFiles.Items.Count;
end;

procedure TCnViewARFForm.FormDestroy(Sender: TObject);
begin
  FOpenedFiles.Free;
  FPrevList.Clear;
  FNextList.Clear;
  FNextList.Free;
  FPrevList.Free;
  FAllUsedByPackages.Free;
  FUsedByPackages.Free;
  FUsedByPackagesList.Free;
  FUnits.Free;
  FAllUnitPackages.Free;
  FUnitPackages.Free;
  FAnalyseResults.Free;
end;

procedure TCnViewARFForm.GetAllRequiredPackages(ssRequiredPackages,
  ssAllRequiredPackages: TStrings);
begin
  FAnalyseResults.GetAllRequiredPackages(ssRequiredPackages, ssAllRequiredPackages);
end;

procedure TCnViewARFForm.GetAllUsedByPackages(ssUsedByPackages,
  ssAllUsedByPackages: TStrings);
begin
  ssAllUsedByPackages.Clear;
  FAnalyseResults.GetAllUsedByPackages(FUsedByPackagesList, ssUsedByPackages, ssAllUsedByPackages);
end;

function TCnViewARFForm.GetUsedByPackagesMask: string;
begin
  Result := Trim(edtUsedPackageMask.Text);
end;

function TCnViewARFForm.GetMask: string;
begin
  if IsViewingModule then
  begin
    Result := GetModuleMask;
  end
  else
  begin
    Result := GetUnitMask;
  end;
end;

function TCnViewARFForm.GetModuleMask: string;
begin
  Result := GetSearchMask(edtSearchModule.Text);
end;

procedure TCnViewARFForm.GetOpenedFiles(Files: TStrings; AllFiles: Boolean);
begin
  if not Assigned(Files) then
  begin
    Exit;
  end;

  if AllFiles then
  begin
    Files.AddStrings(FOpenedFiles);
  end
  else
  begin
    Files.Add(OpenedFileName);
  end;
end;

function TCnViewARFForm.GetSelectedKey: string;
begin
  if IsViewingModule then
  begin
    Result := GetSelectedModule;
  end
  else
  begin
    Result := GetSelectedUnit;
  end;
end;

function TCnViewARFForm.GetSelectedModule: string;
begin
  Result := '';
  if lsbModules.ItemIndex >= 0 then
  begin
    Result := lsbModules.Items[lsbModules.ItemIndex];
  end;
end;

function TCnViewARFForm.GetSelectedUnit: string;
begin
  Result := '';
  if lsbUnits.ItemIndex >= 0 then
  begin
    Result := lsbUnits.Items[lsbUnits.ItemIndex];
  end;
end;

function TCnViewARFForm.GetUnitMask: string;
begin
  Result := GetSearchMask(edtSearchUnit.Text);
end;

function TCnViewARFForm.IndexOfAnalyseResult(const s: string): Integer;
begin
  Result := -1;
  if s = '' then
  begin
    Exit;
  end;

  Result := FAnalyseResults.IndexOf(s);
end;

function TCnViewARFForm.IsViewingModule: Boolean;
begin
  Result := pgcMain.ActivePage = tsModuleView;
end;

function TCnViewARFForm.LastViewIs(const s: string; p: Pointer): Boolean;
var
  idx: Integer;
begin
  idx := FPrevList.Count - 1;
  Result := (idx >= 0) and (FPrevList[idx] = s) and (FPrevList.Objects[idx] = p);
end;

procedure TCnViewARFForm.LoadFromFile(const s: string);
begin
//  btnClear.Click;
  FAnalyseResults.LoadFromFile(s);
  OpenedFileName := s;
  ViewAnalyseResults;
  UpdateControlsState;
end;

procedure TCnViewARFForm.OpenFileManually;
begin
  if odOpenSavedResults.Execute then
  begin
    LoadFromFile(odOpenSavedResults.FileName);
  end;
end;

procedure TCnViewARFForm.pmOpenFilesPopup(Sender: TObject);
begin
  PrevBuildMenu(pmOpenFiles);
  BuildPopupMenu(pmOpenFiles, FOpenedFiles, miOpenSpecifiedFileClick);
end;

procedure TCnViewARFForm.miOpenSpecifiedFileClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    LoadFromFile(TMenuItem(Sender).Caption);
  end;
end;

procedure TCnViewARFForm.DoUpdateAlign(Sender: TObject);
begin
  UpdateChildrenAlign(pgcMain.ActivePage);
end;

procedure TCnViewARFForm.ViewNext;
var
  idx: Integer;
  s: string;
  Proc: TPrevNextProc;
begin
  if not CanViewNext then
  begin
    Exit;
  end;
  FNexting := True;
  try
    idx := FNextList.Count - 1;
    s := FNextList[idx];
    Proc := PrevNextProc(FNextList.Objects[idx]);
    if Assigned(Proc) then
    begin
      Proc(s);
    end;
    FPrevList.AddObject(s, FNextList.Objects[idx]);
    FNextList.Delete(idx);
  finally
    UpdateControlsState;
    FNexting := False;
  end;
end;

procedure TCnViewARFForm.ViewPrev;
var
  idx: Integer;
  s: string;
  Proc: TPrevNextProc;
begin
  if not CanViewPrev then
  begin
    Exit;
  end;
  FPreving := True;
  try
    idx := FPrevList.Count - 2;
    s := FPrevList[idx];
    Proc := PrevNextProc(FPrevList.Objects[idx]);
    if Assigned(Proc) then
    begin
      Proc(s);
    end;
    FNextList.AddObject(FPrevList[idx + 1], FPrevList.Objects[idx + 1]);
    FPrevList.Delete(idx + 1);
  finally
    UpdateControlsState;
    FPreving := False;
  end;
end;

procedure TCnViewARFForm.PrevBuildMenu(pm: TPopupMenu);
var
  i: Integer;
begin
  for i := pm.Items.Count - 1 downto FPopupMenuItemCount do
  begin
    pm.Items.Delete(i);
  end;
end;

function TCnViewARFForm.PrevNexting: Boolean;
begin
  Result := FPreving or FNexting;
end;

function TCnViewARFForm.PrevNextPointer(IsModule: Boolean): Pointer;
begin
  if IsModule then
  begin
    Result := cpPrevNextModules
  end
  else
  begin
    Result := cpPrevNextUnits;
  end;
end;

function TCnViewARFForm.PrevNextProc(IsModule: Pointer): TPrevNextProc;
begin
  if IsModule = cpPrevNextModules then
  begin
    Result := ViewByModule;
  end
  else
  begin
    Result := ViewByUnit;
  end;
end;

function TCnViewARFForm.PrevNextProc(IsModule: Boolean): TPrevNextProc;
begin
  if IsModule then
  begin
    Result := ViewByModule;
  end
  else
  begin
    Result := ViewByUnit;
  end;
end;

procedure TCnViewARFForm.DoUpdateViews(Sender: TObject);
var
  Proc: TPrevNextProc;
begin
  Proc := PrevNextProc(IsViewingModule);
  if Assigned(Proc) then
  begin
    Proc(GetSelectedKey);
  end;
end;

procedure TCnViewARFForm.DoViewByUnit(Sender: TObject);
begin
  if Sender is TListBox then
  begin
    with TListBox(Sender) do
    begin
      if ItemIndex >= 0 then
      begin
        ViewByUnit(Items[ItemIndex]);
      end;
    end;
  end;
end;

procedure TCnViewARFForm.DoViewByModule(Sender: TObject);
begin
  if Sender is TListBox then
  begin
    with TListBox(Sender) do
    begin
      if ItemIndex >= 0 then
      begin
        ViewByModule(Items[ItemIndex]);
      end;
    end;
  end;
end;

procedure TCnViewARFForm.miOpenFileManuallyClick(Sender: TObject);
begin
  OpenFileManually;
end;

procedure TCnViewARFForm.SetOpenedFileName(const Value: string);
begin
  if Value <> '' then
  begin
    FOpenedFiles.Add(Value);
    if FOpenedFiles.Count > ciMaxFileList then
    begin
      FOpenedFiles.Delete(0);
    end;
  end;
  FOpenedFileName := Value;
  ClearPrev;
  ClearNext;
end;

procedure TCnViewARFForm.UpdateModuleView(ssUnits, ssRequirePackages,
  ssAllRequiredPackages, ssUsedByPackages, ssAllUsedByPackages: TStrings);
begin
  SyncListBoxWithStrings(ssUnits, lsbModuleUnits);
  SyncListBoxWithStrings(ssRequirePackages, lsbModuleRequirePackages);
  SyncListBoxWithStrings(ssAllRequiredPackages, lsbModuleAllRequirePackages);
  SyncListBoxWithStrings(ssUsedByPackages, lsbPackagesUsed);
  SyncListBoxWithStrings(ssAllUsedByPackages, lsbAllPackagesUsed);
end;

procedure TCnViewARFForm.UpdateModuleView;
var
  idx, idxUsedBy: Integer;
  s: string;
begin
  s := GetSelectedModule;
  idx := IndexOfAnalyseResult(s);
  idxUsedBy := FUsedByPackagesList.IndexOf(GetSelectedModule);
  if (idx >= 0) and (idxUsedBy >= 0) then
  begin
    SetCommaText(FUsedByPackagesList.StringObjects[idxUsedBy], FUsedByPackages);
  end
  else
  begin
    FUsedByPackages.Clear;
  end;

  UpdateModuleView(FAnalyseResults.PackageInfos[idx], FUsedByPackages);
end;

procedure TCnViewARFForm.UpdateModuleView(P: PPackageInfos; ssUsedByPackages: TStrings);
var
  ssAllRequiredPackages: TStringList;
begin
  GetAllUsedByPackages(FUsedByPackages, FAllUsedByPackages);

  if not Assigned(P) then
  begin
    UpdateModuleView(nil, nil, nil, ssUsedByPackages, FAllUsedByPackages);
  end
  else
  begin
    ssAllRequiredPackages := TStringList.Create;
    try
      ssAllRequiredPackages.Sorted := True;
      GetAllRequiredPackages(P.RequiredPackages, ssAllRequiredPackages);
      UpdateModuleView(P.Units,
        P.RequiredPackages,
        ssAllRequiredPackages,
        ssUsedByPackages,
        FAllUsedByPackages);
    finally
      ssAllRequiredPackages.Free;
    end;
  end;
end;

procedure TCnViewARFForm.UpdateUnitView;
var
  sMask, s: string;
  ss, ssMask: TStringList;

  procedure FilterStrings(Source: TStrings);
  var
    i: Integer;
  begin
    ss.Clear;
    for i := 0 to Source.Count - 1 do
    begin
      s := Source[i];
      if FileMatchesMasks(s, ssMask) then
      begin
        ss.Add(s);
      end;
    end;
  end;

begin
  if lsbUnits.ItemIndex >= 0 then
  begin
    SetCommaText(FUnits.StringObjects[lsbUnits.ItemIndex], FUnitPackages);
  end
  else
  begin
    FUnitPackages.Clear;
  end;

  FillAllUnitPackages(FUnitPackages);
  sMask := GetUsedByPackagesMask;
  if (sMask = '') or (sMask = '*') or (sMask = '*.*') then
  begin
    SyncListBoxWithStrings(FUnitPackages, lsbUnitPackages);
    SyncListBoxWithStrings(FAllUnitPackages, lsbAllUnitPackages);
  end
  else
  begin
    ss := TStringList.Create;
    ssMask := TStringList.Create;
    try
      FileMasksToStrings(sMask, ssMask, False);
      FilterStrings(FUnitPackages);
      SyncListBoxWithStrings(ss, lsbUnitPackages);
      FilterStrings(FAllUnitPackages);
      SyncListBoxWithStrings(ss, lsbAllUnitPackages);
    finally
      ss.Free;
      ssMask.Free;
    end;
  end;
end;

procedure TCnViewARFForm.UpdateControlsState;

  procedure EnableEdit(edt: TEdit; bEnabled: Boolean);
  begin
    if Assigned(edt) then
    begin
      edt.Enabled := bEnabled;
      if not bEnabled then
      begin
        edt.Clear;
      end;
    end;
  end;

var
  bEnabled: Boolean;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    bEnabled := OpenedFileName <> '';

    if not bEnabled then
    begin
      lblOpenedFile.Caption := Format(SCnClickHintARFFmt, [GetButtonCaption(btnOpenFiles)]);
//      lblOpenedFile.EllipsisPosition := epEndEllipsis;
    end
    else
    begin
      lblOpenedFile.Caption := Format(SCnBrowseHintARFFmt, [OpenedFileName]);
//      lblOpenedFile.EllipsisPosition := epPathEllipsis;
    end;
    btnClear.Enabled := bEnabled;
    EnableEdit(edtSearchModule, bEnabled);
    EnableEdit(edtSearchUnit, bEnabled);
    EnableEdit(edtUsedPackageMask, bEnabled);
    btnPrevView.Enabled := bEnabled and CanViewPrev;
    btnNextView.Enabled := bEnabled and CanViewNext;
    btnDUAddExe.Enabled := bEnabled and (lbDUAllExes.SelCount > 0);
    btnDUAddAll.Enabled := bEnabled and (lbDUAllExes.Items.Count > 0);
    btnDURemoveExe.Enabled := bEnabled and (lbDUSelectedExes.SelCount > 0);
    btnDURemoveAll.Enabled := bEnabled and (lbDUSelectedExes.Items.Count > 0);
    btnDUSaveDUs.Enabled := mmoDUDUs.Lines.Count > 0;
    lsbAddHorizontalScrollBar(lbDUSelectedExes);

    if FPrevList.Count > ciMaxPrevNext then
    begin
      FPrevList.Delete(0);
    end;
  finally
    UpdateModuleView;
    UpdateUnitView;
    FUIUpdating := False;
  end;
end;

procedure TCnViewARFForm.ViewAnalyseResults;
var
  i: Integer;
begin
  lsbModules.Clear;
  lbDUAllExes.Clear;
  lbDUSelectedExes.Clear;
  mmoDUDUs.Clear;
  if FAnalyseResults.Count > 0 then
  begin
    lsbModules.Items.BeginUpdate;
    lbDUAllExes.Items.BeginUpdate;
    try
      for i := 0 to FAnalyseResults.Count - 1 do
      begin
        lsbModules.Items.AddObject(FAnalyseResults.Strings[i], FAnalyseResults.Objects[i]);
        lbDUAllExes.Items.AddObject(FAnalyseResults.Strings[i], FAnalyseResults.Objects[i]);
      end;
    finally
      lsbAddHorizontalScrollBar(lsbModules);
      lsbAddHorizontalScrollBar(lbDUAllExes);
      lsbModules.Items.EndUpdate;
      lbDUAllExes.Items.EndUpdate;
    end;
  end;

  lsbUnits.Clear;
  BuildUnits;
  BuildPackageUsedBy;
  if FUnits.Count > 0 then
  begin
    lsbUnits.Items.BeginUpdate;
    try
      for i := 0 to FUnits.Count - 1 do
      begin
        lsbUnits.Items.Add(FUnits[i]);
      end;
    finally
      lsbAddHorizontalScrollBar(lsbUnits);
      lsbUnits.Items.EndUpdate;
    end;
  end;
end;

procedure TCnViewARFForm.ViewByModule(const s: string);
var
  idx: Integer;
  _s: string;
begin
  if ExtractFileExt(s) = '' then
  begin
    _s := s + csDefaultPackageExt;
  end
  else
  begin
    _s := s;
  end;

  idx := lsbModules.Items.IndexOf(_s);
  if PrevNexting or (idx >= 0) then
  begin
    lsbModules.ItemIndex := idx;
    pgcMain.ActivePage := tsModuleView;

    if not (PrevNexting or LastViewIs(_s, cpPrevNextModules)) then
    begin
      FPrevList.AddObject(_s, cpPrevNextModules);
      FNextList.Clear;
    end;

    if not PrevNexting then
    begin
      UpdateControlsState;
    end;
  end;
end;

procedure TCnViewARFForm.ViewByUnit(const s: string);
var
  idx: Integer;
begin
  idx := lsbUnits.Items.IndexOf(s);
  if PrevNexting or (idx >= 0) then
  begin
    lsbUnits.ItemIndex := idx;
    pgcMain.ActivePage := tsUnitView;

    if not (PrevNexting or LastViewIs(s, cpPrevNextUnits)) then
    begin
      FPrevList.AddObject(s, cpPrevNextUnits);
      FNextList.Clear;
    end;

    if not PrevNexting then
    begin
      UpdateControlsState;
    end;
  end;
end;

procedure TCnViewARFForm.FormResize(Sender: TObject);
begin
  // realign controls
  pnlVEExeFiles.Width := gpModule.ClientWidth div 3;
  pnlModuleUnitsPackages.Width := pnlVEExeFiles.Width;
  pnlVEUnits.Height := gpModuleUnitsPackages.ClientHeight * 2 div 5;
  pnlVERequiredPackages.Height := gpModuleUnitsPackages.ClientHeight * 3 div 10;
  pnlVEUsedBy.Height := pnlVEPackages.ClientHeight div 2;
  pnlDUAllExes.Width := pnlVEExeFiles.Width;
  pnlDUSelectedExes.Width := pnlVEExeFiles.Width;

  pnlVUUnits.Width := gpUnit.ClientWidth div 2;
  lsbUnitPackages.Height := (pnlVUPackages.ClientHeight - lsbUnitPackages.Top) div 2;
end;

procedure TCnViewARFForm.btnDUAddExeClick(Sender: TObject);
var
  i: Integer;
begin
  lbDUSelectedExes.Items.BeginUpdate;
  try
    for i := 0 to lbDUAllExes.Items.Count - 1 do
      if lbDUAllExes.Selected[i] and (lbDUSelectedExes.Items.IndexOf(lbDUAllExes.Items[i]) < 0) then
        lbDUSelectedExes.Items.AddObject(lbDUAllExes.Items[i], lbDUAllExes.Items.Objects[i]);
  finally
    lbDUSelectedExes.Items.EndUpdate;
  end;
  AnalyzeDuplicatedUnits;
  UpdateControlsState;
end;

procedure TCnViewARFForm.btnDUAddAllClick(Sender: TObject);
var
  i: Integer;
begin
  lbDUSelectedExes.Items.BeginUpdate;
  try
    lbDUSelectedExes.Clear;
    for i := 0 to lbDUAllExes.Items.Count - 1 do
      lbDUSelectedExes.Items.AddObject(lbDUAllExes.Items[i], lbDUAllExes.Items.Objects[i]);
  finally
    lbDUSelectedExes.Items.EndUpdate;
  end;    
  AnalyzeDuplicatedUnits;
  UpdateControlsState;
end;

procedure TCnViewARFForm.DoUpdateControlsState(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnViewARFForm.btnDURemoveExeClick(Sender: TObject);
var
  I: Integer;
begin
  // DeleteSelected
  if lbDUSelectedExes.MultiSelect then
  begin
    for I := lbDUSelectedExes.Items.Count - 1 downto 0 do
      if lbDUSelectedExes.Selected[I] then
        lbDUSelectedExes.Items.Delete(I);
  end
  else
    if lbDUSelectedExes.ItemIndex <> -1 then
      lbDUSelectedExes.Items.Delete(lbDUSelectedExes.ItemIndex);

  AnalyzeDuplicatedUnits;
  UpdateControlsState;
end;

procedure TCnViewARFForm.btnDURemoveAllClick(Sender: TObject);
begin
  lbDUSelectedExes.Clear;
  AnalyzeDuplicatedUnits;
  UpdateControlsState;
end;

procedure TCnViewARFForm.btnDUSaveDUsClick(Sender: TObject);
begin
  if sdSaveDUs.Execute then
    mmoDUDUs.Lines.SaveToFile(sdSaveDUs.FileName);
end;

procedure TCnViewARFForm.AnalyzeDuplicatedUnits;
var
  i, j: Integer;
  DUs: TStringList;
begin
  mmoDUDUs.Lines.BeginUpdate;
  try
    mmoDUDUs.Clear;
    if lbDUSelectedExes.Items.Count > 1 then
    begin
      DUs := TStringList.Create;
      try
        DUs.Assign(PPackageInfos(lbDUSelectedExes.Items.Objects[0]).Units);
        for i := 1 to lbDUSelectedExes.Items.Count - 1 do
        begin
          for j := DUs.Count - 1 downto 0 do
          begin
            if PPackageInfos(lbDUSelectedExes.Items.Objects[i]).Units.IndexOf(DUs.Strings[j]) < 0 then
              DUs.Delete(j);
          end;
        end;
        mmoDUDUs.Lines.Assign(DUs);
      finally
        DUs.Free;
      end;
    end;  
  finally
    mmoDUDUs.Lines.EndUpdate;
  end;
end;

procedure TCnViewARFForm.FormShow(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnViewARFForm.UIInitialize;
begin
  WrapButtonsCaption(gpAnalyseBtns);
end;

initialization
  RegisterFormClass(TCnViewARFForm);

end.
