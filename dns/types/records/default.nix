#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

{ lib }:

let
  inherit (lib) genAttrs;

  types = [
    "A"
    "AAAA"
    "CAA"
    "CNAME"
    "DNAME"
    "MX"
    "NS"
    "SOA"
    "SRV"
    "TXT"
    "PTR"

    # DNSSEC types
    "DNSKEY"
    "DS"

    # Pseudo types
    "DKIM"
    "DMARC"
  ];

in

genAttrs types (t: import (./. + "/${t}.nix") { inherit lib; })
