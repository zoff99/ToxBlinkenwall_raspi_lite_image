#! /bin/bash

id -a
pwd

if [ "$1""x" == "cachex" ]; then
  echo "option: *CACHE*"
else
  echo "option: +NOcache+"
fi

cd /home/pi/
rm -Rf ToxBlinkenwall/.git # remove previous install
rm -Rf tmp/
git clone https://github.com/Zoxcore/ToxBlinkenwall tmp
cd tmp
git checkout "release"
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

export CF2=" -O3 -g -marm -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 \
 -mfloat-abi=hard -ftree-vectorize "
export CF3=" -funsafe-math-optimizations "
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
# rm -Rf libav
git clone https://github.com/libav/libav
cd libav
git checkout v12.3
./configure --prefix=$_INST_ --disable-devices --disable-programs \
--disable-doc --disable-avdevice --disable-avformat \
--disable-swscale \
--disable-avfilter --disable-network --disable-everything \
--disable-bzlib \
--disable-libxcb-shm \
--disable-libxcb-xfixes \
--enable-parser=h264 \
--enable-runtime-cpudetect \
--enable-mmal \
--enable-decoder=h264_mmal \
--enable-gpl --enable-decoder=h264
make clean
make -j4
make install




cd $_SRC_
# rm -Rf x264
git clone git://git.videolan.org/x264.git
cd x264
git checkout 0a84d986e7020f8344f00752e3600b9769cc1e85 # stable
./configure --prefix=$_INST_ --disable-opencl --enable-shared --enable-static \
--disable-avs --disable-cli
make clean
make -j4
make install


cd $_SRC_
git clone --depth=1 --branch=1.0.16 https://github.com/jedisct1/libsodium.git
cd libsodium
./autogen.sh
export CFLAGS=" $CF2 "
./configure --prefix=$_INST_ --disable-shared --disable-soname-versions
make -j 4
make install

cd $_SRC_
git clone --depth=1 --branch=v1.7.0 https://github.com/webmproject/libvpx.git
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
  --enable-vp9-temporal-denoising

#  --enable-better-hw-compatibility \

make -j 4
make install

cd $_SRC_
git clone --depth=1 --branch=v1.3-rc https://github.com/xiph/opus.git
cd opus
./autogen.sh
export CFLAGS=" $CF2 $CF3 "
export CXXFLAGS=" $CF2 $CF3 "
./configure --prefix=$_INST_ --disable-shared
make -j 4
make install

else
  echo "option: *CACHE*"
  export CFLAGS=" $CF2 $CF3 "
  export CXXFLAGS=" $CF2 $CF3 "

  ls -al $_INST_/include/

  # -- get the source into the image --
  cd $_SRC_
  rm -Rf libav
  git clone https://github.com/libav/libav
  cd libav
  git checkout v12.3

  cd $_SRC_
  rm -Rf x264
  git clone git://git.videolan.org/x264.git
  cd x264
  git checkout 0a84d986e7020f8344f00752e3600b9769cc1e85 # stable

  cd $_SRC_
  rm -Rf libsodium
  git clone --depth=1 --branch=1.0.16 https://github.com/jedisct1/libsodium.git

  cd $_SRC_
  rm -Rf libvpx
  git clone --depth=1 --branch=v1.7.0 https://github.com/webmproject/libvpx.git

  cd $_SRC_
  rm -Rf opus
  git clone --depth=1 --branch=v1.3-rc https://github.com/xiph/opus.git
  # -- get the source into the image --

  cd $_SRC_
  rm -Rf c-toxcore/
fi

cd $_SRC_
git clone https://github.com/Zoxcore/c-toxcore
cd c-toxcore
git checkout "release"

sed -i -e 'sm#define DISABLE_H264_ENCODER_FEATURE.*m#define DISABLE_H264_ENCODER_FEATURE 1m' toxav/rtp.c
cat toxav/rtp.c |grep 'define DISABLE_H264_ENCODER_FEATURE'

./autogen.sh
make clean
export CFLAGS=" $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 -g -fstack-protector-all "
export LDFLAGS=-L$_INST_/lib

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared
make -j 4 || exit 1
make install


cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


gcc \
-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
-I/opt/vc/include -I/opt/vc/interface/vmcs_host/linux -I/opt/vc/interface/vcos/pthreads \
$CF2 $CF3 \
-fstack-protector-all \
-Wno-unused-variable \
-fPIC -export-dynamic -I$_INST_/include -o toxblinkenwall -lm \
toxblinkenwall.c openGL/esUtil.c openGL/esShader.c rb.c \
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
-L/opt/vc/lib -lbcm_host -lvcos -lopenmaxil

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
