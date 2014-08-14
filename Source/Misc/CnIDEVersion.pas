{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from GExperts 1.3                                    }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnIDEVersion;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 版本检查单元
* 单元作者：刘啸 (zjy@cnpack.org)
* 备    注：该单元部分内容移植自 GExperts
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2003.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  CnCommon, CnWizUtils;

function IsIdeVersionLatest: Boolean;

var
  CnIdeVersionDetected: Boolean = False;
  CnIdeVersionIsLatest: Boolean = False;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

function CompareVersionNumber(const V1, V2: TVersionNumber): Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('V1: %d.%d.%d.%d.', [V1.Major, V1.Minor, V1.Release, V1.Build]);
  CnDebugger.LogFmt('V2: %d.%d.%d.%d.', [V2.Major, V2.Minor, V2.Release, V2.Build]);
{$ENDIF}

  Result := V1.Major - V2.Major;
  if Result <> 0 then
    Exit;

  Result := V1.Minor - V2.Minor;
  if Result <> 0 then
    Exit;

  Result := V1.Release - V2.Release;
  if Result <> 0 then
    Exit;

  Result := V1.Build - V2.Build;
end;

function IsDelphi5IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 5; Minor: 0; Release: 6; Build: 18);
var
  ReadFileVersion: TVersionNumber; // Update 1
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coride50.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsBCB5IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 1
    (Major: 5; Minor: 0; Release: 12; Build: 34);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coride50.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi6IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 6; Minor: 0; Release: 6; Build: 240);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide60.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsBCB6IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =  // Update 4
    (Major: 6; Minor: 0; Release: 10; Build: 166);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide60.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi7IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 1
    (Major: 7; Minor: 0; Release: 8; Build: 1);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide70.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi8IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 7; Minor: 1; Release: 1446; Build: 610);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\Dcc71.dll');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  if Result then
  begin
    ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\bds.exe');
    Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  end;
end;

function IsDelphi9IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 9; Minor: 0; Release: 1935; Build: 22056);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide90.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi10IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 10; Minor: 0; Release: 2329; Build: 20030);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi11IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 3, Dec 2007
    (Major: 11; Minor: 0; Release: 2902; Build: 10471);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi12IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 4?
    (Major: 12; Minor: 0; Release: 3420; Build: 21218);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide120.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi14IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 4
    (Major: 14; Minor: 0; Release: 3593; Build: 25826);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide140.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi15IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 15; Minor: 0; Release: 3809; Build: 34076);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide150.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi16IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 4
    (Major: 16; Minor: 0; Release: 4429; Build: 46931);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide160.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphi17IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 17; Minor: 0; Release: 4771; Build: 56661); // Update 2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide170.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphiXE4IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 18; Minor: 0; Release: 4905; Build: 60485); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide180.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphiXE5IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 19; Minor: 0; Release: 14356; Build: 6604); // Update 2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide190.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsDelphiXE6IdeVersionLatest: Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 20; Minor: 0; Release: 16277; Build: 1276); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide200.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
end;

function IsIdeVersionLatest: Boolean;
begin
  if CnIdeVersionDetected then
  begin
    Result := CnIdeVersionIsLatest;
    Exit;
  end;
  // 碰上不支持的 IDE，返回 True
  CnIdeVersionIsLatest := True;

{$IFDEF DELPHI5}
  CnIdeVersionIsLatest := IsDelphi5IdeVersionLatest;
{$ENDIF}

{$IFDEF BCB5}
  CnIdeVersionIsLatest := IsBCB5IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI6}
  CnIdeVersionIsLatest := IsDelphi6IdeVersionLatest;
{$ENDIF}

{$IFDEF BCB6}
  CnIdeVersionIsLatest := IsBCB6IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI7}
  CnIdeVersionIsLatest := IsDelphi7IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI8}
  CnIdeVersionIsLatest := IsDelphi8IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI9}
  CnIdeVersionIsLatest := IsDelphi9IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI10}
  CnIdeVersionIsLatest := IsDelphi10IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI11}
  CnIdeVersionIsLatest := IsDelphi11IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI12}
  CnIdeVersionIsLatest := IsDelphi12IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI14}
  CnIdeVersionIsLatest := IsDelphi14IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI15}
  CnIdeVersionIsLatest := IsDelphi15IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI16}
  CnIdeVersionIsLatest := IsDelphi16IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHI17}
  CnIdeVersionIsLatest := IsDelphi17IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHIXE4}
  CnIdeVersionIsLatest := IsDelphiXE4IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHIXE5}
  CnIdeVersionIsLatest := IsDelphiXE5IdeVersionLatest;
{$ENDIF}

{$IFDEF DELPHIXE6}
  CnIdeVersionIsLatest := IsDelphiXE6IdeVersionLatest;
{$ENDIF}

  Result := CnIdeVersionIsLatest;
  CnIdeVersionDetected := True;
end;

end.
