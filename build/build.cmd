@ECHO OFF
CLS

Title Building Trailers (RELEASE)
CD ..

REM Select program path based on current machine environment
SET progpath=%ProgramFiles%
IF NOT "%ProgramFiles(x86)%".=="". SET progpath=%ProgramFiles(x86)%

REM Define MSbuild path
SET MSBUILD_PATH=%progpath%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%progpath%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%progpath%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%progpath%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\bin\MSBuild.exe
IF NOT EXIST "%MSBUILD_PATH%" SET MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\bin\MSBuild.exe

:: Prepare version
for /f "tokens=*" %%a in ('git rev-list HEAD --count') do set REVISION=%%a 
set REVISION=%REVISION: =%
"Tools\Tools\sed.exe" -i -r "s/(Assembly(File)?Version\(.[0-9]+\.[0-9]+\.[0-9]+\.)[0-9]+(.\))/\1%REVISION%\3/g" "Trailers\Properties\AssemblyInfo.cs"

:: Build
"%MSBUILD_PATH%" /target:Rebuild /property:Configuration=RELEASE /fl /flp:logfile=Trailers.log;verbosity=diagnostic Trailers.sln

:: Revert version
git checkout "Trailers\Properties\AssemblyInfo.cs"

CD build

PAUSE
