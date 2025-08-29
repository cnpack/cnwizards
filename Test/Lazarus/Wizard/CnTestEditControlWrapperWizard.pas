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

unit CnTestEditControlWrapperWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����� EditControlWrapper ���Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ���� Lazarus �е� EditControlWrapper��
* ����ƽ̨��Win7 + Lazarus 4
* ���ݲ��ԣ�Win7 + Lazarus 4
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.08.23 V1.0
*               ������Ԫ
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
// ���� EditControlWrapper ���Ӳ˵�ר��
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
// ���� EditControlWrapper ���Ӳ˵�ר��
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
  RegisterCnWizard(TCnTestEditControlWrapperWizard); // ע��ר��

end.
