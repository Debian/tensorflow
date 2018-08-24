Debian's customized TensorFlow CMake build
==========================================

> Copyright (C) 2018 Mo Zhou. MIT/Expat License.

Modified based on Tensorflow v1.10.0 's CMake build.

 1. Windows/MacOS support is removed.
 2. Downloading is totally disallowed during build.
 3. Use system provided libraries as long as possible.
 4. Only core functionality will be provided. contrib stuff will not be built.

We forked the CMake build because:

 https://github.com/tensorflow/tensorflow/issues/13061#issuecomment-414418853

 Since upstream is going to drop cmake, I no longer have enough patience
 to complete this pull request https://github.com/tensorflow/tensorflow/pull/21699 .
