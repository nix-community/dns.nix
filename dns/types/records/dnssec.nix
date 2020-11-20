# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: MIT

{ pkgs }:
let
  inherit (builtins) attrNames isInt removeAttrs;
  inherit (pkgs.lib) mkOption types;
in
rec {
  mkRegisteredNumberOption = { registryName, numberType, mnemonics }@args:
    mkOption
      {
        type = types.either numberType (types.enum (attrNames mnemonics)) // {
          name = "registeredNumber";
          description = "number in IANA registry '${registryName}'";
        };
        apply = value: if isInt value then value else mnemonics.${value};
      } // removeAttrs args [ "registryName" "numberType" "mnemonics" ];

  mkDNSSECAlgorithmOption = { ... }@args: mkRegisteredNumberOption {
    registryName = "Domain Name System Security (DNSSEC) Algorithm Numbers";
    numberType = types.ints.u8;
    mnemonics = {
      "dsa" = 3;
      "rsasha1" = 5;
      "dsa-nsec3-sha1" = 6;
      "rsasha1-nsec3-sha1" = 7;
      "rsasha256" = 8;
      "rsasha512" = 10;
      "ecc-gost" = 12;
      "ecdsap256sha256" = 13;
      "ecdsap384sha384" = 14;
      "ed25519" = 15;
      "ed448" = 16;
      "privatedns" = 253;
      "privateoid" = 254;
    };
  };
}
