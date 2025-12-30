{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnProjectUseUnitsFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组单元列表单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2018.03.29 V1.1
*               重构以支持模糊匹配
*           2007.04.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics,  ActnList, ImgList, CnCommon, CnConsts, CnWizConsts, CnWizOptions,
  CnWizUtils, CnIni, CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm,
  CnProjectViewUnitsFrm, CnWizEditFiler, CnProjectExtWizard, CnWizClasses,
  CnWizManager,CnProjectViewFormsFrm, CnInputSymbolList, CnStrings;

type
  TCnUseUnitInfo = class(TCnBaseElementInfo)
  public
    FullNameWithPath: string; // 带路径的完整文件名
    IsInProject: Boolean;
    IsOpened: Boolean;
    IsSaved: Boolean;
  end;

//==============================================================================
// 工程组 use 单元列表窗体
//==============================================================================

{ TCnProjectUseUnitsForm }

  TCnProjectUseUnitsForm = class(TCnProjectViewBaseForm)
    rbIntf: TRadioButton;
    rbImpl: TRadioButton;
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure rbIntfKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbImplKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbIntfDblClick(Sender: TObject);
    procedure cbbProjectListChange(Sender: TObject);
  private
    FIsCppMode: Boolean;
    FUnitNameListRef: TCnUnitNameList;
    procedure FillUnitInfo(AInfo: TCnUseUnitInfo);
  protected
    function DoSelectOpenedItem: string; override;
    procedure DoSelectItemChanged(Sender: TObject); override;
    function GetSelectedFileName: string; override;
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;

    procedure UpdateComboBox; override;
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); override;

    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;
  public
    constructor Create(AOwner: TComponent; CppMode: Boolean;
      UnitNameList: TCnUnitNameList); reintroduce;

    procedure InternalCreateList;
    property IsCppMode: Boolean read FIsCppMode write FIsCppMode;
    property UnitNameListRef: TCnUnitNameList read FUnitNameListRef write FUnitNameListRef;
  end;

// UnitNameList 允许外部传入，避免每次打开 Form 时加载过慢
function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TCnUnitNameList): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnPasWideLex, CnBCBWideTokenList,
  mPasLex, mwBCBTokenList, CnPasCodeParser, CnCppCodeParser;

const
  SProject = 'Project';
  csUseUnits = 'UseUnitsAndHdr';

  UseUnitHelpContext = 3135;
  // ViewDialog 在 UseUnit 被调用时的 HelpContext

{ TCnUseUnitInfo }

function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TCnUnitNameList): Boolean;
var
  IsCppMode: Boolean;
  OldCursor: TCursor;
begin
  if CurrentSourceIsC then
  begin
    IsCppMode := True;
    if UnitNameList = nil then
    begin
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        UnitNameList := TCnUnitNameList.Create(True, True, False);
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
  end
  else
  begin
    IsCppMode := False;
    if UnitNameList = nil then
    begin
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        UnitNameList := TCnUnitNameList.Create(True, False, False);
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
  end;

  with TCnProjectUseUnitsForm.Create(nil, IsCppMode, UnitNameList) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csUseUnits);
      InternalCreateList;

      Result := ShowModal = mrOk;
      Hooked := actHookIDE.Checked;
      SaveSettings(Ini, csUseUnits);
      UnitNameListRef := nil;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// 工程组 uses 列表窗体
//==============================================================================

{ TCnProjectUseUnitsForm }

constructor TCnProjectUseUnitsForm.Create(AOwner: TComponent; CppMode: Boolean;
  UnitNameList: TCnUnitNameList);
begin
  FIsCppMode := CppMode;
  FUnitNameListRef := UnitNameList;
  inherited Create(AOwner);
end;

function TCnProjectUseUnitsForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnProjectUseUnitsForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(TCnUseUnitInfo(lvList.ItemFocused.Data).FullNameWithPath);
end;

function TCnProjectUseUnitsForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtUseUnits';
end;

procedure TCnProjectUseUnitsForm.FillUnitInfo(AInfo: TCnUseUnitInfo);
begin
  AInfo.IsOpened := CnOtaIsFileOpen(AInfo.FullNameWithPath);
  AInfo.IsSaved := FileExists(AInfo.FullNameWithPath);

  AInfo.ImageIndex := 78; // Unit Icon
end;

procedure TCnProjectUseUnitsForm.OpenSelect;
var
  CharPos: TOTACharPos;
  Info: TCnUseUnitInfo;
  IsIntfOrH: Boolean;
  IsFromSystem: Boolean;
  EditView: IOTAEditView;
  SrcEditor: IOTASourceEditor;
  HasUses: Boolean;
  LinearPos: LongInt;
  Sl: TStrings;
  F: string;
  J: Integer;
begin
  if lvList.SelCount > 0 then
  begin
    ModalResult := mrOk;
    Sl := TStringList.Create;
    for J := 0 to lvList.Items.Count - 1 do
      if lvList.Items[J].Selected then
        Sl.Add(lvList.Items[J].Caption);

    IsIntfOrH := rbIntf.Checked;
    EditView := CnOtaGetTopMostEditView;
    if EditView = nil then
      Exit;

    if FIsCppMode then
    begin
      // 获取 Cpp 或 H 的 EditView 与 SourceEditor
      F := EditView.Buffer.FileName;
      SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);

      if IsIntfOrH and not (IsH(F) or IsHpp(F)) then
      begin
        F := _CnChangeFileExt(F, '.h');
        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);
      end
      else if not IsIntfOrH and not IsCpp(F) then
      begin
        F := _CnChangeFileExt(f, '.cpp');
        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        SrcEditor := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, F);
      end;

      if (EditView = nil) or (SrcEditor = nil) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsgError('Insert include: No EditView or SourceEditor.');
{$ENDIF}
        Exit;
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('EditView and SourceEditor Got. %s - %s', [EditView.Buffer.FileName,
        SrcEditor.FileName]);
{$ENDIF}

      // 插入 include
      if not SearchUsesInsertPosInCurrentCpp(CharPos, SrcEditor) then
      begin
        ErrorDlg(SCnProjExtUsesNoCppPosition);
        Exit;
      end;

      Info := TCnUseUnitInfo(lvList.Selected.Data);
      if Info <> nil then
        IsFromSystem := not Info.IsInProject
      else
        IsFromSystem := False;

      // 已经得到行 1 列 0 开始的 CharPos，用 EditView.CharPosToPos(CharPos) 转换为线性;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(FIsCppMode, HasUses, IsFromSystem, Sl),
        LinearPos, SrcEditor);
    end
    else
    begin
      // Pascal 只需要使用当前文件的 EditView 插入 uses，还得处理无 uses 的情况
      if not SearchUsesInsertPosInCurrentPas(IsIntfOrH, HasUses, CharPos) then
      begin
        ErrorDlg(SCnProjExtUsesNoPasPosition);
        Exit;
      end;

      // 已经得到行 1 列 0 开始的 CharPos，用 EditView.CharPosToPos(CharPos) 转换为线性;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(FIsCppMode, HasUses, False, Sl), LinearPos);
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(TCnUseUnitInfo(Item.Data).FullNameWithPath) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, TCnUseUnitInfo(Item.Data).FullNameWithPath)
    else
      DrawCompactPath(StatusBar.Canvas.Handle, Rect,
        TCnUseUnitInfo(Item.Data).FullNameWithPath + SCnProjExtNotSave);

    StatusBar.Hint := TCnUseUnitInfo(Item.Data).FullNameWithPath;
  end;
end;

procedure TCnProjectUseUnitsForm.InternalCreateList;
var
  I, Idx: Integer;
  Stream: TMemoryStream;
  UsesList: TStringList;
  Names: TStringList;
  Paths: TStringList;
  Info: TCnUseUnitInfo;
begin
  Names := nil;
  Paths := nil;
  UsesList := nil;
  Stream := nil;

  if FIsCppMode then
  begin
    rbIntf.Caption := SCnProjExtCppHead;
    rbImpl.Caption := SCnProjExtCppSource;
  end
  else
  begin
    rbIntf.Caption := SCnProjExtPasIntf;
    rbImpl.Caption := SCnProjExtPasImpl;
  end;

  try
    ClearDataList;

    Names := TStringList.Create;
    Paths := TStringList.Create;
    UsesList := TStringList.Create;
    Stream := TMemoryStream.Create;

    // 如果未选择全部，则不搜索路径
    FUnitNameListRef.DoInternalLoad(cbbProjectList.ItemIndex = 0);
    FUnitNameListRef.ExportToStringList(Names, Paths);

    // 此时得到了所有可引用的单元列表
    CnOtaSaveCurrentEditorToStream(Stream, False);
    if FIsCppMode then
      ParseUnitIncludes(PAnsiChar(Stream.Memory), UsesList)
    else
      ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);

    if not FIsCppMode then // Pascal 不 uses 自己
    begin
      Idx := Names.IndexOf(_CnChangeFileExt(_CnExtractFileName(CnOtaGetCurrentSourceFile), ''));
      if Idx >= 0 then
      begin
        Names.Delete(Idx);
        Paths.Delete(Idx);
      end;
    end;

    for I := 0 to UsesList.Count - 1 do
    begin
      Idx := Names.IndexOf(UsesList[I]);
      if Idx >= 0 then
      begin
        Names.Delete(Idx);
        Paths.Delete(Idx);
      end;
    end;

    for I := 0 to Names.Count - 1 do
    begin
      Info := TCnUseUnitInfo.Create;
      Info.Text := Names[I];
      Info.FullNameWithPath := Paths[I];
      Info.IsInProject := Integer(Names.Objects[I]) <> 0;
      FillUnitInfo(Info);
      DataList.AddObject(Info.Text, Info);
    end;
  finally
    UsesList.Free;
    Stream.Free;
    Names.Free;
    Paths.Free;
  end;
end;

procedure TCnProjectUseUnitsForm.UpdateComboBox;
begin
  with cbbProjectList do // 前两项与基类相同，因此搜索时可利用基类的 ProjectInfo
  begin
    Clear;
    Items.Add(SCnProjExtProjectAll);
    Items.Add(SCnProjExtCurrentProject);
  end;
end;

procedure TCnProjectUseUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := '';
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectUseUnitsForm.DrawListPreParam(Item: TListItem; ListCanvas: TCanvas);
begin
  if Assigned(Item) and (Item.Data <> nil) and TCnUseUnitInfo(Item.Data).IsOpened then
    ListCanvas.Font.Color := clGreen;
end;

procedure TCnProjectUseUnitsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUseUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnUseUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(_CnExtractFileDir(Info.FullNameWithPath));
      if Info.IsInProject then
        Add(SProject)
      else
        Add('');

      if Info.IsSaved then
        Add('')
      else
        Add(SCnProjExtNotSaved);
    end;
    RemoveListViewSubImages(Item);
  end;
end;

procedure TCnProjectUseUnitsForm.DoSelectItemChanged(Sender: TObject);
var
  Item: TListItem;
  Info: TCnUseUnitInfo;
begin
  inherited;
  Item := lvList.Selected;
  if Item <> nil then
  begin
    Info := TCnUseUnitInfo(Item.Data);
    if Info <> nil then
    begin
      rbIntf.Checked := not Info.IsInProject; // 系统库默认往 intf / h 文件中加
      rbImpl.Checked := Info.IsInProject;
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.rbIntfKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_LEFT then
    edtMatchSearch.SetFocus
  else if Key = VK_RIGHT then
  begin
    rbIntf.Checked := False;
    rbImpl.Checked := True;
    rbImpl.SetFocus;
  end;
end;

procedure TCnProjectUseUnitsForm.rbImplKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_LEFT then
  begin
    rbIntf.Checked := True;
    rbImpl.Checked := False;
    rbIntf.SetFocus;
  end;
end;

procedure TCnProjectUseUnitsForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RIGHT then
  begin
    if edtMatchSearch.SelStart = Length(edtMatchSearch.Text) then
    begin
      if rbIntf.Checked then
      begin
        rbIntf.Checked := False;
        rbImpl.Checked := True;
        rbImpl.SetFocus;
      end
      else
      begin
        rbIntf.Checked := True;
        rbImpl.Checked := False;
        rbIntf.SetFocus;
      end;
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.rbIntfDblClick(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnProjectUseUnitsForm.CreateList;
begin
  // 不在 CreateList 里处理，改在迟来的 InternalCreateList 里处理
end;

procedure TCnProjectUseUnitsForm.cbbProjectListChange(Sender: TObject);
var
  Old: TCursor;
begin
  Old := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    InternalCreateList;
  finally
    Screen.Cursor := Old;
  end;
  inherited;
end;

function TCnProjectUseUnitsForm.CanMatchDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean;
var
  Info: TCnUseUnitInfo;
begin
  Result := False;

  // 先限定工程，工程不符合条件的先剔除
  Info := TCnUseUnitInfo(DataList.Objects[DataListIndex]);
  if (ProjectInfoSearch <> nil) and not Info.IsInProject then
    Exit;

  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  case AMatchMode of // 搜索时单元名参与匹配，不区分大小写
    mmStart:
      begin
        Result := (Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) = 1);
      end;
    mmAnywhere:
      begin
        Result := (Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) > 0);
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes);
      end;
  end;
end;

function TCnProjectUseUnitsForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnUseUnitInfo;
begin
  Info1 := TCnUseUnitInfo(Obj1);
  Info2 := TCnUseUnitInfo(Obj2);

  case ASortIndex of // 因为搜索时只有名称一列参与匹配，因此排序时要考虑到把名称匹配时的全匹配提前
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
      end;
    1: Result := CompareText(Info1.FullNameWithPath, Info2.FullNameWithPath);
    2: Result := CompareInt(Ord(Info1.IsInProject), Ord(Info2.IsInProject));
    3: Result := CompareInt(Ord(Info1.IsSaved), Ord(Info2.IsSaved));
  else
    Result := 0;
  end;

  if SortDown and (ASortIndex in [1..3]) then
    Result := -Result;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
