{ config, private, ... }:

let
  # SearXNG can be switched in or out of the VPN namespace (searxng.nix)
  searxngHost =
    if config.systemd.services.searx.vpnConfinement.enable then
      config.vpnNamespaces.vpn.namespaceAddress
    else
      "127.0.0.1";
in
{
  # WEBUI_SECRET_KEY, OPENAI_API_KEY (the LM Studio token) and
  # AUDIO_TTS_OPENAI_API_KEY (the Kokoro key) as KEY=value lines
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
      # Every model: show token counts, allow web search and the code
      # interpreter, and start each new chat with both switched on
      DEFAULT_MODEL_METADATA = builtins.toJSON {
        capabilities = {
          usage = true;
          web_search = true;
          code_interpreter = true;
        };
        defaultFeatureIds = [
          "web_search"
          "code_interpreter"
        ];
        # No ask_user: the voice screen can't show its questions, so calls hang
        builtinTools.user_input = false;
      };
      # Python runs in the browser with Pyodide, so code costs neither this
      # machine nor the Mac anything
      ENABLE_CODE_INTERPRETER = "True";
      CODE_INTERPRETER_ENGINE = "pyodide";
      # Speech to text with local Whisper on this machine, so recordings never
      # leave the homelab
      AUDIO_STT_ENGINE = "";
      WHISPER_MODEL = "base.en";
      # Text to speech with Kokoro on the Mac (in Docker), through its
      # OpenAI-compatible API. Devices only download the finished audio
      AUDIO_TTS_ENGINE = "openai";
      AUDIO_TTS_OPENAI_API_BASE_URL = "http://${private.macMiniIp}:${toString private.kokoroPort}/v1";
      AUDIO_TTS_MODEL = "kokoro";
      # Default voice; each user can pick another in Settings › Audio
      AUDIO_TTS_VOICE = "bf_emma";
      # Speak each sentence as soon as it's written, rather than waiting for
      # the whole reply
      AUDIO_TTS_SPLIT_ON = "punctuation";
      # No suggested follow-up questions after each reply: saves an extra
      # request to the Mac every time. The model can still ask questions itself
      ENABLE_FOLLOW_UP_GENERATION = "False";
      # No automatic topic tags on chats, another request to the Mac per chat.
      # Tags can still be added by hand
      ENABLE_TAGS_GENERATION = "False";
      ENABLE_TITLE_GENERATION = "False";
      # Unused features off, so their tools aren't sent with every request
      ENABLE_CALENDAR = "False";
      ENABLE_AUTOMATIONS = "False";
      ENABLE_NOTES = "False";
      ENABLE_MEMORIES = "False";
      ENABLE_TOOLS = "False";
      # Search through SearXNG
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://${searxngHost}:${toString private.searxngPort}/search";
      # Results per search. Each is only a title, link and snippet, so more
      # gives the model more to choose from at little cost
      WEB_SEARCH_RESULT_COUNT = "6";
      # Pages the model reads are passed on whole; cap them (in characters,
      # about 5k tokens) so one big page can't fill the model's context
      WEB_FETCH_MAX_CONTENT_LENGTH = "20000";
      # Embed uploaded files and knowledge bases with LM Studio on the Mac
      # instead of on this machine's CPU. URL and token default to the
      # OPENAI_ ones above
      RAG_EMBEDDING_ENGINE = "openai";
      RAG_EMBEDDING_MODEL = "text-embedding-embeddinggemma-300m";
    };
  };
}
