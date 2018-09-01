# TensorFlow Makefile for building proto_text

# proto_text_cc_files.txt
# proto_text_pb_cc_files.txt
# proto_text_pb_h_files.txt

BDIR := $(shell pwd)/build/
$(shell mkdir -p $(BDIR))
PROTO_TEXT := $(BDIR)/proto_text
PROTOC := protoc
INCLUDES := -I.
CXXFLAGS := -pthread -DPLATFORM_POSIX -std=c++14 -fPIC
LIBS := -lpthread -lprotobuf
LDFLAGS := -Wl,--as-needed

.PHONY: all
all: $(PROTO_TEXT)

$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)%.pb.o: $(BDIR)%.pb.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES)

$(BDIR)%.pb.cc $(BDIR)%.pb.h: %.proto
	echo $<
	@mkdir -p $(dir $@)
	$(PROTOC) $< --cpp_out $(BDIR)

PROTO_TEXT_CC_SRCS := $(shell cat proto_text_cc_files.txt)
PROTO_TEXT_CC_OBJS := $(addprefix $(BDIR), $(PROTO_TEXT_CC_SRCS:.cc=.o))

PROTO_TEXT_PB_CC_SRCS := $(shell cat proto_text_pb_cc_files.txt)
PROTO_TEXT_PB_CC_OBJS := $(addprefix $(BDIR), $(PROTO_TEXT_PB_CC_SRCS:.cc=.o))

PROTO_TEXT_PB_H_SRCS := $(shell cat proto_text_pb_h_files.txt)
PROTO_TEXT_PB_H_GEN  := $(addprefix $(BDIR), $(PROTO_TEXT_PB_H_SRCS))

PROTO_TEXT_OBJS := $(PROTO_TEXT_PB_CC_OBJS) $(PROTO_TEXT_CC_OBJS)

$(PROTO_TEXT_OBJS): $(PROTO_TEXT_PB_H_GEN)

$(PROTO_TEXT):  $(PROTO_TEXT_PB_H_GEN) $(PROTO_TEXT_OBJS)
	@mkdir -p $(dir $@)
	$(CXX) -o $(PROTO_TEXT) $(PROTO_TEXT_OBJS) \
		$(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(INCLUDES) $(LIBS)

.PHONY: clean
clean:
	-$(RM) -rf $(BDIR)
