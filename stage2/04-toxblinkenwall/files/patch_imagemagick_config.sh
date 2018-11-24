#! /bin/bash

echo "patching ImageMagick config ..."
sed -i -e 's#^.*<policy domain="path".*$#<!-- removed by ToxBlinkenwall -->#g' "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml"
echo "... ready"
echo "---------------------------------"
echo "changes in ImageMagick config:"
diff "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml.BACKUP" "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml"
echo "---------------------------------"
