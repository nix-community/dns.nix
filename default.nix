#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) lib;
  dns = import ./dns { inherit pkgs; };

  module = {
    options = {
      zones = lib.mkOption {
        type = lib.types.attrsOf dns.types.zone;
        default = {};
        description = "DNS zones";
      };
    };
  };

  testZones = {
    "test.com" = {
      soa = {
        nameServer = "ns.test.com";
        adminEmail = "admin@test.com";
        serial = 2019030800;
      };
    };
  };

  testConfig = (lib.evalModules {
    modules = [
      (module // { config = { zones = testZones; }; })
    ];
  }).config;
in

dns.mkZone "test.com" (testConfig.zones."test.com")
