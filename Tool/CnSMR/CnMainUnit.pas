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

unit CnMainUnit;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：文件关系分析的主窗体实现单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2007.08.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DELPHI7_UP}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Menus, IniFiles, ActnList,
  CnLangMgr, CnClasses, CnLangStorage, CnHashLangStorage, CnWizLangID, CnWideCtrls;

type

{$I WideCtrls.inc}

  TGetOpenedFilesProc = procedure (Sender: TObject; Files: TStrings; AllFiles: Boolean);
  TGetOpenedFilesProcObject = procedure (Files: TStrings; AllFiles: Boolean) of object;
  TPrevNextProc = procedure (const s: string) of object;
  TStringMatchFunc = function (const Mask, s: string): Boolean;

  TAppFileType = (aftARF, aftSMR);
  
  TMessageList = array of TMessage;

  TCnSMRMainForm = class(TForm)
    pgcMain: TPageControl;
    hfs1: TCnHashLangFileStorage;
    lm1: TCnLangManager;
    actlst1: TActionList;
    actHelp: TAction;
    procedure FormResize(Sender: TObject);
    procedure DoUpdateAlign(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  private
    { Private declarations }

    function GetTabSheet(P: TObject): TTabSheet;

    procedure NewForm(FormClass: TFormClass);
    procedure SortTabs;
  protected
    procedure DoCreate; override;
    procedure TranslateStrings;
  public
    { Public declarations }
    procedure GetMessageResults(const Message: TMessage; var Results: TMessageList);
  end;

  IUIInitializable = interface
    ['{2ED5E50B-DFB9-49B8-8B4A-0FF5B0990A45}']
    procedure UIInitialize;
  end;

const
  CM_GETFORMINDEX = WM_USER + 200;
  CM_GETOPENEDFILES = WM_USER + 201;
  ciMaxPrevNext: Integer = 1024;
  ciMaxFileList: Integer = 10;

var
  CnSMRMainForm: TCnSMRMainForm;

  // 需要本地化的字符串
  SCnAboutCaption: string = 'About';
  SCnIDEAbout: string = 'CnPack IDE Wizards - Source file / affected Modules Relation Analyzer' + #13#10#13#10 +
    'Author:' + #13#10 +
    'Chinbo (Shenloqi)  chinbo@eyou.com' + #13#10 +
    'LiuXiao (LiuXiao)  (master@cnpack.org)' + #13#10#13#10 +
    'Copyright (C) 2001-2024 CnPack Team';

  SCnAnalyzedResultsSaved: string = 'Analyzed Results Saved Successed to File %s.';
  SCnDuplicatedNameFound: string = 'Can NOT Save analyzed result: Duplicated File Names Found:'#13#10#13#10'%s';
  SCnSomeAnalyzedFailed: string = 'All Files Analyzed, but Some Files Analyzed Failed:'#13#10;

  SCnClickHintARFFmt: string = 'Please Click "%s" to Open an Analyzed Result File.';
  SCnClickHintSMRFmt: string = 'Please Click "%s" to Open an Source Module Relation File.';
  SCnBrowseHintARFFmt: string = 'Browsing Analyzed Results of "%s"';
  SCnBrowseHintSMRFmt: string = 'Browsing Source Module Relation of "%s"';
  
  SCnSelectTargetPath: string = 'Please Select Target Directory';
  SCnNoMatchedResultAll: string = 'No Matched Directories/files.';
  SCnNoMatchedResultDir: string = 'No Matched Directories.';
  SCnNoMatchedResultFile: string = 'No Matched Files.';
  SCnSuccessedSaveToFile: string = 'Successed Save to File %s.';
  SCnNameDuplicatedFiles: string = 'Name Duplicated Files';

function AppPath: string;
function DefaultMatchProc(const Mask, s: string): Boolean;
function GetButtonCaption(btn: TButton; IncludeAmpSign: Boolean = False): string;
//function GetControlRectInGridPanel(ctrl: TControl; gp: TPanel): TRect;
function GetRectCenter(rect: TRect): TPoint;
function GetSearchMask(const s: string): string;
function lsbFindKey(lsb: TListBox; s: string; SearchNext, SkipCurrent: Boolean; MatchProc: TStringMatchFunc): Boolean;
function lsbItemUnderCursor(lsb: TListBox): Integer;
procedure BuildPopupMenu(pm: TPopupMenu; ss: TStrings; ClickEvent: TNotifyEvent);
procedure lsbAddHorizontalScrollBar(lsb: TListBox);
procedure lsbDeleteSelected(lsb: TListBox; cb: TNotifyEvent);
procedure lsbProcessSearchKeyDown(lsb: TListBox; const Mask: string; var Key: Word; Shift: TShiftState);
procedure RegisterFormClass(FormClass: TFormClass; idx: Integer = -1);
procedure SetDlgInitialDir(c: TComponent);
procedure SyncListBoxWithStrings(ss: TStrings; lsb: TListBox);
procedure SyncMemoWithStrings(ss: TStrings; mmo: TMemo);
procedure UpdateChildrenAlign(ctrl: TControl);
procedure WrapButtonsCaption(ParentControl: TWinControl);

implementation

uses
  CnCommon, CnBaseUtils, CnWizHelp;

{$R *.dfm}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

function AppPath: string;
begin
  Result := _CnExtractFilePath(ParamStr(0));
end;

var
  FormClassList: TList;

procedure RegisterFormClass(FormClass: TFormClass; idx: Integer = -1);
begin
  if not Assigned(FormClass) then
  begin
    Exit;
  end;

  if not Assigned(FormClassList) then
  begin
    FormClassList := TList.Create;
  end;

  if FormClassList.IndexOf(FormClass) < 0 then
  begin
    if idx < 0 then
    begin
      idx := MaxInt;
    end;
    if idx > FormClassList.Count then
    begin
      FormClassList.Add(FormClass);
    end
    else
    begin
      FormClassList.Insert(idx, FormClass);
    end;
  end;
end;

function lsbItemUnderCursor(lsb: TListBox): Integer;
var
  Pos: TPoint;
begin
  Result := -1;
  if not Assigned(lsb) then
  begin
    Exit;
  end;

  GetCursorPos(Pos);
  Pos := lsb.ScreenToClient(Pos);
  Result := lsb.ItemAtPos(Pos, True);
end;

function GetButtonCaption(btn: TButton; IncludeAmpSign: Boolean = False): string;
begin
  Result := '';
  if not Assigned(btn) then
  begin
    Exit;
  end;

  Result := StringReplace(btn.Caption, #13#10, ' ', [rfReplaceAll]);
  if not IncludeAmpSign then
  begin
    Result := StringReplace(Result, '&', '', [rfReplaceAll]);
  end;
end;

procedure WrapButtonsCaption(ParentControl: TWinControl);
var
  i: Integer;
begin
  for i := 0 to ParentControl.ControlCount - 1 do
  begin
    if ParentControl.Controls[i] is TButton then
    begin
      with TButton(ParentControl.Controls[i]) do
      begin
        Caption := StringReplace(Caption, ' ', #13#10, [rfReplaceAll]);
      end;
    end;
  end;
end;

procedure lsbAddHorizontalScrollBar(lsb: TListBox);
var
  i, iWidth, MaxWidth: Integer;
begin
  if Assigned(lsb) then
  begin
    with lsb do
    begin
      MaxWidth := 0;
      for i := 0 to Items.Count - 1 do
      begin
        iWidth := Canvas.TextWidth(Items[i]);
        if MaxWidth < iWidth then
          MaxWidth := iWidth;
      end;
      SendMessage(Handle, LB_SETHORIZONTALEXTENT, MaxWidth + 30, 0);
    end;
  end;
end;

procedure lsbDeleteSelected(lsb: TListBox; cb: TNotifyEvent);
var
  i: Integer;
begin
  if Assigned(cb) then
  begin
    cb(lsb);
  end;

  if lsb.MultiSelect then
  begin
    for I := lsb.Items.Count - 1 downto 0 do
      if lsb.Selected[I] then
        lsb.Items.Delete(I);
  end
  else
    if lsb.ItemIndex <> -1 then
      lsb.Items.Delete(lsb.ItemIndex);

  i := lsb.ItemIndex;
  if i > lsb.Items.Count - 1 then
  begin
    i := lsb.Items.Count - 1;
  end;
  if i < 0 then
  begin
    Exit;
  end;
  if lsb.MultiSelect then
  begin
    lsb.Selected[i] := True;
  end
  else
  begin
    lsb.ItemIndex := i;
  end;
end;

procedure SyncMemoWithStrings(ss: TStrings; mmo: TMemo);
begin
  if not Assigned(mmo) then
  begin
    Exit;
  end;

  if not Assigned(ss) then
  begin
    mmo.Clear;
  end
  else
  begin
    mmo.Lines.Assign(ss);
  end;
end;

procedure SyncListBoxWithStrings(ss: TStrings; lsb: TListBox);
var
  idx: Integer;
begin
  if not Assigned(lsb) then
  begin
    Exit;
  end;

  idx := lsb.ItemIndex;
  if not Assigned(ss) then
  begin
    lsb.Clear;
  end
  else
  begin
    lsb.Items.Assign(ss);
    lsbAddHorizontalScrollBar(lsb);
  end;
  lsb.ItemIndex := idx;
end;

procedure UpdateChildrenAlign(ctrl: TControl);
var
  i: Integer;
begin
  if ctrl is TWinControl then
  begin
    TWinControl(ctrl).Realign;

    for i := 0 to TWinControl(ctrl).ControlCount - 1 do
    begin
      if TWinControl(ctrl).Controls[i] is TWinControl then
      begin
        TWinControl(TWinControl(ctrl).Controls[i]).Realign;
        UpdateChildrenAlign(TWinControl(ctrl).Controls[i]);
      end;
    end;
  end;
end;

procedure BuildPopupMenu(pm: TPopupMenu; ss: TStrings; ClickEvent: TNotifyEvent);
var
  i: Integer;
  mi: TMenuItem;
begin
  if not (Assigned(pm) and Assigned(ss)) then
  begin
    Exit;
  end;

  for i := 0 to ss.Count - 1 do
  begin
    mi := TMenuItem.Create(pm);
    mi.Caption := ss[i];
    mi.OnClick := ClickEvent;
    pm.Items.Add(mi);
  end;
end;

function GetRectCenter(rect: TRect): TPoint;
begin
  Result := Point((rect.Left + rect.Right + 1) div 2, (rect.Top + rect.Bottom + 1) div 2);
end;

//function GetControlRectInGridPanel(ctrl: TControl; gp: TPanel): TRect;
//var
//  i, j: Integer;
//begin
//  Result := Rect(0, 0, 0, 0);
//  if not (Assigned(ctrl) and Assigned(gp)) then
//  begin
//    Exit;
//  end;
//
//  for i := 0 to gp.RowCollection.Count - 1 do
//  begin
//    for j := 0 to gp.ColumnCollection.Count - 1 do
//    begin
//      if gp.ControlCollection.ControlItems[j, i].Control = ctrl then
//      begin
//        Result := gp.CellRect[j, i];
//        Break;
//      end;
//    end;
//  end;
//end;

function DefaultMatchProc(const Mask, s: string): Boolean;
begin
  Result := MatchFileName(Mask, AnsiUpperCase(_CnExtractFileName(s)));
end;

function lsbFindKey(lsb: TListBox; s: string; SearchNext, SkipCurrent: Boolean; MatchProc: TStringMatchFunc): Boolean;
var
  i: Integer;
begin
  Result := False;
  if not (Assigned(lsb) and (s <> '') and Assigned(MatchProc)) then
  begin
    Exit;
  end;

  s := AnsiUpperCase(s);
  i := lsb.ItemIndex;
  try
    if SearchNext then
    begin
      if SkipCurrent then
      begin
        Inc(i);
      end;

      if i < 0 then
      begin
        i := 0;
      end;

      while i < lsb.Items.Count do
      begin
        if MatchProc(s, lsb.Items[i]) then
        begin
          Result := True;
          Break;
        end;
        Inc(i);
      end;
    end
    else
    begin
      if SkipCurrent then
      begin
        Dec(i);
      end;

      if i >= lsb.Items.Count then
      begin
        i := lsb.Items.Count - 1;
      end;

      while i >= 0 do
      begin
        if MatchProc(s, lsb.Items[i]) then
        begin
          Result := True;
          Break;
        end;
        Dec(i);
      end;
    end;
  finally
    if Result then
    begin
      lsb.ItemIndex := i;
    end;
    lsb.Items.EndUpdate;
  end;
end;

function GetSearchMask(const s: string): string;
begin
  Result := AnsiUpperCase(Trim(s));
  if Result <> '' then
  begin
    if Pos('.', Result) = 0 then
    begin
      Result := '*' + Result + '*.*';
    end
    else
    begin
      Result := '*' + Result;
    end;
  end;
end;

procedure lsbProcessSearchKeyDown(lsb: TListBox; const Mask: string;
  var Key: Word; Shift: TShiftState);
var
  OldItemIndex: Integer;
begin
  if not Assigned(lsb) then
  begin
    Exit;
  end;

  OldItemIndex := lsb.ItemIndex;
  case Key of
    VK_UP: begin
      if [ssCtrl] = Shift then
      begin
        lsbFindKey(lsb, Mask, False, True, DefaultMatchProc);
      end
      else
      begin
        lsb.ItemIndex := lsb.ItemIndex - 1;
      end;
      Key := 0;
    end;
    VK_DOWN: begin
      if [ssCtrl] = Shift then
      begin
        lsbFindKey(lsb, Mask, True, True, DefaultMatchProc);
      end
      else
      begin
        lsb.ItemIndex := lsb.ItemIndex + 1;
      end;
      Key := 0;
    end;
    VK_HOME: begin
      if [ssCtrl] = Shift then
      begin
        lsb.ItemIndex := 0;
        Key := 0;
      end;
    end;
    VK_END: begin
      if [ssCtrl] = Shift then
      begin
        lsb.ItemIndex := lsb.Items.Count - 1;
        Key := 0;
      end;
    end;
  end;

  if (lsb.ItemIndex <> OldItemIndex) and Assigned(lsb.OnClick) then
  begin
    lsb.OnClick(lsb);
  end;
end;

procedure SetDlgInitialDir(c: TComponent);
var
  i: Integer;
begin
  if not Assigned(c) then
  begin
    Exit;
  end;

  for i := 0 to c.ComponentCount - 1 do
  begin
    if c.Components[i] is TOpenDialog then
    begin
      TOpenDialog(c.Components[i]).InitialDir := AppPath;
    end;
  end;
end;

procedure TCnSMRMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FormClassList.Count - 1 do
  begin
    if Assigned(FormClassList[i]) then
    begin
      NewForm(TFormClass(FormClassList[i]));
    end;
  end;
  SortTabs;
  if pgcMain.PageCount > 0 then
  begin
    pgcMain.ActivePageIndex := 0;
  end;
  Application.Title := Self.Caption;
end;

procedure TCnSMRMainForm.FormResize(Sender: TObject);
begin
  UpdateChildrenAlign(Self);
end;

procedure TCnSMRMainForm.GetMessageResults(const Message: TMessage; var Results: TMessageList);
var
  i: Integer;
  Msg: TMessage;
begin
  SetLength(Results, 0);
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TForm then
    begin
      Msg := Message;
      Msg.LParam := Integer(Pointer(Components[i]));
      TControl(Components[i]).WindowProc(Msg);
      if Msg.Result <> 0 then
      begin
        SetLength(Results, Length(Results) + 1);
        Results[High(Results)] := Msg;
      end;
    end;
  end;
end;

function TCnSMRMainForm.GetTabSheet(P: TObject): TTabSheet;
begin
  Result := nil;
  if (P is TForm) and (TForm(P).Parent is TTabSheet) then
  begin
    Result := TTabSheet(TForm(P).Parent);
  end;
end;

procedure TCnSMRMainForm.NewForm(FormClass: TFormClass);
var
  F: TForm;
  Ts: TTabSheet;
  IUIInitialize: IUIInitializable;
begin
  F := FormClass.Create(Self);
  CnLanguageManager.TranslateForm(F); // 在此翻译!
  if Supports(F, IUIInitializable, IUIInitialize) then
    IUIInitialize.UIInitialize;

  Ts := TTabSheet.Create(Self);
  with ts do
  begin
    Caption := F.Caption;
    PageControl := pgcMain;
//    AlignWithMargins := True;
  end;

  with F do
  begin
    BorderStyle := bsNone;
    Parent := Ts;
    Align := alClient;
    Visible := True;
  end;
end;

procedure TCnSMRMainForm.SortTabs;
var
  i: Integer;
  Msg: TMessage;
  Results: TMessageList;
  tsh: TTabSheet;
begin
  Msg.Msg := CM_GETFORMINDEX;
  Msg.Result := 0;
  GetMessageResults(Msg, Results);
  for i := Low(Results) to High(Results) do
  begin
    tsh := GetTabSheet(Pointer(Results[i].LParam));
    if Assigned(tsh) then
    try
      tsh.PageIndex := Results[i].Result - 1;
    except
      ;
    end;
  end;
end;

procedure TCnSMRMainForm.DoUpdateAlign(Sender: TObject);
begin
  UpdateChildrenAlign(pgcMain.ActivePage);
end;

procedure TCnSMRMainForm.DoCreate;
const
  csLangDir = 'Lang\';
var
  LangID: DWORD;
  I: Integer;
begin
  if CnLanguageManager <> nil then
  begin
    hfs1.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    LangID := GetWizardsLanguageID;
    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        Break;
      end;
    end;
  end;
  inherited;
end;

procedure TCnSMRMainForm.TranslateStrings;
begin
  TranslateStr(SCnAboutCaption, 'SCnAboutCaption');
  TranslateStr(SCnIDEAbout, 'SCnIDEAbout');

  TranslateStr(SCnAnalyzedResultsSaved, 'SCnAnalyzedResultsSaved');
  TranslateStr(SCnDuplicatedNameFound, 'SCnDuplicatedNameFound');
  TranslateStr(SCnSomeAnalyzedFailed, 'SCnSomeAnalyzedFailed');

  TranslateStr(SCnClickHintARFFmt, 'SCnClickHintARFFmt');
  TranslateStr(SCnClickHintSMRFmt, 'SCnClickHintSMRFmt');
  TranslateStr(SCnBrowseHintARFFmt, 'SCnBrowseHintARFFmt');
  TranslateStr(SCnBrowseHintSMRFmt, 'SCnBrowseHintSMRFmt');
 
  TranslateStr(SCnSelectTargetPath, 'SCnSelectTargetPath');
  TranslateStr(SCnNoMatchedResultAll, 'SCnNoMatchedResultAll');
  TranslateStr(SCnNoMatchedResultDir, 'SCnNoMatchedResultDir');
  TranslateStr(SCnNoMatchedResultFile, 'SCnNoMatchedResultFile');
  TranslateStr(SCnSuccessedSaveToFile, 'SCnSuccessedSaveToFile');
  TranslateStr(SCnNameDuplicatedFiles, 'SCnNameDuplicatedFiles');
end;

procedure TCnSMRMainForm.actHelpExecute(Sender: TObject);
begin
  ShowHelp('CnSMR', 'CnSMR');
end;

initialization

finalization
  if Assigned(FormClassList) then
  begin
    FormClassList.Free;
  end;

end.
