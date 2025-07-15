function fast_forward_branch
  set branch $argv[1]

  git switch $branch && \
    git pull upstream $branch && \
    git push
end
