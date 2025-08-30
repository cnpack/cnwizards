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

unit CnPas2HtmlWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����ʽ����ת�����ר�ҵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��
* ����ƽ̨��PWin98SE + Delphi 6
* ���ݲ��ԣ����ޣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6��
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.03.31 V1.5
*               ֧�ֱ���ɫ
*           2022.09.23 V1.4
*               ֧�� Unicode
*           2003.04.15 V1.3
*               �޸� Action ���²��ִ��루by yygw��
*           2003.03.09 V1.2
*               ���� TEditReader�����봦����ļ��Ĺ��ܡ�
*           2003.02.28 V1.1
*               �������崦���޸�СBug�����밲װ�������������ú�TXT��ʽ���ơ�
*           2003.02.23 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Clipbrd, ToolsAPI, Forms, Dialogs,
  Controls, IniFiles, ShellAPI, StdCtrls, ComCtrls, FileCtrl, Graphics,
  CnCommon, CnPasConvert, CnConsts, CnWizClasses, CnWizConsts, CnWizUtils,
  {$IFDEF IDE_STRING_ANSI_UTF8} CnWideStrings, {$ENDIF}  CnIni, CnWizIdeUtils,
  CnWizEditFiler, CnWizMultiLang, CnPasConvertTypeFrm;

type

{ TCnPas2HtmlWizard }

  TCnPas2HtmlWizard = class(TCnSubMenuWizard)
  private
    FIdCopySelected: Integer;
    FIdExportUnit: Integer;
    FIdExportOpened: Integer;
    FIdExportDPR: Integer;
    FIdExportBPG: Integer;
    FIdConfig: Integer;
    FDispGauge: Boolean;
    FAutoSave: Boolean;
    FConvertType: TCnPasConvertType;
    FDir: string;
    FSourceHtmlEncode: string;
    FFontArray: array[0..9] of TFont;
    FOpenAfterConvert: Boolean;
    FBackgroundColor: TColor;
    procedure CopyHTMLToClipBoard(HtmlStrBuf: PAnsiChar; SizeH: Integer;
      StrBuf: PAnsiChar; SizeT: Integer);
    function InternalProcessAFile(const Filename, OutputDir: string): Boolean;
    procedure ProcessAProject(Project: IOTAProject; const sDir: string; OpenDir: Boolean = False);
    procedure SetConversionFonts(Conversion: TCnSourceConversion);
    procedure ProcessGauge(Process: Integer);
    function GetFonts(const Index: Integer): TFont;
    procedure SetFonts(const Index: Integer; const Value: TFont);
    procedure SetBackgroundColor(const Value: TColor);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure ConvertStream(SourceType: TCnConvertSourceType; const Title: string;
      InStream, OutStream: TStream; ProcessEvent: TCnSourceConvertProcessEvent = nil);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure AcquireSubActions; override;
    property DispGauge: Boolean read FDispGauge write FDispGauge;
    property AutoSave: Boolean read FAutoSave write FAutoSave;
    property OpenAfterConvert: Boolean read FOpenAfterConvert
      write FOpenAfterConvert;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor;
    property FontBasic: TFont index 0 read GetFonts write SetFonts;
    property FontAssembler: TFont index 1 read GetFonts write SetFonts;
    property FontComment: TFont index 2 read GetFonts write SetFonts;
    property FontDirective: TFont index 3 read GetFonts write SetFonts;
    property FontIdentifier: TFont index 4 read GetFonts write SetFonts;
    property FontKeyWord: TFont index 5 read GetFonts write SetFonts;
    property FontNumber: TFont index 6 read GetFonts write SetFonts;
    property FontSpace: TFont index 7 read GetFonts write SetFonts;
    property FontString: TFont index 8 read GetFonts write SetFonts;
    property FontSymbol: TFont index 9 read GetFonts write SetFonts;
  end;

type

{ TCnPas2HtmlForm }

  TCnPas2HtmlForm = class(TCnTranslateForm)
    SaveDialog: TSaveDialog;
    LabelDisp: TLabel;
    ProgressBar: TProgressBar;
  private
    procedure SetConvertingFileName(const Value: string);
  public
    procedure CreateParams(var Params: TCreateParams); override;
    property ConvertingFileName: string write SetConvertingFileName;
  end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  CnPas2HtmlConfigFrm {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csDispGauge = 'DispGauge';
  csAutoSave = 'SaveBeforeConvert';
  csOpenAfterConvert = 'OpenAfterConvert';
  csBackgroundColor = 'BackgroundColor';

var
  CnPas2HtmlForm: TCnPas2HtmlForm = nil;

{$R *.DFM}

{ TCnPas2HtmlWizard }

procedure TCnPas2HtmlWizard.Config;
begin
  with TCnPas2HtmlConfigForm.Create(nil) do
  try
    CopySelectedShortCut := SubActions[FIdCopySelected].ShortCut;
    ExportUnitShortCut := SubActions[FIdExportUnit].ShortCut;
    ExportOpenedShortCut := SubActions[FIdExportOpened].ShortCut;
    ExportDPRShortCut := SubActions[FIdExportDPR].ShortCut;
    ExportBPGShortCut := SubActions[FIdExportBPG].ShortCut;
    ConfigShortCut := SubActions[FIdConfig].ShortCut;
    DispGauge := Self.FDispGauge;
    AutoSave := Self.FAutoSave;
    BackgroundColor := Self.FBackgroundColor;

    FontBasic := Self.FontBasic;
    FontAssembler := Self.FontAssembler;
    FontComment := Self.FontComment;
    FontDirective := Self.FontDirective;
    FontIdentifier := Self.FontIdentifier;
    FontKeyWord := Self.FontKeyWord;
    FontNumber := Self.FontNumber;
    FontSpace := Self.FontSpace;
    FontString := Self.FontString;
    FontSymbol := Self.FontSymbol;

    // ������ʾ��������
    if ShowModal = mrOK then
    begin
      SubActions[FIdCopySelected].ShortCut := CopySelectedShortCut;
      SubActions[FIdExportUnit].ShortCut := ExportUnitShortCut;
      SubActions[FIdExportOpened].ShortCut := ExportOpenedShortCut;
      SubActions[FIdExportDPR].ShortCut := ExportDPRShortCut;
      SubActions[FIdExportBPG].ShortCut := ExportBPGShortCut;
      SubActions[FIdConfig].ShortCut := ConfigShortCut;
      Self.FDispGauge := DispGauge;
      Self.FAutoSave := AutoSave;
      Self.FBackgroundColor := BackgroundColor;

      Self.FontBasic := FontBasic;
      Self.FontAssembler := FontAssembler;
      Self.FontComment := FontComment;
      Self.FontDirective := FontDirective;
      Self.FontIdentifier := FontIdentifier;
      Self.FontKeyWord := FontKeyWord;
      Self.FontNumber := FontNumber;
      Self.FontSpace := FontSpace;
      Self.FontString := FontString;
      Self.FontSymbol := FontSymbol;
      // ����ȷ����������

      DoSaveSettings;
    end;
  finally
    Free;
  end;
end;

procedure TCnPas2HtmlWizard.ConvertStream(SourceType: TCnConvertSourceType;
  const Title: string; InStream, OutStream: TStream;
  ProcessEvent: TCnSourceConvertProcessEvent);
var
  Conversion: TCnSourceConversion;
begin
  Conversion := nil;
  if Assigned(InStream) and Assigned(OutStream) then
  begin
    case FConvertType of
      ctHTML:
        begin
          Conversion := TCnSourceToHtmlConversion.Create;
          (Conversion as TCnSourceToHtmlConversion).HtmlEncode := FSourceHtmlEncode;
        end;
      ctRTF:  Conversion := TCnSourceToRTFConversion.Create;
    end;
    try
      if FDispGauge then
        Conversion.ProcessEvent := ProcessEvent;
      Conversion.InStream := InStream;
      Conversion.OutStream := OutStream;
      Conversion.Title := Title;
      Conversion.SourceType := SourceType;
      
      SetConversionFonts(Conversion);
      Conversion.Convert;
    finally
      Conversion.Free;
    end;
  end;
end;

constructor TCnPas2HtmlWizard.Create;
var
  I: Integer;
begin
  inherited;
  for I := Low(FFontArray) to High(FFontArray) do
    FFontArray[I] := TFont.Create;
end;

procedure TCnPas2HtmlWizard.AcquireSubActions;
begin
  FIdCopySelected := RegisterASubAction(SCnPas2HtmlWizardCopySelected,
    SCnPas2HtmlWizardCopySelectedCaption, 0, SCnPas2HtmlWizardCopySelectedHint);
  FIdExportUnit := RegisterASubAction(SCnPas2HtmlWizardExportUnit,
    SCnPas2HtmlWizardExportUnitCaption, 0, SCnPas2HtmlWizardExportUnitHint);
  FIdExportOpened := RegisterASubAction(SCnPas2HtmlWizardExportOpened,
    SCnPas2HtmlWizardExportOpenedCaption, 0, SCnPas2HtmlWizardExportOpenedHint);
  FIdExportDPR := RegisterASubAction(SCnPas2HtmlWizardExportDPR,
    SCnPas2HtmlWizardExportDPRCaption, 0, SCnPas2HtmlWizardExportDPRHint);
  FIdExportBPG := RegisterASubAction(SCnPas2HtmlWizardExportBPG,
    SCnPas2HtmlWizardExportBPGCaption, 0, SCnPas2HtmlWizardExportBPGHint);
  AddSepMenu;
  FIdConfig := RegisterASubAction(SCnPas2HtmlWizardConfig,
    SCnPas2HtmlWizardConfigCaption, 0, SCnPas2HtmlWizardConfigHint);
end;

destructor TCnPas2HtmlWizard.Destroy;
var
  I: Integer;
begin
  for I := Low(FFontArray) to High(FFontArray) do
  begin
    if Assigned(FFontArray[I]) then
      FFontArray[I].Free;
  end;
  inherited;
end;

procedure TCnPas2HtmlWizard.Execute;
begin

end;

function TCnPas2HtmlWizard.GetCaption: string;
begin
  Result := SCnPas2HtmlWizardMenuCaption;
end;

function TCnPas2HtmlWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnPas2HtmlWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnPas2HtmlWizard.GetHint: string;
begin
  Result := SCnPas2HtmlWizardMenuHint;
end;

function TCnPas2HtmlWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnPas2HtmlWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnPas2HtmlWizardName;
  Author := SCnPack_LiuXiao + ';' + SCnPack_PanYing;
  Email := SCnPack_LiuXiaoEmail + ';' + SCnPack_PanYingEmail;
  Comment := SCnPas2HtmlWizardComment;
end;

function TCnPas2HtmlWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '���ı�,rtf,htm,html';
end;

procedure TCnPas2HtmlWizard.SubActionExecute(Index: Integer);
var
  InMStream, OutMStream, tmpOutMStream: TMemoryStream;
  View: IOTAEditView;
  Block: IOTAEditBlock;
  SrcEditor: IOTASourceEditor;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  iModuleServices: IOTAModuleServices;
  sName, sGroupDir: string;
{$IFDEF UNICODE}
  S: string;
{$ELSE}
  S: AnsiString;
{$ENDIF}
  I: Integer;
  SourceType: TCnConvertSourceType;
begin
  if Index = FIdCopySelected then
  begin
    FConvertType := ctHTML;
    View := CnOtaGetTopMostEditView;
    if View <> nil then
    begin
      Block := View.Block;
      if (Block <> nil) and (Block.Size > 0) then
      begin
        if not CurrentIsDelphiSource and not IsDpk(CnOtaGetCurrentSourceFile) and not CurrentIsCSource then
        begin
          ErrorDlg(SCnPas2HtmlErrorNOTSupport);
          Exit;
        end;

        InMStream := TMemoryStream.Create;
        tmpOutMStream := TMemoryStream.Create;
        OutMStream := TMemoryStream.Create;
        try
          // Block.Text �� Ansi/Utf8/Utf16����Ҫת�� Ansi/Ansi/Utf16
          S := Block.Text;
{$IFDEF IDE_STRING_ANSI_UTF8} // ֻ�� 2005~2007 ��Ҫ�� Utf8 ת���� Ansi
          S := CnUtf8ToAnsi(Block.Text);
{$ENDIF}
          InMStream.Write(S[1], (Length(S) + 1)* SizeOf(Char));

          if CurrentIsDelphiSource or IsDpk(CnOtaGetCurrentSourceFile) then
            SourceType := stPas
          else
            SourceType := stCpp;

          ConvertStream(SourceType, '', InMStream, tmpOutMStream);
          // ��ʱ tmpOutStream ���Ѿ��� HTML �ַ����ˡ�
          ConvertHTMLToClipBoardHtml(tmpOutMStream, OutMStream);
          // ��ʱ OutStream ���Ѿ��� HTML �������ַ����ˡ�
          CopyHTMLToClipBoard(PAnsiChar(OutMStream.Memory), OutMStream.Size,
            PAnsiChar(InMStream.Memory), InMStream.Size);
        finally
          InMStream.Free;
          tmpOutMStream.Free;
          OutMStream.Free;
        end;
      end;
    end;
    Exit;
  end;

  if Index = FIdConfig then
  begin
    Config;
    Exit;
  end;

  // Select convert type
  with TCnPasConvertTypeForm.Create(nil) do
  begin
    chkOpenAfterConvert.Checked := FOpenAfterConvert;
    HTMLEncode := SCnPas2HtmlDefEncode;
    try
      if Open then
      begin
        FSourceHtmlEncode := HTMLEncode;
        FConvertType := ConvertType;
        FOpenAfterConvert := chkOpenAfterConvert.Checked;
      end
      else
        Exit;
    finally
      Free;
    end;
  end;

  if Index = FIdExportUnit then
  begin
    SrcEditor := CnOtaGetCurrentSourceEditor;
    if SrcEditor <> nil then
    begin
      // ����ǰ View ���������ݡ�
      InMStream := nil;
      OutMStream := nil;
      try
        InMStream := TMemoryStream.Create;
        OutMStream := TMemoryStream.Create;

        sName := CnOtaGetUnitName(SrcEditor);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Filename in Current. %s', [sName]);
{$ENDIF}
        if not IsDprOrPas(sName) and not IsCppSourceModule(sName) then
        begin
          ErrorDlg(SCnPas2HtmlErrorNOTSupport);
          Exit;
        end;

        if IsDprOrPas(sName) then
          SourceType := stPas
        else
          SourceType := stCpp;

        if Pos('.', sName) > 0 then
          sName := Copy(sName, 1, Pos('.', sName) - 1);

        if not Assigned(CnPas2HtmlForm) then
          CnPas2HtmlForm := TCnPas2HtmlForm.Create(nil);

        CnPas2HtmlForm.SaveDialog.DefaultExt := SConvertTypeFileExt[FConvertType];
        CnPas2HtmlForm.SaveDialog.Filter := SConvertTypeFileFilter[FConvertType];

        CnPas2HtmlForm.SaveDialog.FileName := sName;
        if CnPas2HtmlForm.SaveDialog.Execute then
        begin
{$IFDEF UNICODE}
          CnOtaSaveEditorToStreamW(SrcEditor, InMStream);
{$ELSE}
          CnOtaSaveEditorToStream(SrcEditor, InMStream);
{$ENDIF}
          ConvertStream(SourceType, SrcEditor.FileName, InMStream, OutMStream);
          OutMStream.SaveToFile(CnPas2HtmlForm.SaveDialog.FileName);
          if FOpenAfterConvert then
            ShellExecute(0, 'open', PChar(CnPas2HtmlForm.SaveDialog.FileName), nil,
              PChar(_CnExtractFileDir(CnPas2HtmlForm.SaveDialog.FileName)), SW_SHOWNORMAL);
        end;
      finally
        CnPas2HtmlForm.Close;
        FreeAndNil(CnPas2HtmlForm);
        InMStream.Free;
        OutMStream.Free;
      end;
    end;
  end
  else if Index = FIdExportOpened then
  begin
    QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
    if GetDirectory(SCnSelectDirCaption, FDir) then
    begin
      FDir := MakePath(FDir);
      Screen.Cursor := crHourGlass;
      try
        if FDispGauge then
        begin
          if not Assigned(CnPas2HtmlForm) then
          begin
            CnPas2HtmlForm := TCnPas2HtmlForm.Create(nil);
            CnPas2HtmlForm.Show;
            CnPas2HtmlForm.Update;
          end;
        end;
        for I := 0 to iModuleServices.GetModuleCount - 1 do
        begin
          sName := CnOtaGetFileNameOfModule(iModuleServices.GetModule(I));
          if (UpperCase(_CnExtractFileExt(sName)) = '.BPG')
{$IFDEF BDS}
           or (UpperCase(_CnExtractFileExt(sName)) = '.BDSPROJ')
           or (UpperCase(_CnExtractFileExt(sName)) = '.DPROJ')
           or (UpperCase(_CnExtractFileExt(sName)) = '.CBPROJ')
           or (UpperCase(_CnExtractFileExt(sName)) = '.BDSGROUP')
           or (UpperCase(_CnExtractFileExt(sName)) = '.GROUPPROJ')
           or (UpperCase(_CnExtractFileExt(sName)) = '.HTM')
{$ENDIF}
           then Continue;
          // ������ BPG/BDSPROJ/DPROJ/CBPROJ/BDSGROUP/GROUPPROJ�ļ���

{$IFDEF DEBUG}
          CnDebugger.LogFmt('Filename in AllOpened. %s', [sName]);
{$ENDIF}
          if not IsDprOrPas(sName) and not IsCppSourceModule(sName) then
          begin
            ErrorDlg(SCnPas2HtmlErrorNOTSupport);
            Continue;
          end;

          if not InternalProcessAFile(sName, FDir) then
            ErrorDlg(Format(SCnPas2HtmlErrorConvert, [sName]));

        end; // end of for
        if FOpenAfterConvert then
          ExploreDir(FDir);
      finally
        if Assigned(CnPas2HtmlForm) then
        begin
          CnPas2HtmlForm.Close;
          FreeAndNil(CnPas2HtmlForm);
        end;
        Screen.Cursor := crDefault;
      end; // end of try
    end;
  end
  else if Index = FIdExportDPR then
  begin
    Project := CnOtaGetCurrentProject;
    if Project = nil then Exit;
    
//    if not IsDelphiRuntime then
//    begin
//      ErrorDlg(SCnPas2HtmlErrorNOTSupport);
//      Exit;
//    end;

    if GetDirectory(SCnSelectDirCaption, FDir) then
    begin
      FDir := MakePath(FDir);
      try
        ProcessAProject(Project, FDir, FOpenAfterConvert);
      finally
        if Assigned(CnPas2HtmlForm) then
        begin
          CnPas2HtmlForm.Close;
          FreeAndNil(CnPas2HtmlForm);
        end;
      end;
      // ��ת���ڲ���Ŀ¼
    end;
  end
  else if Index = FIdExportBPG then
  begin
    ProjectGroup := CnOtaGetProjectGroup;
    if ProjectGroup = nil then Exit;

    if GetDirectory(SCnSelectDirCaption, FDir) then
    begin
      FDir := MakePath(FDir);
      sName := _CnChangeFileExt(_CnExtractFileName(ProjectGroup.FileName), '');

      case FConvertType of
        ctHTML: sGroupDir := FDir + sName + '_Html\';
        ctRTF:  sGroupDir := FDir + sName + '_RTF\';
      end;

      if not DirectoryExists(sGroupDir) then
        CreateDir(sGroupDir);

      for I := 0 to ProjectGroup.ProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[I];
        
//        if not IsDelphiProject(Project) then
//        begin
//          ErrorDlg(SCnPas2HtmlErrorNOTSupport);
//          Continue;
//        end;

        try
          ProcessAProject(Project, sGroupDir);
        finally
          if Assigned(CnPas2HtmlForm) then
          begin
            CnPas2HtmlForm.Close;
            FreeAndNil(CnPas2HtmlForm);
          end;
        end;
      end;
      if FOpenAfterConvert then
        ExploreDir(sGroupDir);
    end;
  end;
end;

procedure TCnPas2HtmlWizard.SubActionUpdate(Index: Integer);
var
  View: IOTAEditView;
  Block: IOTAEditBlock;
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
begin
  SubActions[Index].Visible := Active;
  if not Active or not Action.Enabled then
  begin
    SubActions[Index].Enabled := False;
    Exit;
  end;

  if Index = FIdCopySelected then
  begin
    if CurrentIsSource or IsDpk(CnOtaGetCurrentSourceFile) then
    begin
      View := CnOtaGetTopMostEditView;
      if View <> nil then
      begin
        Block := View.Block;
        SubActions[Index].Enabled := (Block <> nil) and (Block.Size > 0);
      end
      else
        SubActions[Index].Enabled := False;
    end
    else
      SubActions[Index].Enabled := False;
   // ��ǰ�����ļ��༭������ѡ�е�
  end
  else if Index = FIdExportUnit then
  begin
    SubActions[Index].Enabled := CurrentIsSource or IsDpk(CnOtaGetCurrentSourceFile); // ��ǰ�����ļ��༭
  end
  else if Index = FIdExportOpened then
  begin
    // ��ǰ�����ļ��༭
    SubActions[Index].Enabled := CurrentIsSource or IsDpk(CnOtaGetCurrentSourceFile);
  end
  else if Index = FIdExportDPR then
  begin
    // ��ǰ�й���
    Project := CnOtaGetCurrentProject;
    SubActions[Index].Enabled := Project <> nil;
  end
  else if Index = FIdExportBPG then
  begin
    // ��ǰ�й�����
    ProjectGroup := CnOtaGetProjectGroup;
    SubActions[Index].Enabled := ProjectGroup <> nil;
  end
  else if Index = FIdConfig then
    SubActions[Index].Enabled := True;
end;

procedure TCnPas2HtmlWizard.CopyHTMLToClipBoard(HtmlStrBuf: PAnsiChar; SizeH:
  Integer; StrBuf: PAnsiChar; SizeT: Integer);
var
  Fmt: UINT;
  DataH, DataT: THandle;
  DataHPtr, DataTPtr: Pointer;
begin
  Clipboard.Open;
  EmptyClipboard;
  try
    if (HtmlStrBuf <> nil) and (SizeH > 0) then   // �ȸ��� HTML ��ʽ
    begin
      Fmt := RegisterClipboardFormat('HTML Format');
      DataH := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeH + 1);
      try
        DataHPtr := GlobalLock(DataH);
        try
          Move(HtmlStrBuf^, DataHPtr^, SizeH + 1);
          SetClipboardData(Fmt, DataH);
          if not IsClipboardFormatAvailable(Fmt) then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogErrorFmt('HTML Format %d not Availiable after SetClipboardData.', [Fmt]);
{$ENDIF}          
          end;
        finally
          GlobalUnlock(DataH);
        end;
      except
        GlobalFree(DataH);
        raise;
      end;
    end;
    if (StrBuf <> nil) and (SizeT > 0) then   // �ٸ��� TXT ��ʽ
    begin
      DataT := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeT + 1);
      try
        DataTPtr := GlobalLock(DataT);
        try
          Move(StrBuf^, DataTPtr^, SizeT + 1);
          SetClipboardData(CF_TEXT, DataT);
        finally
          GlobalUnlock(DataT);
        end;
      except
        GlobalFree(DataT);
        raise;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

{ TFormPas2Html }

procedure TCnPas2HtmlForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
end;

procedure TCnPas2HtmlWizard.LoadSettings(Ini: TCustomIniFile);
var
  TempFont: TFont;
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    FDispGauge := ReadBool('', csDispGauge, True);
    FAutoSave := ReadBool('', csAutoSave, False);
    FOpenAfterConvert := ReadBool('', csOpenAfterConvert, False);
    FBackgroundColor := ReadColor('', csBackgroundColor, clWhite);

    // �������������������
    TempFont := TFont.Create;
    try
      TempFont.Name := 'Courier New';
      TempFont.Size := 10;

      FontBasic := ReadFont('', CnTCnPasConvertFontName[Ord(fkBasic)],
        TempFont);
      TempFont.Color := clRed;
      FontAssembler := ReadFont('', CnTCnPasConvertFontName[Ord(fkAssembler)],
        TempFont);

      TempFont.Color := clNavy;
      TempFont.Style := [fsItalic];
      FontComment := ReadFont('', CnTCnPasConvertFontName[Ord(fkComment)],
        TempFont);

      TempFont.Style := [];
      TempFont.Color := clGreen;
      FontDirective := ReadFont('', CnTCnPasConvertFontName[Ord(fkDirective)],
        TempFont);
        
      TempFont.Color := clBlack;
      FontIdentifier := ReadFont('',
        CnTCnPasConvertFontName[Ord(fkIdentifier)], TempFont);

      TempFont.Style := [fsBold];
      FontKeyWord := ReadFont('', CnTCnPasConvertFontName[Ord(fkKeyWord)],
        TempFont);

      TempFont.Style := [];
      FontNumber := ReadFont('', CnTCnPasConvertFontName[Ord(fkNumber)],
        TempFont);

      FontSpace := ReadFont('', CnTCnPasConvertFontName[Ord(fkSpace)],
        TempFont);

      TempFont.Color := clBlue;
      FontString := ReadFont('', CnTCnPasConvertFontName[Ord(fkString)],
        TempFont);

      TempFont.Color := clBlack;
      FontSymbol := ReadFont('', CnTCnPasConvertFontName[Ord(fkSymbol)],
        TempFont);
    finally
      TempFont.Free;
    end;
  finally
    Free;
  end;
end;

procedure TCnPas2HtmlWizard.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csDispGauge, FDispGauge);
    WriteBool('', csAutoSave, FAutoSave);
    WriteBool('', csOpenAfterConvert, FOpenAfterConvert);
    WriteColor('', csBackgroundColor, FBackgroundColor);

    for I := Low(FFontArray) to High(FFontArray) do
      WriteFont('', CnTCnPasConvertFontName[I], FFontArray[I]);

    // ����д������������
  finally
    Free;
  end;
end;

function TCnPas2HtmlWizard.InternalProcessAFile(const Filename, OutputDir: string): Boolean;
var
  InMStream, OutMStream: TMemoryStream;
  EReader: TCnEditFiler;
  FileExt: string;
  SourceType: TCnConvertSourceType;
begin
  Result := True;

  InMStream := nil;
  OutMStream := nil;
  EReader := nil;
  try
    InMStream := TMemoryStream.Create;
    OutMStream := TMemoryStream.Create;
    EReader := TCnEditFiler.Create(Filename);
    try
{$IFDEF UNICODE}
      EReader.SaveToStreamW(InMStream);
{$ELSE}
      EReader.SaveToStream(InMStream, True);
{$ENDIF}
    except
      Result := False;
      Exit;
    end;

    if IsDelphiSourceModule(Filename) then
      SourceType := stPas
    else if IsCppSourceModule(Filename) then
      SourceType := stCpp
    else
    begin
      Result := False;
      Exit;
    end;

    // Updated to user ConvertStram function support export mutil-type
    ConvertStream(SourceType, Filename, InMStream, OutMStream, ProcessGauge);

    case FConvertType of
      ctHTML: FileExt := '.htm';
      ctRTF:  FileExt := '.rtf';
    end;
    OutMStream.SaveToFile(OutputDir + _CnChangeFileExt(_CnExtractFileName(Filename), FileExt));
  finally
    InMStream.Free;
    OutMStream.Free;
    EReader.Free;
  end;
end;

procedure TCnPas2HtmlWizard.ProcessAProject(Project: IOTAProject;
  const sDir: string; OpenDir: Boolean);
var
  I: Integer;
  sOutPutDir, sFileName, sPFileName: string;
begin
  Screen.Cursor := crHourGlass;
  try
    if FDispGauge then
    begin
      if not Assigned(CnPas2HtmlForm) then
      begin
        CnPas2HtmlForm := TCnPas2HtmlForm.Create(nil);
        CnPas2HtmlForm.Show;
        CnPas2HtmlForm.Update;
      end;
    end;

    sPFileName := _CnChangeFileExt(_CnExtractFileName(Project.FileName), '');
    case FConvertType of
      ctHTML: sOutPutDir := sDir + sPFileName + '_Html\';
      ctRTF:  sOutPutDir := sDir + sPFileName + '_RTF\';
    end;

    // ����������Ŀ¼�����ھʹ�����
    if not DirectoryExists(sOutPutDir) then
      CreateDir(sOutPutDir);

    // ���¿�ʼ���� DPR ��ת�� html �ļ���
    sFileName := Project.FileName;
    if IsBdsProject(Project.FileName) or IsDProject(Project.FileName) then // ���� BDS Project ����
      sFileName := _CnChangeFileExt(Project.FileName, '.dpr');

    if Assigned(CnPas2HtmlForm) then
      CnPas2HtmlForm.ConvertingFileName := sFileName;

    if not IsCbProject(sFileName) and not InternalProcessAFile(sFileName, sOutPutDir) then
    begin
      sFileName := _CnChangeFileExt(sFileName, '.dpk');
      if not InternalProcessAFile(sFileName, sOutPutDir) then
        ErrorDlg(SCnPas2HtmlErrorConvertProject);
    end;

    // Ȼ��ѭ���������Դ�ļ���
    for I := 0 to Project.GetModuleCount - 1 do
    begin
      if Trim(Project.GetModule(I).FileName) = '' then Continue;
      sFileName := _CnExtractFileName(Project.GetModule(I).FileName);

      if not IsDelphiSourceModule(Project.GetModule(I).FileName)
        and not IsCppSourceModule(Project.GetModule(I).FileName) then
        Continue;                       // �������PAS/C/CPP���ļ���

      if Assigned(CnPas2HtmlForm) then
        CnPas2HtmlForm.ConvertingFileName := sFileName;

      if not InternalProcessAFile(Project.GetModule(I).FileName, sOutPutDir) then
      begin
        ErrorDlg(Format(SCnPas2HtmlErrorConvert, [Project.GetModule(I).FileName]));
        Continue;
      end;
    end;

    if OpenDir then
      ExploreDir(sOutPutDir);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCnPas2HtmlWizard.ProcessGauge(Process: Integer);
begin
  if Assigned(CnPas2HtmlForm) then
    CnPas2HtmlForm.ProgressBar.Position := Process;
  Application.ProcessMessages;
end;

procedure TCnPas2HtmlForm.SetConvertingFileName(const Value: string);
begin
  LabelDisp.Caption := Format(SCnDispCaption, [Value]);
  Update;
end;

function TCnPas2HtmlWizard.GetFonts(const Index: Integer): TFont;
begin
  Result := FFontArray[Index];
end;

procedure TCnPas2HtmlWizard.SetFonts(const Index: Integer;
  const Value: TFont);
begin
  if Value <> nil then
    FFontArray[Index].Assign(Value);
end;

procedure TCnPas2HtmlWizard.SetConversionFonts(Conversion: TCnSourceConversion);
var
  I: Integer;
begin
  with Conversion do
  begin
    BackgroundColor := Self.FBackgroundColor;
    for I := Low(FFontArray) to High(FFontArray) do
    begin
      case I of
        0: ;
        1: AssemblerFont := FFontArray[I];
        2: CommentFont := FFontArray[I];
        3: DirectiveFont := FFontArray[I];
        4: IdentifierFont := FFontArray[I];
        5: KeyWordFont := FFontArray[I];
        6: NumberFont := FFontArray[I];
        7: SpaceFont := FFontArray[I];
        8: StringFont := FFontArray[I];
        9: SymbolFont := FFontArray[I];
      end;
    end;
  end;
end;

procedure TCnPas2HtmlWizard.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
end;

initialization
  RegisterCnWizard(TCnPas2HtmlWizard);

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}
end.

