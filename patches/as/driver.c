--- ./driver.c.orig	2003-03-14 18:18:25.000000000 -0800
+++ ./driver.c	2006-03-15 20:35:27.000000000 -0800
@@ -27,6 +27,8 @@
 char **envp)
 {
     const char *LIB =
+      ASLIBEXECDIR;
+#if 0
 #if defined(__OPENSTEP__) || defined(__HERA__) || \
     defined(__GONZO_BUNSEN_BEAKER__) || defined(__KODIAK__)
 		    "/usr/libexec/";
@@ -40,6 +42,7 @@
 #else
 		    "/usr/local/libexec/gcc/darwin/";
 #endif
+#endif
     const char *AS = "/as";
 
     int i;
@@ -162,6 +165,8 @@
 	    else
 		exit(1);
 	}
+	as_local = "";
+#if 0
 	as_local = makestr(LOCALLIB, arch_name, AS, NULL);
 	if(access(as_local, F_OK) == 0){
 	    argv[0] = as_local;
@@ -171,6 +176,8 @@
 		exit(1);
 	}
 	else{
+#endif
+	{
 	    printf("%s: assembler (%s or %s) for architecture %s not "
 		   "installed\n", progname, as, as_local, arch_name);
 	    arch_flags = get_arch_flags();
@@ -183,6 +190,7 @@
 		    printf("%s for architecture %s\n", as, arch_flags[i].name);
 		    count++;
 		}
+#if 0
 		else{
 		    as_local = makestr(LOCALLIB, arch_flags[i].name, AS, NULL);
 		    if(access(as_local, F_OK) == 0){
@@ -193,6 +201,7 @@
 			count++;
 		    }
 		}
+#endif
 	    }
 	    if(count == 0)
 		printf("%s: no assemblers installed\n", progname);
