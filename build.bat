@echo off

rem Normalize filepath
set myScriptPath=%~f0
set myPath=%myScriptPath:\build.bat=%
set myPathLetter=%myPath:~0,1%
set myPathNoLetter=%myPath:~3%

echo My Path is %myPath%
set tools_dir="%myPath%"
echo tools_dir is %tools_dir%
set tools_dir_clean=%myPath%
echo tools_dir_clean is %tools_dir_clean%
set tools_dir_bash="/%myPathLetter%/%myPathNoLetter:\=/%"
echo tools_dir_bash is %tools_dir_bash%

echo Cleaning previous build

rd /Q /S build
md build
md build\mmd_vr_tools

echo Launching python scripts compilation...
C:\msys64\usr\bin\mintty.exe /bin/env MSYSTEM=MINGW64 /bin/bash -l %tools_dir_bash%/build_python.sh %tools_dir_bash%

echo Compiling AHK scripts...

ahk2exe /in AutoRender.ahk /out build\mmd_vr_tools\AutoRender.exe /icon icons\main_icon.ico
ahk2exe /in CameraMotionToVR.ahk /out build\mmd_vr_tools\CameraMotionToVR.exe /icon icons\camera_converter.ico

echo Copying assets...
xcopy assets build /E
md build\mmd_vr_tools\data
xcopy data build\mmd_vr_tools\data /E