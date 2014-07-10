# Project TODO List

* Architecture
  * Merge kutils and ktools as kite(n).
  * Copy athena-mars/marsutil to Kite as
    * kiteutils
      * marsmisc, template, smartinterp, tclchecker
        * Prune marsmisc of all things that this Kite doesn't need.
      * Split marsmisc into appropriate pieces.
      * Merge kutils/misc.tcl into these pieces as appropriate.
    * kitedocs
      * ehtml, marsdoc, manpage.
    * kiteutils and kitedocs become libs for other projects to use.
  * athena-mars
    * External dependency on kiteutils
    * marsmisc gets restructured, and pruned of all things in kiteutils.
    * Other modules now in Kite are removed.
* Next
  * Add ability to build particular things in buildtool.
  * Complete kite test suite.
* When new athena/kite web server is available
  * Support for "external documents"
    * MS Office documents and similar will reside on a separate web server;
      we'll update it as we change them.
    * project.kite will have an "xdoc" statement:
      * xdoc mag.docx http://...../mag3.5.docx
    * External docs can be pulled in using a kite command, so that they
      can be included in a build.
  * "Kite server" for locally built packages
* As time permits/when needed
  * Add kutils(n) manpages.
  * kite clean
    * Remove bin/*.kit/exe, .kite/*, docs/.../.html, obsolete includes,
      any other kite artifacts.
  * Support for "make" targets
  * Support for binary Tcl libs (C/C++ extensions)
    * Building the C code as "make" targets
    * Plain C libraries and C extensions
    * Building teapot .zips with hardware architecture
  * kite add appkit|lib
    * Add libs or an app/appkit to an existing project.
    * Requires writing the project file, not just reading it.
  * Allow multiple apps/appkits
    * Get all external dependencies by default.
    * Add -exclude option to app/appkit to exclude specific dependencies.
  * kite retest
    * Execute only tests that failed last time.
* User testing needed
  * Test on Linux
  * Text on OS X
* To ponder
  * Consider using basekits from teapot.
  * Plugins for building other build targets (e.g., HTML help)

# Remaining Gaps #

What does Mars need that Kite doesn't yet offer?

* ESSENTIAL!  Support for C Libraries/Extensions, for marsgeo(n).
* Install code/docs to home page/kite server?
* Automated git version tagging

What does Athena need that Kite doesn't yet offer?

* "athena_test", which has needs beyond what [kite test] currently gives.
* Ability to make tarballs (source, docs, installation)
* Install to Athena home page
* Automated git version tagging

