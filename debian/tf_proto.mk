# Build proto related files for TensorFlow

# tf_pb_text_files.txt
# tf_proto_files.txt

include debian/flags.mk

X_TF_PROTO: $(BDIR)/tf_proto.a $(BDIR)/tf_proto_text.a

# -----------------------------------------------------------------------------

TF_PROTO := $(shell find tensorflow/core -type f -name '*.proto')
TF_PROTO_H_GEN := $(addprefix $(BDIR), $(TF_PROTO:.proto=.pb.h))
TF_PROTO_CC_GEN := $(addprefix $(BDIR), $(TF_PROTO:.proto=.pb.cc))
TF_PROTO_OBJS := $(addprefix $(BDIR), $(TF_PROTO:.proto=.pb.o))

$(BDIR)/tf_proto.a: $(TF_PROTO_OBJS)
	ar rcs $@ $(TF_PROTO_OBJS)

$(BDIR)%.pb.o: $(BDIR)%.pb.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)%.pb.cc $(BDIR)%.pb.h: %.proto
	@mkdir -p $(dir $@)
	$(PROTOC) $< --cpp_out $(BDIR)

# -----------------------------------------------------------------------------

PBT_H := $(shell find tensorflow/core -type f -name '*.proto')
PBT_H := $(PBT_H:.proto=.pb.h)
PBT_H_GEN := $(addprefix $(BDIR), $(PBT_H))
PBT_IMPL_GEN := $(addprefix $(BDIR), $(PBT_H:.pb_text.h=.pb_text-impl.h))
PBT_CC_GEN := $(addprefix $(BDIR), $(PBT_H:.h=.cc))
PBT_OBJS := $(addprefix $(BDIR), $(PBT_H:.h=.o))

$(BDIR)/tf_proto_text.a: $(PBT_OBJS)
	ar rcs $@ $(PBT_OBJS)

$(BDIR)%.pb_text.o: $(BDIR)%.pb_text.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)%.pb_text.cc $(BDIR)%.pb_text.h $(BDIR)%.pb_text-impl.h: %.proto | $(PROTO_TEXT)
	@mkdir -p $(dir $@)
	$(PROTO_TEXT) $(BDIR)/tensorflow/core tensorflow/core \
		tensorflow/tools/proto_text/placeholder.txt $<
