# Qdrant MCP server - Semantic documentation search with local embeddings
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "qdrant-mcp";
    description = "Semantic documentation search using Qdrant with local CPU embeddings";
    category = "mcp";
    disabled = true;
  };

  packages = [devPkgs.qdrant-mcp];

  mcpConfig = {
    qdrant-docs = {
      type = "stdio";
      command = "mcp-server-qdrant";
      args = [];
      env = {
        QDRANT_URL = "http://localhost:6333";
        EMBEDDING_MODEL = "sentence-transformers/all-MiniLM-L6-v2";
      };
    };
  };

  shellHook = ''
    echo "  🔍 qdrant-mcp: Semantic documentation search (requires Qdrant server)"
  '';
}
