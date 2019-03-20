_Nix DSL for defining DNS zones_

nix-dns
========

This repository provides:

1. NixOS-style module definitions that describe DNS zones and records in them
2. A DSL that simplifies describing your DNS zones


Example of a zone
------------------

```nix
# dns = import path/to/nix-dns;

with dns.combinators; {
  SOA = {  # Human readable names for fields
    nameServer = "ns.test.com.";
    adminEmail = "admin@test.com";  # Email address with a real `@`!
    serial = 2019030800;
    # Sane defaults for the remaining ones
  };

  NS = [  # A zone consists of lists of records grouped by type
    "ns.test.com."
    "ns2.test.com."
  ];

  A = [
    { address = "203.0.113.1"; }  # Generic A record
    { address = "203.0.113.2"; ttl = 60 * 60; }  # Generic A with TTL
    (a "203.0.113.3")  # Simple a record created with the `a` combinator
    (ttl (60 * 60) (a "203.0.113.4"))  # Equivalent to the second one
  ];

  AAAA = [
    "4321:0:1:2:3:4:567:89ab"  # For simple records you can use a plain string
  ];

  CAA = letsEncrypt "admin@example.com";  # Common template combinators included

  MX = mx.google;  # G Suite mail servers;

  TXT = [
    (with spf; strict [google])  # SPF: only allow gmail
  ];

  subdomains = {
    www.A = [ "203.0.114.1" ];

    staging = delegateTo [  # Another shortcut combinator
      "ns1.another.com."
      "ns2.another.com."
    ];
  };
}
```

You can build an example zone in `example.nix` by running `nix-build example.nix`.


Why?
-----

* DNS zone syntax is crazy. Nix is nice and structured.
* Full power of a Turing-complete functional language
  (`let`, `if`, `map` and other things you are used to).
* Strong typing provded by the NixOS module system.
* All kinds of shortcuts and useful combinators.


Use
----

### In your NixOS configuration

_There is a chance that in the future we will either integrate this into
existing NixOS modules for different DNS servers, or will provide a separate
NixOS module that will configure DNS servers for you._

This example assumes `nsd`, but it should be pretty much the same for other daemons.

```nix
# /etc/nixos/configuration.nix

{

services.nsd = {
  enable = true;
  zones =
    let
      dns = import (builtins.fetchTarball {
        url = "https://github.com/kirelagin/nix-dns/archive/v0.3.1.tar.gz";
        sha256 = "1ykmx6b7al1sh397spnpqis7c9bp0yfmgxxp3v3j7qq45fa5fs09";
      });
    in {
      "example.com" = {
        # provideXFR = [ ... ];
        # notify = [ ... ];
        data = dns.toString "example.com" (import ./dns/example.com { inherit dns; });
      };
    };
};

}
```

```nix
# /etc/nixos/dns/example.com

{ dns }:

with dns.combinators;

{
  SOA = {
    nameServer = "ns1";
    adminEmail = "admin@example.com";
    serial = 2019030800;
  };

  NS = [
    "ns1.example.com."
    "ns2.example.com."
  ];

  A = [ "203.0.113.1" ];
  AAAA = [ "4321:0:1:2:3:4:567:89ab" ];

  subdomains = rec {
    foobar = host "203.0.113.2" "4321:0:1:2:3:4:567:89bb";

    ns1 = foobar;
    ns2 = host "203.0.113.3" "4321:0:1:2:3:4:567:89cc";
  };
}
```

### In modules you develop

`dns/default.nix` exports the `types` attribute, which contains DNS-related
types to be used in the NixOS module system. Using them you can define
an option in your module such as this one:

```nix
# dns = import path/to/nix-dns/dns { inherit pkgs; };

{

yourModule = {
  options = {
    # <...>

    zones = lib.mkOption {
      type = lib.types.attrsOf dns.types.zone;
      description = "DNS zones";
    };
  };

  config = {
    # You can call `toString` on a zone from the `zones` attrset and get
    # a string suitable, for example, for writing with `writeTextFile`.
  };
};

}
```

As another example, take a look at the `evalZone` function in `dns/default.nix`,
which takes a name for a zone and a zone definition, defines a “fake” module
similar to the one above, and then evaluates it. `writeZone` is a helper function
that additionally calls `toString` and writes the resulting string to a file.
