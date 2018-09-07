#!/bin/sh
set -xe

lib="
tensorflow/c/c_test_util.cc
tensorflow/core/platform/posix/test.cc
tensorflow/core/framework/op_def_builder.cc
tensorflow/core/platform/default/logging.cc
tensorflow/core/lib/strings/str_util.cc
tensorflow/core/platform/stacktrace_handler.cc
tensorflow/core/common_runtime/kernel_benchmark_testlib.cc
tensorflow/c/c_api_experimental.cc
tensorflow/core/platform/default/test_benchmark.cc
tensorflow/core/util/reporter.cc
"
libobj=$(echo $lib | sed -e 's#\.cc#.o#g')

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow -I/usr/include/tensorflow/eigen3"
libs="-L. -Wl,--start-group -ltensorflow_cc -lpthread -lprotobuf -lgtest -ldl -Wl,--end-group"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIC"
ldflags=""

# compile lib objects
parallel \
	"printf \" CXX %s\n\" {} ; $cxx $cppflags $cxxflags $ldflags $incdir $libs -c {} -o {.}.o" \
	::: $lib

# compile an test op for unit tests
$cxx tensorflow/c/test_op.cc \
	-I/usr/include/tensorflow/ -I/usr/include/tensorflow/eigen3 \
	-ltensorflow_cc -shared -fPIC -O2 \
	-o tensorflow/c/test_op.so

# compile the unit test ELF executable
$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	$libobj \
	tensorflow/c/c_api_test.cc \
	tensorflow/core/platform/test_main.cc \
	-o tf_c_api_test -lgtest

if ! test -r libtensorflow_cc.so.1.10; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.1.10 || true
fi
LD_LIBRARY_PATH=. ./tf_c_api_test

exit 0
