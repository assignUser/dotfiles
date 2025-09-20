fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.pixi/bin
fish_add_path $HOME/.config/emacs/bin

abbr --add python python3
abbr --add va "source .venv/bin/activate.fish"
abbr --add vd deactivate
abbr --add ia install_archery
abbr --add dr "docker run --rm -it"
abbr --add ope "op run --env-file .env --"
abbr --add cz chezmoi
if command -q helix
  abbr --add hx helix
end

mise activate fish | source
fzf --fish | source
starship init fish | source
zoxide init --cmd cd fish | source

set op_plugins $HOME/.config/op/plugins.sh
if test -e $op_plugins
    source $op_plugins
end
