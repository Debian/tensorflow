# Build tf/core for TensorFlow

include debian/flags.mk
include debian/globs.mk

TF_CORE := $(BDIR)/tf_core.a
X_TF_CORE: $(TF_CORE)

$(TF_CORE): $(CORE_OBJS)
	ar rcs $@ $(CORE_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
