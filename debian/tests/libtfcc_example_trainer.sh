#!/bin/bash
set -ex

src=(
tensorflow/cc/tutorials/example_trainer.cc
)
elf=example_trainer.elf

# CXX
xe -avj0 g++ -O2 -fPIC -c -I. -- "${src[@]}"
# LD
g++ -fPIE -pie -O2 -Wl,--start-group \
	-ltensorflow_cc \
	*.o \
	-Wl,--end-group -o $elf

./$elf
rm *.o $elf

exit 0
