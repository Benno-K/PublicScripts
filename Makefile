TARGETS = extip myip nonsequitur
LBINDIR = /usr/local/bin

install: $(FBTARGETS)
	install -m 755 -t $(LBINDIR) $(FBTARGETS)

Code below is from template!
usage:
	@echo "please use"
	@echo "  make fritz"
	@echo "  or"
	@echo "  make tools"

fritz: $(FBTARGETS)
	install -m 755 -t $(LBINDIR) $(FBTARGETS)

tools: $(TOOLTARGETS)
	install -m 755 -t $(LBINDIR) $(TOOLTARGETS)
