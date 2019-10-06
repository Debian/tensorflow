#!/bin/bash
set +e
set -x


CFLAGS="-O2 -fPIC -I/usr/include/tensorflow -I. -pthread -fpermissive"
LDFLAGS="-ltensorflow"
D=tensorflow/c
common=(
tensorflow/core/platform/test_main.cc
tensorflow/core/util/reporter.cc
tensorflow/core/platform/default/test_benchmark.cc
tensorflow/c/c_test_util.cc
)

#elf=platform_unbounded_work_queue_test
#src=(
#tensorflow/core/platform/unbounded_work_queue_test.cc
#${common[@]}
#)
#flags="-I. -pthread"
#libs="-lprotobuf -l:libgtest.a -ltensorflow"
#source debian/_cc_test

elf=test_op_kernel.so
src=( tensorflow/c/test_op.cc )
flags="$CFLAGS -shared"
libs="-ltensorflow_framework"
tflib=
source debian/_cc_test

elf=test_op1.so
src=( tensorflow/c/test_op1.cc )
flags="$CFLAGS -shared"
libs="-ltensorflow_framework"
tflib=
source debian/_cc_test

g++ $CFLAGS -c $D/c_test.c -o $D/c_test.o
g++ $CFLAGS -c $D/env.cc -o $D/env.o
g++ $CFLAGS -Wl,--start-group $D/c_test.o $D/env.o -ltensorflow_framework -ltensorflow -Wl,--end-group -o c_test
./c_test

#elf=c_api_test.elf
#src=( tensorflow/c/c_api_test.cc 
#      tensorflow/c/c_test_util.cc
#	  tensorflow/c/c_api_experimental.cc
#)
##        ":test_op1.so",
#flags="$CFLAGS -fPIE -pie"
#libs='-lprotobuf -l:libgtest.a'
#tflib=cc
#source debian/_cc_test

#tf_cc_test(
#    name = "c_api_function_test",
#    size = "small",
#    srcs = ["c_api_function_test.cc"],
#    deps = [
#        ":c_api",
#        ":c_api_internal",
#        ":c_test_util",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:lib_internal",
#        "//tensorflow/core:protos_all_cc",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#    ],
#)
#
#tf_cc_test(
#    name = "while_loop_test",
#    size = "small",
#    srcs = ["while_loop_test.cc"],
#    deps = [
#        ":c_api",
#        ":c_test_util",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#    ],
#)
#
#
#
#tf_cuda_cc_test(
#    name = "env_test",
#    size = "small",
#    srcs = ["env_test.cc"],
#    linkopts = select({
#        "//tensorflow:macos": ["-headerpad_max_install_names"],
#        "//conditions:default": [],
#    }),
#    tags = ["noasan"],
#    # We must ensure that the dependencies can be dynamically linked since
#    # the shared library must be able to use core:framework.
#    # linkstatic = tf_kernel_tests_linkstatic(),
#    deps = [
#        ":c_api",
#        ":env",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#    ],
#)
#
#tf_cuda_cc_test(
#    name = "kernels_test",
#    size = "small",
#    srcs = ["kernels_test.cc"],
#    linkopts = select({
#        "//tensorflow:macos": ["-headerpad_max_install_names"],
#        "//conditions:default": [],
#    }),
#    tags = ["no_cuda_on_cpu_tap"],
#    # We must ensure that the dependencies can be dynamically linked since
#    # the shared library must be able to use core:framework.
#    # linkstatic = tf_kernel_tests_linkstatic(),
#    deps = [
#        ":c_api",
#        ":kernels",
#        "//tensorflow/core:framework",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:proto_text",
#        "//tensorflow/core:protos_all_cc",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#        "//tensorflow/core/kernels:ops_testutil",
#        "//third_party/eigen3",
#    ],
#)
#
#tf_cc_test(
#    name = "ops_test",
#    size = "small",
#    srcs = ["ops_test.cc"],
#    linkopts = select({
#        "//conditions:default": [],
#    }),
#    tags = ["noasan"],
#    # We must ensure that the dependencies can be dynamically linked since
#    # the shared library must be able to use core:framework.
#    # linkstatic = tf_kernel_tests_linkstatic(),
#    deps = [
#        ":c_api",
#        ":ops",
#        "//tensorflow/core:framework",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:protos_all_cc",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#        "//tensorflow/core:testlib",
#        "@com_google_absl//absl/strings",
#    ],
#)
