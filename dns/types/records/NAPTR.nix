# RFC 3403
{ lib }:

let
  inherit (builtins) stringLength match;
  inherit (lib) dns mkOption types;

  characterString = types.addCheck types.str (s: stringLength s <= 255);
  flagsString = types.addCheck characterString (s: match "[A-Za-z0-9]*" s != null);
in
{
  rtype = "NAPTR";

  options = {
    order = mkOption {
      type = types.ints.u16;
      example = 100;
      description = "The order in which NAPTR records are processed; lower values are processed first";
    };

    preference = mkOption {
      type = types.ints.u16;
      example = 10;
      description = "The preference among NAPTR records with the same order; lower values are processed first";
    };

    flags = mkOption {
      type = flagsString;
      default = "";
      example = "u";
      description = "NAPTR flags";
    };

    services = mkOption {
      type = characterString;
      default = "";
      example = "sip+E2U";
      description = "NAPTR service parameters";
    };

    regexp = mkOption {
      type = characterString;
      default = "";
      example = "!^.*$!sip:information@example.com!i";
      description = "NAPTR substitution expression";
    };

    replacement = mkOption {
      type = dns.types.domain-name;
      default = ".";
      example = "example.com.";
      description = "NAPTR replacement domain name. This should be a fully-qualified domain name, or '.' when regexp is used";
    };
  };

  dataToString =
    {
      order,
      preference,
      flags,
      services,
      regexp,
      replacement,
      ...
    }:
    if regexp != "" && replacement != "." then
      throw "NAPTR: regexp and replacement are mutually exclusive; use replacement = \".\" when regexp is set"
    else
      lib.concatStringsSep " " [
        (toString order)
        (toString preference)
        (dns.util.writeCharacterString flags)
        (dns.util.writeCharacterString services)
        (dns.util.writeCharacterString regexp)
        replacement
      ];
}
