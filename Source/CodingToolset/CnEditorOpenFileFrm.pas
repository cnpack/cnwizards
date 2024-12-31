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

unit CnEditorOpenFileFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编码工具集打开文件的结果列表单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2015.2.7 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

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

//==============================================================================
// 搜索结果列表窗体
//==============================================================================

{ TCnEditorOpenFileForm }

  TCnEditorOpenFileForm = class(TCnProjectViewBaseForm)
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure lvListData(Sender: TObject; Item: TListItem);
  private
    FListRef: TStrings;
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
  public
    { Public declarations }
    constructor Create(Owner: TComponent; List: TStrings); reintroduce;
  end;

function ShowOpenFileResultList(List: TStrings): Boolean;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

function ShowOpenFileResultList(List: TStrings): Boolean;
begin
  with TCnEditorOpenFileForm.Create(nil, List) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      Result := ShowModal = mrOk;
      if Result then
        BringIdeEditorFormToFront;
      List.Clear;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// 搜索结果列表窗体
//==============================================================================

{ TCnEditorOpenFileForm }

function TCnEditorOpenFileForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  if CurrentModule <> nil then
    Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnEditorOpenFileForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(DataList[lvList.ItemFocused.Index]);
end;

function TCnEditorOpenFileForm.GetHelpTopic: string;
begin
  Result := 'CnEditorOpenFile';
end;

procedure TCnEditorOpenFileForm.OpenSelect;
var
  I: Integer;
  Item: TListItem;
begin
  Item := lvList.Selected;

  if not Assigned(Item) then
    Exit;

  if lvList.SelCount <= 1 then
    CnOtaOpenFile(DataList[Item.Index])
  else
  begin
    for I := 0 to lvList.Items.Count - 1 do
    begin
      Item := lvList.Items[I];
      if Item.Selected then
        CnOtaOpenFile(DataList[Item.Index]);
    end;
  end;

  ModalResult := mrOK;
end;

procedure TCnEditorOpenFileForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(DataList[Item.Index]) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, DataList[Item.Index]);

    StatusBar.Hint := DataList[Item.Index];
  end;
end;

procedure TCnEditorOpenFileForm.CreateList;
begin
  DataList.Assign(FListRef);
  ToolBar.Visible := False;
  pnlHeader.Visible := False;
end;

procedure TCnEditorOpenFileForm.UpdateComboBox;
begin
  cbbProjectList.Visible := False;
  lblProject.Visible := False;
end;

procedure TCnEditorOpenFileForm.DoUpdateListView;
begin
  lvList.Items.Count := DataList.Count;
  lvList.Invalidate;

  UpdateStatusBar;
  if DataList.Count > 0 then
    SelectItemByIndex(0);
end;

procedure TCnEditorOpenFileForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := IntToStr(lvList.Items.Count);
  end;
end;

procedure TCnEditorOpenFileForm.lvListData(Sender: TObject;
  Item: TListItem);
begin
  if (Item.Index >= 0) and (Item.Index < DataList.Count) then
  begin
    Item.Caption := _CnExtractFileName(DataList[Item.Index]);
    Item.ImageIndex := 78;

    with Item.SubItems do
    begin
      Add(_CnExtractFilePath(DataList[Item.Index]));
    end;
    RemoveListViewSubImages(Item);
  end;
end;

procedure TCnEditorOpenFileForm.DoSortListView;
begin

end;

constructor TCnEditorOpenFileForm.Create(Owner: TComponent;
  List: TStrings);
begin
  inherited Create(Owner);
  FListRef := List;
end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.

