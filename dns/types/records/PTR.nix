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
  rtype = "PTR";
  options = {
    cname = mkOption {
      type = types.str;
      example = "www.test.com";
      description = "A <domain-name> which specifies the domain name associated with an IP address";
    };
  };
  dataToString = {ptr, ...}: "${ptr}";
  fromString = ptr: { inherit ptr; };
}
