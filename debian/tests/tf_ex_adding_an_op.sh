#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow_framework -lpthread -lprotobuf"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIC"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_1.cc \
	-o zero_out_op_kernel_1.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_2.cc \
	-o zero_out_op_kernel_2.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_3.cc \
	-o zero_out_op_kernel_3.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/attr_examples.cc \
	-o attr_examples.so -shared

libs="-L. -ltensorflow_cc -lpthread -lprotobuf"

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_1.cc \
	-o zero_out_op_kernel_1.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_2.cc \
	-o zero_out_op_kernel_2.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/zero_out_op_kernel_3.cc \
	-o zero_out_op_kernel_3.so -shared

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	tensorflow/examples/adding_an_op/attr_examples.cc \
	-o attr_examples.so -shared

exit 0
