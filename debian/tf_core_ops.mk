# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

CORE_OPS_SRCS_EXCL := $(wildcard tensorflow/core/ops/*_test.cc) \
	$(wildcard tensorflow/core/ops/*_test_utils.cc)
CORE_OPS_SRCS := $(wildcard tensorflow/core/ops/*.cc)

CORE_OPS_SRCS := $(filter-out $(CORE_OPS_SRCS_EXCL), $(CORE_OPS_SRCS))

CORE_OPS_OBJS := $(addprefix $(BDIR), $(CORE_OPS_SRCS:.cc=.o))

$(BDIR)/tf_core_ops.a: $(CORE_OPS_OBJS)
	ar rcs $@ $(CORE_OPS_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
