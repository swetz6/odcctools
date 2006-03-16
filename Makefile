CCTOOLSNAME=cctools
CCTOOLSVERS=590.36
CCTOOLSDISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.bz2

LD64NAME=ld64
LD64VERS=26.0.81
LD64DISTFILE=$(LD64NAME)-$(LD64VERS).tar.bz2

DISTDIR=odcctools

TOPSRCDIR=$(shell pwd)
HOSTKERNEL=$(shell uname -s)
TARSTRIP=$(TARSTRIP_$(HOSTKERNEL))
TARSTRIP_Darwin=--strip-path
TARSTRIP_Linux=--strip-components

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff as/getc_unlocked.diff		\
	otool/nolibmstub.diff misc/ranlibname.diff			\
	misc/libtool-ldpath.diff ar/ar-ranlibpath.diff			\
	otool/noobjc.diff as/input-scrub.diff	\
	as/messages.diff ar/contents.diff ar/errno.diff			\
	ar/archive.diff misc/libtool-pb.diff ar/ar-printf.diff 		\
	ld/ld-pb.diff ld-sysroot.diff as/relax.diff			\
	as/bignum.diff include/architecture/i386/selguard.diff		\
	misc/redo_prebinding.nomalloc.diff include/mach/machine.diff	\
	ld/relocate-ld64.diff ld64/Options-dotdot.diff \
	ld64/Options-stdarg.diff ld64/Writers/ExecutableFileMachO-class.diff \
	ld64/Options-defcross.diff misc/libtool-relocate-ld64.diff	\
	ld/uuid-nonsmodule.diff misc/redo_prebinding.nogetattrlist.diff \
	ld64/Options-ctype.diff


ADDEDFILESDIR=$(TOPSRCDIR)/files

default: none

clean:
	rm -rf $(DISTDIR)
	rm -rf .state.*

none:
	@echo "Please choose an action:"
	@echo "	extract"
	@echo "	patch"
	@echo "	regen"
	@echo "	clean"


extract:
	if [ \! -f .state.extract ]; then			\
		if [ \! -d $(DISTDIR) ]; then			\
			mkdir -p $(DISTDIR);			\
			tar $(TARSTRIP)=1 -jxf $(CCTOOLSDISTFILE) -C $(DISTDIR);		\
			mkdir -p $(DISTDIR)/ld64;		\
			tar $(TARSTRIP)=2 -jxf $(LD64DISTFILE) -C $(DISTDIR)/ld64; \
			find $(DISTDIR)/ld64/man \
				-type f -exec cp "{}" $(DISTDIR)/man \; ;	\
			find $(DISTDIR) -name \*.orig -exec rm -f "{}" \; ;	\
		fi;						\
		touch .state.extract;				\
	fi

patch: extract 
	if [ \! -f .state.patch ]; then				\
		for p in $(PATCHFILES); do			\
			echo Applying patch $$p;		\
			dir=`dirname $$p`;			\
			( cd $(DISTDIR)/$$dir; 			\
			  patch --no-backup-if-mismatch --posix -p0 < $(PATCHFILESDIR)/$$p );	\
		done;						\
		tar cf - --exclude=CVS -C $(ADDEDFILESDIR) . | 	\
			tar xvf - -C $(DISTDIR);			\
		find $(DISTDIR) -type f -name \*.[ch] | while read f; do \
			sed -e 's/^#import/#include/' < $$f > $$f.tmp;	\
			mv -f $$f.tmp $$f;				\
		done;						\
		find $(DISTDIR) -type f -name \*.h | while read f; do \
			sed -e 's/^__private_extern__/extern/' < $$f > $$f.tmp;	\
			mv -f $$f.tmp $$f;				\
		done;						\
		touch .state.patch;				\
	fi

updatepatch: extract 
	if [ \! -f .state.patch ]; then				\
		for p in $(PATCHFILES); do			\
			echo Applying patch $$p;		\
			dir=`dirname $$p`;			\
			( cd $(DISTDIR)/$$dir; 			\
			  patch -b --posix -p0 < $(PATCHFILESDIR)/$$p; \
			  if [ $$? -eq 1 ]; then			\
				exit 1;				\
			  fi;					\
			  ( find . -type f | while read f; do	\
				if [ -f "$$f.orig" ]; then	\
					diff -u -N "$$f.orig" "$$f";	\
				fi;				\
			  done) > $(PATCHFILESDIR)/$$p;		\
			  find . -type f -name \*.orig -exec rm -f "{}" \;; \
			);					\
		done;						\
		tar cf - --exclude=CVS -C $(ADDEDFILESDIR) . | 	\
			tar xvf - -C $(DISTDIR);			\
		find $(DISTDIR) -type f -name \*.[ch] | while read f; do \
			sed 's/^#import/#include/' < $$f > $$f.tmp;	\
			mv -f $$f.tmp $$f;				\
		done;						\
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
		rm -rf $(DISTDIR)/autom4te.cache;		\
		touch .state.regen;				\
	fi
