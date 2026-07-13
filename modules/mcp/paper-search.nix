# Paper Search MCP server - Academic paper search across multiple sources
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "paper-search";
    description = "Academic paper search (arXiv, PubMed, bioRxiv, etc.)";
    category = "mcp";
    secret = {
      envVar = "SEMANTIC_SCHOLAR_API_KEY";
      ageFile = "semantic-scholar-key.age";
    };
  };

  packages = [devPkgs.paper-search-mcp];

  mcpConfig = {
    paper-search = {
      type = "stdio";
      command = "paper-search-mcp";
      args = [];
      env = {};
    };
  };

  shellHook = ''
    echo "  📚 paper-search: Academic paper search (arXiv, PubMed, etc.)"
  '';
}
