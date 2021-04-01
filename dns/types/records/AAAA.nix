#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

{ lib }:

let
  inherit (lib) mkOption types;

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
  fromString = address: { inherit address; };
}
