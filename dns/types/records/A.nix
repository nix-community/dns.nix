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
  rtype = "A";
  options = {
    address = mkOption {
      type = types.str;
      example = "26.3.0.103";
      description = "IP address of the host";
    };
  };
  dataToString = {address, ...}: address;
}
