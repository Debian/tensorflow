# prepare embedded source code
if ! test -d external/com_google_absl/; then
  echo [[[ embedded / ABSL ]]]
  mkdir -p external/com_google_absl/
  tar xf debian/embedded/43ef2148c0936ebf7cb4be6b19927a9d9d145b8f.tar.gz -C external/com_google_absl/ --strip-components=1
fi

if ! test -d external/eigen3/; then
  echo [[[ embedded / Eigen3 ]]]
  mkdir -p external/eigen3/
  tar xf debian/embedded/049af2f56331.tar.gz -C external/eigen3 --strip-components=1
  #cp -av third_party/eigen3 external/
fi
