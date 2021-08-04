"""
Since openshot has some weird bug which requires every variable to be declared and used within the 
same scope. This helper code generator will generate the necessary code
"""

def generate_encode_side(var_suffix, side_index, layer, indent_level=1, prepend_if = False, num_indent = 4, indent_char=' '):
    template = """{initial_indent_str:s}v{var_suffix:s} = staging_folder + "/" + eye + vr_sides[{side_index:d}] + '_' + base_video_name + '.avi'
{initial_indent_str:s}fr{var_suffix:s} = openshot.FFmpegReader(v{var_suffix:s})
{initial_indent_str:s}fr{var_suffix:s}.Open()
{initial_indent_str:s}if round(fr{var_suffix:s}.info.fps.ToFloat()) != fps:
{initial_indent_str:s}{indent_str:s}fr{var_suffix:s}.info.fps = fr{var_suffix:s}.info.video_timebase.Reciprocal()
{initial_indent_str:s}{indent_str:s}fr{var_suffix:s}.info.video_length = round(fr{var_suffix:s}.info.fps.ToFloat() * fr{var_suffix:s}.info.duration)
{initial_indent_str:s}c{var_suffix:s} = openshot.Clip(fr{var_suffix:s})
{initial_indent_str:s}c{var_suffix:s}.Layer({layer:d})
{initial_indent_str:s}print('Clip created')
{initial_indent_str:s}print('Adding clip')
{initial_indent_str:s}t.AddClip(c{var_suffix:s})
{initial_indent_str:s}print('Clip added')
{initial_indent_str:s}mp{var_suffix:s} = resolve_vr_mask_path(resolution[1], vr_sides[{side_index:d}], vr_format)
{initial_indent_str:s}mr{var_suffix:s} = openshot.QtImageReader(mp{var_suffix:s})
{initial_indent_str:s}br{var_suffix:s} = openshot.Keyframe()
{initial_indent_str:s}br{var_suffix:s}.AddPoint(1, 0.0, openshot.LINEAR)
{initial_indent_str:s}co{var_suffix:s} = openshot.Keyframe()
{initial_indent_str:s}co{var_suffix:s}.AddPoint(1, 0.0, openshot.LINEAR)
{initial_indent_str:s}m{var_suffix:s} = openshot.Mask(mr{var_suffix:s}, br{var_suffix:s}, co{var_suffix:s})
{initial_indent_str:s}m{var_suffix:s}.Layer({layer:d})
{initial_indent_str:s}m{var_suffix:s}.End(fr{var_suffix:s}.info.duration)
{initial_indent_str:s}print('Mask created')
{initial_indent_str:s}t.AddEffect(m{var_suffix:s})

"""
    if_template = "{initial_indent_str:s}if sides_per_eye >= {num:d}:\n"
    out_code = ""
    if prepend_if:
        out_code += if_template.format(initial_indent_str=str(indent_char * indent_level * num_indent), num=int(side_index)+1)
        indent_level += 1
    out_code += template.format(initial_indent_str=str(indent_char * indent_level * num_indent),
        indent_str=str(indent_char * num_indent), var_suffix=var_suffix, 
        side_index=int(side_index), layer=int(layer))
    print(out_code)
    return out_code

if __name__ == '__main__':
    out_code=''
    for i in range(8):
        prepend_if = (i > 3)
        suffix = str(i+1)
        layer = i+1
        out_code += generate_encode_side(suffix, i, layer, prepend_if=prepend_if)

    with open('generated.py', 'wt', encoding='utf-8') as fp:
        fp.write(out_code)