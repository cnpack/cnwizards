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

unit CnStatWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Դ����ͳ��ר��
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��Դ��ͳ��ר��ʵ��ģ��
* ����ƽ̨��Windows 98 + Delphi 6
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2003.03.31 V1.2
*               ��Ŀ¼�������ļ���ʱ������˽�����ʾ
*               ���ڵ������Ч����
*           2003.03.30 V1.1
*               �޸��ظ�ͳ�ƴ���͹����ļ���Ӵ���
*           2003.03.27 V1.0
*               ������Ԫ��ʵ�ֹ��ܣ�����CSV���֧��
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSTATWIZARD}

{$IFDEF DELPHIXE_UP}
  // XE �� FormReadError ���˸��ַ�������
  {$DEFINE FORM_READ_ERROR_V2}
{$ENDIF}

uses
  SysUtils, Classes, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} FileCtrl,
  Controls, ComCtrls, Windows, {$IFDEF LAZARUS} SrcEditorIntf, {$ENDIF}
  CnConsts, CnCommon, CnWizClasses, CnWizConsts,
  CnWizUtils, CnWizEditFiler, Forms, Dialogs, CnLineParser, CnWizCompilerConst;
 
type
  TCnStatStyle = (ssUnit, ssProjectGroup, ssProject, ssOpenUnits, ssDir);

  PCnSourceStatRec = ^TCnSourceStatRec;
  TCnSourceStatRec = record
    FileName, FileDir: string;
    Bytes, CommentBytes, CodeBytes, CommentBlocks: Integer;
    AllLines, EffectiveLines, CodeLines: Integer;
    BlankLines, CommentLines: Integer;
    InterfaceLines, ImplementationLines: Integer;
    ProjectStatRec: PCnSourceStatRec;
    ProjectGroupStatRec: PCnSourceStatRec;
    IsValidSource: Boolean;
  end;

  TCnStatWizard = class(TCnMenuWizard)
  private
    FFileNames: TStringList;
    FIni: TCustomIniFile;
    FMasks: string;
    procedure SetFileNames(const Value: TStringList);
    procedure OnFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected
    procedure SetActive(Value: Boolean); override;
    procedure ProcessAFile(const FileName: string; const Level: Integer;
      IsDirMode: Boolean = False; const Dir: string = '');
    procedure StatAStream(inStream: TStream; PStatRec: PCnSourceStatRec;
      IsCppSource: Boolean); virtual;
    function GetDefFileMask: string; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    procedure StatUnit;
    procedure StatProject;
{$IFDEF DELPHI_OTA}
    procedure StatProjectGroup;
{$ENDIF}
    procedure StatOpenUnits;
    procedure StatDir;

    property FileNames: TStringList read FFileNames write SetFileNames;
  end;

{$ENDIF CNWIZARDS_CNSTATWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSTATWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnStatFrm, CnStatResultFrm, CnWizMethodHook;

{ TCnStatWizard }

const
{$IFDEF UNICODE}
  {$IFDEF FORM_READ_ERROR_V2}
  SCnFormReadErrorName = '@Formread@FormReadError$qqrx20System@UnicodeStringt1';
  {$ELSE}
  SCnFormReadErrorName = '@Formread@FormReadError$qqrx20System@UnicodeString';
  {$ENDIF}
{$ELSE}
  SCnFormReadErrorName = '@Formread@FormReadError$qqrx17System@AnsiString';
{$ENDIF}

function HookedFormReadError(const Str: string
  {$IFDEF FORM_READ_ERROR_V2}; const Str2: string {$ENDIF}): Integer;
begin
  Result := $2A; // ��ʾ IgnoreAll;
end;

constructor TCnStatWizard.Create;
begin
  inherited;
  FIni := CreateIniFile;
  FFileNames := TStringList.Create;
end;

destructor TCnStatWizard.Destroy;
begin
 {$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnStatWizard.Destroy');
 {$ENDIF}
  if Assigned(CnStatResultForm) then
  begin
    CnStatResultForm.Free;
    CnStatResultForm := nil;
  end;
  if CnStatForm <> nil then
  begin
    CnStatForm.Free;
    CnStatForm := nil;
  end;
  FFileNames.Free;
  FIni.Free;
 {$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnStatWizard.Destroy');
 {$ENDIF}
  inherited;
end;

procedure TCnStatWizard.Execute;
var
  OldFormReadError: Pointer;
  ACorIdeModule: HMODULE;
  MethodHook: TCnMethodHook;
begin
  if CnStatForm = nil then
    CnStatForm := TCnStatForm.CreateEx(nil, FIni);

  if CnStatForm.Visible then CnStatForm.Hide;
  if CnStatForm.ShowModal = mrOk then // ���ͳ�ƣ����� StatResultFrm �����ͷ�
  begin
    if CnStatResultForm = nil then
    begin
      CnStatResultForm := TCnStatResultForm.Create(nil);
      CnStatResultForm.Icon := Self.Icon;
    end;
    CnStatResultForm.StaticEnd := False;

    if CnStatResultForm.WindowState = wsMinimized then
      CnStatResultForm.WindowState := wsNormal;
    if not CnStatResultForm.Visible then
      CnStatResultForm.Show;
    CnStatResultForm.BringtoFront;
    CnStatResultForm.Update;

    MethodHook := nil;

{$IFDEF DELPHI_OTA}
{$IFDEF BDS}
  {$IFDEF DELPHIXE2_UP} // �������������ں���
    ACorIdeModule := LoadLibrary(DesignIdeLibName);
  {$ELSE}
    ACorIdeModule := LoadLibrary(DphIdeLibName);
  {$ENDIF}
{$ELSE}
    ACorIdeModule := LoadLibrary(CorIdeLibName);
{$ENDIF}
{$ENDIF}

    try
      CnStatResultForm.StatStyle := CnStatForm.StatStyle;

{$IFDEF DELPHI_OTA}
      // �ҽ� Formread::FormReadError������ $2A ��ʾǿ�� IgnoreAll
      if ACorIdeModule <> 0 then
      begin
        OldFormReadError := GetBplMethodAddress(GetProcAddress(ACorIdeModule, SCnFormReadErrorName));
        if OldFormReadError <> nil then
          MethodHook := TCnMethodHook.Create(OldFormReadError, @HookedFormReadError)
        else
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsgWarning('StatWizard: No FormReadError Found.');
{$ENDIF}
        end;
      end;
{$ENDIF}

      case CnStatForm.StatStyle of
        ssUnit:            Self.StatUnit;
{$IFDEF DELPHI_OTA}
        ssProjectGroup:    Self.StatProjectGroup;
{$ENDIF}
        ssProject:         Self.StatProject;
        ssOpenUnits:       Self.StatOpenUnits;
        ssDir:             Self.StatDir;
      end;
    finally
      CnStatResultForm.StaticEnd := True;
{$IFDEF DELPHI_OTA}
      // �ָ��ҽ�
      MethodHook.Free;
      if ACorIdeModule <> 0 then
        FreeLibrary(ACorIdeModule);
{$ENDIF}
    end;
  end
  else  // ȡ�������������ͷ�
  begin
    CnStatForm.Free;
    CnStatForm := nil;
  end;
end;

function TCnStatWizard.GetCaption: string;
begin
  Result := SCnStatWizardMenuCaption;
end;

function TCnStatWizard.GetDefFileMask: string;
begin
  Result := SCnDefSourceMask;
end;

function TCnStatWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnStatWizard.GetHint: string;
begin
  Result := SCnStatWizardMenuHint;
end;

function TCnStatWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnStatWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnStatWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnStatWizardComment;
end;

procedure TCnStatWizard.OnFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if FileMatchesExts(FileName, FMasks) then
  begin
    Self.FileNames.Add(FileName);
    CnStatResultForm.UpdateFileSearchCount(Self.FileNames.Count);
  end;
end;

procedure TCnStatWizard.SetFileNames(const Value: TStringList);
begin
  if Value <> nil then
    FFileNames.Assign(Value);
end;

procedure TCnStatWizard.ProcessAFile(const FileName: string;
  const Level: Integer; IsDirMode: Boolean; const Dir: string);
var
  PRec: PCnSourceStatRec;
  AParentNode, AddedNode: TTreeNode;
  Reader: TCnEditFiler;
  InStream: TMemoryStream;
  DispCaption: string;
  DirLength: Integer;
begin
  if CnStatResultForm = nil then
    CnStatResultForm := TCnStatResultForm.Create(nil);
  if CnStatResultForm.WindowState = wsMinimized then
    CnStatResultForm.WindowState := wsNormal;

  if not CnStatResultForm.Visible then
  begin
    CnStatResultForm.Show;
    CnStatResultForm.BringtoFront;
  end;

  if Trim(FileName) = '' then
    Exit;

  // �����������ļ���D5 ���޷������� BCB �����ļ���ֻ����һ����¼��
  if (CnStatResultForm.StatStyle = ssProjectGroup) and (Level = 0) or
    IsBpr(FileName) then
  begin
    New(PRec);
    FillChar(PRec^, SizeOf(TCnSourceStatRec), 0);
    PRec^.FileName := _CnExtractFileName(FileName);
    PRec^.FileDir := _CnExtractFileDir(FileName);
    PRec^.IsValidSource := False;
  end
  else if IsCppSourceModule(FileName) or IsDelphiSourceModule(FileName) or
    IsInc(FileName) or IsPackage(FileName) then // ������Ч��Դ�����ļ�
  begin
    InStream := nil; Reader := nil;
    try
      InStream := TMemoryStream.Create;
      try
        Reader := TCnEditFiler.Create(FileName);
        Reader.SaveToStream(inStream, True);
      except
        ErrorDlg(SCnErrorNoFile + ' ' + FileName);
        Exit;
      end;

      New(PRec);
      FillChar(PRec^, SizeOf(TCnSourceStatRec), 0);

      PRec^.FileName := _CnExtractFileName(FileName);
      PRec^.FileDir := _CnExtractFileDir(FileName);
      PRec^.IsValidSource := True;

      StatAStream(inStream, PRec, not (IsDelphiSourceModule(FileName) or IsDpk(FileName)));
    finally
      InStream.Free;
      Reader.Free;
    end;
  end
  else
    Exit;

  if IsDirMode then
  begin
    DirLength := Length(Dir);
    DispCaption := Copy(FileName, DirLength, Length(FileName) - DirLength + 1);
  end
  else
    DispCaption := _CnExtractFileName(FileName);

  if ((CnStatResultForm.StatStyle <> ssProjectGroup) and (CnStatResultForm.StatStyle <> ssProject))
    or ((PRec^.Bytes > 0) and (not IsBpr(FileName) and not IsDpr(FileName))) then
    DispCaption := DispCaption + ' (' + InttoStrSp(PRec^.EffectiveLines) + ')';

  AddedNode := nil;
  if CnStatResultForm.TreeView.Items.Count > 0 then
  begin
    AParentNode := CnStatResultForm.GetLastNodeFromLevel(CnStatResultForm.TreeView, Level - 1);
    if AParentNode <> nil then
      AddedNode := CnStatResultForm.TreeView.Items.AddChildObject(AParentNode, DispCaption, PRec)
    else
    begin
      AParentNode := CnStatResultForm.GetLastNodeFromLevel(CnStatResultForm.TreeView, Level);
      if AParentNode <> nil then
        AddedNode := CnStatResultForm.TreeView.Items.AddObject(AParentNode, DispCaption, PRec);
    end;
  end
  else
  begin
    AddedNode := CnStatResultForm.TreeView.Items.AddObject(nil, DispCaption, PRec);
  end;

  if AddedNode <> nil then
  begin
    case CnStatResultForm.StatStyle of
    ssUnit:
      AddedNode.ImageIndex := 2;
    ssProjectGroup:
      AddedNode.ImageIndex := AddedNode.Level;
    ssProject:
      AddedNode.ImageIndex := AddedNode.Level + 1;
    ssOpenUnits:
      AddedNode.ImageIndex := 2;
    ssDir:
      AddedNode.ImageIndex := 2;
    end;
    AddedNode.SelectedIndex := AddedNode.ImageIndex;
    CnStatResultForm.DoAFileStat(@(CnStatResultForm.StatusBarRec), PRec);
    // CnStatResultForm.TreeView.Checked[AddedNode] := True;
  end;

  CnStatResultForm.UpdateStatusBar;
end;

procedure TCnStatWizard.StatAStream(inStream: TStream;
  PStatRec: PCnSourceStatRec; IsCppSource: Boolean);
var
  Parser: TCnLineParser;
begin
  PStatRec^.Bytes := inStream.Size;
  Parser := nil;
  try
    if IsCppSource then
      Parser := TCnCppLineParser.Create
    else
      Parser := TCnPasLineParser.Create; 
    Parser.InStream := inStream;
    Parser.Parse;

    PStatRec^.CommentBytes := Parser.CommentBytes;
    PStatRec^.CodeBytes := Parser.CodeBytes;
    PStatRec^.CommentBlocks := Parser.CommentBlocks;
    PStatRec^.AllLines := Parser.AllLines;
    PStatRec^.EffectiveLines := Parser.EffectiveLines;
    PStatRec^.CodeLines := Parser.CodeLines;
    PStatRec^.CommentLines := Parser.CommentLines;
    PStatRec^.BlankLines := Parser.BlankLines;
  finally
    Parser.Free;
  end;
end;

procedure TCnStatWizard.StatDir;
var
  I: Integer;
  Dir: string;
begin
  { ����Ӧ���Լ���ȡ�ļ����б���Ӧ�÷ŵ� StatFrm �д���}
  Dir := Trim(CnStatForm.cbbDir.Text);
  if Dir = '' then
  begin
    ErrorDlg(SCnStatDirEmpty);
    Exit;
  end;
  if not DirectoryExists(Dir) then
  begin
    ErrorDlg(SCnStatDirNotExists);
    Exit;
  end;

  if Dir[Length(Dir)] <> '\' then
    Dir := Dir + '\';
  Self.FileNames.Clear;
  if Trim(CnStatForm.cbbMask.Text) = '' then
    FMasks := GetDefFileMask
  else
    FMasks := Trim(CnStatForm.cbbMask.Text);

  CnStatResultForm.ClearResult;
  Screen.Cursor := crHourGlass;
  CnStatResultForm.TreeView.Items.BeginUpdate;
  try
    FindFile(Dir, '*.*', OnFindFile, nil, CnStatForm.cbSubDirs.Checked);

    if Self.FileNames.Count > 0 then
    begin
      for I := 0 to Self.FileNames.Count - 1 do
        Self.ProcessAFile(Self.FileNames.Strings[I], 0, True, Dir);

      CnStatResultForm.StaticEnd := True;
      if CnStatResultForm.TreeView.Items.Count > 0 then
      begin
        CnStatResultForm.TreeView.Items[0].Expand(True);
        CnStatResultForm.TreeView.Selected := CnStatResultForm.TreeView.Items[0];
        if Assigned(CnStatResultForm.TreeView.OnChange) then
          CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
      end;
    end
    else
      ErrorDlg(SCnErrorNoFile);
  finally
    Screen.Cursor := crDefault;
    CnStatResultForm.TreeView.Items.EndUpdate;
  end;
end;

procedure TCnStatWizard.StatOpenUnits;
var
  I, J: Integer;
  sName: string;
{$IFDEF DELPHI_OTA}
  Module: IOTAModule;
  Editor: IOTAEditor;
  iModuleServices: IOTAModuleServices;
  SourceEditor: IOTASourceEditor;
{$ENDIF}
begin
{$IFDEF DELPHI_OTA}
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices.GetModuleCount = 0 then
  begin
    ErrorDlg(SCnErrorNoFile);
    Exit;
  end;
{$ENDIF}

{$IFDEF LAZARUS}
  if (SourceEditorManagerIntf = nil) or (SourceEditorManagerIntf.SourceEditorCount <= 0) then
  begin
    ErrorDlg(SCnErrorNoFile);
    Exit;
  end;
{$ENDIF}

  CnStatResultForm.ClearResult;
  Screen.Cursor := crHourGlass;
  CnStatResultForm.TreeView.Items.BeginUpdate;

  try
{$IFDEF DELPHI_OTA}
    for I := 0 to iModuleServices.GetModuleCount - 1 do
    begin
      Module := iModuleServices.GetModule(I);
      if Module <> nil then
      begin
        for J := 0 to Module.GetModuleFileCount - 1 do
        begin
          Editor := Module.GetModuleFileEditor(J);
          if Supports(Editor, IOTASourceEditor, SourceEditor) then
          begin
            sName := SourceEditor.FileName;
            if (sName = '') or (UpperCase(_CnExtractFileExt(sName)) = '.BPG') or
              ((not (IsDelphiSourceModule(sName) or IsDpk(sName)))
              and (not (IsCppSourceModule(sName)) or IsBpk(sName))) then
              Continue;
            Self.ProcessAFile(sName, 0);
          end;
        end;
      end;
    end;
 {$ENDIF}

 {$IFDEF LAZARUS}
    for I := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
    begin;
      if IsSourceModule(SourceEditorManagerIntf.SourceEditors[I].FileName) then
        ProcessAFile(SourceEditorManagerIntf.SourceEditors[I].FileName, 0);
    end;
 {$ENDIF}

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := CnStatResultForm.TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  finally
    Screen.Cursor := crDefault;
    CnStatResultForm.TreeView.Items.EndUpdate;
  end;
end;

procedure TCnStatWizard.StatProject;
var
  I, J: Integer;
  Project: TCnIDEProjectInterface;
  Opened: Boolean;
{$IFDEF DELPHI_OTA}
  Module: IOTAModule;
  Editor: IOTAEditor;
  SrcEditor: IOTASourceEditor;
{$ENDIF}
begin
  Project := CnOtaGetCurrentProject;
  if Project = nil then
  begin
    ErrorDlg(SCnErrorNoFile);
    Exit;
  end;

  CnStatResultForm.ClearResult;
  Screen.Cursor := crHourGlass;
  CnStatResultForm.TreeView.Items.BeginUpdate;

  try
{$IFDEF DELPHI_OTA}
{$IFDEF BDS}
    if IsBdsProject(Project.FileName) or IsDProject(Project.FileName) then
    begin
      if FileExists(_CnChangeFileExt(Project.FileName, '.dpr')) then
        ProcessAFile(_CnChangeFileExt(Project.FileName, '.dpr'), 0)
      else if FileExists(_CnChangeFileExt(Project.FileName, '.dpk')) then
        ProcessAFile(_CnChangeFileExt(Project.FileName, '.dpk'), 0);
    end
    else if IsCbProject(Project.FileName) then // BCB ���̵����ļ�
    begin
      if FileExists(_CnChangeFileExt(Project.FileName, '.cpp')) then
        ProcessAFile(_CnChangeFileExt(Project.FileName, '.cpp'), 0);
    end;
{$ELSE}
    Self.ProcessAFile(Project.FileName, 0);
{$ENDIF}

    for I := 0 to Project.GetModuleCount - 1 do
    begin
      if (Project.GetModule(I).FileName = '') or
        (not (IsDelphiSourceModule(Project.GetModule(I).FileName) or
          IsPackage(Project.GetModule(I).FileName))) and
        (not IsCppSourceModule(Project.GetModule(I).FileName)) then
        Continue;

      Opened := CnOtaIsFileOpen(Project.GetModule(I).FileName);
      try
        Module := Project.GetModule(I).OpenModule;
      except
        Module := nil;
      end;

      if Module <> nil then
      begin
        for J := 0 to Module.GetModuleFileCount - 1 do
        begin
          Editor := Module.GetModuleFileEditor(J);
          if Supports(Editor, IOTASourceEditor, SrcEditor) then
          begin
            if IsDelphiSourceModule(SrcEditor.FileName)
              or IsPackage(SrcEditor.FileName)
              or IsCppSourceModule(SrcEditor.FileName) then
            begin
              ProcessAFile(SrcEditor.FileName, 1);
            end;
          end;
        end;
      end;

      if not Opened then
      begin
        try
          Module.CloseModule(True);
        except
          ;
        end;
        Module := nil;
      end;
    end;
{$ENDIF}

{$IFDEF LAZARUS}
    for I := 0 to Project.FileCount - 1 do
    begin
      if Project.Files[I].IsPartOfProject and IsSourceModule(Project.Files[I].Filename) then
        ProcessAFile(Project.Files[I].Filename, 1);
    end;
{$ENDIF}

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := CnStatResultForm.TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  finally
    Screen.Cursor := crDefault;
    CnStatResultForm.TreeView.Items.EndUpdate;
  end;
end;

{$IFDEF DELPHI_OTA}

procedure TCnStatWizard.StatProjectGroup;
var
  I, J, K: Integer;
  Module: IOTAModule;
  Editor: IOTAEditor;
  SrcEditor: IOTASourceEditor;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  Opened: Boolean;
begin
  ProjectGroup := CnOtaGetProjectGroup;
  if ProjectGroup = nil then
  begin
    ErrorDlg(SCnErrorNoFile);
    Exit;
  end;

  CnStatResultForm.ClearResult;
  Screen.Cursor := crHourGlass;
  CnStatResultForm.TreeView.Items.BeginUpdate;

  try
    Self.ProcessAFile(ProjectGroup.FileName, 0);
{$IFDEF DEBUG}
    CnDebugger.LogInteger(ProjectGroup.ProjectCount, 'Project Count');
{$ENDIF}
    for I := 0 to ProjectGroup.ProjectCount - 1 do
    begin
      Project := ProjectGroup.Projects[I];
      if Project <> nil then
      begin
{$IFDEF BDS}
        if IsBdsProject(Project.FileName) or IsDProject(Project.FileName)
          or IsCbProject(Project.FileName) then
        begin
          if FileExists(_CnChangeFileExt(Project.FileName, '.dpr')) then
            ProcessAFile(_CnChangeFileExt(Project.FileName, '.dpr'), 1)
          else if FileExists(_CnChangeFileExt(Project.FileName, '.dpk')) then
            ProcessAFile(_CnChangeFileExt(Project.FileName, '.dpk'), 1);
        end;
{$ELSE}
        Self.ProcessAFile(Project.FileName, 1);
{$ENDIF}
        for J := 0 to Project.GetModuleCount - 1 do
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Project [%d] has %d Module', [I, Project.GetModuleCount]);
{$ENDIF}
          if (Project.GetModule(J).FileName = '')  or
            (not (IsDelphiSourceModule(Project.GetModule(J).FileName) or
              IsPackage(Project.GetModule(J).FileName))) and
            (not IsCppSourceModule(Project.GetModule(J).FileName)) then
            Continue;

          Opened := CnOtaIsFileOpen(Project.GetModule(J).FileName);
          try
            Module := Project.GetModule(J).OpenModule;
          except
            Module := nil;
          end;

          if Module <> nil then
          begin
            for K := 0 to Module.GetModuleFileCount - 1 do
            begin
              Editor := Module.GetModuleFileEditor(K);
              if Supports(Editor, IOTASourceEditor, SrcEditor) then
              begin
                if IsDelphiSourceModule(SrcEditor.FileName)
                  or IsPackage(SrcEditor.FileName)
                  or IsCppSourceModule(SrcEditor.FileName) then
                begin
                  ProcessAFile(SrcEditor.FileName, 2);
                end;
              end;
            end;
          end;

          if not Opened then
          begin
            try
              Module.CloseModule(True);
            except
              ;
            end;
            Module := nil;
          end;
        end;
      end
      else
        ErrorDlg(SCnErrorNoFile);
    end;

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := CnStatResultForm.TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  finally
    Screen.Cursor := crDefault;
    CnStatResultForm.TreeView.Items.EndUpdate;
  end;
end;

{$ENDIF}

procedure TCnStatWizard.StatUnit;
begin
  CnStatResultForm.ClearResult;
{$IFNDEF STAND_ALONE}
  if (CnOtaGetCurrentSourceEditor <> nil) and (CnOtaGetCurrentSourceEditor.FileName <> '') then
    ProcessAFile(CnOtaGetCurrentSourceEditor.FileName, 0)
  else
{$ENDIF}
    ErrorDlg(SCnErrorNoFile);
end;

procedure TCnStatWizard.SetActive(Value: Boolean);
begin
  inherited;
  if not Active then
  begin
    if CnStatResultForm <> nil then
      FreeAndNil(CnStatResultForm);
    if CnStatForm <> nil then
      FreeAndNil(CnStatForm);
  end;
end;

function TCnStatWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '����,�к�,count,line,';
end;

initialization
  RegisterCnWizard(TCnStatWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNSTATWIZARD}
end.
