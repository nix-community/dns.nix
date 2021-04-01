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
  rtype = "PTR";
  options = {
    ptrdname = mkOption {
      type = types.str;
      example = "4-3-2-1.dynamic.example.com.";
      description = "A <domain-name> which points to some location in the domain name space";
    };
  };
  dataToString = {ptrdname, ...}: "${ptrdname}";
  fromString = ptrdname: { inherit ptrdname; };
}
