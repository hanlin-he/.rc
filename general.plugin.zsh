alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah'
alias brewup="brew update;brew upgrade;brew cleanup;brew doctor;brew cu -ayv"
alias opamup="opam update;opam upgrade"
alias texup="sudo tlmgr update --self --all"
alias vimup="vim +PlugUpdate +qall"

jdk() {
        version=$1
        export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
        java -version
 }
