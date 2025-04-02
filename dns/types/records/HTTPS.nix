args@{lib, ...}: import ./SVCB.nix args // {
  rtype = "HTTPS";
  nameFixup = name: self: if self.port == 443 then name else "_${self.port}._https.${name}";
}
