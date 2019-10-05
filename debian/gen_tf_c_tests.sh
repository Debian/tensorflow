#!/bin/bash
set +e
set -x


CFLAGS="-O2 -fPIC -fPIE -pie -I. -pthread -fpermissive"
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

g++ $CFLAGS -c $D/c_test.c -o $D/c_test.o
g++ $CFLAGS -Wl,--start-group $D/c_test.o -ltensorflow -Wl,--end-group -o c_test $D/env.cc
./c_test

#tf_cuda_cc_test(
#    name = "c_api_test",
#    size = "small",
#    srcs = ["c_api_test.cc"],
#    data = [
#        ":test_op1.so",
#        "//tensorflow/cc/saved_model:saved_model_half_plus_two",
#    ],
#    kernels = [":test_op_kernel"],
#    linkopts = select({
#        "//tensorflow:macos": ["-headerpad_max_install_names"],
#        "//conditions:default": [],
#    }),
#    tags = [
#        "noasan",
#    ],
#    # We must ensure that the dependencies can be dynamically linked since
#    # the shared library must be able to use core:framework.
#    # linkstatic = tf_kernel_tests_linkstatic(),
#    deps = [
#        ":c_api",
#        ":c_test_util",
#        "//tensorflow/cc:cc_ops",
#        "//tensorflow/cc:grad_ops",
#        "//tensorflow/cc/saved_model:signature_constants",
#        "//tensorflow/cc/saved_model:tag_constants",
#        "//tensorflow/compiler/jit",
#        "//tensorflow/core:array_ops_op_lib",
#        "//tensorflow/core:bitwise_ops_op_lib",
#        "//tensorflow/core:control_flow_ops_op_lib",
#        "//tensorflow/core:core_cpu_internal",
#        "//tensorflow/core:direct_session",
#        "//tensorflow/core:framework",
#        "//tensorflow/core:framework_internal",
#        "//tensorflow/core:functional_ops_op_lib",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:math_ops_op_lib",
#        "//tensorflow/core:nn_ops_op_lib",
#        "//tensorflow/core:no_op_op_lib",
#        "//tensorflow/core:proto_text",
#        "//tensorflow/core:protos_all_cc",
#        "//tensorflow/core:sendrecv_ops_op_lib",
#        "//tensorflow/core:spectral_ops_op_lib",
#        "//tensorflow/core:state_ops_op_lib",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#        "//tensorflow/core/kernels:array",
#        "//tensorflow/core/kernels:control_flow_ops",
#        "//tensorflow/core/kernels:math",
#    ],
#)
#
#tf_cc_test(
#    name = "c_api_experimental_test",
#    size = "medium",
#    srcs = ["c_api_experimental_test.cc"],
#    data = ["testdata/tf_record"],
#    linkopts = select({
#        "//tensorflow:macos": ["-headerpad_max_install_names"],
#        "//conditions:default": [],
#    }),
#    # We must ensure that the dependencies can be dynamically linked since
#    # the shared library must be able to use core:framework.
#    # linkstatic = tf_kernel_tests_linkstatic(),
#    deps = [
#        ":c_api",
#        ":c_api_experimental",
#        ":c_api_internal",
#        ":c_test_util",
#        "//tensorflow/c/eager:c_api",
#        "//tensorflow/c/eager:c_api_test_util",
#        "//tensorflow/core:lib",
#        "//tensorflow/core:protos_all_cc",
#        "//tensorflow/core:test",
#        "//tensorflow/core:test_main",
#        "@com_google_absl//absl/types:optional",
#    ],
#)
#
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
#tf_custom_op_library(
#    name = "test_op1.so",
#    srcs = ["test_op1.cc"],
#)
#
#tf_kernel_library(
#    name = "test_op_kernel",
#    srcs = ["test_op.cc"],
#    deps = [
#        "//tensorflow/core:framework",
#        "//tensorflow/core:lib",
#    ],
#    alwayslink = 1,
#)
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
