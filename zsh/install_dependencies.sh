#!/bin/bash

# Function to handle the installation process
install_package() {
  local package=$1
  local command=$2
  local ignore_ask=$3
  if ! [[ $ignore_ask == 1 ]]; then
    echo "Do you want to install $package? (y/n) "
    read answer
  fi
  if [[ $answer == "y" || $answer == "Y" || $ignore_ask == 1 ]]; then
    {
      $command
    } || {
      echo "Failed to install $package. Continuing with the next one..."
    }
  else
    echo "Skipping $package."
  fi
}

install_brew_package() {
  local package=$1
  local brew_output=$(brew list | grep "$package")
  if [[ "$brew_output" == *"$package"* ]]; then
    echo "$package is already installed."
  else
    echo $brew_output
    echo $package
    install_package $package "brew install $package" $2
  fi
}

brew_packages=(
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
  "ripgrep"
  "fzf"
  "tmux"
  "lazygit"
  "1password-cli"
  "git-delta"
  "tree-sitter"
  "starship"
  "llm"
  "jesseduffield/lazydocker/lazydocker"
  "libimobiledevice"
  "switchaudio-osx"
  "tlrc"
  "stow"
  "lua"
  "eza"
  "tmuxinator"
)

# Iterate through the list and attempt to install each package
for package in "${brew_packages[@]}"; do
  install_brew_package $package "brew install $package"
done

yazi_installed=($(brew list | grep "yazi") == *"yazi"*)
if [[ $yazi_installed == 0 ]]; then
  echo "Do you want to install Yazi - terminal file explorer? (y/n)"
  read answer
    echo "Installing Yazi & it's plugins:"
    install_brew_package 'yazi' 1
    yazi_plugins=(
      "ffmpegthumbnailer" 
      "sevenzip" 
      "jq" 
      "poppler" 
      "fd" 
      "zoxide" 
      "imagemagick" 
      "font-symbols-only-nerd-font"
    )
    for plugin in "${yazi_plugins[@]}"; do
      install_brew_package $plugin
    done
    echo "End of Yazi plugins."
else
  echo "Yazi is already installed."
fi
install_package "tmux plugin manager" "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" 1

echo "Installation process completed."
