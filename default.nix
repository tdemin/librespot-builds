{}: let
    nixpkgsRevision = "e6badb26fc0d238fda2432c45b7dd4e782eb8200";
    nixpkgsSha256 = sha256:0vsvrv7qrrxjn0vgvr3rsvlsbd8bnyacnw4c1mac9vzx17yldxbv;
    nixpkgs = import (builtins.fetchTarball {
        name = "nixpkgs-unstable";
        url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRevision}.tar.gz";
        sha256 = nixpkgsSha256;
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
    paths = derivations ++ [ (pkgs.writeTextFile {
        name = "librespot-version.txt";
        text = "${pkgs.librespot.version}\n";
        executable = false;
        destination = "/version.txt";
    }) ];
}
