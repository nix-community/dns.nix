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
      splitted' = lib.splitString "::" v6;

      splitted = map (
        part:
        lib.pipe part [
          (lib.splitString ":")
          (map (lib.fixedWidthString 4 "0"))
        ]
      ) splitted';

      zero_part =
        let
          missing_count = 8 - (lib.foldl' (acc: part: acc + builtins.length part) 0 splitted);
        in
        lib.fixedWidthString (4 * missing_count) "0" "";
    in
    lib.take 32 (lib.concatMap lib.stringToCharacters (builtins.head splitted ++ [ zero_part ] ++ lib.last splitted));

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
