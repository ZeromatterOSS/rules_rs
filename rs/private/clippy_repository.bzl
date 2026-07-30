load("@rules_rust//rust/platform:triple.bzl", "triple")
load("@rules_rust//rust/platform:triple_mappings.bzl", "system_to_binary_ext")
load(":rust_repository_utils.bzl", "RUST_REPOSITORY_COMMON_ATTR", "download_and_extract", "rustc_lib_build_file")

_build_file_tmpl = """\
filegroup(
    name = "clippy_driver_bin",
    srcs = ["bin/clippy-driver{binary_ext}"],
    data = [":rustc_lib"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "cargo_clippy_bin",
    srcs = ["bin/cargo-clippy{binary_ext}"],
    data = [":rustc_lib"],
    visibility = ["//visibility:public"],
)

{rustc_lib}
"""

def _clippy_repository_impl(rctx):
    exec_triple = triple(rctx.attr.triple)
    download_and_extract(rctx, "clippy", "clippy-preview", exec_triple)
    download_and_extract(rctx, "rustc", "rustc", exec_triple, sha256 = rctx.attr.rustc_sha256)
    rctx.file(
        "BUILD.bazel",
        _build_file_tmpl.format(
            binary_ext = system_to_binary_ext(exec_triple.system),
            rustc_lib = rustc_lib_build_file(exec_triple),
        ),
    )

    return rctx.repo_metadata(reproducible = True)

clippy_repository = repository_rule(
    implementation = _clippy_repository_impl,
    attrs = {
        "rustc_sha256": attr.string(mandatory = True),
    } | RUST_REPOSITORY_COMMON_ATTR,
)
