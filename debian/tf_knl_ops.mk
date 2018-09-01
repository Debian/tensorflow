# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

KERNELS_CC_SRCS := $(wildcard tensorflow/core/kernels/*.cc)
OPS_CC_SRCS := $(wildcard tensorflow/core/ops/*.cc)

TF_KNL_OPS_OBJS := $(addprefix $(BDIR), $(KERNELS_CC_SRCS:.cc=.o)) \
	$(addprefix $(BDIR), $(OPS_CC_SRCS:.cc=.o))

$(BDIR)/tf_knl_ops.a: $(TF_KNL_OPS_OBJS)
	ar rcs $@ $(TF_KNL_OPS_OBJS)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)
