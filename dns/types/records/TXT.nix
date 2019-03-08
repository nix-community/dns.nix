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
  rtype = "TXT";
  options = {
    data = mkOption {
      type = types.str;
      example = "favorite drink=orange juice";
      description = "Arbitrary information";
    };
  };
  dataToString = {data, ...}: ''"${data}"'';
}
