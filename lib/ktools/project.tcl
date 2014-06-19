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

    # The project's root directory

    typevariable rootdir ""

    # info - the project info array
    #
    #   name        - The project name
    #   version     - The version number, x.y.z-Bn
    #   description - The project title
    #   appkit      - List of appkits to build.
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name        ""
        version     ""
        description ""
        appkits     ""
    }

    #-------------------------------------------------------------------
    # Locating the root of the project tree.

    # root ?names...?
    #
    # Find and return the directory containing the project.kite file, which
    # by definition is the top directory for the project.  Cache the
    # name for later.  If "names..." are given, join them to the 
    # dir name and return that.
    #
    # If we cannot find the project directory, throw an error with
    # code FATAL.

    typemethod root {args} {
        if {$rootdir eq ""} {
            # Find the project directory, throwing an error if not found.
            set rootdir [FindProjectDirectory]   
        }

        return [file join $rootdir {*}$args]
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

    #-------------------------------------------------------------------
    # Reading the information from the project file.

    # loadinfo
    #
    # Loads the information from the project file.

    typemethod loadinfo {} {
        # FIRST, set up the safe interpreter
        # TODO: Use a smartinterp(n), once we can claim Mars as an
        # external dependency.
        set safe [interp create -safe]
        $safe alias project [myproc ProjectCmd]
        $safe alias appkit  [myproc AppkitCmd]

        # NEXT, try to load the file
        try {
            $safe eval [readfile [$type root $projfile]]
        } trap FATAL {result} {
            throw FATAL $result
        } on error {result eopts} {
            # TODO: Figure out which errors are FATAL and which
            # are not.
            puts "Got eopts: $eopts"
            exit 1
        } finally {
            interp delete $safe            
        }

        # NEXT, if the project name has not been set, throw an
        # error.

        if {$info(name) eq ""} {
            throw FATAL "No project defined in $projfile"
        }
    }

    # ProjectCmd name version description
    #
    # Implementation of the "project" kite file command.

    proc ProjectCmd {name version description} {
        # TBD: error-checking!
        set info(name)        $name
        set info(version)     $version
        set info(description) $description
    }
    
    # AppkitCmd name
    #
    # Implementation of the "appkit" kite file command.

    proc AppkitCmd {name} {
        # TBD: error-checking!
        lappend info(appkits) $name
    }

    #-------------------------------------------------------------------
    # Other Queries

    # dump
    #
    # Dump the project info to stdout.
    # TODO: Do this right.

    typemethod dump {} {
        puts "Project Information"
        parray info
    }
    
}



