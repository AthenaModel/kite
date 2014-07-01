# Project TODO List

* Support the "require" statement in project.kite
  * DONE require name version
    * Simple for now; don't worry about fancy version specs.
  * DONE to include Tcl dependencies into appkit
  * DONE code to determine whether "require" is present in teapot.
  * DONE Update "kite deps update" to pull missing packages into local teapot.
  * DONE Update "kite deps update name" to update existing require. 
  * Code to create ~/.kite/teapot and prepare local tclsh to use it.
  * Update code to use ~/kite.teapot instead 
* Support the "app" build target.
  * Can't build apps on OS X.
  * Then add code to include the teapot dependencies when building the app.
  * And code to find the basekit, by platform.
* kite test
  * Complete kite test suite.
* kite add appkit|lib

# Remaining Gaps #

The remaining major gaps in Kite's tool set:

* kite retest
  * Execute only tests that failed last time.
* kite add
  * Add libs or an app/appkit to an existing project.
  * Requires writing the project file, not just reading it.
* kite clean
  * Remove bin/*.kit, .kite/*, other kite artifacts.
* kite deps
  * Handling of external dependencies.
* kite build
  * Building of apps, with external dependencies
  * Building of docs
  * Building of teapot packages for libs.

The remaining major gaps in Kites feature set:

* Handling of .ehtml documentation.
* Plugins for building other build targets (e.g., HTML help)
* Handling of other build targets.
  * E.g., C libraries.
  * At least need to be able to specify them in project.kite 
    with shell commands to "make build" and "make clean".

What does Mars need that Kite doesn't yet offer?

* "require" dependencies
  * Pulled into local teapot
  * Pulled into appkit
* Building of documentation
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

* "require" dependencies
  * Pulled into local teapot
  * Pulled into app
* Building of documentation
* "athena_test", which has needs beyond what [kite test] currently gives.
* "kite clean"
* Version tagging
* Make tarballs
* Make installer
* Install to home page

