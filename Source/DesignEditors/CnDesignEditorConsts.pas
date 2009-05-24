{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
* 单元标识：$Id: CnDesignEditorConsts.pas,v 1.8 2009/01/02 08:36:28 liuxiao Exp $
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
// 需要本地化的字符串
//==============================================================================

var
  SCnPropertyEditor: string = '属性编辑器';
  SCnComponentEditor: string = '组件编辑器';
  SCnDesignEditorNameStr: string = '名称: ';
  SCnDesignEditorStateStr: string = '状态: ';
  SCnPropEditorConfigFormCaption: string = '%s - 属性过滤';

  // 编辑器名称
  SCnStringPropEditorName: string = '字符串、标题属性编辑器';
  sCnHintPropEditorName: string = 'Hint 属性编辑器';
  SCnStringsPropEditorName: string = '字符串列表属性编辑器';
  SCnFileNamePropEditorName: string = '文件名属性编辑器';
  SCnSizeConstraintsPropEditorName: string = 'Constraints 属性编辑器';
  SCnFontPropEditorName: string = '字体属性编辑器';
  SCnControlScrollBarPropEditorName: string = '控件滚动条属性编辑器';
  SCnBooleanPropEditorName: string = '布尔属性编辑器';
  SCnAlignPropEditorName: string = 'Align属性编辑器';
  SCnSetPropEditorName: string = '集合属性编辑器';
  SCnNamePropEditorName: string = '组件名属性编辑器';

  // 编辑器说明
  SCnStringPropEditorComment: string = '允许编辑多行文本的字符串和标题属性。';
  sCnHintPropEditorComment: string = '允许编辑多行文本的 Hint 属性，支持长格式和短格式。';
  SCnStringsPropEditorComment: string = '提供更多功能的字符串列表属性编辑器。';
  SCnFileNamePropEditorComment: string = '可以使用打开文件对话框来选择文件名。';
  SCnSizeConstraintsPropEditorComment: string = '可以方便地设置控件或窗体的最大、最小尺寸。';
  SCnFontPropEditorComment: string = '增强的字体属性编辑器，可以显示更多的字体信息。';
  SCnControlScrollBarPropEditorComment: string = '增强的控件滚动条属性编辑器，可以显示更多的信息。';
  SCnBooleanPropEditorComment: string = '可以为布尔属性显示一个检查框。';
  SCnAlignPropEditorComment: string = '可以为Align属性增加图标';
  SCnSetPropEditorComment: string = '为集合属性增加下拉列表设置及直接输入集合值的功能。';
  SCnNamePropEditorComment: string = '使用组件前缀标准来规范组件名称。';

  // TCnMultiLineEditorForm
  SCnPropEditorNoMatch: string = '没有发现匹配的字符串！';
  SCnPropEditorReplaceOK: string = '替换完成，一共进行了%D处替换。';
  SCnPropEditorCursorPos: string = '光标：[%D:%D]';
  SCnPropEditorSaveText: string = '当前文本未保存，要保存吗？';


  // TCnSizeConstraintsEditorForm
  SCnSizeConsInputError: string = '您必须输入有效的整数！';
  SCnSizeConsInputNeg: string = '您不能输入负数！';

  // TCnNamePropEditor
  SCnPrefixWizardNotExist: string = '组件前缀专家没有找到，请开启该专家！';

implementation

end.
