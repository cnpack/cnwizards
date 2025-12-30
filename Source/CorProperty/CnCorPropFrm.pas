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

unit CnCorPropFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性修改专家主界面单元
* 单元作者：陈省(hubdog) hubdog@263.net
*           CnPack 开发组 master@cnpack.org
* 备    注：属性修改专家主界面单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2004.09.08 V1.3 by LiuXiao
*               增加处理所有打开 Form 的选项
*           2003.09.28 V1.2 by 何清
*               修正由于删除已经修改的控件，引起双击定位到该控件时触发异常
*           2003.06.06 V1.1 by 周劲羽
*               修正由于类型匹配可能引起的无效问题
*           2003.05.17 V1.0 by LiuXiao
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
  Windows, Messages, SysUtils, Classes, CnWizConsts, Menus, ImgList,
  Controls, ActnList, ComCtrls, StdCtrls, ExtCtrls, CnCommon,
  Graphics, Forms, Dialogs, CnCorPropWizard, contnrs, ToolsApi, TypInfo,
  {$IFDEF COMPILER5} Dsgnintf, {$ELSE} DesignIntf, Variants, {$ENDIF}
  CnConsts, CnWizManager, CnWizUtils, CnWizIdeUtils, CnLangMgr, CnWizMultiLang,
  CnPopupMenu;

type
  // 修正项目
  TCnCorrectItem = class(TPersistent)
  private
    FCorrComp: TComponent;
    FFileName: string;
    FPropDef: TCnPropDef;
    FPropName: string;
    FOldValue: string;
    procedure SetCorrComp(const Value: TComponent);
    procedure SetFileName(const Value: string);
    procedure SetPropDef(const Value: TCnPropDef);
    procedure SetPropName(const Value: string);
    procedure SetOldValue(const Value: string);
  published
    property FileName: string read FFileName write SetFileName;
    property CorrComp: TComponent read FCorrComp write SetCorrComp;
    property PropDef: TCnPropDef read FPropDef write SetPropDef;
    property PropName: string read FPropName write SetPropName;
    property OldValue: string read FOldValue write SetOldValue;
  end;

  TCnCorrectRange = (crCurrent, crOpened, crProject, crGroup);

  TCnCorPropForm = class(TCnTranslateForm)
    GroupBox1: TGroupBox;
    rbProject: TRadioButton;
    rbForm: TRadioButton;
    rbGroup: TRadioButton;
    btnFind: TButton;
    btnClose: TButton;
    btnConfig: TButton;
    btnHelp: TButton;
    ActionList: TActionList;
    actCorrect: TAction;
    actLocateComp: TAction;
    actCorrectComp: TAction;
    ilImageList1: TImageList;
    pmResult: TPopupMenu;
    LocateComponent1: TMenuItem;
    CorrectPropertyValue1: TMenuItem;
    btnAll: TButton;
    actUndoCorrect: TAction;
    U1: TMenuItem;
    btnUndo: TButton;
    grpResult: TGroupBox;
    lvResult: TListView;
    rbOpened: TRadioButton;
    btnSelected: TButton;
    actConfirmSelected: TAction;
    procedure actCorrectExecute(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCorrectCompUpdate(Sender: TObject);
    procedure actLocateCompUpdate(Sender: TObject);
    procedure actCorrectCompExecute(Sender: TObject);
    procedure actLocateCompExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvResultDblClick(Sender: TObject);
    procedure btnAllClick(Sender: TObject);
    procedure actUndoCorrectUpdate(Sender: TObject);
    procedure actUndoCorrectExecute(Sender: TObject);
    procedure actConfirmSelectedExecute(Sender: TObject);
    procedure actConfirmSelectedUpdate(Sender: TObject);
  private
    FPropDefList: TObjectList;
    FCorrectItemList: TObjectList;
    FHasForm: Boolean;
    procedure SetPropDefList(const Value: TObjectList);
    // 将修正属性的结果添加到 ListView 中，返回是否修改
    function CorrectProp(FileName: string; AComp: IOTAComponent): Boolean;
    function ValidateProp(APropDef: TCnPropDef; AValue: Variant;
      PropInfo: PPropInfo): Boolean;
    procedure AddCorrItem(AItem: TCnCorrectItem);
    procedure SetCorrectItemList(const Value: TObjectList); // 添加修正项目
    procedure ClearItems;
    procedure UpdateView;
    function GetCorrectRange: TCnCorrectRange;
    procedure SetCorrectRange(const Value: TCnCorrectRange);
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure CorrectGroup;                        // 更新项目组中的全部的窗体
    procedure CorrectProject(Project:IOTAProject); // 更新项目中的全部窗体
    procedure CorrectCurrentForm;                  // 更新当前窗体
    procedure CorrectOpenedForm;                   // 更新所有打开窗体
    procedure CorrectModule(Module: IOTAModule);   //更新模块
    property CorrectItemList: TObjectList read FCorrectItemList write
      SetCorrectItemList;                          // 修正项目列表
    property PropDefList: TObjectList read FPropDefList write SetPropDefList;
    property CorrectRange:TCnCorrectRange read GetCorrectRange write SetCorrectRange;
    // 是修改全部，还是只是当前
  end;

  TValueType = (vtInt, vtFloat, vtIdent, vtObject, vtOther);

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCorPropCfgFrm;

{$R *.DFM}

{ TCnFormCorProp }

procedure TCnCorPropForm.SetPropDefList(const Value: TObjectList);
begin
  FPropDefList := Value;
end;

procedure TCnCorPropForm.actCorrectExecute(Sender: TObject);
begin
  BeginWait;
  try
    // 检查
    Assert(FPropDefList <> nil);
    ClearItems;
    // 判断是更新整个 Project 还是单单只是当前窗体
    FHasForm := True;
    case CorrectRange of
      crCurrent:
        begin
          if not rbForm.Enabled then Exit;
          CorrectCurrentForm;
        end;
      crOpened:
        begin
          if not rbOpened.Enabled then Exit;
          CorrectOpenedForm;
        end;
      crProject:
        begin
          if not rbProject.Enabled then Exit;
          CorrectProject(CnOtaGetCurrentProject);
        end;
      crGroup:
        begin
          if not rbGroup.Enabled then Exit;
          CorrectGroup;
        end;
    end;

    if FCorrectItemList.Count > 0 then
      UpdateView // 更新视图
    else if (CorrectRange in [crProject, crGroup]) or not FHasForm then
      ErrorDlg(SCnCorrectPropertyErrNoResult);
  finally
    EndWait;
  end;
end;

function TCnCorPropForm.CorrectProp(FileName: string; AComp: IOTAComponent): Boolean;
var
  NTAComp: INTAComponent;
  ANTAComp: TComponent;
  L: Integer;
  APropDef: TCnPropDef;
  PropName: string;
  V: Variant;
  AValue: Variant;
  AItem: TCnCorrectItem;
  PropInfo: PPropInfo;
  ClassType: TClass;
begin
  Result := False;
  NTAComp := AComp as INTAComponent;
  ANTAComp := NTAComp.GetComponent;

  for L := 0 to PropDefList.Count - 1 do
  begin
    APropDef := TCnPropDef(PropDefList.Items[L]);
    if not APropDef.Active then
      Continue;

    // 判断类型是否匹配
    ClassType := ANTAComp.ClassType;
    while ClassType <> nil do
      if SameText(ClassType.ClassName, APropDef.CompName) then
        Break
      else
        ClassType := ClassType.ClassParent;

    if ClassType = nil then
      Continue;

    PropName := APropDef.PropName;
    PropInfo := GetPropInfoIncludeSub(ANTAComp, PropName);
    if PropInfo = nil then
      Continue;

    // 检查该控件有无该属性名并且检查是否有 Font.Color 这样的级连属性。
    AValue := GetPropValueIncludeSub(ANTAComp, PropName);
    // 对象是 nil 值时 GetPropValueIncludeSub 返回 0，改作空值
    if (PropInfo^.PropType^.Kind = tkClass) and (VarToStr(AValue) = '0') then
      AValue := '';

{$IFDEF DEBUG}
    CnDebugger.LogMsg('CorrectProp. AValue: ' + VarToStr(AValue));
{$ENDIF}

    if not ValidateProp(APropDef, AValue, PropInfo) then
      Continue;

    if APropDef.Action = paCorrect then // 自动更正
    begin
      V := APropDef.ToValue;
      SetPropValueIncludeSub(ANTAComp, PropName, V, ANTAComp.Owner);
      Result := True;
    end;
    // 添加到查找修正列表

    AItem := TCnCorrectItem.Create;
    AItem.FileName := FileName;
    AItem.PropDef := APropDef;
    AItem.PropName := PropName;
    AItem.CorrComp := ANTAComp;
    AItem.OldValue := AValue;

    AddCorrItem(AItem);
  end;
end;

// 检查属性是否满足条件
function TCnCorPropForm.ValidateProp(APropDef: TCnPropDef;
  AValue: Variant; PropInfo: PPropInfo): Boolean;
var
  I1, I2: integer;
  F1, F2: double;
  S1, S2: string;
  ValueType: TValueType;
  IdToInt: TIdentToInt;
begin
  Result := False;
  I1 := 0; I2 := 0; F1 := 0.0; F2 := 0.0;
  try
    // TODO: 用 VarType 检查 AValue 类型，如果是 TObject 等类型就退出
    if IsInt(APropDef.Value) then
    begin
      I1 := StrToInt(APropDef.Value);
      I2 := AValue;
      ValueType := vtInt;
    end
    else if IsFloat(APropDef.Value) then
    begin
      F1 := StrToFloat(APropDef.Value);
      F2 := AValue;
      ValueType := vtFloat;
    end
    else if PropInfo^.PropType^.Kind = tkInteger then
    begin
      IdToInt := FindIdentToInt(PPropInfo(PropInfo)^.PropType^);
      if Assigned(IdToInt) and ((APropDef.Value = '') or (IdToInt(APropDef.Value, I1)))
        and IdToInt(AValue, I2) then
      begin
        ValueType := vtInt;
        if APropDef.Value = '' then
          I1 := 0;
      end
      else
      begin
        S1 := APropDef.Value;
        S2 := AValue;
        ValueType := vtOther;
      end;
    end
    else
    begin
      S1 := APropDef.Value;
      S2 := AValue;
      if PropInfo^.PropType^.Kind = tkClass then
        ValueType := vtObject
      else
        ValueType := vtOther;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('PropName %s, TypeKind %d, S1 %s, S2 %s',
      [APropDef.PropName, Integer(PropInfo^.PropType^.Kind), S1, S2]);
{$ENDIF}

    case APropDef.Compare of
      coLarge, coLargeEqual, coLess, coLessEqual:
        // 字符串和对象等没有大于等于等操作，只能是 = 或 <> 操作
        begin
          if (ValueType = vtOther) or (ValueType = vtObject) then
            Exit;
          case APropDef.Compare of
            coLarge:
              begin
                if ((ValueType = vtInt) and (I2 > I1)) or ((ValueType = vtFloat)
                  and (F2 > F1)) then
                  Result := True
                else
                  Result := False;
              end;
            coLess:
              begin
                if ((ValueType = vtInt) and (I2 < I1)) or ((ValueType = vtFloat)
                  and (F2 < F1)) then
                  Result := True
                else
                  Result := False;
              end;
            coLargeEqual:
              begin
                if ((ValueType = vtInt) and (I2 >= I1)) or ((ValueType = vtFloat)
                  and (F2 >= F1)) then
                  Result := True
                else
                  Result := False;
              end;
            coLessEqual:
              begin
                if ((ValueType = vtInt) and (I2 <= I1)) or ((ValueType = vtFloat)
                  and (F2 <= F1)) then
                  Result := True
                else
                  Result := False;
              end;

          end;
        end;
      coEqual:
        begin
          if ((ValueType = vtInt) and (I2 = I1))
            or ((ValueType = vtFloat) and (FloatToStr(F2) = FloatToStr(F1)))
            or ((ValueType = vtObject) and (S2 = S1))
            or ((ValueType = vtOther) and (S2 = S1)) then
            Result := True
          else
            Result := False;
        end;
      coNotEqual:
        begin
          if ((ValueType = vtInt) and (I2 <> I1))
            or ((ValueType = vtFloat) and (FloatToStr(F2) <> FloatToStr(F1)))
            or ((ValueType = vtObject) and (S2 <> S1))
            or ((ValueType = vtOther) and (S2 <> S1)) then
            Result := True
          else
            Result := False;
        end;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Result, 'ValidateProp');
{$ENDIF}
  except
    ;
  end;
end;

procedure TCnCorPropForm.btnConfigClick(Sender: TObject);
var
  AForm: TCnCorPropCfgForm;
begin
  AForm := TCnCorPropCfgForm.Create(nil);
  try
    AForm.PropDefList := FPropDefList;
    AForm.Initialing := True;
    if AForm.ShowModal = mrOk then
    begin
      FPropDefList := AForm.PropDefList;
      if CnWizardMgr.WizardByClass(TCnCorPropWizard) <> nil then
        CnWizardMgr.WizardByClass(TCnCorPropWizard).DoSaveSettings;
    end;
  finally
    AForm.Free;
  end;
end;

procedure TCnCorPropForm.CorrectProject(Project:IOTAProject);
var
  ModuleInfo: IOTAModuleInfo;
  Module: IOTAModule;
  I, CorResultCount: Integer;
  ModuleIsOpen: Boolean;
  Ext: string;
begin
  Assert(Assigned(Project));
  for I := 0 to Project.GetModuleCount - 1 do
  begin
    ModuleInfo := Project.GetModule(I);
    Assert(Assigned(ModuleInfo));

    if Trim(ModuleInfo.FileName) = '' then // This is a unit like Forms.pas
      Continue;
    ModuleIsOpen := CnOtaIsFileOpen(ModuleInfo.FileName);
    CorResultCount := FCorrectItemList.Count;

    Ext := UpperCase(_CnExtractFileExt(ModuleInfo.FileName));
    if (Ext = '.DCR') then
      Continue;

    try
      Module := ModuleInfo.OpenModule;
    except
      Continue;
    end;
    if not Assigned(Module) then
      Continue;

    CorrectModule(Module);

    if not ModuleIsOpen and (CorResultCount = FCorrectItemList.Count) then
      Module.CloseModule(True);
  end;
end;

procedure TCnCorPropForm.CorrectCurrentForm;
var
  Module: IOTAModule;
begin
  Module := CnOtaGetCurrentModule;
  if Module = nil then
  begin
    FHasForm := False;
    ErrorDlg(SCnCorrectPropertyErrNoForm);
    Exit;
  end;
  CorrectModule(Module);
end;

procedure TCnCorPropForm.CorrectOpenedForm;
var
  I: Integer;
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices.GetModuleCount = 0 then
  begin
    FHasForm := False;
    ErrorDlg(SCnCorrectPropertyErrNoForm);
    Exit;
  end;

  for I := 0 to iModuleServices.GetModuleCount - 1 do
    CorrectModule(iModuleServices.GetModule(I));
end;

procedure TCnCorPropForm.CorrectModule(Module: IOTAModule);
var
  J, K, CorResultCount: Integer;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
  RootComp: IOTAComponent;
  AComp: IOTAComponent;
begin
  for J := 0 to Module.GetModuleFileCount - 1 do
  begin
    Editor := Module.GetModuleFileEditor(J);
    if Editor.QueryInterface(IOTAFormEditor, FormEditor) = S_OK then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Successfully Get %s.FormEditor', [Editor.FileName]);
{$ENDIF}
      RootComp := FormEditor.GetRootComponent;
      CorResultCount := FCorrectItemList.Count;
      // 先判断 Form 本身
      CorrectProp(FormEditor.GetFileName, RootComp);

      // 然后判断 Form 或 DataModule 上的控件
      for K := 0 to RootComp.GetComponentCount - 1 do
      begin
        AComp := RootComp.GetComponent(K);
        CorrectProp(FormEditor.GetFileName, AComp);
      end;

      // 有修改属性则刷新 Object Inspector
      if FCorrectItemList.Count > CorResultCount then
        CnOtaNotifyFormDesignerModified(FormEditor);
    end;
  end;
end;

procedure TCnCorPropForm.AddCorrItem(AItem: TCnCorrectItem);
begin
  FCorrectItemList.Add(AItem);
end;

procedure TCnCorPropForm.SetCorrectItemList(const Value: TObjectList);
begin
  FCorrectItemList := Value;
end;

procedure TCnCorPropForm.ClearItems;
begin
  lvResult.Items.BeginUpdate;
  lvResult.Items.Clear;
  lvResult.Items.EndUpdate;
  CorrectItemList.Clear;
end;

procedure TCnCorPropForm.UpdateView;
var
  I: Integer;
  AItem: TCnCorrectItem;
  AViewItem: TListItem;
begin
  lvResult.Items.BeginUpdate;
  // 将 Item 添加到 ListView 中去
  for I := 0 to FCorrectItemList.Count - 1 do
  begin
    AItem := TCnCorrectItem(FCorrectItemList.Items[I]);
    AViewItem := lvResult.Items.Add;
    if AItem.PropDef.Action = paCorrect then
    begin
      AViewItem.ImageIndex := 0;
      AViewItem.Caption := SCnCorrectPropertyStateCorrected;
    end
    else
    begin
      AViewItem.ImageIndex := 1;
      AViewItem.Caption := SCnCorrectPropertyStateWarning;
    end;
    AViewItem.SubItems.Add(_CnChangeFileExt(_CnExtractFileName(AItem.FileName), ''));
    AViewItem.SubItems.Add(AItem.CorrComp.Name + '.' + AItem.PropDef.PropName);
    with AItem do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('UpdateView. PropName %s', [PropDef.PropName]);
{$ENDIF}

      AViewItem.SubItems.Add(OldValue);
      AViewItem.SubItems.Add(PropDef.ToValue);
    end;
  end;
  lvResult.Items.EndUpdate;
end;

function TCnCorPropForm.GetCorrectRange: TCnCorrectRange;
begin
  if rbForm.Checked then
    Result := crCurrent
  else if rbOpened.Checked then
    Result := crOpened
  else if rbProject.Checked then
    Result := crProject
  else
    Result := crGroup;
end;

procedure TCnCorPropForm.SetCorrectRange(const Value: TCnCorrectRange);
begin
  case Value of
    crCurrent: rbForm.Checked:=true;
    crProject: rbProject.Checked:=true;
    crGroup: rbGroup.checked:=true;
  end;
end;

procedure TCnCorPropForm.CorrectGroup;
var
  CurrentGroup: IOTAProjectGroup;
  Project:IOTAProject;
  I: Integer;
begin
  CurrentGroup := CnOtaGetProjectGroup;
  Assert(Assigned(CurrentGroup));
  for I := 0 to CurrentGroup.GetProjectCount - 1 do
  begin
    Project:=CurrentGroup.GetProject(I);
    CorrectProject(Project);
  end;
end;

{ TCnCorrectItem }

procedure TCnCorrectItem.SetCorrComp(const Value: TComponent);
begin
  FCorrComp := Value;
end;

procedure TCnCorrectItem.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

procedure TCnCorrectItem.SetOldValue(const Value: string);
begin
  FOldValue := Value;
end;

procedure TCnCorrectItem.SetPropDef(const Value: TCnPropDef);
begin
  FPropDef := Value;
end;

procedure TCnCorPropForm.FormCreate(Sender: TObject);
begin
  FCorrectItemList := TObjectList.Create;
  EnlargeListViewColumns(lvResult);
end;

procedure TCnCorPropForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCorrectItemList);
end;

procedure TCnCorrectItem.SetPropName(const Value: string);
begin
  FPropName := Value;
end;

procedure TCnCorPropForm.actCorrectCompUpdate(Sender: TObject);
begin
  // 如果已经更新过了
  if Assigned(lvResult.Selected) then
    (Sender as TAction).Enabled := lvResult.Selected.ImageIndex <> 0
  else
    (Sender as TAction).Enabled := False;
end;

procedure TCnCorPropForm.actLocateCompUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(lvResult.Selected);
end;

procedure TCnCorPropForm.actCorrectCompExecute(Sender: TObject);
var
  AItem: TCnCorrectItem;
  I: Integer;
begin
  // 更新属性
  for I := 0 to lvResult.Items.Count - 1 do
  begin
    if lvResult.Items[I].Selected and (lvResult.Items[I].ImageIndex > 0) then
    begin
      AItem := TCnCorrectItem(FCorrectItemList.Items[lvResult.Items[I].Index]);
      if SetPropValueIncludeSub(AItem.CorrComp, AItem.PropName, AItem.PropDef.ToValue, AItem.CorrComp.Owner) then
      begin
        lvResult.Items[I].ImageIndex := 0;
        lvResult.Items[I].Caption := SCnCorrectPropertyStateCorrected;
      end;
    end;
  end;
end;

procedure TCnCorPropForm.actLocateCompExecute(Sender: TObject);
var
  AItem: TCnCorrectItem;
  Module: IOTAModule;
  I: Integer;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
  NTAComp: INTAComponent;
begin
  with lvResult.Selected do
    AItem := TCnCorrectItem(FCorrectItemList.Items[Index]);

  if IsDelphiRuntime then
    Module := CnOtaGetModule(_CnChangeFileExt(AItem.FileName, '.pas'))
  else
    Module := CnOtaGetModule(_CnChangeFileExt(AItem.FileName, '.cpp'));

  if not Assigned(Module) then
  begin
    ErrorDlg(SCnCorrectPropertyErrNoModuleFound);
    Exit;
  end;

  for I := 0 to Module.GetModuleFileCount - 1 do
  begin
    Editor := Module.GetModuleFileEditor(I);
    if Editor.QueryInterface(IOTAFormEditor, FormEditor) = S_OK then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Locate Component');
    {$ENDIF}
      try
        Editor.Show;
        NTAComp := FormEditor.GetRootComponent as INTAComponent;

        if NTAComp.GetComponent.Name = AItem.CorrComp.Name then
          // 如果是 Form 或 DataModule
          FormEditor.GetRootComponent.Select(False)
        else
          FormEditor.FindComponent(AItem.CorrComp.Name).Select(False);
      except
        ErrorDlg(SCnCorrectPropertyErrNoModuleFound);
        Continue;
      end;
    end;
  end;
end;

procedure TCnCorPropForm.btnAllClick(Sender: TObject);
var
  AItem: TCnCorrectItem;
  I: Integer;
begin
  // 更新属性
  for I := 0 to lvResult.Items.Count - 1 do
  begin
    AItem := TCnCorrectItem(FCorrectItemList.Items[I]);
    if lvResult.Items[I].ImageIndex <> 0 then
    begin
      if SetPropValueIncludeSub(AItem.CorrComp, AItem.PropName, AItem.PropDef.ToValue, AItem.CorrComp.Owner) then
      begin
        with lvResult.Items[I] do
        begin
          ImageIndex := 0;
          Caption := SCnCorrectPropertyStateCorrected;
        end;
      end;
    end;
  end;
end;

procedure TCnCorPropForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCnCorPropForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnCorPropForm.GetHelpTopic: string;
begin
  Result := 'CnCorrectProperty';
end;

procedure TCnCorPropForm.FormActivate(Sender: TObject);
begin
  rbProject.Enabled := CnOtaGetCurrentProject <> nil;
  rbGroup.Enabled := CnOtaGetProjectGroup <> nil;
  if not rbProject.Enabled then
    rbForm.Checked := True;

  // 如果删除了已经修改的控件，双击定位到该控件的时候因为找不到，
  // 所以会抛出一个异常，以下调用将保证每次激活窗口时自动更新列表
  // 这不是好办法，而且会引起速度慢，所以先屏蔽掉再考虑使用事件，
  // if lvResult.Items.Count > 0 then
  //   actCorrectExecute(nil);
end;

procedure TCnCorPropForm.lvResultDblClick(Sender: TObject);
begin
  if lvResult.Selected <> nil then
    actLocateComp.Execute;
end;

procedure TCnCorPropForm.actUndoCorrectUpdate(Sender: TObject);
begin
  // 如果已经更新过了
  if Assigned(lvResult.Selected) then
    (Sender as TAction).Enabled := lvResult.Selected.ImageIndex = 0
  else
    (Sender as TAction).Enabled := False;
end;

procedure TCnCorPropForm.actUndoCorrectExecute(Sender: TObject);
var
  AItem: TCnCorrectItem;
  I: Integer;
begin
  // 更新属性
  for I := 0 to lvResult.Items.Count - 1 do
  begin
    if lvResult.Items[I].Selected and (lvResult.Items[I].ImageIndex = 0) then
    begin
      AItem := TCnCorrectItem(FCorrectItemList.Items[lvResult.Items[I].Index]);
      if SetPropValueIncludeSub(AItem.CorrComp, AItem.PropName, AItem.OldValue, AItem.CorrComp.Owner) then
      begin
        lvResult.Items[I].ImageIndex := 1;
        lvResult.Items[I].Caption := SCnCorrectPropertyStateWarning;
      end;
    end;
  end;
end;

procedure TCnCorPropForm.actConfirmSelectedExecute(Sender: TObject);
var
  AItem: TCnCorrectItem;
  I: Integer;
begin
  // 更新选中的属性
  for I := 0 to lvResult.Items.Count - 1 do
  begin
    AItem := TCnCorrectItem(FCorrectItemList.Items[I]);
    if (lvResult.Items[I].ImageIndex <> 0) and lvResult.Items[I].Selected then
    begin
      if SetPropValueIncludeSub(AItem.CorrComp, AItem.PropName, AItem.PropDef.ToValue, AItem.CorrComp.Owner) then
      begin
        with lvResult.Items[I] do
        begin
          ImageIndex := 0;
          Caption := SCnCorrectPropertyStateCorrected;
        end;
      end;
    end;
  end;
end;

procedure TCnCorPropForm.actConfirmSelectedUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(lvResult.Selected);
end;

procedure TCnCorPropForm.DoLanguageChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvResult.Items.Count - 1 do
    case lvResult.Items[I].ImageIndex of
      0: lvResult.Items[I].Caption := SCnCorrectPropertyStateCorrected;
      1: lvResult.Items[I].Caption := SCnCorrectPropertyStateWarning;
    end;
end;

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}
end.
