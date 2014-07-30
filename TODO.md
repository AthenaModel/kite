# Project TODO List

* Next
  * Define "subtree app" to handle apps.
    * Move the last template into this tree.  
    * It can handle apps vs. appkits.
    * Update trees to use subtree app for app and appit.
    * Remove genfile/gentree code and docs (if any docs)
    * Remove last template.
  * Create new style app command: -apptype kit|exe -gui
    * Update project(n)'s parser
    * Update subtree app.
  * Update athena-mars documentation to use the new kite.

* Architecture changes post-reflection
  * Replace existing templates with "subtree"-based code.
  * Make "app" and "appkit" just one kind of tree, with options on the "app"
    command.
  * Remove list of required packages from project.kite's "lib" command.
  * Replace "lib" statement with "provide".
  * Put tags around "package require" blocks in provided libs.
  * Kite automatically updates the versions in the listed package requires.
    * blockreplace becomes "tagsplit", so that we can base the replacement
    * on the block being replaced.
  * Add "main.tcl" to generated "${app}app" package; make app loader script
    as generic as possible.
* Architecture
  * Merge kiteapp/misc.tcl into kiteutils as appropriate.
  * Merge kite.tcl's main code into kiteapp as appropriate.
  * Add kiteutils and kitedocs as "lib"'s
  * Consider making tkcon an external dependency, and calling it 
    directly.
  * Figure out how to use the right code in development when 
    kiteutils and kitedocs are in the local teapot.
* manpage(n)
  * Add test suite
* kitedoc(n)
  * Add test suite.
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


Man Page Processing

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

