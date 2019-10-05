#!/bin/sh
set -ex

src=(
tensorflow/core/kernels/ops_testutil.cc
tensorflow/core/common_runtime/function_testlib.cc
tensorflow/core/framework/function_testlib.cc
tensorflow/core/api_def/excluded_ops.cc
tensorflow/cc/framework/cc_op_gen.cc
)
elf=tf_core_test.elf
flags=

source debian/_cc_test
exit 0
