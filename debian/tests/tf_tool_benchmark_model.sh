#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow_cc -lpthread -lprotobuf"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/core/util/reporter.cc \
	tensorflow/tools/benchmark/benchmark_model.cc \
	tensorflow/tools/benchmark/benchmark_model_main.cc \
	-o tf_benchmark_model

if ! test -r libtensorflow_cc.so.1.10; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.1.10 || true
fi
LD_LIBRARY_PATH=. ./tf_benchmark_model

exit 0

