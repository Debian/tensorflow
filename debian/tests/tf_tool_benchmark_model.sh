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
# See https://github.com/tensorflow/models/tree/master/research/slim#pre-trained-models
wget -c http://download.tensorflow.org/models/resnet_v2_50_2017_04_14.tar.gz
tar xvf resnet_v2_50_2017_04_14.tar.gz -C /tmp/
wget -c http://download.tensorflow.org/models/inception_v4_2016_09_09.tar.gz
tar xvf inception_v4_2016_09_09.tar.gz -C /tmp/
wget -c https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.4_224.tgz
tar xvf mobilenet_v2_1.4_224.tgz -C /tmp/
wget -c https://storage.googleapis.com/download.tensorflow.org/models/inception5h.zip
unzip inception5h.zip -d /tmp/
fi

./tf_benchmark_model.elf --graph=/tmp/tensorflow_inception_graph.pb

exit 0

