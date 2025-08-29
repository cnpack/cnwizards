@ECHO OFF
CALL :CLEANFILES
DEL .\Win32\*.* /Q 2>NUL

SET TESTPROJ="TestProject.dpr"
SET ALIASFLAG="-ASysUtils=System.SysUtils;Classes=System.Classes;"

SET DCC32="C:\Program Files\Borland\Delphi5\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\01_CnUnitTest_D5.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Borland\Delphi6\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\02_CnUnitTest_D6.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Borland\Delphi7\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\03_CnUnitTest_D7.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Borland\BDS\3.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\04_CnUnitTest_D2005.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\Borland\BDS\4.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\05_CnUnitTest_D2006.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\CodeGear\RAD Studio\5.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\06_CnUnitTest_D2007.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\CodeGear\RAD Studio\6.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\07_CnUnitTest_D2009.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\Embarcadero\RAD Studio\7.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\08_CnUnitTest_D2010.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\Embarcadero\RAD Studio\8.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ%
COPY .\CnUnitTest.dcu .\Win32\09_CnUnitTest_DXE.dcu
CALL :CLEANFILES


SET DCC32="C:\Program Files\Embarcadero\RAD Studio\9.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\10_CnUnitTest_DXE2.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\RAD Studio\10.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\11_CnUnitTest_DXE3.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\RAD Studio\11.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\12_CnUnitTest_DXE4.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\RAD Studio\12.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\13_CnUnitTest_DXE5.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\14.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\14_CnUnitTest_DXE6.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\15.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\15_CnUnitTest_DXE7.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\16.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\16_CnUnitTest_DXE8.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\17.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\17_CnUnitTest_D10S.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\18.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\18_CnUnitTest_D101B.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\19.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\19_CnUnitTest_D102T.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\20.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\20_CnUnitTest_D103R.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\21.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\21_CnUnitTest_D104S.dcu
CALL :CLEANFILES

SET DCC32="C:\Program Files\Embarcadero\Studio\22.0\Bin\dcc32.exe"
%DCC32% %TESTPROJ% %ALIASFLAG%
COPY .\CnUnitTest.dcu .\Win32\22_CnUnitTest_D11A.dcu
CALL :CLEANFILES

PAUSE
EXIT

:CLEANFILES
REM ECHO CLEAN FILES
DEL *.~* 2>NUL
DEL *.dcu 2>NUL
DEL *.exe 2>NUL
GOTO :EOF