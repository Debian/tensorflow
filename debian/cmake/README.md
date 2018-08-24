Debian's customized TensorFlow CMake build
==========================================

Modified based on Tensorflow v1.10.0 's CMake build.

1. Windows/MacOS support is removed.
2. Downloading is totally disallowed during build.
3. Use system provided libraries as long as possible.
4. contrib stuff will not be built.
