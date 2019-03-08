#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (builtins) filter map;
  inherit (pkgs.lib) concatMapStringsSep concatStringsSep filterAttrs mapAttrs;
  inherit (pkgs.lib) mkOption types;

  record = import ./record.nix { inherit pkgs; };
  recordTypes = import ./records { inherit pkgs; };

  recordTypes' = filterAttrs (n: v: n != "SOA") recordTypes;
in

types.submodule ({name, ...}: {
  options = {
    SOA = mkOption rec {
      type = record recordTypes.SOA name;
      example = {
        ttl = 24 * 60 * 60;
      } // type.example;
      description = "SOA record";
    };
    __toString = mkOption {
      readOnly = true;
      visible = false;
    };
  }  // mapAttrs (n: t: mkOption rec {
          type = types.listOf (record t name);
          default = [];
          example = [ t.example ];
          description = "List of ${t} records for this zone/subzone";
        }) recordTypes';

  config = {
    __toString = zone@{SOA, ...}:
      let
        groupToString = n:
          concatMapStringsSep "\n" toString (zone."${n}");
        groups = map groupToString (builtins.attrNames recordTypes');
        groups' = filter (s: s != "") groups;
      in
        ''
          $TTL 24h

          $ORIGIN ${SOA.name}.

          ${toString SOA}

        '' + concatStringsSep "\n\n" groups';
  };
})
