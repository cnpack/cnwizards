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

unit CnEditorOpenFileFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����빤�߼����ļ��Ľ���б�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXPPro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.2.7 V1.0
*               ������Ԫ
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
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles,
  {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} Graphics, ImgList, ActnList,
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm;

type

//==============================================================================
// ��������б���
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
{$ENDIF}

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
// ��������б���
//==============================================================================

{ TCnEditorOpenFileForm }

function TCnEditorOpenFileForm.DoSelectOpenedItem: string;
{$IFDEF DELPHI_OTA}
var
  CurrentModule: IOTAModule;
{$ENDIF}
begin
{$IFDEF LAZARUS}
  Result := CnOtaGetCurrentSourceFile;
{$ELSE}
  CurrentModule := CnOtaGetCurrentModule;
  if CurrentModule <> nil then
    Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
{$ENDIF}
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

