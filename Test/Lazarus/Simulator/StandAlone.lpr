program StandAlone;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms, CnMessageBoxWizard, CnProcListWizard, CnCommentCropper,
  CnBookmarkConfigFrm, CnBookmarkWizard, CnPas2HtmlConfigFrm, CnPas2HtmlWizard,
  CnPasConvertTypeFrm, CnTabOrderWizard, CnAICoderChatFrm, CnAICoderConfig,
  CnAICoderEngine, CnAICoderEngineImpl, CnAICoderNetClient, CnFrmAICoderOption,
  CnAICoderWizard, CnProjectViewBaseFrm, CnCodingToolsetWizard,
  CnEditorOpenFile, CnEditorOpenFileFrm, CnAsciiChart, CnEditorCodeComment,
  CnEditorCodeDelBlank, CnEditorCodeIndent, CnWizConfigFrm, CnWizMenuSortFrm,
  CnWizSubActionShortCutFrm, CnWizLangID, CnWizMultiLang, CnWizMultiLangFrame,
  CnWizTranslate, CnSrcTemplate, CnSrcTemplateEditFrm, CnStatFrm,
  CnStatResultFrm, CnStatWizard, CnCodeFormatterWizard, CnFormatterIntf,
  CnExplore, CnExploreDirectory, CnExploreFilter, CnExploreFilterEditor,
  StandAloneUnit, TestFormUnit {FormFramework};

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
