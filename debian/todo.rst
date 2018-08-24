Things remain to be done
========================

Exp-Stage A
-----------

Only C and C++ interface is provided.

- [x] prevent the build system from downloading anything.
- [x] produce libtensorflow.so.1.10 and install it into .deb package.
- [x] ambiguous FFT2D license.

- [ ] build tests files (googletest) and run the tests.
- [ ] make sure nothing from contrib is built. they are not officially supported.
- [ ] remove useless parts from cmake build.
- [ ] misc improvements to cmake build.
- [ ] is the resulting libtensorflow.so.1.10 correct and working?
  - [ ] write autopkgtest with some mini C/C++ programs.
  - [ ] working on amd64?
  - [ ] working on ppc64el?
- [ ] make sure libtensorflow/amd64 is linked against libmkldnn

- [ ] upload to experimental.

Exp-Stage B
-----------

Provide the Python interface.

- [ ] build pywrap_tensorflow_internal.so
- [ ] figure out how to generate python API
- [ ] install python files
- [ ] is the resulting python package correct and working?
- [ ] write autopkgtest with some mini python programs.
- [ ] make sure nothing from contrib is built.
- [ ] maintain cmake build.

- [ ] bump debian revision to -B* and upload to experimental.

Exp-Stage C
-----------

Let's wait and see what should be done in this stage.

Unstable
--------

- [ ] upload to unstable.

Stage ???
---------

Well, maybe the following is not going to happen.

- [ ] re-enable GRPC support.
      As long as TF doesn't FTBFS with it.
- [ ] Javascript binding tensorflow.js
      I dislike javascript.
- [ ] Go binding.
      I know nothing about Go.
- [ ] Java binding.
      I dislike java.
- [ ] GPU (CUDA) support
      This requires us to prepare another copy of source code and
      rename it to tensorflow-cuda. (just like what I've done for
      src:caffe and src:caffe-contrib). Apart from that, without
      cuDNN, the GPU version will be pointless and useless.
      CUDA version of tensorflow is not planned yet.
- [ ] compile and provide documentation.
