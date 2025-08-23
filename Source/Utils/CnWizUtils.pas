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

unit CnWizUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����������ڹ��̿ⵥԪ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ������ CnWizards ר�Ұ��Ĺ������̿�
*           �õ�Ԫ����������ֲ�� GExperts
*           ��ԭʼ������ GExperts License �ı���
*           ע�⣺IOTAEditBlock.Start/Ending/Column/Row �� 1 ��ʼ�ġ�
*           IOTAEditView.Position.Move�Ĳ������� Col Ҳ�� 1 ��ʼ�ġ�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.04 by liuxiao
*               ����һ�� Unicode �汾�ĺ���
*           2012.10.01 by shenloqi
*               �޸� CnOtaGetCurrLineText ���ܻ�ȡ���һ�к�δ TrimRight �� BUG
*               �޸� CnOtaInsertSingleLine ������ȷ�ڵ�һ�в���� BUG
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2005.05.06 by hubdog
*               ׷��������Ŀ����ֵ�ĺ������޸� CnOtaGetActiveProjectOptions
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
  Forms, ImgList, ExtCtrls, ComObj, IniFiles, FileCtrl, Buttons,
  {$IFDEF LAZARUS} LCLProc, {$IFNDEF STAND_ALONE} LazIDEIntf, ProjectIntf, SrcEditorIntf, {$ENDIF}
  {$ELSE} RegExpr, CnSearchCombo, {$IFNDEF STAND_ALONE} ExptIntf, ToolsAPI,
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, ComponentDesigner, Variants, Types,
  {$ELSE} DsgnIntf, LibIntf,{$ENDIF} {$ENDIF}
  {$IFDEF DELPHIXE3_UP} Actions,{$ENDIF} {$IFDEF USE_CODEEDITOR_SERVICE} ToolsAPI.Editor, {$ENDIF}
  {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, {$ENDIF}
  {$IFDEF IDE_SUPPORT_THEMING} CnIDEMirrorIntf, {$ENDIF} {$ENDIF}
  mPasLex, mwBCBTokenList, CnNative,
  Clipbrd, TypInfo, ComCtrls, StdCtrls, Imm, Contnrs, CnIDEStrings,
  CnPasWideLex, CnBCBWideTokenList, CnStrings, CnWizCompilerConst, CnWizConsts,
  CnCommon, CnConsts, CnWideStrings, CnWizClasses, CnWizIni,
  CnPasCodeParser, CnCppCodeParser, CnWidePasParser, CnWideCppParser;

const
  CRLF = #13#10;
  SAllAlphaNumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';

  InvalidNotifierIndex = -1;
  NonvisualClassNamePattern = 'TContainer';

  // ���Դ�����г���
  csMaxLineLength = 1023;

type
  ECnEmptyCommand = class(ECnWizardException);

  TFormType = (ftBinary, ftText, ftUnknown);

  TShortCutDuplicated = (sdNoDuplicated, sdDuplicatedIgnore, sdDuplicatedStop);
  // ��ݼ���ͻ������״̬
  TCnLoadIconProc = procedure(ABigIcon: TIcon; ASmallIcon: TIcon; const IconName: string);

{$IFNDEF NO_DELPHI_OTA}
{$IFNDEF COMPILER6_UP}
  IDesigner = IFormDesigner;
{$ENDIF}
{$ENDIF}

  // ��װ��һ�� EditView �� SourceEditorInterface �Ķ���
{$IFDEF STAND_ALONE}
  TCnEditViewSourceInterface = Pointer;
  TCnIDEProjectInterface = Pointer;
{$ELSE}
  {$IFDEF LAZARUS}
  TCnEditViewSourceInterface = TSourceEditorInterface;
  TCnIDEProjectInterface = TLazProject;
  {$ELSE}
  TCnEditViewSourceInterface = IOTAEditView;
  TCnIDEProjectInterface = IOTAProject;
  {$ENDIF}
{$ENDIF}

  TCnBookmarkObject = class
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
  CnNoIconList: TStrings;
  IdeClosing: Boolean = False;
  CnLoadIconProc: TCnLoadIconProc = nil; // ������ÿһ��ͼ�����ã����ⲿһ�������޸�ͼ������

{$IFNDEF LAZARUS}

//==============================================================================
// ������Ϣ����
//==============================================================================

{$IFDEF WIN64}
function CnIntToObject(AInt: Int64): TObject;
{* �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���}
function CnObjectToInt(AObject: TObject): Int64;
{* �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���}
{$ELSE}
function CnIntToObject(AInt: Integer): TObject;
{* �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���}
function CnObjectToInt(AObject: TObject): Integer;
{* �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���}
{$ENDIF}

{$IFDEF WIN64}
function CnIntToInterface(AInt: Int64): IUnknown;
{* �� Pascal Script ʹ�õĽ�����ֵת���� IUnknown �ĺ���}
function CnInterfaceToInt(Intf: IUnknown): Int64;
{* �� Pascal Script ʹ�õĽ� IUnknown ת��������ֵ�ĺ���}
{$ELSE}
function CnIntToInterface(AInt: Integer): IUnknown;
{* �� Pascal Script ʹ�õĽ�����ֵת���� IUnknown �ĺ���}
function CnInterfaceToInt(Intf: IUnknown): Integer;
{* �� Pascal Script ʹ�õĽ� IUnknown ת��������ֵ�ĺ���}
{$ENDIF}

{$IFDEF WIN64}
function CnGetClassFromClassName(const AClassName: string): Int64;
{* �� Pascal Script ʹ�õĴ�������ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassFromObject(AObject: TObject): Int64;
{* �� Pascal Script ʹ�õĴӶ����ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassNameFromClass(AClass: Int64): string;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ�����ĺ���}
function CnGetClassParentFromClass(AClass: Int64): Int64;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ������Ϣ�ĺ���}
{$ELSE}
function CnGetClassFromClassName(const AClassName: string): Integer;
{* �� Pascal Script ʹ�õĴ�������ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassFromObject(AObject: TObject): Integer;
{* �� Pascal Script ʹ�õĴӶ����ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassNameFromClass(AClass: Integer): string;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ�����ĺ���}
function CnGetClassParentFromClass(AClass: Integer): Integer;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ������Ϣ�ĺ���}
{$ENDIF}

{$ENDIF}

function CnWizLoadIcon(AIcon: TIcon; ASmallIcon: TIcon; const ResName: string;
  UseDefault: Boolean = False; IgnoreDisabled: Boolean = False): Boolean;
{* ����Դ���ļ���װ��ͼ�ִ꣬��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊ AIcon ͼ��װ�سɹ���־������ ResName �벻Ҫ�� .ico ��չ����
   AIcon ����ϵͳĬ�ϳߴ�һ���� 32*32��ASmallIcon ���� 16*16 ����еĻ�������Ϊ��
   ע�� ASmallIcon ����ĳߴ��Կ����� 32*32��ֻ�����Ͻ� 16*16 ������}
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
{* ����Դ���ļ���װ��λͼ��ִ��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊλͼװ�سɹ���־������ ResName �벻Ҫ�� .bmp ��չ��}
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList;
  Stretch: Boolean = True): Integer;
{* ����ͼ�굽 ImageList �У���ʹ��ƽ������}

{$IFNDEF LAZARUS}
{$IFDEF IDE_SUPPORT_HDPI}

procedure CopyImageListToVirtual(SrcImageList: TCustomImageList;
  DstVirtual: TVirtualImageList; const ANamePrefix: string = '';
  Disabled: Boolean = False);
{* ����ͳ�� ImageList ���ƽ� TVirtualImageList���ڲ������� ImageCollection ����}
function AddGraphicToVirtualImageList(Graphic: TGraphic; DstVirtual: TVirtualImageList;
  const ANamePrefix: string = ''; Disabled: Boolean = False): Integer;
{* ����ͨ�� TGraphic ���ƽ� TVirtualImageList���ڲ������� ImageCollection ����}
procedure CopyVirtualImageList(SrcVirtual, DstVirtual: TVirtualImageList;
  Disabled: Boolean = False);
{* �� TVirtualImageList ���ƽ� TVirtualImageList��Դ��Ŀ����Թ���һ�� ImageCollection
  �粻���ã����ڲ��ȸ��� ImageCollection ���ݡ����渴�� ImageList �����������ڲ���ͼ}

{$ENDIF}

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
{$ENDIF}
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
{$IFDEF IDE_SUPPORT_HDPI}
function GetIDEImagecollection: TCustomImageCollection;
{* ȡ�� IDE �� ImageList ���� VirtualImageList ʱ��Ӧ�� ImageCollection}
{$ENDIF}
procedure SaveIDEImageListToPath(ImgList: TCustomImageList; const Path: string);
{* ���� IDE ImageList �е�ͼ��ָ��Ŀ¼��}
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
{* ����˵������б��ļ�}
function GetIDEMainMenu: TMainMenu;
{* ȡ�� IDE ���˵�}
function GetIDEToolsMenu: TMenuItem;
{* ȡ�� IDE ���˵��µ� Tools �˵�}
function GetIdeRootDirectory: string;
{* ȡ�� IDE ��Ŀ¼}

function GetIDEActionList: TCustomActionList;
{* ȡ�� IDE �� ActionList��Lazarus ��Ϊ nil}
function GetIDEActionFromName(const AName: string): TCustomAction;
{* ȡ�� IDE �� ActionList ��ָ�����Ƶ� Action}
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
{* ȡ�� IDE �� ActionList ��ָ����ݼ��� Action}

procedure SaveIDEActionListToFile(const FileName: string);
{* ���� IDE ActionList �е����ݵ�ָ���ļ�}

function FindIDEAction(const ActionName: string): TContainedAction;
{* ���� IDE Action �������ض���}
procedure FindIDEActionByShortCut(AShortCut: TShortCut; Actions: TObjectList);
{* ���ݿ�ݼ����� IDE ��Ӧ�� Action ���󣬿����ж��}
function CheckQueryShortCutDuplicated(AShortCut: TShortCut;
  OriginalAction: TCustomAction): TShortCutDuplicated;
{* �жϿ�ݼ��Ƿ���������� Action ��ͻ���ų� OriginalAction
  �г�ͻ�򵯿�ѯ�ʣ������޳�ͻ���г�ͻ���û�ͬ�⡢�г�ͻ�û�ֹͣ}
function ExecuteIDEAction(const ActionName: string): Boolean;
{* ���� IDE Action ����ִ����}

{$IFNDEF NO_DELPHI_OTA}
function ReplaceToActualPath(const Path: string; Project: IOTAProject = nil): string;
{* �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��}
procedure SaveIDEOptionsNameToFile(const FileName: string);
{* ���� IDE �������ñ�������ָ���ļ�}
procedure SaveProjectOptionsNameToFile(const FileName: string);
{* ���浱ǰ���̻������ñ�������ָ���ļ�}
{$ENDIF}

function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: TCnNativeInt = 0;
  ImgIndex: Integer = -1): TMenuItem;
{* ����һ���Ӳ˵���}
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
{* ����һ���ָ��˵���}
procedure SortListByMenuOrder(List: TList);
{* ���� TCnMenuWizard �б��е� MenuOrder ֵ������С���������}
function IsTextForm(const FileName: string): Boolean;
{* ���� DFM �ļ��Ƿ��ı���ʽ}

procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
{* ����һЩִ�з����е��쳣}
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
{* �ڴ��ڿؼ��в���ָ����������}
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
{* �ڴ��ڿؼ��в���ָ�������������}

//==============================================================================
// �ؼ�������
//==============================================================================

type
  TCnSelectMode = (smAll, smNothing, smInvert);

function CnGetComponentText(Component: TComponent): string;
{* ��������ı���}
function CnGetComponentAction(Component: TComponent): TBasicAction;
{* ȡ�ؼ������� Action}
procedure RemoveListViewSubImages(ListView: TListView); overload;
{* ���� ListView �ؼ���ȥ������� SubItemImages}
procedure RemoveListViewSubImages(ListItem: TListItem); overload;
{* ���� ListItem��ȥ������� SubItemImages}
function GetListViewWidthString(AListView: TListView; DivFactor: Single = 1.0): string;
{* ת�� ListView ������Ϊ�ַ�������������С����}
procedure SetListViewWidthString(AListView: TListView; const Text: string; MulFactor: Single = 1.0);
{* ת���ַ���Ϊ ListView �����ȣ�������Ŵ���}
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ���������}
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ���������}
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
{* �޸� ListView ��ǰѡ����}

{$IFNDEF LAZARUS}
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
{* ȡ Cursor ��ʶ���б� }
procedure GetCharsetList(List: TStrings);
{* ȡ FontCharset ��ʶ���б� }
procedure GetColorList(List: TStrings);
{* ȡ Color ��ʶ���б� }

function GetListViewWidthString2(AListView: TListView; DivFactor: Single = 1.0): string;
{* ת�� ListView ������Ϊ�ַ�������������С�������ڲ��ᴦ�� D11.3 �����ϰ汾�����Ŀ������� HDPI �Ŵ����� Bug}

{$IFNDEF NO_DELPHI_OTA}

//==============================================================================
// �������ж� IDE/BDS �� Delphi ���� C++Builder ���Ǳ��
//==============================================================================

function IsDelphiRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� Delphi(.NET)�����򷵻� True�������򷵻� False}

function IsCSharpRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� C#�����򷵻� True�������򷵻� False}

function IsDelphiProject(Project: IOTAProject): Boolean;
{* �жϵ�ǰ�Ƿ��� Delphi ����}

function IsVCLFormEditor(FormEditor: IOTAFormEditor = nil): Boolean;
{* ����༭�������Ƿ� VCL ���壨�� .NET ���壩}

{$ENDIF}
{$ENDIF}

//==============================================================================
// �ļ����жϴ����� (���� GExperts Src 1.12)
//==============================================================================

resourcestring
  SCnDefDelphiSourceMask = '.PAS;.DPR';
  SCnDefCppSourceMask = '.CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';
  SCnDefSourceMask = '.PAS;.DPR;CPP;.C;.HPP;.H;.CXX;.CC;.HXX;.HH;.ASM';

function CurrentIsDelphiSource: Boolean;
{* ��ǰ�༭���ļ��� Delphi Դ�ļ������������������ȡ�� dfm �ȶ��ж�Ϊ False}
function CurrentIsCSource: Boolean;
{* ��ǰ�༭���ļ��� C/C++ Դ�ļ������������������ȡ�� dfm �ȶ��ж�Ϊ False}
function CurrentIsSource: Boolean;
{* ��ǰ�༭���ļ��� Delphi �� C/C++ Դ�ļ������������������ȡ�� dfm �ȶ��ж�Ϊ False}
function CurrentSourceIsDelphi: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩�� Delphi Դ�ļ�����ʹ�������ȡ�� dfm Ҳ�ж϶�ӦԴ�ļ�}
function CurrentSourceIsC: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩�� C/C++ Դ�ļ�����ʹ�������ȡ�� dfm Ҳ�ж϶�ӦԴ�ļ�}
function CurrentSourceIsDelphiOrCSource: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩�� Delphi �� C/C++ Դ�ļ�����ʹ�������ȡ�� dfm Ҳ�ж϶�ӦԴ�ļ�}
function CurrentIsForm: Boolean;
{* ��ǰ�༭���ļ��Ǵ����ļ�}

function ExtractUpperFileExt(const FileName: string): string;
{* ȡ��д�ļ���չ��}
procedure AssertIsDprOrPas(const FileName: string);
{* �ٶ��� .dpr��.pas�ļ�}
procedure AssertIsDprOrPasOrInc(const FileName: string);
{* �ٶ��� .dpr��.pas �� .inc�ļ�}
procedure AssertIsPasOrInc(const FileName: string);
{* �ٶ��� .pas �� .inc�ļ�}
function IsSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ� Delphi �� C/C++ Դ�ļ�}
function IsDelphiSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ� Delphi Դ�ļ�}
function IsDprOrPas(const FileName: string): Boolean;
{* �ж��Ƿ� .dpr��.pas �ļ�}
function IsDpr(const FileName: string): Boolean;
{* �ж��Ƿ� .dpr �ļ�}
function IsBpr(const FileName: string): Boolean;
{* �ж��Ƿ� .bpr �ļ�}
function IsLpr(const FileName: string): Boolean;
{* �ж��Ƿ� .lpr �ļ�}
function IsProject(const FileName: string): Boolean;
{* �ж��Ƿ� .bpr�� .dpr�ļ�}
function IsBdsProject(const FileName: string): Boolean;
{* �ж��Ƿ� .bdsproj �ļ�}
function IsDProject(const FileName: string): Boolean;
{* �ж��Ƿ� .dproj �ļ�}
function IsCbProject(const FileName: string): Boolean;
{* �ж��Ƿ� .cbproj �ļ�}
function IsDpk(const FileName: string): Boolean;
{* �ж��Ƿ� .dpk �ļ�}
function IsBpk(const FileName: string): Boolean;
{* �ж��Ƿ� .bpk �ļ�}
function IsLpk(const FileName: string): Boolean;
{* �ж��Ƿ� .lpk �ļ�}
function IsPackage(const FileName: string): Boolean;
{* �ж��Ƿ� .dpk��.bpk �ļ�}
function IsBpg(const FileName: string): Boolean;
{* �ж��Ƿ� .bpg �ļ�}
function IsPas(const FileName: string): Boolean;
{* �ж��Ƿ� .pas �ļ�}
function IsPp(const FileName: string): Boolean;
{* �ж��Ƿ� .pp �ļ�}
function IsDcu(const FileName: string): Boolean;
{* �ж��Ƿ� .dcu �ļ�}
function IsInc(const FileName: string): Boolean;
{* �ж��Ƿ� .inc �ļ�}
function IsDfm(const FileName: string): Boolean;
{* �ж��Ƿ� .dfm �ļ�}
function IsForm(const FileName: string): Boolean;
{* �ж��Ƿ����ļ������� dfm/xfm/fmx ��}
function IsXfm(const FileName: string): Boolean;
{* �ж��Ƿ� .xfm �ļ�}
function IsFmx(const FileName: string): Boolean;
{* �ж��Ƿ� .fmx �ļ�}
function IsCppSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ��������͵� C/C++ Դ�ļ����������� WizOptions �е�����}
function IsHpp(const FileName: string): Boolean;
{* �ж��Ƿ� .hpp �ļ�}
function IsCpp(const FileName: string): Boolean;
{* �ж��Ƿ� .cpp �ļ�}
function IsC(const FileName: string): Boolean;
{* �ж��Ƿ� .c �ļ�}
function IsH(const FileName: string): Boolean;
{* �ж��Ƿ� .h �ļ�}
function IsAsm(const FileName: string): Boolean;
{* �ж��Ƿ� .asm �ļ�}
function IsRC(const FileName: string): Boolean;
{* �ж��Ƿ� .rc �ļ�}
function IsKnownSourceFile(const FileName: string): Boolean;
{* �ж��Ƿ�δ֪�ļ�}
function IsTypeLibrary(const FileName: string): Boolean;
{* �ж��Ƿ��� TypeLibrary �ļ�}
function IsLua(const FileName: string): Boolean;
{* �ж��Ƿ��� lua �ļ�}
function IsSpecifiedExt(const FileName: string; const Ext: string): Boolean;
{* �ж��Ƿ���ָ����չ�����ļ���Ext ����Ҫ�����}
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
{* ʹ���ַ����ķ�ʽ�ж϶����Ƿ�̳��Դ���}
function FindControlByClassName(AParent: TWinControl; const AClassName: string;
  const AComponentName: string = ''): TControl;
{* ʹ���ַ����ķ�ʽ�жϿؼ��Ƿ����ָ���������ӿؼ��������򷵻�������һ��}

//==============================================================================
// OTA �ӿڲ�����غ���
//==============================================================================

function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
{* ��ѯ����ķ���ӿڲ�����һ��ָ���ӿ�ʵ�������ʧ�ܣ����� False}
function CnOtaGetCurrentSelection: string;
{* ȡ��ǰѡ����ı�}
function CnOtaGetTopMostEditView: TCnEditViewSourceInterface; overload;
{* ȡ��ǰ��ǰ�˵� IOTAEditView �ӿڻ� Lazarus �Ļ�༭��}
{$IFNDEF CNWIZARDS_MINIMUM}
function CnOtaDeSelection(CursorStopAtEnd: Boolean = True): Boolean;
{* ȡ����ǰѡ�񣬹����� CursorStopAtEnd ֵ����ͣ����ѡ����β����ͷ��������ѡ�����򷵻� False}
{$ENDIF}

function CnOtaGetCurrentProject: TCnIDEProjectInterface;
{* ȡ��ǰ���̽ӿڣ�֧�� Delphi �� Lazarus��}
function CnOtaGetCurrentProjectName: string;
{* ȡ��ǰ�������ƣ�����չ����֧�� Delphi �� Lazarus��}
function CnOtaGetCurrentProjectFileName: string;
{* ȡ��ǰ�����ļ����ƣ���չ�������� dpr/bdsproj/dproj��֧�� Delphi �� Lazarus��}
function CnOtaGetCurrentProjectFileNameEx: string;
{* ȡ��ǰ�����ļ�������չ��֧�� Delphi �� Lazarus��}

{$IFNDEF LAZARUS}
{$IFNDEF NO_DELPHI_OTA}

function CnOtaGetEditBuffer: IOTAEditBuffer;
{* ȡ IOTAEditBuffer �ӿ�}
function CnOtaGetEditPosition: IOTAEditPosition;
{* ȡ IOTAEditPosition �ӿ�}
function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string; ForceOpen: Boolean = True): IOTAEditView;
{* �����ļ������ر༭���д򿪵ĵ�һ�� EditView��δ��ʱ�� ForceOpen Ϊ True ���Դ򿪣����򷵻� nil}
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
{* ȡָ���༭����ǰ�˵� IOTAEditView �ӿ�}
function CnOtaEditViewSupportsSyntaxHighlight(EditView: IOTAEditView = nil): Boolean;
{* ȡָ�� IOTAEditView �Ƿ�ʹ���﷨����}
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
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor = nil): TWinControl;
{* ȡ�ô���༭���������ؼ��� DataModule ��������ע�� DataModule ������һ���Ƕ��㴰��}
function CnOtaGetCurrentDesignContainer: TWinControl;
{* ȡ�õ�ǰ����༭���������ؼ��� DataModule ��������ע�� DataModule ������һ���Ƕ��㴰��}
function CnOtaGetSelectedComponentFromCurrentForm(List: TList): Boolean; overload;
{* ȡ�õ�ǰ����༭������ѡ��������ʵ��}
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean; overload;
{* ȡ�õ�ǰ����༭������ѡ��Ŀؼ���ʵ��}
function CnOtaGetSelectedComponentFromCurrentForm(List: TInterfaceList): Boolean; overload;
{* ȡ�õ�ǰ����༭������ѡ�������� IComponenet �ӿ�}
function CnOtaGetSelectedControlFromCurrentForm(List: TInterfaceList): Boolean; overload;
{* ȡ�õ�ǰ����༭������ѡ��Ŀؼ��� IComponenet �ӿ�}
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
{* ���ش���༭����ƴ���������� DataModule �������ʵ������Ӧ�������ϵ�����ڼ������������ Owner}
function CnOtaGetFormDesignerGridOffset: TPoint;
{* ���ش���������ĸ��Ҳ���� Grid �ĺ�������������}
function CnOtaGetCurrentEditWindow: TCustomForm;
{* �� OTA �ķ�ʽȡ��ǰ�� EditWindow}
function CnOtaGetCurrentEditControl: TWinControl;
{* �� OTA �ķ�ʽȡ��ǰ�� EditControl �ؼ�}
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
{* ���ص�Ԫ����}
function CnOtaGetProjectGroup: IOTAProjectGroup;
{* ȡ��ǰ������}
function CnOtaGetProjectGroupFileName: string;
{* ȡ��ǰ�������ļ���}
function CnOtaGetProjectSourceFileName(Project: IOTAProject): string;
{* ȡ���̵�Դ���ļ� dpr/dpk}
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
{* ȡ������Դ}
function CnOtaGetProjectVersion(Project: IOTAProject = nil): string;
{* ȡ���̰汾���ַ���}
function CnOtaGetProject: IOTAProject;
{* ȡ��һ������}
function CnOtaGetProjectCountFromGroup: Integer;
{* ȡ��ǰ�������й��������޹����鷵�� -1}
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
{* ȡ��ǰ�������еĵ� Index �����̣��� 0 ��ʼ}
function CnOtaGetProjectSourceFiles(Sources: TStrings;
  IncludeDpr: Boolean = True; Project: IOTAProject = nil): Boolean;
{* ��ȡָ��������������Դ���ļ������� Sources���粻ָ���������õ�ǰ���̣������Ƿ��ȡ�ɹ�}
function CnOtaGetProjectGroupSourceFiles(Sources: TStrings;
  IncludeDpr: Boolean = True): Boolean;
{* ��ȡ��ǰ�����������й����е�Դ���ļ������� Sources�������Ƿ��ȡ�ɹ�}
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
function CnOtaGetOptionsNames(Options: IOTAOptions; IncludeType:
  Boolean = True): string; overload;
{* ȡ�� IDE ���ñ������б�}
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
{* ���õ�ǰ��Ŀ������ֵ}

function CnOtaGetProjectPlatform(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰ Platform ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰ FrameworkType ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName: string): string;
{* �����Ŀ�ĵ�ǰ BuildConfiguration �е�����ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject; const APropName,
  AValue: string);
{* ������Ŀ�ĵ�ǰ BuildConfiguration �е�����ֵ���粻֧�ִ�������ʲô������}

{$IFDEF SUPPORT_CROSS_PLATFORM}
procedure CnOtaGetPlatformsFromBuildConfiguration(BuildConfig: IOTABuildConfiguration; Platforms: TStrings);
{* ��ȡ BuildConfiguration �� Platforms �� TStrings �У��Ա���Ͱ汾��ű���֧�ַ��͵�����}
{$ENDIF}

function CnOtaGetProjectOutputDirectory(Project: IOTAProject): string;
{* �����Ŀ�Ķ������ļ����Ŀ¼}
function CnOtaGetProjectOutputTarget(Project: IOTAProject): string;
{* �����Ŀ�Ķ������ļ��������·��}
procedure CnOtaGetProjectList(const List: TInterfaceList);
{* ȡ�����й����б�}
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
function CnOtaGetEnvironmentOptionValue(const OptionName: string): Variant;
{* ȡ��ǰ������ָ������ֵ}
procedure CnOtaSetEnvironmentOptionValue(const OptionName: string; OptionValue: Variant);
{* ���õ�ǰ������ָ������ֵ}
function CnOtaGetEditOptions: IOTAEditOptions;
{* ȡ��ǰ�༭������}
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
{* ȡ��ǰ����ѡ��}
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
{* ȡ��ǰ����ָ��ѡ��}
function CnOtaGetPackageServices: IOTAPackageServices;
{* ȡ��ǰ�����������}

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* ȡ��ǰ��������ѡ�2009 �����Ч}
{$ENDIF}

function CnOtaGetNewFormTypeOption: TFormType;
{* ȡ�����������½�������ļ�����}
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
{* ����ָ��ģ��ָ���ļ����ĵ�Ԫ�༭��}
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
{* ����ָ��ģ��ָ���ļ����ı༭��}
function CnOtaGetEditActionsFromModule(Module: IOTAModule = nil): IOTAEditActions;
{* ����ָ��ģ��� EditActions }
procedure CnOtaDeleteCurrentSelection;
{* ɾ��ѡ�е��ı�}
function CnOtaReplaceCurrentSelection(const Text: string; NoSelectionInsert: Boolean = True;
  KeepSelecting: Boolean = False; LineMode: Boolean = False): Boolean;
{* ���ı��滻ѡ�е��ı���
  Text����������ݣ�2007 �� Text �� AnsiString�����ܶ��ַ�����2009 ������ UnicodeString��
  NoSelectionInsert��������ѡ����ʱ�Ƿ��ڵ�ǰλ�ò��롣
  KeepSelecting�����Ʋ�����Ƿ�ѡ�в������ݡ�
  LineMode �Ƿ��Ƚ�ѡ����չ�����С�
  �����Ƿ�ɹ�����֪���⣺D5���ƺ�ѡ����Ч}
function CnOtaReplaceCurrentSelectionUtf8(const Utf8Text: AnsiString; NoSelectionInsert: Boolean = True;
  KeepSelecting: Boolean = False; LineMode: Boolean = False): Boolean;
{* ���ı��滻ѡ�е��ı��������� Utf8 �� Ansi �ַ��������� D2005~2007 ��ʹ�ã������ַ�}

procedure CnOtaEditBackspace(Many: Integer);
{* �ڱ༭�����˸�}
procedure CnOtaEditDelete(Many: Integer);
{* �ڱ༭����ɾ��}

{$IFNDEF CNWIZARDS_MINIMUM}

function CnOtaGetCurrentProcedure: string;
{* ��ȡ��ǰ������ڵĹ��̻�������������ʵ�����򣬲�������������}
function CnOtaGetCurrentOuterBlock: string;
{* ��ȡ��ǰ������ڵ�����������}
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
{* ȡָ���е�Դ���룬�к��� 1 ��ʼ�����ؽ��Ϊ Ansi/Unicode���� UTF8}
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
{* ȡ��ǰ��Դ����}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; ActualPosWhenEmpty: Boolean = False): Boolean;
{* ʹ�� NTA ����ȡ��ǰ��Դ���롣�ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
   ���ʹ�� ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1
   ��ֵ�� EditPos.Col ���ɡ�
   ActualPosWhenEmpty ���Ƶ�ǰ�ı�Ϊ��ʱ��CharIndex ʹ�� 0 ���ǹ�����ʵλ��
   D567 ȡ������AnsiString��CharIndex �ǵ�ǰ����� Text �е� Ansi λ�ã�0 ��ʼ��
   BDS �� Unicode ��ȡ������ UTF8 ��ʽ�� AnsiString��CharIndex �ǵ�ǰ����� Text �е� Utf8 λ�ã�0 ��ʼ��
   Unicode IDE ��ȡ�õ��� UTF16 �ַ�����CharIndex �ǵ�ǰ����� Text �е� Utf16 λ�ã�0 ��ʼ��}

{$IFDEF UNICODE}
function CnNtaGetCurrLineTextW(var Text: string; var LineNo: Integer;
  var Utf16CharIndex: Integer; PreciseMode: Boolean = False): Boolean;
{* ʹ�� NTA ����ȡ��ǰ��Դ����Ĵ� Unicode �汾���ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
   �������� ConvertPos ת�� EditPos��ֻ�ܽ� CharIndex ת�� Ansi �� + 1 ���� EditPos.Col��
   Utf16CharIndex �ǵ�ǰ����� Text �е� Utf16 ��ʵλ�ã�0 ��ʼ��+ 1 ����±�
   PreciseMode Ϊ True ʱʹ�� Canvas.TextWidth ���������ַ���ʵ�ʿ�ȣ�׼ȷ������
   Ϊ False ʱֱ���ж��ַ� Unicode �����Ƿ���� $1100 ����������һ�ַ����Ƕ��ַ���
   ���ϲ��ֹŹ� Unicode �ַ�ʱ�����ƫ��}
{$ENDIF}

function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
{* ���� SourceEditor ��ǰ����Ϣ}
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil;
  SupportUnicodeIdent: Boolean = False): Boolean;
{* ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ��ٶȽϿ죬���� Unicode ��ʶ��
  Token �� 2009 Ϊ�緵�� Ansi �� Utf16�������� 2005 ~ 2007���� Utf8 ת Ansi �Ŀ��ܶ��ַ�������}

{$IFDEF IDE_STRING_ANSI_UTF8}
function CnOtaGetCurrPosTokenUtf8(var Token: WideString; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil;
  SupportUnicodeIdent: Boolean = False; IndexUsingWide: Boolean = False): Boolean;
{* ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ����� Unicode ��ʶ�������� 2005 ~ 2007��
  ����� WideString������ Utf8 ת Ansi �Ķ��ַ����Ρ�
  CurrIndex 0 ��ʼ������ IndexUsingWide �������� Ansi �� Wide ƫ��}
{$ENDIF}

{$IFDEF UNICODE}
function CnOtaGetCurrPosTokenW(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCharSet = [];
  CharSet: TCharSet = []; EditView: IOTAEditView = nil; SupportUnicodeIdent: Boolean = False;
  IndexUsingWide: Boolean = False; PreciseMode: Boolean = False): Boolean;
{* ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ŵ� Unicode �汾������ Unicode ��ʶ����
  ������ 2009 �����ϡ�CurrIndex 0 ��ʼ������ IndexUsingWide �������� Ansi �� Wide ƫ��
  PreciseMode Ϊ True ʱʹ�� Canvas.TextWidth ���������ַ���ʵ�ʿ�ȣ�׼ȷ������
   Ϊ False ʱֱ���ж��ַ��Ƿ���� $1100 ����������һ�ַ����Ƕ��ַ������ϲ��ֹŹ� Unicode �ַ������ƫ��}
{$ENDIF}

function CnOtaGeneralGetCurrPosToken(var Token: TCnIdeTokenString; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []; EditView: IOTAEditView = nil): Boolean;
{* ��װ�Ļ�ȡ��ǰ����µı�ʶ���Լ������ŵĺ�����BDS �������� Unicode ��ʶ���������� Unicode ת Ansi �Ķ��ַ������⡣
  Token: D567 �·��� AnsiString��2005~2007 �·��� WideString��2009 �����Ϸ��� UnicodeString
  CurrIndex: 0 ��ʼ��D567 �·��ص�ǰ����� Token �ڵ� Ansi ƫ�ƣ�2007 �����Ϸ��� WideChar ƫ��}

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
{* �ж�λ���Ƿ񳬳���β�ˡ��˻����� Unicode �����µ�ǰ�к��г���һ�����ַ�ʱ���ܻ᲻׼������ }
procedure CnOtaGetCurrentBreakpoints(Results: TList);
{* ʹ�� CnWizDebuggerNotifierServices ��ȡ��ǰԴ�ļ��ڵĶϵ㣬
   List �з��� TCnBreakpointDescriptor ʵ��}
function CnOtaSelectCurrentToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
{* ѡ�е�ǰ����µı�ʶ������������û�б�ʶ���򷵻� False}

{$ENDIF}

function IsValidDotIdentifier(const Ident: string): Boolean;
{* �Ƿ��Ƿ��ϵ�ǰ Delphi �汾�ĺϷ���ʶ��������ӵ㵫�㲻������ǰ��}

procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
{* ѡ��һ������飬ò�Ʋ��ر�ɿ�}
function CnOtaMoveAndSelectBlock(const Start, After: TOTACharPos; View: IOTAEditView = nil): Boolean;
{* �� Block �ķ�ʽ���ô����ѡ���������Ƿ�ɹ���D5 ���� Bug ���ܵ��� D5 ���޷�ѡ�С�
   ������ʼλ�ñ���С�ڽ���λ�ã�����Ҳ�޷�ѡ�С�ѡ��ɹ�����ͣ���ڽ�����}
function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView = nil): Boolean;
{* �� Block Extend �ķ�ʽѡ��һ�У������Ƿ�ɹ�����괦������}
function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer; View: IOTAEditView = nil): Boolean;
{* �� Block Extend �ķ�ʽѡ�ж��У����ͣ���� End ������ʶ�ĵط��������Ƿ�ɹ�}
function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
{* ֱ������ֹ����Ϊ����ѡ�д���죬����һ��ʼ�������Ƿ�ɹ�
   ��������д���ֹ���У��ڲ��ụ��}
function CnOtaCurrBlockEmpty: Boolean;
{* ���ص�ǰѡ��Ŀ��Ƿ�Ϊ��}
function CnOtaGetBlockOffsetForLineMode(var StartPos: TOTACharPos; var EndPos: TOTACharPos;
  View: IOTAEditView = nil): Boolean;
{* ���ص�ǰѡ��Ŀ���չ����ģʽ�����ʼλ�ã���ʵ����չѡ����}
function CnOtaCloseFileByAction(const FileName: string): Boolean;
{* �� ActionService ���ر��ļ�}
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
{* ��δ����Ĵ���}
{$ENDIF}
{$ENDIF}

function CnOtaOpenFile(const FileName: string): Boolean;
{* ���ļ�}
function CnOtaIsFileOpen(const FileName: string): Boolean;
{* �ж��ļ��Ƿ��}

{$IFNDEF LAZARUS}
{$IFNDEF NO_DELPHI_OTA}
procedure CnOtaSaveFile(const FileName: string; ForcedSave: Boolean = False);
{* �����ļ�}
function CnOtaSaveFileByAction(const FileName: string): Boolean;
{* �� ActionService �������ļ�����Ȼ�ᵯ������Ի���}
procedure CnOtaCloseFile(const FileName: string; ForceClosed: Boolean = False);
{* �ر��ļ�}
function CnOtaIsFormOpen(const FormName: string): Boolean;
{* �жϴ����Ƿ��}
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
{* �ж�ģ���Ƿ��ѱ��޸�}
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
{* ָ��ģ���Ƿ����ı����巽ʽ��ʾ, Lines Ϊת��ָ���У�<= 0 ����}
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
{* ��ָ���ļ��ɼ������ Lines �������� 0����������õ� Lines �д�ֱ����}
function CnOtaIsDebugging: Boolean;
{* ��ǰ�Ƿ��ڵ���״̬}
function CnOtaGetBaseModuleFileName(const FileName: string): string;
{* ȡģ��ĵ�Ԫ�ļ���}
function CnOtaIsPersistentBlocks: Boolean;
{* ��ǰ PersistentBlocks �Ƿ�Ϊ True}

{$ENDIF}

//==============================================================================
// Դ���������غ���
//==============================================================================

function ConvertNtaEditorStringToAnsi(const LineText: string; UseAlterChar: Boolean = False): AnsiString;
{* ��ͨ�� Nta ������õ��ַ��� AnsiString/AnsiUtf8/Utf16 ����ת��Ϊ AnsiString}

{$ENDIF}

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean; MaxLen: Integer = 0; AddAtHead: Boolean = False): string;
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

{$IFNDEF LAZARUS}

{$IFDEF COMPILER6_UP}
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
{* ����ת�� Utf8 �� Ansi �ַ����������ڳ��ȶ�����Ҫ�� Ansi �ַ����ַ���}
{$ENDIF}

{$IFDEF UNICODE}
function ConvertTextToEditorUnicodeText(const Text: string): string;
{* Unicode ������ת���ַ���Ϊ�༭��ʹ�õ��ַ��������� AnsiString ת��}
{$ENDIF}

function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
{* ת���ַ���Ϊ�༭��ʹ�õ��ַ���}

function ConvertEditorTextToText(const Text: AnsiString): AnsiString;
{* ת���༭��ʹ�õ��ַ���Ϊ��ͨ�ַ���}

{$IFDEF IDE_WIDECONTROL}

function ConvertWTextToEditorText(const Text: WideString): AnsiString;
{* ת�����ַ���Ϊ�༭��ʹ�õ��ַ�����Utf8����D2005~2007 �汾ʹ��}

function ConvertEditorTextToWText(const Text: AnsiString): WideString;
{* ת���༭��ʹ�õ��ַ�����Utf8��Ϊ���ַ�����D2005~2007 �汾ʹ��}

{$ENDIF}

{$IFDEF UNICODE}

function ConvertTextToEditorTextW(const Text: string): AnsiString;
{* ת���ַ���Ϊ�༭��ʹ�õ��ַ�����Utf8����D2009 ���ϰ汾ʹ��}

function ConvertEditorTextToTextW(const Text: AnsiString): string;
{* ת���༭��ʹ�õ��ַ�����Utf8��Ϊ Unicode �ַ�����D2009 ���ϰ汾ʹ��}

{$ENDIF}

{$ENDIF}

function CnOtaGetCurrentSourceFile: string;
{* ȡ��ǰ�༭��Դ�ļ����༭���ʱ�����ڱ༭��Դ�ļ���
  ����ƴ���ʱ���᷵�� dfm �������ļ�������Դ���ļ�}

function CnOtaGetCurrentSourceFileName: string;
{* ȡ��ǰ�༭�� Pascal �� Cpp Դ�ļ����ж����ƽ϶ࡣ
  ��ȡ�� dfm �ȣ����ж϶�Ӧ pas/cpp Դ�ļ��Ƿ�򿪣����򷵻ض�ӦԴ�ļ�}

{$IFNDEF NO_DELPHI_OTA}

procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);
{* �� EditPosition �в���һ���ı���֧�� D2005 ��ʹ�� utf-8 ��ʽ}

{$IFNDEF CNWIZARDS_MINIMUM}

function CnOtaGetLinesElideInfo(Infos: TList; EditControl: TControl = nil): Boolean;
{* ��һ�༭���е����۵���Ϣ��Infos ��� List ��˳������۵��Ŀ�ʼ�кͽ�����
  ���۵���֧���۵�ʱ���� False��ע����ʱ�޷����ֽ��ڵ������۵���}

{$ENDIF}

{$ENDIF}

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
{* ����һ���ı�����ǰ���ڱ༭��Դ�ļ��У����سɹ���־��ע�� Lazarus �� Text ��Ҫ Utf8 ��ʽ��
   ���� Delphi �в�������ı�ʱ���ܳ��ֲ���Ҫ���������� EditPosition.InsertText �ľ���
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

 procedure CnOtaInsertTextIntoEditor(const Text: string);
{* �����ı�����ǰ IOTASourceEditor �ĵ�ǰ���λ�ã���������ı���
  ע��÷����ڲ�ʹ���˵�ǰ��������λ�ã�����λ��ת������в��ᳬ����β�����ƣ���˸÷��������ı�ʱ������ǰ�е���߿���}

{$IFNDEF STAND_ALONE}

function CnGeneralGetCurrLinearPos(SourceEditor: {$IFDEF LAZARUS} TSourceEditorInterface
  {$ELSE} IOTASourceEditor {$ENDIF} = nil): Integer;
{* �� CnGeneralSaveEditorToStream �� FromCurrPos Ϊ False ʱ���ʹ�õġ�
  ���ص�ǰ����� Stream �е��ַ�ƫ������0 ��ʼ���� Stream ��ʽ��ӦΪ Ansi/Utf16/Utf16}

function CnOtaGetCurrLinearPos(SourceEditor: {$IFDEF LAZARUS} TSourceEditorInterface
  {$ELSE} IOTASourceEditor {$ENDIF} = nil): Integer;
{* ���� SourceEditor ��ǰ���λ�õ����Ե�ַ����Ϊ 0 ��ʼ�� Ansi/Utf8/Utf8��Lazarus ��ҲΪ Utf8
  ������Delphi �� Unicode �����µ�ǰλ��֮ǰ�п��ַ�ʱ CharPosToPos ��ֵ�����ף���������
  ���˴�������ǰ�е� Utf8 ƫ�������������ˣ��պ��ű�֤�� Unicode �����µ� Utf8}

procedure CnPasParserParseSource(Parser: TCnGeneralPasStructParser;
  Stream: TMemoryStream; AIsDpr, AKeyOnly: Boolean);
{* ��װ�Ľ��������� Pascal ����Ĺ��̣��������Ե�ǰ���Ĵ���}

procedure CnPasParserParseString(Parser: TCnGeneralPasStructParser;
  Stream: TMemoryStream);
{* ��װ�Ľ��������� Pascal �����е��ַ����Ĺ��̣��������Ե�ǰ���Ĵ���}

procedure CnCppParserParseSource(Parser: TCnGeneralCppStructParser;
  Stream: TMemoryStream; CurrLine: Integer = 0; CurCol: Integer = 0;
  ParseCurrent: Boolean = False; NeedRoundSquare: Boolean = False);
{* ��װ�Ľ��������� Cpp ����Ĺ��̣������˶Ե�ǰ���Ĵ����Լ��Ƿ���ҪС�����ŷֺš�
   Line �� Col Ϊ Cpp ������ʹ�õ� Ansi/Wide/Wide ƫ�ƣ�1 ��ʼ}

procedure CnCppParserParseString(Parser: TCnGeneralCppStructParser;
  Stream: TMemoryStream);
{* ��װ�Ľ��������� C/C++ �����е��ַ����Ĺ��̣��������Ե�ǰ���Ĵ���}

function CnOtaGetCurrentCharPosFromCursorPosForParser(out CharPos: TOTACharPos): Boolean;
{* ��ȡ��ǰ���λ�ò�����ת����Ϊ StructureParser ����� CharPos��Ҳ������ 1 ��ʼ���� 0 ��ʼ}

{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF NO_DELPHI_OTA}

function CnOtaGetLinePosFromEditPos(EditPos: TOTAEditPos; SourceEditor: IOTASourceEditor = nil): Integer;
{* ���� SourceEditor ָ���༭λ�õ����Ե�ַ����Ϊ 0 ��ʼ�� Ansi/Utf8/Utf8��
  ������ Unicode �����µ�ǰλ��֮ǰ�п��ַ�ʱ CharPosToPos ��ֵ�����ף���������
  ���˴�������ǰ�е� Utf8 ƫ�������������ˣ��պ��ű�֤�� Unicode �����µ� Utf8}

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
{* ���� SourceEditor ��ǰ���λ��}

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer; {$IFDEF UNICODE} deprecated; {$ENDIF}
{* �༭λ��ת��Ϊ����λ�ã���Ϊ 0 ��ʼ�� Ansi/Utf8/Utf8 ��� Ansi
   �� Unicode �����¸�λ��֮ǰ�п��ַ�ʱ��ֵ�����ף����Ƽ�ʹ��}

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos; {$IFDEF UNICODE} deprecated; {$ENDIF}
{* ����λ��ת��Ϊ�༭λ�ã�����λ��Ҫ��Ϊ 0 ��ʼ�� Ansi/Utf8/Utf8 ��� Ansi
   �� Unicode �����¸�λ��֮ǰ�п��ַ�ʱ����û������}

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
{* ���� EditReader ���ݵ����У����е����� CheckUtf8 ΪĬ�� True ʱΪ Ansi ��ʽ������Ϊ Ansi/Utf8/Utf8������ĩβ #0 �ַ���
   AlternativeWideChar ��ʾ CheckUtf8 Ϊ True ʱ���ڴ�Ӣ�� OS �� Unicode �����£�
   �Ƿ�ת���ɵ� Ansi �е�ÿ�����ַ��ֶ��滻�������ո񡣴�ѡ�����ڶ����Ӣ�� OS
   �� Unicode ������ UnicodeString ֱ��ת Ansi ʱ�Ķ��ַ�����}

procedure CnOtaSaveEditorToStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
{* ����༭���ı������У�CheckUtf8 Ϊ True ʱ��Ϊ Ansi ��ʽ������Ϊ Ansi/Utf8/Utf8}

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
{* ����༭���ı������У�CheckUtf8 Ϊ True ʱ��Ϊ Ansi ��ʽ������Ϊ Ansi/Utf8/Utf8}

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False): Boolean;
{* ���浱ǰ�༭���ı������У�CheckUtf8 Ϊ True ʱ��Ϊ Ansi ��ʽ������Ϊ Ansi/Utf8/Utf8}

function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean = True): string;
{* ȡ�õ�ǰ�༭��Դ����}

function CnGeneralFilerLoadFileFromStream(const FileName: string; Stream: TMemoryStream): Boolean;
{* ��װ��һͨ�÷�����ʹ�� Filer �������ݼ�����ָ���ļ�����Ҫ�� BDS ���Ͼ�ʹ�� WideChar��
  D567 ʹ�� AnsiChar�������� UTF8��Ҳ���� Ansi/Utf16/Utf16��ĩβ�����н����ַ� #0��
  �����ִ����ļ������ڴ棬�� Ansi �� Wide ����﷨�����д���ļ���}

function CnGeneralFilerSaveFileToStream(const FileName: string; Stream: TMemoryStream): Boolean;
{* ��װ��һͨ�÷�����ʹ�� Filer ��ָ���ļ����ݱ��������У�BDS ���Ͼ�ʹ�� WideChar��
  D567 ʹ�� AnsiChar�������� UTF8��Ҳ���� Ansi/Utf16/Utf16��ĩβ���н����ַ� #0��
  �����ִ����ļ������ڴ棬�� Ansi �� Wide ����﷨������}

{$IFDEF IDE_STRING_ANSI_UTF8}

procedure CnOtaSaveReaderToWideStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* ���� EditReader ���ݵ����У����е�����Ϊ WideString ��ʽ����ĩβ #0 �ַ���2005 ~ 2007 ��ʹ��}

procedure CnOtaSaveEditorToWideStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* ����༭���ı������У�Utf8 ����תΪ WideString����ĩβ #0 �ַ���2005 ~ 2007 ��ʹ��}

function CnOtaSaveEditorToWideStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
{* ����༭���ı������У�Utf8 ����תΪ WideString����ĩβ #0 �ַ���2005 ~ 2007 ��ʹ��}

function CnOtaSaveCurrentEditorToWideStream(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
{* ���浱ǰ�༭���ı������У�Utf8 ����תΪ WideString����ĩβ #0 �ַ���2005 ~ 2007 ��ʹ��}

{$ENDIF}

{$IFDEF UNICODE}

procedure CnOtaSaveReaderToStreamW(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* ���� EditReader ���ݵ����У����е�����Ĭ��Ϊ Unicode ��ʽ����ĩβ #0 �ַ���2009 ����ʹ��}

procedure CnOtaSaveEditorToStreamWEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
{* ����༭���ı������У�Unicode �汾����ĩβ #0 �ַ���2009 ����ʹ��}

function CnOtaSaveEditorToStreamW(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
{* ����༭���ı������У�Unicode �汾����ĩβ #0 �ַ���2009 ����ʹ��}

function CnOtaSaveCurrentEditorToStreamW(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
{* ���浱ǰ�༭���ı������У�Unicode �汾����ĩβ #0 �ַ���2009 ����ʹ��}

function CnOtaGetCurrentEditorSourceW: string;
{* ȡ�õ�ǰ�༭��Դ���룬Unicode �汾��2009 ����ʹ��}

procedure CnOtaSetCurrentEditorSourceW(const Text: string);
{* ���õ�ǰ�༭��Դ���룬Unicode �汾��2009 ����ʹ��}

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}
procedure CnOtaSetCurrentEditorSourceUtf8(const Text: string);
{* ���õ�ǰ�༭��Դ���룬ֻ�� D2005~2007 �汾ʹ�ã�����Ϊԭʼ UTF8 ����}
{$ENDIF}

procedure CnOtaSetCurrentEditorSource(const Text: string);
{* ���õ�ǰ�༭��Դ���룬���ڸ��汾ʹ�ã����ж����ת�����ܵ��¶�����
   ����ע�����������һ��̫��Ʃ�糬�� 1024�����ܻᱻ IDE �ضϣ�����ͬ}

procedure CnOtaInsertLineIntoEditor(const Text: string);
{* ����һ���ַ�������ǰ IOTASourceEditor������ Text Ϊ�����ı�ʱ����
   �����滻��ǰ��ѡ���ı���}

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
{* ����һ���ı���ǰ IOTASourceEditor��Line Ϊ�кţ�Text Ϊ���� }

procedure CnOtaInsertTextIntoEditorUtf8(const Utf8Text: AnsiString);
{* �����ı�����ǰ IOTASourceEditor����������ı���
  ���� D2005~2007 ���������� CnOtaInsertTextIntoEditor �Ա���ת�� Ansi �����ܶ��ַ�������}

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
{* Ϊָ�� SourceEditor ����һ�� Writer���������Ϊ�շ��ص�ǰֵ��}

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* ��ָ��λ�ô������ı����ڲ��������Ҫ�� Utf8 ת������� SourceEditor Ϊ��ʹ�õ�ǰֵ��
  Position ����λ�ÿ��ɹ��λ�� ConvertPos �Լ� CharPosToPos ת��������ע��ת��������ᳬ����β��}

procedure CnOtaInsertTextIntoEditorAtPosUtf8(const Utf8Text: AnsiString; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* ��ָ��λ�ô����� Utf8 �ַ�������� SourceEditor Ϊ��ʹ�õ�ǰֵ��
  ���� D2005~2007 ���������� CnOtaInsertTextIntoEditorAtPos �Ա���ת�� Ansi �����ܶ��ַ������⡣
  Position ����λ�ÿ��ɹ��λ�� ConvertPos �Լ� CharPosToPos ת��������ע��ת��������ᳬ����β��}

{$IFDEF UNICODE}
procedure CnOtaInsertTextIntoEditorAtPosW(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* ��ָ��λ�ô������ı������ SourceEditor Ϊ��ʹ�õ�ǰֵ��D2009 ����ʹ�á�
  Position ����λ�ÿ��ɹ��λ�� ConvertPos �Լ� CharPosToPos ת��������ע��ת��������ᳬ����β��}
{$ENDIF}

{$IFNDEF CNWIZARDS_MINIMUM}

procedure CnOtaGotoEditPosAndRepaint(EditView: IOTAEditView; EditPosLine: Integer; EditPosCol: Integer = 0);
{* �������ָ���������в��ػ������о��� 1 ��ʼ��EditPosCol Ϊ 0 ʱ��ʾ����}

{$ENDIF}

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��
  Middle Ϊ True ʱ��ʾ��ֱ�����Ϲ��������У�False ��ʾ������������ɼ����籾���ɼ��Ͳ�����}

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
{* ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ�� }

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã�BDS ���ϵ���ʹ�� Utf8 ����ֵ����� EditView Ϊ��ʹ�õ�ǰֵ��
  Middle Ϊ True ʱ��ʾ��ֱ�����Ϲ��������У����ƺ�������
  False ��ʾ������������ɼ����籾���ɼ��Ͳ�����
  ����߰汾 Delphi �� 10.x ���ϣ���ѡ����ʱ���ܻ������ת�����ƫ��}

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
{* ת��һ������λ�õ� TOTACharPos����Ϊ�� D5/D6 �� IOTAEditView.PosToCharPos
   ���ܲ�����������}

function CnOtaGetBlockIndent: Integer;
{* ��õ�ǰ�༭����������� }

procedure CnOtaClosePage(EditView: IOTAEditView);
{* �ر�ģ����ͼ}

procedure CnOtaCloseEditView(AModule: IOTAModule);
{* ���ر�ģ�����ͼ�������ر�ģ��}

procedure CnOtaConvertEditViewCharPosToEditPos(EditViewPtr: Pointer;
  CharPosLine, CharPosCharIndex: Integer; var EditPos: TOTAEditPos);
{* �� EditView �е� CharPos תΪ EditPos����װ�������� 2009 ������ƫ�������
  EditView ʹ�� Pointer ���д��������Ч�ʡ�2005 ���ϲ�ʹ�� ConvertPos���Ӷ�
  ת�������Ľ������������ Tab ��ʱ������ʵ������������ڿ��ַ����ṹ�﷨������
  ���Ѿ�������Ԥ�ȵ� Tab չ���������������}

{$IFNDEF CNWIZARDS_MINIMUM}

procedure CnOtaConvertEditPosToParserCharPos(EditViewPtr: Pointer; var EditPos:
  TOTAEditPos; var CharPos: TOTACharPos);
{* �� EditPos ת����Ϊ StructureParser ����� CharPos��δ���ƣ���δʹ��}

function CnOtaConvertEditPosToLinearPos(EditViewPtr: Pointer; var EditPos: TOTAEditPos;
  out Position: Integer): Boolean;
{* �� EditPos ת����Ϊ EditWriter ��������� Pos���ڲ���װ Unicode �����µ�ǰ�п��ַ�ƫ��}

{$ENDIF}

procedure CnConvertGeneralTokenPositionToCharPos(EditViewPtr: Pointer;
  Token: TCnGeneralPasToken; out CharPos: TOTACharPos);
{* ��װ�İ� Pascal Token ���������� Ansi/Wide λ�ò���ת���� IDE ����� CharPos �Ĺ���
  ��� CharPos���Ա��� EditView ת���� EditPos��Token ������ C/C++ �� TCnGeneralCppToken}

procedure ConvertGeneralTokenPos(EditView: Pointer; AToken: TCnGeneralPasToken);
{* ������������������ Token ������ת���� IDE ����� EditPos�������� C/C++ �� TCnGeneralCppToken}

procedure ParseUnitUsesFromFileName(const FileName: string; UsesList: TStrings);
{* ����Դ���������õĵ�Ԫ��FileName �������ļ���}

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

procedure CnOtaGetCurrFormSelectionsClassName(List: TStrings);
{* ȡ�õ�ǰѡ��Ŀؼ��������б�}

procedure CnOtaCopyCurrFormSelectionsClassName;
{* ���Ƶ�ǰѡ��Ŀؼ��������б�������}

function CnOtaIDESupportsTheming: Boolean;
{* ��� IDE �Ƿ�֧�������л�}

function CnOtaGetIDEThemingEnabled: Boolean;
{* ��� IDE �Ƿ������������л�}

function CnOtaGetActiveThemeName: string;
{* ��� IDE ��ǰ��������}

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

procedure CloneSearchCombo(var ASearchCombo: TCnSearchComboBox; ACombo: TComboBox);
{* ��һ�� Combo ����Ϊ CnSearchCombo�����������滻��}

function FileExists(const Filename: string): Boolean;
{* Tests for file existance, a lot faster than the RTL implementation }

procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* ��һ EditView �е���ǩ��Ϣ������һ ObjectList ��}

procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* �� ObjectList ��ȫ���ָ�һ EditView �е���ǩ}

procedure ReplaceBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
{* �� ObjectList ���滻һ���� EditView �е���ǩ}

{$ENDIF}

function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
  APattern: string; IsMatchStart: Boolean = False): Boolean;
{* �ж�������ʽƥ��}

{$IFNDEF CNWIZARDS_MINIMUM}
procedure TranslateFormFromLangFile(AForm: TCustomForm; const ALangDir, ALangFile: string;
  LangID: Cardinal);
{* ����ָ���������ļ����봰��}
{$ENDIF}

{$ENDIF}

procedure CnEnlargeButtonGlyphForHDPI(const Button: TControl);
{* ���� HDPI ���ã��Ŵ� Button �е� Glyph��Button ֻ���� SpeedButton �� BitBtn}

{$IFNDEF STAND_ALONE}

{$IFDEF LAZARUS}

function CnLazSaveEditorToStream(Editor: TSourceEditorInterface; Stream: TMemoryStream;
  FromCurrPos: Boolean = False; CheckUtf8: Boolean = False): Boolean;
{* Lazarus �±���༭���ı������У���֧�� Ansi ģʽ��
  CheckUtf8 Ϊ True ʱΪ Utf8 ��ʽ�� #0������Ϊ Utf16 ��ʽ���� #0}

{$ENDIF}

function CnGeneralSaveEditorToStream(Editor: {$IFDEF LAZARUS} TSourceEditorInterface {$ELSE} IOTASourceEditor {$ENDIF};
  Stream: TMemoryStream; FromCurrPos: Boolean = False): Boolean;
{* ��װ��һͨ�÷�������༭���ı������У�Lazarus �� BDS ���Ͼ�ʹ�� WideChar��D567 ʹ�� AnsiChar�������� UTF8
  Ҳ���� Ansi/Utf16/Utf16��Lazarus ��Ҳ���� Utf16��ĩβ���н����ַ� #0���� Ansi �� Wide ����﷨�����á�
  ����� MemoryStream���� Memory ��ֱ��ת���� PCnIdeTokenChar��ͬ���� Ansi/Wide/Wide
  ���Ҫ�� FromCurrPos Ϊ False ������»�ȡ��ǰ����� Stream �е�ƫ����
  ���� CnGeneralGetCurrLinearPos ������ƫ����Ҳ���� Ansi/Utf16/Utf16}

function CnGeneralSaveEditorToUtf8Stream(Editor: {$IFDEF LAZARUS} TSourceEditorInterface {$ELSE} IOTASourceEditor {$ENDIF};
  Stream: TMemoryStream; FromCurrPos: Boolean = False): Boolean;
{* ��װ��һͨ�÷�������༭���ı������У�Lazarus �� BDS ���Ͼ�ʹ�� Utf8��D567 ���ǲ��ò�ʹ�� Ansi��
  Ҳ���� Ansi/Utf8/Utf8��Lazarus ��Ҳ���� Utf8��ĩβ���н����ַ� #0}

{$ENDIF}

function CnWizInputQuery(const ACaption, APrompt: string;
  var Value: string; Ini: TCustomIniFile = nil;
  const Section: string = csDefComboBoxSection): Boolean;
{* ��װ������Ի����ڲ�����ص����÷Ŵ��}

function CnWizInputBox(const ACaption, APrompt, ADefault: string;
   Ini: TCustomIniFile = nil; const Section: string = csDefComboBoxSection): string;
{* ��װ������Ի����ڲ�����ص����÷Ŵ��}

function CnWizInputMultiLineQuery(const ACaption, APrompt: string;
  var Value: string): Boolean;
{* ��װ����������ַ����ĶԻ����ڲ�����ص����÷Ŵ��}

function CnWizInputMultiLineBox(const ACaption, APrompt, ADefault: string): string;
{* ��װ����������ַ����ĶԻ����ڲ�����ص����÷Ŵ��}

procedure CnWizAssert(Expr: Boolean; const Msg: string = '');
{* ��װ Assert �ж�}

var
  CnLoadedIconCount: Integer = 0; // ���м�¼���ص� Icon ����

{$IFDEF NO_DELPHI_OTA}
  // ����ģ���滻�ı���
  CnStubRefMainForm: TCustomForm = nil;
  CnStubRefMainMenu: TMainMenu = nil;
  CnStubRefImageList: TCustomImageList = nil;
  CnStubRefActionList: TActionList = nil;
{$ENDIF}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFDEF SUPPORT_FMX}
  CnFmxUtils,
{$ENDIF}
  Math, CnWizOptions, CnGraphUtils, CnWizShortCut, CnWizIdeUtils, CnWizHelp,
  CnLangMgr, CnLangStorage, CnHashLangStorage
  {$IFNDEF STAND_ALONE} {$IFDEF LAZARUS} {$ELSE}, CnWizEditFiler, CnWizScaler
  {$IFNDEF CNWIZARDS_MINIMUM}
  , CnWizMultiLang, CnWizDebuggerNotifier, CnEditControlWrapper, CnIDEVersion
  {$ENDIF} {$ENDIF} {$ENDIF}
  ;

const
  MAX_LINE_LENGTH = 2048;
  CNWIZARDDEFAULT_ICO = 'CnWizardDefault';

type
  TControlAccess = class(TControl);
  TGraphicHack = class(TGraphic);

{$IFNDEF LAZARUS}

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
  I: Integer;
begin
  for I := Low(ComponentClasses) to High(ComponentClasses) do
  begin
    if CnNoIconList.IndexOf(ComponentClasses[I].ClassName) < 0 then
    begin
      CnNoIconList.Add(ComponentClasses[I].ClassName);
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

{$IFDEF WIN64}

// �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���
function CnIntToObject(AInt: Int64): TObject;
begin
  Result := TObject(AInt);
end;

// �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���
function CnObjectToInt(AObject: TObject): Int64;
begin
  Result := Int64(AObject);
end;

{$ELSE}

// �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���
// ����Ϊ Pascal Script ��֧�� TObject(0) �����﷨��
function CnIntToObject(AInt: Integer): TObject;
begin
  Result := TObject(AInt);
end;

// �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���
function CnObjectToInt(AObject: TObject): Integer;
begin
  Result := Integer(AObject);
end;

{$ENDIF}

{$IFDEF WIN64}

// �� Pascal Script ʹ�õĽ�����ֵת���� Interface �ĺ���
function CnIntToInterface(AInt: Int64): IUnknown;
begin
  Result := IUnknown(AInt);
end;

// �� Pascal Script ʹ�õĽ� Interface ת��������ֵ�ĺ���
function CnInterfaceToInt(Intf: IUnknown): Int64;
begin
  Result := Int64(Intf);
end;

{$ELSE}

// �� Pascal Script ʹ�õĽ�����ֵת���� Interface �ĺ���
function CnIntToInterface(AInt: Integer): IUnknown;
begin
  Result := IUnknown(AInt);
end;

// �� Pascal Script ʹ�õĽ� Interface ת��������ֵ�ĺ���
function CnInterfaceToInt(Intf: IUnknown): Integer;
begin
  Result := Integer(Intf);
end;

{$ENDIF}

{$IFDEF WIN64}

// �� Pascal Script ʹ�õĴ�������ȡ����Ϣ��ת��������ֵ�ĺ���
function CnGetClassFromClassName(const AClassName: string): Int64;
begin
  Result := Int64(GetClass(AClassName));
end;

// �� Pascal Script ʹ�õĴӶ����ȡ����Ϣ��ת��������ֵ�ĺ���
function CnGetClassFromObject(AObject: TObject): Int64;
begin
  Result := Int64(AObject.ClassType);
end;

// �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ�����ĺ���
function CnGetClassNameFromClass(AClass: Int64): string;
begin
  Result := TClass(AClass).ClassName;
end;

// �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ������Ϣ�ĺ���
function CnGetClassParentFromClass(AClass: Int64): Int64;
begin
  Result := Int64(TClass(AClass).ClassParent);
end;

{$ELSE}

// �� Pascal Script ʹ�õĴ�������ȡ����Ϣ��ת��������ֵ�ĺ���
function CnGetClassFromClassName(const AClassName: string): Integer;
begin
  Result := Integer(GetClass(AClassName));
end;

// �� Pascal Script ʹ�õĴӶ����ȡ����Ϣ��ת��������ֵ�ĺ���
function CnGetClassFromObject(AObject: TObject): Integer;
begin
  Result := Integer(AObject.ClassType);
end;

// �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ�����ĺ���
function CnGetClassNameFromClass(AClass: Integer): string;
begin
  Result := TClass(AClass).ClassName;
end;

// �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ������Ϣ�ĺ���
function CnGetClassParentFromClass(AClass: Integer): Integer;
begin
  Result := Integer(TClass(AClass).ClassParent);
end;

{$ENDIF}

{$ENDIF}

var
  FResInited: Boolean;
  HResModule: HMODULE;

// ������Դ DLL �ļ�
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

// �ͷ���Դ DLL �ļ�
procedure FreeResDll;
begin
  if HResModule <> 0 then
    FreeLibrary(HResModule);
  FResInited := False;
end;

// ����Դ���ļ���װ��ͼ��
function CnWizLoadIcon(AIcon: TIcon; ASmallIcon: TIcon; const ResName: string;
  UseDefault: Boolean; IgnoreDisabled: Boolean): Boolean;
var
  FileName: string;
  AHandle: HICON;

  procedure AfterIconLoad;
  begin
    if Assigned(CnLoadIconProc) then
      CnLoadIconProc(AIcon, ASmallIcon, ResName);
  end;

  // ר��ֻ���� 16x16 Сͼ��
  procedure LoadAndCheckSmallIcon;
  begin
    // ָ��С�ߴ��ټ���ͼ��
    if ASmallIcon <> nil then
    begin
      ASmallIcon.Height := 16;
      ASmallIcon.Width := 16;
      ASmallIcon.LoadFromFile(FileName);

      // ������ص���ͼ��ߴ粻�� 16x16 �����
      if ASmallIcon.Handle <> 0 then
        if (ASmallIcon.Height <> 16) or (ASmallIcon.Width <> 16) then
          ASmallIcon.Handle := 0;
    end;
  end;

begin
  Result := False;
  if WizOptions.DisableIcons and not IgnoreDisabled then // ������ǿ�ƺ��� WizOptions.DisableIcons
    Exit;

  // ���ļ���װ��
  try
    if SameFileName(_CnExtractFileName(ResName), ResName) then
      FileName := WizOptions.IconPath + ResName + SCnIcoFileExt
    else
      FileName := ResName;

    if FileExists(FileName) then
    begin
      if AIcon <> nil then
      begin
        AIcon.LoadFromFile(FileName); // AIcon ʹ�������� 32 * 32 �ߴ�
        if not AIcon.Empty then
        begin
          Result := True;
          Inc(CnLoadedIconCount);

          LoadAndCheckSmallIcon;
          AfterIconLoad;
          Exit;
        end;
      end
      else
      begin
        Result := True;
        Inc(CnLoadedIconCount);

        LoadAndCheckSmallIcon;
        AfterIconLoad;
        Exit;
      end;
    end;
  except
    ;
  end;

  // ����Դ��װ��
  if LoadResDll then
  begin
    if AIcon <> nil then
    begin
      // ��װ����ƥ��ߴ� 32 * 32
      AHandle := LoadImage(HResModule, PChar(UpperCase(ResName)), IMAGE_ICON, 32, 32, 0);
      if AHandle <> 0 then
      begin
        AIcon.Handle := AHandle;
        Inc(CnLoadedIconCount);
        Result := True;

        // ��ָ��С�ߴ����
        if ASmallIcon <> nil then
        begin
          AHandle := LoadImage(HResModule, PChar(UpperCase(ResName)), IMAGE_ICON, 16, 16, 0);
          if AHandle <> 0 then
          begin
            ASmallIcon.Handle := AHandle;
            Inc(CnLoadedIconCount);
          end;
        end;

        AfterIconLoad;
        Exit;
      end;
    end
    else if ASmallIcon <> nil then // ֻװ��С�ߴ�ģ�����ֻ�� 32x32 ��ͼ���ļ���˵���ܲ��ɹ�
    begin
      AHandle := LoadImage(HResModule, PChar(UpperCase(ResName)), IMAGE_ICON, 16, 16, 0);
      if AHandle <> 0 then
      begin
        ASmallIcon.Handle := AHandle;
        Result := True;

        Inc(CnLoadedIconCount);
        AfterIconLoad;
        Exit;
      end;
    end;
  end;

  // ����δ���سɹ��ŵ�����
  if UseDefault then
  begin
    FileName := WizOptions.IconPath + CNWIZARDDEFAULT_ICO + SCnIcoFileExt;
    if FileExists(FileName) then // ��Ĭ�ϵ� ico �ļ�
    begin
      if AIcon <> nil then
      begin
        AIcon.LoadFromFile(FileName);
        if not AIcon.Empty then
        begin
          Result := True;
          Inc(CnLoadedIconCount);

          // ָ��С�ߴ��ټ���ͼ��
          if ASmallIcon <> nil then
          begin
            ASmallIcon.Height := 16;
            ASmallIcon.Width := 16;
            ASmallIcon.LoadFromFile(FileName);
            Inc(CnLoadedIconCount);
          end;
          Exit;
        end;
      end
      else if ASmallIcon <> nil then
      begin
        ASmallIcon.Height := 16;
        ASmallIcon.Width := 16;
        ASmallIcon.LoadFromFile(FileName);
        Result := True;

        Inc(CnLoadedIconCount);
        Exit;
      end;
    end;
  end;

  if UseDefault then // ����Ĭ��ͼ����Դ
  begin
    if AIcon <> nil then
    begin
      AHandle := LoadImage(HResModule, PChar(UpperCase(CNWIZARDDEFAULT_ICO)), IMAGE_ICON, 0, 0, 0);
      if AHandle <> 0 then
      begin
        AIcon.Handle := AHandle;
        Inc(CnLoadedIconCount);
        Result := True;

        // ��ָ��С�ߴ����
        if ASmallIcon <> nil then
        begin
          AHandle := LoadImage(HResModule, PChar(UpperCase(CNWIZARDDEFAULT_ICO)), IMAGE_ICON, 16, 16, 0);
          if AHandle <> 0 then
          begin
            ASmallIcon.Handle := AHandle;
            Inc(CnLoadedIconCount);
          end;
        end;

        Exit;
      end;
    end
    else if ASmallIcon <> nil then
    begin
      AHandle := LoadImage(HResModule, PChar(UpperCase(CNWIZARDDEFAULT_ICO)), IMAGE_ICON, 16, 16, 0);
      if AHandle <> 0 then
      begin
        ASmallIcon.Handle := AHandle;
        Result := True;

        Inc(CnLoadedIconCount);
        Exit;
      end;
    end;
  end;
end;

// ����Դ���ļ���װ��λͼ
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
var
  FileName: string;
begin
  Result := False;
  // if WizOptions.DisableIcons then // Bitmap ���٣���ʡ��
  //   Exit;

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

// ����ͼ�굽 ImageList �У���ʹ��ƽ�����촦��
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList;
  Stretch: Boolean): Integer;
const
  MaskColor = clBtnFace;
var
  SrcBmp, DstBmp: TBitmap;
  PSrc1, PSrc2, PDst: PRGBArray;
  X, Y: Integer;
begin
  Assert(Assigned(AIcon));
  Assert(Assigned(ImageList));

{$IFDEF DEBUG}
  if not AIcon.Empty then
    CnDebugger.LogFmt('AddIcon %dx%d To ImageList %dx%d', [AIcon.Width, AIcon.Height,
      ImageList.Width, ImageList.Height]);
{$ENDIF}

  if (ImageList.Width = 16) and (ImageList.Height = 16) and not AIcon.Empty and
    (AIcon.Width = 32) and (AIcon.Height = 32) then
  begin
    if Stretch then // ImageList �ߴ��ͼ���ָ�����������£�ʹ��ƽ������
    begin
      SrcBmp := nil;
      DstBmp := nil;
      try
        SrcBmp := CreateEmptyBmp24(32, 32, MaskColor);
        DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
        SrcBmp.Canvas.Draw(0, 0, AIcon);
        for Y := 0 to DstBmp.Height - 1 do
        begin
          PSrc1 := SrcBmp.ScanLine[Y * 2];
          PSrc2 := SrcBmp.ScanLine[Y * 2 + 1];
          PDst := DstBmp.ScanLine[Y];
          for X := 0 to DstBmp.Width - 1 do
          begin
            PDst^[X].b := (PSrc1^[X * 2].b + PSrc1^[X * 2 + 1].b + PSrc2^[X * 2].b
              + PSrc2^[X * 2 + 1].b) shr 2;
            PDst^[X].g := (PSrc1^[X * 2].g + PSrc1^[X * 2 + 1].g + PSrc2^[X * 2].g
              + PSrc2^[X * 2 + 1].g) shr 2;
            PDst^[X].r := (PSrc1^[X * 2].r + PSrc1^[X * 2 + 1].r + PSrc2^[X * 2].r
              + PSrc2^[X * 2 + 1].r) shr 2;
          end;
        end;
        Result := ImageList.AddMasked(DstBmp, MaskColor);
      finally
        if Assigned(SrcBmp) then FreeAndNil(SrcBmp);
        if Assigned(DstBmp) then FreeAndNil(DstBmp);
      end;
    end
    else
    begin
      // ָ�������������£��� 32*32 ͼ������Ͻ� 16*16 ���ֻ���������
      DstBmp := nil;
      try
        DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
        DstBmp.Canvas.Draw(0, 0, AIcon);
        Result := ImageList.AddMasked(DstBmp, MaskColor);
      finally
        DstBmp.Free;
      end;
    end;
  end
  else if not AIcon.Empty then
    Result := ImageList.AddIcon(AIcon)
  else
    Result := -1;
end;

{$IFNDEF LAZARUS}
{$IFDEF IDE_SUPPORT_HDPI}

procedure CopyImageListToVirtual(SrcImageList: TCustomImageList;
  DstVirtual: TVirtualImageList; const ANamePrefix: string; Disabled: Boolean);
var
  I, C1, C2: Integer;
  Ico: TIcon;
  Mem: TMemoryStream;
  Collection: TImageCollection;
begin
  if (SrcImageList = nil) or (DstVirtual = nil) or
    (DstVirtual.ImageCollection = nil) then
    Exit;

  if DstVirtual.ImageCollection is TImageCollection then
    Collection := DstVirtual.ImageCollection as TImageCollection
  else
    Exit;

  C1 := Collection.Count;
  Mem := TMemoryStream.Create;
  try
    for I := 0 to SrcImageList.Count - 1 do
    begin
      Ico := TIcon.Create;
      try
        SrcImageList.GetIcon(I, Ico);
        Mem.Clear;
        Ico.SaveToStream(Mem);
      finally
        Ico.Free;
      end;
      Collection.Add(ANamePrefix + IntToStr(I), Mem);
    end;
  finally
    Mem.Free;
  end;
  C2 := Collection.Count;

  DstVirtual.Add('', C1, C2 - 1, Disabled);
end;

function AddGraphicToVirtualImageList(Graphic: TGraphic; DstVirtual: TVirtualImageList;
  const ANamePrefix: string; Disabled: Boolean): Integer;
var
  C: Integer;
  R: TRect;
  Bmp: TBitmap;
  Mem: TMemoryStream;
  Collection: TImageCollection;
begin
  Result := -1;
  if (Graphic = nil) or (DstVirtual = nil) then
    Exit;

  if DstVirtual.ImageCollection is TImageCollection then
    Collection := DstVirtual.ImageCollection as TImageCollection
  else
    Exit;

  C := Collection.Count;
  Mem := TMemoryStream.Create;
  try
    if Graphic is TIcon then // �� Icon ��ֱ�Ӵ���ⶪʧ͸����
    begin
      Mem.Clear;
      (Graphic as TIcon).SaveToStream(Mem);
    end
    else if Graphic is TBitmap then
    begin
      Mem.Clear;
      (Graphic as TBitmap).SaveToStream(Mem);
    end
    else
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.PixelFormat := pf32bit;
        Bmp.AlphaFormat := afIgnored;
        Bmp.Width := Graphic.Width;
        Bmp.Height := Graphic.Height;
        R := Rect(0, 0, Bmp.Width, Bmp.Height);
        TGraphicHack(Graphic).Draw(Bmp.Canvas, R);

        Mem.Clear;
        Bmp.SaveToStream(Mem);
      finally
        Bmp.Free;
      end;
    end;
    Collection.Add(ANamePrefix + IntToStr(C), Mem);
  finally
    Mem.Free;
  end;

  DstVirtual.Add('', C, C, Disabled);
  Result := DstVirtual.Count - 1;
end;

procedure CopyVirtualImageList(SrcVirtual, DstVirtual: TVirtualImageList;
  Disabled: Boolean);
begin
  if (SrcVirtual = nil) or (DstVirtual = nil) then
    Exit;

  if SrcVirtual.ImageCollection = nil then
    Exit;

  // ���Ŀ��û�У�����Դ��
  if DstVirtual.ImageCollection = nil then
    DstVirtual.ImageCollection := SrcVirtual.ImageCollection;

  // ���Ŀ�����Ҳ�ͬ��Դ������
  if SrcVirtual.ImageCollection <> DstVirtual.ImageCollection then
    DstVirtual.ImageCollection.Assign(SrcVirtual.ImageCollection);

  // �ٸ������ݣ��ڲ�����ȫ Assign ���
  DstVirtual.Images := SrcVirtual.Images;
end;

{$ENDIF}

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
  x, y, I: Integer;
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
            for I := 0 to 3 do
              if (C[I]^.r = tr) and (C[I]^.g = tg) and (C[I]^.b = tb) then
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
  I: Integer;
  Len: Integer;
  NextResultChar: Integer;
  CheckChar: Char;
  NextChar: Char;
begin
  Len := Length(Str);
  NextResultChar := 1;
  SetLength(Result, Len);

  for I := 1 to Len do
  begin
    CheckChar := Str[I];
    NextChar := Str[I + 1];
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
          Result[NextResultChar] := Str[I];
          Inc(NextResultChar);
        end;
    end;
  end;
  if Len = 0 then
    Exit;
  SetLength(Result, NextResultChar - 1);
end;

{$ENDIF}

// ��ʾָ������İ�������
procedure ShowHelp(const Topic: string);
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  if not CnWizHelp.ShowHelp(Topic) then
    ErrorDlg(SCnNoHelpofThisLang);
{$ENDIF}
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
  I, L: Integer;
begin
  Result := Caption;
  for I := Length(Result) downto 1 do
  begin
    if Result[I] = '.' then
      Delete(Result, I, 1);
  end;

  L := Length(Result);
  if L > 4 then
  begin
    if CharInSet(Result[L - 3], ['(', '[']) and (Result[L - 2] = '&') and
      CharInSet(Result[L], [')', ']']) then
      Delete(Result, L - 3, 4);
  end;

  Result := StringReplace(Result, '&', '', [rfReplaceAll]);
end;

//ȡ�� IDE �� ImageList
function GetIDEImageList: TCustomImageList;
{$IFNDEF NO_DELPHI_OTA}
var
  Svcs40: INTAServices40;
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := CnStubRefImageList;
{$ELSE}
{$IFDEF LAZARUS}
  Result := GetIDEMainMenu.Images;
{$ELSE}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ImageList;
{$ENDIF}
{$ENDIF}
end;

{$IFDEF IDE_SUPPORT_HDPI}

// ȡ�� IDE �� ImageList ���� VirtualImageList ʱ��Ӧ�� ImageCollection
function GetIDEImagecollection: TCustomImageCollection;
var
  IL: TCustomImageList;
begin
  IL := GetIDEImageList;
  if (IL <> nil) and (IL is TVirtualImageList) then
    Result := (IL as TVirtualImageList).ImageCollection
  else
    Result := nil;
end;

{$ENDIF}

// ���� IDE ImageList �е�ͼ��ָ��Ŀ¼��}
procedure SaveIDEImageListToPath(ImgList: TCustomImageList; const Path: string);
var
  Bmp: TBitmap;
  I: Integer;
begin
  if (ImgList = nil) or not DirectoryExists(Path) then
    Exit;

  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf24bit;
  Bmp.Width := ImgList.Width;
  Bmp.Height := ImgList.Height;
  try
    for I := 0 to ImgList.Count - 1 do
    begin
      Bmp.Canvas.Brush.Color := clFuchsia;
      Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
      ImgList.GetBitmap(I, Bmp);
      Bmp.SaveToFile(MakePath(Path) + IntToStrEx(I, 3) + '.bmp');
    end;
  finally
    Bmp.Free;
  end;
end;

// ����˵������б��ļ�
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
var
  I: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    for I := 0 to AMenu.Count - 1 do
      List.Add(AMenu.Items[I].Name + ' | ' + AMenu.Items[I].Caption);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// ȡ�� IDE ���˵�
function GetIDEMainMenu: TMainMenu;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  I: Integer;
  F: TCustomForm;
{$ELSE}
  Svcs40: INTAServices40;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := CnStubRefMainMenu;
{$ELSE}
{$IFDEF LAZARUS}
  F := GetIDEMainForm;
  for I := 0 to F.ComponentCount - 1 do
  begin
    if F.Components[I] is TMainMenu then
    begin
      Result := F.Components[I] as TMainMenu;
      Exit;
    end;
  end;
{$ELSE}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.MainMenu;
{$ENDIF}
{$ENDIF}
end;

// ȡ�� IDE ���˵��µ� Tools �˵�
function GetIDEToolsMenu: TMenuItem;
var
  MainMenu: TMainMenu;
  I: Integer;
begin
  MainMenu := GetIDEMainMenu; // IDE ���˵�
  if MainMenu <> nil then
  begin
{$IFDEF LAZARUS}
    Result := MainMenu.Items.Items[8]; // Lazarus ��д�����
    Exit;
{$ELSE}
    for I := 0 to MainMenu.Items.Count - 1 do
    begin
      if AnsiCompareText(SToolsMenuName, MainMenu.Items[I].Name) = 0 then
      begin
        Result := MainMenu.Items[I];
        Exit;
      end;
    end;
{$ENDIF}
  end;
  Result := nil;
end;

// ȡ�� IDE ��Ŀ¼
function GetIdeRootDirectory: string;
begin
  Result := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));
end;

// ȡ�� IDE �� ActionList
function GetIDEActionList: TCustomActionList;
{$IFNDEF NO_DELPHI_OTA}
var
  Svcs40: INTAServices40;
{$ENDIF}
begin
{$IFDEF NO_DELPHI_OTA}
  Result := CnStubRefActionList;
{$ELSE}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ActionList;
{$ENDIF}
end;

// ȡ�� IDE �� ActionList ��ָ�����Ƶ� Action
function GetIDEActionFromName(const AName: string): TCustomAction;
var
  I: Integer;
  ActionList: TCustomActionList;
begin
  Result := nil;
  ActionList := GetIDEActionList;
  if ActionList <> nil then
  begin
    for I := 0 to ActionList.ActionCount - 1 do
    begin
      if ActionList.Actions[I] is TCustomAction then
      begin
        if TCustomAction(ActionList.Actions[I]).Name = AName then
        begin
          Result := TCustomAction(ActionList.Actions[I]);
          Exit;
        end;
      end;
    end;
  end;
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
  begin
    for I := 0 to ActionList.ActionCount - 1 do
    begin
      if ActionList.Actions[I] is TCustomAction then
      begin
        if TCustomAction(ActionList.Actions[I]).ShortCut = ShortCut then
        begin
          Result := TCustomAction(ActionList.Actions[I]);
          Exit;
        end;
      end;
    end;
  end;
end;

// ���� IDE ActionList �е����ݵ�ָ���ļ�
procedure SaveIDEActionListToFile(const FileName: string);
var
  ActionList: TCustomActionList;
  I: Integer;
  List: TStrings;
begin
  ActionList := GetIDEActionList;
  if ActionList = nil then
    Exit;

  List := TStringList.Create;
  try
    for I := 0 to ActionList.ActionCount - 1 do
    begin
      if ActionList.Actions[I] is TCustomAction then
        with ActionList.Actions[I] as TCustomAction do
          List.Add(Name + ' | ' + Caption)
      else
        List.Add(ActionList.Actions[I].Name);
    end;
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// ���� IDE Action �������ض���
function FindIDEAction(const ActionName: string): TContainedAction;
var
  ActionList: TCustomActionList;
  I: Integer;
begin
  if ActionName = '' then
  begin
    Result := nil;
    Exit;
  end;

  ActionList := GetIDEActionList;
  if ActionList <> nil then
  begin
    for I := 0 to ActionList.ActionCount - 1 do
    begin
      if SameText(ActionList.Actions[I].Name, ActionName) then
      begin
        Result := ActionList.Actions[I];
        Exit;
      end;
    end;
  end;
  Result := nil;
{$IFDEF DEBUG}
  CnDebugger.LogMsgError('FindIDEAction can NOT find ' + ActionName);
{$ENDIF}
end;

// ���ݿ�ݼ����� IDE ��Ӧ�� Action ���󣬿����ж��
procedure FindIDEActionByShortCut(AShortCut: TShortCut; Actions: TObjectList);
var
  ActionList: TCustomActionList;
  I: Integer;
begin
  if AShortCut = 0 then
    Exit;

  ActionList := GetIDEActionList;
  if ActionList = nil then
    Exit;

  Actions.Clear;
  for I := 0 to ActionList.ActionCount - 1 do
  begin
    if (ActionList.Actions[I] is TCustomAction) and
      ((ActionList.Actions[I] as TCustomAction).ShortCut = AShortCut) then
      Actions.Add(ActionList.Actions[I]);
  end;
end;

// �жϿ�ݼ��Ƿ������ Action ��ͻ���г�ͻ�򵯿�ѯ�ʣ������޳�ͻ���г�ͻ���û�ͬ�⡢�г�ͻ�û�ֹͣ
function CheckQueryShortCutDuplicated(AShortCut: TShortCut;
  OriginalAction: TCustomAction): TShortCutDuplicated;
const
  SCN_ACTION = 'Action: ';
  SCN_MENU = 'Menu: ';
var
  Actions: TObjectList;
  S: string;
  Idx: Integer;
  WS: TCnWizShortCut;
begin
  Result := sdNoDuplicated;
  if AShortCut = 0 then  // 0 ��ʾ�޿�ݼ������жϣ�ͳͳ���ز��ظ�
    Exit;

  Actions := TObjectList.Create(False);

  try
    FindIDEActionByShortCut(AShortCut, Actions);
    Actions.Remove(OriginalAction); // ɾ������

    if Actions.Count > 0 then // �в�ͬ���Լ���Ŀ�� Action
    begin
      S := TCustomAction(Actions[0]).Caption;
      if S = '' then
        S := TCustomAction(Actions[0]).Name;

      if S <> '' then
        S := SCN_ACTION + S;
    end
    else
    begin
      // Ŀ�� Action �����ڣ���ȥ��ݼ���������鵥���� ShortCuts
      Idx := WizShortCutMgr.IndexOfShortCut(AShortCut);
      if Idx < 0 then    // ��ݼ���������Ҳû��
        Exit;

      WS := WizShortCutMgr.ShortCuts[Idx];
      if WS.Action = OriginalAction then // �е����ڸ� Action Ҳ����
        Exit;

      S := WS.MenuName;
      if S = '' then
        S := WS.Name;

      if S <> '' then
        S := SCN_MENU + S;
    end;
  finally
    Actions.Free;
  end;

  if S = '' then
    S := SCnNoName;

  if QueryDlg(Format(SCnShortCutUsingByActionQuery, [ShortCutToText(AShortCut), S])) then
    Result := sdDuplicatedIgnore
  else
    Result := sdDuplicatedStop;
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
  begin
    Result := False;
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('ExecuteIDEAction can NOT Find ' + ActionName);
{$ENDIF}
  end;
end;

{$IFNDEF NO_DELPHI_OTA}

// �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��
function ReplaceToActualPath(const Path: string; Project: IOTAProject = nil): string;
{$IFDEF COMPILER6_UP}
var
  Vars: TStringList;
  I: Integer;
{$IFDEF DELPHI2011_UP}
  BC: IOTAProjectOptionsConfigurations;
{$ENDIF}
begin
  Result := Path;
  Vars := TStringList.Create;
  try
    GetEnvironmentVars(Vars, True);
    for I := 0 to Vars.Count - 1 do
    begin
{$IFDEF DELPHIXE6_UP}
      // There's a $(Platform) values '' in XE6, will make Platform Empty.
      if Trim(Vars.Values[Vars.Names[I]]) = '' then
        Continue;
{$ENDIF}
      Result := StringReplace(Result, '$(' + Vars.Names[I] + ')',
        Vars.Values[Vars.Names[I]], [rfReplaceAll, rfIgnoreCase]);
    end;

{$IFDEF DELPHI2011_UP}
    BC := CnOtaGetActiveProjectOptionsConfigurations(Project);
    if BC <> nil then
    begin
      if BC.GetActiveConfiguration <> nil then
      begin
        Result := StringReplace(Result, '$(Config)',
          BC.GetActiveConfiguration.GetName, [rfReplaceAll, rfIgnoreCase]);
  {$IFDEF DELPHI2012_UP}
        if BC.GetActiveConfiguration.GetPlatform <> '' then
        begin
          Result := StringReplace(Result, '$(Platform)',
            BC.GetActiveConfiguration.GetPlatform, [rfReplaceAll, rfIgnoreCase]);
        end
        else if Project <> nil then
        begin
          Result := StringReplace(Result, '$(Platform)',
            Project.CurrentPlatform, [rfReplaceAll, rfIgnoreCase]);
        end;
  {$ENDIF}
      end;
    end;
{$ENDIF}

    if Project <> nil then
    begin
      Result := StringReplace(Result, '$(MSBuildProjectName)',
        _CnChangeFileExt(_CnExtractFileName(Project.FileName), ''),
        [rfReplaceAll, rfIgnoreCase]);
    end;
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

{$ENDIF}

// ����һ���Ӳ˵���
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: TCnNativeInt = 0;
  ImgIndex: Integer = -1): TMenuItem;
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
  Result.ImageIndex := ImgIndex;
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
  I, J: Integer;
  P: Pointer;
begin
  // ð������
  if List.Count = 1 then
    Exit;

  for I := List.Count - 2 downto 0 do
  begin
    for J := 0 to I do
    begin
      if TCnMenuWizard(List.Items[J]).MenuOrder >
        TCnMenuWizard(List.Items[J + 1]).MenuOrder then  // ��ͷ�ں��
        begin
          P := List.Items[J];
          List.Items[J] := List.Items[J + 1];
          List.Items[J + 1] := P;
        end;
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
procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
begin
{$IFDEF DEBUG}
  if E = nil then
    CnDebugger.LogMsgWithType('Error: ' + ErrorMsg, cmtError)
  else
  begin
    CnDebugger.LogMsgWithType('Error ' + ErrorMsg + ' : ' + E.Message, cmtError);
    CnDebugger.LogStackFromAddress(ExceptAddr, 'Call Stack');
  end;
{$ENDIF}
end;

// �ڴ��ڿؼ��в���ָ����������
function FindComponentByClass(AWinControl: TWinControl;
  AClass: TClass; const AComponentName: string = ''): TComponent;
var
  I: Integer;
begin
  if AWinControl <> nil then
  begin
    for I := 0 to AWinControl.ComponentCount - 1 do
    begin
      if (AWinControl.Components[I] is AClass) and ((AComponentName = '') or
        (SameText(AComponentName, AWinControl.Components[I].Name))) then
      begin
        Result := AWinControl.Components[I];
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

// �ڴ��ڿؼ��в���ָ�������������
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string): TComponent;
var
  I: Integer;
begin
  for I := 0 to AWinControl.ComponentCount - 1 do
  begin
    if AWinControl.Components[I].ClassNameIs(AClassName) and ((AComponentName =
      '') or (SameText(AComponentName, AWinControl.Components[I].Name))) then
    begin
      Result := AWinControl.Components[I];
      Exit;
    end;
  end;
  Result := nil;
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
      {$IFDEF UNICODE}, tkUString{$ENDIF}]);
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
procedure RemoveListViewSubImages(ListView: TListView);
{$IFDEF BDS}
var
  I, J: Integer;
{$ENDIF}
begin
{$IFDEF BDS}
  for I := 0 to ListView.Items.Count - 1 do
  begin
    for J := 0 to ListView.Items[I].SubItems.Count - 1 do
      ListView.Items[I].SubItemImages[J] := -1;
  end;
{$ENDIF}
end;

// ���� ListItem��ȥ������� SubItemImages
procedure RemoveListViewSubImages(ListItem: TListItem);
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
function GetListViewWidthString(AListView: TListView; DivFactor: Single): string;
var
  I: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    if SingleEqual(DivFactor, 1.0) then
      for I := 0 to AListView.Columns.Count - 1 do
        Lines.Add(IntToStr(AListView.Columns[I].Width))
    else
      for I := 0 to AListView.Columns.Count - 1 do
        Lines.Add(IntToStr(Round(AListView.Columns[I].Width / DivFactor)));

    Result := Lines.CommaText;
  finally
    Lines.Free;
  end;
end;

{* ת���ַ���Ϊ ListView ������ }
procedure SetListViewWidthString(AListView: TListView; const Text: string;
  MulFactor: Single);
var
  I: Integer;
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.CommaText := Text;
    if SingleEqual(MulFactor, 1.0) then
    begin
      for I := 0 to Min(AListView.Columns.Count - 1, Lines.Count - 1) do
        AListView.Columns[I].Width := StrToIntDef(Lines[I], AListView.Columns[I].Width);
    end
    else
    begin
      for I := 0 to AListView.Columns.Count - 1 do
      begin
        if I < Lines.Count then
          AListView.Columns[I].Width := Round(StrToIntDef(Lines[I], AListView.Columns[I].Width) * MulFactor)
        else // �����ã���ԭʼ����Ŵ�
          AListView.Columns[I].Width := Round(AListView.Columns[I].Width * MulFactor);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

// ListView ��ǰѡ�����Ƿ���������
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to AListView.Items.Count - 1 do
  begin
    if AListView.Items[I].Selected and not AListView.Items[I - 1].Selected then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

// ListView ��ǰѡ�����Ƿ���������
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := AListView.Items.Count - 2 downto 0 do
  begin
    if AListView.Items[I].Selected and not AListView.Items[I + 1].Selected then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

// �޸� ListView ��ǰѡ����
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
var
  I: Integer;
begin
  for I := 0 to AListView.Items.Count - 1 do
  begin
    if Mode = smAll then
      AListView.Items[I].Selected := True
    else if Mode = smNothing then
      AListView.Items[I].Selected := False
    else
      AListView.Items[I].Selected := not AListView.Items[I].Selected;
  end;
end;

{$IFNDEF LAZARUS}

// ����ģʽ����
function ScreenHasModalForm: Boolean;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if fsModal in Screen.CustomForms[I].FormState then
    begin
      Result := True;
      Exit;
    end;
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

// ȡ Cursor ��ʶ���б�
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

// ȡ FontCharset ��ʶ���б�
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

// ȡ Color ��ʶ���б�
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

function GetListViewWidthString2(AListView: TListView; DivFactor: Single = 1.0): string;
{$IFDEF IDE_SUPPORT_HDPI}
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
  Lines: TStringList;
  HdpiFactor: Single;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_HDPI}
  {$IFNDEF CNWIZARDS_MINIMUM}
  if CnIsGEDelphi11Dot3 then
  begin
    Lines := TStringList.Create;
    HdpiFactor := AListView.CurrentPPI / Windows.USER_DEFAULT_SCREEN_DPI;

    try
      if SingleEqual(DivFactor, 1.0) then
        for I := 0 to AListView.Columns.Count - 1 do
          Lines.Add(IntToStr(Round(AListView.Columns[I].Width / HdpiFactor)))
      else
        for I := 0 to AListView.Columns.Count - 1 do
          Lines.Add(IntToStr(Round(AListView.Columns[I].Width / (HdpiFactor * DivFactor))));

      Result := Lines.CommaText;
    finally
      Lines.Free;
    end;
  end
  else
    Result := GetListViewWidthString(AListView, DivFactor);
  {$ELSE}
    Result := GetListViewWidthString(AListView, DivFactor);
  {$ENDIF}
{$ELSE}
  Result := GetListViewWidthString(AListView, DivFactor);
{$ENDIF}
end;

{$ENDIF}

//==============================================================================
// �ļ����жϴ����� (���� GExperts Src 1.12)
//==============================================================================

// ��ǰ�༭���ļ��� Delphi Դ�ļ�
function CurrentIsDelphiSource: Boolean;
begin
  Result := WizOptions.IsDelphiSource(CnOtaGetCurrentSourceFile);
end;

// ��ǰ�༭���ļ��� C/C++ Դ�ļ�
function CurrentIsCSource: Boolean;
begin
  Result := WizOptions.IsCSource(CnOtaGetCurrentSourceFile);
end;

// ��ǰ�༭���ļ��� Delphi �� C/C++ Դ�ļ�
function CurrentIsSource: Boolean;
begin
{$IFDEF BDS}
  Result := (CurrentIsDelphiSource or CurrentIsCSource) and
    (CnOtaGetEditPosition <> nil);
{$ELSE}
  Result := CurrentIsDelphiSource or CurrentIsCSource;
{$ENDIF}
end;

// ��ǰ�༭��Դ�ļ����Ǵ��壩�� Delphi Դ�ļ�
function CurrentSourceIsDelphi: Boolean;
begin
  Result := WizOptions.IsDelphiSource(CnOtaGetCurrentSourceFileName);
end;

// ��ǰ�༭��Դ�ļ����Ǵ��壩�� C/C++ Դ�ļ�
function CurrentSourceIsC: Boolean;
begin
  Result := WizOptions.IsCSource(CnOtaGetCurrentSourceFileName);
end;

// ��ǰ�༭��Դ�ļ����Ǵ��壩�� Delphi �� C/C++ Դ�ļ�
function CurrentSourceIsDelphiOrCSource: Boolean;
begin
  Result := CurrentSourceIsDelphi or CurrentSourceIsC;
end;

// ��ǰ�༭���ļ��Ǵ����ļ�
function CurrentIsForm: Boolean;
begin
  Result := IsForm(CnOtaGetCurrentSourceFile);
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
  Result := ((FileExt = '.PAS') or (FileExt = '.DPR')
    {$IFDEF LAZARUS} or (FileExt = '.LPR'){$ENDIF});
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

function IsLpr(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.LPR');
end;

function IsProject(const FileName: string): Boolean;
begin
  Result := IsDpr(FileName) or IsBpr(FileName) {$IFDEF LAZARUS} or IsLpr(FileName) {$ENDIF};
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

function IsLpk(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.LPK');
end;

function IsPackage(const FileName: string): Boolean;
begin
  Result := IsDpk(FileName) or IsBpk(FileName) {$IFDEF LAZARUS} or IsLPK(FileName) {$ENDIF};
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

function IsPp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := (FileExt = '.PP');
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
  Result := (FileExt = '.DFM') or (FileExt = '.XFM')
    {$IFDEF LAZARUS} or (FileExt = '.LFM') {$ENDIF};
{$IFDEF SUPPORT_FMX}
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

function IsLua(const FileName: string): Boolean;
begin
  Result := IsSpecifiedExt(FileName, '.LUA');
end;

function IsSpecifiedExt(const FileName: string; const Ext: string): Boolean;
var
  FileExt: string;
begin
  FileExt := ExtractUpperFileExt(FileName);
  Result := FileExt = UpperCase(Ext);
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
function FindControlByClassName(AParent: TWinControl; const AClassName: string;
  const AComponentName: string): TControl;
var
  I: Integer;
begin
  if AParent <> nil then
  begin
    for I := AParent.ControlCount - 1 downto 0 do // ���������ҵ��������
    begin
      if AParent.Controls[I].ClassNameIs(AClassName) and
        ((AComponentName = '') or (AParent.Controls[I].Name = AComponentName)) then
      begin
        Result := AParent.Controls[I];
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

//==============================================================================
// OTA �ӿڲ�����غ���
// ���²��ִ����޸��� GxExperts Src 1.11������������ Lazarus ��֧��
//==============================================================================

// ��ѯ����ķ���ӿڲ�����һ��ָ���ӿ�ʵ�������ʧ�ܣ����ؼ�
function QuerySvcs(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean;
begin
  Result := (Instance <> nil) and Supports(Instance, Intf, Inst);
{$IFDEF DEBUG}
  if not Result then
    CnDebugger.LogMsgWithType('Query Services Interface Fail: ' + GUIDToString(Intf), cmtError);
{$ENDIF}
end;

// ȡ��ǰѡ����ı�
function CnOtaGetCurrentSelection: string;
{$IFNDEF NO_DELPHI_OTA}
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
{$ENDIF}
begin
  Result := '';
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor <> nil then
    Result := SourceEditorManagerIntf.ActiveEditor.Selection;
{$ELSE}
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if Assigned(EditBlock) then
    Result := EditBlock.Text;

{$IFDEF IDE_STRING_ANSI_UTF8}
  Result := CnUtf8ToAnsi2(Result);
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

// ȡ��ǰ��ǰ�˵� IOTAEditView �ӿڻ� Lazarus �Ļ�༭��
function CnOtaGetTopMostEditView: TCnEditViewSourceInterface;
{$IFNDEF NO_DELPHI_OTA}
var
  iEditBuffer: IOTAEditBuffer;
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := nil;
{$ELSE}
{$IFDEF LAZARUS}
  Result := SourceEditorManagerIntf.ActiveEditor;
{$ELSE}
  iEditBuffer := CnOtaGetEditBuffer;
  if iEditBuffer <> nil then
  begin
    Result := iEditBuffer.GetTopView;
    Exit;
  end;
  Result := nil;
{$ENDIF}
{$ENDIF}
end;

{$IFNDEF CNWIZARDS_MINIMUM}

function CnOtaDeSelection(CursorStopAtEnd: Boolean): Boolean;
{$IFNDEF NO_DELPHI_OTA}
var
  EditView: IOTAEditView;
  R, C: Integer;
{$ENDIF}
begin
  Result := False;
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor <> nil then
  begin
    if SourceEditorManagerIntf.ActiveEditor.SelStart <> SourceEditorManagerIntf.ActiveEditor.SelEnd then
    begin;
      if CursorStopAtEnd then
        SourceEditorManagerIntf.ActiveEditor.SelStart := SourceEditorManagerIntf.ActiveEditor.SelEnd
      else
        SourceEditorManagerIntf.ActiveEditor.SelEnd := SourceEditorManagerIntf.ActiveEditor.SelStart;
    end;
  end;
{$ELSE}
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  if EditView.Block = nil then
    Exit;

  if CursorStopAtEnd then
  begin
    R := EditView.Block.EndingRow;
    C := EditView.Block.EndingColumn;
  end
  else
  begin
    R := EditView.Block.StartingRow;
    C := EditView.Block.StartingColumn;
  end;

  EditView.Block.Reset;
  CnOtaGotoEditPosAndRepaint(EditView, R, C);
  Result := True;
{$ENDIF}
{$ENDIF}
end;

{$ENDIF}

// ȡ��ǰ����
function CnOtaGetCurrentProject: TCnIDEProjectInterface;
{$IFNDEF NO_DELPHI_OTA}
var
  IProjectGroup: IOTAProjectGroup;
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := nil;
{$ELSE}
  {$IFDEF LAZARUS}
  Result := LazarusIDE.ActiveProject;
  {$ELSE}
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
  {$ENDIF}
{$ENDIF}
end;

// ȡ��ǰ�������ƣ�����չ��
function CnOtaGetCurrentProjectName: string;
var
  IProject: TCnIDEProjectInterface;
begin
  Result := '';
{$IFNDEF STAND_ALONE}
  IProject := CnOtaGetCurrentProject;
  if Assigned(IProject) then
  begin
{$IFDEF LAZARUS}
    Result := _CnExtractFileName(IProject.MainFile.FileName);
{$ELSE}
    Result := _CnExtractFileName(IProject.FileName);
{$ENDIF}
    Result := _CnChangeFileExt(Result, '');
  end;
{$ENDIF}
end;

// ȡ��ǰ�����ļ����ƣ���չ�������� dpr/bdsproj/dproj
function CnOtaGetCurrentProjectFileName: string;
var
  CurrentProject: TCnIDEProjectInterface;
begin
{$IFNDEF STAND_ALONE}
  CurrentProject := CnOtaGetCurrentProject;
  if Assigned(CurrentProject) then
  begin
{$IFDEF LAZARUS}
    Result := CurrentProject.MainFile.FileName;
{$ELSE}
    Result := CurrentProject.FileName;
{$ENDIF}
  end
  else
    Result := '';
{$ENDIF}
end;

// ȡ��ǰ�����ļ�������չ
function CnOtaGetCurrentProjectFileNameEx: string;
begin
  // �޸��Է��Ϸ���ȫ·���Ĺ���
  Result := _CnChangeFileExt((CnOtaGetCurrentProjectFileName), '');
{$IFNDEF NO_DELPHI_OTA}
  if Result <> '' then
    Exit;

  Result := _CnChangeFileExt((CnOtaGetProject.FileName), '');
  if Result <> '' then
    Exit;

  Result := Trim(Application.MainForm.Caption);
  Delete(Result, 1, AnsiPos('-', Result) + 1);
{$ENDIF}
end;

{$IFNDEF LAZARUS}
{$IFNDEF NO_DELPHI_OTA}

// ȡ IOTAEditBuffer �ӿ�
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

// ȡ IOTAEditPosition �ӿ�
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

// �����ļ������ر༭���д򿪵ĵ�һ�� EditView��δ��ʱ�� ForceOpen Ϊ True ���Դ򿪣����򷵻� nil
function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string;
  ForceOpen: Boolean): IOTAEditView;
var
  Editor: IOTAEditor;
  SrcEditor: IOTASourceEditor;
begin
  Result := nil;
  Editor := CnOtaGetEditor(FileName);
  if (Editor = nil) and not ForceOpen then
    Exit;

  if not CnOtaOpenFile(FileName) then
    Exit;

  if not Supports(Editor, IOTASourceEditor, SrcEditor) then
    Exit;

  if SrcEditor.EditViewCount = 0 then
    Exit;

  Result := SrcEditor.EditViews[0];
end;

// ȡָ���༭����ǰ�˵� IOTAEditView �ӿ�
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

// ȡָ�� IOTAEditView �Ƿ�ʹ���﷨����
function CnOtaEditViewSupportsSyntaxHighlight(EditView: IOTAEditView): Boolean;
var
  Buffer: IOTAEditBuffer;
  Options: IOTABufferOptions;
begin
  Result := False;
  if EditView = nil then
    EditView := CnOtaGetTopMostEditView;

  if EditView <> nil then
  begin
    Buffer := EditView.GetBuffer;
    if Buffer <> nil then
    begin
      Options := Buffer.GetBufferOptions;
      if Options <> nil then
        Result := Options.GetSyntaxHighlight;
    end;
  end;
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
  I: Integer;
  Editor: IOTAEditor;
  FormEditor: IOTAFormEditor;
begin
  if Assigned(Module) then
  begin
    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      Editor := CnOtaGetFileEditorForModule(Module, I);
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

// ȡ�ô���༭���������ؼ��� DataModule ��������ע�� DataModule ������һ���Ƕ��㴰��
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
var
  Root: TComponent;
begin
  if FormEditor = nil then
    FormEditor := CnOtaGetCurrentFormEditor;

  { ֧��Ϊ Root �� TWinControl ����ƶ���ȡ�� Container }
  Result := nil;
  Root := CnOtaGetRootComponentFromEditor(FormEditor);
  if Root is TWinControl then
  begin
    Result := Root as TWinControl;
    while Assigned(Result) and Assigned(Result.Parent) do
      Result := Result.Parent;
  end
  else if (Root is TDataModule) and (Root.Owner <> nil) and (Root.Owner is TWinControl) then
  begin
    // DataModule ʵ���� Owner ����������� TDataModuleDesigner/TDataModuleForm
    Result := TWinControl(Root.Owner);
  end;
end;

// ȡ�õ�ǰ����༭���������ؼ��� DataModule ��������ע�� DataModule ������һ���Ƕ��㴰��
function CnOtaGetCurrentDesignContainer: TWinControl;
begin
  if CurrentIsForm then
    Result := CnOtaGetDesignContainerFromEditor(CnOtaGetCurrentFormEditor)
  else
    Result := nil;
end;

// ȡ�õ�ǰ����༭������ѡ������
function CnOtaGetSelectedComponentFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  I: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for I := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(I);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
        List.Add(Component);
    end;
  end;

  Result := List.Count > 0;
end;

// ȡ�õ�ǰ����༭������ѡ��Ŀؼ�
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  I: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for I := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(I);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
      begin
        if (Component is TControl) and Assigned(TControl(Component).Parent) then
          List.Add(Component);
{$IFDEF SUPPORT_FMX}
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

// ȡ�õ�ǰ����༭������ѡ�������� IComponenet �ӿ�
function CnOtaGetSelectedComponentFromCurrentForm(List: TInterfaceList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  I: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for I := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(I);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
          List.Add(IComponent);
    end;
  end;

  Result := List.Count > 0;
end;

// ȡ�õ�ǰ����༭������ѡ��Ŀؼ��� IComponenet �ӿ�
function CnOtaGetSelectedControlFromCurrentForm(List: TInterfaceList): Boolean;
var
  FormEditor: IOTAFormEditor;
  IComponent: IOTAComponent;
  Component: TComponent;
  I: Integer;
begin
  Result := False;
  if List = nil then
    Exit;
  List.Clear;

  FormEditor := CnOtaGetFormEditorFromModule(CnOtaGetCurrentModule);
  if not Assigned(FormEditor) then Exit;

  for I := 0 to FormEditor.GetSelCount - 1 do
  begin
    IComponent := FormEditor.GetSelComponent(I);
    if Assigned(IComponent) and Assigned(IComponent.GetComponentHandle) and
      (TObject(IComponent.GetComponentHandle) is TComponent) then
    begin
      Component := TObject(IComponent.GetComponentHandle) as TComponent;
      if Assigned(Component) then
      begin
        if (Component is TControl) and Assigned(TControl(Component).Parent) then
          List.Add(IComponent);
{$IFDEF SUPPORT_FMX}
        if CnFmxIsInheritedFromControl(Component) then
        begin
          if Assigned(CnFmxGetControlParent(Component)) then
            List.Add(IComponent);
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
{$IFDEF COMPILER6_UP}
var
  EditActions: IOTAEditActions;
{$ENDIF}
begin
  try
  {$IFDEF COMPILER6_UP}
    if (ComponentDesigner.ActiveRoot <> nil)
      and Assigned(ComponentDesigner.ActiveRoot.GetFormEditor) then
      ComponentDesigner.ActiveRoot.GetFormEditor.Show
    else
    begin
      if CurrentIsSource then
      begin
        // BDS �� ComponentDesigner.ActiveRoot Ϊ nil��ֻ�ܲ��˺�����ֹ�ִ�� IOTAEditActions.ToggleFormUnit
        EditActions := CnOtaGetEditActionsFromModule(nil);
        if EditActions <> nil then
          EditActions.ToggleFormUnit;
      end;
    end;
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
  I, J: Integer;
  Module: IOTAModule;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    for I := 0 to ModuleServices.ModuleCount - 1 do
    begin
      Module := ModuleServices.Modules[I];
      for J := 0 to Module.GetModuleFileCount - 1 do
      begin
        if Module.GetModuleFileEditor(J) <> nil then
        begin
          if SameFileName(FileName, Module.GetModuleFileEditor(J).FileName) then
          begin
            Result := Module.GetModuleFileEditor(J);
            Exit;
          end;
        end;
      end;
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

// ���ش���������ĸ��Ҳ���� Grid �ĺ�������������
function CnOtaGetFormDesignerGridOffset: TPoint;
var
  Svcs: IOTAServices;
begin
  Result.x := 0;
  Result.y := 0;
  try
    QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
    if Assigned(Svcs) then
    begin
      Result.x := Svcs.GetEnvironmentOptions.GetOptionValue('GridSizeX');
      Result.y := Svcs.GetEnvironmentOptions.GetOptionValue('GridSizeY');
    end;
  except
    ;
  end;
end;

// �� OTA �ķ�ʽȡ��ǰ�� EditWindow
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

// �� OTA �ķ�ʽȡ��ǰ�� EditControl �ؼ�
function CnOtaGetCurrentEditControl: TWinControl;
var
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
{$ELSE}
  EditWindow: TCustomForm;
  Comp: TComponent;
{$ENDIF}
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    Result := CES.GetTopEditor
  else
    Result := nil;
{$ELSE}
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
{$ENDIF}
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
  I: Integer;
{$ENDIF}
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
{$IFDEF BDS}
  Result := IModuleServices.MainProjectGroup;
{$ELSE}
  if IModuleServices <> nil then
  begin
    for I := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[I];
      if Supports(IModule, IOTAProjectGroup, Result) then
        Exit;
    end;
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
  I: Integer;
begin
  Result := '';
  IModuleServices := BorlandIDEServices as IOTAModuleServices;
  if IModuleServices = nil then Exit;

  IProjectGroup := nil;
  for I := 0 to IModuleServices.ModuleCount - 1 do
  begin
    IModule := IModuleServices.Modules[I];
    if IModule.QueryInterface(IOTAProjectGroup, IProjectGroup) = S_OK then
      Break;
  end;
  // Delphi 5 does not return the file path when querying IOTAProjectGroup directly
  if IProjectGroup <> nil then
    Result := IModule.FileName;
end;

// ȡ���̵�Դ���ļ� dpr/dpk
function CnOtaGetProjectSourceFileName(Project: IOTAProject): string;
{$IFNDEF PROJECT_FILENAME_DPR}
var
  I: Integer;
{$ENDIF}
begin
  Result := '';
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;

{$IFDEF PROJECT_FILENAME_DPR}
  // D567 �� Project �� FileName ���� dpr/dpk
  if IsDpr(Project.FileName) or IsDpk(Project.FileName) then
    Result := Project.FileName;
{$ELSE}
  // ���� bdsproj/dproj���� dpr/dpk
  for I := 0 to Project.GetModuleFileCount - 1 do
  begin
    if IsDpr(Project.GetModuleFileEditor(I).FileName) or
      IsDpk(Project.GetModuleFileEditor(I).FileName) then
    begin
      Result := Project.GetModuleFileEditor(I).FileName;
      Exit;
    end;
  end;
{$ENDIF}
end;

// ȡ������Դ
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
var
  I: Integer;
  IEditor: IOTAEditor;
begin
  for I:= 0 to Project.GetModuleFileCount - 1 do
  begin
    IEditor := Project.GetModuleFileEditor(I);
    if Supports(IEditor, IOTAProjectResource, Result) then
      Exit;
  end;
  Result := nil;
end;

// ȡ���̰汾���ַ���
function CnOtaGetProjectVersion(Project: IOTAProject = nil): string;
var
  Options: IOTAProjectOptions;
begin
  Result := '';
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then
    Exit;

  try
{$IFDEF VERSIONINFO_PER_CONFIGURATION}
    if Project = nil then
      Project := CnOtaGetCurrentProject;

    Result := Format('%d.%d.%d.%d',
      [StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_MajorVer')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_MinorVer')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_Release')), 0),
      StrToIntDef(VarToStr(CnOtaGetProjectCurrentBuildConfigurationValue(Project, 'VerInfo_Build')), 0)]);
{$ELSE}
    Result := Format('%d.%d.%d.%d',
      [StrToIntDef(VarToStr(Options.GetOptionValue('MajorVersion')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('MinorVersion')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('Release')), 0),
      StrToIntDef(VarToStr(Options.GetOptionValue('Build')), 0)]);
{$ENDIF}
  except
    ;
  end;
end;

//�趨��Ŀ����ֵ
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
begin
  Assert(Options <> nil, ' Options can not be null');
  Options.Values[AOption] := AValue;
end;

// �����Ŀ�ĵ�ǰ Platform ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectPlatform(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORT_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.CurrentPlatform;
{$ENDIF}
end;

// �����Ŀ�ĵ�ǰ FrameworkType ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
begin
  Result := '';
{$IFDEF SUPPORT_CROSS_PLATFORM}
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;
  Result := Project.FrameworkType;
{$ENDIF}
end;

// ��õ�ǰ��Ŀ�ĵ�ǰ BuildConfiguration �е�����ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���
function CnOtaGetProjectCurrentBuildConfigurationValue(Project:IOTAProject;
  const APropName: string): string;
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
{$IFDEF SUPPORT_CROSS_PLATFORM}
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
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
{$IFDEF SUPPORT_CROSS_PLATFORM}
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

// ���õ�ǰ��Ŀ�ĵ�ǰ BuildConfiguration �е�����ֵ
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project:IOTAProject;const APropName,
  AValue: string);
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
{$IFDEF SUPPORT_CROSS_PLATFORM}
  PS: string;
  PlatformConfig: IOTABuildConfiguration;
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
{$IFDEF SUPPORT_CROSS_PLATFORM}
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

{$IFDEF SUPPORT_CROSS_PLATFORM}
// ��ȡ BuildConfiguration �� Platforms �� TStrings �У��Ա���Ͱ汾��ű���֧�ַ��͵�����}
procedure CnOtaGetPlatformsFromBuildConfiguration(BuildConfig: IOTABuildConfiguration;
  Platforms: TStrings);
var
  S: string;
begin
  if (BuildConfig = nil) or (Platforms = nil) then
    Exit;

  Platforms.Clear;
  for S in BuildConfig.Platforms do
    Platforms.Add(S);
end;
{$ENDIF}

// ȡ�� IDE ���ñ������б�
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True);
var
  Names: TOTAOptionNameArray;
  I: Integer;
begin
  List.Clear;
  Names := nil;
  if not Assigned(Options) then Exit;

  Names := Options.GetOptionNames;
  try
    for I := Low(Names) to High(Names) do
    begin
      if IncludeType then
        List.Add(Names[I].Name + ': ' + GetEnumName(TypeInfo(TTypeKind),
          Ord(Names[I].Kind)))
      else
        List.Add(Names[I].Name);
    end;
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
  I: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
  begin
    for I := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[I];
      if Supports(IModule, IOTAProject, Result) then
        Exit;
    end;
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

// ��ȡָ��������������Դ���ļ������� Sources���粻ָ���������õ�ǰ���̣������Ƿ��ȡ�ɹ�
function CnOtaGetProjectSourceFiles(Sources: TStrings;
  IncludeDpr: Boolean; Project: IOTAProject): Boolean;
var
  I: Integer;
begin
  Result := False;
  Sources.Clear;

  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;

  if IncludeDpr and IsSourceModule(Project.FileName) then
    Sources.Add(Project.FileName);
{$IFDEF BDS}
  if IncludeDpr and not IsDpr(Project.FileName) then
    Sources.Add(_CnChangeFileExt(Project.FileName, '.dpr'));
{$ENDIF}

  for I := 0 to Project.GetModuleCount - 1 do
  begin
    if IsSourceModule(Project.GetModule(I).FileName) then
      Sources.Add(Project.GetModule(I).FileName);
  end;
  Result := Sources.Count > 0;
end;

// ��ȡ��ǰ�����������й����е�Դ���ļ������� Sources�������Ƿ��ȡ�ɹ�
function CnOtaGetProjectGroupSourceFiles(Sources: TStrings;
  IncludeDpr: Boolean): Boolean;
var
  B: Boolean;
  I: Integer;
  G: IOTAProjectGroup;
  P: IOTAProject;
  SL: TStringList;
begin
  Result := False;
  G := CnOtaGetProjectGroup;
  if G <> nil then
  begin
    Sources.Clear;
    SL := TStringList.Create;
    try
      for I := 0 to G.ProjectCount - 1 do
      begin
        P := G.Projects[I];
        B := CnOtaGetProjectSourceFiles(SL, IncludeDpr, P);
        if B then
        begin
          Sources.AddStrings(SL);
          Result := True;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

// �����Ŀ�Ķ������ļ����Ŀ¼
function CnOtaGetProjectOutputDirectory(Project: IOTAProject): string;
var
  Options: IOTAProjectOptions;
  ProjectDir: string;
{$IFNDEF DELPHIXE_UP}
  Dir: Variant;
  OutputDir: string;
{$ENDIF}
begin
  Result := '';
  if Project = nil then
    Project := CnOtaGetCurrentProject;
  if Project = nil then
    Exit;

  ProjectDir := _CnExtractFileDir(Project.FileName);
  Options := Project.ProjectOptions;

{$IFDEF DELPHIXE_UP}  // XE ����ֱ���� TargetName��Ҫ��֤�Ƿ�͵�ǰ Configuration ��Ŀ¼һ��
  if Options <> nil then
    Result := _CnExtractFilePath(Options.TargetName)
  else
    Result := ProjectDir;
{$ELSE}
  if Options <> nil then
  begin
    Dir := Options.GetOptionValue('OutputDir');
    OutputDir := VarToStr(Dir);

    if OutputDir <> '' then // $(Config)/$(Platform) ����ʽ����Ҫ�滻
      Result := LinkPath(ProjectDir, ReplaceToActualPath(OutputDir));
  end;

  if Result = '' then
    Result := ProjectDir;
{$ENDIF}
end;

// �����Ŀ�Ķ������ļ��������·��
function CnOtaGetProjectOutputTarget(Project: IOTAProject): string;
var
  Dir, ProjectFileName: string;
{$IFNDEF DELPHIXE_UP}
  OutExt, IntermediaDir: string;
  Val: Variant;
{$ENDIF}
begin
  Result := '';
  if Project = nil then
    Exit;

  ProjectFileName := Project.GetFileName;
  if ProjectFileName = '' then
    Exit;

  Dir := CnOtaGetProjectOutputDirectory(Project);
  if Dir = '' then
    Exit;

{$IFDEF DELPHIXE_UP}
  if CnOtaGetActiveProjectOptions <> nil then
    Result := CnOtaGetActiveProjectOptions.TargetName;
{$ELSE}
  { TODO : �Զ���������չ���ݲ�֧�� }
  try
    if CnOtaGetActiveProjectOption('GenPackage', Val) and Val then
      OutExt := '.bpl';
  except
    ;
  end;

  try
    if (OutExt = '') and CnOtaGetActiveProjectOption('GenStaticLibrary', Val) and Val then
      OutExt := '.lib';
  except
    ;
  end;

  try
    if (OutExt = '') and CnOtaGetActiveProjectOption('GenDll', Val) and Val then
      OutExt := '.dll';
  except
    ;
  end;

  if OutExt = '' then
    OutExt := '.exe';

{$IFDEF IDE_CONF_MANAGER}
  if not IsDelphiRuntime then
  begin
{$IFDEF BDS2009_UP}
    if CnOtaGetActiveProjectOptionsConfigurations <> nil then
    begin
      if CnOtaGetActiveProjectOptionsConfigurations.GetActiveConfiguration <> nil then
      begin
        IntermediaDir := MakePath(CnOtaGetActiveProjectOptionsConfigurations.GetActiveConfiguration.GetName);
      end;
    end;
{$ELSE}
    // TODO: BCB2007 ���� OTA �ӿڵõ� Configuration�������ķ���
    try
      if CnOtaGetActiveProjectOption('UnitOutputDir', Val) then
        IntermediaDir := MakePath(VarToStr(Val));
    except
      ;
    end;
{$ENDIF}
  end;
{$ENDIF}
  Result := MakePath(Dir) + IntermediaDir + _CnChangeFileExt(_CnExtractFileName(ProjectFileName), OutExt);
{$ENDIF}
end;

// ȡ�����й����б�
procedure CnOtaGetProjectList(const List: TInterfaceList);
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProject: IOTAProject;
  I: Integer;
begin
  if not Assigned(List) then
    Exit;

  QuerySvcs(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
  begin
    for I := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[I];
      if Supports(IModule, IOTAProject, IProject) then
        List.Add(IProject);
    end;
  end;
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
  I: Integer;
  Editor: IOTAEditor;
  SourceEditor: IOTASourceEditor;
begin
  Result := '';
  if Assigned(Module) then
  begin
    if not GetSourceEditorFileName then
      Result := Module.FileName
    else
    begin
      for I := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := Module.GetModuleFileEditor(I);
        if Supports(Editor, IOTASourceEditor, SourceEditor) then
        begin
          Result := Editor.FileName;
          Break;
        end;
      end;
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

// ȡ��ǰ������ָ������ֵ
function CnOtaGetEnvironmentOptionValue(const OptionName: string): Variant;
var
  Svcs: IOTAServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Result := Svcs.GetEnvironmentOptions.GetOptionValue(OptionName)
  else
    Result := Null;
end;

// ���õ�ǰ������ָ������ֵ
procedure CnOtaSetEnvironmentOptionValue(const OptionName: string; OptionValue: Variant);
var
  Svcs: IOTAServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAServices, Svcs);
  if Assigned(Svcs) then
    Svcs.GetEnvironmentOptions.SetOptionValue(OptionName, OptionValue);
end;

// ȡ��ǰ�༭������
function CnOtaGetEditOptions: IOTAEditOptions;
var
  Svcs: IOTAEditorServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAEditorServices, Svcs);
  if Assigned(Svcs) then
  begin
  {$IFDEF COMPILER7_UP}
    if Assigned(Svcs.GetTopBuffer) then
      Result := Svcs.GetTopBuffer.EditOptions
    else if Svcs.EditOptionsCount > 0 then
      Result := Svcs.GetEditOptionsIndex(0)
    else
      Result := nil;
  {$ELSE}
    Result := Svcs.GetEditOptions;
  {$ENDIF}
  end
  else
    Result := nil;
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

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
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
  I: Integer;
  IEditor: IOTAEditor;
  ISourceEditor: IOTASourceEditor;
begin
  if not Assigned(Module) then
  begin
    Result := nil;
    Exit;
  end;

  for I := 0 to Module.GetModuleFileCount - 1 do
  begin
    IEditor := CnOtaGetFileEditorForModule(Module, I);

    if Supports(IEditor, IOTASourceEditor, ISourceEditor) then
    begin
      if Assigned(ISourceEditor) then
      begin
        if (FileName = '') or SameFileName(ISourceEditor.FileName, FileName) then
        begin
          Result := ISourceEditor;
          Exit;
        end;
      end;
    end;
  end;
  Result := nil;
end;

// ����ָ��ģ��ָ���ļ����ı༭��
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
var
  I: Integer;
  Editor: IOTAEditor;
begin
  Assert(Assigned(Module));
  for I := 0 to Module.GetModuleFileCount - 1 do
  begin
    Editor := CnOtaGetFileEditorForModule(Module, I);
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
  I: Integer;
  EditView: IOTAEditView;
  SourceEditor: IOTASourceEditor;
begin
  if Module = nil then
    Module := CnOtaGetCurrentModule;

  if Module <> nil then
  begin
    SourceEditor := CnOtaGetSourceEditorFromModule(Module);
    if SourceEditor = nil then
    begin
      Result := nil;
      Exit;
    end;

    for I := 0 to SourceEditor.GetEditViewCount - 1 do
    begin
      EditView := SourceEditor.GetEditView(I);
      if Supports(EditView, IOTAEditActions, Result) then
        Exit;
    end;
  end;
  Result := nil;
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

// ���ı��滻ѡ�е��ı�
function CnOtaReplaceCurrentSelection(const Text: string; NoSelectionInsert:
  Boolean; KeepSelecting: Boolean; LineMode: Boolean): Boolean;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
  EditPos, InsPos: TOTAEditPos;
  StartPos, EndPos: TOTACharPos;
  LinearPos: Integer;
  InsertLen: Integer;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if not Assigned(EditBlock) or not EditBlock.IsValid then
  begin
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, StartPos);
    // ��ѡ����
    if not NoSelectionInsert then
      Exit;

    // ���뵱ǰ�������λ��
    CnOtaInsertTextIntoEditor(Text);
  end
  else
  begin
    if LineMode then
    begin
      // �ѿ����쵽��ͷβ
      if not CnOtaGetBlockOffsetForLineMode(StartPos, EndPos, EditView) then
        Exit;

      CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('CnOtaReplaceCurrentSelection Line Selection %s', [EditBlock.Text]);
{$ENDIF}
    end;

    InsPos.Line := EditBlock.StartingRow;
    InsPos.Col := EditBlock.StartingColumn;

    EditView.ConvertPos(True, InsPos, StartPos); // 1 ��ʼ����� 0 ��ʼ
    EditBlock.Delete;

    // EditBlock.Delete ��ǰ���λ�ò�ȷ��������ֱ�ӵ��� CnOtaInsertTextIntoEditor
    // ���ڵ�ǰ���λ�ô������ı���������ܲ�������λ��ƫ��
    LinearPos := EditView.CharPosToPos(StartPos);
{$IFDEF UNICODE}
    CnOtaInsertTextIntoEditorAtPosW(Text, LinearPos);
{$ELSE}
    CnOtaInsertTextIntoEditorAtPos(Text, LinearPos);
{$ENDIF}
  end;

  EditBlock := nil;
  if KeepSelecting then
  begin
    // StartPos ��ʱ��ûѡ����ʱ�ĵ�ǰ���λ�û���ѡ������ѡ����ͷ
    // InsertLen ��������ƫ�����㣬�� Ansi(D7y����) �� Utf8 (D2007����)��ƫ�ơ�
{$IFDEF IDE_WIDECONTROL}
    InsertLen := Length(CnAnsiToUtf8(AnsiString(Text)));
{$ELSE}
    InsertLen := Length(Text);
{$ENDIF}

    LinearPos := EditView.CharPosToPos(StartPos); // ��ʼλ��תΪ����λ��
    EndPos := EditView.PosToCharPos(LinearPos + InsertLen); // ����λ�üӺ�ת��Ϊ����λ��

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaReplaceCurrentSelection StartPos %d:%d. Linear %d. Insert Length %d. EndPos %d:%d',
//    [StartPos.Line, StartPos.CharIndex, LinearPos, InsertLen, EndPos.Line, EndPos.CharIndex]);
{$ENDIF}

    // ѡ�в�������ݣ��� StartPos �� EndPos ������λ��
    CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
  end;
  Result := True;
end;

// ���ı��滻ѡ�е��ı��������� Utf8 �� Ansi �ַ��������� D2005~2007 ��ʹ��
function CnOtaReplaceCurrentSelectionUtf8(const Utf8Text: AnsiString;
  NoSelectionInsert: Boolean; KeepSelecting: Boolean; LineMode: Boolean): Boolean;
var
  EditView: IOTAEditView;
  EditBlock: IOTAEditBlock;
  EditPos, InsPos: TOTAEditPos;
  StartPos, EndPos: TOTACharPos;
  LinearPos: Integer;
  InsertLen: Integer;
begin
  Result := False;
  EditView := CnOtaGetTopMostEditView;
  if not Assigned(EditView) then
    Exit;

  EditBlock := EditView.Block;
  if not Assigned(EditBlock) or not EditBlock.IsValid then
  begin
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, StartPos);
    // ��ѡ����
    if not NoSelectionInsert then
      Exit;

    // ���뵱ǰ�������λ��
    CnOtaInsertTextIntoEditorUtf8(Utf8Text);
  end
  else
  begin
    if LineMode then
    begin
      // �ѿ����쵽��ͷβ
      if not CnOtaGetBlockOffsetForLineMode(StartPos, EndPos, EditView) then
        Exit;

      CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('CnOtaReplaceCurrentSelection Line Selection %s', [EditBlock.Text]);
{$ENDIF}
    end;

    InsPos.Line := EditBlock.StartingRow;
    InsPos.Col := EditBlock.StartingColumn;

    EditView.ConvertPos(True, InsPos, StartPos); // 1 ��ʼ����� 0 ��ʼ
    EditBlock.Delete;

    // EditBlock.Delete ��ǰ���λ�ò�ȷ��������ֱ�ӵ��� CnOtaInsertTextIntoEditor
    // ���ڵ�ǰ���λ�ô������ı���������ܲ�������λ��ƫ��
    LinearPos := EditView.CharPosToPos(StartPos);
    CnOtaInsertTextIntoEditorAtPosUtf8(Utf8Text, LinearPos);
  end;

  EditBlock := nil;
  if KeepSelecting then
  begin
    // StartPos ��ʱ��ûѡ����ʱ�ĵ�ǰ���λ�û���ѡ������ѡ����ͷ
    // InsertLen ��������ƫ�����㣬�� Utf8 (D2007����) ��ƫ�ơ�
    InsertLen := Length(Utf8Text);
    LinearPos := EditView.CharPosToPos(StartPos); // ��ʼλ��תΪ����λ��
    EndPos := EditView.PosToCharPos(LinearPos + InsertLen); // ����λ�üӺ�ת��Ϊ����λ��

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaReplaceCurrentSelection StartPos %d:%d. Linear %d. Insert Length %d. EndPos %d:%d',
//    [StartPos.Line, StartPos.CharIndex, LinearPos, InsertLen, EndPos.Line, EndPos.CharIndex]);
{$ENDIF}

    // ѡ�в�������ݣ��� StartPos �� EndPos ������λ��
    CnOtaMoveAndSelectBlock(StartPos, EndPos, EditView);
  end;
  Result := True;
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

{$IFNDEF CNWIZARDS_MINIMUM}

// ��ȡ��ǰ������ڵĹ��̻�������������ʵ�����򣬲�������������
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
  Vis: TTokenKind;
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
  Result := string(Parser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex, Vis));
  Parser.Free;
end;

// ȡָ���е�Դ���룬�к��� 1 ��ʼ�����ؽ��Ϊ Ansi/Unicode���� UTF8
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
      {$IFDEF UNICODE}
      Result := ConvertEditorTextToTextW(OutStr);
      {$ELSE}
      Result := string(ConvertEditorTextToText(OutStr));
      {$ENDIF}

    {$IFDEF UNICODE}
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
  {$IFDEF UNICODE}
  Text := TrimRight(ConvertEditorTextToTextW(OutStr));
  {$ELSE}
  Text := TrimRight(string(ConvertEditorTextToText(OutStr)));
  {$ENDIF}
  Result := True;
end;

// ʹ�� NTA ����ȡ��ǰ��Դ���롣�ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
// ���ʹ�� ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1
// ��ֵ�� EditPos.Col ����
// D7 ������ȡ������AnsiString��CharIndex �� CursorPos.Col���༭����״̬���� Col�� - 1��һ�¡�
//   ����ֱ�Ӹ��� CharIndex ���� Text
// BDS �� Unicode ��ȡ������ UTF8 ��ʽ�� AnsiString��CharIndex �� CursorPos.Col��UTF8 ��ʽ�� Col�� - 1���ͱ༭����״̬����ʾ�� Ansi Col �Բ��Ϻ�
//   Ҳ����ֱ�Ӹ��� CharIndex ���� Text����Ҫע��˫�ֽ��ַ���������ֽ�
// Unicode IDE ��ȡ�õ��� UTF16 �ַ�����CharIndex �� CursorPos.Col���༭����״̬���� Col��- 1���ͱ༭����״̬����ʾ��һ��
//   ���Ҫ���� CharIndex ���� Text������Ҫ�� Text ת��Ϊ AnsiString
// AnsiString[CharIndex] �ַ��ǹ������Ǹ��ַ�
{
  �����±��Ϊ׼��
                      ��ȡ�� Text ��ʽ   CharIndex(CursorPos.Col - 1) �༭��״̬������ʵ��״����Ansi��   ConvertPos �õ��� TOTACharPos

  Delphi5/6/7         Ansi               ͬ��һ��                   ͬ���� CursorPos һ��            Ansi

  Delphi 2005~2007    Ansi with UTF8     ͬ���� UTF8 һ��           Ansi���� UTF8 ��һ��               Utf8

  Delphi 2009~        UTF16              Ansi���� UTF16 ��һ��        ͬ�� Ansi���� CursorPos һ��       Ansi�������ң�
                                                                      �� UTF16 ��һ��
}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; ActualPosWhenEmpty: Boolean): Boolean;
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
    // LineText �� D5~D7 ��Ϊ AnsiString��CharIndex Ҳ�� Ansi λ�á�
    // �� D2005~2007 ���ǰ��� UTF8 �ַ��� AnsiString��CursorPos.Col �� Utf8 λ�ã�
    // ���� CharIndex �� D2005~2007 ��Ҳ�� Utf8 ƫ�ơ�
    // �� D2009 ����ֱ���� UnicodeString���� CursorPos.Col �� Unicode IDE ���� Ansi λ�ã�
    // ���ԱȽ���Ҫ�� LineText ת�� Ansi ����ܽ���

    if ActualPosWhenEmpty and (Text = '') then
    begin
      CharIndex := View.CursorPos.Col - 1;
      // ������ʱ���� CharIndex Ϊ 0�������ݲ��������Ƿ�ʹ����ʵ�Ĺ��λ��
    end
    else
    begin
{$IFDEF UNICODE}
      // ת���� Ansi ���������㣬��ֱ��ת AnsiString �Ա���Ӣ��ƽ̨���ַ�
      CharIndex := Min(View.CursorPos.Col - 1,
        CalcAnsiDisplayLengthFromWideString(PWideChar(Text), @IDEWideCharIsWideLength));
{$ELSE}
      CharIndex := Min(View.CursorPos.Col - 1, Length(Text));
{$ENDIF}
    end;

    LineNo := View.CursorPos.Line;
    Result := True;
  end;
end;

{$IFDEF UNICODE}

var
  VirtualEditControlBitmap: TBitmap = nil;

// ʹ�� Canvas �� TextWidth ������׼������ַ����� Ansi �Ӵ�����
function CalcWideStringLengthFromAnsiOffsetOnCanvas(Text: PWideChar;
  AnsiOffset: Integer): Integer;
var
  C: array[0..1] of WideChar;
  Idx, WidthLimit: Integer;
begin
  Result := 0;
  if (Text <> nil) and (AnsiOffset > 0) then
  begin
    Idx := 0;

    // ͬ���༭���������
    if VirtualEditControlBitmap = nil then
    begin
      VirtualEditControlBitmap := TBitmap.Create;
      VirtualEditControlBitmap.Canvas.Font := EditControlWrapper.EditorBaseFont;
    end
    else
    begin
      if (VirtualEditControlBitmap.Canvas.Font.Name <> EditControlWrapper.EditorBaseFont.Name)
        or (VirtualEditControlBitmap.Canvas.Font.Size <> EditControlWrapper.EditorBaseFont.Size) then
        VirtualEditControlBitmap.Canvas.Font := EditControlWrapper.EditorBaseFont;
    end;

    WidthLimit := VirtualEditControlBitmap.Canvas.TextWidth('a');
    WidthLimit := WidthLimit + (WidthLimit shr 1);
    C[1] := #0;

    while (Text^ <> #0) and (Idx < AnsiOffset) do
    begin
      C[0] := Text^;
      if (Ord(C[0]) > $FF) and (VirtualEditControlBitmap.Canvas.TextWidth(C) > WidthLimit) then
        Inc(Idx, SizeOf(WideChar))
      else
        Inc(Idx, SizeOf(AnsiChar));

      Inc(Text);
      Inc(Result);
    end;
  end;
end;

//  ʹ�� NTA ����ȡ��ǰ��Դ����Ĵ� Unicode �汾���ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
//  �������� ConvertPos ת�� EditPos��ֻ�ܽ� CharIndex ת�� Ansi �� + 1
//  ��ֵ�� EditPos.Col��Utf16CharIndex �ǵ�ǰ����� Text �е� Utf16 ��ʵλ�ã�0 ��ʼ��
function CnNtaGetCurrLineTextW(var Text: string; var LineNo: Integer;
  var Utf16CharIndex: Integer; PreciseMode: Boolean): Boolean;
var
  EditControl: TControl;
  View: IOTAEditView;
  AnsiCharIndex: Integer;
begin
  Result := False;
  EditControl := GetCurrentEditControl;
  View := CnOtaGetTopMostEditView;
  if (EditControl <> nil) and (View <> nil) then
  begin
    Text := GetStrProp(EditControl, 'LineText');

    // CursorPos �� Unicode IDE �·�ӳ���� Ansi���� UTF8����ʽ���У�
    // ��Ҫ�� string ת�� Ansi ����ܵõ�����Ӧ�� Text �е���ʵλ��
    AnsiCharIndex := View.CursorPos.Col - 1;
    if not PreciseMode then
      Utf16CharIndex := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(Text),
        AnsiCharIndex, False, @IDEWideCharIsWideLength)
    else
      Utf16CharIndex := CalcWideStringLengthFromAnsiOffsetOnCanvas(PWideChar(Text),
        AnsiCharIndex);

    LineNo := View.CursorPos.Line;
    Result := True;
  end;
end;

{$ENDIF}

// ���� SourceEditor ��ǰ����Ϣ
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
var
  LineText: string;
begin
  Result := CnNtaGetCurrLineText(LineText, LineNo, CharIndex);
  if Result then
    LineLen := Length(LineText);
end;

// �ж�һ�ַ����Ƿ��ǺϷ��ı�ʶ����SupportUnicodeIdent Ϊ True ʱֻ�� Unicode �����µ���
function _IsValidIdent(const Ident: string; SupportUnicodeIdent: Boolean): Boolean;
begin
  if SupportUnicodeIdent then
    Result := IsValidIdentW(Ident)
  else
    Result := IsValidIdent(Ident);
end;

// �ж�һ���ַ����Ƿ��ǺϷ��ı�ʶ��
function _IsValidIdentWide(const Ident: WideString; SupportUnicodeIdent: Boolean): Boolean;
begin
  if SupportUnicodeIdent then
    Result := IsValidIdentWide(Ident)
  else
    Result := IsValidIdent(string(Ident));
end;

// ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ��ٶȽϿ�
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean; FirstSet, CharSet: TAnsiCharSet;
  EditView: IOTAEditView; SupportUnicodeIdent: Boolean): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  AnsiText: AnsiString;
  I: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  Utf8Text: AnsiString;
{$ENDIF}

  function _IsValidIdentChar(C: AnsiChar; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
    begin
      if SupportUnicodeIdent then
        Result := IsValidIdentChar(Char(C), First) or (Ord(C) > 127)
      else
        Result := IsValidIdentChar(Char(C), First);
    end
    else
      Result := CharInSet(Char(C), FirstSet + CharSet);
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
    if CheckCursorOutOfLineEnd and CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
      Exit;

    AnsiText := ConvertNtaEditorStringToAnsi(LineText);
{$IFDEF IDE_STRING_ANSI_UTF8}
    // ע�������õ��� CharIndex �� D2005~2007 ���� Utf8 �ģ���Ҫת���� Ansi ��
    // TODO: ֱ�� Utf8 ת Ansi���ݲ����Ǵ���ҳδ���õ��¶��ַ�������
    Utf8Text := Copy(LineText, 1, CharIndex);
    CharIndex := Length(CnUtf8ToAnsi(Utf8Text));
{$ENDIF}

    I := CharIndex;
    CurrIndex := 0;
    // ������ʼ�ַ�
    while (I > 0) and _IsValidIdentChar(AnsiText[I], False) do
    begin
      Dec(I);
      Inc(CurrIndex);
    end;
    Delete(AnsiText, 1, I);

    // ���ҽ����ַ�
    I := 1;
    while (I <= Length(AnsiText)) and _IsValidIdentChar(AnsiText[I], False) do
      Inc(I);
    Delete(AnsiText, I, MaxInt);
    Token := string(AnsiText);
  end;

  if Token <> '' then
  begin
    if CharInSet(Token[1], FirstSet) or _IsValidIdent(Token, SupportUnicodeIdent) then
      Result := True
    else
    begin
      // ����ֲ��ǺϷ���ʶ�������ַ�Ҳ���ԣ���ôɾ�����ַ���һ��
      Delete(Token, 1, 1);
      if Token <> '' then
        if CharInSet(Token[1], FirstSet) or _IsValidIdent(Token, SupportUnicodeIdent) then
          Result := True
    end;
  end;

  if not Result then
    Token := '';
end;

{$IFDEF IDE_STRING_ANSI_UTF8}

// ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ����� Unicode ��ʶ�������� 2005 ~ 2007��
// ����� WideString������ Utf8 ת Ansi �Ķ��ַ����Ρ�
// CurrIndex ���� IndexUsingWide �������� Ansi �� Wide ƫ��
function CnOtaGetCurrPosTokenUtf8(var Token: WideString; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean; FirstSet, CharSet: TAnsiCharSet;
  EditView: IOTAEditView; SupportUnicodeIdent: Boolean; IndexUsingWide: Boolean): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  Utf8Text: AnsiString;
  WideText: WideString;
  I: Integer;

  function _IsValidIdentChar(C: WideChar; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
    begin
      if SupportUnicodeIdent then
        Result := IsValidIdentChar(Char(C), First) or (Ord(C) > 127)
      else
        Result := IsValidIdentChar(Char(C), First);
    end
    else
      Result := CharInSet(Char(C), FirstSet + CharSet);
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
    if CheckCursorOutOfLineEnd and CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
      Exit;

    // CharIndex �� Utf8 λ�ã�LineText ����Ҳ�� Utf8�����ܰ� Utf8 ת Ansi���¶��ַ�
    // �����Ҫ�� LineText ת WideString��CharIndex ��Ӧת WideString �� Index
    Utf8Text := Copy(LineText, 1, CharIndex);
    CharIndex := Length(Utf8Decode(Utf8Text));
    WideText := Utf8Decode(LineText);

    I := CharIndex;
    CurrIndex := 0;

    // ������ʼ�ַ�
    while (I > 0) and _IsValidIdentChar(WideText[I], False) do
    begin
      Dec(I);
      Inc(CurrIndex);
    end;
    Delete(WideText, 1, I);

    // ���ҽ����ַ�
    I := 1;
    while (I <= Length(WideText)) and _IsValidIdentChar(WideText[I], False) do
      Inc(I);
    Delete(WideText, I, MaxInt);
    Token := WideText;

    if not IndexUsingWide then
    begin
      // CurrIndex �� WideString �ģ���Ҫת���� Ansi ��
      WideText := Copy(WideText, 1, CurrIndex);
      CurrIndex := CalcAnsiDisplayLengthFromWideString(PWideChar(WideText));
    end;
  end;

  if Token <> '' then
  begin
    // �жϵõ��� WideString �Ƿ��ǺϷ��ı�ʶ��
    if CharInSet(Char(Token[1]), FirstSet) or _IsValidIdentWide(Token, SupportUnicodeIdent) then
      Result := True;
  end;

  if not Result then
    Token := '';
end;

{$ENDIF}

{$IFDEF UNICODE}

// ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ŵ� Unicode �汾������ Unicode ��ʶ��
function CnOtaGetCurrPosTokenW(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean; FirstSet, CharSet: TCharSet;
  EditView: IOTAEditView; SupportUnicodeIdent: Boolean;
  IndexUsingWide: Boolean; PreciseMode: Boolean): Boolean;
var
  LineNo: Integer;
  CharIndex: Integer;
  LineText: string;
  AnsiText: AnsiString;
  I: Integer;

  function _IsValidIdentChar(C: Char; First: Boolean): Boolean;
  begin
    if (FirstSet = []) and (CharSet = []) then
    begin
      if SupportUnicodeIdent then
        Result := IsValidIdentChar(Char(C), First) or (Ord(C) > 127)
      else
        Result := IsValidIdentChar(Char(C), First);
    end
    else
      Result := CharInSet(Char(C), FirstSet + CharSet);
  end;

  function StrHasUnicodeChar(const S: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Length(S) = 0 then
      Exit;
    for I := 0 to Length(S) - 1 do
    begin
      if Ord(S[I]) > 127 then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

begin
  Token := '';
  CurrIndex := 0;
  Result := False;

  if not Assigned(EditView) then
    EditView := CnOtaGetTopMostEditView;

  if (EditView <> nil) and CnNtaGetCurrLineTextW(LineText, LineNo, CharIndex,
     PreciseMode) and (LineText <> '') then
  begin
    if CheckCursorOutOfLineEnd then
    begin
      if StrHasUnicodeChar(LineText) then
      begin
        // CnOtaIsEditPosOutOfLine ���ж��ڵ�ǰ�������п��ֽ��ַ�ʱ���ܲ�׼
        // ����ֱ���жϣ����߶��� UTF16����ֱ���жϡ�
        if CharIndex > Length(LineText) then
          Exit;
      end
      else
      begin
        if CnOtaIsEditPosOutOfLine(EditView.CursorPos) then
          Exit;
      end;
    end;

    // CharIndex �� Utf16 λ�ã�����ֱ�Ӽ���
    I := CharIndex;
    CurrIndex := 0;
    // ������ʼ�ַ�
    while (I > 0) and _IsValidIdentChar(LineText[I], False) do
    begin
      Dec(I);
      Inc(CurrIndex);
    end;
    Delete(LineText, 1, I);

    // ���ҽ����ַ�
    I := 1;
    while (I <= Length(LineText)) and _IsValidIdentChar(LineText[I], False) do
      Inc(I);
    Delete(LineText, I, MaxInt);
    Token := LineText;

    if not IndexUsingWide then
    begin
      // CurrIndex �� Utf16 �ģ���Ҫת���� Ansi ��
      AnsiText := ConvertNtaEditorStringToAnsi(Copy(Token, 1, CurrIndex), True);
      CurrIndex := Length(AnsiText);
    end;
  end;

  if Token <> '' then
  begin
    if CharInSet(Token[1], FirstSet) or _IsValidIdent(Token, SupportUnicodeIdent) then
      Result := True;
  end;

  if not Result then
    Token := '';
end;

{$ENDIF}

// ��װ�Ļ�ȡ��ǰ����µı�ʶ���Լ������ŵĺ�����BDS �������� Unicode ��ʶ���������� Unicode ת Ansi �Ķ��ַ������⡣
// Token: D567 �·��� AnsiString��2005~2007 �·��� WideString��2009 �����Ϸ��� UnicodeString
// CurrIndex: 0 ��ʼ��D567 �·��ص�ǰ����� Token �ڵ� Ansi ƫ�ƣ�2007 �����Ϸ��� WideChar ƫ��
function CnOtaGeneralGetCurrPosToken(var Token: TCnIdeTokenString; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean; FirstSet, CharSet: TAnsiCharSet;
  EditView: IOTAEditView): Boolean;
begin
{$IFDEF UNICODE}
  {$IFDEF DELPHI110_ALEXANDRIA_UP}
  Result := CnOtaGetCurrPosTokenW(Token, CurrIndex, CheckCursorOutOfLineEnd,
    FirstSet, CharSet, EditView, _SUPPORT_WIDECHAR_IDENTIFIER, True, False); // D110 ���ϸĳɹ̶������
  {$ELSE}
  Result := CnOtaGetCurrPosTokenW(Token, CurrIndex, CheckCursorOutOfLineEnd,
    FirstSet, CharSet, EditView, _SUPPORT_WIDECHAR_IDENTIFIER, True, True); // ʹ�þ�ȷģʽ�������ַ����
{$ENDIF}
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  Result := CnOtaGetCurrPosTokenUtf8(Token, CurrIndex, CheckCursorOutOfLineEnd,
    FirstSet, CharSet, EditView, _SUPPORT_WIDECHAR_IDENTIFIER, True);
  {$ELSE}
  Result := CnOtaGetCurrPosToken(Token, CurrIndex, CheckCursorOutOfLineEnd,
    FirstSet, CharSet, EditView, _SUPPORT_WIDECHAR_IDENTIFIER);
  {$ENDIF}
{$ENDIF}
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
  Token: TCnIdeTokenString; // Ansi/Wide/Wide
  CurrIndex: Integer;       // Ansi/Wide/Wide
  EditPos: IOTAEditPosition;
  MoveToRightCount: Integer;    // �ӹ�괦�����Ҷ������ Col�������Ƶ���
  BkspDelLeftCount, BkspDelRightCount: Integer;  // �ӹ���˸�ɾ����������˸�ɾ�����������ַ���
begin
  Result := False;
  if CnOtaGeneralGetCurrPosToken(Token, CurrIndex, True, FirstSet, CharSet, nil) then
  begin
    EditPos := CnOtaGetEditPosition;
    if not Assigned(EditPos) then
      Exit;

    // MoveRelative: 0  Ansi/Utf8/Utf8
    // BackspaceDelete: Wide/Wide/Wide
{$IFDEF BDS}
    // 2005 ���ϵģ����� 2009���ƶ���궼Ҫ�� UTF8 ƫ������ɾ���ַ���Ҫ�� WideChar ƫ����
    MoveToRightCount := CalcUtf8LengthFromWideString(PWideChar(Copy(Token, CurrIndex + 1, MaxInt)));
{$ELSE}
    // D567 �±�ʶ����˫�ֽ��ַ���ֱ���������
    MoveToRightCount := Length(Token) - CurrIndex;
{$ENDIF}
    BkspDelLeftCount := CurrIndex;
    BkspDelRightCount := Length(Token) - CurrIndex;

    if DelLeft and DelRight then
    begin
      EditPos.MoveRelative(0, MoveToRightCount);
      EditPos.BackspaceDelete(BkspDelLeftCount + BkspDelRightCount);
    end
    else if DelLeft and (CurrIndex > 0) then
      EditPos.BackspaceDelete(BkspDelLeftCount)
    else if DelRight and (CurrIndex < Length(Token) - 1) then
    begin
      EditPos.MoveRelative(0, MoveToRightCount);
      EditPos.BackspaceDelete(BkspDelRightCount);
    end;
    Result := True;
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

// �ж�λ���Ƿ񳬳���β�ˡ��˻����� Unicode �����µ�ǰ�к��п��ַ�ʱ���ܻ᲻׼������
// һ�� Unicode �����£����ں��м������ַ���ʹ�� ConvertPos �ͻ���ܲ������е�ƫ�
// Ҳ��������β�ټӼ��вŻ��ж�Ϊ������β������������򻹲����ף���Ҫ��������
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView): Boolean;
var
  APos: TOTAEditPos;
  CPos: TOTACharPos;
{$IFDEF UNICODE}
  EditControl: TControl;
  S: AnsiString;
  I, Idx, Len: Integer;
  HasWide: Boolean;
{$ENDIF}
begin
  Result := True;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    View.ConvertPos(True, EditPos, CPos);
    View.ConvertPos(False, APos, CPos);
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaIsEditPosOutOfLine EditPos: %d,%d. APos %d,%d.',
//   [EditPos.Line, EditPos.Col, APos.Line, APos.Col]);
{$ENDIF}
    Result := not SameEditPos(EditPos, APos);

{$IFDEF UNICODE}
    // Unicode �����¿�����������һ��
    EditControl := EditControlWrapper.GetEditControl(View);
    if EditControl = nil then
      Exit;

    // ʹ�� EditControlWrapper.GetTextAtLine �Ͽ��ȡ�����֣����� Tab ��չ��
    S := AnsiString(TrimRight(EditControlWrapper.GetTextAtLine(EditControl, EditPos.Line)));
    if S = '' then
      Exit;

    HasWide := False;
    Idx := -1;
    Len := Length(S);

    for I := 1 to Len do
    begin
      if Ord(S[I]) > 127 then
      begin
        HasWide := True;
        Idx := I;
        Break;
      end;
    end;

    if not HasWide then
      Exit;
    if EditPos.Col < Idx + 1 then
      Exit;

    // Unicode �����º���˫�ֽ��ַ�ʱ��������Ҫ�жϵ�λ���ڵ�һ��˫�ֽ��ַ���ʱ
    // ������ƫ��������жϷ�ʽ��
    Result := EditPos.Col > Len + 1; // Col is 0 based.
{$ENDIF}
  end;  
end;

// ʹ�� CnWizDebuggerNotifierServices ��ȡ��ǰԴ�ļ��ڵĶϵ㣬List �з��� TCnBreakpointDescriptor ʵ��
procedure CnOtaGetCurrentBreakpoints(Results: TList);
begin
  if Results <> nil then
    CnWizDebuggerNotifierServices.RetrieveBreakpoints(Results, CnOtaGetCurrentSourceFileName);
end;

// ѡ�е�ǰ����µı�ʶ������������û�б�ʶ���򷵻� False
function CnOtaSelectCurrentToken(FirstSet: TAnsiCharSet = [];
  CharSet: TAnsiCharSet = []): Boolean;
var
  View: IOTAEditView;
  Token: TCnIdeTokenString; // Ansi/Wide/Wide
  CurrIndex: Integer;       // Ansi/Wide/Wide
  EditPos: IOTAEditPosition;
  Block: IOTAEditBlock;
  MoveToRightCount: Integer;    // �ӹ�괦�����Ҷ������ Col�������Ƶ���
begin
  Result := False;
  if CnOtaGeneralGetCurrPosToken(Token, CurrIndex, True, FirstSet, CharSet, nil) then
  begin
    View := CnOtaGetTopMostEditView;
    if View = nil then
      Exit;

    Block := View.Block;
    if Block = nil then
      Exit;

    EditPos := CnOtaGetEditPosition;
    if not Assigned(EditPos) then
      Exit;

{$IFDEF BDS}
    // CurrIndex �� 0 ��ʼ�� Ansi/Wide/Wide�������ƶ����ʱ��Ҫת�� 0 ��ʼ�� Ansi/Utf8/Utf8
    CurrIndex := CalcUtf8LengthFromWideString(PWideChar(Copy(Token, 1, CurrIndex)));
    // MoveToRightCount �����ƶ���굽��ʶ��β���� 0 ��ʼ�� Ansi/Utf8/Utf8
    MoveToRightCount := CalcUtf8LengthFromWideString(PWideChar(Token));
{$ELSE}
    // D567 �±�ʶ����˫�ֽ��ַ���ֱ�Ӽ��� Token ����
    MoveToRightCount := Length(Token);
{$ENDIF}

    // ��ǰ�ƶ� CurrIndex����ʼѡ�в������ƶ� MoveToRightCount���ٽ���ѡ��
    // MoveRelative: 0  Ansi/Utf8/Utf8

    EditPos.MoveRelative(0, -CurrIndex);

    Block.Reset;
    Block.Style := btNonInclusive;
    Block.BeginBlock;

    EditPos.MoveRelative(0, MoveToRightCount);

    Block.EndBlock;
    Result := True;
  end;
end;

{$ENDIF}

// �Ƿ��Ƿ��ϵ�ǰ Delphi �汾�ĺϷ���ʶ��������ӵ㵫�㲻������ǰ��
function IsValidDotIdentifier(const Ident: string): Boolean;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9', '.'];
var
  I: Integer;
begin
  Result := False;
{$IFDEF UNICODE} // Unicode Identifier Supports
  if (Length(Ident) = 0) or not (CharInSet(Ident[1], Alpha) or (Ord(Ident[1]) > 127)) then
    Exit;
  for I := 2 to Length(Ident) do
  begin
    if not (CharInSet(Ident[I], AlphaNumeric) or (Ord(Ident[I]) > 127)) then
      Exit;
  end;
{$ELSE}
  if (Length(Ident) = 0) or not CharInSet(Ident[1], Alpha) then
    Exit;
  for I := 2 to Length(Ident) do
  begin
    if not CharInSet(Ident[I], AlphaNumeric) then
      Exit;
  end;
{$ENDIF}
  Result := True;

  if Result and (Ident[Length(Ident)] = '.') then
    Result := False;
end;

// ѡ��һ�������
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
var
  View: IOTAEditView;
  Ed: IOTASourceEditor;
begin
  Ed := Editor;
  if Ed = nil then
  begin
    View := CnOtaGetTopMostEditView;
    if View = nil then
      Exit;
    Ed := View.GetBuffer;
  end;

  if Ed = nil then
    Exit;

  Ed.BlockVisible := False;
  try
    Ed.BlockType := btNonInclusive;
    Ed.BlockStart := Start;
    Ed.BlockAfter := After;
  finally
    Ed.BlockVisible := True;
  end;
end;

// �� Block �ķ�ʽ���ô����ѡ���������Ƿ�ɹ�
function CnOtaMoveAndSelectBlock(const Start, After: TOTACharPos; View: IOTAEditView): Boolean;
var
  Block: IOTAEditBlock;
  Row, Col: Integer;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  Row := Start.Line;       // 2005~2007 �� Col Ϊ 0 �ᵼ�¹��������������м����Ա���������СΪ 1
  Col := Start.CharIndex;
  if Col <= 0 then
    Col := 1;

  View.Position.Move(Row, Col);
  Block := View.Block;
  if Block = nil then
    Exit;

  Block.Reset;
  Block.Style := btNonInclusive;
  Block.BeginBlock;

  Row := After.Line;
  Col := After.CharIndex;
  if Col <= 0 then
    Col := 1;

  View.Position.Move(Row, Col);
  Block.EndBlock;
  Result := True;
end;

// �� Block Extend �ķ�ʽѡ��һ�У������Ƿ�ɹ�����괦������
function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView): Boolean;
var
  Position: IOTAEditPosition;
  Block: IOTAEditBlock;
  EndRow, EndCol: Integer;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  Position := View.Position;
  Block := View.Block;
  Block.Save;
  try
    Position.Move(LineNum, 1);
    Position.MoveEOL;
    Position.Save;
    try
      Position.MoveBOL;
      EndRow := Position.Row;
      EndCol := Position.Column;
    finally
      Position.Restore;
    end;
  finally
    Block.Restore;
  end;
  Block.Extend(EndRow, EndCol);
  View.Paint;

  Result := True;
end;

// �� Block Extend �ķ�ʽѡ�ж��У����ͣ���� End ������ʶ�ĵط��������Ƿ�ɹ�
function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer;
  View: IOTAEditView = nil): Boolean;
var
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
  EndRow, EndCol: Integer;
begin
  if StartLineNum = EndLineNum then
    Result := CnOtaMoveAndSelectLine(StartLineNum, View)
  else
  begin
    Result := False;
    if View = nil then
      View := CnOtaGetTopMostEditView;
    if View = nil then
      Exit;

    Position := View.Position;
    Block := View.Block;
    Block.Save;
    try
      Position.Move(StartLineNum, 1);
      if StartLineNum > EndLineNum then
        Position.MoveEOL
      else
        Position.MoveBOL;

      Position.Save;
      try
        Position.Move(EndLineNum, 1);
        if StartLineNum > EndLineNum then
          Position.MoveBOL
        else
          Position.MoveEOL;
        EndRow := Position.Row;
        EndCol := Position.Column;
      finally
        Position.Restore;
      end;
    finally
      Block.Restore;
    end;
    Block.Extend(EndRow, EndCol);
    View.Paint;

    Result := True;
  end;
end;

// ֱ������ֹ����Ϊ����ѡ�д���飬����һ��ʼ�������Ƿ�ɹ�
function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
var
  Start, After: TOTACharPos;
  R1, R2, C1, C2, T: Integer;
begin
  R1 := OneBasedStartRow;
  R2 := OneBasedEndRow;
  C1 := OneBasedStartCol;
  C2 := OneBasedEndCol;

  // �����ʼλ�ô��ڽ���λ�ã��򻥻�
  if (R1 > R2) or ((R1 = R2) and (C1 > C2)) then
  begin
    T := R1; R1 := R2; R2 := T;
    T := C1; C1 := C2; C2 := T;
  end;

  Start.Line := R1;
  Start.CharIndex := C1;
  After.Line := R2;
  After.CharIndex := C2;

  Result := CnOtaMoveAndSelectBlock(Start, After, View);
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

// ���ص�ǰѡ��Ŀ���չ����ģʽ�����ʼλ�ã���ʵ����չѡ����
function CnOtaGetBlockOffsetForLineMode(var StartPos: TOTACharPos; var EndPos: TOTACharPos;
  View: IOTAEditView = nil): Boolean;
var
  Block: IOTAEditBlock;
begin
  Result := False;
  if View = nil then
    View := CnOtaGetTopMostEditView;
  if Assigned(View) and View.Block.IsValid then
  begin
    Block := View.Block;
    StartPos.Line := Block.StartingRow;
    StartPos.CharIndex := 1;
    EndPos.Line := Block.EndingRow;
    EndPos.CharIndex := Block.EndingColumn;
    if EndPos.CharIndex > 1 then
    begin
      if EndPos.Line < View.Buffer.GetLinesInBuffer then
      begin
        Inc(EndPos.Line);
        EndPos.CharIndex := 1;
      end
      else
        EndPos.CharIndex := 1024; // �ø�����������β
    end;
    Result := True;
  end;
end;

// �� ActionService ���ر��ļ�
function CnOtaCloseFileByAction(const FileName: string): Boolean;
var
  ActionServices: IOTAActionServices;
begin
  Result := False;
  try
    ActionServices := BorlandIDEServices as IOTAActionServices;
    if ActionServices <> nil then
      Result := ActionServices.CloseFile(FileName);
  except
    ;
  end;
end;

// �� ActionService �������ļ�
function CnOtaSaveFileByAction(const FileName: string): Boolean;
var
  ActionServices: IOTAActionServices;
begin
  Result := False;
  try
    ActionServices := BorlandIDEServices as IOTAActionServices;
    if ActionServices <> nil then
      Result := ActionServices.SaveFile(FileName);
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

{$ENDIF}
{$ENDIF}

// ���ļ�
function CnOtaOpenFile(const FileName: string): Boolean;
{$IFNDEF NO_DELPHI_OTA}
var
  ActionServices: IOTAActionServices;
{$ENDIF}
begin
  Result := False;
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  LazarusIDE.DoOpenEditorFile(FileName, -1, -1, []);
{$ELSE}
  try
    ActionServices := BorlandIDEServices as IOTAActionServices;
    if ActionServices <> nil then
    begin
      try
{$IFNDEF CNWIZARDS_MINIMUM}
        DisableWaitDialogShow;
{$ENDIF}
        // 10.4.2 �´��ļ�ʱ���� IDE �ᱻĪ������������̨
        // ��Ҫͨ�� Hook �� WaitDialogService �ķ�ʽȥ��
        Result := ActionServices.OpenFile(FileName);
      finally
{$IFNDEF CNWIZARDS_MINIMUM}
        EnableWaitDialogShow; // �ָ� WaitDialogService
{$ENDIF}
      end;
    end;
  except
    ;
  end;
{$ENDIF}
{$ENDIF}
end;

// �ж��ļ��Ƿ��
function CnOtaIsFileOpen(const FileName: string): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  Editor: TSourceEditorInterface;
  FullPath, EditorPath: string;
{$ELSE}
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FileEditor: IOTAEditor;
{$ENDIF}
  I: Integer;
{$ENDIF}
begin
  Result := False; // ����ģʽ��ֱ�ӷ���δ��
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  for I := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
  begin
    Editor := SourceEditorManagerIntf.SourceEditors[I];
    EditorPath := Editor.FileName;

    if EditorPath = '' then
      Continue;

    Result := CompareText(FileName, Editor.FileName) = 0;
    if Result then
      Exit;
  end;
{$ELSE}
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then
    Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
  begin
    for I := 0 to Module.GetModuleFileCount-1 do
    begin
      FileEditor := CnOtaGetFileEditorForModule(Module, I);
      Assert(Assigned(FileEditor));

      Result := CompareText(FileName, FileEditor.FileName) = 0;
      if Result then
        Exit;
    end;
  end;
{$ENDIF}
{$ENDIF}
end;

{$IFNDEF LAZARUS}
{$IFNDEF NO_DELPHI_OTA}

// �����ļ�
procedure CnOtaSaveFile(const FileName: string; ForcedSave: Boolean);
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
begin
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then
    Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
    Module.Save(False, ForcedSave);
end;

// �ر��ļ�
procedure CnOtaCloseFile(const FileName: string; ForceClosed: Boolean);
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
begin
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then
    Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
    Module.CloseModule(ForceClosed);
end;

// �жϴ����Ƿ��
function CnOtaIsFormOpen(const FormName: string): Boolean;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
begin
  Result := False;

  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then
    Exit;

  Module := ModuleServices.FindFormModule(FormName);
  if Assigned(Module) then
  begin
    FormEditor := CnOtaGetFormEditorFromModule(Module);
    Result := Assigned(FormEditor);
  end;
end;

// �ж�ģ���Ƿ��ѱ��޸�
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AModule.GetModuleFileCount - 1 do
    if AModule.GetModuleFileEditor(I).Modified then
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
  I: Integer;
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
      for I := 0 to Module.GetModuleFileCount-1 do
      begin
        FileEditor := Module.GetModuleFileEditor(I);
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

{$ENDIF}

//==============================================================================
// Դ���������غ���
//==============================================================================

// ��ͨ�� Nta ������õ��ַ��� AnsiString/AnsiUtf8/Utf16 ����ת��Ϊ AnsiString
function ConvertNtaEditorStringToAnsi(const LineText: string;
  UseAlterChar: Boolean): AnsiString;
begin
{$IFDEF UNICODE}
  // D2009 ������
  if UseAlterChar then // ��Ӣ�� Unicode �����²���ֱ��ת Ansi
    Result := ConvertUtf16ToAlterDisplayAnsi(PWideChar(LineText), 'C')
  else
    Result := AnsiString(LineText);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
     // D2005 ~ 2007 Utf8 to Ansi
     if UseAlterChar then // ��Ӣ�Ļ����� Utf8 ����ֱ��ת Ansi
       Result := ConvertUtf8ToAlterDisplayAnsi(PAnsiChar(LineText), 'C')
     else
       Result := Utf8ToAnsi(LineText);
  {$ELSE}
     // D5��6��7 ��ͬ��ֱ�ӷ���
     Result := AnsiString(LineText);
  {$ENDIF}
{$ENDIF}
end;

{$ENDIF}

// �ַ���תΪԴ���봮
function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean; MaxLen: Integer; AddAtHead: Boolean): string;
var
  Strings: TStrings;
  I, J: Integer;
  S, Line, SingleLine: string;
{$IFDEF UNICODE}
  TmpLine: string;
{$ELSE}
  TmpLine: WideString;
{$ENDIF}
  IsDelphi: Boolean;
begin
  Result := '';
{$IFDEF NO_DELPHI_OTA}
  IsDelphi := True; // �������л� Laz �£�Ĭ������ Pascal ����
{$ELSE}
  IsDelphi := CurrentIsDelphiSource;
{$ENDIF}

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
      S := CRLF
    else
      S := '';
        
    Strings.Text := Str;
    for I := 0 to Strings.Count - 1 do
    begin
      Line := Strings[I];

      if MaxLen <= 1 then
      begin
        for J := Length(Line) downto 1 do
        begin
          if IsDelphi then             // Delphi �� ' ��ת��Ϊ ''
          begin
            if Line[J] = '''' then
              Insert('''', Line, J);
          end
          else begin                   // C++Builder �� " ��ת��Ϊ \"
            if Line[J] = '"' then
              Insert('\', Line, J);
          end;
        end;
      end
      else
      begin
        // �� Line ���������ɶ���ַ�����Ȼ��ֱ�ת����Ȼ����ƴ������
        // ANSI ģʽ��Ҫ���ǿ��ַ��������⣬����ת�� WideString ����
        TmpLine := Line;
        Line := '';
        repeat
          SingleLine := string(Copy(TmpLine, 1, MaxLen));
          Delete(TmpLine, 1, MaxLen);

          for J := Length(SingleLine) downto 1 do
          begin
            if IsDelphi then             // Delphi �� ' ��ת��Ϊ ''
            begin
              if SingleLine[J] = '''' then
                Insert('''', SingleLine, J);
            end
            else
            begin                   // C++Builder �� " ��ת��Ϊ \"
              if SingleLine[J] = '"' then
                Insert('\', SingleLine, J);
            end;
          end;

          if Line = '' then
            Line := SingleLine
          else
            Line := Line + ''' + ''' + SingleLine;
        until Length(TmpLine) = 0;
      end;

      if IsDelphi then // Delphi �ַ����� + �Ų��ܽ��ַ�������һ���� #13#10 ���ַ�����
      begin
        if I = Strings.Count - 1 then  // ���һ�в��ӻ��з�
        begin
          if Line <> '' then
            Result := Format('%s''%s''', [Result, Line])
          else
            Delete(Result, Length(Result) - Length(' + ' + S) + 1,
              Length(' + ' + S));
        end
        else
        begin
          if Trim(ADelphiReturn) <> '' then
          begin
            if AddAtHead then
            begin
              if Wrap or (Line <> '') then
                Result := Format('%s''%s'' + %s%s+ ', [Result, Line, ADelphiReturn, S])
              else
                Result := Result + ADelphiReturn + ' + ' + S;
            end
            else
            begin
              if Wrap or (Line <> '') then
                Result := Format('%s''%s'' + %s + %s', [Result, Line, ADelphiReturn, S])
              else
                Result := Result + ADelphiReturn + ' + ' + S;
            end;
          end
          else
          begin
            if Wrap or (Line <> '') then
              Result := Format('%s''%s'' + %s', [Result, Line, S])
            else
              Result := Result + S;
          end;
        end;
      end
      else // C �ַ������� + �ű��ܽ��ַ�������һ���� \n ���ַ�����
      begin
        if I = Strings.Count - 1 then
          Result := Format('%s"%s"', [Result, Line])
        else
          Result := Format('%s"%s%s" %s', [Result , Line, ACReturn, S]);
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
  I: Integer;
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
    for I := 1 to Strings.Count - 1 do
      if (I = 1) or not IndentOnceOnly then
        Result := Result + Spc(Indent) + Trim(Strings[I]) + #13#10  // ��������
      else
        Result := Result + Strings[I] + #13#10;
    Delete(Result, Length(Result) - 1, 2); // ɾ������Ļ��з�
  finally
    Strings.Free;
  end;
end;

{$IFNDEF LAZARUS}
{$IFDEF COMPILER6_UP}
// ����ת��Utf8��Ansi�ַ����������ڳ��ȶ�����Ҫ��Ansi�ַ����ַ���
function FastUtf8ToAnsi(const Text: AnsiString): AnsiString;
var
  I, L, Len: Cardinal;
  IsMultiBytes: Boolean;
  P: PDWORD;
begin
  if Text <> '' then
  begin
    Len := Length(Text);
    L := Len and $FFFFFFFC;
    P := PDWORD(@Text[1]);
    IsMultiBytes := False;
    for I := 0 to L div 4 do
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
      for I := L + 1 to Len do
      begin
        if Ord(Text[I]) and $80 <> 0 then
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

{$IFDEF UNICODE}

// Unicode ������ת���ַ���Ϊ�༭��ʹ�õ��ַ��������� AnsiString ת��
function ConvertTextToEditorUnicodeText(const Text: string): string;
begin
  Result := Text;
end;

{$ENDIF}

// ת���ַ���Ϊ�༭��ʹ�õ��ַ���
function ConvertTextToEditorText(const Text: AnsiString): AnsiString;
begin
{$IFDEF IDE_WIDECONTROL}
  // ֻ�ʺ��ڷ� Unicode ������ BDS��
  Result := CnAnsiToUtf8(Text);
{$ELSE}
  Result := Text;  // D567 ������ֱ��ʹ�ü��ɣ��� Unicode �����£�ֱ������ string �ƺ����У�����
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

{$IFDEF IDE_WIDECONTROL}

// ת�����ַ���Ϊ�༭��ʹ�õ��ַ�����Utf8����D2005~2007 �汾ʹ��
function ConvertWTextToEditorText(const Text: WideString): AnsiString;
begin
  Result := Utf8Encode(Text);
end;

// ת���༭��ʹ�õ��ַ�����Utf8��Ϊ���ַ�����D2005~2007 �汾ʹ��
function ConvertEditorTextToWText(const Text: AnsiString): WideString;
begin
  Result := UTF8Decode(Text);
end;

{$ENDIF}

{$IFDEF UNICODE}

// ת���ַ���Ϊ�༭��ʹ�õ��ַ�����Utf8����D2009 ���ϰ汾ʹ��
function ConvertTextToEditorTextW(const Text: string): AnsiString;
begin
  Result := Utf8Encode(Text);
end;

// ת���༭��ʹ�õ��ַ�����Utf8��Ϊ Unicode �ַ�����D2009 ���ϰ汾ʹ��
function ConvertEditorTextToTextW(const Text: AnsiString): string;
begin
  Result := UTF8ToUnicodeString(Text);
end;

{$ENDIF}

{$ENDIF}

// ȡ��ǰ�༭��Դ�ļ�  (���� GExperts Src 1.12���иĶ�)
function CnOtaGetCurrentSourceFile: string;
{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
{$IFDEF COMPILER6_UP}
var
  iModule: IOTAModule;
  iEditor: IOTAEditor;
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := 'C:\CnPack\Unit1.pas'; // ��������ģʽ��ģ�ⷵ��һ���̶��ļ���
{$ELSE}
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor <> nil then
    Result := SourceEditorManagerIntf.ActiveEditor.FileName
  else
    Result := '';
{$ELSE}
{$IFDEF COMPILER6_UP}
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
  {$IFDEF BCB}  // BCB �¿��ܴ����޷���õ�ǰ���̵� cpp �ļ������⣬�ش˼��ϴ˹���
  if (Result = '') and (CnOtaGetEditBuffer <> nil) then
    Result := CnOtaGetEditBuffer.FileName;
  {$ENDIF}
{$ELSE}
  // Delphi5/BCB5/K1 ����ȻҪ���þɵķ�ʽ
  Result := ToolServices.GetCurrentFile;
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

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

{$IFNDEF NO_DELPHI_OTA}

// �� EditPosition �в���һ���ı���֧�� D2005 ��ʹ�� utf-8 ��ʽ
procedure CnOtaPositionInsertText(EditPosition: IOTAEditPosition; const Text: string);
begin
{$IFDEF UNICODE}
  EditPosition.InsertText(Text); // InsertText �� Unicode ������ʹ�� Unicode �ַ��������� Utf8 ת��
{$ELSE}
  EditPosition.InsertText(ConvertTextToEditorText(Text));
{$ENDIF}
end;

{$IFNDEF CNWIZARDS_MINIMUM}

// ��һ�༭���е����۵���Ϣ��Infos ��� List ��˳������۵��Ŀ�ʼ�кͽ����У����۵���֧���۵�ʱ���� False
function CnOtaGetLinesElideInfo(Infos: TList; EditControl: TControl): Boolean;
{$IFDEF IDE_EDITOR_ELIDE}
var
  I: Integer;
  Obj: TCnEditorObject;
  Old, B: Boolean;
{$ENDIF}
begin
  Result := False;
  if Infos = nil then
    Exit;

  if EditControl = nil then
    EditControl := CnOtaGetCurrentEditControl;

  Infos.Clear;
  if EditControl = nil then
    Exit;

{$IFDEF IDE_EDITOR_ELIDE}
  Obj := EditControlWrapper.GetEditorObject(EditControl);
  Old := False;

  for I := 1 to Obj.Context.LineCount do
  begin
    B := EditControlWrapper.GetLineIsElided(EditControl, I);
    if B <> Old then
    begin
      Infos.Add(Pointer(I - 1));
      Old := B;
    end;
  end;

  if (Infos.Count mod 2) <> 0 then
    Infos.Add(Pointer(Obj.Context.LineCount));
{$ENDIF}

  Result := Infos.Count > 0;
end;

{$ENDIF}

{$ENDIF}

// ����һ���ı�����ǰ���ڱ༭��Դ�ļ��У����سɹ���־
function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
  iEditView: IOTAEditView;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := True; // ��������ģʽ��ɶ������ֱ�ӷ��سɹ�
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  if not CnOtaMovePosInCurSource(InsertPos, 0, 0) then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P := Editor.CursorTextXY;
    Editor.ReplaceText(P, P, Text);
    Result := True;
  end;
{$ELSE}
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
{$ENDIF}
{$ENDIF}
end;

// ��õ�ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Col := 1;
  Row := 1;
  Result := True; // ��������ģʽ��ģ�ⷵ�ع̶�λ��
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P := Editor.CursorTextXY;
    Row := P.Y;
    Col := P.X;
    Result := True;
  end;
{$ELSE}
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    Col := iEditPosition.Column;
    Row := iEditPosition.Row;
    Result := True;
  except
    ;
  end;
{$ENDIF}
{$ENDIF}
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := True; // ��������ģʽ����ʱɶ������
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P.X := Col;
    P.Y := Row;
    Editor.CursorTextXY := P;
    Result := True;
  end;
{$ELSE}
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, Col);
    Result := True;
  except
    ;
  end;
{$ENDIF}
{$ENDIF}
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourceCol(Col: Integer): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := True; // ��������ģʽ����ʱɶ������
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P.X := Col;
    P.Y := Editor.CursorTextXY.Y;
    Editor.CursorTextXY := P;
    Result := True;
  end;
{$ELSE}
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(iEditPosition.Row, Col);
    Result := True;
  except
    ;
  end;
{$ENDIF}
{$ENDIF}
end;

// �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
function CnOtaSetCurSourceRow(Row: Integer): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := True; // ��������ģʽ����ʱɶ������
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P.X := Editor.CursorTextXY.X;
    P.Y := Row;
    Editor.CursorTextXY := P;
    Result := True;
  end;
{$ELSE}
  try
    iEditPosition := CnOtaGetEditPosition;
    if iEditPosition = nil then Exit;
    iEditPosition.Move(Row, iEditPosition.Column);
    Result := True;
  except
    ;
  end;
{$ENDIF}
{$ENDIF}
end;

// �ڵ�ǰԴ�ļ����ƶ����
function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
{$IFNDEF STAND_ALONE}
var
{$IFDEF LAZARUS}
  P: TPoint;
  Editor: TSourceEditorInterface;
{$ELSE}
  iEditPosition: IOTAEditPosition;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF STAND_ALONE}
  Result := True; // ��������ģʽ����ʱɶ������
{$ELSE}
  Result := False;
{$IFDEF LAZARUS}
  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Assigned(Editor) then
  begin
    P := Editor.CursorTextXY;
    case Pos of
      ipFileHead:
        begin
          P.X := 1;
          P.Y := 1;
        end;
      ipFileEnd:
        begin
          P.Y := Editor.Lines.Count;
          if Editor.Lines.Count > 0 then
            P.X := Length(Editor.Lines[Editor.Lines.Count - 1])
          else
            P.X := 1;
        end;
      ipLineHead:
        begin
          P.X := 1;
        end;
      ipLineEnd:
        begin
          if P.Y <= Editor.Lines.Count then
            P.X := Length(Editor.Lines[P.Y - 1])
          else
            P.X := 1;
        end;
    end;

    if (OffsetRow <> 0) or (OffsetCol <> 0) then
    begin
      P.X := P.X + OffsetCol;
      P.Y := P.Y + OffsetRow;
    end;
    Editor.CursorTextXY := P;
    Result := True;
  end;
{$ELSE}
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
{$ENDIF}
{$ENDIF}
end;

procedure CnOtaInsertTextIntoEditor(const Text: string);
{$IFNDEF NO_DELPHI_OTA}
var
  EditView: IOTAEditView;
  Position: Longint;
  EditPos: TOTAEditPos;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor <> nil then
  begin
    SourceEditorManagerIntf.ActiveEditor.ReplaceText(SourceEditorManagerIntf.ActiveEditor.CursorTextXY,
      SourceEditorManagerIntf.ActiveEditor.CursorTextXY, Text);
  end;
{$ELSE}
  EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));
  EditPos := EditView.CursorPos;

  if not CnOtaConvertEditPosToLinearPos(Pointer(EditView), EditPos, Position) then
    Exit;

{$IFDEF UNICODE}
  CnOtaInsertTextIntoEditorAtPosW(Text, Position);
{$ELSE}
  CnOtaInsertTextIntoEditorAtPos(Text, Position);
{$ENDIF}
  EditView.MoveViewToCursor;
  EditView.Paint;
{$ENDIF}
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function CnGeneralGetCurrLinearPos(SourceEditor: {$IFDEF LAZARUS} TSourceEditorInterface
  {$ELSE} IOTASourceEditor {$ENDIF}): Integer;
{$IFDEF BDS}
var
  Stream: TMemoryStream;
  Utf8Text: AnsiString;
  WideText: WideString;
{$ENDIF}
begin
  Result := CnOtaGetCurrLinearPos(SourceEditor);
{$IFDEF BDS}
  // Utf8 ƫ������ת���� Utf16 ƫ����������ȡ 1 �� Utf8 ƫ�������Ӵ���ת UnicodeString �����ַ�����
  if Result <= 0 then
    Exit;

  Stream := TMemoryStream.Create;
  try
    CnGeneralSaveEditorToUtf8Stream(SourceEditor, Stream); // ���� Stream �� Utf8
    if Stream.Size <= 0 then
      Exit;

    if Stream.Size < Result then
      Result := Stream.Size;

    SetLength(Utf8Text, Result);
    Move(Stream.Memory^, Utf8Text[1], Result);
    WideText := CnUtf8DecodeToWideString(Utf8Text);
    Result := Length(WideText);
  finally
    Stream.Free;
  end;
{$ENDIF}
end;

// ���� SourceEditor ��ǰ���λ�õ����Ե�ַ����Ϊ 0 ��ʼ�� Ansi/Utf8/Utf8
function CnOtaGetCurrLinearPos(SourceEditor: {$IFDEF LAZARUS} TSourceEditorInterface
  {$ELSE} IOTASourceEditor {$ENDIF}): Integer;
var
{$IFDEF LAZARUS}
  Editor: TSourceEditorInterface;
{$ELSE}
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
{$ENDIF}
begin
{$IFDEF LAZARUS}
  if not Assigned(SourceEditor) then
    SourceEditor := SourceEditorManagerIntf.ActiveEditor;

  if SourceEditor <> nil then
  begin
    Result := SourceEditor.SelStart;
  end
  else
    Result := 0;
{$ELSE}
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor.EditViewCount > 0 then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;

    Result := CnOtaGetLinePosFromEditPos(EditPos, SourceEditor);
  end
  else
    Result := 0;
{$ENDIF}
end;

// ��װ�Ľ��������� Pascal ����Ĺ���
procedure CnPasParserParseSource(Parser: TCnGeneralPasStructParser;
  Stream: TMemoryStream; AIsDpr, AKeyOnly: Boolean);
begin
  if (Parser = nil) or (Stream = nil) then
    Exit;

{$IFDEF LAZARUS}
  Parser.ParseSource(PWideChar(Stream.Memory), AIsDpr, AKeyOnly);
{$ELSE}
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Parser.ParseSource(PWideChar(Stream.Memory), AIsDpr, AKeyOnly);
{$ELSE}
  Parser.ParseSource(PAnsiChar(Stream.Memory), AIsDpr, AKeyOnly);
{$ENDIF}
{$ENDIF}
end;

// ��װ�Ľ��������� Pascal �����е��ַ����Ĺ��̣��������Ե�ǰ���Ĵ���
procedure CnPasParserParseString(Parser: TCnGeneralPasStructParser;
  Stream: TMemoryStream);
begin
  if (Parser = nil) or (Stream = nil) then
    Exit;

{$IFDEF LAZARUS}
  Parser.ParseString(PWideChar(Stream.Memory));
{$ELSE}
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Parser.ParseString(PWideChar(Stream.Memory));
{$ELSE}
  Parser.ParseString(PAnsiChar(Stream.Memory));
{$ENDIF}
{$ENDIF}
end;


// ��װ�Ľ��������� Cpp ����Ĺ���
procedure CnCppParserParseSource(Parser: TCnGeneralCppStructParser;
  Stream: TMemoryStream; CurrLine: Integer; CurCol: Integer;
  ParseCurrent: Boolean; NeedRoundSquare: Boolean);
begin
  if (Parser = nil) or (Stream = nil) then
    Exit;

{$IFDEF LAZARUS}
  Parser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
    CurrLine, CurCol, ParseCurrent, NeedRoundSquare);
{$ELSE}
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Parser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
    CurrLine, CurCol, ParseCurrent, NeedRoundSquare);
{$ELSE}
  Parser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size, CurrLine, CurCol,
    ParseCurrent, NeedRoundSquare);
{$ENDIF}
{$ENDIF}
end;

// ��װ�Ľ��������� C/C++ �����е��ַ����Ĺ��̣��������Ե�ǰ���Ĵ���
procedure CnCppParserParseString(Parser: TCnGeneralCppStructParser;
  Stream: TMemoryStream);
begin
  if (Parser = nil) or (Stream = nil) then
    Exit;

{$IFDEF LAZARUS}
  Parser.ParseString(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar));
{$ELSE}
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  Parser.ParseString(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar));
{$ELSE}
  Parser.ParseString(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}
{$ENDIF}
end;

function CnOtaGetCurrentCharPosFromCursorPosForParser(out CharPos: TOTACharPos): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIndex: Integer;
begin
  Result := False;
{$IFDEF LAZARUS}
  if SourceEditorManagerIntf.ActiveEditor <> nil then
  begin
    Text := SourceEditorManagerIntf.ActiveEditor.CurrentLineText;
    CharPos.Line := SourceEditorManagerIntf.ActiveEditor.CursorTextXY.Y;
    CharPos.CharIndex := 0;

    // Text �� 1 �� x - 1 �� Copy �Ӵ�
    CharIndex := SourceEditorManagerIntf.ActiveEditor.CursorTextXY.X;
    if CharIndex > 0 then
    begin
      Text := Copy(Text, 1, CharIndex - 1);
      CharPos.CharIndex := Length(Utf8Decode(Text));
    end;
    Result := True;
  end;
{$ELSE}
{$IFDEF UNICODE}
  if not CnNtaGetCurrLineTextW(Text, LineNo, CharIndex) then
    Exit;
{$ELSE}
  if not CnNtaGetCurrLineText(Text, LineNo, CharIndex) then
    Exit;

  {$IFDEF IDE_STRING_ANSI_UTF8}
    // CharIndex is Utf8, convert to Utf16
    Delete(Text, CharIndex + 1, MaxInt);
    CharIndex := Length(UTF8Decode(Text));
  {$ENDIF}
{$ENDIF}
  CharPos.Line := LineNo;
  CharPos.CharIndex := CharIndex;
  Result := True;
{$ENDIF}
end;

{$ENDIF}

{$IFNDEF LAZARUS}

{$IFNDEF NO_DELPHI_OTA}

function CnOtaGetLinePosFromEditPos(EditPos: TOTAEditPos;
  SourceEditor: IOTASourceEditor): Integer;
var
  CharPos: TOTACharPos;
  IEditView: IOTAEditView;
{$IFDEF UNICODE}
{$IFNDEF CNWIZARDS_MINIMUM}
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  EditControl: TControl;
{$ENDIF}
{$ENDIF}
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor.EditViewCount > 0 then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);

{$IFDEF UNICODE}
    CharPos.Line := EditPos.Line;
    CharPos.CharIndex := 0;

    Result := IEditView.CharPosToPos(CharPos); // �õ����׵�����λ�ã��� Utf8 ����

  {$IFDEF CNWIZARDS_MINIMUM}
    Inc(Result, EditPos.Col - 1);
  {$ELSE}
    // Unicode �������п��ַ�ʱ ConvertPos �� CharPosToPos �������ף�ֻ���ֹ�ת��
    // �Ƚ���ǰ���׵����������Ե�ַ������ȷ�� Utf8���ټ��ϱ������׵���ǰ����ε� Utf8 ����
    EditControl := EditControlWrapper.GetEditControl(IEditView);
    if EditControl = nil then
    begin
      Inc(Result, EditPos.Col - 1);
      Exit;
    end;

    CnNtaGetCurrLineTextW(Text, LineNo, CharIdx);
    Text := Copy(Text, 1, CharIdx); // �õ����ǰ�� UTF16 �ַ���
    // ת���� Utf8 ���󳤶ȣ��ӵ������׳�����
    Inc(Result, Length(UTF8Encode(Text)));
  {$ENDIF}
{$ELSE}
    IEditView.ConvertPos(True, EditPos, CharPos);
    Result := IEditView.CharPosToPos(CharPos);
{$ENDIF}
    if Result < 0 then
      Result := 0;
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

// ���� EditReader ���ݵ����У����е����� CheckUtf8 ʱĬ��Ϊ Ansi������ Ansi/Utf8/Utf8 ��ʽ
procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
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
{$IFDEF UNICODE}
  UniText: string;
{$ENDIF}
begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaSaveReaderToStream. StartPos %d, EndPos %d, PreSize %d.',
//    [StartPos, EndPos, PreSize]);
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

  // ��ʱ������������ Ansi/Utf8/Utf8��CheckUtf8 ����� True����ȫת Ansi

{$IFDEF IDE_WIDECONTROL}
  if CheckUtf8 then
  begin
    AlternativeWideChar := AlternativeWideChar and _UNICODE_STRING and CodePageOnlySupportsEnglish;

    if AlternativeWideChar then
    begin
{$IFDEF UNICODE}
      // Unicode �������ڴ�Ӣ�� OS �²��ܰ��պ����ת Ansi�����ⶪ�ַ���
      // ��Ҫת�� UTF16 ����Ӳ��� Ansi��
      UniText := Utf8Decode(PAnsiChar(Stream.Memory));
      Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(UniText));
{$ELSE}
      Text := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
{$ENDIF}
    end
    else
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
    end;
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
  PreSize: Integer = 0; CheckUtf8: Boolean = True; AlternativeWideChar: Boolean = False);
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  CnOtaSaveReaderToStream(Editor.CreateReader, Stream, StartPos, EndPos, PreSize, CheckUtf8, AlternativeWideChar);
end;

// ����༭���ı�������
function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean; AlternativeWideChar: Boolean): Boolean;
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
      IPos := CnOtaGetCurrLinearPos(Editor)
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

    CnOtaSaveEditorToStreamEx(Editor, Stream, IPos, 0, PreSize, CheckUtf8, AlternativeWideChar);
    Result := True;
  end;
end;

// ���浱ǰ�༭���ı�������
function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean; AlternativeWideChar: Boolean): Boolean;
begin
  Result := CnOtaSaveEditorToStream(nil, Stream, FromCurrPos, CheckUtf8, AlternativeWideChar);
end;

// ȡ�õ�ǰ�༭��Դ����
function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean): string;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    if CnOtaSaveCurrentEditorToStream(Strm, False, CheckUtf8) then
      Result := string(PAnsiChar(Strm.Memory));
  finally
    Strm.Free;
  end;
end;

// ��װ��һͨ�÷�����ʹ�� Filer �������ݼ�����ָ���ļ�����Ҫ�� Ansi/Utf16/Utf16��
// ĩβ�����н����ַ� #0�������ִ����ļ������ڴ棬�� Ansi �� Wide ����﷨�����д���ļ���
function CnGeneralFilerLoadFileFromStream(const FileName: string; Stream: TMemoryStream): Boolean;
{$IFDEF IDE_STRING_ANSI_UTF8}
var
  Utf8: AnsiString;
  Text: WideString;
{$ENDIF}
begin
  Result := False;
  if Stream.Size <= 0 then
    Exit;
{$IFDEF IDE_STRING_ANSI_UTF8}
  // BDS 2005~2007 �� Stream Ҫ���� Utf8����Ҫ�� Utf16 ת������
  SetLength(Text, Stream.Size div SizeOf(WideChar));
  Move(Stream.Memory^, Text[1], Length(Text) * SizeOf(WideChar));
  Utf8 := CnUtf8EncodeWideString(Text);

  Stream.Size := Length(Utf8);
  Stream.Position := 0;
  Stream.Write(PAnsiChar(Utf8)^, (Length(Utf8)));
  Stream.Position := 0;
{$ENDIF}
  EditFilerLoadFileFromStream(FileName, Stream, False);
  Result := True;
end;

// ��װ��һͨ�÷�����ʹ�� Filer ��ָ���ļ����ݱ��������У�Ansi/Utf16/Utf16��ĩβ���н����ַ� #0��
// �����ִ����ļ������ڴ棬�� Ansi �� Wide ����﷨������
function CnGeneralFilerSaveFileToStream(const FileName: string; Stream: TMemoryStream): Boolean;
{$IFDEF IDE_STRING_ANSI_UTF8}
var
  Utf8: AnsiString;
  Text: WideString;
{$ENDIF}
begin
  EditFilerSaveFileToStream(FileName, Stream, False);
{$IFDEF IDE_STRING_ANSI_UTF8}
  // BDS 2005~2007 �� Stream ��� IDE �ж������������ Utf8����Ҫת���� Utf16
  if Stream.Size > 0 then
  begin
    SetLength(Utf8, Stream.Size);
    Move(Stream.Memory^, Utf8[1], Stream.Size);
    Text := CnUtf8DecodeToWideString(Utf8);

    if Text <> '' then
    begin
      Stream.Size := (Length(Text) + 1) * SizeOf(WideChar);
      Stream.Position := 0;
      Stream.Write(Pointer(Text)^, (Length(Text) + 1) * SizeOf(WideChar));
    end
    else
    begin
      // ���ת UTF16 ʧ�ܣ�˵������ Utf8������ Ansi ����ֱ��ת��Ϊ WideString
{$IFDEF DEBUG}
      CnDebugger.LogMsg('CnGeneralFilerSaveFileToStream Utf8 to Wide Fail, use Ansi to Wide.');
{$ENDIF}
      Text := WideString(Utf8);
    end;
  end;
{$ENDIF}
  Result := Stream.Size > 0;
end;

{$IFDEF UNICODE}

// ���� EditReader ���ݵ����У����е�����Ĭ��Ϊ Unicode ��ʽ��2009 ����ʹ��
procedure CnOtaSaveReaderToStreamW(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
const
  // Leave typed constant as is - needed for streaming code.
  TerminatingNulChar: AnsiChar = #0;
  BufferSize = 1024 * 24;
var
  Buffer: PAnsiChar;
  EditReaderPos: Integer;
  DataLen: Integer;
  ReadDataSize: Integer;
  Text: string;
begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaSaveReaderToStreamW. StartPos %d, EndPos %d, PreSize %d.',
//    [StartPos, EndPos, PreSize]);
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

  // ��ʹ Unicode �����£�EditReader ��������Ȼ�� Utf8 �� AnsiString���ڴ�ת�� UnicodeString
  Text := UTF8ToUnicodeString(PAnsiChar(Stream.Memory));
  Stream.Size := (Length(Text) + 1) * SizeOf(Char);
  Stream.Position := 0;
  Stream.Write(PChar(Text)^, (Length(Text) + 1) * SizeOf(Char));

  Stream.Position := 0;
end;

// ����༭���ı������У�Unicode �汾��2009 ����ʹ��
procedure CnOtaSaveEditorToStreamWEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  CnOtaSaveReaderToStreamW(Editor.CreateReader, Stream, StartPos, EndPos, PreSize);
end;

// ����༭���ı������У�Unicode �汾��2009 ����ʹ��
function CnOtaSaveEditorToStreamW(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
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
      IPos := CnOtaGetCurrLinearPos(Editor)
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

    CnOtaSaveEditorToStreamWEx(Editor, Stream, IPos, 0, PreSize);
    Result := True;
  end;
end;

// ���浱ǰ�༭���ı������У�Unicode �汾��2009 ����ʹ��
function CnOtaSaveCurrentEditorToStreamW(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
begin
  Result := CnOtaSaveEditorToStreamW(nil, Stream, FromCurrPos);
end;

// ȡ�õ�ǰ�༭��Դ���룬Unicode �汾��2009 ����ʹ��
function CnOtaGetCurrentEditorSourceW: string;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    if CnOtaSaveCurrentEditorToStreamW(Stream, False) then
      Result := string(PChar(Stream.Memory));
  finally
    Stream.Free;
  end;
end;

// ���õ�ǰ�༭��Դ���룬Unicode �汾��2009 ����ʹ��
procedure CnOtaSetCurrentEditorSourceW(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}

// ���� EditReader ���ݵ����У����е�����Ϊ WideString ��ʽ����ĩβ #0 �ַ���2005 ~ 2007 ��ʹ��
procedure CnOtaSaveReaderToWideStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
const
  // Leave typed constant as is - needed for streaming code.
  TerminatingNulChar: AnsiChar = #0;
  BufferSize = 1024 * 24;
var
  Buffer: PAnsiChar;
  EditReaderPos: Integer;
  DataLen: Integer;
  ReadDataSize: Integer;
  Text: WideString;
begin
  Assert(EditReader <> nil);
  Assert(Stream <> nil);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaSaveReaderToStreamW. StartPos %d, EndPos %d, PreSize %d.',
//    [StartPos, EndPos, PreSize]);
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

  // EditReader �������� Utf8 �� AnsiString���ڴ�ת�� WideString
  Text := UTF8Decode(PAnsiChar(Stream.Memory));
  Stream.Size := (Length(Text) + 1) * SizeOf(WideChar);
  Stream.Position := 0;
  Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * SizeOf(WideChar));

  Stream.Position := 0;
end;

// ����༭���ı������У�Utf8 ����תΪ WideString��2005 ~ 2007 ��ʹ��
procedure CnOtaSaveEditorToWideStreamEx(Editor: IOTASourceEditor; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0);
begin
  if Editor = nil then
  begin
    Editor := CnOtaGetCurrentSourceEditor;
    if Editor = nil then
      Exit;
  end;

  CnOtaSaveReaderToWideStream(Editor.CreateReader, Stream, StartPos, EndPos, PreSize);
end;

// ����༭���ı������У�Utf8 ����תΪ WideString��2005 ~ 2007 ��ʹ��
function CnOtaSaveEditorToWideStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean = False): Boolean;
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
      IPos := CnOtaGetCurrLinearPos(Editor)
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

    CnOtaSaveEditorToWideStreamEx(Editor, Stream, IPos, 0, PreSize);
    Result := True;
  end;
end;

// ���浱ǰ�༭���ı������У�Utf8 ����תΪ WideString��2005 ~ 2007 ��ʹ��
function CnOtaSaveCurrentEditorToWideStream(Stream: TMemoryStream; FromCurrPos:
  Boolean): Boolean;
begin
  Result := CnOtaSaveEditorToWideStream(nil, Stream, FromCurrPos);
end;

// ���õ�ǰ�༭��Դ���룬ֻ�� D2005~2007 �汾ʹ�ã�����Ϊԭʼ UTF8 ����
procedure CnOtaSetCurrentEditorSourceUtf8(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
    EditWriter.Insert(PAnsiChar(Text));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

// ���õ�ǰ�༭��Դ����
procedure CnOtaSetCurrentEditorSource(const Text: string);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;

  EditWriter := CnOtaGetEditWriterForSourceEditor(nil);
  try
    EditWriter.DeleteTo(MaxInt);
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
  {$ENDIF}
  finally
    EditWriter := nil;
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

procedure CnOtaInsertTextIntoEditorUtf8(const Utf8Text: AnsiString);
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
  CnOtaInsertTextIntoEditorAtPosUtf8(Utf8Text, Position);
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
  {$IFDEF UNICODE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
  {$ELSE}
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
  {$ENDIF}
  finally
    EditWriter := nil;
  end;
end;

procedure CnOtaInsertTextIntoEditorAtPosUtf8(const Utf8Text: AnsiString; Position: Longint;
  SourceEditor: IOTASourceEditor);
var
  EditWriter: IOTAEditWriter;
begin
  if Utf8Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
    EditWriter.Insert(PAnsiChar(Utf8Text));
  finally
    EditWriter := nil;
  end;
end;

{$IFDEF UNICODE}

// ��ָ��λ�ô������ı������ SourceEditor Ϊ��ʹ�õ�ǰֵ��D2009 ����ʹ�á�
procedure CnOtaInsertTextIntoEditorAtPosW(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
var
  EditWriter: IOTAEditWriter;
begin
  if Text = '' then
    Exit;
  EditWriter := CnOtaGetEditWriterForSourceEditor(SourceEditor);
  try
    EditWriter.CopyTo(Position);
    EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW((Text))));
  finally
    EditWriter := nil;
  end;
end;

{$ENDIF}

{$IFNDEF CNWIZARDS_MINIMUM}

procedure CnOtaGotoEditPosAndRepaint(EditView: IOTAEditView; EditPosLine: Integer; EditPosCol: Integer);
var
  EditControl: TControl;
  EditPos: TOTAEditPos; // ���� 1 ��ʼ
begin
  if EditView <> nil then
  begin
    if EditPosLine > 0 then
    begin
      EditPos.Line := EditPosLine;
      if EditPosCol <= 0 then
        EditPos.Col := 1
      else
        EditPos.Col := EditPosCol;

      EditView.CursorPos := EditPos;
      if EditPosCol <= 0 then
        EditView.Center(EditPosLine, 1);

      CnOtaMakeSourceVisible(EditView.Buffer.FileName);
      EditView.MoveViewToCursor;
      EditView.Paint;

      EditControl := GetCurrentEditControl;
      if (EditControl <> nil) and (EditControl is TWinControl) then
        (EditControl as TWinControl).SetFocus;
    end;
  end;
end;

{$ENDIF}

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

  if EditView = nil then
    Exit;

  if EditPos.Line < 1 then
    EditPos.Line := 1;

  TopRow.Col := 1;
  TopRow.Line := EditPos.Line;

  if Middle then
  begin
    TopRow.Line := TopRow.Line - (EditView.ViewSize.cy div 2) + 1;
    if TopRow.Line < 1 then
      TopRow.Line := 1;
    EditView.TopPos := TopRow;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('CnOtaGotoEditPos Set Middle TopPos Line %d Col %d', [TopRow.Line, TopRow.Col]);
{$ENDIF}
  end
  else
  begin
    if EditView.TopPos.Line > EditPos.Line then
    begin
      TopRow.Line := EditPos.Line;
      EditView.TopPos := TopRow;
    end
    else if (EditView.TopPos.Line + EditView.ViewSize.cy) < EditPos.Line then
    begin
      TopRow.Line := EditPos.Line - EditView.ViewSize.cy;
      EditView.TopPos := TopRow;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('CnOtaGotoEditPos Set Non-Middle TopPos Line %d Col %d', [TopRow.Line, TopRow.Col]);
{$ENDIF}
  end;

  EditView.CursorPos := EditPos;
  EditView.MoveViewToCursor; // FIXME: TopPos ��ֵ�ƺ������⣿
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

// �� EditView �е� CharPos תΪ EditPos����װ�������� 2009 ������ƫ�������
// EditView ʹ�� Pointer ���д��������Ч�ʡ�2005 ���ϲ�ʹ�� ConvertPos����
// ʹ�ÿ��ַ����ṹ�﷨����������Ԥ�� Tab չ��
procedure CnOtaConvertEditViewCharPosToEditPos(EditViewPtr: Pointer;
  CharPosLine, CharPosCharIndex: Integer; var EditPos: TOTAEditPos);
{$IFNDEF BDS}
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
{$ENDIF}
begin
{$IFDEF BDS}
  // 2005 ���ϣ�Pascal/Cpp ���ַ��﷨�ṹ���������Ѿ����� Tab չ�������� Convert ��
  EditPos.Line := CharPosLine;
  EditPos.Col := CharPosCharIndex + 1;
{$ELSE}
  if EditViewPtr = nil then
  begin
    EditPos.Line := CharPosLine;
    EditPos.Col := CharPosCharIndex + 1;
    Exit;
  end;

  CharPos := OTACharPos(CharPosCharIndex, CharPosLine);
  EditView := IOTAEditView(EditViewPtr);
  try
    EditView.ConvertPos(False, EditPos, CharPos);
  except
    // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
    EditPos.Line := CharPosLine;
    EditPos.Col := CharPosCharIndex + 1;
  end;
{$ENDIF}

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnOtaConvertEditViewCharPosToEditPos %d:%d to %d:%d',
//    [CharPosLine, CharPosCharIndex, EditPos.Line, EditPos.Col]);
{$ENDIF}
end;

{$IFNDEF CNWIZARDS_MINIMUM}

// �� EditPos ת����Ϊ StructureParser ����� CharPos
procedure CnOtaConvertEditPosToParserCharPos(EditViewPtr: Pointer; var EditPos:
  TOTAEditPos; var CharPos: TOTACharPos);
var
{$IFNDEF BDS2009_UP}
  EditView: IOTAEditView;
{$ENDIF}
  EditControl: TControl;
  Text: string;
begin
  if EditViewPtr = nil then
    EditViewPtr := Pointer(CnOtaGetTopMostEditView);
  EditControl := EditControlWrapper.GetEditControl(IOTAEditView(EditViewPtr));
  if EditControl = nil then
    Exit;

  Text := EditControlWrapper.GetTextAtLine(EditControl, EditPos.Line);
  // ��õ�ǰ�����ݣ�Ansi/Utf8/Utf16

{$IFDEF BDS2009_UP}
  CharPos.Line := EditPos.Line;
  CharPos.CharIndex := EditPos.Col - 1;

  // TODO: Convert AnsiCharIndex to WideCharIndex
{$ELSE}
  if EditViewPtr = nil then
  begin
    CharPos.Line := EditPos.Line;
    CharPos.CharIndex := EditPos.Col - 1;

  {$IFDEF IDE_STRING_ANSI_UTF8}
    // TODO: Convert Utf8 CharIndex to WideCharIndex
  {$ENDIF}
  end;

  EditView := IOTAEditView(EditViewPtr);
  try
    EditView.ConvertPos(True, EditPos, CharPos);
  except
    // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
    CharPos.Line := EditPos.Line;
    CharPos.CharIndex := EditPos.Col - 1;
  end;
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // TODO: Convert Utf8 CharIndex to WideCharIndex
  {$ENDIF}
{$ENDIF}
end;

function CnOtaConvertEditPosToLinearPos(EditViewPtr: Pointer; var EditPos: TOTAEditPos;
  out Position: Integer): Boolean;
var
  EditView: IOTAEditView;
  EditControl: TControl;
  Text: string;
  CharPos: TOTACharPos;
begin
  Result := False;
  if EditViewPtr = nil then
    EditViewPtr := Pointer(CnOtaGetTopMostEditView);
  if EditViewPtr = nil then
    Exit;
  EditControl := EditControlWrapper.GetEditControl(IOTAEditView(EditViewPtr));
  if EditControl = nil then
    Exit;

  Text := EditControlWrapper.GetTextAtLine(EditControl, EditPos.Line);
  // ��õ�ǰ�����ݣ�Ansi/Utf8/Utf16
{$IFDEF UNICODE}
  CharPos.Line := EditPos.Line;
  CharPos.CharIndex := 0; // �Ȼ����ͷ������λ��

  EditView := IOTAEditView(EditViewPtr);
  Position := EditView.CharPosToPos(CharPos);

  // ���ݵ�ǰ�й��ǰ�Ŀ��ַ����������� Position
  Inc(Position, CalcUtf8LengthFromWideStringOffset(PWideChar(Text), EditPos.Col));
  Result := True;
{$ELSE}
  EditView := IOTAEditView(EditViewPtr);
  try
    EditView.ConvertPos(True, EditPos, CharPos);
  except
    // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
    CharPos.Line := EditPos.Line;
    CharPos.CharIndex := EditPos.Col - 1;
  end;

  Position := EditView.CharPosToPos(CharPos);
  Result := True;
{$ENDIF}
end;

{$ENDIF}

// ��װ�İ� Pascal Token ���������� Ansi/Wide λ�ò���ת���� IDE ����� CharPos �Ĺ���
// ��� CharPos���Ա��� EditView ת���� EditPos
procedure CnConvertGeneralTokenPositionToCharPos(EditViewPtr: Pointer;
  Token: TCnGeneralPasToken; out CharPos: TOTACharPos);
{$IFDEF IDE_STRING_ANSI_UTF8}
var
  Text: string;
  EditControl: TControl;
{$ENDIF}
begin
  if Token = nil then
    Exit;

  CharPos.Line := Token.LineNumber + 1; // 0 ��ʼ��� 1 ��ʼ

{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  CharPos.CharIndex := Token.CharIndex; // ��ʹ�� 0 ��ʼ�� WideChar ƫ��

  // CharPos ��Ҫ Utf8���ѻ��� WideChar �� CharIndex ת������
  EditControl := EditControlWrapper.GetEditControl(IOTAEditView(EditViewPtr));
  if EditControl <> nil then
  begin
    Text := EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line);
    // �õ� Utf8 �� Text��ת�� WideString ����ȡ��ת�����󳤶�
    CharPos.CharIndex := CalcUtf8StringLengthFromWideOffset(PAnsiChar(Text), CharPos.CharIndex);
  end;
  {$ELSE}
  CharPos.CharIndex := Token.AnsiIndex; // ʹ�� WideToken �� Ansi ƫ�ƣ����� 0 ��ʼ
  {$ENDIF}
{$ELSE}
  CharPos.CharIndex := Token.CharIndex; // ���� Ansi ƫ�ƣ����� 0 ��ʼ
{$ENDIF}

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CnConvertPasTokenPositionToCharPos %d:%d/(A)%d to %d:%d - %s.',
//    [Token.LineNumber, Token.CharIndex, {$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
//     Token.AnsiIndex, {$ELSE} 0, {$ENDIF} CharPos.Line, CharPos.CharIndex, Token.Token])
{$ENDIF}
end;

// ������������������ Token ������ת���� IDE ����� EditPos
procedure ConvertGeneralTokenPos(EditView: Pointer; AToken: TCnGeneralPasToken);
var
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
begin
  // �������������������ַ�ƫ��ת���� CharPos
  CnConvertGeneralTokenPositionToCharPos(EditView, AToken, CharPos);
  // �ٰ� CharPos ת���� EditPos
  CnOtaConvertEditViewCharPosToEditPos(EditView,
    CharPos.Line, CharPos.CharIndex, EditPos);

  AToken.EditCol := EditPos.Col;
  AToken.EditLine := EditPos.Line;
{$IFDEF IDE_STRING_ANSI_UTF8}
  // D2005~2007 �� EditPos �� Col �� Utf8 �ģ���������Ҫ Ansi �ģ�
  // ���Զ��⿪������ʹ���� AnsiIndex
  AToken.EditAnsiCol := AToken.AnsiIndex + 1;
{$ENDIF}
end;

// ����Դ���������õĵ�Ԫ��FileName �������ļ���
procedure ParseUnitUsesFromFileName(const FileName: string; UsesList: TStrings);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Stream);
{$IFDEF UNICODE}
    ParseUnitUsesW(PChar(Stream.Memory), UsesList);
{$ELSE}
    ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);
{$ENDIF}
  finally
    Stream.Free;
  end;
end;

//==============================================================================
// ���������غ���
//==============================================================================

// ȡ�õ�ǰ��ƵĴ��弰ѡ�������б����سɹ���־
function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList;
  ExcludeForm: Boolean): Boolean;
var
  I: Integer;
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
  I: Integer;
begin
  Result := False;
  Assert(Assigned(Component));
  for I := 0 to Component.GetPropCount - 1 do
  begin
    Result := SameText(Component.GetPropName(I), PropertyName);
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
  I: Integer;
begin
  List.Clear;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;

    for I := 0 to AList.Count - 1 do
      List.Add(TComponent(AList[I]).Name);
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

// ȡ�õ�ǰѡ��Ŀؼ��������б�
procedure CnOtaGetCurrFormSelectionsClassName(List: TStrings);
var
  AForm: TCustomForm;
  AList: TList;
  I: Integer;
begin
  List.Clear;
  AList := TList.Create;
  try
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;

    for I := 0 to AList.Count - 1 do
      List.Add(TComponent(AList[I]).ClassName);
  finally
    AList.Free;
  end;
end;

// ���Ƶ�ǰѡ��Ŀؼ��������б�������
procedure CnOtaCopyCurrFormSelectionsClassName;
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    CnOtaGetCurrFormSelectionsClassName(List);
    if List.Count = 1 then
      Clipboard.AsText := List[0]  // ֻ��һ��ʱȥ�����з�
    else
      Clipboard.AsText := List.Text;
  finally
    List.Free;
  end;
end;

// ��� IDE �Ƿ�֧�������л�
function CnOtaIDESupportsTheming: Boolean;
{$IFDEF IDE_SUPPORT_THEMING}
var
  {$IFDEF DELPHI102_TOKYO}
  Theming: ICnOTAIDEThemingServices250;
  {$ELSE}
  Theming: IOTAIDEThemingServices250;
  {$ENDIF}
{$ENDIF}
begin
  Result := False;
{$IFDEF IDE_SUPPORT_THEMING}
  if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), Theming) then
    Result := True;
{$ENDIF}
end;

// ��� IDE �Ƿ������������л�
function CnOtaGetIDEThemingEnabled: Boolean;
{$IFDEF IDE_SUPPORT_THEMING}
var
  {$IFDEF DELPHI102_TOKYO}
  Theming: ICnOTAIDEThemingServices;
  {$ELSE}
  Theming: IOTAIDEThemingServices;
  {$ENDIF}
{$ENDIF}
begin
  Result := False;
{$IFDEF IDE_SUPPORT_THEMING}
  if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), Theming) then
    if Theming <> nil then
      Result := Theming.IDEThemingEnabled;
{$ENDIF}
end;

// ��� IDE ��ǰ��������
function CnOtaGetActiveThemeName: string;
{$IFDEF IDE_SUPPORT_THEMING}
var
  {$IFDEF DELPHI102_TOKYO}
  Theming: ICnOTAIDEThemingServices;
  {$ELSE}
  Theming: IOTAIDEThemingServices;
  {$ENDIF}
{$ENDIF}
begin
  Result := '';
{$IFDEF IDE_SUPPORT_THEMING}
  try
    if Supports(BorlandIDEServices, StringToGUID(GUID_IOTAIDETHEMINGSERVICES), Theming) then
      if Theming <> nil then
        Result := Theming.ActiveTheme;
  except
    ; // ���ܳ���ֻ������
  end;
{$ENDIF}
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

procedure CloneSearchCombo(var ASearchCombo: TCnSearchComboBox; ACombo: TComboBox);
begin
  ASearchCombo := TCnSearchComboBox.Create(ACombo.Owner);
  ASearchCombo.MatchMode := mmAnywhere;

  ASearchCombo.Parent := ACombo.Parent;
  ASearchCombo.Top := ACombo.Top;
  ASearchCombo.Left := ACombo.Left;
  ASearchCombo.Width := ACombo.Width;
  ASearchCombo.Height := ACombo.Height;
  ASearchCombo.DropDownList.Width := ASearchCombo.Width;
  ASearchCombo.OnSelect := ACombo.OnChange;

  ASearchCombo.Visible := True;
  ACombo.Visible := False;
end;

// Tests for file existance, a lot faster than the RTL implementation
function FileExists(const Filename: string): Boolean;
var
  a: Cardinal;
begin
  a := GetFileAttributes(PChar(Filename));
  Result := (a <> $FFFFFFFF) and (a and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

{$IFNDEF NO_DELPHI_OTA}

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
  Result := CurrentSourceIsDelphi;
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

{$ENDIF}

const
  MAX_BOOKMARK_COUNT = 20; // 20 ����Ϊ Toggle Var/Uses ʹ�õ��� 19 �� 20

// ��һ EditView �е���ǩ��Ϣ������һ ObjectList ��
procedure SaveBookMarksToObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  BookMarkObj: TCnBookmarkObject;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;
  BookMarkList.Clear;

  for I := 0 to MAX_BOOKMARK_COUNT do
  begin
    APos := EditView.BookmarkPos[I];
    if (APos.CharIndex <> 0) or (APos.Line <> 0) then
    begin
      BookMarkObj := TCnBookmarkObject.Create;
      BookMarkObj.ID := I;
      BookMarkObj.Line := APos.Line;
      BookMarkObj.Col := APos.CharIndex;
      BookMarkList.Add(BookMarkObj);
    end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('SaveBookMarksToObjectList Got %d Bookmarks.', [BookMarkList.Count]);
{$ENDIF}
end;

// �� ObjectList �лָ�һ EditView �е���ǩ
procedure LoadBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  EditPos, SavePos: TOTAEditPos;
  BookMarkObj: TCnBookmarkObject;
begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  if BookMarkList.Count > 0 then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to MAX_BOOKMARK_COUNT do // �������ǰ����ǩ
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
      BookMarkObj := TCnBookmarkObject(BookMarkList.Extract(BookMarkList.First));
      EditPos := EditView.CursorPos;
      EditPos.Line := BookMarkObj.Line;
      EditView.CursorPos := EditPos;
      EditView.BookmarkToggle(BookMarkObj.ID);
      BookMarkObj.Free;
    end;
    EditView.CursorPos := SavePos;
  end;
end;

// �� ObjectList ���滻һ���� EditView �е���ǩ
procedure ReplaceBookMarksFromObjectList(EditView: IOTAEditView; BookMarkList: TObjectList);
var
  I: Integer;
  APos: TOTACharPos;
  EditPos, SavePos: TOTAEditPos;
  BookMarkObj: TCnBookmarkObject;

  function BookMarkIdInList(BID: Integer): Boolean;
  var
    J: Integer;
  begin
    for J := 0 to BookMarkList.Count - 1 do
    begin
      if TCnBookmarkObject(BookMarkList[J]).ID = BID then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

begin
  if (EditView = nil) or (BookMarkList = nil) then Exit;

  if BookMarkList.Count > 0 then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to MAX_BOOKMARK_COUNT do // ����������� BookMarkList �е���ǩ
    begin
      if not BookMarkIdInList(I) then
        Continue;

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
      BookMarkObj := TCnBookmarkObject(BookMarkList.Extract(BookMarkList.First));
      EditPos := EditView.CursorPos;
      EditPos.Line := BookMarkObj.Line;
      EditView.CursorPos := EditPos;
      EditView.BookmarkToggle(BookMarkObj.ID);
      BookMarkObj.Free;
    end;
    EditView.CursorPos := SavePos;
  end;
end;

{$ENDIF}

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

{$IFNDEF CNWIZARDS_MINIMUM}

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

{$ENDIF}

{$ENDIF}

// ���� HDPI ���ã��Ŵ� Button �е� Glyph��Button ֻ���� SpeedButton �� BitBtn
procedure CnEnlargeButtonGlyphForHDPI(const Button: TControl);
var
  SB: TSpeedButton;
  BB: TBitBtn;
  N: Integer;
  Bmp: TBitmap;
  S: Single;
begin
  if Button = nil then
    Exit;

  S := IdeGetScaledFactor(Button);
  if S < 1.2 then // ̫С�˲�����
    Exit;

  Bmp := nil;
  try
    if Button is TSpeedButton then
    begin
      SB := Button as TSpeedButton;
      N := SB.NumGlyphs;
      if SB.Glyph.Empty then
        Exit;

      Bmp := TBitmap.Create;
      Bmp.Width := Trunc(N * SB.Glyph.Width * S);
      Bmp.Height := Trunc(SB.Glyph.Height * S);

      Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), SB.Glyph);
      SB.Glyph.Assign(Bmp);
    end
    else if Button is TBitBtn then
    begin
      BB := Button as TBitBtn;
      N := BB.NumGlyphs;

      if BB.Glyph.Empty then
        Exit;

      Bmp := TBitmap.Create;
      Bmp.Width := Trunc(N * BB.Glyph.Width * S);
      Bmp.Height := Trunc(BB.Glyph.Height * S);

      Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), BB.Glyph);
      BB.Glyph.Assign(Bmp);
    end;
  finally
    Bmp.Free;
  end;
end;

{$IFNDEF STAND_ALONE}

{$IFDEF LAZARUS}

function CnLazSaveEditorToStream(Editor: TSourceEditorInterface; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean): Boolean;
var
  Utf8Text: string;
  Utf16Text: WideString;
begin
  Assert(Stream <> nil);
  Result := False;

  if Editor = nil then
  begin
    Editor := SourceEditorManagerIntf.ActiveEditor;
    if Editor = nil then
      Exit;
  end;

  Utf8Text := Editor.SourceText;
  if FromCurrPos then
    Utf8Text := Copy(Utf8Text, Editor.SelStart, MaxInt);

  if Length(Utf8Text) > 0 then
  begin
    if CheckUtf8 then
    begin
      // ֱ��д�� Utf8
      Stream.Write(Utf8Text[1], Length(Utf8Text) + 1);
      Result := True;
    end
    else
    begin
      Utf16Text := CnUtf8DecodeToWideString(Utf8Text);
      if Length(Utf16Text) > 0 then
      begin
        Stream.Write(Utf16Text[1], (Length(Utf16Text) + 1) * SizeOf(WideChar));
        Result := True;
      end;
    end;
  end;
end;

{$ENDIF}

// ��װ��һͨ�÷�������༭���ı������У�BDS ���Ͼ�ʹ�� WideChar��D567 ʹ�� AnsiChar�������� UTF8
function CnGeneralSaveEditorToStream(Editor: {$IFDEF LAZARUS} TSourceEditorInterface {$ELSE} IOTASourceEditor {$ENDIF};
  Stream: TMemoryStream; FromCurrPos: Boolean): Boolean;
begin
{$IFDEF LAZARUS}
  Result := CnLazSaveEditorToStream(Editor, Stream, FromCurrPos);
{$ELSE}
{$IFDEF UNICODE}
  Result := CnOtaSaveEditorToStreamW(Editor, Stream, FromCurrPos);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  Result := CnOtaSaveEditorToWideStream(Editor, Stream, FromCurrPos);
  {$ELSE}
  Result := CnOtaSaveEditorToStream(Editor, Stream, FromCurrPos, False);
  {$ENDIF}
{$ENDIF}
{$ENDIF}
end;

function CnGeneralSaveEditorToUtf8Stream(Editor: {$IFDEF LAZARUS} TSourceEditorInterface {$ELSE} IOTASourceEditor {$ENDIF};
  Stream: TMemoryStream; FromCurrPos: Boolean): Boolean;
begin
{$IFDEF LAZARUS}
  Result := CnLazSaveEditorToStream(Editor, Stream, FromCurrPos, True);
{$ELSE}
  Result := CnOtaSaveEditorToStream(Editor, Stream, FromCurrPos, False);
{$ENDIF}
end;

{$ENDIF}

procedure FormCallBack(Sender: TObject);
begin
{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
  if Sender is TForm then
    ScaleForm(Sender as TForm, IdeGetScaledFactor);
{$ENDIF}
{$ENDIF}
end;

function CnWizInputQuery(const ACaption, APrompt: string;
  var Value: string; Ini: TCustomIniFile; const Section: string): Boolean;
begin
  Result := CnCommon.CnInputQuery(ACaption, APrompt, Value, Ini, Section, False, FormCallBack);
end;

function CnWizInputBox(const ACaption, APrompt, ADefault: string;
   Ini: TCustomIniFile; const Section: string): string;
begin
  Result := CnInputBox(ACaption, APrompt, ADefault, Ini, Section, FormCallBack);
end;

function CnWizInputMultiLineQuery(const ACaption, APrompt: string;
  var Value: string): Boolean;
begin
  Result := CnInputMultiLineQuery(ACaption, APrompt, Value, FormCallBack);
end;

function CnWizInputMultiLineBox(const ACaption, APrompt, ADefault: string): string;
begin
  Result := CnInputMultiLineBox(ACaption, APrompt, ADefault, FormCallBack);
end;

// ��װ Assert �ж�
procedure CnWizAssert(Expr: Boolean; const Msg: string = '');
begin
{$IFDEF DEBUG}
  if Expr then
    CnDebugger.LogMsg('Assert Passed: ' + Msg)
  else
    CnDebugger.LogMsgError('Assert Failed! ' + Msg);
{$ENDIF}
  Assert(Expr, Msg);
end;

initialization
{$IFNDEF LAZARUS}
  CnNoIconList := TStringList.Create;
  AddNoIconToList('TMenuItem'); // TMenuItem ����ר�Ҽ���֮ǰ��ע��
  AddNoIconToList('TField');
  AddNoIconToList('TAction');
  OldRegisterNoIconProc := RegisterNoIconProc;
  RegisterNoIconProc := CnRegisterNoIconProc;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizUtils.');
{$ENDIF}

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizUtils finalization.');
{$ENDIF}

{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF UNICODE}
  VirtualEditControlBitmap.Free;
{$ENDIF}
{$ENDIF}

{$IFNDEF LAZARUS}
  RegisterNoIconProc := OldRegisterNoIconProc;
  FreeAndNil(CnNoIconList);
{$ENDIF}
  FreeResDll;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizUtils finalization.');
{$ENDIF}

end.

