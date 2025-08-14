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

unit CnProjectViewFormsFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组窗体列表单元
* 单元作者：张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2018.03.29 V2.1
*               重构以支持模糊匹配
*           2004.2.22 V2.0
*               重写所有代码
*           2004.2.18 V1.9 by Leeon
*               更改两个列表框架
*           2003.11.16 V1.8
*               新增打开多个文件时是否提示的功能
*           2003.10.30 V1.7 by yygw
*               修正排序后窗体显示时有时不能显示当前窗体的问题
*           2003.10.16 V1.6
*               新增自动选择当前打开的窗体并使之可见
*           2003.8.08 V1.5
*               修正判断只读文件和特殊的窗体文件类型时的错误，优化性能
*           2003.6.28 V1.4
*               将 Record 类型改成了 class 类型，修复了一些错误
*           2003.6.26 V1.3
*               新增挂接 IDE 功能
*           2003.6.15 V1.2
*               新增窗体转换、显示文件属性功能，优化了大量代码
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
  {$IFDEF COMPILER6_UP} StrUtils, {$ENDIF}
  {$IFDEF SUPPORT_FMX} CnFmxUtils, {$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizMultiLang, CnProjectViewBaseFrm, CnWizDfmParser, ImgList, ActnList,
  CnWizIdeUtils, CnStrings;

type
  TCnFormInfo = class(TCnBaseElementInfo)
  {* 需要解析 DFM}
  private
    FDesignClass: string;
    FFileName: string;
    FProject: string;
    FSize: Integer;
    FIsOpened: Boolean;
    FDfmInfo: TDfmInfo;
    function GetDesignClassText: string;
  public
    constructor Create; override;
    destructor Destroy; override;

    property DfmInfo: TDfmInfo read FDfmInfo write FDfmInfo;
  published
    property DesignClass: string read FDesignClass write FDesignClass;
    property FileName: string read FFileName write FFileName;
    property Project: string read FProject write FProject;
    property Size: Integer read FSize write FSize;
    property IsOpened: Boolean read FIsOpened write FIsOpened;
    property DesignClassText: string read GetDesignClassText;
  end;

//==============================================================================
// 工程组窗体列表窗体
//==============================================================================

{ TCnProjectViewFormsForm }

  TCnProjectViewFormsForm = class(TCnProjectViewBaseForm)
    tbnSep2: TToolButton;
    tbnConvertToText: TToolButton;
    tbnConvertToBinary: TToolButton;
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure tbnConvertToTextClick(Sender: TObject);
    procedure tbnConvertToBinaryClick(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
  private
    function ChangeType(const FileName: string; Format: TDfmFormat): Boolean;
    procedure ConvertSelectedForm(Format: TDfmFormat);
  protected
    procedure FillFormInfo(AInfo: TCnFormInfo);
    function DoSelectOpenedItem: string; override;
    function GetSelectedFileName: string; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateStatusBar; override;
    procedure UpdateComboBox; override;
    procedure DoSelectItemChanged(Sender: TObject); override;
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); override;

    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;
  public

  end;

function ShowProjectViewForms(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csViewForms = 'ViewForms';
  SFrameOfForm = 'TFrame';
  SDataMoudleOfForm = 'TDataModule';

type
  TControlAccess = class(TControl);

function ShowProjectViewForms(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;
begin
  with TCnProjectViewFormsForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csViewForms);
      Result := ShowModal = mrOk;
      Hooked := actHookIDE.Checked;
      SaveSettings(Ini, csViewForms);
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// 工程组窗体列表窗体
//==============================================================================

{ TCnFormInfo }

constructor TCnFormInfo.Create;
begin
  inherited;
  FDfmInfo := TDfmInfo.Create;
end;

destructor TCnFormInfo.Destroy;
begin
  FDfmInfo.Free;
  inherited;
end;

function TCnFormInfo.GetDesignClassText: string;
begin
  if FDfmInfo.Kind <> dkObject then
    Result := DesignClass + '(' + SDfmKinds[FDfmInfo.Kind] + ')'
  else
    Result := DesignClass;
end;

{ TCnProjectViewFormsForm }

function TCnProjectViewFormsForm.ChangeType(const FileName: string; Format: TDfmFormat): Boolean;
var
  BinStream, StrStream: TMemoryStream;
begin
  Result := False;

  if not FileExists(FileName) then
    Exit;

  if (GetFileAttributes(PChar(FileName)) and FILE_ATTRIBUTE_READONLY) <> 0 then
    if QueryDlg(SCnProjExtFileIsReadOnly, False, SCnInformation) then
      SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL)
    else
      Exit;

  BinStream := nil;
  StrStream := nil;
  try
    BinStream := TMemoryStream.Create;
    StrStream := TMemoryStream.Create;
    try
      BinStream.LoadFromFile(FileName);
      case Format of
        dfText:
          begin
            BinStream.LoadFromFile(FileName);
            ObjectResourceToText(BinStream, StrStream);
            StrStream.SaveToFile(FileName);
          end;
        dfBinary:
          begin
            StrStream.LoadFromFile(FileName);
            ObjectTextToResource(StrStream, BinStream);
            BinStream.SaveToFile(FileName);
          end;
      end;
      Result := True;
    except
      Result := False;
    end;
  finally
    BinStream.Free;
    StrStream.Free;
  end;
end;

procedure TCnProjectViewFormsForm.CreateList;
var
  ProjectInfo: TCnProjectInfo;
  FormInfo: TCnFormInfo;
  I, J: Integer;
  FormFileName: string;
  IProject: IOTAProject;
  IModuleInfo: IOTAModuleInfo;
  ProjectInterfaceList: TInterfaceList;
  Exists: Boolean;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
{$IFDEF SUPPORT_FMX}
  ARect: TRect;
{$ENDIF}

  function GetDfmInfoFromIDE(const AFileName: string; AInfo: TCnFormInfo): Boolean;
  var
    IModule: IOTAModule;
    IFormEditor: IOTAFormEditor;
    Comp: TComponent;
  begin
    Result := False;
    try
      IModule := CnOtaGetModule(AFileName);
      if not Assigned(IModule) then
        Exit;

      IFormEditor := CnOtaGetFormEditorFromModule(IModule);
      if not Assigned(IFormEditor) then
        Exit;

      Comp := CnOtaGetRootComponentFromEditor(IFormEditor);
      if Assigned(Comp) and (Comp is TControl) then
      begin
        AInfo.DfmInfo.FormClass := Comp.ClassName;
        AInfo.DfmInfo.Name := Comp.Name;
        AInfo.DfmInfo.Caption := TControlAccess(Comp).Caption;
        AInfo.DfmInfo.Left := TControl(Comp).Left;
        AInfo.DfmInfo.Top := TControl(Comp).Top;
        AInfo.DfmInfo.Width := TControl(Comp).Width;
        AInfo.DfmInfo.Height := TControl(Comp).Height;
        Result := True;
      end;

{$IFDEF SUPPORT_FMX}
      if Assigned(Comp) and (CnFmxIsInheritedFromCommonCustomForm(Comp)
        or CnFmxIsInheritedFromFrame(Comp)) then
      begin
        AInfo.DfmInfo.FormClass := Comp.ClassName;
        AInfo.DfmInfo.Name := Comp.Name;

        // Frame 时返回空
        AInfo.DfmInfo.Caption := CnFmxGetCommonCustomFormCaption(Comp);
        ARect := CnFmxGetControlRect(Comp);

        AInfo.DfmInfo.Left := ARect.Left;
        AInfo.DfmInfo.Top := ARect.Top;
        AInfo.DfmInfo.Width := ARect.Width;
        AInfo.DfmInfo.Height := ARect.Height;
        Result := True;
      end;
{$ENDIF}

    except
      ;
    end;
  end;
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

        // 添加窗体信息到 FormInfo
        for J := 0 to IProject.GetModuleCount - 1 do
        begin
          IModuleInfo := IProject.GetModule(J);
          if IModuleInfo.FormName = '' then
            Continue;
          if UpperCase(_CnExtractFileExt(IModuleInfo.FormName)) = '.RES' then
            Continue;

          FormFileName := _CnChangeFileExt(IModuleInfo.FileName, '.dfm');
          Exists := FileExists(FormFileName);

{$IFDEF SUPPORT_FMX}
          if not Exists then
          begin
            FormFileName := _CnChangeFileExt(IModuleInfo.FileName, '.fmx'); // FMX
            Exists := FileExists(FormFileName);
          end;
{$ENDIF}

          if not Exists then
          begin
            FormFileName := _CnChangeFileExt(IModuleInfo.FileName, '.nfm'); // VCL.NET
            Exists := FileExists(FormFileName);
            if not Exists then
            begin
              FormFileName := _CnChangeFileExt(IModuleInfo.FileName, '.xfm'); // CLX, Kylix
              Exists := FileExists(FormFileName);
            end;
          end;

          if not Exists then
          begin
            // todo: Get default form name
            FormFileName := _CnChangeFileExt(IModuleInfo.FileName, '.dfm');
          end;

          FormInfo := TCnFormInfo.Create;
          with FormInfo do
          begin
            Text := IModuleInfo.FormName;  // 似乎没用上
            FileName := FormFileName;
            Project := _CnExtractFileName(IProject.FileName);
            DesignClass := IModuleInfo.DesignClass;
            IsOpened := CnOtaIsFormOpen(IModuleInfo.FormName);
            
            if Exists then
            begin
              Size := GetFileSize(FormFileName);
              ParseDfmFile(FormFileName, FormInfo.DfmInfo);
            end
            else
            begin
              Size := 0;
              FDfmInfo.Format := dfUnknown;
            end;
          end;

          GetDfmInfoFromIDE(IModuleInfo.FileName, FormInfo);
          FillFormInfo(FormInfo);
          FormInfo.ParentProject := ProjectInfo;
          DataList.AddObject(FormInfo.DfmInfo.Name, FormInfo);
        end;

        ProjectList.Add(ProjectInfo);  // ProjectList 中包含模块信息
      end;
    except
      raise Exception.Create(SCnProjExtCreatePrjListError);
    end;
  finally
    ProjectInterfaceList.Free;
  end;
end;

function TCnProjectViewFormsForm.DoSelectOpenedItem: string;
begin
  Result := Trim(CnOtaGetCurrentFormName);
end;

function TCnProjectViewFormsForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(TCnFormInfo(lvList.ItemFocused.Data).FileName);
end;

function TCnProjectViewFormsForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtViewForms';
end;

procedure TCnProjectViewFormsForm.FillFormInfo(AInfo: TCnFormInfo);
begin
  with AInfo do
  begin
    if (DfmInfo.Format = dfText) and (DesignClass = SFrameOfForm) then
      ImageIndex := 71
    else if (DfmInfo.Format = dfBinary) and (DesignClass = SFrameOfForm) then
      ImageIndex := 72
    else if (DfmInfo.Format = dfText) and (DesignClass = SDataMoudleOfForm) then
      ImageIndex := 74
    else if (DfmInfo.Format = dfBinary) and (DesignClass = SDataMoudleOfForm) then
      ImageIndex := 75
    else if DfmInfo.Format = dfText then
      ImageIndex := 68
    else if DfmInfo.Format = dfBinary then
      ImageIndex := 69
    else
      case CnOtaGetNewFormTypeOption of
        ftText: ImageIndex := 68;
        ftBinary: ImageIndex := 69;
      end;
  end;
end;

procedure TCnProjectViewFormsForm.OpenSelect;
var
  Item: TListItem;

  procedure OpenItem(const FileName: string; const FormName: string = '');
  var
    S: string;
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Open: Filename %s, Formname %s', [FileName, FormName]);
{$ENDIF}
    if FormName <> '' then
    begin
      CnOtaOpenUnSaveForm(FormName);
      Exit;
    end;

    S := _CnChangeFileExt(FileName, '.pas');
    if FileExists(S) then
    begin
      CnOtaOpenFile(S);
    end
    else
    begin
      S := _CnChangeFileExt(FileName, '.cpp');
      if FileExists(S) then
      begin
        CnOtaOpenFile(S);
{$IFDEF BCB}
        CnOtaMakeSourceVisible(S);
{$ENDIF}
      end
      else
      begin
        S := _CnChangeFileExt(FileName, '.cs');
        if FileExists(S) then
          CnOtaOpenFile(S)
        else
          CnOtaOpenFile(FileName);
      end;
    end;
  end;

  procedure OpenItems;
  var
    I: Integer;
    FormInfo: TCnFormInfo;
  begin
    BeginBatchOpenClose;
    try
      for I := 0 to lvList.Items.Count - 1 do
        if lvList.Items.Item[I].Selected then
        begin
          FormInfo := TCnFormInfo(lvList.Items.Item[I].Data);
          if FormInfo.DfmInfo.Format = dfUnknown then
            OpenItem(FormInfo.FileName, FormInfo.DfmInfo.Name)
          else
            OpenItem(FormInfo.FileName);
        end;
    finally
      EndBatchOpenClose;
    end;
  end;

begin
  Item := lvList.Selected;

  if not Assigned(Item) then
    Exit;

  if lvList.SelCount <= 1 then
    if TCnFormInfo(Item.Data).DfmInfo.Format = dfUnknown then
      OpenItem(TCnFormInfo(Item.Data).FileName, TCnFormInfo(Item.Data).DfmInfo.Name)
    else
      OpenItem(TCnFormInfo(Item.Data).FileName)
  else
  begin
    if actQuery.Checked then
      if not QueryDlg(SCnProjExtOpenFormWarning, False, SCnInformation) then
        Exit;

    OpenItems;
  end;

  ModalResult := mrOK;
end;

procedure TCnProjectViewFormsForm.UpdateComboBox;
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
      for i := 0 to ProjectList.Count - 1 do
      begin
        ProjectInfo := TCnProjectInfo(ProjectList[i]);
        Items.AddObject(_CnExtractFileName(ProjectInfo.Name), ProjectInfo);
      end;
  end;
end;

procedure TCnProjectViewFormsForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount, [ProjectList.Count]);
    Panels[2].Text := Format(SCnProjExtFormsFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectViewFormsForm.DoSelectItemChanged(Sender: TObject);
var
  BinForm, TxtForm: Integer;
  i: Integer;
begin
  inherited;

  BinForm := 0;
  TxtForm := 0;

  with lvList do
  begin
    if SelCount <= 0 then
    begin
      tbnConvertToText.Enabled := False;
      tbnConvertToBinary.Enabled := False;
      Exit;
    end;

    for i := 0 to Items.Count - 1 do
      if lvList.Items[i].Selected then
        if TCnFormInfo(Items[i].Data).DfmInfo.Format = dfBinary then
          Inc(BinForm)
        else
          Inc(TxtForm);
  end;

  tbnConvertToText.Enabled := BinForm <> 0;
  tbnConvertToBinary.Enabled := TxtForm <> 0;
end;

procedure TCnProjectViewFormsForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(TCnFormInfo(Item.Data).FileName) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, TCnFormInfo(Item.Data).FileName)
    else
      DrawCompactPath(StatusBar.Canvas.Handle, Rect,
        TCnFormInfo(Item.Data).FileName + SCnProjExtNotSave);

    StatusBar.Hint := TCnFormInfo(Item.Data).FileName;
  end;
end;

procedure TCnProjectViewFormsForm.ConvertSelectedForm(Format: TDfmFormat);
var
  Item: TListItem;
  I: Integer;
  FileName: string;
begin
  Item := lvList.Selected;
  if Assigned(Item) then
  begin
    for I := 0 to lvList.Items.Count - 1 do
    begin
      if lvList.Items.Item[I].Selected then
      begin
        FileName := TCnFormInfo(lvList.Items.Item[I].Data).FileName;
        if FileExists(FileName) then
        begin
          case Format of
            dfBinary:
              begin
                ChangeType(FileName, Format);
                TCnFormInfo(lvList.Items.Item[I].Data).DfmInfo.Format := dfBinary;
              end;
            dfText:
              begin
                ChangeType(FileName, Format);
                TCnFormInfo(lvList.Items.Item[I].Data).DfmInfo.Format := dfText;
              end;
          end;
          FillFormInfo(TCnFormInfo(lvList.Items.Item[I].Data));
        end
        else
        begin
          InfoDlg(SCnProjExtFileNotExistOrNotSave, SCnInformation, 64);
          Exit;
        end;
      end;
    end;
    
    UpdateListView;
  end;
end;

procedure TCnProjectViewFormsForm.tbnConvertToTextClick(Sender: TObject);
begin
  ConvertSelectedForm(dfText);
end;

procedure TCnProjectViewFormsForm.tbnConvertToBinaryClick(Sender: TObject);
begin
  ConvertSelectedForm(dfBinary);
end;

procedure TCnProjectViewFormsForm.DrawListPreParam(Item: TListItem;
  ListCanvas: TCanvas);
begin
  if Assigned(Item) and (Item.Data <> nil) and TCnFormInfo(Item.Data).IsOpened then
    ListCanvas.Font.Color := clGreen;
end;

procedure TCnProjectViewFormsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnFormInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnFormInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text; // DfmInfo.Name;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;
    
    with Item.SubItems do
    begin
      Add(Info.DfmInfo.Caption);
      Add(Info.DesignClassText);
      Add(Info.Project);
      Add(IntToStrSp(Info.Size));
      Add(SDfmFormats[Info.DfmInfo.Format]);
    end;
    RemoveListViewSubImages(Item);
  end;
end;

function TCnProjectViewFormsForm.CanMatchDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean;
var
  Info: TCnFormInfo;
  UpperMatch: string;
begin
  Result := False;

  // 先限定工程，工程不符合条件的先剔除
  Info := TCnFormInfo(DataList.Objects[DataListIndex]);
  if (ProjectInfoSearch <> nil) and (ProjectInfoSearch <> Info.ParentProject) then
    Exit;

  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  if AMatchMode in [mmStart, mmAnywhere] then
    UpperMatch := UpperCase(AMatchStr);

  case AMatchMode of // 搜索时窗体名、标题参与匹配，不区分大小写
    mmStart:
      begin
        Result := (Pos(UpperMatch, UpperCase(DataList[DataListIndex])) = 1)
          or (Pos(UpperMatch, UpperCase(Info.DfmInfo.Caption)) = 1);
      end;
    mmAnywhere:
      begin
        if FMatchAnyWhereSepList = nil then
          FMatchAnyWhereSepList := TStringList.Create;
        Result := AnyWhereSepMatchStr(UpperMatch, DataList[DataListIndex], FMatchAnyWhereSepList, MatchedIndexes, False)
         or AnyWhereSepMatchStr(UpperMatch,  UpperCase(Info.DfmInfo.Caption), FMatchAnyWhereSepList, nil, False);
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes)
          or FuzzyMatchStr(AMatchStr, Info.DfmInfo.Caption) ;
      end;
  end;
end;

function TCnProjectViewFormsForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnFormInfo;
begin
  Info1 := TCnFormInfo(Obj1);
  Info2 := TCnFormInfo(Obj2);

  case ASortIndex of // 因为搜索时名称、标题两列参与匹配，因此这两列排序时要考虑到把名称匹配时的全匹配提前
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.DfmInfo.Name, Info2.DfmInfo.Name, SortDown);
      end;
    1:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.DfmInfo.Caption, Info2.DfmInfo.Caption, SortDown);
      end;
    2: Result := CompareText(Info1.DesignClassText, Info2.DesignClassText);
    3: Result := CompareText(Info1.Project, Info2.Project);
    4: Result := CompareValue(Info1.Size, Info2.Size);
    5: Result := CompareText(SDfmFormats[Info1.DfmInfo.Format], SDfmFormats[Info2.DfmInfo.Format]);
  else
    Result := 0;
  end;

  if SortDown and (ASortIndex in [2..5]) then
    Result := -Result;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.

