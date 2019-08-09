# SPDX-FileCopyrightText: 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> {} }:

let
  dns = import ./dns { inherit pkgs; };
in

{
  inherit (dns) evalZone writeZone;
  inherit (dns) combinators;

  toString = name: zone: toString (dns.evalZone name zone);
} // dns.combinators
