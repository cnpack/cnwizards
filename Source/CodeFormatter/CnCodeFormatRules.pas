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

unit CnCodeFormatRules;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ�ִ����ʽ������
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* �޸ļ�¼��2003.12.16 V0.1
*               ������Ŀǰ���� �����ո�����������ǰ��ո������ؼ��ִ�Сд �����á�
                ������δʵ�֡�
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, TypInfo;

type
  TCnCodeStyle = (fsNone);

  TCnCodeStyles = set of TCnCodeStyle;

  TCnKeywordStyle = (ksLowerCaseKeyword, ksUpperCaseKeyword, ksPascalKeyword, ksNoChange);

  TCnBeginStyle = (bsNextLine, bsSameLine);

  TCnElseAfterEndStyle = (eaeNextLine, eaeSameLine);

  TCnCodeWrapMode = (cwmNone, cwmSimple, cwmAdvanced);
  {* ���뻻�е����ã����Զ����С��򵥵ĳ����ͻ��У��߼��ĳ������˲Ŵ��ٵĵط�����}

  TCnTypeIDStyle = (tisUpperFirst, tisNoChange); // ���ͱ�ʶ���Ĵ���ʽ������ĸ��д�򲻱�

  TCnCompDirectiveMode = (cdmAsComment, cdmOnlyFirst, cdmNone); // None ��ʾ�Ӹ����洦��

  TCnPascalCodeFormatRule = record
    ContinueAfterError: Boolean;
    CodeStyle: TCnCodeStyles;

    CompDirectiveMode: TCnCompDirectiveMode;
    KeywordStyle: TCnKeywordStyle;
    BeginStyle: TCnBeginStyle;
    ElseAfterEndStyle: TCnElseAfterEndStyle;
    CodeWrapMode: TCnCodeWrapMode;
    TypeIDStyle: TCnTypeIDStyle;    // �����޷������ʶ���ڵķִʣ����岻���ݲ����⿪��
    TabSpaceCount: Byte;
    SpaceBeforeOperator: Byte;
    SpaceAfterOperator: Byte;
    SpaceBeforeASM: Byte;
    SpaceTabASMKeyword: Byte;
    WrapWidth: Integer;
    WrapNewLineWidth: Integer;
    UsesUnitSingleLine: Boolean;
    SingleStatementToBlock: Boolean; // if while for case �ȵ�������Ƿ�� begin end��Ҳ�ݲ����⿪��
    UseIgnoreArea: Boolean;
    UsesLineWrapWidth: Integer;
    KeepUserLineBreak: Boolean;
  end;

const
  CnPascalCodeForVCLRule: TCnPascalCodeFormatRule =
  (
    ContinueAfterError: False;
    CodeStyle: [];

    CompDirectiveMode: cdmAsComment;
    KeywordStyle: ksLowerCaseKeyword;
    BeginStyle: bsNextLine;
    ElseAfterEndStyle: eaeNextLine;
    CodeWrapMode: cwmNone;
    TypeIDStyle: tisNoChange;
    TabSpaceCount: 2;
    SpaceBeforeOperator: 1;
    SpaceAfterOperator: 1;
    SpaceBeforeASM: 8;
    SpaceTabASMKeyword: 8;
    WrapWidth: 80;
    WrapNewLineWidth: 90;
    UsesUnitSingleLine: False;
    SingleStatementToBlock: False;
    UseIgnoreArea: True;
    UsesLineWrapWidth: 90;
    KeepUserLineBreak: False;
  );

function PascalCodeRuleToString(var Rule: TCnPascalCodeFormatRule): string;

var
  CnPascalCodeForRule: TCnPascalCodeFormatRule;

implementation

function PascalCodeRuleToString(var Rule: TCnPascalCodeFormatRule): string;
const
  sLineBreak = #13#10;
var
  S: string;

  function MyBooleanToStr(Value: Boolean): string;
  begin
    if Value then
      Result := 'True'
    else
      Result := 'False';
  end;
begin
  S := 'TCnPascalCodeFormatRule:' + sLineBreak;
  S := S + '  ContinueAfterError: ' + MyBooleanToStr(Rule.ContinueAfterError) + sLineBreak;
  S := S + '  CodeStyle: ' + '[Set of TCnCodeStyle]' + sLineBreak;  // Set ������ʱ�򻯴���
  S := S + '  CompDirectiveMode: ' + GetEnumName(TypeInfo(TCnCompDirectiveMode), Ord(Rule.CompDirectiveMode)) + sLineBreak;
  S := S + '  KeywordStyle: ' + GetEnumName(TypeInfo(TCnKeywordStyle), Ord(Rule.KeywordStyle)) + sLineBreak;
  S := S + '  BeginStyle: ' + GetEnumName(TypeInfo(TCnBeginStyle), Ord(Rule.BeginStyle)) + sLineBreak;
  S := S + '  ElseAfterEndStyle: ' + GetEnumName(TypeInfo(TCnElseAfterEndStyle), Ord(Rule.ElseAfterEndStyle)) + sLineBreak;
  S := S + '  CodeWrapMode: ' + GetEnumName(TypeInfo(TCnCodeWrapMode), Ord(Rule.CodeWrapMode)) + sLineBreak;
  S := S + '  TypeIDStyle: ' + GetEnumName(TypeInfo(TCnTypeIDStyle), Ord(Rule.TypeIDStyle)) + sLineBreak;
  S := S + '  TabSpaceCount: ' + IntToStr(Rule.TabSpaceCount) + sLineBreak;
  S := S + '  SpaceBeforeOperator: ' + IntToStr(Rule.SpaceBeforeOperator) + sLineBreak;
  S := S + '  SpaceAfterOperator: ' + IntToStr(Rule.SpaceAfterOperator) + sLineBreak;
  S := S + '  SpaceBeforeASM: ' + IntToStr(Rule.SpaceBeforeASM) + sLineBreak;
  S := S + '  SpaceTabASMKeyword: ' + IntToStr(Rule.SpaceTabASMKeyword) + sLineBreak;
  S := S + '  WrapWidth: ' + IntToStr(Rule.WrapWidth) + sLineBreak;
  S := S + '  WrapNewLineWidth: ' + IntToStr(Rule.WrapNewLineWidth) + sLineBreak;
  S := S + '  UsesUnitSingleLine: ' + MyBooleanToStr(Rule.UsesUnitSingleLine) + sLineBreak;
  S := S + '  SingleStatementToBlock: ' + MyBooleanToStr(Rule.SingleStatementToBlock) + sLineBreak;
  S := S + '  UseIgnoreArea: ' + MyBooleanToStr(Rule.UseIgnoreArea) + sLineBreak;
  S := S + '  UsesLineWrapWidth: ' + IntToStr(Rule.UsesLineWrapWidth) + sLineBreak;
  S := S + '  KeepUserLineBreak: ' + MyBooleanToStr(Rule.KeepUserLineBreak);
  Result := S;
end;

initialization
  // Default Setting
  CnPascalCodeForRule := CnPascalCodeForVCLRule;

end.
