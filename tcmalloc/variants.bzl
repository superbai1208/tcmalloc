# Copyright 2019 The TCMalloc Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" Helper functions to simplify TCMalloc BUILD files """

variants = [
    {
        "name": "8k_pages",
        "malloc": "//tcmalloc",
        "deps": ["//tcmalloc:common"],
        "copts": [],
    },
    {
        "name": "32k_pages",
        "malloc": "//tcmalloc:tcmalloc_large_pages",
        "deps": ["//tcmalloc:common_large_pages"],
        "copts": ["-DTCMALLOC_LARGE_PAGES"],
    },
    {
        "name": "256k_pages",
        "malloc": "//tcmalloc:tcmalloc_256k_pages",
        "deps": ["//tcmalloc:common_256k_pages"],
        "copts": ["-DTCMALLOC_256K_PAGES"],
    },
    {
        "name": "small_but_slow",
        "malloc": "//tcmalloc:tcmalloc_small_but_slow",
        "deps": ["//tcmalloc:common_small_but_slow"],
        "copts": ["-DTCMALLOC_SMALL_BUT_SLOW"],
    },
    {
        "name": "legacy_spans",
        "malloc": "//tcmalloc",
        "deps": [
            "//tcmalloc:common",
            "//tcmalloc:want_legacy_spans",
        ],
        "copts": [],
    },
    {
        "name": "8k_pages_lock_free",
        "malloc": "//tcmalloc",
        "deps": ["//tcmalloc:common"],
        "copts": [],
        "env": {"BORG_EXPERIMENTS": "TCMALLOC_LOCK_FREE_TRANSFER_CACHE_V2"},
    },
    {
        "name": "8k_pages_sans_56",
        "malloc": "//tcmalloc",
        "deps": ["//tcmalloc:common"],
        "copts": [],
        "env": {"BORG_EXPERIMENTS": "TCMALLOC_CACHELINE_AWARE_SIZECLASSES"},
    },
    {
        "name": "8k_pages_16x_transfer_cache",
        "malloc": "//tcmalloc",
        "deps": ["//tcmalloc:common"],
        "copts": [],
        "env": {"BORG_EXPERIMENTS": "TEST_ONLY_TCMALLOC_16X_TRANSFER_CACHE"},
    },
    {
        "name": "8k_pages_16x_transfer_cache_v2",
        "malloc": "//tcmalloc",
        "deps": ["//tcmalloc:common"],
        "copts": [],
        "env": {"BORG_EXPERIMENTS": "TCMALLOC_16X_TRANSFER_CACHE_REAL"},
    },
]

# Declare an individual test.
def create_tcmalloc_test(
        name,
        copts,
        linkopts,
        malloc,
        srcs,
        deps,
        **kwargs):
    native.cc_test(
        name = name,
        srcs = srcs,
        copts = copts,
        linkopts = linkopts,
        malloc = malloc,
        deps = deps,
        **kwargs
    )

# Create test_suite of name containing tests variants.
def create_tcmalloc_testsuite(name, srcs, **kwargs):
    copts = kwargs.pop("copts", [])
    deps = kwargs.pop("deps", [])
    linkopts = kwargs.pop("linkopts", [])

    test_suite_targets = []
    for variant in variants:
        inner_test_suite_name = name + "_" + variant["name"]
        test_suite_targets.append(inner_test_suite_name)
        create_tcmalloc_test(
            inner_test_suite_name,
            copts = copts + variant.get("copts", []),
            linkopts = linkopts + variant.get("linkopts", []),
            malloc = variant.get("malloc"),
            srcs = srcs,
            deps = deps + variant.get("deps", []),
            env = variant.get("env", {}),
            **kwargs
        )

    native.test_suite(name = name, tests = test_suite_targets)

def create_tcmalloc_benchmark(name, srcs, **kwargs):
    deps = kwargs.pop("deps")
    malloc = kwargs.pop("malloc", "//tcmalloc")

    native.cc_binary(
        name = name,
        srcs = srcs,
        malloc = malloc,
        testonly = 1,
        linkstatic = 1,
        deps = deps + ["//tcmalloc/testing:benchmark_main"],
        **kwargs
    )
