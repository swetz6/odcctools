#!/bin/sh

set -e

CCTOOLSNAME=cctools
CCTOOLSVERS=622.3
CCTOOLSDISTFILE=${CCTOOLSNAME}-${CCTOOLSVERS}.tar.bz2

LD64NAME=ld64
LD64VERS=59.2
LD64DISTFILE=${LD64NAME}-${LD64VERS}.tar.bz2

DISTDIR=odcctools

TOPSRCDIR=`pwd`

MAKEDISTFILE=0
UPDATEPATCH=0
USESDK=1

while [ $# -gt 0 ]; do
    case $1 in
	--distfile)
	    shift
	    MAKEDISTFILE=1
	    ;;
	--updatepatch)
	    shift
	    UPDATEPATCH=1
	    ;;
	--nosdk)
	    shift
	    USESDK=0
	    ;;
	--help)
	    echo "Usage: $0 [--help] [--distfile] [--updatepatch] [--nosdk]" 1>&2
	    exit 0
	    ;;
	*)
	    echo "Unknown option $1" 1>&2
	    exit 1
    esac
done



if [ "`tar --help | grep -- --strip-components 2> /dev/null`" ]; then
    TARSTRIP=--strip-components
else
    TARSTRIP=--strip-path
fi

PATCHFILESDIR=${TOPSRCDIR}/patches

PATCHFILES=`cd "${PATCHFILESDIR}" && find * -type f \! -path \*/.svn\*`

ADDEDFILESDIR=${TOPSRCDIR}/files

if [ -d "${DISTDIR}" ]; then
    echo "${DISTDIR} already exists. Please move aside before running" 1>&2
    exit 1
fi

mkdir -p ${DISTDIR}
tar ${TARSTRIP}=1 -jxf ${CCTOOLSDISTFILE} -C ${DISTDIR}
mkdir -p ${DISTDIR}/ld64
tar ${TARSTRIP}=1 -jxf ${LD64DISTFILE} -C ${DISTDIR}/ld64
find ${DISTDIR}/ld64/doc/ -type f -exec cp "{}" ${DISTDIR}/man \;

# Clean the source a bit
find ${DISTDIR} -name \*.orig -exec rm -f "{}" \;
rm -rf ${DISTDIR}/{cbtlibs,dyld,file,gprof,libdyld,mkshlib,profileServer}

if [ $USESDK -eq 1 ]; then
    SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk
    echo "Merging content from $SDKROOT"
    if [ ! -d "$SDKROOT" ]; then
	echo "$SDKROOT must be present" 1>&2
	exit 1
    fi

    mv ${DISTDIR}/include/mach/machine.h ${DISTDIR}/include/mach/machine.h.new;
    for i in mach architecture i386 libkern; do
	tar cf - -C "$SDKROOT/usr/include" $i | tar xf - -C ${DISTDIR}/include
    done
    mv ${DISTDIR}/include/mach/machine.h.new ${DISTDIR}/include/mach/machine.h;

    for f in ${DISTDIR}/include/libkern/OSByteOrder.h; do
	sed -e 's/__GNUC__/__GNUC_UNUSED__/g' < $f > $f.tmp
	mv -f $f.tmp $f
    done
fi

# process source for mechanical substitutions
echo "Removing #import"
find ${DISTDIR} -type f -name \*.[ch] | while read f; do
    sed -e 's/^#import/#include/' < $f > $f.tmp
    mv -f $f.tmp $f
done
	
echo "Removing __private_extern__"
find ${DISTDIR} -type f -name \*.h | while read f; do
    sed -e 's/^__private_extern__/extern/' < $f > $f.tmp
    mv -f $f.tmp $f
done

set +e

INTERACTIVE=0
echo "Applying patches"
for p in ${PATCHFILES}; do			
    dir=`dirname $p`
    if [ $INTERACTIVE -eq 1 ]; then
	read -p "Apply patch $p? " REPLY
    else
	echo "Applying patch $p"
    fi
    pushd ${DISTDIR}/$dir > /dev/null
    patch --backup --posix -p0 < ${PATCHFILESDIR}/$p
    if [ $? -ne 0 ]; then
	echo "There was a patch failure. Please manually merge and exit the sub-shell when done"
	$SHELL
	if [ $UPDATEPATCH -eq 1 ]; then
	    find . -type f | while read f; do
		if [ -f "$f.orig" ]; then
		    diff -u -N "$f.orig" "$f"
		fi
	    done > ${PATCHFILESDIR}/$p
	fi
    fi
    find . -type f -name \*.orig -exec rm -f "{}" \;
    popd > /dev/null
done

set -e

echo "Adding new files"
tar cf - --exclude=CVS --exclude=.svn -C ${ADDEDFILESDIR} . | tar xvf - -C ${DISTDIR}

echo "Deleting cruft"
find ${DISTDIR} -name Makefile -exec rm -f "{}" \;
find ${DISTDIR} -name \*~ -exec rm -f "{}" \;
find ${DISTDIR} -name .\#\* -exec rm -f "{}" \;

pushd ${DISTDIR} > /dev/null
autoheader
autoconf
rm -rf autom4te.cache
popd > /dev/null

if [ $MAKEDISTFILE -eq 1 ]; then
    DATE=$(date +%Y%m%d)
    mv ${DISTDIR} ${DISTDIR}-$DATE
    tar jcf ${DISTDIR}-$DATE.tar.bz2 ${DISTDIR}-$DATE
fi

exit 0
