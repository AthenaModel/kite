#-----------------------------------------------------------------------
# TITLE:
#   project.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) project file reader/writing
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export project
}

#-----------------------------------------------------------------------
# project ensemble

snit::type ::kutils::project {
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
        apps        ""
        appkits     ""
        libkits     ""
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
        # TODO: error-checking!
        set info(name)        $name
        set info(version)     $version
        set info(description) $description
    }
    
    # AppkitCmd name
    #
    # Implementation of the "appkit" kite file command.

    proc AppkitCmd {name} {
        # TODO: error-checking!
        lappend info(appkits) $name
    }

    #-------------------------------------------------------------------
    # Other Queries

    # appkits
    #
    # Returns the list of appkit names

    typemethod appkits {} {
        return $info(appkits)
    }

    # dumpinfo
    #
    # Dump the project info to stdout.

    typemethod dumpinfo {} {
        puts "Project Information:\n"

        DumpValue "Name:"        $info(name)
        DumpValue "Version:"     $info(version)
        DumpValue "Description:" $info(description)

        puts ""

        DumpValue "Apps:"     [join $info(apps)    ", "]
        DumpValue "AppKits:"  [join $info(appkits) ", "]
        DumpValue "LibKits:"  [join $info(libkits) ", "]
    }

    # DumpValue name value
    #
    # name   - The label, include colon
    # value  - The value to dump
    #
    # Writes a row with the name and value in two columns.  If
    # the value is "", then "n/a" is output.

    proc DumpValue {name value} {
        set fmt "%-12s %s"

        if {$value eq ""} {
            set value "n/a"
        }

        puts [format $fmt $name $value]
    }
    
}



