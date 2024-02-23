{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnWizTranslate;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：资源字符串定义单元
* 单元作者：CnPack开发组
* 备    注：该单元对 CnWizards 用到的资源字符串进行翻译
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.08.26 V1.0
*               LiuXiao: 创建单元并陆续更新
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows,
  CnCommon, CnLangMgr, CnConsts, CnWizConsts, CnDesignEditorConsts;

procedure CnTranslateConsts(Sender: TObject);
{* 根据当前语言号翻译字符串变量 }

implementation

procedure CnTranslateAuthorInfo;
begin
  TranslateStr(SCnPack_Zjy, 'SCnPack_Zjy');
  TranslateStr(SCnPack_Shenloqi, 'SCnPack_Shenloqi');
  TranslateStr(SCnPack_xiaolv, 'SCnPack_xiaolv');
  TranslateStr(SCnPack_Flier, 'SCnPack_Flier');
  TranslateStr(SCnPack_LiuXiao, 'SCnPack_LiuXiao');
  TranslateStr(SCnPack_PanYing, 'SCnPack_PanYing');
  TranslateStr(SCnPack_Hubdog, 'SCnPack_Hubdog');
  TranslateStr(SCnPack_Wyb_star, 'SCnPack_Wyb_star');
  TranslateStr(SCnPack_Licwing, 'SCnPack_Licwing');
  TranslateStr(SCnPack_Alan, 'SCnPack_Alan');
  TranslateStr(SCnPack_Aimingoo, 'SCnPack_Aimingoo');
  TranslateStr(SCnPack_QSoft, 'SCnPack_QSoft');
  TranslateStr(SCnPack_SQuall, 'SCnPack_SQuall');
  TranslateStr(SCnPack_Hhha, 'SCnPack_Hhha');
  TranslateStr(SCnPack_Beta, 'SCnPack_Beta');
  TranslateStr(SCnPack_Leeon, 'SCnPack_Leeon');
  TranslateStr(SCnPack_SuperYoyoNc, 'SCnPack_SuperYoyoNc');
  TranslateStr(SCnPack_DragonPC, 'SCnPack_DragonPC');
  TranslateStr(SCnPack_Kendling, 'SCnPack_Kendling');
  TranslateStr(SCnPack_ccRun, 'SCnPack_ccRun');
  TranslateStr(SCnPack_Dingbaosheng, 'SCnPack_Dingbaosheng');
  TranslateStr(SCnPack_LuXiaoban, 'SCnPack_LuXiaoban');
  TranslateStr(SCnPack_Savetime, 'SCnPack_Savetime');
  TranslateStr(SCnPack_solokey, 'SCnPack_solokey');
  TranslateStr(SCnPack_Bahamut, 'SCnPack_Bahamut');
  TranslateStr(SCnPack_Sesame, 'SCnPack_Sesame');
  TranslateStr(SCnPack_BuDeXian, 'SCnPack_BuDeXian');
  TranslateStr(SCnPack_XiaoXia, 'SCnPack_XiaoXia');
  TranslateStr(SCnPack_ZiMin, 'SCnPack_ZiMin');
  TranslateStr(SCnPack_rarnu, 'SCnPack_rarnu');
  TranslateStr(SCnPack_dejoy, 'SCnPack_dejoy');
end;

procedure CnTranslateDesignConsts;
begin
  //----------------------------------------------------------------------------
  //  Design Editors
  //----------------------------------------------------------------------------

  // Design Editors Name
  TranslateStr(SCnPropertyEditor, 'SCnPropertyEditor');
  TranslateStr(SCnComponentEditor, 'SCnComponentEditor');
  TranslateStr(SCnDesignEditorNameStr, 'SCnDesignEditorNameStr');
  TranslateStr(SCnDesignEditorStateStr, 'SCnDesignEditorStateStr');
  TranslateStr(SCnPropEditorConfigFormCaption, 'SCnPropEditorConfigFormCaption');
  TranslateStr(SCnCompEditorCustomizeCaption, 'SCnCompEditorCustomizeCaption');
  TranslateStr(SCnCompEditorCustomizeCaption1, 'SCnCompEditorCustomizeCaption1');
  TranslateStr(SCnCompEditorCustomizeDesc, 'SCnCompEditorCustomizeDesc');

  // Editors Name
  TranslateStr(SCnStringPropEditorName, 'SCnStringPropEditorName');
  TranslateStr(SCnHintPropEditorName, 'sCnHintPropEditorName');
  TranslateStr(SCnStringsPropEditorName, 'SCnStringsPropEditorName');
  TranslateStr(SCnFileNamePropEditorName, 'SCnFileNamePropEditorName');
  TranslateStr(SCnSizeConstraintsPropEditorName, 'SCnSizeConstraintsPropEditorName');
  TranslateStr(SCnFontPropEditorName, 'SCnFontPropEditorName');
  TranslateStr(SCnControlScrollBarPropEditorName, 'SCnControlScrollBarPropEditorName');
  TranslateStr(SCnBooleanPropEditorName, 'SCnBooleanPropEditorName');
  TranslateStr(SCnAlignPropEditorName, 'SCnAlignPropEditorName');
  TranslateStr(SCnSetPropEditorName, 'SCnSetPropEditorName');
  TranslateStr(SCnNamePropEditorName, 'SCnNamePropEditorName');
  TranslateStr(SCnImageListCompEditorName, 'SCnImageListCompEditorName');

  // Editors Comment
  TranslateStr(SCnStringPropEditorComment, 'SCnStringPropEditorComment');
  TranslateStr(SCnHintPropEditorComment, 'sCnHintPropEditorComment');
  TranslateStr(SCnStringsPropEditorComment, 'SCnStringsPropEditorComment');
  TranslateStr(SCnFileNamePropEditorComment, 'SCnFileNamePropEditorComment');
  TranslateStr(SCnSizeConstraintsPropEditorComment, 'SCnSizeConstraintsPropEditorComment');
  TranslateStr(SCnFontPropEditorComment, 'SCnFontPropEditorComment');
  TranslateStr(SCnControlScrollBarPropEditorComment, 'SCnControlScrollBarPropEditorComment');
  TranslateStr(SCnBooleanPropEditorComment, 'SCnBooleanPropEditorComment');
  TranslateStr(SCnAlignPropEditorComment, 'SCnAlignPropEditorComment');
  TranslateStr(SCnSetPropEditorComment, 'SCnSetPropEditorComment');
  TranslateStr(SCnNamePropEditorComment, 'SCnNamePropEditorComment');
  TranslateStr(SCnImageListCompEditorComment, 'SCnImageListCompEditorComment');

  // TCnMultiLineEditorForm
  TranslateStr(SCnPropEditorNoMatch, 'SCnPropEditorNoMatch');
  TranslateStr(SCnPropEditorReplaceOK, 'SCnPropEditorReplaceOK');
  TranslateStr(SCnPropEditorCursorPos, 'SCnPropEditorCursorPos');
  TranslateStr(SCnPropEditorSaveText, 'SCnPropEditorSaveText');

  // TCnSizeConstraintsEditorForm
  TranslateStr(SCnSizeConsInputError, 'SCnSizeConsInputError');
  TranslateStr(SCnSizeConsInputNeg, 'SCnSizeConsInputNeg');

  // TCnNamePropEditor
  TranslateStr(SCnPrefixWizardNotExist, 'SCnPrefixWizardNotExist');

  // TCnImageListEditor
  TranslateStr(SCnImageListChangeSize, 'SCnImageListChangeSize');
  TranslateStr(SCnImageListChangeXPStyle, 'SCnImageListChangeXPStyle');
  TranslateStr(SCnImageListSearchFailed, 'SCnImageListSearchFailed');
  TranslateStr(SCnImageListInvalidFile, 'SCnImageListInvalidFile');
  TranslateStr(SCnImageListSepBmp, 'SCnImageListSepBmp');
  TranslateStr(SCnImageListNoPngLib, 'SCnImageListNoPngLib');
  TranslateStr(SCnImageListExportFailed, 'SCnImageListExportFailed');
  TranslateStr(SCnImageListXPStyleNotSupport, 'SCnImageListXPStyleNotSupport');
  TranslateStr(SCnImageListSearchIconsetFailed, 'SCnImageListSearchIconsetFailed');
  TranslateStr(SCnImageListGotoPage, 'SCnImageListGotoPage');
  TranslateStr(SCnImageListGotoPagePrompt, 'SCnImageListGotoPagePrompt');
end;

procedure CnTranslateWizards;
begin
  //----------------------------------------------------------------------------
  //  Wizards
  //----------------------------------------------------------------------------

  // Common
  TranslateStr(SCnSaveDlgTxtFilter, 'SCnSaveDlgTxtFilter');
  TranslateStr(SCnSaveDlgTitle, 'SCnSaveDlgTitle');
  TranslateStr(SCnOverwriteQuery, 'SCnOverwriteQuery');
  TranslateStr(SCnDeleteConfirm, 'SCnDeleteConfirm');
  TranslateStr(SCnClearConfirm, 'SCnClearConfirm');
  TranslateStr(SCnDefaultConfirm, 'SCnDefaultConfirm');
  TranslateStr(SCnNoHelpofThisLang, 'SCnNoHelpofThisLang');
  TranslateStr(SCnOnlineHelp, 'SCnOnlineHelp');
  TranslateStr(SCnImportAppend, 'SCnImportAppend');
  TranslateStr(SCnImportError, 'SCnImportError');
  TranslateStr(SCnExportError, 'SCnExportError');
  TranslateStr(SCnUnknownNameResult, 'SCnUnknownNameResult');
  TranslateStr(SCnNoneResult, 'SCnNoneResult');
  TranslateStr(SCnInputFile, 'SCnInputFile');
  TranslateStr(SCnDoublePasswordError, 'SCnDoublePasswordError');
  TranslateStr(SCnMoreMenu, 'SCnMoreMenu');
  TranslateStr(SCnCountFmt, 'SCnCountFmt');

  // CnWizUpgrade
  TranslateStr(SCnWizNoUpgrade, 'SCnWizNoUpgrade');
  TranslateStr(SCnWizUpgradeFail, 'SCnWizUpgradeFail');
  TranslateStr(SCnWizUpgradeCommentName, 'SCnWizUpgradeCommentName');

  // CheckIDEVersion
  TranslateStr(SCnIDENOTLatest, 'SCnIDENOTLatest');

  // CnWizUtils
  TranslateStr(SCnWizardForPasOrDprOnly, 'SCnWizardForPasOrDprOnly');
  TranslateStr(SCnWizardForPasOrIncOnly, 'SCnWizardForPasOrIncOnly');
  TranslateStr(SCnWizardForDprOrPasOrIncOnly, 'SCnWizardForDprOrPasOrIncOnly');

  // CnShortcut
  TranslateStr(SCnDuplicateShortCutName, 'SCnDuplicateShortCutName');

  // CnMenuAction
  TranslateStr(SCnDuplicateCommand, 'SCnDuplicateCommand');
  TranslateStr(SCnWizSubActionShortCutFormCaption, 'SCnWizSubActionShortCutFormCaption');

  // CnWizConfigForm
  TranslateStr(SCnWizConfigCaption, 'SCnWizConfigCaption');
  TranslateStr(SCnWizConfigHint, 'SCnWizConfigHint');
  TranslateStr(SCnProjectWizardName, 'SCnProjectWizardName');
  TranslateStr(SCnFormWizardName, 'SCnFormWizardName');
  TranslateStr(SCnUnitWizardName, 'SCnUnitWizardName');
  TranslateStr(SCnRepositoryWizardName, 'SCnRepositoryWizardName');
  TranslateStr(SCnMenuWizardName, 'SCnMenuWizardName');
  TranslateStr(SCnSubMenuWizardName, 'SCnSubMenuWizardName');
  TranslateStr(SCnActionWizardName, 'SCnActionWizardName');
  TranslateStr(SCnIDEEnhanceWizardName, 'SCnIDEEnhanceWizardName');
  TranslateStr(SCnBaseWizardName, 'SCnBaseWizardName');
  TranslateStr(SCnWizardNameStr, 'SCnWizardNameStr');
  TranslateStr(SCnWizardShortCutStr, 'SCnWizardShortCutStr');
  TranslateStr(SCnWizardStateStr, 'SCnWizardStateStr');
  TranslateStr(SCnWizardActiveStr, 'SCnWizardActiveStr');
  TranslateStr(SCnWizardDisActiveStr, 'SCnWizardDisActiveStr');
  TranslateStr(SCnWizCommentReseted, 'SCnWizCommentReseted');

  TranslateStr(SCnSelectDir, 'SCnSelectDir');
  TranslateStr(SCnQueryAbort, 'SCnQueryAbort');

  TranslateStr(SCnExportPCDirCaption, 'SCnExportPCDirCaption');
  TranslateStr(SCnExportPCSucc, 'SCnExportPCSucc');
  TranslateStr(SCnConfirmResetSetting, 'SCnConfirmResetSetting');
  TranslateStr(SCnSettingsReset, 'SCnSettingsReset');

  // CnWizAbout
  TranslateStr(SCnConfigIONotExists, 'SCnConfigIONotExists');

  // CnMessageBoxWizard
  TranslateStr(SCnMsgBoxMenuCaption, 'SCnMsgBoxMenuCaption');
  TranslateStr(SCnMsgBoxMenuHint, 'SCnMsgBoxMenuHint');
  TranslateStr(SCnMsgBoxName, 'SCnMsgBoxName');
  TranslateStr(SCnMsgBoxComment, 'SCnMsgBoxComment');
  TranslateStr(SCnMsgBoxProjectCaption, 'SCnMsgBoxProjectCaption');
  TranslateStr(SCnMsgBoxProjectPrompt, 'SCnMsgBoxProjectPrompt');
  TranslateStr(SCnMsgBoxProjectDefaultName, 'SCnMsgBoxProjectDefaultName');
  TranslateStr(SCnMsgBoxProjectExists, 'SCnMsgBoxProjectExists');
  TranslateStr(SCnMsgBoxDeleteProject, 'SCnMsgBoxDeleteProject');
  TranslateStr(SCnMsgBoxCannotDelLastProject, 'SCnMsgBoxCannotDelLastProject');

  // CnComponentSelector
  TranslateStr(SCnCompSelectorMenuCaption, 'SCnCompSelectorMenuCaption');
  TranslateStr(SCnCompSelectorMenuHint, 'SCnCompSelectorMenuHint');
  TranslateStr(SCnCompSelectorName, 'SCnCompSelectorName');
  TranslateStr(SCnCompSelectorComment, 'SCnCompSelectorComment');
  TranslateStr(SCnCompSelectorNotSupport, 'SCnCompSelectorNotSupport');

  // CnTabOrderWizard
  TranslateStr(SCnTabOrderMenuCaption, 'SCnTabOrderMenuCaption');
  TranslateStr(SCnTabOrderMenuHint, 'SCnTabOrderMenuHint');
  TranslateStr(SCnTabOrderName, 'SCnTabOrderName');
  TranslateStr(SCnTabOrderComment, 'SCnTabOrderComment');
  TranslateStr(SCnTabOrderSetCurrControlCaption, 'SCnTabOrderSetCurrControlCaption');
  TranslateStr(SCnTabOrderSetCurrControlHint, 'SCnTabOrderSetCurrControlHint');
  TranslateStr(SCnTabOrderSetCurrFormCaption, 'SCnTabOrderSetCurrFormCaption');
  TranslateStr(SCnTabOrderSetCurrFormHint, 'SCnTabOrderSetCurrFormHint');
  TranslateStr(SCnTabOrderSetOpenedFormCaption, 'SCnTabOrderSetOpenedFormCaption');
  TranslateStr(SCnTabOrderSetOpenedFormHint, 'SCnTabOrderSetOpenedFormHint');
  TranslateStr(SCnTabOrderSetProjectCaption, 'SCnTabOrderSetProjectCaption');
  TranslateStr(SCnTabOrderSetProjectHint, 'SCnTabOrderSetProjectHint');
  TranslateStr(SCnTabOrderSetProjectGroupCaption, 'SCnTabOrderSetProjectGroupCaption');
  TranslateStr(SCnTabOrderSetProjectGroupHint, 'SCnTabOrderSetProjectGroupHint');
  TranslateStr(SCnTabOrderDispTabOrderCaption, 'SCnTabOrderDispTabOrderCaption');
  TranslateStr(SCnTabOrderDispTabOrderHint, 'SCnTabOrderDispTabOrderHint');
  TranslateStr(SCnTabOrderAutoResetCaption, 'SCnTabOrderAutoResetCaption');
  TranslateStr(SCnTabOrderAutoResetHint, 'SCnTabOrderAutoResetHint');
  TranslateStr(SCnTabOrderConfigCaption, 'SCnTabOrderConfigCaption');
  TranslateStr(SCnTabOrderConfigHint, 'SCnTabOrderConfigHint');
  TranslateStr(SCnTabOrderSucc, 'SCnTabOrderSucc');
  TranslateStr(SCnTabOrderFail, 'SCnTabOrderFail');

  // CnDfm6To5Wizard
  TranslateStr(SCnDfm6To5WizardMenuCaption, 'SCnDfm6To5WizardMenuCaption');
  TranslateStr(SCnDfm6To5WizardMenuHint, 'SCnDfm6To5WizardMenuHint');
  TranslateStr(SCnDfm6To5WizardName, 'SCnDfm6To5WizardName');
  TranslateStr(SCnDfm6To5WizardComment, 'SCnDfm6To5WizardComment');
  TranslateStr(SCnDfm6To5OpenError, 'SCnDfm6To5OpenError');
  TranslateStr(SCnDfm6To5SaveError, 'SCnDfm6To5SaveError');
  TranslateStr(SCnDfm6To5InvalidFormat, 'SCnDfm6To5InvalidFormat');

  // CnBookmarkWizard
  TranslateStr(SCnBookmarkWizardMenuCaption, 'SCnBookmarkWizardMenuCaption');
  TranslateStr(SCnBookmarkWizardMenuHint, 'SCnBookmarkWizardMenuHint');
  TranslateStr(SCnBookmarkWizardName, 'SCnBookmarkWizardName');
  TranslateStr(SCnBookmarkWizardComment, 'SCnBookmarkWizardComment');
  TranslateStr(SCnBookmarkAllUnit, 'SCnBookmarkAllUnit');
  TranslateStr(SCnBookmarkCurrentUnit, 'SCnBookmarkCurrentUnit');
  TranslateStr(SCnBookmarkFileCount, 'SCnBookmarkFileCount');

  // CnCodingToolsetWizard
  TranslateStr(SCnCodingToolsetWizardMenuCaption, 'SCnCodingToolsetWizardMenuCaption');
  TranslateStr(SCnCodingToolsetWizardMenuHint, 'SCnCodingToolsetWizardMenuHint');
  TranslateStr(SCnCodingToolsetWizardName, 'SCnCodingToolsetWizardName');
  TranslateStr(SCnCodingToolsetWizardComment, 'SCnCodingToolsetWizardComment');
  TranslateStr(SCnCodingToolsetWizardConfigCaption, 'SCnCodingToolsetWizardConfigCaption');
  TranslateStr(SCnCodingToolsetWizardConfigHint, 'SCnCodingToolsetWizardConfigHint');

  // CnEditorCodeTool
  TranslateStr(SCnEditorCodeToolSelIsEmpty, 'SCnEditorCodeToolSelIsEmpty');
  TranslateStr(SCnEditorCodeToolNoLine, 'SCnEditorCodeToolNoLine');

  // CnEditorCodeSwap
  TranslateStr(SCnEditorCodeSwapMenuCaption, 'SCnEditorCodeSwapMenuCaption');
  TranslateStr(SCnEditorCodeSwapName, 'SCnEditorCodeSwapName');
  TranslateStr(SCnEditorCodeSwapMenuHint, 'SCnEditorCodeSwapMenuHint');

  // CnEditorCodeToString
  TranslateStr(SCnEditorCodeToStringMenuCaption, 'SCnEditorCodeToStringMenuCaption');
  TranslateStr(SCnEditorCodeToStringName, 'SCnEditorCodeToStringName');
  TranslateStr(SCnEditorCodeToStringMenuHint, 'SCnEditorCodeToStringMenuHint');

   // CnEditorExtractString
  TranslateStr(SCnEditorExtractStringMenuCaption, 'SCnEditorExtractStringMenuCaption');
  TranslateStr(SCnEditorExtractStringName, 'SCnEditorExtractStringName');
  TranslateStr(SCnEditorExtractStringMenuHint, 'SCnEditorExtractStringMenuHint');
  TranslateStr(SCnEditorExtractStringNotFound, 'SCnEditorExtractStringNotFound');
  TranslateStr(SCnEditorExtractStringCopiedFmt, 'SCnEditorExtractStringCopiedFmt');
  TranslateStr(SCnEditorExtractStringAskReplace, 'SCnEditorExtractStringAskReplace');
  TranslateStr(SCnEditorExtractStringChangeName, 'SCnEditorExtractStringChangeName');
  TranslateStr(SCnEditorExtractStringEnterNewName, 'SCnEditorExtractStringEnterNewName');
  TranslateStr(SCnEditorExtractStringDuplicatedName, 'SCnEditorExtractStringDuplicatedName');
  TranslateStr(SCnEditorExtractStringReplacedFmt, 'SCnEditorExtractStringReplacedFmt');

  // CnEditorCodeDelBlank
  TranslateStr(SCnEditorCodeDelBlankMenuCaption, 'SCnEditorCodeDelBlankMenuCaption');
  TranslateStr(SCnEditorCodeDelBlankName, 'SCnEditorCodeDelBlankName');
  TranslateStr(SCnEditorCodeDelBlankMenuHint, 'SCnEditorCodeDelBlankMenuHint');

  // CnEditorOpenFile
  TranslateStr(SCnEditorOpenFileMenuCaption, 'SCnEditorOpenFileMenuCaption');
  TranslateStr(SCnEditorOpenFileName, 'SCnEditorOpenFileName');
  TranslateStr(SCnEditorOpenFileMenuHint, 'SCnEditorOpenFileMenuHint');
  TranslateStr(SCnEditorOpenFileDlgCaption, 'SCnEditorOpenFileDlgCaption');
  TranslateStr(SCnEditorOpenFileDlgHint, 'SCnEditorOpenFileDlgHint');
  TranslateStr(SCnEditorOpenFileNotFound, 'SCnEditorOpenFileNotFound');

  // CnEditorZoomFullScreen
  TranslateStr(SCnEditorZoomFullScreenMenuCaption, 'SCnEditorZoomFullScreenMenuCaption');
  TranslateStr(SCnEditorZoomFullScreenMenuHint, 'SCnEditorZoomFullScreenMenuHint');
  TranslateStr(SCnEditorZoomFullScreen, 'SCnEditorZoomFullScreen');
  TranslateStr(SCnEditorZoomFullScreenNoEditor, 'SCnEditorZoomFullScreenNoEditor');

  // CnEditorCodeComment
  TranslateStr(SCnEditorCodeCommentMenuCaption, 'SCnEditorCodeCommentMenuCaption');
  TranslateStr(SCnEditorCodeCommentMenuHint, 'SCnEditorCodeCommentMenuHint');
  TranslateStr(SCnEditorCodeCommentName, 'SCnEditorCodeCommentName');

  // CnEditorCodeUnComment
  TranslateStr(SCnEditorCodeUnCommentMenuCaption, 'SCnEditorCodeUnCommentMenuCaption');
  TranslateStr(SCnEditorCodeUnCommentMenuHint, 'SCnEditorCodeUnCommentMenuHint');
  TranslateStr(SCnEditorCodeUnCommentName, 'SCnEditorCodeUnCommentName');

  // CnEditorCodeToggleComment
  TranslateStr(SCnEditorCodeToggleCommentMenuCaption, 'SCnEditorCodeToggleCommentMenuCaption');
  TranslateStr(SCnEditorCodeToggleCommentMenuHint, 'SCnEditorCodeToggleCommentMenuHint');
  TranslateStr(SCnEditorCodeToggleCommentName, 'SCnEditorCodeToggleCommentName');

  // CnEditorCodeIndent
  TranslateStr(SCnEditorCodeIndentMenuCaption, 'SCnEditorCodeIndentMenuCaption');
  TranslateStr(SCnEditorCodeIndentMenuHint, 'SCnEditorCodeIndentMenuHint');
  TranslateStr(SCnEditorCodeIndentName, 'SCnEditorCodeIndentName');

  // CnEditorCodeUnIndent
  TranslateStr(SCnEditorCodeUnIndentMenuCaption, 'SCnEditorCodeUnIndentMenuCaption');
  TranslateStr(SCnEditorCodeUnIndentMenuHint, 'SCnEditorCodeUnIndentMenuHint');
  TranslateStr(SCnEditorCodeUnIndentName, 'SCnEditorCodeUnIndentName');

  // CnAsciiChart
  TranslateStr(SCnAsciiChartMenuCaption, 'SCnAsciiChartMenuCaption');
  TranslateStr(SCnAsciiChartMenuHint, 'SCnAsciiChartMenuHint');
  TranslateStr(SCnAsciiChartName, 'SCnAsciiChartName');

  // CnEditorInsertColor
  TranslateStr(SCnEditorInsertTimeMenuCaption, 'SCnEditorInsertTimeMenuCaption');
  TranslateStr(SCnEditorInsertTimeMenuHint, 'SCnEditorInsertTimeMenuHint');
  TranslateStr(SCnEditorInsertTimeName, 'SCnEditorInsertTimeName');

  // CnEditorInsertColor
  TranslateStr(SCnEditorInsertColorMenuCaption, 'SCnEditorInsertColorMenuCaption');
  TranslateStr(SCnEditorInsertColorMenuHint, 'SCnEditorInsertColorMenuHint');
  TranslateStr(SCnEditorInsertColorName, 'SCnEditorInsertColorName');

  // CnEditorCollector
  TranslateStr(SCnEditorCollectorMenuCaption, 'SCnEditorCollectorMenuCaption');
  TranslateStr(SCnEditorCollectorMenuHint, 'SCnEditorCollectorMenuHint');
  TranslateStr(SCnEditorCollectorName, 'SCnEditorCollectorName');
  TranslateStr(SCnEditorCollectorInputCaption, 'SCnEditorCollectorInputCaption');

  // CnEditorSortLines
  TranslateStr(SCnEditorSortLinesMenuCaption, 'SCnEditorSortLinesMenuCaption');
  TranslateStr(SCnEditorSortLinesMenuHint, 'SCnEditorSortLinesMenuHint');
  TranslateStr(SCnEditorSortLinesName, 'SCnEditorSortLinesName');

  // CnEditorToggleVar
  TranslateStr(SCnEditorToggleVarMenuCaption, 'SCnEditorToggleVarMenuCaption');
  TranslateStr(SCnEditorToggleVarMenuHint, 'SCnEditorToggleVarMenuHint');
  TranslateStr(SCnEditorToggleVarName, 'SCnEditorToggleVarName');

  // CnEditorToggleUses
  TranslateStr(SCnEditorToggleUsesMenuCaption, 'SCnEditorToggleUsesMenuCaption');
  TranslateStr(SCnEditorToggleUsesMenuHint, 'SCnEditorToggleUsesMenuHint');
  TranslateStr(SCnEditorToggleUsesName, 'SCnEditorToggleUsesName');

  // CnEditorPrevMessage
  TranslateStr(SCnEditorPrevMessageMenuCaption, 'SCnEditorPrevMessageMenuCaption');
  TranslateStr(SCnEditorPrevMessageMenuHint, 'SCnEditorPrevMessageMenuHint');
  TranslateStr(SCnEditorPrevMessageName, 'SCnEditorPrevMessageName');

  // CnEditorJumpMessage
  TranslateStr(SCnEditorNextMessageMenuCaption, 'SCnEditorNextMessageMenuCaption');
  TranslateStr(SCnEditorNextMessageMenuHint, 'SCnEditorNextMessageMenuHint');
  TranslateStr(SCnEditorNextMessageName, 'SCnEditorNextMessageName');

  // CnEditorJumpIntf
  TranslateStr(SCnEditorJumpIntfMenuCaption, 'SCnEditorJumpIntfMenuCaption');
  TranslateStr(SCnEditorJumpIntfMenuHint, 'SCnEditorJumpIntfMenuHint');
  TranslateStr(SCnEditorJumpIntfName, 'SCnEditorJumpIntfName');

  // CnEditorJumpImpl
  TranslateStr(SCnEditorJumpImplMenuCaption, 'SCnEditorJumpImplMenuCaption');
  TranslateStr(SCnEditorJumpImplMenuHint, 'SCnEditorJumpImplMenuHint');
  TranslateStr(SCnEditorJumpImplName, 'SCnEditorJumpImplName');

  // CnEditorJumpMatchedKeyword
  TranslateStr(SCnEditorJumpMatchedKeywordMenuCaption, 'SCnEditorJumpMatchedKeywordMenuCaption');
  TranslateStr(SCnEditorJumpMatchedKeywordMenuHint, 'SCnEditorJumpMatchedKeywordMenuHint');
  TranslateStr(SCnEditorJumpMatchedKeywordName, 'SCnEditorJumpMatchedKeywordName');

  // CnEditorJumpPrevIdent
  TranslateStr(SCnEditorJumpPrevIdentMenuCaption, 'SCnEditorJumpPrevIdentMenuCaption');
  TranslateStr(SCnEditorJumpPrevIdentMenuHint, 'SCnEditorJumpPrevIdentMenuHint');
  TranslateStr(SCnEditorJumpPrevIdentName, 'SCnEditorJumpPrevIdentName');

  // CnEditorJumpNextIdent
  TranslateStr(SCnEditorJumpNextIdentMenuCaption, 'SCnEditorJumpNextIdentMenuCaption');
  TranslateStr(SCnEditorJumpNextIdentMenuHint, 'SCnEditorJumpNextIdentMenuHint');
  TranslateStr(SCnEditorJumpNextIdentName, 'SCnEditorJumpNextIdentName');

  // CnEditorJumpIDEInsight
  TranslateStr(SCnEditorJumpIDEInsightMenuCaption, 'SCnEditorJumpIDEInsightMenuCaption');
  TranslateStr(SCnEditorJumpIDEInsightMenuHint, 'SCnEditorJumpIDEInsightMenuHint');
  TranslateStr(SCnEditorJumpIDEInsightName, 'SCnEditorJumpIDEInsightName');

  // CnEditorFontInc
  TranslateStr(SCnEditorFontIncMenuCaption, 'SCnEditorFontIncMenuCaption');
  TranslateStr(SCnEditorFontIncMenuHint, 'SCnEditorFontIncMenuHint');
  TranslateStr(SCnEditorFontIncName, 'SCnEditorFontIncName');

  // CnEditorFontDec
  TranslateStr(SCnEditorFontDecMenuCaption, 'SCnEditorFontDecMenuCaption');
  TranslateStr(SCnEditorFontDecMenuHint, 'SCnEditorFontDecMenuHint');
  TranslateStr(SCnEditorFontDecName, 'SCnEditorFontDecName');

  // CnEditorExtendingSelect
  TranslateStr(SCnEditorExtendingSelectMenuCaption, 'SCnEditorExtendingSelectMenuCaption');
  TranslateStr(SCnEditorExtendingSelectMenuHint, 'SCnEditorExtendingSelectMenuHint');
  TranslateStr(SCnEditorExtendingSelectName, 'SCnEditorExtendingSelectName');

  // CnEditorDuplicateUnit
  TranslateStr(SCnEditorDuplicateUnitMenuCaption, 'SCnEditorDuplicateUnitMenuCaption');
  TranslateStr(SCnEditorDuplicateUnitMenuHint, 'SCnEditorDuplicateUnitMenuHint');
  TranslateStr(SCnEditorDuplicateUnitName, 'SCnEditorDuplicateUnitName');

  // CnSrcTemplate
  TranslateStr(SCnSrcTemplateMenuCaption, 'SCnSrcTemplateMenuCaption');
  TranslateStr(SCnSrcTemplateMenuHint, 'SCnSrcTemplateMenuHint');
  TranslateStr(SCnSrcTemplateName, 'SCnSrcTemplateName');
  TranslateStr(SCnSrcTemplateComment, 'SCnSrcTemplateComment');
  TranslateStr(SCnSrcTemplateConfigCaption, 'SCnSrcTemplateConfigCaption');
  TranslateStr(SCnSrcTemplateConfigHint, 'SCnSrcTemplateConfigHint');
  TranslateStr(SCnSrcTemplateInsertToProcCaption, 'SCnSrcTemplateInsertToProcCaption');
  TranslateStr(SCnSrcTemplateInsertToProcHint, 'SCnSrcTemplateInsertToProcHint');
  TranslateStr(SCnSrcTemplateInsertToProcPrompt, 'SCnSrcTemplateInsertToProcPrompt');
  TranslateStr(SCnSrcTemplateInsertToProcCountFmt, 'SCnSrcTemplateInsertToProcCountFmt');
  TranslateStr(SCnSrcTemplateCaptionIsEmpty, 'SCnSrcTemplateCaptionIsEmpty');
  TranslateStr(SCnSrcTemplateContentIsEmpty, 'SCnSrcTemplateContentIsEmpty');
  TranslateStr(SCnSrcTemplateSourceTypeNotSupport, 'SCnSrcTemplateSourceTypeNotSupport');
  TranslateStr(SCnSrcTemplateReadDataError, 'SCnSrcTemplateReadDataError');
  TranslateStr(SCnSrcTemplateWriteDataError, 'SCnSrcTemplateWriteDataError');
  TranslateStr(SCnSrcTemplateImportAppend, 'SCnSrcTemplateImportAppend');
  TranslateStr(SCnSrcTemplateWizardDelete, 'SCnSrcTemplateWizardDelete');
  TranslateStr(SCnSrcTemplateWizardClear, 'SCnSrcTemplateWizardClear');

  TranslateStr(SCnSrcTemplateDataDefName, 'SCnSrcTemplateDataDefName');
  TranslateStr(SCnSrcTemplateDataDefName_CB, 'SCnSrcTemplateDataDefName_CB');

  TranslateStr(SCnEIPCurrPos, 'SCnEIPCurrPos');
  TranslateStr(SCnEIPBOL, 'SCnEIPBOL');
  TranslateStr(SCnEIPEOL, 'SCnEIPEOL');
  TranslateStr(SCnEIPBOF, 'SCnEIPBOF');
  TranslateStr(SCnEIPEOF, 'SCnEIPEOF');
  TranslateStr(SCnEIPProcHead, 'SCnEIPProcHead');

  TranslateStr(SCnEMVProjectDir, 'SCnEMVProjectDir');
  TranslateStr(SCnEMVProjectName, 'SCnEMVProjectName');
  TranslateStr(SCnEMVProjectVersion, 'SCnEMVProjectVersion');
  TranslateStr(SCnEMVProjectGroupDir, 'SCnEMVProjectGroupDir');
  TranslateStr(SCnEMVProjectGroupName, 'SCnEMVProjectGroupName');
  TranslateStr(SCnEMVUnit, 'SCnEMVUnit');
  TranslateStr(SCnEMVUnitName, 'SCnEMVUnitName');
  TranslateStr(SCnEMVUnitPath, 'SCnEMVUnitPath');
  TranslateStr(SCnEMVProceName, 'SCnEMVProceName');
  TranslateStr(SCnEMVResult, 'SCnEMVResult');
  TranslateStr(SCnEMVArguments, 'SCnEMVArguments');
  TranslateStr(SCnEMVArgList, 'SCnEMVArgList');
  TranslateStr(SCnEMVRetType, 'SCnEMVRetType');
  TranslateStr(SCnEMVCurProceName, 'SCnEMVCurProceName');
  TranslateStr(SCnEMVCurMethodName, 'SCnEMVCurMethodName');
  TranslateStr(SCnEMVCurClassName, 'SCnEMVCurClassName');
  TranslateStr(SCnEMVUser, 'SCnEMVUser');
  TranslateStr(SCnEMVCurIDEName, 'SCnEMVCurIDEName');
  TranslateStr(SCnEMVDateTime, 'SCnEMVDateTime');
  TranslateStr(SCnEMVDate, 'SCnEMVDate');
  TranslateStr(SCnEMVYear, 'SCnEMVYear');
  TranslateStr(SCnEMVMonth, 'SCnEMVMonth');
  TranslateStr(SCnEMVMonthShortName, 'SCnEMVMonthShortName');
  TranslateStr(SCnEMVMonthLongName, 'SCnEMVMonthLongName');
  TranslateStr(SCnEMVDay, 'SCnEMVDay');
  TranslateStr(SCnEMVDayShortName, 'SCnEMVDayShortName');
  TranslateStr(SCnEMVDayLongName, 'SCnEMVDayLongName');
  TranslateStr(SCnEMVHour, 'SCnEMVHour');
  TranslateStr(SCnEMVMinute, 'SCnEMVMinute');
  TranslateStr(SCnEMVSecond, 'SCnEMVSecond');
  TranslateStr(SCnEMVCodeLines, 'SCnEMVCodeLines');
  TranslateStr(SCnEMVGUID, 'SCnEMVGUID');
  TranslateStr(SCnEMVColPos, 'SCnEMVColPos');
  TranslateStr(SCnEMVCursor, 'SCnEMVCursor');

  // CnMsdnWizard
  TranslateStr(SCnMsdnWizardName, 'SCnMsdnWizardName');
  TranslateStr(SCnMsdnWizardMenuCaption, 'SCnMsdnWizardMenuCaption');
  TranslateStr(SCnMsdnWizardMenuHint, 'SCnMsdnWizardMenuHint');
  TranslateStr(SCnMsdnWizardRunConfigCaption, 'SCnMsdnWizardRunConfigCaption');
  TranslateStr(SCnMsdnWizardRunConfigHint, 'SCnMsdnWizardRunConfigHint');
  TranslateStr(SCnMsdnWizardRunMsdnCaption, 'SCnMsdnWizardRunMsdnCaption');
  TranslateStr(SCnMsdnWizardRunMsdnHint, 'SCnMsdnWizardRunMsdnHint');
  TranslateStr(SCnMsdnWizardRunSearchCaption, 'SCnMsdnWizardRunSearchCaption');
  TranslateStr(SCnMsdnWizardRunSearchHint, 'SCnMsdnWizardRunSearchHint');
  TranslateStr(SCnMsdnWizardComment, 'SCnMsdnWizardComment');
  TranslateStr(SCnMsdnToolBarCaption, 'SCnMsdnToolBarCaption');
  TranslateStr(SCnMsdnSelectKeywordHint, 'SCnMsdnSelectKeywordHint');
  TranslateStr(SCnMsdnNoMsdnInstalled, 'SCnMsdnNoMsdnInstalled');
  TranslateStr(SCnMsdnNoLanguage, 'SCnMsdnNoLanguage');
  TranslateStr(SCnMsdnNoCollection, 'SCnMsdnNoCollection');
  TranslateStr(SCnMsdnRegError, 'SCnMsdnRegError');
  TranslateStr(SCnMsdnConnectToServerError, 'SCnMsdnConnectToServerError');
  TranslateStr(SCnMsdnDisconnectServerError, 'SCnMsdnDisconnectServerError');
  TranslateStr(SCnMsdnIsInvalidURL, 'SCnMsdnIsInvalidURL');
  TranslateStr(SCnMsdnShowKeywordFailed, 'SCnMsdnShowKeywordFailed');
  TranslateStr(SCnMsdnOpenIndexFailed, 'SCnMsdnOpenIndexFailed');
  TranslateStr(SCnMsdnOpenSearchFailed, 'SCnMsdnOpenSearchFailed');

  // CnPas2HtmlWizard
  TranslateStr(SCnPas2HtmlWizardMenuCaption, 'SCnPas2HtmlWizardMenuCaption');
  TranslateStr(SCnPas2HtmlWizardMenuHint, 'SCnPas2HtmlWizardMenuHint');
  TranslateStr(SCnPas2HtmlWizardName, 'SCnPas2HtmlWizardName');
  TranslateStr(SCnPas2HtmlWizardComment, 'SCnPas2HtmlWizardComment');

  TranslateStr(SCnPas2HtmlWizardCopySelectedCaption, 'SCnPas2HtmlWizardCopySelectedCaption');
  TranslateStr(SCnPas2HtmlWizardCopySelectedHint, 'SCnPas2HtmlWizardCopySelectedHint');

  TranslateStr(SCnPas2HtmlWizardExportUnitCaption, 'SCnPas2HtmlWizardExportUnitCaption');
  TranslateStr(SCnPas2HtmlWizardExportUnitHint, 'SCnPas2HtmlWizardExportUnitHint');

  TranslateStr(SCnPas2HtmlWizardExportOpenedCaption, 'SCnPas2HtmlWizardExportOpenedCaption');
  TranslateStr(SCnPas2HtmlWizardExportOpenedHint, 'SCnPas2HtmlWizardExportOpenedHint');

  TranslateStr(SCnPas2HtmlWizardExportDPRCaption, 'SCnPas2HtmlWizardExportDPRCaption');
  TranslateStr(SCnPas2HtmlWizardExportDPRHint, 'SCnPas2HtmlWizardExportDPRHint');

  TranslateStr(SCnPas2HtmlWizardExportBPGCaption, 'SCnPas2HtmlWizardExportBPGCaption');
  TranslateStr(SCnPas2HtmlWizardExportBPGHint, 'SCnPas2HtmlWizardExportBPGHint');

  TranslateStr(SCnPas2HtmlWizardConfigCaption, 'SCnPas2HtmlWizardConfigCaption');
  TranslateStr(SCnPas2HtmlWizardConfigHint, 'SCnPas2HtmlWizardConfigHint');

  TranslateStr(SCnSelectDirCaption, 'SCnSelectDirCaption');
  TranslateStr(SCnDispCaption, 'SCnDispCaption');
  TranslateStr(SCnPas2HtmlErrorNOTSupport, 'SCnPas2HtmlErrorNOTSupport');
  TranslateStr(SCnPas2HtmlErrorConvertProject, 'SCnPas2HtmlErrorConvertProject');
  TranslateStr(SCnPas2HtmlErrorConvert, 'SCnPas2HtmlErrorConvert');
  TranslateStr(SCnPas2HtmlDefEncode, 'SCnPas2HtmlDefEncode');

  // CnWizEditFiler
  TranslateStr(SCnFileDoesNotExist, 'SCnFileDoesNotExist');
  TranslateStr(SCnNoEditorInterface, 'SCnNoEditorInterface');
  TranslateStr(SCnNoModuleNotifier, 'SCnNoModuleNotifier');

  // CnReplaceWizard
  TranslateStr(SCnReplaceWizardMenuCaption, 'SCnReplaceWizardMenuCaption');
  TranslateStr(SCnReplaceWizardMenuHint, 'SCnReplaceWizardMenuHint');
  TranslateStr(SCnReplaceWizardName, 'SCnReplaceWizardName');
  TranslateStr(SCnReplaceWizardComment, 'SCnReplaceWizardComment');

  TranslateStr(SCnLineLengthError, 'SCnLineLengthError');
  TranslateStr(SCnClassNotTerminated, 'SCnClassNotTerminated');
  TranslateStr(SCnPatternTooLong, 'SCnPatternTooLong');
  TranslateStr(SCnInvalidGrepSearchCriteria, 'SCnInvalidGrepSearchCriteria');
  TranslateStr(SCnSenselessEscape, 'SCnSenselessEscape');

  TranslateStr(SCnReplaceSourceEmpty, 'SCnReplaceSourceEmpty');
  TranslateStr(SCnReplaceDirEmpty, 'SCnReplaceDirEmpty');
  TranslateStr(SCnReplaceDirNotExists, 'SCnReplaceDirNotExists');
  TranslateStr(SCnReplaceSelectDirCaption, 'SCnReplaceSelectDirCaption');

  TranslateStr(SCnSaveFileError, 'SCnSaveFileError');
  TranslateStr(SCnSaveEditFileError, 'SCnSaveEditFileError');
  TranslateStr(SCnReplaceWarning, 'SCnReplaceWarning');
  TranslateStr(SCnReplaceResult, 'SCnReplaceResult');
  TranslateStr(SCnReplaceQueryContinue, 'SCnReplaceQueryContinue');

  // CnSourceDiffWizard
  TranslateStr(SCnSourceDiffWizardMenuCaption, 'SCnSourceDiffWizardMenuCaption');
  TranslateStr(SCnSourceDiffWizardMenuHint, 'SCnSourceDiffWizardMenuHint');
  TranslateStr(SCnSourceDiffWizardName, 'SCnSourceDiffWizardName');
  TranslateStr(SCnSourceDiffWizardComment, 'SCnSourceDiffWizardComment');
  TranslateStr(SCnSourceDiffCaseIgnored, 'SCnSourceDiffCaseIgnored');
  TranslateStr(SCnSourceDiffBlanksIgnored, 'SCnSourceDiffBlanksIgnored');
  TranslateStr(SCnSourceDiffChanges, 'SCnSourceDiffChanges');
  TranslateStr(SCnSourceDiffApprox, 'SCnSourceDiffApprox');
  TranslateStr(SCnSourceDiffOpenError, 'SCnSourceDiffOpenError');
  TranslateStr(SCnSourceDiffOpenFile, 'SCnSourceDiffOpenFile');
  TranslateStr(SCnSourceDiffUpdateFile, 'SCnSourceDiffUpdateFile');
  TranslateStr(SCnDiskFile, 'SCnDiskFile');
  TranslateStr(SCnEditorBuff, 'SCnEditorBuff');
  TranslateStr(SCnBackupFile, 'SCnBackupFile');

  // CnStatWizard
  TranslateStr(SCnStatWizardMenuCaption, 'SCnStatWizardMenuCaption');
  TranslateStr(SCnStatWizardMenuHint, 'SCnStatWizardMenuHint');
  TranslateStr(SCnStatWizardName, 'SCnStatWizardName');
  TranslateStr(SCnStatWizardComment, 'SCnStatWizardComment');

  TranslateStr(SCnStatDirEmpty, 'SCnStatDirEmpty');
  TranslateStr(SCnStatDirNotExists, 'SCnStatDirNotExists');

  TranslateStr(SCnStatSelectDirCaption, 'SCnStatSelectDirCaption');
  TranslateStr(SCnStatusBarFmtString, 'SCnStatusBarFmtString');
  TranslateStr(SCnStatusBarFindFileFmt, 'SCnStatusBarFindFileFmt');
  TranslateStr(SCnStatClearResult, 'SCnStatClearResult');
  TranslateStr(SCnErrorNoFile, 'SCnErrorNoFile');
  TranslateStr(SCnErrorNoFind, 'SCnErrorNoFind');

  TranslateStr(SCnStatBytesFmtStr, 'SCnStatBytesFmtStr');
  TranslateStr(SCnStatLinesFmtStr, 'SCnStatLinesFmtStr');
  TranslateStr(SCnStatFilesCaption, 'SCnStatFilesCaption');
  TranslateStr(SCnStatProjectName, 'SCnStatProjectName');
  TranslateStr(SCnStatProjectFiles, 'SCnStatProjectFiles');
  TranslateStr(SCnStatProjectBytes, 'SCnStatProjectBytes');
  TranslateStr(SCnStatProjectLines1, 'SCnStatProjectLines1');
  TranslateStr(SCnStatProjectLines2, 'SCnStatProjectLines2');
  TranslateStr(SCnStatProjectGroupName, 'SCnStatProjectGroupName');
  TranslateStr(SCnStatProjectGroupFiles, 'SCnStatProjectGroupFiles');
  TranslateStr(SCnStatProjectGroupBytes, 'SCnStatProjectGroupBytes');
  TranslateStr(SCnStatProjectGroupLines1, 'SCnStatProjectGroupLines1');
  TranslateStr(SCnStatProjectGroupLines2, 'SCnStatProjectGroupLines2');
  TranslateStr(SCnStatNoProject, 'SCnStatNoProject');
  TranslateStr(SCnStatNoProjectGroup, 'SCnStatNoProjectGroup');

  TranslateStr(SCnStatExpTitle, 'SCnStatExpTitle');
  TranslateStr(SCnStatExpDefFileName, 'SCnStatExpDefFileName');
  TranslateStr(SCnStatExpProject, 'SCnStatExpProject');
  TranslateStr(SCnStatExpProjectGroup, 'SCnStatExpProjectGroup');
  TranslateStr(SCnStatExpFileName, 'SCnStatExpFileName');
  TranslateStr(SCnStatExpFileDir, 'SCnStatExpFileDir');
  TranslateStr(SCnStatExpFileBytes, 'SCnStatExpFileBytes');
  TranslateStr(SCnStatExpFileCodeBytes, 'SCnStatExpFileCodeBytes');
  TranslateStr(SCnStatExpFileCommentBytes, 'SCnStatExpFileCommentBytes');
  TranslateStr(SCnStatExpFileAllLines, 'SCnStatExpFileAllLines');
  TranslateStr(SCnStatExpFileEffectiveLines, 'SCnStatExpFileEffectiveLines');
  TranslateStr(SCnStatExpFileBlankLines, 'SCnStatExpFileBlankLines');
  TranslateStr(SCnStatExpFileCodeLines, 'SCnStatExpFileCodeLines');
  TranslateStr(SCnStatExpFileCommentLines, 'SCnStatExpFileCommentLines');
  TranslateStr(SCnStatExpFileCommentBlocks, 'SCnStatExpFileCommentBlocks');
  TranslateStr(SCnStatExpSeperator, 'SCnStatExpSeperator');

  TranslateStr(SCnStatExpCSVTitleFmt, 'SCnStatExpCSVTitleFmt');
  TranslateStr(SCnStatExpCSVLineFmt, 'SCnStatExpCSVLineFmt');
  TranslateStr(SCnStatExpCSVProject, 'SCnStatExpCSVProject');
  TranslateStr(SCnStatExpCSVProjectGroup, 'SCnStatExpCSVProjectGroup');
  TranslateStr(SCnStatExpCSVFileName, 'SCnStatExpCSVFileName');
  TranslateStr(SCnStatExpCSVFileDir, 'SCnStatExpCSVFileDir');
  TranslateStr(SCnStatExpCSVBytes, 'SCnStatExpCSVBytes');
  TranslateStr(SCnStatExpCSVCodeBytes, 'SCnStatExpCSVCodeBytes');
  TranslateStr(SCnStatExpCSVCommentBytes, 'SCnStatExpCSVCommentBytes');
  TranslateStr(SCnStatExpCSVAllLines, 'SCnStatExpCSVAllLines');
  TranslateStr(SCnStatExpCSVEffectiveLines, 'SCnStatExpCSVEffectiveLines');
  TranslateStr(SCnStatExpCSVBlankLines, 'SCnStatExpCSVBlankLines');
  TranslateStr(SCnStatExpCSVCodeLines, 'SCnStatExpCSVCodeLines');
  TranslateStr(SCnStatExpCSVCommentLines, 'SCnStatExpCSVCommentLines');
  TranslateStr(SCnStatExpCSVCommentBlocks, 'SCnStatExpCSVCommentBlocks');
  TranslateStr(SCnDoNotStat, 'SCnDoNotStat');

  // CnPrefixWizard
  TranslateStr(SCnPrefixWizardMenuCaption, 'SCnPrefixWizardMenuCaption');
  TranslateStr(SCnPrefixWizardMenuHint, 'SCnPrefixWizardMenuHint');
  TranslateStr(SCnPrefixWizardName, 'SCnPrefixWizardName');
  TranslateStr(SCnPrefixWizardComment, 'SCnPrefixWizardComment');
  TranslateStr(SCnPrefixInputError, 'SCnPrefixInputError');
  TranslateStr(SCnPrefixNameError, 'SCnPrefixNameError');
  TranslateStr(SCnPrefixDupName, 'SCnPrefixDupName');
  TranslateStr(SCnPrefixNoComp, 'SCnPrefixNoComp');
  TranslateStr(SCnPrefixAskToProcess, 'SCnPrefixAskToProcess');

  // CnWizAbout
  // CnWizAboutForm
  TranslateStr(SCnWizAboutCaption, 'SCnWizAboutCaption');
  TranslateStr(SCnWizAboutHelpCaption, 'SCnWizAboutHelpCaption');
  TranslateStr(SCnWizAboutHistoryCaption, 'SCnWizAboutHistoryCaption');
  TranslateStr(SCnWizAboutTipOfDaysCaption, 'SCnWizAboutTipOfDaysCaption');
  TranslateStr(SCnWizAboutBugReportCaption, 'SCnWizAboutBugReportCaption');
  TranslateStr(SCnWizAboutUpgradeCaption, 'SCnWizAboutUpgradeCaption');
  TranslateStr(SCnWizAboutConfigIOCaption, 'SCnWizAboutConfigIOCaption');
  TranslateStr(SCnWizAboutUrlCaption, 'SCnWizAboutUrlCaption');
  TranslateStr(SCnWizAboutBbsCaption, 'SCnWizAboutBbsCaption');
  TranslateStr(SCnWizAboutMailCaption, 'SCnWizAboutMailCaption');
  TranslateStr(SCnWizAboutDonateCaption, 'SCnWizAboutDonateCaption');
  TranslateStr(SCnWizAboutAboutCaption, 'SCnWizAboutAboutCaption');
  TranslateStr(SCnWizAboutHint, 'SCnWizAboutHint');
  TranslateStr(SCnWizAboutHelpHint, 'SCnWizAboutHelpHint');
  TranslateStr(SCnWizAboutHistoryHint, 'SCnWizAboutHistoryHint');
  TranslateStr(SCnWizAboutTipOfDayHint, 'SCnWizAboutTipOfDayHint');
  TranslateStr(SCnWizAboutBugReportHint, 'SCnWizAboutBugReportHint');
  TranslateStr(SCnWizAboutUpgradeHint, 'SCnWizAboutUpgradeHint');
  TranslateStr(SCnWizAboutConfigIOHint, 'SCnWizAboutConfigIOHint');
  TranslateStr(SCnWizAboutUrlHint, 'SCnWizAboutUrlHint');
  TranslateStr(SCnWizAboutBbsHint, 'SCnWizAboutBbsHint');
  TranslateStr(SCnWizAboutMailHint, 'SCnWizAboutMailHint');
  TranslateStr(SCnWizAboutDonateHint, 'SCnWizAboutDonateHint');
  TranslateStr(SCnWizAboutAboutHint, 'SCnWizAboutAboutHint');
  TranslateStr(SCnWizMailSubject, 'SCnWizMailSubject');

  // CnEditorEnhancements
  TranslateStr(SCnEditorEnhanceWizardName, 'SCnEditorEnhanceWizardName');
  TranslateStr(SCnEditorEnhanceWizardComment, 'SCnEditorEnhanceWizardComment');
  TranslateStr(SCnMenuCloseOtherPagesCaption, 'SCnMenuCloseOtherPagesCaption');
  TranslateStr(SCnMenuShellMenuCaption, 'SCnMenuShellMenuCaption');
  TranslateStr(SCnMenuSelAllCaption, 'SCnMenuSelAllCaption');
  TranslateStr(SCnMenuEnableThumbnailCaption, 'SCnMenuEnableThumbnailCaption');
  TranslateStr(SCnMenuBlockToolsCaption, 'SCnMenuBlockToolsCaption');
  TranslateStr(SCnMenuExploreCaption, 'SCnMenuExploreCaption');
  TranslateStr(SCnMenuCopyFileNameMenuCaption, 'SCnMenuCopyFileNameMenuCaption');
  TranslateStr(SCnEditorEnhanceConfig, 'SCnEditorEnhanceConfig');
  TranslateStr(SCnToolBarClose, 'SCnToolBarClose');
  TranslateStr(SCnToolBarCloseHint, 'SCnToolBarCloseHint');

  TranslateStr(SCnLineNumberGotoLine, 'SCnLineNumberGotoLine');
  TranslateStr(SCnLineNumberGotoBookMark, 'SCnLineNumberGotoBookMark');
  TranslateStr(SCnLineNumberClearBookMarks, 'SCnLineNumberClearBookMarks');
  TranslateStr(SCnLineNumberShowIDELineNum, 'SCnLineNumberShowIDELineNum');
  TranslateStr(SCnLineNumberClose, 'SCnLineNumberClose');

  TranslateStr(SCnSrcEditorNavIDEBack, 'SCnSrcEditorNavIDEBack');
  TranslateStr(SCnSrcEditorNavIDEForward, 'SCnSrcEditorNavIDEForward');
  TranslateStr(SCnSrcEditorNavIDEBackList, 'SCnSrcEditorNavIDEBackList');
  TranslateStr(SCnSrcEditorNavIDEForwardList, 'SCnSrcEditorNavIDEForwardList');
  TranslateStr(SCnSrcEditorNavPause, 'SCnSrcEditorNavPause');

  // CnSrcEditorBlockTools
  TranslateStr(SCnSrcBlockToolsHint, 'SCnSrcBlockToolsHint');

  TranslateStr(SCnSrcBlockEdit, 'SCnSrcBlockEdit');
  TranslateStr(SCnSrcBlockCopy, 'SCnSrcBlockCopy');
  TranslateStr(SCnSrcBlockCopyAppend, 'SCnSrcBlockCopyAppend');
  TranslateStr(SCnSrcBlockDuplicate, 'SCnSrcBlockDuplicate');
  TranslateStr(SCnSrcBlockCut, 'SCnSrcBlockCut');
  TranslateStr(SCnSrcBlockCutAppend, 'SCnSrcBlockCutAppend');
  TranslateStr(SCnSrcBlockDelete, 'SCnSrcBlockDelete');
  TranslateStr(SCnSrcBlockSaveToFile, 'SCnSrcBlockSaveToFile');

  TranslateStr(SCnSrcBlockCase, 'SCnSrcBlockCase');
  TranslateStr(SCnSrcBlockLowerCase, 'SCnSrcBlockLowerCase');
  TranslateStr(SCnSrcBlockUpperCase, 'SCnSrcBlockUpperCase');
  TranslateStr(SCnSrcBlockToggleCase, 'SCnSrcBlockToggleCase');

  TranslateStr(SCnSrcBlockFormat, 'SCnSrcBlockFormat');
  TranslateStr(SCnSrcBlockIndent, 'SCnSrcBlockIndent');
  TranslateStr(SCnSrcBlockIndentEx, 'SCnSrcBlockIndentEx');
  TranslateStr(SCnSrcBlockUnindent, 'SCnSrcBlockUnindent');
  TranslateStr(SCnSrcBlockUnindentEx, 'SCnSrcBlockUnindentEx');
  TranslateStr(SCnSrcBlockIndentCaption, 'SCnSrcBlockIndentCaption');
  TranslateStr(SCnSrcBlockIndentPrompt, 'SCnSrcBlockIndentPrompt');
  TranslateStr(SCnSrcBlockUnindentCaption, 'SCnSrcBlockUnindentCaption');
  TranslateStr(SCnSrcBlockUnindentPrompt, 'SCnSrcBlockUnindentPrompt');

  TranslateStr(SCnSrcBlockComment, 'SCnSrcBlockComment');
  TranslateStr(SCnSrcBlockWrap, 'SCnSrcBlockWrap');
  TranslateStr(SCnSrcBlockWrapBy, 'SCnSrcBlockWrapBy');
  TranslateStr(SCnSrcBlockReplace, 'SCnSrcBlockReplace');
  TranslateStr(SCnSrcBlockReplaceInBlock, 'SCnSrcBlockReplaceInBlock');
  TranslateStr(SCnSrcBlockSearch, 'SCnSrcBlockSearch');
  TranslateStr(SCnWebSearchFileDef, 'SCnWebSearchFileDef');
  TranslateStr(SCnSrcBlockMisc, 'SCnSrcBlockMisc');
  TranslateStr(SCnSrcBlockMoveUp, 'SCnSrcBlockMoveUp');
  TranslateStr(SCnSrcBlockMoveDown, 'SCnSrcBlockMoveDown');
  TranslateStr(SCnSrcBlockDeleteLines, 'SCnSrcBlockDeleteLines');
  TranslateStr(SCnSrcBlockDisableStructualHighlight, 'SCnSrcBlockDisableStructualHighlight');

  // CnSrcEditorKey
  TranslateStr(SCnRenameVarCaption, 'SCnRenameVarCaption');
  TranslateStr(SCnRenameVarHintFmt, 'SCnRenameVarHintFmt');
  TranslateStr(SCnRenameErrorValid, 'SCnRenameErrorValid');

  // CnFormEnhancements
  TranslateStr(SCnFormEnhanceWizardName, 'SCnFormEnhanceWizardName');
  TranslateStr(SCnFormEnhanceWizardComment, 'SCnFormEnhanceWizardComment');
  TranslateStr(SCnMenuFlatFormCustomizeCaption, 'SCnMenuFlatFormCustomizeCaption');
  TranslateStr(SCnMenuFlatFormConfigCaption, 'SCnMenuFlatFormConfigCaption');
  TranslateStr(SCnMenuFlagFormPosCaption, 'SCnMenuFlagFormPosCaption');
  TranslateStr(SCnMenuFlatPanelTopLeft, 'SCnMenuFlatPanelTopLeft');
  TranslateStr(SCnMenuFlatPanelTopRight, 'SCnMenuFlatPanelTopRight');
  TranslateStr(SCnMenuFlatPanelBottomLeft, 'SCnMenuFlatPanelBottomLeft');
  TranslateStr(SCnMenuFlatPanelBottomRight, 'SCnMenuFlatPanelBottomRight');
  TranslateStr(SCnMenuFlatPanelLeftTop, 'SCnMenuFlatPanelLeftTop');
  TranslateStr(SCnMenuFlatPanelLeftBottom, 'SCnMenuFlatPanelLeftBottom');
  TranslateStr(SCnMenuFlatPanelRightTop, 'SCnMenuFlatPanelRightTop');
  TranslateStr(SCnMenuFlatPanelRightBottom, 'SCnMenuFlatPanelRightBottom');
  TranslateStr(SCnMenuFlatFormAllowDragCaption, 'SCnMenuFlatFormAllowDragCaption');
  TranslateStr(SCnMenuFlagFormImportCaption, 'SCnMenuFlagFormImportCaption');
  TranslateStr(SCnMenuFlagFormExportCaption, 'SCnMenuFlagFormExportCaption');
  TranslateStr(SCnMenuFlatFormCloseCaption, 'SCnMenuFlatFormCloseCaption');
  TranslateStr(SCnMenuFlatFormDataFileFilter, 'SCnMenuFlatFormDataFileFilter');
  TranslateStr(SCnFlatToolBarRestoreDefault, 'SCnFlatToolBarRestoreDefault');
  TranslateStr(SCnFloatPropBarFilterCaption, 'SCnFloatPropBarFilterCaption');
  TranslateStr(SCnFloatPropBarRenameCaption, 'SCnFloatPropBarRenameCaption');
  TranslateStr(SCnEmbeddedDesignerNotSupport, 'SCnEmbeddedDesignerNotSupport');

  // CnDesignWizard
  TranslateStr(SCnDesignWizardMenuCaption, 'SCnDesignWizardMenuCaption');
  TranslateStr(SCnDesignWizardMenuHint, 'SCnDesignWizardMenuHint');
  TranslateStr(SCnDesignWizardName, 'SCnDesignWizardName');
  TranslateStr(SCnDesignWizardComment, 'SCnDesignWizardComment');

  TranslateStr(SCnAlignLeftCaption, 'SCnAlignLeftCaption');
  TranslateStr(SCnAlignLeftHint, 'SCnAlignLeftHint');
  TranslateStr(SCnAlignRightCaption, 'SCnAlignRightCaption');
  TranslateStr(SCnAlignRightHint, 'SCnAlignRightHint');
  TranslateStr(SCnAlignTopCaption, 'SCnAlignTopCaption');
  TranslateStr(SCnAlignTopHint, 'SCnAlignTopHint');
  TranslateStr(SCnAlignBottomCaption, 'SCnAlignBottomCaption');
  TranslateStr(SCnAlignBottomHint, 'SCnAlignBottomHint');
  TranslateStr(SCnAlignHCenterCaption, 'SCnAlignHCenterCaption');
  TranslateStr(SCnAlignHCenterHint, 'SCnAlignHCenterHint');
  TranslateStr(SCnAlignVCenterCaption, 'SCnAlignVCenterCaption');
  TranslateStr(SCnAlignVCenterHint, 'SCnAlignVCenterHint');
  TranslateStr(SCnSpaceEquHCaption, 'SCnSpaceEquHCaption');
  TranslateStr(SCnSpaceEquHHint, 'SCnSpaceEquHHint');
  TranslateStr(SCnSpaceEquHXCaption, 'SCnSpaceEquHXCaption');
  TranslateStr(SCnSpaceEquHXHint, 'SCnSpaceEquHXHint');
  TranslateStr(SCnSpaceIncHCaption, 'SCnSpaceIncHCaption');
  TranslateStr(SCnSpaceIncHHint, 'SCnSpaceIncHHint');
  TranslateStr(SCnSpaceDecHCaption, 'SCnSpaceDecHCaption');
  TranslateStr(SCnSpaceDecHHint, 'SCnSpaceDecHHint');
  TranslateStr(SCnSpaceRemoveHCaption, 'SCnSpaceRemoveHCaption');
  TranslateStr(SCnSpaceRemoveHHint, 'SCnSpaceRemoveHHint');
  TranslateStr(SCnSpaceEquVCaption, 'SCnSpaceEquVCaption');
  TranslateStr(SCnSpaceEquVHint, 'SCnSpaceEquVHint');
  TranslateStr(SCnSpaceIncVCaption, 'SCnSpaceIncVCaption');
  TranslateStr(SCnSpaceEquVYCaption, 'SCnSpaceEquVYCaption');
  TranslateStr(SCnSpaceEquVYHint, 'SCnSpaceEquVYHint');
  TranslateStr(SCnSpaceIncVHint, 'SCnSpaceIncVHint');
  TranslateStr(SCnSpaceDecVCaption, 'SCnSpaceDecVCaption');
  TranslateStr(SCnSpaceDecVHint, 'SCnSpaceDecVHint');
  TranslateStr(SCnSpaceRemoveVCaption, 'SCnSpaceRemoveVCaption');
  TranslateStr(SCnSpaceRemoveVHint, 'SCnSpaceRemoveVHint');
  TranslateStr(SCnIncWidthCaption, 'SCnIncWidthCaption');
  TranslateStr(SCnIncWidthHint, 'SCnIncWidthHint');
  TranslateStr(SCnDecWidthCaption, 'SCnDecWidthCaption');
  TranslateStr(SCnDecWidthHint, 'SCnDecWidthHint');
  TranslateStr(SCnIncHeightCaption, 'SCnIncHeightCaption');
  TranslateStr(SCnIncHeightHint, 'SCnIncHeightHint');
  TranslateStr(SCnDecHeightCaption, 'SCnDecHeightCaption');
  TranslateStr(SCnDecHeightHint, 'SCnDecHeightHint');
  TranslateStr(SCnMakeMinWidthCaption, 'SCnMakeMinWidthCaption');
  TranslateStr(SCnMakeMinWidthHint, 'SCnMakeMinWidthHint');
  TranslateStr(SCnMakeMaxWidthCaption, 'SCnMakeMaxWidthCaption');
  TranslateStr(SCnMakeMaxWidthHint, 'SCnMakeMaxWidthHint');
  TranslateStr(SCnMakeSameWidthCaption, 'SCnMakeSameWidthCaption');
  TranslateStr(SCnMakeSameWidthHint, 'SCnMakeSameWidthHint');
  TranslateStr(SCnMakeMinHeightCaption, 'SCnMakeMinHeightCaption');
  TranslateStr(SCnMakeMinHeightHint, 'SCnMakeMinHeightHint');
  TranslateStr(SCnMakeMaxHeightCaption, 'SCnMakeMaxHeightCaption');
  TranslateStr(SCnMakeMaxHeightHint, 'SCnMakeMaxHeightHint');
  TranslateStr(SCnMakeSameHeightCaption, 'SCnMakeSameHeightCaption');
  TranslateStr(SCnMakeSameHeightHint, 'SCnMakeSameHeightHint');
  TranslateStr(SCnMakeSameSizeCaption, 'SCnMakeSameSizeCaption');
  TranslateStr(SCnMakeSameSizeHint, 'SCnMakeSameSizeHint');
  TranslateStr(SCnParentHCenterCaption, 'SCnParentHCenterCaption');
  TranslateStr(SCnParentHCenterHint, 'SCnParentHCenterHint');
  TranslateStr(SCnParentVCenterCaption, 'SCnParentVCenterCaption');
  TranslateStr(SCnParentVCenterHint, 'SCnParentVCenterHint');
  TranslateStr(SCnBringToFrontCaption, 'SCnBringToFrontCaption');
  TranslateStr(SCnBringToFrontHint, 'SCnBringToFrontHint');
  TranslateStr(SCnSendToBackCaption, 'SCnSendToBackCaption');
  TranslateStr(SCnSendToBackHint, 'SCnSendToBackHint');
  TranslateStr(SCnSnapToGridCaption, 'SCnSnapToGridCaption');
  TranslateStr(SCnSnapToGridHint, 'SCnSnapToGridHint');
  TranslateStr(SCnUseGuidelinesCaption, 'SCnUseGuidelinesCaption');
  TranslateStr(SCnUseGuidelinesHint, 'SCnUseGuidelinesHint');
  TranslateStr(SCnAlignToGridCaption, 'SCnAlignToGridCaption');
  TranslateStr(SCnAlignToGridHint, 'SCnAlignToGridHint');
  TranslateStr(SCnSizeToGridCaption, 'SCnSizeToGridCaption');
  TranslateStr(SCnSizeToGridHint, 'SCnSizeToGridHint');
  TranslateStr(SCnLockControlsCaption, 'SCnLockControlsCaption');
  TranslateStr(SCnLockControlsHint, 'SCnLockControlsHint');
  TranslateStr(SCnSelectRootCaption, 'SCnSelectRootCaption');
  TranslateStr(SCnSelectRootHint, 'SCnSelectRootHint');
  TranslateStr(SCnCopyCompNameCaption, 'SCnCopyCompNameCaption');
  TranslateStr(SCnCopyCompNameHint, 'SCnCopyCompNameHint');
  TranslateStr(SCnCopyCompClassCaption, 'SCnCopyCompClassCaption');
  TranslateStr(SCnCopyCompClassHint, 'SCnCopyCompClassHint');
  TranslateStr(SCnNonArrangeCaption, 'SCnNonArrangeCaption');
  TranslateStr(SCnNonArrangeHint, 'SCnNonArrangeHint');
  TranslateStr(SCnListCompCaption, 'SCnListCompCaption');
  TranslateStr(SCnListCompHint, 'SCnListCompHint');
  TranslateStr(SCnComparePropertyCaption, 'SCnComparePropertyCaption');
  TranslateStr(SCnComparePropertyHint, 'SCnComparePropertyHint');
  TranslateStr(SCnCompToCodeCaption, 'SCnCompToCodeCaption');
  TranslateStr(SCnCompToCodeHint, 'SCnCompToCodeHint');
  TranslateStr(SCnChangeCompClassCaption, 'SCnChangeCompClassCaption');
  TranslateStr(SCnChangeCompClassHint, 'SCnChangeCompClassHint');
  TranslateStr(SCnHideComponentCaption, 'SCnHideComponentCaption');
  TranslateStr(SCnHideComponentHint, 'SCnHideComponentHint');
  TranslateStr(SCnShowFlatFormCaption, 'SCnShowFlatFormCaption');
  TranslateStr(SCnShowFlatFormHint, 'SCnShowFlatFormHint');
  TranslateStr(SCnListComponentCount, 'SCnListComponentCount');
  TranslateStr(SCnCompToCodeEnvNotSupport, 'SCnCompToCodeEnvNotSupport');
  TranslateStr(SCnCompToCodeProcCopiedFmt, 'SCnCompToCodeProcCopiedFmt');
  TranslateStr(SCnCompToCodeConvertedFmt, 'SCnCompToCodeConvertedFmt');
  TranslateStr(SCnChangeCompClassErrorNoSelection, 'SCnChangeCompClassErrorNoSelection');
  TranslateStr(SCnChangeCompClassErrorDiffType, 'SCnChangeCompClassErrorDiffType');
  TranslateStr(SCnChangeCompClassNewHint, 'SCnChangeCompClassNewHint');
  TranslateStr(SCnChangeCompClassErrorNew, 'SCnChangeCompClassErrorNew');
  TranslateStr(SCnChangeCompClassErrorCreateFmt, 'SCnChangeCompClassErrorCreateFmt');
  TranslateStr(SCnMustGreaterThanZero, 'SCnMustGreaterThanZero');
  TranslateStr(SCnHideNonVisualNotSupport, 'SCnHideNonVisualNotSupport');
  TranslateStr(SCnNonNonVisualFound, 'SCnNonNonVisualFound');
  TranslateStr(SCnNonNonVisualNotSupport, 'SCnNonNonVisualNotSupport');
  TranslateStr(SCnSpacePrompt, 'SCnSpacePrompt');
  TranslateStr(SCnMustDigital, 'SCnMustDigital');
  TranslateStr(SCnPropertyCompareSelectCaptionFmt, 'SCnPropertyCompareSelectCaptionFmt');
  TranslateStr(SCnPropertyCompareToComponentsFmt, 'SCnPropertyCompareToComponentsFmt');
  TranslateStr(SCnPropertyCompareTwoComponentsFmt, 'SCnPropertyCompareTwoComponentsFmt');
  TranslateStr(SCnPropertyCompareNoPrevDiff, 'SCnPropertyCompareNoPrevDiff');
  TranslateStr(SCnPropertyCompareNoNextDiff, 'SCnPropertyCompareNoNextDiff');

  // CnPaletteEnhanceWizard
  TranslateStr(SCnPaletteEnhanceWizardName, 'SCnPaletteEnhanceWizardName');
  TranslateStr(SCnPaletteEnhanceWizardComment, 'SCnPaletteEnhanceWizardComment');
  TranslateStr(SCnPaletteTabsMenuCaption, 'SCnPaletteTabsMenuCaption');
  TranslateStr(SCnPaletteMultiLineMenuCaption, 'SCnPaletteMultiLineMenuCaption');
  TranslateStr(SCnLockToolbarMenuCaption, 'SCnLockToolbarMenuCaption');
  TranslateStr(SCnPaletteMoreCaption, 'SCnPaletteMoreCaption');

  TranslateStr(SCnSearchComponent, 'SCnSearchComponent');
  TranslateStr(SCnPalSettingsCaption, 'SCnPalSettingsCaption');
  TranslateStr(SCnComponentDetailFmt, 'SCnComponentDetailFmt');
  TranslateStr(SCnComponentWithPackageDetailFmt, 'SCnComponentWithPackageDetailFmt');

  // CnVerEnhanceWizard
  TranslateStr(SCnVerEnhanceWizardName, 'SCnVerEnhanceWizardName');
  TranslateStr(SCnVerEnhanceWizardComment, 'SCnVerEnhanceWizardComment');

  // CnCorPropWizard
  TranslateStr(SCnCorrectPropertyName, 'SCnCorrectPropertyName');
  TranslateStr(SCnCorrectPropertyMenuCaption, 'SCnCorrectPropertyMenuCaption');
  TranslateStr(SCnCorrectPropertyMenuHint, 'SCnCorrectPropertyMenuHint');
  TranslateStr(SCnCorrectPropertyComment, 'SCnCorrectPropertyComment');

  TranslateStr(SCnCorrectPropertyActionWarn, 'SCnCorrectPropertyActionWarn');
  TranslateStr(SCnCorrectPropertyActionAutoCorrect, 'SCnCorrectPropertyActionAutoCorrect');
  TranslateStr(SCnCorrectPropertyStateCorrected, 'SCnCorrectPropertyStateCorrected');
  TranslateStr(SCnCorrectPropertyStateWarning, 'SCnCorrectPropertyStateWarning');
  TranslateStr(SCnCorrectPropertyAskDel, 'SCnCorrectPropertyAskDel');
  TranslateStr(SCnCorrectPropertyRulesCountFmt, 'SCnCorrectPropertyRulesCountFmt');

  TranslateStr(SCnCorrectPropertyErrNoForm, 'SCnCorrectPropertyErrNoForm');
  TranslateStr(SCnCorrectPropertyErrNoResult, 'SCnCorrectPropertyErrNoResult');
  TranslateStr(SCnCorrectPropertyErrNoModuleFound, 'SCnCorrectPropertyErrNoModuleFound');
  TranslateStr(SCnCorrectPropertyErrClassFmt, 'SCnCorrectPropertyErrClassFmt');
  TranslateStr(SCnCorrectPropertyErrClassCreate, 'SCnCorrectPropertyErrClassCreate');
  TranslateStr(SCnCorrectPropertyErrPropFmt, 'SCnCorrectPropertyErrPropFmt');
  TranslateStr(SCnCorrPropSetPropValueErrorFmt, 'SCnCorrPropSetPropValueErrorFmt');

  // CnProjectExtWizard
  TranslateStr(SCnProjExtWizardName, 'SCnProjExtWizardName');
  TranslateStr(SCnProjExtWizardCaption, 'SCnProjExtWizardCaption');
  TranslateStr(SCnProjExtWizardHint, 'SCnProjExtWizardHint');
  TranslateStr(SCnProjExtWizardComment, 'SCnProjExtWizardComment');
  TranslateStr(SCnProjExtRunSeparatelyCaption, 'SCnProjExtRunSeparatelyCaption');
  TranslateStr(SCnProjExtRunSeparatelyHint, 'SCnProjExtRunSeparatelyHint');
  TranslateStr(SCnProjExtExploreUnitCaption, 'SCnProjExtExploreUnitCaption');
  TranslateStr(SCnProjExtExploreUnitHint, 'SCnProjExtExploreUnitHint');
  TranslateStr(SCnProjExtExploreProjectCaption, 'SCnProjExtExploreProjectCaption');
  TranslateStr(SCnProjExtExploreProjectHint, 'SCnProjExtExploreProjectHint');
  TranslateStr(SCnProjExtExploreExeCaption, 'SCnProjExtExploreExeCaption');
  TranslateStr(SCnProjExtExploreExeHint, 'SCnProjExtExploreExeHint');
  TranslateStr(SCnProjExtViewUnitsCaption, 'SCnProjExtViewUnitsCaption');
  TranslateStr(SCnProjExtViewUnitsHint, 'SCnProjExtViewUnitsHint');
  TranslateStr(SCnProjExtViewFormsCaption, 'SCnProjExtViewFormsCaption');
  TranslateStr(SCnProjExtViewFormsHint, 'SCnProjExtViewFormsHint');
  TranslateStr(SCnProjExtUseUnitsCaption, 'SCnProjExtUseUnitsCaption');
  TranslateStr(SCnProjExtUseUnitsHint, 'SCnProjExtUseUnitsHint');
  TranslateStr(SCnProjExtListUsedCaption, 'SCnProjExtListUsedCaption');
  TranslateStr(SCnProjExtListUsedHint, 'SCnProjExtListUsedHint');

  // Project Backup
  TranslateStr(SCnProjExtBackupCaption, 'SCnProjExtBackupCaption');
  TranslateStr(SCnProjExtBackupHint, 'SCnProjExtBackupHint');
  TranslateStr(SCnProjExtBackupFileCount, 'SCnProjExtBackupFileCount');
  TranslateStr(SCnProjExtBackupNoFile, 'SCnProjExtBackupNoFile');
  TranslateStr(SCnProjExtBackupMustZip, 'SCnProjExtBackupMustZip');
  TranslateStr(SCnProjExtBackupDllMissCorrupt, 'SCnProjExtBackupDllMissCorrupt');
  TranslateStr(SCnProjExtBackupErrorCompressor, 'SCnProjExtBackupErrorCompressor');
  TranslateStr(SCnProjExtBackupSuccFmt, 'SCnProjExtBackupSuccFmt');
  TranslateStr(SCnProjExtBackupFail, 'SCnProjExtBackupFail');
  TranslateStr(SCnProjExtBackupLastFmt, 'SCnProjExtBackupLastFmt');

  TranslateStr(SCnProjExtDelTempCaption, 'SCnProjExtDelTempCaption');
  TranslateStr(SCnProjExtDelTempHint, 'SCnProjExtDelTempHint');
  TranslateStr(SCnProjExtProjectAll, 'SCnProjExtProjectAll');
  TranslateStr(SCnProjExtCurrentProject, 'SCnProjExtCurrentProject');
  TranslateStr(SCnProjExtProjectCount, 'SCnProjExtProjectCount');
  TranslateStr(SCnProjExtFormsFileCount, 'SCnProjExtFormsFileCount');
  TranslateStr(SCnProjExtUnitsFileCount, 'SCnProjExtUnitsFileCount');
  TranslateStr(SCnProjExtFramesFileCount, 'SCnProjExtFramesFileCount');
  TranslateStr(SCnProjExtNotSave, 'SCnProjExtNotSave');
  TranslateStr(SCnProjExtFileNotExistOrNotSave, 'SCnProjExtFileNotExistOrNotSave');
  TranslateStr(SCnProjExtOpenFormWarning, 'SCnProjExtOpenFormWarning');
  TranslateStr(SCnProjExtOpenUnitWarning, 'SCnProjExtOpenUnitWarning');
  TranslateStr(SCnProjExtFileIsReadOnly, 'SCnProjExtFileIsReadOnly');
  TranslateStr(SCnProjExtCreatePrjListError, 'SCnProjExtCreatePrjListError');
  TranslateStr(SCnProjExtErrorInUse, 'SCnProjExtErrorInUse');
  TranslateStr(SCnProjExtUsesNoPasPosition, 'SCnProjExtUsesNoPasPosition');
  TranslateStr(SCnProjExtUsesNoCppPosition, 'SCnProjExtUsesNoCppPosition');
  TranslateStr(SCnProjExtAddExtension, 'SCnProjExtAddExtension');
  TranslateStr(SCnProjExtAddNewText, 'SCnProjExtAddNewText');
  TranslateStr(SCnProjExtCleaningComplete, 'SCnProjExtCleaningComplete');
  TranslateStr(SCnProjExtCustomBackupFile, 'SCnProjExtCustomBackupFile');
  TranslateStr(SCnProjExtBackupAddFile, 'SCnProjExtBackupAddFile');
  TranslateStr(SCnProjExtDirBuilderCaption, 'SCnProjExtDirBuilderCaption');
  TranslateStr(SCnProjExtDirBuilderHint, 'SCnProjExtDirBuilderHint');
  TranslateStr(SCnProjExtConfirmOverrideTemplet, 'SCnProjExtConfirmOverrideTemplet');
  TranslateStr(SCnProjExtConfirmSaveTemplet, 'SCnProjExtConfirmSaveTemplet');
  TranslateStr(SCnProjExtConfirmDeleteDir, 'SCnProjExtConfirmDeleteDir');
  TranslateStr(SCnProjExtConfirmDeleteTemplet, 'SCnProjExtConfirmDeleteTemplet');
  TranslateStr(SCnProjExtSelectDir, 'SCnProjExtSelectDir');
  TranslateStr(SCnProjExtSaveTempletCaption, 'SCnProjExtSaveTempletCaption');
  TranslateStr(SCnProjExtInputTempletName, 'SCnProjExtInputTempletName');
  TranslateStr(SCnProjExtIsNotUniqueDirName, 'SCnProjExtIsNotUniqueDirName');
  TranslateStr(SCnProjExtDirNameHasInvalidChar, 'SCnProjExtDirNameHasInvalidChar');
  TranslateStr(SCnProjExtDirCreateSucc, 'SCnProjExtDirCreateSucc');
  TranslateStr(SCnProjExtDirCreateFail, 'SCnProjExtDirCreateFail');
  TranslateStr(SCnProjExtVclToFmxCaption, 'SCnProjExtVclToFmxCaption');
  TranslateStr(SCnProjExtVclToFmxHint, 'SCnProjExtVclToFmxHint');
  TranslateStr(SCnProjExtVclToFmxConvertOK, 'SCnProjExtVclToFmxConvertOK');
  TranslateStr(SCnProjExtVclToFmxConvertError, 'SCnProjExtVclToFmxConvertError');

  // CnFilesSnapshotWizard
  TranslateStr(SCnFilesSnapshotWizardName, 'SCnFilesSnapshotWizardName');
  TranslateStr(SCnFilesSnapshotWizardCaption, 'SCnFilesSnapshotWizardCaption');
  TranslateStr(SCnFilesSnapshotWizardHint, 'SCnFilesSnapshotWizardHint');
  TranslateStr(SCnFilesSnapshotWizardComment, 'SCnFilesSnapshotWizardComment');
  TranslateStr(SCnFilesSnapshotAddCaption, 'SCnFilesSnapshotAddCaption');
  TranslateStr(SCnFilesSnapshotAddHint, 'SCnFilesSnapshotAddHint');
  TranslateStr(SCnFilesSnapshotManageCaption, 'SCnFilesSnapshotManageCaption');
  TranslateStr(SCnFilesSnapshotManageHint, 'SCnFilesSnapshotManageHint');
  TranslateStr(SCnFilesSnapshotReopenCaption, 'SCnFilesSnapshotReopenCaption');
  TranslateStr(SCnFilesSnapshotReopenHint, 'SCnFilesSnapshotReopenHint');
  TranslateStr(SCnFilesSnapshotManageFrmCaptionManage, 'SCnFilesSnapshotManageFrmCaptionManage');
  TranslateStr(SCnFilesSnapshotManageFrmCaptionAdd, 'SCnFilesSnapshotManageFrmCaptionAdd');
  TranslateStr(SCnFilesSnapshotManageFrmLblSnapshotsCaptionManage, 'SCnFilesSnapshotManageFrmLblSnapshotsCaptionManage');
  TranslateStr(SCnFilesSnapshotManageFrmLblSnapshotsCaptionAdd, 'SCnFilesSnapshotManageFrmLblSnapshotsCaptionAdd');

  // CnCommentCroperWizard
  TranslateStr(SCnCommentCropperWizardName, 'SCnCommentCropperWizardName');
  TranslateStr(SCnCommentCropperWizardMenuCaption, 'SCnCommentCropperWizardMenuCaption');
  TranslateStr(SCnCommentCropperWizardMenuHint, 'SCnCommentCropperWizardMenuHint');
  TranslateStr(SCnCommentCropperWizardComment, 'SCnCommentCropperWizardComment');
  TranslateStr(SCnCommentCropperCountFmt, 'SCnCommentCropperCountFmt');

  // CnFavoriteWizard
  TranslateStr(SCnFavWizName, 'SCnFavWizName');
  TranslateStr(SCnFavWizCaption, 'SCnFavWizCaption');
  TranslateStr(SCnFavWizHint, 'SCnFavWizHint');
  TranslateStr(SCnFavWizComment, 'SCnFavWizComment');
  TranslateStr(SCnFavWizAddToFavoriteMenuCaption, 'SCnFavWizAddToFavoriteMenuCaption');
  TranslateStr(SCnFavWizAddToFavoriteMenuHint, 'SCnFavWizAddToFavoriteMenuHint');
  TranslateStr(SCnFavWizManageFavoriteMenuCaption, 'SCnFavWizManageFavoriteMenuCaption');
  TranslateStr(SCnFavWizManageFavoriteMenuHint, 'SCnFavWizManageFavoriteMenuHint');

  // CnCpuWinEnhancements
  TranslateStr(SCnCpuWinEnhanceWizardName, 'SCnCpuWinEnhanceWizardName');
  TranslateStr(SCnCpuWinEnhanceWizardComment, 'SCnCpuWinEnhanceWizardComment');
  TranslateStr(SCnMenuCopyLinesToClipboard, 'SCnMenuCopyLinesToClipboard');
  TranslateStr(SCnMenuCopyLinesToFile, 'SCnMenuCopyLinesToFile');
  TranslateStr(SCnMenuCopyLinesCaption, 'SCnMenuCopyLinesCaption');

  // CnResourceMgrWizard
  TranslateStr(SCnResMgrWizardMenuCaption, 'SCnResMgrWizardMenuCaption');
  TranslateStr(SCnResMgrWizardMenuHint, 'SCnResMgrWizardMenuHint');
  TranslateStr(SCnResMgrWizardName, 'SCnResMgrWizardName');
  TranslateStr(SCnResMgrWizardComment, 'SCnResMgrWizardComment');
  TranslateStr(SCnDocumentMgrWizardCaption, 'SCnDocumentMgrWizardCaption');
  TranslateStr(SCnDocumentMgrWizardHint, 'SCnDocumentMgrWizardHint');
  TranslateStr(SCnDocumentMgrWizardComment, 'SCnDocumentMgrWizardComment');
  TranslateStr(SCnImageMgrWizardCaption, 'SCnImageMgrWizardCaption');
  TranslateStr(SCnImageMgrWizardHint, 'SCnImageMgrWizardHint');
  TranslateStr(SCnImageMgrWizardComment, 'SCnImageMgrWizardCommen');
  TranslateStr(SCnResMgrConfigCaption, 'SCnResMgrConfigCaption');
  TranslateStr(SCnResMgrConfigHint, 'SCnResMgrConfigHint');
  TranslateStr(SCnResMgrConfigComment, 'SCnResMgrConfigComment');

  // CnRepositoryMenu
  TranslateStr(SCnRepositoryMenuCaption, 'SCnRepositoryMenuCaption');
  TranslateStr(SCnRepositoryMenuHint, 'SCnRepositoryMenuHint');
  TranslateStr(SCnRepositoryMenuName, 'SCnRepositoryMenuName');
  TranslateStr(SCnRepositoryMenuComment, 'SCnRepositoryMenuComment');

  // CnExplore
  TranslateStr(SCnExploreMenuCaption, 'SCnExploreMenuCaption');
  TranslateStr(SCnExploreMenuHint, 'SCnExploreMenuHint');
  TranslateStr(SCnExploreName, 'SCnExploreName');
  TranslateStr(SCnExploreComment, 'SCnExploreComment');
  TranslateStr(SCnNewFolder, 'SCnNewFolder');
  TranslateStr(SCnNewFolderHint, 'SCnNewFolderHint');
  TranslateStr(SCnNewFolderDefault, 'SCnNewFolderDefault');
  TranslateStr(SCnUnableToCreateFolder, 'SCnUnableToCreateFolder');
  TranslateStr(SCnExploreFilterAllFile, 'SCnExploreFilterAllFile');
  TranslateStr(SCnExploreFilterDelphiFile, 'SCnExploreFilterDelphiFile');
  TranslateStr(SCnExploreFilterBCBFile, 'SCnExploreFilterBCBFile');
  TranslateStr(SCnExploreFilterDelphiProjectFile, 'SCnExploreFilterDelphiProjectFile');
  TranslateStr(SCnExploreFilterDelphiPackageFile, 'SCnExploreFilterDelphiPackageFile');
  TranslateStr(SCnExploreFilterDelphiUnitFile, 'SCnExploreFilterDelphiUnitFile');
  TranslateStr(SCnExploreFilterDelphiFormFile, 'SCnExploreFilterDelphiFormFile');
  TranslateStr(SCnExploreFilterConfigFile, 'SCnExploreFilterConfigFile');
  TranslateStr(SCnExploreFilterTextFile, 'SCnExploreFilterTextFile');
  TranslateStr(SCnExploreFilterSqlFile, 'SCnExploreFilterSqlFile');
  TranslateStr(SCnExploreFilterHtmlFile, 'SCnExploreFilterHtmlFile');
  TranslateStr(SCnExploreFilterWebFile, 'SCnExploreFilterWebFile');
  TranslateStr(SCnExploreFilterBatchFile, 'SCnExploreFilterBatchFile');
  TranslateStr(SCnExploreFilterTypeLibFile, 'SCnExploreFilterTypeLibFile');
  TranslateStr(SCnExploreFilterDefault, 'SCnExploreFilterDefault');
  TranslateStr(SCnExploreFilterDeleteFmt, 'SCnExploreFilterDeleteFmt');

  // CnDUnitWizard
  TranslateStr(SCnDUnitWizardName, 'SCnDUnitWizardName');
  TranslateStr(SCnDUnitWizardComment, 'SCnDUnitWizardComment');
  TranslateStr(SCnDUnitErrorNOTSupport, 'SCnDUnitErrorNOTSupport');
  TranslateStr(SCnDUnitTestName, 'SCnDUnitTestName');
  TranslateStr(SCnDUnitTestAuthor, 'SCnDUnitTestAuthor');
  TranslateStr(SCnDUnitTestVersion, 'SCnDUnitTestVersion');
  TranslateStr(SCnDUnitTestDescription, 'SCnDUnitTestDescription');
  TranslateStr(SCnDUnitTestComments, 'SCnDUnitTestComments');

  // CnObjInspectorEnhanceWizard
  TranslateStr(SCnObjInspectorEnhanceWizardName, 'SCnObjInspectorEnhanceWizardName');
  TranslateStr(SCnObjInspectorEnhanceWizardComment, 'SCnObjInspectorEnhanceWizardComment');

  // CnWizBoot
  TranslateStr(SCnWizBootCurrentCount, 'SCnWizBootCurrentCount');
  TranslateStr(SCnWizBootEnabledCount, 'SCnWizBootEnabledCount');

  // CnIniFilerWizard
  TranslateStr(SCnIniFilerWizardName, 'SCnIniFilerWizardName');
  TranslateStr(SCnIniFilerWizardComment, 'SCnIniFilerWizardComment');
  TranslateStr(SCnIniFilerPasFilter, 'SCnIniFilerPasFilter');
  TranslateStr(SCnIniFilerCppFilter, 'SCnIniFilerCppFilter');
  TranslateStr(SCnIniErrorNoFile, 'SCnIniErrorNoFile');
  TranslateStr(SCnIniErrorPrefix, 'SCnIniErrorPrefix');
  TranslateStr(SCnIniErrorClassName, 'SCnIniErrorClassName');
  TranslateStr(SCnIniErrorReadIni, 'SCnIniErrorReadIni');
  TranslateStr(SCnIniErrorNOTSupport, 'SCnIniErrorNOTSupport');
  TranslateStr(SCnIniErrorNOProject, 'SCnIniErrorNOProject');

  // CnMemProfWizard
  TranslateStr(SCnMemProfWizardName, 'SCnMemProfWizardName');
  TranslateStr(SCnMemProfWizardComment, 'SCnMemProfWizardComment');

  // CnWinTopRoller
  TranslateStr(SCnWinTopRollerName, 'SCnWinTopRollerName');
  TranslateStr(SCnWinTopRollerComment, 'SCnWinTopRollerComment');
  TranslateStr(SCnWinTopRollerBtnTopHint, 'SCnWinTopRollerBtnTopHint');
  TranslateStr(SCnWinTopRollerBtnRollerHint, 'SCnWinTopRollerBtnRollerHint');
  TranslateStr(SCnWinTopRollerBtnOptionsHint, 'SCnWinTopRollerBtnOptionsHint');
  TranslateStr(SCnWinTopRollerPopupAddToFilter, 'SCnWinTopRollerPopupAddToFilter');
  TranslateStr(SCnWinTopRollerPopupOptions, 'SCnWinTopRollerPopupOptions');

  // CnInputHelper
  TranslateStr(SCnInputHelperName, 'SCnInputHelperName');
  TranslateStr(SCnInputHelperComment, 'SCnInputHelperComment');
  TranslateStr(SCnInputHelperConfig, 'SCnInputHelperConfig');
  TranslateStr(SCnInputHelperAutoPopup, 'SCnInputHelperAutoPopup');
  TranslateStr(SCnInputHelperDispButtons, 'SCnInputHelperDispButtons');
  TranslateStr(SCnInputHelperSortKind, 'SCnInputHelperSortKind');
  TranslateStr(SCnInputHelperIcon, 'SCnInputHelperIcon');
  TranslateStr(SCnInputHelperSortByScope, 'SCnInputHelperSortByScope');
  TranslateStr(SCnInputHelperSortByText, 'SCnInputHelperSortByText');
  TranslateStr(SCnInputHelperSortByLength, 'SCnInputHelperSortByLength');
  TranslateStr(SCnInputHelperSortByKind, 'SCnInputHelperSortByKind');
  TranslateStr(SCnInputHelperCopy, 'SCnInputHelperCopy');
  TranslateStr(SCnInputHelperAddSymbol, 'SCnInputHelperAddSymbol');
  TranslateStr(SCnInputHelperHelp, 'SCnInputHelperHelp');
  TranslateStr(SCnInputHelperKibitzCompileRunning, 'SCnInputHelperKibitzCompileRunning');
  TranslateStr(SCnInputHelperPreDefSymbolList, 'SCnInputHelperPreDefSymbolList');
  TranslateStr(SCnInputHelperUserTemplateList, 'SCnInputHelperUserTemplateList');
  TranslateStr(SCnInputHelperCompDirectSymbolList, 'SCnInputHelperCompDirectSymbolList');
  TranslateStr(SCnInputHelperUnitNameList, 'SCnInputHelperUnitNameList');
  TranslateStr(SCnInputHelperUnitUsesList, 'SCnInputHelperUnitUsesList');
  TranslateStr(SCnInputHelperIDECodeTemplateList, 'SCnInputHelperIDECodeTemplateList');
  TranslateStr(SCnInputHelperIDESymbolList, 'SCnInputHelperIDESymbolList');
  TranslateStr(SCnInputHelperUserSymbolList, 'SCnInputHelperUserSymbolList');
  TranslateStr(SCnInputHelperXMLCommentList, 'SCnInputHelperXMLCommentList');
  TranslateStr(SCnInputHelperJavaDocList, 'SCnInputHelperJavaDocList');
  TranslateStr(SCnInputHelperSymbolNameIsEmpty, 'SCnInputHelperSymbolNameIsEmpty');
  TranslateStr(SCnInputHelperSymbolKindError, 'SCnInputHelperSymbolKindError');
  TranslateStr(SCnInputHelperUserMacroCaption, 'SCnInputHelperUserMacroCaption');
  TranslateStr(SCnInputHelperUserMacroPrompt, 'SCnInputHelperUserMacroPrompt');
  TranslateStr(SCnInputHelperDisableCodeCompletionSucc, 'SCnInputHelperDisableCodeCompletionSucc');
  TranslateStr(SCnKeywordDefault, 'SCnKeywordDefault');
  TranslateStr(SCnKeywordLower, 'SCnKeywordLower');
  TranslateStr(SCnKeywordUpper, 'SCnKeywordUpper');
  TranslateStr(SCnKeywordFirstUpper, 'SCnKeywordFirstUpper');

  // CnProcListWizard
  TranslateStr(SCnProcListWizardName, 'SCnProcListWizardName');
  TranslateStr(SCnProcListWizardComment, 'SCnProcListWizardComment');
  TranslateStr(SCnProcListWizardMenuCaption, 'SCnProcListWizardMenuCaption');
  TranslateStr(SCnProcListWizardMenuHint, 'SCnProcListWizardMenuHint');
  TranslateStr(SCnProcListObjsAll, 'SCnProcListObjsAll');
  TranslateStr(SCnProcListObjsNone, 'SCnProcListObjsNone');
  TranslateStr(SCnProcListErrorInFile, 'SCnProcListErrorInFile');
  TranslateStr(SCnProcListErrorFileType, 'SCnProcListErrorFileType');
  TranslateStr(SCnProcListErrorPreview, 'SCnProcListErrorPreview');

  TranslateStr(SCnProcListCurrentFile, 'SCnProcListCurrentFile');
  TranslateStr(SCnProcListAllFileInProject, 'SCnProcListAllFileInProject');
  TranslateStr(SCnProcListAllFileInProjectGroup, 'SCnProcListAllFileInProjectGroup');
  TranslateStr(SCnProcListAllFileOpened, 'SCnProcListAllFileOpened');

  TranslateStr(SCnProcListJumpIntfHint, 'SCnProcListJumpIntfHint');
  TranslateStr(SCnProcListJumpImplHint, 'SCnProcListJumpImplHint');
  TranslateStr(SCnProcListClassComboHint, 'SCnProcListClassComboHint');
  TranslateStr(SCnProcListProcComboHint, 'SCnProcListProcComboHint');

  TranslateStr(SCnProcListSortMenuCaption, 'SCnProcListSortMenuCaption');
  TranslateStr(SCnProcListSortSubMenuByName, 'SCnProcListSortSubMenuByName');
  TranslateStr(SCnProcListSortSubMenuByLocation, 'SCnProcListSortSubMenuByLocation');
  TranslateStr(SCnProcListSortSubMenuReverse, 'SCnProcListSortSubMenuReverse');
  TranslateStr(SCnProcListExportMenuCaption, 'SCnProcListExportMenuCaption');
  TranslateStr(SCnProcListCloseMenuCaption, 'SCnProcListCloseMenuCaption');

  TranslateStr(SCnProcListNoContent, 'SCnProcListNoContent');
  TranslateStr(SCnProcListCloseToolBarHint, 'SCnProcListCloseToolBarHint');
  TranslateStr(SCnProcListErrorNoIntf, 'SCnProcListErrorNoIntf');
  TranslateStr(SCnProcListErrorNoImpl, 'SCnProcListErrorNoImpl');

  // CnUsesTools
  TranslateStr(SCnUsesToolsMenuCaption, 'SCnUsesToolsMenuCaption');
  TranslateStr(SCnUsesToolsMenuHint, 'SCnUsesToolsMenuHint');
  TranslateStr(SCnUsesToolsName, 'SCnUsesToolsName');
  TranslateStr(SCnUsesToolsComment, 'SCnUsesToolsComment');

  // CnUsesCleaner
  TranslateStr(SCnUsesCleanerMenuCaption, 'SCnUsesCleanerMenuCaption');
  TranslateStr(SCnUsesCleanerMenuHint, 'SCnUsesCleanerMenuHint');
  TranslateStr(SCnUsesCleanerName, 'SCnUsesCleanerName');
  TranslateStr(SCnUsesCleanerComment, 'SCnUsesCleanerComment');
  TranslateStr(SCnUsesCleanerCompileFail, 'SCnUsesCleanerCompileFail');
  TranslateStr(SCnUsesCleanerUnitError, 'SCnUsesCleanerUnitError');
  TranslateStr(SCnUsesCleanerProcessError, 'SCnUsesCleanerProcessError');
  TranslateStr(SCnUsesCleanerHasInitSection, 'SCnUsesCleanerHasInitSection');
  TranslateStr(SCnUsesCleanerHasRegProc, 'SCnUsesCleanerHasRegProc');
  TranslateStr(SCnUsesCleanerInCleanList, 'SCnUsesCleanerInCleanList');
  TranslateStr(SCnUsesCleanerInIgnoreList, 'SCnUsesCleanerInIgnoreList');
  TranslateStr(SCnUsesCleanerNotSource, 'SCnUsesCleanerNotSource');
  TranslateStr(SCnUsesCleanerCompRef, 'SCnUsesCleanerCompRef');
  TranslateStr(SCnUsesCleanerNoneResult, 'SCnUsesCleanerNoneResult');
  TranslateStr(SCnUsesCleanerReport, 'SCnUsesCleanerReport');

  // CnUsesInitTree
  TranslateStr(SCnUsesInitTreeMenuCaption, 'SCnUsesInitTreeMenuCaption');
  TranslateStr(SCnUsesInitTreeMenuHint, 'SCnUsesInitTreeMenuHint');
  TranslateStr(SCnUsesInitTreeSearchInProject, 'SCnUsesInitTreeSearchInProject');
  TranslateStr(SCnUsesInitTreeSearchInProjectSearch, 'SCnUsesInitTreeSearchInProjectSearch');
  TranslateStr(SCnUsesInitTreeSearchInSystemSearch, 'SCnUsesInitTreeSearchInSystemSearch');
  TranslateStr(SCnUsesInitTreeNotFound, 'SCnUsesInitTreeNotFound');

  // CnUsesFromIdent
  TranslateStr(SCnUsesUnitFromIdentMenuCaption, 'SCnUsesUnitFromIdentMenuCaption');
  TranslateStr(SCnUsesUnitFromIdentMenuHint, 'SCnUsesUnitFromIdentMenuHint');
  TranslateStr(SCnUsesUnitAnalyzeWaiting, 'SCnUsesUnitAnalyzeWaiting');
  TranslateStr(SCNUsesUnitFromIdentErrorFmt, 'SCNUsesUnitFromIdentErrorFmt');

  // CnIdeEnhanceMenu
  TranslateStr(SCnIdeEnhanceMenuCaption, 'SCnIdeEnhanceMenuCaption');
  TranslateStr(SCnIdeEnhanceMenuHint, 'SCnIdeEnhanceMenuHint');
  TranslateStr(SCnIdeEnhanceMenuName, 'SCnIdeEnhanceMenuName');
  TranslateStr(SCnIdeEnhanceMenuComment, 'SCnIdeEnhanceMenuComment');

  // CnSourceHighlight
  TranslateStr(SCnSourceHighlightWizardName, 'SCnSourceHighlightWizardName');
  TranslateStr(SCnSourceHighlightWizardComment, 'SCnSourceHighlightWizardComment');
  TranslateStr(SCnSourceHighlightCustomIdentHint, 'SCnSourceHighlightCustomIdentHint');
  TranslateStr(SCnSourceHighlightCustomIdentConfirm, 'SCnSourceHighlightCustomIdentConfirm');

  // CnIdeBRWizard
  TranslateStr(SCnIdeBRWizardMenuCaption, 'SCnIdeBRWizardMenuCaption');
  TranslateStr(SCnIdeBRWizardMenuHint, 'SCnIdeBRWizardMenuHint');
  TranslateStr(SCnIdeBRWizardName, 'SCnIdeBRWizardName');
  TranslateStr(SCnIdeBRWizardComment, 'SCnIdeBRWizardComment');
  TranslateStr(SCnIdeBRToolNotExists, 'SCnIdeBRToolNotExists');

  // CnFastCodeWizard
  TranslateStr(SCnFastCodeWizardName, 'SCnFastCodeWizardName');
  TranslateStr(SCnFastCodeWizardComment, 'SCnFastCodeWizardComment');

  // CnScriptWizard
  TranslateStr(SCnScriptWizardMenuCaption, 'SCnScriptWizardMenuCaption');
  TranslateStr(SCnScriptWizardMenuHint, 'SCnScriptWizardMenuHint');
  TranslateStr(SCnScriptWizardName, 'SCnScriptWizardName');
  TranslateStr(SCnScriptWizardComment, 'SCnScriptWizardComment');
  TranslateStr(SCnScriptFormCaption, 'SCnScriptFormCaption');
  TranslateStr(SCnScriptFormHint, 'SCnScriptFormHint');
  TranslateStr(SCnScriptWizCfgCaption, 'SCnScriptWizCfgCaption');
  TranslateStr(SCnScriptWizCfgHint, 'SCnScriptWizCfgHint');
  TranslateStr(SCnScriptBrowseDemoCaption, 'SCnScriptBrowseDemoCaption');
  TranslateStr(SCnScriptBrowseDemoHint, 'SCnScriptBrowseDemoHint');
  TranslateStr(SCnScriptFileNotExists, 'SCnScriptFileNotExists');
  TranslateStr(SCnScriptCompError, 'SCnScriptCompError');
  TranslateStr(SCnScriptExecError, 'SCnScriptExecError');
  TranslateStr(SCnScriptCompiler, 'SCnScriptCompiler');
  TranslateStr(SCnScriptCompiling, 'SCnScriptCompiling');
  TranslateStr(SCnScriptErrorMsg, 'SCnScriptErrorMsg');
  TranslateStr(SCnScriptCompiledSucc, 'SCnScriptCompiledSucc');
  TranslateStr(SCnScriptExecutedSucc, 'SCnScriptExecutedSucc');
  TranslateStr(SCnScriptCompilingFailed, 'SCnScriptCompilingFailed');
  TranslateStr(SCnScriptExecConfirm, 'SCnScriptExecConfirm');
  TranslateStr(SCnScriptMenuDemoCaption, 'SCnScriptMenuDemoCaption');
  TranslateStr(SCnScriptMenuDemoHint, 'SCnScriptMenuDemoHint');
  TranslateStr(SCnScriptModeManual, 'SCnScriptModeManual');
  TranslateStr(SCnScriptModeIDELoaded, 'SCnScriptModeIDELoaded');
  TranslateStr(SCnScriptModeFileNotify, 'SCnScriptModeFileNotify');
  TranslateStr(SCnScriptModeBeforeCompile, 'SCnScriptModeBeforeCompile');
  TranslateStr(SCnScriptModeAfterCompile, 'SCnScriptModeAfterCompile');
  TranslateStr(SCnScriptModeSourceEditorNotify, 'SCnScriptModeSourceEditorNotify');
  TranslateStr(SCnScriptModeFormEditorNotify, 'SCnScriptModeFormEditorNotify');
  TranslateStr(SCnScriptModeApplicationEvent, 'SCnScriptModeApplicationEvent');
  TranslateStr(SCnScriptModeActiveFormChanged, 'SCnScriptModeActiveFormChanged');
  TranslateStr(SCnScriptModeEditorFlatButton, 'SCnScriptModeEditorFlatButton');
  TranslateStr(SCnScriptModeDesignerContextMenu, 'SCnScriptModeDesignerContextMenu');

  // CnFeedReaderWizard
  TranslateStr(SCnFeedReaderWizardName, 'SCnFeedReaderWizardName');
  TranslateStr(SCnFeedReaderWizardComment, 'SCnFeedReaderWizardComment');
  TranslateStr(SCnFeedPrevFeedCaption, 'SCnFeedPrevFeedCaption');
  TranslateStr(SCnFeedNextFeedCaption, 'SCnFeedNextFeedCaption');
  TranslateStr(SCnFeedForceUpdateCaption, 'SCnFeedForceUpdateCaption');
  TranslateStr(SCnFeedConfigCaption, 'SCnFeedConfigCaption');
  TranslateStr(SCnFeedCloseCaption, 'SCnFeedCloseCaption');
  TranslateStr(SCnFeedCloseQuery, 'SCnFeedCloseQuery');
  TranslateStr(SCnFeedNewItem, 'SCnFeedNewItem');

  // CnCodeFormatterWizard
  TranslateStr(SCnCodeFormatterWizardName, 'SCnCodeFormatterWizardName');
  TranslateStr(SCnCodeFormatterWizardComment, 'SCnCodeFormatterWizardComment');
  TranslateStr(SCnCodeFormatterWizardMenuCaption, 'SCnCodeFormatterWizardMenuCaption');
  TranslateStr(SCnCodeFormatterWizardMenuHint, 'SCnCodeFormatterWizardMenuHint');
  TranslateStr(SCnCodeFormatterWizardConfigCaption, 'SCnCodeFormatterWizardConfigCaption');
  TranslateStr(SCnCodeFormatterWizardConfigHint, 'SCnCodeFormatterWizardConfigHint');
  TranslateStr(SCnCodeFormatterWizardFormatCurrentCaption, 'SCnCodeFormatterWizardFormatCurrentCaption');
  TranslateStr(SCnCodeFormatterWizardFormatCurrentHint, 'SCnCodeFormatterWizardFormatCurrentHint');
  TranslateStr(SCnCodeFormatterWizardErrLineWidth, 'SCnCodeFormatterWizardErrLineWidth');
  TranslateStr(SCnCodeFormatterWizardErrSelection, 'SCnCodeFormatterWizardErrSelection');
  TranslateStr(SCnCodeFormatterErrUnknown, 'SCnCodeFormatterErrUnknown');
  TranslateStr(SCnCodeFormatterErrPascalFmt, 'SCnCodeFormatterErrPascalFmt');
  TranslateStr(SCnCodeFormatterErrPascalIdentExp, 'SCnCodeFormatterErrPascalIdentExp');
  TranslateStr(SCnCodeFormatterErrPascalStringExp, 'SCnCodeFormatterErrPascalStringExp');
  TranslateStr(SCnCodeFormatterErrPascalNumberExp, 'SCnCodeFormatterErrPascalNumberExp');
  TranslateStr(SCnCodeFormatterErrPascalCharExp, 'SCnCodeFormatterErrPascalCharExp');
  TranslateStr(SCnCodeFormatterErrPascalSymbolExp, 'SCnCodeFormatterErrPascalSymbolExp');
  TranslateStr(SCnCodeFormatterErrPascalParseErr, 'SCnCodeFormatterErrPascalParseErr');
  TranslateStr(SCnCodeFormatterErrPascalInvalidBin, 'SCnCodeFormatterErrPascalInvalidBin');
  TranslateStr(SCnCodeFormatterErrPascalInvalidString, 'SCnCodeFormatterErrPascalInvalidString');
  TranslateStr(SCnCodeFormatterErrPascalInvalidBookmark, 'SCnCodeFormatterErrPascalInvalidBookmark');
  TranslateStr(SCnCodeFormatterErrPascalLineTooLong, 'SCnCodeFormatterErrPascalLineTooLong');
  TranslateStr(SCnCodeFormatterErrPascalEndCommentExp, 'SCnCodeFormatterErrPascalEndCommentExp');
  TranslateStr(SCnCodeFormatterErrPascalNotSupport, 'SCnCodeFormatterErrPascalNotSupport');
  TranslateStr(SCnCodeFormatterErrPascalErrorDirective, 'SCnCodeFormatterErrPascalErrorDirective');
  TranslateStr(SCnCodeFormatterErrPascalNoMethodHeading, 'SCnCodeFormatterErrPascalNoMethodHeading');
  TranslateStr(SCnCodeFormatterErrPascalNoStructType, 'SCnCodeFormatterErrPascalNoStructType');
  TranslateStr(SCnCodeFormatterErrPascalNoTypedConstant, 'SCnCodeFormatterErrPascalNoTypedConstant');
  TranslateStr(SCnCodeFormatterErrPascalNoEqualColon, 'SCnCodeFormatterErrPascalNoEqualColon');
  TranslateStr(SCnCodeFormatterErrPascalNoDeclSection, 'SCnCodeFormatterErrPascalNoDeclSection');
  TranslateStr(SCnCodeFormatterErrPascalNoProcFunc, 'SCnCodeFormatterErrPascalNoProcFunc');
  TranslateStr(SCnCodeFormatterErrPascalUnknownGoal, 'SCnCodeFormatterErrPascalUnknownGoal');
  TranslateStr(SCnCodeFormatterErrPascalErrorInterface, 'SCnCodeFormatterErrPascalErrorInterface');
  TranslateStr(SCnCodeFormatterErrPascalInvalidStatement, 'SCnCodeFormatterErrPascalInvalidStatement');

  // CnMatchButtonFrame
  TranslateStr(SCnMatchButtonFrameMenuStartCaption, 'SCnMatchButtonFrameMenuStartCaption');
  TranslateStr(SCnMatchButtonFrameMenuStartHint, 'SCnMatchButtonFrameMenuStartHint');
  TranslateStr(SCnMatchButtonFrameMenuAnyCaption, 'SCnMatchButtonFrameMenuAnyCaption');
  TranslateStr(SCnMatchButtonFrameMenuAnyHint, 'SCnMatchButtonFrameMenuAnyHint');
  TranslateStr(SCnMatchButtonFrameMenuFuzzyCaption, 'SCnMatchButtonFrameMenuFuzzyCaption');
  TranslateStr(SCnMatchButtonFrameMenuFuzzyHint, 'SCnMatchButtonFrameMenuFuzzyHint');
end;

// 根据当前语言号翻译字符串变量
procedure CnTranslateConsts(Sender: TObject);
begin
  // 如当前无语言，则不翻译
  if (CnLanguageManager = nil) or (CnLanguageManager.LanguageStorage = nil)
    or (CnLanguageManager.LanguageStorage.LanguageCount = 0)
    or (CnLanguageManager.CurrentLanguageIndex = -1) then
    Exit;

  CnTranslateAuthorInfo;

  TranslateStr(SCnInformation, 'SCnInformation');
  TranslateStr(SCnWarning, 'SCnWarning');
  TranslateStr(SCnError, 'SCnError');
  TranslateStr(SCnEnabled, 'SCnEnabled');
  TranslateStr(SCnDisabled, 'SCnDisabled');
  TranslateStr(SCnMsgDlgOK, 'SCnMsgDlgOK');
  TranslateStr(SCnMsgDlgCancel, 'SCnMsgDlgCancel');
  TranslateStr(SCnMsgDlgYes, 'SCnMsgDlgYes');
  TranslateStr(SCnMsgDlgNo, 'SCnMsgDlgNo');
  TranslateStr(SCnMsgDlgYesToAll, 'SCnMsgDlgYesToAll');
  TranslateStr(SCnMsgDlgNoToAll, 'SCnMsgDlgNoToAll');
  
  //----------------------------------------------------------------------------
  //  Feedback
  //----------------------------------------------------------------------------

  TranslateStr(STypeDescription, 'STypeDescription');
  TranslateStr(SBugDescriptionDescription, 'SBugDescriptionDescription');
  TranslateStr(SFeatureDescriptionDescription, 'SFeatureDescriptionDescription');
  TranslateStr(SDetailsDescription, 'SDetailsDescription');
  TranslateStr(SStepsDescription, 'SStepsDescription');
  TranslateStr(SBugConfigurationDescription, 'SBugConfigurationDescription');
  TranslateStr(SFeatureConfigurationDescription, 'SFeatureConfigurationDescription');
  TranslateStr(SReportDescription, 'SReportDescription');
  TranslateStr(STypeExample, 'STypeExample');
  TranslateStr(SBugDescriptionExample, 'SBugDescriptionExample');
  TranslateStr(SFeatureDescriptionExample, 'SFeatureDescriptionExample');
  TranslateStr(SDetailsExample, 'SDetailsExample');
  TranslateStr(SStepsExample, 'SStepsExample');
  TranslateStr(SFinish, 'SFinish');
  TranslateStr(SNext, 'SNext');
  TranslateStr(STitle, 'STitle');
  TranslateStr(SBugReport, 'SBugReport');
  TranslateStr(SFeatureRequest, 'SFeatureRequest');
  TranslateStr(SDescription, 'SDescription');
  TranslateStr(SSteps, 'SSteps');
  TranslateStr(SBugDetails, 'SBugDetails');
  TranslateStr(SBugIsReproducible, 'SBugIsReproducible');
  TranslateStr(SBugIsNotReproducible, 'SBugIsNotReproducible');
  TranslateStr(SFillInReminder, 'SFillInReminder');
  TranslateStr(SFillInReminderPaste, 'SFillInReminderPaste');
  TranslateStr(SFillInReminderAttach, 'SFillInReminderAttach');
  TranslateStr(SBugSteps, 'SBugSteps');
  TranslateStr(SUnknown, 'SUnknown');
  TranslateStr(SOutKeyboard, 'SOutKeyboard');
  TranslateStr(SOutLocale, 'SOutLocale');
  TranslateStr(SOutExperts, 'SOutExperts');
  TranslateStr(SOutPackages, 'SOutPackages');
  TranslateStr(SOutIDEPackages, 'SOutIDEPackages');
  TranslateStr(SOutCnWizardsActive, 'SOutCnWizardsActive');
  TranslateStr(SOutCnWizardsCreated, 'SOutCnWizardsCreated');
  TranslateStr(SOutConfig, 'SOutConfig');
  TranslateStr(SCnKeyMappingConflictsHint, 'SCnKeyMappingConflictsHint');

  CnTranslateWizards;
  CnTranslateDesignConsts;
end;

end.
