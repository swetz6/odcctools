CCTOOLSNAME=cctools
CCTOOLSVERS=528
DISTFILE=$(CCTOOLSNAME)-$(CCTOOLSVERS).tar.gz
DISTDIR=$(CCTOOLSNAME)-$(CCTOOLSVERS)

TOPSRCDIR=$(shell pwd)

PATCHFILESDIR=$(TOPSRCDIR)/patches
PATCHFILES=as/driver.c ld-Bstatic.diff

ADDEDFILESDIR=$(TOPSRCDIR)/files
ADDEDFILES=configure.ac Makefile.in include/config.h.in install-sh	\
	config.guess config.sub

default: none

clean:
	rm -rf $(DISTDIR)

none:
	@echo "Please choose an action:"
	@echo "\textract"
	@echo "\tpatch"
	@echo "\tclean"


extract:
	if [ \! -d $(DISTDIR) ]; then				\
		tar zxf $(DISTFILE);				\
	fi

patch: extract
	for p in $(PATCHFILES); do				\
		echo Applying patch $$p;			\
		dir=`dirname $$p`;				\
		( cd $(DISTDIR)/$$dir; 				\
		  patch --posix -p0 < $(PATCHFILESDIR)/$$p );	\
	done
	for p in $(ADDEDFILES); do				\
		echo Adding file $$p;				\
		cp $(ADDEDFILESDIR)/$$p $(DISTDIR)/$$p;		\
	done

regen:
	cd $(DISTDIR) && autoheader;
	cd $(DISTDIR) && autoconf;
