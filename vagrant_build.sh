#! /bin/bash


_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo $_HOME_
cd $_HOME_

mkdir -p ./artefacts/
rm -Rf ./data/
mkdir -p ./data/

rsync -avz ./stage2 ./data/

echo '#! /bin/bash
    rm -f /var/lib/apt/lists/lock
    rm -f /var/cache/apt/archives/lock
    apt-get update > /dev/null 2> /dev/null

    export CIRCLE_PROJECT_USERNAME="zoff99"
    export CIRCLE_BRANCH="master"

    cd
    mkdir -p work
    export _HOME_=$(pwd)
    echo $_HOME_

    apt-get install -y --no-install-recommends \
    quilt parted realpath qemu-user-static debootstrap zerofree pxz zip \
    dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl \
    openssl ca-certificates git sudo bc wget rsync

    # docker --------
    apt-get install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    # --
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    # --
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    # --
    apt-get update
    # --
    apt-get install -y docker-ce docker-ce-cli containerd.io
    # docker --------

    cd $_HOME_;git clone https://github.com/RPi-Distro/pi-gen ; cd pi-gen ; git checkout "2018-11-13-raspbian-stretch"
    cd $_HOME_;cp -av /data/stage2 pi-gen/
    cd $_HOME_;cd ./pi-gen/stage2 ; find . -type f | xargs -L1 chmod a+x
    cd $_HOME_;cd ./pi-gen/stage2 ; ls -alR
    # give name of CI vars to docker
    cd $_HOME_;echo "$CIRCLE_PROJECT_USERNAME" > ./pi-gen/stage3/_GIT_PROJECT_USERNAME_
    cd $_HOME_;echo "$CIRCLE_PROJECT_USERNAME"; cat ./pi-gen/stage3/_GIT_PROJECT_USERNAME_
    cd $_HOME_;echo "$CIRCLE_PROJECT_REPONAME" > ./pi-gen/stage3/_GIT_PROJECT_REPONAME_
    cd $_HOME_;echo "$CIRCLE_PROJECT_REPONAME"; cat ./pi-gen/stage3/_GIT_PROJECT_REPONAME_
    cd $_HOME_;echo "$CIRCLE_BRANCH" > ./pi-gen/stage3/_GIT_BRANCH_
    cd $_HOME_;echo "$CIRCLE_BRANCH"; cat ./pi-gen/stage3/_GIT_BRANCH_

    # add ToxBlinkenwall custom build stuff ----------
    cd $_HOME_;cd pi-gen;echo "IMG_NAME=Raspbian" > config
    cd $_HOME_;cd pi-gen;touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
    cd $_HOME_;cd pi-gen;touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

    # load module for ARM binaries -------------------
    modprobe binfmt_misc
    cd $_HOME_;cd pi-gen;./build-docker.sh # ./build.sh

    cd $_HOME_;cd pi-gen; mkdir -p deploy2/
    cd $_HOME_;cd pi-gen; cp -av deploy/image_*-Raspbian-lite.zip deploy2/image-Raspbian-lite.zip
    cd $_HOME_;cd pi-gen; cp -av deploy/build.log deploy2/
    cd $_HOME_;cd pi-gen; ls -hal deploy2/
    # save artefacts ---------------------------------
    cd $_HOME_;cd pi-gen; cd deploy2/ ; mv -v * /artefacts/


' > ./artefacts/runme.sh

chmod a+x ./artefacts/runme.sh

vagrant destroy -f
vagrant up

