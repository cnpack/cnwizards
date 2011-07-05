unit GetIdeVersion;

// Original Authors: Stefan Hoffmeister and Erik Berry

interface

{$I CnWizards.inc}

type
  TBorlandIdeVersion =
    (ideUndetected, ideUnknown,
     ideD300, ideD301, ideD302,
     ideD400, ideD401, ideD402, ideD403,
     ideD500, ideD501,
     ideD600, ideD601R, ideD601F, ideD602,
     ideD700, ideD71,
     ideD800, ideD801, ideD802,
     ideD900, ideD901, ideD902, ideD903,
     ideD1000, ideD1001, ideD1002,
     ideD1100, ideD1101, ideD1103,
     ideD1200,
     ideD1400,
     ideD1500,
     ideD1600,
     ideCSB100,
     ideBCB300, ideBCB301,
     ideBCB400, ideBCB401, ideBCB402,
     ideBCB500, ideBCB501,
     ideBCB600, ideBCB601, ideBCB602, ideBCB604,
     ideKylix100,
     ideKylix200,
     ideKylix300
     );

// Returns the *exact* version of the product;
//
// Note that the IDE executable and hence the IDE's reported
// version number in the about box may have not been changed.
//
// We err on the safe side, i.e. until we do not
// detect a feature of a higher version, we do
// not increment the version number to something
// higher.

function GetBorlandIdeVersion: TBorlandIdeVersion;

implementation

uses
  SysUtils, Dialogs,
  CnWizUtils, CnCommon;

var
  DetectedVersion: TBorlandIdeVersion;

// Result < 0 if V1 < V2
// Result = 0 if V1 = V2
// Result > 0 if V1 > V2
function CompareVersionNumber(const V1, V2: TVersionNumber): Integer;
begin
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


// *****************************************************
{
  Delphi 3.00:

  File          File Version  Size      Modified Time
  delphi32.exe  3.0.5.53      2027464   Monday, March 24, 1997 3:00:00 AM
  dcldb30.dpl   3.0.5.53      376320    Monday, March 24, 1997 3:00:00 AM
  dclstd30.dpl  3.0.5.53      198656    Monday, March 24, 1997 3:00:00 AM
  tlibimp.exe   [none]        276480    Monday, March 24, 1997 3:00:00 AM
  vcldb30.dcp   [none]        630696    Monday, March 24, 1997 3:00:00 AM
  vcl30.dcp     [none]        2284263   Monday, March 24, 1997 3:00:00 AM


  Delphi 3.01:

  File          File Version  Size      Modified Time
  delphi32.exe  3.0.5.83      2045888   Tuesday, August 05, 1997 3:01:00 AM
  dcldb30.dpl   3.0.5.83      381440    Tuesday, August 05, 1997 3:01:00 AM
  dclstd30.dpl  3.0.5.83      199168    Tuesday, August 05, 1997 3:01:00 AM
  tlibimp.exe   [none]        269312    Tuesday, August 05, 1997 3:01:00 AM
  scktsrvr.exe  [none]        314368    Tuesday, August 05, 1997 3:01:00 AM
  vcldb30.dcp   [none]        636049    Tuesday, August 05, 1997 3:01:00 AM
  vcl30.dcp     [none]        2288236   Tuesday, August 05, 1997 3:01:00 AM


  Delphi 3.02:

  File          File Version  Size      Modified Time
  delphi32.exe  3.0.5.83      2045888   Tuesday,  August  05, 1997 3:01:00 AM
  dcldb30.dpl   3.0.5.83      381952    Thursday, October 23, 1997 3:02:00 AM
  dclstd30.dpl  3.0.5.83      199168    Tuesday,  August  05, 1997 3:01:00 AM
  tlibimp.exe   [none]        269824    Thursday, October 23, 1997 3:02:00 AM
  scktsrvr.exe  [none]        314368    Thursday, October 23, 1997 3:02:00 AM
  vcldb30.dcp   [none]        636490    Thursday, October 23, 1997 3:02:00 AM
  vcl30.dcp     [none]        2288985   Thursday, October 23, 1997 3:02:00 AM
}
function GetDelphi3IdeVersion: TBorlandIdeVersion;
const
  Delphi32_EXE_D301: TVersionNumber =
    (Major: 3; Minor: 0; Release: 5; Build: 83);

  FileSizeDCLDB30_D302 = 381952;
var
  RootFolder: string;

  ReadFileSize: Integer;
  ReadFileVersion: TVersionNumber;
begin
  Result := ideD300;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\DCLDB30.DPL');
  if CompareVersionNumber(ReadFileVersion, Delphi32_EXE_D301) = 0 then
    Result := ideD301;

  // D3.02 can only be installed on top of D3.01
  if Result = ideD301 then
  begin
    // Try to detect D3.02; we choose to check the
    // file size of DCLDB30.DPL, because it is an
    // IDE design-time package which is handled
    // exclusively by the IDE.
    RootFolder := GetIdeRootDirectory;
    ReadFileSize := GetFileSize(RootFolder + 'Bin\DCLDB30.DPL');
    if ReadFileSize = FileSizeDCLDB30_D302 then
      Result := ideD302;
  end;
end;

{
  C++Builder 3.00:

  File          File Version  Size      Modified Time
  comp32p.dll   4.12.207.2    913498    Monday, February 9, 1998 3:00:00 AM
  ilink32.dll   3.0.0.0       266240    Monday, February 9, 1998 3:00:00 AM
  ilink32.exe   3.0.0.0       270226    Monday, February 9, 1998 3:00:00 AM


  C++Builder 3.01:

  File          File Version  Size      Modified Time
  comp32p.dll   4.12.210.2    913408    Monday, July 6, 1998 3:01:00 AM
  ilink32.dll   3.0.0.0       266752    Monday, July 6, 1998 3:01:00 AM
  ilink32.exe   3.0.0.0       270336    Monday, July 6, 1998 3:01:00 AM

  It appears as if comp32p.dll is the best detector 3.00 -> 3.01
}

function GetCppBuilder3IdeVersion: TBorlandIdeVersion;
const
  COMP32P_DLL_BCB301: TVersionNumber =
    (Major: 4; Minor: 12; Release: 210; Build: 2);
var
  ReadFileVersion: TVersionNumber;
begin
  Result := ideBCB300;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\comp32p.dll');
  if CompareVersionNumber(ReadFileVersion, COMP32P_DLL_BCB301) = 0 then
    Result := ideBCB301;
end;

{
  Delphi 4.00:

  File          File Version  Size      Modified Time
  delphi32.exe  4.0.5.37      343040    Wednesday, June 17, 1998 4:00:00 AM!
  coride40.bpl  4.0.5.25      3698176   Thursday, June 18, 1998 4:00:00 AM
  dcldb40.bpl   4.0.5.37      466944    Thursday, June 18, 1998 4:00:00 AM
  dclstd40.bpl  4.0.5.37      338944    Thursday, June 18, 1998 4:00:00 AM
  vclide40.bpl  4.0.5.25      847360    Thursday, June 18, 1998 4:00:00 AM
  dphide40.bpl  4.0.5.25      602112    Thursday, June 18, 1998 4:00:00 AM
  dbx40.bpl     4.0.0.0       847872    Thursday, June 18, 1998 4:00:00 AM
  dcc32.exe     [empty]       543232    Thursday, June 18, 1998 4:00:00 AM
  tlibimp.exe   [none]        304128    Thursday, June 18, 1998 4:00:00 AM
  scktsrvc.exe  [none]        474624    Thursday, June 18, 1998 4:00:00 AM
  sqlmon.exe    3.0           504320    Thursday, June 18, 1998 4:00:00 AM
  imagedit.exe  4.0.5.37      520192    Thursday, June 18, 1998 4:00:00 AM
  pce.exe       [none]        538624    Thursday, June 18, 1998 4:00:00 AM
  vcl40.dcp     [none]        3619257   Thursday, June 18, 1998 4:00:00 AM
  vcldb40.dcp   [none]        846752    Thursday, June 18, 1998 4:00:00 AM
  dbx40.dcp     [none]        650904    Thursday, June 18, 1998 4:00:00 AM


  Delphi 4.01 (Update #1):

  File          File Version  Size      Modified Time
  delphi32.exe  4.0.5.37      343040    Wednesday, June   17, 1998 4:00:00 AM!
  coride40.bpl  4.0.5.45      3698688   Tuesday,   August 11, 1998 4:00:00 AM
  dcldb40.bpl   4.0.5.45      466944    Tuesday,   August 11, 1998 4:00:00 AM
  dclstd40.bpl  4.0.5.37      338944    Thursday,  June   18, 1998 4:00:00 AM
  vclide40.bpl  4.0.5.25      847360    Thursday,  June   18, 1998 4:00:00 AM
  dphide40.bpl  4.0.5.25      605184    Tuesday,   August 11, 1998 4:00:00 AM
  dbx40.bpl     4.0.0.0       847872    Thursday,  June   18, 1998 4:00:00 AM
  dcc32.exe     [empty]       543232    Tuesday,   August 11, 1998 4:00:00 AM
  tlibimp.exe   [none]        304128    Tuesday,   August 11, 1998 4:00:00 AM
  scktsrvc.exe  [none]        474624    Thursday,  June   18, 1998 4:00:00 AM
  sqlmon.exe    3.0           504320    Thursday,  June   18, 1998 4:00:00 AM
  imagedit.exe  4.0.5.37      520192    Thursday,  June   18, 1998 4:00:00 AM
  pce.exe       [none]        538624    Thursday,  June   18, 1998 4:00:00 AM
  vcl40.dcp     [none]        3619304   Tuesday,   August 11, 1998 4:00:00 AM
  vcldb40.dcp   [none]        846944    Tuesday,   August 11, 1998 4:00:00 AM
  dbx40.dcp     [none]        650904    Thursday,  June   18, 1998 4:00:00 AM

  coride40.bpl looks to be the best determinant of 4.00 -> 4.01.


  Delphi 4.02 (Update #2):

  File          File Version  Size      Modified Time
  delphi32.exe  4.0.5.104     343552    Thursday, October 22, 1998 4:01:00 AM
  coride40.bpl  4.0.5.104     3706368   Thursday, October 22, 1998 4:01:00 AM
  dcldb40.bpl   4.0.5.104     466944    Thursday, October 22, 1998 4:01:00 AM
  dclstd40.bpl  4.0.5.104     339968    Thursday, October 22, 1998 4:01:00 AM
  vclide40.bpl  4.0.5.104     849408    Thursday, October 22, 1998 4:01:00 AM
  dphide40.bpl  4.0.5.104     604160    Thursday, October 22, 1998 4:01:00 AM
  dbx40.bpl     4.0.0.0       847872    Thursday, October 22, 1998 4:01:00 AM
  dcc32.exe     [empty]       545280    Thursday, October 22, 1998 4:01:00 AM
  tlibimp.exe   [none]        307200    Thursday, October 22, 1998 4:01:00 AM
  scktsrvc.exe  [none]        500736    Thursday, October 22, 1998 4:01:00 AM
  sqlmon.exe    3.0           505856    Thursday, October 22, 1998 4:01:00 AM
  imagedit.exe  4.0.5.104     521216    Thursday, October 22, 1998 4:01:00 AM
  pce.exe       [none]        540672    Thursday, October 22, 1998 4:01:00 AM
  vcl40.dcp     [none]        3622345   Thursday, October 22, 1998 4:01:00 AM
  vcldb40.dcp   [none]        847552    Thursday, October 22, 1998 4:01:00 AM
  dbx40.dcp     [none]        650915    Thursday, October 22, 1998 4:01:00 AM

  delphi32.exe looks to be the best determinant of 4.01 -> 4.02.

  NOTE: The update's registry entries we discussed in the newsgroups might not
  be changed when the second update was installed from an original 4.02 CD and
  not the Update Patch from the Internet.


  Delphi 4.03 (Update #3):

  File          File Version  Size      Modified Time
  delphi32.exe  4.0.5.108     385024    Tuesday, February 09, 1999 4:02:00 AM
  coride40.bpl  4.0.5.104     3706368   Thursday, October 22, 1998 4:01:00 AM
  dcldb40.bpl   4.0.5.104     466944    Thursday, October 22, 1998 4:01:00 AM
  dclstd40.bpl  4.0.5.108     339968    Tuesday, February 09, 1999 4:02:00 AM
  vclide40.bpl  4.0.5.104     849408    Thursday, October 22, 1998 4:01:00 AM
  dphide40.bpl  4.0.5.104     604160    Thursday, October 22, 1998 4:01:00 AM
  dbx40.bpl     4.0.0.0       847872    Thursday, October 22, 1998 4:01:00 AM
  dcc32.exe     [empty]       545280    Thursday, October 22, 1998 4:01:00 AM
  tlibimp.exe   [none]        307200    Thursday, October 22, 1998 4:01:00 AM
  scktsrvc.exe  [none]        500224    Wednesday,January 27, 1999 4:00:00 AM!
  sqlmon.exe    3.0           505856    Thursday, October 22, 1998 4:01:00 AM
  imagedit.exe  4.0.5.104     521216    Thursday, October 22, 1998 4:01:00 AM
  pce.exe       [none]        540672    Thursday, October 22, 1998 4:01:00 AM
  vcl40.dcp     [none]        3622200   Wednesday,February 17,1999 4:02:00 AM
  vcldb40.dcp   [none]        847552    Thursday, October 22, 1998 4:01:00 AM
  dbx40.dcp     [none]        650915    Thursday, October 22, 1998 4:01:00 AM

  delphi32.exe looks to be the best determinant of 4.02 -> 4.03.
}
function GetDelphi4IdeVersion: TBorlandIdeVersion;
const
  CORIDE40_BPL_D401: TVersionNumber =
    (Major: 4; Minor: 0; Release: 5; Build: 45);

  DELPHI32_EXE_D402: TVersionNumber =
    (Major: 4; Minor: 0; Release: 5; Build: 104);

  DELPHI32_EXE_D403: TVersionNumber =
    (Major: 4; Minor: 0; Release: 5; Build: 108);
var
  ReadFileVersion: TVersionNumber;
begin
  Result := ideD400;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\CORIDE40.BPL');
  if CompareVersionNumber(ReadFileVersion, CORIDE40_BPL_D401) = 0 then
  begin
    Result := ideD401;
    Exit;
  end;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\DELPHI32.EXE');
  if CompareVersionNumber(ReadFileVersion, DELPHI32_EXE_D402) = 0 then
  begin
    Result := ideD402;
    Exit;
  end;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\DELPHI32.EXE');
  if CompareVersionNumber(ReadFileVersion, DELPHI32_EXE_D403) = 0 then
    Result := ideD403;
end;

{
  C++Builder 4.00:

  File          File Version  Size      Modified Time
  bcb.exe       4.0.14.4      508928    Wednesday, January 27, 1999 4:00:00 AM
  comp32p.dll   4.12.210.2    1044480   Wednesday, January 27, 1999 4:00:00 AM
  ilink32.dll   4.0.10.23     274432    Wednesday, January 27, 1999 4:00:00 AM


  C++Builder 4.01:

  File          File Version  Size      Modified Time
  bcb.exe       4.0.14.11     508928    Tuesday, June 1, 1999 4:01:00 AM
  comp32p.dll   4.12.210.2    1044480   Tuesday, June 1, 1999 4:01:00 AM
  ilink32.dll   4.0.10.26     274432    Tuesday, June 1, 1999 4:01:00 AM

  It appears as if bcb.exe is the best detector 4.00 -> 4.01


  C++Builder 4.02:

  File          File Version  Size      Modified Time
  bcb.exe       4.0.14.11     508928    Tuesday, June 1, 1999 4:01:00 AM
  comp32p.dll   4.12.210.2    1044480   Friday, October 15, 1999 4:02:00 AM
  ilink32.dll   4.0.10.26     274432    Tuesday, June 1, 1999 4:01:00 AM

  It appears as if the ONLY way to detect 4.02 is to have a look
  at the time-stamp of comp32p.dll (only bcc32.exe, comp32p.dll,
  cpp32.exe were changed)
}

function GetCppBuilder4IdeVersion: TBorlandIdeVersion;
const
  BCB_EXE_BCB401: TVersionNumber =
    (Major: 4; Minor: 0; Release: 11; Build: 14);
var
  ReadFileVersion: TVersionNumber;
  PatchedFileTimeStamp: TDateTime;
  Difference: Integer;
begin
  Result := ideBCB400;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\BCB.EXE');
  if CompareVersionNumber(ReadFileVersion, BCB_EXE_BCB401) = 0 then
    Result := ideBCB401;

  // BCB4.02 was not a "full patch", but incremental:
  if Result = ideBCB401 then
  begin
    PatchedFileTimeStamp := EncodeDate(1999, 10, 15);
    PatchedFileTimeStamp := PatchedFileTimeStamp + EncodeTime(04, 02, 0, 0); // 4:02:00 am

    Difference := FileAge(GetIdeRootDirectory + 'Bin\COMP32P.DLL') -
                  DateTimeToFileDate(PatchedFileTimeStamp);

    if Difference = 0 then
    begin
      Result := ideBCB402;
    end;
  end;
end;

{
  Delphi 5.00:

  File          File Version  Size      Modified Time
  coride50.bpl  5.0.5.62      3779072   Wednesday, August 11, 1999 5:00:00 AM
  Dsnide50.bpl  5.0.5.62      750592    Wednesday, August 11, 1999 5:00:00 AM
  Dphide50.bpl  5.0.5.62      409600    Wednesday, August 11, 1999 5:00:00 AM
  Vclide50.bpl  5.0.5.62      863232    Wednesday, August 11, 1999 5:00:00 AM

  Delphi 5.01:

  coride40.bpl  5.0.6.18      3780096   Monday, January 24, 2000 5:01:00 AM
  Dsnide50.bpl  5.0.6.18      760320    Monday, January 24, 2000 5:01:00 AM
  Dphide50.bpl  5.0.6.18      410112    Monday, January 24, 2000 5:01:00 AM
  Vclide50.bpl  5.0.6.18      863232    Monday, January 24, 2000 5:01:00 AM
  delphi32.exe  5.0.6.18      424960    Monday, January 24, 2000 5:01:00 AM
}

function GetDelphi5IdeVersion: TBorlandIdeVersion;
const
  Delphi32_EXE_D500: TVersionNumber =
    (Major: 5; Minor: 0; Release: 5; Build: 68);
var
  ReadFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD500;

  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\DELPHI32.EXE');
  VersionNumber := CompareVersionNumber(ReadFileVersion, Delphi32_EXE_D500);
  if VersionNumber > 0 then
    Result := ideD501;
end;

{
  C++Builder 5.00:

  File          File Version  Size      Modified Time
  bcc32.exe     5.0.12.34     866304    Monday, January 31, 2000 5:00:00 AM
  bordbg51.exe  5.0.12.34     219136    Monday, January 31, 2000 5:00:00 AM
  cgconfig.exe  5.0.12.34     571392    Monday, January 31, 2000 5:00:00 AM
  dsnide50.bpl  5.0.12.34     760832    Monday, January 31, 2000 5:00:00 AM
  bcb.exe       5.0.12.34     954368    Monday, January 31, 2000 5:00:00 AM
  bcbide50.bpl  5.0.12.34     1121792   Monday, January 31, 2000 5:00:00 AM
  coride50.bpl  5.0.12.34     3883008   Monday, January 31, 2000 5:00:00 AM

  C++Builder 5.01:

  File          File Version  Size      Modified Time
  bcc32.exe     5.5.1.1       869376    Monday, August 07, 2000, 5:01:00 AM
  bordbg51.exe  5.0.12.34     219136    Monday, January 31, 2000 5:00:00 AM
  cgconfig.exe  5.0.12.34     571392    Monday, January 31, 2000 5:00:00 AM
  dsnide50.bpl  5.0.12.34     760832    Monday, January 31, 2000 5:00:00 AM
  bcb.exe       5.0.12.34     954368    Monday, January 31, 2000 5:00:00 AM
  bcbide50.bpl  5.0.12.34     1121792   Monday, January 31, 2000 5:00:00 AM
  coride50.bpl  5.0.12.34     3883008   Monday, January 31, 2000 5:00:00 AM
  tlibimp.exe   5.0.12.34(!)  23040     Monday, August 07, 2000, 5:01:00 AM
  tlib50.bpl    5.0.12.34(!)  589312    Monday, August 07, 2000, 5:01:00 AM
  ilink32.exe   5.0.1.1       326144    Monday, August 07, 2000, 5:01:00 AM
}

function GetCppBuilder5IdeVersion: TBorlandIdeVersion;
const
  BCC32_EXE_BCB500: TVersionNumber =
    (Major: 5; Minor: 0; Release: 12; Build: 34);
var
  ReadFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideBCB500;
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\BCC32.EXE');
  VersionNumber := CompareVersionNumber(ReadFileVersion, BCC32_EXE_BCB500);
  if VersionNumber > 0 then
    Result := ideBCB501;
end;

{
  Delphi 6.00:

  File            File Version  Size      Modified Time
  delphide60.bpl  6.0.6.142     409,600   Thursday, May 17, 2001, 2:46:06 PM (?)
  vclide60.bpl    6.0.6.142     697,344   Thursday, May 17, 2001, 2:46:22 PM (?)
  designide60.bpl 6.0.6.142     702,976   Thursday, May 17, 2001, 2:46:06 PM (?)
  coreide60.bpl   6.0.6.142     3,074,560 Thursday, May 17, 2001, 2:45:56 PM (?)
  DCC60.DLL       6.0.6.142     867,840   Thursday, May 17, 2001, 2:45:58 PM (?)
  delphi32.exe    6.0.6.142     473,088   Thursday, May 17, 2001, 2:46:06 PM (?)

  Delphi 6.01 (recalled release):

  File            File Version  Size      Modified Time
  delphide60.bpl  6.0.6.189     3,065,344 Thursday, September 06, 2001, 6:01:00 AM
  vclide60.bpl    6.0.6.163     696,832   Tuesday, May 22, 2001, 1:00:00 AM (?)
  designide60.bpl 6.0.6.163     701,440   Tuesday, May 22, 2001, 1:00:00 AM (?)
  coreide60.bpl   6.0.6.189     3,065,344 Thursday, September 06, 2001, 6:01:00 AM
  DCC60.DLL       6.0.6.189     792,064   Thursday, September 06, 2001, 6:01:00 AM
  delphi32.exe    6.0.6.189     472,064   Thursday, September 06, 2001, 6:01:00 AM

  Delphi 6.01 (final release):

  File            File Version  Size      Modified Time
  delphide60.bpl  6.0.6.163(!)  409,088   Tuesday, May 22, 2001, 12:00:00 AM
  vclide60.bpl    6.0.6.163     696,832   Tuesday, May 22, 2001, 12:00:00 AM
  designide60.bpl 6.0.6.163     701,440   Tuesday, May 22, 2001, 12:00:00 AM
  coreide60.bpl   6.0.6.190     3,065,344 Thursday, September 27, 2001, 5:01:00 AM
  DCC60.DLL       6.0.6.190     792,064   Thursday, September 27, 2001, 5:01:00 AM
  delphi32.exe    6.0.6.190     472,064   Thursday, September 27, 2001, 5:01:00 AM

  Delphi 6.02:
  File            File Version  Size      Modified Time
  delphide60.bpl  6.0.6.240     409,600   Friday, February 15, 2002, 2:02:00 PM
  vclide60.bpl    6.0.6.163     696,832   Tuesday, May 22, 2001, 12:00:00 AM
  designide60.bpl 6.0.6.163     701,440   Tuesday, May 22, 2001, 12:00:00 AM
  coreide60.bpl   6.0.6.240     3,065,344 Friday, February 15, 2002, 2:02:00 PM
  DCC60.DLL       6.0.6.240     707,584   Friday, February 15, 2002, 2:02:00 PM
  delphi32.exe    6.0.6.240     472,064   Friday, February 15, 2002, 2:02:00 PM
}

function GetDelphi6IdeVersion: TBorlandIdeVersion;
const
  CoreIdeD600: TVersionNumber =
    (Major: 6; Minor: 0; Release: 6; Build: 142);
  CoreIdeD601R: TVersionNumber =
    (Major: 6; Minor: 0; Release: 6; Build: 189);
  CoreIdeD601F: TVersionNumber =
    (Major: 6; Minor: 0; Release: 6; Build: 190);
var
  ReadFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD600;
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide60.bpl');
  VersionNumber := CompareVersionNumber(ReadFileVersion, CoreIdeD600);
  if VersionNumber > 0 then
    Result := ideD601R;
  VersionNumber := CompareVersionNumber(ReadFileVersion, CoreIdeD601R);
  if VersionNumber > 0 then
    Result := ideD601F;
  VersionNumber := CompareVersionNumber(ReadFileVersion, CoreIdeD601F);
  if VersionNumber > 0 then
    Result := ideD602;
end;

{
  C++Builder 6.00:

  File            File Version  Size      Modified Time
  designide60.bpl 6.0.10.157    706,560   Saturday, February 02, 2002, 1:00:00 AM
  coreide60.bpl   6.0.10.157    3,158,016 Saturday, February 02, 2002, 1:00:00 AM
  bcb.exe         6.0.10.157    732,672   Friday, February 01, 2002, 2:00:00 PM
  bcc32.exe       5.6.0.0       1,394,688 Saturday, February 02, 2002, 1:00:00 AM
  dcc60.dll       6.0.10.157    797,696   Saturday, February 02, 2002, 1:00:00 AM
  bcbide60.bpl    6.0.10.157    974,848   Saturday, February 02, 2002, 12:00:00 AM

  C++Builder 6.01:

  File            File Version  Size      Modified Time
  designide60.bpl 6.0.10.157   706,560 Saturday, February 02, 2002, 1:00:00 AM
  dcc60.dll       6.0.10.157   797,696 Saturday, February 02, 2002, 1:00:00 AM
  bcb.exe         6.0.10.161   732,672 Friday, February 01, 2002, 2:00:00 PM
  coreide60.bpl   6.0.10.157 3,158,016 Saturday, February 02, 2002, 1:00:00 AM
  bcc32.exe       5.6.0.0    1,394,688 Saturday, February 02, 2002, 1:00:00 AM
  bcbide60.bpl    6.0.10.161   974,848 Friday, February 01, 2002, 2:00:00 PM

  C++Builder 6.02:

  File            File Version  Size      Modified Time
  designide60.bpl 6.0.10.157   706,560 Saturday, February 02, 2002, 1:00:00 AM
  dcc60.dll       6.0.10.157   797,696 Saturday, February 02, 2002, 1:00:00 AM
  bcb.exe         6.0.10.165   732,672 Thursday, July 11, 2002, 6:02:00 AM
  coreide60.bpl   6.0.10.165 3,158,016 Thursday, July 11, 2002, 6:02:00 AM
  bcc32.exe       5.6.1.0    1,397,760 Thursday, July 11, 2002, 6:02:00 AM
  bcbide60.bpl    6.0.10.165   974,848 Thursday, July 11, 2002, 6:02:00 AM

  (C++Builder 6.03 was a semi-private beta release)

  C++Builder 6.04:

  File            File Version  Size      Modified Time
  designide60.bpl 6.0.10.166   706,560 Thursday, January 30, 2003, 6:04:00 AM
  dcc60.dll       6.0.10.155   797,696 Wednesday, January 30, 2002, 5:38:44 PM
  bcb.exe         6.0.10.166   732,672 Thursday, January 30, 2003, 6:04:00 AM
  coreide60.bpl   6.0.10.166 3,158,016 Thursday, January 30, 2003, 6:04:00 AM
  bcc32.exe       5.6.4.0    1,398,272 Thursday, January 30, 2003, 6:04:00 AM
  bcbide60.bpl    6.0.10.166   975,872 Thursday, January 30, 2003, 6:04:00 AM
}

function GetCppBuilder6IdeVersion: TBorlandIdeVersion;
const
  BcbExe600: TVersionNumber =
    (Major: 6; Minor: 0; Release: 10; Build: 157);
  BcbExe601: TVersionNumber =
    (Major: 6; Minor: 0; Release: 10; Build: 161);
  BcbExe602: TVersionNumber =
    (Major: 6; Minor: 0; Release: 10; Build: 165);
var
  ReadFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideBCB600;
  ReadFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\bcb.exe');
  VersionNumber := CompareVersionNumber(ReadFileVersion, BcbExe600);
  if VersionNumber > 0 then
    Result := ideBCB601;
  VersionNumber := CompareVersionNumber(ReadFileVersion, BcbExe601);
  if VersionNumber > 0 then
    Result := ideBCB602;
  VersionNumber := CompareVersionNumber(ReadFileVersion, BcbExe602);
  if VersionNumber > 0 then
    Result := ideBCB604;
end;

{
  Delphi 7.00:

  File            File Version  Size      Modified Time
  delphide70.bpl  7.0.4.453    473,088    Friday, August 09, 2002, 8:00:00 AM
  vclide70.bpl    7.0.4.453    708,608    Friday, August 09, 2002, 8:00:00 AM
  designide70.bpl 7.0.4.453    625,152    Friday, August 09, 2002, 8:00:00 AM
  coreide70.bpl   7.0.4.453  3,180,544    Friday, August 09, 2002, 8:00:00 AM
  DCC70.DLL       7.0.4.453    841,216    Friday, August 09, 2002, 8:00:00 AM
  delphi32.exe    7.0.4.453    545,792    Friday, August 09, 2002, 1:00:00 PM

  Delphi 7.1:

  File            File Version  Size      Modified Time
  delphide70.bpl  7.0.4.453    473,088    Friday, August 09, 2002, 9:00:00 AM
  vclide70.bpl    7.0.4.453    708,608    Friday, August 09, 2002, 9:00:00 AM
  designide70.bpl 7.0.8.1      625,664    Friday, April 23, 2004, 9:01:00 AM
  coreide70.bpl   7.0.8.1    3,186,688    Friday, April 23, 2004, 9:01:00 AM
  DCC70.DLL       7.0.8.1      843,264    Friday, April 23, 2004, 9:01:00 AM
  delphi32.exe    7.0.8.1      545,792    Friday, April 23, 2004, 9:01:00 AM
}
function GetDelphi7IdeVersion: TBorlandIdeVersion;
const
  CoreIDE700: TVersionNumber =
    (Major: 7; Minor: 0; Release: 4; Build: 453);
var
  ReadFileVersion: TVersionNumber;
  VersionNumber: Integer;
  CoreIdeFile: string;
begin
  Result := ideD700;
  CoreIdeFile := GetIdeRootDirectory + 'Bin\coreide70.bpl';
  if FileExists(CoreIdeFile) then begin
    ReadFileVersion := GetFileVersionNumber(CoreIdeFile);
    VersionNumber := CompareVersionNumber(ReadFileVersion, CoreIDE700);
    if VersionNumber > 0 then
      Result := ideD71;
  end;
end;

function GetCSharpBuilder1Version: TBorlandIdeVersion;
begin
  Result := ideCSB100;
end;

{
  Delphi 8.00:

  File                 File Version   Size       Modified Time
  delphicoreide71.bpl 7.1.1446.610   1,228,800  Wednesday, December 17, 2003, 10:00:00 AM
  vclide71.bpl        7.1.1446.610     921,088  Wednesday, December 17, 2003, 10:00:00 AM
  designide71.bpl     7.1.1446.610     677,376  Wednesday, December 17, 2003, 10:00:00 AM
  coreide71.bpl       7.1.1446.610   2,793,984  Wednesday, December 17, 2003, 10:00:00 AM
  DCC71.DLL           7.1.1446.610     922,112  Wednesday, December 17, 2003, 10:00:00 AM
  bds.exe             7.1.1446.610   1,092,608  Wednesday, December 17, 2003, 10:00:00 AM
  Studio.Host.dll     7.1.1446.610     684,032  Wednesday, December 17, 2003, 10:00:00 AM
  bordbk71.dll        50.4.228.1       718,848  Wednesday, December 17, 2003, 10:00:00 AM

  Delphi 8.01:
  delphicoreide71.bpl
  vclide71.bpl
  designide71.bpl
  coreide71.bpl
  DCC71.DLL           7.1.1490.25464
  bds.exe
  Studio.Host.dll
  bordbk71.dll        50.4.228.2

  Delphi 8.02:
  delphicoreide71.bpl 7.1.1523.17956 1,231,360  Friday, February 27, 2004, 10:02:00 AM
  vclide71.bpl        7.1.1523.17956   921,600  Friday, February 27, 2004, 10:02:00 AM
  designide71.bpl     7.1.1523.17956   678,912  Friday, February 27, 2004, 10:02:00 AM
  coreide71.bpl       7.1.1523.17956 2,797,568  Friday, February 27, 2004, 10:02:00 AM
  DCC71.DLL           7.1.1523.17956   923,136  Friday, February 27, 2004, 10:02:00 AM
  bds.exe             7.1.1523.17956 1,092,608  Friday, February 27, 2004, 10:02:00 AM
  B.Studio.Host.dll   7.1.1523.17956   688,128  Friday, February 27, 2004, 10:02:00 AM
}
function GetDelphi8Version: TBorlandIdeVersion;
const
  Dcc800: TVersionNumber =
    (Major: 7; Minor: 1; Release: 1446; Build: 610);
  Dcc801: TVersionNumber =
    (Major: 7; Minor: 1; Release: 1490; Build: 25464);
  BdsExe800: TVersionNumber =
    (Major: 7; Minor: 1; Release: 1446; Build: 610);
var
  DccFileVersion: TVersionNumber;
  BdsFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD800;
  DccFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\DCC71.DLL');
  VersionNumber := CompareVersionNumber(DccFileVersion, Dcc800);
  if VersionNumber > 0 then begin
    Result := ideD801;
    BdsFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\bds.exe');
    VersionNumber := CompareVersionNumber(BdsFileVersion, BdsExe800);
    if VersionNumber > 0 then
      Result := ideD802;
  end;
end;

{
  Delphi 9.00 (2005):

  File                 File Version   Size       Modified Time
  delphicoreide9.bpl   9.0.1761.24408 2,891,264  Friday, October 22, 2004, 10:00:00 AM
  vclide9.bpl          9.0.1761.24408 1,255,936  Friday, October 22, 2004, 10:00:00 AM
  designide9.bpl       9.0.1761.24408 749,056    Friday, October 22, 2004, 10:00:00 AM
  coreide9.bpl         9.0.1761.24408 3,367,936  Friday, October 22, 2004, 10:00:00 AM
  DCC90.DLL            9.0.1761.24408 987,136    Friday, October 22, 2004, 10:00:00 AM
  bds.exe              9.0.1761.24408 916,992    Friday, October 22, 2004, 10:00:00 AM
  B.Studio.Host.dll    9.0.1761.24408 688,128    Friday, October 22, 2004, 10:00:00 AM
  bordbk9.dll          90.1.1.1       779,264    Friday, October 22, 2004, 10:00:00 AM

  Delphi 9.01 (2005 Update 1):

  File                 File Version   Size       Modified Time
  delphicoreide9.bpl   9.0.1810.11291 2,891,776  Thursday, December 09, 2004, 9:01:00 AM
  vclide9.bpl          9.0.1761.24408 1,255,936  Friday, October 22, 2004, 10:00:00 AM
  designide9.bpl       9.0.1810.11291 749,568    Thursday, December 09, 2004, 9:01:00 AM
  coreide9.bpl         9.0.1810.11291 3,369,472  Thursday, December 09, 2004, 9:01:00 AM
  DCC90.DLL            9.0.1810.11291 988,672    Thursday, December 09, 2004, 9:01:00 AM
  bds.exe              9.0.1761.24408 916,992    Thursday, December 09, 2004, 9:01:00 AM
  B.Studio.Host.dll    9.0.1810.11291 688,128    Thursday, December 09, 2004, 9:01:00 AM
  bordbk9.dll          90.1.2.1       782,336    Thursday, December 09, 2004, 9:01:00 AM

  Delphi 9.03 (2005 Update 3):

  File                 File Version   Size       Modified Time
  delphicoreide9.bpl   9.0.1882.30496 2,899,968  Friday, March 04, 2005, 12:02:00 PM
  vclide9.bpl          9.0.1882.30496 1,255,936  Friday, March 04, 2005, 12:02:00 PM
  designide9.bpl       9.0.1935.22056 750,080    Tuesday, April 19, 2005, 11:03:00 AM
  coreide9.bpl         9.0.1935.22056 3,372,544  Tuesday, April 19, 2005, 11:03:00 AM
  DCC90.DLL            9.0.1882.30496 989,184    Friday, March 04, 2005, 12:02:00 PM
  bds.exe              9.0.1935.22056 917,504    Tuesday, April 19, 2005, 11:03:00 AM
  B.Studio.Host.dll    9.0.1882.30496 688,128    Friday, March 04, 2005, 12:02:00 PM
  bordbk9.dll          90.1.3.1       784,896    Friday, March 04, 2005, 12:02:00 PM
}
function GetDelphi9Version: TBorlandIdeVersion;
const
  CoreIde900: TVersionNumber =
    (Major: 9; Minor: 0; Release: 1761; Build: 24408);
  CoreIde901: TVersionNumber =
    (Major: 9; Minor: 0; Release: 1810; Build: 11291);
  CoreIde903: TVersionNumber =
    (Major: 9; Minor: 0; Release: 1935; Build: 22056);
var
  CoreIdeFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD900;
  CoreIdeFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide90.bpl');
  VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde900);
  if VersionNumber > 0 then
  begin
    Result := ideD901;
    VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde901);
    if VersionNumber > 0 then
    begin
      Result := ideD902;
      VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde903);
      if VersionNumber >= 0 then
        Result := ideD903;
    end;
  end;
end;

function GetDelphi10Version: TBorlandIdeVersion;
const
  CoreIde1000: TVersionNumber =
    (Major: 10; Minor: 0; Release: 0; Build: 0);
  CoreIde1001: TVersionNumber =
    (Major: 10; Minor: 0; Release: 2166; Build: 28377);
  CoreIde1002: TVersionNumber =
    (Major: 10; Minor: 0; Release: 2288; Build: 42451);
var
  CoreIdeFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD1000;
  CoreIdeFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde1001);
  if VersionNumber >= 0 then begin
    Result := ideD1001;
    VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde1002);
    if VersionNumber >= 0 then
      Result := ideD1002;
  end;
end;

function GetDelphi11Version: TBorlandIdeVersion;
const
  CoreIde1100: TVersionNumber =
    (Major: 11; Minor: 0; Release: 2627; Build: 5503);
  CoreIde1101: TVersionNumber =
    (Major: 11; Minor: 0; Release: 2709; Build: 7128);
  CoreIde1103: TVersionNumber =
    (Major: 11; Minor: 0; Release: 2804; Build: 9245);    
var
  CoreIdeFileVersion: TVersionNumber;
  VersionNumber: Integer;
begin
  Result := ideD1100;
  CoreIdeFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide100.bpl');
  VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde1101);
  if VersionNumber >= 0 then begin
    // Result := ideD1101; // 不判断 Update 包了。
  end;
end;

function GetDelphi12Version: TBorlandIdeVersion;
const
  CoreIde1200: TVersionNumber =
    (Major: 12; Minor: 0; Release: 0; Build: 0);
//var
//  CoreIdeFileVersion: TVersionNumber;
//  VersionNumber: Integer;
begin
  Result := ideD1200;
//  CoreIdeFileVersion := GetFileVersionNumber(GetIdeRootDirectory + 'Bin\coreide120.bpl');
//  VersionNumber := CompareVersionNumber(CoreIdeFileVersion, CoreIde1101);
//  if VersionNumber >= 0 then begin
    // Result := ideD1200; // 不判断 Update 包了。
//  end;
end;

function GetDelphi14Version: TBorlandIdeVersion;
const
  CoreIde1400: TVersionNumber =
    (Major: 14; Minor: 0; Release: 0; Build: 0);
begin
  Result := ideD1400;
end;

function GetDelphi15Version: TBorlandIdeVersion;
const
  CoreIde1500: TVersionNumber =
    (Major: 15; Minor: 0; Release: 0; Build: 0);
begin
  Result := ideD1500;
end;

function GetDelphi16Version: TBorlandIdeVersion;
const
  CoreIde1600: TVersionNumber =
    (Major: 16; Minor: 0; Release: 0; Build: 0);
begin
  Result := ideD1600;
end;

function GetBorlandIdeVersion: TBorlandIdeVersion;
begin
  // We only actually detect the version once per session.
  // The previous result is cached in DetectedVersion.
  if DetectedVersion <> ideUndetected then
  begin
    Result := DetectedVersion;
    Exit;
  end;

  {$IFDEF VER100} // Delphi 3.0
    Result := GetDelphi3IdeVersion;
    Assert(Result in [ideD300, ideD301, ide302]);
  {$ENDIF VER100}

  {$IFDEF VER110}  // C++Builder 3.0
    Result := GetCppBuilder3IdeVersion;
    Assert(Result in [ideBCB300, ideBCB301]);
  {$ENDIF VER110}

  {$IFDEF VER120}  // Delphi 4.0
    Result := GetDelphi4IdeVersion;
    Assert(Result in [ideD400, ideD401, ideD402, ideD403]);
  {$ENDIF VER120}

  {$IFDEF VER125}  // C++Builder 4.0
    Result := GetCppBuilder4IdeVersion;
    Assert(Result in [ideBCB400, ideBCB401]);
  {$ENDIF VER125}

  {$IFDEF VER130}  // Delphi 5.0 and C++Builder 5.0
    {$IFDEF BCB}
      Result := GetCppBuilder5IdeVersion;
      Assert(Result in [ideBCB500, ideBCB501]);
    {$ELSE not BCB}
      Result := GetDelphi5IdeVersion;
      Assert(Result in [ideD500, ideD501]);
    {$ENDIF BCB}
  {$ENDIF VER130}

  {$IFDEF VER140}  // Delphi 6.0 and C++Builder 6.0
    {$IFDEF BCB}
      Result := GetCppBuilder6IdeVersion;
      Assert(Result in [ideBCB600, ideBCB601, ideBCB602, ideBCB604]);
    {$ELSE not BCB}
      {$IFDEF LINUX}
        {$IF System.RTLVersion > 14.0 }
          {$IF System.RTLVersion >= 14.5 }
            Result := ideKylix300;
          {$ELSE}
            Result := ideKylix200;
          {$IFEND}
        {$ELSE}
          Result := ideKylix100;
        {$IFEND}
      {$ELSE}
        Result := GetDelphi6IdeVersion;
        Assert(Result in [ideD600, ideD601R, ideD601F, ideD602]);
      {$ENDIF}
    {$ENDIF BCB}
  {$ENDIF VER140}

  {$IFDEF VER150}  // Delphi 7.0 and C++Builder 7.0
    Result := GetDelphi7IdeVersion;
    Assert(Result in [ideD700, ideD71]);
  {$ENDIF VER150}

  {$IFDEF VER160}  // Delphi 8 and C#Builder 1.0
    Result := GetDelphi8Version;
    Assert(Result in [ideD800, ideD801, ideD802, ideCSB100]);
  {$ENDIF VER160}

  {$IFDEF VER170}  // Delphi 9 (2005)
    Result := GetDelphi9Version;
    Assert(Result in [ideD900, ideD901, ideD902, ideD903]);
  {$ENDIF VER170}

  {$IFDEF VER180}  // Delphi 10 (2006)
    Result := GetDelphi10Version;
    Assert(Result in [ideD1000, ideD1001, ideD1002]);
  {$ENDIF VER180}

  {$IFDEF VER185}  // Delphi 11 (2007)
    Result := GetDelphi11Version;
    Assert(Result in [ideD1100, ideD1101]);
  {$ENDIF VER185}

  {$IFDEF VER200}  // Delphi 12 (2009)
    Result := GetDelphi12Version;
    Assert(Result in [ideD1200]);
  {$ENDIF VER200}

  {$IFDEF VER210}  // Delphi 14 (2010)
    Result := GetDelphi14Version;
    Assert(Result in [ideD1400]);
  {$ENDIF VER210}

  {$IFDEF VER220}  // Delphi 15 (2011)
    Result := GetDelphi15Version;
    Assert(Result in [ideD1500]);
  {$ENDIF}

  {$IFDEF VER230}  // Delphi 16 (2012)
    Result := GetDelphi16Version;
    Assert(Result in [ideD1600]);
  {$ENDIF}

  if Result = ideUnknown then
    MessageDlg('Unknown IDE major version detected.  Please update This File.', mtError, [mbOK], 0);

  DetectedVersion := Result;
end;

initialization
  DetectedVersion := ideUndetected;

end.

