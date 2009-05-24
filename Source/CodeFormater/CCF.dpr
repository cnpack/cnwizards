program CCF;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  CnCodeFormater in 'CnCodeFormater.pas',
  CnCodeFormatRules in 'CnCodeFormatRules.pas',
  CnCodeGenerators in 'CnParser\CnCodeGenerators.pas',
  CnCompilerConsts in 'CnParser\CnCompilerConsts.pas',
  CnKeywords in 'CnParser\CnKeywords.pas',
  CnScaners in 'CnParser\CnScaners.pas',
  CnTokens in 'CnParser\CnTokens.pas';

var
  InputFileName, OutputFileName, RuleFileName: String;

  I: Integer;

procedure PromptHelp;
begin
  Writeln('CnPack code formater commandline tools');
  Writeln('Author: CnPack, Simon Liu, 2003-3-1');
  Writeln('Usage: CCF [OPTION]');
  Writeln('Option:');
  Writeln('  -i InputFileName        Special the input source file name');
  Writeln('  -o OutputFileName       Special the output source file name');
  Writeln('  -s RuleFileName         Special the format rule file name');
  //Writeln('  -d Path                 Format all file in the directory, result file end with .ccf');
  Writeln('  -q                      Quite mode, without any output');
  Writeln('  -h                      Prompt this help');
  Writeln('  -v                      Version');
  Writeln;
end;

procedure ParseOptionSwitch;
var
  Index: Integer;
begin
  if ParamCount = 0 then
  begin
    PromptHelp;
    Exit;
  end;

  Index := 1;

  repeat
    if (Length(ParamStr(Index)) > 1) and (ParamStr(Index)[1]='-') then
    begin
      case UpperCase(ParamStr(Index)[2])[1] of
        'I': InputFileName := ParamStr(Index+1);
        'O': OutputFileName := ParamStr(Index+1);
        'S': RuleFileName := ParamStr(Index+1);
        'Q': ;
        'H': PromptHelp;
        'V': ;
      else
        Writeln('Unknown option switch ' + ParamStr(Index));
      end;
    end else
    begin
      Writeln('Unknown option switch ' + ParamStr(Index));
    end;
    
    Inc(Index);
  until Index > ParamCount;
end;

procedure FormatCode(IntpuFile, OutpurFile, RuleFile: String);
begin

end;

begin
  ParseOptionSwitch;
  
  if InputFileName = '' then
  begin
    Writeln('Use -i to special input source file.');
    Exit;
  end;
  
  if not FileExists(InputFileName) then
  begin
    Writeln('Source file ' + InputFileName + ' not found.');
    Exit;
  end;

  if OutputFileName = '' then
    OutputFileName := InputFileName + '.ccf';

  try
    FormatCode(InputFileName, OutputFileName, RuleFileName);
  except
    on E: Exception do
    begin
      Writeln(E.Message);
      Exit;
    end;
  end;

  Writeln;
  Writeln('Format Complete.');
end.
