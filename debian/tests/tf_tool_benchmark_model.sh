#!/bin/sh
set -xe
export _CC_NORM=1

src=(
tensorflow/core/util/reporter.cc
tensorflow/tools/benchmark/benchmark_model.cc
tensorflow/tools/benchmark/benchmark_model_main.cc
)
elf="tf_benchmark_model.elf"
flags=" -I. -ltensorflow_cc"
libs="-lpthread -ltensorflow_cc -ltensorflow_framework -lprotobuf "
tflib=cc
source debian/tests/_cc_test

#g++ -O2 \
#	tensorflow/core/util/reporter.cc \
#	tensorflow/tools/benchmark/benchmark_model.cc \
#	tensorflow/tools/benchmark/benchmark_model_main.cc \
#	-ltensorflow_cc \
#	-I. -I/usr/include/tensorflow -ltensorflow_framework -lprotobuf


if (! test -r inception5h.zip) && (! test -r /tmp/tensorflow_inception_graph.pb); then
# See https://github.com/tensorflow/models/tree/master/research/slim#pre-trained-models
wget -c https://storage.googleapis.com/download.tensorflow.org/models/inception5h.zip
unzip inception5h.zip -d /tmp/
fi

LD_LIBRARY_PATH=. ./tf_benchmark_model.elf --graph=/tmp/tensorflow_inception_graph.pb

exit 0

