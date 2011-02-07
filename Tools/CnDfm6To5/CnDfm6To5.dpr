{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program CnDfm6To5;

{$I CnPack.inc}

{$IFNDEF DELPHI5}
  'Error: This program can only be compiled in Delphi 5.0!'
{$ENDIF}

uses
  Forms,
  CnDTMainFrm in 'CnDTMainFrm.pas' {CnDTMainForm},
  CnWizDfm6To5 in '..\..\Source\Utils\CnWizDfm6To5.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'DFM 窗体转换工具';
  Application.CreateForm(TCnDTMainForm, CnDTMainForm);
  Application.Run;
end.
