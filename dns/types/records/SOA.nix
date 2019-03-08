#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs.lib) concatStringsSep replaceStrings;
  inherit (pkgs.lib) mkOption types;

in

{
  rtype = "SOA";
  options = {
    nameServer = mkOption {
      type = types.str;
      example = "ns1.example.com";
      description = "The <domain-name> of the name server that was the original or primary source of data for this zone";
    };
    adminEmail = mkOption {
      type = types.str;
      example = "admin@example.com";
      description = "An email address of the person responsible for this zone. (Note: in traditional zone files you are supposed to put a dot instead of `@` in your address; you can use `@` with this module and it is recommended to do so.)";
      apply = replaceStrings ["@"] ["."];
    };
    serial = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      example = 20;
      description = "Version number of the original copy of the zone";
    };
    refresh = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      default = 24 * 60 * 60;
      example = 7200;
      description = "Time interval before the zone should be refreshed";
    };
    retry = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      default = 10 * 60;
      example = 600;
      description = "Time interval that should elapse before a failed refresh should be retried";
    };
    expire = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      default = 10 * 24 * 60 * 60;
      example = 3600000;
      description = "Time value that specifies the upper limit on the time interval that can elapse before the zone is no longer authoritative";
    };
    minimum = mkOption {
      type = types.ints.unsigned;  # TODO: u32
      default = 60;
      example = 60;
      description = "Minimum TTL field that should be exported with any RR from this zone";
    };
  };
  dataToString = data@{nameServer, adminEmail, ...}:
    let
      numbers = map toString (with data; [serial refresh retry expire minimum]);
    in "${nameServer}. ${adminEmail}. (${concatStringsSep " " numbers})";
}
