SHELL = /bin/bash
TARGETS = extip extip6 myip myip6 ifip6 nonsequitur zero-out-rootfs-freespace dusage pushsslcert2fb testmail clean crondtab kpclean ctab ghrelease ruthe whateverrun syncthing-upd ascreens upgchk screenify spamlearn doAptUpgrade ddfbset homeaddr f2bsts

LBINDIR = /usr/local/bin

install: $(TARGETS)
	@for n in $(TARGETS);\
	do \
	diff -q $$n $(LBINDIR)/$$n > /dev/null;\
	if [ "$$?" != "0"	];then \
	   echo sudo install -m 755 -t $(LBINDIR) $$n;\
	   sudo install -m 755 -t $(LBINDIR) $$n;\
	fi;\
	done;\
	echo for dusage;\
	echo " cp -n" dusagelimits ~/.dusagelimits;\
	cp -n dusagelimits ~/.dusagelimits;\
	echo "ln -s LBINDIR/whateverrun LBINDIR/dusagerun";\
	ln -sf LBINDIR/whateverrun$LBINDIR/dusagerun;\

copyright: $(TARGETS)
	crnupdate $(TARGETS)

asset: $(TARGETS)
	zip asset.zip $(TARGETS)

# Code below is from template!
usage:
	@echo "please use"
	@echo "  make fritz"
	@echo "  or"
	@echo "  make tools"

fritz: $(FBTARGETS)
	install -m 755 -t $(LBINDIR) $(FBTARGETS)

tools: $(TOOLTARGETS)
	install -m 755 -t $(LBINDIR) $(TOOLTARGETS)
