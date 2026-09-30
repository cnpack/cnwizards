{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CnWizards_L4;

{$warn 5023 off : no warning about unused units}
interface

uses
  CnLazPkgEntry, CnWizConsts, CnWizCompilerConst, CnWizOptions, CnWizShortCut, 
  CnWizMenuAction, CnWizClasses, CnWizManager, mPasLex, CnPasCodeParser, 
  CnPasWideLex, CnWidePasParser, CnWizIdeUtils, CnWizUtils, CnWizIdeDock, 
  CnFloatWindow, CnSourceCropper, CnPascalAST, CnLineParser, CnWizEditFiler, 
  CnWizCmdMsg, CnWizCmdNotify, CnWizCmdSend, CnWizMultiLang, CnWizAbout, 
  CnWizAboutFrm, CnMessageBoxWizard, CnWizConfigFrm, CnAICoderEngine, 
  CnAICoderEngineImpl, CnAICoderNetClient, CnAICoderConfig, CnAICoderChatFrm, 
  CnAICoderWizard, CnCodingToolsetWizard, CnProjectViewBaseFrm, 
  CnEditorOpenFile, CnEditorOpenFileFrm, CnProcListWizard, CnSrcEditorToolBar, 
  CnFlatToolbarConfigFrm, CnComponentSelector, CnAsciiChart, 
  CnSelectionCodeTool, CnEditorInsertColor, CnEditorCodeSwap, 
  CnEditorCodeToString, CnSrcTemplate, CnSrcTemplateEditFrm, CnCommentCropper, 
  CnBookmarkWizard, CnWizNotifier, CnStatFrm, CnStatResultFrm, CnStatWizard, 
  CnEditorCodeComment, CnPas2HtmlConfigFrm, CnPas2HtmlWizard, 
  CnPasConvertTypeFrm, CnCodeFormatRules, CnCodeFormatterWizard, 
  CnFormatterIntf, CnTabOrderWizard, CnEditorToggleUses, CnEditorToggleVar, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('CnLazPkgEntry', @CnLazPkgEntry.Register);
end;

initialization
  RegisterPackage('CnWizards_L4', @Register);
end.
