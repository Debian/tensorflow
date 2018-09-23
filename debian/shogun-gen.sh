#!/usr/bin
set -x

# Probe working directory
if test -r ./shogun.py; then
	SHOGUN="python3 shogun.py"
	DATADIR="bazelDumps"
elif test -r ./debian/shogun.py; then
	SHOGUN="python3 debian/shogun.py"
	DATADIR="debian/bazelDumps"
else
	echo where are you?
	exit 1
fi

$SHOGUN Generator \
	-g $DATADIR/GEN__tensorflow_tools_proto_text_gen_proto_text_functions \
	-o proto_text.gen.ninja

$SHOGUN ProtoText \
	-i $DATADIR/SRC__tensorflow_tools_proto_text_gen_proto_text_functions \
	-g $DATADIR/GEN__tensorflow_tools_proto_text_gen_proto_text_functions \
	-o proto_text.ninja

$SHOGUN Generator \
	-g $DATADIR/GEN__tensorflow_libtensorflow_framework_so \
	-o libtensorflow_framework.gen.ninja

$SHOGUN TFLib_framework \
	-i $DATADIR/SRC__tensorflow_libtensorflow_framework_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_framework_so \
	-o libtensorflow_framework.ninja

#$SHOGUN CCOP \
#	-i $DATADIR/SRC__tensorflow_libtensorflow_so \
#	-g $DATADIR/GEN__tensorflow_libtensorflow_so
#
#$SHOGUN TFLib \
#	-i $DATADIR/SRC__tensorflow_libtensorflow_so \
#	-g $DATADIR/GEN__tensorflow_libtensorflow_so
#
#$SHOGUN TFCCLib \
#	-i $DATADIR/SRC__tensorflow_libtensorflow_cc_so \
#	-g $DATADIR/GEN__tensorflow_libtensorflow_cc_so
