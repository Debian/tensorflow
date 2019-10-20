#!/usr/bin/pypy3
# Json2Ninja
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

proto_text_h = """
tensorflow/core/example/example.pb_text.h
tensorflow/core/example/feature.pb_text.h
tensorflow/core/framework/allocation_description.pb_text.h
tensorflow/core/framework/api_def.pb_text.h
tensorflow/core/framework/attr_value.pb_text.h
tensorflow/core/framework/cost_graph.pb_text.h
tensorflow/core/framework/device_attributes.pb_text.h
tensorflow/core/framework/function.pb_text.h
tensorflow/core/framework/graph.pb_text.h
tensorflow/core/framework/graph_transfer_info.pb_text.h
tensorflow/core/framework/kernel_def.pb_text.h
tensorflow/core/framework/log_memory.pb_text.h
tensorflow/core/framework/node_def.pb_text.h
tensorflow/core/framework/op_def.pb_text.h
tensorflow/core/framework/reader_base.pb_text.h
tensorflow/core/framework/remote_fused_graph_execute_info.pb_text.h
tensorflow/core/framework/resource_handle.pb_text.h
tensorflow/core/framework/step_stats.pb_text.h
tensorflow/core/framework/summary.pb_text.h
tensorflow/core/framework/tensor.pb_text.h
tensorflow/core/framework/tensor_description.pb_text.h
tensorflow/core/framework/tensor_shape.pb_text.h
tensorflow/core/framework/tensor_slice.pb_text.h
tensorflow/core/framework/types.pb_text.h
tensorflow/core/framework/variable.pb_text.h
tensorflow/core/framework/versions.pb_text.h
tensorflow/core/lib/core/error_codes.pb_text.h
tensorflow/core/protobuf/cluster.pb_text.h
tensorflow/core/protobuf/config.pb_text.h
tensorflow/core/protobuf/debug.pb_text.h
tensorflow/core/protobuf/device_properties.pb_text.h
tensorflow/core/protobuf/graph_debug_info.pb_text.h
tensorflow/core/protobuf/queue_runner.pb_text.h
tensorflow/core/protobuf/rewriter_config.pb_text.h
tensorflow/core/protobuf/saver.pb_text.h
tensorflow/core/protobuf/tensor_bundle.pb_text.h
tensorflow/core/protobuf/trace_events.pb_text.h
tensorflow/core/protobuf/verifier_config.pb_text.h
tensorflow/core/util/event.pb_text.h
tensorflow/core/util/memmapped_file_system.pb_text.h
tensorflow/core/util/saved_tensor_slice.pb_text.h
""".split()
proto_text_cc = [re.sub('\.h$', '.cc', x) for x in proto_text_h]


def red(s: str) -> str: return f'\033[1;31m{s}\033[0;m'
def green(s: str) -> str: return f'\033[1;32m{s}\033[0;m'
def yellow(s: str) -> str: return f'\033[1;33m{s}\033[0;m'
def blue(s: str) -> str: return f'\033[1;34m{s}\033[0;m'
def violet(s: str) -> str: return f'\033[1;35m{s}\033[0;m'
def cyan(s: str) -> str: return f'\033[1;36m{s}\033[0;m'

class FakeBazel(object):
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
                        '-g\d', '-c', '-o', '-O\d', '-Os', '-M\w',
                        '-m.*', '-U_FORTIFY_SOURCE.*',
                        "-D__TIME__=.*?", "-D__TIMESTAMP__=.*?",
                        "-D__DATE__=.*?", '-Iexternal/.*', '-I.',
                        '-B.*', '-Lbazel-out.*', '-L.*',
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
                        '-Wall', '-Woverloaded-virtual',
                        '-Wunused-but-set-parameter',
                        '-Wno-free-nonheap-object',
                        '-Wno-shift-negative-value',
                        '-Wno-builtin-macro-redefined',
                        '-Wno-sign-compare', '-Wno-unused-function',
                        '-Wno-write-strings', '-Wextra', '-Wcast-qual',
                        '-Wconversion-null',
                        '-Wmissing-declarations',
                        '-Woverlength-strings',
                        '-Wpointer-arith',
                        '-Wunused-local-typedefs',
                        '-Wunused-result', '-Wvarargs', '-Wvla',
                        '-Wwrite-strings',
                        '-Wno-missing-field-initializers',
                        '-Wa,--noexecstack', '-Werror', '-Wformat=.*',
                        '-Wsign-compare', '-Wmissing.*', '-Wshadow.*',
                        '-Wold-st.*', '-Wstrict.*', '-Wno.*',
                        '-w', # Inhibit all warning messages. https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#Warning-Options
                        '-Wl,-rpath,.*',
                        ]):
                        pass
                    elif re.match('^-Wl,--version-script$', t) or re.match('^-Wl,--version-script$', tokens[i-1]):
                        if t != '-Wl,--version-script':
                            target['flags'].extend(['-Wl,--version-script', t])
                    elif any(re.match(r, t) for r in [
                        '-D\S+', '-pthread', '-fPIC', '-std=.*', '-Wl.*',
                        '-pass-exit-codes', '-shared',
                        ]):
                        if '-DTENSORFLOW_USE_MKLDNN_CONTRACTION_KERNEL' in t:
                            # we have mkldnn 1.X, but the reference build use 0.X
                            # so adding another flag
                            #target['flags'].extend([t, '-DENABLE_MKLDNN_V1'])
                            pass
                        else:
                            target['flags'].append(t)
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
                        target['src'].append(t)
                    elif re.match('.*\.cxx$', t):
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
            elif cmd.startswith('/bin/bash') and not cmd.startswith('/bin/bash -c'):
                # it's a shell script
                target = {'type': 'SHELL', 'sh': []}
                target['sh'] = shlex.split(cmd)[-1]
                if DEBUG: print(target)
                depgraph.append(target)
            elif cmd.startswith('external/nasm/nasm'):
                # we don't need this assember
                continue
            elif cmd.startswith('external/com_google_protobuf/protoc'):
                # it's a protobuf compiler command
                target = {'type': 'PROTOC', 'proto': [], 'flags': []}
                tokens = shlex.split(cmd)
                for t in tokens[1:]:
                    if re.match('-I.*', t):
                        pass
                    elif re.match('--cpp_out=.*', t):
                        target['flags'].append(t)
                    elif re.match('--grpc_out=.*', t):
                        target['flags'].append(t)
                    elif re.match('.*\.proto$', t):
                        target['proto'].append(t)
                    elif re.match('--plugin=protoc-gen-grpc=\S*', t):
                        target['flags'].append('--plugin=protoc-gen-grpc=/usr/bin/grpc_cpp_plugin')
                    else:
                        raise Exception(f'what is {t} in {cmd}?')
                if DEBUG: print(target)
                depgraph.append(target)
            elif cmd.startswith('external/swig/swig'):
                # it's a swig command
                target = {'type': 'SWIG', 'src': [], 'dest': [], 'flags': []}
                tokens = shlex.split(cmd)
                for (i, token) in enumerate(tokens[1:]):
                    if any((token == '-c++', token == '-python')):
                        target['flags'].append(token)
                    elif any((token=='-module', token=='-o', token=='-outdir')):
                        pass
                    elif tokens[i] == '-module':
                        target['flags'].extend(['-module', token])
                    elif tokens[i] == '-o':
                        target['dest'] = token
                    elif tokens[i] == '-outdir':
                        target['flags'].extend(['-outdir', token])
                    elif re.match('-ltensorflow.*', token):
                        target['flags'].append(token)
                    elif re.match('-I.*', token):
                        target['flags'].append(token)
                    elif re.match('.*\.i$', token):
                        target['src'] = token
                    else:
                        raise Exception(f'SWIG: what is {token}? CMD: {cmd}')
                depgraph.append(target)
            else:
                raise Exception(f"cannot understand: {cmd}")
        return depgraph
    @staticmethod
    def ccDeps(cc: str) -> List[str]:
        '''
        read cxx file and extract dependency information
        '''
        deps = []
        f = open(cc, 'rt')
        for line in f.readlines():
            deps.extend(re.findall('#include\s+"(tensorflow/\S+)"', line))
        f.close()
        return deps
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
                        'external/swig.*',
                        'tensorflow/lite/.*',
                        ]):
                    continue
                elif any(re.match(r, t['src'][0]) for r in [
                    '.*tensorflow/core/platform/s3/.*',
                        ]):
                    continue
            elif 'CMD' == t['type']:
                if 'external/jpeg' in t['cmd']: continue
                if 'external/snappy' in t['cmd']: continue
                if 'external/com_google_protobuf' in t['cmd']: continue
                if 'external/nasm' in t['cmd']: continue
                if 'external/png_archive/scripts/pnglibconf.h.prebuilt' in t['cmd']: continue
            else:
                pass
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
    def generateNinja(depgraph: str, dest: str, default: str):
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
        F.rule('CXX', CCACHE+'$CXX $CPPFLAGS $CXXFLAGS -I. -Iexternal -Iexternal/eigen3 -Ithird_party/eigen3 -Iexternal/com_google_absl -I/usr/include/gemmlowp -I/usr/include/python3.7m -O2 -fPIC $flags -c -o $out $in')
        F.rule('SWIG', 'swig -I. $flags -o $out $in')
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
        F.build(proto_text_h + proto_text_cc, 'phony', 'proto_text_all_cc')
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
                    F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc'])
                elif re.match('.*\.cc$', src) and obj.endswith('.o'):
                    if os.path.exists(src):
                        ccdeps = FakeBazel.ccDeps(src)
                    else:
                        ccdeps = []
                    if re.match('.*\.pb\.cc$', src):
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc', src, *ccdeps])
                    elif re.match('.*\.pb_text\.cc', src):
                        #F.build(src, 'phony', 'proto_text_all_cc', implicit=['protos_all_cc'])
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc', *ccdeps])
                    else:
                        F.build(obj, 'CXX', src, variables={'flags': flags}, implicit=['protos_all_cc', *ccdeps])
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
                elif re.match('.*_pywrap_tensorflow_internal.so$', obj):
                    objs_pywrap = [x.strip() for x in
                            open('debian/buildlogs/_pywrap_tensorflow_internal.so-2.params').readlines()
                            if x.strip().endswith('.o')]
                    F.build(obj, 'CXXSO', '', variables={'flags': flags},
                            implicit=[*objs_pywrap, 'protos_all_cc'])
                    F.build(os.path.basename(obj), 'phony', obj)
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
                    print('MISSING', t)
            elif t['type'] == 'SHELL':
                # sh
                sh = t['sh']
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
            elif t['type'] == 'SWIG':
                # swig
                F.build(t['dest'], 'SWIG', t['src'], variables={'flags': t['flags']})
            else:
                print('MISSING', t)
        if default is not None:
            F.default(default)
        F.close()
    def __init__(self, path: str, dest: str, default: str = None):
        sys.stdout.flush()
        cmdlines = json.load(open(path, 'rt'))
        print(f'{__file__}: (understand)')
        depgraph = self.understandCmdlines(cmdlines)
        sys.stdout.flush()
        print(f'{__file__}: (rinse)')
        depgraph = self.rinseGraph(depgraph)
        depgraph = self.dedupGraph(depgraph)
        print(f'{__file__}: (generate)')
        self.generateNinja(depgraph, dest, default)
        print(green(f'Json2Ninja: {path} -> {dest} [{default}]'))

#    cursor.rule('rule_PROTOC_PYTHON', '$PROTOC --python_out . -I. $in')
#    cursor.rule( #        'rule_PY_OP_GEN', #        f'LD_LIBRARY_PATH=. ./$in tensorflow/core/api_def/base_api,tensorflow/core/api_def/python_api 1 > $out'
#    )

if __name__ == '__main__':

    # argument parser
    ag = argparse.ArgumentParser()
    ag.add_argument('-i', '--input', type=str, required=True)
    ag.add_argument('-o', '--output', type=str, required=True)
    ag.add_argument('-d', '--default', type=str, required=True)
    ag = ag.parse_args(sys.argv[1:])

    FakeBazel(ag.input, ag.output, ag.default)
