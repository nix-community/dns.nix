<!--
SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

dns.nix
========

_A Nix DSL for defining DNS zones_

This repository provides:

1. NixOS-style module definitions that describe DNS zones and records in them.
2. A DSL that simplifies describing your DNS zones.


## An example of a zone

```nix
with dns.lib.combinators; {
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

You can build an example zone in `example.nix` by running
`nix build -f ./example.nix` or `nix-build ./example.nix`.


## Why?

* The DNS zone syntax is crazy. Nix is nice and structured.
* Having the full power of a Turing-complete functional language
  (`let`, `if`, `map` and other things you are used to).
* All kinds of shortcuts and useful combinators.
* Strong typing provded by the NixOS module system.
* Modularity: records defined in different modules get magically merged.


## Use


### Importing

There are two ways to import `dns.nix`.

#### As a flake

Add it as an input to your flake:

```nix
# flake.nix

{
  inputs = {
    # ...

    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";  # (optionally)
    };
  };

  outputs = { self, nixpkgs, dns }: {
    # Most functions from `dns.nix` are available in `dns.lib`.
    # Functions that require `stdenv` (e.g. `writeZone`) are in
    # `dns.util.<system>`.
    # ...
  };
}
```

#### Importing directly (legacy)

Always get the latest version from GitHub:

```nix
let
  dns = import (builtins.fetchTarball "https://github.com/kirelagin/dns.nix/archive/master.zip");
in {
  # ...
}
```

To make your setup more reproducible, you should pin the version used by specifying
a commit hash or using a submodule. This is all a little clumsy and nowadays it
is probably best to simply switch to flakes.

### Basic use
Define a zone content:

```nix
# example.com.nix

{ dns }:

with dns.lib.combinators;

{
  SOA = {
    nameServer = "ns1";
    adminEmail = "admin@example.com";
    serial = 2019030800;
  };
  useOrigin = false; # default value, see comment below.
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

Then use `toString` to generate as a string.

``` nix
{ dns }:

  zoneAsString = dns.lib.toString "example.com" (import ./example.com.nix) { inherit dns; };
```


If `useOrigin=false`, the default value, serialization will use fully qualified name.
For instance, `A = [ "203.0.113.1" ]`will be serialized as `example.com. A 203.0.113.1`.

If `useOrigin=true`, `toString` adds `$ORIGIN example.com.` and use `@` as domain name.
`A = [ "203.0.113.1" ]`will be then serialized as 

``` dns-zone
$ORIGIN example.com.
@ A 203.0.113.1
```

### In your NixOS configuration

_There is a chance that in the future we will either integrate this into
existing NixOS modules for different DNS servers, or will provide a separate
NixOS module that will configure DNS servers for you._

These example assume `nsd`, but it should be pretty much the same for other daemons.

When your system is defined as a flake:

```nix

{

# Add `dns.nix` to `inputs` (see above).
# ...

# In `outputs`:

  nixosConfigurations.yourSystem = nixpkgs.lib.nixosSystem {

    # ...

    services.nsd = {
      enable = true;
      zones = {
        "example.com" = {
          # provideXFR = [ ... ];
          # notify = [ ... ];
          data = dns.lib.toString "example.com" (import ./example.com.nix { inherit dns; });
        };
      };
    };

  };

}
```

If your system configuration is not a flake, everything will be essentially
the same, you will just import it differently.


### In modules you develop

`dns.lib` provides the `types` attribute, which contains DNS-related
types to be used in the NixOS module system. Using them you can define
an option in your module such as this one:

```nix
# dns = ...

{

yourModule = {
  options = {
    # <...>

    zones = lib.mkOption {
      type = lib.types.attrsOf dns.lib.types.zone;
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
similar to the one above, and then evaluates it.

`dns.utils` provides `writeZone`, which is a helper function that additionally
calls `toString` and writes the resulting string to a file.


## Contributing

If you encounter any issues when using this library or have improvement ideas,
please open an issue on GitHub.

You are also very welcome to submit pull requests.

Please, note that in this repository we are making effort to track
the authorship information for all contributions.
In particular, we are following the [REUSE] practices.
The tl;dr is: please, add information about yourself to the headers of
each of the files that you edited if your change was _substantial_
(you get to judge what is substantial and what is not).

[REUSE]: https://reuse.software/


## License

[MPL-2.0] © [Kirill Elagin] and contributors (see headers in the files).

Additionally, all code in this repository is dual-licensed under the MIT license
for direct compatibility with nixpkgs.

[MPL-2.0]: https://spdx.org/licenses/MPL-2.0.html
[Kirill Elagin]: https://kir.elagin.me/
