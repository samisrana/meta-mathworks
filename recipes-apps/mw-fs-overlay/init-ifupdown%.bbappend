FILESEXTRAPATHS:prepend := "${THISDIR}/files/common/fs-overlay:"

do_install:append() {
    install -d ${D}${sysconfdir}/network
    install -m 0644 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/interfaces
}

