RUNSCRIPTS = r-host.sh r-mtalpha-sim.sh r-mtsparc-sim.sh r-mtsparc-fpga.sh r-mipsel-sim.sh \
	r-leon2mt-fpga.sh leon2mt-sim-ctl
EXTRA_DIST += r-host.sh.in r-mt-sim.sh.in r-mtsparc-fpga.sh.in r-leon2mt-fpga.sh.in \
	leon2mt-sim-ctl.in

sllib_SCRIPTS += $(RUNSCRIPTS)
CLEANFILES += $(RUNSCRIPTS)

COMMON_SUBST = \
 -e 's|@BASH[@]|$(BASH)|g' \
 -e 's|@slc_datadir[@]|$(pkgdatadir)|g' \
 -e 's|@slc_libdir[@]|$(pkglibdir)|g' \
 -e 's|@spp_helper[@]|$(bindir)/spp|g' \
 -e 's|@python[@]|$(PYTHON)|g'

r-host.sh: r-host.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST)
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@

leon2mt-sim-ctl: leon2mt-sim-ctl.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST)
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@

r-mtalpha-sim.sh: r-mt-sim.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST) \
	 -e 's|@MGSIM_ARCH[@]|$(MGSIM_ALPHA)|g' \
	 -e 's|@ARCH[@]|ALPHA|g' \
	 -e 's|@arch[@]|alpha|g' \
	 -e 's|@mtarch[@]|mtalpha|g'
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@

r-mipsel-sim.sh: r-mt-sim.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST) \
	 -e 's|@MGSIM_ARCH[@]|$(MGSIM_MIPSEL)|g' \
	 -e 's|@ARCH[@]|MIPSEL|g' \
	 -e 's|@arch[@]|mipsel|g' \
	 -e 's|@mtarch[@]|mipsel|g'
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@

r-mtsparc-sim.sh: r-mt-sim.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST) \
	 -e 's|@MGSIM_ARCH[@]|$(MGSIM_SPARC)|g' \
	 -e 's|@ARCH[@]|SPARC|g' \
	 -e 's|@arch[@]|sparc|g' \
	 -e 's|@mtarch[@]|mtsparc|g'
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@

r-mtsparc-fpga.sh: r-mtsparc-fpga.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST) \
	 -e 's|@ARCH[@]|SPARC|g' \
	 -e 's|@arch[@]|sparc|g' \
	 -e 's|@mtarch[@]|mtsparc|g'
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@


r-leon2mt-fpga.sh: r-leon2mt-fpga.sh.in Makefile
	$(AM_V_at)rm -f $@ $@.out
	$(AM_V_GEN)$(SED) <$< >$@.out $(COMMON_SUBST) \
	 -e 's|@ARCH[@]|LEON2MT|g' \
	 -e 's|@arch[@]|leon2mt|g' \
	 -e 's|@mtarch[@]|leon2mt|g'
	$(AM_V_at)chmod +x,a-w $@.out
	$(AM_V_at)mv -f $@.out $@


