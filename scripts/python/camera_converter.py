import sys
import os
import math
from typing import List

from mmd_tools.core import vmd
from mmd_tools.core.vmd.helper import CameraInterpolation
from mmd_tools.geom.core import Matrix

tools_dir = None
user_prefs = None
workdir_prefix = 'workDir'

if getattr(sys, 'frozen', False):
    # It's a frozen executable, use the executable path to
    # determine the tools dir
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(sys.executable)) + '/..')
    workdir_prefix = ''
else:
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + '/../..')

def convert_camera_motion(motion: vmd.File, jobId:str = None, convert_interp:bool = False, apply_camera_dist_offset:bool = False, z_rot_min:float = -20.0, z_rot_max:float = 20.0):
    converted = vmd.File()
    converted.header = vmd.Header()
    converted.boneAnimation = vmd.BoneAnimation()
    center_bone_jp = 'センター'
    arm_bone_jp = 'アーム'
    model_name_jp = '視点ボーン'
    converted.header.model_name = model_name_jp
    converted.boneAnimation[center_bone_jp] = []
    converted.boneAnimation[arm_bone_jp] = []
    dummy_interp = dummy_interpolation()
    
    camAnim = motion.cameraAnimation
    num_frames = 0
    total_frames = len(camAnim)
    for camFrame in camAnim:
        centerBoneFrame = vmd.BoneFrameKey()
        centerBoneFrame.frame_number = camFrame.frame_number
        centerBoneFrame.location = camFrame.location
        rot_deg = [math.degrees(x) for x in camFrame.rotation]
        rot_deg[0] = -rot_deg[0]
        if rot_deg[2] < z_rot_min:
            rot_deg[2] = z_rot_min
        elif rot_deg[2] > z_rot_max:
            rot_deg[2] = z_rot_max
        mat = Matrix.rotation(*rot_deg)
        centerBoneFrame.rotation = mat.quaternions()
        camInterp = CameraInterpolation(camFrame.interp)
        if convert_interp:
            centerBoneFrame.interp = fill_interpolation_data(camInterp.interp_x, camInterp.interp_y, camInterp.interp_z, camInterp.interp_r)
        else:
            centerBoneFrame.interp = dummy_interp
        converted.boneAnimation[center_bone_jp].append(centerBoneFrame)
        
        armBoneFrame = vmd.BoneFrameKey()
        armBoneFrame.frame_number = camFrame.frame_number
        dist = camFrame.distance
        if apply_camera_dist_offset:
            sign = -1
            if dist >= 0:
                sign = 1
            dist = (abs(dist) / 3 + 4) * sign
            # dist = (math.tan(math.radians(camFrame.angle / 2) * abs(dist)) + 4) * sign
        armBoneFrame.location = [0, 0, dist]
        armBoneFrame.rotation = [0, 0, 0, 1]
        if convert_interp:
            armBoneFrame.interp = fill_interpolation_data(interp_z=camInterp.interp_dist)
        else:
            armBoneFrame.interp = dummy_interp
        converted.boneAnimation[arm_bone_jp].append(armBoneFrame)
        num_frames += 1
        if num_frames == 1 or num_frames % 10 == 0:
            print('Converted {:d} of {:d} frames.'.format(num_frames, total_frames))

    basedir = os.path.dirname(motion.filepath)
    base_name = os.path.splitext(motion.filepath)[0]
    out_filepath = get_safe_filename(basedir, base_name+'_converted_vr')
    converted.save(filepath=out_filepath)
    print('Saved successfully to: {:s}'.format(out_filepath))
    if jobId is not None:
        status_dir = os.path.join(tools_dir, workdir_prefix, 'status', 'completed')
        if not os.path.exists(status_dir):
            os.makedirs(status_dir)
        status_file = os.path.join(status_dir, jobId+'.main')
        with open(status_file, 'wt'):
            pass

def get_safe_filename(directory, base_name, ext='.vmd'):
    fname = os.path.join(directory, base_name + ext)
    i = 0
    while os.path.exists(fname):
        i += 1
        fname = os.path.join(directory, base_name + '({:d})'.format(i) + ext)
    return fname

def dummy_interpolation() -> List[int]:
    return fill_interpolation_data()

def fill_interpolation_data(interp_x: List[int] = [0x14,0x14,0x6b,0x6b], interp_y: List[int] = [0x14,0x14,0x6b,0x6b], 
                            interp_z: List[int] = [0x14,0x14,0x6b,0x6b], interp_r: List[int] = [0x14,0x14,0x6b,0x6b]) -> List[int]:
    ret = [0x00] * 64
    l = 0
    for j in range(4):
        for i in range(j, 16, 1):
            flag=i%4
            if flag == 0:
                ret[l] = interp_x[i//4]
            elif flag == 0:
                ret[l] = interp_y[i//4]
            elif flag == 0:
                ret[l] = interp_z[i//4]
            else:
                ret[l] = interp_r[i//4]
            l += 1
            
        for i in range(j):
            ret[l] = 0
            l += 1

    return ret

if getattr(sys, 'frozen', False) or __name__ == '__main__':
    # print(sys.argv)
    vmdPath = sys.argv[1]
    jobId = None
    if len(sys.argv) > 2 and len(sys.argv[2]) > 0:
        jobId = sys.argv[2]
    motion = vmd.File()
    motion.load(filepath=vmdPath)
    convert_camera_motion(motion, convert_interp=True, jobId=jobId, apply_camera_dist_offset=True)