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
  rtype = "CNAME";
  options = {
    cname = mkOption {
      type = types.str;
      example = "www.test.com";
      description = "A <domain-name> which specifies the canonical or primary name for the owner. The owner name is an alias";
    };
  };
  dataToString = {cname, ...}: "${cname}";
  fromString = cname: { inherit cname; };
}
