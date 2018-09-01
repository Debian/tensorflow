# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

CORE_KERNELS_SRCS_EXCL := $(wildcard tensorflow/core/kernels/*test*) \
	tensorflow/core/kernels/sparse_tensor_dense_matmul_op.cc \
	tensorflow/core/kernels/conv_grad_ops_3d.cc \
	tensorflow/core/kernels/adjust_contrast_op.cc \
	tensorflow/core/kernels/debug_ops.cc
CORE_KERNELS_SRCS := $(wildcard tensorflow/core/kernels/*.cc) \
	$(wildcard tensorflow/core/kernels/*main.cc)

CORE_KERNELS_SRCS := $(filter-out $(CORE_KERNELS_SRCS_EXCL), $(CORE_KERNELS_SRCS))

CORE_KERNELS_OBJS := $(addprefix $(BDIR), $(CORE_KERNELS_SRCS:.cc=.o))

$(BDIR)/tf_core_kernels.a: $(CORE_KERNELS_OBJS)
	ar rcs $@ $(CORE_KERNELS_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
