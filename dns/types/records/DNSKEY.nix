# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: MIT

{ lib }:
let
  inherit (builtins) isInt split;
  inherit (lib) concatStrings flatten mkOption types;

  dnssecOptions = import ./dnssec.nix { inherit lib; };
  inherit (dnssecOptions) mkDNSSECAlgorithmOption;
in
{
  rtype = "DNSKEY";
  options = {
    flags = mkOption {
      description = "Flags pertaining to this RR.";
      type = types.either types.ints.u16 (types.submodule {
        options = {
          zoneSigningKey = mkOption {
            description = "Whether this RR holds a zone signing key (ZSK).";
            type = types.bool;
            default = false;
          };
          secureEntryPoint = mkOption {
            type = types.bool;
            description = ''
              Whether this RR holds a secure entry point.
              In general, this means the key is a key-signing key (KSK), as opposed to a zone-signing key.
            '';
            default = false;
          };
        };
      });
      apply = value:
        if isInt value
        then value
        else
          (if value.zoneSigningKey then 256 else 0)
          + (if value.secureEntryPoint then 1 else 0);
    };
    algorithm = mkDNSSECAlgorithmOption {
      description = "Algorithm of the key referenced by this RR.";
    };
    publicKey = mkOption {
      type = types.str;
      description = "Base64-encoded public key.";
      apply = value: concatStrings (flatten (split "[[:space:]]" value));
    };
  };
  dataToString = { flags, algorithm, publicKey, ... }:
    "${toString flags} 3 ${toString algorithm} ${publicKey}";
}
