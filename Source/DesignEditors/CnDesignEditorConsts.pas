{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnDesignEditorConsts;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：属性组件编辑器常量定义单元
* 单元作者：CnPack开发组
* 备    注：
* 开发平台：PWin2000 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.03.14 V1.2
*               增加了本地化字符串
*           2003.03.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows;

{$I CnWizards.inc}

//==============================================================================
// Need to Localize
//==============================================================================

var
  SCnPropertyEditor: string = 'Property Editor';
  SCnComponentEditor: string = 'Component Editor';
  SCnDesignEditorNameStr: string = 'Name:';
  SCnDesignEditorStateStr: string = 'State:';
  SCnPropEditorConfigFormCaption: string = '%s - Property Filter';

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

  // Editor Comments
  SCnStringPropEditorComment: string = 'Editor for Multi-line String and Caption.';
  sCnHintPropEditorComment: string = 'Editor for Multi-line Hint, Short and Long Style Supported.';
  SCnStringsPropEditorComment: string = 'Editor for String List.';
  SCnFileNamePropEditorComment: string = 'Use OpenFile Dialog to Select FileName.';
  SCnSizeConstraintsPropEditorComment: string = 'Editor for Constraints.';
  SCnFontPropEditorComment: string = 'Editor for Font with more Information.';
  SCnControlScrollBarPropEditorComment: string = 'Editor for Scrollbar with more Information.';
  SCnBooleanPropEditorComment: string = 'Editor for Bool Property with a Checkbox.';
  SCnSetPropEditorComment: string = 'Editor for Set Property with Checkboxs in Dropdown List, Direct Input Supported.';
  SCnAlignPropEditorComment: string = 'Editor for Align Property with a bitmap.';
  SCnNamePropEditorComment: string = 'Editor for Component Name Property used Component Prefix Rules.';

  // TCnMultiLineEditorForm
  SCnPropEditorNoMatch: string = 'No Matched Text!';
  SCnPropEditorReplaceOK: string = 'Replace OK, %D actions total.';
  SCnPropEditorCursorPos: string = 'Caret [%D:%D]';
  SCnPropEditorSaveText: string = 'Text Changed. Save it Now?';


  // TCnSizeConstraintsEditorForm
  SCnSizeConsInputError: string = 'Please Enter Integer Values.';
  SCnSizeConsInputNeg: string = 'Negative is Invalid.';

  // TCnNamePropEditor
  SCnPrefixWizardNotExist: string = 'Component Prefix Wizard NOT Exists, Please Enable It.';

implementation

end.
