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

# ---
export PYTHON_BIN_PATH=/usr/bin/python3
export USE_DEFAULT_PYTHON_LIB_PATH=1
export TF_NEED_JEMALLOC=0
export TF_NEED_KAFKA=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_AWS=0
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export TF_NEED_S3=0
export TF_ENABLE_XLA=1
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL=0
export TF_NEED_MPI=0
export TF_NEED_TENSORRT=0
export TF_NEED_NGRAPH=0
export TF_NEED_IGNITE=0
export TF_NEED_ROCM=0
export TF_SET_ANDROID_WORKSPACE=0
export TF_DOWNLOAD_CLANG=0
export TF_CUDA_CLANG=0
export TF_IGNORE_MAX_BAZEL_VERSION=0
export TF_NEED_CUDA=0
export CC_OPT_FLAGS="-march=x86-64"
./configure
# ---

bazelDump () {
	# generate mangled query to be used as filename
	local mq="$(echo $1 | sed -e 's#:#_#' -e 's#/#_#g' -e 's#\.#_#g')"

	# query all required source files
	bazel query "kind(\"source file\", deps($1))" \
		--incompatible_disallow_dict_plus=false \
	| awk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq \
	> $datadir/SRC$mq

	# query all required generated files
	bazel query "kind(\"generated file\", deps($1))" \
		--incompatible_disallow_dict_plus=false \
	| awk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
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
	| awk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
	| sort | uniq > $datadir/SRC$1
	cat $datadir/TMPGEN$1 \
	| awk '{if ($0~/^@/){split($0, sp, "//"); print sp[1];} else {print}}' \
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
bazelDump //tensorflow/tools/pip_package:build_pip_package

#bazelDumpNonPythonTestTargets __tf_alltest_nocontrib_nopy
