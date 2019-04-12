# prepare embedded source code
set -x
if ! test -d debian/embedded/eigen3; then
  tar xf debian/embedded/eigen/5a4931dafc1c.tar.gz -C debian/embedded/
  mv debian/embedded/eigen-eigen-5a4931dafc1c debian/embedded/eigen3
fi
if ! test -d debian/embedded/fft; then
  tar -zxf debian/embedded/fft.tgz -C debian/embedded/
fi
if ! test -d debian/embedded/abseil/build; then
  cd debian/embedded/abseil; sh build-abseil-static.sh
fi
