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
# tf_core_lib library
########################################################
file(GLOB_RECURSE tf_core_lib_srcs
    "${tensorflow_source_dir}/tensorflow/core/lib/*.h"
    "${tensorflow_source_dir}/tensorflow/core/lib/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/public/*.h"
)

file(GLOB tf_core_platform_srcs
    "${tensorflow_source_dir}/tensorflow/core/platform/*.h"
    "${tensorflow_source_dir}/tensorflow/core/platform/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/platform/default/*.h"
    "${tensorflow_source_dir}/tensorflow/core/platform/default/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/framework/resource_handle.h"
    "${tensorflow_source_dir}/tensorflow/core/framework/resource_handle.cc")
if (NOT tensorflow_ENABLE_GPU)
  file(GLOB tf_core_platform_gpu_srcs
      "${tensorflow_source_dir}/tensorflow/core/platform/cuda_libdevice_path.*"
      "${tensorflow_source_dir}/tensorflow/core/platform/default/cuda_libdevice_path.*")
  list(REMOVE_ITEM tf_core_platform_srcs ${tf_core_platform_gpu_srcs})
else()
  file(GLOB tf_core_platform_srcs_exclude
      "${tensorflow_source_dir}/tensorflow/core/platform/default/device_tracer.cc")
  list(REMOVE_ITEM tf_core_platform_srcs ${tf_core_platform_srcs_exclude})
endif()

list(APPEND tf_core_lib_srcs ${tf_core_platform_srcs})

if(UNIX)
  file(GLOB tf_core_platform_posix_srcs
      "${tensorflow_source_dir}/tensorflow/core/platform/posix/*.h"
      "${tensorflow_source_dir}/tensorflow/core/platform/posix/*.cc"
  )
  list(APPEND tf_core_lib_srcs ${tf_core_platform_posix_srcs})
endif(UNIX)

if(WIN32)
  file(GLOB tf_core_platform_windows_srcs
      "${tensorflow_source_dir}/tensorflow/core/platform/windows/*.h"
      "${tensorflow_source_dir}/tensorflow/core/platform/windows/*.cc"
      "${tensorflow_source_dir}/tensorflow/core/platform/posix/error.h"
      "${tensorflow_source_dir}/tensorflow/core/platform/posix/error.cc"
  )
  list(APPEND tf_core_lib_srcs ${tf_core_platform_windows_srcs})
endif(WIN32)

if (tensorflow_ENABLE_HDFS_SUPPORT)
  list(APPEND tf_core_platform_hdfs_srcs
      "${tensorflow_source_dir}/tensorflow/core/platform/hadoop/hadoop_file_system.cc"
      "${tensorflow_source_dir}/tensorflow/core/platform/hadoop/hadoop_file_system.h"
  )
  list(APPEND tf_core_lib_srcs ${tf_core_platform_hdfs_srcs})
endif()

file(GLOB_RECURSE tf_core_lib_test_srcs
    "${tensorflow_source_dir}/tensorflow/core/lib/*test*.h"
    "${tensorflow_source_dir}/tensorflow/core/lib/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/core/platform/*test*.h"
    "${tensorflow_source_dir}/tensorflow/core/platform/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/core/public/*test*.h"
)
list(REMOVE_ITEM tf_core_lib_srcs ${tf_core_lib_test_srcs})

add_library(tf_core_lib OBJECT ${tf_core_lib_srcs})
add_dependencies(tf_core_lib ${tensorflow_EXTERNAL_DEPENDENCIES} tf_protos_cc)

# Tricky setup to force always rebuilding
# force_rebuild always runs forcing ${VERSION_INFO_CC} target to run
# ${VERSION_INFO_CC} would cache, but it depends on a phony never produced
# target.
set(VERSION_INFO_CC ${tensorflow_source_dir}/tensorflow/core/util/version_info.cc)
add_custom_target(force_rebuild_target ALL DEPENDS ${VERSION_INFO_CC})
add_custom_command(OUTPUT __force_rebuild COMMAND ${CMAKE_COMMAND} -E echo)
add_custom_command(OUTPUT
    ${VERSION_INFO_CC}
    COMMAND ${PYTHON_EXECUTABLE} ${tensorflow_source_dir}/tensorflow/tools/git/gen_git_source.py
    ARGS --raw_generate ${VERSION_INFO_CC} --source_dir ${tensorflow_source_dir} --git_tag_override=${GIT_TAG_OVERRIDE}
    DEPENDS __force_rebuild)
set(tf_version_srcs ${tensorflow_source_dir}/tensorflow/core/util/version_info.cc)
