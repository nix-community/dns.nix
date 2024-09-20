# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
# SPDX-FileCopyrightText: 2024 Tom Hubrecht <https://hubrecht.ovh>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

{
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  dns = import ./dns { inherit (pkgs) lib; };
in

rec {
  lib = {
    inherit (dns) evalZone combinators types;
    toString = name: zone: builtins.toString (dns.evalZone name zone);
  } // dns.combinators;

  util.writeZone = import ./util/writeZone.nix {
    inherit (lib) evalZone;
    inherit (pkgs) writeTextFile;
  };

  checks = {
    eval-lib = pkgs.writeText "eval-lib" (builtins.deepSeq lib "OK");
    reuse =
      pkgs.runCommand "reuse-lint"
        {
          nativeBuildInputs = [ pkgs.reuse ];
        }
        ''
          reuse --root ${./.} lint > "$out"
        '';
  };
}
