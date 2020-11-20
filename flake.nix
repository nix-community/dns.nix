# SPDX-FileCopyrightText: 2020 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  description = "Nix DSL for defining DNS zones";

  outputs = { self, nixpkgs }: {

    lib = import ./default.nix { pkgs = nixpkgs; };

  };
}
