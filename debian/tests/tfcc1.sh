set -x
cc="debian/tests/tfcc1.cc"
cxxflags="-O2"
inc="-I. -Idebian/embedded/eigen"
lib="-ltensorflow -L.. -L."

g++ $cxxflags $inc $lib $cc -o tfcc1
