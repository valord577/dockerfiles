#!/usr/bin/env python3

# fmt: off

import importlib.util
import io
import json
import subprocess as sp
import os
import platform
import sys

from pathlib import Path
from typing import Union
from urllib.parse import urljoin


PROJ_ROOT = (Path(__file__).absolute().resolve().parents[1]).as_posix()
# ----------------------------
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', line_buffering=True)
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', line_buffering=True)
# ----------------------------
RCLONE_EXEC = (Path(PROJ_ROOT) / '.github' / 'rclone')
# ----------------------------
S3_R2_ACCOUNT_ID = os.getenv('S3_R2_ACCOUNT_ID') or '<mask>'
S3_R2_ACCESS_KEY = os.getenv('S3_R2_ACCESS_KEY') or '<mask>'
S3_R2_SECRET_KEY = os.getenv('S3_R2_SECRET_KEY') or '<mask>'
S3_R2_STORAGE_REGION = os.getenv('S3_R2_STORAGE_REGION') or  'auto'
S3_R2_STORAGE_BUCKET = os.getenv('S3_R2_STORAGE_BUCKET') or '<mask>'
# ----------------------------
NATIVE_PLAT = platform.system().lower()
if NATIVE_PLAT not in ['linux', 'darwin', 'windows']:
    raise NotImplementedError(f'unsupported native platform: {NATIVE_PLAT}')
NATIVE_ARCH = platform.machine().lower()
if NATIVE_ARCH == 'x86_64':  NATIVE_ARCH = 'amd64'
if NATIVE_ARCH == 'aarch64': NATIVE_ARCH = 'arm64'
# ----------------------------
# >>>> utils functions >>>>
# ----------------------------
def print_stderr(str):
    print(str, file=sys.stderr)
def _util_func__subprocess(args: Union[str, list[str]],
    cwd: Union[str, None] = None, env: Union[dict[str, str], None] = None, shell=False,
    collect_stdout=False, stdout = None,
) -> str:
    print_stderr(f'>>>> subprocess cmdline: {args}')
    proc = sp.run(
        args=args, cwd=cwd, env=env, check=True, shell=shell,
        stdout=(sp.PIPE if collect_stdout else stdout), text=(True if collect_stdout else None),
    )
    return proc.stdout if collect_stdout else ''

def _util_dopack_zip_with_softlinks(filepath: Path, zipname: Union[str, None] = None):
    if not zipname:
        zipname = filepath.name

    _sh = 'bash'
    _cwd = (filepath.parent).absolute().as_posix()
    if sys.platform == 'win32':
        _sh = 'C:/msys64/usr/bin/bash.exe'
        _cwd = f'$(cygpath -u "{_cwd}")'
    _cmd = f'zip -ry {zipname}.zip {filepath.name}'
    _util_func__subprocess(args=[_sh, '-lc', f'cd {_cwd}; {_cmd}'])
def _util_unpack_zip_with_softlinks(zipfile: Path, extract_dir: str):
    _sh = 'bash'
    _cwd = (Path(extract_dir)).absolute().as_posix()
    if sys.platform == 'win32':
        _sh = 'C:/msys64/usr/bin/bash.exe'
        _cwd = f'$(cygpath -u "{_cwd}")'
    _cmd = f'unzip {zipfile.absolute().as_posix()}'
    _util_func__subprocess(args=[_sh, '-lc', f'cd {_cwd}; {_cmd}'])
