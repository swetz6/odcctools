AC_INIT([odcctools], [528.5od3], [odcctools@opendarwin.org])
AC_PREREQ([2.57])
AC_REVISION([$Revision: 1.23 $])

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

case $target_cpu in
     powerpc*)
        AC_DEFINE(EMULATED_HOST_CPU_TYPE, 18, [Emulated CPU type])        
        AC_DEFINE(EMULATED_HOST_CPU_SUBTYPE, 100, [Emulated CPU subtype])        
	;;
     i?86)
        AC_DEFINE(EMULATED_HOST_CPU_TYPE, 7, [Emulated CPU type])        
        AC_DEFINE(EMULATED_HOST_CPU_SUBTYPE, 14, [Emulated CPU subtype])        
	;;
     *)
	AC_MSG_ERROR([Unsupported target $target_cpu])
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
   [AC_SUBST([MDYNAMICNOPIC],[-mdynamic-no-pic])
    AC_MSG_RESULT([yes])],
   [AC_SUBST([MDYNAMICNOPIC],[])
    AC_MSG_RESULT([no])]
)
CFLAGS=$ORIGCFLAGS

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -no-cpp-precomp"
supported=0
AC_MSG_CHECKING([if -no-cpp-precomp is supported])
AC_LANG_CONFTEST([[const char hw[] = "Hello, World\n";]])
rm -f conftest.$ac_objext conftest$ac_exeext
out=`$CC -c $CFLAGS $CPPFLAGS conftest.$ac_ext 2>&1`
if [[ $? -ne 0 ]]; then
   supported=0;
else
   unrecog=`echo $out | grep unrecog | wc -l`
   if [[ $unrecog -gt 0 ]]; then
      supported=0;
   else
      supported=1;
   fi
fi

if [[ $supported -eq 1 ]]; then
   AC_MSG_RESULT([yes])
else
   CFLAGS="$ORIGCFLAGS"
   AC_MSG_RESULT([no])
fi
rm -f conftest.$ac_objext conftest$ac_exeext conftest.$ac_ext

WARNINGS=""

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -Wall"
AC_MSG_CHECKING([if -Wall is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [WARNINGS="$WARNINGS -Wall"
    AC_MSG_RESULT([yes])],
   [AC_MSG_RESULT([no])]
)
CFLAGS=$ORIGCFLAGS

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -Wno-long-double"
AC_MSG_CHECKING([if -Wno-long-double is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [WARNINGS="$WARNINGS -Wno-long-double"
    AC_MSG_RESULT([yes])],
   [AC_MSG_RESULT([no])]
)
CFLAGS=$ORIGCFLAGS

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -Wno-import"
AC_MSG_CHECKING([if -Wno-import is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [WARNINGS="$WARNINGS -Wno-import"
    AC_MSG_RESULT([yes])],
   [AC_MSG_RESULT([no])]
)
CFLAGS=$ORIGCFLAGS

AC_SUBST([WARNINGS], [$WARNINGS])

ORIGCFLAGS=$CFLAGS
CFLAGS="$CFLAGS -x objective-c"
OBJC="-x objective-c"
AC_MSG_CHECKING([if -x objective-c is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[const char hw[] = "Hello, World\n";]])],
   [AC_DEFINE(HAVE_OBJC, 1, [Have Objective-C support])
    AC_MSG_RESULT([yes])],
   [OBJC=""
    AC_MSG_RESULT([no])]
)
AC_SUBST([OBJC], [$OBJC])
CFLAGS=$ORIGCFLAGS

AC_MSG_CHECKING([if __private_extern__ is supported])
AC_COMPILE_IFELSE(
   [AC_LANG_SOURCE([[__private_extern__ int foo;]])],
   [AC_SUBST([HAVE_PRIVEXT], [YES])
    AC_MSG_RESULT([yes])],
   [AC_SUBST([HAVE_PRIVEXT], [NO])
    AC_MSG_RESULT([no])]
)

ORIGLDFLAGS=$LDFLAGS
LDFLAGS="-multiply_defined suppress"
AC_MSG_CHECKING([if -multiply_defined suppress is supported])
AC_LINK_IFELSE([AC_LANG_PROGRAM()],
	[AC_MSG_RESULT([yes])],
	[LDFLAGS="$ORIGLDFLAGS"
	 AC_MSG_RESULT([no])]
)

AC_HEADER_STDC
AC_CHECK_HEADER([stdio.h])
AC_CHECK_DECLS([getc_unlocked])
AH_VERBATIM([HAVE_DECL_GETC_UNLOCKED_REPLACEMENT],
[/* For systems that don't have getc_unlocked, use getc  */
#if !HAVE_DECL_GETC_UNLOCKED
# define getc_unlocked(a) getc(a)
#endif])

case $host_os in
     darwin*)
        COMPONENTS="ar as libstuff ld man misc otool"
	AC_SUBST([HAVE_FOREIGN_HEADERS],[NO])
	;;
     *)
        COMPONENTS="as libstuff otool"
	AC_SUBST([HAVE_FOREIGN_HEADERS],[YES])
	AC_SUBST([EMULATED_OBJ], [emulated.c])
	AC_C_BIGENDIAN([AC_SUBST([ENDIAN_FLAG],[-D__BIG_ENDIAN__=1])],
			[AC_SUBST([ENDIAN_FLAG],[-D__LITTLE_ENDIAN__=1])])
	;;
esac
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
