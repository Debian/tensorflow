#!/bin/sh
set -ex

NINJA_TEMPLATE="debian/tests/tf_core_test.ninja.in"
NINJA=${NINJA_TEMPLATE%.in}
cp $NINJA_TEMPLATE $NINJA

testsrc="
tensorflow/core/framework/allocator_test.cc

tensorflow/cc/framework/scope.cc
tensorflow/cc/client/client_session.cc
tensorflow/core/platform/default/test_benchmark.cc
tensorflow/core/util/reporter.cc
"
for src in $testsrc; do
	echo build $(echo $src | sed -e 's#.cc$#.o#'): cxxobj $src >> $NINJA
done

echo "build test: cxxexe $" >> $NINJA
for src in $testsrc; do
	echo " $(echo $src | sed -e 's#.cc$#.o#') $" >> $NINJA
done
echo " tensorflow/contrib/makefile/test/test_main.cc" >> $NINJA
echo " libs = -Wl,--start-group -lgtest -ltensorflow_framework -lgtest -lprotobuf -lpthread -ljpeg -ldl -lm -lsqlite3 -Wl,--end-group" >> $NINJA

ninja -f $NINJA -v

