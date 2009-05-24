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

unit CnProjectListUsedFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：被引用单元列表窗体
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWinXPPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id: CnProjectListUsedFrm.pas,v 1.9 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2007.07.03 V1.0
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
  Graphics, ImgList, ActnList,
  CnPasCodeParser,  CnWizIdeUtils, CnEditorOpenFile, CnWizUtils, CnIni,
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizMultiLang,
  CnProjectViewBaseFrm, CnProjectViewUnitsFrm, CnLangMgr;

type

//==============================================================================
// 被引用单元列表窗体
//==============================================================================

{ TCnProjectListUsedForm }

  TCnProjectListUsedForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
  private
    FUsedList: TStringList;
    FDisplayList: TStringList;
    FCurFile: string;
    FIsDpr: Boolean;
    FIsPas: Boolean;
    FIsC: Boolean;
  protected
    procedure DoUpdateListView; override;
    function DoSelectOpenedItem: string; override;
    procedure OpenSelect; override;
    function GetSelectedFileName: string; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure UpdateStatusBar; override;
    procedure DoSortListView; override;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    { Public declarations }
    class procedure ParseUnitInclude(const Source: string; UsesList: TStrings);
  end;

function ShowProjectListUsed(Ini: TCustomIniFile): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csListUsed = 'ListUsed';

type
  TControlAccess = class(TControl);

function ShowProjectListUsed(Ini: TCustomIniFile): Boolean;
begin
  with TCnProjectListUsedForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csListUsed);
      Result := ShowModal = mrOk;
      SaveSettings(Ini, csListUsed);
      if Result then
        BringIdeEditorFormToFront;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// 被引用单元列表窗体
//==============================================================================

{ TCnProjectListUsedForm }

procedure TCnProjectListUsedForm.CreateList;
var
  Stream: TMemoryStream;
  TmpName: string;
begin
  FreeAndNil(FUsedList);
  if FUsedList = nil then
    FUsedList := TStringList.Create
  else
    FUsedList.Clear;
    
  FCurFile := CnOtaGetCurrentSourceFile;

  if FCurFile <> '' then
  begin
    if IsForm(FCurFile) then
    begin
      TmpName := ChangeFileExt(FCurFile, '.pas');
      if CnOtaIsFileOpen(TmpName) then
        FCurFile := TmpName
      else
      begin
        TmpName := ChangeFileExt(FCurFile, '.cpp');
        if CnOtaIsFileOpen(TmpName) then
          FCurFile := TmpName;
      end;
    end;

    Stream := TMemoryStream.Create;
    try
      CnOtaSaveCurrentEditorToStream(Stream, False);
      if IsDelphiSourceModule(FCurFile) then
      begin
        FIsPas := True;
        FIsDpr := IsDpr(FCurFile);
        ParseUnitUses(PAnsiChar(Stream.Memory), FUsedList);
      end
      else if IsCppSourceModule(FCurFile) then
      begin
        // 解析 C 的 include
        FIsC := True;
        ParseUnitInclude(PChar(Stream.Memory), FUsedList);
      end;
    finally
      Stream.Free;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogStrings(FUsedList, 'Used List.');
{$ENDIF}
  end;
end;

function TCnProjectListUsedForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtListUsed';
end;

procedure TCnProjectListUsedForm.OpenSelect;
var
  I: Integer;
  Error: Boolean;
begin
  Error := False;
  if lvList.SelCount > 0 then
  begin
    if (lvList.SelCount > 1) and actQuery.Checked then
      if not QueryDlg(SCnProjExtOpenUnitWarning, False, SCnInformation) then
        Exit;

    for I := 0 to lvList.Items.Count - 1 do
      if lvList.Items[I].Selected then
        if not TCnEditorOpenFile.SearchAndOpenFile(lvList.Items[I].Caption) then
        begin
          Error := True;
          ErrorDlg(SCnEditorOpenFileNotFind);
        end;

    if not Error then
      ModalResult := mrOK;    
  end;
end;

procedure TCnProjectListUsedForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnProjExtUnitsFileCount, [FDisplayList.Count]);
end;

procedure TCnProjectListUsedForm.lvListData(Sender: TObject;
  Item: TListItem);
begin
  if (FDisplayList <> nil) and (Item.Index >= 0) and
    (Item.Index < FDisplayList.Count) then
  begin
    Item.Caption := FDisplayList[Item.Index];
    Item.ImageIndex := 78;
    if FIsDpr then
      Item.SubItems.Add('project')
    else if FIsC then
      Item.SubItems.Add('include')
    else
    begin
      if FDisplayList.Objects[Item.Index] = nil then
        Item.SubItems.Add('interface')
      else
        Item.SubItems.Add('implementation');
    end;
    RemoveListViewSubImages(Item);
  end;
end;

procedure TCnProjectListUsedForm.DoUpdateListView;
var
  MatchSearchText: string;
  IsMatchAny: Boolean;
  I, ToSelIndex: Integer;
  ToSelUnitInfos: TStringList;
begin
  MatchSearchText := edtMatchSearch.Text;
  IsMatchAny := MatchAny;
  ToSelIndex := 0;
  ToSelUnitInfos := TStringList.Create;

  if FDisplayList = nil then
    FDisplayList := TStringList.Create
  else
    FDisplayList.Clear;

  try
    for I := 0 to FUsedList.Count - 1 do
    begin
      if (MatchSearchText = '') or (AnsiStartsText(MatchSearchText, FUsedList[I])) or
        (IsMatchAny and AnsiContainsText(FUsedList[I], MatchSearchText)) then
      begin
        FDisplayList.AddObject(FUsedList[I], FUsedList.Objects[I]);
        // 全匹配时，提高首匹配的优先级，记下第一个该首匹配的项以备选中
        if IsMatchAny and AnsiStartsText(MatchSearchText, FUsedList[I]) then
          ToSelUnitInfos.Add(FUsedList[I]);
      end;
    end;

    DoSortListView;
    lvList.Items.Count := FDisplayList.Count;
    lvList.Invalidate;
    UpdateStatusBar;

    // 如有需要选中的首匹配的项则选中，无则选 0，第一项
    if (ToSelUnitInfos.Count > 0) and (FDisplayList.Count > 0) then
    begin
      for I := 0 to FDisplayList.Count - 1 do
      begin
        if ToSelUnitInfos.IndexOf(FDisplayList[I]) >= 0 then
        begin
          // CurrList 中的第一个在 SelUnitInfos 里头的项
          ToSelIndex := I;
          Break;
        end;
      end;
    end;
    SelectItemByIndex(ToSelIndex);
  finally
    ToSelUnitInfos.Free;
  end;
end;

procedure TCnProjectListUsedForm.UpdateComboBox;
begin
// Do nothing for Combo Hidden.
end;

procedure TCnProjectListUsedForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(FUsedList);
  FreeAndNil(FDisplayList);
end;

procedure TCnProjectListUsedForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin
// DO nothing. Not draw here.
end;

function TCnProjectListUsedForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := ChangeFileExt(ExtractFileName(CurrentModule.FileName), '');
end;

function TCnProjectListUsedForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(lvList.ItemFocused.Caption);
end;

class procedure TCnProjectListUsedForm.ParseUnitInclude(
  const Source: string; UsesList: TStrings);
const
  SCnInclude = '#include';
var
  I, Len: Integer;
begin
  Len := Length(SCnInclude);
  if (UsesList <> nil) and (Source <> '') then
  begin
    UsesList.Text := Source;
    for I := UsesList.Count - 1 downto 0 do
    begin
      if AnsiStartsText(SCnInclude, Trim(UsesList[I])) then
      begin
        UsesList[I] := Trim(Copy(Trim(UsesList[I]), Len + 1, MaxInt));
        UsesList[I] := StringReplace(UsesList[I], '"', '', [rfReplaceAll, rfIgnoreCase]);
        UsesList[I] := StringReplace(UsesList[I], '<', '', [rfReplaceAll, rfIgnoreCase]);
        UsesList[I] := StringReplace(UsesList[I], '>', '', [rfReplaceAll, rfIgnoreCase]);

        if Length(UsesList[I]) = 0 then
          UsesList.Delete(I);
      end
      else
        UsesList.Delete(I);
    end;
  end;
end;

procedure TCnProjectListUsedForm.DoLanguageChanged(Sender: TObject);
begin
  try
    ToolBar.ShowCaptions := True;
    ToolBar.ShowCaptions := False;
  except
    ;
  end;
end;

var
  _SortIndex: Integer;
  _SortDown: Boolean;
  _MatchStr: string;

function DoListSort(List: TStringList; Index1, Index2: Integer): Integer;
begin
  case _SortIndex of
    0: Result := CompareTextPos(_MatchStr, List[Index1], List[Index2]);
    1: Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
  else
    Result := 0;
  end;

  if _SortDown then
    Result := -Result;
end;

procedure TCnProjectListUsedForm.DoSortListView;
var
  Sel: string;
begin
  if lvList.Selected <> nil then
    Sel := lvList.Selected.Caption
  else
    Sel := '';

  _SortIndex := SortIndex;
  _SortDown := SortDown;
  if MatchAny then
    _MatchStr := edtMatchSearch.Text
  else
    _MatchStr := '';
  FDisplayList.CustomSort(DoListSort);
  lvList.Invalidate;

  if Sel <> '' then
    SelectItemByIndex(FDisplayList.IndexOf(Sel));
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
