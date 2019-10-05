#!/bin/bash
set -ex

# translated from tensorflow/core/BUILD's tf_cc_test targets

common=(
tensorflow/core/platform/test_main.cc
tensorflow/core/util/reporter.cc
tensorflow/core/platform/default/test_benchmark.cc
)

elf=platform_unbounded_work_queue_test
src=(
tensorflow/core/platform/unbounded_work_queue_test.cc
)
src+=( ${common[@]} )
tflib=f
flags="-I. -pthread"
libs="-lprotobuf -l:libgtest.a"
source debian/_cc_test

elf=stats_calculator_test
src=( tensorflow/core/util/stats_calculator_test.cc )
src+=( ${common[@]} )
source debian/_cc_test
