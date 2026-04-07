# Shell prompt with git integration via Starship
{
  pkgs,
  lib,
}: {
  meta = {
    name = "prompt";
    description = "Starship cross-shell prompt with git integration";
    category = "tool";
  };

  packages = [
    pkgs.starship
  ];

  shellHook = ''
    echo "  🚀 Starship prompt active"
    export STARSHIP_CONFIG=${pkgs.writeText "starship.toml" ''
      [git_branch]
      symbol = " "
      style = "bold yellow"

      [git_status]
      style = "bold red"
      ahead = "⇡''${count}"
      behind = "⇣''${count}"
      diverged = "⇕⇡''${ahead_count}⇣''${behind_count}"
      conflicted = "✖"
      untracked = "?"
      stashed = "$"
      modified = "!"
      staged = "+"
      renamed = "»"
      deleted = "✘"

      [directory]
      style = "bold blue"
      truncation_length = 4
      truncate_to_repo = true
    ''}
    eval "$(starship init bash)"
  '';
}
