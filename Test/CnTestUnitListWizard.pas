{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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

unit CnTestUnitListWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：TUnitNameList 测试用例单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.03.01 V1.0
*               创建单元
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
// 测试 TUnitNameList 相关功能的菜单专家
//==============================================================================

{ TCnTestUnitListWizard }

  TCnTestUnitListWizard = class(TCnMenuWizard)
  private
    FList: TUnitNameList;
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
// 测试 TUnitNameList 相关功能的菜单专家
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
    FList := TUnitNameList.Create(True, False, False);
    IsCppMode := False;
  end
  else if CurrentIsCSource then
  begin
    FList := TUnitNameList.Create(True, True, False);
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

    // 此时得到了所有可引用的单元列表

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

    // 此时剔除已引用的，得到了可引用的单元列表
    if Names.Count = 0 then
      Exit;
    EditView := CnOtaGetTopMostEditView;

    if IsCppMode then
    begin
      // 插入至 Cpp 文件头部最后一个 include 后，如无就插最头上
      if not SearchCppInsertPos(False, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for Cpp Include.');
        Exit;
      end;
    end
    else
    begin
      // 插入至 interface 处的 uses，还得处理无 uses 的情况
      if not SearchPasInsertPos(False, HasUses, CharPos) then
      begin
        ErrorDlg('Can NOT Find an Insert Position for implementation uses.');
        Exit;
      end;
    end;

    // 已经得到行 1 列 0 开始的 CharPos，用 EditView.CharPosToPos(CharPos) 转换为线性;
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
      // 插入至 H 文件头部最后一个 include 后，如无就查ifdef def，插它后面
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
  // 插在最后一个 include 前面。如无 include，h 文件和 cpp 处理还不同。
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
      CharPos.Line := LastIncLine + 1; // 最后一个 inc 的行首
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
            HasUses := True; // 到达了自己需要的 uses 处
            while not (Lex.TokenID in [tkNull, tkSemiColon]) do
              Lex.Next;

            if Lex.TokenID = tkSemiColon then
            begin
              // 插入位置就在分号前
              Result := True;
{$IFDEF UNICODE}
              CharPos.Line := Lex.LineNumber;
              CharPos.CharIndex := Lex.TokenPos - Lex.LineStartOffset;
              CnDebugger.LogMsg('Insertion Col for Unicode (Zero Based) is: ' + IntToStr(CharPos.CharIndex));

              LineText := CnOtaGetLineText(CharPos.Line);
              S := AnsiString(Copy(LineText, 1, CharPos.CharIndex));
              CnDebugger.LogMsg('Line Text before Insertion: ' + S);

              CharPos.CharIndex := Length(CnAnsiToUtf8(S));  // 不明白 Unicode 环境里的 TOTACharPos 为什么也需要做 Utf8 转换
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
            else // uses 后找不着分号，出错
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

    // 解析完毕，到此处是没有 uses 的情形
    if IsIntf and MeetIntf then    // 曾经遇到过 interface 就以 interface 为插入点
    begin
      Result := True;
      CharPos.Line := IntfLine;
      CharPos.CharIndex := Length('interface');
    end
    else if not IsIntf and MeetImpl then // 曾经遇到过 interface 就以 interface 为插入点
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
  RegisterCnWizard(TCnTestUnitListWizard); // 注册此测试专家

end.
