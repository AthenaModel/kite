# Project TODO List

* Make "lib" related changes, as listed at the bottom of lib.md.
* Make "appkit" related changes, as listed at the bottom of appkit.md.
* Build fails on OSX; it doesn't find the right teapot.
* An appkit project's kiteinfo should be populated by "kite new"
* Document the project.kite file syntax and semantics.

At this point Kite becomes useful.

* Support the "app" build target.
  * Add "require" project.kite command, to indicate the app's teapot dependencies.
* Later add "teacup" interactions related to teapot dependencies.
* [kite run] -- runs appkits, possibly with arguments.
  * If only one appkit, just runs it.  If multiple, you need to specify
    the name?
  * Should there only be one app/appkit?  Do I need a project type?
* [kite shell] invokes tkcon with a script.
  * For appkits, it's the main script
  * For libs, it's a script that sets the auto_path and requires the 
    core package.  (Packages?)