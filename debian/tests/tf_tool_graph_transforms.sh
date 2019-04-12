#!/bin/sh
set -xe

export CXXFLAGS=" -I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow/eigen3"
export CXXFLAGS=" $CXXFLAGS -L. -ltensorflow_cc -lpthread -lprotobuf -I/usr/include/gemmlowp"
cxx="g++"
cxxflags=$CXXFLAGS

lib="
tensorflow/tools/graph_transforms/add_default_attributes.cc
tensorflow/tools/graph_transforms/backports.cc
tensorflow/tools/graph_transforms/file_utils.cc
tensorflow/tools/graph_transforms/flatten_atrous.cc
tensorflow/tools/graph_transforms/fold_batch_norms.cc
tensorflow/tools/graph_transforms/fold_constants_lib.cc
tensorflow/tools/graph_transforms/fold_old_batch_norms.cc
tensorflow/tools/graph_transforms/freeze_requantization_ranges.cc
tensorflow/tools/graph_transforms/fuse_convolutions.cc
tensorflow/tools/graph_transforms/insert_logging.cc
tensorflow/tools/graph_transforms/obfuscate_names.cc
tensorflow/tools/graph_transforms/quantize_nodes.cc
tensorflow/tools/graph_transforms/quantize_weights.cc
tensorflow/tools/graph_transforms/remove_attribute.cc
tensorflow/tools/graph_transforms/remove_control_dependencies.cc
tensorflow/tools/graph_transforms/remove_device.cc
tensorflow/tools/graph_transforms/remove_nodes.cc
tensorflow/tools/graph_transforms/rename_attribute.cc
tensorflow/tools/graph_transforms/rename_op.cc
tensorflow/tools/graph_transforms/round_weights.cc
tensorflow/tools/graph_transforms/set_device.cc
tensorflow/tools/graph_transforms/sort_by_execution_order.cc
tensorflow/tools/graph_transforms/sparsify_gather.cc
tensorflow/tools/graph_transforms/strip_unused_nodes.cc
tensorflow/tools/graph_transforms/transform_graph.cc
tensorflow/tools/graph_transforms/transform_utils.cc
"
objs=$(echo $lib | sed -e 's#\.cc#.o#g')

# compile lib objects
./debian/parallel $lib

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	$objs \
	tensorflow/tools/graph_transforms/compare_graphs.cc \
	-o tf_compare_graphs

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	$objs \
	tensorflow/tools/graph_transforms/summarize_graph_main.cc \
	-o tf_summarize_graph

$cxx $cppflags $cxxflags $ldflags $incdir $libs \
	$objs \
	tensorflow/tools/graph_transforms/transform_graph_main.cc \
	-o tf_transform_graph

if ! test -r libtensorflow_cc.so.2.0; then
	ln -sr libtensorflow_cc.so libtensorflow_cc.so.2.0 || true
fi

LD_LIBRARY_PATH=. ./tf_compare_graphs --help || true
LD_LIBRARY_PATH=. ./tf_summarize_graph --help || true
LD_LIBRARY_PATH=. ./tf_transform_graph --help || true

exit 0
