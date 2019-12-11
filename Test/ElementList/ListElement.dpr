program ListElement;

uses
  SysUtils,
  Forms,
  CnProjectViewBaseFrm in '..\..\Source\ProjectExtWizard\CnProjectViewBaseFrm.pas',
  CnWizMultiLang in '..\..\Source\MultiLang\CnWizMultiLang.pas' {CnTranslateForm},
  CnWizLangID in '..\..\Source\MultiLang\CnWizLangID.pas',
  CnWizShareImages in '..\..\Source\Misc\CnWizShareImages.pas' {dmCnSharedImages: TDataModule},
  CnProcListWizard in '..\..\Source\SimpleWizards\CnProcListWizard.pas' {CnProcListForm};

var
  Wizard: TCnProcListWizard;
begin
  Application.CreateForm(TdmCnSharedImages, dmCnSharedImages);
  Wizard := TCnProcListWizard.Create;
  Wizard.Execute;
  Wizard.Free;
end.