#!/bin/bash

CMD=`realpath $0`
CONFIG_BOARD_DIR=`dirname $CMD`
TOP_DIR=$(realpath $CONFIG_BOARD_DIR/../../../)
echo "TOP DIR = $TOP_DIR"
BUILD_DIR=$TOP_DIR/build
[[ ! -d "$BUILD_DIR" ]] && mkdir -p $BUILD_DIR

# env
export CPU=a311d
export BOARD=radxa-zero2
export MODEL=ubuntu
export DISTRO=focal
export VARIANT=server
export ARCH=arm64
export FORMAT=mbr
export IMAGESIZE=2000MB

# Add pre-installed packages for target system
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-packages.list <<EOF
amlogic-overlay*.deb
linux-headers-5.10.69*amlogic*.deb
linux-image-5.10.69*amlogic*.deb
linux-5.10-radxa-zero-latest*.deb
resize-assistant*.deb
amlogic-adbd*.deb
libmraa-focal_*_arm64.deb
EOF

# Add yaml variable
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-variable.yaml <<EOF
{{- \$board := or .board "${BOARD}" -}}
{{- \$architecture := or .architecture "${ARCH}" -}}
{{- \$model :=  or .model "${MODEL}" -}}
{{- \$suite := or  .suite "${DISTRO}" -}}
{{- \$imagesize := or .imagesize "${IMAGESIZE}" -}}
{{- \$bootpartitionend := or .bootpartitionend "1081343S" -}}
{{- \$rootpartitionstart := or .rootpartitionstart "1081344S" -}}
{{- \$apt_repo := or .apt_repo "radxa" -}}

EOF

# Add images yaml
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-yaml.list <<EOF
00_architecture.yaml
01_debootstrap_ubuntu.yaml
02_partitions_amlogic.yaml
03_filesystem_deploy.yaml
20_packages_start.yaml
21_packages_base.yaml
21_packages_bluetooth.yaml
21_packages_devel.yaml
21_packages_libs_ubuntu.yaml
21_packages_math.yaml
21_packages_python_ubuntu.yaml
21_packages_sound.yaml
21_packages_utilities.yaml
21_packages_net.yaml
22_packages_end.yaml
30_overlays.yaml
60_setup_user.yaml
61_add_apt_sources.yaml
62_fix_resolv_conf.yaml
63_setup_hostname_hosts.yaml
65_fix_uenv.yaml
80_preinstall_tb_packages.yaml
84_preinstall_u-boot.yaml
85_u_boot_amlogic.yaml
90_clean_rootfs.yaml
EOF