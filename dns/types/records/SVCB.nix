# rfc9460

{ lib }:

let
  inherit (lib)
    concatStringsSep
    dns
    filter
    isInt
    isList
    mapAttrsToList
    mkEnableOption
    mkOption
    types
    ;

  mkSvcParams = params: concatStringsSep " " (
    filter (s: s != "") (
      mapAttrsToList (
        name: value:
        if value == true then
          name
        else if isList value then
          "${name}=${concatStringsSep "," value}"
        else if isInt value then
          "${name}=${builtins.toString value}"
        else
          ""
      ) params
    )
  );
in
{
  rtype = "SVCB";
  options = {
    svcPriority = mkOption {
      example = 1;
      type = types.ints.u16;
    };
    targetName = mkOption {
      example = ".";
      type = types.str;
    };
    mandatory = mkOption {
      example = [ "ipv4hint" ];
      default = null;
      type = types.nullOr (types.nonEmptyListOf types.str);
    };
    alpn = mkOption {
      example = [ "h2" ];
      default = null;
      type = types.nullOr (types.nonEmptyListOf types.str);
    };
    no-default-alpn = mkOption {
      example = true;
      default = false;
      type = types.bool;
    };
    port = mkOption {
      example = 443;
      default = null;
      type = types.nullOr types.port;
    };
    ipv4hint = mkOption {
      example = [ "127.0.0.1" ];
      default = null;
      type = types.nullOr (types.nonEmptyListOf types.str);
    };
    ipv6hint = mkOption {
      example = [ "::1" ];
      default = null;
      type = types.nullOr (types.nonEmptyListOf types.str);
    };
    ech = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    dohpath = mkOption {
      example = "/dns-query{?dns}";
      type = types.nullOr types.str;
      default = null;
    };
    tls-supported-groups = mkOption {
      example = [ 23 29 ];
      default = null;
      type = types.nullOr (types.nonEmptyListOf types.int.u16);
    };
    ohttp = mkOption {
      example = true;
      default = false;
      type = types.bool;
    };

    # For when the AttrLeaf convention is required
    nodeServiceName = mkOption {
      example = "_8443._https"
      description = "If the protocol requires the underscored node name prefix specified in RFC 8552, the node name to use";
      type = types.nullOr types.strMatching "^_(.+)";
      default = null;
    };
  };
  dataToString = { svcPriority, targetName, mandatory ? null, alpn ? null, no-default-alpn ? null, port ? null, ipv4hint ? null, ipv6hint ? null, ech ? null, ... }:
"${toString svcPriority} ${targetName} ${
  mkSvcParams {
    inherit
      alpn
      ech
      ipv4hint
      ipv6hint
      mandatory
      no-default-alpn
      port
      dohpath
      tls-supported-groups
      ohttp
      ;
  }
}";
  nameFixup = lib.mkIf (self.nodeServiceName != null) 
    (name: self:
      "${self.nodeServiceName}.${name}");
}
