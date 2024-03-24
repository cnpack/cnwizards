{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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
* 修改记录：2018.03.29 V1.1
*               重构以支持模糊匹配
*           2007.07.03 V1.0
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
  CnProjectViewBaseFrm, CnProjectViewUnitsFrm, CnLangMgr, CnStrings;

type

//==============================================================================
// 被引用单元列表窗体
//==============================================================================

{ TCnProjectListUsedForm }

  TCnProjectListUsedForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
  private
    FCurFile: string;
    FIsDpr: Boolean;
    FIsPas: Boolean;
    FIsC: Boolean;
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
    procedure DrawListPreParam(Item: TListItem; ListCanvas: TCanvas); override;
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

  TCnUsedUnitInfo = class(TCnBaseElementInfo)
  private
    FInImpl: Boolean;
  public
    property InImpl: Boolean read FInImpl write FInImpl;
  end;

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
  I: Integer;
  Info: TCnUsedUnitInfo;
begin
  FCurFile := CnOtaGetCurrentSourceFile;

  if FCurFile <> '' then
  begin
    if IsForm(FCurFile) then
    begin
      TmpName := _CnChangeFileExt(FCurFile, '.pas');
      if CnOtaIsFileOpen(TmpName) then
        FCurFile := TmpName
      else
      begin
        TmpName := _CnChangeFileExt(FCurFile, '.cpp');
        if CnOtaIsFileOpen(TmpName) then
          FCurFile := TmpName;
      end;
    end;

    Caption := Caption + ' - ' + FCurFile;
    Stream := TMemoryStream.Create;
    try
      CnOtaSaveCurrentEditorToStream(Stream, False);
      if IsDelphiSourceModule(FCurFile) then
      begin
        FIsPas := True;
        FIsDpr := IsDpr(FCurFile);
        ParseUnitUses(PAnsiChar(Stream.Memory), DataList);

        // ParseUnitUses 解析出的是否在 Implementation 部分的是个 Boolean，转成对象
        for I := 0 to DataList.Count - 1 do
        begin
          Info := TCnUsedUnitInfo.Create;
          Info.Text := DataList[I];

          if DataList.Objects[I] <> nil then
            Info.InImpl := True;

          DataList.Objects[I] := Info;
        end;
      end
      else if IsCppSourceModule(FCurFile) then
      begin
        // 解析 C 的 include
        FIsC := True;
        ParseUnitInclude(PChar(Stream.Memory), DataList);
        // 同样转成对象
        for I := 0 to DataList.Count - 1 do
        begin
          Info := TCnUsedUnitInfo.Create;
          Info.Text := DataList[I];
          DataList.Objects[I] := Info;
        end;
      end;
    finally
      Stream.Free;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogStrings(DataList, 'Used List.');
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
{$IFDEF SUPPORT_UNITNAME_DOT}
  Prefix: string;
  Prefixes: TStrings;
  PO: IOTAProjectOptions;
{$ENDIF}
begin
  Error := False;
  if lvList.SelCount > 0 then
  begin
    if (lvList.SelCount > 1) and actQuery.Checked then
      if not QueryDlg(SCnProjExtOpenUnitWarning, False, SCnInformation) then
        Exit;

{$IFDEF SUPPORT_UNITNAME_DOT}
    Prefixes := TStringList.Create;
    try
      PO := CnOtaGetActiveProjectOptions;
      if PO <> nil then
      begin
        Prefix := PO.Values['NamespacePrefix'];
        if Trim(Prefix) <> '' then
          ExtractStrings([';'], [' '], PChar(Prefix), Prefixes);
      end;
{$ENDIF}

      for I := 0 to lvList.Items.Count - 1 do
      begin
        if lvList.Items[I].Selected then
        begin
          if not TCnEditorOpenFile.SearchAndOpenFile(lvList.Items[I].Caption
            {$IFDEF SUPPORT_UNITNAME_DOT}, Prefixes {$ENDIF}) then
          begin
            Error := True;
            ErrorDlg(SCnEditorOpenFileNotFound);
          end;
        end;
      end;

{$IFDEF SUPPORT_UNITNAME_DOT}
    finally
      Prefixes.Free;
    end;
{$ENDIF}

    if not Error then
      ModalResult := mrOK;    
  end;
end;

procedure TCnProjectListUsedForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnProjExtUnitsFileCount, [DisplayList.Count]);
end;

procedure TCnProjectListUsedForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnUsedUnitInfo;
begin
  if (DisplayList <> nil) and (Item.Index >= 0) and
    (Item.Index < DisplayList.Count) then
  begin
    Item.Caption := DisplayList[Item.Index];
    Item.ImageIndex := 78; // Unit
    if FIsDpr then
      Item.SubItems.Add('project')
    else if FIsC then
      Item.SubItems.Add('include')
    else
    begin
      Info := TCnUsedUnitInfo(DisplayList.Objects[Item.Index]);
      if (Info = nil) or not Info.InImpl then
        Item.SubItems.Add('interface')
      else
        Item.SubItems.Add('implementation');
    end;
    Item.Data := DisplayList.Objects[Item.Index];
    RemoveListViewSubImages(Item);
  end;
end;

procedure TCnProjectListUsedForm.UpdateComboBox;
begin
// Do nothing for Combo Hidden.
end;

function TCnProjectListUsedForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
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
  I, J, QS, QE, BS, BE, Len: Integer;
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
        QS := 0; QE := 0; BS := 0; BE := 0;
        for J := 1 to Length(UsesList[I]) do
        begin
          case UsesList[I][J] of
          '"':
            begin
              if QS = 0 then
                QS := J
              else
                QE := J;
            end;
          '<':
            BS := J;
          '>':
            BE := J;
          end;
        end;

        if (BE > 0) and (BS > 0) and (BE > BS) then
          UsesList[I] := Copy(UsesList[I], BS + 1, BE - BS - 1)
        else if (QE > 0) and (QS > 0) and (QE > QS) then
          UsesList[I] := Copy(UsesList[I], QS + 1, QE - QS - 1);

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

function TCnProjectListUsedForm.CanMatchDataByIndex(
  const AMatchStr: string; AMatchMode: TCnMatchMode;
  DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean;
begin
  Result := False;
  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  case AMatchMode of // 搜索时只有名称参与匹配，不区分大小写
    mmStart:
      begin
        Result := Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) = 1;
      end;
    mmAnywhere:
      begin
        Result := Pos(UpperCase(AMatchStr), UpperCase(DataList[DataListIndex])) > 0;
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes);
      end;
  end;
end;

function TCnProjectListUsedForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
begin
  case ASortIndex of // 因为搜索时名称参与匹配，因此排序时也要考虑到把名称的全匹配提前
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, S1, S2, SortDown);
      end;
    1:
      begin
        Result := Integer(Obj1) - Integer(Obj2);
        if SortDown then
          Result := -Result;
      end;
  else
    Result := 0;
  end;
end;

procedure TCnProjectListUsedForm.DrawListPreParam(Item: TListItem;
  ListCanvas: TCanvas);
begin

end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
