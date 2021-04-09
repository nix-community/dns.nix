# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

{ lib }:

let
  inherit (builtins) stringLength;

in

{
  # RFC 1035, 3.1
  domain-name = lib.types.addCheck lib.types.str (s: stringLength s <= 255);
}
