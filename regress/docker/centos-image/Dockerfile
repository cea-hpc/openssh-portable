FROM centos:7

# Install development environment to compile sftp
RUN set -ex \
	&& yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& yum -y update \
	&& yum -y install autoconf gcc git make openssh-server openssl-devel pam-devel time zlib-devel

# Copy ssh keys to root
RUN set -ex && install -d -m0700 /root/.ssh
COPY ./ssh/id_ed25519.pub /root/.ssh/authorized_keys
COPY ./ssh/id_ed25519* ./ssh/known_hosts /root/.ssh/
RUN chmod 0600 /root/.ssh/authorized_keys /root/.ssh/id_ed25519

# Copy sshd keys
COPY ./ssh/ssh_config /etc/ssh/
RUN chmod 0644 /etc/ssh/ssh_config
COPY ./ssh/ssh_host_ed25519_key* /etc/ssh/
RUN chmod 0600 /etc/ssh/ssh_host_ed25519_key

# Copy sshd configurations
COPY ./ssh/sshd_config /etc/ssh/

# Copy entrypoint for tester
COPY ./openssh.sh /root/
COPY ./test.sh /root/
