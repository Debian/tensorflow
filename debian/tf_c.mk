# find tensorflow/c -type f -name '*.cc' | grep -v test | grep -v python | grep -v experimental

include debian/flags.mk
include debian/globs.mk

X_TF_C := $(BDIR)/tf_c.a

$(BDIR)/tf_c.a: $(TF_C_OBJS)
	ar rcs $@ $(TF_C_OBJS)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
