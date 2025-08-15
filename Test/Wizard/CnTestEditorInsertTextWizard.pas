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

unit CnTestEditorInsertTextWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ա༭���в����ַ������Ӳ˵�ר�Ҳ��Ե�Ԫ
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
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// ���Ա༭�������ı����Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorInsertTextWizard }

  TCnTestEditorInsertTextWizard = class(TCnSubMenuWizard)
  private
    FIdInsertTextIntoEditor: Integer;
    FIdInsertLineIntoEditor: Integer;
    FIdReplaceCurrentSelection: Integer;
    FIdInsertTextToCurSource: Integer;
    FIdInsertMoreTexts: Integer;
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

implementation

//==============================================================================
// ���Ա༭�������ı����Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorInsertTextWizard }

procedure TCnTestEditorInsertTextWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditorInsertTextWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditorInsertTextWizard.AcquireSubActions;
begin
  FIdInsertTextIntoEditor := RegisterASubAction('CnOtaInsertTextIntoEditor',
    'Test CnOtaInsertTextIntoEditor', 0, 'Test CnOtaInsertTextIntoEditor',
    'CnOtaInsertTextIntoEditor');
  FIdInsertLineIntoEditor := RegisterASubAction('CnOtaInsertLineIntoEditor',
    'Test CnOtaInsertLineIntoEditor', 0, 'Test CnOtaInsertLineIntoEditor',
    'CnOtaInsertLineIntoEditor');
  FIdReplaceCurrentSelection := RegisterASubAction('CnOtaReplaceCurrentSelection',
    'Test CnOtaReplaceCurrentSelection', 0, 'Test CnOtaReplaceCurrentSelection',
    'CnOtaReplaceCurrentSelection');
  FIdInsertTextToCurSource := RegisterASubAction('CnOtaInsertTextToCurSource',
    'Test CnOtaInsertTextToCurSource', 0, 'Test CnOtaInsertTextToCurSource',
    'CnOtaInsertTextToCurSource');
  FIdInsertMoreTexts := RegisterASubAction('CnOtaInsertMoreTexts',
    'Test Insert More Texts', 0, 'Test Insert More Texts', 'CnOtaInsertMoreTexts');
end;

function TCnTestEditorInsertTextWizard.GetCaption: string;
begin
  Result := 'Test Editor Insert Text';
end;

function TCnTestEditorInsertTextWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorInsertTextWizard.GetHint: string;
begin
  Result := 'Test Editor InsertText';
end;

function TCnTestEditorInsertTextWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorInsertTextWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Insert Text Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor Insert Text Wizard';
end;

procedure TCnTestEditorInsertTextWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorInsertTextWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorInsertTextWizard.SubActionExecute(Index: Integer);
var
  S: string;
  APos: TOTAEditPos;
begin
  if not Active then Exit;

  if Index = FIdInsertTextIntoEditor then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{�Է�˯��}');
    CnOtaInsertTextIntoEditor(S); // Using EditWriter.Insert
  end
  else if Index = FIdInsertLineIntoEditor then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{�Է�˯��}');
    CnOtaInsertLineIntoEditor(S); // Using EditPosition.Insert
  end
  else if Index = FIdReplaceCurrentSelection then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{�Է�˯��}');
    CnOtaReplaceCurrentSelection(S, True, True);
  end
  else if Index = FIdInsertTextToCurSource then
  begin
    S := CnInputBox('Enter Text', 'Enter Text:', '{�Է�˯��}');
    APos.Line := 27; APos.Col := 31;
    CnOtaGetTopMostEditView.CursorPos := APos;
    CnOtaInsertTextToCurSource(S);
  end
  else if Index = FIdInsertMoreTexts then
  begin
    S := '��200';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
    S := '������ʾһ��';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
    S := '�ַ�' + #13#10 + '  end';
    CnOtaInsertTextIntoEditor(S);
    Sleep(0);
  end;
end;

procedure TCnTestEditorInsertTextWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditorInsertTextWizard); // ע��ר��

end.
