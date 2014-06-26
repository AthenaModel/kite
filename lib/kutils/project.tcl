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
    #   name           - The project name
    #   version        - The version number, x.y.z-Bn
    #   description    - The project title
    #   appkit         - Name of project appkit, or "" if none.
    #
    #   includes       - List of include names
    #   include-$name  - inclusion dictionary for the $name
    #
    #       vcs - git|svn
    #       url - The repository URL
    #       tag - The version/branch tag
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name           ""
        version        ""
        description    ""
        appkit         ""
        includes       {}
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

        if {$rootdir eq ""} {
            return ""
        }

        return [file join $rootdir {*}$args]
    }

    # FindProjectDirectory
    #
    # Starting from the current working directory, works its way up
    # the tree looking for project.kite; if found it returns the 
    # directory containing project.kite, and "" otherwise.

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

        return ""
    }

    #-------------------------------------------------------------------
    # Reading the information from the project file.

    # loadinfo
    #
    # Loads the information from the project file.  We must be
    # in a project tree.

    typemethod loadinfo {} {
        # FIRST, set up the safe interpreter
        # TODO: Use a smartinterp(n), once we can claim Mars as an
        # external dependency.
        set safe [interp create -safe]
        $safe alias project [myproc ProjectCmd]
        $safe alias appkit  [myproc AppkitCmd]
        $safe alias include [myproc IncludeCmd]


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
        if {$info(appkit) ne ""} {
            throw SYNTAX "Multiple appkit statements; only one is allowed."
        }

        set name [string trim [string tolower $name]]

        if {![regexp {^[a-z]\w*$} $name]} {
            throw SYNTAX "Invalid appkit name \"$name\""
        }

        set info(appkit) $name
    }

    # IncludeCmd name vcs url tag
    #
    # name  - Name of included software; used as directory name 
    #         under <root>/includes/
    # vcs   - svn | git
    # url   - URL of the project for cloning/checkout
    # tag   - The specific version of the software to checkout.
    #
    # Pulls the software from the repository at the URL using the
    # "svn" or "git" command line tool.  The URL is to the project
    # root.  The tag is the tag or branch to checkout, in a form
    # appropriate for the VCS.
    #
    # For git, the tag can be any branch or tag name.
    # For svn, the tag is added to the URL, e.g., "trunk", 
    # "branches/athena_6.3.1", "tags/athena_6.3.1-R12".

    proc IncludeCmd {name vcs url tag} {
        prepare vcs  -required -tolower
        prepare name -required
        prepare url  -required
        prepare tag  -required

        if {$vcs ni {git svn}} {
            throw SYNTAX "Unknown VCS on include: \"$vcs\""
        }

        if {![BaseName? $name]} {
            throw SYNTAX "Invalid include name: \"$name\""
        }

        if {$name in $info(includes)} {
            throw SYNTAX "Duplicate include name: \"$name\""
        }

        ladd info(includes) $name
        set info(include-$name) \
            [dict create vcs $vcs url $url tag $tag]
    }


    # BaseName? name
    #
    # name   - A base file name, e.g., <base>.kit.
    #
    # Validates the name; it may contain letters, numbers, underscores,
    # and hyphens, and should begin with a letter.

    proc BaseName? {name} {
        return [regexp {^[a-z][[:alnum:]_-]*$} $name]
    }

    # Version? ver
    #
    # ver   - A version number, e.g, 1.2.3-B12 or 1.2.3-SNAPSHOT.
    #
    # Validates the version.

    proc Version? {ver} {
        # TODO: use the correct regexp for Tcl packages, plus
        # allow -suffix.
        return [regexp {^\d+[.ab]\d+[.ab]\d+(-\w+)?$} $ver]
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
        dict set mapping %project   $info(name)
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

    # intree
    #
    # Returns 1 if we're in a project tree, and 0 otherwise.

    typemethod intree {} {
        return [expr {$rootdir ne ""}]
    }

    # hasinfo
    #
    # Returns 1 if we've successfully loaded project info, and
    # 0 otherwise.

    typemethod hasinfo {} {
        return [expr {$info(name) ne ""}]
    }

    # appkit
    #
    # Returns the appkit name, if any.

    typemethod appkit {} {
        return $info(appkit)
    }

    # include names
    #
    # Returns the list of include names.

    typemethod {include names} {} {
        return $info(includes)
    }

    # include get name ?attr?
    #
    # name  - the include name
    # attr  - Optionally, an include attribute.
    #
    # Returns the include dictionary, or one attribute of it.

    typemethod {include get} {name {attr ""}} {
        if {$attr eq ""} {
            return $info(include-$name)
        } else {
            return [dict get $info(include-$name) $attr]
        }
    }

    # dumpinfo
    #
    # Dump the project info to stdout.

    typemethod dumpinfo {} {
        puts "Project Information:\n"

        DumpValue "Name:"        $info(name)
        DumpValue "Version:"     $info(version)
        DumpValue "Description:" $info(description)
        DumpValue "AppKit:"      [expr {$info(appkit) ne "" ? $info(appkit) : "n/a"}]

        puts ""

        foreach name $info(includes) {
            array set d $info(includes-$name)
            DumpValue "Include:"  "$name as $d(vcs) $d(url) $d(tag)"
        }
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



