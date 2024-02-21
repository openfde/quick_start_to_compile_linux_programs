#!/bin/bash

set -e

echo -e "******************installing libglibutil****************************"
#libglibutil
if [  ! -e libglibutil ];then
	sudo apt install git make gcc python3 pkg-config libglib2.0-dev  -y
	git clone https://gitee.com/openfde/libglibutil.git
else
	cd libglibutil 
	git pull
	cd -
fi
cd libglibutil
make
sudo make install
sudo make install-dev
cd -

#libgbinder
echo -e "\n\n\n ******************installing libgbinder****************************"
if [  ! -e libgbinder ];then
	git clone https://gitee.com/openfde/libgbinder.git
else
	cd libgbinder
	git pull 
	cd -
fi
cd libgbinder
make
sudo make install
sudo make install-dev
cd -

#gibinder-python
echo -e "\n\n\n ******************installing gbinder-python****************************"
if [  ! -e gbinder-python ];then
	sudo apt install python3-pip cython3 lxc curl ca-certificates -y
	git clone https://gitee.com/openfde/gbinder-python.git
	sudo pip3 install pyclip -i https://mirrors.aliyun.com/pypi/simple
else
	cd gbinder-python
	git pull
	cd -
fi
cd gbinder-python
sudo python3 setup.py build_ext --inplace --cython
sudo python3 setup.py install
cd -

#waydroid
echo  -e "\n\n\n ******************installing waydroid ****************************"
if [  ! -e waydroid_waydroid ];then
	git clone https://gitee.com/openfde/waydroid_waydroid.git
else
	cd waydroid_waydroid
	git pull
	cd -
fi
cd waydroid_waydroid
sudo make install
cd -

#golang1.20.13
if [ ! -e go1.20.13.linux-arm64.tar.gz ];then
	echo  -e "\n\n\n ******************installing go ****************************"
	sudo apt install wget -y
	wget https://go.dev/dl/go1.20.13.linux-arm64.tar.gz -O ~/go1.20.13.linux-arm64.tar.gz
	cd ~ && tar -xf ~/go1.20.13.linux-arm64.tar.gz && cd go && sudo cp -a bin/* /usr/bin/
	sudo sed -i "/GOROOT/d" ~/.bashrc
	export GOROOT=~/go 
	echo "export GOROOT=~/go" >> ~/.bashrc
	sudo sed -i "/GOPATH/d" ~/.bashrc
	mkdir ~/gopath -p 
	export GOPATH=~/gopath 
	echo "export GOPATH=~/gopath" >> ~/.bashrc
	cd - && go env -w GOPROXY=https://goproxy.cn,direct
fi

#fde_fs
echo -e "\n\n\n ******************building fde_fs****************************"
sudo apt install  libfuse-dev fuse3 -y
if [ ! -e fde_fs ];then
	git clone https://gitee.com/openfde/fde_fs.git
else
	cd fde_fs
	git pull
	cd -
fi
cd fde_fs
make
sudo make install
cd - 

echo  -e "\n\n\n ******************building fde_tigervncserver****************************"
#tiger_vncserver
if [ ! -e fde_tigervncserver ];then
	git clone https://gitee.com/openfde/fde_tigervncserver.git 
	cd fde_tigervncserver
	sudo dpkg -i xorg-server-source_2%3a1.20.13-1ubuntu1~20.04.8_all.deb
	sudo apt install cdbs cmake pristine-tar libjpeg-dev libgnutls28-dev libpam0g-dev libxft-dev libxcursor-dev libxrandr-dev libxdamage-dev libwrap0-dev libfltk1.3-dev xserver-xorg-dev debhelper po-debconf quilt bison flex xutils-dev x11proto-dev xtrans-dev libxau-dev libxdmcp-dev libxfont-dev libxkbfile-dev libpixman-1-dev libpciaccess-dev libgcrypt-dev nettle-dev libudev-dev libaudit-dev libdrm-dev libgl1-mesa-dev libunwind-dev libxmuu-dev libxext-dev libx11-dev libxrender-dev libxi-dev libdmx-dev libxpm-dev libxaw7-dev libxt-dev libxmu-dev libxtst-dev libxres-dev libxfixes-dev libxv-dev libxinerama-dev libxshmfence-dev libepoxy-dev libegl1-mesa-dev libgbm-dev libbsd-dev libdbus-1-dev libsystemd-dev -y
	sudo dpkg -i tigervnc-build-deps_1.10.1+dfsg-3_arm64.deb
	sudo apt install equivs devscripts --no-install-recommends -y
	sudo mk-build-deps -i -t "apt-get" -r
	cd -
else
	cd fde_tigervncserver
	git pull
	cd -
fi
#cd fde_tigervncserver
#sudo DEB_BUILD_OPTIONS="parallel=8" dpkg-buildpackage -b -uc -us
#cd - && sudo apt install libfile-readbackwards-perl
#sudo dpkg  -i  tigervnc-standalone-server_1.10.1+dfsg-3_arm64.deb

#fdeime
echo  -e "\n\n\n ******************building fdeime****************************"
if [ ! -e fdeime ];then
	git clone https://gitee.com/openfde/fdeime.git
	sudo apt install libibus-1.0-dev -y
else
	cd fdeime
	git pull 
	cd -
fi
cd fdeime
mkdir build -p && cd build
cmake ..
make
sudo make install
cd ../../


#mutter
source /etc/lsb-release
if [ "$DISTRIB_ID" = "Kylin" ];then
	echo -e "\n\n\n ******************building mutter****************************"
	if [ ! -e mutter ];then
		git clone https://gitee.com/openfde/mutter.git 
		sudo apt install -y meson libgraphene-1.0-dev libgtk-3-dev gsettings-desktop-schemas-dev gnome-settings-daemon-dev libjson-glib-dev libgnome-desktop-3-dev libxkbcommon-x11-dev libx11-xcb-dev libxcb-randr0-dev libxcb-res0-dev libcanberra-dev libgudev-1.0-dev libinput-dev libstartup-notification0-dev sysprof xwayland gnome-settings-daemon
	else
		cd mutter
		git pull 
		cd -
	fi
	cd mutter
	meson build && ninja -C build -j4
	sudo ninja -C build install && sudo ldconfig
	cd - 
fi

#fde_ctrl
echo -e "\n\n\n ******************building fde_ctrl****************************"
if [  ! -e fde_ctrl ];then
	git clone https://gitee.com/openfde/fde_ctrl.git
	sudo apt install libx11-dev i3 -y
	sudo rm -rf /usr/share/waydroid-sessions/i3.desktop
else
	cd fde_ctrl
	git pull 
	echo $GOROOT
	cd -
fi
cd fde_ctrl
make build
sudo make install
cd -

