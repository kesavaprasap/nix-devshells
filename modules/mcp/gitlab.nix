# GitLab MCP server - GitLab API integration
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "gitlab";
    description = "GitLab API integration";
    category = "mcp";
    secret = {
      envVar = "GITLAB_PERSONAL_ACCESS_TOKEN";
      ageFile = "gitlab-token.age";
    };
  };

  packages = [devPkgs.mcp-gitlab];

  mcpConfig = {
    gitlab = {
      type = "stdio";
      command = "mcp-gitlab";
      args = [];
      env = {
        GITLAB_API_URL = "https://gitlab.licuspace.de/api/v4";
      };
    };
  };

  shellHook = ''
    echo "  🦊 gitlab: GitLab API integration"
  '';
}
