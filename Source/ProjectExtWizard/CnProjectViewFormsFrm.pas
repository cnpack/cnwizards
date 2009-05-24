{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
* 单元标识：$Id: CnProjectViewFormsFrm.pas,v 1.31 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2004.2.22 V2.0
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
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizMultiLang, CnProjectViewBaseFrm, CnWizDfmParser, ImgList, ActnList;

type
  TCnFormInfo = class(TDfmInfo)
  private
    FDesignClass: string;
    FFileName: string;
    FProject: string;
    FSize: Integer;
    FImageIndex: Integer;
    FIsOpened: Boolean;
    function GetDesignClassText: string;
  published
    property DesignClass: string read FDesignClass write FDesignClass;
    property FileName: string read FFileName write FFileName;
    property Project: string read FProject write FProject;
    property Size: Integer read FSize write FSize;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
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
    procedure DoSortListView; override;
    function GetSelectedFileName: string; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateStatusBar; override;
    procedure UpdateComboBox; override;
    procedure DoUpdateListView; override;
    procedure DoSelectItemChanged(Sender: TObject); override;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;
  public
    { Public declarations }
  end;

function ShowProjectViewForms(Ini: TCustomIniFile; out Hooked: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

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

function TCnFormInfo.GetDesignClassText: string;
begin
  if Kind <> dkObject then
    Result := DesignClass + '(' + SDfmKinds[Kind] + ')'
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
  i, j: Integer;
  FormFileName: string;
  IProject: IOTAProject;
  IModuleInfo: IOTAModuleInfo;
  ProjectInterfaceList: TInterfaceList;
  Exists: Boolean;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
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
        AInfo.FormClass := Comp.ClassName;
        AInfo.Name := Comp.Name;
        AInfo.Caption := TControlAccess(Comp).Caption;
        AInfo.Left := TControl(Comp).Left;
        AInfo.Top := TControl(Comp).Top;
        AInfo.Width := TControl(Comp).Width;
        AInfo.Height := TControl(Comp).Height;
        Result := True;
      end;
    except
      ;
    end;
  end;
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
        ProjectInfo.Name := ExtractFileName(IProject.FileName);
        ProjectInfo.FileName := IProject.FileName;

        // 添加窗体信息到 FormInfo
        for j := 0 to IProject.GetModuleCount - 1 do
        begin
          IModuleInfo := IProject.GetModule(j);
          if IModuleInfo.FormName = '' then
            Continue;
          if UpperCase(ExtractFileExt(IModuleInfo.FormName)) = '.RES' then
            Continue;

          FormFileName := ChangeFileExt(IModuleInfo.FileName, '.dfm');
          Exists := FileExists(FormFileName);
          if not Exists then
          begin
            FormFileName := ChangeFileExt(IModuleInfo.FileName, '.nfm'); // VCL.NET
            Exists := FileExists(FormFileName);
            if not Exists then
            begin
              FormFileName := ChangeFileExt(IModuleInfo.FileName, '.xfm'); // CLX, Kylix
              Exists := FileExists(FormFileName);
            end;
          end;

          if not Exists then
          begin
            // todo: Get default form name
            FormFileName := ChangeFileExt(IModuleInfo.FileName, '.dfm');
          end;

          FormInfo := TCnFormInfo.Create;
          with FormInfo do
          begin
            Name := IModuleInfo.FormName;
            FileName := FormFileName;
            Project := ExtractFileName(IProject.FileName);
            DesignClass := IModuleInfo.DesignClass;
            IsOpened := CnOtaIsFormOpen(Name);
            
            if Exists then
            begin
              Size := GetFileSize(FormFileName);
              ParseDfmFile(FormFileName, FormInfo);
            end
            else
            begin
              Size := 0;
              Format := dfUnknown;
            end;
          end;

          GetDfmInfoFromIDE(IModuleInfo.FileName, FormInfo);
          FillFormInfo(FormInfo);
          ProjectInfo.InfoList.Add(FormInfo);  // 添加窗体信息到 ProjectRecord
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
    if (Format = dfText) and (DesignClass = SFrameOfForm) then
      ImageIndex := 71
    else if (Format = dfBinary) and (DesignClass = SFrameOfForm) then
      ImageIndex := 72
    else if (Format = dfText) and (DesignClass = SDataMoudleOfForm) then
      ImageIndex := 74
    else if (Format = dfBinary) and (DesignClass = SDataMoudleOfForm) then
      ImageIndex := 75
    else if Format = dfText then
      ImageIndex := 68
    else if Format = dfBinary then
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

    S := ChangeFileExt(FileName, '.pas');
    if FileExists(S) then
    begin
      CnOtaOpenFile(S);
    end
    else
    begin
      S := ChangeFileExt(FileName, '.cpp');
      if FileExists(S) then
      begin
        CnOtaOpenFile(S);
{$IFDEF BCB}
        CnOtaMakeSourceVisible(S);
{$ENDIF}
      end
      else
      begin
        S := ChangeFileExt(FileName, '.cs');
        if FileExists(S) then
          CnOtaOpenFile(S)
        else
          CnOtaOpenFile(FileName);
      end;
    end;
  end;

  procedure OpenItems;
  var
    i: Integer;
    FormInfo: TCnFormInfo;
  begin
    for i := 0 to lvList.Items.Count - 1 do
      if lvList.Items.Item[i].Selected then
      begin
        FormInfo := TCnFormInfo(lvList.Items.Item[i].Data);
        if FormInfo.Format = dfUnknown then
          OpenItem(FormInfo.FileName, FormInfo.Name)
        else
          OpenItem(FormInfo.FileName);
      end;
  end;

begin
  Item := lvList.Selected;

  if not Assigned(Item) then
    Exit;

  if lvList.SelCount <= 1 then
    if TCnFormInfo(Item.Data).Format = dfUnknown then
      OpenItem(TCnFormInfo(Item.Data).FileName, TCnFormInfo(Item.Data).Name)
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
        Items.AddObject(ExtractFileName(ProjectInfo.Name), ProjectInfo);
      end;
  end;
end;

procedure TCnProjectViewFormsForm.DoUpdateListView;
var
  i, ToSelIndex: Integer;
  ProjectInfo: TCnProjectInfo;
  MatchSearchText: string;
  IsMatchAny: Boolean;
  ToSelFormInfos: TList;

  procedure DoAddProject(AProject: TCnProjectInfo);
  var
    i: Integer;
    FormInfo: TCnFormInfo;
  begin
    for i := 0 to ProjectInfo.InfoList.Count - 1 do
    begin
      FormInfo := TCnFormInfo(ProjectInfo.InfoList[i]);
      if (MatchSearchText = '') or
        AnsiStartsText(MatchSearchText, FormInfo.Name) or
        AnsiStartsText(MatchSearchText, FormInfo.Caption) or
        IsMatchAny and (AnsiContainsText(FormInfo.Name, MatchSearchText) or
        AnsiContainsText(FormInfo.Caption, MatchSearchText)) then
      begin
        CurrList.Add(FormInfo);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and (AnsiStartsText(MatchSearchText, FormInfo.Name)
          or AnsiStartsText(MatchSearchText, FormInfo.Caption)) then
          ToSelFormInfos.Add(FormInfo);
      end;
    end;
  end;

begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('DoUpdateListView');
{$ENDIF DEBUG}

  ToSelIndex := 0;
  ToSelFormInfos := TList.Create;

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
        if ChangeFileExt(ProjectInfo.FileName, '') = CnOtaGetCurrentProjectFileNameEx then
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
    if (ToSelFormInfos.Count > 0) and (CurrList.Count > 0) then
    begin
      for I := 0 to CurrList.Count - 1 do
      begin
        if ToSelFormInfos.IndexOf(CurrList.Items[I]) >= 0 then
        begin
          // CurrList 中的第一个在 SelUnitInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;
    SelectItemByIndex(ToSelIndex);
  finally
    ToSelFormInfos.Free;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('DoUpdateListView');
{$ENDIF DEBUG}
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
        if TCnFormInfo(Items[i].Data).Format = dfBinary then
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
  i: Integer;
  FileName: string;
begin
  Item := lvList.Selected;
  if Assigned(Item) then
  begin
    for i := 0 to lvList.Items.Count - 1 do
    begin
      if lvList.Items.Item[i].Selected then
      begin
        FileName := TCnFormInfo(lvList.Items.Item[i].Data).FileName;
        if FileExists(FileName) then
        begin
          case Format of
            dfBinary:
              begin
                ChangeType(FileName, Format);
                TCnFormInfo(lvList.Items.Item[i].Data).Format := dfBinary;
              end;
            dfText:
              begin
                ChangeType(FileName, Format);
                TCnFormInfo(lvList.Items.Item[i].Data).Format := dfText;
              end;
          end;
          FillFormInfo(TCnFormInfo(lvList.Items.Item[i].Data));
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

procedure TCnProjectViewFormsForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
  if Assigned(Item) and TCnFormInfo(Item.Data).IsOpened then
    ListView.Canvas.Font.Color := clRed;
end;

procedure TCnProjectViewFormsForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnFormInfo;
begin
  if (Item.Index >= 0) and (Item.Index < CurrList.Count) then
  begin
    Info := TCnFormInfo(CurrList[Item.Index]);
    Item.Caption := Info.Name;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;
    
    with Item.SubItems do
    begin
      Add(Info.Caption);
      Add(Info.DesignClassText);
      Add(Info.Project);
      Add(IntToStrSp(Info.Size));
      Add(SDfmFormats[Info.Format]);
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
  Info1, Info2: TCnFormInfo;
begin
  Info1 := TCnFormInfo(Item1);
  Info2 := TCnFormInfo(Item2);
  
  case _SortIndex of
    0: Result := CompareTextPos(_MatchStr, Info1.Name, Info2.Name);
    1: Result := CompareTextPos(_MatchStr, Info1.Caption, Info2.Caption);
    2: Result := CompareText(Info1.DesignClassText, Info2.DesignClassText);
    3: Result := CompareText(Info1.Project, Info2.Project);
    4: Result := CompareValue(Info1.Size, Info2.Size);
    5: Result := CompareText(SDfmFormats[Info1.Format], SDfmFormats[Info2.Format])
  else
    Result := 0;
  end;

  if _SortDown then
    Result := -Result;
end;

procedure TCnProjectViewFormsForm.DoSortListView;
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

