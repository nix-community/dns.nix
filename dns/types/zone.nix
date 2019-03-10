#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (builtins) filter hasAttr map;
  inherit (pkgs.lib) concatMapStringsSep concatStringsSep filterAttrs id mapAttrs
                     optionalString;
  inherit (pkgs.lib) mkOption types;

  record = import ./record.nix { inherit pkgs; };

  recordTypes = import ./records { inherit pkgs; };
  recordTypes' = filterAttrs (n: v: n != "SOA") recordTypes;

  subzoneOptions = name: {
    subdomains = mkOption {
      type = types.attrsOf (subzone name);
      default = {};
      example = {
        www = {
          A = [ { address = "1.1.1.1"; } ];
        };
        staging = {
          A = [ { address = "1.0.0.1"; } ];
        };
      };
      description = "Records for subdomains of the domain";
    };
  } //
    mapAttrs (n: t: mkOption rec {
      type = types.listOf (record t name);
      default = [];
      example = [ t.example ];
      description = "List of ${t} records for this zone/subzone";
    }) recordTypes';

  subzone = pname:
    types.submodule ({name, ...}: {
      options = subzoneOptions "${name}.${pname}";
    });

  writeSubzone = zone:
    let
      groupToString = n:
        concatMapStringsSep "\n" toString (zone."${n}");
      groups = map groupToString (builtins.attrNames recordTypes');
      groups' = filter (s: s != "") groups;

      sub = concatMapStringsSep "\n\n" writeSubzone (builtins.attrValues zone.subdomains);
    in
      concatStringsSep "\n\n" groups'
      + optionalString (sub != "") ("\n\n" + sub);
in

rec {
  zone = types.submodule ({name, ...}: {
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
    } // subzoneOptions name;

    config = {
      __toString = zone@{SOA, ...}:
          ''
            ${toString SOA}

          '' + writeSubzone zone + "\n";
    };
  });

  inherit subzone;
}
