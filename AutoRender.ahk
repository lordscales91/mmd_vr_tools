; Setting the compiler directives to customize the EXE properties.

;@Ahk2Exe-SetCompanyName Lordscales91
;@Ahk2Exe-SetCopyright Copyright(c) 2021
;@Ahk2Exe-SetDescription MMD VR AutoRender
;@Ahk2Exe-SetVersion 0.0.2-beta
;@Ahk2Exe-SetName MMD VR AutoRender

#Include DataModel.ahk
#SingleInstance, force
SetWorkingDir, %A_ScriptDir%
SetControlDelay, 100
SetTitleMatchMode, 2

global VR_180_MODE := 1
global VR_360_MODE := 2

global VR_SIDE_LEFT = "L"
global VR_SIDE_RIGHT = "R"
global VR_SIDE_TOP = "T"
global VR_SIDE_BOTTOM = "B"
global VR_SIDE_FRONT = "F"

global EYE_LEFT := "L"
global EYE_RIGHT := "R"

global FATAL_ERROR := "FatalError"
global WORKDIR_PREFIX := "workDir\"

if (A_IsCompiled) {
    WORKDIR_PREFIX := ""
}

global userPreferencesFile := "preferences.ini"
global userPrefs := ""

global defaultRenderCodec := "MJPEG"
global defaultEncodingFormat := "MP4"
global defaultEncodingQuality := "medium"
global defaultFrameRate := 60

IsFatalError(val) {
    Return val == FATAL_ERROR
}

FatalError() {
    Return FATAL_ERROR
}

InitPhase() {
    userPrefs := GetOrCreateUserPreferences()
    jobs := GetPendingJobs()
    if(jobs.Length()) {
        if(jobs[1].jobStatus != JobData.STATUS_PENDING) {
            MsgBox, 0x24, % "Confirmation", % "A previous Job couldn't finish`nDo you want to resume it?"
            IfMsgBox, Yes 
            {
                StartMMDPhase(jobs[1])
            } else {
                StartMMDPhase()
            }
        } else {
            ; Automatically launch a pending job
            StartMMDPhase(jobs[1])
        }
    } else {
        StartMMDPhase()
    }
}

ReadUserPreferences() {
    IniRead, MMDExecutable, %userPreferencesFile%, General, MMDExecutable
    IniRead, deleteStagingFiles, %userPreferencesFile%, General, deleteStagingFiles, 0

    IniRead, fps, %userPreferencesFile%, Render, fps, %defaultFrameRate%
    IniRead, renderCodec, %userPreferencesFile%, Render, renderCodec, %defaultRenderCodec%

    IniRead, finalEncodingFormat, %userPreferencesFile%, Encoding, finalEncodingFormat, %defaultEncodingFormat%
    IniRead, finalEncodingQuality, %userPreferencesFile%, Encoding, finalEncodingQuality, %defaultEncodingQuality%
    IniRead, finalVideoOutDir, %userPreferencesFile%, Encoding, finalVideoOutDir, %A_Space%

    if (!finalVideoOutDir) {
        finalVideoOutDir := DetermineDefaultOutputDir()
    }

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
    isNew := true
    try {
        if(InStr(FileExist(userPreferencesFile), "A")) {
            isNew := false
        }
        IniWrite % prefs.MMDExecutable, %userPreferencesFile%, General, MMDExecutable
        IniWrite % prefs.deleteStagingFiles, %userPreferencesFile%, General, deleteStagingFiles

        IniWrite % prefs.fps, %userPreferencesFile%, Render, fps
        IniWrite % prefs.renderCodec, %userPreferencesFile%, Render, renderCodec

        IniWrite % prefs.finalEncodingFormat, %userPreferencesFile%, Encoding, finalEncodingFormat
        IniWrite % prefs.finalEncodingQuality, %userPreferencesFile%, Encoding, finalEncodingQuality
        IniWrite % prefs.finalVideoOutDir, %userPreferencesFile%, Encoding, finalVideoOutDir
    } catch {
        action := "created"
        if(!isNew) {
            action := "updated"
        }
        MsgBox, 0x10, % "Error", % "Preferences file couldn't be " action ".`nEnsure you have write permissions to this folder"
        ExitApp, 1
    }
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
    Loop, Files, % WORKDIR_PREFIX "status\processing\*.main" 
    {
        if(RegExMatch(A_LoopFileName, "(.*?)\.", jobId)) {
            job := ReadJobData(jobId1)
            if (IsObject(job)) {
                jobs.Push(job)
            }
        }
    }

    ; Get the pending jobs
    Loop, Files, % WORKDIR_PREFIX "status\pending\*.main"
    {
        if(RegExMatch(A_LoopFileName, "(.*?)\.", jobId)) {
            job := ReadJobData(jobId1)
            if(IsObject(job)) {
                jobs.Push(job)
            }
        }
    }
    Return jobs
}

ReadJobData(pJobId, readTasks:=true) {
    jobIniFile := WORKDIR_PREFIX . "jobs\" . pJobId . "\main.ini"
    if(!InStr(FileExist(jobIniFile), "A")) {
        ; TODO: Log the error in a log file
        ; For now put a toast
        TrayTip % "Warning", % "Job data file couldn't be found", 1, 2
        Return ""
    }
    IniRead, jobId, %jobIniFile%, General, jobId
    IniRead, jobShortId, %jobIniFile%, General, jobShortId
    IniRead, jobStatus, %jobIniFile%, General, jobStatus
    IniRead, pmmFile, %jobIniFile%, General, pmmFile
    IniRead, baseVideoName, %jobIniFile%, General, baseVideoName
    IniRead, fps, %jobIniFile%, General, fps
    IniRead, VRFormat, %jobIniFile%, General, VRFormat, 0
    IniRead, parallaxEnabled, %jobIniFile%, General, parallaxEnabled, 0
    IniRead, sidesPerEye, %jobIniFile%, General, sidesPerEye, 0
    IniRead, resolutionStr, %jobIniFile%, General, resolution
    IniRead, recordingFramesStr, %jobIniFile%, General, recordingFrames
    IniRead, taskNamesStr, %jobIniFile%, General, taskNames, %A_Space%
    
    if(!taskNamesStr) {
        ; This shouldn't happen unless the user messed up the ini file
        Return ""
    }
    job := new JobData    
    job.jobId := jobId
    job.jobShortId := jobShortId
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
        tasks := ReadTaskData(pJobId, taskNamesArr)
        if (!tasks.Length()) {
            job := ""
            TrayTip % "Warning", % "Job contains no tasks (or tasks couldn't be loaded)", 1, 2
            Return ""
        }
        job.tasks := tasks
    }
    Return job
}

WriteJobData(job, writeTasks:=false) {
    success := true
    if(!InStr(FileExist(WORKDIR_PREFIX . "jobs\" . job.jobId), "D")) {
        try {
            FileCreateDir % WORKDIR_PREFIX "jobs\" job.jobId
        } catch {
            success := false
            TrayTip % "Error", % "Couldn't store information about the job.`nIt won't be possible to proceed to the Encoding Phase.", 2, 3
        }
    }
    if(success) {
        try {
            jobId := job.jobId
            jobIniFile := WORKDIR_PREFIX . "jobs\" . jobId . "\main.ini"
            IniWrite % jobId, %jobIniFile%, General, jobId
            if(job.jobShortId != -1) {
                IniWrite % job.jobShortId, %jobIniFile%, General, jobShortId
            }
            IniWrite % job.jobStatus, %jobIniFile%, General, jobStatus
            UpdateJobStatus(job, job.jobStatus)
            IniWrite % job.pmmFile, %jobIniFile%, General, pmmFile
            IniWrite % job.baseVideoName, %jobIniFile%, General, baseVideoName
            IniWrite % job.fps, %jobIniFile%, General, fps
            if(job.VRFormat) {
                IniWrite % job.VRFormat, %jobIniFile%, General, VRFormat
            }
            if(job.parallaxEnabled) {
                IniWrite % job.parallaxEnabled, %jobIniFile%, General, parallaxEnabled
            }
            if(job.sidesPerEye) {
                IniWrite % job.sidesPerEye, %jobIniFile%, General, sidesPerEye
            }
            if(IsObject(job.resolution) && job.resolution.Count() == 2) {
                IniWrite % job.resolution[1] "," job.resolution[2], %jobIniFile%, General, resolution
            }
            if(IsObject(job.recordingFrames) && job.recordingFrames.Count() == 2) {
                IniWrite % job.recordingFrames[1] "," job.recordingFrames[2], %jobIniFile%, General, recordingFrames
            }
            if(IsObject(job.tasks) && job.tasks.Length() > 0) {
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
                IniWrite % taskNames, %jobIniFile%, General, taskNames
            }
        } catch {
            success := false
            TrayTip % "Error", % "Couldn't store information about the job.`nIt won't be possible to proceed to the Encoding Phase.", 2, 3
        }
    }
    
    Return success
}

ReadTaskData(pJobId, taskNames) {
    tasks := []
    for i, name in taskNames {
        taskIniFile :=  WORKDIR_PREFIX . "jobs\" . pJobId . "\" . name . ".ini"
        if(InStr(FileExist(taskIniFile), "A")) {
            IniRead, taskShortId, %taskIniFile%, General, taskShortId
            IniRead, taskType, %taskIniFile%, General, taskType
            IniRead, taskStatus, %taskIniFile%, General, taskStatus
            IniRead, taskResult, %taskIniFile%, General, taskResult, %A_Space%
            IniRead, side, %taskIniFile%, General, side
            IniRead, dependsOnStr, %taskIniFile%, General, dependsOn, %A_Space%
            task := new TaskData
            task.taskId := name
            task.taskShortId := taskShortId
            task.taskType := taskType
            task.taskStatus := taskStatus
            task.taskResult := taskResult
            task.jobId := pJobId
            task.side := side
            task.dependsOn := StrSplit(dependsOnStr, ",")
            tasks.Push(task)
        }
    }
    Return tasks
}

WriteTaskData(task) {
    success := true
    if(!InStr(FileExist(WORKDIR_PREFIX . "jobs\" . task.jobId), "D")) {
        try {
            FileCreateDir % WORKDIR_PREFIX "jobs\" task.jobId
        } catch {
            success := false
            TrayTip % "Error", % "Couldn't store information about the job.`nIt won't be possible to proceed to the Encoding Phase.", 2, 3
        }
        
    }
    if(success) {
        try {
            taskIniFile := WORKDIR_PREFIX . "jobs\" . task.jobId . "\" . task.taskId . ".ini"
            IniWrite % task.taskId, %taskIniFile%, General, taskId
            if(task.taskShortId != -1) {
                IniWrite % task.taskShortId, %taskIniFile%, General, taskShortId
            }
            IniWrite % task.taskId, %taskIniFile%, General, taskId
            IniWrite % task.taskType, %taskIniFile%, General, taskType
            IniWrite % task.taskStatus, %taskIniFile%, General, taskStatus
            IniWrite % task.taskResult, %taskIniFile%, General, taskResult
            IniWrite % task.jobId, %taskIniFile%, General, jobId
            IniWrite % task.side, %taskIniFile%, General, side
            if (IsObject(task.dependsOn) && task.dependsOn.Length() > 0) {
                dependsOnStr := ""
                for i, d in task.dependsOn {
                    if (i > 1) {
                        dependsOnStr .= ","
                    }
                    dependsOnStr .= d
                }
                IniWrite % dependsOnStr, %taskIniFile%, General, dependsOn
            }
        } catch {
            success := false
            TrayTip % "Error", % "Couldn't store information about the job.`nIt won't be possible to proceed to the Encoding Phase.", 2, 3
        }
    }
    Return success
    
}

UpdateJobStatus(ByRef job, newStatus) {
    success := true
    action := "created"
    try {
        oldStatusFile := DetermineJobStatusFilePath(job.jobId, job.jobStatus)
        newStatusFile := DetermineJobStatusFilePath(job.jobId, newStatus)
        if(InStr(FileExist(oldStatusFile), "A")) {
            ; Move file
            action := "updated"
            FileMove, %oldStatusFile%, %newStatusFile%
        } else {
            FileAppend,, %newStatusFile%
        }
        job.jobStatus := newStatus
        IniWrite % job.jobStatus, % WORKDIR_PREFIX "jobs\" job.jobId "\main.ini", General, jobStatus
    } catch {
        success := false
        TrayTip % "Warning", % "Job status file couldn't be " action, 1, 2
    }
    Return success
}

UpdateTaskStatus(ByRef task, newStatus) {
    success := true
    try {
        IniWrite % newStatus, % WORKDIR_PREFIX "jobs\" task.jobId "\" task.taskId ".ini", General, taskStatus
        task.taskStatus := newStatus
    } catch {
        success := false
        TrayTip % "Warning", % "Couldn't update the task status", 1, 2
    }
    Return success
}

PullTaskStatus(ByRef task) {

    IniRead, taskStatus, % WORKDIR_PREFIX "jobs\" task.jobId "\" task.taskId ".ini", General, taskStatus
    IniRead, taskResult, % WORKDIR_PREFIX "jobs\" task.jobId "\" task.taskId ".ini", General, taskResult, %A_Space%
    task.taskStatus := taskStatus
    task.taskResult := taskResult
}

DetermineJobStatusFilePath(jobId, jobStatus) {
    directory := WORKDIR_PREFIX . "status\pending\"
    
    if(jobStatus == JobData.STATUS_PROCESSING) {
        directory := WORKDIR_PREFIX . "status\processing\"
    }
    if(jobStatus == JobData.STATUS_COMPLETED) {
        directory := WORKDIR_PREFIX . "status\completed\"
    }
    if(!InStr(FileExist(directory), "D")) {
        FileCreateDir % directory
    }
    filePath := directory . jobId . ".main"
    Return filePath
}

DetermineDefaultOutputDir() {
    outputDir := A_WorkingDir . "\" . WORKDIR_PREFIX . "out"
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
        if(!userPrefs.MMDExecutable) {
            ; Try to fill up the MMD executable path if needed
            mmdPath := DetermineMMDExecutablePath(mmdInstances1)
            if (mmdPath) {
                userPrefs.MMDExecutable := mmdPath
                WriteUserPreferences(userPrefs)
            }
        }
        success := true
        if(!job) {
            Random, rand1, 10000, 99999
            Random, rand2
            job := new JobData
            job.jobId := A_Now . "_" . rand1
            job.jobShortId := Format("{:08x}", rand2)
            ; Determine the data from the running MMD instance
            ; Create a job holding that data and persist it
            success := DetermineJobDataFromMMD(job, mmdInstances1)
            if(IsFatalError(success)) {
                ; TODO: Ideally here we should trigger some retry behaviour
                MsgBox, 0x10, % "Error", % "Process couldn't be finished."
                ExitApp, 1
            } else {
                InitializeTasks(job)
                WriteJobData(job, true)
            }
        }
        
        aux := StartVR180Rendering(mmdInstances1, job)
        success := (IsFatalError(aux))?FatalError():(success && aux)
        if(IsFatalError(success)) {
            MsgBox, 0x10, % "Error", % "Process couldn't be finished."
            ExitApp, 1
        } else if(success) {
            MsgBox % "Process complete"
            ExitApp
        } else {
            MsgBox, 0x10, % "Error", % "Process ended with errors."
            ExitApp, 1
        }
    } else if (mmdInstances > 1) {
        ; TODO: Implement batch mode
        MsgBox, 0x10, % "Error", % "More than one MMD instance was found.`nPlease close one and try again"
        ExitApp, 1
    } else {
        MsgBox, 0x10, % "Error", % "No MMD instances found.`nOpen MMD before executing this program"
        ExitApp, 1
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
            Random, rand1
            task := new TaskData
            task.jobId := job.jobId
            task.taskShortId := Format("{:08x}", rand1)
            task.taskId := Format("{:05d}", taskCounter) . "_rendering"
            task.taskType := TaskData.T_RENDERING
            task.taskStatus := TaskData.STATUS_PENDING
            task.side := eye . side
            tasks.Push(task)
            taskCounter++
        }
    }
    encodingSides := [EYE_LEFT, EYE_RIGHT, "F"]
    for i, encSide in encodingSides {
        Random, rand1
        task := new TaskData
        task.jobId := job.jobId
        task.taskShortId := Format("{:08x}", rand1)
        task.taskId := Format("{:05d}", taskCounter) . "_encoding"
        task.taskType := TaskData.T_ENCODING
        task.taskStatus := TaskData.STATUS_PENDING
        task.side := encSide
        tasks.Push(task)
        taskCounter++
    }
    Random, rand1
    injectTask := new TaskData
    injectTask.jobId := job.jobId
    injectTask.taskShortId := Format("{:08x}", rand1)
    injectTask.taskId := Format("{:05d}", taskCounter) . "_inject_metadata"
    injectTask.taskType := TaskData.T_INJECT_METADATA
    injectTask.taskStatus := TaskData.STATUS_PENDING
    tasks.Push(injectTask)
    taskCounter++

    job.tasks := tasks
}

StartVR180Rendering(mmdWin, job) {
    UpdateJobStatus(job, JobData.STATUS_PROCESSING)
    success := CreateStagingDir(job, fullPathStaging)
    if(!success) {
        Return FatalError()
    }
    
    videoName := job.baseVideoName
    viewpointModel := FindViewpointModelName(mmdWin, videoName)
    if(!viewpointModel) {
        MsgBox, 0x10, % "Error", % "Viewpoint model not found"
        ExitApp, 1
    }
    preferredCodecs := []
    ; Set the preferred codecs, in priority order, first the job and then the user preferences
    if (job.renderCodec) {
        preferredCodecs.Push(job.renderCodec)
    }
    if (userPrefs.renderCodec) {
        preferredCodecs.Push(userPrefs.renderCodec)
    }
    ; Set some fallback codecs
    preferredCodecs.Push("MJPEG", "ffdshow video encoder")
    encodingOptions := {startFrame: job.recordingFrames[1], endFrame: job.recordingFrames[2], enableAudio: true, fps: 60
                    , preferredCodecs: preferredCodecs}
    finalEncodedVideoPath := ""
    for i, task in job.tasks {
        shouldProcess := (task.taskStatus != TaskData.STATUS_COMPLETED)?1:0

        if(shouldProcess && task.taskType == TaskData.T_RENDERING) {
            eye := SubStr(task.side, 1, 1)
            side := SubStr(task.side, 2, 1)
            prefix := eye . side . "_"
            videoFilepath := fullPathStaging . "\" . prefix . videoName . ".avi"
            if (FileExist(videoFilepath)) {
                ; If a previous file with the same name exists it means it's from a previous failed attempt.
                ; Get rid of it before starting the process
                FileDelete, %videoFilepath%
            }
            UpdateTaskStatus(task, TaskData.STATUS_PREPARING)
            success := (success && PrepareRenderVRSide(mmdWin, videoName, viewpointModel, side, eye))
            if (success) {
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
            side := task.side
            expectedFilename := fullPathStaging . "\" side . "_encoded_" . videoName . "." . Format("{:L}", job.finalEncodingFormat)
            if(side != "F" && FileExist(expectedFilename)) {
                FileDelete, %expectedFilename%
            }
            success := StartEncodingTask(job, task)
            if(!success) {
                Break
            }
        }
        if(task.taskType == TaskData.T_ENCODING && task.side == "F") {
            if(task.taskStatus == TaskData.STATUS_COMPLETED) {
                finalEncodedVideoPath := task.taskResult
            }
        }
        if(shouldProcess && task.taskType == TaskData.T_INJECT_METADATA && finalEncodedVideoPath) {
            success := StartInjectMetadataTask(job, task, finalEncodedVideoPath)
            if(!success) {
                Break
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
    txtPid := 0
    try {

        renderStarted := -1
        recWindowId := 0

        ; Get the PID to find the dialogs
        WinGet, mmdPid, PID, ahk_id %mmdWin%

        ; Just to be sure the WinMenuSelectItem works, activate the MMD window first
        ; this way we ensure it is in a "non-minimized" state. See: https://www.autohotkey.com/docs/commands/WinMenuSelectItem.htm
        WinActivate, ahk_id %mmdWin%
        WinWaitActive, ahk_id %mmdWin%,, 5
        if (ErrorLevel) {
            success := false
        }
        
        if(success) {
            ; Activate another window before selecting the menu item
            Run % "notepad.exe data\placeholder.txt",,, txtPid
            WinWait, ahk_pid %txtPid%,, 5
            if (ErrorLevel) {
                success := false
            }
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
            ClickWithDelayChange("Button5", "ahk_id " dialogId)
            WinWait, ahk_class RecWindow ahk_pid %mmdPid%,, 5
            if(ErrorLevel) {
                success := false
                TrayTip, % "Problem rendering", % "Rendering window for video " videoName " couldn't be found", 3, 3
            } else {
                WinGet, recWindowId, ID, ahk_class RecWindow ahk_pid %mmdPid%
                if(recWindowId) {
                    renderStarted := A_TickCount
                } else {
                    success := false
                }
                ; TrayTip, % "Rendering started", % "Rendering " videoName "...", 3, 1
            }
        }
        if(txtPid) {
            ; Kill the window we just created
            WinKill, ahk_pid %txtPid%
        }
        if(success) {
            timeBeforeCheckHung := 30 * 60 * 1000 ; 30 minutes in millis
            periodOfGrace := 10 * 60 * 1000 ; 10 minutes
            hungStart := -1
            while(WinExist("ahk_id " recWindowId)) {
                ; Wait until the rendering window becomes hidden or is closed

                renderEllapsed := A_TickCount - renderStarted
                if(renderEllapsed > timeBeforeCheckHung) {
                    ; After 30 minutes start checking if the MMD Render froze
                    ; If it froze give it some time and if it's still frozen. Kill it
                    isHung := IsHungWindow(recWindowId)
                    if(IsHung == 0) {
                        ; It has recovered within the period of grace. Keep it going
                        hungStart := -1
                    }
                    if(hungStart != -1) {
                        hungEllapsed := hungStart - A_TickCount
                        if(hungEllapsed > periodOfGrace) {
                            Process, Close, %mmdPid%
                            MsgBox, 0x10, % "Error", % "MMD froze during rendering and had to be killed"
                            ExitApp, 1
                        }
                    }else {
                        if(IsHung == 1) {
                            hungStart := A_TickCount
                        }
                    }
                }
                Sleep, 100    
            }
        }
    } catch {
        success := false
        TrayTip % "Error", % "Unknown error while rendering the video", 2, 3
        if(txtPid) {
            ; Kill the window we just created
            WinKill, ahk_pid %txtPid%
        }
    }
    ; TrayTip, % "Debug", % "RenderVideo " videoName " end", 1, 1
    Return success
}

PrepareRenderVRSide(mmdWin, videoName, viewpointModel, side, eye) {
    success := true
    try {
        if (viewpointModel) {
            ; Set the camera to follow the correct eye bone
            eyeBone := "Viewpoint_" . eye
            Control, ChooseString, %eyeBone%, ComboBox6, ahk_id %mmdWin%
            ClickWithDelayChange("Button32", "ahk_id " mmdWin)
            ; Ensure EquirectangularX is selected in the accessory panel
            Control, ChooseString, % "EquirectangularX", ComboBox7, ahk_id %mmdWin%
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
    } catch {
        success := false
        TrayTip % "Error", % "Problem setting up the camera settings for VR", 2, 3
    }
    
    Return success
}

SetVRCameraParams(mmdWin, videoName, rotX, rotY, accRx, accRy, angle := 92) {
    success := true
    WinActivate, ahk_id %mmdWin%
    WinWaitActive, ahk_id %mmdWin%,, 5
    if(ErrorLevel) {
        success := false
        TrayTip % "Error", % "Problem setting camera parameters for " videoName, 3, 3
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

        ClickWithDelayChange("Button32", "ahk_id " mmdWin)
        ClickWithDelayChange("Button48", "ahk_id " mmdWin)
    }
    Return success
}

StartEncodingTask(job, ByRef task) {
    success := true
    try {
        scriptPid := 0
        scriptWin := 0
        encodingStarted := -1
        if (A_IsCompiled) {
            ; For the compiled exe we can get the PID directly from the Run command
            Run % A_WorkingDir . "\scripts\encode_video.exe " task.jobId " " task.taskId,,, scriptPid
            WinWait, ahk_pid %scriptPid%,, 10
            encodingStarted := A_TickCount
            WinGet, scriptWin, ID, ahk_pid %scriptPid%
        } else {
            toolsDir := A_WorkingDir
            toolsDirClean := StrReplace(toolsDir, ":")
            toolsDirBash := "/" . StrReplace(toolsDirClean, "\", "/")
            pythonScript := toolsDirBash . "/scripts/python/encode_video.py"
            Run % "C:\msys64\usr\bin\mintty.exe /bin/env MSYSTEM=MINGW64 /bin/bash -l """ toolsDirBash "/scripts/bash/python_launcher.sh"" " pythonScript " "  task.jobId " " task.taskId
            ; When running the script in MinGW we need to lookup the cli window using a tag
            exeLookup := "mintty.exe"
            idSep := ":"
            idTag := "[" . job.jobShortId . idSep . task.taskShortId . "]"
            WinWait, %idTag% ahk_exe %exeLookup%,, 10
            encodingStarted := A_TickCount
            WinGet, scriptPid, PID, %idTag% ahk_exe %exeLookup%
            WinGet, scriptWin, ID, ahk_pid %scriptPid%
        }

        timeBeforeCheckHung := 15 * 60 * 1000 ; 15 minutes in millis
        periodOfGrace := 5 * 60 * 1000 ; 5 minutes
        hungStart := -1
        ; Wait for the script to finish
        oldStatus := task.taskStatus
        while (oldStatus == task.taskStatus) {
            encodingEllapsed := A_TickCount - encodingStarted
            if (encodingEllapsed > timeBeforeCheckHung && scriptWin) {
                ; After 15 minutes start checking if the process froze
                isHung := IsHungWindow(scriptWin)
                if(IsHung == 0) {
                    ; It has recovered within the period of grace. Keep it going
                    hungStart := -1
                }
                if(hungStart != -1) {
                    hungEllapsed := hungStart - A_TickCount
                    if(hungEllapsed > periodOfGrace) {
                        Process, Close, %scriptPid%
                        MsgBox, 0x10, % "Error", % "The encoding script froze and had to be killed"
                        ExitApp, 1
                    }
                } else {
                    if(IsHung == 1) {
                        hungStart := A_TickCount
                    }
                }
            }
            PullTaskStatus(task)
            Sleep, 100
        }
        if(task.taskStatus == TaskData.STATUS_ERROR) {
            success := false
            TrayTip % "Error", % "Encoding task finished with errors", 2, 3
        }
    } catch {
        success := false
        TrayTip % "Error", % "Unknown error during encoding", 2, 3
    }
    Return success
}

StartInjectMetadataTask(ByRef job, ByRef task, videoFile) {
    success := true
    try {
        scriptPid := 0
        scriptWin := 0
        taskStarted := -1
        if (A_IsCompiled) {
            ; For the compiled exe we can get the PID directly from the Run command
            Run % A_WorkingDir . "\scripts\inject_metadata.exe " task.jobId " " task.taskId " """ videoFile """",,, scriptPid
            WinWait, ahk_pid %scriptPid%,, 10
            taskStarted := A_TickCount
            WinGet, scriptWin, ID, ahk_pid %scriptPid%
        } else {
            toolsDir := A_WorkingDir
            toolsDirClean := StrReplace(toolsDir, ":")
            toolsDirBash := "/" . StrReplace(toolsDirClean, "\", "/")
            pythonScript := toolsDirBash . "/scripts/python/inject_metadata.py"
            Run % "C:\msys64\usr\bin\mintty.exe /bin/env MSYSTEM=MINGW64 /bin/bash -l """ toolsDirBash "/scripts/bash/python_launcher.sh"" " pythonScript " "  task.jobId " " task.taskId " '" videoFile "'"
            ; When running the script in MinGW we need to lookup the cli window using a tag
            exeLookup := "mintty.exe"
            idSep := ":"
            idTag := "[" . job.jobShortId . idSep . task.taskShortId . "]"
            WinWait, %idTag% ahk_exe %exeLookup%,, 10
            taskStarted := A_TickCount
            WinGet, scriptPid, PID, %idTag% ahk_exe %exeLookup%
            WinGet, scriptWin, ID, ahk_pid %scriptPid%
        }

        timeBeforeCheckHung := 10 * 60 * 1000 ; 10 minutes in millis
        periodOfGrace := 5 * 60 * 1000 ; 5 minute
        hungStart := -1
        ; Wait for the script to finish
        oldStatus := task.taskStatus
        while (oldStatus == task.taskStatus) {
            taskEllapsed := A_TickCount - taskStarted
            if (taskEllapsed > timeBeforeCheckHung && scriptWin) {
                ; After 15 minutes start checking if the process froze
                isHung := IsHungWindow(scriptWin)
                if(IsHung == 0) {
                    ; It has recovered within the period of grace. Keep it going
                    hungStart := -1
                }
                if(hungStart != -1) {
                    hungEllapsed := hungStart - A_TickCount
                    if(hungEllapsed > periodOfGrace) {
                        Process, Close, %scriptPid%
                        MsgBox, 0x10, % "Error", % "The encoding script froze and had to be killed"
                        ExitApp, 1
                    }
                } else {
                    if(IsHung == 1) {
                        hungStart := A_TickCount
                    }
                }
            }
            PullTaskStatus(task)
            Sleep, 100
        }

        if(task.taskStatus == TaskData.STATUS_ERROR) {
            success := false
            TrayTip % "Error", % "Encoding task finished with errors", 2, 3
        }
    } catch {
        success := false
        TrayTip % "Error", % "Unknown error while injecting the metadata", 2, 3
    }
    Return success
}

CreateStagingDir(job, ByRef outFullpath) {
    success := true
    try {
        if(!InStr(FileExist(WORKDIR_PREFIX . "staging\" . job.jobId), "D")) {
            FileCreateDir % WORKDIR_PREFIX "staging\" job.jobId
        }
        outFullPath := A_WorkingDir . "\" . WORKDIR_PREFIX . "staging\" . job.jobId
    } catch e {
        success := false
        TrayTip % "Error creating directory", % "Error creating staging directory for: " job.jobId, 3, 3
    }
    Return success
}

ClickWithDelayChange(controlParam, winTitle, delayBefore := -1, delayAfter := 100) {
    SetControlDelay, %delayBefore%
    ControlClick, %controlParam%, %winTitle%
    SetControlDelay, %delayAfter%
    Sleep, %delayAfter%
}

ExtractStartEndFrames(mmdWin, ByRef startFrame, ByRef endFrame) {
    success := false
    errorThrown := false
    try {
        ; Get the start and end frames from the "play" panel
        ControlGetText, startStr, Edit19, ahk_id %mmdWin%
        ControlGetText, endStr, Edit20, ahk_id %mmdWin%
        startFrame := startStr?startStr:0
        endFrame := endStr 
        if(!endStr) {
            ; Determine the end frame by clicking the go to last frame button 
            ; and extracting the value from the EditText
            ClickWithDelayChange("Button8", "ahk_id " mmdWin)
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
    } catch {
        errorThrown := true
        TrayTip % "Warning", % "Problem extracting start-end frames, defaulting to 0-300", 2, 2
        startFrame := 0
        endFrame := 300
    }
    if(!success && !errorThrown) {
        TrayTip % "Warning", % "Unknown problem extracting start-end frames, defaulting to 0-300", 2, 2
        startFrame := 0
        endFrame := 300
    }
    Return success
}

ExtractResolution(mmdWin, ByRef width, ByRef height) {
    success := true
    txtPid := 0
    try {
        ; Get the PID to find the dialogs opened
        WinGet, mmdPid, PID, ahk_id %mmdWin%

        ; Just to be sure the WinMenuSelectItem works, activate the MMD window first
        ; this way we ensure it is in a "non-minimized" state. See: https://www.autohotkey.com/docs/commands/WinMenuSelectItem.htm
        WinActivate, ahk_id %mmdWin%
        WinWaitActive, ahk_id %mmdWin%,, 5
        if (ErrorLevel) {
            success := false
        }

        if(success) {
            Run % "notepad.exe data\placeholder.txt",,, txtPid
            WinWait, ahk_pid %txtPid%,, 5
            if (ErrorLevel) {
                success := false
            }
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
            if (ErrorLevel) {
                success := false
            }
            
        }
        if(txtPid) {
            WinKill, ahk_pid %txtPid%
        }
        if(success) {
            WinGet, dialogId, ID, screen size ahk_pid %mmdPid%
            ControlGetText, widthStr, Edit1, ahk_id %dialogId%
            ControlGetText, heightStr, Edit2, ahk_id %dialogId%
            ; Multiply by one to force a cast to integer
            width := widthStr * 1
            height := heightStr * 1
            ; Cancel the dialog
            ClickWithDelayChange("Button2", "ahk_id " . dialogId)
        } else {
            success := FatalError()
            TrayTip % "Error", % "Couldn't extract the width and height", 2, 3
        }
    } catch {
        TrayTip % "Error", % "Couldn't extract the width and height", 2, 3
        success := FatalError()
        if(txtPidAux) {
            WinKill, ahk_pid %txtPid%
        }
    }
    Return success
}

DetermineJobDataFromMMD(ByRef job, mmdWin) {
    success := true
    videoName := DetermineVideoBaseName(mmdWin, pmmFile)
    job.baseVideoName := videoName
    job.pmmFile := pmmFile
    aux := ExtractStartEndFrames(mmdWin, startFrame, endFrame)
    success :=  (IsFatalError(success) || IsFatalError(aux))?FatalError():(success && aux)
    job.recordingFrames := [startFrame, endFrame]
    aux := ExtractResolution(mmdWin, width, height)
    success := (IsFatalError(success) || IsFatalError(aux))?FatalError():(success && aux) 
    job.resolution := [width, height]
    Return success
}

DetermineMMDExecutablePath(mmdWin) {
    mmdPath := ""
    if (mmdWin) {
        WinGet, procPath, ProcessPath, ahk_id %mmdWin%
        if(procPath) {
            mmdPath := procPath
        }
    }
    Return mmdPath
}

; Retrieves the name of the the Viewpoint model, if it is used
FindViewpointModelName(mmdWin, videoName) {
    found := ""
    try {
        ; Switch to camera / acc
        Control, ChooseString, % "camera", ComboBox3, ahk_id %mmdWin%
        ; Get the followbone model
        ControlGetText, followModel, ComboBox5, ahk_id %mmdWin%
        if (InStr(followModel, "Viewpoint")) {
            ; We only accept the translated version of the viewpoint model
            found := followModel
        } else {
            ; Try to select the viewpoint model
            Control, ChooseString, % "Viewpoint", ComboBox3, ahk_id %mmdWin%
            if (InStr(followModel, "Viewpoint")) {
                ClickWithDelayChange("Button32", "ahk_id " mmdWin)
                found := followModel
            }
        }
    } catch {

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
DetermineVideoBaseName(mmdWin, ByRef pmmFullPath) {
    Random, rand1, 1, 99999
    videoTitle := "mmd_" . A_Now . "_" . Format("{:05d}", rand1)
    WinGetTitle, mmdTitle, ahk_id %mmdWin%
    pmmFullPath := ""
    if(RegExMatch(mmdTitle, "\[(.*?\.pmm)\]", extracted)) {
        pmmFullPath := extracted1
        SplitPath, pmmFullPath,,,, pmmFileName
        videoTitle := pmmFileName
    }
    Return videoTitle
}

IsHungWindow(win) {
    result := 0
    try {
        if(DllCall("IsHungAppWindow", "Ptr", win)) {
            result := 1
        }
    } catch {
        result := -1
    }
    Return result
}

InitPhase()

^#q::
MsgBox, 0x24, % "Confimation", % "Do you want to abort the process?"
IfMsgBox, Yes 
{
    ExitApp
}