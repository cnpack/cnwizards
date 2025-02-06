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

unit CnProjectFramesFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程组添加 Frame 列表窗体
* 单元作者：张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2018.03.29 V1.1
*               重构以支持模糊匹配
*           2007.04.27 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
{$IFDEF COMPILER6_UP} StrUtils, {$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, ImgList, ActnList,
{$IFDEF SUPPORT_FMX} CnFmxUtils, {$ENDIF}
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizMultiLang, CnProjectViewBaseFrm, CnWizDfmParser, CnProjectViewFormsFrm;

type

//==============================================================================
// 工程组添加 Frame 列表窗体
//==============================================================================

{ TCnProjectFramesForm }

  TCnProjectFramesForm = class(TCnProjectViewFormsForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
  protected
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateStatusBar; override;
  public

  end;

function ShowProjectInsertFrame(ASelf: TCustomForm): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  CnProjectExtWizard, CnWizManager, CnWizIdeUtils {$IFDEF DEBUG}, CnDebug{$ENDIF};

const
  csFrameInsert = 'FrameInsert';
  SFrameOfForm = 'TFrame';
  SDataMoudleOfForm = 'TDataModule';

  SelectFrameHelpContext = 6030;
  // ViewDialog 在 Select Frame 被调用时的 HelpContext

type
  TControlAccess = class(TControl);

var
  Ini: TCustomIniFile = nil;
  // 用来传递保存参数，因为Hook的部分只能传Self，无法传其他参数
  OriginalList: TStrings = nil;

  // 供ProjectExtWizard控制本窗口是否需要重复UpdteMethod的参数
  NeedUpdateMethodHook: Boolean = True;

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
    FrameInsertHookBtnChecked := False;
    Result := False;
    Exit;
  end;
  
{$IFDEF DEBUG}
  CnDebugger.LogInteger(ASelf.HelpContext, 'ViewDialog HelpContext ');
{$ENDIF}

//  IsUseUnit := ASelf.HelpContext = UseUnitHelpContext;
  if ASelf.HelpContext <> SelectFrameHelpContext then
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

  AForm := TCnProjectFramesForm.Create(nil);
  with AForm do
  begin
    try
      btnQuery.Visible := False; // 无需此提示
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csFrameInsert);

      // 默认先打开当前工程
      cbbProjectList.ItemIndex := cbbProjectList.Items.IndexOf(SCnProjExtCurrentProject);
      if Assigned(cbbProjectList.OnChange) then
        cbbProjectList.OnChange(cbbProjectList);

      Result := ShowModal = mrOk;

      FrameInsertHookBtnChecked := actHookIDE.Checked;
      SaveSettings(Ini, csFrameInsert);
      if NeedUpdateMethodHook then
        AWizard.UpdateMethodHook(FrameInsertHookBtnChecked);

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
            AName := _CnChangeFileExt(TCnFormInfo(lvList.Items[I].Data).Text, '');
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
// 工程组添加 Frame 列表窗体
//==============================================================================

{ TCnProjectFramesForm }

procedure TCnProjectFramesForm.CreateList;
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
      if Assigned(Comp) and CnFmxIsInheritedFromFrame(Comp) then
      begin
        AInfo.DfmInfo.FormClass := Comp.ClassName;
        AInfo.DfmInfo.Name := Comp.Name;
        ARect := CnFmxGetControlRect(Comp);

        // FMX Frame 无 Caption 
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
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Frames: IModuleInfo DesignClass is %s.', [IModuleInfo.DesignClass]);
          if GetClass(IModuleInfo.DesignClass) <> nil then
            CnDebugger.LogFmt('Frames: IModuleInfo DesignClass Found. Parent is %s.', [GetClass(IModuleInfo.DesignClass).ClassParent.ClassName]);
{$ENDIF}
          if Trim(IModuleInfo.DesignClass) = '' then
            Continue;

          if IModuleInfo.DesignClass <> SFrameOfForm then
          begin
            if GetClass(IModuleInfo.DesignClass) = nil then
              Continue
            else if not GetClass(IModuleInfo.DesignClass).InheritsFrom(TCustomFrame) then
              Continue;
          end;

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
            Text := IModuleInfo.FormName;
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
              DfmInfo.Format := dfUnknown;
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

function TCnProjectFramesForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtFrames';
end;

procedure TCnProjectFramesForm.OpenSelect;
begin
  if lvList.SelCount > 0 then
    ModalResult := mrOK;
end;

procedure TCnProjectFramesForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount, [ProjectList.Count]);
    Panels[2].Text := Format(SCnProjExtFramesFileCount, [lvList.Items.Count]);
  end;
end;

procedure TCnProjectFramesForm.lvListData(Sender: TObject;
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
      Add(Info.DesignClassText);
      Add(Info.Project);
      Add(IntToStrSp(Info.Size));
      Add(SDfmFormats[Info.DfmInfo.Format]);
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
