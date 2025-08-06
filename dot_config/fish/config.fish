fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.pixi/bin
fish_add_path $HOME/.cargo/bin


abbr --add python python3
abbr --add va "source .venv/bin/activate.fish"
abbr --add vd deactivate
abbr --add ia install_archery
abbr --add dr "docker run --rm -it"
abbr --add ope "op run --env-file .env --"

mise activate fish | source
fzf --fish | source
starship init fish | source
zoxide init --cmd cd fish | source
