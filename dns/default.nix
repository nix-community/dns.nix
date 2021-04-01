#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MIT
#

{ lib }:

let
  types = import ./types { inherit lib; };
  combinators = import ./combinators.nix { inherit lib; };

  evalZone = name: zone:
    (lib.evalModules {
      modules = [
        { options = {
            zones = lib.mkOption {
              type = lib.types.attrsOf types.zone;
              description = "DNS zones";
            };
          };
          config = {
            zones = { "${name}" = zone; };
          };
        }
      ];
    }).config.zones."${name}";

in

{
  inherit evalZone;

  inherit types;

  inherit combinators;
}
