#!/usr/bin/pypy3
# FakeBazel
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re, argparse, shlex
from ninja_syntax import Writer
from typing import *

DEBUG=os.getenv('DEBUG', False)

class FakeBazel(object):
    @staticmethod
    def parseBuildlog(path: str) -> List[str]:
        '''
        Read the Bazel buildlog (bazel build -s //tensorflow:xxx 2>&1 | tee log),
        collect all the command lines inside it and return the cmdline list.
        '''
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
        return cmdlines
    @staticmethod
    def rinseGraph(depgraph: List[str]) -> List[str]:
        '''
        Remove unwanted targets from the dependency graph,
        especially those for external source files (e.g. protobuf)
        '''
        G = []
        for t in depgraph:
            if 'CXX' == t['type']:
                if t['obj'][0] =='bazel-out/host/bin/external/com_google_protobuf/protoc':
                    continue
                if t['obj'][0] =='bazel-out/host/bin/external/nasm/nasm':
                    continue
                if len(t['src'])==0:
                    pass
                elif any(re.match(r, t['src'][0]) for r in[
                        'external/com_google_protobuf/.*',
                        'external/boringssl/.*',
                        'external/aws/.*',
                        #'external/com_google_absl/.*',
                        'external/curl/.*',
                        'external/fft2d/.*',
                        'external/com_googlesource_code_re2/.*',
                        'external/nsync/.*',
                        'external/jpeg/.*',
                        'external/hwloc/.*',
                        'external/gif_archive/.*',
                        'external/zlib_archive/.*',
                        'external/double_conversion/.*',
                        'external/jsoncpp_git/.*',
                        'external/highwayhash/.*',
                        'external/snappy/.*',
                        'external/nasm/.*',
                        ]):
                    continue
            if 'CMD' == t['type']:
                if 'external/jpeg' in t['cmd']: continue
                if 'external/snappy' in t['cmd']: continue
                if 'external/com_google_protobuf' in t['cmd']: continue
                if 'external/nasm' in t['cmd']: continue
            G.append(t)
        for t in G:
            if t['type'] == 'CXX':
                if len(t['src']) == 0:
                    print(t)
                else:
                    print(t['src'])
            else:
                print(t)
        return G
        #rinsed, count = [], 0
        #for line in cmdlines:
        #    line = re.sub("'", '', line)
        #    if not FakeBazel.isUnwanted(line):
        #if any(re.match(x, line) for x in [
        #    '.*external/aws/aws-cpp-sdk-core/.*?.c[cp]?p?\s.*',
        #    '.*external/boringssl.*?.c[cp]?p?\s.*',
        #    '.*external/com_google_protobuf/.*?.c[cp]?p?\s.*',
        #    '.*external/\S*?.c\s',
        #    '.*external/\S.*?.cc\s',
        #    '.*external/\S*?.cpp\s',
        #    ]):
        #    return True
        #else:
        #    return False
        #        rinsed.append(line)
        #    else:
        #        count += 1
        #print(f'* {count}/{len(cmdlines)} commands were drop out.')
        #return rinsed
    @staticmethod
    def understandCmdlines(cmdlines: List[str]) -> (List):
        '''
        Understand the command lines and rebuild the dependency graph.
        '''
        depgraph = []
        for cmd in cmdlines:
            if cmd.startswith('/usr/lib/ccache/gcc'):
                # it's a CXX/LD command
                target = {'type': 'CXX', 'src': [], 'obj': [], 'flags': []}
                tokens = shlex.split(cmd)
                for (i,t) in enumerate(tokens[1:], 1):
                    if any(re.match(r, t) for r in [
                        '-g\d',
                        '-c',
                        '-o',
                        '-O\d',
                        '-M\w',
                        '-m.*',
                        '-U_FORTIFY_SOURCE',
                        "-D__TIME__=.*?",
                        "-D__TIMESTAMP__=.*?",
                        "-D__DATE__=.*?",
                        '-D_FORTIFY_SOURCE=1',
                        '-Iexternal/.*',
                        '-I.',
                        '-B.*',
                        ]):
                        pass
                    elif any(re.match(r, t) for r in [
                        '-fstack-protect',
                        '-fno-omit-frame-pointer',
                        '-ffunction-sections',
                        '-fdata-sections',
                        '-fno-canonical-system-headers',
                        '-frandom-seed=.*',
                        '-fexceptions',
                        '-fno-exceptions',
                        '-ftemplate-depth.*',
                        '-fno-com.*',
                        '-fuse-ld.*',
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
                        '-Wno-missing-field-initializers',
                        '-Wa,--noexecstack',
                        '-Werror',
                        '-Wformat=.*',
                        '-Wsign-compare',
                        '-Wmissing.*',
                        '-Wshadow.*',
                        '-Wold-st.*',
                        '-Wstrict.*',
                        '-Wno.*',
                        '-w', # Inhibit all warning messages. https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#Warning-Options
                        ]):
                        pass
                    elif any(re.match(r, t) for r in [
                        '-D\S+',
                        '-pthread',
                        '-fPIC',
                        '-std=.*',
                        '-Wl.*',
                        '-pass-exit-codes',
                        '-shared',
                        ]):
                        target['flags'].append(t)
                    elif re.match('-iquote', t) or re.match('-iquote', tokens[i-1]):
                        pass
                    elif re.match('-isystem', t) or re.match('-isystem', tokens[i-1]):
                        pass
                    elif re.match('-x', t) or re.match('-x', tokens[i-1]):
                        pass
                    elif re.match('.*\.d$', t):
                        pass
                    elif re.match('.*\.c[cp]?p?$', t):
                        target['src'].append(t)
                    elif re.match('.*\.S$', t):
                        target['src'].append(t)
                    elif re.match('-o', tokens[i-1]):
                        target['obj'].append(t)
                    else:
                        raise Exception(f'what is {t}? prev={tokens[i-1]} next={tokens[i+1]} full={tokens}')
                if DEBUG: print(target)
                depgraph.append(target)
            elif cmd.startswith('/bin/bash -c'):
                # it's a shell command
                target = {'type': 'CMD', 'cmd': []}
                target['cmd'] = shlex.split(cmd)[-1]
                if DEBUG: print(target)
                depgraph.append(target)
            elif cmd.startswith('bazel-out/host/bin/external/nasm/nasm'):
                # we don't need this assember
                continue
            elif cmd.startswith('bazel-out/host/bin/external/com_google_protobuf/protoc'):
                # it's a protobuf compiler command
                target = {'type': 'PROTOC', 'proto': [], 'flags': []}
                tokens = shlex.split(cmd)
                for t in tokens[1:]:
                    if re.match('-I.*', t):
                        pass
                    elif re.match('--cpp_out=.*', t):
                        target['flags'].append(t)
                    elif re.match('.*\.proto$', t):
                        target['proto'].append(t)
                    else:
                        raise Exception(f'what is {t} in {cmd}?')
                if DEBUG: print(target)
                depgraph.append(target)
            else:
                raise Exception(f"cannot understand: {cmd}")
        return depgraph
    def __init__(self, path: str):
        print(f'* Parsing {path} ...')
        sys.stdout.flush()
        cmdlines = self.parseBuildlog(path)
        depgraph = self.understandCmdlines(cmdlines)
        print(f'  -> {len(cmdlines)} command lines -> {len(depgraph)} targets')
        sys.stdout.flush()
        depgraph = self.rinseGraph(depgraph)

fakeb = FakeBazel(sys.argv[1])