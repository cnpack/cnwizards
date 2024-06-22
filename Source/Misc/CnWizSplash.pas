{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnWizSplash;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 封面窗口处理单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 开发平台：WinXpPro + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2007.03.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CnWizManager, {$IFNDEF CNWIZARDS_MINIMUM} CnWizUtils, {$ENDIF}
  CnWizConsts;

procedure CnWizInitSplash;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CnSplashScreenFormName = 'SplashScreen';

procedure CnWizInitSplash;
var
  I: Integer;
  SplashForm: TCustomForm;
  pnlCnWiz: TPanel;
  imgCnWiz: TImage;
begin
  SplashForm := nil;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if Screen.CustomForms[I].Name = CnSplashScreenFormName then
    begin
      SplashForm := Screen.CustomForms[I];
      Break;
    end;
  end;

  if SplashForm <> nil then
  begin
    //pnlCnWiz
    pnlCnWiz := TPanel.Create(SplashForm);

    //imgCnWiz
    imgCnWiz := TImage.Create(SplashForm);

    //pnlCnWiz
    pnlCnWiz.Name := 'pnlCnWiz';
    pnlCnWiz.Visible := False;
    pnlCnWiz.Parent := SplashForm;
    pnlCnWiz.Caption := '';
    pnlCnWiz.Width := 32;
    pnlCnWiz.Height := 32;
    pnlCnWiz.Left := SplashForm.Width - pnlCnWiz.Width - 16;
    pnlCnWiz.Top := 16;
    pnlCnWiz.BevelOuter := bvNone;

    //imgCnWiz
    imgCnWiz.Name := 'imgCnWiz';
    imgCnWiz.Visible := False;
    imgCnWiz.Parent := pnlCnWiz;
    imgCnWiz.Align := alClient;

{$IFDEF CNWIZARDS_MINIMUM}
    // Draw Pure Color or Text to avoid Load Icon
{$ELSE}
    CnWizLoadBitmap(imgCnWiz.Picture.Bitmap, SCnAboutBmp);
{$ENDIF}
    if not imgCnWiz.Picture.Bitmap.Empty then
    begin
//      没啥用处    
//      imgCnWiz.ShowHint := True;
//      imgCnWiz.Hint := Format('%s %s.%s Build %s', ['CnPack IDE Wizards',
//        SCnWizardMajorVersion, SCnWizardMinorVersion, SCnWizardBuildDate]);
      pnlCnWiz.Visible := True;
      imgCnWiz.Visible := True;
      pnlCnWiz.BringToFront;
      SplashForm.Update;
    end;
  end;
end;

initialization
{$IFNDEF BDS}
  @InitSplashProc := @CnWizInitSplash;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizSplash.');
{$ENDIF}

end.
