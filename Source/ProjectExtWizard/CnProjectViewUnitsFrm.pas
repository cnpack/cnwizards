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

unit CnProjectViewUnitsFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������鵥Ԫ�б�Ԫ
* ��Ԫ���ߣ���ΰ��Alan�� BeyondStudio@163.com
* ��    ע��
* ����ƽ̨��PWinXPPro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.3.28 V2.3
*               ��������ع���֧��ģ��ƥ��
*           2015.1.17 V2.2
*               ������ʾ����������Ϊ Unknown ���ļ�
*           2004.2.22 V2.1
*               ��д���д���
*           2004.2.18 V2.0 by Leeon
*               ���������б���
*           2003.11.18 V1.9
*               �����򿪵�Ԫ���겻���ֵ�����
*           2003.11.16 V1.8
*               �����򿪶���ļ�ʱ�Ƿ���ʾ�Ĺ���
*           2003.10.30 V1.7 by yygw
*               �������������ʾʱ��ʱ������ʾ��ǰ��Ԫ������
*           2003.10.16 V1.6
*               �����Զ�ѡ��ǰ�򿪵ĵ�Ԫ��ʹ֮�ɼ�
*           2003.8.08 V1.5
*               ɾ����ʾ�����еĹ���
*           2003.6.28 V1.4
*               �� Record ���͸ĳ��� class ���ͣ��޸���һЩ����
*           2003.6.26 V1.3
*               �����ҽ� IDE ����
*           2003.6.17 V1.2
*               ������ʾ�ļ����ԡ��Ż��˴�������
*           2003.6.6 V1.1
*               ����ƥ�����빦��
*           2003.5.28 V1.0
*               ������Ԫ
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
// �����鵥Ԫ�б���
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

  end;

function ShowProjectViewUnits(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  SUnitTypes: array[TCnUnitType] of string =
    ('Unknown', 'Project', 'Package', 'DataModule', 'Unit(Form)', 'Unit',
     'Asm ','C', 'H', 'RC');
  csViewUnits = 'ViewUnits';

  csUnitImageIndexs: array[TCnUnitType] of Integer =
    (26, 76, 77, 73, 67, 78, 79, 80, 81, 89); // 26 means unknown

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
// �����鵥Ԫ�б���
//==============================================================================

{ TCnProjectViewUnitsForm }

function TCnProjectViewUnitsForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnUnitInfo;
begin
  Info1 := TCnUnitInfo(Obj1);
  Info2 := TCnUnitInfo(Obj2);

  case ASortIndex of // ��Ϊ����ʱֻ������һ�в���ƥ�䣬�������ʱҪ���ǵ�������ƥ��ʱ��ȫƥ����ǰ
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

  // ���޶����̣����̲��������������޳�
  Info := TCnUnitInfo(DataList.Objects[DataListIndex]);
  if (ProjectInfoSearch <> nil) and (ProjectInfoSearch <> Info.ParentProject) then
    Exit;

  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  case AMatchMode of // ����ʱ��Ԫ������ƥ�䣬�����ִ�Сд
    mmStart:
      begin
        Result := (Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) = 1);
      end;
    mmAnywhere:
      begin
        if FMatchAnyWhereSepList = nil then
          FMatchAnyWhereSepList := TStringList.Create;
        Result := AnyWhereSepMatchStr(AMatchStr, DataList[DataListIndex],
          FMatchAnyWhereSepList, MatchedIndexes, False);
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
    // CnOtaMakeSourceVisible(FilePath);  // �����򿪿��ܻᵼ���� ctView ֪ͨ
    // CnOtaOpenFile(FilePath); // �������� Project �ļ�ʱ�ᵼ�����´������ļ�
                                // ���� BCB 5/6 �»�ֻ�򿪴�������� CPP �ļ�

    // ���Ա�������������жϣ�Ҳ�����˴� Project Source �� BCB 5/6 CPP ��ʱ��֪ͨ
    if IsDpr(FilePath) or IsPackage(FilePath) or IsBdsProject(FilePath) or
      IsDProject(FilePath) or IsBpr(FilePath) or IsCbProject(FilePath) or IsBpg(FilePath)
      {$IFNDEF BDS} or IsCppSourceModule(FilePath) {$ENDIF} then
    begin
      // ����� dproj �� bdsproj������ dpr ��
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
      // BDS ��ProjectGroup Ҳ֧�� Project �ӿڣ������Ҫȥ��
      if Supports(IProject, IOTAProjectGroup, ProjectGroup) then
        Continue;
{$ENDIF}

        ProjectInfo := TCnProjectInfo.Create;
        ProjectInfo.Name := _CnExtractFileName(IProject.FileName);
        ProjectInfo.FileName := IProject.FileName;
        // ע��߰汾�Ĺ����ļ�����õ����� dproj����û�� dpr

        // �� Project ��Ϣ��ӵ� UnitInfo
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

          if UnitFileName = '' then // ע������п��ļ�����֪����Դ
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

            // δ֪�����ļ���������չ��
            if UnitType = utUnknown then
              Text := _CnExtractFileName(UnitFileName);
          end;
          
          FillUnitInfo(UnitInfo);
          UnitInfo.ParentProject := ProjectInfo;
          DataList.AddObject(UnitInfo.Text, UnitInfo);
        end;
        ProjectList.Add(ProjectInfo);  // ProjectList ��ֻ����������Ϣ
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
        Add(SCnProjExtNotSaved);
    end;
    RemoveListViewSubImages(Item);
  end;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.

