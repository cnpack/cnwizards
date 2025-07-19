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

unit CnWizClasses;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards �����ඨ�嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�ԪΪ CnWizards ��ܵ�һ���֣�����������ר�ҵĻ����ࡣ
*           Ҫע��һ����ʵ�ֵ�ר�ң�����ʵ�ָ�ר�ҵĵ�Ԫ initialization �ڵ���
*           RegisterCnWizard ��ע��һ��ר�������á�
*         - TCnBaseWizard
*           ���� CnWizard ��ײ�ĳ�����ࡣ
*           - TCnIconWizard
*             ��ͼ��ĳ�����ࡣ
*             - TCnIDEEnhanceWizard
*               IDE ������չר�һ��ࡣ
*             - TCnActionWizard
*               �� IDE Action �ĳ�����࣬�������������п�ݼ���ר�ҡ�
*               - TCnMenuWizard
*                 ���˵��ĵĳ�����࣬������������ͨ���˵����õ�ר�ҡ�
*                 - TCnSubMenuWizard
*                   ���Ӳ˵���ĳ�����࣬������������ͨ���Ӳ˵�����õ�ר�ҡ�
*             - TCnRepositoryWizard
*               ���� Repository ר�һ��ࡣ
*               - TCnFormWizard
*                 �����������嵥Ԫ�ļ���ģ���򵼻��࣬���������� Pas ��Ԫ��
*               - TCnProjectWizard
*                 ��������Ӧ�ó��򹤳̵�ģ���򵼻��ࡣ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.05.19 V2.0
*               LiuXiao ����������Ҽ��˵�������ࡣ
*           2015.01.03 V1.9
*               LiuXiao ���� ResetSettings ���������������ء�
*           2004.06.01 V1.8
*               LiuXiao ���� TCnSubMenuWizard.OnPopup �������ڵ����˵��м����Ӳ˵���
*           2004.04.27 V1.7
*               beta �� TCnSubMenuWizard ������һ��������AddSubMenuWizard��
*               ����������Ӧ�ķ��������ṩ�Զ༶�Ӳ˵�ר�ҵ�֧�֡�
*           2003.12.12 V1.6
*               �� TCnUnitWizard ���� IOTAFormWizard �ӿڡ�
*           2003.06.22 V1.5
*               ���ӳ����� TCnIconWizard���Դ����ͼ���ר�ҡ�
*               ���ӻ����� TCnIDEEnhanceWizard���Դ��� IDE ������չ�����ࡣ
*           2003.05.02 V1.4
*               ʵ���� TCnSubMenuWizard.ShowShortCutDialog ����
*           2003.04.15 V1.3
*               �����Ӳ˵�ר�Ҳ����İ�ť״̬�����Զ����µ�����
*           2003.02.27 V1.2
*               Ϊ�Ӳ˵�ר�����ӹ�������ť֧�֣����ʱ����������
*           2002.10.26 V1.1
*               ���� CnSubMenuWizard ����
*           2002.09.17 V1.0
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Classes, Sysutils, Graphics, Menus, ActnList, IniFiles, Dialogs,
  {$IFDEF STAND_ALONE} {$IFDEF LAZARUS} LCLProc, {$ENDIF} {$ELSE}
  {$IFDEF LAZARUS} LCLProc, IDECommands, {$ELSE} ToolsAPI, {$ENDIF}
  {$ENDIF}
  Registry, ComCtrls, Forms, CnHashMap, CnWizShortCut, CnWizMenuAction,
  {$IFNDEF LAZARUS} CnPopupMenu, {$ENDIF} CnIni, CnWizIni, CnWizConsts;

type
  ECnWizardException = class(Exception);

{$IFDEF NO_DELPHI_OTA}
  TWizardState = set of (wsEnabled, wsChecked);

  TOTAFileNotification = (ofnFileOpening, ofnFileOpened, ofnFileClosing,
    ofnDefaultDesktopLoad, ofnDefaultDesktopSave, ofnProjectDesktopLoad,
    ofnProjectDesktopSave, ofnPackageInstalled, ofnPackageUninstalled);
{$ENDIF}

//==============================================================================
// ר�Ұ�ר�ҳ������
//==============================================================================

{ TCnBaseWizard }

{$M+}

  TCnBaseWizard = class{$IFNDEF NO_DELPHI_OTA}(TNotifierObject, IOTAWizard){$ENDIF}
  {* CnWizard ר�ҳ�����࣬������ר��������Ĺ������� }
  private
    FActive: Boolean;
    FWizardIndex: Integer;
    FDefaultsMap: TCnStrToVariantHashMap;
  protected
    procedure SetActive(Value: Boolean); virtual;
    {* Active ����д�������������ظ÷������� Active ���Ա���¼�
       ����ʱ�÷������� LoadSettings ֮����ã���ȷ�������������ݺ��ٱ���״̬ }
    function GetHasConfig: Boolean; virtual;
    {* HasConfig ���Զ��������������ظ÷��������Ƿ���ڿ��������� }
    function GetIcon: TIcon; virtual; abstract;
    {* Icon ���Զ��������������ظ÷������ط���ר��ͼ�꣬�û�ר��ͨ�������Լ����� }
    function GetBigIcon: TIcon; virtual; abstract;
    {* ��ߴ� Icon ���Զ��������������ظ÷������ط���ר��ͼ�꣬�û�ר��ͨ�������Լ����� }

    // IOTAWizard methods
    function GetIDString: string;
    function GetName: string; virtual;
  public
    constructor Create; virtual;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }
    class function WizardName: string;
    {* ȡר�����ƣ�������֧�ֱ��ػ����ַ��� }
    function GetAuthor: string; virtual;
    {* ��������}
    function GetComment: string; virtual;
    {* ����ע��}
    function GetSearchContent: string; virtual;
    {* ���ع��������ַ������������԰�Ƕ��ŷָ����Ӣ�Ĺؼ��ʣ���Ҫ��Сд}
    procedure DebugComand(Cmds: TStrings; Results: TStrings); virtual;
    {* ���� Debug ����������������� Results �У����ڲ�������}

    // IOTAWizard methods
    function GetState: TWizardState; virtual;
    {* ����ר��״̬��IOTAWizard �������������ظ÷�������ר��״̬ }
    procedure Execute; virtual; abstract;
    {* ר��ִ���巽����IOTAWizard ���󷽷����������ʵ�֡�
       ���û�ִ��һ��ר��ʱ�������ø÷����� }

    procedure Loaded; virtual;
    {* IDE ������ɺ���ø÷���}

    procedure LaterLoaded; virtual;
    {* IDE ������ɸ���һЩ����ø÷��������ڸ߰汾 IDE �д��� IDE �˵������̫�ٵĳ���}

    procedure VersionFirstRun; virtual;
    {* ���汾�ŵ�ר�ҵ�һ�δ���ʱ�����ã�����ʱ�����ڹ��캯��֮��ר�ҹ��������ã�������������
      �������ʹ�� CnWizardMgr.ProductVersion �õ���ǰ���ְ汾�ţ�ʹ��
      WizOptions.ReadInteger(SCnVersionFirstRun, Self.ClassName, 0) �õ���һ���ܵİ汾��
      �Խ��жԱȲ�������������������������°����õȡ�
      ע��õ��ò����� Delphi �汾��ֻ����ר�Ұ��汾��Ҳ����˵��ͬ�汾�� Delphi Ҳֻ�������е��Ǹ�����һ��}

    class function IsInternalWizard: Boolean; virtual;
    {* ��ר���Ƿ������ڲ�ר�ң�������ڲ������б�����ʾ�Ҳ������� }

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string);
      virtual; {$IFNDEF BCB}abstract;{$ENDIF BCB}
    {* ȡר����Ϣ�������ṩר�ҵ�˵���Ͱ�Ȩ��Ϣ�����󷽷����������ʵ�֡�
     |<PRE>
       var AName: string      - ר�����ƣ�������֧�ֱ��ػ����ַ���
       var Author: string     - ר�����ߣ�����ж�����ߣ��÷ֺŷָ�
       var Email: string      - ר���������䣬����ж�����ߣ��÷ֺŷָ�
       var Comment: string    - ר��˵����������֧�ֱ��ػ������з����ַ���
     |</PRE> }
    procedure Config; virtual;
    {* ר�����÷�������ר�ҹ�������ר�����ý����е��ã��� HasConfig Ϊ��ʱ��Ч }
    procedure LanguageChanged(Sender: TObject); virtual;
    {* ר���ڶ�������Է����ı��ʱ��Ĵ����������ش˹��̴��������ַ��� }
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* װ��ר�����÷������������ش˷����� INI �����ж�ȡר�Ҳ�����
       ע��˷���������ר��һ�����������б����ö�Σ������Ҫ��������
       ��ֹ�ظ����ص��¶������ݵ����⡣ }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* ����ר�����÷������������ش˷�����ר�Ҳ������浽 INI ������ }
    procedure ResetSettings(Ini: TCustomIniFile); virtual;
    {* ����ר�����÷������������� INI ����֮��ı��涯������Ҫ���ش˷��� }

    class function GetIDStr: string;
    {* ����ר��Ψһ��ʶ������������ʹ�� }
    function CreateIniFile(CompilerSection: Boolean = False): TCustomIniFile;
    {* ����һ�����ڴ�ȡר�����ò����� INI �����û�ʹ�ú����Լ��ͷ� }
    procedure DoLoadSettings;
    {* װ��ר������ }
    procedure DoSaveSettings;
    {* ����ר������ }
    procedure DoResetSettings;
    {* ����ר������}

    property Active: Boolean read FActive write SetActive;
    {* ��Ծ���ԣ�����ר�ҵ�ǰ�Ƿ���� }
    property HasConfig: Boolean read GetHasConfig;
    {* ��ʾר���Ƿ�������ý�������� }
    property WizardIndex: Integer read FWizardIndex write FWizardIndex;
    {* ר��ע����� IDE ���ص������ţ����ͷ�ר��ʱʹ�ã��벻Ҫ�޸ĸ�ֵ }
    property Icon: TIcon read GetIcon;
    {* ר��ͼ�����ԣ���С��������������� ActionWizard �������� 16x16���� IconWizard Ĭ�� 32x32 }
    property BigIcon: TIcon read GetBigIcon;
    {* ר�Ҵ�ͼ�꣬����еĻ�}
  end;

{$M-}

type
  TCnWizardClass = class of TCnBaseWizard;

//==============================================================================
// ��ͼ�����ԵĻ�����
//==============================================================================

{ TCnIconWizard }

  TCnIconWizard = class(TCnBaseWizard)
  {* IDE ��ͼ�����ԵĻ����� }
  private
    FIcon: TIcon;
  protected
    function GetIcon: TIcon; override;
    {* ���ظ���ר�ҵ�ͼ�꣬��������ش˹��̷��������� Icon ����
       FIcon ʹ��ϵͳĬ�ϳߴ磬һ���� 32 * 32 ��}
    function GetBigIcon: TIcon; override;
    {* ���ظ���ר�ҵĴ�ͼ�꣬32 * 32 ��}
    procedure InitIcon(AIcon, ASmallIcon: TIcon); virtual;
    {* ����������ʼ��ͼ�꣬���󴴽�ʱ���ã���������ش˹������´��� FIcon }
    class function GetIconName: string; virtual;
    {* ����ͼ���ļ��� }
  public
    constructor Create; override;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }
  end;

//==============================================================================
// IDE ������չ������
//==============================================================================

{ TCnIDEEnhanceWizard }

  TCnIDEEnhanceWizard = class(TCnIconWizard);
  {* IDE ������չ������ }

//==============================================================================
// �� Action �Ϳ�ݼ��ĳ���ר����
//==============================================================================

{ TCnActionWizard }

  TCnActionWizard = class(TCnIDEEnhanceWizard)
  {* �� Action �Ϳ�ݼ��� CnWizard ר�ҳ�����࣬�Ӹ�����Icon �� 16x16 }
  private
    FAction: TCnWizAction;
    function GetImageIndex: Integer;
  protected
    function GetIcon: TIcon; override;
    procedure OnActionUpdate(Sender: TObject); virtual;
    function CreateAction: TCnWizAction; virtual;
    procedure Click(Sender: TObject); virtual;
    function GetCaption: string; virtual; abstract;
    {* ����ר�ҵı��� }
    function GetHint: string; virtual;
    {* ����ר�ҵ� Hint ��ʾ }
    function GetDefShortCut: TShortCut; virtual;
    {* ����ר�ҵ�Ĭ�Ͽ�ݼ���ʵ��ʹ��ʱר�ҵĿ�ݼ�������ɹ��������趨������
       ֻ��Ҫ����Ĭ�ϵľ����ˡ� }
  public
    constructor Create; override;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }
    function GetSearchContent: string; override;
    {* ���ع��������ַ������ѱ����� Hint ����ȥ }
    property ImageIndex: Integer read GetImageIndex;
    {* ר��ͼ���� IDE ���� ImageList �е������� }
    property Action: TCnWizAction read FAction;
    {* ר�� Action ���� }
    function EnableShortCut: Boolean; virtual;
    {* ����ר���Ƿ�����ÿ�ݼ����� }
    procedure RefreshAction; virtual;
    {* ���¸��� Action ������ }
  end;

//==============================================================================
// ���˵��ĳ���ר����
//==============================================================================

{ TCnMenuWizard }

type
  TCnMenuWizard = class(TCnActionWizard)
  {* ���˵��� CnWizard ר�ҳ������ }
  private
    FMenuOrder: Integer;
    function GetAction: TCnWizMenuAction;
    function GetMenu: TMenuItem;
    procedure SetMenuOrder(const Value: Integer);
  protected
    function CreateAction: TCnWizAction; override;
  public
    constructor Create; override;

    function EnableShortCut: Boolean; override;
    {* ����ר���Ƿ�����ÿ�ݼ����� }
    property Menu: TMenuItem read GetMenu;
    {* ר�ҵĲ˵����� }
    property Action: TCnWizMenuAction read GetAction;
    {* ר�� Action ���� }
    property MenuOrder: Integer read FMenuOrder write SetMenuOrder;
    {* ר�ҵĲ˵�������� }
  end;

//==============================================================================
// ���Ӳ˵���ĳ���ר����
//==============================================================================

{ TCnSubMenuWizard }

  TCnSubMenuWizard = class(TCnMenuWizard)
  {* ���Ӳ˵���� CnWizard ר�ҳ������ }
  private
    FList: TList;
    FPopupMenu: TPopupMenu;
    FPopupAction: TCnWizAction; // ���ڷ��õ���������ʱ�����İ�ť��Ӧ�� Action������ Action ͼ���ظ�
    FExecuting: Boolean;
    FRefreshing: Boolean;
    procedure FreeSubMenus;
    procedure OnExecute(Sender: TObject);
    procedure OnUpdate(Sender: TObject);
    procedure OnPopup(Sender: TObject);
    function GetSubActions(Index: Integer): TCnWizMenuAction;
    function GetSubActionCount: Integer;
    function GetSubMenus(Index: Integer): TMenuItem;
  protected
    procedure SetActive(Value: Boolean); override;
    procedure OnActionUpdate(Sender: TObject); override;
    function CreateAction: TCnWizAction; override;
    procedure Click(Sender: TObject); override;
    function IndexOf(SubAction: TCnWizMenuAction): Integer;
    {* ����ָ���� Action ���б��е������� }
    function RegisterASubAction(const ACommand, ACaption: string;
      AShortCut: TShortCut = 0; const AHint: string = '';
      const AIconName: string = ''): Integer;
    {* ע��һ���� Action�����������š�
     |<PRE>
       ACommand: string         - Action �����֣�����Ϊһ��Ψһ���ַ���ֵ
       ACaption: string         - Action �ı���
       AShortCut: TShortCut     - Action ��Ĭ�Ͽ�ݼ���ʵ��ʹ�õļ�ֵ���ע����ж�ȡ
       AHint: string            - Action ����ʾ��Ϣ
       Result: Integer          - �����б��е�������
     |</PRE> }
    procedure AddSubMenuWizard(SubMenuWiz: TCnSubMenuWizard);
    {* Ϊ��ר�ҹҽ�һ���Ӳ˵�ר�� }
    procedure AddSepMenu;
    {* ����һ���ָ��˵� }
    procedure DeleteSubAction(Index: Integer);
    {* ɾ��ָ������ Action }

    function ShowShortCutDialog(const HelpStr: string): Boolean;
    {* ��ʾ�� Action ��ݼ����öԻ��� }

    procedure SubActionExecute(Index: Integer); virtual;
    {* �Ӳ˵���ִ�з���������Ϊ�Ӳ˵��������ţ�ר�������ظ÷������� Action ִ���¼� }
    procedure SubActionUpdate(Index: Integer); virtual;
    {* �Ӳ˵�����·���������Ϊ�Ӳ˵��������ţ�ר�������ظ÷������� Action ״̬ }
  public
    constructor Create; override;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }
    function GetSearchContent: string; override;
    {* ���ع��������ַ������������Ӳ˵��ı����� Hint ����ȥ }
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;
    {* ����ʱ��ӡ�Ӳ˵��Լ� Action �ȵ���Ϣ}
    procedure Execute; override;
    {* ִ����ʲô������ }
    function EnableShortCut: Boolean; override;
    {* �����Ƿ�����ÿ�ݼ����� False }
    procedure AcquireSubActions; virtual;
    {* �������ش˹��̣��ڲ����� RegisterASubAction �����Ӳ˵��
        �˹����ڶ����л�ʱ�ᱻ�ظ����á� }
    procedure ClearSubActions; virtual;
    {* ɾ�����е��� Action�������Ӳ˵��еķָ��� }
    procedure RefreshAction; override;
    {* ���ص�ˢ�� Action �ķ��������˼̳�ˢ�²˵����⣬��ˢ���Ӳ˵� Action }
    procedure RefreshSubActions; virtual;
    {* ���������� Action������������ش˷�������ֹ�� Action ���� }
    property SubActionCount: Integer read GetSubActionCount;
    {* ר���� Action ���� }
    property SubMenus[Index: Integer]: TMenuItem read GetSubMenus;
    {* ר�ҵ��Ӳ˵��������� }
    property SubActions[Index: Integer]: TCnWizMenuAction read GetSubActions;
    {* ר�ҵ��� Action �������� }
    function ActionByCommand(const ACommand: string): TCnWizAction;
    {* ����ָ�������ֲ����� Action�����򷵻� nil}
  end;

//==============================================================================
// ���� Repository ר�һ���
//==============================================================================

{ TCnRepositoryWizard }

  TCnRepositoryWizard = class(TCnIconWizard {$IFNDEF NO_DELPHI_OTA}, IOTARepositoryWizard {$ENDIF})
  {* CnWizard ģ���򵼳������ }
  protected
    FIconHandle: HICON;
    function GetName: string; override;
    {* ���� GetName ���������� WizardName ��Ϊ��ʾ���ַ�����  }
  public
    constructor Create; override;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }

    // IOTARepositoryWizard methods
    function GetPage: string;
{$IFDEF COMPILER6_UP}
  {$IFDEF WIN64}
    function GetGlyph: THandle;
  {$ELSE}
    function GetGlyph: Cardinal;
  {$ENDIF}
{$ELSE}
    function GetGlyph: HICON;
{$ENDIF}
  end;

//==============================================================================
// ��Ԫģ���򵼻���
//==============================================================================

{ TCnUnitWizard }

  TCnUnitWizard = class(TCnRepositoryWizard {$IFNDEF NO_DELPHI_OTA},
    {$IFDEF DELPHI10_UP}IOTAProjectWizard{$ELSE}IOTAFormWizard{$ENDIF} {$ENDIF});
  {* ����ʵ�� IOTAFormWizard ������ New �Ի����г���, BDS2006 ��Ҫ�� IOTAProjectWizard}

//==============================================================================
// ����ģ���򵼻���
//==============================================================================

{ TCnFormWizard }

  TCnFormWizard = class(TCnRepositoryWizard {$IFNDEF NO_DELPHI_OTA}, IOTAFormWizard {$ENDIF});

//==============================================================================
// ����ģ���򵼻���
//==============================================================================

{ TCnProjectWizard }

  TCnProjectWizard = class(TCnRepositoryWizard {$IFNDEF NO_DELPHI_OTA}, IOTAProjectWizard {$ENDIF});

//==============================================================================
// �������༭���Ҽ��˵�ִ����Ŀ�Ļ��࣬�����������Ӧ����ʵ�ֹ���
//==============================================================================

{ TCnBaseMenuExecutor }

  TCnBaseMenuExecutor = class(TObject)
  {* �������༭���Ҽ��˵�ִ����Ŀ�Ļ��࣬�ɴ�����ĳһר��ʵ��}
  private
    FTag: Integer;
    FWizard: TCnBaseWizard;
  public
    constructor Create(OwnWizard: TCnBaseWizard); virtual;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }

    function GetActive: Boolean; virtual;
    {* ������Ŀ�Ƿ���ʾ������˳���ŵ���}
    function GetCaption: string; virtual;
    {* ��Ŀ��ʾ�ı��⣬����˳���ŵ�һ}
    function GetHint: string; virtual;
    {* ��Ŀ����ʾ}
    function GetEnabled: Boolean; virtual;
    {* ������Ŀ�Ƿ�ʹ�ܣ�����˳���ŵ���}
    procedure Prepare; virtual;
    {* PrepareItem ʱ�����ã�����˳���ŵڶ�}
    function Execute: Boolean; virtual;
    {* ��Ŀִ�з���������Ĭ��ʲô������}

    property Wizard: TCnBaseWizard read FWizard;
    {* ���� Wizard ʵ��}
    property Tag: Integer read FTag write FTag;
    {* ��һ�� Tag}
  end;

//==============================================================================
// �������༭���Ҽ��˵�ִ����Ŀ����һ��ʽ�Ļ��࣬�����������¼���ָ��ִ�в���
//==============================================================================

{ TCnContextMenuExecutor }

  TCnContextMenuExecutor = class(TCnBaseMenuExecutor)
  {* �������༭���Ҽ��˵�ִ����Ŀ����һ��ʽ�Ļ��࣬�����������¼���ָ��ִ�в���}
  private
    FActive: Boolean;
    FEnabled: Boolean;
    FCaption: string;
    FHint: string;
    FOnExecute: TNotifyEvent;
  protected
    procedure DoExecute; virtual;
  public
    constructor Create; reintroduce; virtual;

    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;

    property Caption: string read FCaption write FCaption;
    {* ��Ŀ��ʾ�ı���}
    property Hint: string read FHint write FHint;
    {* ��Ŀ��ʾ����ʾ}
    property Active: Boolean read FActive write FActive;
    {* ������Ŀ�Ƿ���ʾ}
    property Enabled: Boolean read FEnabled write FEnabled;
    {* ������Ŀ�Ƿ�ʹ��}
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    {* ��Ŀִ�з�����ִ��ʱ����}
  end;

//==============================================================================
// ר�����б���ع���
//==============================================================================

procedure RegisterCnWizard(const AClass: TCnWizardClass);
{* ע��һ�� CnBaseWizard ר�������ã�ÿ��ר��ʵ�ֵ�ԪӦ�ڸõ�Ԫ�� initialization
   �ڵ��øù���ע��ר���� }

function GetCnWizardClass(const ClassName: string): TCnWizardClass;
{* ����ר������ȡָ����ר�������� }

function GetCnWizardClassCount: Integer;
{* ������ע���ר�������� }

function GetCnWizardClassByIndex(const Index: Integer): TCnWizardClass;
{* ����������ȡָ����ר�������� }

function GetCnWizardTypeNameFromClass(AClass: TClass): string;
{* ����ר������ȡר���������� }

function GetCnWizardTypeName(AWizard: TCnBaseWizard): string;
{* ����ר��ʵ����ȡָ����ר�������� }

procedure GetCnWizardInfoStrs(AWizard: TCnBaseWizard; Infos: TStrings);
{* ��ȡר��ʵ���������ַ����б�����Ϣ�����}

procedure AdjustCnWizardsClassOrder;
{* ��ר�ҹ���������ʱ������ע���ר����˳���Ա��Ż�����Ĳ˵�����˳��}

implementation

uses
  CnWizUtils, CnWizOptions, CnCommon, CnRegIni
{$IFNDEF CNWIZARDS_MINIMUM}, CnWizCommentFrm {$IFNDEF NO_DELPHI_OTA}
  , CnWizSubActionShortCutFrm
{$ENDIF}{$ENDIF}
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

//==============================================================================
// ר�����б���ع���
//==============================================================================

var
  CnWizardClassList: TList = nil; // ר���������б�

// ע��һ�� CnBaseWizard ר��������
procedure RegisterCnWizard(const AClass: TCnWizardClass);
begin
  Assert(CnWizardClassList <> nil, 'CnWizardClassList is nil!');
  if CnWizardClassList.IndexOf(AClass) < 0 then
    CnWizardClassList.Add(AClass);
end;

// ����ר������ȡָ����ר��������
function GetCnWizardClass(const ClassName: string): TCnWizardClass;
var
  I: Integer;
begin
  for I := 0 to CnWizardClassList.Count - 1 do
  begin
    Result := CnWizardClassList[I];
    if Result.ClassNameIs(ClassName) then
      Exit;
  end;
  Result := nil;
end;

// ������ע���ר��������
function GetCnWizardClassCount: Integer;
begin
  Result := CnWizardClassList.Count;
end;

// ����������ȡָ����ר��������
function GetCnWizardClassByIndex(const Index: Integer): TCnWizardClass;
begin
  Result := nil;
  if (Index >= 0) and (Index <= CnWizardClassList.Count - 1) then
    Result := CnWizardClassList[Index];
end;

// ����ר������ȡר����������
function GetCnWizardTypeNameFromClass(AClass: TClass): string;
begin
  if AClass.InheritsFrom(TCnProjectWizard) then
    Result := SCnProjectWizardName
  else if AClass.InheritsFrom(TCnFormWizard) then
    Result := SCnFormWizardName
  else if AClass.InheritsFrom(TCnUnitWizard) then
    Result := SCnUnitWizardName
  else if AClass.InheritsFrom(TCnRepositoryWizard) then
    Result := SCnRepositoryWizardName
  else if AClass.InheritsFrom(TCnSubMenuWizard) then
    Result := SCnSubMenuWizardName
  else if AClass.InheritsFrom(TCnMenuWizard) then
    Result := SCnMenuWizardName
  else if AClass.InheritsFrom(TCnActionWizard) then
    Result := SCnActionWizardName
  else if AClass.InheritsFrom(TCnIDEEnhanceWizard) then
    Result := SCnIDEEnhanceWizardName
  else
    Result := SCnBaseWizardName;
end;

// ����ר��ʵ����ȡָ����ר��������
function GetCnWizardTypeName(AWizard: TCnBaseWizard): string;
begin
  Result := GetCnWizardTypeNameFromClass(AWizard.ClassType);
end;

procedure GetCnWizardInfoStrs(AWizard: TCnBaseWizard; Infos: TStrings);
begin
  if (AWizard <> nil) and (Infos <> nil) then
  begin
    Infos.Add('ClassName: ' + AWizard.ClassName);
    Infos.Add('IDString: ' + AWizard.GetIDString);
    Infos.Add('WizardName: ' + AWizard.WizardName);
    Infos.Add('Comment: ' + AWizard.GetComment);

    if AWizard is TCnIconWizard then
    begin
      // ��ӡ Icon ��Ϣ������
    end;
    if AWizard is TCnActionWizard then
    begin
      Infos.Add('Action Caption: ' + (AWizard as TCnActionWizard).Action.Caption);
      Infos.Add('Action Hint: ' + (AWizard as TCnActionWizard).Action.Hint);
      Infos.Add('Action ImageIndex: ' + IntToStr((AWizard as TCnActionWizard).Action.ImageIndex));
      Infos.Add('Action ShortCut: ' + ShortCutToText((AWizard as TCnActionWizard).Action.ShortCut));
    end;
  end;
end;

procedure AdjustCnWizardsClassOrder;
var
  I: Integer;
  W: TCnWizardClass;
begin
  // ���빤�߼��ȸ�������
  for I := 0 to CnWizardClassList.Count - 1 do
  begin
    W := TCnWizardClass(CnWizardClassList[I]);
    if W.ClassNameIs('TCnCodingToolsetWizard') then
    begin
      CnWizardClassList.Delete(I);
      CnWizardClassList.Insert(0, W);
      Break;
    end;
  end;

  // �������ר�Ҹ������棬���±��빤�߼�
  for I := 0 to CnWizardClassList.Count - 1 do
  begin
    W := TCnWizardClass(CnWizardClassList[I]);
    if W.ClassNameIs('TCnDesignWizard') then
    begin
      CnWizardClassList.Delete(I);
      CnWizardClassList.Insert(0, W);
      Break;
    end;
  end;

  // AI ���������ȸ����
  for I := 0 to CnWizardClassList.Count - 1 do
  begin
    W := TCnWizardClass(CnWizardClassList[I]);
    if W.ClassNameIs('TCnAICoderWizard') then
    begin
      CnWizardClassList.Delete(I);
      CnWizardClassList.Add(W);
      Break;
    end;
  end;

  // �ű�ר�Ҹ���󣬼��� AI ��������
  for I := 0 to CnWizardClassList.Count - 1 do
  begin
    W := TCnWizardClass(CnWizardClassList[I]);
    if W.ClassNameIs('TCnScriptWizard') then
    begin
      CnWizardClassList.Delete(I);
      CnWizardClassList.Add(W);
      Break;
    end;
  end;
end;

//==============================================================================
// ר�Ұ�ר�һ�����
//==============================================================================

{ TCnBaseWizard }

// �๹����
constructor TCnBaseWizard.Create;
begin
  inherited Create;
  FWizardIndex := -1;
end;

// ��������
destructor TCnBaseWizard.Destroy;
begin
  FDefaultsMap.Free;
  inherited Destroy;
end;

{$IFDEF BCB}
class procedure TCnBaseWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin

end;
{$ENDIF BCB}

// ȡר������
class function TCnBaseWizard.WizardName: string;
var
  Author, Email, Comment: string;
begin
  GetWizardInfo(Result, Author, Email, Comment);
end;

// ����ר��Ψһ��ʶ������������ʹ��
class function TCnBaseWizard.GetIDStr: string;
begin
  Result := RemoveClassPrefix(ClassName);
end;

// ����ר������
function TCnBaseWizard.GetAuthor: string;
var
  Name, Email, Comment: string;
begin
  GetWizardInfo(Name, Result, Email, Comment);
end;

// ����ר��ע��
function TCnBaseWizard.GetComment: string;
var
  Name, Author, Email: string;
begin
  GetWizardInfo(Name, Author, Email, Result);
end;

// ���ع��������ַ������������԰�Ƕ��ŷָ����Ӣ�Ĺؼ��ʣ���Ҫ��Сд
function TCnBaseWizard.GetSearchContent: string;
begin
  Result := '';
end;

// ��ר���Ƿ������ڲ�ר�ң�����ʾ����������
class function TCnBaseWizard.IsInternalWizard: Boolean;
begin
  Result := False;
end;

// ���� Debug ����������������� Results �У����ڲ�������
procedure TCnBaseWizard.DebugComand(Cmds: TStrings; Results: TStrings);
begin
  if Results <> nil then
    Results.Add(ClassName + ' Debug Command Not Implemented.');
end;

//------------------------------------------------------------------------------
// �������÷���
//------------------------------------------------------------------------------

// ����һ�����ڴ�ȡר�����ò����� INI �����û�ʹ�ú����Լ��ͷ�
function TCnBaseWizard.CreateIniFile(CompilerSection: Boolean): TCustomIniFile;
var
  Path: string;
begin
  if FDefaultsMap = nil then
    FDefaultsMap := TCnStrToVariantHashMap.Create;

  if CompilerSection then
    Path := MakePath(MakePath(WizOptions.RegPath) + GetIDStr) + WizOptions.CompilerID
  else
    Path := MakePath(WizOptions.RegPath) + GetIDStr;

  Result := TCnWizIniFile.Create(Path, KEY_ALL_ACCESS, FDefaultsMap);
end;

procedure TCnBaseWizard.DoLoadSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Loading Settings: ' + ClassName);
{$ENDIF}
    try
      LoadSettings(Ini);
    except
      on E: Exception do
      begin
{$IFDEF NO_DELPHI_OTA}
        ShowMessage(Format('WizClasses %s LoadSettings Error. %s - %s',
          [ClassName, E.ClassName, E.Message]));
{$ELSE}
        DoHandleException(Format('WizClasses %s LoadSettings Error. %s - %s',
          [ClassName, E.ClassName, E.Message]));
{$ENDIF}
      end;
    end;
  finally
    Ini.Free;
  end;
end;

procedure TCnBaseWizard.DoSaveSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Saving Settings: ' + ClassName);
{$ENDIF}
    try
      SaveSettings(Ini);
    except
      on E: Exception do
      begin
{$IFDEF NO_DELPHI_OTA}
        ShowMessage(Format('WizClasses %s SaveSettings Error. %s - %s',
          [ClassName, E.ClassName, E.Message]));
{$ELSE}
        DoHandleException(Format('WizClasses %s SaveSettings Error. %s - %s',
          [ClassName, E.ClassName, E.Message]));
{$ENDIF}
      end;
    end;
  finally
    Ini.Free;
  end;
end;

procedure TCnBaseWizard.DoResetSettings;
var
  Ini: TCustomIniFile;
  List: TStrings;
  Reg: TRegistry;
begin
  Ini := CreateIniFile;
  List := TStringList.Create;
  try
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Reset Settings: ' + ClassName);
  {$ENDIF}

    if Ini is TCnRegistryIniFile then
    begin
      with (Ini as TCnRegistryIniFile).RegIniFile do
      begin
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Remove Registry Entry: ' + FileName);
  {$ENDIF}

        Reg := TRegistry.Create;
        try
          Reg.DeleteKey(FileName);
        finally
          Reg.Free;
        end;
      end;
    end;
    
    ResetSettings(Ini);

    DoLoadSettings; // ��������������ʹר��ʹ��Ĭ������
  finally
    Ini.Free;
    List.Free;
  end;
end;

procedure TCnBaseWizard.Config;
begin
  // ����ɶҲ����
end;

procedure TCnBaseWizard.LanguageChanged(Sender: TObject);
begin
  // ����ɶҲ����
end;

procedure TCnBaseWizard.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    ReadObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseWizard.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseWizard.ResetSettings(Ini: TCustomIniFile);
begin
// ����ɶҲ����
end;

procedure TCnBaseWizard.Loaded;
begin
  // ����ɶҲ����
end;

procedure TCnBaseWizard.LaterLoaded;
begin
  // ����ɶҲ����
end;

procedure TCnBaseWizard.VersionFirstRun;
begin
  // ����ɶҲ����
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// HasConfig ���Զ�����
function TCnBaseWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

// Active  ����д����
procedure TCnBaseWizard.SetActive(Value: Boolean);
begin
  FActive := Value;
{$IFDEF DEBUG}
  CnDebugger.LogMsg(ClassName + ' SetActive to ' + IntToStr(Integer(Value)));
{$ENDIF}
end;

//------------------------------------------------------------------------------
// ����ʵ�ֵ� IOTAWizard ����
//------------------------------------------------------------------------------

{ TCnBaseWizard.IOTAWizard }

function TCnBaseWizard.GetIDString: string;
begin
  Result := SCnWizardsNamePrefix + '.' + GetIDStr;
end;

function TCnBaseWizard.GetName: string;
begin
  Result := SCnWizardsNamePrefix + ' ' + GetIDStr;
end;

function TCnBaseWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

//==============================================================================
// ��ͼ�����ԵĻ�����
//==============================================================================

{ TCnIconWizard }

constructor TCnIconWizard.Create;
begin
  inherited;
  FActive := True;
  FIcon := TIcon.Create;
  InitIcon(FIcon, nil);
end;

destructor TCnIconWizard.Destroy;
begin
  inherited;
  FIcon.Free;
end;

// ���� Icon ���ԣ���ʹ������ͼ�꣬������
function TCnIconWizard.GetIcon: TIcon;
begin
  Result := FIcon;
end;

// ���ش� Icon ���ԣ�����������
function TCnIconWizard.GetBigIcon: TIcon;
begin
  Result := FIcon;
end;

// ����ͼ���ļ���
class function TCnIconWizard.GetIconName: string;
begin
  Result := ClassName;
end;

// ����������ʼ��ͼ�꣬������
procedure TCnIconWizard.InitIcon(AIcon, ASmallIcon: TIcon);
begin
{$IFNDEF NO_DELPHI_OTA}
  if AIcon <> nil then
    CnWizLoadIcon(AIcon, ASmallIcon, GetIconName, True);
{$ENDIF}
end;

//==============================================================================
// �� Action �Ϳ�ݼ��ĳ���ר����
//==============================================================================

{ TCnActionWizard }

// �๹����
constructor TCnActionWizard.Create;
begin
  inherited Create;
  FActive := True;
  FAction := CreateAction;
  FAction.OnUpdate := OnActionUpdate;
end;

// ��������
destructor TCnActionWizard.Destroy;
begin
  if Assigned(FAction) then
    WizActionMgr.DeleteAction(FAction);
  inherited Destroy;
end;

// ���¸��� Action ������
procedure TCnActionWizard.RefreshAction;
begin
  if FAction <> nil then
  begin
    FAction.Caption := GetCaption;
    FAction.Hint := GetHint;
  end;
end;

//------------------------------------------------------------------------------
// ���ⷽ��
//------------------------------------------------------------------------------

// Action ����¼�
procedure TCnActionWizard.Click(Sender: TObject);
begin
  try
    if Active and Action.Enabled and (IsInternalWizard or
      ShowCnWizCommentForm(Self)) then
      Execute;
  except
    on E: Exception do
    begin
{$IFDEF NO_DELPHI_OTA}
      ShowMessage(Format('WizClasses %s Click Error. %s - %s',
        [ClassName, E.ClassName, E.Message]));
{$ELSE}
      DoHandleException(Format('WizClasses %s Click Error. %s - %s',
        [ClassName, E.ClassName, E.Message]));
{$ENDIF}
    end;
  end;
end;

// ״̬�����¼�
procedure TCnActionWizard.OnActionUpdate(Sender: TObject);
var
  State: TWizardState;
begin
  State := GetState;
  FAction.Visible := FActive;
  FAction.Enabled := FActive and (wsEnabled in State);
  FAction.Checked := wsChecked in State;
  // ĳЩ����²�������ڿ�ݼ�������Ӳ˵��Ĳ˵���
  if not EnableShortCut then
    FAction.ShortCut := 0;
end;

// ���� Action
function TCnActionWizard.CreateAction: TCnWizAction;
begin
  Result := WizActionMgr.AddAction(GetIDStr, GetCaption, GetDefShortCut, Click,
    GetIconName, GetHint, True);
end;

// ȡĬ�Ͽ�ݼ�����
function TCnActionWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

// ȡר���Ƿ�����ÿ�ݼ�����
function TCnActionWizard.EnableShortCut: Boolean;
begin
  Result := True;
end;

// ȡ Hint ��ʾ����
function TCnActionWizard.GetHint: string;
begin
  Result := '';
end;

function TCnActionWizard.GetSearchContent: string;
begin
  Result := GetCaption + ',' + GetHint + ',';
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// Icon ���Զ�����
function TCnActionWizard.GetIcon: TIcon;
begin
  Assert(Assigned(FAction));
  Result := FAction.Icon;
end;

// ImageIndex ���Զ�����
function TCnActionWizard.GetImageIndex: Integer;
begin
  Assert(Assigned(FAction));
  Result := FAction.ImageIndex;
end;

//==============================================================================
// ���˵��ĳ���ר����
//==============================================================================

{ TCnMenuWizard }

// ���췽��
constructor TCnMenuWizard.Create;
begin
  inherited;
  FMenuOrder := -1;
end;

// ���� MenuOrder ����
procedure TCnMenuWizard.SetMenuOrder(const Value: Integer);
begin
  FMenuOrder := Value;
end;

// �������˵��� Action
function TCnMenuWizard.CreateAction: TCnWizAction;
begin
  Result := WizActionMgr.AddMenuAction(GetIDStr, GetCaption, GetIDStr, GetDefShortCut, Click,
    GetIconName, GetHint, True);
end;

// Action ���Զ�����
function TCnMenuWizard.GetAction: TCnWizMenuAction;
begin
  Assert(inherited Action is TCnWizMenuAction);
  Result := TCnWizMenuAction(inherited Action);
end;

// Menu ���Զ�����
function TCnMenuWizard.GetMenu: TMenuItem;
begin
  Assert(Assigned(Action));
  Result := Action.Menu;
end;

// �����Ƿ��п�ݼ�
function TCnMenuWizard.EnableShortCut: Boolean;
begin
  Result := (Menu = nil) or (Menu.Count = 0); // ���Ӳ˵���ʱ�������ÿ�ݼ�����
end;

//==============================================================================
// ���Ӳ˵���ĳ���ר����
//==============================================================================

{ TCnSubMenuWizard }

// �๹����
constructor TCnSubMenuWizard.Create;
{$IFNDEF NO_DELPHI_OTA}
var
  Svcs40: INTAServices40;
{$ENDIF}
begin
  inherited;
  FList := TList.Create;
  // ����ר�ұ��ŵ���������ʱ�������ť�����Ĳ˵�
  FPopupMenu := TPopupMenu.Create(nil);

{$IFNDEF NO_DELPHI_OTA}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  FPopupMenu.Images := Svcs40.ImageList;
{$ENDIF}

  // ���ڹ������������ϰ�ť�� Action��ͼ��Ӧ���� Action ͼ��һ����Ϊ�����ظ�����
  FPopupAction := WizActionMgr.AddAction(GetIDStr + '1', GetCaption, 0, OnPopup,
    '', GetHint);
  // �ȴ��յ�ͼ�������ٸ��� ImageIndex ֵ����ʡ������ SubMenuWizard �е�ÿһ�� Icon
  FPopupAction.ImageIndex := Action.ImageIndex;
  FPopupAction.OnUpdate := OnActionUpdate;
end;

// ��������
destructor TCnSubMenuWizard.Destroy;
begin
  ClearSubActions;
  FreeSubMenus;
  WizActionMgr.DeleteAction(FPopupAction);
  FPopupMenu.Free;
  FList.Free;
  inherited;
end;

function TCnSubMenuWizard.GetSearchContent: string;
var
  I: Integer;
  Act: TCnWizAction;
begin
  Result := inherited GetSearchContent;
  for I := 0 to SubActionCount - 1 do
  begin
    Act := SubActions[I];
    Result := Result + Act.Caption + ',' + Act.Hint + ',';
  end;
end;

procedure TCnSubMenuWizard.DebugComand(Cmds: TStrings; Results: TStrings);
var
  I: Integer;
  Act: TCnWizAction;
begin
  for I := 0 to SubActionCount - 1 do
  begin
    Act := SubActions[I];
    Results.Add(IntToStr(I) + '. ' + Act.Command + ': ' + Act.Caption);
  end;
end;

procedure TCnSubMenuWizard.AcquireSubActions;
begin
// ���಻����Ӳ˵���
end;

// ����ר�� Action ��
function TCnSubMenuWizard.CreateAction: TCnWizAction;
begin
  Result := inherited CreateAction;  // ���� Action ͼ��� FPopupAction �ظ�����Ӱ�첻��
  Assert(Result is TCnWizMenuAction);
  Result.ActionList := nil; // ��ֹ�� Action ���Զ�������ص� ToolBar ��
  TCnWizMenuAction(Result).Menu.ImageIndex := -1; // ���Ӳ˵������ʾλͼ
end;

// ִ����
procedure TCnSubMenuWizard.Execute;
begin
// ִ����ʲô������
end;

// �Ӳ˵�ר�Ҳ������ÿ�ݼ����ñ���
function TCnSubMenuWizard.EnableShortCut: Boolean;
begin
  Result := False;
end;

// ���Ӳ˵�ר����ˢ�� Action ��ʱ�����أ�˳����� Action Ҳˢ��һ�¡�
procedure TCnSubMenuWizard.RefreshAction;
begin
  inherited;
  // ˢ�����ڹ������������ϰ�ť�� Action
  FRefreshing := True;
  try
    if FPopupAction <> nil then
    begin
      FPopupAction.Caption := GetCaption;
      FPopupAction.Hint := GetHint;
    end;
    RefreshSubActions;
  finally
    FRefreshing := False;
  end;
end;

// ˢ���� Action ���类���أ��ɲ� inherited ����ֹ��ˢ�¡�
procedure TCnSubMenuWizard.RefreshSubActions;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg(ClassName + ' to RefreshSubActions.');
{$ENDIF}
  if FActive then
  begin
    AcquireSubActions;
    WizActionMgr.ArrangeMenuItems(Menu, 0, True);
  end
  else
    ClearSubActions;
end;

// �Ǽ�һ���� Action������������
function TCnSubMenuWizard.RegisterASubAction(const ACommand, ACaption: string;
  AShortCut: TShortCut; const AHint: string; const AIconName: string): Integer;
var
  NewAction: TCnWizMenuAction;
  IconName: string;
  I: Integer;
begin
  if AIconName = '' then
    IconName := ACommand
  else
    IconName := AIconName;

  if FRefreshing then
  begin
    for I := 0 to FList.Count - 1 do
    begin
      if TCnWizMenuAction(FList[I]).Command = ACommand then
      begin
        TCnWizMenuAction(FList[I]).Caption := ACaption;
        TCnWizMenuAction(FList[I]).Hint := AHint;
        Result := I;
        Exit;
      end;
    end;
  end;

  NewAction := WizActionMgr.AddMenuAction(ACommand, ACaption, ACommand, AShortCut,
    OnExecute, IconName, AHint);
  NewAction.OnUpdate := OnUpdate;
  Menu.Add(NewAction.Menu);
  Result := FList.Add(NewAction);
end;

// Ϊ��ר�ҹҽ�һ���Ӳ˵�ר�ң��������� Action ���б��е�������
procedure TCnSubMenuWizard.AddSubMenuWizard(SubMenuWiz: TCnSubMenuWizard);
begin
  // �����Ӳ˵�ר�ҵĲ˵����뱾ר�Ҳ˵�
  Menu.Add(SubMenuWiz.Action.Menu);
  // һ��Ҫ������Ӳ˵�ר�ҵ� Action���μ� ClearSubActions �е�˵��
  FList.Add(SubMenuWiz.Action);
end;

// ����һ���ָ��˵�
procedure TCnSubMenuWizard.AddSepMenu;
var
  SepMenu: TMenuItem;
begin
  if not FRefreshing then
  begin
    SepMenu := TMenuItem.Create(Menu);
    SepMenu.Caption := '-';
    Menu.Add(SepMenu);
  end;
end;

// ����� Action �б������Ӳ˵��еķָ���
procedure TCnSubMenuWizard.ClearSubActions;
var
  WizAction: TCnWizAction;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg(ClassName + ' to ClearSubActions.');
{$ENDIF}
  while FList.Count > 0 do
  begin
    WizAction := SubActions[0];
    // ����� Action �Ĳ˵����Ӳ˵���˵���� Action ��һ���Ӳ˵�ר�ҵ� Action��
    // ɾ���� Action �Ĺ���Ӧ���������������Ӳ˵�ר�ң��������������Ӳ˵�ר��
    // �뱾ר�Ҳ˵�֮��Ĺ�����������Ӳ˵�ר�ҵ� Menu.Parent ʼ�ղ�Ϊ nil���´�
    // �ٽ����Ӳ˵�ר�ҹ����κ�ר��ʱ������ֲ˵��ظ�������쳣�����ұ�������
    // �� Menu.Clear ��ɾ�����Ӳ˵�ר�ҵĲ˵������Ӳ˵�ר�����ͷ�ʱ��ͨ��ɾ����
    // �� Action ɾ�����Ӳ˵�ʱ�������Ӳ˵��ѱ�ɾ���������� AV �쳣��
    // LiuXiao: �Ӳ˵�ר�һ��ͷ��� Action�������ظ��ͷ������´���
    try
      if Assigned(WizAction) and (WizAction is TCnWizMenuAction) and
        (TCnWizMenuAction(WizAction).Menu.Count > 0) then
        Menu.Remove(TCnWizMenuAction(WizAction).Menu)
      else
        WizActionMgr.DeleteAction(WizAction);
    except
      ;
    end;
    FList.Delete(0);
  end;
  Menu.Clear; // ɾ���Ӳ˵��еķָ���
end;

// ɾ��һ���� Action
procedure TCnSubMenuWizard.DeleteSubAction(Index: Integer);
var
  WizAction: TCnWizAction;
begin
  if (Index >= 0) and (Index < FList.Count) then
  begin
    WizAction := SubActions[Index];
    // ����� Action �Ĳ˵����Ӳ˵���˵���� Action ��һ���Ӳ˵�ר�ҵ� Action��
    // ɾ���� Action �Ĺ���Ӧ���������������Ӳ˵�ר�ң��������������Ӳ˵�ר��
    // �뱾ר�Ҳ˵�֮��Ĺ�����������Ӳ˵�ר�ҵ� Menu.Parent ʼ�ղ�Ϊ nil���´�
    // �ٽ����Ӳ˵�ר�ҹ����κ�ר��ʱ������ֲ˵��ظ�������쳣��
    if Assigned(WizAction) and (WizAction is TCnWizMenuAction) and
      (TCnWizMenuAction(WizAction).Menu.Count > 0) then
      Menu.Remove(TCnWizMenuAction(WizAction).Menu)
    else
      WizActionMgr.DeleteAction(WizAction);
    FList.Delete(Index);
  end;
end;

// �ͷŲ˵���
procedure TCnSubMenuWizard.FreeSubMenus;
begin
  Menu.Clear;
end;

// ����ָ���� Action ���б��е�������
function TCnSubMenuWizard.IndexOf(SubAction: TCnWizMenuAction): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if SubActions[I] = SubAction then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TCnSubMenuWizard.ActionByCommand(const ACommand: string): TCnWizAction;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FList.Count - 1 do
  begin
    if SubActions[I].Command = ACommand then
    begin
      Result := SubActions[I];
      Exit;
    end;
  end;
end;

// ר�ҵ��÷���
procedure TCnSubMenuWizard.Click(Sender: TObject);
begin
  // ���̳е��ñ�����ʾ������ʾ�Ի���
end;

// Action ִ����
procedure TCnSubMenuWizard.OnExecute(Sender: TObject);
var
  I: Integer;
begin
  if not Active or FExecuting then
    Exit;

  FExecuting := True;
  try
    for I := 0 to FList.Count - 1 do
    begin
      if TObject(FList[I]) = Sender then
      begin
        // ��ֹͨ����ݼ�������Ч�Ĺ���
        SubActions[I].Update;
        if SubActions[I].Enabled then
        begin
          try
            // �ڲ�ר�Ҳ���ʾ
            if IsInternalWizard or ShowCnWizCommentForm(WizardName + ' - ' +
              GetCaptionOrgStr(SubActions[I].Caption), SubActions[I].Icon,
              SubActions[I].Command) then
              SubActionExecute(I);
          except
            on E: Exception do
            begin
{$IFDEF NO_DELPHI_OTA}
              ShowMessage(Format('WizClasses %s.SubActions[%d].Execute: %s - %s',
                [ClassName, I, E.ClassName, E.Message]));
{$ELSE}
              DoHandleException(Format('WizClasses %s.SubActions[%d].Execute: %s - %s',
                [ClassName, I, E.ClassName, E.Message]));
{$ENDIF}
            end;
          end;
        end;

        Exit;
      end;
    end;
  finally
    FExecuting := False;
  end;
end;

// Action ����
procedure TCnSubMenuWizard.OnUpdate(Sender: TObject);
var
  I: Integer;
begin
  OnActionUpdate(nil);
  for I := 0 to FList.Count - 1 do
  begin
    if TObject(FList[I]) = Sender then
    begin
      SubActionUpdate(I);
      Exit;
    end;
  end;
end;

// ��ʾ��ݼ����öԻ���
function TCnSubMenuWizard.ShowShortCutDialog(const HelpStr: string): Boolean;
begin
{$IFDEF NO_DELPHI_OTA}
  Result := False;
{$ELSE}
  {$IFNDEF CNWIZARDS_MINIMUM}
  Result := SubActionShortCutConfig(Self, HelpStr);
  {$ELSE}
  Result := False;
  {$ENDIF}
{$ENDIF}
end;

procedure TCnSubMenuWizard.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := FActive;
  inherited;             // ȷ�������Ƿ�ı䣬����Ҳ������
  if Old <> Value then
    RefreshSubActions;
end;

procedure TCnSubMenuWizard.OnActionUpdate(Sender: TObject);
begin
  inherited;
  FPopupAction.Visible := Action.Visible;
  FPopupAction.Enabled := Action.Enabled;
  FPopupAction.Checked := Action.Checked;
end;

procedure TCnSubMenuWizard.OnPopup(Sender: TObject);
var
  Point: TPoint;

  procedure AddMenuSubItems(SrcItem, DstItem: TMenuItem);
  var
    MenuItem, SubItem: TMenuItem;
    I, J: Integer;
  begin
    for I := 0 to SrcItem.Count - 1 do
    begin
      MenuItem := TMenuItem.Create(FPopupMenu);
      MenuItem.Action := SrcItem.Items[I].Action;
      if not Assigned(MenuItem.Action) then
        MenuItem.Caption := SrcItem.Items[I].Caption
      else if MenuItem.Action is TCnWizMenuAction then
      begin  // ��Ӷ����Ӳ˵�
        for J := 0 to TCnWizMenuAction(MenuItem.Action).Menu.Count - 1 do
        begin
          SubItem := TMenuItem.Create(FPopupMenu);
          SubItem.Action := TCnWizMenuAction(MenuItem.Action).Menu.Items[J].Action;
          if not Assigned(SubItem.Action) then
            SubItem.Caption := TCnWizMenuAction(MenuItem.Action).Menu.Items[J].Caption;
          MenuItem.Add(SubItem);
        end;
      end;
      AddMenuSubItems(SrcItem.Items[I], MenuItem);
      DstItem.Add(MenuItem);
    end;
  end;
begin
  FPopupMenu.Items.Clear;
  AddMenuSubItems(Menu, FPopupMenu.Items);
  GetCursorPos(Point);
  FPopupMenu.Popup(Point.x, Point.y);
end;

//------------------------------------------------------------------------------
// ���ⷽ��
//------------------------------------------------------------------------------

// �Ӳ˵���ִ�з���������Ϊ�Ӳ˵���������
procedure TCnSubMenuWizard.SubActionExecute(Index: Integer);
begin

end;

// �Ӳ˵�����·���������Ϊ�Ӳ˵���������
procedure TCnSubMenuWizard.SubActionUpdate(Index: Integer);
begin
  SubActions[Index].Visible := Active;
  SubActions[Index].Enabled := Active and Action.Enabled;
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// SubActionCount ���Զ�����
function TCnSubMenuWizard.GetSubActionCount: Integer;
begin
  Result := FList.Count;
end;

// SubActions ���Զ�����
function TCnSubMenuWizard.GetSubActions(Index: Integer): TCnWizMenuAction;
begin
  Result := nil;
  if (Index >= 0) and (Index < FList.Count) then
    Result := TCnWizMenuAction(FList[Index]);
end;

// SubMenus ���Զ�����
function TCnSubMenuWizard.GetSubMenus(Index: Integer): TMenuItem;
begin
  Result := nil;
  if (Index >= 0) and (Index < FList.Count) then
    Result := TCnWizMenuAction(FList[Index]).Menu; 
end;

//==============================================================================
// ����Repositoryר�һ���
//==============================================================================

{ TCnRepositoryWizard }

// ��������
constructor TCnRepositoryWizard.Create;
begin
  inherited;
  FIconHandle := 0;
end;

// ��������
destructor TCnRepositoryWizard.Destroy;
begin
  if FIcon <> nil then
    FreeAndNil(FIcon);
//  if FIconHandle <> 0 then    // �� IDE �ͷţ��˴�����Ҫ�ͷţ���л niaoge �ļ��
//    DestroyIcon(FIconHandle);
  inherited;
end;

// ���� GetName ���������� WizardName ��Ϊ��ʾ���ַ�����
function TCnRepositoryWizard.GetName: string;
begin
  Result := WizardName;
end;

//------------------------------------------------------------------------------
// ����ʵ�ֵ� IOTARepositoryWizard ����
//------------------------------------------------------------------------------

{ TCnRepositoryWizard.IOTARepositoryWizard }

// ����ͼ����
{$IFDEF COMPILER6_UP}
{$IFDEF WIN64}
function TCnRepositoryWizard.GetGlyph: THandle;
{$ELSE}
function TCnRepositoryWizard.GetGlyph: Cardinal;
{$ENDIF}
{$ELSE}
function TCnRepositoryWizard.GetGlyph: HICON;
{$ENDIF}
begin
  // IDE ��������������ͼ�꣬�����ʹ�� CopyIcon ���޷�������ʾ�����һ�
  // ��ԭ�е�ͼ��������˴��Ĵ���ɱ�֤ͼ��������ʾ�����Ҳ��������Դй©��
  DestroyIcon(FIconHandle);
  FIconHandle := CopyIcon(Icon.Handle);
  Result := FIconHandle;
end;

// ���ذ�װҳ��
function TCnRepositoryWizard.GetPage: string;
begin
  Result := SCnWizardsPage;
end;

//==============================================================================
// ������Ҽ��˵�ִ����Ŀ�Ļ���
//==============================================================================

{ TCnBaseMenuExecutor }

// �๹����
constructor TCnBaseMenuExecutor.Create(OwnWizard: TCnBaseWizard);
begin
  FWizard := OwnWizard;
end;

// ��������
destructor TCnBaseMenuExecutor.Destroy;
begin

  inherited;
end;

// PrepareItem ʱ�����ã�����Ĭ��ʲô������
procedure TCnBaseMenuExecutor.Prepare;
begin

end;

// ��Ŀִ�з���������Ĭ��ʲô������
function TCnBaseMenuExecutor.Execute: Boolean;
begin
  Result := True;
end;

// ������Ŀ�Ƿ���ʾ
function TCnBaseMenuExecutor.GetActive: Boolean;
begin
  Result := True;
end;

// ��Ŀ��ʾ�ı���
function TCnBaseMenuExecutor.GetCaption: string;
begin
  Result := '';
end;

// ������Ŀ�Ƿ�ʹ��
function TCnBaseMenuExecutor.GetEnabled: Boolean;
begin
  Result := True;
end;

// ��Ŀ����ʾ
function TCnBaseMenuExecutor.GetHint: string;
begin
  Result := '';
end;

{ TCnContextMenuExecutor }

constructor TCnContextMenuExecutor.Create;
begin
  inherited Create(nil);
  FActive := True;
  FEnabled := True;
end;

procedure TCnContextMenuExecutor.DoExecute;
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self);
end;

function TCnContextMenuExecutor.Execute: Boolean;
begin
  DoExecute;
  Result := True;
end;

function TCnContextMenuExecutor.GetActive: Boolean;
begin
  Result := FActive;
end;

function TCnContextMenuExecutor.GetCaption: string;
begin
  Result := FCaption;
end;

function TCnContextMenuExecutor.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TCnContextMenuExecutor.GetHint: string;
begin
  Result := FHint;
end;

initialization
  CnWizardClassList := TList.Create;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizClasses.');
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnBaseWizard finalization.');
{$ENDIF}

  FreeAndNil(CnWizardClassList);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnBaseWizard finalization.');
{$ENDIF}

end.

