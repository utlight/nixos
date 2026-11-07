_repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

if [[ -n $_repo_root ]]; then
	_hist_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
	mkdir -p "$_hist_dir"
	_hash=$(print -rn -- "$_repo_root" | md5sum | cut -c1-12)
	HISTFILE="$_hist_dir/${_repo_root:t}-$_hash"
fi

unset _repo_root _hist_dir _hash
