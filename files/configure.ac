AC_INIT([odcctools], [528od1], [odcctools@opendarwin.org])
AC_PREREQ([2.57])
AC_REVISION([$Revision: 1.3 $])

AC_CONFIG_SRCDIR([APPLE_LICENSE])
AC_CONFIG_HEADERS([include/config.h])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

case $target_os in
darwin*)
	:
	;;
*)
	AC_MSG_ERROR([$PACKAGE_NAME only supports targeting Darwin])
	;;
esac

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_CC

AC_CHECK_TOOL([HOST_RANLIB], [ranlib], :)
AC_CHECK_TOOL([HOST_AR], [ar], :)

AC_MSG_CHECKING([for configured assembler targets])
ASTARGETS=""
case $target_cpu in
powerpc*)
	ASTARGETS="$ASTARGETS ppc ppc64"
	;;
i?86)
	ASTARGETS="$ASTARGETS i386"
	;;
*)
	AC_MSG_ERROR([Unsupported target $target_cpu])
	;;
esac
AC_MSG_RESULT([$ASTARGETS])
AC_SUBST([ASTARGETS], [$ASTARGETS]) 

AC_SYS_LARGEFILE
AC_SYS_LONG_FILE_NAMES

AC_CONFIG_FILES([Makefile as/Makefile])
for ast in $ASTARGETS; do
    case $ast in
    ppc)
	AC_CONFIG_FILES([as/Makefile.ppc:as/Makefile.arch.in:as/Makefile.ppc.in])
	AC_CONFIG_COMMANDS([as/Makefile.ppc.link], [mkdir -p ${ac_abs_top_builddir}/as/ppc_build; ln -s -f ../Makefile.ppc ${ac_abs_top_builddir}/as/ppc_build/Makefile])
	;;
    ppc64)
	AC_CONFIG_FILES([as/Makefile.ppc64:as/Makefile.arch.in:as/Makefile.ppc64.in])
	AC_CONFIG_COMMANDS([as/Makefile.ppc64.link], [mkdir -p ${ac_abs_top_builddir}/as/ppc64_build; ln -s -f ../Makefile.ppc64 ${ac_abs_top_builddir}/as/ppc64_build/Makefile])
	;;
    i386)
	AC_CONFIG_FILES([as/Makefile.i386:as/Makefile.arch.in:as/Makefile.i386.in])
	AC_CONFIG_COMMANDS([as/Makefile.i386.link], [mkdir -p ${ac_abs_top_builddir}/as/i386_build; ln -s -f ../Makefile.i386 ${ac_abs_top_builddir}/as/i386_build/Makefile])
	;;
    *)
	AC_MSG_ERROR([Unrecognized assembler target $ast])
	;;
    esac
done
AC_OUTPUT
