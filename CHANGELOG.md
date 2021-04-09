<!--
SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Changed

- Options that correspond to domain names are now limited to 255 characters
  (as required by the standard). This change is not breaking, since,
  even though the restriction was not represented in option types,
  using a longer string would not work anyway.
- Fix: character-string data of arbitrary length is now correctly split
  into string literals each of which is no longer than 255 characters,
  as required by the zone file format specification.


## [1.0.0]

This is the first real release of this project, all the previous
versions were considered “beta”. So no detailed changelog is provided.

### Changed

- The project is now called `dns.nix` (was: `nix-dns`).


[Unreleased]: https://github.com/kirelagin/dns.nix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kirelagin/dns.nix/releases/tag/v1.0.0
