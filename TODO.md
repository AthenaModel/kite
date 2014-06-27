# Project TODO List

* Make "appkit" related changes, as listed at the bottom of appkit.md.
* An appkit project's kiteinfo should be populated by "kite new"
* Document the project.kite file syntax and semantics.

At this point Kite becomes useful.

* Support the "app" build target.
  * Can't work on this on OS X.
  * Add "require" project.kite command, to indicate the app's teapot dependencies.
* Later add "teacup" interactions related to teapot dependencies.

# Remaining Gaps #

The remaining major gaps in Kite's tool set:

* kite version
  * Display the Kite version information.
* kite test
  * Creation of test suite skeletons as part of [kite new]
  * Execution of library and application test suites on [kite test]
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
