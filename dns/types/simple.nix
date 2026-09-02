# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

{ lib }:

let
  inherit (builtins) stringLength;

  # RFC 1035, 3.1
  domain-name = lib.types.addCheck lib.types.nonEmptyStr (s: stringLength s <= 255) // {
    description = "an RFC 1035 DNS domain name";
  };
in

{
  inherit domain-name;

  # RFC 2181, section 11
  domain-label = lib.types.addCheck lib.types.nonEmptyStr (s: stringLength s <= 63) // {
    description = "a DNS label";
  };

  fqdn = lib.types.addCheck domain-name (lib.strings.hasSuffix ".") // {
    description = "a fully-qualified DNS domain name";
  };
}
