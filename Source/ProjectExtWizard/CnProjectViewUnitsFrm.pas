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
* 修改记录：2018.3.28 V2.3
*               跟随基类重构以支持模糊匹配
*           2015.1.17 V2.2
*               允许显示工程中类型为 Unknown 的文件
*           2004.2.22 V2.1
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
  Graphics, ImgList, ActnList, CnStrings, CnCommon, CnConsts, CnWizConsts,
  CnWizOptions, CnWizUtils, CnIni, CnWizIdeUtils, CnWizMultiLang,
  CnProjectViewBaseFrm, CnWizEditFiler;

type
  TCnUnitType = (utUnknown, utProject, utPackage, utDataModule, utForm, utUnit,
    utAsm, utC, utH, utRC);

  TCnUnitInfo = class(TCnBaseElementInfo)
  private
    FIsOpened: Boolean;
    FSize: Integer;
    FImageIndex: Integer;
    FFileName: string;
    FProject: string;
    FUnitType: TCnUnitType;
  public
    property FileName: string read FFileName write FFileName;
    property Project: string read FProject write FProject;
    property Size: Integer read FSize write FSize;
    property UnitType: TCnUnitType read FUnitType write FUnitType;
    property IsOpened: Boolean read FIsOpened write FIsOpened;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
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
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); override;

    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;
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
    (26, 76, 77, 73, 67, 78, 79, 80, 81, 89); // 26 means unknown
  
function ShowProjectViewUnits(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

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

function TCnProjectViewUnitsForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnUnitInfo;
begin
  Info1 := TCnUnitInfo(Obj1);
  Info2 := TCnUnitInfo(Obj2);

  case ASortIndex of // 因为搜索时只有名称一列参与匹配，因此排序时要考虑到把名称匹配时的全匹配提前
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
      end;
    1:
      begin
        Result := CompareText(SUnitTypes[Info1.UnitType], SUnitTypes[Info2.UnitType]);
        if SortDown then
          Result := -Result;
      end;
    2:
      begin
        Result := CompareText(Info1.Project, Info2.Project);
        if SortDown then
          Result := -Result;
      end;
    3, 4:
      begin
        Result := CompareValue(Info1.Size, Info2.Size);
        if SortDown then
          Result := -Result;
      end;
  else
    Result := 0;
  end;
end;

function TCnProjectViewUnitsForm.CanMatchDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean;
var
  Info: TCnUnitInfo;
begin
  Result := False;

  // 先限定工程，工程不符合条件的先剔除
  Info := TCnUnitInfo(DataList.Objects[DataListIndex]);
  if (ProjectInfoSearch <> nil) and (ProjectInfoSearch <> Info.ParentProject) then
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
    // CnOtaOpenFile(FilePath); // 但这样打开 Project 文件时会导致重新打开所有文件
                                // 并且 BCB 5/6 下会只打开窗体而不打开 CPP 文件

    // 所以必须加上这样的判断，也牺牲了打开 Project Source 与 BCB 5/6 CPP 打开时的通知
    if IsDpr(FilePath) or IsPackage(FilePath) or IsBdsProject(FilePath) or
      IsDProject(FilePath) or IsBpr(FilePath) or IsCbProject(FilePath) or IsBpg(FilePath)
      {$IFNDEF BDS} or IsCppSourceModule(FilePath) {$ENDIF} then
    begin
      // 如果是 dproj 或 bdsproj，换成 dpr 打开
      if IsDProject(FilePath) or IsBdsProject(FilePath) then
        CnOtaMakeSourceVisible(_CnChangeFileExt(FilePath, '.dpr'))
      else
        CnOtaMakeSourceVisible(FilePath);
    end
    else
    begin
      CnOtaOpenFile(FilePath);
    end;
  end;

  procedure OpenSelectedItem;
  var
    I: Integer;
  begin
    BeginBatchOpenClose;
    try
      for I := 0 to Pred(lvList.Items.Count) do
        if lvList.Items.Item[I].Selected then
          OpenItem(TCnUnitInfo(lvList.Items.Item[I].Data).FileName);
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
  I, J: Integer;
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
      for I := 0 to ProjectInterfaceList.Count - 1 do
      begin
        IProject := IOTAProject(ProjectInterfaceList[I]);

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
        // 注意高版本的工程文件这里得到的是 dproj，而没有 dpr

        // 将 Project 信息添加到 UnitInfo
        UnitInfo := TCnUnitInfo.Create;
        with UnitInfo do
        begin
          Text := _CnChangeFileExt(_CnExtractFileName(IProject.FileName), '');
          FileName := IProject.FileName;
          Project := _CnExtractFileName(IProject.FileName);
          
        {$IFDEF SUPPORT_MODULETYPE}
          // TODO: Check ModuleInfo.ModuleType
        {$ELSE}
          if IsDpr(IProject.FileName) or IsBpr(IProject.FileName)
{$IFDEF BDS}
            or IsBdsProject(IProject.FileName) or IsDProject(IProject.FileName)
{$ENDIF}
            then
            UnitType := utProject
          else if IsBpk(IProject.FileName) or IsDpk(IProject.FileName) then
            UnitType := utPackage
          else
            UnitType := utUnknown;
        {$ENDIF}
        end;
        
        FillUnitInfo(UnitInfo);
        UnitInfo.ParentProject := ProjectInfo;
        DataList.AddObject(UnitInfo.Text, UnitInfo);

        for J := 0 to IProject.GetModuleCount - 1 do
        begin
          IModuleInfo := IProject.GetModule(J);
          UnitFileName := IModuleInfo.FileName;

          if UnitFileName = '' then // 注意可能有空文件，不知道来源
            Continue;

          if SameText(UpperCase(_CnExtractFileExt(UnitFileName)), '.RES') then
            Continue;
          if SameText(UpperCase(_CnExtractFileExt(UnitFileName)), '.DCR') then
            Continue;
          if SameText(UpperCase(_CnExtractFileExt(UnitFileName)), '.DCP') then
            Continue;

          UnitInfo := TCnUnitInfo.Create;
          with UnitInfo do
          begin
            Text := _CnChangeFileExt(_CnExtractFileName(UnitFileName), '');
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

            // 未知类型文件不隐藏扩展名
            if UnitType = utUnknown then
              Text := _CnExtractFileName(UnitFileName);
          end;
          
          FillUnitInfo(UnitInfo);
          UnitInfo.ParentProject := ProjectInfo;
          DataList.AddObject(UnitInfo.Text, UnitInfo);
        end;
        ProjectList.Add(ProjectInfo);  // ProjectList 中只包含工程信息
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
  I: Integer;
  ProjectInfo: TCnProjectInfo;
begin
  with cbbProjectList do
  begin
    Clear;
    Items.Add(SCnProjExtProjectAll);
    Items.Add(SCnProjExtCurrentProject);
    if Assigned(ProjectList) then
    begin
      for I := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[I]);
        Items.AddObject(_CnExtractFileName(ProjectInfo.Name), ProjectInfo);
      end;
    end;
  end;
end;

procedure TCnProjectViewUnitsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount, [ProjectList.Count]);
    Panels[2].Text := Format(SCnProjExtUnitsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectViewUnitsForm.DrawListPreParam(Item: TListItem;
  ListCanvas: TCanvas);
begin
  if Assigned(Item) and (Item.Data <> nil) and TCnUnitInfo(Item.Data).IsOpened then
    ListCanvas.Font.Color := clGreen;
end;

procedure TCnProjectViewUnitsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
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

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.

