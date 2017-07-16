
TOP :=			$(PWD)
TMPDIR :=		$(TOP)/tmp
PROTO :=		$(TOP)/proto

STAMPS_DIR :=		$(TOP)/make_stamps
STAMPS_REMOVE =		mkdir -p $(STAMPS_DIR); rm -f $@
STAMPS_CREATE =		mkdir -p $(STAMPS_DIR); touch $@

#
# A "sysroot" tarball contains "lib", "usr/lib", and "usr/include" from a
# particular SmartOS platform image.  This directory tree is used with the GCC
# "--sysroot" option, in an attempt to build binaries that will run on an old
# platform rather than just the current build system.
#
SYSROOT_DATE :=		20141030T081701Z
SYSROOT_TAR :=		sysroot.joyent_$(SYSROOT_DATE).tar.gz

MANTA_BASE_URL :=	https://us-east.manta.joyent.com
SYSROOT_BASE_URL :=	$(MANTA_BASE_URL)/Joyent_Dev/public/sysroot
SYSROOT_URL :=		$(SYSROOT_BASE_URL)/$(SYSROOT_TAR)

STAMP_SYSROOT :=	$(STAMPS_DIR)/sysroot
STAMP_ILLUMOS :=	$(STAMPS_DIR)/illumos
STAMP_EXTRACT :=	$(STAMPS_DIR)/extract
STAMP_MAKE_TOOLS :=	$(STAMPS_DIR)/make-tools

SYSROOT :=		$(TOP)/sysroot
ILLUMOS :=		$(TOP)/illumos

CW_PATCH :=		$(TOP)/cw_sysroot.diff

CLOSED_BINS_URL :=	https://download.joyent.com/pub/build/illumos
CLOSED_BINS :=		on-closed-bins.i386.tar.bz2 \
			on-closed-bins-nd.i386.tar.bz2

ONBLD_FILES :=		lib/i386/libctf.so.1 \
			lib/i386/libdwarf.so.1 \
			bin/i386/ctfconvert-altexec \
			bin/i386/ctfdiff \
			bin/i386/ctfdump \
			bin/i386/ctfmerge-altexec \
			bin/i386/ctfstrip

.PHONY: all
all: $(STAMP_MAKE_TOOLS)

$(TMPDIR):
	mkdir -p $@

$(TMPDIR)/$(SYSROOT_TAR): | $(TMPDIR)
	curl -fsS -o $@ "$(SYSROOT_URL)"

$(TMPDIR)/on-closed-bin%: | $(TMPDIR)
	curl -fsS -o $@ "$(CLOSED_BINS_URL)/$(notdir $@)"

$(STAMP_SYSROOT): $(TMPDIR)/$(SYSROOT_TAR) | $(TMPDIR)
	$(STAMPS_REMOVE)
	rm -rf $(SYSROOT)
	mkdir -p $(SYSROOT)
	cd $(SYSROOT) && tar xfz $(TMPDIR)/$(SYSROOT_TAR)
	$(STAMPS_CREATE)

$(STAMP_ILLUMOS): $(CW_PATCH)
	$(STAMPS_REMOVE)
	rm -rf $(ILLUMOS)
	git clone https://github.com/joyent/illumos-joyent.git $(ILLUMOS)
	cd $(ILLUMOS) && \
	    git apply $(CW_PATCH)
	$(STAMPS_CREATE)

$(STAMP_EXTRACT): $(STAMP_ILLUMOS) $(addprefix $(TMPDIR)/,$(CLOSED_BINS))
	$(STAMPS_REMOVE)
	cd $(ILLUMOS) && \
	    /usr/bin/tar xpjf $(TMPDIR)/on-closed-bins.i386.tar.bz2 && \
	    /usr/bin/tar xpjf $(TMPDIR)/on-closed-bins-nd.i386.tar.bz2
	$(STAMPS_CREATE)

$(TMPDIR)/env.sh: gen_env.sh
	./gen_env.sh $(ILLUMOS) > $@

$(STAMP_MAKE_TOOLS): $(STAMP_EXTRACT) $(STAMP_SYSROOT) $(TMPDIR)/env.sh
	$(STAMPS_REMOVE)
	/usr/bin/ksh93 '$(ILLUMOS)/usr/src/tools/scripts/bldenv.sh' \
	    "$(TMPDIR)/env.sh" \
	    'export PATH="$$PATH:/opt/local/bin" && \
	    export MAKE=/opt/local/bin/dmake && \
	    export CW_SYSROOT=$(SYSROOT) && \
	    cd "$$SRC/tools" && \
	    SAVEARGS= $$MAKE -e install'
	$(STAMPS_CREATE)

.PHONY: install
install: $(STAMP_MAKE_TOOLS)
	rm -rf $(PROTO)
	mkdir -p $(PROTO)/bin
	(cd $(ILLUMOS)/usr/src/tools/proto/root_i386-nd/opt && \
	    tar cf - $(addprefix onbld/,$(ONBLD_FILES))) | \
	    (cd $(PROTO) && tar xf -)
	ln -s ../onbld/bin/i386/ctfmerge-altexec $(PROTO)/bin/ctfmerge
	ln -s ../onbld/bin/i386/ctfconvert-altexec $(PROTO)/bin/ctfconvert
	ln -s ../onbld/bin/i386/ctfdump $(PROTO)/bin/ctfdump
	ln -s ../onbld/bin/i386/ctfdiff $(PROTO)/bin/ctfdiff
	ln -s ../onbld/bin/i386/ctfstrip $(PROTO)/bin/ctfstrip

.PHONY: tarball
tarball: install
	sha=$$(cd illumos && git rev-parse --short=7 HEAD) && \
	    (cd $(PROTO) && \
	    gtar --numeric-owner --owner=0 --group=0 -czf \
	    $(TOP)/ctftools.$(SYSROOT_DATE).$$sha.tar.gz \
	    onbld bin)

clean:
	test -d $(SYSROOT) && chmod -R u+rwX $(SYSROOT) || true
	rm -rf $(STAMPS_DIR) $(TMPDIR) $(PROTO) $(ILLUMOS) $(SYSROOT)
	rm -f ctftools.*.tar.gz

