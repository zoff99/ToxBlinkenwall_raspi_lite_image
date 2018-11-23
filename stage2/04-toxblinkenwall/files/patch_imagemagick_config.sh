#! /bin/bash

echo "patching ImageMagick config ..."
sed -i -e 's#^.*<policy domain="path".*$#<!-- removed by ToxBlinkenwall -->#g' /etc/ImageMagick-6/policy.xml
echo "... ready"
