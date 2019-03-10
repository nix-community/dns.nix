#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs.lib) mkOption types;

in

{
  rtype = "AAAA";
  options = {
    address = mkOption {
      type = types.str;
      example = "4321:0:1:2:3:4:567:89ab";
      description = "IPv6 address of the host";
    };
  };
  dataToString = {address, ...}: address;
}
