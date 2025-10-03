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

  # : str -> str
  # Prepares a Nix string to be written to a zone file as a character-string
  # literal: breaks it into chunks of 255 (per RFC 1035, 3.3) and encloses
  # each chunk in quotation marks.
  writeCharacterString = s:
    if stringLength s <= 255
    then ''"${s}"''
    else concatMapStringsSep " " (x: ''"${x}"'') (splitInGroupsOf 255 s);

  # : str -> str, with length 4 (zeros are padded to the left)
  align4Bytes = lib.fixedWidthString 4 "0";

  # : int -> str -> str
  # Expands "" to 4n zeros and aligns the rest on 4 bytes
  align4BytesOrExpand = n: v:
    if v == ""
    then (lib.fixedWidthString (4*n) "0" "")
    else align4Bytes v;

  # : str -> [ str ]
  # Returns the record of the ipv6 as a list
  mkIPv6RecordAux = v6:
    let
      v6' = if lib.hasPrefix "::" v6 then
        "0${v6}"
      else if lib.hasSuffix "::" v6 then
        "${v6}0"
      else
        v6;
      splitted = lib.splitString ":" v6';
      n = 8 - builtins.length (lib.filter (x: x != "") splitted);
    in
      lib.stringToCharacters (lib.concatMapStrings (align4BytesOrExpand n) splitted);

  # : str -> str
  # Returns the reversed record of the ipv6
  mkIPv6ReverseRecord = v6:
    lib.concatStringsSep "." (lib.reverseList (mkIPv6RecordAux v6)) + ".ip6.arpa";

  # : str -> str
  # Returns the reversed record of the ipv4
  mkIPv4ReverseRecord = v4:
    lib.concatStringsSep "." (
      lib.reverseList (
        lib.splitString "." v4
      )
    ) + ".in-addr.arpa";
in {
  inherit writeCharacterString mkIPv4ReverseRecord mkIPv6ReverseRecord;
}
