{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CnWizards_L4;

{$warn 5023 off : no warning about unused units}
interface

uses
  CnLazPkgEntry, CnWizConsts, CnWizCompilerConst, CnWizOptions, CnWizShortCut, 
  CnWizMenuAction, CnWizClasses, CnPasCodeParser, CnPasWideLex, 
  CnWidePasParser, mPasLex, CnWizManager, CnWizIdeUtils, CnWizUtils, 
  CnWizAbout, CnWizAboutFrm, CnMessageBoxWizard, CnWizConfigFrm, 
  CnTestEditorTextWizard, CnWizIdeDock, CnAICoderEngine, CnAICoderEngineImpl, 
  CnAICoderNetClient, CnAICoderConfig, CnAICoderChatFrm, CnAICoderWizard, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('CnLazPkgEntry', @CnLazPkgEntry.Register);
end;

initialization
  RegisterPackage('CnWizards_L4', @Register);
end.
