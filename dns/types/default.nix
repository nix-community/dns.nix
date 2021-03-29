#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ lib }:

{
  inherit (import ./zone.nix { inherit lib; }) zone subzone;
  record = import ./record.nix { inherit lib; };
  records = import ./records { inherit lib; };
}
