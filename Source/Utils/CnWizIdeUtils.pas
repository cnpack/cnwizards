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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizIdeUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ع�����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
*           CnPack ������ master@cnpack.org
* ��    ע���õ�Ԫ����������ֲ�� GExperts 1.12 Src
*           ��ԭʼ������ GExperts License �ı���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2016.04.04 by liuxiao
*               ���� 2010 ���ϰ汾���·��ؼ����֧��
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2005.05.06 V1.3
*               hubdog ���� ��ȡ�汾��Ϣ�ĺ���
*           2004.03.19 V1.2
*               LiuXiao ���� CnPaletteWrapper����װ�ؼ����ĸ�������
*           2003.03.06 V1.1
*               GetLibraryPath ��չ��·��������Χ��֧�ֹ�������·��
*           2002.12.05 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, Forms, Contnrs,
  Menus, Buttons, ComCtrls, StdCtrls, ExtCtrls, TypInfo, ImgList,
  {$IFDEF LAZARUS} PackageIntf, ComponentReg, IDEOptionsIntf, {$ENDIF}
  {$IFDEF DELPHI_OTA} ToolsAPI, CnWizEditFiler, {$IFDEF IDE_SUPPORT_HDPI}
  Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF}
 {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner, Variants,
  {$ELSE} DsgnIntf, LibIntf,{$ENDIF} {$ENDIF}
  {$IFDEF FPC} LCLType, {$ELSE} Tabs, {$ENDIF}
  {$IFDEF OTA_PALETTE_API} PaletteAPI, {$ENDIF}
  {$IFNDEF STAND_ALONE} {$IFNDEF CNWIZARDS_MINIMUM} CnIDEVersion, {$ENDIF} {$ENDIF}
  {$IFDEF USE_CODEEDITOR_SERVICE} ToolsAPI.Editor, {$ENDIF}
  CnPasCodeParser, CnWidePasParser, CnWizMethodHook, mPasLex, CnPasWideLex,
  mwBCBTokenList, CnBCBWideTokenList, CnWizUtils, CnCommon,
  CnWideStrings, CnWizOptions, CnWizCompilerConst, CnIDEStrings;

//==============================================================================
// IDE �еĳ�������
//==============================================================================

const
  // IDE Action ����
  SCnEditSelectAllCommand = 'EditSelectAllCommand';

  // Editor �����Ҽ��˵�����
  SCnMenuClosePageName = 'ecClosePage';
  SCnMenuClosePageIIName = 'ecClosePageII';
  SCnMenuEditPasteItemName = 'EditPasteItem';
  SCnMenuOpenFileAtCursorName = 'ecOpenFileAtCursor';

  // Editor �����������
{$IFDEF LAZARUS}
  SCnEditorFormClassName = 'TSourceNotebook';
  SCnEditorFormName = 'SourceNotebook';    // �ƺ�������ʵ��
  SCnEditControlClassName = 'TIDESynEditor';
  SCnEditControlNamePrefix = 'SynEdit';    // һ���ڶ���༭��ʵ���������ǰ׺�����ƺ��滹������

  // Lazarus �༭������һ�� PageControl��ÿ�� TabSheet ��һ���༭��ʵ��
  SCnEditWindowPageControlClassName = 'TExtendedNotebook';
  SCnEditWindowPageControlName = 'SrcEditNotebook';
{$ELSE}
  SCnEditorFormClassName = 'TEditWindow';
  SCnEditorFormNamePrefix = 'EditWindow_'; // �ര��ʵ���������ǰ׺�����ƺ��滹������
  SCnEditControlClassName = 'TEditControl';
  SCnEditControlName = 'Editor';
{$ENDIF}

  SCnDesignControlClassName = 'TEditorFormDesigner';
  SCnWelcomePageClassName = 'TWelcomePageFrame';
  SCnDisassemblyViewClassName = 'TDisassemblyView';
  SCnDisassemblyViewName = 'CPU';
  SCnEditorStatusBarName = 'StatusBar';

{$IFDEF BDS}
  {$IFDEF BDS4_UP} // BDS 2006 RAD Studio 2007 �ı�ǩҳ����
  SCnXTabControlClassName = 'TIDEGradientTabSet';   // TWinControl ����
  {$ELSE} // BDS 2005 �ı�ǩҳ����
  SCnXTabControlClassName = 'TCodeEditorTabControl'; // TTabSet ����
  {$ENDIF}
{$ELSE} // Delphi BCB �ı�ǩҳ����
  SCnXTabControlClassName = 'TXTabControl';
{$ENDIF BDS}
  SCnXTabControlName = 'TabControl';

  SCnTabControlPanelName = 'TabControlPanel';
  SCnCodePanelName = 'CodePanel';
  SCnTabPanelName = 'TabPanel';

  // ����鿴��
  SCnPropertyInspectorClassName = 'TPropertyInspector';
  SCnPropertyInspectorName = 'PropertyInspector';
  SCnPropertyInspectorListClassName = 'TInspListBox';
  SCnPropertyInspectorListName = 'PropList';
  SCnPropertyInspectorTabControlName = 'TabControl';
  SCnPropertyInspectorLocalPopupMenu = 'LocalPopupMenu';

  // �༭�����öԻ���
{$IFDEF BDS}
  SCnEditorOptionDlgClassName = 'TDefaultEnvironmentDialog';
  SCnEditorOptionDlgName = 'DefaultEnvironmentDialog';
{$ELSE} {$IFDEF BCB}
  SCnEditorOptionDlgClassName = 'TCppEditorPropertyDialog';
  SCnEditorOptionDlgName = 'CppEditorPropertyDialog';
{$ELSE}
  SCnEditorOptionDlgClassName = 'TPasEditorPropertyDialog';
  SCnEditorOptionDlgName = 'PasEditorPropertyDialog';
{$ENDIF} {$ENDIF}

  // �ؼ������������������
  SCnPaletteTabControlClassName = 'TComponentPaletteTabControl';
  SCnPalettePropSelectedIndex = 'SelectedIndex';
  SCnPalettePropSelectedToolName = 'SelectedToolName';
  SCnPalettePropSelector = 'Selector';
  SCnPalettePropPalToolCount = 'PalToolCount';

  // D2010 �����ϰ汾���¿ؼ��壬һ�� TComponentToolbarFrame ����� TGradientTabSet
  SCnNewPaletteFrameClassName = 'TComponentToolbarFrame';
  SCnNewPaletteFrameName = 'ComponentToolbarFrame';
  SCnNewPaletteTabClassName = 'TGradientTabSet';
  SCnNewPaletteTabName = 'TabControl';
  SCnNewPaletteTabItemsPropName = 'Items';
  SCnNewPaletteTabIndexPropName = 'TabIndex';
  SCnNewPalettePanelContainerName = 'PanelButtons';
  SCnNewPaletteButtonClassName = 'TPalItemSpeedButton';
  
  // ��Ϣ����
  SCnMessageViewFormClassName = 'TMessageViewForm';
  SCnMessageViewTabSetName = 'MessageGroups';
  SCnMvEditSourceItemName = 'mvEditSourceItem';

  // ������Ϣ��ʾ�󴰿�
  SCnExpandableEvalViewClassName = 'TExpandableEvalView';
  SCnExpandableEvalViewName = 'ExpandableEvalView';

{$IFDEF BDS}
  SCnTreeMessageViewClassName = 'TBetterHintWindowVirtualDrawTree';
{$ELSE}
  SCnTreeMessageViewClassName = 'TTreeMessageView';
{$ENDIF}

  // XE5 �����ϰ汾�� IDE Insight ������ 
{$IFDEF IDE_HAS_INSIGHT}
  SCnIDEInsightBarClassName = 'TButtonedEdit';
  SCnIDEInsightBarName = 'beIDEInsight';
{$ENDIF}

  // ���õ�Ԫ���ܵ� Action ����
{$IFDEF DELPHI}
  SCnUseUnitActionName = 'FileUseUnitCommand';
{$ELSE}
  SCnUseUnitActionName = 'FileIncludeUnitHdrCommand';
{$ENDIF}

  // Lazarus ������
  SCnLazMainFormClassName = 'TMainIDEBar';
  SCnLazMainFormName = 'MainIDE';

  SCnColor16Table: array[0..15] of TColor =
  ( clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clLtGray, clDkGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite);

  csDarkBackgroundColor = $2E2F33;  // Dark ģʽ�µ�δѡ�еı���ɫ
  csDarkFontColor = $FFFFFF;        // Dark ģʽ�µ�δѡ�е�������ɫ
  csDarkHighlightBkColor = $8E6535; // Dark ģʽ�µ�ѡ��״̬�µĸ�������ɫ
  csDarkHighlightFontColor = $FFFFFF; // Dark ģʽ�µ�ѡ��״̬�µĸ���������ɫ

  // 10.4.2 ��� Error Insight �������ͣ���Ӱ���и�
  SCnErrorInsightRenderStyleKeyName = 'ErrorInsightMarks';
  csErrorInsightRenderStyleNotSupport = -1;
  csErrorInsightRenderStyleClassic = 0;
  csErrorInsightRenderStyleSmoothWave = 1;
  csErrorInsightRenderStyleSolid = 2;
  csErrorInsightRenderStyleDot = 3;

  // Smooth Waveʱ�и��� 3 ���صĹ̶�ƫ��
  csErrorInsightCharHeightOffset = 3;

type
{$IFDEF BDS}
  {$IFDEF BDS2006_UP}
  TXTabControl = TWinControl;
  {$ELSE}
  TXTabControl = TTabSet;
  {$ENDIF}
{$ELSE}
  TXTabControl = TTabControl;
{$ENDIF BDS}

{$IFDEF BDS}
  TXTreeView = TCustomControl;
{$ELSE}
  TXTreeView = TTreeView;
{$ENDIF BDS}

  TCnSrcEditorPage = (epCode, epDesign, epCPU, epWelcome, epOthers);

  TCnModuleSearchType = (mstInvalid, mstInProject, mstProjectSearch, mstSystemSearch);
  {* ��������Դ��λ�����ͣ��Ƿ��������ڡ���������Ŀ¼�ڡ�ϵͳ����Ŀ¼�ڣ�������װĿ¼��ϵͳ�⣩}

  TCnModuleSearchTypes = set of TCnModuleSearchType;

  TCnUsesFileType = (uftInvalid, uftPascalSource, uftPascalDcu, uftCppHeader);

  TCnUnitCallback = procedure(const AUnitFullName: string; Exists: Boolean;
    FileType: TCnUsesFileType; ModuleSearchType: TCnModuleSearchType) of object;

  TEnumEditControlProc = procedure (EditWindow: TCustomForm; EditControl:
    TControl; Context: Pointer) of object;

type
  PCnUnitsInfoRec = ^TCnUnitsInfoRec;
  TCnUnitsInfoRec = record
    IsCppMode: Boolean;
    Sorted: TStringList;
    Unsorted: TStringList;
  end;

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ѡ���еĴ��룬ʹ������ģʽ�����ѡ���Ϊ�գ��򷵻ص�ǰ�д��롣}

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ѡ���Ĵ��롣}

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ȫ��Դ���롣}

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ѡ���еĴ��룬ʹ������ģʽ�����ѡ���Ϊ�գ����滻��ǰ�д��롣}

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ѡ���Ĵ��롣}

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ȫ��Դ���롣}

function IdeInsertTextIntoEditor(const Text: string): Boolean;
{* �����ı�����ǰ�༭����֧�ֶ����ı���}

function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
{* ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ�� }

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
{* �ƶ���굽ָ��λ�ã�Middle ��ʾ�Ƿ��ƶ���ͼ�����ġ�}

function IdeGetBlockIndent: Integer;
{* ��õ�ǰ�༭����������� }

function IdeGetSourceByFileName(const FileName: string): string;
{* �����ļ���ȡ�����ݡ�����ļ��� IDE �д򿪣����ر༭���е����ݣ����򷵻��ļ����ݡ�
  ����Ӧ������ BOM ͷ�� Ansi/Ansi/Utf16}

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
{* �����ļ���д�����ݡ�����ļ��� IDE �д򿪣�д�����ݵ��༭���У��������
   OpenInIde Ϊ����ļ�д�뵽�༭����OpenInIde Ϊ��ֱ��д���ļ���}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£�Ƶ�����ã���˴˴� View ��ָ�����������ü����Ӷ��Ż��ٶȣ����汾����ʹ�� }

function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£�ͬ�ϣ���ʹ�� WideToken���ɹ� Unicode/Utf8 �����µ���}

function IsGeneralCurrentToken(AView: Pointer; AControl: TControl;
    Token: TCnGeneralPasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£����������������}

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* ȡ�ô���༭�����������FormEditor Ϊ nil ��ʾȡ��ǰ���� }

function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
{* ȡ�õ�ǰ��ƵĴ��� }

function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
{* ȡ�õ�ǰ��ƴ�������ѡ������ }

{$ENDIF}

function IdeGetIsEmbeddedDesigner: Boolean;
{* ȡ�õ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ}

var
  IdeIsEmbeddedDesigner: Boolean = False;
  {* ��ǵ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ��initiliazation ʱ����ʼ���������ֹ��޸���ֵ��
     ʹ�ô�ȫ�ֱ������Ա���Ƶ������ IdeGetIsEmbeddedDesigner ����}

//==============================================================================
// �޸��� GExperts Src 1.12 �� IDE ��غ���
//==============================================================================

function GetIDEMainForm: TCustomForm;
{* ���� IDE �����壨TAppBuilder �� TMainIDEBar��}

{$IFDEF DELPHI_OTA}

function GetIDEEdition: string;
{* ���� IDE �汾}

function GetComponentPaletteTabControl: TTabControl;
{* ������������󣬿���Ϊ�գ�ֻ֧�� 2010 ���°汾}

function GetNewComponentPaletteTabControl: TWinControl;
{* ���� 2010 �����ϵ����������ϰ벿�� Tab ���󣬿���Ϊ��}

function GetNewComponentPaletteComponentPanel: TWinControl;
{* ���� 2010 �����ϵ����������°벿����������б���������󣬿���Ϊ��}

function GetEditWindowStatusBar(EditWindow: TCustomForm = nil): TStatusBar;
{* ���ر༭�������·���״̬��������Ϊ��}

function GetObjectInspectorForm: TCustomForm;
{* ���ض����������壬����Ϊ��}

function GetComponentPalettePopupMenu: TPopupMenu;
{* �����������Ҽ��˵�������Ϊ��}

function GetComponentPaletteControlBar: TControlBar;
{* �������������ڵ� ControlBar������Ϊ��}

function GetIDEInsightBar: TWinControl;
{* ���� IDE Insight ������ؼ�����}

function GetExpandableEvalViewForm: TCustomForm;
{* ���ص���ʱ��ʾ��Ϣ�󴰿ڣ��Ͱ汾��ǵ����ڿ���Ϊ��}

function GetMainMenuItemHeight: Integer;
{* �������˵���߶� }

{$ENDIF}

function IsIdeEditorForm(AForm: TCustomForm): Boolean;
{* �ж�ָ�������Ƿ�༭������}

function IsIdeDesignForm(AForm: TCustomForm): Boolean;
{* �ж�ָ�������Ƿ�������ڴ���}

procedure BringIdeEditorFormToFront;
{* ��Դ��༭����Ϊ��Ծ}

procedure GetInstalledComponents(Packages, Components: TStrings);
{* ȡ�Ѱ�װ�İ����������������Ϊ nil�����ԣ�}

function IsEditControl(AControl: TComponent): Boolean;
{* �ж�ָ���ؼ��Ƿ����༭���ؼ� }

function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean = True): Integer;
{* ö�� IDE �еĴ���༭�����ں� EditControl �ؼ������ûص��������������� }

{$IFDEF LAZARUS}

function GetEditControlsFromEditorForm(AForm: TCustomForm; EditControls: TObjectList): Integer;
{* Lazarus �·��ر༭�����ڵı༭���ؼ��б���Ϊһ�������� Tab��ÿ�� Tab ����һ�� Edit �ؼ���}

{$ELSE}

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
{* ���ر༭�����ڵı༭���ؼ���ע�� Lazarus ����Ϊһ�������� Tab��ÿ�� Tab ����һ�� Edit �ؼ���
  ���������ֻ�ܷ����ҵ��ĵ�һ�����������Ŀؼ������岻��ֱ���� Lazarus �½��ã�ֻ�� Delphi ��ʹ�á�}

{$ENDIF}

function GetCurrentEditControl: TControl;
{* ���ص�ǰ�Ĵ���༭���ؼ� }

procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean = True);
{* ȡ���������е� LibraryPath ����}

procedure GetProjectLibPath(Paths: TStrings);
{* ȡ��ǰ���������� Path ����}

function GetProjectDcuPath(AProject: TCnIDEProjectInterface): string;
{* ȡ��ǰ���̵����Ŀ¼��֧�� Delphi �� Lazarus}

function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
{* ȡ��ǰ�༭���ڶ���ҳ�����ͣ�����༭�����ؼ� }

function IsDesignControl(AControl: TControl): Boolean;
{* �ж�һ Control �Ƿ�������� WinControl}

function IsDesignWinControl(AControl: TWinControl): Boolean;
{* �ж�һ WinControl �Ƿ�������� WinControl}

function IsXTabControl(AControl: TComponent): Boolean;
{* �ж�ָ���ؼ��Ƿ�༭�����ڵ� TabControl �ؼ� }

{$IFDEF DELPHI_OTA}

procedure CloseExpandableEvalViewForm;
{* �رյ���ʱ��ʾ��Ϣ�󴰿�}

function IDEIsCurrentWindow: Boolean;
{* �ж� IDE �Ƿ��ǵ�ǰ�Ļ���� }

//==============================================================================
// ������ IDE ��غ���
//==============================================================================

function GetInstallDir: string;
{* ȡ��������װĿ¼}

{$IFDEF BDS}
function GetBDSUserDataDir: string;
{* ȡ�� BDS (Delphi8�Ժ�汾) ���û�����Ŀ¼ }
{$ENDIF}

function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
{* ����ģ������������ļ���}

function GetFileNameSearchTypeFromModuleName(AName: string;
  var SearchType: TCnModuleSearchType; AProject: IOTAProject = nil): string;
{* ����ģ������������ļ����Լ�������һ������Ŀ¼�У�����չ��ʱĬ���� pas}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
{* ��ȡ��ǰ��Ŀ�еİ汾��Ϣ��ֵ}

function GetCurrentCompilingProject: IOTAProject;
{* ���ص�ǰ���ڱ���Ĺ��̣�ע�ⲻһ���ǵ�ǰ����}

function CompileProject(AProject: IOTAProject): Boolean;
{* ���빤�̣����ر����Ƿ�ɹ�}

function GetComponentUnitName(const ComponentName: string): string;
{* ȡ����������ڵĵ�Ԫ��}

function GetIDERegistryFont(const RegItem: string; AFont: TFont;
  out BackgroundColor: TColor; CheckBackDef: Boolean = False): Boolean;
{* ��ĳ��ע���������ĳ�����岢��ֵ�� AFont�����ѱ���ɫ��ֵ�� BackgroundColor
   CheckBackDef ��ʾ��Ŀǰ���� D56 �£�������ɫʱ�Ƿ��� Default Background Ϊ True��
   True ����ʹ��Ĭ�ϱ���ɫ�����Ǳ���Ŀ����ɫ����������ض����ı���ɫֵ
   RegItem ������ '', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol'
    ��ע�����ͷ�Ѿ������˵ļ�ֵ}

function GetCPUViewFromEditorForm(AForm: TCustomForm): TControl;
{* ���ر༭�����ڵ� CPU �鿴���ؼ� }

function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
{* ���ر༭�����ڵ� TabControl �ؼ� }

function GetEditorTabTabs(ATab: TXTabControl): TStrings;
{* ���ر༭�� TabControl �ؼ��� Tabs ����}

function GetEditorTabTabIndex(ATab: TXTabControl): Integer;
{* ���ر༭�� TabControl �ؼ��� Index ����}

function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
{* �ӱ༭���ؼ�����������ı༭�����ڵ�״̬��}

function GetCurrentSyncButton: TControl;
{* ��ȡ��ǰ��ǰ�˱༭�����﷨�༭��ť��ע���﷨�༭��ť���ڲ����ڿɼ�}

function GetCurrentSyncButtonVisible: Boolean;
{* ��ȡ��ǰ��ǰ�˱༭�����﷨�༭��ť�Ƿ�ɼ����ް�ť�򲻿ɼ������� False}

function GetCodeTemplateListBox: TControl;
{* ���ر༭���еĴ���ģ���Զ������}

function GetCodeTemplateListBoxVisible: Boolean;
{* ���ر༭���еĴ���ģ���Զ�������Ƿ�ɼ����޻򲻿ɼ������� False}

function IsCurrentEditorInSyncMode: Boolean;
{* ��ǰ�༭���Ƿ����﷨��༭ģʽ�£���֧�ֻ��ڿ�ģʽ�·��� False}

function IsKeyMacroRunning: Boolean;
{* ��ǰ�Ƿ��ڼ��̺��¼�ƻ�طţ���֧�ֻ��ڷ��� False}

procedure BeginBatchOpenClose;
{* ��ʼ�����򿪻�ر��ļ� }

procedure EndBatchOpenClose;
{* ���������򿪻�ر��ļ� }

function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
{* �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNode ǿ��ת���ɹ��õ� TreeNode}

function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
{* �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNodes ǿ��ת���ɹ��õ� TreeNodes}

procedure ApplyThemeOnToolBar(ToolBar: TToolBar; Recursive: Boolean = True);
{* Ϊ������Ӧ�����⣬ֻ��֧������� Delphi �汾����Ч}

function GetErrorInsightRenderStyle: Integer;
{* ���� ErrorInsight �ĵ�ǰ���ͣ�����ֵΪ csErrorInsightRenderStyle* ϵ�г���
   -1 Ϊ��֧�֣�1 ʱ��Ӱ��༭���иߣ�Ӱ��̶Ⱥ���ʾ Leve �Լ��Ƿ�������ʾ���޹�}

function IdeEnumUsesIncludeUnits(UnitCallback: TCnUnitCallback; IsCpp: Boolean = False;
  SearchTypes: TCnModuleSearchTypes = [mstInProject, mstProjectSearch, mstSystemSearch]): Boolean;
{* ���� Uses ��Ԫ���ɸ��� SearchTypes ָ����Χ�����ص��ļ��������� IDE �д򿪵Ļ�δ�����
  Delphi ����� pas �� dcu��C++Builder ����� h/hpp�������� UnitCallback ��ָ��}

procedure CorrectCaseFromIdeModules(UnitFilesList: TStringList; IsCpp: Boolean = False);
{* �����ļ�����õ�ϵͳ Uses �ĵ�Ԫ����Сд���ܲ���ȷ���˴�ͨ������ IDE ģ��������
  UnitFilesList �ǲ��� dcu ��չ�����ļ����б�ע�ⲻ������·�����б�
  ������� UnitFilesList.Sorted �ᱻ��Ϊ True}

//==============================================================================
// ��չ�ؼ�
//==============================================================================

type
  TCnToolBarComboBox = class(TComboBox)
  private
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  end;

//==============================================================================
// �������װ��
//==============================================================================

type

{ TCnPaletteWrapper }

  TCnPaletteWrapper = class(TObject)
  {* ��װ�˿ؼ���������Ե��࣬�󲿷�ֻ֧�ֵͰ汾�ؼ���
     �߰汾�ؼ������������� Panel ��ɣ����� Panel ���� TGradientTab �� ToolbarSearch
     ���� Panel ���ɹ�����ť�Լ���� TPalItemSpeedButton �Ŀؼ�ͼ�갴ť}
  private
    FPalTab: TWinControl;  // �Ͱ汾ָ��� TabControl �������߰汾ָ�ϰ벿�ֵ� TGradientTabSet
    FPalette: TWinControl; // �Ͱ汾ָ��� TabControl �ڵ�����������߰汾ָ�°벿�ֵ��������
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FPageScroller: TWinControl;
{$ENDIF}
    FUpdateCount: Integer;
{$IFDEF COMPILER6_UP}
  {$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    FOldRootClass: TClass;
  {$ENDIF}
{$ENDIF}
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    function ParseCompNameFromHint(const Hint: string): string;
    function ParseUnitNameFromHint(const Hint: string): string;
    function ParsePackageNameFromHint(const Hint: string): string;
{$ENDIF}
    function GetSelectedIndex: Integer;
    function GetSelectedToolName: string;
    function GetSelectedUnitName: string;
    function GetSelector: TSpeedButton;
    function GetPalToolCount: Integer;
    function GetActiveTab: string;
    function GetTabCount: Integer;
    function GetIsMultiLine: Boolean;
    procedure SetSelectedIndex(const Value: Integer);
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetTabs(Index: Integer): string;

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    procedure GetComponentImageFromNewPalette(Bmp: TBitmap; const AComponentClassName: string);
  {$ELSE}
    procedure GetComponentImageFromOldPalette(Bmp: TBitmap; const AComponentClassName: string);
  {$ENDIF}
{$ENDIF}
  public
    constructor Create;

    procedure BeginUpdate;
    {* ��ʼ���£���ֹˢ��ҳ�� }
    procedure EndUpdate;
    {* ֹͣ���£��ָ�ˢ��ҳ�� }
    function SelectComponent(const AComponent: string; const ATab: string): Boolean;
    {* ��������ѡ�пؼ����е�ĳ�ؼ��������Ƿ�ɹ� }
    function FindTab(const ATab: string): Integer;
    {* ����ĳҳ������� }
    function GetUnitNameFromComponentClassName(const AClassName: string;
      const ATabName: string = ''): string;
    {* �������������䵥Ԫ��}
{$IFDEF OTA_PALETTE_API}
    function GetUnitPackageNameFromComponentClassName(out UnitName: string; out PackageName: string;
      const AClassName: string; const ATabName: string = ''): Boolean;
    {* �� Palette API �Ľӿڴ����������õ�Ԫ������������ػ�ȡ�Ƿ�ɹ�}
{$ENDIF}
    procedure GetComponentImage(Bmp: TBitmap; const AComponentClassName: string);
    {* ���ؼ�����ָ�����������ͼ����Ƶ� Bmp �У�Bmp �Ƽ��ߴ�Ϊ 26 * 26}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* ���µĿؼ��ڱ�ҳ����ţ�0 ��ͷ��֧�ָ߰汾���¿ؼ��� }
    property SelectedToolName: string read GetSelectedToolName;
    {* ���µĿؼ���������δ������Ϊ�գ�֧�ָ߰汾���¿ؼ��� }
    property SelectedUnitName: string read GetSelectedUnitName;
    {* ���µĿؼ��ĵ�Ԫ����δ����Ϊ�գ�֧�ָ߰汾���¿ؼ��棬�ɽ��� Hint ����}
    property Selector: TSpeedButton read GetSelector;
    {* ��������л��������� SpeedButton���Ͱ汾��������ڣ��߰汾�� Tab ͷ�� }
    property PalToolCount: Integer read GetPalToolCount;
    {* ��ǰҳ�ؼ�������֧�ָ߰汾���¿ؼ��� }
    property ActiveTab: string read GetActiveTab;
    {* ��ǰҳ���⣬֧�ָ߰汾���¿ؼ��� }
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* ��ǰҳ������֧�ָ߰汾���¿ؼ��� }
    property Tabs[Index: Integer]: string read GetTabs;
    {* ���������õ�ҳ���ƣ�֧�ָ߰汾���¿ؼ��� }
    property TabCount: Integer read GetTabCount;
    {* �ؼ�����ҳ����֧�ָ߰汾���¿ؼ��� }
    property IsMultiLine: Boolean read GetIsMultiLine;
    {* �ؼ����Ƿ���У�֧�ָ߰汾���¿ؼ��嵫�߰汾�¿ؼ��岻֧�ֶ��� }
    property Visible: Boolean read GetVisible write SetVisible;
    {* �ؼ����Ƿ�ɼ���֧�ָ߰汾���¿ؼ��� }
    property Enabled: Boolean read GetEnabled write SetEnabled;
    {* �ؼ����Ƿ�ʹ�ܣ�֧�ָ߰汾���¿ؼ��� }
  end;

{ TCnMessageViewWrapper }

  TCnMessageViewWrapper = class(TObject)
  {* ��װ����Ϣ��ʾ���ڵĸ������Ե��� }
  private
    FMessageViewForm: TCustomForm;
    FTreeView: TXTreeView;
    FTabSet: TTabSet;
    FEditMenuItem: TMenuItem;
{$IFNDEF BDS}
    function GetMessageCount: Integer;
    function GetSelectedIndex: Integer;
    procedure SetSelectedIndex(const Value: Integer);
    function GetCurrentMessage: string;
{$ENDIF}
    function GetTabCaption: string;
    function GetTabCount: Integer;
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetTabSetVisible: Boolean;
  public
    constructor Create;

    procedure UpdateAllItems;

    procedure EditMessageSource;
    {* ˫����Ϣ����}

    property MessageViewForm: TCustomForm read FMessageViewForm;
    {* ��Ϣ����}
    property TreeView: TXTreeView read FTreeView;
    {* ��Ϣ�����ʵ����BDS �·� TreeView�����ֻ�ܷ��� CustomControl }
{$IFNDEF BDS}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* ��Ϣ��ѡ�е����}
    property MessageCount: Integer read GetMessageCount;
    {* ���е���Ϣ��}
    property CurrentMessage: string read GetCurrentMessage;
    {* ��ǰѡ�е���Ϣ�����ƺ����Ƿ��ؿ�}
{$ENDIF}
    property TabSet: TTabSet read FTabSet;
    {* ���ط�ҳ�����ʵ��}
    property TabSetVisible: Boolean read GetTabSetVisible;
    {* ���ط�ҳ����Ƿ�ɼ���D5 ��Ĭ�ϲ��ɼ�}
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* ����/���õ�ǰҳ���}
    property TabCount: Integer read GetTabCount;
    {* ������ҳ��}
    property TabCaption: string read GetTabCaption;
    {* ���ص�ǰҳ���ַ���}
    property EditMenuItem: TMenuItem read FEditMenuItem;
    {* '�༭'�˵���}
  end;

  TCnThemeWrapper = class(TObject)
  {* ��װ��������Ϣ�Ĺ�����}
  private
    FActiveThemeName: string;
    FCurrentIsDark: Boolean;
    FCurrentIsLight: Boolean;
    FSupportTheme: Boolean;
    procedure ThemeChanged(Sender: TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsUnderDarkTheme: Boolean;
    function IsUnderLightTheme: Boolean;

    property SupportTheme: Boolean read FSupportTheme;
    property ActiveThemeName: string read FActiveThemeName;
    property CurrentIsDark: Boolean read FCurrentIsDark;
    property CurrentIsLight: Boolean read FCurrentIsLight;
  end;

function CnPaletteWrapper: TCnPaletteWrapper;
{* �ؼ����װ����}

function CnMessageViewWrapper: TCnMessageViewWrapper;
{* ��Ϣ����װ����}

function CnThemeWrapper: TCnThemeWrapper;
{* �����װ����}

procedure DisableWaitDialogShow;
{* �� Hook ��ʽ���� WaitDialog}

procedure EnableWaitDialogShow;
{* �Խ�� Hook ��ʽ���� WaitDialog}

{$ENDIF}

function IdeGetScaledPixelsFromOrigin(APixels: Integer; AControl: TControl = nil): Integer;
{* IDE �и��� DPI ���������ã�����ԭʼ����������ʵ�������������ڻ���
  ֧�� Windows �е����űȣ�֧�� IDE ������ DPI Ware/Unware ��
  Ҳ����˵��Windows ���ű��� 100% Ҳ����ԭʼ��Сʱ������ IDE ����ģʽ��ζ�����ԭʼ����
  ���űȲ�Ϊ 100% ʱ��DPI Ware �ŷ��� APixels * HDPI ������Unware ����ɶ�����Է���ԭʼ����}

function IdeGetOriginPixelsFromScaled(APixels: Integer; AControl: TControl = nil): Integer;
{* IDE �и��� DPI ���������ã�������ʵ����������Ӧ��ԭʼ������������ƻ�洢
  ֧�� Windows �е����űȣ�֧�� IDE ������ DPI Ware/Unware ��
  Ҳ����˵��Windows ���ű��� 100% Ҳ����ԭʼ��Сʱ������ IDE ����ģʽ��ζ�����ԭʼ����
  ���űȲ�Ϊ 100% ʱ��DPI Ware �ŷ��� APixels / HDPI ������Unware ����ɶ�����Է���ԭʼ����}

function IdeGetScaledFactor(AControl: TControl = nil): Single;
{* ��� IDE ��ĳ�ؼ���Ӧ�÷Ŵ�ı���}

procedure IdeSetReverseScaledFontSize(AControl: TControl);
{* IDE �и��� DPI ���������ã����Ƽ���ĳ�ֺŵ�ԭʼ�ߴ磬�Ա� Scale ʱ�ָ�ԭʼ�ߴ硣�ݲ�ʹ�á�}

procedure IdeScaleToolbarComboFontSize(Combo: TControl);
{* ͳһ���ݵ�ǰ HDPI ���������õ����� Toolbar �е� Combobox ���ֺ�}

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}

function IdeGetVirtualImageListFromOrigin(Origin: TCustomImageList;
  AControl: TControl = nil; IgnoreWizLargeOption: Boolean = False): TVirtualImageList;
{* ͳһ���ݵ�ǰ HDPI ���������õȣ���ԭʼ TImageList ����һ�� TVirtualImageList�������ͷ�
  IgnoreWizLargeOption ��ʾ������ר�Ұ������е�ʹ�ô�ͼ��}

{$ENDIF}
{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF CNWIZARDS_MINIMUM}

{$IFDEF DELPHI_OTA}

function SearchUsesInsertPosInPasFile(const FileName: string; IsIntf: Boolean;
  out HasUses: Boolean; out LinearPos: Integer): Boolean;
{* ʹ�� Filer ��װָ�� Pascal Դ�ļ������� uses �����������λ�ã��������ļ������
  ƫ�ƾ��� Ansi/Utf16/Utf16 Ϊ׼��IsIntf ָ���������� interface ���� uses
  ���� implemetation �ģ������Ƿ�ɹ����ɹ�ʱ��������λ�ã��Լ��ô��Ƿ����� uses}

function SearchUsesInsertPosInCurrentPas(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
{* �ڵ�ǰ�༭�� Pascal Դ�ļ������� uses ������ı༭��λ�ã�IsIntf ָ���������� interface ���� uses
  ���� implemetation �ģ������Ƿ�ɹ����ɹ�ʱ���ر༭��λ�ã��Լ��ô��Ƿ����� uses}

function SearchUsesInsertPosInCurrentCpp(out CharPos: TOTACharPos;
  SourceEditor: IOTASourceEditor = nil): Boolean;
{* �ڱ༭�� C++ Դ�ļ������� include �������λ�ã������Ƿ�ɹ����ɹ�ʱ����λ��}

function JoinUsesOrInclude(IsCpp, FileHasUses: Boolean; IsHFromSystem: Boolean;
  const IncFiles: TStrings): string;
{* ����Դ���������������ļ����б�õ������ uses �� include �ַ�����
  FileHasUses ֻ�� Pascal ������Ч��IsHFromSystem ֻ�� Cpp �ļ���Ч}

{$ENDIF}
{$ENDIF}
{$ENDIF}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Registry, CnGraphUtils {$IFNDEF LAZARUS}, CnWizNotifier {$ENDIF};

const
{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF FPC}
  CN_DEF_SCREEN_DPI = 96;
{$ELSE}
  CN_DEF_SCREEN_DPI = Windows.USER_DEFAULT_SCREEN_DPI;
{$ENDIF}
{$ENDIF}

  SSyncButtonName = 'SyncButton';
  SCodeTemplateListBoxName = 'CodeTemplateListBox';
{$IFDEF IDE_SWITCH_BUG}
  {$IFDEF WIN64}
  SWaitDialogShow = '_ZN10Waitdialog14TIDEWaitDialog4ShowEN6System13UnicodeStringES2_b';
  {$ELSE}
  SWaitDialogShow = '@Waitdialog@TIDEWaitDialog@Show$qqrx20System@UnicodeStringt1o';
  {$ENDIF}
{$ENDIF}

{$IFDEF BDS4_UP}
const
{$IFDEF WIN64}
  SBeginBatchOpenCloseName = '_ZN10Editorform19BeginBatchOpenCloseEv';
  SEndBatchOpenCloseName = '_ZN10Editorform17EndBatchOpenCloseEb';
{$ELSE}
  SBeginBatchOpenCloseName = '@Editorform@BeginBatchOpenClose$qqrv';
  SEndBatchOpenCloseName = '@Editorform@EndBatchOpenClose$qqrv';

{$IFDEF DELPHI120_ATHENS_UP}
  // D12.1 �����ˣ��� 12 û��
  SEndBatchOpenCloseName121 = '@Editorform@EndBatchOpenClose$qqrxo';
{$ENDIF}
{$ENDIF}

var
  BeginBatchOpenCloseProc: TProcedure = nil;
  EndBatchOpenCloseProc: TProcedure = nil;
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
var
  FOriginImages: TObjectList = nil;
  FVirtualImages: TObjectList = nil;
  FImageCollections: TObjectList = nil;
{$ENDIF}

{$IFDEF IDE_SWITCH_BUG}
type
  TCnWaitDialogShowProc = procedure (ASelfClass: Pointer; const Caption: string;
    const TitleMessage: string; LockDrawing: Boolean);

var
  FDesignIdeHandle: THandle = 0;
  FWaitDialogHook: TCnMethodHook = nil;
  OldWaitDialogShow: TCnWaitDialogShowProc = nil;

procedure MyWaitDialogShow(ASelfClass: Pointer; const Caption: string; const TitleMessage: string; LockDrawing: Boolean);
begin
  // ɶ������
{$IFDEF DEBUG}
  CnDebugger.LogMsg('MyWaitDialogShow Called. Do Nothing.');
{$ENDIF}
end;

{$ENDIF}

type
  TControlHack = class(TControl);
  TCustomControlHack = class(TCustomControl);

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE���ܺ���
//==============================================================================

type
  TGetCodeMode = (smLine, smSelText, smSource);
  // ѡ������չ�����У�δѡ��ǰ�У���ѡ�����������ļ�

function DoGetEditorSrcInfo(Mode: TGetCodeMode; View: IOTAEditView;
  var StartPos, EndPos, NewRow, NewCol, BlockStartLine, BlockEndLine: Integer): Boolean;
var
  Block: IOTAEditBlock;
  Row, Col: Integer;
  Stream: TMemoryStream;
begin
  Result := False;
  if View <> nil then
  begin
    Block := View.Block;
    StartPos := 0;
    EndPos := 0;
    BlockStartLine := 0;
    BlockEndLine := 0;
    NewRow := 0;
    NewCol := 0;
    if Mode = smLine then
    begin
{$IFDEF DEBUG}
      if Block = nil then
        CnDebugger.LogMsg('DoGetEditorSrcInfo: Block is nil.')
      else if Block.IsValid then
        CnDebugger.LogMsg('DoGetEditorSrcInfo: Block is Valid.');
{$ENDIF}
      if (Block <> nil) and Block.IsValid then
      begin             // ѡ���ı���������
        BlockStartLine := Block.StartingRow;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockStartLine), View);
        BlockEndLine := Block.EndingRow;
        // ��겻������ʱ��������һ������
        if Block.EndingColumn > 1 then
        begin
          if BlockEndLine < View.Buffer.GetLinesInBuffer then
          begin
            Inc(BlockEndLine);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, BlockEndLine), View);
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
      end
      else
      begin    // δѡ���ʾת�����С�
        if CnOtaGetCurSourcePos(Col, Row) then
        begin
          StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row), View);
          if Row < View.Buffer.GetLinesInBuffer then
          begin
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row + 1), View);
            NewRow := Row + 1;
            NewCol := Col;
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, Row), View);
        end
        else
        begin
          Exit;
        end;
      end;
    end
    else if Mode = smSelText then
    begin
      if (Block <> nil) and (Block.IsValid) then
      begin                           // ������ѡ����ı�
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(Block.StartingColumn,
          Block.StartingRow), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(Block.EndingColumn,
          Block.EndingRow), View);
      end;
    end
    else
    begin
      StartPos := 0;
      Stream := TMemoryStream.Create;
      try
        CnOtaSaveCurrentEditorToStream(Stream, False);
        EndPos := Stream.Size; // �ñ��취�õ��༭�ĳ���
      finally
        Stream.Free;
      end;
    end;
    
    Result := True;
  end;
end;

function DoGetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: AnsiString;
  Res: string;
  Buf: PAnsiChar;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos, Len, ReadStart, ASize: Integer;
  Reader: IOTAEditReader;
  NewRow, NewCol: Integer;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('DoGetEditorLines: StartPos %d, EndPos %d.', [StartPos, EndPos]);
{$ENDIF}

    Len := EndPos - StartPos;
    Assert(Len >= 0);
    SetLength(Text, Len);
    Buf := Pointer(Text);
    ReadStart := StartPos;

    Reader := View.Buffer.CreateReader;
    try
      while Len > SCnOtaBatchSize do // ��ζ�ȡ
      begin
        ASize := Reader.GetText(ReadStart, Buf, SCnOtaBatchSize);
        Inc(Buf, ASize);
        Inc(ReadStart, ASize);
        Dec(Len, ASize);
      end;
      if Len > 0 then // �����ʣ���
        Reader.GetText(ReadStart, Buf, Len);
    finally
      Reader := nil;
    end;                  

    {$IFDEF UNICODE}
    Res := ConvertEditorTextToTextW(Text); // Unicode �²����� Ansi ת���Ա��ⶪ�ַ�
    {$ELSE}
    Res := ConvertEditorTextToText(Text);
    {$ENDIF}

    // 10.1 �����ϵĽű�ר�Ҵ����� TStringList���� LineBreak ���Ի�Ī�������գ���һ��
{$IFDEF DELPHI101_BERLIN_UP}
    if Lines.LineBreak <> sLineBreak then
      Lines.LineBreak := sLineBreak;
{$ENDIF}

    Lines.Text := Res;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('DoGetEditorLines Get %d Lines.', [Lines.Count]);
{$ENDIF}
    Result := Text <> '';
  end;
end;

function DoSetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: string;
  S: AnsiString;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos: Integer;
  Writer: IOTAEditWriter;
  NewRow, NewCol: Integer;
{$IFDEF TSTRINGS_HAS_OPTIONS}
  T: Boolean;
{$ENDIF}
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;

{$IFDEF TSTRINGS_HAS_OPTIONS}
    T := Lines.TrailingLineBreak;
    Lines.TrailingLineBreak := True; // Ҫ����ĩβ�Ļس����������һ�б�������
{$ENDIF}
    Text := StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]);
{$IFDEF TSTRINGS_HAS_OPTIONS}
    Lines.TrailingLineBreak := T;
{$ENDIF}

    Writer := View.Buffer.CreateUndoableWriter;
    try
      Writer.CopyTo(StartPos);
  {$IFDEF UNICODE}
      S := ConvertTextToEditorTextW(Text);
  {$ELSE}
      S := ConvertTextToEditorText(Text);
  {$ENDIF}
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Insert %d AnsiChars to %d -> %d', [Length(S), StartPos, EndPos]);
{$ENDIF}
      Writer.Insert(PAnsiChar(S));
      Writer.DeleteTo(EndPos);
    finally
      Writer := nil;
    end;                

    if (NewRow > 0) and (NewCol > 0) then
    begin
      View.CursorPos := OTAEditPos(NewCol, NewRow);
    end
    else if (BlockStartLine > 0) and (BlockEndLine > 0) then
    begin
      CnOtaSelectBlock(View.Buffer, OTACharPos(0, BlockStartLine),
        OTACharPos(0, BlockEndLine));
    end;

    Result := True;
  end;
end;

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smLine, Lines);
end;

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSelText, Lines);
end;

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSource, Lines);
end;

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smLine, Lines);
end;

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSelText, Lines);
end;

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSource, Lines);
end;

function IdeInsertTextIntoEditor(const Text: string): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaInsertTextIntoEditor(Text);
    Result := True;
  end
  else
    Result := False;  
end;
  
function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
var
  EditPos: TOTAEditPos;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    EditPos := CnOtaGetEditPos(CnOtaGetTopMostEditView);
    Col := EditPos.Col;
    Line := EditPos.Line;
    Result := True;
  end
  else
    Result := False;
end;

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaGotoEditPos(OTAEditPos(Col, Line), CnOtaGetTopMostEditView, Middle);
    Result := True;
  end
  else
    Result := False;
end;

function IdeGetBlockIndent: Integer;
begin
  Result := CnOtaGetBlockIndent;
end;  

function IdeGetSourceByFileName(const FileName: string): string;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Strm, True); // Ansi/Ansi/Utf16
    // �õ� Ansi/Ansi/Utf16 ���ݣ���Ӧֱ��ת�� string
    Result := string(PChar(Strm.Memory));
  finally
    Strm.Free;
  end;
end;

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
var
  Strm: TMemoryStream;
begin
  Result := False;
  if OpenInIde and not CnOtaOpenFile(FileName) then
    Exit;
    
  if CnOtaIsFileOpen(FileName) then
  begin
    Strm := TMemoryStream.Create;
    try
      Source.SaveToStream(Strm);
      Strm.Position := 0;
      with TCnEditFiler.Create(FileName) do
      try
        ReadFromStream(Strm);
      finally
        Free;
      end;
    finally
      Strm.Free;
    end;
  end
  else
    Source.SaveToFile(FileName);
  Result := True;
end;  

// �жϱ�ʶ���Ƿ��ڹ����
function IsGeneralCurrentToken(AView: Pointer; AControl: TControl;
  Token: TCnGeneralPasToken): Boolean;
begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Result := IsCurrentTokenW(AView, AControl, Token);
{$ELSE}
  Result := IsCurrentToken(AView, AControl, Token);
{$ENDIF}
end;

// �жϱ�ʶ���Ƿ��ڹ���£����汾����ʹ��
function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
var
{$IFDEF BDS}
  Text: AnsiString;
{$ENDIF}
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;

  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // �кŲ���ʱֱ���˳�
  begin
    Result := False;
    Exit;
  end;

  // ����Ȳ���Ҫ���������ݽ��бȽϣ����� Col ��ֱ�۵� Ansi ���˫�ֽ��ַ�ռ 2 ��
{$IFDEF BDS}
  Text := AnsiString(GetStrProp(AControl, 'LineText')); // D2009 ���� Unicode Ҳ��ת���� Ansi
  if Text <> '' then
  begin
    // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
    // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

    {$IFNDEF UNICODE}
    // D2005~2007 ��õ��� Utf8 �ַ�������Ҫת��Ϊ Ansi ���ܽ���ֱ���бȽ�
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    {$ENDIF}
  end;
{$ENDIF}
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(Token.Token));
end;

// �жϱ�ʶ���Ƿ��ڹ���£�ʹ�� WideToken���ɹ� Unicode/Utf8 �����µ���
function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
var
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;

  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // �кŲ���ʱֱ���˳�
  begin
    Result := False;
    Exit;
  end;

  // ����Ȳ���Ҫ�Ƚ��У��������� CursorPos �� ANSI �Ĺ��λ�ã�
  // ���Եð� Utf16 ת�� Ansi ���Ƚ�
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol +
    CalcAnsiDisplayLengthFromWideString(Token.Token));
end;

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

// ȡ�ô���༭�����������FormEditor Ϊ nil ��ʾȡ��ǰ����
function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
  Result := CnOtaGetFormDesigner(FormEditor);
end;  

// ȡ�õ�ǰ��ƵĴ���
function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
begin
  Result := nil;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;
    
  {$IFDEF COMPILER6_UP}
    if Designer.Root is TCustomForm then
      Result := TCustomForm(Designer.Root);
  {$ELSE}
    Result := Designer.Form;
  {$ENDIF}
  except
    ;
  end;
end;

// ȡ�õ�ǰ��ƴ�������ѡ������
function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
var
  I: Integer;
  AObj: TPersistent;
  AList: IDesignerSelections;
begin
  Result := False;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;

    if Selections <> nil then
    begin
      Selections.Clear;
      AList := CreateSelectionList;
      Designer.GetSelections(AList);
      for I := 0 to AList.Count - 1 do
      begin
      {$IFDEF COMPILER6_UP}
        AObj := TPersistent(AList[I]);
      {$ELSE}
        AObj := TryExtractPersistent(AList[I]);
      {$ENDIF}
        if AObj <> nil then // perhaps is nil when disabling packages in the IDE
          Selections.Add(AObj);
      end;

      if ExcludeForm and (Selections.Count = 1) and (Selections[0] =
        IdeGetDesignedForm(Designer)) then
        Selections.Clear;
    end;
    Result := True;
  except
    ;
  end;
end;

{$ENDIF}

// ȡ�õ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ
function IdeGetIsEmbeddedDesigner: Boolean;
{$IFDEF BDS}
{$IFNDEF DELPHI104_SYDNEY_UP}
var
  S: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF BDS}
  {$IFDEF DELPHI104_SYDNEY_UP} // 10.4.1 ���ϣ���Ƕ��ʽ�����ѡ�Ĭ�϶�Ƕ����
  Result := True;
  {$ELSE}
  S := CnOtaGetEnvironmentOptions.Values['EmbeddedDesigner'];
  Result := S = 'True';
  {$ENDIF}
{$ELSE}
  Result := False;  // D7 ���»� Lazarus ��֧��Ƕ��
{$ENDIF}
end;

//==============================================================================
// �޸��� GExperts Src 1.12 �� IDE ��غ���
//==============================================================================

// ���� IDE �����壨TAppBuilder �� TMainIDEBar��
function GetIDEMainForm: TCustomForm;
begin
  Assert(Assigned(Application));
{$IFDEF STAND_ALONE}
  Result := CnStubRefMainForm;
{$ELSE}
{$IFDEF LAZARUS}
  Result := Application.FindComponent('MainIDE') as TCustomForm;
{$ELSE}
  Result := Application.FindComponent('AppBuilder') as TCustomForm;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find IDE Main Form!');
{$ENDIF}
end;

{$IFDEF DELPHI_OTA}

// ȡ IDE �汾
function GetIDEEdition: string;
begin
  Result := '';

  with TRegistry.Create do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly(WizOptions.CompilerRegPath) then
    begin
      Result := ReadString('Version');
      CloseKey;
    end;
  finally
    Free;
  end;
end;

// ������������󣬿���Ϊ��
function GetComponentPaletteTabControl: TTabControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent('TabControl') as TTabControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find ComponentPalette TabControl!');
{$ENDIF}
end;

// ���� 2010 �����ϵ����������ϰ벿�� Tab ���󣬿���Ϊ��
function GetNewComponentPaletteTabControl: TWinControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPaletteTabName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find New ComponentPalette TabControl!');
{$ENDIF}
end;

// ���� 2010 �����ϵ����������°벿����������б���������󣬿���Ϊ��
function GetNewComponentPaletteComponentPanel: TWinControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find New ComponentPalette Panel!');
{$ENDIF}
end;

// ���ر༭�������·���״̬��������Ϊ��
function GetEditWindowStatusBar(EditWindow: TCustomForm = nil): TStatusBar;
var
  AComp: TComponent;
begin
  Result := nil;
  if EditWindow = nil then
    EditWindow := CnOtaGetCurrentEditWindow;

  if EditWindow = nil then
    Exit;

  AComp := EditWindow.FindComponent(SCnEditorStatusBarName);
  if (AComp <> nil) and (AComp is TStatusBar) then
    Result := AComp as TStatusBar;
end;

// ���ض����������壬����Ϊ��
function GetObjectInspectorForm: TCustomForm;
begin
  Result := GetIDEMainForm;
  if Result <> nil then  // �󲿷ְ汾�� ObjectInspector �� AppBuilder ���ӿؼ�
    Result := TCustomForm(Result.FindComponent(SCnPropertyInspectorName));
  if Result = nil then // D2007 ��ĳЩ�汾�� ObjectInspector �� Application ���ӿؼ�
    Result := TCustomForm(Application.FindComponent(SCnPropertyInspectorName));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find Object Inspector!');
{$ENDIF}
end;

// �����������Ҽ��˵�������Ϊ��
function GetComponentPalettePopupMenu: TPopupMenu;
var
  MainForm: TCustomForm;
begin
  Result := nil;
  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    Result := TPopupMenu(MainForm.FindComponent('PaletteMenu'));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find PaletteMenu!');
{$ENDIF}
end;

// �������������ڵ�ControlBar������Ϊ��
function GetComponentPaletteControlBar: TControlBar;
var
  MainForm: TCustomForm;
  I: Integer;
begin
  Result := nil;

  MainForm := GetIDEMainForm;
  if MainForm <> nil then
    for I := 0 to MainForm.ComponentCount - 1 do
      if MainForm.Components[I] is TControlBar then
      begin
        Result := MainForm.Components[I] as TControlBar;
        Break;
      end;
      
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsgError('Unable to Find ControlBar!');
{$ENDIF}
end;

function GetExpandableEvalViewForm: TCustomForm;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if Screen.CustomForms[I].ClassNameIs(SCnExpandableEvalViewClassName) then
    begin
      Result := Screen.CustomForms[I];
      Exit;
    end;
  end;
  Result := nil;
end;

function GetIDEInsightBar: TWinControl;
{$IFDEF IDE_HAS_INSIGHT}
var
  MainForm: TCustomForm;
  AComp: TComponent;
{$ENDIF}
begin
  Result := nil;
{$IFDEF IDE_HAS_INSIGHT}
  MainForm := GetIDEMainForm;
  if MainForm <> nil then
  begin
    AComp := MainForm.FindComponent(SCnIDEInsightBarName);
    if (AComp is TWinControl) and (AComp.ClassNameIs(SCnIDEInsightBarClassName)) then
      Result := TWinControl(AComp);
  end;
{$ENDIF}
end;

// �������˵���߶�
function GetMainMenuItemHeight: Integer;
{$IFDEF COMPILER7_UP}
var
  MainForm: TCustomForm;
  Component: TComponent;
{$ENDIF}
begin
{$IFDEF COMPILER7_UP}
  Result := 23;
  MainForm := GetIDEMainForm;
  Component := nil;
  if MainForm <> nil then
    Component := MainForm.FindComponent('MenuBar');
  if (Component is TControl) then
    Result := TControl(Component).ClientHeight; // This is approximate?
{$ELSE}
  Result := GetSystemMetrics(SM_CYMENU);
{$ENDIF}
end;

{$ENDIF}

// �ж�ָ�������Ƿ�������ڴ���
function IsIdeDesignForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (csDesigning in AForm.ComponentState);
end;

// �ж�ָ�������Ƿ�༭������
function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and
{$IFDEF LAZARUS}
            (AForm.Name = SCnEditorFormName) and
{$ELSE}
            (Pos(SCnEditorFormNamePrefix, AForm.Name) = 1) and
{$ENDIF}
            (AForm.ClassName = SCnEditorFormClassName) and
            (not (csDesigning in AForm.ComponentState));
end;

// ��Դ��༭����Ϊ��Ծ
procedure BringIdeEditorFormToFront;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      Screen.CustomForms[I].BringToFront;
      Exit;
    end;
  end;
end;

// ȡ�Ѱ�װ�İ������
procedure GetInstalledComponents(Packages, Components: TStrings);
{$IFNDEF STAND_ALONE}
var
{$IFDEF FPC}
  Pkg: TIDEPackage;
  Comp: TRegisteredComponent;
{$ELSE}
  PackSvcs: IOTAPackageServices;
{$ENDIF}
  I, J: Integer;
{$ENDIF}
begin
  if Assigned(Packages) then
    Packages.Clear;
  if Assigned(Components) then
    Components.Clear;
{$IFNDEF STAND_ALONE}
{$IFDEF FPC}
  for I := 0 to PackageEditingInterface.GetPackageCount - 1 do
  begin
    Pkg := PackageEditingInterface.GetPackages(I);
    if Assigned(Packages) then
      Packages.Add(Pkg.Name);

    if Assigned(Components) then
    begin
      for J := 0 to IDEComponentPalette.Comps.Count - 1 do
      begin
        Comp := IDEComponentPalette.Comps[J];
        Components.Add(Comp.ComponentClass.ClassName);
      end;
    end;
  end;
{$ELSE}
  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    if Assigned(Packages) then
      Packages.Add(PackSvcs.PackageNames[I]);
    if Assigned(Components) then
    begin
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        Components.Add(PackSvcs.ComponentNames[I, J]);
    end;
  end;
{$ENDIF}
{$ENDIF}
end;

// �ж�ָ���ؼ��Ƿ����༭���ؼ�
function IsEditControl(AControl: TComponent): Boolean;
{$IFDEF USE_CODEEDITOR_SERVICE}
var
  CES: INTACodeEditorServices;
{$ENDIF}
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if (AControl is TWinControl) and Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    Result := CES.IsIDEEditor(TWinControl(AControl));
{$ELSE}
  Result := (AControl <> nil) and AControl.ClassNameIs(SCnEditControlClassName)
    and {$IFDEF LAZARUS} (Pos(SCnEditControlNamePrefix, AControl.Name) = 1)
    {$ELSE} SameText(AControl.Name, SCnEditControlName) {$ENDIF};
{$ENDIF}
end;

// ö�� IDE �еĴ���༭�����ں� EditControl �ؼ������ûص���������������
function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean): Integer;
var
  I: Integer;
  EditWindow: TCustomForm;
  EditControl: TControl;
{$IFDEF LAZARUS}
  J: Integer;
  List: TObjectList;
{$ENDIF}
begin
  Result := 0;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      EditWindow := Screen.CustomForms[I];
{$IFDEF LAZARUS}
      List := TObjectList.Create(False);
      try
        GetEditControlsFromEditorForm(EditWindow, List);
        if List.Count > 0 then
        begin
          for J := 0 to List.Count - 1 do
          begin
            EditControl := TControl(List[J]);
            if Assigned(EditControl) or not EditorMustExists then
            begin
              Inc(Result);
              if Assigned(Proc) then
                Proc(EditWindow, EditControl, Context);
            end;
          end;
        end;
      finally
        List.Free;
      end;
{$ELSE}
      EditControl := GetEditControlFromEditorForm(EditWindow);
      if Assigned(EditControl) or not EditorMustExists then
      begin
        Inc(Result);
        if Assigned(Proc) then
          Proc(EditWindow, EditControl, Context);
      end;
{$ENDIF}
    end;
  end;
end;

{$IFDEF LAZARUS}

// Lazarus �·��ر༭�����ڵı༭���ؼ��б�
function GetEditControlsFromEditorForm(AForm: TCustomForm; EditControls: TObjectList): Integer;
var
  I: Integer;
begin
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is TControl then
    begin
      if IsEditControl(AForm.Components[I]) then
        EditControls.Add(AForm.Components[I]);
    end;
  end;

  Result := EditControls.Count;
end;

{$ELSE}

// ���ر༭�����ڵı༭���ؼ�
function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
begin
{$IFDEF LAZARUS}
  Result := TControl(FindComponentByClassName(AForm, SCnEditControlClassName));
  if Result <> nil then
    if Pos(SCnEditControlNamePrefix, Result.Name) <> 1 then
      Result := nil;
{$ELSE}
  Result := TControl(FindComponentByClassName(AForm, SCnEditControlClassName,
    SCnEditControlName));
{$ENDIF}
end;

{$ENDIF}

// ���ص�ǰ�Ĵ���༭���ؼ�
function GetCurrentEditControl: TControl;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  I: Integer;
  EditWindow: TCustomForm;
  Pgc: TPageControl;
  Tb: TTabSheet;
{$ELSE}
  View: IOTAEditView;
{$ENDIF}
{$ENDIF}
begin
  Result := nil;
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      EditWindow := Screen.CustomForms[I];
      Pgc := TPageControl(FindComponentByClassName(EditWindow,
        SCnEditWindowPageControlClassName, SCnEditWindowPageControlName));
      if Pgc <> nil then
      begin
        Tb := Pgc.ActivePage;
        if Tb <> nil then
          Result := TControl(FindControlByClassName(Tb, SCnEditControlClassName));
      end;
    end;
  end;
{$ELSE}
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.GetEditWindow <> nil) then
    Result := GetEditControlFromEditorForm(View.GetEditWindow.Form);
{$ENDIF}
{$ENDIF}
end;

type
  TCnProjPathType = (pptSrc, pptUnit, pptLib, pptInclude);
  {* pptSrc �� pptUnit ��Ӧ UnitDir��Ҳ���� Unit Search Path��
     pptInclude ��Ӧ IncludeDir��Ҳ���� $I �ȵ��ļ�}

procedure AddProjectPath(Project: TCnIDEProjectInterface; Paths: TStrings; PathType: TCnProjPathType);
{$IFNDEF STAND_ALONE}
var
  IDStr, APath: string;
  APaths: TStrings;
  I: Integer;

  function GetProjPathIDFromType(APathType: TCnProjPathType): string;
  begin
    case APathType of
      pptSrc: Result := 'SrcDir';
      pptUnit: Result := 'UnitDir';
      pptLib: Result := 'LibPath';
      pptInclude: Result := 'IncludePath';
    else
      Result := 'LibPath';
    end;
  end;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if not Assigned(Project.LazCompilerOptions) then
    Exit;

  case PathType of
    pptSrc: APath := Project.LazCompilerOptions.SrcPath;
    pptUnit: APath := Project.LazCompilerOptions.OtherUnitFiles;
    pptLib: APath := Project.LazCompilerOptions.Libraries;
    pptInclude: APath := Project.LazCompilerOptions.IncludePath;
  end;

  if APath <> '' then
  begin
    // TODO: ���·�����滻��

    // ����·���е����·��
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for I := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[I]) <> '' then   // ��ЧĿ¼
        begin
          APath := MakePath(Trim(APaths[I]));
          if (Length(APath) > 2) and (APath[2] = ':') then // ȫ·��Ŀ¼
          begin
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end
          else  // ���·��
          begin
            APath := LinkPath(_CnExtractFilePath(Project.Directory), APath);
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;
{$ELSE}
  if not Assigned(Project.ProjectOptions) then
    Exit;

  IDStr := GetProjPathIDFromType(PathType);
  APath := Project.ProjectOptions.GetOptionValue(IdStr);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('AddProjectPath: %s '#13#10 + APath, [IdStr]);
{$ENDIF}

  if APath <> '' then
  begin
    APath := ReplaceToActualPath(APath, Project); // ���·��Ҳһ���滻

    // ����·���е����·��
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for I := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[I]) <> '' then   // ��ЧĿ¼
        begin
          APath := MakePath(Trim(APaths[I]));
          if (Length(APath) > 2) and (APath[2] = ':') then // ȫ·��Ŀ¼
          begin
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end
          else                          // ���·��
          begin
            APath := LinkPath(_CnExtractFilePath(Project.FileName), APath);
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;
{$ENDIF}
{$ENDIF}
end;

// ȡ���������е� LibraryPath ���ݣ�ע�� XE2 ���ϰ汾��GetEnvironmentOptions ��ͷ
// �õ���ֵ�����ǵ�ǰ���̵� Platform ��Ӧ��ֵ������ֻ�ܸĳɸ��ݹ���ƽ̨��ע��������
procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean);
var
{$IFDEF DELPHI_OTA}
  Svcs: IOTAServices;
  Options: IOTAEnvironmentOptions;
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform: string;
  Project: IOTAProject;
{$ENDIF}
{$ENDIF}
  Text: string;
  List: TStrings;


  procedure AddList(AList: TStrings);
  var
    S: string;
    I: Integer;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      S := Trim(MakePath(AList[I]));
      if (S <> '') and (Paths.IndexOf(S) < 0) then
        Paths.Add(S);
    end;
  end;

begin
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if IDEEnvironmentOptions = nil then
    Exit;
{$ELSE}
  Svcs := BorlandIDEServices as IOTAServices;
  if not Assigned(Svcs) then Exit;
  Options := Svcs.GetEnvironmentOptions;
  if not Assigned(Options) then Exit;

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform := '';
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    CurPlatform := Project.CurrentPlatform;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Project.CurrentPlatform  is ' + CurPlatform);
  {$ENDIF}
  end;
{$ENDIF}
{$ENDIF}

  List := TStringList.Create;
  try
{$IFDEF LAZARUS}
    // �û������ FPC �� source Ŀ¼���Լ� lcl Ŀ¼
    Text := LinkPath(_CnExtractFilePath(IDEEnvironmentOptions.GetParsedCompilerFilename), '..\..\source\rtl\');
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    Text := MakePath(IDEEnvironmentOptions.GetParsedLazarusDirectory) + 'lcl\';
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    Text := MakePath(IDEEnvironmentOptions.GetParsedLazarusDirectory) + 'components\';
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);
{$ELSE}
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Search Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('LibraryPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Browsing Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('BrowsingPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);
{$ENDIF}

    if IncludeProjectPath then
    begin
      GetProjectLibPath(List);
      AddList(List);
    end;
  finally
    List.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
{$ENDIF}
{$ENDIF}
end;

// ȡ��ǰ���������� Path ����
procedure GetProjectLibPath(Paths: TStrings);
var
{$IFDEF DELPHI_OTA}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
  Project: TCnIDEProjectInterface;
  Path: string;
  I, J: Integer;
  APaths: TStrings;
begin
  Paths.Clear;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('GetProjectLibPath');
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  // �ѵ�ǰ���̵ļ���·�����ӽ���
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    AddProjectPath(Project, Paths, pptSrc);
    AddProjectPath(Project, Paths, pptUnit);
    AddProjectPath(Project, Paths, pptLib);
    AddProjectPath(Project, Paths, pptInclude);

    for I := 0 to Project.FileCount - 1 do
    begin
      Path := _CnExtractFileDir(Project.Files[I].Filename);
      if Paths.IndexOf(Path) < 0 then
        Paths.Add(Path);
    end;
  end;

{$ELSE}
  // ����ǰ�������е�·������
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
  begin
    APaths := TStringList.Create;
    try
      for I := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[I];
        if Assigned(Project) then
        begin
          // ���ӹ�������·��
          AddProjectPath(Project, Paths, pptSrc);
          AddProjectPath(Project, Paths, pptUnit);
          AddProjectPath(Project, Paths, pptLib);
          AddProjectPath(Project, Paths, pptInclude);

          // ���ӹ������ļ���·��
          for J := 0 to Project.GetModuleCount - 1 do
          begin
            Path := _CnExtractFileDir(Project.GetModule(J).FileName);
            if Paths.IndexOf(Path) < 0 then
              Paths.Add(Path);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;
{$ENDIF}
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
  CnDebugger.LogLeave('GetProjectLibPath');
{$ENDIF}
end;

function GetProjectDcuPath(AProject: TCnIDEProjectInterface): string;
begin
{$IFDEF STAND_ALONE}
  Result := '';
{$ELSE}
{$IFDEF LAZARUS}
  if (AProject <> nil) and (AProject.LazCompilerOptions <> nil) then
  begin
    Result := AProject.LazCompilerOptions.GetUnitOutputDirectory(True);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
  {$ENDIF}
  end;
{$ELSE}
  if (AProject <> nil) and (AProject.ProjectOptions <> nil) then
  begin
    Result := ReplaceToActualPath(AProject.ProjectOptions.Values['UnitOutputDir'], AProject);
    if Result <> '' then
      Result := MakePath(LinkPath(_CnExtractFilePath(AProject.FileName), Result));
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
  {$ENDIF}
  end
  else
    Result := '';
{$ENDIF}
{$ENDIF}
end;

// ȡ��ǰ�༭���ڶ���ҳ�����ͣ�����༭�����ؼ�
function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
var
  I: Integer;
  Ctrl: TControl;
begin
  // ��ͷ������һ�� Align �� Client �Ķ������Ǳ༭������ʾ
  Result := epOthers;
  for I := AControl.ControlCount - 1 downto 0 do
  begin
    Ctrl := AControl.Controls[I];
    if Ctrl.Visible and (Ctrl.Align = alClient) then
    begin
      if Ctrl.ClassNameIs(SCnEditControlClassName) then
        Result := epCode
      else if Ctrl.ClassNameIs(SCnDisassemblyViewClassName) then
        Result := epCPU
      else if Ctrl.ClassNameIs(SCnDesignControlClassName) then
        Result := epDesign
      else if Ctrl.ClassNameIs(SCnWelcomePageClassName) then
        Result := epWelcome;
      Break;
    end;
  end;
end;

// �ж�һ Control �Ƿ�������� Control
function IsDesignControl(AControl: TControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl is TControl) and
    (csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
    not (AControl is TCustomForm) and not (AControl is TCustomFrame) and
    ((AControl.Owner is TCustomForm) or (AControl.Owner is TCustomFrame)) and
    (csDesigning in AControl.Owner.ComponentState);
end;

// �ж�һ WinControl �Ƿ�������� Control
function IsDesignWinControl(AControl: TWinControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl is TWinControl) and
    (csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
    not (AControl is TCustomForm) and not (AControl is TCustomFrame) and
    ((AControl.Owner is TCustomForm) or (AControl.Owner is TCustomFrame)) and
    (csDesigning in AControl.Owner.ComponentState);
end;

// �ж�ָ���ؼ��Ƿ�༭�����ڵ� TabControl �ؼ�
function IsXTabControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(SCnXTabControlClassName)
    and SameText(AControl.Name, SCnXTabControlName);
end;

{$IFDEF DELPHI_OTA}

procedure CloseExpandableEvalViewForm;
var
  F: TCustomForm;
begin
  F := GetExpandableEvalViewForm;
  if F <> nil then
    F.Close;
end;

// �ж� IDE �Ƿ��ǵ�ǰ�Ļ����
function IDEIsCurrentWindow: Boolean;
begin
  Result := GetCurrentThreadId = GetWindowThreadProcessId(GetForegroundWindow, nil);
end;

//==============================================================================
// ������ IDE ��غ���
//==============================================================================

// ȡ��������װĿ¼
function GetInstallDir: string;
begin
  Result := _CnExtractFileDir(_CnExtractFileDir(Application.ExeName));
end;

{$IFDEF BDS}
// ȡ�� BDS (Delphi8/9������) ���û�����Ŀ¼
function GetBDSUserDataDir: string;
const
  CSIDL_LOCAL_APPDATA = $001c;
begin
  Result := MakePath(GetSpecialFolderLocation(CSIDL_LOCAL_APPDATA));
{$IFDEF DELPHI8}
  Result := Result + 'Borland\BDS\2.0';
{$ELSE}
{$IFDEF DELPHI9}
  Result := Result + 'Borland\BDS\3.0';
{$ELSE}
{$IFDEF DELPHI10}
  Result := Result + 'Borland\BDS\4.0';
{$ELSE}
{$IFDEF DELPHI11}
  Result := Result + 'CodeGear\RAD Studio\5.0';
{$ELSE}
{$IFDEF DELPHI12}
  Result := Result + 'CodeGear\RAD Studio\6.0';
{$ELSE}
{$IFDEF DELPHI14}
  Result := Result + 'CodeGear\RAD Studio\7.0';
{$ELSE}
{$IFDEF DELPHI15}
  Result := Result + 'Embarcadero\BDS\8.0';
{$ELSE}
{$IFDEF DELPHI16}
  Result := Result + 'Embarcadero\BDS\9.0';
{$ELSE}
{$IFDEF DELPHI17}
  Result := Result + 'Embarcadero\BDS\10.0';
{$ELSE}
{$IFDEF DELPHIXE4}
  Result := Result + 'Embarcadero\BDS\11.0';
{$ELSE}
{$IFDEF DELPHIXE5}
  Result := Result + 'Embarcadero\BDS\12.0';
{$ELSE}
{$IFDEF DELPHIXE6}
  Result := Result + 'Embarcadero\BDS\14.0';
{$ELSE}
{$IFDEF DELPHIXE7}
  Result := Result + 'Embarcadero\BDS\15.0';
{$ELSE}
{$IFDEF DELPHIXE8}
  Result := Result + 'Embarcadero\BDS\16.0';
{$ELSE}
{$IFDEF DELPHI10_SEATTLE}
  Result := Result + 'Embarcadero\BDS\17.0';
{$ELSE}
{$IFDEF DELPHI101_BERLIN}
  Result := Result + 'Embarcadero\BDS\18.0';
{$ELSE}
{$IFDEF DELPHI102_TOKYO}
  Result := Result + 'Embarcadero\BDS\19.0';
{$ELSE}
{$IFDEF DELPHI103_RIO}
  Result := Result + 'Embarcadero\BDS\20.0';
{$ELSE}
{$IFDEF DELPHI104_SYDNEY}
  Result := Result + 'Embarcadero\BDS\21.0';
{$ELSE}
{$IFDEF DELPHI110_ALEXANDRIA}
  Result := Result + 'Embarcadero\BDS\22.0';
{$ELSE}
{$IFDEF DELPHI120_ATHENS}
  Result := Result + 'Embarcadero\BDS\23.0';
{$ELSE}
{$IFDEF DELPHI130_FLORENCE}
  Result := Result + 'Embarcadero\BDS\37.0';
{$ELSE}
  Error: Unknown Compiler
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;
{$ENDIF}

// ����ģ������������ļ���
function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
var
  SearchType: TCnModuleSearchType;
begin
  SearchType := mstInvalid;
  Result := GetFileNameSearchTypeFromModuleName(AName, SearchType, AProject);
end;

// ����ģ������������ļ����Լ�������һ������Ŀ¼��
function GetFileNameSearchTypeFromModuleName(AName: string;
  var SearchType: TCnModuleSearchType; AProject: IOTAProject = nil): string;
var
  Paths: TStringList;
  I, ProjectSrcIdx: Integer;
  Ext, ProjectPath: string;
begin
  if AProject = nil then
    AProject := CnOtaGetCurrentProject;

  Ext := LowerCase(_CnExtractFileExt(AName));
  if (Ext = '') or (Ext <> '.pas') then
    AName := AName + '.pas';

  Result := '';
  SearchType := mstInvalid;

  // �ڹ���ģ���в���
  if AProject <> nil then
  begin
    for I := 0 to AProject.GetModuleCount - 1 do
    begin
      if SameFileName(_CnExtractFileName(AProject.GetModule(I).FileName), AName) then
      begin
        Result := AProject.GetModule(I).FileName;
        SearchType := mstInProject;
        Exit;
      end;
    end;

    ProjectPath := MakePath(_CnExtractFilePath(AProject.FileName));
    if FileExists(ProjectPath + AName) then
    begin
      Result := ProjectPath + AName;
      SearchType := mstInProject;
      Exit;
    end;
  end;

  Paths := TStringList.Create;
  try
    if Assigned(AProject) then  // ���빤������·��
      AddProjectPath(AProject, Paths, pptSrc);

    ProjectSrcIdx := Paths.Count; // ǰ ProjectSrcIdx ����Ҳ���� 0 �� ProjectSrcIdx - 1 �ǹ�������·��

    // ����ϵͳ����·��
    GetLibraryPath(Paths, False);

    for I := 0 to Paths.Count - 1 do
    begin
      if FileExists(MakePath(Paths[I]) + AName) then
      begin
        Result := MakePath(Paths[I]) + AName;
        if I >= ProjectSrcIdx then        // ϵͳ·�����ҵ���
          SearchType := mstSystemSearch
        else
          SearchType := mstProjectSearch; // ����·�����ҵ���
        Exit;
      end;
    end;
  finally
    Paths.Free;
  end;
end;

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
var
  Options: IOTAProjectOptions;
  PKeys: Integer;
begin
  Result := nil;
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then Exit;
  PKeys := Options.GetOptionValue('Keys');
{$IFDEF DEBUG}
  CnDebugger.LogInteger(PKeys, 'CnOtaGetVersionInfoKeys');
{$ENDIF}
  Result := Pointer(PKeys);
end;

// ���빤�̣����ر����Ƿ�ɹ�
function CompileProject(AProject: IOTAProject): Boolean;
begin
  Result := not AProject.ProjectBuilder.ShouldBuild or
    AProject.ProjectBuilder.BuildProject(cmOTAMake, False);
end;

// ���ص�ǰ���ڱ���Ĺ��̣�ע�ⲻһ���ǵ�ǰ����
function GetCurrentCompilingProject: IOTAProject;
begin
  Result := CnWizNotifierServices.GetCurrentCompilingProject;
end;

// ȡ����������ڵĵ�Ԫ��
function GetComponentUnitName(const ComponentName: string): string;
var
  ClassRef: TClass;
  TypeData: PTypeData;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('GetComponentUnitName: ' + ComponentName);
{$ENDIF}

  Result := '';
  ClassRef := GetClass(ComponentName);

  if Assigned(ClassRef) then
  begin
    TypeData := GetTypeData(PTypeInfo(ClassRef.ClassInfo));
    Result := string(TypeData^.UnitName);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('UnitName: ' + Result);
  {$ENDIF}
  end;
end;

function GetIDERegistryFont(const RegItem: string; AFont: TFont;
  out BackgroundColor: TColor; CheckBackDef: Boolean): Boolean;
const
  SCnIDEFontName = 'Editor Font';
  SCnIDEFontSize = 'Font Size';

  SCnIDEBold = 'Bold';
  SCnIDEDefaultBackground = 'Default Background';

  {$IFDEF COMPILER7_UP}
  SCnIDEForeColor = 'Foreground Color New';
  SCnIDEBackColor = 'Background Color New';
  {$ELSE}
  SCnIDEForeColor = 'Foreground Color';
  SCnIDEBackColor = 'Background Color';
  {$ENDIF}
  SCnIDEItalic = 'Italic';
  SCnIDEUnderline = 'Underline';
var
  S: string;
  Reg: TRegistry;
  Size: Integer;
{$IFDEF COMPILER7_UP}
  AColorStr: string;
{$ENDIF}
  AColor: Integer;

  function ReadBoolReg(Reg: TRegistry; const RegName: string): Boolean;
  var
    S: string;
  begin
    Result := False;
    if Reg <> nil then
    begin
      try
        S := Reg.ReadString(RegName);
        if (UpperCase(S) = 'TRUE') or (S = '1') then
          Result := True;
      except
        ;
      end;
    end;
  end;

begin
  // ��ĳ��ע���������ĳ�����岢��ֵ�� AFont
  Result := False;
  if WizOptions = nil then
    Exit;

  if AFont <> nil then
  begin
    Reg := nil;
    try
      Reg := TRegistry.Create;
      Reg.RootKey := HKEY_CURRENT_USER;
      try
        if RegItem = '' then // �ǻ������壬û�ж���ɫ����
        begin
          if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Options') then
          begin
            if Reg.ValueExists(SCnIDEFontName) then
            begin
              S := Reg.ReadString(SCnIDEFontName);
              if S <> '' then AFont.Name := S;
            end;
            if Reg.ValueExists(SCnIDEFontSize) then
            begin
              Size := Reg.ReadInteger(SCnIDEFontSize);
              if Size > 0 then AFont.Size := Size;
            end;
            Reg.CloseKey;
          end;
          Result := True; // ����������Ĭ������
        end
        else  // �Ǹ������壬��ǰ��ɫ��ȡ�ͱ���ɫ��ȡ����Ϊ TFont û�б���ɫ������� BackgroundColor ������
        begin
          AFont.Style := [];
          if Reg.OpenKeyReadOnly(Format(WizOptions.CompilerRegPath
            + '\Editor\Highlight\%s', [RegItem])) then
          begin
            if Reg.ValueExists(SCnIDEBold) and ReadBoolReg(Reg, SCnIDEBold) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsBold];
            end;
            if Reg.ValueExists(SCnIDEItalic) and ReadBoolReg(Reg, SCnIDEItalic) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsItalic];
            end;
            if Reg.ValueExists(SCnIDEUnderline) and ReadBoolReg(Reg, SCnIDEUnderline) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsUnderline];
            end;
            if Reg.ValueExists(SCnIDEForeColor) then
            begin
              Result := True;
{$IFDEF COMPILER7_UP}
              AColorStr := Reg.ReadString(SCnIDEForeColor);
              if IdentToColor(AColorStr, AColor) then
                AFont.Color := AColor
              else
                AFont.Color := StrToIntDef(AColorStr, 0);
{$ELSE}
              // D5/6 ����ɫ�� 16 ɫ������
              AColor := Reg.ReadInteger(SCnIDEForeColor);
              if AColor in [0..15] then
                AFont.Color := SCnColor16Table[AColor];
{$ENDIF}
            end;
            if Reg.ValueExists(SCnIDEBackColor) then
            begin
              Result := True;
{$IFDEF COMPILER7_UP}
              AColorStr := Reg.ReadString(SCnIDEBackColor);
              if IdentToColor(AColorStr, AColor) then
                BackgroundColor := AColor
              else
                BackgroundColor := StrToIntDef(AColorStr, 0);
{$ELSE}
              // D5/6 ����ɫ�� 16 ɫ������
              AColor := Reg.ReadInteger(SCnIDEBackColor);
              if AColor in [0..15] then
              begin
                if CheckBackDef then // ����Ŀ�Default Background Ϊ False ʱ��ʾ�б���ɫ����ѡ�����Ч���ŷ���
                begin
                  if Reg.ValueExists(SCnIDEDefaultBackground) then
                  begin
                    // ���� -1 ��Щ�ַ������� True
                    if LowerCase(Reg.ReadString(SCnIDEDefaultBackground)) = 'false' then
                      BackgroundColor := SCnColor16Table[AColor];
                  end;
                end
                else
                  BackgroundColor := SCnColor16Table[AColor];
              end;
{$ENDIF}
            end;
          end;
        end;
      except
        Result := False;
      end;
    finally
      Reg.Free;
    end;
  end;
end;

// ���ر༭�����ڵ� CPU �鿴���ؼ�
function GetCPUViewFromEditorForm(AForm: TCustomForm): TControl;
begin
  Result := TControl(FindComponentByClassName(AForm, SCnDisassemblyViewClassName,
    SCnDisassemblyViewName));
end;

// �ӱ༭���ؼ�����������ı༭�����ڵ�״̬��
function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
var
  AComp: TComponent;
begin
  Result := nil;
  if EditControl <> nil then
  begin
    AComp := FindComponentByClass(TWinControl(EditControl.Owner), TStatusBar, 'StatusBar');
    if AComp is TStatusBar then
      Result := AComp as TStatusBar;
  end;
end;

// ���ر༭�����ڵ� TabControl �ؼ�
function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
begin
  Result := TXTabControl(FindComponentByClassName(AForm, SCnXTabControlClassName,
    SCnXTabControlName));
end;

// ���ر༭�� TabControl �ؼ��� Tabs ����
function GetEditorTabTabs(ATab: TXTabControl): TStrings;
begin
  Result := nil;
  if ATab <> nil then
  begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
    Result := TStrings(GetObjectProp(ATab, 'Items'));
{$ELSE}
    Result := ATab.Tabs;
{$ENDIF}
  end;
end;

// ���ر༭�� TabControl �ؼ��� Index ����
function GetEditorTabTabIndex(ATab: TXTabControl): Integer;
begin
  Result := -1;
  if ATab <> nil then
  begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
    Result := GetOrdProp(ATab, 'TabIndex');
{$ELSE}
    Result := ATab.TabIndex;
{$ENDIF}
  end;
end;

// ��ȡ��ǰ��ǰ�˱༭�����﷨�༭��ť��ע���﷨�༭��ť���ڲ����ڿɼ�
function GetCurrentSyncButton: TControl;
var
  EditControl: TControl;
begin
  Result := nil;
  EditControl := GetCurrentEditControl;
  if EditControl <> nil then
    Result := TControl(EditControl.FindComponent(SSyncButtonName));
end;

// ��ȡ��ǰ��ǰ�˱༭�����﷨�༭��ť�Ƿ�ɼ����ް�ť�򲻿ɼ������� False
function GetCurrentSyncButtonVisible: Boolean;
var
  Button: TControl;
begin
  Result := False;
  Button := GetCurrentSyncButton;
  if Button <> nil then
    Result := Button.Visible;
end;

// ���ر༭���еĴ���ģ���Զ������
function GetCodeTemplateListBox: TControl;
begin
  Result := TControl(Application.FindComponent(SCodeTemplateListBoxName));
end;

// ���ر༭���еĴ���ģ���Զ�������Ƿ�ɼ����޻򲻿ɼ������� False
function GetCodeTemplateListBoxVisible: Boolean;
var
  Control: TControl;
begin
  Result := False;
  Control := GetCodeTemplateListBox;
  if Control <> nil then
    Result := Control.Visible;
end;

// ��ǰ�༭���Ƿ����﷨��༭ģʽ�£���֧�ֻ��ڿ�ģʽ�·��� False
function IsCurrentEditorInSyncMode: Boolean;
{$IFDEF IDE_SYNC_EDIT_BLOCK}
var
  View: IOTAEditView;
{$ENDIF}
begin
  Result := False;
{$IFDEF IDE_SYNC_EDIT_BLOCK}
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.Block <> nil) then
    Result := View.Block.SyncMode <> smNone;
{$ENDIF}
end;

// ��ǰ�Ƿ��ڼ��̺��¼�ƻ�طţ���֧�ֻ��ڷ��� False
function IsKeyMacroRunning: Boolean;
var
  Key: IOTAKeyboardServices;
  Rec: IOTARecord;
begin
  Result := False;
  if Supports(BorlandIDEServices, IOTAKeyboardServices, Key) then
  begin
    Rec := Key.CurrentPlayback;
    if Rec <> nil then
      Result := Rec.IsPlaying or Rec.IsRecording;
  end;
end;

var
  CorIdeModule: HMODULE;

procedure InitIdeAPIs;
begin
{$IFNDEF STAND_ALONE}
  CorIdeModule := LoadLibrary(CorIdeLibName);
  Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

{$IFDEF BDS4_UP}
  BeginBatchOpenCloseProc := GetProcAddress(CorIdeModule, SBeginBatchOpenCloseName);
  Assert(Assigned(BeginBatchOpenCloseProc), 'Failed to load BeginBatchOpenCloseProc from CorIdeModule');

  EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName);
{$IFNDEF WIN64}
{$IFDEF DELPHI120_ATHENS_UP}
  if not Assigned(EndBatchOpenCloseProc) then // D12.1 �����ˣ�����һ��
    EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName121);
{$ENDIF}
{$ENDIF}

  Assert(Assigned(EndBatchOpenCloseProc), 'Failed to load EndBatchOpenCloseProc from CorIdeModule');
{$ENDIF}
{$ENDIF}
end;

procedure FinalIdeAPIs;
begin
{$IFNDEF STAND_ALONE}
  if CorIdeModule <> 0 then
    FreeLibrary(CorIdeModule);
{$ENDIF}
end;

// ��ʼ�����򿪻�ر��ļ�
procedure BeginBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(BeginBatchOpenCloseProc) then
    BeginBatchOpenCloseProc;
{$ENDIF}
end;

// ���������򿪻�ر��ļ�
procedure EndBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(EndBatchOpenCloseProc) then
    EndBatchOpenCloseProc;
{$ENDIF}
end;

// �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNode ǿ��ת���ɹ��õ� TreeNode
function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
begin
{$IFDEF DEBUG}
  if not (Node is TTreeNode) then
  begin
  {$IFDEF WIN64}
    CnDebugger.LogFmt('Node ClassName %s. Value %16.16x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, NativeInt(Node)]);
  {$ELSE}
    CnDebugger.LogFmt('Node ClassName %s. Value %8.8x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, Integer(Node)]);
  {$ENDIF}
  end;
{$ENDIF}
  Result := TTreeNode(Node);
end;

// �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNodes ǿ��ת���ɹ��õ� TreeNodes
function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
begin
{$IFDEF DEBUG}
  if not (Nodes is TTreeNodes) then
  begin
  {$IFDEF WIN64}
    CnDebugger.LogFmt('Nodes ClassName %s. Value %16.16x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, NativeInt(Nodes)]);
  {$ELSE}
    CnDebugger.LogFmt('Nodes ClassName %s. Value %8.8x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, Integer(Nodes)]);
  {$ENDIF}
  end;
{$ENDIF}
  Result := TTreeNodes(Nodes);
end;

procedure ApplyThemeOnToolBar(ToolBar: TToolBar; Recursive: Boolean);
{$IFDEF IDE_SUPPORT_THEMING}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_THEMING}
  if CnThemeWrapper.CurrentIsDark then
  begin
    ToolBar.DrawingStyle := TTBDrawingStyle.dsGradient;
    ToolBar.GradientStartColor := csDarkBackgroundColor;
    ToolBar.GradientEndColor := csDarkBackgroundColor;
  end
  else
  begin
    ToolBar.DrawingStyle := TTBDrawingStyle.dsNormal;
    ToolBar.Color := clBtnface;
  end;

  if Recursive then
  begin
    for I := 0 to ToolBar.ControlCount - 1 do
    begin
      if ToolBar.Controls[I] is TToolBar then
        ApplyThemeOnToolbar(ToolBar.Controls[I] as TToolBar);
    end;
  end;
{$ENDIF}
end;

function GetErrorInsightRenderStyle: Integer;
{$IFDEF IDE_HAS_ERRORINSIGHT}
var
  V: Variant;
{$ENDIF}
begin
  // Env Options ��� ErrorInsightMarks ֵ
{$IFDEF IDE_HAS_ERRORINSIGHT}
  V := CnOtaGetEnvironmentOptionValue(SCnErrorInsightRenderStyleKeyName);
  if VarToStr(V) = '' then
    Result := csErrorInsightRenderStyleNotSupport
  else
    Result := V;
{$ELSE}
  Result := csErrorInsightRenderStyleNotSupport;
{$ENDIF}
end;

procedure GetInfoProc(const Name: string; NameType: TNameType; Flags: Byte;
  Param: Pointer);
var
  Idx: Integer;
  Cpp: Boolean;
begin
  // ����Ԫ����ͷ�ļ����滻����ȷ�Ĵ�Сд��ʽ
  if NameType = ntContainsUnit then
  begin
    Cpp := PCnUnitsInfoRec(Param).IsCppMode;
    if not Cpp then
    begin
      Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name);
      if Idx >= 0 then
        PCnUnitsInfoRec(Param).Unsorted[Idx] := Name;
    end
    else
    begin
      Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name + '.hpp');
      if Idx >= 0 then
        PCnUnitsInfoRec(Param).Unsorted[Idx] := Name + '.hpp'
      else
      begin
        Idx := PCnUnitsInfoRec(Param).Sorted.IndexOf(Name + '.h');
        if Idx >= 0 then
          PCnUnitsInfoRec(Param).Unsorted[Idx] := Name + '.h'
      end;
    end;
  end;
end;

function GetModuleProc(HInstance: THandle; Data: Pointer): Boolean;
var
  Flags: Integer;
begin
  Result := True;
  try
    if FindResource(HInstance, 'PACKAGEINFO', RT_RCDATA) <> 0 then
      GetPackageInfo(HInstance, Data, Flags, GetInfoProc);
  except
    ;
  end;
end;

var
  FCurrFileType: TCnUsesFileType;
  FCurrSearchType: TCnModuleSearchType;
  FUnitCallback: TCnUnitCallback = nil;

procedure InternalDoFindFile(ASelf: TObject; const FileName: string; const Info:
  TSearchRec; var Abort: Boolean);
begin
  FUnitCallback(FileName, True, FCurrFileType, FCurrSearchType);
end;

function IdeEnumUsesIncludeUnits(UnitCallback: TCnUnitCallback; IsCpp: Boolean;
  SearchTypes: TCnModuleSearchTypes): Boolean;
var
  Paths: TStringList;
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
  FileName: string;
  I, J: Integer;
  FindCallBack: TFindCallback;
  A, B: Boolean;

  procedure EnumPaths(APaths: TStringList);
  var
    K: Integer;
  begin
    if IsCpp then
    begin
      FCurrFileType := uftCppHeader;
      for K := 0 to APaths.Count - 1 do
        FindFile(APaths[K], '*.h*', FindCallBack, nil, False, False);
    end
    else
    begin
      for K := 0 to APaths.Count - 1 do
      begin
        if APaths.Objects[K] = nil then // �б�ǵĻ����� pas��Ʃ�� Lib Ŀ¼
        begin
          FCurrFileType := uftPascalSource;
          FindFile(APaths[K], '*.pas', FindCallBack, nil, False, False);
        end;
        FCurrFileType := uftPascalDcu;
        FindFile(APaths[K], '*.dcu', FindCallBack, nil, False, False);
      end;
    end;
  end;

begin
  Result := False;
  if not Assigned(UnitCallback) then
    Exit;

  Paths := nil;
  try
    Paths := TStringList.Create;
    Paths.Sorted := True;

    FUnitCallback := UnitCallback;
    TMethod(FindCallBack).Code := @InternalDoFindFile;
    TMethod(FindCallBack).Data := nil;

    if mstSystemSearch in SearchTypes then
    begin
      Paths.Clear;
      FCurrSearchType := mstSystemSearch;
      GetLibraryPath(Paths, False);

      if IsCpp then
        Paths.Add(MakePath(GetInstallDir) + 'Include\')
      else
      begin
        Paths.Add(MakePath(GetInstallDir) + 'Lib\');
        Paths.Objects[Paths.Count - 1] := TObject(True); // ���ֻ�� dcu
      end;

      EnumPaths(Paths);
    end;

    if mstProjectSearch in SearchTypes then
    begin
      Paths.Clear;
      FCurrSearchType := mstProjectSearch;

      GetProjectLibPath(Paths);
      EnumPaths(Paths);
    end;

    if mstInProject in SearchTypes then
    begin
      FCurrSearchType := mstInProject;
      ProjectGroup := CnOtaGetProjectGroup;
      if not Assigned(ProjectGroup) then
        Exit;

      for I := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[I];
        if not Assigned(Project) then
          Continue;

        for J := 0 to Project.GetModuleCount - 1 do
        begin
          FileName := Project.GetModule(J).FileName;
          if IsCpp then
          begin
            FileName := _CnChangeFileExt(FileName, '.h');
            A := FileExists(FileName);
            B := CnOtaIsFileOpen(FileName);
            if A or B then
              UnitCallback(FileName, A, uftCppHeader, mstInProject)
            else
            begin
              FileName := _CnChangeFileExt(FileName, '.hpp');
              A := FileExists(FileName);
              B := CnOtaIsFileOpen(FileName);
              if A or B then
                UnitCallback(FileName, A, uftCppHeader, mstInProject);
            end;
          end
          else
          begin
            A := FileExists(FileName);
            B := CnOtaIsFileOpen(FileName);

            if A or B then ; // ֻ Pas �� Dcu ֪ͨ Callback
            begin
              if IsPas(FileName) then
                UnitCallback(FileName, A, uftPascalSource, mstInProject)
              else if IsDcu(FileName) then
                UnitCallback(FileName, A, uftPascalDcu, mstInProject);
            end;
          end;
        end;
      end;
    end;
    Result := True;
  finally
    Paths.Free;
  end;
end;

procedure CorrectCaseFromIdeModules(UnitFilesList: TStringList; IsCpp: Boolean);
var
  Data: TCnUnitsInfoRec;
begin
  { Use a sorted StringList for searching and copy this list to an unsorted list
    which is manipulated in GetInfoProc(). After that the unsorted list is
    copied back to the original sorted list. BinSearch is a lot faster than
    linear search. (by AHUser) }
  Data.IsCppMode := IsCpp;
  Data.Sorted := UnitFilesList;
  Data.Unsorted := TStringList.Create;
  try
    Data.Unsorted.Assign(UnitFilesList);
    Data.Unsorted.Sorted := False; // added to avoid exception
    EnumModules(GetModuleProc, @Data);
  finally
    UnitFilesList.Sorted := False;
    UnitFilesList.Assign(Data.Unsorted);
    UnitFilesList.Sorted := True;
    Data.Unsorted.Free;
  end;
end;

//==============================================================================
// ��չ�ؼ�
//==============================================================================

{ TCnToolBarComboBox }

procedure TCnToolBarComboBox.CNKeyDown(var Message: TWMKeyDown);
var
  AShortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Message.KeyData);
  AShortCut := ShortCut(Message.CharCode, ShiftState);
  Message.Result := 1;
  if not HandleEditShortCut(Self, AShortCut) then
    inherited;
end;

//==============================================================================
// �������װ��
//==============================================================================

{ TCnPaletteWrapper }

var
  FCnPaletteWrapper: TCnPaletteWrapper = nil;

function CnPaletteWrapper: TCnPaletteWrapper;
begin
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  if FCnPaletteWrapper = nil then
    FCnPaletteWrapper := TCnPaletteWrapper.Create;
  Result := FCnPaletteWrapper;
{$ELSE}
  raise Exception.Create('Palette NOT Support.');
{$ENDIF}
end;

procedure TCnPaletteWrapper.BeginUpdate;
begin
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 0, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 0, 0);
  end;
  Inc(FUpdateCount);
end;

constructor TCnPaletteWrapper.Create;
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I, J: Integer;
{$ENDIF}
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  FPalTab := GetNewComponentPaletteTabControl;
  if FPalTab <> nil then
    FPalette := FPalTab.Owner.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;
{$ELSE}
  FPalTab := GetComponentPaletteTabControl;

  for I := 0 to FPalTab.ControlCount - 1 do
  begin
    if FPalTab.Controls[I].ClassNameIs('TPageScroller') then
    begin
      FPageScroller := FPalTab.Controls[I] as TWinControl;
      for J := 0 to FPageScroller.ControlCount - 1 do
      begin
        if FPageScroller.Controls[J].ClassNameIs('TPalette') then
        begin
          FPalette := FPageScroller.Controls[J] as TWinControl;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnPaletteWrapper.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 1, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 1, 0);
    FPalTab.Invalidate;
    FPalette.Invalidate;
  end;
end;

function TCnPaletteWrapper.FindTab(const ATab: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TabCount - 1 do
    if Tabs[I] = ATab then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnPaletteWrapper.GetActiveTab: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  Result := '';
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName)];
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Strings[(FPalTab as TTabControl).TabIndex];
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.GetComponentImage(Bmp: TBitmap;
  const AComponentClassName: string);
begin
{$IFDEF SUPPORT_PALETTE_ENHANCE}
  {$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  GetComponentImageFromNewPalette(Bmp, AComponentClassName);
  {$ELSE}
  GetComponentImageFromOldPalette(Bmp, AComponentClassName);
  {$ENDIF}
{$ENDIF}
end;

{$IFDEF SUPPORT_PALETTE_ENHANCE}

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

procedure TCnPaletteWrapper.GetComponentImageFromNewPalette(Bmp: TBitmap;
  const AComponentClassName: string);
var
{$IFDEF OTA_PALETTE_API}
  Item: IOTABasePaletteItem;
  Group: IOTAPaletteGroup;
  CI: IOTAComponentPaletteItem;
  Painter: INTAPalettePaintIcon;
  PAS: IOTAPaletteServices;
{$ELSE}
  I, J: Integer;
  S: string;
{$ENDIF}
begin
  if (Bmp = nil) or (AComponentClassName = '') then
    Exit;

{$IFDEF OTA_PALETTE_API}
  // ע���� PALETTE_API ʱ����һ�����µĿؼ��壬�������¿ؼ��������� API
  if Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        Item := Group.FindItemByName(AComponentClassName, True);
        if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI)
          and Supports(Item, INTAPalettePaintIcon, Painter) then
          Painter.Paint(Bmp.Canvas, 1, 1, pi24x24);
      end;
    end;
  end;
{$ELSE}
  try
    BeginUpdate;
    for I := 0 to TabCount - 1 do
    begin
      TabIndex := I;
      for J := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[J] is TSpeedButton) and
          FPalette.Controls[J].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          S := ParseCompNameFromHint((FPalette.Controls[J] as TSpeedButton).Hint);
          if S = AComponentClassName then
          begin
            GetControlBitmap(FPalette.Controls[J], Bmp);
            Exit;
          end;
        end;
      end;
    end;
  finally
    EndUpdate;
  end;
{$ENDIF}
end;

{$ELSE}

procedure TCnPaletteWrapper.GetComponentImageFromOldPalette(Bmp: TBitmap;
  const AComponentClassName: string);
var
  AClass: TComponentClass;
{$IFDEF COMPILER6_UP}
  FormEditor: IOTAFormEditor;
  Root: TPersistent;
  PalItem: IPaletteItem;
  PalItemPaint: IPalettePaint;
{$ENDIF}
begin
  if (Bmp = nil) or (AComponentClassName = '') then
    Exit;

  try
{$IFDEF COMPILER6_UP}
    FormEditor := CnOtaGetCurrentFormEditor;
    if Assigned(FormEditor) and (FormEditor.GetSelComponent(0) <> nil) then
    begin
      Root := TPersistent(FormEditor.GetSelComponent(0).GetComponentHandle);
      if (Root <> nil) and not ObjectIsInheritedFromClass(Root, 'TDataModule') then
      begin
        // ֻ���� CLX �� VCL ����ڴ���仯�������ת�� CLX/VCL ������ָ�
        if FOldRootClass <> Root.ClassType then
        begin
          ActivateClassGroup(TPersistentClass(Root.ClassType));
          FOldRootClass := Root.ClassType;
        end;
      end;
    end;
{$ENDIF}

    AClass := TComponentClass(GetClass(AComponentClassName));
    if AClass <> nil then
    begin
      Bmp.Canvas.FillRect(Bounds(0, 0, Bmp.Width, Bmp.Height));
{$IFDEF COMPILER6_UP}
      PalItem := ComponentDesigner.ActiveDesigner.Environment.GetPaletteItem(AClass) as IPaletteItem;
      if Supports(PalItem, IPalettePaint, PalItemPaint) then
        PalItemPaint.Paint(Bmp.Canvas, 0, 0);
{$ELSE}
      DelphiIDE.GetPaletteItem(TComponentClass(AClass)).Paint(Bmp.Canvas, -1, -1);
{$ENDIF}
    end;
  except
    ;
  end;
end;

{$ENDIF}

{$ENDIF}

function TCnPaletteWrapper.GetEnabled: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Enabled
  else
    Result := False;
end;

function TCnPaletteWrapper.GetIsMultiLine: Boolean;
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE} // �¿ؼ��岻֧�ֶ���
  Result := False;
{$ELSE}
  Result := (FPalTab as TTabControl).MultiLine;
{$ENDIF}
end;

function TCnPaletteWrapper.GetPalToolCount: Integer;
var
  I: Integer;
begin
  Result := -1;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  if FPalette <> nil then
  begin
    for I := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[I] is TSpeedButton) and
        FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        Inc(Result);
    end;
  end;
{$ELSE}
  try
    if FPalette <> nil then
      Result := GetPropValue(FPalette, SCnPalettePropPalToolCount)
  except
    Result := 0;
    if FPageScroller <> nil then
      for I := 0 to FPageScroller.ControlCount - 1 do
        if Self.FPageScroller.Controls[I] is TSpeedButton then
          Inc(Result);
  end;
{$ENDIF}
end;

function TCnPaletteWrapper.GetSelectedIndex: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I, Idx: Integer;
{$ENDIF}
begin
  Result := -1;
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      Idx := -1;
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          Inc(Idx);
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := Idx;
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedIndex);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelectedToolName: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I: Integer;
{$ENDIF}
begin
  Result := '';
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := ParseCompNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedToolName);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelectedUnitName: string;
var
  S: string;
  AClass: TPersistentClass;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  {$IFDEF OTA_PALETTE_API}
  SelTool: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
  {$ELSE}
  I: Integer;
  {$ENDIF}
{$ENDIF}
begin
  Result := '';
  S := SelectedToolName;

  if S <> '' then
  begin
    AClass := GetClass(S);
    if (AClass <> nil) and (PTypeInfo(AClass.ClassInfo).Kind = TypInfo.tkClass) then
      Result := string(GetTypeData(PTypeInfo(AClass.ClassInfo)).UnitName);

    // ��������������� FMX ���޷���� Class �ģ���������취
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  {$IFDEF OTA_PALETTE_API}
    // ֧�� PaletteAPI �Ļ�ֱ�ӻ�ȡ
    if (Result = '') and Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
    begin
      if PAS <> nil then
      begin
        SelTool := PAS.SelectedTool;
        if (SelTool <> nil) and Supports(SelTool, IOTAComponentPaletteItem, CI) then
        begin
          if CI <> nil then
            Result := CI.UnitName;
        end;
      end;
    end;
  {$ELSE} // �����֧�� PaletteAPI����ֻ��ͨ��ѡ����ʵ�֣��൱��
    if Result = '' then
    begin
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := ParseUnitNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
            Exit;
          end;
        end;
      end;
    end;
  {$ENDIF}
{$ENDIF}
  end;
end;

function TCnPaletteWrapper.GetSelector: TSpeedButton;
begin
  Result := nil;
  try
    if FPalette <> nil then
      Result := TSpeedButton(GetObjectProp(FPalette, SCnPalettePropSelector))
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetTabCount: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList.Count
    else
      Result := 0;
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Count;
{$ENDIF}
  end
  else
    Result := 0;
end;

function TCnPaletteWrapper.GetTabIndex: Integer;
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Result := GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName);
{$ELSE}
    Result := (FPalTab as TTabControl).TabIndex;
{$ENDIF}
  end
  else
    Result := -1;
end;

function TCnPaletteWrapper.GetTabs(Index: Integer): string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[Index]
    else
      Result := '';
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs[Index];
{$ENDIF}
  end
  else
    Result := '';
end;

function TCnPaletteWrapper.GetUnitNameFromComponentClassName(
  const AClassName: string; const ATabName: string): string;
var
  AClass: TPersistentClass;
{$IFDEF OTA_PALETTE_API}
  Group, SubGroup: IOTAPaletteGroup;
  Item: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
{$ENDIF}
begin
  Result := '';
  AClass := GetClass(AClassName);
  if (AClass <> nil) and (PTypeInfo(AClass.ClassInfo).Kind = TypInfo.tkClass) then
    Result := string(GetTypeData(PTypeInfo(AClass.ClassInfo)).UnitName);

{$IFDEF DEBUG}
  if Result = '' then
    Cndebugger.LogMsg('GetUnitNameFromComponentClassName ' + AClassName + ' NOT Found.');
{$ENDIF}

{$IFDEF OTA_PALETTE_API}
  if (Result = '') and Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        if ATabName <> '' then
        begin
          // ����� Tab �����ҵ� Tab ���� Group ������������ֵ��� Item
          SubGroup := Group.FindItemGroupByName(ATabName);
          if SubGroup <> nil then
          begin
            Item := SubGroup.FindItemByName(AClassName, True);
            if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
              Result := CI.UnitName;
          end;
        end
        else
        begin
          // û�� Tab ���ͱ����� Group ����������ֵ��� Item
          Item := SubGroup.FindItemByName(AClassName, True);
          if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
              Result := CI.UnitName;
        end;
      end;
    end;
  end;
{$ELSE}
  if (Result = '') and SelectComponent(AClassName, ATabName) then
    Result := SelectedUnitName;
{$ENDIF}
end;

{$IFDEF OTA_PALETTE_API}

function TCnPaletteWrapper.GetUnitPackageNameFromComponentClassName(
  out UnitName: string; out PackageName: string; const AClassName: string;
  const ATabName: string): Boolean;
var
  Group, SubGroup: IOTAPaletteGroup;
  Item: IOTABasePaletteItem;
  CI: IOTAComponentPaletteItem;
  PAS: IOTAPaletteServices;
begin
  Result := False;
  if Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
  begin
    if PAS <> nil then
    begin
      Group := PAS.BaseGroup;
      if Group <> nil then
      begin
        if ATabName <> '' then
        begin
          // ����� Tab �����ҵ� Tab ���� Group ������������ֵ��� Item
          SubGroup := Group.FindItemGroupByName(ATabName);
          if SubGroup <> nil then
          begin
            Item := SubGroup.FindItemByName(AClassName, True);
            if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
            begin
              UnitName := CI.UnitName;
              PackageName := CI.PackageName;
              Result := True;
            end;
          end;
        end
        else
        begin
          // û�� Tab ���ͱ����� Group ����������ֵ��� Item
          Item := SubGroup.FindItemByName(AClassName, True);
          if (Item <> nil) and Supports(Item, IOTAComponentPaletteItem, CI) then
          begin
            UnitName := CI.UnitName;
            PackageName := CI.PackageName;
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

function TCnPaletteWrapper.GetVisible: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Visible
  else
    Result := False;
end;

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

const
  COMP_NAME_PREFIX = 'Name: ';
  UNIT_NAME_PREFIX = 'Unit: ';
  PACKAGE_NAME_PREFIX = 'Package: ';
  CRLF = #13#10;

function InternalParseContentFromHint(const Hint: string; const Pat: string): string;
var
  APos: Integer;
begin
  // �ѿؼ��������ĳ��� SpeedButton ��ť�� Hint ��ͷ���ֶ�ֵ��������
  {
    Hint ���磺
    Name: ComponentName
    Unit: UnitName
    Package: PackageName
  }
  Result := Hint;
  if Pat = '' then
    Exit;

  APos := Pos(Pat, Result);
  if APos > 0 then
    Delete(Result, 1, APos - 1 + Length(Pat));
  APos := Pos(CRLF, Result);
  if APos > 0 then
    Result := Copy(Result, 1, APos - 1);
end;

function TCnPaletteWrapper.ParseCompNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, COMP_NAME_PREFIX);
end;

function TCnPaletteWrapper.ParseUnitNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, UNIT_NAME_PREFIX);
end;

function TCnPaletteWrapper.ParsePackageNameFromHint(const Hint: string): string;
begin
  Result := InternalParseContentFromHint(Hint, PACKAGE_NAME_PREFIX);
end;

{$ENDIF}

function TCnPaletteWrapper.SelectComponent(const AComponent,
  ATab: string): Boolean;
var
  I, Idx: Integer;
{$IFNDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  J: Integer;
{$ENDIF}

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  function SelectComponentInCurrentTab: Boolean;
  var
    K: Integer;
    S: string;
  begin
    Result := False;
    for K := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[K] is TSpeedButton) and
        FPalette.Controls[K].ClassNameIs(SCnNewPaletteButtonClassName) then
      begin
        S := ParseCompNameFromHint((FPalette.Controls[K] as TSpeedButton).Hint);
        if S = AComponent then
        begin
          if not (FPalette.Controls[K] as TSpeedButton).Down then
            (FPalette.Controls[K] as TSpeedButton).Click;
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}

begin
  Result := True;
  Idx := FindTab(ATab);
  if Idx >= 0 then
    TabIndex := Idx;

  // �����ʾ��ѡ��
  if AComponent = '' then
  begin
    SelectedIndex := -1;
    Exit;
  end
  else
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    if SelectComponentInCurrentTab then
      Exit;
{$ELSE}
    for I := 0 to PalToolCount - 1 do
    begin
      SelectedIndex := I;
      if SelectedToolName = AComponent then
        Exit;
    end;
{$ENDIF}
  end;

  // �� Tab ���޴����ʱ��ȫ������
  for I := 0 to TabCount - 1 do
  begin
    TabIndex := I;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    if SelectComponentInCurrentTab then
      Exit;
{$ELSE}
    for J := 0 to PalToolCount - 1 do
    begin
      SelectedIndex := J;
      if SelectedToolName = AComponent then
        Exit;
    end;
{$ENDIF}
  end;

  SelectedIndex := -1;
  Result := False;
end;

procedure TCnPaletteWrapper.SetEnabled(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Enabled := Value;
end;

procedure TCnPaletteWrapper.SetSelectedIndex(const Value: Integer);
var
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  I, Idx: Integer;
{$ELSE}
  PropInfo: PPropInfo;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Idx := -1;
    for I := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[I] is TSpeedButton) and
        FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
      begin
        Inc(Idx);
        if (Idx = Value) and not (FPalette.Controls[I] as TSpeedButton).Down then
        begin
          (FPalette.Controls[I] as TSpeedButton).Click;
          Exit;
        end
        else if (Value = -1) and (FPalette.Controls[I] as TSpeedButton).Down then
        begin
          (FPalette.Controls[I] as TSpeedButton).Click;
          Exit;
        end;
      end;
    end;
{$ELSE}
    PropInfo := GetPropInfo(FPalette.ClassInfo, SCnPalettePropSelectedIndex);
    SetOrdProp(FPalette, PropInfo, Value);
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.SetTabIndex(const Value: Integer);
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    SetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName, Value);
{$ELSE}
    (FPalTab as TTabControl).TabIndex := Value;
    if Assigned((FPalTab as TTabControl).OnChange) then
      (FPalTab as TTabControl).OnChange(FPalTab);
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.SetVisible(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Visible := Value;
end;

//==============================================================================
// ��Ϣ������ڷ�װ��
//==============================================================================

{ TCnMessageViewWrapper }

var
  FCnMessageViewWrapper: TCnMessageViewWrapper = nil;

function CnMessageViewWrapper: TCnMessageViewWrapper;
begin
  if FCnMessageViewWrapper = nil then
    FCnMessageViewWrapper := TCnMessageViewWrapper.Create
  else
    FCnMessageViewWrapper.UpdateAllItems;

  Result := FCnMessageViewWrapper;
end;

constructor TCnMessageViewWrapper.Create;
begin
  UpdateAllItems;
end;

procedure TCnMessageViewWrapper.EditMessageSource;
begin
  if (FEditMenuItem <> nil) and Assigned(FEditMenuItem.OnClick) then
  begin
    FMessageViewForm.SetFocus;
    FEditMenuItem.OnClick(FEditMenuItem);
  end;
end;

{$IFNDEF BDS}

function TCnMessageViewWrapper.GetCurrentMessage: string;
begin
  Result := '';
  if FTreeView <> nil then
    if FTreeView.Selected <> nil then
      Result := FTreeView.Selected.Text;
end;

function TCnMessageViewWrapper.GetMessageCount: Integer;
begin
  Result := -1;
  if FTreeView <> nil then
    Result := FTreeView.Items.Count;
end;

function TCnMessageViewWrapper.GetSelectedIndex: Integer;
begin
  Result := -1;
  if (FTreeView <> nil) and (FTreeView.Selected <> nil) then
    Result := FTreeView.Selected.AbsoluteIndex;
end;

procedure TCnMessageViewWrapper.SetSelectedIndex(const Value: Integer);
begin
  if FTreeView <> nil then
    if (Value >= 0) and (Value < FTreeView.Items.Count) then
      FTreeView.Selected := FTreeView.Items[Value];
end;

{$ENDIF}

function TCnMessageViewWrapper.GetTabCaption: string;
begin
  Result := '';
  if FTabSet <> nil then
    Result := FTabSet.Tabs[FTabSet.TabIndex];
end;

function TCnMessageViewWrapper.GetTabCount: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.Tabs.Count;
end;

function TCnMessageViewWrapper.GetTabIndex: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.TabIndex;
end;

function TCnMessageViewWrapper.GetTabSetVisible: Boolean;
begin
  Result := False;
  if FTabSet <> nil then
    Result := FTabSet.Visible;;
end;

procedure TCnMessageViewWrapper.SetTabIndex(const Value: Integer);
begin
  if FTabSet <> nil then
    FTabSet.TabIndex := Value;
end;

procedure TCnMessageViewWrapper.UpdateAllItems;
var
  I, J: Integer;
begin
  try
    FMessageViewForm := nil;
    FEditMenuItem := nil;
    FTreeView := nil;
    FTabSet := nil;
    
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[I].ClassNameIs('TMessageViewForm') then
      begin
        FMessageViewForm := Screen.CustomForms[I];
        FEditMenuItem := TMenuItem(FMessageViewForm.FindComponent(SCnMvEditSourceItemName));

        for J := 0 to FMessageViewForm.ControlCount - 1 do
        begin
          if FMessageViewForm.Controls[J].ClassNameIs(SCnTreeMessageViewClassName) then
          begin
           FTreeView := TXTreeView(FMessageViewForm.Controls[J]);
          end
          else if FMessageViewForm.Controls[J].Name = SCnMessageViewTabSetName then
          begin
            FTabSet := TTabSet(FMessageViewForm.Controls[J]);
          end;
        end;
      end;
    end;
  except
    ;
  end;
end;

var
  FThemeWrapper: TCnThemeWrapper = nil;

function CnThemeWrapper: TCnThemeWrapper;
begin
  if FThemeWrapper = nil then
    FThemeWrapper := TCnThemeWrapper.Create;
  Result := FThemeWrapper;
end;

{ TCnThemeWrapper }

constructor TCnThemeWrapper.Create;
begin
  inherited;
{$IFDEF IDE_SUPPORT_THEMING}
  FSupportTheme := True;
{$ENDIF}
  FActiveThemeName := CnOtaGetActiveThemeName;
  FCurrentIsDark := FActiveThemeName = 'Dark';

  CnWizNotifierServices.AddAfterThemeChangeNotifier(ThemeChanged);
end;

destructor TCnThemeWrapper.Destroy;
begin
  CnWizNotifierServices.RemoveAfterThemeChangeNotifier(ThemeChanged);
  inherited;
end;

function TCnThemeWrapper.IsUnderDarkTheme: Boolean;
begin
  Result := FSupportTheme and FCurrentIsDark;
end;

function TCnThemeWrapper.IsUnderLightTheme: Boolean;
begin
  Result := FSupportTheme and FCurrentIsLight;
end;

procedure TCnThemeWrapper.ThemeChanged(Sender: TObject);
begin
  FActiveThemeName := CnOtaGetActiveThemeName;
  FCurrentIsDark := FActiveThemeName = 'Dark';
  FCurrentIsLight := FActiveThemeName = 'Light';
end;

procedure DisableWaitDialogShow;
begin
{$IFDEF IDE_SWITCH_BUG}
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  if not CnIsDelphi10Dot4GEDot2 then
    Exit;
  {$ENDIF}

  if FWaitDialogHook = nil then
  begin
    FDesignIdeHandle := GetModuleHandle(DesignIdeLibName);
    if FDesignIdeHandle <> 0 then
    begin
      OldWaitDialogShow := GetBplMethodAddress(GetProcAddress(FDesignIdeHandle, SWaitDialogShow));
      FWaitDialogHook := TCnMethodHook.Create(@OldWaitDialogShow, @MyWaitDialogShow);
    end;
  end;
  FWaitDialogHook.HookMethod;
{$ENDIF}
end;

procedure EnableWaitDialogShow;
begin
{$IFDEF IDE_SWITCH_BUG}
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  if not CnIsDelphi10Dot4GEDot2 then
    Exit;
  {$ENDIF}

  if FWaitDialogHook <> nil then
    FWaitDialogHook.UnhookMethod;
{$ENDIF}
end;

{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}

function GetControlCurrentPPI(AControl: TControl): Integer;
{$IFDEF FPC}
var
  P: TPoint;
  M: TMonitor;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := Screen.PixelsPerInch;
  try
    P := AControl.ClientToScreen(Point(0, 0));
    M := Screen.MonitorFromPoint(P);
    if M <> nil then
      Result := M.PixelsPerInch;
  except
    ;
  end;
{$ELSE}
  Result := AControl.CurrentPPI;
{$ENDIF}
end;

{$ENDIF}

function IdeGetScaledPixelsFromOrigin(APixels: Integer; AControl: TControl): Integer;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := APixels
  else
  begin
    Result := MulDiv(APixels, GetControlCurrentPPI(AControl), CN_DEF_SCREEN_DPI);
  end;
{$ELSE}
  Result := APixels; // IDE ��֧�� HDPI ʱԭ�ⲻ���ط��أ����� OS ����
{$ENDIF}
end;

function IdeGetOriginPixelsFromScaled(APixels: Integer; AControl: TControl = nil): Integer;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := APixels
  else
  begin
    Result := MulDiv(APixels, CN_DEF_SCREEN_DPI, GetControlCurrentPPI(AControl));
  end;
{$ELSE}
  Result := APixels; // IDE ��֧�� HDPI ʱԭ�ⲻ���ط���
{$ENDIF}
end;

function IdeGetScaledFactor(AControl: TControl = nil): Single;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl = nil then
    AControl := Application.MainForm;

  if AControl = nil then
    Result := 1.0
  else
  begin
    Result := GetControlCurrentPPI(AControl) / CN_DEF_SCREEN_DPI;
  end;
{$ELSE}
  Result := 1.0; // IDE ��֧�� HDPI ʱԭ�ⲻ���ط��أ����� OS ����
{$ENDIF}
end;

procedure IdeSetReverseScaledFontSize(AControl: TControl);
begin
{$IFDEF IDE_SUPPORT_HDPI}
  if AControl <> nil then
  begin
  if not TControlHack(AControl).ParentFont
    {$IFNDEF FPC} and (sfFont in TControlHack(AControl).DefaultScalingFlags) {$ENDIF}
    then
    TControlHack(AControl).Font.Height := MulDiv(TControlHack(AControl).Font.Height,
      CN_DEF_SCREEN_DPI, GetControlCurrentPPI(AControl));
  end;
{$ENDIF}
end;

procedure IdeScaleToolbarComboFontSize(Combo: TControl);
begin
  // �� DPI �� Toolbar �е� ComboBox �ƺ��ᱻ�Զ��Ŵ������������ IdeGetScaledPixelsFromOrigin
  if WizOptions.UseLargeIcon then
    TControlHack(Combo).Font.Size := csLargeComboFontSize;
end;

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}

function IdeGetVirtualImageListFromOrigin(Origin: TCustomImageList;
  AControl: TControl; IgnoreWizLargeOption: Boolean): TVirtualImageList;
var
  Idx: Integer;
  AVL: TVirtualImageList;
  AIC: TImageCollection;
begin
  Result := nil;
  if Origin = nil then
    Exit;

  if Origin.Count = 0 then
    Exit;

  Idx := FOriginImages.IndexOf(Origin);
  if (Idx >= 0) and (Idx < FVirtualImages.Count) then
  begin
    Result := TVirtualImageList(FVirtualImages[Idx]);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('IdeGetVirtualImageListFromOrigin Existing Result Index %d', [Idx]);
{$ENDIF}
    Exit;
  end;

  AVL := TVirtualImageList.Create(Application);
  AIC := TImageCollection.Create(Application);
  AVL.ImageCollection := AIC;

  FOriginImages.Add(Origin);
  FVirtualImages.Add(AVL);
  FImageCollections.Add(AIC);

  if WizOptions.UseLargeIcon and not IgnoreWizLargeOption then
  begin
    AVL.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth, AControl);
    AVL.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight, AControl);
  end
  else
  begin
    AVL.Width := IdeGetScaledPixelsFromOrigin(Origin.Width, AControl);
    AVL.Height := IdeGetScaledPixelsFromOrigin(Origin.Height, AControl);
  end;

  CopyImageListToVirtual(Origin, AVL);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('IdeGetVirtualImageListFromOrigin New Result Index %d', [FVirtualImages.Count - 1]);
{$ENDIF}
  Result := AVL;
end;

{$ENDIF}
{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF CNWIZARDS_MINIMUM}

{$IFDEF DELPHI_OTA}

function SearchUsesInsertPosInPasFile(const FileName: string; IsIntf: Boolean;
  out HasUses: Boolean; out LinearPos: Integer): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralWidePasLex;
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfPos, ImplPos: Integer;
begin
  Result := False;
  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfPos := 0;
  ImplPos := 0;

  Stream := nil;
  Lex := nil;

  try
    Stream := TMemoryStream.Create;
    CnGeneralFilerSaveFileToStream(FileName, Stream);

    Lex := TCnGeneralWidePasLex.Create;
    Lex.Origin := Stream.Memory;

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // �������Լ���Ҫ�� uses ��
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // ����λ�þ��ڷֺ�ǰ
              Result := True;
              LinearPos := Lex.TokenPos;
              Exit;
            end
            else // uses ���Ҳ��ŷֺţ�����
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface, tkProgram:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;

          IntfPos := Lex.TokenPos;
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;

          ImplPos := Lex.TokenPos;
        end;
      end;
      Lex.Next;
    end;

    // ������ϣ����˴���û�� uses ������
    if IsIntf and MeetIntf then    // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      LinearPos := IntfPos + Length('interface');
    end
    else if not IsIntf and MeetImpl then // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      LinearPos := ImplPos + Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

function SearchUsesInsertPosInCurrentPas(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralPasLex;
{$IFDEF UNICODE}
  LineText: string;
  S: AnsiString;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  LineText: string;
  S: AnsiString;
  {$ENDIF}
{$ENDIF}
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfLine, ImplLine: Integer;
begin
  Result := False;
  Stream := TMemoryStream.Create;

  // ������Ż��� General ϵ�У������Ȳ���
{$IFDEF UNICODE}
  Lex := TCnPasWideLex.Create;
  CnOtaSaveCurrentEditorToStreamW(Stream, False);
{$ELSE}
  Lex := TmwPasLex.Create;
  CnOtaSaveCurrentEditorToStream(Stream, False);
{$ENDIF}

  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfLine := 0;
  ImplLine := 0;

  CharPos.Line := 0;
  CharPos.CharIndex := -1;

  try
{$IFDEF UNICODE}
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // �������Լ���Ҫ�� uses ��
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // ����λ�þ��ڷֺ�ǰ
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // ������ Unicode ������� TOTACharPos ΪʲôҲ��Ҫ�� Utf8 ת��
{$ELSE}
              CharPos.Line := Lex.LineNumber + 1;
              CharPos.CharIndex := Lex.TokenPos - Lex.LinePos;
  {$IFDEF IDE_STRING_ANSI_UTF8}
              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));
  {$ENDIF}
{$ENDIF}
              Exit;
            end
            else // uses ���Ҳ��ŷֺţ�����
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface, tkProgram:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;
{$IFDEF UNICODE}
          IntfLine := Lex.LineNumber;
{$ELSE}
          IntfLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;
{$IFDEF UNICODE}
          ImplLine := Lex.LineNumber;
{$ELSE}
          ImplLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      end;
      Lex.Next;
    end;

    // ������ϣ����˴���û�� uses ������
    if IsIntf and MeetIntf then    // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := ImplLine;
      CharPos.CharIndex := Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

function SearchUsesInsertPosInCurrentCpp(out CharPos: TOTACharPos;
  SourceEditor: IOTASourceEditor = nil): Boolean;
var
  Stream: TMemoryStream;
  LastIncLine: Integer;
{$IFDEF UNICODE}
  CParser: TCnBCBWideTokenList;
{$ELSE}
  CParser: TBCBTokenList;
{$ENDIF}
begin
  // �������һ�� include ǰ�档���� include��h �ļ��� cpp ������ͬ��
  Result := False;
  Stream := nil;
  CParser := nil;

  try
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStreamW(SourceEditor, Stream, False);
    CParser.SetOrigin(PWideChar(Stream.Memory), Stream.Size div SizeOf(Char));
{$ELSE}
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveEditorToStream(SourceEditor, Stream, False);
    CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}

    LastIncLine := -1;
    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
{$IFDEF UNICODE}
        LastIncLine := CParser.LineNumber;
{$ELSE}
        LastIncLine := CParser.RunLineNumber;
{$ENDIF}
      end;
      CParser.NextNonJunk;
    end;

    if LastIncLine >= 0 then
    begin
      Result := True;
      CharPos.Line := LastIncLine + 1; // ���һ�� inc ������
      CharPos.CharIndex := 0;
    end;
  finally
    CParser.Free;
    Stream.Free;
  end;
end;

function JoinUsesOrInclude(IsCpp, FileHasUses: Boolean; IsHFromSystem: Boolean;
  const IncFiles: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  if (IncFiles = nil) or (IncFiles.Count = 0) then
    Exit;

  if IsCpp then
  begin
    for I := 0 to IncFiles.Count - 1 do
    begin
      if IsHFromSystem then
        Result := Result + Format('#include <%s>' + #13#10, [IncFiles[I]])
      else
        Result := Result + Format('#include "%s"' + #13#10, [IncFiles[I]]);
    end;
  end
  else
  begin
    if FileHasUses then
    begin
      for I := 0 to IncFiles.Count - 1 do
        Result := Result + ', ' + IncFiles[I];
    end
    else
    begin
      Result := #13#10#13#10 + 'uses' + #13#10 + Spc(CnOtaGetBlockIndent) + IncFiles[0];
      for I := 1 to IncFiles.Count - 1 do
        Result := Result + ', ' + IncFiles[I];
      Result := Result + ';';
    end;
  end;
end;

{$ENDIF}

{$ENDIF}

initialization
{$IFDEF DELPHI_OTA}
  // ʹ�ô�ȫ�ֱ������Ա���Ƶ������ IdeGetIsEmbeddedDesigner ����
  IdeIsEmbeddedDesigner := IdeGetIsEmbeddedDesigner;
  InitIdeAPIs;
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  FOriginImages := TObjectList.Create(False);
  FVirtualImages := TObjectList.Create(False);
  FImageCollections := TObjectList.Create(False);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizIdeUtils.');
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizIdeUtils finalization.');
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  FImageCollections.Free;
  FVirtualImages.Free;
  FOriginImages.Free;
{$ENDIF}

{$IFDEF IDE_SWITCH_BUG}
  FWaitDialogHook.Free;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  if FCnPaletteWrapper <> nil then
    FreeAndNil(FCnPaletteWrapper);

  if FCnMessageViewWrapper <> nil then
    FreeAndNil(FCnMessageViewWrapper);

  if FThemeWrapper <> nil then
    FreeAndNil(FThemeWrapper);

  FinalIdeAPIs;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizIdeUtils finalization.');
{$ENDIF}
{$ENDIF}

end.

