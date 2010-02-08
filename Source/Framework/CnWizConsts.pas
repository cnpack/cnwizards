{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnWizConsts;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家工具包
* 单元名称：资源字符串定义单元
* 单元作者：CnPack开发组
* 备    注：该单元定义了 CnWizards 用到的资源字符串
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2005.05.05 V1.2
*               hubdog: 增加新的版本信息扩展专家
*           2003.08.20 V1.1
*               LiuXiao: 完善英文释文
*           2002.09.17 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  CnWizCompilerConst, CnConsts;

//==============================================================================
// 不需要本地化的字符串
//==============================================================================

const
  {$I Version.inc}

  SCnWizardVersion = SCnWizardMajorVersion + '.' + SCnWizardMinorVersion;
  SCnWizardFullVersion = SCnWizardVersion + ' Build ' + SCnWizardBuildDate;

  SCnWizardCaption = 'CnPack IDE Wizards ' + SCnWizardVersion;
  SCnWizardDesc = 'CnPack IDE Wizards for Delphi/C++Builder/BDS/Rad Studio' + #13#10 +
                  '' + #13#10 +
                  'Version: ' + SCnWizardFullVersion + #13#10 +
                  'Copyright: 2001-2010 CnPack Team' + #13#10 +
                  '' + #13#10 +
                  'This is a freeware, you can use it freely without any fee. ' +
                  'You can copy or distribute it in any form, without any fee. ' +
                  'The source code can be abtained from Internet. ' +
                  'For more information please see the license file.' + #13#10 +
                  '' + #13#10 +
                  'WebSite: ' + SCnPackUrl + #13#10 +
                  'Forum: ' + SCnPackBbsUrl + #13#10 +
                  'Mail: ' + SCnPackEmail;
  SCnWizardLicense = 'Freeware';

resourcestring

  // Framework
  SCnWizardMgrName = 'CnPack Wizards';
  SCnWizardMgrID = 'CnPack.Wizards';
  SCnWizardsMenuName = 'CnPackMenu';
  SToolsMenuName = 'ToolsMenu';
  SCnPackKeyboard = 'CnPack_Keyboard';
  SCnActiveSection = 'Active';
  SCnMenuOrderSection = 'MenuOrder';

  // 保存窗体位置
  SCnFormPosition = 'FormPosition';
  SCnFormPositionTop = '_Top';
  SCnFormPositionLeft = '_Left';
  SCnFormPositionWidth = '_Width';
  SCnFormPositionHeight = '_Height';

  SCnCreateSection = 'Create';
  SCnBootLoadSection = 'BootLoad';
  SCnSplashBmp = 'CnWizSplash';
  SCnAboutBmp = 'CnWizAbout';

  SCnActionPrefix = 'act';
  SCnMenuItemPrefix = 'mni';
  SCnIcoFileExt = '.ico';
  SCnBmpFileExt = '.bmp';

  // IDE CmdLine Switch
  SCnNoCnWizardsSwitch = 'nocn';
  SCnShowBootFormSwitch = 'swcn';
  SCnUserRegSwitch = 'cnreg';

  SCnWizardsPage = 'CnPack';
  SCnWizardsNamePrefix = 'CnPack';
  SCnWizardsMenuCaption = 'C&nPack';
  SCnWizardsActionCategory = 'CnPack';
  SCnWizAlignSizeCategory = 'CnFormDesign';

  SCnKeyBindingDispName = 'CnPack Buffer List';
  SCnKeyBindingName = 'CnPack.BufferList';
  SCnShortCutsSection = 'ShortCuts';
  SCnOptionSection = 'Option';
  SCnCommentSection = 'Comment';
  SCnUpgradeSection = 'Upgrade';

  SCnWizConfigCommand = 'CnWizConfig';
  SCnWizConfigIcon = 'CnWizConfig';
  SCnWizConfigMenuName = 'CnWizConfig';

  SCnWizardRegPath = 'CnWizards';
  SCnWizLangPath = 'Lang';
  SCnWizDataPath = 'Data';
  SCnWizTemplatePath = 'Data\Templates';
  SCnWizIconPath = 'Icons';
  SCnWizHelpPath = 'Help';
  SCnWizUserPath = 'User';
  SCnWizCustomUserPath = 'CnWizards';
  SCnWizCommentPath = 'Comment';
  SCnWizLangFile = 'CnWizards.txt';
  SCnWizHelpIniFile = 'Help.ini';
  SCnWizCommentIniFile = 'Comments.ini';
  SCnWizUpgradeIniFile = 'Upgrade.ini';
  SCnWizTipOfDayIniFile = 'TipOfDay.ini';
  SCnWizResDllName = 'CnWizRes.dll';

  // RegPath
  SCnPropEditorRegPath = 'CnPropEditor';
  SCnCompEditorRegPath = 'CnCompEditor';
  SCnIdeEnhancementsRegPath = 'IdeEnhancements';

  SCnEditorEnhReg = 'SourceEditor';
  SCnFormEnhReg = 'FormDesigner';
  SCnPalEnhReg = 'ComponentPalette';

  // IdePath
{$IFDEF BDS}
  SCnIDEPathMacro = '$(BDS)';
{$ELSE}
{$IFDEF BCB}
  SCnIDEPathMacro = '$(BCB)';
{$ELSE}
  SCnIDEPathMacro = '$(DELPHI)';
{$ENDIF}
{$ENDIF}

  SCnWizOnlineHelpUrl = 'http://help.cnpack.org/cnwizards/';

  // CnWizUpgrade
  SCnWizDefUpgradeURL = 'http://upgrade.cnpack.org/cnwizards/';
  SCnWizDefNightlyBuildUrl = 'http://upgrade.cnpack.org/cnwizards/latest/';
  SCnWizUpgradeVersion = 'Ver %s Build %s';

  // CnMessageBoxWizard
  SCnMsgBoxDataName = 'MsgBoxPrj.ini';
  SCnMsgBoxProjectLastName = 'Auto Saved';

  // CnSrcTemplate
  SCnSrcTemplateDataName = 'Editor.cdt';

  // CnInputHelper
  SCnPreDefSymbolsFile = 'PreDefSymbols.xml';
  SCnCodeTemplateFile = 'CodeTemplate.xml';
  SCnUserSymbolsFile = 'UserSymbols.xml';
  SCnXmlCommentDataFile = 'XmlComment.xml';
  SCnJavaDocDataFile = 'JavaDocComment.xml';
  SCnCompDirectDataFile = 'CompDirect.ini';
  SCnInputHelperHelpStr = 'CnInputHelper';

  // CnPas2HtmlWizard
  SCnHTMLPostFix = '_Html';

  // CnFormEnhancements
  SCnFlatToolBarDataExt = 'ini';

  // CnEditorWizard
  SCnEditorWizardConfigName = 'CnEditorWizardConfig';
  SCnEditorCollectorDir = 'Collector';
  SCnEditorCollectorData = 'Collector.dat';

  // CnSrcTemplate
  SCnSrcTemplateConfigName = 'CnSrcTemplateConfig';
  SCnSrcTemplateIconName = 'TCnSrcTemplate';
  SCnSrcTemplateItem = 'CnEditorItem';

  // CnTabOrderWizard
  SCnTabOrderSetCurrControl = 'CnTabOrderSetCurrControl';
  SCnTabOrderSetCurrForm = 'CnTabOrderSetCurrForm';
  SCnTabOrderSetOpenedForm = 'CnTabOrderSetOpenedForm';
  SCnTabOrderSetProject = 'CnTabOrderSetProject';
  SCnTabOrderSetProjectGroup = 'CnTabOrderSetProjectGroup';
  SCnTabOrderDispTabOrder = 'CnTabOrderDispTabOrder';
  SCnTabOrderAutoReset = 'CnTabOrderAutoReset';
  SCnTabOrderConfig = 'CnTabOrderConfig';

  // CnPas2HtmlWizard
  SCnPas2HtmlWizardCopySelected = 'CnPas2HtmlWizardCopySelected';
  SCnPas2HtmlWizardExportUnit = 'CnPas2HtmlWizardExportUnit';
  SCnPas2HtmlWizardExportOpened = 'CnPas2HtmlWizardExportOpened';
  SCnPas2HtmlWizardExportDPR = 'CnPas2HtmlWizardExportDPR';
  SCnPas2HtmlWizardExportBPG = 'CnPas2HtmlWizardExportBPG';
  SCnPas2HtmlWizardConfig = 'CnPas2HtmlWizardConfig';

  // CnPrefixWizard
  SCnPrefixDataName = 'Prefix.ini';

  // CnProjectExtWizard
  SCnProjExtWizard = 'CnProjectExtWizard';
  SCnProjExtRunSeparately = 'CnProjExtRunSeparately';
  SCnProjExtExploreUnit = 'CnProjExtExploreUnit';
  SCnProjExtExploreProject = 'CnProjExtExploreProject';
  SCnProjExtExploreExe = 'CnProjExtExploreExe';
  SCnProjExtViewUnits = 'CnProjExtViewUnits';
  SCnProjExtViewForms = 'CnProjExtViewForms';
  SCnProjExtUseUnits = 'CnProjExtUseUnits';
  SCnProjExtListUsed = 'CnProjExtListUsed';
  SCnProjExtBackup = 'CnProjExtBackup';
  SCnProjExtDelTemp = 'CnProjExtDelTemp';
  SCnProjExtFileReopen = 'CnProjExtFileReopen';
  SCnProjExtDirBuilder = 'CnProjExtDirBuilder';

  SCnProjExtBackupDllName = 'CnZipWrapper.Dll';

  // CnFilesSnapshotWizard
  SCnProjExtFilesSnapshotAdd = 'CnProjExtFilesSnapshotAdd';
  SCnProjExtFilesSnapshotManage = 'CnProjExtFilesSnapshotManage';
  SCnProjExtFilesSnapshotsItem = 'CnProjExtFilesSnapshotsItem';

  // CnWizAbout
  SCnWizAboutHelp = 'CnWizAboutHelp';
  SCnWizAboutHistory = 'CnWizAboutHistory';
  SCnWizAboutBugReport = 'CnWizAboutBugReport';
  SCnWizAboutUpgrade = 'CnWizAboutUpgrade';
  SCnWizAboutConfigIO = 'CnWizAboutConfigIO';
  SCnWizAboutUrl = 'CnWizAboutUrl';
  SCnWizAboutBbs = 'CnWizAboutBbs';
  SCnWizAboutMail = 'CnWizAboutMail';
  SCnWizAboutTipOfDay = 'CnWizAboutTipOfDay';
  SCnWizAboutAbout = 'CnWizAboutAbout';

  // CnEditorEnhancements
  SCnMenuCloseOtherPagesName = 'CnCloseOtherPages';
  SCnShellMenuName = 'CnShellMenu';
  SCnMenuSelAllName = 'CnSelAll';
  SCnMenuBlockToolsName = 'CnMenuBlockTools';
  SCnMenuExploreName = 'CnExplore';
  SCnCopyFileNameMenuName = 'CnCopyFileName';
  SCnEditorToolBarDataName = 'EditorToolBar.ini';
  SCnEditorDesignToolBarDataName = 'DesignToolBar.ini';
{$IFDEF DELPHI}
  SCnCodeWrapFile = 'CodeWrap.xml';
{$ELSE}
  SCnCodeWrapFile = 'CodeWrap_CB.xml';
{$ENDIF}
  SCnGroupReplaceFile = 'GroupReplace.xml';
  SCnWebSearchFile = 'WebSearch.xml';

  // CnFormEnhancements
  SCnFlatPanelFileName = 'FormToolBar';
  SCnFloatPropBarFileName = 'FloatPropBar.dat';

  // CnPaletteEnhancements
  SCnPaletteTabsMenuName = 'CnPaletteTabs';
  SCnPaletteMutiLineMenuName = 'CnPaletteMultiLine';
  SCnLockToolbarMenuName = 'CnLockToolBar';
  SCnWizMenuName = 'CnWizToolMenu';
  SCnWizOptionMenuName = 'CnWizToolOptionMenu';
  SCnDefWizMenuCaption = '&Wizards';

  // CnCorPropWizard
  SCnCorPropDataName = 'CorRules.ini';

  // CnConfigIO
  SCnConfigIOName = 'CnConfigIO.exe';

  // CnFavoriteWizard
  SCnFavWizAddToFavorite = 'CnFavWziAddToFavorite';
  SCnFavWizManageFavorite = 'CnFavWizManageFavorite';

  // CnCpuWinEnhancements
  SCnMenuCopy30LinesName = 'CnCopy30Lines';
  SCnMenuCopyLinesName = 'CnCopyLines';

  // CnWizMultiLang
  SCnWizMultiLangName = 'Language Switch';
  SCnWizMultiLangCaption = 'Languages';
  SCnWizMultiLangHint = 'Language Switch';
  SCnWizMultiLangComment = 'Language Switch';

  // CnResourceMgrWizard
  SCnWizDocumentMgr = 'CnWizDocumentMgr';
  SCnWizImageMgr = 'CnWizImageMgr';
  SCnWizResMgrConfig = 'CnWizResMgrConfig';

  // CnRepositoryMenu
  SCnRepositoryMenuCommand = 'CnRepositoryMenu';

  // CnMsdnWizard
  SCnMsdnWizRunConfig = 'CnMsdnWizRunConfig';
  SCnMsdnWizRunMsdn = 'CnMsdnWizRunMsdn';
  SCnMsdnWizRunSearch = 'CnMsdnWizRunSearch';

  // CnInputHelper
  SCnInputHelperPopup = 'CnInputHelperPopup';

  // CnIdeEnhanceMenu
  SCnIdeEnhanceMenuCommand = 'CnIdeEnhanceMenu';

  // CnIdeBRTool
  SCnIdeBRToolName = 'CnIdeBRTool.exe';

  // CnScriptWizard
  SCnScriptWizCfgCommand = 'CnScriptWizardConfig';
  SCnScriptFormCommand = 'CnScriptForm';
  SCnScriptBrowseDemoCommand = 'CnScriptBrowseDemo';
  SCnScriptTemplateFileName = 'CnScript.pas';
  SCnScriptFileName = 'Scripts.xml';
  SCnScriptItem = 'CnScriptItem';
  SCnScriptDeclDir = 'PSDecl';
  SCnScriptDemoDir = 'PSDemo';
  SCnScriptFileDir = 'Scripts';
  SCnScriptDefName = 'Script%d.pas';

//==============================================================================
// 需要本地化的字符串
//==============================================================================

var
  // Common
  SCnSaveDlgTxtFilter: string = '文本文件 (*.txt)|*.TXT|所有文件 (*.*)|*.*|';
  SCnSaveDlgTitle: string = '保存为...';
  SCnOverwriteQuery: string = '文件已经存在，是否覆盖？';
  SCnDeleteConfirm: string = '您确定要删除吗？';
  SCnClearConfirm: string = '您确定要清空吗？';
  SCnDefaultConfirm: string = '您确定要删除自定义内容，恢复默认设置吗？';
  SCnNoHelpofThisLang: string = 'Sorry. No HELP in this Language.';
  SCnOnlineHelp: string = '在线帮助(&H)';
  SCnImportAppend: string = '是否采用追加方式导入？';
  SCnImportError: string = '导入数据失败！';
  SCnExportError: string = '导出数据失败！';
  SCnUnknownNameResult: string = '不可用';
  SCnNoneResult: string = '无';
  SCnInputFile: string = '请输入文件名！';
  SCnDoublePasswordError: string = '密码非法或不一致，请重新输入！';
  SCnMoreMenu: string = '更多...';

  // 反馈向导
  STypeDescription: string =
    '  错误报告包括非法访问、死机、不能正常工作的功能以及其它异常情况。' + #13#10#13#10 +
    '  用户建议指对 CnPack 开发包的建议、新功能需求以及其它的信息。' + #13#10#13#10 +
    '  在您提交错误报告和建议时，请保证您使用的是最新的 CnPack，' +
    '您可以通过自动更新功能或访问开发网站来获得最新版本。';
  SBugDescriptionDescription: string =
    '  请输入关于错误的详细描述，包括您系统中特殊的数据和设置，以及您认为可能对' +
    '开发人员重现该错误有用的内容。' + #13#10#13#10 +
    '  通常，只有当开发人员能够有效地重现一个错误时，它才可能被正确的修正。' +
    '作为必要的数据，您的编译环境及操作系统等资料稍后将会被收集。';
  SFeatureDescriptionDescription: string =
    '  请输入一份关于您想要的新功能的详细描述，请确认该功能对您来说确实是有用的。';
  SDetailsDescription: string =
    '  在您报告一个错误后，开发人员能够重现它，对修正错误是非常重要的。' + #13#10#13#10 +
    '  请说明您是否可以通过一些固定的步骤重现该错误，及错误重现的概率。' + #13#10#13#10 +
    '  同时，请选择您是否能在其它计算机上重现该问题，以及该错误是否只与特定的项目相关。';
  SStepsDescription: string =
    '  请输入详细的操作步骤，以帮助开发人员重现该错误。' + #13#10#13#10 +
    '  您的步骤应该以启动 IDE 开始，直到出现错误前的操作。' +
    '包括鼠标点击、按键、切换窗体，以及错误发生后的详细异常信息。' + #13#10#13#10 +
    '  如果可能，尝试用一个默认的工程、简单的工程或是 IDE 自带的例子工程来重现它。';
  SConfigurationDescription1: string =
    '';
  SConfigurationDescription2: string =
    #13#10#13#10 + '  为了保证一份有效的报告，我们推荐您保留默认的选项。稍后，在发送给我们之前，' +
    '您也可以自已编辑或删除这些设置信息。';
  SBugConfigurationDescription: string = '  您选择的所有内容都将发送给开发组，以帮助开发组重现错误并修正它。'
    + #13#10#13#10 + '  为了保证一份有效的报告，我们推荐您保留默认的选项。稍后，在发送给我们之前，' +
    '您也可以自已编辑或删除这些设置信息。';
  SFeatureConfigurationDescription: string = '  您选择的所有内容都将发送给开发组，以帮助开发组确认您所提出的建议。'
    + #13#10#13#10 + '  为了保证一份有效的报告，我们推荐您保留默认的选项。稍后，在发送给我们之前，' +
    '您也可以自已编辑或删除这些设置信息。';
  SReportDescription: string =
    '  点击“完成”按钮，将生成一封反馈邮件，您需要将剪贴板中的内容粘贴到邮件中去。' + #13#10#13#10 +
    '  或者，您也可以点击“保存”按钮将它们保存到文件中，并作为附件发送给 %s。' + #13#10#13#10 +
    '  这个向导并不会自动发送任何您不愿意公开的内容，所有内容都需要您手工发送。';

  STypeExample: string =
    '  CnPack 开发组并不打算承担任何商业开发任务。成员们都很忙，从事自由软件开发' +
    '只是我们的兴趣和追求，所以我们不会为您开发定制的组件、专家或项目。' + #13#10#13#10 +
    '  另外，专家包通常不再开发 GExperts 等免费工具中已存在的专家，您在建议时请注意。';
  SBugDescriptionExample: string =
    '  当我在 IDE 的工具条上增加专家按钮后，重新启动 IDE 却发现增加的' +
    '按钮变成了空的按钮。';
  SFeatureDescriptionExample: string =
    '  我希望可以增加一个新的编辑器工具，能够把 ' +
    {$IFDEF BCB} 'C++' {$ELSE} 'Delphi' {$ENDIF} +
    ' 代码转成 VB 的代码，这样我就可以用它来写 Outlook 邮件病毒了 :-)' + #13#10#13#10 +
    '  如果能实现的话，我会给你一份高薪又轻松的工作。';
  SDetailsExample: string =
    '';
  SStepsExample: string =
    '1. 从开始菜单中启动 ' + CompilerName + #13#10 +
    '2. 右键点击 IDE 工具栏，选择 Customize...' + #13#10 +
    '3. 拖动一个 CnPack 专家项到工具栏上' + #13#10 +
    '4. 关闭 ' + CompilerName + #13#10 +
    '5. 重新启动 ' + CompilerName + #13#10 +
    '6. 工具栏上刚才新增的按钮变成了空按钮';
  SConfigurationExample: string =
    '';
  SReportExample: string =
    '';

  SFinish: string = '完成(&F)';
  SNext: string = '下一步(&N) >';

  STitle: string = '错误报告及用户建议向导 - ';
  SBugReport: string = '错误报告。';
  SFeatureRequest: string = '功能建议。';

  SDescription: string = '描述:';
  SSteps: string = '步骤:';

  SBugDetails: string = '错误细节:';
  SBugIsReproducible: string = '  该错误有 %s%% 的概率可重现。';
  SBugIsNotReproducible: string = '  该错误不可重现。';

  SFillInReminder: string = '请记得在此粘贴生成的报告';
  SFillInReminderPaste: string = '请记得在此粘贴生成的报告';
  SFillInReminderAttach: string = '请记得在此粘贴生成的报告或附件 %s';

  SBugSteps: string =
    '1. 从开始菜单中启动 ' + CompilerName + #13#10 +
    '2. 一个默认的空工程被创建' + #13#10 +
    '3. 在主菜单中，选择...' + #13#10 +
    '4.' + #13#10 +
    '5.';

  SUnknown: string = '<未知>';
  SOutKeyboard: string = '键盘:';
  SOutLocale: string = '本地化信息:';
  SOutExperts: string = '已安装的专家:';
  SOutPackages: string = '已安装的包:';
  SOutIDEPackages: string = '已安装的 IDE 包:';
  SOutCnWizardsActive: string = 'CnPack IDE 专家启用状态:';
  SOutCnWizardsCreated: string = 'CnPack IDE 专家创建状态:';
  SOutConfig: string = '设置:';

  // CnWizUpgrade
  SCnWizNoUpgrade: string = '您当前使用的已经是最新的版本了！' + #13#10#13#10 +
    '您需要浏览每日构建版发布页面吗？';
  SCnWizUpgradeFail: string = '连接服务器失败，请稍后再试，或访问项目网站来查询更新！';
  SCnWizUpgradeCommentName: string = 'Comment';

  // CheckIDEVersion
  SCnIDENOTLatest: string = '经检测，您的 IDE 可能没有安装最新的补丁包，' +
    '这会导致 IDE 不够稳定，并且专家包的部分功能也可能得不到支持。' +
    '因此推荐您下载安装最新的补丁包。';

  // CnWizUtils
  SCnWizardForPasOrDprOnly: string = '该专家仅适用于 .pas 和 .dpr 文件';
  SCnWizardForPasOrIncOnly: string = '该专家仅适用于 .pas 和 .inc 文件';
  SCnWizardForDprOrPasOrIncOnly: string = '该专家仅适用于 .pas、.dpr 和 .inc 文件';

  // CnShortcut
  SCnDuplicateShortCutName: string = '要定义的热键名称重复: %s';

  // CnMenuAction
  SCnDuplicateCommand: string = '要定义的命令字重复: %s';
  SCnWizSubActionShortCutFormCaption: string = '%s - 快捷键设置';

  // CnWizConfigForm
  SCnWizConfigCaption: string = '设置(&O)...';
  SCnWizConfigHint: string = '设置 CnPack IDE 专家工具';
  SCnProjectWizardName: string = '工程模板向导';
  SCnFormWizardName: string = '窗体模板向导';
  SCnUnitWizardName: string = '单元模板向导';
  SCnRepositoryWizardName: string = '模板向导';
  SCnMenuWizardName: string = '标准菜单专家';
  SCnSubMenuWizardName: string = '带子菜单项专家';
  SCnActionWizardName: string = '快捷键专家';
  SCnIDEEnhanceWizardName: string = 'IDE 功能扩展专家';
  SCnBaseWizardName: string = '普通专家';
  SCnWizardNameStr: string = '名称: ';
  SCnWizardShortCutStr: string = '热键: ';
  SCnWizardStateStr: string = '状态: ';
  SCnWizardActiveStr: string = '有效';
  SCnWizardDisActiveStr: string = '禁用';
  SCnWizCommentReseted: string = '所有专家的功能提示窗体已重新开启！' + #13#10 +
    '使用专家工具时您将会得到功能提示。';

  SCnSelectDir: string = '选择一个文件夹';
  SCnQueryAbort: string = '您确定要中断当前操作吗？';

  SCnExportPCDirCaption: string = '请选择控件列表与包列表保存的文件夹';
  SCnExportPCSucc: string = '已经成功保存控件列表文件 %s 和包列表文件 %s';
  // CnWizAbout
  SCnConfigIONotExists: string = '无法运行导入导出工具，请重新安装专家包！';

  // CnMessageBoxWizard
  SCnMsgBoxMenuCaption: string = 'MessageBox(&M)...';
  SCnMsgBoxMenuHint: string = '可视化创建 MessageBox 函数调用代码';
  SCnMsgBoxName: string = 'MessageBox 设计器';
  SCnMsgBoxComment: string = '用于可视化创建 MessageBox 函数调用代码。';
  SCnMsgBoxProjectCaption: string = '新增模板';
  SCnMsgBoxProjectPrompt: string = '请输入模板名称:';
  SCnMsgBoxProjectDefaultName: string = '模板';
  SCnMsgBoxProjectExists: string = '您输入的模板名已存在，您确认要覆盖吗？';
  SCnMsgBoxDeleteProject: string = '您确认要删除该模板吗？';
  SCnMsgBoxCannotDelLastProject: string = '您不能删除自动保存模板！';

  // CnComponentSelector
  SCnCompSelectorMenuCaption: string = '组件选取(&S)...';
  SCnCompSelectorMenuHint: string = '使用多种方式批量选取组件';
  SCnCompSelectorName: string = '组件选取工具';
  SCnCompSelectorComment: string = '允许用户使用多种方式批量选取组件。';
  SCnCompSelectorNotSupport: string = '组件选取工具只支持窗体和 Frame！';

  // CnTabOrderWizard
  SCnTabOrderMenuCaption: string = '设置Tab Order(&T)';
  SCnTabOrderMenuHint: string = '自动设置控件的 Tab Order 值';
  SCnTabOrderName: string = 'Tab Order 设置工具';
  SCnTabOrderComment: string = '可以根据定义自动设置控件的 Tab Order 值。';
  SCnTabOrderSetCurrControlCaption: string = '已选择的控件(&C)';
  SCnTabOrderSetCurrControlHint: string = '自动设置当前选择控件的 Tab Order 值。' + #13#10 +
    '如果选择的控件包含子控件，则设置其子控件；' + #13#10 +
    '反之设置该控件的父控件下的子控件。';
  SCnTabOrderSetCurrFormCaption: string = '当前窗体所有控件(&F)';
  SCnTabOrderSetCurrFormHint: string = '自动设置当前窗体上所有控件的 Tab Order';
  SCnTabOrderSetOpenedFormCaption: string = '所有打开的窗体(&E)';
  SCnTabOrderSetOpenedFormHint: string = '自动设置所有打开窗体上所有控件的 Tab Order';
  SCnTabOrderSetProjectCaption: string = '当前工程所有窗体(&P)';
  SCnTabOrderSetProjectHint: string = '自动设置当前工程所有窗体上所有控件的 Tab Order';
  SCnTabOrderSetProjectGroupCaption: string = '当前工程组所有窗体(&G)';
  SCnTabOrderSetProjectGroupHint: string = '自动设置当前工程组所有窗体上所有控件的 Tab Order';
  SCnTabOrderDispTabOrderCaption: string = '显示控件Tab Order(&D)';
  SCnTabOrderDispTabOrderHint: string = '是否允许在设计期显示窗口控件的 Tab Order';
  SCnTabOrderAutoResetCaption: string = '移动控件自动设置(&A)';
  SCnTabOrderAutoResetHint: string = '当控件位置移动时是否自动更新 Tab Order';
  SCnTabOrderConfigCaption: string = '设置(&O)...';
  SCnTabOrderConfigHint: string = '显示 Tab Order 设置工具的配置窗口。';
  SCnTabOrderSucc: string = '成功处理了 %d 个窗体上的控件！';
  SCnTabOrderFail: string = '没有需要处理的窗体！';

  // CnDfm6To5Wizard
  SCnDfm6To5WizardMenuCaption: string = '打开高版本窗体(&H)...';
  SCnDfm6To5WizardMenuHint: string = '打开由高版本编译器创建的窗体单元';
  SCnDfm6To5WizardName: string = '打开高版本窗体工具';
  SCnDfm6To5WizardComment: string = '打开由高版本编译器创建的窗体单元。';
  SCnDfm6To5OpenError: string = '文件打开失败！'
    + #13#10#13#10 + '文件名: %s';
  SCnDfm6To5SaveError: string = '写文件失败，请检查文件的只读属性！'
    + #13#10#13#10 + '文件名: %s';
  SCnDfm6To5InvalidFormat: string = '窗体文件格式转换失败！'
    + #13#10#13#10 + '文件名: %s';

  // CnBookmarkWizard
  SCnBookmarkWizardMenuCaption: string = '书签浏览(&B)...';
  SCnBookmarkWizardMenuHint: string = '浏览当前打开文件中所有的书签';
  SCnBookmarkWizardName: string = '书签浏览专家';
  SCnBookmarkWizardComment: string = '浏览当前打开文件中所有的书签。';
  SCnBookmarkAllUnit: string = '<全部单元>';
  SCnBookmarkFileCount: string = '单元总数: %d';

  // CnEditorWizard
  SCnEditorWizardMenuCaption: string = '代码编辑器专家(&E)';
  SCnEditorWizardMenuHint: string = '代码编辑器增强工具集';
  SCnEditorWizardName: string = '代码编辑器专家';
  SCnEditorWizardComment: string = '代码编辑器增强工具集。';
  SCnEditorWizardConfigCaption: string = '设置(&O)...';
  SCnEditorWizardConfigHint: string = '设置代码编辑器增强工具';

  // CnEditorCodeTool
  SCnEditorCodeToolSelIsEmpty: string = '请先选择要进行处理的代码！';
  SCnEditorCodeToolNoLine: string = '无法获得需要处理的代码！';

  // CnEditorCodeSwap
  SCnEditorCodeSwapMenuCaption: string = '赋值交换(&C)';
  SCnEditorCodeSwapName: string = '赋值交换工具';
  SCnEditorCodeSwapMenuHint: string = '交换当前选择代码中赋值符两边的内容';

  // CnEditorCodeToString
  SCnEditorCodeToStringMenuCaption: string = '转换为字符串(&S)';
  SCnEditorCodeToStringName: string = '代码转字符串工具';
  SCnEditorCodeToStringMenuHint: string = '将当前选择的代码转换成字符串';

  // CnEditorCodeDelBlank
  SCnEditorCodeDelBlankMenuCaption: string = '删除空行(&D)...';
  SCnEditorCodeDelBlankName: string = '删除空行工具';
  SCnEditorCodeDelBlankMenuHint: string = '按需要删除代码中的空行';

  // CnEditorOpenFile
  SCnEditorOpenFileMenuCaption: string = '打开文件(&P)...';
  SCnEditorOpenFileName: string = '打开文件工具';
  SCnEditorOpenFileMenuHint: string = '直接根据文件名在搜索路径中查找并打开文件';
  SCnEditorOpenFileDlgCaption: string = '打开文件';
  SCnEditorOpenFileDlgHint: string = '输入文件名:';
  SCnEditorOpenFileNotFind: string = '在搜索路径及系统路径中没有找到指定的文件！';

  // CnEditorZoomFullScreen
  SCnEditorZoomFullScreenMenuCaption: string = '代码窗口全屏切换(&F)';
  SCnEditorZoomFullScreenMenuHint: string = '代码编辑器窗口在正常和全屏之间切换';
  SCnEditorZoomFullScreen: string = '代码窗口全屏切换工具';
  SCnEditorZoomFullScreenNoEditor: string = '未找到代码编辑器窗口或代码编辑器窗口处于停靠状态，无法进行全屏切换';

  // CnEditorCodeComment
  SCnEditorCodeCommentMenuCaption: string = '注释代码块(&B)';
  SCnEditorCodeCommentMenuHint: string = '用双斜线注释掉选中的代码块';
  SCnEditorCodeCommentName: string = '代码块注释工具';

  // CnEditorCodeUnComment
  SCnEditorCodeUnCommentMenuCaption: string = '取消代码块注释(&U)';
  SCnEditorCodeUnCommentMenuHint: string = '取消选中的用双斜线注释掉的代码块的注释';
  SCnEditorCodeUnCommentName: string = '代码块取消注释工具';

  // CnEditorCodeToggleComment
  SCnEditorCodeToggleCommentMenuCaption: string = '反转代码块注释(&I)';
  SCnEditorCodeToggleCommentMenuHint: string = '反转选中的代码块的注释';
  SCnEditorCodeToggleCommentName: string = '反转代码块注释工具';

  // CnEditorCodeIndent
  SCnEditorCodeIndentMenuCaption: string = '代码块缩进(&R)';
  SCnEditorCodeIndentMenuHint: string = '代码块向右缩进';
  SCnEditorCodeIndentName: string = '代码块缩进工具';

  // CnEditorCodeUnIndent
  SCnEditorCodeUnIndentMenuCaption: string = '代码块反缩进(&L)';
  SCnEditorCodeUnIndentMenuHint: string = '代码块反缩进';
  SCnEditorCodeUnIndentName: string = '代码块反缩进工具';

  // CnAsciiChart
  SCnAsciiChartMenuCaption: string = 'ASCII 字符表(&A)';
  SCnAsciiChartMenuHint: string = '显示 ASCII 字符表';
  SCnAsciiChartName: string = 'ASCII 字符表';

  // CnEditorInsertColor
  SCnEditorInsertColorMenuCaption: string = '插入颜色(&N)';
  SCnEditorInsertColorMenuHint: string = '插入颜色';
  SCnEditorInsertColorName: string = '插入颜色工具';

  // CnEditorInsertTime
  SCnEditorInsertTimeMenuCaption: string = '插入日期时间(&T)';
  SCnEditorInsertTimeMenuHint: string = '插入日期时间';
  SCnEditorInsertTimeName: string = '插入日期时间工具';

  // CnEditorCollector
  SCnEditorCollectorMenuCaption: string = '收集面板(&G)';
  SCnEditorCollectorMenuHint: string = '收集面板';
  SCnEditorCollectorName: string = '收集面板';
  SCnEditorCollectorInputCaption: string = '请输入标签名';

  // CnEditorSortLines
  SCnEditorSortLinesMenuCaption: string = '选择行排序(&S)';
  SCnEditorSortLinesMenuHint: string = '选择行排序';
  SCnEditorSortLinesName: string = '选择行排序工具';

  // CnEditorToggleVar
  SCnEditorToggleVarMenuCaption: string = '切换局部变量(&V)';
  SCnEditorToggleVarMenuHint: string = '切换局部变量编辑区';
  SCnEditorToggleVarName: string = '切换局部变量编辑区工具';

  // CnEditorToggleUses
  SCnEditorToggleUsesMenuCaption: string = '切换引用(&X)';
  SCnEditorToggleUsesMenuHint: string = '切换引用区';
  SCnEditorToggleUsesName: string = '切换引用区工具';

  // CnEditorPrevMessage
  SCnEditorPrevMessageMenuCaption: string = '跳至上一信息行(&E)';
  SCnEditorPrevMessageMenuHint: string = '在编辑器中跳至信息区所标识的上一行';
  SCnEditorPrevMessageName: string = '跳至上一信息行工具';

  // CnEditorNextMessage
  SCnEditorNextMessageMenuCaption: string = '跳至下一信息行(&F)';
  SCnEditorNextMessageMenuHint: string = '在编辑器中跳至信息区所标识的下一行';
  SCnEditorNextMessageName: string = '跳至下一信息行工具';

  // CnEditorJumpIntf
  SCnEditorJumpIntfMenuCaption: string = '跳至 interface(&Q)';
  SCnEditorJumpIntfMenuHint: string = '跳至单元的 interface 部分';
  SCnEditorJumpIntfName: string = '跳至声明区工具';

  // CnEditorJumpImpl
  SCnEditorJumpImplMenuCaption: string = '跳至 implementation(&M)';
  SCnEditorJumpImplMenuHint: string = '跳至单元的 implementation 部分';
  SCnEditorJumpImplName: string = '跳至实现区工具';

  // CnEditorJumpMatchedKeyword
  SCnEditorJumpMatchedKeywordMenuCaption: string = '跳至匹配的关键字(&K)';
  SCnEditorJumpMatchedKeywordMenuHint: string = '跳至光标下匹配的关键字';
  SCnEditorJumpMatchedKeywordName: string = '跳至匹配关键字工具';

  // CnSrcTemplate
  SCnSrcTemplateMenuCaption: string = '源码模板专家(&K)';
  SCnSrcTemplateMenuHint: string = '源代码及注释模板';
  SCnSrcTemplateName: string = '源码模板专家';
  SCnSrcTemplateComment: string = '源代码及注释模板。';
  SCnSrcTemplateConfigCaption: string = '设置(&O)...';
  SCnSrcTemplateConfigHint: string = '设置源代码及注释模板';

  SCnSrcTemplateCaptionIsEmpty: string = '编辑器模板菜单标题不能为空！';
  SCnSrcTemplateContentIsEmpty: string = '编辑器模板内容不能为空！';
  SCnSrcTemplateReadDataError: string = '读取编辑器专家数据文件错误！';
  SCnSrcTemplateWriteDataError: string = '保存编辑器专家数据文件错误！';
  SCnSrcTemplateImportAppend: string = '是否使用追加方式将数据追加到当前的模板库中？';
  SCnSrcTemplateWizardDelete: string = '您确认要删除该编辑器模板吗？';
  SCnSrcTemplateWizardClear: string = '您确认要删除所有的编辑器模板吗？';

  SCnSrcTemplateDataDefName: string = 'Editor_CHS.cdt';

  SCnEIPCurrPos: string = '当前光标处';
  SCnEIPBOL: string = '当前行行首';
  SCnEIPEOL: string = '当前行行末';
  SCnEIPBOF: string = '单元头部';
  SCnEIPEOF: string = '单元尾部';
  SCnEIPProcHead: string = '当前光标后下一过程头部';

  SCnEMVProjectDir: string = '工程目录';
  SCnEMVProjectName: string = '工程名称';
  SCnEMVProjectGroupDir: string = '工程组目录';
  SCnEMVProjectGroupName: string = '工程组名称';
  SCnEMVUnit: string = '单元名称';
  SCnEMVProceName: string = '当前光标后下一过程名称';
  SCnEMVResult: string = '函数返回值';
  SCnEMVArguments: string = '过程参数';
  SCnEMVArgList: string = '过程参数列表块';
  SCnEMVRetType: string = '函数返回值类型块';
  SCnEMVCurProceName: string = '当前光标所在的过程名称';
  SCnEMVCurMethodName: string = '当前光标所在的方法名称（无类名）';
  SCnEMVCurClassName: string = '当前光标所在的类名';
  SCnEMVUser: string = '当前登录用户';
  SCnEMVDateTime: string = '当前日期时间';
  SCnEMVDate: string = '当前日期';
  SCnEMVYear: string = '年份';
  SCnEMVMonth: string = '月';
  SCnEMVMonthShortName: string = '短格式月';
  SCnEMVMonthLongName: string = '长格式月';
  SCnEMVDay: string = '日';
  SCnEMVDayShortName: string = '短格式日';
  SCnEMVDayLongName: string = '长格式日';
  SCnEMVHour: string = '时';
  SCnEMVMinute: string = '分';
  SCnEMVSecond: string = '秒';
  SCnEMVCodeLines: string = '单元代码行数';
  SCnEMVColPos: string = '用空格填充到指定列（例%ColPos80%）';
  SCnEMVCursor: string = '插入后的光标位置，如有多个，以最后一个为准';

  // CnMsdnWizard
  SCnMsdnWizardName: string = 'MSDN 帮助专家';
  SCnMsdnWizardMenuCaption: string = 'MSDN 帮助专家(&D)';
  SCnMsdnWizardMenuHint: string = '在 IDE 中打开 MSDN 帮助';
  SCnMsdnWizardRunConfigCaption: string = '设置(&O)...';
  SCnMsdnWizardRunConfigHint: string = '设置 MSDN 选项';
  SCnMsdnWizardRunMsdnCaption: string = 'MSDN 帮助(&H)...';
  SCnMsdnWizardRunMsdnHint: string = '打开 MSDN 帮助';
  SCnMsdnWizardRunSearchCaption: string = 'MSDN 搜索(&S)...';
  SCnMsdnWizardRunSearchHint: string = '打开 MSDN 搜索';

  SCnMsdnWizardComment: string = 'MSDN 帮助在线调用工具，允许在 IDE 中调用 MSDN 帮助。';
  SCnMsdnToolBarCaption: string = 'MSDN Help';
  SCnMsdnSelectKeywordHint: string = '请选择要在 MSDN 中查找的关键字';
  SCnMsdnNoMsdnInstalled: string = '请先安装 MSDN ！';
  SCnMsdnNoLanguage: string = '首选语言 [%s] 不存在！';
  SCnMsdnNoCollection: string = '首选版本 [%s] 不存在！';
  SCnMsdnRegError: string = '从注册表中读取 MSDN 安装信息出错！';
  SCnMsdnConnectToServerError: string = '连接服务程序异常！';
  SCnMsdnDisconnectServerError: string = '断开连接服务程序异常！';
  SCnMsdnIsInvalidURL: string = '网页地址无效！';
  SCnMsdnShowKeywordFailed: string = '显示关键字失败！';
  SCnMsdnOpenIndexFailed: string = '打开索引失败！';
  SCnMsdnOpenSearchFailed: string = '打开搜索失败！';

  // CnPas2HtmlWizard
  SCnPas2HtmlWizardMenuCaption: string = '带格式代码输出(&L)';
  SCnPas2HtmlWizardMenuHint: string = '将代码转换成 HTML 或 RTF 格式输出';
  SCnPas2HtmlWizardName: string = '带格式代码输出工具';
  SCnPas2HtmlWizardComment: string = '将代码转换成 HTML 或 RTF 格式输出。';

  SCnPas2HtmlWizardCopySelectedCaption: string = '复制 HTML 到剪贴板(&C)';
  SCnPas2HtmlWizardCopySelectedHint: string = '将当前编辑区的选中代码块转换成 HTML 格式后放入剪贴板';

  SCnPas2HtmlWizardExportUnitCaption: string = '输出当前文件(&U)...';
  SCnPas2HtmlWizardExportUnitHint: string = '将当前编辑的 Unit 输出成 HTML 文件或 RTF 文件';

  SCnPas2HtmlWizardExportOpenedCaption: string = '输出打开的文件(&A)...';
  SCnPas2HtmlWizardExportOpenedHint: string = '将所有打开的 Unit 输出成 HTML 文件或 RTF 文件';

  SCnPas2HtmlWizardExportDPRCaption: string = '输出当前工程(&P)...';
  SCnPas2HtmlWizardExportDPRHint: string = '将当前工程中的所有 Unit 输出成 HTML 文件或 RTF 文件';

  SCnPas2HtmlWizardExportBPGCaption: string = '输出当前工程组(&G)...';
  SCnPas2HtmlWizardExportBPGHint: string = '将当前工程组中的所有 Unit 输出成 HTML 文件或 RTF 文件';

  SCnPas2HtmlWizardConfigCaption: string = '设置(&O)...';
  SCnPas2HtmlWizardConfigHint: string = '格式输出设置';

  SCnSelectDirCaption: string = '请选择输出文件保存的目录';
  SCnDispCaption: string = '正在转换 %s';
  SCnPas2HtmlErrorNOTSupport: string = '本向导只支持 Pascal/C/C++ 工程/文件转换。';
  SCnPas2HtmlErrorConvertProject: string = '转换工程文件失败！';
  SCnPas2HtmlErrorConvert: string = '转换失败！文件 %s';
  SCnPas2HtmlDefEncode: string = 'gb2312';

  // CnWizEditFiler
  SCnFileDoesNotExist: string = '文件 %s 不存在！';
  SCnNoEditorInterface: string = 'FEditRead: 文件 %s 没有找到编辑器接口！';
  SCnNoModuleNotifier: string = 'TCnEditFiler: 文件 %s 无法取得模块通知器！';

  // CnReplaceWizard
  SCnReplaceWizardMenuCaption: string = '批量文件替换(&R)...';
  SCnReplaceWizardMenuHint: string = '在多个文件中执行查找替换';
  SCnReplaceWizardName: string = '批量文件替换专家';
  SCnReplaceWizardComment: string = '在多个文件中执行查找替换。';

  SCnLineLengthError: string = '程序发现文件中一行的长度超过了 %d 字符。' + #13#10 +
    '文件名: %s' + #13#10 +
    '这可能是因为该文件是一个不支持的二进制文件。';
  SCnClassNotTerminated: string = '第 %d 个字符为不匹配的 "[" 标记！' + #13#10 +
    '关于正则表达式的使用说明，请查看帮助文件。';
  SCnPatternTooLong: string = '查找内容长度大于 500 字符！';
  SCnInvalidGrepSearchCriteria: string = '第 %d 个字符的描述符 ":" 后面是一个无效的字符！' + #13#10 +
    '关于正则表达式的使用说明，请查看帮助文件。';
  SCnSenselessEscape: string = '转义符 "\" 后面没有发现有效的字符！' + #13#10 +
    '关于正则表达式的使用说明，请查看帮助文件。';

  SCnReplaceSourceEmpty: string = '查找文本不能为空！';
  SCnReplaceDirEmpty: string = '查找目录时目录不能为空！';
  SCnReplaceDirNotExists: string = '指定的目录不存在！';
  SCnReplaceSelectDirCaption: string = '选择文件夹';

  SCnSaveFileError: string = '保存文件出错，文件可能具有只读属性！' + #13#10 +
    '文件名: %s';
  SCnSaveEditFileError: string = '写编辑器源码出错，源码可能具有只读属性！' + #13#10 +
    '文件名: %s';
  SCnReplaceWarning: string = '批量文件替换可能会修改多个文件！' + #13#10 +
    '请确认您确实要执行此次操作！' + #13#10#13#10 + '是否继续？';
  SCnReplaceResult: string = '文本替换完成！' + #13#10#13#10 +
    '在查找的 %d 个文件中，一共进行了 %d 处替换。';
  SCnReplaceQueryContinue: string = '是否继续替换其它文件？';

  // CnSourceDiffWizard
  SCnSourceDiffWizardMenuCaption: string = '源代码比较(&F)...';
  SCnSourceDiffWizardMenuHint: string = '对源代码进行比较和代码拼合';
  SCnSourceDiffWizardName: string = '源代码比较专家';
  SCnSourceDiffWizardComment: string = '对源代码进行比较和代码拼合。';
  SCnSourceDiffCaseIgnored: string = '忽略大小写';
  SCnSourceDiffBlanksIgnored: string = '忽略空白字符';
  SCnSourceDiffChanges: string = '文件变更数: %d %s';
  SCnSourceDiffApprox: string = '已完成百分数: %d%%';
  SCnSourceDiffOpenError: string = '打开文件失败！';
  SCnSourceDiffOpenFile: string = '打开文件(&O)...';
  SCnSourceDiffUpdateFile: string = '刷新当前文件(&U)';
  SCnDiskFile: string = '文件';
  SCnEditorBuff: string = '内存';
  SCnBakFile: string = '备份';

  // CnStatWizard
  SCnStatWizardMenuCaption: string = '源代码统计(&J)...';
  SCnStatWizardMenuHint: string = '对源代码进行统计';
  SCnStatWizardName: string = '源代码统计专家';
  SCnStatWizardComment: string = '对源代码进行统计。';

  SCnStatDirEmpty: string = '查找目录时目录不能为空！';
  SCnStatDirNotExists: string = '指定的目录不存在！';

  SCnStatSelectDirCaption: string = '请选择源代码目录';
  SCnStatusBarFmtString: string = '共统计 %s 个文件，共 %s 字节，有效行共 %s 行。';
  SCnStatusBarFindFileFmt: string = '已搜索到 %s 个文件';
  SCnStatClearResult: string = '正在准备进行新的统计……';
  SCnErrorNoFile: string = '文件不存在。';
  SCnErrorNoFind: string = '未找到字符串：%s';

  SCnStatBytesFmtStr: string = '字节数 %s，代码 %s 字节，注释 %s 处，注释共 %s 字节。';
  SCnStatLinesFmtStr: string = '总行数 %s，代码 %s 行，注释 %s 行，空行 %s 行，有效行 %s 行。';
  SCnStatFilesCaption: string = '所有文件汇总';
  SCnStatProjectName: string = '工程：%s';
  SCnStatProjectFiles: string = '文件数目 %s，总共 %s 字节。';
  SCnStatProjectBytes: string = '代码 %s 字节，注释 %s 字节。';
  SCnStatProjectLines1: string = '行数 %s，有效行 %s，空行 %s。';
  SCnStatProjectLines2: string = '代码 %s 行，注释 %s 处 %s 行。';
  SCnStatProjectGroupName: string = '工程组：%s';
  SCnStatProjectGroupFiles: string = '%s 工程，%s 文件，总共 %s 字节。';
  SCnStatProjectGroupBytes: string = '代码 %s 字节，注释 %s 字节。';
  SCnStatProjectGroupLines1: string = '行数 %s，有效行 %s，空行 %s。';
  SCnStatProjectGroupLines2: string = '代码 %s 行，注释 %s 处 %s 行。';
  SCnStatNoProject: string = '无工程信息。';
  SCnStatNoProjectGroup: string = '无工程组信息。';

  SCnStatExpTitle: string = '源代码统计结果输出'#13#10'由 CnPack IDE 专家包生成'#13#10'%s';
  SCnStatExpDefFileName: string = 'StatResult';
  SCnStatExpProject: string = '工程 %s 总体数据统计：';
  SCnStatExpProjectGroup: string = '工程组 %s 总体数据统计：';
  SCnStatExpFileName: string = '文件名：%s';
  SCnStatExpFileDir: string = '所在目录：%s';
  SCnStatExpFileBytes: string = '总字节数：%s';
  SCnStatExpFileCodeBytes: string = '代码字节数：%s';
  SCnStatExpFileCommentBytes: string = '注释字节数：%s';
  SCnStatExpFileAllLines: string = '总行数：%s';
  SCnStatExpFileEffectiveLines: string = '有效行数：%s';
  SCnStatExpFileBlankLines: string = '空行数：%s';
  SCnStatExpFileCodeLines: string = '代码行数：%s';
  SCnStatExpFileCommentLines: string = '注释行数：%s';
  SCnStatExpFileCommentBlocks: string = '注释块数：%s';
  SCnStatExpSeperator: string = #13#10'--------------------------'#13#10;

  SCnStatExpCSVTitleFmt: string = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';
  SCnStatExpCSVLineFmt: string = '%s%s%s%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s%d';
  SCnStatExpCSVProject: string = '工程总体数据';
  SCnStatExpCSVProjectGroup: string = '工程组总体数据';
  SCnStatExpCSVFileName: string = '文件名';
  SCnStatExpCSVFileDir: string = '所在目录';
  SCnStatExpCSVBytes: string = '总字节数';
  SCnStatExpCSVCodeBytes: string = '代码字节数';
  SCnStatExpCSVCommentBytes: string = '注释字节数';
  SCnStatExpCSVAllLines: string = '总行数';
  SCnStatExpCSVEffectiveLines: string = '有效行数';
  SCnStatExpCSVBlankLines: string = '空行数';
  SCnStatExpCSVCodeLines: string = '代码行数';
  SCnStatExpCSVCommentLines: string = '注释行数';
  SCnStatExpCSVCommentBlocks: string = '注释块数';
  SCnDoNotStat: string = '非源代码文件不做统计。';

  // CnPrefixWizard
  SCnPrefixWizardMenuCaption: string = '组件前缀专家(&P)...';
  SCnPrefixWizardMenuHint: string = '对组件名按标准前缀进行改名';
  SCnPrefixWizardName: string = '组件前缀专家';
  SCnPrefixWizardComment: string = '对组件名按标准前缀进行改名。';
  SCnPrefixInputError: string = '请输入有效的标识符作为组件前缀！';
  SCnPrefixNameError: string = '请输入有效的标识符作为组件名！';
  SCnPrefixDupName: string = '窗体中已经有一个同名的组件了，请重新输入组件名！';
  SCnPrefixNoComp: string = '在您选择的范围中没有需要改名的组件！';
  SCnPrefixAskToProcess: string = '您确实要对这些组件的名称进行处理吗？';

  // CnWizAbout
  // CnWizAboutForm
  SCnWizAboutCaption: string = '帮助(&A)';
  SCnWizAboutHelpCaption: string = '帮助主题(&I)...';
  SCnWizAboutHistoryCaption: string = '历史修改记录(&H)...';
  SCnWizAboutTipOfDaysCaption: string = '每日一帖(&D)...';
  SCnWizAboutBugReportCaption: string = '错误报告及建议(&R)...';
  SCnWizAboutUpgradeCaption: string = '检查更新(&U)...';
  SCnWizAboutConfigIOCaption: string = '设置导入导出(&E)...';
  SCnWizAboutUrlCaption: string = '访问开发网站(&W)';
  SCnWizAboutBbsCaption: string = '访问用户论坛(&B)';
  SCnWizAboutMailCaption: string = '发送邮件(&M)';

  SCnWizAboutAboutCaption: string = '关于(&A)...';
  SCnWizAboutHint: string = '帮助及其它工具';
  SCnWizAboutHelpHint: string = '显示 CnPack 专家包帮助文件';
  SCnWizAboutHistoryHint: string = '显示 CnPack 专家包历史修改记录';
  SCnWizAboutTipOfDayHint: string = '显示”每日一帖“';
  SCnWizAboutBugReportHint: string = '打开错误报告及建议向导';
  SCnWizAboutUpgradeHint: string = '通过互联网检查最新的更新信息';
  SCnWizAboutConfigIOHint: string = '导入导出 CnPack IDE 专家包设置';
  SCnWizAboutUrlHint: string = '访问 CnPack 开发网站';
  SCnWizAboutBbsHint: string = '访问 CnPack 用户论坛';
  SCnWizAboutMailHint: string = '写信给 CnPack 开发组';
  SCnWizAboutAboutHint: string = '关于 CnPack 专家包';
  SCnWizMailSubject: string = '关于 CnPack 开发包。';

  // CnEditorEnhancements
  SCnEditorEnhanceWizardName: string = '代码编辑器扩展';
  SCnEditorEnhanceWizardComment: string = '扩展代码编辑器的功能';
  SCnMenuCloseOtherPagesCaption: string = '关闭其它的页面';
  SCnMenuShellMenuCaption: string = '外壳关联菜单';
  SCnMenuSelAllCaption: string = '选择全部';
  SCnMenuBlockToolsCaption: string = 'CnPack 编辑菜单';
  SCnMenuExploreCaption: string = '在资源管理器中打开 "%s"';
  SCnMenuCopyFileNameMenuCaption: string = '复制完整的路径名/文件名';
  SCnEditorEnhanceConfig: string = '编辑器扩展设置(&C)...';

  SCnToolBarClose: string = '关闭编辑器工具栏(&H)';
  SCnToolBarCloseHint: string = '您已经选择了关闭编辑器工具栏。'#13#10#13#10 +
    '如果您以后需要重新显示此工具栏，可在编辑器扩展设置窗口中勾选'#13#10 +
    '“在编辑器中显示工具栏”来实现。';

  SCnLineNumberGotoLine: string = '跳至行号(&G)...';
  SCnLineNumberGotoBookMark: string = '跳至书签(&J)';
  SCnLineNumberClearBookMarks: string = '清除所有书签(&R)';
  SCnLineNumberShowIDELineNum: string = '显示 IDE 行号(&I)';
  SCnLineNumberClose: string = '关闭行号显示(&X)';

  SCnSrcEditorNavIDEBack: string = 'IDE 后退 (Shift+Click)';
  SCnSrcEditorNavIDEForward: string = 'IDE 前进 (Shift+Click)';
  SCnSrcEditorNavIDEBackList: string = 'IDE 后退列表';
  SCnSrcEditorNavIDEForwardList: string = 'IDE 前进列表';
  SCnSrcEditorNavPause: string = '暂用 IDE 跳转功能';

  // CnSrcEditorBlockTools
  SCnSrcBlockToolsHint: string = '选择文本相关操作';

  SCnSrcBlockEdit: string = '编辑(&E)';
  SCnSrcBlockCopy: string = '复制到剪贴板(&C)';
  SCnSrcBlockCopyAppend: string = '追加复制到剪贴板(&E)';
  SCnSrcBlockDuplicate: string = '在当前位置重复(&U)';
  SCnSrcBlockCut: string = '剪切到剪贴板(&T)';
  SCnSrcBlockCutAppend: string = '追加剪切到剪贴板(&F)';
  SCnSrcBlockDelete: string = '删除(&D)';
  SCnSrcBlockSaveToFile: string = '保存到文件(&S)...';

  SCnSrcBlockCase: string = '大小写转换(&A)';
  SCnSrcBlockLowerCase: string = '转换为小写(&L)';
  SCnSrcBlockUpperCase: string = '转换为大写(&U)';
  SCnSrcBlockToggleCase: string = '大小写互换(&T)';

  SCnSrcBlockFormat: string = '格式处理(&F)';
  SCnSrcBlockIndent: string = '代码缩进(&I)';
  SCnSrcBlockIndentEx: string = '代码缩进指定列(&J)...';
  SCnSrcBlockUnindent: string = '代码反缩进(&U)';
  SCnSrcBlockUnindentEx: string = '代码反缩进指定列(&V)...';
  SCnSrcBlockIndentCaption: string = '代码缩进';
  SCnSrcBlockIndentPrompt: string = '请输入要缩进的代码列数:';
  SCnSrcBlockUnindentCaption: string = '代码反缩进';
  SCnSrcBlockUnindentPrompt: string = '请输入要反缩进的代码列数:';

  SCnSrcBlockComment: string = '代码注释(&M)';

  SCnSrcBlockWrap: string = '代码嵌入(&B)';
  SCnSrcBlockWrapBy: string = '嵌入到 %s 中';
  
  SCnSrcBlockReplace: string = '组替换(&P)';

  SCnSrcBlockSearch: string = 'Web 搜索(&W)';
  SCnWebSearchFileDef: string = 'WebSearch_CHS.xml';

  SCnSrcBlockMisc: string = '其它(&O)';

  // CnSrcEditorKey
  SCnRenameVarCaption: string = '标识符改名';
  SCnRenameVarHintFmt: string = '替换 %s 为：';
  SCnRenameErrorValid: string = '标识符非法，无法进行替换';
  
  // CnFormEnhancements
  SCnFormEnhanceWizardName: string = '窗体设计器扩展';
  SCnFormEnhanceWizardComment: string = '扩展窗体设计器的功能';
  SCnMenuFlatFormCustomizeCaption: string = '定制工具面板(&O)...';
  SCnMenuFlatFormConfigCaption: string = '设置(&N)...';
  SCnMenuFlagFormPosCaption: string = '工具面板位置(&P)';
  SCnMenuFlatPanelTopLeft: string = '上方左边(&1)';
  SCnMenuFlatPanelTopRight: string = '上方右边(&2)';
  SCnMenuFlatPanelBottomLeft: string = '下方左边(&3)';
  SCnMenuFlatPanelBottomRight: string = '下方右边(&4)';
  SCnMenuFlatPanelLeftTop: string = '左方上边(&5)';
  SCnMenuFlatPanelLeftBottom: string = '左方下边(&6)';
  SCnMenuFlatPanelRightTop: string = '右方上边(&7)';
  SCnMenuFlatPanelRightBottom: string = '右方下边(&8)';
  SCnMenuFlatFormAllowDragCaption: string = '允许拖动工具栏(&D)';
  SCnMenuFlagFormImportCaption: string = '从文件中导入(&I)...';
  SCnMenuFlagFormExportCaption: string = '导出到文件(&E)...';
  SCnMenuFlatFormCloseCaption: string = '关闭(&C)';
  SCnMenuFlatFormDataFileFilter: string = '浮动工具面板设置文件(*.ini)|*.ini';
  SCnFlatToolBarRestoreDefault: string = '您确定要删除自定义的工具栏，恢复默认设置吗？';
  SCnFloatPropBarFilterCaption: string = '只显示自定义的属性';
  SCnFloatPropBarRenameCaption: string = '修改组件名称';
  SCnEmbeddedDesignerNotSupport: string = '本工具只支持非嵌入模式的 VCL 设计期窗体';

  // CnAlignSizeWizard
  SCnAlignSizeMenuCaption: string = '窗体设计专家(&Z)';
  SCnAlignSizeMenuHint: string = '对选择控件进行对齐及大小设置';
  SCnAlignSizeName: string = '窗体设计专家';
  SCnAlignSizeComment: string = '允许使用菜单项或浮动面板对选择控件进行对齐及缩放设置。';

  SCnAlignLeftCaption: string = '左边对齐';
  SCnAlignLeftHint: string = '左对齐所选控件，选择两个控件以上时有效';
  SCnAlignRightCaption: string = '右边对齐';
  SCnAlignRightHint: string = '右对齐所选控件，选择两个控件以上时有效';
  SCnAlignTopCaption: string = '上边对齐';
  SCnAlignTopHint: string = '上边对齐所选控件，选择两个控件以上时有效';
  SCnAlignBottomCaption: string = '下边对齐';
  SCnAlignBottomHint: string = '下边对齐所选控件，选择两个控件以上时有效';
  SCnAlignHCenterCaption: string = '水平中心对齐';
  SCnAlignHCenterHint: string = '水平中心对齐所选控件，选择两个控件以上时有效';
  SCnAlignVCenterCaption: string = '垂直中心对齐';
  SCnAlignVCenterHint: string = '垂直中心对齐所选控件，选择两个控件以上时有效';
  SCnSpaceEquHCaption: string = '水平方向等间距';
  SCnSpaceEquHHint: string = '水平方向等间距，选择三个控件以上时有效';
  SCnSpaceEquHXCaption: string = '水平方向自定义等间距';
  SCnSpaceEquHXHint: string = '水平方向自定义等间距，选择两个控件以上时有效';
  SCnSpaceIncHCaption: string = '水平方向扩大间距';
  SCnSpaceIncHHint: string = '水平方向扩大间距，选择两个控件以上时有效';
  SCnSpaceDecHCaption: string = '水平方向减少间距';
  SCnSpaceDecHHint: string = '水平方向减少间距，选择两个控件以上时有效';
  SCnSpaceRemoveHCaption: string = '水平方向消除间距';
  SCnSpaceRemoveHHint: string = '水平方向消除间距，选择两个控件以上时有效';
  SCnSpaceEquVCaption: string = '垂直方向等间距';
  SCnSpaceEquVHint: string = '垂直方向等间距，选择三个控件以上时有效';
  SCnSpaceEquVYCaption: string = '垂直方向自定义等间距';
  SCnSpaceEquVYHint: string = '垂直方向自定义等间距，选择两个控件以上时有效';
  SCnSpaceIncVCaption: string = '垂直方向扩大间距';
  SCnSpaceIncVHint: string = '垂直方向扩大间距，选择两个控件以上时有效';
  SCnSpaceDecVCaption: string = '垂直方向减少间距';
  SCnSpaceDecVHint: string = '垂直方向减少间距，选择两个控件以上时有效';
  SCnSpaceRemoveVCaption: string = '垂直方向消除间距';
  SCnSpaceRemoveVHint: string = '垂直方向消除间距，选择两个控件以上时有效';
  SCnIncWidthCaption: string = '增加宽度';
  SCnIncWidthHint: string = '增加控件宽度';
  SCnDecWidthCaption: string = '减少宽度';
  SCnDecWidthHint: string = '减少控件宽度';
  SCnIncHeightCaption: string = '增加高度';
  SCnIncHeightHint: string = '增加控件高度';
  SCnDecHeightCaption: string = '减少高度';
  SCnDecHeightHint: string = '减少控件高度';
  SCnMakeMinWidthCaption: string = '宽度缩到最小';
  SCnMakeMinWidthHint: string = '控件宽度缩到最小，选择两个控件以上时有效';
  SCnMakeMaxWidthCaption: string = '宽度放到最大';
  SCnMakeMaxWidthHint: string = '控件宽度放到最大，选择两个控件以上时有效';
  SCnMakeSameWidthCaption: string = '宽度一致';
  SCnMakeSameWidthHint: string = '控件宽度与第一个控件一致，选择两个控件以上时有效';
  SCnMakeMinHeightCaption: string = '高度缩到最小';
  SCnMakeMinHeightHint: string = '控件高度缩到最小，选择两个控件以上时有效';
  SCnMakeMaxHeightCaption: string = '高度放到最大';
  SCnMakeMaxHeightHint: string = '控件高度放到最大，选择两个控件以上时有效';
  SCnMakeSameHeightCaption: string = '高度一致';
  SCnMakeSameHeightHint: string = '控件高度与第一个控件一致，选择两个控件以上时有效';
  SCnMakeSameSizeCaption: string = '大小一致';
  SCnMakeSameSizeHint: string = '控件大小与第一个控件相同，选择两个控件以上时有效';
  SCnParentHCenterCaption: string = '水平置于父控件中心';
  SCnParentHCenterHint: string = '将所选控件在水平方向上置于父控件中心';
  SCnParentVCenterCaption: string = '垂直置于父控件中心';
  SCnParentVCenterHint: string = '将所选控件在垂直方向上置于父控件中心';
  SCnBringToFrontCaption: string = '移到前面';
  SCnBringToFrontHint: string = '将控件移到前面';
  SCnSendToBackCaption: string = '移到后面';
  SCnSendToBackHint: string = '将控件移到后面';
  SCnSnapToGridCaption: string = '控件吸附到栅格';
  SCnSnapToGridHint: string = '控件移动和缩放时吸附到栅格';
  SCnUseGuidelinesCaption: string = '切换设计辅助线';
  SCnUseGuidelinesHint: string = '切换设计辅助线';
  SCnAlignToGridCaption: string = '控件对齐到栅格';
  SCnAlignToGridHint: string = '控件位置对齐到栅格';
  SCnSizeToGridCaption: string = '控件缩放到栅格';
  SCnSizeToGridHint: string = '控件尺寸缩放到栅格';
  SCnLockControlsCaption: string = '锁定控件';
  SCnLockControlsHint: string = '锁定控件不允许移动';
  SCnSelectRootCaption: string = '选择窗体';
  SCnSelectRootHint: string = '选择当前设计对象为窗体';
  SCnCopyCompNameCaption: string = '复制当前选择的组件名';
  SCnCopyCompNameHint: string = '复制当前选择的所有组件的名称到剪贴板';
  SCnHideComponentCaption: string = '隐藏不可视组件';
  SCnHideComponentHint: string = '隐藏或显示窗体上的不可视的组件';
  SCnNonArrangeCaption: string = '排列不可视组件...';
  SCnNonArrangeHint: string = '对窗体上的不可视组件进行排列';
  SCnListCompCaption: string = '组件列表...';
  SCnListCompHint: string = '设计器组件列表供快速定位';
  SCnCompToCodeCaption: string = '转换成代码...';
  SCnCompToCodeHint: string = '将所选择组件转换成创建代码';
  SCnShowFlatFormCaption: string = '浮动工具面板设置...';
  SCnShowFlatFormHint: string = '浮动工具面板设置';

  SCnListComponentCount: string = '组件总数: %d';
  SCnCompToCodeEnvNotSupport: string = '组件代码转换不支持此环境！';
  SCnCompToCodeProcCopiedFmt: string = '过程 %s 已复制到剪贴板';
  SCnCompToCodeConvertedFmt: string = '共转换 %d 项';
  SCnMustGreaterThanZero: string = '所输入的数值必须大于零！';
  SCnHideNonVisualNotSupport: string = '本功能目前只支持 VCL';
  SCnNonNonVisualFound: string = '没有可供处理的不可视组件';
  SCnNonNonVisualNotSupport: string = '不可视组件排列目前只支持 VCL';
  SCnSpacePrompt: string = '请输入控件间距：';
  SCnMustDigital: string = '输入必须是数字';

  // CnPaletteEnhanceWizard
  SCnPaletteEnhanceWizardName: string = 'IDE 主窗体扩展';
  SCnPaletteEnhanceWizardComment: string = '扩展组件面板与 IDE 主菜单等的功能';
  SCnPaletteTabsMenuCaption: string = '&Tabs';
  SCnPaletteMultiLineMenuCaption: string = '多行方式(&M)';
  SCnLockToolbarMenuCaption: string = '锁定工具栏(&L)';
  SCnPaletteMoreCaption: string = '更多(&M)...';

  SCnSearchComponent: string = '查找组件';
  SCnComponentDetailFmt: string = '组件类: %s' + #13#10 + '单元名: %s' + #13#10 + '标签页: %s' + #13#10#13#10 + '继承关系: ' + #13#10#13#10;

  // CnVerEnhanceWizard
  SCnVerEnhanceWizardName: string = '版本信息扩展';
  SCnVerEnhanceWizardComment: string = '版本信息内容扩展专家';

  // CnCorPropWizard
  SCnCorrectPropertyName: string = '属性修改器';
  SCnCorrectPropertyMenuCaption: string = '属性修改器(&C)...';
  SCnCorrectPropertyMenuHint: string = '按照一定规则批量修改窗体上的组件属性';
  SCnCorrectPropertyComment: string = '按照一定规则批量修改窗体上的组件属性';

  SCnCorrectPropertyActionWarn: string = '提示';
  SCnCorrectPropertyActionAutoCorrect: string = '自动更正';
  SCnCorrectPropertyStateCorrected: string = '已修改';
  SCnCorrectPropertyStateWarning: string = '需要确认';
  SCnCorrectPropertyAskDel: string = '您是否确实要删除此条规则？';
  SCnCorrectPropertyRulesCountFmt: string = '共有规则 %d 条。';

  SCnCorrectPropertyErrNoForm: string = '当前没有待处理的窗体';
  SCnCorrectPropertyErrNoResult: string = '没有找到符合修正规则的属性';
  SCnCorrectPropertyErrNoModuleFound: string = '该组件不存在，可能其所在的窗体已关闭或组件本身已被删除。';
  SCnCorrectPropertyErrClassFmt: string = '找不到组件类 %s ，是否继续？';
  SCnCorrectPropertyErrClassCreate: string = '组件类 %s 无法进行属性验证，是否继续？';
  SCnCorrectPropertyErrPropFmt: string = '组件类 %s 中找不到属性 %s ，可能仅在其派生类中存在，是否继续？';
  SCnCorrPropSetPropValueErrorFmt: string = '设置属性 %s 时出错，可能是该组件、属性不存在或值错误，请检查规则定义。'
    + #13#10#13#10 + '%s';

  // CnProjectExtWizard
  SCnProjExtWizardName: string = '工程扩展工具';
  SCnProjExtWizardCaption: string = '工程扩展工具(&Q)';
  SCnProjExtWizardHint: string = '用于工程功能扩展的工具集合。';
  SCnProjExtWizardComment: string = '用于工程功能扩展的工具集合。';
  SCnProjExtRunSeparatelyCaption: string = '脱离 IDE 运行(&R)';
  SCnProjExtRunSeparatelyHint: string = '脱离 IDE 单独运行程序。';
  SCnProjExtExploreUnitCaption: string = '浏览当前文件目录(&D)...';
  SCnProjExtExploreUnitHint: string = '在资源管理器中打开当前文件所在的文件夹。';
  SCnProjExtExploreProjectCaption: string = '浏览工程目录(&P)...';
  SCnProjExtExploreProjectHint: string = '在资源管理器中打开当前工程所在的文件夹。';
  SCnProjExtExploreExeCaption: string = '浏览输出目录(&E)...';
  SCnProjExtExploreExeHint: string = '在资源管理器中打开当前输出文件夹。';
  SCnProjExtViewUnitsCaption: string = '工程组单元列表(&U)...';
  SCnProjExtViewUnitsHint: string = '显示当前工程组所有单元列表。';
  SCnProjExtViewFormsCaption: string = '工程组窗体列表(&F)...';
  SCnProjExtViewFormsHint: string = '显示当前工程组所有窗体列表。';
  SCnProjExtUseUnitsCaption: string = '引用单元(&I)...';
  SCnProjExtUseUnitsHint: string = '显示当前工程组所有单元列表进行引用。';
  SCnProjExtListUsedCaption: string = '已引用单元列表(&S)...';
  SCnProjExtListUsedHint: string = '显示当前单元所引用的其它单元列表。';

  SCnProjExtBackupCaption: string = '工程备份(&B)...';
  SCnProjExtBackupHint: string = '压缩备份工程文件';
  SCnProjExtBackupFileCount: string = '备份 %s 工程文件总数: %d';
  SCnProjExtBackupNoFile: string = '没有需要备份的文件。';
  SCnProjExtBackupMustZip: string = '目前只支持 ZIP 格式的压缩文件，目标文件扩展名将更改为 ZIP，是否继续？';
  SCnProjExtBackupDllMissCorrupt: string = '找不到 ZIP 库或库已损坏，请重新安装。';
  SCnProjExtBackupErrorCompressor: string = '外部压缩程序不存在，请重新指定。';
  SCnProjExtBackupSuccFmt: string = '文件已成功备份至 %s';

  SCnProjExtDelTempCaption: string = '清除工程临时文件(&C)...';
  SCnProjExtDelTempHint: string = '清除工程目录下的临时文件。';
  SCnProjExtProjectAll: string = '<全部>';
  SCnProjExtCurrentProject: string = '<当前工程>';
  SCnProjExtProjectCount: string = '工程总数: %d';
  SCnProjExtFormsFileCount: string = '窗体总数: %d';
  SCnProjExtUnitsFileCount: string = '单元总数: %d';
  SCnProjExtFramesFileCount: string = 'Frame 总数: %d';

  SCnProjExtNotSave: string = '（未保存）';
  SCnProjExtFileNotExistOrNotSave: string = '文件不存在或未保存！';
  SCnProjExtOpenFormWarning: string = '您选择了多个窗体，是否继续？';
  SCnProjExtOpenUnitWarning: string = '您选择了多个单元，是否继续？';
  SCnProjExtFileIsReadOnly: string = '文件属性为“只读”，是否设置属性为正常并继续转换窗体？';
  SCnProjExtCreatePrjListError: string = '创建 ProjectList 错误！';
  SCnProjExtErrorInUse: string = '无法找到以下文件，' + #13#10 + '可能与当前文件处于不同工程中：';
  SCnProjExtAddExtension: string = '添加文件扩展名';
  SCnProjExtAddNewText: string = '输入准备删除的文件的扩展名:';
  SCnProjExtCleaningComplete: string = '清除完成。 %d 个文件被删除。' + #13#10 +
    '恢复了 %s 字节的存储空间。';
  SCnProjExtFileReopenCaption: string = '打开历史文件(&O)...';
  SCnProjExtFileReopenHint: string = '打开历史文件';
  SCnProjExtCustomBackupFile: string = '自选备份';
  
  SCnProjExtDirBuilderCaption: string = '工程目录创建器(&L)...';
  SCnProjExtDirBuilderHint: string = '打开工程目录创建器';
  SCnProjExtConfirmOverrideTemplet: string = '模板“%s”已经存在，是否覆盖？';
  SCnProjExtConfirmSaveTemplet: string = '当前模板未保存，要保存吗？';
  SCnProjExtConfirmDeleteDir: string = '确认要删除目录“%s”吗？';
  SCnProjExtConfirmDeleteTemplet: string = '确认要删除模板“%s”吗？';
  SCnProjExtSelectDir: string = '请选择一个目录:';
  SCnProjExtSaveTempletCaption: string = '保存模板';
  SCnProjExtInputTempletName: string = '请输入模板名称:';
  SCnProjExtIsNotUniqueDirName: string = '目录名重复。';
  SCnProjExtDirNameHasInvalidChar: string = '目录名不能包括以下字符:' + #10#13 + ' \ / :  * ? " < > | ';
  SCnProjExtDirCreateSucc: string = '已成功创建目录树';
  SCnProjExtDirCreateFail: string = '目录树创建失败，可能目标只读';

  // CnFilesSnapshotWizard
  SCnFilesSnapshotWizardName: string = '历史文件与快照专家';
  SCnFilesSnapshotWizardCaption: string = '历史文件与快照专家(&W)';
  SCnFilesSnapshotWizardHint: string = '快速打开历史文件。';
  SCnFilesSnapshotWizardComment: string = '快速打开历史文件。';
  SCnFilesSnapshotAddCaption: string = '创建文件列表快照(&C)...';
  SCnFilesSnapshotAddHint: string = '根据当前打开的文件创建一个快照';
  SCnFilesSnapshotManageCaption: string = '管理文件列表快照(&M)...';
  SCnFilesSnapshotManageHint: string = '管理已有的文件列表快照';

  SCnFilesSnapshotManageFrmCaptionManage: string = '整理文件列表快照';
  SCnFilesSnapshotManageFrmCaptionAdd: string = '创建文件列表快照';
  SCnFilesSnapshotManageFrmLblSnapshotsCaptionManage: string = '请选择要处理的文件列表快照:';
  SCnFilesSnapshotManageFrmLblSnapshotsCaptionAdd: string = '将当前打开的文件列表保存为快照:';

  // CnCommentCroperWizard
  SCnCommentCropperWizardName: string = '删除注释专家';
  SCnCommentCropperWizardMenuCaption: string = '删除注释(&V)...';
  SCnCommentCropperWizardMenuHint: string = '删除代码中的注释';
  SCnCommentCropperWizardComment: string = '删除代码中的注释';
  SCnCommentCropperCountFmt: string = '共处理 %d 个文件。';

  // CnFavoriteWizard
  SCnFavWizName: string = '收藏夹专家';
  SCnFavWizCaption: string = '收藏夹专家';
  SCnFavWizHint: string = '收藏和管理工程、单元及窗体文件的专家';
  SCnFavWizComment: string = '收藏和管理工程、单元及窗体文件的专家。';
  SCnFavWizAddToFavoriteMenuCaption: string = '添加到收藏夹(&A)...';
  SCnFavWizAddToFavoriteMenuHint: string = '添加当前文件到收藏夹';
  SCnFavWizManageFavoriteMenuCaption: string = '整理收藏夹(&O)...';
  SCnFavWizManageFavoriteMenuHint: string = '整理收藏夹中的文件';

  // CnCpuWinEnhancements
  SCnCpuWinEnhanceWizardName: string = 'CPU 窗口扩展';
  SCnCpuWinEnhanceWizardComment: string = '允许从 CPU 窗口中复制汇编代码。';
  SCnMenuCopyLinesToClipboard: string = '复制 %d 行到剪贴板';
  SCnMenuCopyLinesToFile: string = '复制 %d 行到文件...';
  SCnMenuCopyLinesCaption: string = '复制代码...';

  // CnResourceMgrWizard
  SCnResMgrWizardMenuCaption: string = '资源管理专家';
  SCnResMgrWizardMenuHint: string = '资源管理专家';
  SCnResMgrWizardName: string = '资源管理专家';
  SCnResMgrWizardComment: string = '用于收集管理各种有效的编程资源。';
  SCnDocumentMgrWizardCaption: string = '电子文档管理器';
  SCnDocumentMgrWizardHint: string = '电子文档管理器';
  SCnDocumentMgrWizardComment: string = '用于收集分类管理来自网络的各种电子文档，支持.txt、.rtf和*.htm格式。';
  SCnImageMgrWizardCaption: string = '图标管理器';
  SCnImageMgrWizardHint: string = '图标管理器';
  SCnImageMgrWizardComment: string = '用于收集分类管理各种类型的图像资源，支持.bmp、.ico、gif和jpg等格式。';
  SCnResMgrConfigCaption: string = '设置(&O)...';
  SCnResMgrConfigHint: string = '设置资源管理器属性';
  SCnResMgrConfigComment: string = '设置资源管理器属性。';

  // CnRepositoryMenu
  SCnRepositoryMenuCaption: string = 'Repository 列表(&Y)';
  SCnRepositoryMenuHint: string = 'Repository 专家列表';
  SCnRepositoryMenuName: string = 'Repository 列表';
  SCnRepositoryMenuComment: string = 'Repository 专家列表';

  // CnExplore
  SCnExploreMenuCaption: string = '文件管理器专家(&X)';
  SCnExploreMenuHint: string = '嵌入的 Windows 资源管理器，包含了文件过滤、文件夹收藏和临时文件删除功能';
  SCnExploreName: string = '文件管理器专家';
  SCnExploreComment: string = '嵌入的 Windows 资源管理器，包含了文件过滤、文件夹收藏和临时文件删除功能';
  SCnNewFolder: string = '新建文件夹';
  SCnNewFolderHint: string = '请输入文件夹名称：';
  SCnNewFolderDefault: string = '新建文件夹';
  SCnUnableToCreateFolder: string = '不能创建文件夹';
  SCnExploreFilterDataName: string = 'ExploreFilter.cdt';
  SCnExploreFilterAllFile: string = '所有文件';
  SCnExploreFilterDelphiFile: string = 'Delphi 文件';
  SCnExploreFilterBCBFile: string = 'C++Builder 文件';
  SCnExploreFilterDelphiProjectFile: string = '工程文件';
  SCnExploreFilterDelphiPackageFile: string = '包文件';
  SCnExploreFilterDelphiUnitFile: string = 'Delphi 单元文件';
  SCnExploreFilterDelphiFormFile: string = '窗体文件';
  SCnExploreFilterConfigFile: string = '配置文件'; 
  SCnExploreFilterTextFile: string = '文本文件';
  SCnExploreFilterSqlFile: string = 'SQL 脚本';
  SCnExploreFilterHtmlFile: string = 'HTML 文件';
  SCnExploreFilterWebFile: string = 'Web 文本';
  SCnExploreFilterBatchFile: string = '批处理文件';
  SCnExploreFilterTypeLibFile: string = 'Type Library';
  SCnExploreFilterStat: string = '当前过滤类型:';
  SCnExploreFilterDefault: string = '这将恢复默认的文件过滤设置，你以前所作的修改将被改变。是否继续？';
  SCnExploreFilterDeleteFmt: string = '是否删除选中的过滤类型？' + #13#10 +
    '类型：   %s' + #13#10 + '扩展名： %s';

  // CnDUnitWizard
  SCnDUnitWizardName: string = 'DUnit 测试用例生成向导';
  SCnDUnitWizardComment: string = '生成 DUnit 测试用例，要求已安装 DUnit 单元';
  SCnDUnitErrorNOTSupport: string = '本向导只支持生成 Delphi/Pascal 的工程或单元！';
  SCnDUnitTestName: string = '测试名称：';
  SCnDUnitTestAuthor: string = '作    者：';
  SCnDUnitTestVersion: string = '版    本：';
  SCnDUnitTestDescription: string = '说    明：';
  SCnDUnitTestComments: string = '备    注：';

  // CnObjInspectorEnhanceWizard
  SCnObjInspectorEnhanceWizardName: string = '对象查看器扩展';
  SCnObjInspectorEnhanceWizardComment: string = '增强对象查看器的功能。';

  // CnWizBoot
  SCnWizBootCurrentCount: string = '当前专家：%d';
  SCnWizBootEnabledCount: string = '启动专家：%d';

  // CnIniFilerWizard
  SCnIniFilerWizardName: string = 'INI 读写单元生成向导';
  SCnIniFilerWizardComment: string = '根据 INI 文件生成读写该 INI 文件的单元';
  SCnIniFilerPasFilter: string = 'Pascal 文件(*.pas)|*.pas';
  SCnIniFilerCppFilter: string = 'C++ 文件(*.cpp)|*.cpp';
  SCnIniErrorNoFile: string = 'INI 文件不存在或文件名输入错误，请重新选择文件。';
  SCnIniErrorPrefix: string = '无效的字符串常量前缀';
  SCnIniErrorClassName: string = '无效的类名';
  SCnIniErrorReadIni: string = '读取 INI 时发生错误，请检查 INI 文件。';
  SCnIniErrorNOTSupport: string = '本向导目前只支持生成 Pascal 或 C++ 单元，不支持 C# 及其他。';
  SCnIniErrorNOProject: string = '无法判断当前语言类型，请手工选择。' + #13#10 + '是否生成 Pascal 单元？选“否”则生成 C++ 单元。';

  // CnMemProfWizard
  SCnMemProfWizardName: string = 'CnMemProf 工程向导';
  SCnMemProfWizardComment: string = '生成带 CnMemProf 内存防护功能的工程向导';

  // CnWinTopRoller
  SCnWinTopRollerName: string = '窗口置顶与折叠扩展';
  SCnWinTopRollerComment: string = '替 IDE 中的窗口增加置顶与折叠的扩展按钮';
  SCnWinTopRollerBtnTopHint: string = '窗口置顶';
  SCnWinTopRollerBtnRollerHint: string = '窗口折叠';
  SCnWinTopRollerBtnOptionsHint: string = '按钮选项';
  SCnWinTopRollerPopupAddToFilter: string = '将此窗体加入屏蔽列表';
  SCnWinTopRollerPopupOptions: string = '设置...';

  // CnInputHelper
  SCnInputHelperName: string = '代码输入助手';
  SCnInputHelperComment: string = '在输入代码时自动弹出下拉框辅助输入';
  SCnInputHelperConfig: string = '设置(&O)...';
  SCnInputHelperAutoPopup: string = '允许自动弹出(&A)';
  SCnInputHelperDispButtons: string = '显示快速按钮(&B)';
  SCnInputHelperSortKind: string = '排序方式(&R)';
  SCnInputHelperIcon: string = '图例(&I)';
  SCnInputHelperSortByScope: string = '自动排序(&1)';
  SCnInputHelperSortByText: string = '按文本排序(&2)';
  SCnInputHelperSortByLength: string = '按长度排序(&3)';
  SCnInputHelperSortByKind: string = '按类型排序(&4)';
  SCnInputHelperAddSymbol: string = '添加自定义符号(&S)...';
  SCnInputHelperHelp: string = '输入助手帮助(&H)';
  SCnInputHelperKibitzCompileRunning: string = '正在后台获取标识符列表';

  SCnInputHelperPreDefSymbolList: string = '预定义的常用标识符列表';
  SCnInputHelperUserTemplateList: string = '常用代码模板列表';
  SCnInputHelperCompDirectSymbolList: string = '系统编译指示字列表';
  SCnInputHelperUnitNameList: string = '在 uses 区中使用的单元名称列表';
  SCnInputHelperUnitUsesList: string = '在代码区使用的引用单元名称列表';
  SCnInputHelperIDECodeTemplateList: string = 'IDE 自带的代码模板列表';
  SCnInputHelperIDESymbolList: string = '从实时编译器取得的标识符列表';
  SCnInputHelperUserSymbolList: string = '用户自定义的标识符及代码模板列表';
  SCnInputHelperXMLCommentList: string = 'XML 格式代码注释列表';
  SCnInputHelperJavaDocList: string = 'JavaDoc 格式代码注释列表';

  SCnInputHelperSymbolNameIsEmpty: string = '符号名称不能为空！';
  SCnInputHelperSymbolKindError: string = '请选择符号类型！';
  SCnInputHelperUserMacroCaption: string = '自定义宏';
  SCnInputHelperUserMacroPrompt: string = '请输入自定义宏名称:';

  SCnKeywordDefault: string = '默认';
  SCnKeywordLower: string = '小写关键字';
  SCnKeywordUpper: string = '大写关键字';
  SCnKeywordFirstUpper: string = '词首大写';

  // CnProcListWizard
  SCnProcListWizardName: string = '函数过程列表专家';
  SCnProcListWizardComment: string = '列出当前源码文件中的函数与过程';
  SCnProcListWizardMenuCaption: string = '函数过程列表(&G)...';
  SCnProcListWizardMenuHint: string = '列出当前源码文件中的函数与过程';
  SCnProcListObjsAll: string = '<全部>';
  SCnProcListObjsNone: string = '<独立>';
  SCnProcListErrorInFile: string = '语法解析错误，源文件可能已损坏';
  SCnProcListErrorFileType: string = '文件不存在，或文件类型不支持';
  SCnProcListErrorPreview: string = '<文件未打开，函数实现部分的预览功能暂时无效>';

  SCnProcListCurrentFile: string = '<当前单元>';
  SCnProcListAllFileInProject: string = '<当前工程所有单元>';
  SCnProcListAllFileInProjectGroup: string = '<当前工程组所有单元>';
  SCnProcListAllFileOpened: string = '<所有打开的单元>';

  SCnProcListJumpIntfHint: string = '跳至单元的 interface 部分';
  SCnProcListJumpImplHint: string = '跳至单元的 implementation 部分';
  SCnProcListClassComboHint: string = '类型声明列表';
  SCnProcListProcComboHint: string = '函数过程列表';
  SCnProcListMatchStartHint: string = '匹配开头';
  SCnProcListMatchAnyHint: string = '匹配所有位置';

  SCnProcListSortMenuCaption: string = '排序规则(&S)';
  SCnProcListSortSubMenuByName: string = '按名称(&N)';
  SCnProcListSortSubMenuByLocation: string = '按位置(&L)';
  SCnProcListSortSubMenuReverse: string = '反序(&R)';
  SCnProcListExportMenuCaption: string = '输出列表到文件(&E)...';
  SCnProcListCloseMenuCaption: string = '关闭函数列表工具栏(&H)';

  SCnProcListNoContent: string = '<无>';
  SCnProcListCloseToolBarHint: string = '您已经选择了关闭函数列表工具栏。'#13#10#13#10 +
    '如果您以后需要重新显示此工具栏，可在函数过程列表窗口中点击'#13#10 +
    '“显示函数过程列表工具栏”按钮来实现。';

  SCnProcListErrorNoIntf: string = '未找到 interface 部分';
  SCnProcListErrorNoImpl: string = '未找到 implementation 部分';

  // CnUsesCleaner
  SCnUsesCleanerMenuCaption: string = '清理引用单元(&U)...';
  SCnUsesCleanerMenuHint: string = '清理源代码中不需要的引用单元';
  SCnUsesCleanerName: string = '清理引用单元专家';
  SCnUsesCleanerComment: string = '清理源代码中不需要的引用单元。';
  SCnUsesCleanerCompileFail: string = '编译工程失败，无法分析单元引用关系！';
  SCnUsesCleanerUnitError: string = '处理文件 %s 失败！'#13#10#13#10 +
    '该文件格式可能不支持，请与开发组联系！';
  SCnUsesCleanerProcessError: string = '处理文件 %s 失败，您需要继续处理其它文件吗？';
  SCnUsesCleanerHasInitSection: string = '包含初始化节';
  SCnUsesCleanerHasRegProc: string = '包含注册过程';
  SCnUsesCleanerInCleanList: string = '在清理列表中';
  SCnUsesCleanerInIgnoreList: string = '在忽略列表中';
  SCnUsesCleanerNotSource: string = '无源码';
  SCnUsesCleanerCompRef: string = '组件间接引用';
  SCnUsesCleanerNoneResult: string = '没有找到需要处理的内容！';
  SCnUsesCleanerReport: string = '引用单元清理完成！' + #13#10 +
    '共清理 %d 个多余引用于 %d 单元中。'#13#10#13#10 +
    '您需要查看清理日志吗？';

  // CnIdeEnhanceMenu
  SCnIdeEnhanceMenuCaption: string = 'IDE 扩展设置(&I)';
  SCnIdeEnhanceMenuHint: string = 'IDE 扩展设置列表';
  SCnIdeEnhanceMenuName: string = 'IDE 扩展设置';
  SCnIdeEnhanceMenuComment: string = 'IDE 扩展设置列表';

  // CnSourceHighlight
  SCnSourceHighlightWizardName: string = '源代码高亮扩展';
  SCnSourceHighlightWizardComment: string = '括号匹配高亮和结构高亮等扩展';

  // CnIdeBRWizard
  SCnIdeBRWizardMenuCaption: string = 'IDE 配置备份/恢复(&0)...';
  SCnIdeBRWizardMenuHint: string = '运行 IDE 配置备份/恢复工具';
  SCnIdeBRWizardName: string = 'IDE 配置备份/恢复工具';
  SCnIdeBRWizardComment: string = '运行 IDE 配置备份/恢复工具';
  SCnIdeBRToolNotExists: string = '无法运行 IDE 配置备份/恢复工具，请重新安装专家包！';

  // CnFastCodeWizard
  SCnFastCodeWizardName: string = 'FastCode 优化专家';
  SCnFastCodeWizardComment: string = '使用 FastCode/FastMove 来提升 IDE 的性能';

  // CnScriptWizard
  SCnScriptWizardMenuCaption: string = '脚本扩展专家(&1)';
  SCnScriptWizardMenuHint: string = '可编写 Pascal 脚本以实现功能扩展';
  SCnScriptWizardName: string = '脚本扩展专家';
  SCnScriptWizardComment: string = '可编写 Pascal 脚本以实现功能扩展';
  SCnScriptFormCaption: string = '脚本窗口(&W)';
  SCnScriptFormHint: string = '显示用于编辑和执行脚本的可停靠窗口';
  SCnScriptWizCfgCaption: string = '脚本设置(&S)...';
  SCnScriptWizCfgHint: string = '脚本扩展设置窗口';
  SCnScriptBrowseDemoCaption: string = '浏览脚本示例(&B)...';
  SCnScriptBrowseDemoHint: string = '在资源管理器中打开脚本示例的所在目录';
  SCnScriptFileNotExists: string = '脚本文件不存在！';
  SCnScriptCompError: string = '脚本编译错误:';
  SCnScriptExecError: string = '脚本运行错误:';
  SCnScriptCompiler: string = '编译器';
  SCnScriptCompiling: string = '正在编译...';
  SCnScriptErrorMsg: string = '%s 于 %d.%d';
  SCnScriptCompiledSucc: string = '编译成功';
  SCnScriptExecutedSucc: string = '执行成功';
  SCnScriptCompilingFailed: string = '编译失败';
  SCnScriptExecConfirm: string = '您确定要执行脚本 %s 吗？';
  SCnScriptMenuDemoCaption: string = '例子(&D)';
  SCnScriptMenuDemoHint: string = '脚本例子';

implementation

end.

