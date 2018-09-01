# Build core/kernels and core:ops for TensorFlow

include debian/flags.mk

TF_CORE := $(BDIR)/tf_core.a
TF_CORE_COMPONENTS := \
	$(BDIR)/tf_core_ops.a $(BDIR)/tf_core_kernels.a \
	$(BDIR)/tf_core_lib.a $(BDIR)/tf_core_platform.a \
	$(BDIR)/tf_core_framework.a $(BDIR)/tf_core_graph.a \
	$(BDIR)/tf_core_util.a $(BDIR)/tf_core_common_runtime.a \
	$(BDIR)/tf_core_grappler.a

$(TF_CORE): $(TF_CORE_COMPONENTS)
	ar rcs $@ $(TF_CORE_COMPONENTS)

# core / ops ------------------------------------------------------------------

CORE_OPS_SRCS_EXCL := $(wildcard tensorflow/core/ops/*_test.cc) \
	$(wildcard tensorflow/core/ops/*_test_utils.cc)
CORE_OPS_SRCS := $(wildcard tensorflow/core/ops/*.cc)
CORE_OPS_SRCS := $(filter-out $(CORE_OPS_SRCS_EXCL), $(CORE_OPS_SRCS))
CORE_OPS_OBJS := $(addprefix $(BDIR), $(CORE_OPS_SRCS:.cc=.o))

$(BDIR)/tf_core_ops.a: $(CORE_OPS_OBJS)
	ar rcs $@ $(CORE_OPS_OBJS)

# core / kernels --------------------------------------------------------------

CORE_KERNELS_SRCS_EXCL := $(wildcard tensorflow/core/kernels/*test*) \
	tensorflow/core/kernels/sparse_tensor_dense_matmul_op.cc \
	tensorflow/core/kernels/conv_grad_ops_3d.cc \
	tensorflow/core/kernels/adjust_contrast_op.cc \
	tensorflow/core/kernels/debug_ops.cc
CORE_KERNELS_SRCS := $(wildcard tensorflow/core/kernels/*.cc) \
	$(wildcard tensorflow/core/kernels/*main.cc)
CORE_KERNELS_SRCS := $(filter-out $(CORE_KERNELS_SRCS_EXCL), $(CORE_KERNELS_SRCS))
CORE_KERNELS_OBJS := $(addprefix $(BDIR), $(CORE_KERNELS_SRCS:.cc=.o))

$(BDIR)/tf_core_kernels.a: $(CORE_KERNELS_OBJS)
	ar rcs $@ $(CORE_KERNELS_OBJS)

# core / lib ------------------------------------------------------------------

CORE_LIB_SRCS_EXCL := $(wildcard tensorflow/core/lib/*/*test.cc)
CORE_LIB_SRCS := $(wildcard tensorflow/core/lib/*/*.cc)
CORE_LIB_SRCS := $(filter-out $(CORE_LIB_SRCS_EXCL), $(CORE_LIB_SRCS))
CORE_LIB_OBJS := $(addprefix $(BDIR), $(CORE_LIB_SRCS:.cc=.o))

$(BDIR)/tf_core_lib.a: $(CORE_LIB_OBJS)
	ar rcs $@ $(CORE_LIB_OBJS)

# core / platform -------------------------------------------------------------

CORE_PLATFORM_SRCS_EXCL := $(wildcard tensorflow/core/platform/*test.cc) \
	$(wildcard tensorflow/core/platform/default/cuda*.cc)
CORE_PLATFORM_SRCS := $(wildcard tensorflow/core/platform/*.cc) \
	$(wildcard tensorflow/core/platform/public/*.cc) \
	$(wildcard tensorflow/core/platform/posix/*.cc) \
	$(wildcard tensorflow/core/platform/default/*.cc)
CORE_PLATFORM_SRCS := $(filter-out $(CORE_PLATFORM_SRCS_EXCL), $(CORE_PLATFORM_SRCS))
CORE_PLATFORM_OBJS := $(addprefix $(BDIR), $(CORE_PLATFORM_SRCS:.cc=.o))

$(BDIR)/tf_core_platform.a: $(CORE_PLATFORM_OBJS)
	ar rcs $@ $(CORE_PLATFORM_OBJS)

# core / framework ------------------------------------------------------------

CORE_FRAME_SRCS_EXCL := $(wildcard tensorflow/core/framework/*test.cc) \
	$(wildcard tensorflow/core/framework/*testutils.cc)
CORE_FRAME_SRCS := $(wildcard tensorflow/core/framework/*.cc)
CORE_FRAME_SRCS := $(filter-out $(CORE_FRAME_SRCS_EXCL), $(CORE_FRAME_SRCS))
CORE_FRAME_OBJS := $(addprefix $(BDIR), $(CORE_FRAME_SRCS:.cc=.o))

$(BDIR)/tf_core_framework.a: $(CORE_FRAME_OBJS)
	ar rcs $@ $(CORE_FRAMEWORK_OBJS)

# core / graph ----------------------------------------------------------------

CORE_GRAPH_SRCS_EXCL := $(wildcard tensorflow/core/graph/*test.cc)
CORE_GRAPH_SRCS := $(wildcard tensorflow/core/graph/*.cc)
CORE_GRAPH_SRCS := $(filter-out $(CORE_GRAPH_SRCS_EXCL), $(CORE_GRAPH_SRCS))
CORE_GRAPH_OBJS := $(addprefix $(BDIR), $(CORE_GRAPH_SRCS:.cc=.o))

$(BDIR)/tf_core_graph.a: $(CORE_GRAPH_OBJS)
	ar rcs $@ $(CORE_GRAPH_OBJS)

# core / util -----------------------------------------------------------------

CORE_UTIL_SRCS_EXCL := $(wildcard tensorflow/core/util/*test.cc)
CORE_UTIL_SRCS := $(wildcard tensorflow/core/util/*.cc)
CORE_UTIL_SRCS := $(filter-out $(CORE_UTIL_SRCS_EXCL), $(CORE_UTIL_SRCS))
CORE_UTIL_OBJS := $(addprefix $(BDIR), $(CORE_UTIL_SRCS:.cc=.o))

$(BDIR)/tf_core_util.a: $(CORE_UTIL_OBJS)
	ar rcs $@ $(CORE_UTIL_OBJS)

# core / common_runtime -------------------------------------------------------

CORE_CR_SRCS_EXCL := $(wildcard tensorflow/core/common_runtime/*test.cc)
CORE_CR_SRCS := $(wildcard tensorflow/core/common_runtime/*.cc)
CORE_CR_SRCS := $(filter-out $(CORE_CR_SRCS_EXCL), $(CORE_CR_SRCS))
CORE_CR_OBJS := $(addprefix $(BDIR), $(CORE_CR_SRCS:.cc=.o))

$(BDIR)/tf_core_common_runtime.a: $(CORE_CR_OBJS)
	ar rcs $@ $(CORE_CR_OBJS)

# core / grappler -------------------------------------------------------------

CORE_GR_SRCS_EXCL := $(wildcard tensorflow/core/grappler/*test.cc) \
	$(wildcard tensorflow/core/grappler/*/*test.cc) \
	tensorflow/core/grappler/inputs/file_input_yielder.cc \
	tensorflow/core/grappler/inputs/trivial_test_graph_input_yielder.cc
CORE_GR_SRCS := $(wildcard tensorflow/core/grappler/*.cc) \
	$(wildcard tensorflow/core/grappler/*/*.cc)
CORE_GR_SRCS := $(filter-out $(CORE_GR_SRCS_EXCL), $(CORE_GR_SRCS))
CORE_GR_OBJS := $(addprefix $(BDIR), $(CORE_GR_SRCS:.cc=.o))

$(BDIR)/tf_core_grappler.a: $(CORE_GR_OBJS)
	ar rcs $@ $(CORE_GR_OBJS)

# generic rule for objects ----------------------------------------------------

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
