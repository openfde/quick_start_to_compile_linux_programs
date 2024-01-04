#!/bin/bash

set -e

sudo apt install git -y
if [  ! -e libglibutil ];then
	git clone https://gitee.com/openfde/libglibutil.git
fi
cd libglibutil 
git pull 
sudo apt install make gcc pkg-config libglib2.0-dev  -y
make
sudo make install
sudo make install-dev

cd -
if [  ! -e libgbinder ];then
	git clone https://gitee.com/openfde/libgbinder.git
fi
cd libgbinder
git pull 
make
sudo make install
sudo make install-dev

cd -
sudo apt install python3-pip cython3 lxc curl ca-certificates -y
if [  ! -e gbinder-python ];then
	git clone https://gitee.com/openfde/gbinder-python.git
fi
cd gbinder-python
git pull
python3 setup.py build_ext --inplace --cython
sudo cp -a gbinder.cpython-38-aarch64-linux-gnu.so /usr/lib/python3/dist-packages/
pip3 install pyclip

cd -
sudo apt install golang -y
if [  ! -e fde_ctrl ];then
	git clone https://gitee.com/openfde/fde_ctrl.git
fi
cd fde_ctrl
git pull
sudo make build && sudo make install

cd -
if [  ! -e fde_fs ];then
	git clone https://gitee.com/openfde/fde_fs.git
fi
cd fde_fs
git pull
sudo make build && sudo make install
cd -

if [  ! -e waydroid_waydroid ];then
	git clone https://gitee.com/openfde/waydroid_waydroid.git
fi
cd waydroid_waydroid
git pull
sudo make install
cd -
