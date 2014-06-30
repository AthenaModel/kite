# Project TODO List

* Fix "kite shell" on Windows
* kite test
  * Creation of test suite skeletons as part of [kite new]
  * Complete kite test suite.
* kite add appkit|lib
* Support the "require" statement in project.kite
  * require name version
    * Simple for now; don't worry about fancy version specs.
  * Code to pull packages into ~/.kite/teapot
  * Code to create ~/.kite/teapot and prepare local tclsh to use it.
  * Code to include Tcl dependencies into appkit?
* Support the "app" build target.
  * Can't build apps on OS X.
  * Then add code to include the teapot dependencies when building the app.
  * And code to find the basekit, by platform.

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
