#!/bin/bash
set -ex

src=(
tensorflow/tools/lib_package/libtensorflow_test.c
)
elf=libtensorflow_test.elf
flags=
tflib=c

export _CC_NORM
source debian/tests/_cc_test
./libtensorflow_test.elf
exit 0
