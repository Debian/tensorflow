#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow_cc -lpthread -lprotobuf"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/label_image/main.cc \
	-o tf_ex_label_image

if ! test -r libtensorflow_cc.so.1.10; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.1.10 || true
fi

# according to tensorflow/examples/label_image
curl -L "https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz" | tar -C tensorflow/examples/label_image/data -xz

LD_LIBRARY_PATH=. ./tf_ex_label_image --help || true

exit 0

