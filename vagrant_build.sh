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

# quilt qemu-user-static debootstrap zip libarchive-tools qemu-utils pigz

echo '#! /bin/bash
    git clone https://github.com/RPi-Distro/pi-gen
    cd pi-gen/
    git checkout "2023-12-05-raspios-bookworm"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
        binfmt-support quilt qemu-user-static \
        debootstrap zip libarchive-tools \
        qemu-utils pigz
    modprobe nbd
    modprobe binfmt_misc
    update-binfmts --enable
    lsmod | grep nbd
    lsmod | grep binfmt_misc
    echo "IMG_NAME=Raspbian" > config
    echo "DISABLE_FIRST_BOOT_USER_RENAME=1" >> config
    echo "FIRST_USER_PASS=984a755nb7349r857348t9573495" >> config

    touch ./stage3/SKIP
    touch ./stage4/SKIP ./stage5/SKIP
    touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

    # custom parts ----------------------------
    # custom parts ----------------------------
    export CIRCLE_PROJECT_USERNAME="zoff99"
    export CIRCLE_BRANCH="master"
    export CIRCLE_PROJECT_REPONAME="ToxBlinkenwall"
    pwd
    cp -av /data/stage2 ./
    cd ./stage2
    find . -type f | xargs -L1 chmod a+x
    ls -alR
    cd ../
    # give name of CI vars to docker
    echo "$CIRCLE_PROJECT_USERNAME" > ./stage3/_GIT_PROJECT_USERNAME_
    echo "$CIRCLE_PROJECT_USERNAME"
    cat ./stage3/_GIT_PROJECT_USERNAME_
    echo "$CIRCLE_PROJECT_REPONAME" > ./stage3/_GIT_PROJECT_REPONAME_
    echo "$CIRCLE_PROJECT_REPONAME"
    cat ./stage3/_GIT_PROJECT_REPONAME_
    echo "$CIRCLE_BRANCH" > ./stage3/_GIT_BRANCH_
    echo "$CIRCLE_BRANCH"
    cat ./stage3/_GIT_BRANCH_
    ls -al ./stage3/
    # custom parts ----------------------------
    # custom parts ----------------------------

    ./build.sh

    # save generated image --------------------
    # save generated image --------------------
    mkdir -p deploy2/
    find -name "*Raspbian-lite.zip"
    find -name "\*Raspbian-lite.zip"
    cp -av deploy/image_*-Raspbian-lite.zip deploy2/image-Raspbian-lite.zip
    cp -av deploy/build.log deploy2/
    ls -hal deploy2/
    cd deploy2/ ; mv -v * /artefacts/
    # save generated image --------------------
    # save generated image --------------------

' > ./artefacts/runme.sh

chmod a+x ./artefacts/runme.sh

vagrant destroy -f
vagrant up



