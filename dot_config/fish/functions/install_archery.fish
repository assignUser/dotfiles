function install_archery
  if not test -d .venv;
    venv .venv
  end

  source .venv/bin/activate.fish

  pip install -e dev/archery[all]
end
