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

unit CnCommentCropper;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ɾ��ע��ר���봰�嵥Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
*           dejoy
* ��    ע��ɾ��ע��ר���봰�嵥Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.02.28 V1.4
*               ���� BDS �¿���©�� dpr �ļ�������
*           2014.12.29 V1.3
*               ����һЩ��ĩβ�����Լ��ַ�������������ʧ�������
*           2009.01.26 V1.2
*               ����Ŀ¼�����Ĺ��ܣ�����һ�ϲ����е�ѡ��
*           2003.07.29 V1.1
*               ���ӱ����Զ����ʽע�͵Ĺ���
*           2003.06.12 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCOMMENTCROPPERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolsApi, FileCtrl,
  CnConsts, CnWizClasses, CnWizConsts, CnWizUtils, CnCommon,
  CnWizIdeUtils, CnIni, IniFiles, CnWizEditFiler, CnSourceCropper, CnWizMultiLang;

type
  TCropStyle = (csCropSelected, csCropCurrent, csCropOpened, csCropProject,
    csCropProjectGroup, csDirectory);

type
  TCnCommentCropForm = class(TCnTranslateForm)
    gbKind: TGroupBox;
    rbSelEdit: TRadioButton;
    rbCurrUnit: TRadioButton;
    rbOpenedUnits: TRadioButton;
    rbCurrProject: TRadioButton;
    rbProjectGroup: TRadioButton;
    GroupBox1: TGroupBox;
    rbCropComment: TRadioButton;
    rbExAscii: TRadioButton;
    chkCropDirective: TCheckBox;
    chkCropTodo: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkReserve: TCheckBox;
    edReserveStr: TEdit;
    Label1: TLabel;
    chkCropProjectSrc: TCheckBox;
    rbDirectory: TRadioButton;
    grpDir: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    btnSelectDir: TButton;
    cbbDir: TComboBox;
    cbbMask: TComboBox;
    chkSubDirs: TCheckBox;
    chkMergeBlank: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure chkReserveClick(Sender: TObject);
    procedure UpdateClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    function GetCropStyle: TCropStyle;
    procedure SetCropStyle(const Value: TCropStyle);
    function GetCropOption: TCnCropOption;
    procedure SetCropOption(const Value: TCnCropOption);
    function GetCropDirective: Boolean;
    procedure SetCropDirective(const Value: Boolean);
    function GetCropTodoList: Boolean;
    procedure SetCropTodoList(const Value: Boolean);
    function GetReserve: Boolean;
    procedure SetReserve(const Value: Boolean);
    function GetReserveStr: string;
    procedure SetReserveStr(const Value: string);
    function GetCropProjectSrc: Boolean;
    procedure SetCropProjectSrc(const Value: Boolean);
    function GetMergeBlank: Boolean;
    procedure SetMergeBlank(const Value: Boolean);
    function GetIncludeSubDirs: Boolean;
    procedure SetIncludeSubDirs(const Value: Boolean);
    function GetDir: string;
    function GetFileMask: string;
    procedure SetDir(const Value: string);
    procedure SetFileMask(const Value: string);
  protected
    function GetHelpTopic: string; override;
  public
    property CropStyle: TCropStyle read GetCropStyle write SetCropStyle;
    property CropOption: TCnCropOption read GetCropOption write SetCropOption;
    property CropDirective: Boolean read GetCropDirective write SetCropDirective;
    property CropTodoList: Boolean read GetCropTodoList write SetCropTodoList;
    property CropProjectSrc: Boolean read GetCropProjectSrc write SetCropProjectSrc;
    property MergeBlank: Boolean read GetMergeBlank write SetMergeBlank;
    property Dir: string read GetDir write SetDir;
    property FileMask: string read GetFileMask write SetFileMask;
    property IncludeSubDirs: Boolean read GetIncludeSubDirs write SetIncludeSubDirs;
    property Reserve: Boolean read GetReserve write SetReserve;
    property ReserveStr: string read GetReserveStr write SetReserveStr;
  end;

{ TCnCommentCroperWizard }

  TCnCommentCropperWizard = class(TCnMenuWizard)
  private
    FCropTodoList: Boolean;
    FCropDirective: Boolean;
    FCropProjectSrc: Boolean;
    FCropOption: TCnCropOption;
    FCropStyle: TCropStyle;
    FCropCount: Integer;
    FReserve: Boolean;
    FReserveStr: string;
    FMergeBlank: Boolean;
    FIncludeSubDirs: Boolean;
    FInternalMasks: string;
    FFileMask: string;
    FDir: string;
    FDirsHistory: TStrings;
    FFileMasksHistory: TStrings;
  protected
    function GetHasConfig: Boolean; override;
    procedure OnFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);

    procedure CropAUnit(const FileName: string; IsCurrent: Boolean = False);
    procedure CropStream(InStream, OutStream: TStream; IsDelphi: Boolean = True);
    procedure MergeBlankStream(Stream: TStream);
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

    procedure CropComments;
    procedure CropSelected;
    procedure CropCurrentUnit;
    procedure CropOpenedUnits;
    procedure CropAProject(Project: IOTAProject);
    procedure CropAProjectGroup(ProjectGroup: IOTAProjectGroup);
    procedure CropInDirectories;

    property CropStyle: TCropStyle read FCropStyle write FCropStyle;
    property CropOption: TCnCropOption read FCropOption write FCropOption;
    property CropDirective: Boolean read FCropDirective write FCropDirective;
    property CropTodoList: Boolean read FCropTodoList write FCropTodoList;
    property CropProjectSrc: Boolean read FCropProjectSrc write FCropProjectSrc;
    property MergeBlank: Boolean read FMergeBlank write FMergeBlank;
    property Dir: string read FDir write FDir;
    property FileMask: string read FFileMask write FFileMask;
    property IncludeSubDirs: Boolean read FIncludeSubDirs write FIncludeSubDirs;
    property Reserve: Boolean read FReserve write FReserve;
    property ReserveStr: string read FReserveStr write FReserveStr;
    property CropCount: Integer read FCropCount write FCropCount;
  end;

{$ENDIF CNWIZARDS_CNCOMMENTCROPPERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCOMMENTCROPPERWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csCropOption = 'CropOption';
  csCropDirective = 'CropDirective';
  csCropTodoList = 'CropTodoList';
  csCropProjectSrc = 'CropProjectSrc';
  csMergeBlank = 'MergeBlank';
  csDir = 'Dir';
  csDirsHistory = 'DirsHistory';
  csMask = 'Mask';
  csFileMasksHistory = 'FileMasksHistory';
  csIncludeSub = 'IncludeSub';
  csReserve = 'Reserve';
  csReserveStr = 'ReserveStr';
  csDefReserveStr = '%,*,(*,*),#,%File';

{ TCnCommentCroperWizard }

procedure TCnCommentCropperWizard.Config;
begin
  inherited;

end;

constructor TCnCommentCropperWizard.Create;
begin
  inherited;
  FDirsHistory := TStringList.Create;
  FFileMasksHistory := TStringList.Create;
end;

procedure TCnCommentCropperWizard.CropAUnit(const FileName: string;
  IsCurrent: Boolean);
var
  EditFiler: TCnEditFiler;
  InStream, OutStream: TStream;
begin
  // ����ǰ�ļ��Ļ�����ʹ������ Project Source������ǰ�ļ��� Project Source��
  // �����ճ�����
  if not FCropProjectSrc and not IsCurrent then
    if IsDpr(FileName) or IsBpr(FileName) or IsBpg(FileName) then
      Exit;

  EditFiler := nil;
  InStream := nil;
  OutStream := nil;
  try
    EditFiler := TCnEditFiler.Create(FileName);
    InStream := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;

    try
      EditFiler.SaveToStream(InStream, True);
    except
      Application.HandleException(Self);
      Exit;
    end;

    CropStream(InStream, OutStream, IsDelphiSourceModule(FileName));

    if FMergeBlank then
      MergeBlankStream(OutStream);

    EditFiler.ReadFromStream(OutStream, True);
    Inc(FCropCount);
  finally
    EditFiler.Free;
    InStream.Free;
    OutStream.Free;
  end;
end;

procedure TCnCommentCropperWizard.CropComments;
begin
  FCropCount := 0;
  Screen.Cursor := crHourGlass;
  try
    case FCropStyle of
      csCropSelected:       CropSelected;
      csCropCurrent:        CropCurrentUnit;
      csCropOpened:         CropOpenedUnits;
      csCropProject:        CropAProject(CnOtaGetCurrentProject);
      csCropProjectGroup:   CropAProjectGroup(CnOtaGetProjectGroup);
      csDirectory:          CropInDirectories;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if FCropCount > 0 then
    InfoDlg(Format(SCnCommentCropperCountFmt, [FCropCount]));
end;

procedure TCnCommentCropperWizard.CropCurrentUnit;
begin
  if IsSourceModule(CnOtaGetCurrentSourceFile) then
    CropAUnit(CnOtaGetCurrentSourceFile, True);
end;

procedure TCnCommentCropperWizard.CropOpenedUnits;
var
  I: Integer;
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  for I := 0 to iModuleServices.GetModuleCount - 1 do
    if IsSourceModule(CnOtaGetFileNameOfModule(iModuleServices.GetModule(I))) then
      CropAUnit(CnOtaGetFileNameOfModule(iModuleServices.GetModule(I)));
end;

procedure TCnCommentCropperWizard.CropAProject(Project: IOTAProject);
var
  I: Integer;
begin
  if Project <> nil then
  begin
    // ���� BDS ����õ� dproj�������� dpr����Ҫ���⴦��
    if IsSourceModule(Project.FileName) then
      CropAUnit(Project.FileName);
{$IFDEF BDS}
    if not IsDpr(Project.FileName) then
      CropAUnit(_CnChangeFileExt(Project.FileName, '.dpr'));
{$ENDIF}

    for I := 0 to Project.GetModuleCount - 1 do
    begin
      if IsSourceModule(Project.GetModule(I).FileName) then
        CropAUnit(Project.GetModule(I).FileName);
      if IsC(Project.GetModule(I).FileName) or IsCpp(Project.GetModule(I).FileName) then
      begin
        if FileExists(_CnChangeFileExt(Project.GetModule(I).FileName, '.h')) or
          CnOtaIsFileOpen(_CnChangeFileExt(Project.GetModule(I).FileName, '.h')) then
          CropAUnit(_CnChangeFileExt(Project.GetModule(I).FileName, '.h'));
      end;
    end;
  end;
end;

procedure TCnCommentCropperWizard.CropAProjectGroup(ProjectGroup: IOTAProjectGroup);
var
  I: Integer;
begin
  if ProjectGroup <> nil then
  begin
    for I := 0 to ProjectGroup.ProjectCount - 1 do
      CropAProject(ProjectGroup.Projects[I]);
  end;
end;

procedure TCnCommentCropperWizard.CropSelected;
var
  InStream, OutStream: TMemoryStream;
  View: IOTAEditView;
  Block: IOTAEditBlock;
  Text: AnsiString;
  Cropper: TCnSourceCropper;
begin
  View := CnOtaGetTopMostEditView;
  Cropper := nil;
  if View <> nil then
  begin
    Block := View.Block;
    if (Block <> nil) and (Block.Size > 0) then
    begin
      InStream := TMemoryStream.Create;
      OutStream := TMemoryStream.Create;
      try
        Text := AnsiString(Block.Text);
        InStream.Write(Text[1], Length(Text));
{$IFDEF DEBUG}
//      CnDebugger.LogMemDump(InStream.Memory, InStream.Size);
{$ENDIF}

        if IsDelphiSourceModule(CnOtaGetCurrentSourceFile) then
          Cropper := TCnPasCropper.Create
        else
          Cropper := TCnCppCropper.Create;

        Cropper.InStream := InStream;
        Cropper.OutStream := OutStream;
        Cropper.CropOption := FCropOption;
        Cropper.CropDirective := FCropDirective;
        Cropper.CropTodoList := FCropTodoList;
        Cropper.Reserve := FReserve;
        Cropper.ReserveItems.Text := StringReplace(FReserveStr, ',',
          #13#10, [rfReplaceAll]);

        Cropper.Parse;
        if FMergeBlank then
          MergeBlankStream(OutStream);
{$IFDEF DEBUG}
//      CnDebugger.LogMemDump(OutStream.Memory, OutStream.Size);
{$ENDIF}

        CnOtaDeleteCurrentSelection;
        CnOtaInsertTextIntoEditor(string(PAnsiChar(OutStream.Memory)));
      finally
        InStream.Free;
        OutStream.Free;
        Cropper.Free;
      end;
    end;
  end;
end;

destructor TCnCommentCropperWizard.Destroy;
begin
  inherited;
  FDirsHistory.Free;
  FFileMasksHistory.Free;
end;

procedure TCnCommentCropperWizard.Execute;
begin
  with TCnCommentCropForm.Create(nil) do
  begin
    CropOption := FCropOption;
    CropDirective := FCropDirective;
    CropTodoList := FCropTodoList;
    CropProjectSrc := FCropProjectSrc;
    Reserve := FReserve;
    ReserveStr := FReserveStr;
    Dir := FDir;
    FileMask := FFileMask;
    if FDirsHistory.Text <> '' then
      cbbDir.Items.Text := FDirsHistory.Text;
    if FFileMasksHistory.Text <> '' then
      cbbMask.Items.Text := FFileMasksHistory.Text;

    try
      ShowModal;
      if ModalResult = mrOK then
      begin
        FCropOption := CropOption;
        FCropDirective := CropDirective;
        FCropTodoList := CropTodoList;
        FCropProjectSrc := CropProjectSrc;
        FCropStyle := CropStyle;
        FMergeBlank := MergeBlank;
        FReserve := Reserve;
        FReserveStr := ReserveStr;
        FDir := Dir;
        FFileMask := FileMask;
        FDirsHistory.Text := cbbDir.Items.Text;
        FFileMasksHistory.Text := cbbMask.Items.Text;

        // �����ܴ���
        CropComments;

        DoSaveSettings;
      end;
    finally
      Free;
    end;
  end;
end;

function TCnCommentCropperWizard.GetCaption: string;
begin
  Result := SCnCommentCropperWizardMenuCaption;
end;

function TCnCommentCropperWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnCommentCropperWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnCommentCropperWizard.GetHint: string;
begin
  Result := SCnCommentCropperWizardMenuHint;
end;

function TCnCommentCropperWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnCommentCropperWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnCommentCropperWizardName;
  Author := SCnPack_LiuXiao + ';' + SCnPack_dejoy;
  Email := SCnPack_LiuXiaoEmail + ';' + SCnPack_dejoyEmail;
  Comment := SCnCommentCropperWizardComment;
end;

procedure TCnCommentCropperWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  begin
    CropTodoList := ReadBool('', csCropTodoList, False);
    CropDirective := ReadBool('', csCropDirective, False);
    CropProjectSrc := ReadBool('', csCropProjectSrc, False);
    MergeBlank := ReadBool('', csMergeBlank, False);
    IncludeSubDirs := ReadBool('', csIncludeSub, True);
    Reserve := ReadBool('', csReserve, True);
    ReserveStr := ReadString('', csReserveStr, csDefReserveStr);
    CropOption := TCnCropOption(ReadInteger('', csCropOption, 0));
    ReadStrings('', csDirsHistory, FDirsHistory);
    ReadStrings('', csFileMasksHistory, FFileMasksHistory);
    Free;
  end;
end;

procedure TCnCommentCropperWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csCropTodoList, FCropTodoList);
    WriteBool('', csCropDirective, FCropDirective);
    WriteBool('', csCropProjectSrc, FCropProjectSrc);
    WriteBool('', csMergeBlank, FMergeBlank);
    WriteBool('', csReserve, FReserve);
    WriteString('', csReserveStr, FReserveStr);
    WriteInteger('', csCropOption, Ord(FCropOption));
    if FDirsHistory.Text <> '' then
      WriteStrings('', csDirsHistory, FDirsHistory);
    if FFileMasksHistory.Text <> '' then
      WriteStrings('', csFileMasksHistory, FFileMasksHistory);
  finally
    Free;
  end;
end;

{ TCommentCropForm }

function TCnCommentCropForm.GetCropDirective: Boolean;
begin
  Result := chkCropDirective.Checked;
end;

function TCnCommentCropForm.GetCropOption: TCnCropOption;
begin
  if rbExAscii.Checked then
    Result := coExAscii
  else Result := coAll;
end;

function TCnCommentCropForm.GetCropStyle: TCropStyle;
begin
  if rbSelEdit.Checked then
    Result := csCropSelected
  else if rbCurrUnit.Checked then
    Result := csCropCurrent
  else if rbOpenedUnits.Checked then
    Result := csCropOpened
  else if rbCurrProject.Checked then
    Result := csCropProject
  else if rbDirectory.Checked then
    Result := csDirectory
  else
    Result := csCropProjectGroup;
end;

function TCnCommentCropForm.GetCropTodoList: Boolean;
begin
  Result := chkCropTodo.Checked;
end;

procedure TCnCommentCropForm.SetCropDirective(const Value: Boolean);
begin
  chkCropDirective.Checked := Value;
end;

procedure TCnCommentCropForm.SetCropOption(const Value: TCnCropOption);
begin
  case Value of
    coAll:     rbCropComment.Checked := True;
    coExAscii: rbExAscii.Checked := True;
  end;
end;

procedure TCnCommentCropForm.SetCropStyle(const Value: TCropStyle);
begin
  case Value of
    csCropSelected:       rbSelEdit.Checked := True;
    csCropCurrent:        rbCurrUnit.Checked := True;
    csCropOpened:         rbOpenedUnits.Checked := True;
    csCropProject:        rbCurrProject.Checked := True;
    csCropProjectGroup:   rbProjectGroup.Checked := True;
    csDirectory:          rbDirectory.Checked := True;
  end;
end;

procedure TCnCommentCropForm.SetCropTodoList(const Value: Boolean);
begin
  chkCropTodo.Checked := Value;
end;

procedure TCnCommentCropForm.FormCreate(Sender: TObject);
begin
  rbSelEdit.Enabled := False;
  if CurrentIsSource then
    if CnOtaGetTopMostEditView <> nil then
      if CnOtaGetTopMostEditView.Block <> nil then
        if CnOtaGetTopMostEditView.Block.Size > 0 then
        begin
          rbSelEdit.Enabled := True;
          rbSelEdit.Checked := True;
        end;

  chkCropDirective.Enabled := IsDelphiRuntime;
  rbCurrUnit.Enabled := CnOtaGetTopMostEditView <> nil;
  rbOpenedUnits.Enabled := rbCurrUnit.Enabled;
  rbCurrProject.Enabled := CnOtaGetCurrentProject <> nil;
  rbProjectGroup.Enabled := CnOtaGetProjectGroup <> nil;
  edReserveStr.Enabled := chkReserve.Checked;
  chkCropProjectSrc.Enabled := rbCurrProject.Checked or rbProjectGroup.Checked;

  if (CnOtaGetCurrentProject = nil) and (CnOtaGetCurrentSourceFile = '') then
    rbDirectory.Checked := True;

  UpdateClick(nil);
end;

procedure TCnCommentCropperWizard.CropStream(InStream, OutStream: TStream;
  IsDelphi: Boolean );
var
  Cropper: TCnSourceCropper;
begin
  // ɾ�����е�ע�͡�
  Assert((InStream <> nil) and (OutStream <> nil));

  if IsDelphi then
    Cropper := TCnPasCropper.Create
  else
    Cropper := TCnCppCropper.Create;

  Cropper.InStream := InStream;
  Cropper.OutStream := OutStream;

  Cropper.CropOption := FCropOption;
  Cropper.CropDirective := FCropDirective;
  Cropper.CropTodoList := FCropTodoList;
  Cropper.Reserve := FReserve;
  Cropper.ReserveItems.Text := StringReplace(FReserveStr, ',',
    #13#10, [rfReplaceAll]);
  try
    Cropper.Parse;
  finally
    Cropper.Free;
  end;
end;

procedure TCnCommentCropForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnCommentCropForm.GetHelpTopic: string;
begin
  Result := 'CnCommentCropperWizard';
end;

function TCnCommentCropForm.GetReserve: Boolean;
begin
  Result := chkReserve.Checked;
end;

procedure TCnCommentCropForm.SetReserve(const Value: Boolean);
begin
  chkReserve.Checked := Value;
end;

function TCnCommentCropForm.GetReserveStr: string;
begin
  Result := Trim(edReserveStr.Text);
end;

procedure TCnCommentCropForm.SetReserveStr(const Value: string);
begin
  edReserveStr.Text := Value;
end;

procedure TCnCommentCropForm.chkReserveClick(Sender: TObject);
begin
  edReserveStr.Enabled := chkReserve.Checked;
end;

function TCnCommentCropForm.GetCropProjectSrc: Boolean;
begin
  Result := chkCropProjectSrc.Checked;
end;

procedure TCnCommentCropForm.SetCropProjectSrc(const Value: Boolean);
begin
  chkCropProjectSrc.Checked := Value;
end;

procedure TCnCommentCropForm.UpdateClick(Sender: TObject);
var
  I: Integer;
begin
  chkCropProjectSrc.Enabled := rbCurrProject.Checked or rbProjectGroup.Checked;
  grpDir.Enabled := rbDirectory.Checked;

  for I := 0 to grpDir.ControlCount - 1 do
    grpDir.Controls[I].Enabled := rbDirectory.Checked;
end;

procedure TCnCommentCropForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := cbbDir.Text;
  if GetDirectory(SCnReplaceSelectDirCaption, NewDir) then
    cbbDir.Text := NewDir;
end;

function TCnCommentCropForm.GetMergeBlank: Boolean;
begin
  Result := chkMergeBlank.Checked;
end;

procedure TCnCommentCropForm.SetMergeBlank(const Value: Boolean);
begin
  chkMergeBlank.Checked := Value;
end;

procedure TCnCommentCropperWizard.CropInDirectories;
begin
  if FileMask = '' then
    FInternalMasks := SCnDefSourceMask
  else
    FInternalMasks := FileMask;
  FindFile(Dir, '*.*', OnFindFile, nil, IncludeSubDirs);
end;

function TCnCommentCropForm.GetIncludeSubDirs: Boolean;
begin
  Result := chkSubDirs.Checked;
end;

procedure TCnCommentCropForm.SetIncludeSubDirs(const Value: Boolean);
begin
  chkSubDirs.Checked := Value;
end;

function TCnCommentCropForm.GetDir: string;
begin
  Result := Trim(cbbDir.Text);
end;

function TCnCommentCropForm.GetFileMask: string;
begin
  Result := Trim(cbbMask.Text);
end;

procedure TCnCommentCropForm.SetDir(const Value: string);
begin
  cbbDir.Text := Trim(Value);
end;

procedure TCnCommentCropForm.SetFileMask(const Value: string);
begin
  cbbMask.Text := Trim(Value);
end;

procedure TCnCommentCropperWizard.OnFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if FileMatchesExts(FileName, FInternalMasks) then
    CropAUnit(FileName);
end;

procedure TCnCommentCropperWizard.MergeBlankStream(Stream: TStream);
var
  Strings: TStringList;
  I: Integer;
  PreIsBlank, CurIsBlank, LastIsBlank: Boolean;
  EofChar: AnsiChar;
  LastLineBuf: array[0..1] of AnsiChar;

  function IsBlankLine(const ALine: string): Boolean;
  var
    S: string;
    I: Integer;
  begin
    Result := True;
    S := Trim(ALine);
    if S = '' then
      Exit
    else
    begin
      for I := 1 to Length(S) do
      begin
        if not CharInSet(S[I], [' ', #9, #13, #10]) then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;

begin
  Strings := TStringList.Create;
  try
    // ���� Stream �е�����ĩβ���޿��У���� TStringList ���ٱ��ȥ�����С�
    // ������Ҫ���²����滹ԭ
    Stream.Position := Stream.Size - 2;
    Stream.Read(LastLineBuf, 2);
    LastIsBlank := (LastLineBuf[0] = #10) or (LastLineBuf[1] = #10);
    // ֻҪ��һ���� #10 ����ĩβ����
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(LastIsBlank, 'Before MergeBlank. Last Line is Blank?');
{$ENDIF}

    Stream.Position := 0;
    Strings.LoadFromStream(Stream);

    I := Strings.Count - 1;
    PreIsBlank := False;

    while I >= 0 do
    begin
      if not IsBlankLine(Strings[I]) then
        CurIsBlank := False
      else
      begin
        if PreIsBlank then
          Strings.Delete(I);
        CurIsBlank := True;
      end;
      Dec(I);
      PreIsBlank := CurIsBlank;
    end;

    Stream.Size := 0;
    Strings.SaveToStream(Stream);

{$IFDEF DEBUG}
    CnDebugger.LogBoolean(IsBlankLine(Strings[Strings.Count - 1]), 'After MergeBlank. Last Line is Blank?');
{$ENDIF}

    if not LastIsBlank then
    begin
      // TStrings ����ĩβд����س����У���֮ǰ�ޣ���������Ҫȥ��
      Stream.Position := Stream.Position - 2; // �����ƶ����س�����
    end;

    // д�������
    EofChar := #0;
    Stream.Write(EofChar, SizeOf(EofChar));
  finally
    FreeAndNil(Strings);
  end;
end;

procedure TCnCommentCropForm.FormClose(Sender: TObject;
  var Action: TCloseAction);

  procedure CheckAndInsertComboItems(cb: TComboBox; const Text: string);
  begin
    if Text = '' then Exit;
    
    if cb.Items.IndexOf(Text) < 0 then
    begin
      cb.Items.Insert(0, Text);
      if cb.Items.Count > 10 then   // ���� 10 ��
        cb.Items.Delete(10);
    end;
  end;
begin
  if ModalResult = mrOK then
  begin
    CheckAndInsertComboItems(cbbDir, cbbDir.Text);
    CheckAndInsertComboItems(cbbMask, cbbMask.Text);
  end;
end;

procedure TCnCommentCropForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult <> mrOK) or not rbDirectory.Checked then
  begin
    CanClose := True;
    Exit;
  end;

  if Trim(cbbDir.Text) = '' then
  begin
    ErrorDlg(SCnReplaceDirEmpty);
    CanClose := False;
    Exit;
  end;
  if not DirectoryExists(Dir) then
  begin
    ErrorDlg(SCnReplaceDirNotExists);
    CanClose := False;
    Exit;
  end;
  CanClose := True;
end;

function TCnCommentCropperWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '����,delete,blankline,';
end;

initialization
  RegisterCnWizard(TCnCommentCropperWizard);

{$ENDIF CNWIZARDS_CNCOMMENTCROPPERWIZARD}
end.
