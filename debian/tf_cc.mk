# Makefile for tensorflow/cc

include debian/flags.mk
include debian/globs.mk

X_TF_CC: $(BDIR)/tf_cc.a

$(BDIR)/tf_cc.a: $(TF_CC_OBJS)
	ar rcs $@ $(TF_CC_OBJS)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
