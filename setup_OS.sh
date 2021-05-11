#!/bin/bash

# This is a list of packages/programs to install with a new distro (ubuntu)

# Variables
python_version_global="3.9.1"

# Update
sudo apt update
sudo apt-get update

# Install git
Git()
{
sudo apt install git
}

# Install vim
Vim()
{
sudo apt-get install vim
sudo apt-get install gedit
sudo apt-get install curl:wqsudo apt update
}

# Install pyenv in ~/.pyenv
Pyenv()
{
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init --path)"' >> ~/.profile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
echo -e 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
exec $SHELL
source .bashrc
#source .bash_profile
source .profile
}

# These are required to get pyenv and python working properly
Python()
{
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

# You need to install this for 18.04 onwards
sudo bash -c "echo 'deb http://security.debian.org/debian-security jessie/updates main' >> /etc/apt/sources.list"
sudo apt-get install -y --no-install-recommends libssl1.0.0

# Install and set the global python version
pyenv install $python_version_global
pyenv global $python_version_global

# Install pipx
python -m pip install pipx
python -m pipx ensurepath

# Install poetry
pipx install poetry
pipx ensurepath
}

Code()
{
# Install VS Code
sudo apt install software-properties-common apt-transport-https

# Add repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Install the code
sudo apt install code
}

PyCharm()
{
# Install PyCharm Community
sudo apt-get install snap
sudo snap install pycharm-community --classic
}

Ulauncher()
{
# Install Ulauncher
sudo add-apt-repository ppa:agornostal/ulauncher
sudo apt-get install ulauncher
}

I3()
{
# Add i3
sudo apt install i3
}

# Things to install
Git
Vim
Pyenv
Python
Code
PyCharm
Ulauncher
I3

