###########################################################
#
# ds101-bootstrap
#
# Creates an ipk for bootstrapping the DS-101. Also
# includes missing GLIBC libraries
#
###########################################################

ifeq ($(OPTWARE_TARGET),ds101)
DS101_GLIBC_VERSION=2.3.3
endif
ifeq ($(OPTWARE_TARGET),ds101g)
DS101_GLIBC_VERSION=2.3.3
endif
DS101_BOOTSTRAP_VERSION=1.0
DS101_BOOTSTRAP_DIR=ds101-bootstrap-$(DS101_BOOTSTRAP_VERSION)
DS101_BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DS101_BOOTSTRAP_DESCRIPTION=Bootstrap package for the DS-10x
DS101_BOOTSTRAP_SECTION=util
DS101_BOOTSTRAP_PRIORITY=optional
DS101_BOOTSTRAP_DEPENDS=
DS101_BOOTSTRAP_CONFLICTS=

DS101_BOOTSTRAP_IPK_VERSION=4

DS101_BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/ds101-bootstrap
DS101_BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/ds101-bootstrap
DS101_BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/ds101-bootstrap-$(DS101_BOOTSTRAP_VERSION)-ipk
DS101_BOOTSTRAP_IPK=$(BUILD_DIR)/ds101-bootstrap_$(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
DS101_BOOTSTRAP_XSH=$(BUILD_DIR)/ds101-bootstrap_$(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).xsh

$(DS101_BOOTSTRAP_BUILD_DIR)/.configured: $(DS101_BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(DS101_BOOTSTRAP_DIR) $(DS101_BOOTSTRAP_BUILD_DIR)
	mkdir -p $(DS101_BOOTSTRAP_BUILD_DIR)
	touch $@

ds101-bootstrap-unpack: $(DS101_BOOTSTRAP_BUILD_DIR)/.configured

$(DS101_BOOTSTRAP_BUILD_DIR)/.built: $(DS101_BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(OPTWARE_TARGET),ds101)
	cp -R $(TARGET_LIBDIR)/* $(DS101_BOOTSTRAP_BUILD_DIR)/
	find $(DS101_BOOTSTRAP_BUILD_DIR)/ -type l |xargs rm
	rm -rf $(DS101_BOOTSTRAP_BUILD_DIR)/*.dir
	rm -f $(DS101_BOOTSTRAP_BUILD_DIR)/libc\.* $(DS101_BOOTSTRAP_BUILD_DIR)/libpthread* $(DS101_BOOTSTRAP_BUILD_DIR)/libnss_files*
else
	cp $(TARGET_LIBDIR)/libpthread-0.*.so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/librt-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/libutil-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/libgcc_s.so.1 $(DS101_BOOTSTRAP_BUILD_DIR)/
endif
	cp $(TARGET_LIBDIR)/../sbin/ldconfig $(DS101_BOOTSTRAP_BUILD_DIR)/
	$(INSTALL) -m 644 $(IPKG-OPT_SOURCE_DIR)/rc.optware $(DS101_BOOTSTRAP_BUILD_DIR)/
	touch $@

ds101-bootstrap: $(DS101_BOOTSTRAP_BUILD_DIR)/.built

$(DS101_BOOTSTRAP_BUILD_DIR)/.staged: $(DS101_BOOTSTRAP_BUILD_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -d $(STAGING_PREFIX)/sbin
	$(INSTALL) -d $(STAGING_PREFIX)/etc
	$(INSTALL) -d $(STAGING_DIR)/writeable/lib
ifeq ($(OPTWARE_TARGET),ds101)
	$(INSTALL) -d $(STAGING_LIB_DIR)/gconv
	$(INSTALL) -d $(STAGING_LIB_DIR)/ldscripts
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/*crt* $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/lib* $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/gconv/* $(STAGING_LIB_DIR)/gconv
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(STAGING_LIB_DIR)/ldscripts	
	rm -f $(STAGING_LIB_DIR)/libc\.* $(STAGING_LIB_DIR)/libpthread* $(STAGING_LIB_DIR)/libnss_files*
else
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libpthread-0.*.so $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/librt-$(DS101_GLIBC_VERSION).so $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libutil-$(DS101_GLIBC_VERSION).so $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libgcc_s.so.1 $(STAGING_LIB_DIR)
endif
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldconfig $(STAGING_PREFIX)/sbin
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/rc.optware $(STAGING_PREFIX)/etc
	touch $@

ds101-bootstrap-stage: $(DS101_BOOTSTRAP_BUILD_DIR)/.staged

$(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ds101-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DS101_BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(DS101_BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DS101_BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(DS101_BOOTSTRAP_SITE)/$(DS101_BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(DS101_BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(DS101_BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(DS101_BOOTSTRAP_CONFLICTS)" >>$@

$(DS101_BOOTSTRAP_IPK): $(DS101_BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(DS101_BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/ds101-bootstrap_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)/writeable/lib
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib
ifeq ($(OPTWARE_TARGET),ds101)
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/gconv
	$(INSTALL) -d $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/ldscripts
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/*crt* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/lib* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/gconv/* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/gconv/
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/ldscripts/
	rm -f $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/libc* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/libpthread* $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/libnss_files*
else	
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libpthread-0.*.so $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/librt-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libutil-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libgcc_s.so.1 $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib
endif
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldconfig $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/rc.optware $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/etc

	$(STRIP_COMMAND) $(DS101_BOOTSTRAP_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	$(MAKE) $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/preinst $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/preinst
	$(INSTALL) -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/postinst $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DS101_BOOTSTRAP_IPK_DIR)

$(DS101_BOOTSTRAP_XSH): $(DS101_BOOTSTRAP_IPK) \
		$(BUILD_DIR)/ipkg-opt/.ipk $(BUILD_DIR)/openssl/.ipk $(BUILD_DIR)/wget-ssl/.ipk
	rm -rf $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap
	mkdir -p $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(DS101_BOOTSTRAP_IPK) $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.ipk
	# Additional ipk's we require
	cp $(IPKG-OPT_IPK) $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap/ipkg.ipk
	cp $(OPENSSL_IPK) $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap/openssl.ipk
	cp $(WGET-SSL_IPK) $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap/wget-ssl.ipk
	# bootstrap scripts
	$(INSTALL) -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/bootstrap.sh $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap
	$(INSTALL) -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/ipkg.sh $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap

	# If you should ever change the archive header (echo lines below), 
	# make sure to recalculate dd's bs= argument, otherwise the self-
	# extracting archive will break! Using tail+n would be much simpler
	# but the tail command available on the DS-101 doesn't support this.
	echo "#!/bin/sh" >$@
	echo 'echo "DS-10x Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=181 skip=1| tar xvz' >>$@
	echo "cd bootstrap && sh bootstrap.sh && cd .. && rm -r bootstrap" >>$@
	echo 'exec /bin/sh --login' >>$@
	tar -C $(DS101_BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@

ds101-bootstrap-ipk: $(DS101_BOOTSTRAP_XSH)
ds101-bootstrap-xsh: $(DS101_BOOTSTRAP_XSH)

ds101-bootstrap-clean:
	rm -rf $(DS101_BOOTSTRAP_BUILD_DIR)/*

ds101-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(DS101_BOOTSTRAP_DIR) $(DS101_BOOTSTRAP_BUILD_DIR) $(DS101_BOOTSTRAP_IPK_DIR) $(DS101_BOOTSTRAP_IPK) $(DS101_BOOTSTRAP_XSH)
	rm -rf $(DS101_BOOTSTRAP_BUILD_DIR)/bootstrap
