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
set(tf_op_lib_names
    "audio_ops"
    "array_ops"
    "batch_ops"
    "bitwise_ops"
    "boosted_trees_ops"
    "candidate_sampling_ops"
    "checkpoint_ops"
    "control_flow_ops"
    "ctc_ops"
    "cudnn_rnn_ops"
    "data_flow_ops"
    "dataset_ops"
    "decode_proto_ops"
    "encode_proto_ops"
    "functional_ops"
    "image_ops"
    "io_ops"
    "linalg_ops"
    "list_ops"
    "lookup_ops"
    "logging_ops"
    "manip_ops"
    "math_ops"
    "nn_ops"
    "no_op"
    "parsing_ops"
    "random_ops"
    "remote_fused_graph_ops"
    "resource_variable_ops"
    "rpc_ops"
    "script_ops"
    "sdca_ops"
    "set_ops"
    "sendrecv_ops"
    "sparse_ops"
    "spectral_ops"
    "state_ops"
    "stateless_random_ops"
    "string_ops"
    "summary_ops"
    "training_ops"
)

foreach(tf_op_lib_name ${tf_op_lib_names})
    ########################################################
    # tf_${tf_op_lib_name} library
    ########################################################
    file(GLOB tf_${tf_op_lib_name}_srcs
        "${tensorflow_source_dir}/tensorflow/core/ops/${tf_op_lib_name}.cc"
    )

    add_library(tf_${tf_op_lib_name} OBJECT ${tf_${tf_op_lib_name}_srcs})

    add_dependencies(tf_${tf_op_lib_name} tf_core_framework)
endforeach()
