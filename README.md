_Nix DSL for defining DNS zones_

nix-dns
========

This repository provies:

1. NixOS-style module definitions that describe DNS zones.
2. A DSL to make building DNS zones easier.


Example
--------

```nix
with dns.combinators; {
  SOA = {  # Human readable names for fields
    nameServer = "ns.test.com";
    adminEmail = "admin@test.com";  # Email address with real `@`!
    serial = 2019030800;
    # Sane defaults for the remaining ones
  };

  NS = map ns [  # Why not `map` over your records?
    "ns.test.com"
    "ns2.test.com"
  ];

  A = [
    { address = "203.0.113.1"; }  # Generic A record
    { address = "203.0.113.2"; ttl = 60 * 60; }  # Generic A with TTL
    (a "203.0.113.3")  # Simple a record create with the `a` combinator
    (ttl (60 * 60) (a "203.0.113.4"))  # Equivalent to the second one
  ];

  AAAA = [
    (aaaa "4321:0:1:2:3:4:567:89ab")
  ];

  CAA = letsEncrypt "admin@example.com";  # Common template combinators included

  TXT = [
    (with spf; strict [google])  # SPF: only allow gmail
  ];

  subdomains = {
    www = {
      A = [ (a "203.0.114.1") ];
    };
    staging = delegateTo [  # Another shortcut combinator
      "ns1.another.com"
      "ns2.another.com"
    ];
  };
}
```

You will find an actual zone definition in `example.nix` and you can build it
with `nix-build example.nix`.
