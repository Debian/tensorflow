# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

TF_CORE := $(BDIR)/tf_core.a
$(TF_CORE): $(BDIR)/tf_core_ops.a $(BDIR)/tf_core_kernels.a \
		$(BDIR)/tf_core_lib.a $(BDIR)/tf_core_platform.a
	ar rcs $@ $<

# core / ops ------------------------------------------------------------------

CORE_OPS_SRCS_EXCL := $(wildcard tensorflow/core/ops/*_test.cc) \
	$(wildcard tensorflow/core/ops/*_test_utils.cc)
CORE_OPS_SRCS := $(wildcard tensorflow/core/ops/*.cc)
CORE_OPS_SRCS := $(filter-out $(CORE_OPS_SRCS_EXCL), $(CORE_OPS_SRCS))
CORE_OPS_OBJS := $(addprefix $(BDIR), $(CORE_OPS_SRCS:.cc=.o))

$(BDIR)/tf_core_ops.a: $(CORE_OPS_OBJS)
	ar rcs $@ $(CORE_OPS_OBJS)

# core / kernels --------------------------------------------------------------

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

# core / lib ------------------------------------------------------------------

CORE_LIB_SRCS_EXCL := $(wildcard tensorflow/core/lib/*/*test.cc)
CORE_LIB_SRCS := $(wildcard tensorflow/core/lib/*/*.cc)
CORE_LIB_SRCS := $(filter-out $(CORE_LIB_SRCS_EXCL), $(CORE_LIB_SRCS))
CORE_LIB_OBJS := $(addprefix $(BDIR), $(CORE_LIB_SRCS:.cc=.o))

$(BDIR)/tf_core_lib.a: $(CORE_LIB_OBJS)
	ar rcs $@ $(CORE_LIB_OBJS)

# core / platform

CORE_PLATFORM_SRCS_EXCL := $(wildcard tensorflow/core/platform/*test.cc) \
	$(wildcard tensorflow/core/platform/default/cuda*.cc)
CORE_PLATFORM_SRCS := $(wildcard tensorflow/core/platform/*.cc) \
	$(wildcard tensorflow/core/platform/public/*.cc) \
	$(wildcard tensorflow/core/platform/posix/*.cc) \
	$(wildcard tensorflow/core/platform/default/*.cc)
CORE_PLATFORM_SRCS := $(filter-out $(CORE_PLATFORM_SRCS_EXCL), $(CORE_PLATFORM_SRCS))
CORE_PLATFORM_OBJS := $(addprefix $(BDIR), $(CORE_PLATFORM_SRCS:.cc=.o))

$(BDIR)/tf_core_platform.a: $(CORE_PLATFORM_OBJS)
	ar rcs $@ $(CORE_PLATFORM_OBJS)

# generic rule for objects ----------------------------------------------------

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
