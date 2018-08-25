# Minimum CMake required
cmake_minimum_required(VERSION 3.5)

# Project
project(tensorflow C CXX)
set(TF_PROJ_VERSION "1.10.0")
set(TF_PROJ_SOVERSION "1.10")

# Set C++14 as standard for the whole project
set(CMAKE_CXX_STANDARD 14)

# Actual source is the ../../.. directory
get_filename_component(tf_contrib_source_dir ${tensorflow_SOURCE_DIR} PATH)
get_filename_component(tf_tf_source_dir ${tf_contrib_source_dir} PATH)
get_filename_component(tensorflow_source_dir ${tf_tf_source_dir} PATH)

# Options
option(tensorflow_VERBOSE "Enable for verbose output" OFF)

# BoringSSL is enabled for gRPC.
option(tensorflow_ENABLE_SSL_SUPPORT "Enable boringssl support" OFF)

option(tensorflow_ENABLE_GRPC_SUPPORT "Enable gRPC support" OFF)
option(tensorflow_ENABLE_HDFS_SUPPORT "Enable HDFS support" OFF)
option(tensorflow_ENABLE_JEMALLOC_SUPPORT "Enable jemalloc support" OFF)
option(tensorflow_BUILD_CC_EXAMPLE "Build the C++ tutorial example" ON)
option(tensorflow_BUILD_PYTHON_BINDINGS "Build the Python bindings" ON)
option(tensorflow_BUILD_ALL_KERNELS "Build all OpKernels" ON)
option(tensorflow_BUILD_CONTRIB_KERNELS "Build OpKernels from tensorflow/contrib/..." OFF)
option(tensorflow_BUILD_CC_TESTS "Build cc unit tests " OFF)
option(tensorflow_BUILD_PYTHON_TESTS "Build python unit tests " OFF)
option(tensorflow_BUILD_MORE_PYTHON_TESTS "Build more python unit tests for contrib packages" OFF)
option(tensorflow_OPTIMIZE_FOR_NATIVE_ARCH "Enable compiler optimizations for the native processor architecture (if available)" ON)
option(tensorflow_ENABLE_SNAPPY_SUPPORT "Enable SNAPPY compression support" ON)
option(tensorflow_DISABLE_EIGEN_FORCEINLINE "Disable forceinline, to speed up build on windows." OFF)

# SIMD, MKL and MKLDNN options
option(tensorflow_WIN_CPU_SIMD_OPTIONS "Enables CPU SIMD instructions" OFF)
option(tensorflow_ENABLE_MKL_SUPPORT "Enable Intel MKL support" OFF)
option(tensorflow_ENABLE_MKLDNN_SUPPORT "Enable Intel MKLDNN support, requires MKL enabled" OFF)

# GPU, CUDA and cuDNN options
option(tensorflow_ENABLE_GPU "Enable GPU support" OFF)
set(tensorflow_CUDA_VERSION "9.0" CACHE STRING "CUDA version to build against")
set(tensorflow_CUDNN_VERSION "7" CACHE STRING "cuDNN version to build against")

if (NOT WIN32)
  # Threads: defines CMAKE_THREAD_LIBS_INIT and adds -pthread compile option
  # for targets that link ${CMAKE_THREAD_LIBS_INIT}.
  find_package (Threads)

  # Options for linking CUDA/CUDNN libraries
  option(tensorflow_PATH_STATIC_LIB "Additional library search path for libcudnn_static.a, libnccl_static.a, libculibos.a" /usr/local/cuda/lib64/)
  option(tensorflow_CUDNN_INCLUDE "cudnn.h header install path" /usr/include/)
  if (NOT tensorflow_CUDNN_INCLUDE)
    # option's default value is OFF. Fill it with real default values
    set(tensorflow_CUDNN_INCLUDE /usr/include)
  endif (NOT tensorflow_CUDNN_INCLUDE)
  option(tensorflow_PATH_CUDNN_STATIC_LIB "Override PATH_STATIC_LIB for libcudnn_static.a" ${tensorflow_PATH_STATIC_LIB})
  if (NOT tensorflow_PATH_CUDNN_STATIC_LIB)
    # option's default value is OFF. Fill it with real default values
    set (tensorflow_PATH_CUDNN_STATIC_LIB ${tensorflow_PATH_STATIC_LIB})
  endif (NOT tensorflow_PATH_CUDNN_STATIC_LIB)
  option(tensorflow_PATH_NCCL_STATIC_LIB "Override PATH_STATIC_LIB for libnccl_static.a" ${tensorflow_PATH_STATIC_LIB})
  if (NOT tensorflow_PATH_NCCL_STATIC_LIB)
    # option's default value is OFF. Fill it with real default values
    set (tensorflow_PATH_NCCL_STATIC_LIB ${tensorflow_PATH_STATIC_LIB})
  endif (NOT tensorflow_PATH_NCCL_STATIC_LIB)
  option(tensorflow_CUDA_LIBRARY_PATH "Designate the default CUDA library paths" /usr/local/cuda/lib64)
  if (NOT tensorflow_CUDA_LIBRARY_PATH)
    # option's default value is OFF. Fill it with real default values
    set(tensorflow_CUDA_LIBRARY_PATH /usr/local/cuda/lib64)
  endif (NOT tensorflow_CUDA_LIBRARY_PATH)

endif()

set(BOOL_WIN32 OFF)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

# [CLEANUP] Remove when done
# For debugging
function(SHOW_VARIABLES)
    get_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()

# External dependencies
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/external)

# Location where external projects will be downloaded
set (DOWNLOAD_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/downloads"
     CACHE PATH "Location where external projects will be downloaded.")
mark_as_advanced(DOWNLOAD_LOCATION)

if (tensorflow_ENABLE_POSITION_INDEPENDENT_CODE)
	set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
	set(CMAKE_POSITION_INDEPENDENT_CODE OFF)
endif()

# TODO(jart): We should make this only apply to snapfn.cc
add_definitions(-DSQLITE_OMIT_LOAD_EXTENSION)

if (tensorflow_DISABLE_EIGEN_FORCEINLINE)
  add_definitions(-DEIGEN_STRONG_INLINE=inline)
endif()

add_definitions(-DEIGEN_AVOID_STL_ARRAY)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -std=c++11")
endif()

if (tensorflow_OPTIMIZE_FOR_NATIVE_ARCH)
  include(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-march=native" COMPILER_OPT_ARCH_NATIVE_SUPPORTED)
  if (COMPILER_OPT_ARCH_NATIVE_SUPPORTED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
  endif()
endif()

include(CheckCXXCompilerFlag)

# OpenMP Support
CHECK_CXX_COMPILER_FLAG("-fopenmp" GCC_OPENMP_SUPPORT)
if (GCC_OPENMP_SUPPORT)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
endif()

if (tensorflow_ENABLE_JEMALLOC_SUPPORT)
  add_definitions(-DTENSORFLOW_USE_JEMALLOC -DJEMALLOC_EXPORT=)
endif()

# External dependencies
include(Dependency.cmake)
include(eigen)
include(fft2d)

add_definitions(${ADD_CFLAGS})
link_directories(${ADD_LINK_DIRECTORY})

set(tensorflow_EXTERNAL_LIBRARIES
    ${gif_STATIC_LIBRARIES}
    ${png_STATIC_LIBRARIES}
    ${jpeg_STATIC_LIBRARIES}
    ${lmdb_STATIC_LIBRARIES}
    ${jsoncpp_STATIC_LIBRARIES}
    ${farmhash_STATIC_LIBRARIES}
    ${fft2d_STATIC_LIBRARIES}
    ${highwayhash_STATIC_LIBRARIES}
    ${nsync_STATIC_LIBRARIES}
    ${protobuf_STATIC_LIBRARIES}
    ${re2_STATIC_LIBRARIES}
    ${sqlite_STATIC_LIBRARIES}
    ${double_conversion_STATIC_LIBRARIES}
    ${zlib_STATIC_LIBRARIES}
)

set(tensorflow_EXTERNAL_DEPENDENCIES
    jsoncpp
    protobuf
    eigen
    gemmlowp
    cub
    fft2d
    re2
    double_conversion
)

include_directories(
    # Source and generated code.
    ${tensorflow_source_dir}
    ${CMAKE_CURRENT_BINARY_DIR}
    # External dependencies.
    ${zlib_INCLUDE_DIR}
    ${gif_INCLUDE_DIR}
    ${png_INCLUDE_DIR}
    ${jpeg_INCLUDE_DIR}
    ${lmdb_INCLUDE_DIR}
    ${eigen_INCLUDE_DIRS}
    ${gemmlowp_INCLUDE_DIR}
    ${jsoncpp_INCLUDE_DIR}
    ${farmhash_INCLUDE_DIR}
    ${highwayhash_INCLUDE_DIR}
    ${cub_INCLUDE_DIR}
    ${nsync_INCLUDE_DIR}
    ${PROTOBUF_INCLUDE_DIRS}
    ${re2_INCLUDE_DIR}
    ${sqlite_INCLUDE_DIR}
    ${double_conversion_INCLUDE_DIR}
)

if(tensorflow_ENABLE_GRPC_SUPPORT)
  if(tensorflow_ENABLE_SSL_SUPPORT)
    include(boringssl)
    include_directories(${boringssl_INCLUDE_DIR})
  endif()
  #include(grpc)
  include_directories(${GRPC_INCLUDE_DIRS})
  # Place boringssl after grpc as grpc depends on boringssl.
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${grpc_STATIC_LIBRARIES})
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES grpc)
  if(tensorflow_ENABLE_SSL_SUPPORT)
    list(APPEND tensorflow_EXTERNAL_LIBRARIES ${boringssl_STATIC_LIBRARIES})
    list(APPEND tensorflow_EXTERNAL_DEPENDENCIES boringssl)
  endif()
endif()
if(tensorflow_ENABLE_JEMALLOC_SUPPORT)
  include(jemalloc)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${jemalloc_STATIC_LIBRARIES})
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES jemalloc)
  include_directories(${jemalloc_INCLUDE_DIRS})
endif()
if(tensorflow_ENABLE_SNAPPY_SUPPORT)
  #include(snappy)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${snappy_STATIC_LIBRARIES})
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES snappy)
  include_directories(${snappy_INCLUDE_DIR})
endif()
list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
if(HAIKU)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES network)
endif()

# MKL Support
if (tensorflow_ENABLE_MKL_SUPPORT)
  add_definitions(-DINTEL_MKL -DEIGEN_USE_VML)
  include(mkl)
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${mkl_STATIC_LIBRARIES})
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES mkl_copy_shared_to_destination)
  include_directories(${mkl_INCLUDE_DIRS})
  if (tensorflow_ENABLE_MKLDNN_SUPPORT)
    include(mkldnn)
    list(APPEND tensorflow_EXTERNAL_LIBRARIES ${mkldnn_STATIC_LIBRARIES})
    list(APPEND tensorflow_EXTERNAL_DEPENDENCIES mkldnn_copy_shared_to_destination)
    include_directories(${mkldnn_INCLUDE_DIRS})
  else (tensorflow_ENABLE_MKLDNN_SUPPORT)
    add_definitions(-DINTEL_MKL_ML)
  endif()
endif (tensorflow_ENABLE_MKL_SUPPORT)

if (tensorflow_ENABLE_GPU)
  # Default install paths for cuda libraries in Linux
  # In some Linux distros, find_package(CUDA) seems to require CMAKE_LIBRARY_PATH to include cuda-lib paths
  list(APPEND CMAKE_LIBRARY_PATH "${tensorflow_CUDA_LIBRARY_PATH}")
  list(APPEND CMAKE_LIBRARY_PATH "${tensorflow_CUDA_LIBRARY_PATH}/stubs")

  # later command will make use of the value in tensorflow_CUDA_VERSION
  find_package(CUDA ${tensorflow_CUDA_VERSION} REQUIRED EXACT)

  # Test compatibility of compiler on CUDA
  try_compile(CUDA_TEST_COMPILE_C
    ${CMAKE_CURRENT_BINARY_DIR}/tests/cuda
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/cuda/compatibility_test.c
    CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CUDA_INCLUDE_DIRS})
  try_compile(CUDA_TEST_COMPILE_CXX
    ${CMAKE_CURRENT_BINARY_DIR}/tests/cuda
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/cuda/compatibility_test.cc
    CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CUDA_INCLUDE_DIRS})
  if(NOT (CUDA_TEST_COMPILE_C AND CUDA_TEST_COMPILE_CXX))
    message(FATAL_ERROR "Selected compiler (or version) is not supported for CUDA")
  endif()

  # by default we assume compute cabability 3.5 and 5.2. If you change this change it in
  # CUDA_NVCC_FLAGS and cuda_config.h below
  set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-gencode arch=compute_30,code=\"sm_30,compute_30\";-gencode arch=compute_35,code=\"sm_35,compute_35\";-gencode arch=compute_52,code=\"sm_52,compute_52\")
  set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--include-path ${PROJECT_BINARY_DIR}/$\{build_configuration\};--expt-relaxed-constexpr)
  set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-ftz=true)  # Flush denormals to zero
  set(CUDA_INCLUDE ${CUDA_TOOLKIT_TARGET_DIR} ${CUDA_TOOLKIT_TARGET_DIR}/extras/CUPTI/include)
  include_directories(${CUDA_INCLUDE})

  # Without these double quotes, cmake in Linux makes it "-DTF_EXTRA_CUDA_CAPABILITIES=3.0, -D3.5, -D5.2" for cc, which incurs build breaks
  add_definitions(-DGOOGLE_CUDA=1 -D"TF_EXTRA_CUDA_CAPABILITIES=3.0,3.5,5.2")

  set(CUDNN_INCLUDE "${tensorflow_CUDNN_INCLUDE}")

  find_library(nccl_STATIC_LIBRARY NAMES libnccl_static.a PATHS ${tensorflow_PATH_NCCL_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
  if (NOT nccl_STATIC_LIBRARY)
    message(FATAL_ERROR "NCCL is required for GPU-build")
  else (NOT nccl_STATIC_LIBRARY)
    message("nccl-static: ${nccl_STATIC_LIBRARY}")
    # something like /usr/lib64/libnccl_static.a
  endif (NOT nccl_STATIC_LIBRARY)

  find_library(cudnn_STATIC_LIBRARY NAMES libcudnn_static.a PATHS ${tensorflow_PATH_CUDNN_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
  if (NOT cudnn_STATIC_LIBRARY)
    message(FATAL_ERROR "CUDNN is required for GPU-build")
  else (NOT cudnn_STATIC_LIBRARY)
    message("cudnn-static: ${cudnn_STATIC_LIBRARY}")
  endif (NOT cudnn_STATIC_LIBRARY)

  find_library(culibos_STATIC_LIBRARY NAMES libculibos.a PATHS ${tensorflow_PATH_STATIC_LIB} ${CUDA_TOOLKIT_ROOT_DIR})
  if (NOT culibos_STATIC_LIBRARY)
    message(FATAL_ERROR "CULIBOS is required for GPU-build")
  else (NOT culibos_STATIC_LIBRARY)
    message("culibos-static: ${culibos_STATIC_LIBRARY}")
  endif (NOT culibos_STATIC_LIBRARY)

  set(CUDA_LIBRARIES ${CUDA_LIBRARIES} ${CUDA_CUDA_LIBRARY} ${CUDA_CUBLAS_LIBRARIES} ${CUDA_CUFFT_LIBRARIES}
    ${CUDA_curand_LIBRARY} ${CUDA_cupti_LIBRARY} ${CUDA_cusolver_LIBRARY} ${cudnn_STATIC_LIBRARY} ${culibos_STATIC_LIBRARY} ${nccl_STATIC_LIBRARY})
  include_directories(${CUDNN_INCLUDE})

  # Remove "." from CUDA version variable.
  string(REPLACE "." "" short_CUDA_VER ${tensorflow_CUDA_VERSION})

  # create cuda_config.h
  FILE(WRITE ${tensorflow_source_dir}/third_party/gpus/cuda/cuda_config.h
    "#ifndef CUDA_CUDA_CONFIG_H_\n"
    "#define CUDA_CUDA_CONFIG_H_\n"
    "#define TF_CUDA_CAPABILITIES CudaVersion(\"3.0\"),CudaVersion(\"3.5\"),CudaVersion(\"5.2\")\n"
    "#define TF_CUDA_VERSION \"64_${short_CUDA_VER}\"\n"
    "#define TF_CUDNN_VERSION \"64_${tensorflow_CUDNN_VERSION}\"\n"
    "#define TF_CUDA_TOOLKIT_PATH \"${CUDA_TOOLKIT_ROOT_DIR}\"\n"
    "#endif  // CUDA_CUDA_CONFIG_H_\n"
  )

  # tf assumes in various places header files to be in cuda/include. On windows the cuda sdk
  # installs them under cuda/version/include and to avoid that we need to change tf we copy a
  # few files to cuda/include
  FILE(COPY
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuComplex.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cublas_v2.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cusolverDn.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda_fp16.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/device_functions.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cufft.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/curand.h
    ${CUDA_TOOLKIT_TARGET_DIR}/include/cuda_runtime_api.h
    ${CUDNN_INCLUDE}/cudnn.h
    DESTINATION ${tensorflow_source_dir}/third_party/gpus/cuda/include
  )

  include_directories(${tensorflow_source_dir}/third_party/gpus)
  # add cuda libraries to tensorflow_EXTERNAL_LIBRARIES
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${CUDA_LIBRARIES})
  # add gomp to tensorflow_EXTERNAL_LIBRARIES, needed by libcusolver.so
  list(APPEND tensorflow_EXTERNAL_LIBRARIES gomp)

  # NOTE(mrry): Update these flags when the version of CUDA or cuDNN used
  # in the default build is upgraded.
	set(tensorflow_BUILD_INFO_FLAGS --build_config cuda --key_value
		cuda_version_number=${tensorflow_CUDA_VERSION}
		cudnn_version_number=${tensorflow_CUDNN_VERSION})
else(tensorflow_ENABLE_GPU)
  set(tensorflow_BUILD_INFO_FLAGS --build_config cpu --key_value
    msvcp_dll_name=msvcp140.dll)
endif(tensorflow_ENABLE_GPU)

# Find python executable
include(FindPythonInterp)
if(NOT ${PYTHONINTERP_FOUND})
    message(FATAL_ERROR "CMake was unable to find a python interpreter.")
endif()

# Let's get to work!
include(010_tf_protos_cc.cmake)
include(020_tf_core_lib.cmake)
include(030_tf_core_framework.cmake)

if (tensorflow_ENABLE_GPU)
  include(tf_stream_executor.cmake)
endif()

include(040_tf_core_cpu.cmake)
include(050_tf_op_libs.cmake)
include(060_tf_core_ops.cmake)
include(061_tf_user_ops.cmake)
include(062_tf_debug_ops.cmake)
include(070_tf_core_direct_session.cmake)
include(080_tf_core_kernels.cmake)

if(tensorflow_ENABLE_GRPC_SUPPORT)
  include(tf_core_distributed_runtime.cmake)
endif()

# We include tf_cc_ops first, because tf_c depends on tf_cc.
include(100_tf_cc_framework.cmake)
include(110_tf_cc_op_gen.cmake)
include(120_tf_cc_ops.cmake)
include(130_tf_c.cmake)
include(140_tf_grappler.cmake)

include(tf_core_profiler.cmake)
if(tensorflow_BUILD_CC_EXAMPLE)
  include(tf_tutorials.cmake)
  include(tf_label_image_example.cmake)
endif()
include(tf_tools.cmake)
if(tensorflow_BUILD_PYTHON_BINDINGS)
  include(tf_python.cmake)
endif()

# Build the shared object libtensorflow.so.SOVERSION
include(tf_shared_lib.cmake)

if(tensorflow_BUILD_CC_TESTS OR tensorflow_BUILD_PYTHON_TESTS)
  include(tf_tests.cmake)
endif()
