{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CnWizards_L4;

{$warn 5023 off : no warning about unused units}
interface

uses
  CnLazPkgEntry, CnWizConsts, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('CnLazPkgEntry', @CnLazPkgEntry.Register);
end;

initialization
  RegisterPackage('CnWizards_L4', @Register);
end.
