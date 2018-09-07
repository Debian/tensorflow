#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow -lm"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/tools/lib_package/libtensorflow_test.c \
	-o tf_libtensorflow_test

if ! test -r libtensorflow.so.1.10; then
	ln -sr libtensorflow.so libtensorflow.so.1.10 || true
fi
LD_LIBRARY_PATH=. ./tf_libtensorflow_test

exit 0
