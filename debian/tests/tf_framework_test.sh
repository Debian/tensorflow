#!/bin/bash
set -ex

src=(
tensorflow/core/framework/allocator_test.cc
tensorflow/cc/framework/scope.cc
tensorflow/cc/client/client_session.cc
tensorflow/core/platform/default/test_benchmark.cc
tensorflow/core/util/reporter.cc
)
elf=tf_framework_test.elf
flags=

source debian/_framework_test
exit 0
