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

unit CnSrcTemplate;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源代码模板专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串符合本地化处理方式
* 修改记录：2022.10.07 V1.1
*               加入给当前 Pascal 单元每个函数增加代码片段的功能，入口未开放
*           2005.08.22 V1.0
*               从 CnCodingToolsetWizard 中分离出来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IniFiles, ToolsAPI, Menus, OmniXML, OmniXMLPersistent,
  CnWizMultiLang, CnWizMacroUtils, CnWizClasses, CnConsts, CnWizConsts, CnWizUtils,
  CnWizManager {$IFDEF BDS}, CnEditControlWrapper {$ENDIF};

type

{ TCnEditorItem }

  TCnSrcTemplate = class;
  TCnEditorCollection = class;
  
  TCnEditorItem = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FCaption: string;
    FIconName: string;
    FContent: string;
    FHint: string;
    FInsertPos: TCnEditorInsertPos;
    FShortCut: TShortCut;
    FActionIndex: Integer;
    FSavePos: Boolean;
    FCollection: TCnEditorCollection;
    FForDelphi: Boolean;
    FForBcb: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Collection: TCnEditorCollection read FCollection;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property SavePos: Boolean read FSavePos write FSavePos;
    property InsertPos: TCnEditorInsertPos read FInsertPos write FInsertPos;
    property Caption: string read FCaption write FCaption;
    property Content: string read FContent write FContent;
    property Hint: string read FHint write FHint;
    property IconName: string read FIconName write FIconName;

    property ForDelphi: Boolean read FForDelphi write FForDelphi default {$IFDEF BDS} True {$ELSE} {$IFDEF DELPHI} True {$ELSE} False {$ENDIF} {$ENDIF};
    property ForBcb: Boolean read FForBcb write FForBcb default {$IFDEF BDS} True {$ELSE} {$IFDEF DELPHI} False {$ELSE} True {$ENDIF} {$ENDIF};
  end;

{ TCnEditorCollection }

  TCnEditorCollection = class(TCollection)
  private
    FWizard: TCnSrcTemplate;
    function GetItems(Index: Integer): TCnEditorItem;
    procedure SetItems(Index: Integer; const Value: TCnEditorItem);
  protected
    property Wizard: TCnSrcTemplate read FWizard;
  public
    constructor Create(AWizard: TCnSrcTemplate);
    function LoadFromFile(const FileName: string): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function Add: TCnEditorItem;
    property Items[Index: Integer]: TCnEditorItem read GetItems write SetItems; default;
  end;

{ TCnSrcTemplate }

  TCnSrcTemplate = class(TCnSubMenuWizard)
  private
    FConfigIndex: Integer;
    FInsertToProcIndex: Integer;
    FLastIndexRef: Integer;
    FBatchCode: string;
    FCollection: TCnEditorCollection;
    FExecuting: Boolean;

    procedure UpdateActions;
    procedure DoExecute(Editor: TCnEditorItem);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure LoadCollection;
    procedure SaveCollection;

    procedure InsertCodeToProc;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure AcquireSubActions; override;
    procedure Execute; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    property Collection: TCnEditorCollection read FCollection;
  end;

{ TCnSrcTemplateForm }

  TCnSrcTemplateForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    btnEdit: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnImport: TButton;
    btnExport: TButton;
    btnHelp: TButton;
    btnOK: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCreate(Sender: TObject);
  private
    FWizard: TCnSrcTemplate;
    FItemChanged: Boolean;
    procedure UpdateListViewItem(Index: Integer);
    procedure UpdateListView;
    procedure UpdateButtons;
  protected
    function GetHelpTopic: string; override;
  public
    property ItemChanged: Boolean read FItemChanged write FItemChanged;
    {* 条目是否改变过？供保存时使用}
  end;

const
  csEditorInsertPosDescs: array[TCnEditorInsertPos] of PString = (
    @SCnEIPCurrPos, @SCnEIPBOL, @SCnEIPEOL, @SCnEIPBOF, @SCnEIPEOF, @SCnEIPProcHead);

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}

implementation

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  mPasLex, CnSrcTemplateEditFrm, CnWizOptions, CnWizShortCut, CnCommon,
  CnWizMacroFrm, CnWizMacroText, CnWizCommentFrm;

{$R *.DFM}

{ TCnEditorItem }

procedure TCnEditorItem.Assign(Source: TPersistent);
begin
  if Source is TCnEditorItem then
  begin
    FEnabled := TCnEditorItem(Source).FEnabled;
    FIconName := TCnEditorItem(Source).FIconName;
    FContent := TCnEditorItem(Source).FContent;
    FShortCut := TCnEditorItem(Source).FShortCut;
    FCaption := TCnEditorItem(Source).FCaption;
    FSavePos := TCnEditorItem(Source).FSavePos;
    FHint := TCnEditorItem(Source).FHint;
    FInsertPos := TCnEditorItem(Source).FInsertPos;
  end
  else
    inherited Assign(Source);
end;

constructor TCnEditorItem.Create(Collection: TCollection);
begin
  Assert(Collection is TCnEditorCollection);
  inherited Create(Collection);
  FCollection := TCnEditorCollection(Collection);
  FEnabled := True;
  FInsertPos := ipCurrPos;
  FSavePos := False;
  FActionIndex := -1;
  FIconName := SCnSrcTemplateIconName;

{$IFDEF BDS}
  FForDelphi := True;
  FForBcb := True;
{$ELSE}
  {$IFDEF DELPHI}
  FForDelphi := True;
  {$ELSE}
  FForBcb := True;
  {$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.TraceObject(Self);
{$ENDIF}
end;

{ TCnEditorCollection }

function TCnEditorCollection.Add: TCnEditorItem;
begin
  Result := TCnEditorItem(inherited Add);
end;

constructor TCnEditorCollection.Create(AWizard: TCnSrcTemplate);
begin
  inherited Create(TCnEditorItem);
  FWizard := AWizard;
end;

function TCnEditorCollection.GetItems(Index: Integer): TCnEditorItem;
begin
  Result := TCnEditorItem(inherited Items[Index]);
end;

procedure TCnEditorCollection.SetItems(Index: Integer;
  const Value: TCnEditorItem);
begin
  inherited Items[Index] := Value;
end;

function TCnEditorCollection.LoadFromFile(const FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    if not FileExists(FileName) then
      Exit;

    TOmniXMLReader.LoadFromFile(Self, FileName);
    // 弥补 XML 读入字符串的时候 #13#10 变成 #10 的问题。LiuXiao
    for I := 0 to Count - 1 do
    begin
      Items[I].Content := StringReplace(Items[I].Content, #10, #13#10, [rfReplaceAll]);
      Items[I].Content := StringReplace(Items[I].Content, #13#13, #13, [rfReplaceAll]);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TCnEditorCollection.SaveToFile(const FileName: string): Boolean;
begin
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    Result := False;
  end;
end;

{ TCnSrcTemplate }

procedure TCnSrcTemplate.Config;
begin
  inherited;
  with TCnSrcTemplateForm.Create(nil) do
  try
    ShowModal;
    DoSaveSettings;
    if ItemChanged then
      SaveCollection;
  finally
    Free;
  end;

  UpdateActions;
end;

constructor TCnSrcTemplate.Create;
begin
  inherited;
  FCollection := TCnEditorCollection.Create(Self);
end;

destructor TCnSrcTemplate.Destroy;
begin
  FCollection.Free;
  inherited;
end;

procedure TCnSrcTemplate.DoExecute(Editor: TCnEditorItem);
var
  MacroText: TCnWizMacroText;
  Content: string;
  AIcon: TIcon;
  CursorPos: Integer;
begin
  if FExecuting then Exit;
  
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnSrcTemplate.DoExecute');
{$ENDIF}

  FExecuting := True;
  MacroText := TCnWizMacroText.Create(Editor.FContent);
  try
    if MacroText.Macros.Count > 0 then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogStrings(MacroText.Macros, 'UserMacros');
    {$ENDIF}
      if (Editor.FActionIndex >= 0) and not SubActions[Editor.FActionIndex].Icon.Empty then
        AIcon := SubActions[Editor.FActionIndex].Icon
      else
        AIcon := Icon;
      if not GetEditorMacroValue(MacroText.Macros, Editor.FCaption, AIcon) then
        Exit;
    end;
    CursorPos := 0;
    Content := MacroText.OutputText(CursorPos);
    EdtInsertTextToCurSource(Content, Editor.FInsertPos, Editor.FSavePos, CursorPos);
  finally
    MacroText.Free;
    FExecuting := False;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnSrcTemplate.DoExecute');
{$ENDIF}
end;

procedure TCnSrcTemplate.Execute;
begin

end;

function TCnSrcTemplate.GetCaption: string;
begin
  Result := SCnSrcTemplateMenuCaption;
end;

function TCnSrcTemplate.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnSrcTemplate.GetHint: string;
begin
  Result := SCnSrcTemplateMenuHint;
end;

function TCnSrcTemplate.GetState: TWizardState;
begin
  if Active then 
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnSrcTemplate.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnSrcTemplateName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnSrcTemplateComment;
end;

procedure TCnSrcTemplate.LanguageChanged(Sender: TObject);
begin
  inherited;
  LoadCollection;
  if Active then
    UpdateActions;
end;

procedure TCnSrcTemplate.LoadCollection;
begin
  if not FCollection.LoadFromFile(WizOptions.GetUserFileName(SCnSrcTemplateDataName,
    True, SCnSrcTemplateDataDefName)) then
    ErrorDlg(SCnSrcTemplateReadDataError);
end;

procedure TCnSrcTemplate.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  LoadCollection;
{$IFDEF DEBUG}
  CnDebugger.TraceCollection(FCollection);
{$ENDIF}
end;

procedure TCnSrcTemplate.SaveCollection;
begin
  if not FCollection.SaveToFile(WizOptions.GetUserFileName(SCnSrcTemplateDataName,
    False, SCnSrcTemplateDataDefName)) then
    ErrorDlg(SCnSrcTemplateWriteDataError);
  WizOptions.CheckUserFile(SCnSrcTemplateDataName, SCnSrcTemplateDataDefName);
end;

procedure TCnSrcTemplate.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnSrcTemplate.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnSrcTemplateDataName);
end;

procedure TCnSrcTemplate.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  inherited;
  if Index = FConfigIndex then
  begin
    Config;
  end
  else if Index = FInsertToProcIndex then
  begin
    InsertCodeToProc;
  end
  else
  begin
    for I := 0 to FCollection.Count - 1 do
      if FCollection[I].FEnabled and (FCollection[I].FActionIndex
        = Index) then
      begin
        DoExecute(FCollection[I]);
        Exit;
      end;
  end;
end;

procedure TCnSrcTemplate.SubActionUpdate(Index: Integer);
begin
  if Index > FConfigIndex then
  begin
    SubActions[Index].Enabled := Action.Enabled and CurrentIsSource;
    Exit;
  end;
  inherited;
end;

procedure TCnSrcTemplate.AcquireSubActions;
begin
  FConfigIndex := RegisterASubAction(SCnSrcTemplateConfigName,
    SCnSrcTemplateConfigCaption, 0, SCnSrcTemplateConfigHint,
    SCnSrcTemplateIconName);

  AddSepMenu;
  FInsertToProcIndex := RegisterASubAction(SCnSrcTemplateInsertToProcName,
    SCnSrcTemplateInsertToProcCaption, 0, SCnSrcTemplateInsertToProcHint);

  FLastIndexRef := FInsertToProcIndex;

  AddSepMenu;
  UpdateActions;
end;

procedure TCnSrcTemplate.UpdateActions;
var
  I: Integer;

  function ItemCanShow(Item: TCnEditorItem): Boolean;
  begin
    Result := False;
    if Item = nil then
      Exit;
    if not Item.Enabled then
      Exit;

{$IFDEF BDS}
   Result := Item.ForDelphi or Item.ForBcb;
{$ELSE}
  {$IFDEF DELPHI}
  Result := Item.ForDelphi;
  {$ELSE}
  Result := Item.ForBcb;
  {$ENDIF}
{$ENDIF}
  end;
begin
  if not Active then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    // 注意如果 Active 为 False，则 FLastIndexRef 可能为 0，会出错
    while SubActionCount > FLastIndexRef + 1 do
      DeleteSubAction(FLastIndexRef + 1);

    for I := 0 to FCollection.Count - 1 do
    begin
{$IFDEF DEBUG}
      CnDebugger.TraceObject(FCollection[I]);
{$ENDIF}
      if ItemCanShow(FCollection[I]) then
      begin
        with FCollection[I] do
        begin
          FActionIndex := RegisterASubAction(SCnSrcTemplateItem + IntToStr(I),
            FCaption, FShortCut, FHint, FIconName);
          SubActions[FActionIndex].ShortCut := FShortCut;
        end;
      end
      else
        FCollection[I].FActionIndex := -1;
    end;
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

function TCnSrcTemplate.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '宏,macro,template';
end;

procedure TCnSrcTemplate.InsertCodeToProc;
const
  PROC_NAME = '%ProcName%';
  DEF_CODE = '  CnDebugger.LogMsg(''%ProcName%'');';
var
  I, J: Integer;
  S, T, ProcName: string;
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  PasParser: TCnGeneralPasStructParser;
  CharPos: TOTACharPos;
  AfterToken, Token: TCnGeneralPasToken;
  ProcNames: TStringList;
  Lines, Cols: TList;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  if not IsDprOrPas(EditView.Buffer.FileName) and not IsInc(EditView.Buffer.FileName) then
  begin
    ErrorDlg(SCnSrcTemplateSourceTypeNotSupport);
    Exit;
  end;

  if FBatchCode = '' then
    FBatchCode := DEF_CODE;
  S := CnWizInputMultiLineBox(SCnInformation, SCnSrcTemplateInsertToProcPrompt, FBatchCode);
  if S = '' then
    Exit;

  FBatchCode := S;

  PasParser := nil;
  Stream := nil;
  ProcNames := nil;
  Lines := nil;
  Cols := nil;

  try
    PasParser := TCnGeneralPasStructParser.Create;
    Stream := TMemoryStream.Create;
    ProcNames := TStringList.Create;
    Lines := TList.Create;
    Cols := TList.Create;

{$IFDEF BDS}
    PasParser.UseTabKey := True;
    PasParser.TabWidth := EditControlWrapper.GetTabWidth;;
{$ENDIF}

    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

    // 解析当前显示的源文件
    CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName), False);
    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    // 找要插入的内容和位置
    for I := 0 to PasParser.Count - 1 do
    begin
      Token := PasParser.Tokens[I];
      if Token.IsMethodStart and (Token.TokenID <> tkBegin)then
      begin
        // 是 Procedure/Function 等
        ProcName := '';
        if I < PasParser.Count - 1 then
        begin
          J := 1;
          AfterToken := PasParser.Tokens[I + J];
          while AfterToken.TokenID in [tkIdentifier, tkPoint] do
          begin
            ProcName := ProcName + AfterToken.Token;
            Inc(J);
            if I + J >= PasParser.Count - 1 then
              Break;
            AfterToken := PasParser.Tokens[I + J];
          end;
        end;

        if ProcName = '' then // 匿名函数的情况
          ProcName := '<Unknown>';

        // ProceNames 不能超过 Lines
        if ProcNames.Count = Lines.Count then // 如果数量相等，则先加一
          ProcNames.Add(ProcName)
        else if ProcNames.Count > Lines.Count then
        begin
          if ProcNames.Count = 0 then
            ProcNames.Add(ProcName)
          else // 如果 ProcNames 大于 Lines 数量，说明出现 IFDEF 时多个 procedure 对应一个 begin end 的情形
            ProcNames[ProcNames.Count - 1] := ProcName;
            // 应将当前 ProcName 取代最后一个
        end;
        Continue;
      end;

      if Token.IsMethodStart and (Token.TokenID = tkBegin) then
      begin
        Lines.Add(Pointer(Token.LineNumber + 2)); // 加 2 是因为 0 开始且下一行
        Cols.Add(Pointer(Token.CharIndex));

        // Lines 数量此时应等于 ProcNames，如果大于，则 ProcNames 要重复最末个
        // 以备出现 IFDEF 时一个 procedure 对应多个 begin end 的情形
        if Lines.Count > ProcNames.Count then
          ProcNames.Add(ProcNames[ProcNames.Count - 1]);
        Continue;
      end;
    end;

    for I := Lines.Count - 1 downto 0 do
    begin
      T := StringReplace(S, PROC_NAME, ProcNames[I], [rfReplaceAll]);

      if Integer(Cols[I]) > 0 then      // 和 begin 的缩进相同
        T := Spc(Integer(Cols[I])) + T;

      // 把 T 插入 Token 所在的行的下一行
      CnOtaInsertSingleLine(Integer(Lines[I]), T);
    end;

    InfoDlg(Format(SCnSrcTemplateInsertToProcCountFmt, [Lines.Count]));
  finally
    Cols.Free;
    Lines.Free;
    ProcNames.Free;
    Stream.Free;
    PasParser.Free;
  end;
end;

{ TCnSrcTemplateForm }

procedure TCnSrcTemplateForm.FormCreate(Sender: TObject);
begin
  inherited;
  FWizard := TCnSrcTemplate(CnWizardMgr.WizardByClass(TCnSrcTemplate));
  Assert(Assigned(FWizard));
  EnlargeListViewColumns(ListView);
  UpdateListView;
end;

procedure TCnSrcTemplateForm.UpdateListViewItem(Index: Integer);
begin
  with ListView.Items[Index] do
  begin
    Caption := FWizard.FCollection[Index].FCaption;
    SubItems.Clear;
    if FWizard.FCollection[Index].FEnabled then
      SubItems.Add(SCnEnabled)
    else
      SubItems.Add(SCnDisabled);
    SubItems.Add(ShortCutToText(FWizard.FCollection[Index].FShortCut));
  end;
end;

procedure TCnSrcTemplateForm.UpdateListView;
var
  I: Integer;
begin
  ListView.Items.Clear;
  for I := 0 to FWizard.FCollection.Count - 1 do
  begin
    ListView.Items.Add;
    UpdateListViewItem(I);
  end;
  ListView.Selected := ListView.TopItem;
  UpdateButtons;
end;

procedure TCnSrcTemplateForm.UpdateButtons;
var
  HasSelected: Boolean;
begin
  HasSelected := Assigned(ListView.Selected);
  btnDelete.Enabled := HasSelected;
  btnClear.Enabled := ListView.Items.Count > 0;
  btnEdit.Enabled := HasSelected;
  btnUp.Enabled := HasSelected and (ListView.Selected.Index > 0);
  btnDown.Enabled := HasSelected and (ListView.Selected.Index < ListView.Items.Count - 1);
end;

procedure TCnSrcTemplateForm.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateButtons;
end;

procedure TCnSrcTemplateForm.btnAddClick(Sender: TObject);
var
  ACaption: string;
  AHint: string;
  AIconName: string;
  AShortCut: TShortCut;
  AInsertPos: TCnEditorInsertPos;
  AEnabled: Boolean;
  ASavePos: Boolean;
  AContent: string;
  AForDelphi: Boolean;
  AForBcb: Boolean;
begin
  ACaption := '';
  AHint := '';
  AIconName := '';
  AShortCut := 0;
  AInsertPos := ipCurrPos;
  AEnabled := True;
  ASavePos := False;
  AContent := '';

{$IFDEF BDS}
  AForDelphi := True;
  AForBcb := True;
{$ELSE}
  {$IFDEF DELPHI}
  AForDelphi := True;
  AForBcb := False;
  {$ELSE}
  AForDelphi := False;
  AForBcb := True;
  {$ENDIF}
{$ENDIF}
  if ShowEditorEditForm(ACaption, AHint, AIconName, AShortCut, AInsertPos,
    AEnabled, ASavePos, AContent, AForDelphi, AForBcb) then
    with FWizard.FCollection.Add do
    begin
      FCaption := ACaption;
      FHint := AHint;
      FIconName := AIconName;
      FShortCut := AShortCut;
      FInsertPos := AInsertPos;
      FEnabled := AEnabled;
      FSavePos := ASavePos;
      FContent := AContent;
      FForDelphi := AForDelphi;
      FForBcb := AForBcb;
      ListView.Items.Add;
      UpdateListViewItem(ListView.Items.Count - 1);
      ListView.Selected := ListView.Items[ListView.Items.Count - 1];
      FItemChanged := True;
    end;
end;

procedure TCnSrcTemplateForm.btnDeleteClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if not Assigned(Item) then Exit;
  if QueryDlg(SCnSrcTemplateWizardDelete) then
  begin
    FWizard.FCollection.Delete(Item.Index);
    Item.Free;
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnClearClick(Sender: TObject);
begin
  if QueryDlg(SCnSrcTemplateWizardClear) then
  begin
    ListView.Items.Clear;
    FWizard.FCollection.Clear;
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnEditClick(Sender: TObject);
begin
  if not Assigned(ListView.Selected) then Exit;
  if ShowEditorEditForm(FWizard.FCollection[ListView.Selected.Index]) then
  begin
    UpdateListViewItem(ListView.Selected.Index);
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnUpClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if Assigned(Item) and (Item.Index > 0) then
  begin
    FWizard.FCollection[Item.Index].Index := Item.Index - 1;
    UpdateListViewItem(Item.Index - 1);
    UpdateListViewItem(Item.Index);
    ListView.Selected := ListView.Items[Item.Index - 1];
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnDownClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ListView.Selected;
  if Assigned(Item) and (Item.Index < ListView.Items.Count - 1) then
  begin
    FWizard.FCollection[Item.Index].Index := Item.Index + 1;
    UpdateListViewItem(Item.Index + 1);
    UpdateListViewItem(Item.Index);
    ListView.Selected := ListView.Items[Item.Index + 1];
    UpdateButtons;
    FItemChanged := True;
  end;
end;

procedure TCnSrcTemplateForm.btnImportClick(Sender: TObject);
var
  EditorCollection: TCnEditorCollection;
begin
  if OpenDialog.FileName = '' then
    OpenDialog.FileName := WizOptions.GetUserFileName(SCnSrcTemplateDataName,
      True, SCnSrcTemplateDataDefName);
  if OpenDialog.Execute then
  begin
    EditorCollection := TCnEditorCollection.Create(nil);
    try
      if EditorCollection.LoadFromFile(OpenDialog.FileName) then
      begin
        if QueryDlg(SCnSrcTemplateImportAppend) then
        begin
          while EditorCollection.Count > 0 do
          begin
            FWizard.FCollection.Add.Assign(EditorCollection.Items[0]);
            EditorCollection.Delete(0);
          end;
        end
        else
        begin
          FWizard.FCollection.Assign(EditorCollection);
        end;
        UpdateListView;
        FItemChanged := True;
      end
      else
        ErrorDlg(SCnSrcTemplateReadDataError);
    finally
      EditorCollection.Free;
    end;
  end;
end;

procedure TCnSrcTemplateForm.btnExportClick(Sender: TObject);
begin
  if SaveDialog.FileName = '' then
    SaveDialog.FileName := WizOptions.GetUserFileName(SCnSrcTemplateDataName,
      False, SCnSrcTemplateDataDefName);
  if SaveDialog.Execute then
  begin
    if not FWizard.FCollection.SaveToFile(SaveDialog.FileName) then
      ErrorDlg(SCnSrcTemplateWriteDataError);
  end;
end;

procedure TCnSrcTemplateForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcTemplateForm.GetHelpTopic: string;
begin
  Result := 'CnSrcTemplate';
end;

initialization
  RegisterCnWizard(TCnSrcTemplate); // 注册专家

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}
end.
