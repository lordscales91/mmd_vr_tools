import os
from cx_Freeze import setup, Executable

build_exe_options = {}

basedir = os.path.dirname(__file__)

setup(
    name="mmd_vr_tools_scripts",
    version="0.0.1-beta",
    options={"build_exe": build_exe_options},
    executables=[Executable(os.path.join(basedir, "encode_video.py")), Executable(os.path.join(basedir, "camera_converter.py")), 
                Executable(os.path.join(basedir, "inject_metadata.py"))]
)