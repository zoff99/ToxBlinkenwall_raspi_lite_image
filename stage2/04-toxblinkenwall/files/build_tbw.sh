#! /bin/bash

id -a
pwd

if [ "$1""x" == "cachex" ]; then
  echo "option: *CACHE*"
else
  echo "option: +NOcache+"
fi

echo "==============================="
export _git_branch_=$(cat /_GIT_BRANCH_)
echo "GIT: current branch is:"
echo $_git_branch_
export _git_project_username_=$(cat /_GIT_PROJECT_USERNAME_)
echo "GIT: current username is:"
echo $_git_project_username_
echo "==============================="

cd /home/pi/
rm -Rf ToxBlinkenwall/.git # remove previous install
rm -Rf tmp/

echo "using local build from zoff99 repo"
git clone https://github.com/zoff99/ToxProxy tmp
cd tmp
git checkout "zoff99/tweaks_001"

cd ..
mkdir -p ToxBlinkenwall/
cp -a tmp/*  ToxBlinkenwall/
cp -a tmp/.gitignore ToxBlinkenwall/
cp -a tmp/.git ToxBlinkenwall/
rm -Rf tmp/

cd
export _HOME_="/home/pi/"
echo $_HOME_

# cd $_HOME_/ToxBlinkenwall/


export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

export CF2=" -O3 -ggdb3 -marm -mtune=arm1176jzf-s -march=armv6 -mfpu=vfp -mfloat-abi=hard "
export CF3="" # " -funsafe-math-optimizations "
export VV1=" VERBOSE=1 V=1 "

if [ "$1""x" != "cachex" ]; then
  echo "option: +NOcache+"
  sudo rm -Rfv $_SRC_
  sudo rm -Rfv $_INST_
fi

mkdir -p $_SRC_
mkdir -p $_INST_
sudo chown -R pi:pi $_SRC_
sudo chown -R pi:pi $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig

if [ "$1""x" != "cachex" ]; then

  echo "option: +NOcache+"


cd $_SRC_
# rm -Rf x264
git clone https://code.videolan.org/videolan/x264.git
cd x264
git checkout 1771b556ee45207f8711744ccbd5d42a3949b14c # 0a84d986e7020f8344f00752e3600b9769cc1e85 # stable
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-opencl --enable-static \
--disable-avs --disable-cli --enable-pic --disable-asm
make clean
make -j $(nproc)
make install



# for ffmpeg --------
export CFLAGS="-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
-I/opt/vc/include -I/opt/vc/interface/vmcs_host/linux -I/opt/vc/interface/vcos/pthreads \
$CF2 $CF3 \
-I/opt/vc/include \
-I/opt/vc/include/IL/ \
-I/opt/vc/interface/vmcs_host/linux \
-I/opt/vc/interface/vcos/pthreads "

cd $_SRC_
# rm -Rf libav
git clone https://github.com/FFmpeg/FFmpeg libav
cd libav
git checkout n4.1.1
./configure --prefix=$_INST_ --disable-devices \
--enable-pthreads \
--disable-shared --enable-static \
--disable-doc --disable-avdevice \
--disable-swscale \
--disable-network \
--enable-ffmpeg --enable-ffprobe \
--disable-network --disable-everything \
--disable-bzlib \
--disable-libxcb-shm \
--disable-libxcb-xfixes \
--enable-parser=h264 \
--enable-runtime-cpudetect \
--enable-omx-rpi --enable-mmal \
--enable-omx \
--enable-libx264 \
--enable-encoder=libx264 \
--enable-decoder=h264_mmal \
--enable-encoder=h264_omx \
--disable-neon \
--enable-gpl --enable-decoder=h264
make clean
make -j $(nproc)
make install

unset CFLAGS


cd $_SRC_
git clone --depth=1 --branch=1.0.17 https://github.com/jedisct1/libsodium.git
cd libsodium
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared --disable-soname-versions
make -j $(nproc)
make install

cd $_SRC_
git clone --depth=1 --branch=v1.8.0 https://github.com/webmproject/libvpx.git
cd libvpx
make clean
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "

sed -i -e 's#armv7-linux-gcc#armv6-linux-gcc#g' ./configure

./configure --prefix=$_INST_ --disable-examples \
  --disable-unit-tests --enable-shared \
  --size-limit=16384x16384 \
  --target=armv6-linux-gcc \
  --enable-onthefly-bitpacking \
  --enable-error-concealment \
  --enable-runtime-cpu-detect \
  --enable-multi-res-encoding \
  --enable-postproc \
  --enable-vp9-postproc \
  --enable-temporal-denoising \
  --disable-neon --disable-neon-asm \
  --enable-vp9-temporal-denoising

#  --enable-better-hw-compatibility \

make -j $(nproc)
make install

cd $_SRC_
git clone --depth=1 --branch=v1.3 https://github.com/xiph/opus.git
cd opus
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared
make -j $(nproc)
make install

else
  echo "option: *CACHE*"
  export CFLAGS=" $CF2 $CF3 "
  export CXXFLAGS=" $CF2 $CF3 "

  ls -al $_INST_/include/

  # -- get the source into the image --
  cd $_SRC_
  rm -Rf x264
  git clone https://code.videolan.org/videolan/x264.git
  cd x264
  git checkout 1771b556ee45207f8711744ccbd5d42a3949b14c # 0a84d986e7020f8344f00752e3600b9769cc1e85 # stable
  cd $_SRC_
  rm -Rf libav
  git clone https://github.com/FFmpeg/FFmpeg libav
  cd libav
  git checkout n4.1.1

  cd $_SRC_
  rm -Rf libsodium
  git clone --depth=1 --branch=1.0.17 https://github.com/jedisct1/libsodium.git

  cd $_SRC_
  rm -Rf libvpx
  git clone --depth=1 --branch=v1.8.0 https://github.com/webmproject/libvpx.git

  cd $_SRC_
  rm -Rf opus
  git clone --depth=1 --branch=v1.3 https://github.com/xiph/opus.git
  # -- get the source into the image --

  cd $_SRC_
  rm -Rf c-toxcore/
fi

cd $_SRC_

if [ "$_git_project_username_""x" == "zoff99x" ]; then
    echo "using local build from zoff99 repo"
    git clone https://github.com/zoff99/c-toxcore
    cd c-toxcore
    git checkout "zoff99/zoxcore_local_fork"
else
    git clone https://github.com/Zoxcore/c-toxcore
    cd c-toxcore

    if [ "$_git_branch_""x" == "masterx" ]; then
        git checkout "toxav-multi-codec"
    elif [ "$_git_branch_""x" == "toxphonev20x" ]; then
        git checkout "release"
    else
        git checkout "release"
    fi
fi

./autogen.sh
make clean
export CFLAGS=" -DRPIZEROW $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 \
                --param=ssp-buffer-size=1 -ggdb3 -fstack-protector-all "
export LDFLAGS=-L$_INST_/lib

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared
make -j $(nproc) || exit 1
make install


cd $_HOME_/ToxBlinkenwall/src/

export WARN01=" -Wall -Wextra -Wno-unused-result -Wno-pointer-sign -Wno-unused-parameter -Wno-unused-variable "
export CFLAGS=" $WARN01 -std=gnu99 -I$_INST_/include/ \
  -L$_INST_/lib -O3 -g3 -fstack-protector-all -fPIC -export-dynamic "

gcc $CFLAGS \
ToxProxy.c \
-lm \
-std=gnu99 \
-L$_INST_/lib \
$_INST_/lib/libtoxcore.a \
$_INST_/lib/libtoxav.a \
-lrt \
$_INST_/lib/libopus.a \
$_INST_/lib/libvpx.a \
$_INST_/lib/libx264.a \
$_INST_/lib/libavcodec.a \
$_INST_/lib/libavutil.a \
$_INST_/lib/libsodium.a \
-lpthread \
-ldl \
-o ToxProxy

res2=$?

ls -hal ToxProxy
file ToxProxy
ldd ToxProxy

## ------------- hack to make it work with tbw image ---------------------------
## ------------- hack to make it work with tbw image ---------------------------
mkdir -p $_HOME_/ToxBlinkenwall/toxblinkenwall
cp -av ToxProxy $_HOME_/ToxBlinkenwall/toxblinkenwall/toxproxy
cp -av $_HOME_/ToxBlinkenwall/detect_usb_audio.sh $_HOME_/ToxBlinkenwall/toxblinkenwall/
cp -av $_HOME_/ToxBlinkenwall/process_usb_drive.sh $_HOME_/ToxBlinkenwall/toxblinkenwall/
cp -av $_HOME_/ToxBlinkenwall/udev_default.sh $_HOME_/ToxBlinkenwall/toxblinkenwall/

echo "tp dir looks like this :"
echo "----------------------------"
ls -al $_HOME_/ToxBlinkenwall/toxblinkenwall/
echo "----------------------------"
## ------------- hack to make it work with tbw image ---------------------------
## ------------- hack to make it work with tbw image ---------------------------


## ----------------------------------------

echo '#! /bin/bash
cd ~/ToxBlinkenwall/toxblinkenwall/
./loop_services.sh > /dev/null 2>/dev/null &
' >> /home/pi/ToxBlinkenwall/toxblinkenwall/initscript.sh
chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/initscript.sh

## ----------------------------------------

echo '#! /bin/bash

function clean_up
{
	pkill toxproxy
	sleep 2
	pkill -9 toxproxy
	pkill -9 toxproxy
    cat /dev/zero > /dev/fb0
	exit
}

cd $(dirname "$0")
export LD_LIBRARY_PATH=~/inst/lib/

trap clean_up SIGHUP SIGINT SIGTERM SIGKILL

while [ 1 == 1 ]; do
    # just in case, so that udev scripts really really work
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-udevd
    mkdir -p ./db/

    if [ -f "OPTION_USE_STDLOG" ]; then
        std_log=stdlog.log
    else
        std_log=/dev/null
    fi
    ulimit -c 99999

    cat /dev/zero > /dev/fb0
    ./toxproxy > "$std_log" 2>&1

    #
    if [ -f "OPTION_USE_STDLOG" ]; then
        # save debug info ---------------
        mv ./toxproxy.2 ./toxproxy.3
        mv ./core.2 ./core.3
        mv ./stdlog.log.2 ./stdlog.log.3
        # -------------------------------
        mv ./toxproxy.1 ./toxproxy.2
        mv ./core.1 ./core.2
        mv ./stdlog.log.1 ./stdlog.log.2
        # -------------------------------
        cp ./toxproxy ./toxproxy.1
        mv ./core ./core.1
        mv ./stdlog.log ./stdlog.log.1
        # save debug info ---------------
    fi
    #

    if [ -f "OPTION_NOLOOP" ]; then
        # do not loop/restart
        clean_up
        exit 1
    fi

done
' >> /home/pi/ToxBlinkenwall/toxblinkenwall/loop_services.sh
chmod u+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/loop_services.sh


cd $_HOME_

if [ $res2 -eq 0 ]; then
 echo "compile: OK"
else
 echo "compile: ** ERROR **"
 exit 2
fi

# echo '' >> ~/.profile


echo "build ready"
