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

unit CnTestParseTimeWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�������ʱ����ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�ǽ�����ʱ����ר�ҵĲ��Ե�Ԫ�����Ա�����TObject.Create ��
*           D2010 ���԰��µĺ�ʱʮ���� D5/D7 ����ǰ�汾�����������ڴ����������
*           ���������ڣ���ֻ���� IDE �ڲ��������� exe �վɡ�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2009.06.06 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, CnPasCodeParser, mPasLex, Contnrs, TypInfo,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper, mwBCBTokenList;

type

  TCnTestToken = class(TPersistent)
  {* ����һ Token �Ľṹ������Ϣ}
  private

  protected
    FCppTokenKind: TCTokenKind;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    // FToken: AnsiString;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  published
    property UseAsC: Boolean read FUseAsC;
    {* �Ƿ��� C ��ʽ�Ľ�����Ĭ�ϲ���}
    property CharIndex: Integer read FCharIndex; // Start 0
    {* �ӱ��п�ʼ�����ַ�λ�ã����㿪ʼ }
    property EditCol: Integer read FEditCol write FEditCol;
    {* �����У���һ��ʼ }
    property EditLine: Integer read FEditLine write FEditLine;
    {* �����У���һ��ʼ }
    property ItemIndex: Integer read FItemIndex;
    {* ������ Parser �е���� }
    property ItemLayer: Integer read FItemLayer;
    {* ���ڸ����Ĳ�� }
    property LineNumber: Integer read FLineNumber; // Start 0
    {* �����кţ����㿪ʼ }
    property MethodLayer: Integer read FMethodLayer;
    {* ���ں�����Ƕ�ײ�Σ������Ϊһ }
    // property Token: AnsiString read FToken;
    {* �� Token ���ַ������� }
    property TokenID: TTokenKind read FTokenID;
    {* Token ���﷨���� }
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    {* ��Ϊ C �� Token ʹ��ʱ�� CToken ����}
    property TokenPos: Integer read FTokenPos;
    {* Token �������ļ��е�����λ�� }
    property IsBlockStart: Boolean read FIsBlockStart;
    {* �Ƿ���һ���ƥ���������Ŀ�ʼ }
    property IsBlockClose: Boolean read FIsBlockClose;
    {* �Ƿ���һ���ƥ���������Ľ��� }
    property IsMethodStart: Boolean read FIsMethodStart;
    {* �Ƿ��Ǻ������̵Ŀ�ʼ }
    property IsMethodClose: Boolean read FIsMethodClose;
    {* �Ƿ��Ǻ������̵Ľ��� }
  end;

  PCnTestRecord = ^TCnTestRecord;
  TCnTestRecord = packed record
    FCppTokenKind: TCTokenKind;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: AnsiString;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  end;

//==============================================================================
// ������ʱ�����ò˵�ר��
//==============================================================================

{ TCnTestParseTimeWizard }

  TCnTestParseTimeWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    destructor Destroy; override;
  end;

implementation

//==============================================================================
// ������ʱ�����ò˵�ר��
//==============================================================================

{ TCnSampleMenuWizard }

procedure TCnTestParseTimeWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

destructor TCnTestParseTimeWizard.Destroy;
begin

  inherited;
end;

procedure TCnTestParseTimeWizard.Execute;
var
  Tick: Cardinal;
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  Parser: TCnPasStructureParser;
  I: Integer;
  List: TList;
  P: PCnTestRecord;
  AControl: TControl;
  Str: AnsiString;
  WStr: string;
begin
  Stream := TMemoryStream.Create;
  Parser := TCnPasStructureParser.Create;
  try
    EditView := CnOtaGetTopMostEditView;
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // ������ǰ��ʾ��Դ�ļ�������ʱ��
    Tick := GetTickCount;
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), True);
    Tick := GetTickCount - Tick;
  finally
    Parser.Free;
    Stream.Free;
  end;

  ShowMessage('Parse Time: ' + IntToStr(Tick));

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TCnPasToken.Create);

  Tick := GetTickCount - Tick;

  ShowMessage('Create TCnPasToken 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TCnTestToken.Create);
  Tick := GetTickCount - Tick;

  ShowMessage('Create TCnTestToken 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TObject.Create);
  Tick := GetTickCount - Tick;

  ShowMessage('Create TObject 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TList.Create;
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
  begin
    New(P);
    List.Add(P);
  end;
  Tick := GetTickCount - Tick;

  ShowMessage('New PCnTestRecord 100000 Time: ' + IntToStr(Tick));
  for I := 0 to 100000 - 1 do
    Dispose(List[I]);
  List.Free;

  Tick := GetTickCount;
  for I := 0 to 10000 - 1 do
  begin
    AControl := CnOtaGetCurrentEditControl;
    if AControl <> nil then
    begin
      Str := AnsiString(GetStrProp(AControl, 'LineText'));
      if Str = '' then
        Exit;
    end;
  end;
  Tick := GetTickCount - Tick;
  ShowMessage('AnsiString(GetStrProp(AControl, LineText)) 100000 Time: ' + IntToStr(Tick));

 {$IFDEF UNICODE}
  Tick := GetTickCount;
  for I := 0 to 10000 - 1 do
  begin
    AControl := CnOtaGetCurrentEditControl;
    if AControl <> nil then
    begin
      WStr := GetStrProp(AControl, 'LineText');
      if WStr = '' then
        Exit;
    end;
  end;
  Tick := GetTickCount - Tick;
  ShowMessage('Unicode GetStrProp(AControl, LineText) 100000 Time: ' + IntToStr(Tick));
 {$ENDIF}
end;

function TCnTestParseTimeWizard.GetCaption: string;
begin
  Result := 'Test Parse Time';
  { TODO -oAnyone : ����ר�Ҳ˵��ı��⣬�ַ�������б��ػ����� }
end;

function TCnTestParseTimeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : ����Ĭ�ϵĿ�ݼ� }
end;

function TCnTestParseTimeWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : ����ר���Ƿ������ô��� }
end;

function TCnTestParseTimeWizard.GetHint: string;
begin
  Result := 'Test Parse Time of Current Unit';
  { TODO -oAnyone : ����ר�Ҳ˵���ʾ��Ϣ���ַ�������б��ػ����� }
end;

function TCnTestParseTimeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : ����ר�Ҳ˵�״̬���ɸ���ָ���������趨 }
end;

class procedure TCnTestParseTimeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'CnTestParseTimeWizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Parse Time Wizard';
  { TODO -oAnyone : ����ר�ҵ����ơ����ߡ����估��ע���ַ�������б��ػ����� }
end;

procedure TCnTestParseTimeWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ�װ��ר���ڲ��õ��Ĳ�����ר�Ҵ���ʱ�Զ������� }
end;

procedure TCnTestParseTimeWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ˱���ר���ڲ��õ��Ĳ�����ר���ͷ�ʱ�Զ������� }
end;

initialization
  RegisterCnWizard(TCnTestParseTimeWizard); // ע��ר��

end.
