#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (builtins) attrValues filter map removeAttrs;
  inherit (pkgs.lib) concatMapStringsSep concatStringsSep mapAttrs
                     mapAttrsToList optionalString;
  inherit (pkgs.lib) mkOption types;

  inherit (import ./record.nix { inherit pkgs; }) recordType writeRecord;

  rsubtypes = import ./records { inherit pkgs; };
  rsubtypes' = removeAttrs rsubtypes ["SOA"];

  subzoneOptions = {
    subdomains = mkOption {
      type = types.attrsOf subzone;
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
      type = types.listOf (recordType t);
      default = [];
      example = [ t.example ];
      description = "List of ${t} records for this zone/subzone";
    }) rsubtypes';

  subzone = types.submodule {
      options = subzoneOptions;
    };

  writeSubzone = name: zone:
    let
      groupToString = pseudo: subt:
        concatMapStringsSep "\n" (writeRecord name subt) (zone."${pseudo}");
      groups = mapAttrsToList groupToString rsubtypes';
      groups' = filter (s: s != "") groups;

      writeSubzone' = subname: writeSubzone "${subname}.${name}";
      sub = concatStringsSep "\n\n" (mapAttrsToList writeSubzone' zone.subdomains);
    in
      concatStringsSep "\n\n" groups'
      + optionalString (sub != "") ("\n\n" + sub);

  zone = types.submodule ({name, ...}: {
    options = {
      SOA = mkOption rec {
        type = recordType rsubtypes.SOA;
        example = {
          ttl = 24 * 60 * 60;
        } // type.example;
        description = "SOA record";
      };
      __toString = mkOption {
        readOnly = true;
        visible = false;
      };
    } // subzoneOptions;

    config = {
      __toString = zone@{SOA, ...}:
          ''
            ${writeRecord name rsubtypes.SOA SOA}

          '' + writeSubzone name zone + "\n";
    };
  });

in

{
  inherit zone;
  inherit subzone;
}
