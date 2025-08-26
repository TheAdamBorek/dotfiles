function try_install_zsh() {
    echo "Trying to install zsh!"
    if [[ !$0 == "zsh" ]]; then
       echo "Installing zsh!"
       sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "zsh seems to be already installed"
    fi
    rm ~/.zshrc
    ln -s ~/zshrc/.zshrc ~/.zshrc
}

function setup_bash_profile() {
    if [[ ! -f ~/.bash_profile ]]; then
        echo "bash_profile doesn't exisists. Creating it..."
        touch ~/.bash_profile
        cp ~/zshrc/bash_profile_template ~/.bash_profile
    else
        echo "bash_profile already exists. I won't override it." 
    fi
}

function install_rvm() {
    sh "curl -sSL https://get.rvm.io | bash -s stable"
}

function install_brew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
}

function install_nvm() {
    sh "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
}

try_install_zsh
setup_bash_profile
install_rvm
install_brew
install_nvm

source "~/.bash_profile"
sh "~/zshrc/install_dependencies.sh"