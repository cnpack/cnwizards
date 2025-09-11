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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.3                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnIDEVersion;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE �汾��鵥Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫ����������ֲ�� GExperts
*           ��ԭʼ������ GExperts License �ı���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2023.11.08 by liuxiao
*               ������ֲ���� Delphi 12 Athens
*           2022.03.12 by liuxiao
*               ������ֲ���� Delphi 11.3 Alexandria
*           2020.05.27 by liuxiao
*               ������ֲ���� Delphi 10.4 Sydney
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2003.04.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Forms, CnCommon, CnWizUtils;

function GetIdeExeVersion: string;
{* ��ȡ IDE �� exe �ļ�����ϸ�汾��}

function IsIdeVersionLatest(out LatestUpdate: string): Boolean;
{* ���ص�ǰ�Ƿ����� IDE �汾}

function IsDelphi10Dot2GEDot2: Boolean;
{* �����Ƿ� Delphi 10.2.2 �� 10.2 �ĸ��ߵ��Ӱ汾�����������ж�}

function IsDelphi10Dot4GEDot2: Boolean;
{* �����Ƿ� Delphi 10.4.2 �� 10.4 �ĸ��ߵ��Ӱ汾������ĳЩ�Ź��ж�}

function IsDelphi11GEDot3: Boolean;
{* �����Ƿ� Delphi 11.3 �� 11 �ĸ��ߵ��Ӱ汾������ĳЩ�Ź��ж�}

function IsDelphi12Dot3GEHotFix: Boolean;
{* �����Ƿ� Delphi 12.3 �� HotFix ����ߵ��Ӱ汾������ĳЩ�Ź��ж�}

var
  CnIdeVersionDetected: Boolean = False;
  CnIdeVersionIsLatest: Boolean = False;

  CnIsDelphi10Dot2GEDot2: Boolean = False;
  CnIsDelphi10Dot4GEDot2: Boolean = False;

  CnIsDelphi11GEDot3: Boolean = False; // �Ƿ� D11 �µ� .3�������� D12
  CnIsGEDelphi11Dot3: Boolean = False; // �Ƿ���ڵ��� D11.3������ D12
  CnIsDelphi12Dot3GEHotFix: Boolean = False;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

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

function IsDelphi5IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 5; Minor: 0; Release: 6; Build: 18);
var
  ReadFileVersion: TVersionNumber; // Update 1��ע���ļ������� IDE ��ͬ
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\dcc32.exe');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsBCB5IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 1
    (Major: 5; Minor: 0; Release: 12; Build: 34);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coride50.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphi6IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 6; Minor: 0; Release: 6; Build: 240);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide60.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsBCB6IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =  // Update 4
    (Major: 6; Minor: 0; Release: 10; Build: 166);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide60.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 4';
end;

function IsDelphi7IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 1
    (Major: 7; Minor: 0; Release: 8; Build: 1);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide70.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphi8IdeVersionLatest(out LatestUpdate: string): Boolean;
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
  LatestUpdate := 'Update 2';
end;

function IsDelphi2005IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 9; Minor: 0; Release: 1935; Build: 22056);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide90.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphi2006IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2
    (Major: 10; Minor: 0; Release: 2329; Build: 20030);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphi2007IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 3, Dec 2007
    (Major: 11; Minor: 0; Release: 2902; Build: 10471);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 3';
end;

function IsDelphi2009IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 4
    (Major: 12; Minor: 0; Release: 3420; Build: 21218);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide120.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 4';
end;

function IsDelphi2010IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 5
    (Major: 14; Minor: 0; Release: 3615; Build: 26342);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide140.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 4';
end;

function IsDelphiXEIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 2?
    (Major: 15; Minor: 0; Release: 3953; Build: 35171);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide150.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphiXE2IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber = // Update 4 HotFix 1
    (Major: 16; Minor: 0; Release: 4504; Build: 48759);
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide160.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 4 HotFix 1';
end;

function IsDelphiXE3IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 17; Minor: 0; Release: 4770; Build: 56661); // Update 2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide170.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphiXE4IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 18; Minor: 0; Release: 4905; Build: 60485); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide180.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphiXE5IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 19; Minor: 0; Release: 14356; Build: 6604); // Update 2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide190.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphiXE6IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 20; Minor: 0; Release: 16277; Build: 1276); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide200.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphiXE7IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 21; Minor: 0; Release: 17707; Build: 5020); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide210.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphiXE8IdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 22; Minor: 0; Release: 19908; Build: 869); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide220.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphi10SIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 23; Minor: 0; Release: 21418; Build: 4207); // Update 1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide230.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 1';
end;

function IsDelphi101BIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 24; Minor: 0; Release: 25048; Build: 9432); // Update 2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide240.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2';
end;

function IsDelphi102TIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 25; Minor: 0; Release: 31059; Build: 3231); // 10.2.3 ���ڸ��µİ汾����ʵӦ�ý� 10.2.4
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide250.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 3 (10.2.3)';
end;

function IsDelphi10Dot2GEDot2: Boolean;
{$IFDEF DELPHI102_TOKYO}
const
  CoreIdeLatest: TVersionNumber =
    (Major: 25; Minor: 0; Release: 29039; Build: 2004); // 10.2.2
var
  ReadFileVersion: TVersionNumber;
{$ENDIF}
begin
{$IFDEF DELPHI102_TOKYO}
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide250.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function IsDelphi103RIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 26; Minor: 0; Release: 36039; Build: 7899); // 10.3.3
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide260.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 3 (10.3.3)';
end;

function IsDelphi104SIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 27; Minor: 0; Release: 40680; Build: 4203); // 10.4.2
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide270.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 2 (10.4.2)';
end;

function IsDelphi10Dot4GEDot2: Boolean;
{$IFDEF DELPHI104_SYDNEY}
const
  CoreIdeLatest: TVersionNumber =
    (Major: 27; Minor: 0; Release: 40680; Build: 4203); // 10.4.2
var
  ReadFileVersion: TVersionNumber;
{$ENDIF}
begin
{$IFDEF DELPHI104_SYDNEY}
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide270.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function IsDelphi110AIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 28; Minor: 0; Release: 48361; Build: 3236); // 11.3.1
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide280.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 3.1 (11.3.1)';
end;

function IsDelphi120AIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 29; Minor: 0; Release: 55362; Build: 2017); // 12.3
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide290.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := 'Update 3 (12.3)';
end;

function IsDelphi130AIdeVersionLatest(out LatestUpdate: string): Boolean;
const
  CoreIdeLatest: TVersionNumber =
    (Major: 37; Minor: 0; Release: 57242; Build: 3601); // 13.0
var
  ReadFileVersion: TVersionNumber;
begin
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide370.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
  LatestUpdate := '13.0';
end;

function IsDelphi11GEDot3: Boolean;
{$IFDEF DELPHI110_ALEXANDRIA}
const
  CoreIdeLatest: TVersionNumber =
    (Major: 28; Minor: 0; Release: 47991; Build: 2819); // 11.3
var
  ReadFileVersion: TVersionNumber;
{$ENDIF}
begin
{$IFDEF DELPHI110_ALEXANDRIA}
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide280.bpl');
  Result := CompareVersionNumber(ReadFileVersion, CoreIdeLatest) >= 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function IsGEDelphi11Dot3: Boolean;
begin
{$IFDEF DELPHI120_ATHENS_UP}
  Result := True;
{$ELSE}
  Result := IsDelphi11GEDot3;
{$ENDIF};
end;

function IsDelphi12Dot3GEHotFix: Boolean;
{$IFDEF DELPHI120_ATHENS}
var
  Year, Month, Day: Word;
  D: TDateTime;
{$ENDIF}
begin
{$IFDEF DELPHI120_ATHENS}
  Year := 1970;
  Month := 1;
  Day := 1;

  // 12.3 �������� HotFix���汾�Ŷ�һ����ֻ�����ļ����������ж�
  D := GetFileDateTime(GetIdeRootDirectory + 'Bin\coreide290.bpl');
  DecodeDate(D, Year, Month, Day);
  Result := (Year = 2025) and (Month >= 4);
{$ELSE}
  Result := False;
{$ENDIF};
end;

function IsIdeVersionLatest(out LatestUpdate: string): Boolean;
begin
  if CnIdeVersionDetected then
  begin
    Result := CnIdeVersionIsLatest;
    Exit;
  end;

  // ���ϲ�֧�ֵ� IDE������ True
  CnIdeVersionIsLatest := True;

{$IFDEF DELPHI5}
  CnIdeVersionIsLatest := IsDelphi5IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF BCB5}
  CnIdeVersionIsLatest := IsBCB5IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI6}
  CnIdeVersionIsLatest := IsDelphi6IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF BCB6}
  CnIdeVersionIsLatest := IsBCB6IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI7}
  CnIdeVersionIsLatest := IsDelphi7IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI8}
  CnIdeVersionIsLatest := IsDelphi8IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI2005}
  CnIdeVersionIsLatest := IsDelphi2005IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI2006}
  CnIdeVersionIsLatest := IsDelphi2006IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI2007}
  CnIdeVersionIsLatest := IsDelphi2007IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI2009}
  CnIdeVersionIsLatest := IsDelphi2009IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI2010}
  CnIdeVersionIsLatest := IsDelphi2010IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE}
  CnIdeVersionIsLatest := IsDelphiXEIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE2}
  CnIdeVersionIsLatest := IsDelphiXE2IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE3}
  CnIdeVersionIsLatest := IsDelphiXE3IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE4}
  CnIdeVersionIsLatest := IsDelphiXE4IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE5}
  CnIdeVersionIsLatest := IsDelphiXE5IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE6}
  CnIdeVersionIsLatest := IsDelphiXE6IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE7}
  CnIdeVersionIsLatest := IsDelphiXE7IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHIXE8}
  CnIdeVersionIsLatest := IsDelphiXE8IdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI10_SEATTLE}
  CnIdeVersionIsLatest := IsDelphi10SIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI101_BERLIN}
  CnIdeVersionIsLatest := IsDelphi101BIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI102_TOKYO}
  CnIdeVersionIsLatest := IsDelphi102TIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI103_RIO}
  CnIdeVersionIsLatest := IsDelphi103RIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI104_SYDNEY}
  CnIdeVersionIsLatest := IsDelphi104SIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI110_ALEXANDRIA}
  CnIdeVersionIsLatest := IsDelphi110AIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI120_ATHENS}
  CnIdeVersionIsLatest := IsDelphi120AIdeVersionLatest(LatestUpdate);
{$ENDIF}

{$IFDEF DELPHI130_FLORENCE}
  CnIdeVersionIsLatest := IsDelphi130AIdeVersionLatest(LatestUpdate);
{$ENDIF}

  Result := CnIdeVersionIsLatest;
  CnIdeVersionDetected := True;

  // ��ʼ��һЩ����ı���
  CnIsDelphi10Dot2GEDot2 := IsDelphi10Dot2GEDot2;
  CnIsDelphi10Dot4GEDot2 := IsDelphi10Dot4GEDot2;

  CnIsDelphi11GEDot3 := IsDelphi11GEDot3;
  CnIsGEDelphi11Dot3 := IsGEDelphi11Dot3;

  CnIsDelphi12Dot3GEHotFix := IsDelphi12Dot3GEHotFix;
end;

function GetIdeExeVersion: string;
var
  V: TVersionNumber;
begin
  V := GetFileVersionNumber(Application.ExeName);
  Result := Format('%d.%d.%d.%d', [V.Major, V.Minor, V.Release, V.Build]);
end;

end.
