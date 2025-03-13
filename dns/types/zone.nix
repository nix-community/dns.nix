#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
# SPDX-FileCopyrightText: 2021 Naïm Favier <n@monade.li>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

{ lib }:

let
  inherit (builtins) attrValues filter map removeAttrs;
  inherit (lib) concatMapStringsSep concatStringsSep mapAttrs
                     mapAttrsToList optionalString;
  inherit (lib) mkOption literalExample types;

  inherit (import ./record.nix { inherit lib; }) recordType writeRecord;

  rsubtypes = import ./records { inherit lib; };
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
      # example = [ t.example ];  # TODO: any way to auto-generate an example for submodule?
      description = "List of ${n} records for this zone/subzone";
    }) rsubtypes';

  subzone = types.submodule {
    options = subzoneOptions;
    config._module.args = { inherit (lib) dns; };
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
  zone = types.submodule ({ name, ... }: {
    options = {
      useOrigin = mkOption {
        type = types.bool;
        default = false;
        description = "Wether to use $ORIGIN and unqualified name or fqdn when exporting the zone.";
      };

      TTL = mkOption {
        type = types.ints.unsigned;
        default = 24 * 60 * 60;
        example = literalExample "60 * 60";
        description = "Default record caching duration. Sets the $TTL variable";
      };
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
      _module.args = { inherit (lib) dns; };
      __toString = zone@{ useOrigin, TTL, SOA, ... }:
        if useOrigin then
          ''
            $ORIGIN ${name}.
            $TTL ${toString TTL}

            ${writeRecord "@" rsubtypes.SOA SOA}

            ${writeSubzone "@" zone}
          ''
	      else
          ''
            $TTL ${toString TTL}

            ${writeRecord name rsubtypes.SOA SOA}

            ${writeSubzone name zone}
          '';
    };
  });

in

{
  inherit zone;
  inherit subzone;
}
