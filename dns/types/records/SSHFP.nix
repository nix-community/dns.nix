# RFC 4255

{ lib }:

let
  inherit (lib) dns mkOption types;
  inherit (builtins) attrNames;
  algorithm = {
    "rsa" = 1;
    "dsa" = 2;
    "ecdsa" = 3; # RFC 6594
    "ed25519" = 4; # RFC 7479 / RFC 8709
    "ed448" = 6; # RFC 8709
  };
  mode = {
    "sha1" = 1;
    "sha256" = 2; # RFC 6594
  };
in

{
  rtype = "SSHFP";
  options = {
    algorithm = mkOption {
      example = "ed25519";
      type = types.enum (attrNames algorithm);
      apply = value: algorithm.${value};
    };
    mode = mkOption {
      example = "sha256";
      type = types.enum (attrNames mode);
      apply = value: mode.${value};
    };
    fingerprint = mkOption {
      type = types.str;
    };
  };
  dataToString = { algorithm, mode, fingerprint, ... }:
    "${toString algorithm} ${toString mode} ${fingerprint}";
}
