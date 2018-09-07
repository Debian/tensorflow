#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow -lpthread -lprotobuf -lgtest"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/c/c_test_util.cc \
	tensorflow/c/c_api_test.cc \
	tensorflow/core/platform/posix/test.cc \
	tensorflow/contrib/makefile/test/test_main.cc \
	-o tf_c_api_test

if ! test -r libtensorflow_cc.so.1.10; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.1.10 || true
fi
LD_LIBRARY_PATH=. ./tf_c_api_test

exit 0
