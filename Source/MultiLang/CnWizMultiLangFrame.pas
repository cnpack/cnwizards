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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizMultiLangFrame;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包多语控制单元 Frame 基类
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2024.03.16 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnLangMgr;

type
  TCnTranslateFrame = class(TFrame)
  {* 拥有翻译功能的 TFrame 类，可独立翻译，不依赖于放置的宿主}
  private

  protected
    procedure LanguageChanged(Sender: TObject);
    procedure Translate;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{ TCnTranslateFrame }

constructor TCnTranslateFrame.Create(AOwner: TComponent);
begin
  inherited;
  DisableAlign;
  try
    Translate;
  finally
    EnableAlign;
  end;
  CnLanguageManager.AddChangeNotifier(LanguageChanged);
end;

destructor TCnTranslateFrame.Destroy;
begin
  CnLanguageManager.RemoveChangeNotifier(LanguageChanged);
  inherited;
end;

procedure TCnTranslateFrame.LanguageChanged(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTranslateFrame.LanguageChanged');
{$ENDIF}
  DisableAlign;
  try
    CnLanguageManager.TranslateFrame(Self);
  finally
    EnableAlign;
  end;
end;

procedure TCnTranslateFrame.Translate;
begin
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    Screen.Cursor := crHourGlass;
    try
      CnLanguageManager.TranslateFrame(Self);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

end.
