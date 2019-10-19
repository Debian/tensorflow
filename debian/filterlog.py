#!/usr/bin/pypy3
# FilterLog
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
#License: Expat
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# .
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# .
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
import os, sys, re, argparse, shlex, json
from glob import glob as _glob
from ninja_syntax import Writer
from typing import *

DEBUG=os.getenv('DEBUG', False)


def red(s: str) -> str: return f'\033[1;31m{s}\033[0;m'
def green(s: str) -> str: return f'\033[1;32m{s}\033[0;m'
def yellow(s: str) -> str: return f'\033[1;33m{s}\033[0;m'
def blue(s: str) -> str: return f'\033[1;34m{s}\033[0;m'
def violet(s: str) -> str: return f'\033[1;35m{s}\033[0;m'
def cyan(s: str) -> str: return f'\033[1;36m{s}\033[0;m'

class FilterLog(object):
    @staticmethod
    def filterBuildlog(path: str) -> List[str]:
        '''
        Read the Bazel buildlog (bazel build -s //tensorflow:xxx 2>&1 | tee log),
        collect all the command lines inside it and return the cmdline list.
        '''
        cmdlines = []
        lines = open(path, 'rt').readlines()
        states = {'bracket': 0, 'cmd': False}
        for (i, line) in enumerate(lines):
            line = line.strip()
            if line.startswith('(') and lines[i-1].startswith('SUBCOMMAND'):
                #cmdlines.append(line)
                states['cmd'] = True
                states['bracket'] += line.count('(') - line.count(')')
            elif states['cmd'] == True:
                states['bracket'] += line.count('(') - line.count(')')
                if states['bracket'] == 0:
                    cmdlines.append(line[:-1])
                    states['cmd'] = False
            else:
                pass
        return cmdlines
    @staticmethod
    def dirMangle(path: str):
        path = path.replace('bazel-out/k8-opt/bin', './')
        path = path.replace('bazel-out/host/bin', './')
        path = path.replace('/_objs/', '/')
        path = path.replace('.//external/com_google_protobuf/protoc', './external/com_google_protobuf/protoc')
        return path
    @staticmethod
    def cleanCmdlines(cmdlines: list) -> List[str]:
        '''
        cleanup unwanted stuff from the cmdlines
        '''
        lines = []
        for line in cmdlines:
            if DEBUG: print(line)
            if "EOF'" in line: continue
            if "done'" in line: continue
            line = ' '.join(shlex.split(line))
            line = FilterLog.dirMangle(line)
            lines.append(line)
        return lines
    @staticmethod
    def sanityTest(cmdlines: list) -> None:
        '''
        perform sanity tests
        '''
        for line in cmdlines:
            if any(line.startswith(x) for x in [
                '/usr/lib/ccache/gcc',
                '/bin/bash',
                './external/com_google_protobuf/protoc',
                ]):
                pass
            else:
                raise ValueError(f'what is {line}?')
    def __init__(self, path: str, dest: str):
        cmdlines = self.filterBuildlog(path)
        cmdlines = self.cleanCmdlines(cmdlines)
        self.sanityTest(cmdlines)
        json.dump(cmdlines, open(dest, 'wt'), indent=4)

if __name__ == '__main__':

    FilterLog(sys.argv[1], sys.argv[2])
