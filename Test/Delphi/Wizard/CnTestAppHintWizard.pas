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

unit CnTestAppHintWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestAppHintWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ܹ��� D567 �� Hint ����ʾһ��С���
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2018.07.28 V1.0
*               ������Ԫ
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
// CnTestAppHintWizard �˵�ר��
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
// CnTestAppHintWizard �˵�ר��
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
  RegisterCnWizard(TCnTestAppHintWizard); // ע��˲���ר��

end.
