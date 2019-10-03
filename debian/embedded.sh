# prepare embedded source code
set -x
if ! test -d external/com_google_absl/; then
  mkdir -p external/com_google_absl/
  tar xf debian/embedded/43ef2148c0936ebf7cb4be6b19927a9d9d145b8f.tar.gz -C external/com_google_absl/ --strip-components=1
fi
#ln -s . bazel-out
#ln -s . k8-opt
#ln -s . host
#ln -s . bin
cp -v debian/buildlogs/gen_proto_text_functions-2.params tensorflow/tools/proto_text/gen_proto_text_functions-2.params
