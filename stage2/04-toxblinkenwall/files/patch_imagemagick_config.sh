#! /bin/bash

echo "patching ImageMagick config ..."

# sed -i -e 's#^.*<policy domain="path".*$#<!-- removed by ToxBlinkenwall -->#g' "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml"

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policymap [
  <!ELEMENT policymap (policy)+>
  <!ATTLIST policymap xmlns CDATA #FIXED '"''"'>
  <!ELEMENT policy EMPTY>
  <!ATTLIST policy xmlns CDATA #FIXED '"''"' domain NMTOKEN #REQUIRED
    name NMTOKEN #IMPLIED pattern CDATA #IMPLIED rights NMTOKEN #IMPLIED
    stealth NMTOKEN #IMPLIED value CDATA #IMPLIED>
]>
<policymap>
  <policy domain="coder" rights="read|write" pattern="*" />
  <policy domain="resource" name="memory" value="256MiB"/>
  <policy domain="resource" name="map" value="512MiB"/>
  <policy domain="resource" name="width" value="16KP"/>
  <policy domain="resource" name="height" value="16KP"/>
  <policy domain="resource" name="area" value="128MB"/>
  <policy domain="resource" name="disk" value="1GiB"/>
  <policy domain="delegate" rights="none" pattern="URL" />
  <policy domain="delegate" rights="none" pattern="HTTPS" />
  <policy domain="delegate" rights="none" pattern="HTTP" />
</policymap>
' > "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml"

echo "... ready"
echo "---------------------------------"
echo "changes in ImageMagick config:"
diff "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml.BACKUP" "${ROOTFS_DIR}/etc/ImageMagick-6/policy.xml"
echo "---------------------------------"

