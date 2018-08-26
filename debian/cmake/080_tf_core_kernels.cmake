# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
########################################################
# tf_core_kernels library
########################################################

if(tensorflow_BUILD_ALL_KERNELS)
  file(GLOB_RECURSE tf_core_kernels_srcs
     "${tensorflow_source_dir}/tensorflow/core/kernels/*.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/*.cc"
  )
else(tensorflow_BUILD_ALL_KERNELS)
  # Build a minimal subset of kernels to be able to run a test program.
  set(tf_core_kernels_srcs
     "${tensorflow_source_dir}/tensorflow/core/kernels/bounds_check.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/constant_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/constant_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/fill_functor.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/fill_functor.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/matmul_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/matmul_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/no_op.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/no_op.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/ops_util.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/ops_util.cc"
     "${tensorflow_source_dir}/tensorflow/core/kernels/sendrecv_ops.h"
     "${tensorflow_source_dir}/tensorflow/core/kernels/sendrecv_ops.cc"
  )
endif(tensorflow_BUILD_ALL_KERNELS)

if(tensorflow_BUILD_CONTRIB_KERNELS)
  set(tf_contrib_kernels_srcs "")
  list(APPEND tf_core_kernels_srcs ${tf_contrib_kernels_srcs})
endif(tensorflow_BUILD_CONTRIB_KERNELS)

# Cloud libraries require curl and boringssl.
# Curl is not supported yet anyway so we remove for now.
file(GLOB tf_core_kernels_cloud_srcs
    "${tensorflow_source_dir}/tensorflow/contrib/cloud/kernels/*.h"
    "${tensorflow_source_dir}/tensorflow/contrib/cloud/kernels/*.cc"
)
list(REMOVE_ITEM tf_core_kernels_srcs "${tf_core_kernels_cloud_srcs}")

file(GLOB_RECURSE tf_core_kernels_exclude_srcs
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test*.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test*.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*testutil.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*testutil.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test_utils.h"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*test_utils.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*main.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/*.cu.cc"
   "${tensorflow_source_dir}/tensorflow/core/kernels/fuzzing/*"
   "${tensorflow_source_dir}/tensorflow/core/kernels/hexagon/*"
   "${tensorflow_source_dir}/tensorflow/core/kernels/remote_fused_graph_rewriter_transform*.cc"
)
list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_exclude_srcs})

if(tensorflow_ENABLE_GPU)
  file(GLOB_RECURSE tf_core_kernels_gpu_exclude_srcs
      # temporarily disable nccl as it needs to be ported with gpu
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/kernels/nccl_manager.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/kernels/nccl_ops.cc"
      "${tensorflow_source_dir}/tensorflow/contrib/nccl/ops/nccl_ops.cc"
  )
  list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_gpu_exclude_srcs})
endif(tensorflow_ENABLE_GPU)

file(GLOB_RECURSE tf_core_gpu_kernels_srcs
    "${tensorflow_source_dir}/tensorflow/core/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/framework/kernels/zero_initializer_op_gpu.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/image/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/rnn/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/seq2seq/kernels/*.cu.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/resampler/kernels/*.cu.cc"
)

if(WIN32 AND tensorflow_ENABLE_GPU)
  file(GLOB_RECURSE tf_core_kernels_cpu_only_srcs
      # GPU implementation not working on Windows yet.
      "${tensorflow_source_dir}/tensorflow/core/kernels/matrix_diag_op.cc"
      "${tensorflow_source_dir}/tensorflow/core/kernels/one_hot_op.cc")
  list(REMOVE_ITEM tf_core_kernels_srcs ${tf_core_kernels_cpu_only_srcs})
  add_library(tf_core_kernels_cpu_only OBJECT ${tf_core_kernels_cpu_only_srcs})
  add_dependencies(tf_core_kernels_cpu_only tf_core_cpu)
  # Undefine GOOGLE_CUDA to avoid registering unsupported GPU kernel symbols.
  get_target_property(target_compile_flags tf_core_kernels_cpu_only COMPILE_FLAGS)
  if(target_compile_flags STREQUAL "target_compile_flags-NOTFOUND")
    set(target_compile_flags "/UGOOGLE_CUDA")
  else()
    set(target_compile_flags "${target_compile_flags} /UGOOGLE_CUDA")
  endif()
  set_target_properties(tf_core_kernels_cpu_only PROPERTIES COMPILE_FLAGS ${target_compile_flags})
endif(WIN32 AND tensorflow_ENABLE_GPU)

add_library(tf_core_kernels OBJECT ${tf_core_kernels_srcs})
add_dependencies(tf_core_kernels tf_core_cpu)

if (WIN32)
  target_compile_options(tf_core_kernels PRIVATE /MP)
endif (WIN32)
if (tensorflow_ENABLE_GPU)
  set_source_files_properties(${tf_core_gpu_kernels_srcs} PROPERTIES CUDA_SOURCE_PROPERTY_FORMAT OBJ)
  set(tf_core_gpu_kernels_lib tf_core_gpu_kernels)
  cuda_add_library(${tf_core_gpu_kernels_lib} ${tf_core_gpu_kernels_srcs})
  set_target_properties(${tf_core_gpu_kernels_lib}
                        PROPERTIES DEBUG_POSTFIX ""
                        COMPILE_FLAGS "${TF_REGULAR_CXX_FLAGS}"
  )
  add_dependencies(${tf_core_gpu_kernels_lib} tf_core_cpu)
endif()
