SHELL = /bin/bash
TARGETS = fritzip myip nonsequitur zero-out-rootfs-freespace dusage pushsslcert2fb testmail clean crondtab kpclean ctab ghrelease ruthe whateverrun syncthing-upd ascreens upgchk screenify spamlearn doAptUpgrade htmlwrap htmlmailx ddfbset homeaddr f2bsts friedl ddnstool githooks
UTARGETS=nsimgurl shredLenovoWSg diskmon
PTARGETS=git-web-viewer.php webgit.php

LBINDIR = /usr/local/bin
UBINDIR = ~/bin
PBINDIR = /data/www
PSTYDIR = $(PBINDIR)/webgit-style
POWNER  = www-data
PGROUP  = www-data
PSTYLES	= dark-theme light-theme webgit-layout

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

restofabove:
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

webgit:
	@for n in $(PTARGETS);\
	do \
	sudo diff -q $$n $(PBINDIR)/$$n > /dev/null;\
	if [ "$$?" != "0"	];then \
     echo sudo installing in $(PBINDIR): $$n;\
	   sudo install -o $(POWNER) -g $(PGROUP) -m 500 -t $(PBINDIR) $$n;\
	fi;\
	done;\
	for n in $(PSTYLES);\
	do \
	sudo diff -q $$n.css $(PSTYDIR)/$$n.css > /dev/null;\
	if [ "$$?" != "0"	];then \
     echo sudo installing in $(PSTYDIR): $$n.css;\
	   sudo install -o $(POWNER) -g $(PGROUP) -m 400 -t $(PSTYDIR) $$n.css;\
	fi;\
	done;\

webgitlayout: webgit-layout.css
	@sudo diff -q webgit-layout.css $(PSTYDIR)/webgit-layout.css > /dev/null; \
	if [ "$$?" != "0"	];then \
    echo sudo installing in $(PSTYDIR)/webgit-style: style webgit-layout.css;\
		sudo install -o $(POWNER) -g $(PGROUP) -m 400 -t $(PBINDIR)/webgit-style  webgit-layout.css; \
	fi;\

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
