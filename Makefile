CCTOOLSNAME=cctools
CCTOOLSVERS=528.5
DISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.bz2
DISTDIR=$(CCTOOLSNAME)-$(CCTOOLSVERS)

TOPSRCDIR=$(shell pwd)

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff as/getc_unlocked.diff		\
	otool/nolibmstub.diff misc/ranlibname.diff			\
	misc/libtool-ldpath.diff ar/ar-ranlibpath.diff			\
	private_extern.diff otool/noobjc.diff as/input-scrub.diff	\
	as/messages.diff ar/contents.diff ar/errno.diff			\
	ar/archive.diff misc/libtool-pb.diff ar/ar-printf.diff 		\
	ld/ld-pb.diff

ADDEDFILESDIR=$(TOPSRCDIR)/files

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
			tar jxf $(DISTFILE);			\
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
		tar cf - --exclude=CVS -C $(ADDEDFILESDIR) . | 	\
			tar xvf - -C $(DISTDIR);			\
		touch .state.patch;				\
	fi

regen: patch
	if [ \! -f .state.regen ]; then				\
		find $(DISTDIR) -name Makefile -exec rm -f "{}" \; ;	\
		find $(DISTDIR) -name \*~ -exec rm -f "{}" \; ;	\
		find $(DISTDIR) -name .\#\* -exec rm -f "{}" \; ;	\
		( cd $(DISTDIR) &&				\
		  autoheader &&					\
		  autoconf );					\
		touch .state.regen;				\
	fi
