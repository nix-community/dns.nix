#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

{
  zone = import ./zone.nix { inherit pkgs; };
  record = import ./record.nix { inherit pkgs; };
  records = import ./records { inherit pkgs; };
}
