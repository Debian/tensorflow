#!/usr/bin
set -x

# Probe working directory
if test -r ./shogun.py; then
	export DNINJA="."
elif test -r ./debian/ninja/shogun.py; then
	export DNINJA="./debian/ninja"
else
	echo Please chdir to the root of source tree or debian/ninja!
	exit 1
fi

# shogun program
SHOGUN="python3 $DNINJA/shogun.py"

$SHOGUN ProtoText -i $DNINJA/tf_tool_proto_text.source_file.txt \
	-g $DNINJA/tf_tool_proto_text.generated_file.txt

$SHOGUN TFCoreProto -i $DNINJA/tf_core_proto_text.source_file.txt \
	-g $DNINJA/tf_core_proto_text.generated_file.txt

$SHOGUN TFFrame -i $DNINJA/tf_libtensorflow_framework_so.source_file.txt \
	-g $DNINJA/tf_libtensorflow_framework_so.generated_file.txt

#$SHOGUN TFLibAndroid -i tf_core_android_tflib.source_file.txt \
#	-g tf_core_android_tflib.generated_file.txt

#tf_libtensorflow_so.generated_file.txt
#tf_libtensorflow_so.source_file.txt
