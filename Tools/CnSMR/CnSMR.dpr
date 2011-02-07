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

program CnSMR;

uses
  Forms,
  CnMainUnit in 'CnMainUnit.pas' {CnSMRMainForm},
  CnEditARFUnit in 'CnEditARFUnit.pas' {CnEditARFForm},
  CnSMRBplUtils in 'CnSMRBplUtils.pas',
  CnBaseUtils in 'CnBaseUtils.pas',
  CnViewARFUnit in 'CnViewARFUnit.pas' {CnViewARFForm},
  CnViewSMRUnit in 'CnViewSMRUnit.pas' {CnViewSMRForm},
  CnEditSMRUnit in 'CnEditSMRUnit.pas' {CnEditSMRForm},
  CnSMRUtils in 'CnSMRUtils.pas',
  CnAboutUnit in 'CnAboutUnit.pas' {CnAboutForm},
  CnBuffStr in 'CnBuffStr.pas',
  CnSelectMaskFrm in 'CnSelectMaskFrm.pas' {CnSelectMaskForm},
  CnTextPreviewFrm in 'CnTextPreviewFrm.pas' {CnTextPreviewForm},
  CnDirListFrm in 'CnDirListFrm.pas' {CnDirListForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCnSMRMainForm, CnSMRMainForm);
  Application.CreateForm(TCnDirListForm, CnDirListForm);
  Application.Run;
end.
