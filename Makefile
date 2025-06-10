SHELL = /bin/bash
TARGETS = fritzip myip nonsequitur zero-out-rootfs-freespace dusage pushsslcert2fb testmail clean crondtab kpclean ctab ghrelease ruthe whateverrun syncthing-upd ascreens upgchk screenify spamlearn doAptUpgrade ddfbset homeaddr f2bsts friedl ddnstool githooks
UTARGETS=nsimgurl shredLenovoWSg

LBINDIR = /usr/local/bin
UBINDIR = ~/bin

install: $(TARGETS) $(UTARGETS)
	@for n in $(UTARGETS);\
	do \
	diff -q $$n $(UBINDIR)/$$n > /dev/null;\
	if [ "$$?" != "0"	];then \
	   echo install -m 755 -t $(UBINDIR) $$n;\
	   install -m 755 -t $(UBINDIR) $$n;\
	fi;\
	done
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

friedldoc:
	@ssh s24 "cat st/download/friedl.md" | diff 2>&1 >/dev/null -q - friedl.md;if [ $$? != 0 ]; then scp s24:st/download/friedl.md .;fi
	@ssh s24 "cat st/download/friedlde.md" | diff 2>&1 >/dev/null -q - friedlde.md;if [ $$? != 0 ]; then scp s24:st/download/friedlde.md .;fi

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
