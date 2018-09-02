# Must use [bazel release 0.15.0]]
#
# If Bazel complain "util/hash not found blah blah blah", just remove the
# corresponding line in bazel's BUILD file and try again.

bazel query 'kind("source file", deps(//tensorflow/tools/proto_text:gen_proto_text_functions))' \
	> debian/ninja/tf_tool_proto_text.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/tools/proto_text:gen_proto_text_functions))' \
	> debian/ninja/tf_tool_proto_text.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow:libtensorflow.so))' \
	> debian/ninja/tf_libtensorflow_so.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow:libtensorflow.so))' \
	> debian/ninja/tf_libtensorflow_so.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/tools/lib_package:libtensorflow_test))' \
	> debian/ninja/tf_libtensorflow_test.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/tools/lib_package:libtensorflow_test))' \
	> debian/ninja/tf_libtensorflow_test.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/python:pywrap_tensorflow))' \
	> debian/ninja/tf_python_pywrap_tensorflow.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/python:pywrap_tensorflow))' \
	> debian/ninja/tf_python_pywrap_tensorflow.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow:libtensorflow_framework.so))' \
	> debian/ninja/tf_libtensorflow_framework_so.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow:libtensorflow_framework.so))' \
	> debian/ninja/tf_libtensorflow_framework_so.generated_file.txt
