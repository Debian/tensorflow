# Common Flags for TensorFlow Makefile

BDIR := $(shell pwd)/build/
$(shell mkdir -p $(BDIR))
PROTO_TEXT := $(BDIR)/proto_text
PROTOC := protoc
INCLUDES := -I/usr/include -I. -I$(BDIR) -Idebian/embedded/eigen -I/usr/include/gemmlowp \
	-Ithird_party/eigen3 -I/usr/include/google
CXXFLAGS := -pthread -DPLATFORM_POSIX -std=c++14 -fPIC
LIBS := -lpthread -lprotobuf -lnsync -lnsync_cpp -ldouble-conversion -ldl
LDFLAGS := -Wl,--as-needed
