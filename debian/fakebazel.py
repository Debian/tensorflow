#!/usr/bin/python3
# FakeBazel
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re, argparse, shlex
from ninja_syntax import Writer
from typing import *

class FakeBazel(object):
    @staticmethod
    def parseBuildlog(path: str) -> List[str]:
        cmdlines = []
        lines = open(path, 'rt').readlines()
        states = [0, 0] # (anther SUBCOMMAND, bracket balance)
        for line in lines:
            if line.startswith('#') and line.endswith(')'): continue
            if line.startswith('WARNING:'): continue
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
        #if line.startswith('/usr/lib/ccache/gcc'):
        #    src, obj = [], ''
        #    tokens = list(line.split())
        #    for i, t in enumerate(tokens):
        #        if t == '-o':
        #            obj = tokens[i+1]
        #    for i, t in enumerate(tokens):
        #        if i == 0:
        #            continue
        #        if not t.startswith('-') and not t.endswith('.d'):
        #            if t.endswith('.o') and re.match('.*\.so.*', obj):
        #                src.append(t)
        #            elif t.endswith('.o'):
        #                pass
        #            else:
        #                src.append(t)
        #    print(' [31;1mCC[m', src, '->', obj.replace('bazel-out/k8-opt/bin/', ''))
        #else:
        #    print(line)
        return ' '.join(line.split())
    @staticmethod
    def isUnwanted(line: str) -> bool:
        if any(re.match(x, line) for x in [
            '.*external/aws/aws-cpp-sdk-core/.*?.c[cp]?p?\s.*',
            '.*external/boringssl.*?.c[cp]?p?\s.*',
            '.*external/com_google_protobuf/.*?.c[cp]?p?\s.*',
            '.*external/\S*?.c\s',
            '.*external/\S.*?.cc\s',
            '.*external/\S*?.cpp\s',
            ]):
            return True
        else:
            return False
    @staticmethod
    def rinseCmdlines(cmdlines: List[str]) -> List[str]:
        rinsed, count = [], 0
        for line in cmdlines:
            line = re.sub("'", '', line)
            if not FakeBazel.isUnwanted(line):
                rinsed.append(line)
            else:
                count += 1
        print(f'* {count}/{len(cmdlines)} commands were drop out.')
        return rinsed
    @staticmethod
    def understandCmdlines(cmdlines: List[str]) -> (List, List):
        '''
        Understand and Rinse the command lines
        '''
        depgraph = []
        for cmd in cmdlines:
            if cmd.startswith('/usr/lib/ccache/gcc'):
                # it's a CXX/LD command
                target = {'type': 'CXX', 'src': [], 'obj': [], 'flags': []}
                tokens = shlex.split(cmd)
                for (i,t) in enumerate(tokens[1:], 1):
                    if re.match('-g\d', t):
                        pass
                    elif re.match('-c', t):
                        pass
                    elif re.match('-o', t):
                        pass
                    elif re.match('-O\d', t):
                        pass
                    elif re.match('-M\w', t):
                        pass
                    elif re.match('-std=.*', t):
                        target['flags'].append(t)
                    elif re.match('-U_FORTIFY_SOURCE', t):
                        pass
                    elif re.match("-D__TIME__=.*?", t):
                        pass
                    elif re.match("-D__TIMESTAMP__=.*?", t):
                        pass
                    elif re.match("-D__DATE__=.*?", t):
                        pass
                    elif re.match('-D_FORTIFY_SOURCE=1', t):
                        pass
                    elif any(re.match(r, t) for r in [
                        '-fstack-protect',
                        '-fno-omit-frame-pointer',
                        '-ffunction-sections',
                        '-fdata-sections',
                        '-fno-canonical-system-headers',
                        '-frandom-seed=.*',
                        ]):
                        pass
                    elif any(re.match(r, t) for r in [
                        '-Wall',
                        '-Woverloaded-virtual',
                        '-Wunused-but-set-parameter',
                        '-Wno-free-nonheap-object',
                        '-Wno-shift-negative-value',
                        '-Wno-builtin-macro-redefined',
                        '-Wno-sign-compare',
                        '-Wno-unused-function',
                        '-Wno-write-strings',
                        '-Wextra',
                        '-Wcast-qual',
                        '-Wconversion-null',
                        '-Wmissing-declarations',
                        '-Woverlength-strings',
                        '-Wpointer-arith',
                        '-Wunused-local-typedefs',
                        '-Wunused-result',
                        '-Wvarargs',
                        '-Wvla',
                        '-Wwrite-strings',
                        ]):
                        pass
                        pass
                    elif re.match('-D\S+', t):
                        target['flags'].append(t)
                    elif re.match('.*\.d$', t):
                        pass
                    elif re.match('-iquote', t) or re.match('-iquote', tokens[i-1]):
                        pass
                    elif re.match('-isystem', t) or re.match('-isystem', tokens[i-1]):
                        pass
                    elif re.match('.*\.c[cp]?p?$', t):
                        target['src'].append(t)
                    elif re.match('-o', tokens[i-1]):
                        target['obj'].append(t)
                    else:
                        raise Exception(f'what is {t}? prev={tokens[i-1]} next={tokens[i+1]}')
                print(target)
                depgraph.append(target)
            elif cmd.startswith('/bin/bash -c'):
                # it's a shell command
                target = {'type': 'CMD', 'cmd': []}
                target['cmd'] = shlex.split(cmd)[-1]
                print(target)
                depgraph.append(target)
            else:
                raise Exception(f"cannot understand: {cmd}")
        return [], {}
    def __init__(self, path: str):
        cmdlines = self.parseBuildlog(path)
        cmdlines, depgraph = self.understandCmdlines(cmdlines)

fakeb = FakeBazel(sys.argv[1])
