# Project TODO List

## Next

* manroot changes
    * Consider moving xref/xrefset into its own macro set; manpage(5) and
      kitedoc(5) need it, but Athena's help(5) does not.
* 'kite deps' needs to show actual versions in teapot.

* Consider: add -force, -follow, and -follow-recommend as options to app,
  to be passed along to tclapp.
* We have three flavors: windows, osx, and linux.  That's really
  32-bit windows, 64-bit osx, and 64-bit linux.  We could have five
  architectures: win32, win64, osx, linux32, and linux64. 

* ehtml(5) macro sets should use CSS for formatting, where possible.
  * Provide default CSS macro!
* Include a dist block in the default project file.
* macro(n) should support textutil::expander's textcmd.
  * Should manpage(n)/kitedocs(n) use it for quoting?
* Add %install target to dist; includes an installation script
  * a list of bash commands.
* Clean up "kite new" syntax.  
  * In particular, provide option for description.

* Test suite for table(n).
* Cleanup:
  * Compare docs.tcl with tool_docs.tcl and make sure there's a clean
    division.
    * Add a call to docs.tcl indicating whether there are documents
      that will be processed.
    * Probably should support arbitrary depths.
  * Update help subsystem to support tree of topics.
  * Use smartinterp for parsing project.kite.
  * Work through code, looking for things to improve.
  * Pull "knowledge" into specific spots.
  * Rationalize "project" queries.
* Cross-platform builds
  * Need to manage Tcl version.
* Improve 'kite add': options on additions, e.g., private libraries.
  * Options:
    * -private: Private library, not "provided".
    * -notest: Library has no test suite 
  * Constraints:
    * Can't add app if loader script or lib/nameapp already exists.
    * Can't add library if lib/name already exists.
* Testing of kiteapp modules.
  * Split between UI modules (e.g., <name>tool.tcl) and implementation
    modules (e.g., tool.tcl).
  * Can test each.
* Plug-in architecture.
  * A plugin defines a new tool.
  * It provides help, calling info, and so forth.
    * Provide cleaner interface for existing tools.
  * Can access "project" API, which will have to be documented.
  * Provide clean "project" API.
    * Pass project object into plugins?

## Notes

* Test suites
  * kitedoc(n)
  * manpage(n)
* To ponder
  * Consider using basekits from teapot.

# Remaining Gaps #

## For Athena

* "athena_test", which has needs beyond what [kite test] currently gives.


