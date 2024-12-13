# draft-ietf-dnsop-svcb-https-08

{ lib }:

let
  inherit (lib) dns mkOption types;
  inherit (builtins) attrNames;
  listToStringComma = lib.concatStringsSep ",";
  optionalListToStringComma = v: if v == null then null else listToStringComma v;
  optionalOption = name: value: if value == null then "" else "${name}=${value}";
  optionalBool = name: value: if value then "${name}" else "";
  optionalInt = name: value: toString (optionalOption name value);
  optionalList = name: value: optionalOption name (optionalListToStringComma value);
in
rec {
  rtype = "SVCB";
  options = {
    svcPriority = mkOption {
      example = 1;
      type = types.int;
    };
    targetName = mkOption {
      example = ".";
      type = types.str;
    };
    mandatory = mkOption {
      example = [ "ipv4hint" ];
      default = null;
      type = types.nullOr (types.listOf types.str);
    };
    alpn = mkOption {
      example = [ "h2" ];
      default = null;
      type = types.nullOr (types.listOf types.str);
    };
    no-default-alpn = mkOption {
      example = true;
      default = false;
      type = types.bool;
    };
    port = mkOption {
      example = 443;
      default = null;
      type = types.nullOr types.int;
    };
    ipv4hint = mkOption {
      example = [ "127.0.0.1" ];
      default = null;
      type = types.nullOr (types.listOf types.str);
    };
    ipv6hint = mkOption {
      example = [ "::1" ];
      default = null;
      type = types.nullOr (types.listOf types.str);
    };
    ech = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };
  dataToString = { svcPriority, targetName, mandatory ? null, alpn ? null, no-default-alpn ? null, port ? null, ipv4hint ? null, ipv6hint ? null, ech ? null, ... }:
    "${toString svcPriority} ${targetName} ${optionalList "mandatory" mandatory} ${optionalList "alpn" alpn} ${optionalBool "no-default-alpn" no-default-alpn} ${optionalInt "port" port} ${optionalList "ipv4hint" ipv4hint} ${optionalList "ipv6hint" ipv6hint} ${optionalOption "ech" ech}";
}
