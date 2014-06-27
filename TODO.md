# Project TODO List

* Make "appkit" related changes, as listed at the bottom of appkit.md.
* An appkit project's kiteinfo should be populated by "kite new"
* Document the project.kite file syntax and semantics.

At this point Kite becomes useful.

* Add a -verbose mode, and debugging puts that it triggers.
* Support the "app" build target.
  * Add "require" project.kite command, to indicate the app's teapot dependencies.
* Later add "teacup" interactions related to teapot dependencies.
* [kite run] -- runs the app/appkit, possibly with arguments.

# Remaining Gaps #

The remaining major gaps in Kite's tool set:

* kite version
  * Display the Kite version information.
* kite run
  * Run app/appkit on [kite run]
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

Also, handling of .ehtml documentation.
