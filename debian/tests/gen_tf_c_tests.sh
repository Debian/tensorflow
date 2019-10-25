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

elf=test_op_kernel.so
src=( tensorflow/c/test_op.cc )
flags="$CFLAGS -shared"
libs="-ltensorflow_framework"
tflib=
source debian/tests/_cc_test

elf=test_op1.so
src=( tensorflow/c/test_op1.cc )
flags="$CFLAGS -shared"
libs="-ltensorflow_framework"
tflib=
source debian/tests/_cc_test

g++ $CFLAGS -c $D/c_test.c -o $D/c_test.o
g++ $CFLAGS -c $D/env.cc -o $D/env.o
g++ $CFLAGS -Wl,--start-group $D/c_test.o $D/env.o -ltensorflow_framework -ltensorflow -Wl,--end-group -o c_test
./c_test
