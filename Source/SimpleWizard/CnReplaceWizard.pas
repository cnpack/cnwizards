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

unit CnReplaceWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������ļ��滻ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���ڲ����� Ansi �滻�������� Unicode ������
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.03.01 V1.0
*               Liu Xiao �����滻��ָ���ǩ�Ļ���
*           2003.03.01 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNREPLACEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, ToolsAPI, FileCtrl, Math, Contnrs, AsRegExpr,
  CnConsts, CnCommon, CnWizClasses, CnWizConsts, CnWizUtils, CnWizEditFiler, CnNative,
  CnWizSearch, CnIni, CnWizMultiLang {$IFDEF IDE_WIDECONTROL}, CnWideStrings {$ENDIF};

type

{ TCnReplaceWizardForm }

  TCnReplaceStyle = (rsUnit, rsProjectGroups, rsProject, rsOpenUnits, rsDir);

  TCnReplaceWizardForm = class(TCnTranslateForm)
    tbOptions: TGroupBox;
    gbText: TGroupBox;
    Label1: TLabel;
    cbbSrc: TComboBox;
    Label2: TLabel;
    cbbDst: TComboBox;
    rgReplaceStyle: TRadioGroup;
    gbDir: TGroupBox;
    cbCaseSensitive: TCheckBox;
    cbWholeWord: TCheckBox;
    btnReplace: TButton;
    btnClose: TButton;
    btnHelp: TButton;
    Label3: TLabel;
    btnSelectDir: TButton;
    cbbDir: TComboBox;
    Label4: TLabel;
    cbbMask: TComboBox;
    cbSubDirs: TCheckBox;
    cbRegEx: TCheckBox;
    cbANSICompatible: TCheckBox;
    rbNormal: TRadioButton;
    rbRegExpr: TRadioButton;
    chkUseSub: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure rgReplaceStyleClick(Sender: TObject);
    procedure cbbDirDropDown(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure rbNormalClick(Sender: TObject);
  private
    FIni: TCustomIniFile;
    FSearcher: TCnSearcher;
    
    function GetDestText: string;
    function GetDir: string;
    function GetFileMask: string;
    function GetIncludeSubDirs: Boolean;
    function GetReplaceStyle: TCnReplaceStyle;
    function GetSearchOption: TSearchOptions;
    function GetSourceText: string;
    procedure LoadSettings;
    procedure SaveSettings;
    function GetANSICompatible: Boolean;
  protected
    function GetHelpTopic: string; override;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile;
      ASearcher: TCnSearcher);

    property SearchOption: TSearchOptions read GetSearchOption;
    property ReplaceStyle: TCnReplaceStyle read GetReplaceStyle;
    property SourceText: string read GetSourceText;
    property DestText: string read GetDestText;
    property Dir: string read GetDir;
    property FileMask: string read GetFileMask;
    property IncludeSubDirs: Boolean read GetIncludeSubDirs;
    property ANSICompatible: Boolean read GetANSICompatible;
  end;

//==============================================================================
// �����ļ��滻ר��
//==============================================================================

{ TCnReplaceWizard }

  TCnReplaceWizard = class(TCnMenuWizard)
  private
    FUseRegExpr: Boolean;
    FUseSub: Boolean;
    FSearcher: TCnSearcher;
    FRegExpr: TRegExpr;
    FInStream: TMemoryStream;
    FOutStream: TMemoryStream;
    FLastInStreamPos: Integer;
    FFoundCount: Integer;
    FCurrCount: Integer;
    FFileCount: Integer;
    FDestText: string;
    FMasks: string;
    FAbort: Boolean;
    FOpenInIDE: Boolean;
    procedure OnFound(Sender: TObject; LineNo: Integer; LineOffset: Integer;
      const Line: string; SPos, EPos: Integer);
    function OnRegExprReplace(ARegExpr : TRegExpr): string;
    procedure OnFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure QueryContinue(const Msg: string);
    procedure DoNormalReplace(const FileName: string);
    procedure DoRegExprReplace(const FileName: string);
    procedure ReplaceFile(const FileName: string);
    procedure ReplaceProject(Project: IOTAProject);
    procedure ReplaceProjectGroup(ProjectGroup: IOTAProjectGroup);
    procedure ReplaceOpenUnits;
    procedure ReplaceDir(const Dir, FileMask: string; IncludeSubDirs: Boolean);
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNREPLACEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNREPLACEWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

{ TCnReplaceWizardForm }

constructor TCnReplaceWizardForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile; ASearcher: TCnSearcher);
begin
  Create(AOwner);
  FIni := AIni;
  FSearcher := ASearcher;
end;

procedure TCnReplaceWizardForm.FormCreate(Sender: TObject);
var
  Sel: string;
  Idx: Integer;
begin
  LoadSettings;
  Sel := CnOtaGetCurrentSelection;      // ȡ��ǰѡ����ı�
  if (Pos(#10, Sel) > 0) or (Pos(#13, Sel) > 0) then
    Sel := Copy(Sel, 1, Min(Pos(#13, Sel), Pos(#10, Sel)) - 1);

  if Sel = '' then
    CnOtaGetCurrPosToken(Sel, Idx, False); // ȡ��ǰ����µı�ʶ��

  if Sel <> '' then
    cbbSrc.Text := Sel;
end;

procedure TCnReplaceWizardForm.FormDestroy(Sender: TObject);
begin
  if ModalResult = mrOk then
    SaveSettings;
end;

procedure TCnReplaceWizardForm.btnReplaceClick(Sender: TObject);
begin
  if not QueryDlg(SCnReplaceWarning, True) then
    Exit;
    
  if cbbSrc.Text = '' then
  begin
    ErrorDlg(SCnReplaceSourceEmpty);
    Exit;
  end;

  try
    FSearcher.SearchOptions := SearchOption;
    FSearcher.SetPattern(cbbSrc.Text);
    FSearcher.ANSICompatible := ANSICompatible;
  except
    on E: EPatternError do
    begin
      ErrorDlg(E.Message);
      Exit;
    end;
  end;

  if ReplaceStyle = rsDir then
  begin
    if Dir = '' then
    begin
      ErrorDlg(SCnReplaceDirEmpty);
      Exit;
    end;

    if not DirectoryExists(Dir) then
    begin
      ErrorDlg(SCnReplaceDirNotExists);
      Exit;
    end;
  end;

  ModalResult := mrOk;
end;

const
  csSourceText = 'SourceText';
  csSourceTexts = 'SourceTexts';
  csDestText = 'DestText';
  csDestTexts = 'DestTexts';
  csUseRegExpr = 'UseRegExpr';
  csCaseSensitive = 'CaseSensitive';
  csWholeWord = 'WholeWord';
  csRegEx = 'RegEx';
  csIncludeForm = 'IncludeForm';
  csReplaceStyle = 'ReplaceStyle';
  csUseSub = 'UseSub';
  csDir = 'Dir';
  csDirs = 'Dirs';
  csMask = 'Mask';
  csMasks = 'Masks';
  csSubDirs = 'SubDirs';
  csANSICompatible = 'ANSICompatible';

procedure TCnReplaceWizardForm.LoadSettings;
begin
  with TCnIniFile.Create(FIni) do
  try
    cbbSrc.Text := ReadString('', csSourceText, '');
    ReadStrings(csSourceTexts, cbbSrc.Items);
    cbbDst.Text := ReadString('', csDestText, '');
    ReadStrings(csDestTexts, cbbDst.Items);
    rbNormal.Checked := not ReadBool('', csUseRegExpr, False);
    rbRegExpr.Checked := not rbNormal.Checked;
    cbCaseSensitive.Checked := ReadBool('', csCaseSensitive, False);
    cbWholeWord.Checked := ReadBool('', csWholeWord, False);
    cbRegEx.Checked := ReadBool('', csRegEx, False);
    cbANSICompatible.Checked := ReadBool('', csANSICompatible, False);
    chkUseSub.Checked := ReadBool('', csUseSub, False);
    rgReplaceStyle.ItemIndex := ReadInteger('', csReplaceStyle, 0);
    cbbDir.Text := ReadString('', csDir, '');
    ReadStrings(csDirs, cbbDir.Items);
    cbbMask.Text := ReadString('', csMask, '');
    ReadStrings(csMasks, cbbMask.Items);
    cbSubDirs.Checked := ReadBool('', csSubDirs, True);

    rgReplaceStyleClick(nil);
    rbNormalClick(nil);
  finally
    Free;
  end;
end;

procedure TCnReplaceWizardForm.SaveSettings;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TComboBox then
      AddComboBoxTextToItems(TComboBox(Components[I]));

  with TCnIniFile.Create(FIni) do
  try
    WriteString('', csSourceText, cbbSrc.Text);
    WriteStrings(csSourceTexts, cbbSrc.Items);
    WriteString('', csDestText, cbbDst.Text);
    WriteStrings(csDestTexts, cbbDst.Items);
    WriteBool('', csCaseSensitive, cbCaseSensitive.Checked);
    WriteBool('', csWholeWord, cbWholeWord.Checked);
    WriteBool('', csRegEx, cbRegEx.Checked);
    WriteBool('', csANSICompatible, cbANSICompatible.Checked);
    WriteBool('', csUseRegExpr, rbRegExpr.Checked);
    WriteBool('', csUseSub, chkUseSub.Checked);
    WriteInteger('', csReplaceStyle, rgReplaceStyle.ItemIndex);
    WriteString('', csDir, cbbDir.Text);
    WriteStrings(csDirs, cbbDir.Items);
    WriteString('', csMask, cbbMask.Text);
    WriteStrings(csMasks, cbbMask.Items);
    WriteBool('', csSubDirs, cbSubDirs.Checked);
  finally
    Free;
  end;
end;

procedure TCnReplaceWizardForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnReplaceWizardForm.GetHelpTopic: string;
begin
  Result := 'CnReplaceWizard';
end;

procedure TCnReplaceWizardForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := cbbDir.Text;
  if GetDirectory(SCnReplaceSelectDirCaption, NewDir) then
    cbbDir.Text := NewDir;
end;

procedure TCnReplaceWizardForm.rgReplaceStyleClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to gbDir.ControlCount - 1 do
    gbDir.Controls[I].Enabled := ReplaceStyle = rsDir;
end;

procedure TCnReplaceWizardForm.rbNormalClick(Sender: TObject);
begin
  cbCaseSensitive.Enabled := rbNormal.Checked;
  cbWholeWord.Enabled := rbNormal.Checked;
  cbRegEx.Enabled := rbNormal.Checked;
  cbANSICompatible.Enabled := rbNormal.Checked;
  chkUseSub.Enabled := rbRegExpr.Checked;
end;

procedure TCnReplaceWizardForm.cbbDirDropDown(Sender: TObject);
var
  I: Integer;
  MaxWidth: Integer;
  Bitmap: Graphics.TBitmap;
begin
  MaxWidth := cbbDir.Width;
  Bitmap := Graphics.TBitmap.Create;
  try
    Bitmap.Canvas.Font.Assign(cbbDir.Font);
    for I := 0 to cbbDir.Items.Count - 1 do
      MaxWidth := Max(MaxWidth, Bitmap.Canvas.TextWidth(cbbDir.Items[I]) + 10);
  finally;
    Bitmap.Free;
  end;
  if cbbDir.Items.Count > cbbDir.DropDownCount then
    Inc(MaxWidth,  GetSystemMetrics(SM_CXVSCROLL));
  MaxWidth := Min(400, MaxWidth);
  if MaxWidth > cbbDir.Width then
    SendMessage(cbbDir.Handle, CB_SETDROPPEDWIDTH, MaxWidth, 0)
  else
    SendMessage(cbbDir.Handle, CB_SETDROPPEDWIDTH, 0, 0);
end;

function TCnReplaceWizardForm.GetANSICompatible: Boolean;
begin
  Result := cbANSICompatible.Checked;
end;

function TCnReplaceWizardForm.GetDestText: string;
begin
  Result := cbbDst.Text;
end;

function TCnReplaceWizardForm.GetDir: string;
begin
  Result := cbbDir.Text;
end;

function TCnReplaceWizardForm.GetFileMask: string;
begin
  Result := cbbMask.Text;
end;

function TCnReplaceWizardForm.GetIncludeSubDirs: Boolean;
begin
  Result := cbSubDirs.Checked;
end;

function TCnReplaceWizardForm.GetReplaceStyle: TCnReplaceStyle;
begin
  Result := TCnReplaceStyle(rgReplaceStyle.ItemIndex);
end;

function TCnReplaceWizardForm.GetSearchOption: TSearchOptions;
begin
  Result := [];
  if cbCaseSensitive.Checked then Include(Result, soCaseSensitive);
  if cbWholeWord.Checked then Include(Result, soWholeWord);
  if cbRegEx.Checked then Include(Result, soRegEx);
end;

function TCnReplaceWizardForm.GetSourceText: string;
begin
  Result := cbbSrc.Text;
end;

//==============================================================================
// �����滻ר��
//==============================================================================

{ TCnReplaceWizard }

constructor TCnReplaceWizard.Create;
begin
  inherited;
  FInStream := TMemoryStream.Create;
  FOutStream := TMemoryStream.Create;
end;

destructor TCnReplaceWizard.Destroy;
begin
  FInStream.Free;
  FOutStream.Free;
  inherited;
end;

procedure TCnReplaceWizard.Execute;
var
  FileName: string;
begin
  FSearcher := nil;
  FRegExpr := nil;

  try
    FSearcher := TCnSearcher.Create;
    FRegExpr := TRegExpr.Create;
    FSearcher.OnFound := OnFound;
    with TCnReplaceWizardForm.CreateEx(nil, CreateIniFile, FSearcher) do
    try
      if ShowModal = mrOk then
      begin
        FUseRegExpr := rbRegExpr.Checked;
        FUseSub := chkUseSub.Checked;
        if FUseRegExpr then
          FRegExpr.Expression := SourceText;
        FDestText := DestText;
        FFoundCount := 0;
        FCurrCount := 0;
        FFileCount := 0;
        FAbort := False;
        case ReplaceStyle of
          rsProjectGroups:
            begin
              ReplaceProjectGroup(CnOtaGetProjectGroup);
            end;
          rsProject:
            begin
              ReplaceProject(CnOtaGetCurrentProject);
            end;
          rsOpenUnits:
            begin
              ReplaceOpenUnits;
            end;
          rsDir:
            begin
              ReplaceDir(Dir, FileMask, IncludeSubDirs);
            end;
        else                            // rsUnit
          begin
            FileName := CnOtaGetFileNameOfCurrentModule(True);
            ReplaceFile(FileName);
          end;
        end;
        
        if not FAbort then
          InfoDlg(Format(SCnReplaceResult, [FFileCount, FFoundCount]));
      end;
    finally
      Free;
      FInStream.Size := 0;
      FOutStream.Size := 0;
    end;
  finally
    FreeAndNil(FSearcher);
    FreeAndNil(FRegExpr);
  end;
end;

procedure TCnReplaceWizard.QueryContinue(const Msg: string);
begin
  FAbort := Application.MessageBox(PChar(Msg + #13#10#13#10 +
    SCnReplaceQueryContinue), PChar(SCnError),
    MB_YESNO + MB_ICONSTOP) = IDNO;
end;

procedure TCnReplaceWizard.ReplaceFile(const FileName: string);
var
  Reader: TCnEditFiler;
  IModule: IOTAModule;
  ISourceEditor: IOTASourceEditor;
  IWriter: IOTAEditWriter;
  BookMarkList: TObjectList;
  EditView: IOTAEditView;
{$IFDEF IDE_WIDECONTROL}
  Text: AnsiString;
{$ENDIF}
begin
  Reader := TCnEditFiler.Create(FileName);
  try
    FInStream.Size := 0;
    try
      Reader.SaveToStream(FInStream{$IFDEF IDE_WIDECONTROL}, True{$ENDIF});
      // �õ��� FInStream ȷ��Ϊ Ansi
    except
      on E: Exception do
      begin
        QueryContinue(E.Message);
        Exit;
      end;
    end;
    FOpenInIDE := Reader.Mode = mmModule;
  finally
    Reader.Free;
  end;

  FCurrCount := 0;
  if FUseRegExpr then
    DoRegExprReplace(_CnExtractFileName(FileName))
  else
    DoNormalReplace(_CnExtractFileName(FileName));
  BookMarkList := nil;

  if FOutStream.Size > 0 then  // ִ�й��滻��FOutStream ��һֱ�� Ansi �����ݣ�û�� Utf8/Utf16 ����
  begin
    if FOpenInIDE then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('ReplaceFile is in IDE: ' + FileName);
{$ENDIF}
      try
        IModule := CnOtaGetModule(FileName);
        if Assigned(IModule) then
        begin
          ISourceEditor := CnOtaGetSourceEditorFromModule(IModule, FileName);
          if Assigned(ISourceEditor) then
          begin
            IWriter := ISourceEditor.CreateWriter;
            if Assigned(IWriter) then
            begin
              BookMarkList := TObjectList.Create(True);
              EditView := CnOtaGetTopMostEditView(ISourceEditor);
              // �ȱ���ԭ�е���ǩ
              if EditView <> nil then
                SaveBookMarksToObjectList(EditView, BookMarkList);

              try
{$IFDEF IDE_WIDECONTROL}
                // BDS ����Ҫ�� Utf8 ת��
                Text := CnAnsiToUtf8(PAnsiChar(FOutStream.Memory));
                FOutStream.Size := Length(Text) + 1;
                FOutStream.Position := 0;
                FOutStream.Write(PAnsiChar(Text)^, Length(Text) + 1);
{$ENDIF}
                IWriter.DeleteTo(MaxInt);
                IWriter.Insert(FOutStream.Memory); // Writer д�������Ҫ��Ansi/Utf8/Utf8

                Inc(FFileCount);
                Inc(FFoundCount, FCurrCount);

                // �滻��Ϻ�ԭ��ǩ
                if EditView <> nil then
                  LoadBookMarksFromObjectList(EditView, BookMarkList);
                Exit;
              finally
                IWriter := nil;
                FreeAndNil(BookMarkList);
              end;
            end;
          end;
        end;
        QueryContinue(Format(SCnSaveEditFileError, [FileName]));
      except
        QueryContinue(Format(SCnSaveEditFileError, [FileName]));
      end;
    end
    else
    begin
      try
        // ����Ϊ�ļ�ʱȥ����β���� #0 �ַ�
        if PByte(TCnNativeUInt(FOutStream.Memory) + FOutStream.Size - 1)^ = 0 then
          FOutStream.Size := FOutStream.Size - 1;

        // �� Reader ���棬���� BDS ���ϱ��ֱ���
        Reader := TCnEditFiler.Create(FileName);
        try
          FOutStream.Position := 0;
          try
            Reader.ReadFromStream(FOutStream{$IFDEF IDE_WIDECONTROL}, True{$ENDIF});
          except
            on E: Exception do
            begin
              QueryContinue(E.Message);
            end;
          end;
        finally
          Reader.Free;
        end;

        Inc(FFileCount);
        Inc(FFoundCount, FCurrCount);
      except
        QueryContinue(Format(SCnSaveFileError, [FileName]));
      end;
    end;
  end
  else
    Inc(FFileCount);
end;

procedure TCnReplaceWizard.ReplaceProject(Project: IOTAProject);
var
  I: Integer;
  FileName: string;
begin
  if not Assigned(Project) then
    Exit;

  if IsDpr(Project.FileName) then
    ReplaceFile(Project.FileName);        // ���� dpr �����ļ������������� bdsproj/dproj ��
  if FAbort then Exit;
  
  for I := 0 to Project.GetModuleCount - 1 do
  begin
    FileName := Project.GetModule(I).FileName;
    if IsSourceModule(FileName) then
      ReplaceFile(FileName);
{$IFDEF BCB}
    if IsCpp(FileName) or IsC(FileName) then // BCB ���滻���ͷ�ļ�
    begin
      FileName := _CnChangeFileExt(FileName, '.h');
      if FileExists(FileName) then
        ReplaceFile(FileName);
    end;
{$ENDIF}
    if FAbort then Exit;
  end;
end;

procedure TCnReplaceWizard.ReplaceProjectGroup(
  ProjectGroup: IOTAProjectGroup);
var
  I: Integer;
begin
  if not Assigned(ProjectGroup) then Exit;

  for I := 0 to ProjectGroup.ProjectCount - 1 do
  begin
    ReplaceProject(ProjectGroup.Projects[I]);
    if FAbort then Exit;
  end;
end;

procedure TCnReplaceWizard.ReplaceOpenUnits;
var
  iModuleServices: IOTAModuleServices;
  I: Integer;
  FileName: string;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);

  for I := 0 to iModuleServices.GetModuleCount - 1 do
  begin
    FileName := CnOtaGetFileNameOfModule(iModuleServices.GetModule(I));
    ReplaceFile(FileName);
    if FAbort then Exit;
  end;
end;

procedure TCnReplaceWizard.OnFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if FileMatchesExts(FileName, FMasks) then
  begin
    ReplaceFile(FileName);
    Abort := FAbort;
  end;
end;

procedure TCnReplaceWizard.ReplaceDir(const Dir, FileMask: string;
  IncludeSubDirs: Boolean);
begin
  if FileMask = '' then
    FMasks := SCnDefSourceMask
  else
    FMasks := FileMask;
    
  FindFile(Dir, '*.*', OnFindFile, nil, IncludeSubDirs);
end;

procedure TCnReplaceWizard.DoNormalReplace(const FileName: string);
begin
  FInStream.Position := 0;
  FOutStream.Size := 0;
  FLastInStreamPos := 0;

  FSearcher.FileName := FileName;
  FSearcher.Search(FInStream);

  if FLastInStreamPos > 0 then
  begin
    FOutStream.Write(Pointer(TCnNativeInt(FInStream.Memory) + FLastInStreamPos)^,
      FInStream.Size - FLastInStreamPos);
  end;
end;

procedure TCnReplaceWizard.OnFound(Sender: TObject; LineNo: Integer;
  LineOffset: Integer; const Line: string; SPos, EPos: Integer);
{$IFDEF UNICODE}
var
  DestText: AnsiString;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('LineNo: %d LineOffset: %d SPos: %d EPos: %d', [LineNo,
    LineOffset, SPos, EPos]);
  CnDebugger.LogMsg('Line: ' + Line);
{$ENDIF}

  FOutStream.Write(Pointer(TCnNativeInt(FInStream.Memory) + FLastInStreamPos)^,
    LineOffset + SPos - FLastInStreamPos - 1);

{$IFDEF UNICODE}
  // D2009 �²���ֱ��д Unicode string ��ȥ����ᵼ�½ض�
  DestText := AnsiString(FDestText);
  FOutStream.Write(Pointer(DestText)^, Length(DestText));
{$ELSE}
  FOutStream.Write(Pointer(FDestText)^, Length(FDestText));
{$ENDIF}
  FLastInStreamPos := LineOffset + EPos;

  Inc(FCurrCount);
end;

procedure TCnReplaceWizard.DoRegExprReplace(const FileName: string);
var
  InStr, OutStr: RegExprString;
  MemStr: AnsiString;
begin
  FInStream.Position := 0;
  FOutStream.Size := 0;
  FLastInStreamPos := 0;

  InStr := RegExprString(PAnsiChar(FInStream.Memory));
  OutStr := FRegExpr.ReplaceEx(InStr, OnRegExprReplace);

  if FLastInStreamPos > 0 then
  begin
    MemStr := AnsiString(OutStr);
    FOutStream.Write(PAnsiChar(MemStr)^, Length(MemStr) + 1);
  end;
end;

function TCnReplaceWizard.OnRegExprReplace(ARegExpr: TRegExpr): string;
begin
  if FUseSub then
    Result := ARegExpr.Substitute(FDestText)
  else
    Result := FDestText;
  FLastInStreamPos := ARegExpr.MatchPos[0] + ARegExpr.MatchLen[0];
  Inc(FCurrCount);
end;

function TCnReplaceWizard.GetCaption: string;
begin
  Result := SCnReplaceWizardMenuCaption;
end;

function TCnReplaceWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnReplaceWizard.GetHint: string;
begin
  Result := SCnReplaceWizardMenuHint;
end;

function TCnReplaceWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnReplaceWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnReplaceWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnReplaceWizardComment;
end;

initialization
  RegisterCnWizard(TCnReplaceWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNREPLACEWIZARD}
end.
