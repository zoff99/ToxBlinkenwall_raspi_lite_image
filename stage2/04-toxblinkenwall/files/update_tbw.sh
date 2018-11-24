#! /bin/bash

id -a
pwd

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

# shutdown tbw and clear screen ----------
chmod u+x ./initscript.sh
./initscript.sh stop
cat /dev/zero > /dev/fb0
sleep 1
# shutdown tbw and clear screen ----------


export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

export CF2=" -O3 -g -marm -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 \
 -mfloat-abi=hard -ftree-vectorize "
export CF3=" -funsafe-math-optimizations "
export VV1=" VERBOSE=1 V=1 "

mkdir -p $_SRC_
mkdir -p $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig


cd $_SRC_
rm -Rf c-toxcore
git clone https://github.com/Zoxcore/c-toxcore
cd c-toxcore
git checkout "release"

echo "GIT:current branch is:"
cat /pi-gen/_GIT_BRANCH_

./autogen.sh
make clean
export CFLAGS=" $CF2 -D_GNU_SOURCE -I$_INST_/include/ -O3 -g -fstack-protector-all "
export LDFLAGS=-L$_INST_/lib

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared
make -j 4
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
 . ~/.profile
 $_HOME_/ToxBlinkenwall/toxblinkenwall/initscript.sh start
else
 echo "compile: ** ERROR **"
 # show random colors on screen to make error visible
 cat /dev/urandom > /dev/fb0
fi
