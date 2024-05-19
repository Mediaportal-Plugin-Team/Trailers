@ECHO OFF
CLS

Title Creating Trailers Installer

IF "%programfiles(x86)%XXX"=="XXX" GOTO 32BIT
    :: 64-bit
    SET PROGS=%programfiles(x86)%
    GOTO CONT
:32BIT
    SET PROGS=%ProgramFiles%
:CONT

IF NOT EXIST "%PROGS%\Team MediaPortal\MediaPortal\" SET PROGS=C:

:: Get version from DLL
FOR /F "tokens=*" %%i IN ('..\Tools\Tools\sigcheck.exe /accepteula /nobanner /n "..\Trailers\bin\Release\Trailers.dll"') DO (SET version=%%i)

:: Temp xmp2 file
COPY ..\Installer\Trailers.xmp2 ..\Installer\TrailersTemp.xmp2

:: Build MPE1
CD ..\Installer
"%PROGS%\Team MediaPortal\MediaPortal\MPEMaker.exe" ..\Installer\TrailersTemp.xmp2 /B /V=%version% /UpdateXML
CD ..\build

:: Cleanup
DEL ..\Installer\TrailersTemp.xmp2
