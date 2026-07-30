load("@rules_rust//rust/platform:triple.bzl", "triple")
load("@rules_rust//rust/platform:triple_mappings.bzl", "system_to_binary_ext")
load(":rust_repository_utils.bzl", "RUST_REPOSITORY_COMMON_ATTR", "download_and_extract")

_build_file_tmpl = """\
filegroup(
    name = "rust_analyzer",
    srcs = ["bin/rust-analyzer{binary_ext}"],
    visibility = ["//visibility:public"],
)
"""

def _rust_analyzer_repository_impl(rctx):
    exec_triple = triple(rctx.attr.triple)
    download_and_extract(rctx, "rust-analyzer", "rust-analyzer-preview", exec_triple)
    rctx.file("BUILD.bazel", _build_file_tmpl.format(binary_ext = system_to_binary_ext(exec_triple.system)))

    return rctx.repo_metadata(reproducible = True)

rust_analyzer_repository = repository_rule(
    implementation = _rust_analyzer_repository_impl,
    attrs = RUST_REPOSITORY_COMMON_ATTR,
)
