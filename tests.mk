# 
# slc, a SL compiler.
# 
# Copyright (C) 2008,2009 The SL project..
# All rights reserved.
# 

TESTS_ENVIRONMENT = \
	SLC=$(top_builddir)/bin/slc.local \
	SGR=$(top_builddir)/bin/sgr.local \
	TESTDIR=$(builddir) \
	$(top_srcdir)/bin/slt
