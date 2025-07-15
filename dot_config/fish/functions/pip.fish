function pip --description 'Wrapper using uv when available'
  set _pip python -m pip

  if type -q uv;
    set _pip uv pip
  end

  $_pip $argv
end
