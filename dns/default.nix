#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  mkZone = name: zone:
    pkgs.writeTextFile {
      name = "${name}.zone";
      text = toString zone + "\n";
    };
in

{
  inherit mkZone;

  types = import ./types { inherit pkgs; };
}
