#!/bin/bash

# Change root
# sudo -s
# passwd

echo "Change root password"
read

echo "Change timezone to denver"
read

puts "here we go"

# Script to setup the machine in the cloud

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


brew install asdf git

# Install asdf to shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc


# Install ruby 3.2.2 with asdf
asdf plugin add ruby
asdf install ruby 3.2.2

# Add my public key to the server

echo "Add your public key to the server"
read

