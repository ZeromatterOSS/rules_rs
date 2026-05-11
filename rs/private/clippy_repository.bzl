load("@rules_rust//rust/platform:triple.bzl", "triple")
load("@rules_rust//rust/private:repository_utils.bzl", "BUILD_for_clippy")
load(":rust_repository_utils.bzl", "RUST_REPOSITORY_COMMON_ATTR", "download_and_extract")

def _clippy_repository_impl(rctx):
    exec_triple = triple(rctx.attr.triple)
    download_and_extract(rctx, "clippy", "clippy-preview", exec_triple)
    download_and_extract(rctx, "rustc", "rustc", exec_triple, sha256 = rctx.attr.rustc_sha256)
    rctx.file("BUILD.bazel", BUILD_for_clippy(exec_triple, include_rustc_lib = True))

    return rctx.repo_metadata(reproducible = True)

clippy_repository = repository_rule(
    implementation = _clippy_repository_impl,
    attrs = {
        "rustc_sha256": attr.string(mandatory = True),
    } | RUST_REPOSITORY_COMMON_ATTR,
)
