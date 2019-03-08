#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

{
  inherit (import ./zone.nix { inherit pkgs; }) zone subzone;
  record = import ./record.nix { inherit pkgs; };
  records = import ./records { inherit pkgs; };
}
