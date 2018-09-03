#!/usr/bin
set -x
SHOGUN="python3 shogun.py"

$SHOGUN ProtoText -i tf_tool_proto_text.source_file.txt \
	-g tf_tool_proto_text.generated_file.txt

$SHOGUN TFCoreProto -i tf_core_proto_text.source_file.txt \
	-g tf_core_proto_text.generated_file.txt

$SHOGUN TFFrame -i tf_libtensorflow_framework_so.source_file.txt \
	-g tf_libtensorflow_framework_so.generated_file.txt

#$SHOGUN TFLibAndroid -i tf_core_android_tflib.source_file.txt \
#	-g tf_core_android_tflib.generated_file.txt

#tf_libtensorflow_so.generated_file.txt
#tf_libtensorflow_so.source_file.txt
