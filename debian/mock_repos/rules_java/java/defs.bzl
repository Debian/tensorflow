# Copyright 2020 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Mocks rules defined in rules_java."""

def java_binary(**kwargs):
    native.java_binary(**kwargs)

def java_library(**kwargs):
    native.java_library(**kwargs)

def java_test(**kwargs):
    native.java_test(**kwargs)

def java_proto_library(**kwargs):
    native.java_proto_library(**kwargs)

def java_import(**kwargs):
    native.java_import(**kwargs)

def java_toolchain(**kwargs):
    native.java_toolchain(**kwargs)

def java_runtime(**kwargs):
    native.java_runtime(**kwargs)

def java_plugin(**kwargs):
    native.java_plugin(**kwargs)
