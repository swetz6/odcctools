AC_INIT([odcctools], [528od1], [odcctools@opendarwin.org])
AC_PREREQ([2.57])
AC_REVISION([$Revision: 1.14 $])

AC_CONFIG_SRCDIR([APPLE_LICENSE])
AC_CONFIG_HEADERS([include/config.h])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AC_ARG_PROGRAM

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

ASTARGETS=""
conftargets=""
AC_MSG_CHECKING([for configured assembler targets])
AC_ARG_ENABLE([as-targets],
		AC_HELP_STRING([--enable-as-targets],
				[space-separated list ("ppc", "ppc64", "i386", "all")]),
		[conftargets="$enableval"],
		[conftargets="default"])

case "$conftargets" in
     all)
        ASTARGETS="ppc ppc64 i386"
	;;
     default)
        case $target_cpu in
	powerpc*)
	 	ASTARGETS="ppc ppc64"
		;;
	i?86)
		ASTARGETS="i386"
		;;
	*)
		AC_MSG_ERROR([Unsupported target $target_cpu])
		;;
	esac
	;;
     yes)
	AC_MSG_ERROR([no assembler targets configured])
	;;
     no)
	AC_MSG_ERROR([no assembler targets configured])
	;;
     *)
	if [[ -z "$conftargets" ]]; then
	   AC_MSG_ERROR([no assembler targets configured])
	fi
	ASTARGETS="$conftargets"
	;;
esac

AC_MSG_RESULT([$ASTARGETS])
AC_SUBST([ASTARGETS], [$ASTARGETS]) 

AC_SUBST([ASLIBEXECDIR], ['${libexecdir}/as'])

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -mdynamic-no-pic"
AC_MSG_CHECKING([if -mdynamic-no-pic is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [AC_SUBST([MDYNAMICNOPIC],[-mdynamic-no-pic]) AC_MSG_RESULT([yes])],
   [AC_SUBST([MDYNAMICNOPIC],[]) AC_MSG_RESULT([no])]
)
CFLAGS=$ORIGCFLAGS

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -no-cpp-precomp"
AC_MSG_CHECKING([if -no-cpp-precomp is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [AC_MSG_RESULT([yes])],
   [CFLAGS="$ORIGCFLAGS", AC_MSG_RESULT([no])]
)

ORIGLDFLAGS=$LDFLAGS
LDFLAGS="-multiply_defined suppress"
AC_MSG_CHECKING([if -multiply_defined suppress is supported])
AC_LINK_IFELSE([AC_LANG_PROGRAM()],
	[AC_MSG_RESULT([yes])],
	[LDFLAGS="$ORIGLDFLAGS", AC_MSG_RESULT([no])]
)

AC_HEADER_STDC
AC_CHECK_HEADER([stdio.h])
AC_CHECK_DECLS([getc_unlocked])
AH_VERBATIM([HAVE_DECL_GETC_UNLOCKED_REPLACEMENT],
[/* For systems that don't have getc_unlocked, use getc  */
#if !HAVE_DECL_GETC_UNLOCKED
# define getc_unlocked(a) getc(a)
#endif])

COMPONENTS="ar as libstuff ld man misc otool"
AC_SUBST([COMPONENTS], [$COMPONENTS])

AC_CONFIG_FILES([Makefile libstuff/Makefile])
AC_CONFIG_FILES([ar/Makefile])
AC_CONFIG_FILES([as/Makefile])
for ast in $ASTARGETS; do
    case $ast in
    ppc)
	AC_CONFIG_FILES([as/ppc/Makefile:as/ppc/Makefile.in:as/Makefile.arch.in])
	;;
    ppc64)
	AC_CONFIG_FILES([as/ppc64/Makefile:as/ppc64/Makefile.in:as/Makefile.arch.in])
	;;
    i386)
	AC_CONFIG_FILES([as/i386/Makefile:as/i386/Makefile.in:as/Makefile.arch.in])
	;;
    *)
	AC_MSG_ERROR([Unrecognized assembler target $ast])
	;;
    esac
done
AC_CONFIG_FILES([ld/Makefile])
AC_CONFIG_FILES([man/Makefile])
AC_CONFIG_FILES([misc/Makefile])
AC_CONFIG_FILES([otool/Makefile])
AC_OUTPUT
