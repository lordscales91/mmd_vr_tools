import os
import sys
import struct
import ctypes
from configparser import ConfigParser
from typing import List
from spatialmedia import mpeg
from spatialmedia.mpeg.constants import *

tools_dir = None
user_prefs = None
workdir_prefix = 'workDir'
cli_id_tag = ''

VR_FORMAT_NONE = -1
VR_FORMAT_180DEG = 1
VR_FORMAT_360DEG = 2
PREFERENCES_FILE = 'preferences.ini'
TOOLSET_NAME = 'MMD VR Tools'

if getattr(sys, 'frozen', False):
    # It's a frozen executable, use the executable path to
    # determine the tools dir
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(sys.executable)) + '/..')
    workdir_prefix = ''
else:
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + '/../..')

def inject_metadata(infile: str, job_data:ConfigParser):
    if os.path.isfile(infile):
        resolution = []
        resolution_str = job_data.get('General', 'resolution', fallback=None)
        if(resolution_str is not None and ',' in resolution_str):
            resolution = list([int(x) for x in resolution_str.split(',')])
        else:
            raise Exception("Wrong resolution!!")
        
        with open(infile, 'rb') as in_fh:
            # Load the input file
            mpeg4_file = mpeg.load(in_fh)

            # Generate the metadata
            cropped_area_img_width = resolution[0]
            cropped_area_img_height = resolution[1]
            full_pano_width = resolution[0]
            full_pano_height = resolution[1]
            cropped_area_left = 0
            cropped_area_top = 0
            vr_format = job_data.getint('General', 'VRFormat', fallback=VR_FORMAT_180DEG)
            stereo_mode = 'left-right'
            if vr_format == VR_FORMAT_180DEG:
                cropped_area_img_width = resolution[0] * 2
                full_pano_width = resolution[0] * 4
                cropped_area_left = resolution[0]

            crop_args = [cropped_area_img_width, cropped_area_img_height, full_pano_width, full_pano_height,
                cropped_area_left, cropped_area_top]
            metadata_v1 = generate_v1_metadata(stereo_mode, *crop_args)
            metadata_v2 = generate_v2_metadata(stereo_mode)

            # Get the proper boxex to inject the data
            video_trak = find_video_trak(mpeg4_file.moov_box, in_fh)
            avc1_box = find_atom_box(mpeg4_file.moov_box)
            if avc1_box is None and video_trak is None:
                raise Exception("Couldn't find a box to inject the metadata. The video is likely corrupted.")
            # Inject the metadata
            if video_trak is not None:
                video_trak.add(metadata_v1)
            if isinstance(avc1_box, mpeg.Container):
                for b in metadata_v2:
                    avc1_box.add(b)
            mpeg4_file.resize()

            # Save the result as a new file
            parent_dir = os.path.dirname(infile)
            fname_parts = os.path.splitext(os.path.basename(infile))
            out_file = get_safe_filename(parent_dir, fname_parts[0]+'_injected', fname_parts[1])
            with open(out_file, 'wb') as out_fh:
                mpeg4_file.save(in_fh, out_fh)
                print('Done!')
                return out_file
    else:
        raise Exception("Input file not found")

def generate_v1_metadata(stereo:str=None, *crop) -> mpeg.Box:
    additional_xml = ""
    if stereo == "top-bottom":
        additional_xml += SPHERICAL_XML_CONTENTS_TOP_BOTTOM

    if stereo == "left-right":
        additional_xml += SPHERICAL_XML_CONTENTS_LEFT_RIGHT
    
    if len(crop) == 6:
        additional_xml += SPHERICAL_XML_CONTENTS_CROP_FORMAT.format(*crop)

    spherical_xml = (SPHERICAL_XML_HEADER +
                     SPHERICAL_XML_CONTENTS_FORMAT.format(TOOLSET_NAME) +
                     # SPHERICAL_XML_CONTENTS +
                     additional_xml +
                     SPHERICAL_XML_FOOTER)
    uuid_box = mpeg.Box()
    uuid_box.header_size = 8
    uuid_box.name = TAG_UUID
    uuid_box.set(SPHERICAL_UUID_ID + spherical_xml.encode('utf8'))
    return uuid_box

def generate_v2_metadata(stereo:str=None) -> List[mpeg.Box]:
    contents = []
    stereo_mode = 0
    if stereo == "top-bottom":
        stereo_mode = 1
    if stereo == "left-right":
        stereo_mode = 2
    
    # Stereoscopic 3D Video Box (st3d)
    st3d_box = mpeg.Box()
    st3d_box.header_size = 8
    st3d_box.name = b'st3d'
    # Fullbox spec as defined in the ISOBMFF has 4 bytes before the content.
    # 1 byte for the version and 3 for flags. To simplify we just pack a 4-byte integer 0
    st3d_box.set(struct.pack('iB', 0, stereo_mode))
    contents.append(st3d_box)

    # Spherical Video Box (sv3d)
    sv3d_box = mpeg.Container()
    sv3d_box.header_size = 8
    sv3d_box.name = b'sv3d'
    sv3d_box.contents = []
    contents.append(sv3d_box)

    # Spherical Video Header (svhd)
    svhd_box = mpeg.Box()
    svhd_box.header_size = 8
    svhd_box.name = b'svhd'
    metadata_source = TOOLSET_NAME.encode('utf8')
    svhd_box.set(struct.pack('>i{:d}sB'.format(len(metadata_source)), 0, metadata_source, 0))
    # svhd_box.set(struct.pack('>iB', 0, 0))
    sv3d_box.contents.append(svhd_box)

    # Projection Box (proj)
    proj_box = mpeg.Container()
    proj_box.header_size = 8
    proj_box.name = b'proj'
    proj_box.contents = []
    sv3d_box.contents.append(proj_box)

    # Projection Header Box (prhd)
    prhd_box = mpeg.Box()
    prhd_box.header_size = 8
    prhd_box.name = b'prhd'
    prhd_box.set(struct.pack('>4i', *([0] * 4))) # Just set all values to 0
    proj_box.contents.append(prhd_box)

    # Projection Data Box
    # Equirectangular Projection Box (equi)
    equi_box = mpeg.Box()
    equi_box.header_size = 8
    equi_box.name = b'equi'
    # Not sure what the hell is this, but Google's VR 180 creator seems to always add these values at the end regardless of the video resolution
    unknown_bytes = b'\x40\x00\x00\x00'
    equi_box.set(struct.pack('>3i', *([0] * 3)) + unknown_bytes + unknown_bytes)
    proj_box.contents.append(equi_box)

    return contents

def find_atom_box(root:mpeg.Container, min_offset:int = 0, box_name=b'avc1') -> mpeg.Box:
    found = None
    if isinstance(root.contents, list):
        for item in root.contents:
            if item.name == box_name and item.position >= min_offset:
                found = item
                break
            elif isinstance(item, mpeg.Container):
                found = find_atom_box(item, min_offset, box_name)
                if found is not None:
                    break
    return found

def find_video_trak(root:mpeg.Container, fh) -> mpeg.Container:
    offset = root.position
    max_offset = offset + root.size()
    found = None
    while found is None and offset < max_offset:
        item = find_atom_box(root, offset, TAG_TRAK)
        if item is not None:
            offset = item.position
            # Found the first trak, get the VideoHandler to determine the type
            item_hdlr = find_atom_box(item, offset, TAG_HDLR)
            if item_hdlr is not None:
                offset = item_hdlr.content_start() + 8
                fh.seek(offset)
                if fh.read(4) == TRAK_TYPE_VIDE:
                    found = item
                else:
                    # Weird, but it's not the video track, try with the next one
                    offset = item.position + item.size()
            else:
                # No video handler found, break the loop
                offset = max_offset
        else:
            # No tracks found
            offset = max_offset

    return found

def get_safe_filename(directory, base_name, ext='.mp4'):
    fname = os.path.join(directory, base_name + ext)
    i = 1
    while os.path.exists(fname):
        fname = os.path.join(directory, base_name + '({:d})'.format(i) + ext)
        i += 1
    return fname

def change_cli_title(new_title:str):
    if getattr(sys, 'frozen', False):
        ctypes.windll.kernel32.SetConsoleTitleW(new_title + ' ' + cli_id_tag)
    else:
        sys.stdout.write("\x1b]2;{:s}\x07".format(new_title + ' ' + cli_id_tag))

def update_task_status(task_data, out_file, new_status=9, task_result=''):
    task_data.set('General', 'taskStatus', str(new_status))
    if task_result is not None:
        task_data.set('General', 'taskResult', task_result)
    with open(out_file, 'wt', encoding='utf-16') as fp:
        task_data.write(fp, False)

if getattr(sys, 'frozen', False) or __name__ == '__main__':
    job_file_name = sys.argv[1] 
    task_file_name = sys.argv[2]
    input_video = sys.argv[3]
    job_file = os.path.join(tools_dir, workdir_prefix, 'jobs', job_file_name, 'main.ini')
    task_file = os.path.join(tools_dir, workdir_prefix, 'jobs', job_file_name, task_file_name + ".ini")
    print("the task file name should be: " + task_file)
    print('the input video is: ' + input_video)
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
        change_cli_title("Injecting metadata...")
        try:
            out_file = inject_metadata(input_video, job_data)
            update_task_status(task_data, task_file, task_result=out_file)
        except Exception as e:
            print(type(e).__name__ + ': ' + str(e))
            update_task_status(task_data, task_file, -1, str(e))
            sys.exit(1)
