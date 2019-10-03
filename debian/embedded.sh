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
#ln -s . bazel-out
#ln -s . k8-opt
#ln -s . host
#ln -s . bin
cp -v debian/buildlogs/gen_proto_text_functions-2.params tensorflow/tools/proto_text/gen_proto_text_functions-2.params
cp -v debian/patches/cuda_config.h third_party/gpus/cuda/cuda_config.h
cp -v debian/patches/tensorrt_config.h third_party/tensorrt/tensorrt_config.h

which pypy3 && PY=pypy3 || PY=python3
$PY debian/fakebazel.py
NINJA_STATUS="[1;31m[%es (%p) %f/%t][0;m " ninja -v
