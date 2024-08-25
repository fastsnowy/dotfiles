HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

#  Don't put duplicate lines in the history.
setopt hist_ignore_dups
setopt hist_ignore_all_dups

# Share history between all sessions.
setopt share_history
setopt append_history

# Save each command right after it has been executed.
setopt extended_history

# Save the history after each command.
setopt hist_reduce_blanks
