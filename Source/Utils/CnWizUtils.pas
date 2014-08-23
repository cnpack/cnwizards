{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
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

unit CnWizUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����������ڹ��̿ⵥԪ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ������ CnWizards ר�Ұ��Ĺ������̿�
*           �õ�Ԫ����������ֲ�� GExperts
*           ��ԭʼ������ GExperts License �ı���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2012.10.01 by shenloqi
*               �޸�CnOtaGetCurrLineText���ܻ�ȡ���һ�к�δTrimRight��BUG
*               �޸�CnOtaInsertSingleLine������ȷ�ڵ�һ�в����BUG
*           2012.09.19 by shenloqi
*               ��ֲ��Delphi XE3
*           2005.05.06 by hubdog
*               ׷��������Ŀ����ֵ�ĺ������޸�CnOtaGetActiveProjectOptions
*           2005.05.04 by hubdog
*               ���ƿؼ����ƺ��Զ��л�������ģʽ
*           2002.09.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, Menus, ActnList,
  Forms, ImgList, ExtCtrls, ExptIntf, ToolsAPI, ComObj, IniFiles, FileCtrl,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner,
  {$ELSE}
  DsgnIntf, LibIntf,
  {$ENDIF}
  {$IFDEF DELPHIXE3_UP}Actions,{$ENDIF}
  Clipbrd, TypInfo, ComCtrls, StdCtrls, Imm, Contnrs, RegExpr,
  CnWizConsts, CnCommon, CnConsts, CnWideStrings, CnWizClasses, CnWizIni;

type
  ECnWizardException = class(Exception);
  ECnDuplicateShortCutName = class(ECnWizardException);
  ECnDuplicateCommand = class(ECnWizardException);
  ECnEmptyCommand = class(ECnWizardException);

  TFormType = (ftBinary, ftText, ftUnknown);

{$IFNDEF COMPILER6_UP}
  IDesigner = IFormDesigner;
{$ENDIF}

const
  CRLF = #13#10;
  SAllAlphaNumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';

  InvalidNotifierIndex = -1;
  NonvisualClassNamePattern = 'TContainer';
  
  // ���Դ�����г���
  csMaxLineLength = 1023;

var
  CnNoIconList: TStrings;
  IdeClosing: Boolean;

//==============================================================================
// ������Ϣ����
//==============================================================================

function CnIntToObject(AInt: Integer): TObject;
{* �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���}
function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
{* ����Դ���ļ���װ��ͼ�ִ꣬��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊͼ��װ�سɹ���־������ ResName �벻Ҫ�� .ico ��չ��}
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
{* ����Դ���ļ���װ��λͼ��ִ��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊλͼװ�سɹ���־������ ResName �벻Ҫ�� .bmp ��չ��}
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
{* ����ͼ�굽 ImageList �У�ʹ��ƽ������}
function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
{* ����һ�� Disabled ��λͼ�����ض�����Ҫ���÷��ͷ�}
procedure AdjustButtonGlyph(Glyph: TBitmap);
{* Delphi �İ�ť�� Disabled ״̬ʱ����ʾ��ͼ����ѿ����ú���ͨ���ڸ�λͼ�Ļ�����
   ����һ���µĻҶ�λͼ�������һ���⡣������ɺ� Glyph ��ȱ�Ϊ�߶ȵ���������Ҫ
   ���� Button.NumGlyphs := 2 }
function SameFileName(const S1, S2: string): Boolean;
{* �ļ�����ͬ}
function CompressWhiteSpace(const Str: string): string;
{* ѹ���ַ����м�Ŀհ��ַ�}
procedure ShowHelp(const Topic: string);
{* ��ʾָ������İ�������}
procedure CenterForm(const Form: TCustomForm);
{* �������}
procedure EnsureFormVisible(const Form: TCustomForm);
{* ��֤����ɼ�}
function GetCaptionOrgStr(const Caption: string): string;
{* ɾ���������ȼ���Ϣ}
function GetIDEImageList: TCustomImageList;
{* ȡ�� IDE �� ImageList}
procedure SaveIDEImageListToPath(const Path: string);
{* ���� IDE ImageList �е�ͼ��ָ��Ŀ¼��}
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
{* ����˵������б��ļ�}
function GetIDEMainMenu: TMainMenu;
{* ȡ�� IDE ���˵�}
function GetIDEToolsMenu: TMenuItem;
{* ȡ�� IDE ���˵��µ� Tools �˵�}
function GetIDEActionList: TCustomActionList;
{* ȡ�� IDE �� ActionList}
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
{* ȡ�� IDE �� ActionList ��ָ����ݼ��� Action}
function GetIdeRootDirectory: string;
{* ȡ�� IDE ��Ŀ¼}
function ReplaceToActualPath(const Path: string): string;
{* �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��}
procedure SaveIDEActionListToFile(const FileName: string);
{* ���� IDE ActionList �е����ݵ�ָ���ļ�}
procedure SaveIDEOptionsNameToFile(const FileName: string);
{* ���� IDE �������ñ�������ָ���ļ�}
procedure SaveProjectOptionsNameToFile(const FileName: string);
{* ���浱ǰ���̻������ñ�������ָ���ļ�}
function FindIDEAction(const ActionName: string): TContainedAction;
{* ���� IDE Action �������ض���}
function ExecuteIDEAction(const ActionName: string): Boolean;
{* ���� IDE Action ����ִ����}
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
{* ����һ���Ӳ˵���}
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
{* ����һ���ָ��˵���}
procedure SortListByMenuOrder(List: TList);
{* ���� TCnMenuWizard �б��е� MenuOrder ֵ������С���������}
function IsTextForm(const FileName: string): Boolean;
{* ���� DFM �ļ��Ƿ��ı���ʽ}
procedure DoHandleException(const ErrorMsg: string);
{* ����һЩִ�з����е��쳣}
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
{* �ڴ��ڿؼ��в���ָ����������}
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
{* �ڴ��ڿؼ��в���ָ�������������}
function ScreenHasModalForm: Boolean;
{* ����ģʽ����}
procedure SetFormNoTitle(Form: TForm);
{* ȥ������ı���}
procedure SendKey(vk: Word);
{* ����һ�������¼�}
function IMMIsActive: Boolean;
{* �ж����뷨�Ƿ��}
function GetCaretPosition(var Pt: TPoint): Boolean;
{* ȡ�༭�������Ļ������}
procedure GetCursorList(List: TStrings);
{* ȡCursor��ʶ���б� }
procedure GetCharsetList(List: TStrings);
{* ȡFontCharset��ʶ���б� }
procedure GetColorList(List: TStrings);
{* ȡColor��ʶ���б� }
function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;
{* ʹ�ؼ������׼�༭��ݼ� }

//==============================================================================
// �ؼ������� 
//==============================================================================

type
  TCnSelectMode = (smAll, smNone, smInvert);

function CnGetComponentText(Component: TComponent): string;
{* ��������ı���}
function CnGetComponentAction(Component: TComponent): TBasicAction;
{* ȡ�ؼ������� Action }
procedure RemoveListViewSubImages(ListView: TListView); overload;
{* ���� ListView �ؼ���ȥ������� SubItemImages }
procedure RemoveListViewSubImages(ListItem: TListItem); overload;
{* ���� ListItem��ȥ������� SubItemImages }
function GetListViewWidthString(AListView: TListView): string;
{* ת�� ListView ������Ϊ�ַ��� }
procedure SetListViewWidthString(AListView: TListView; const Text: string);
{* ת���ַ���Ϊ ListView ������ }
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ��������� }
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ��������� }
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
{* �޸� ListView ��ǰѡ���� }

//==============================================================================
// �������ж� IDE/BDS �� Delphi ���� C++Builder ���Ǳ��
//==============================================================================

function IsDelphiRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� Delphi(.NET)�����򷵻� True�������򷵻� False}

function IsCSharpRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� C#�����򷵻� True�������򷵻� False}

function IsDelphiProject(Project: IOTAProject): Boolean;
{* �жϵ�ǰ�Ƿ��� Delphi ����}

//==============================================================================
// �ļ����жϴ����� (���� GExperts Src 1.12)
//==============================================================================

resourcestring
  SCnDefDelphiSourceMask = '.PAS;.DPR';
  SCnDefCppSourceMask = '.CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';
  SCnDefSourceMask = '.PAS;.DPR;CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';

function CurrentIsDelphiSource: Boolean;
{* ��ǰ�༭���ļ���DelphiԴ�ļ�}
function CurrentIsCSource: Boolean;
{* ��ǰ�༭���ļ���CԴ�ļ�}
function CurrentIsSource: Boolean;
{* ��ǰ�༭���ļ���Delphi��CԴ�ļ�}
function CurrentIsForm: Boolean;
{* ��ǰ�༭���ļ��Ǵ����ļ�}
function IsVCLFormEditor(FormEditor: IOTAFormEditor = nil): Boolean;
{* ����༭�������Ƿ� VCL ���壨�� .NET ���壩}
function ExtractUpperFileExt(const FileName: string): string;
{* ȡ��д�ļ���չ��}
procedure AssertIsDprOrPas(const FileName: string);
{* �ٶ���.Dpr��.Pas�ļ�}
procedure AssertIsDprOrPasOrInc(const FileName: string);
{* �ٶ���.Dpr��.Pas��.Inc�ļ�}
procedure AssertIsPasOrInc(const FileName: string);
{* �ٶ���.Pas��.Inc�ļ�}
function IsSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ�Delphi��C++Դ�ļ�}
function IsDelphiSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ�DelphiԴ�ļ�}
function IsDprOrPas(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpr��.Pas�ļ�}
function IsDpr(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpr�ļ�}
function IsBpr(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpr�ļ�}
function IsProject(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpr��.Dpr�ļ�}
function IsBdsProject(const FileName: string): Boolean;
{* �ж��Ƿ�.bdsproj�ļ�}
function IsDProject(const FileName: string): Boolean;
{* �ж��Ƿ�.dproj�ļ�}
function IsCbProject(const FileName: string): Boolean;
{* �ж��Ƿ�.cbproj�ļ�}
function IsDpk(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpk�ļ�}
function IsBpk(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpk�ļ�}
function IsPackage(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpk��.Bpk�ļ�}
function IsBpg(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpg�ļ�}
function IsPas(const FileName: string): Boolean;
{* �ж��Ƿ�.Pas�ļ�}
function IsDcu(const FileName: string): Boolean;
{* �ж��Ƿ�.Dcu�ļ�}
function IsInc(const FileName: string): Boolean;
{* �ж��Ƿ�.Inc�ļ�}
function IsDfm(const FileName: string): Boolean;
{* �ж��Ƿ�.Dfm�ļ�}
function IsForm(const FileName: string): Boolean;
{* �ж��Ƿ����ļ�}
function IsXfm(const FileName: string): Boolean;
{* �ж��Ƿ�.Xfm�ļ�}
function IsFmx(const FileName: string): Boolean;
{* �ж��Ƿ�.fmx�ļ�}
function IsCppSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ��������͵�C++Դ�ļ�}
function IsHpp(const FileName: string): Boolean;
{* �ж��Ƿ�.Hpp�ļ�}
function IsCpp(const FileName: string): Boolean;
{* �ж��Ƿ�.Cpp�ļ�}
function IsC(const FileName: string): Boolean;
{* �ж��Ƿ�.C�ļ�}
function IsH(const FileName: string): Boolean;
{* �ж��Ƿ�.H�ļ�}
function IsAsm(const FileName: string): Boolean;
{* �ж��Ƿ�.ASM�ļ�}
function IsRC(const FileName: string): Boolean;
{* �ж��Ƿ�.RC�ļ�}
function IsKnownSourceFile(const FileName: string): Boolean;
{* �ж��Ƿ�δ֪�ļ�}
function IsTypeLibrary(const FileName: string): Boolean;
{* �ж��Ƿ��� TypeLibrary �ļ�}
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
{* ʹ���ַ����ķ�ʽ�ж϶����Ƿ�̳��Դ���}
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
{* ʹ���ַ����ķ�ʽ�жϿؼ��Ƿ����ָ���������ӿؼ��������򷵻�������һ��}

//==============================================================================
// OTA �ӿڲ�����غ���
//==============================================================================

function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
{* ��ѯ����ķ���ӿڲ�����һ��ָ���ӿ�ʵ�������ʧ�ܣ����� False}
function CnOtaGetEditBuffer: IOTAEditBuffer;
{* ȡIOTAEditBuffer�ӿ�}
function CnOtaGetEditPosition: IOTAEditPosition;
{* ȡIOTAEditPosition�ӿ�}
function CnOtaGetTopMostEditView: IOTAEditView; overload;
{* ȡ��ǰ��ǰ�˵�IOTAEditView�ӿ�}
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
{* ȡָ���༭����ǰ�˵�IOTAEditView�ӿ�}
function CnOtaGetTopMostEditActions: IOTAEditActions;
{* ȡ��ǰ��ǰ�˵� IOTAEditActions �ӿ�}
function CnOtaGetCurrentModule: IOTAModule;
{* ȡ��ǰģ��}
function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
{* ȡ��ǰԴ��༭��}
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
{* ȡģ��༭��}
function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
{* ȡ����༭��}
function CnOtaGetCurrentFormEditor: IOTAFormEditor;
{* ȡ��ǰ����༭��}
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
{* ȡ�ô���༭���������ؼ�}
function CnOtaGetCurrentDesignContainer: TWinControl;
{* ȡ�õ�ǰ����༭���������ؼ�}
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
{* ȡ�õ�ǰ����༭������ѡ��Ŀؼ�}
function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
{* ��ʾָ��ģ��Ĵ��� (���� GExperts Src 1.2)}
procedure CnOtaShowDesignerForm;
{* ��ʾ��ǰ��ƴ��� }
function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* ȡ��ǰ�Ĵ��������}
function CnOtaGetActiveDesignerType: string;
{* ȡ��ǰ����������ͣ������ַ��� dfm �� xfm}
function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
{* ȡ���������}
function CnOtaGetComponentText(Component: IOTAComponent): string;
{* ��������ı���}
function CnOtaGetModule(const FileName: string): IOTAModule;
{* �����ļ�������ģ��ӿ�}
function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
{* ȡ��ǰ������ģ�������޹��̷��� -1}
function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
{* ȡ��ǰ�����еĵ� Index ��ģ����Ϣ���� 0 ��ʼ}
function CnOtaGetEditor(const FileName: string): IOTAEditor;
{* �����ļ������ر༭���ӿ�}
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
{* ���ش���༭����ƴ������}
function CnOtaGetCurrentEditWindow: TCustomForm;
{* ȡ��ǰ�� EditWindow}
function CnOtaGetCurrentEditControl: TWinControl;
{* ȡ��ǰ�� EditControl �ؼ�}
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
{* ���ص�Ԫ����}
function CnOtaGetProjectGroup: IOTAProjectGroup;
{* ȡ��ǰ������}
function CnOtaGetProjectGroupFileName: string;
{* ȡ��ǰ�������ļ���}
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
{* ȡ������Դ}
function CnOtaGetCurrentProject: IOTAProject;
{* ȡ��ǰ����}
function CnOtaGetProject: IOTAProject;
{* ȡ��һ������}
function CnOtaGetProjectCountFromGroup: Integer;
{* ȡ��ǰ�������й��������޹����鷵�� -1}
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
{* ȡ��ǰ�������еĵ� Index �����̣��� 0 ��ʼ}
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
function CnOtaGetOptionsNames(Options: IOTAOptions; IncludeType:
  Boolean = True): string; overload;
{* ȡ�� IDE ���ñ������б�}
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
{* ���õ�ǰ��Ŀ������ֵ}

function CnOtaGetProjectPlatform(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰPlatformֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰFrameworkTypeֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName: string): string;
{* �����Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName,
  AValue: string);
{* ������Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ���粻֧�ִ�������ʲô������}

procedure CnOtaGetProjectList(const List: TInterfaceList);
{* ȡ�����й����б�}
function CnOtaGetCurrentProjectName: string;
{* ȡ��ǰ��������}
function CnOtaGetCurrentProjectFileName: string;
{* ȡ��ǰ�����ļ�����}
function CnOtaGetCurrentProjectFileNameEx: string;
{* ȡ��ǰ�����ļ�������չ}
function CnOtaGetCurrentFormName: string;
{* ȡ��ǰ��������}
function CnOtaGetCurrentFormFileName: string;
{* ȡ��ǰ�����ļ�����}
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
{* ȡָ��ģ���ļ�����GetSourceEditorFileName ��ʾ�Ƿ񷵻��ڴ���༭���д򿪵��ļ�}
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
{* ȡ��ǰģ���ļ���}
function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
{* ȡ��ǰ��������}
function CnOtaGetEditOptions: IOTAEditOptions;
{* ȡ��ǰ�༭������}
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
{* ȡ��ǰ����ѡ��}
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
{* ȡ��ǰ����ָ��ѡ��}
function CnOtaGetPackageServices: IOTAPackageServices;
{* ȡ��ǰ�����������}

{$IFDEF DELPHI2009_UP}
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* ȡ��ǰ��������ѡ�2009 �����Ч}
{$ENDIF}

function CnOtaGetNewFormTypeOption: TFormType;
{* ȡ�����������½�������ļ�����}
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
{* ����ָ��ģ��ָ���ļ����ĵ�Ԫ�༭��}
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
{* ����ָ��ģ��ָ���ļ����ı༭��}
function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
{* ����ָ��ģ��� EditActions }
function CnOtaGetCurrentSelection: string;
{* ȡ��ǰѡ����ı�}
procedure CnOtaDeleteCurrentSelection;
{* ɾ��ѡ�е��ı�}
procedure CnOtaEditBackspace(Many: Integer);
{* �ڱ༭�����˸�}
procedure CnOtaEditDelete(Many: Integer);
{* �ڱ༭����ɾ��}
function CnOtaGetCurrentProcedure: string;
{* ��ȡ��ǰ������ڵĹ��̻�����}
function CnOtaGetCurrentOuterBlock: string;
{* ��ȡ��ǰ������ڵ�����������}
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
{* ȡָ���е�Դ����}
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
{* ȡ��ǰ��Դ����}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
{* ʹ�� NTA ����ȡ��ǰ��Դ���롣�ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
   ���ʹ�� ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1 
   ��ֵ�� EditPos.Col ���ɡ�}
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
{* ���� SourceEditor ��ǰ����Ϣ}
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil): Boolean;
{* ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ��ٶȽϿ�}
function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
{* ȡ��ǰ����µ��ַ�������ƫ����}
function CnOtaDeleteCurrToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ��}
function CnOtaDeleteCurrTokenLeft(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ����벿��}
function CnOtaDeleteCurrTokenRight(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ���Ұ벿��}
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
{* �ж�λ���Ƿ񳬳���β�� }
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
{* ѡ��һ�������}
function CnOtaCurrBlockEmpty: Boolean;
{* ���ص�ǰѡ��Ŀ��Ƿ�Ϊ�� }
function CnOtaOpenFile(const FileName: string): Boolean;
{* ���ļ�}
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
{* ��δ����Ĵ���}
function CnOtaIsFileOpen(const FileName: string): Boolean;
{* �ж��ļ��Ƿ��}
function CnOtaIsFormOpen(const FormName: string): Boolean;
{* �жϴ����Ƿ��}
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
{* �ж�ģ���Ƿ��ѱ��޸�}
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
{* ָ��ģ���Ƿ����ı����巽ʽ��ʾ, Lines Ϊת��ָ���У�<= 0 ����}
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
{* ��ָ���ļ��ɼ�}
function CnOtaIsDebugging: Boolean;
{* ��ǰ�Ƿ��ڵ���״̬}
function CnOtaGetBaseModuleFileName(const FileName: string): string;
{* ȡģ��ĵ�Ԫ�ļ���}
function CnOtaIsPersistentBlocks: Boolean;
{* ��ǰ PersistentBlocks �Ƿ�Ϊ True}

//==============================================================================
// Դ���������غ���
//==============================================================================

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
{* �ַ���תΪԴ���봮}

function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
{* �������Զ��л�Ϊ���д��롣
 |<PRE>
   Code: string            - Դ����
   Len: Integer            - �п��
   Indent: Integer         - ���к�������ַ���
   IndentOnceOnly: Boolean - �Ƿ���ڲ����ڶ���ʱ��������
 |</PRE>}

{$IFDEF COMPILER6_UP}
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
{* ����ת��Utf8��Ansi�ַ����������ڳ��ȶ�����Ҫ��Ansi�ַ����ַ��� }
{$ENDIF}

function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
{* ת���ַ���Ϊ�༭��ʹ�õ��ַ��� }

function ConvertEditorTextToText(const Text: AnsiString): AnsiString;
{* ת���༭��ʹ�õ��ַ���Ϊ��ͨ�ַ��� }

function CnOtaGetCurrentSourceFile: string;
{* ȡ��ǰ�༭��Դ�ļ�}

function CnOtaGetCurrentSourceFileName: string;
{* ȡ��ǰ�༭�� Pascal �� C Դ�ļ����ж����ƽ϶�}

// �� EditPosition �в���һ���ı���֧�� D2005 ��ʹ�� utf-8 ��ʽ
procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);

type
  TInsertPos = (ipCur, ipFileHead, ipFileEnd, ipLineHead, ipLineEnd);
{* �ı�����λ��
 |<PRE>
   ipCur         - ��ǰ��괦
   ipFileHead    - �ļ�ͷ��
   ipFileEnd     - �ļ�β��
   ipLineHead    - ��ǰ����
   ipLineEnd     - ��ǰ��β
 |</PRE>}

function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos
  = ipCur): Boolean;
{* ����һ���ı�����ǰ���ڱ༭��Դ�ļ��У����سɹ���־
 |<PRE>
   Text: string           - �ı�����
   InsertPos: TInsertPos  - ����λ�ã�Ĭ��Ϊ ipCurr ��ǰλ��
 |</PRE>}

function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
{* ��õ�ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
 |<PRE>
   Col: Integer           - ��λ��
   Row: Integer           - ��λ��
 |</PRE>}

function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
 |<PRE>
   Col: Integer           - ��λ��
   Row: Integer           - ��λ��
 |</PRE>}

function CnOtaSetCurSourceCol(Col: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־}

function CnOtaSetCurSourceRow(Row: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־}

function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
{* �ڵ�ǰ�༭��Դ�ļ����ƶ���꣬���سɹ���־
 |<PRE>
   Pos: TInsertPos        - ���λ��
   Offset: Integer        - ƫ����
 |</PRE>}

function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
{* ���� SourceEditor ��ǰ���λ�õ����Ե�ַ}

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
{* ���� SourceEditor ��ǰ���λ��}

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
{* �༭λ��ת��Ϊ����λ�� }

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
{* ����λ��ת��Ϊ�༭λ�� }

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
{* ����EditReader���ݵ�����}

procedure CnOtaSaveEditorToStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
{* ����༭���ı�������}

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = True): Boolean;
{* ����༭���ı�������}

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
{* ���浱ǰ�༭���ı�������}

function CnOtaGetCurrentEditorSource: string;
{* ȡ�õ�ǰ�༭��Դ����}

procedure CnOtaInsertLineIntoEditor(const Text: string);
{* ����һ���ַ�������ǰ IOTASourceEditor������ Text Ϊ�����ı�ʱ����
   �����滻��ǰ��ѡ���ı���}

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
{* ����һ���ı���ǰ IOTASourceEditor��Line Ϊ�кţ�Text Ϊ���� }

procedure CnOtaInsertTextIntoEditor(const Text: string);
{* �����ı�����ǰ IOTASourceEditor����������ı���}

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
{* Ϊָ�� SourceEditor ����һ�� Writer���������Ϊ�շ��ص�ǰֵ��}

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* ��ָ��λ�ô������ı������ SourceEditor Ϊ��ʹ�õ�ǰֵ��}

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��}

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
{* ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ�� }

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��}

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
{* ת��һ������λ�õ� TOTACharPos����Ϊ�� D5/D6 �� IOTAEditView.PosToCharPos
   ���ܲ�����������}

function CnOtaGetBlockIndent: Integer;
{* ��õ�ǰ�༭����������� }

procedure CnOtaClosePage(EditView: IOTAEditView);
{* �ر�ģ����ͼ}

procedure CnOtaCloseEditView(AModule: IOTAModule);
{* ���ر�ģ�����ͼ�������ر�ģ��}

//==============================================================================
// ���������غ���
//==============================================================================

function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList; 
  ExcludeForm: Boolean = True): Boolean;
{* ȡ�õ�ǰ��ƵĴ��弰ѡ�������б����سɹ���־
 |<PRE>
   var AForm: TCustomForm    - ������ƵĴ���
   Selections: TList         - ��ǰѡ�������б�������� nil �򲻷���
   ExcludeForm: Boolean      - ������ Form ����
   Result: Boolean           - ����ɹ�����Ϊ True
 |</PRE>}

function CnOtaGetCurrFormSelectionsCount: Integer;
{* ȡ��ǰ��ƵĴ�����ѡ��ؼ�������}

function CnOtaIsCurrFormSelectionsEmpty: Boolean;
{* �жϵ�ǰ��ƵĴ������Ƿ�ѡ���пؼ�}

procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor = nil);
{* ֪ͨ��������������ѱ��}

function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor = nil): Boolean;
{* �жϵ�ǰѡ��Ŀؼ��Ƿ�Ϊ��ƴ��屾��}

function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
{* �ж�����ڿؼ���ָ�������Ƿ����}

procedure CnOtaSetCurrFormSelectRoot;
{* ���õ�ǰ����ڴ���ѡ������Ϊ��ƴ��屾��}

procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
{* ȡ�õ�ǰѡ��Ŀؼ��������б�}

procedure CnOtaCopyCurrFormSelectionsName;
{* ���Ƶ�ǰѡ��Ŀؼ��������б�������}

function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
{* ����һ��λ��ֵ}

function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
{* ����һ���༭λ��ֵ }

function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
{* �ж������༭λ���Ƿ���� }

function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
{* �ж������ַ�λ���Ƿ���� }

function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
{* �ж�һ�ؼ������Ƿ��Ƿǿ��ӻ��ؼ�}

function FileExists(const Filename: string): Boolean;
{* Tests for file existance, a lot faster than the RTL implementation }

procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* ��һ EditView �е���ǩ��Ϣ������һ ObjectList ��}

procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* �� ObjectList �лָ�һ EditView �е���ǩ}

function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
  APattern: string; IsMatchStart: Boolean = False): Boolean;
{* �ж�������ʽƥ��}

procedure TranslateFormFromLangFile(AForm: TCustomForm; const ALangDir, ALangFile: string;
  LangID: Cardinal);
{* ����ָ���������ļ����봰��}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFDEF SUPPORTS_FMX}
  CnFmxUtils,
{$ENDIF}
  Math, CnWizOptions, CnWizMultiLang, CnLangMgr, CnGraphUtils, CnWizIdeUtils,
  CnPasCodeParser, CnCppCodeParser, CnLangStorage, CnHashLangStorage, CnWizHelp;

type
  TControlAccess = class(TControl);

  TCnBookmarkObj = class
  private
    FLine: Integer;
    FCol: Integer;
    FID: Integer;
  public
    property ID: Integer read FID write FID;
    property Line: Integer read FLine write FLine;
    property Col: Integer read FCol write FCol;
  end;

var
{$IFDEF COMPILER7_UP}
  OldRegisterNoIconProc: procedure(const ComponentClasses: array of TComponentClass) = nil;
{$ELSE}
  OldRegisterNoIconProc: procedure(ComponentClasses: array of TComponentClass) = nil;
{$ENDIF COMPILER7_UP}

{$IFDEF COMPILER7_UP}
procedure CnRegisterNoIconProc(const ComponentClasses: array of TComponentClass);
{$ELSE}
procedure CnRegisterNoIconProc(ComponentClasses: array of TComponentClass);
{$ENDIF COMPILER7_UP}
var
  i: Integer;
begin
  for i := Low(ComponentClasses) to High(ComponentClasses) do
  begin
    if CnNoIconList.IndexOf(ComponentClasses[i].ClassName) < 0 then
    begin
      CnNoIconList.Add(ComponentClasses[i].ClassName);
    end;
  end;

  if Assigned(OldRegisterNoIconProc) then
    OldRegisterNoIconProc(ComponentClasses);
end;

procedure AddNoIconToList(const ClassName: string);
var
  AClass: TPersistentClass;
begin
  AClass := GetClass(ClassName);
  if Assigned(AClass) then
    CnNoIconList.Add(AClass.ClassName);
end;

//==============================================================================
// ������Ϣ����
//==============================================================================

// �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���
// ����Ϊ Pascal Script ��֧�� TObject(0) �����﷨��
function CnIntToObject(AInt: Integer): TObject;
begin
  Result := TObject(AInt);
end;

var
  FResInited: Boolean;
  HResModule: HMODULE;

// ������ԴDLL�ļ�
function LoadResDll: Boolean;
begin
  if not FResInited then
  begin
    HResModule := LoadLibrary(PChar(WizOptions.DllPath + SCnWizResDllName));
  {$IFDEF DEBUG}
    CnDebugger.LogInteger(HResModule, 'HResModule');
  {$ENDIF}
    FResInited := True;
  end;
  Result := HResModule <> 0;
end;

// �ͷ���ԴDLL�ļ�
procedure FreeResDll;
begin
  if HResModule <> 0 then
    FreeLibrary(HResModule);
  FResInited := False;
end;

// ����Դ���ļ���װ��ͼ��
function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
var
  FileName: string;
  Handle: HICON;
begin
  Result := False;
  
  // ���ļ���װ��
  try
    if SameFileName(_CnExtractFileName(ResName), ResName) then
      FileName := WizOptions.IconPath + ResName + SCnIcoFileExt
    else
      FileName := ResName;
    if FileExists(FileName) then
    begin
      AIcon.LoadFromFile(FileName);
      if not AIcon.Empty then
      begin
        Result := True;
        Exit;
      end;
    end;
  except
    ;
  end;

  // ����Դ��װ��
  if LoadResDll then
  begin
    Handle := LoadImage(HResModule, PChar(UpperCase(ResName)), IMAGE_ICON, 0, 0, 0);
    if Handle <> 0 then
    begin
      AIcon.Handle := Handle;
      Result := True;
    end;
  end;
end;

// ����Դ���ļ���װ��λͼ
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
var
  FileName: string;
begin
  Result := False;
  
  // ���ļ���װ��
  try
    if SameFileName(_CnExtractFileName(ResName), ResName) then
      FileName := WizOptions.IconPath + ResName + SCnBmpFileExt
    else
      FileName := ResName;
    if FileExists(FileName) then
    begin
      ABitmap.LoadFromFile(FileName);
      if not ABitmap.Empty then
      begin
        Result := True;
        Exit;
      end;
    end;
  except
    ;
  end;

  // ����Դ��װ��
  if LoadResDll then
  begin
    ABitmap.LoadFromResourceName(HResModule, UpperCase(ResName));
    Result := not ABitmap.Empty;
  end;
end;

// ����ͼ�굽 ImageList �У�ʹ��ƽ������
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
const
  MaskColor = clBtnFace;
var
  SrcBmp, DstBmp: TBitmap;
  PSrc1, PSrc2, PDst: PRGBArray;
  x, y: Integer;
begin
  Assert(Assigned(AIcon));
  Assert(Assigned(ImageList));
  if (ImageList.Width = 16) and (ImageList.Height = 16) and not AIcon.Empty and
    (AIcon.Width = 32) and (AIcon.Height = 32) then
  begin
    SrcBmp := nil;
    DstBmp := nil;
    try
      SrcBmp := CreateEmptyBmp24(32, 32, MaskColor);
      DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
      SrcBmp.Canvas.Draw(0, 0, AIcon);
      for y := 0 to DstBmp.Height - 1 do
      begin
        PSrc1 := SrcBmp.ScanLine[y * 2];
        PSrc2 := SrcBmp.ScanLine[y * 2 + 1];
        PDst := DstBmp.ScanLine[y];
        for x := 0 to DstBmp.Width - 1 do
        begin
          PDst^[x].b := (PSrc1^[x * 2].b + PSrc1^[x * 2 + 1].b + PSrc2^[x * 2].b
            + PSrc2^[x * 2 + 1].b) shr 2;
          PDst^[x].g := (PSrc1^[x * 2].g + PSrc1^[x * 2 + 1].g + PSrc2^[x * 2].g
            + PSrc2^[x * 2 + 1].g) shr 2;
          PDst^[x].r := (PSrc1^[x * 2].r + PSrc1^[x * 2 + 1].r + PSrc2^[x * 2].r
            + PSrc2^[x * 2 + 1].r) shr 2;
        end;
      end;
      Result := ImageList.AddMasked(DstBmp, MaskColor);
    finally
      if Assigned(SrcBmp) then FreeAndNil(SrcBmp);
      if Assigned(DstBmp) then FreeAndNil(DstBmp);
    end;
  end
  else if not AIcon.Empty then
    Result := ImageList.AddIcon(AIcon)
  else
    Result := -1;
end;

// ����һ�� Disabled ��λͼ�����ض�����Ҫ���÷��ͷ�
function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
const
  ROP_DSPDxax = $00E20746;
var
  MonoBmp: TBitmap;
  Col: TColor;
  tr, tg, tb: Byte;
  P, P1, P2, P3: PRGBArray;
  R: PRGBColor;
  C: array[0..3] of PRGBColor;
  x, y, i: Integer;
  IsEdge: Boolean;
begin
  Result := TBitmap.Create;
  if Assigned(Glyph) then
  begin
    Glyph.PixelFormat := pf24bit;
    Result.Assign(Glyph);
    Result.PixelFormat := pf24bit;
    Result.Canvas.Brush.Color := Glyph.TransparentColor;
    Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));

    Col := ColorToRGB(Glyph.TransparentColor);
    tr := GetRValue(Col);
    tg := GetGValue(Col);
    tb := GetBValue(Col);
    for y := 0 to Result.Height - 1 do
    begin
      P := Result.ScanLine[y];
      P1 := Glyph.ScanLine[Max(y - 1, 0)];
      P2 := Glyph.ScanLine[y];
      P3 := Glyph.ScanLine[Min(y + 1, Result.Height - 1)];
      for x := 0 to Result.Width - 1 do
      begin
        R := @P2^[x];
        if (R^.r <> tr) or (R^.g <> tg) or (R^.b <> tb) then
        begin
          IsEdge := (R^.r + R^.g + R^.b) < 3 * $80;
          if not IsEdge then
          begin
            C[0] := @P1^[x];
            C[1] := @P3^[x];
            C[2] := @P2^[Max(x - 1, 0)];
            C[3] := @P2^[Min(x + 1, Result.Width - 1)];
            for i := 0 to 3 do
              if (C[i]^.r = tr) and (C[i]^.g = tg) and (C[i]^.b = tb) then
              begin
                IsEdge := True;
                Break;
              end;
          end;
          
          if IsEdge then
          begin
            R := @P^[x];
            R^.b := 0;
            R^.g := 0;
            R^.r := 0;
          end
        end;
      end;
    end;

    MonoBmp := TBitmap.Create;
    try
      with MonoBmp do
      begin
        Assign(Result);
        HandleType := bmDDB;
        Canvas.Brush.Color := clBlack;
        Width := Result.Width;
        if Monochrome then
        begin
          Canvas.Font.Color := clWhite;
          Monochrome := False;
          Canvas.Brush.Color := clWhite;
        end;
        Monochrome := True;
      end;
      with Result.Canvas do
      begin
        Brush.Color := clBtnFace;
        FillRect(Rect(0, 0, Result.Width, Result.Height));
        Brush.Color := clBtnHighlight;
        SetTextColor(Handle, clBlack);
        SetBkColor(Handle, clWhite);
        BitBlt(Handle, 1, 1, Result.Width, Result.Height,
          MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
        Brush.Color := clBtnShadow;
        SetTextColor(Handle, clBlack);
        SetBkColor(Handle, clWhite);
        BitBlt(Handle, 0, 0, Result.Width, Result.Height,
          MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
      end;
    finally
      MonoBmp.Free;
    end;
  end;
end;

// Delphi �İ�ť�� Disabled ״̬ʱ����ʾ��ͼ����ѿ����ú���ͨ����ԭλͼ�Ļ�����
// ����һ���µĻҶ�λͼ�������һ���⣬������ɺ� Glyph ��ȱ�Ϊ�߶ȵ���������Ҫ
// ���� Button.NumGlyphs := 2
procedure AdjustButtonGlyph(Glyph: TBitmap);
var
  Bmp, Bmp2: TBitmap;
begin
  if Assigned(Glyph) then
  begin
    Bmp := CreateDisabledBitmap(Glyph);
    try
      Bmp2 := TBitmap.Create;
      try
        Bmp2.Assign(Glyph);
        Glyph.Width := Glyph.Width * 2;
        Glyph.Canvas.Brush.Color := Glyph.TransparentColor;
        Glyph.Canvas.FillRect(Rect(0, 0, Glyph.Width, Glyph.Height));
        Glyph.Canvas.Draw(0, 0, Bmp2);
        Glyph.Canvas.Draw(Bmp.Width, 0, Bmp);
      finally
        Bmp2.Free;
      end;
    finally
      Bmp.Free;
    end;
  end;
end;

// �ļ�����ͬ
function SameFileName(const S1, S2: string): Boolean;
begin
  Result := (CompareText(S1, S2) = 0);
end;

// ѹ���ַ����м�Ŀհ��ַ�
function CompressWhiteSpace(const Str: string): string;
var
  i: Integer;
  Len: Integer;
  NextResultChar: Integer;
  CheckChar: Char;
  NextChar: Char;
begin
  Len := Length(Str);
  NextResultChar := 1;
  SetLength(Result, Len);

  for i := 1 to Len do
  begin
    CheckChar := Str[i];
    NextChar := Str[i + 1];
    case CheckChar of
      #9, #10, #13, #32:
        begin
          if CharInSet(NextChar, [#0, #9, #10, #13, #32]) or (NextResultChar = 1) then
            Continue
          else
          begin
            Result[NextResultChar] := #32;
            Inc(NextResultChar);
          end;
        end;
      else
        begin
          Result[NextResultChar] := Str[i];
          Inc(NextResultChar);
        end;
    end;
  end;
  if Len = 0 then
    Exit;
  SetLength(Result, NextResultChar - 1);
end;

// ��ʾָ������İ�������
procedure ShowHelp(const Topic: string);
begin
  if not CnWizHelp.ShowHelp(Topic) then
    ErrorDlg(SCnNoHelpofThisLang);
end;

// �������
procedure CenterForm(const Form: TCustomForm);
var
  Rect: TRect;
begin
  if Form = nil then
    Exit;

  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);

  with Form do
  begin
    SetBounds((Rect.Right - Rect.Left - Width) div 2,
      (Rect.Bottom - Rect.Top - Height) div 2, Width, Height);
  end;
end;

// ��֤����ɼ�
procedure EnsureFormVisible(const Form: TCustomForm);
var
  Rect: TRect;
begin
  Rect.Top := 0;
  Rect.Left := 0;
  Rect.Right := Screen.Width;
  Rect.Bottom := Screen.Height;
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);
  if (Form.Left + Form.Width > Rect.Right) then
    Form.Left := Form.Left - ((Form.Left + Form.Width) - Rect.Right);
  if (Form.Top + Form.Height > Rect.Bottom) then
    Form.Top := Form.Top - ((Form.Top + Form.Height) - Rect.Bottom);
  if Form.Left < 0 then
    Form.Left := 0;
  if Form.Top < 0 then
    Form.Top := 0;
end;

// ɾ���������ȼ���Ϣ
function GetCaptionOrgStr(const Caption: string): string;
var
  i, l: Integer;
begin
  Result := Caption;
  for i := Length(Result) downto 1 do
    if Result[i] = '.' then
      Delete(Result, i, 1);

  l := Length(Result);
  if l > 4 then
    if CharInSet(Result[l - 3], ['(', '[']) and (Result[l - 2] = '&') and
      CharInSet(Result[l], [')', ']']) then
      Delete(Result, l - 3, 4);

  Result := StringReplace(Result, '&', '', [rfReplaceAll]);
end;

//ȡ�� IDE �� ImageList
function GetIDEImageList: TCustomImageList;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ImageList;
end;

// ���� IDE ImageList �е�ͼ��ָ��Ŀ¼��}
procedure SaveIDEImageListToPath(const Path: string);
var
  ImgList: TCustomImageList;
  Bmp: TBitmap;
  i: Integer;
begin
  if not DirectoryExists(Path) then
    Exit;
  ImgList := GetIDEImageList;
  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf24bit;
  Bmp.Width := ImgList.Width;
  Bmp.Height := ImgList.Height;
  try
    for i := 0 to ImgList.Count - 1 do
    begin
      Bmp.Canvas.Brush.Color := clFuchsia;
      Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
      ImgList.GetBitmap(i, Bmp);
      Bmp.SaveToFile(MakePath(Path) + IntToStrEx(i, 3) + '.bmp');
    end;
  finally
    Bmp.Free;
  end;
end;

// ����˵������б��ļ�
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
var
  i: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    for i := 0 to AMenu.Count - 1 do
      List.Add(AMenu.Items[i].Name + ' | ' + AMenu.Items[i].Caption);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// ȡ�� IDE ���˵�
function GetIDEMainMenu: TMainMenu;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.MainMenu;
end;

// ȡ�� IDE ���˵��µ� Tools �˵�
function GetIDEToolsMenu: TMenuItem;
var
  MainMenu: TMainMenu;
  i: Integer;
begin
  MainMenu := GetIDEMainMenu; // IDE���˵�
  if MainMenu <> nil then
  begin
    for i := 0 to MainMenu.Items.Count - 1 do
      if AnsiCompareText(SToolsMenuName, MainMenu.Items[i].Name) = 0 then
      begin
        Result := MainMenu.Items[i];
        Exit;
      end
  end;
  Result := nil;
end;
  
// ȡ�� IDE �� ActionList
function GetIDEActionList: TCustomActionList;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ActionList;
end;

// ȡ�� IDE �� ActionList ��ָ����ݼ��� Action
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
var
  I: Integer;
  ActionList: TCustomActionList;
begin
  Result := nil;
  ActionList := GetIDEActionList;
  if ActionList <> nil then
    for I := 0 to ActionList.ActionCount - 1 do
      if ActionList.Actions[I] is TCustomAction then
        if TCustomAction(ActionList.Actions[I]).ShortCut = ShortCut then
        begin
          Result := TCustomAction(ActionList.Actions[I]);
          Exit;
        end;  
end;  

// ȡ�� IDE ��Ŀ¼
function GetIdeRootDirectory: string;
begin
  Result := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));
end;

// �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��
function ReplaceToActualPath(const Path: string): string;
{$IFDEF COMPILER6_UP}
var
  Vars: TStringList;
  i: Integer;
{$IFDEF DELPHI2011_UP}
  BC: IOTAProjectOptionsConfigurations;
{$ENDIF}
begin
  Result := Path;
  Vars := TStringList.Create;
  try
    GetEnvironmentVars(Vars, True);
    for i := 0 to Vars.Count - 1 do
      Result := StringReplace(Result, '$(' + Vars.Names[i] + ')',
        Vars.Values[Vars.Names[i]], [rfReplaceAll, rfIgnoreCase]);
    {$IFDEF DELPHI2011_UP}
      BC := CnOtaGetActiveProjectOptionsConfigurations(nil);
      if BC <> nil then
        if BC.GetActiveConfiguration <> nil then
        begin
          Result := StringReplace(Result, '$(Config)',
            BC.GetActiveConfiguration.GetName, [rfReplaceAll, rfIgnoreCase]);
    {$IFDEF DELPHI2012_UP}
          Result := StringReplace(Result, '$(Platform)',
            BC.GetActiveConfiguration.GetPlatform, [rfReplaceAll, rfIgnoreCase]);
    {$ENDIF}
        end;
    {$ENDIF}
  finally
    Vars.Free;
  end;   
end;  
{$ELSE}
begin
  // Delphi5 �²�֧�ֻ�������
  Result := StringReplace(Path, SCnIDEPathMacro, MakeDir(GetIdeRootDirectory),
    [rfReplaceAll, rfIgnoreCase]);
end;
{$ENDIF}

// ���� IDE ActionList �е����ݵ�ָ���ļ�
procedure SaveIDEActionListToFile(const FileName: string);
var
  ActionList: TCustomActionList;
  i: Integer;
  List: TStrings;
begin
  ActionList := GetIDEActionList;
  List := TStringList.Create;
  try
    for i := 0 to ActionList.ActionCount - 1 do
      if ActionList.Actions[i] is TCustomAction then
        with ActionList.Actions[i] as TCustomAction do
          List.Add(Name + ' | ' + Caption)
      else
        List.Add(ActionList.Actions[i].Name);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// ���� IDE �������ñ�������ָ���ļ�
procedure SaveIDEOptionsNameToFile(const FileName: string);
var
  Options: IOTAEnvironmentOptions;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Assigned(Options) then
    SaveStringToFile(CnOtaGetOptionsNames(Options), FileName);
end;

// ���浱ǰ���̻������ñ�������ָ���ļ�
procedure SaveProjectOptionsNameToFile(const FileName: string);
var
  Options: IOTAProjectOptions;
begin
  Options := CnOtaGetActiveProjectOptions;
  if Assigned(Options) then
    SaveStringToFile(CnOtaGetOptionsNames(Options), FileName);
end;

// ���� IDE Action �������ض���
function FindIDEAction(const ActionName: string): TContainedAction;
var
  Svcs40: INTAServices40;
  ActionList: TCustomActionList;
  i: Integer;
begin
  if ActionName = '' then 
  begin
    Result := nil;
    Exit;
  end;

  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  ActionList := Svcs40.ActionList;
  for i := 0 to ActionList.ActionCount - 1 do
    if SameText(ActionList.Actions[i].Name, ActionName) then
    begin
      Result := ActionList.Actions[i];
      Exit;
    end;
  Result := nil;
end;

// ���� IDE Action ����ִ����
function ExecuteIDEAction(const ActionName: string): Boolean;
var
  Action: TContainedAction;
begin
  Action := FindIDEAction(ActionName);
  if Assigned(Action) then
    Result := Action.Execute
  else
    Result := False;
end;

// ����һ���Ӳ˵���
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
begin
  Result := TMenuItem.Create(Menu);
  Result.Caption := Caption;
  Result.OnClick := OnClick;
  Result.ShortCut := ShortCut;
  if Hint = '' then
    Result.Hint := StripHotkey(Caption)
  else
    Result.Hint := Hint;
  Result.Tag := Tag;
  Result.Action := Action;
  Menu.Add(Result);
end;

// ����һ���ָ��˵���
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
begin
  Result := AddMenuItem(Menu, '-');
end;

// ���� TCnMenuWizard �б��е� MenuOrder ֵ������С���������
procedure SortListByMenuOrder(List: TList);
var
  i, j: Integer;
  P: Pointer;
begin
  // ð������
  if List.Count = 1 then
    Exit;
    
  for i := List.Count - 2 downto 0 do
    for j := 0 to i do
    begin
      if TCnMenuWizard(List.Items[j]).MenuOrder >
        TCnMenuWizard(List.Items[j + 1]).MenuOrder then  // ��ͷ�ں��
        begin
          P := List.Items[j];
          List.Items[j] := List.Items[j + 1];
          List.Items[j + 1] := P;
        end;
    end;
end;

// ���� DFM �ļ��Ƿ��ı���ʽ
function IsTextForm(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  C: Char;
begin
  Result := False;
  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      FileStream.Position := 0;
      if FileStream.Read(C, SizeOf(C)) = SizeOf(C) then
        if CharInSet(C, ['o','O','i','I',' ',#13,#11,#9]) then
          Result := True;
    finally
      FileStream.Free;
    end;
  except
    ;
  end;
end;

// ����һЩִ�з����е��쳣
procedure DoHandleException(const ErrorMsg: string);
begin
{$IFDEF Debug}
  CnDebugger.LogMsgWithType('Error: ' + ErrorMsg, cmtError);
{$ENDIF Debug}
end;

// �ڴ��ڿؼ��в���ָ����������
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
var
  i: Integer;
begin
  for i := 0 to AWinControl.ComponentCount - 1 do
    if (AWinControl.Components[i] is AClass) and ((AComponentName = '') or
      (SameText(AComponentName, AWinControl.Components[i].Name))) then
    begin
      Result := AWinControl.Components[i];
      Exit;
    end;
  Result := nil;
end;

// �ڴ��ڿؼ��в���ָ�������������
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
var
  i: Integer;
begin
  for i := 0 to AWinControl.ComponentCount - 1 do
    if AWinControl.Components[i].ClassNameIs(AClassName) and ((AComponentName = 
      '') or (SameText(AComponentName, AWinControl.Components[i].Name))) then
    begin
      Result := AWinControl.Components[i];
      Exit;
    end;
  Result := nil;
end;

// ����ģʽ����
function ScreenHasModalForm: Boolean;
var
  i: Integer;
begin
  for i := 0 to Screen.CustomFormCount - 1 do
    if fsModal in Screen.CustomForms[i].FormState then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

// ȥ������ı���
procedure SetFormNoTitle(Form: TForm);
var
  Style: Integer;
  H: Integer;
  Max: boolean;                         // for refresh form
begin
  Max := Form.WindowState = wsMaximized;
  if Max then Form.WindowState := wsNormal;
  H := Form.Width;
  Style := GetWindowLong(Form.Handle, GWL_STYLE);
  SetWindowLong(Form.Handle, GWL_STYLE, Style and not WS_CAPTION);
  // only for refresh form
  Form.Width := H + 1;
  Form.Width := H;
  if Max then Form.WindowState := wsNormal;
end;

// ����һ�������¼�
procedure SendKey(vk: Word);
begin
  keybd_event(vk, 0, 0, 0);
  keybd_event(vk, 0, KEYEVENTF_KEYUP, 0);
end;

// �ж����뷨�Ƿ��
function IMMIsActive: Boolean;
begin
  Result := ImmIsIME(GetKeyBoardLayOut(0));
end;

// ȡ�༭�������Ļ������
function GetCaretPosition(var Pt: TPoint): Boolean;
begin
  Result := Windows.GetCaretPos(Pt);
  if Result then
  begin
    Windows.ClientToScreen(Windows.GetFocus(), Pt);
  end;
end;

type
  TCnGetListClass = class
    FList: TStrings;
    procedure GetProc(const S: string);
  end;

procedure TCnGetListClass.GetProc(const S: string);
begin
  FList.Add(S);
end;  

// ȡCursor��ʶ���б�
procedure GetCursorList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetCursorValues(GetProc);
  finally
    Free;
  end;
end;

// ȡFontCharset��ʶ���б�
procedure GetCharsetList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetCharsetValues(GetProc);
  finally
    Free;
  end;
end;

// ȡColor��ʶ���б�
procedure GetColorList(List: TStrings);
begin
  with TCnGetListClass.Create do
  try
    FList := List;
    GetColorValues(GetProc);
  finally
    Free;
  end;
end;

// ʹ�ؼ������׼�༭��ݼ�
function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;

  function SendMessageToActiveControl(Msg: Cardinal): Boolean;
  begin
    if (AControl is TCustomEdit) or (AControl is TCustomComboBox) then
    begin
      SendMessage(AControl.Handle, Msg, 0, 0);
      Result := True;
    end
    else
      Result := False;
  end;
begin
  if AControl = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  if AShortCut = ShortCut(Word('C'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_COPY)
  else if AShortCut = ShortCut(Word('X'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_CUT)
  else if AShortCut = ShortCut(Word('V'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_PASTE)
  else if AShortCut = ShortCut(Word('Z'), [ssCtrl]) then
    Result := SendMessageToActiveControl(WM_UNDO)
  else if AShortCut = ShortCut(Word('A'), [ssCtrl]) then
  begin
    if AControl is TCustomEdit then
      TCustomEdit(AControl).SelectAll
    else if AControl is TCustomComboBox then
      TCustomComboBox(AControl).SelectAll
    else
      Result := False;
  end
  else
    Result := False;
end;

//==============================================================================
// �ؼ�������
//==============================================================================

// ��������ı���
function CnGetComponentText(Component: TComponent): string;
var
  Text: string;

  function GetCompPropText(const PropName: string; var AText: string): Boolean;
  var
    PInfo: PPropInfo;
  begin
    Result := False;
    PInfo := GetPropInfo(Component, PropName, [tkString, tkLString, tkWString
      {$IFDEF UNICODE_STRING}, tkUString{$ENDIF}]);
    if PInfo <> nil then
    begin
      AText := GetStrProp(Component, PInfo);
      Result := AText <> '';
    end;
  end;
begin
  Result := '';
  if Assigned(Component) then
  begin
    if Component is TCustomAction then
      Result := TCustomAction(Component).Caption
    else if Component is TMenuItem then
      Result := TMenuItem(Component).Caption
  {$IFDEF COMPILER6_UP}
    else if Component is TLabeledEdit then
      Result := TLabeledEdit(Component).EditLabel.Caption
  {$ENDIF}
    else if GetCompPropText('Caption', Text) or GetCompPropText('Text', Text) or
      GetCompPropText('Title', Text) or GetCompPropText('Filter', Text) or
      GetCompPropText('FieldName', Text) or GetCompPropText('TableName', Text) then
      Result := Text
    else if Component is TControl then
      Result := TControlAccess(Component).Text;
  end;
end;

// ȡ�ؼ������� Action
function CnGetComponentAction(Component: TComponent): TBasicAction;
begin
  if Component is TControl then
    Result := TControl(Component).Action
  else if Component is TMenuItem then
    Result := TMenuItem(Component).Action
  else
    Result := nil;
end;

// ���� ListView �ؼ���ȥ������� SubItemImages
procedure RemoveListViewSubImages(ListView: TListView); overload;
{$IFDEF BDS}
var
  i, j: Integer;
{$ENDIF}
begin
{$IFDEF BDS}
  for i := 0 to ListView.Items.Count - 1 do
    for j := 0 to ListView.Items[i].SubItems.Count - 1 do
      ListView.Items[i].SubItemImages[j] := -1;
{$ENDIF}
end;

// ���� ListItem��ȥ������� SubItemImages
procedure RemoveListViewSubImages(ListItem: TListItem); overload;
{$IFDEF BDS}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF BDS}
  for I := 0 to ListItem.SubItems.Count - 1 do
      ListItem.SubItemImages[I] := -1;
{$ENDIF}
end;

{* ת�� ListView ������Ϊ�ַ��� }
function GetListViewWidthString(AListView: TListView): string;
var
  i: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    for i := 0 to AListView.Columns.Count - 1 do
      Lines.Add(IntToStr(AListView.Columns[i].Width));
    Result := Lines.CommaText;
  finally
    Lines.Free;
  end;
end;

{* ת���ַ���Ϊ ListView ������ }
procedure SetListViewWidthString(AListView: TListView; const Text: string);
var
  i: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.CommaText := Text;
    for i := 0 to Min(AListView.Columns.Count - 1, Lines.Count - 1) do
      AListView.Columns[i].Width := StrToIntDef(Lines[i], AListView.Columns[i].Width);
  finally
    Lines.Free;
  end;
end;

// ListView ��ǰѡ�����Ƿ���������
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to AListView.Items.Count - 1 do
    if AListView.Items[i].Selected and not AListView.Items[i - 1].Selected then
    begin
      Result := True;
      Exit;
    end;
end;

// ListView ��ǰѡ�����Ƿ���������
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := AListView.Items.Count - 2 downto 0 do
    if AListView.Items[i].Selected and not AListView.Items[i + 1].Selected then
    begin
      Result := True;
      Exit;
    end;
end;

// �޸� ListView ��ǰѡ����
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
var
  i: Integer;
begin
  for i := 0 to AListView.Items.Count - 1 do
    if Mode = smAll then
      AListView.Items[i].Selected := True
    else if Mode = smNone then
      AListView.Items[i].Selected := False
    else
      AListView.Items[i].Selected := not AListView.Items[i].Selected;
end;

//==============================================================================
// �ļ����жϴ����� (���� GExperts Src 1.12)
//==============================================================================

// ��ǰ�༭���ļ���DelphiԴ�ļ�
function CurrentIsDelphiSource: Boolean;
begin
  Result := WizOptions.IsDelphiSource(CnOtaGetCurrentSourceFile);
end;

// ��ǰ�༭���ļ���CԴ�ļ�
function CurrentIsCSource: Boolean;
begin
  Result := WizOptions.IsCSource(CnOtaGetCurrentSourceFile);
end;

// ��ǰ�༭���ļ���Delphi��CԴ�ļ�
function CurrentIsSource: Boolean;
begin
{$IFDEF BDS}
  Result := (CurrentIsDelphiSource or CurrentIsCSource) and
    (CnOtaGetEditPosition <> nil);
{$ELSE}
  Result := CurrentIsDelphiSource or CurrentIsCSource;
{$ENDIF}
end;

// ��ǰ�༭���ļ��Ǵ����ļ�
function CurrentIsForm: Boolean;
begin
  Result := IsForm(CnOtaGetCurrentSourceFile);
end;

// ����༭�������Ƿ� VCL ���壨�� .NET ���壩
function IsVCLFormEditor(FormEditor: IOTAFormEditor = nil): Boolean;
begin
  if FormEditor = nil then
    Result := CurrentIsForm
  else
  begin
{$IFDEF COMPILER6_UP}
    Result := IsForm(FormEditor.FileName);
{$ELSE}
    Result := True;
{$ENDIF}
  end;
end;
  
function ExtractUpperFileExt(const FileName: string): string;
begin
  Result := UpperCase(_CnExtractFileExt(FileName));
end;

procedure AssertIsDprOrPas(const FileName: string);
begin
  if not IsDprOrPas(FileName) then
    raise Exception.Create(SCnWizardForPasOrDprOnly);
end;

procedure AssertIsPasOrInc(const FileName: string);
begin
  if not (IsPas(FileName) or IsInc(FileName)) then
    raise Exception.Create(SCnWizardForPasOrIncOnly);
end;

procedure AssertIsDprOrPasOrInc(const FileName: string);
begin
  if not (IsDprOrPas(FileName) or IsInc(FileName)) then
    raise Exception.Create(SCnWizardForDprOrPasOrIncOnly);
end;

function IsSourceModule(const FileName: string): Boolean;
begin
  Result := IsDelphiSourceModule(FileName) or IsCppSourceModule(FileName);
end;

function IsDelphiSourceModule(const FileName: string): Boolean;
begin
  Result := IsDprOrPas(FileName);
end;

function IsDprOrPas(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.PAS') or (FileExt = '.DPR'));
end;

function IsDpr(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPR');
end;

function IsBpr(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPR');
end;

function IsProject(const FileName: string): Boolean;
begin
  Result := IsDpr(FileName) or IsBpr(FileName);
end;

function IsBdsProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BDSPROJ');
end;

function IsDProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPROJ');
end;

function IsCbProject(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.CBPROJ');
end;

function IsDpk(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DPK');
end;

function IsBpk(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPK');
end;

function IsPackage(const FileName: string): Boolean;
begin
  Result := IsDpk(FileName) or IsBpk(FileName);
end;

function IsBpg(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.BPG')  or (FileExt = '.BDSGROUP') or (FileExt = '.GROUPPROJ');
end;

function IsPas(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.PAS');
end;

function IsDcu(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DCU');
end;

function IsInc(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.INC');
end;

function IsDfm(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.DFM');
end;

// �ж��ļ��Ƿ���
function IsForm(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.DFM') or (FileExt = '.XFM');
{$IFDEF SUPPORTS_FMX}
  if not Result then
    Result := (FileExt = '.FMX');
{$ENDIF}
end;

function IsXfm(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.XFM');
end;

function IsFmx(const FileName: string): Boolean;
begin
  Result := (ExtractUpperFileExt(FileName) = '.FMX');
end;

function IsCppSourceModule(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.CPP') or (FileExt = '.C') or
             (FileExt = '.HPP') or (FileExt = '.H') or
             (FileExt = '.CXX') or (FileExt = '.CC') or
             (FileExt = '.HXX') or (FileExt = '.HH') or
             (FileExt = '.ASM'));
end;

function IsHpp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.HPP') or (FileExt = '.HH');
end;

function IsCpp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.CPP') or (FileExt = '.CC');
end;

function IsC(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.C');
end;

function IsH(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.H');
end;

function IsAsm(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.ASM');
end;

function IsRC(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.RC');
end;

function IsKnownSourceFile(const FileName: string): Boolean;
begin
  Result := IsDprOrPas(FileName) or IsCppSourceModule(FileName);
end;

function IsTypeLibrary(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := ((FileExt = '.TLB')
          or (FileExt = '.OLB')
          or (FileExt = '.OCX')
          or (FileExt = '.DLL')
          or (FileExt = '.EXE'));
end;

// ʹ���ַ����ķ�ʽ�ж϶����Ƿ�̳��Դ���
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
var
  AClass: TClass;
begin
  Result := False;
  AClass := AObj.ClassType;
  while AClass <> nil do
  begin
    if AClass.ClassNameIs(AClassName) then
    begin
      Result := True;
      Exit;
    end;
    AClass := AClass.ClassParent;
  end;
end;

// ʹ���ַ����ķ�ʽ�жϿؼ��Ƿ����ָ���������ӿؼ��������򷵻�������һ��
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
var
  I: Integer;
begin
  if AParent <> nil then
    for I := AParent.ControlCount - 1 downto 0 do // ���������ҵ��������
      if AParent.Controls[I].ClassNameIs(AClassName) then
      begin
        Result := AParent.Controls[I];
        Exit;
      end;
  Result := nil;
end;


//==============================================================================
// OTA �ӿڲ�����غ���
// ���´󲿷ִ����޸��� GxExperts Src 1.11
//==============================================================================

// ��ѯ����ķ���ӿڲ�����һ��ָ���ӿ�ʵ�������ʧ�ܣ����ؼ�
function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
begin
  Result := (Instance <> nil) and Supports(Instance, Intf, Inst);
{$IFDEF Debug}
  if not Result then
    CnDebugger.LogMsgWithType('Query services interface fail: ' + GUIDToString(Intf), cmtError);
{$ENDIF Debug}
end;

// ȡIOTAEditBuffer�ӿ�
function CnOtaGetEditBuffer: IOTAEditBuffer;
var
  iEditorServices: IOTAEditorServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, iEditorServices);
  if iEditorServices <> nil then
  begin
    Result := iEditorServices.GetTopBuffer;
    Exit;
  end;
  Result := nil;
end;

// ȡIOTAEditPosition�ӿ�
function CnOtaGetEditPosition: IOTAEditPosition;
var
  iEditBuffer: IOTAEditBuffer;
begin
  iEditBuffer := CnOtaGetEditBuffer;
  if iEditBuffer <> nil then
  begin
    Result := iEditBuffer.GetEditPosition;
    Exit;
  end;
  Result := nil;
end;

// ȡ��ǰ��ǰ�˵�IOTAEditView�ӿ�
function CnOtaGetTopMostEditView: IOTAEditView;
var
  iEditBuffer: IOTAEditBuffer;
begin
  iEditBuffer := CnOtaGetEditBuffer;
  if iEditBuffer <> nil then
  begin
    Result := iEditBuffer.GetTopView;
    Exit;
  end;
  Result := nil;
end;

// ȡָ���༭����ǰ�˵�IOTAEditView�ӿ�
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView;
var
  EditBuffer: IOTAEditBuffer;
begin
  if SourceEditor = nil then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor <> nil then
  begin
    QuerySvcs(SourceEditor, IOTAEditBuffer, EditBuffer);
    if EditBuffer <> nil then
    begin
      Result := EditBuffer.TopView;
      Exit;
    end
    else if SourceEditor.EditViewCount > 0 then
    begin
      Result := SourceEditor.EditViews[0];
      Exit;
    end;
  end;
  Result := nil;
end;

// ȡ��ǰ��ǰ�˵� IOTAEditActions �ӿ�
function CnOtaGetTopMostEditActions: IOTAEditActions;
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView <> nil then
  begin
    QuerySvcs(EditView, IOTAEditActions, Result);
    Exit;
  end;
  Result := nil;
end;

// ȡ��ǰģ��
function CnOtaGetCurrentModule: IOTAModule;
var
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices <> nil then
  begin
    Result := iModuleServices.CurrentModule;
    Exit;
  end;
  Result := nil;
end;

// ȡ��ǰԴ��༭��
function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
var
  EditBuffer: IOTAEditBuffer;
begin
  Result := nil;
  EditBuffer := CnOtaGetEditBuffer;
  if Assigned(EditBuffer) and (EditBuffer.FileName <> '') then
    Result := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule, EditBuffer.FileName);
  if Result = nil then
    Result := CnOtaGetSourceEditorFromModule(CnOtaGetCurrentModule);
end;

// ȡģ��༭�� (���� GExperts Src 1.12)
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
begin
  Result := nil;
  if not Assigned(Module) then Exit;
  try
    // BCB 5 ��Ϊһ���򵥵ĵ�Ԫ���� GetModuleFileEditor(1) �����
    {$IFDEF BCB5}
    if IsCpp(Module.FileName) and (Module.GetModuleFileCount = 2) and (Index = 1) then
      Index := 2;
    {$ENDIF}
    Result := Module.GetModuleFileEditor(Index);
  except
    Result := nil; // �� IDE �ͷ�ʱ�����ܻ����쳣����
  end;
end;

// ȡ����༭�� (���� GExperts Src 1.12)
function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
var
  i: Integer;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
begin
  if Assigned(Module) then
  begin
      for i := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := CnOtaGetFileEditorForModule(Module, i);
        if Supports(Editor, IOTAFormEditor, FormEditor) then
        begin
          Result := FormEditor;
          Exit;
        end;
      end;
  end;
  Result := nil;
end;

// ȡ��ǰ����༭��
function CnOtaGetCurrentFormEditor: IOTAFormEditor;
var
  Module: IOTAModule;
begin
  Module := CnOtaGetCurrentModule;
  if Assigned(Module) then
  begin    
    Result := CnOtaGetFormEditorFromModule(Module);
    Exit;
  end;   
  Result := nil;
end;

// ȡ�ô���༭���������ؼ�
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
var
  Root: TComponent;
begin
  { TODO : ֧��Ϊ Root �� TWinControl ����ƶ���ȡ�� Container }
  Result := nil;
  Root := CnOtaGetRootComponentFromEditor(FormEditor);
  if Root is TWinControl then
  begin
    Result := Root as TWinControl;
    while Assigned(Result) and Assigned(Result.Parent) do
      Result := Result.Parent;
  end;
end;

// ȡ�õ�ǰ����༭���������ؼ�
function CnOtaGetCurrentDesignContainer: TWinControl;
begin
  if CurrentIsForm then
    Result := CnOtaGetDesignContainerFromEditor(CnOtaGetCurrentFormEditor)
  else
    Result := nil;
end;

// ȡ�õ�ǰ����༭������ѡ��Ŀؼ�
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  i: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for i := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(i);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
      begin
        if (Component is TControl) and Assigned(TControl(Component).Parent) then
          List.Add(Component);
{$IFDEF SUPPORTS_FMX}
        if CnFmxIsInheritedFromControl(Component) then
        begin
          if Assigned(CnFmxGetControlParent(Component)) then
            List.Add(Component);
        end;
{$ENDIF}
      end;
    end;
  end;

  Result := List.Count > 0;
end;

// ��ʾָ��ģ��Ĵ��� (���� GExperts Src 1.2)
function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
var
  FormEditor: IOTAFormEditor;
begin
  Result := False;
  if Module = nil then Exit;
  FormEditor := CnOtaGetFormEditorFromModule(Module);
  if Assigned(FormEditor) then
  begin
    FormEditor.Show;
    Result := True;
  end;
end;

// ȡ��ǰ�Ĵ��������
function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor): IDesigner;
var
  NTAFormEditor: INTAFormEditor;
begin
  if not Assigned(FormEditor) then
    FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);

  if (FormEditor = nil) or not IsVCLFormEditor(FormEditor) then
  begin
    Result := nil;
    Exit;
  end;
  QuerySvcs(FormEditor, INTAFormEditor, NTAFormEditor);
  if NTAFormEditor <> nil then
  begin
    Result := NTAFormEditor.GetFormDesigner;
    Exit;
  end;
  Result := nil;
end;

// ȡ��ǰ����������ͣ������ַ��� dfm �� xfm
function CnOtaGetActiveDesignerType: string;
{$IFDEF COMPILER6_UP}
var
  Svcs: IOTAServices;
{$ENDIF}
begin
  Result := 'dfm';
{$IFDEF COMPILER6_UP}
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Result := Svcs.GetActiveDesignerType;
{$ENDIF}
end;

// ��ʾ��ǰ��ƴ���
procedure CnOtaShowDesignerForm;
begin
  try
  {$IFDEF COMPILER6_UP}
    if (ComponentDesigner.ActiveRoot <> nil)
      and Assigned(ComponentDesigner.ActiveRoot.GetFormEditor) then
      ComponentDesigner.ActiveRoot.GetFormEditor.Show;
  {$ELSE}
    if Assigned(CompLib) and Assigned(CompLib.GetActiveForm)
      and (CompLib.GetActiveForm.GetFormEditor <> nil) then
      CompLib.GetActiveForm.GetFormEditor.Show;
  {$ENDIF}
  except
    ;
  end;
end;

// ȡ���������
function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
var
{$IFDEF COMPILER6_UP}
  CompIntf: INTAComponent;
{$ELSE}
  CompIntf: IComponent;
{$ENDIF}
begin
  Result := False;
{$IFDEF COMPILER6_UP}
  CompIntf := Component as INTAComponent;
{$ELSE}
  CompIntf := Component.GetIComponent;
{$ENDIF}
  Name := '';
  if CompIntf = nil then
    Exit
  else
  begin
  {$IFDEF COMPILER6_UP}
    Name := CompIntf.GetComponent.Name;
  {$ELSE}
    Name := CompIntf.Name;
  {$ENDIF}
    Result := True;
  end;
end;

// �������� TControl�����������
function CnOtaGetComponentText(Component: IOTAComponent): string;
var
  NTAComp: INTAComponent;
begin
  NTAComp := Component as INTAComponent;
  Result := CnGetComponentText(NTAComp.GetComponent);
end;

// �����ļ�������ģ��ӿ�
function CnOtaGetModule(const FileName: string): IOTAModule;
var
  ModuleServices: IOTAModuleServices;
begin
  Result := nil;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    Result := ModuleServices.FindModule(FileName);
end;

// ȡ��ǰ������ģ�������޹��̷��� -1
function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
begin
  Result := -1;
  if Project <> nil then
    Result := Project.GetModuleCount;
end;

// ȡ��ǰ�����еĵ� Index ��ģ����Ϣ���� 0 ��ʼ
function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
begin
  if Project <> nil then
    Result := Project.GetModule(Index)
  else
    Result := nil;
end;

// �����ļ������ر༭���ӿ�
function CnOtaGetEditor(const FileName: string): IOTAEditor;
var
  ModuleServices: IOTAModuleServices;
  i, j: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    for i := 0 to ModuleServices.ModuleCount - 1 do
      for j := 0 to ModuleServices.Modules[i].GetModuleFileCount - 1 do
        if SameFileName(FileName, ModuleServices.Modules[i].GetModuleFileEditor(j).FileName) then
        begin
          Result := ModuleServices.Modules[i].GetModuleFileEditor(j);
          Exit;
        end;
  Result := nil;
end;

// ���ش���༭����ƴ������
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
var
  Component: IOTAComponent;
  NTAComponent: INTAComponent;
begin
  if Assigned(Editor) and IsVCLFormEditor(Editor) then 
  begin
    try
      Component := Editor.GetRootComponent;
    except
      // ��ĳЩ�ļ�ʱ�����Delphi5��
      Result := nil;
      Exit;
    end;
      
    if Assigned(Component) and QuerySvcs(Component, INTAComponent,
      NTAComponent) then
    begin
      Result := NTAComponent.GetComponent;
      Exit;
    end;
  end;
  Result := nil;
end;

// ȡ��ǰ�� EditWindow
function CnOtaGetCurrentEditWindow: TCustomForm;
var
  EditView: IOTAEditView;
  EditWindow: INTAEditWindow;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    EditWindow := EditView.GetEditWindow;
    if Assigned(EditWindow) then
    begin
      Result := EditWindow.Form;
      Exit;
    end;
  end;
  Result := nil;
end;

// ȡ��ǰ�� EditControl �ؼ�
function CnOtaGetCurrentEditControl: TWinControl;
var
  EditWindow: TCustomForm;
  Comp: TComponent;
begin
  EditWindow := CnOtaGetCurrentEditWindow;
  if EditWindow <> nil then
  begin
    Comp := FindComponentByClassName(EditWindow, 'TEditControl', 'Editor');
    if (Comp <> nil) and (Comp is TWinControl) then
    begin
      Result := TWinControl(Comp);
      Exit;
    end;
  end;
  Result := nil;
end;

// ���ص�Ԫ����
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
begin
  Result := _CnExtractFileName(Editor.FileName);
end;

// ȡ��ǰ������
function CnOtaGetProjectGroup: IOTAProjectGroup;
var
  IModuleServices: IOTAModuleServices;
{$IFNDEF BDS}
  IModule: IOTAModule;
  i: Integer;
{$ENDIF}
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
{$IFDEF BDS}
  Result := IModuleServices.MainProjectGroup;
{$ELSE}
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProjectGroup, Result) then
        Exit;
    end;
  Result := nil;
{$ENDIF}
end;

// ȡ��ǰ�������ļ���
function CnOtaGetProjectGroupFileName: string;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProjectGroup: IOTAProjectGroup;
  i: Integer;
begin
  Result := '';
  IModuleServices := BorlandIDEServices as IOTAModuleServices;
  if IModuleServices = nil then Exit;
  
  IProjectGroup := nil;
  for i := 0 to IModuleServices.ModuleCount - 1 do
  begin
    IModule := IModuleServices.Modules[i];
    if IModule.QueryInterface(IOTAProjectGroup, IProjectGroup) = S_OK then
      Break;
  end;
  // Delphi 5 does not return the file path when querying IOTAProjectGroup directly
  if IProjectGroup <> nil then
    Result := IModule.FileName;
end;

// ȡ������Դ
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
var
  i: Integer;
  IEditor: IOTAEditor;
begin
  for i:= 0 to (Project.GetModuleFileCount - 1) do
  begin
    IEditor := Project.GetModuleFileEditor(i);
    if Supports(IEditor, IOTAProjectResource, Result) then
      Exit;
  end;
  Result := nil;
end;

// ȡ��ǰ����
function CnOtaGetCurrentProject: IOTAProject;
var
  IProjectGroup: IOTAProjectGroup;
begin
  IProjectGroup := CnOtaGetProjectGroup;
  if Assigned(IProjectGroup) then
  begin
      try
        // This raises exceptions in D5 with .bat projects active
        Result := IProjectGroup.ActiveProject;
        Exit;
      except
        ;
      end;
  end;
  Result := nil;
end;

//�趨��Ŀ����ֵ
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
begin
  Assert(Options <> nil, ' Options can not be null');
  Options.Values[AOption] := AValue;
end;

// �����Ŀ�ĵ�ǰPlatformֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectPlatform(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.CurrentPlatform;
{$ENDIF}
end;

// �����Ŀ�ĵ�ǰFrameworkTypeֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.FrameworkType;
{$ENDIF}
end;


// ��õ�ǰ��Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject;const APropName: string): string;
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  Proj: IOTAProject;
  CurrPs: string;
{$ENDIF}
{$ENDIF}
begin
  Result := '';
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  BC := nil;
  POCS := CnOtaGetActiveProjectOptionsConfigurations(Project);
  if POCS <> nil then
  begin
    for I := 0 to POCS.GetConfigurationCount - 1 do
    begin
      if POCS.GetConfiguration(I).GetName = POCS.GetActiveConfiguration.GetName then
      begin
        BC := POCS.GetConfiguration(I);
        Break;
      end;
    end;

    if BC <> nil then
    begin
{$IFDEF SUPPORTS_CROSS_PLATFORM}
      Proj := Project; 
      if Proj = nil then
        Proj := CnOtaGetCurrentProject;

      CurrPs := '';
      if Proj <> nil  then
      begin
        CurrPs := Proj.CurrentPlatform;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('CnOtaGetProjectCurrentBuildConfigurationValue. Current Project Platform %s.', [CurrPs]);
{$ENDIF}
        for PS in BC.Platforms do
        begin
          PlatformConfig := BC.PlatformConfiguration[PS];
{$IFDEF DEBUG}
          CnDebugger.LogFmt('CnOtaGetProjectCurrentBuildConfigurationValue. Name %s, Platform %s, Value %s.',
            [APropName, PS, PlatformConfig.Value[APropName]]);
{$ENDIF}
          if PS = CurrPs then
            Result := PlatformConfig.Value[APropName];
        end;
      end;
{$ELSE}
      Result := BC.GetValue(APropName);
{$ENDIF}
    end;
  end;
{$ENDIF}
end;

// ���õ�ǰ��Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject;const APropName,
  AValue: string);
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
{$IFDEF SUPPORTS_CROSS_PLATFORM}
  Proj: IOTAProject;
  CurrPs: string;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  BC := nil;
  POCS := CnOtaGetActiveProjectOptionsConfigurations(Project);

  if POCS <> nil then
  begin
    for I := 0 to POCS.GetConfigurationCount - 1 do
    begin
      if POCS.GetConfiguration(I).GetName = POCS.GetActiveConfiguration.GetName then
      begin
        BC := POCS.GetConfiguration(I);
        Break;
      end;
    end;

    if BC <> nil then
    begin
{$IFDEF SUPPORTS_CROSS_PLATFORM}
      Proj := Project;
      if Proj = nil then
        Proj := CnOtaGetCurrentProject;

      CurrPs := '';
      if Proj <> nil  then
      begin
        CurrPs := Proj.CurrentPlatform;
        for PS in BC.Platforms do
        begin
          PlatformConfig := BC.PlatformConfiguration[PS];
          if PS = CurrPs then
          begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('CnOtaSetProjectCurrentBuildConfigurationValue. Name %s, Platform %s, Value %s.',
            [APropName, PS, AValue]);
{$ENDIF}
            PlatformConfig.SetValue(APropName, AValue);
            Exit;
          end;
        end;
      end;
{$ELSE}
      BC.SetValue(APropName, AValue);
{$ENDIF}
    end;
  end;
{$ENDIF}
end;  

// ȡ�� IDE ���ñ������б�
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True);
var
  Names: TOTAOptionNameArray;
  i: Integer;
begin
  List.Clear;
  Names := nil;
  if not Assigned(Options) then Exit;

  Names := Options.GetOptionNames;
  try
    for i := Low(Names) to High(Names) do
      if IncludeType then
        List.Add(Names[i].Name + ': ' + GetEnumName(TypeInfo(TTypeKind),
          Ord(Names[i].Kind)))
      else
        List.Add(Names[i].Name);
  finally
    Names := nil;
  end;
end;

function CnOtaGetOptionsNames(Options: IOTAOptions; IncludeType:
  Boolean = True): string;
var
  List: TStringList;
begin
  Result := '';
  List := TStringList.Create;
  try
    CnOtaGetOptionsNames(Options, List, IncludeType);
    Result := List.Text;
  finally
    List.Free;
  end;
end;

// ȡ��һ������
function CnOtaGetProject: IOTAProject;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  i: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProject, Result) then
        Exit;
    end;
  Result := nil;
end;

// ȡ��ǰ�������й��������޹����鷵�� -1
function CnOtaGetProjectCountFromGroup: Integer;
begin
  Result := -1;
  if CnOtaGetProjectGroup <> nil then
    Result := CnOtaGetProjectGroup.GetProjectCount;
end;

// ȡ��ǰ�������еĵ� Index �����̣��� 0 ��ʼ
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
begin
  if CnOtaGetProjectGroup <> nil then
    Result := CnOtaGetProjectGroup.GetProject(Index)
  else
    Result := nil;
end;

// ȡ�����й����б�
procedure CnOtaGetProjectList(const List: TInterfaceList);
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProject: IOTAProject;
  i: Integer;
begin
  if not Assigned(List) then
    Exit;

  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
    for i := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[i];
      if Supports(IModule, IOTAProject, IProject) then
        List.Add(IProject);
    end;
end;

// ȡ��ǰ��������
function CnOtaGetCurrentProjectName: string;
var
  IProject: IOTAProject;
begin
  Result := '';

  IProject := CnOtaGetCurrentProject;
  if Assigned(IProject) then
  begin
    Result := _CnExtractFileName(IProject.FileName);
    Result := _CnChangeFileExt(Result, '');
  end;
end;

// ȡ��ǰ�����ļ�����
function CnOtaGetCurrentProjectFileName: string;
var
  CurrentProject: IOTAProject;
begin
  CurrentProject := CnOtaGetCurrentProject;
  if Assigned(CurrentProject) then
    Result := CurrentProject.FileName
  else
    Result := '';
end;

// ȡ��ǰ�����ļ�������չ
function CnOtaGetCurrentProjectFileNameEx: string;
begin
  // �޸��Է��Ϸ���ȫ·���Ĺ���
  Result := _CnChangeFileExt((CnOtaGetCurrentProjectFileName), '');

  if Result <> '' then
    Exit;

  Result := _CnChangeFileExt((CnOtaGetProject.FileName), '');
  if Result <> '' then
    Exit;

  Result := Trim(Application.MainForm.Caption);
  Delete(Result, 1, AnsiPos('-', Result) + 1);
end;

// ȡ��ǰ��������
function CnOtaGetCurrentFormName: string;
var
  FormDesigner: IDesigner;
  AForm: TCustomForm;
  AFrame: TFrame;
begin
  Result := '';
  try
    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;
  {$IFDEF COMPILER6_UP}
    if FormDesigner.Root is TCustomForm then
    begin
      AForm := TCustomForm(FormDesigner.Root);
      Result := AForm.Name;
    end
    else
    if FormDesigner.Root is TFrame then
    begin
      AFrame := TFrame(FormDesigner.Root);
      Result := AFrame.Name;
    end;
  {$ELSE}
    if FormDesigner.GetRoot is TCustomForm then
    begin
      AForm := TCustomForm(FormDesigner.Form);
      Result := AForm.Name;
    end
    else
    if FormDesigner.GetRoot is TFrame then
    begin
      AFrame := TFrame(FormDesigner.GetRoot);
      Result := AFrame.Name;
    end;
  {$ENDIF}
  except
    ;
  end;
end;

// ȡ��ǰ�����ļ�����
function CnOtaGetCurrentFormFileName: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  if Assigned(CurrentModule) then
    Result := _CnChangeFileExt(CurrentModule.FileName, '.dfm')
  else
    Result := '';
end;

// ȡָ��ģ���ļ�����GetSourceEditorFileName ��ʾ�Ƿ񷵻��ڴ���༭���д򿪵��ļ�
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean): string;
var
  i: Integer;
  Editor: IOTAEditor;
  SourceEditor: IOTASourceEditor;
begin
  Result := '';
  if Assigned(Module) then
    if not GetSourceEditorFileName then
      Result := Module.FileName
    else
      for i := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := Module.GetModuleFileEditor(i);
        if Supports(Editor, IOTASourceEditor, SourceEditor) then
        begin
          Result := Editor.FileName;
          Break;
        end;
      end;
end;

// ȡ��ǰģ���ļ���
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean): string;
begin
  Result := CnOtaGetFileNameOfModule(CnOtaGetCurrentModule, GetSourceEditorFileName);
end;

// ȡ��ǰ��������
function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
var
  Svcs: IOTAServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Result := Svcs.GetEnvironmentOptions
  else
    Result := nil;
end;

// ȡ��ǰ�༭������
function CnOtaGetEditOptions: IOTAEditOptions;
var
  Svcs: IOTAEditorServices;
begin
  Result := nil;
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, Svcs);
  if Assigned(Svcs) then
  begin
  {$IFDEF COMPILER7_UP}
    if Assigned(Svcs.GetTopBuffer) then
      Result := Svcs.GetTopBuffer.EditOptions
    else if Svcs.EditOptionsCount > 0 then
      Result := Svcs.GetEditOptionsIndex(0);
  {$ELSE}
    Result := Svcs.GetEditOptions;
  {$ENDIF}
  end;
end;

// ȡ��ǰ����ѡ��
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
begin
  if Assigned(Project) then
  begin
    Result := Project.ProjectOptions;
    Exit;
  end;

  Project := CnOtaGetCurrentProject;
  if Assigned(Project) then
    Result := Project.ProjectOptions
  else
    Result := nil;
end;

// ȡ��ǰ����ָ��ѡ��
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
var
  ProjectOptions: IOTAProjectOptions;
begin
  Result := False;
  Value := '';
  ProjectOptions := CnOtaGetActiveProjectOptions;
  if Assigned(ProjectOptions) then
  begin
    Value := ProjectOptions.Values[Option];
    Result := True;
  end;
end;

// ȡ��ǰ�����������
function CnOtaGetPackageServices: IOTAPackageServices;
begin
  if not QuerySvcs(BorlandIDEServices, IOTAPackageServices, Result) then
    Result := nil;
end;

{$IFDEF DELPHI2009_UP}
// * ȡ��ǰ��������ѡ�2009 �����Ч
function CnOtaGetActiveProjectOptionsConfigurations
  (Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
var
  ProjectOptions: IOTAProjectOptions;
begin
  ProjectOptions := CnOtaGetActiveProjectOptions(Project);
  if ProjectOptions <> nil then
    if Supports(ProjectOptions, IOTAProjectOptionsConfigurations, Result) then
      Exit;

  Result := nil;
end;
{$ENDIF}

// ȡ�����������½�������ļ�����
function CnOtaGetNewFormTypeOption: TFormType;
var
  Options: IOTAEnvironmentOptions;
begin
  Result := ftUnknown;

  Options := CnOtaGetEnvironmentOptions;
  if not Assigned(Options) then Exit;

  case Options.Values['DFMAsText'] of
    -1: Result := ftText;
    0: Result := ftBinary;
  end;
end;

// ����ָ��ģ��ָ���ļ����ĵ�Ԫ�༭��
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string): IOTASourceEditor;
var
  i: Integer;
  IEditor: IOTAEditor;
  ISourceEditor: IOTASourceEditor;
begin
  Result := nil;
  if not Assigned(Module) then
    Exit;

  for i := 0 to Module.GetModuleFileCount-1 do
  begin
    IEditor := CnOtaGetFileEditorForModule(Module, i);

    if Supports(IEditor, IOTASourceEditor, ISourceEditor) then
    begin
      if Assigned(ISourceEditor) then
      begin
        if (FileName = '') or SameFileName(ISourceEditor.FileName, FileName) then
        begin
          Result := ISourceEditor;
          Break;
        end;
      end;
    end;
  end;
end;

// ����ָ��ģ��ָ���ļ����ı༭��
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
var
  i: Integer;
  Editor: IOTAEditor;
begin
  Assert(Assigned(Module));
  for i := 0 to Module.GetModuleFileCount-1 do
  begin
    Editor := CnOtaGetFileEditorForModule(Module, i);
    if SameFileName(Editor.FileName, FileName) then
    begin
      Result := Editor;
      Exit;
    end;
  end;
  Result := nil;
end;

// ����ָ��ģ��� EditActions 
function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
var
  i: Integer;
  EditView: IOTAEditView;
  SourceEditor: IOTASourceEditor;
begin
  if Module <> nil then
  begin
      SourceEditor := CnOtaGetSourceEditorFromModule(Module);
      if SourceEditor = nil then
      begin
        Result := nil;
        Exit;
      end;
      
      for i := 0 to SourceEditor.GetEditViewCount - 1 do
      begin
        EditView := SourceEditor.GetEditView(i);
        if Supports(EditView, IOTAEditActions, Result) then
          Exit;
      end;
  end;
  Result := nil;
end;

// ȡ��ǰѡ����ı�
function CnOtaGetCurrentSelection: string;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
begin
  Result := '';

  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if Assigned(EditBlock) then
    Result := EditBlock.Text;

{$IFDEF IDE_WIDECONTROL}
  Result := CnUtf8ToAnsi2(Result);
{$ENDIF}
end;

// ɾ��ѡ�е��ı�
procedure CnOtaDeleteCurrentSelection;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
begin
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if Assigned(EditBlock) then
    EditBlock.Delete;
end;

// �ڱ༭�����˸�
procedure CnOtaEditBackspace(Many: Integer);
var
  EditPosition: IOTAEditPosition;
  EditView: IOTAEditView;
begin
  EditPosition := CnOtaGetEditPosition;
  if Assigned(EditPosition) then
  begin
    EditPosition.BackspaceDelete(Many);
    EditView := CnOtaGetTopMostEditView;
    if Assigned(EditView) then
      EditView.Paint;
  end;
end;

// �ڱ༭����ɾ��
procedure CnOtaEditDelete(Many: Integer);
var
  EditPosition: IOTAEditPosition;
  EditView: IOTAEditView;
begin
  EditPosition := CnOtaGetEditPosition;
  if Assigned(EditPosition) then
  begin
    EditPosition.Delete(Many);
    EditView := CnOtaGetTopMostEditView;
    if Assigned(EditView) then
      EditView.Paint;
  end;
end;

// ��ȡ��ǰ������ڵĹ��̻�����
function CnOtaGetCurrentProcedure: string;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  PasParser: TCnPasStructureParser;
  CParser: TCnCppStructureParser;
  S: string;
begin
  Result := '';
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  S := EditView.Buffer.FileName;
  Stream := TMemoryStream.Create;
  CnOtaSaveEditorToStream(EditView.Buffer, Stream);
  try
    if IsDprOrPas(S) or IsInc(S) then
    begin
      PasParser := TCnPasStructureParser.Create;
      try
        PasParser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(EditView.Buffer.FileName), False);

        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
        if PasParser.CurrentChildMethod <> '' then
          Result := string(PasParser.CurrentChildMethod)
        else if PasParser.CurrentMethod <> '' then
          Result := string(PasParser.CurrentMethod);
      finally
        PasParser.Free;
      end;
    end
    else if IsCppSourceModule(S) then
    begin
      CParser := TCnCppStructureParser.Create;

      try
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        // �Ƿ���Ҫת����
        CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
          CharPos.Line, CharPos.CharIndex, True);

        Result := string(CParser.CurrentMethod);
      finally
        CParser.Free;
      end;
    end;
  finally
    Stream.Free;
  end;
end;

// ��ȡ��ǰ������ڵ�����������
function CnOtaGetCurrentOuterBlock: string;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
begin
  Result := '';
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  Parser := TCnPasStructureParser.Create;
  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), False);
  finally
    Stream.Free;
  end;

  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Result := string(Parser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex));
  Parser.Free;
end;

// ȡָ���е�Դ����
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
var
  L1, L2: Integer;
  Reader: IOTAEditReader;
  View: IOTAEditView;
  OutStr: AnsiString;
begin
  Result := '';
  if LineNum < 1 then
  begin
    Count := Count + LineNum - 1;
    LineNum := 1;
  end;
  if Count <= 0 then Exit;

  if not Assigned(EditBuffer) then
    EditBuffer := CnOtaGetEditBuffer;
  if LineNum > EditBuffer.GetLinesInBuffer then Exit;

  if Assigned(EditBuffer) then
  begin
    View := EditBuffer.TopView;
    if Assigned(View) then
    begin
      L1 := View.CharPosToPos(OTACharPos(0, LineNum));
      L2 := View.CharPosToPos(OTACharPos(csMaxLineLength, Min(LineNum +
        Count - 1, EditBuffer.GetLinesInBuffer)));
      SetLength(OutStr , L2 - L1);
      Reader := EditBuffer.CreateReader;
      try
        Reader.GetText(L1, PAnsiChar(OutStr), L2 - L1);
      finally
        Reader := nil;
      end;
      Result := string(ConvertEditorTextToText(OutStr));
    {$IFDEF UNICODE_STRING}
      // �˺����� D2009 �� Result ���Ȳ��ԣ���Ҫ TrimRight
      Result := TrimRight(Result);
    {$ENDIF}
    end;
  end;
end;

// ȡ��ǰ��Դ����
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
var
  L1, L2: Integer;
  Reader: IOTAEditReader;
  EditBuffer: IOTAEditBuffer;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  OutStr: AnsiString;
begin
  Result := False;
  if not Assigned(View) then
    View := CnOtaGetTopMostEditView;
  if not Assigned(View) then Exit;

  EditPos := View.CursorPos;
  View.ConvertPos(True, EditPos, CharPos);
  LineNo := CharPos.Line;
  CharIndex := CharPos.CharIndex;

  EditBuffer := View.Buffer;
  L1 := CnOtaEditPosToLinePos(OTAEditPos(1, LineNo), EditBuffer.TopView);
  if (LineNo >= View.Buffer.GetLinesInBuffer) then
    L2 := CnOtaEditPosToLinePos(OTAEditPos(High(SmallInt), LineNo + 1), EditBuffer.TopView)
  else
    L2 := CnOtaEditPosToLinePos(OTAEditPos(1, LineNo + 1), EditBuffer.TopView) - 2;
  SetLength(OutStr, L2 - L1);
  Reader := EditBuffer.CreateReader;
  try
    Reader.GetText(L1, PAnsiChar(OutStr), L2 - L1);
  finally
    Reader := nil;
  end;          
  Text := TrimRight(string(ConvertEditorTextToText(OutStr)));
  Result := True;
end;

// ʹ�� NTA ����ȡ��ǰ��Դ���롣�ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
// ���ʹ�� ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1
// ��ֵ�� EditPos.Col ����
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
var
  EditControl: TControl;
  View: IOTAEditView;
begin
  Result := False;
  EditControl := GetCurrentEditControl;
  View := CnOtaGetTopMostEditView;
  if (EditControl <> nil) and (View <> nil) then
  begin
    Text := GetStrProp(EditControl, 'LineText');
    //CnDebugger.TraceFmt('Col %d, Len %d, Text %s', [View.CursorPos.Col - 1, Length(Text), Text]);
    CharIndex := Min(View.CursorPos.Col - 1, Length(Text));
    LineNo := View.CursorPos.Line;
    Result := True;
    Exit;
  end;
end;

// ���� SourceEditor ��ǰ����Ϣ
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
var
  LineText: string;
begin
  Result := CnNtaGetCurrLineText(LineText, LineNo, CharIndex);
  if Result then
    LineLen := Length(LineText);
end;

// ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ��ٶȽϿ�
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  i: Integer;

  function _IsValidIdentChar(C: Char; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
      Result := IsValidIdentChar(C, First)
    else
      Result := CharInSet(C, FirstSet + CharSet);
  end;
begin
  Token := '';
  CurrIndex := 0;
  Result := False;

  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;

  if (EditView <> nil) and CnNtaGetCurrLineText(LineText, LineNo, CharIndex) and
    (LineText <> '') then
  begin
    //CnDebugger.TraceFmt('CharIndex %d, LineText %s', [CharIndex, LineText]);
    if CheckCursorOutOfLineEnd and CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
      Exit;

    i := CharIndex;
    CurrIndex := 0;
    // ������ʼ�ַ�
    while (i > 0) and _IsValidIdentChar(LineText[i], False) do
    begin
      Dec(i);
      Inc(CurrIndex);
    end;
    Delete(LineText, 1, i);

    // ���ҽ����ַ�
    i := 1;
    while (i <= Length(LineText)) and _IsValidIdentChar(LineText[i], False) do
      Inc(i);
    Delete(LineText, i, MaxInt);
    Token := LineText;
  end;

  if Token <> '' then
  begin
    if CharInSet(Token[1], FirstSet) or IsValidIdent(Token) then
      Result := True;
  end;

  if not Result then
    Token := '';
end;

// ȡ��ǰ����µ��ַ�������ƫ����
function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
var
  CharIndex: Integer;
  LineText: string;
  LineNo: Integer;
begin
  Result := #0;
  if (View = nil) or (View = CnOtaGetTopMostEditView) then
  begin
    if CnOtaGetCurrLineText(LineText, LineNo, CharIndex) then
    begin
      CharIndex := CharIndex + OffsetX + 1;
      if (CharIndex > 0) and (CharIndex <= Length(LineText)) then
        Result := LineText[CharIndex];
    end;
  end
  else if CnOtaGetCurrLineText(LineText, LineNo, CharIndex, View) then
  begin
    CharIndex := CharIndex + OffsetX + 1;
    if (CharIndex > 0) and (CharIndex <= Length(LineText)) then
      Result := LineText[CharIndex];
  end;
end;

function _DeleteCurrToken(DelLeft, DelRight: Boolean; FirstSet: TAnsiCharSet;
  CharSet: TAnsiCharSet): Boolean;
var
  Token: string;
  CurrIndex: Integer;
  EditPos: IOTAEditPosition;
begin
  Result := False;
  if CnOtaGetCurrPosToken(Token, CurrIndex, True, FirstSet, CharSet) then
  begin
    EditPos := CnOtaGetEditPosition;
    if Assigned(EditPos) then
    begin
      if DelLeft and DelRight then
      begin
        EditPos.MoveRelative(0, Length(Token) - CurrIndex);
        EditPos.BackspaceDelete(Length(Token));
      end
      else if DelLeft and (CurrIndex > 0) then
        EditPos.BackspaceDelete(CurrIndex)
      else if DelRight and (CurrIndex < Length(Token) - 1) then
      begin
        EditPos.MoveRelative(0, Length(Token) - CurrIndex);
        EditPos.BackspaceDelete(Length(Token) - CurrIndex);
      end;
      Result := True;
    end;
  end;
end;

// ɾ����ǰ����µı�ʶ��
function CnOtaDeleteCurrToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(True, True, FirstSet, CharSet);
end;

// ɾ����ǰ����µı�ʶ����벿��
function CnOtaDeleteCurrTokenLeft(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(True, False, FirstSet, CharSet);
end;

// ɾ����ǰ����µı�ʶ���Ұ벿��
function CnOtaDeleteCurrTokenRight(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
begin
  Result := _DeleteCurrToken(False, True, FirstSet, CharSet);
end;

// �ж�λ���Ƿ񳬳���β��
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView): Boolean;
var
  APos: TOTAEditPos;
  CPos: TOTACharPos;
begin
  Result := True;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.ConvertPos(True, EditPos, CPos);
    View.ConvertPos(False, APos, CPos);
    Result := not SameEditPos(EditPos, APos);
  end;  
end;

// ѡ��һ�������
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
begin
  Editor.BlockVisible := False;
  try
    Editor.BlockType := btNonInclusive;
    Editor.BlockStart := Start;
    Editor.BlockAfter := After;
  finally
    Editor.BlockVisible := True;
  end;
end;

// ���ص�ǰѡ��Ŀ��Ƿ�Ϊ��
function CnOtaCurrBlockEmpty: Boolean;
var
  View: IOTAEditView;
begin
  Result := True;
  View := CnOtaGetTopMostEditView;
  if Assigned(View) and View.Block.IsValid then
    Result := False;
end;

// ���ļ�
function CnOtaOpenFile(const FileName: string): Boolean;
var
  ActionServices: IOTAActionServices;
begin
  Result := False;
  try
    ActionServices := BorlandIDEServices as IOTAActionServices;
    if ActionServices <> nil then
      Result := ActionServices.OpenFile(FileName);
  except
    ;
  end;            
end;

// ��δ����Ĵ���
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
var
  iModuleServices: IOTAModuleServices;
begin
  Result := False;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices <> nil then
    Result := CnOtaShowFormForModule(iModuleServices.FindFormModule(FormName));
end;

// �ж��ļ��Ƿ��
function CnOtaIsFileOpen(const FileName: string): Boolean;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FileEditor: IOTAEditor;
  i: Integer;
begin
  Result := False;

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
  begin
    for i := 0 to Module.GetModuleFileCount-1 do
    begin
      FileEditor := CnOtaGetFileEditorForModule(Module, i);
      Assert(Assigned(FileEditor));

      Result := CompareText(FileName, FileEditor.FileName) = 0;
      if Result then
        Exit;
    end;
  end;
end;

// �жϴ����Ƿ��
function CnOtaIsFormOpen(const FormName: string): Boolean;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
  i: Integer;
begin
  Result := False;

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindFormModule(FormName);
  if Assigned(Module) then
  begin
    for i := 0 to Module.GetModuleFileCount-1 do
    begin
      FormEditor := CnOtaGetFormEditorFromModule(Module);

      Result := Assigned(FormEditor);
      if Result then
        Exit;
    end;
  end;
end;

// �ж�ģ���Ƿ��ѱ��޸�
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to AModule.GetModuleFileCount - 1 do
    if AModule.GetModuleFileEditor(i).Modified then
    begin
      Result := True;
      Exit;
    end;
end;

// ȡģ��ĵ�Ԫ�ļ���
function CnOtaGetBaseModuleFileName(const FileName: string): string;
var
  AltName: string;
begin
  Result := FileName;
  if IsForm(FileName) then
  begin
    {$IFDEF BCB}
    AltName := _CnChangeFileExt(FileName, '.cpp');
    if CnOtaIsFileOpen(AltName) or FileExists(AltName) then
      Result := AltName;
    {$ENDIF BCB}
    AltName := _CnChangeFileExt(FileName, '.pas');
    if CnOtaIsFileOpen(AltName) or FileExists(AltName) then
      Result := AltName;
  end;
end;

// ��ǰ�Ƿ��ڵ���״̬
function CnOtaIsDebugging: Boolean;
var
  DebugScvs: IOTADebuggerServices;
begin
  Result := False;
  QuerySvcs(BorlandIDEServices, IOTADebuggerServices, DebugScvs);
  if Assigned(DebugScvs) then
    Result := DebugScvs.ProcessCount > 0;
end;

// ��ָ���ļ��ɼ�
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer): Boolean;
var
  EditActions: IOTAEditActions;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
  SourceEditor: IOTASourceEditor;
  FileEditor: IOTAEditor;
  i: Integer;
  BaseFileName: string;
begin
  Result := False;

  BaseFileName := CnOtaGetBaseModuleFileName(FileName);
  Module := CnOtaGetModule(BaseFileName);

  if Module <> nil then
  begin
    if IsForm(FileName) then
    begin
      if not CnOtaModuleIsShowingFormSource(Module) then
      begin
        SourceEditor := CnOtaGetSourceEditorFromModule(Module, BaseFileName);
        if Assigned(SourceEditor) then
          SourceEditor.Show;
        SourceEditor := nil;
        EditActions := CnOtaGetEditActionsFromModule(Module);
        if EditActions <> nil then
        begin
          FormEditor := CnOtaGetFormEditorFromModule(Module);
          FormEditor.Show;
          EditActions.SwapSourceFormView;
          Result := True;
        end;
      end;
    end
    else // We are focusing a regular text file, not a form
    begin
      if CnOtaModuleIsShowingFormSource(Module) then
      begin
        SourceEditor := CnOtaGetSourceEditorFromModule(Module);
        if Assigned(SourceEditor) then
          SourceEditor.Show;
        SourceEditor := nil;
        EditActions := CnOtaGetEditActionsFromModule(Module);
        if EditActions <> nil then
        begin
          EditActions.SwapSourceFormView;
          Result := True;
        end;
      end
      else
        Result := True;
    end;
  end;

  if not CnOtaIsFileOpen(BaseFileName) then
    Result := CnOtaOpenFile(FileName);

  // D5 sometimes delays opening the file until messages are processed
  Application.ProcessMessages;

  if Result then
  begin
    Module := CnOtaGetModule(BaseFileName);
    if Module <> nil then
    begin
      for i := 0 to Module.GetModuleFileCount-1 do
      begin
        FileEditor := Module.GetModuleFileEditor(i);
        Assert(Assigned(FileEditor));

        if CompareText(FileEditor.FileName, FileName) = 0 then
        begin
          FileEditor.Show;
          if Lines > 0 then
          begin
            Supports(FileEditor, IOTASourceEditor, SourceEditor);
            if (SourceEditor <> nil) and (SourceEditor.EditViewCount > 0) then
            begin
              SourceEditor.EditViews[0].Center(Lines, 1);
              SourceEditor.EditViews[0].Paint;
            end;
          end;
          Exit;
        end;
      end;
    end;
    Result := False;
  end;
end;

// ָ��ģ���Ƿ����ı����巽ʽ��ʾ
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
var
  Editor: IOTAEditor;
begin
  Result := False;
  if Module.GetModuleFileCount = 1 then
  begin
    Editor := CnOtaGetFileEditorForModule(Module, 0);
    Assert(Assigned(Editor));
    if IsForm(Editor.GetFileName) then
      Result := True;
  end;
end;

// ��ǰ PersistentBlocks �Ƿ�Ϊ True
function CnOtaIsPersistentBlocks: Boolean;
var
  EnvOptions: IOTAEnvironmentOptions;
begin
  Result := False;
  try
    EnvOptions := CnOtaGetEnvironmentOptions;
    if Assigned(EnvOptions) then
      Result := EnvOptions.Values['PersistentBlocks'];
  except
    ;
  end;
end;

//==============================================================================
// Դ���������غ���
//==============================================================================

// �ַ���תΪԴ���봮
function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
var
  Strings: TStrings;
  i, j: Integer;
  s, Line: string;
  IsDelphi: Boolean;
begin
  Result := '';
  IsDelphi := CurrentIsDelphiSource;
  if Str = '' then
  begin
    if IsDelphi then
      Result := ''''''
    else
      Result := '""';
    Exit;
  end;

  Strings := TStringList.Create;
  try
    if Wrap then                     // �Ƿ���뻻�з�
      s := CRLF
    else
      s := '';
        
    Strings.Text := Str;
    for i := 0 to Strings.Count - 1 do
    begin
      Line := Strings[i];
      for j := Length(Line) downto 1 do 
        if IsDelphi then             // Delphi �� ' ��ת��Ϊ ''
        begin
          if Line[j] = '''' then
            Insert('''', Line, j);
        end
        else begin                   // C++Builder �� " ��ת��Ϊ \"
          if Line[j] = '"' then
            Insert('\', Line, j);
        end;

      if IsDelphi then
      begin
        if i = Strings.Count - 1 then  // ���һ�в��ӻ��з�
        begin
          if Line <> '' then
            Result := Format('%s''%s''', [Result, Line])
          else
            Delete(Result, Length(Result) - Length(' + ' + s) + 1,
              Length(' + ' + s));
        end
        else
        begin
          if Trim(ADelphiReturn) <> '' then
          begin
            if Wrap or (Line <> '') then
              Result := Format('%s''%s'' + %s + %s', [Result, Line, ADelphiReturn, s])
            else
              Result := Result + ADelphiReturn + ' + ' + s;
          end
          else
          begin
            if Wrap or (Line <> '') then
              Result := Format('%s''%s'' + %s', [Result, Line, s])
            else
              Result := Result + s;
          end;
        end;
      end
      else
      begin
        if i = Strings.Count - 1 then
          Result := Format('%s"%s"', [Result, Line])
        else
          Result := Format('%s"%s%s" %s', [Result , Line, ACReturn, s]);
      end;
    end;
  finally
    Strings.Free;
  end;
end;

// �������Զ��л�Ϊ���д���
function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
var
  Strings: TStrings;
  i: Integer;
begin
  if Length(Code) <= Width then
  begin
    Result := Code;
    Exit;
  end;
  
  Result := StrLeft(Code, Indent); // �ȴ����һ������������������ַ�
  Delete(Code, 1, Indent);
  
  Strings := TStringList.Create;
  try
    Strings.Text := WrapText(Code, #13#10, [' '], Width - Indent);
    Result := Result + Strings[0] + #13#10;
    for i := 1 to Strings.Count - 1 do
      if (i = 1) or not IndentOnceOnly then
        Result := Result + Spc(Indent) + Trim(Strings[i]) + #13#10  // ��������
      else
        Result := Result + Strings[i] + #13#10;
    Delete(Result, Length(Result) - 1, 2); // ɾ������Ļ��з�
  finally
    Strings.Free;
  end;
end;

{$IFDEF COMPILER6_UP}
// ����ת��Utf8��Ansi�ַ����������ڳ��ȶ�����Ҫ��Ansi�ַ����ַ���
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
var
  i, l, Len: Cardinal;
  IsMultiBytes: Boolean;
  P: PDWORD;
begin
  if Text <> '' then
  begin
    Len := Length(Text);
    l := Len and $FFFFFFFC;
    P := PDWORD(@Text[1]);
    IsMultiBytes := False;
    for i := 0 to l div 4 do
    begin
      if P^ and $80808080 <> 0 then
      begin
        IsMultiBytes := True;
        Break;
      end;
      Inc(P);  
    end;
    
    if not IsMultiBytes then
    begin
      for i := l + 1 to Len do
      begin
        if Ord(Text[i]) and $80 <> 0 then
        begin
          IsMultiBytes := True;
          Break;
        end;  
      end;  
    end;

    if IsMultiBytes then
      Result := CnUtf8ToAnsi(Text)
    else
      Result := Text;
  end
  else
    Result := '';
end;

{$ENDIF}

// ת���ַ���Ϊ�༭��ʹ�õ��ַ���
function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
begin
{$IFDEF IDE_WIDECONTROL}
  Result := CnAnsiToUtf8(Text);
{$ELSE}
  Result := Text;
{$ENDIF}
end;

// ת���༭��ʹ�õ��ַ���Ϊ��ͨ�ַ���
function ConvertEditorTextToText(const Text: AnsiString): AnsiString;
begin
{$IFDEF IDE_WIDECONTROL}
  // ֻ�ʺ��ڷ� Unicode ������ BDS��Unicode �����£�ֱ������ string ����
  Result := CnUtf8ToAnsi(Text);
{$ELSE}
  // ֻ�ʺ��� D7 ������
  Result := Text;
{$ENDIF}
end;

// ȡ��ǰ�༭��Դ�ļ�  (���� GExperts Src 1.12���иĶ�)
function CnOtaGetCurrentSourceFile: string;
{$IFDEF COMPILER6_UP}
var
  iModule: IOTAModule;
  iEditor: IOTAEditor;
begin
  iModule := CnOtaGetCurrentModule;
  if iModule <> nil then
  begin
    iEditor := iModule.GetCurrentEditor;
    if iEditor <> nil then
    begin
      Result := iEditor.FileName;
      if Result <> '' then
        Exit;
    end;
  end;
  Result := '';
{$IFDEF BCB}  // BCB �¿��ܴ����޷���õ�ǰ���̵�cpp�ļ������⣬�ش˼��ϴ˹���
  if (Result = '') and (CnOtaGetEditBuffer <> nil) then
    Result := CnOtaGetEditBuffer.FileName;
{$ENDIF}
end;
{$ELSE}
begin
  // Delphi5/BCB5/K1 ����ȻҪ���þɵķ�ʽ
  Result := ToolServices.GetCurrentFile;
end;
{$ENDIF}

// ȡ��ǰ�༭�� Pascal �� C Դ�ļ����ж����ƽ϶�
function CnOtaGetCurrentSourceFileName: string;
var
  TmpName: string;
begin
  Result := CnOtaGetCurrentSourceFile;
  if IsForm(Result) then
  begin
    TmpName := _CnChangeFileExt(Result, '.pas');
    if CnOtaIsFileOpen(TmpName) then
      Result := TmpName
    else
    begin
      TmpName := _CnChangeFileExt(Result, '.cpp');
      if CnOtaIsFileOpen(TmpName) then
        Result := TmpName
      else
      begin
        TmpName := _CnChangeFileExt(Result, '.h');
        if CnOtaIsFileOpen(TmpName) then
          Result := TmpName
        else
        begin
          TmpName := _CnChangeFileExt(Result, '.cc');
          if CnOtaIsFileOpen(TmpName) then
            Result := TmpName
          else
          begin
            TmpName := _CnChangeFileExt(Result, '.hh');
            if CnOtaIsFileOpen(TmpName) then
              Result := TmpName
          end;
        end;
      end;
    end;
  end
  else
  begin
    if not (IsDprOrPas(Result) or IsTypeLibrary(Result) or IsInc(Result)
      or IsCpp(Result) or IsC(Result) or IsHpp(Result) or IsH(Result)) then
    begin
      // ErrorDlg(SPasOrDprOrCPPOnly, mtError, [mbOK], 0)
      Result := '';
    end;
  end;
end;

// �� EditPosition �в���һ���ı���֧�� D2005 ��ʹ�� utf-8 ��ʽ
procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);
begin
{$IFDEF UNICODE_STRING}
  EditPosition.InsertText(string(ConvertTextToEditorText(AnsiString(Text))));
{$ELSE}
  EditPosition.InsertText(ConvertTextToEditorText(Text));
{$ENDIF}
end;

// ����һ���ı�����ǰ���ڱ༭��Դ�ļ��У����سɹ���־
function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos): Boolean;
var
  iEditPosition: IOTAEditPosition;
  iEditView: IOTAEditView;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditView := CnOtaGetTopMostEditView;
    if iEditView = nil then Exit;
    if not CnOtaMovePosInCurSource(InsertPos, 0, 0) then Exit;
    CnOtaPositionInsertText(iEditPosition, Text);
    iEditView.Paint;
    Result := True;
  except
    ;
  end;
end;

// ��õ�ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    Col := iEditPosition.Column;
    Row := iEditPosition.Row;
    Result := True;
  except
    ;
  end;
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, Col);
    Result := True;
  except
    ;
  end;
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourceCol(Col: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(iEditPosition.Row, Col);
    Result := True;
  except
    ;
  end;
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourceRow(Row: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, iEditPosition.Column);
    Result := True;
  except
    ;
  end;
end;

// �ڵ�ǰԴ�ļ����ƶ����
function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
var
  iEditPosition: IOTAEditPosition;
begin
  Result := False;
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    case Pos of
      ipFileHead: if not iEditPosition.Move(1, 1) then Exit;
      ipFileEnd: if not iEditPosition.MoveEOF then Exit;
      ipLineHead: if not iEditPosition.MoveBOL then Exit;
      ipLineEnd: if not iEditPosition.MoveEOL then Exit;
    end;
    if (OffsetRow <> 0) or (OffsetCol <> 0) then
      if not iEditPosition.MoveRelative(OffsetRow, OffsetCol) then Exit;
    Result := True;
  except
    ;
  end;
end;

// ���� SourceEditor ��ǰ���λ�õ����Ե�ַ
function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor): Integer;
var
  CharPos: TOTACharPos;
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor.EditViewCount > 0 then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;
    IEditView.ConvertPos(True, EditPos, CharPos);
    Result := IEditView.CharPosToPos(CharPos);
    if Result < 0 then Result := 0;
  end
  else
    Result := 0;
end;

// ���� SourceEditor ��ǰ���λ��
function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor): TOTACharPos;
var
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(SourceEditor) and (SourceEditor.EditViewCount > 0) then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;
    IEditView.ConvertPos(True, EditPos, Result);
  end
  else
  begin
    Result.CharIndex := 0;
    Result.Line := 0;
  end;
end;

// �༭λ��ת��Ϊ����λ��
function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
var
  CharPos: TOTACharPos;
begin
  if EditView = nil then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    EditView.ConvertPos(True, EditPos, CharPos);
    Result := EditView.CharPosToPos(CharPos);
  end
  else
    Result := 0;
end;

// ����λ��ת��Ϊ�༭λ��
function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
var
  CharPos: TOTACharPos;
begin
  if EditView = nil then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    CharPos := CnOtaGetCharPosFromPos(LinePos, EditView);
    EditView.ConvertPos(False, Result, CharPos);
  end
  else
  begin
    Result.Col := 0;
    Result.Line := 0;
  end;
end;

// ����EditReader���ݵ�����
procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
const
  // Leave typed constant as is - needed for streaming code.
  TerminatingNulChar: Char = #0;
  BufferSize = 1024 * 24;
var
  Buffer: PAnsiChar;
  EditReaderPos: Integer;
  DataLen: Integer;
  ReadDataSize: Integer;
{$IFDEF IDE_WIDECONTROL}
  Text: AnsiString;
{$ENDIF}
begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('CnOtaSaveReaderToStream. StartPos %d, EndPos %d, PreSize %d.',
    [StartPos, EndPos, PreSize]);
{$ENDIF}

  if EndPos > 0 then
  begin
    DataLen := EndPos - StartPos;
    Stream.Size := DataLen + 1;
  end
  else
  begin
    // ����Ԥ�Ƶ��ڴ����������
    DataLen := MaxInt;
    Stream.Size := PreSize;
  end;
  Stream.Position := 0;
  GetMem(Buffer, BufferSize);
  try
    EditReaderPos := StartPos;
    ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
    Inc(EditReaderPos, ReadDataSize);
    Dec(DataLen, ReadDataSize);
    while (ReadDataSize = BufferSize) and (DataLen > 0) do
    begin
      Stream.Write(Buffer^, ReadDataSize);
      ReadDataSize := EditReader.GetText(EditReaderPos, Buffer, Min(BufferSize, DataLen));
      Inc(EditReaderPos, ReadDataSize);
      Dec(DataLen, ReadDataSize);
    end;
    Stream.Write(Buffer^, ReadDataSize);
    Stream.Write(TerminatingNulChar, SizeOf(TerminatingNulChar));
    if Stream.Size > Stream.Position then
      Stream.Size := Stream.Position;
  finally
    FreeMem(Buffer);
  end;

{$IFDEF IDE_WIDECONTROL}
  if CheckUtf8 then
  begin
    Text := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
    Stream.Size := Length(Text) + 1;
    Stream.Position := 0;
    Stream.Write(PAnsiChar(Text)^, Length(Text) + 1);
  end;
{$ENDIF}

  Stream.Position := 0;
end;

// ����༭���ı�������
procedure CnOtaSaveEditorToStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
var
  Reader: IOTAEditReader;
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  Reader := Editor.CreateReader;
  try
    CnOtaSaveReaderToStream(Reader, Stream, StartPos, EndPos, PreSize, CheckUtf8);
  finally
    Reader := nil;
  end;
end;

// ����༭���ı�������
function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = True): Boolean;
var
  IPos: Integer;
  PreSize: Integer;
begin
  Assert(Stream <> nil);
  Result := False;

  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  if Editor.EditViewCount > 0 then
  begin
    if FromCurrPos then
      IPos := CnOtaGetCurrPos(Editor)
    else
      IPos := 0;

    // ������ļ�δ���棬������ FileSize ���䲻һ�µ������
    // ���ܵ��� PreSize Ϊ���Ӷ���������
    if FileExists(Editor.FileName) then
      PreSize := Round(GetFileSize(Editor.FileName) * 1.5) - IPos
    else
      PreSize := 0;

    // �޲���������
    if PreSize < 0 then
      PreSize := 0;

    CnOtaSaveEditorToStreamEx(Editor, Stream, IPos, 0, PreSize, CheckUtf8);
    Result := True;
  end;
end;

// ���浱ǰ�༭���ı�������
function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
begin
  Result := CnOtaSaveEditorToStream(nil, Stream, FromCurrPos, CheckUtf8);
end;

// ȡ�õ�ǰ�༭��Դ����
function CnOtaGetCurrentEditorSource: string;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    if CnOtaSaveCurrentEditorToStream(Strm, False, True) then
      Result := PChar(Strm.Memory);
  finally
    Strm.Free;
  end;   
end;  

// ����һ���ַ�������ǰ IOTASourceEditor������ Text Ϊ�����ı�ʱ����
procedure CnOtaInsertLineIntoEditor(const Text: string);
var
  EditView: IOTAEditView;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    CnOtaPositionInsertText(EditView.Position, Text);
    EditView.Paint;
  end;
end;

// ����һ���ı���ǰ IOTASourceEditor��Line Ϊ�кţ�Text Ϊ����
procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
  begin
    if Line > 1 then
    begin
      // �Ȳ���һ������
      EditView.Position.Move(Line - 1, 1);
      EditView.Position.MoveEOL;
    end
    else
    begin
      EditView.Position.Move(1, 1);
    end;
    CnOtaPositionInsertText(EditView.Position, CRLF);
    // �ٲ����ı��Ա�����һ���Զ�����
    EditView.Position.Move(Line, 1);
    CnOtaPositionInsertText(EditView.Position, Text);
    EditView.Paint;
  end;
end;

// �����ı�����ǰ IOTASourceEditor����������ı���
procedure CnOtaInsertTextIntoEditor(const Text: string);
var
  EditView: IOTAEditView;
  Position: Longint;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
begin
  EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Position := EditView.CharPosToPos(CharPos);
  CnOtaInsertTextIntoEditorAtPos(Text, Position);
  EditView.MoveViewToCursor;
  EditView.Paint;
end;

// Ϊָ�� SourceEditor ����һ�� Writer���������Ϊ�շ��ص�ǰֵ��
function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
resourcestring
  SEditWriterNotAvail = 'Edit writer not available';
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(SourceEditor) then
    Result := SourceEditor.CreateUndoableWriter;
  Assert(Assigned(Result), SEditWriterNotAvail);
end;

// ��ָ��λ�ô������ı������ SourceEditor Ϊ��ʹ�õ�ǰֵ��
procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
  {$IFDEF UNICODE_STRING}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(Text))));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
  {$ENDIF}
  finally
    EditWriter := nil;
  end;          
end;

// �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��
procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView; Middle: Boolean);
var
  CurPos: TOTAEditPos;
  CharPos: TOTACharPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));

  CharPos := CnOtaGetCharPosFromPos(Position, EditView);
  CurPos.Col := CharPos.CharIndex + 1;
  CurPos.Line := CharPos.Line;
  CnOtaGotoEditPos(CurPos, EditView, Middle);
end;

// ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��
function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) then
    Result := EditView.CursorPos
  else
  begin
    Result.Col := 0;
    Result.Line := 0;
  end;
end;

// �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��
procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView; Middle: Boolean);
var
  TopRow: TOTAEditPos;
begin
  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;
//  Assert(Assigned(EditView));
  if EditView = nil then
    Exit;

  if EditPos.Line < 1 then
    EditPos.Line := 1;
  TopRow := EditPos;
  if Middle then
    TopRow.Line := TopRow.Line - (EditView.ViewSize.cy div 2) + 1;
  if TopRow.Line < 1 then
    TopRow.Line := 1;
  TopRow.Col := 1;
  EditView.TopPos := TopRow;

  EditView.CursorPos := EditPos;
  Application.ProcessMessages;
  EditView.Paint;
end;

// ת��һ������λ�õ� TOTACharPos����Ϊ�� D5/D6 �� IOTAEditView.PosToCharPos
// ���ܲ�����������
function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
var
  EditWriter: IOTAEditWriter;
begin
  Assert(Assigned(EditView));
  EditWriter := EditView.Buffer.CreateUndoableWriter;
  try
    Assert(Assigned(EditWriter));
    EditWriter.CopyTo(Position);
    Result := EditWriter.CurrentPos;
  finally
    EditWriter := nil;
  end;          
end;

// ��õ�ǰ�༭����������� 
function CnOtaGetBlockIndent: Integer;
var
  EditOptions: IOTAEditOptions;
begin
  EditOptions := CnOtaGetEditOptions;
  if Assigned(EditOptions) then
    Result := EditOptions.GetBlockIndent
  else
    Result := 2;
end;

// �ر�ģ����ͼ
procedure CnOtaClosePage(EditView: IOTAEditView);
var
  EditActions: IOTAEditActions;
begin
  if not Assigned(EditView) then Exit;
  QuerySvcs(EditView, IOTAEditActions, EditActions);
  if Assigned(EditActions) then
    EditActions.ClosePage;
end;

// ���ر�ģ�����ͼ�������ر�ģ��
procedure CnOtaCloseEditView(AModule: IOTAModule);
var
  Editor: IOTASourceEditor;
  View: IOTAEditView;
begin
  Editor := CnOtaGetSourceEditorFromModule(AModule);
  if Editor = nil then Exit;
  View := CnOtaGetTopMostEditView(Editor);
  if View = nil then Exit;
  Editor.Show;
  CnOtaClosePage(View);
end;

//==============================================================================
// ���������غ���
//==============================================================================

// ȡ�õ�ǰ��ƵĴ��弰ѡ�������б����سɹ���־
function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList;
  ExcludeForm: Boolean): Boolean;
var
  i: Integer;
  AObj: TPersistent;
  FormDesigner: IDesigner;
  AList: IDesignerSelections;
begin
  Result := False;
  try
    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then Exit;
  {$IFDEF COMPILER6_UP}
    if FormDesigner.Root is TCustomForm then
      AForm := TCustomForm(FormDesigner.Root);
  {$ELSE}
    AForm := FormDesigner.Form;
  {$ENDIF}

    if Selections <> nil then
    begin
      Selections.Clear;
      AList := CreateSelectionList;
      FormDesigner.GetSelections(AList);
      for i := 0 to AList.Count - 1 do
      begin
      {$IFDEF COMPILER6_UP}
        AObj := TPersistent(AList[i]);
      {$ELSE}
        AObj := TryExtractPersistent(AList[i]);
      {$ENDIF}
        if AObj <> nil then // perhaps is nil when disabling packages in the IDE
          Selections.Add(AObj);
      end;
      
      if ExcludeForm and (Selections.Count = 1) and (Selections[0] = AForm) then
        Selections.Clear;
    end;
    Result := True;
  except
    ;
  end;
end;

// ȡ��ǰ��ƵĴ�����ѡ��ؼ�������
function CnOtaGetCurrFormSelectionsCount: Integer;
var
  AForm: TCustomForm;
  AList: TList;
begin
  Result := 0;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;
    Result := AList.Count;
  finally
    AList.Free;
  end;
end;

// �жϵ�ǰ��ƵĴ������Ƿ�ѡ���пؼ�
function CnOtaIsCurrFormSelectionsEmpty: Boolean;
begin
  Result := CnOtaGetCurrFormSelectionsCount <= 0;
end;

// ֪ͨ��������������ѱ��
procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor);
var
  FormDesigner: IDesigner;
begin
  FormDesigner := CnOtaGetFormDesigner(FormEditor);
  if FormDesigner = nil then Exit;
  FormDesigner.Modified;
end;

// �жϵ�ǰѡ��Ŀؼ��Ƿ�Ϊ��ƴ��屾��
function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor): Boolean;
var
  SelCount: Integer;
  CurrentComponent: IOTAComponent;
  RootComponent: IOTAComponent;
begin
  Result := False;
  if not Assigned(FormEditor) then
    FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);

  if FormEditor = nil then Exit;
  SelCount := FormEditor.GetSelCount;
  if SelCount = 1 then
  begin
    CurrentComponent := FormEditor.GetSelComponent(0);
    Assert(Assigned(CurrentComponent));
    RootComponent := FormEditor.GetRootComponent;
    Assert(Assigned(RootComponent));
    Result := SameText(RootComponent.GetComponentType, CurrentComponent.GetComponentType);
  end
  else
    Result := False;
end;

// �ж�����ڿؼ���ָ�������Ƿ����
function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  Assert(Assigned(Component));
  for i := 0 to Component.GetPropCount - 1 do
  begin
    Result := SameText(Component.GetPropName(i), PropertyName);
    if Result then
      Break;
  end;
end;

// ���õ�ǰ����ڴ���ѡ������Ϊ��ƴ��屾��
procedure CnOtaSetCurrFormSelectRoot;
var
  FormDesigner: IDesigner;
begin
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;
  FormDesigner.SelectComponent(FormDesigner.GetRoot);
end;

// ȡ�õ�ǰѡ��Ŀؼ��������б�
procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
var
  AForm: TCustomForm;
  AList: TList;
  i: Integer;
begin
  List.Clear;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;
    
    for i := 0 to AList.Count - 1 do
      List.Add(TComponent(AList[i]).Name);
  finally
    AList.Free;
  end;
end;

// ���Ƶ�ǰѡ��Ŀؼ��������б�������
procedure CnOtaCopyCurrFormSelectionsName;
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    CnOtaGetCurrFormSelectionsName(List);
    if List.Count = 1 then
      Clipboard.AsText := List[0]  // ֻ��һ��ʱȥ�����з�
    else
      Clipboard.AsText := List.Text;
  finally
    List.Free;
  end;
end;

// ����һ��λ��ֵ
function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
begin
  Result.CharIndex := CharIndex;
  Result.Line := Line;
end;

// ����һ���༭λ��ֵ
function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
begin
  Result.Col := Col;
  Result.Line := Line;
end;

// �ж������༭λ���Ƿ����
function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
begin
  Result := (Pos1.Col = Pos2.Col) and (Pos1.Line = Pos2.Line);
end;

// �ж������ַ�λ���Ƿ����
function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
begin
  Result := (Pos1.CharIndex = Pos2.CharIndex) and (Pos1.Line = Pos2.Line);
end;

// �ж�һ�ؼ������Ƿ��Ƿǿ��ӻ��ؼ�
function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
var
  AClassName: array[0..256] of Char;
begin
  //FillChar(AClassName, SizeOf(AClassName), #0);
  AClassName[GetClassName(hWnd, @AClassName, SizeOf(AClassName) - 1)] := #0;
  Result := string(AClassName) = NonvisualClassNamePattern;
end;

// Tests for file existance, a lot faster than the RTL implementation
function FileExists(const Filename: string): Boolean;
var
  a: Cardinal;
begin
  a := GetFileAttributes(PChar(Filename));
  Result := (a <> $FFFFFFFF) and (a and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

// �ø��ַ����жϵ�ǰ IDE/BDS �Ƿ��� Delphi�����򷵻� True��C++Builder �򷵻� False
function IsDelphiRuntime: Boolean;
{$IFDEF COMPILER9_UP}
var
  Project: IOTAProject;
  Personality: string;
{$ENDIF}
begin
{$IFNDEF COMPILER9_UP} // ���� BDS 2005/2006 �����ϣ����Ա�����Ϊ׼
  {$IFDEF DELPHI}
  Result := True;
  {$ELSE}
  Result := False;
  {$ENDIF}
  Exit;
{$ELSE} // �� BDS 2005/2006 ����������Ҫ��̬�ж�
  Result := CurrentIsDelphiSource;
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    Personality := Project.Personality;
    if (Personality = sDelphiPersonality) or (Personality = sDelphiDotNetPersonality) then
      Result := True
    else if (Personality = sCBuilderPersonality) or (Personality = sCSharpPersonality) then
      Result := False;
  end;
{$ENDIF}
end;

// �ø��ַ����жϵ�ǰ IDE �Ƿ��� C#�����򷵻� True�������򷵻� False
function IsCSharpRuntime: Boolean;
{$IFDEF COMPILER9_UP}
var
  Project: IOTAProject;
  Personality: string;
{$ENDIF}
begin
  Result := False;
{$IFDEF COMPILER9_UP}
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    Personality := Project.Personality;
    if Personality = sCSharpPersonality then
      Result := True;
  end;
{$ENDIF}
end;

// �жϵ�ǰ�Ƿ��� Delphi ����
function IsDelphiProject(Project: IOTAProject): Boolean;
{$IFDEF COMPILER9_UP}
var
  Personality: string;
{$ENDIF}
begin
  Result := False;
  if Project <> nil then
  begin
{$IFDEF COMPILER9_UP}
    Personality := Project.Personality;
    if (Personality = sDelphiPersonality) or (Personality = sDelphiDotNetPersonality) then
      Result := True;
{$ELSE}
    Result := IsDpr(Project.FileName) or IsDpk(Project.FileName);
{$ENDIF}
  end;
end;

// ��һ EditView �е���ǩ��Ϣ������һ ObjectList ��
procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  BookMarkObj: TCnBookmarkObj;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  for I := 0 to 9 do
  begin
    APos := EditView.BookmarkPos[I];
    if (APos.CharIndex <> 0) or (APos.Line <> 0) then
    begin
      BookMarkObj := TCnBookmarkObj.Create;
      BookMarkObj.ID := I;
      BookMarkObj.Line := APos.Line;
      BookMarkObj.Col := APos.CharIndex;
      BookMarkList.Add(BookMarkObj);
    end;
  end;
end;

// �� ObjectList �лָ�һ EditView �е���ǩ
procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  EditPos, SavePos: TOTAEditPos;
  BookMarkObj: TCnBookmarkObj;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  if BookMarkList.Count > 0 then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to 9 do // �������ǰ����ǩ
    begin
      APos := EditView.BookmarkPos[I];
      if (APos.Line <> 0) or (APos.CharIndex <> 0) then
      begin
        EditPos := EditView.CursorPos;
        EditPos.Line := APos.Line;
        EditView.CursorPos := EditPos;
        EditView.BookmarkToggle(I);
      end;
    end;

    for I := 0 to BookMarkList.Count - 1 do
    begin
      BookMarkObj := TCnBookmarkObj(BookMarkList.Extract(BookMarkList.First));
      EditPos := EditView.CursorPos;
      EditPos.Line := BookMarkObj.Line;
      EditView.CursorPos := EditPos;
      EditView.BookmarkToggle(BookMarkObj.ID);
      BookMarkObj.Free;
    end;
    EditView.CursorPos := SavePos;
  end;
end;

// �ж�������ʽƥ��
function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
  APattern: string; IsMatchStart: Boolean = False): Boolean;
begin
  Result := True;
  if (APattern = '') or (ARegExpr = nil) then Exit;

  if IsMatchStart and (APattern[1] <> '^') then // ����Ĵ�ͷƥ��
    APattern := '^' + APattern;

  ARegExpr.Expression := APattern;
  try
    Result := ARegExpr.Exec(AText);
  except
    Result := False;
  end;
end;

// ����ָ���������ļ����봰��
procedure TranslateFormFromLangFile(AForm: TCustomForm; const ALangDir, ALangFile: string;
  LangID: Cardinal);
var
  LangMgr: TCnLangManager;
  Storage: TCnHashLangFileStorage;
begin
  LangMgr := nil;
  Storage := nil;
  try
    LangMgr := TCnLangManager.Create(nil);
    LangMgr.AutoTranslate := False;
    LangMgr.TranslateTreeNode := True;
    LangMgr.UseDefaultFont := True;
    Storage := TCnHashLangFileStorage.Create(nil);
    Storage.StorageMode := smByDirectory;
    Storage.FileName := ALangFile;
    Storage.LanguagePath := ALangDir;
    LangMgr.LanguageStorage := Storage;
    if Storage.Languages.Find(LangID) >= 0 then
    begin
      LangMgr.CurrentLanguageIndex := Storage.Languages.Find(LangID);
      LangMgr.TranslateForm(AForm);
    end;
  finally
    LangMgr.Free;
    Storage.Free;
  end;
end;
  
initialization
  CnNoIconList := TStringList.Create;
  AddNoIconToList('TMenuItem'); // TMenuItem ����ר�Ҽ���֮ǰ��ע��
  AddNoIconToList('TField');
  AddNoIconToList('TAction');
  OldRegisterNoIconProc := RegisterNoIconProc;
  RegisterNoIconProc := CnRegisterNoIconProc;

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnWizUtils finalization.');
{$ENDIF Debug}

  RegisterNoIconProc := OldRegisterNoIconProc;
  FreeAndNil(CnNoIconList);
  
  FreeResDll;
{$IFDEF Debug}
  CnDebugger.LogLeave('CnWizUtils finalization.');
{$ENDIF Debug}

end.

