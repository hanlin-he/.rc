alias brewup="brew update;brew upgrade;brew cleanup;brew doctor;brew cu -a"
alias opamup="opam update;opam upgrade"
alias texup="sudo tlmgr update --self --all"
alias vimup="vim +PluginUpdate +qall"
alias vims="vim --servername VIM"
alias convertflac=$'for f in ./*.flac; do avconv -i "$f" -c:a alac "${f%.*}.m4a"; done'

changelaunchpadlayout() {
    defaults write com.apple.dock springboard-columns -int $1;defaults write com.apple.dock springboard-rows -int $2;defaults write com.apple.dock ResetLaunchPad -bool TRUE;killall Dock
}
alias cll=changelaunchpadlayout
alias git=hub
