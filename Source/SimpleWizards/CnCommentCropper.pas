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

unit CnCommentCropper;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：删除注释专家与窗体单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
*           dejoy
* 备    注：删除注释专家与窗体单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2009.01.26 V1.2
*               增加目录搜索的功能，增加一合并空行的选项
*           2003.07.29 V1.1
*               增加保留自定义格式注释的功能
*           2003.06.12 V1.0
*               创建单元
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
  TCommentCropForm = class(TCnTranslateForm)
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
    function GetCropOption: TCropOption;
    procedure SetCropOption(const Value: TCropOption);
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
    property CropOption: TCropOption read GetCropOption write SetCropOption;
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
    FCropOption: TCropOption;
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

    procedure CropAUnit(const FileName: string);
    procedure CropStream(InStream, OutStream: TStream; IsDelphi: Boolean = True);
    procedure MergeBlankStream(Stream: TStream);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
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
    property CropOption: TCropOption read FCropOption write FCropOption;
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

procedure TCnCommentCropperWizard.CropAUnit(const FileName: string);
var
  EditFiler: TCnEditFiler;
  InStream, OutStream: TStream;
begin
  if not Self.CropProjectSrc then
    if IsDpr(FileName) or IsBpr(FileName) or IsBpg(FileName) then Exit;

  EditFiler := nil; InStream := nil; OutStream := nil;
  try
    EditFiler := TCnEditFiler.Create(FileName);
    InStream := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;

    try
      EditFiler.SaveToStream(InStream);
    except
      Application.HandleException(Self);
      Exit;
    end;

    Self.CropStream(InStream, OutStream, IsDelphiSourceModule(FileName));

    if Self.MergeBlank then
      MergeBlankStream(OutStream);

    EditFiler.ReadFromStream(OutStream);
    Inc(FCropCount);
  finally
    EditFiler.Free;
    InStream.Free;
    OutStream.Free;
  end;
end;

procedure TCnCommentCropperWizard.CropComments;
begin
  Self.CropCount := 0;
  Screen.Cursor := crHourGlass;
  try
    case Self.CropStyle of
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

  if Self.CropCount > 0 then
    InfoDlg(Format(SCnCommentCropperCountFmt, [Self.CropCount]));
end;

procedure TCnCommentCropperWizard.CropCurrentUnit;
begin
  if IsSourceModule(CnOtaGetCurrentSourceFile) then
    Self.CropAUnit(CnOtaGetCurrentSourceFile);
end;

procedure TCnCommentCropperWizard.CropOpenedUnits;
var
  i: Integer;
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  for i := 0 to iModuleServices.GetModuleCount - 1 do
    if IsSourceModule(CnOtaGetFileNameOfModule(iModuleServices.GetModule(i))) then
      CropAUnit(CnOtaGetFileNameOfModule(iModuleServices.GetModule(i)));
end;

procedure TCnCommentCropperWizard.CropAProject(Project: IOTAProject);
var
  i: Integer;
begin
  if Project <> nil then
  begin
    if IsSourceModule(Project.FileName) then
      CropAUnit(Project.FileName);
    for i := 0 to Project.GetModuleCount - 1 do
    begin
      if IsSourceModule(Project.GetModule(i).FileName) then
        CropAUnit(Project.GetModule(i).FileName);
    end;
  end;
end;

procedure TCnCommentCropperWizard.CropAProjectGroup(ProjectGroup: IOTAProjectGroup);
var
  i: Integer;
begin
  if ProjectGroup <> nil then
    for i := 0 to ProjectGroup.ProjectCount - 1 do
      CropAProject(ProjectGroup.Projects[i]);
end;

procedure TCnCommentCropperWizard.CropSelected;
var
  InStream, OutStream: TMemoryStream;
  View: IOTAEditView;
  Block: IOTAEditBlock;
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
        InStream.Write(Block.Text[1], Length(Block.Text));

        if IsDelphiSourceModule(CnOtaGetCurrentSourceFile) then
          Cropper := TCnPasCropper.Create(nil)
        else
          Cropper := TCnCPPCropper.Create(nil);

        Cropper.InStream := InStream;
        Cropper.OutStream := OutStream;
        Cropper.CropOption := Self.CropOption;
        Cropper.CropDirective := Self.CropDirective;
        Cropper.CropTodoList := Self.CropTodoList;
        Cropper.Reserve := Self.Reserve;
        Cropper.ReserveItems.Text := StringReplace(Self.FReserveStr, ',',
          #13#10, [rfReplaceAll]);

        Cropper.Parse;
        if Self.MergeBlank then
          MergeBlankStream(OutStream);

        CnOtaDeleteCurrentSelection;
        CnOtaInsertTextIntoEditor(StrPas(PChar(OutStream.Memory)));
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
  with TCommentCropForm.Create(nil) do
  begin
    CropOption := Self.CropOption;
    CropDirective := Self.CropDirective;
    CropTodoList := Self.CropTodoList;
    CropProjectSrc := Self.CropProjectSrc;
    Reserve := Self.Reserve;
    ReserveStr := Self.ReserveStr;
    Dir := Self.Dir;
    FileMask := Self.FileMask;
    if Self.FDirsHistory.Text <> '' then
      cbbDir.Items.Text := Self.FDirsHistory.Text;
    if Self.FFileMasksHistory.Text <> '' then
      cbbMask.Items.Text := Self.FFileMasksHistory.Text;

    try
      ShowModal;
      if ModalResult = mrOK then
      begin
        Self.CropOption := CropOption;
        Self.CropDirective := CropDirective;
        Self.CropTodoList := CropTodoList;
        Self.CropProjectSrc := CropProjectSrc;
        Self.CropStyle := CropStyle;
        Self.MergeBlank := MergeBlank;
        Self.Reserve := Reserve;
        Self.ReserveStr := ReserveStr;
        Self.Dir := Dir;
        Self.FileMask := FileMask;
        Self.FDirsHistory.Text := cbbDir.Items.Text;
        Self.FFileMasksHistory.Text := cbbMask.Items.Text;

        // 进行总处理。
        Self.CropComments;

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
    Self.CropTodoList := ReadBool('', csCropTodoList, False);
    Self.CropDirective := ReadBool('', csCropDirective, False);
    Self.CropProjectSrc := ReadBool('', csCropProjectSrc, False);
    Self.MergeBlank := ReadBool('', csMergeBlank, False);
    Self.IncludeSubDirs := ReadBool('', csIncludeSub, True);
    Self.Reserve := ReadBool('', csReserve, True);
    Self.ReserveStr := ReadString('', csReserveStr, csDefReserveStr);
    Self.CropOption := TCropOption(ReadInteger('', csCropOption, 0));
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
    WriteBool('', csCropTodoList, Self.CropTodoList);
    WriteBool('', csCropDirective, Self.CropDirective);
    WriteBool('', csCropProjectSrc, Self.CropProjectSrc);
    WriteBool('', csMergeBlank, Self.MergeBlank);
    WriteBool('', csReserve, Self.Reserve);
    WriteString('', csReserveStr, Self.ReserveStr);
    WriteInteger('', csCropOption, Ord(Self.CropOption));
    if FDirsHistory.Text <> '' then
      WriteStrings('', csDirsHistory, FDirsHistory);
    if FFileMasksHistory.Text <> '' then
      WriteStrings('', csFileMasksHistory, FFileMasksHistory);
  finally
    Free;
  end;
end;

{ TCommentCropForm }

function TCommentCropForm.GetCropDirective: Boolean;
begin
  Result := Self.chkCropDirective.Checked;
end;

function TCommentCropForm.GetCropOption: TCropOption;
begin
  if Self.rbExAscii.Checked then
    Result := coExAscii
  else Result := coAll;
end;

function TCommentCropForm.GetCropStyle: TCropStyle;
begin
  if Self.rbSelEdit.Checked then
    Result := csCropSelected
  else if Self.rbCurrUnit.Checked then
    Result := csCropCurrent
  else if Self.rbOpenedUnits.Checked then
    Result := csCropOpened
  else if Self.rbCurrProject.Checked then
    Result := csCropProject
  else if Self.rbDirectory.Checked then
    Result := csDirectory
  else
    Result := csCropProjectGroup;
end;

function TCommentCropForm.GetCropTodoList: Boolean;
begin
  Result := Self.chkCropTodo.Checked;
end;

procedure TCommentCropForm.SetCropDirective(const Value: Boolean);
begin
  Self.chkCropDirective.Checked := Value;
end;

procedure TCommentCropForm.SetCropOption(const Value: TCropOption);
begin
  case Value of
    coAll:     Self.rbCropComment.Checked := True;
    coExAscii: Self.rbExAscii.Checked := True;
  end;
end;

procedure TCommentCropForm.SetCropStyle(const Value: TCropStyle);
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

procedure TCommentCropForm.SetCropTodoList(const Value: Boolean);
begin
  Self.chkCropTodo.Checked := Value;
end;

procedure TCommentCropForm.FormCreate(Sender: TObject);
begin
  Self.rbSelEdit.Enabled := False;
  if CurrentIsSource then
    if CnOtaGetTopMostEditView <> nil then
      if CnOtaGetTopMostEditView.Block <> nil then
        if CnOtaGetTopMostEditView.Block.Size > 0 then
        begin
          Self.rbSelEdit.Enabled := True;
          Self.rbSelEdit.Checked := True;
        end;

  Self.chkCropDirective.Enabled := IsDelphiRuntime;
  Self.rbCurrUnit.Enabled := CnOtaGetTopMostEditView <> nil;
  Self.rbOpenedUnits.Enabled := Self.rbCurrUnit.Enabled;
  Self.rbCurrProject.Enabled := CnOtaGetCurrentProject <> nil;
  Self.rbProjectGroup.Enabled := CnOtaGetProjectGroup <> nil;
  Self.edReserveStr.Enabled := Self.chkReserve.Checked;
  Self.chkCropProjectSrc.Enabled := chkCropProjectSrc.Checked or rbProjectGroup.Checked;

  if (CnOtaGetCurrentProject = nil) and (CnOtaGetCurrentSourceFile = '') then
    rbDirectory.Checked := True;

  UpdateClick(nil);
end;

procedure TCnCommentCropperWizard.CropStream(InStream, OutStream: TStream;
  IsDelphi: Boolean );
var
  Cropper: TCnSourceCropper;
begin
  // 删除流中的注释。
  Assert((InStream <> nil) and (OutStream <> nil));

  if IsDelphi then
    Cropper := TCnPasCropper.Create(nil)
  else
    Cropper := TCnCPPCropper.Create(nil);

  Cropper.InStream := InStream;
  Cropper.OutStream := OutStream;

  Cropper.CropOption := Self.CropOption;
  Cropper.CropDirective := Self.CropDirective;
  Cropper.CropTodoList := Self.CropTodoList;
  Cropper.Reserve := Self.Reserve;
  Cropper.ReserveItems.Text := StringReplace(Self.FReserveStr, ',',
    #13#10, [rfReplaceAll]);
  try
    Cropper.Parse;
  finally
    Cropper.Free;
  end;
end;

procedure TCommentCropForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCommentCropForm.GetHelpTopic: string;
begin
  Result := 'CnCommentCropperWizard';
end;

function TCommentCropForm.GetReserve: Boolean;
begin
  Result := Self.chkReserve.Checked;
end;

procedure TCommentCropForm.SetReserve(const Value: Boolean);
begin
  Self.chkReserve.Checked := Value;
end;

function TCommentCropForm.GetReserveStr: string;
begin
  Result := Trim(edReserveStr.Text);
end;

procedure TCommentCropForm.SetReserveStr(const Value: string);
begin
  Self.edReserveStr.Text := Value;
end;

procedure TCommentCropForm.chkReserveClick(Sender: TObject);
begin
  Self.edReserveStr.Enabled := Self.chkReserve.Checked;
end;

function TCommentCropForm.GetCropProjectSrc: Boolean;
begin
  Result := Self.chkCropProjectSrc.Checked;
end;

procedure TCommentCropForm.SetCropProjectSrc(const Value: Boolean);
begin
  Self.chkCropProjectSrc.Checked := Value;
end;

procedure TCommentCropForm.UpdateClick(Sender: TObject);
var
  I: Integer;
begin
  chkCropProjectSrc.Enabled := chkCropProjectSrc.Checked or rbProjectGroup.Checked;
  grpDir.Enabled := rbDirectory.Checked;

  for I := 0 to grpDir.ControlCount - 1 do
    grpDir.Controls[I].Enabled := rbDirectory.Checked;
end;

procedure TCommentCropForm.btnSelectDirClick(Sender: TObject);
var
  NewDir: string;
begin
  NewDir := cbbDir.Text;
  if GetDirectory(SCnReplaceSelectDirCaption, NewDir) then
    cbbDir.Text := NewDir;
end;

function TCommentCropForm.GetMergeBlank: Boolean;
begin
  Result := chkMergeBlank.Checked;
end;

procedure TCommentCropForm.SetMergeBlank(const Value: Boolean);
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

function TCommentCropForm.GetIncludeSubDirs: Boolean;
begin
  Result := chkSubDirs.Checked;
end;

procedure TCommentCropForm.SetIncludeSubDirs(const Value: Boolean);
begin
  chkSubDirs.Checked := Value;
end;

function TCommentCropForm.GetDir: string;
begin
  Result := Trim(cbbDir.Text);
end;

function TCommentCropForm.GetFileMask: string;
begin
  Result := Trim(cbbMask.Text);
end;

procedure TCommentCropForm.SetDir(const Value: string);
begin
  cbbDir.Text := Trim(Value);
end;

procedure TCommentCropForm.SetFileMask(const Value: string);
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
  PreIsBlank, CurIsBlank: Boolean;

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

    // 最后的空行不删除了
    Stream.Size := 0;
    Strings.SaveToStream(Stream);
  finally
    FreeAndNil(Strings);
  end;
end;

procedure TCommentCropForm.FormClose(Sender: TObject;
  var Action: TCloseAction);

  procedure CheckAndInsertComboItems(cb: TComboBox; const Text: string);
  begin
    if Text = '' then Exit;
    
    if cb.Items.IndexOf(Text) < 0 then
    begin
      cb.Items.Insert(0, Text);
      if cb.Items.Count > 10 then   // 保留 10 项
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

procedure TCommentCropForm.FormCloseQuery(Sender: TObject;
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

initialization
  RegisterCnWizard(TCnCommentCropperWizard);

{$ENDIF CNWIZARDS_CNCOMMENTCROPPERWIZARD}
end.
