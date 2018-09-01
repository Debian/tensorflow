# Build proto related files for TensorFlow

# tf_pb_text_files.txt
# tf_proto_files.txt

include debian/flags.mk

TF_PROTO := $(shell cat tf_proto_files.txt)
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
