#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs.lib) genAttrs;

  types = [
    "A"
    "AAAA"
    "CAA"
    "CNAME"
    "NS"
    "SOA"
    "TXT"
  ];

in

genAttrs types (t: import (./. + "/${t}.nix") { inherit pkgs; })
