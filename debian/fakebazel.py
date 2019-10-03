#!/usr/bin/python3
# FakeBazel
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re, argparse
from ninja_syntax import Writer
from typing import *

class FakeBazel(object):
    @staticmethod
    def parseBuildlog(path: str) -> List[str]:
        cmdlines = []
        lines = open(path, 'rt').readlines()
        states = [0] # (anther SUBCOMMAND)
        for line in lines:
            line = line.strip()
            if line.startswith('SUBCOMMAND'):
                if states[0] == 1:
                    states[0] = 0
            if line.endswith(')') and not line.endswith('__)') and \
                    not line.startswith('#') and not line.endswith('configured)'):
                if 'EOF' in line:
                    states[0] = 1
                elif states[0] == 0:
                    cmdlines.append(re.sub('\)$', '', line))
                    states[0] = 1
                else:
                    pass
        print(f'* Parsed[{path}] {len(cmdlines)} command lines.')
        return cmdlines
    @staticmethod
    def stripCompilerArgs(line: str) -> str:
        res = ['-f\S*?\s', '-g\d\s', '-O\d\s', '-M\w\s', '-W\S*?\s',
                '-U_FORTIFY_SOURCE', '-iquote\s\S*?\s', '-isystem\s\S*?\s',
                "-D__DATE__=.*?\s", "-D__TIME__=.*?\s",
                "-D__TIMESTAMP__=.*?\s", '-D_FORTIFY_SOURCE=1']
        for r in res:
            line = re.sub(r, ' ', line)
        return ' '.join(line.split())
    @staticmethod
    def isUnwanted(line: str) -> bool:
        if any(re.match(x, line) for x in [
            '.*external/aws/aws-cpp-sdk-core/.*?.c[cp]?p?\s.*',
            '.*external/boringssl.*?.c[cp]?p?\s.*',
            '.*external/com_google_protobuf/.*?.c[cp]?p?\s.*',
            '.*external/.*?.c\s',
            '.*external/.*?.cc\s',
            '.*external/.*?.cpp\s',
            ]):
            return True
        else:
            return False
    @staticmethod
    def rinseCmdlines(cmdlines: List[str]) -> List[str]:
        rinsed, count = [], 0
        for line in cmdlines:
            line = re.sub("'", '', line)
            line = FakeBazel.stripCompilerArgs(line)
            if not FakeBazel.isUnwanted(line):
                if line.startswith('/usr/lib/ccache/gcc'):
                    src, obj = [], ''
                    tokens = list(line.split())
                    for i, t in enumerate(tokens):
                        if t == '-o':
                            obj = tokens[i+1]
                    for i, t in enumerate(tokens):
                        if i == 0:
                            continue
                        if not t.startswith('-') and not t.endswith('.d'):
                            if t.endswith('.o') and re.match('.*\.so.*', obj):
                                src.append(t)
                            elif t.endswith('.o'):
                                pass
                            else:
                                src.append(t)
                    print(' [31;1mCC[m', src, '->', obj.replace('bazel-out/k8-opt/bin/', ''))
                else:
                    print(line)
                rinsed.append(line)
            else:
                count += 1
        print(f'* {count}/{len(cmdlines)} commands were drop out.')
        return rinsed
    def __init__(self, path: str):
        self.cmdlines = self.parseBuildlog(path)
        self.cmdlines = self.rinseCmdlines(self.cmdlines)

fakeb = FakeBazel(sys.argv[1])
