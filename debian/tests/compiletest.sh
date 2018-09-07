cp test.ninja.in test.ninja

testsrc=$(diff -ru debian/bazelDumps/SRC__tensorflow_libtensorflow_cc_so debian/bazelDumps/SRC__tf_alltest_nocontrib_nopy \
	| grep -e '^+' | grep -v -e '^+@' | grep -v 'third_party' | grep -v debian \
	| sed -e 's#^\+//##g' | sed -e 's#:#/#g' \
	| grep -v -e '.*pbtxt$' \
	| grep -v 'tensorflow/python' \
	| grep -v 'tensorflow/tools' \
	| grep -v 'tensorflow/examples' \
	| grep -v 'tensorflow/contrib' \
	| grep -v -e 'test*data' \
	| grep -e '.*cc$' \
	| grep -v ops \
	| grep -v kernels \
	| grep -v hadoop \
	| grep -v cloud \
	| grep -v debug \
	| grep -v s3 \
	| grep -v example \
	| grep -v windows \
	| grep -v python \
	| grep -v tool \
	| grep -v main \
	| grep -v grappler \
	| grep -v fingerprint \
	| grep -v shape_refiner_test \
	| grep -v constant_folding_test \
	| grep -v function_test \
	| grep -v function_threadpool_test \
	| grep -v lower_if_op_test \
	| grep -v .cu.cc \
	| grep -v gpu \
	| grep -v graph_to_functiondef_test \
	| grep -v graph_partition_test \
	| grep -v presized_cuckoo_map_test \
	| grep -v distributed)

for src in $testsrc; do
	echo build $(echo $src | sed -e 's#.cc$#.o#'): cxxobj $src >> test.ninja
done

echo "build test: cxxexe $" >> test.ninja
for src in $testsrc; do
	echo " $(echo $src | sed -e 's#.cc$#.o#') $" >> test.ninja
done
echo " tensorflow/contrib/makefile/test/test_main.cc" >> test.ninja
echo " libs = -Wl,--start-group -lgtest -ltensorflow_cc -ltensorflow_framework -lgtest -lprotobuf -lpthread -ljpeg -ldl -lm -lsqlite3 -Wl,--end-group" >> test.ninja

ninja -f test.ninja -v

#FIXME: undefined symbols
