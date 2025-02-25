program CnTestDcu32;

uses
  Forms,
  CnTestDcu32Frm in 'CnTestDcu32Frm.pas' {FormDcu32},
  DAsmUtil in '..\..\Source\ThirdParty\DCU32_110\DAsmUtil.pas',
  DasmX86 in '..\..\Source\ThirdParty\DCU32_110\DasmX86.pas',
  DCP in '..\..\Source\ThirdParty\DCU32_110\DCP.pas',
  DCU32 in '..\..\Source\ThirdParty\DCU32_110\DCU32.pas',
  DCU_In in '..\..\Source\ThirdParty\DCU32_110\DCU_In.pas',
  DCU_Out in '..\..\Source\ThirdParty\DCU32_110\DCU_Out.pas',
  DCURecs in '..\..\Source\ThirdParty\DCU32_110\DCURecs.pas',
  DCUTbl in '..\..\Source\ThirdParty\DCU32_110\DCUTbl.pas',
  FixUp in '..\..\Source\ThirdParty\DCU32_110\FixUp.pas',
  op in '..\..\Source\ThirdParty\DCU32_110\op.pas',
  DasmCF in '..\..\Source\ThirdParty\DCU32_110\DasmCF.pas',
  DasmDefs in '..\..\Source\ThirdParty\DCU32_110\DasmDefs.pas',
  DasmMSIL in '..\..\Source\ThirdParty\DCU32_110\DasmMSIL.pas',
  CnDCU32 in '..\..\Source\Utils\CnDCU32.pas',
  Win64SEH in '..\..\Source\ThirdParty\DCU32_110\Win64SEH.pas',
  DasmOpT in '..\..\Source\ThirdParty\DCU32_110\DasmOpT.pas',
  InlineOp in '..\..\Source\ThirdParty\DCU32_110\InlineOp.pas',
  DasmProc in '..\..\Source\ThirdParty\DCU32_110\DasmProc.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormDcu32, FormDcu32);
  Application.Run;
end.
