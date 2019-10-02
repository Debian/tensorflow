# Description:
#   TensorFlow Base libraries.
#   This package contains the following libraries:
#     - Platform dependent libraries that require different implementations
#       across different OSs or environments.
#     - STL replacement libraries rest of TensorFlow should depend on.
#
#   The libraries in this package are not allowed to have ANY dependencies
#   to any TensorFlow code outside this package.

srcs = ["abi.cc",
	"env_time.cc",
	"default/logging.cc",
	"cpu_info.cc"]
srcs = [os.path.join(d, x) for x in srcs]
objs = [x.replace('.cc', '.o') for x in srcs]
for x in srcs:
	f.build(x.replace('.cc', '.o'), 'CXX', x)
f.build('tensorflow/core/platform.phony', 'phony', objs)
