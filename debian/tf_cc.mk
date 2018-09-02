# Makefile for tensorflow/cc

include debian/flags.mk

X_TF_CC: $(BDIR)/tf_cc.a

TF_CC_SRCS_EX := \
	$(wildcard tensorflow/cc/framework/cc_op_gen*) \
	$(wildcard tensorflow/cc/*/*test.cc)

TF_CC_SRCS := \
	$(wildcard tensorflow/cc/*/*.cc)

TF_CC_SRCS := $(filter-out $(TF_CC_SRCS_EX), $(TF_CC_SRCS))
TF_CC_OBJS := $(addprefix $(BDIR), $(TF_CC_SRCS:.cc=.o))

$(BDIR)/tf_cc.a: $(TF_CC_OBJS)
	ar rcs $@ $(TF_CC_OBJS)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
