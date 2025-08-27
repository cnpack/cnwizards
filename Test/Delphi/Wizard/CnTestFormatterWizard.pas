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

unit CnTestFormatterWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Դ����ʽ�����ܵĲ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnCppCodeParser �� ParseCppCodePosInfo �Բ鿴�Ƿ����˹��
            ���ڴ���λ�����͡�����ʱ��ǰ���ڴ� C/C++ �ļ����ɲ��ԡ�
* ����ƽ̨��WinXP + BCB 5/6
* ���ݲ��ԣ�PWin9X/2000/XP + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.02.12 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnFormatterIntf;

type

//==============================================================================
// ���Լ��� DLL �����и�ʽ�������Ĳ˵�ר��
//==============================================================================

{ TCnTestFormatterWizard }

  TCnTestFormatterWizard = class(TCnMenuWizard)
  private
    FHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;
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
  CnDebug, CnCommon;

const
{$IFDEF UNICODE}
  DLLName: string = 'CnFormatLibW.dll'; // D2009 ~ ���� �� Unicode ��
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  DLLName: string = 'CnFormatLibW.dll'; // D2005 ~ 2007 Ҳ�� Unicode �浫�� UTF8
  {$ELSE}
  DLLName: string = 'CnFormatLib.dll';  // D5~7 ���� Ansi ��
  {$ENDIF}
{$ENDIF}

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

//==============================================================================
// ���Լ��� DLL �����и�ʽ�������Ĳ˵�ר��
//==============================================================================

{ TCnTestFormatterWizard }

procedure TCnTestFormatterWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestFormatterWizard.Create;
begin
  inherited;

end;

destructor TCnTestFormatterWizard.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TCnTestFormatterWizard.Execute;
var
  Src: string;
  Res: PChar;
  Formatter: ICnPascalFormatterIntf;
  ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
  View: IOTAEditView;
  Block: IOTAEditBlock;
  StartPos, EndPos, StartPosIn, EndPosIn: Integer;
  StartRec, EndRec: TOTACharPos;
begin
  if FHandle = 0 then
    FHandle := LoadLibrary(PChar(ModulePath + DLLName));
   
  if FHandle = 0 then
  begin
    ShowMessage('No DLL Found.');
    Exit;
  end;

  if not Assigned(FGetProvider) then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FHandle, 'GetCodeFormatterProvider'));
  if not Assigned(FGetProvider) then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Provider Found.');
    Exit;
  end;

  Formatter := FGetProvider();
  if Formatter = nil then
  begin
    FGetProvider := nil;
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Formatter Found.');
    Exit;
  end;

  if CnOtaCurrBlockEmpty then
  begin
{$IFDEF UNICODE}
    // Src/Res Utf16
    Src := CnOtaGetCurrentEditorSourceW;
    Res := Formatter.FormatOnePascalUnitW(PChar(Src), Length(Src));

    // Remove FF FE BOM if exists
    if (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
      Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // Src/Res Utf8
    Src := CnOtaGetCurrentEditorSource(False);
    Res := Formatter.FormatOnePascalUnitUtf8(PAnsiChar(Src), Length(Src));

    // Remove EF BB BF BOM if exist
    if (StrLen(Res) > 3) and
      (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
      Inc(Res, 3);
  {$ELSE}
    // Src/Res Ansi
    Src := CnOtaGetCurrentEditorSource(True);
    Res := Formatter.FormatOnePascalUnit(PAnsiChar(Src), Length(Src));
  {$ENDIF}
{$ENDIF}

    if Res <> nil then
    begin
      ShowMessage(Res);
{$IFDEF UNICODE}
      // Utf16 �ڲ�ת Utf8 д��
      CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
      // Utf8 ֱ��д��
      CnOtaSetCurrentEditorSourceUtf8(string(Res));
  {$ELSE}
      // Ansi ת Utf8 д��
      CnOtaSetCurrentEditorSource(string(Res));
  {$ENDIF}
{$ENDIF}
    end
    else
    begin
      ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
        SourcePos, CurrentToken);
      ShowMessage(Format('Error Code %d, Line %d, Col %d, Pos %d, Token %s', [ErrCode,
        SourceLine, SourceCol, SourcePos, CurrentToken]));
    end;
  end
  else // ��ѡ����
  begin
{$IFDEF UNICODE}
    // Src/Res Utf16
    Src := CnOtaGetCurrentEditorSourceW;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // Src/Res Utf8
    Src := CnOtaGetCurrentEditorSource(False);
  {$ELSE}
    // Src/Res Ansi
    Src := CnOtaGetCurrentEditorSource(True);
  {$ENDIF}
{$ENDIF}

    View := CnOtaGetTopMostEditView;
    if View <> nil then
    begin
      Block := View.Block;
      if (Block <> nil) and Block.IsValid then
      begin
        // ѡ�����ֹλ�����쵽��ģʽ
        if not CnOtaGetBlockOffsetForLineMode(StartRec, EndRec, View) then
          Exit;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(StartRec.CharIndex, StartRec.Line), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(EndRec.CharIndex, EndRec.Line), View);

        // ��ʱ StartPos �� EndPos ����˵�ǰѡ������Ҫ������ı�
{$IFDEF UNICODE}
        // Src/Res Utf16���� LinearPos �� Utf8 ��ƫ��������Ҫת��
        StartPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, StartPos + 1))) - 1;
        EndPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, EndPos + 1))) - 1;

        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlockW(PChar(Src), Length(Src), StartPosIn, EndPosIn);

        // Remove FF FE BOM if exists
        if (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
          Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        StartPosIn := StartPos;
        EndPosIn := EndPos;
        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);

        // Remove EF BB BF BOM if exist
        if (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);
  {$ELSE}
        // Src/Res Ansi
        StartPosIn := StartPos;
        EndPosIn := EndPos;
        // IDE �ڵ����� Pos �� 0 ��ʼ�ģ�ʹ�� Src �� Copy ʱ���±��� 1 ��ʼ�������Ҫ�� 1
        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlock(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);
  {$ENDIF}
{$ENDIF}

        if Res <> nil then
        begin
          ShowMessage(Res);
//          Len := StrLen(Res);
//          if (Len > 2) and (Res[Len - 2] = #13) and (Res[Len - 1] = #10) then
//            Res[Len - 2] := #0;  // ȥ��β���Ķ���Ļ���

          {$IFDEF IDE_STRING_ANSI_UTF8}
          CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
          {$ELSE}
          // Ansi/Unicode ������
          CnOtaReplaceCurrentSelection(Res, True, True, True);
          {$ENDIF}
        end
        else
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);
          ShowMessage(Format('Error Code %d, Line %d, Col %d, Pos %d, Token %s', [ErrCode,
            SourceLine, SourceCol, SourcePos, CurrentToken]));
        end;
      end;
    end;
  end;

  Formatter := nil;
end;

function TCnTestFormatterWizard.GetCaption: string;
begin
  Result := 'Test Formatter';
end;

function TCnTestFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestFormatterWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestFormatterWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestFormatterWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Formatter Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Formatterusing DLL.';
end;

procedure TCnTestFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestFormatterWizard); // ע��˲���ר��

end.
