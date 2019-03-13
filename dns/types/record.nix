#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs) lib;
  inherit (lib) const isString mkOption types;

  defaults = {
    class = "IN";
    ttl = 24 * 60 * 60;
  };

  recordType = rsubt:
    let
      submodule = types.submodule {
        options = {
          class = mkOption {
            type = types.enum ["IN"];
            default = defaults.class;
            example = "IN";
            description = "Resource record class. Only IN is supported";
          };
          ttl = mkOption {
            type = types.ints.unsigned;  # TODO: u32
            default = defaults.ttl;
            example = 300;
            description = "Record caching duration (in seconds)";
          };
        } // rsubt.options;
      };
    in
      (if rsubt ? fromString then types.either types.str else lib.id) submodule;

  writeRecord = name: rsubt: data:
    let
      data' =
        if isString data && rsubt ? fromString
        then defaults // rsubt.fromString data
        else data;
      name' = rsubt.nameFixup or (n: _: n) name data';
      rtype = rsubt.rtype;
    in with data';
      "${name'}. ${toString ttl} ${class} ${rtype} ${rsubt.dataToString data'}";

in

{
  inherit recordType;
  inherit writeRecord;
}
