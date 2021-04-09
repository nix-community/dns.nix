#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 1035, 3.3.14

{ lib }:

let
  inherit (lib) dns mkOption types;

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
  dataToString = { data, ... }: dns.util.writeCharacterString data;
  fromString = data: { inherit data; };
}
