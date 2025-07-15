function merge_pr --wraps='./dev/merge_arrow_pr.sh' --description './dev/merge_arrow_pr.sh'
  ARROW_GITHUB_API_TOKEN=$(gh auth token) ./dev/merge_arrow_pr.sh $argv
        
end
