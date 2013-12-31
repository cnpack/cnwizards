{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnLocalHistoryWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：本地历史备份专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DiffUnit, ExtCtrls, DiffControl, Menus, ComCtrls, ShellAPI,
  IniFiles, CnCRC32, CnWizUtils, Buttons, ToolWin, ActnList, ImgList,
  CnWizMultiLang, CnIni, CnWizConsts, ToolsAPI, CnWizEditFiler, CnCommon,
  CnBaseWizard, CnConsts, CnWizEdtTabSetHook, CnWizEdtTabSetFrm;

type
  TCnLocalHistoryWizard = class;

{ TCnLocalHistoryForm }

  TCnLocalHistoryForm = class(TCnWizEdtTabSetForm)
    actAddColor: TAction;
    actCompare: TAction;
    actDelColor: TAction;
    actFont: TAction;
    actGoto: TAction;
    actHelp: TAction;
    actIgnoreBlanks: TAction;
    actIgnoreCase: TAction;
    ActionList: TActionList;
    actModColor: TAction;
    actNextDiff: TAction;
    actPrioDiff: TAction;
    actShowDiffOnly: TAction;
    actSplitHorizontally: TAction;
    ColorDialog: TColorDialog;
    FontDialog: TFontDialog;
    lvLeft: TListView;
    lvRight: TListView;
    Panel1: TPanel;
    pbFile: TPaintBox;
    pbPos: TPaintBox;
    pnlDisplay: TPanel;
    pnlLeft: TPanel;
    pnlMain: TPanel;
    pnlRight: TPanel;
    pnlVersion: TPanel;
    splFiles: TSplitter;
    splMain: TSplitter;
    splVersion: TSplitter;
    StatusBar1: TStatusBar;
    tbCompare: TToolButton;
    tbFont: TToolButton;
    tbGoto: TToolButton;
    tbHelp: TToolButton;
    tbNextDiff: TToolButton;
    tbPrioDiff: TToolButton;
    tbSplitHorizontally: TToolButton;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton11: TToolButton;
    ToolButton4: TToolButton;
    procedure actAddColorExecute(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure actDelColorExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure actGotoExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actIgnoreBlanksExecute(Sender: TObject);
    procedure actIgnoreCaseExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actModColorExecute(Sender: TObject);
    procedure actNextDiffExecute(Sender: TObject);
    procedure actPrioDiffExecute(Sender: TObject);
    procedure actShowDiffOnlyExecute(Sender: TObject);
    procedure actSplitHorizontallyExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbFileMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbFilePaint(Sender: TObject);
    procedure pbPosPaint(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure StatusBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    Diff: TDiff;
    DiffControl1: TDiffControl;
    DiffControl2: TDiffControl;
    DiffControlMerge: TDiffControl;
    FFilesCompared: Boolean;
    FileBmp: TBitmap;
    FSourceName: string;
    FWizard: TCnLocalHistoryWizard;
    Lines1, Lines2: TStrings;
    procedure DiffCtrlDblClick(Sender: TObject);
    procedure DiffCtrlMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DiffProgress(Sender: TObject; percent: Integer);
    procedure DisplayDiffs;
    procedure DoOpenFile(const FileName: string; InEditor: Boolean; OpenFile1: 
      Boolean);
    procedure RepaintControls;
    procedure SetFilesCompared(const Value: Boolean);
    procedure SetSourceName(const Value: string);
    procedure SetSplitHorizontally(SplitHorizontally: Boolean);
    procedure SyncScroll(Sender: TObject);
    procedure UpdateFileBmp;
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function GetHelpTopic: string; override;
  public
    procedure DoTabHide; override;
    procedure DoTabShow(Editor: IOTASourceEditor; View: IOTAEditView); override;
    function GetTabCaption: string; override;
    function IsTabVisible(Editor: IOTASourceEditor; View: IOTAEditView): Boolean;
      override;
    property FilesCompared: Boolean read FFilesCompared write SetFilesCompared;
    property SourceName: string read FSourceName write SetSourceName;
    property Wizard: TCnLocalHistoryWizard read FWizard;
  end;

//==============================================================================
// 本地历史备份专家类
//==============================================================================

{ TCnLocalHistoryWizard }

  TCnLocalHistoryWizard = class(TCnIDEEnhanceWizard)
  private
    FAddColor: TColor;
    FDelColor: TColor;
    FFont: TFont;
    FHorizontal: Boolean;
    FIgnoreBlanks: Boolean;
    FIgnoreCase: Boolean;
    FList: TList;
    FModColor: TColor;
    FShowDiffOnly: Boolean;
    procedure SetAddColor(const Value: TColor);
    procedure SetDelColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetHorizontal(const Value: Boolean);
    procedure SetIgnoreBlanks(const Value: Boolean);
    procedure SetIgnoreCase(const Value: Boolean);
    procedure SetModColor(const Value: TColor);
    procedure SetShowDiffOnly(const Value: Boolean);
    procedure UpdateForms;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    property AddColor: TColor read FAddColor write SetAddColor;
    property DelColor: TColor read FDelColor write SetDelColor;
    property Font: TFont read FFont write SetFont;
    property Horizontal: Boolean read FHorizontal write SetHorizontal;
    property IgnoreBlanks: Boolean read FIgnoreBlanks write SetIgnoreBlanks;
    property IgnoreCase: Boolean read FIgnoreCase write SetIgnoreCase;
    property ModColor: TColor read FModColor write SetModColor;
    property ShowDiffOnly: Boolean read FShowDiffOnly write SetShowDiffOnly;
  end;

const
  colorAdd = 1;
  colorMod = 2;
  colorDel = 3;

implementation

uses CnWizShareImages;

const
  SLocalHistoryTabCaption = 'History';

{$R *.DFM}

function HashLine(const Line: string; IgnoreCase, IgnoreBlanks: Boolean): Pointer;
var
  i, j, Len: Integer;
  s: string;
begin
  s := Line;
  if IgnoreBlanks then
  begin
    i := 1;
    j := 1;
    Len := Length(Line);
    while i <= Len do
    begin
      if not (Line[i] in [#9, #32]) then
      begin
        s[j] := Line[i];
        Inc(j);
      end;
      Inc(i);
    end;
    SetLength(s, j - 1);
  end;
  if IgnoreCase then s := AnsiLowerCase(s);
  //return result as a pointer to save typecasting later...
  Result := Pointer(CRC32Calc(0, PChar(s)^, Length(s)));
end;

//==============================================================================
// 源代码比较窗体
//==============================================================================

const
  csFont = 'Font';
  csAddColor = 'AddColor';
  csModColor = 'ModColor';
  csDelColor = 'DelColor';
  csHorizontal = 'Horizontal';
  csIgnoreBlanks = 'IgnoreBlanks';
  csIgnoreCase = 'IgnoreCase';
  csShowDiffOnly = 'ShowDiffOnly';
  
procedure TCnLocalHistoryForm.actAddColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorAdd];
    if not Execute then Exit;
    DiffControl1.LineColors[colorAdd] := Color;
    DiffControl2.LineColors[colorAdd] := Color;
    DiffControlMerge.LineColors[colorAdd] := Color;
  end;
  RepaintControls;
end;

procedure TCnLocalHistoryForm.actCompareExecute(Sender: TObject);
var
  i: Integer;
  HashList1, HashList2: TList;
  optionsStr: string;
begin
  FilesCompared := False;
  if (Lines1.Count = 0) or (Lines2.Count = 0) then Exit;

  if actIgnoreCase.Checked then
    optionsStr := SCnSourceDiffCaseIgnored;
  if actIgnoreBlanks.Checked then
    if optionsStr = '' then
      optionsStr := SCnSourceDiffBlanksIgnored else
      optionsStr := optionsStr + ', ' + SCnSourceDiffBlanksIgnored;
  if optionsStr <> '' then
    optionsStr := '  (' + optionsStr + ')';

  HashList1 := TList.Create;
  HashList2 := TList.Create;
  try
    //create the hash lists to compare...
    HashList1.capacity := Lines1.Count;
    HashList2.capacity := Lines2.Count;
    for i := 0 to Lines1.Count - 1 do
      HashList1.Add(HashLine(Lines1[i], actIgnoreCase.Checked,
        actIgnoreBlanks.Checked));
    for i := 0 to Lines2.Count - 1 do
      HashList2.Add(HashLine(Lines2[i], actIgnoreCase.Checked,
        actIgnoreBlanks.Checked));

    screen.cursor := crHourglass;
    try
      if not Diff.Execute(PIntArray(HashList1.List), PIntArray(HashList2.List),
        HashList1.Count, HashList2.Count) then Exit;
      FilesCompared := True;
      DisplayDiffs;
    finally
      screen.cursor := crDefault;
    end;
    Statusbar1.Panels[3].Text := Format(SCnSourceDiffChanges, [Diff.ChangeCount,
      optionsStr]);
  finally
    HashList1.Free;
    HashList2.Free;
  end;
end;

procedure TCnLocalHistoryForm.actDelColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorDel];
    if not Execute then Exit;
    DiffControl1.LineColors[colorDel] := Color;
    DiffControl2.LineColors[colorDel] := Color;
    DiffControlMerge.LineColors[colorDel] := Color;
  end;
  RepaintControls;
end;

procedure TCnLocalHistoryForm.actFontExecute(Sender: TObject);
begin
  FontDialog.Font := DiffControl1.Font;
  if not FontDialog.Execute then Exit;
  DiffControl1.Font := FontDialog.Font;
  DiffControl2.Font := FontDialog.Font;
  DiffControlMerge.Font := FontDialog.Font;
end;

procedure TCnLocalHistoryForm.actGotoExecute(Sender: TObject);

  procedure GotoSourceEditor(DiffControl: TDiffControl; const FileName: string);
  var
    P: TPoint;
    i, y: Integer;
  begin
    GetCursorPos(P);
    P := DiffControl.ScreenToClient(P);
    P := DiffControl.ClientPtToTextPoint(P);
    i := P.y;

    if FilesCompared then
    begin
      // 向前查找有效的行号
      if DiffControl.Lines.LineNum[i] = 0 then
        while (i > 0) and (DiffControl.Lines.LineNum[i] = 0) do
        Dec(i);

      // 向后查找有效的行号
      if DiffControl.Lines.LineNum[i] = 0 then
      begin
        i := P.y;
        while (i < DiffControl.Lines.Count - 1) and
         (DiffControl.Lines.LineNum[i] = 0) do
         Inc(i);
      end;

      // 在编辑器中打开
      if DiffControl.Lines.LineNum[i] > 0 then
        y := DiffControl.Lines.LineNum[i]
      else
        y := 0;
    end
    else
      y := P.y;

    CnOtaMakeSourceVisible(FileName, y);
    Close;
  end;
begin
  // todo: 
  {if ActiveControl = DiffControl1 then
  begin
    //GotoSourceEditor(DiffControl1, FileName1);
  end
  else if (ActiveControl = DiffControl2) and (FileName2 <> '') then
  begin
    if FileKind1 = fkBakFile then
      GotoSourceEditor(DiffControl2, GetBakFileName(FileName2))
    else
      GotoSourceEditor(DiffControl2, FileName2);
  end;}
end;

procedure TCnLocalHistoryForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnLocalHistoryForm.actIgnoreBlanksExecute(Sender: TObject);
begin
  actIgnoreBlanks.Checked := not actIgnoreBlanks.Checked;
  if FilesCompared then
    actCompare.Execute;
end;

procedure TCnLocalHistoryForm.actIgnoreCaseExecute(Sender: TObject);
begin
  actIgnoreCase.Checked := not actIgnoreCase.Checked;
  if FilesCompared then
    actCompare.Execute;
end;

procedure TCnLocalHistoryForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actCompare.Enabled := True;
  actNextDiff.Enabled := FilesCompared;
  actPrioDiff.Enabled := FilesCompared;

  actShowDiffOnly.Enabled := True;

  actGoto.Enabled := (ActiveControl = DiffControl1) and (Lines1.Count > 0) or
    (ActiveControl = DiffControl2) and (Lines2.Count > 0);
end;

procedure TCnLocalHistoryForm.actModColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorMod];
    if not Execute then Exit;
    DiffControl1.LineColors[colorMod] := Color;
    DiffControl2.LineColors[colorMod] := Color;
    DiffControlMerge.LineColors[colorMod] := Color;
  end;
  RepaintControls;
end;

procedure TCnLocalHistoryForm.actNextDiffExecute(Sender: TObject);
begin
  if ActiveControl is TDiffControl then
    TDiffControl(ActiveControl).GotoNextDiff
  else
    DiffControl1.GotoNextDiff;
end;

procedure TCnLocalHistoryForm.actPrioDiffExecute(Sender: TObject);
begin
  if ActiveControl is TDiffControl then
    TDiffControl(ActiveControl).GotoPrioDiff
  else
    DiffControl1.GotoPrioDiff;
end;

procedure TCnLocalHistoryForm.actShowDiffOnlyExecute(Sender: TObject);
begin
  actShowDiffOnly.Checked := not actShowDiffOnly.Checked;
  if FilesCompared then
    DisplayDiffs;
end;

procedure TCnLocalHistoryForm.actSplitHorizontallyExecute(Sender: TObject);
begin
  actSplitHorizontally.Checked := not actSplitHorizontally.Checked;
  SetSplitHorizontally(actSplitHorizontally.Checked);
end;

procedure TCnLocalHistoryForm.DiffCtrlDblClick(Sender: TObject);
begin
  if Sender is TDiffControl then
    actGoto.Execute;
end;

procedure TCnLocalHistoryForm.DiffCtrlMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  clrIndex, ClickedLine: Integer;
begin
  with TDiffControl(Sender) do
  begin
    ClickedLine := ClientPtToTextPoint(Point(X, Y)).y;
    if ClickedLine >= Lines.Count then Exit;
    clrIndex := Lines.ColorIndex[ClickedLine];
    if clrIndex = 0 then
      KillFocus else
      FocusStart := ClickedLine;
  end;
end;

procedure TCnLocalHistoryForm.DiffProgress(Sender: TObject; percent: Integer);
begin
  Statusbar1.Panels[3].Text := Format(SCnSourceDiffApprox, [percent]);
  Statusbar1.Refresh;
end;

procedure TCnLocalHistoryForm.DisplayDiffs;
var
  i, j, k: Integer;
begin
  DiffControl1.Lines.BeginUpdate;
  DiffControl2.Lines.BeginUpdate;
  try
    DiffControl1.Lines.Clear;
    DiffControl2.Lines.Clear;
    DiffControl1.MaxLineNum := Lines1.Count;
    DiffControl2.MaxLineNum := Lines2.Count;

    j := 0;
    k := 0;
    with Diff do
      for i := 0 to ChangeCount - 1 do
        with changes[i] do
        begin
          //first add preceeding unmodified lines...
          if actShowDiffOnly.Checked then
            Inc(k, x - j)
          else
            while j < x do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[j], j + 1, 0);
              DiffControl2.Lines.AddLineInfo(lines2[k], k + 1, 0);
              Inc(j);
              Inc(k);
            end;

          if Kind = ckAdd then
          begin
            for j := k to k + Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo('', 0, colorAdd);
              DiffControl2.Lines.AddLineInfo(lines2[j], j + 1, colorAdd);
            end;
            j := x;
            k := y + Range;
          end else if Kind = ckModify then
          begin
            for j := 0 to Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[x + j], x + j + 1, colorMod);
              DiffControl2.Lines.AddLineInfo(lines2[k + j], k + j + 1, colorMod);
            end;
            j := x + Range;
            k := y + Range;
          end else
          begin
            for j := x to x + Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[j], j + 1, colorDel);
              DiffControl2.Lines.AddLineInfo('', 0, colorDel);
            end;
            j := x + Range;
          end;
        end;

    if not actShowDiffOnly.Checked then
      while j < lines1.Count do
      begin
        DiffControl1.Lines.AddLineInfo(lines1[j], j + 1, 0);
        DiffControl2.Lines.AddLineInfo(lines2[k], k + 1, 0);
        Inc(j);
        Inc(k);
      end;
  finally
    DiffControl1.Lines.EndUpdate;
    DiffControl2.Lines.EndUpdate;
    DiffControl1.TopVisibleLine := 0;
    DiffControl2.TopVisibleLine := 0;
    UpdateFileBmp;
    pbPos.Repaint;
  end;
end;

procedure TCnLocalHistoryForm.DoLanguageChanged(Sender: TObject);
begin
end;

procedure TCnLocalHistoryForm.DoOpenFile(const FileName: string; InEditor: Boolean;
  OpenFile1: Boolean);
var
  DiffControl: TDiffControl;
  Stream: TMemoryStream;
begin
  Stream := nil;
  FilesCompared := False;
  if OpenFile1 then
  begin
    DiffControl := DiffControl1;
    if not InEditor then                // 存盘文件
      Lines1.LoadFromFile(FileName)
    else
    begin                               // 编辑器缓冲区
      with TCnEditFiler.Create(FileName) do
      try
        Stream := TMemoryStream.Create;
        SaveToStream(Stream);
        Stream.Position := 0;
        Lines1.LoadFromStream(Stream);
      finally
        Free;
        if Assigned(Stream) then Stream.Free;
      end;
    end;
    DiffControl.Lines.Assign(Lines1);
  end
  else
  begin
    DiffControl := DiffControl2;
    if not InEditor then                // 存盘文件
      Lines2.LoadFromFile(FileName)
    else
    begin                               // 编辑器缓冲区
      with TCnEditFiler.Create(FileName) do
      try
        Stream := TMemoryStream.Create;
        SaveToStream(Stream);
        Stream.Position := 0;
        Lines2.LoadFromStream(Stream);
      finally
        Free;
        if Assigned(Stream) then Stream.Free;
      end;
    end;
    DiffControl.Lines.Assign(Lines2);
  end;

  DiffControl.MaxLineNum := 1;
  DiffControl.TopVisibleLine := 0;
  DiffControl.HorzScroll := 0;
end;

procedure TCnLocalHistoryForm.DoTabHide;
begin
  inherited;

end;

procedure TCnLocalHistoryForm.DoTabShow(Editor: IOTASourceEditor;
  View: IOTAEditView);
begin
  inherited;

end;

procedure TCnLocalHistoryForm.FormCreate(Sender: TObject);
begin
  FWizard := 
  Lines1 := TStringList.Create;
  Lines2 := TStringList.Create;
  Diff := TDiff.Create(Self);
  Diff.OnProgress := DiffProgress;

  DiffControl1 := TDiffControl.Create(Self);
  with DiffControl1 do
  begin
    Parent := pnlLeft;
    Align := alClient;
    OnMouseDown := DiffCtrlMouseDown;
    OnDblClick := DiffCtrlDblClick;
  end;

  DiffControl2 := TDiffControl.Create(Self);
  with DiffControl2 do
  begin
    Parent := pnlRight;
    Align := alClient;
    OnMouseDown := DiffCtrlMouseDown;
    OnDblClick := DiffCtrlDblClick;
  end;

  pbPos.Canvas.Pen.Color := clBlack;
  pbPos.Canvas.Pen.Width := 2;

  FileBmp := TBitmap.Create;
  FileBmp.Canvas.Brush.Color := clWindow;
end;

procedure TCnLocalHistoryForm.FormDestroy(Sender: TObject);
begin
  //SaveOptions;
  FileBmp.Free;
  Lines2.Free;
  Lines1.Free;
end;

procedure TCnLocalHistoryForm.FormResize(Sender: TObject);
begin
  if actSplitHorizontally.Checked then
    pnlLeft.Height := pnlMain.ClientHeight div 2 else
    pnlLeft.Width := pnlMain.ClientWidth div 2;
  lvLeft.Width := pnlVersion.ClientWidth div 2;
end;

function TCnLocalHistoryForm.GetHelpTopic: string;
begin
  Result := 'CnSourceDiffWizard';
end;

function TCnLocalHistoryForm.GetTabCaption: string;
begin
  Result := SLocalHistoryTabCaption;
end;

function TCnLocalHistoryForm.IsTabVisible(Editor: IOTASourceEditor;
  View: IOTAEditView): Boolean;
begin
  Result := True;
end;

procedure TCnLocalHistoryForm.pbFileMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    DiffControl1.TopVisibleLine := Trunc(Y / pbFile.Height *
      (DiffControl1.Lines.Count - 1)) - DiffControl1.ClientHeight div
      DiffControl1.LineHeight div 2;
    SyncScroll(DiffControl1);
  end;
end;

procedure TCnLocalHistoryForm.pbFilePaint(Sender: TObject);
begin
  with pbFile do
    Canvas.StretchDraw(Rect(0, 0, Width, Height), FileBmp);
end;

procedure TCnLocalHistoryForm.pbPosPaint(Sender: TObject);
var
  yPos: Integer;
begin
  if DiffControl1.Lines.Count = 0 then Exit;
  with pbPos do
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(ClientRect);
    yPos := DiffControl1.TopVisibleLine + DiffControl1.VisibleLines div 2;
    yPos := ClientHeight * ypos div DiffControl1.Lines.Count;
    Canvas.MoveTo(0, yPos);
    Canvas.LineTo(ClientWidth, yPos);
  end;
end;

procedure TCnLocalHistoryForm.RepaintControls;
begin
  DiffControl1.Repaint;
  DiffControl2.Repaint;
  UpdateFileBmp;
  pbFile.Repaint;
  //pbPos.Repaint;
  StatusBar1.Repaint;
end;

procedure TCnLocalHistoryForm.SetFilesCompared(const Value: Boolean);
begin
  FFilesCompared := Value;
  if Value then
  begin
    DiffControl1.OnScroll := SyncScroll;
    DiffControl2.OnScroll := SyncScroll;
    pnlDisplay.Visible := True;
  end
  else
  begin
    DiffControl1.UseFocusRect := False;
    DiffControl2.UseFocusRect := False;
    DiffControlMerge.UseFocusRect := False;
    DiffControl1.OnScroll := nil;
    DiffControl2.OnScroll := nil;
    Statusbar1.Panels[3].Text := '';
    pnlDisplay.Visible := False;
  end;
end;

procedure TCnLocalHistoryForm.SetSourceName(const Value: string);
begin
  FSourceName := Value;
end;

procedure TCnLocalHistoryForm.SetSplitHorizontally(SplitHorizontally: Boolean);
begin
  if SplitHorizontally then
  begin
    pnlLeft.Align := alTop;
    pnlLeft.Height := pnlMain.ClientHeight div 2 - 1;
    splFiles.Align := alTop;
    splFiles.cursor := crVSplit;
  end else
  begin
    pnlLeft.Align := alLeft;
    pnlLeft.Width := pnlMain.ClientWidth div 2 - 1;
    splFiles.Align := alLeft;
    splFiles.Left := 10;
    splFiles.cursor := crHSplit;
  end;
end;

procedure TCnLocalHistoryForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  case Panel.Index of
    0: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorAdd];
    1: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorMod];
    2: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorDel];
  else Exit;
  end;
  StatusBar1.Canvas.FillRect(Rect);
  StatusBar1.Canvas.TextOut(Rect.Left + 4, Rect.Top, Panel.Text);
end;

procedure TCnLocalHistoryForm.StatusBar1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  if (X >= 0) and (X <= StatusBar1.Panels[0].Width * 3) and (Y >= 0) and
    (Y <= StatusBar1.ClientHeight) and (Button = mbLeft) then
  begin
    i := X div StatusBar1.Panels[0].Width + 1;
    if i = colorAdd then
      actAddColor.Execute
    else if i = colorMod then
      actModColor.Execute
    else if i = colorDel then
      actDelColor.Execute;
  end;
end;

procedure TCnLocalHistoryForm.SyncScroll(Sender: TObject);
begin
  //stop recursive WM_SCROLL messages...
  DiffControl1.OnScroll := nil;
  DiffControl2.OnScroll := nil;

  if Sender = DiffControl1 then
  begin
    DiffControl2.TopVisibleLine := DiffControl1.TopVisibleLine;
    DiffControl2.HorzScroll := DiffControl1.HorzScroll;
  end
  else if Sender = DiffControl2 then
  begin
    DiffControl1.TopVisibleLine := DiffControl2.TopVisibleLine;
    DiffControl1.HorzScroll := DiffControl2.HorzScroll;
  end;

  DiffControl1.OnScroll := SyncScroll;
  DiffControl2.OnScroll := SyncScroll;

  pbPosPaint(Self);
end;

procedure TCnLocalHistoryForm.UpdateFileBmp;
var
  i, j, y1, y2: Integer;
  clrIndex: Integer;
  HeightRatio: single;
begin
  if (DiffControl1.Lines.Count = 0) or (DiffControl2.Lines.Count = 0) then Exit;
  HeightRatio := Screen.Height / DiffControl1.Lines.Count;

  FileBmp.Height := Screen.Height;
  FileBmp.Width := pbFile.ClientWidth;
  FileBmp.Canvas.Pen.Width := 2;
  FileBmp.Canvas.Brush.Color := clWhite;
  FileBmp.Canvas.FillRect(Rect(0, 0, FileBmp.Width, FileBmp.Height));
  with DiffControl1 do
  begin
    i := 0;
    while i < Lines.Count do
    begin
      clrIndex := Lines.ColorIndex[i];
      if clrIndex = 0 then
        Inc(i)
      else
      begin
        j := i + 1;
        while (j < Lines.Count) and (Lines.ColorIndex[j] = Lines.ColorIndex[i]) do
          Inc(j);
        FileBmp.Canvas.Brush.Color := LineColors[clrIndex];
        y1 := Trunc(i * HeightRatio);
        y2 := Trunc(j * HeightRatio);
        FileBmp.Canvas.FillRect(Rect(0, y1, FileBmp.Width, y2));
        i := j;
      end;
    end;
  end;
  pbFile.Invalidate;
end;

{ TCnLocalHistoryWizard }

constructor TCnLocalHistoryWizard.Create;
begin
  inherited;
  FList := TList.Create;
  EditorTabSetHook.AddEditPage(TCnLocalHistoryForm);
end;

destructor TCnLocalHistoryWizard.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnLocalHistoryWizard.Config;
begin
  inherited;

end;

function TCnLocalHistoryWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnLocalHistoryWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  inherited;

end;

procedure TCnLocalHistoryWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    AddColor := ReadColor('', csAddColor, $0FD70F);
    ModColor := ReadColor('', csModColor, $FF8080);
    DelColor := ReadColor('', csDelColor, $CF98FF);

    Font.Name := SCnDefaultFontName;
    Font.Size := SCnDefaultFontSize;
    Font.Charset := SCnDefaultFontCharset;
    Font.Color := clBlack;
    Font := ReadFont('', csFont, Font);

    Horizontal := ReadBool('', csHorizontal, False);
    IgnoreBlanks := ReadBool('', csIgnoreBlanks, False);
    IgnoreCase := ReadBool('', csIgnoreCase, False);
    ShowDiffOnly := ReadBool('', csShowDiffOnly, False);
  finally
    Free;
  end;
end;

procedure TCnLocalHistoryWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteColor('', csAddColor, AddColor);
    WriteColor('', csModColor, ModColor);
    WriteColor('', csDelColor, DelColor);

    WriteFont('', csFont, Font);

    WriteBool('', csHorizontal, Horizontal);
    WriteBool('', csIgnoreBlanks, IgnoreBlanks);
    WriteBool('', csIgnoreCase, IgnoreCase);
    WriteBool('', csShowDiffOnly, ShowDiffOnly);
  finally
    Free;
  end;
end;

procedure TCnLocalHistoryWizard.SetAddColor(const Value: TColor);
begin
  if FAddColor <> Value then
  begin
    FAddColor := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetDelColor(const Value: TColor);
begin
  if FDelColor <> Value then
  begin
    FDelColor := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  UpdateForms;
end;

procedure TCnLocalHistoryWizard.SetHorizontal(const Value: Boolean);
begin
  if FHorizontal <> Value then
  begin
    FHorizontal := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetIgnoreBlanks(const Value: Boolean);
begin
  if FIgnoreBlanks <> Value then
  begin
    FIgnoreBlanks := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetIgnoreCase(const Value: Boolean);
begin
  if FIgnoreCase <> Value then
  begin
    FIgnoreCase := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetModColor(const Value: TColor);
begin
  if FModColor <> Value then
  begin
    FModColor := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.SetShowDiffOnly(const Value: Boolean);
begin
  if FShowDiffOnly <> Value then
  begin
    FShowDiffOnly := Value;
    UpdateForms;
  end;
end;

procedure TCnLocalHistoryWizard.UpdateForms;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    with TCnLocalHistoryForm(FList[i]) do
    begin
      DiffControl1.Font.Assign(Self.Font);
      DiffControl2.Font.Assign(Self.Font);
      DiffControl1.LineColors[colorAdd] := AddColor;
      DiffControl1.LineColors[colorMod] := ModColor;
      DiffControl1.LineColors[colorDel] := DelColor;
      DiffControl2.LineColors[colorAdd] := AddColor;
      DiffControl2.LineColors[colorMod] := ModColor;
      DiffControl2.LineColors[colorDel] := DelColor;
      SetSplitHorizontally(Horizontal);
    end;
end;

initialization
  RegisterCnWizard(TCnLocalHistoryWizard); // 注册专家

end.

