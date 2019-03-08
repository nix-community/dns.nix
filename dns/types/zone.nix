#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs.lib) mkOption types;

  record = import ./record.nix { inherit pkgs; };
  recordTypes = import ./records { inherit pkgs; };

in

types.submodule ({name, ...}: {
  options = {
    soa = mkOption rec {
      type = record recordTypes.SOA;
      example = {
        ttl = 24 * 60 * 60;
      } // type.example;
      description = "SOA record";
    };
    __toString = mkOption {
      readOnly = true;
      visible = false;
    };
  };

  config = {
    soa.name = name;
    soa.class = "IN";
    __toString = { soa, ... }:
      ''
        $TTL 24h

        $ORIGIN ${soa.name}.

        ${toString soa}
      '';

  };
})
