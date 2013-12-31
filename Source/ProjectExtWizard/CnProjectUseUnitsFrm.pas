{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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
  ImgList, CnProjectViewFormsFrm, CnProjectFramesFrm;

type

//==============================================================================
// 工程组 use 单元列表窗体
//==============================================================================

{ TCnProjectUseUnitsForm }

  TCnProjectUseUnitsForm = class(TCnProjectViewBaseForm)
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure lvListData(Sender: TObject; Item: TListItem);
  private
    procedure FillUnitInfo(AInfo: TCnUnitInfo);
  protected
    function DoSelectOpenedItem: string; override;
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
    { Public declarations }
  end;

function ShowProjectUseUnits(ASelf: TCustomForm): Boolean;

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

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csUseUnits = 'UseUnits';

  UseUnitHelpContext = 3135;
  // ViewDialog 在 UseUnit 被调用时的 HelpContext

  SelectFrameHelpContext = 6030;
  // ViewDialog 在 Select Frame 被调用时的 HelpContext

{ TCnProjectUseUnitsForm }

// 此过程还可能会被插入Frame时调用，因此过程内部根据 HelpContext 分别处理了这俩情况
function ShowProjectUseUnits(ASelf: TCustomForm): Boolean;
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

  ErrList := nil; HasError := False;
  Ini := TCnBaseWizard.CreateIniFile;

  // 判断是引用单元还是添加Frame
  if IsUseUnit then
    AForm := TCnProjectUseUnitsForm.Create(nil)
  else
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
      begin
        AWizard := TCnProjectExtWizard(CnWizardMgr.WizardByClass(TCnProjectExtWizard));
        if AWizard <> nil then
          AWizard.UpdateMethodHook(UseUnitsHookBtnChecked);
      end;

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
              AName := _CnChangeFileExt(TCnUnitInfo(lvList.Items[I].Data).FileName, '')
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
    Result := Trim(TCnUnitInfo(lvList.ItemFocused.Data).FileName);
end;

function TCnProjectUseUnitsForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtUseUnits';
end;

procedure TCnProjectUseUnitsForm.FillUnitInfo(AInfo: TCnUnitInfo);
var
  Reader: TCnEditFiler;
begin
  AInfo.IsOpened := CnOtaIsFileOpen(AInfo.FileName);

  Reader := nil;
  try
    try
      if not AInfo.IsOpened then
      begin
        AInfo.Size := GetFileSize(AInfo.FileName);
      end
      else
      begin
        Reader := TCnEditFiler.Create(AInfo.FileName);
        AInfo.Size := Reader.FileSize;
      end;
    except
      AInfo.Size := 0;
    end;
  finally
    Reader.Free;
  end;

  AInfo.ImageIndex := csUnitImageIndexs[AInfo.UnitType];
end;

procedure TCnProjectUseUnitsForm.OpenSelect;
begin
  if lvList.SelCount > 0 then
    ModalResult := mrOK;
end;

procedure TCnProjectUseUnitsForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(TCnUnitInfo(Item.Data).FileName) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, TCnUnitInfo(Item.Data).FileName)
    else
      DrawCompactPath(StatusBar.Canvas.Handle, Rect,
        TCnUnitInfo(Item.Data).FileName + SCnProjExtNotSave);

    StatusBar.Hint := TCnUnitInfo(Item.Data).FileName;
  end;
end;

procedure TCnProjectUseUnitsForm.CreateList;
var
  ProjectInfo: TCnProjectInfo;
  UnitInfo: TCnUnitInfo;
  i, j: Integer;
  UnitFileName: string;
  IProject: IOTAProject;
  IModuleInfo: IOTAModuleInfo;
  ProjectInterfaceList: TInterfaceList;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
begin
  ProjectInterfaceList := TInterfaceList.Create;
  try
    CnOtaGetProjectList(ProjectInterfaceList);

    try
      for i := 0 to ProjectInterfaceList.Count - 1 do
      begin
        IProject := IOTAProject(ProjectInterfaceList[i]);

        if IProject.FileName = '' then
          Continue;

{$IFDEF BDS}
        // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
        if Supports(IProject, IOTAProjectGroup, ProjectGroup) then
          Continue;
{$ENDIF}

        ProjectInfo := TCnProjectInfo.Create;
        ProjectInfo.Name := _CnExtractFileName(IProject.FileName);
        ProjectInfo.FileName := IProject.FileName;

        // Project 源文件信息无需添加到 UnitInfo
        // 添加模块信息到 PModuleRecord
        for j := 0 to IProject.GetModuleCount - 1 do
        begin
          IModuleInfo := IProject.GetModule(j);
          UnitFileName := IModuleInfo.FileName;

          if UnitFileName = '' then
            Continue;

          if SameText(_CnExtractFileExt(UnitFileName), '.RES') then
            Continue;

          UnitInfo := TCnUnitInfo.Create;
          with UnitInfo do
          begin
            Name := _CnChangeFileExt(_CnExtractFileName(UnitFileName), '');
            FileName := UnitFileName;
            Project := _CnExtractFileName(IProject.FileName);

          {$IFDEF SUPPORT_MODULETYPE}
            // todo: Check ModuleInfo.ModuleType
          {$ELSE}
            if AnsiPos('DataModule', IModuleInfo.DesignClass) > 0 then
              UnitType := utDataModule
            else if IsRC(IModuleInfo.FileName) then
              UnitType := utRC
            else if (IModuleInfo.FormName <> '') then
              UnitType := utForm
            else if IsPas(IModuleInfo.FileName) or IsCpp(IModuleInfo.FileName) then
              UnitType := utUnit
            else if IsAsm(IModuleInfo.FileName) then
              UnitType := utAsm
            else if IsC(IModuleInfo.FileName) then
              UnitType := utC
            else if IsH(IModuleInfo.FileName) then
              UnitType := utH
            else
              UnitType := utUnknown;
          {$ENDIF}
          end;

          FillUnitInfo(UnitInfo);
          ProjectInfo.InfoList.Add(UnitInfo);  // 添加模块信息到 ProjectInfo
        end;
        ProjectList.Add(ProjectInfo);  // PProjectRecord 中包含模块信息
      end;
    except
      raise Exception.Create(SCnProjExtCreatePrjListError);
    end;
  finally
    ProjectInterfaceList.Free;
  end;
end;

procedure TCnProjectUseUnitsForm.UpdateComboBox;
var
  i: Integer;
  ProjectInfo: TCnProjectInfo;
begin
  with cbbProjectList do
  begin
    Clear;
    Items.Add(SCnProjExtProjectAll);
    Items.Add(SCnProjExtCurrentProject);
    if Assigned(ProjectList) then
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        Items.AddObject(_CnExtractFileName(ProjectInfo.Name), ProjectInfo);
      end;
    end;
  end;
end;

procedure TCnProjectUseUnitsForm.DoUpdateListView;
var
  i, ToSelIndex: Integer;
  ProjectInfo: TCnProjectInfo;
  MatchSearchText: string;
  IsMatchAny: Boolean;
  ToSelUnitInfos: TList;

  procedure DoAddProject(AProject: TCnProjectInfo; IsCurrent: Boolean);
  var
    I: Integer;
    UnitInfo: TCnUnitInfo;
  begin
    for I := 0 to AProject.InfoList.Count - 1 do
    begin
      UnitInfo := TCnUnitInfo(AProject.InfoList[I]);
      if (MatchSearchText = '') or
        RegExpContainsText(FRegExpr, UnitInfo.Name, MatchSearchText, not IsMatchAny) then
      begin
        if IsCurrent and (OriginalList.IndexOf(_CnChangeFileExt(UnitInfo.Name, '')) < 0) then // 当前工程，不在列表内，不加
          Continue;

        if UnitInfo.UnitType <> utUnknown then
        begin
          CurrList.Add(UnitInfo);
          // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
          if IsMatchAny and AnsiStartsText(MatchSearchText, UnitInfo.Name) then
            ToSelUnitInfos.Add(Pointer(UnitInfo));
        end;
      end;
    end;
  end;

begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('DoUpdateListView');
{$ENDIF DEBUG}

  ToSelIndex := 0;
  ToSelUnitInfos := TList.Create;

  try
    CurrList.Clear;
    MatchSearchText := edtMatchSearch.Text;
    IsMatchAny := MatchAny;

    if cbbProjectList.ItemIndex <= 0 then  // All Projects
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        DoAddProject(ProjectInfo, False);
      end;
    end
    else if cbbProjectList.ItemIndex = 1 then // Current Project
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        if _CnChangeFileExt(ProjectInfo.FileName, '') = CnOtaGetCurrentProjectFileNameEx then
          DoAddProject(ProjectInfo, True);
      end;
    end
    else
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        if cbbProjectList.Items.Objects[cbbProjectList.ItemIndex] <> nil then
          if TCnProjectInfo(cbbProjectList.Items.Objects[cbbProjectList.ItemIndex]).FileName
            = ProjectInfo.FileName then
          begin
            DoAddProject(ProjectInfo, _CnChangeFileExt(ProjectInfo.FileName, '') = CnOtaGetCurrentProjectFileNameEx);
          end;
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
  CnDebugger.LogLeave('DoUpdateListView');
{$ENDIF DEBUG}
end;

procedure TCnProjectUseUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount, [ProjectList.Count]);
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectUseUnitsForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
  if Assigned(Item) and TCnUnitInfo(Item.Data).IsOpened then
    ListView.Canvas.Font.Color := clRed;
end;

procedure TCnProjectUseUnitsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < CurrList.Count) then
  begin
    Info := TCnUnitInfo(CurrList[Item.Index]);
    Item.Caption := Info.Name;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(SUnitTypes[Info.UnitType]);
      Add(Info.Project);
      Add(IntToStrSp(Info.Size));
      if Info.Size > 0 then
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
  Info1, Info2: TCnUnitInfo;
begin
  Info1 := TCnUnitInfo(Item1);
  Info2 := TCnUnitInfo(Item2);
  
  case _SortIndex of
    0: Result := CompareTextPos(_MatchStr, Info1.Name, Info2.Name);
    1: Result := CompareText(SUnitTypes[Info1.UnitType], SUnitTypes[Info2.UnitType]);
    2: Result := CompareText(Info1.Project, Info2.Project);
    3, 4: Result := CompareValue(Info1.Size, Info2.Size);
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

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
