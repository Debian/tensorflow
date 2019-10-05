#!/bin/sh
set -xe

src=(
tensorflow/c/c_test_util.cc
tensorflow/core/platform/posix/test.cc
tensorflow/core/framework/op_def_builder.cc
tensorflow/core/platform/default/logging.cc
tensorflow/core/lib/strings/str_util.cc
tensorflow/core/platform/stacktrace_handler.cc
tensorflow/core/common_runtime/kernel_benchmark_testlib.cc
tensorflow/c/c_api_experimental.cc
tensorflow/core/platform/default/test_benchmark.cc
)
elf=tf_c_api_test.elf
flags=

source debian/_c_test
exit 0
