#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 1035, 3.3.11

{ lib }:

let
  inherit (lib) dns mkOption;

in

{
  rtype = "NS";
  options = {
    nsdname = mkOption {
      type = dns.types.domain-name;
      example = "ns2.example.com";
      description = "A <domain-name> which specifies a host which should be authoritative for the specified class and domain";
    };
  };
  dataToString = {nsdname, ...}: "${nsdname}";
  fromString = nsdname: { inherit nsdname; };
}
