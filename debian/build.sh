#!/bin/sh
# Build with native makefile from a clean git repo.
set -x
JOBS=72
sh debian/bazelQuery.sh
echo "tensorflow/core/protobuf/eager_service.proto
tensorflow/core/grappler/costs/op_performance_data.proto
tensorflow/core/kernels/boosted_trees/boosted_trees.proto" >> tf_proto_files.txt
sh debian/embedded.sh
make -f debian/proto_text.mk -j$JOBS
make -f debian/tf_proto.mk -j$JOBS
make -f debian/tf_core.mk -j$JOBS
make -f debian/tf_cc_op_gen.mk -j$JOBS
make -f debian/tf_cc.mk -j$JOBS
make -f debian/tf_c.mk -j$JOBS
make -f debian/tf_shlib.mk -j$JOBS
make -f debian/tf_benchmark_model.mk -j$JOBS
