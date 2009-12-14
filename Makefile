# Written by Simon Josefsson <simon@josefsson.org>.
# Copyright (c) 2009 Yubico AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

VERSION=1.1
PACKAGE=yubikey-ksm
CODE=ykksm-config.php ykksm-decrypt.php ykksm-gen-keys.pl		\
	ykksm-upgrade.pl ykksm-db.sql ykksm-export.pl ykksm-import.pl	\
	ykksm-utils.php .htaccess
DOCS=doc/DecryptionProtocol.wiki doc/DesignGoals.wiki		\
	doc/GenerateKeys.wiki doc/ImportKeysToKSM.wiki		\
	doc/Installation.wiki doc/KeyProvisioningFormat.wiki

all: $(PACKAGE)-$(VERSION).tgz

$(PACKAGE)-$(VERSION).tgz: $(FILES)
	mkdir $(PACKAGE)-$(VERSION) $(PACKAGE)-$(VERSION)/doc
	cp $(CODE) $(PACKAGE)-$(VERSION)/
	cp $(DOCS) $(PACKAGE)-$(VERSION)/doc/
	tar cfz $(PACKAGE)-$(VERSION).tgz $(PACKAGE)-$(VERSION)
	rm -rf $(PACKAGE)-$(VERSION)

clean:
	rm -f *~
	rm -rf $(PACKAGE)-$(VERSION)

etcprefix = /etc/ykksm
binprefix = /usr/bin
phpprefix = /usr/share/ykksm
docprefix = /usr/share/doc/ykksm

install:
	install -D ykksm-decrypt.php $(phpprefix)/ykksm-decrypt.php
	install -D ykksm-utils.php $(phpprefix)/ykksm-utils.php
	install -D ykksm-gen-keys.pl $(binprefix)/bin/ykksm-gen-keys
	install -D ykksm-import.pl $(binprefix)/ykksm-import
	install -D ykksm-export.pl $(binprefix)/ykksm-export
	install -D ykksm-config.php $(etcprefix)/config.php
	install -D ykksm-db.sql $(docprefix)/ykksm-db.sql
	install -D $(DOCS) $(docprefix)/

PROJECT=yubikey-ksm
USER=simon75j
KEYID=B9156397

release:
	make
	gpg --detach-sign --default-key $(KEYID) $(PACKAGE)-$(VERSION).tgz
	gpg --verify $(PACKAGE)-$(VERSION).tgz.sig
	svn copy https://$(PROJECT).googlecode.com/svn/trunk/ \
	 https://$(PROJECT).googlecode.com/svn/tags/$(PACKAGE)-$(VERSION) \
	 -m "Tagging the $(VERSION) release of the $(PACKAGE) project."
	googlecode_upload.py -s "OpenPGP signature for $(PACKAGE) $(VERSION)." \
	 -p $(PROJECT) -u $(USER) $(PACKAGE)-$(VERSION).tgz.sig
	googlecode_upload.py -s "$(PACKAGE) $(VERSION)." \
	 -p $(PROJECT) -u $(USER) $(PACKAGE)-$(VERSION).tgz 
