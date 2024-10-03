#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

let
  dns = import ./.;
  util = dns.util.${builtins.currentSystem};

  testZone = with dns.lib.combinators; {
    SOA = {
      nameServer = "ns.test.com.";
      adminEmail = "admin@test.com";
      serial = 2019030800;
    };

    NS = [
      "ns.test.com."
      "ns2.test.com."
    ];

    A = [
      { address = "203.0.113.1"; ttl = 60 * 60; }
      "203.0.113.2"
      (ttl (60 * 60) (a "203.0.113.3"))
    ];

    AAAA = [
      "4321:0:1:2:3:4:567:89ab"
    ];

    MX = mx.google;

    TXT = [
      (with spf; strict [ "a:mail.example.com" google ])
    ];

    DMARC = [ (dmarc.postmarkapp "mailto:re+abcdefghijk@dmarc.postmarkapp.com") ];

    CAA = letsEncrypt "admin@example.com";

    SRV = [
      {
        service = "sip";
        proto = "tcp";
        port = 5060;
        target = "sip.example.com";
      }
    ];

    SSHFP = [
      {
        algorithm = "ed25519";
        mode = "sha256";
        fingerprint = "899EB4AC9285578AFDA3CCBE152EE78D8618B8F3862FEF2703E1FC7011E9B8AA";
      }
    ];
    OPENPGPKEY = [
      "very long base64 text"
    ];
    HTTPS = [
      {
        svcPriority = 1;
        targetName = ".";
        alpn = [ "http/1.1" "h2" "h3" ];
        ipv4hint = [ "203.0.113.1" "203.0.113.2" "203.0.113.3" ];
        ipv6hint = [ "4321:0:1:2:3:4:567:89ab" ];
      }
    ];
    TLSA = [
      {
        certUsage = "dane-ee";
        selector = "spki";
        match = "sha256";
        certificate = "899EB4AC9285578AFDA3CCBE152EE78D8618B8F3862FEF2703E1FC7011E9B8AA";
      }
    ];

    subdomains = rec {
      www.A = [ "203.0.113.4" ];
      www2 = host "203.0.113.5" "4321:0:1:2:3:4:567:89bb";
      www3 = host "203.0.113.6" null;
      www4 = www3;

      staging = delegateTo [
        "ns1.another.com."
        "ns2.another.com."
      ];

      foo.subdomains.www.CNAME = [ "foo.test.com." ];
    };
  };
in

util.writeZone "test.com" testZone
