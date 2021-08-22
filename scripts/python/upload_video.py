import os
import sys
import time
import ctypes
from configparser import ConfigParser
from contextlib import closing
import socket
import urllib.parse
import webbrowser
import http.server
import re

import pkce
import requests as r
import requests.utils as req_utils

tools_dir = None
user_prefs = None
workdir_prefix = 'workDir'
cli_id_tag = ''

PREFERENCES_FILE = 'preferences.ini'
CONFIG_DIR = 'config'

UPLOAD_STATUS_UNRECOVERABLE = -9
UPLOAD_STATUS_NOT_STARTED = -2
UPLOAD_STATUS_EXPIRED = -1
UPLOAD_STATUS_UNKNOWN = 0
UPLOAD_STATUS_INCOMPLETE = 1
UPLOAD_STATUS_COMPLETED = 9

if getattr(sys, 'frozen', False):
    # It's a frozen executable, use the executable path to
    # determine the tools dir
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(sys.executable)) + '/..')
    workdir_prefix = ''
else:
    tools_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + '/../..')

class OAuthHttpHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if hasattr(self.server, '_x_callback'):
            print('The request path is: ' + self.path)
            request_path = self.path
            if request_path.startswith('/'):
                request_path = self.path[1:]
            if request_path.startswith('?'):
                request_path = request_path[1:]
            query_params = urllib.parse.parse_qs(request_path)
            print(query_params)
            if 'error' in query_params:
                print('ERROR: ' + query_params['error'])
            elif 'code' in query_params:
                config_file = os.path.join(tools_dir, CONFIG_DIR, 'youtube_oauth.ini')
                oauth_config = ConfigParser()
                oauth_config.optionxform = lambda opt: str(opt)
                oauth_config.read(config_file, 'utf-16')
                client_id = oauth_config.get('General', 'clientId')
                client_not_so_secret = oauth_config.get('General', 'clientSecret')
                code = query_params['code']
                code_verifier = getattr(self.server, '_x_code_verifier')
                redirect_uri = 'http://127.0.0.1:{:s}'.format(str(self.server.server_address[1]))

                token_url = 'https://oauth2.googleapis.com/token'
                resp = r.post(token_url, data={'client_id': client_id, 
                    'client_secret': client_not_so_secret,
                    'code': code,
                    'code_verifier': code_verifier,
                    'grant_type': 'authorization_code',
                    'redirect_uri': redirect_uri
                })
                print(resp)
                if str(resp.status_code).startswith('2'):
                    resp_json = resp.json()
                    access_token = None
                    refresh_token = None
                    if 'access_token' in resp_json:
                        access_token = resp_json['access_token']
                    if 'refresh_token' in resp_json:
                        refresh_token = resp_json['refresh_token']
                    store_tokens(refresh_token, access_token)
                else:
                    print('ERROR: ' + resp.text)
            else:
                pass
            self.send_response(200, '<p><strong>Request received</strong></p>')
            self.server._x_callback(self.server)
            self.close_connection = True

def start_upload(access_token:str, input_video:str, video_title:str = None):
    if not os.path.isfile(input_video):
        raise Exception("Video file not found")
    
    filesize = os.path.getsize(input_video)
    mime_type = 'application/octet-stream'
    base_name, ext = os.path.splitext(os.path.basename(input_video))
    if ext == '.mp4':
        mime_type = 'video/mp4'
    if video_title is None:
        video_title = base_name
    video_metadata = {
        'snippet': {
            'title': video_title,
            'description': 'Video automatically uploaded by MMD VR Tools.',
            # Category 22 is "Entertainment" which I think is the most appropriate 
            'categoryId': 22
        },
        'status': {'privacyStatus': 'private'}
    }
    api_headers = {
        'Authorization': 'Bearer ' + access_token,
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Upload-Content-Length': str(filesize),
        'X-Upload-Content-Type': mime_type
    }
    api_params = {
        'uploadType': 'resumable',
        'part': 'snippet,status,contentDetails'
    }
    change_cli_title('Preparing upload...')
    print('Preparing upload...')
    resp = r.post('https://www.googleapis.com/upload/youtube/v3/videos', headers=api_headers, params=api_params, json=video_metadata)
    if not str(resp.status_code).startswith('2'):
        print('ERROR: ' + resp.text)
        raise Exception("Couldn't upload the video")

    upload_location = resp.headers.get('location')
    if not upload_location:
        raise Exception("Couldn't retrieve the URL to upload the video")
    api_headers = {'Authorization': 'Bearer ' + access_token, 'Content-Type': mime_type}
    success = False
    with open(input_video, 'rb') as fp:
        full_video_data = fp.read()
        retryable_status_codes = (500, 502, 503, 504)
        change_cli_title('Uploading...')
        print('Upload started')
        resp = r.put(upload_location, data=full_video_data)
        success = str(resp.status_code).startswith('2')
        if not success:
            print('WARN: Initial upload failed. Status Code: {:s} Details:'.format(str(resp.status_code)))
            print(resp.headers)
            print(resp.text)
        else:
            print('Done')
        while not success:
            if resp.status_code not in retryable_status_codes:
                print('ERROR: ' + resp.text)
                break
            # Check the upload status
            upload_status = check_upload_status(access_token, upload_location, filesize)
            if upload_status[0] == UPLOAD_STATUS_COMPLETED:
                success = True
            elif upload_status[0] == UPLOAD_STATUS_NOT_STARTED:
                # It hasn't started yet. Check again later.
                if upload_status[2] is not None:
                    retry_wait = upload_status[2]
                else:
                    retry_wait = 1
                time.sleep(retry_wait)
            elif upload_status[0] == UPLOAD_STATUS_INCOMPLETE:
                # If we have a retry-after, wait that amount of time
                if upload_status[2] is not None:
                    retry_wait = upload_status[2]
                else:
                    retry_wait = 1
                time.sleep(retry_wait)
                # Now try to resume the download
                if upload_status[1] is not None:
                    # Prepared the headers to resume the download
                    first_byte = upload_status[1][1] + 1
                    last_byte = len(full_video_data) - 1
                    total_content_length = len(full_video_data)
                    content_range = 'bytes {:d}-{:d}/{:d}'.format(first_byte, last_byte, total_content_length)
                    api_headers['Content-Range'] = content_range
                    partial_upload = full_video_data[first_byte:]
                    resp = r.put(upload_location, headers=api_headers, data=partial_upload)
                    if not str(resp.status_code).startswith('2'):
                        print('ERROR: ' + resp.text)
                        break
                else:
                    # We don't know the uploaded range, this shouldn't happen
                    pass
            else:
                print("ERROR: Couldn't resume the download.")
                break
    return success
            
def check_upload_status(access_token:str, upload_url:str, total_size:int):
    upload_status = UPLOAD_STATUS_UNKNOWN
    retry_after = None
    uploaded_range = None
    api_headers = {
        'Authorization': 'Bearer ' + access_token,
        'Content-Range': 'bytes */' + str(total_size)
    }
    print('Checking upload status...')
    resp = r.put(upload_url, headers=api_headers)
    print(resp.headers)
    print(resp.text)
    if resp.status_code == 201:
        upload_status = UPLOAD_STATUS_COMPLETED
        uploaded_range = (0, total_size-1)
    elif resp.status_code == 308:
        upload_status = UPLOAD_STATUS_NOT_STARTED
        if 'Range' in resp.headers:
            upload_status = UPLOAD_STATUS_INCOMPLETE
            m = re.match(r"bytes=(\d+)-(\d+)", resp.headers['Range'])
            if m is not None:
                uploaded_range = (int(m.group(1)), int(m.group(2)))
        if 'Retry-After' in resp.headers:
            try:
                retry_after = int(resp.headers['Retry-After'])
            except ValueError:
                pass
    elif resp.status_code == 401:
        upload_status = UPLOAD_STATUS_EXPIRED
    else:
        upload_status = UPLOAD_STATUS_UNRECOVERABLE
    return (upload_status, uploaded_range, retry_after)


def requires_authorization():
    return not os.path.exists(os.path.join(tools_dir, CONFIG_DIR, 'youtube_token.ini'))

def store_tokens(refresh_token:str, access_token:str):
    tokens_file = os.path.join(tools_dir, CONFIG_DIR, 'youtube_token.ini')
    tokens_config = ConfigParser()
    tokens_config.optionxform = lambda opt: str(opt)
    tokens_config.add_section('General')
    tokens_config.set('General', 'refreshToken', refresh_token)
    tokens_config.set('General', 'accessToken', access_token)
    with open(tokens_file, 'wt', encoding='utf-16') as fp:
        tokens_config.write(fp)
        print('Tokens saved')

def get_access_token():
    tokens_file = os.path.join(tools_dir, CONFIG_DIR, 'youtube_token.ini')
    tokens_config = ConfigParser()
    tokens_config.optionxform = lambda opt: str(opt)
    tokens_config.read(tokens_file, 'utf-16')
    access_token = tokens_config.get('General', 'accessToken', fallback=None)
    if not validate_access_token(access_token):
        refresh_token = tokens_config.get('General', 'refreshToken')
        access_token = refresh_access_token(refresh_token)
    return access_token

def validate_access_token(access_token:str) -> bool:
    valid = False
    resp = r.get('https://www.googleapis.com/oauth2/v3/tokeninfo', params={'access_token': access_token})
    if str(resp.status_code).startswith('2'):
        valid = True
    else:
        print('WARN validating token: ' + resp.text)
    return valid

def refresh_access_token(refresh_token:str) -> str:
    access_token = None
    config_file = os.path.join(tools_dir, CONFIG_DIR, 'youtube_oauth.ini')
    oauth_config = ConfigParser()
    oauth_config.optionxform = lambda opt: str(opt)
    oauth_config.read(config_file, 'utf-16')
    client_id = oauth_config.get('General', 'clientId')
    client_not_so_secret = oauth_config.get('General', 'clientSecret')
    api_params = {'client_id': client_id, 'client_secret': client_not_so_secret, 'grant_type': 'refresh_token', 'refresh_token': refresh_token}
    resp = r.post('https://oauth2.googleapis.com/token', data=api_params)
    if str(resp.status_code).startswith('2'):
        resp_json = resp.json()
        if 'access_token' in resp_json:
            access_token = resp_json['access_token']
        if 'refresh_token' in resp_json:
            refresh_token = resp_json['refresh_token']
        store_tokens(refresh_token, access_token)
    else:
        print('ERROR refreshing token: ' + resp.text)
    return access_token

def start_authorization_request():
    change_cli_title('Opening web browser for authorization request')
    config_file = os.path.join(tools_dir, CONFIG_DIR, 'youtube_oauth.ini')
    oauth_config = ConfigParser()
    oauth_config.optionxform = lambda opt: str(opt)
    oauth_config.read(config_file, 'utf-16')

    client_id = oauth_config.get('General', 'clientId')
    port = find_free_port()
    redirect_uri = urllib.parse.quote_plus('http://127.0.0.1:{:s}'.format(str(port)))
    scope_safe = urllib.parse.quote_plus('https://www.googleapis.com/auth/youtube.upload')
    code_verifier, code_challenge = pkce.generate_pkce_pair()

    url = ('https://accounts.google.com/o/oauth2/v2/auth?scope={scope:s}&response_type=code&redirect_uri={uri:s}&client_id={client_id:s}'
        + '&code_challenge={code_challenge:s}&code_challenge_method=S256').format(
        scope = scope_safe, uri = redirect_uri, client_id = client_id, code_challenge = code_challenge
    )
    if not webbrowser.open(url):
        raise Exception("Couldn't open the default browser")

    # Start a server to listen for the response
    httpd = http.server.HTTPServer(('', int(port)), OAuthHttpHandler)
    # Inject some custom attributes to handle the authorization
    httpd._x_callback = authorization_callback
    httpd._x_code_verifier = code_verifier
    httpd._x_code_challenge = code_challenge
    httpd.handle_request()
    print('After server shutdown')

def authorization_callback(httpd:http.server.HTTPServer):
    print('Authorization callback')
    # httpd.shutdown()

def find_free_port():
    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
        s.bind(('', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]

def change_cli_title(new_title:str):
    if getattr(sys, 'frozen', False):
        ctypes.windll.kernel32.SetConsoleTitleW(new_title + ' ' + cli_id_tag)
    else:
        sys.stdout.write("\x1b]2;{:s}\x07".format(new_title + ' ' + cli_id_tag))
        print()

def update_task_status(task_data:ConfigParser, out_file:str, new_status:int = 9, task_result:str = ''):
    task_data.set('General', 'taskStatus', str(new_status))
    if task_result is not None:
        task_data.set('General', 'taskResult', task_result)
    with open(out_file, 'wt', encoding='utf-16') as fp:
        task_data.write(fp, False)

if getattr(sys, 'frozen', False) or __name__ == '__main__':
    job_file_name = '' 
    task_file_name = ''
    input_video = sys.argv[1]
    if len(sys.argv) >= 4:
        job_file_name = sys.argv[2] 
        task_file_name = sys.argv[3]
        
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
    video_title = None
    if job_data is not None:
        print('Job and task data successfully parsed')
        job_short_id = job_data.get('General', 'jobShortId', fallback="000")
        task_short_id = task_data.get('General', 'taskShortId', fallback="000")
        id_sep = ':'
        cli_id_tag = "[{:s}{:s}{:s}]".format(job_short_id, id_sep, task_short_id)
        change_cli_title('Preparing upload...')
        video_title = job_data.get('General', 'baseVideoName', fallback=None)
    try:
        if requires_authorization():
            start_authorization_request()
        else:
            # Get an access token
            access_token = get_access_token()
            if access_token is None:
                raise Exception("Couldn't get an access token")
            success = start_upload(access_token, input_video, video_title)
            if task_data is not None:
                if success:
                    update_task_status(task_data, task_file)
                else:
                    update_task_status(task_data, task_file, -1)
    except Exception as e:
        print(type(e).__name__ + ': ' + str(e))
        if task_data is not None:
            update_task_status(task_data, task_file, -1, str(e))
        sys.exit(1)