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

$SHOGUN AllProto

$SHOGUN ProtoText \
	-i $DATADIR/SRC__tensorflow_tools_proto_text_gen_proto_text_functions \
	-g $DATADIR/GEN__tensorflow_tools_proto_text_gen_proto_text_functions

$SHOGUN TFLib_framework \
	-i $DATADIR/SRC__tensorflow_libtensorflow_framework_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_framework_so

$SHOGUN CCOP \
	-i $DATADIR/SRC__tensorflow_libtensorflow_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_so

$SHOGUN TFLib \
	-i $DATADIR/SRC__tensorflow_libtensorflow_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_so

$SHOGUN TFCCLib \
	-i $DATADIR/SRC__tensorflow_libtensorflow_cc_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_cc_so
