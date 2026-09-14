tm() {
  local target_session=""
  local OPTIND=1
  while getopts "s:" opt; do
    case "$opt" in
    s) target_session="$OPTARG" ;;
    *)
      echo "Usage: tm [-s session] [path]" >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  local dir session

  if [ -n "$target_session" ]; then
    session="$target_session"
    if ! tmux has-session -t "$session" 2>/dev/null; then
      echo "No such session: $session" >&2
      return 1
    fi
  else
    dir="${1:-$PWD}"
    dir="$(cd "$dir" && pwd)" || return 1
    session="$(basename "$dir" | tr '.' '_')"

    if ! tmux has-session -t "$session" 2>/dev/null; then
      tmux new-session -d -s "$session" -c "$dir" -n terminal
      tmux new-window -t "$session" -c "$dir" -n nvim
      tmux send-keys -t "$session:nvim" "nvim" C-m
      tmux new-window -t "$session" -c "$dir" -n lazygit
      tmux send-keys -t "$session:lazygit" "lazygit" C-m
      tmux select-window -t "$session:terminal"
    fi
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}

_tm_sessions() {
  local -a sessions
  sessions=(${(f)"$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"})
  _describe 'tmux session' sessions
}

_tm() {
  _arguments \
    '(-s)-s+[select an existing tmux session]:session:_tm_sessions' \
    '1:directory:_files -/'
}
compdef _tm tm
