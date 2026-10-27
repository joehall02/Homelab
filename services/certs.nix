{ config, private, ... }:

{
  # Porkbun API keys as KEY=value lines, read by lego
  sops.secrets.porkbun-acme = { };

  # One wildcard certificate from Let's Encrypt for every service.
  # Ownership is proven with a temporary _acme-challenge TXT record created
  # through the Porkbun API, so no inbound ports are needed.
  # Caddy's module gives itself read access and reloads on renewal.
  security.acme = {
    acceptTerms = true;
    certs.${private.domain} = {
      extraDomainNames = [ "*.${private.domain}" ];
      dnsProvider = "porkbun";
      environmentFile = config.sops.secrets.porkbun-acme.path;
    };
  };
}
