#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

let
  dns = import ./. { };

  testZone = {
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

    subdomains = {
      www = {
        A = [ { address = "1.1.1.1"; } ];
      };
      staging = {
        A = [ { address = "1.0.0.1"; } ];
      };
    };
  };
in

dns.writeZone "test.com" testZone
