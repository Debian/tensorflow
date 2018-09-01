# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

CORE_LIB_SRCS_EXCL := $(wildcard tensorflow/core/lib/*/*test.cc)
CORE_LIB_SRCS := $(wildcard tensorflow/core/lib/*/*.cc)

CORE_LIB_SRCS := $(filter-out $(CORE_LIB_SRCS_EXCL), $(CORE_LIB_SRCS))

CORE_LIB_OBJS := $(addprefix $(BDIR), $(CORE_LIB_SRCS:.cc=.o))

$(BDIR)/tf_core_lib.a: $(CORE_LIB_OBJS)
	ar rcs $@ $(CORE_LIB_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
