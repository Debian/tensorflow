# A part of modified TensorFlow CMake for Debian.
# Copyright (C) 2018 Mo Zhou. MIT/Expat License

# double-conversion
set(double_conversion_INCLUDE_DIR "/usr/include/double-conversion")
set(double_conversion_STATIC_LIBRARIES "-ldouble-conversion")
add_custom_target(double_conversion)

# farmhash
set(farmhash_INCLUDE_DIR "/usr/include")
set(farmhash_STATIC_LIBRARIES "-lfarmhash")
add_custom_target(farmhash)

# gemmlowp
set(gemmlowp_INCLUDE_DIR "/usr/include/gemmlowp")
add_custom_target(gemmlowp)

# gif
set(gif_INCLUDE_DIR "/usr/include")
set(gif_STATIC_LIBRARIES "-lgif")
add_custom_target(gif)

# grpc FIXME: FTBFS with GRPC support: API mismatch.
#find_package(PkgConfig)
#set(grpc_INCLUDE_DIRS "/usr/include/")
#set(grpc_STATIC_LIBRARIES "-lgrpc++ -lgrpc")
#set(GRPC_BUILD "/usr/bin")
#add_custom_target(grpc)

# gtest
set(googletest_INCLUDE_DIRS "/usr/include")
execute_process(COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH OUTPUT_VARIABLE CMAKE_MULTIARCH_TRIPLET OUTPUT_STRIP_TRAILING_WHITESPACE)
set(googletest_STATIC_LIBRARIES "/usr/lib/${CMAKE_MULTIARCH_TRIPLET}/libgtest.a")
add_custom_target(googletest)

# highwayhash
set(highwayhash_INCLUDE_DIR "/usr/include/highwayhash")
set(highwayhash_STATIC_LIBRARIES "-lhighwayhash")
add_custom_target(highwayhash)
add_custom_target(highwayhash_create_destination_dir)
add_custom_target(highwayhash_copy_headers_to_destination)

# jpeg
set(jpeg_INCLUDE_DIR "/usr/include")
set(jpeg_STATIC_LIBRARIES "-ljpeg")
add_custom_target(jpeg)

# jsoncpp
  # Debian user still need to patch TF's code to modify the include path
  # find . -type f -exec sed -i -e 's@include/json/json.h@json/json.h@g' '{}' +
set(jsoncpp_STATIC_LIBRARIES "-ljsoncpp")
set(jsoncpp_INCLUDE_DIR "/usr/include/jsoncpp")
add_custom_target(jsoncpp)

# lmdb
set(lmdb_INCLUDE_DIR "/usr/include")
set(lmdb_STATIC_LIBRARIES "-llmdb")
add_custom_target(lmdb)

# nsync
set(nsync_INCLUDE_DIR "/usr/include")
set(nsync_STATIC_LIBRARIES "-lnsync -lnsync_cpp")
add_custom_target(nsync)

# png
set(png_INCLUDE_DIR "/usr/include/libpng16")
set(png_STATIC_LIBRARIES "-lpng16")
add_custom_target(png)

# protobuf
set(PROTOBUF_INCLUDE_DIRS "/usr/include/google/")
set(protobuf_STATIC_LIBRARIES "-lprotobuf")
set(PROTOBUF_PROTOC_EXECUTABLE "/usr/bin/protoc")
add_custom_target(protobuf)

# re2
set(re2_INCLUDE_DIR "/usr/include")
set(re2_STATIC_LIBRARIES "-lre2")
add_custom_target(re2)

# snappy
set(snappy_INCLUDE_DIR "/usr/include")
set(snappy_STATIC_LIBRARIES "-lsnappy")
add_custom_target(snappy)
add_definitions(-DTF_USE_SNAPPY)

# sqlite3
set(sqlite_INCLUDE_DIR "/usr/include")
set(sqlite_STATIC_LIBRARIES "-lsqlite3")
add_custom_target(sqlite)

# zlib
set(zlib_INCLUDE_DIR ${ZLIB_INCLUDE_DIRS})
set(zlib_STATIC_LIBRARIES "-lz")
add_custom_target(zlib)

# stubs
add_custom_target(cub)
