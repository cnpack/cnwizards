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

unit CnDesignEditorConsts;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ���������༭���������嵥Ԫ
* ��Ԫ���ߣ�CnPack������
* ��    ע��
* ����ƽ̨��PWin2000 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.03.14 V1.2
*               �����˱��ػ��ַ���
*           2003.03.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  Windows;

{$I CnWizards.inc}

const
  // TCnImageListEditor
  csImageCacheDir = 'ImageCache';

//==============================================================================
// Need to Localize
//==============================================================================

var
  SCnPropertyEditor: string = 'Property Editor';
  SCnComponentEditor: string = 'Component Editor';
  SCnDesignEditorNameStr: string = 'Name:';
  SCnDesignEditorStateStr: string = 'State:';
  SCnPropEditorConfigFormCaption: string = '%s - Property Filter';
  SCnCompEditorCustomizeCaption: string = 'Customize Component Editor';
  SCnCompEditorCustomizeCaption1: string = 'Customize Component';
  SCnCompEditorCustomizeDesc: string = 'Component List to Register, (Format "ClassName")';

  // Editor Names
  SCnStringPropEditorName: string = 'String Caption Editor';
  sCnHintPropEditorName: string = 'Hint Editor';
  SCnStringsPropEditorName: string = 'String List Editor';
  SCnFileNamePropEditorName: string = 'FileName Editor';
  SCnSizeConstraintsPropEditorName: string = 'Constraints Editor';
  SCnFontPropEditorName: string = 'Font Editor';
  SCnControlScrollBarPropEditorName: string = 'Scrollbar Editor';
  SCnBooleanPropEditorName: string = 'Bool Editor';
  SCnSetPropEditorName: string = 'Set Editor';
  SCnAlignPropEditorName: string = 'Align Editor';
  SCnNamePropEditorName: string = 'Component Name Editor';
  SCnImageListCompEditorName: string = 'ImageList Editor';

  // Editor Comments
  SCnStringPropEditorComment: string = 'Editor for Multi-line String and Caption.';
  sCnHintPropEditorComment: string = 'Editor for Multi-line Hint, Short and Long Style Supported.';
  SCnStringsPropEditorComment: string = 'Editor for String List.';
  SCnFileNamePropEditorComment: string = 'Use OpenFile Dialog to Select FileName.';
  SCnSizeConstraintsPropEditorComment: string = 'Editor for Constraints.';
  SCnFontPropEditorComment: string = 'Editor for Font with Nore Information.';
  SCnControlScrollBarPropEditorComment: string = 'Editor for Scrollbar with More Information.';
  SCnBooleanPropEditorComment: string = 'Editor for Bool Property with a Checkbox.';
  SCnSetPropEditorComment: string = 'Editor for Set Property with Checkboxs in Dropdown List, Direct Input Supported.';
  SCnAlignPropEditorComment: string = 'Editor for Align Property with a Bitmap.';
  SCnNamePropEditorComment: string = 'Editor for Component Name Property used Component Prefix Rules.';
  SCnImageListCompEditorComment: string = 'Editor for TImageList, XP Style Image and Online Search Supported.';

  // TCnMultiLineEditorForm
  SCnPropEditorNoMatch: string = 'No Matched Text!';
  SCnPropEditorReplaceOK: string = 'Replace OK, Totally Count %D.';
  SCnPropEditorCursorPos: string = 'Caret [%D:%D]';
  SCnPropEditorSaveText: string = 'Text Changed. Save it Now?';

  // TCnSizeConstraintsEditorForm
  SCnSizeConsInputError: string = 'Please Enter Integer Values.';
  SCnSizeConsInputNeg: string = 'Negative is Invalid.';

  // TCnNamePropEditor
  SCnPrefixWizardNotExist: string = 'Component Prefix Wizard NOT Exists, Please Enable It.';

  // TCnImageListEditor
  SCnImageListChangeSize: string = 'Do You Want to Change the Image Dimensions?';
  SCnImageListChangeXPStyle: string = 'Do You Want to Change the Image Style?';
  SCnImageListSearchFailed: string = 'Search image failed!';
  SCnImageListInvalidFile: string = 'The File is NOT a Valid Image File: ';
  SCnImageListSepBmp: string = 'Image Dimensions for %s are Greater than Imagelist Dimensions. Split it into %d Separated Bitmaps?';
  SCnImageListNoPngLib: string = 'CnPngLib.dll NOT Found! Please Reinstall CnWizards.';
  SCnImageListExportFailed: string = 'Export Images Failed!';
  SCnImageListXPStyleNotSupport: string = 'The ImageList Uses XP Style images, but Your IDE doesn''t Support XPManifest! Do You Want to Convert Images to Normal Style?';
  SCnImageListSearchIconsetFailed: string = 'Search Icon Set Failed!';
  SCnImageListGotoPage: string = 'Goto Page';
  SCnImageListGotoPagePrompt: string = 'Enter New Page Number:';

implementation

end.
