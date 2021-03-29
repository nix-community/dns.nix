# SPDX-FileCopyrightText: 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {} }:

let
  dns = import ./dns { inherit pkgs; };
  writeZone = import ./util/writeZone.nix {
    inherit (dns) evalZone;
    inherit (pkgs) writeTextFile;
  };
in

{
  inherit (dns) evalZone;
  inherit (dns) combinators;
  inherit writeZone;

  toString = name: zone: toString (dns.evalZone name zone);
} // dns.combinators
