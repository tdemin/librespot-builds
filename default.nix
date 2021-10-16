{}: let
    nixpkgsRevision = "eeff99817d0ed62fa3fc5a05b5be7fbdf0e599ee";
    nixpkgs = import (builtins.fetchTarball {
        name = "nixpkgs-unstable";
        url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRevision}.tar.gz";
        sha256 = sha256:0vh04x06pz5f4nn57bha5l1wplwbs688zhlqa5rdarh9vdc4kfm6;
    });
    pkgs = nixpkgs {};
    architectures = {
        aarch64 = {
            system = "aarch64-linux";
            interpreter = "/lib/ld-linux-aarch64.so.1";
        };
        amd64 = {
            system = "x86_64-linux";
            interpreter = "/lib64/ld-linux-x86-64.so.2";
        };
        i686 = {
            system = "i686-linux";
            interpreter = "/lib/ld-linux.so.2";
        };
    };
    bincache = system: nixpkgs {
        system = architectures."${system}".system;
    };
    package = system: (bincache system).librespot;
    binary = system: "${package system}/bin/librespot";
    # patchelf pass is required to make binaries work on any system, not just with Nix/NixOS
    derive = system: let pkg = package system; in with pkgs; derivation {
        name = "librespot-${pkg.version}-${system}";
        version = pkg.version;
        builder = "${pkgs.bash}/bin/bash";
        args = [
            ./patchelf.sh
            "${binary system}"
            architectures."${system}".interpreter
            "librespot-${pkg.version}-${system}"
        ];
        buildInputs = with pkgs; [ patchelf coreutils ];
        inherit patchelf coreutils;
        system = builtins.currentSystem;
    };
    derivations = builtins.map derive (builtins.attrNames architectures);
in pkgs.buildEnv {
    name = "librespot-build";
    paths = derivations;
}
