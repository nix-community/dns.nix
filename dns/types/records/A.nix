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
  rtype = "A";
  options = {
    address = mkOption {
      type = types.str;
      example = "26.3.0.103";
      description = "IP address of the host";
    };
  };
  dataToString = {address, ...}: address;
  fromString = address: { inherit address; };
}
