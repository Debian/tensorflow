#!/bin/sh
set -ex
g++ debian/tests/myop.cc -I/usr/include/tensorflow -ltensorflow_framework -shared -fPIC -o myop.so -O2
