# Project TODO List

* Documentation questions
  * Development documentation vs. User documentation
  * Docs for libraries
  * Docs for apps
* Allow multiple apps/appkits
  * Get all external dependencies by default.
  * Add -exclude option to app/appkit to exclude specific dependencies.
* Build requirements into lib pkgModules.tcl files.
  * -kite-start-require/-kite-end-require tags
  * By default, all "require"'d packages
  * Add -exclude option to lib to exclude specific "require'd" packages.
* Write man pages
* Add ability to build particular things in buildtool.
* Test on Linux:
  * Install TDK
  * Build appkit
  * Build app
* kite test
  * Complete kite test suite.
* kite add appkit|lib
* Consider using basekits from teapot.

# Remaining Gaps #

The remaining major gaps in Kite's tool set:

* kite retest
  * Execute only tests that failed last time.
* kite add
  * Add libs or an app/appkit to an existing project.
  * Requires writing the project file, not just reading it.
* kite clean
  * Remove bin/*.kit, .kite/*, other kite artifacts.
* kite build
  * Building of docs
  * Building of teapot packages for libs.

The remaining major gaps in Kites feature set:

* Plugins for building other build targets (e.g., HTML help)
* Handling of other build targets.
  * E.g., C libraries.
  * At least need to be able to specify them in project.kite 
    with shell commands to "make build" and "make clean".
  * In project.kite:
    * make src/libFoo

What does Mars need that Kite doesn't yet offer?

* Building of "make" targets
  * E.g., C libs
* Teapot packaging of libs.
  * Pulling "require" dependencies into teapot.txt.
  * Install to local teapot
  * Install to kite server
* "kite clean"
* Version tagging
* Install to home page/kite server


What does Athena need that Kite doesn't yet offer?

* "athena_test", which has needs beyond what [kite test] currently gives.
* "kite clean"
* Version tagging
* Make tarballs
* Make installer
* Install to home page
* Ability to create .zip/.tgz archives.

