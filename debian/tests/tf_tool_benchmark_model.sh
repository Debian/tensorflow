#!/bin/sh
set -xe
export _CC_NORM=1

src=(
tensorflow/core/util/reporter.cc
tensorflow/tools/benchmark/benchmark_model.cc
tensorflow/tools/benchmark/benchmark_model_main.cc
)
elf=tf_benchmark_model.elf
flags="-Wl,--allow-multiple-definition -Wl,--whole-archive -I."
libs="-lpthread -ltensorflow_framework -ltensorflow  -lprotobuf "
source debian/tests/_cc_test

LD_LIBRARY_PATH=. ./tf_benchmark_model.elf || true

if ! test -r inception5h.zip; then
wget -c https://storage.googleapis.com/download.tensorflow.org/models/inception5h.zip
unzip inception5h.zip -d /tmp/
fi

./tf_benchmark_model.elf --graph=/tmp/tensorflow_inception_graph.pb

exit 0

