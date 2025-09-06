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

unit CnExplore;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ļ�������ר�ҵ�Ԫ
* ��Ԫ���ߣ�Hhha��Hhha�� Hhha@eyou.con
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 7
* ���ݲ��ԣ�δ����
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.03.01
*               ��ֲ�� 64 λ������ Sys Ŀ¼��λ����
*           2003.12.03 by QSoft
*               ��ֲ�� D5
*           2003.11.17
*               ��������ʷ��Ϣ���湦���е� Bug
*           2003.11.08
*               �����˲��ֳ����ע�ͣ������˳�ʼ���� Bug
*           2003.10.30
*               ��ɳ�ʼ������ʷ��Ϣ���湦��
*           2003.10.28
*               �����������ʱ�ļ�ʱ�����͵�ѡ��
*           2003.10.09
*               �������Դ������ ListView �Ĺ��˹���
*               ����:CopyCharDB, GetCharsUpToNextCharDB, ExtensionsToTStrings
*               ������ Scp 1.7 ����ֲ
*               �������ļ����������ļ��غͳ�ʼ����λ����,�Լ��ļ���\�ļ�\����
*               ����������
*           2003.10.08
*               �����������ڵĲ��ֹ���,�����˲���ע��
*               1.����"����ͼ��"����Ϊ�˵���ʽ����
*               2.����"�ļ�����"���ܵĲ˵�ѡ��ʽ
*               3.����"�ļ���"���ܵĲ˵�ѡ��ʽ
*           2003.10.05
*               ʹ�� Delphi �� Demo �е���Դ�������ؼ��滻�� SCP1.7
*               �����ļ��еĴ���,�ļ�(��)��ɾ���͹��˹����д��ڽ�һ������
*               �����˴��� Dock ��Ŀؼ� Resize �ļ�
*               �޸��˴��ڵļ��ط�ʽ
*           2003.09.29
*               �����ļ�.����ʵ����Դ������,���˺�ɾ����ʱ�ļ�
*
* ���������⣺shlcmbx��·���������⣨��Ҫ�޸Ŀؼ���
*             shlst������������ļ��϶����⣨��Ҫ�޸Ŀؼ���
*            ר�ҵ�λ�ô洢���⡣
*
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

uses
  Forms, SysUtils, Messages, Windows, Classes, Controls, ExtCtrls, ComCtrls,
  IniFiles, StdCtrls, Menus, ToolWin, ActnList, ImgList,
  {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF}
  {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF}
  CnWizIdeDock, CnShellCtrls, CnWizClasses, CnConsts, CnWizConsts, CnPopupMenu;

//==============================================================================
// Explore ���ߴ���
//==============================================================================

{ TCnExploreForm }

type
  TDockState = (dsDocked, dsUndocked); //����״̬

  TCnExplorerWizard = class;

  TCnExploreForm = class(TCnIdeDockForm)
    ToolBar: TToolBar;
    btnListIcon: TToolButton;
    il: TImageList;
    btnFilter: TToolButton;
    btnUp: TToolButton;
    stat: TStatusBar;
    btnCurrProj: TToolButton;
    spl: TSplitter;
    pnlClient: TPanel;
    shltv: TCnShellTreeView;
    shlst: TCnShellListView;
    pmViewStyle: TPopupMenu;
    mnuitmVSIcon: TMenuItem;
    mnuitmVSSmallIcon: TMenuItem;
    mnuitmVSList: TMenuItem;
    mnuitmVSDetail: TMenuItem;
    pmFileFilter: TPopupMenu;
    pmFolder: TPopupMenu;
    mnuitmFCurProj: TMenuItem;
    N1: TMenuItem;
    mnuitmFsys: TMenuItem;
    mnuitmFtoolsapi: TMenuItem;
    mnuitmFcommon: TMenuItem;
    mnuitmFwin: TMenuItem;
    N2: TMenuItem;
    mnuitmF1: TMenuItem;
    mnuitmF2: TMenuItem;
    mnuitmF3: TMenuItem;
    mnuitmF4: TMenuItem;
    mnuitmF5: TMenuItem;
    N3: TMenuItem;
    mnuitmFMore: TMenuItem;
    mnuitmFAdd: TMenuItem;
    N5: TMenuItem;
    mnuitmFF1: TMenuItem;
    mnuitmFF2: TMenuItem;
    mnuitmFF3: TMenuItem;
    mnuitmFF4: TMenuItem;
    mnuitmFF5: TMenuItem;
    N6: TMenuItem;
    mnuitmFFMore: TMenuItem;
    mnuitmFFFolder: TMenuItem;
    mnuitmFFFiles: TMenuItem;
    N7: TMenuItem;
    mnuitmFFHide: TMenuItem;
    actlst: TActionList;
    actFilter1: TAction;
    actFilter2: TAction;
    actFilter3: TAction;
    actFilter4: TAction;
    actFilter5: TAction;
    actFilter0: TAction;
    actFolder0: TAction;
    actFolder1: TAction;
    actFolder2: TAction;
    actFolder3: TAction;
    actFolder4: TAction;
    actFolder5: TAction;
    actFFFolder: TAction;
    actFFFiles: TAction;
    actFFHide: TAction;
    mnuitmFCurFile: TMenuItem;
    btnCreateDir: TToolButton;
    actCreateDir: TAction;
    ilLarge: TImageList;
    procedure btnUpClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure btnListIconClick(Sender: TObject);
    procedure btnCurrProjClick(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure mnuitmFCurProjClick(Sender: TObject);
    procedure mnuitmFFMoreClick(Sender: TObject);
    procedure mnuitmFsysClick(Sender: TObject);
    procedure mnuitmFcommonClick(Sender: TObject);
    procedure mnuitmFwinClick(Sender: TObject);
    procedure mnuitmFtoolsapiClick(Sender: TObject);
    procedure shltvChange(Sender: TObject; Node: TTreeNode);
    procedure shlstAddFolder(Sender: TObject; AFolder: TShellFolder;
      var CanAdd: Boolean);
    procedure actFilter1Update(Sender: TObject);
    procedure actFolder0Update(Sender: TObject);
    procedure actFilter0Update(Sender: TObject);
    procedure actFilter1Execute(Sender: TObject);
    procedure mnuitmFMoreClick(Sender: TObject);
    procedure actFolder1Execute(Sender: TObject);
    procedure mnuitmFAddClick(Sender: TObject);
    procedure actVSIconExecute(Sender: TObject);
    procedure actFFFolderExecute(Sender: TObject);
    procedure mnuitmFCurFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCreateDirExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FWizard: TCnExplorerWizard;

    FDockState: TDockState; // ���� Dock ״̬
    FFileFilterKey: string; // �����ַ� Key
    FFileFilterVal: string; // �����ַ� Value
    FFileFilterList: TStringList; // �ļ����������б�,���ݴ���ʹ��
    FDirectoryList: TStringList;  // �ղ��ļ����б�����ʹ��
    FFileFilterMenu: TStringList; // �ļ����������б�,�˵�ʹ��
    FDirectoryMenu: TStringList;  // �ղ��ļ����б��˵�ʹ��
    function GetBoolean(const Index: Integer): Boolean;
    procedure SetBoolean(const Index: Integer; const Value: Boolean);

    procedure ChangeListViewStyle(Index: Integer); // �ı� ListView �� ViewStype
    function GetListViewStyle(): Integer; // �õ� ListView �� ViewStype
    function ChangeMenu(AValue: string; AStrList: TStringList): Boolean;
    procedure PopupMenu(Sender: TObject; PopMenu: TPopupMenu);
    procedure SetFilter(AValue, AKey: string);  // �����ļ�����
    procedure LoadFileFilterState;              // ���� FileFilter �˵�
    procedure LoadFolderState;                  // ���� Folder ���˲˵�
    procedure ChangeShlstSet;  //�ı� Shlsh �� ObjectTypes ����
  protected
    function GetHelpTopic: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property FilesCheck: Boolean index 0 read GetBoolean write SetBoolean;
    property FolderCheck: Boolean index 1 read GetBoolean write SetBoolean;
    property HideCheck: Boolean index 2 read GetBoolean write SetBoolean;
    property VSDetailCheck: Boolean index 3 read GetBoolean write SetBoolean;
    property VSListCheck: Boolean index 4 read GetBoolean write SetBoolean;
    property VSIconCheck: Boolean index 5 read GetBoolean write SetBoolean;
    property VSSmallIconCheck: Boolean index 6 read GetBoolean write SetBoolean;
    property ListViewStyle: Integer read GetListViewStyle write
      ChangeListViewStyle;
    property Filter: TStringList read FFileFilterMenu;
    property Folder: TStringList read FDirectoryMenu;
    property FolderList: TStringList read FDirectoryList;
  end;

  TCnExplorerWizard = class(TCnMenuWizard)
  private
    FFilesCheck: Boolean;
    FFolderCheck: Boolean;
    FHideCheck: Boolean;
    FListViewStyle: Integer;
    FVSDetailCheck: Boolean;
    FVSListCheck: Boolean;
    FVSIconCheck: Boolean;
    FVSSmallIconCheck: Boolean;
    FFilter: TStringList;
    FFolder: TStringList;
    FFolderList: TStringList;
  protected
    procedure SetActive(Value: Boolean); override;

    property FilesCheck: Boolean read FFilesCheck write FFilesCheck;
    property FolderCheck: Boolean read FFolderCheck write FFolderCheck;
    property HideCheck: Boolean read FHideCheck write FHideCheck;
    property ListViewStyle: Integer read FListViewStyle write FListViewStyle;
    property VSDetailCheck: Boolean read FVSDetailCheck write FVSDetailCheck;
    property VSListCheck: Boolean read FVSListCheck write FVSListCheck;
    property VSIconCheck: Boolean read FVSIconCheck write FVSIconCheck;
    property VSSmallIconCheck: Boolean read FVSSmallIconCheck write
      FVSSmallIconCheck;
    property Filter: TStringList read FFilter;
    property Folder: TStringList read FFolder;
    property FolderList: TStringList read FFolderList;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCommon, CnIni, CnWizUtils, CnWizIdeUtils, CnWizOptions, CnWizShareImages,
  CnExploreDirectory, CnExploreFilter;

{$R *.DFM}

const
  csCnExploreForm = 'CnExploreForm';

var
  CnExploreForm: TCnExploreForm;

procedure CopyCharDB(var APos: Integer; const ASource: string; var ADest:
  string);
begin
  if IsDBCSLeadByte(Byte(ASource[APos])) then
  begin
    ADest := ADest + ASource[APos] + ASource[APos + 1];
    Inc(APos, 2);
  end
  else
  begin
    ADest := ADest + ASource[APos];
    Inc(APos);
  end;
end;

procedure GetCharsUpToNextCharDB(var APos: Integer; ASource: string; var ADest:
  string; CharToFind: Char);
begin
  ADest := '';
  while (ASource[APos] <> CharToFind) and (APos <= Length(ASource)) do
    CopyCharDB(APos, ASource, ADest);
end;

// ���ļ���չ���ַ���ת���� TStringList
procedure ExtensionsToTStrings(AExtensions: string; AExts: TStringList);
var
  Ps: Integer;
  Ext: string;
begin
  Ps := 1;
  while (Ps <= Length(AExtensions)) do
  begin
    GetCharsUpToNextCharDB(Ps, AExtensions, Ext, ';'); Inc(Ps);
    if (Ext <> '') and (Ext <> '*.*') then AExts.Add(Ext);
  end;

  AExts.Sorted := TRUE;
  AExts.Duplicates := dupIgnore;
end;

procedure TCnExploreForm.FormCreate(Sender: TObject);
begin
{$IFNDEF FPC}
  shltv.ChangeDelay := 50;
{$ENDIF}
end;

// �ı䱣�� Menu ��Ϣ�� StringList
function TCnExploreForm.ChangeMenu(AValue: string; AStrList: TStringList):
  Boolean;
var
  I, Loca: Integer;
begin
  Loca := AStrList.IndexOf(AValue);
  if Loca < 0 then
  begin
    AStrList.Insert(0, AValue);
    if AStrList.Count > 5 then
      AStrList.Delete(5);
  end
  else
  begin
    if Loca = 0 then
    begin
      Result := False;
      Exit;
    end
    else
    Begin
      for I := Loca - 1 downto 0 do
        AStrList.Strings[I + 1] := AStrList.Strings[I];
      AStrList.Strings[0] := AValue;
    end;
  end;
  Result := True;
end;

//==============================================================================
// Explorer ���ߴ���
//==============================================================================

// ��ť�����˵�
procedure TCnExploreForm.PopupMenu(Sender: TObject; PopMenu: TPopupMenu);
var
  P: TPoint;
begin
  P := TWinControl(Sender).ClientToScreen(Point(0, TWinControl(Sender).Height));
  PopMenu.Popup(P.x, P.y);
end;

procedure TCnExploreForm.LoadFileFilterState;
begin
  if FFileFilterMenu.Count >= 1 then
    actFilter1.Caption := FFileFilterMenu.Strings[0];
  if FFileFilterMenu.Count >= 2 then
    actFilter2.Caption := FFileFilterMenu.Strings[1];
  if FFileFilterMenu.Count >= 3 then
    actFilter3.Caption := FFileFilterMenu.Strings[2];
  if FFileFilterMenu.Count >= 4 then
    actFilter4.Caption := FFileFilterMenu.Strings[3];
  if FFileFilterMenu.Count >= 5 then
    actFilter5.Caption := FFileFilterMenu.Strings[4];
end;

procedure TCnExploreForm.LoadFolderState;
begin
  if FDirectoryMenu.Count >= 1 then
    actFolder1.Caption := FDirectoryMenu.Strings[0];
  if FDirectoryMenu.Count >= 2 then
    actFolder2.Caption := FDirectoryMenu.Strings[1];
  if FDirectoryMenu.Count >= 3 then
    actFolder3.Caption := FDirectoryMenu.Strings[2];
  if FDirectoryMenu.Count >= 4 then
    actFolder4.Caption := FDirectoryMenu.Strings[3];
  if FDirectoryMenu.Count >= 5 then
    actFolder5.Caption := FDirectoryMenu.Strings[4];
end;

procedure TCnExploreForm.SetFilter(AValue, AKey: string);
var
  S: string;
begin
  S := FFileFilterVal;
  FFileFilterVal := AValue;

  if S <> FFileFilterVal then
  begin
    if not Assigned(FFileFilterList) then
      FFileFilterList := TStringList.Create
    else
      FFileFilterList.Clear;

    ExtensionsToTStrings(AValue, FFileFilterList);
    FFileFilterKey := AKey;

    shlst.Refresh;
  end;

  if ChangeMenu(AKey + '(' + AValue + ')', FFileFilterMenu) then
    LoadFileFilterState();
end;

procedure TCnExploreForm.ChangeListViewStyle(Index: Integer);
begin
  case Index of
    0: shlst.ViewStyle := vsIcon;
    1: shlst.ViewStyle := vsSmallIcon;
    2: shlst.ViewStyle := vsList;
    3: shlst.ViewStyle := vsReport;
  end;
  btnListIcon.Tag := Index;
end;

function TCnExploreForm.GetListViewStyle(): Integer;
begin
  Result := 0;
  if shlst.ViewStyle = vsIcon then
    Result := 0
  else if shlst.ViewStyle = vsSmallIcon then
    Result := 1
  else if shlst.ViewStyle = vsList then
    Result := 2
  else if shlst.ViewStyle = vsReport then
    Result := 3;
end;

procedure TCnExploreForm.btnListIconClick(Sender: TObject);
begin
  PopupMenu(Sender, pmViewStyle);
end;

procedure TCnExploreForm.FormEndDock(Sender, Target: TObject; X,
  Y: Integer);
begin
  inherited;
  if (FDockState = dsUndocked) and (Target <> nil) then
    //pnlComboResize(Sender);
    ;

  if Target = nil then
    FDockState := dsUndocked
  else
    FDockState := dsDocked;
end;

procedure TCnExploreForm.btnUpClick(Sender: TObject);
var
  Target: TTreeNode;
begin
  if Assigned(shltv.Selected) and Assigned(shltv.Selected.Parent) then
  begin
    Target := shltv.Selected;
    Target := Target.Parent;
    Target.Selected := TRUE;
  end;
end;

procedure TCnExploreForm.btnFilterClick(Sender: TObject);
begin
  PopupMenu(Sender, pmFileFilter);
end;

procedure TCnExploreForm.btnCurrProjClick(Sender: TObject);
begin
  PopupMenu(Sender, pmFolder);
end;

procedure TCnExploreForm.mnuitmFCurProjClick(Sender: TObject);
var
  CurPath: string;
begin
  CurPath := _CnExtractFilePath(CnOtaGetCurrentProjectFileName);
  if CurPath <> '' then
    shltv.Path := CurPath;
end;

procedure TCnExploreForm.mnuitmFCurFileClick(Sender: TObject);
var
  CurPath: string;
begin
{$IFDEF DELPHI_OTA}
  CurPath := _CnExtractFilePath(CnOtaGetFileNameOfCurrentModule);
{$ENDIF}
{$IFDEF LAZARUS}
  CurPath := _CnExtractFilePath(CnOtaGetCurrentSourceFile);
{$ENDIF}
  if CurPath <> '' then
    shltv.Path := CurPath;
end;

procedure TCnExploreForm.mnuitmFFMoreClick(Sender: TObject);
var
  Result, Row: Integer;
  Filter, Key: string;
begin
  CnExploreFilterForm := TCnExploreFilterForm.Create(nil);
  with CnExploreFilterForm do
  try
    chkFolder.Checked := otFolders in shlst.ObjectTypes;
    chkFiles.Checked := otNonFolders in shlst.ObjectTypes;
    chkHider.Checked := otHidden in shlst.ObjectTypes;
    if FindFilter(FFileFilterKey, Row) then
      Selected := Row;
    stat.Panels[0].Text := stat.Panels[0].Text + ' ' + FFileFilterVal;

    Result := ShowModal;
    if Result = mrOK then
    begin
      if chkFolder.Checked and chkFiles.Checked and chkHider.Checked then
        shlst.ObjectTypes := [otFolders, otNonFolders, otHidden]
      else if chkFolder.Checked and chkFiles.Checked then
        shlst.ObjectTypes := [otFolders, otNonFolders]
      else if chkFolder.Checked and chkHider.Checked then
        shlst.ObjectTypes := [otFolders, otHidden]
      else if chkFiles.Checked and chkHider.Checked then
        shlst.ObjectTypes := [otNonFolders, otHidden]
      else if chkFolder.Checked then
        shlst.ObjectTypes := [otFolders]
      else if chkFiles.Checked then
        shlst.ObjectTypes := [otNonFolders]
      else if chkHider.Checked then
        shlst.ObjectTypes := [otHidden]
      else
        shlst.ObjectTypes := [];

      GetFilter(Selected, Key, Filter);
      SetFilter(Filter, Key);
    end;
  finally
    Free;
    CnExploreFilterForm := nil;
  end;
end;

procedure TCnExploreForm.mnuitmFsysClick(Sender: TObject);
begin
{$IFDEF BDS}
  {$IFDEF DELPHIXE_UP}
  shltv.Path := WizOptions.CompilerPath + 'Source\Rtl\Sys';
  {$ELSE}
  shltv.Path := WizOptions.CompilerPath + 'Source\Win32\Rtl\Sys';
  {$ENDIF}
{$ELSE}
  shltv.Path := WizOptions.CompilerPath + 'Source\Rtl\Sys';
{$ENDIF}
end;

procedure TCnExploreForm.mnuitmFcommonClick(Sender: TObject);
begin
{$IFDEF BDS}
  shltv.Path := WizOptions.CompilerPath + 'Source\Win32\Rtl\Common';
{$ELSE}
  shltv.Path := WizOptions.CompilerPath + 'Source\Rtl\Common';
{$ENDIF}
end;

procedure TCnExploreForm.mnuitmFwinClick(Sender: TObject);
begin
{$IFDEF BDS}
  shltv.Path := WizOptions.CompilerPath + 'Source\Win32\Rtl\Win';
{$ELSE}
  shltv.Path := WizOptions.CompilerPath + 'Source\Rtl\Win';
{$ENDIF}
end;

procedure TCnExploreForm.mnuitmFtoolsapiClick(Sender: TObject);
begin
  shltv.Path := WizOptions.CompilerPath + 'Source\ToolsAPI';
end;

procedure TCnExploreForm.shltvChange(Sender: TObject; Node: TTreeNode);
begin
  stat.Panels[0].Text := shltv.Path;
end;

procedure TCnExploreForm.shlstAddFolder(Sender: TObject;
  AFolder: TShellFolder; var CanAdd: Boolean);

  function FileinExtList(const aFile: string): Boolean;
  var
    I: Integer;
    XExt: string;
  begin
    Result := False;
    if FFileFilterList.Count > 0 then
      for I := 0 to FFileFilterList.Count - 1 do
      begin
        XExt := _CnExtractFileExt(aFile);
        if UpperCase('*' + XExt) = UpperCase(FFileFilterList.Strings[I]) then
        begin
          Result := True;
          Break;
        end;
      end;
  end;

begin
  if FFileFilterList <> nil then
  begin
    if FFileFilterList.Count > 0 then
    begin
      if (FileinExtList(AFolder.DisplayName)) or (AFolder.IsFolder) then
        CanAdd := True
      else
        CanAdd := False;
    end;
  end;
end;

procedure TCnExploreForm.actFilter1Update(Sender: TObject);
begin
  (Sender as TAction).Visible := (Sender as TAction).Caption <> '';
end;

procedure TCnExploreForm.actFolder0Update(Sender: TObject);
begin
  (Sender as TAction).Visible := actFolder1.Caption <> '';
end;

procedure TCnExploreForm.actFilter0Update(Sender: TObject);
begin
  (Sender as TAction).Visible := actFilter1.Caption <> '';
end;

procedure TCnExploreForm.actFilter1Execute(Sender: TObject);
var
  AValue: string;
  AKey: string;
  APos: Integer;
begin
  AValue := FFileFilterMenu.Strings[(Sender as TAction).Tag];
  APos := 1;
  GetCharsUpToNextCharDB(APos, AValue, AKey, '(');
  inc(APos);
  GetCharsUpToNextCharDB(APos, AValue, AValue, ')');
  SetFilter(AValue, AKey);
end;

procedure TCnExploreForm.mnuitmFMoreClick(Sender: TObject);
var
  Result: Integer;
  Directory: string;
begin
  CnExploreDirctoryForm := TCnExploreDirctoryForm.Create(nil);
  with CnExploreDirctoryForm do
  begin
    try
      stat.Panels[0].Text := stat.Panels[0].Text + ' ' + shltv.Path;
      lst.Items.Assign(FDirectoryList);
      Result := ShowModal;
      if Result = mrOK then
      begin
        try
          Directory := lst.Items[lst.ItemIndex];
          shltv.Path := Directory;
          if ChangeMenu(Directory, FDirectoryMenu) then
            LoadFolderState;
        except
          ;
        end;
        FDirectoryList.Assign(lst.Items);
      end;
    finally
      Free;
      CnExploreDirctoryForm := nil;
    end;
  end;
end;

procedure TCnExploreForm.actFolder1Execute(Sender: TObject);
var
  Directory: string;
begin
  Directory := FDirectoryMenu.Strings[(Sender as TAction).Tag];
  shltv.Path := Directory;
  if ChangeMenu(Directory, FDirectoryMenu) then
    LoadFolderState;
end;

procedure TCnExploreForm.mnuitmFAddClick(Sender: TObject);
begin
  if FDirectoryList.IndexOf(shltv.Path) < 0 then
    FDirectoryList.Add(shltv.Path);
end;

// Boolean ����д����

procedure TCnExploreForm.SetBoolean(const Index: Integer; const Value: Boolean);
begin
  case Index of
    0: actFFFolder.Checked := Value;
    1: actFFFiles.Checked := Value;
    2: actFFHide.Checked := Value;
    3: mnuitmVSDetail.Checked := Value;
    4: mnuitmVSList.Checked := Value;
    5: mnuitmVSIcon.Checked := Value;
    6: mnuitmVSSmallIcon.Checked := Value;
  end;
end;

// Boolean ���Զ�����

function TCnExploreForm.GetBoolean(const Index: Integer): Boolean;
begin
  case Index of
    0: Result := actFFFolder.Checked;
    1: Result := actFFFiles.Checked;
    2: Result := actFFHide.Checked;
    3: Result := mnuitmVSDetail.Checked;
    4: Result := mnuitmVSList.Checked;
    5: Result := mnuitmVSIcon.Checked;
    6: Result := mnuitmVSSmallIcon.Checked;
  else
    Result := False;
  end;
end;

function TCnExploreForm.GetHelpTopic: string;
begin
  Result := 'CnExplorerWizard';
end;

constructor TCnExploreForm.Create(AOwner: TComponent);
var
  CurPath: string;
begin
  inherited Create(AOwner);
  FDockState := dsUndocked;
  FFileFilterList := TStringList.Create;
  FDirectoryList := TStringList.Create;
  FFileFilterMenu := TStringList.Create;
  FDirectoryMenu := TStringList.Create;

  // ����·��Ϊ��ǰ���̵�·��
  CurPath := _CnExtractFilePath(CnOtaGetCurrentProjectFileName);
  if CurPath <> '' then
    shltv.Path := CurPath;

  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
{$IFNDEF IDE_SUPPORT_HDPI}
  if WizOptions.UseLargeIcon then
  begin
    dmCnSharedImages.StretchCopyToLarge(il, ilLarge);
    ToolBar.Images := ilLarge;
  end;
{$ENDIF}
  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
end;

destructor TCnExploreForm.Destroy;
begin
  if Assigned(FFileFilterList) then
    FreeAndnil(FFileFilterList);
  if Assigned(FDirectoryList) then
    FreeAndnil(FDirectoryList);
  if Assigned(FFileFilterMenu) then
    FreeAndnil(FFileFilterMenu);
  if Assigned(FDirectoryMenu) then
    FreeAndnil(FDirectoryMenu);

  inherited Destroy;
  CnExploreForm := nil;
end;

constructor TCnExplorerWizard.Create;
begin
  inherited;

  FFilter := TStringList.Create;
  FFolder := TStringList.Create;
  FFolderList := TStringList.Create;
end;

destructor TCnExplorerWizard.Destroy;
begin
  FreeAndNil(CnExploreForm);

  Filter.Free;
  Folder.Free;
  FolderList.Free;
  inherited;
end;

procedure TCnExplorerWizard.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
  T: string;
begin
  with TCnIniFile.Create(Ini) do
  try
    FListViewStyle := Ini.ReadInteger('', 'FListViewStyle', 3);
    FVSIconCheck := Ini.ReadBool('', 'FVSIconCheck', False);
    FVSSmallIconCheck := Ini.ReadBool('', 'FVSSmallIconCheck', False);
    FVSListCheck := Ini.ReadBool('', 'FVSListCheck', False);
    FVSDetailCheck := Ini.ReadBool('', 'FVSDetailCheck', True);
    FFolderCheck := Ini.ReadBool('', 'FFolderCheck', True);
    FFilesCheck := Ini.ReadBool('', 'FFilesCheck', True);
    FHideCheck := Ini.ReadBool('', 'FHideCheck', True);
    FFolderList.CommaText := Ini.ReadString('', 'FFolderList', '');

    for I := 0 to 4 do
    begin
      T := Ini.ReadString('FFilter', IntToStr(I + 1), '');
      if T <> '' then
        FFilter.Add(T);
    end;
    for I := 0 to 4 do
    begin
      T := Ini.ReadString('FFolder', IntToStr(I + 1), '');
      if T <> '' then
        FFolder.Add(T);
    end;
  finally
    Free;
  end;
end;

procedure TCnExplorerWizard.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  if CnExploreForm <> nil then
  begin
    FilesCheck := CnExploreForm.FilesCheck;
    FolderCheck := CnExploreForm.FolderCheck;
    HideCheck := CnExploreForm.HideCheck;

    VSDetailCheck := CnExploreForm.VSDetailCheck;
    VSListCheck := CnExploreForm.VSListCheck;
    VSIconCheck := CnExploreForm.VSIconCheck;
    VSSmallIconCheck := CnExploreForm.VSSmallIconCheck;
    ListViewStyle := CnExploreForm.ListViewStyle;
    Filter.Assign(CnExploreForm.Filter);
    Folder.Assign(CnExploreForm.Folder);
    FolderList.Assign(CnExploreForm.FolderList);
  end;

  with TCnIniFile.Create(Ini) do
  try
    Ini.WriteInteger('', 'FListViewStyle', FListViewStyle);
    Ini.WriteBool('', 'FVSIconCheck', FVSIconCheck);
    Ini.WriteBool('', 'FVSSmallIconCheck', FVSSmallIconCheck);
    Ini.WriteBool('', 'FVSListCheck', FVSListCheck);
    Ini.WriteBool('', 'FVSDetailCheck', FVSDetailCheck);
    Ini.WriteBool('', 'FFolderCheck', FFolderCheck);
    Ini.WriteBool('', 'FFilesCheck', FFilesCheck);
    Ini.WriteBool('', 'FHideCheck', FHideCheck);
    Ini.WriteString('', 'FFolderList', FFolderList.CommaText);
    for I := 0 to FFilter.Count - 1 do
      Ini.WriteString('FFilter', IntToStr(I + 1), FFilter.Strings[I]);
    for I := 0 to FFolder.Count - 1 do
      Ini.WriteString('FFolder', IntToStr(I + 1), FFolder.Strings[I]);
  finally
    Free;
  end;
end;

procedure TCnExplorerWizard.Execute;
begin
  if CnExploreForm = nil then
  begin
    CnExploreForm := TCnExploreForm.Create(nil);
    CnExploreForm.FWizard := Self;
    CnExploreForm.FilesCheck := FilesCheck;
    CnExploreForm.FolderCheck := FolderCheck;
    CnExploreForm.HideCheck := HideCheck;
    CnExploreForm.VSDetailCheck := VSDetailCheck;
    CnExploreForm.VSListCheck := VSListCheck;
    CnExploreForm.VSIconCheck := VSIconCheck;
    CnExploreForm.VSSmallIconCheck := VSSmallIconCheck;
    CnExploreForm.ListViewStyle := ListViewStyle;
    CnExploreForm.Filter.Assign(Filter);
    CnExploreForm.Folder.Assign(Folder);
    CnExploreForm.FolderList.Assign(FolderList);

    CnExploreForm.ChangeShlstSet;
    CnExploreForm.LoadFileFilterState;
    CnExploreForm.LoadFolderState;
  end;
{$IFDEF DELPHI_OTA}
  IdeDockManager.ShowForm(CnExploreForm);
{$ELSE}
  CnExploreForm.Show;
{$ENDIF}
end; 

function TCnExplorerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end; 

class procedure TCnExplorerWizard.GetWizardInfo(var Name, Author, Email, Comment:
  string);
begin
  Name := SCnExploreName;
  Author := SCnPack_Hhha + #13#10 + SCnPack_QSoft;
  Email := SCnPack_HhhaEmail + #13#10 + SCnPack_QSoftEmail;
  Comment := SCnExploreComment;
end;

function TCnExplorerWizard.GetCaption: string;
begin
  Result := SCnExploreMenuCaption;
end; 

function TCnExplorerWizard.GetHint: string;
begin
  Result := SCnExploreMenuHint;
end;

function TCnExplorerWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnExploreForm.FormDestroy(Sender: TObject);
begin
  CnExploreForm := nil;
  inherited;
end;

procedure TCnExploreForm.actVSIconExecute(Sender: TObject);
begin
  inherited;
  (Sender as TMenuItem).Checked := True;
  ChangeListViewStyle((Sender as TMenuItem).Tag);
end;

procedure TCnExploreForm.ChangeShlstSet();
Begin
  if actFFFolder.Checked and actFFFiles.Checked and actFFHide.Checked then
    shlst.ObjectTypes := [otFolders, otNonFolders, otHidden]
  else if actFFFolder.Checked and actFFFiles.Checked then
    shlst.ObjectTypes := [otFolders, otNonFolders]
  else if actFFFolder.Checked and actFFHide.Checked then
    shlst.ObjectTypes := [otFolders, otHidden]
  else if actFFFiles.Checked and actFFHide.Checked then
    shlst.ObjectTypes := [otNonFolders, otHidden]
  else if actFFFolder.Checked then
    shlst.ObjectTypes := [otFolders]
  else if actFFFiles.Checked then
    shlst.ObjectTypes := [otNonFolders]
  else if actFFHide.Checked then
    shlst.ObjectTypes := [otHidden]
  else
    shlst.ObjectTypes := [];
end;

procedure TCnExploreForm.actFFFolderExecute(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Checked := not (Sender as TAction).Checked;
  ChangeShlstSet;
end;

procedure TCnExploreForm.actCreateDirExecute(Sender: TObject);
var
  aPath: string;
begin
  aPath := SCnNewFolderDefault;
  if CnWizInputQuery(SCnNewFolder, SCnNewFolderHint, aPath) then
  begin
    if aPath <> '' then
    begin
      aPath := MakePath(shltv.Path) + aPath;
      if not ForceDirectories(aPath) then
        ErrorDlg(SCnUnableToCreateFolder)
      else
        shltv.Refresh(shltv.Selected);
    end;
  end;
end;

procedure TCnExplorerWizard.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Value <> Old then
  begin
    if Value then
    begin
{$IFDEF DELPHI_OTA}
      IdeDockManager.RegisterDockableForm(TCnExploreForm, CnExploreForm,
        csCnExploreForm);
{$ENDIF}
    end
    else
    begin
{$IFDEF DELPHI_OTA}
      IdeDockManager.UnRegisterDockableForm(CnExploreForm, csCnExploreForm);
{$ENDIF}
      FreeAndNil(CnExploreForm);
    end;
  end;
end;

function TCnExplorerWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '��Դ,�ļ�,file,resource,explorer,';
end;

initialization
  RegisterCnWizard(TCnExplorerWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}
end.

