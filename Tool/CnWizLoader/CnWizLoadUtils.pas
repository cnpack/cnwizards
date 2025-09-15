{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnWizLoadUtils;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizard 专家 DLL 加载器工具单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin7 + Delphi 5.0
* 兼容测试：所有版本的 Delphi
* 本 地 化：该单元无需本地化
* 修改记录：2025.02.03 V1.0
*               从 WizLoader 的工程中独立出来
*               持续根据 Delphi 的新版及新 Update 包及新 Patch 包更新
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
  {* 文件版本号}
    Major: Word;
    Minor: Word;
    Release: Word;
    Build: Word;
  end;

function IsDebuggerPresent: BOOL; stdcall; external 'kernel32.dll';

// 取文件版本号
function GetFileVersionNumber(const FileName: string): TVersionNumber;

// 加载器 DLL 卸载函数，执行专家包 DLL 的卸载过程并卸载专家包 DLL
procedure LoaderTerminate;

// 包含 32 位和 64 位在内的所有版本 DLL 的判断并返回完整路径和名称
function GetWizardDll: string;

var
  LoaderTerminateProc: TWizardTerminateProc = nil;
  DllInst: HINST = 0;

implementation

{$IFDEF WIN64}
{$R-} // 64 位下不知道哪里出 Range Check Error，屏蔽先
{$ENDIF}

// 取文件版本号
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

// 加载器 DLL 卸载函数，执行专家包 DLL 的卸载过程并卸载专家包 DLL
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
  if IsDebuggerPresent then // 调试期，指向开发路径
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

  // 判断 IDE 类型与版本号
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
        if V.Release < XE2_UPDATE4_HOTFIX1_RELEASE then  // XE2 Update 4 Hotfix 1 不兼容以前的版本，采用另一个 DLL
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
          Result := Dir + 'CnWizards_DXE81.DLL' // XE8 Update 1 或以上的 FMX 不兼容无 Update 版的，采用另一个低版本编译的 DLL
        else
          Result := Dir + 'CnWizards_DXE8.DLL';
      end;
    23: Result := Dir + 'CnWizards_D10S.DLL';
    24: Result := Dir + 'CnWizards_D101B.DLL';
    25: Result := Dir + 'CnWizards_D102T.DLL';
    26:
      begin
        if V.Release < RIO_10_3_2_RELEASE then  // 10.3.1 或以下采用另一个 DLL
          Result := Dir + 'CnWizards_D103R1.DLL'
        else
          Result := Dir + 'CnWizards_D103R.DLL';
      end;
    27:
      begin
        if V.Release < SYDNEY_10_4_1_RELEASE then  // 10.4.0 采用另一个 DLL
          Result := Dir + 'CnWizards_D104S1.DLL'
        else
          Result := Dir + 'CnWizards_D104S.DLL';
      end;
    28: Result := Dir + 'CnWizards_D110A.DLL';
    29:
      begin
{$IFDEF WIN64}
        Result := Dir + 'CnWizards_D120A64.DLL'; // 64 位 IDE 用这个
{$ELSE}
        if V.Release < ATHENS_12_2_RELEASE then  // 12.1 或 12.0 采用另一个 DLL
          Result := Dir + 'CnWizards_D120A1.DLL'
        else if V.Release < ATHENS_12_2_PATCH1_RELEASE then // 12.2 采用另一个 DLL
          Result := Dir + 'CnWizards_D120A2.DLL'
        else
          Result := Dir + 'CnWizards_D120A.DLL'; // 12.2 Patch 1
{$ENDIF}
      end;
    37:
      begin
{$IFDEF WIN64}
        Result := Dir + 'CnWizards_D130F64.DLL'; // 64 位 IDE 用这个
{$ELSE}
        Result := Dir + 'CnWizards_D130F.DLL';   // 13.0
{$ENDIF}
      end;
  end;
end;

end.
