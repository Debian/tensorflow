#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow_cc -lpthread -lprotobuf"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/cc/tutorials/example_trainer.cc \
	-o tf_example_trainer

if ! test -r libtensorflow_cc.so.2.0; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.2.0 || true
fi
LD_LIBRARY_PATH=. ./tf_example_trainer

exit 0
