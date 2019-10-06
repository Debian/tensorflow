#!/usr/bin/pypy3
# FakeBazel
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


inputs1_proto_text = """
tensorflow/core tensorflow/core/ tensorflow/core/lib/core/error_codes.proto tensorflow/tools/proto_text/placeholder.txt
""".split()

inputs2_proto_text = """
tensorflow/core tensorflow/core/ tensorflow/core/example/example.proto tensorflow/core/example/feature.proto tensorflow/core/framework/allocation_description.proto tensorflow/core/framework/api_def.proto tensorflow/core/framework/attr_value.proto tensorflow/core/framework/cost_graph.proto tensorflow/core/framework/device_attributes.proto tensorflow/core/framework/function.proto tensorflow/core/framework/graph.proto tensorflow/core/framework/graph_transfer_info.proto tensorflow/core/framework/kernel_def.proto tensorflow/core/framework/log_memory.proto tensorflow/core/framework/node_def.proto tensorflow/core/framework/op_def.proto tensorflow/core/framework/reader_base.proto tensorflow/core/framework/remote_fused_graph_execute_info.proto tensorflow/core/framework/resource_handle.proto tensorflow/core/framework/step_stats.proto tensorflow/core/framework/summary.proto tensorflow/core/framework/tensor.proto tensorflow/core/framework/tensor_description.proto tensorflow/core/framework/tensor_shape.proto tensorflow/core/framework/tensor_slice.proto tensorflow/core/framework/types.proto tensorflow/core/framework/variable.proto tensorflow/core/framework/versions.proto tensorflow/core/protobuf/config.proto tensorflow/core/protobuf/cluster.proto tensorflow/core/protobuf/debug.proto tensorflow/core/protobuf/device_properties.proto tensorflow/core/protobuf/graph_debug_info.proto tensorflow/core/protobuf/queue_runner.proto tensorflow/core/protobuf/rewriter_config.proto tensorflow/core/protobuf/tensor_bundle.proto tensorflow/core/protobuf/saver.proto tensorflow/core/protobuf/verifier_config.proto tensorflow/core/protobuf/trace_events.proto tensorflow/core/util/event.proto tensorflow/core/util/memmapped_file_system.proto tensorflow/core/util/saved_tensor_slice.proto tensorflow/core/lib/core/error_codes.proto tensorflow/tools/proto_text/placeholder.txt
""".split()


def red(s: str) -> str: return f'\033[1;31m{s}\033[0;m'
def green(s: str) -> str: return f'\033[1;32m{s}\033[0;m'
def yellow(s: str) -> str: return f'\033[1;33m{s}\033[0;m'
def blue(s: str) -> str: return f'\033[1;34m{s}\033[0;m'
def violet(s: str) -> str: return f'\033[1;35m{s}\033[0;m'
def cyan(s: str) -> str: return f'\033[1;36m{s}\033[0;m'

class FakeBazel(object):
    @staticmethod
    def dirMangle(path: str):
        path = path.replace('bazel-out/k8-opt/bin/', '')
        path = path.replace('bazel-out/k8-opt/bin', './')
        path = path.replace('bazel-out/host/bin/', '')
        path = path.replace('bazel-out/host/bin', './')
        path = path.replace('/_objs/', '/')
        return path
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
    def understandCmdlines(cmdlines: List[str]) -> (List):
        '''
        Understand the command lines and rebuild the dependency graph.
        paths must be mangled.
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
                        '-Os',
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
                        '-Lbazel-out.*',
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
                        '-Wl,-rpath,.*',
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
                        if '-DTENSORFLOW_USE_MKLDNN_CONTRACTION_KERNEL' in t:
                            # we have mkldnn 1.X, but the reference build use 0.X
                            # so adding another flag
                            #target['flags'].extend([t, '-DENABLE_MKLDNN_V1'])
                            pass
                        else:
                            target['flags'].append(FakeBazel.dirMangle(t))
                    elif re.match('-iquote', t) or re.match('-iquote', tokens[i-1]):
                        pass
                    elif re.match('-isystem', t) or re.match('-isystem', tokens[i-1]):
                        pass
                    elif re.match('-x', t) or re.match('-x', tokens[i-1]):
                        pass
                    elif re.match('-z', t) or re.match('-z', tokens[i-1]):
                        # -z is passed directly on to the linker along with
                        #  the keyword keyword. See the section in the
                        # documentation of your linker for permitted values
                        # and their meanings.
                        if not re.match('-z', t):
                            target['flags'].extend(['-z', t])
                    elif re.match('.*\.d$', t):
                        pass
                    elif re.match('.*\.c[cp]?p?$', t):
                        target['src'].append(FakeBazel.dirMangle(t))
                    elif re.match('.*\.S$', t):
                        target['src'].append(FakeBazel.dirMangle(t))
                    elif re.match('-o', tokens[i-1]):
                        target['obj'].append(FakeBazel.dirMangle(t))
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
            elif cmd.startswith('/bin/bash') and not cmd.startswith('/bin/bash -c'):
                # it's a shell script
                target = {'type': 'SHELL', 'sh': []}
                target['sh'] = shlex.split(cmd)[-1]
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
                        target['flags'].append(FakeBazel.dirMangle(t))
                    elif re.match('--grpc_out=.*', t):
                        target['flags'].append(FakeBazel.dirMangle(t))
                    elif re.match('.*\.proto$', t):
                        target['proto'].append(FakeBazel.dirMangle(t))
                    elif re.match('--plugin=protoc-gen-grpc=\S*', t):
                        target['flags'].append('--plugin=protoc-gen-grpc=/usr/bin/grpc_cpp_plugin')
                    else:
                        raise Exception(f'what is {t} in {cmd}?')
                if DEBUG: print(target)
                depgraph.append(target)
            else:
                raise Exception(f"cannot understand: {cmd}")
        return depgraph
    @staticmethod
    def rinseGraph(depgraph: List[str]) -> List[str]:
        '''
        Remove unwanted targets from the dependency graph,
        especially those for external source files (e.g. protobuf)
        '''
        G = []
        for t in depgraph:
            if 'CXX' == t['type']:
                if t['obj'][0] =='external/com_google_protobuf/protoc':
                    continue
                if t['obj'][0] =='external/nasm/nasm':
                    continue
                if t['obj'][0] == 'external/grpc/grpc_cpp_plugin':
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
                        'external/farmhash.*',
                        'external/grpc.*',
                        'external/mkl_dnn.*',
                        'external/lmdb.*',
                        'external/icu.*',
                        'external/com_github_nanopb_nanopb.*',
                        'external/png_archive.*',
                        'external/org_sqlite.*',
                        'third_party/icu.*',
                        ]):
                    continue
                elif any(re.match(r, t['src'][0]) for r in [
                    '.*tensorflow/core/platform/s3/.*',
                        ]):
                    continue
            if 'CMD' == t['type']:
                if 'external/jpeg' in t['cmd']: continue
                if 'external/snappy' in t['cmd']: continue
                if 'external/com_google_protobuf' in t['cmd']: continue
                if 'external/nasm' in t['cmd']: continue
                if 'external/png_archive/scripts/pnglibconf.h.prebuilt' in t['cmd']: continue
            G.append(t)
        for t in G:
            if t['type'] == 'CXX':
                if len(t['src']) == 0:
                    if DEBUG: print(t)
                else:
                    if DEBUG: print(t['src'])
            else:
                if DEBUG: print(t)
        return G
    @staticmethod
    def dedupGraph(depgraph: str):
        G = []
        for t in depgraph:
            if t['type'] == 'CXX':
                dup = [i for (i,x) in enumerate(G)
                        if (x['type'] == 'CXX') and (x['src'] == t['src']) and (x['obj'] == t['obj'])]
                if not dup:
                    G.append(t)
                else:
                    if DEBUG: print('merging', t)
                    G[dup[0]]['flags'].extend(t['flags'])
                    G[dup[0]]['flags'] = list(set(G[dup[0]]['flags']))
            elif t['type'] == 'PROTOC':
                dup = [(i,x) for (i,x) in enumerate(G)
                        if (x['type'] == 'PROTOC') and (x['proto'] == t['proto'])]
                if not dup:
                    G.append(t)
                else:
                    #print('merging', t)
                    #G[dup[0][0]]['flags'].extend(t['flags'])
                    pass
            else:
                G.append(t)
        return G
    @staticmethod
    def generateNinja(depgraph: str, dest: str):
        '''
        Generate the NINJA file from the given depgraph
        '''
        dedupdir = set()
        F = Writer(open(dest, 'wt'))
        F.comment(f'Automatically generated by {__file__}')
        F.newline()
        F.comment(f'variables')
        CCACHE = 'ccache ' if os.path.exists('/usr/bin/ccache') else ''
        F.variable('CXX', str(os.getenv('CXX','g++')))
        F.variable('CPPFLAGS', '-D_FORTIFY_SOURCE=2 ' + str(os.getenv('CPPFLAGS', '')))
        F.variable('CXXFLAGS', '-O2 -w -gsplit-dwarf -DNDEBUG ' + str(os.getenv('CXXFLAGS', '')))
        F.variable('LDFLAGS', '-Wl,-z,relro -Wl,-z,now ' + str(os.getenv('LDFLAGS', '')))
        F.newline()
        F.comment(f'rules')
        F.rule('PROTOC', 'protoc -I. $in $flags')
        F.rule('CXX', CCACHE+'$CXX $CPPFLAGS $CXXFLAGS -I. -Iexternal -Iexternal/eigen3 -Ithird_party/eigen3 -Iexternal/com_google_absl -I/usr/include/gemmlowp -O2 -fPIC $flags -c -o $out $in')
        F.rule('CXXEXEC', CCACHE+'$CXX $LDFLAGS -I. -Ltensorflow -O2 -fPIE -pie $flags -o $out $in')
        F.rule('CXXSO', CCACHE+'$CXX $LDFLAGS -shared -fPIC -Ltensorflow $flags -o $out $in')
        F.rule('MKDIR', 'mkdir -p $out')
        F.rule('CP', 'cp -v $in $out')
        F.rule('PROTO_TEXT', './tensorflow/tools/proto_text/gen_proto_text_functions.elf $in')
        F.rule('SYMLINK', 'ln -s $in $out')
        F.rule('SH', 'LD_LIBRARY_PATH=tensorflow bash $in')
        F.newline()
        # protos_all_cc target
        protos = list(set(x['proto'][0] for x in depgraph if x['type']=='PROTOC'))
        F.build('protos_all_cc', 'phony', [re.sub('\.proto$', '.pb.cc', x) for x in protos])
        # gen_proto_text_function
        F.build('gen_proto_text_functions', 'phony', 'tensorflow/tools/proto_text/gen_proto_text_functions.elf')
        # inputs{1,2}_proto_text
        F.build('inputs1_proto_text', 'PROTO_TEXT', inputs1_proto_text,
                implicit='gen_proto_text_functions')
        F.build('inputs2_proto_text', 'PROTO_TEXT', inputs2_proto_text,
                implicit='gen_proto_text_functions')
        F.build('proto_text_all_cc', 'phony', ['inputs1_proto_text', 'inputs2_proto_text'])
        # small targets
        for t in depgraph:
            if t['type'] == 'CXX':
                # src obj flags
                src, obj, flags = t['src'], t['obj'], t['flags']
                flags = ' '.join(flags)
                assert(len(src) <= 1)
                assert(len(obj) == 1)
                src = '' if len(src)<1 else src[0]
                obj = obj[0]
                if re.match('.*\.c$', src) and obj.endswith('.o'):
                    F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protoc_all_cc'])
                elif re.match('.*\.cc$', src) and obj.endswith('.o'):
                    if re.match('.*\.pb\.cc$', src):
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc', src])
                    elif re.match('.*\.pb_text\.cc', src):
                        F.build(src, 'phony', 'proto_text_all_cc', implicit=['protos_all_cc'])
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc'])
                    else:
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc'])
                elif re.match('.*\.cpp$', src) and obj.endswith('.o'):
                    F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc'])
                elif re.match('.*gen_proto_text_functions.*', obj):
                    objs_gen_proto_text_functions = [x.strip() for x in
                        open('debian/buildlogs/gen_proto_text_functions-2.params').readlines()
                        if x.strip().endswith('.o')]
                    F.build(obj+'.elf', 'CXXEXEC', '', variables={'flags': flags},
                            implicit=[*objs_gen_proto_text_functions, 'protos_all_cc'])
                elif re.match('.*tensorflow/cc/.*gen_cc', obj):
                    objs_gen_cc = [x.strip() for x in open(obj+'-2.params').readlines() if x.strip().endswith('.o')]
                    F.build(obj, 'CXXEXEC', src, variables={'flags': flags},
                            implicit=[*objs_gen_cc, 'protos_all_cc', 'proto_text_all_cc'])
                elif re.match('.*libtensorflow_framework.*', obj):
                    objs_libtensorflow_framework = [x.strip() for x in
                        open('debian/buildlogs/libtensorflow_framework.so.2.0.0-2.params').readlines()
                        if x.strip().endswith('.o')]
                    F.build(obj, 'CXXSO', '', variables={'flags': flags},
                            implicit=[*objs_libtensorflow_framework, 'protos_all_cc'])
                    F.build(os.path.basename(obj), 'phony', obj)
                    F.build(obj.replace('.so.2.0.0', '.so.2'), 'SYMLINK', os.path.basename(obj))  # .so.2 -> .so.2.0.0
                    F.build(os.path.basename(obj.replace('.so.2.0.0', '.so.2')), 'phony', obj.replace('.so.2.0.0', '.so.2'))
                    F.build(obj.replace('.so.2.0.0', '.so'), 'SYMLINK', os.path.basename(obj.replace('.so.2.0.0', '.so.2')))  # .so -> .so.2
                elif re.match('.*libtensorflow\.so.*', obj):
                    objs_libtensorflow = [x.strip() for x in
                        open('debian/buildlogs/libtensorflow.so.2.0.0-2.params').readlines()
                        if x.strip().endswith('.o')]
                    F.build(obj, 'CXXSO', '', variables={'flags': flags},
                            implicit=[*objs_libtensorflow, 'protos_all_cc'])
                    F.build(os.path.basename(obj), 'phony', obj)
                    F.build(obj.replace('.so.2.0.0', '.so.2'), 'SYMLINK', os.path.basename(obj))  # .so.2 -> .so.2.0.0
                    F.build(os.path.basename(obj.replace('.so.2.0.0', '.so.2')), 'phony', obj.replace('.so.2.0.0', '.so.2'))
                    F.build(obj.replace('.so.2.0.0', '.so'), 'SYMLINK', os.path.basename(obj.replace('.so.2.0.0', '.so.2')))  # .so -> .so.2
                elif re.match('.*libtensorflow_cc\.so.*', obj):
                    objs_libtensorflow = [x.strip() for x in
                        open('debian/buildlogs/libtensorflow_cc.so.2.0.0-2.params').readlines()
                        if x.strip().endswith('.o')]
                    F.build(obj, 'CXXSO', '', variables={'flags': flags},
                            implicit=[*objs_libtensorflow, 'protos_all_cc'])
                    F.build(os.path.basename(obj), 'phony', obj)
                    F.build(obj.replace('.so.2.0.0', '.so.2'), 'SYMLINK', os.path.basename(obj))  # .so.2 -> .so.2.0.0
                    F.build(os.path.basename(obj.replace('.so.2.0.0', '.so.2')), 'phony', obj.replace('.so.2.0.0', '.so.2'))
                    F.build(obj.replace('.so.2.0.0', '.so'), 'SYMLINK', os.path.basename(obj.replace('.so.2.0.0', '.so.2')))  # .so -> .so.2

                else:
                    print('???????', t)
            elif t['type'] == 'PROTOC':
                # proto flags
                if len(t['proto']) > 1:
                    print('len_proto>1?????????', t)
                assert(len(t['proto']) == 1)
                proto, flags = t['proto'][0], ' '.join(t['flags'])
                #flags = re.sub('(.*)(--cpp_out=).*', '\\1\\2.', flags)
                if 'grpc' in flags:
                    F.build([re.sub('\.proto$', '.pb.cc', proto),
                        re.sub('\.proto$', '.grpc.pb.cc', proto),
                        re.sub('\.proto$', '.grpc.pb.h', proto),
                        re.sub('\.proto$', '.pb.h', proto)],
                        'PROTOC', proto, variables={'flags': flags},
                        implicit=os.path.dirname(proto))
                else:
                    F.build([re.sub('\.proto$', '.pb.cc', proto),
                        re.sub('\.proto$', '.pb.h', proto)],
                        'PROTOC', proto, variables={'flags': flags},
                        implicit=os.path.dirname(proto))
            elif t['type'] == 'CMD':
                if 'bazel-out/host/bin/tensorflow/tools/git/gen_git_source' in t['cmd']:
                    pass
                elif 'tensorflow/tools/proto_text/gen_proto_text_functions' in t['cmd']:
                    print(t)
                elif all(x in t['cmd'] for x in ['libtensorflow.so', 'ln -sf']):
                    pass
                elif all(x in t['cmd'] for x in ['libtensorflow_framework.so', 'ln -sf']):
                    pass
                else:
                    print('MISSING', FakeBazel.dirMangle(t['cmd']))
            elif t['type'] == 'SHELL':
                # sh
                sh = FakeBazel.dirMangle(t['sh'])
                if re.match('.*tensorflow/cc.*rule.genrule_script\.sh$', sh):
                    depexe = re.sub('tensorflow/cc/(.*?)_genrule.genrule_script.sh$',
                            'tensorflow/cc/ops/\\1_gen_cc', sh)
                    outcc_internal = re.sub('tensorflow/cc/(.*?)_genrule.genrule_script.sh$',
                            'tensorflow/cc/ops/\\1_internal.cc', sh)
                    outcc = re.sub('tensorflow/cc/(.*?)_genrule.genrule_script.sh$',
                            'tensorflow/cc/ops/\\1.cc', sh)
                    #F.build([outcc, outcc_internal], 'SH', sh, implicit=[depexe])
                    pass
                else:
                    print('MISSING', t)
            else:
                print('MISSING', t)
        F.close()
    def __init__(self, path: str, dest: str = 'build.ninja'):
        print(cyan(f'* Parsing {path} ...'))
        sys.stdout.flush()
        cmdlines = self.parseBuildlog(path)
        depgraph = self.understandCmdlines(cmdlines)
        print(f'  -> {len(cmdlines)} command lines -> {len(depgraph)} targets')
        sys.stdout.flush()
        depgraph = self.rinseGraph(depgraph)
        print(f'  -> {len(depgraph)} rinsed targets')
        depgraph = self.dedupGraph(depgraph)
        print(f'  -> {len(depgraph)} deduped targets')
        self.generateNinja(depgraph, dest)
        print(f'  -> Generated Ninja file {dest}')
        json.dump(depgraph, open('depgraph_debug.json', 'wt'), indent=4)
        print(yellow(f'  (json fore debugging stored in -> depgraph_debug.json)'))

#    cursor.rule('rule_PROTOC_PYTHON', '$PROTOC --python_out . -I. $in')
#    cursor.rule( #        'rule_PY_OP_GEN', #        f'LD_LIBRARY_PATH=. ./$in tensorflow/core/api_def/base_api,tensorflow/core/api_def/python_api 1 > $out'
#    )

if __name__ == '__main__':

    # argument parser
    ag = argparse.Argumentparser()
    ag.add_argument('action', type=str, default='parselog')
    ag = ag.parse_args(sys.argv[1:])

    if ag.action == 'parselog':
        fakeb = FakeBazel('debian/buildlogs/libtensorflow_framework.so.log',
                'libtensorflow_framework.ninja') # fundamental
        fakeb = FakeBazel('debian/buildlogs/libtensorflow.so.log',
                'libtensorflow.ninja') # C, Python
        fakeb = FakeBazel('debian/buildlogs/libtensorflow_cc.so.log',
                'libtensorflow_cc.ninja') # C++
    elif ag.action == 'scanserver':
        # Next-gen
        pass
    elif ag.action == 'scanclient':
        # Next-gen
        pass

# FAKE BAZEL FAKE BAZEL FAKE BAZEL FAKE BAZEL FAKE BAZEL FAKE BAZEL FAKE BAZEL

def load(*args, **kwargs):
    for f in args:
        if DEBUG: print(f'BZL[{red("load")}] {f}')

tf_additional_test_deps = lambda *x, **y: []
cc_header_only_library = lambda *x, **y: []
closure_proto_library = lambda *x, **y: []
if_android = lambda *x, **y: []
if_cuda = lambda *x, **y: []
if_dynamic_kernels = lambda *x, **y: []
if_emscripten = lambda *x, **y: []
if_ios = lambda *x, **y: []
if_linux_x86_64 = lambda *x, **y: []
if_mkl = lambda *x, **y: []
if_mobile = lambda *x, **y: []
if_nccl = lambda *x, **y: []
if_not_windows = lambda *x, **y: []
if_static = lambda *x, **y: []
if_tensorrt = lambda *x, **y: []
if_windows = lambda *x, **y: []
mkl_deps = lambda *x, **y: []
tensorflow_opensource_extra_deps = lambda *x, **y: []
tf_additional_all_protos = lambda *x, **y: []
tf_additional_cloud_kernel_deps = lambda *x, **y: []
tf_additional_cloud_op_deps = lambda *x, **y: []
tf_additional_core_deps = lambda *x, **y: []
tf_additional_cupti_wrapper_deps = lambda *x, **y: []
tf_additional_device_tracer_cuda_deps = lambda *x, **y: []
tf_additional_device_tracer_deps = lambda *x, **y: []
tf_additional_device_tracer_test_flags = lambda *x, **y: []
tf_additional_gdr_lib_defines = lambda *x, **y: []
tf_additional_human_readable_json_deps = lambda *x, **y: []
tf_additional_lib_defines = lambda *x, **y: []
tf_additional_lib_deps = lambda *x, **y: []
tf_additional_libdevice_data = lambda *x, **y: []
tf_additional_libdevice_deps = lambda *x, **y: []
tf_additional_minimal_lib_srcs = lambda *x, **y: []
tf_additional_monitoring_hdrs = lambda *x, **y: []
tf_additional_mpi_lib_defines = lambda *x, **y: []
tf_additional_numa_copts = lambda *x, **y: []
tf_additional_numa_deps = lambda *x, **y: []
tf_additional_numa_lib_defines = lambda *x, **y: []
tf_additional_test_deps = lambda *x, **y: []
tf_additional_verbs_lib_defines = lambda *x, **y: []
tf_android_core_proto_headers = lambda *x, **y: []
tf_android_core_proto_sources = lambda *x, **y: []
tf_cc_test = lambda *x, **y: []
tf_cc_test_gpu = lambda *x, **y: []
tf_cc_test_mkl = lambda *x, **y: []
tf_cc_tests = lambda *x, **y: []
tf_cc_tests_gpu = lambda *x, **y: []
tf_copts = lambda *x, **y: []
tf_cuda_cc_test = lambda *x, **y: []
tf_cuda_library = lambda *x, **y: []
tf_cuda_only_cc_test = lambda *x, **y: []
tf_cuda_tests_tags = lambda *x, **y: []
tf_features_nomodules_if_android = lambda *x, **y: []
tf_features_nomodules_if_emscripten = lambda *x, **y: []
tf_gen_op_libs = lambda *x, **y: []
tf_generate_proto_text_sources = lambda *x, **y: []
tf_genrule_cmd_append_to_srcs = lambda *x, **y: []
tf_grpc_service_all = lambda *x, **y: []
tf_jspb_proto_library = lambda *x, **y: []
tf_kernel_tests_linkstatic = lambda *x, **y: []
tf_lib_proto_compiler_deps = lambda *x, **y: []
tf_lib_proto_parsing_deps = lambda *x, **y: []
tf_openmp_copts = lambda *x, **y: []
tf_opts_nortti_if_android = lambda *x, **y: []
tf_opts_nortti_if_emscripten = lambda *x, **y: []
tf_portable_proto_library = lambda *x, **y: []
tf_proto_library = lambda *x, **y: []
tf_proto_library_cc = lambda *x, **y: []
tf_protos_all = lambda *x, **y: []
tf_protos_all_impl = lambda *x, **y: []
tf_protos_grappler = lambda *x, **y: []
tf_protos_grappler_impl = lambda *x, **y: []
tf_pyclif_proto_library = lambda *x, **y: []
tf_version_info_genrule = lambda *x, **y: []
transitive_hdrs = lambda *x, **y: []
package = lambda *x, **y: []
package_group = lambda *x, **y: []
exports_files = lambda *x, **y: []
java_proto_library = lambda *x, **y: []
select = lambda *x, **y: []
genrule = lambda *x, **y: []
alias = lambda *x, **y: []

def tf_proto_library(**kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    if DEBUG: print(f'BZL[tf_proto_library] name={name} srcs={srcs}')

def proto_library(**kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    if DEBUG: print(f'BZL[proto_library] name={name} srcs={srcs}')

def filegroup(*args, **kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    if DEBUG: print(f'BZL[filegroup] name={name} srcs={srcs}')

def cc_library(*args, **kwargs):
    name = kwargs['name']
    hdrs = kwargs['hdrs'] if 'hdrs' in kwargs else []
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[{yellow("cc_library")}] name={name} srcs={srcs} deps={deps}')

def tf_cc_tests(*args, **kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[{green("tf_cc_tests")}] name={name} srcs={srcs} deps={deps}')
    tf_cc_test(*args, **kwargs)

def tf_cuda_library(*args, **kwargs):
    name = kwargs['name']
    hdrs = kwargs['hdrs'] if 'hdrs' in kwargs else []
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[{red("tf_cuda_library")}] name={name} srcs={srcs} deps={deps}')

def tf_gen_op_libs(*args, **kwargs):
    op_lib_names = kwargs['op_lib_names']
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[tf_ten_op_libs] op_lib_names={op_lib_names} deps={deps}')

def tf_cc_tests_gpu(*args, **kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[tf_cc_tests_gpu] name={name} srcs={srcs} deps={deps}')

def tf_cc_test_mkl(*args, **kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[tf_cc_tests_mkl] name={name} srcs={srcs} deps={deps}')

def tf_cuda_cc_test(*args, **kwargs):
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[tf_cuda_cc_test] name={name} srcs={srcs} deps={deps}')

def glob(exprs, exclude=[]):
    dirname = "tensorflow/core" #os.path.dirname(__file__)
    flist = []
    fexclude = []
    for expr in exprs:
        flist.extend(_glob(os.path.join(dirname, expr), recursive=True))
    for expr in exclude:
        fexclude.extend(_glob(os.path.join(dirname, expr), recursive=True))
    flist = list(set(flist))
    fexclude = set(fexclude)
    rinsed = []
    for i in flist:
        if i not in fexclude:
            rinsed.append(i)
    if DEBUG: print(f'BZL[{violet("glob")}] {rinsed}')
    return rinsed

def tf_cc_test(*args, **kwargs):
    '''
    Generate a test script in BASH
    '''
    name = kwargs['name']
    srcs = kwargs['srcs'] if 'srcs' in kwargs else []
    deps = kwargs['deps'] if 'deps' in kwargs else []
    if DEBUG: print(f'BZL[{green("tf_cc_test")}] name={name} srcs={srcs} deps={deps}')

    ccsrc = []
    tflib = []
    flags = ['-I.', '-I/usr/include/tensorflow']
    libs = ["-lpthread", "-l:libgtest.a", '-ltensorflow_cc']
    libs.extend("""
-lcrypto
-lcurl
-ldl
-ldouble-conversion
-lfarmhash
-lgif
-lgpr
-lgrpc
-lgrpc++
-lhighwayhash
-licuuc
-ljpeg
-ljsoncpp
-llmdb
-lm
-lmkldnn
-lnsync
-lnsync_cpp
-lpng
-lprotobuf
-lprotobuf-lite
-lpthread
-lre2
-lrt
-lsnappy
-lsqlite3
-lssl
-lstdc++
-lz""".split())

    def srcProcess(p):
        if re.match('//tensorflow.*\.cc', p):
            p = re.sub('^//', '', p)
            p = re.sub(':', '/', p)
            ccsrc.append(p)
        elif re.match('\w+/.*\.cc', p):
            p = os.path.join('tensorflow/core', p)
            ccsrc.append(p)
        else:
            ccsrc.append(p)
            print(cyan(f"srcProcess: don't know how to understand {p}"))

    def depProcess(d):
        if any(re.match(x, d) for x in [
                ':framework',
                ':lib',
                ':lib_internal',
                ':core',
                ':core_cpu',
                ':core_cpu_internal',
                ]):
            libs.append('-ltensorflow_framework')
        elif any(re.match(x, d) for x in [
                ':test',
                ':test_main',
                ]):
            ccsrc.extend([
                "tensorflow/core/util/reporter.cc",
                "tensorflow/core/platform/test.cc",
                "tensorflow/core/platform/default/test_benchmark.cc",
                "tensorflow/core/platform/posix/test.cc",
                ])
            ccsrc.append("tensorflow/core/platform/test_main.cc")
        elif any(re.match(x,d) for x in [
                '@com_google_absl.*',
                '//third_party/eigen3',
                '@com_google_googletest//:gtest_main',
                '@zlib_archive//:zlib',
                ]):
            pass
        elif any(re.match(x, d) for x in [
                '//tensorflow/cc:cc_ops',
                '//tensorflow/cc:cc_ops_internal',
                '//tensorflow/cc:.*',
                '//tensorflow/core/.*',
                ':all_kernels',
                ':array_ops_op_lib',
                ':.*',
                '//tensorflow/c/kernels:bitcast_op_lib',
                ]):
            libs.append('-ltensorflow_cc')
        else:
            ccsrc.append(d)
            print(red(f"depProcess: don't know how to understand {d}"))

    for x in srcs:
        srcProcess(x)
    for x in deps:
        depProcess(x)

    ccsrc, flags, libs = list(set(ccsrc)), list(set(flags)), list(set(libs))

    with open(name, 'wt') as F:
        F.writelines([
            '#!/bin/bash\n',
            'set -e; set +x\n',
            f'# Automatically generated by {__file__}\n',
            '\n',
            ])
        F.writelines([
            f'elf="{name}.elf"\n'
            'src=(\n',
            *[x + '\n' for x in ccsrc],
            ])
        F.write(')\n')
        F.writelines([
            'tflib=\n',
            'flags="' + ' '.join(flags) + '"\n',
            'libs="' + ' '.join(libs) + '"\n',
            ])
        F.writelines([
            'source debian/_cc_test\n',
            'exit 0\n',
            ])
    os.chmod(name, 0o755)
    print(f'{red("FakeBazel")}[{blue("GenTest")}] -> {green(name)}')
    with open('__alltests', 'at') as f:
        f.write(f'set +e; /bin/bash {name}\n')
    os.chmod('__alltests', 0o755)
