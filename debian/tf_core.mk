# Build tf/core for TensorFlow

include debian/flags.mk

TF_CORE := $(BDIR)/tf_core.a
X_TF_CORE: $(TF_CORE)

# Check the list with $ find tensorflow/core -type d | sort
CORE_SRCS := \
	$(wildcard tensorflow/core/*.cc) \
	$(wildcard tensorflow/core/common_runtime/*.cc) \
	$(wildcard tensorflow/core/common_runtime/*/*.cc) \
	$(wildcard tensorflow/core/framework/*.cc) \
	$(wildcard tensorflow/core/graph/*.cc) \
	$(wildcard tensorflow/core/grappler/*.cc) \
	$(wildcard tensorflow/core/grappler/*/*.cc) \
	$(wildcard tensorflow/core/kernels/*.cc) \
	$(wildcard tensorflow/core/kernels/*/*.cc) \
	$(wildcard tensorflow/core/kernels/*/*/*.cc) \
	$(wildcard tensorflow/core/lib/*/*.cc) \
	$(wildcard tensorflow/core/ops/*.cc) \
	$(wildcard tensorflow/core/platform/*.cc) \
	$(wildcard tensorflow/core/platform/*/*.cc) \
	$(wildcard tensorflow/core/util/*.cc) \
	$(wildcard tensorflow/core/util/*/*.cc)

CORE_SRCS_EX := \
	$(wildcard tensorflow/core/*.cu.cc) \
	$(wildcard tensorflow/core/*/*.cu.cc) \
	$(wildcard tensorflow/core/*/*/*.cu.cc) \
	$(wildcard tensorflow/core/*/*/*/*.cu.cc) \
	$(wildcard tensorflow/core/*_main.cc) \
	$(wildcard tensorflow/core/*/*_main.cc) \
	$(wildcard tensorflow/core/*/*/*_main.cc) \
	$(wildcard tensorflow/core/*/*/*/*_main.cc) \
	$(wildcard tensorflow/core/*test.cc) \
	$(wildcard tensorflow/core/*/*test.cc) \
	$(wildcard tensorflow/core/*/*/*test.cc) \
	$(wildcard tensorflow/core/*/*/*/*test.cc) \
	$(wildcard tensorflow/core/*testlib.cc) \
	$(wildcard tensorflow/core/*/*testlib.cc) \
	$(wildcard tensorflow/core/*/*/*testlib.cc) \
	$(wildcard tensorflow/core/*/*/*/*testlib.cc) \
	$(wildcard tensorflow/core/*testutil.cc) \
	$(wildcard tensorflow/core/*/*testutil.cc) \
	$(wildcard tensorflow/core/*/*/*testutil.cc) \
	$(wildcard tensorflow/core/*/*/*/*testutil.cc) \
	$(wildcard tensorflow/core/*test_utils.cc) \
	$(wildcard tensorflow/core/*/*test_utils.cc) \
	$(wildcard tensorflow/core/*/*/*test_utils.cc) \
	$(wildcard tensorflow/core/*/*/*/*test_utils.cc) \
	$(wildcard tensorflow/core/common_runtime/gpu/*) \
	$(wildcard tensorflow/core/common_runtime/sycl/*) \
	$(wildcard tensorflow/core/kernels/cuda*) \
	$(wildcard tensorflow/core/platform/default/cuda*.cc) \
	$(wildcard tensorflow/core/platform/stream_executor*) \
	$(wildcard tensorflow/core/user_ops/*) \
	tensorflow/core/grappler/inputs/file_input_yielder.cc \
	tensorflow/core/grappler/inputs/trivial_test_graph_input_yielder.cc \
	tensorflow/core/kernels/adjust_contrast_op.cc \
	tensorflow/core/kernels/conv_grad_ops_3d.cc \
	tensorflow/core/kernels/debug_ops.cc \
	tensorflow/core/kernels/sparse_tensor_dense_matmul_op.cc

CORE_SRCS := $(filter-out $(CORE_SRCS_EX), $(CORE_SRCS))
CORE_OBJS := $(addprefix $(BDIR), $(CORE_SRCS:.cc=.o))

$(TF_CORE): $(CORE_OBJS)
	ar rcs $@ $(CORE_OBJS)

# XXX: adding a "-w" argument to let GCC shutup or you'll get a giant buildlog.
$(BDIR)%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -w
