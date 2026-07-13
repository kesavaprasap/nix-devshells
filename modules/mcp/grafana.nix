# Grafana MCP server - query dashboards, datasources, and alerts
{
  pkgs,
  lib,
  devPkgs,
}: {
  meta = {
    name = "grafana";
    description = "Grafana API integration — dashboards, datasources, alerts";
    category = "mcp";
    secret = {
      envVar = "GRAFANA_API_KEY";
      ageFile = "grafana-mcp-token.age";
    };
  };

  packages = [devPkgs.mcp-grafana];

  mcpConfig = {
    grafana = {
      type = "stdio";
      command = "mcp-grafana";
      args = [];
      env = {
        GRAFANA_URL = "https://grafana.licuspace.de";
      };
    };
  };

  shellHook = ''
    echo "  📊 grafana: Grafana API integration"
  '';
}
