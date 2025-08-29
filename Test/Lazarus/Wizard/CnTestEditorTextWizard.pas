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

unit CnTestEditorTextWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ա༭���в����ַ������Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ������ Lazarus �༭���в����ַ����������� Utf8��
* ����ƽ̨��Win7 + Lazarus 4
* ���ݲ��ԣ�Win7 + Lazarus 4
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.04.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf;

type

//==============================================================================
// ���Ա༭���ı���ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorTextWizard }

  TCnTestEditorTextWizard = class(TCnSubMenuWizard)
  private
    FIdEditorPosition: Integer;
    FIdEditorGetText: Integer;
    FIdEditorCurrentLine: Integer;
    FIdEditorSelection: Integer;
    FIdEditorInsertText: Integer;
    FIdEditorSaveStream: Integer;
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

uses
  CnDebug;

//==============================================================================
// ���Ա༭���ı���ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorTextWizard }

procedure TCnTestEditorTextWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditorTextWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditorTextWizard.AcquireSubActions;
begin
  FIdEditorPosition := RegisterASubAction('CnLazEditorPosition',
    'Test CnLazEditorPosition', 0, 'Test CnLazEditorPosition',
    'CnLazEditorPosition');
  FIdEditorGetText := RegisterASubAction('CnLazEditorGetText',
    'Test CnLazEditorGetText', 0, 'Test CnLazEditorGetText',
    'CnLazEditorGetText');
  FIdEditorCurrentLine := RegisterASubAction('CnLazEditorCurrentLine',
    'Test CnLazEditorCurrentLine', 0, 'Test CnLazEditorCurrentLine',
    'CnLazEditorCurrentLine');
  FIdEditorSelection := RegisterASubAction('CnLazEditorSelection',
    'Test CnLazEditorSelection', 0, ' Test CnLazEditorSelection',
    'CnLazEditorSelection');
  FIdEditorInsertText := RegisterASubAction('CnLazEditorInsertText',
    'Test CnLazEditorInsertText', 0, 'Test CnLazEditorInsertText',
    'CnLazEditorInsertText');
  FIdEditorSaveStream := RegisterASubAction('CnLazEditorSaveStream',
    'Test CnLazEditorSaveStream', 0, 'Test CnLazEditorSaveStream',
    'CnLazEditorSaveStream');
end;

function TCnTestEditorTextWizard.GetCaption: string;
begin
  Result := 'Test Editor Text';
end;

function TCnTestEditorTextWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorTextWizard.GetHint: string;
begin
  Result := 'Test Editor Text';
end;

function TCnTestEditorTextWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorTextWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Text Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor Text Wizard';
end;

procedure TCnTestEditorTextWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorTextWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorTextWizard.SubActionExecute(Index: Integer);
var
  S: string;
  P, P1: TPoint;
  S1, S2: Integer;
  Editor: TSourceEditorInterface;
  Stream: TMemoryStream;
begin
  if not Active then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Editor = nil then
  begin
    ErrorDlg('No Editor');
    Exit;
  end;

  if Index = FIdEditorPosition then
  begin
    P := Editor.CursorTextXY;
    ShowMessage(Format('Cursor Text Position Line/Col: %d/%d', [P.Y, P.X]));
  end
  else if Index = FIdEditorGetText then
  begin
    S := Editor.SourceText;
    CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorCurrentLine then
  begin
    S := Editor.CurrentLineText;
    CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorSelection then
  begin
    P := Editor.BlockBegin;
    P1 := Editor.BlockEnd;
    S1 := Editor.SelStart;
    S2 := Editor.SelEnd;
    ShowMessage(Format('Current Block is From %d/%d (%d) to %d/%d (%d)', [P.Y, P.X, S1, P1.Y, P1.X, S2]));

    if Editor.Selection <> '' then
      CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorInsertText then
  begin
    // ע�� S �������汾Դ�ļ�����仯���仯������� Utf8 ������ת������Ϊ Lazarus ��Ҫ Utf8
    S := 'a := ''�Է�˯��''' + #13#10 + 'b := ''A Cup of ����'';';
    CnDebugger.LogRawString(S);
    S := CnAnsiToUtf8(S);
    CnDebugger.LogRawString(S);
    // CnOtaInsertTextToCurSource(S, ipCur);
    P := Editor.CursorTextXY;
    Editor.ReplaceText(P, P, S);
  end
  else if Index = FIdEditorSaveStream then
  begin
    Stream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(nil, Stream);
      CnDebugger.LogMemDump(Stream.Memory, Stream.Size);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TCnTestEditorTextWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditorTextWizard); // ע��ר��

end.
