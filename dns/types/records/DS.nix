# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: MPL-2.0 or MIT

# RFC 4034, 5

{ lib }:

let
  inherit (lib) mkOption types;

  dnssecOptions = import ./dnssec.nix { inherit lib; };
  inherit (dnssecOptions) mkRegisteredNumberOption mkDNSSECAlgorithmOption;

  mkDSDigestTypeOption = { ... }@args: mkRegisteredNumberOption {
    registryName = "Delegation Signer (DS) Resource Record (RR) Type Digest Algorithms";
    numberType = types.ints.u8;
    # These mnemonics are unofficial, unlike the DNSSEC algorithm ones.
    mnemonics = {
      "sha-1" = 1;
      "sha-256" = 2;
      "gost" = 3;
      "sha-384" = 4;
    };
  };
in
{
  rtype = "DS";
  options = {
    keyTag = mkOption {
      description = "Tag computed over the DNSKEY referenced by this RR to identify it.";
      type = types.ints.u16;
    };
    algorithm = mkDNSSECAlgorithmOption {
      description = "Algorithm of the key referenced by this RR.";
    };
    digestType = mkDSDigestTypeOption {
      description = "Type of the digest given in the `digest` attribute.";
    };
    digest = mkOption {
      description = "Digest of the DNSKEY referenced by this RR.";
      type = types.strMatching "[[:xdigit:]]+";
    };
  };
  dataToString = { keyTag, algorithm, digestType, digest, ... }:
    "${toString keyTag} ${toString algorithm} ${toString digestType} ${digest}";
}
