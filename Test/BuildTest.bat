@ECHO OFF
CD ..
CALL CleanInplace.bat 2> NUL
CD Test
SETLOCAL ENABLEDELAYEDEXPANSION
SET ROOTDIR=%~dp0
ECHO ROOTDIR=!ROOTDIR!
SET DCC32="C:\Program Files\Borland\Delphi5\Bin\dcc32.exe"
SET DCC7_32="C:\Program Files\Borland\Delphi7\Bin\dcc32.exe"
SET DCCR_32="C:\Program Files\Embarcadero\RAD Studio\9.0\bin\dcc32.exe"

CD %ROOTDIR%\Delphi\Program
CD
SET DPR="NOVALUE"
SET DIRNAME="NODIR"
FOR /D %%D IN (.\*) DO (
  ECHO =====================================
  ECHO Enter %%D
  CD ..\..\..
  CALL CleanInplace.bat 2> NUL
  CD Test\Delphi\Program\%%D
  SET DIRNAME=%%D
  FOR %%F IN (.\*.dpr) DO (
    SET DPR=%%F
    IF "!DPR:~-3!" == "dpr" (
      ECHO Building !DPR! with !DPR:~0,-3!cfg in !DIRNAME!
      IF "!DIRNAME:~-3!" == "_D7" (
        %DCC7_32% "%%F"
        IF !ERRORLEVEL! NEQ 0 GOTO END
      ) ELSE (
        IF "!DIRNAME:~-4!" == "_FMX" (
          %DCCR_32% "%%F"
          IF !ERRORLEVEL! NEQ 0 GOTO END
        ) ELSE (
          IF "!DIRNAME!" == ".\ParseXETemplate" (
             %DCCR_32% "%%F"
             IF !ERRORLEVEL! NEQ 0 GOTO END
          ) ELSE (
            IF "!DIRNAME!" == ".\VclToFmx" (
              %DCCR_32% "%%F" < "!DPR:~0,-3!cfg"
            ) ELSE (
              IF "!DIRNAME!" == ".\PngConvert" (
                %DCCR_32% "%%F" < "!DPR:~0,-3!cfg"
                IF !ERRORLEVEL! NEQ 0 GOTO END
              ) ELSE (
                IF "!DIRNAME:~-4!" == "110A" (
                  ECHO Skip "%%F"
                ) ELSE (
                  %DCC32% "%%F" < "!DPR:~0,-3!cfg"
                  IF !ERRORLEVEL! NEQ 0 GOTO END
                )
              )
            )
          )
        )
      )
    )
  )
  CD ..
)
ECHO Build CnPack IDE Wizards Delphi Stand Alone Test Cases Complete.
:END
CD %ROOTDIR%
PAUSE
EXIT
