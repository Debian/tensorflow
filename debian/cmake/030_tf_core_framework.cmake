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
# tf_core_framework library
########################################################
file(GLOB_RECURSE tf_core_framework_srcs
    "${tensorflow_source_dir}/tensorflow/core/framework/*.h"
    "${tensorflow_source_dir}/tensorflow/core/framework/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/edgeset.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/edgeset.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/graph.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/graph.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/graph_def_builder.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/graph_def_builder.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/node_builder.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/node_builder.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/tensor_id.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/tensor_id.cc"
    "${tensorflow_source_dir}/tensorflow/core/graph/while_context.h"
    "${tensorflow_source_dir}/tensorflow/core/graph/while_context.cc"
    "${tensorflow_source_dir}/tensorflow/core/util/*.h"
    "${tensorflow_source_dir}/tensorflow/core/util/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/common_runtime/session.cc"
    "${tensorflow_source_dir}/tensorflow/core/common_runtime/session_factory.cc"
    "${tensorflow_source_dir}/tensorflow/core/common_runtime/session_options.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/*.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/*.h"
    "${tensorflow_source_dir}/public/*.h"
)

file(GLOB_RECURSE tf_core_framework_exclude_srcs
    "${tensorflow_source_dir}/tensorflow/core/framework/*test*.h"
    "${tensorflow_source_dir}/tensorflow/core/framework/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/core/framework/*testutil.h"
    "${tensorflow_source_dir}/tensorflow/core/framework/*testutil.cc"
    "${tensorflow_source_dir}/tensorflow/core/framework/*main.cc"
    "${tensorflow_source_dir}/tensorflow/core/framework/resource_handle.cc"
    "${tensorflow_source_dir}/tensorflow/core/util/*test*.h"
    "${tensorflow_source_dir}/tensorflow/core/util/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/core/util/*main.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/loader.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/vacuum.cc"
)

# TODO(jart): Why doesn't this work?
# set_source_files_properties(
#     ${tensorflow_source_dir}/tensorflow/contrib/tensorboard/db/snapfn.cc
#     PROPERTIES COMPILE_FLAGS -DSQLITE_OMIT_LOAD_EXTENSION)

list(REMOVE_ITEM tf_core_framework_srcs ${tf_core_framework_exclude_srcs})

add_library(tf_core_framework OBJECT
    ${tf_core_framework_srcs}
    ${tf_version_srcs}
    ${PROTO_TEXT_HDRS}
    ${PROTO_TEXT_SRCS})
add_dependencies(tf_core_framework
    tf_core_lib
    proto_text
)
