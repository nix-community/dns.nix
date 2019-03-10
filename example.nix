#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

let
  dns = import ./. { };

  testZone = with dns.combinators; {
    SOA = {
      nameServer = "ns.test.com.";
      adminEmail = "admin@test.com";
      serial = 2019030800;
    };

    NS = map ns [
      "ns.test.com."
      "ns2.test.com."
    ];

    A = [
      { address = "203.0.113.1"; ttl = 60 * 60; }
      (a "203.0.113.2")
      (ttl (60 * 60) (a "203.0.113.3"))
    ];

    AAAA = [
      (aaaa "4321:0:1:2:3:4:567:89ab")
    ];

    MX = mx.google;

    TXT = [
      (with spf; strict ["a:mail.example.com" google])
    ];

    CAA = letsEncrypt "admin@example.com";

    SRV = [
      { service = "sip";
        proto = "tcp";
        port = 5060;
        target = "sip.example.com";
      }
    ];

    subdomains = {
      www = {
        A = map a [ "203.0.113.4" ];
      };
      staging = delegateTo [
        "ns1.another.com."
        "ns2.another.com."
      ];
      foo.subdomains.www.CNAME = map cname [ "foo.test.com" ];
    };
  };
in

dns.writeZone "test.com" testZone
