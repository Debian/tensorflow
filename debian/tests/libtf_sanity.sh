#!/bin/bash
set -ex

src=(
tensorflow/tools/lib_package/libtensorflow_test.c
)
elf=libtensorflow_test.elf
flags=

source debian/_cc_test

exit 0
