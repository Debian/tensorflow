# This Makefile compiles a library containing the C++ runtime for the TensorFlow
# library. It's designed for use on platforms with limited resources where
# running a full Bazel build would be prohibitive.
#
# It includes only a bare-bones set of functionality.
#
# The default setup below is aimed at Unix-like devices, and should work on
# modern Linux and OS X distributions without changes.

VERSION   := 1.10.0
SOVERSION := 1.10
SOFILE    := libtensorflow.so

# Find where we're running from, so we can store generated files here.
ifeq ($(origin MAKEFILE_DIR), undefined)
	MAKEFILE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
endif

# Where compiled objects are stored.
HOST_OBJDIR := $(MAKEFILE_DIR)/gen/host_obj/
HOST_BINDIR := $(MAKEFILE_DIR)/gen/host_bin/
HOST_GENDIR := $(MAKEFILE_DIR)/gen/host_obj/

# proto_text is a tool that converts protobufs into a form we can use more
# compactly within TensorFlow. It's a bit like protoc, but is designed to
# produce a much more minimal result so we can save binary space.
# We have to build it on the host system first so that we can create files
# that are needed for the runtime building.
PROTO_TEXT := $(HOST_BINDIR)proto_text
# The list of dependencies is derived from the Bazel build file by running
# the gen_file_lists.sh script on a system with a working Bazel setup.
PROTO_TEXT_CC_FILES := $(shell cat $(MAKEFILE_DIR)/proto_text_cc_files.txt)
PROTO_TEXT_PB_CC_LIST := \
	$(shell cat $(MAKEFILE_DIR)/proto_text_pb_cc_files.txt) \
	$(wildcard tensorflow/contrib/makefile/downloads/double_conversion/double-conversion/*.cc)
PROTO_TEXT_PB_H_LIST := $(shell cat $(MAKEFILE_DIR)/proto_text_pb_h_files.txt)

# Locations of the intermediate files proto_text generates.
PROTO_TEXT_PB_H_FILES := $(addprefix $(HOST_GENDIR), $(PROTO_TEXT_PB_H_LIST))
PROTO_TEXT_CC_OBJS := $(addprefix $(HOST_OBJDIR), $(PROTO_TEXT_CC_FILES:.cc=.o))
PROTO_TEXT_PB_OBJS := $(addprefix $(HOST_OBJDIR), $(PROTO_TEXT_PB_CC_LIST:.cc=.o))
PROTO_TEXT_OBJS := $(PROTO_TEXT_CC_OBJS) $(PROTO_TEXT_PB_OBJS)

# Target device settings.

# Default to running on the same system we're compiling on.
# You should override TARGET on the command line if you're cross-compiling, e.g.
# make -f tensorflow/contrib/makefile/Makefile TARGET=ANDROID
TARGET := LINUX

# Where compiled objects are stored.
GENDIR := $(MAKEFILE_DIR)/gen/
OBJDIR := $(GENDIR)obj/
LIBDIR := $(GENDIR)lib/
BINDIR := $(GENDIR)bin/
PBTGENDIR := $(GENDIR)proto_text/
PROTOGENDIR := $(GENDIR)proto/
DEPDIR := $(GENDIR)dep/
$(shell mkdir -p $(DEPDIR) >/dev/null)

# Settings for the target compiler.
CXX := $(CC_PREFIX) gcc

CXXFLAGS += --std=c++14 -DIS_SLIM_BUILD -fno-exceptions -O2 -DNDEBUG -fPIC
CPPFLAGS +=
LDFLAGS +=
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

LIBS := -lstdc++ -lprotobuf -lpthread -lm -lz -ldl -lpthread \
	-lnsync -lnsync_cpp -ldouble-conversion

PROTOC := protoc

$(info PROTOC = "$(PROTOC)")
$(info CC_PREFIX = "$(CC_PREFIX)")

PROTOCFLAGS :=
AR := ar
ARFLAGS := -r
LIBFLAGS :=

LIBFLAGS += -Wl,--allow-multiple-definition -Wl,--whole-archive
LDFLAGS := -Wl,--no-whole-archive


# This library is the main target for this makefile. It will contain a minimal
# runtime that can be linked in to other programs.
LIB_NAME := libtensorflow-core.a
LIB_PATH := $(LIBDIR)$(LIB_NAME)

# A small example program that shows how to link against the library.
BENCHMARK_NAME := $(BINDIR)benchmark

# What sources we want to compile, derived from the main Bazel build using the
# gen_file_lists.sh script.

CORE_CC_ALL_SRCS := \
$(wildcard tensorflow/core/*.cc) \
$(wildcard tensorflow/core/common_runtime/*.cc) \
$(wildcard tensorflow/core/framework/*.cc) \
$(wildcard tensorflow/core/graph/*.cc) \
$(wildcard tensorflow/core/grappler/*.cc) \
$(wildcard tensorflow/core/grappler/*/*.cc) \
$(wildcard tensorflow/core/lib/*/*.cc) \
$(wildcard tensorflow/core/platform/*.cc) \
$(wildcard tensorflow/core/platform/*/*.cc) \
$(wildcard tensorflow/core/platform/*/*/*.cc) \
$(wildcard tensorflow/core/util/*.cc) \
$(wildcard tensorflow/core/util/*/*.cc) \
$(wildcard tensorflow/contrib/makefile/downloads/double_conversion/double-conversion/*.cc) \
tensorflow/core/util/version_info.cc
# Remove duplicates (for version_info.cc)
CORE_CC_ALL_SRCS := $(sort $(CORE_CC_ALL_SRCS))

CORE_CC_EXCLUDE_SRCS_NON_GPU := \
$(wildcard tensorflow/core/*/*test.cc) \
$(wildcard tensorflow/core/*/*testutil*) \
$(wildcard tensorflow/core/*/*testlib*) \
$(wildcard tensorflow/core/*/*main.cc) \
$(wildcard tensorflow/core/*/*/*test.cc) \
$(wildcard tensorflow/core/*/*/*testutil*) \
$(wildcard tensorflow/core/*/*/*testlib*) \
$(wildcard tensorflow/core/*/*/*main.cc) \
$(wildcard tensorflow/core/debug/*.cc) \
$(wildcard tensorflow/core/framework/op_gen_lib.cc) \
$(wildcard tensorflow/core/graph/dot.*) \
$(wildcard tensorflow/core/lib/db/*) \
$(wildcard tensorflow/core/lib/gif/*) \
$(wildcard tensorflow/core/lib/io/zlib*) \
$(wildcard tensorflow/core/lib/io/record*) \
$(wildcard tensorflow/core/lib/jpeg/*) \
$(wildcard tensorflow/core/lib/png/*) \
$(wildcard tensorflow/core/util/events_writer.*) \
$(wildcard tensorflow/core/util/reporter.*) \
$(wildcard tensorflow/core/platform/default/test_benchmark.*) \
$(wildcard tensorflow/core/platform/cloud/*) \
$(wildcard tensorflow/core/platform/google/*) \
$(wildcard tensorflow/core/platform/google/*/*) \
$(wildcard tensorflow/core/platform/jpeg.*) \
$(wildcard tensorflow/core/platform/png.*) \
$(wildcard tensorflow/core/platform/s3/*) \
$(wildcard tensorflow/core/platform/windows/*) \
$(wildcard tensorflow/core/grappler/inputs/trivial_test_graph_input_yielder.*) \
$(wildcard tensorflow/core/grappler/inputs/file_input_yielder.*) \
$(wildcard tensorflow/core/grappler/clusters/single_machine.*) \
tensorflow/core/util/cuda_kernel_helper_test.cu.cc

CORE_CC_EXCLUDE_SRCS := \
$(CORE_CC_EXCLUDE_SRCS_NON_GPU) \
$(wildcard tensorflow/core/platform/stream_executor.*) \
$(wildcard tensorflow/core/platform/default/cuda_libdevice_path.*) \
$(wildcard tensorflow/core/platform/cuda.h) \
$(wildcard tensorflow/core/platform/cuda_libdevice_path.*) \
$(wildcard tensorflow/core/user_ops/*.cu.cc) \
$(wildcard tensorflow/core/common_runtime/gpu/*) \
$(wildcard tensorflow/core/common_runtime/gpu_device_factory.*)

ifeq ($(BUILD_FOR_TEGRA),1)
CORE_CC_ALL_SRCS := $(CORE_CC_ALL_SRCS) \
tensorflow/core/kernels/concat_lib_gpu.cc \
tensorflow/core/kernels/cuda_solvers.cc \
tensorflow/core/kernels/cudnn_pooling_gpu.cc \
tensorflow/core/kernels/dense_update_functor.cc \
tensorflow/core/kernels/fractional_avg_pool_op.cc \
tensorflow/core/kernels/fractional_max_pool_op.cc \
tensorflow/core/kernels/fractional_pool_common.cc \
tensorflow/core/kernels/pooling_ops_3d.cc \
tensorflow/core/kernels/sparse_fill_empty_rows_op.cc \
tensorflow/core/kernels/list_kernels.cc \
$(wildcard tensorflow/core/common_runtime/gpu/*.cc) \
$(wildcard tensorflow/stream_executor/*.cc) \
$(wildcard tensorflow/stream_executor/*/*.cc)

CORE_CC_EXCLUDE_SRCS := \
$(CORE_CC_EXCLUDE_SRCS_NON_GPU)

CUDA_CC_SRCS := $(wildcard tensorflow/core/kernels/*.cu.cc)
CUDA_CC_OBJS := $(addprefix $(OBJDIR), $(CUDA_CC_SRCS:.cc=.o))
endif  # TEGRA

# Filter out all the excluded files.
TF_CC_SRCS := $(filter-out $(CORE_CC_EXCLUDE_SRCS), $(CORE_CC_ALL_SRCS))
# Add in any extra files that don't fit the patterns easily
TF_CC_SRCS += debian/embedded/fft/fftsg.c
TF_CC_SRCS += tensorflow/core/common_runtime/gpu/gpu_id_manager.cc
# Also include the op and kernel definitions.
TF_CC_SRCS += $(shell cat $(MAKEFILE_DIR)/tf_op_files.txt)
PBT_CC_SRCS := $(shell cat $(MAKEFILE_DIR)/tf_pb_text_files.txt)
PROTO_SRCS := $(shell cat $(MAKEFILE_DIR)/tf_proto_files.txt)
BENCHMARK_SRCS := \
tensorflow/core/util/reporter.cc \
tensorflow/tools/benchmark/benchmark_model.cc \
tensorflow/tools/benchmark/benchmark_model_main.cc

# File names of the intermediate files target compilation generates.
TF_CC_OBJS := $(addprefix $(OBJDIR), \
$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(TF_CC_SRCS))))
PBT_GEN_FILES := $(addprefix $(PBTGENDIR), $(PBT_CC_SRCS))
PBT_OBJS := $(addprefix $(OBJDIR), $(PBT_CC_SRCS:.cc=.o))
PROTO_CC_SRCS := $(addprefix $(PROTOGENDIR), $(PROTO_SRCS:.proto=.pb.cc))
PROTO_OBJS := $(addprefix $(OBJDIR), $(PROTO_SRCS:.proto=.pb.o))
LIB_OBJS := $(PROTO_OBJS) $(TF_CC_OBJS) $(PBT_OBJS)
BENCHMARK_OBJS := $(addprefix $(OBJDIR), $(BENCHMARK_SRCS:.cc=.o))

.PHONY: clean cleantarget

# The target that's compiled if there's no command-line arguments.
all: $(LIB_PATH) $(BENCHMARK_NAME) $(SOFILE)

DESTDIR ?= $(MAKEFILE_DIR)/../tmp
INST_INC ?= $(DESTDIR)/usr/include/tensorflow/
INST_LIB ?= $(DESTDIR)/usr/lib/$(shell dpkg-architecture -qDEB_HOST_MULTIARCH)/
INST_BIN ?= $(DESTDIR)/usr/bin/

INCLUDES :=  -I. -I$(MAKEFILE_DIR)/../embedded/eigen  -I$(HOST_GENDIR) \
	-I$(PROTOGENDIR) -I$(PBTGENDIR) -I/usr/include/gemmlowp/

install: all
	mkdir -p $(INST_INC)
	# FIXME: what header to install?
	mkdir -p $(INST_LIB)
	install -m0644 $(SOFILE)* $(INST_LIB)
	mkdir -p $(INST_BIN)
	install -m0755 $(BENCHMARK_NAME) $(INST_BIN)

# Rules for target compilation.

.phony_version_info:
tensorflow/core/util/version_info.cc: .phony_version_info
	tensorflow/tools/git/gen_git_source.sh $@

# Gathers together all the objects we've compiled into a single '.a' archive.
$(LIB_PATH): $(LIB_OBJS)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $(LIB_PATH) $(LIB_OBJS)

$(SOFILE): $(LIB_OBJS)
	$(CXX) -fPIC -shared $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(LIB_OBJS) \
		-Wl,-soname=$(SOFILE).$(SOVERSION) \
		-o $(SOFILE).$(VERSION)
	-ln -s $(SOFILE).$(VERSION) $(SOFILE).$(SOVERSION)
	-ln -s $(SOFILE).$(VERSION) $(SOFILE)

$(BENCHMARK_NAME): $(BENCHMARK_OBJS) $(LIB_PATH) $(CUDA_LIB_DEPS)
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) \
	-o $(BENCHMARK_NAME) $(BENCHMARK_OBJS) \
	$(LIBFLAGS) $(TEGRA_LIBS) $(LIB_PATH) $(LDFLAGS) $(LIBS) $(CUDA_LIBS)

# NVCC compilation rules for Tegra
ifeq ($(BUILD_FOR_TEGRA),1)
$(OBJDIR)%.cu.o: %.cu.cc
	@mkdir -p $(dir $@)
	@mkdir -p $(dir $(DEPDIR)$*)
	$(NVCC) $(NVCCFLAGS) -Xcompiler "$(CXXFLAGS4NVCC) $(DEPFLAGS)" $(INCLUDES) -c $< -o $@

$(LIBDIR)libtfcuda.a: $(CUDA_CC_OBJS)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $@ $(CUDA_CC_OBJS)
endif

# Matches on the normal hand-written TensorFlow C++ source files.
$(OBJDIR)%.o: %.cc | $(PBT_GEN_FILES)
	@mkdir -p $(dir $@)
	@mkdir -p $(dir $(DEPDIR)$*)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(DEPFLAGS) $(INCLUDES) -c $< -o $@
	@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

# Matches on plain C files.
$(OBJDIR)%.o: %.c
	@mkdir -p $(dir $@)
	@mkdir -p $(dir $(DEPDIR)$*)
	$(CXX) $(CPPFLAGS) $(patsubst --std=c++11,--std=c99, $(CXXFLAGS)) -x c $(DEPFLAGS) \
$(INCLUDES) -c $< -o $@
	@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

# Compiles C++ source files that have been generated by protoc.
$(OBJDIR)%.pb.o: $(PROTOGENDIR)%.pb.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Builds C++ code from proto files using protoc.
$(PROTOGENDIR)%.pb.cc $(PROTOGENDIR)%.pb.h: %.proto
	@mkdir -p $(dir $@)
	$(PROTOC) $(PROTOCFLAGS) $< --cpp_out $(PROTOGENDIR)

# Uses proto_text to generate minimal pb_text C++ files from protos.
$(PBTGENDIR)%.pb_text.cc $(PBTGENDIR)%.pb_text.h $(PBTGENDIR)%.pb_text-impl.h: %.proto | $(PROTO_TEXT)
	@mkdir -p $(dir $@)
	$(PROTO_TEXT) \
	$(PBTGENDIR)tensorflow/core \
	tensorflow/core/ \
	tensorflow/tools/proto_text/placeholder.txt \
	$<

# Compiles the C++ source files created by proto_text.
$(OBJDIR)%.pb_text.o: $(PBTGENDIR)%.pb_text.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Makes sure that we don't compile the protoc-generated C++ sources before they
# and the proto_text files have been created.
$(PROTO_OBJS): $(PROTO_CC_SRCS) $(PBT_GEN_FILES)

# Host compilation rules.

# For normal manually-created TensorFlow C++ source files.
$(HOST_OBJDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Compiles object code from protoc-built C++ source files.
$(HOST_OBJDIR)%.pb.o: $(HOST_GENDIR)%.pb.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Ensures we wait until proto_text has generated the .h files from protos before
# we compile the C++.
$(PROTO_TEXT_OBJS) : $(PROTO_TEXT_PB_H_FILES)

# Runs proto_text to generate C++ source files from protos.
$(PROTO_TEXT): $(PROTO_TEXT_OBJS) $(PROTO_TEXT_PB_H_FILES)
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) \
	-o $(PROTO_TEXT) $(PROTO_TEXT_OBJS) $(HOST_LDOPTS) $(LIBS)

# Compiles the C++ source files from protos using protoc.
$(HOST_GENDIR)%.pb.cc $(HOST_GENDIR)%.pb.h: %.proto
	@mkdir -p $(dir $@)
	$(PROTOC) $(PROTOCFLAGS) $< --cpp_out $(HOST_GENDIR)

# Gets rid of all generated files.
clean:
	rm -rf $(MAKEFILE_DIR)/gen
	rm -rf tensorflow/core/util/version_info.cc

# Gets rid of all generated files except protobuf libs generated
# before calling make.  This allows users not to recompile proto libs everytime.
clean_except_protobuf_libs:
	find $(MAKEFILE_DIR)/gen -mindepth 1 -maxdepth 1 ! -name "protobuf*" -exec rm -r "{}" \;
	rm -rf tensorflow/core/util/version_info.cc

# Gets rid of target files only, leaving the host alone. Also leaves the lib
# directory untouched deliberately, so we can persist multiple architectures
# across builds for iOS and Android.
cleantarget:
	rm -rf $(OBJDIR)
	rm -rf $(BINDIR)
	rm -rf $(LIBDIR)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(TF_CC_SRCS)))
