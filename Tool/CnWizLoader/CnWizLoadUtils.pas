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

unit CnWizLoadUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizard ר�� DLL ���������ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ����а汾�� Delphi
* �� �� �����õ�Ԫ���豾�ػ�
* �޸ļ�¼��2025.02.03 V1.0
*               �� WizLoader �Ĺ����ж�������
*               �������� Delphi ���°漰�� Update ������ Patch ������
================================================================================
|</PRE>}

interface

uses
  SysUtils, Windows, Forms, ToolsAPI;

const
  SCnNoCnWizardsSwitch = 'nocn';

type
  TWizardEntryPoint = function (const BorlandIDEServices: IBorlandIDEServices;
    RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;

  TVersionNumber = packed record
  {* �ļ��汾��}
    Major: Word;
    Minor: Word;
    Release: Word;
    Build: Word;
  end;

function IsDebuggerPresent: BOOL; stdcall; external 'kernel32.dll';

// ȡ�ļ��汾��
function GetFileVersionNumber(const FileName: string): TVersionNumber;

// ������ DLL ж�غ�����ִ��ר�Ұ� DLL ��ж�ع��̲�ж��ר�Ұ� DLL
procedure LoaderTerminate;

// ���� 32 λ�� 64 λ���ڵ����а汾 DLL ���жϲ���������·��������
function GetWizardDll: string;

var
  LoaderTerminateProc: TWizardTerminateProc = nil;
  DllInst: HINST = 0;

implementation

{$IFDEF WIN64}
{$R-} // 64 λ�²�֪������� Range Check Error��������
{$ENDIF}

// ȡ�ļ��汾��
function GetFileVersionNumber(const FileName: string): TVersionNumber;
var
  VersionInfoBufferSize: DWORD;
  dummyHandle: DWORD;
  VersionInfoBuffer: Pointer;
  FixedFileInfoPtr: PVSFixedFileInfo;
  VersionValueLength: UINT;
begin
  FillChar(Result, SizeOf(Result), 0);
  if not FileExists(FileName) then
    Exit;

  VersionInfoBufferSize := GetFileVersionInfoSize(PChar(FileName), dummyHandle);
  if VersionInfoBufferSize = 0 then
    Exit;

  GetMem(VersionInfoBuffer, VersionInfoBufferSize);
  try
    try
      Win32Check(GetFileVersionInfo(PChar(FileName), dummyHandle,
        VersionInfoBufferSize, VersionInfoBuffer));
      Win32Check(VerQueryValue(VersionInfoBuffer, '\',
        Pointer(FixedFileInfoPtr), VersionValueLength));
    except
      Exit;
    end;
    Result.Major := FixedFileInfoPtr^.dwFileVersionMS shr 16;
    Result.Minor := FixedFileInfoPtr^.dwFileVersionMS;
    Result.Release := FixedFileInfoPtr^.dwFileVersionLS shr 16;
    Result.Build := FixedFileInfoPtr^.dwFileVersionLS;
  finally
    FreeMem(VersionInfoBuffer);
  end;
end;

// ������ DLL ж�غ�����ִ��ר�Ұ� DLL ��ж�ع��̲�ж��ר�Ұ� DLL
procedure LoaderTerminate;
begin
  if Assigned(LoaderTerminateProc) then
    LoaderTerminateProc();
  FreeLibrary(DllInst);
  DllInst := 0;
end;

function GetWizardDll: string;
const
  XE2_UPDATE4_HOTFIX1_RELEASE = 4504;
  XE8_UPDATE1_RELEASE = 19908;
  RIO_10_3_2_RELEASE = 34749;
  SYDNEY_10_4_1_RELEASE = 38860;
  ATHENS_12_2_RELEASE = 53571;
  ATHENS_12_2_PATCH1_RELEASE = 53982;
var
  FullPath: array[0..MAX_PATH - 1] of AnsiChar;
  Dir, Exe: string;
  V: TVersionNumber;
begin
  if IsDebuggerPresent then // �����ڣ�ָ�򿪷�·��
  begin
    OutputDebugString('Is Under Debugger. Use Developing Dll.');
    Dir := 'C:\CnPack\cnwizards\Bin\';
    if not DirectoryExists(Dir) then
    begin
      OutputDebugString('But NO Developing Directory. Use Normal Again.');
      GetModuleFileNameA(HInstance, @FullPath[0], MAX_PATH);
      Dir := ExtractFilePath(FullPath);
    end;
  end
  else
  begin
    GetModuleFileNameA(HInstance, @FullPath[0], MAX_PATH);
    Dir := ExtractFilePath(FullPath);
  end;

  // �ж� IDE ������汾��
  V := GetFileVersionNumber(Application.ExeName);
  Exe := LowerCase(ExtractFileName(Application.ExeName));

  OutputDebugString(PChar(Format('CnWizards Loader Get Exe Version: %d.%d.%d.%d',
    [V.Major, V.Minor, V.Release, V.Build])));

  case V.Major of
    5:
      begin
        if Pos('bcb', Exe) = 1 then
          Result := Dir + 'CnWizards_CB5.DLL'
        else
          Result := Dir + 'CnWizards_D5.DLL'
      end;
    6:
      begin
        if Pos('bcb', Exe) = 1 then
          Result := Dir + 'CnWizards_CB6.DLL'
        else
          Result := Dir + 'CnWizards_D6.DLL'
      end;
    7: Result := Dir + 'CnWizards_D7.DLL';
    9: Result := Dir + 'CnWizards_D2005.DLL';
    10: Result := Dir + 'CnWizards_D2006.DLL';
    11: Result := Dir + 'CnWizards_D2007.DLL';
    12: Result := Dir + 'CnWizards_D2009.DLL';
    14: Result := Dir + 'CnWizards_D2010.DLL';
    15: Result := Dir + 'CnWizards_DXE.DLL';
    16:
      begin
        if V.Release < XE2_UPDATE4_HOTFIX1_RELEASE then  // XE2 Update 4 Hotfix 1 ��������ǰ�İ汾��������һ�� DLL
          Result := Dir + 'CnWizards_DXE21.DLL'
        else
          Result := Dir + 'CnWizards_DXE2.DLL';
      end;
    17: Result := Dir + 'CnWizards_DXE3.DLL';
    18: Result := Dir + 'CnWizards_DXE4.DLL';
    19: Result := Dir + 'CnWizards_DXE5.DLL';
    20: Result := Dir + 'CnWizards_DXE6.DLL';
    21: Result := Dir + 'CnWizards_DXE7.DLL';
    22:
      begin
        if V.Release < XE8_UPDATE1_RELEASE then
          Result := Dir + 'CnWizards_DXE81.DLL' // XE8 Update 1 �����ϵ� FMX �������� Update ��ģ�������һ���Ͱ汾����� DLL
        else
          Result := Dir + 'CnWizards_DXE8.DLL';
      end;
    23: Result := Dir + 'CnWizards_D10S.DLL';
    24: Result := Dir + 'CnWizards_D101B.DLL';
    25: Result := Dir + 'CnWizards_D102T.DLL';
    26:
      begin
        if V.Release < RIO_10_3_2_RELEASE then  // 10.3.1 �����²�����һ�� DLL
          Result := Dir + 'CnWizards_D103R1.DLL'
        else
          Result := Dir + 'CnWizards_D103R.DLL';
      end;
    27:
      begin
        if V.Release < SYDNEY_10_4_1_RELEASE then  // 10.4.0 ������һ�� DLL
          Result := Dir + 'CnWizards_D104S1.DLL'
        else
          Result := Dir + 'CnWizards_D104S.DLL';
      end;
    28: Result := Dir + 'CnWizards_D110A.DLL';
    29:
      begin
{$IFDEF WIN64}
        Result := Dir + 'CnWizards_D120A64.DLL'; // 64 λ IDE �����
{$ELSE}
        if V.Release < ATHENS_12_2_RELEASE then  // 12.1 �� 12.0 ������һ�� DLL
          Result := Dir + 'CnWizards_D120A1.DLL'
        else if V.Release < ATHENS_12_2_PATCH1_RELEASE then // 12.2 ������һ�� DLL
          Result := Dir + 'CnWizards_D120A2.DLL'
        else
          Result := Dir + 'CnWizards_D120A.DLL'; // 12.2 Patch 1
{$ENDIF}
      end;
    37:
      begin
{$IFDEF WIN64}
        Result := Dir + 'CnWizards_D130F64.DLL'; // 64 λ IDE �����
{$ELSE}
        Result := Dir + 'CnWizards_D130F.DLL';   // 13.0
{$ENDIF}
      end;
  end;
end;

end.
