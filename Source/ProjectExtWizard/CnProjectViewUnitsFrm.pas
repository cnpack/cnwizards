{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnProjectViewUnitsFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组单元列表单元
* 单元作者：张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.2.22 V2.1
*               重写所有代码
*           2004.2.18 V2.0 by Leeon
*               更改两个列表框架
*           2003.11.18 V1.9
*               修正打开单元后光标不出现的问题
*           2003.11.16 V1.8
*               新增打开多个文件时是否提示的功能
*           2003.10.30 V1.7 by yygw
*               修正排序后窗体显示时有时不能显示当前单元的问题
*           2003.10.16 V1.6
*               新增自动选择当前打开的单元并使之可见
*           2003.8.08 V1.5
*               删除显示代码行的功能
*           2003.6.28 V1.4
*               将 Record 类型改成了 class 类型，修复了一些错误
*           2003.6.26 V1.3
*               新增挂接 IDE 功能
*           2003.6.17 V1.2
*               新增显示文件属性、优化了大量代码
*           2003.6.6 V1.1
*               新增匹配输入功能
*           2003.5.28 V1.0
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
  CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm, CnWizEditFiler,
  ImgList, ActnList;

type

  TCnUnitType = (utUnknown, utProject, utPackage, utDataModule, utForm, utUnit,
    utAsm, utC, utH, utRC);

  TCnUnitInfo = class
  public
    Name: string;
    FileName: string;
    Project: string;
    Size: Integer;
    UnitType: TCnUnitType;
    IsOpened: Boolean;
    ImageIndex: Integer;
  end;

//==============================================================================
// 工程组单元列表窗体
//==============================================================================

{ TCnProjectViewUnitsForm }

  TCnProjectViewUnitsForm = class(TCnProjectViewBaseForm)
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

const
  SUnitTypes: array[TCnUnitType] of string =
    ('Unknown', 'Project', 'Package', 'DataModule', 'Unit(Form)', 'Unit',
     'Asm ','C', 'H', 'RC');
  SNotSaved = 'Not Saved';
  csViewUnits = 'ViewUnits';

  csUnitImageIndexs: array[TCnUnitType] of Integer =
    (-1, 76, 77, 73, 67, 78, 79, 80, 81, 89);
  
function ShowProjectViewUnits(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

{ TCnProjectViewUnitsForm }

function ShowProjectViewUnits(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;
begin
  with TCnProjectViewUnitsForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csViewUnits);
      Result := ShowModal = mrOk;
      Hooked := actHookIDE.Checked;
      SaveSettings(Ini, csViewUnits);
      if Result then
        BringIdeEditorFormToFront;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// 工程组单元列表窗体
//==============================================================================

{ TCnProjectViewUnitsForm }

function TCnProjectViewUnitsForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnProjectViewUnitsForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(TCnUnitInfo(lvList.ItemFocused.Data).FileName);
end;

function TCnProjectViewUnitsForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtViewUnits';
end;

procedure TCnProjectViewUnitsForm.FillUnitInfo(AInfo: TCnUnitInfo);
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

procedure TCnProjectViewUnitsForm.OpenSelect;
var
  Item: TListItem;

  procedure OpenItem(const FilePath: string);
  begin
    // CnOtaMakeSourceVisible(FilePath);  // 这样打开可能会导致无 ctView 通知
    // CnOtaOpenFile(FilePath); // 但这样打开Project文件时会导致重新打开所有文件
                                // 并且 BCB 5/6 下会只打开窗体而不打开 CPP 文件

    // 所以必须加上这样的判断，也牺牲了打开Project Source与BCB 5/6 CPP打开时的通知
    if IsDpr(FilePath) or IsPackage(FilePath) or IsBdsProject(FilePath) or
      IsDProject(FilePath) or IsBpr(FilePath) or IsCbProject(FilePath) or IsBpg(FilePath)
      {$IFNDEF BDS} or IsCppSourceModule(FilePath) {$ENDIF} then
    begin
      CnOtaMakeSourceVisible(FilePath);
    end
    else
    begin
      CnOtaOpenFile(FilePath);
    end;
  end;

  procedure OpenSelectedItem;
  var
    i: Integer;
  begin
    BeginBatchOpenClose;
    try
      for i := 0 to Pred(lvList.Items.Count) do
        if lvList.Items.Item[i].Selected then
          OpenItem(TCnUnitInfo(lvList.Items.Item[i].Data).FileName);
    finally
      EndBatchOpenClose;
    end;
  end;

begin
  Item := lvList.Selected;

  if not Assigned(Item) then
    Exit;

  if lvList.SelCount <= 1 then
    OpenItem(TCnUnitInfo(Item.Data).FileName)
  else
  begin
    if actQuery.Checked then
      if not QueryDlg(SCnProjExtOpenUnitWarning, False, SCnInformation) then
        Exit;

    OpenSelectedItem;
  end;

  ModalResult := mrOK;
end;

procedure TCnProjectViewUnitsForm.StatusBarDrawPanel(StatusBar: TStatusBar;
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

procedure TCnProjectViewUnitsForm.CreateList;
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

        // 将 Project 信息添加到 UnitInfo
        UnitInfo := TCnUnitInfo.Create;
        with UnitInfo do
        begin
          Name := _CnChangeFileExt(_CnExtractFileName(IProject.FileName), '');
          FileName := IProject.FileName;
          Project := _CnExtractFileName(IProject.FileName);;
          
        {$IFDEF SUPPORT_MODULETYPE}
          // todo: Check ModuleInfo.ModuleType
        {$ELSE}
          if IsDpr(IProject.FileName) or IsBpr(IProject.FileName) then
            UnitType := utProject
          else if IsBpk(IProject.FileName) or IsDpk(IProject.FileName) then
            UnitType := utPackage
          else
            UnitType := utUnknown;
        {$ENDIF}
        end;
        
        FillUnitInfo(UnitInfo);
        ProjectInfo.InfoList.Add(UnitInfo);  // 添加模块信息到 ProjectInfo

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

procedure TCnProjectViewUnitsForm.UpdateComboBox;
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

procedure TCnProjectViewUnitsForm.DoUpdateListView;
var
  i, ToSelIndex: Integer;
  ProjectInfo: TCnProjectInfo;
  MatchSearchText: string;
  IsMatchAny: Boolean;
  ToSelUnitInfos: TList;

  procedure DoAddProject(AProject: TCnProjectInfo);
  var
    i: Integer;
    UnitInfo: TCnUnitInfo;
  begin
    for i := 0 to AProject.InfoList.Count - 1 do
    begin
      UnitInfo := TCnUnitInfo(AProject.InfoList[i]);
      if (MatchSearchText = '') or RegExpContainsText(FRegExpr, UnitInfo.Name,
        MatchSearchText, not IsMatchAny) then
      begin
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

    if cbbProjectList.ItemIndex <= 0 then
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        DoAddProject(ProjectInfo);
      end;
    end
    else if cbbProjectList.ItemIndex = 1 then
    begin
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        if _CnChangeFileExt(ProjectInfo.FileName, '') = CnOtaGetCurrentProjectFileNameEx then
          DoAddProject(ProjectInfo);
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
            DoAddProject(ProjectInfo);
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

procedure TCnProjectViewUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount, [ProjectList.Count]);
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectViewUnitsForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
  if Assigned(Item) and TCnUnitInfo(Item.Data).IsOpened then
    ListView.Canvas.Font.Color := clRed;
end;

procedure TCnProjectViewUnitsForm.lvListData(Sender: TObject;
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

procedure TCnProjectViewUnitsForm.DoSortListView;
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

