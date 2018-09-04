# prepare embedded source code
set -x
if ! test -d debian/embedded/eigen; then
  tar -zxf debian/embedded/fd6845384b86.tar.gz -C debian/embedded/
  mv debian/embedded/eigen* debian/embedded/eigen
fi
if ! test -d debian/embedded/fft; then
  tar -zxf debian/embedded/fft.tgz -C debian/embedded/
fi
