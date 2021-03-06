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

## ----------------------
_FFMPEG_VERSION_="n4.1.6"
_OPUS_VERSION_="v1.3.1"
_VPX_VERSION_="v1.8.0"
_LIBSODIUM_VERSION_="1.0.18"
_X264_VERSION_="1771b556ee45207f8711744ccbd5d42a3949b14c"
## ----------------------

cd /home/pi/
rm -Rf ToxBlinkenwall/.git # remove previous install
rm -Rf tmp/

if [ "$_git_project_username_""x" == "zoff99x" ]; then
    echo "using local build from zoff99 repo"
    git clone https://github.com/zoff99/ToxBlinkenwall tmp
    cd tmp
    git checkout "master"
else
    git clone https://github.com/Zoxcore/ToxBlinkenwall tmp
    cd tmp

    if [ "$_git_branch_""x" == "masterx" ]; then
        git checkout "master"
    elif [ "$_git_branch_""x" == "toxphonev20x" ]; then
        git checkout "release"
    else
        git checkout "release"
    fi
fi

cd ..
mkdir -p ToxBlinkenwall/
cp -a tmp/*  ToxBlinkenwall/
cp -a tmp/.gitignore ToxBlinkenwall/
cp -a tmp/.git ToxBlinkenwall/
rm -Rf tmp/

cd
export _HOME_="/home/pi/"
echo $_HOME_
cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

export CF2=" -O3 -ggdb3 -marm -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 \
 -mfloat-abi=hard -ftree-vectorize "
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
git checkout "$_X264_VERSION_" # stable
./configure --prefix=$_INST_ --disable-opencl --enable-static \
--disable-avs --disable-cli --enable-pic || exit 1
make clean
make -j $(nproc) || exit 1
make install || exit 1



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
git checkout "$_FFMPEG_VERSION_"
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
--enable-gpl --enable-decoder=h264 || exit 1
make clean
make -j $(nproc) || exit 1
make install || exit 1

unset CFLAGS


cd $_SRC_
git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git
cd libsodium
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared --disable-soname-versions || exit 1
make -j $(nproc) || exit 1
make install || exit 1

cd $_SRC_
git clone --depth=1 --branch="$_VPX_VERSION_" https://github.com/webmproject/libvpx.git
cd libvpx
make clean
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-examples \
  --disable-unit-tests --enable-shared \
  --size-limit=16384x16384 \
  --enable-onthefly-bitpacking \
  --enable-error-concealment \
  --enable-runtime-cpu-detect \
  --enable-multi-res-encoding \
  --enable-postproc \
  --enable-vp9-postproc \
  --enable-temporal-denoising \
  --enable-vp9-temporal-denoising || exit 1

#  --enable-better-hw-compatibility \

make -j $(nproc) || exit 1
make install || exit 1

cd $_SRC_
git clone --depth=1 --branch="$_OPUS_VERSION_" https://github.com/xiph/opus.git
cd opus
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared --enable-float-approx || exit 1
make -j $(nproc) || exit 1
make install || exit 1

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
  git checkout "$_X264_VERSION_" || exit 1 # stable

  cd $_SRC_
  rm -Rf libav
  git clone https://github.com/FFmpeg/FFmpeg libav
  cd libav
  git checkout "$_FFMPEG_VERSION_" || exit 1

  cd $_SRC_
  rm -Rf libsodium
  git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git || exit 1

  cd $_SRC_
  rm -Rf libvpx
  git clone --depth=1 --branch="$_VPX_VERSION_" https://github.com/webmproject/libvpx.git || exit 1

  cd $_SRC_
  rm -Rf opus
  git clone --depth=1 --branch="$_OPUS_VERSION_" https://github.com/xiph/opus.git || exit 1
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
export CFLAGS=" -D HW_CODEC_CONFIG_RPI3_TBW_BIDI $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 \
                --param=ssp-buffer-size=1 -ggdb3 -fstack-protector-all "
export LDFLAGS=-L$_INST_/lib

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared || exit 1
make -j $(nproc) || exit 1
make install || exit 1


cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


gcc \
-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
-I/opt/vc/include -I/opt/vc/interface/vmcs_host/linux -I/opt/vc/interface/vcos/pthreads \
$CF2 $CF3 \
-fstack-protector-all \
-Wno-unused-variable \
-fPIC -export-dynamic -I$_INST_/include -o toxblinkenwall -lm \
toxblinkenwall.c openGL/esUtil.c openGL/esShader.c rb.c \
omx.c \
-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads \
-I/opt/vc/include/interface/vmcs_host/linux -lbrcmEGL -lbrcmGLESv2 \
-lbcm_host -L/opt/vc/lib \
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
-lasound \
-lpthread -lv4lconvert \
-lmmal -lmmal_core -lmmal_vc_client -lmmal_components -lmmal_util \
-L/opt/vc/lib -lbcm_host -lvcos -lopenmaxil -ldl

res2=$?

ldd toxblinkenwall
ls -hal toxblinkenwall
file toxblinkenwall

cd $_HOME_

if [ $res2 -eq 0 ]; then
 echo "compile: OK"
else
 echo "compile: ** ERROR **"
 exit 2
fi

echo '
IS_ON=RASPI
HD=RASPIHD
export IS_ON
export HD
' >> ~/.profile


echo "build ready"
