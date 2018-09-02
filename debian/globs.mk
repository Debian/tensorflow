TF_PROTO_FILES := $(shell cat tf_proto_files.txt)
#TF_PROTO_FILES := $(shell find tensorflow/core -type f -name '*.proto')
TF_PROTO_H_GEN := $(addprefix $(BDIR), $(TF_PROTO_FILES:.proto=.pb.h))
TF_PROTO_CC_GEN := $(addprefix $(BDIR), $(TF_PROTO_FILES:.proto=.pb.cc))
TF_PROTO_OBJS := $(addprefix $(BDIR), $(TF_PROTO_FILES:.proto=.pb.o))

PBT_H := $(shell cat tf_pb_text_files.txt)
#PBT_H := $(shell find tensorflow/core -type f -name '*.proto')
#PBT_H := $(PBT_H:.proto=.pb.h)
PBT_H_GEN := $(addprefix $(BDIR), $(PBT_H))
PBT_IMPL_GEN := $(addprefix $(BDIR), $(PBT_H:.pb_text.h=.pb_text-impl.h))
PBT_CC_GEN := $(addprefix $(BDIR), $(PBT_H:.h=.cc))
PBT_OBJS := $(addprefix $(BDIR), $(PBT_H:.h=.o))

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
	$(wildcard tensorflow/core/lib/*.cc) \
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
	$(wildcard tensorflow/core/kernels/fuzzing/*) \
	$(wildcard tensorflow/core/platform/cloud/*) \
	$(wildcard tensorflow/core/platform/s3/*) \
	$(wildcard tensorflow/core/platform/google/*/*) \
	$(wildcard tensorflow/core/platform/google/*) \
	$(wildcard tensorflow/core/platform/windows/*) \
	$(wildcard tensorflow/core/user_ops/*) \
	$(wildcard tensorflow/core/debug/*) \
	$(wildcard tensorflow/core/platform/default/test_benchmark.*) \
	$(wildcard tensorflow/core/kernels/hexagon/*) \
	tensorflow/core/grappler/inputs/file_input_yielder.cc \
	tensorflow/core/grappler/inputs/trivial_test_graph_input_yielder.cc \
	tensorflow/core/kernels/adjust_contrast_op.cc \
	tensorflow/core/kernels/conv_grad_ops_3d.cc \
	tensorflow/core/kernels/debug_ops.cc \
	tensorflow/core/kernels/sparse_tensor_dense_matmul_op.cc

CORE_SRCS := $(sort $(CORE_SRCS))
CORE_SRCS := $(filter-out $(CORE_SRCS_EX), $(CORE_SRCS))
CORE_OBJS := $(addprefix $(BDIR), $(CORE_SRCS:.cc=.o))

TF_CC_SRCS_EX := \
	$(wildcard tensorflow/cc/framework/cc_op_gen*) \
	$(wildcard tensorflow/cc/*/*test.cc)

TF_CC_SRCS := \
	$(wildcard tensorflow/cc/*/*.cc)

TF_CC_SRCS := $(filter-out $(TF_CC_SRCS_EX), $(TF_CC_SRCS))
TF_CC_OBJS := $(addprefix $(BDIR), $(TF_CC_SRCS:.cc=.o))

TF_C_SRCS := \
tensorflow/c/checkpoint_reader.cc \
tensorflow/c/eager/c_api_debug.cc \
tensorflow/c/eager/c_api.cc \
tensorflow/c/c_api_function.cc \
tensorflow/c/c_api.cc \
tensorflow/c/tf_status_helper.cc

TF_C_OBJS := $(addprefix $(BDIR), $(TF_C_SRCS:.cc=.o))
