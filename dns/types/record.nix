#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
# SPDX-FileCopyrightText: 2021 Naïm Favier <n@monade.li>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

{ lib }:

let
  inherit (lib) hasSuffix isString mkOption removeSuffix types;

  recordType = rsubt:
    let
      submodule = types.submodule {
        options = {
          class = mkOption {
            type = types.enum [ "IN" ];
            default = "IN";
            example = "IN";
            description = "Resource record class. Only IN is supported";
          };
          ttl = mkOption {
            type = types.nullOr types.ints.unsigned;  # TODO: u32
            default = null;
            example = 300;
            description = "Record caching duration (in seconds)";
          };
        } // rsubt.options;
        config._module.args = { inherit (lib) dns; };
      };
    in
      (if rsubt ? fromString then types.either types.str else lib.id) submodule;

  # name == "@" : use unqualified domain name
  writeRecord = name: rsubt: data:
    let
      data' =
        if isString data && rsubt ? fromString then
          # add default values for the record type
          (recordType rsubt).merge [] [ { file = ""; value = rsubt.fromString data; } ]
        else data;
      name' = let fname = rsubt.nameFixup or (n: _: n) name data'; in
        if name == "@" then name
        else if (hasSuffix ".@" name) then removeSuffix ".@" fname
        else "${fname}.";
      rtype = rsubt.rtype;
    in lib.concatStringsSep " " (with data'; [
        name'
      ] ++ lib.optionals (ttl != null) [
        (toString ttl)
      ] ++ [
        class
        rtype
        (rsubt.dataToString data')
      ]);

in

{
  inherit recordType;
  inherit writeRecord;
}
