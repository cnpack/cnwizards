{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program CnCodeFormatterTestPrj;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
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

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
