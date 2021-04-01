#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MIT
#

{ lib }:

let
  inherit (lib) mkOption types;

in

{
  rtype = "NS";
  options = {
    nsdname = mkOption {
      type = types.str;
      example = "ns2.example.com";
      description = "A <domain-name> which specifies a host which should be authoritative for the specified class and domain";
    };
  };
  dataToString = {nsdname, ...}: "${nsdname}";
  fromString = nsdname: { inherit nsdname; };
}
