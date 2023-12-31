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

git clone https://github.com/zoff99/ToxBlinkenwall tmp
cd tmp
git checkout "master"

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


mkdir -p $_SRC_
mkdir -p $_INST_
sudo chown -R pi:pi $_SRC_
sudo chown -R pi:pi $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig

cd $_SRC_

git clone https://github.com/zoff99/c-toxcore
cd c-toxcore
git checkout "zoff99/zoxcore_local_fork"

./autogen.sh
make clean
export CFLAGS=" -fPIC -DHW_CODEC_CONFIG_RPI3_TBW_TV -DTOX_CAPABILITIES_ACTIVE -D_GNU_SOURCE -O3 \
                --param=ssp-buffer-size=1 -g -fstack-protector-all "

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared || exit 1
make -j $(nproc) || exit 1
make install || exit 1


cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


_OO_=" -g -O3 -fno-omit-frame-pointer -Wstack-protector \
      -fstack-protector-all \
      --param=ssp-buffer-size=1 "

gcc $_OO_ \
-DHW_CODEC_CONFIG_RPI3_TBW_TV \
-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
-Wno-unused-variable \
-fPIC -export-dynamic -I$_INST_/include -o toxblinkenwall -lm \
toxblinkenwall.c rb.c \
-std=gnu99 \
-L$_INST_/lib \
$_INST_/lib/libtoxcore.a \
$_INST_/lib/libtoxav.a \
-lrt \
-lm \
-lopus \
-lvpx \
-lx264 \
-lSDL2 \
-lavcodec \
-lavutil \
-lsodium \
-lasound \
-lpthread -lv4lconvert


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
