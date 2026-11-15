{ config, private, ... }:

{
  # WEBUI_SECRET_KEY and OPENAI_API_KEY (the LM Studio token) as KEY=value lines
  sops.secrets.open-webui-env = { };

  services.open-webui = {
    enable = true;
    # The module's default of 127.0.0.1 would hide it from the LAN
    host = "0.0.0.0";
    port = private.openWebuiPort;
    openFirewall = true;
    environmentFile = config.sops.secrets.open-webui-env.path;
    environment = {
      # Setting environment replaces the module's defaults, so restate them
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
      ENABLE_VERSION_UPDATE_CHECK = "False";
      ENABLE_COMMUNITY_SHARING = "False";
      # Env vars win over the admin UI, so this file stays the source of truth
      ENABLE_PERSISTENT_CONFIG = "False";
      # The admin account exists; nobody else can register
      ENABLE_SIGNUP = "False";
      # The module defaults this to http://localhost:<port>
      WEBUI_URL = "https://open-webui.${private.domain}";
      # Models come from LM Studio on the Mac mini, not a local Ollama
      ENABLE_OLLAMA_API = "False";
      OPENAI_API_BASE_URL = "http://${private.macMiniIp}:${toString private.lmStudioPort}/v1";
      # Ask LM Studio for token counts, so each reply can show them
      DEFAULT_MODEL_METADATA = builtins.toJSON { capabilities.usage = true; };
    };
  };
}
