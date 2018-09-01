# prepare embedded source code
set -x
tar -zxvf debian/embedded/fd6845384b86.tar.gz -C debian/embedded/
mv debian/embedded/eigen* debian/embedded/eigen
tar -zxvf debian/embedded/fft.tgz -C debian/embedded/
