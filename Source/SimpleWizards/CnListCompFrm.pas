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

unit CnListCompFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：设计器组件列表窗体
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2008.03.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

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
  CnProjectViewBaseFrm, CnProjectViewUnitsFrm, CnLangMgr;

type

//==============================================================================
// 设计器组件列表窗体
//==============================================================================

{ TCnListCompForm }

  TCnListCompForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure actHookIDEExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCompList: TStringList;
    FDisplayList: TStringList;
  protected
    procedure DoUpdateListView; override;
    function DoSelectOpenedItem: string; override;
    procedure OpenSelect; override;
    function GetSelectedFileName: string; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure UpdateStatusBar; override;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    { Public declarations }
  end;

function CnListComponent(Ini: TCustomIniFile): Boolean;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csListComp = 'ListComp';

type
  TCnCompInfo = class(TObject)
  private
    FCompClass: string;
    FCompName: string;
    FCaptionText: string;
    FComponent: TComponent;
    FIsControl: Boolean;
    FIsMenuItem: Boolean;
  public
    property CompName: string read FCompName write FCompName;
    property CompClass: string read FCompClass write FCompClass;
    property CaptionText: string read FCaptionText write FCaptionText;
    property IsControl: Boolean read FIsControl write FIsControl;
    property IsMenuItem: Boolean read FIsMenuItem write FIsMenuItem;
    property Component: TComponent read FComponent write FComponent;
  end;

  TCnControlHack = class(TControl);

var
  FDestList: IDesignerSelections;
  FSourceList: IDesignerSelections;

function CnListComponent(Ini: TCustomIniFile): Boolean;
var
  FormDesigner: IDesigner;
begin
  Result := False;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

  FSourceList := CreateSelectionList;
  FDestList := CreateSelectionList;
  FormDesigner.GetSelections(FSourceList);

  with TCnListCompForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csListComp);

      Result := ShowModal = mrOk;
      SaveSettings(Ini, csListComp);
      if Result then
        FormDesigner.SetSelections(FDestList);
    finally
      FSourceList := nil; // 确保释放接口
      FDestList := nil;
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
    for I := 0 to FCompList.Count - 1 do
    begin
      Info := TCnCompInfo(FCompList.Objects[I]);
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
      Info.CompName := AComponent.Name;
      Info.CompClass := AComponent.ClassName;
      Info.Component := AComponent;
      Info.IsControl := AComponent is TControl;
      Info.IsMenuItem := AComponent is TMenuItem;

      if Info.IsControl then
        Info.CaptionText := TCnControlHack(AComponent).Text
      else if Info.IsMenuItem then
        Info.CaptionText := TMenuItem(AComponent).Caption;

      FCompList.AddObject(AComponent.Name, Info);

      // 递归增加子控件
      if IncludeChildren and (AComponent is TWinControl) then
        for I := 0 to TWinControl(AComponent).ControlCount - 1 do
          AddItem(TWinControl(AComponent).Controls[i], True);
    end;
  end;

begin
  // 检查 ComponentSelector
  if CnWizardMgr.WizardByClassName('TCnComponentSelector') = nil then
    btnHookIDE.Visible := False;

  FCompList := TStringList.Create;
  FDisplayList := TStringList.Create;

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
  StatusBar.Panels[1].Text := Format(SCnListComponentCount, [FDisplayList.Count]);
end;

procedure TCnListCompForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnCompInfo;
begin
  if (FDisplayList <> nil) and (Item.Index >= 0) and
    (Item.Index < FDisplayList.Count) then
  begin
    Info := TCnCompInfo(FDisplayList.Objects[Item.Index]);
    Item.Caption := Info.CompName;
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

procedure TCnListCompForm.DoUpdateListView;
var
  MatchSearchText: string;
  IsMatchAny: Boolean;
  I, ToSelIndex: Integer;
  ToSelCompInfos: TStringList;
  Info: TCnCompInfo;
begin
  MatchSearchText := edtMatchSearch.Text;
  IsMatchAny := MatchAny;
  ToSelIndex := 0;
  ToSelCompInfos := TStringList.Create;

  FDisplayList.Clear;

  try
    for I := 0 to FCompList.Count - 1 do
    begin
      Info := TCnCompInfo(FCompList.Objects[I]);
      if Info = nil then
        Continue;

      if (MatchSearchText = '') or (AnsiStartsText(MatchSearchText, FCompList[I])) or
        (IsMatchAny and AnsiContainsText(FCompList[I], MatchSearchText)) then
      begin
        FDisplayList.AddObject(FCompList[I], FCompList.Objects[I]);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and AnsiStartsText(MatchSearchText, FCompList[I]) then
          ToSelCompInfos.Add(FCompList[I]);
      end
      else if (AnsiStartsText(MatchSearchText, Info.CompClass)) or
        (IsMatchAny and AnsiContainsText(Info.CompClass, MatchSearchText)) then
      begin
        FDisplayList.AddObject(FCompList[I], FCompList.Objects[I]);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and AnsiStartsText(MatchSearchText, Info.CompClass) then
          ToSelCompInfos.Add(FCompList[I]);
      end
      else if (AnsiStartsText(MatchSearchText, Info.CaptionText)) or
        (IsMatchAny and AnsiContainsText(Info.CaptionText, MatchSearchText)) then
      begin
        FDisplayList.AddObject(FCompList[I], FCompList.Objects[I]);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and AnsiStartsText(MatchSearchText, Info.CaptionText) then
          ToSelCompInfos.Add(FCompList[I]);
      end
    end;

    DoSortListView;
    lvList.Items.Count := FDisplayList.Count;
    lvList.Invalidate;
    UpdateStatusBar;

    // 如有需要选中的首匹配的项则选中，无则选 0，第一项
    if (ToSelCompInfos.Count > 0) and (FDisplayList.Count > 0) then
    begin
      for I := 0 to FDisplayList.Count - 1 do
      begin
        if ToSelCompInfos.IndexOf(FDisplayList[I]) >= 0 then
        begin
          // CurrList 中的第一个在 ToSelCompInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;
    SelectItemByIndex(ToSelIndex);
  finally
    ToSelCompInfos.Free;
  end;
end;

procedure TCnListCompForm.UpdateComboBox;
begin
// Do nothing for Combo Hidden.
end;

procedure TCnListCompForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FCompList.Count - 1 do
    FCompList.Objects[I].Free;
  FreeAndNil(FCompList);
  FreeAndNil(FDisplayList);
  inherited;
end;

procedure TCnListCompForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
// DO nothing. Not draw here.
end;

function TCnListCompForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := ChangeFileExt(ExtractFileName(CurrentModule.FileName), '');
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

procedure TCnListCompForm.FormShow(Sender: TObject);
begin
  inherited;
  actHookIDE.Checked := False;
end;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.
