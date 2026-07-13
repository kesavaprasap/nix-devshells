# Shrimp MCP server - AI-powered task management system
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "shrimp";
    description = "AI-powered task management system";
    category = "mcp";
    disabled = true;
  };

  packages = [devPkgs.mcp-shrimp-task-manager];

  mcpConfig = {
    shrimp = {
      type = "stdio";
      command = "mcp-shrimp-task-manager";
      args = [];
      env = {
        DATA_DIR = ".shrimp";
        TEMPLATES_USE = "en";
        ENABLE_GUI = "true";
        MCP_PROMPT_EXECUTE_TASK_APPEND = "Validation: Add that pre-commit hooks must pass and progress must be committed.";
      };
    };
  };

  shellHook = ''
    echo "  🦐 shrimp: AI-powered task management"
  '';
}
