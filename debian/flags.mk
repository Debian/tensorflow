# Common Flags for TensorFlow Makefile

BDIR := $(shell pwd)/build/
$(shell mkdir -p $(BDIR))
PROTO_TEXT := $(BDIR)/proto_text
PROTOC := protoc
INCLUDES := -I/usr/include -I. -I$(BDIR) -Idebian/embedded/eigen -I/usr/include/gemmlowp \
	-Ithird_party/eigen3 -I/usr/include/google -I/usr/include/jsoncpp
CXXFLAGS := -pthread -DPLATFORM_POSIX -std=c++14 -fPIC -gsplit-dwarf
LIBS := -lpthread -lprotobuf -lnsync -lnsync_cpp -ldouble-conversion -ldl -lm -lz
LDFLAGS := -Wl,--as-needed

TF_CORE := $(BDIR)/tf_core.a
TF_CORE_LIB := $(BDIR)/tf_core_lib.a
TF_CORE_FRAMEWORK := $(BDIR)/tf_core_framework.a
