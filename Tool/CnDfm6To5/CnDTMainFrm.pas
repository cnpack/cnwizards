{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnDTMainFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：窗体格式及文件编码换行转换工具主窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2026.05.12 V1.1
*               加入文件格式及回车换行的处理
*           2003.04.03 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, FileCtrl, CnLangTranslator, CnLangStorage,
  CnHashLangStorage, CnLangMgr, CnClasses, CnWideCtrls, ExtCtrls;

type
  TCnSrcConvType = (sctUtf8, sctUtf16, sctAnsi, sctCRLF, sctLF);

  TCnSrcConvertResult = (scrSucc, scrOpenError, scrSaveError, scrInvalidFormat);

{$I WideCtrls.inc}

  TCnDTMainForm = class(TForm)
    btnStart: TButton;
    btnClose: TButton;
    btnAbout: TButton;
    Label1: TLabel;
    lblURL: TLabel;
    btnBinToTxt: TButton;
    btnTxtToBin: TButton;
    pgcMain: TPageControl;
    tsDFM: TTabSheet;
    bvl1: TBevel;
    GroupBox1: TGroupBox;
    sbFile: TSpeedButton;
    sbDir: TSpeedButton;
    rbFile: TRadioButton;
    edtFile: TEdit;
    rbDir: TRadioButton;
    edtDir: TEdit;
    cbSubDirs: TCheckBox;
    cbReadOnly: TCheckBox;
    GroupBox2: TGroupBox;
    ListView: TListView;
    OpenDialog: TOpenDialog;
    CnLangManager: TCnLangManager;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    CnLangTranslator1: TCnLangTranslator;
    tsSource: TTabSheet;
    grpSource: TGroupBox;
    btnSrcOpen: TSpeedButton;
    btnSrcBrowse: TSpeedButton;
    rbSrcFile: TRadioButton;
    edtSrcFile: TEdit;
    rbSrcDir: TRadioButton;
    edtSrcDir: TEdit;
    chkSrcSubDirs: TCheckBox;
    chkSrcReadOnly: TCheckBox;
    lblSrcConvertType: TLabel;
    cbbSrcConv: TComboBox;
    grpSrcResult: TGroupBox;
    lvSrcResult: TListView;
    lblSrcExt: TLabel;
    dlgOpen: TOpenDialog;
    cbbSrcFileType: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbFileClick(Sender: TObject);
    procedure sbDirClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure rbFileClick(Sender: TObject);
    procedure btnBinToTxtClick(Sender: TObject);
    procedure btnTxtToBinClick(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
    procedure btnSrcOpenClick(Sender: TObject);
    procedure btnSrcBrowseClick(Sender: TObject);
  private
    FConvType: TCnSrcConvType;
    FSourcePattern: string;
    procedure ConvertAFormFile(const FileName: string);
    procedure FormFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure BinToTextFile(const FileName: string);
    procedure BinToTextFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure TextToBinFile(const FileName: string);
    procedure TextToBinFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);

    procedure ConvertASourceFile(const FileName: string; ConvType: TCnSrcConvType);
    procedure SourceFileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);

    function InternalConvertSource(const FileName: string;
      ConvType: TCnSrcConvType): TCnSrcConvertResult;
    function InternalToUtf8(const FileName: string): TCnSrcConvertResult;
    function InternalToUtf16(const FileName: string): TCnSrcConvertResult;
    function InternalToAnsi(const FileName: string): TCnSrcConvertResult;
    function InternalToCRLF(const FileName: string): TCnSrcConvertResult;
    function InternalToLF(const FileName: string): TCnSrcConvertResult;
  protected
    procedure DoCreate; override;
    procedure TranslateStrings;
  public

  end;

var
  CnDTMainForm: TCnDTMainForm;

implementation

uses
  CnWizDfm6To5, CnCommon, CnConsts, Registry, CnWizLangID, CnWideStrings;

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  csSection = 'CnDfm6To5';
  csSelectFile = 'SelectFile';
  csFileName = 'FileName';
  csDirName = 'DirName';
  csSubDirs = 'SubDirs';
  csReadOnly = 'ReadOnly';

var
  SCnErrorCaption: string = 'Error';
  SCnInfoCaption: string = 'Hint';
  SCnSelectDir: string = 'Please Select the Directory';
  SCnOpenFileError: string = 'File Does not Exist.';
  SCnDirNotExists: string = 'Directory Does not Exist.';
  SCnSucc: string = 'Convert Successfully.';
  SCnOpenFail: string = 'Open Failure.';
  SCnSaveFail: string = 'Save Failure.';
  SCnInvalidFormat: string = 'Invalid File Format.';
  SCnAbout: string = 'DFM/Source File Convert Tool' + #13#10#13#10 +
    'This tool can be used to Convert Forms generated by Delphi 6/7' + #13#10 +
    'or C++Builder 6 or Above to Delphi 5 or C++ Builder 5 Format.' + #13#10 +
    'Including Text and Binary Format Conversions.' + #13#10#13#10 +
    'UTF-8/UTF-16/ANSI Source Format and CRLF/LF Line Break Conversions are also Supported.' + #13#10#13#10 +
    'Author: Zhou JingYu (zjy@cnpack.org)' + #13#10 +
    'Multilang: Liu Xiao (master@cnpack.org)' + #13#10 +
    'Copyright (C)2001-2026 CnPack Team';

  SCnResults: array[TCnDFMConvertResult] of PString =
    (@SCnSucc, @SCnOpenFail, @SCnSaveFail, @SCnInvalidFormat);

  SCnSrcResults: array[TCnSrcConvertResult] of PString =
    (@SCnSucc, @SCnOpenFail, @SCnSaveFail, @SCnInvalidFormat);

procedure TCnDTMainForm.FormCreate(Sender: TObject);
begin
  pgcMain.ActivePageIndex := 0;
  cbbSrcConv.ItemIndex := 0;

  with TRegistryIniFile.Create(MakePath(SCnPackRegPath) + SCnPackToolRegPath) do
  try
    rbFile.Checked := ReadBool(csSection, csSelectFile, True);
    rbDir.Checked := not rbFile.Checked;
    edtFile.Text := ReadString(csSection, csFileName, '');
    edtDir.Text := ReadString(csSection, csDirName, '');
    cbSubDirs.Checked := ReadBool(csSection, csSubDirs, True);
    cbReadOnly.Checked := ReadBool(csSection, csReadOnly, True);
    chkSrcSubDirs.Checked := ReadBool(csSection, csSubDirs, True);
    chkSrcReadOnly.Checked := ReadBool(csSection, csReadOnly, True);
    rbFileClick(nil);
  finally
    Free;
  end;

  Application.Title := Caption;
end;

procedure TCnDTMainForm.FormDestroy(Sender: TObject);
begin
  with TRegistryIniFile.Create(MakePath(SCnPackRegPath) + SCnPackToolRegPath) do
  try
    WriteBool(csSection, csSelectFile, rbFile.Checked);
    WriteString(csSection, csFileName, edtFile.Text);
    WriteString(csSection, csDirName, edtDir.Text);
    WriteBool(csSection, csSubDirs, cbSubDirs.Checked);
    WriteBool(csSection, csReadOnly, cbReadOnly.Checked);
  finally
    Free;
  end;
end;

procedure TCnDTMainForm.ConvertAFormFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := DFM6To5(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]^);
  end;
end;

procedure TCnDTMainForm.FormFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') then
    ConvertAFormFile(FileName);
end;

procedure TCnDTMainForm.btnStartClick(Sender: TObject);
begin
  if pgcMain.ActivePage = tsDFM then
  begin
    ListView.Items.Clear;

    if rbFile.Checked then
    begin
      if FileExists(edtFile.Text) then
        ConvertAFormFile(edtFile.Text)
      else
        ErrorDlg(SCnOpenFileError, SCnErrorCaption);
    end
    else
    begin
      if not DirectoryExists(edtDir.Text) then
        ErrorDlg(SCnDirNotExists, SCnErrorCaption)
      else
      begin
        FindFile(edtDir.Text, '*.*', FormFileCallBack, nil, cbSubDirs.Checked);
      end;
    end;
  end
  else
  begin
    lvSrcResult.Items.Clear;

    FConvType := TCnSrcConvType(cbbSrcConv.ItemIndex);
    FSourcePattern := LowerCase(cbbSrcFileType.Text);

    if rbSrcFile.Checked then
    begin
      if FileExists(edtSrcFile.Text) then
        ConvertASourceFile(edtSrcFile.Text, FConvType)
      else
        ErrorDlg(SCnOpenFileError, SCnErrorCaption);
    end
    else
    begin
      if not DirectoryExists(edtSrcDir.Text) then
        ErrorDlg(SCnDirNotExists, SCnErrorCaption)
      else
      begin
        FindFile(edtSrcDir.Text, '*.*', SourceFileCallBack, nil, cbSubDirs.Checked);
      end;
    end;
  end;
end;

procedure TCnDTMainForm.sbFileClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    edtFile.Text := OpenDialog.FileName;
end;

procedure TCnDTMainForm.sbDirClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtDir.Text;
  if GetDirectory(SCnSelectDir, Dir) then
    edtDir.Text := Dir;
end;

procedure TCnDTMainForm.rbFileClick(Sender: TObject);
begin
  edtFile.Enabled := rbFile.Checked;
  sbFile.Enabled := rbFile.Checked;
  edtDir.Enabled := rbDir.Checked;
  sbDir.Enabled := rbDir.Checked;
  cbSubDirs.Enabled := rbDir.Checked;

  edtSrcFile.Enabled := rbSrcFile.Checked;
  btnSrcOpen.Enabled := rbSrcFile.Checked;
  edtSrcDir.Enabled := rbSrcDir.Checked;
  btnSrcBrowse.Enabled := rbSrcDir.Checked;
  chkSrcSubDirs.Enabled := rbSrcDir.Checked;
end;

procedure TCnDTMainForm.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnAbout, SCnInfoCaption);
end;

procedure TCnDTMainForm.lblURLClick(Sender: TObject);
begin
  RunFile(SCnPackUrl);
end;

procedure TCnDTMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCnDTMainForm.DoCreate;
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

procedure TCnDTMainForm.TranslateStrings;
begin
  TranslateStr(SCnErrorCaption, 'SCnErrorCaption');
  TranslateStr(SCnInfoCaption, 'SCnInfoCaption');
  TranslateStr(SCnSelectDir, 'SCnSelectDir');
  TranslateStr(SCnOpenFileError, 'SCnOpenFileError');
  TranslateStr(SCnDirNotExists, 'SCnDirNotExists');
  TranslateStr(SCnSucc, 'SCnSucc');
  TranslateStr(SCnOpenFail, 'SCnOpenFail');
  TranslateStr(SCnSaveFail, 'SCnSaveFail');
  TranslateStr(SCnInvalidFormat, 'SCnInvalidFormat');
  TranslateStr(SCnAbout, 'SCnAbout');
end;

procedure TCnDTMainForm.btnBinToTxtClick(Sender: TObject);
begin
  ListView.Items.Clear;

  if rbFile.Checked then
  begin
    if FileExists(edtFile.Text) then
      BinToTextFile(edtFile.Text)
    else
      ErrorDlg(SCnOpenFileError, SCnErrorCaption);
  end
  else
  begin
    if not DirectoryExists(edtDir.Text) then
      ErrorDlg(SCnDirNotExists, SCnErrorCaption)
    else
    begin
      FindFile(edtDir.Text, '*.*', BinToTextFileCallBack, nil, cbSubDirs.Checked);
    end;
  end;
end;

procedure TCnDTMainForm.btnTxtToBinClick(Sender: TObject);
begin
  ListView.Items.Clear;

  if rbFile.Checked then
  begin
    if FileExists(edtFile.Text) then
      TextToBinFile(edtFile.Text)
    else
      ErrorDlg(SCnOpenFileError, SCnErrorCaption);
  end
  else
  begin
    if not DirectoryExists(edtDir.Text) then
      ErrorDlg(SCnDirNotExists, SCnErrorCaption)
    else
    begin
      FindFile(edtDir.Text, '*.*', TextToBinFileCallBack, nil, cbSubDirs.Checked);
    end;
  end;
end;

procedure TCnDTMainForm.BinToTextFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := BinToText(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]^);
  end;
end;

procedure TCnDTMainForm.BinToTextFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') or
    SameText(_CnExtractFileExt(FileName), '.XFM') then
    BinToTextFile(FileName);
end;

procedure TCnDTMainForm.TextToBinFile(const FileName: string);
var
  Res: TCnDFMConvertResult;
begin
  if cbReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := TextToBin(FileName);
  with ListView.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnResults[Res]^);
  end;
end;

procedure TCnDTMainForm.TextToBinFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameText(_CnExtractFileExt(FileName), '.DFM') or
    SameText(_CnExtractFileExt(FileName), '.XFM') then
    TextToBinFile(FileName);
end;

procedure TCnDTMainForm.pgcMainChange(Sender: TObject);
begin
  btnBinToTxt.Enabled := pgcMain.ActivePage = tsDFM;
  btnTxtToBin.Enabled := pgcMain.ActivePage = tsDFM;
end;

procedure TCnDTMainForm.btnSrcOpenClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    edtSrcFile.Text := dlgOpen.FileName;
end;

procedure TCnDTMainForm.btnSrcBrowseClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtSrcDir.Text;
  if GetDirectory(SCnSelectDir, Dir) then
    edtSrcDir.Text := Dir;
end;

procedure TCnDTMainForm.ConvertASourceFile(const FileName: string;
  ConvType: TCnSrcConvType);
var
  Res: TCnSrcConvertResult;
begin
  if chkSrcReadOnly.Checked then
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

  Res := InternalConvertSource(FileName, ConvType);
  with lvSrcResult.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add(SCnSrcResults[Res]^);
  end;
end;

procedure TCnDTMainForm.SourceFileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Ext: string;
begin
  if (FSourcePattern = '') or (FSourcePattern = '*') or (FSourcePattern = '*.*') then
    ConvertASourceFile(FileName, FConvType)
  else
  begin
    Ext := LowerCase(ExtractFileExt(FileName));
    if Pos(Ext, FSourcePattern) > 0 then
      ConvertASourceFile(FileName, FConvType);
  end;
end;

function TCnDTMainForm.InternalConvertSource(const FileName: string;
  ConvType: TCnSrcConvType): TCnSrcConvertResult;
begin
  case ConvType of
    sctUtf8:
      Result := InternalToUtf8(FileName);
    sctUtf16:
      Result := InternalToUtf16(FileName);
    sctAnsi:
      Result := InternalToAnsi(FileName);
    sctCRLF:
      Result := InternalToCRLF(FileName);
    sctLF:
      Result := InternalToLF(FileName);
  else
    Result := scrInvalidFormat;
  end;
end;

function TCnDTMainForm.InternalToAnsi(const FileName: string): TCnSrcConvertResult;
var
  List: TCnWideStringList;
  TmpFile: string;
begin
  Result := scrOpenError;
  if not FileExists(FileName) then
    Exit;

  List := TCnWideStringList.Create;
  try
    try
      List.LoadFromFile(FileName);
    except
      Result := scrOpenError;
      Exit;
    end;

    TmpFile := FileName + '.~tmp';
    try
      List.WriteBOM := False;
      List.SaveToFile(TmpFile, wlfAnsi);
    except
      Result := scrSaveError;
      Exit;
    end;
  finally
    List.Free;
  end;

  try
    DeleteFile(FileName);
    if not RenameFile(TmpFile, FileName) then
    begin
      Result := scrSaveError;
      Exit;
    end;
  except
    Result := scrSaveError;
    Exit;
  end;

  Result := scrSucc;
end;

function TCnDTMainForm.InternalToCRLF(const FileName: string): TCnSrcConvertResult;
var
  List: TCnWideStringList;
  TmpFile: string;
  Fmt: TCnWideListFormat;
begin
  Result := scrOpenError;
  if not FileExists(FileName) then
    Exit;

  List := TCnWideStringList.Create;
  try
    try
      List.LoadFromFile(FileName);
    except
      Result := scrOpenError;
      Exit;
    end;

    Fmt := List.LoadFormat;
    List.UseSingleLF := False;

    TmpFile := FileName + '.~tmp';
    try
      List.WriteBOM := List.HasBOM;
      List.SaveToFile(TmpFile, Fmt);
    except
      Result := scrSaveError;
      Exit;
    end;
  finally
    List.Free;
  end;

  try
    DeleteFile(FileName);
    if not RenameFile(TmpFile, FileName) then
    begin
      Result := scrSaveError;
      Exit;
    end;
  except
    Result := scrSaveError;
    Exit;
  end;

  Result := scrSucc;
end;

function TCnDTMainForm.InternalToLF(const FileName: string): TCnSrcConvertResult;
var
  List: TCnWideStringList;
  TmpFile: string;
  Fmt: TCnWideListFormat;
begin
  Result := scrOpenError;
  if not FileExists(FileName) then
    Exit;

  List := TCnWideStringList.Create;
  try
    try
      List.LoadFromFile(FileName);
    except
      Result := scrOpenError;
      Exit;
    end;

    Fmt := List.LoadFormat;
    List.UseSingleLF := True;

    TmpFile := FileName + '.~tmp';
    try
      List.WriteBOM := List.HasBOM;
      List.SaveToFile(TmpFile, Fmt);
    except
      Result := scrSaveError;
      Exit;
    end;
  finally
    List.Free;
  end;

  try
    DeleteFile(FileName);
    if not RenameFile(TmpFile, FileName) then
    begin
      Result := scrSaveError;
      Exit;
    end;
  except
    Result := scrSaveError;
    Exit;
  end;

  Result := scrSucc;
end;

function TCnDTMainForm.InternalToUtf16(const FileName: string): TCnSrcConvertResult;
var
  List: TCnWideStringList;
  TmpFile: string;
begin
  Result := scrOpenError;
  if not FileExists(FileName) then
    Exit;

  List := TCnWideStringList.Create;
  try
    try
      List.LoadFromFile(FileName);
    except
      Result := scrOpenError;
      Exit;
    end;

    TmpFile := FileName + '.~tmp';
    try
      List.WriteBOM := True;
      List.SaveToFile(TmpFile, wlfUnicode);
    except
      Result := scrSaveError;
      Exit;
    end;
  finally
    List.Free;
  end;

  try
    DeleteFile(FileName);
    if not RenameFile(TmpFile, FileName) then
    begin
      Result := scrSaveError;
      Exit;
    end;
  except
    Result := scrSaveError;
    Exit;
  end;

  Result := scrSucc;
end;

function TCnDTMainForm.InternalToUtf8(const FileName: string): TCnSrcConvertResult;
var
  List: TCnWideStringList;
  TmpFile: string;
begin
  Result := scrOpenError;
  if not FileExists(FileName) then
    Exit;

  List := TCnWideStringList.Create;
  try
    try
      List.LoadFromFile(FileName);
    except
      Result := scrOpenError;
      Exit;
    end;

    TmpFile := FileName + '.~tmp';
    try
      List.WriteBOM := True;
      List.SaveToFile(TmpFile, wlfUtf8);
    except
      Result := scrSaveError;
      Exit;
    end;
  finally
    List.Free;
  end;

  try
    DeleteFile(FileName);
    if not RenameFile(TmpFile, FileName) then
    begin
      Result := scrSaveError;
      Exit;
    end;
  except
    Result := scrSaveError;
    Exit;
  end;

  Result := scrSucc;
end;

end.

