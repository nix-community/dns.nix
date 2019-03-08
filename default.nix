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
      SOA = {
        nameServer = "ns.test.com";
        adminEmail = "admin@test.com";
        serial = 2019030800;
      };

      NS = [
        { nsdname = "ns.test.com"; }
        { nsdname = "ns2.test.com"; }
      ];

      A = [
        { address = "1.1.1.1"; ttl = 60 * 60; }
        { address = "1.0.0.1"; ttl = 60 * 60; }
      ];

      CAA = [
        { issuerCritical = false;
          tag = "issue";
          value = "letsencrypt.org";
        }
        { issuerCritical = false;
          tag = "issuewild";
          value = ";";
        }
        { issuerCritical = false;
          tag = "iodef";
          value = "mailto:admin@example.com";
        }
      ];
    };
  };

  testConfig = (lib.evalModules {
    modules = [
      (module // { config = { zones = testZones; }; })
    ];
  }).config;
in

dns.mkZone "test.com" (testConfig.zones."test.com")
