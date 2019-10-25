#!/bin/bash
set -ex

src=(
tensorflow/core/framework/allocator_test.cc
#tensorflow/cc/framework/scope.cc
#tensorflow/cc/client/client_session.cc
tensorflow/core/platform/default/test_benchmark.cc
tensorflow/core/util/reporter.cc
tensorflow/core/platform/test_main.cc
)
elf=tf_framework_test.elf
flags=-I.
libs="-lprotobuf -ltensorflow_framework -lgtest -lpthread"

export _CC_NORM=1
source debian/tests/_cc_test
./tf_framework_test.elf
exit 0
