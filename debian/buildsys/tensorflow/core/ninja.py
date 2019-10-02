




f.include('tensorflow/core/platform/build.ninja')

COMMON_PROTO_SRCS = [
    "example/example.proto",
    "example/feature.proto",
    "framework/allocation_description.proto",
    "framework/api_def.proto",
    "framework/attr_value.proto",
    "framework/cost_graph.proto",
    "framework/device_attributes.proto",
    "framework/function.proto",
    "framework/graph.proto",
    "framework/graph_transfer_info.proto",
    "framework/kernel_def.proto",
    "framework/log_memory.proto",
    "framework/node_def.proto",
    "framework/op_def.proto",
    "framework/reader_base.proto",
    "framework/remote_fused_graph_execute_info.proto",
    "framework/resource_handle.proto",
    "framework/step_stats.proto",
    "framework/summary.proto",
    "framework/tensor.proto",
    "framework/tensor_description.proto",
    "framework/tensor_shape.proto",
    "framework/tensor_slice.proto",
    "framework/types.proto",
    "framework/variable.proto",
    "framework/versions.proto",
    "protobuf/config.proto",
    "protobuf/cluster.proto",
    "protobuf/debug.proto",
    "protobuf/device_properties.proto",
    "protobuf/graph_debug_info.proto",
    "protobuf/queue_runner.proto",
    "protobuf/rewriter_config.proto",
    "protobuf/tensor_bundle.proto",
    "protobuf/saver.proto",
    "protobuf/verifier_config.proto",
    "protobuf/trace_events.proto",
    "util/event.proto",
    "util/memmapped_file_system.proto",
    "util/saved_tensor_slice.proto",
]

ERROR_CODES_PROTO_SRCS = [
    "lib/core/error_codes.proto",
]

CORE_PROTO_SRCS = COMMON_PROTO_SRCS + ERROR_CODES_PROTO_SRCS






ADDITIONAL_CORE_PROTO_SRCS = [
    "example/example_parser_configuration.proto",
    "protobuf/trackable_object_graph.proto",
    "protobuf/control_flow.proto",
    "protobuf/data/experimental/snapshot.proto",
    # TODO(ebrevdo): Re-enable once CriticalSection is in core.
    # "protobuf/critical_section.proto",
    "protobuf/meta_graph.proto",
    "protobuf/named_tensor.proto",
    "protobuf/saved_model.proto",
    "protobuf/saved_object_graph.proto",
    "protobuf/struct.proto",
    "protobuf/tensorflow_server.proto",
    "protobuf/transport_options.proto",
    "util/test_log.proto",
]

protoGroup('protos_all', [os.path.join(d, x) for x in CORE_PROTO_SRCS + ADDITIONAL_CORE_PROTO_SRCS])


src = "tensorflow/core/platform/platform_strings.cc"
f.variable('_platform_strings', src.replace('.cc', '.o'))
f.build(src.replace('.cc', '.o'), 'CXX', src)


src = "tensorflow/core/platform/protobuf.cc"
f.variable('_lib_proto_parsing', src.replace('.cc', '.o'))
f.build(src.replace('.cc', '.o'), 'CXX', src)

