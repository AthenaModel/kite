#-----------------------------------------------------------------------
# TITLE:
#   project.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: ktools(n) project file reader/writing
#
#-----------------------------------------------------------------------

namespace eval ::ktools:: {
    namespace export project
}

#-----------------------------------------------------------------------
# project ensemble

snit::type ::ktools::project {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Constants
    
    # The project file name.
    typevariable projfile "project.kite"

    #-------------------------------------------------------------------
    # Type variables

    # The project directory

    typevariable projdir ""

    # info - the project info array
    #
    #   name        - The project name
    #   version     - The version number, x.y.z-Bn
    #   description - The project title
    #   app         - Application name (if any)
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name        ""
        version     ""
        description ""
        app         ""
    }

    #-------------------------------------------------------------------
    # Public Type Methods

    # path ?names...?
    #
    # Find and return the directory containing the project.kite file, which
    # by definition is the top directory for the project.  Cache the
    # name for later.  If "names..." are given, join them to the 
    # dir name and return that.
    #
    # If we cannot find the project directory, throw an error with
    # code FATAL.

    typemethod path {args} {
        if {$projdir eq ""} {
            # Find the project directory, throwing an error if not found.
            set projdir [FindProjectDirectory]   
        }

        return [file join $projdir {*}$args]
    }

    # FindProjectDirectory
    #
    # Starting from the current working directory, works its way up
    # the tree looking for project.kite; if found it returns the 
    # directory containing project.kite.  Otherwise, it throws an
    # error of type FATAL.

    proc FindProjectDirectory {} {
        set lastdir ""
        set nextdir [pwd]

        while {$nextdir ne $lastdir} {
            set candidate [file join $nextdir $projfile]

            try {
                if {[file exists $candidate]} {
                    return $nextdir
                }

                set lastdir $nextdir
                set nextdir [file dirname $lastdir]
            } on error {} {
                # Most likely, we got to directory we can't read.
                break
            }
        }

        throw FATAL \
            "Could not find $projfile in this directory or its parents"
    }
}



