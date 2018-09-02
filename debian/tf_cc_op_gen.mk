include debian/flags.mk

OP_NAMES := $(shell find tensorflow/core/ops/ -type f -name '*ops.cc')
OP_NAMES := $(patsubst tensorflow/core/ops/%.cc,%, $(OP_NAMES)) no_op

X_TF_CC_OP_GEN: $(addsuffix _gen, $(addprefix $(BDIR), $(OP_NAMES)))

TF_CC_OP_GEN_SRCS := \
	tensorflow/cc/framework/cc_op_gen.cc \
	tensorflow/cc/framework/cc_op_gen_main.cc
TF_CC_OP_GEN_OBJS := $(addprefix $(BDIR), $(TF_CC_OP_GEN_SRCS:.cc=.o))

$(BDIR)%_gen: $(TF_CC_OP_GEN_OBJS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LIBS) \
		build/tensorflow/core/ops/$(patsubst %_gen,%,$(shell basename $@)).o $(TF_CC_OP_GEN_OBJS) $(TF_CORE) \
		$(BDIR)/tf_proto.a $(BDIR)/tf_proto_text.a \
		tensorflow/core/lib/strings/proto_text_util.cc \
		-o $@
	@mkdir -p $(BDIR)/tensorflow/cc/ops/
	$@ build/tensorflow/cc/ops/$(patsubst %_gen,%,$(shell basename $@)).h \
	build/tensorflow/cc/ops/$(patsubst %_gen,%,$(shell basename $@)).cc \
	0 tensorflow/core/api_def/base_api

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w

