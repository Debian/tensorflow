# Common Flags for TensorFlow Makefile

BDIR := $(shell pwd)/build/
$(shell mkdir -p $(BDIR))
PROTO_TEXT := $(BDIR)/proto_text
PROTOC := protoc
INCLUDES := -I. -I$(BDIR) -Idebian/embedded/eigenn -I/usr/include/gemmlowp \
	-Ithird_party/eigen3
CXXFLAGS := -pthread -DPLATFORM_POSIX -std=c++14 -fPIC
LIBS := -lpthread -lprotobuf
LDFLAGS := -Wl,--as-needed
