# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

{ lib }:

let
  inherit (builtins)
    genList
    stringLength
    substring
    concatStringsSep
    ;
  inherit (lib.strings) concatMapStringsSep splitString;
  inherit (lib.lists) reverseList;

  # : int -> str -> [str], such that each output str is <= n bytes
  splitInGroupsOf =
    n: s:
    let
      groupCount = (stringLength s - 1) / n + 1;
    in
    genList (i: substring (i * n) n s) groupCount;

  # : str -> str
  # Prepares a Nix string to be written to a zone file as a character-string
  # literal: breaks it into chunks of 255 (per RFC 1035, 3.3) and encloses
  # each chunk in quotation marks.
  writeCharacterString =
    s: if stringLength s <= 255 then ''"${s}"'' else concatMapStringsSep " " (x: ''"${x}"'') (splitInGroupsOf 255 s);

  # : str -> [ str ]
  # Returns the record of the ipv6 as a list
  mkIPv6RecordAux =
    v6:
    let
      v6' =
        if lib.hasPrefix "::" v6 then
          "0${v6}"
        else if lib.hasSuffix "::" v6 then
          "${v6}0"
        else
          v6;
      splitted = splitString ":" v6';
      missing_count = 8 - builtins.length (lib.filter (x: x != "") splitted);

      # : int -> str -> str
      # Expands "" to 4n zeros and aligns the rest on 4 bytes
      pad_to_hex_or_expand = n: v: if v == "" then (lib.fixedWidthString (4 * n) "0" "") else lib.fixedWidthString 4 "0" v;
    in
    lib.pipe splitted [
      (lib.concatMapStrings (pad_to_hex_or_expand missing_count))
      lib.stringToCharacters
    ];

  # : str -> str
  # Returns the reversed record of the ipv6
  mkIPv6ReverseRecord =
    v6:
    lib.pipe v6 [
      mkIPv6RecordAux
      reverseList
      (concatStringsSep ".")
      (s: s + ".ip6.arpa")
    ];

  # : [ str ] -> str
  # Reverse the list then concat with sep "."
  reverse_concat_octets = octets: concatStringsSep "." (reverseList octets);

  # : str -> str
  # Returns the reversed record of the ipv4
  mkIPv4ReverseRecord =
    v4:
    lib.pipe v4 [
      (splitString ".")
      reverse_concat_octets
      (s: s + ".in-addr.arpa")
    ];

  # : str -> [ str str]
  # Returns the reversed origin prefix and host octets
  mkIPv4ReverseRecord' =
    depth: v4:
    let
      reverse_octets = splitString "." v4;
    in
    [
      (reverse_concat_octets (lib.drop depth reverse_octets)) # host octets
      (reverse_concat_octets (lib.take depth reverse_octets)) # prefix
    ];
in
{
  inherit
    writeCharacterString
    mkIPv4ReverseRecord
    mkIPv4ReverseRecord'
    mkIPv6ReverseRecord
    ;
}
