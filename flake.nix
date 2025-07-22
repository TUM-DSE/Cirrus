{
  nixConfig.extra-substituters = [
    "https://tum-dse.cachix.org"
  ];

  nixConfig.extra-trusted-public-keys = [
    "tum-dse.cachix.org-1:v67rK18oLwgO0Z4b69l30SrV1yRtqxKpiHodG4YxhNM="
  ];

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      unstablepkgs,
      flake-utils,
      ...
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable = unstablepkgs.legacyPackages.${system};
        flakepkgs = self.packages.${system};
        buildDeps =
          pkgs:
          (with pkgs; [
            pkg-config
            gnumake
            flex
            bison
            git
            wget
            libuuid
            gcc
            # qemu
            (qemu_kvm.overrideAttrs (
              new: old: {
                patches =
                  old.patches
                  ++ [
                  ];
              }
            ))
            cmake
            unzip
            clang
            openssl
            ncurses
            bridge-utils
            python3
            python3Packages.numpy
            python3Packages.matplotlib
            python3Packages.seaborn
            python3Packages.scipy
            gnuplot
            llvmPackages_15.bintools
            perl
            doxygen
            gzip
            ncurses
            ncurses.dev
            sqlite.all
            (pkgs.runCommand "gcc-nm" { } ''
              # only bring in gcc-nm from libgcc.out, because it otherwise prevents crt1.so from musl to be found
              mkdir -p $out/bin
              cp ${pkgs.libgcc.out}/bin/gcc-nm $out/bin
              cp -r ${pkgs.libgcc.out}/libexec/ $out/
            '')
            gdb
            bpftrace
          ]);
        prevailDeps =
          pkgs:
          (with pkgs; [
            gcc
            git
            cmake
            boost
            yaml-cpp
          ]);
        make-disk-image = import (./nix/make-disk-image.nix);
      in
      {
        packages = {
          guest-image = make-disk-image {
            config = self.nixosConfigurations.guest.config;
            inherit (pkgs) lib;
            inherit pkgs;
            format = "qcow2";
          };

          linux-firmware-pinned = (
            pkgs.linux-firmware.overrideAttrs (
              old: new: {
                src = fetchGit {
                  url = "git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
                  ref = "main";
                  rev = "8a2d811764e7fcc9e2862549f91487770b70563b";
                };
                version = "8a2d81";
                outputHash = "sha256-dVvfwgto9Pgpkukf/IoJ298MUYzcsV1G/0jTxVcdFGw=";
              }
            )
          );
        };

        devShells = {
          default = pkgs.mkShell {
            name = "devShell";
            buildInputs =
              (buildDeps pkgs)
              ++ (prevailDeps pkgs)
              ++ [
                unstable.kraft
                unstable.gh
                unstable.just
                unstable.bridge-utils
                unstable.ack
              ];
            KRAFTKIT_NO_WARN_SUDO = "1";
            KRAFTKIT_NO_CHECK_UPDATES = "true";
            SQLITE_HDR = pkgs.sqlite.dev;
            SQLITE_LIB = pkgs.sqlite.out;
          };
        };
      }
    ))
    // (
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        flakepkgs = self.packages.x86_64-linux;
      in
      {
        nixosConfigurations = {
          guest = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              (import ./nix/guest-config.nix {
                inherit pkgs;
                inherit (pkgs) lib;
                inherit flakepkgs;
              })
              ./nix/nixos-generators-qcow.nix
            ];
          };
        };

      }
    );
}
