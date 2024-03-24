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

unit CnEditARFUnit;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：ARF 编辑分析单元
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Buttons,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus, CnSMRBplUtils, CnMainUnit,
  CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnEditARFForm = class(TForm, IUIInitializable)
    odOpenFiles: TOpenDialog;
    sdAnalyseResults: TSaveDialog;
    gpAnalyse: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    mmoUnits: TMemo;
    pnlRequiredPackages: TPanel;
    Label2: TLabel;
    mmoRequirePackages: TMemo;
    pnlExeFiles: TPanel;
    Label3: TLabel;
    lsbFiles: TListBox;
    sbButtons: TScrollBox;
    gpAnalyseBtns: TPanel;
    btnOpenFiles: TBitBtn;
    btnAnalyse: TBitBtn;
    btnAnalyseAll: TBitBtn;
    btnClearFiles: TBitBtn;
    btnSaveResults: TBitBtn;
    btnAppendResults: TBitBtn;
    pmAddFiles: TPopupMenu;
    miSelectFiles: TMenuItem;
    miSelectFilesFromFileList: TMenuItem;
    odOpenFilesFrom: TOpenDialog;
    Label5: TLabel;
    edtSearchFile: TEdit;
    procedure edtSearchFileKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchFileChange(Sender: TObject);
    procedure miSelectFilesFromFileListClick(Sender: TObject);
    procedure miSelectFilesClick(Sender: TObject);
    procedure btnAppendResultsClick(Sender: TObject);
    procedure btnClearFilesClick(Sender: TObject);
    procedure lsbFilesDblClick(Sender: TObject);
    procedure btnSaveResultsClick(Sender: TObject);
    procedure lsbFilesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lsbFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lsbFilesClick(Sender: TObject);
    procedure btnAnalyseAllClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAnalyseClick(Sender: TObject);
    procedure btnOpenFilesClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FAnalyseResults: TPackageInfosList;
    FUIUpdating: Boolean;
    FPerformUIUpdating: Boolean;
    FAnalysing: Boolean;

    function GetSelectedFile: string;
    function IndexOfAnalyseResult(const s: string): Integer;

    procedure AddFiles(ss: TStrings);
    procedure AnalyseAFile(const FileName: string; AllowException: Boolean = False);
    procedure AnalyseAllFiles(var Errors: string);
    procedure Analysing(b: Boolean);
    procedure UpdateAnalyseResultView(PPI: PPackageInfos); overload;
    procedure UpdateAnalyseResultView(ssUnits, ssRequirePackages: TStrings); overload;
    procedure UpdateAnalyseResultView; overload;
    procedure UpdateControlsState;
    procedure WillDeleteSelected(Sender: TObject);
    procedure CMGetFormIndex(var Message: TMessage); message CM_GETFORMINDEX;
  public
    { Public declarations }
    procedure UIInitialize;
  end;

implementation

uses
  CnCommon, CnBaseUtils;

{$R *.dfm}

const
  CRLF = #13#10;

function StringProcessProc(const s: string): string;
begin
  Result := _CnExtractFileName(s);
end;

procedure TCnEditARFForm.AddFiles(ss: TStrings);
var
  i: Integer;
  tmpSs: TStringList;
begin
  tmpSs := TStringList.Create;
  try
    tmpSs.Assign(lsbFiles.Items);
    tmpSs.Sorted := True;
    for i := 0 to ss.Count - 1 do
    begin
      if FileExists(ss[i]) then
      begin
        tmpSs.Add(ss[i]);
      end;
    end;
    lsbFiles.Items.Assign(tmpSs);
    lsbAddHorizontalScrollBar(lsbFiles);
  finally
    tmpSs.Free;
  end;
end;

procedure TCnEditARFForm.AnalyseAFile(const FileName: string; AllowException: Boolean = False);
begin
  try
    FAnalyseResults.AddFile(FileName);
  except
    if AllowException then
    begin
      raise;
    end;
  end;
end;

procedure TCnEditARFForm.AnalyseAllFiles(var Errors: string);
var
  i: Integer;
begin
  FAnalyseResults.BeginUpdate;
  try
    FAnalyseResults.Clear;
    for i := 0 to lsbFiles.Items.Count - 1 do
    begin
      try
        AnalyseAFile(lsbFiles.Items[i], True);
      except
        on E: Exception do
        begin
          Errors := Errors + E.Message + #13#10;
        end;
      end;
    end;
  finally
    FAnalyseResults.EndUpdate;
  end;
end;

procedure TCnEditARFForm.Analysing(b: Boolean);
begin
  FAnalysing := b;
  UpdateControlsState;
end;

procedure TCnEditARFForm.btnAnalyseAllClick(Sender: TObject);
var
  Errors: string;
begin
  Analysing(True);
  try
    Errors := '';
    AnalyseAllFiles(Errors);
    if Errors <> '' then
    begin
      raise Exception.Create(SCnSomeAnalyzedFailed + Errors);
    end;
  finally
    Analysing(False);
  end;
end;

procedure TCnEditARFForm.btnAnalyseClick(Sender: TObject);
var
  FileName: string;
begin
  if lsbFiles.ItemIndex < 0 then
  begin
    Exit;
  end;

  Analysing(True);
  try
    FileName := GetSelectedFile;
    FAnalyseResults.Delete(IndexOfAnalyseResult(FileName));
    AnalyseAFile(FileName, True);
  finally
    Analysing(False);
  end;
end;

procedure TCnEditARFForm.btnAppendResultsClick(Sender: TObject);
var
  ssSavedModules, ssNames, ssDuplicated: TStringList;
begin
  sdAnalyseResults.Options := sdAnalyseResults.Options - [ofOverwritePrompt];
  if sdAnalyseResults.Execute then
  begin
    ssSavedModules := TStringList.Create;
    ssNames := TStringList.Create;
    ssDuplicated := TStringList.Create;
    try
      if FileExists(sdAnalyseResults.FileName) then
      begin
        StringsLoadFromFileWithSection(ssSavedModules, sdAnalyseResults.FileName, cssExecutableFiles);
      end;
      ssSavedModules.AddStrings(FAnalyseResults);
      if not ExtractFileNames(ssSavedModules, ssNames, ssDuplicated) then
      begin
        raise Exception.CreateFmt(SCnDuplicatedNameFound, [ssDuplicated.Text]);
      end;
      FAnalyseResults.AppendToFile(sdAnalyseResults.FileName);
      ShowMessage(Format(SCnAnalyzedResultsSaved, [AnsiQuotedStr(sdAnalyseResults.FileName, '"')]));
    finally
      ssSavedModules.Free;
      ssNames.Free;
      ssDuplicated.Free;
    end;
  end;
end;

procedure TCnEditARFForm.btnClearFilesClick(Sender: TObject);
begin
  FAnalyseResults.Clear;
  lsbFiles.Clear;
  UpdateControlsState;
end;

procedure TCnEditARFForm.btnOpenFilesClick(Sender: TObject);
begin
  miSelectFiles.Click;
end;

procedure TCnEditARFForm.btnSaveResultsClick(Sender: TObject);
var
  ssNames, ssDuplicated: TStringList;
begin
  sdAnalyseResults.Options := sdAnalyseResults.Options + [ofOverwritePrompt];
  if sdAnalyseResults.Execute then
  begin
    ssNames := TStringList.Create;
    ssDuplicated := TStringList.Create;
    try
      if not ExtractFileNames(FAnalyseResults, ssNames, ssDuplicated) then
      begin
        raise Exception.CreateFmt(SCnDuplicatedNameFound, [ssDuplicated.Text]);
      end;
      FAnalyseResults.SaveToFile(sdAnalyseResults.FileName);
      ShowMessage(Format(SCnAnalyzedResultsSaved, [AnsiQuotedStr(sdAnalyseResults.FileName, '"')]));
    finally
      ssNames.Free;
      ssDuplicated.Free;
    end;
  end;
end;

procedure TCnEditARFForm.CMGetFormIndex(var Message: TMessage);
begin
  Message.Result := 2;
end;

procedure TCnEditARFForm.edtSearchFileChange(Sender: TObject);
var
  OldItemIndex: Integer;
  lsb: TListBox;
begin
  lsb := lsbFiles;
  OldItemIndex := lsb.ItemIndex;
  lsb.Items.BeginUpdate;
  try
    lsb.ItemIndex := -1;
    lsbFindKey(lsb, GetSearchMask(edtSearchFile.Text), True, False, DefaultMatchProc);
  finally
    lsb.Items.EndUpdate;
  end;
  if (lsb.ItemIndex <> OldItemIndex) and Assigned(lsb.OnClick) then
  begin
    lsb.OnClick(lsb);
  end;
end;

procedure TCnEditARFForm.edtSearchFileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  lsb: TListBox;
begin
  lsb := lsbFiles;
  lsbProcessSearchKeyDown(lsb, GetSearchMask(edtSearchFile.Text), Key, Shift);
end;

procedure TCnEditARFForm.FormCreate(Sender: TObject);
begin
  FAnalyseResults := TPackageInfosList.Create;
  FAnalyseResults.Sorted := True;
  FAnalyseResults.StringProcessProc := StringProcessProc;
  SetDlgInitialDir(Self);
end;

procedure TCnEditARFForm.FormDestroy(Sender: TObject);
begin
  FAnalyseResults.Free;
end;

function TCnEditARFForm.GetSelectedFile: string;
begin
  Result := '';
  if lsbFiles.ItemIndex >= 0 then
  begin
    Result := lsbFiles.Items[lsbFiles.ItemIndex];
  end;
end;

function TCnEditARFForm.IndexOfAnalyseResult(const s: string): Integer;
begin
  Result := -1;
  if s = '' then
  begin
    Exit;
  end;

  Result := FAnalyseResults.IndexOf(s);
end;

procedure TCnEditARFForm.lsbFilesClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnEditARFForm.lsbFilesDblClick(Sender: TObject);
begin
  if lsbItemUnderCursor(lsbFiles) >= 0 then
  begin
    btnAnalyse.Click;
  end;
end;

procedure TCnEditARFForm.lsbFilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Sender is TListBox) then
  begin
    lsbDeleteSelected(TListBox(Sender), WillDeleteSelected);
    FPerformUIUpdating := True;
  end;
end;

procedure TCnEditARFForm.lsbFilesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FPerformUIUpdating then
  begin
    lsbAddHorizontalScrollBar(lsbFiles);
    UpdateControlsState;
  end;
end;

procedure TCnEditARFForm.miSelectFilesClick(Sender: TObject);
begin
  if odOpenFiles.Execute then
  begin
    AddFiles(odOpenFiles.Files);
    UpdateControlsState;
  end;
end;

procedure TCnEditARFForm.miSelectFilesFromFileListClick(Sender: TObject);
var
  ss: TStrings;
begin
  if odOpenFilesFrom.Execute then
  begin
    ss := TStringList.Create;
    try
      ss.LoadFromFile(odOpenFilesFrom.FileName);
      AddFiles(ss);
      UpdateControlsState;
    finally
      ss.Free;
    end;
  end;
end;

procedure TCnEditARFForm.UpdateAnalyseResultView;
begin
  UpdateAnalyseResultView(FAnalyseResults.PackageInfos[IndexOfAnalyseResult(GetSelectedFile)]);
end;

procedure TCnEditARFForm.UpdateAnalyseResultView(ssUnits, ssRequirePackages: TStrings);
begin
  SyncMemoWithStrings(ssUnits, mmoUnits);
  SyncMemoWithStrings(ssRequirePackages, mmoRequirePackages);
end;

procedure TCnEditARFForm.UpdateAnalyseResultView(PPI: PPackageInfos);
begin
  if PPI = nil then
  begin
    UpdateAnalyseResultView(nil, nil);
  end
  else
  begin
    UpdateAnalyseResultView(PPI.Units, PPI.RequiredPackages);
  end;
end;

procedure TCnEditARFForm.UpdateControlsState;
var
  bEnabled: Boolean;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    bEnabled := not FAnalysing;

    btnOpenFiles.Enabled := bEnabled;
    btnAnalyse.Enabled := bEnabled and (lsbFiles.ItemIndex >= 0);
    btnAnalyseAll.Enabled := bEnabled and (lsbFiles.Items.Count > 0);
    btnSaveResults.Enabled := bEnabled and (FAnalyseResults.Count > 0);
    btnAppendResults.Enabled := btnSaveResults.Enabled;
    btnClearFiles.Enabled := btnAnalyseAll.Enabled;
    edtSearchFile.Enabled := btnAnalyseAll.Enabled;
    lsbFiles.Enabled := bEnabled;
    mmoUnits.Enabled := btnAnalyse.Enabled;
    mmoRequirePackages.Enabled := btnAnalyse.Enabled;
  finally
    UpdateAnalyseResultView;
    FUIUpdating := False;
  end;
end;

procedure TCnEditARFForm.WillDeleteSelected(Sender: TObject);
var
  i: Integer;
begin
  if Sender = lsbFiles then
  begin
    for i := 0 to lsbFiles.Items.Count - 1 do
    begin
      if lsbFiles.Selected[i] then
      begin
        FAnalyseResults.Delete(IndexOfAnalyseResult(lsbFiles.Items[i]));
      end;
    end;
  end;
end;

procedure TCnEditARFForm.FormResize(Sender: TObject);
begin
  // realign controls
  pnlExeFiles.Width := (gpAnalyse.ClientWidth - sbButtons.Width) * 2 div 5;
  pnlRequiredPackages.Width := (gpAnalyse.ClientWidth - sbButtons.Width) * 3 div 10;
end;

procedure TCnEditARFForm.FormShow(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnEditARFForm.UIInitialize;
begin
  WrapButtonsCaption(gpAnalyseBtns);
end;

initialization
  RegisterFormClass(TCnEditARFForm);

end.
