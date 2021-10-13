{}: let
    nixpkgsRevision = "fdd348249b84f88ebb528b2015b248419c358848";
    nixpkgs = import (builtins.fetchTarball {
        name = "nixpkgs-unstable";
        url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRevision}.tar.gz";
        sha256 = sha256:1vjg3z3k0cfwzjwwsf8g17ljbp0zydyhxa4r6i68b84hmnj3k605;
    });
    pkgs = nixpkgs {};
    architectures = {
        # TODO: stdenv bootstrap cannot be built on non-armv7l
        # armhf = {
        #     crossCompile = true;
        #     system = "armv7l-linux";
        #     config = "armv7l-unknown-linux-gnueabihf";
        #     interpreter = "/lib/ld-linux-armhf.so.3";
        # };
        aarch64 = {
            crossCompile = true;
            system = "aarch64-linux";
            config = "aarch64-unknown-linux-gnu";
            interpreter = "/lib/ld-linux-aarch64.so.1";
        };
        amd64 = {
            crossCompile = false;
            system = "x86_64-linux";
            config = "x86_64-unknown-linux-gnu";
            interpreter = "/lib/ld-linux.so.2";
        };
        i686 = {
            crossCompile = false;
            system = "i686-linux";
            config = "i686-unknown-linux-gnu";
            interpreter = "/lib/ld-linux.so.2";
        };
    };
    bincache = system: nixpkgs {
        system = architectures."${system}".system;
    };
    crossSystem = system: let
        config = architectures."${system}";
    in if (config.crossCompile == true) then (nixpkgs {
        crossSystem = {
            config = config.config;
        };
        overlays = [(self: super: {
            # packages that do not cross-compile
            inherit ((bincache system))
                tpm2-tss
                systemd
                libfido2
                openssh
            ;
        })];
    }) else (bincache system);
    package = system: (crossSystem system).callPackage ./librespot.nix {
        withALSA = true;
        withPulseAudio = true;
    };
    binary = system: "${package system}/bin/librespot";
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
