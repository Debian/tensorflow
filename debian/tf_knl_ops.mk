# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

KERNELS_CC_SRCS_EXCL := $(wildcard tensorflow/core/kernels/*_test.cc) \
	$(wildcard tensorflow/core/kernels/*_test_utils.cc)
OPS_CC_SRCS_EXCL := $(wildcard tensorflow/core/ops/*_test.cc) \
	$(wildcard tensorflow/core/ops/*_test_utils.cc)
KERNELS_CC_SRCS := $(wildcard tensorflow/core/kernels/*.cc)
OPS_CC_SRCS := $(wildcard tensorflow/core/ops/*.cc)

KERNELS_CC_SRCS := $(filter-out $(KERNELS_CC_SRCS_EXCL), $(KERNELS_CC_SRCS))
OPS_CC_SRCS := $(filter-out $(OPS_CC_SRCS_EXCL), $(OPS_CC_SRCS))

TF_KNL_OPS_OBJS := $(addprefix $(BDIR), $(KERNELS_CC_SRCS:.cc=.o)) \
	$(addprefix $(BDIR), $(OPS_CC_SRCS:.cc=.o))

$(BDIR)/tf_knl_ops.a: $(TF_KNL_OPS_OBJS)
	ar rcs $@ $(TF_KNL_OPS_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
