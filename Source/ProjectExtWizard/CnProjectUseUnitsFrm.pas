{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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

unit CnProjectUseUnitsFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组单元列表单元
* 单元作者：刘啸（liuxiao@cnpack.org）
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2007.04.01 V1.0
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
  Graphics, CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm, CnProjectViewUnitsFrm,
  CnWizEditFiler, CnProjectExtWizard, CnWizClasses, CnWizManager, ActnList,
  ImgList, CnProjectViewFormsFrm, CnProjectFramesFrm, CnInputSymbolList;

type
  TCnUseUnitInfo = class
  public
    Name: string;
    FullNameWithPath: string; // 带路径的完整文件名
    IsInProject: Boolean;
    IsOpened: Boolean;
    IsSaved: Boolean;
    ImageIndex: Integer;
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rbIntfKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbImplKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbIntfDblClick(Sender: TObject);
  private
    FIsCppMode: Boolean;
    FUsesList: TObjectList; // 存储所有的 UseUnitInfo
    FUnitNameListRef: TUnitNameList;
    procedure FillUnitInfo(AInfo: TCnUseUnitInfo);
    function SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
      out CharPos: TOTACharPos): Boolean;
    function SearchCppInsertPos(IsH: Boolean; out CharPos: TOTACharPos; SourceEditor: IOTASourceEditor = nil): Boolean;
  protected
    function DoSelectOpenedItem: string; override;
    procedure DoSelectItemChanged(Sender: TObject); override;
    function GetSelectedFileName: string; override;
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure DoUpdateListView; override;
    procedure DoSortListView; override;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;
  public
    constructor Create(AOwner: TComponent; CppMode: Boolean;
      UnitNameList: TUnitNameList); reintroduce;

    property IsCppMode: Boolean read FIsCppMode write FIsCppMode;
    property UnitNameListRef: TUnitNameList read FUnitNameListRef write FUnitNameListRef;
  end;

function ShowProjectInsertFrame(ASelf: TCustomForm): Boolean;

// UnitNameList 允许外部传入，避免每次打开 Form 时加载过慢
function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TUnitNameList): Boolean;

var
  Ini: TCustomIniFile = nil;
  // 用来传递保存参数，因为Hook的部分只能传Self，无法传其他参数
  OriginalList: TStrings = nil;
  NeedUpdateMethodHook: Boolean = True;
  // 供ProjectExtWizard控制本窗口是否需要重复UpdteMethod的参数
  IsUseUnit: Boolean;

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

  SelectFrameHelpContext = 6030;
  // ViewDialog 在 Select Frame 被调用时的 HelpContext

{ TCnUseUnitInfo }

function ShowProjectUseUnits(Ini: TCustomIniFile; out Hooked: Boolean;
  var UnitNameList: TUnitNameList): Boolean;
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
        UnitNameList := TUnitNameList.Create(True, True);
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
        UnitNameList := TUnitNameList.Create(True, False);
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

      Result := ShowModal = mrOk;
      Hooked := actHookIDE.Checked;
      SaveSettings(Ini, csUseUnits);
      UnitNameListRef := nil;
    finally
      Free;
    end;
  end;
end;


// 此过程还可能会被插入 Frame 时调用，因此过程内部根据 HelpContext 分别处理了这俩情况
function ShowProjectInsertFrame(ASelf: TCustomForm): Boolean;
var
  I, Idx: Integer;
  AListBox: TListBox;
  AName: string;
  AWizard: TCnProjectExtWizard;
  ErrList: TStrings;
  HasError: Boolean;
  AForm: TCnProjectViewBaseForm;
begin
  Result := False;
  AListBox := nil;
  if ASelf <> nil then
  begin
    OriginalList := TStringList.Create;
    for I := 0 to ASelf.ComponentCount - 1 do
    begin
      if ASelf.Components[I] is TListBox then
      begin
        AListBox := TListBox(ASelf.Components[I]);
        OriginalList.Assign(AListBox.Items);
        Break;
      end;
    end;
  end;

  if AListBox = nil then
  begin
    UseUnitsHookBtnChecked := False;
    Result := False;
    Exit;
  end;
  
{$IFDEF DEBUG}
  CnDebugger.LogInteger(ASelf.HelpContext, 'ViewDialog HelpContext ');
{$ENDIF}

  IsUseUnit := ASelf.HelpContext = UseUnitHelpContext;
  if not IsUseUnit and (ASelf.HelpContext <> SelectFrameHelpContext) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjectExt: ViewDialog HelpContext Both Error. Exit.');
{$ENDIF}
    Exit;
  end;

  ErrList := nil;
  HasError := False;
  AWizard := TCnProjectExtWizard(CnWizardMgr.WizardByClass(TCnProjectExtWizard));
  Ini := AWizard.CreateIniFile;

  // 判断是引用单元还是添加Frame
//  if IsUseUnit then
//    AForm := TCnProjectUseUnitsForm.Create(nil)
//  else
    AForm := TCnProjectFramesForm.Create(nil);

  with AForm do
  begin
    try
      btnQuery.Visible := False; // 无需此提示
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csUseUnits);

      // 默认先打开当前工程
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtCurrentProject);
      if Assigned(cbbProjectList.OnChange) then
        cbbProjectList.OnChange(cbbProjectList);

      Result := ShowModal = mrOk;

      UseUnitsHookBtnChecked := actHookIDE.Checked;
      SaveSettings(Ini, csUseUnits);
      if NeedUpdateMethodHook then
        AWizard.UpdateMethodHook(UseUnitsHookBtnChecked);

      if Result then
      begin
        try
          for I := 0 to AListBox.Items.Count - 1 do
            AListBox.Selected[I] := False;
        except
          ;
        end;
        AListBox.ItemIndex := -1; // Select Nothing

        for I := 0 to lvList.Items.Count - 1 do
        begin
          if lvList.Items[I].Selected then
          begin
            if IsUseUnit then
              AName := _CnChangeFileExt(TCnUseUnitInfo(lvList.Items[I].Data).FullNameWithPath, '')
            else
              AName := _CnChangeFileExt(TCnFormInfo(lvList.Items[I].Data).Name, '');

            AName := _CnExtractFileName(AName);
            Idx := OriginalList.IndexOf(AName);
            if Idx >= 0 then
            begin
              try
                AListBox.Selected[Idx] := True;
              except
                AListBox.ItemIndex := Idx;
              end;
            end
            else
            begin
              HasError := True;
              if ErrList = nil then
                ErrList := TStringList.Create;
              ErrList.Add(AName);
            end;
          end;
        end;

        if HasError then
          ErrorDlg(SCnProjExtErrorInUse + #13#10#13#10 + ErrList.Text);
        BringIdeEditorFormToFront;
      end;
    finally
      Free;
      FreeAndNil(Ini);
      FreeAndNil(ErrList);
      FreeAndNil(OriginalList);
    end;
  end;
end;

//==============================================================================
// 工程组 uses 列表窗体
//==============================================================================

{ TCnProjectUseUnitsForm }

constructor TCnProjectUseUnitsForm.Create(AOwner: TComponent; CppMode: Boolean;
  UnitNameList: TUnitNameList);
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
  S, F: string;

  // 根据源码类型得到插入的 uses 或 include 字符串，FileHasUses 只对 Pascal 代码
  // 有效、IsHFromSystem 只对 Cpp 文件有效
  function JoinUsesOrInclude(FileHasUses: Boolean; IsHFromSystem: Boolean;
    const IncFile: string): string;
  begin
    if FIsCppMode then
    begin
      if IsHFromSystem then
        Result := Format('#include <%s>' + #13#10, [IncFile])
      else
        Result := Format('#include "%s"' + #13#10, [IncFile]);
    end
    else
    begin
      if FileHasUses then
        Result := Format(', %s', [IncFile])
      else
        Result := Format(#13#10#13#10 + 'uses' + #13#10 + '%s%s;',
          [Spc(CnOtaGetBlockIndent), IncFile]);
    end;
  end;

begin
  if lvList.SelCount > 0 then
  begin
    ModalResult := mrOk;
    S := lvList.Selected.Caption;
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
      if not SearchCppInsertPos(IsIntfOrH, CharPos, SrcEditor) then
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
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(HasUses, IsFromSystem, S),
        LinearPos, SrcEditor);
    end
    else
    begin
      // Pascal 只需要使用当前文件的 EditView 插入 uses，还得处理无 uses 的情况
      if not SearchPasInsertPos(IsIntfOrH, HasUses, CharPos) then
      begin
        ErrorDlg(SCnProjExtUsesNoPasPosition);
        Exit;
      end;

      // 已经得到行 1 列 0 开始的 CharPos，用 EditView.CharPosToPos(CharPos) 转换为线性;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(HasUses, False, S), LinearPos);
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

procedure TCnProjectUseUnitsForm.CreateList;
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
    if FUsesList = nil then
      FUsesList := TObjectList.Create(True)
    else
      FUsesList.Clear;

    Names := TStringList.Create;
    Paths := TStringList.Create;
    UsesList := TStringList.Create;
    Stream := TMemoryStream.Create;

    FUnitNameListRef.DoInternalLoad;
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
      Info.Name := Names[I];
      Info.FullNameWithPath := Paths[I];
      Info.IsInProject := Integer(Names.Objects[I]) <> 0;
      FillUnitInfo(Info);
      FUsesList.Add(Info);
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
  // Do nothing about combobox because hidden.
end;

procedure TCnProjectUseUnitsForm.DoUpdateListView;
var
  I, ToSelIndex: Integer;
  MatchSearchText: string;
  IsMatchAny: Boolean;
  ToSelUnitInfos: TList;
  UnitInfo: TCnUseUnitInfo;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnProjectUseUnitsForm DoUpdateListView');
{$ENDIF DEBUG}

  ToSelIndex := 0;
  ToSelUnitInfos := TList.Create;

  try
    CurrList.Clear;
    MatchSearchText := edtMatchSearch.Text;
    IsMatchAny := MatchAny;

    for I := 0 to FUsesList.Count - 1 do
    begin
      UnitInfo := TCnUseUnitInfo(FUsesList[I]);
      if (MatchSearchText = '') or
        RegExpContainsText(FRegExpr, UnitInfo.Name, MatchSearchText, not IsMatchAny) then
      begin
        CurrList.Add(UnitInfo);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and AnsiStartsText(MatchSearchText, UnitInfo.Name) then
          ToSelUnitInfos.Add(Pointer(UnitInfo));
      end;
    end;

    DoSortListView;

    lvList.Items.Count := CurrList.Count;
    lvList.Invalidate;

    UpdateStatusBar;

    // 如有需要选中的首匹配的项则选中，无则选 0，第一项
    if (ToSelUnitInfos.Count > 0) and (CurrList.Count > 0) then
    begin
      for I := 0 to CurrList.Count - 1 do
      begin
        if ToSelUnitInfos.IndexOf(CurrList.Items[I]) >= 0 then
        begin
          // CurrList 中的第一个在 SelUnitInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;
    SelectItemByIndex(ToSelIndex);
  finally
    ToSelUnitInfos.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnProjectUseUnitsForm DoUpdateListView');
{$ENDIF DEBUG}
end;

procedure TCnProjectUseUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := '';
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectUseUnitsForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
  if Assigned(Item) and TCnUseUnitInfo(Item.Data).IsOpened then
    ListView.Canvas.Font.Color := clRed;
end;

procedure TCnProjectUseUnitsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUseUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < CurrList.Count) then
  begin
    Info := TCnUseUnitInfo(CurrList[Item.Index]);
    Item.Caption := Info.Name;
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
        Add(SNotSaved);
    end;
    RemoveListViewSubImages(Item);
  end;
end;

var
  _SortIndex: Integer;
  _SortDown: Boolean;
  _MatchStr: string;

function DoListSort(Item1, Item2: Pointer): Integer;
var
  Info1, Info2: TCnUseUnitInfo;
begin
  Info1 := TCnUseUnitInfo(Item1);
  Info2 := TCnUseUnitInfo(Item2);
  
  case _SortIndex of
    0: Result := CompareTextPos(_MatchStr, Info1.Name, Info2.Name);
    1: Result := CompareTextPos(_MatchStr, Info1.FullNameWithPath, Info2.FullNameWithPath);
    2: Result := CompareInt(Ord(Info1.IsInProject), Ord(Info2.IsInProject));
    3: Result := CompareInt(Ord(Info1.IsSaved), Ord(Info2.IsSaved));
  else
    Result := 0;
  end;

  if _SortDown then
    Result := -Result;
end;

procedure TCnProjectUseUnitsForm.DoSortListView;
var
  Sel: Pointer;
begin
  if lvList.Selected <> nil then
    Sel := lvList.Selected.Data
  else
    Sel := nil;

  _SortIndex := SortIndex;
  _SortDown := SortDown;
  if MatchAny then
    _MatchStr := edtMatchSearch.Text
  else
    _MatchStr := '';
  CurrList.Sort(DoListSort);
  lvList.Invalidate;

  if Sel <> nil then
    SelectItemByIndex(CurrList.IndexOf(Sel));
end;

procedure TCnProjectUseUnitsForm.FormCreate(Sender: TObject);
begin
  FUsesList := TObjectList.Create(True);
  inherited;
end;

procedure TCnProjectUseUnitsForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FUsesList.Free;
end;

function TCnProjectUseUnitsForm.SearchCppInsertPos(IsH: Boolean;
  out CharPos: TOTACharPos; SourceEditor: IOTASourceEditor): Boolean;
var
  Stream: TMemoryStream;
  LastIncLine: Integer;
{$IFDEF UNICODE}
  CParser: TCnBCBWideTokenList;
{$ELSE}
  CParser: TBCBTokenList;
{$ENDIF}
begin
  // 插在最后一个 include 前面。如无 include，h 文件和 cpp 处理还不同。
  Result := False;
  Stream := nil;
  CParser := nil;

  try
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStreamW(SourceEditor, Stream, False);
    CParser.SetOrigin(PWideChar(Stream.Memory), Stream.Size div SizeOf(Char));
{$ELSE}
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStream(SourceEditor, Stream, False);
    CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}

    LastIncLine := -1;
    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
{$IFDEF UNICODE}
        LastIncLine := CParser.LineNumber;
{$ELSE}
        LastIncLine := CParser.RunLineNumber;
{$ENDIF}
      end;
      CParser.NextNonJunk;
    end;

    if LastIncLine >= 0 then
    begin
      Result := True;
      CharPos.Line := LastIncLine + 1; // 最后一个 inc 的行首
      CharPos.CharIndex := 0;
    end;
  finally
    CParser.Free;
    Stream.Free;
  end;
end;

function TCnProjectUseUnitsForm.SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
{$IFDEF UNICODE}
  Lex: TCnPasWideLex;
  LineText: string;
  S: AnsiString;
{$ELSE}
  Lex: TmwPasLex;
  {$IFDEF IDE_STRING_ANSI_UTF8}
  LineText: string;
  S: AnsiString;
  {$ENDIF}
{$ENDIF}
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfLine, ImplLine: Integer;
begin
  Result := False;
  Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
  Lex := TCnPasWideLex.Create;
  CnOtaSaveCurrentEditorToStreamW(Stream, False);
{$ELSE}
  Lex := TmwPasLex.Create;
  CnOtaSaveCurrentEditorToStream(Stream, False);
{$ENDIF}

  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfLine := 0;
  ImplLine := 0;

  CharPos.Line := 0;
  CharPos.CharIndex := -1;

  try
{$IFDEF UNICODE}
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // 到达了自己需要的 uses 处
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // 插入位置就在分号前
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // 不明白 Unicode 环境里的 TOTACharPos 为什么也需要做 Utf8 转换
{$ELSE}
              CharPos.Line := Lex.LineNumber + 1;
              CharPos.CharIndex := Lex.TokenPos - Lex.LinePos;
  {$IFDEF IDE_STRING_ANSI_UTF8}
              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));
  {$ENDIF}
{$ENDIF}
              Exit;
            end
            else // uses 后找不着分号，出错
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;
{$IFDEF UNICODE}
          IntfLine := Lex.LineNumber;
{$ELSE}
          IntfLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;
{$IFDEF UNICODE}
          ImplLine := Lex.LineNumber;
{$ELSE}
          ImplLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      end;
      Lex.Next;
    end;

    // 解析完毕，到此处是没有 uses 的情形
    if IsIntf and MeetIntf then    // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      CharPos.Line := ImplLine;
      CharPos.CharIndex := Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
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

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
