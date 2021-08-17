; Setting the compiler directives to customize the EXE properties.

;@Ahk2Exe-SetCompanyName Lordscales91
;@Ahk2Exe-SetCopyright Copyright(c) 2021
;@Ahk2Exe-SetDescription Camera Motion to VR
;@Ahk2Exe-SetVersion 0.0.1-beta
;@Ahk2Exe-SetName MMD VR Motion Converter

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

global WORKDIR_PREFIX := "workDir\"

if (A_IsCompiled) {
    WORKDIR_PREFIX := ""
}

; For now this is just a small wrapper around the Python script, eventually this could have a GUI
; to schedule several conversions to be executed in batch.

InitPhase() {
    vmdFile := ""
    if (A_Args.Length() > 0) {
        vmdFile := A_Args[1]
    } else {
        FileSelectFile, selectedFile, 1,, % "Select the motion to convert", % "VMD Motion Data (*.vmd)"
        if (ErrorLevel) {
            MsgBox, 0x10, % "Error", % "No file selected. Process aborted"
            ExitApp, -1
        } else {
            vmdFile := selectedFile
        }
    }
    if(vmdFile) {
        LaunchConverter(vmdFile)
        ExitApp
    }
}

LaunchConverter(vmdFile) {
    Random, rand1, 10000, 99999
    jobId := "cam_conversion_" . A_Now . "_" . rand1
    if (A_IsCompiled) {
        Run % A_WorkingDir "\scripts\camera_converter.exe """ vmdFile """ " jobId
    } else {
        toolsDirBash := ConvertPathToMSYS(A_WorkingDir)
        pythonScript := toolsDirBash . "/scripts/python/camera_converter.py"
        vmdFileBash := ConvertPathToMSYS(vmdFile)
        Run % "C:\msys64\usr\bin\mintty.exe /bin/env MSYSTEM=MINGW64 /bin/bash -l """ toolsDirBash "/scripts/bash/python_launcher.sh"" " pythonScript " '" vmdFileBash "' " jobId
    }
    ; Wait for it to finish
    expectedFile := A_WorkingDir . "\" . WORKDIR_PREFIX . "status\completed\" . jobId . ".main"
    while(!FileExist(expectedFile)) {
        Sleep, 200
    }
}

ConvertPathToMSYS(fpath) {
    clean := StrReplace(fpath, ":")
    fpathBash := "/" . StrReplace(clean, "\", "/")
    Return fpathBash
}

InitPhase()