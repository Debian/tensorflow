#!/bin/bash
set -ex

src=(
tensorflow/tools/lib_package/libtensorflow_test.c
)
elf=libtensorflow_test.elf

# CXX
xe -avj0 gcc -O2 -fPIC -c -- "${src[@]}"
# LD
gcc -fPIE -pie -O2 -Wl,--start-group \
	-ltensorflow \
	*.o \
	-Wl,--end-group -o $elf

./$elf
rm *.o $elf

exit 0
