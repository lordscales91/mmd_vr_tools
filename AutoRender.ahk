; Setting the compiler directives to customize the EXE properties.

;@Ahk2Exe-SetCompanyName Lordscales91
;@Ahk2Exe-SetCopyright Copyright(c) 2021
;@Ahk2Exe-SetDescription MMD VR AutoRender
;@Ahk2Exe-SetVersion 0.0.1-beta
;@Ahk2Exe-SetName MMD VR AutoRender

#Include DataModel.ahk
#SingleInstance, force
SetWorkingDir, %A_ScriptDir%
SetControlDelay, 100

global VR_180_MODE := 1
global VR_360_MODE := 2

global VR_SIDE_LEFT = "L"
global VR_SIDE_RIGHT = "R"
global VR_SIDE_TOP = "T"
global VR_SIDE_BOTTOM = "B"
global VR_SIDE_FRONT = "F"

global EYE_LEFT = "L"
global EYE_RIGHT = "R"

global userPreferencesFile := "preferences.ini"
global userPrefs := ""

InitPhase() {
    userPrefs := GetOrCreateUserPreferences()
    jobs := GetPendingJobs()
    if(jobs.Count()) {
        if(jobs[1].jobStatus == JobData.STATUS_PROCESSING) {
            MsgBox, 0x24, % "Confimation", % "A previous Job couldn't finish`nDo you want to resume it?"
            IfMsgBox, Yes 
            {
                StartMMDPhase(jobs[1])
            } else {
                StartMMDPhase()
            }
        }
    } else {
        StartMMDPhase()
    }
}

ReadUserPreferences() {
    IniRead, MMDExecutable, %userPreferencesFile%, General, MMDExecutable
    IniRead, deleteStagingFiles, %userPreferencesFile%, General, deleteStagingFiles, 0

    IniRead, fps, %userPreferencesFile%, Render, fps, 60
    IniRead, renderCodec, %userPreferencesFile%, Render, renderCodec, % "ffdshow video encoder"

    IniRead, finalEncodingFormat, %userPreferencesFile%, Encoding, finalEncodingFormat, % "MP4"
    IniRead, finalEncodingQuality, %userPreferencesFile%, Encoding, finalEncodingQuality, % "medium"
    IniRead, finalVideoOutDir, %userPreferencesFile%, Encoding, finalVideoOutDir, % ""

    prefs := new UserPreferences
    prefs.MMDExecutable := MMDExecutable
    prefs.deleteStagingFiles := deleteStagingFiles
    prefs.fps := fps
    prefs.renderCodec := renderCodec
    prefs.finalEncodingFormat := finalEncodingFormat
    prefs.finalEncodingQuality := finalEncodingQuality
    prefs.finalVideoOutDir := finalVideoOutDir
    Return prefs
}

WriteUserPreferences(prefs) {
    IniWrite % prefs.MMDExecutable, %userPreferencesFile%, General, MMDExecutable
    IniWrite % prefs.deleteStagingFiles, %userPreferencesFile%, General, deleteStagingFiles

    IniWrite % prefs.fps, %userPreferencesFile%, Render, fps
    IniWrite % prefs.renderCodec, %userPreferencesFile%, Render, renderCodec

    IniWrite % prefs.finalEncodingFormat, %userPreferencesFile%, Encoding, finalEncodingFormat
    IniWrite % prefs.finalEncodingQuality, %userPreferencesFile%, Encoding, finalEncodingQuality
    IniWrite % prefs.finalVideoOutDir, %userPreferencesFile%, Encoding, finalVideoOutDir
}

GetOrCreateUserPreferences() {
    prefs := new UserPreferences
    if (InStr(FileExist(userPreferencesFile), "A")) {
        prefs := ReadUserPreferences()
    } else {
        prefs.finalVideoOutDir := DetermineDefaultOutputDir()
        WriteUserPreferences(prefs)
    }
    Return prefs
}

GetPendingJobs() {
    jobs := []
    ; first take a look at the jobs started but never finished
    Loop, Files, % "status\processing\*.main" 
    {
        if(RegExMatch(A_LoopFileName, "(.*?)\.", jobId)) {
            job := ReadJobData(jobId1)
            jobs.Push(job)
        }
        
    }

    ; Get the pending jobs
    Loop, Files, % "status\pending\*.main"
    {
        if(RegExMatch(A_LoopFileName, "(.*?)\.", jobId)) {
            job := ReadJobData(jobId1)
            jobs.Push(job)
        }
    }
    Return jobs
}

ReadJobData(pJobId, readTasks:=true) {

    IniRead, jobId, % "jobs\" pJobId ".ini", General, jobId
    IniRead, jobStatus, % "jobs\" pJobId ".ini", General, jobStatus
    IniRead, pmmFile, % "jobs\" pJobId ".ini", General, pmmFile
    IniRead, baseVideoName, % "jobs\" pJobId ".ini", General, baseVideoName
    IniRead, fps, % "jobs\" pJobId ".ini", General, fps
    IniRead, VRFormat, % "jobs\" pJobId ".ini", General, VRFormat
    IniRead, parallaxEnabled, % "jobs\" pJobId ".ini", General, parallaxEnabled
    IniRead, sidesPerEye, % "jobs\" pJobId ".ini", General, sidesPerEye
    IniRead, resolutionStr, % "jobs\" pJobId ".ini", General, resolution
    IniRead, recordingFramesStr, % "jobs\" pJobId ".ini", General, recordingFrames
    IniRead, taskNamesStr, % "jobs\" pJobId ".ini", General, taskNames
    
    job := new JobData    
    job.jobId := jobId
    job.jobStatus := jobStatus
    job.pmmFile := pmmFile
    job.baseVideoName := baseVideoName
    job.fps := fps
    job.VRFormat := VRFormat
    job.parallaxEnabled := parallaxEnabled
    job.sidesPerEye := sidesPerEye
    job.resolution := StrSplit(resolutionStr, ",")
    job.recordingFrames := StrSplit(recordingFramesStr, ",")
    if(readTasks) {
        taskNamesArr := StrSplit(taskNamesStr, ",")
        job.tasks := ReadTaskData(pJobId, taskNamesArr)
    }
    Return job
}

WriteJobData(job, writeTasks:=false) {
    if(!InStr(FileExist("jobs"), "D")) {
        FileCreateDir % "jobs"
    }
    jobId := job.jobId
    IniWrite % jobId, % "jobs\" jobId ".ini", General, jobId
    IniWrite % job.jobStatus, % "jobs\" jobId ".ini", General, jobStatus
    UpdateJobStatus(job, job.jobStatus)
    IniWrite % job.pmmFile, % "jobs\" jobId ".ini", General, pmmFile
    IniWrite % job.baseVideoName, % "jobs\" jobId ".ini", General, baseVideoName
    IniWrite % job.fps, % "jobs\" jobId ".ini", General, fps
    if(job.VRFormat) {
        IniWrite % job.VRFormat, % "jobs\" jobId ".ini", General, VRFormat
    }
    if(job.parallaxEnabled) {
        IniWrite % job.parallaxEnabled, % "jobs\" jobId ".ini", General, parallaxEnabled
    }
    if(job.sidesPerEye) {
        IniWrite % job.sidesPerEye, % "jobs\" jobId ".ini", General, sidesPerEye
    }
    if(IsObject(job.resolution) && job.resolution.Count() == 2) {
        IniWrite % job.resolution[1] "," job.resolution[2], % "jobs\" jobId ".ini", General, resolution
    }
    if(IsObject(job.recordingFrames) && job.recordingFrames.Count() == 2) {
        IniWrite % job.recordingFrames[1] "," job.recordingFrames[2], % "jobs\" jobId ".ini", General, recordingFrames
    }
    if(IsObject(job.tasks) && job.tasks.Count() > 0) {
        taskNames := ""
        for i, task in job.tasks {
            if (i > 1) {
                taskNames .= ","
            }
            taskNames .= task.taskId
            if(writeTasks) {
                WriteTaskData(task)
            }
        }
        IniWrite % taskNames, % "jobs\" jobId ".ini", General, taskNames
    }
}

ReadTaskData(pJobId, taskNames) {
    tasks := []
    for i, name in taskNames {
        if(InStr(FileExist("jobs\tasks\" . pJobId . "." . name . ".ini"), "A")) {
            IniRead, taskType, % "jobs\tasks\" pJobId "." name ".ini", General, taskType
            IniRead, taskStatus, % "jobs\tasks\" pJobId "." name ".ini", General, taskStatus
            IniRead, side, % "jobs\tasks\" pJobId "." name ".ini", General, side
            IniRead, dependsOnStr, % "jobs\tasks\" pJobId "." name ".ini", General, dependsOn
            task := new TaskData
            task.taskId := name
            task.taskType := taskType
            task.taskStatus := taskStatus
            task.jobId := pJobId
            task.side := side
            task.dependsOn := StrSplit(dependsOnStr, ",")
            tasks.Push(task)
        }
    }
    Return tasks
}

WriteTaskData(task) {
    if(!InStr(FileExist("jobs\tasks"), "D")) {
        FileCreateDir % "jobs\tasks"
    }
    IniWrite % task.taskId, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, taskId
    IniWrite % task.taskType, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, taskType
    IniWrite % task.taskStatus, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, taskStatus
    IniWrite % task.jobId, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, jobId
    IniWrite % task.side, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, side
    if IsObject(task.dependsOn && task.dependsOn.Count() > 0) {
        dependsOnStr := ""
        for i, d in task.dependsOn {
            if (i > 1) {
                dependsOnStr .= ","
            }
            dependsOnStr .= d
        }
        IniWrite % dependsOnStr, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, dependsOn
    }
}

UpdateJobStatus(ByRef job, newStatus) {
    oldStatusFile := DetermineJobStatusFilePath(job.jobId, job.jobStatus)
    newStatusFile := DetermineJobStatusFilePath(job.jobId, newStatus)
    if(InStr(FileExist(oldStatusFile), "A")) {
        ; Move file
        FileMove, %oldStatusFile%, %newStatusFile%
    } else {
        FileAppend,, %newStatusFile%
    }
    job.jobStatus := newStatus
    IniWrite % job.jobStatus, % "jobs\" job.jobId ".ini", General, jobStatus
}

UpdateTaskStatus(ByRef task, newStatus) {
    IniWrite % newStatus, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, taskStatus
    task.taskStatus := newStatus
}

PullTaskStatus(ByRef task) {

    IniRead, taskStatus, % "jobs\tasks\" task.jobId "." task.taskId ".ini", General, taskStatus
    task.taskStatus := taskStatus
}

DetermineJobStatusFilePath(jobId, jobStatus) {
    directory := "status\pending\"
    
    if(jobStatus == JobData.STATUS_PROCESSING) {
        directory := "status\processing\"
    }
    if(jobStatus == JobData.STATUS_COMPLETED) {
        directory := "status\completed\"
    }
    if(!InStr(FileExist(directory), "D")) {
        FileCreateDir % directory
    }
    filePath := directory . jobId . ".main"
    Return filePath
}

DetermineDefaultOutputDir() {
    outputDir := A_WorkingDir . "\out"
    EnvGet, userpf, UserProfile
    if (InStr(FileExist(userpf . "\Videos"), "D")) {
        try {
            FileCreateDir % userpf . "\Videos\MMDVideos"
            if (ErrorLevel == 0) {
                outputDir := userpf . "\Videos\MMDVideos"
            }
        } catch {}
    }
    Return outputDir
}

StartMMDPhase(job:="") {
    ; Locating an MMD instance
    WinGet, mmdInstances, List, ahk_class Polygon Movie Maker
    if (mmdInstances == 1) {
        ; Only one instance found, assume single mode render
        
        if(!job) {
            ; else determine the data from the running MMD instance
            ; Create a job holding that data
            ; and persist that data

            Random, rand1, 10000, 99999
            job := new JobData
            job.jobId := A_Now . "_" . Format("{:05d}", rand1)
            DetermineJobDataFromMMD(job, mmdInstances1)
            InitializeTasks(job)
            WriteJobData(job, true)
        }
        
        ; MsgBox % "The base video name is '" videoName "'"
        StartVR180Rendering(mmdInstances1, job)
        MsgBox % "Process complete"
        ExitApp
    } else if (mmdInstances > 1) {
        ; TODO: Implement batch mode
        MsgBox, 0x10, % "Error", % "More than one MMD instance was found.`nPlease close one and try again"
        ExitApp, -1
    } else {
        MsgBox, 0x10, % "Error", % "No MMD instances found.`nOpen MMD before executing this program"
        ExitApp, -1
    }
}

InitializeTasks(ByRef job) {
    ; TODO: Create the proper tasks depending on the job data
    eyes := [EYE_LEFT, EYE_RIGHT]
    sides := [VR_SIDE_LEFT, VR_SIDE_RIGHT, VR_SIDE_TOP, VR_SIDE_BOTTOM, VR_SIDE_FRONT]
    taskCounter := 1
    tasks := []
    for i, eye in eyes {
        for j, side in sides {
            task := new TaskData
            task.jobId := job.jobId
            task.taskId := "rendering" . Format("{:05d}", taskCounter)
            task.taskType := TaskData.T_RENDERING
            task.taskStatus := TaskData.STATUS_PENDING
            task.side := eye . side
            tasks.Push(task)
            taskCounter++
        }
    }
    encodingSides := [EYE_LEFT, EYE_RIGHT, "F"]
    for i, encSide in encodingSides {
        task := new TaskData
        task.jobId := job.jobId
        task.taskId := "encoding" . Format("{:05d}", taskCounter)
        task.taskType := TaskData.T_ENCODING
        task.taskStatus := TaskData.STATUS_PENDING
        task.side := encSide
        tasks.Push(task)
        taskCounter++
    }
    job.tasks := tasks
}

StartVR180Rendering(mmdWin, job) {
    UpdateJobStatus(job, JobData.STATUS_PROCESSING)
    success := CreateStagingDir(job, fullPathStaging)
    if(success) {
        videoName := job.baseVideoName
        viewpointModel := FindViewpointModelName(mmdWin, videoName)
        preferredCodecs := []
        ; Set the preferred codecs, in priority order, first the job and then the user preferences
        ; if (job.renderCodec) {
        ;    preferredCodecs.Push(job.renderCodec)
        ; }
        if (userPrefs.renderCodec) {
            preferredCodecs.Push(userPrefs.renderCodec)
        }
        ; Set some fallback codecs
        preferredCodecs.Push("MJPEG", "ffdshow video encoder")
        encodingOptions := {startFrame: job.recordingFrames[1], endFrame: job.recordingFrames[2], enableAudio: true, fps: 60
                        , preferredCodecs: preferredCodecs}
        for i, task in job.tasks {
            ; TODO: Check also if the rendered video file still exist and is not corrupted
            shouldProcess := (task.taskStatus != TaskData.STATUS_COMPLETED)?1:0
            
            if(shouldProcess && task.taskType == TaskData.T_RENDERING) {
                eye := SubStr(task.side, 1, 1)
                side := SubStr(task.side, 2, 1)
                UpdateTaskStatus(task, TaskData.STATUS_PREPARING)
                if (PrepareRenderVRSide(mmdWin, videoName, viewpointModel, side, eye)) {
                    prefix := eye . side . "_"
                    UpdateTaskStatus(task, TaskData.STATUS_PROCESSING)
                    success := RenderVideo(mmdWin, prefix . videoName, fullPathStaging, encodingOptions)
                    encodingOptions.enableAudio := false
                    if (!success) {
                        Break
                    }
                    task.taskStatus := TaskData.STATUS_COMPLETED
                    WriteTaskData(task)
                }
            }

            if(shouldProcess && task.taskType == TaskData.T_ENCODING) {
                StartEncodingTask(job, task)
            }
        }
    }
    if (success) {
       UpdateJobStatus(job, JobData.STATUS_COMPLETED)
    }
    Return success
}

RenderVideo(mmdWin, videoName, directory, encodingOptions) {
    ; TrayTip, % "Debug", % "RenderVideo " videoName " start", 1, 1
    success := true
    ; Get the PID to find the dialogs
    WinGet, mmdPid, PID, ahk_id %mmdWin%
    ; Activate another window before selecting the menu item
    Run % "notepad.exe data\placeholder.txt",,, txtPid
    WinWait, ahk_pid %txtPid%,, 5
    if (ErrorLevel) {
        success := false
    }
    if(success) {
        WinActivate, ahk_pid %txtPid%
        WinWaitActive, ahk_pid %txtPid%,, 5
        if (ErrorLevel) {
            success := false
        }
    }
    if (success) {
        WinMenuSelectItem, ahk_id %mmdWin%,, file, render to AVI
        WinWait, output AVI ahk_pid %mmdPid%,, 5
        WinGet, dialogId, ID
        if (ErrorLevel) {
            success := false
            TrayTip, % "Couldn't render video", % "Video " videoName " could not be rendered.`nRender to AVI file dialog not found", 3, 3
        }
    }
    if(success) {
        ControlSetText, Edit1, %directory%\%videoName%, ahk_id %dialogId%
        ; ControlClick, Button2, ahk_id %dialogId%
        ClickWithDelayChange("Button2", "ahk_id " dialogId)
        WinWait, AVI ahk_pid %mmdPid%,, 5
        WinGet, dialogId, ID
        if (ErrorLevel) {
            success := false
            TrayTip, % "Couldn't render video", % "Video " videoName " could not be rendered.`nAVI-out dialog not found", 3, 3
        }
    }
    if(success) {
        ControlSetText, Edit3, % encodingOptions.fps, ahk_id %dialogId%
        ControlSetText, Edit4, % encodingOptions.startFrame, ahk_id %dialogId%
        ControlSetText, Edit5, % encodingOptions.endFrame, ahk_id %dialogId%
        ControlGet, isWAV, Enabled, , Button1, ahk_id %dialogId%
        if (isWAV) {
            if (encodingOptions.enableAudio) {
                Control, Check,, Button1, ahk_id %dialogId%
            } else {
                Control, UnCheck,, Button1, ahk_id %dialogId%
            }
        }
        codecFound := false
        for i, codec in encodingOptions.preferredCodecs {
            Control, ChooseString, % codec, ComboBox1, ahk_id %dialogId%
            ControlGet, selected, Choice,, ComboBox1, ahk_id %dialogId%
            if(!ErrorLevel && InStr(selected, codec)) {
                ; Try the preferredCodecs until one succeeds
                codecFound := true
                Break
            }
        }
        if (!codecFound) {
            TrayTip, % "Couldn't find a preferred codec", % "No preferred codec was found to render " videoName, 3, 2
        }
        ; ControlClick, Button5, ahk_id %dialogId%
        ClickWithDelayChange("Button5", "ahk_id " dialogId)
        WinWait, ahk_class RecWindow ahk_pid %mmdPid%,, 5
        if(ErrorLevel) {
            success := false
            TrayTip, % "Problem rendering", % "Rendering window for video " videoName " couldn't be found", 3, 3
        } else {
            ; TrayTip, % "Rendering started", % "Rendering " videoName "...", 3, 1
        }
    }
    if(txtPid) {
        ; Kill the window we just created
        WinKill, ahk_pid %txtPid%
    }
    if(success) {
        ; TODO: Set a proper timeout to wait for the render
        while(WinExist("ahk_class RecWindow ahk_pid " mmdPid)) {
            ; Wait until the rendering window becomes hidden or is killed    
        }
        ; TrayTip, % "Debug", % "RenderVideo " videoName " after while", 1, 1
        if(WinExist("ahk_class RecWindow ahk_pid " mmdPid)) {
            success := false
            TrayTip, % "Problem rendering", % "Rendering of video " videoName " is taking too long", 3, 3
        } else {
            ; TrayTip, % "Rendering finished", % "Rendering " videoName "...", 3, 1
        }
    }
    ; TrayTip, % "Debug", % "RenderVideo " videoName " end", 1, 1
    Return success
}

PrepareRenderVRSide(mmdWin, videoName, viewpointModel, side, eye) {
    success := true
    if (viewpointModel) {
        ; Set the camera to follow the correct eye bone
        eyeBone := "Viewpoint_" . eye
        Control, ChooseString, %eyeBone%, ComboBox6, ahk_id %mmdWin%
        ClickWithDelayChange("Button32", "ahk_id " mmdWin)
        rotX := 0.0
        rotY := 0.0
        accRx := 0.0 
        accRy := 0.0
        angle := 92
        switch side 
        {
            case VR_SIDE_LEFT:
                rotY := 45.0
                accRy := -45.0
            case VR_SIDE_RIGHT:
                rotY := -45.0
                accRy := 45.0
            case VR_SIDE_TOP:
                rotY := 45.0
                accRy := -45.0
                rotX := -90.0
                accRx := -90.0
                angle := 103
            case VR_SIDE_BOTTOM:
                rotY := 45.0
                accRy := -45.0
                rotX := 90.0
                accRx := 90.0
                angle := 103
        }
        success := SetVRCameraParams(mmdWin, videoName, rotX, rotY, accRx, accRy, angle)
        ; MsgBox % "Params set for eye: " eye ", side: " side
    } else {
        ; TODO: Implement static camera handling
        ; or maybe try to find and set the viewpointModel first
    }
    Return success
}

SetVRCameraParams(mmdWin, videoName, rotX, rotY, accRx, accRy, angle := 92) {
    success := true
    WinActivate, ahk_id %mmdWin%
    WinWaitActive, ahk_id %mmdWin%,, 5
    if(ErrorLevel) {
        success := false
        TrayTip % "Problem setting VR parameter", % "Problem setting camera parameters for " videoName, 3, 3
    } else {
        ControlFocus, Edit29, ahk_id %mmdWin%
        ControlSetText, Edit29, %rotX%, ahk_id %mmdWin%
        ControlFocus, Edit30, ahk_id %mmdWin%
        ControlSetText, Edit30, %rotY%, ahk_id %mmdWin%
        ControlFocus, Edit14, ahk_id %mmdWin%
        ControlSetText, Edit14, %accRx%, ahk_id %mmdWin%
        ControlFocus, Edit15, ahk_id %mmdWin%
        ControlSetText, Edit15, %accRy%, ahk_id %mmdWin%
        ControlFocus, Edit4, ahk_id %mmdWin%
        ControlSetText, Edit4, %angle%, ahk_id %mmdWin%
        ControlFocus, Edit15, ahk_id %mmdWin%

        ; ControlClick, Button32, ahk_id %mmdWin% ; register the camera
        ; ControlClick, Button48, ahk_id %mmdWin% ; register Equirrectangular
        ClickWithDelayChange("Button32", "ahk_id " mmdWin)
        ClickWithDelayChange("Button48", "ahk_id " mmdWin)
    }
    Return success
}

StartEncodingTask(job, task) {
    if (A_IsCompiled) {
        Run % A_WorkingDir . "\scripts\encode_video.exe " task.jobId "." task.taskId
    } else {
        toolsDir := A_WorkingDir
        toolsDirClean := StrReplace(toolsDir, ":")
        toolsDirBash := "/" . StrReplace(toolsDirClean, "\", "/")
        Run % "C:\msys64\usr\bin\mintty.exe /bin/env MSYSTEM=MINGW64 /bin/bash -l """ toolsDirBash "/scripts/bash/encode_video.sh"" " " """ toolsDirBash """ " task.jobId "." task.taskId
    }
    ; Wait for the script to finish
    oldStatus := task.taskStatus
    while (oldStatus == task.taskStatus) {
        PullTaskStatus(task)
        Sleep, 200
    }
    ; MsgBox % "Task status changed"
}

CreateStagingDir(job, ByRef outFullpath) {
    success := false
    try {
        if(!InStr(FileExist("staging\" . job.jobId), "D")) {
            FileCreateDir % "staging\" job.jobId
        }
        outFullPath := A_WorkingDir . "\staging\" . job.jobId
        success := true
    } catch e {
        TrayTip % "Error creating directory", % "Error creating staging directory for: " job.jobId, 3, 3
    }
    Return success
}

ClickWithDelayChange(controlParam, winTitle, delayBefore := -1, delayAfter := 100) {
    SetControlDelay, %delayBefore%
    ControlClick, %controlParam%, %winTitle%
    SetControlDelay, %delayAfter%
}

ExtractStartEndFrames(mmdWin, ByRef startFrame, ByRef endFrame) {
    success := false
    ControlGetText, startStr, Edit19, ahk_id %mmdWin%
    ControlGetText, endStr, Edit20, ahk_id %mmdWin%
    startFrame := startStr?startStr:0
    endFrame := endStr 
    if(!endStr) {
        ; Determine the end frame by clicking the last frame button 
        ; and extracting the value from the EditText
        ; ControlClick, Button8, ahk_id %mmdWin%
        ClickWithDelayChange("Button8", "ahk_id " mmdWin)
        Sleep, 100
        ControlGetText, endStr, Edit1, ahk_id %mmdWin%
        if (endStr > 0) {
            endFrame := endStr
            success := true
        } else {
            ; Render 300 frames by default
            endFrame := 300
        }
    } else {
        success := true
    }
    ; Set the view to the initial frame
    ControlSetText, Edit1, %startFrame%, ahk_id %mmdWin%
    ; Send Enter to the control to submit the change
    ControlSend, Edit1, {Enter}, ahk_id %mmdWin%
    Return success
}

ExtractResolution(mmdWin, ByRef width, ByRef height) {
    success := true
    ; Get the PID to find the dialogs
    WinGet, mmdPid, PID, ahk_id %mmdWin%
    Run % "notepad.exe data\placeholder.txt",,, txtPid
    WinWait, ahk_pid %txtPid%,, 5
    if (ErrorLevel) {
        success := false
    }
    if(success) {
        WinActivate, ahk_pid %txtPid%
        WinWaitActive, ahk_pid %txtPid%,, 5
        if (ErrorLevel) {
            success := false
        }
    }
    if (success) {
        WinMenuSelectItem, ahk_id %mmdWin%,, view, screen size
        WinWait, screen size ahk_pid %mmdPid%,, 5
        WinGet, dialogId, ID
        if (ErrorLevel) {
            success := false
        }
    }
    if(txtPid) {
        WinKill, ahk_pid %txtPid%
    }
    if(success) {
        ControlGetText, widthStr, Edit1, ahk_id %dialogId%
        ControlGetText, heightStr, Edit2, ahk_id %dialogId%
        width := (widthStr)?widthStr:1080
        height := (heightStr)?heightStr:1080
        ClickWithDelayChange("Button2", "ahk_id " . dialogId)
    }
}

DetermineJobDataFromMMD(ByRef job, mmdWin) {
    videoName := DetermineVideoBaseName(mmdWin)
    job.baseVideoName := videoName
    ExtractStartEndFrames(mmdWin, startFrame, endFrame)
    job.recordingFrames := [startFrame, endFrame]
    ExtractResolution(mmdWin, width, height)
    job.resolution := [width, height]
}

; Retrieves the name of the the Viewpoint model, if it is used
FindViewpointModelName(mmdWin, videoName) {
    found := ""
    ; Switch to camera / acc
    Control, ChooseString, % "camera", ComboBox3, ahk_id %mmdWin%
    ; Get the followbone model
    ControlGetText, followModel, ComboBox5, ahk_id %mmdWin%
    if (InStr(followModel, "Viewpoint")) {
        ; We only accept the translated version of the viewpoint model
        found := followModel
    }
    Return found
}

; Determines which VR mode we are rendering, -1 if none
DetermineVRRendering(mmdWin) {
    ; TODO: Implement this, for now hardcode VR_180_MODE
    Return VR_180_MODE
}

; Determines the base name for the final rendered video
; extracted from the window title
DetermineVideoBaseName(mmdWin) {
    Random, rand1, 10000, 99999
    videoTitle := "mmd_" . A_Now . "_" . Format("{:05d}", rand1)
    WinGetTitle, mmdTitle, ahk_id %mmdWin%
    if(RegExMatch(mmdTitle, "\[.*?([^\\]+).pmm\]", extracted)) {
        videoTitle := extracted1
    }
    Return videoTitle
}


InitPhase()

^#q::
MsgBox, 0x24, % "Confimation", % "Do you want to abort the process?"
IfMsgBox, Yes 
{
    ExitApp
}