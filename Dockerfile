FROM registry.access.redhat.com/ubi8/ubi:8.1


LABEL image="Redhat UBI 8"
LABEL file_version="1.0.0"
LABEL package_mgr="Nix"
LABEL software.version="1.0.0"
LABEL summary="Container image with RedHat and the Nix package manager installed"
LABEL license="MIT"
LABEL author="tselva <selva005@gmail.com>"


RUN yum -y update \
	&& yum -y install bzip2 wget sudo curl git xz \
	&& yum clean all

RUN yum -y install openssh-server.x86_64 \
	&& cd /etc/ssh \
	&& ssh-keygen -A

RUN groupadd nixbld \
	&& adduser user \
	&& usermod -a -G wheel user \
	&& usermod -a -G nixbld user \
	&& passwd -d root \
	&& echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user:user
WORKDIR /home/user

ONBUILD ENV \
	USER=user \
	PATH=$PATH:/nix/var/nix/profiles/per-user/user/profile/bin

RUN curl -L https://nixos.org/nix/install | sh


ENV \
	USER=user \
	PATH=$PATH:/nix/var/nix/profiles/per-user/user/profile/bin
RUN . /home/user/.nix-profile/etc/profile.d/nix.sh

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

