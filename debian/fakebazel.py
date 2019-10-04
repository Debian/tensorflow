#!/usr/bin/pypy3
# FakeBazel
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re, argparse, shlex, json
from ninja_syntax import Writer
from typing import *

DEBUG=os.getenv('DEBUG', False)


objs_gen_proto_text_functions = [x.strip() for x in
        open('debian/buildlogs/gen_proto_text_functions-2.params').readlines() if x.strip().endswith('.o')]

inputs1_proto_text = """
tensorflow/core tensorflow/core/ tensorflow/core/lib/core/error_codes.proto tensorflow/tools/proto_text/placeholder.txt
""".split()

inputs2_proto_text = """
tensorflow/core tensorflow/core/ tensorflow/core/example/example.proto tensorflow/core/example/feature.proto tensorflow/core/framework/allocation_description.proto tensorflow/core/framework/api_def.proto tensorflow/core/framework/attr_value.proto tensorflow/core/framework/cost_graph.proto tensorflow/core/framework/device_attributes.proto tensorflow/core/framework/function.proto tensorflow/core/framework/graph.proto tensorflow/core/framework/graph_transfer_info.proto tensorflow/core/framework/kernel_def.proto tensorflow/core/framework/log_memory.proto tensorflow/core/framework/node_def.proto tensorflow/core/framework/op_def.proto tensorflow/core/framework/reader_base.proto tensorflow/core/framework/remote_fused_graph_execute_info.proto tensorflow/core/framework/resource_handle.proto tensorflow/core/framework/step_stats.proto tensorflow/core/framework/summary.proto tensorflow/core/framework/tensor.proto tensorflow/core/framework/tensor_description.proto tensorflow/core/framework/tensor_shape.proto tensorflow/core/framework/tensor_slice.proto tensorflow/core/framework/types.proto tensorflow/core/framework/variable.proto tensorflow/core/framework/versions.proto tensorflow/core/protobuf/config.proto tensorflow/core/protobuf/cluster.proto tensorflow/core/protobuf/debug.proto tensorflow/core/protobuf/device_properties.proto tensorflow/core/protobuf/graph_debug_info.proto tensorflow/core/protobuf/queue_runner.proto tensorflow/core/protobuf/rewriter_config.proto tensorflow/core/protobuf/tensor_bundle.proto tensorflow/core/protobuf/saver.proto tensorflow/core/protobuf/verifier_config.proto tensorflow/core/protobuf/trace_events.proto tensorflow/core/util/event.proto tensorflow/core/util/memmapped_file_system.proto tensorflow/core/util/saved_tensor_slice.proto tensorflow/core/lib/core/error_codes.proto tensorflow/tools/proto_text/placeholder.txt
""".split()


objs_libtensorflow_framework = [x.strip() for x in
        open('debian/buildlogs/libtensorflow_framework.so.2.0.0-2.params').readlines() if x.strip().endswith('.o')]


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
        F.rule('PROTOC', 'protoc -I. $in $flags')
        F.rule('CXX', 'ccache g++ -I. -Iexternal -Iexternal/eigen3 -Iexternal/com_google_absl -O2 -fPIC $flags -c -o $out $in')
        F.rule('CXXEXEC', 'ccache g++ -I. -O2 -fPIE -pie $flags -o $out $in')
        F.rule('CXXSO', 'ccache g++ -fPIC $flags -o $out $in')
        F.rule('MKDIR', 'mkdir -p $out')
        F.rule('CP', 'cp -v $in $out')
        F.rule('PROTO_TEXT', './tensorflow/tools/proto_text/gen_proto_text_functions.elf $in')
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
                    F.build(obj+'.elf', 'CXXEXEC', '', variables={'flags': flags},
                            implicit=[*objs_gen_proto_text_functions, 'protos_all_cc'])
                elif re.match('.*libtensorflow_framework.*', obj):
                    F.build(obj, 'CXXSO', '', variables={'flags': flags},
                            implicit=[*objs_libtensorflow_framework, 'protos_all_cc'])
                else:
                    print('???????', t)
            elif t['type'] == 'PROTOC':
                # proto flags
                if len(t['proto']) > 1:
                    print('len_proto>1?????????', t)
                assert(len(t['proto']) == 1)
                proto, flags = t['proto'][0], ' '.join(t['flags'])
                flags = re.sub('(.*)(--cpp_out=).*', '\\1\\2.', flags)
                F.build([re.sub('\.proto$', '.pb.cc', proto),
                    re.sub('\.proto$', '.pb.h', proto)],
                    'PROTOC', proto, variables={'flags': flags},
                    implicit=os.path.dirname(proto))
            elif t['type'] == 'CMD':
                if 'bazel-out/host/bin/tensorflow/tools/git/gen_git_source' in t['cmd']:
                    pass
                else:
                    print('MISSING', FakeBazel.dirMangle(t['cmd']))
            else:
                print('MISSING', t)
        F.close()
    def __init__(self, path: str, dest: str = 'build.ninja'):
        print(f'* Parsing {path} ...')
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


#fakeb = FakeBazel('debian/buildlogs/libtensorflow_framework.so.log',
#        'libtensorflow_framework.ninja')
fakeb = FakeBazel('debian/buildlogs/libtensorflow.so.log')
