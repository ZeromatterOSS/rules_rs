"""Repository rule for downloading bpf-linker."""

_BPF_LINKER_VERSION = "0.10.4"

_BPF_LINKER_ARCHIVES = {
    "aarch64-apple-darwin": "7e0c692b2e839afdb3e2f1053bd9a94e55b99f7b6a94ef69990449a6d72837ce",
    "aarch64-pc-windows-gnullvm": "341ea6db58a7d5ac7348d835e86a8da9ef351445704646f9632a4410d89ae60a",
    "aarch64-unknown-linux-musl": "c3638cd3cb735ff85705905a07e0df61c0f9426480334c8e2efe5cb92fd9d3de",
    "x86_64-apple-darwin": "55771c82883b414f3f4e8bd081a182e8deefa1b953ab249c85b253fc2b69de48",
    "x86_64-pc-windows-gnullvm": "d3e3448333f4dd7e49103071a547ff9a944d6f277b48bdcfe9d9326dca725260",
    "x86_64-unknown-linux-musl": "4dda77daab6c5f120a468e6d3ede2498f5bd47ece712172cfb7290176d93d015",
}

_BPF_LINKER_ARCHIVE_TRIPLES = {
    "aarch64-apple-darwin": "aarch64-apple-darwin",
    "aarch64-pc-windows-msvc": "aarch64-pc-windows-gnullvm",
    "aarch64-unknown-linux-gnu": "aarch64-unknown-linux-musl",
    "x86_64-apple-darwin": "x86_64-apple-darwin",
    "x86_64-pc-windows-msvc": "x86_64-pc-windows-gnullvm",
    "x86_64-unknown-linux-gnu": "x86_64-unknown-linux-musl",
}

BPF_LINKER_SUPPORTED_EXEC_TRIPLES = sorted(_BPF_LINKER_ARCHIVE_TRIPLES.keys())

def _bpf_linker_archive_triple(exec_triple):
    return _BPF_LINKER_ARCHIVE_TRIPLES.get(exec_triple)

def bpf_linker_repository_name(exec_triple):
    archive_triple = _bpf_linker_archive_triple(exec_triple)
    if not archive_triple:
        return None
    return "rs_bpf_linker_" + archive_triple.replace("-", "_")

def bpf_linker_binary_name(exec_triple):
    return "bpf-linker.exe" if "-windows-" in exec_triple else "bpf-linker"

def _bpf_linker_repository_impl(rctx):
    archive_triple = rctx.attr.archive_triple
    rctx.download_and_extract(
        url = "https://github.com/aya-rs/bpf-linker/releases/download/v{version}/bpf-linker-{triple}.tar.zst".format(
            version = _BPF_LINKER_VERSION,
            triple = archive_triple,
        ),
        sha256 = _BPF_LINKER_ARCHIVES[archive_triple],
    )
    rctx.file(
        "BUILD.bazel",
        'exports_files(["%s"])\n' % bpf_linker_binary_name(archive_triple),
    )

    return rctx.repo_metadata(reproducible = True)

_bpf_linker_repository = repository_rule(
    implementation = _bpf_linker_repository_impl,
    attrs = {
        "archive_triple": attr.string(
            mandatory = True,
            values = _BPF_LINKER_ARCHIVES.keys(),
        ),
    },
)

def declare_bpf_linker_repository(exec_triple):
    """Declares the pinned bpf-linker repository for a supported execution triple."""
    archive_triple = _bpf_linker_archive_triple(exec_triple)
    if not archive_triple:
        fail("bpf-linker is not available for execution triple {}".format(exec_triple))

    _bpf_linker_repository(
        name = bpf_linker_repository_name(exec_triple),
        archive_triple = archive_triple,
    )
