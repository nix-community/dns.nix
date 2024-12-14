# RFC 9460

{ lib }:

let
  inherit (lib) dns mkOption types;
  mkSvcValue = value: if (lib.isList value) then (lib.concatStringsSep "," value) else (toString value);
  mkSvcParam = key: value: lib.optionalString (value != null) (if lib.isBool value then
    lib.optionalString value key
  else
    "${key}=${mkSvcValue value}");
  mkSvcParams = params: lib.concatStringsSep " " (lib.mapAttrsToList mkSvcParam params);
in
{
  rtype = "HTTPS";
  options = {
    priority = mkOption {
      type = types.ints.u16;
      default = 1;
      description = "The priority of this record, a value of 0 indicates AliasMode";
    };
    target = mkOption {
      type = dns.types.domain-name;
      default = ".";
      description = "The domain name of either the alias target or the alternative endpoint";
    };
    alpn = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "The set of ALPN and associated transport protocols supported by this service endpoint";
    };
    ech = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "base64 encoded ECHConfigList. Do not use escape sequences!";
    };
    no-default-alpn = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the target does not support the default ALPN value (HTTP 1.1)";
    };
    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "The TCP or UDP port that should be used to reach this alternative endpoint";
    };
    ipv4hint = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "IPv4 addresses that clients MAY use to reach the service";
    };
    ipv6hint = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "IPv6 addresses that clients MAY use to reach the service";
    };
  };
  dataToString = data: with data;
    "${toString priority} ${target} ${mkSvcParams { inherit no-default-alpn alpn ech port ipv4hint ipv6hint; }}";
}
