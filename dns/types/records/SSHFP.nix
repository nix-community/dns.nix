#
# SPDX-FileCopyrightText: 2023 Kloenk <https://kloenk.eu/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 4255

{ lib }:

let
  inherit (lib) dns mkOption types;

  algorithms = {
    "RSA" = 1;
    "DSA" = 2;
    "ECDSA" = 3;
    "ED25519" = 4;
    "ED448" = 6;
  };

  hash_types = {
    "SHA-1" = 1;
    "SHA-256" = 2;
  };
in

{
  rtype = "SSHFP";
  options = {
    algorithm = mkOption {
      type = types.enum (builtins.attrNames algorithms);
      example = "ED25519";
      description = "Describes the algorithm of the public key";
    };
    type = mkOption {
      type = types.enum (builtins.attrNames hash_types);
      example = "SHA-256";
      description = "Algorithm used to hash the public key";
    };
    fingerprint = mkOption {
      type = types.str;
      example = "";
      description = "Hexadecimal representation of the hash result, as text";
    };
  };
  dataToString = {algorithm, type, fingerprint, ...}:
    "${toString algorithms.${algorithm}} ${toString hash_types.${type}} ${fingerprint}";
}
