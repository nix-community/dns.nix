#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 1035, 3.3.12

{ lib }:

let
  inherit (lib) dns mkOption;

in

{
  rtype = "PTR";
  options = {
    ptrdname = mkOption {
      type = dns.types.domain-name;
      example = "4-3-2-1.dynamic.example.com.";
      description = "A <domain-name> which points to some location in the domain name space";
    };
  };
  dataToString = {ptrdname, ...}: "${ptrdname}";
  fromString = ptrdname: { inherit ptrdname; };
}
