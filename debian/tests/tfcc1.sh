set -x
cc="debian/tests/tfcc1.cc"
cxxflags="-O2"
inc="-I. -Idebian/embedded/eigen3 -I/usr/include/tensorflow"
lib="-ltensorflow -L.. -L."

sh debian/embedded.sh

g++ $cxxflags $inc $lib $cc -o tfcc1
