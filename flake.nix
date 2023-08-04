{
  nixConfig.extra-substituters = [
    "https://wasmcloud.cachix.org"
    "https://bytecodealliance.cachix.org"
    "https://nix-community.cachix.org"
    "https://cache.garnix.io"
  ];
  nixConfig.extra-trusted-public-keys = [
    "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
    "bytecodealliance.cachix.org-1:0SBgh//n2n0heh0sDFhTm+ZKBRy2sInakzFGfzN531Y="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  inputs.nixify.url = github:rvolosatovs/nixify;
  inputs.wasi-preview1-command-component-adapter.flake = false;
  inputs.wasi-preview1-command-component-adapter.url = https://github.com/bytecodealliance/wasmtime/releases/download/v11.0.1/wasi_snapshot_preview1.command.wasm;
  inputs.wasi-preview1-reactor-component-adapter.flake = false;
  inputs.wasi-preview1-reactor-component-adapter.url = https://github.com/bytecodealliance/wasmtime/releases/download/v11.0.1/wasi_snapshot_preview1.reactor.wasm;

  outputs = {
    nixify,
    wasi-preview1-command-component-adapter,
    wasi-preview1-reactor-component-adapter,
    ...
  }:
    with nixify.lib; let
      WASI_PREVIEW1_COMMAND_COMPONENT_ADAPTER = wasi-preview1-command-component-adapter;
      WASI_PREVIEW1_REACTOR_COMPONENT_ADAPTER = wasi-preview1-reactor-component-adapter;
    in
      rust.mkFlake {
        src = ./.;

        excludePaths = [
          ".github"
          ".gitignore"
        ];

        doCheck = false; # testing is performed in checks via `nextest`

        clippy.allTargets = true;
        clippy.deny = ["warnings"];
        clippy.workspace = true;

        test.allTargets = true;
        test.workspace = true;

        buildOverrides = {...}: {...}: {
          inherit
            WASI_PREVIEW1_COMMAND_COMPONENT_ADAPTER
            WASI_PREVIEW1_REACTOR_COMPONENT_ADAPTER
            ;
        };

        withPackages = {
          hostRustToolchain,
          packages,
          pkgs,
          ...
        }: let
          mkAdapter = name: src:
            pkgs.stdenv.mkDerivation {
              inherit
                name
                src
                ;

              dontUnpack = true;
              dontBuild = true;

              installPhase = ''
                install $src $out
              '';
            };
        in
          packages
          // {
            wasi-preview1-command-component-adapter = mkAdapter "wasi-preview1-command-component-adapter" wasi-preview1-command-component-adapter;
            wasi-preview1-reactor-component-adapter = mkAdapter "wasi-preview1-reactor-component-adapter" wasi-preview1-reactor-component-adapter;
          };
      };
}
