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

unit CnSourceDiffFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源代码比较窗体单元
* 单元作者：Angus Johnson（原作者） ajohnson@rpi.net.au
*           周劲羽（移植）zjy@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2019.01.22 V1.2
*               加入粘贴功能的支持
*           2003.03.21 V1.1
*               修正右边差异图底色可能不正确的 Bug
*               修正点击按钮定义到源码可能会出错的 Bug
*           2003.03.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DiffUnit, ExtCtrls, DiffControl, Menus, ComCtrls, ShellAPI, Clipbrd,
  IniFiles, CnDiffEditorFrm, CnCRC32, CnWizUtils, Buttons, ToolWin, CnIni,
  ActnList, ImgList, CnWizConsts, ToolsAPI, CnWizEditFiler, CnCommon,
  CnConsts, CnWizMultiLang, CnPopupMenu;

type

  TFileKind = (fkDiskFile, fkEditorBuff, fkBackupFile);
  TFileKinds = set of TFileKind;

  TCnSourceDiffForm = class(TCnTranslateForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    mnuOpen1: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    Options1: TMenuItem;
    mnuIgnoreBlanks: TMenuItem;
    mnuIgnoreCase: TMenuItem;
    N2: TMenuItem;
    mnuCompare: TMenuItem;
    OpenDialog1: TOpenDialog;
    N3: TMenuItem;
    mnuFont: TMenuItem;
    Help1: TMenuItem;
    mnuOpen2: TMenuItem;
    FontDialog: TFontDialog;
    mnuSplitHorizontally: TMenuItem;
    N4: TMenuItem;
    pnlDisplay: TPanel;
    pbFile: TPaintBox;
    pbPos: TPaintBox;
    N5: TMenuItem;
    mnuHighlightColors: TMenuItem;
    Added1: TMenuItem;
    Modified1: TMenuItem;
    Deleted1: TMenuItem;
    ColorDialog: TColorDialog;
    mnuCancel: TMenuItem;
    mnuMergeOptions: TMenuItem;
    mnuMergeFromFile1: TMenuItem;
    mnuMergeFromFile2: TMenuItem;
    mnuMergeFromNeither: TMenuItem;
    SaveDialog: TSaveDialog;
    mnuSaveMerged: TMenuItem;
    Panel1: TPanel;
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    pnlMerge: TPanel;
    Splitter2: TSplitter;
    mnuActions: TMenuItem;
    N6: TMenuItem;
    mnuMergeFocusedText: TMenuItem;
    mnuEditFocusedText: TMenuItem;
    Contents1: TMenuItem;
    mnuShowDiffsOnly: TMenuItem;
    StatusBar1: TStatusBar;
    ToolBar: TToolBar;
    tbSaveMerged: TToolButton;
    tbSplitHorizontally: TToolButton;
    tbFont: TToolButton;
    tbCompare: TToolButton;
    ActionList: TActionList;
    actOpen1: TAction;
    actOpen2: TAction;
    actSaveMerged: TAction;
    actClose: TAction;
    actIgnoreBlanks: TAction;
    actIgnoreCase: TAction;
    actShowDiffOnly: TAction;
    actSplitHorizontally: TAction;
    actAddColor: TAction;
    actModColor: TAction;
    actDelColor: TAction;
    actFont: TAction;
    actCompare: TAction;
    actCancel: TAction;
    actMergeFromFile1: TAction;
    actMergeFromFile2: TAction;
    actMergeFromNeither: TAction;
    actMergeFocusedText: TAction;
    actEditFocusedText: TAction;
    actHelp: TAction;
    ToolButton8: TToolButton;
    btnFileKind1: TBitBtn;
    btnHistory1: TBitBtn;
    btnFileKind2: TBitBtn;
    btnHistory2: TBitBtn;
    btnOpenFile1: TBitBtn;
    btnOpenFile2: TBitBtn;
    pmFileKind1: TPopupMenu;
    pmHistory1: TPopupMenu;
    pmHistory2: TPopupMenu;
    pmiDiskFile1: TMenuItem;
    pmiEditorBuff1: TMenuItem;
    pmiBackupFile1: TMenuItem;
    pmFileKind2: TPopupMenu;
    pmiDiskFile2: TMenuItem;
    pmiEditorBuff2: TMenuItem;
    pmiBackupFile2: TMenuItem;
    ToolButton1: TToolButton;
    tbCancel: TToolButton;
    tbHelp: TToolButton;
    ToolButton11: TToolButton;
    tbClose: TToolButton;
    ToolButton13: TToolButton;
    actNextDiff: TAction;
    actPrioDiff: TAction;
    tbNextDiff: TToolButton;
    tbPrioDiff: TToolButton;
    ToolButton4: TToolButton;
    tbMerge: TToolButton;
    tbMergeFocusedText: TToolButton;
    tbEditFocusedText: TToolButton;
    ToolButton9: TToolButton;
    N7: TMenuItem;
    mnuNextDiff: TMenuItem;
    mnuPrioDiff: TMenuItem;
    actCompareEx: TAction;
    mnuCompareEx: TMenuItem;
    tbCompareEx: TToolButton;
    actGoto: TAction;
    tbGoto: TToolButton;
    mnuGoto: TMenuItem;
    OpenDialog2: TOpenDialog;
    btnPaste1: TBitBtn;
    btnPaste2: TBitBtn;
    actPaste1: TAction;
    actPaste2: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbFilePaint(Sender: TObject);
    procedure pbPosPaint(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actCompareExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actMergeFromExecute(Sender: TObject);
    procedure actMergeFocusedTextExecute(Sender: TObject);
    procedure actEditFocusedTextExecute(Sender: TObject);
    procedure actOpen1Execute(Sender: TObject);
    procedure actOpen2Execute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actIgnoreBlanksExecute(Sender: TObject);
    procedure actIgnoreCaseExecute(Sender: TObject);
    procedure actShowDiffOnlyExecute(Sender: TObject);
    procedure actSplitHorizontallyExecute(Sender: TObject);
    procedure actAddColorExecute(Sender: TObject);
    procedure actModColorExecute(Sender: TObject);
    procedure actDelColorExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure actSaveMergedExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure pnlCaptionLeftResize(Sender: TObject);
    procedure pnlCaptionRightResize(Sender: TObject);
    procedure pbFileMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnFileKind1Click(Sender: TObject);
    procedure StatusBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnHistory1Click(Sender: TObject);
    procedure btnFileKind2Click(Sender: TObject);
    procedure btnHistory2Click(Sender: TObject);
    procedure pmFileKind1Popup(Sender: TObject);
    procedure pmFileKind2Popup(Sender: TObject);
    procedure pmiDiskFile1Click(Sender: TObject);
    procedure pmiDiskFile2Click(Sender: TObject);
    procedure pmHistory1Popup(Sender: TObject);
    procedure pmHistory2Popup(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actNextDiffExecute(Sender: TObject);
    procedure actPrioDiffExecute(Sender: TObject);
    procedure tbMergeClick(Sender: TObject);
    procedure actCompareExExecute(Sender: TObject);
    procedure actGotoExecute(Sender: TObject);
    procedure actPaste1Execute(Sender: TObject);
    procedure actPaste2Execute(Sender: TObject);
  private
    Ini: TCustomIniFile;
    FFilesCompared: Boolean;
    Lines1, Lines2: TStrings;
    FileBmp: TBitmap;
    Diff: TDiff;
    DiffControl1: TDiffControl;
    DiffControl2: TDiffControl;
    DiffControlMerge: TDiffControl;
    History1: TStrings;
    History2: TStrings;
    UnitList: TStrings;
    FFileKind1: TFileKind;
    FFileKind2: TFileKind;
    procedure DisplayDiffs;
    procedure DiffCtrlMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DiffCtrlDblClick(Sender: TObject);
    procedure LoadOptions;
    procedure SaveOptions;
    procedure RepaintControls;
    procedure UpdateFileBmp;
    procedure SyncScroll(Sender: TObject);
    procedure FileDrop(Sender: TObject; dropHandle: Integer; var DropHandled: Boolean);
    procedure DoOpenFile(OpenFile1: Boolean);
    procedure DiffProgress(Sender: TObject; percent: Integer);
    procedure SetSplitHorizontally(SplitHorizontally: Boolean);
    procedure DoPopupMenu(Btn: TBitBtn; Menu: TPopupMenu);
    function GetBakFileName(const FileName: string): string;
    procedure SetFileKind1(const Value: TFileKind);
    procedure SetFileKind2(const Value: TFileKind);
    function GetFileKinds(const FileName: string): TFileKinds;
    procedure OnHistory1Click(Sender: TObject);
    procedure OnHistory2Click(Sender: TObject);
    procedure UpdateHistoryMenu(Menu: TPopupMenu; History: TStrings;
      OnClick: TNotifyEvent; IsEmpty: Boolean);
    function GetFileName1: string;
    function GetFileName2: string;
    procedure SetFileName1(const Value: string);
    procedure SetFileName2(const Value: string);
    procedure SetFilesCompared(const Value: Boolean);
    function GetIsMerging: Boolean;
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile);
    property FileKind1: TFileKind read FFileKind1 write SetFileKind1;
    property FileKind2: TFileKind read FFileKind2 write SetFileKind2;
    property FileName1: string read GetFileName1 write SetFileName1;
    property FileName2: string read GetFileName2 write SetFileName2;
    property FilesCompared: Boolean read FFilesCompared write SetFilesCompared;
    property IsMerging: Boolean read GetIsMerging;
  end;

const
  colorAdd = 1;
  colorMod = 2;
  colorDel = 3;

  csMaxHistory = 8;

var
  csFileKinds: array[TFileKind] of string = ('SCnDiskFile', 'SCnEditorBuff', 'SCnBakFile');

  CnSourceDiffForm: TCnSourceDiffForm;

procedure ShowSourceDiffForm(AIni: TCustomIniFile; AIcon: TIcon = nil);

procedure FreeSourceDiffForm;

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

uses
  CnWizShareImages, CnWizOptions {$IFDEF DEBUG}, CnDebug{$ENDIF};

{$R *.DFM}

procedure ShowSourceDiffForm(AIni: TCustomIniFile; AIcon: TIcon = nil);
begin
  if CnSourceDiffForm = nil then
  begin
    CnSourceDiffForm := TCnSourceDiffForm.CreateEx(Application.MainForm, AIni);
    if AIcon <> nil then
      CnSourceDiffForm.Icon := AIcon;
  end;
  CnSourceDiffForm.Show;
end;

procedure FreeSourceDiffForm;
begin
  if CnSourceDiffForm <> nil then
    CnSourceDiffForm.Free;
end;

function HashLine(const Line: string; IgnoreCase, IgnoreBlanks: Boolean): Pointer;
var
  I, J, Len: Integer;
  S: string;
begin
  S := Line;
  if IgnoreBlanks then
  begin
    I := 1;
    J := 1;
    Len := Length(Line);
    while I <= Len do
    begin
      if not CharInSet(Line[I], [#9, #32]) then
      begin
        S[J] := Line[I];
        Inc(J);
      end;
      Inc(I);
    end;
    SetLength(S, J - 1);
  end;
  if IgnoreCase then S := AnsiLowerCase(S);
  //return result as a pointer to save typecasting later...
  Result := Pointer(CRC32Calc(0, PChar(S)^, Length(S) * SizeOf(Char)));
end;

//==============================================================================
// 源代码比较窗体
//==============================================================================

constructor TCnSourceDiffForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile);
begin
  Create(AOwner);
  Ini := AIni;
end;

procedure TCnSourceDiffForm.FormCreate(Sender: TObject);
begin
  Lines1 := TStringList.Create;
  Lines2 := TStringList.Create;
  Diff := TDiff.Create(Self);
  Diff.OnProgress := DiffProgress;

  History1 := TStringList.Create;
  History2 := TStringList.Create;
  UnitList := TStringList.Create;

  DiffControl1 := TDiffControl.Create(Self);
  with DiffControl1 do
  begin
    Parent := pnlLeft;
    Align := alClient;
    OnMouseDown := DiffCtrlMouseDown;
    OnDropFiles := FileDrop;
    OnDblClick := DiffCtrlDblClick;
  end;

  DiffControl2 := TDiffControl.Create(Self);
  with DiffControl2 do
  begin
    Parent := pnlRight;
    Align := alClient;
    OnMouseDown := DiffCtrlMouseDown;
    OnDropFiles := FileDrop;
    OnDblClick := DiffCtrlDblClick;
  end;

  DiffControlMerge := TDiffControl.Create(Self);
  with DiffControlMerge do
  begin
    Parent := pnlMerge;
    Align := alClient;
    OnMouseDown := DiffCtrlMouseDown;
    OnDblClick := DiffCtrlDblClick;
    Color := $D9D9D9;
  end;

  Splitter2.Visible := False;

  pbPos.Canvas.Pen.Color := clBlack;
  pbPos.Canvas.Pen.Width := 2;

  FileBmp := TBitmap.Create;
  FileBmp.Canvas.Brush.Color := clWindow;

  pnlCaptionLeftResize(nil);
  pnlCaptionRightResize(nil);

  btnFileKind1.Caption := csFileKinds[Low(TFileKind)];
  btnFileKind2.Caption := csFileKinds[Low(TFileKind)];
  
  LoadOptions;
  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
end;

procedure TCnSourceDiffForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveOptions;
  Action := caHide;
end;

procedure TCnSourceDiffForm.FormDestroy(Sender: TObject);
begin
  Diff.Free;
  FileBmp.Free;
  Lines2.Free;
  Lines1.Free;
  UnitList.Free;
  History1.Free;
  History2.Free;
  DiffControl2.Free;
  DiffControl1.Free;
  DiffControlMerge.Free;
end;

procedure TCnSourceDiffForm.FormResize(Sender: TObject);
begin
  if actSplitHorizontally.Checked then
    pnlLeft.Height := pnlMain.ClientHeight div 2 - 1 else
    pnlLeft.Width := pnlMain.ClientWidth div 2 - 1;
end;

const
  csBoundsLeft = 'Left';
  csBoundsTop = 'Top';
  csBoundsWidth = 'Width';
  csBoundsHeight = 'Height';
  csFont = 'Font';
  csAddColor = 'AddColor';
  csModColor = 'ModColor';
  csDelColor = 'DelColor';
  csHorizontal = 'Horizontal';
  csInitialDir1 = 'InitialDir';
  csInitialDir2 = 'InitialDir2';
  csIgnoreBlanks = 'IgnoreBlanks';
  csIgnoreCase = 'IgnoreCase';
  csShowDiffOnly = 'ShowDiffOnly';
  csHistory1 = 'History1';
  csHistory2 = 'History2';

procedure TCnSourceDiffForm.LoadOptions;
var
  L, T, W, H: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    L := ReadInteger('', csBoundsLeft, 0);
    T := ReadInteger('', csBoundsTop, 0);
    W := ReadInteger('', csBoundsWidth, -1);
    H := ReadInteger('', csBoundsHeight, -1);

    //set (Add, Del, Mod) colors...
    DiffControl1.LineColors[colorAdd] := ReadColor('', csAddColor, $0FD70F);
    DiffControl1.LineColors[colorMod] := ReadColor('', csModColor, $FF8080);
    DiffControl1.LineColors[colorDel] := ReadColor('', csDelColor, $CF98FF);

    DiffControl1.Font.Handle := GetStockObject(DEFAULT_GUI_FONT);
    DiffControl1.Font := ReadFont('', csFont, DiffControl1.Font);

    OpenDialog1.InitialDir := ReadString('', csInitialDir1, '');
    OpenDialog2.InitialDir := ReadString('', csInitialDir2, '');
    actSplitHorizontally.Checked := ReadBool('', csHorizontal, False);
    actIgnoreBlanks.Checked := ReadBool('', csIgnoreBlanks, False);
    actIgnoreCase.Checked := ReadBool('', csIgnoreCase, False);
    actShowDiffOnly.Checked := ReadBool('', csShowDiffOnly, False);

    History1 := ReadStrings(csHistory1, History1);
    History2 := ReadStrings(csHistory2, History2);

    SetSplitHorizontally(actSplitHorizontally.Checked);
  finally
    Free;
  end;

  DiffControl2.Font.Assign(DiffControl1.Font);
  DiffControlMerge.Font.Assign(DiffControl1.Font);
  DiffControl2.LineColors[colorAdd] := DiffControl1.LineColors[colorAdd];
  DiffControlMerge.LineColors[colorAdd] := DiffControl1.LineColors[colorAdd];
  DiffControl2.LineColors[colorMod] := DiffControl1.LineColors[colorMod];
  DiffControlMerge.LineColors[colorMod] := DiffControl1.LineColors[colorMod];
  DiffControl2.LineColors[colorDel] := DiffControl1.LineColors[colorDel];
  DiffControlMerge.LineColors[colorDel] := DiffControl1.LineColors[colorDel];

  //make sure the form is positioned on screen ...
  //(ie make sure nobody's fiddled with the INI file!)
  if (W > 0) and (H > 0) and
    (L < Screen.Width) and (T < Screen.Height) and
    (L + W > 0) and (T + H > 0) then
    SetBounds(L, T, W, H);
end;

procedure TCnSourceDiffForm.SaveOptions;
begin
  with TCnIniFile.Create(Ini) do
  try
    if WindowState = wsNormal then
    begin
      WriteInteger('', csBoundsLeft, Self.Left);
      WriteInteger('', csBoundsTop, Self.Top);
      WriteInteger('', csBoundsWidth, Self.Width);
      WriteInteger('', csBoundsHeight, Self.Height);
    end;

    WriteColor('', csAddColor, DiffControl1.LineColors[colorAdd]);
    WriteColor('', csModColor, DiffControl1.LineColors[colorMod]);
    WriteColor('', csDelColor, DiffControl1.LineColors[colorDel]);

    WriteFont('', csFont, DiffControl1.Font);
    WriteString('', csInitialDir1, OpenDialog1.InitialDir);
    WriteString('', csInitialDir2, OpenDialog2.InitialDir);
    WriteBool('', csHorizontal, actSplitHorizontally.Checked);
    WriteBool('', csIgnoreBlanks, actIgnoreBlanks.Checked);
    WriteBool('', csIgnoreCase, actIgnoreCase.Checked);
    WriteBool('', csShowDiffOnly, actShowDiffOnly.Checked);

    WriteStrings(csHistory1, History1);
    WriteStrings(csHistory2, History2);
  finally
    Free;
  end;
end;

// Syncronise scrolling of both DiffControls...
procedure TCnSourceDiffForm.SyncScroll(Sender: TObject);
begin
  // stop recursive WM_SCROLL messages...
  DiffControl1.OnScroll := nil;
  DiffControl2.OnScroll := nil;
  DiffControlMerge.OnScroll := nil;

  if Sender = DiffControl1 then
  begin
    DiffControl2.TopVisibleLine := DiffControl1.TopVisibleLine;
    DiffControl2.HorzScroll := DiffControl1.HorzScroll;
    if IsMerging then
    begin
      DiffControlMerge.TopVisibleLine := DiffControl1.TopVisibleLine;
      DiffControlMerge.HorzScroll := DiffControl1.HorzScroll;
    end;
  end
  else if Sender = DiffControl2 then
  begin
    DiffControl1.TopVisibleLine := DiffControl2.TopVisibleLine;
    DiffControl1.HorzScroll := DiffControl2.HorzScroll;
    if IsMerging then
    begin
      DiffControlMerge.TopVisibleLine := DiffControl1.TopVisibleLine;
      DiffControlMerge.HorzScroll := DiffControl1.HorzScroll;
    end;
  end
  else if Sender = DiffControlMerge then
  begin
    DiffControl1.TopVisibleLine := DiffControlMerge.TopVisibleLine;
    DiffControl1.HorzScroll := DiffControlMerge.HorzScroll;
    DiffControl2.TopVisibleLine := DiffControlMerge.TopVisibleLine;
    DiffControl2.HorzScroll := DiffControlMerge.HorzScroll;
  end;

  DiffControl1.OnScroll := SyncScroll;
  DiffControl2.OnScroll := SyncScroll;
  if IsMerging then DiffControlMerge.OnScroll := SyncScroll;

  pbPosPaint(Self);
end;

procedure TCnSourceDiffForm.DoOpenFile(OpenFile1: Boolean);
var
  DiffControl: TDiffControl;
  FileName: string;
  Kinds: TFileKinds;
  Kind, FKind: TFileKind;
  Stream: TMemoryStream;
begin
  if OpenFile1 then
  begin
    FileName := FileName1;
    Kind := FileKind1;
  end
  else
  begin
    FileName := FileName2;
    Kind := FileKind2;
  end;

  Kinds := GetFileKinds(FileName);
  if Kinds = [] then
  begin
    ErrorDlg(SCnSourceDiffOpenError);
    Exit;
  end;

  if not (Kind in Kinds) then
  begin
    for FKind := Low(FKind) to High(FKind) do
    begin
      if FKind in Kinds then
      begin
        if OpenFile1 then
        begin
          FFileKind1 := FKind;
          Kind := FKind;
          btnFileKind1.Caption := csFileKinds[Kind];
        end
        else
        begin
          FFileKind2 := FKind;
          Kind := FKind;
          btnFileKind2.Caption := csFileKinds[Kind];
        end;
        Break;
      end;
    end;
  end;

  FilesCompared := False;
  if OpenFile1 then
  begin
    DiffControl := DiffControl1;
    if Kind = fkDiskFile then           // 存盘文件
      Lines1.LoadFromFile(FileName)
    else if Kind = fkBackupFile then       // 备份文件
      Lines1.LoadFromFile(GetBakFileName(FileName))
    else
    begin                               // 编辑器缓冲区
      Stream := TMemoryStream.Create;
      try
        EditFilerSaveFileToStream(FileName, Stream, True); // Ansi/Ansi/Utf16
        Lines1.Text := string(PChar(Stream.Memory));
      finally
        Stream.Free;
      end;
    end;
    DiffControl.Lines.Assign(Lines1);
  end
  else
  begin
    DiffControl := DiffControl2;
    if Kind = fkDiskFile then           // 存盘文件
      Lines2.LoadFromFile(FileName)
    else if Kind = fkBackupFile then       // 备份文件
      Lines2.LoadFromFile(GetBakFileName(FileName))
    else
    begin                               // 编辑器缓冲区
      Stream := TMemoryStream.Create;
      try
        EditFilerSaveFileToStream(FileName, Stream, True); // Ansi/Ansi/Utf16
        Lines2.Text := string(PChar(Stream.Memory));
      finally
        Stream.Free;
      end;
    end;
    DiffControl.Lines.Assign(Lines2);
  end;

  if OpenFile1 then
    OpenDialog1.InitialDir := _CnExtractFilePath(FileName)
  else
    OpenDialog2.InitialDir := _CnExtractFilePath(FileName);

  DiffControl.MaxLineNum := 1;
  DiffControl.TopVisibleLine := 0;
  DiffControl.HorzScroll := 0;
end;

procedure TCnSourceDiffForm.actOpen1Execute(Sender: TObject);
begin
  if FileName1 <> '' then
    OpenDialog1.InitialDir := _CnExtractFileDir(FileName1);

  if OpenDialog1.Execute then
  begin
    FileName1 := OpenDialog1.FileName;
    if History1.IndexOf(OpenDialog1.FileName) < 0 then
    begin
      History1.Insert(0, OpenDialog1.FileName);
      while History1.Count > csMaxHistory do
        History1.Delete(csMaxHistory);
    end;
    DoOpenFile(True);
  end;
end;

procedure TCnSourceDiffForm.actOpen2Execute(Sender: TObject);
begin
  OpenDialog2.Filter := OpenDialog1.Filter;
  OpenDialog2.FilterIndex := OpenDialog1.FilterIndex;

  if FileName2 <> '' then
    OpenDialog2.InitialDir := _CnExtractFileDir(FileName2);

  if OpenDialog2.Execute then
  begin
    FileName2 := OpenDialog2.FileName;
    if History2.IndexOf(OpenDialog2.FileName) < 0 then
    begin
      History2.Insert(0, OpenDialog2.FileName);
      while History2.Count > csMaxHistory do
        History2.Delete(csMaxHistory);
    end;
    DoOpenFile(False);
  end;
end;

procedure TCnSourceDiffForm.FileDrop(Sender: TObject; dropHandle: Integer; var DropHandled:
  Boolean);
var
  FileBuffer: array[0..MAX_PATH] of Char;
begin
  DropHandled := DragQueryFile(dropHandle, 0, @FileBuffer, MAX_PATH) > 0;

  if Sender = DiffControl1 then
    FileName1 := FileBuffer
  else
    FileName2 := FileBuffer;

  DoOpenFile(Sender = DiffControl1);
  SetForegroundWindow(Application.Handle);
end;

procedure TCnSourceDiffForm.DiffCtrlDblClick(Sender: TObject);
begin
  if Sender is TDiffControl then
  begin
    if not IsMerging then
      actGoto.Execute
    else
    begin
      if TDiffControl(Sender).FocusLength = 0 then Exit;
      if Sender = DiffControlMerge then
      begin
        //don't allow editing empty lines...
        with DiffControlMerge do
        begin
          if (FocusLength > 0) and (Lines.LineNum[FocusStart] <> 0) then
            actEditFocusedTextExecute(nil);
        end;
      end
      else
        actMergeFocusedTextExecute(nil);
    end;
  end;
end;

procedure TCnSourceDiffForm.DiffCtrlMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TCnSourceDiffForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnSourceDiffForm.actCompareExecute(Sender: TObject);
var
  I: Integer;
  HashList1, HashList2: TList;
  optionsStr: string;
begin
  FilesCompared := False;
  if (Lines1.Count = 0) or (Lines2.Count = 0) then Exit;

  if actIgnoreCase.Checked then
    optionsStr := SCnSourceDiffCaseIgnored;
  if actIgnoreBlanks.Checked then
  begin
    if optionsStr = '' then
      optionsStr := SCnSourceDiffBlanksIgnored
    else
      optionsStr := optionsStr + ', ' + SCnSourceDiffBlanksIgnored;
  end;

  if optionsStr <> '' then
    optionsStr := '  (' + optionsStr + ')';

  HashList1 := TList.Create;
  HashList2 := TList.Create;
  try
    // create the hash lists to compare...
    HashList1.capacity := Lines1.Count;
    HashList2.capacity := Lines2.Count;
    for I := 0 to Lines1.Count - 1 do
      HashList1.Add(HashLine(Lines1[I], actIgnoreCase.Checked,
        actIgnoreBlanks.Checked));
    for I := 0 to Lines2.Count - 1 do
      HashList2.Add(HashLine(Lines2[I], actIgnoreCase.Checked,
        actIgnoreBlanks.Checked));

    screen.cursor := crHourglass;
    try
      actCancel.Enabled := True;
      // CALCULATE THE DIFFS HERE ...
      if not Diff.Execute(PIntArray(HashList1.List), PIntArray(HashList2.List),
        HashList1.Count, HashList2.Count) then
        Exit;
      FilesCompared := True;
      DisplayDiffs;
    finally
      screen.cursor := crDefault;
      actCancel.Enabled := False;
    end;

    Statusbar1.Panels[3].Text := Format(SCnSourceDiffChanges, [Diff.ChangeCount,
      optionsStr]);
  finally
    HashList1.Free;
    HashList2.Free;
  end;
end;

procedure TCnSourceDiffForm.actCompareExExecute(Sender: TObject);
begin
  DoOpenFile(True);
  DoOpenFile(False);
  actCompare.Execute;
end;

procedure TCnSourceDiffForm.DiffProgress(Sender: TObject; percent: Integer);
begin
  Statusbar1.Panels[3].Text := Format(SCnSourceDiffApprox, [percent]);
  Statusbar1.Refresh;
end;

procedure TCnSourceDiffForm.DisplayDiffs;
var
  I, J, K: Integer;
begin
  DiffControl1.Lines.BeginUpdate;
  DiffControl2.Lines.BeginUpdate;
  try
    DiffControl1.Lines.Clear;
    DiffControl2.Lines.Clear;
    DiffControl1.MaxLineNum := Lines1.Count;
    DiffControl2.MaxLineNum := Lines2.Count;

    J := 0;
    K := 0;
    with Diff do
    begin
      for I := 0 to ChangeCount - 1 do
      begin
        with Changes[I] do
        begin
          // first add preceeding unmodified lines...
          if actShowDiffOnly.Checked then
            Inc(K, x - J)
          else
          begin
            while J < x do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[J], J + 1, 0);
              DiffControl2.Lines.AddLineInfo(lines2[K], K + 1, 0);
              Inc(J);
              Inc(K);
            end;
          end;

          if Kind = ckAdd then
          begin
            for J := K to K + Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo('', 0, colorAdd);
              DiffControl2.Lines.AddLineInfo(lines2[J], J + 1, colorAdd);
            end;
            J := x;
            K := y + Range;
          end else if Kind = ckModify then
          begin
            for J := 0 to Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[x + J], x + J + 1, colorMod);
              DiffControl2.Lines.AddLineInfo(lines2[K + J], K + J + 1, colorMod);
            end;
            J := x + Range;
            K := y + Range;
          end
          else
          begin
            for J := x to x + Range - 1 do
            begin
              DiffControl1.Lines.AddLineInfo(lines1[J], J + 1, colorDel);
              DiffControl2.Lines.AddLineInfo('', 0, colorDel);
            end;
            J := x + Range;
          end;
        end;
      end;
    end;

    // add remaining unmodified lines...
    if not actShowDiffOnly.Checked then
    begin
      while J < lines1.Count do
      begin
        DiffControl1.Lines.AddLineInfo(lines1[J], J + 1, 0);
        DiffControl2.Lines.AddLineInfo(lines2[K], K + 1, 0);
        Inc(J);
        Inc(K);
      end;
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

procedure TCnSourceDiffForm.actIgnoreBlanksExecute(Sender: TObject);
begin
  actIgnoreBlanks.Checked := not actIgnoreBlanks.Checked;
  if FilesCompared then
    actCompare.Execute;
end;

procedure TCnSourceDiffForm.actIgnoreCaseExecute(Sender: TObject);
begin
  actIgnoreCase.Checked := not actIgnoreCase.Checked;
  if FilesCompared then
    actCompare.Execute;
end;

procedure TCnSourceDiffForm.actShowDiffOnlyExecute(Sender: TObject);
begin
  actShowDiffOnly.Checked := not actShowDiffOnly.Checked;
  // if files have already been compared then refresh the changes
  // as long as no merge has been atarted ...
  if FilesCompared and not IsMerging then
    DisplayDiffs;
end;

procedure TCnSourceDiffForm.actFontExecute(Sender: TObject);
begin
  FontDialog.Font := DiffControl1.Font;
  if not FontDialog.Execute then
    Exit;
  DiffControl1.Font := FontDialog.Font;
  DiffControl2.Font := FontDialog.Font;
  DiffControlMerge.Font := FontDialog.Font;
end;

procedure TCnSourceDiffForm.SetSplitHorizontally(SplitHorizontally: Boolean);
begin
  if SplitHorizontally then
  begin
    pnlLeft.Align := alTop;
    pnlLeft.Height := pnlMain.ClientHeight div 2 - 1;
    Splitter1.Align := alTop;
    Splitter1.cursor := crVSplit;
  end else
  begin
    pnlLeft.Align := alLeft;
    pnlLeft.Width := pnlMain.ClientWidth div 2 - 1;
    Splitter1.Align := alLeft;
    Splitter1.Left := 10;
    Splitter1.cursor := crHSplit;
  end;
end;

procedure TCnSourceDiffForm.actSplitHorizontallyExecute(Sender: TObject);
begin
  actSplitHorizontally.Checked := not actSplitHorizontally.Checked;
  SetSplitHorizontally(actSplitHorizontally.Checked);
end;

procedure TCnSourceDiffForm.UpdateFileBmp;
var
  I, J, Y1, Y2: Integer;
  clrIndex: Integer;
  HeightRatio: single;
begin
  if (DiffControl1.Lines.Count = 0) or (DiffControl2.Lines.Count = 0) then
    Exit;
  HeightRatio := Screen.Height / DiffControl1.Lines.Count;

  FileBmp.Height := Screen.Height;
  FileBmp.Width := pbFile.ClientWidth;
  FileBmp.Canvas.Pen.Width := 2;
  FileBmp.Canvas.Brush.Color := clWhite;
  FileBmp.Canvas.FillRect(Rect(0, 0, FileBmp.Width, FileBmp.Height));

  with DiffControl1 do
  begin
    I := 0;
    while I < Lines.Count do
    begin
      clrIndex := Lines.ColorIndex[I];
      if clrIndex = 0 then
        Inc(I)
      else
      begin
        J := I + 1;
        while (J < Lines.Count) and (Lines.ColorIndex[J] = Lines.ColorIndex[I]) do
          Inc(J);
        FileBmp.Canvas.Brush.Color := LineColors[clrIndex];
        Y1 := Trunc(I * HeightRatio);
        Y2 := Trunc(J * HeightRatio);
        FileBmp.Canvas.FillRect(Rect(0, Y1, FileBmp.Width, Y2));
        I := J;
      end;
    end;
  end;
  pbFile.Invalidate;
end;

procedure TCnSourceDiffForm.pbFileMouseDown(Sender: TObject;
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

procedure TCnSourceDiffForm.pbFilePaint(Sender: TObject);
begin
  with pbFile do
    Canvas.StretchDraw(Rect(0, 0, Width, Height), FileBmp);
end;

procedure TCnSourceDiffForm.pbPosPaint(Sender: TObject);
var
  yPos: Integer;
begin
  if DiffControl1.Lines.Count = 0 then
    Exit;

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

procedure TCnSourceDiffForm.RepaintControls;
begin
  DiffControl1.Repaint;
  DiffControl2.Repaint;
  UpdateFileBmp;
  pbFile.Repaint;
  //pbPos.Repaint;
  StatusBar1.Repaint;
end;

procedure TCnSourceDiffForm.actAddColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorAdd];
    if not Execute then
      Exit;

    DiffControl1.LineColors[colorAdd] := Color;
    DiffControl2.LineColors[colorAdd] := Color;
    DiffControlMerge.LineColors[colorAdd] := Color;
  end;
  RepaintControls;
end;

procedure TCnSourceDiffForm.actModColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorMod];
    if not Execute then
      Exit;

    DiffControl1.LineColors[colorMod] := Color;
    DiffControl2.LineColors[colorMod] := Color;
    DiffControlMerge.LineColors[colorMod] := Color;
  end;
  RepaintControls;
end;

procedure TCnSourceDiffForm.actDelColorExecute(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := DiffControl1.LineColors[colorDel];
    if not Execute then
      Exit;

    DiffControl1.LineColors[colorDel] := Color;
    DiffControl2.LineColors[colorDel] := Color;
    DiffControlMerge.LineColors[colorDel] := Color;
  end;
  RepaintControls;
end;

procedure TCnSourceDiffForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  case Panel.Index of
    0: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorAdd];
    1: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorMod];
    2: StatusBar1.Canvas.Brush.Color := DiffControl1.LineColors[colorDel];
  else
    Exit;
  end;

  StatusBar1.Canvas.FillRect(Rect);
  StatusBar1.Canvas.TextOut(Rect.Left + 4, Rect.Top, Panel.Text);
end;

procedure TCnSourceDiffForm.actCancelExecute(Sender: TObject);
begin
  Diff.Cancel;
end;

procedure TCnSourceDiffForm.actMergeFromExecute(Sender: TObject);
var
  I: Integer;
begin
  DiffControl1.UseFocusRect := True;
  DiffControl2.UseFocusRect := True;
  DiffControlMerge.UseFocusRect := True;
  if (Sender = actMergeFromFile1) or (Sender = actMergeFromNeither) then
  begin
    DiffControlMerge.Lines.Assign(DiffControl1.Lines);
    DiffControlMerge.MaxLineNum := Lines1.Count;
    if (Sender = actMergeFromNeither) then
    begin
      with DiffControlMerge.Lines do
      begin
        BeginUpdate;
        for I := 0 to Count - 1 do
          if ColorIndex[I] <> 0 then Strings[I] := '';
        EndUpdate;
      end;
    end;
  end
  else
  begin
    DiffControlMerge.Lines.Assign(DiffControl2.Lines);
    DiffControlMerge.MaxLineNum := Lines2.Count;
  end;

  pnlMerge.Visible := True;
  if actSplitHorizontally.Checked then
  begin
    pnlMerge.Height := (ClientHeight -
      statusbar1.Height - pnlCaptionLeft.Height) div 3;
    pnlLeft.Height := pnlMerge.Height;
  end
  else
    pnlMerge.Height := (ClientHeight -
      statusbar1.Height - pnlCaptionLeft.Height) div 2;

  pnlMerge.Top := 1;                    // force pnlMerge above statusbar
  Splitter2.Visible := True;
  Splitter2.Top := 0;                   // force Splitter2 above pnlMerge
  DiffControlMerge.OnScroll := SyncScroll;
  SyncScroll(DiffControl1);
end;

procedure TCnSourceDiffForm.actMergeFocusedTextExecute(Sender: TObject);
var
  I: Integer;
  DiffControl: TDiffControl;
begin
  if DiffControl1.Focused then
    DiffControl := DiffControl1 else
    DiffControl := DiffControl2;
  with DiffControl do
  begin
    if FocusLength <= 0 then
      Exit;

    for I := FocusStart to FocusStart + FocusLength - 1 do
    begin
      DiffControlMerge.Lines[I] := Lines[I];
      DiffControlMerge.Lines.LineNum[I] := Lines.LineNum[I];
    end;
  end;
end;

procedure TCnSourceDiffForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  DiffControl: TDiffControl;
begin
  actCompare.Enabled := ((FileName1 <> '') and (FileName2 <> '')) or
    ((DiffControl1.Lines.Text <> '') and (DiffControl2.Lines.Text <> ''));
  actCompareEx.Enabled := (FileName1 <> '') and (FileName2 <> '');
  actSaveMerged.Enabled := IsMerging;
  actNextDiff.Enabled := FilesCompared;
  actPrioDiff.Enabled := FilesCompared;

  actShowDiffOnly.Enabled := not IsMerging;

  mnuMergeOptions.Enabled := FilesCompared and not IsMerging and
    not actShowDiffOnly.Checked;
  tbMerge.Enabled := mnuMergeOptions.Enabled;
  actGoto.Enabled := (ActiveControl = DiffControl1) and (FileName1 <> '') or
    (ActiveControl = DiffControl2) and (FileName2 <> '');

  if not IsMerging then
  begin
    actEditFocusedText.Enabled := False;
    actMergeFocusedText.Enabled := False;
    Exit;
  end;

  if DiffControl1.Focused then
    DiffControl := DiffControl1
  else if DiffControl2.Focused then
    DiffControl := DiffControl2
  else
    DiffControl := DiffControlMerge;

  if (DiffControl.FocusLength = 0) or
    ((DiffControl = DiffControlMerge) and
    (DiffControlMerge.Lines.LineNum[DiffControlMerge.FocusStart] = 0)) then
  begin
    actEditFocusedText.Enabled := False;
    actMergeFocusedText.Enabled := False;
    Exit;
  end;

  actEditFocusedText.Enabled := DiffControl = DiffControlMerge;
  actMergeFocusedText.Enabled := DiffControl <> DiffControlMerge;
  actPaste1.Enabled := Clipboard.AsText <> '';
  actPaste2.Enabled := actPaste1.Enabled;
end;

procedure TCnSourceDiffForm.actSaveMergedExecute(Sender: TObject);
var
  I: Integer;
begin
  SaveDialog.InitialDir := OpenDialog1.InitialDir;
  if not SaveDialog.Execute then
    Exit;

  with TStringList.Create do
  try
    BeginUpdate;
    // todo - watch out for merges with ShowDiffsOnly checked!!!
    for I := 0 to DiffControlMerge.Lines.Count - 1 do
    begin
      if DiffControlMerge.Lines.LineNum[I] > 0 then
        Add(DiffControlMerge.Lines[I]);
    end;

    EndUpdate;
    SaveToFile(SaveDialog.FileName);
  finally
    Free;
  end;
end;

procedure TCnSourceDiffForm.actEditFocusedTextExecute(Sender: TObject);
var
  I, OldLineNum, OldClrIdx: Integer;
begin
  with TCnDiffEditorForm.Create(Self) do
  try
    Icon := Self.Icon;
    Width := Self.ClientWidth - 20;
    ClientHeight := Min(65 +
      (DiffControlMerge.LineHeight + 1) * DiffControlMerge.FocusLength,
      DiffControlMerge.Height);
    Memo.Font.Assign(DiffControlMerge.Font);

    with DiffControlMerge do
      Memo.Color := LineColors[Lines.ColorIndex[FocusStart]];

    Memo.Lines.BeginUpdate;
    with DiffControlMerge do
    begin
      for I := FocusStart to FocusStart + FocusLength - 1 do
        Memo.Lines.Add(Lines[I]);
    end;
    Memo.Lines.EndUpdate;

    Memo.SelStart := 0;
    Memo.Modified := False;

    if (ShowModal <> mrOK) or not Memo.Modified then
      Exit;

    with DiffControlMerge do
    begin
      OldLineNum := Lines.LineNum[FocusStart];
      OldClrIdx := Lines.ColorIndex[FocusStart];
      Lines.BeginUpdate;
      //for the moment the no. of lines after editing must remain the same...
      while Memo.Lines.Count < FocusLength do Memo.Lines.Add('');
      for I := 1 to FocusLength do Lines.Delete(FocusStart);
      for I := FocusLength - 1 downto 0 do
        Lines.InsertLineInfo(FocusStart, Memo.Lines[I], OldLineNum + I, OldClrIdx);
      Lines.EndUpdate;
    end;
  finally
    Free;
  end;
end;

procedure TCnSourceDiffForm.pnlCaptionLeftResize(Sender: TObject);
begin
  btnHistory1.Left := pnlCaptionLeft.Width - btnHistory1.Width - 1;
  btnFileKind1.Left := btnHistory1.Left - btnFileKind1.Width;
  btnOpenFile1.Left := btnFileKind1.Left - btnOpenFile1.Width;
  btnPaste1.Left := btnOpenFile1.Left - btnPaste1.Width;
end;

procedure TCnSourceDiffForm.pnlCaptionRightResize(Sender: TObject);
begin
  btnHistory2.Left := pnlCaptionRight.Width - btnHistory2.Width - 1;
  btnFileKind2.Left := btnHistory2.Left - btnFileKind2.Width;
  btnOpenFile2.Left := btnFileKind2.Left - btnOpenFile2.Width;
  btnPaste2.Left := btnOpenFile2.Left - btnPaste2.Width;
end;

procedure TCnSourceDiffForm.StatusBar1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if (X >= 0) and (X <= StatusBar1.Panels[0].Width * 3) and (Y >= 0) and
    (Y <= StatusBar1.ClientHeight) and (Button = mbLeft) then
  begin
    I := X div StatusBar1.Panels[0].Width + 1;
    if I = colorAdd then
      actAddColor.Execute
    else if I = colorMod then
      actModColor.Execute
    else if I = colorDel then
      actDelColor.Execute;
  end;
end;

procedure TCnSourceDiffForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSourceDiffForm.GetHelpTopic: string;
begin
  Result := 'CnSourceDiffWizard';
end;

procedure TCnSourceDiffForm.DoPopupMenu(Btn: TBitBtn; Menu: TPopupMenu);
var
  P: TPoint;
begin
  P := Btn.ClientToScreen(Point(0, Btn.Height));
  Menu.Popup(P.x, P.y);
end;

procedure TCnSourceDiffForm.btnFileKind1Click(Sender: TObject);
begin
  DoPopupMenu(btnFileKind1, pmFileKind1);
end;

procedure TCnSourceDiffForm.btnHistory1Click(Sender: TObject);
begin
  DoPopupMenu(btnHistory1, pmHistory1);
end;

procedure TCnSourceDiffForm.btnFileKind2Click(Sender: TObject);
begin
  DoPopupMenu(btnFileKind2, pmFileKind2);
end;

procedure TCnSourceDiffForm.btnHistory2Click(Sender: TObject);
begin
  DoPopupMenu(btnHistory2, pmHistory2);
end;

function TCnSourceDiffForm.GetBakFileName(const FileName: string): string;
begin
  Result := _CnExtractFilePath(FileName) + StringReplace(_CnExtractFileName(FileName),
    '.', '.~', [rfReplaceAll]);
end;

function TCnSourceDiffForm.GetFileKinds(
  const FileName: string): TFileKinds;
var
  FModIntf: IOTAModule;
begin
  Result := [];
  // 源文件存在
  if FileExists(FileName) then Include(Result, fkDiskFile);

  // 备份文件存在
  if FileExists(GetBakFileName(FileName)) then Include(Result, fkBackupFile);

  // 文件在IDE中打开
  FModIntf := CnOtaGetModule(FileName);
  if FModIntf <> nil then
    if CnOtaGetSourceEditorFromModule(FModIntf, FileName) <> nil then
      Include(Result, fkEditorBuff);
end;

procedure TCnSourceDiffForm.SetFileKind1(const Value: TFileKind);
begin
  if Value <> FFileKind1 then
  begin
    if FileName1 <> '' then
    begin
      if Value in GetFileKinds(FileName1) then
      begin
        FFileKind1 := Value;
        btnFileKind1.Caption := csFileKinds[Value];
        DoOpenFile(True);
      end
    end
    else
    begin
      FFileKind1 := Value;
      btnFileKind1.Caption := csFileKinds[Value];
    end;
  end;
end;

procedure TCnSourceDiffForm.SetFileKind2(const Value: TFileKind);
begin
  if Value <> FFileKind2 then
  begin
    if FileName2 <> '' then
    begin
      if Value in GetFileKinds(FileName2) then
      begin
        FFileKind2 := Value;
        btnFileKind2.Caption := csFileKinds[Value];
        DoOpenFile(False);
      end
    end
    else
    begin
      FFileKind2 := Value;
      btnFileKind2.Caption := csFileKinds[Value];
    end;
  end;
end;

procedure TCnSourceDiffForm.pmFileKind1Popup(Sender: TObject);
var
  Kinds: TFileKinds;
begin
  Kinds := GetFileKinds(FileName1);
  pmiDiskFile1.Checked := FileKind1 = fkDiskFile;
  pmiDiskFile1.Enabled := (fkDiskFile in Kinds) or (FileName1 = '');
  pmiEditorBuff1.Checked := FileKind1 = fkEditorBuff;
  pmiEditorBuff1.Enabled := (fkEditorBuff in Kinds) or (FileName1 = '');
  pmiBackupFile1.Checked := FileKind1 = fkBackupFile;
  pmiBackupFile1.Enabled := (fkBackupFile in Kinds) or (FileName1 = '');
end;

procedure TCnSourceDiffForm.pmFileKind2Popup(Sender: TObject);
var
  Kinds: TFileKinds;
begin
  Kinds := GetFileKinds(FileName2);
  pmiDiskFile2.Checked := FileKind2 = fkDiskFile;
  pmiDiskFile2.Enabled := (fkDiskFile in Kinds) or (FileName2 = '');
  pmiEditorBuff2.Checked := FileKind2 = fkEditorBuff;
  pmiEditorBuff2.Enabled := (fkEditorBuff in Kinds) or (FileName2 = '');
  pmiBackUpFile2.Checked := FileKind2 = fkBackupFile;
  pmiBackUpFile2.Enabled := (fkBackupFile in Kinds) or (FileName2 = '');
end;

procedure TCnSourceDiffForm.pmiDiskFile1Click(Sender: TObject);
begin
  if Sender is TMenuItem then
    FileKind1 := TFileKind(TMenuItem(Sender).Tag);
end;

procedure TCnSourceDiffForm.pmiDiskFile2Click(Sender: TObject);
begin
  if Sender is TMenuItem then
    FileKind2 := TFileKind(TMenuItem(Sender).Tag);
end;

const
  csOpenIndex = 1;
  csUpdateIndex = 2;
  csUnitIndex = 100;
  csHistoryIndex = 200;

procedure TCnSourceDiffForm.UpdateHistoryMenu(Menu: TPopupMenu;
  History: TStrings; OnClick: TNotifyEvent; IsEmpty: Boolean);
var
  iModuleServices: IOTAModuleServices;
  I: Integer;
  FileName: string;

  procedure CreateItem(const Caption: string; Tag: Integer; AOnClick: TNotifyEvent);
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(Menu);
    Item.Caption := Caption;
    Item.OnClick := AOnClick;
    Item.Tag := Tag;
    Menu.Items.Add(Item);
  end;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);

  Menu.Items.Clear;
  UnitList.Clear;

  CreateItem(SCnSourceDiffOpenFile, csOpenIndex, OnClick);
  if not IsEmpty then
    CreateItem(SCnSourceDiffUpdateFile, csUpdateIndex, OnClick);
  CreateItem('-', -1, nil);

  for I := 0 to iModuleServices.GetModuleCount - 1 do
  begin
    FileName := CnOtaGetFileNameOfModule(iModuleServices.GetModule(I));
    UnitList.Add(FileName);
    CreateItem(FileName, csUnitIndex + I, OnClick);
  end;

  CreateItem('-', -1, nil);

  for I := 0 to History.Count - 1 do
    CreateItem(History[I], csHistoryIndex + I, OnClick);
end;

procedure TCnSourceDiffForm.pmHistory1Popup(Sender: TObject);
begin
  UpdateHistoryMenu(pmHistory1, History1, OnHistory1Click, FileName1 = '');
end;

procedure TCnSourceDiffForm.pmHistory2Popup(Sender: TObject);
begin
  UpdateHistoryMenu(pmHistory2, History2, OnHistory2Click, FileName2 = '');
end;

procedure TCnSourceDiffForm.OnHistory1Click(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    with TMenuItem(Sender) do
    begin
      if Tag >= csHistoryIndex then
      begin
        FileName1 := History1[Tag - csHistoryIndex];
        DoOpenFile(True);
      end
      else if Tag >= csUnitIndex then
      begin
        FileName1 := UnitList[Tag - csUnitIndex];
        DoOpenFile(True);
      end
      else if Tag = csOpenIndex then
      begin
        actOpen1.Execute;
      end
      else if Tag = csUpdateIndex then
      begin
        DoOpenFile(True);
      end;
    end;
  end;
end;

procedure TCnSourceDiffForm.OnHistory2Click(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    with TMenuItem(Sender) do
    begin
      if Tag >= csHistoryIndex then
      begin
        FileName2 := History2[Tag - csHistoryIndex];
        DoOpenFile(False);
      end
      else if Tag >= csUnitIndex then
      begin
        FileName2 := UnitList[Tag - csUnitIndex];
        DoOpenFile(False);
      end
      else if Tag = csOpenIndex then
      begin
        actOpen2.Execute;
      end
      else if Tag = csUpdateIndex then
      begin
        DoOpenFile(False);
      end;
    end;
  end;
end;

function TCnSourceDiffForm.GetFileName1: string;
begin
  Result := Trim(pnlCaptionLeft.Caption);
end;

function TCnSourceDiffForm.GetFileName2: string;
begin
  Result := Trim(pnlCaptionRight.Caption);
end;

procedure TCnSourceDiffForm.SetFileName1(const Value: string);
begin
  pnlCaptionLeft.Caption := '  ' + Value;
end;

procedure TCnSourceDiffForm.SetFileName2(const Value: string);
begin
  pnlCaptionRight.Caption := '  ' + Value;
end;

procedure TCnSourceDiffForm.actNextDiffExecute(Sender: TObject);
begin
  if ActiveControl is TDiffControl then
    TDiffControl(ActiveControl).GotoNextDiff
  else
    DiffControl1.GotoNextDiff;
end;

procedure TCnSourceDiffForm.actPrioDiffExecute(Sender: TObject);
begin
  if ActiveControl is TDiffControl then
    TDiffControl(ActiveControl).GotoPrioDiff
  else
    DiffControl1.GotoPrioDiff;
end;

procedure TCnSourceDiffForm.tbMergeClick(Sender: TObject);
begin
  tbMerge.CheckMenuDropdown;
end;

function TCnSourceDiffForm.GetIsMerging: Boolean;
begin
  Result := pnlMerge.Visible;
end;

procedure TCnSourceDiffForm.SetFilesCompared(const Value: Boolean);
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
    pnlMerge.Visible := False;
  end;
end;

procedure TCnSourceDiffForm.actGotoExecute(Sender: TObject);

  procedure GotoSourceEditor(DiffControl: TDiffControl; const FileName: string);
  var
    P: TPoint;
    I, y: Integer;
  begin
    GetCursorPos(P);
    P := DiffControl.ScreenToClient(P);
    P := DiffControl.ClientPtToTextPoint(P);
    I := P.y;

    if FilesCompared then
    begin
      // 向前查找有效的行号
      if DiffControl.Lines.LineNum[I] = 0 then
        while (I > 0) and (DiffControl.Lines.LineNum[I] = 0) do
        Dec(I);

      // 向后查找有效的行号
      if DiffControl.Lines.LineNum[I] = 0 then
      begin
        I := P.y;
        while (I < DiffControl.Lines.Count - 1) and
         (DiffControl.Lines.LineNum[I] = 0) do
         Inc(I);
      end;

      // 在编辑器中打开
      if DiffControl.Lines.LineNum[I] > 0 then
        y := DiffControl.Lines.LineNum[I]
      else
        y := 0;
    end
    else
      y := P.y;

    CnOtaMakeSourceVisible(FileName, y);
    Close;
  end;
begin
  if (ActiveControl = DiffControl1) and (FileName1 <> '') then
  begin
    if FileKind1 = fkBackupFile then
      GotoSourceEditor(DiffControl1, GetBakFileName(FileName1))
    else
      GotoSourceEditor(DiffControl1, FileName1);
  end
  else if (ActiveControl = DiffControl2) and (FileName2 <> '') then
  begin
    if FileKind1 = fkBackupFile then
      GotoSourceEditor(DiffControl2, GetBakFileName(FileName2))
    else
      GotoSourceEditor(DiffControl2, FileName2);
  end;
end;

procedure TCnSourceDiffForm.DoLanguageChanged(Sender: TObject);
begin
  csFileKinds[fkDiskFile] := SCnDiskFile;
  csFileKinds[fkEditorBuff] := SCnEditorBuff;
  csFileKinds[fkBackupFile] := SCnBackupFile;

  // 用 Caption 变化来修补工具栏按钮可能错乱的问题
  ToolBar.ShowCaptions := True;
  ToolBar.ShowCaptions := False;

  // 用尺寸的变化来修补工具栏按钮可能消失的问题
  Self.Width := Self.Width + 1;
  Self.Width := Self.Width - 1;
end;

procedure TCnSourceDiffForm.actPaste1Execute(Sender: TObject);
var
  S: string;
begin
  S := Clipboard.AsText;
  if S <> '' then
  begin
    Lines1.Text := S;
    DiffControl1.Lines.Assign(Lines1);
  end;
end;

procedure TCnSourceDiffForm.actPaste2Execute(Sender: TObject);
var
  S: string;
begin
  S := Clipboard.AsText;
  if S <> '' then
  begin
    Lines2.Text := S;
    DiffControl2.Lines.Assign(Lines2);
  end;
end;

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}
end.

