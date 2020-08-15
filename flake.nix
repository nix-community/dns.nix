{
  description = "Nix DSL for defining DNS zones";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      genTestScript = system: zone:
        nixpkgsFor.${system}.runCommand "dns-test-${system}" {
          inputs = with nixpkgsFor.${system}; [ diffutils ];
        } ''
          #!{nixpkgsFor.${system}.bash}/bin/bash
          #$(diff -du --label actual --label expected "$1" "$2")"
          if ! cmp -s "${zone}" "${self + "/.expected_zone"}"; then
            echo "file not equal:\n $(diff -du --label actual --label expected "${zone}" "${
              self + "/.expected_zone"
            }")"
            exit 1
          fi
          cp ${zone} $out
        '';

    in {
      # this atribute is there to override the nixpkgs version
      libOverlay.dns = import self;

      lib = forAllSystems (system: {
        dns = self.libOverlay.dns { pkgs = nixpkgsFor.${system}; };
      });

      hydraJobs = {
        dns.x86_64-linux = genTestScript "x86_64-linux"
          (import ./example.nix { dns = self.lib.x86_64-linux.dns; });
        dns.aarch64-linux = genTestScript "aarch64-linux"
          (import ./example.nix { dns = self.lib.aarch64-linux.dns; });
      };
    };
}
