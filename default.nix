#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs ? import <nixpkgs> {} }:

let
  dns = import ./dns { inherit pkgs; };
in

{
  inherit (dns) evalZone writeZone;
}
