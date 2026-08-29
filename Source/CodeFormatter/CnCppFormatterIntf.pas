unit CnCppFormatterIntf;

{$I CnPack.inc}

interface

{$IFDEF MSWINDOWS}
uses Windows;
{$ENDIF}

{$IFNDEF MSWINDOWS}
type DWORD = Cardinal;
{$ENDIF}

const
  CN_CPP_BRACE_SAMELINE = 0;
  CN_CPP_BRACE_NEXTLINE = 1;

type

  ICnCppFormatterIntf = interface
    ['{C6B53E5D-6A95-4C4A-9E2B-9A0B8E1D6F20}']
    procedure SetCppFormatRule(TabSpace, WrapWidth, BraceStyle,
      SpaceBeforeBinaryOperator, SpaceAfterBinaryOperator: DWORD;
      KeepUserLineBreak, UseIgnoreArea, FormatAsm: LongBool);
    function FormatOneCppUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    function FormatOneCppUnitUtf8(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    function FormatOneCppUnitW(Input: PWideChar; Len: DWORD): PWideChar;
    function FormatCppBlock(Input: PAnsiChar; Len, StartOffset,
      EndOffset: DWORD): PAnsiChar;
    function FormatCppBlockUtf8(Input: PAnsiChar; Len, StartOffset,
      EndOffset: DWORD): PAnsiChar;
    function FormatCppBlockW(Input: PWideChar; Len, StartOffset,
      EndOffset: DWORD): PWideChar;
  end;

  TCnGetCppFormatterProvider = function: ICnCppFormatterIntf; stdcall;

implementation

end.
