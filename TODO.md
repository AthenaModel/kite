# Project TODO List

## Next

* Add "xfile" statement, per the xdocs.md file.  "xfile" because it doesn't
  need to be a documentation file, necessarily.
  * 'kite xfile' pulls in or cleans up the xfiles.
  * 'kite build all' pulls in all xfiles.
  * 'kite clean' calls 'kite xfile clean'.
  * 'xfile {local path} {url}', e.g., 'xfile docs/aag.docx https://...'
  * Alternatively, "curl", "See URL", alludes to "curl" app.
* 'kite deps' needs to show actual versions in teapot.
* Flesh out the test suites
* Flesh out the KDG.
  * Use required material from the notes.

* Consider: add -force, -follow, and -follow-recommend as options to app,
  to be passed along to tclapp.
* We have three flavors: windows, osx, and linux.  That's really
  32-bit windows, 64-bit osx, and 64-bit linux.  We could have five
  architectures: win32, win64, osx, linux32, and linux64. 

* macro(n) should support textutil::expander's textcmd.
  * Should manpage(n)/kitedocs(n) use it for quoting?
* Add %install target to dist; includes an installation script
  * a list of bash commands.
* Clean up "kite new" syntax.  
  * In particular, provide option for description.

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

