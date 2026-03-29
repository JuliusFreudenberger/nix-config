{
  ...
}: {
  services.opkssh = {
    enable = true;
    providers = {
      pocket-id = {
        issuer = "https://example.com";
        clientId = "";
        lifetime = "12h";
      };
    };
    authorizations = [
      { user = "<username>"; principal = "<email>"; issuer = "https://example.com"; }
    ];
  };
}

