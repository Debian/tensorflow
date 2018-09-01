# Build proto related files for TensorFlow

# tf_pb_text_files.txt
# tf_proto_files.txt

include debian/flags.mk

PBT_H := $(shell cat tf_pb_text_files.txt)
PBT_H_GEN := $(addprefix $(BDIR), $(PBT_H))
PBT_IMPL_GEN := $(addprefix $(BDIR), $(PBT_H:.pb_text.h=.pb_text-impl.h))
PBT_CC_GEN := $(addprefix $(BDIR), $(PBT_H:.h=.cc))
PBT_OBJS := $(addprefix $(BDIR), $(PBT_H:.h=.o))

all: $(PBT_OBJS)

$(BDIR)%.pb_text.o: $(BDIR)%.pb_text.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)%.pb_text.cc $(BDIR)%.pb_text.h $(BDIR)%.pb_text-impl.h: %.proto | $(PROTO_TEXT)
	@mkdir -p $(dir $@)
	$(PROTO_TEXT) $(BDIR)/tensorflow/core tensorflow/core \
		tensorflow/tools/proto_text/placeholder.txt $<

