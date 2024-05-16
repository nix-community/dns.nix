# RFC 6672

{ lib }:

let
  inherit (lib) dns mkOption;

in

{
  rtype = "DNAME";
  options = {
    dname = mkOption {
      type = dns.types.domain-name;
      example = "www.test.com";
      description = "A <domain-name> which provides redirection from a part of the DNS name tree to another part of the DNS name tree";
    };
  };
  dataToString = {dname, ...}: "${dname}";
  fromString = dname: { inherit dname; };
}
