# Should probably use [bazel release 0.15.0]]
#
# If Bazel complain "util/hash not found blah blah blah", just remove the
# corresponding line in bazel's BUILD file and try again.
#
# XXX: don't apply any filter here! write the filters in shogun.py
#
# Ref: https://docs.bazel.build/versions/master/query-how-to.html
set -x
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

datadir="debian/bazelDumps"

cat > .bazelrc << EOF
build --action_env PYTHON_BIN_PATH="/usr/bin/python3"
build --action_env PYTHON_LIB_PATH="/usr/lib/python3/dist-packages"
build --python_path="/usr/bin/python3"
build --define with_jemalloc=true
build --define with_gcp_support=true
build --define with_hdfs_support=true
build --define with_aws_support=true
build --define with_kafka_support=true
build:xla --define with_xla_support=true
build:gdr --define with_gdr_support=true
build:verbs --define with_verbs_support=true
build --action_env TF_NEED_OPENCL_SYCL="0"
build --action_env TF_NEED_CUDA="0"
build --action_env TF_DOWNLOAD_CLANG="0"
build --define grpc_no_ares=true
build:opt --copt=-march=native
build:opt --host_copt=-march=native
build:opt --define with_default_optimizations=true
build --strip=always
EOF

bazelDump () {
	# generate mangled query to be used as filename
	local mq="$(echo $1 | sed -e 's#:#_#' -e 's#/#_#g' -e 's#\.#_#g')"

	# query all required source files
	bazel query "kind(\"source file\", deps($1))" \
	| gawk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq \
	> $datadir/SRC$mq

	# query all required generated files
	bazel query "kind(\"generated file\", deps($1))" \
	| gawk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq \
	> $datadir/GEN$mq
}

bazelDumpNonPythonTestTargets () {
	bazel query 'kind(cc_.*, tests(//tensorflow/... -//tensorflow/contrib/... -//tensorflow/python/... -//tensorflow/java/... -//tensorflow/compiler/...))' > $datadir/TEST$1
	touch $datadir/TMPSRC$1
	touch $datadir/TMPGEN$1
	for target in $(cat $datadir/TEST$1); do
		bazel query "kind(\"source file\", deps($target))" >> $datadir/TMPSRC$1
		bazel query "kind(\"generated file\", deps($target))" >> $datadir/TMPGEN$1
	done
	cat $datadir/TMPSRC$1 \
	| gawk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq > $datadir/SRC$1
	cat $datadir/TMPGEN$1 \
	| gawk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq > $datadir/GEN$1
}

# Following queries are arranged in Dependency order.

bazelDump //tensorflow/tools/proto_text:gen_proto_text_functions
bazelDump //tensorflow/core:proto_text
bazelDump //tensorflow/core:tensorflow
bazelDump //tensorflow:libtensorflow_framework.so
bazelDump //tensorflow/tools/lib_package:libtensorflow_test
bazelDump //tensorflow:libtensorflow.so
bazelDump //tensorflow:libtensorflow_cc.so
bazelDump //tensorflow/python:pywrap_tensorflow

#bazelDumpNonPythonTestTargets __tf_alltest_nocontrib_nopy
