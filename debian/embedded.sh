# prepare embedded source code
set -x
if ! test -d external/com_google_absl/; then
  mkdir -p external/com_google_absl/
  tar xf debian/embedded/43ef2148c0936ebf7cb4be6b19927a9d9d145b8f.tar.gz -C external/com_google_absl/ --strip-components=1
fi
if ! test -d external/eigen3/; then
  mkdir -p external/eigen3/
  tar xf debian/embedded/049af2f56331.tar.gz -C external/eigen3 --strip-components=1
  #cp -av third_party/eigen3 external/
fi
if ! test -d external/include/; then
  mkdir external/include
  ln -s /usr/include/jsoncpp/json external/include/
fi
cp -v debian/buildlogs/gen_proto_text_functions-2.params tensorflow/tools/proto_text/gen_proto_text_functions-2.params
cp -v debian/buildlogs/libtensorflow_framework.so.2.0.0-2.params tensorflow/
cp -v debian/patches/version_info.cc tensorflow/core/util/version_info.cc
cp -v debian/patches/cuda_config.h third_party/gpus/cuda/cuda_config.h
cp -v debian/patches/tensorrt_config.h third_party/tensorrt/tensorrt_config.h

mkdir -p external/bazel_tools/tools/genrule/
cp -v debian/patches/genrule-setup.sh external/bazel_tools/tools/genrule/genrule-setup.sh
for I in $(ls debian/buildlogs/*.genrule_script.sh); do
	cp -v $I tensorflow/cc/
	sed -i -e 's@bazel-out/k8-opt/bin/@@g' \
		-e 's@bazel-out/host/bin/@@g' tensorflow/cc/$(basename $I)
done

which pypy3 && PY=pypy3 || PY=python3
$PY debian/fakebazel.py
NINJA_STATUS="[1;31m[%es (%p) %f/%t][0;m " ninja -v
