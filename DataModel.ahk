class Preferences {
    ; Indicates if the intermediate files in staging should be deleted
    ; after the job finishes
    deleteStagingFiles:=0
    fps:=60
    renderCodec:="MJPEG"
    finalEncodingFormat:="MP4"
    finalEncodingQuality:="medium"
    finalVideoOutDir:=""
}

class UserPreferences extends Preferences {
    MMDExecutable:=""
}

class JobData extends Preferences {
    static STATUS_PENDING := 1
    static STATUS_PROCESSING := 2
    static STATUS_COMPLETED := 9
    static STATUS_ERROR := -1

    static VR_FORMAT_NONE := -1
    static VR_FORMAT_180DEG := 1
    static VR_FORMAT_360DEG := 2

    jobId:=""
    jobShortId:=-1
    jobStatus:=1
    pmmFile:=""
    baseVideoName:=""
    ; Possible values: -1 (Non-VR video), 0 (unset), 1 (180 deg), 2 (360 deg)
    VRFormat:=0
    ; If this is false the program will render a monoscopic VR video
    ; -1 (disabled), 0 (unset), 1 (enabled)
    parallaxEnabled:=0
    sidesPerEye:=0
    resolution:=""
    recordingFrames:=""
    tasks := ""
}

class TaskData {
    static T_RENDERING := 1
    static T_ENCODING := 2

    static STATUS_PENDING := 1
    static STATUS_PREPARING := 2
    static STATUS_PROCESSING := 3
    static STATUS_COMPLETED := 9
    static STATUS_ERROR := -1

    taskId:=""
    taskShortId:=-1
    taskType:=0
    taskStatus:=1
    jobId:=""
    side:=""
    dependsOn:=""
}

