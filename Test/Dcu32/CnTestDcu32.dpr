program CnTestDcu32;

uses
  Forms,
  CnTestDcu32Frm in 'CnTestDcu32Frm.pas' {Form1},
  DasmUtil in '..\..\Source\ThirdParty\DCU32\DAsmUtil.pas',
  DasmX86 in '..\..\Source\ThirdParty\DCU32\DasmX86.pas',
  DCP in '..\..\Source\ThirdParty\DCU32\DCP.pas',
  DCU32 in '..\..\Source\ThirdParty\DCU32\DCU32.pas',
  DCU_In in '..\..\Source\ThirdParty\DCU32\DCU_In.pas',
  DCU_Out in '..\..\Source\ThirdParty\DCU32\DCU_Out.pas',
  DCURecs in '..\..\Source\ThirdParty\DCU32\DCURecs.pas',
  DCUTbl in '..\..\Source\ThirdParty\DCU32\DCUTbl.pas',
  FixUp in '..\..\Source\ThirdParty\DCU32\FixUp.pas',
  op in '..\..\Source\ThirdParty\DCU32\op.pas',
  DasmCF in '..\..\Source\ThirdParty\DCU32\DasmCF.pas',
  DasmDefs in '..\..\Source\ThirdParty\DCU32\DasmDefs.pas',
  DasmMSIL in '..\..\Source\ThirdParty\DCU32\DasmMSIL.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
