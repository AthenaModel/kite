#-----------------------------------------------------------------------
# TITLE:
#   tool_docs.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "docs" tool.  By default, this docss all of the docs 
#   targets: The app or appkit (if any), teapot packages, docs, and
#   other docs targets specified in project.kite.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::DOCS

tool define docs {
    usage       {0 1 "?<target>|-clean?"}
    description "Format project documentation."
    needstree      yes
} {
    The 'kite docs' tool formats project documentation in kitedoc(5) and 
    manpage(5) format.  These are Extended HTML (.ehtml) formats; 
    see the Kite man pages for more details.

    By default, this tool formats all of the project's ".ehtml" 
    documentation.  Alternatively, a target may be specified, one of:

    * A path relative to <root>, e.g., "docs" or "docs/dev", naming
      a directory that contains ".ehtml" files.

    * A file name.  If the file is in docs/man*, Kite formats the man pages
      in that directory; if elsewhere in docs/*, Kite formats the document
      as a kitedoc(5) file.

    * A man page directory, e.g., "mann"

    Finally, if the "-clean" option is given then the chosen set of 
    formatted documents are deleted instead of formatted.

    manpage(5) format is used for man pages, which are found in the 
    <root>/docs/man* directories:

    * man1 - Executables
    * man5 - File formats
    * mann - Tcl packages
    * mani - Tcl interfaces

    kitedoc(5) format is used for more general documentation, with 
    section numbers, table of contents, and so forth.  kitedoc(5)
    documents may be found in <root>/docs and any of its non-manpage
    subdirectories.

    Both manpage(5) and kitedoc(5) documents processed using this tool
    may make use of the project_macros(5) macro set.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        set target [lindex $argv 0]

        if {$target eq ""} {
            # Build everything
            docs manpages
            docs kitedocs
            return
        }

        if {$target eq "-clean"} {
            $type clean
            return
        }

        # NEXT, is the target a file?
        if {[file isfile $target]} {
            if {[file extension $target] ne ".ehtml"} {
                throw FATAL "Kite cannot format [file extension $target] files."
            }

            # Is it in the docs directory?
            set fullpath [file normalize $target]

            if {![string match [project root docs *] $fullpath]} {
                throw FATAL "Target \"$target\" is not under <root>/docs/"
            }

            # Is it a man page file?
            set dir [file dirname $fullpath]

            if {[string match [project root docs man*] $dir]} {
                docs manpages [file tail $dir]
                return
            }

            # It's a kitedoc(5) file.
            docs kitedocs $fullpath
            return
        }

        # NEXT, get the target directory.
        set dir [GetTargetDirectory $target]

        if {[string match man* [file tail $dir]]} {
            docs manpages [file tail $dir]
        } else {
            docs kitedocs $dir
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

    #-------------------------------------------------------------------
    # Clean up

    # clean
    #
    # Removes all built documentation files.

    typemethod clean {} {
        clean "Cleaning manpage(5) man pages..." docs/man*/*.html
        clean "Cleaning kitedoc(5) documents..." docs/*.html docs/*/*.html
    }  
}






