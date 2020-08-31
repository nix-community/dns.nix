{
  description = "Nix DSL for defining DNS zones";

  outputs = { self, nixpkgs }: {

    lib = import ./default.nix { pkgs = nixpkgs; };

  };
}
