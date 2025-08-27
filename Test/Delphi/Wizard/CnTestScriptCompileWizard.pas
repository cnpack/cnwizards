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

unit CnTestScriptCompileWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestScriptCompileWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.03.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, IniFiles,
  ToolsAPI, FileCtrl, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon;

type

//==============================================================================
// CnTestScriptCompileWizard �˵�ר��
//==============================================================================

{ TCnTestScriptCompileWizard }

  TCnTestScriptCompileWizard = class(TCnMenuWizard)
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
  end;

implementation

uses
  CnDebug, CnScriptClasses;

//==============================================================================
// CnTestScriptCompileWizard �˵�ר��
//==============================================================================

{ TCnTestScriptCompileWizard }

procedure TCnTestScriptCompileWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestScriptCompileWizard.Execute;
var
  I: Integer;
  Dir, Msg: string;
  Files, Sl: TStringList;
  Exec: TCnScriptExec;
begin
  if SelectDirectory('Select Script Directory', 'C:\', Dir) then
  begin
    Files := TStringList.Create;
    try
      GetDirFiles(Dir, Files);

      for I := 0 to Files.Count - 1 do
      begin
        if LowerCase(ExtractFileExt(Files[I])) <> '.pas' then
          Continue;

        Sl := nil;
        Exec := nil;

        try
          Sl := TStringList.Create;
          Sl.LoadFromFile(MakePath(Dir) + Files[I]);
          Exec := TCnScriptExec.Create;

          Msg := '';
          if Exec.CompileScript(Sl.Text, Msg) = erSucc then
          begin
            CnDebugger.LogMsg('Compile OK: ' + Files[I]);
            if Exec.ExecScript(Sl.Text, Msg) = erSucc then
              CnDebugger.LogMsg('Exec OK: ' + Files[I])
            else
            begin
              CnDebugger.LogMsgError('Exec Fail: ' + Files[I]);
              CnDebugger.LogMsgError(Msg);
            end;
          end
          else
          begin
            CnDebugger.LogMsgError('Compile Fail: ' + Files[I]);
            CnDebugger.LogMsgError(Msg);
          end;
        finally
          Exec.Free;
          Sl.Free;
        end;
      end;
    finally
      Files.Free;
    end;
  end;
end;

function TCnTestScriptCompileWizard.GetCaption: string;
begin
  Result := 'Test Script Compile';
end;

function TCnTestScriptCompileWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestScriptCompileWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestScriptCompileWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestScriptCompileWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestScriptCompileWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Script Compile Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Script Files Compiling';
end;

procedure TCnTestScriptCompileWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestScriptCompileWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestScriptCompileWizard); // ע��˲���ר��

end.
