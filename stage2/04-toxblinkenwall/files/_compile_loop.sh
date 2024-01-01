#! /bin/bash

cd

export _HOME_=$(pwd)
echo $_HOME_
mkdir -p $_HOME_/ToxBlinkenwall/toxblinkenwall/
cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


export FULL=0

if [ -f "OPTION_DEV_BUILD_FULL" ]; then
    FULL=1
    export FULL
fi


export ASAN=0

if [ "$ASAN""x" == "1x" ]; then
        ASZI=" -fsanitize=address -fsanitize-recover=address -static-libasan -fno-omit-frame-pointer "
	# ASZI=" -fsanitize=address -fno-omit-frame-pointer " # "-static-libasan "
	ASZL="" # " -static-libasan "
fi

export USEPIE=0

if [ "$USEPIE""x" == "1x" ]; then
    PIEFL1=" -fPIE -pie "
fi

export CF2=" -fPIC -O3 -g -fno-omit-frame-pointer"
export CFX2="-fPIC  "
export CF3="" # " -funsafe-math-optimizations "
export VV1=" VERBOSE=1 V=1 "


./initscript.sh stop

cat /dev/zero > /dev/fb0
sleep 1

export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

mkdir -p $_SRC_
mkdir -p $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig



cd $_SRC_
git clone https://github.com/zoff99/c-toxcore
cd c-toxcore


#./autogen.sh
#make clean

export CFLAGS=" $PIEFL1 -fPIC -DHW_CODEC_CONFIG_RPI3_TBW_TV -DTOX_CAPABILITIES_ACTIVE $CF2 \
            -D_GNU_SOURCE -I$_INST_/include/ -O3 -g -fstack-protector-all \
            --param=ssp-buffer-size=1 "
export LDFLAGS=" $PIEFL1 -fPIC -g -L$_INST_/lib "

#./configure \
#--prefix=$_INST_ \
#--disable-soname-versions --disable-testing --disable-shared

#make clean

if [ "$USEPIE""x" == "1x" ]; then
    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool
fi

make $VV1 -j 4
err_code=$?

make install









res=$err_code


echo "#############"
echo "#############"
echo "#############"
echo "#############"

if [ $res -eq 0 ]; then

cd $_HOME_/ToxBlinkenwall/toxblinkenwall/

if [ "$ASAN""x" == "1x" ]; then
   export ASAN_OPTIONS=halt_on_error=0
   # export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libasan.so.3
   # export ASAN_OPTIONS=malloc_context_size=100:check_initialization_order=true # verbosity=2:
fi


_OO_=" -g -O3 -fno-omit-frame-pointer -Wstack-protector \
      -fstack-protector-all \
      --param=ssp-buffer-size=1 "


gcc $_OO_ \
$ASZI $ASZL \
$PIEFL1 \
-DHW_CODEC_CONFIG_RPI3_TBW_TV \
-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
$CF2 $CF3 \
$LL1 \
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

cd $_HOME_

	if [ $res2 -eq 0 ]; then
                :
		$_HOME_/ToxBlinkenwall/toxblinkenwall/initscript.sh start
	else
		echo "ERROR 11 !!"
		cat /dev/urandom > /dev/fb0
		$_HOME_/fill_fb.sh "1 1 1 1 1"
	fi

else
	echo "ERROR 22 !!"
	cat /dev/urandom > /dev/fb0
fi

echo "" > /home/pi/ToxBlinkenwall/toxblinkenwall/scripts/create_gfx.sh

rm -f $_HOME_/compile_me.txt

