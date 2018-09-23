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
	-o libtensorflow_framework.ninja \
	-H libtensorflow_framework.hdrs \
	-O libtensorflow_framework.so \
	-b libtfccopgen.so

$SHOGUN Generator \
	-g $DATADIR/GEN__tensorflow_libtensorflow_so \
	-o libtensorflow.gen.ninja
$SHOGUN TFLib \
	-i $DATADIR/SRC__tensorflow_libtensorflow_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_so \
	-o libtensorflow.ninja \
	-H libtensorflow.hdrs \
	-O libtensorflow.so

$SHOGUN Generator \
	-g $DATADIR/GEN__tensorflow_libtensorflow_cc_so \
	-o libtensorflow_cc.gen.ninja
$SHOGUN TFLib \
	-i $DATADIR/SRC__tensorflow_libtensorflow_cc_so \
	-g $DATADIR/GEN__tensorflow_libtensorflow_cc_so \
	-o libtensorflow_cc.ninja \
	-H libtensorflow_cc.hdrs \
	-O libtensorflow_cc.so

$SHOGUN Generator \
	-g $DATADIR/GEN__tensorflow_python_pywrap_tensorflow \
	-o pywrap_tensorflow_internal.gen.ninja
