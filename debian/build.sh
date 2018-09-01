#!/bin/sh
set -x
JOBS=72
sh debian/embedded.sh
make -f debian/proto_text.mk -j$JOBS
make -f debian/tf_proto_text.mk -j$JOBS
make -f debian/tf_proto.mk -j$JOBS
make -f debian/tf_core_ops.mk -j$JOBS
make -f debian/tf_core_kernels.mk -j$JOBS
