#!/bin/bash

set -eux

# Compile sftp
rm -rf /tmp/openssh-portable
git clone /openssh-portable /tmp/openssh-portable
cd /tmp/openssh-portable
autoreconf
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-kerberos5
make sftp

# Run tests
/root/test.sh
