#!/bin/bash
set -ex

src=(
tensorflow/cc/tutorials/example_trainer.cc
)
elf=example_trainer.elf
libs="-lprotobuf -Wl,--start-group -ltensorflow_framework -ltensorflow_cc -Wl,--end-group"

export _CC_NORM=1
source debian/tests/_cc_test
./example_trainer.elf
exit 0
