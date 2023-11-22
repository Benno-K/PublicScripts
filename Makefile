SHELL = /bin/bash
TARGETS = extip myip nonsequitur zero-out-rootfs-freespace diskusage pushsslcert2fb testmail clean crondtab kpclean ctab ghrelease ruthe

LBINDIR = /usr/local/bin

install: $(TARGETS)
	@for n in $(TARGETS);\
	do \
	diff -q $$n $(LBINDIR)/$$n > /dev/null;\
	if [ "$$?" != "0"	];then \
	   echo sudo install -m 755 -t $(LBINDIR) $$n;\
	   sudo install -m 755 -t $(LBINDIR) $$n;\
	fi;\
	done

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
