#! /bin/bash

cd

export _HOME_=$(pwd)
echo $_HOME_
cd $_HOME_/ToxBlinkenwall/toxblinkenwall/


export CF2=" -fPIE -pie -fPIC -O3 -g -marm -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize "
export CFX2=" -fPIE -pie -fPIC -marm -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize "
export CF3="" # " -funsafe-math-optimizations "
export VV1=" VERBOSE=1 V=1 "

export FULL=0

if [ -f "OPTION_DEV_BUILD_FULL" ]; then
    FULL=1
    export FULL
fi


export ASAN=1

if [ "$ASAN""x" == "1x" ]; then
	ASZI=" -fsanitize=address -fno-omit-frame-pointer " # "-static-libasan "
	ASZL="" # " -static-libasan "
fi

./initscript.sh stop

cat /dev/zero > /dev/fb0
sleep 1

export _SRC_=$_HOME_/src/
export _INST_=$_HOME_/inst/

mkdir -p $_SRC_
mkdir -p $_INST_

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig




if [ "$FULL""x" == "1x" ]; then

    cd $_SRC_
    rm -Rf x264
    git clone git://git.videolan.org/x264.git
    cd x264
    git checkout 0a84d986e7020f8344f00752e3600b9769cc1e85 # stable
    ./configure --prefix=$_INST_ --disable-opencl --enable-static \
    --disable-avs --disable-cli --enable-pic

    find . -name libtool

    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool

    make clean
    make -j $(nproc)
    make install

fi



if [ "$FULL""x" == "1x" ]; then

    export CFLAGS="-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
    -I/opt/vc/include -I/opt/vc/interface/vmcs_host/linux -I/opt/vc/interface/vcos/pthreads \
    $CF2 $CF3 \
    -I/opt/vc/include \
    -I/opt/vc/include/IL/ \
    -I/opt/vc/interface/vmcs_host/linux \
    -I/opt/vc/interface/vcos/pthreads "

    cd $_SRC_
    rm -Rf libav
    git clone https://github.com/FFmpeg/FFmpeg libav
    cd libav
    git checkout n4.1.1
    ./configure --prefix=$_INST_ \
    --enable-pthreads \
    --disable-shared --enable-static \
    --disable-doc \
    --disable-swscale \
    --enable-ffmpeg --enable-ffprobe \
    --disable-network --disable-everything \
    --enable-outdev=fbdev \
    --enable-opengl \
    --enable-outdev=opengl \
    --disable-bzlib \
    --disable-libxcb-shm \
    --disable-libxcb-xfixes \
    --enable-parser=h264 \
    --enable-runtime-cpudetect \
    --enable-omx-rpi --enable-mmal \
    --enable-omx \
    --enable-decoder=h264_mmal \
    --enable-encoder=h264_omx \
    --enable-gpl --enable-decoder=h264 || exit 1

    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool

    make -j $(nproc)
    make install

fi


if [ "$FULL""x" == "1x" ]; then

    cd $_SRC_
    git clone --depth=1 --branch=1.0.17 https://github.com/jedisct1/libsodium.git
    cd libsodium
    ./autogen.sh
    make clean
    export CFLAGS=" $CF2 "
    ./configure --prefix=$_INST_ --disable-shared --disable-soname-versions # --enable-minimal

    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool

    make -j 4
    make install

fi


if [ "$FULL""x" == "1x" ]; then

    cd $_SRC_
    git clone --depth=1 --branch=v1.8.0 https://github.com/webmproject/libvpx.git
    cd libvpx
    make clean
    export CFLAGS=" $CF2 $CF3 "
    export CXXLAGS=" $CF2 $CF3 "
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

    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool

    make -j $(nproc)
    make install

fi


if [ "$FULL""x" == "1x" ]; then

    cd $_SRC_
    git clone --depth=1 --branch=v1.3 https://github.com/xiph/opus.git
    cd opus
    ./autogen.sh
    make clean
    export CFLAGS=" $CF2 $CF3 "
    export CXXLAGS=" $CF2 $CF3 "
    ./configure --prefix=$_INST_ --disable-shared

    sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
    sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool

    make -j $(nproc)
    make install

fi




cd $_SRC_
cd c-toxcore


./autogen.sh
make clean

export CFLAGS=" -fPIE -pie -fPIC -D HW_CODEC_CONFIG_RPI3_TBW_TV $CF2 \
            -D_GNU_SOURCE -I$_INST_/include/ -O3 -ggdb3 -fstack-protector-all \
            --param=ssp-buffer-size=1 "
export LDFLAGS=" -fPIE -pie -fPIC -ggdb3 -L$_INST_/lib "

./configure \
--prefix=$_INST_ \
--disable-soname-versions --disable-testing --disable-shared

make clean

sed -i -e 'sxpic_mode=.*xpic_mode=yesxg' libtool
sed -i -e 'sxpie_flag=xpie_flag=-fPICxg' libtool


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
    export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libasan.so.3
    export ASAN_OPTIONS=malloc_context_size=100:check_initialization_order=true # verbosity=2:
fi


_OO_=" -ggdb3 -O3 -fno-omit-frame-pointer -Wstack-protector \
      -fstack-protector-all \
      --param=ssp-buffer-size=1 "



gcc $_OO_ \
$ASZI $ASZL \
-fPIE -pie \
-DRASPBERRY_PI -DOMX_SKIP64BIT -DUSE_VCHIQ_ARM \
-I/opt/vc/include -I/opt/vc/interface/vmcs_host/linux -I/opt/vc/interface/vcos/pthreads \
$CF2 $CF3 \
$LL1 \
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

cd $_HOME_

	if [ $res2 -eq 0 ]; then
		$_HOME_/ToxBlinkenwall/toxblinkenwall/initscript.sh start
	else
		echo "ERROR !!"
		# cat /dev/urandom > /dev/fb0
		$_HOME_/fill_fb.sh "1 1 1 1 1"
	fi

else
	echo "ERROR !!"
	cat /dev/urandom > /dev/fb0
fi


rm -f $_HOME_/compile_me.txt

