#!/bin/bash

set -e

#libglibutil
sudo apt install git make gcc python3 pkg-config libglib2.0-dev  -y
if [  ! -e libglibutil ];then
	git clone https://gitee.com/openfde/libglibutil.git
fi
cd libglibutil 
git pull 
make
sudo make install
sudo make install-dev
cd -

#libgbinder
if [  ! -e libgbinder ];then
	git clone https://gitee.com/openfde/libgbinder.git
fi
cd libgbinder
git pull 
make
sudo make install
sudo make install-dev
cd -

#gibinder-python
sudo apt install python3-pip cython3 lxc curl ca-certificates -y
if [  ! -e gbinder-python ];then
	git clone https://gitee.com/openfde/gbinder-python.git
fi
cd gbinder-python
git pull
sudo python3 setup.py build_ext --inplace --cython
sudo python3 setup.py install
sudo pip3 install pyclip -i https://mirrors.aliyun.com/pypi/simple
cd -

#waydroid
if [  ! -e waydroid_waydroid ];then
	git clone https://gitee.com/openfde/waydroid_waydroid.git
fi
cd waydroid_waydroid
git pull
sudo make install
cd -

#golang1.20.13
sudo apt install wget -y && wget https://go.dev/dl/go1.20.13.linux-arm64.tar.gz -O ~/go1.20.13.linux-arm64.tar.gz
cd ~ && tar -xf ~/go1.20.13.linux-arm64.tar.gz && cd go && sudo cp -a bin/* /usr/bin/
export GOROOT=~/go && echo "export GOROOT=~/go" >> ~/.bashrc
mkdir ~/gopath && export GOPATH=~/gopath && echo "export GOPATH=~/gopath" >> ~/.bashrc
cd - && go env -w GOPROXY=https://goproxy.cn,direct

#fde_fs
if [ ! -e fde_fs ];then
	git clone https://gitee.com/openfde/fde_fs.git
fi
sudo apt install  libfuse-dev fuse3 -y
cd fde_fs &&  git pull && make
sudo make install
cd - 

#tiger_vncserver
if [ ! -e fde_tigervncserver ];then
	git clone https://gitee.com/openfde/fde_tigervncserver.git && cd fde_tigervncserver
fi
cd fde_tigervncserver
sudo dpkg -i xorg-server-source_2%3a1.20.13-1ubuntu1~20.04.8_all.deb
sudo dpkg -i tigervnc-build-deps_1.10.1+dfsg-3_arm64.deb
sudo apt --fix-broken install  -y
sudo apt install equivs devscripts --no-install-recommends -y
sudo mk-build-deps -i -t "apt-get" -r
sudo DEB_BUILD_OPTIONS="parallel=8" dpkg-buildpackage -b -uc -us
cd - && sudo apt install libfile-readbackwards-perl
sudo dpkg  -i  tigervnc-standalone-server_1.10.1+dfsg-3_arm64.deb

#fdeime
if [ ! -e fdeime ];then
	git clone https://gitee.com/openfde/fdeime.git
fi
cd fdeime
git pull 
sudo apt install libibus-1.0-dev -y
mkdir build && cd build
cmake ..
make
sudo make install
cd ~


#mutter
source /etc/lsb-release
if [ "$DISTRIB_ID" = "Kylin" ];then
	if [ ! -e mutter ];then
		git clone https://gitee.com/openfde/mutter.git 
	fi
	cd mutter
	git pull 
	sudo apt install -y meson libgraphene-1.0-dev libgtk-3-dev gsettings-desktop-schemas-dev gnome-settings-daemon-dev libjson-glib-dev libgnome-desktop-3-dev libxkbcommon-x11-dev libx11-xcb-dev libxcb-randr0-dev libxcb-res0-dev libcanberra-dev libgudev-1.0-dev libinput-dev libstartup-notification0-dev sysprof xwayland gnome-settings-daemon
	meson build && ninja -C build
	sudo ninja -C build install && sudo ldconfig
	cd - 
fi

#fde_ctrl
if [  ! -e fde_ctrl ];then
	git clone https://gitee.com/openfde/fde_ctrl.git
fi
cd fde_ctrl
git pull
sudo apt install libx11-dev i3 -y
sudo make build && sudo make install
cd -

