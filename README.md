# How to update

1. Update adapter URL and flake

   1. Update adapter URL
   1. Update flake: `nix flake update`
   1. Commit: `build(nix): update adapter to X.Y.Z`

2. (If releasing)
   1. bump the Cargo.toml and Cargo.lock: `cargo build`
   1. Commit: build: vX.Y.Z
   1. Merge PR
   1. Publish crate: `cargo publish`
