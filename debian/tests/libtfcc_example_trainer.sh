#!/bin/bash
set -ex

src=(
tensorflow/cc/tutorials/example_trainer.cc
)
elf=example_trainer.elf
libs=-lprotobuf

source debian/tests/_cc_test
exit 0
