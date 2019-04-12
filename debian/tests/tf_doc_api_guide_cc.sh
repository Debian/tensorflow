#!/bin/sh
set -xe

incdir="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
libs="-L. -ltensorflow_cc -lpthread -lprotobuf"
cxx="g++"
cppflags=""
cxxflags="-w -O2 -fPIE -pie"
ldflags=""

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	debian/tests/tf_doc_api_guide_cc.cc \
	-o tf_doc_api_guide_cc

if ! test -r libtensorflow_cc.so.2.0; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.2.0 || true
fi
LD_LIBRARY_PATH=. ./tf_doc_api_guide_cc

exit 0
