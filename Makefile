CCTOOLSNAME=cctools
CCTOOLSVERS=528
DISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.gz
DISTDIR=$(CCTOOLSNAME)-$(CCTOOLSVERS)

TOPSRCDIR=$(shell pwd)

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff as/getc_unlocked.diff		\
	otool/nolibmstub.diff misc/ranlibname.diff			\
	misc/libtool-ldpath.diff ar/ar-ranlibpath.diff

ADDEDFILESDIR=$(TOPSRCDIR)/files
ADDEDFILES=configure.ac Makefile.in include/config.h.in install-sh	\
	config.guess config.sub as/Makefile.in as/Makefile.arch.in	\
	as/ppc/Makefile.in as/ppc64/Makefile.in as/i386/Makefile.in	\
	libstuff/Makefile.in as/apple_version.c ar/Makefile.in		\
	ld/apple_version.c ld/Makefile.in		\
	otool/Makefile.in man/Makefile.in misc/Makefile.in		\
	misc/apple_version.c

default: none

clean:
	rm -rf $(DISTDIR)
	rm -rf .state.*

none:
	@echo "Please choose an action:"
	@echo "	extract"
	@echo "	patch"
	@echo "	clean"


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
		find $(DISTDIR) -name Makefile -exec rm "{}" \; ;	\
		find $(DISTDIR) -name \*~ -exec rm "{}" \; ;	\
		find $(DISTDIR) -name .\#\* -exec rm "{}" \; ;	\
		( cd $(DISTDIR) &&				\
		  autoheader &&					\
		  autoconf );					\
		touch .state.regen;				\
	fi
