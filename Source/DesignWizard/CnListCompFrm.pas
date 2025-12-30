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

unit CnListCompFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：设计器组件列表窗体
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2021.08.13 V1.1
*               增加一独立调用供外界选择组件
*           2018.03.24 V1.1
*               跟随基类重构
*           2008.03.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDESIGNWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
  {$IFDEF COMPILER6_UP}
  StrUtils, DesignIntf, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, ImgList, ActnList, Menus,
  CnPasCodeParser, CnWizIdeUtils, CnWizUtils, CnIni,
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizMultiLang, CnWizManager,
  CnProjectViewBaseFrm, CnProjectViewUnitsFrm, CnLangMgr, CnStrings;

type

//==============================================================================
// 设计器组件列表窗体
//==============================================================================

{ TCnListCompForm }

  TCnListCompForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure actHookIDEExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actAttributeExecute(Sender: TObject);
  private
    FSingleMode: Boolean;

  protected
    function DoSelectOpenedItem: string; override;
    procedure OpenSelect; override;
    function GetSelectedFileName: string; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure UpdateStatusBar; override;
    procedure DoLanguageChanged(Sender: TObject); override;

    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;

    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
  public
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string); override;
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string); override;

    property SingleMode: Boolean read FSingleMode write FSingleMode;
  end;

function CnListComponent(Ini: TCustomIniFile): Boolean;
{* 弹出选择界面并选中一个或多个组件}

function CnListComponentForOne(Ini: TCustomIniFile): TComponent;
{* 供外界调用以弹出界面并返回一个当前设计器上的组件}

{$ENDIF CNWIZARDS_CNDESIGNWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDESIGNWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csListComp = 'ListComp';
  csShowEmptyNames = 'ShowEmptyNames';

type
  TCnCompInfo = class(TCnBaseElementInfo)
  private
    FCompClass: string;
    FCaptionText: string;
    FComponent: TComponent;
    FIsControl: Boolean;
    FIsMenuItem: Boolean;
  public
    property CompClass: string read FCompClass write FCompClass;
    property CaptionText: string read FCaptionText write FCaptionText;
    property IsControl: Boolean read FIsControl write FIsControl;
    property IsMenuItem: Boolean read FIsMenuItem write FIsMenuItem;
    property Component: TComponent read FComponent write FComponent;
  end;

  TCnControlHack = class(TControl);

var
  FDestList: IDesignerSelections;

function CnListComponent(Ini: TCustomIniFile): Boolean;
var
  FormDesigner: IDesigner;
begin
  Result := False;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ListComponent Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

  FDestList := CreateSelectionList;
  with TCnListCompForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      if Ini <> nil then
        LoadSettings(Ini, csListComp);

      Result := ShowModal = mrOk;
      if Ini <> nil then
        SaveSettings(Ini, csListComp);
      if Result then
        FormDesigner.SetSelections(FDestList);
    finally
      FDestList := nil;  // 确保释放接口
      Free;
    end;
  end;
end;

function CnListComponentForOne(Ini: TCustomIniFile): TComponent;
var
  FormDesigner: IDesigner;
begin
  Result := nil;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ListComponentForOne Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

  FDestList := CreateSelectionList;
  with TCnListCompForm.Create(nil) do
  begin
    try
      SingleMode := True;

      ShowHint := WizOptions.ShowHint;
      if Ini <> nil then
        LoadSettings(Ini, csListComp);

      if ShowModal = mrOk then
      begin
        if FDestList.Count > 0 then
        begin
{$IFDEF COMPILER6_UP}
          Result := TComponent(FDestList[0]);
{$ELSE}
          Result := TComponent(ExtractPersistent(FDestList[0]));
{$ENDIF}
        end;
      end;

      if Ini <> nil then
        SaveSettings(Ini, csListComp);
    finally
      FDestList := nil;  // 确保释放接口
      Free;
    end;
  end;
end;

//==============================================================================
// 设计器组件列表窗体
//==============================================================================

{ TCnListCompForm }

procedure TCnListCompForm.CreateList;
var
  I: Integer;
  DesignContainer: TComponent;

  function CompListIndexOf(AComponent: TComponent): Integer;
  var
    I: Integer;
    Info: TCnCompInfo;
  begin
    Result := -1;
    for I := 0 to DataList.Count - 1 do
    begin
      Info := TCnCompInfo(DataList.Objects[I]);
      if Info <> nil then
      begin
        if Info.Component = AComponent then
        begin
          Result := I;
          Exit;
        end;  
      end;  
    end;  
  end;

  // 增加一项条目
  procedure AddItem(AComponent: TComponent; IncludeChildren: Boolean = False);
  var
    I: Integer;
    Info: TCnCompInfo;
  begin
    if CompListIndexOf(AComponent) < 0 then
    begin
      Info := TCnCompInfo.Create;
      Info.Text := AComponent.Name;
      Info.CompClass := AComponent.ClassName;
      Info.Component := AComponent;
      Info.IsControl := AComponent is TControl;
      Info.IsMenuItem := AComponent is TMenuItem;

      if Info.IsControl then
        Info.CaptionText := TCnControlHack(AComponent).Text
      else if Info.IsMenuItem then
        Info.CaptionText := TMenuItem(AComponent).Caption;

      DataList.AddObject(AComponent.Name, Info);

      // 递归增加子控件
      if IncludeChildren and (AComponent is TWinControl) then
        for I := 0 to TWinControl(AComponent).ControlCount - 1 do
          AddItem(TWinControl(AComponent).Controls[i], True);
    end;
  end;

begin
  // 检查 ComponentSelector
  if CnWizardMgr.WizardByClassName('TCnComponentSelector') = nil then
    btnHookIDE.Visible := False
  else
    actHookIDE.ImageIndex := CnWizardMgr.ImageIndexByClassName('TCnComponentSelector');

  DesignContainer := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
  if DesignContainer <> nil then
  begin
    AddItem(DesignContainer, False);
    for I := 0 to DesignContainer.ComponentCount - 1 do
      AddItem(DesignContainer.Components[I], True);
  end;
end;

function TCnListCompForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

procedure TCnListCompForm.OpenSelect;
var
  I: Integer;
begin
  if lvList.SelCount > 0 then
  begin
    for I := 0 to lvList.Items.Count - 1 do
    begin
      if lvList.Items[I].Selected and (lvList.Items[I].Data <> nil) then
      begin
        {$IFDEF COMPILER6_UP}
          FDestList.Add(TCnCompInfo(lvList.Items[i].Data).Component);
        {$ELSE}
          FDestList.Add(MakeIPersistent(TCnCompInfo(lvList.Items[i].Data).Component));
        {$ENDIF}
      end;
    end;

    ModalResult := mrOK;
  end;
end;

procedure TCnListCompForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnListComponentCount, [DisplayList.Count]);
end;

procedure TCnListCompForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnCompInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnCompInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    if Info.IsControl then
      Item.ImageIndex := 67
    else if Info.IsMenuItem then
      Item.ImageIndex := 93
    else
      Item.ImageIndex := 90; // 暂不管精确绘制组件图标

    Item.SubItems.Add(Info.CompClass);
    Item.SubItems.Add(Info.CaptionText);
    RemoveListViewSubImages(Item);
    Item.Data := Info;
  end;
end;

procedure TCnListCompForm.UpdateComboBox;
begin
  // Do nothing for Combo Hidden.
end;

function TCnListCompForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnListCompForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(lvList.ItemFocused.Caption);
end;

procedure TCnListCompForm.DoLanguageChanged(Sender: TObject);
begin
  try
    ToolBar.ShowCaptions := True;
    ToolBar.ShowCaptions := False;
  except
    ;
  end;
end;

procedure TCnListCompForm.actHookIDEExecute(Sender: TObject);
begin
  if CnWizardMgr.WizardByClassName('TCnComponentSelector') <> nil then
  begin
    ModalResult := mrNone;
    Hide;
    CnWizardMgr.WizardByClassName('TCnComponentSelector').Execute;
    Close;
  end;
end;

procedure TCnListCompForm.actAttributeExecute(Sender: TObject);
begin
  actAttribute.Checked := not actAttribute.Checked;
  UpdateListView;
end;

procedure TCnListCompForm.FormShow(Sender: TObject);
begin
  inherited;

  if FSingleMode then
  begin
    actHookIDE.Visible := False;
    actSelectAll.Visible := False;
    actSelectNone.Visible := False;
    actSelectInvert.Visible := False;
    actOpen.Visible := False;
  end
  else
    actHookIDE.Checked := False;
end;

function TCnListCompForm.CanMatchDataByIndex(const AMatchStr: string;
  AMatchMode: TCnMatchMode; DataListIndex: Integer; var StartOffset: Integer;
  MatchedIndexes: TList): Boolean;
var
  Info: TCnCompInfo;
  UpperMatch: string;
begin
  Result := False;
  if AMatchStr = '' then
  begin
    // 空名字且不显示空名字的话就退出
    if not actAttribute.Checked and (DataList[DataListIndex] = '') then
      Exit;

    Result := True;
    Exit;
  end;

  Info := TCnCompInfo(DataList.Objects[DataListIndex]);
  if Info = nil then
    Exit;

  // 空名字且不显示空名字的话就退出
  if not actAttribute.Checked and (DataList[DataListIndex] = '') then
    Exit;

  if AMatchMode in [mmStart, mmAnywhere] then
    UpperMatch := UpperCase(AMatchStr);

  case AMatchMode of // 搜索时三列都参与匹配，不区分大小写
    mmStart:
      begin
        Result := (Pos(UpperMatch, UpperCase(DataList[DataListIndex])) = 1)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) = 1)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) = 1);
      end;
    mmAnywhere:
      begin
        Result := (Pos(UpperMatch, UpperCase(DataList[DataListIndex])) > 0)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) > 0)
          or (Pos(UpperMatch, UpperCase(Info.CaptionText)) > 0);
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes)
          or FuzzyMatchStr(AMatchStr, Info.CompClass)
          or FuzzyMatchStr(AMatchStr, Info.CaptionText);
      end;
  end;
end;

function TCnListCompForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnCompInfo;
begin
  Info1 := TCnCompInfo(Obj1);
  Info2 := TCnCompInfo(Obj2);

  case ASortIndex of // 因为搜索时三列都参与匹配，因此排序时也要考虑到把全匹配提前
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
      end;
    1:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.CompClass, Info2.CompClass, SortDown);
      end;
    2:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.CaptionText, Info2.CaptionText, SortDown);
      end;
  else
    Result := 0;
  end;
end;

procedure TCnListCompForm.LoadSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  inherited;
  actAttribute.Checked := Ini.ReadBool(aSection, csShowEmptyNames, True);
end;

procedure TCnListCompForm.SaveSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  inherited;
  Ini.WriteBool(aSection, csShowEmptyNames, actAttribute.Checked);
end;

{$ENDIF CNWIZARDS_CNDESIGNWIZARD}
end.
