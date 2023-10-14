#!/bin/bash
set -eo pipefail

has() {
  [[ -x "$(command -v "$1")" ]];
}

has_not() {
  ! has "$1" ;
}

ok() {
  echo "→ "$1" OK"
}

sudo apt update
sudo apt install -y \
	vlc \
	python3 \
	python3-pip \
	chromium \
	git \
	htop \
	zsh \
	curl \
	terminator \
	playonlinux

ok "System updated!"
ok "vlc"
ok "python"
ok "chromium"
ok "git"
ok "htop"
ok "zsh"
ok "curl"
ok "terminator"
ok "playonlinux"

if has_not google-chrome-stable; then
  wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg --force-depends -i chrome.deb
  sudo apt-get install -fy
  rm chrome.deb
fi
ok "Chrome"

if has_not docker; then
  sudo apt-get install apt-transport-https ca-certificates linux-image-extra-$(uname -r) -y
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  sudo sh -c "echo 'deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -sc) main' | cat > /etc/apt/sources.list.d/docker.list"
  sudo apt-get update
  sudo apt-get purge lxc-docker
  sudo apt-get install docker-engine -y
  sudo service docker start
  sudo groupadd docker
  sudo usermod -aG docker $(id -un)
fi
ok "Docker"

if ! [[ -d "/opt/stremio" ]]; then
  curl -#So stremio.tar.gz http://dl.strem.io/Stremio3.5.7.linux.tar.gz
  sudo mkdir -p /opt/stremio
  sudo tar -xvzf stremio.tar.gz -C /opt/stremio
  curl -SO# http://www.strem.io/3.0/stremio-white-small.png
  sudo mv stremio-white-small.png /opt/stremio/
  curl -SO# https://gist.githubusercontent.com/claudiosmweb/797b502bc095dabee606/raw/52ad06b73d90a4ef389a384fbc815066c89798eb/stremio.desktop
  sudo mv stremio.desktop /usr/share/applications/
  rm stremio.tar.gz
fi
ok "Strem.io"

if has_not simplescreenrecorder; then
  sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder -y
  sudo apt-get update
  sudo apt-get install simplescreenrecorder -y
  # if you want to record 32-bit OpenGL applications on a 64-bit system:
  sudo apt-get install simplescreenrecorder-lib:i386 -y
fi
ok "Simple Screen Recorder"

if ! [[ -d "$HOME/.nvm" ]]; then
  NODE_VERSION=4
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  source ~/.bashrc
  nvm install $NODE_VERSION
  nvm use $NODE_VERSION
  nvm alias default $NODE_VERSION
fi
ok "NVM"

npm i -g nodemon hmh-cli clima
ok "NodeJS global modules"

if has_not mysql; then
  sudo apt-get install -y mysql-server
fi
ok "MySQL"

if ! [[ -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi
ok "OH My ZSH"

if has_not mongod; then
  sudo bash -c "$(wget -O - https://raw.githubusercontent.com/fdaciuk/install-linux/master/mongo-ubuntu.sh)"
fi
ok "Mongo DB"

# Clean up
sudo apt-get autoclean -y
sudo apt-get autoremove -y

ok "Installation finished!"
