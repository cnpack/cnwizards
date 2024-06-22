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

unit ConfigIO;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包设置导入导出工具
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.05.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Registry, ExtCtrls, StdCtrls, FileCtrl, CnCommon, CnConsts, CnWizLangID,
  CnLangTranslator, CnLangStorage, CnHashLangStorage, CnLangMgr, CnClasses,
  CnWizCfgUtils, CnWideCtrls;

const
  SCnWizardsReg = 'CnWizards.reg';

var
  SCnQuitAsk: string = 'Sure to Exit?';
  SCnQuitAskCaption: string = 'Information';
  SCnRestoreDef: string = 'The Restoring Action will Overwrite Existing Config Info, Continue?';
  SCnBackupSucc: string = 'CnPack IDE Wizards Config Info Exported Successfully.';
  SCnRestoreSucc: string = 'CnPack IDE Wizards Config Info Imported Successfully.';
  SCnRestoreDefSucc: string = 'CnPack IDE Wizards Config Info Restored Successfully.';
  SCnIdeRunning: string = 'Please Close Delphi / C++Builder before Importing or Exporting.';
  SCnIdeRunning1: string = 'Please Close Delphi / C++Builder before Restoring.';
  SCnRestoreError: string = 'Can not Import Registry Files.';

  SCnConfigIOCmdHelp: string =
    'This Tool Supports Command Line Mode without Showing the Main Form.' + #13#10#13#10 +
    'Command Line Switch Help:' + #13#10#13#10 +
    '         The First Parameter without / or - Represents the File name.' + #13#10 +
    '         -i or /i     Import CnWizards Settings' + #13#10 +
    '         -o or /o     Export CnWizards Settings' + #13#10 +
    '         -r or /r     Restore to CnWizards Default Settings' + #13#10 +
    '         -n or /n or -NoMsg or /NoMsg Do NOT Show the Success Message after Import/Export/Restore Operation.' + #13#10 +
    '         -? or /? or -h 或 /h  Show the Command Line Help' + #13#10#13#10 +
    'Examples:' + #13#10 +
    '         CnConfigIO -i C:\a.cnw -n' + #13#10 +
    '         CnConfigIO -o C:\a.cnw -n' + #13#10 +
    '         CnConfigIO -r';

  SCnConfigIOAboutCaption: string = 'About';
  SCnConfigIOAbout: string = 'CnPack IDE Wizards Config Import & Export Tool' + #13#10#13#10 +
    'This tool can be used to Import and Export CnPack IDE Wizards Config Information ' + #13#10 +
    'for Config backup or migration.' + #13#10#13#10 +
    'Author: Liu Xiao (master@cnpack.org)' + #13#10 +
    'Copyright (C) 2001-2024 CnPack Team';

type

{$I WideCtrls.inc}

  TFrmConfigIO = class(TForm)
    Label1: TLabel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    RadioButtonOut: TRadioButton;
    RadioButtonIn: TRadioButton;
    btnClose: TButton;
    btnHelp: TButton;
    btnOK: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    RadioButtonRestore: TRadioButton;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    CnLangManager: TCnLangManager;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FDone: Boolean;
    FRegPath: string;
    FRegFile: string;
    FUserPath: string;
    FFileList: TStringList;
    FParmNoMsg: Boolean;
    FParmImport: Boolean;
    FParmExport: Boolean;
    FParmReDef: Boolean;
    FParmHelp: Boolean;
    FVaildParams: Boolean;
    function IsIdeRunning: Boolean;
    procedure OnFindFileToDel(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure OnFindFileToBackup(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected
    procedure DoCreate; override;
    procedure TranslateStrings;
  public
    procedure BackupToFile(const FileName: string);
    procedure RestoreFromFile(const FileName: string);
    procedure RestoreDef;
    function BackupWizardsReg(const FileName: string): Boolean;
    function RestoreWizardsReg(const FileName: string): Boolean;
    procedure ClearReg;
  end;

var
  FrmConfigIO: TFrmConfigIO;

implementation

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

procedure TFrmConfigIO.FormCreate(Sender: TObject);
var
  AFileName: string;
  I: Integer;
begin
  Application.Title := Caption;
  FRegPath := MakePath(SCnPackRegPath);
  FRegFile := MakePath(GetWindowsTempPath) + SCnWizardsReg; // Use Temp Directory to avoid read only.
  FFileList := TStringList.Create;
  FParmNoMsg := (FindCmdLineSwitch('n', ['-', '/'], True) or
    FindCmdLineSwitch('NoMsg', ['-', '/'], True));
  FParmImport := FindCmdLineSwitch('i', ['-', '/'], True);
  FParmExport := FindCmdLineSwitch('o', ['-', '/'], True);
  FParmReDef := FindCmdLineSwitch('r', ['-', '/'], True);
  FParmHelp := FindCmdLineSwitch('?', ['-', '/'], True)
    or FindCmdLineSwitch('h', ['-', '/'], True)
    or FindCmdLineSwitch('help', ['-', '/'], True);

  FUserPath := GetCWUserPath;

  FVaildParams := FParmImport or FParmExport or FParmReDef;

  if FParmHelp then
  begin
    InfoDlg(SCnConfigIOCmdHelp, SCnQuitAskCaption);
    Application.Terminate;
    Exit;
  end;

  if not Application.ShowMainForm then
  begin
    for I := 1 to ParamCount do
      if (Length(ParamStr(I)) > 0) and not (ParamStr(I)[1] in ['-', '/']) then
      begin
        AFileName := Trim(ParamStr(I));
        Break;
      end;
      
    if AFileName <> '' then
    begin
      if FParmExport then
        BackupToFile(AFileName)
      else if FParmImport then
        RestoreFromFile(AFileName)
      else if FParmReDef then
        RestoreDef;
    end;

    Application.Terminate;
  end;  
end;

procedure TFrmConfigIO.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
end;

procedure TFrmConfigIO.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmConfigIO.btnOKClick(Sender: TObject);
begin
  if Self.RadioButtonOut.Checked then
  begin
    if Self.SaveDialog.Execute then
    begin
      // 导出设置
      Self.BackupToFile(SaveDialog.FileName);
    end
  end
  else if Self.RadioButtonIn.Checked then
  begin
    if IsIdeRunning then
    begin
      InfoDlg(SCnIdeRunning, SCnQuitAskCaption);
      Exit;
    end;

    if Self.OpenDialog.Execute then
    begin
      // 导入设置
      Self.RestoreFromFile(OpenDialog.FileName);
    end;
  end
  else
  begin
    if IsIdeRunning then
    begin
      InfoDlg(SCnIdeRunning1, SCnQuitAskCaption);
      Exit;
    end;

    if QueryDlg(SCnRestoreDef, False, SCnQuitAskCaption) then
      Self.RestoreDef;
  end;
end;

procedure TFrmConfigIO.btnHelpClick(Sender: TObject);
begin
  InfoDlg(SCnConfigIOAbout, SCnConfigIOAboutCaption);
end;

procedure TFrmConfigIO.RestoreDef;
begin
  if DirectoryExists(FUserPath) then
    FindFile(FUserPath, '*.*', OnFindFileToDel, nil, True, False);
  // 删除 CnDebugViewer 默认设置
  DeleteFile('CnDVOptions.xml');
  ClearReg;
  FDone := True;

  if not FParmNoMsg then
    InfoDlg(SCnRestoreDefSucc, SCnQuitAskCaption);
end;

procedure TFrmConfigIO.ClearReg;
var
  r: TRegistry;
begin
  r := TRegistry.Create(KEY_ALL_ACCESS);
  try
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKey(FRegPath, False) then
      r.DeleteKey(FRegPath);
    r.CloseKey;
  finally
    r.Free;
  end;
end;

procedure TFrmConfigIO.BackupToFile(const FileName: string);
var
  i: Integer;
  Writer: TWriter;
  BackupStream: TFileStream;
  AStream: TMemoryStream;
  F: string;
begin
  Self.BackupWizardsReg(Self.FRegFile);
  Self.FFileList.Clear;
  Self.FFileList.Add(Self.FRegFile);
  FindFile(Self.FUserPath, '*.*', OnFindFileToBackup, nil, True, False);
  if Self.FFileList.Count > 0 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('BackupFile Count ' + IntToStr(FFileList.Count));
{$ENDIF}
    BackupStream := nil; Writer := nil; AStream := nil;
    try
      F := _CnChangeFileExt(FileName, '.cnw');
      if not FileExists(f) then
        BackupStream := TFileStream.Create(F, fmCreate)
      else
        BackupStream := TFileStream.Create(F, fmOpenWrite);

      Writer := TWriter.Create(BackupStream, 2048);
      Writer.WriteInteger(FFileList.Count);

      AStream := TMemoryStream.Create;
      for i := 0 to Self.FFileList.Count - 1 do
      begin
        Writer.WriteStr(_CnExtractFileName(FFileList.Strings[i]));
        if FileExists(FFileList.Strings[i]) then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('BackupFile: ' + FFileList.Strings[i]);
{$ENDIF}
          AStream.LoadFromFile(FFileList.Strings[i]);
          Writer.WriteInteger(AStream.Size);
          Writer.Write(AStream.Memory^, AStream.Size);
        end
        else
          Writer.WriteInteger(0);
      end;

      Writer.FlushBuffer;
    finally
      AStream.Free;
      Writer.Free;
      BackupStream.Free;
    end;
  end;
  if FileExists(FRegFile) then
    DeleteFile(FRegFile);

  Self.FDone := True;
  if not FParmNoMsg then
    InfoDlg(SCnBackupSucc, SCnQuitAskCaption);
end;

procedure TFrmConfigIO.RestoreFromFile(const FileName: string);
var
  i, j, FileSize: Integer;
  Reader: TReader;
  RestoreStream: TFileStream;
  AStream: TMemoryStream;
  TmpFile: string;
begin
  // todo: 原来备份的用户路径可能与当前读到的不一致，更安全的办法应该是先恢复注册表，
  // 再从注册表中更新用户路径进行恢复，此处暂未修改。
  if DirectoryExists(FUserPath) then
    FindFile(FUserPath, '*.*', OnFindFileToDel, nil, True, False)
  else
    ForceDirectories(FUserPath);

  Reader := nil; RestoreStream := nil; AStream := nil;
  try
    RestoreStream := TFileStream.Create(FileName, fmOpenRead);
    AStream := TMemoryStream.Create;
    Reader := TReader.Create(RestoreStream, 2048);
    i := Reader.ReadInteger;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('RestoreFile Count ' + IntToStr(i));
{$ENDIF}
    j := i;
    while i > 0 do
    begin
      TmpFile := Reader.ReadStr;
      FileSize := Reader.ReadInteger;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('RestoreFile: ' + TmpFile + ' Size: ' + IntToStr(FileSize));
{$ENDIF}
      AStream.SetSize(FileSize);
      Reader.Read(AStream.Memory^, FileSize);
      if j = i then
        AStream.SaveToFile(FRegFile)
      else
        AStream.SaveToFile(MakePath(FUserPath) + TmpFile);

      Dec(i);
    end;
  finally
    AStream.Free;
    Reader.Free;
    RestoreStream.Free;
  end;

  if FileExists(FRegFile) then
  begin
    if not Self.RestoreWizardsReg(FRegFile) then
    begin
      ErrorDlg(SCnRestoreError);
      Exit;
    end;
    DeleteFile(FRegFile);
  end;
  Self.FDone := True;

  if not FParmNoMsg then
    InfoDlg(SCnRestoreSucc, SCnQuitAskCaption);
end;

function TFrmConfigIO.BackupWizardsReg(const FileName: string): Boolean;
begin
  Result := 31 < WinExec(PChar('regedit.exe /e "' + FileName + '" HKEY_CURRENT_USER'
    + FRegPath), SW_HIDE);
end;

function TFrmConfigIO.RestoreWizardsReg(const FileName: string): Boolean;
begin
  if FVaildParams then
    Result := 31 < WinExec(PChar('regedit.exe /i /s "' + FileName + '"'), SW_HIDE)
  else
    Result := 0 = WinExecAndWait32('regedit.exe /i /s "' + FileName + '"', SW_HIDE);
end;

procedure TFrmConfigIO.OnFindFileToDel(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Delete Old File: ' + FileName);
{$ENDIF}
  DeleteFile(FileName);
end;

procedure TFrmConfigIO.OnFindFileToBackup(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
const
  EXCLUDE_DIR_1 = 'FeedCache';
  EXCLUDE_DIR_2 = 'ImageCache';
var
  Dir: string;
begin
  // Do not backup the content in those Directory.
  Dir := ExcludeTrailingBackslash(_CnExtractFileDir(FileName));
  if Pos(UpperCase(EXCLUDE_DIR_1), UpperCase(Dir)) = Length(Dir) - Length(EXCLUDE_DIR_1) + 1 then
    Exit;
  if Pos(UpperCase(EXCLUDE_DIR_2), UpperCase(Dir)) = Length(Dir) - Length(EXCLUDE_DIR_2) + 1 then
    Exit;

  FFileList.Add(FileName);
end;

function TFrmConfigIO.IsIdeRunning: Boolean;
var
  Info: TSearchRec;
  FR: Integer;
  Path: string;
begin
  Result := False;

  if FindWindow('TAppBuilder', nil) = 0 then
    Exit;
    
  Path := _CnExtractFilePath(Application.ExeName);
  FR := FindFirst(Path + 'CnWizard*.dll', faAnyFile - faVolumeID, Info);
  try
    while FR = 0 do
    begin
      if IsFileInUse(Path + Info.Name) then
      begin
        Result := True;
        Exit;
      end;
      FR := FindNext(Info);
    end;
  finally
    FindClose(Info);
  end;
end;

procedure TFrmConfigIO.DoCreate;
const
  csLangDir = 'Lang\';
var
  LangID: DWORD;
  I: Integer;
begin
  if CnLanguageManager <> nil then
  begin
    CnHashLangFileStorage.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
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

procedure TFrmConfigIO.TranslateStrings;
begin
  TranslateStr(SCnQuitAsk, 'SCnQuitAsk');
  TranslateStr(SCnQuitAskCaption, 'SCnQuitAskCaption');
  TranslateStr(SCnRestoreDef, 'SCnRestoreDef');
  TranslateStr(SCnBackupSucc, 'SCnBackupSucc');
  TranslateStr(SCnRestoreSucc, 'SCnRestoreSucc');
  TranslateStr(SCnRestoreDefSucc, 'SCnRestoreDefSucc');
  TranslateStr(SCnIdeRunning, 'SCnIdeRunning');
  TranslateStr(SCnIdeRunning1, 'SCnIdeRunning1');
  TranslateStr(SCnRestoreError, 'SCnRestoreError');
  TranslateStr(SCnConfigIOCmdHelp, 'SCnConfigIOCmdHelp');
  TranslateStr(SCnConfigIOAboutCaption, 'SCnConfigIOAboutCaption');
  TranslateStr(SCnConfigIOAbout, 'SCnConfigIOAbout');
end;

procedure TFrmConfigIO.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := FDone or QueryDlg(SCnQuitAsk, False, SCnQuitAskCaption);
end;

end.

