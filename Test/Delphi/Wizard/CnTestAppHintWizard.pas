{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnTestAppHintWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestAppHintWizard
* 单元作者：CnPack 开发组
* 备    注：能够在 D567 的 Hint 上显示一个小红块
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2018.07.28 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizNotifier, CnWizClasses, CnWizUtils, CnWizConsts,
  CnWizMethodHook, CnWizCompilerConst;

type

//==============================================================================
// CnTestAppHintWizard 菜单专家
//==============================================================================

{ TCnTestAppHintWizard }

  TCnTestAppHintWizard = class(TCnMenuWizard)
  private
    FCorIdeModule: HMODULE;
  protected
    function GetHasConfig: Boolean; override;
    procedure AppEvent(EventType: TCnWizAppEventType; Data: Pointer);
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

type
  TControlAccess = class(TControl);
  THintWindowAccess = class(THintWindow);

var
  FCalcHintRectHook: TCnMethodHook;
  FPaintHook: TCnMethodHook;

function MyHintWindowCalcHintRect(Self: TObject; MaxWidth: Integer;
  const AHint: string; AData: Pointer): TRect;
begin
  try
    FCalcHintRectHook.UnhookMethod;

    Result := THintWindow(Self).CalcHintRect(MaxWidth, AHint, AData);
    Result.Right := Result.Right + Result.Bottom - Result.Top;
    CnDebugger.LogMsg('MyHintWindowCalcHintRect: Add Width ' + IntToStr(Result.Bottom - Result.Top));
  finally
    FCalcHintRectHook.HookMethod;
  end;
end;

procedure MyHintWindowPaint(Self: TObject);
var
  R: TRect;
  H: THintWindowAccess;
  OldColor: TColor;
  OldStyle: TBrushStyle;
begin
  try
    FPaintHook.UnhookMethod;
    H := THintWindowAccess(Self);
    H.Paint;

    R.Top := H.ClientHeight div 3;
    R.Bottom := R.Top * 2 + 1;
    R.Left := H.ClientWidth - R.Top * 2;
    R.Right := R.Left + R.Top + 1;

    OldColor := H.Canvas.Brush.Color;
    OldStyle := H.Canvas.Brush.Style;

    H.Canvas.Brush.Style := bsSolid;
    H.Canvas.Brush.Color := clRed;
    H.Canvas.FillRect(R);

    H.Canvas.Brush.Color := OldColor;
    H.Canvas.Brush.Style := OldStyle;
    CnDebugger.LogMsg('MyHintWindowPaint');
  finally
    FPaintHook.HookMethod;
  end;
end;

//==============================================================================
// CnTestAppHintWizard 菜单专家
//==============================================================================

{ TCnTestAppHintWizard }

procedure TCnTestAppHintWizard.AppEvent(EventType: TCnWizAppEventType; Data: Pointer);
var
  H: PHintInfo;
begin
  if EventType = aeHint then
  begin
    CnDebugger.LogMsg('App Set Hint: ' + Application.Hint);
  end
  else if EventType = aeShowHint then
  begin
    H := PHintInfo(Data);
    if (H <> nil) and (H^.HintControl <> nil) then
      CnDebugger.LogMsg('App Show HintInfo on ' + H^.HintControl.Name + ' : ' + H^.HintStr)
    else
      CnDebugger.LogMsg('App Show Hint: ' + Application.Hint);
  end;
end;

procedure TCnTestAppHintWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestAppHintWizard.Create;
begin
  inherited;
  CnWizNotifierServices.AddAppEventNotifier(AppEvent);
end;

destructor TCnTestAppHintWizard.Destroy;
begin
  CnWizNotifierServices.RemoveAppEventNotifier(AppEvent);
  FreeAndNil(FCalcHintRectHook);
  FreeAndNil(FPaintHook);
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
  inherited;
end;

procedure TCnTestAppHintWizard.Execute;
begin
  if FCorIdeModule = 0 then
  begin
    FCorIdeModule := LoadLibrary(CorIdeLibName);
    CnWizAssert(FCorIdeModule <> 0, 'Failed to load FCorIdeModule');

    FCalcHintRectHook := TCnMethodHook.Create(GetBplMethodAddress(@THintWindow.CalcHintRect), @MyHintWindowCalcHintRect);
    FPaintHook := TCnMethodHook.Create(GetBplMethodAddress(@THintWindowAccess.Paint), @MyHintWindowPaint);
  end;
  ShowMessage(HintWindowClass.ClassName);
end;

function TCnTestAppHintWizard.GetCaption: string;
begin
  Result := 'Test Application Hint';
end;

function TCnTestAppHintWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestAppHintWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestAppHintWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestAppHintWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestAppHintWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Application Hint Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Application Hint';
end;

procedure TCnTestAppHintWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestAppHintWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestAppHintWizard); // 注册此测试专家

end.
