# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

{ lib }:

let
  inherit (builtins) genList stringLength substring;
  inherit (lib.strings) concatMapStringsSep;

  # : int -> str -> [str], such that each output str is <= n bytes
  splitInGroupsOf = n: s:
    let
      groupCount = (stringLength s - 1) / n + 1;
    in genList (i: substring (i * n) n s) groupCount;

  # : str -> [str], such that each output str is <= 255 bytes
  # (RFC 1035, 3.3)
  writeCharacterString = s:
    if stringLength s <= 255
    then ''"${s}"''
    else concatMapStringsSep " " (x: ''"${x}"'') (splitInGroupsOf 255 s);

in {
  inherit writeCharacterString;
}
