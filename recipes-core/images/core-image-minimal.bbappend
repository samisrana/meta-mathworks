IMAGE_INSTALL:append = " boost"
IMAGE_INSTALL:append = " openssh-sftp-server"
IMAGE_INSTALL:append = " libubootenv-bin"
IMAGE_INSTALL:append = " busybox-udhcpd busybox-udhcpc "
IMAGE_INSTALL:append = " libusb-compat libserialport libiio libiio-iiod libiio-tests "
#IMAGE_INSTALL:append = " libusb-compat libserialport libiio libiio-tests "
#IMAGE_INSTALL:append = " lttng-ust lttng-ust-bin lttng-tools lttng-modules"
IMAGE_INSTALL:append = " avahi-utils avahi-daemon avahi-autoipd"
IMAGE_INSTALL:append = " dtc"
IMAGE_INSTALL:append = " procps"
IMAGE_INSTALL:append = " libsysfs sysfsutils libconfig util-linux sed"


inherit extrausers
# Set root password as "cyclonevsoc" (argument -p for usermod is obtained using 'mkpasswd -m sha-512 root')
EXTRA_USERS_PARAMS = " \
usermod -p '\$6\$WR/8UtKTrBI\$ws/orbjj4P6jA8sYCBnWhKMwuORdQJR8LOQApnE96UqhtS/vy4olMAMKn/xneYF0gtiBsCekyxX8Wqy0cr5o40' root\
"


# SSHD_CONFIG
SSHD_CONFIG_FILE ?= "${IMAGE_ROOTFS}${sysconfdir}/ssh/sshd_config"
# DROPBEAR config
DROPBEAR_CONFIG_FILE ?= "${IMAGE_ROOTFS}${sysconfdir}/default/dropbear"

# Modify the serial console config and the video console config files.
GETTY_SYSVINIT_UNIT ?= "${IMAGE_ROOTFS}${sysconfdir}/inittab"
GETTY_SYSTEMD_UNITS ?= " \
     ${IMAGE_ROOTFS}${systemd_system_unitdir}/serial-getty@.service \
     ${IMAGE_ROOTFS}${systemd_system_unitdir}/getty@.service \
"
#  Modify the systemd unit configuration files
l_enable_autologin () {
	for unit in ${GETTY_SYSTEMD_UNITS}; do
		if [ -f $unit ]; then
	    		sed -i -e 's/^\(ExecStart *=.*getty \)/\1--autologin root /' $unit
		fi
	done
	if [ -f ${GETTY_SYSVINIT_UNIT} ]; then
	    sed -i 's/\/bin\/start_getty\(.*\)/\/sbin\/getty\1 -a root/' ${GETTY_SYSVINIT_UNIT} 
	fi


}

l_permit_sshrootlogin () {
	if [ -f ${SSHD_CONFIG_FILE} ]; then
	    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' ${SSHD_CONFIG_FILE}
	fi
	if [ -f ${DROPBEAR_CONFIG_FILE} ]; then
	    sed -i 's/-w//g' ${DROPBEAR_CONFIG_FILE}
	fi
}

ROOTFS_POSTPROCESS_COMMAND:append = "l_enable_autologin; \
				     l_permit_sshrootlogin;"


