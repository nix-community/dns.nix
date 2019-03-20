#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (builtins) map;
  inherit (pkgs) lib;

in

rec {

#
# Simple records
#

a = address: { inherit address; };
aaaa = address: { inherit address; };
cname = cname: { inherit cname; };
ns = nsdname: { inherit nsdname; };
txt = data: { inherit data; };


#
# Modifiers
#

ttl = ttl: record: record // { inherit ttl; };


#
# Templates/shortcuts
#

host = ipv4: ipv6:
  lib.optionalAttrs (ipv4 != null) { A = [ipv4]; } //
  lib.optionalAttrs (ipv6 != null) { AAAA = [ipv6]; };

delegateTo = nameservers: {
  NS = map ns nameservers;
};

mx = rec {
  mx = preference: exchange: { inherit preference exchange; };

  google = map (ttl 3600) [
    (mx 1  "aspmx.l.google.com.")
    (mx 5  "alt1.aspmx.l.google.com.")
    (mx 5  "alt2.aspmx.l.google.com.")
    (mx 10 "alt3.aspmx.l.google.com.")
    (mx 10 "alt4.aspmx.l.google.com.")
  ];
};

letsEncrypt = email: [
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
    value = "mailto:${email}";
  }
];

spf =
  let
    toSpf = rs:
      txt (lib.concatStringsSep " " (["v=spf1"] ++ rs));
  in {
    soft = rs: toSpf (rs ++ ["~all"]);
    strict = rs: toSpf (rs ++ ["-all"]);

    google = "include:_spf.google.com";
  };

}
