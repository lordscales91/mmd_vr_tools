@echo off
echo Compiling AHK scripts...
del build\mmd_vr_tools\*.exe
ahk2exe /in AutoRender.ahk /out build\mmd_vr_tools\AutoRender.exe /icon icons\main_icon.ico
ahk2exe /in CameraMotionToVR.ahk /out build\mmd_vr_tools\CameraMotionToVR.exe /icon icons\camera_converter.ico