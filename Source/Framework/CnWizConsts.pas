{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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
// Do NOT need to Localize
//==============================================================================

const
  {$I Version.inc}

  SCnWizardVersion = SCnWizardMajorVersion + '.' + SCnWizardMinorVersion;
  SCnWizardFullVersion = SCnWizardVersion + ' Build ' + SCnWizardBuildDate;

  SCnWizardCaption = 'CnPack IDE Wizards ' + SCnWizardVersion;
  SCnWizardDesc = 'CnPack IDE Wizards for Delphi/C++Builder/BDS/Rad Studio' + #13#10 +
                  '' + #13#10 +
                  'Version: ' + SCnWizardFullVersion + #13#10 +
                  'Copyright: 2001-2014 CnPack Team' + #13#10 +
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

  // CnExplore
  SCnExploreFilterDataName = 'ExploreFilter.cdt';

  // CnSourceHighlight
  SCnSourceHighlightBlock = 'CnSourceHighlightBlock';

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
// Need to Localize
//==============================================================================

var
  // Common
  SCnSaveDlgTxtFilter: string = 'Text file (*.txt)|*.TXT|All files (*.*)|*.*|';
  SCnSaveDlgTitle: string = 'Save as...';
  SCnOverwriteQuery: string = 'File already Exists, Overwrite?';
  SCnDeleteConfirm: string = 'Sure to Delete?';
  SCnClearConfirm: string = 'Sure to Clear?';
  SCnDefaultConfirm: string = 'Sure to Restore Settings to Default?';
  SCnNoHelpofThisLang: string = 'Sorry. No HELP in this Language.';
  SCnOnlineHelp: string = 'Online &Help';
  SCnImportAppend: string = 'Append to the Existing?';
  SCnImportError: string = 'Import Data Error!';
  SCnExportError: string = 'Export Data Error!';
  SCnUnknownNameResult: string = 'Unknown Name';
  SCnNoneResult: string = 'None';
  SCnInputFile: string = 'Please Enter the Filename.';
  SCnDoublePasswordError: string = 'Password Error or Mismatch, Please Enter again.';
  SCnMoreMenu: string = 'More...';

  // 反馈向导
  STypeDescription: string =
    '  Bug Report includes access violation, system crash, malfunctions and other exceptions.' + #13#10#13#10 +
    '  Suggestions include advices, new requirements and other information to CnPack IDE Wizards.' + #13#10#13#10 +
    '  Please make sure that your CnPack IDE Wizards is the latest version when you commit this report. ' +
    'You can obtain the latest version by auto update or access our website.';
  SBugDescriptionDescription: string =
    '  Please enter the bug details, including special configuration data in your system and other useful information which is beneficial to developers.' + #13#10#13#10 +
    '  Generally, Only a bug can be reproduced, it can be fixed effectively. Your compiler environments and OS information will be collected as important details.';
  SFeatureDescriptionDescription: string =
    '  Please enter the details about your requirements, making sure that it''s useful to you.';
  SDetailsDescription: string =
    '  It''s Important for us to reproduce the bug your reported.' + #13#10#13#10 +
    '  Please tell us whether you can reproduce the bug through some certain steps, and its probability.' + #13#10#13#10 +
    '  If possible, including whether the bug can recur at other computer and whether only relative to some certain projects.';
  SStepsDescription: string =
    '  Please enter the steps to help us to reproduce the bug.' + #13#10#13#10 +
    '  The steps should begin at starting IDE to the bug''s appearing, include Mouse clicking, Shortcuts, Form switching and Exception information about the bug.' + #13#10#13#10 +
    '  If possible, try to reproduce it by a simple or default project, or a IDE Demo project.';
  SBugConfigurationDescription: string =
    '  Your selection will send to us to help us to reproduce the bug and fix it.' + #13#10#13#10 +
    '  To keep the report effective, we recommend that you keep the default options. Before you send it, you can edit or delete the options information.';
  SFeatureConfigurationDescription: string =
    '  Your selection will send to us to help us to affirm your suggestions.' + #13#10#13#10 +
    '  To keep the report effective, we recommend that you keep the default options. Before you send it, you can edit or delete the options information.';
  SReportDescription: string =
    '  Press Finish button to generate a feedback mail''s content. You need paste the content to your email, ' + #13#10#13#10 +
    '  or press Save button to save the content and send to %s as attachment.' + #13#10#13#10 +
    '  Our Wizards would not automatically send information which may be about your privacy. All contents need you to send manually.';
  STypeExample: string =
    '  CnPack team won''t to take any commercial develop tasks. All members are busy. ' +
    'Freeware developing is our interesting and pursuit, so we won''t do any customize components, ' +
    'wizards or projects. Further more, wizards existing in free Tools, e.g. GExperts, are also excluded.' + #13#10#13#10 +
    '  Please pay attention to it.';
  SBugDescriptionExample: string =
    '  I add some Toolbutton to IDE toolbar. After restarting, the buttons added become empty.';
  SFeatureDescriptionExample: string =
    '  I hope that You can write a new editor, which can convert Delphi or C++ code to VB, so I can write Outlook Email Virus in Delphi or C++. :-)' + #13#10#13#10 +
    '  If you could implement it, I''ll give you a lot of money.';
  SDetailsExample: string =
    '';
  SStepsExample: string =
    '1. Run %s from Start Menu.' + #13#10 +
    '2. Right-Click the Toolbar in IDE, Choose Customize...' + #13#10 +
    '3. Drag a CnPack IDE Wizard to Toolbar.' + #13#10 +
    '4. Close %s ' + #13#10 +
    '5. Restart %s ' + #13#10 +
    '6. The Toolbutton Added is Empty.';
  SConfigurationExample: string =
    '';
  SReportExample: string =
    '';
  SFinish: string = '&Finished';
  SNext: string = '&Next >';
  STitle: string = 'Bug Report or Suggestions Wizard -';
  SBugReport: string = 'Bug Report';
  SFeatureRequest: string = 'Suggestions';
  SDescription: string = 'Description:';
  SSteps: string = 'Steps:';
  SBugDetails: string = 'Bug Details:';
  SBugIsReproducible: string = '  Can Recur with a Probability of %s%%.';
  SBugIsNotReproducible: string = '  Can''t Recur.';
  SFillInReminder: string = 'Please Paste the Report Here';
  SFillInReminderPaste: string = 'Please Paste the Report Here';
  SFillInReminderAttach: string = 'Please Paste the Report and the Attachment %s Here';
  SBugSteps: string =
    '1. Run %s from Start Menu.' + #13#10 +
    '2. A Blank Project Created.' + #13#10 +
    '3. Click the MainMenu...' + #13#10 +
    '4.' + #13#10 +
    '5.';

  SUnknown: string = '<Unknown>';
  SOutKeyboard: string = 'Keyboard:';
  SOutLocale: string = 'Localization Info:';
  SOutExperts: string = 'Wizards Installed:';
  SOutPackages: string = 'Packages Installed:';
  SOutIDEPackages: string = 'IDE Packages Installed:';
  SOutCnWizardsActive: string = 'CnPack IDE Wizards Enabled State:';
  SOutCnWizardsCreated: string = 'CnPack IDE Wizards Created State:';
  SOutConfig: string = 'Settings:';

  // CnWizUpgrade
  SCnWizUpgradeName: string = 'Check Update';
  SCnWizUpgradeComment: string = 'Check the Latest Version of CnPack IDE Wizards';
  SCnWizNoUpgrade: string = 'You''ve already Used the Latest Version!' + #13#10#13#10 +
    'Do You Want to Browse Our Nightly-Buid Download Page?';
  SCnWizUpgradeFail: string = 'Connection Failure. Please Retry Later, or Visit our Website to Get the Update.';
  SCnWizUpgradeCommentName: string = 'Comment_ENU';

  // CheckIDEVersion
  SCnIDENOTLatest: string =
    'We''ve Detected that the Latest Update Pack Maybe NOT Installed in this IDE. ' +
    'Perhaps Your IDE is NOT stable, and Some Functions of CnWizards will NOT be Supported. ' +
    'We Recommend You Download and Install the Latest Update Pack.';

  // CnWizUtils
  SCnWizardForPasOrDprOnly: string = 'Only to .pas and .dpr files';
  SCnWizardForPasOrIncOnly: string = 'Only to .pas and .inc files';
  SCnWizardForDprOrPasOrIncOnly: string = 'Only to .pas, .dpr and .inc files';

  // CnShortcut
  SCnDuplicateShortCutName: string = 'Duplicated Shortcut: %s';

  // CnMenuAction
  SCnDuplicateCommand: string = 'Duplicated Command: %s';
  SCnWizSubActionShortCutFormCaption: string = '%s - Hotkey Configuration';

  // CnWizConfigForm
  SCnWizConfigCaption: string = '&Options...';
  SCnWizConfigHint: string = 'Options of CnPack IDE Wizards';
  SCnWizConfigName: string = 'Options';
  SCnWizConfigComment: string = 'Options of CnPack IDE Wizards';
  SCnProjectWizardName: string = 'Project Wizard';
  SCnFormWizardName: string = 'Form Wizard';
  SCnUnitWizardName: string = 'Unit Wizard';
  SCnRepositoryWizardName: string = 'Repository Wizard';
  SCnMenuWizardName: string = 'Menu Wizard';
  SCnSubMenuWizardName: string = 'Submenu Wizard';
  SCnActionWizardName: string = 'Shortcut Wizard';
  SCnIDEEnhanceWizardName: string = 'IDE Enhancements Wizard';
  SCnBaseWizardName: string = 'Common Wizard';
  SCnWizardNameStr: string = 'Name:';
  SCnWizardShortCutStr: string = 'Shortcut:';
  SCnWizardStateStr: string = 'State:';
  SCnWizardActiveStr: string = 'Enabled';
  SCnWizardDisActiveStr: string = 'Disabled';
  SCnWizCommentReseted: string = 'All Hint forms are enabled and will displayed ' + #13#10 + 'when you use the Wizards.';
  SCnSelectDir: string = 'Select a directory.';
  SCnQueryAbort: string = 'Sure to Abort?';
  SCnExportPCDirCaption: string = 'Select a directory.';
  SCnExportPCSucc: string = 'Component list file %s and package list file %s save succeed.';

  // CnWizAbout
  SCnConfigIONotExists: string = 'File NOT Found. Please Reinstall CnWizards!';

  // CnMessageBoxWizard
  SCnMsgBoxMenuCaption: string = '&MessageBox...';
  SCnMsgBoxMenuHint: string = 'Visual Designer for MessageBox Function';
  SCnMsgBoxName: string = 'MessageBox Visual Designer';
  SCnMsgBoxComment: string = 'Visual Designer for MessageBox Function.';
  SCnMsgBoxProjectCaption: string = 'New Template';
  SCnMsgBoxProjectPrompt: string = 'Enter Template Name:';
  SCnMsgBoxProjectDefaultName: string = 'Template';
  SCnMsgBoxProjectExists: string = 'Template Name already Exists, Overwrite?';
  SCnMsgBoxDeleteProject: string = 'Sure to Delete the Template?';
  SCnMsgBoxCannotDelLastProject: string = 'Auto Saved Template can MOT be Deleted!';

  // CnComponentSelector
  SCnCompSelectorMenuCaption: string = 'Component &Selector...';
  SCnCompSelectorMenuHint: string = 'Selecting Components with Multi-mode.';
  SCnCompSelectorName: string = 'Component Selector';
  SCnCompSelectorComment: string = 'Allows User to Select Components with Multi-mode.';
  SCnCompSelectorNotSupport: string = 'Only Form and Frame are Supported by Component Selector!';

  // CnTabOrderWizard
  SCnTabOrderMenuCaption: string = '&Tab Orders';
  SCnTabOrderMenuHint: string = 'Auto Set Tab Orders';
  SCnTabOrderName: string = 'Tab Orders Configuration';
  SCnTabOrderComment: string = 'Customize Components'' Tab Orders';
  SCnTabOrderSetCurrControlCaption: string = '&Components Selected';
  SCnTabOrderSetCurrControlHint: string = 'Auto Set Tab Orders.';
  SCnTabOrderSetCurrFormCaption: string = 'All Components of Current &Form';
  SCnTabOrderSetCurrFormHint: string = 'Auto Set Tab Orders in the Form.';
  SCnTabOrderSetOpenedFormCaption: string = 'All Opened &Forms';
  SCnTabOrderSetOpenedFormHint: string = 'Auto Set Tab Orders in All Opened Forms.';
  SCnTabOrderSetProjectCaption: string = 'All Forms in Current &Project';
  SCnTabOrderSetProjectHint: string = 'Auto Set Tab Orders in Current Project.';
  SCnTabOrderSetProjectGroupCaption: string = 'All Forms in Current Project&Group';
  SCnTabOrderSetProjectGroupHint: string = 'Auto Set Tab Orders in Current ProjectGroup.';
  SCnTabOrderDispTabOrderCaption: string = '&Display Tab Orders';
  SCnTabOrderDispTabOrderHint: string = 'Display Tab Orders in Designing Mode.';
  SCnTabOrderAutoResetCaption: string = '&Auto Update Tab Orders';
  SCnTabOrderAutoResetHint: string = 'Auto Update Tab Orders after Components Moved.';
  SCnTabOrderConfigCaption: string = '&Options...';
  SCnTabOrderConfigHint: string = 'Display Options Dialog of Tab Order Wizard';
  SCnTabOrderSucc: string = 'Processed %d Components Successfully.';
  SCnTabOrderFail: string = 'No Forms Available.';

  // CnDfm6To5Wizard
  SCnDfm6To5WizardMenuCaption: string = 'Open &High Version Forms...';
  SCnDfm6To5WizardMenuHint: string = 'Open Forms and Units Created by High Version IDEs.';
  SCnDfm6To5WizardName: string = 'Open High Version Forms Tool';
  SCnDfm6To5WizardComment: string = 'Open Forms and Units Created by High Version IDEs.';
  SCnDfm6To5OpenError: string = 'File Opening Failure! ' + #13#10#13#10 + 'Filename: %s';
  SCnDfm6To5SaveError: string = 'Writing File Failure, please check the read-only attributes. ' + #13#10#13#10 + 'Filename: %s';
  SCnDfm6To5InvalidFormat: string = 'Convertion Failure! ' + #13#10#13#10 + 'Filename: %s';

  // CnBookmarkWizard
  SCnBookmarkWizardMenuCaption: string = '&BookMark Browser...';
  SCnBookmarkWizardMenuHint: string = 'Browsing BookMarks of All Opening Files';
  SCnBookmarkWizardName: string = 'BookMark Browser';
  SCnBookmarkWizardComment: string = 'Browsing BookMarks of All Opening Files';
  SCnBookmarkAllUnit: string = '<All Units>';
  SCnBookmarkFileCount: string = 'Units Count: %d';

  // CnEditorWizard
  SCnEditorWizardMenuCaption: string = 'Code &Editor Wizard';
  SCnEditorWizardMenuHint: string = 'Code Editor Tools';
  SCnEditorWizardName: string = 'Code Editor Wizard';
  SCnEditorWizardComment: string = 'Code Editor Tools.';
  SCnEditorWizardConfigCaption: string = '&Options...';
  SCnEditorWizardConfigHint: string = 'Configurate the Code Editor Wizard';

  // CnEditorCodeTool
  SCnEditorCodeToolSelIsEmpty: string = 'Please Select the Code Block to Process.';
  SCnEditorCodeToolNoLine: string = 'Can not Get Source Lines.';

  // CnEditorCodeSwap
  SCnEditorCodeSwapMenuCaption: string = 'Eval S&wap';
  SCnEditorCodeSwapName: string = 'Eval Swap Tool';
  SCnEditorCodeSwapMenuHint: string = 'Swap the Contents of the Evaluation Sign in Both Sides';

  // CnEditorCodeToString
  SCnEditorCodeToStringMenuCaption: string = 'Convert to &String';
  SCnEditorCodeToStringName: string = 'Code to String Converter';
  SCnEditorCodeToStringMenuHint: string = 'Convert Code Block Selected to String';

  // CnEditorCodeDelBlank
  SCnEditorCodeDelBlankMenuCaption: string = '&Delete Blank Lines...';
  SCnEditorCodeDelBlankName: string = 'Delete Blank Lines Tool';
  SCnEditorCodeDelBlankMenuHint: string = 'Delete Blank Lines';

  // CnEditorOpenFile
  SCnEditorOpenFileMenuCaption: string = 'O&pen File...';
  SCnEditorOpenFileName: string = 'Open File Tool';
  SCnEditorOpenFileMenuHint: string = 'Search and Open File in Search Path.';
  SCnEditorOpenFileDlgCaption: string = 'Open File';
  SCnEditorOpenFileDlgHint: string = 'Enter Filename:';
  SCnEditorOpenFileNotFind: string = 'File not Found in Search Path!';

  // CnEditorZoomFullScreen
  SCnEditorZoomFullScreenMenuCaption: string = 'Editor &FullScreen Switch';
  SCnEditorZoomFullScreenMenuHint: string = 'Switch Code Editor in FullScreen and Normal Mode';
  SCnEditorZoomFullScreen: string = 'Editor Fullscreen Switch';
  SCnEditorZoomFullScreenNoEditor: string = 'Editor Window Docked or does NOT Exist';

  // CnEditorCodeComment
  SCnEditorCodeCommentMenuCaption: string = 'Co&mment Code';
  SCnEditorCodeCommentMenuHint: string = 'Comment Selected Code Block with //';
  SCnEditorCodeCommentName: string = 'Comment Code Tool';

  // CnEditorCodeUnComment
  SCnEditorCodeUnCommentMenuCaption: string = 'Unc&omment Code';
  SCnEditorCodeUnCommentMenuHint: string = 'Uncomment Selected Code Block Commented by //';
  SCnEditorCodeUnCommentName: string = 'UnComment Code Tool';

  // CnEditorCodeToggleComment
  SCnEditorCodeToggleCommentMenuCaption: string = 'Toggle &Comment';
  SCnEditorCodeToggleCommentMenuHint: string = 'Toggle Comment Selected Code Block';
  SCnEditorCodeToggleCommentName: string = 'Toggle Comment Code Tool';

  // CnEditorCodeIndent
  SCnEditorCodeIndentMenuCaption: string = '&Indent';
  SCnEditorCodeIndentMenuHint: string = 'Indent Code Block';
  SCnEditorCodeIndentName: string = 'Indent Code Tool';

  // CnEditorCodeUnIndent
  SCnEditorCodeUnIndentMenuCaption: string = '&Unindent';
  SCnEditorCodeUnIndentMenuHint: string = 'Unindent Code Block';
  SCnEditorCodeUnIndentName: string = 'Unindent Code Tool';

  // CnAsciiChart
  SCnAsciiChartMenuCaption: string = '&ASCII Chart';
  SCnAsciiChartMenuHint: string = 'Display ASCII Chart';
  SCnAsciiChartName: string = 'ASCII Chart';

  // CnEditorInsertColor
  SCnEditorInsertColorMenuCaption: string = 'I&nsert Color';
  SCnEditorInsertColorMenuHint: string = 'Insert Color';
  SCnEditorInsertColorName: string = 'Insert Color Tool';

  // CnEditorInsertTime
  SCnEditorInsertTimeMenuCaption: string = 'Insert Date &Time';
  SCnEditorInsertTimeMenuHint: string = 'Insert Date Time';
  SCnEditorInsertTimeName: string = 'Insert Date Time Tool';

  // CnEditorCollector
  SCnEditorCollectorMenuCaption: string = 'Co&llector';
  SCnEditorCollectorMenuHint: string = 'Collector';
  SCnEditorCollectorName: string = 'Collector';
  SCnEditorCollectorInputCaption: string = 'Enter Label Name';

  // CnEditorSortLines
  SCnEditorSortLinesMenuCaption: string = 'So&rt Selected Lines';
  SCnEditorSortLinesMenuHint: string = 'Sort Selected Lines';
  SCnEditorSortLinesName: string = 'Sort Selected Lines Tool';

  // CnEditorToggleVar
  SCnEditorToggleVarMenuCaption: string = 'Toggle &Var Field';
  SCnEditorToggleVarMenuHint: string = 'Jump between Current Place and Var Field';
  SCnEditorToggleVarName: string = 'Toggle Var Field Tool';

  // CnEditorToggleUses
  SCnEditorToggleUsesMenuCaption: string = 'Toggle Uses&/Include';
  SCnEditorToggleUsesMenuHint: string = 'Jump between Current Place and Uses/Include Part';
  SCnEditorToggleUsesName: string = 'Toggle Use/Include Tool';

  // CnEditorPrevMessage
  SCnEditorPrevMessageMenuCaption: string = 'Previous M&essage Line';
  SCnEditorPrevMessageMenuHint: string = 'In Editor, Jump to Previous Line Marked by Selected Item in Message View';
  SCnEditorPrevMessageName: string = 'Previous Message Line Tool';

  // CnEditorNextMessage
  SCnEditorNextMessageMenuCaption: string = 'Next Messa&ge Line';
  SCnEditorNextMessageMenuHint: string = 'In Editor, Jump to Next Line Marked by Selected Item in Message View';
  SCnEditorNextMessageName: string = 'Next Message Line Tool';

  // CnEditorJumpIntf
  SCnEditorJumpIntfMenuCaption: string = '&Jump to Intf.';
  SCnEditorJumpIntfMenuHint: string = 'Jump to Interface';
  SCnEditorJumpIntfName: string = 'Jump to Interface Tool';

  // CnEditorJumpImpl
  SCnEditorJumpImplMenuCaption: string = 'Jump to Impl&.';
  SCnEditorJumpImplMenuHint: string = 'Jump to Implementation';
  SCnEditorJumpImplName: string = 'Jump to Implementation Tool';

  // CnEditorJumpMatchedKeyword
  SCnEditorJumpMatchedKeywordMenuCaption: string = 'Jump to Matched &Keyword';
  SCnEditorJumpMatchedKeywordMenuHint: string = 'Jump to Matched Keyword under Cursor';
  SCnEditorJumpMatchedKeywordName: string = 'Jump to Matched Keyword Tool';

  // CnEditorJumpPrevIdent
  SCnEditorJumpPrevIdentMenuCaption: string = 'Jump to Previous Identifier';
  SCnEditorJumpPrevIdentMenuHint: string = 'Jump to Previous Identifier under Cursor';
  SCnEditorJumpPrevIdentName: string = 'Jump to Previous Identifier Tool';

  // CnEditorJumpNextIdent
  SCnEditorJumpNextIdentMenuCaption: string = 'Jump to Next Identifier';
  SCnEditorJumpNextIdentMenuHint: string = 'Jump to Next Identifier under Cursor';
  SCnEditorJumpNextIdentName: string = 'Jump to Next Identifier Tool';

  // CnEditorFontInc
  SCnEditorFontIncMenuCaption: string = 'Zoom &Larger Font';
  SCnEditorFontIncMenuHint: string = 'Zoom Larger Editor Font';
  SCnEditorFontIncName: string = 'Zoom Larger Editor Font Tool';

  // CnEditorFontDec
  SCnEditorFontDecMenuCaption: string = 'Zoom &Smaller Font';
  SCnEditorFontDecMenuHint: string = 'Zoom Smaller Editor Font';
  SCnEditorFontDecName: string = 'Zoom Smaller Editor Font Tool';

  // CnSrcTemplate
  SCnSrcTemplateMenuCaption: string = 'Source Te&mplates';
  SCnSrcTemplateMenuHint: string = 'Source and Comment Templates';
  SCnSrcTemplateName: string = 'Source Templates';
  SCnSrcTemplateComment: string = 'Source and Comment Templates.';
  SCnSrcTemplateConfigCaption: string = '&Options...';
  SCnSrcTemplateConfigHint: string = 'Source Templates Options';
  SCnSrcTemplateCaptionIsEmpty: string = 'Template''s Menu Caption can''t be Empty!';
  SCnSrcTemplateContentIsEmpty: string = 'Template''s Content can''t be Empty!';
  SCnSrcTemplateReadDataError: string = 'Error Reading Data Files.';
  SCnSrcTemplateWriteDataError: string = 'Error Saving Data Files.';
  SCnSrcTemplateImportAppend: string = 'Append the Data to Templates?';
  SCnSrcTemplateWizardDelete: string = 'Sure to Delete the Template?';
  SCnSrcTemplateWizardClear: string = 'Sure to Delete All the Templates?';
  SCnSrcTemplateDataDefName: string = 'Editor_ENU.cdt';
  SCnSrcTemplateDataDefName_CB: string = 'Editor_CB_ENU.cdt';
  SCnEIPCurrPos: string = 'Current Position';
  SCnEIPBOL: string = 'Begin of Line';
  SCnEIPEOL: string = 'End of Line';
  SCnEIPBOF: string = 'Unit Header';
  SCnEIPEOF: string = 'Unit End';
  SCnEIPProcHead: string = 'Next Procedure Head';
  SCnEMVProjectDir: string = 'Project Directory';
  SCnEMVProjectName: string = 'Project Name';
  SCnEMVProjectGroupDir: string = 'Project Group Directory';
  SCnEMVProjectGroupName: string = 'Project Group Name';
  SCnEMVUnit: string = 'Unit Name';
  SCnEMVProceName: string = 'Next Procedure Name';
  SCnEMVResult: string = 'The Return Type of the Procedure, or None';
  SCnEMVArguments: string = 'The Arguments Passed to the Procedure, or None';
  SCnEMVArgList: string = 'The Arguments List passed to the Procedure, or Empty';
  SCnEMVRetType: string = 'The Return Type of the Procedure, or Empty';
  SCnEMVCurProceName: string = 'Current Procedure Name';
  SCnEMVCurMethodName: string = 'Current Method Name (without Class Name)';
  SCnEMVCurClassName: string = 'Current Class Name';
  SCnEMVUser: string = 'Current Username';
  SCnEMVCurIDEName: string = 'Current IDE Name and Version';
  SCnEMVDateTime: string = 'Date and Time';
  SCnEMVDate: string = 'Date';
  SCnEMVYear: string = 'Year';
  SCnEMVMonth: string = 'Month';
  SCnEMVMonthShortName: string = 'Month Short Names';
  SCnEMVMonthLongName: string = 'Month Long Names';
  SCnEMVDay: string = 'Day';
  SCnEMVDayShortName: string = 'Day Short Names';
  SCnEMVDayLongName: string = 'Day Long Names';
  SCnEMVHour: string = 'Hour';
  SCnEMVMinute: string = 'Minute';
  SCnEMVSecond: string = 'Second';
  SCnEMVCodeLines: string = 'Current Unit Code Lines';
  SCnEMVColPos: string = 'Fill with Space to Special Column(Example: %ColPos80%)';
  SCnEMVCursor: string = 'Cursor Position after Insert(Only First Available)';

  // CnMsdnWizard
  SCnMsdnWizardName: string = 'MSDN Help Wizard';
  SCnMsdnWizardMenuCaption: string = 'MS&DN Help Wizard';
  SCnMsdnWizardMenuHint: string = 'Open MSDN Help in the IDE';
  SCnMsdnWizardRunConfigCaption: string = '&Options...';
  SCnMsdnWizardRunConfigHint: string = 'Set MSDN wizard Options';
  SCnMsdnWizardRunMsdnCaption: string = 'MSDN &Help...';
  SCnMsdnWizardRunMsdnHint: string = 'Open MSDN help';
  SCnMsdnWizardRunSearchCaption: string = 'MSDN &Search...';
  SCnMsdnWizardRunSearchHint: string = 'Open MSDN Search';
  SCnMsdnWizardComment: string = 'Use MSDN Help or MSDN Online in IDE.';
  SCnMsdnToolBarCaption: string = 'MSDN Help';
  SCnMsdnSelectKeywordHint: string = 'Select Keyword to Search in MSDN';
  SCnMsdnNoMsdnInstalled: string = 'Please Install MSDN First!';
  SCnMsdnNoLanguage: string = 'Preferred Language [%s] NOT Exists!';
  SCnMsdnNoCollection: string = 'Preferred Collection [%s] NOT Exists!';
  SCnMsdnRegError: string = 'Error Reading MSDN Setup Info from Registry!';
  SCnMsdnConnectToServerError: string = 'Can NOT Connect to Server!';
  SCnMsdnDisconnectServerError: string = 'Disconnect The Server Error!';
  SCnMsdnIsInvalidURL: string = 'The Homepage Address is Invalid!';
  SCnMsdnShowKeywordFailed: string = 'Show the Keyword Failed!';
  SCnMsdnOpenIndexFailed: string = 'Open Index Failed!';
  SCnMsdnOpenSearchFailed: string = 'Open Search Failed!';

  // CnPas2HtmlWizard
  SCnPas2HtmlWizardMenuCaption: string = '&Export to HTML/RTF';
  SCnPas2HtmlWizardMenuHint: string = 'Convert Code to HTML/RTF Format ';
  SCnPas2HtmlWizardName: string = 'Source Format Convert Wizard';
  SCnPas2HtmlWizardComment: string = 'Convert Code to HTML/RTF Format';
  SCnPas2HtmlWizardCopySelectedCaption: string = '&Copy as HTML Format';
  SCnPas2HtmlWizardCopySelectedHint: string = 'Convert the Current Selection to HTML Format and Copy to Clipboard';
  SCnPas2HtmlWizardExportUnitCaption: string = 'Export &Unit...';
  SCnPas2HtmlWizardExportUnitHint: string = 'Export Current Unit to a HTML or RTF File';
  SCnPas2HtmlWizardExportOpenedCaption: string = 'Export &All Opened...';
  SCnPas2HtmlWizardExportOpenedHint: string = 'Exports All Opened Units to HTML or RTF Files';
  SCnPas2HtmlWizardExportDPRCaption: string = 'Export Current &Project...';
  SCnPas2HtmlWizardExportDPRHint: string = 'Export Current Project to HTML or RTF Files';
  SCnPas2HtmlWizardExportBPGCaption: string = 'Export Project &Group...';
  SCnPas2HtmlWizardExportBPGHint: string = 'Export Current ProjectGroup to HTML or RTF Files';
  SCnPas2HtmlWizardConfigCaption: string = '&Options...';
  SCnPas2HtmlWizardConfigHint: string = 'Convert Output Options';
  SCnSelectDirCaption: string = 'Please Select the Directory to Save Output Files.';
  SCnDispCaption: string = 'Converting %s';
  SCnPas2HtmlErrorNOTSupport: string = 'Only Pascal/C/C++ File Supported.';
  SCnPas2HtmlErrorConvertProject: string = 'Converting Project Error.';
  SCnPas2HtmlErrorConvert: string = 'Convertion Error in File %s';
  SCnPas2HtmlDefEncode: string = 'iso-8859-1';

  // CnWizEditFiler
  SCnFileDoesNotExist: string = 'File %s NOT Exists!';
  SCnNoEditorInterface: string = 'FEditRead: Can not get editor''s interface for file %s.';
  SCnNoModuleNotifier: string = 'TCnEditFiler: Can not get module notifier for file %s.';

  // CnReplaceWizard
  SCnReplaceWizardMenuCaption: string = '&Replace in Files...';
  SCnReplaceWizardMenuHint: string = 'Replace in Files';
  SCnReplaceWizardName: string = 'Batch File Replace';
  SCnReplaceWizardComment: string = 'Search and Replace Text in Files';
  SCnLineLengthError: string = 'Grep detected a line longer than %d characters in:' + #13#10 + '%s.' + #13#10 +
    'Likely, this is an unsupported binary file type.';
  SCnClassNotTerminated: string = 'Class at %d did not terminate property';
  SCnPatternTooLong: string = 'Grep pattern too long. (> 500 characters)';
  SCnInvalidGrepSearchCriteria: string = 'Character immediately following: at %d is not a valid grep search criteria';
  SCnSenselessEscape: string = 'Escape character ("\") without a following character does not make sense';
  SCnReplaceSourceEmpty: string = 'Text to Search can''t be Empty!';
  SCnReplaceDirEmpty: string = 'Directory Name can''t be Empty!';
  SCnReplaceDirNotExists: string = 'Directory NOT Exists!';
  SCnReplaceSelectDirCaption: string = 'Select a Directory';
  SCnSaveFileError: string = 'Saving Error, File is Read-only.' + #13#10 + 'Filename: %s';
  SCnSaveEditFileError: string = 'Writing Editor Error, File in Editor is Read-only.' + #13#10 + 'Filename: %s';
  SCnReplaceWarning: string = 'Replacing would Modify the Files.' + #13#10 + 'Please Make Sure the Operation.' + #13#10#13#10 + 'Continue?';
  SCnReplaceResult: string = 'Replace Complete! ' + #13#10#13#10 + '%d Files, %d Replaced.';
  SCnReplaceQueryContinue: string = 'Continue Other Files'' Replacing?';

  // CnSourceDiffWizard
  SCnSourceDiffWizardMenuCaption: string = 'Source Com&pare...';
  SCnSourceDiffWizardMenuHint: string = 'Compare and Merge Source Files';
  SCnSourceDiffWizardName: string = 'Source Compare Wizard';
  SCnSourceDiffWizardComment: string = 'Compare and Merge Source Files';
  SCnSourceDiffCaseIgnored: string = 'Case Ignored';
  SCnSourceDiffBlanksIgnored: string = 'Blanks Ignored';
  SCnSourceDiffChanges: string = '  Changes: %d %s';
  SCnSourceDiffApprox: string = 'Approx. %d%% complete';
  SCnSourceDiffOpenError: string = 'Open File Failed.';
  SCnSourceDiffOpenFile: string = '&Open File...';
  SCnSourceDiffUpdateFile: string = '&Refresh Current File';
  SCnDiskFile: string = 'File';
  SCnEditorBuff: string = 'Mem';
  SCnBakFile: string = 'Bak';

  // CnStatWizard
  SCnStatWizardMenuCaption: string = 'So&urce Statistics...';
  SCnStatWizardMenuHint: string = 'Source Statistics';
  SCnStatWizardName: string = 'Source Statistics Wizard';
  SCnStatWizardComment: string = 'Source Statistics';
  SCnStatDirEmpty: string = 'Directory Name can''t be Empty!';
  SCnStatDirNotExists: string = 'Directory NOT Exists!';
  SCnStatSelectDirCaption: string = 'Select the Directory';
  SCnStatusBarFmtString: string = '%s Files, %s Bytes, %s Effective Lines.';
  SCnStatusBarFindFileFmt: string = '%s Files Found...';
  SCnStatClearResult: string = 'Preparing for New Statistics...';
  SCnErrorNoFile: string = 'File NOT Exists.';
  SCnErrorNoFind: string = 'String not Found: %s';
  SCnStatBytesFmtStr: string = '%s Bytes, Code %s Bytes, Comment %s Blocks, %s Bytes.';
  SCnStatLinesFmtStr: string = '%s Lines, Code %s Lines, Comment %s Lines, Blank %s Lines, Effective %s Lines.';
  SCnStatFilesCaption: string = 'Files Information';
  SCnStatProjectName: string = 'Project: %s';
  SCnStatProjectFiles: string = '%s Files, %s Bytes.';
  SCnStatProjectBytes: string = 'Code %s Bytes, Comment %s Bytes.';
  SCnStatProjectLines1: string = '%s Lines, %s Effective, %s Blank.';
  SCnStatProjectLines2: string = 'Code %s Lines, Comment %s Blocks, %s Lines.';
  SCnStatProjectGroupName: string = 'ProjectGroup: %s';
  SCnStatProjectGroupFiles: string = '%s Projects, %s Files, %s Bytes.';
  SCnStatProjectGroupBytes: string = 'Code %s Bytes, Comment %s Bytes.';
  SCnStatProjectGroupLines1: string = '%s Lines, %s Effective, %s Blank.';
  SCnStatProjectGroupLines2: string = 'Code %s Lines, Comment %s Blocks %s Lines.';
  SCnStatNoProject: string = 'No Project Information.';
  SCnStatNoProjectGroup: string = 'No ProjectGroup Information.';
  SCnStatExpTitle: string = 'Source Statistics Result Report';
  SCnStatExpDefFileName: string = 'StatResult';
  SCnStatExpProject: string = 'Project %s''s Information:';
  SCnStatExpProjectGroup: string = 'ProjectGroup %s''s Information:';
  SCnStatExpFileName: string = 'Filename: %s';
  SCnStatExpFileDir: string = 'At Dir.: %s';
  SCnStatExpFileBytes: string = 'Bytes: %s';
  SCnStatExpFileCodeBytes: string = 'Code Bytes: %s';
  SCnStatExpFileCommentBytes: string = 'Comment Bytes: %s';
  SCnStatExpFileAllLines: string = 'Lines: %s';
  SCnStatExpFileEffectiveLines: string = 'Effective Lines: %s';
  SCnStatExpFileBlankLines: string = 'Blank Lines: %s';
  SCnStatExpFileCodeLines: string = 'Code Lines: %s';
  SCnStatExpFileCommentLines: string = 'Comment Lines: %s';
  SCnStatExpFileCommentBlocks: string = 'Comment Blocks: %s';
  SCnStatExpSeperator: string = '' + #13#10 + '--------------------------' + #13#10 + ';';
  SCnStatExpCSVTitleFmt: string = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';
  SCnStatExpCSVLineFmt: string = '%s%s%s%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s%d';
  SCnStatExpCSVProject: string = 'Project Information';
  SCnStatExpCSVProjectGroup: string = 'ProjectGroup Information';
  SCnStatExpCSVFileName: string = 'Filename';
  SCnStatExpCSVFileDir: string = 'At Dir.';
  SCnStatExpCSVBytes: string = 'Bytes';
  SCnStatExpCSVCodeBytes: string = 'Code Bytes';
  SCnStatExpCSVCommentBytes: string = 'Comment Bytes';
  SCnStatExpCSVAllLines: string = 'Lines';
  SCnStatExpCSVEffectiveLines: string = 'Effective Lines';
  SCnStatExpCSVBlankLines: string = 'Blank Lines';
  SCnStatExpCSVCodeLines: string = 'Code Lines';
  SCnStatExpCSVCommentLines: string = 'Comment Lines';
  SCnStatExpCSVCommentBlocks: string = 'Comment Blocks';
  SCnDoNotStat: string = 'None-source File won''t be Processed.';

  // CnPrefixWizard
  SCnPrefixWizardMenuCaption: string = '&Prefix Wizard...';
  SCnPrefixWizardMenuHint: string = 'Rename Prefix of Components';
  SCnPrefixWizardName: string = 'Component Prefix Wizard';
  SCnPrefixWizardComment: string = 'Rename Prefix of Components';
  SCnPrefixInputError: string = 'Please Enter A Effective Prefix as the Component Name.';
  SCnPrefixNameError: string = 'Please Enter A Effective Prefix as the Component Name.';
  SCnPrefixDupName: string = 'A Component with the Same Name Found, Please Reenter the Name.';
  SCnPrefixNoComp: string = 'No Components Found in Selections.';
  SCnPrefixAskToProcess: string = 'Sure to Process the Names of Component(s)?';

  // CnWizAbout
  SCnWizAboutCaption: string = '&About...';
  SCnWizAboutName: string = 'About and Help';
  SCnWizAboutComment: string = 'About and Help';
  SCnWizAboutHelpCaption: string = 'Help Top&ics...';
  SCnWizAboutHistoryCaption: string = 'Update &History...';
  SCnWizAboutTipOfDaysCaption: string = '&Tip of Day...';
  SCnWizAboutBugReportCaption: string = 'Bug &Report or Suggestions...';
  SCnWizAboutUpgradeCaption: string = 'Check &Update...';
  SCnWizAboutConfigIOCaption: string = 'Config Import/&Export...';
  SCnWizAboutUrlCaption: string = 'CnPack &WebSite';
  SCnWizAboutBbsCaption: string = 'CnPac&k Forum';
  SCnWizAboutMailCaption: string = 'E&mail';
  SCnWizAboutAboutCaption: string = '&About...';
  SCnWizAboutHint: string = 'About CnPack IDE Wizards';
  SCnWizAboutHelpHint: string = 'CnPack IDE Wizards Help';
  SCnWizAboutHistoryHint: string = 'CnPack IDE Wizards Update History';
  SCnWizAboutTipOfDayHint: string = 'Display the Tip of Day';
  SCnWizAboutBugReportHint: string = 'Open the Wizards to Report Error or Send Suggestion';
  SCnWizAboutUpgradeHint: string = 'Check the Latest Version of CnPack IDE Wizards';
  SCnWizAboutConfigIOHint: string = 'Load/Save the Config Info of CnPack IDE Wizards';
  SCnWizAboutUrlHint: string = 'Access the CnPack WebSite';
  SCnWizAboutBbsHint: string = 'Access CnPack Forum';
  SCnWizAboutMailHint: string = 'Write Mail to CnPack';
  SCnWizAboutAboutHint: string = 'About CnPack IDE Wizards';
  SCnWizMailSubject: string = 'About CnPack IDE Wizards';

  // CnEditorEnhancements
  SCnEditorEnhanceWizardName: string = 'Editor Enhancements';
  SCnEditorEnhanceWizardComment: string = 'Editor Enhancements';
  SCnMenuCloseOtherPagesCaption: string = 'Close All Other Pages';
  SCnMenuShellMenuCaption: string = 'Shell Context Menu';
  SCnMenuSelAllCaption: string = 'Select All';
  SCnMenuBlockToolsCaption: string = 'CnPack Editor Menu';
  SCnMenuExploreCaption: string = 'Open "%s" in Windows Explorer';
  SCnMenuCopyFileNameMenuCaption: string = 'Copy Full Path/FileName';
  SCnEditorEnhanceConfig: string = 'Editor Tools &Settings...';

  SCnToolBarClose: string = '&Hide Editor ToolBar';
  SCnToolBarCloseHint: string = 'You Choose to Close Editor ToolBar.' + #13#10#13#10 +
    'If You Want to Show it Again. You can Check the "Show Toolbar in Editor" CheckBox' + #13#10 +
    'in Editor Enhancement Settings Dialog.';

  SCnLineNumberGotoLine: string = '&Goto Line...';
  SCnLineNumberGotoBookMark: string = '&Jump to Bookmark';
  SCnLineNumberClearBookMarks: string = 'Clear &All Bookmarks';
  SCnLineNumberShowIDELineNum: string = 'Show IDE''s &Line Number';
  SCnLineNumberClose: string = '&Hide Line Number';

  SCnSrcEditorNavIDEBack: string = 'IDE''s Go Back (Shift+Click)';
  SCnSrcEditorNavIDEForward: string = 'IDE''s Go Forward (Shift+Click)';
  SCnSrcEditorNavIDEBackList: string = 'IDE''s Go Back List';
  SCnSrcEditorNavIDEForwardList: string = 'IDE''s Go Forward List';
  SCnSrcEditorNavPause: string = 'Use IDE''s Jumping Temporarily';

  // CnSrcEditorBlockTools
  SCnSrcBlockToolsHint: string = 'Source Block Tools';
  SCnSrcBlockEdit: string = '&Edit';
  SCnSrcBlockCopy: string = '&Copy';
  SCnSrcBlockCopyAppend: string = 'Copy && &Append';
  SCnSrcBlockDuplicate: string = '&Duplicate';
  SCnSrcBlockCut: string = 'Cu&t';
  SCnSrcBlockCutAppend: string = 'Cut && Appe&nd';
  SCnSrcBlockDelete: string = '&Delete';
  SCnSrcBlockSaveToFile: string = '&Save to File...';
  SCnSrcBlockCase: string = 'Convert C&ase';
  SCnSrcBlockLowerCase: string = 'To &Lower Case';
  SCnSrcBlockUpperCase: string = 'To &Upper Case';
  SCnSrcBlockToggleCase: string = '&Invert Case';
  SCnSrcBlockFormat: string = '&Format';
  SCnSrcBlockIndent: string = '&Indent';
  SCnSrcBlockIndentEx: string = 'I&ndent Columns...';
  SCnSrcBlockUnindent: string = '&Unindent';
  SCnSrcBlockUnindentEx: string = 'Un&indent Columns...';
  SCnSrcBlockIndentCaption: string = 'Indent';
  SCnSrcBlockIndentPrompt: string = 'Please Enter a Number to Indent:';
  SCnSrcBlockUnindentCaption: string = 'Unindent';
  SCnSrcBlockUnindentPrompt: string = 'Please Enter a Number to Unindent:';
  SCnSrcBlockComment: string = 'Co&mment';
  SCnSrcBlockWrap: string = '&Surround With';
  SCnSrcBlockWrapBy: string = 'Surround with "%s"';
  SCnSrcBlockReplace: string = 'Group Re&place';
  SCnSrcBlockSearch: string = '&Web Search';
  SCnWebSearchFileDef: string = 'WebSearch_ENU.xml';
  SCnSrcBlockMisc: string = '&Others';
  SCnSrcBlockMoveUp: string = 'Move &Up';
  SCnSrcBlockMoveDown: string = 'Move &Down';
  SCnSrcBlockDeleteLines: string = 'Delete &Lines';

  // CnSrcEditorKey
  SCnRenameVarCaption: string = 'Rename Identifier';
  SCnRenameVarHintFmt: string = 'Replace %s To:';
  SCnRenameErrorValid: string = 'Invalid Identifier. Abort Replacing.';
  
  // CnFormEnhancements
  SCnFormEnhanceWizardName: string = 'Form Designer Enhancements';
  SCnFormEnhanceWizardComment: string = 'Form Designer Enhancements';
  SCnMenuFlatFormCustomizeCaption: string = 'Cust&omize...';
  SCnMenuFlatFormConfigCaption: string = 'Setti&ngs...';
  SCnMenuFlagFormPosCaption: string = '&Position';
  SCnMenuFlatPanelTopLeft: string = 'Top Left(&1)';
  SCnMenuFlatPanelTopRight: string = 'Top Right(&2)';
  SCnMenuFlatPanelBottomLeft: string = 'Bottom Left(&3)';
  SCnMenuFlatPanelBottomRight: string = 'Bottom Right(&4)';
  SCnMenuFlatPanelLeftTop: string = 'Left Top(&5)';
  SCnMenuFlatPanelLeftBottom: string = 'Left Bottom(&6)';
  SCnMenuFlatPanelRightTop: string = 'Right Top(&7)';
  SCnMenuFlatPanelRightBottom: string = 'Right Bottom(&8)';
  SCnMenuFlatFormAllowDragCaption: string = 'Allow &Drag';
  SCnMenuFlagFormImportCaption: string = '&Import Buttons...';
  SCnMenuFlagFormExportCaption: string = '&Export Buttons...';
  SCnMenuFlatFormCloseCaption: string = '&Close';
  SCnMenuFlatFormDataFileFilter: string = 'Config Files(*.ini)|*.ini';
  SCnFlatToolBarRestoreDefault: string = 'Sure to Delete Your Toolbars and Restore to Default?';
  SCnFloatPropBarFilterCaption: string = 'Only Show Frequent Properties';
  SCnFloatPropBarRenameCaption: string = 'Rename Component';
  SCnEmbeddedDesignerNotSupport: string = 'Sorry. VCL Embedded Designer NOT Supported.';

  // CnAlignSizeWizard
  SCnAlignSizeMenuCaption: string = 'Form Design Wi&zard';
  SCnAlignSizeMenuHint: string = 'Adjust Align or Size of Selected Components';
  SCnAlignSizeName: string = 'Form Design Wizard';
  SCnAlignSizeComment: string = 'Allow Adjusting Align or Size of Selected Components';
  SCnAlignLeftCaption: string = 'Align Left Edges';
  SCnAlignLeftHint: string = 'Align Left Edges, Enabled when Selected >= 2';
  SCnAlignRightCaption: string = 'Align Right Edges';
  SCnAlignRightHint: string = 'Align Right Edges, Enabled when Selected >= 2';
  SCnAlignTopCaption: string = 'Align Top Edges';
  SCnAlignTopHint: string = 'Align Top Edges, Enabled when Selected >= 2';
  SCnAlignBottomCaption: string = 'Align Bottom Edges';
  SCnAlignBottomHint: string = 'Align Bottom Edges, Enabled when Selected >= 2';
  SCnAlignHCenterCaption: string = 'Align Horizontal Centers';
  SCnAlignHCenterHint: string = 'Align Horizontal Centers, Enabled when Selected >= 2';
  SCnAlignVCenterCaption: string = 'Align Vertical Centers';
  SCnAlignVCenterHint: string = 'Align Vertical Centers, Enabled when Selected >= 2';
  SCnSpaceEquHCaption: string = 'Space Equally Horizontally';
  SCnSpaceEquHHint: string = 'Space Equally Horizontally, Enabled when Selected >= 3';
  SCnSpaceEquHXCaption: string = 'Space Equally Horizontally by...';
  SCnSpaceEquHXHint: string = 'Space Equally Horizontally by a Given Value, Enabled when Selected >= 2';
  SCnSpaceIncHCaption: string = 'Increase Horizontal Space';
  SCnSpaceIncHHint: string = 'Increase Horizontal Space, Enabled when Selected >= 2';
  SCnSpaceDecHCaption: string = 'Decrease Horizontal Space';
  SCnSpaceDecHHint: string = 'Decrease Horizontal Space, Enabled when Selected >= 2';
  SCnSpaceRemoveHCaption: string = 'Remove Horizontal Space';
  SCnSpaceRemoveHHint: string = 'Remove Horizontal Space, Enabled when Selected >= 2';
  SCnSpaceEquVCaption: string = 'Space Equally Vertically';
  SCnSpaceEquVHint: string = 'Space Equally Vertically, Enabled when Selected >= 3';
  SCnSpaceEquVYCaption: string = 'Space Equally Vertically by...';
  SCnSpaceEquVYHint: string = 'Space Equally Vertically by a Given Value, Enabled when Selected >= 2';
  SCnSpaceIncVCaption: string = 'Increase Vertical Space';
  SCnSpaceIncVHint: string = 'Increase Vertical Space, Enabled when Selected >= 2';
  SCnSpaceDecVCaption: string = 'Decrease Vertical Space';
  SCnSpaceDecVHint: string = 'Decrease Vertical Space, Enabled when Selected >= 2';
  SCnSpaceRemoveVCaption: string = 'Remove Vertical Space';
  SCnSpaceRemoveVHint: string = 'Remove Vertical Space, Enabled when Selected >= 2';
  SCnIncWidthCaption: string = 'Increase Width';
  SCnIncWidthHint: string = 'Increase Width';
  SCnDecWidthCaption: string = 'Decrease Width';
  SCnDecWidthHint: string = 'Decrease Width';
  SCnIncHeightCaption: string = 'Increase Height';
  SCnIncHeightHint: string = 'Increase Height';
  SCnDecHeightCaption: string = 'Decrease Height';
  SCnDecHeightHint: string = 'Decrease Height';
  SCnMakeMinWidthCaption: string = 'Shrink Width to Smallest';
  SCnMakeMinWidthHint: string = 'Shrink Width to Smallest, Enabled when Selected >= 2';
  SCnMakeMaxWidthCaption: string = 'Grow Width to Largest';
  SCnMakeMaxWidthHint: string = 'Grow Width to Largest, Enabled when Selected >= 2';
  SCnMakeSameWidthCaption: string = 'Make Same Width';
  SCnMakeSameWidthHint: string = 'Make same width to first selected control, Enabled when Selected >= 2';
  SCnMakeMinHeightCaption: string = 'Shrink Height to Smallest';
  SCnMakeMinHeightHint: string = 'Shrink Height to Smallest, Enabled when Selected >= 2';
  SCnMakeMaxHeightCaption: string = 'Grow Height to Largest';
  SCnMakeMaxHeightHint: string = 'Grow Height to Largest, Enabled when Selected >= 2';
  SCnMakeSameHeightCaption: string = 'Make Same Height';
  SCnMakeSameHeightHint: string = 'Make same height to first selected control, Enabled when Selected >= 2';
  SCnMakeSameSizeCaption: string = 'Make Same Size';
  SCnMakeSameSizeHint: string = 'Make same size to first selected control, Enabled when Selected >= 2';
  SCnParentHCenterCaption: string = 'Center Horizontally';
  SCnParentHCenterHint: string = 'Center horizontally in parent';
  SCnParentVCenterCaption: string = 'Center Vertically';
  SCnParentVCenterHint: string = 'Center vertically in parent';
  SCnBringToFrontCaption: string = 'Bring to Front';
  SCnBringToFrontHint: string = 'Bring control to front';
  SCnSendToBackCaption: string = 'Send to Back';
  SCnSendToBackHint: string = 'Send control to back';
  SCnSnapToGridCaption: string = 'Snap to Grid';
  SCnSnapToGridHint: string = 'Snap to grid when control remove or resize';
  SCnUseGuidelinesCaption: string = 'Designer Guideline';
  SCnUseGuidelinesHint: string = 'Toggle Designer Guideline';
  SCnAlignToGridCaption: string = 'Align to Grid';
  SCnAlignToGridHint: string = 'Align to grid';
  SCnSizeToGridCaption: string = 'Size to Grid';
  SCnSizeToGridHint: string = 'Size to grid';
  SCnLockControlsCaption: string = 'Lock Controls';
  SCnLockControlsHint: string = 'Lock Controls';
  SCnSelectRootCaption: string = 'Select Form';
  SCnSelectRootHint: string = 'Select Current Form in Current Designer';
  SCnCopyCompNameCaption: string = 'Copy Component''s Name';
  SCnCopyCompNameHint: string = 'Copy Selected Component''s Name to Clipboard';
  SCnNonArrangeCaption: string = 'Arrange Non-visual...';
  SCnNonArrangeHint: string = 'Arrange the Non-visual Components';
  SCnListCompCaption: string = 'Locate Components...';
  SCnListCompHint: string = 'Search and Locate Components in Designer';
  SCnCompToCodeCaption: string = 'Convert to Code...';
  SCnCompToCodeHint: string = 'Convert Selected Components to Creating Code';
  SCnHideComponentCaption: string = 'Hide Non-visual';
  SCnHideComponentHint: string = 'Hide / Display the Non-visual Component';
  SCnShowFlatFormCaption: string = 'Float Toolbar Options...';
  SCnShowFlatFormHint: string = 'Float Toolbar Options';
  SCnListComponentCount: string = 'Components Count: %d';
  SCnCompToCodeEnvNotSupport: string = 'Only VCL Designer Supported.';
  SCnCompToCodeProcCopiedFmt: string = '%s' + #13#10 + 'Copied to Clipboard. ';
  SCnCompToCodeConvertedFmt: string = '%d Items Converted';
  SCnMustGreaterThanZero: string = 'Numbers Entered Must Greater than Zero';
  SCnHideNonVisualNotSupport: string = 'Only VCL Designer Supported.';
  SCnNonNonVisualFound: string = 'No Non-visual Components Found!';
  SCnNonNonVisualNotSupport: string = 'Only VCL Designer Supported.';
  SCnSpacePrompt: string = 'Please Enter the Space:';
  SCnMustDigital: string = 'Please Enter a Digital Value.';

  // CnPaletteEnhanceWizard
  SCnPaletteEnhanceWizardName: string = 'IDE Main Form Enhancements';
  SCnPaletteEnhanceWizardComment: string = 'Component Palette & Main Form Enhancements';
  SCnPaletteTabsMenuCaption: string = '&Tabs';
  SCnPaletteMultiLineMenuCaption: string = '&Multi-Line';
  SCnLockToolbarMenuCaption: string = '&Lock Toolbar';
  SCnPaletteMoreCaption: string = '&More...';
  SCnSearchComponent: string = 'Search Component';
  SCnComponentDetailFmt: string = 'ClassName: %s' + #13#10 + 'Unit: %s' + #13#10 + 'Tab: %s' + #13#10#13#10 + 'Inheritance List: ' + #13#10#13#10;

  // CnVerEnhanceWizard
  SCnVerEnhanceWizardName: string = 'Version Enhancements';
  SCnVerEnhanceWizardComment: string = 'Version Enhancements Wizard';

  // CnCorPropWizard
  SCnCorrectPropertyName: string = 'Property Corrector';
  SCnCorrectPropertyMenuCaption: string = 'Property &Corrector...';
  SCnCorrectPropertyMenuHint: string = 'Correct Properties According to Some Customized Rules';
  SCnCorrectPropertyComment: string = 'Correct Properties According to Some Customized Rules';
  SCnCorrectPropertyActionWarn: string = 'Prompt';
  SCnCorrectPropertyActionAutoCorrect: string = 'Auto Correct';
  SCnCorrectPropertyStateCorrected: string = 'Corrected';
  SCnCorrectPropertyStateWarning: string = 'Require Affirmance';
  SCnCorrectPropertyAskDel: string = 'Sure to Delete this Rule?';
  SCnCorrectPropertyRulesCountFmt: string = 'Total Rules: %d .';
  SCnCorrectPropertyErrNoForm: string = 'No Form to Process.';
  SCnCorrectPropertyErrNoResult: string = 'No Property Found.';
  SCnCorrectPropertyErrNoModuleFound: string = 'Component NOT Exists, Perhaps Deleted or the Form has Closed.';
  SCnCorrectPropertyErrClassFmt: string = 'Can not Find the Class %s ,Continue?';
  SCnCorrectPropertyErrClassCreate: string = 'Can not Create the Class %s to Verify the Property, Continue?';
  SCnCorrectPropertyErrPropFmt: string = 'In %s, There''s No %s Property, Maybe only Exist in Decend Classes, Continue?';
  SCnCorrPropSetPropValueErrorFmt: string = 'Error Occurred when Processing the %s Property, Please Check Rules.' + #13#10#13#10;

  // CnProjectExtWizard
  SCnProjExtWizardName: string = 'Project Extension Wizard';
  SCnProjExtWizardCaption: string = '&Project Enhancements';
  SCnProjExtWizardHint: string = 'Tools to Enhance Functions about Project';
  SCnProjExtWizardComment: string = 'Tools to Enhance Functions about Project';
  SCnProjExtRunSeparatelyCaption: string = '&Run Separately From IDE';
  SCnProjExtRunSeparatelyHint: string = 'Run Separately From IDE, without Debugging';
  SCnProjExtExploreUnitCaption: string = 'Browse Current File''s &Dir...';
  SCnProjExtExploreUnitHint: string = 'Open Current File''s Directory in Windows Explorer';
  SCnProjExtExploreProjectCaption: string = 'Browse &Project Dir...';
  SCnProjExtExploreProjectHint: string = 'Open Project Directory in Windows Explorer';
  SCnProjExtExploreExeCaption: string = '&Browse Output Dir...';
  SCnProjExtExploreExeHint: string = 'Open Output Directory in Windows Explorer';
  SCnProjExtViewUnitsCaption: string = 'List &Units...';
  SCnProjExtViewUnitsHint: string = 'Display Units List in Project Group';
  SCnProjExtViewFormsCaption: string = 'List &Forms...';
  SCnProjExtViewFormsHint: string = 'Display Forms List in Project Group';
  SCnProjExtUseUnitsCaption: string = 'Use Un&it...';
  SCnProjExtUseUnitsHint: string = 'Show Units to Use';
  SCnProjExtListUsedCaption: string = 'List U&sed...';
  SCnProjExtListUsedHint: string = 'Show Units that Used by Current Unit';
  SCnProjExtBackupCaption: string = 'Project &Backup...';
  SCnProjExtBackupHint: string = 'Compress and Backup Project Files';
  SCnProjExtBackupFileCount: string = 'Backup %s Files: %d';
  SCnProjExtBackupNoFile: string = 'No Files to Backup.';
  SCnProjExtBackupMustZip: string = 'Only ZIP Format Supported. Change the File Extension to ZIP?';
  SCnProjExtBackupDllMissCorrupt: string = 'ZIP Library Missing or Corrupted. Please ReInstall.';
  SCnProjExtBackupErrorCompressor: string = 'External Compressor NOT Exists. Please Select One.';
  SCnProjExtBackupSuccFmt: string = 'File Saved to %s';
  SCnProjExtBackupFail: string = 'Backup Files Failed!';
  SCnProjExtDelTempCaption: string = '&Clean Temporary Files...';
  SCnProjExtDelTempHint: string = 'Clean Temporary Files in Project';
  SCnProjExtProjectAll: string = '<All>';
  SCnProjExtCurrentProject: string = '<Current Project>';
  SCnProjExtProjectCount: string = 'Projects Count: %d';
  SCnProjExtFormsFileCount: string = 'Forms Count: %d';
  SCnProjExtUnitsFileCount: string = 'Units Count: %d';
  SCnProjExtFramesFileCount: string = 'Frames Count: %d';
  SCnProjExtNotSave: string = '(Not Saved)';
  SCnProjExtFileNotExistOrNotSave: string = 'The File NOT Exists or Not Saved!';
  SCnProjExtOpenFormWarning: string = 'You Selected More than One Forms, Continue?';
  SCnProjExtOpenUnitWarning: string = 'You Selected More than One Units, Continue?';
  SCnProjExtFileIsReadOnly: string = 'The File is ReadOnly, Set its Attribute to Normal and Continue to Convert It?';
  SCnProjExtCreatePrjListError: string = 'Create ProjectList Error!';
  SCnProjExtErrorInUse: string = 'Can NOT Find these Files.' + #13#10 + 'Maybe They''re in Different Projects.';
  SCnProjExtAddExtension: string = 'Add File Extension';
  SCnProjExtAddNewText: string = 'Enter a File Extension:';
  SCnProjExtCleaningComplete: string = 'Cleaning complete. ' + #13#10 + 'Total delete %d files, ' + #13#10 + '%s bytes.';
  SCnProjExtFileReopenCaption: string = '&Open Historical Files...';
  SCnProjExtFileReopenHint: string = 'Open Historical Files';
  SCnProjExtCustomBackupFile: string = 'Customized Files';
  SCnProjExtDirBuilderCaption: string = 'Project Dir Bui&lder...';
  SCnProjExtDirBuilderHint: string = 'Open Project Dir Builder';
  SCnProjExtConfirmOverrideTemplet: string = 'Template "%s" already Exists, Overwrite?';
  SCnProjExtConfirmSaveTemplet: string = 'The Current Template does not saved, Save it?';
  SCnProjExtConfirmDeleteDir: string = 'Sure to Delete the Directory "%s"?';
  SCnProjExtConfirmDeleteTemplet: string = 'Sure to Delete the Template "%s"?';
  SCnProjExtSelectDir: string = 'Please Select a Directory:';
  SCnProjExtSaveTempletCaption: string = 'Save Template';
  SCnProjExtInputTempletName: string = 'Enter Template Name:';
  SCnProjExtIsNotUniqueDirName: string = 'Duplicated Directory Name.';
  SCnProjExtDirNameHasInvalidChar: string = 'The Directory Name can NOT Contain Following Char:'' + #10#13 + '' \ / :  * ? " < > | ';
  SCnProjExtDirCreateSucc: string = 'Directories Built Succeed.';
  SCnProjExtDirCreateFail: string = 'Directories Built Failed! Perhaps the Destination is Readonly.';

  // CnFilesSnapshotWizard
  SCnFilesSnapshotWizardName: string = 'Historical Files Snapshot';
  SCnFilesSnapshotWizardCaption: string = 'Historical Files Snapshot';
  SCnFilesSnapshotWizardHint: string = 'Historical Files Snapshot';
  SCnFilesSnapshotWizardComment: string = 'Historical Files Snapshot';
  SCnFilesSnapshotAddCaption: string = '&Create a Snapshot...';
  SCnFilesSnapshotAddHint: string = 'Create a Snapshot of Opened Files';
  SCnFilesSnapshotManageCaption: string = '&Manage Snapshot List...';
  SCnFilesSnapshotManageHint: string = 'Manage Snapshot List';
  SCnFilesSnapshotManageFrmCaptionManage: string = 'Manage File List Snapshots';
  SCnFilesSnapshotManageFrmCaptionAdd: string = 'Create a File List Snapshot';
  SCnFilesSnapshotManageFrmLblSnapshotsCaptionManage: string = 'Select a Snapshot:';
  SCnFilesSnapshotManageFrmLblSnapshotsCaptionAdd: string = 'Save File List as a Snapshot:';

  // CnCommentCroperWizard
  SCnCommentCropperWizardName: string = 'Comment Cropper';
  SCnCommentCropperWizardMenuCaption: string = 'Comments Cropper...';
  SCnCommentCropperWizardMenuHint: string = 'Crop Comments in Source Code';
  SCnCommentCropperWizardComment: string = 'Crop Comments in Source Code';
  SCnCommentCropperCountFmt: string = '%d File(s) Processed.';

  // CnFavoriteWizard
  SCnFavWizName: string = 'Favorites Wizard';
  SCnFavWizCaption: string = 'Favorites';
  SCnFavWizHint: string = 'Manager the Favorite Projects, Units and Forms.';
  SCnFavWizComment: string = 'Manager the Favorite Projects, Units and Forms.';
  SCnFavWizAddToFavoriteMenuCaption: string = '&Add to Favorites...';
  SCnFavWizAddToFavoriteMenuHint: string = 'Add Current File to Favorites';
  SCnFavWizManageFavoriteMenuCaption: string = '&Organize Favorites...';
  SCnFavWizManageFavoriteMenuHint: string = 'Organize Files in Favorites';

  // CnCpuWinEnhancements
  SCnCpuWinEnhanceWizardName: string = 'CPU Window Enhancements';
  SCnCpuWinEnhanceWizardComment: string = 'Copy ASM Code in CPU Window';
  SCnMenuCopyLinesToClipboard: string = 'Copy %d Lines';
  SCnMenuCopyLinesToFile: string = 'Copy %d Lines to File...';
  SCnMenuCopyLinesCaption: string = 'Copy ASM Code...';

  // CnResourceMgrWizard
  SCnResMgrWizardMenuCaption: string = 'Resource Manager';
  SCnResMgrWizardMenuHint: string = 'Resource Manager';
  SCnResMgrWizardName: string = 'Resource Manager';
  SCnResMgrWizardComment: string = 'Resource Manager.';
  SCnDocumentMgrWizardCaption: string = 'Document Manager';
  SCnDocumentMgrWizardHint: string = 'Document Manager';
  SCnDocumentMgrWizardComment: string = 'Document Manager.';
  SCnImageMgrWizardCaption: string = 'Image Manager';
  SCnImageMgrWizardHint: string = 'Image Manager';
  SCnImageMgrWizardComment: string = 'Image Manager.';
  SCnResMgrConfigCaption: string = 'Options...';
  SCnResMgrConfigHint: string = 'Resource Manager Options';
  SCnResMgrConfigComment: string = 'Resource Manager Options';

  // CnRepositoryMenu
  SCnRepositoryMenuCaption: string = 'Repository List';
  SCnRepositoryMenuHint: string = 'Cn Repository Wizards List';
  SCnRepositoryMenuName: string = 'Repository List';
  SCnRepositoryMenuComment: string = 'Cn Repository Wizards List';

  // CnDUnitWizard
  SCnDUnitWizardName: string = 'DUnit Test Case';
  SCnDUnitWizardComment: string = 'Generate DUnit Test Case Application, DUnit Needed.';
  SCnDUnitErrorNOTSupport: string = 'Only Delphi/Pascal Supported!';
  SCnDUnitTestName: string = 'Test Name:';
  SCnDUnitTestAuthor: string = '   Author:';
  SCnDUnitTestVersion: string = '  Version:';
  SCnDUnitTestDescription: string = '  Summary:';
  SCnDUnitTestComments: string = ' Comments:';

  // CnObjInspectorEnhanceWizard
  SCnObjInspectorEnhanceWizardName: string = 'Object Inspector Enhancements';
  SCnObjInspectorEnhanceWizardComment: string = 'Object Inspector Enhancements';

  // CnWizBoot
  SCnWizBootCurrentCount: string = 'Current Wizards: %d';
  SCnWizBootEnabledCount: string = 'Enabled Wizards: %d';

  // CnExplore
  SCnExploreMenuCaption: string = 'Explorer...';
  SCnExploreMenuHint: string = 'Embedded Windows Explorer. Its Functions include Filtering, Favorites and Cleaning Temporary Files.';
  SCnExploreName: string = 'Explorer Wizard';
  SCnExploreComment: string = 'Embedded Windows Explorer. Its Functions include Filtering, Favorites and Cleaning Temporary Files.';
  SCnNewFolder: string = 'New Folder';
  SCnNewFolderHint: string = 'Enter the Folder Name:';
  SCnNewFolderDefault: string = 'New Folder';
  SCnUnableToCreateFolder: string = 'Unable to Create Folder!';
  SCnExploreFilterAllFile: string = 'All Files';
  SCnExploreFilterDelphiFile: string = 'Delphi Files';
  SCnExploreFilterBCBFile: string = 'C++Builder Files';
  SCnExploreFilterDelphiProjectFile: string = 'Project Files';
  SCnExploreFilterDelphiPackageFile: string = 'Package Files';
  SCnExploreFilterDelphiUnitFile: string = 'Delphi Units';
  SCnExploreFilterDelphiFormFile: string = 'Form Files';
  SCnExploreFilterConfigFile: string = 'Configuration Files';
  SCnExploreFilterTextFile: string = 'Text File';
  SCnExploreFilterSqlFile: string = 'SQL File';
  SCnExploreFilterHtmlFile: string = 'HTML File';
  SCnExploreFilterWebFile: string = 'Web Page';
  SCnExploreFilterBatchFile: string = 'BAT File';
  SCnExploreFilterTypeLibFile: string = 'Type Library';
  SCnExploreFilterDefault: string = 'Restore Default Settings and Discard Changes, Continue?';
  SCnExploreFilterDeleteFmt: string = 'Sure to Delete the Filter?' + #13#10 + 'Type:    %s' + #13#10 + 'Ext:     %s';

  // CnIniFilerWizard
  SCnIniFilerWizardName: string = 'INI Reader and Writer';
  SCnIniFilerWizardComment: string = 'Generate a Read and Write Unit from a INI file.';
  SCnIniFilerPasFilter: string = 'Pascal File (*.pas)|*.pas';
  SCnIniFilerCppFilter: string = 'C++ File (*.cpp)|*.cpp';
  SCnIniErrorNoFile: string = 'Error Input or the INI File NOT Exists. Please Select a File Again.';
  SCnIniErrorPrefix: string = 'Invalid Constant Prefix';
  SCnIniErrorClassName: string = 'Invalid ClassName';
  SCnIniErrorReadIni: string = 'Error Occurred when Read the INI File, Please Check It.';
  SCnIniErrorNOTSupport: string = 'Only Pascal or C++ Supported. C# and Other Formats NOT Supported.';
  SCnIniErrorNOProject: string = 'Please Select the Language Type.' + #13#10 + 'Use Pascal? YES Means Pascal, and NO Means C++.';

  // CnMemProfWizard
  SCnMemProfWizardName: string = 'CnMemProf Project';
  SCnMemProfWizardComment: string = 'Generate A Project with CnMemProf to Report Memory Usage.';

  // CnWinTopRoller
  SCnWinTopRollerName: string = 'Caption Button Enhancements';
  SCnWinTopRollerComment: string = 'Add Caption Buttons to IDE Windows';
  SCnWinTopRollerBtnTopHint: string = 'Stay On Top';
  SCnWinTopRollerBtnRollerHint: string = 'Roll this Window';
  SCnWinTopRollerBtnOptionsHint: string = 'DropDown Menu';
  SCnWinTopRollerPopupAddToFilter: string = '&Add to Filters';
  SCnWinTopRollerPopupOptions: string = '&Options...';

  // CnInputHelper
  SCnInputHelperName: string = 'Code Input Helper';
  SCnInputHelperComment: string = 'Auto Drop Down Window like Code-Insight';
  SCnInputHelperConfig: string = '&Settings...';
  SCnInputHelperAutoPopup: string = '&Auto Popup';
  SCnInputHelperDispButtons: string = 'Display Speed &Buttons';
  SCnInputHelperSortKind: string = 'So&rt Style';
  SCnInputHelperIcon: string = 'Explain of &Images';
  SCnInputHelperSortByScope: string = 'Automatic(&1)';
  SCnInputHelperSortByText: string = 'by Text(&2)';
  SCnInputHelperSortByLength: string = 'by Length(&3)';
  SCnInputHelperSortByKind: string = 'by Type(&4)';
  SCnInputHelperAddSymbol: string = 'Add a User-defined &Symbol...';
  SCnInputHelperHelp: string = 'Input Helper Tool &Help';
  SCnInputHelperKibitzCompileRunning: string = 'Retrieving Symbols in Background';
  SCnInputHelperPreDefSymbolList: string = 'Pre-defined Symbols and Code Templates';
  SCnInputHelperUserTemplateList: string = 'Frequent Code Templates';
  SCnInputHelperCompDirectSymbolList: string = 'System Compiler directives';
  SCnInputHelperUnitNameList: string = 'Unit Names in uses Statement Area';
  SCnInputHelperUnitUsesList: string = 'Used Unit Names in Source Code Area';
  SCnInputHelperIDECodeTemplateList: string = 'IDE''s Code Templates';
  SCnInputHelperIDESymbolList: string = 'Symbols getting from System Compiler';
  SCnInputHelperUserSymbolList: string = 'User-defined Symbols and Code Templates';
  SCnInputHelperXMLCommentList: string = 'Code Comments in XML Style';
  SCnInputHelperJavaDocList: string = 'Code Comments in JavaDoc Style';
  SCnInputHelperSymbolNameIsEmpty: string = 'Symbol Name can NOT be Empty!';
  SCnInputHelperSymbolKindError: string = 'Please select the Symbol Type!';
  SCnInputHelperUserMacroCaption: string = 'User-defined Macro';
  SCnInputHelperUserMacroPrompt: string = 'Please Input Macro Name:';
  SCnKeywordDefault: string = 'Unchange';
  SCnKeywordLower: string = 'Lower case';
  SCnKeywordUpper: string = 'Upper case';
  SCnKeywordFirstUpper: string = 'Only first up';

  // CnProcListWizard
  SCnProcListWizardName: string = 'Procedure List Wizard';
  SCnProcListWizardComment: string = 'List All Procedures and Functions in Current Source File';
  SCnProcListWizardMenuCaption: string = 'Procedure Li&st...';
  SCnProcListWizardMenuHint: string = 'List All Procedures and Functions in Current Source File';
  SCnProcListObjsAll: string = '<All>';
  SCnProcListObjsNone: string = '<Independent>';
  SCnProcListErrorInFile: string = 'Error in Parsing, File maybe Corrupted.';
  SCnProcListErrorFileType: string = 'File NOT Exists or File Type NOT Supported.';
  SCnProcListErrorPreview: string = '<Preview Disabled for File NOT Opened.>';
  SCnProcListCurrentFile: string = '<Current>';
  SCnProcListAllFileInProject: string = '<All in Project>';
  SCnProcListAllFileInProjectGroup: string = '<All in ProjectGroup>';
  SCnProcListAllFileOpened: string = '<All Opened>';
  SCnProcListJumpIntfHint: string = 'Jump to Interface';
  SCnProcListJumpImplHint: string = 'Jump to Implementation';
  SCnProcListClassComboHint: string = 'Class List';
  SCnProcListProcComboHint: string = 'Procedure/Function List';
  SCnProcListMatchStartHint: string = 'Match Name Start';
  SCnProcListMatchAnyHint: string = 'Match All Parts';
  SCnProcListSortMenuCaption: string = '&Sort';
  SCnProcListSortSubMenuByName: string = 'By &Name';
  SCnProcListSortSubMenuByLocation: string = 'By &Location';
  SCnProcListSortSubMenuReverse: string = '&Reversed';
  SCnProcListExportMenuCaption: string = '&Export List...';
  SCnProcListCloseMenuCaption: string = '&Hide Procedure List ToolBar';
  SCnProcListNoContent: string = '<None>';
  SCnProcListCloseToolBarHint: string = 'You Choose to Close Procedure List ToolBar.' + #13#10#13#10 +
    'If You Want to Show it Again. You can Click the "Show Procedure List ToolBar" Button' + #13#10 +
    'in Procedure List Dialog.';
  SCnProcListErrorNoIntf: string = 'Interface NOT Found.';
  SCnProcListErrorNoImpl: string = 'Implementation NOT Found.';

  // CnUsesCleaner
  SCnUsesCleanerMenuCaption: string = '&Uses Cleaner...';
  SCnUsesCleanerMenuHint: string = 'Clean Unused Units Reference';
  SCnUsesCleanerName: string = 'Uses Units Cleaner';
  SCnUsesCleanerComment: string = 'Clean Unused Units Reference';
  SCnUsesCleanerCompileFail: string = 'Compile Error. Cleaner can NOT continue.';
  SCnUsesCleanerUnitError: string = 'Processing %s Failed.' + #13#10#13#10 + 'Perhaps the Format is NOT supported, Please contact CnPack Team. ';
  SCnUsesCleanerProcessError: string = 'Failed when Processing file %s , Continue?';
  SCnUsesCleanerHasInitSection: string = 'Including initialization';
  SCnUsesCleanerHasRegProc: string = 'Including Register';
  SCnUsesCleanerInCleanList: string = 'In Clean List';
  SCnUsesCleanerInIgnoreList: string = 'In Skipping List';
  SCnUsesCleanerCompRef: string = 'Indirectly Depend';
  SCnUsesCleanerNotSource: string = 'NO Source Code.';
  SCnUsesCleanerNoneResult: string = 'Nothing to Process.';
  SCnUsesCleanerReport: string = 'Clean Complete!' + #13#10 + '%d Unused Reference Units Removed from %d Units.' + #13#10#13#10 + 'Do you want to view log?';

  // CnIdeEnhanceMenu
  SCnIdeEnhanceMenuCaption: string = '&IDE Enhancements Settings';
  SCnIdeEnhanceMenuHint: string = 'IDE Enhancements Settings';
  SCnIdeEnhanceMenuName: string = 'IDE Enhancements Settings';
  SCnIdeEnhanceMenuComment: string = 'IDE Enhancements Settings';

  // CnSourceHighlight
  SCnSourceHighlightWizardName: string = 'Source Highlight Enhancements';
  SCnSourceHighlightWizardComment: string = 'Bracket Match & Structure Highlight';

  // CnIdeBRWizard
  SCnIdeBRWizardMenuCaption: string = 'IDE Config Backup&/Restore...';
  SCnIdeBRWizardMenuHint: string = 'Run IDE Config Backup/Restore Tool';
  SCnIdeBRWizardName: string = 'IDE Config Backup/Restore Tool';
  SCnIdeBRWizardComment: string = 'Run IDE Config Backup/Restore Tool';
  SCnIdeBRToolNotExists: string = 'Can NOT Find IDE Config Backup/Restore Tool. Please Reinstall CnWizards!';

  // CnFastCodeWizard
  SCnFastCodeWizardName: string = 'FastCode IDE Optimizer';
  SCnFastCodeWizardComment: string = 'Improve the IDE Performance by Using FastCode/FastMove';

  // CnScriptWizard
  SCnScriptWizardMenuCaption: string = 'Sc&ript Wizard';
  SCnScriptWizardMenuHint: string = 'Extend IDE by Writing Pascal Script';
  SCnScriptWizardName: string = 'Script Wizard';
  SCnScriptWizardComment: string = 'Extend IDE by Writing Pascal Script';
  SCnScriptFormCaption: string = 'Script &Window...';
  SCnScriptFormHint: string = 'Show the Script Window';
  SCnScriptWizCfgCaption: string = 'Script &Library...';
  SCnScriptWizCfgHint: string = 'Script Libary Window';
  SCnScriptBrowseDemoCaption: string = '&Browse Demo...';
  SCnScriptBrowseDemoHint: string = 'Open Script Demo Directory in Windows Explorer';
  SCnScriptFileNotExists: string = 'Script File NOT Exists!';
  SCnScriptCompError: string = 'Compiling Error:';
  SCnScriptExecError: string = 'Runtime Error:';
  SCnScriptCompiler: string = 'Compiler';
  SCnScriptCompiling: string = 'Compiling...';
  SCnScriptErrorMsg: string = '%s at %d.%d';
  SCnScriptCompiledSucc: string = 'Compiled Successfully';
  SCnScriptExecutedSucc: string = 'Successfully Executed';
  SCnScriptCompilingFailed: string = 'Compiling Failed';
  SCnScriptExecConfirm: string = 'Sure to Execute Script "%s"?';
  SCnScriptMenuDemoCaption: string = '&Demos';
  SCnScriptMenuDemoHint: string = 'Script Demos';

  // CnFeedWizard
  SCnFeedWizardName: string = 'FeedReader Wizard';
  SCnFeedWizardComment: string = 'Display Feed Content in Status Bar';
  SCnFeedPrevFeedCaption: string = '&Previous Item';
  SCnFeedNextFeedCaption: string = '&Next Item';
  SCnFeedForceUpdateCaption: string = '&Update All';
  SCnFeedConfigCaption: string = '&Settings...';
  SCnFeedCloseCaption: string = '&Close';
  SCnFeedCloseQuery: string = 'Sure to Close FeedReader Wizard?';
  SCnFeedNewItem: string = 'New Feed';

implementation

end.

