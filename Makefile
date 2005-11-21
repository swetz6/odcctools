CCTOOLSNAME=cctools
CCTOOLSVERS=590.18
CCTOOLSDISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.bz2
CCTOOLSDISTDIR=$(CCTOOLSNAME)-$(CCTOOLSVERS)

LD64NAME=ld64
LD64VERS=26.0.81
LD64DISTFILE=$(LD64NAME)-$(LD64VERS).tar.bz2

TOPSRCDIR=$(shell pwd)

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff as/getc_unlocked.diff		\
	otool/nolibmstub.diff misc/ranlibname.diff			\
	misc/libtool-ldpath.diff ar/ar-ranlibpath.diff			\
	private_extern.diff otool/noobjc.diff as/input-scrub.diff	\
	as/messages.diff ar/contents.diff ar/errno.diff			\
	ar/archive.diff misc/libtool-pb.diff ar/ar-printf.diff 		\
	ld/ld-pb.diff ld-sysroot.diff as/relax.diff			\
	as/bignum.diff include/architecture/i386/selguard.diff		\
	misc/redo_prebinding.nomalloc.diff include/mach/machine.diff

ADDEDFILESDIR=$(TOPSRCDIR)/files

default: none

clean:
	rm -rf $(CCTOOLSDISTDIR)
	rm -rf .state.*

none:
	@echo "Please choose an action:"
	@echo "	extract"
	@echo "	patch"
	@echo "	regen"
	@echo "	clean"


extract:
	if [ \! -f .state.extract ]; then			\
		if [ \! -d $(CCTOOLSDISTDIR) ]; then			\
			tar jxf $(CCTOOLSDISTFILE);			\
			mkdir -p $(CCTOOLSDISTDIR)/.tmp.ld64;		\
			tar jxf $(LD64DISTFILE) -C $(CCTOOLSDISTDIR)/.tmp.ld64; \
			find $(CCTOOLSDISTDIR)/.tmp.ld64/$(LD64NAME)-$(LD64VERS)/doc/man \
				-type f -exec cp "{}" $(CCTOOLSDISTDIR)/man \; ;	\
			mkdir -p $(CCTOOLSDISTDIR)/ld64;		\
			tar cf - -C $(CCTOOLSDISTDIR)/.tmp.ld64/$(LD64NAME)-$(LD64VERS)/src . | \
				tar xf - -C $(CCTOOLSDISTDIR)/ld64;	\
			rm -rf $(CCTOOLSDISTDIR)/.tmp.ld64;		\
		fi;						\
		touch .state.extract;				\
	fi

patch: extract 
	if [ \! -f .state.patch ]; then				\
		for p in $(PATCHFILES); do			\
			echo Applying patch $$p;		\
			dir=`dirname $$p`;			\
			( cd $(CCTOOLSDISTDIR)/$$dir; 			\
			  patch --no-backup-if-mismatch --posix -p0 < $(PATCHFILESDIR)/$$p );	\
		done;						\
		tar cf - --exclude=CVS -C $(ADDEDFILESDIR) . | 	\
			tar xvf - -C $(CCTOOLSDISTDIR);			\
		find $(CCTOOLSDISTDIR) -type f -name \*.[ch] | while read f; do \
			sed 's/^#import/#include/' < $$f > $$f.tmp;	\
			mv -f $$f.tmp $$f;				\
		done;						\
		touch .state.patch;				\
	fi

updatepatch: extract 
	if [ \! -f .state.patch ]; then				\
		for p in $(PATCHFILES); do			\
			echo Applying patch $$p;		\
			dir=`dirname $$p`;			\
			( cd $(CCTOOLSDISTDIR)/$$dir; 			\
			  patch -b --posix -p0 < $(PATCHFILESDIR)/$$p; \
			  if [ $$? -eq 1 ]; then			\
				exit 1;				\
			  fi;					\
			  ( find . -type f | while read f; do	\
				if [ -f "$$f.orig" ]; then	\
					diff -u -N "$$f.orig" "$$f";	\
				fi;				\
			  done) > $(PATCHFILESDIR)/$$p;		\
			  find . -type f -name \*.orig -exec rm "{}" \;; \
			);					\
		done;						\
		tar cf - --exclude=CVS -C $(ADDEDFILESDIR) . | 	\
			tar xvf - -C $(CCTOOLSDISTDIR);			\
		find $(CCTOOLSDISTDIR) -type f -name \*.[ch] | while read f; do \
			sed 's/^#import/#include/' < $$f > $$f.tmp;	\
			mv -f $$f.tmp $$f;				\
		done;						\
		touch .state.patch;				\
	fi

regen: patch
	if [ \! -f .state.regen ]; then				\
		find $(CCTOOLSDISTDIR) -name Makefile -exec rm -f "{}" \; ;	\
		find $(CCTOOLSDISTDIR) -name \*~ -exec rm -f "{}" \; ;	\
		find $(CCTOOLSDISTDIR) -name .\#\* -exec rm -f "{}" \; ;	\
		( cd $(CCTOOLSDISTDIR) &&				\
		  autoheader &&					\
		  autoconf );					\
		rm -rf $(CCTOOLSDISTDIR)/autom4te.cache;		\
		touch .state.regen;				\
	fi
