#!/bin/sh
set -xe

g++ -ltensorflow -lgtest -lpthread \
	debian/tests/capi/TF_Version.cc -lgtest \
	-o TF_Version
./TF_Version
