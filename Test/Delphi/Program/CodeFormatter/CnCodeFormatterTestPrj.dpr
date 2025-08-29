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

program CnCodeFormatterTestPrj;

uses
  Forms,
  CnCodeFormatterTest in 'CnCodeFormatterTest.pas' {MainForm},
  CnFormatterIntf in '..\..\..\..\Source\CodeFormatter\CnFormatterIntf.pas',
  CnScanners in '..\..\..\..\Source\CodeFormatter\CnParser\CnScanners.pas',
  CnTokens in '..\..\..\..\Source\CodeFormatter\CnParser\CnTokens.pas',
  CnCodeFormatter in '..\..\..\..\Source\CodeFormatter\CnCodeFormatter.pas',
  CnParseConsts in '..\..\..\..\Source\CodeFormatter\CnParser\CnParseConsts.pas',
  CnCodeGenerators in '..\..\..\..\Source\CodeFormatter\CnParser\CnCodeGenerators.pas',
  CnCodeFormatRules in '..\..\..\..\Source\CodeFormatter\CnCodeFormatRules.pas',
  CnPascalGrammar in '..\..\..\..\Source\CodeFormatter\CnParser\CnPascalGrammar.pas',
  CnCompDirectiveTree in '..\..\..\..\Source\CodeFormatter\CnCompDirectiveTree.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
