function venv
  set _venv python3 -m venv

  if type -q uv;
    set _venv uv venv
  end

  if test -d .venv;
    rm -rf .venv
  end

  $_venv .venv

end
