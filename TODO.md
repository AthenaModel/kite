# Project TODO List

* Building "make" targets
  * 'kite compile' does this; 'kite compile $name' should compile just the
    one.
  * 'kite build' builds apps and libs.
  * 'kite build all' compiles all src, builds apps and libs, and formats
    all docs.
* When a project "package require"'s packages it also exports, it should
  probably use "package require -exact".  That will guarantee that it
  uses the version within the project itself, rather than settling for
  something in the teapot.

## Notes

* Default teapot:
  * Making ~/.kite/teapot the default teapot means that
    different users are in contention.
  * Perhaps I should just make sure it's linked, and build
    against it.
  * Send note to Andreas: per-user teapots and links.
* Test suites
  * kitedoc(n)
  * manpage(n)
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
  * kite clean
    * Remove bin/*.kit/exe, .kite/*, docs/.../.html, obsolete includes,
      any other kite artifacts.
  * Support for "make" targets
  * Support for binary Tcl libs (C/C++ extensions)
    * Building the C code as "make" targets
    * Plain C libraries and C extensions
    * Building teapot .zips with hardware architecture
  * kite add app|lib
    * Add libs or an app to an existing project.
    * Requires writing the project file, not just reading it.
  * kite retest
    * Execute only tests that failed last time.
* User testing needed
  * Test on Linux
* To ponder
  * Consider using basekits from teapot.

# Remaining Gaps #

## For Mars

* Package tarballs: source, docs, installation
* ESSENTIAL!  Support for C Libraries/Extensions, for marsgeo(n).
* Install code/docs to home page/kite server?
* Automated git version tagging

## For Athena

* "athena_test", which has needs beyond what [kite test] currently gives.
* Package tarballs: source, docs, installation
* Install to Athena home page
* Automated git version tagging


## Man Page Processing

* Where do man pages go, when built?
  *   Do they simply live in the docs/manX directory, as now?
  *   A developer has to clone Mars and build the docs by hand?
  *   Perhaps we can push them out to https://oak/kite?
* At present, man page references can have "roots" so that 
  Athena man pages can refer to Mars man pages or Tcl man pages
  or Tk man pages.  Does that even make sense, with this new world?
* Athena man pages are now strictly for the developer; but the user
  of Mars might or might not be a developer.
* An app/appkit could package up the docs, and install them locally.
* An app/appkit could package up the docs, and display them in a 
  mybrowser (if mybrowser were part of Mars)

