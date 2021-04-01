#
# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MIT
#

# This is a “fake” record type, not actually part of DNS.
# It gets compiled down to a TXT record.

{ lib }:

let
  inherit (lib) mkOption types;

in

rec {
  rtype = "TXT";
  options = {
    selector = mkOption {
      type = types.str;
      example = "mail";
      description = "DKIM selector name";
    };
    h = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["sha1" "sha256"];
      description = "Acceptable hash algorithms. Empty means all of them";
      apply = lib.concatStringsSep ":";
    };
    k = mkOption {
      type = types.nullOr types.str;
      default = "rsa";
      example = "rsa";
      description = "Key type";
    };
    n = mkOption {
      type = types.str;
      default = "";
      example = "Just any kind of arbitrary notes.";
      description = "Notes that might be of interest to a human";
    };
    p = mkOption {
      type = types.str;
      example = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDwIRP/UC3SBsEmGqZ9ZJW3/DkMoGeLnQg1fWn7/zYtIxN2SnFCjxOCKG9v3b4jYfcTNh5ijSsq631uBItLa7od+v/RtdC2UzJ1lWT947qR+Rcac2gbto/NMqJ0fzfVjH4OuKhitdY9tf6mcwGjaNBcWToIMmPSPDdQPNUYckcQ2QIDAQAB";
      description = "Public-key data (base64)";
    };
    s = mkOption {
      type = types.listOf (types.enum ["*" "email"]);
      default = ["*"];
      example = ["email"];
      description = "Service Type";
      apply = lib.concatStringsSep ":";
    };
    t = mkOption {
      type = types.listOf (types.enum ["y" "s"]);
      default = [];
      example = ["y"];
      description = "Flags";
      apply = lib.concatStringsSep ":";
    };
  };
  dataToString = data:
    let
      items = ["v=DKIM1"] ++ lib.pipe data [
        (builtins.intersectAttrs options)  # remove garbage list `_module`
        (lib.filterAttrs (_k: v: v != null && v != ""))
        (lib.filterAttrs (k: _v: k != "selector"))
        (lib.mapAttrsToList (k: v: "${k}=${v}"))
      ];
    in ''"${lib.concatStringsSep "; " items + ";"}"'';
  nameFixup = name: self:
    "${self.selector}._domainkey.${name}";
}
