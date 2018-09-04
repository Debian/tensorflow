#!/usr/bin
set -x

# Probe working directory
if test -r ./shogun.py; then
	SHOGUN="python3 shogun.py"
	DATADIR="./bazelDumps/"
elif test -r ./debian/shogun.py; then
	SHOGUN="python3 debian/shogun.py"
	DATADIR="./debian/bazelDumps/"
else
	echo where are you?
	exit 1
fi

$SHOGUN AllProto

$SHOGUN ProtoText -i $DATADIR/tf_tool_proto_text.source_file.txt \
	-g $DATADIR/tf_tool_proto_text.generated_file.txt

#$SHOGUN TFCoreProto -i $DATADIR/tf_core_proto_text.source_file.txt \
#	-g $DATADIR/tf_core_proto_text.generated_file.txt
#
#$SHOGUN TFFrame -i $DATADIR/tf_libtensorflow_framework_so.source_file.txt \
#	-g $DATADIR/tf_libtensorflow_framework_so.generated_file.txt
#
#$SHOGUN TFLibAndroid -i $DATADIR/tf_core_android_tflib.source_file.txt \
#	-g $DATADIR/tf_core_android_tflib.generated_file.txt
#
#$SHOGUN CCOP -i $DATADIR/tf_libtensorflow_so.source_file.txt \
#	-g $DATADIR/tf_libtensorflow_so.generated_file.txt
#
#$SHOGUN TFLib -i $DATADIR/tf_libtensorflow_so.source_file.txt \
#	-g $DATADIR/tf_libtensorflow_so.generated_file.txt
