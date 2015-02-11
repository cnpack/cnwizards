library CnFormatLib;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  CnFormatterIntf in '..\..\Source\CodeFormatter\CnFormatterIntf.pas',
  CnCodeFormatterImpl in 'CnCodeFormatterImpl.pas',
  CnCodeFormatter in '..\..\Source\CodeFormatter\CnCodeFormatter.pas',
  CnCodeFormatRules in '..\..\Source\CodeFormatter\CnCodeFormatRules.pas',
  CnCodeGenerators in '..\..\Source\CodeFormatter\CnParser\CnCodeGenerators.pas',
  CnCompilerConsts in '..\..\Source\CodeFormatter\CnParser\CnCompilerConsts.pas',
  CnParseConsts in '..\..\Source\CodeFormatter\CnParser\CnParseConsts.pas',
  CnPascalGrammar in '..\..\Source\CodeFormatter\CnParser\CnPascalGrammar.pas',
  CnScaners in '..\..\Source\CodeFormatter\CnParser\CnScaners.pas',
  CnTokens in '..\..\Source\CodeFormatter\CnParser\CnTokens.pas';

{$R *.RES}

begin
end.
