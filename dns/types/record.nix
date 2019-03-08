#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs) lib;
  inherit (lib) mkOption types;

  recordTypes = import ./records { inherit pkgs; };
in

recordType: types.submodule {
  options = {
    name = mkOption {
      type = types.str;
      example = "example.com";
      description = "Name of the node to which this resource record pertains";
    };
    rtype = mkOption {
      type = types.enum (lib.mapAttrsToList (n: v: v.rtype) recordTypes);
      readOnly = true;
      visible = false;
      description = "Type of the record. Do not set this option yourself!";
    };
    _rtype = mkOption {
      readOnly = true;
      visible = false;
    };
    class = mkOption {
      type = types.enum ["IN"];
      default = "IN";
      example = "IN";
      description = "Resource record class. Only IN is supported";
    };
    ttl = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      default = 24 * 60 * 60;
      example = 300;
      description = "Record caching duration (in seconds)";
    };
    __toString = mkOption {
      readOnly = true;
      visible = false;
    };
  } // recordType.options;
  config = {
    rtype  = recordType.rtype;
    _rtype = recordType;
    __toString = data@{name, rtype, class, ttl, _rtype, ...}:
      "${name}. ${toString ttl} ${class} ${rtype} ${_rtype.dataToString data}";
  };
}
