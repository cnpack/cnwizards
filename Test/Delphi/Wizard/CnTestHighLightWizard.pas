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

unit CnTestHighLightWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����������ֹ��ܲ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫʵ���˴���������ֹ��ܵĲ��ԣ���ʱֻ֧�ֵͰ汾�� Unicode��δ���� Unicode
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnPasCodeParser,
  mPasLex;

type

//==============================================================================
// ����ṹ�������Բ˵�ר��
//==============================================================================

{ TCnTestHighLightWizard }

  TCnTestHighLightWizard = class(TCnMenuWizard)
  private
    FParser: TCnPasStructureParser;
  protected
    function GetHasConfig: Boolean; override;
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

    property Parser: TCnPasStructureParser read FParser;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ����ṹ�������Բ˵�ר��
//==============================================================================

{ TCnTestHighLightWizard }

procedure TCnTestHighLightWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

constructor TCnTestHighLightWizard.Create;
begin
  inherited;
  FParser := TCnPasStructureParser.Create;
end;

destructor TCnTestHighLightWizard.Destroy;
begin
  FParser.Free;
  inherited;
end;

procedure TCnTestHighLightWizard.Execute;
{$IFNDEF UNICODE}
const
  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkRecord, tkClass,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase,
    tkRepeat, tkUntil];
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, Sum: Integer;
{$ENDIF}
begin
{$IFNDEF UNICODE}
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then Exit;

  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // ������ǰ��ʾ��Դ�ļ�
    Parser.ParseSource(PChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), True);
  finally
    Stream.Free;
  end;

  // �������ٲ��ҵ�ǰ������ڵĿ�
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

  CnDebugger.TraceFmt('CharPos.Line %d, CharPos.CharIndex %d.',
    [CharPos.Line, CharPos.CharIndex]);

  if Parser.Count > 0 then
  begin
    for I := 0 to Parser.Count - 1 do
    begin
      CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
      EditView.ConvertPos(False, EditPos, CharPos);
      Parser.Tokens[I].EditCol := EditPos.Col;
      Parser.Tokens[I].EditLine := EditPos.Line;
    end;
  end;

  Sum := 0;
  for I := 0 to Parser.Count - 1 do
  begin
    if Parser.Tokens[I].TokenID in csKeyTokens then
    begin
      // �������Ҫ�� Token ����Ϣ
      CnDebugger.TraceObject(Parser.Tokens[I]);
      Inc(Sum);
    end;
  end;
  CnDebugger.TraceInteger(Sum, 'All Tokens: ');

  CnDebugger.TraceObject(Parser.MethodStartToken);
  CnDebugger.TraceObject(Parser.MethodCloseToken);
  CnDebugger.TraceObject(Parser.BlockStartToken);
  CnDebugger.TraceObject(Parser.BlockCloseToken);
  CnDebugger.TraceObject(Parser.InnerBlockStartToken);
  CnDebugger.TraceObject(Parser.InnerBlockCloseToken);

  CnDebugger.TraceSeparator;
{$ENDIF}
end;

function TCnTestHighLightWizard.GetCaption: string;
begin
  Result := 'Test Highight';
  { TODO -oAnyone : ����ר�Ҳ˵��ı��⣬�ַ�������б��ػ����� }
end;

function TCnTestHighLightWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : ����Ĭ�ϵĿ�ݼ� }
end;

function TCnTestHighLightWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : ����ר���Ƿ������ô��� }
end;

function TCnTestHighLightWizard.GetHint: string;
begin
  Result := 'Test HighLight. Parse Current Pascal Source File.';
  { TODO -oAnyone : ����ר�Ҳ˵���ʾ��Ϣ���ַ�������б��ػ����� }
end;

function TCnTestHighLightWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : ����ר�Ҳ˵�״̬���ɸ���ָ���������趨 }
end;

class procedure TCnTestHighLightWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Highlight Structure';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test HighLight. Parse Current Pascal Source File.';
  { TODO -oAnyone : ����ר�ҵ����ơ����ߡ����估��ע���ַ�������б��ػ����� }
end;

procedure TCnTestHighLightWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ�װ��ר���ڲ��õ��Ĳ�����ר�Ҵ���ʱ�Զ������� }
end;

procedure TCnTestHighLightWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ˱���ר���ڲ��õ��Ĳ�����ר���ͷ�ʱ�Զ������� }
end;

initialization
  RegisterCnWizard(TCnTestHighLightWizard); // ע��ר��

end.
