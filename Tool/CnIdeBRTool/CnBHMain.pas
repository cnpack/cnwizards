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

unit CnBHMain;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家辅助备份/恢复工具
* 单元名称：CnWizards 辅助备份/恢复工具主窗体单元
* 单元作者：ccRun(老妖)
* 备    注：CnWizards 专家辅助备份/恢复工具主窗体单元
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 已知问题：XE以及以上版本的代码模板分目录存储了，备份会失败
* 修改记录：2006.08.23 V1.0
*               LiuXiao 移植此单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Registry,
  Dialogs, ExtCtrls, StdCtrls, Buttons, CnAppBuilderInfo, ComCtrls, CheckLst,
  ImgList, ShellApi, CleanClass, CnCommon, CnWizCompilerConst, CnWizMultiLang, 
  CnBHConst, CnLangMgr, CnLangStorage, CnHashLangStorage, CnClasses, CnWizLangID,
  CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnIdeBRMainForm = class(TCnTranslateForm)
    btnNext: TBitBtn;
    btnAbout: TBitBtn;
    bvlLine: TBevel;
    pnlTop: TPanel;
    bvlLineTop: TBevel;
    btnClose: TBitBtn;
    imgIcon: TImage;
    lblFun: TLabel;
    lblDesc: TLabel;
    btnPrev: TBitBtn;
    pgcMain: TPageControl;
    tsFirst: TTabSheet;
    tsBackup: TTabSheet;
    tsRestore: TTabSheet;
    tsResult: TTabSheet;
    lbl1: TLabel;
    rbBackup: TRadioButton;
    rbRestore: TRadioButton;
    lbl2: TLabel;
    edtBackupFile: TEdit;
    lbl3: TLabel;
    btnBrowBackupFile: TBitBtn;
    lbl4: TLabel;
    lbl5: TLabel;
    edtRestoreFile: TEdit;
    btnBrowRestoreFile: TBitBtn;
    lbl6: TLabel;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    lbxBackupOptions: TCheckListBox;
    lbxRestoreOptions: TCheckListBox;
    il16: TImageList;
    mmoLog: TMemo;
    tsSelectApp: TTabSheet;
    lbl7: TLabel;
    lbxSelectApp: TListBox;
    lbl8: TLabel;
    tsPreRestore: TTabSheet;
    mmoBakFileInfo: TMemo;
    lbl9: TLabel;
    edtRestoreRootPath: TEdit;
    chkSaveUsrObjRep2Sys: TCheckBox;
    rbOther: TRadioButton;
    tsOther: TTabSheet;
    lbl10: TLabel;
    lblProjects: TLabel;
    lblFiles: TLabel;
    lblIDEs: TLabel;
    btnSelAllIDE: TSpeedButton;
    btnSelAllProj: TSpeedButton;
    btnSelAllFile: TSpeedButton;
    lstIDEs: TCheckListBox;
    lstProjects: TCheckListBox;
    lstFiles: TCheckListBox;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    lbl11: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    btnHelp: TBitBtn;
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tsBackupShow(Sender: TObject);
    procedure btnBrowRestoreFileClick(Sender: TObject);
    procedure btnBrowBackupFileClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure MyDrawCheckListBoxItem(Control: TWinControl;
      Index: Integer; Rect: TRect; AState: TOwnerDrawState);
    procedure MyDrawRadioListBoxItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbxBackupOptionsClick(Sender: TObject);
    procedure lbxRestoreOptionsClickCheck(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbxSelectAppClick(Sender: TObject);
    procedure TabSheetShow(Sender: TObject);

    procedure btnSelAllIDEClick(Sender: TObject);
    procedure btnSelAllProjClick(Sender: TObject);
    procedure btnSelAllFileClick(Sender: TObject);
    procedure lstIDEsClick(Sender: TObject);
    procedure lstIDEsClickCheck(Sender: TObject);
    procedure lstProjectsClickCheck(Sender: TObject);
    procedure lstFilesClickCheck(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure pgcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnHelpClick(Sender: TObject);
  private
    m_bCanClose: Boolean;
    m_atRestore: TAbiType;
    FDone: Boolean;

    FOldSel: Integer;
    function GetEntryValue(const AValue: string): string;
    procedure LoadHistories;
    procedure UpdateToList;
    procedure UpdateToHisEntries(ListBox: TCheckListBox; His: TCnHisEntries);
    procedure SelAllListBox(ListBox: TCheckListBox);
    procedure CleanHis;

    procedure WMDropFiles(var Msg: TWMDropFiles);
    procedure ParseFileAndNotifyUI(strBakFile: String);
    function MyValidLbxItemChecked(lbx: TCheckListBox): boolean;
    procedure lstProjectsFilesClickCheck(Sender: TObject);

    function GetRegIDEBase(IDE: TCnCompiler): string;
  protected
    procedure DoCreate; override;
    procedure DoLanguageChanged(Sender: TObject); override;
    function GetHelpTopic: string; override;
    procedure DoHelpError; override;
    function NeedAdjustRightBottomMargin: Boolean; override;
  public
    procedure TranslateStrings;
    procedure WndProc(var Message: TMessage); override;
  end;

var
  CnIdeBRMainForm: TCnIdeBRMainForm;

implementation

{$R *.dfm}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  SCnRegIDEBase = '\Software\Borland\';
  SCnRegIDEBase12 = '\Software\CodeGear\';
  SCnRegIDEBase15 = '\Software\Embarcadero\';

  SACnRegIDEEntries: array[TCnCompiler] of string =
    ('Delphi\5.0', 'Delphi\6.0', 'Delphi\7.0', 'BDS\2.0', 'BDS\3.0', 'BDS\4.0',
    'BDS\5.0', 'BDS\6.0', 'BDS\7.0', 'BDS\8.0', 'BDS\9.0', 'BDS\10.0', 'BDS\11.0',
    'BDS\12.0', 'BDS\14.0', 'BDS\15.0', 'BDS\16.0', 'BDS\17.0', 'BDS\18.0', 'BDS\19.0',
    'BDS\20.0', 'BDS\21.0', 'BDS\22.0', 'BDS\23.0', 'C++Builder\5.0', 'C++Builder\6.0');
  SCnRegHisProject = '\Closed Projects';
  SCnRegHisFiles = '\Closed Files';

var
  FIDERunning: Boolean = False;

// 窗体创建时-------------------------------------------------------------------
procedure TCnIdeBRMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
  strRootDir: String;
begin
  m_bCanClose := True;
  // 使窗体可接受文件拖放
  DragAcceptFiles(Handle, True);
  //
  Application.Title := g_strAppTitle + g_strAppVer;
  Caption := Application.Title;
  pgcMain.SendToBack;
  pgcMain.ActivePageIndex := 0;

  // 查看系统中已安装的 AppBuilder
  for I := Ord(Low(TAbiType)) to Ord(High(TAbiType)) do
  begin
    strRootDir := GetAppRootDir(TAbiType(I));
    if strRootDir <> '' then
    begin
      lbxSelectApp.Items.AddObject(Format('%-20s ( %s )',[g_strAppName[I], strRootDir]), TObject(1));
    end
    else
    begin
      lbxSelectApp.Items.AddObject(Format('%-20s ( %s )',[g_strAppName[I], g_strNotInstalled]), TObject(0));
    end;
  end;

  for I := Ord(Low(TAbiType)) to Ord(High(TAbiType)) do
  begin
    if FindCmdLineSwitch('I' + g_strAppAbName[I], ['-', '/'], True) then
      if lbxSelectApp.Items.Objects[I] = TObject(1) then
        lbxSelectApp.ItemIndex := I;
  end;

  for I := 0 to Length(g_strAbiOptions) - 1 do
  begin
    lbxBackupOptions.Items.Add(g_strAbiOptions[I]);
    lbxRestoreOptions.Items.Add(g_strAbiOptions[I]);
  end;
end;

// 下一步-----------------------------------------------------------------------
procedure TCnIdeBRMainForm.btnNextClick(Sender: TObject);
var
  i: Integer;
  m_abi: TAppBuilderInfo;
begin
  if pgcMain.ActivePage = tsFirst then
  begin
    if rbBackup.Checked then
    begin
      pgcMain.ActivePage := tsSelectApp;
      lbxBackupOptions.ItemIndex := -1;
    end
    else if rbRestore.Checked then
    begin
      // 切换到准备恢复的页面时清空备份文件的信息
      edtRestoreFile.Text := '';
      mmoBakFileInfo.Lines.Clear;
      lbxRestoreOptions.Enabled := False;
      for I := 0 to lbxRestoreOptions.Items.Count - 1 do
        lbxRestoreOptions.Checked[I] := False;
      pgcMain.ActivePage := tsPreRestore;
    end
    else if rbOther.Checked then
    begin
      pgcMain.ActivePage := tsOther;
      CreateIDEHistories;
      LoadHistories;
      UpdateToList;
    end;
  end
  else if pgcMain.ActivePage = tsSelectApp then
  begin
    with lbxSelectApp do
    begin
      if (ItemIndex = -1) or (Integer(Items.Objects[ItemIndex]) = 0) then
      begin
        Application.MessageBox(PChar(g_strErrorSelectApp),
          PChar(g_strAppTitle), MB_OK or MB_ICONWARNING);
        exit;
      end;
    end;
//    备份时似乎 IDE 在运行也不要紧？
//    if IsAppBuilderRunning(TAbiType(lbxSelectApp.ItemIndex)) then
//    begin
//      ErrorDlg(Format(g_strErrorIDERunningFmt, [g_strAppName[lbxSelectApp.ItemIndex]]);
//      Exit;
//    end;
    for I := 0 to lbxBackupOptions.Items.Count - 1 do
      lbxBackupOptions.Checked[I] := True;

    // BDS 2005 以上的菜单模板和对象库不分开了。
    if lbxSelectApp.ItemIndex >= Ord(atBDS2005) then
    begin
      lbxBackupOptions.Checked[0] := True;
      lbxBackupOptions.ItemEnabled[0] := False;
    end
    else
    begin
      lbxBackupOptions.ItemEnabled[0] := True;
    end;

    if rbOther.Checked then // 其他工具
    begin
      pgcMain.ActivePage := tsOther;
    end
    else if rbBackup.Checked then // 备份文件
    begin
      pgcMain.ActivePage := tsBackup;
    end;
  end
  else if pgcMain.ActivePage = tsBackup then
  begin
    with lbxBackupOptions do
    begin
      if not MyValidLbxItemChecked(lbxBackupOptions) then
      begin
        ErrorDlg(g_strErrorSelectBackup, SCnErrorCaption);
        SetFocus;
        Exit;
      end;
    end;

    if Length(Trim(edtBackupFile.Text)) = 0 then
    begin
      ErrorDlg(g_strErrorFileName, SCnErrorCaption);
      edtBackupFile.SetFocus;
      Exit;
    end;

    // 切换到结果页面
    pgcMain.ActivePage := tsResult;

    // 进行备份操作
    if m_abi <> nil then
      FreeAndNil(m_abi);
    btnClose.Enabled := False;
    m_bCanClose := False;
    Screen.Cursor := crHourGlass;

    // 创建 TAppBuilderInfo 对象
    try
      m_abi := TAppBuilderInfo.Create(
          Handle, TAbiType(lbxSelectApp.ItemIndex));
      if lbxBackupOptions.Checked[0] then
        m_abi.m_AbiOption := [aoCodeTemp];
      if lbxBackupOptions.Checked[1] then
        m_abi.m_AbiOption := m_abi.m_AbiOption + [aoObjRep];
      if lbxBackupOptions.Checked[2] then
        m_abi.m_AbiOption := m_abi.m_AbiOption + [aoRegInfo];
      if lbxBackupOptions.Checked[3] then
        m_abi.m_AbiOption := m_abi.m_AbiOption + [aoMenuTemp];

      m_abi.BackupInfoToFile(edtBackupFile.Text, chkSaveUsrObjRep2Sys.Checked);
      FDone := True;
    finally
      FreeAndNil(m_abi);
      btnClose.Enabled := True;
      m_bCanClose := True;
      Screen.Cursor := crDefault;
    end;
  end
  else if pgcMain.ActivePage = tsPreRestore then
  begin
    if mmoBakFileInfo.Lines.Count < 4 then
    begin
      EnableWindow(btnNext.Handle, False);
      Exit;
    end;
    if Length(Trim(edtRestoreFile.Text)) = 0 then
    begin
      ErrorDlg(g_strErrorSelectFile, SCnErrorCaption);
      edtRestoreFile.SetFocus;
      Exit;
    end;
    if Not FileExists(edtRestoreFile.Text) then
    begin
      ErrorDlg(g_strErrorFileNotExist, SCnErrorCaption);
      Exit;
    end;
    if edtRestoreRootPath.Text <> GetAppRootDir(m_atRestore) then
      btnNext.Enabled := False
    else
      btnNext.Enabled := True;

    pgcMain.ActivePage := tsRestore;
  end
  else if pgcMain.ActivePage = tsRestore then
  begin
    if edtRestoreRootPath.Text <> GetAppRootDir(m_atRestore) then
    begin
      ErrorDlg(g_strErrorNoIDE, SCnErrorCaption);
      Exit;
    end;
    if not MyValidLbxItemChecked(lbxRestoreOptions) then
    begin
      ErrorDlg(g_strErrorSelectRestore, SCnErrorCaption);
      lbxRestoreOptions.SetFocus;
      Exit;
    end;

    // 判断 AppBuilder 是否正在运行中
    if not IsAppBuilderRunning(m_atRestore) then
    begin
      // 切换到结果页面
      btnClose.Enabled := False;
      m_bCanClose := False;
      pgcMain.ActivePage := tsResult;
      Screen.Cursor := crHourGlass;

      // 进行恢复操作
      try
        m_abi := TAppBuilderInfo.Create(Handle, m_atRestore);
        m_abi.m_AbiOption := [];
        if lbxRestoreOptions.Checked[0] then
          m_abi.m_AbiOption := [aoCodeTemp];
        if lbxRestoreOptions.Checked[1] then
          m_abi.m_AbiOption := m_abi.m_AbiOption + [aoObjRep];
        if lbxRestoreOptions.Checked[2] then
          m_abi.m_AbiOption := m_abi.m_AbiOption + [aoRegInfo];
        if lbxRestoreOptions.Checked[3] then
          m_abi.m_AbiOption := m_abi.m_AbiOption + [aoMenuTemp];

        m_abi.RestoreInfoFromFile(edtRestoreFile.Text);
        FDone := True;
      finally
        FreeAndNil(m_abi);
        btnClose.Enabled := True;
        m_bCanClose := True;
        Screen.Cursor := crDefault;
      end;
    end
    else
      ErrorDlg(Format(g_strErrorIDERunningFmt, [g_strAppName[Integer(m_atRestore)]]), SCnErrorCaption);
  end
  else if pgcMain.ActivePage = tsOther then
  begin
    if FindWindow('TAppBuilder', nil) <> 0 then
    begin
      ErrorDlg(SCnIDERunning, SCnErrorCaption);
      Exit;
    end;
    UpdateToHisEntries(lstProjects, IDEHistories[TCnCompiler(lstIDEs.ItemIndex)].Projects);
    UpdateToHisEntries(lstFiles, IDEHistories[TCnCompiler(lstIDEs.ItemIndex)].Files);

    CleanHis;

    LoadHistories;
    UpdateToList;
    FDone := True;
  end;
end;

// 上一步
procedure TCnIdeBRMainForm.btnPrevClick(Sender: TObject);
begin
  if pgcMain.ActivePage = tsSelectApp then
    pgcMain.ActivePage := tsFirst
  else if pgcMain.ActivePage = tsPreRestore then
    pgcMain.ActivePage := tsFirst
  else if pgcMain.ActivePage = tsBackup then
    pgcMain.ActivePage := tsSelectApp
  else if pgcMain.ActivePage = tsRestore then
    pgcMain.ActivePage := tsPreRestore
  else if pgcMain.ActivePage = tsOther then
    pgcMain.ActivePage := tsFirst
  else if pgcMain.ActivePage = tsPreRestore then
    pgcMain.ActivePage := tsFirst
  else if pgcMain.ActivePage = tsResult then
    pgcMain.ActivePage := tsFirst;
end;

// 备份页面显示出来时
procedure TCnIdeBRMainForm.tsBackupShow(Sender: TObject);
begin

end;

// 点击'浏览恢复文件'按钮
procedure TCnIdeBRMainForm.btnBrowRestoreFileClick(Sender: TObject);
begin
  dlgOpen.InitialDir := _CnExtractFilePath(Application.ExeName);
  if dlgOpen.Execute then
  begin
    ParseFileAndNotifyUI(dlgOpen.FileName);
  end;
end;

// 点击'浏览备份文件'按钮
procedure TCnIdeBRMainForm.btnBrowBackupFileClick(Sender: TObject);
begin
  dlgSave.FileName := _CnExtractFileName(edtBackupFile.Text);
  if dlgSave.Execute then
  begin
    edtBackupFile.Text := dlgSave.FileName;
  end;
end;

procedure TCnIdeBRMainForm.lbxBackupOptionsClick(Sender: TObject);
begin
  Invalidate;
  // BDS 下共同变化
  if lbxSelectApp.ItemIndex in [6, 7] then
    lbxBackupOptions.Checked[0] := lbxBackupOptions.Checked[1];
end;

procedure TCnIdeBRMainForm.lbxRestoreOptionsClickCheck(Sender: TObject);
begin
  with (Sender as TCheckListBox) do
  begin
    if ItemIndex <> -1 then
    begin
      if Integer(Items.Objects[ItemIndex]) = 0 then
        Checked[ItemIndex] := False;
      Invalidate;
    end;

    // BDS 下共同变化
    if not lbxRestoreOptions.ItemEnabled[0] then
      lbxRestoreOptions.Checked[0] := lbxRestoreOptions.Checked[1];
  end;
end;

// 显示关于窗口
procedure TCnIdeBRMainForm.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnIDEAbout, SCnAboutCaption);
end;

// 验证 CheckListBox 中是否有选择 Item
function TCnIdeBRMainForm.MyValidLbxItemChecked(lbx: TCheckListBox): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to lbx.Items.Count - 1 do
  begin
    if lbx.Checked[i] then
    begin
      Result := True;
      break;
    end;
  end;
end;

// 自画ListBox，实现RadioListBox的效果
procedure TCnIdeBRMainForm.MyDrawRadioListBoxItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  rct, rctDraw: TRect;
  uState: UINT;
begin
  with Control as TListBox do
  begin
    rct.Left := Rect.Left + 15;
    rct.Top := Rect.Top;
    rct.Bottom := Rect.Bottom;
    rct.Right := rct.Left + Control.Width - 32;

    rctDraw.left := Rect.Left + 1;
    rctDraw.right := Rect.Left + 13;
    rctDraw.top := Rect.Top;
    rctDraw.bottom := Rect.Bottom;

    Canvas.Brush.Color := Color;
    Canvas.FillRect(Rect);

    if ((odFocused in State) or (odSelected in State))
      and (Integer(Items.Objects[Index]) = 1) then
    begin
      Canvas.Brush.Color := $00FFF7F7;
      Canvas.Pen.Color := clGray;
      Canvas.RoundRect(rct.Left, rct.Top, rct.Right, rct.Bottom, 5, 5);
    end;

    if odSelected in State then
    begin
      if Integer(Items.Objects[Index]) = 0 then
        uState := DFCS_BUTTONRADIO or DFCS_INACTIVE
      else
        uState := DFCS_BUTTONRADIO or DFCS_CHECKED;
    end
    else
    begin
      if Integer(Items.Objects[Index]) = 0 then
        uState := DFCS_BUTTONRADIO or DFCS_INACTIVE
      else
        uState := DFCS_BUTTONRADIO;
    end;

    Windows.DrawFrameControl(Canvas.Handle, rctDraw,
        DFC_BUTTON, uState);
    // 字体颜色
    if Integer(Items.Objects[Index]) = 1 then
      Canvas.Font.Color := Font.Color
    else
      Canvas.Font.Color := clGray;

    // 绘制图标
    il16.Draw(Canvas, rct.Left + 4,
        rct.Top + (rct.Bottom - rct.Top - il16.Height) div 2, Index);

    // 绘制出文字
    Canvas.TextOut(rct.Left + 24,
        rct.Top + (Rect.Bottom - rct.Top - Canvas.TextHeight('A')) div 2,
        Items.Strings[Index]);
    if odFocused in State then
      Canvas.DrawFocusRect(Rect);
  end;
end;

// 绘制CheckListBox的Item
procedure TCnIdeBRMainForm.MyDrawCheckListBoxItem(Control: TWinControl;
  Index: Integer; Rect: TRect; AState: TOwnerDrawState);
var
  rct: TRect;
begin
  with (Control as TCheckListBox) do
  begin
    rct.Left := Rect.Left;
    rct.Top := Rect.Top;
    rct.Bottom := Rect.Bottom;
    rct.Right := rct.Left + Canvas.TextWidth('A')
        * (Length(Items.Strings[Index]) + 2) + 16;
    if (odFocused in AState) and ItemEnabled[Index] then // 当前选中项
    begin
      Canvas.Brush.Color := $00FFF7F7;
      Canvas.Pen.Color := clGray;
      Canvas.RoundRect(rct.Left, rct.Top, rct.Right, rct.Bottom, 5, 5);
    end
    else
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect);
    end;
    // 字体颜色
    if Checked[Index] then
      Canvas.Font.Color := Font.Color
    else
      Canvas.Font.Color := clGray;
      
    // 图像
    il16.Draw(Canvas, Rect.Left + 3, Rect.Top + 2, Index + Integer(High(TAbiType)) + 1); // 前面 许多个是 IDE 图标
    // 绘制出文字
    SetBkMode(Canvas.Handle, TRANSPARENT);
    Canvas.TextOut(Rect.Left + 22, Rect.Top + (Rect.Bottom
      - Rect.Top - Canvas.TextHeight('A')) div 2,
      Items.Strings[Index]);

    if odFocused in AState then
      Canvas.DrawFocusRect(Rect);
  end;
end;

// 重载WndProc实现自定义消息的拦截
procedure TCnIdeBRMainForm.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = $400 + 1001 then
  begin
    if Message.LParam = 1 then
      mmoLog.Lines.Strings[mmoLog.Lines.Count - 1] := PChar(Message.WParam)
    else
      mmoLog.Lines.Add(PChar(Message.WParam));
  end;
  if Message.Msg = WM_DROPFILES then
  begin
    WMDropFiles(TWMDropFiles(Message));
  end;
end;

// 处理文件拖放消息
procedure TCnIdeBRMainForm.WMDropFiles(var Msg: TWMDropFiles);
var
  strFileName: String;
  nLength: Integer;
begin
  if DragQueryFile(HDROP(Msg.Drop), $FFFFFFFF, nil, 0) > 0 then
  begin
    // 选择一个文件的路径
    SetLength(strFileName, MAX_PATH);
    nLength := DragQueryFile(HDROP(Msg.Drop), 0, PChar(strFileName), Length(strFileName));
    SetLength(strFileName, nLength);
    if UpperCase(_CnExtractFileExt(strFileName)) = '.BIC' then
    begin
      ParseFileAndNotifyUI(strFileName);
    end;
  end;
  DragFinish(HDROP(Msg.Drop));
end;

// 分析备份文件
procedure TCnIdeBRMainForm.ParseFileAndNotifyUI(strBakFile: String);
var
  strRootDir, strAppName: String;
  ao: TAbiOptions;
  i: integer;
begin
  if not FileExists(strBakFile) then Exit;

  edtRestoreFile.Text := strBakFile;
  mmoBakFileInfo.Lines.Clear;
  // 分析备份文件
  try
    ao := ParseBakFile(strBakFile, strRootDir, strAppName, m_atRestore);
  except
    mmoBakFileInfo.Lines.Add(g_strFileInvalid);
  end;
  if ao = [] then
  begin
    btnNext.Enabled := False;
    mmoBakFileInfo.Lines.Add(g_strFileInvalid);
  end
  else
  begin
    btnNext.Enabled := True;
    mmoBakFileInfo.Lines.Clear;
    mmoBakFileInfo.Lines.Add(g_strIDEName + #13#10 + '　　' + strAppName);
    mmoBakFileInfo.Lines.Add(g_strInstallDir + #13#10 + '　　' + strRootDir);
    mmoBakFileInfo.Lines.Add(g_strBackupContent);

    for i := 0 to lbxRestoreOptions.Items.Count - 1 do
      lbxRestoreOptions.Checked[i] := False;

    if aoCodeTemp in ao then
    begin
      lbxRestoreOptions.Checked[0] := True;
      mmoBakFileInfo.Lines.Add('　　' + g_strAbiOptions[0]);
    end;
    if aoObjRep in ao then
    begin
      lbxRestoreOptions.Checked[1] := True;
      mmoBakFileInfo.Lines.Add('　　' + g_strAbiOptions[1]);
    end;
    if aoRegInfo in ao then
    begin
      lbxRestoreOptions.Checked[2] := True;
      mmoBakFileInfo.Lines.Add('　　' + g_strAbiOptions[2]);
    end;
    if aoMenuTemp in ao then
    begin
      lbxRestoreOptions.Checked[3] := True;
      mmoBakFileInfo.Lines.Add('　　' + g_strAbiOptions[3]);
    end;

    lbxRestoreOptions.Items.Objects[0] := TObject(Integer(aoCodeTemp in ao));
    lbxRestoreOptions.Items.Objects[1] := TObject(Integer(aoObjRep in ao));
    lbxRestoreOptions.Items.Objects[2] := TObject(Integer(aoRegInfo in ao));
    lbxRestoreOptions.Items.Objects[3] := TObject(Integer(aoMenuTemp in ao));

    lbxRestoreOptions.Enabled := True;
    edtRestoreRootPath.Text := GetAppRootDir(m_atRestore);

    if (strAppName = g_strAppName[6]) or (strAppName = g_strAppName[7]) then
      lbxRestoreOptions.ItemEnabled[0] := False;

    if Length(edtRestoreRootPath.Text) < 2 then
      edtRestoreRootPath.Text := strAppName + g_strIDENotInstalled;
  end;
  pgcMain.ActivePage := tsPreRestore;
end;

procedure TCnIdeBRMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Not m_bCanClose then
    Action := caNone;
end;

procedure TCnIdeBRMainForm.lbxSelectAppClick(Sender: TObject);
begin
  btnNext.Enabled := (lbxSelectApp.ItemIndex >= 0)
    and (Integer(lbxSelectApp.Items.Objects[lbxSelectApp.ItemIndex]) = 1);
end;

procedure TCnIdeBRMainForm.TabSheetShow(Sender: TObject);
var
  ts: TTabSheet;
begin
  ts := Sender as TTabSheet;
  if ts = tsFirst then
  begin
    btnPrev.Visible := False;
    btnNext.Visible := True;
    btnNext.Enabled := True;
  end
  else if ts = tsSelectApp then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
    btnNext.Enabled := False;
    if Assigned(lbxSelectApp.OnClick) then
      lbxSelectApp.OnClick(lbxSelectApp);
  end
  else if ts = tsPreRestore then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
    if Length(Trim(edtRestoreFile.Text)) > 0 then
      btnNext.Enabled := True
    else
      btnNext.Enabled := False;
  end
  else if ts = tsBackup then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
    btnNext.Enabled := True;
    edtBackupFile.Text := MakePath(GetMyDocumentsDir) 
        + g_strAppAbName[lbxSelectApp.ItemIndex]
        + FormatDateTime('_yyyymmdd', Now()) + '.bic';
  end
  else if ts = tsRestore then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
  end
  else if ts = tsOther then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
    btnNext.Enabled := True;
  end
  else if ts = tsResult then
  begin
    btnPrev.Visible := True;
    btnPrev.Enabled := True;
    btnNext.Visible := True;
    btnNext.Enabled := False;
  end;
end;

procedure TCnIdeBRMainForm.LoadHistories;
var
  I: Integer;
  IDE: TCnCompiler;
  Reg: TRegistry;
  Strs: TStringList;
begin
  Strs := nil; Reg := nil;
  try
    Reg := TRegistry.Create;
    Strs := TStringList.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    for IDE := Low(TCnCompiler) to High(TCnCompiler) do
    begin
      if Reg.OpenKey(GetRegIDEBase(IDE) + SACnRegIDEEntries[IDE]
        + SCnRegHisProject, False) then
      begin
        IDEHistories[IDE].Exists := True;
        Strs.Clear;
        Reg.GetValueNames(Strs);

        IDEHistories[IDE].Projects.Clear;
        for I := 0 to Strs.Count - 1 do
        begin
          if Strs[I] = 'Max Closed Files' then //D2010后加了此项控制最大数
            Continue;

          with IDEHistories[IDE].Projects.Add do
          begin
            EntryName := Strs[I];
            EntryValue := GetEntryValue(Reg.ReadString(Strs[I]));
            ToDelete := True;
          end;
        end;
        Reg.CloseKey;
      end;
      if Reg.OpenKey(GetRegIDEBase(IDE) + SACnRegIDEEntries[IDE]
        + SCnRegHisFiles, False) then
      begin
        IDEHistories[IDE].Exists := True;
        Strs.Clear;
        Reg.GetValueNames(Strs);

        IDEHistories[IDE].Files.Clear;
        for I := 0 to Strs.Count - 1 do
        begin
          if Strs[I] = 'Max Closed Files' then //D2010后加了此项控制最大数
            Continue;
            
          with IDEHistories[IDE].Files.Add do
          begin
            EntryName := Strs[I];
            EntryValue := GetEntryValue(Reg.ReadString(Strs[I]));
            ToDelete := True;
          end;
        end;
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
    Strs.Free;
  end;
end;

procedure TCnIdeBRMainForm.UpdateToList;
var
  IDE: TCnCompiler;
begin
  // 将显示更新到界面
  lstIDEs.Clear;
  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    lstIDEs.Items.Add(IDEHistories[IDE].IDEName);
    lstIDEs.Checked[lstIDEs.Items.Count - 1] := IDEHistories[IDE].Exists;
  end;
  FOldSel := -1;
  lstIDEs.ItemIndex := 0;
  lstIDEsClick(lstIDEs);
end;

procedure TCnIdeBRMainForm.btnSelAllIDEClick(Sender: TObject);
begin
  SelAllListBox(lstIDEs);
  lstIDEsClick(lstIDEs);
end;

procedure TCnIdeBRMainForm.btnSelAllProjClick(Sender: TObject);
begin
  SelAllListBox(lstProjects);
  lstProjectsFilesClickCheck(lstProjects);
end;

procedure TCnIdeBRMainForm.btnSelAllFileClick(Sender: TObject);
begin
  SelAllListBox(lstFiles);
  lstProjectsFilesClickCheck(lstFiles);
end;

procedure TCnIdeBRMainForm.SelAllListBox(ListBox: TCheckListBox);
var
  I: Integer;
begin
  if ListBox.Items.Count > 0 then
    for I := 0 to ListBox.Items.Count - 1 do
      ListBox.Checked[I] := True;
end;

procedure TCnIdeBRMainForm.CleanHis;
var
  I: Integer;
  IDE: TCnCompiler;
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;

    for IDE := Low(TCnCompiler) to High(TCnCompiler) do
    begin
      if Reg.OpenKey(GetRegIDEBase(IDE) + SACnRegIDEEntries[IDE]
        + SCnRegHisProject, False) then
      begin
        for I := 0 to IDEHistories[IDE].Projects.Count - 1 do
          if IDEHistories[IDE].Projects.Items[I].ToDelete then
            Reg.DeleteValue(IDEHistories[IDE].Projects.Items[I].EntryName);
        Reg.CloseKey;
      end;

      if Reg.OpenKey(GetRegIDEBase(IDE) + SACnRegIDEEntries[IDE]
        + SCnRegHisFiles, False) then
      begin
        for I := 0 to IDEHistories[IDE].Files.Count - 1 do
          if IDEHistories[IDE].Files.Items[I].ToDelete then
            Reg.DeleteValue(IDEHistories[IDE].Files.Items[I].EntryName);
        Reg.CloseKey;
      end;
    end;
    InfoDlg(SCnCleaned, SCnQuitAskCaption);
  finally
    Reg.Free;
  end;
end;

procedure TCnIdeBRMainForm.lstIDEsClick(Sender: TObject);
var
  I: Integer;
  IDE: TCnCompiler;
begin
  if lstIDEs.Items.Count = 0 then Exit;

  if lstIDEs.ItemIndex <> FOldSel then
  begin
    if (FOldSel >= 0) and (FOldSel <= Ord(High(TCnCompiler))) then
    begin
      UpdateToHisEntries(lstProjects, IDEHistories[TCnCompiler(FOldSel)].Projects);
      UpdateToHisEntries(lstFiles, IDEHistories[TCnCompiler(FOldSel)].Files);
    end;

    IDE := TCnCompiler(lstIDEs.ItemIndex);
    lstProjects.Clear;
    for I := 0 to IDEHistories[IDE].Projects.Count - 1 do
    begin
      lstProjects.Items.Add(IDEHistories[IDE].Projects.Items[I].EntryValue);
      lstProjects.Checked[I] := IDEHistories[IDE].Projects.Items[I].ToDelete;
    end;
    // todo: 加入水平滚动条会导致检查框刷新不正确
    //ListboxHorizontalScrollbar(lstProjects);

    lstFiles.Clear;
    for I := 0 to IDEHistories[IDE].Files.Count - 1 do
    begin
      lstFiles.Items.Add(IDEHistories[IDE].Files.Items[I].EntryValue);
      lstFiles.Checked[I] := IDEHistories[IDE].Files.Items[I].ToDelete;
    end;
    //ListboxHorizontalScrollbar(lstFiles);

    FOldSel := lstIDEs.ItemIndex;
  end;
end;

procedure TCnIdeBRMainForm.UpdateToHisEntries(ListBox: TCheckListBox;
  His: TCnHisEntries);
var
  I: Integer;
begin
  for I := 0 to ListBox.Items.Count - 1 do
    His.Items[I].ToDelete := ListBox.Checked[I];
end;

procedure TCnIdeBRMainForm.lstProjectsFilesClickCheck(Sender: TObject);
var
  I: Integer;
  State: TCheckBoxState;
  IsChecked, IsUnchecked: Boolean;
begin
  if not (Sender is TCheckListBox) then Exit;
  if lstProjects.Items.Count = 0 then Exit;

  IsChecked := True; IsUnchecked := True;
  for I := 0 to lstProjects.Items.Count - 1 do
  begin
    if lstProjects.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;
  for I := 0 to lstFiles.Items.Count - 1 do
  begin
    if lstFiles.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;

  if not IsChecked and not IsUnchecked then
    State := cbGrayed
  else if IsChecked then
    State := cbChecked
  else
    State := cbUnchecked;

  lstIDEs.State[lstIDEs.ItemIndex] := State;
end;

procedure TCnIdeBRMainForm.lstFilesClickCheck(Sender: TObject);
var
  I: Integer;
  State: TCheckBoxState;
  IsChecked, IsUnchecked: Boolean;
begin
  if not (Sender is TCheckListBox) then Exit;
  if lstFiles.Items.Count = 0 then Exit;

  IsChecked := True; IsUnchecked := True;
  for I := 0 to lstProjects.Items.Count - 1 do
  begin
    if lstProjects.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;
  for I := 0 to lstFiles.Items.Count - 1 do
  begin
    if lstFiles.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;

  if not IsChecked and not IsUnchecked then
    State := cbGrayed
  else if IsChecked then
    State := cbChecked
  else
    State := cbUnchecked;

  lstIDEs.State[lstIDEs.ItemIndex] := State;
end;

function TCnIdeBRMainForm.GetEntryValue(const AValue: string): string;
var
  Idx: Integer;
begin
  Result := AValue;
  Idx := AnsiPos(',''', Result);
  if Idx > 0 then
    Delete(Result, 1, Idx + 1);
  Idx := AnsiPos(''',', Result);
  if Idx > 0 then
    Delete(Result, Idx, MaxInt);
end;

procedure TCnIdeBRMainForm.lstIDEsClickCheck(Sender: TObject);
var
  I: Integer;
begin
  lstIDEsClick(Sender);

  for I := 0 to lstProjects.Items.Count - 1 do
    lstProjects.Checked[I] := lstIDEs.Checked[lstIDEs.ItemIndex];
  for I := 0 to lstFiles.Items.Count - 1 do
    lstFiles.Checked[I] := lstIDEs.Checked[lstIDEs.ItemIndex];
end;

procedure TCnIdeBRMainForm.lstProjectsClickCheck(Sender: TObject);
var
  I: Integer;
  State: TCheckBoxState;
  IsChecked, IsUnchecked: Boolean;
begin
  if not (Sender is TCheckListBox) then Exit;

  IsChecked := True; IsUnchecked := True;
  for I := 0 to lstProjects.Items.Count - 1 do
  begin
    if lstProjects.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;
  for I := 0 to lstFiles.Items.Count - 1 do
  begin
    if lstFiles.Checked[I] then
      IsUnchecked := False
    else
      IsChecked := False;
  end;

  if not IsChecked and not IsUnchecked then
    State := cbGrayed
  else if IsChecked then
    State := cbChecked
  else
    State := cbUnchecked;

  lstIDEs.State[lstIDEs.ItemIndex] := State;
end;

procedure TCnIdeBRMainForm.btnCloseClick(Sender: TObject);
begin
  if FDone or QueryDlg(SCnQuitAsk, True, SCnQuitAskCaption) then
    Close;
end;

procedure TCnIdeBRMainForm.pgcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := False;
end;

procedure TCnIdeBRMainForm.DoCreate;
const
  csLangDir = 'Lang\';
var
  I: Integer;
  LangID: DWORD;
begin
  if CnLanguageManager <> nil then
  begin
    CnHashLangFileStorage.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    CnLanguageManager.LanguageStorage := CnHashLangFileStorage;

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

procedure TCnIdeBRMainForm.TranslateStrings;
begin
  TranslateStrArray(g_strOpResult, 'g_strOpResult');
  TranslateStrArray(g_strAbiOptions, 'g_strAbiOptions');
  TranslateStr(g_strFileInvalid, 'g_strFileInvalid');
  TranslateStr(g_strBackup, 'g_strBackup');
  TranslateStr(g_strRestore, 'g_strRestore');
  TranslateStr(g_strBackuping, 'g_strBackuping');
  TranslateStr(g_strAnalyzing, 'g_strAnalyzing');
  TranslateStr(g_strRestoring, 'g_strRestoring');
  TranslateStr(g_strCreating, 'g_strCreating');
  TranslateStr(g_strNotFound, 'g_strNotFound');
  TranslateStr(g_strObjRepConfig, 'g_strObjRepConfig');
  TranslateStr(g_strObjRepUnit, 'g_strObjRepUnit');
  TranslateStr(g_strPleaseWait, 'g_strPleaseWait');
  TranslateStr(g_strUnkownName, 'g_strUnkownName');
  TranslateStr(g_strBakFile, 'g_strBakFile');
  TranslateStr(g_strCreate, 'g_strCreate');
  TranslateStr(g_strAnalyseSuccess, 'g_strAnalyseSuccess');
  TranslateStr(g_strBackupSuccess, 'g_strBackupSuccess');
  TranslateStr(g_strThanksForRestore, 'g_strThanksForRestore');
  TranslateStr(g_strThanksForBackup, 'g_strThanksForBackup');
  TranslateStr(g_strPleaseCheckFile, 'g_strPleaseCheckFile');
  TranslateStr(g_strAppTitle, 'g_strAppTitle');
  TranslateStr(g_strBugReportToMe, 'g_strBugReportToMe');

  TranslateStr(g_strIDEName, 'g_strIDEName');
  TranslateStr(g_strInstallDir, 'g_strInstallDir');
  TranslateStr(g_strBackupContent,  'g_strBackupContent');
  TranslateStr(g_strIDENotInstalled, 'g_strIDENotInstalled');
  TranslateStr(g_strErrorSelectApp, 'g_strErrorSelectApp');
  TranslateStr(g_strErrorSelectBackup, 'g_strErrorSelectBackup');
  TranslateStr(g_strErrorFileName, 'g_strErrorFileName');
  TranslateStr(g_strErrorSelectFile, 'g_strErrorSelectFile');
  TranslateStr(g_strErrorFileNotExist, 'g_strErrorFileNotExist');
  TranslateStr(g_strErrorNoIDE, 'g_strErrorNoIDE');
  TranslateStr(g_strErrorSelectRestore, 'g_strErrorSelectRestore');
  TranslateStr(g_strErrorIDERunningFmt, 'g_strErrorIDERunningFmt');
  TranslateStr(g_strNotInstalled, 'g_strNotInstalled');
  TranslateStr(SCnIDERunning, 'SCnIDERunning');
  TranslateStr(SCnQuitAsk, 'SCnQuitAsk');
  TranslateStr(SCnQuitAskCaption, 'SCnQuitAskCaption');
  TranslateStr(SCnErrorCaption, 'SCnErrorCaption');
  TranslateStr(SCnCleaned, 'SCnCleaned');
  TranslateStr(SCnHelpOpenError, 'SCnHelpOpenError');
  TranslateStr(SCnAboutCaption, 'SCnAboutCaption');
  TranslateStr(SCnIDEAbout, 'SCnIDEAbout');
end;

procedure TCnIdeBRMainForm.DoLanguageChanged(Sender: TObject);
begin
  TranslateStrings;
end;

function TCnIdeBRMainForm.GetHelpTopic: string;
begin
  Result := 'CnIdeBRTool';
end;

procedure TCnIdeBRMainForm.DoHelpError;
begin
  ErrorDlg(SCnHelpOpenError, SCnErrorCaption);
end;

procedure TCnIdeBRMainForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnIdeBRMainForm.GetRegIDEBase(IDE: TCnCompiler): string;
begin
  if (Integer(IDE) >= Integer(cnDelphi2009)) and not (IDE in [cnBCB5, cnBCB6]) then
  begin
    if (Integer(IDE) >= Integer(cnDelphiXE)) then
      Result := SCnRegIDEBase15
    else
      Result := SCnRegIDEBase12;
  end
  else
    Result := SCnRegIDEBase;
end;

function TCnIdeBRMainForm.NeedAdjustRightBottomMargin: Boolean;
begin
  Result := False;
end;

end.
