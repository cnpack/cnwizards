{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2015 CnPack ������                       }
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

unit CnTestUnitListWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�TUnitNameList ����������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.03.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnInputSymbolList,
  CnPasCodeParser, CnCppCodeParser;

type

//==============================================================================
// ���� TUnitNameList ��ع��ܵĲ˵�ר��
//==============================================================================

{ TCnTestUnitListWizard }

  TCnTestUnitListWizard = class(TCnMenuWizard)
  private
    FList: TCnUnitNameList;
    function SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
      out CharPos: TOTACharPos): Boolean;
    function SearchCppInsertPos(IsH: Boolean; out CharPos: TOTACharPos): Boolean;
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
  end;

implementation

uses
  CnDebug, mPasLex, CnCommon, CnPasWideLex, mwBCBTokenList, CnBCBWideTokenList;

//==============================================================================
// ���� TUnitNameList ��ع��ܵĲ˵�ר��
//==============================================================================

{ TCnTestUnitListWizard }

procedure TCnTestUnitListWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestUnitListWizard.Create;
begin
  inherited;

end;

destructor TCnTestUnitListWizard.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnTestUnitListWizard.Execute;
var
  IsCppMode: Boolean;
  I, Idx: Integer;
  Stream: TMemoryStream;
  UsesList: TStringList;
  Names: TStringList;
  Paths: TStringList;
  HasUses: Boolean;
  CharPos: TOTACharPos;
  LinearPos: LongInt;
  EditView: IOTAEditView;

  function JoinInclude(IsSystem: Boolean; const IncFile: string): string;
  begin
    if IsSystem then
      Result := Format('#include <%s>' + #13#10, [IncFile])
    else
      Result := Format('#include "%s"' + #13#10, [IncFile]);
  end;

begin
  if CurrentIsDelphiSource then
  begin
    FList := TCnUnitNameList.Create(True, False, False);
    IsCppMode := False;
  end
  else if CurrentIsCSource then
  begin
    FList := TCnUnitNameList.Create(True, True, False);
    IsCppMode := True;
  end
  else
    Exit;

  Names := TStringList.Create;
  Paths := TStringList.Create;
  Stream := TMemoryStream.Create;
  UsesList := TStringList.Create;
  CnDebugger.LogMsg('TUnitNameList Created.');

  try
    FList.DoInternalLoad;
    FList.ExportToStringList(Names, Paths);

    ShowMessage('Found Units/Headers Count: ' + IntToStr(Names.Count));

    // ��ʱ�õ������п����õĵ�Ԫ�б�

    CnOtaSaveCurrentEditorToStream(Stream, False);
    if not IsCppMode then
      ParseUnitUses(PAnsiChar(Stream.Memory), UsesList)
    else
      ParseUnitIncludes(PAnsiChar(Stream.Memory), UsesList);

    for I := 0 to UsesList.Count - 1 do
    begin
      Idx := Names.IndexOf(UsesList[I]);
      if Idx >= 0 then
      begin
        CnDebugger.LogMsg('Remove Existing ' + UsesList[I]);
        Names.Delete(Idx);
        Paths.Delete(Idx);
      end;
    end;

    ShowMessage('Found Units/Headers not used: ' + IntToStr(Names.Count));
    for I := 0 to Names.Count - 1 do
      CnDebugger.LogFmt('%d. %s in %s', [Integer(Names.Objects[I]), Names[I], Paths[I]]);

    // ��ʱ�޳������õģ��õ��˿����õĵ�Ԫ�б�
    if Names.Count = 0 then
      Exit;
    EditView := CnOtaGetTopMostEditView;

    if IsCppMode then
    begin
      // ������ Cpp �ļ�ͷ�����һ�� include �����޾Ͳ���ͷ��
      if not SearchCppInsertPos(False, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for Cpp Include.');
        Exit;
      end;
    end
    else
    begin
      // ������ interface ���� uses�����ô����� uses �����
      if not SearchPasInsertPos(False, HasUses, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for implementation uses.');
        Exit;
      end;
    end;

    // �Ѿ��õ��� 1 �� 0 ��ʼ�� CharPos���� EditView.CharPosToPos(CharPos) ת��Ϊ����;
    LinearPos := EditView.CharPosToPos(CharPos);

    if IsCppMode then
    begin
      ShowMessage('Will insert #include ' + Names[0] + ' to Position ' + IntToStr(CharPos.Line) + ':' + IntToStr(CharPos.CharIndex));
      CnOtaInsertTextIntoEditorAtPos(JoinInclude(True, Names[0]), LinearPos);
    end
    else
    begin
      if HasUses then
      begin
        ShowMessage('Will insert ' + Names[0] + ' to Position ' + IntToStr(CharPos.Line) + ':' + IntToStr(CharPos.CharIndex));
        CnOtaInsertTextIntoEditorAtPos(', ' + Names[0], LinearPos);
      end
      else
      begin
        ShowMessage('Will insert uses ' + Names[0] + ' after implementation. Line ' + IntToStr(CharPos.Line));
        CnOtaInsertTextIntoEditorAtPos(#13#10#13#10 + 'uses' + #13#10 + '  ' + Names[0] + ';', LinearPos);
      end;
    end;

    if Names.Count = 1 then
      Exit;

    if IsCppMode then
    begin
      // ������ H �ļ�ͷ�����һ�� include �����޾Ͳ�ifdef def����������
      if not SearchCppInsertPos(True, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for Cpp Include.');
        Exit;
      end
    end
    else
    begin
      if not SearchPasInsertPos(True, HasUses, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for interface uses.');
        Exit;
      end;
    end;

    LinearPos := EditView.CharPosToPos(CharPos);
    if IsCppMode then
    begin
      ShowMessage('Will insert #include ' + Names[1] + ' to Position ' + IntToStr(CharPos.Line) + ':' + IntToStr(CharPos.CharIndex));
      CnOtaInsertTextIntoEditorAtPos(JoinInclude(False, Names[1]), LinearPos);
    end
    else
    begin
      if HasUses then
      begin
        ShowMessage('Will insert ' + Names[1] + ' to Position ' + IntToStr(CharPos.Line) + ':' + IntToStr(CharPos.CharIndex));
        CnOtaInsertTextIntoEditorAtPos(', ' + Names[1], LinearPos);
      end
      else
      begin
        ShowMessage('Will insert uses ' + Names[1] + ' after interface. Line ' + IntToStr(CharPos.Line));
        CnOtaInsertTextIntoEditorAtPos(#13#10#13#10 + 'uses' + #13#10 + '  ' + Names[1] + ';', LinearPos);
      end;
    end;
  finally
    UsesList.Free;
    Stream.Free;
    Names.Free;
    Paths.Free;
    FreeAndNil(FList);
  end;
end;

function TCnTestUnitListWizard.GetCaption: string;
begin
  Result := 'Test Unit List';
end;

function TCnTestUnitListWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestUnitListWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestUnitListWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestUnitListWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestUnitListWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Unit List Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Unit List';
end;

procedure TCnTestUnitListWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUnitListWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

function TCnTestUnitListWizard.SearchCppInsertPos(IsH: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
  LineText: string;
  S: AnsiString;
  LastIncLine: Integer;
{$IFDEF UNICODE}
  CParser: TCnBCBWideTokenList;
{$ELSE}
  CParser: TBCBTokenList;
{$ENDIF}
begin
  // �������һ�� include ǰ�档���� include��h �ļ��� cpp ������ͬ��
  Result := False;
  Stream := nil;
  CParser := nil;

  try
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveCurrentEditorToStreamW(Stream, False);
    CParser.SetOrigin(PWideChar(Stream.Memory), Stream.Size div SizeOf(Char));
{$ELSE}
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CnOtaSaveCurrentEditorToStream(Stream, False);
    CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
{$ENDIF}

    LastIncLine := -1;
    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
{$IFDEF UNICODE}
        LastIncLine := CParser.LineNumber;
{$ELSE}
        LastIncLine := CParser.RunLineNumber;
{$ENDIF}
      end;
      CParser.NextNonJunk;
    end;

    if LastIncLine >= 0 then
    begin
      Result := True;
      CharPos.Line := LastIncLine + 1; // ���һ�� inc ������
      CharPos.CharIndex := 0;
    end;
  finally
    CParser.Free;
    Stream.Free;
  end;
end;

function TCnTestUnitListWizard.SearchPasInsertPos(IsIntf: Boolean; out HasUses: Boolean;
  out CharPos: TOTACharPos): Boolean;
var
  Stream: TMemoryStream;
  LineText: string;
  S: AnsiString;
{$IFDEF UNICODE}
  Lex: TCnPasWideLex;
{$ELSE}
  Lex: TmwPasLex;
{$ENDIF}
  InIntf: Boolean;
  MeetIntf: Boolean;
  InImpl: Boolean;
  MeetImpl: Boolean;
  IntfLine, ImplLine: Integer;
begin
  Result := False;
  Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
  Lex := TCnPasWideLex.Create;
  CnOtaSaveCurrentEditorToStreamW(Stream, False);
{$ELSE}
  Lex := TmwPasLex.Create;
  CnOtaSaveCurrentEditorToStream(Stream, False);
{$ENDIF}

  InIntf := False;
  InImpl := False;
  MeetIntf := False;
  MeetImpl := False;

  HasUses := False;
  IntfLine := 0;
  ImplLine := 0;
  
  CharPos.Line := 0;
  CharPos.CharIndex := -1;

  try
{$IFDEF UNICODE}
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
      tkUses:
        begin
          if (IsIntf and InIntf) or (not IsIntf and InImpl) then
          begin
            HasUses := True; // �������Լ���Ҫ�� uses ��
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // ����λ�þ��ڷֺ�ǰ
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;
              CnDebugger.LogMsg('Insertion Col for Unicode (Zero Based) is: ' + IntToStr(CharPos.CharIndex));

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));
              CnDebugger.LogMsg('Line Text before Insertion: ' + S);

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // ������ Unicode ������� TOTACharPos ΪʲôҲ��Ҫ�� Utf8 ת��
{$ELSE}
              CharPos.Line := Lex.LineNumber + 1;
              CharPos.CharIndex := Lex.TokenPos - Lex.LinePos;
              CnDebugger.LogMsg('Insertion Col for Ansi (Zero Based) is: ' + IntToStr(CharPos.CharIndex));

  {$IFDEF IDE_STRING_ANSI_UTF8}
              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));

              CnDebugger.LogMsg('Line Text before Insertion: ' + S);

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));              
  {$ENDIF}
{$ENDIF}
              Exit;
            end
            else // uses ���Ҳ��ŷֺţ�����
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
      tkInterface:
        begin
          MeetIntf := True;
          InIntf := True;
          InImpl := False;
{$IFDEF UNICODE}
          IntfLine := Lex.LineNumber;
{$ELSE}
          IntfLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      tkImplementation:
        begin
          MeetImpl := True;
          InIntf := False;
          InImpl := True;
{$IFDEF UNICODE}
          ImplLine := Lex.LineNumber;
{$ELSE}
          ImplLine := Lex.LineNumber + 1;
{$ENDIF}
        end;
      end;
      Lex.Next;
    end;

    // ������ϣ����˴���û�� uses ������
    if IsIntf and MeetIntf then    // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // ���������� interface ���� interface Ϊ�����
    begin
      Result := True;
      CharPos.Line := ImplLine;
      CharPos.CharIndex := Length('implementation');
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

initialization
  RegisterCnWizard(TCnTestUnitListWizard); // ע��˲���ר��

end.
