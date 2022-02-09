# RFC7929

{ lib }:

let
  inherit (lib) dns mkOption types;

in

{
  rtype = "OPENPGPKEY";
  options = {
    data = mkOption {
      type = types.str;
    };
  };

  dataToString = { data, ... }: dns.util.writeCharacterString data;
  fromString = data: { inherit data; };
}
