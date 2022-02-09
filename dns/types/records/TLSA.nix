# RFC 6698

{ lib }:

let
  inherit (lib) dns mkOption types;
  inherit (builtins) attrNames;

  certUsage = {
    "pkix-ta" = 0;
    "pkix-ee" = 1;
    "dane-ta" = 2;
    "dane-ee" = 3;
  };
  selectors = {
    "cert" = 0;
    "spki" = 1;
  };
  match = {
    "full" = 0;
    "sha256" = 1;
    "sha512" = 2;
  };
in
{
  rtype = "TLSA";
  options = {
    certUsage = mkOption {
      example = "dane-ee";
      type = types.enum (attrNames certUsage);
      apply = value: certUsage.${value};
    };
    selector = mkOption {
      example = "spki";
      type = types.enum (attrNames selectors);
      apply = value: selectors.${value};
    };
    match = mkOption {
      example = "sha256";
      type = types.enum (attrNames match);
      apply = value: match.${value};
    };
    certificate = mkOption {
      type = types.str;
    };
  };
  dataToString = { certUsage, selector, match, certificate, ... }:
    "${toString certUsage} ${toString selector} ${toString match} ${certificate}";
}
