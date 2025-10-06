{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnFormatterIntf;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������ӿ�
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ���������ʽ���Ķ���ӿ�
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�����ƽ̨
* �� �� ��������Ҫ
* �޸ļ�¼��2015.02.11 V1.0
*               ������Ԫ��
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows;

const
  // ���� IFDEF ELSE ENDIF ʱ�Ĵ���ģʽ
  CN_RULE_DIRECTIVE_MODE_ASCOMMENT    = 1;
  {* ����ע�ʹ���}
  CN_RULE_DIRECTIVE_MODE_ONLYFIRST    = 2;
  {* ֻ�����һ����}
  CN_RULE_DIRECTIVE_MODE_DEFAULT      = CN_RULE_DIRECTIVE_MODE_ASCOMMENT;

  // �ؼ��ִ�Сд����
  CN_RULE_KEYWORD_STYLE_UPPER         = 1;
  {* ȫ��д}
  CN_RULE_KEYWORD_STYLE_LOWER         = 2;
  {* ȫСд}
  CN_RULE_KEYWORD_STYLE_UPPERFIRST    = 3;
  {* ����ĸ��д}
  CN_RULE_KEYWORD_STYLE_NOCHANGE      = 4;
  {*���ı�ԭ�е�}
  CN_RULE_KEYWORD_STYLE_DEFAULT       = CN_RULE_KEYWORD_STYLE_LOWER;

  // Begin �鿪ʼģʽ
  CN_RULE_BEGIN_STYLE_NEXTLINE        = 1;
  {* begin ����һ��}
  CN_RULE_BEGIN_STYLE_SAMELINE        = 2;
  {* begin �ڱ���}
  CN_RULE_BEGIN_STYLE_DEFAULT         = CN_RULE_BEGIN_STYLE_NEXTLINE;

  // Ene ��� Else �鿪ʼģʽ
  CN_RULE_ELSEAFTEREND_STYLE_NEXTLINE = 1;
  {* else ����һ��}
  CN_RULE_ELSEAFTEREND_STYLE_SAMELINE = 2;
  {* else �ڱ���}
  CN_RULE_ELSEAFTEREND_STYLE_DEFAULT  = CN_RULE_ELSEAFTEREND_STYLE_NEXTLINE;

  // ���뻻��ģʽ
  CN_RULE_CODE_WRAP_MODE_NONE         = 1;
  {* �����Զ�����}
  CN_RULE_CODE_WRAP_MODE_SIMPLE       = 2;
  {* �������õ� WrapWidth ���Զ�����}
  CN_RULE_CODE_WRAP_MODE_ADVANCED     = 3;
  {* �������õ� WrapNewLineWidth �� �� WrapWidth ���Զ�����}
  CN_RULE_CODE_WRAP_MODE_DEFAULT      = CN_RULE_CODE_WRAP_MODE_NONE;

  // Ĭ�������ո���
  CN_RULE_TABSPACE_DEFAULT            = 2;

  // ˫Ŀ�����ǰ��Ĭ�Ͽո���
  CN_RULE_SPACE_BEFORE_OPERATOR       = 1;

  // ˫Ŀ��������Ĭ�Ͽո���
  CN_RULE_SPACE_AFTER_OPERATOR        = 1;

  // ���ָ������Ĭ������
  CN_RULE_SPACE_BEFORE_ASM            = 8;

  // ���ָ�� Tab ���
  CN_RULE_SPACE_TAB_ASM               = 8;

  // Ĭ�ϻ��г����˿��
  CN_RULE_LINE_WRAP_WIDTH             = 80;

  // Ĭ�ϸ߼����г����˿��
  CN_RULE_LINE_WRAP_NEWLINE_WIDTH     = 100;

  // ���ⲿָ������ʼԪ������
  CN_START_UNKNOWN_ALL                = 0;
  CN_START_USES                       = 1;
  CN_START_CONST                      = 2;
  CN_START_TYPE                       = 3;
  CN_START_VAR                        = 4;
  CN_START_PROC                       = 5;
  CN_START_STATEMENT                  = 6;

  // ������
  CN_ERRCODE_OK                       = 0;
  CN_ERRCODE_START                    = 1;

  CN_ERRCODE_PASCAL_IDENT_EXP         = 1;
  CN_ERRCODE_PASCAL_STRING_EXP        = 2;
  CN_ERRCODE_PASCAL_NUMBER_EXP        = 3;
  CN_ERRCODE_PASCAL_CHAR_EXP          = 4;
  CN_ERRCODE_PASCAL_SYMBOL_EXP        = 5;
  CN_ERRCODE_PASCAL_PARSE_ERR         = 6;
  CN_ERRCODE_PASCAL_INVALID_BIN       = 7;
  CN_ERRCODE_PASCAL_INVALID_STRING    = 8;
  CN_ERRCODE_PASCAL_INVALID_BOOKMARK  = 9;
  CN_ERRCODE_PASCAL_LINE_TOOLONG      = 10;
  CN_ERRCODE_PASCAL_ENDCOMMENT_EXP    = 11;
  CN_ERRCODE_PASCAL_NOT_SUPPORT       = 12;

  CN_ERRCODE_PASCAL_ERROR_DIRECTIVE   = 13;
  CN_ERRCODE_PASCAL_NO_METHODHEADING  = 14;
  CN_ERRCODE_PASCAL_NO_STRUCTTYPE     = 15;
  CN_ERRCODE_PASCAL_NO_TYPEDCONSTANT  = 16;
  CN_ERRCODE_PASCAL_NO_EQUALCOLON     = 17;
  CN_ERRCODE_PASCAL_NO_DECLSECTION    = 18;
  CN_ERRCODE_PASCAL_NO_PROCFUNC       = 19;
  CN_ERRCODE_PASCAL_UNKNOWN_GOAL      = 20;
  CN_ERRCODE_PASCAL_ERROR_INTERFACE   = 21;
  CN_ERRCODE_PASCAL_INVALID_STATEMENT = 22;

  CN_ERRCODE_END                      = 22;

type
  ICnPascalFormatterIntf = interface
    ['{0CC0F874-227A-4516-9D17-6331EA86CBCA}']
    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD;
      BeginStyle: DWORD; WrapMode: DWORD; TabSpace: DWORD; SpaceBeforeOperator: DWORD;
      SpaceAfterOperator: DWORD; SpaceBeforeAsm: DWORD; SpaceTabAsm: DWORD;
      LineWrapWidth: DWORD; NewLineWrapWidth: DWORD; UsesSingleLine: LongBool;
      UseIgnoreArea: LongBool; UsesLineWrapWidth: DWORD; KeepUserLineBreak: LongBool);
    {* ���ø�ʽ��ѡ��}

    procedure SetPreIdentifierNames(Names: PLPSTR);
    {* ����Ԥ�����úõı�ʶ������������Сд�ã�ע����ָ���ڴ������ڸ�ʽ����Ϻ����ͷ�}

    procedure SetInputLineMarks(Marks: PDWORD);
    {* ����Դ�ļ���������ӳ���ϵ�е�Դ�У���������ǩ���ϵ��ʹ�á�
       ��һ�� DWORD ����ķ�ʽ���ݣ�0 ��β������� nil ��ʾ������}

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* ��ʽ��һ���� Pascal �ļ����ݣ������� AnsiString ��ʽ���롣
       ���ؽ���洢�� AnsiString �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function FormatOnePascalUnitUtf8(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* ��ʽ��һ���� Pascal �ļ����ݣ������� UTF8String ��ʽ���롣
       ���ؽ���洢�� Utf8String �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function FormatOnePascalUnitW(Input: PWideChar; Len: DWORD): PWideChar;
    {* ��ʽ��һ���� Pascal �ļ����ݣ������� UnicodeString ��ʽ���롣Len �ַ�����
       ���ؽ���洢�� UnicodeString �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function FormatPascalBlock(Input: PAnsiChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PAnsiChar;
    {* ��ʽ��һ����飬�������� Pascal �ļ������� AnsiString ��ʽ���롣
       StartOffset �� EndOffset �Ǵ�����������ļ��е�ƫ�������� IDE �е�ѡ����ֱ�ӻ�á�
       �� Copy ������ Input �л�ô� StartOffset �� EndOffset ����������Ӧѡ���������ݡ�
       ���ؽ���洢�� AnsiString �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function FormatPascalBlockUtf8(Input: PAnsiChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PAnsiChar;
    {* ��ʽ��һ����飬���� Pascal �ļ������� UTF8String ��ʽ���롣
       StartOffset �� EndOffset �Ǵ�����������ļ��е� UTF8 ƫ�������� IDE �е�ѡ����ֱ�ӻ�á�
       �� Copy ������ Input �л�ô� StartOffset �� EndOffset ����������Ӧѡ������ Utf8���ݡ�
       ���ؽ���洢�� Utf8String �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function FormatPascalBlockW(Input: PWideChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PWideChar;
    {* ��ʽ��һ����飬���� Pascal �ļ������� UnicodeString ��ʽ���롣Len �ַ�����
       StartOffset �� EndOffset �Ǵ�����������ļ��е� Unicode �ַ�ƫ������
       ���ɴ� IDE �е�ѡ����ֱ�ӻ�ã���Ҫ����һ�� Utf8 ת������ܴ��롣
       �� Copy ������ Input �л�ô� StartOffset �� EndOffset ����������Ӧѡ������ Unicode ���ݡ�
       ���ؽ���洢�� UnicodeString �ַ����ݵ�ָ�룬����������ͷš�
       ������� nil��˵��������Ҫ�� RetrieveLastError ��ô�����}

    function RetrieveOutputLinkMarks: PDWORD;
    {* ��ȡԴ�ļ���������ӳ���ϵ�е�Ŀ���У�����ʽ����Ϻ�����ǩ���ϵ��ʹ�á�
       ��һ�� DWORD ����ָ��ķ�ʽ���ݣ�0 ��β�������߲����ͷŴ������ڴ�}

    function RetrievePascalLastError(out SourceLine: Integer; out SourceCol: Integer;
      out SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
    {* ��ȡ�������Լ�����ʱ�Ĵ������������������ƫ���Լ���������ʱ�ĵ�ǰ Token��
       CurrentToken ����Ӧ���Ƴ���ʹ�ã������ͷ�}
  end;

  TCnGetFormatterProvider = function: ICnPascalFormatterIntf; stdcall;
  {* DLL ������ĺ�������}

implementation

end.
