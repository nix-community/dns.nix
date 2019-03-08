#
# © 2019 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT
#

{ pkgs }:

let
  inherit (pkgs.lib) mkOption types;

in

{
  rtype = "CAA";
  options = {
    issuerCritical = mkOption {
      type = types.bool;
      example = true;
      description = "If set to '1', indicates that the corresponding property tag MUST be understood if the semantics of the CAA record are to be correctly interpreted by an issuer";
    };
    tag = mkOption {
      type = types.enum ["issue" "issuewild" "iodef"];
      example = "issue";
      description = "One of the defined property tags";
    };
    value = mkOption {
      type = types.str;
      example = "ca.example.net";
      description = "Value of the property";
    };
  };
  dataToString = {issuerCritical, tag, value, ...}:
    ''${if issuerCritical then "1" else "0"} ${tag} "${value}"'';
}
