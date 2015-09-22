# Project TODO List

## Next

* htmltrans/manpage(n)
  * Add line number info to `htmltrans parse`, so that we can give better
    error messages.
  * ehtml(n):
    * Revise kitedoc(n) to use `htmltrans parse`.
    * Need to move formatting from HTML to CSS.  E.g., emit "class=" attributes
      instead of `<tt>` and `<b>` tags.
    * Consecutive `defitem` macros with no description get an empty 
      "<dd> </dd>" that causes a blank line.  The "<dd>" is emitted 
      automatically, and the "</dd>" is added by `htmltrans para`.
      * Ideally, there shouldn't be any "<dd> </dd>"; and also,
        the "</dd>" should really be included by ehtml(n).
      * Can we use the expander stack to handle this, and only include
        the description if there is one?
        * Yes, but it's trickier than it looks.
          * If a macro pushes an expander context, it pushes it for the
            macro's entire result...which is a problem, because we want
            to emit the `<dt>...</dt>`, and then push an empty context.
          * On `<def*>`:
            * Clear the result.
            * If the current context is "def*", retrieve the "dt" var and
              pop the text.
              * Set the result to the "dt" var's value.  If the text isn't
                whitespace or empty, add it in `<dd>...</dd>` to the result. 
            * Push a context called "def*".  
            * Stash the `<dt>...</dt>` as a context var "dt"
            * Return the result.
          * On `</deflist>`, if the current context is "def*", handle 
            the previous item as above.
      * Otherwise, we really need to let the macro indicate that there's
        no item following; it shouldn't be up to htmltrans(n) to unilaterally
        remove the empty item.
        * defitem-, def-, defopt-?
      * Related problem: sometimes we have two syntaxes for a single command,
        and use a pair of defitems to cover it.  But they have the same 
        command name, and hence the same link, and we save only one link
        text.  So the same link text appears twice in the synopsis.
      * Should I be looking for a better syntax to handle this use case?

## Old Notes

* 'kite deps' needs to show actual versions in teapot.
* Flesh out the test suites
* Flesh out the KDG.
  * Use required material from the notes.
* Consider: how to add metadata so that 'project save' updates 
  automatically.

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

