CCTOOLSNAME=cctools
CCTOOLSVERS=528
DISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.gz
DISTDIR=$(CCTOOLSNAME)-$(CCTOOLSVERS)

TOPSRCDIR=$(shell pwd)

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff as/getc_unlocked.diff

ADDEDFILESDIR=$(TOPSRCDIR)/files
ADDEDFILES=configure.ac Makefile.in include/config.h.in install-sh	\
	config.guess config.sub as/Makefile.in as/Makefile.arch.in	\
	as/ppc/Makefile.in as/ppc64/Makefile.in as/i386/Makefile.in	\
	libstuff/Makefile.in as/apple_version.c ar/Makefile.in		\
	include/Makefile.in ld/apple_version.c ld/Makefile.in

default: none

clean:
	rm -rf $(DISTDIR)
	rm -rf .state.*

none:
	@echo "Please choose an action:"
	@echo "\textract"
	@echo "\tpatch"
	@echo "\tclean"


extract:
	if [ \! -f .state.extract ]; then			\
		if [ \! -d $(DISTDIR) ]; then			\
			tar zxf $(DISTFILE);			\
		fi;						\
		touch .state.extract;				\
	fi

patch: extract 
	if [ \! -f .state.patch ]; then				\
		for p in $(PATCHFILES); do			\
			echo Applying patch $$p;		\
			dir=`dirname $$p`;			\
			( cd $(DISTDIR)/$$dir; 			\
			  patch --posix -p0 < $(PATCHFILESDIR)/$$p );	\
		done;						\
		for p in $(ADDEDFILES); do			\
			echo Adding file $$p;			\
			mkdir -p $(DISTDIR)/`dirname $$p`;	\
			cp $(ADDEDFILESDIR)/$$p $(DISTDIR)/$$p;	\
		done;						\
		touch .state.patch;				\
	fi

regen: patch
	if [ \! -f .state.regen ]; then				\
		( cd $(DISTDIR) &&				\
		  autoheader &&					\
		  autoconf );					\
		touch .state.regen;				\
	fi
