#!/bin/bash

set -e

function isUpdated() {
	LOCAL=$(git log $1 -n 1 --pretty=format:"%H")
	git fetch
	REMOTE=$(git log remotes/origin/$1 -n 1 --pretty=format:"%H")

	if [ "$LOCAL" = "$REMOTE" ]; then
	    	echo "Up-to-date"
	else
	    	echo "Need updated"
	fi
}

echo -e "************************ Installing libglibuitl ************************"
#libglibutil
recompile=0
if [  ! -e libglibutil ];then
	sudo apt install git make gcc python3 pkg-config libglib2.0-dev  -y
	git clone https://gitee.com/openfde/libglibutil.git
	recompile=1
else
	cd libglibutil 
	result=`isUpdated master` 
	echo -e "************************ libglibutil is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null 
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd libglibutil
	make
	sudo make install-dev
	cd - 1>/dev/null 
fi

if [  ! -e /etc/lsb-release ];then
	source /etc/os-release
	if [ "$ID" = "debian" ];then
		DISTRIB_ID="Debian"
	fi
else
	source /etc/lsb-release
fi
#weston
if { [ "$DISTRIB_ID" == "Kylin" ] && [ "$DISTRIB_RELEASE" == "V10" ];  } || [ "$DISTRIB_ID" == "uos" ] || [ "$DISTRIB_ID" == "Deepin" ];then
	echo -e "\n\n\n ******************Installing weston*************************"
	if [  ! -e weston ];then
		sudo apt install libpixman-1-dev libinput-dev libdrm-dev wayland-protocols libcairo2-dev libpango1.0-dev libjpeg-dev libwebp-dev libsystemd-dev libpam0g-dev libgbm-dev libva-dev freerdp2-dev libx11-xcb-dev libxcb-xkb-dev libxcb-composite0-dev liblcms2-dev libcolord-dev libgstreamer-plugins-base1.0-dev libxml2-dev libxkbcommon-dev libdbus-1-dev libxcursor-dev meson cmake -y
		git clone https://gitee.com/openfde/weston
		recompile=1
		cd weston
		if  [ "$DISTRIB_ID" == "Kylin" ] || [ "$DISTRIB_ID" == "uos" ];then 
			pipe_dev=libpipewire-0.2-dev
			set +e
			sudo apt search ${pipe_dev} 2>/dev/null |grep ${pipe_dev}
			if [ $? != 0 ];then
				pipe_dev=libpipewire-0.3-dev
			fi
			set -e
			sudo apt install -y ${pipe_dev}
			git checkout fde_8.0.0
		elif [ "$DISTRIB_ID" == "Deepin" ];then
			sudo apt install -y libseat-dev libpipewire-0.3-dev libxcb-cursor-dev libneatvnc-dev
			git checkout fde_12.0.1
		fi
		cd - 1>/dev/null
	else
		cd weston
		if  [ "$DISTRIB_ID" == "Kylin" ] || [ "$DISTRIB_ID" == "uos" ];then 
			result=`isUpdated fde_8.0.0` 
		elif [ "$DISTRIB_ID" == "Deepin" ];then
			result=`isUpdated fde_12.0.1` 
		fi
		echo -e "************************ weston is $result ************************"
		if [ "$result" == "Need updated" ];then
			recompile=1
			git pull 
		fi
		cd - 1>/dev/null 
	fi
	if [ $recompile -eq 1 ];then
		recompile=0
		cd weston
		mkdir -p build
		meson build
		meson configure build --prefix=/usr/local
		sudo ninja -C build install
		cd - 1>/dev/null 
	fi
fi

#gibinder-python

#libgbinder
echo -e "\n\n\n ******************Installing libgbinder****************************"
if [  ! -e libgbinder ];then
	git clone https://gitee.com/openfde/libgbinder.git
	recompile=1
else
	cd libgbinder
	result=`isUpdated master` 
	echo -e "************************ libgbinder is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null 
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd libgbinder
	make
	sudo make install-dev
	cd - 1>/dev/null 
fi

#gibinder-python
echo -e "\n\n\n ******************Installing gbinder-python****************************"
if [  ! -e gbinder-python ];then
	sudo apt install python3-pip cython3 lxc curl ca-certificates -y
	git clone https://gitee.com/openfde/gbinder-python.git
	recompile=1
else
	cd gbinder-python
	result=`isUpdated master` 
	echo -e "************************ gbinder-python is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null 
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd gbinder-python
	sudo python3 setup.py build_ext --inplace --cython
	sudo python3 setup.py install
	sudo python3 setup.py sdist --cython
	cd - 1>/dev/null
fi

#waydroid
echo  -e "\n\n\n ******************Installing waydroid ****************************"
if [  ! -e waydroid_waydroid ];then
	git clone https://gitee.com/openfde/waydroid_waydroid.git
	recompile=1
else
	cd waydroid_waydroid
	result=`isUpdated fde_w_14` 
	echo -e "************************ waydroid is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd waydroid_waydroid
	sudo make install
	cd - 1>/dev/null
fi

#if [ "$DISTRIB_ID" == "Kylin" ] && [ "$DISTRIB_RELEASE" == "V10" ];then
#	echo  -e "\n\n\n ******************Installing mesa ****************************"
#	if [ ! -e mesa ];then
#		git clone https://gitee.com/openfde/mesa.git 
#		cd mesa
#		recompile=1
#		git checkout origin/20.1.0_fde_w_for_kylinv10 -b 20.1.0_fde_w_for_kylinv10
#		sudo apt install bison flex  libwayland-egl-backend-dev  libxcb-glx0  libxcb-glx0-dev libxcb-dri2-0-dev libxcb-dri3-dev  libxcb-present-dev  libxshmfence-dev libxxf86vm-dev libxcb-shm0-dev libx11-xcb-dev -y
#		cd - 1>/dev/null
#	else
#		cd mesa
#		result=`isUpdated 20.1.0_fde_w_for_kylinv10` 
#		echo -e "************************ mesa is $result ************************"
#		if [ "$result" == "Need updated" ];then
#			recompile=1
#			git pull 
#		fi
#		cd - 1>/dev/null
#	fi
#	if [ $recompile -eq 1 ];then
#		recompile=0
#		cd mesa
#		mkdir -p build
#		meson build . 
#		meson configure build -Dprefix=/usr
#		sudo ninja -C build install
#		cd - 1>/dev/null
#	fi
#fi
#fde_renderer the daemon of emugl on host linux
echo -e "\n\n\n************************ Installing fde_emugl ************************"
if [ ! -e "fde_emugl" ];then
	git clone https://gitee.com/openfde/fde_emugl
	sudo apt install -y libboost-dev liblz4-dev cmake ninja-build libgl1-mesa-dev libunwind-dev libpciaccess-dev libxcb-dri3-dev libdrm-dev
	cd fde_emugl 
	recompile=1
	if [ "$DISTRIB_ID" = "Ubuntu" -a "$DISTRIB_CODENAME" = "noble" ] ;then
		git checkout ubuntu24.04
	fi
	cd - 1>/dev/null
else
	cd fde_emugl
	tarbranch="main"
	if  [ "$DISTRIB_ID" = "Ubuntu" ] ;then
		if [ "$DISTRIB_CODENAME" = "noble" ];then
			if [ "$branch" != "ubuntu24.04" ];then
				git checkout ubuntu24.04
				tarbranch="ubuntu24.04"
			fi
		fi
	fi
	result=`isUpdated $tarbranch`
	echo -e "************************ fde_emugl is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd fde_emugl
	cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -G Ninja -B build/
	cmake --build build/
	sudo cmake --install build/
	cd - 1>/dev/null
fi

#golang1.23.12
if [ -e "/usr/bin/go" ];then
	goversion=`go version |awk -F " " '{print $3}'`
else
	goversion="0"
fi
if [ "$goversion" != "go1.23.12" ];then
	echo  -e "\n\n\n ******************installing go ****************************"
	sudo apt install wget -y
	wget https://go.dev/dl/go1.23.12.linux-arm64.tar.gz -O ~/go1.23.12.linux-arm64.tar.gz
	cd ~ && tar -xf ~/go1.23.12.linux-arm64.tar.gz &&  sudo cp -a go/bin/* /usr/bin/
	sudo rm -rf /usr/local/go &&& cp -a go /usr/local
	sudo sed -i "/GOPATH/d" ~/.bashrc
	mkdir ~/gopath -p 
	export GOPATH=~/gopath 
	echo "export GOPATH=~/gopath" >> ~/.bashrc
	cd - && go env -w GOPROXY=https://goproxy.cn,direct
fi

#fde_fs
echo -e "\n\n\n ******************Building fde_fs****************************"
if [ ! -e fde_fs ];then
	sudo apt install  libfuse-dev fuse3 -y
	git clone https://gitee.com/openfde/fde_fs.git
	recompile=1
else
	cd fde_fs
	result=`isUpdated master` 
	echo -e "************************ fde_fs is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null
fi
if [ $recompile -eq 1 ];then
	recompile=0
	cd fde_fs
	make
	sudo make install
	cd - 1>/dev/null 
fi

#echo  -e "\n\n\n ******************Building fde_tigervncserver****************************"
#tiger_vncserver
#if [ ! -e fde_tigervncserver ];then
#	git clone https://gitee.com/openfde/fde_tigervncserver.git 
#	cd fde_tigervncserver
#	recompile=1
#	sudo dpkg -i xorg-server-source_2%3a1.20.13-1ubuntu1~20.04.8_all.deb
#	sudo apt install cdbs cmake pristine-tar libjpeg-dev libgnutls28-dev libpam0g-dev libxft-dev libxcursor-dev libxrandr-dev libxdamage-dev libwrap0-dev libfltk1.3-dev xserver-xorg-dev debhelper po-debconf quilt bison flex xutils-dev x11proto-dev xtrans-dev libxau-dev libxdmcp-dev libxfont-dev libxkbfile-dev libpixman-1-dev libpciaccess-dev libgcrypt-dev nettle-dev libudev-dev libaudit-dev libdrm-dev libgl1-mesa-dev libunwind-dev libxmuu-dev libxext-dev libx11-dev libxrender-dev libxi-dev libdmx-dev libxpm-dev libxaw7-dev libxt-dev libxmu-dev libxtst-dev libxres-dev libxfixes-dev libxv-dev libxinerama-dev libxshmfence-dev libepoxy-dev libegl1-mesa-dev libgbm-dev libbsd-dev libdbus-1-dev libsystemd-dev -y
#	sudo dpkg -i tigervnc-build-deps_1.10.1+dfsg-3_arm64.deb
#	sudo apt install equivs devscripts --no-install-recommends -y
#	sudo mk-build-deps -i -t "apt-get" -r
#	cd -
#else
#	cd fde_tigervncserver
#	result=`isUpdated fde_w` 
#	echo -e "************************ fde_tigervncserver is $result ************************"
#	if [ "$result" == "Need updated" ];then
#		recompile=1
#		git pull 
#	fi
#	cd - 1>/dev/null
#fi
#if [ $recompile -eq 1 ];then
#	recompile=0
#	cd fde_tigervncserver
#	sudo DEB_BUILD_OPTIONS="parallel=8" dpkg-buildpackage -b -uc -us
#	cd - 1>/dev/null && sudo apt install libfile-readbackwards-perl
#	sudo dpkg  -i  tigervnc-standalone-server_1.10.1+dfsg-3_arm64.deb
#fi

#fdeime
#echo  -e "\n\n\n ******************Building fdeime****************************"
#if [ ! -e fdeime ];then
#	recompile=1
#	git clone https://gitee.com/openfde/fdeime.git
#	sudo apt install libibus-1.0-dev -y
#else
#	cd fdeime
#	result=`isUpdated master` 
#	echo -e "************************ fdeime is $result ************************"
#	if [ "$result" == "Need updated" ];then
#		recompile=1
#		git pull 
#	fi
#	cd - 1>/dev/null
#fi
#if [ $recompile -eq 1 ];then
#	recompile=0
#	cd fdeime
#	mkdir build -p
#	cmake -B build
#	sudo make -C build install
#	cd - 1>/dev/null
#fi


#mutter
#uos and deepin doesn't support mutter
if  [ "$DISTRIB_ID" != "uos" ] && [ "$DISTRIB_ID" != "Deepin" ];then 
	echo -e "\n\n\n ******************building mutter****************************"
	if [ ! -e mutter ];then
		git clone https://gitee.com/openfde/mutter.git
		recompile=1
		sudo apt install -y meson libgraphene-1.0-dev libgtk-3-dev gsettings-desktop-schemas-dev gnome-settings-daemon-dev libjson-glib-dev libgnome-desktop-3-dev libxkbcommon-x11-dev libx11-xcb-dev libxcb-randr0-dev libxcb-res0-dev libcanberra-dev libgudev-1.0-dev libinput-dev libstartup-notification0-dev sysprof xwayland gnome-settings-daemon libxkbfile-dev intltool libgbm-dev
		cd mutter
		if [ "$DISTRIB_ID" = "Kylin" ] ;then
			git checkout 3.36.1_w
		elif  [ "$DISTRIB_ID" = "Debian" ] ;then
			sudo apt install -y libgbm-dev libcolord-dev liblcms2-dev libpipewire-0.3-dev xvfb xcvt
			git checkout 43.8_debian
		#elif  [ "$DISTRIB_ID" = "uos" ] ;then
		#	git checkout 3.30.2_uos
		#	sudo apt install -y libgbm-dev libelogind-dev libgles2-mesa-dev
		elif  [ "$DISTRIB_ID" = "Ubuntu" ] ;then
			sudo apt install -y liblcms2-dev libcolord-dev libpipewire-0.3-dev xvfb
			if [ "$DISTRIB_CODENAME" = "jammy" ];then
				sudo apt install -y libgbm-dev xcvt
				git checkout 42.9_ubuntu
			elif [ "$DISTRIB_CODENAME" = "noble" ];then
				sudo apt install -y libeis-dev libei-dev libcolord-gtk4-dev libgnome-desktop-4-dev gobject-introspection python3-dbusmock
				git checkout 46.2_ubuntu
			fi
		fi
		cd -  1>/dev/null
	else
		cd mutter
		branch=`git branch |grep '*' |awk -F " " '{print $2}' `
		tarbranch="3.36.1_w"
		if [ "$DISTRIB_ID" = "Kylin" ] ;then
			if [ "$branch" != "3.36.1_w" ];then
				git checkout 3.36.1_w
			fi
		elif  [ "$DISTRIB_ID" = "Debian" ] ;then
			git checkout 43.8_debian
			tarbranch="43.8_debian"
		#elif  [ "$DISTRIB_ID" = "uos" ] ;then
		#	if [ "$branch" != "3.30.2_uos" ];then
		#		git checkout 3.30.2_uos
		#	fi
		#	tarbranch="3.30.2_uos"
		elif  [ "$DISTRIB_ID" = "Ubuntu" ] ;then
			if [ "$DISTRIB_CODENAME" = "jammy" ];then
				if [ "$branch" != "42.9_ubuntu" ];then
					git checkout 42.9_ubuntu
				fi
				tarbranch="42.9_ubuntu"
			elif [ "$DISTRIB_CODENAME" = "noble" ];then
				if [ "$branch" != "46.2_ubuntu" ];then
					git checkout 46.2_ubuntu
				fi
				tarbranch="46.2_ubuntu"
			fi
		fi
		result=`isUpdated "$tarbranch"`
		echo "************************ mutter  is $result ************************"
		if [ "$result" == "Need updated" ];then
			recompile=1
			git pull 
		fi
		cd - 1>/dev/null
	fi
	if [ $recompile -eq 1 ];then
		cd mutter
		recompile=0
		if  [ "$DISTRIB_ID" = "uos" ] ;then
			./autogen.sh
			make -j4
			sudo make install
		else
			mkdir -p build
			meson build . && ninja -C build -j4
			sudo ninja -C build install && sudo ldconfig
		fi
		cd - 1>/dev/null 
	fi
fi

#fde_ctrl
echo -e "\n\n\n ******************Building fde_ctrl****************************"
if [  ! -e fde_ctrl ];then
	git clone https://gitee.com/openfde/fde_ctrl.git
	if [ "$DISTRIB_ID" != "Deepin" ];then
		sudo apt install -y mutter
	fi
	sudo apt install ddcutil libx11-dev  -y
	recompile=1
else
	cd fde_ctrl
	result=`isUpdated "main"`
	echo "************************ fde_ctrl  is $result ************************"
	if [ "$result" == "Need updated" ];then
		recompile=1
		git pull 
	fi
	cd - 1>/dev/null
fi

if [ $recompile -eq 1 ];then
	recompile=0
	cd fde_ctrl
	make build
	sudo make install
	cd - 1>/dev/null
fi


#fde_navi
if { [ "$DISTRIB_ID" == "Kylin" ] && [ "$DISTRIB_RELEASE" == "V10" ];  } || [ "$DISTRIB_ID" == "uos" ];then
	echo -e "\n\n\n ******************Building fde_navi****************************"
	if [  ! -e fde_navi ];then
		git clone https://gitee.com/openfde/fde_navi.git
		sudo apt install -y qt5-qmake wmctrl qt5-default qtbase5-dev g++
		recompile=1
	else
		cd fde_navi
		result=`isUpdated "master"`
		echo "************************ fde_navi  is $result ************************"
		if [ "$result" == "Need updated" ];then
			recompile=1
			git pull 
		fi
		cd - 1>/dev/null
	fi
	if [ $recompile -eq 1 ];then
		recompile=0
		cd fde_navi
		qmake
		make
		sudo cp -a fde_navi /usr/bin/
		cd - 1>/dev/null
	fi
fi

