#!/bin/bash
set -ex

src=(
tensorflow/cc/tutorials/example_trainer.cc
)
elf=example_trainer.elf

source debian/_cc_test
exit 0
