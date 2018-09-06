# prepare embedded source code
set -x
if ! test -d debian/embedded/eigen3; then
  tar -zxf debian/embedded/fd6845384b86.tar.gz -C debian/embedded/
  mv debian/embedded/eigen* debian/embedded/eigen3
fi
if ! test -d debian/embedded/fft; then
  tar -zxf debian/embedded/fft.tgz -C debian/embedded/
fi
