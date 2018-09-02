# Must use [bazel release 0.15.0]]

bazel query 'kind("source file", deps(//tensorflow/tools/lib_package:libtensorflow))' \
	> debian/ninja/tf_tools_lib_package_libtensorflow.source_file.txt

bazel query 'kind("generated file", deps(//tensorflow/tools/lib_package:libtensorflow))' \
	> debian/ninja/tf_tools_lib_package_libtensorflow.generated_file.txt
