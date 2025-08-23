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
* ��    ע���õ�Ԫ�����ڱ༭���в����ַ������� Ansi/Utf8/Unicode ���֡�
* ����ƽ̨��Win7 + Delphi 5.01
* ���ݲ��ԣ�Win7 + D5/2007/2009
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.04.21 V1.0
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
    FIdEditControlDump: Integer;
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
end;

function TCnTestEditControlWrapperWizard.GetCaption: string;
begin
  Result := 'Test EditControlWrapper';
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
end;

procedure TCnTestEditControlWrapperWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditControlWrapperWizard); // ע��ר��

end.
