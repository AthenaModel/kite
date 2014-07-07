#-----------------------------------------------------------------------
# TITLE:
#   docstool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "docs" tool.  By default, this docss all of the docs 
#   targets: The app or appkit (if any), teapot packages, docs, and
#   other docs targets specified in project.kite.
#
#   TODO: When we actually have more than one kind of docs product,
#   add arguments so that the user can selectively docs just one thing.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(docs) {
    arglist     {?target? ?-clean?}
    package     ktools
    ensemble    ::ktools::docstool
    description "Format project documentation."
    intree      yes
}

set ::khelp(docs) {
    The "docs" tool formats project documentation in marsdoc(5) and 
    manpage(5) format.  These are Extended HTML (.ehtml) formats 
    defined by the Mars library; see the Mars man pages for more details.

    By default, this tool formats all of the project's ".ehtml" 
    documentation.  Alternatively, a target may be specified, one of:

    * A path relative to <root>, e.g., "docs" or "docs/dev"
    * A man page directory, e.g., "mann"
    * "-clean", meaning to remove all .html files.

    Finally, if the "-clean" option is given then the chosen set of 
    formatted documents are deleted instead of formatted.

    manpage(5) format is used for man pages, which are found in the 
    <root>/docs/man* directories:

    * man1 - Executables
    * man5 - File formats
    * mann - Tcl packages
    * mani - Tcl interfaces

    marsdoc(5) format is used for more general documentation, with 
    section numbers, table of contents, and so forth.  marsdoc(5)
    documents may be found in <root>/docs and any of its non-manpage
    subdirectories.
}

#-----------------------------------------------------------------------
# docstool ensemble

snit::type ::ktools::docstool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs docs 0 1 {?target?} $argv

        set target [lindex $argv 0]

        if {$target eq ""} {
            # Build everything
            docs manpages
            docs marsdocs
            return
        }

        if {$target eq "-clean"} {
            puts "TODO: Provide cleaning services!"
            # docs clean
            return
        }

        # NEXT, get the target directory.
        set dir [GetTargetDirectory $target]

        if {[string match man* [file tail $dir]]} {
            docs manpages [file tail $dir]
        } else {
            docs marsdocs $dir
        }

    }
    
    # GetTargetDirectory target
    #
    # target - The target as a relative directory.

    proc GetTargetDirectory {target} {
        # FIRST, is relative to $root/docs?
        set candidate [project root docs {*}$target]

        if {[file isdirectory $candidate]} {
            return $candidate
        }

        # NEXT, is it relative to $root
        set candidate [project root {*}$target]

        if {[file isdirectory $candidate] &&
            [string match [project root docs]* $candidate]
        } {
            return $candidate
        }

        throw FATAL "Cannot identify docs/ directory from target \"$target\""
    }

 
    
}



