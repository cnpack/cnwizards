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

unit CnWizManager;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizardMgr ר�ҹ�����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�ԪΪ CnWizards ��ܵ�һ���֣������� CnWizardMgr ר�ҹ�������
*           ��Ԫʵ����ר�� DLL ����ڵ�������������ר�ҹ�����ʼ�����е�ר�ҡ�
*
*           ע��ר����ʵ��������˳���� Create LoadSettings SetActive
*           �������� Create ʱ��ʼ����׼����LoadSettings ʱ�������õľ�̬���ݣ�
*           �� SetActive ʱʹ����Ч����Ч
*
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.05.19 V1.3 by liuxiao
*               ���� D6 ���ϰ汾��ע��������Ҽ��˵�ִ����Ļ���
*           2003.10.03 V1.2 by ����(QSoft)
*               ����ר����������
*           2003.08.02 V1.1
*               LiuXiao ���� WizardCanCreate ���ԡ�
*           2002.09.17 V1.0
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF IDE_INTEGRATE_CASTALIA}
  {$IFNDEF DELPHI101_BERLIN_UP}
    {$DEFINE CASTALIA_KEYMAPPING_CONFLICT_BUG}
  {$ENDIF}
{$ENDIF}

uses
  Windows, Messages, Classes, Graphics, Controls, Sysutils, Menus, ActnList,
  Forms, ImgList, ExtCtrls, IniFiles, Dialogs, Registry,  Contnrs,
  {$IFDEF LAZARUS} LCLProc, {$IFNDEF STAND_ALONE} IDECommands, {$ENDIF} {$ELSE}
  {$IFDEF DELPHI_OTA} ToolsAPI,  CnRestoreSystemMenu, CnWizIdeHooks,
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, DesignMenus,{$ELSE}
  DsgnIntf,{$ENDIF} {$ENDIF} {$ENDIF}
  CnWizClasses, CnWizConsts, CnWizMenuAction, CnWizUtils, CnWizIdeUtils
  {$IFNDEF CNWIZARDS_MINIMUM}, CnLangMgr {$ENDIF};

const
  BootShortCutKey = VK_LSHIFT; // ��ݼ�Ϊ �� Shift���û����������� Delphi ʱ
                               // ���¸ü�������ר����������

  // ���øı�ʱ֪ͨ��ȥ��֪ͨ����õĴ��Եĸı����ݣ�
  // ����ר��ʹ�ܡ�����/����༭��ʹ�ܡ�������
  CNWIZARDS_SETTING_WIZARDS_CHANGED            = 1;
  CNWIZARDS_SETTING_PROPERTY_EDITORS_CHANGED   = 2;
  CNWIZARDS_SETTING_COMPONENT_EDITORS_CHANGED  = 4;
  CNWIZARDS_SETTING_OTHERS_CHANGED             = 8;

const
  KEY_MAPPING_REG = '\Editor\Options\Known Editor Enhancements';

type

//==============================================================================
// TCnWizardMgr ��ר����
//==============================================================================

{ TCnWizardMgr }

  TCnWizardMgr = class{$IFDEF DELPHI_OTA}(TNotifierObject, IOTAWizard){$ENDIF}
  {* CnWizardMgr ר�ҹ������࣬����ά��ר���б�
     �벻Ҫֱ�Ӵ��������ʵ���������ʵ����ר�� DLL ע��ʱ�Զ���������ʹ��ȫ��
     ���� CnWizardMgr �����ʹ�����ʵ����}
  private
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF DELPHI_OTA}
    FRestoreSysMenu: TCnRestoreSystemMenu;
{$ENDIF}
{$ENDIF}
    FProductVersion: Integer;
    FMenu: TMenuItem;
    FToolsMenu: TMenuItem;
    FWizards: TList;              // ר��ʵ�����ֱ�������ĸ� List �У�������ͨר��
    FMenuWizards: TList;          // �˵�ר��
    FIDEEnhanceWizards: TList;    // ������չ��ר��
    FRepositoryWizards: TList;    // ģ����ר��
    FTipTimer: TTimer;
    FLaterLoadTimer: TTimer;
    FSepMenu: TMenuItem;
    FConfigAction: TCnWizMenuAction;
    FWizMultiLang: TCnMenuWizard;
    FWizAbout: TCnMenuWizard;
    FOffSet: array[0..3] of Integer;
    FSettingsLoaded: Boolean;
  {$IFDEF BDS}
    FSplashBmp: TBitmap;   // �������棬24x24
    FAboutBmp: TBitmap;    // IDE ���ڴ��ڣ�36x36
  {$ENDIF}
    procedure CalcProductVersion;
    procedure DoLaterLoad(Sender: TObject);
    procedure DoFreeLaterLoadTimer(Sender: TObject);

    procedure CreateIDEMenu;
    procedure InstallIDEMenu;
    procedure FreeMenu;
    procedure InstallWizards;
    procedure VersionFirstRunWizards;
    procedure FreeWizards;
    procedure CreateMiscMenu;
    procedure InstallMiscMenu;
    procedure EnsureNoParent(Menu: TMenuItem);
    procedure FreeMiscMenu;

    procedure RegisterPluginInfo;
    procedure InternalCreate;
    procedure InstallPropEditors;
    procedure InstallCompEditors;
    procedure SetTipShowing;
    procedure ShowTipofDay(Sender: TObject);
    procedure CheckIDEVersion;
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}
    procedure CheckKeyMappingEnhModulesSequence;
{$ENDIF}
{$ENDIF}
    function GetWizards(Index: Integer): TCnBaseWizard;
    function GetWizardCount: Integer;
    function GetMenuWizardCount: Integer;
    function GetMenuWizards(Index: Integer): TCnMenuWizard;
    function GetRepositoryWizardCount: Integer;
    function GetRepositoryWizards(Index: Integer): TCnRepositoryWizard;
    procedure OnConfig(Sender: TObject);
    procedure OnIdleLoaded(Sender: TObject);
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    function GetIDEEnhanceWizardCount: Integer;
    function GetIDEEnhanceWizards(Index: Integer): TCnIDEEnhanceWizard;
    function GetWizardCanCreate(WizardClassName: string): Boolean;
    procedure SetWizardCanCreate(WizardClassName: string;
      const Value: Boolean);
    function GetOffSet(Index: Integer): Integer;
    function GetProductVersion: Integer;
  public
    constructor Create;
    {* �๹����}
    destructor Destroy; override;
    {* ��������}

    // IOTAWizard methods
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;

    procedure LoadSettings;
    {* װ������ר�ҵ�����}
    procedure SaveSettings;
    {* ��������ר�ҵ�����}
    procedure ConstructSortedMenu;
    {* �ؽ������Ĳ˵� }
    procedure UpdateMenuPos(UseToolsMenu: Boolean);
    {* �����������˵���λ�ã��ж������˵������� Tools �� }
    procedure RefreshLanguage;
    {* ���¶���ר�ҵĸ��������ַ��������� Action ���� }
    procedure ChangeWizardLanguage;
    {* ����ר�ҵ����Ըı��¼�������ר�ҵ����� }
    function WizardByName(const WizardName: string): TCnBaseWizard;
    {* ����ר�����Ʒ���ר��ʵ��������Ҳ���ר�ң�����Ϊ nil}
    function WizardByClass(AClass: TCnWizardClass): TCnBaseWizard;
    {* ����ר����������ר��ʵ��������Ҳ���ר�ң�����Ϊ nil}
    function WizardByClassName(const AClassName: string): TCnBaseWizard;
    {* ����ר�������ַ�������ר��ʵ��������Ҳ���ר�ң�����Ϊ nil}
    function ImageIndexByClassName(const AClassName: string): Integer;
    {* ����ר�������ַ�������ר�ҵ�ͼ������������Ҳ���ר�һ���ͼ������������Ϊ -1}
    function ActionByWizardClassNameAndCommand(const AClassName: string;
      const ACommand: string): TCnWizAction;
    {* ����ר�������ַ����������ַ��ظ��Ӳ˵�ר�ҵ�ָ���� Action�����򷵻� nil}
    function ImageIndexByWizardClassNameAndCommand(const AClassName: string;
      const ACommand: string): Integer;
    {* ����ר�������ַ����������ַ��ظ��Ӳ˵�ר�ҵ�ָ���� Action �� ImageIndex�����򷵻� -1}
    function IndexOf(Wizard: TCnBaseWizard): Integer;
    {* ����ר��ʵ����������ר���б��е�������}
    procedure DispatchDebugComand(Cmd: string; Results: TStrings);
    {* �ַ����� Debug ����������������� Results �У����ڲ�������}
    property Menu: TMenuItem read FMenu;
    {* ���뵽 IDE ���˵��еĲ˵���}
    property WizardCount: Integer read GetWizardCount;
    {* TCnBaseWizard ��������ר�ҵ����������������е�ר��}
    property MenuWizardCount: Integer read GetMenuWizardCount;
    {* TCnMenuWizard �˵�ר�Ҽ������������}
    property IDEEnhanceWizardCount: Integer read GetIDEEnhanceWizardCount;
    {* TCnIDEEnhanceWizard ר�Ҽ������������}
    property RepositoryWizardCount: Integer read GetRepositoryWizardCount;
    {* TCnRepositoryWizard ģ����ר�Ҽ������������}
    property Wizards[Index: Integer]: TCnBaseWizard read GetWizards; default;
    {* ��װ��ר�����飬�����˹�����ά��������ר��}
    property MenuWizards[Index: Integer]: TCnMenuWizard read GetMenuWizards;
    {* �˵�ר�����飬������ TCnMenuWizard ��������ר��}
    property IDEEnhanceWizards[Index: Integer]: TCnIDEEnhanceWizard
      read GetIDEEnhanceWizards;
    {* IDE ������չר�����飬������ TCnIDEEnhanceWizard ��������ר��}
    property RepositoryWizards[Index: Integer]: TCnRepositoryWizard
      read GetRepositoryWizards;
    {* ģ����ר�����飬������ TCnRepositoryWizard ��������ר��}

    property WizardCanCreate[WizardClassName: string]: Boolean read GetWizardCanCreate
      write SetWizardCanCreate;
    {* ָ��ר���Ƿ񴴽� }
    property OffSet[Index: Integer]: Integer read GetOffSet;

    property ProductVersion: Integer read GetProductVersion;
    {* ��ר�Ұ������ְ汾�ţ����� 1.2.3 ��ͷ��� 123}
  end;

{$IFDEF DELPHI_OTA}
{$IFDEF COMPILER6_UP}

  TCnDesignSelectionManager = class(TBaseSelectionEditor, ISelectionEditor)
  {* ������Ҽ��˵�ִ����Ŀ������}
  public
    procedure ExecuteVerb(Index: Integer; const List: IDesignerSelections);
    function GetVerb(Index: Integer): string;
    function GetVerbCount: Integer;
    procedure PrepareItem(Index: Integer; const AItem: IMenuItem);
    procedure RequiresUnits(Proc: TGetStrProc);
  end;

{$ENDIF}
{$ENDIF}

var
  CnWizardMgr: TCnWizardMgr = nil;
  {* TCnWizardMgr ��ר��ʵ��}

  InitSplashProc: TProcedure = nil;
  {* ������洰��ͼƬ�����ݵ����ģ��}

procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
{* ע��һ��������Ҽ��˵���ִ�ж���ʵ����Ӧ����ר�Ҵ���ʱע��
  ע��˷������ú�Executor ���ɴ˴�ͳһ���������ͷţ������ⲿ�����ͷ���}

procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
{* ע��һ��������Ҽ��˵���ִ�ж���ʵ������һ��ʽ}

procedure UnRegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
{* ��ע��һ��������Ҽ��˵���ִ�ж���ʵ������ע��� Executor ���Զ��ͷ�}

procedure UnRegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
{* ��ע��һ��������Ҽ��˵���ִ�ж���ʵ������һ��ʽ����ע��� Executor ���Զ��ͷ�}

procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
{* ע��һ���༭���Ҽ��˵���ִ�ж���ʵ����Ӧ����ר�Ҵ���ʱע��}

procedure UnRegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
{* ��ע��һ���༭���Ҽ��˵���ִ�ж���ʵ������ע��� Executor ���Զ��ͷ�}

function GetEditorMenuExecutorCount: Integer;
{* ������ע��ı༭���Ҽ��˵���Ŀ���������༭����չʵ���Զ���༭���˵���}

function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
{* ������ע��ı༭���Ҽ��˵���Ŀ�����༭����չʵ���Զ���༭���˵���}

function GetCnWizardMgr: TCnWizardMgr;
{* ��װ�ķ��� TCnWizardMgr ��ר��ʵ���ĺ�������Ҫ���ű�ר��ʹ��}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizOptions, CnWizShortCut, CnCommon,
{$IFNDEF CNWIZARDS_MINIMUM}
  {$IFNDEF STAND_ALONE} CnDesignEditor, {$ENDIF}
  CnWizAbout, CnWizShareImages, CnWizMultiLang, CnWizBoot, CnWizTranslate, CnWizConfigFrm,
  CnWizUpgradeFrm, CnWizCommentFrm, CnWizTipOfDayFrm,
  {$IFNDEF LAZARUS}{$IFNDEF STAND_ALONE}
  CnIDEVersion,
  {$ENDIF}{$ENDIF}
{$ENDIF}
  CnWizNotifier, CnWizCompilerConst;

const
  csCnWizFreeMutex = 'CnWizFreeMutex';
  csMaxWaitFreeTick = 5000;

  SCN_DBG_CMD_SEARCH = 'search';
  SCN_DBG_CMD_DUMP = 'dump';
  SCN_DBG_CMD_OPTION = 'option';
  SCN_DBG_CMD_STATE = 'state';

var
  CnDesignExecutorList: TObjectList = nil; // ������Ҽ��˵�ִ�ж����б�

  CnEditorExecutorList: TObjectList = nil; // �༭���Ҽ��˵�ִ�ж����б�

// ��װ�ķ��� TCnWizardMgr ��ר��ʵ���ĺ�������Ҫ���ű�ר��ʹ��
function GetCnWizardMgr: TCnWizardMgr;
begin
  Result := CnWizardMgr;
end;

// ע��һ��������Ҽ��˵���ִ�ж���ʵ����Ӧ����ר�Ҵ���ʱע��
procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
begin
  Assert(CnDesignExecutorList <> nil, 'CnDesignExecutorList is nil!');
  if CnDesignExecutorList.IndexOf(Executor) < 0 then
    CnDesignExecutorList.Add(Executor);
end;

// ע��һ��������Ҽ��˵���ִ�ж���ʵ������һ��ʽ
procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  RegisterBaseDesignMenuExecutor(Executor);
end;

// ��ע��һ��������Ҽ��˵���ִ�ж���ʵ������ע��� Executor ���Զ��ͷ�
procedure UnRegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
begin
  Assert(CnDesignExecutorList <> nil, 'CnDesignExecutorList is nil!');
  CnDesignExecutorList.Remove(Executor);
end;

// ��ע��һ��������Ҽ��˵���ִ�ж���ʵ������һ��ʽ����ע��� Executor ���Զ��ͷ�
procedure UnRegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  UnRegisterBaseDesignMenuExecutor(Executor);
end;

// ע��һ���༭���Ҽ��˵���ִ�ж���ʵ����Ӧ����ר�Ҵ���ʱע��
procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  Assert(CnEditorExecutorList <> nil, 'CnEditorExecutorList is nil!');
  if CnEditorExecutorList.IndexOf(Executor) < 0 then
    CnEditorExecutorList.Add(Executor);
end;

// ��ע��һ���༭���Ҽ��˵���ִ�ж���ʵ������ע��� Executor ���Զ��ͷ�
procedure UnRegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  Assert(CnEditorExecutorList <> nil, 'CnEditorExecutorList is nil!');
  CnEditorExecutorList.Remove(Executor);
end;

// ������ע��ı༭���Ҽ��˵���Ŀ���������༭����չʵ���Զ���༭���˵���
function GetEditorMenuExecutorCount: Integer;
begin
  Result := CnEditorExecutorList.Count;
end;

// ������ע��ı༭���Ҽ��˵���Ŀ�����༭����չʵ���Զ���༭���˵���
function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
begin
  Result := TCnContextMenuExecutor(CnEditorExecutorList[Index]);
end;

//==============================================================================
// TCnWizardMgr ��ר����
//==============================================================================

{ TCnWizardMgr }

procedure TCnWizardMgr.InternalCreate;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('InternalCreate');
{$ENDIF}

  FWizards := TList.Create;
  FMenuWizards := TList.Create;
  FIDEEnhanceWizards := TList.Create;
  FRepositoryWizards := TList.Create;

{$IFNDEF CNWIZARDS_MINIMUM}
  dmCnSharedImages := TdmCnSharedImages.Create(nil);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate ShareImg Copy To IDE');
{$ENDIF}
  dmCnSharedImages.CopyToIDEMainImageList;
{$ENDIF}

{$IFNDEF LAZARUS}
{$IFDEF BDS}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate SpashBmp');
{$ENDIF}
  FSplashBmp := TBitmap.Create;
  CnWizLoadBitmap(FSplashBmp, SCnSplashBmp);
  FAboutBmp := TBitmap.Create;
  CnWizLoadBitmap(FAboutBmp, SCnAboutBmp);
{$ENDIF}
  RegisterPluginInfo;

{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate CheckIDEVersion');
{$ENDIF}
  CheckIDEVersion;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate CreateIDEMenu');
{$ENDIF}
{$ENDIF}
  CreateIDEMenu;

  // ��������ר��
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate InstallWizards');
{$ENDIF}
  InstallWizards;

  // ���ר�ҵİ汾��ʼ��
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate VersionFirstRunWizards');
{$ENDIF}
  VersionFirstRunWizards;

  // ��������ר�����ò������Ӳ˵�
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate LoadSettings');
{$ENDIF}
  LoadSettings;

  // ���������Ӳ˵����˵����������������
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate CreateMiscMenu');
{$ENDIF}
  CreateMiscMenu;

{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
{$IFNDEF CNWIZARDS_MINIMUM}
  // ר�Ҵ�����ϲ�����������Ϻ���ͼ�����Ӳ˵�ͼ��ű����� IDE �� ImageList �У�
  // ��ʱ���ƴ�ŵ� IDE ���� ImageList �в��ܱ�֤��©
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate ShareImg Copy Large To IDE');
{$ENDIF}
  dmCnSharedImages.CopyLargeIDEImageList;
{$ENDIF}
{$ENDIF}
{$ENDIF}

  // ������˵�����ٲ��뵽 IDE �У��Խ�� D7 �²˵�����Ҫ�����������������
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate InstallIDEMenu');
{$ENDIF}
  InstallIDEMenu;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate InstallPropEditors');
{$ENDIF}
  InstallPropEditors;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate InstallCompEditors');
{$ENDIF}
  InstallCompEditors;

{$IFNDEF CNWIZARDS_MINIMUM}
  // ��ˢ��������Ŀ�������Ըı�ʱ�Ĵ������ơ�
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil) then
  begin
    // ע�⣬���� Languages ��Ŀ���ڣ��ɱ��������жϡ���ǰ����������Ϊ -1
    RefreshLanguage;
    ChangeWizardLanguage;
{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
    CnDesignEditorMgr.LanguageChanged(CnLanguageManager);
{$ENDIF}
{$ENDIF}
  end;
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  // �ļ�֪ͨ
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);

  // IDE ������ɺ���� Loaded
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InternalCreate IdleLoaded');
{$ENDIF}
  CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdleLoaded);
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('InternalCreate');
{$ENDIF}
end;

// BDS ��ע������Ʒ��Ϣ
procedure TCnWizardMgr.RegisterPluginInfo;
{$IFDEF BDS}
var
  AboutSvcs: IOTAAboutBoxServices;
{$ENDIF}
begin
{$IFDEF BDS}
  if Assigned(SplashScreenServices) then
  begin
    SplashScreenServices.AddPluginBitmap(SCnWizardCaption, FSplashBmp.Handle);
  end;

  if QuerySvcs(BorlandIDEServices, IOTAAboutBoxServices, AboutSvcs) then
  begin
    AboutSvcs.AddPluginInfo(SCnWizardCaption, SCnWizardDesc, FAboutBmp.Handle,
      False, SCnWizardLicense);
  end;
{$ENDIF}
end;

procedure TCnWizardMgr.DoFreeLaterLoadTimer(Sender: TObject);
begin
  FreeAndNil(FLaterLoadTimer);
end;

procedure TCnWizardMgr.DoLaterLoad(Sender: TObject);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('DoLaterLoad');
{$ENDIF}

{$IFDEF DEBUG}
  {$IFDEF IDE_SUPPORT_HDPI}
    if Application.MainForm <> nil then
    begin
{$IFDEF FPC}
      CnDebugger.LogInteger(Screen.PixelsPerInch, 'Application Screen PPI: ');
{$ELSE}
      CnDebugger.LogInteger(Application.MainForm.CurrentPPI, 'Application MainForm PPI: ');
{$ENDIF}
    end;
  {$ENDIF}
{$ENDIF}

  FLaterLoadTimer.Enabled := False;
  for I := 0 to WizardCount - 1 do
  try
    Wizards[I].LaterLoaded;
  except
    DoHandleException('WizManager ' + Wizards[I].ClassName + '.OnLaterLoad');
  end;

{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoFreeLaterLoadTimer);
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('DoLaterLoad');
{$ENDIF}
end;

// �๹����
constructor TCnWizardMgr.Create;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizardMgr.Create');
{$ENDIF}
  inherited Create;

  // ��ר�ҿ����� Create �������������ܹ����� CnWizardMgr �е��������ԡ�
  CnWizardMgr := Self;
  CalcProductVersion;

{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  RegisterThemeClass;
{$ENDIF}  
{$ENDIF}
  WizOptions := TCnWizOptions.Create;
  // ������洰��
  if @InitSplashProc <> nil then
    InitSplashProc();

{$IFNDEF CNWIZARDS_MINIMUM}
  // ��ǰ��ʼ������
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnWizardMgr InitLanguage');
{$ENDIF}
  CreateLanguageManager;
  if CnLanguageManager <> nil then
    InitLangManager;

  CnTranslateConsts(nil);

{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}
  CheckKeyMappingEnhModulesSequence;
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnWizardMgr WizShortCutMgr.BeginUpdate');
{$ENDIF}
  WizShortCutMgr.BeginUpdate;
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  {$IFDEF DEBUG}
  CnDebugger.LogMsg('CnWizardMgr CnListBeginUpdate');
  {$ENDIF}
  CnListBeginUpdate;
{$ENDIF}
{$ENDIF}
{$ENDIF}

  try
    InternalCreate;
  finally
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('CnWizardMgr CnListEndUpdate');
  {$ENDIF}
    CnListEndUpdate;
{$ENDIF}
{$ENDIF}
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('CnWizardMgr WizShortCutMgr.EndUpdate');
  {$ENDIF}
    WizShortCutMgr.EndUpdate;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnWizardMgr ConstructSortedMenu');
{$ENDIF}
  ConstructSortedMenu;
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF DELPHI_OTA}
  FRestoreSysMenu := TCnRestoreSystemMenu.Create(nil);
{$ENDIF}
{$ENDIF}

  // Create LaterLoaded Timer
  FLaterLoadTimer := TTimer.Create(nil);
  FLaterLoadTimer.Enabled := False;
  FLaterLoadTimer.Interval := 2000;
  FLaterLoadTimer.OnTimer := DoLaterLoad;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.Create');
  CnDebugger.LogSeparator;
{$ENDIF}
end;

// ��������
destructor TCnWizardMgr.Destroy;
var
  hMutex: THandle;
begin
{$IFDEF DEBUG}
  CnDebugger.LogSeparator;
  CnDebugger.LogEnter('TCnWizardMgr.Destroy');
{$ENDIF}

  // ��ֹ��� IDE ʵ��ͬʱ�ͷ�ʱ�������ó�ͻ
  hMutex := CreateMutex(nil, False, csCnWizFreeMutex);
{$IFDEF DEBUG}
  if GetLastError = ERROR_ALREADY_EXISTS then
    CnDebugger.LogMsg('Waiting for another instance');
{$ENDIF}
  WaitForSingleObject(hMutex, csMaxWaitFreeTick);

  try
    // ��ֹ�����ж�ʱ������Ч������
    if FSettingsLoaded then
      SaveSettings;

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
    CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Destroy WizShortCutMgr BeginUpdate');
{$ENDIF}
    WizShortCutMgr.BeginUpdate;
    try
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Destroy FreeMiscMenu');
{$ENDIF}
      FreeMiscMenu;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Destroy FreeWizards');
{$ENDIF}
      FreeWizards;
    finally
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Destroy WizShortCutMgr EndUpdate');
{$ENDIF}
      WizShortCutMgr.EndUpdate;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Destroy FreeMenu');
{$ENDIF}
    FreeMenu;

{$IFNDEF CNWIZARDS_MINIMUM}
    FreeAndNil(dmCnSharedImages);
{$ENDIF}
  {$IFDEF BDS}
    FreeAndNil(FSplashBmp);
    FreeAndNil(FAboutBmp);
  {$ENDIF}

    FreeAndNil(FRepositoryWizards);
    FreeAndNil(FIDEEnhanceWizards);
    FreeAndNil(FMenuWizards);
    FreeAndNil(FWizards);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Destroy FreeWizActionMgr');
{$ENDIF}
    FreeWizActionMgr;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('Destroy FreeWizShortCutMgr');
{$ENDIF}
    FreeWizShortCutMgr;

    FreeAndNil(WizOptions);
    FreeAndNil(FLaterLoadTimer);
    FreeAndNil(FTipTimer);
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF DELPHI_OTA}
    FreeAndNil(FRestoreSysMenu);
{$ENDIF}
{$ENDIF}

    inherited Destroy;
  finally
    if hMutex <> 0 then
    begin
      ReleaseMutex(hMutex);
      CloseHandle(hMutex);
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.Destroy');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// ר��������ط���
//------------------------------------------------------------------------------

// ����ר�Ұ��˵���
procedure TCnWizardMgr.CreateIDEMenu;
begin
  FMenu := TMenuItem.Create(nil);
  Menu.Name := SCnWizardsMenuName;
  Menu.Caption := SCnWizardsMenuCaption;
{$IFDEF DELPHI}
  Menu.AutoHotkeys := maManual;
{$ENDIF}
end;

// ��װ IDE �˵���
procedure TCnWizardMgr.InstallIDEMenu;
var
  MainMenu: TMainMenu;
begin
  MainMenu := GetIDEMainMenu; // IDE ���˵�
  if MainMenu <> nil then
  begin
    FToolsMenu := GetIDEToolsMenu;

    if WizOptions.UseToolsMenu and Assigned(FToolsMenu) then
      FToolsMenu.Insert(0, Menu)
    else if Assigned(FToolsMenu) then // �²˵����� Tools �˵�����
      MainMenu.Items.Insert(MainMenu.Items.IndexOf(FToolsMenu) + 1, Menu)
    else
      MainMenu.Items.Add(Menu);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Install Menu Succeed');
  {$ENDIF}
  end;
end;

// ���¶���ר�ҵĸ��������ַ��������� Action ����
procedure TCnWizardMgr.RefreshLanguage;
var
  I: Integer;
begin
  if FConfigAction <> nil then
  begin
    FConfigAction.Caption := SCnWizConfigCaption;
    FConfigAction.Hint := SCnWizConfigHint;
  end;

  if FWizAbout <> nil then
    FWizAbout.RefreshAction;

  WizActionMgr.MoreAction.Caption := SCnMoreMenu;
  WizActionMgr.MoreAction.Hint := StripHotkey(SCnMoreMenu);

  for I := 0 to WizardCount - 1 do
  begin
    if Wizards[I] is TCnActionWizard then
      TCnActionWizard(Wizards[I]).RefreshAction;
  end;
end;

// ����ר�ҵ����Ըı��¼�����ר���Լ��������Ա仯
procedure TCnWizardMgr.ChangeWizardLanguage;
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
{$ENDIF}
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  for I := 0 to WizardCount - 1 do
    Wizards[I].LanguageChanged(CnLanguageManager);
{$ENDIF}
end;

// ���������˵���
procedure TCnWizardMgr.CreateMiscMenu;
begin
  FSepMenu := TMenuItem.Create(nil);
  FSepMenu.Caption := '-';
  FConfigAction := WizActionMgr.AddMenuAction(SCnWizConfigCommand, SCnWizConfigCaption,
    SCnWizConfigMenuName, 0, OnConfig, SCnWizConfigIcon, SCnWizConfigHint);

{$IFNDEF CNWIZARDS_MINIMUM}
  FWizMultiLang := TCnWizMultiLang.Create;
  FWizAbout := TCnWizAbout.Create;
{$ENDIF}
end;

// ���ݲ˵�ר���б�͸��˵����ؽ��˵���
procedure TCnWizardMgr.ConstructSortedMenu;
var
  List: TList;
  I: Integer;
begin
  if (FMenuWizards = nil) or (Menu = nil) then Exit;

  List := TList.Create;
  try
    for I := 0 to FMenuWizards.Count - 1 do
    begin
      List.Add(FMenuWizards.Items[I]);
      EnsureNoParent(TCnMenuWizard(FMenuWizards.Items[I]).Menu);
    end;

    for I := Menu.Count - 1 downto 0 do
      Menu.Delete(I);

    SortListByMenuOrder(List);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ConstructSortedMenu. Before Insert: %d', [Menu.Count]);
{$ENDIF}

    for I := 0 to List.Count - 1 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ConstructSortedMenu. Insert %s', [TCnMenuWizard(List.Items[I]).Menu.Caption]);
{$ENDIF}
      Menu.Add(TCnMenuWizard(List.Items[I]).Menu);
    end;

    InstallMiscMenu;
  finally
    List.Free;
  end;

  WizActionMgr.ArrangeMenuItems(Menu);
end;

procedure TCnWizardMgr.UpdateMenuPos(UseToolsMenu: Boolean);
var
  MainMenu: TMainMenu;
begin
  if FToolsMenu <> nil then
  begin
    MainMenu := GetIDEMainMenu;
    if MainMenu = nil then
      Exit;

    if UseToolsMenu then
    begin
      MainMenu.Items.Remove(FMenu);
      FToolsMenu.Insert(0, FMenu);
    end
    else
    begin
      FToolsMenu.Remove(FMenu);
      MainMenu.Items.Insert(FToolsMenu.MenuIndex + 1, FMenu);
    end;
  end;
end;

// ���� TCnIDEEnhanceWizard ר�Ҽ������������
function TCnWizardMgr.GetIDEEnhanceWizardCount: Integer;
begin
  Result := FIDEEnhanceWizards.Count;
end;

// ȡָ���� IDE ������չר��
function TCnWizardMgr.GetIDEEnhanceWizards(Index: Integer): TCnIDEEnhanceWizard;
begin
  if (Index >= 0) and (Index <= FIDEEnhanceWizards.Count - 1) then
    Result := TCnIDEEnhanceWizard(FIDEEnhanceWizards[Index])
  else
    Result := nil;
end;

// ����ר����������ר��ʵ��������Ҳ���ר�ң�����Ϊ nil
function TCnWizardMgr.WizardByClass(AClass: TCnWizardClass): TCnBaseWizard;
var
  I: Integer;
begin
  for I := 0 to WizardCount - 1 do
  begin
    if Wizards[I] is AClass then
    begin
      Result := Wizards[I];
      Exit;
    end;
  end;
  Result := nil;
end;

// ����ר�������ַ�������ר��ʵ��������Ҳ���ר�ң�����Ϊ nil
function TCnWizardMgr.WizardByClassName(const AClassName: string): TCnBaseWizard;
var
  I: Integer;
begin
  for I := 0 to WizardCount - 1 do
  begin
    if Wizards[I].ClassNameIs(AClassName) then
    begin
      Result := Wizards[I];
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnWizardMgr.ImageIndexByClassName(const AClassName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to WizardCount - 1 do
  begin
    if Wizards[I].ClassNameIs(AClassName) then
    begin
      if Wizards[I] is TCnActionWizard then
        Result := (Wizards[I] as TCnActionWizard).ImageIndex;
      Exit;
    end;
  end;
end;

function TCnWizardMgr.ActionByWizardClassNameAndCommand(const AClassName: string;
  const ACommand: string): TCnWizAction;
var
  ABase: TCnBaseWizard;
begin
  Result := nil;
  ABase := WizardByClassName(AClassName);
  if (ABase <> nil) and (ABase is TCnSubMenuWizard) then
    Result := (ABase as TCnSubMenuWizard).ActionByCommand(ACommand);
end;

function TCnWizardMgr.ImageIndexByWizardClassNameAndCommand(const AClassName: string;
  const ACommand: string): Integer;
var
  AnAction: TCnWizAction;
begin
  Result := -1;
  AnAction := ActionByWizardClassNameAndCommand(AClassName, ACommand);
  if AnAction <> nil then
    Result := AnAction.ImageIndex;
end;

// ����ר��ʵ����������ר���б��е�������
function TCnWizardMgr.IndexOf(Wizard: TCnBaseWizard): Integer;
var
  I: Integer;
begin
  for I := 0 to WizardCount - 1 do
  begin
    if Wizards[I] = Wizard then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

// ����ר�����Ʒ���ר��ʵ��������Ҳ���ר�ң�����Ϊ nil
function TCnWizardMgr.WizardByName(const WizardName: string): TCnBaseWizard;
var
  I: Integer;
begin
  for I := 0 to WizardCount - 1 do
  begin
    if SameText(Wizards[I].WizardName, WizardName) then
    begin
      Result := Wizards[I];
      Exit;
    end;
  end;
  Result := nil;
end;

// �ͷŲ˵���
procedure TCnWizardMgr.FreeMenu;
begin
  if Menu <> nil then
  begin
    while Menu.Count > 0 do
      Menu[0].Free;
    FreeAndNil(FMenu);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Free menu succeed');
{$ENDIF}
  end;
end;

// ��װר���б�
procedure TCnWizardMgr.InstallWizards;
var
  I: Integer;
  Wizard: TCnBaseWizard;
  MenuWizard: TCnMenuWizard;
  IDEEnhanceWizard: TCnIDEEnhanceWizard;
  RepositoryWizard: TCnRepositoryWizard;
{$IFDEF DELPHI_OTA}
  WizardSvcs: IOTAWizardServices;
{$ENDIF}
{$IFNDEF CNWIZARDS_MINIMUM}
  FrmBoot: TCnWizBootForm;
  KeyState: TKeyboardState;
{$ENDIF}
  UserBoot: Boolean;
  BootList: array of Boolean;
begin
{$IFDEF DELPHI_OTA}
  if not QuerySvcs(BorlandIDEServices, IOTAWizardServices, WizardSvcs) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('Query IOTAWizardServices Fail', cmtError);
  {$ENDIF}
    Exit;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Adjust Wizards Class Order');
{$ENDIF}
  AdjustCnWizardsClassOrder;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin Installing Wizards');
{$ENDIF}

  UserBoot := False;

{$IFNDEF CNWIZARDS_MINIMUM}
  GetKeyboardState(KeyState);

  if (KeyState[BootShortCutKey] and $80 <> 0) or // �Ƿ����û�����ר��
    FindCmdLineSwitch(SCnShowBootFormSwitch, ['/', '-'], True) then
  begin
    FrmBoot := TCnWizBootForm.Create(Application);
    try
      if FrmBoot.ShowModal = mrOK then
      begin
        UserBoot := True;
        SetLength(BootList, GetCnWizardClassCount);
        FrmBoot.GetBootList(BootList);
      end;
    finally
      FrmBoot.Free;
    end;
  end;
{$ENDIF}

  for I := 0 to GetCnWizardClassCount - 1 do
  begin
    if ((not UserBoot) and WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(I)).ClassName]) or
       (UserBoot and BootList[I]) then
    begin
      try
        Wizard := TCnWizardClass(GetCnWizardClassByIndex(I)).Create;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard Created: ' + Wizard.ClassName);
{$ENDIF}
      except
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard Create Fail: ' +
          TCnWizardClass(GetCnWizardClassByIndex(I)).ClassName);
{$ENDIF}
        Wizard := nil;
      end;

      if Wizard = nil then
        Continue;

      if Wizard is TCnRepositoryWizard then
      begin
        RepositoryWizard := TCnRepositoryWizard(Wizard);
        FRepositoryWizards.Add(RepositoryWizard);
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
        // TODO: ע�� Lazarus �µ� Repository ר��
{$ELSE}
        RepositoryWizard.WizardIndex := WizardSvcs.AddWizard(RepositoryWizard);
{$ENDIF}
{$ENDIF}
      end
      else if Wizard is TCnMenuWizard then // �˵���ר��
      begin
        MenuWizard := TCnMenuWizard(Wizard);
        FMenuWizards.Add(MenuWizard);
      end
      else if Wizard is TCnIDEEnhanceWizard then  // IDE ������չר��
      begin
        IDEEnhanceWizard := TCnIDEEnhanceWizard(Wizard);
        FIDEEnhanceWizards.Add(IDEEnhanceWizard);
      end
      else
        FWizards.Add(Wizard);

{$IFDEF DEBUG}
      CnDebugger.LogFmt('Wizard [%d] Installed: %s', [I, Wizard.ClassName]);
{$ENDIF}
    end;
  end;

  // ��ʼ��ƫ����
  FOffSet[0] := FWizards.Count;
  FOffSet[1] := FOffSet[0] + FMenuWizards.Count;
  FOffSet[2] := FOffSet[1] + FIDEEnhanceWizards.Count;
  FOffSet[3] := FOffSet[2] + FRepositoryWizards.Count;
  if UserBoot then
    SetLength(BootList, 0);
end;

procedure TCnWizardMgr.VersionFirstRunWizards;
var
  I, V: Integer;
  Wizard: TCnBaseWizard;
begin
  for I := 0 to WizardCount - 1 do
  begin
    Wizard := Wizards[I];

    // ���ע����ڣ�������Ӧ��ֵ�Ƿ��Ǳ��汾�ţ�������ִ�в���ע����ڵİ汾��
    V := WizOptions.ReadInteger(SCnVersionFirstRun, Wizard.ClassName, 0);
    if V <> CnWizardMgr.ProductVersion then
    begin
      try
        Wizard.VersionFirstRun;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard VersionFirstRun: ' + Wizard.ClassName);
{$ENDIF}
      except
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard VersionFirstRun Exception: ' + Wizard.ClassName);
{$ENDIF}
      end;
      // ֻҪִ���ˣ������Ƿ����д���汾�ţ��´β���ִ��
      WizOptions.WriteInteger(SCnVersionFirstRun, Wizard.ClassName, CnWizardMgr.ProductVersion);
    end;
  end;
end;  

function TCnWizardMgr.GetOffSet(Index: Integer): Integer;
begin
  Result := FOffSet[Index];
end;

// �ͷ�ר���б�
procedure TCnWizardMgr.FreeWizards;
{$IFDEF DELPHI_OTA}
var
  WizardSvcs: IOTAWizardServices;
{$ENDIF}
begin
{$IFDEF DELPHI_OTA}
  if not QuerySvcs(BorlandIDEServices, IOTAWizardServices, WizardSvcs) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('Query IOTAWizardServices Error', cmtError);
{$ENDIF}
    Exit;
  end;
{$ENDIF}

  if FWizards <> nil then
  begin
    while FWizards.Count > 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg(TCnBaseWizard(FWizards[0]).ClassName + '.Free');
{$ENDIF}
      try
        try
          TCnBaseWizard(FWizards[0]).Free;
        finally
          FWizards.Delete(0);
        end;
      except
        Continue;
      end;
    end;
  end;

  if FMenuWizards <> nil then
  begin
    while FMenuWizards.Count > 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg(TCnMenuWizard(FMenuWizards[0]).ClassName + '.Free');
{$ENDIF}
      try
        try
          TCnMenuWizard(FMenuWizards[0]).Free;
        finally
          FMenuWizards.Delete(0);
        end;
      except
        Continue;
      end;
    end;
  end;

  if FIDEEnhanceWizards <> nil then
  begin
    while FIDEEnhanceWizards.Count > 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg(TCnIDEEnhanceWizard(FIDEEnhanceWizards[0]).ClassName + '.Free');
{$ENDIF}
      try
        try
          TCnIDEEnhanceWizard(FIDEEnhanceWizards[0]).Free;
        finally
          FIDEEnhanceWizards.Delete(0);
        end;
      except
        Continue;
      end;
    end;
  end;

  if FRepositoryWizards <> nil then
  begin
    while FRepositoryWizards.Count > 0 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg(TCnRepositoryWizard(FRepositoryWizards[0]).ClassName + '.Free');
{$ENDIF}

{$IFNDEF DELPHI_OTA}
      TObject(FRepositoryWizards[0]).Free;
{$ELSE}
      // �Ƴ�ר�һ��Զ��ͷŵ�
      WizardSvcs.RemoveWizard(TCnRepositoryWizard(FRepositoryWizards[0]).WizardIndex);
{$ENDIF}
      FRepositoryWizards.Delete(0);
    end;
  end;
end;

// װ��ר������
procedure TCnWizardMgr.LoadSettings;
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizardMgr.LoadSettings');
{$ENDIF}
  with WizOptions.CreateRegIniFile do
  try
    // ���� MenuOrder
    for I := 0 to MenuWizardCount - 1 do
    begin
      MenuWizards[I].MenuOrder := ReadInteger(SCnMenuOrderSection,
        MenuWizards[I].GetIDStr, I);

      // �˴����� AcquireSubActions, �� TCnSubMenuWizard �� Create ʱ�пճ�ʼ��
      if MenuWizards[I] is TCnSubMenuWizard then
      begin
        (MenuWizards[I] as TCnSubMenuWizard).ClearSubActions;
{$IFDEF DEBUG}
         CnDebugger.LogFmt('%d %s to AcquireSubActions.', [I, MenuWizards[I].ClassName]);
{$ENDIF}
        (MenuWizards[I] as TCnSubMenuWizard).AcquireSubActions;
      end;
    end;

    // װ��ר�����ã���ȷ�������������ݺ�������ר�ҵĻ״̬
    for I := 0 to WizardCount - 1 do
    begin
      Wizards[I].DoLoadSettings;
      Wizards[I].Active := ReadBool(SCnActiveSection,
        Wizards[I].GetIDStr, Wizards[I].Active);
    end;
  finally
    Free;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.LoadSettings');
{$ENDIF}
end;

// ����ר������
procedure TCnWizardMgr.SaveSettings;
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizardMgr.SaveSettings');
{$ENDIF}

  with WizOptions.CreateRegIniFile do
  try
    for I := 0 to WizardCount - 1 do
    begin
      Wizards[I].DoSaveSettings;
      // ���� Active
      WriteBool(SCnActiveSection, Wizards[I].GetIDStr, Wizards[I].Active);
    end;

    // ���� MenuOrder
    for I := 0 to MenuWizardCount - 1 do
      WriteInteger(SCnMenuOrderSection, MenuWizards[I].GetIDStr,
        MenuWizards[I].MenuOrder);
  finally
    Free;
  end;

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.CompEditorRegPath) do
  try
    for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
    begin
      CnDesignEditorMgr.CompEditors[I].DoSaveSettings;
      with CnDesignEditorMgr.CompEditors[I] do
        WriteBool(SCnActiveSection, IDStr, Active);
    end;
  finally
    Free;
  end;

  with WizOptions.CreateRegIniFile(WizOptions.PropEditorRegPath) do
  try
    for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
    begin
      CnDesignEditorMgr.PropEditors[I].DoSaveSettings;
      with CnDesignEditorMgr.PropEditors[I] do
        WriteBool(SCnActiveSection, IDStr, Active);
    end;
  finally
    Free;
  end;
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.SaveSettings');
{$ENDIF}
end;

procedure TCnWizardMgr.EnsureNoParent(Menu: TMenuItem);
begin
  if (Menu <> nil) and (Menu.Parent <> nil) then
    Menu.Parent.Remove(Menu);
end;

// ��װ���������˵�
procedure TCnWizardMgr.InstallMiscMenu;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('Install Misc Menu Entered.');
{$ENDIF}
  if Menu.Count > 0 then
  begin
    EnsureNoParent(FSepMenu);
    Menu.Add(FSepMenu);
  end;

{$IFNDEF CNWIZARDS_MINIMUM}
  EnsureNoParent(FConfigAction.Menu);
  EnsureNoParent(FWizMultiLang.Menu);
  EnsureNoParent(FWizAbout.Menu);

  Menu.Add(FConfigAction.Menu);
  Menu.Add(FWizMultiLang.Menu);
  Menu.Add(FWizAbout.Menu);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('Install Misc Menu Leave Successed.');
{$ENDIF}
end;

// �ͷ����������˵�
procedure TCnWizardMgr.FreeMiscMenu;
begin
  WizActionMgr.DeleteAction(TCnWizAction(FConfigAction));
  FWizMultiLang.Free;
  FWizAbout.Free;
  FSepMenu.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Free Misc Menu Succeed');
{$ENDIF}
end;

// ��װ����༭��
procedure TCnWizardMgr.InstallCompEditors;
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin Installing Component Editors');
{$ENDIF}
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.CompEditorRegPath) do
  try
    for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
      with CnDesignEditorMgr.CompEditors[I] do
      begin
        Active := ReadBool(SCnActiveSection, IDStr, True);
{$IFDEF DEBUG}
        if Active then
          CnDebugger.LogMsg('Component Editors Installed: ' + IDStr);
{$ENDIF}
        DoLoadSettings;
      end;
  finally
    Free;
  end;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Installing Component Editors Succeed');
{$ENDIF}
end;

// ��װ���Ա༭��
procedure TCnWizardMgr.InstallPropEditors;
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin Installing Property Editors');
{$ENDIF}
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.PropEditorRegPath) do
  try
    for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
      with CnDesignEditorMgr.PropEditors[I] do
      begin
        Active := ReadBool(SCnActiveSection, IDStr, True);
{$IFDEF DEBUG}
        if Active then
          CnDebugger.LogMsg('Property Editors Installed: ' + IDStr);
{$ENDIF}
        DoLoadSettings;
      end;
  finally
    Free;
  end;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Installing Property Editors Succeed');
{$ENDIF}
end;

// ����ÿ��һ������ʱ
procedure TCnWizardMgr.SetTipShowing;
begin
  FTipTimer := TTimer.Create(nil);
  FTipTimer.Interval := 8000;
  FTipTimer.OnTimer := ShowTipofDay;
end;

// ��ʾÿ��һ��
procedure TCnWizardMgr.ShowTipofDay(Sender: TObject);
begin
  FreeAndNil(FTipTimer);
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  ShowCnWizTipOfDayForm(False);
{$ENDIF}
{$ENDIF}
end;

// ��� IDE �汾����ʾ
procedure TCnWizardMgr.CheckIDEVersion;
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
var
  LatestUpdate: string;
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  if not IsIdeVersionLatest(LatestUpdate) then
  begin
    ShowSimpleCommentForm('', Format(SCnIDENOTLatest, [LatestUpdate]),
      SCnCheckIDEVersion + CompilerShortName);
  end;
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

// �ļ�֪ͨ
procedure TCnWizardMgr.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  // ����ʱ������Ч�������ڼ��ذ���������
  if NotifyCode = ofnPackageInstalled then
    WizOptions.DoFixThreadLocale;
end;

// IDE �������¼�
procedure TCnWizardMgr.OnIdleLoaded(Sender: TObject);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('OnIdleLoaded');
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  dmCnSharedImages.CopyLargeIDEImageList(True); // �ٸ���һ�δ�ߴ�ͼ��
{$ENDIF}
{$ENDIF}

  WizShortCutMgr.BeginUpdate;
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
  CnListBeginUpdate;
{$ENDIF}
{$ENDIF}
{$ENDIF}
  try
    for I := 0 to WizardCount - 1 do
    try
      Wizards[I].Loaded;
    except
      DoHandleException('WizManager ' + Wizards[I].ClassName + '.Loaded');
    end;

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
    // װ������༭������
    for I := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
    try
      CnDesignEditorMgr.CompEditors[I].Loaded;
    except
      DoHandleException('WizManager ' + CnDesignEditorMgr.CompEditors[I].IDStr + '.Loaded');
    end;

    // װ�����Ա༭������
    for I := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
    try
      CnDesignEditorMgr.PropEditors[I].Loaded;
    except
      DoHandleException('WizManager ' + CnDesignEditorMgr.PropEditors[I].IDStr + '.Loaded');
    end;
{$ENDIF}
{$ENDIF}

  finally
{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFNDEF LAZARUS}
    CnListEndUpdate;
{$ENDIF}
{$ENDIF}
{$ENDIF}
    WizShortCutMgr.UpdateBinding;   // IDE ������ǿ�����°�һ��
    WizShortCutMgr.EndUpdate;
  end;

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  // IDE ��������ע��༭���Ա�֤���ȼ����
  CnDesignEditorMgr.Register;
{$ENDIF}
{$ENDIF}

  // ȫ��װ��������������־
  FSettingsLoaded := True;

{$IFNDEF STAND_ALONE}
{$IFNDEF CNWIZARDS_MINIMUM}
  // �������
  if (WizOptions.UpgradeStyle = usAllUpgrade) or (WizOptions.UpgradeStyle =
    usUserDefine) and (WizOptions.UpgradeContent <> []) then
    CheckUpgrade(False);

  // ��ʾÿ��һ��
  SetTipShowing;
{$ENDIF}
{$ENDIF}

  FLaterLoadTimer.Enabled := True;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('OnIdleLoaded');
  CnDebugger.StopTimeMark('CWS'); // CnWizards Start-up Timing Stop
  CnDebugger.LogSeparator;
{$ENDIF}
end;

// ��ʾר�����öԻ���
procedure TCnWizardMgr.OnConfig(Sender: TObject);
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
{$ENDIF}
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  I := WizActionMgr.IndexOfCommand(SCnWizConfigCommand);
  if I >= 0 then
    ShowCnWizConfigForm(WizActionMgr.WizActions[I].Icon)
  else
    ShowCnWizConfigForm;
{$ENDIF}
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// ȡר������
function TCnWizardMgr.GetWizardCount: Integer;
begin
  Result := OffSet[3];
end;

// ȡָ��ר��
function TCnWizardMgr.GetWizards(Index: Integer): TCnBaseWizard;
begin
  if Index < 0 then
  begin
    Result := nil;
    Exit;
  end;
  // �������ͨר��
  if (Index <= OffSet[0] - 1) then
    Result := TCnBaseWizard(FWizards[Index])
  // ����ǲ˵�ר��
  else if (Index <= OffSet[1] - 1) then
    Result := TCnBaseWizard(FMenuWizards[Index - OffSet[0]])
  // ����� IDE ������չר��
  else if (Index <= OffSet[2] - 1) then
    Result := TCnBaseWizard(FIDEEnhanceWizards[Index - OffSet[1]])
  // �����Repositoryר��
  else if (Index <= OffSet[3] - 1) then
    Result := TCnBaseWizard(FRepositoryWizards[Index - OffSet[2]])
  else
    Result := nil;
end;

// ȡ�˵�ר������
function TCnWizardMgr.GetMenuWizardCount: Integer;
begin
  Result := FMenuWizards.Count;
end;

// ȡָ���˵�ר��
function TCnWizardMgr.GetMenuWizards(Index: Integer): TCnMenuWizard;
begin
  if (Index >= 0) and (Index <= FMenuWizards.Count - 1) then
    Result := TCnMenuWizard(FMenuWizards[Index])
  else
    Result := nil;
end;

// ȡ�ֿ�ר������
function TCnWizardMgr.GetRepositoryWizardCount: Integer;
begin
  Result := FRepositoryWizards.Count;
end;

// ȡָ���ֿ�ר��
function TCnWizardMgr.GetRepositoryWizards(
  Index: Integer): TCnRepositoryWizard;
begin
  if (Index >= 0) and (Index <= FRepositoryWizards.Count - 1) then
    Result := TCnRepositoryWizard(FRepositoryWizards[Index])
  else
    Result := nil;
end;

// ȡָ��ר���Ƿ񴴽�
function TCnWizardMgr.GetWizardCanCreate(WizardClassName: string): Boolean;
begin
  Result := WizOptions.ReadBool(SCnCreateSection, WizardClassName, True);
  WizOptions.WriteBool(SCnCreateSection, WizardClassName, Result);
end;

// дָ��ר���Ƿ񴴽�
procedure TCnWizardMgr.SetWizardCanCreate(WizardClassName: string;
  const Value: Boolean);
begin
  WizOptions.WriteBool(SCnCreateSection, WizardClassName, Value);
end;

// �ַ����� Debug ����������������� Results �У����ڲ�������
procedure TCnWizardMgr.DispatchDebugComand(Cmd: string; Results: TStrings);
var
  LocalCmd, ID: string;
  Cmds: TStrings;
  I: Integer;
  Wizard: TCnBaseWizard;
  Matched: Boolean;
begin
  if (Cmd = '') or (Results = nil) then
    Exit;
  Results.Clear;

  Cmds := TStringList.Create;
  try
    ExtractStrings([' '], [], PChar(Cmd), Cmds);
    if Cmds.Count = 0 then
      Exit;

    LocalCmd := LowerCase(Cmds[0]);
    Matched := False;
    Wizard := nil;
    for I := 0 to GetWizardCount - 1 do
    begin
      Wizard := GetWizards(I);
      ID := LowerCase(Wizard.GetIDStr);
      if Pos(LocalCmd, ID) > 0 then
      begin
        Matched := True;
        Break;
      end;
    end;

    if Matched and (Wizard <> nil) then
    begin
      Cmds.Delete(0);
      // �ȴ������ Wizard ��ͨ������
      if (Cmds.Count = 1) and (LowerCase(Cmds[0]) = SCN_DBG_CMD_SEARCH) then
        Results.Add(Wizard.GetSearchContent)
      else
        Wizard.DebugComand(Cmds, Results);
    end
    else
    begin
      // ����һЩ����Ե��� Wizard ��ȫ������
      if LowerCase(Cmds[0]) = SCN_DBG_CMD_DUMP then
      begin
        // ѭ����ӡÿ�� Wizard �Ļ�����Ϣ
        for I := 0 to GetWizardCount - 1 do
        begin
          Wizard := GetWizards(I);
          if Wizard <> nil then
          begin
            Results.Add('#' + IntToStr(I) + ':');
            GetCnWizardInfoStrs(Wizard, Results);
            Results.Add('');
          end;
        end;
      end
      else if LowerCase(Cmds[0]) = SCN_DBG_CMD_OPTION then
      begin
        WizOptions.DumpToStrings(Results);
        Results.Add('');
      end
      else if  LowerCase(Cmds[0]) = SCN_DBG_CMD_STATE then
      begin
        // ��ӡ�ڲ�״̬
        Results.Add('Loaded Icons: ' + IntToStr(CnLoadedIconCount));
        Results.Add('');
      end
      else  // No Wizard can process this debug command, do other stuff
        Results.Add('Unknown Debug Command ' + Cmd);
    end;
  finally
    Cmds.Free;
  end;
end;

//------------------------------------------------------------------------------
// ����ʵ�ֵ� IOTAWizard ����
//------------------------------------------------------------------------------

{ TCnWizardMgr.IOTAWizard }

// ר��ִ�з������շ�����
procedure TCnWizardMgr.Execute;
begin
  // do nothing
end;

// ȡר��ID
function TCnWizardMgr.GetIDString: string;
begin
  Result := SCnWizardMgrID;
end;

// ȡר����
function TCnWizardMgr.GetName: string;
begin
  Result := SCnWizardMgrName;
end;

procedure TCnWizardMgr.CalcProductVersion;
var
  V1, V2, V3, D: Integer;
  S, T: string;
begin
  try
    V1 := StrToInt(SCnWizardMajorVersion) * 100;
    V2 := 0;
    V3 := 0;
    S := SCnWizardMinorVersion;
    D := Pos('.', S);
    if D > 1 then
    begin
      T := Copy(S, 1, D - 1);
      V2 := StrToInt(T) * 10;
      Delete(S, 1, D);

      D := Pos('.', S);
      if D > 1 then
      begin
        T := Copy(S, 1, D - 1);
        V3 := StrToInt(T);
      end;
    end;

    FProductVersion := V1 + V2 + V3;
  except
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('No CnWizards Version Found: ' + SCnWizardVersion);
{$ENDIF}
  end;
end;

// ȡר�Ұ����ְ汾��
function TCnWizardMgr.GetProductVersion: Integer;

begin
  if FProductVersion = 0 then
    CalcProductVersion;

  Result := FProductVersion;
end;

// ����ר��״̬
function TCnWizardMgr.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}

procedure TCnWizardMgr.CheckKeyMappingEnhModulesSequence;
const
  PRIORITY_KEY = 'Priority';
  CASTALIA_KEYNAME = 'Castalia';
  CNPACK_KEYNAME = 'CnPack';
var
  List: TStringList;
  Reg: TRegistry;
  I, {MinIdx,} MaxIdx, CnPackIdx, MinValue, MaxValue: Integer;
  Contain: Boolean;
begin
  // ����ϻع�ѡ�˲�����ʾ������ʾ��
  if not WizOptions.ReadBool(SCnCommentSection, SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, True) then
    Exit;

  // XE8/10 Seattle �� IDE ���ɵ� Castalia �Ŀ�ݼ��� CnPack �г�ͻ��
  // ������ Castalia ���ִ��ڣ��� CnPack �� Priority �����������ʾ��
  List := TStringList.Create;
  try
    if GetKeysInRegistryKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG, List) then
    begin
      if List.Count <= 1 then
        Exit;

      // List �д���ÿ�� Key �����֣�Objects ��ͷ���� Priority ֵ
      for I := 0 to List.Count - 1 do
      begin
        List.Objects[I] := Pointer(-1);
        Reg := TRegistry.Create(KEY_READ);
        try
          if Reg.OpenKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG + '\' + List[I], False) then
          begin
            List.Objects[I] := Pointer(Reg.ReadInteger(PRIORITY_KEY));
          end;
        finally
          Reg.Free;
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Key Mapping: %s: Priority %d.', [List[I], Integer(List.Objects[I])]);
{$ENDIF}
      end;

      Contain := False;
      for I := 0 to List.Count - 1 do
      begin
        if Pos(CASTALIA_KEYNAME, List[I]) > 0 then
        begin
          Contain := True;
          Break;
        end;
      end;

      if not Contain then // ���û Castalia����ž�û��ͻ��������
        Exit;

      Contain := False;
      CnPackIdx := -1;
      for I := 0 to List.Count - 1 do
      begin
        if Pos(CNPACK_KEYNAME, List[I]) > 0 then
        begin
          Contain := True;
          CnPackIdx := I;
          Break;
        end;
      end;

{$IFNDEF CNWIZARDS_MINIMUM}
      if not Contain then // û CnPack ��ֵ�������ǵ�һ�����У�ֻ����ʾ
      begin
        ShowSimpleCommentForm('', Format(SCnKeyMappingConflictsHint, [WizOptions.CompilerRegPath + KEY_MAPPING_REG]),
          SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, False);
        Exit;
      end;
{$ENDIF}

      // Both exist, check the priority of CnPack
      // MinIdx := 0;
      MaxIdx := 0;
      MinValue := Integer(List.Objects[0]);
      MaxValue := Integer(List.Objects[0]);
      for I := 0 to List.Count - 1 do
      begin
        if Integer(List.Objects[I]) < MinValue then
        begin
          //MinIdx := I;
          MinValue := Integer(List.Objects[I]);
        end;

        if Integer(List.Objects[I]) > MaxValue then
        begin
          MaxIdx := I;
          MaxValue := Integer(List.Objects[I]);
        end;
      end;

      if MaxIdx = CnPackIdx then // CnPack ����ӳ��˳�����������档
        Exit;

{$IFNDEF CNWIZARDS_MINIMUM}
      ShowSimpleCommentForm('', Format(SCnKeyMappingConflictsHint, [WizOptions.CompilerRegPath + KEY_MAPPING_REG]),
        SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, False);
{$ENDIF}
    end;
  finally
    List.Free;
  end;
end;

{$ENDIF}
{$ENDIF}

{$IFDEF DELPHI_OTA}
{$IFDEF COMPILER6_UP}

//==============================================================================
// ������Ҽ��˵�ִ����Ŀ������
//==============================================================================

{ TCnDesignSelectionManager }

procedure TCnDesignSelectionManager.ExecuteVerb(Index: Integer;
  const List: IDesignerSelections);
begin
  TCnBaseMenuExecutor(CnDesignExecutorList[Index]).Execute;
end;

function TCnDesignSelectionManager.GetVerb(Index: Integer): string;
begin
  Result := TCnBaseMenuExecutor(CnDesignExecutorList[Index]).GetCaption;
end;

function TCnDesignSelectionManager.GetVerbCount: Integer;
begin
  Result := CnDesignExecutorList.Count;
end;

procedure TCnDesignSelectionManager.PrepareItem(Index: Integer;
  const AItem: IMenuItem);
var
  Executor: TCnBaseMenuExecutor;
begin
  Executor := TCnBaseMenuExecutor(CnDesignExecutorList[Index]);
  if (Executor <> nil) and ((Executor.Wizard = nil) or Executor.Wizard.Active) then
    Executor.Prepare;

  AItem.Visible := (Executor <> nil) and
    ((Executor.Wizard = nil) or Executor.Wizard.Active)
    and Executor.GetActive;

  if AItem.Visible then
    AItem.Enabled := Executor.GetEnabled;
end;

procedure TCnDesignSelectionManager.RequiresUnits(Proc: TGetStrProc);
begin

end;

{$ENDIF}
{$ENDIF}

initialization
  CnDesignExecutorList := TObjectList.Create(True);
  CnEditorExecutorList := TObjectList.Create(True);

{$IFNDEF STAND_ALONE}
{$IFDEF COMPILER6_UP}
  RegisterSelectionEditor(TComponent, TCnDesignSelectionManager);
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizManager.');
{$ENDIF}

finalization
  FreeAndNil(CnDesignExecutorList);
  FreeAndNil(CnEditorExecutorList);

end.

