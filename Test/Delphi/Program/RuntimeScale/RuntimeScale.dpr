program RuntimeScale;

uses
  Forms,
  UnitRuntimeSale in 'UnitRuntimeSale.pas' {FormRuntimeTest},
  TestEditorCodeToString in 'TestEditorCodeToString.pas' {CnEditorCodeToStringForm},
  CnWizScaler in '..\..\..\..\Source\Utils\CnWizScaler.pas',
  TestEditorCodeComment in 'TestEditorCodeComment.pas' {EditorCodeCommentForm},
  TestEditorWizard in 'TestEditorWizard.pas' {EditorToolsForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormRuntimeTest, FormRuntimeTest);
  Application.Run;
end.
