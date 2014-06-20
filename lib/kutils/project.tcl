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
        } trap SYNTAX {result} {
            throw FATAL "Error in project.kite: $result"
        } trap {TCL WRONGARGS} {result} {
            # Assume this is in the project.kite file
            throw FATAL "Error in project.kite: $result"
        } trap FATAL {result} {
            throw FATAL $result
        } on error {result eopts} {
            # TODO: If verbose, include stacktrace.
            throw FATAL $result
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
        set info(name)        [string trim [string tolower $name]]
        set info(version)     [string trim $version]
        set info(description) [string trim $description]

        if {![BaseName? $info(name)]} {
            throw SYNTAX "Invalid project name: \"$info(name)\""
        }

        if {![Version? $info(version)]} {
            throw SYNTAX "Invalid version number: \"$info(version)\""
        }

        if {$info(description) eq ""} {
            throw SYNTAX "Missing project description"
        }
    }
    
    # AppkitCmd name
    #
    # Implementation of the "appkit" kite file command.

    proc AppkitCmd {name} {
        set name [string trim [string tolower $name]]

        if {![regexp {^[a-z]\w*$} $name]} {
            throw SYNTAX "Invalid appkit name \"$name\""
        }

        if {$name in $info(appkits)} {
            throw SYNTAX "Duplicate appkit name \"$name\""
        }
        lappend info(appkits) $name
    }

    # BaseName? name
    #
    # name   - A base file name, e.g., <base>.kit.
    #
    # Validates the name; it may contain letters, numbers, underscores,
    # and hyphens, and should begin with a latter.

    proc BaseName? {name} {
        return [regexp {^[a-z][[:alnum:]_-]*$} $name]
    }

    # Version? ver
    #
    # ver   - A version number, e.g, 1.2.3-B12 or 1.2.3-SNAPSHOT.
    #
    # Validates the version.

    proc Version? {ver} {
        return [regexp {^\d+\.\d+\.\d+(-\w+)?$} $ver]
    }

    #-------------------------------------------------------------------
    # Saving project info for use by the project's own code.

    # kiteinfo save
    #
    # Saves the kiteinfo package to lib/kiteinfo/*.
    #
    # TODO: We probably don't want to include everything in info().

    typemethod {kiteinfo save} {} {
        # FIRST, get the data together
        dict set mapping %package   kiteinfo
        dict set mapping %kiteinfo  [list [array get info]]

        # FIRST, create the directory (if needed)
        set dir [project root lib kiteinfo]
        file mkdir $dir

        # NEXT, generate the files.
        generate pkgIndex   $mapping [file join $dir pkgIndex.tcl]
        generate pkgModules $mapping [file join $dir pkgModules.tcl]
        generate kiteinfo   $mapping [file join $dir kiteinfo.tcl]
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



