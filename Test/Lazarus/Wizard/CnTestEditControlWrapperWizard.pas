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

unit CnTestEditControlWrapperWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试 EditControlWrapper 的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 中的 EditControlWrapper。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.08.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon,
  CnWideStrings, CnWizIdeUtils, SrcEditorIntf, StdCtrls;

type

  { TCnTestEditControlWrapperForm }

  TCnTestEditControlWrapperForm = class(TForm)
    MemoTest: TMemo;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

//==============================================================================
// 测试 EditControlWrapper 的子菜单专家
//==============================================================================

{ TCnTestEditControlWrapperWizard }

  TCnTestEditControlWrapperWizard = class(TCnSubMenuWizard)
  private
    FAdded: Boolean;
    FIdEditControlDump: Integer;
    FIdKeyNotifier: Integer;
    procedure OnKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure OnKeyUp(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure OnSysKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure OnSysKeyUp(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

var
  CnTestEditControlWrapperForm: TCnTestEditControlWrapperForm = nil;

implementation

{$R *.lfm}

uses
  CnDebug, CnEditControlWrapper;

{ TCnTestEditControlWrapperForm }

procedure TCnTestEditControlWrapperForm.Timer1Timer(Sender: TObject);
var
  I: Integer;
  E: TControl;
  O: TCnEditorObject;
begin
  with MemoTest.Lines do
  begin
    Clear;
    Add(Format('EditControl Count %d', [EditControlWrapper.EditControlCount]));
    for I := 0 to EditControlWrapper.EditControlCount - 1 do
    begin
      E := EditControlWrapper.EditControls[I];
      Add(Format('  #%d %s - %s', [I, E.ClassName, E.Name]));
    end;

    E := GetCurrentEditControl;
    if E = nil then
      Add('No Current EditControl')
    else
      Add('Current EditControl is ' + E.Name);

    Add('======================');
    Add(Format('EditorObject Count %d', [EditControlWrapper.EditorCount]));
    for I := 0 to EditControlWrapper.EditControlCount - 1 do
    begin
      O := EditControlWrapper.Editors[I];
      if O <> nil then
        Add(Format('  #%d %s owner %s', [I, O.ClassName, O.EditWindow.ClassName]))
      else
        Add('  #%d nil');
    end;
  end;
end;

//==============================================================================
// 测试 EditControlWrapper 的子菜单专家
//==============================================================================

{ TCnTestEditControlWrapperWizard }

procedure TCnTestEditControlWrapperWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditControlWrapperWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditControlWrapperWizard.AcquireSubActions;
begin
  FIdEditControlDump := RegisterASubAction('CnLazEditControlDump',
    'Test CnLazEditControlDump', 0, 'Test CnLazEditControlDump',
    'CnLazEditControlDump');
  FIdKeyNotifier := RegisterASubAction('CnLazEditControlKeyNotifier',
    'Test CnLazEditControlKeyNotifier', 0, 'Test CnLazEditControlKeyNotifier',
    'CnLazEditControlKeyNotifier');
end;

function TCnTestEditControlWrapperWizard.GetCaption: string;
begin
  Result := 'Test EditControlWrapper';
end;

procedure TCnTestEditControlWrapperWizard.OnKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  CnDebugger.TraceFmt('KeyDown %d ScanCode %d', [Key, ScanCode]);
end;

procedure TCnTestEditControlWrapperWizard.OnKeyUp(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  CnDebugger.TraceFmt('KeyUp %d ScanCode %d', [Key, ScanCode]);
end;

procedure TCnTestEditControlWrapperWizard.OnSysKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  CnDebugger.TraceFmt('SysKeyDown %d ScanCode %d', [Key, ScanCode]);
end;

procedure TCnTestEditControlWrapperWizard.OnSysKeyUp(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  CnDebugger.TraceFmt('SysKeyUp %d ScanCode %d', [Key, ScanCode]);
end;

function TCnTestEditControlWrapperWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditControlWrapperWizard.GetHint: string;
begin
  Result := 'Test EditControlWrapper';
end;

function TCnTestEditControlWrapperWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditControlWrapperWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControlWrapper Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test EditControlWrapper Wizard';
end;

procedure TCnTestEditControlWrapperWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditControlWrapperWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditControlWrapperWizard.SubActionExecute(Index: Integer);
begin
  if not Active then Exit;

  if Index = FIdEditControlDump then
  begin
    if CnTestEditControlWrapperForm = nil then
      CnTestEditControlWrapperForm := TCnTestEditControlWrapperForm.Create(Application);
    CnTestEditControlWrapperForm.Show;
  end
  else if Index = FIdKeyNotifier then
  begin
    if FAdded then
    begin
      EditControlWrapper.RemoveKeyDownNotifier(OnKeyDown);
      EditControlWrapper.RemoveKeyUpNotifier(OnKeyUp);
      EditControlWrapper.RemoveSysKeyDownNotifier(OnSysKeyDown);
      EditControlWrapper.RemoveSysKeyUpNotifier(OnSysKeyUp);
      FAdded := False;
      ShowMessage('Key Hook Removed');
    end
    else
    begin
      EditControlWrapper.AddKeyDownNotifier(OnKeyDown);
      EditControlWrapper.AddKeyUpNotifier(OnKeyUp);
      EditControlWrapper.AddSysKeyDownNotifier(OnSysKeyDown);
      EditControlWrapper.AddSysKeyUpNotifier(OnSysKeyUp);
      FAdded := True;
      ShowMessage('Key Hook Added');
    end;
  end;
end;

procedure TCnTestEditControlWrapperWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditControlWrapperWizard); // 注册专家

end.
