
import re
import sys
import ctypes
import os
from configparser import ConfigParser
import openshot

tools_dir = None
user_prefs = None
workdir_prefix = 'workDir'
cli_id_tag = ''

if getattr(sys, 'frozen', False):
    # It's a frozen executable, use the executable path to
    # determine the tools dir
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(sys.executable)) + '/..')
    workdir_prefix = ''
else:
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + '/../..')

VR_FORMAT_NONE = -1
VR_FORMAT_180DEG = 1
VR_FORMAT_360DEG = 2
PREFERENCES_FILE = 'preferences.ini'

def vr_encode_side(job_data, task_data):
    resolution = []
    resolution_str = job_data.get('General', 'resolution', fallback=None)
    if(resolution_str is not None and ',' in resolution_str):
        resolution = list([int(x) for x in resolution_str.split(',')])
    print('Resolution is {:d}x{:d}'.format(*resolution))
    original_frame_range = []
    recording_frames_str = job_data.get('General', 'recordingFrames', fallback=None)
    if (recording_frames_str is not None and ',' in recording_frames_str):
        original_frame_range = list([int(x) for x in recording_frames_str.split(',')])
    fps = job_data.getint('General', 'fps', fallback=60)
    sides_per_eye = job_data.getint('General', 'sidesPerEye', fallback=5)
    eye = task_data.get('General', 'side', fallback='L')
    base_video_name = job_data.get('General', 'baseVideoName', fallback='My video')
    staging_folder = os.path.join(tools_dir, workdir_prefix, 'staging', job_data['General']['jobId'])
    out_prefix = eye + '_encoded_'
    vr_format = job_data.getint('General', 'VRFormat', fallback=VR_FORMAT_180DEG)
    original_frame_diff = original_frame_range[1] - original_frame_range[0]
    original_frame_count = original_frame_diff * (fps // 30) + 1
    adjusted_frame_range = [original_frame_range[0] * (fps // 30) + 1, original_frame_range[1] * (fps // 30) + 1]
    target_bitrate = 15000000
    encode_audio = (eye == 'L')

    vr_sides = ['L', 'R', 'T', 'B', 'F', '1', '2', '3', '4']
    print('Preparing for encoding')
    t = openshot.Timeline(int(resolution[0]), int(resolution[1]), openshot.Fraction(fps,1), 48000, 2, openshot.LAYOUT_STEREO)
    t.Open()
    print('Timeline opened')

    # Code auto-generated because we need all the variables defined in the same scope
    v1 = staging_folder + "/" + eye + vr_sides[0] + '_' + base_video_name + '.avi'
    fr1 = openshot.FFmpegReader(v1)
    c1 = openshot.Clip(fr1)
    c1.Layer(1)
    print('Clip created')
    print('Adding clip')
    t.AddClip(c1)
    print('Clip added')
    mp1 = resolve_vr_mask_path(resolution[1], vr_sides[0], vr_format)
    mr1 = openshot.QtImageReader(mp1)
    br1 = openshot.Keyframe()
    br1.AddPoint(1, 0.0, openshot.LINEAR)
    co1 = openshot.Keyframe()
    co1.AddPoint(1, 0.0, openshot.LINEAR)
    m1 = openshot.Mask(mr1, br1, co1)
    m1.Layer(1)
    m1.End(fr1.info.duration)
    print('Mask created')
    t.AddEffect(m1)

    v2 = staging_folder + "/" + eye + vr_sides[1] + '_' + base_video_name + '.avi'
    fr2 = openshot.FFmpegReader(v2)
    c2 = openshot.Clip(fr2)
    c2.Layer(2)
    print('Clip created')
    print('Adding clip')
    t.AddClip(c2)
    print('Clip added')
    mp2 = resolve_vr_mask_path(resolution[1], vr_sides[1], vr_format)
    mr2 = openshot.QtImageReader(mp2)
    br2 = openshot.Keyframe()
    br2.AddPoint(1, 0.0, openshot.LINEAR)
    co2 = openshot.Keyframe()
    co2.AddPoint(1, 0.0, openshot.LINEAR)
    m2 = openshot.Mask(mr2, br2, co2)
    m2.Layer(2)
    m2.End(fr2.info.duration)
    print('Mask created')
    t.AddEffect(m2)

    v3 = staging_folder + "/" + eye + vr_sides[2] + '_' + base_video_name + '.avi'
    fr3 = openshot.FFmpegReader(v3)
    c3 = openshot.Clip(fr3)
    c3.Layer(3)
    print('Clip created')
    print('Adding clip')
    t.AddClip(c3)
    print('Clip added')
    mp3 = resolve_vr_mask_path(resolution[1], vr_sides[2], vr_format)
    mr3 = openshot.QtImageReader(mp3)
    br3 = openshot.Keyframe()
    br3.AddPoint(1, 0.0, openshot.LINEAR)
    co3 = openshot.Keyframe()
    co3.AddPoint(1, 0.0, openshot.LINEAR)
    m3 = openshot.Mask(mr3, br3, co3)
    m3.Layer(3)
    m3.End(fr3.info.duration)
    print('Mask created')
    t.AddEffect(m3)

    v4 = staging_folder + "/" + eye + vr_sides[3] + '_' + base_video_name + '.avi'
    fr4 = openshot.FFmpegReader(v4)
    c4 = openshot.Clip(fr4)
    c4.Layer(4)
    print('Clip created')
    print('Adding clip')
    t.AddClip(c4)
    print('Clip added')
    mp4 = resolve_vr_mask_path(resolution[1], vr_sides[3], vr_format)
    mr4 = openshot.QtImageReader(mp4)
    br4 = openshot.Keyframe()
    br4.AddPoint(1, 0.0, openshot.LINEAR)
    co4 = openshot.Keyframe()
    co4.AddPoint(1, 0.0, openshot.LINEAR)
    m4 = openshot.Mask(mr4, br4, co4)
    m4.Layer(4)
    m4.End(fr4.info.duration)
    print('Mask created')
    t.AddEffect(m4)

    if sides_per_eye >= 5:
        v5 = staging_folder + "/" + eye + vr_sides[4] + '_' + base_video_name + '.avi'
        fr5 = openshot.FFmpegReader(v5)
        c5 = openshot.Clip(fr5)
        c5.Layer(5)
        print('Clip created')
        print('Adding clip')
        t.AddClip(c5)
        print('Clip added')
        mp5 = resolve_vr_mask_path(resolution[1], vr_sides[4], vr_format)
        mr5 = openshot.QtImageReader(mp5)
        br5 = openshot.Keyframe()
        br5.AddPoint(1, 0.0, openshot.LINEAR)
        co5 = openshot.Keyframe()
        co5.AddPoint(1, 0.0, openshot.LINEAR)
        m5 = openshot.Mask(mr5, br5, co5)
        m5.Layer(5)
        m5.End(fr5.info.duration)
        print('Mask created')
        t.AddEffect(m5)

    if sides_per_eye >= 6:
        v6 = staging_folder + "/" + eye + vr_sides[5] + '_' + base_video_name + '.avi'
        fr6 = openshot.FFmpegReader(v6)
        c6 = openshot.Clip(fr6)
        c6.Layer(6)
        print('Clip created')
        print('Adding clip')
        t.AddClip(c6)
        print('Clip added')
        mp6 = resolve_vr_mask_path(resolution[1], vr_sides[5], vr_format)
        mr6 = openshot.QtImageReader(mp6)
        br6 = openshot.Keyframe()
        br6.AddPoint(1, 0.0, openshot.LINEAR)
        co6 = openshot.Keyframe()
        co6.AddPoint(1, 0.0, openshot.LINEAR)
        m6 = openshot.Mask(mr6, br6, co6)
        m6.Layer(6)
        m6.End(fr6.info.duration)
        print('Mask created')
        t.AddEffect(m6)

    if sides_per_eye >= 7:
        v7 = staging_folder + "/" + eye + vr_sides[6] + '_' + base_video_name + '.avi'
        fr7 = openshot.FFmpegReader(v7)
        c7 = openshot.Clip(fr7)
        c7.Layer(7)
        print('Clip created')
        print('Adding clip')
        t.AddClip(c7)
        print('Clip added')
        mp7 = resolve_vr_mask_path(resolution[1], vr_sides[6], vr_format)
        mr7 = openshot.QtImageReader(mp7)
        br7 = openshot.Keyframe()
        br7.AddPoint(1, 0.0, openshot.LINEAR)
        co7 = openshot.Keyframe()
        co7.AddPoint(1, 0.0, openshot.LINEAR)
        m7 = openshot.Mask(mr7, br7, co7)
        m7.Layer(7)
        m7.End(fr7.info.duration)
        print('Mask created')
        t.AddEffect(m7)

    if sides_per_eye >= 8:
        v8 = staging_folder + "/" + eye + vr_sides[7] + '_' + base_video_name + '.avi'
        fr8 = openshot.FFmpegReader(v8)
        c8 = openshot.Clip(fr8)
        c8.Layer(8)
        print('Clip created')
        print('Adding clip')
        t.AddClip(c8)
        print('Clip added')
        mp8 = resolve_vr_mask_path(resolution[1], vr_sides[7], vr_format)
        mr8 = openshot.QtImageReader(mp8)
        br8 = openshot.Keyframe()
        br8.AddPoint(1, 0.0, openshot.LINEAR)
        co8 = openshot.Keyframe()
        co8.AddPoint(1, 0.0, openshot.LINEAR)
        m8 = openshot.Mask(mr8, br8, co8)
        m8.Layer(8)
        m8.End(fr8.info.duration)
        print('Mask created')
        t.AddEffect(m8)
    # End auto-generated code

    w = openshot.FFmpegWriter(staging_folder + '/' + out_prefix + base_video_name + '.mp4')
    w.SetVideoOptions(True, "libx264", openshot.Fraction(fps, 1), resolution[0], resolution[1],
                  openshot.Fraction(1, 1), False, False, target_bitrate)
    if encode_audio:
        w.SetAudioOptions(True, "aac", t.info.sample_rate, t.info.channels, t.info.channel_layout, 192000)
    
    w.PrepareStreams()
    if target_bitrate >= 1500000:
        w.SetOption(openshot.VIDEO_STREAM, "qmin", '2')
        w.SetOption(openshot.VIDEO_STREAM, "qmax", '30')
    
    w.SetOption(openshot.VIDEO_STREAM, "muxing_preset", "mp4_faststart")
    w.Open()
    print("Start encoding...")
    print("Number of frames: {:d}".format(original_frame_count))
    encoded_frames = 0
    for i in range(adjusted_frame_range[0], adjusted_frame_range[1] + 1):
        f = t.GetFrame(i)
        w.WriteFrame(f)
        encoded_frames += 1
        if (encoded_frames == 1 or encoded_frames % 10 == 0):
            print()
            progress_info = "Encoded {:d} of {:d} frames".format(encoded_frames, original_frame_count)
            print(progress_info)
            change_cli_title(progress_info)

    w.Close()
    t.Close()
    print("Encoding finished")

def resolve_vr_mask_path(height, side='L', vr_format=1):
    print('resolve_vr_mask_path start')
    mask_path = None
    s = side.lower()
    masks_dir = tools_dir + '/data/masks'
    if(vr_format == VR_FORMAT_180DEG):
        mask_path = masks_dir + '/vr_180_' + str(height) + '_' + s + '.png'
    elif(vr_format == VR_FORMAT_360DEG):
        pass
    return mask_path

def vr_encode_final(job_data):
    print('vr_encode_final')
    resolution_per_eye = []
    resolution = []
    resolution_str = job_data.get('General', 'resolution', fallback=None)
    if resolution_str is not None and ',' in resolution_str:
        resolution_per_eye = list([int(x) for x in resolution_str.split(',')])
    original_frame_range = []
    recording_frames_str = job_data.get('General', 'recordingFrames', fallback=None)
    if (recording_frames_str is not None and ',' in recording_frames_str):
        original_frame_range = list([int(x) for x in recording_frames_str.split(',')])
    fps = job_data.getint('General', 'fps', fallback=60)
    base_video_name = job_data.get('General', 'baseVideoName', fallback='My video')
    vr_format = job_data.getint('General', 'VRFormat', fallback=VR_FORMAT_180DEG)
    original_frame_diff = original_frame_range[1] - original_frame_range[0]
    original_frame_count = original_frame_diff * (fps // 30) + 1
    adjusted_frame_range = [original_frame_range[0] * (fps // 30) + 1, original_frame_range[1] * (fps // 30) + 1]
    target_bitrate = 15000000
    if vr_format == VR_FORMAT_180DEG:
        # Left-right layout for 180 deg
        resolution = [resolution_per_eye[0] * 2, resolution_per_eye[1]]
    else:
        # Top-bottom layout for 360 deg
        resolution = [resolution_per_eye[0], resolution_per_eye[1] * 2]
    staging_folder = os.path.join(tools_dir, workdir_prefix, 'staging', job_data['General']['jobId'])
    out_folder = determine_output_dir(job_data)
    if not os.path.isdir(out_folder):
        os.makedirs(out_folder)
    
    print('Preparing for encoding')
    t = openshot.Timeline(int(resolution[0]), int(resolution[1]), openshot.Fraction(fps,1), 48000, 2, openshot.LAYOUT_STEREO)
    t.Open()

    lv = openshot.FFmpegReader(staging_folder + '/L_encoded_' + base_video_name + '.mp4')
    lv.Open()
    lv.DisplayInfo()
    lc = openshot.Clip(lv)
    lc.Layer(1)
    lc.scale = openshot.SCALE_FIT

    rv = openshot.FFmpegReader(staging_folder + '/R_encoded_' + base_video_name + '.mp4')
    rc = openshot.Clip(rv)
    rc.Layer(2)
    rc.scale = openshot.SCALE_FIT
    mute_audio = openshot.Keyframe()
    mute_audio.AddPoint(1, 0.0, openshot.LINEAR)
    rc.has_audio = mute_audio

    if vr_format == VR_FORMAT_180DEG:
        lc.gravity = openshot.GRAVITY_LEFT
        rc.gravity = openshot.GRAVITY_RIGHT
    else:
        lc.gravity = openshot.GRAVITY_TOP
        rc.gravity = openshot.GRAVITY_BOTTOM

    print('Adding clips')
    t.AddClip(lc)
    t.AddClip(rc)
    print('Clips added')

    w = openshot.FFmpegWriter(get_safe_filename(out_folder, base_video_name))
    w.SetAudioOptions(True, "aac", t.info.sample_rate, t.info.channels, t.info.channel_layout, 192000)
    w.SetVideoOptions(True, "libx264", openshot.Fraction(fps, 1), resolution[0], resolution[1],
                  openshot.Fraction(1, 1), False, False, target_bitrate)
    
    w.PrepareStreams()
    if target_bitrate >= 1500000:
        w.SetOption(openshot.VIDEO_STREAM, "qmin", '2')
        w.SetOption(openshot.VIDEO_STREAM, "qmax", '30')
    
    w.SetOption(openshot.VIDEO_STREAM, "muxing_preset", "mp4_faststart")
    w.Open()
    print("Start encoding...")
    print("Number of frames: {:d}".format(original_frame_count))
    encoded_frames = 0
    for i in range(adjusted_frame_range[0], adjusted_frame_range[1] + 1):
        f = t.GetFrame(i)
        w.WriteFrame(f)
        encoded_frames += 1
        if (encoded_frames == 1 or encoded_frames % 10 == 0):
            progress_info = "Encoded {:d} of {:d} frames".format(encoded_frames, original_frame_count)
            print(progress_info)
            change_cli_title(progress_info)
    w.Close()
    t.Close()
    print('Encoding finished')

def determine_output_dir(job_data):
    out_dir = job_data.get('General', 'finalVideoOutDir', fallback='')
    if len(out_dir) == 0 and user_prefs is not None:
        out_dir = user_prefs.get('Encoding', 'finalVideoOutDir', fallback='')
    if len(out_dir) == 0:
        out_dir = os.path.join(tools_dir, 'out')
    return out_dir

def get_safe_filename(directory, base_name, ext='.mp4'):
    fname = os.path.join(directory, base_name + ext)
    i = 1
    while os.path.exists(fname):
        fname = os.path.join(directory, base_name + '({:d})'.format(i) + ext)
        i += 1
    return fname

def update_task_status(task_data, out_file, new_status=9):
    task_data.set('General', 'taskStatus', str(new_status))
    with open(out_file, 'wt', encoding='utf-16') as fp:
        task_data.write(fp, False)

def change_cli_title(new_title:str):
    if getattr(sys, 'frozen', False):
        ctypes.windll.kernel32.SetConsoleTitleW(new_title + ' ' + cli_id_tag)
    else:
        sys.stdout.write("\x1b]2;{:s}\x07".format(new_title + ' ' + cli_id_tag))

if getattr(sys, 'frozen', False) or __name__ == '__main__':
    print("tools dir is: " + tools_dir)
    job_file_name = sys.argv[1] 
    task_file_name = sys.argv[2]
    job_file = os.path.join(tools_dir, workdir_prefix, 'jobs', job_file_name, 'main.ini')
    task_file = os.path.join(tools_dir, workdir_prefix, 'jobs', job_file_name, task_file_name + ".ini")
    print("the task file name should be: " + task_file)
    task_data = None
    job_data = None
    if os.path.isfile(tools_dir+'/'+PREFERENCES_FILE):
        user_prefs = ConfigParser()
        user_prefs.optionxform = lambda opt: str(opt)
        user_prefs.read(tools_dir+'/'+PREFERENCES_FILE, 'utf-16')
    if os.path.isfile(task_file):
        print('Task file found')
        task_data = ConfigParser()
        task_data.optionxform = lambda opt: str(opt)
        task_data.read(task_file, 'utf-16')

    if task_data is not None:
        if os.path.isfile(job_file):
            print('Job file found')
            job_data = ConfigParser()
            job_data.optionxform = lambda opt: str(opt)
            job_data.read(job_file, 'utf-16')

    if job_data is not None:
        print('Job and task data successfully parsed')
        job_short_id = job_data.get('General', 'jobShortId', fallback="000")
        task_short_id = task_data.get('General', 'taskShortId', fallback="000")
        id_sep = ':'
        cli_id_tag = "[{:s}{:s}{:s}]".format(job_short_id, id_sep, task_short_id)
        change_cli_title("Encoding...")
        try:
            if(job_data.getint('General', 'VRFormat', fallback=VR_FORMAT_180DEG) != VR_FORMAT_NONE):
                if(task_data.get('General', 'side', fallback='L')) == 'F':
                    vr_encode_final(job_data)
                else:
                    vr_encode_side(job_data, task_data)
            update_task_status(task_data, task_file)
        except Exception as e:
            print(type(e).__name__ + ': ' + str(e))
            update_task_status(task_data, task_file, -1)
            sys.exit(1)
